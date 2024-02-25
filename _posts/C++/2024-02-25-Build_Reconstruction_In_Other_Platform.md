---
layout: default
title: Build Reconstruction in Other Platform
categories:
- C++
tags:
- C++
---
//Description: 在其它平台中使用三维重建

//Create Date: 2024-02-25 18:34:19

//Author: channy

# CMake
CMake 在查找其它库时在目标目录下的cmake中寻找查找信息。

路径信息通过各个库的.cmake文件说明中查找。如OpenCV在OpenCVConfig.cmake中设置了OpenCV_INCLUDE_DIRS变量，osg在OpenSceneGraphConfig.cmake中设置了OSG_INCLUDE_DIR等。

```
cmake -G"MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%cd%/install -DCMAKE_C_COMPILER=D:/Qt/Qt5.14.2/Tools/mingw730_64/bin/gcc.exe -DCMAKE_CXX_COMPILER=D:/Qt/Qt5.14.2/Tools/mingw730_64/bin/c++.exe -DCMAKE_MAKE_PROGRAM=D:/Qt/Qt5.14.2/Tools/mingw730_64/bin/mingw32-make.exe ../cmake
```
cmake使用mingw编译
## OpenSceneGraph
OpenSceneGraph -> install -> set System Path OSG_DIR -> use find_package(OpenSceneGraph)

只有OpenSceneGraph_INCLUDE_DIRS

## GLFW
glfw的glfw3Config.cmake文件指向glfw3Targets.cmake文件，而该文件里面并没有设置类似于GLFW3_INCLUDE_DIR之类的变量。故加了路径之后cmake能够find_package成功但路径为空。

修改glfw3Targets.cmake文件增加路径设置
```
set(GLFW3_INCLUDE_DIR "${_IMPORT_PREFIX}/include")
set(GLFW3_LIBRARY_DIR "${_IMPORT_PREFIX}/lib")
```

-> set System Path GLFW3_DIR -> use find_package(GLFW3)

# c++开发库给java调用
1. c++开发实现库函数
2. 如果是给android，下载ndk。建立jni文件夹，编写Android.mk和Application.mk两个文件。其中jni文件夹下include存放头文件，src存放源文件，libs存放依赖库。
3. ndk-build 会在jni同层下建立文件夹libs和obj生成.so库文件
4. 下载安装jdk，设置java环境变量，编写简单的java调用程序
5. javac -h -jni xxx.java生成jni头文件
6. 编写jni头文件对应的cpp文件
7. jni的头文件和cpp文件增加到c++库，重新ndk-build

```Android.mk
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_CFLAGS += -Wall
LOCAL_CFLAGS += -O3 -fPIC -std=c++17

LOCAL_C_INCLUDES := $(LOCAL_PATH)/include

LOCAL_C_INCLUDES += $(LOCAL_PATH)/include/eigen-3.4.0

LOCAL_C_INCLUDES += ${LOCAL_PATH}/include/magic_enum-master/include

LOCAL_SRC_FILES := \
	$(subst $(LOCAL_PATH)/,, \
	$(wildcard $(LOCAL_PATH)/src/*.cpp)) 

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_C_INCLUDES)

LOCAL_CPP_FEATURES += exceptions

LOCAL_LDLIBS := -L$(LOCAL_PATH)/libs 

LOCAL_MODULE := IntentionDetection
```

```Application.mk
# The ARMv7 is significanly faster due to the use of the hardware FPU
#APP_ABI := armeabi
APP_ABI := armeabi-v7a
APP_STL := c++_static
APP_PLATFORM := android-16
```

## 
```
error: cannot initialize a parameter of type 'JNIEnv **' (aka '_JNIEnv **') with an rvalue of type 'void **'
                if ((g_VM)->AttachCurrentThread((void**)&env, NULL) != 0) {
```
windows 需要`(void**)`转型，linux不需要。

# Assimp
1. Assimp不支持Ply格式的多纹理坐标加载。

# OpenMVG
```bat
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

# OpenMVS
```bat
InterfaceCOLMAP.exe  -w D:\dataset\lab\Parking -i D:\dataset\lab\Parking

DensifyPointCloud.exe -w D:\dataset\lab\Parking -i scene.mvs

ReconstructMesh.exe -w D:\dataset\lab\Parking -i scene_dense.mvs

