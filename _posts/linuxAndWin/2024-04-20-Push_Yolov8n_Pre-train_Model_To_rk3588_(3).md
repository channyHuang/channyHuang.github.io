---
layout: default
title: Push Yolov8n Pre-train Model To rk3588 (3)
categories:
- Linux
tags:
- Server
- Linux
---
//Description: 优化。记录yolov8n部署到rk3588后的优化，从原先的单核npu跑修改成使用线程池开3个线程3个核一起跑，本地视频的识别帧率从原来的14+提升到40+，但网络摄像头的识别帧率依旧在15+，最终发现和摄像头支持的最高帧率及当前设置的帧率有关系。

//Create Date: 2024-04-20 10:14:28

//Author: channy

[toc]

# 使用线程池进行多frame检测
## 背景
使用firefly的rk3588，配银河麒麟系统，8G内存，有rga3双核，npu三核。

使用自己训练的模型：
* **方法**： 原先使用单线程，直接从摄像头中读取一帧并进行识别，识别完成后显示，再读取下一帧
* **时间性能**： 本地视频识别帧率14+，其中python推理接口0.05s/帧，后处理0.02s/帧
* **其它性能**： 内存100+M，cpu20%左右，npu核1达20%左右，核2和核3基本没用上，为0% 
* **优化**： 使用线程池开启3个线程，把3个核跑满
* **优化后时间性能**： 本地视频识别帧率40+，网络摄像头识别帧率15+。后发现网络摄像头支持的最大帧率为15。
* **优化后其它性能**： 识别本地视频时，内存100+M，cpu50%左右，npu每个核都占40%左右  

## 代码清单 
1. [threadpool](https://github.com/channyHuang/rk3588DeployNoteAndCode/tree/main/threadpool)
2. [threadpool_board](https://github.com/channyHuang/rk3588DeployNoteAndCode/tree/main/threadpool_board)

# 背景问题
## 问题1：超大图像识别不实时
经过前面的尝试，知道了模型的输入尺寸1920和640对帧率有明显的影响。考虑到超大尺寸的图像直接识别达不到实时需求，故对图像进行分割。

## 问题2：单模型识别大小目标效果不理想
当需要识别的目标种类多且大小相差较大时，使用单个模型识别达不到优秀的效果。

# 解决方案
## 超大图像分割
以尺寸1920X1080的输入图像为例，使用的模型输入尺寸为640（即pt转onnx的转换参数imgsz=640），初始时尝试直接对图像平均分割成4等分，则每份为960X540，再resize到640后进行识别，发现识别帧率只有17+。分析npu3个核占用率分别为38%、18%、18%，时间花费在同步等待上。后改成分割成2X3=6份，每份都为640X640，有重叠。识别帧率提升到20+。

源码片段见附录。

| 分割数量 | 模型尺寸 | fps(py) |
|:---:|:---:|:---:|
| 4 | 1920x1920 | 0.85 | 
| 4 | 1920x1088 | 1.41 |

| 尺寸 | 阈值 | 总目标 | 正确数(占比) | 错误数(占比) | 漏检数(占比) | fps(py) |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
1440x1440 | 0.63 | 11951 | 10534(0.88) | 584(0.04) | 1417(0.12) | 3.23/6.36 |

## 多模型串并联
使用两个模型，其中一个模型识别大目标，另一个识别小目标。考虑到多线程开的3个线程占满了3个核，故先考虑模型串联。尝试发现串联前后帧率相近，均为20+，npu占用率每个核都从18%上升到38%。

# Conv -> ConvExSwish
从`.onnx`到`.rknn`的模型对比，Conv+Sigmoid+Mul合并成了ConvExSwish

# 多Batch使用
模型转换时[ultralytics_yolov8](https://github.com/ultralytics/ultralytics_yolov8)的`default.yaml`里的`batch: 16`在`mode: export`下并没有生效，生成的`.onnx`文件使用`netron`查看还是(1,3,w,h)

在`rknn.build`的`rknn_batch_size=3`设置后，使用`netron`查看`.rknn`模型还是(1,3,w,h)
```python
ret = rknn.build(do_quantization=do_quant, dataset=DATASET_PATH, rknn_batch_size = 3)
```
但此时若使用`init_runtime`设置单核
```python
rknn.init_runtime(core_mask=RKNNLite.NPU_CORE_0)
```
控制台会报
```sh
core mask = 4 is invalid for batch size: 3, fall back to CORE_AUTO mode
```

Python下推理时间也不一样，同样只输入1帧图像的情况下，batch=3时单推理接口用时1.5s，batch=1时单推理接口用时0.5s，有明显差别。

# 附录1：图像分割成640倍数计算offset
```python
import math

MODEL_SIZE = 640

def cal_offset(shape = [1080, 1920]):
    height_num = math.ceil(shape[0] / MODEL_SIZE)
    width_num = math.ceil(shape[1] / MODEL_SIZE)
    block = height_num * width_num
    height_pad, width_pad = 0, 0
    if height_num > 1:
        height_pad = (height_num * MODEL_SIZE - shape[0]) // (height_num - 1)
    if width_num > 1:
        width_pad = (width_num * MODEL_SIZE - shape[1]) // (width_num - 1)
    height_offset = 0
    width_offset = 0
    offset = []
    edge_flag = [False, False]
    while height_offset < shape[0]:
        edge_flag[1] = False
        if height_offset + MODEL_SIZE >= shape[0]:
            height_offset = shape[0] - MODEL_SIZE
            edge_flag[0] = True
        while width_offset < shape[1]:
            if width_offset + MODEL_SIZE > shape[1]:
                width_offset = shape[1] - MODEL_SIZE
                edge_flag[1] = True
            offset.append([height_offset, width_offset])
            if edge_flag[1]:
                break
            width_offset += MODEL_SIZE - width_pad
        if edge_flag[0]:
            break
        height_offset += MODEL_SIZE - height_pad
        width_offset = 0
    return offset
```