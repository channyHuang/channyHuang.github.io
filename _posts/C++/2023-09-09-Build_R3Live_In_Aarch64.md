---
layout: default
title: OSG - OpenSceneGraph And Shader
categories:
- C++
tags:
- C++
---
//Description: 在Aarch64的cpu上编译运行R3Live。

//Create Date: 2023-09-09 10:34:19

//Author: channy

# build R3Live in Aarch64 Environment

## My Environment
```
nvidia@ubuntu:~$ uname -a
Linux ubuntu 5.10.104-tegra #1 SMP PREEMPT Wed Aug 10 20:17:07 PDT 2022 aarch64 aarch64 aarch64 GNU/Linux
```

Arm to build r3live on Orin, containing ros-noetic, so no need to install ros again.

目标是在Orin上编译运行R3Live，orin自带了ros-noetic，所以就不用再手动安装一遍了。

## Update cmake version
Download cmake install package ".tar.gz" in [CMake](https://cmake.org/files) 

对CMake有最低版本要求，一般Orin是简化了的Ubuntu，需要升级CMake。
```
tar -xvzf cmake-xxx.tar.gz
cd cmake-xxx
make
sudo make install
sudo vim ~/.bashrc
// add the following two lines 
export PATH=$PATH:/opt/cmake-install/bin
export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:/opt/cmake-install
// save and run
source /.bashrc
```

## Download Source Code
1. Clone R3Live Reposity  
源码下载
```
// in my project path "/xxx/"
mkdir r3live
cd r3live
mkdir src
cd src
git clone https://github.com/hku-mars/r3live.git
``` 
And then open the README.md file, in case build failed and search reason later.

2. Install CGAL and pcl_viewer  
安装CGAL和PCL
```
sudo apt-get install libcgal-dev pcl-tools
```
My major is reconstruction, so these two are necessary.

因为我的目标是重建，所以这两个库是必要的，如果只关注SLAM这两个库可选。

3. Clone Livox-SDK And Build And Install  
按照Livox-SDK的README步骤编译安装，一切顺利，没有报错。
```
// in my project path "/xxx/"
git clone https://github.com/Livox-SDK/Livox-SDK.git Livox-SDK-master
cd Livox-SDK-master
cd build && cmake ..
make
sudo make install
```

4. Clone livox_ros_driver Reposity And Build  
Livox-ros-driver同样，用catkin编译安装。
```
// in my project path "/xxx/"
mkdir livox_driver
cd livox_driver
mkdir src
cd src
git clone https://github.com/Livox-SDK/livox_ros_driver.git 

cd ../
catkin_make
source ./devel/setup.sh
```

Untill now everything goes well in my environment

5. Install Opencv
```
sudo apt-get install libopencv-dev
```

Actually maybe this step is not necessary because after I install it, I found that there are two version of opencv, currently installed 4.5.4 and 4.2.0 in catkin...  
其实catkin自带了有opencv，应该是不需要再安装Opencv的了。一开始不知道又安装了一个高版本，后续会有两个版本冲突的Warning.

## Modify Source Code Witch Not Be Supported In Aarch64
因为源R3Live代码是不支持ARM结构的CPU的，ARM不支持MSSE，而代码里面用到了MSSE2和MSSE3，以及其它一些函数。所以接下来需要修改源码。
1. modify CMakeLists.txt to solve opencv conflict  
先修改CMake文件CMakeLists.txt，解决Opencv版本冲突，如果没有安装更高版本则不用修改。
```
// specify cmake version
find_package(OpenCV 4.2.0 REQUIRED)
```

If not work, remove one version
```
// CMakeLists.txt, add before every target_link_libraries
file(GLOB_RECURSE OLD_OPENCV "/usr/lib/aarch64-linux-gnu/libopencv*")
list(REMOVE_ITEM catkin_LIBRARIES ${OLD_OPENCV})
```

2. Disable msse2/msse3  
还是CMake文件，编译不使用msse2和msse3，因为ARM的cpu很多都不支持。
```
#set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -std=c++14 -O3 -lboost_system -msse2 -msse3 -pthread -Wenum-compare") # -Wall
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -std=c++14 -O3 -lboost_system -march=native -pthread -Wenum-compare") # -Wall
```

Because arm cpu does not support msse...

3. Annotate All CPUID function  
注释掉所有的CPUID函数，这个函数只在输出信息中使用到，如果已经知道自己的CPU情况，可以先注释掉该函数把代码跑起来再说。
```c++
#ifdef _MSC_VER
#include <intrin.h>
inline void CPUID(int CPUInfo[4], int level) {
	__cpuid(CPUInfo, level);
}
#else
// #include <cpuid.h>
 inline void CPUID(int CPUInfo[4], int level) {
// 	unsigned* p((unsigned*)CPUInfo);
// 	__get_cpuid((unsigned&)level, p+0, p+1, p+2, p+3);
 }
#endif
```

```c++
// tools_logger.hpp
inline CPUINFO GetCPUInfo_()
{
    CPUINFO info;

    // set all values to 0 (false)
    memset( &info, 0, sizeof( CPUINFO ) );
/*
    int CPUInfo[ 4 ];

    // CPUID with an InfoType argument of 0 returns the number of
    // valid Ids in CPUInfo[0] and the CPU identification string in
    // the other three array elements. The CPU identification string is
    // not in linear order. The code below arranges the information
    // in a human readable form.
    CPUID( CPUInfo, 0 );
    *( ( int * ) info.vendor ) = CPUInfo[ 1 ];
    *( ( int * ) ( info.vendor + 4 ) ) = CPUInfo[ 3 ];
    *( ( int * ) ( info.vendor + 8 ) ) = CPUInfo[ 2 ];

    // Interpret CPU feature information.
    CPUID( CPUInfo, 1 );
    info.bMMX = ( CPUInfo[ 3 ] & 0x800000 ) != 0;            // test bit 23 for MMX
    info.bSSE = ( CPUInfo[ 3 ] & 0x2000000 ) != 0;           // test bit 25 for SSE
    info.bSSE2 = ( CPUInfo[ 3 ] & 0x4000000 ) != 0;          // test bit 26 for SSE2
    info.bSSE3 = ( CPUInfo[ 2 ] & 0x1 ) != 0;                // test bit 0 for SSE3
    info.bSSE41 = ( CPUInfo[ 2 ] & 0x80000 ) != 0;           // test bit 19 for SSE4.1
    info.bSSE42 = ( CPUInfo[ 2 ] & 0x100000 ) != 0;          // test bit 20 for SSE4.2
    info.bAVX = ( CPUInfo[ 2 ] & 0x18000000 ) == 0x18000000; // test bits 28,27 for AVX
    info.bFMA = ( CPUInfo[ 2 ] & 0x18001000 ) == 0x18001000; // test bits 28,27,12 for FMA

    // EAX=0x80000000 => CPUID returns extended features
    CPUID( CPUInfo, 0x80000000 );
    const unsigned nExIds = CPUInfo[ 0 ];
    info.bEXT = ( nExIds >= 0x80000000 );

    // must be greater than 0x80000004 to support CPU name
    if ( nExIds > 0x80000004 )
    {
        size_t idx( 0 );
        CPUID( CPUInfo, 0x80000002 ); // CPUID returns CPU name part1
        while ( ( ( uint8_t * ) CPUInfo )[ idx ] == ' ' )
            ++idx;
        memcpy( info.name, ( uint8_t * ) CPUInfo + idx, sizeof( CPUInfo ) - idx );
        idx = sizeof( CPUInfo ) - idx;

        CPUID( CPUInfo, 0x80000003 ); // CPUID returns CPU name part2
        memcpy( info.name + idx, CPUInfo, sizeof( CPUInfo ) );
        idx += 16;

        CPUID( CPUInfo, 0x80000004 ); // CPUID returns CPU name part3
        memcpy( info.name + idx, CPUInfo, sizeof( CPUInfo ) );
    }

    if ( ( strncmp( info.vendor, "AuthenticAMD", 12 ) == 0 ) && info.bEXT )
    {                                                       // AMD
        CPUID( CPUInfo, 0x80000001 );                       // CPUID will copy ext. feat. bits to EDX and cpu type to EAX
        info.b3DNOWEX = ( CPUInfo[ 3 ] & 0x40000000 ) != 0; // indicates AMD extended 3DNow+!
        info.bMMXEX = ( CPUInfo[ 3 ] & 0x400000 ) != 0;     // indicates AMD extended MMX
    }
*/
    return info;
}
```

This function only used in output message, not necessary for final result. And arm do not contains 'cpuid.h' file.

4. Replace msse implimentation   
整个代码里用到msse的目前看只有光流跟踪这一块，即lkpyramid.cpp文件里面的calculate_LK_optical_flow函数。很奇怪头文件里这个函数定义返回的是int，实现文件里又变成了void......可以直接用Opencv的函数替代原来的实现，也可以打开CV_SSE2宏判断。
```c++
// calculate_LK_optical_flow function in lkpyramid.cpp
inline int calculate_LK_optical_flow(const cv::Range &range, const Mat *prevImg, const Mat *prevDeriv, const Mat *nextImg,
                                      const Point2f *prevPts, Point2f *nextPts,
                                      uchar *status, float *err,
                                      Size winSize, TermCriteria criteria,
                                      int level, int maxLevel, int flags, float minEigThreshold)
{
    Point2f halfWin((winSize.width - 1) * 0.5f, (winSize.height - 1) * 0.5f);
    const Mat &I = *prevImg;
    const Mat &J = *nextImg;
    const Mat &derivI = *prevDeriv;

    std::vector<Point2f> Ipts, Jpts;
    for (int ptidx = range.start; ptidx < range.end; ptidx++) {
        Ipts.push_back(prevPts[ptidx]);
        Jpts.push_back(nextPts[ptidx]);
    }
    std::vector<uchar> Ostatus;
    std::vector<float> Oerr;
    cv::calcOpticalFlowPyrLK(I, J, Ipts, Jpts, Ostatus, Oerr, winSize, maxLevel, criteria);
    for (int ptidx = range.start; ptidx < range.end; ptidx++) {
        if (status)
            status[ptidx] = Ostatus[ptidx];
        if (err)
            err[ptidx] = Oerr[ptidx];
    }
    return 0;
}
```

Only one function "calculate_LK_optical_flow" in "lkpyramid.cpp" has msse implement. Replace it with origin opencv function. Or just annotate codes using sse

```c++
inline int calculate_LK_optical_flow(const cv::Range &range, const Mat *prevImg, const Mat *prevDeriv, const Mat *nextImg,
                                      const Point2f *prevPts, Point2f *nextPts,
                                      uchar *status, float *err,
                                      Size winSize, TermCriteria criteria,
                                      int level, int maxLevel, int flags, float minEigThreshold)
{
    Point2f halfWin((winSize.width - 1) * 0.5f, (winSize.height - 1) * 0.5f);
    const Mat &I = *prevImg;
    const Mat &J = *nextImg;
    const Mat &derivI = *prevDeriv;

    int j, cn = I.channels(), cn2 = cn * 2;
    cv::AutoBuffer<deriv_type> _buf(winSize.area() * (cn + cn2));
    int derivDepth = DataType<deriv_type>::depth;

    Mat IWinBuf(winSize, CV_MAKETYPE(derivDepth, cn), (deriv_type *)_buf);
    Mat derivIWinBuf(winSize, CV_MAKETYPE(derivDepth, cn2), (deriv_type *)_buf + winSize.area() * cn);

    for (int ptidx = range.start; ptidx < range.end; ptidx++)
    {
        
        Point2f prevPt = prevPts[ptidx] * (float)(1. / (1 << level));
        Point2f nextPt;
        if (level == maxLevel)
        {
            if (flags & OPTFLOW_USE_INITIAL_FLOW)
                nextPt = nextPts[ptidx] * (float)(1. / (1 << level));
            else
                nextPt = prevPt;
        }
        else
            nextPt = nextPts[ptidx] * 2.f;
        nextPts[ptidx] = nextPt;
        
        Point2i iprevPt, inextPt;
        prevPt -= halfWin;
        iprevPt.x = cvFloor(prevPt.x);
        iprevPt.y = cvFloor(prevPt.y);

        if (iprevPt.x < -winSize.width || iprevPt.x >= derivI.cols ||
            iprevPt.y < -winSize.height || iprevPt.y >= derivI.rows)
        {
            if (level == 0)
            {
                if (status)
                    status[ptidx] = false;
                if (err)
                    err[ptidx] = 0;
            }
            continue;
        }

        float a = prevPt.x - iprevPt.x;
        float b = prevPt.y - iprevPt.y;
        const int W_BITS = 14, W_BITS1 = 14;
        const float FLT_SCALE = 1.f / (1 << 20);
        int iw00 = cvRound((1.f - a) * (1.f - b) * (1 << W_BITS));
        int iw01 = cvRound(a * (1.f - b) * (1 << W_BITS));
        int iw10 = cvRound((1.f - a) * b * (1 << W_BITS));
        int iw11 = (1 << W_BITS) - iw00 - iw01 - iw10;

        int dstep = (int)(derivI.step / derivI.elemSize1());
        int stepI = (int)(I.step / I.elemSize1());
        int stepJ = (int)(J.step / J.elemSize1());
        acctype iA11 = 0, iA12 = 0, iA22 = 0;
        float A11, A12, A22;

#if CV_SSE2
        __m128i qw0 = _mm_set1_epi32(iw00 + (iw01 << 16));
        __m128i qw1 = _mm_set1_epi32(iw10 + (iw11 << 16));
        __m128i z = _mm_setzero_si128();
        __m128i qdelta_d = _mm_set1_epi32(1 << (W_BITS1 - 1));
        __m128i qdelta = _mm_set1_epi32(1 << (W_BITS1 - 5 - 1));
        __m128 qA11 = _mm_setzero_ps(), qA12 = _mm_setzero_ps(), qA22 = _mm_setzero_ps();
#endif

        // extract the patch from the first image, compute covariation matrix of derivatives
        int x, y;
        for (y = 0; y < winSize.height; y++)
        {
            const uchar *src = I.ptr() + (y + iprevPt.y) * stepI + iprevPt.x * cn;
            const deriv_type *dsrc = derivI.ptr<deriv_type>() + (y + iprevPt.y) * dstep + iprevPt.x * cn2;

            deriv_type *Iptr = IWinBuf.ptr<deriv_type>(y);
            deriv_type *dIptr = derivIWinBuf.ptr<deriv_type>(y);

            x = 0;

#if CV_SSE2
            for (; x <= winSize.width * cn - 4; x += 4, dsrc += 4 * 2, dIptr += 4 * 2)
            {
                __m128i v00, v01, v10, v11, t0, t1;

                v00 = _mm_unpacklo_epi8(_mm_cvtsi32_si128(*(const int *)(src + x)), z);
                v01 = _mm_unpacklo_epi8(_mm_cvtsi32_si128(*(const int *)(src + x + cn)), z);
                v10 = _mm_unpacklo_epi8(_mm_cvtsi32_si128(*(const int *)(src + x + stepI)), z);
                v11 = _mm_unpacklo_epi8(_mm_cvtsi32_si128(*(const int *)(src + x + stepI + cn)), z);

                t0 = _mm_add_epi32(_mm_madd_epi16(_mm_unpacklo_epi16(v00, v01), qw0),
                                   _mm_madd_epi16(_mm_unpacklo_epi16(v10, v11), qw1));
                t0 = _mm_srai_epi32(_mm_add_epi32(t0, qdelta), W_BITS1 - 5);
                _mm_storel_epi64((__m128i *)(Iptr + x), _mm_packs_epi32(t0, t0));

                v00 = _mm_loadu_si128((const __m128i *)(dsrc));
                v01 = _mm_loadu_si128((const __m128i *)(dsrc + cn2));
                v10 = _mm_loadu_si128((const __m128i *)(dsrc + dstep));
                v11 = _mm_loadu_si128((const __m128i *)(dsrc + dstep + cn2));

                t0 = _mm_add_epi32(_mm_madd_epi16(_mm_unpacklo_epi16(v00, v01), qw0),
                                   _mm_madd_epi16(_mm_unpacklo_epi16(v10, v11), qw1));
                t1 = _mm_add_epi32(_mm_madd_epi16(_mm_unpackhi_epi16(v00, v01), qw0),
                                   _mm_madd_epi16(_mm_unpackhi_epi16(v10, v11), qw1));
                t0 = _mm_srai_epi32(_mm_add_epi32(t0, qdelta_d), W_BITS1);
                t1 = _mm_srai_epi32(_mm_add_epi32(t1, qdelta_d), W_BITS1);
                v00 = _mm_packs_epi32(t0, t1); // Ix0 Iy0 Ix1 Iy1 ...

                _mm_storeu_si128((__m128i *)dIptr, v00);
                t0 = _mm_srai_epi32(v00, 16);                     // Iy0 Iy1 Iy2 Iy3
                t1 = _mm_srai_epi32(_mm_slli_epi32(v00, 16), 16); // Ix0 Ix1 Ix2 Ix3

                __m128 fy = _mm_cvtepi32_ps(t0);
                __m128 fx = _mm_cvtepi32_ps(t1);

                qA22 = _mm_add_ps(qA22, _mm_mul_ps(fy, fy));
                qA12 = _mm_add_ps(qA12, _mm_mul_ps(fx, fy));
                qA11 = _mm_add_ps(qA11, _mm_mul_ps(fx, fx));
            }
#endif
            for (; x < winSize.width * cn; x++, dsrc += 2, dIptr += 2)
            {
                int ival = CV_DESCALE(src[x] * iw00 + src[x + cn] * iw01 +
                                          src[x + stepI] * iw10 + src[x + stepI + cn] * iw11,
                                      W_BITS1 - 5);
                int ixval = CV_DESCALE(dsrc[0] * iw00 + dsrc[cn2] * iw01 +
                                           dsrc[dstep] * iw10 + dsrc[dstep + cn2] * iw11,
                                       W_BITS1);
                int iyval = CV_DESCALE(dsrc[1] * iw00 + dsrc[cn2 + 1] * iw01 + dsrc[dstep + 1] * iw10 +
                                           dsrc[dstep + cn2 + 1] * iw11,
                                       W_BITS1);

                Iptr[x] = (short)ival;
                dIptr[0] = (short)ixval;
                dIptr[1] = (short)iyval;

                iA11 += (itemtype)(ixval * ixval);
                iA12 += (itemtype)(ixval * iyval);
                iA22 += (itemtype)(iyval * iyval);
            }
        }

#if CV_SSE2
        float CV_DECL_ALIGNED(16) A11buf[4], A12buf[4], A22buf[4];
        _mm_store_ps(A11buf, qA11);
        _mm_store_ps(A12buf, qA12);
        _mm_store_ps(A22buf, qA22);
        iA11 += A11buf[0] + A11buf[1] + A11buf[2] + A11buf[3];
        iA12 += A12buf[0] + A12buf[1] + A12buf[2] + A12buf[3];
        iA22 += A22buf[0] + A22buf[1] + A22buf[2] + A22buf[3];
#endif

        A11 = iA11 * FLT_SCALE;
        A12 = iA12 * FLT_SCALE;
        A22 = iA22 * FLT_SCALE;

        float D = A11 * A22 - A12 * A12;
        float minEig = (A22 + A11 - std::sqrt((A11 - A22) * (A11 - A22) + 4.f * A12 * A12)) / (2 * winSize.width * winSize.height);

        if (err && (flags & OPTFLOW_LK_GET_MIN_EIGENVALS) != 0)
            err[ptidx] = (float)minEig;

        if (minEig < minEigThreshold || D < FLT_EPSILON)
        {
            if (level == 0 && status)
                status[ptidx] = false;
            continue;
        }

        D = 1.f / D;

        nextPt -= halfWin;
        Point2f prevDelta;

        for (j = 0; j < criteria.maxCount; j++)
        {
            inextPt.x = cvFloor(nextPt.x);
            inextPt.y = cvFloor(nextPt.y);

            if (inextPt.x < -winSize.width || inextPt.x >= J.cols ||
                inextPt.y < -winSize.height || inextPt.y >= J.rows)
            {
                if (level == 0 && status)
                    status[ptidx] = false;
                break;
            }

            a = nextPt.x - inextPt.x;
            b = nextPt.y - inextPt.y;
            iw00 = cvRound((1.f - a) * (1.f - b) * (1 << W_BITS));
            iw01 = cvRound(a * (1.f - b) * (1 << W_BITS));
            iw10 = cvRound((1.f - a) * b * (1 << W_BITS));
            iw11 = (1 << W_BITS) - iw00 - iw01 - iw10;
            acctype ib1 = 0, ib2 = 0;
            float b1, b2;
 #if CV_SSE2
            qw0 = _mm_set1_epi32(iw00 + (iw01 << 16));
            qw1 = _mm_set1_epi32(iw10 + (iw11 << 16));
            __m128 qb0 = _mm_setzero_ps(), qb1 = _mm_setzero_ps();
 #endif

            for (y = 0; y < winSize.height; y++)
            {
                const uchar *Jptr = J.ptr() + (y + inextPt.y) * stepJ + inextPt.x * cn;
                const deriv_type *Iptr = IWinBuf.ptr<deriv_type>(y);
                const deriv_type *dIptr = derivIWinBuf.ptr<deriv_type>(y);
                x = 0;
#if CV_SSE2
                for (; x <= winSize.width * cn - 8; x += 8, dIptr += 8 * 2)
                {
                    __m128i diff0 = _mm_loadu_si128((const __m128i *)(Iptr + x)), diff1;
                    __m128i v00 = _mm_unpacklo_epi8(_mm_loadl_epi64((const __m128i *)(Jptr + x)), z);
                    __m128i v01 = _mm_unpacklo_epi8(_mm_loadl_epi64((const __m128i *)(Jptr + x + cn)), z);
                    __m128i v10 = _mm_unpacklo_epi8(_mm_loadl_epi64((const __m128i *)(Jptr + x + stepJ)), z);
                    __m128i v11 = _mm_unpacklo_epi8(_mm_loadl_epi64((const __m128i *)(Jptr + x + stepJ + cn)), z);

                    __m128i t0 = _mm_add_epi32(_mm_madd_epi16(_mm_unpacklo_epi16(v00, v01), qw0),
                                               _mm_madd_epi16(_mm_unpacklo_epi16(v10, v11), qw1));
                    __m128i t1 = _mm_add_epi32(_mm_madd_epi16(_mm_unpackhi_epi16(v00, v01), qw0),
                                               _mm_madd_epi16(_mm_unpackhi_epi16(v10, v11), qw1));
                    t0 = _mm_srai_epi32(_mm_add_epi32(t0, qdelta), W_BITS1 - 5);
                    t1 = _mm_srai_epi32(_mm_add_epi32(t1, qdelta), W_BITS1 - 5);
                    diff0 = _mm_subs_epi16(_mm_packs_epi32(t0, t1), diff0);
                    diff1 = _mm_unpackhi_epi16(diff0, diff0);
                    diff0 = _mm_unpacklo_epi16(diff0, diff0);        // It0 It0 It1 It1 ...
                    v00 = _mm_loadu_si128((const __m128i *)(dIptr)); // Ix0 Iy0 Ix1 Iy1 ...
                    v01 = _mm_loadu_si128((const __m128i *)(dIptr + 8));
                    v10 = _mm_unpacklo_epi16(v00, v01);
                    v11 = _mm_unpackhi_epi16(v00, v01);
                    v00 = _mm_unpacklo_epi16(diff0, diff1);
                    v01 = _mm_unpackhi_epi16(diff0, diff1);
                    v00 = _mm_madd_epi16(v00, v10);
                    v11 = _mm_madd_epi16(v01, v11);
                    qb0 = _mm_add_ps(qb0, _mm_cvtepi32_ps(v00));
                    qb1 = _mm_add_ps(qb1, _mm_cvtepi32_ps(v11));
                }
#endif
                for (; x < winSize.width * cn; x++, dIptr += 2)
                {
                    int diff = CV_DESCALE(Jptr[x] * iw00 + Jptr[x + cn] * iw01 +
                                              Jptr[x + stepJ] * iw10 + Jptr[x + stepJ + cn] * iw11,
                                          W_BITS1 - 5) -
                               Iptr[x];
                    ib1 += (itemtype)(diff * dIptr[0]);
                    ib2 += (itemtype)(diff * dIptr[1]);
                }
            }

#if CV_SSE2
            float CV_DECL_ALIGNED(16) bbuf[4];
            _mm_store_ps(bbuf, _mm_add_ps(qb0, qb1));
            ib1 += bbuf[0] + bbuf[2];
            ib2 += bbuf[1] + bbuf[3];
#endif

            b1 = ib1 * FLT_SCALE;
            b2 = ib2 * FLT_SCALE;

            Point2f delta((float)((A12 * b2 - A22 * b1) * D),
                          (float)((A12 * b1 - A11 * b2) * D));
            //delta = -delta;

            nextPt += delta;
            nextPts[ptidx] = nextPt + halfWin;

            if (delta.ddot(delta) <= criteria.epsilon)
                break;

            if (j > 0 && std::abs(delta.x + prevDelta.x) < 0.01 &&
                std::abs(delta.y + prevDelta.y) < 0.01)
            {
                nextPts[ptidx] -= delta * 0.5f;
                break;
            }
            prevDelta = delta;
        }

        CV_Assert(status != NULL);
        if (status[ptidx] && err && level == 0 && (flags & OPTFLOW_LK_GET_MIN_EIGENVALS) == 0)
        {
            Point2f nextPoint = nextPts[ptidx] - halfWin;
            Point inextPoint;

            inextPoint.x = cvFloor(nextPoint.x);
            inextPoint.y = cvFloor(nextPoint.y);

            if (inextPoint.x < -winSize.width || inextPoint.x >= J.cols ||
                inextPoint.y < -winSize.height || inextPoint.y >= J.rows)
            {
                if (status)
                    status[ptidx] = false;
                continue;
            }

            float aa = nextPoint.x - inextPoint.x;
            float bb = nextPoint.y - inextPoint.y;
            iw00 = cvRound((1.f - aa) * (1.f - bb) * (1 << W_BITS));
            iw01 = cvRound(aa * (1.f - bb) * (1 << W_BITS));
            iw10 = cvRound((1.f - aa) * bb * (1 << W_BITS));
            iw11 = (1 << W_BITS) - iw00 - iw01 - iw10;
            float errval = 0.f;

            for (y = 0; y < winSize.height; y++)
            {
                const uchar *Jptr = J.ptr() + (y + inextPoint.y) * stepJ + inextPoint.x * cn;
                const deriv_type *Iptr = IWinBuf.ptr<deriv_type>(y);

                for (x = 0; x < winSize.width * cn; x++)
                {
                    int diff = CV_DESCALE(Jptr[x] * iw00 + Jptr[x + cn] * iw01 +
                                              Jptr[x + stepJ] * iw10 + Jptr[x + stepJ + cn] * iw11,
                                          W_BITS1 - 5) -
                               Iptr[x];
                    errval += std::abs((float)diff);
                }
            }
            err[ptidx] = errval * 1.f / (32 * winSize.width * cn * winSize.height);
        }
    }
    return 0;
}
```

## Build And Run R3Live  
最后就可以正常编译运行了。
1. build r3live
```
// in my project path "/xxx/"
cd r3live
catkin_make
source ./devel/setup.bash
```

2. download dataset
following README.md of R3Live 5.1

3. Run
Until now you can follow README.md of R3Live normally.

# Others
debug launch file
```
launch-prefix="xterm -e gdb -ex run --args"
```

# Results
## Hardware Environments
```
RAM infos  : 29.82GB Physical Memory 14.91GB Virtual Memory
OS  infos  : Linux 5.10.104-tegra (aarch64)
```
## Software Environments
```
+++++++++++++++++++++++++++++++++++++++++++++++
Here is the your software environments: 
GCC version          : 9.4.0
Boost version        : 1.71.0
Eigen version        : 3.3.7
OpenCV version       : 4.5.4
+++++++++++++++++++++++++++++++++++++++++++++++
```
## data
```
path:        20230607lvi.bag
version:     2.0
duration:    7:06s (426s)
start:       Apr 20 2019 08:05:06.31 (1555718706.31)
end:         Apr 20 2019 08:12:12.71 (1555719132.71)
size:        4.0 GB
messages:    95922
compression: none [4265/4265 chunks]
types:       sensor_msgs/CompressedImage [8f7a12909da2c9d3332d540a0977563f]
             sensor_msgs/Imu             [6a62c6daae103f4ff57a132d6f95cec2]
             sensor_msgs/PointCloud2     [1158d486dd51d683ce2f1be655c3c181]
topics:      /image_1/compressed    6396 msgs    : sensor_msgs/CompressedImage
             /imu_raw              85262 msgs    : sensor_msgs/Imu            
             /rslidar_points        4264 msgs    : sensor_msgs/PointCloud2
```
## Output maps
```
Saving globale map...
Saving global map: 100 %
Save globale map cost 7138.71 ms
Saving views and camera poses 100 % ...
Save views and camera poses cost 1140.86 ms
Save Rgb points to /home/nvidia/r3live_output/rgb_pt
Saving offline map 100% ...
Total have 5029576 points.
Now write to: /home/nvidia/r3live_output/rgb_pt
Save PCD cost time = 184.08
========================================================
Open pcl_viewer to display point cloud, close the viewer's window to continue mapping process ^_^
========================================================
The viewer window provides interactive commands; for help, press 'h' or 'H' from within the window.
> Loading /home/nvidia/r3live_output/rgb_pt.pcd [PCLVisualizer::setUseVbos] Has no effect when OpenGL version is ≥ 2
[done, 442.905 ms : 5029576 points]
```
## Offline maps
```
Loading R3LIVE offline maps, please wait with patience~~~
Loading global map: 100 %
Load offine global map cost: 6785.71 ms
Loading views and camera poses 100 % ...
Load offine R3LIVE offline maps cost: 9939.09 ms
Number of rgb points: 23239832
Size of frames: 6390
==== Work directory: /home/nvidia/r3live_output
Number of image frames: 6390
Iamge resolution  = 1920 X 1080
Add frames: 94%, total_points = 9937931 ...
Number of image frames: 1464
Number of points 9937931
Retriving points: 100% ...
Total available points number 1585001
Points inserted 1585001 (100%, 9s210ms)           
Delaunay tetrahedralization completed: 1585001 points -> 1585001 vertices, 10108516 (+242) cells, 20217153 (+363) faces (10s873ms)
Points weighted 1585001 (100%, 4s644ms)           
Weighting completed in 4s644ms
Delaunay tetrahedras weighting completed: 10108758 cells, 20217516 faces (13s776ms)
Delaunay tetrahedras graph-cut completed (228232 flow): 1452655 vertices, 3556408 faces (17s280ms)
FixNonManifold, current iteration 0, Mesh Info: have 1494143 vertices and 3115664 faces
FixNonManifold, current iteration 1, Mesh Info: have 1566664 vertices and 3033228 faces
FixNonManifold, current iteration 2, Mesh Info: have 1615213 vertices and 3020944 faces
FixNonManifold, current iteration 3, Mesh Info: have 1626216 vertices and 3018530 faces
Mesh reconstruction completed: 1626216 vertices, 3018530 faces
Clean mesh [1/3]: Cleaned mesh: 1438862 vertices, 2879773 faces (38s97ms)
Clean mesh [2/3]: Cleaned mesh: 1438889 vertices, 2879855 faces (15s39ms)
Clean mesh [3/3]: Cleaned mesh: 1438889 vertices, 2879855 faces (5s752ms)
Save mesh to file: /home/nvidia/r3live_output/reconstructed_mesh.ply
Mesh saved: 1438889 vertices, 2879855 faces (536ms)
Save mesh to file: /home/nvidia/r3live_output/reconstructed_mesh.obj
Mesh saved: 1438889 vertices, 2879855 faces (7s652ms)
```

# Source
## ESIKF filter
* service_VIO_update
 * vio_preintegration
  * imu_preintegration
 * Global_map::selection_points_for_projection 
  * Image_frame::project_3d_point_in_this_img // project 3d points to image
 * Rgbmap_tracker::track_img // optical-flow 
 * Rgbmap_tracker::remove_outlier_using_ransac_pnp // PnP Ransac

* service_LIO_update
 * ImuProcess::Process // 
 * Global_map::append_points_to_global_map // add points to voxel
## pose graph optimize
Perspective-n-Point (PnP) 
