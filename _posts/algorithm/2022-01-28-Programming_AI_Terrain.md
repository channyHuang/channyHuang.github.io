---
layout: default
title: Programming_AI_Terrain.md
categories:
- Algorithm
tags:
- Game
---
//Description: Programming_AI_Terrain (自动生成地貌)

//Create Date: 2022-01-28 15:28:39

//Author: channy

# 概述 
目标：根据输入的描述性文字，自动生成游戏中的地形地貌

思路：机器学习GAN模型

参考样例：基于GAN的描述文本生成图像

## 背景
文本生成图像：VAE(Variational Auto-Encoder)，DRAW（Deep Recurrent Attention Writer）以及GAN(GAN-INT-CLS)等

启发：[pixray](https://github.com/pixray/pixray) [pixray-demo](https://replicate.com/pixray/text2image)

## 功能拆分
1. 根据输入的几何体名称，自动生成基于voxel的sdf数据和网格s

## 数据准备
### 参考GAN模型
> DF-GAN 根据描述文字生成对应图像  
### 参考数据
[ModelNet](https://cvgl.stanford.edu/data2/) 训练网络的时候用的是voxel grids格式的数据，shapeNet提供了32×32×32的grid数据以及grid数据相应渲染的结果，里面grid数据是用.binvox格式存储的[binvox](https://www.patrickmin.com/binvox/) ，python的读取示例（dimatura/binvox-rw-py），如果想要将mesh数据体素化，可以用 mesh-voxelization工具(FairyPig/mesh-voxelization)。
[ShapeNet](https://shapenet.org/)
### 我们的数据准备
* voxel使用进制存储文件，其中前3个byte存储该voxel的size(x, y, z)，后续x*y*z个byte存储对应位置上的sdf[0,254]  
* 文字描述直接使用几何体名称
* 参考DF-GAN的数据输入格式生成filenames.pickle和captions.pickle
* 使用[StackGAN-inception-model](https://github.com/hanzhanggit/StackGAN-inception-model)生成DAMSM，用于在训练过程中计算DAMSM loss
* **batch_size**每次迭代训练取batch_size个样本。数据量小时取1

* 使用**inception_v3**先训练描述文字模型

# 源码
正在修复bug。。。

# reference
## 近年text-to-image论文及代码
* python 2.7 + pytorch
> 2017 [StackGAN++](https://github.com/hanzhanggit/StackGAN-v2) [StackGAN-inception-model](https://github.com/hanzhanggit/StackGAN-inception-model)
> [Recipe2ImageGAN](https://github.com/netanelyo/Recipe2ImageGAN)
* python 2.7 + tensorflow 0.12
> 2017 [StackGAN](https://github.com/hanzhanggit/StackGAN)  
* pytorch
> 2019 [MirrorGAN](https://github.com/qiaott/MirrorGAN)
* python 2.7 + pytorch + tensorflow
> 2019 [DM-GAN](https://github.com/MinfengZhu/DM-GAN)
* python 2.7
> 2016 [text2image](https://github.com/mansimov/text2image)
* python 3 + tensorflow 1.0
> 2016 [text-to-image](https://github.com/zsdonghao/text-to-image)
* pytorch + CuDNN
> 2016 [Learning What and Where to Draw](https://github.com/reedscot/nips2016)
* python + Caffe
> 2017 [Plug and Play Generative Networks](https://github.com/Evolving-AI-Lab/ppgn)
* python 3+ + pytorch 1.0+
> 2018 [AttnGAN](https://github.com/davidstap/AttnGAN) 
> 2020 [DF-GAN](https://github.com/tobran/DF-GAN)
> 2019 [ControlGAN](https://github.com/mrlibw/ControlGAN)  
> 2020 [ManiGAN](https://github.com/mrlibw/ManiGAN) 基于ControlGAN的改进

## 三维上的GAN
* python 2.7
> 2016 [voxel-dcgan](https://github.com/maxorange/voxel-dcgan)
* python 2.7 + tensorflow >= 1.0
> 2016 [3D GAN](https://www.meetshah.dev/gan/deep-learning/tensorflow/visdom/2017/04/01/3d-generative-adverserial-networks-for-volume-classification-and-generation.html) [github-tf-3dgan](https://github.com/meetps/tf-3dgan)
* python 2.7 + tensorflow 1.1
> 2017 [3D-RecGAN](https://github.com/Yang7879/3D-RecGAN)
* python 2/3 + pytorch
> 2018 [Z-GAN](https://github.com/vlkniaz/Z_GAN)

## 地形有关的GAN
[PoE-GAN](https://deepimagination.cc/PoE-GAN/)

# 附录一：binvox文件基本结构
binvox文件由ASCII的文件头和二进制的数据组成
```binvox头
#binvox 1
dim 32 32 32
translate -0.302239 -0.169754 -0.360326
scale 0.720652
data
```
其中，"#binvox 1"指定版本号，"dim"指定体素网格的size，"translate"和"scale"用于正则化对应的变换，"data"标志文件头结束，往下都是数据。
二进制数据中包含多对数据，每对数据(pair)的首个byte是当前pair的具体数值0或1（1表示该voxel被填充），第二个byte是当前数值被重复多少次[1,255]。  
即：binvox是把原voxel的数据生成一个一维的数组，并将重复的点压缩后得到的结果

[**binvox-rw-py**](https://github.com/dimatura/binvox-rw-py)

# 附录二：mesh-to-sdf
[mesh-voxelization](https://github.com/FairyPig/mesh-voxelization)

# 附录三：工具类
[pytorch-DCGAN](https://pytorch.apachecn.org/#/docs/1.7/22)
[python-library-binary](https://www.lfd.uci.edu/~gohlke/pythonlibs/)
[keras](https://keras.io/examples/)
* 中文python分词工具
> [jieba](https://github.com/fxsjy/jieba)
> [pkuseg](https://github.com/lancopku/pkuseg-python)
> [FoolNLTK](https://github.com/rockyzhengwu/FoolNLTK)
> [THULAC](https://github.com/thunlp/THULAC-Python)