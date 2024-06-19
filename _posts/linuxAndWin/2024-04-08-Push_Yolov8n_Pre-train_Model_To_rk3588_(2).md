---
layout: default
title: Push Yolov8n Pre-train Model To rk3588 (2)
categories:
- Linux
tags:
- Server
- Linux
---
//Description: 记录yolov8n部署到rk3588后的修改和优化，包括剪枝、量化、混合量化、转成c++，然而并没有明显优化效果，转成c++后每帧从python的0.5s降到0.35s，主要耗时均在SDK的三个api中(rknn_init,rknn_inputs_set,rknn_run)，每个api用时0.1+s，整个识别过程就特别慢。最终通过模型不同的输出测试，确认为输入分辨率对识别耗时有明显影响，同时pt转onnx的方式有问题，应该使用SDK官网的转换方式并设置imgsz而不是使用Yolov8官网的转换方式。写于2024年4月初，SDK文档参考了v2.0.0beta0版本，板子实际运行安装的SDK是1.6.0版本。

//Create Date: 2024-04-08 10:14:28

//Author: channy

[toc]

# 代码清单
[cpp](https://github.com/channyHuang/rk3588DeployNoteAndCode/cpp)

# 使用RKNN的官网代码进行模型转换
[ultralytics_yolov8](https://github.com/ultralytics/ultralytics_yolov8)

使用Yolov8的官网代码转换模型会遇到各种问题，换用RKNN的官网代码转换能够避免，因其在转换过程中做了其它处理。

把`pt`模型转换成`onnx`后，再使用`rknn_model_zoo`中example对应的yolo版本进行`onnx`到`rknn`的转换。

# 剪枝
`model_pruning`设置为True剪枝，然而对小模型没有明显效果。
```python
    rknn.config(mean_values=[128, 128, 128], std_values=[128, 128, 128], 
                quant_img_RGB2BGR = True, 
                quantized_dtype = 'asymmetric_quantized-8', quantized_method = 'layer', quantized_algorithm = 'mmse', optimization_level = 3,
                target_platform = 'rk3588',
                model_pruning = True)
```

# 量化
量化方法channel/layer，量化算法normal/mmse/kl_divergence
```python
    ret = rknn.build(do_quantization = True, dataset = './dataset.txt', rknn_batch_size = None)
```
当`quant_img_RGB2BGR`为False时，error_analysis的误差上升到几百+，改成True后依旧几百上千+。

## 混合量化
```python
    # step 1
    if True:
        model_path = '../model/v8n.onnx'
        rknn = RKNN(verbose = True)
        rknn.config(mean_values=[128, 128, 128], std_values=[128, 128, 128], 
                    quant_img_RGB2BGR = True, 
                    quantized_dtype = 'asymmetric_quantized-8', quantized_method = 'channel', quantized_algorithm = 'normal', optimization_level = 3,
                    target_platform = 'rk3588',
                    model_pruning = True)
        ret = rknn.load_onnx(model = model_path)
        ret = rknn.hybrid_quantization_step1(dataset = './dataset.txt', proposal = False)
        rknn.release()
    # step 2
    rknn = RKNN(verbose = True)
    ret = rknn.hybrid_quantization_step2(model_input = './v8n.model',
                                         data_input='./v8n.data',
                                         model_quantization_cfg='./v8n.quantization.cfg')
    ret = rknn.export_rknn('./v8n.rknn')
    ret = rknn.accuracy_analysis(inputs = ['../model/test.jpg'], output_dir = None)
    start_time = time.time()
    origin_img = cv2.imread('../model/test.jpg')
    origin_img_rz = cv2.resize(origin_img, IMG_SIZE)
    img_height, img_width = origin_img.shape[:2]
    img = cv2.cvtColor(origin_img, cv2.COLOR_BGR2RGB)
    img = cv2.resize(img, IMG_SIZE)
    image_data = np.array(img) / 255.0
    image_data = np.transpose(image_data, (0, 1, 2))
    image_data = np.expand_dims(image_data, axis = 0).astype(np.float16)
    
    ret = rknn.init_runtime()
    outputs = rknn.inference(inputs = [img])

    boxes, classes, scores = post_process(outputs)
    xyxyboxes = []
    for b in boxes:
        xyxyboxes.append(xywh2xyxy(b[0], b[1], b[2], b[3]))
    draw(origin_img_rz, xyxyboxes, scores, classes)

    cur_time = time.time()
    spend_time = "{:.2f}  s".format((cur_time - start_time))
    cv2.putText(origin_img_rz, spend_time, (30, 30), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2)
    cv2.imshow('res', cv2.resize(origin_img_rz, (750, 750)))
    #cv2.imwrite('test_res.jpg', cv2.resize(origin_img_rz, (750, 750)))
    cv2.waitKey(10000)
    cv2.destroyAllWindows()
```
量化完后发现使用自己的模型完全识别不到目标。。。

# python转c++
背景：使用python写读入图像、推理、画框显示整个过程总耗时在0.5s/帧左右，耗时集中在python的rknn推理接口。

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

见附录改成自己的模型后，对单图像耗时进行测试，发现如下：
1. 图像输入尺寸影响耗时
过程中输出错误
```
Error on improcess STATUS=-1
RGA error message: Unsupported function: src unsupport with stride 750, rgb888 width stride should be 16 aligned!
```
模型是1920x1920，输入图像使用了750x750，报了上面的错误，改成736x736后错误消失，总运行时间上也从0.47s降到0.37s。

2. 不同模型识别耗时不一样，集中在SDK的api中
* Python的耗时集中在rknn.inference上，自己的模型用时0.47+s/帧
* c++的耗时集中在rknn_init、rknn_inputs_set和rknn_run三个函数中，自己的模型用时分别为0.09+s/帧、0.11+s/帧、0.13+s/帧，总用时0.35+s/帧。

3. 图像输入使用的是RawRGB原始数据，即width*height*channel个char的数据可直接输入，jpg的数据需要使用SDK里面的imgutils库转化。

# 模型耗时和demo相差大
做了以上优化后，发现自己的模型耗时和demo的差距依旧较大，故查找原因。先后试过不同的模型输入分辨率并记录Python单推理接口耗时/帧如下。 
 
| 模型输入分辨率 | 模型训练代码版本 | 激活函数 | onnx转换方式 | SDK转换参数 | Python单推理接口耗时/帧 | 本地视频全流程帧率(fps) |
|:---:|:------:|:---:|:---:|:---:|:---:|:---:|
| 1920 x 1920 | Yolov5n | Relu | Yolov8官网转换 | - | 0.25s |
| 1920 x 1920 |	Yolov8n | Softmax | Yolov8官网转换 | - | 0.5s |
| 1920 x 1920 | Yolov8n | Softmax | SDK官网转换 | imgsz=640 | <font color=red>0.06s</font> |
| 1920 x 1920 | Yolov8n | Softmax | SDK官网转换 | imgsz = 1920 | 0.42s |
| 1920 x 1920 |	Yolov8n | Relu | Yolov8官网转换 | - | 0.5s |
| 1920 x 1920 |	Yolov8n | Relu | SDK官网转换 | imgsz=640 | <font color=red>0.06s</font> |
| 1920 x 1920 |	Yolov8n | Relu | SDK官网转换 | imgsz=1920 | <font color=red>0.06s</font> | 20 
| 640 x 640 | Yolov8n | Relu | SDK官网转换 | imgsz=640 | <font color=red>0.04s</font> | 40
| 640 x 640 | Yolov8n | Relu | SDK官网转换 | imgsz=1920 | 0.42s |

最终确认耗时大的主要原因是分辨率大。同时注意到`failed to config argb mode layer`错误。

## ONNX转成RKNN报'failed to config argb mode layer'错误
在试验过程中遇到在用Yolov8的`export`函数直接转成`onnx`后再转`RKNN`报`failed to config argb mode layer`错误。

```sh
I rknn building ...
E RKNN: [15:36:41.876] failed to config argb mode layer!
Aborted (core dumped)
```

```python
def pt2onnx(path = '../model/v8n_relu.pt', sim = True):
    model = YOLO(path)
    res = model.export(format="onnx", simplify = sim)#, opset = 19) 
```

上网搜索发现使用[ultralytics_yolov8](https://github.com/airockchip/ultralytics_yolov8.git)里面的`exporter.py`从`pt`转到`onnx`再转`rknn`能转成功。看描述应该是算子相关问题。

接着发现之前耗时大的真正原因是`pt`转`onnx`的转换方式也有问题，用Yolov8官网的转换方式是保持了输入尺寸即1920x1920的，分辨率大导致耗时大；用SDK官网的转换方式默认参数imgsz＝640，转换后才能达到和demo相当的水平；但其中用v8n+1920x1920+relu直接用imgsz=1920也能达到demo相当的速度。

# adb 连板分析
## adb connect [ip]
没有数据线，网线直连传输文件到板端，无意中发现adb除了使用数据线外，也可以使用网线直连的方式，只需要pc和板的ip在同一网段即可。
```
$ adb connect 192.168.1.222
connected to 192.168.1.222:5555
```
然后执行代码，可正常运行`memory_detail = rknn.eval_memory()`并输出内存占用状况。
```
======================================================
            Memory Profile Info Dump                  
======================================================
NPU model memory detail(bytes):
    Weight Memory: 8.06 MiB
    Internal Tensor Memory: 105.47 MiB
    Other Memory: 3.72 MiB
    Total Memory: 117.25 MiB

INFO: When evaluating memory usage, we need consider  
the size of model, current model size is: 11.79 MiB       
======================================================
```

## `rknn.eval_perf()`报错
在执行性能评估时发生
`invalid literal for int() with base 10: 'cat: /sys/class/devfreq/dmc/cur_freq: 没有那个文件或目录'`
的错误。
```
    perf_result = rknn.eval_perf()
  File "/home/channy/miniconda3/envs/RKNN-Toolkit2/lib/python3.8/site-packages/rknn/api/rknn.py", line 326, in eval_perf
    return self.rknn_base.eval_perf(is_print, fix_freq)
  File "rknn/api/rknn_base.py", line 3005, in rknn.api.rknn_base.RKNNBase.eval_perf
  File "rknn/api/rknn_runtime.py", line 223, in rknn.api.rknn_runtime.RKNNRuntime.get_hardware_freq
  File "rknn/api/rknn_platform.py", line 817, in rknn.api.rknn_platform.get_ddr_freq
ValueError: invalid literal for int() with base 10: 'cat: /sys/class/devfreq/dmc/cur_freq: 没有那个文件或目录'
```
板子`/sys/class/devfreq`下面确实没有`dmc`文件夹。即板子不支持固定DDR频率。而api的源码没有公布也改不了路径。。。

无解。。。只能自行使用其它方法统计总时间了。

后面发现Python的性能统计接口运行不通，但C++的可以。代码可见
[cpp](https://github.com/channyHuang/rk3588DeployNoteAndCode/cpp)。通过对文件夹中的图像进行检测，得到每帧的平均耗时及每层的耗时。
具体可见附录1：性能统计输出结果。

# 正确率计算
在板子上用转换后的模型直接检测训练数据并统计检测目标结果

## 未量化
| 阈值 | 总目标 | 正确数 | 错误数 | 漏检数 |
|:---:|:---:|:---:|:---:|:---:|
| 0.25 | 32412 | 31655(0.97) | 19364(0.59) | 757(0.02) |
| 0.5  | 32412 | 29581(0.91) | 3593(0.11) | 2831(0.08) |
| 0.63 | 32412 | 27792(0.85) | 1704(0.05) | 4620(0.14) |
| 0.80 | 32412 | 13989(0.43) | 156(0.004) | 18423(0.56) |

误检最高置信度0.91+

## 量化
| 阈值 | 总目标 | 正确数 | 错误数 | 漏检数 |
|:---:|:---:|:---:|:---:|:---:|
| 0.5  | 32412 | 31041(0.95) | 440(0.01) | 1371(0.04) |
| 0.63 | 32412 | 30108(0.92) | 221(0.006) | 2304(0.07) |
| 0.80 | 32412 | 18001(0.555)| 34(0.001) | 14411(0.44) |

误检最高置信度0.889455

# 附录1：性能统计输出结果 
使用量化后的1920x1920为输入尺寸的模型进行检测，单推理接口Python用时0.3+s，c++用时0.15s左右。c++下每层耗时如下。 
```sh
rknn_run
---> ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                                         Network Layer Information Table                                                                               
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ID   OpType           DataType Target InputShape                               OutputShape            Cycles(DDR/NPU/Total)    Time(us)     MacUsage(%)          WorkLoad(0/1/2)      RW(KB)       FullName        
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
1    InputOperator    UINT8    CPU    \                                        (1,3,1920,1920)        0/0/0                    4            \                    0.0%/0.0%/0.0%       0            InputOperator:images
2    ConvExSwish      UINT8    NPU    (1,3,1920,1920),(16,3,3,3),(16)          (1,16,960,960)         1091036/8294400/8294400  16130        2.41/0.00/0.00       100.0%/0.0%/0.0%     10802        Conv:/model.0/conv/Conv
3    ConvExSwish      INT8     NPU    (1,16,960,960),(32,16,3,3),(32)          (1,32,480,480)         935287/2073600/2073600   4862         21.32/0.00/0.00      100.0%/0.0%/0.0%     14404        Conv:/model.1/conv/Conv
4    ConvExSwish      INT8     NPU    (1,32,480,480),(32,32,1,1),(32)          (1,32,480,480)         623442/921600/921600     4204         5.48/0.00/0.00       100.0%/0.0%/0.0%     7201         Conv:/model.2/cv1/conv/Conv
5    Split            INT8     NPU    (1,32,480,480),(2)                       (1,16,480,480),...     623388/0/623388          1195         \                    100.0%/0.0%/0.0%     7200         Split:/model.2/Split
6    ConvExSwish      INT8     NPU    (1,16,480,480),(16,16,3,3),(16)          (1,16,480,480)         311802/2073600/2073600   4094         12.66/0.00/0.00      100.0%/0.0%/0.0%     3602         Conv:/model.2/m.0/cv1/conv/Conv
7    ConvExSwish      INT8     NPU    (1,16,480,480),(16,16,3,3),(16)          (1,16,480,480)         311802/2073600/2073600   3921         13.22/0.00/0.00      100.0%/0.0%/0.0%     3602         Conv:/model.2/m.0/cv2/conv/Conv
8    Add              INT8     NPU    (1,16,480,480),(1,16,480,480)            (1,16,480,480)         467541/0/467541          945          \                    100.0%/0.0%/0.0%     7200         Add:/model.2/m.0/Add
9    Concat           INT8     NPU    (1,16,480,480),(1,16,480,480),...        (1,48,480,480)         935081/0/935081          2002         \                    100.0%/0.0%/0.0%     10800        Concat:/model.2/Concat
10   ConvExSwish      INT8     NPU    (1,48,480,480),(32,48,1,1),(32)          (1,32,480,480)         779310/921600/921600     4743         7.29/0.00/0.00       100.0%/0.0%/0.0%     10801        Conv:/model.2/cv2/conv/Conv
11   ConvExSwish      INT8     NPU    (1,32,480,480),(64,32,3,3),(64)          (1,64,240,240)         468342/1036800/1036800   2655         39.05/0.00/0.00      100.0%/0.0%/0.0%     7218         Conv:/model.3/conv/Conv
12   ConvExSwish      INT8     NPU    (1,64,240,240),(64,64,1,1),(64)          (1,64,240,240)         311889/460800/460800     2306         9.99/0.00/0.00       100.0%/0.0%/0.0%     3604         Conv:/model.4/cv1/conv/Conv
13   Split            INT8     NPU    (1,64,240,240),(2)                       (1,32,240,240),...     311695/0/311695          785          \                    100.0%/0.0%/0.0%     3600         Split:/model.4/Split
14   ConvExSwish      INT8     NPU    (1,32,240,240),(32,32,3,3),(32)          (1,32,240,240)         156248/518400/518400     1263         41.05/0.00/0.00      100.0%/0.0%/0.0%     1809         Conv:/model.4/m.0/cv1/conv/Conv
15   ConvExSwish      INT8     NPU    (1,32,240,240),(32,32,3,3),(32)          (1,32,240,240)         156248/518400/518400     1324         39.15/0.00/0.00      100.0%/0.0%/0.0%     1809         Conv:/model.4/m.0/cv2/conv/Conv
16   Add              INT8     NPU    (1,32,240,240),(1,32,240,240)            (1,32,240,240)         233771/0/233771          624          \                    100.0%/0.0%/0.0%     3600         Add:/model.4/m.0/Add
17   ConvExSwish      INT8     NPU    (1,32,240,240),(32,32,3,3),(32)          (1,32,240,240)         156248/518400/518400     1143         45.35/0.00/0.00      100.0%/0.0%/0.0%     1809         Conv:/model.4/m.1/cv1/conv/Conv
18   ConvExSwish      INT8     NPU    (1,32,240,240),(32,32,3,3),(32)          (1,32,240,240)         156248/518400/518400     1211         42.81/0.00/0.00      100.0%/0.0%/0.0%     1809         Conv:/model.4/m.1/cv2/conv/Conv
19   Add              INT8     NPU    (1,32,240,240),(1,32,240,240)            (1,32,240,240)         233771/0/233771          565          \                    100.0%/0.0%/0.0%     3600         Add:/model.4/m.1/Add
20   Concat           INT8     NPU    (1,32,240,240),(1,32,240,240),...        (1,128,240,240)        623388/0/623388          1317         \                    100.0%/0.0%/0.0%     7200         Concat:/model.4/Concat
21   ConvExSwish      INT8     NPU    (1,128,240,240),(64,128,1,1),(64)        (1,64,240,240)         467909/460800/467909     2641         17.45/0.00/0.00      100.0%/0.0%/0.0%     7208         Conv:/model.4/cv2/conv/Conv
22   ConvExSwish      INT8     NPU    (1,64,240,240),(128,64,3,3),(128)        (1,128,120,120)        236931/1036800/1036800   1640         63.22/0.00/0.00      100.0%/0.0%/0.0%     3673         Conv:/model.5/conv/Conv
23   ConvExSwish      INT8     NPU    (1,128,120,120),(128,128,1,1),(128)      (1,128,120,120)        156583/230400/230400     1230         18.73/0.00/0.00      100.0%/0.0%/0.0%     1817         Conv:/model.6/cv1/conv/Conv
24   Split            INT8     NPU    (1,128,120,120),(2)                      (1,64,120,120),...     155848/0/155848          551          \                    100.0%/0.0%/0.0%     1800         Split:/model.6/Split
25   ConvExSwish      INT8     NPU    (1,64,120,120),(64,64,3,3),(64)          (1,64,120,120)         79504/518400/518400      841          61.64/0.00/0.00      100.0%/0.0%/0.0%     936          Conv:/model.6/m.0/cv1/conv/Conv
26   ConvExSwish      INT8     NPU    (1,64,120,120),(64,64,3,3),(64)          (1,64,120,120)         79504/518400/518400      836          62.01/0.00/0.00      100.0%/0.0%/0.0%     936          Conv:/model.6/m.0/cv2/conv/Conv
27   Add              INT8     NPU    (1,64,120,120),(1,64,120,120)            (1,64,120,120)         116886/0/116886          374          \                    100.0%/0.0%/0.0%     1800         Add:/model.6/m.0/Add
28   ConvExSwish      INT8     NPU    (1,64,120,120),(64,64,3,3),(64)          (1,64,120,120)         79504/518400/518400      842          61.57/0.00/0.00      100.0%/0.0%/0.0%     936          Conv:/model.6/m.1/cv1/conv/Conv
29   ConvExSwish      INT8     NPU    (1,64,120,120),(64,64,3,3),(64)          (1,64,120,120)         79504/518400/518400      841          61.64/0.00/0.00      100.0%/0.0%/0.0%     936          Conv:/model.6/m.1/cv2/conv/Conv
30   Add              INT8     NPU    (1,64,120,120),(1,64,120,120)            (1,64,120,120)         116886/0/116886          463          \                    100.0%/0.0%/0.0%     1800         Add:/model.6/m.1/Add
31   Concat           INT8     NPU    (1,64,120,120),(1,64,120,120),...        (1,256,120,120)        311694/0/311694          844          \                    100.0%/0.0%/0.0%     3600         Concat:/model.6/Concat
32   ConvExSwish      INT8     NPU    (1,256,120,120),(128,256,1,1),(128)      (1,128,120,120)        235199/460800/460800     1518         30.36/0.00/0.00      100.0%/0.0%/0.0%     3633         Conv:/model.6/cv2/conv/Conv
33   ConvExSwish      INT8     NPU    (1,128,120,120),(256,128,3,3),(256)      (1,256,60,60)          129440/1036800/1036800   1612         64.32/0.00/0.00      100.0%/0.0%/0.0%     2090         Conv:/model.7/conv/Conv
34   ConvExSwish      INT8     NPU    (1,256,60,60),(256,256,1,1),(256)        (1,256,60,60)          80781/230400/230400      802          28.73/0.00/0.00      100.0%/0.0%/0.0%     966          Conv:/model.8/cv1/conv/Conv
35   Split            INT8     NPU    (1,256,60,60),(2)                        (1,128,60,60),...      77925/0/77925            421          \                    100.0%/0.0%/0.0%     900          Split:/model.8/Split
36   ConvExSwish      INT8     NPU    (1,128,60,60),(128,128,3,3),(128)        (1,128,60,60)          45239/518400/518400      731          70.92/0.00/0.00      100.0%/0.0%/0.0%     595          Conv:/model.8/m.0/cv1/conv/Conv
37   ConvExSwish      INT8     NPU    (1,128,60,60),(128,128,3,3),(128)        (1,128,60,60)          45239/518400/518400      725          71.50/0.00/0.00      100.0%/0.0%/0.0%     595          Conv:/model.8/m.0/cv2/conv/Conv
38   Add              INT8     NPU    (1,128,60,60),(1,128,60,60)              (1,128,60,60)          58443/0/58443            185          \                    100.0%/0.0%/0.0%     900          Add:/model.8/m.0/Add
39   Concat           INT8     NPU    (1,128,60,60),(1,128,60,60),...          (1,384,60,60)          116886/0/116886          304          \                    100.0%/0.0%/0.0%     1350         Concat:/model.8/Concat
40   ConvExSwish      INT8     NPU    (1,384,60,60),(256,384,1,1),(256)        (1,256,60,60)          101647/345600/345600     775          44.59/0.00/0.00      100.0%/0.0%/0.0%     1448         Conv:/model.8/cv2/conv/Conv
41   ConvExSwish      INT8     NPU    (1,256,60,60),(128,256,1,1),(128)        (1,128,60,60)          59872/115200/115200      480          24.00/0.00/0.00      100.0%/0.0%/0.0%     933          Conv:/model.9/cv1/conv/Conv
42   MaxPool          INT8     NPU    (1,128,60,60)                            (1,128,60,60)          38962/0/38962            341          \                    100.0%/0.0%/0.0%     450          MaxPool:/model.9/m/MaxPool
43   MaxPool          INT8     NPU    (1,128,60,60)                            (1,128,60,60)          38962/0/38962            336          \                    100.0%/0.0%/0.0%     450          MaxPool:/model.9/m_1/MaxPool
44   MaxPool          INT8     NPU    (1,128,60,60)                            (1,128,60,60)          38962/0/38962            336          \                    100.0%/0.0%/0.0%     450          MaxPool:/model.9/m_2/MaxPool
45   Concat           INT8     NPU    (1,128,60,60),(1,128,60,60),...          (1,512,60,60)          155847/0/155847          379          \                    100.0%/0.0%/0.0%     1800         Concat:/model.9/Concat
46   ConvExSwish      INT8     NPU    (1,512,60,60),(256,512,1,1),(256)        (1,256,60,60)          122513/460800/460800     825          55.85/0.00/0.00      100.0%/0.0%/0.0%     1930         Conv:/model.9/cv2/conv/Conv
47   Resize           INT8     NPU    (1,256,60,60),(1),(4)                    (1,256,120,120)        194810/0/194810          682          \                    100.0%/0.0%/0.0%     900          Resize:/model.10/Resize
48   Concat           INT8     NPU    (1,256,120,120),(1,128,120,120)          (1,384,120,120)        467541/0/467541          1089         \                    100.0%/0.0%/0.0%     5400         Concat:/model.11/Concat
49   ConvExSwish      INT8     NPU    (1,384,120,120),(128,384,1,1),(128)      (1,128,120,120)        313815/691200/691200     1630         42.40/0.00/0.00      100.0%/0.0%/0.0%     5449         Conv:/model.12/cv1/conv/Conv
50   Split            INT8     NPU    (1,128,120,120),(2)                      (1,64,120,120),...     155848/0/155848          441          \                    100.0%/0.0%/0.0%     1800         Split:/model.12/Split
51   ConvExSwish      INT8     NPU    (1,64,120,120),(64,64,3,3),(64)          (1,64,120,120)         79504/518400/518400      721          71.90/0.00/0.00      100.0%/0.0%/0.0%     936          Conv:/model.12/m.0/cv1/conv/Conv
52   ConvExSwish      INT8     NPU    (1,64,120,120),(64,64,3,3),(64)          (1,64,120,120)         79504/518400/518400      718          72.20/0.00/0.00      100.0%/0.0%/0.0%     936          Conv:/model.12/m.0/cv2/conv/Conv
53   Concat           INT8     NPU    (1,64,120,120),(1,64,120,120),...        (1,192,120,120)        233771/0/233771          499          \                    100.0%/0.0%/0.0%     2700         Concat:/model.12/Concat
54   ConvExSwish      INT8     NPU    (1,192,120,120),(128,192,1,1),(128)      (1,128,120,120)        195891/345600/345600     1271         27.19/0.00/0.00      100.0%/0.0%/0.0%     2725         Conv:/model.12/cv2/conv/Conv
55   Resize           INT8     NPU    (1,128,120,120),(1),(4)                  (1,128,240,240)        389618/0/389618          1119         \                    100.0%/0.0%/0.0%     1800         Resize:/model.13/Resize
56   Concat           INT8     NPU    (1,128,240,240),(1,64,240,240)           (1,192,240,240)        935081/0/935081          1871         \                    100.0%/0.0%/0.0%     10800        Concat:/model.14/Concat
57   ConvExSwish      INT8     NPU    (1,192,240,240),(64,192,1,1),(64)        (1,64,240,240)         623929/691200/691200     3004         23.01/0.00/0.00      100.0%/0.0%/0.0%     10812        Conv:/model.15/cv1/conv/Conv
58   Split            INT8     NPU    (1,64,240,240),(2)                       (1,32,240,240),...     311695/0/311695          740          \                    100.0%/0.0%/0.0%     3600         Split:/model.15/Split
59   ConvExSwish      INT8     NPU    (1,32,240,240),(32,32,3,3),(32)          (1,32,240,240)         156248/518400/518400     1209         42.88/0.00/0.00      100.0%/0.0%/0.0%     1809         Conv:/model.15/m.0/cv1/conv/Conv
60   ConvExSwish      INT8     NPU    (1,32,240,240),(32,32,3,3),(32)          (1,32,240,240)         156248/518400/518400     1208         42.91/0.00/0.00      100.0%/0.0%/0.0%     1809         Conv:/model.15/m.0/cv2/conv/Conv
61   Concat           INT8     NPU    (1,32,240,240),(1,32,240,240),...        (1,96,240,240)         467541/0/467541          922          \                    100.0%/0.0%/0.0%     5400         Concat:/model.15/Concat
62   ConvExSwish      INT8     NPU    (1,96,240,240),(64,96,1,1),(64)          (1,64,240,240)         389899/460800/460800     2392         14.45/0.00/0.00      100.0%/0.0%/0.0%     5406         Conv:/model.15/cv2/conv/Conv
63   ConvExSwish      INT8     NPU    (1,64,240,240),(64,64,3,3),(64)          (1,64,120,120)         196389/518400/518400     1013         51.17/0.00/0.00      100.0%/0.0%/0.0%     3636         Conv:/model.16/conv/Conv
64   Concat           INT8     NPU    (1,64,120,120),(1,128,120,120)           (1,192,120,120)        233771/0/233771          519          \                    100.0%/0.0%/0.0%     2700         Concat:/model.17/Concat
65   ConvExSwish      INT8     NPU    (1,64,240,240),(64,64,3,3),(64)          (1,64,240,240)         313274/2073600/2073600   2543         81.54/0.00/0.00      100.0%/0.0%/0.0%     3636         Conv:/model.22/cv2.0/cv2.0.0/conv/Conv
66   ConvExSwish      INT8     NPU    (1,64,240,240),(64,64,3,3),(64)          (1,64,240,240)         313274/2073600/2073600   2488         83.34/0.00/0.00      100.0%/0.0%/0.0%     3636         Conv:/model.22/cv3.0/cv3.0.0/conv/Conv
67   ConvExSwish      INT8     NPU    (1,192,120,120),(128,192,1,1),(128)      (1,128,120,120)        195891/345600/345600     1275         27.11/0.00/0.00      100.0%/0.0%/0.0%     2725         Conv:/model.18/cv1/conv/Conv
68   Split            INT8     NPU    (1,128,120,120),(2)                      (1,64,120,120),...     155848/0/155848          354          \                    100.0%/0.0%/0.0%     1800         Split:/model.18/Split
69   ConvExSwish      INT8     NPU    (1,64,240,240),(64,64,3,3),(64)          (1,64,240,240)         313274/2073600/2073600   2480         83.61/0.00/0.00      100.0%/0.0%/0.0%     3636         Conv:/model.22/cv2.0/cv2.0.1/conv/Conv
70   Conv             INT8     NPU    (1,64,240,240),(64,64,1,1),(64)          (1,64,240,240)         311889/460800/460800     928          24.83/0.00/0.00      100.0%/0.0%/0.0%     3604         Conv:/model.22/cv2.0/cv2.0.2/Conv
71   OutputOperator   INT8     CPU    (1,64,240,240)                           \                      0/0/0                    347          \                    0.0%/0.0%/0.0%       3600         OutputOperator:322
72   ConvExSwish      INT8     NPU    (1,64,240,240),(64,64,3,3),(64)          (1,64,240,240)         313274/2073600/2073600   2477         83.71/0.00/0.00      100.0%/0.0%/0.0%     3636         Conv:/model.22/cv3.0/cv3.0.1/conv/Conv
73   ConvExSwish      INT8     NPU    (1,64,120,120),(64,64,3,3),(64)          (1,64,120,120)         79504/518400/518400      714          72.61/0.00/0.00      100.0%/0.0%/0.0%     936          Conv:/model.18/m.0/cv1/conv/Conv
74   ConvSigmoid      INT8     NPU    (1,64,240,240),(3,64,1,1),(3)            (1,3,240,240)          233792/230400/233792     1380         0.78/0.00/0.00       100.0%/0.0%/0.0%     3600         Conv:/model.22/cv3.0/cv3.0.2/Conv
75   OutputOperator   INT8     CPU    (1,3,240,240)                            \                      0/0/0                    236          \                    0.0%/0.0%/0.0%       1800         OutputOperator:onnx::ReduceSum_330
76   ConvExSwish      INT8     NPU    (1,64,120,120),(64,64,3,3),(64)          (1,64,120,120)         79504/518400/518400      748          69.30/0.00/0.00      100.0%/0.0%/0.0%     936          Conv:/model.18/m.0/cv2/conv/Conv
77   Concat           INT8     NPU    (1,64,120,120),(1,64,120,120),...        (1,192,120,120)        233771/0/233771          615          \                    100.0%/0.0%/0.0%     2700         Concat:/model.18/Concat
78   ConvClip         INT8     NPU    (1,3,240,240),(1,3,1,1),(1)              (1,1,240,240)          155854/230400/230400     438          0.04/0.00/0.00       100.0%/0.0%/0.0%     1800         Conv:/model.22/ReduceSum_2conv
79   OutputOperator   INT8     CPU    (1,1,240,240)                            \                      0/0/0                    233          \                    0.0%/0.0%/0.0%       1800         OutputOperator:336
80   ConvExSwish      INT8     NPU    (1,192,120,120),(128,192,1,1),(128)      (1,128,120,120)        195891/345600/345600     1211         28.54/0.00/0.00      100.0%/0.0%/0.0%     2725         Conv:/model.18/cv2/conv/Conv
81   ConvExSwish      INT8     NPU    (1,128,120,120),(128,128,3,3),(128)      (1,128,60,60)          103682/518400/518400     800          64.80/0.00/0.00      100.0%/0.0%/0.0%     1945         Conv:/model.19/conv/Conv
82   Concat           INT8     NPU    (1,128,60,60),(1,256,60,60)              (1,384,60,60)          116886/0/116886          403          \                    100.0%/0.0%/0.0%     1350         Concat:/model.20/Concat
83   ConvExSwish      INT8     NPU    (1,128,120,120),(64,128,3,3),(64)        (1,64,120,120)         120024/1036800/1036800   1290         80.37/0.00/0.00      100.0%/0.0%/0.0%     1872         Conv:/model.22/cv2.1/cv2.1.0/conv/Conv
84   ConvExSwish      INT8     NPU    (1,128,120,120),(64,128,3,3),(64)        (1,64,120,120)         120024/1036800/1036800   1352         76.69/0.00/0.00      100.0%/0.0%/0.0%     1872         Conv:/model.22/cv3.1/cv3.1.0/conv/Conv
85   ConvExSwish      INT8     NPU    (1,384,60,60),(256,384,1,1),(256)        (1,256,60,60)          101647/345600/345600     775          44.59/0.00/0.00      100.0%/0.0%/0.0%     1448         Conv:/model.21/cv1/conv/Conv
86   Split            INT8     NPU    (1,256,60,60),(2)                        (1,128,60,60),...      77925/0/77925            331          \                    100.0%/0.0%/0.0%     900          Split:/model.21/Split
87   ConvExSwish      INT8     NPU    (1,64,120,120),(64,64,3,3),(64)          (1,64,120,120)         79504/518400/518400      755          68.66/0.00/0.00      100.0%/0.0%/0.0%     936          Conv:/model.22/cv2.1/cv2.1.1/conv/Conv
88   Conv             INT8     NPU    (1,64,120,120),(64,64,1,1),(64)          (1,64,120,120)         78119/115200/115200      480          12.00/0.00/0.00      100.0%/0.0%/0.0%     904          Conv:/model.22/cv2.1/cv2.1.2/Conv
89   OutputOperator   INT8     CPU    (1,64,120,120)                           \                      0/0/0                    98           \                    0.0%/0.0%/0.0%       900          OutputOperator:343
90   ConvExSwish      INT8     NPU    (1,64,120,120),(64,64,3,3),(64)          (1,64,120,120)         79504/518400/518400      722          71.80/0.00/0.00      100.0%/0.0%/0.0%     936          Conv:/model.22/cv3.1/cv3.1.1/conv/Conv
91   ConvExSwish      INT8     NPU    (1,128,60,60),(128,128,3,3),(128)        (1,128,60,60)          45239/518400/518400      700          74.06/0.00/0.00      100.0%/0.0%/0.0%     595          Conv:/model.21/m.0/cv1/conv/Conv
92   ConvSigmoid      INT8     NPU    (1,64,120,120),(3,64,1,1),(3)            (1,3,120,120)          58465/57600/58465        429          0.63/0.00/0.00       100.0%/0.0%/0.0%     900          Conv:/model.22/cv3.1/cv3.1.2/Conv
93   OutputOperator   INT8     CPU    (1,3,120,120)                            \                      0/0/0                    57           \                    0.0%/0.0%/0.0%       450          OutputOperator:onnx::ReduceSum_351
94   ConvExSwish      INT8     NPU    (1,128,60,60),(128,128,3,3),(128)        (1,128,60,60)          45239/518400/518400      699          74.16/0.00/0.00      100.0%/0.0%/0.0%     595          Conv:/model.21/m.0/cv2/conv/Conv
95   Concat           INT8     NPU    (1,128,60,60),(1,128,60,60),...          (1,384,60,60)          116886/0/116886          585          \                    100.0%/0.0%/0.0%     1350         Concat:/model.21/Concat
96   ConvClip         INT8     NPU    (1,3,120,120),(1,3,1,1),(1)              (1,1,120,120)          38969/57600/57600        161          0.03/0.00/0.00       100.0%/0.0%/0.0%     450          Conv:/model.22/ReduceSum_1_2conv
97   OutputOperator   INT8     CPU    (1,1,120,120)                            \                      0/0/0                    83           \                    0.0%/0.0%/0.0%       450          OutputOperator:355
98   ConvExSwish      INT8     NPU    (1,384,60,60),(256,384,1,1),(256)        (1,256,60,60)          101647/345600/345600     655          52.76/0.00/0.00      100.0%/0.0%/0.0%     1448         Conv:/model.21/cv2/conv/Conv
99   ConvExSwish      INT8     NPU    (1,256,60,60),(64,256,3,3),(64)          (1,64,60,60)           54958/518400/518400      751          69.03/0.00/0.00      100.0%/0.0%/0.0%     1044         Conv:/model.22/cv2.2/cv2.2.0/conv/Conv
100  ConvExSwish      INT8     NPU    (1,256,60,60),(64,256,3,3),(64)          (1,64,60,60)           54958/518400/518400      755          68.66/0.00/0.00      100.0%/0.0%/0.0%     1044         Conv:/model.22/cv3.2/cv3.2.0/conv/Conv
101  ConvExSwish      INT8     NPU    (1,64,60,60),(64,64,3,3),(64)            (1,64,60,60)           21061/129600/129600      209          62.01/0.00/0.00      100.0%/0.0%/0.0%     261          Conv:/model.22/cv2.2/cv2.2.1/conv/Conv
102  Conv             INT8     NPU    (1,64,60,60),(64,64,1,1),(64)            (1,64,60,60)           19676/28800/28800        118          12.20/0.00/0.00      100.0%/0.0%/0.0%     229          Conv:/model.22/cv2.2/cv2.2.2/Conv
103  OutputOperator   INT8     CPU    (1,64,60,60)                             \                      0/0/0                    34           \                    0.0%/0.0%/0.0%       225          OutputOperator:362
104  ConvExSwish      INT8     NPU    (1,64,60,60),(64,64,3,3),(64)            (1,64,60,60)           21061/129600/129600      205          63.22/0.00/0.00      100.0%/0.0%/0.0%     261          Conv:/model.22/cv3.2/cv3.2.1/conv/Conv
105  ConvSigmoid      INT8     NPU    (1,64,60,60),(3,64,1,1),(3)              (1,3,60,60)            14633/14400/14633        165          0.41/0.00/0.00       100.0%/0.0%/0.0%     225          Conv:/model.22/cv3.2/cv3.2.2/Conv
106  OutputOperator   INT8     CPU    (1,3,60,60)                              \                      0/0/0                    23           \                    0.0%/0.0%/0.0%       112          OutputOperator:onnx::ReduceSum_370
107  ConvClip         INT8     NPU    (1,3,60,60),(1,3,1,1),(1)                (1,1,60,60)            9748/14400/14400         102          0.01/0.00/0.00       100.0%/0.0%/0.0%     112          Conv:/model.22/ReduceSum_2_2conv
108  OutputOperator   INT8     CPU    (1,1,60,60)                              \                      0/0/0                    23           \                    0.0%/0.0%/0.0%       112          OutputOperator:374
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Total Operator Elapsed Per Frame Time(us): 128441
Total Memory Read/Write Per Frame Size(KB): 289739
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
                                 Operator Time Consuming Ranking Table            
---------------------------------------------------------------------------------------------------
OpType             CallNumber   CPUTime(us)  GPUTime(us)  NPUTime(us)  TotalTime(us)  TimeRatio(%)  
---------------------------------------------------------------------------------------------------
ConvExSwish        57           0            0            100965       100965         78.61%        
Concat             13           0            0            11349        11349          8.84%         
Split              8            0            0            4818         4818           3.75%         
Add                6            0            0            3156         3156           2.46%         
ConvSigmoid        3            0            0            1974         1974           1.54%         
Resize             2            0            0            1801         1801           1.40%         
Conv               3            0            0            1526         1526           1.19%         
OutputOperator     9            1134         0            0            1134           0.88%         
MaxPool            3            0            0            1013         1013           0.79%         
ConvClip           3            0            0            701          701            0.55%         
InputOperator      1            4            0            0            4              0.00%         
---------------------------------------------------------------------------------------------------
```

# 附录2：根据自己的模型修改后处理函数
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
