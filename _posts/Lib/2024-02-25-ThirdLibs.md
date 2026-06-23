---
layout: default
title: 第三方库记录
categories:
- Lib
tags:
- Lib
---
//Description: 记录用过的第三方库函数，特别是三维重建相关的

//Create Date: 2023-02-25 18:04:19

//Author: channy

# Compiler
## CMake
CMake 在查找其它库时在目标目录下的cmake中寻找查找信息。

路径信息通过各个库的.cmake文件说明中查找。如OpenCV在OpenCVConfig.cmake中设置了OpenCV_INCLUDE_DIRS变量，osg在OpenSceneGraphConfig.cmake中设置了OSG_INCLUDE_DIR等。

```
cmake -G"MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%cd%/install -DCMAKE_C_COMPILER=D:/Qt/Qt5.14.2/Tools/mingw730_64/bin/gcc.exe -DCMAKE_CXX_COMPILER=D:/Qt/Qt5.14.2/Tools/mingw730_64/bin/c++.exe -DCMAKE_MAKE_PROGRAM=D:/Qt/Qt5.14.2/Tools/mingw730_64/bin/mingw32-make.exe ../cmake
```
cmake使用mingw编译

# Reconstruction
## OpenMVG + OpenMVS
图像序列重建基本流程
## Open3D
* ISPC 编译器
编译需要下载ext-open3d_sphinx_theme
## COLMAP
稠密重建需要gpu
## GDAL
地理信息库

# Model Loader
## Assimp 
支持多种格式模型，不支持obj中同一顶点不同uv

1. Assimp不支持Ply格式的多纹理坐标加载。

## tinyobjloader
加载obj文件用。只有头文件，只能单次include，适用于小型项目。

# Geometry Library
## OpenCV
视觉几何处理库。经典算法，效果一般。
## CGAL
几何模型库。只包含头文件可用。经典算法，效果一般。模板多，移植不易。
## PCL 
点云库。
## vcglib
meshlab中使用vcg求解点云法向量，比CGAL效果好。
## libigl
只头文件。几何视觉库。依赖Eigen，使用glfw可视化。
## PhysX
物理碰撞库。
## xatlas 
纹理扩展库。

# Math
## Eigen
只头文件。矩阵运算库。
## Ceres-solver
非线性优化问题
## lz4
高效无损压缩算法
## flann
快速邻近搜索包
## glpk
线性规划
## scip
整数非线性规划求解器

# 其它
## ffmpeg
音视频库
## jpeg/libpng  
## magic_enum
只头文件。枚举类型和string的相互转化，c++17以上
## FleeImage
## protobuf
结构化数据格式

# 渲染显示
## OpenSceneGraph
渲染显示，封装了opengl

OpenSceneGraph -> install -> set System Path OSG_DIR -> use find_package(OpenSceneGraph)

只有OpenSceneGraph_INCLUDE_DIRS

## OpenGL
## glfw/glew
glfw的glfw3Config.cmake文件指向glfw3Targets.cmake文件，而该文件里面并没有设置类似于GLFW3_INCLUDE_DIR之类的变量。故加了路径之后cmake能够find_package成功但路径为空。

修改glfw3Targets.cmake文件增加路径设置
```
set(GLFW3_INCLUDE_DIR "${_IMPORT_PREFIX}/include")
set(GLFW3_LIBRARY_DIR "${_IMPORT_PREFIX}/lib")
```

-> set System Path GLFW3_DIR -> use find_package(GLFW3)

# 界面
## Qt
## ImGUI

# Agent
## DDPG/MADDPG/MAPPO

# 3d model format
## 3dml 
数据表存储

# Cross Platform
## c++开发库给java调用
1. c++开发实现库函数
2. 如果是给android，下载ndk。建立jni文件夹，编写Android.mk和Application.mk两个文件。其中jni文件夹下include存放头文件，src存放源文件，libs存放依赖库。
3. ndk-build 会在jni同层下建立文件夹libs和obj生成.so库文件
4. 下载安装jdk，设置java环境变量，编写简单的java调用程序
5. javac -h -jni xxx.java生成jni头文件
6. 编写jni头文件对应的cpp文件
7. jni的头文件和cpp文件增加到c++库，重新ndk-build

```Android.mk
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_CFLAGS += -Wall
LOCAL_CFLAGS += -O3 -fPIC -std=c++17

LOCAL_C_INCLUDES := $(LOCAL_PATH)/include

LOCAL_C_INCLUDES += $(LOCAL_PATH)/include/eigen-3.4.0

LOCAL_C_INCLUDES += ${LOCAL_PATH}/include/magic_enum-master/include

LOCAL_SRC_FILES := \
	$(subst $(LOCAL_PATH)/,, \
	$(wildcard $(LOCAL_PATH)/src/*.cpp)) 

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_C_INCLUDES)

LOCAL_CPP_FEATURES += exceptions

LOCAL_LDLIBS := -L$(LOCAL_PATH)/libs 

LOCAL_MODULE := IntentionDetection
```

```Application.mk
# The ARMv7 is significanly faster due to the use of the hardware FPU
#APP_ABI := armeabi
APP_ABI := armeabi-v7a
APP_STL := c++_static
APP_PLATFORM := android-16
```

### 多平台编译 
```
error: cannot initialize a parameter of type 'JNIEnv **' (aka '_JNIEnv **') with an rvalue of type 'void **'
                if ((g_VM)->AttachCurrentThread((void**)&env, NULL) != 0) {
```
windows 需要`(void**)`转型，linux不需要。

