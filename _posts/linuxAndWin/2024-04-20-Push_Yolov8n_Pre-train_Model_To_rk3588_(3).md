---
layout: default
title: Push Yolov8n Pre-train Model To rk3588 (3)
categories:
- Linux
tags:
- Server
- Linux
---
//Description: 记录yolov8n部署到rk3588后的优化，从原先的单核npu跑修改成使用线程池开3个线程3个核一起跑，本地视频的识别帧率从原来的14+提升到40+，但网络摄像头的识别帧率依旧在15+，最终发现和摄像头支持的最高帧率及当前设置的帧率有关系。另外发现rknn_model_zoo对图像的处理没有考虑非16倍长宽的图像，也没有考虑内存大于4G时的rga函数imfill的使用，对此进行了修改。

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

# C++输入不同尺寸图像报错
模型输入尺寸是640x640的。
## 1. 报`src unsupport width stride 750`错误
输入图像尺寸是750x750时报错，原因为rga只支持16位对齐的数据，把图像先resize为736x736的，该错误消失。

也就是说，rknn_model_zoo里面是没有对输入图像尺寸非16的倍数这种情况做处理的。
```sh
$ ./rknn_yolov8_demo ../model/v8n_640.rknn ../model/test.jpg

Error on improcess STATUS=-1
RGA error message: Unsupported function: src unsupport width stride 750, rgb888 width stride should be 16 aligned!

// convert_image_rga in image_utils.c 
```

修改方法可以在convert_image_rga函数中improcess之前增加非16倍数的图像做裁剪或填充处理，类似长宽尺寸不相等时的填充处理部分。具体代码可以使用rga的scale相关的函数，这样可以在3588上加速。

## 2. rga输出一堆类似错误的信息
输入图像尺寸是2880x1616时不算报错，但在首帧识别结束运行第二帧的时候，会停止在improcess之前不往下走，有点像死锁的现象。
```sh
$ ./rknn_yolov8_demo ../model/v8n_640.rknn ./out.jpg

fill dst image (x y w h)=(0 0 640 640) with color=0x72727272
 RgaCollorFill(1819) RGA_COLORFILL fail: Invalid argument
 RgaCollorFill(1820) RGA_COLORFILL fail: Invalid argument
69 im2d_rga_impl rga_task_submit(2171): Failed to call RockChipRga interface, please use 'dmesg' command to view driver error log.
69 im2d_rga_impl rga_dump_channel_info(1500): src_channel: 
  rect[x,y,w,h] = [0, 0, 0, 0]
  image[w,h,ws,hs,f] = [0, 0, 0, 0, rgba8888]
  buffer[handle,fd,va,pa] = [0, 0, 0, 0]
  color_space = 0x0, global_alpha = 0x0, rd_mode = 0x0

69 im2d_rga_impl rga_dump_channel_info(1500): dst_channel: 
  rect[x,y,w,h] = [0, 0, 640, 640]
  image[w,h,ws,hs,f] = [640, 640, 640, 640, rgb888]
  buffer[handle,fd,va,pa] = [154, 0, 0, 0]
  color_space = 0x0, global_alpha = 0xff, rd_mode = 0x1

69 im2d_rga_impl rga_dump_opt(1550): opt version[0x0]:

69 im2d_rga_impl rga_dump_opt(1551): set_core[0x0], priority[0]

69 im2d_rga_impl rga_dump_opt(1554): color[0x72727272] 
69 im2d_rga_impl rga_dump_opt(1563): 

69 im2d_rga_impl rga_task_submit(2180): acquir_fence[-1], release_fence_ptr[0x0], usage[0x280000]

// 使用线程读取摄像头几帧(<30帧)后，停在此处
```

关于报错中的`RgaCollorFill(1819) RGA_COLORFILL fail: Invalid argument`并不是网上一些文章说的rga3不支持imfill函数，实际是支持的。应该和内存分配有关系，改成用`dma_buf_alloc`分配该错误消失。

```c++
// image_utils.h
    int set_image_dma_buf_alloc(image_buffer_t* img);
// image_utils.cpp
    int set_image_dma_buf_alloc(image_buffer_t* img) {
        int ret = dma_buf_alloc(DMA_HEAP_DMA32_UNCACHE_PATCH, img->size, &img->fd, (void **)&img->virt_addr);
        return ret;
    }
// yolov8.cc
    // Pre Process
    dst_img.width = app_ctx->model_width;
    dst_img.height = app_ctx->model_height;
    dst_img.format = IMAGE_FORMAT_RGB888;
    dst_img.size = get_image_size(&dst_img);
    if (dst_img.virt_addr == nullptr) {
        //dst_img.virt_addr = (unsigned char *)malloc(dst_img.size);
        set_image_dma_buf_alloc(&dst_img);
    }
    if (dst_img.virt_addr == NULL)
    {
        printf("malloc buffer size:%d fail!\n", dst_img.size);
        return -1;
    }
    ......
out:
    if (dst_img.virt_addr != NULL)
    {
        //free(dst_img.virt_addr);
        image_dma_buf_free(&dst_img);
        dst_img.virt_addr = NULL;
    }
```

但使用线程读取摄像头几帧(<30帧)后停止不前的现象还有，确认进到improcess函数一直停在里面没有跑完该函数。

最后发现是`dma_buf_alloc`没有对应的free导致，加上free后还需要注意free并不会把`virt_addr`设回空，需要自行置空。另外报dma allocate fail分配失败也是类似的错误，`dma_buf_alloc`一定要有对应的`dma_buf_free`，就跟c++的`new/delete`和`malloc/free`对应一样，否则会有内存泄漏。

# 背景问题
## 问题1：超大图像识别不实时
经过前面的尝试，知道了模型的输入尺寸1920和640对帧率有明显的影响。考虑到超大尺寸的图像直接识别达不到实时需求，故对图像进行分割。

## 问题2：单模型识别大小目标效果不理想
当需要识别的目标种类多且大小相差较大时，使用单个模型识别达不到优秀的效果。

# 解决方案
## 超大图像分割
以尺寸1920X1080的输入图像为例，使用的模型输入尺寸为640（即pt转onnx的转换参数imgsz=640），初始时尝试直接对图像平均分割成4等分，则每份为960X540，再resize到640后进行识别，发现识别帧率只有17+。分析npu3个核占用率分别为38%、18%、18%，时间花费在同步等待上。后改成分割成2X3=6份，每份都为640X640，有重叠。识别帧率提升到20+。

源码片段见附录。

## 多模型串并联
使用两个模型，其中一个模型识别大目标，另一个识别小目标。考虑到多线程开的3个线程占满了3个核，故先考虑模型串联。尝试发现串联前后帧率相近，均为20+，npu占用率每个核都从18%上升到38%。

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