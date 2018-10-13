---
layout: default
---

//Author: channy

//Create Date: 2018-10-13 13:27:33

//Description: 

# Matlab_And_C_Combining_Coding

## matlab调用C

假设已有C文件.h和.cpp，以加法为例：
```c++
#ifndef ADD_H
#define ADD_H
 
#include <iostream>
using namespace std;
 
double add(double a, double b);
 
#endif
#include "add.h"
 
double add(double a, double b)
{
 return a + b;
}
```

需要在.cpp文件上加如下内容：

```c++
#include "mex.h"
 
#include "add.h"
 
double add(double a, double b)
{
 return a + b;
}

// MEX文件接口函数
 
void mexFunction(int nlhs,mxArray *plhs[], int nrhs,const mxArray *prhs[])
 
{
 
    double *a;
 
    double b, c;
 
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
 
    a = mxGetPr(plhs[0]);
 
    b = *(mxGetPr(prhs[0]));
 
    c = *(mxGetPr(prhs[1]));
 
    *a = add(b, c);
 
}

```

最后在matlab中运行 >> mex add.cpp 能够把add编译成mex文件，直接调用

解析：mexFunction四个参数的意思为：

nlhs = 1，说明调用语句左手面（lhs－left hand side）有一个变量，即a。

nrhs = 2，说明调用语句右手面（rhs－right hand side）有两个自变量，即b和c。

plhs是一个数组，其内容为指针，该指针指向数据类型mxArray。因为现在左手面只有一个变量，即该数组只有一个指针，plhs[0]指向的结果会赋值给a。

prhs和plhs类似，因为右手面有两个自变量，即该数组有两个指针，prhs[0]指向了b，prhs[1]指向了c。要注意prhs是const的指针数组，即不能改变其指向内容。

因为Matlab最基本的单元为array，无论是什么类型也好，如有double array、 cell array、 struct array……所以a,b,c都是array，b = 1.1便是一个1x1的double array。而在C语言中，Matlab的array使用mxArray类型来表示。所以就不难明白为什么plhs和prhs都是指向mxArray类型的指针数组。

在未涉及具体的计算时，output的值是未知的，是未赋值的。所以在具体的程序中，我们建立一个1x1的实double矩阵（使用 mxCreateDoubleMatrix函数，其返回指向刚建立的mxArray的指针），然后令plhs[0]指向它。接着令指针a指向plhs [0]所指向的mxArray的第一个元素（使用mxGetPr函数，返回指向mxArray的首元素的指针）。同样地，我们把prhs[0]和prhs [1]所指向的元素（即1.1和2.2）取出来赋给b和c。于是我们可以把b和c作自变量传给函数add，得出给果赋给指针a所指向的mxArray中的元素。因为a是指向plhs[0]所指向的mxArray的元素，所以最后作输出时，plhs[0]所指向的mxArray赋值给output，则 output便是已计算好的结果了。

## C调用matlab

工程目录中加入包含目录和库目录，一般在MATLAb/2014b/extern/include 和 lib/win64/microsoft中

下例中MTest.m文件如下
```matlab
function [c] = MTest(ab)
    c = ab(1) + ab(2);
end
```
main.cpp文件
```c++
#include <iostream>
using namespace std;
 
//引用Matlab头文件和库文件
#include "engine.h" 
#pragma comment(lib, "libeng.lib")
#pragma comment(lib, "libmx.lib")
#pragma comment(lib, "libmat.lib")
 
int main()
{
 double ab[2];
 ab[0] = 4.5;
 ab[1] = 2.6;
 double *c;
 
 //启动
 Engine *ep;
 if (!(ep = engOpen("\0"))) {
 fprintf(stderr, "\nCan't start Matlab Engine\n");
 return EXIT_FAILURE;
 }
 engEvalString(ep, "clear all");
 
 mxArray *a = NULL, *result = NULL;
 a = mxCreateDoubleMatrix(1, 2, mxREAL);
 result = mxCreateDoubleMatrix(1, 1, mxREAL);
 memcpy((void*)mxGetPr(a), (void*)ab, sizeof(ab));
 //执行表达式中的命令
 engPutVariable(ep, "a", a);
 
 engEvalString(ep, "cd F:/mycode/matlabTest/matlabTest");
 engEvalString(ep, "c = MTest(a)");
 result = engGetVariable(ep, "c");
 c = mxGetPr(result);
 mxDestroyArray(a);
 mxDestroyArray(result);
 
 printf("%f\n", *c);
 cout << "End..." << endl;
 //关闭
 engEvalString(ep, "close;");
 engClose(ep);
 
 return 0;
}
 
 
/*
#include <iostream>
#include <math.h>
#include "engine.h"
using namespace std;
void main()
{
 Engine *ep; //定义Matlab引擎指针。
 if (!(ep = engOpen(NULL))) //测试是否启动Matlab引擎成功。
 {
 cout << "Can't start Matlab engine!" << endl;
 exit(1);
 }
 
 //下面是将c++格式数据转换为matlab格式可用数据
 double data[4] = { 1.0, 2.0, 3.0, 4.0 };
 mxArray *Y = mxCreateDoubleMatrix(1, 4, mxREAL);
 
 memcpy(mxGetPr(Y), data, sizeof(data));
 engPutVariable(ep, "Y", Y);
 
 engEvalString(ep, "plot(Y,'o')");    //显示数据
 mxDestroyArray(Y);
 
 engEvalString(ep, "figure");        //开一个新的显示窗口
 
 //////////////////////////////////////////////////////////
 //下面是从matlab格式数据转换为c++格式可用数据
 //    mxArray *filename=NULL;
 //    const char *name="D:/Program Files/MATLAB/R2010b/bin/win32/lena.jpg";
 //    filename=mxCreateString(name);
 //    engPutVariable(ep,"filename",filename);
 
 engEvalString(ep, "X=imread('F:/mycode/meso/data/pic/0001.jpg');");    //在engine中读取一张图片
 engEvalString(ep, "imshow(X)");        //显示图片
 mxArray *X = engGetVariable(ep, "X");    //从engine获得真正的数组X
 
 int ndims = mxGetNumberOfDimensions(X);    //获得这个数组的维数
 cout << ndims << endl;
 
 int *dims = new int[ndims];
 memcpy(dims, mxGetDimensions(X), ndims*sizeof(int));    //获得数组每一维的大小
 for (int i = 0; i<ndims; i++)
 {
 cout << dims[i] << "  ";
 }
 cout << endl;
 
//	double *p=(double*)mxGetData(X);    //指向数组X的指针以便能访问数组元素,图像数据量太大，这里就不显示了
//	for (int i=0;i<dims[0];i++) {
//		for (int j=0;j<dims[1];j++)	{
//			cout<<p[i*dims[1]+j]<<"  ";
//		}
//		cout<<endl;
//	}
 
 delete[] dims;
 mxDestroyArray(X);
 
 cout << "good job." << endl;
 cin.get();
 engClose(ep); //关闭Matlab引擎。
 
}
*/
```


