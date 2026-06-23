---
layout: default
title: Reconstruction Papers
categories:
- Algorithm
tags:
- Computer Vision
---
//Description: 利用imu+激光点云+图像进行实时三维重建技术笔记。

//Create Date: 2024-02-25 20:40:39

//Author: channy
[toc]

<font color = red>已有项目阅读笔记</font>  

# 前言: 关于坐标系转换参数的笔记
在三维重建中使用到各个坐标系之间的转换，以雷达坐标系L和相机坐标系C为说明，把相机坐标系C放在雷达坐标系L的x轴前方7个单位处：
```c++
    y                                                       y
    |                                                       |
    |                                                       |
    |                                                       |
    |                                                       |
    |                                                       | (1m)
    L-----------> x                 (<-7m->)                C-----P-----> x 
   /                                                       /
  /                                                       /
 /                                                       /
z                                                       z
```
则相机坐标系C到雷达坐标系L的转换参数${R_{cl}, t_{cl}}$有两种可能的意思并且这两种意思对应的操作正好相反：  
1. 把在相机坐标系C下的点 $P_c = \{1,0,0\}$ 转换到雷达坐标系L下$P_l = \{8,0,0\} $，即转换参数满足  
$$ R_{cl} * P_c + t_{cl} = P_l $$
按这种意思，转换参数 $R_{cl} = E, t_{cl} = \{7,0,0\}$  

2. 把相机坐标系C经过旋转平移变成雷达坐标系L对应的操作，即应该把相机坐标系C沿x轴负方向水平移动7个单位。  
按这种意思，转换参数 $R_{cl} = E, t_{cl} = \{-7,0,0\}$ 

也就是说，对坐标系的转换参数定义或理解不一样，会导致对应的参数相逆。

增加旋转后更能证明，如果按意思1的转换参数是$\{R,t\}$，那么按意思2的参数则变成了$\{R^{-1}, R^{-1} * (-t) \}$

故，在研究一个项目之前，强烈建议该项目的作者是按哪种意思写的坐标系转换参数，并对比是否和自己的数据参数相一致，否则在改成自己的数据后容易出现效果差异太大等问题。

# R3LIVE
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

```c++
R3LIVE::service_process_img_buffer // 线程中，每次循环查询g_received_compressed_img_msg或g_received_img_msg中的图像数据，调用R3LIVE::process_image处理图像。

R3LIVE::process_image // 当首次获取到图像数据即m_camera_start_ros_tim < 0时，启动R3LIVE::service_VIO_update视觉处理线程。并对每一帧图像数据和外参加入到m_queue_image_with_pose队列中。

R3LIVE::service_VIO_update // 视觉处理线程中，每次循环查询m_queue_image_with_pose中的数据。
    Global_map::selection_points_for_projection // 初始时使用m_rgb_pts_vec 中的点投影到图像中作为初始跟踪点
    vio_preintegration // 对每帧图像和外参数据，先调用vio_preintegration对上一帧图像到当前帧图像时间戳之间的imu数据（即imu_buffer_vio队列中的imu数据）进行积分得到摄像机位姿；
        ImuProcess::imu_preintegration // dt<= 50ms，积分得到的pose作为每帧图像的pos
    Rgbmap_tracker::track_img // 然后调用Rgbmap_tracker::track_img图像光流跟踪算法，但不改变pose值，其中跟踪的点 m_last_tracked_pts 由激光点云中能投影到图像上的点组成并存储到 m_map_rgb_pts_in_last_frame_pos 中
    render_pts_in_voxels_mp　// 接着启动render_pts_in_voxels_mp线程计算点云中点的颜色；
    Offline_map_recorder::insert_image_and_pts // 最后存储到Offline_map_recorder中，其中m_pts_in_views_vec存储的即重建的带颜色信息的点云。
    Rgbmap_tracker::update_and_append_track_pts // 把 m_map_rgb_pts_in_last_frame_pos 中能投影到图像中的点更新到m_last_tracked_pts中
```

### Lidar PointCloud Flow
每一帧的点云数据触发回调R3LIVE::feat_points_cbk，把点云数据加入到队列g_camera_lidar_queue中，交给点云处理线程处理。

```c++
R3LIVE::service_LIO_update // 点云处理线程
    sync_packages // 对g_camera_lidar_queue中的每一帧点云数据，调用sync_packages对上一帧点云到当前帧点云时间戳之间的imu数据（即imu_buffer_lio队列中的imu数据）进行积分得到激光传感器位姿，其中通过调用get_pointcloud_data_from_ros_message去除离激光距离大于阈值maximum_range的点；
    ImuProcess::Process // 然后调用ImuProcess::Process把点云转换到世界坐标系；
    // 再使用PCL库（pcl::VoxelGrid）对点云进行降采样，创建KD树；
    KD_TREE::Nearest_Search // 接着使用ICP对齐（PCA最小二乘）进行平面估算
    set_initial_state_cov // EKF扩展Kalman滤波调整位姿g_lio_state；
    append_points_to_global_map // 最后存储到Offline_map_recorder的Global_map的m_rgb_pts_vec和m_pts_last_hitted中。
```

## structs
### Global_map
* m_hashmap_3d_pts 每个点对应一个grid，grid的大小m_minimum_pts_size，保证生成的点云间隔一定距离不至于太密
* m_hashmap_voxels 多个grid组成一个voxel，voxel的大小m_voxel_resolution

## test
可以提高回环重合精度的参数：
* m_lio_update_point_step 对降采样后的点云均匀间隔step加入激光传感器位姿调整计算
* m_append_global_map_point_step 对调整后的点云间隔step加入到m_rgb_pts_vec中
* m_image_downsample_ratio 对图像降采样，=1/scale

## Functions 
1. selection_points_for_projection 点云投影到图像上，获取投影成功的点云和对应的texcoord

