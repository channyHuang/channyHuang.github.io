---
layout: default
title: Process_Monitor
categories:
- C++
tags:
- C++
---
//Author: channy

//Create Date: 2019-04-12 22:26:52

//Description: 

# Process_Monitor

At the beginning, is there any api which can get exec file verison in linux?
在linux下有没有类似于winapi-GetFileVersion获取可执行文件版本号的方法？

Monitor one process, including memroy usage, cpu percentage, running time, etc.

## get file version
windows
```c++
    LPCWSTR lpFullPathFile = (LPCWSTR)sFullPathFile.unicode();
    DWORD dwInfoSize = GetFileVersionInfoSize(lpFullPathFile, 0);
    if (0 >= dwInfoSize) {
        //Log::info(QString().sprintf("error when getFileVersion of file %s, errorCode = %ld.", sFullPathFile.toStdString().c_str(), GetLastError()));
        return false;
    }

    char *pInfoBuf = new char[dwInfoSize];
    if (false == GetFileVersionInfo(lpFullPathFile,0,dwInfoSize,pInfoBuf ))
    {
        //Log::info(QString().sprintf("error when getFileVersion of file %s, errorCode = %ld", sFullPathFile.toStdString().c_str(), GetLastError()));
        delete [] pInfoBuf;
        return false;
    }

    unsigned int dwInfoValSize;
    VS_FIXEDFILEINFO *pInfoVal = NULL;

    VerQueryValue(pInfoBuf, (TEXT("\\")), (void**)&pInfoVal, &dwInfoValSize);
    delete [] pInfoBuf;

    sProcVersion  = QString().sprintf("%d.%d.%d.%d",
                                        HIWORD(pInfoVal->dwFileVersionMS), LOWORD(pInfoVal->dwFileVersionMS),
                                        HIWORD(pInfoVal->dwFileVersionLS), LOWORD(pInfoVal->dwFileVersionLS));
```

## get file info (modifyTime, fileSize, etc)
can use Qt api QFileInfo, cross platform

## get system version (win or linux)
In windows can use Qt api QSysInfo::windowsVersion(), while in linux, 
```c++
    struct utsname uts;
    if(uname(&uts) >= 0) {
        m_sSystemVersion = QString().sprintf("sysname = %s, release = %s, version = %s, machine = %s",
                                              uts.sysname, uts.release, uts.version, uts.machine);
```

## get boot time
```c++
#ifdef Q_OS_WIN
    LARGE_INTEGER t;
    if (0 == m_nLastPerformanceCounter)
    {
        QueryPerformanceFrequency(&t);
        m_nLastPerformanceCounter = t.QuadPart;
    }

    if (0 == m_nLastPerformanceCounter) return false;

    QueryPerformanceCounter(&t);
    m_nPCStartSeconds = t.QuadPart / m_nLastPerformanceCounter;
    m_nPCStartMSecs =(double)(t.QuadPart - m_nPCStartSeconds * m_nLastPerformanceCounter)*1000000 / m_nLastPerformanceCounter;
#elif defined Q_OS_LINUX
    struct sysinfo s_info;
    if ( 0 == sysinfo(&s_info))
        m_nPCStartSeconds = s_info.uptime;
    m_nPCStartMSecs = 0;
#endif
```

## get disk free space
windows
```c++
#ifdef Q_OS_WIN
    LPCWSTR lpcwstrDriver=(LPCWSTR)sDriver.utf16();
    ULARGE_INTEGER liFreeBytesAvailable, liTotalBytes, liTotalFreeBytes;

    if( !GetDiskFreeSpaceEx( lpcwstrDriver, &liFreeBytesAvailable, &liTotalBytes, &liTotalFreeBytes) )
        return false;

    nDiskFreeSpace = liTotalFreeBytes.QuadPart / BYTETOM; //MB
    nDiskTotalSpace = liTotalBytes.QuadPart / BYTETOM;
#elif defined Q_OS_LINUX
    struct statfs buf;
    if (0 > statfs(sDriver.toStdString().c_str(), &buf))
        return false;

    nDiskTotalSpace = ((long long) buf.f_bsize * (long long) buf.f_blocks) / BYTETOM;
    nDiskFreeSpace = ((long long) buf.f_bsize * (long long) buf.f_bfree) / BYTETOM;
#endif
```

