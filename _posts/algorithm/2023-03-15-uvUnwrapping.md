---
layout: default
title: UV unwrapping 自动展uv
categories:
- Algorithm
tags:
- Game
---
//Description: 自动展uv的算法分析。自动展uv一般采用组合或变分（variational）方法，是一个数值优化问题。即裁剪切割网格模型，使得展开后的扭曲度最小化。

//Create Date: 2023-03-15 20:40:39

//Author: channy

[toc]

# 概述  
自动展uv一般采用组合或变分（variational）方法，是一个数值优化问题。  
主要算法一般分为两大类：固定边界法和活动边界法。其中固定边界法通过指定网格的边界顶点的参数值固定在一个凸多边形上（一般为纹理矩形或圆形），然后对内部顶点的参数值进行求解（如通过重心坐标系）。活动边界法则根据网格特点通过一定的方式计算出来。  
比较经典的方法有：LSCM、ARAP等。  
其中LSCM和ARAP可以参考[libigl](https://libigl.github.io/)库，VSC是在BFF上进行改进的算法。

## LSCM (Least Square Conformal Mapping)
活动边界法。  
共形映射（Conformal Map ）的直观几何特点就是，参数域上一个圆，映射到曲面的切平面上依然是一个圆（只是进行了旋转，平移，和等比缩放）。  

根据Cauchy-Riemann公式
$$N(u,v) \times \frac{\partial x}{\partial u} = \frac{\partial x}{\partial v}$$
可以表示为
$$\frac{\partial x}{\partial u} - i \frac{\partial x}{\partial v} = 0$$
$$\frac{\partial u}{\partial x} + i \frac{\partial u}{\partial y} = 0$$
网格参数化目标是让它尽可能的满足共形映射，于是我们提出一个共形能量，每个三角形的共形能量为：
$$C(T) = \int_T {|\frac{\partial u}{\partial x} + i \frac{\partial u}{\partial y}|}^2 dA $$
每个三角形内部的梯度都为常数

## Matric Distortion
$$f(u,v) -> (x,y,z)$$
切平面是一个3x2的雅可比矩阵
$$J_f = \frac{\partial (x,y,z)}{\partial (u,v)} = [f_u, f_v]$$
对其进行SVD分解，可得$$J_f = U \sum V^T$$，$\sum$相当于在u和v方向上分别伸缩$\sigma_1$和$\sigma_2$

## BFF (Boundary first flattening)  
先确定边界，然后进行内部flatterning.  
保持复数特殊性 $$f(z) = u(z) + i v(z), z = x + i y$$
本质上uv坐标系相对xy坐标系变换是一个旋转加等比缩放的矩阵，符合共形映射的特点。
$$\frac{\partial u}{\partial x} = \frac{\partial v}{\partial y}, \frac{\partial u}{\partial y} = -\frac{\partial v}{\partial x}$$

调和函数
$$\Delta u = \triangledown(\triangledown u) = \frac{\partial \frac{\partial u}{\partial x}}{\partial x} + \frac{\partial \frac{\partial u}{\partial y}}{\partial y} = \frac{\partial \frac{\partial v}{\partial y}}{\partial x} + \frac{\partial (-\frac{\partial v}{\partial x})}{\partial y} = \frac{\partial ^2v}{\partial x \partial y} - \frac{\partial ^2v}{\partial x \partial y} = 0$$

$$\Delta v = \triangledown(\triangledown v) = \frac{\partial \frac{\partial v}{\partial x}}{\partial x} + \frac{\partial \frac{\partial v}{\partial y}}{\partial y} = \frac{\partial (-\frac{\partial u}{\partial y})}{\partial x} + \frac{\partial \frac{\partial u}{\partial x}}{\partial y} = -\frac{\partial ^2u}{\partial x \partial y} + \frac{\partial ^2u}{\partial x \partial y} = 0$$

因为 f 是共形映射，意味着曲面上任意一点切平面上的任意两个切向量，映射到复平面上夹角不变，长度比例不变。用 df 表示 f 的微分形式，曲面上的一条曲线的切向量 X 映射到复平面上的切向量为 df(X)，那么：

df(JX) = idf(X)

通过共形映射找到网格对应复平面上的边界曲线，那么这条曲线的u和v之间肯定是相互约束的，否则就无法使得内部点形成调和函数。（黎曼已经证明任何和圆盘同胚的曲面都有共形映射的uv参数域）

通过边界曲线的长度（length）或曲率密度（curvature density）约束，来获取共形映射条件下的边界，通过边界来求内部顶点的uv值。

$$\begin {aligned} \left. \begin {aligned} \Delta u = K - e^{2u}\tilde {K} \; on \; M \cr \frac {\partial u}{\partial n} = k - e^u\tilde{k}\; on \; \partial M \end {aligned} \right\} && (1) \end {aligned}$$
使用此公式，可以根据缩放系数u计算出参数化后网格边界顶点处的测地曲率，根据边界的测地曲率计算出参数化后网格边界的顶点坐标；当边界确定之后，根据拉普拉斯-泊松方程或拉普拉斯-纽曼方程求解内部顶点坐标。

## Variational Surface Cutting (2018)
在三角面片上使用Eulerian numerical integrator（欧拉数值积分）

## ABF (Angle Based Flattening)

## ARAP (As rigid as possible)
对二维网格进行形变，通过计算三角网格顶点$\{v_0,v_1,v_2\}$的相对坐标$\{x_{01},y_{01}\}$使得$v_2 = v_0 + x_{01}v_0v_1 + y_{01}R_{90}v_0v_1$，最小化变化前后的误差函数$E=\sum_{i=1,2,3} {|v_i^{desired} - v_i^{'}|}^2$，最后问题转化为求解可以表示成稀疏矩阵的方程组。

## Xatlas库原理  
一般分为三大步骤：处理网格数据、计算charts和打包charts。
```c++
// 整理顶点信息和面片信息：根据连通计算mesh数
xatlas::AddMesh
// 计算charts: Planar类型为根据面的法向量点积是否接近1进行分chart
xatlas::ComputeCharts
// 打包charts
xatlas::PackCharts
```

计算charts时开启线程，对每个chartGroup调用computeCharts。其中一个mesh对应一个chartGroup。
```c++
runMeshComputeChartsTask -> runChartGroupComputeChartsTask -> 
ChartGroup.computeCharts
	runCreateAndParameterizeChartTask
```
 Planar类型通过计算面之间的法向量点积接近1.0把面放入同一个chart

# 参考资料
[xatlas](https://github.com/jpcy/xatlas)
[网格参数化原理1-9](https://www.zhihu.com/people/allan-35-49/posts)