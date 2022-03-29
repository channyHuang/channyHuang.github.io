<head>
    <script type="text/x-mathjax-config">
    MathJax.Hub.Config({ TeX: { equationNumbers: { autoNumber: "all" } } });
    </script>

    <script type="text/x-mathjax-config">
    MathJax.Hub.Config({tex2jax: {
             inlineMath: [ ['$','$'],["$$","$$"], ["\\(","\\)"] ],
             processEscapes: true
           }
         });
    </script>

    <script src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML" type="text/javascript">
    </script>
</head>

---
layout: default
title: Math In Physics Engine Bullet And Solver
categories:
- Game
tags:
- Game
---
//Description: Math In Physics Engine Bullet And Solver, 物理引擎库Bullet中的数学和求解器

//Create Date: 2022-03-23 15:32:39

//Author: channy

# 概述 
物理引擎库Bullet中的数学和求解器。以bullet3为例。

# 求解器
求解方程组 Ax = b, 其中A为n阶方阵，x和b均为n维列向量。该方程组有唯一解当且仅当矩阵A满秩。

## LCP/MLCP 求解  
### Gauss-Seidel (GS迭代求解法)  
Gauss-Seidel迭代求解方程 Ax = b  
**问题描述**  
Ax + b >= 0
x >= 0
x^T (Ax + b) = 0

**步骤**  
矩阵A可以被分割为 A = D - L - U, 其中D是对角矩阵，L是左下部分矩阵

得 $$ x_{k+1} = (D - L)^(-1) U x_{k} + (D - L)^(-1) b $$

通过Gauss-Seidel迭代求线性互补问题(LCP)的解，要求A是正定阵或者主元占优矩阵。

![Gauss-Seidel](./imageFormat/Gauss-Seidel-bullet.png)

### Mixed Linear Complementarity Problem (MLCP迭代求解法)  
**问题描述**  
w = Ax + b
v_lo <= x <= v_hi

**步骤**  
记 z^k = (D - L)^(-1) U x^k - (D - L)^(-1) b

得 x^(k+1) = max(min( (x_(hi))_i, z^k), (x_(lo))_i)

## 原理  
### Gauss-Seidel 算法

![Gauss-Seidel](./imageFormat/Gauss-Seidel.png)

把矩阵A拆成下三角L + 上三角U + 对角线D，则有
(L + U + D) x = b, 即
D x = b - (L + U)x，根据该式设计
x_(k + 1) = [b - (L + U) x] / D

### Projected Gauss-Seidel (PGS迭代求解法)  
PGS方法和GS方法的区别仅仅在于，PGS在每次迭代后会将 \lambda 截断到一个给定范围内。

令 c^k = b - U x^k

得 x^(k+1) = max(0, ((D - L)^(-1) U x^k - (D - L)^(-1) b)_i)

每次迭代过程中，所得x^(k+1)每一个分量的值都会被截断 

当矩阵 A 是正定矩阵的时候，PGS可得严格被证明为收敛
### Lemke (互补枢轴算法)
由原始单纯形法改进而来，主元消去法，由一个准互补基本可行解出发，通过主元消去法（转轴方法）求出一个新的准互补基本可行解，不断迭代。可能求解失败。

1. 按照最小比值规则确定离基变量
1. 保持准互补性，若w_i(z_i)是离基变量，则z_i(w_i)是进基变量

**步骤**
1. 若q >= 0, 则(w, z) = (q, 0)为解，否则
取max{-q_i}所在的行s行为主行，z_0对应的列为主列，主元消去，令y_s = z_s
2. 设现行表中变量y_s下面的列为d_x，若d_x <= 0，退出；否则按最小比值规则确定指标r，使  
q_i / d_is = min{q_i / d_is, d_is > 0}  
如果r行的基变量是z_0，转4；否则转3
3. 设r行的基变量为w_l或z_l (l != s)，y_s进基，以r行为主行，y_s对应的列为主列，主元消去。如果离基变量是w_l，则令y_s = z_l；如果离基变量是z_l，则令y_s = w_l，转2  
4. y_s进基，z_0离基。以r行为主行，y_s对应的列为主列，主元消去。得可行解，退出

**说明及改进**
1. 只满足于一个互补可行解  
2. 收敛条件强  

### Dantzig-Wolfe算法
暂未找到算法原理，只知道同样基于换基消元法

### SOR (Sucessive Over Relaxation Method) 算法
GS方法是SOR方法的特例
松弛因子(relaxation factor)
选择适当的松弛因子能使收敛的Gauss-Seidel迭代法获得加速收敛的效果
## bullet3 中的 MLCP 求解器 solveMLCP 
btMLCPSolverInterface.solveMLCP

四类 Solver 直接继承 btMLCPSolverInterface，具体求解过程在solveMLCP中。  

* btSolveProjectedGaussSeidel (PGS) 
	* solveMLCP (btSolveProjectedGaussSeidel) 根据算法公式直接求x_{k + 1}
* btDantzigSolver (Dantzig)
	* solveMLCP (btDantzigSolver)
		* btSolveDantzigLCP
			* btFactorLDLT
				* btSolveL1_2 // L * X = B, B有2列；block=2*2；其中L为n*n的行优先存储的对角线为1的下三角矩阵，leading dimension为lskip1，B为n*2的列优先存储的矩阵，leading dimension为lskip1，返回值覆盖B
				* btSolveL1_1 // L * X = B, B有1列；block=2*2；其中L为n*n的行优先存储的对角线为1的下三角矩阵，leading dimension为lskip，返回值覆盖B
			* btSolveLDLT
				* btSolveL1 // L * X = B, B有1列；block=4*4；
				* btVectorScale // a[i] scale d[i]
				* btSolveL1T // L^T * x = b; block=4*4
			* btLCP.solve1
				* btSolveL1
				* btSolveL1T
			* btLCP.unpermute 
* btLemkeSolver (Lemke)
	* solveMLCP (btLemkeSolver)
		* btLemkeAlgorithm.solve
			* findLexicographicMinimum 查找主元
			* GaussJordanEliminationStep Gauss-Jordan消元法
	z0 = max{-q_i}
* btPathSolver //未启用，缺少头文件 

# 参考文献
[Physics-Based Animation](https://www.researchgate.net/profile/Kenny-Erleben/publication/247181209_Physics-Based_Animation/links/5e1b2ed04585159aa4cb43d8/Physics-Based-Animation.pdf)
[Lemke-Howson Algorithm](https://web.stanford.edu/~saberi/lecture4.pdf)
[Iterative Dynamics with Temporal Coherence](https://box2d.org/files/ErinCatto_IterativeDynamics_GDC2005.pdf)
[Practical methods of optimization] by Fletcher R.