## get process id by name
```c++
#ifdef Q_OS_WIN
    HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (INVALID_HANDLE_VALUE == hSnapshot)
        return false;

    PROCESSENTRY32 pe;
    pe.dwSize = sizeof(PROCESSENTRY32);
    if (Process32First(hSnapshot, &pe))
    {
        do
        {
            if(0 == _stricmp(WcharToChar(pe.szExeFile).c_str(), sProcessName.toStdString().c_str()))
                vPid.push_back(pe.th32ProcessID);
        }while(Process32Next(hSnapshot, &pe));
    }
    CloseHandle(hSnapshot);
#elif defined Q_OS_LINUX
    char buffer[256] = {0};
    QDir dir("/proc");
    dir.setFilter(QDir::Dirs);
    QFileInfoList fileInfoList = dir.entryInfoList();
    for (QFileInfo file : fileInfoList)
    {
        FILE *fp = fopen((file.absoluteFilePath() + "/status").toStdString().c_str(), "r");
        if (NULL == fp)
            continue;

        fgets(buffer, 256, fp);
        fclose(fp);
        char key[20], value[20];
        sscanf(buffer, "%s %s", key, value);

        if (QString(value) == sProcessName)
            vPid.push_back(file.fileName().toInt());
    }
#endif
```

## get total memory info
```c++
#ifdef Q_OS_WIN
    MEMORYSTATUSEX statex;
    statex.dwLength = sizeof (statex);
    GlobalMemoryStatusEx(&statex);
    Log::info(QString().sprintf("physical memory free/total = %lld/%lld(M), "
                                "virtual memory free/total = %lld/%lld(M), "
                                "page file free/total = %lld/%lld(M), "
                                "extended memory = %lld",
                                statex.ullAvailPhys / BYTETOM, statex.ullTotalPhys / BYTETOM,
                                statex.ullAvailVirtual / BYTETOM, statex.ullTotalVirtual / BYTETOM,
                                statex.ullAvailPageFile / BYTETOM, statex.ullTotalPageFile / BYTETOM,
                                statex.ullAvailExtendedVirtual / BYTETOM));
#elif defined Q_OS_LINUX
    struct sysinfo s_info;
    if(0 == sysinfo(&s_info))
    {
        Log::info(QString().sprintf("totalProcess = %d, memory free/total/shared = %ld/%ld/%ld, memory used = %ld,"
                                  "swap total/free = %ld/%ld, high total/free = %ld/%ld",
                                  s_info.procs, s_info.freeram / BYTETOM, s_info.totalram / BYTETOM, s_info.sharedram / BYTETOM,
                                  s_info.bufferram / BYTETOM,
                                  s_info.totalswap / BYTETOM, s_info.freeswap / BYTETOM, s_info.totalhigh / BYTETOM, s_info.freehigh / BYTETOM));
    }
#endif
```

## get total cpu percentage
```c++
#ifdef Q_OS_WIN
    FILETIME ftIdle, ftKernel, ftUser;
    if (GetSystemTimes(&ftIdle, &ftKernel, &ftUser))
    {
        double fCPUIdleTime = transferFileTime(ftIdle);
        double fCPUKernelTime = transferFileTime(ftKernel);
        double fCPUUserTime = transferFileTime(ftUser);
        nCPUUseRate= 100.0 - (fCPUIdleTime - m_fOldCPUIdleTime) / (fCPUKernelTime - m_fOldCPUKernelTime + fCPUUserTime - m_fOldCPUUserTime)*100.0;
        m_fOldCPUIdleTime = fCPUIdleTime;
        m_fOldCPUKernelTime = fCPUKernelTime;
        m_fOldCPUUserTime = fCPUUserTime;
    }
#elif defined Q_OS_LINUX
    int nCPUIdleTime = 0, nCPUKernelTime = 0, nCPUUserTime = 0, nCPUNiceTime = 0;
    FILE *fd = fopen("/proc/stat","r");
    if (NULL != fd)
    {
        char buff[1024]={0};
        fgets(buff,sizeof(buff),fd);
        fclose(fd);

        char name[64]={0};
        sscanf(buff,"%s %d %d %d %d",name,&nCPUUserTime, &nCPUNiceTime, &nCPUKernelTime, &nCPUIdleTime);
        nCPUUseRate = 100.0 - nCPUIdleTime * 100.0 / (nCPUKernelTime + nCPUUserTime + nCPUIdleTime);
    }
#endif
```

