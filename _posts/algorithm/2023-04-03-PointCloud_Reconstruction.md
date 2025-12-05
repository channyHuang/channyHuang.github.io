---
layout: default
title: PointCloud_Reconstruction
categories:
- Algorithm
tags:
- Computer Vision
---
//Description: 点云表面重建技术研究笔记。有传统多视角几何匹配方法、神经网络方法两种。

//Create Date: 2023-04-03 20:40:39

//Author: channy

[toc]

# <font color = red> 传统点云表面重建基本流程 </font>
以使用CGAL进行简单实现为例，一般步骤有：
## 1. Outlier removal  
  删除外围噪声点Outlier，即点云分割
  * **Statistical Outlier Removal filter**  
  针对点云中的每一个点，搜索最近的k个邻近点组成邻近点集${P_i}$，计算该点到邻近点集合中每个点的距离的均值和标准差；如果该点在预先设置的标准差范围内，则保留该点否则去掉。
  * **Radius Outlier removal**  
  设定一个搜索半径，判断目标点在设定半径范围内的相邻点数目，设定阈值范围
  * **Conditional removal**  
  自定义一个过滤的condition，对目标点云进行特定点的移除
  * **passthrough**  
  直通滤波（passthrough filter)操作相对粗暴，针对自定义的点的类型，对 X、Y、Z、R、G、B…等等各纬度进行内外点的界定

<font color = cyan> 对于无规律的点云，上述算法效果并不理想。特别是对于杂乱且密度不一致的点云，外围点剔除效果并不好，甚至不如聚类后取最大的类。 </font>

## 2. Simplify  
点云简化。各种滤波，包括高斯滤波、体素滤波、均值滤波等等。
* **Grid Simplify**  
把点云空间分割成单位立方体，对每个单位立方体内的点只取其中一个（随机、重心等），其它点舍弃。
* **WLOP Simplify (Weighted Locally Opti-mal Projection)**  
* **Hirarchy Simplify**  
对点云中的点计算聚类重心，

<font color = cyan> 点云简化目标是为了减少不必要的计算量，但有可能以降低精确度为代价。在精确度没达到的前提下，不建议使用。 </font>

## 3. Smooth  
点云光滑化
* **JET Smooth**  
* **Bilateral Smooth**  

<font color = cyan> 肉眼看不出明显区别。 </font>

## 4. Normal Estimation  
法向量估计  
* **JET**   
不估计朝向
* **PCA**  
不估计朝向 
* **MST**  
最小生成树算法。在有法向量的基础上修正法向量朝向
* **VCM**
利用扫描点的特征--视线估计法向量朝向

最小二乘法 (MLS)，2阶多项式

<font color = cyan> CGAL中有上面四种算法，但从实际计算结果看，各种组合都没有VcgLib中的法向量估计算法好。 </font>

## 5. Reconstruction   
重建三维网格
* **Possion重建（2006）**  
需要法向量作为输入，保证重建生成的曲面封闭。不对输入点云进行插值，重建的曲面严格经过输入点。  
通过拟合隐式函数确定网格面。设目标曲面函数$F(x)$，使得$F(x)$在每个点$p$处的梯度值即为该点的法向量$n$，即最小化误差函数$min {|F - \nabla n|}^2$  

<font color = cyan> Possion重建在2020年有论文发表有新改进，对误差函数增加了一项，且增加了包围盒，能够避免为了封闭强行扩展表面的问题。 </font>

* **Advancing Front surface reconstruction**  
先把点云空间进行Delaunay三角剖分，然后根据法向量使用优先队列选择最适合的面逐步扩展直到所有面连接。
* **Scale Space**  
对点云进行缩放，如使用平滑滤波器进行平滑得到弱化了细节的点云，从而得到两个不同细节的网格，再根据初始点云对网格进行插值，逐步逼近点云。
* **其它算法**  
凸包重建、凹包重建

## 6. Post Processing  
后处理，如补洞等
* **hole filling**  
* **mesh smooth** 

# <font color = red> 神经网络重建原理方法 </font>
$$(\theta, \phi, r, g, b) -> (x, y, z, a)$$
根据输入的多角度RGB图像和对应的摄像机参数，建立两个MLP分别求解三维空间中网格点的alpha和RGB值
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

