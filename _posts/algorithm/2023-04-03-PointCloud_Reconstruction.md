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

***
<font color = red> 传统方法 </font>
***

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
针对点云中的每一个点，搜索最近的k个邻近点组成邻近点集${P_i}$，计算该点到邻近点集合中每个点的距离的均值和标准差；如果该点在预先设置的标准差范围内，则保留该点否则去掉。
## Radius Outlier removal
设定一个搜索半径，判断目标点在设定半径范围内的相邻点数目，设定阈值范围
## Conditional removal
自定义一个过滤的condition，对目标点云进行特定点的移除
## passthrough
直通滤波（passthrough filter)操作相对粗暴，针对自定义的点的类型，对 X、Y、Z、R、G、B…等等各纬度进行内外点的界定

<font color = cyan> 对于无规律的点云，上述算法效果并不理想。特别是对于杂乱且密度不一致的点云，外围点剔除效果并不好，甚至不如聚类后取最大的类。 </font>

# Simplify
各种滤波，包括高斯滤波、体素滤波、均值滤波等等。
## Grid Simplify
把点云空间分割成单位立方体，对每个单位立方体内的点只取其中一个（随机、重心等），其它点舍弃。
## WLOP Simplify (Weighted Locally Opti-mal Projection)

## Hirarchy Simplify
对点云中的点计算聚类重心，

<font color = cyan> 点云简化目标是为了减少不必要的计算量，但有可能以降低精确度为代价。在精确度没达到的前提下，不建议使用。 </font>

# Smooth
## JET Smooth
## Bilateral Smooth

<font color = cyan> 肉眼看不出明显区别。 </font>

# Normal Estimation
## JET 
不估计朝向
## PCA
不估计朝向
## MST
最小生成树算法。在有法向量的基础上修正法向量朝向
## VCM
利用扫描点的特征--视线估计法向量朝向
最小二乘法 (MLS)，2阶多项式

<font color = cyan> CGAL中有上面四种算法，但从实际计算结果看，各种组合都没有VcgLib中的法向量估计算法好。 </font>

# Reconstruction 重建三维网格
## Possion重建（2006）
需要法向量作为输入，保证重建生成的曲面封闭。不对输入点云进行插值，重建的曲面严格经过输入点。  
通过拟合隐式函数确定网格面。设目标曲面函数$F(x)$，使得$F(x)$在每个点$p$处的梯度值即为该点的法向量$n$，即最小化误差函数$min {|F - \nabla n|}^2$  

<font color = cyan> Possion重建在2020年有论文发表有新改进，对误差函数增加了一项，且增加了包围盒，能够避免为了封闭强行扩展表面的问题。 </font>

## Advancing Front surface reconstruction
先把点云空间进行Delaunay三角剖分，然后根据法向量使用优先队列选择最适合的面逐步扩展直到所有面连接。
## Scale Space
对点云进行缩放，如使用平滑滤波器进行平滑得到弱化了细节的点云，从而得到两个不同细节的网格，再根据初始点云对网格进行插值，逐步逼近点云。
## 其它算法
凸包重建、凹包重建

# Post Processing
## hole filling
## mesh smooth

***
<font color = red> 神经网络方法 </font>
***

# NeRF
$$(\theta, \phi, r, g, b) -> (x, y, z, a)$$
根据输入的多角度RGB图像和对应的摄像机参数，建立两个MLP分别求解三维空间中网格点的alpha和RGB值
## [instant-ngp](https://github.com/NVlabs/instant-ngp) 
* 输入数据：多角度RGB图像序列
* 预处理：每幅图像对应的摄像机参数
* 输出：点云数据
### instant-ngp具体步骤
1. 把可能的整个目标区域划分成多个单位立方体网格，整数点为网格顶点
1. 根据输入数据使用Nerf训练每个网格顶点的可见度alpha：(u,v,r,g,b)->(x,y,z,alpha)
1. 根据输入数据使用Nerf训练每个网格顶点的RGB颜色值
1. 根据SDF生成模型网格
### instant-ngp翰入数据对结果的影响分桥
1. 图像数量
在角度包含360度全方位的情况下，更多的图像数量对结果没有明显影响
1. 图像分辨率
把原分辨率3080x2160的图像降成1920x1080，对结果没有明显影响
1. 图像清晰度
直接影响到结果的精确度

