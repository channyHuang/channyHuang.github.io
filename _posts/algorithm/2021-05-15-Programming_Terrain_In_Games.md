---
layout: default
title: Noise_Terrain_Generation.md
categories:
- Algorithm
tags:
- Game
---
//Description: 程序化地形生成 Programming Terrain Mesh Generation

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
	1. 根据输入的biome_size，把整块地形近似分割成biome_size方块，每个方块随机使用不同的地貌
	2. 对每个区域生成对应地貌
		1. 噪声生成主地貌
			* x-z遍历，目标单位立方体中，与其相邻的9个立方体（包括其本身）各自使用噪声产生一个数值（占有率），一个地貌index，同时记录其与目标立方体中随机点的距离
			* 对上面9个立方体各自生成权重参数
			* 在y即高度上，根据当前高度与总高度比值，排除上下固定地形（空气和地基），根据地貌修正占有率，及地表面和地里面的材质
				* 水平面
				* 平原：草地 + 石头 + 水
				* 沼泽：草地 + 泥 + 浆 + 水
				* 山地：草地 + 泥
				* 沙丘：沙 + 沙石
				* 熔岩：岩浆 + 岩浆岩 + 石头
				* 冰川：雪 + 冰
				* 峡谷：泥 + 水 + 浆
				* 龟裂：voronoi图
			* 根据ridge噪声生成洞穴，即判断当前立方体是否为洞穴，是则占有率置0
			* 根据地貌和高度设置温度，根据地貌设置湿度
		2. 地形边界平滑处理，噪声参数+权重
	3. 地形生态根据区域随机生成（erosion侵蚀，高度决定植被）
2. 机器学习
	1. 输入点、线、面作为地形高度、生态类型参考，算法生成具体生态
	2. 生态笔刷

## 地形数据生成
1. 把地形区域按整数划分成单位立方体，使得每个单位立方体的顶点的三维坐标都是整数
2. 对每一个单位立方体顶点，根据需要的地形计算该顶点所在位置的三维有向距离场(Signed Distance Field，简称SDF)。其中SDF的定义为：当前位置与距离当前位置最近的地形之间的距离，正数表示该位置朝向地形正面（地形表面），即在地形外面，负数表示该位置朝向地形里面，即在地形里面。  
一些基本的SDF计算方法：  
生成一个球心在c(cx, cy, cz)半径为r的球形地形：点p(x, y, z)的sdf = (x - c).length() - r。  
生成一个中心在c(cx, cy, cz)边长为s的正方体地形：记v(vx, vy, vz) = (p - c ) - 0.5 * s; 则点p(x, y, z)的sdf = v.length() + min(0, max(vx, vy, vz))。  
其中对于任一三维向量v(vx, vy, vz)，v的长度 v.length() = sqrt(vx * vx + vy * vy + vz * vz)。
3. 对每一个在地形外部的顶点，其SDF值为正数，其材质为空气。而对于每一个在地形内部的顶点，其SDF值为负数（即在地形里面的点），根据需要设置材质。材质分为四种：1) 规则材质（砖块、木板等）、2) 半规则材质（路面、冰、玄武岩等）、3) 不规则材质（沙、泥土、草等），4) 水材质，分别对应生成方块网格、带棱角的网格、及光滑的网格。水材质需要单独考虑，是因为生成网格时需要考虑水面和水底（大陆架）两层，而其它材质只需要生成一层。
4. 对每个单位立方体的顶点，用tag = {1, 2, 3}表示该顶点是空气、水、其它材质。

## Noise type 噪声分类

