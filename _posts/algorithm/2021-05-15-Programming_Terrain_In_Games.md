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

最终目标为生成全局地形vBox，地貌种类为n，包括如下部分：
* 基本地形生成，地形高低起伏，考虑洞穴（地形网格，否则直接用高度图即可）
* 地貌类型，根据地形高度和不同地貌的概率确定（地形材质） 
* 生态，主要为动植物分布
* 其它物品

基本思路： 
1. 非机器学习
	1. voronoi分成n个区域，对应n种地貌
	2. 对每个区域生成对应地貌
		1. 噪声生成主地貌
		2. 地形边界平滑处理，噪声参数+权重
	3. 地形生态根据区域随机生成（erosion侵蚀，高度决定植被）
2. 机器学习
	1. 输入点、线、面作为地形高度、生态类型参考，算法生成具体生态
	2. 生态笔刷

## noise type 噪声分类

[**fastnoise library**](https://github.com/Auburn/FastNoise) - a noise library contains most of classical noise

* single noise 
	* Lattic based
		* Gradient noise
			* [**Perlin noise**](https://mrl.cs.nyu.edu/~perlin/noise/)
			* Simplex noise
			* Wavelet noise
		* Value noise
	* Point based
		* Worley/Cell noise - Voronoi diagram
* [fractal noise](https://thebookofshaders.com/13/?lan=ch)
	* fbm noise
	* ridge noise
	* domain wrapping noise

用各种noise可以生成地形高度图，但无法生成复杂结构如山洞等

### procedure terrain 利用噪声生成地形

[Making maps with noise functions](https://www.redblobgames.com/maps/terrain-from-noise/)

[游戏中的程序化地形生成技术简介](https://zhuanlan.zhihu.com/p/59358576)

[Terrain 算法整理](https://zhuanlan.zhihu.com/p/149052689)

[Free Terrain 3D models](https://www.cgtrader.com/free-3d-models/terrain)

[Fantasy Map Generator](https://github.com/rlguy/FantasyMapGenerator)

### Perlin Noise/Simplex Noise

其中Perlin noise被广泛应用，可以用Perlin噪声生成三维噪声图，[-1,1]分布，根据每个空间点的噪声正负确定该点是否是地形的一部分（marching cubes 网格化算法）

常用于生成平滑的地形

[perlin noise algorithm](https://adrianb.io/2014/08/09/perlinnoise.html)
* 生成网格梯度向量
* 曲线拟合
* Simplex Noise的梯度函数为三阶方程，避免导数不连续问题

[**Perlin noise in 3d**](http://www.twinklingstar.cn/2015/2581/classical-perlin-noise/)

[Perlin noise implement](https://www.scratchapixel.com/lessons/procedural-generation-virtual-worlds/perlin-noise-part-2/perlin-noise-terrain-mesh)

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

### Diamond Square



## Voxel数据存储

每个数组元素（Voxel）保存的不再是高度值，而是一个近似的距离值（iso-value）或密度值SDF，表示这个点有多大程度在土地里或暴露在空气中。

### 3D 等值面提取/网格重建

* [Marching Cubes](http://paulbourke.net/geometry/polygonise/)
* Marching tetrahedra (2D) - Marching Cube (3D)
* Dividing Cubes
* Dual Contouring (Hermite data) 根据法线最小化误差函数求得点所在的坐标，每个inside的voxel顶点对应生成一个点，法线可指定
* [Transvoxel](http://transvoxel.org/) MC的改进
* Naive Surface Nets
* Poisson

### Delaunay三角化
	
## 数学相关

### convex hull

Andrew / Quickhull

### 距离分类

* Euclidean 
Use the Euclidean distance metric

* Manhattan
Use the Manhattan distance metric.

* Chebychev
Use the Chebychev distance metric.

* Minkowski
Use the Minkowski distance metric.

### 数学库

[CGAL](https://www.cgal.org/) 使用LGPL和GPL协议

[ALGLIB]

[Eigen]

[LAPACK++](http://lapackpp.sourceforge.net/)

[Math Libraries in C++](https://en.wikipedia.org/wiki/List_of_numerical_libraries#C++)

## 生态模拟

1. 不同噪声生成不同地形

* 山地：perlin + fbm
* 沙丘：perlin + ridge
```c++
	//fast_noise_lite
	//set noise type
	noiseLite.SetNoiseType(NoiseType_Perlin);
	noiseLite.SetFractalType(FractalType_Ridged);
    
    //set noise params
    noiseLite.SetFrequency(0.01);
    noiseLite.SetFractalGain(0.5);
    noiseLite.SetFractalOctaves(7);
    noiseLite.SetFractalLacunarity(1.0/1.75);
    noiseLite.SetFractalWeightedStrength(2);
```
* 平原/丘陵/极地：perlin + domain wrapping
* 电路板：domain wrapping
* **河流**: Voronoi图
	* 交互：确定最小初始高度，随机河流源头，梯度下降，erosion生成流域图
	* 非交互：
* [植被](http://www-cs-students.stanford.edu/~amitp/game-programming/polygon-map-generation/demo.html) （温度、湿度、高度）
	* 到水源的距离确定湿度
	* 基于密度图的植被放置方法
	* 三种噪声分别对应三个因素
* 道路
	* 贝塞尔曲线，Catmull-Rom曲线
* 城市

[在地图上生成蜿蜒河流的两种方法](https://www.gameres.com/862595.html)
[Polygonal Map Generation for Games](http://www-cs-students.stanford.edu/~amitp/game-programming/polygon-map-generation/)

## 地形平滑

[Gaussian filter](https://www.geeksforgeeks.org/gaussian-filter-generation-c/)

bi-linear interpolation

对voxel中的data进行滤波

[voxel terrain storage](https://zeux.io/2017/03/27/voxel-terrain-storage/)

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

## 物理相关
### raytracing

[Raytracing on a grid](http://playtechs.blogspot.com/2007/03/raytracing-on-grid.html)

## 同roblox的比较[Roblox-StudioTools](https://github.com/Roblox/Studio-Tools)

### 笔刷+水材质，以下terrain表示非水材质的地形

* **增加/生长** 
	* 水：先减少terrain，后增加水
	* terrain: 可在水上定位，但忽略水，直接增加terrain
* **减少/侵蚀** 
	* 已有水不受影响，先减少terrain，当减少部分有水时，水不做减少，原来要减少的部分替换成水
* **光滑**
	* 水和terrain同等对待
* **展平**
	* 展平terrain，当展平部分满足一定条件时，增加水
* **绘制**
	* terrain能绘制成水，不可逆
* **海平面**
	* 在一个整体范围内增加/删除所有水
	
## 性能优化
### 地形lod

* LOD减面
	* 保持最外圈的网格信息，减化内圈的网格信息 [改进的Unreal4减面算法](https://zhuanlan.zhihu.com/p/46246467)
* 边插入/删除
	* [边删除&边插入](https://blog.csdn.net/u012234115/article/details/48055399)
* **缝合** 前提：不同lod相接的地方有共同顶点
	* [缝合](https://zhuanlan.zhihu.com/p/158851901)
* [CDLOD](https://www.docin.com/touch_new/preview_new.do?id=894948728)

### 网格面简化

* 基于二次误差度量的网格简化
	* 二次度量误差（QEM，quadric error metric）指的是当前顶点到其邻域所有三角面（也称关联平面）的距离平方和。
	