---
layout: default
title: Frustum Culling
categories:
- Algorithm
tags:
- Game
---
//Description: Frustum Culling

//Create Date: 2022-08-26 10:27:39

//Author: channy

# 概述  
视锥体剔除优化方案。使用八叉树构建层次包围盒。  
其中，视锥体由六个平面组成
```c++
class Frustum {
public:
    Frustum() {}

    Plane plane_[6];
};
```
八叉树存储了根节点和最小包围盒阈值

每个八叉树节点存储该节点对应的包围盒、元素及元素id、子节点

## 基础相交检测
n平面法向量与x空间上任意一点的点乘加上平面距离d = 0时，表示该点x在平面上，当<0时，表示在平面背面。当一个点位于视锥体6个平面的背面时，表示该点位于视锥体外。
$$ n x + d = 0 $$

## 优化一：平面一致性测试
如果一个点在上一次检测中位于视锥体外，那么下一次检测与上一次检测结果相同的可能性大。

即，一个点在上一次检测中在一平面外，下一次检测可优先检测该平面，尽早退出循环计算

## 优化二：八分测试
在视锥体对称的情况下，检测包围盒中心点到顶点的距离，及视锥体中心到顶点的最大距离，并进行比较，只需要比较三个视锥体平面

## 优化三：标记
一个包围盒位于视锥体某平面的背面，那么该包围盒所有子节点也位于视锥体该平面的背面，可以增加标记，在检测该包围盒的子节点时避免重复与该平面的计算

## 平移旋转一致性测试
当知道视锥体的平移与旋转时，
* 如果上一次检测包围盒位于视锥体的一侧，而视锥体只平移向另一侧
* 如果上一次检测包围盒位于视锥体的一侧，而视锥体只旋转向另一侧

# reference  
[Optimized View Frustum Culling Algorithms for Bounding Boxes](https://www.tandfonline.com/doi/abs/10.1080/10867651.2000.10487517)

@article{assarsson2000optimized,
  title={Optimized view frustum culling algorithms for bounding boxes},
  author={Assarsson, Ulf and Moller, Tomas},
  journal={Journal of graphics tools},
  volume={5},
  number={1},
  pages={9--22},
  year={2000},
  publisher={Taylor \& Francis}
}
