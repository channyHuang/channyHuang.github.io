---
layout: default
title: PointCloud_Reconstruction
categories:
- Algorithm
tags:
- Computer Vision
---
//Description: 点云表面重建技术研究笔记。

//Create Date: 2023-04-03 20:40:39

//Author: channy

[toc]

***
<font color = red> 传统方法 </font>
***

# 概述  
点云表面重建一般步骤有：
1. 删除外围噪声点Outlier，即点云分割
1. 点云简化
1. 点云光滑化
1. 法向量估计
1. 重建三维网格
1. 后处理，如补洞等

# Outlier removal
## Statistical Outlier Removal filter
针对点云中的每一个点，搜索最近的k个邻近点组成邻近点集${P_i}$，计算该点到邻近点集合中每个点的距离的均值和标准差；如果该点在预先设置的标准差范围内，则保留该点否则去掉。
## Radius Outlier removal
设定一个搜索半径，判断目标点在设定半径范围内的相邻点数目，设定阈值范围
## Conditional removal
自定义一个过滤的condition，对目标点云进行特定点的移除
## passthrough
直通滤波（passthrough filter)操作相对粗暴，针对自定义的点的类型，对 X、Y、Z、R、G、B…等等各纬度进行内外点的界定

<font color = cyan> 对于无规律的点云，上述算法效果并不理想。特别是对于杂乱且密度不一致的点云，外围点剔除效果并不好，甚至不如聚类后取最大的类。 </font>

# Simplify
各种滤波，包括高斯滤波、体素滤波、均值滤波等等。
## Grid Simplify
把点云空间分割成单位立方体，对每个单位立方体内的点只取其中一个（随机、重心等），其它点舍弃。
## WLOP Simplify (Weighted Locally Opti-mal Projection)

## Hirarchy Simplify
对点云中的点计算聚类重心，

<font color = cyan> 点云简化目标是为了减少不必要的计算量，但有可能以降低精确度为代价。在精确度没达到的前提下，不建议使用。 </font>

# Smooth
## JET Smooth
## Bilateral Smooth

<font color = cyan> 肉眼看不出明显区别。 </font>

# Normal Estimation
## JET 
不估计朝向
## PCA
不估计朝向
## MST
最小生成树算法。在有法向量的基础上修正法向量朝向
## VCM
利用扫描点的特征--视线估计法向量朝向
最小二乘法 (MLS)，2阶多项式

<font color = cyan> CGAL中有上面四种算法，但从实际计算结果看，各种组合都没有VcgLib中的法向量估计算法好。 </font>

# Reconstruction 重建三维网格
## Possion重建（2006）
需要法向量作为输入，保证重建生成的曲面封闭。不对输入点云进行插值，重建的曲面严格经过输入点。  
通过拟合隐式函数确定网格面。设目标曲面函数$F(x)$，使得$F(x)$在每个点$p$处的梯度值即为该点的法向量$n$，即最小化误差函数$min {|F - \nabla n|}^2$  

<font color = cyan> Possion重建在2020年有论文发表有新改进，对误差函数增加了一项，且增加了包围盒，能够避免为了封闭强行扩展表面的问题。 </font>

## Advancing Front surface reconstruction
先把点云空间进行Delaunay三角剖分，然后根据法向量使用优先队列选择最适合的面逐步扩展直到所有面连接。
## Scale Space
对点云进行缩放，如使用平滑滤波器进行平滑得到弱化了细节的点云，从而得到两个不同细节的网格，再根据初始点云对网格进行插值，逐步逼近点云。
## 其它算法
凸包重建、凹包重建

# Post Processing
## hole filling
## mesh smooth

***
<font color = red> 神经网络方法 </font>
***

# NeRF
[CityNeRF](https://github.com/city-super/BungeeNeRF)  
[awesome-NeRF](https://github.com/awesome-NeRF/awesome-NeRF)

***
<font color = red> 其它笔记 </font>
***

# 附录1: 编译遇到的问题
* 使用CGAL过程中转Debug编译，报
```
fatal error C1128: number of sections exceeded object file format limit : compile with /bigobj
```
vs中，可properties(属性) -> Configuration Properties(配置属性) -> C/C++ -> Command Line(命令行) -> Additional options(其他选项)，加上 /bigobj属性重新编译。

# 参考库
[cgal](https://github.com/CGAL/cgal.git)  
[glfw](https://github.com/glfw/glfw)  
[glew](https://github.com/nigels-com/glew/releases/download/glew-2.2.0/glew-2.2.0.zip)