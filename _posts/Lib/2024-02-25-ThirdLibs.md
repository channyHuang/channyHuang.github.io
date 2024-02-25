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
## OpenGL
## glfw/glew

# 界面
## Qt
## ImGUI

# Agent
## DDPG/MADDPG/MAPPO

# 3d model format
## 3dml 
数据表存储
