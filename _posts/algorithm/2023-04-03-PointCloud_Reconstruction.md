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

# <font color = red> 传统方法 </font>
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

# <font color = red> 神经网络方法 </font>
# nerf
$$(\theta, \phi, r, g, b) -> (x, y, z, a)$$
根据输入的多角度RGB图像和对应的摄像机参数，建立两个MLP分别求解三维空间中网格点的alpha和RGB值
## [instant-ngp](https://github.com/NVlabs/instant-ngp) 
* 输入数据：多角度RGB图像序列。每幅图像对应的传感器位姿[3x4矩阵]（拍摄时每幅图像对应的传感器位姿相对于首幅图像或前一幅图像对应的传感器位姿的参数--旋转R[3x3]和平移t[3x1]）
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
### instant-ngp源码说明
* load_nerf 读取输入数据返回NerfDataset，支持的图像格式有
```c++
	std::vector<std::string> supported_image_formats = {
		"png", "jpg", "jpeg", "bmp", "gif", "tga", "pic", "pnm", "psd", "exr",
	};
```
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

### colmap2nerf 计算摄像机参数
可使用colmap稀疏重建计算，再通过./scripts/colmap2nerf.py进行格式转换

### video2picture
```sh
ffmpeg.exe -i "D:/dataset/lab/IMG_0080.MOV" -qscale:v 1 -qmin 1 -vf "fps=30.0" "D:/dataset/lab/images"/s04d.jpg
```

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

# <font color = red> 其它笔记 </font>
# 附录1: 现有开源代码使用
## ffmpeg video2picture
```bat
ffmpeg.exe -i "D:/dataset/lab/IMG_0080.MOV" -qscale:v 1 -qmin 1 -vf "fps=30.0" "D:/dataset/lab\images"/%04d.jpg

ffmpeg.exe -i "D:/dataset/lab/IMG_0080.MOV" -vcodec libx264 -s 1920x1080 -crf 0 -acodec copy new.mp4
```

## colmap
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

# 附录2: 编译遇到的问题
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
