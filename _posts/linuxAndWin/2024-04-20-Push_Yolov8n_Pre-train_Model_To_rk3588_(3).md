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

# 量化算法对比
其中量化接口中量化算法`quantized_algorithm`有三种选择：`normal`, `mmse`, `kl_divergence`，默认用的是`normal`
```python
    rknn.config(mean_values=[128, 128, 128], std_values=[128, 128, 128], 
                quant_img_RGB2BGR = False, 
                quantized_dtype = 'asymmetric_quantized-8', 
                quantized_method = 'layer', 
                quantized_algorithm = 'normal' # normal, mmse, kl_divergence
    )
```
输入尺寸为1920x1088的模型，使用130张图像作为量化数据集。

其中`mmse`报内存不足错误量化失败...使用的是RTX 3090的机器...

使用`rknn_model_zoo`中的yolov8.py进行精度统计。得到结论如下：
* 使用不同的量化数据集，`normal`和`kl_divergence`各有千秋，但两种算法得出来的精度差都小于0.003
* 使用相同的量化数据集，`normal`统计得到的精度比`kl_divergence`要高一点，高出值小于0.003
```sh
# 模型1使用数据集A，normal算法
Average Precision  (AP) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.661
 Average Precision  (AP) @[ IoU=0.50      | area=   all | maxDets=100 ] = 0.847
 Average Precision  (AP) @[ IoU=0.75      | area=   all | maxDets=100 ] = 0.761
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.500
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.685
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.810
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=  1 ] = 0.689
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets= 10 ] = 0.695
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.695
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.529
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.722
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.823
map  -->  0.6605219808700262
map50-->  0.8470041428157167
map75-->  0.7609103938797357
map85-->  0.7223725490196078
map95-->  0.823076923076923



# 模型1使用数据集A，KL算法
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.630
 Average Precision  (AP) @[ IoU=0.50      | area=   all | maxDets=100 ] = 0.838
 Average Precision  (AP) @[ IoU=0.75      | area=   all | maxDets=100 ] = 0.748
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.511
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.649
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.812
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=  1 ] = 0.658
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets= 10 ] = 0.663
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.663
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.542
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.688
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.821
map  -->  0.6302562523675191
map50-->  0.8377440352117917
map75-->  0.7475242527036031
map85-->  0.6881764705882353
map95-->  0.8211538461538461



# 模型1使用数据集A，normal算法，rgb2bgr设为True
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.639
 Average Precision  (AP) @[ IoU=0.50      | area=   all | maxDets=100 ] = 0.851
 Average Precision  (AP) @[ IoU=0.75      | area=   all | maxDets=100 ] = 0.763
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.508
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.666
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.811
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=  1 ] = 0.670
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets= 10 ] = 0.676
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.676
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.542
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.710
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.821
map  -->  0.6392917713976933
map50-->  0.8509087057354383
map75-->  0.7626395237690455
map85-->  0.709529411764706
map95-->  0.8211538461538461



# 模型1使用数据集A，KL算法，rgb2bgr设为True
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.627
 Average Precision  (AP) @[ IoU=0.50      | area=   all | maxDets=100 ] = 0.828
 Average Precision  (AP) @[ IoU=0.75      | area=   all | maxDets=100 ] = 0.754
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.514
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.646
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.767
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=  1 ] = 0.653
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets= 10 ] = 0.658
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.658
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.546
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.683
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.828
map  -->  0.6270778561720423
map50-->  0.8281628162816281
map75-->  0.754006396003263
map85-->  0.6825098039215686
map95-->  0.8278846153846156



# 模型1使用数据集B，normal算法
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.640
 Average Precision  (AP) @[ IoU=0.50      | area=   all | maxDets=100 ] = 0.856
 Average Precision  (AP) @[ IoU=0.75      | area=   all | maxDets=100 ] = 0.764
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.486
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.661
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.764
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=  1 ] = 0.671
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets= 10 ] = 0.676
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.676
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.529
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.701
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.822
map  -->  0.6398269637540307
map50-->  0.8561360283493789
map75-->  0.7643781763368628
map85-->  0.7009607843137255
map95-->  0.8221153846153848



# 模型2使用数据集C，normal算法
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.681
 Average Precision  (AP) @[ IoU=0.50      | area=   all | maxDets=100 ] = 0.911
 Average Precision  (AP) @[ IoU=0.75      | area=   all | maxDets=100 ] = 0.803
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.667
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.724
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.587
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=  1 ] = 0.307
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets= 10 ] = 0.713
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.726
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.696
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.770
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.612
map  -->  0.6807538123398008
map50-->  0.9106005895949721
map75-->  0.8034101483997518
map85-->  0.7697170738162189
map95-->  0.6119744507465746



# 模型2使用数据集C，KL算法
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.688
 Average Precision  (AP) @[ IoU=0.50      | area=   all | maxDets=100 ] = 0.908
 Average Precision  (AP) @[ IoU=0.75      | area=   all | maxDets=100 ] = 0.807
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.638
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.730
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.592
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=  1 ] = 0.303
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets= 10 ] = 0.714
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.727
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.663
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.770
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.613
map  -->  0.6875320399843964
map50-->  0.9081044717132812
map75-->  0.8073981486818188
map85-->  0.7701273658941363
map95-->  0.6133057282946665
```

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