## get total process info
```c++
#ifdef Q_OS_WIN
    DWORD dwTotalProcCount = 0;
    DWORD dwTotalThreadCount = 0;
    DWORD dwTotalHandleCount = 0;
    HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (INVALID_HANDLE_VALUE != hSnapshot)
    {
        PROCESSENTRY32 pe;
        pe.dwSize = sizeof(PROCESSENTRY32);
        if (Process32First(hSnapshot, &pe))
        {
            do
            {
                dwTotalProcCount++;
                dwTotalThreadCount += pe.cntThreads;

                HANDLE handle = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, false, pe.th32ProcessID);
                if (NULL == handle)
                    continue;
                DWORD dwHandleCount = 0;
                if (false == GetProcessHandleCount(handle, &dwHandleCount))
                    continue;
                dwTotalHandleCount += dwHandleCount;
            }while(Process32Next(hSnapshot, &pe));
        }
        CloseHandle(hSnapshot);
    }
    Log::info(QString().sprintf("totalProcess = %ld, totalThread = %ld, totalHandle = %ld",
                                dwTotalProcCount, dwTotalThreadCount, dwTotalHandleCount));

#endif
```

## get memory info of each process
```c++
#ifdef Q_OS_WIN
    PROCESS_MEMORY_COUNTERS procMemCounters;

    HANDLE hProcess = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, false, dwProcessId);
    if (NULL == hProcess)
        return false;

    bool res = GetProcessMemoryInfo(hProcess, &procMemCounters, sizeof(procMemCounters));
    if (false == res)
        return false;

    memoryUsed = procMemCounters.WorkingSetSize;
    peakMemoryUsed = procMemCounters.PeakWorkingSetSize;
    pageFileUsed = procMemCounters.PagefileUsage;
    peakPageFileUsed = procMemCounters.PeakPagefileUsage;
#elif defined Q_OS_LINUX
    char file[64] = {0};//æä»¶å?
    FILE *fd;         //å®ä¹æä»¶æéfd
    char line_buff[256] = {0};  //è¯»åè¡çç¼å²å?    sprintf(file,"/proc/%ld/status", dwProcessId);//æä»¶ä¸­ç¬¬11è¡åå«ç

    fd = fopen (file, "r"); //ä»¥Rè¯»çæ¹å¼æå¼æä»¶åèµç»æéfd
    if (NULL == fd)
        return false;

    char name[256] = {0};
    QString sAddMemoryInfo;
    while(NULL != fgets(line_buff, sizeof(line_buff), fd))
    {
        sscanf(line_buff, "%s", name);
        if (QString(name) == QString("Threads:"))
        {
            sscanf(line_buff, "%s %ld", name, &dwThreadCount);
        }
        else if (QString(name) == QString("VmPeak:"))
        {
            sscanf(line_buff, "%s %ld", name, &peakMemoryUsed);
        }
        else if (QString(name) == QString("VmRSS:"))
        {
            sscanf(line_buff, "%s %ld", name, &memoryUsed);
        }
        else if (line_buff[0] == 'V' && line_buff[1] == 'm')
        {
            sAddMemoryInfo += QString(line_buff);
        }

    }
    fclose(fd);
    peakMemoryUsed *= 1024;
    memoryUsed *= 1024;
#endif
```

