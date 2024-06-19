---
layout: default
title: Push Yolov8n Pre-train Model To rk3588 (1)
categories:
- Linux
tags:
- Server
- Linux
---
//Description: 记录把Yolov8n预训练的模型push到rk3588的板子上进行目标检测的整个过程，其中遇到原始模型无法jit.load、模型转换后检测错误、板子上安装SDK失败等问题，最终通过改用load、分析error list抛弃部分模型、检查版本一致性解决。写于2024年4月初，SDK文档参考了v2.0.0beta0版本，板子实际运行安装的SDK是1.6.0版本。

//Create Date: 2024-04-02 10:14:28

//Author: channy

[toc]

# 基本环境信息
板子上需要版本一致 Version (RKNN Server = Runtime = RKNN-Toolkit2)。aarch64。
* RKNN Server: 1.5.0
* RKNN Runtime (librknnrt): 1.5.0
* RKNPU driver: 0.9.2

PC 使用了Ubuntu，必需要x86_64，因为官方的SDK中只有x64的whl安装文件，aarch64的只能安装ToolkitLite

# 代码清单
1. pt模型转换成onnx模型： [pt2onnx](https://github.com/channyHuang/rk3588DeployNoteAndCode/blob/main/modelConvert/pt2onnx.py)
1. PC上查看onnx模型的检测结果： [inferenceUsingOnnxInPC](https://github.com/channyHuang/rk3588DeployNoteAndCode/blob/main/modelConvert/inferenceUsingOnnxInPC.py)
1. 在PC上转换成rknn模型并模拟检测： [inferenceSimulateInPC](https://github.com/channyHuang/rk3588DeployNoteAndCode/blob/main/modelConvert/inferenceSimulateInPC.py)

# step1: pt模型转换成onnx模型
一开始尝试的是使用Yolov8的官网代码进行模型转换。

原本是想要直接使用SDK中的`rknn.load_pytorch(model = '../model/v8n.pt', input_size_list = [[1, 3, 1920, 1920]])`直接转换成rknn的，但出现了load错误
## Q: torch.jit.load failed

```sh
RuntimeError('PytorchStreamReader failed locating file constants.pkl: file not found')
```

```sh
D Save log info to: build.log
I rknn-toolkit2 version: 2.0.0b0+9bab5682
W config: The quant_img_RGB2BGR of input 0 is set to True, which means that the RGB2BGR conversion will be done first
          when the quantized image is loaded (only valid for jpg/jpeg/png/bmp, npy will ignore this flag).
          Special note here, if quant_img_RGB2BGR is True and the quantized image is jpg/jpeg/png/bmp,
          the mean_values / std_values in the config corresponds the order of BGR.
W load_pytorch: Catch exception when torch.jit.load:
    RuntimeError('PytorchStreamReader failed locating file constants.pkl: file not found')
W load_pytorch: Make sure that the torch version of '/home/channy/Documents/thirdlibs/rknn_model_zoo/examples/yolov8/model/v8n.pt' is consistent with the installed torch version '2.2.1+cu121'!
E load_pytorch: Traceback (most recent call last):
E load_pytorch:   File "rknn/api/rknn_base.py", line 1590, in rknn.api.rknn_base.RKNNBase.load_pytorch
E load_pytorch:   File "/home/channy/miniconda3/envs/NewVersion/lib/python3.8/site-packages/torch/jit/_serialization.py", line 159, in load
E load_pytorch:     cpp_module = torch._C.import_ir_module(cu, str(f), map_location, _extra_files, _restore_shapes)  # type: ignore[call-arg]
E load_pytorch: RuntimeError: PytorchStreamReader failed locating file constants.pkl: file not found
W If you can't handle this error, please try updating to the latest version of the toolkit2 and runtime from:
  https://console.zbox.filez.com/l/I00fc3 (Pwd: rknn)  Path: RKNPU2_SDK / 2.X.X / develop /
  If the error still exists in the latest version, please collect the corresponding error logs and the model,
  convert script, and input data that can reproduce the problem, and then submit an issue on:
  https://redmine.rock-chips.com (Please consult our sales or FAE for the redmine account)
E build: The model has not been loaded, please load it first!
E export_rknn: RKNN model does not exist, please load & build model first!
E init_runtime: RKNN model does not exist, please load & build model first!
E inference: The runtime has not been initialized, please call init_runtime first!
```
上网搜索发现缺少`constants.pkl`大概率是导出模型的时候设置的只导出权重还是导出整个网络导致的，不方便重新训练导出，故直接改用Yolov8自带的格式转换函数先行转换到`onnx`模型，见附录１。

后续查看RKNPU的2.0版官方文档发现文档的常见问题中也有说明：
> 目前只支持'torch.jit.trace()'导出的模型。'torch.save()'接口仅保存权重参数字典,缺乏网络结构信息，无法被正常导入并转成 RKNN 模型

# step 2: PC上查看onnx模型的检测结果
检测图像中有多个目标，能够正常检测到其中两个目标。

# step 3: 在PC上转换成rknn模型并模拟检测
> <font color=red>这里遇到的错误后面发现都是因为使用Yolov8的官网转换模型的缘故，其实正确的操作应该是使用rknn的SDK的官网进行模型转换。下一篇笔记再细说，这里先记下遇到过的错误。</font>

使用官网模型报`failed to config argb mode layer`错误，因为模型中有rk3588不支持的算子Softmax导致，需要在训练生成模型时修改成其它如tanh之类的。

```sh
I rknn-toolkit2 version: 2.0.0b0+9bab5682
W config: The quant_img_RGB2BGR of input 0 is set to True, which means that the RGB2BGR conversion will be done first
          when the quantized image is loaded (only valid for jpg/jpeg/png/bmp, npy will ignore this flag).
          Special note here, if quant_img_RGB2BGR is True and the quantized image is jpg/jpeg/png/bmp,
          the mean_values / std_values in the config corresponds the order of BGR.
I Loading :   0%|                                                           | 0/I Loading : 100%|██████████████████████████████████████████████| 147/147 [00:00<00:00, 68075.82it/s]
I rknn building ...
E RKNN: [17:10:22.036] failed to config argb mode layer!
Aborted (core dumped)
```

其中`ret = rknn.load_onnx(model = model_path, outputs = export_outputs)`参数outputs默认为`onnx`的最终输出模型。

## Q: ERROR 'REGTASK: The bit width of field value exceeds the limit'
```
E RKNN: [11:55:46.914] REGTASK: The bit width of field value exceeds the limit, target: v2, offset: 0x4038, shift = 16, limit: 0x1fff, value: 0x11f70
E RKNN: [11:55:46.914] REGTASK: The bit width of field value exceeds the limit, target: v2, offset: 0x5048, shift = 19, limit: 0x1fff, value: 0x11f70
```
模型转换报错`REGTASK: The bit width of field value exceeds the limit`，但依然会输出转换后的rknn文件。

上网搜索有说加`simplify=False`参数的，有让增加混合量化的，尝试后均没有解决报错问题，模型转换过程中依旧会报上面的错误。又搜索到说该报错不影响的，没找到解决方案，暂时搁置。

## Q: detect failed
最初`output`参数没有设置，直接使用的默认值。结果发现检测失败，没有任何检测结果。

然后使用  
`ret = rknn.accuracy_analysis(inputs = ['../model/test.jpg'], target = None)`  
分析误差。在`snapshot`文件夹下`error_analysis.txt`文件中查看每一层网络PC模拟和原模型的误差差距。

发现官方模型每层的欧拉距离都在6以内，但自己的模型最后两层欧拉距离达到180+。怀疑是最后两层有不支持的算子导致的误差太大从而检测失败。

```
[Mul] /model.22/Mul_2_output_0_shape4                                               1.00000 | 181.08    1.00000 | 83.088        
[Reshape] /model.22/Mul_2_output_0                                                  1.00000 | 181.08    1.00000 | 83.088 
```

使用netron查看原`onnx`文件的网络结构
```sh
sudo snap install netron


```
![onnx_net](./../../images/onnx_net.png)

在`rknn.load_onnx(...)`中设置`outputs`参数舍弃误差太大的层。

再重新转换成rknn后模拟检测发现可以检测到目标了。

## Q: different results in simulator and PC
然后发现对同一张包含多个目标的图像，PC上使用`onnx`模型能够检测到2个目标，PC模拟使用`rknn`也能够检测到2个目标，但不是相同的2个目标，即检测结果不完全一致，前者检测到目标A和B，而后者检测到目标A和C。

# step 4: 在板子上运行目标检测
把生成的rknn放到板子上后，根据SDK文档在板子上安装SDK，即目录`rknn-toolkit-lite2/packages`下的whl文件。确认版本一致 Version (RKNN Server = Runtime = RKNN-Toolkit2)。

安装完成后，在板子上是rknnlite，直接加载模型、初始化，即可以推理。

```python
from rknnlite.api import RKNNLite

rknn_lite = RKNNLite()
ret = rknn_lite.load_rknn('yolov8n.rknn')
ret = rknn_lite.init_runtime(core_mask=RKNNLite.NPU_CORE_0)

# read image same as in PC

outputs = rknn_lite.inference(inputs=[img])
# do something same as in PC
rknn_lite.release()
```
详细可见附录3。

板子上的RKNNLite接口(python版)一共只有7个：
```python
# 初始化
rknn_lite =　RKNNLite(verbose=True, verbose_file='./inference.log') 
# 加载模型
ret = rknn_lite.load_rknn('./resnet_18.rknn')
# 初始化运行时环境
ret = rknn_lite.init_runtime(core_mask=RKNNLite.NPU_CORE_AUTO)
# 模型推理
outputs = rknn_lite.inference(inputs=[img])
# 查询 SDK 版本
sdk_version = rknn_lite.get_sdk_version()
# 查询模型可运行平台
rknn_lite.list_support_target_platform(rknn_model=’mobilenet_v1.r
knn’)
# 释放资源
rknn_lite.release()
```
看样子性能什么的还是需要PC或连板，貌似不能直接在板上调用接口获取性能信息。

文档中写了PC（模拟器和板端）的性能评估，但经测试只有精度分析`rknn.accuracy_analysis()`能在模拟器中进行，性能评估`rknn.eval_perf()`和内存评估`rknn.eval_memory()`都需要连板。

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
https://mirror.baidu.com/pypi/simple
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
