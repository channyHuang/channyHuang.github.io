---
layout: default
title: Push Yolov8n Pre-train Model To rk3588 (4)
categories:
- Linux
tags:
- Server
- Linux
---
//Description: c++部署和优化。记录yolov8n部署到rk3588使用C++部署和优化过程。发现rknn_model_zoo对图像的处理没有考虑非16倍长宽的图像，也没有考虑内存大于4G时的rga函数imfill的使用，对此进行了修改。同时发现零拷贝在帧率上并没有明显提升；多核`ConvExSwish`算子不生效等等问题。转成c++后每帧从python的0.5s降到0.35s，主要耗时均在SDK的三个api中(rknn_init,rknn_inputs_set,rknn_run)，每个api用时0.1+s，整个识别过程就特别慢。

//Create Date: 2024-07-18 09:27:01

//Author: channy

[toc]

# 代码清单
[cpp](https://github.com/channyHuang/rk3588DeployNoteAndCode/cpp)

# C++基本流程
参考yolov8的demo中c++的实现，主要文件有3个：
* main.cc
* yolov8.cc
* postprocess.cc
主要函数有：
```c++
init_post_process //从文件中读取label
	loadLabelName
init_yolov8_model //加载模型，调用rknn_init和rknn_query两个api接口
read_image //读取图像
inference_yolov8_model //推理，调用rknn_run
	convert_image_with_letterbox 
		convert_image 
			convert_image_rga
	rknn_inputs_set
	rknn_run
	rknn_outputs_get
	post_process //后处理，根据threshold过滤检测结果
        process_fp32 // threshold过滤
write_image //写结果图像到文件
```

自己的模型改成c++的话主要修改post_process的后处理函数。

* c++的耗时集中在rknn_init、rknn_inputs_set和rknn_run三个函数中，自己的模型用时分别为0.09+s/帧、0.11+s/帧、0.13+s/帧，总用时0.35+s/帧。

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

图像输入使用的是RawRGB原始数据，即width*height*channel个char的数据可直接输入，jpg的数据需要使用SDK里面的imgutils库转化。

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

# C++优化
## zero copy API 零拷贝
零拷贝`rknn_create_mem`和`rknn_set_io_mem`，直接用`rknn_model_zoo`样例中的`yolov8_rv1106_1103.cc`理论上也可以，但实际测试发现强信赖于目标个数的设置，有时会检测不到目标。具体原因暂未知。

直接修改`CMakeLists.txt`使用`rv1106_1103`的代码可实现零拷贝。
```c++
if (TARGET_SOC STREQUAL "rv1106" OR TARGET_SOC STREQUAL "rv1103")
    add_definitions(-DRV1106_1103)
    set(rknpu_yolov8_file rknpu2/yolov8_rv1106_1103.cc)
    #dma
    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../../3rdparty/allocator/dma)
else()
#dma
add_definitions(-DRV1106_1103)
set(rknpu_yolov8_file rknpu2/yolov8_rv1106_1103.cc)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../../3rdparty/allocator/dma)
endif()
```

但从实验上看，零拷贝和不用零拷贝在rk3588上的帧率差别不大甚至零拷贝的帧率略有下降。具体原因暂未知。

## NPU多核配置
```c++
// NPU多核配置
    rknn_core_mask core_mask = RKNN_NPU_CORE_0_1_2;
    ret = rknn_set_core_mask(ctx, core_mask);
```

配置多核后查看性能统计信息中的`WorkLoad`一栏，能够看到对`Add`和`Concat`算子确实是3个核并行计算了，但`ConvExSwish`算子依旧是单核。而且`onnx`模型中`ConvExSwish`算子对应的是`Conv`，按文档`Conv`是可以多核并行的，而`ConvExSwish`没有说明。记下待查。

```sh
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                                         Network Layer Information Table                                                                               
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ID   OpType           DataType Target InputShape                               OutputShape            Cycles(DDR/NPU/Total)    Time(us)     MacUsage(%)          WorkLoad(0/1/2)      RW(KB)       FullName        
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
......
7    ConvExSwish      INT8     NPU    (1,16,480,480),(16,16,3,3),(16)          (1,16,480,480)         311802/2073600/2073600   3973         4.35/4.35/4.35       100.0%/0.0%/0.0%     3602         Conv:/model.2/m.0/cv2/conv/Conv
8    Add              INT8     NPU    (1,16,480,480),(1,16,480,480)            (1,16,480,480)         467541/0/467541          573          \                    33.3%/33.3%/33.3%    7200         Add:/model.2/m.0/Add
9    Concat           INT8     NPU    (1,16,480,480),(1,16,480,480),...        (1,48,480,480)         935081/0/935081          1283         \                    33.3%/33.3%/33.3%    10800        Concat:/model.2/Concat
......
```

## dynamic shape
动态shape需要NPU驱动0.9.2或以上，而NPU驱动是直接在固件上的，即升级NPU驱动需要直接刷新固件。

## 自定义算子
对自定义的算子，至rknn的SDK2.0.0版本时只支持onnx模型。主要操作为定义算子运算，然后注册算子即可。
### 定义算子运算
```c++
/**
 * float32 kernel implemetation sample for custom cpu op
 * */
int compute_custom_sigmoid_float32(rknn_custom_op_context* op_ctx, rknn_custom_op_tensor* inputs, uint32_t n_inputs,
                                    rknn_custom_op_tensor* outputs, uint32_t n_outputs)
{
    unsigned char*      in_ptr   = (unsigned char*)inputs[0].mem.virt_addr + inputs[0].mem.offset;
    unsigned char*      out_ptr  = (unsigned char*)outputs[0].mem.virt_addr + outputs[0].mem.offset;
    const float*        in_data  = (const float*)in_ptr;
    float*              out_data = (float*)out_ptr;

    // kernel implemetation for custom sigmoid cpu op
    {
        int inside  = 1;

        for (int i = 0; i < inputs[0].attr.n_dims; i++) {
            inside *= inputs[0].attr.dims[i];
        }

        for (int y = 0; y < inside; y++) {
            const float* src_y    = in_data  + y;
            float*       dst_y    = out_data + y;
            dst_y[0] = 1 / (1 + exp(-src_y[0]));
        }
    }
    return 0;
}
```
### 注册算子
```c++
  // register a custom op
  rknn_custom_op user_op[1];
  memset(user_op, 0, sizeof(rknn_custom_op));
  strncpy(user_op[0].op_type, "cstSigmoid", RKNN_MAX_NAME_LEN - 1);
  user_op[0].version = 1;
  user_op[0].target  = RKNN_TARGET_TYPE_CPU;
  user_op[0].compute = compute_custom_sigmoid_float32;
  ret = rknn_register_custom_ops(ctx, user_op, 1);
  if (ret < 0) {
      printf("rknn_register_custom_op fail! ret = %d\n", ret);
      return -1;
  }
```

## 多Batch使用
```c++
// 多batch推理
    rknn_set_batch_core_num(ctx, 3);
```
设置多Batch后查看npu占用率能明显看到3个核都非空闲，有一定效果。

## 模型稀疏化推理
yolov8转换失败。

# 附录1：根据自己的模型修改后处理函数
```c++
static int process_fp32(float *box_tensor, int grid_w, int grid_h,
                        std::vector<float> &boxes, 
                        std::vector<float> &objProbs, 
                        std::vector<int> &classId, 
                        float threshold)
{
    int validCount = 0;
    int grid_len = grid_h;

    for (int i = 0; i < grid_h; i++)
    {
        int offset = i;
        int max_class_id = -1;

        float max_score = 0;
        int pad = (grid_len << 2);
        for (int c= 0; c< OBJ_CLASS_NUM; c++){
            if ((box_tensor[pad + offset] > threshold) && (box_tensor[pad + offset] > max_score))
            {
                max_score = box_tensor[pad + offset];
                max_class_id = c;
            }
            offset += grid_len;
        }

        // compute box
        if (max_score> threshold){
            offset = i;
            float box[4];
            for (int k=0; k < 4; k++){
                box[k] = box_tensor[offset];
                offset += grid_len;
            }

            float x1,y1,w,h;
            x1 = box[0];
            y1 = box[1];
            w = box[2];
            h = box[3];
            boxes.push_back(x1);
            boxes.push_back(y1);
            boxes.push_back(w);
            boxes.push_back(h);
            objProbs.push_back(max_score);
            classId.push_back(max_class_id);
            validCount ++;
        }
    }
    return validCount;
}
```

# 附录2：c++性能统计结果
```sh
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                                         Network Layer Information Table                                                                               
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ID   OpType           DataType Target InputShape                               OutputShape            Cycles(DDR/NPU/Total)    Time(us)     MacUsage(%)          WorkLoad(0/1/2)      RW(KB)       FullName        
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
1    InputOperator    UINT8    CPU    \                                        (1,3,1920,1088)        0/0/0                    9            \                    0.0%/0.0%/0.0%       0            InputOperator:images
2    ConvExSwish      UINT8    NPU    (1,3,1920,1088),(16,3,3,3),(16)          (1,16,960,544)         1222645/4700160/4700160  9524         0.77/0.77/0.77       100.0%/0.0%/0.0%     6122         Conv:/model.0/conv/Conv
3    ConvExSwish      INT8     NPU    (1,16,960,544),(32,16,3,3),(32)          (1,32,480,272)         1048205/1175040/1175040  2817         6.95/6.95/6.95       100.0%/0.0%/0.0%     8164         Conv:/model.1/conv/Conv
4    ConvExSwish      INT8     NPU    (1,32,480,272),(32,32,1,1),(32)          (1,32,480,272)         698639/522240/698639     12009        0.36/0.36/0.36       100.0%/0.0%/0.0%     4081         Conv:/model.2/cv1/conv/Conv
5    Split            INT8     NPU    (1,32,480,272),(2)                       (1,16,480,272),...     698534/0/698534          2391         \                    100.0%/0.0%/0.0%     4080         Split:/model.2/Split
6    ConvExSwish      INT8     NPU    (1,16,480,272),(16,16,3,3),(16)          (1,16,480,272)         349481/1175040/1175040   2515         3.89/3.89/3.89       100.0%/0.0%/0.0%     2042         Conv:/model.2/m.0/cv1/conv/Conv
7    ConvExSwish      INT8     NPU    (1,16,480,272),(16,16,3,3),(16)          (1,16,480,272)         349481/1175040/1175040   2378         4.12/4.12/4.12       100.0%/0.0%/0.0%     2042         Conv:/model.2/m.0/cv2/conv/Conv
8    Add              INT8     NPU    (1,16,480,272),(1,16,480,272)            (1,16,480,272)         523899/0/523899          619          \                    33.3%/33.3%/33.3%    4080         Add:/model.2/m.0/Add
9    Concat           INT8     NPU    (1,16,480,272),(1,16,480,272),...        (1,48,480,272)         1047798/0/1047798        1339         \                    33.3%/33.3%/33.3%    6120         Concat:/model.2/Concat
10   ConvExSwish      INT8     NPU    (1,48,480,272),(32,48,1,1),(32)          (1,32,480,272)         873315/522240/873315     2617         2.49/2.49/2.49       100.0%/0.0%/0.0%     6121         Conv:/model.2/cv2/conv/Conv
11   ConvExSwish      INT8     NPU    (1,32,480,272),(64,32,3,3),(64)          (1,64,240,136)         525483/587520/587520     1445         13.55/13.55/13.55    100.0%/0.0%/0.0%     4098         Conv:/model.3/conv/Conv
12   ConvExSwish      INT8     NPU    (1,64,240,136),(64,64,1,1),(64)          (1,64,240,136)         349652/261120/349652     1407         3.09/3.09/3.09       100.0%/0.0%/0.0%     2044         Conv:/model.4/cv1/conv/Conv
13   Split            INT8     NPU    (1,64,240,136),(2)                       (1,32,240,136),...     349268/0/349268          1005         \                    100.0%/0.0%/0.0%     2040         Split:/model.4/Split
14   ConvExSwish      INT8     NPU    (1,32,240,136),(32,32,3,3),(32)          (1,32,240,136)         175425/293760/293760     783          12.51/12.51/12.51    100.0%/0.0%/0.0%     1029         Conv:/model.4/m.0/cv1/conv/Conv
15   ConvExSwish      INT8     NPU    (1,32,240,136),(32,32,3,3),(32)          (1,32,240,136)         175425/293760/293760     762          12.85/12.85/12.85    100.0%/0.0%/0.0%     1029         Conv:/model.4/m.0/cv2/conv/Conv
16   Add              INT8     NPU    (1,32,240,136),(1,32,240,136)            (1,32,240,136)         261950/0/261950          496          \                    33.3%/33.3%/33.3%    2040         Add:/model.4/m.0/Add
17   ConvExSwish      INT8     NPU    (1,32,240,136),(32,32,3,3),(32)          (1,32,240,136)         175425/293760/293760     689          14.21/14.21/14.21    100.0%/0.0%/0.0%     1029         Conv:/model.4/m.1/cv1/conv/Conv
18   ConvExSwish      INT8     NPU    (1,32,240,136),(32,32,3,3),(32)          (1,32,240,136)         175425/293760/293760     680          14.40/14.40/14.40    100.0%/0.0%/0.0%     1029         Conv:/model.4/m.1/cv2/conv/Conv
19   Add              INT8     NPU    (1,32,240,136),(1,32,240,136)            (1,32,240,136)         261950/0/261950          344          \                    33.3%/33.3%/33.3%    2040         Add:/model.4/m.1/Add
20   Concat           INT8     NPU    (1,32,240,136),(1,32,240,136),...        (1,128,240,136)        698532/0/698532          1349         \                    33.3%/33.3%/33.3%    4080         Concat:/model.4/Concat
21   ConvExSwish      INT8     NPU    (1,128,240,136),(64,128,1,1),(64)        (1,64,240,136)         524627/261120/524627     1627         5.35/5.35/5.35       100.0%/0.0%/0.0%     4088         Conv:/model.4/cv2/conv/Conv
22   ConvExSwish      INT8     NPU    (1,64,240,136),(128,64,3,3),(128)        (1,128,120,68)         268199/587520/587520     990          19.78/19.78/19.78    100.0%/0.0%/0.0%     2113         Conv:/model.5/conv/Conv
23   ConvExSwish      INT8     NPU    (1,128,120,68),(128,128,1,1),(128)       (1,128,120,68)         176089/130560/176089     747          5.83/5.83/5.83       100.0%/0.0%/0.0%     1037         Conv:/model.6/cv1/conv/Conv
24   Split            INT8     NPU    (1,128,120,68),(2)                       (1,64,120,68),...      174635/0/174635          495          \                    100.0%/0.0%/0.0%     1020         Split:/model.6/Split
25   ConvExSwish      INT8     NPU    (1,64,120,68),(64,64,3,3),(64)           (1,64,120,68)          90442/293760/293760      427          22.93/22.93/22.93    100.0%/0.0%/0.0%     546          Conv:/model.6/m.0/cv1/conv/Conv
26   ConvExSwish      INT8     NPU    (1,64,120,68),(64,64,3,3),(64)           (1,64,120,68)          90442/293760/293760      423          23.15/23.15/23.15    100.0%/0.0%/0.0%     546          Conv:/model.6/m.0/cv2/conv/Conv
27   Add              INT8     NPU    (1,64,120,68),(1,64,120,68)              (1,64,120,68)          130975/0/130975          226          \                    33.3%/33.3%/33.3%    1020         Add:/model.6/m.0/Add
28   ConvExSwish      INT8     NPU    (1,64,120,68),(64,64,3,3),(64)           (1,64,120,68)          90442/293760/293760      421          23.26/23.26/23.26    100.0%/0.0%/0.0%     546          Conv:/model.6/m.1/cv1/conv/Conv
29   ConvExSwish      INT8     NPU    (1,64,120,68),(64,64,3,3),(64)           (1,64,120,68)          90442/293760/293760      424          23.09/23.09/23.09    100.0%/0.0%/0.0%     546          Conv:/model.6/m.1/cv2/conv/Conv
30   Add              INT8     NPU    (1,64,120,68),(1,64,120,68)              (1,64,120,68)          130975/0/130975          236          \                    33.3%/33.3%/33.3%    1020         Add:/model.6/m.1/Add
31   Concat           INT8     NPU    (1,64,120,68),(1,64,120,68),...          (1,256,120,68)         349266/0/349266          449          \                    33.3%/33.3%/33.3%    2040         Concat:/model.6/Concat
32   ConvExSwish      INT8     NPU    (1,256,120,68),(128,256,1,1),(128)       (1,128,120,68)         264775/261120/264775     781          11.14/11.14/11.14    100.0%/0.0%/0.0%     2073         Conv:/model.6/cv2/conv/Conv
33   ConvExSwish      INT8     NPU    (1,128,120,68),(256,128,3,3),(256)       (1,256,60,34)          155801/589824/589824     897          21.83/21.83/21.83    100.0%/0.0%/0.0%     1310         Conv:/model.7/conv/Conv
34   ConvExSwish      INT8     NPU    (1,256,60,34),(256,256,1,1),(256)        (1,256,60,34)          92967/131072/131072      463          9.40/9.40/9.40       100.0%/0.0%/0.0%     576          Conv:/model.8/cv1/conv/Conv
35   Split            INT8     NPU    (1,256,60,34),(2)                        (1,128,60,34),...      87318/0/87318            318          \                    100.0%/0.0%/0.0%     510          Split:/model.8/Split
36   ConvExSwish      INT8     NPU    (1,128,60,34),(128,128,3,3),(128)        (1,128,60,34)          56071/294912/294912      469          20.88/20.88/20.88    100.0%/0.0%/0.0%     400          Conv:/model.8/m.0/cv1/conv/Conv
37   ConvExSwish      INT8     NPU    (1,128,60,34),(128,128,3,3),(128)        (1,128,60,34)          56071/294912/294912      475          20.61/20.61/20.61    100.0%/0.0%/0.0%     400          Conv:/model.8/m.0/cv2/conv/Conv
38   Add              INT8     NPU    (1,128,60,34),(1,128,60,34)              (1,128,60,34)          65488/0/65488            131          \                    33.3%/33.3%/33.3%    510          Add:/model.8/m.0/Add
39   Concat           INT8     NPU    (1,128,60,34),(1,128,60,34),...          (1,384,60,34)          130975/0/130975          199          \                    33.3%/33.3%/33.3%    765          Concat:/model.8/Concat
40   ConvExSwish      INT8     NPU    (1,384,60,34),(256,384,1,1),(256)        (1,256,60,34)          117535/196608/196608     393          16.61/16.61/16.61    100.0%/0.0%/0.0%     863          Conv:/model.8/cv2/conv/Conv
41   ConvExSwish      INT8     NPU    (1,256,60,34),(128,256,1,1),(128)        (1,128,60,34)          68313/65536/68313        296          7.35/7.35/7.35       100.0%/0.0%/0.0%     543          Conv:/model.9/cv1/conv/Conv
42   MaxPool          INT8     NPU    (1,128,60,34)                            (1,128,60,34)          43659/0/43659            267          \                    100.0%/0.0%/0.0%     255          MaxPool:/model.9/m/MaxPool
43   MaxPool          INT8     NPU    (1,128,60,34)                            (1,128,60,34)          43659/0/43659            5125         \                    100.0%/0.0%/0.0%     255          MaxPool:/model.9/m_1/MaxPool
44   MaxPool          INT8     NPU    (1,128,60,34)                            (1,128,60,34)          43659/0/43659            235          \                    100.0%/0.0%/0.0%     255          MaxPool:/model.9/m_2/MaxPool
45   Concat           INT8     NPU    (1,128,60,34),(1,128,60,34),...          (1,512,60,34)          174633/0/174633          268          \                    33.3%/33.3%/33.3%    1020         Concat:/model.9/Concat
46   ConvExSwish      INT8     NPU    (1,512,60,34),(256,512,1,1),(256)        (1,256,60,34)          142104/262144/262144     584          14.90/14.90/14.90    100.0%/0.0%/0.0%     1150         Conv:/model.9/cv2/conv/Conv
47   Resize           INT8     NPU    (1,256,60,34),(1),(4)                    (1,256,120,68)         218293/0/218293          561          \                    100.0%/0.0%/0.0%     510          Resize:/model.10/Resize
48   Concat           INT8     NPU    (1,256,120,68),(1,128,120,68)            (1,384,120,68)         523899/0/523899          788          \                    33.3%/33.3%/33.3%    3060         Concat:/model.11/Concat
49   ConvExSwish      INT8     NPU    (1,384,120,68),(128,384,1,1),(128)       (1,128,120,68)         353461/391680/391680     1002         13.03/13.03/13.03    100.0%/0.0%/0.0%     3109         Conv:/model.12/cv1/conv/Conv
50   Split            INT8     NPU    (1,128,120,68),(2)                       (1,64,120,68),...      174635/0/174635          460          \                    100.0%/0.0%/0.0%     1020         Split:/model.12/Split
51   ConvExSwish      INT8     NPU    (1,64,120,68),(64,64,3,3),(64)           (1,64,120,68)          90442/293760/293760      544          18.00/18.00/18.00    100.0%/0.0%/0.0%     546          Conv:/model.12/m.0/cv1/conv/Conv
52   ConvExSwish      INT8     NPU    (1,64,120,68),(64,64,3,3),(64)           (1,64,120,68)          90442/293760/293760      482          20.32/20.32/20.32    100.0%/0.0%/0.0%     546          Conv:/model.12/m.0/cv2/conv/Conv
53   Concat           INT8     NPU    (1,64,120,68),(1,64,120,68),...          (1,192,120,68)         261950/0/261950          423          \                    33.3%/33.3%/33.3%    1530         Concat:/model.12/Concat
54   ConvExSwish      INT8     NPU    (1,192,120,68),(128,192,1,1),(128)       (1,128,120,68)         220432/195840/220432     775          8.42/8.42/8.42       100.0%/0.0%/0.0%     1555         Conv:/model.12/cv2/conv/Conv
55   Resize           INT8     NPU    (1,128,120,68),(1),(4)                   (1,128,240,136)        436585/0/436585          923          \                    100.0%/0.0%/0.0%     1020         Resize:/model.13/Resize
56   Concat           INT8     NPU    (1,128,240,136),(1,64,240,136)           (1,192,240,136)        1047798/0/1047798        1440         \                    33.3%/33.3%/33.3%    6120         Concat:/model.14/Concat
57   ConvExSwish      INT8     NPU    (1,192,240,136),(64,192,1,1),(64)        (1,64,240,136)         699603/391680/699603     1849         7.06/7.06/7.06       100.0%/0.0%/0.0%     6132         Conv:/model.15/cv1/conv/Conv
58   Split            INT8     NPU    (1,64,240,136),(2)                       (1,32,240,136),...     349268/0/349268          761          \                    100.0%/0.0%/0.0%     2040         Split:/model.15/Split
59   ConvExSwish      INT8     NPU    (1,32,240,136),(32,32,3,3),(32)          (1,32,240,136)         175425/293760/293760     727          13.47/13.47/13.47    100.0%/0.0%/0.0%     1029         Conv:/model.15/m.0/cv1/conv/Conv
60   ConvExSwish      INT8     NPU    (1,32,240,136),(32,32,3,3),(32)          (1,32,240,136)         175425/293760/293760     710          13.79/13.79/13.79    100.0%/0.0%/0.0%     1029         Conv:/model.15/m.0/cv2/conv/Conv
61   Concat           INT8     NPU    (1,32,240,136),(1,32,240,136),...        (1,96,240,136)         523899/0/523899          954          \                    33.3%/33.3%/33.3%    3060         Concat:/model.15/Concat
62   ConvExSwish      INT8     NPU    (1,96,240,136),(64,96,1,1),(64)          (1,64,240,136)         437139/261120/437139     1557         4.19/4.19/4.19       100.0%/0.0%/0.0%     3066         Conv:/model.15/cv2/conv/Conv
63   ConvExSwish      INT8     NPU    (1,64,240,136),(64,64,3,3),(64)          (1,64,120,68)          221416/293760/293760     578          16.94/16.94/16.94    100.0%/0.0%/0.0%     2076         Conv:/model.16/conv/Conv
64   Concat           INT8     NPU    (1,64,120,68),(1,128,120,68)             (1,192,120,68)         261950/0/261950          401          \                    33.3%/33.3%/33.3%    1530         Concat:/model.17/Concat
65   ConvExSwish      INT8     NPU    (1,64,240,136),(64,64,3,3),(64)          (1,64,240,136)         352391/1175040/1175040   1397         28.04/28.04/28.04    100.0%/0.0%/0.0%     2076         Conv:/model.22/cv2.0/cv2.0.0/conv/Conv
66   ConvExSwish      INT8     NPU    (1,64,240,136),(64,64,3,3),(64)          (1,64,240,136)         352391/1175040/1175040   1443         27.14/27.14/27.14    100.0%/0.0%/0.0%     2076         Conv:/model.22/cv3.0/cv3.0.0/conv/Conv
67   ConvExSwish      INT8     NPU    (1,192,120,68),(128,192,1,1),(128)       (1,128,120,68)         220432/195840/220432     777          8.40/8.40/8.40       100.0%/0.0%/0.0%     1555         Conv:/model.18/cv1/conv/Conv
68   Split            INT8     NPU    (1,128,120,68),(2)                       (1,64,120,68),...      174635/0/174635          437          \                    100.0%/0.0%/0.0%     1020         Split:/model.18/Split
69   ConvExSwish      INT8     NPU    (1,64,240,136),(64,64,3,3),(64)          (1,64,240,136)         352391/1175040/1175040   1559         25.12/25.12/25.12    100.0%/0.0%/0.0%     2076         Conv:/model.22/cv2.0/cv2.0.1/conv/Conv
70   Conv             INT8     NPU    (1,64,240,136),(64,64,1,1),(64)          (1,64,240,136)         349652/261120/349652     397          10.96/10.96/10.96    33.3%/33.3%/33.3%    2044         Conv:/model.22/cv2.0/cv2.0.2/Conv
71   OutputOperator   INT8     CPU    (1,64,240,136)                           \                      0/0/0                    177          \                    0.0%/0.0%/0.0%       2040         OutputOperator:322
72   ConvExSwish      INT8     NPU    (1,64,240,136),(64,64,3,3),(64)          (1,64,240,136)         352391/1175040/1175040   1438         27.24/27.24/27.24    100.0%/0.0%/0.0%     2076         Conv:/model.22/cv3.0/cv3.0.1/conv/Conv
73   ConvExSwish      INT8     NPU    (1,64,120,68),(64,64,3,3),(64)           (1,64,120,68)          90442/293760/293760      454          21.57/21.57/21.57    100.0%/0.0%/0.0%     546          Conv:/model.18/m.0/cv1/conv/Conv
74   ConvSigmoid      INT8     NPU    (1,64,240,136),(8,64,1,1),(8)            (1,8,240,136)          262014/130560/262014     777          0.70/0.70/0.70       100.0%/0.0%/0.0%     2040         Conv:/model.22/cv3.0/cv3.0.2/Conv
75   OutputOperator   INT8     CPU    (1,8,240,136)                            \                      0/0/0                    94           \                    0.0%/0.0%/0.0%       1020         OutputOperator:onnx::ReduceSum_330
76   ConvExSwish      INT8     NPU    (1,64,120,68),(64,64,3,3),(64)           (1,64,120,68)          90442/293760/293760      461          21.24/21.24/21.24    100.0%/0.0%/0.0%     546          Conv:/model.18/m.0/cv2/conv/Conv
77   Concat           INT8     NPU    (1,64,120,68),(1,64,120,68),...          (1,192,120,68)         261950/0/261950          413          \                    33.3%/33.3%/33.3%    1530         Concat:/model.18/Concat
78   ConvClip         INT8     NPU    (1,8,240,136),(1,8,1,1),(1)              (1,1,240,136)          174647/130560/174647     231          0.04/0.04/0.04       33.3%/33.3%/33.3%    1020         Conv:/model.22/ReduceSum_2conv
79   OutputOperator   INT8     CPU    (1,1,240,136)                            \                      0/0/0                    96           \                    0.0%/0.0%/0.0%       1020         OutputOperator:336
80   ConvExSwish      INT8     NPU    (1,192,120,68),(128,192,1,1),(128)       (1,128,120,68)         220432/195840/220432     718          9.09/9.09/9.09       100.0%/0.0%/0.0%     1555         Conv:/model.18/cv2/conv/Conv
81   ConvExSwish      INT8     NPU    (1,128,120,68),(128,128,3,3),(128)       (1,128,60,34)          121559/294912/294912     451          21.71/21.71/21.71    100.0%/0.0%/0.0%     1165         Conv:/model.19/conv/Conv
82   Concat           INT8     NPU    (1,128,60,34),(1,256,60,34)              (1,384,60,34)          130975/0/130975          200          \                    33.3%/33.3%/33.3%    765          Concat:/model.20/Concat
83   ConvExSwish      INT8     NPU    (1,128,120,68),(64,128,3,3),(64)         (1,64,120,68)          137182/587520/587520     702          27.90/27.90/27.90    100.0%/0.0%/0.0%     1092         Conv:/model.22/cv2.1/cv2.1.0/conv/Conv
84   ConvExSwish      INT8     NPU    (1,128,120,68),(64,128,3,3),(64)         (1,64,120,68)          137182/587520/587520     698          28.06/28.06/28.06    100.0%/0.0%/0.0%     1092         Conv:/model.22/cv3.1/cv3.1.0/conv/Conv
85   ConvExSwish      INT8     NPU    (1,384,60,34),(256,384,1,1),(256)        (1,256,60,34)          117535/196608/196608     392          16.65/16.65/16.65    100.0%/0.0%/0.0%     863          Conv:/model.21/cv1/conv/Conv
86   Split            INT8     NPU    (1,256,60,34),(2)                        (1,128,60,34),...      87318/0/87318            205          \                    100.0%/0.0%/0.0%     510          Split:/model.21/Split
87   ConvExSwish      INT8     NPU    (1,64,120,68),(64,64,3,3),(64)           (1,64,120,68)          90442/293760/293760      602          16.27/16.27/16.27    100.0%/0.0%/0.0%     546          Conv:/model.22/cv2.1/cv2.1.1/conv/Conv
88   Conv             INT8     NPU    (1,64,120,68),(64,64,1,1),(64)           (1,64,120,68)          87702/65280/87702        199          5.47/5.47/5.47       33.3%/33.3%/33.3%    514          Conv:/model.22/cv2.1/cv2.1.2/Conv
89   OutputOperator   INT8     CPU    (1,64,120,68)                            \                      0/0/0                    53           \                    0.0%/0.0%/0.0%       510          OutputOperator:343
90   ConvExSwish      INT8     NPU    (1,64,120,68),(64,64,3,3),(64)           (1,64,120,68)          90442/293760/293760      376          26.04/26.04/26.04    100.0%/0.0%/0.0%     546          Conv:/model.22/cv3.1/cv3.1.1/conv/Conv
91   ConvExSwish      INT8     NPU    (1,128,60,34),(128,128,3,3),(128)        (1,128,60,34)          56071/294912/294912      357          27.43/27.43/27.43    100.0%/0.0%/0.0%     400          Conv:/model.21/m.0/cv1/conv/Conv
92   ConvSigmoid      INT8     NPU    (1,64,120,68),(8,64,1,1),(8)             (1,8,120,68)           65552/32640/65552        291          0.47/0.47/0.47       100.0%/0.0%/0.0%     510          Conv:/model.22/cv3.1/cv3.1.2/Conv
93   OutputOperator   INT8     CPU    (1,8,120,68)                             \                      0/0/0                    31           \                    0.0%/0.0%/0.0%       255          OutputOperator:onnx::ReduceSum_351
94   ConvExSwish      INT8     NPU    (1,128,60,34),(128,128,3,3),(128)        (1,128,60,34)          56071/294912/294912      495          19.78/19.78/19.78    100.0%/0.0%/0.0%     400          Conv:/model.21/m.0/cv2/conv/Conv
95   Concat           INT8     NPU    (1,128,60,34),(1,128,60,34),...          (1,384,60,34)          130975/0/130975          289          \                    33.3%/33.3%/33.3%    765          Concat:/model.21/Concat
96   ConvClip         INT8     NPU    (1,8,120,68),(1,8,1,1),(1)               (1,1,120,68)           43672/32640/43672        241          0.01/0.01/0.01       33.3%/33.3%/33.3%    255          Conv:/model.22/ReduceSum_1_2conv
97   OutputOperator   INT8     CPU    (1,1,120,68)                             \                      0/0/0                    33           \                    0.0%/0.0%/0.0%       255          OutputOperator:355
98   ConvExSwish      INT8     NPU    (1,384,60,34),(256,384,1,1),(256)        (1,256,60,34)          117535/196608/196608     455          14.35/14.35/14.35    100.0%/0.0%/0.0%     863          Conv:/model.21/cv2/conv/Conv
99   ConvExSwish      INT8     NPU    (1,256,60,34),(64,256,3,3),(64)          (1,64,60,34)           66943/294912/294912      460          21.29/21.29/21.29    100.0%/0.0%/0.0%     654          Conv:/model.22/cv2.2/cv2.2.0/conv/Conv
100  ConvExSwish      INT8     NPU    (1,256,60,34),(64,256,3,3),(64)          (1,64,60,34)           66943/294912/294912      384          25.50/25.50/25.50    100.0%/0.0%/0.0%     654          Conv:/model.22/cv3.2/cv3.2.0/conv/Conv
101  ConvExSwish      INT8     NPU    (1,64,60,34),(64,64,3,3),(64)            (1,64,60,34)           24954/73728/73728        136          18.00/18.00/18.00    100.0%/0.0%/0.0%     164          Conv:/model.22/cv2.2/cv2.2.1/conv/Conv
102  Conv             INT8     NPU    (1,64,60,34),(64,64,1,1),(64)            (1,64,60,34)           22215/16384/22215        87           3.13/3.13/3.13       33.3%/33.3%/33.3%    132          Conv:/model.22/cv2.2/cv2.2.2/Conv
103  OutputOperator   INT8     CPU    (1,64,60,34)                             \                      0/0/0                    21           \                    0.0%/0.0%/0.0%       127          OutputOperator:362
104  ConvExSwish      INT8     NPU    (1,64,60,34),(64,64,3,3),(64)            (1,64,60,34)           24954/73728/73728        251          9.75/9.75/9.75       100.0%/0.0%/0.0%     164          Conv:/model.22/cv3.2/cv3.2.1/conv/Conv
105  ConvSigmoid      INT8     NPU    (1,64,60,34),(8,64,1,1),(8)              (1,8,60,34)            16437/8192/16437         244          0.14/0.14/0.14       100.0%/0.0%/0.0%     128          Conv:/model.22/cv3.2/cv3.2.2/Conv
106  OutputOperator   INT8     CPU    (1,8,60,34)                              \                      0/0/0                    17           \                    0.0%/0.0%/0.0%       63           OutputOperator:onnx::ReduceSum_370
107  ConvClip         INT8     NPU    (1,8,60,34),(1,8,1,1),(1)                (1,1,60,34)            10928/8192/10928         154          0.00/0.00/0.00       33.3%/33.3%/33.3%    63           Conv:/model.22/ReduceSum_2_2conv
108  OutputOperator   INT8     CPU    (1,1,60,34)                              \                      0/0/0                    14           \                    0.0%/0.0%/0.0%       63           OutputOperator:374
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Total Operator Elapsed Per Frame Time(us): 96186
Total Memory Read/Write Per Frame Size(KB): 165476
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
                                 Operator Time Consuming Ranking Table            
---------------------------------------------------------------------------------------------------
OpType             CallNumber   CPUTime(us)  GPUTime(us)  NPUTime(us)  TotalTime(us)  TimeRatio(%)  
---------------------------------------------------------------------------------------------------
ConvExSwish        57           0            0            69273        69273          72.02%        
Concat             13           0            0            8512         8512           8.85%         
Split              8            0            0            6072         6072           6.31%         
MaxPool            3            0            0            5627         5627           5.85%         
Add                6            0            0            2052         2052           2.13%         
Resize             2            0            0            1484         1484           1.54%         
ConvSigmoid        3            0            0            1312         1312           1.36%         
Conv               3            0            0            683          683            0.71%         
ConvClip           3            0            0            626          626            0.65%         
OutputOperator     9            536          0            0            536            0.56%         
InputOperator      1            9            0            0            9              0.01%         
---------------------------------------------------------------------------------------------------
```