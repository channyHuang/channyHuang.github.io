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
针对每一个点，把该点和其距离最近的N个点组成一个点集合；假设这个点集符合正态分布，计算该点集合的均值和标准差；如果该点在预先设置的标准差范围内，例如一个标准差内，则保留该点否则去掉；
## Radius Outlier removal
设定一个搜索半径，判断目标点在设定半径范围内的相邻点数目，设定阈值范围
## Conditional removal
自定义一个过滤的condition，对目标点云进行特定点的移除
## passthrough
直通滤波（passthrough filter)操作相对粗暴，针对自定义的点的类型，对 X、Y、Z、R、G、B…等等各纬度进行内外点的界定

# Simplify
滤波

# Smooth
最小二乘法 (MLS)，2阶多项式

# 重建三维网格
### Possion重建（2006）
通过拟合隐式函数。
### Advancing Front surface reconstruction
### Scale Space
### 其它算法
凸包重建、凹包重建