---
layout: default
title: Notes_In_Daily_Coding_Life
categories:
tags:
---
//Description: Just some notes in daily coding life

//Create Date: 2019-04-24 16:59:35

//Author: channy

# set PC to auto start  
```
at 00:00 /every:M,T,W,Th,F,S,Su shutdown -s -t 120

at /delete
```

# add share folder to VirtualBox but without permission
```
sudo usermod -aG vboxsf $(username)
```

# pyinstall error str object has no attribute items

As other python error, the version of libraries do not match.

Update setuptools to version 40+, solved

用pyinstaller把脚本转化成exe时报错，升级setuptools到40+版本后解决~

# Qt change version and update

If change version in qt .pro file, and use DEFINES to define this version value, or other value but not only version, please remember to `rebuild` it to make it valiable, otherwise it will still be the old value.

在Qt下修改.pro文件的版本号，并且该版本号是用DEFINES定义成变量用在程序中的，或者其它非版本号的变量，保证重新编译使其生效，否则该变量仍旧是原来的值。

[back](./)