## get cpu percentage of each process
```c++
    long long curTime = 0;
#ifdef Q_OS_WIN
    HANDLE hProcess = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, false, dwProcessId);
    if (NULL == hProcess)
        return false;

    FILETIME creationTime;
    FILETIME exitTime;
    FILETIME kernelTime;
    FILETIME userTime;

    if (false == GetProcessTimes(hProcess, &creationTime, &exitTime, &kernelTime, &userTime))
         return false;

    filetimeToQDateTime(creationTime, procStartTime);
    procStartTime = procStartTime.addSecs(3600 * 8);
    curTime = (transferFileTime(kernelTime) + transferFileTime(userTime)) / m_nNumberOfProcessors;

    FILETIME sysTime;
    GetSystemTimeAsFileTime(&sysTime);

    if (0 == lastSysTime || 0 == lastTime)
    {
        //first time to calc
        lastSysTime = transferFileTime(sysTime);
        lastTime = curTime;
        cpuPercentage = 0;
        return true;
    }

    if (0 != transferFileTime(sysTime) - lastSysTime)
        cpuPercentage = (curTime - lastTime) * 100.0 / (transferFileTime(sysTime) - lastSysTime);

    lastSysTime = transferFileTime(sysTime);
#elif defined Q_OS_LINUX

#define PROCESS_ITEM 14

    char file_name[64]={0};

    FILE *fd;
    char line_buff[1024]={0};
    sprintf(file_name,"/proc/%ld/stat", dwProcessId);

    fd = fopen(file_name,"r");
    if(nullptr == fd){
        return 0;
    }

    int nCurUptime = 0;
    struct sysinfo s_info;
    if ( 0 == sysinfo(&s_info))
        nCurUptime = s_info.uptime;

    int userTime;
    int systemTime;
    int curUserTime;
    int curSystemTime;
    fgets(line_buff,sizeof(line_buff), fd);

    sscanf(line_buff,"%ld",&dwProcessId);
    const char *q =getItems(line_buff, PROCESS_ITEM);
    sscanf(q,"%d %d %d %d",&userTime,&systemTime,&curUserTime,&curSystemTime);

    q = getItems(line_buff, PROCESS_ITEM + 8);
    int nProcStartTime;
    sscanf(q, "%d", &nProcStartTime);
    procStartTime = QDateTime::currentDateTime().addSecs(nProcStartTime / sysconf(_SC_CLK_TCK) - nCurUptime);
    fclose(fd);

    cpuPercentage = (userTime + systemTime) * 100.0 / sysconf(_SC_CLK_TCK) / (nCurUptime - nProcStartTime / sysconf(_SC_CLK_TCK));

    lastSysTime = systemTime;
#endif
    lastTime = curTime;
```

## get all threads of each process
```c++
#ifdef Q_OS_WIN
    THREADENTRY32 te;
    te.dwSize = sizeof(THREADENTRY32);

    HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
    if (INVALID_HANDLE_VALUE == hSnapshot)
        return false;

    if(Thread32First(hSnapshot, &te))
    {
        do
        {
            if(dwProcessId == te.th32OwnerProcessID)
                vThreadId.push_back(te.th32ThreadID);
        }while(Thread32Next(hSnapshot, &te));
    }
    CloseHandle(hSnapshot);
#endif
```

## judge a process alive by name