未证：

mcc -B csharedlib:函数名 文件名

生成一组文件，其中的.dll, .h, .lib

需要调用的.cpp中加入：头文件，库文件

同样用mxArray和memcpy

## matlab调用C带cuda

假设已有C文件和CU文件，以向量加法为例：
```c++
#ifndef __ADDVECTORS_H__
#define __ADDVECTORS_H__
 
extern void addVectors(float* A, float* B,float* C, int size);
 
#endif // __ADDVECTORS_H__
# include "AddVectors.h"
//# include <mex.h>
 
__global__ void addVectorsMask(float* A, float* B, float* C,int size)
{
        int i=blockIdx.x;
        if(i>=size)
        return;
 
        C[i]=A[i]+B[i];
}
 
 
void addVectors(float* A, float* B, float* C,int size)
{
        float *devPtrA=0;
        float *devPtrB=0;
        float *devPtrC=0;
 
 
        cudaMalloc(&devPtrA,sizeof(float)*size);
        cudaMalloc(&devPtrB,sizeof(float)*size);
        cudaMalloc(&devPtrC,sizeof(float)*size);
 
        cudaMemcpy(devPtrA,A,sizeof(float)*size,cudaMemcpyHostToDevice);
        cudaMemcpy(devPtrB,B,sizeof(float)*size,cudaMemcpyHostToDevice);
 
 
        addVectorsMask<<<size,1>>>(devPtrA,devPtrB,devPtrC,size);
 
        cudaMemcpy(C,devPtrC,sizeof(float)*size,cudaMemcpyDeviceToHost);
 
        cudaFree(devPtrA);
        cudaFree(devPtrB);
        cudaFree(devPtrC);
 
}
```

如同调用C类似，mexFunction增加在CPP文件中
```c++
# include "mex.h"
# include "AddVectors.h"
 
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
        if(nrhs !=2)
        mexErrMsgTxt("Invaid number of input arguments");
        
        if(nlhs !=1)
        mexErrMsgTxt("Invaid number of outputs ");
 
        if(!mxIsSingle(prhs[0])&&!mxIsSingle(prhs[1]))
        mexErrMsgTxt("Input vector data type must be single");
 
        int numRowsA=(int)mxGetM(prhs[0]);
        int numColsA=(int)mxGetN(prhs[0]);
        int numRowsB=(int)mxGetM(prhs[1]);
        int numColsB=(int)mxGetN(prhs[1]);
 
        if(numRowsA !=numRowsB || numColsA !=numColsB)
                mexErrMsgTxt("Invalid size. The size of two vectors must be same");
        
        int minSize=(numRowsA<numColsA)?numRowsA:numColsA;
        int maxSize=(numRowsA>numColsA)?numRowsA:numColsA;
 
        if(minSize !=1)
                mexErrMsgTxt("Invalid size. The vector must be one dimentional");
 
        float* A=(float*)mxGetData(prhs[0]);
        float* B=(float*)mxGetData(prhs[1]);
 
        plhs[0]=mxCreateNumericMatrix(numRowsA,numColsB,mxSINGLE_CLASS,mxREAL);
        float* C=(float*)mxGetData(plhs[0]);
 
        addVectors(A,B,C,maxSize);
 
 
}
```

在matlab下输入以下命令生成可调用的中间文件（.obj, .mexw64）
```matlab
system('nvcc -c AddVectors.cu --compiler-options -fPIC');
 
mex AddVectorsCuda.cpp AddVectors.obj -lcudart -L'C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v6.5/lib/x64'
```

调用测试：
```matlab
a = [3,4,5];
b = [2,7,9];
c = AddVectorsCuda(single(a), single(b));
```

[back](./)

