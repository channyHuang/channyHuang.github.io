---
layout: default
---

# Project Relighting

will finish it soon...

### Some libraries or algorithms used in this project

Photometric Ambient Occlusion

http://www.cs.cornell.edu/projects/photoao/

計算圖像的環境光散射（AO）

Stereo Matching with Nonparametric Smoothness Priors in Feature Space
http://pages.cs.wisc.edu/~lizhang/projects/mvstereo/cvpr2009/

把每個像素視為向量，圖像匹配轉化為匹配點云。通過最小化由連續性和光滑性組成的能量函數計算深度圖。

输入：图像（>=2张），摄像机参数，相机对（匹配对）， mindepth and maxdepth，输入图像名称，其它Optical的参数

输出：對應的深度圖

腳型數據的測試效果并不好。

Visual Hall to model

http://vision.gel.ulaval.ca/~visualhull/

输入多张图像轮廓和对应的摄像机参数，给定包围盒，把其中的体素反投影在图像上判断其是否在Model里面，从而实现三维重建。也可以输入图像，利用自动分割求轮廓。

http://www.dip.ee.uct.ac.za/~kforbes/DoubleMirror/DoubleMirror.html

两面镜子成一定角度摆放（已知摄像机参数），利用镜面成像拍摄一幅图像得到物体多个角度的视图，visual hall判断是否投影在图像上。

Photometric Stereo

源码：http://pages.cs.wisc.edu/~csverma/CS766_09/Stereo/stereo.html

数据：http://www.cs.cornell.edu/courses/cs6644/2014fa/assignments/assignment1.html

扩展：assignment2... ; project1, project2, project4...

扩展阅读：http://grail.cs.washington.edu/projects/sam/

用上述方法重建效果不理想

只有图像和光源信息的dataset：http://gl.ict.usc.edu/Data/LightStage/

输入：铬球（chrome ball）1,...,n，mask，图像1,...,n（不同光源同一场景）

目标：估计深度和法向量

假设条件：朗伯体

估计光源方向

利用chrome ball亮点估计光源的方向。


[Px,Py]为亮点坐标，[Cx,Cy]为球心，R为散射方向[0,0,1]

计算法向量

N为法向量，L光源方向。

最小二乘法解线性方程组

生成深度图

Photometric Stereo 2

http://ubee.enseeiht.fr/photometricstereo/