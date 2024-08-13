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