## nerf: [instant-ngp](https://github.com/NVlabs/instant-ngp) 
* 输入数据：多角度RGB图像序列。每幅图像对应的传感器位姿[3x4矩阵]（拍摄时每幅图像对应的传感器位姿相对于首幅图像或前一幅图像对应的传感器位姿的参数--旋转R[3x3]和平移t[3x1]）
* 预处理：每幅图像对应的摄像机参数
* 输出：点云数据
* 具体步骤
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
### instant-ngp源码说明
* load_nerf 读取输入数据返回NerfDataset，支持的图像格式有
```c++
	std::vector<std::string> supported_image_formats = {
		"png", "jpg", "jpeg", "bmp", "gif", "tga", "pic", "pnm", "psd", "exr",
	};
```
```c++
Testbed::train_and_render
  Testbed::train(1<<18)
    training_prep_nerf: 更新density的MLP
      update_density_grid_nerf
        mark_untrained_density_grid 把三维空间${size}^3 * cascade$点反投影到图像上，标记需要训练的点（去除投影到图像外的点）
        generate_grid_samples_nerf_nonuniform: 随机生成采样点
        m_nerf_network->density 对每个采样点估计density
        splat_grid_samples_nerf_max_nearest_neighbor 
        ema_grid_samples_nerf EMA指数移动平均
        update_density_grid_mean_and_bitfield
    train_nerf: 
      train_nerf_step
        generate_training_samples_nerf: 对每幅图像随机取点生成射线Ray，计算射线与aabb的交点并在其间进行采样得到采样点
          coords_out(j)->set_with_optional_extra_dims: encoding后的输入？
        m_network->inference_mixed_precision 
        compute_loss_kernel_train_nerf: 计算射线逐点积分，同时维护MLP中的loss
        fill_rollover_and_rescale
        m_network->forward/backward: 训练MLP，更新rgb 
      m_trainer->optimizer_step m_trainer(m_network, m_optimizer)
  Testbed::render_frame_main
    render_nerf: 使用tracer计算当前角度射线上的rgb值
      Testbed::NerfTracer::init_rays_from_camera 根据指定的aabb生成射线，计算射线到aabb的交点确定范围
        init_rays_with_payload_kernel_nerf
          uv_to_ray 根据像素值uv获取Ray原点和方向
        advance_pos_nerf_kernel 
          advance_pos_nerf 计算payload.t
      Testbed::NerfTracer::trace: 迭代MARCH_ITER，使用双ray
        compact_kernel_nerf: 射线前进时，置换ray中的值，hit中时，存储到m_rays_hit，得到最终该射线到图像上的rgb计算值
        generate_next_nerf_network_inputs: 根据原点和射线方向生成采样点，step前进
        network.inference_mixed_precision (NerfNetwork)
        composite_kernel_nerf 积分累加local_rgba
      shade_kernel_nerf: 射线累积值到frame_buffer(二维),即显示到屏幕上的rgba值，depth_buffer深度值
  Testbed::render_frame_epilogue 渲染dlss、GT、VR、m_render_transparency_as_checkerboard等

get_rgba_on_grid 保存rgba和raw数据时调用
  generate_grid_samples_nerf_uniform_dir 射线采样，$step = sqrt(3) / 1024$
  tcnn::Network::inference
  compute_nerf_rgba_kernel
    compute_nerf_rgba alpha-density转换

Testbed {GLTexture} {CudaRenderBuffer}
  CudaRenderBuffer {SurfaceProvider, tcnn::GPUMemory<vec4>, CudaRenderBufferView} 最终显示的rgba和depth
    SurfaceProvider 接口
    - CudaSurface2D cuda的array数据载体和surface数据描述
    - GLTexture {CUDAMapping 与cpu交互} 与opengl交互
```

