---
layout: default
title: Programming_AI_Terrain.md
categories:
- Game
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

## 功能拆分
1. 根据输入的几何体名称，自动生成基于voxel的sdf数据和网格
