---
layout: default
title: Project - 3D Reconstruction
categories:
- Algorithm
- Lib
tags:
- Computer Vision
- Project
- 3D Reconstruction
---
//Description: previous project, 3D reconstruction, greduate paper

# Project - 3D Reconstruction

Here is a little introduction about one of my previous projects -- 3D reconstruction.

## Basic Data Flow

So sorry that flow can not be shown -.-
```flow
st=>start: Start
opInput=>operation: Input images/vedio
opDetect=>operation: Feature detect and match
opCompute=>operation: Compute params of camera
opFace=>operation: Reconstruct mesh model
opFix=>operation: Fix model using DB
e=>end
st->opInput->opDetect->opCompute->opFace->opFix->e
```

Well, First step, Feature detecting and matching. (*[Feature Detection In OpenCV](./Feature_Detection_In_OpenCV.html) & 
[Feature Matching In OpenCV](./Feature_Matching_In_OpenCV.html)*)

There are many kinds of features, SIFT, SURF, FAST, ORB, BRISK, Freak, Harri, BOW...

Compared these features, we can find that in most cases, SIFT is best because it contains scale, can detect more features than others, of cause, it is not fast enough.

In this project, we combine two features: `SIFT` and `Freak`.

- [x] Difficulty 1: **What if the input images has few features?**

	Of cause we can add some texture objects in scene if possible. But if it is hard, than we can add something else, for example, detect lines or other shapes in input images according to what scene to be inputed. Building reconstruction is based on line detection. This project tries to reconstruct foot, so there is no lines.

Minimize the error of reprojection, BA algorithm, solve nonlinear least squares problem.

The basic method to resolve BA is Gradient descent, such as Gauss-Newton, Levenberg-Marquardt, etc. And there are many libraries to solve Least Square Method: `Ceres Solver`

PS: `Some libraries that can solve Least Square` (**At the bottom of this article**)

PPS: `Some libraries of math`  (**At the bottom of this article**)

PPPS: `Some libraries used before`   (**At the bottom of this article**)

- [] Difficulty 2: **What if the point cloud is sparse?**

	In order to build a dense point cloud, most researchers will refer to PMVS/CMVS. This is an open source library to generate a dense point cloud. But I don't know why so many people believe it is a 3D reconstruction library. Actually, the input of PMVS/CMVS is sparse point cloud, it is just change it to dense cloud but not contains the whole flow of 3D reconstruction.

From point cloud to mesh model, use possion reconstruction.

- [] Difficulty 3: **How to improve precision?**

We have a small database of foot. At the last step in this project, we use models in database to fix the reconstruction model.

