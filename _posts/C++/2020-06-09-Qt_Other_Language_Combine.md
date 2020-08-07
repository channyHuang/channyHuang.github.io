---
layout: default
title: Qt_Other_Language_Combine
categories:
- C++
tags:
- C++
---
//Description: Qt和其它语言的交叉使用笔记

//Create Date: 2020-06-09 15:02:47

//Author: channy

# Qt_Other_Language_Combine

## Qt调用c#的动态库dll

想什么呢，不能直接调用哦

```c++
    QLibrary qLib(m_sDllName);
    if (qLib.load())
    {
        Dll_TmatrixInitialize = (TYPE_DLL_TmatrixInitialize)qLib.resolve    ("TmatrixInitialize");
        if (nullptr == Dll_TmatrixInitialize)
            writeLog("Load Dll_TmatrixInitialize failed");
    }
```

load是成功的，但是里面的函数都resolve不出来哦，没有参数的也不例外。

# Qt_Source

版本: Qt 5.9.0

目录: Src

## Qt解析pdf成图片

根据文档，在linux下比较推荐popper，但是windows编译据说有很多问题

[mupdf](https://mupdf.com/docs/building.html)

Compiling on Linux
If you are compiling from source you will need several third party libraries: freetype2, jbig2dec, libjpeg, openjpeg, and zlib. These libraries are contained in the source archive. If you are using git, they are included as git submodules.

You will also need the X11 headers and libraries if you're building on Linux. These can typically be found in the xorg-dev package. Alternatively, if you only want the command line tools, you can build with HAVE_X11=no.

The new OpenGL-based viewer also needs OpenGL headers and libraries. If you're building on Linux, install the mesa-common-dev, libgl1-mesa-dev packages, and libglu1-mesa-dev packages. You'll also need several X11 development packages: xorg-dev, libxcursor-dev, libxrandr-dev, and libxinerama-dev. To skip building the OpenGL viewer, build with HAVE_GLUT=no.

To install the viewer, command line tools, libraries, and header files on your system:

make prefix=/usr/local install
To install only the command line tools, libraries, and headers invoke make like this:

make HAVE_X11=no HAVE_GLUT=no prefix=/usr/local install

## Starting Class - QObject

目录: Src/qtbase/src/corelib/kernel



[back](/)

