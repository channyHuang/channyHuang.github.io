---
layout: default
title: Yolo Learning Notes
categories:
- Algorithm
tags:
- Computer Vision
---
//Description: Yolo目标检测网络学习笔记。记录在学习Yolo过程中遇到的问题。Yolo网络分为三部分：主干网络、颈部网络和检测头。主干网络VGG->ResNet->DarkNet->MobileNet->ShuffleNet用于提取出图像中的特征信息。颈部网络SPP->SDD->FPN。检测头MLP->CNN->DETR。

//Create Date: 2024-04-03 09:38:39

//Author: channy

[toc]

# Basic
## 主干网络
用于提取出图像中的特征信息
* VGG (Fast R-CNN、SSD)
* ResNet
* DarkNet
* MobileNet
* ShuffleNet
## 颈部网络
* FPN 特征金字塔网络
* SPP 空间金字塔池化模块

# Yolo
## Yolov1: googlenet + SPP + MLP
把图像分割成SxS的网格进行检测
* IoU
* MLP参数多
## Yolov2: DarkNet-19 + SDD + CNN
* 先验框机制
* 多尺度训练
## Yolov3: DarkNet-53 + FPN
* 多级检测和特征金字塔
## Yolov4: CSPDarkNet-53 + PaFPN 
* Mosaic augmentation 马赛克增强
## YOLOX: + SimOTA
## ELAN
## YoloF
## FCOS

# Others
## Yolov8: CSPDarkNet + SPPF