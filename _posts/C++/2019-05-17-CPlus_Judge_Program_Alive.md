---
layout: default
title: CPlus_Judge_Program_Alive
categories:
- C++
tags:
- C++
- Windows
- Linux
- Qt
---
//Author: channy

//Create Date: 2019-05-17 15:37:32

//Description: 给定进程名称、启动参数，判断该进程是否正在运行，启动参数不同的不算 

# CPlus_Judge_Program_Alive

需求：写一个api判断指定名字和启动参数的进程是否已存在，若不存在则启动。

> Method 1: 用win的api'ReadProcessMemory'

实验平台：win 7 64 bit

用'OpenProcess'得到进程句柄，用'ReadProcessMemory'获取地址，第二次调用'ReadProcessMemory'获取参数地址......

结果：。。。当然是失败啦。。。

第一个'ReadProcessMemory'就返回false，然后，就没有然后啦~

> Method 2: 还是用win的api'DuplicateHandle'

实验平台：win 7 64 bit; win 10 64 bit

试了一个，好像还是可以的哦，美滋滋。。。

用Qt启动自己写的.exe，QProcess能够设置参数的那种，用下面的代码能够正确判断'由user启动'的进程。在一般情况下够用。

你以为这就完了？Too young too simple^_^

这种方法并不能获取到由system启动的进程的信息，由system启动的如service会在DuplicateHandle的时候返回false，进不到if里面，然后，就获取不到启动参数啦~

然后呢？看到强调的词了吗？当然是要跳过代码到Method3啦

```c++
//need Ntdll.dll in windows
bool isProgramAlive(QString sProgramName, QString sStartUpParam)
{
    QStringList qslStartParam = sStartUpParam.split(' ', QString::SkipEmptyParts);

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
        else
        {
            qDebug() << QString::number(GetLastError());
        }
        CloseHandle(hProc);
    }while(Process32Next(hSnapshot, &pe));

    CloseHandle(hSnapshot);
```

> Method 3: 用cmd命令，对结果进行分析

实验平台：win 7 64 bit; win 10 64 bit

cmd运行"wmic process where caption='进程名字' get caption,commandline /value"可以获得指定名字的正在运行的进程的启动参数，然后对参数进行分割、判断

在自己的两台机子上跑完全ok，希望在别人的机子上跑不出幺蛾子吧~

```c++
bool isProgramAlive(QString sProgramName, QString sStartUpParam)
{
    QStringList qslStartParam = sStartUpParam.split(' ', QString::SkipEmptyParts);
    QString sCmdGetProgInfo = "wmic process where caption='" + sProgramName + "' get caption,commandline /value";

    QProcess qpCmdProcess(0);
    qpCmdProcess.start(sCmdGetProgInfo);
    qpCmdProcess.waitForStarted();
    qpCmdProcess.waitForFinished();
    QByteArray qbProgInfo = qpCmdProcess.readAllStandardOutput();

    //qDebug() << qpComProcess.readAllStandardError();
    //qDebug() << "qbProgInfo " << qbProgInfo;
    QStringList qslProgInfo = QString(qbProgInfo).split(QRegExp("[\r \n]+"), QString::SkipEmptyParts);

    QStringList qslProgParam;
    int nProgCnt = 0;
    for (QString sInfo : qslProgInfo)
    {
        if (sInfo.contains("Caption"))
        {
            nProgCnt++;
            continue;
        }
        if (sInfo.contains("CommandLine"))
        {
            if (1 >= nProgCnt) continue;
            //qDebug() << qslProgParam.size() << " " << sInfo << " " << qslProgParam;
            if (qslProgParam == qslStartParam) return true;
            qslProgParam.clear();
        }
        else
        {
            qslProgParam.push_back(sInfo);
        }
    }
    if (1 <= nProgCnt)
    {
        //qDebug() << qslProgParam.size() << " " << qslProgParam;
        if (qslProgParam == qslStartParam) return true;
    }

    return false;
}
```



[back](./)

