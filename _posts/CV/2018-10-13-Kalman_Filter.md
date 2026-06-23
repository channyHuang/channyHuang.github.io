---
layout: default
title: Kalman_Filter
categories:
- Algorithm
tags:
- Computer Vision
- Filter
---
//Description: 用自己的话理解Kalman滤波

//Create Date: 2018-10-13 17:24:28

//Author: channy

<head>
    <script src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML" type="text/javascript"></script>
    <script type="text/x-mathjax-config">
        MathJax.Hub.Config({
            tex2jax: {
            skipTags: ['script', 'noscript', 'style', 'textarea', 'pre'],
            inlineMath: [['$','$']]
            }
        });
    </script>
</head>

# Kalman_Filter

有人看不懂，可能是因为不清楚已知的变量有哪些

PS：写推导过程最好先将已知量、求解量先列出来，不建议推导过程中突然冒出个变量，不知道是已知的还是由什么推导出来的这个变量

## 已有变量

状态值 $\vec{x_k} = (\vec{p}, \vec{v})$, 状态中的变量都服从`Gauss`分布$N(\mu, \sigma^2)$

协方差矩阵 $$P_k = 
\left[
\begin{matrix}
\Sigma_{pp} & \Sigma_{pv} \\ 
\Sigma_{vp} & \Sigma_{vv} \\
\end{matrix}
\right]$$, $\Sigma_{ij}$状态中的变量相关关系

预测矩阵 $F_k$, 预测从当前状态转移到下一状态

控制矩阵 $B_k$

控制向量 $\vec{u_k}$

控制噪声协方差 $Q_k$

最佳估计值 $\hat{x_k}$

测量值 $\vec{z_k}$

测量数据的变量间的协方差矩阵$H_k$

测量噪声$R_k$

假设变量有两个，用到的有两个`Gauss`分布、预测分布（即两个分布融合后的分布）和测量分布$(\mu_1, \Sigma_1) = (\vec{z_k}, R_k)$

也就是说，上面的变量除最佳估计值$\hat{x_k}$外都是已知的

## 理论推导

如果$x$的协方差矩阵是$Cov(x) = \Sigma$, 那么$Ax$的协方差矩阵是$Cov(Ax) = A\Sigma A^T$

所以

$$ \hat{x}_k = F_k \hat{x}_{k-1} + B_k \vec{u_k}\$$

$$ P_k = F_k P_{k-1} F_k^T + Q_k$$

`Gauss`分布融合后还是`Gauss`分布，可知卡尔曼增益 

$$K = \Sigma_0 (\Sigma_0 + \Sigma_1)^{-1}$$

$$\vec{\mu}^{'} = \vec{\mu_0} + K(\vec{\mu_1} - \vec{\mu_0}) $$

$$\Sigma^{'} = \Sigma_0 - K \Sigma_0 $$

记预测分布$(\mu_0, \Sigma_0) = (H_k \hat{x}_k, H_k P_k H_k^T)$, 测量分布$(\mu_1, \Sigma_1) = (\vec{z_k}, R_k)$

可求得
$$K = H_k P_k H_k^T + R_k)^{-1}$$

最终得到更新方程

$$\hat{x}_k^{'} = \hat{x}_k + K^{'} (\vec{z_k} - \hat{x}_k)$$

$$P_k^{'} = P_k - K^{'} H_k P_k$$

$$K^{'} = P_k H_k^T (H_k P_k H_k^T + R_k)^{-1}$$

## Reference
[How a Kalman filter works, in pictures](http://www.bzarg.com/p/how-a-kalman-filter-works-in-pictures/)

---

[back](./)

