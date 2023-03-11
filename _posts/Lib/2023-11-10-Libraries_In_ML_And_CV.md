---
layout: default
title: Libraries In Machine Learning And Computer Vision
categories:
- Lib
tags:
- Lib
---
//Description: Libraries In Machine Learning And Computer Vision

//Create Date: 2013-11-10 07:32:05

//Author: channy

[toc]

# ​机器学习库
参考资料：[mloss | All entries](http://mloss.org/software/jmlr/)

## Java库
* Approach Mahout  
java库。需要Maven编译。arules Mining Association Rules and Frequent Itemsets :
* CAM   
java库。主要用于机器学习和数据挖掘。
* CAPR  
CTBN-RLE: Continuous Time Bayesian Network Reasoning andLearning Engine

## C/C++库
* Darwin  
c++库，主攻机器学习、图像建模、计算机视觉研究。依赖库有Eigen 3.1.2以上，OpenCV 2.4.6以上。机器学习算法包括分类boost,决策树，产生高斯分布，k-means,线性回归，PCA,随机森林等。

文档页：http://drwn.anu.edu.au/index.html
* Dlib ml   
C++库。包括机器学习等，主要为SVM。

文档页：dlib C++ Library
## DLLearner Build  
* Dmtl  
数据挖掘c++库,Data miningtemplate library。

文档页：Data Mining Template Library

## 其它
* ECOC :
* FastInf :
* GMPL :
* GPstuff : Gaussian Processes.
* Java-ML :
* JNCC2 ：Naive Credal Classifier 2 java库。
* Jstacs : java库。
* libDAI :
* Liblinear : 大规模数据线性分类C++库，有matlab,java,python等扩展接口。
* Libsvm : 非线性svm分类器生成库。
* LPmade :
* LWPR :
* MLC++  
c++库。包含了C4.5、Bayes 等多种数据挖掘算法。最后一次更新在97年，太老。

文档页：http://www.sgi.com/tech/mlc/docs.html

* Mlpack  
c++库。依赖于五个库（LAPACK,BLAS,Armadillo,LibXml2,Boost）。

* MOA :
* Model Monitor :
* MSVMpack : Multi-class SVM.
* Mulan :
* Multiboost :
* Nieme :
* OpenCV-ml : 图像处理的机器学习库。包括了多种流行的算法。
* Orange  
python的数据挖掘库。主要用.tab的数据文件。

文档页：Orange Data Mining - Data Mining

* Pebl :
* PyBrain :
* RL-Glue :
* Sally :
* Scikitlearn  
基于python的机器学习库。包括6大部分，Classification,Regression, Clustering, Dimensionality reduction, Model selection,Preprocessing.涵盖了数据挖掘一半的算法。
* Shark  
机器学习C++库。依赖于Boost 库1.45或更高版本，并使用CMake。

文档页：http://shark-project.sourceforge.net/index.html
* SHOGUN  
C++库，有python,octave,Matlab接口。主要用于大规模学习方法和SVM。
* SSA Toolbox :
* SUMO :
* Torch 7 :只找到Linux安装。

文档页：Torch | Scientific computing for LuaJIT.
*  Waffles : 机器学习的c++库。非监督学习算法多样，包括降维算法，实现了PCA等，也有聚类算法k-means,k-medoids等。数据集主要格式为.arff,可从MLData.org上下载，提供数据格式转换。共有九个应用：
    * Waffles_audio 音频处理
    * Waffles_cluster 各种聚类算法
    * Waffles_dimred 降维
    * Waffles_generate 产生样本或其它类型的数据
    * Waffles_learn 监督学习算法
    * Waflles_plot 数据可视化
    * Waflles_recommend PCA,协同过滤？
    * Waflles_sparse 稀疏数据的学习
    * Waffles_transform 数据变换
    * Waffles_wizard 图形化界面。只是用来产生命令行，可作用户手册。

所有的这些功能都被包含在c++类库GClasses中，使用起来非常方便，只需using namespace GClasses

文档页：  http://waffles.sourceforge.net/docs.html

* Weka :数据挖掘java库。涵盖了数据挖掘十大经典算法中的90%。有图形界面和命令行输入两种。使用数据主要为.arff格式。
* Boost：c++准标准库。其中包括：

1) Regex：正则表达式库

2) Graph：图组件和算法

3) Mpl：用模板实现的元编程框架

4) Thread：可移植的c++多线程库

5) Python：把c++类和函数映射到Python中

# Computer Vision

http://www.cvchina.info/tag/ptam/

http://cs2.swfc.edu.cn/~zyl/?p=860

