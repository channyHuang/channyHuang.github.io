---
layout: default
title: Linux Yolov8 C++
categories:
- Linux
tags:
- Server
- Linux
---
//Description: 记录使用C++在linux上部署yolov8检测和跟踪的过程。遇到`dnn::readNetFromONNX`错误，升级OpenCV版本可解决。同时记录输入图像尺寸和模型尺寸不一致时出现的错误。

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
