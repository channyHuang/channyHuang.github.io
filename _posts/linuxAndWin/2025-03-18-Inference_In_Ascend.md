---
layout: default
title: 在银河Kylin+华为昇腾一体机上进行模型推理部署
categories:
- Linux
tags:
- Server
- Linux
---
//Description: 记录在银河Kylin系统+华为昇腾一体机进行模型推理部署过程中的笔记，写于2025年3月

//Create Date: 2025-03-18 14:20:28

//Author: channy

[toc]

# 在银河Kylin+华为昇腾一体机进行模型推理部署
## 背景
Edge-FHDS2300-Z1算力机。

计划在原ubuntu (x86_64) 服务器上继续训练，只在算力机 (aarch64) 上做推理部署，不在算力机上训练（机器风扇太太太吵了@_@）。

## 开发环境准备
### 训练机上
1. 安装CANN软件，（Ascend-cann-toolkit_8.0.0_linux-x86_64.run）  
Ubuntu上安装[Ascend](https://www.hiascend.com/document/detail/zh/Atlas200IDKA2DeveloperKit/23.0.RC2/Application%20Development%20Guide/tmuacop/tmuacop_0016.html)

[资源下载](https://www.hiascend.com/developer/download/community/result?module=cluster+pt+tf+cann&cannChild=rt)

2. 配置环境变量
```sh
source /home/channy/Ascend/ascend-toolkit/set_env.sh 

export LD_LIBRARY_PATH=/home/channy/Ascend/ascend-toolkit/latest/x86_64-linux/devlib/:$LD_LIBRARY_PATH
```
或者把
```sh
source /home/channy/Ascend/ascend-toolkit/set_env.sh
```
加入到`~/.bashrc`中

3. 验证模型转换工具已正确安装　
```sh
$ atc
ATC start working now, please wait for a moment.
...
ATC run failed, Please check the detail log, Try 'atc --help' for more information
E10007: [PID: 10490] 2025-03-18-09:02:18.501.341 [--framework] is required. The value must be [0(Caffe) or 1(MindSpore) or 3(TensorFlow) or 5(Onnx)].
```

### 算力机上
1. 安装CANN软件，（Ascend-cann-toolkit_8.0.RC3_linux-aarch64.run)
其中如果需要用于torch_npu的话，不建议安装最新版torch（写该文章时是2.4.0）和torchvision（0.19.1），因为torch_npu会因版本不匹配而报错。

官网的第三方库支持版本列表：[完整清单列表](https://www.hiascend.com/document/detail/zh/Pytorch/60RC2/modthirdparty/modparts/thirdpart_0005.html)

[torch_npu](https://www.hiascend.com/document/detail/zh/Pytorch/60RC2/configandinstg/instg/insg_0001.html)
这时还只支持torch 2.3.1以下的。

| torch | torchvision | torch_npu |
|:---:|:---:|:---:|
| 2.1.0 | 0.16.0  | 5.0.rc2 |

## 模型转换
1. 查看AI处理器版本号
```sh
$ npu-smi info
+--------------------------------------------------------------------------------------------------------+
| npu-smi 23.0.0                                   Version: 23.0.0                                       |
+-------------------------------+-----------------+------------------------------------------------------+
| NPU     Name                  | Health          | Power(W)     Temp(C)           Hugepages-Usage(page) |
| Chip    Device                | Bus-Id          | AICore(%)    Memory-Usage(MB)                        |
+===============================+=================+======================================================+
| 24      310P3                 | OK              | NA           29                0     / 0             |
| 0       0                     | 0000:04:00.0    | 0            1832 / 21527                            |
+===============================+=================+======================================================+
+-------------------------------+-----------------+------------------------------------------------------+
| NPU     Chip                  | Process id      | Process name             | Process memory(MB)        |
+===============================+=================+======================================================+
| No running processes found in NPU 24                                                                   |
+===============================+=================+======================================================+
```
其中`Name`下方的`310P3`前加上`Ascend`即为版本号`Ascend310P3`

2. 转换模型
```sh
atc --model=encodeModel.onnx --framework=5 --output=encodeModel --soc_version=Ascend310B4
atc --model=encodeModel.onnx --framework=5 --output=encodeModel --soc_version=Ascend310P3
```

`--framework`原始框架类型，各框架对应的数值如下：
0:Caffe; 1:MindSpore; 3:Tensorflow; 5:ONNX

## 修改适配机载推理代码 
把cuda改成npu，如`torch.cuda.is_available`改成`torch.npu.is_available`，`xxx.cuda()`改成`xxx.npu()`等。。。是不够的。。。

直接用`torch.load`加载.om模型，报错
```sh
    encodeModel = torch.load(sEncodeModel).float()
  File "/home/edge/.local/lib/python3.8/site-packages/torch/serialization.py", line 1028, in load
    return _legacy_load(opened_file, map_location, pickle_module, **pickle_load_args)
  File "/home/edge/.local/lib/python3.8/site-packages/torch/serialization.py", line 1246, in _legacy_load
    magic_number = pickle_module.load(f, **pickle_load_args)
ValueError: could not convert string to int
```

最开始看到拿到的机器里下载好了一个`Ascend-cann-toolkit-8.0.RC1.alpha001_linux-aarch64.run`，没有怀疑直接安装，然后使用`pyACL`加载模型一直加载失败返回错误码500002内部错误，见附录1。没有头绪尝试着重新下载安装RC3高一点版本的`Ascend-cann-toolkit-8.0.RC3_linux-aarch64.run`然后加载就好了。。。好了。。。了。。。

[pyACL](https://www.hiascend.com/document/detail/zh/canncommercial/700/inferapplicationdev/aclpythondevg/nottoctopics/aclpythondevg_01_0002.html)

[错误码列表](https://www.hiascend.com/document/detail/zh/canncommercial/700/inferapplicationdev/aclpythondevg/nottoctopics/aclpythondevg_01_0901.html)

## 其它小bug
插着无线网卡开机会卡在“银河Kylin”那个蓝色标志的开机画面，只有先拔掉无线网卡再开机等开机进桌面后再插上无线网卡才能正常。不知道是无线网卡的原因还是什么原因。

## OpenVino
OpenVino更多支持Intel的CPU/GPU
[推理设备支持](https://docs.openvino.ai/cn/2022.3/openvino_workflow_zh_CN/deployment_intro_zh_CN/openvino_intro_zh_CN/GPU_zh_CN.html)
### apt install 安装依赖
libcurl4-openssl-dev
iperf3
llvm-12-dev
clang-12
libclang-12-dev
scons
### 编译调试
能够编译成功，但发现无法在aarch64的华为盒子里跑OpenVino，无论是CPU还是GPU或是NPU。CPU直接崩溃，GPU报找不到
```sh
Device with "GPU" name is not registedred in the OpenVINO Runtime
```
## onnxruntime
onnxruntime能够调用起华为盒子的CPU做推理，但速度巨慢，近10s（对应于调用Intel的CPU用时2s，Intel的GPU用时0.5s）

# 附录1: 安装低版本CANN后加载模型报错
使用python的`acl.mdl.load_from_file('xxx.om')`一直失败，错误码500002内部错误。
/home/xxx/ascend/log/debug/plog/里面的日志报错
```sh
[ERROR] DRV(69072,python3):2025-03-18-14:35:48.599.331 [ascend][curpid: 69072, 69072][drv][devmm][_devmm_mem_remote_map 1888]<errno:22, 8> Mem_remote_map ioctl error. (src_va=0x124080000000; size=4194304; devid=0; ret=8)
[ERROR] RUNTIME(69072,python3):2025-03-18-14:35:48.599.713 [pool.cc:1031]69072 MallocPcieBarBuffer:Pcie Host Register failed, retCode=0x7020010, size=4194304(Byte), dev_id=0.
[ERROR] RUNTIME(69072,python3):2025-03-18-14:35:48.599.725 [pool.cc:190]69072 BufferAllocator:allocFunc failed, init count=1024, item size=4096(Byte)
[ERROR] GE(69072,python3):2025-03-18-14:35:48.619.348 [model_utils.cc:1313]69072 GetHbmFeatureMapMemInfo: ErrorNo: 4294967295(failed) [LOAD][DEFAULT]Assert (sub_memory_info.size() == 3U) failed, expect 3 actual 4
[ERROR] GE(69072,python3):2025-03-18-14:35:48.619.603 [model_utils.cc:1329]69072 GetAllMemoryTypeSize: ErrorNo: 4294967295(failed) [LOAD][DEFAULT]Assert ((GetHbmFeatureMapMemInfo(ge_model, all_mem_info)) == ge::SUCCESS) failed
[ERROR] GE(69072,python3):2025-03-18-14:35:48.619.628 [model_utils.cc:1286]69072 InitRuntimeParams: ErrorNo: 4294967295(failed) [LOAD][DEFAULT]Assert (total_hbm_size == (static_cast<int64_t>(runtime_param.mem_size) - runtime_param.zero_copy_size)) failed, expect 469474304 actual 0
[ERROR] GE(69072,python3):2025-03-18-14:35:48.619.645 [davinci_model.cc:481]69072 InitRuntimeParams: ErrorNo: 4294967295(failed) [LOAD][DEFAULT]Assert ((ModelUtils::InitRuntimeParams(ge_model_, runtime_param_, device_id_)) == ge::SUCCESS) failed
[ERROR] GE(69072,python3):2025-03-18-14:35:48.619.661 [davinci_model.cc:686]69072 Init: ErrorNo: 4294967295(failed) [LOAD][DEFAULT]Assert ((InitRuntimeParams()) == ge::SUCCESS) failed
[ERROR] GE(69072,python3):2025-03-18-14:35:48.619.670 [model_manager.cc:1210]69072 LoadModelOffline: ErrorNo: 4294967295(failed) [LOAD][DEFAULT][Init][DavinciModel] failed, ret:1343225857.
[ERROR] GE(69072,python3):2025-03-18-14:35:48.620.302 [graph_loader.cc:143]69072 LoadModelFromData: ErrorNo: 1343225857(Parameter's invalid!) [LOAD][DEFAULT][Load][Model] failed, model_id:1.
[ERROR] ASCENDCL(69072,python3):2025-03-18-14:35:48.620.316 [model.cpp:280]69072 ModelLoadFromFileWithMem: [LOAD][DEFAULT][Model][FromData]load model from data failed, ge result[1343225857]
[ERROR] ASCENDCL(69072,python3):2025-03-18-14:35:48.620.518 [model.cpp:1637]69072 aclmdlLoadFromFile: [LOAD][DEFAULT]Load model from file failed!
[ERROR] GE(69072,python3):2025-03-18-14:35:48.620.624 [model_manager.cc:954]69072 GetInputOutputDescInfo: ErrorNo: 145003(Model id invalid.) [GET][DEFAULT][Get][Model] Failed, Invalid model id 0!
[ERROR] GE(69072,python3):2025-03-18-14:35:48.620.634 [graph_executor.cc:409]69072 GetInputOutputDescInfo: ErrorNo: 145003(Model id invalid.) [GET][DEFAULT][Get][InputOutputDescInfo] failed, model_id:0.
[ERROR] GE(69072,python3):2025-03-18-14:35:48.620.650 [ge_executor.cc:744]69072 GetModelDescInfo: ErrorNo: 145003(Model id invalid.) [GET][DEFAULT][Get][InputOutputDescInfo] failed. ret = 145003, model id:0
[ERROR] ASCENDCL(69072,python3):2025-03-18-14:35:48.620.658 [model.cpp:1386]69072 aclmdlGetDesc: [GET][DEFAULT][Get][ModelDescInfo]get model description failed, ge result[545008], model id[0]
```