### colmap2nerf 计算摄像机参数
可使用colmap稀疏重建计算，再通过./scripts/colmap2nerf.py进行格式转换
```
python ./scripts/colmap2nerf.py --aabb_scale 128 --run_colmap --images ./images

python ./scripts/colmap2nerf.py --video_in D:/dataset/lab/IMG_0080.MOV --video_fps 30 --run_colmap --aabb_scale 128

instant-ngp.exe ./data/fox
```
### video2picture
```
ffmpeg.exe -i "D:/dataset/lab/IMG_0080.MOV" -qscale:v 1 -qmin 1 -vf "fps=30.0" "D:/dataset/lab/images"/s04d.jpg
```
### colmap2nerf steps
1. 特征点检测，SIFT特征
```
COLMAP.bat feature_extractor --ImageReader.camera_model OPENCV --ImageReader.camera_params "" --SiftExtraction.estimate_affine_shape=true --SiftExtraction.domain_size_pooling=true --ImageReader.single_camera 1 --database_path colmap.db --image_path "./images"
```
1. 特征点匹配
```
COLMAP.bat sequential_matcher --SiftMatching.guided_matching=true --database_path colmap.db
```
* exhaustive_matcher 全局匹配
* sequential_matcher 序列匹配
* spatial_matcher
* vocab_tree_matcher
1. 计算机摄像机参数进行稀疏重建
```
COLMAP.bat mapper --database_path colmap.db --image_path "./images" --output_path ./colmap_sparse
```
输出sparse文件夹，包含摄像机参数和稀疏点云
* mapper
* hierarchical_mapper 
1. 输出稀疏重建model结果为txt格式
```
COLMAP.bat model_converter --input_path colmap_sparse/O --output_path colmap_text --output_type TXT
```
可能会生成多个mode1， 可使用model_merger合并，但不一定成功。只有当两个model间有相同图像时才能合并。
```
COLMAP.bat model_merger --input_path1 colmap_sparse/O --input_path2 colmap_sparse1 --output_path colmap_sparse/01

COLMAP.bat bundle_adjuster --input_path colmap_sparse/01 --output_path colmap_sparse/01new
```
1. 转化成nerf格式
```
./colmap2nerf.py --aabb_scale 128 --images ./images --text ./colmap_text --out ./transforms.json
```
### 稠密重建
colmap稠密重建需要GPU，使用cuda
1. 图像去畸变
```
COLMAP.bat image_undistorter --image_path ./images --input_path ./colmap_sparse/0 --output_path ./dense --output_type COLMAP
```
输出dense文件夹
```
COLMAP.bat patch_match_stereo --workspace_path ./dense --workspace_format COLMAP --PatchMarchStereo.geom_consistency true
```
输出dense/stereo文件夹，估计每张图像的depthMap和NormalMap
1. 融合
```
COLMAP.bat stereo_fusion --workspace_path ./dense --workspace_format COLMAP --input_type geometric --output_path ./dense/result.ply
```
输出点云模型
### instant-ngp源码说明
* load_nerf 读取输入数据返回NerfDataset，支持多种图像格式
* sharpness_discard_threshold 图像清晰度阈值
* Testbed::train
    * training_prep_nerf 更新density的MLP
        * generate_grid_samples_nerf_nonuniform
    * train_nerf
        * train_nerf_step
            * generate_training_samples_nerf 对每幅图像随机取点生成射线Ray，计算射线与aabb的交点并在期间进行采样得到采样点
            * compute_loss_kernel_train_nerf 计算射线逐点积分，同时维护MLP中的loss
            * forward/backward 训练MLP，更新RGB

## MLP多层感知器基础
### Loss 损失函数 L(Y, f(x))
衡量估计值地f(x)和真实值Y之间的误差，即代价函数（无监督）或误差函数（有监督）。forward后计算Loss进行backward。
> Huber 损失函数 $\frac{1}{2} |Y - f(x)|^2, |Y - f(x)| < \delta; \delta |Y - f(x)| - \frac{1}{2} {\delta}^2$  
> L1 损失函数 $\sum | Y - f(x) | $  
> L2 损失函数 $\sqrt{ \frac{1}{n} \sum |Y - f(x)|^2 }$  
> MSE 圴方误差函数 $\frac{1}{n} \sum |Y - f(x)|^2$  
### Optimizer 优化器
backward过程中，指引参数更新使得损失函数最小化
> GD 梯度下降  
> Adam、  
> AdaGrad 自适应学习率  
> RMSProp 
### Learning rate 学习率  
参数更新 $w_n = w_0 - \delta w^{'}_0 $，
> 轮数衰减：一定步长后学习率减半  
> 指数衰减：学习率按训练轮数增长指数插值递减等  
> 分数衰减：$ \delta_n  = \frac{\delta_0}{1 + kt}$
### Activation 激活层
把神经网络中上下层的线性组合关系增加非线性变换
> ReLU 修正线性单元（Rectified Linear Unit）  
> Sigmoid $\frac {1} {1 + e^{-x}} $  
> Tanh 双曲正切激活函数
### EMA 指数移动平均（Exponential Moving Average）
取最后n步的平均，能使得模型更加的鲁棒
### Decay 学习率衰减因子
Exponential / Logarithmic

***
<font color = red> 其它笔记 </font>
***

# 附录1: 编译遇到的问题
* 使用CGAL过程中转Debug编译，报
```
fatal error C1128: number of sections exceeded object file format limit : compile with /bigobj
```
vs中，可properties(属性) -> Configuration Properties(配置属性) -> C/C++ -> Command Line(命令行) -> Additional options(其他选项)，加上 /bigobj属性重新编译。

# 参考库
[cgal](https://github.com/CGAL/cgal.git)  
[glfw](https://github.com/glfw/glfw)  
[glew](https://github.com/nigels-com/glew/releases/download/glew-2.2.0/glew-2.2.0.zip)
[RGB-D重建](https://blog.51cto.com/u_14439393/5748486)
[点云重建](https://github.com/PRBonn/puma)
