---
layout: default
title: Using_Cuda_In_Qt_Linux
categories:
- Linux
tags:
- Linux
- Qt
- Cuda
---
//Description: 一时心血来潮想学cuda了，Ubuntu下结合Qt，网上的教程真的。。。错误有点多～

//Create Date: 2019-08-15 14:23:24

//Author: 代码是别人的

# Using_Cuda_In_Qt_Linux

平台：Ubuntu 18.04, Qt 5.7

对Cuda的理解参考了[CUDA编程入门极简教程](https://zhuanlan.zhihu.com/p/34587739)

## Cuda安装

下载的离线安装文件.run，运行安装，然后发现多选框中打叉的是选中将要安装的，空的是没有选中不会安装的。。。

安装完成后设置环境变量，make，运行sample，一切正常

## 修改Qt的pro文件，一个简单的Qt+Cuda程序跑起来

```c++
// main.cpp

#include <QtCore/QCoreApplication>

extern "C"
void runCudaPart();

int main(int argc, char *argv[])
{
    runCudaPart();
	return 0;
}
```

```c++
//kernel.cu
// CUDA-C includes
#include <cuda.h>
 
#include <cuda_runtime.h>
 
    #include <stdio.h>
 
    extern "C"
//Adds two arrays
    void runCudaPart();
 
 
__global__ void addAry( int * ary1, int * ary2 )
{
    int indx = threadIdx.x;
    ary1[ indx ] += ary2[ indx ];
}
 
 
// Main cuda function
 
void runCudaPart() {
 
    int ary1[32];
    int ary2[32];
    int res[32];
 
    for( int i=0 ; i<32 ; i++ )
    {
        ary1[i] = i;
        ary2[i] = 2*i;
        res[i]=0;
    }
 
    int * d_ary1, *d_ary2;
    cudaMalloc((void**)&d_ary1, 32*sizeof(int));
    cudaMalloc((void**)&d_ary2, 32*sizeof(int));
 
 
    cudaMemcpy((void*)d_ary1, (void*)ary1, 32*sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy((void*)d_ary2, (void*)ary2, 32*sizeof(int), cudaMemcpyHostToDevice);
 
 
    addAry<<<1,32>>>(d_ary1,d_ary2);
 
    cudaMemcpy((void*)res, (void*)d_ary1, 32*sizeof(int), cudaMemcpyDeviceToHost);
    for( int i=0 ; i<32 ; i++ )
        printf( "result[%d] = %d\n", i, res[i]);
 
 
    cudaFree(d_ary1);
    cudaFree(d_ary2);
}
```

```c++

QT       += core

QT       -= gui

TARGET = cudaQTS
CONFIG   += console
CONFIG   -= app_bundle

TEMPLATE = app


SOURCES += main.cpp


# This makes the .cu files appear in your project
OTHER_FILES +=  ./kernel.cu

# CUDA settings <-- may change depending on your system
CUDA_SOURCES += ./kernel.cu
CUDA_SDK = "/usr/local/cuda-10.1/"   # Path to cuda SDK install
CUDA_DIR = "/usr/local/cuda-10.1/"            # Path to cuda toolkit install

# DO NOT EDIT BEYOND THIS UNLESS YOU KNOW WHAT YOU ARE DOING....

SYSTEM_NAME = ubuntu         # Depending on your system either 'Win32', 'x64', or 'Win64'
SYSTEM_TYPE = 64            # '32' or '64', depending on your system
CUDA_ARCH = sm_50           # Type of CUDA architecture, for example 'compute_10', 'compute_11', 'sm_10'
NVCC_OPTIONS = --use_fast_math


# include paths
INCLUDEPATH += $$CUDA_DIR/include

# library directories
QMAKE_LIBDIR += $$CUDA_DIR/lib64/

CUDA_OBJECTS_DIR = ./


# Add the necessary libraries
CUDA_LIBS = -lcuda -lcudart

# The following makes sure all path names (which often include spaces) are put between quotation marks
CUDA_INC = $$join(INCLUDEPATH,'" -I"','-I"','"')
#LIBS += $$join(CUDA_LIBS,'.so ', '', '.so')
LIBS += $$CUDA_LIBS

# Configuration of the Cuda compiler
CONFIG(debug, debug|release) {
    # Debug mode
    cuda_d.input = CUDA_SOURCES
    cuda_d.output = $$CUDA_OBJECTS_DIR/${QMAKE_FILE_BASE}_cuda.o
    cuda_d.commands = $$CUDA_DIR/bin/nvcc -D_DEBUG $$NVCC_OPTIONS $$CUDA_INC $$NVCC_LIBS --machine $$SYSTEM_TYPE -arch=$$CUDA_ARCH -c -o ${QMAKE_FILE_OUT} ${QMAKE_FILE_NAME}
    cuda_d.dependency_type = TYPE_C
    QMAKE_EXTRA_COMPILERS += cuda_d
}
else {
    # Release mode
    cuda.input = CUDA_SOURCES
    cuda.output = $$CUDA_OBJECTS_DIR/${QMAKE_FILE_BASE}_cuda.o
    cuda.commands = $$CUDA_DIR/bin/nvcc $$NVCC_OPTIONS $$CUDA_INC $$NVCC_LIBS --machine $$SYSTEM_TYPE -arch=$$CUDA_ARCH -c -o ${QMAKE_FILE_OUT} ${QMAKE_FILE_NAME}
    cuda.dependency_type = TYPE_C
    QMAKE_EXTRA_COMPILERS += cuda
}
```

至少能够跑起来了，后续就可以认真地学习Cuda而不用费心编译问题或是makefile的编写问题了。

[back](./)

