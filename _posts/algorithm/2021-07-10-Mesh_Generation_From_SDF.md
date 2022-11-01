---
layout: default
title: Mesh_Generation_From_SDF.md
categories:
- Game
tags:
- Game
---
//Description: 从sdf数据中生成网格

//Create Date: 2021-07-10 14:46:27

//Author: channy

# Mesh Generation From SDF

## 概述

输入： 
[Marching Cubes]()
[Dual Contouring](https://github.com/emilk/Dual-Contouring.git)
[Native Surface Nets](https://github.com/Q-Minh/naive-surface-nets.git)
设sdf函数为f(v)，对每一个voxel，如果该voxel的12条棱中存在至少一条棱满足f(v1) * f(v2) <= 0，说明这个voxel包含有网格面，记为活动voxel。

对于MC，根据活动voxel所有顶点的情况共可分为10+个种类，依靠查找MC表确定活动voxel产生的顶点数和面数，每个产生的顶点都在voxel的边上，不会出现在内部或外部。

而对于DC和SN，都是每个活动voxel产生一个网格顶点，DC由法线控制，顶点可能会出现离voxel偏远的情况或是解矩阵方程无解的情况，需要特殊处理。
