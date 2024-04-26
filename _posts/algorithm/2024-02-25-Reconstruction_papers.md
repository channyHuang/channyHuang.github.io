---
layout: default
title: Reconstruction Papers
categories:
- Algorithm
tags:
- Computer Vision
---
//Description: 表面重论文笔记。

//Create Date: 2024-02-25 20:40:39

//Author: channy
[toc]

# open source project
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


# R3Live
## Input Data And Callback
1. IMU: R3LIVE::imu_cbk
2. Image: R3LIVE::image_comp_callback或R3LIVE::image_callback
3. Lidar PointCloud: R3LIVE::feat_points_cbk

## Threads
1. R3LIVE::service_LIO_update: 点云处理线程，R3LIVE构造函数中启动
2. R3LIVE::service_process_img_buffer: 图像处理线程，第一帧图像回调函数中启动
3. R3LIVE::service_VIO_update: 视觉处理线程，R3LIVE::process_image处理第一帧图像时启动
4. render_pts_in_voxels_mp: 计算点云中点对应图像像素点的颜色作为纹理
5. Global_map::service_refresh_pts_for_projection: 计算点云到图像上的映射关系，Global_map的构造函数中启动

## Data Flow
### Start
启动时创建R3LIVE对象fast_lio_instance，在构造函数中加载传感器位姿参数，并启动R3LIVE::service_LIO_update点云处理线程

### IMU Flow
每一帧的IMU数据包含（时间戳、线加速度和角速度），触发回调R3LIVE::imu_cbk，分别加入到imu_buffer_lio和imu_buffer_vio两个队列中，分别供图像帧和点云帧进行积分求得位姿。

### Image Flow
图像处理包含对源图像数据和压缩图像数据的处理，sub_image_typed区分类型。

R3LIVE::service_process_img_buffer线程中，每次循环查询g_received_compressed_img_msg或g_received_img_msg中的图像数据，调用R3LIVE::process_image处理图像。

R3LIVE::process_image中，当首次获取到图像数据即m_camera_start_ros_tim < 0时，启动R3LIVE::service_VIO_update视觉处理线程。并对每一帧图像数据和外参加入到m_queue_image_with_pose队列中。

R3LIVE::service_VIO_update视觉处理线程中，每次循环查询m_queue_image_with_pose中的数据。对每帧图像和外参数据，先调用vio_preintegration对上一帧图像到当前帧图像时间戳之间的imu数据（即imu_buffer_vio队列中的imu数据）进行积分得到摄像机位姿；然后调用Rgbmap_tracker::track_img图像光流跟踪算法；接着启动render_pts_in_voxels_mp线程计算点云中点的颜色；最后存储到Offline_map_recorder中，其中m_pts_in_views_vec存储的即重建的带颜色信息的点云。

### Lidar PointCloud Flow
每一帧的点云数据触发回调R3LIVE::feat_points_cbk，把点云数据加入到队列g_camera_lidar_queue中，交给点云处理线程处理。

R3LIVE::service_LIO_update点云处理线程中，对g_camera_lidar_queue中的每一帧点云数据，调用sync_packages对上一帧点云到当前帧点云时间戳之间的imu数据（即imu_buffer_lio队列中的imu数据）进行积分得到激光传感器位姿，其中通过调用get_pointcloud_data_from_ros_message去除离激光距离大于阈值maximum_range的点；然后调用ImuProcess::Process把点云转换到世界坐标系；再使用PCL库（pcl::VoxelGrid）对点云进行降采样，创建KD树；接着使用ICP对齐（PCA最小二乘）和Kalman滤波调整位姿；最后存储到Offline_map_recorder的Global_map的m_pts_last_hitted中。

## structs
### Global_map
* m_hashmap_3d_pts 每个点对应一个grid，grid的大小m_minimum_pts_size，保证生成的点云间隔一定距离不至于太密
* m_hashmap_voxels 多个grid组成一个voxel，voxel的大小m_voxel_resolution

## test
可以提高回环重合精度的参数：
* m_lio_update_point_step 对降采样后的点云均匀间隔step加入激光传感器位姿调整计算
* m_append_global_map_point_step 对调整后的点云间隔step加入到m_rgb_pts_vec中
* m_image_downsample_ratio 对图像降采样，=1/scale

## Algorithms
### ICP 点云配准
$$ (R, t) -> min \sum_i^{n} |p_i - (R * p_i^{'} + t)|^2 $$
1. KNN查找最近点
2. 求解AX=B (QR分解或LU分解等)

## Functions 
1. selection_points_for_projection 点云投影到图像上，获取投影成功的点云和对应的texcoord
