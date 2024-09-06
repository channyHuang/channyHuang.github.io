---
layout: default
title: Linux Yolov8 C++ And ROS SLAM
categories:
- Linux
tags:
- Server
- Linux
---
//Description: 记录使用C++在linux上部署yolov8检测和跟踪的过程，及在RK3588带aarch64的Kylin系统上部署ROS+SLAM的过程。遇到`dnn::readNetFromONNX`错误，升级OpenCV版本可解决。同时记录输入图像尺寸和模型尺寸不一致时出现的错误。写于2024年夏。

//Create Date: 2024-06-11 14:14:28

//Author: channy

[toc]

# 代码清单 
[rk3588DeployNoteAndCode](https://github.com/channyHuang/rk3588DeployNoteAndCode)

# OpenCV版本 
使用Opencv4.2在`dnn::readNetFromONNX(ModelPath);`时会报错，改用Opencv4.9则该报错消失。
```sh
tensor_proto.raw_data().empty() || !tensor_proto.float_data().empty() || !tensor_proto.double_data().empty() || !tensor_proto.int64_data().empty()
```

# 输入图像尺寸和模型尺寸
当输入图像尺寸和模型输入尺寸不一致时会报错，改成模型尺寸则该报错消失。
```sh
[ERROR:0@0.134] global net_impl.cpp:1162 getLayerShapesRecursively OPENCV/DNN: [Reshape]:(onnx_node!/model.22/dfl/Reshape): getMemoryShapes() throws exception. inputs=1 outputs=1/1 blobs=0
[ERROR:0@0.134] global net_impl.cpp:1168 getLayerShapesRecursively     input[0] = [ 1 64 75600 ]
[ERROR:0@0.134] global net_impl.cpp:1172 getLayerShapesRecursively     output[0] = [ ]
[ERROR:0@0.134] global net_impl.cpp:1178 getLayerShapesRecursively Exception message: OpenCV(4.9.0-dev) /home/channy/Documents/thirdlibs/opencv-4.x/modules/dnn/src/layers/reshape_layer.cpp:109: error: (-215:Assertion failed) total(srcShape, srcRange.start, srcRange.end) == maskTotal in function 'computeShapeByReshapeMask'

terminate called after throwing an instance of 'cv::Exception'
  what():  OpenCV(4.9.0-dev) /home/channy/Documents/thirdlibs/opencv-4.x/modules/dnn/src/layers/reshape_layer.cpp:109: error: (-215:Assertion failed) total(srcShape, srcRange.start, srcRange.end) == maskTotal in function 'computeShapeByReshapeMask'

Aborted (core dumped)
```

# 在RK3588上部署ROS+SLAM
## 环境
* roc-rk3588s-pc 板子
* kylin v10 桌面版系统
* aarch64 

以部署[VINS-Mono](https://github.com/HKUST-Aerial-Robotics/VINS-Mono.git)为例。

## 分析
1. kylin系统直接安装ros
ros官方并不支持kylin系统，直接在kylin系统上增加ros的源直接安装ros报找不到包的错误。

故考虑docker。

2. 直接使用aarch64的ros镜像
一开始是考虑直接pull下aarch64的ros镜像
```sh
docker pull arm64v8/ros:noetic-ros-core
```
使用国内源镜像pull不成功，报`timeout`错误，试了好几个ros1版本的均失败。

2. 使用ubuntu镜像并在其中安装ros
改考虑docker跑ubuntu镜像并在上面安装ros。
```sh
docker pull arm64v8/ubuntu
```
一开始指定了aarch64但没有指定ubuntu的版本，直接拉的24.04，pull成功，但启动失败。
```sh
docker pull arm64v8/ubuntu:20.04
```
换了指定ubuntu版本依旧是pull成功，但启动失败。

后面查看了官方hello-world中的提示，不指定aarch64
```sh
docker run -it ubuntu bash
```
能够成功pull下ubuntu 24.04的镜像。但目前为止ros对ubuntu 24 的支持还不完善，安装ros过程中遇到报错没有完全解决。故改用ubuntu 20.04。
```sh
docker run -it ubuntu：20.04 bash
```
能够启动成功，在上面换国内源安装ros，项目需要安装的是noetic。

正常安装完成ros后能够成功运行项目代码。

4. 使用docker跑ubuntu镜像并在其中跑docker的ros镜像
发现docker里面是不允许再跑docker的。

# SLAM在NPU上的优化 
## [VINS-Mono]基本流程
1. rosbag play YOUR_PATH_TO_DATASET/MH_01_easy.bag
根据时间戳

2. roslaunch vins_estimator euroc.launch  

2.1 feature_tracker
* readIntrinsicParameter 读取摄像机内参
* img_callback // 当图像时间戳间隔过大或早于当前时间时发送重置消息restart，使用cv::createCLAHE计算图像直方图，得到特征点，发送特征点消息到vins_estimator和rviz显示
  * FeatureTracker::readImage // cv::calcOpticalFlowPyrLK光流跟踪，cv::findFundamentalMat计算基本矩阵  

2.2 vins_estimator
* imu_callback
  * predict // $s_{t+1} = s_t + v_t * t + 0.5 * a * t * t$
* feature_callback // 检测的特征点
* restart_callback // 重置imu，重新开始积分 
* relocalization_callback // 监听pose_graph发送的match_points消息，根据关键帧特征点快速重定位（回环检测）
* process 主线程，imu积分，sfm重建，ceres求解，pub消息 
  * getMeasurements 等够estimator.td时间的imu数据，和feature数据打包
  * processIMU // 同predict?
  * setReloFrame // 当需要重定位时使用
  * processImage
    * getCorresponding // 对两帧图像的特征点进行匹配
    * solveOdometry // 
      * FeatureManager::triangulate // 使用svd分解求每个特征值的深度
      * optimization // 使用ceres库求解  

2.3 pose_graph
* PoseGraph
  * optimize4DoF
* imu_forward_callback // 从vins_estimator中接收odometry消息
* vio_callback // 从vins_estimator中接收odometry消息，发送key_odometrys给rviz显示
* image_callback // image_buf，给process提供数据，给显示发消息
* pose_callback // pose_buf，给process提供数据
* point_callback // point_buf，给process提供数据
* process // 创建KeyFrame，回环检测，或重定位

3. roslaunch vins_estimator vins_rviz.launch
显示

## 优化方向
### 矩阵计算改成npu
但npu的矩阵运算
$$A_{MxK} * B_{KxN} = C_{MxN}$$
只支持K是32的倍数，N是16的倍数。

经实验，当矩阵维度太大时(128x128x128?)会出现内存错误而导致矩阵运算失败。

且从时间统计上看，同样的数据，使用npu耗时并没有比使用cpu耗时有减少。
### 使用OpenCL加速图像特征点检测
默认的Kylin系统用apt安装的opencv不带opencl，需要重新勾选上opencl重新编译opencv。

但从多帧检测的统计结果看，对500帧图像检测特征点并计算总时长，opencl仅比cpu少用1秒。

```c++
#include <iostream>
#include <opencv2/opencv.hpp>
#include <opencv2/core/ocl.hpp>

int main() {
    // 检查是否有可用的 OpenCL（用于 GPU 加速）
    if (!cv::ocl::haveOpenCL()) {
        std::cout << "OpenCL is not available." << std::endl;
        return -1;
    }

    // 设置 OpenCL 为可用状态
    cv::ocl::setUseOpenCL(true);

    // 读取图像
    cv::Mat image = cv::imread("your_image.jpg");
    if (image.empty()) {
        std::cout << "Could not read the image." << std::endl;
        return -1;
    }

    // 创建特征点检测器
    cv::Ptr<cv::Feature2D> detector = cv::ORB::create();

    // 检测特征点
    std::vector<cv::KeyPoint> keypoints;
    cv::Mat descriptors;
    detector->detectAndCompute(image, cv::noArray(), keypoints, descriptors);

    // 绘制特征点
    cv::Mat outputImage;
    cv::drawKeypoints(image, keypoints, outputImage, cv::Scalar::all(-1), cv::DrawMatchesFlags::DEFAULT);

    // 显示结果
    cv::imshow("Image with Keypoints", outputImage);
    cv::waitKey(0);

    return 0;
}
```