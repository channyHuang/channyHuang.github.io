---
layout: default
title: GLSL Learning
categories:
- Notes
tags:
- Game
---
//Description: 记录学习opengl中遇到的问题

//Create Date: 2023-04-08 10:27:39

//Author: channy

# 版本
截止目前，OpenGL共存在3个大版本，1.0、2.0和3.0.

2.0中，vertex shader的输入数据变量用attribute，输出到fragment shader的数据变量用varying.

而在3.0中，vertex shader的输入数据变量用in，输出到fragment shader的数据变量用out

# 运算符
2.0中，不支持逻辑运算符

3.0中支持。