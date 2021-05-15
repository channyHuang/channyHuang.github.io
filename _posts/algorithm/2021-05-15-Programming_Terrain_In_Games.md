---
layout: default
title: Noise_Terrain_Generation.md
categories:
- Game
tags:
- Game
---
//Description: 程序化地形生成

//Create Date: 2021-05-15 17:19:39

//Author: channy

# noise terrain generation

## 概述

1. 最终目标为生成全局地形vBox/vSphere，地形种类为n
1. voronoi分成n个区域，对应n种地形
1. 对每个区域生成对应地形
1. 地形边界平滑处理
1. 地形生态根据区域随机生成（erosion侵蚀，高度决定植被）

## noise type 噪声分类

[fastnoise library](https://github.com/Auburn/FastNoise)

single noise 
	Lattic based
		Gradient noise
			Perlin noise
			Simplex noise
			Wavelet noise
		Value noise
	Point based
fractal noise
	fbm noise
	fride noise
	domain wrapping noise

用各种noise可以生成地形高度图，但无法生成复杂结构如山洞等

### reference 

[从随机数到自然界中的噪声之二-Perlin Noise](https://zhuanlan.zhihu.com/p/77628759)

[分形布朗运动fbm](https://thebookofshaders.com/13/?lan=ch)

[常用噪声算法](https://zhuanlan.zhihu.com/p/346844820)

[Making maps with noise functions](https://www.redblobgames.com/maps/terrain-from-noise/)

[游戏中的程序化地形生成技术简介](https://zhuanlan.zhihu.com/p/59358576)

[Terrain 算法整理](https://zhuanlan.zhihu.com/p/149052689)

[Free Terrain 3D models](https://www.cgtrader.com/free-3d-models/terrain)

### Perlin Noise/Simplex Noise

其中Perlin noise被广泛应用，可以用Perlin噪声生成三维噪声图，[-1,1]分布，根据每个空间点的噪声正负确定该点是否是地形的一部分（marching cubes 网格化算法）

常用于生成平滑的地形

> 生成网格梯度向量
> 曲线拟合
> Simplex Noise的梯度函数为三阶方程，避免导数不连续问题

[三维的柏林噪声，需要算出八个顶点的梯度贡献值，然后进行插值计算](http://www.twinklingstar.cn/2015/2581/classical-perlin-noise/)

[Perlin噪声具体实现参考](https://www.scratchapixel.com/lessons/procedural-generation-virtual-worlds/perlin-noise-part-2/perlin-noise-terrain-mesh)

2d perlin noise可生成高度图，3d perlin noise可生成立体图

### fractal noise/分形噪声

分形噪声本质上是基础噪声的叠加，如Perlin + fbm多用于生成山地地形

（Fractal Noise is any noise which produces a fractal）

参数说明：

> amplitude: 噪声振动幅度，影响噪声的最大最小值

> frqueency: 频率 

> octaves: 分形数，影响平滑度。The level of detail. Lower = more peaks and valleys, higher = less peaks and valleys.

> lacunarity: 倍数，间隙度。The level of detail on each octave (adjusts frequency).

> gain: 增益。How much an octave contributes to overall shape (adjusts amplitude).

### Voronoi图生成地形算法(Worley/Cell Noise)

效果：对整个地形进行分割成区域，每个区域一种地形（平原、山地...）；或用于平原粗糙化分裂

2d Voronoi基本图形生成

> n个随机点vCenters（最后分割成的区域个数及中心点）

> 对图中每个像素点，查找最近的vCenters

> over

2d Voronoi高度图生成

> 对图中的每个像素点，knn查找最近的k个点，计算到这k个点的加权距离，作为高度

2d Voronoi图边界粗糙化

> level2, f(n) > n 个随机点vHCenters

> 对图中每个像素点，查找最近的vHCenters

> 对查找到的vHCenters，查找最近的vCenters

根据目标像素到最近中心点的距离确定高度，距离有Eular距离等

## Voxel数据存储

每个数组元素（Voxel）保存的不再是高度值，而是一个近似的距离值（iso-value）或密度值SDF，表示这个点有多大程度在土地里或暴露在空气中。

### 3D 等值面提取/网格重建

> Marching Cubes
> Marching tetrahedra
> Dividing Cubes
> Dual Contouring (Hermite data)
> Transvoxel (http://transvoxel.org/)
> Naive Surface Nets

# Delaunay三角化
## godot Voxel Tools

|- VoxelTerrain
	|- VoxelBuffer //mininum storage cell 
		|- VoxelGeneratorNoise
		|- SimplexNoise //generate 3d terrain with lod
	|- VoxelMap
		|- VoxelBlock //include voxel buffer、material、mesh etc
	
|- VirsulServerRaster //render
	|- VisualServerCanvas
	|- VisualServerViewport
	|- VisualServerScene
	
## 数学相关

###距离分类

* Euclidean 
Use the Euclidean distance metric

* Manhattan
Use the Manhattan distance metric.

* Chebychev
Use the Chebychev distance metric.

* Minkowski
Use the Minkowski distance metric.

### 数学库

[ALGLIB]

[Eigen]

[LAPACK++](http://lapackpp.sourceforge.net/)

[Math Libraries in C++](https://en.wikipedia.org/wiki/List_of_numerical_libraries#C++)

## 生态模拟

> 山地：perlin + fbm
> 沙丘：perlin + ridge
> 平原/丘陵/极地：perlin + domain wrapping
> 电路板：domain wrapping


## 河流

确定最小初始高度，随机河流源头，梯度下降，erosion生成流域图

erosion

## 植被

到水源的距离确定湿度

基于密度图的植被放置方法。

利用一张灰度图来控制植被模型的分布。一层灰度信息只能控制一种植物的分布。

density

pointcloud

## 道路

贝塞尔曲线

Catmull-Rom曲线

## 地形平滑

Gaussian filter 3d

对voxel中的data进行滤波

### 2D

3*3 filter

bi-linear interpolation

```
^
| A--------B
| |        |
| | P      |
| |        |
| C--------D
Y 
*X------------>

// This could be different depending on how you get points
// (basically generates a [0, 1] value depending on the position in quad;
px = P.x - (int)P.x
py = P.y - (int)P.y
AB = A.h * (1.0 - px) + B.h * px;
CD = C.h * (1.0 - px) + D.h * px;
ABCD = AB * (1.0 - py) + CD * py;
```
Gaussian filter 



## convex hull

Andrew / Quickhull
