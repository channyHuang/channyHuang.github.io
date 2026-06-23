---
layout: default
title: Signature
categories:
- Security
tags:
- Security
---
//Description: 指纹识别和文件签名

//Create Date: 2021-02-01 00:09:20

//Author: channy

# 指纹识别
## 指纹特性：
1. 指纹的几何特性：指在空间上嵴是突起的，峪是凹下的。嵴与嵴相交、相连、分开会表现为一些几何图案。
2. 指纹的生物特性：指嵴和峪的导电性不同，与空气之间形成的介电常数不同、温度不同等。
3. 指纹的物理特性：指嵴和峪着力在水平面上时，对接触面形成的压力不同、对波的阻抗不同等。
## 指纹采集
* 光学传感。利用光的折摄和反射原理，将手指放在光学镜片上，手指在内置光源照射下，光从底部射向三棱镜，并经棱镜射出，射出的光线在手指表面指纹凹凸不平的线纹上折射的角度及反射回去的光线明暗就会不一样。
* 电容传感。将电容感整合于一块芯片中，当指纹按压芯片表面时，内部电容感测器会根据指纹波峰与波谷而产生的电荷差，从而形成指纹影像。
* 射频/超声波传感。
* 力学/热学传感。
## 指纹识别
在指纹图象上找到并比对指纹的特征。类似于人脸识别。特征点检测。
## winapi
### Windows Biometric Framework [WBF](https://docs.microsoft.com/en-us/windows/win32/secbiomet/biometric-service-api-portal)
WBF支持windows 7

WinBioOpenSession 打开设备

WinBioEnrollBegin 开始录入指纹

WinBioVerify 验证指纹

# 数字签名
## 加密和签名的区别

 序号 | 加密 | 签名 |
 ---|---|---|
 1 | 保护发送端，保证数据不被第三方篡改 | 保护接收端，保证数据是从可信任方发送过来的 |
 2 | 使用接收方公钥加密 | 使用发送方私钥签名 |
 
## 签名过程

### windows下pe文件签名

#### 嵌入式签名

见pe文件结构

微软自带签名工具signtool

#### 编录签名

将签名数据另存为.cat的文件中，并不嵌入到pe文件里面。可对任意格式文件进行签名。

### windows下pe文件签名验证

编录文件的签名微软并未公开格式文档。

对于嵌入式签名，

1. 从pe文件中取出签名

WIN_CERTIFICATE.bCertificate是SignedData格式的签名

2. 校验文件本身的签名，遵循PKCS7标准中的SignedData格式。

用IssuerAndSerialNumber找到签名者的证书，使用里面的公钥解密EncryptedDigest得到一个DigestInfo结构（一般是RSA算法），将这个结构与authenticatedAttributes做摘要得到的结构对比

3. 校验证书链一直到根证书

AuthorityKeyIdentifier和SubjectKeyIdentifier

组建证书链时，将把A证书的中的AuthorityKeyIdentifier（简称AKID） 的keyIdentifier、authorityCertIssuer、authorityCertSerialNumber与B证书的SubjectKeyIdentifier（简称SKID）、issuer 、serialNumber分别匹配，如果匹配上则B证书为A证书的签发者。如果A证书的上面三项与自己对应数据匹配上，则A证书为自签名的证书，证书链构建完毕。

校验证书链中每个证书的签名、有效期和用法（是否可以用于代码签名）。签名验证的算法为证书中的signatureAlgorithm，签名是signatureValue，被签名的数据为tbsCertificate，公钥从父证书的subjectPublicKeyInfo里面拿。

4. 对比文件摘要是否与签名中携带的一致

签名数据中的Hash算法和Hash在SignedData的contentInfo中

### 相关数据结构和winapi

CERT_INFO里包含了证书的一些基本信息，包括版本、序列号、签名算法、期效等等

CMSG_SIGNER_INFO里包含了签名者的信息，包括版本、序列号、签名算法、加密信息的hash等

SPROG_PUBLISHERINFO则包含证书颁发机构等

公钥 CERT_INFO.SubjectPublicKeyInfo


 序号 | api | 功能 |
 ---|---|---
 1 | WinVerifyTrust | 验证签名证书 |
 2 | CryptQueryObject | 获取签名信息HCRYPTMSG |
 3 | CryptMsgGetParam | 获取签名者信息PCMSG_SIGNER_INFO |
 4 | GetProgAndPublisherInfo |  |
 5 | CertFindCertificateInStore | 从商店中获取证书信息 |
 6 | GetTimeStampSignerInfo | 获取时间戳 |
 7 | GetDateOfTimeStamp | 获取证书期限 |
 8 | CertGetNameString | |

