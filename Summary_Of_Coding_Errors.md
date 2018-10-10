---
layout: default
---

//Author: channy

//Create Date: 2018-10-10 11:35:49

//Description: VS 错误和其它错误总结

# Summary_Of_Coding_Errors
***************************************************************************
QString -> std::string 
(x) QString.toLocal8bit()
(x) QString.toStdString()
(?) QString.toUtf8()
(?) QString.toLocal8Bit().constData()
***************************************************************************
error 在注释中遇到意外的文件结束

文件格式不对，尝试改为UTF-8

***************************************************************************

error C4996 解决方法：

1：使用安全的函数替换老的函数

2：屏蔽警告信息

1.#pragma warning(disable:4996)

2.预处理器定义，增加_CRT_SECURE_NO_DEPRECATE
***************************************************************************
min max不是std的成员

加入#include<algorithm>

***************************************************************************

1>------ 已启动生成: 项目: 20130925, 配置: Debug Win32 ------
1>  stdafx.cpp
 1>d:\code\20130925\20130925\stdafx.cpp(18): error C4996: 'fopen': This function or variable may be unsafe. Consider using fopen_s instead. To disable deprecation, use _CRT_SECURE_NO_WARNINGS. See online help for details.
 1>          d:\vs2012\vc\include\stdio.h(218) : 参见“fopen”的声明
1>  20130925.cpp
 1>  正在生成代码...
 ========== 生成: 成功 0 个，失败 1 个，最新 0 个，跳过 0 个==========
 
解决方案，项目 ->属性 -> c/c++ -> 预处理器 -> 点击预处理器定义，编辑，加入_CRT_SECURE_NO_WARNINGS，即可。
 
***************************************************************************
 
经常有些原因需要使用Qt静态链接版本，查了些资料，自己一直没编译过去，于是从
1. 安装VS2012Qt5插件。
2. 编译时会报错"Failed to load platform plugin windows"。
此时，链接下面的库：
opengl32.lib
Qt5PlatformSupport.lib
qwindows.lib
并增加下面的代码：
#include <QtPlugin>
Q_IMPORT_PLUGIN (QWindowsIntegrationPlugin);
可能还需要添加的库：
Ws2_32.lib
Imm32.lib
Winmm.lib
Libcmt.lib
***************************************************************************
 
无法解析的外部符号QMetaObject
无法解析的外部符号 WSAAsyncSelect
 
在cpp文件末加上#include “moc_*.cpp”
 
***************************************************************************
 
QWT无法解析的外部符号"public: static struct QMetaObject const QwtPlot::staticMetaObject"
 
配置属性—>C/C++-->预处理器加上QWT_DLL
 
***************************************************************************
 
lib之间有冲突。需要删除导入的一些libs。 
 
版 本
	
类 型
	
使用的library
	
被忽略的library
R Release
	
单线程
	
libc.lib
	
libcmt.lib, msvcrt.lib, libcd.lib, libcmtd.lib, msvcrtd.lib
多线程
	
libcmt.lib
	
libc.lib, msvcrt.lib, libcd.lib, libcmtd.lib, msvcrtd.lib
使用DLL的多线程
	
msvcrt.lib
	
libc.lib, libcmt.lib, libcd.lib, libcmtd.lib, msvcrtd.lib
D Debug
	
单线程
	
libcd.lib
	
libc.lib, libcmt.lib, msvcrt.lib, libcmtd.lib, msvcrtd.lib
多线程
	
libcmtd.lib
	
libc.lib, libcmt.lib, msvcrt.lib, libcmtd.lib, msvcrtd.lib
使用DLL的多线程
	
msvcrtd.lib
	
libc.lib, libcmt.lib, msvcrt.lib, libcd.lib, libcmtd.lib
例如编译Release版本的单线程的工程，在linker的命令行加入如下的参数： /NODEFAULTLIB:libcmt.lib /NODEFAULTLIB:msvcrt.lib /NODEFAULTLIB:libcd.lib /NODEFAULTLIB:libcmtd.lib /NODEFAULTLIB:msvcrtd.lib
解决办法：
在CUDA编译选项里加入/MTd 或  /MT
Project Settings:  
在有"LIBCMT"冲突错误存在，在“配置属性-->链接器-->输入-->忽略特定库”中把libcmt.lib添加进去或者在“配置属性-->链接器-->命令运”的“附加选项”添加上/NODEFAULTLIB:libcmt.lib
libcmtd 这个库有时候不能忽略，忽略后会有不能解析的外部符号错误
其实有个方便的方法 链接时加入参数 /FORCE:MULTIPLE
 
***************************************************************************
 
Qt5Cored.lib(qeventdispatcher_win.obj) : error LNK2019: unresolved external symbol_WSAAsyncSelect@16 referenced in function "public: void __thiscall            QEventDispatcherWin32Private::doWsaAsyncSelect(int)" (?doWsaAsyncSelect@QEventDispatcherWin32Private@@QAEXH@Z)
      这个链接容易解决，属性页-->Link-->input  Additional Dependencies 加入Ws2_32.lib, 然后运行
 
***************************************************************************
 
错误：fatal error C1189: #error :  The C++ Standard Library forbids macroizing keywords. Enable warning C4005 to find the forbidden macro. 
 
解决方法：add "_XKEYCHECK_H" in Preprocessor Definitions
 
***************************************************************************
运行错误：the application was unable to start correctly. Click OK to close the application.
库或dll有32bit和64bit混合的，改成一致
也有可以缺失dll,可以尝试把用到的库的所有dll拷过去测试
 ***************************************************************************
错误：error LNK2026 模块对于SAFESEH映像是不安全的。
把/SAFESEH:NO加到链接器-命令行-其他选项里
 ***************************************************************************
opencv和cuda混合编程用到cv中的gpu时，链接错误
自己编译OpenCV得到的gpu的lib替代二进制安装的lib
运行中错误
OpenCV Error: Gpu API call (invalid device function) in call
查看cuda的capability Major，修改cmake的-gencode后面的参数
set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS}; -gencode arch=compute_30,code=sm_30; -gencode arch=compute_35,code=sm_35; -gencode arch=compute_50,code=sm_50; --use_fast_math ;--restrict; )
 
***************************************************************************
fatal error C1189: #error :  The C++ Standard Library forbids macroizing keywords. Enable warning C4005 to find the forbidden macro.  
预处理器里添加 _XKEYCHECK_H
cmake下添加 add_definitions(-D_XKEYCHECK_H)
***************************************************************************
snprintf不支持：
https://www.ijs.si/software/snprintf/

***************************************************************************
编译器错误 C1128
Visual C++ 2005 之前的版本中所提供的链接器不能读取使用 /bigobj 生成的 .obj 文件。
在 Visual Studio 开发环境中设置此编译器选项

    打开项目的“属性页”对话框。 有关详细信息，请参见如何：打开项目属性页。
    单击“C/C++”文件夹。
    单击“命令行”属性页。
    在“附加选项”框中键入编译器选项。
	
[back](./)

