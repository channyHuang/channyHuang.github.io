---
layout: default
title: 在cygwin下编译和运行Bundler
categories:
tags:
---
//Description: 在cygwin下编译和运行Bundler

# 1-0 编译Bundler (在cygwin下)
(1) 在编译之前请大家在/src打开Bundle2PMVS.cpp将217行的


fprintf(f_scr, "mv  pmvs/%s.rd.jpg %s/visualize/%08d.jpg\n", 修改为 fprintf(f_scr, "mv  %s.jpg %s/visualize/%08d.jpg\n"。原因后面第(6)步大家会知道。




$ cd 到bundler的目录下
$ make
(在编译到BundlerApp.h文件第620行, 出现错误: 不能直接调用构造函数'SkeletalApp::BundlerApp')该头文件在/bundler/src目录中, 注释掉该行, 继续make, 可以通过编译此次make共生成bundler.exe, Bundle2PMVS,exe, BundleVis.exe, KeyMatchFull.exe, RadialUndistort.exe,  libANN_char.dll, 都放置在/bundler/bin目录下。


(2) 下载SIFT获取siftWin32.exe




# 1-1 运行Bundler (在cygwin下)
(1) cd 到bundler目录
(2) mkdir result 
存放输出结果
(3) cd result
(4) ../Runbundler.sh ../examples/kermit
(注: ../examples/kermit指明用于进行多视角重建的图像所在目录)此时已经运行完Bundler, 在./bundle/bundle.out文件里有重建的稀疏点3D坐标和相机参数, 具体说明参见/bundler/readme.txt。这样/bundler会生成两个文件夹/bundle和/prepare。
(5) ../bin/Bundle2PMVS.exe prepare/list.txt bundle/bundle.out
此时生成了pmvs子目录, 编辑里边的prep_pmvs.sh（用到工具EditPlus 3,网上可以搜到）, 指明BUNDLE_BIN_PATH路径来寻找RadialUndistort.exe和Bundle2Vis.exe。注意我们用的是Cygwin所以改BUNDLE_BIN_PATH要注意目录的格式，比如我的Bundler在E盘根目录，那么BUNDLER_BIN_PATH=/cygdrive/e/bundler/bin（地址不能有空格）
(6) ./pmvs/prep_pmvs.sh
在pmvs目下生成txt, visualize, models目录和bundle.rd.out, list.rd.txt, vis.dat, pmvs_options.txt文件, 这些都是PMVS2的输入。


# 1-2 CMVS-PMVS


将CMVS-PMVS-master\binariesWin-Linux\Win64-VS2010文件夹中的文件全部拷贝到之前的result文件夹目录下


打开cmd
1.进入bundler目录


2.进入bundler/result文件夹下（cd E:\bundler\result）


3.输入cmvs pmvs/


4.输入genOption pmvs/


5.pmvs2 pmvs/ option-0000


这样，我们发现/pmvs/models/文件夹多了几个文件，其中*.ply文件为3D模型文件用下面的软件可以查看。


     vi   deploy.sh          
     :set fileformat=unix 
     :wq



[back](./)
