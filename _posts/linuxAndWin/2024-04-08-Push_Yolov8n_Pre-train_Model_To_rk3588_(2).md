---
layout: default
title: Push Yolov8n Pre-train Model To rk3588 (2)
categories:
- Linux
tags:
- Server
- Linux
---
//Description: 性能统计。记录yolov8n部署到rk3588后的性能统计和分析，然而并没有明显优化效果，最终通过模型不同的输出测试，确认为输入分辨率对识别耗时有明显影响。同时统计了不同分辨率下的推理正确率。写于2024年4月初，SDK文档参考了v2.0.0beta0版本，板子实际运行安装的SDK是1.6.0版本。

//Create Date: 2024-04-08 10:14:28

//Author: channy

[toc]

# 代码清单
[cpp](https://github.com/channyHuang/rk3588DeployNoteAndCode/cpp)

# python推理耗时记录
背景：使用python写读入图像、推理、画框显示整个过程总耗时在0.5s/帧左右，耗时集中在python的rknn推理接口。

不同模型识别耗时不一样，集中在SDK的api中
* Python的耗时集中在rknn.inference上，自己的模型用时0.47+s/帧

## `rknn.eval_perf()`报错
在执行性能评估时发生
`invalid literal for int() with base 10: 'cat: /sys/class/devfreq/dmc/cur_freq: 没有那个文件或目录'`
的错误。
```sh
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

# 模型耗时和demo相差大
先后试过不同的模型输入分辨率并记录Python单推理接口耗时/帧如下。 
 
| 模型输入分辨率 | 模型训练代码版本 | 激活函数 | onnx转换方式 | SDK转换参数 | Python单推理接口耗时/帧 | 本地视频全流程帧率(fps) |
|:---:|:------:|:---:|:---:|:---:|:---:|:---:|
| 1920 x 1920 | Yolov5n | Relu | Yolov8官网转换 | - | 0.25s |
| 1920 x 1920 |	Yolov8n | Softmax | Yolov8官网转换 | - | 0.5s |
| 1920 x 1920 | Yolov8n | Softmax | SDK官网转换 | imgsz=640 | <font color=red>0.06s</font> |
| 1920 x 1920 | Yolov8n | Softmax | SDK官网转换 | imgsz = 1920 | 0.42s |
| 1920 x 1920 |	Yolov8n | Relu | Yolov8官网转换 | - | 0.5s |
| 1920 x 1920 |	Yolov8n | Relu | SDK官网转换 | imgsz=640 | <font color=red>0.06s</font> |
| 1920 x 1920 |	Yolov8n | Relu | SDK官网转换 | imgsz=1920 | 0.42s | 20 
| 640 x 640 | Yolov8n | Relu | SDK官网转换 | imgsz=640 | <font color=red>0.04s</font> | 40
| 640 x 640 | Yolov8n | Relu | SDK官网转换 | imgsz=1920 | 0.42s |

最终确认耗时大的主要原因是分辨率大。同时注意到`failed to config argb mode layer`错误。

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

# 正确率计算
在板子上用自己训练的转换后的模型直接检测训练数据并统计检测目标结果

## 未量化
| 阈值 | 总目标 | 正确数(占比) | 错误数(占比) | 漏检数(占比) |
|:---:|:---:|:---:|:---:|:---:|
| 0.25 | 32412 | 31655(0.97) | 19364(0.59) | 757(0.02) |
| 0.5  | 32412 | 29581(0.91) | 3593(0.11) | 2831(0.08) |
| 0.63 | 32412 | 27792(0.85) | 1704(0.05) | 4620(0.14) |
| 0.80 | 32412 | 13989(0.43) | 156(0.004) | 18423(0.56) |

误检最高置信度0.91+

## 量化
| 阈值 | 总目标 | 正确数(占比) | 错误数(占比) | 漏检数(占比) |
|:---:|:---:|:---:|:---:|:---:|
| 0.5  | 32412 | 31041(0.95) | 440(0.01) | 1371(0.04) |
| 0.63 | 32412 | 30108(0.92) | 221(0.006) | 2304(0.07) |
| 0.80 | 32412 | 18001(0.555)| 34(0.001) | 14411(0.44) |

误检最高置信度0.889455

## 尺寸对比
### 0626.pt
YOLOv8n summary: 225 layers, 3012408 parameters, 0 gradients, 8.2 GFLOPs
(225, 3012408, 0, 8.201676800000001)

阈值：0.8 

| 尺寸 | GFLOPS | fps(py/c++) | mAP | MAC(KB) |
|:---:|:---:|:---:|:---:|:---:|
| 1920x1920 | 8.2 | 1.55/4.44 | 0.77 | 289740 |
| 1920x1088 | 8.2 | 2.38/7.02 | 0.65 | 165476 |

| 尺寸 | 总目标 | 正确数 | 错误数 | 漏检数 | 
|:---:|:---:|:---:|:---:|:---:|
| PC | 18600 | 12687(0.68) | 381(0.02) | 5913(0.31) 
| 1920x1920 | 18600 | 14244(0.77) | 504(0.03) | 4356(0.23)
| 1920x1088 | 18600 | 12071(0.65) | 301(0.02) | 6529(0.35)

### 0715.pt 
YOLOv8n summary (fused): 168 layers, 3007208 parameters, 0 gradients, 8.1 GFLOPs

| 尺寸 | GFLOPS | fps(py/c++) | mAP | MAC(KB) |
|:---:|:---:|:---:|:---:|:---:|
| 1920x1920 | 8.1 | 1.65/4.30 | 0.85 | 289740 |
| 1920x1088 | 8.1 | 2.46/5.07 | 0.68 | 165476 |

| 尺寸 | 阈值 | 总目标 | 正确数 | 错误数 | 漏检数 | 
|:---:|:---:|:---:|:---:|:---:|:---:|
| 1920x1920 | 0.80 | 11951 | 10101(0.85) | 270(0.02) | 1850(0.15) |
| 1920x1920 | 0.63 | 11951 | 11066(0.93) | 472(0.04) | 885(0.07) |
| 1920x1088 | 0.80 | 11951 | 8123(0.68) | 359(0.03) | 3828(0.32) |
| 1920x1088 | 0.63 | 11951 | 9807(0.82) | 586(0.05) | 2144(0.18) |


# 其它记录
## 查看npu占用
```sh
sudo cat /sys/kernel/debug/rknpu/load
```
## 国内源
```
阿里云： http://mirrors.aliyun.com/pypi/simple/
中国科技大学： https://pypi.mirrors.ustc.edu.cn/simple/
豆瓣： http://pypi.douban.com/simple/
清华大学： https://pypi.tuna.tsinghua.edu.cn/simple/
中国科学技术大学： http://pypi.mirrors.ustc.edu.cn/simple/
百度：https://mirror.baidu.com/pypi/simple
```
## pip3 install 后使用sudo python3 xxx.py出现找不到对应的module
如果sudo启动时报 'ModuleNotFoundError: No module named rknnlite'
*  可能1：没安装RKNN的SDK
*  可能2：安装时没有用 sudo，因为sudo用户和普通用户的python包查找路径不完全一样，不想花时间用sudo重新安装的话，可做如下操作  
1. 分别查看sudo下和普通环境下Python的Path
```sh
firefly@kylinos:~$ sudo python3
输入密码
Python 3.8.10 (default, Jan 23 2024, 01:35:54) 
[GCC 9.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import sys
>>> sys.path
['', '/usr/lib/python38.zip', '/usr/lib/python3.8', '/usr/lib/python3.8/lib-dynload', '/usr/local/lib/python3.8/dist-packages', '/usr/lib/python3/dist-packages']
```
```sh
firefly@kylinos:~$ python3
Python 3.8.10 (default, Jan 23 2024, 01:35:54) 
[GCC 9.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import sys
>>> sys.path
['', '/usr/lib/python38.zip', '/usr/lib/python3.8', '/usr/lib/python3.8/lib-dynload', '/home/firefly/.local/lib/python3.8/site-packages', '/usr/local/lib/python3.8/dist-packages', '/usr/lib/python3/dist-packages']
```
2. 将普通环境下的库链接到sudo Python下  

在Python的dist-packages下创建*.pth文件
```sh
firefly@kylinos:~$ cd /usr/local/lib/python3.8/dist-packages
firefly@kylinos:/usr/local/lib/python3.8/dist-packages$ sudo touch rknn_py38_path.pth
```
并在创建的*.pth文件中加入上面查看到的普通环境下的`sys.path`  

*.pth文件
```
/usr/lib/python38.zip
/usr/lib/python3.8
/usr/lib/python3.8/lib-dynload
/home/firefly/.local/lib/python3.8/site-packages
/usr/local/lib/python3.8/dist-packages
/usr/lib/python3/dist-packages
```
3. 此时使用sudo也可以运行不再报找不到Module错误
## onnxruntime在cpu/gpu下跑
```python
import onnxruntime
print(onnxruntime.get_device())
ort_session = onnxruntime.InferenceSession('../model/v8n.onnx', provides = ['CUDAExecutionProvider'])
print(ort_session.get_providers())
```

```
// output
GPU
['CPUExecutionProvider']
```
# ffmpeg
../configure --prefix=$PWD/install --disable-x86asm --enable-static --enable-shared