# <font color = red> 其它相关算法及原理 </font>
## Algorithms
### ICP 点云配准
$$ (R, t) -> min \sum_i^{n} |p_i - (R * p_i^{'} + t)|^2 $$
1. KNN查找最近点
2. 求解AX=B (QR分解或LU分解等)

# <font color = red> 其它笔记 </font>
# 附录1: 部分项目阅读笔记  
## puma 
点云Poisson重建。滑动窗口机制，每n帧点云组成局部点云，对每帧点云和当前n-1的局部点云进行icp匹配，然后对局部点云Poisson重建生成局部网格，并去除掉点云密度小于一定阈值的点和面，再去除重叠点云和重叠网格合成到全局网格中。
主要使用了open3d库。
icp有gicp、p2p、p2l等算法。深度越大，细节越多，重建时间也越长，资源消耗也越多。
## Bungee-nerf
使用多尺寸nerf，由远及近。baseblock和resblock对应训练和测试两个网络
## On Surface Prior
使用两个神经网络学习SDF和ODF。SDF使用ODF学到的表面先验预测点云中的SDF。即，对于点云G周围的采样点q,投影到G成点p，投影的长度和方向分别由在q点的SDF和梯度决定；由p的KNN组成局部区域t，ODF判断p是否在区域t上，如果不在，反向传播惩罚SDF网络，同时鼓励SDF网络产生最短投影距离。
## Neus-nerf
将渲染重建优化与SDF网络训练关联，联合优化。传统Nerf只合成新视角，对网格化效果不理想，游离噪声点多。DVR、IDR需要mask屏蔽背景。IDR算法虽然用于表面重建，但使用的还是传统的表面渲染，对表面深度会变化的物理不鲁棒。Neus改进了权重函数和体密度函数。权重函数需要满足两个条件：无偏差性——对射线$p(t)$，当$f(p(t^{*})) = 0$也就是$t^{*}$ 是SDF函数的零水平集表面点时，权重应在 $p(t^{*})$ 处有局部最大值；遮挡适应性——射线r上如果有相异的两点有相同的SDF值，则距离视点近的点具有更大的权重。
重点在于重建，总体Pipeline和Nerf大相径庭，整体依赖于RGB loss项。
NeRF: 训练背景颜色
SDFNetwork: 训练sdf
SingleVarianceNetwork: 偏差
RenderingNetwork: 训练rgb
## PlenOctree 数据结构：稀疏八叉树
## MVSNerf
学习通用网络，取三个视觉图像训练，2DCNN提取图像特征得到cost volume，3DCNN进行encode，MLP学习Nerf。模型具有泛化性。

# 附录2: 现有开源代码使用
## IMMESH
imu+激光重建网格，在r3live的基础上
```c++
Voxel_mapping::service_LiDAR_update
  sync_packages　// 同步激光数据和imu积分
  ImuProcess::Process2
  map_incremental_grow　// 网格增长线程
    start_mesh_threads
      service_reconstruct_mesh // 对队列g_rec_mesh_data_package_list中的每帧数据调用incremental_mesh_reconstruction重建
        incremental_mesh_reconstruction　// 每帧激光三角化
          delaunay_triangulation
          find_relative_triangulation_combination // 查找当前帧点云的邻近点(20个)
          remove_triangle_list
          insert_triangle
service_refresh_and_synchronize_triangle
```

## ffmpeg video2picture
```sh
ffmpeg.exe -i "D:/dataset/lab/IMG_0080.MOV" -qscale:v 1 -qmin 1 -vf "fps=30.0" "D:/dataset/lab\images"/%04d.jpg

ffmpeg.exe -i "D:/dataset/lab/IMG_0080.MOV" -vcodec libx264 -s 1920x1080 -crf 0 -acodec copy new.mp4
```

## colmap
从图像到三维稠密点云
### 编译
最终版本
* glog: 0.8.0
* ceres-solver: 2.3.0

1. 版本对应问题
Ubuntu 20.04使用apt install默认安装的cuda-toolkit 10.1、Eigen 3.3.7和Ceres 1.14.0版本都相对较低。

对NVIDIA 3090显卡来说，安装550驱动后最高支持cuda 12.4， 10.1不能充分利用3090

安装了Eigen 3.4.0，glog 0.8.0，编译ceres-solver-2.2.0时报错。
```sh
CMake Error at /usr/local/lib/cmake/Ceres/CeresConfig.cmake:85 (message):
  Failed to find Ceres - Found Eigen dependency, but the version of Eigen
  found (3.4.0) does not exactly match the version of Eigen Ceres was
  compiled with (3.3.7).  This can cause subtle bugs by triggering violations
  of the One Definition Rule.  See the Wikipedia article
  http://en.wikipedia.org/wiki/One_Definition_Rule for more details
Call Stack (most recent call first):
  /usr/local/lib/cmake/Ceres/CeresConfig.cmake:204 (ceres_report_not_found)
  cmake/FindDependencies.cmake:41 (find_package)
  CMakeLists.txt:116 (include)
```
确认是版本问题。
```sh
In file included from /home/channy/Documents/thirdlibs/ceres-solver-2.2.0/internal/ceres/levenberg_marquardt_strategy_test.cc:40:
/home/channy/Documents/thirdlibs/ceres-solver-2.2.0/internal/ceres/gmock/mock-log.h:115:8: error: ‘void testing::ScopedMockLog::send(google::LogSeverity, const char*, const char*, int, const tm*, const char*, size_t)’ marked ‘override’, but does not override
  115 |   void send(google::LogSeverity severity,
      |        ^~~~
/home/channy/Documents/thirdlibs/ceres-solver-2.2.0/internal/ceres/levenberg_marquardt_strategy_test.cc: In member function ‘virtual void ceres::internal::LevenbergMarquardtStrategy_CorrectDiagonalToLinearSolver_Test::TestBody()’:
/home/channy/Documents/thirdlibs/ceres-solver-2.2.0/internal/ceres/levenberg_marquardt_strategy_test.cc:144:19: error: cannot declare variable ‘log’ to be of abstract type ‘testing::ScopedMockLog’
  144 |     ScopedMockLog log;
      |                   ^~~
```
2. glog版本更新问题
依赖于glog的LogSink类，而glog在2025年归档版本0.8.0中该类的send函数修改了输入参数类型（在2021年该类已变更），由const struct ::tm*变成const LogMessageTime&，需要对应修改colmap中重写该函数的类型
```c++
  virtual void send(LogSeverity severity, const char* full_filename,
                    const char* base_filename, int line,
                    const struct ::tm* tm_time,
                    const char* message, size_t message_len) = 0;
```
```c++
 virtual void send(LogSeverity severity, const char* full_filename,
                    const char* base_filename, int line,
                    const LogMessageTime& time, const char* message,
                    size_t message_len) = 0;
```
3. ceres-solver版本更新问题
glog的LogSink类send接口的参数之一类型由原来的`struct ::tm*`在2021年变成了`LogMessageTime`，而ceres-solver-2.2.0版本还保持着旧参数类型。2025年5月新拉ceres-2.3.0最新的代码，已经没有该文件了。编译报缺少abseil库，abseil可以依赖下面的GTest
```sh
CMake Error at CMakeLists.txt:173 (find_package):
  By not providing "Findabsl.cmake" in CMAKE_MODULE_PATH this project has
  asked CMake to find a package configuration file provided by "absl", but
  CMake did not find one.
```
```sh
CMake Error at /snap/cmake/1463/share/cmake-4.0/Modules/FindPackageHandleStandardArgs.cmake:227 (message):
  Could NOT find GTest (missing: GTEST_LIBRARY GTEST_INCLUDE_DIR
  GTEST_MAIN_LIBRARY) (Required is at least version "1.14.0")
```
使用apt install libgtest-dev 安装的版本是1.10.0
4. 
```sh
CMake Error at /usr/share/cmake-3.16/Modules/CMakeFindDependencyMacro.cmake:47 (find_package):
  By not providing "FindCUDAToolkit.cmake" in CMAKE_MODULE_PATH this project
  has asked CMake to find a package configuration file provided by
  "CUDAToolkit", but CMake did not find one.

  Could not find a package configuration file provided by "CUDAToolkit"
  (requested version 12.8.93) with any of the following names:

    CUDAToolkitConfig.cmake
    cudatoolkit-config.cmake
```
### 使用
```sh
# 特征点检测，SIFT特征
COLMAP.bat feature_extractor --ImageReader.camera_model OPENCV --ImageReader.camera_params "" --SiftExtraction.estimate_affine_shape=true --SiftExtraction.domain_size_pooling=true --ImageReader.single_camera 1 --database_path colmap.db --image_path "./images"

COLMAP.bat feature_extractor --ImageReader.camera_model PINHOLE --ImageReader.camera_params "" --SiftExtraction.estimate_affine_shape=true --SiftExtraction.domain_size_pooling=true --ImageReader.single_camera 1 --database_path colmap.db --image_path "./images"

# 特征点匹配
# * exhaustive_matcher 全局匹配
# * sequential_matcher 序列匹配
# * spatial_matcher
# * vocab_tree_matcher
COLMAP.bat sequential_matcher --SiftMatching.guided_matching=true --database_path colmap.db
COLMAP.bat sequential_matcher --database_path colmap.db

# 计算机摄像机参数进行稀疏重建
COLMAP.bat mapper --database_path colmap.db --image_path "./images" --output_path ./colmap_sparse

# 输出sparse文件夹，包含摄像机参数和稀疏点云
# * mapper
# * hierarchical_mapper 

# colmap稠密重建需要GPU，使用cuda
# 图像去畸变
COLMAP.bat image_undistorter --image_path ./images --input_path ./colmap_sparse/0 --output_path ./dense --output_type COLMAP
# 输出dense文件夹
COLMAP.bat patch_match_stereo --workspace_path ./dense --workspace_format COLMAP --PatchMatchStereo.geom_consistency true
# 输出dense/stereo文件夹，估计每张图像的depthMap和NormalMap
# 融合
COLMAP.bat stereo_fusion --workspace_path ./dense --workspace_format COLMAP --input_type geometric --output_path ./dense/result.ply
# 输出点云模型
# colmap的mesh功能相对还有很大的改进空间

// 自动重建计算摄像机参数
./colmap automatic_reconstructor --image_path /home/channy/Documents/datasets/dataset_reconstruct/20250107_ZC/Capture --workspace_path /home/channy/Documents/datasets/dataset_reconstruct/20250107_ZC

./colmap model_aligner --input_path ./sparse/0 --output_path ./CameraPos_GPS --alignment_type ecef --database_path ./database.db
```

### 基本步骤和原理
1. feature detection: SiftGPU，胜在快速、具有尺度不变性。但对于kNN特征点距离的匹配效果其实并不算特别好。当特征点检测失败或匹配错误多导致匹配错乱时，都会导致摄像机参数计算失败。
2. feature matching: Exhaustive、Sequential、VocabTree、Transitive
* exhaustive_matcher 全局匹配
* sequential_matcher 序列匹配
* spatial_matcher 
* vocab_tree_matcher 
如果想要更好的匹配效果，可以尝试块匹配、光流跟踪等其它匹配算法，但时间和空间占用可能都会比Sift多。
3. mapper: incremental/global
输出sparse文件夹，包含摄像机参数和稀疏点云
* mapper
* hierarchical_mapper 
4. model merge
可能会生成多个model，可使用model_merger合并，但不一定成功
5. mesh reconstruction -> PoissonRecon
6. texture
#### 使用SQLite3存储中间过程
在scene/database中，使用SQLite3创建.db文件，并创建一系列表存储摄像机内参数、图像信息、特征点、特征描述、匹配信息等等。
| 表格名称 | 属性 | 说明 | 
|:---:|:---:|:---:|
| cameras | camera_id, model, width, height, params, prior_focal_length | |
| images | image_id, name, camera_id | |
| pose_priors | image_id, position, coordinate_system | |
| keypoints | image_id, rows, cols, data | | 
| descriptors | image_id, rows, cols, data | |
| matches | pair_id, rows, cols, data | |
| two_view_geometries | pair_id, rows, cols, data, config, F, E, H, qvec, tvec | | 

同时还有cache机制，如果cache中已经有结果，则不会再检测或匹配
#### 
```c++
CreateFeatureExtractorController
  FeatureExtractorController
    SiftFeatureExtractorThread  // 从job队列中取image_data，并把检测到的key和des赋值到image_data
      CreateSiftFeatureExtractor
        SiftGPUFeatureExtractor.Extract  // SiftGpu的RunSIFT
CreateSequentialFeatureMatcher
  GenericFeatureMatcher (Thread)
    FeatureMatcherController
      FeatureMatcherWorker  // SiftGPU的GetSiftMatch
IncrementalMapperController::Run
  Reconstruct
    ReconstructSubModel
      InitializeReconstruction
        IncrementalMapper::FindInitialImagePair
          FindFirstInitialImage // 初始化，对图像按能找到匹配点的数量排序，选择初始重建图像
          EstimateInitialTwoViewGeometry // 得到初始的三维点云和[R,t]
      FindNextImages // 根据可恢复的三维点数量选择后续图像
```

## OpenMVS
位姿－>网格
### 编译
* nanoflann
* libjxl
```sh
# Install dependencies
sudo apt install git cmake build-essential pkg-config

# Clone and build libjxl
git clone https://github.com/libjxl/libjxl.git
cd libjxl
git submodule update --init --recursive
```
* 设置vcg路径
```CMakeLists.txt
set(VCG_DIR "/home/channy/Documents/thirdlibs/vcglib")
```
* 
```sh
openMVS/libs/Common/Config.h:235:44: error: missing binary operator before token "("
  235 | #if defined(__has_builtin) && __has_builtin(__builtin_debugtrap)
      |                                            ^
make[2]: *** [libs/Common/CMakeFiles/Common.dir/build.make:80: libs/Common/CMakeFiles/Common.dir/cmake_pch.hxx.gch] Error 1
make[1]: *** [CMakeFiles/Makefile2:525: libs/Common/CMakeFiles/Common.dir/all] Error 2
make: *** [Makefile:146: all] Error 2
```
* boost link error　
boost编译默认不开启zstd和bzip2导致编译一直报错boost链接库。  
拉了最新的CGAL代码，生成的cmake要求boost最低1.74.0，但ubuntu20.04使用apt安装的是1.71.0，于是源码编译boost。
```sh
/lib/libMVS.a(Scene.cpp.o): in function `boost::detail::sp_counted_impl_p<boost::iostreams::symmetric_filter<boost::iostreams::detail::zstd_decompressor_impl<std::allocator<char> >, std::allocator<char> >::impl>::dispose()':
Scene.cpp:(.text._ZN5boost6detail17sp_counted_impl_pINS_9iostreams16symmetric_filterINS2_6detail22zstd_decompressor_implISaIcEEES6_E4implEE7disposeEv[_ZN5boost6detail17sp_counted_impl_pINS_9iostreams16symmetric_filterINS2_6detail22zstd_decompressor_implISaIcEEES6_E4implEE7disposeEv]+0x24): undefined reference to `boost::iostreams::detail::zstd_base::reset(bool, bool)'
```
OpenMVS使用到了boost的iostreams，源码编译就需要手动打开zstd和bzip2。
```sh
apt install libzstd-dev libbz2-dev
```
如果前面编译过boost没有打开，可以先清除生成文件如b2,bootstrap.log,bin.v2等。  
运行bash时把需要用到的都加到--with-libraries中。然后运行b2时配置zstd和bzip2的路径，一般apt安装的默认应该在/usr/下，也有可能有例外的。
```sh
sh ./bootstrap.sh --with-libraries=iostreams,program_options,serialization,system,throw-exception
./b2 --with-iostreams --with-program_options -s NO_ZSTD=0 -s ZSTD_INCLUDE=/usr/include/zstd -s ZSTD_LIBPATH=/usr/lib/x86_64-linux-gnu -s NO_BZIP2=0 -s BZIP2_include=/usr/include -s BZIP2_LIBPATH=/usr/lib/x86_64-linux-gnu
```

### 使用
```sh
# 把colmap计算得到的摄像机参数转换成mvs的格式，有bug为-i不能直接接./，曲线运行-i ./../cur_folder/
InterfaceCOLMAP.exe  -w D:\dataset\lab\Parking -i D:\dataset\lab\Parking

DensifyPointCloud.exe -w D:\dataset\lab\Parking -i scene.mvs

ReconstructMesh.exe -w D:\dataset\lab\Parking -i scene_dense.mvs

TextureMesh.exe -w D:\dataset\lab\Parking -i scene_dense_mesh.mvs
```

1. format translation
2. depth map. NCC patch, fusion
3. Dense pointcloud -> delaunay reconstruction -> mesh clean -> hole filling
4. Texture projection: face view selection + generate texture pic

```c++
---> DensifyPointClouds
Scene::DenseReconstruction
    Scene::ComputeDepthMaps
        DepthMapsData::SelectViews 根据面积、角度、覆盖度对每一张图像选择相邻视图
        Scene::DenseReconstructionEstimate
            DepthMapsData::InitViews
                DepthMapsData::InitDepthMap 根据可用的稀疏点初始化深度图
                    MVS::TriangulatePoints2DepthMap Delaunay三角化
            DepthMapsData::EstimateDepthMap
                DepthMapsData::ScoreDepthMapTmp 计算深度图像每个像素点的深度值置信度存储到confMap0中
                    DepthEstimator::ScorePixel 根据深度和法线计算像素NCC 
                        DepthEstimator::ScorePixelImage 计算图像中像素的NCC得分
                DepthMapsData::EstimateDepthMapTmp 
                    DepthEstimator::ProcessPixel

FaceViewSelection // 计算网格中每个三角面对应的最佳图像
  ListCameraFaces　// 对图像进行GaussianBlur后使用八叉树，对每张图像，把所有三角面投影到图像中，记录每个三角面对应每张图像的quality、color等信息
  // 使用boost建立邻接图，
  // LBP算法，label对应idxView+1
  // 对同一label(同一张图)且相邻的两个面，放在同一个texturePatches里面
GenerateTexture // 对于每个patch中的每个三角面，根据label映射到对应图像中计算texcoord，并计算整个patch在图像中对应的rect
  Camera.ProjectPointP // 计算aabb
  // 对patch两两对比，去除被包含的patch
  RectsBinPack::ComputeTextureSize // 计算纹理需要图像的长宽
  MaxRectsBinPack.Insert　// uv二维装箱算法bin packing algorithms，使用nRectPackingHeuristic控制使用的算法，nRectPackingHeuristic/100 - MaxRects/Skyline/Guillotine；nRectPackingHeuristic%100　- BottomLeft/MinWasteFit/Last
  // 有计算冗余,当纹理图像剩余rect被进一步分割后，会重新计算patch在每个剩余rect中的长宽score，算是以时间换空间
  // 如果重建出来的模型比较大的话，如网格重建出来的二进制ply文件有300+M，此时直接使用TextureMesh计算纹理在这一步会非常非常非常耗时，比较建议的方法是分割成小网格
```

### 对网格模型分片
```c++
void splitMesh(Scene &scene) {
	Mesh::Box box = scene.mesh.GetAABB();
	VERBOSE("Mesh Bound: (%f,%f,%f) - (%f,%f,%f)", box.ptMin.x(), box.ptMin.y(), box.ptMin.z(), box.ptMax.x(), box.ptMax.y(), box.ptMax.z());
	int gap = 5;
	int fMinX = std::floor(box.ptMin.x() / gap) * gap;
	int fMinY = std::floor(box.ptMin.y() / gap) * gap;
	int fMinZ = std::floor(box.ptMin.z() / gap) * gap;
	int nCountX = std::ceil((box.ptMax.x() - fMinX) / gap);
	int nCountY = std::ceil((box.ptMax.y() - fMinY) / gap);
	int nCountZ = std::ceil((box.ptMax.z() - fMinZ) / gap);
	VERBOSE("Chunk %d-%d-%d", nCountX, nCountY, nCountZ);
	Mesh::FacesChunkArr chunks(nCountX * nCountY * nCountZ);
	// std::vector<Mesh::FaceIdxArr> vChunks(nCountX * nCountY * nCountZ);
	FOREACH(idxFace, scene.mesh.faces) {
		const Mesh::Face& facet = scene.mesh.faces[idxFace];
		for (int v=0; v<3; ++v) {
			const Mesh::Vertex& vertex = scene.mesh.vertices[facet[v]];
			int nIdxX = std::floor((vertex.x - fMinX) / gap);
			int nIdxY = std::floor((vertex.y - fMinY) / gap);
			int nIdxZ = std::floor((vertex.z - fMinZ) / gap);
			int idx = nIdxX + nIdxY * nCountX + nIdxZ * nCountX * nCountY;
			chunks[idx].faces.push_back(idxFace);
			if (chunks[idx].name.IsEmpty()) {
				chunks[idx].name = String::FormatString("%02d-%02d-%02d", nIdxX, nIdxY, nIdxZ);
			}
		}
	}
	VERBOSE("save...");
	scene.mesh.Save(chunks, g_strWorkingFolder + "/mesh.ply");
}
```

$$
NCC(A, B) = \frac{\sum (A – \bar{A}) \cdot (B – \bar{B})}{\sqrt{\sum (A – \bar{A})^2} \cdot \sqrt{\sum(B – \bar{B})^2}} 
$$

SGM 半全局算法
PatchMatch

局部：SAD、SSD、NCC/ZNCC, Census-Transform、Mutual Information、PatchMatch
全局：graph cut, Belief Propagation, Dynamic Programming
半全局：SGM

TOF, Structured Light

Scene::ReconstructMesh Delaunay三角化，计算每条边的权重，graph-cut分割提取网格。

### 异常记录
2025年11月下旬新拉的develop分支的代码

1. TextureMesh.cpp 
```c++
int main(int argc, LPCTSTR*argv)
......
	if (scene.mesh.IsEmpty()) {
		VERBOSE("error: empty initial mesh");
		return EXIT_FAILURE;
	}
	const String baseFileName(MAKE_PATH_SAFE(Util::getFileFullName(OPT::strOutputFileName)));
	if (OPT::nOrthoMapResolution && !scene.mesh.HasTexture()) {
		// the input mesh is already textured and an orthographic projection was requested
		goto ProjectOrtho;
	}
......
```
其中`if (OPT::nOrthoMapResolution && !scene.mesh.HasTexture()) {`为什么是`!scene.mesh.HasTexture()`?这是没有纹理才进if里面吗？难道不是有纹理才进if里面？

2. Mesh.cpp 
```c++
void Mesh::ProjectOrthoTopDown(unsigned resolution, Image8U3& image, Image8U& mask, Point3& center) const
......
  Camera camera;
	camera.R.SetFromDirUp(Vec3(Point3(0,0,-1)), Vec3(Point3(0,1,0)));
	camera.C = center;
	camera.C.z += size.z;
	camera.K = KMatrix::IDENTITY;
  if (size.x > size.y) {
		image.create(CEIL2INT(size.y*(resolution-1)/size.x), (int)resolution);
		camera.K(0,0) = camera.K(1,1) = (resolution-1)/size.x;
	} else {
		image.create((int)resolution, CEIL2INT(size.x*(resolution-1)/size.y));
		camera.K(0,0) = camera.K(1,1) = (resolution-1)/size.y;
	}
	camera.K(0,2) = (REAL)(image.width()-1)/2;
	camera.K(1,2) = (REAL)(image.height()-1)/2;
	// project mesh
	DepthMap depthMap(image.size());
		ProjectOrtho(camera, depthMap, image);
......

```
其中`SetFromDirUp`写死了viewDir是z轴负方向，对于无人机拍摄的图像集重建来说viewDir应该是z轴正向，直接不改代码投影不出来想要的结果。

其中`camera.C.z += size.z;`是把相机拉近到模型[zmin, zmax]的中点了？容易投影不全？

其中`ProjectOrtho(camera, depthMap, image);`
```c++
void Mesh::ProjectOrtho(const Camera& camera, DepthMap& depthMap, Image8U3& image) const
......
		void Raster(const ImageRef& pt, const Triangle& t, const Point3f& bary) {
			const Depth z(ComputeDepth(t, bary));
			ASSERT(z > Depth(0));
			Depth& depth = depthMap(pt);
			if (depth == 0 || depth > z) {
				depth = z;
				xt  = mesh.faceTexcoords[idxFaceTex+0] * bary[0];
				xt += mesh.faceTexcoords[idxFaceTex+1] * bary[1];
				xt += mesh.faceTexcoords[idxFaceTex+2] * bary[2];
				auto texIdx = mesh.faceTexindices[idxFaceTex / 3];
				image(pt) = mesh.texturesDiffuse[texIdx].sampleSafe(xt);
			}
		}
......
```
对应的`auto texIdx = mesh.faceTexindices[idxFaceTex / 3];`当texturesDiffuse长度为１时会崩，因为生成纹理时如果texturesDiffuse长度为１是没有faceTexindices的，可以改为`auto texIdx = mesh.GetFaceTextureIndex(idxFaceTex / 3);`
```c++
void MeshTexture::GenerateTexture(bool bGlobalSeamLeveling, bool bLocalSeamLeveling, unsigned nTextureSizeMultiple, unsigned nRectPackingHeuristic, Pixel8U colEmpty, float fSharpnessWeight, int maxTextureSize)
......
		if (texturesDiffuse.size() == 1)
			faceTexindices.Release();
......
```

## colmap2nerf steps

可能会生成多个mode1， 可使用model_merger合并，但不一定成功。只有当两个model间有相同图像时才能合并。
```sh
# 输出稀疏重建model结果为txt格式
COLMAP.bat model_converter --input_path colmap_sparse/0 --output_path sparse --output_type TXT
# 模型合并
COLMAP.bat model_merger --input_path1 colmap_sparse/0 --input_path2 colmap_sparse1 --output_path colmap_sparse/01

COLMAP.bat bundle_adjuster --input_path colmap_sparse/01 --output_path colmap_sparse/01new
# 转化成nerf格式
./colmap2nerf.py --aabb_scale 128 --images ./images --text ./colmap_text --out ./transforms.json

python ./scripts/colmap2nerf.py --aabb_scale 128 --run_colmap --images ./images

python ./scripts/colmap2nerf.py --video_in D:/dataset/lab/IMG_0080.MOV --video_fps 30 --run_colmap --aabb_scale 128
# 训练渲染
instant-ngp.exe ./data/fox
```

## OpenMVG
```sh
::openMVG_main_SfMInit_ImageListing.exe -d E:\thirdLibs\openMVG\src\openMVG\exif\sensor_width_database\sensor_width_camera_database.txt  -i D:\dataset\lab\parking\images -o D:\dataset\lab\parking\openmvg -f 1
::openMVG_main_SfMInit_ImageListing.exe -f 4838 -i D:\dataset\lab\parking\images -o D:\dataset\lab\parking\openmvg

// sift feature
::openMVG_main_ComputeFeatures.exe -i D:\dataset\lab\parking\openmvg\sfm_data.json -o D:\dataset\lab\parking\openmvg\ -n 10 -f 1

// write index pair to file 
::openMVG_main_PairGenerator.exe -i D:\dataset\lab\parking\openmvg\sfm_data.json -o D:\dataset\lab\parking\openmvg\imgpairs.bin -m CONTIGUOUS -c 10
::openMVG_main_PairGenerator.exe -i D:\dataset\lab\parking\openmvg\sfm_data.json -o D:\dataset\lab\parking\openmvg\imgpairs.bin 

// for each pair images, generate index of matching features 
openMVG_main_ComputeMatches.exe -i D:\dataset\lab\parking\openmvg\sfm_data.json -o D:\dataset\lab\parking\openmvg\matches.txt -p D:\dataset\lab\parking\openmvg\imgpairs.bin -f 1

// using BA and RANSAC to filte error matching
openMVG_main_GeometricFilter.exe -i D:\dataset\lab\parking\openmvg\sfm_data.json -m  D:\dataset\lab\parking\openmvg\matches.txt -o D:\dataset\lab\parking\openmvg\matches.f.txt -f 1

openMVG_main_SfM.exe -s GLOBAL -i D:\dataset\lab\parking\openmvg\sfm_data.json -m D:\dataset\lab\parking\openmvg\ -o D:\dataset\lab\parking\openmvg\
::openMVG_main_SfM.exe -s INCREMENTAL -i D:\dataset\lab\parking\openmvg\sfm_data.json -M D:\dataset\lab\parking\openmvg\matches.txt -o D:\dataset\lab\parking\openmvg\sfm\

openMVG_main_openMVG2openMVS.exe -i D:\dataset\lab\Parking\openmvg\sfm_data.bin -o scene.mvs -d D:\dataset\lab\Parking\openmvg -n 30
```

1. sift feature. generate .feat and .desc files for each image. .feat file records position of keypoints, sigma and theta. .desc file records 128 float data of descriptor.
2. match (exhaustive/sequential), kNN search nearist point(s), openMVG use 2NN+ratio=0.8
3. filter, erase error matches. RANSAC, fundamental/essential/homography matrix
4. SfM (global/incremental)
* incremental 对错误匹配修正高，总体精度高，时间长，drift可用loop closure优化
* global 时间短，避免drift，错误匹配影响大，总体精度低
5. format translation. 

# 附录3: 编译遇到的问题
* 使用CGAL过程中转Debug编译，报
```
fatal error C1128: number of sections exceeded object file format limit : compile with /bigobj
```
vs中，可properties(属性) -> Configuration Properties(配置属性) -> C/C++ -> Command Line(命令行) -> Additional options(其他选项)，加上 /bigobj属性重新编译。

* 编译colmap
```sh
cmake .. -DCMAKE_CUDA_COMPILER=/usr/local/cuda-12.5/bin/nvcc
```

# 附录3: 重建参考GroundTruth
轿车长宽高：4.8m * 1.8m * 1.5m

# 参考库
[cgal](https://github.com/CGAL/cgal.git)  
[glfw](https://github.com/glfw/glfw)  
[glew](https://github.com/nigels-com/glew/releases/download/glew-2.2.0/glew-2.2.0.zip)
[RGB-D重建](https://blog.51cto.com/u_14439393/5748486)
[点云重建](https://github.com/PRBonn/puma)

# 数据集
[点云集](https://robotik.informatik.uni-wuerzburg.de/telematics/3dscans/)
[kitti](https://www.cvlibs.net/datasets/kitti/)
[EuRoC MAV / ASL Datasets](https://projects.asl.ethz.ch/datasets/doku.php?id=kmavvisualinertialdatasets)
[M2DGR](https://github.com/SJTU-ViSYS/M2DGR)
[M2DGR-plus](https://github.com/SJTU-ViSYS/M2DGR-plus?tab=readme-ov-file)