* OpenCV: (c++)
* RAVL(http://www.ee.surrey.ac.uk/CVSSP/Ravl/)
* Cimg: 图像处理开源库。整个库只有一个头文件。包含一个基于PDE的光流算法。

图像、视频IO类。C++ Template Image Processing Toolkit by David Tschumperlé

* FreeImage
* DevIL:
* [ImageMagick](http://www.imagemagick.org/script/index.php)
* [FFMPEG](http://www.ffmpeg.org/)
* [VideoInput](http://www.muonics.net/school/spring05/videoInput/)
* portVideo:
* [BoostGIL](http://www.boost.org/)  
Boost Generic Image Libraryby Hailin Jin and Lubomir Bourdev at Adobe Systems
* [ITK](http://www.itk.org/)   
Segmentation & Registration Toolkit
* [VTK](http://www.vtk.org/)  
The Visualization Toolkit
* [ImageJ](http://rsbweb.nih.gov/ij/)/[Fiji](http://fiji.sc/wiki/index.php/Fiji)
* openip
* [Image ProcessingLibrary (IPL)](https://github.com/Argoday/IPL)
* [MeVisLab](http://www.mevislab.de/home/about-mevislab/)   
Medical Imagemage Processing and Visualization (forMac OS X)

## AR类/AugmentedReality
* [ARToolKit](http://www.hitl.washington.edu/artoolkit/)
* [ARToolKitPlus](http://handheldar.icg.tugraz.at/artoolkitplus.php)
* [PTAM](http://www.robots.ox.ac.uk/~gk/PTAM/)  
实时跟踪。依赖库较多，不好编译

* [BazAR](http://cvlab.epfl.ch/software/bazar/index.php)  
基于特征点检测和识别的AR库

## 局部不变特征
* [VLFeat](http://www.vlfeat.org/)  
(C,Matlab)目前最好的Sift开源实现。同时包含了KD-tree，KD-Forest，BoW实现。
* [Ferns](http://cvlab.epfl.ch/software/ferns/index.php)  
基于Naive Bayesian Bundle的特征点识别。高速，但占用内存高
* [SIFT By Rob Hess](http://blogs.oregonstate.edu/hess/code/sift/)  
基于OpenCV的Sift实现

## 目标检测
* [AdaBoostBy JianXin.Wu](http://c2inet.sce.ntu.edu.sg/Jianxin/RareEvent/rare_event.htm)
* [行人检测 By JianXin.Wu](http://c2inet.sce.ntu.edu.sg/Jianxin/projects/Pedestrian/Pedestrian.html)

## 最近邻/ANN
* [FLANN](http://www.cs.ubc.ca/~mariusm/index.php/FLANN/FLANN)  
目前最完整的（近似）最近邻开源库。不但实现了一系列查找算法，还包含了一种自动选取最快算法的机制
* [ANN](http://www.cs.umd.edu/~mount/ANN/)

## SLAM & SFM
* [SceneLib](http://www.doc.ic.ac.uk/~ajd/Scene/)
* [SLICSuper Pixel](http://ivrg.epfl.ch/supplementary_material/RK_SLICSuperpixels/index.html)

## 目标跟踪
* [TLD](http://info.ee.surrey.ac.uk/Personal/Z.Kalal/tld.html)
* [KLT](http://www.ces.clemson.edu/~stb/klt/)
* [Online boosting trackers](http://www.vision.ee.ethz.ch/boostingTrackers/)

## 直线检测
* [DSCC](http://www.umiacs.umd.edu/~zhengyf/LineDetect.htm)   
基于联通域连接的直线检测算法
* [LSD](http://www.ipol.im/pub/algo/gjmr_line_segment_detector/)  
基于梯度的，局部直线段检测算子

## 指纹
* [pHash](http://phash.org/)

## 图像检索
* [libpmk](http://people.csail.mit.edu/jjl/libpmk/)
* vocsearch

## 视觉显著性
* [Global Contrast BasedSalient Region Detection](http://cg.cs.tsinghua.edu.cn/people/~cmm/saliency/)

## FFT/DWT
* [FFTW](http://www.fftw.org/)  
最快，最好的开源FFT
* [FFTReal](http://ldesoras.free.fr/prod.html#src_fftreal)

## 音频处理
* [STK](https://ccrma.stanford.edu/software/stk/)
* [Libsndfile](http://www.mega-nerd.com/libsndfile/)
* [libsamplerate](http://www.mega-nerd.com/libsndfile/)

## 数据压缩
* QccPack -Quantization, Compression, and Coding Library
* [libCVD](http://www.edwardrosten.com/cvd/)  
computer vision library
* VXL - C++Libraries for Computer Vision
* [VIGRA](http://hci.iwr.uni-heidelberg.de/vigra/)  
GenericProgramming for Computer Vision (C++)
* [MRPT](http://www.mrpt.org/)  
TheMobile Robot Programming Toolkit (C++)
* [STAIRVision Library](http://ai.stanford.edu/~sgould/svl/) (C++)
* [NASAVision Workbench](https://github.com/visionworkbench/visionworkbench)
* [CCV](http://libccv.org/)
* QVision
* [BLEPO](http://www.ces.clemson.edu/~stb/blepo/)
* [AForge.NET](http://www.aforgenet.com/framework/) (C#)
* [Accord.NET](http://code.google.com/p/accord/) (C#)

## Matlab工具箱
* [Peter's Functions for Computer Vision](http://www.csse.uwa.edu.au/~pk/research/matlabfns/) (Matlab)
* [Piotr's Image & Video Matlab Toolbox](http://vision.ucsd.edu/~pdollar/toolbox/doc/index.html)
* [Peter Corke's Machine Vision Toolbox](http://www.petercorke.com/Toolbox_software.html)
* [MATLAB Functions for Multiple ViewGeometry](http://www.robots.ox.ac.uk/~vgg/hzbook/code/)
* [BaluToolbox Matlab](http://dmery.ing.puc.cl/index.php/balu/)
* [Machine Learning Toolbox by Kevin Murphy](http://www.cs.ubc.ca/~murphyk/Software/index.html)
* [Graph Boosting Toolboxfor Matlab](http://www.nowozin.net/sebastian/gboost/)
* [MATLABToolbox for the LabelMe Image Database](http://labelme.csail.mit.edu/LabelMeToolbox/index.html)

## 相机标定
* [Camera Calibration Toolbox for Matlab](http://www.vision.caltech.edu/bouguetj/calib_doc/)
* [OCamCalib:Omnidirectional Camera Calibration Toolbox for Matlab](https://sites.google.com/site/scarabotix/ocamcalib-toolbox)
* [GML C++ Camera Calibration Toolbox](http://graphics.cs.msu.ru/en/node/909)

## 模型拟合和鲁棒估计
* [RANSAC Toolbox for Matlab](http://vision.ece.ucsb.edu/~zuliani/Research/RANSAC/RANSAC.shtml)
* [RANSAC Matlab implementation](http://www.csse.uwa.edu.au/~pk/research/matlabfns/#robust)
* [MRPTRANSAC C++ examples](http://www.mrpt.org/RANSAC_C%20%20_examples)
* [RANSAC C++ template framework](http://isiswiki.georgetown.edu/zivy/)
* [PCL's RANSAC tutorial](http://pointclouds.org/documentation/tutorials/random_sample_consensus.php)
* [RANdom Sample Consensus (RANSAC) in C#](http://crsouza.blogspot.com/2010/06/random-sample-consensus-ransac-in-c.html)
* [GroupSAC](http://www.kaini.org/Research/GroupSAC/GroupSAC.html)

## 特征检测与匹配
* [SIFT](http://www.cs.ubc.ca/~lowe/keypoints/)  
Scale-invariant feature transform
* [SURF](http://www.vision.ee.ethz.ch/~surf/index.html)  
Speeded Up Robust Features
* [BRIEF](http://cvlab.epfl.ch/software/brief/)  
Binary Robust Independent Elementary Features
* [DAISY](http://cvlab.epfl.ch/research/surface/daisy/#code)  
An Efficient Dense Descriptor Applied for Wide Baseline Stereo
* [ORB](http://cs2.swfc.edu.cn/~zyl/www.willowgarage.com/sites/default/files/orb_final.pdf)  
An efficient alternative to SIFT or SURF

## 非线性最小二乘法（non-linearleast squares）
* [Ceres Solver](http://code.google.com/p/ceres-solver/)  
Google街景技术中使用的非线性最小二乘法解决库

## Bundle adjustment
* [Wikipediaabout Bundle adjustment](http://en.wikipedia.org/wiki/Bundle_adjustment)
* [sba](http://www.ics.forth.gr/~lourakis/sba/)  
A Generic Sparse Bundle Adjustment C/C++ Package Based on theLevenberg-Marquardt Algorithm
* [ceres-solver](http://code.google.com/p/ceres-solver/)   
ANonlinear Least Squares Minimizer by SameerAgarwal

2 [Matlab Toolbox](http://stommel.tamu.edu/~baum/toolboxes.html)

[back](./)