windows
loop each alive process to file the target one, need ntdll.dll
```c++
    HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (INVALID_HANDLE_VALUE == hSnapshot)
        return false;

    PROCESSENTRY32 pe;
    pe.dwSize = sizeof(PROCESSENTRY32);
    if (false == Process32First(hSnapshot, &pe))
        return false;
    do
    {
        if(0 != _stricmp(WcharToChar(pe.szExeFile).c_str(), sProgramName.toStdString().c_str())) continue;

        HANDLE hProc = OpenProcess(PROCESS_ALL_ACCESS, FALSE, pe.th32ProcessID);
        if (INVALID_HANDLE_VALUE == hProc) continue;

        HANDLE hNewProcess = NULL;
        PEB peb;
        RTL_USER_PROCESS_PARAMETERS upps;
        HMODULE hModule = LoadLibrary(QString("Ntdll.dll").toStdWString().c_str());
        typedef NTSTATUS(WINAPI *NtQueryInformationProcessFace)(HANDLE, DWORD, PVOID, ULONG, PULONG);
        NtQueryInformationProcessFace NtQueryInformationProcess = (NtQueryInformationProcessFace)GetProcAddress(hModule, "NtQueryInformationProcess");
        if (DuplicateHandle(GetCurrentProcess(), hProc, GetCurrentProcess(), &hNewProcess, 0, FALSE, DUPLICATE_SAME_ACCESS))
        {
            PROCESS_BASIC_INFORMATION pbi;
            NTSTATUS isok = NtQueryInformationProcess(hNewProcess, ProcessBasicInformation, (PVOID)&pbi, sizeof(PROCESS_BASIC_INFORMATION), 0);
            if (BCRYPT_SUCCESS(isok))
            {
                if (ReadProcessMemory(hNewProcess, pbi.PebBaseAddress, &peb, sizeof(PEB), 0))
                {
                    if (ReadProcessMemory(hNewProcess, peb.ProcessParameters, &upps, sizeof(RTL_USER_PROCESS_PARAMETERS), 0))
                    {
                        WCHAR *buffer = new WCHAR[upps.CommandLine.Length + 1];
                        ZeroMemory(buffer, (upps.CommandLine.Length + 1) * sizeof(WCHAR));
                        ReadProcessMemory(hNewProcess, upps.CommandLine.Buffer, buffer, upps.CommandLine.Length, 0);

                        QString qsProcParam = QString::fromWCharArray(buffer, upps.CommandLine.Length).toUtf8();
                        delete buffer;
                        QStringList qslProcParam = qsProcParam.split(' ', QString::SkipEmptyParts);

                        if (qslProcParam.size() == qslStartParam.size() + 1)
                        {
                            int nPos = 1;
                            for (QString sParam : qslStartParam)
                            {
                                if (qslProcParam[nPos] != sParam) break;
                                nPos++;
                            }
                            if (nPos == qslProcParam.size())
                                return true;
                        }
                    }
                }
            }
            CloseHandle(hNewProcess);
        }
        CloseHandle(hProc);
    }while(Process32Next(hSnapshot, &pe));

    CloseHandle(hSnapshot);
```
linux
loop each file under /proc to find the target one
```c++
    char buffer[256] = {0};
    QDir dir("/proc");
    dir.setFilter(QDir::Dirs);
    QFileInfoList fileInfoList = dir.entryInfoList();
    for (QFileInfo file : fileInfoList)
    {
        FILE *fp = fopen((file.absoluteFilePath() + "/status").toStdString().c_str(), "r");
        if (NULL == fp)
            continue;

        fgets(buffer, 256, fp);
        char key[20], value[20];
        sscanf(buffer, "%s %s", key, value);
        fclose(fp);

        if (QString(value) != sProgramName)
            continue;

        int pid = file.fileName().toInt();
        FILE *cmdfp = fopen(QString().sprintf("/proc/%d/cmdline", pid).toStdString().c_str(), "r");
        if (NULL == cmdfp)
            continue;

        memset(buffer, 0, 256);
        fgets(buffer, 256, cmdfp);
        QString qsProcParam = QString::fromUtf8(buffer, 256);
        QStringList qslProcParam = qsProcParam.split(QChar('\0'), QString::SkipEmptyParts);
        if (qslProcParam.size() == qslStartParam.size() + 1)
        {
            int nPos = 1;
            for (QString sParam : qslStartParam)
            {
                if (qslProcParam[nPos] != sParam) break;
                nPos++;
            }
            if (nPos == qslProcParam.size())
                return true;
        }
        fclose(cmdfp);
    }
```

## get handle and handle count
windows
```c++
    hProcess = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, false, dwProcessId);
    if (NULL != hProcess)
        GetProcessHandleCount(hProcess, &dwHandleCount);
```

[back](./)

---
layout: default
