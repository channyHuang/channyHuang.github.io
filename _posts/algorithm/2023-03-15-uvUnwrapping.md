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
自动展uv一般采用组合或变分（variational）方法，是一个数值优化问题。比较经典的方法有：
1. ABF (Angle Based Flattening), 
2. LSCM (Least Square Conformal Mapping), 
3. ARAP (As rigid as possible), 
4. BFF (Boundary first flattening), 
5. Variational Surface Cutting (2018)
6. OptCuts.

其中LSCM和ARAP可以参考[libigl](https://libigl.github.io/)库，VSC是在BFF上进行改进的算法。

## Xatlas库原理  
一般分为三大步骤：处理网格数据、计算charts和打包charts。
```c++
xatlas::AddMesh
xatlas::ComputeCharts
xatlas::PackCharts
```
计算charts时开启线程，对每个chartGroup调用computeCharts
```c++
runMeshComputeChartsTask -> runChartGroupComputeChartsTask -> 
```

```c++
ChartGroup.computeCharts
	runCreateAndParameterizeChartTask
```

# 参考资料
[xatlas](https://github.com/jpcy/xatlas)