---
layout: default
---

[English_Version_Please_Click_Here](./index)

# 目录

**计算机视觉**

[项目－三维重建系统](./Project_3D_Reconstruction.html)

[OpenCV特征点检测](./Feature_Detection_In_OpenCV.html)

[OpenCV特征点匹配](./Feature_Matching_In_OpenCV.html)

[计算机参数和点云计算](./Compute_Camera_Params_and_Point_Cloud.html)

[Kalman滤波](./Kalman_Filter)

[项目－重光照](./Project_Relighting.html)

**C++**

[未解决问题之内存使用量](./Unsolved_Question_Memory_Usage)

[进程监控（获取指定进程的信息）](./Process_Monitor)

[在Linux下跑Qt应用程序](./Qt_In_Linux)

[代码错误总结](./Summary_Of_Coding_Errors)

[Matlab和C相互调用](./Matlab_And_C_Combining_Coding)

[头文件相互包含](./Head_File_Include_Each_Other)

[工作中的笔记和bug](./Notes_And_Bugs_In_Work)

**Linux**

[用Shell自动生成博客文章的固定部分](./Generate_Head_Using_Shell.html)

[Linux基本命令](./Linux_Basic_Comment)

[Linux网络编程笔记](./Linux_Network_Programming_Notes)

**Android**

[Android编译源码](./Android_Build_Source)

[Android逆向](./Android_Crack.html)

[Android反编译](./Android_Rebuid_Notes)

**Daily convenience command**
[日常用到的命令笔记](./Notes_In_Daily_Coding_Life)

**Other subjects**

[面试中遇到过的问题总结](./Questions_In_Interview.html)

[基础代码模板](./Model_Code_Of_InputOutput)

[用Python做自己喜欢的事情](./Python_To_Do_Something_I_Like)

[Matlab的Gui参数传递](./Matlab_Gui_Params)

[其它](./Trifles.html)

## 我想说

```c++
// feel free
for (int i = 0; i <= forever; i++) {
	std::cout << "missing you, my code" << std::endl;
}
```
### 关于我

#### 编程水平

| 语言          | 水平             |
|:-------------|:------------------|
| c++          | 熟悉           |
| Android      | 熟悉           |
| Python       | 一般          |

#### 自我介绍

1. 喜欢编程，熟悉 C/C++、Matlab及android的framework层中的audio和UI模块，会编写android应用小程序，会用 Python，shell实现简单的功能

2. 数学基础扎实，本科数学系，学过数值计算等课程；

3. 对计算机视觉领域特别是三维重建方向有深入的研究

4. 自学能力强，业余时间学习二外一年能够正常交流

5. 目前正在学习机器学习的相关内容，在kaggle上参加过入门级的比赛

#### 外语水平

| 语言          | 水平                       |
|:-------------|:---------------------------|
| 英语          | TOEFL(87), GRE(140+170+2.5)|
| 韩语          | TOPIK(4级)                 |
| 法语          | A2                         |

### 项目经历

1. 三维重建系统 （2015.03 ~ 2017.03）
 	
	给定手机拍摄的同一静止场景不同视角下的视频或图像序列，主要以人体部位如头、手等作为场景研究对象，目标为重建出场景，精度误差小于5mm 
	
	a) 结合IMU数据和多视角重建理论，当用经典的视觉方法计算图像帧对应的摄像机参数失败时，增加IMU的陀螺仪、加速计、磁通数据建立因子图确定目标函数，融合两种方法求出摄像机外参，并恢复场景的三维点云模型
	
	b) 根据摄像机参数生成模型点云后，对点云进行表面重建后根据已有模型数据库对点 云模型进一步修复和变形
	
	c) 根据场景物体的骨架进一步引导模型形变，骨架由点云或模型数据库中的网格模型生成
	
	负责部分：前期主要负责从三维点云到网格模型重建和修复部分，后期增加 IMU 和视觉的融合部分

2. 三维重建后的重光照渲染研究 （2014.07 ~ 2015.06）
	
	a)   实现一个重光照系统，对于给定的物体模型（点云或网格模型），通过调节光照参 数对该物体进行重光照，并嵌入到新的图像背景中；
	
	b)   对于给定的物体模型，根据给定的目标背景图像，自动计算光源方向和其它光照参数，对物体进行重光照；
	
	c)   结合三维重建中求得的摄像机参数，对不同视角下的物体进行重光照，嵌入到视频 的图像帧中生成新的视频；
	
	d)   研究中遇到过的问题：重光照结果精确度不高，还有待改进 
	负责部分：重光照功能全部自己完成

3. 服务器日志数据挖掘和可视化研究 （2013.03 ~ 2014.06）

	a)   对日志数据进行统计和分析，发现其中有用的规则，并进行可视化显示；
	
	b)   根据访问数据捕捉新出现的手机终端，预测新手机产品的出现；
	
	c)   研究中遇到过的问题：日志数据量大，计算时间长，有待改进； 
	
	负责部分：全部自己完成

### 相关专利

申请号：201510771082.4 申请日：2015-11-12

基于图像和模型计算光照参数进行重光照渲染的方法.

申请号：201710173548.X 申请日：2017-03-22 

一种通过智能手机采集脚型视频和传感器数据获取三维脚型的方法 

#### 个人信息
<dl>
<dt>名字</dt>
<dd>Channy</dd>
<dt>邮箱</dt>
<dd>349117102@qq.com</dd>
</dl>
---

[返回](./)