[**fastnoise library**](https://github.com/Auburn/FastNoise) - a noise library contains most of classical noise

* single noise 
	* Lattic based 基于晶格的方法
		* Gradient noise
			* [**Perlin noise**](https://mrl.cs.nyu.edu/~perlin/noise/)
			* Simplex noise
			* Wavelet noise
		* Value noise
	* Point based 基于点的方法
		* Worley/Cell noise - Voronoi diagram
* [fractal noise](https://thebookofshaders.com/13/?lan=ch) 频率+振幅
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

## 三角网格生成
1. 考虑到地形可能很大，从计算机角度看一次性直接计算所有数据容易造成内存和cpu不够用。故把整个地形分割成若干块，每个块为包含19 * 19 * 19个单位立方体的大立方体。先对每个块生成三角形网格，再对所有块进行合并 
2. 对每个块中的每个单位立方体，判断该单位立方体的8个顶点对应的SDF值是否同号；
如果8个顶点同号且tag相同，即顶点SDF值均为正数或均为负数，且tag均为同一类，则说明该单位立方体要么全部位于地形外部，要么全部位于地形内部，不产生地形网格；
如果8个顶点异号或tag不相同，即其中至少有一个正数和一个负数，或tag包含两种类别以上，则说明该单位立方体有地形表面经过，需要产生地形网格。不同的tag保证了水和陆地相接触的立方体也能生成网格，即大陆架网格。
3. 对每一个需要产生地形网格的单位立方体，记顶点的三维坐标位置e(ex, ey, ez)，8个顶点的三维坐标位置$e_i(ex_\{i}, ey_\{i}, ez_\{i})$，其中i = [1, 8]，每个顶点的SDF值sdf_\{ei}，计算该单位立方体生成的网格顶点的位置p(px, py, pz) = \sum (e_i * sdf_\{ei}), i = 1...8。
4. 根据材质调整生成的网格顶点的位置。对于生成该网格顶点的8个单位立方体顶点，如果存在至少一个顶点的材质为规则材质，则表示需要生成方块地形，则把该网格顶点移到该单位立方体的中心点；如果存在至少一个顶点的材质为半规则材质，则表示需要生成带棱角的网格，则需要根据每种材质的光滑程度[0,1]，对该顶点进行一定的位移。例如：玄武岩的光滑程度为0.3，记生成的网格顶点坐标位置为q(x, y, z)，则先对单位立文体左下角的顶点p取哈希值得到偏移坐标值offset(ox, oy, oz)，再把生成的网格顶点坐标位置q + offset得到最终的网格顶点坐标位置。为了计算方便，如果偏移后得到的坐标位置超出了该单位立方体，则需要移回到立方体内部。
4. 连接相邻单位立方体的顶点生成三角形网格。对于每一个块中的每一个单位立方体顶点p(x, y, z)，检测p1(x + 1, y, z), p2(x, y + 1, z) 和 p3(x, y, z + 1)三个相邻的顶点，如果p和p_i的tag不相同，则把这几个单位立方体对应生成的网格顶点连接成三角形网格。
例如：单位立方体顶点p(x, y, z)和p1(x + 1, y, z)的tag不相同，则单位立方体b(x, y, z)和b2(x，y + 1, z)和b3(x, y, z + 1)和b23(x, y + 1, z + 1)四个单位立方体对应生成的网格顶点bp、bp2、bp3和bp23连接成两个三角形(bp, bp2, bp23)和(bp, bp23, bp3)
5. 计算生成的每个三角形面的法线，再根据材质类型计算每个三角形顶点，即网格顶点的法线，用于渲染出棱角。对于一个网格顶点，如果生成该网格顶点的单位立方体8个顶点中，存在至少一个顶点的材质为非规则材质或水，则网格顶点不共用法线，即每个三角形面的顶点有自己的法线，即为该三角形面的法线；否则网格顶点共用法线，即如果两个三角形面有一个共同的顶点，则该顶点的法线为两个三角形面的法线的平均值。
6. 生成LOD（Level of Detail）网格。渲染对于近处和远处需要呈现的细节不同，故远处的三角形网格可以比近处的三角形网格稀疏。

### 网格生成算法调研  
体素顶点的sdf (signed distance function) 值表示该顶点到目标网格面的最近距离，如果目标网格面是封闭的，sdf<0表示该顶点在网格面内部，>0表示在网格面外部

1. **Marching Cube (MC)**  
	**基本流程：**  
	一个体素一条边的数值决定点的位置（在体素边上）。如一条边如果两个点的值分别为p1=v1和p2=v2（v1*v2<=0），则生成的点在p1-v1*(p2-p1)/(v2-v1)上。一个体素生成的面只有16种情况。  
	**优势：**  
	* 经典，能够满足大部分使用场景
	* 查表，效率高  
	**劣势：**
	* 所有顶点都生成在voxel的边上，有限制
	* 有二义性（如右图点的不同连接方式），导致在特殊情况下会有裂缝
	* 只能生成光滑的曲面，无法处理尖锐的棱角情况  
1. **Dual Marching Cube (DMC)**  
	**基本流程：**  
	MC的改进，体素顶点不是sdf值，而是Hermite data。其它同MC。  
	**优势：**  
	同MC  
	**劣势：**  
	同MC  
1. **Transvoxel**  
	**基本流程：**  
	同MC。在MC的基础上解决MC的二义性产生的裂缝。  
	**优势：**  
	在MC的基础上解决了MC的二义性问题  
	**劣势：**  
	同MC  
1. **Dual Contouring (DC)**  
	**基本流程：**  
	根据最小化二次误差函数生成顶点。误差函数E(x)=∑_i▒(n_i∙(x−p_i))^2。对每个voxel的8个顶点p_i，n_i为该顶点对应于目标网格面的法向，x为最终生成的点的位置。  
	**优势：**  
	能够处理MC不能处理的尖锐的棱角情况。有法线信息做为输入，能够生成精确度高的网格，并可根据法线进行调整。  
	**劣势：**  需要已知法线信息做为输入，通常适用于工业零件建模、或由Perlin噪声生成的不可变地形网格生成（Perlin噪声在生成地形的同时可以获取对应点的法向）  
1. **Surface Nets**  
	**基本流程：**  
	对体素的8个顶点的sdf值与体素顶点位置做加权平均。每个voxel最多只生成一个顶点。  
	**优势：**  
	生成的顶点可以在voxel内部或边上任意位置，没有MC点在voxel边上的限制，也没有DC需要法线作为输入的限制，生成的曲面类型比较丰富。  
	**劣势：**  
	每个voxel最多只生成一个顶点，无法满足像地形粗糙类需要网格细分的需求（voxel体素通用劣势）。

## Voxel数据存储

每个数组元素（Voxel）保存的不再是高度值，而是一个近似的距离值（iso-value）或密度值SDF，表示这个点有多大程度在土地里或暴露在空气中。

[SDF](https://github.com/fogleman/sdf.git)
[distfunctions](https://iquilezles.org/www/articles/distfunctions/distfunctions.htm)

### 3D 等值面提取/网格重建

* [Marching Cubes](http://paulbourke.net/geometry/polygonise/)
* Marching tetrahedra (2D) - Marching Cube (3D)
* Dividing Cubes
* Dual Contouring (Hermite data) 根据法线最小化误差函数求得点所在的坐标，每个inside的voxel顶点对应生成一个点，法线可指定 [DC](https://www.cse.wustl.edu/~taoju/research/dualContour.pdf)
* [Transvoxel](http://transvoxel.org/) MC的改进
* Naive Surface Nets [SurfaceNets](https://link.springer.com/content/pdf/10.1007%2FBFb0056277.pdf)
* Poisson
* Dual Marching Cubes [dmc](https://www.cs.rice.edu/~jwarren/papers/dmc.pdf)

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
#### 属性
笔刷形状：圆平面、正方形平面、球体、立方体、圆柱体......
笔刷大小：1不一定有效，因为一个单位立方体最多只生成一个点，一个点不足以表示复杂多面体
材质：自动材质
锚点：鼠标打到地形表面的点处于形状的位置
锁定平面：是否根据地形表面的法线确定笔刷平面是垂直于法线还是保持鼠标刚点下时所在的平面不变
锁定方向：增长/侵蚀特有
强度：
#### 操作
* **增加/生长** 
	* 如果笔刷大小比较小（<=2），稍微放大笔刷（+0.5），否则按原大小笔刷改变细微，肉眼可能看不出来
	* 根据形状计算形状内外的单位立方体的占有率occupancy
	* 如果是自动材质，根据笔刷方向，反向选择对应立方体的材质
	* 如果当前已有地形，比较占有率，新占有率大则更新原占有率；如果当前没有地形，赋值占有率和材质
	* 如果忽略水：先减少terrain，后在减少的位置上顺延增加水
	* terrain: 可在水上定位，但忽略水，直接增加terrain
* **减少/侵蚀** 
	* 如果笔刷大小比较小（<=2），稍微放大笔刷（+0.5），否则按原大小笔刷改变细微，肉眼可能看不出来
	* 根据形状计算形状内外的单位立方体的占有率occupancy
	* 如果当前已有地形，直接更新占有率和材质（空气），如果当前没有地形，比较占有率，新占有率小则更新原占有率
	* 已有水不受影响，先减少terrain，当减少部分有水时，水不做减少，原来要减少的部分替换成水
* **光滑**
	* 取当前单位立方体和周围8个立方体的占有率，作平均
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

[Simplify Surface](https://www.ri.cmu.edu/pub_files/pub2/garland_michael_1997_1/garland_michael_1997_1.pdf)
	
# reference
[天美F1引擎专家：如何利用PCG技术加速大世界地形生产](https://mp.weixin.qq.com/s/G-GEXc5J-Fb8S5xAmYDI0A)
[Virtual Terrain](http://vterrain.org/)