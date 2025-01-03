---
layout: default
title: Push Yolov8n Pre-train Model To rk3588 (1)
categories:
- Linux
tags:
- Server
- Linux
---
//Description: 模型转换。记录把Yolov8n预训练的模型push到rk3588的板子上进行目标检测的整个过程，其中遇到原始模型无法jit.load、模型转换后检测错误、板子上安装SDK失败等问题，最终通过改用load、分析error list抛弃部分模型、检查版本一致性解决。写于2024年4月初，SDK文档参考了v2.0.0beta0版本，板子实际运行安装的SDK是1.6.0版本。后发现更建议用SDK的官网转换而不是Yolov8的官网转换方法，同时记录了模型转换过程中的剪枝、量化、混合量化等操作；同时pt转onnx的方式有问题，应该使用SDK官网的转换方式并设置imgsz而不是使用Yolov8官网的转换方式。

//Create Date: 2024-04-02 10:14:28

//Author: channy

[toc]

# 基本环境信息
板子上需要版本一致 Version (RKNN Server = Runtime = RKNN-Toolkit2)。aarch64。
* RKNN Server: 1.5.0
* RKNN Runtime (librknnrt): 1.5.0
* RKNPU driver: 0.9.2

PC 使用了Ubuntu，必需要x86_64，因为官方的SDK中只有x64的whl安装文件，aarch64的只能安装ToolkitLite

官网代码：
[airockchip](https://github.com/airockchip)
[rockchip-linux](https://github.com/rockchip-linux)
[rockchip-npu](https://github.com/Pelochus/linux-rockchip-npu-0.9.6/releases)
[论坛](https://dev.t-firefly.com/portal.php?mod=topic&topicid=11)
[ROC-RK3588S-PC](https://wiki.t-firefly.com/zh_CN/ROC-RK3588S-PC/index.html)

# 代码清单
1. pt模型转换成onnx模型： [pt2onnx](https://github.com/channyHuang/rk3588DeployNoteAndCode/blob/main/modelConvert/pt2onnx.py)
1. PC上查看onnx模型的检测结果： [inferenceUsingOnnxInPC](https://github.com/channyHuang/rk3588DeployNoteAndCode/blob/main/modelConvert/inferenceUsingOnnxInPC.py)
1. 在PC上转换成rknn模型并模拟检测： [inferenceSimulateInPC](https://github.com/channyHuang/rk3588DeployNoteAndCode/blob/main/modelConvert/inferenceSimulateInPC.py)

# Step0: 安装rknnlite2
## Q: Python.h：没有那个文件或目录
```sh
sudo apt install libpython3-dev
```

## Q: ruamel.yaml.clib
```sh
sudo apt install libyaml-dev

pip3 install --upgrade setuptools wheel
```
可同时升级pip3

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
> <font color=red>这里遇到的错误后面发现都是因为使用Yolov8的官网转换模型的缘故，其实正确的操作应该是使用rknn的SDK的官网进行模型转换。后面再细说，这里先记下遇到过的错误。</font>

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
rknn_lite.list_support_target_platform(rknn_model=’mobilenet_v1.rknn’)
# 释放资源
rknn_lite.release()
```
看样子性能什么的还是需要PC或连板，貌似不能直接在板上调用接口获取性能信息。

文档中写了PC（模拟器和板端）的性能评估，但经测试只有精度分析`rknn.accuracy_analysis()`能在模拟器中进行，性能评估`rknn.eval_perf()`和内存评估`rknn.eval_memory()`都需要连板。


# 使用RKNN的官网代码进行模型转换
[ultralytics_yolov8](https://github.com/ultralytics/ultralytics_yolov8)

使用Yolov8的官网代码转换模型会遇到各种问题，换用RKNN的官网代码转换能够避免，因其在转换过程中做了其它处理。

把`pt`模型转换成`onnx`后，再使用`rknn_model_zoo`中example对应的yolo版本进行`onnx`到`rknn`的转换。

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

接着发现之前耗时大的真正原因是`pt`转`onnx`的转换方式也有问题，用Yolov8官网的转换方式是保持了输入尺寸即1920x1920的，分辨率大导致耗时大；用SDK官网的转换方式默认参数imgsz＝640，转换后才能达到和demo相当的水平。但从1920转换到640会伴随精度丢失，因为1920的输入图像会经过缩放后再推理。

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

但量化确实能够在一定程度上提高效率，1920x1920的模型推理未量化约0.4s每帧，量化后可以减小到0.3s每帧。

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

# Python自定义算子
## 模型准备
```python
import onnx

path = '../model/yolov8n.onnx'
model = onnx.load(path)

for node in model.graph.node:
    if node.op_type == 'Softmax':
        node.op_type = 'cstSoftmax'

onnx.save(model, 'yolov8n_custom.onnx')
```
## 定义算子运算
自定义算子类，主要包含`shape_infer`和`compute`两个函数
```python
import numpy as np
from rknn.api.custom_op import get_node_attr

class cstSoftmax:
    op_type = 'cstSoftmax'
    def shape_infer(self, node, in_shapes, in_dtypes):
        out_shapes = in_shapes.copy()
        out_dtypes = in_dtypes.copy()
        return out_shapes, out_dtypes
    def compute(self, node, inputs):
        x = inputs[0]
        axis = get_node_attr(node, 'axis')
        x_max = np.max(x, axis = axis, keepdims = True)
        tmp = np.exp(x - x_max)
        s = np.sum(tmp, axis = axis, keepdims = True)
        outputs = [tmp / s]
        return outputs
```
## 转换成rknn
在`config`和`load`之间注册自定义算子`reg_custom_op`
```python
rknn = RKNN(verbose = True)
    rknn.config(mean_values=[127.5, 127.5, 127.5], std_values=[127.5, 127.5, 127.5], 
                quant_img_RGB2BGR = True, target_platform = 'rk3588')
    ret = rknn.reg_custom_op(cstSoftmax())
    if ret != 0:
        print('Register op failed!')
        exit(ret)
    ret = rknn.load_onnx(model = 'yolov8n_custom.onnx')
    if ret != 0:
        print('Load model failed!')
        exit(ret)
    ret = rknn.build(do_quantization = False)
    if ret != 0:
        print('Build model failed!')
        exit(ret)
    ret = rknn.export_rknn(export_path = './yolov8n_custom.rknn', simplify = False, cpp_gen_cfg = False)
    ret = rknn.load_rknn('yolov8n_custom.rknn')
    ret = rknn.init_runtime(target = None, perf_debug = False, eval_mem = True, async_mode = False)#, core_mask = RKNN.NPU_CORE_0_1_2)
    # inference here ...
    image_inference(args, rknn)
```