TextureMesh.exe -w D:\dataset\lab\Parking -i scene_dense_mesh.mvs
```

1. format translation
2. depth map. NCC patch, fusion
3. Dense pointcloud -> delaunay reconstruction -> mesh clean -> hole filling
4. Texture projection: face view selection + generate texture pic

# colmap
1. feature detection: SiftGPU
2. feature matching: Exhaustive、Sequential、VocabTree、Transitive
* exhaustive_matcher 全局匹配
* sequential_matcher 序列匹配
* spatial_matcher 
* vocab_tree_matcher 
3. mapper: incremental/global
输出sparse文件夹，包含摄像机参数和稀疏点云
* mapper
* hierarchical_mapper 
4. model merge
可能会生成多个model，可使用model_merger合并，但不一定成功
```bat
.\..\..\..\external\colmap_gpu\colmap_bin\COLMAP.bat model_merger --input_path1 colmap_sparse/0 --input_path2 colmap_sparse/1 --output_path colmap_sparse/01

.\..\..\..\external\colmap_gpu\colmap_bin\COLMAP.bat bundle_adjuster --input_path colmap_sparse/01 --output_path colmap_sparse/01r
```
5. mesh reconstruction -> PoissonRecon
6. texture

```
.\..\..\..\external\colmap_gpu\colmap_bin\COLMAP.bat feature_extractor --ImageReader.camera_model OPENCV --ImageReader.camera_params "" --SiftExtraction.estimate_affine_shape=true --SiftExtraction.domain_size_pooling=true --ImageReader.single_camera 1 --database_path colmap.db --image_path "./images"

.\..\..\..\external\colmap_gpu\colmap_bin\COLMAP.bat sequential_matcher --SiftMatching.guided_matching=true --database_path colmap.db

.\..\..\..\external\colmap_gpu\colmap_bin\COLMAP.bat mapper --database_path colmap.db --image_path "./images" --output_path colmap_sparse

.\..\..\..\external\colmap_gpu\colmap_bin\COLMAP.bat model_converter --input_path colmap_sparse/0 --output_path colmap_text --output_type TXT

python .\..\..\..\scripts\colmap2nerf.py --aabb_scale 128 --images .\images --text .\colmap_text --out .\transforms.json
```
## dense reconstruction
需要GPU  
```bat
.\..\..\..\external\colmap_gpu\colmap_bin\
```
* 图像去畸变
```bat
.\..\..\..\external\colmap_gpu\colmap_bin\COLMAP.bat image_undistorter --image_path ./images --input_path ./colmap_sparse/0 --output_path ./dense --output_type COLMAP
```
输出dense文件夹
```bat
.\..\..\..\external\colmap_gpu\colmap_bin\COLMAP.bat patch_match_stereo --workspace_path ./dense --workspace_format COLMAP --PatchMatchStereo.geom_consistency true
```
输出dense/stereo文件夹，估计每张图像的depthMap和NormalMap
* 融合
```bat
.\..\..\..\external\colmap_gpu\colmap_bin\COLMAP.bat stereo_fusion --workspace_path ./dense --workspace_format COLMAP --input_type geometric --output_path ./dense/result.ply
```
输出点云模型

# nerf
每幅图像对应的传感器位姿[3x4矩阵]（拍摄时每幅图像对应的传感器位姿相对于首幅图像或前一幅图像对应的传感器位姿的参数--旋转R[3x3]和平移t[3x1]）

可使用colmap稀疏重建计算，再通过scripts/colmap2nerf.py进行格式转换
```bat
python ./../../../scripts/colmap2nerf.py --aabb_scale 128 --run_colmap --images ./images
python ./../../../scripts/colmap2nerf.py --video_in D:/dataset/lab/IMG_0080.MOV --video_fps 30 --run_colmap --aabb_scale 128

instant-ngp.exe ./data/fox
```

## video2picture
```bat
ffmpeg.exe -i "D:/dataset/lab/IMG_0080.MOV" -qscale:v 1 -qmin 1 -vf "fps=30.0" "D:/dataset/lab\images"/%04d.jpg

ffmpeg.exe -i "D:/dataset/lab/IMG_0080.MOV" -vcodec libx264 -s 1920x1080 -crf 0 -acodec copy new.mp4
```

## 输入数据对结果的影响分析
1. 图像数量
在角度包含360度全方位的情况下，更多的图像数量对结果没有明显影响
2. 图像分辨率
把原分辨率3080x2160的图像降成1920x1080，对结果没有明显影响
3. 图像清晰度
直接影响到结果的精确度

## 源码说明
load_nerf: 读取输入数据返回NerfDataset，支持的图像格式有
```c++
	std::vector<std::string> supported_image_formats = {
		"png", "jpg", "jpeg", "bmp", "gif", "tga", "pic", "pnm", "psd", "exr",
	};
```
sharpness_discard_threshold: 图像清晰度阈值

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
