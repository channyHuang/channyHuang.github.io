---
layout: default
title: Finger Recog
categories:
- Security
tags:
- Security
---
//Description: 指纹识别

//Create Date: 2021-02-01 00:09:20

//Author: channy

# 指纹识别

## 指纹特性：

1，指纹的几何特性：指在空间上嵴是突起的，峪是凹下的。嵴与嵴相交、相连、分开会表现为一些几何图案。

2，指纹的生物特性：指嵴和峪的导电性不同，与空气之间形成的介电常数不同、温度不同等。

3，指纹的物理特性：指嵴和峪着力在水平面上时，对接触面形成的压力不同、对波的阻抗不同等。


## 指纹采集

光学传感。利用光的折摄和反射原理，将手指放在光学镜片上，手指在内置光源照射下，光从底部射向三棱镜，并经棱镜射出，射出的光线在手指表面指纹凹凸不平的线纹上折射的角度及反射回去的光线明暗就会不一样。

电容传感。将电容感整合于一块芯片中，当指纹按压芯片表面时，内部电容感测器会根据指纹波峰与波谷而产生的电荷差，从而形成指纹影像。

射频/超声波传感。

力学/热学传感。

## 指纹识别

在指纹图象上找到并比对指纹的特征。类似于人脸识别。

特征点检测。

## 指纹设备



## winapi

### Windows Biometric Framework

WBF支持windows 7

WinBioOpenSession 打开设备

WinBioEnrollBegin 开始录入指纹

WinBioVerify 验证指纹

[WBF](https://docs.microsoft.com/en-us/windows/win32/secbiomet/biometric-service-api-portal)