## Some reference:
> [VisualSFM](http://ccwu.me/vsfm/)

> [PMVS/CMVS](http://www.di.ens.fr/pmvs/)

### Some libraries that can solve Least Square

1.         lmfit python package

(Least-Squares Minimization with Constraints for Python)

https://pypi.python.org/pypi/lmfit/0.6

2.         EoFit

非线性最小二乘拟合

https://www.effectiveobjects.com/eofit-dll.html

3.         Drej - A java regression library

最小二乘回归和分类

http://www.gregdennis.com/drej/

4.         Least Squares Geometric Elements library

最小二乘拟合

http://www.eurometros.org/gen_report.php?category=distributions&pkey=14&subform=yes

5.         MINPACK

http://cran.r-project.org/web/packages/minpack.lm/index.html

 

以下是两个数值分析库，包含最小二乘

6.         ALGlib

http://www.alglib.net/download.php

7.         MPFIT

http://www.physics.wisc.edu/~craigm/idl/cmpfit.html


### Some libraries of math (Summarized by others)

cml, alglib, levmar, armadillo.

关于数学库，gsl 、 vxl中的vnl子库、eigen作为一般的库还是可以的。

1、OpenSceneGraph

OpenSceneGraph是个开源的高性能3D图形工具，广泛应用于可视化模拟、游戏、虚拟现实、科学可视化和建模等领域。完全用标准C++和OpenGL编写，可以在各种平台下运行。


2、OpenTissue

OpenTissue是一个优秀的3D交互建模和仿真算法库，使用C++的模板实现，支持各种常用3D数学算法，建模与三角化，碰撞检测，基于GPU的动画角色蒙皮，动力学等等。支持OpenGL与NVIDIA Cg。它是基于ZLib协议开源发布的，可以用作商业目的。编译时需要Boost库支持，并使用CMake进行生成编译脚本。

3、PhysBAM

hysBAM 是斯坦福大学针的物理仿真库，能够模拟刚性 & 形变、 可压缩和不可压缩流体、 耦合的固体 & 流体、 耦合的刚性及变形固体、 铰接式刚性机构 & 人类、 骨折、 火、 烟、 头发、 布、 肌肉，以及其他许多自然现象。这些算法常被用于国外物理仿真与三维影像制作。

4、DOLFIN

DOLFIN是FEniCS项目的C++接口，用于实现自动化的计算数学建模（ACMM）。DOLFIN提供了一个一致的、求解常微分和偏微分方程的问题求解环境（Problem Solving Environment）。关键的特性包括：简单、一致和直观的面向对象的API；通过FFC自动高效地计算变分形式；自动和高效地组合线性系统；支持通用的有限元。

5、libMesh

libMesh用来处理六面体、四面体、四边形、三角形网格。和有限元相关。可以用来模拟风洞、流体等。

6、FEniCS

FEniCS是一个合作项目以开发自动科学计算相关的革新的概念和工具，特别是用有限元方法自动求解偏微分方程。FEniCS是由一些可相互操作的组件组成的项目。这些组件包括问题求解环境DOLFIN，FEniCS形式编译器FFC，有限元制表机FIAT，just-in-time编译器Instant，代码生成接口UFC，形式化语言UFL和其它一些组件。

7、GAMS

The General Algebraic Modeling System是一款数学规划和优化的高级建模系统。GAMS是特别为建模线性、非线性和混合整数最优化问题而设计的，对大型的复杂的问题问题特别有帮助。GAMS可以运行在个人计算机、工作站、大型机和超级计算机上。（商业和教学都是收费的，demo版本有较大限制）

8、OOFEM

OOFEM是自由的、具有面向对象结构的有限元代码，主要用于解决机械、交通运输和流体力学问题。项目为FEM计算开发高效强健的工具，并且提供模块化和可扩展的环境。OOFEM以GNU GPL许可发布。
       
9、OpenFEM

有限元分析，即使用有限元方法来分析静态或动态的物体或系统。在这种方法中一个物体或系统被分解为由多个相互联结的、简单、独立的点组成的几何模型。在这种方法中这些独立的点的数量是有限的，因此被称为有限元。


10、Ceres Solver

这是一个可移植的C++库，用来建模和解决大型复杂的非线性最小二乘问题。显著特性如下：
友好的的API；自动和数值微分；强健的损失函数；局部参数化；A threaded Jacobian 估值器和线性求解器；Trust region solvers with non-monotonic steps (Levenberg-Marquardt and Dogleg (Powell & Subspace))；线性搜索求解器（L-BFGS和非线性CG）；对小问题的稠密QR分解（使用Eigen）；大型稀疏问题

### Some libraries used before

几何处理库libigl ~=CGAL

https://github.com/libigl/libigl

书籍 **************************************************************

NO1.   英文书籍电子版

http://gen.lib.rus.ec/

第三方库 **************************************************************

NO1.   Boost二进制安装包，终于不用再自己要死要活地编译了

http://boost.teeks99.com/

NO2.   Python的各种库，应有尽有

http://www.lfd.uci.edu/~gohlke/pythonlibs/

NO3.   计算机视觉的各种测试数据集

http://www.cvpapers.com/datasets.html

No4.   glew

http://glew.sourceforge.net/

No5.    matlab库，四元数

http://www.montefiore.ulg.ac.be/~dteney/dml.htm

***voxel graphics c++ libaray***

No6.       OpenVDB，c++库，可以处理voxel

http://www.openvdb.org/

依赖于zlib, tbb, openexr...编译困难

No7.       Binvox

把mesh文件转化成voxel grid (Not really a library, but a voxelizer 
with a basic binary voxel data definition)
http://www.cs.princeton.edu/~min/binvox/

No8.        GigaVoxels (Ray-guided streaming library for voxels)

http://gigavoxels.imag.fr/

No9.    PolyVox，c++ library

http://www.volumesoffun.com/polyvox-documentation/

No10.     Field3D

http://opensource.imageworks.com/?p=field3d

算法 **************************************************************

No 1.

Kalman滤波：

matlab库 -- http://www.cs.ubc.ca/~murphyk/Software/Kalman/kalman.html

No 2.

传感器：

由传感器数据估计旋转矩阵：

http://www.x-io.co.uk/res/doc/madgwick_internal_report.pdf

No 3.

视觉的一些算法和对应的库：

http://www.cvpapers.com/rr.html

各种视觉的数据集：很多打不开

http://www.computervisiononline.com/datasets

视觉，matlab

http://damienteney.info/dml.htm

No 4.

图形学的一些库：

http://www.dgp.toronto.edu/~rms/links.html

No 5.

OpenGL矩阵计算类

http://www.songho.ca/opengl/gl_matrix.html

No 6.

.off 三维模型格式 

[back](./)
