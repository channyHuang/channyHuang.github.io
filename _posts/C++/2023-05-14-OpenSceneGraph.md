---
layout: default
title: OSG - OpenSceneGraph
categories:
- C++
tags:
- C++
---
//Description: 为了跨平台编译不折腾打算从Qt换成imgui+osg. 测试平台用的是MacBook Pro (13-inch, 2019, Two Thunderbolt 3 ports)，系统用的是macOS Big Sur。

//Create Date: 2023-05-14 21:04:19

//Author: channy

# imgui + osg
在win10上正常，但在mac上报不支持glsl 130. 试了下120可以，但130就是会报错。
```c++
ERROR: ImGui_ImplOpenGL3_CreateDeviceObjects: failed to compile vertex shader! With GLSL: #version 130

ERROR: 0:1: '' :  version '130' is not supported
```

# osg基本操作
## assimp
assimp并不属于osg。只因为渲染显示一般需要加载模型，而assimp是个还不错的选择。
## osg使用高版本glsl
osgViewer：显示窗口
osgDB：读取纹理等资源，但默认支持的图片格式不包含jpg和png，需要编译时加上第三方的库。默认支持bmp。
osg

# 附录
opengl和glsl版本对应
```c++
//----------------------------------------
// OpenGL    GLSL      GLSL
// version   version   string
//----------------------------------------
//  2.0       110       "#version 110"
//  2.1       120       "#version 120"
//  3.0       130       "#version 130"
//  3.1       140       "#version 140"
//  3.2       150       "#version 150"
//  3.3       330       "#version 330 core"
//  4.0       400       "#version 400 core"
//  4.1       410       "#version 410 core"
//  4.2       420       "#version 410 core"
//  4.3       430       "#version 430 core"
//  ES 2.0    100       "#version 100"      = WebGL 1.0
//  ES 3.0    300       "#version 300 es"   = WebGL 2.0
//----------------------------------------
```