---
layout: default
title: Windows的cmd命令笔记
categories:
- Windows
tags:
- Windows
---
//Description: Windows的cmd命令笔记

//Create Date: 2019-07-13 17:12:08

//Author: channy 

# Windows下一些命令与笔记

## 修改默认编码

按组合快捷键“win+ R”打开运行，输入cmd，打开命令提示符

输入   chcp

显示默认编码 936，即“gbk”编码

输入   chcp 65001

表示将编码转换为“utf-8”

## set PC to auto start 自动开关机
```
at 00:00 /every:M,T,W,Th,F,S,Su shutdown -s -t 120

at /delete
```

## add share folder to VirtualBox but without permission 虚拟机共享文件夹
```
sudo usermod -aG vboxsf $(username)
```

## pyinstall error str object has no attribute items 安装python库

As other python error, the version of libraries do not match.

Update setuptools to version 40+, solved

用pyinstaller把脚本转化成exe时报错，升级setuptools到40+版本后解决~

## Qt change version and update 升级Qt

If change version in qt .pro file, and use DEFINES to define this version value, or other value but not only version, please remember to `rebuild` it to make it valiable, otherwise it will still be the old value.

在Qt下修改.pro文件的版本号，并且该版本号是用DEFINES定义成变量用在程序中的，或者其它非版本号的变量，保证重新编译使其生效，否则该变量仍旧是原来的值。

## 在运行vs2012时，出现所有项目都无法加载的情况
只需要到vs2012的安装目录，运行devenv /resetuserdata 即可，在此记录，以备后用。

# some_interesting_codes

```
document.body.contentEditable='true';
```

操作步骤：

1. 网页F12
2. 面板上选中Console，输入上面的代码，回车
3. 整个页面可以任意编辑

[back](./)