### 可能存在的问题

1. WinVerifyTrust

验证CRL（销证书列表）时使用的WinINet系列API性能不好。这个系列的API是出了名的不稳定，而且据说可能会导致堆破坏

2. 

枚举签名时的死循环。据说在XP系统上WinVerfiyTrust在校验PE文件嵌入式签名时，循环枚举签名时没有判断签名的长度，如果PE文件被破坏，签名长度为0的话，WinVerfiyTrust会陷入死循环。

3. 一般的CA都是有基本的安全概念的，对于证书的颁发都会比较谨慎。但是某些有途径向用户电脑插入根证书的厂商对于证书的颁发并不谨慎

### 可能的改进

1. 写验证签名的代码，并且带一个可信的根证书列表下去，验证通过后，将整个证书链所有证书的信息都通过自己的CS协议发送到自己的后台来验证证书是否可信，这样我们还可以通过后台来干掉吊销列表中的证书。

## 参考
[对Windows 平台下PE文件数字签名的一些研究](https://blog.csdn.net/snowfoxmonitor/article/details/79829518)
[openssl](https://www.openssl.org/)

## winapi使用样例

### 用winapi验证编录签名和嵌入式签名
```
#include <windows.h>
#include <tchar.h>
#include <stdio.h>
#include <psapi.h>
#include <Softpub.h>
#include <Mscat.h>

#pragma comment (lib, "wintrust")
// To ensure correct resolution of symbols, add Psapi.lib to TARGETLIBS
// and compile with -DPSAPI_VERSION=1
BOOL CheckFileTrust(LPCWSTR lpFileName)
{
    BOOL bRet = FALSE;
    WINTRUST_DATA wd = { 0 };
    WINTRUST_FILE_INFO wfi = { 0 };
    WINTRUST_CATALOG_INFO wci = { 0 };
    CATALOG_INFO ci = { 0 };

    HCATADMIN hCatAdmin = NULL;
    if (!CryptCATAdminAcquireContext(&hCatAdmin, NULL, 0))
    {
        return FALSE;
    }

    HANDLE hFile = CreateFileW(lpFileName, GENERIC_READ, FILE_SHARE_READ,
        NULL, OPEN_EXISTING, 0, NULL);
    if (INVALID_HANDLE_VALUE == hFile)
    {
        CryptCATAdminReleaseContext(hCatAdmin, 0);
        return FALSE;
    }

    DWORD dwCnt = 100;
    BYTE byHash[100];
    CryptCATAdminCalcHashFromFileHandle(hFile, &dwCnt, byHash, 0);
    CloseHandle(hFile);

    LPWSTR pszMemberTag = new WCHAR[dwCnt * 2 + 1];
    for (DWORD dw = 0; dw < dwCnt; ++dw)
    {
        wsprintfW(&pszMemberTag[dw * 2], L"%02X", byHash[dw]);
    }

    HCATINFO hCatInfo = CryptCATAdminEnumCatalogFromHash(hCatAdmin,
        byHash, dwCnt, 0, NULL);
    if (NULL == hCatInfo)
    {
        wfi.cbStruct = sizeof(WINTRUST_FILE_INFO);
        wfi.pcwszFilePath = lpFileName;
        wfi.hFile = NULL;
        wfi.pgKnownSubject = NULL;

        wd.cbStruct = sizeof(WINTRUST_DATA);
        wd.dwUnionChoice = WTD_CHOICE_FILE;
        wd.pFile = &wfi;
        wd.dwUIChoice = WTD_UI_NONE;
        wd.fdwRevocationChecks = WTD_REVOKE_NONE;
        wd.dwStateAction = WTD_STATEACTION_IGNORE;
        wd.dwProvFlags = WTD_SAFER_FLAG;
        wd.hWVTStateData = NULL;
        wd.pwszURLReference = NULL;
    }
    else
    {
        CryptCATCatalogInfoFromContext(hCatInfo, &ci, 0);
        wci.cbStruct = sizeof(WINTRUST_CATALOG_INFO);
        wci.pcwszCatalogFilePath = ci.wszCatalogFile;
        wci.pcwszMemberFilePath = lpFileName;
        wci.pcwszMemberTag = pszMemberTag;

        wd.cbStruct = sizeof(WINTRUST_DATA);
        wd.dwUnionChoice = WTD_CHOICE_CATALOG;
        wd.pCatalog = &wci;
        wd.dwUIChoice = WTD_UI_NONE;
        wd.fdwRevocationChecks = WTD_STATEACTION_VERIFY;
        wd.dwProvFlags = 0;
        wd.hWVTStateData = NULL;
        wd.pwszURLReference = NULL;
    }
    GUID action = WINTRUST_ACTION_GENERIC_VERIFY_V2;
    HRESULT hr = WinVerifyTrust(NULL, &action, &wd);
    bRet = SUCCEEDED(hr);

    if (NULL != hCatInfo)
    {
        CryptCATAdminReleaseCatalogContext(hCatAdmin, hCatInfo, 0);
    }
    CryptCATAdminReleaseContext(hCatAdmin, 0);
    delete[] pszMemberTag;
    return bRet;
}

int _tmain(int argc, TCHAR* argv[])
{

    CheckFileTrust(L"C:/downloadInstallers/BaiduNetdisk_7.0.13.2.exe");
    return 0;
}
```

### 用winapi获取签名部分信息
```
#include <windows.h>
#include <wincrypt.h>
#include <wintrust.h>
#include <stdio.h>
#include <tchar.h>
#include <SoftPub.h>

#pragma comment(lib, "crypt32.lib")
#pragma comment (lib, "wintrust")

#define ENCODING (X509_ASN_ENCODING | PKCS_7_ASN_ENCODING)

typedef struct {
    LPWSTR lpszProgramName;
    LPWSTR lpszPublisherLink;
    LPWSTR lpszMoreInfoLink;
} SPROG_PUBLISHERINFO, * PSPROG_PUBLISHERINFO;

BOOL GetProgAndPublisherInfo(PCMSG_SIGNER_INFO pSignerInfo,
    PSPROG_PUBLISHERINFO Info);
BOOL GetDateOfTimeStamp(PCMSG_SIGNER_INFO pSignerInfo, SYSTEMTIME* st);
BOOL PrintCertificateInfo(PCCERT_CONTEXT pCertContext);
BOOL GetTimeStampSignerInfo(PCMSG_SIGNER_INFO pSignerInfo,
    PCMSG_SIGNER_INFO* pCounterSignerInfo);


BOOL VerifyEmbeddedSignature(LPCWSTR pwszSourceFile)
{
    LONG lStatus;
    DWORD dwLastError;

    // Initialize the WINTRUST_FILE_INFO structure.

    WINTRUST_FILE_INFO FileData;
    memset(&FileData, 0, sizeof(FileData));
    FileData.cbStruct = sizeof(WINTRUST_FILE_INFO);
    FileData.pcwszFilePath = pwszSourceFile;
    FileData.hFile = NULL;
    FileData.pgKnownSubject = NULL;

    /*
    WVTPolicyGUID specifies the policy to apply on the file
    WINTRUST_ACTION_GENERIC_VERIFY_V2 policy checks:

    1) The certificate used to sign the file chains up to a root
    certificate located in the trusted root certificate store. This
    implies that the identity of the publisher has been verified by
    a certification authority.

    2) In cases where user interface is displayed (which this example
    does not do), WinVerifyTrust will check for whether the
    end entity certificate is stored in the trusted publisher store,
    implying that the user trusts content from this publisher.

    3) The end entity certificate has sufficient permission to sign
    code, as indicated by the presence of a code signing EKU or no
    EKU.
    */

    GUID WVTPolicyGUID = WINTRUST_ACTION_GENERIC_VERIFY_V2;
    WINTRUST_DATA WinTrustData;

    // Initialize the WinVerifyTrust input data structure.

    // Default all fields to 0.
    memset(&WinTrustData, 0, sizeof(WinTrustData));

    WinTrustData.cbStruct = sizeof(WinTrustData);

    // Use default code signing EKU.
    WinTrustData.pPolicyCallbackData = NULL;

    // No data to pass to SIP.
    WinTrustData.pSIPClientData = NULL;

    // Disable WVT UI.
    WinTrustData.dwUIChoice = WTD_UI_NONE;

    // No revocation checking.
    WinTrustData.fdwRevocationChecks = WTD_REVOKE_NONE;

    // Verify an embedded signature on a file.
    WinTrustData.dwUnionChoice = WTD_CHOICE_FILE;

    // Verify action.
    WinTrustData.dwStateAction = WTD_STATEACTION_VERIFY;

    // Verification sets this value.
    WinTrustData.hWVTStateData = NULL;

    // Not used.
    WinTrustData.pwszURLReference = NULL;

    // This is not applicable if there is no UI because it changes 
    // the UI to accommodate running applications instead of 
    // installing applications.
    WinTrustData.dwUIContext = 0;

    // Set pFile.
    WinTrustData.pFile = &FileData;

    // WinVerifyTrust verifies signatures as specified by the GUID 
    // and Wintrust_Data.
    lStatus = WinVerifyTrust(
        NULL,
        &WVTPolicyGUID,
        &WinTrustData);

    switch (lStatus)
    {
    case ERROR_SUCCESS:
        /*
        Signed file:
            - Hash that represents the subject is trusted.

            - Trusted publisher without any verification errors.

            - UI was disabled in dwUIChoice. No publisher or
                time stamp chain errors.

            - UI was enabled in dwUIChoice and the user clicked
                "Yes" when asked to install and run the signed
                subject.
        */
        wprintf_s(L"The file \"%s\" is signed and the signature "
            L"was verified.\n",
            pwszSourceFile);
        break;

    case TRUST_E_NOSIGNATURE:
        // The file was not signed or had a signature 
        // that was not valid.

        // Get the reason for no signature.
        dwLastError = GetLastError();
        if (TRUST_E_NOSIGNATURE == dwLastError ||
            TRUST_E_SUBJECT_FORM_UNKNOWN == dwLastError ||
            TRUST_E_PROVIDER_UNKNOWN == dwLastError)
        {
            // The file was not signed.
            wprintf_s(L"The file \"%s\" is not signed.\n",
                pwszSourceFile);
        }
        else
        {
            // The signature was not valid or there was an error 
            // opening the file.
            wprintf_s(L"An unknown error occurred trying to "
                L"verify the signature of the \"%s\" file.\n",
                pwszSourceFile);
        }

        break;

    case TRUST_E_EXPLICIT_DISTRUST:
        // The hash that represents the subject or the publisher 
        // is not allowed by the admin or user.
        wprintf_s(L"The signature is present, but specifically "
            L"disallowed.\n");
        break;

    case TRUST_E_SUBJECT_NOT_TRUSTED:
        // The user clicked "No" when asked to install and run.
        wprintf_s(L"The signature is present, but not "
            L"trusted.\n");
        break;

    case CRYPT_E_SECURITY_SETTINGS:
        /*
        The hash that represents the subject or the publisher
        was not explicitly trusted by the admin and the
        admin policy has disabled user trust. No signature,
        publisher or time stamp errors.
        */
        wprintf_s(L"CRYPT_E_SECURITY_SETTINGS - The hash "
            L"representing the subject or the publisher wasn't "
            L"explicitly trusted by the admin and admin policy "
            L"has disabled user trust. No signature, publisher "
            L"or timestamp errors.\n");
        break;

    default:
        // The UI was disabled in dwUIChoice or the admin policy 
        // has disabled user trust. lStatus contains the 
        // publisher or time stamp chain error.
        wprintf_s(L"Error is: 0x%x.\n",
            lStatus);
        break;
    }

    // Any hWVTStateData must be released by a call with close.
    WinTrustData.dwStateAction = WTD_STATEACTION_CLOSE;

    lStatus = WinVerifyTrust(
        NULL,
        &WVTPolicyGUID,
        &WinTrustData);

    return true;
}

int _tmain(int argc, TCHAR* argv[])
{
    WCHAR szFileName[MAX_PATH];
    HCERTSTORE hStore = NULL;
    HCRYPTMSG hMsg = NULL;
    PCCERT_CONTEXT pCertContext = NULL;
    BOOL fResult;
    DWORD dwEncoding, dwContentType, dwFormatType;
    PCMSG_SIGNER_INFO pSignerInfo = NULL;
    PCMSG_SIGNER_INFO pCounterSignerInfo = NULL;
    DWORD dwSignerInfo;
    CERT_INFO CertInfo;
    SPROG_PUBLISHERINFO ProgPubInfo;
    SYSTEMTIME st;

    ZeroMemory(&ProgPubInfo, sizeof(ProgPubInfo));
    __try
    {
        if (argc != 2)
        {
            _tprintf(_T("Usage: SignedFileInfo <filename>\n"));
            return 0;
        }

# ifdef UNICODE
        lstrcpynW(szFileName, argv[1], MAX_PATH);
#else
        if (mbstowcs(szFileName, argv[1], MAX_PATH) == -1)
        {
            printf("Unable to convert to unicode.\n");
            __leave;
        }
#endif

        // Get message handle and store handle from the signed file.
        fResult = CryptQueryObject(CERT_QUERY_OBJECT_FILE,
            szFileName,
            CERT_QUERY_CONTENT_FLAG_PKCS7_SIGNED_EMBED,
            CERT_QUERY_FORMAT_FLAG_BINARY,
            0,
            &dwEncoding,
            &dwContentType,
            &dwFormatType,
            &hStore,
            &hMsg,
            NULL);
        if (!fResult)
        {
            _tprintf(_T("CryptQueryObject failed with %x\n"), GetLastError());
            __leave;
        }

        // Get signer information size.
        fResult = CryptMsgGetParam(hMsg,
            CMSG_SIGNER_INFO_PARAM,
            0,
            NULL,
            &dwSignerInfo);
        if (!fResult)
        {
            _tprintf(_T("CryptMsgGetParam failed with %x\n"), GetLastError());
            __leave;
        }

        // Allocate memory for signer information.
        pSignerInfo = (PCMSG_SIGNER_INFO)LocalAlloc(LPTR, dwSignerInfo);
        if (!pSignerInfo)
        {
            _tprintf(_T("Unable to allocate memory for Signer Info.\n"));
            __leave;
        }

        // Get Signer Information.
        fResult = CryptMsgGetParam(hMsg,
            CMSG_SIGNER_INFO_PARAM,
            0,
            (PVOID)pSignerInfo,
            &dwSignerInfo);
        if (!fResult)
        {
            _tprintf(_T("CryptMsgGetParam failed with %x\n"), GetLastError());
            __leave;
        }

        // Get program name and publisher information from 
        // signer info structure.
        if (GetProgAndPublisherInfo(pSignerInfo, &ProgPubInfo))
        {
            if (ProgPubInfo.lpszProgramName != NULL)
            {
                wprintf(L"Program Name : %s\n",
                    ProgPubInfo.lpszProgramName);
            }

            if (ProgPubInfo.lpszPublisherLink != NULL)
            {
                wprintf(L"Publisher Link : %s\n",
                    ProgPubInfo.lpszPublisherLink);
            }

            if (ProgPubInfo.lpszMoreInfoLink != NULL)
            {
                wprintf(L"MoreInfo Link : %s\n",
                    ProgPubInfo.lpszMoreInfoLink);
            }
        }

        _tprintf(_T("\n"));

        // Search for the signer certificate in the temporary 
        // certificate store.
        CertInfo.Issuer = pSignerInfo->Issuer;
        CertInfo.SerialNumber = pSignerInfo->SerialNumber;

        pCertContext = CertFindCertificateInStore(hStore,
            ENCODING,
            0,
            CERT_FIND_SUBJECT_CERT,
            (PVOID)&CertInfo,
            NULL);
        if (!pCertContext)
        {
            _tprintf(_T("CertFindCertificateInStore failed with %x\n"),
                GetLastError());
            __leave;
        }

        // Print Signer certificate information.
        _tprintf(_T("Signer Certificate:\n\n"));
        PrintCertificateInfo(pCertContext);
        _tprintf(_T("\n"));

        // Get the timestamp certificate signerinfo structure.
        if (GetTimeStampSignerInfo(pSignerInfo, &pCounterSignerInfo))
        {
            // Search for Timestamp certificate in the temporary
            // certificate store.
            CertInfo.Issuer = pCounterSignerInfo->Issuer;
            CertInfo.SerialNumber = pCounterSignerInfo->SerialNumber;

            pCertContext = CertFindCertificateInStore(hStore,
                ENCODING,
                0,
                CERT_FIND_SUBJECT_CERT,
                (PVOID)&CertInfo,
                NULL);
            if (!pCertContext)
            {
                _tprintf(_T("CertFindCertificateInStore failed with %x\n"),
                    GetLastError());
                __leave;
            }

            // Print timestamp certificate information.
            _tprintf(_T("TimeStamp Certificate:\n\n"));
            PrintCertificateInfo(pCertContext);
            _tprintf(_T("\n"));

            // Find Date of timestamp.
            if (GetDateOfTimeStamp(pCounterSignerInfo, &st))
            {
                _tprintf(_T("Date of TimeStamp : %02d/%02d/%04d %02d:%02d\n"),
                    st.wMonth,
                    st.wDay,
                    st.wYear,
                    st.wHour,
                    st.wMinute);
            }
            _tprintf(_T("\n"));
        }
    }
    __finally
    {
        // Clean up.
        if (ProgPubInfo.lpszProgramName != NULL)
            LocalFree(ProgPubInfo.lpszProgramName);
        if (ProgPubInfo.lpszPublisherLink != NULL)
            LocalFree(ProgPubInfo.lpszPublisherLink);
        if (ProgPubInfo.lpszMoreInfoLink != NULL)
            LocalFree(ProgPubInfo.lpszMoreInfoLink);

        if (pSignerInfo != NULL) LocalFree(pSignerInfo);
        if (pCounterSignerInfo != NULL) LocalFree(pCounterSignerInfo);
        if (pCertContext != NULL) CertFreeCertificateContext(pCertContext);
        if (hStore != NULL) CertCloseStore(hStore, 0);
        if (hMsg != NULL) CryptMsgClose(hMsg);
    }
    return 0;
}

BOOL PrintCertificateInfo(PCCERT_CONTEXT pCertContext)
{
    BOOL fReturn = FALSE;
    LPTSTR szName = NULL;
    DWORD dwData;

    __try
    {
        // Print Serial Number.
        _tprintf(_T("Serial Number: "));
        dwData = pCertContext->pCertInfo->SerialNumber.cbData;
        for (DWORD n = 0; n < dwData; n++)
        {
            _tprintf(_T("%02x "),
                pCertContext->pCertInfo->SerialNumber.pbData[dwData - (n + 1)]);
        }
        _tprintf(_T("\n"));

        // Get Issuer name size.
        if (!(dwData = CertGetNameString(pCertContext,
            CERT_NAME_SIMPLE_DISPLAY_TYPE,
            CERT_NAME_ISSUER_FLAG,
            NULL,
            NULL,
            0)))
        {
            _tprintf(_T("CertGetNameString failed.\n"));
            __leave;
        }

        // Allocate memory for Issuer name.
        szName = (LPTSTR)LocalAlloc(LPTR, dwData * sizeof(TCHAR));
        if (!szName)
        {
            _tprintf(_T("Unable to allocate memory for issuer name.\n"));
            __leave;
        }

        // Get Issuer name.
        if (!(CertGetNameString(pCertContext,
            CERT_NAME_SIMPLE_DISPLAY_TYPE,
            CERT_NAME_ISSUER_FLAG,
            NULL,
            szName,
            dwData)))
        {
            _tprintf(_T("CertGetNameString failed.\n"));
            __leave;
        }

        // print Issuer name.
        _tprintf(_T("Issuer Name: %s\n"), szName);
        LocalFree(szName);
        szName = NULL;

        // Get Subject name size.
        if (!(dwData = CertGetNameString(pCertContext,
            CERT_NAME_SIMPLE_DISPLAY_TYPE,
            0,
            NULL,
            NULL,
            0)))
        {
            _tprintf(_T("CertGetNameString failed.\n"));
            __leave;
        }

        // Allocate memory for subject name.
        szName = (LPTSTR)LocalAlloc(LPTR, dwData * sizeof(TCHAR));
        if (!szName)
        {
            _tprintf(_T("Unable to allocate memory for subject name.\n"));
            __leave;
        }

        // Get subject name.
        if (!(CertGetNameString(pCertContext,
            CERT_NAME_SIMPLE_DISPLAY_TYPE,
            0,
            NULL,
            szName,
            dwData)))
        {
            _tprintf(_T("CertGetNameString failed.\n"));
            __leave;
        }

        // Print Subject Name.
        _tprintf(_T("Subject Name: %s\n"), szName);

        fReturn = TRUE;
    }
    __finally
    {
        if (szName != NULL) LocalFree(szName);
    }

    return fReturn;
}

LPWSTR AllocateAndCopyWideString(LPCWSTR inputString)
{
    LPWSTR outputString = NULL;

    outputString = (LPWSTR)LocalAlloc(LPTR,
        (wcslen(inputString) + 1) * sizeof(WCHAR));
    if (outputString != NULL)
    {
        lstrcpyW(outputString, inputString);
    }
    return outputString;
}

BOOL GetProgAndPublisherInfo(PCMSG_SIGNER_INFO pSignerInfo,
    PSPROG_PUBLISHERINFO Info)
{
    BOOL fReturn = FALSE;
    PSPC_SP_OPUS_INFO OpusInfo = NULL;
    DWORD dwData;
    BOOL fResult;

    __try
    {
        // Loop through authenticated attributes and find
        // SPC_SP_OPUS_INFO_OBJID OID.
        for (DWORD n = 0; n < pSignerInfo->AuthAttrs.cAttr; n++)
        {
            if (lstrcmpA(SPC_SP_OPUS_INFO_OBJID,
                pSignerInfo->AuthAttrs.rgAttr[n].pszObjId) == 0)
            {
                // Get Size of SPC_SP_OPUS_INFO structure.
                fResult = CryptDecodeObject(ENCODING,
                    SPC_SP_OPUS_INFO_OBJID,
                    pSignerInfo->AuthAttrs.rgAttr[n].rgValue[0].pbData,
                    pSignerInfo->AuthAttrs.rgAttr[n].rgValue[0].cbData,
                    0,
                    NULL,
                    &dwData);
                if (!fResult)
                {
                    _tprintf(_T("CryptDecodeObject failed with %x\n"),
                        GetLastError());
                    __leave;
                }

                // Allocate memory for SPC_SP_OPUS_INFO structure.
                OpusInfo = (PSPC_SP_OPUS_INFO)LocalAlloc(LPTR, dwData);
                if (!OpusInfo)
                {
                    _tprintf(_T("Unable to allocate memory for Publisher Info.\n"));
                    __leave;
                }

                // Decode and get SPC_SP_OPUS_INFO structure.
                fResult = CryptDecodeObject(ENCODING,
                    SPC_SP_OPUS_INFO_OBJID,
                    pSignerInfo->AuthAttrs.rgAttr[n].rgValue[0].pbData,
                    pSignerInfo->AuthAttrs.rgAttr[n].rgValue[0].cbData,
                    0,
                    OpusInfo,
                    &dwData);
                if (!fResult)
                {
                    _tprintf(_T("CryptDecodeObject failed with %x\n"),
                        GetLastError());
                    __leave;
                }

                // Fill in Program Name if present.
                if (OpusInfo->pwszProgramName)
                {
                    Info->lpszProgramName =
                        AllocateAndCopyWideString(OpusInfo->pwszProgramName);
                }
                else
                    Info->lpszProgramName = NULL;

                // Fill in Publisher Information if present.
                if (OpusInfo->pPublisherInfo)
                {

                    switch (OpusInfo->pPublisherInfo->dwLinkChoice)
                    {
                    case SPC_URL_LINK_CHOICE:
                        Info->lpszPublisherLink =
                            AllocateAndCopyWideString(OpusInfo->pPublisherInfo->pwszUrl);
                        break;

                    case SPC_FILE_LINK_CHOICE:
                        Info->lpszPublisherLink =
                            AllocateAndCopyWideString(OpusInfo->pPublisherInfo->pwszFile);
                        break;

                    default:
                        Info->lpszPublisherLink = NULL;
                        break;
                    }
                }
                else
                {
                    Info->lpszPublisherLink = NULL;
                }

                // Fill in More Info if present.
                if (OpusInfo->pMoreInfo)
                {
                    switch (OpusInfo->pMoreInfo->dwLinkChoice)
                    {
                    case SPC_URL_LINK_CHOICE:
                        Info->lpszMoreInfoLink =
                            AllocateAndCopyWideString(OpusInfo->pMoreInfo->pwszUrl);
                        break;

                    case SPC_FILE_LINK_CHOICE:
                        Info->lpszMoreInfoLink =
                            AllocateAndCopyWideString(OpusInfo->pMoreInfo->pwszFile);
                        break;

                    default:
                        Info->lpszMoreInfoLink = NULL;
                        break;
                    }
                }
                else
                {
                    Info->lpszMoreInfoLink = NULL;
                }

                fReturn = TRUE;

                break; // Break from for loop.
            } // lstrcmp SPC_SP_OPUS_INFO_OBJID 
        } // for 
    }
    __finally
    {
        if (OpusInfo != NULL) LocalFree(OpusInfo);
    }

    return fReturn;
}

BOOL GetDateOfTimeStamp(PCMSG_SIGNER_INFO pSignerInfo, SYSTEMTIME* st)
{
    BOOL fResult;
    FILETIME lft, ft;
    DWORD dwData;
    BOOL fReturn = FALSE;

    // Loop through authenticated attributes and find
    // szOID_RSA_signingTime OID.
    for (DWORD n = 0; n < pSignerInfo->AuthAttrs.cAttr; n++)
    {
        if (lstrcmpA(szOID_RSA_signingTime,
            pSignerInfo->AuthAttrs.rgAttr[n].pszObjId) == 0)
        {
            // Decode and get FILETIME structure.
            dwData = sizeof(ft);
            fResult = CryptDecodeObject(ENCODING,
                szOID_RSA_signingTime,
                pSignerInfo->AuthAttrs.rgAttr[n].rgValue[0].pbData,
                pSignerInfo->AuthAttrs.rgAttr[n].rgValue[0].cbData,
                0,
                (PVOID)&ft,
                &dwData);
            if (!fResult)
            {
                _tprintf(_T("CryptDecodeObject failed with %x\n"),
                    GetLastError());
                break;
            }

            // Convert to local time.
            FileTimeToLocalFileTime(&ft, &lft);
            FileTimeToSystemTime(&lft, st);

            fReturn = TRUE;

            break; // Break from for loop.

        } //lstrcmp szOID_RSA_signingTime
    } // for 

    return fReturn;
}

BOOL GetTimeStampSignerInfo(PCMSG_SIGNER_INFO pSignerInfo, PCMSG_SIGNER_INFO* pCounterSignerInfo)
{
    PCCERT_CONTEXT pCertContext = NULL;
    BOOL fReturn = FALSE;
    BOOL fResult;
    DWORD dwSize;

    __try
    {
        *pCounterSignerInfo = NULL;

        // Loop through unathenticated attributes for
        // szOID_RSA_counterSign OID.
        for (DWORD n = 0; n < pSignerInfo->UnauthAttrs.cAttr; n++)
        {
            if (lstrcmpA(pSignerInfo->UnauthAttrs.rgAttr[n].pszObjId,
                szOID_RSA_counterSign) == 0)
            {
                // Get size of CMSG_SIGNER_INFO structure.
                fResult = CryptDecodeObject(ENCODING,
                    PKCS7_SIGNER_INFO,
                    pSignerInfo->UnauthAttrs.rgAttr[n].rgValue[0].pbData,
                    pSignerInfo->UnauthAttrs.rgAttr[n].rgValue[0].cbData,
                    0,
                    NULL,
                    &dwSize);
                if (!fResult)
                {
                    _tprintf(_T("CryptDecodeObject failed with %x\n"),
                        GetLastError());
                    __leave;
                }

                // Allocate memory for CMSG_SIGNER_INFO.
                *pCounterSignerInfo = (PCMSG_SIGNER_INFO)LocalAlloc(LPTR, dwSize);
                if (!*pCounterSignerInfo)
                {
                    _tprintf(_T("Unable to allocate memory for timestamp info.\n"));
                    __leave;
                }

                // Decode and get CMSG_SIGNER_INFO structure
                // for timestamp certificate.
                fResult = CryptDecodeObject(ENCODING,
                    PKCS7_SIGNER_INFO,
                    pSignerInfo->UnauthAttrs.rgAttr[n].rgValue[0].pbData,
                    pSignerInfo->UnauthAttrs.rgAttr[n].rgValue[0].cbData,
                    0,
                    (PVOID)*pCounterSignerInfo,
                    &dwSize);
                if (!fResult)
                {
                    _tprintf(_T("CryptDecodeObject failed with %x\n"),
                        GetLastError());
                    __leave;
                }

                fReturn = TRUE;

                break; // Break from for loop.
            }
        }
    }
    __finally
    {
        // Clean up.
        if (pCertContext != NULL) CertFreeCertificateContext(pCertContext);
    }

    return fReturn;
}
```