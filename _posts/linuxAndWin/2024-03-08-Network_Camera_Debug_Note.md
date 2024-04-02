---
layout: default
title: Orin下使用Python调试网络摄像头笔记
categories:
- Linux
tags:
- Server
- Linux
---
//Description: 记录在Orin下使用Python调试网络摄像头获取rtsp流数据遇到的断网、延迟、获取不到数据等问题，最终发现网络是由于系统网络不稳定、延迟改用GStreamer获取数据、获取不到数据是由于安装的OpenCV不支持GStreamer需要重新源码编译并打开GStreamer支持。写于2024年3月初。

//Create Date: 2024-03-08 13:14:28

//Author: channy

# Orin下使用Python调试网络摄像头笔记
为防止信息泄露，以下使用到的网络摄像头的ip地址均用`192.168.1.88`代替，摄像头的rtsp访问地址用`rtsp://192.168.1.88:554/user=admin&password=admin&xxx`表示
## 问题1：直接使用Python+OpenCV读取摄像头有明显延迟
Q: get camera stream and play has large delay   

### A: 尝试直接使用ffmpeg播放视频流检查流畅程度   
try to play video stream using ffmpeg
```
ffplay rtsp://192.168.1.88:554/user=admin&password=admin&xxx

Q: ffplay Server returned 401 Unauthorized
A: adding user name and password before ip
```
出现401未认证错误，解决方案为在ip地址前增加用户名和密码，用冒号隔开，用@连接ip

### A: 使用ffmpeg保存获取到的视频帧，能够正常保存
```
ffmpeg -i "rtsp://admin:admin@192.168.1.88:554/user=admin&password=admin&xxx" -y -f image2 -r 1/1 img%03d.jpg

A: normal
```

### A: 尝试ffmpeg增加参数调整缓存，依旧有明显延迟
```
ffplay -i rtsp://192.168.1.88:554/user=admin&password=admin&xxx -fflags nobuffer -analyzeduration 1000000

Q: failed: No route to host 
A: network unstable, restart network service

sudo service network-manager restart
```
最终发现设置中的网络会自动断开，确认是系统网络问题，重启系统网络服务`sudo service network-manager restart`之后网络正常

## 问题2：使用Python+OpenCV获取rtsp视频流失败
using python+opencv to capture rtsp stream
### A: 直接使用GStreamer获取样例rtsp播放视频能够正常播放
using gstreamer to play video
```
gst-launch-1.0 playbin uri=https://www.freedesktop.org/software/gstreamer-sdk/data/media/sintel_trailer-480p.webm

A: normal
```
### A: 使用GStreamer获取网络摄像头的rtsp数据
using gstreamer to get camera stream
```
gst-launch-1.0 rtspsrc location=rtsp://192.168.1.88:554/user=admin&password=admin&xxx ! rtph264depay ! h264parse ! nvv4l2decoder ! nvvidconv ! autovideosink

A: normal

gst-launch-1.0 rtspsrc location=location=rtsp://192.168.1.88:554/user=admin&password=admin&xxx latency = 2000 ! rtph264depay ! h264parse ! nvv4l2decoder ! nvvidconv ! 'video/x-raw,width=960,height=540,format=I420' ! videoconvert ! autovideosink

A: normal

gst-launch-1.0 rtspsrc location=location=rtsp://192.168.1.88:554/user=admin&password=admin&xxx latency = 2000 ! rtph264depay ! h264parse ! nvv4l2decoder ! nvvidconv ! 'video/x-raw,width=960,height=540,format=BGRx' ! videoconvert ! 'video/x-raw,format=I420' ! autovideosink

A: normal, but opencv NOT support BGRx or I420
```
能够正常获取数据并直接播放

其中！分隔中的每一个都是gstreamer的参数，整个gstreamer是一个串起来的Pipe，类似于构件串联，如果前一项输出和后一项输入的数据格式对不上的话就会报错。

## 问题3：获取到的流无法接入到OpenCV中
即cap.isOpened返回False

### A: 查看opencv的编译信息
```
import cv2
print(cv2.getBuildInformation())

// not support gstreamer ?
GStreamer:                   NO
```
发现当前安装的opencv并不支持GStreamer
### A: 开启GStreamer并从源码编译opencv
build and install opencv with gstreamer from source

以4.1.1为例，大致步骤如下。
```
1.基础包安装
# apt-get install gstreamer1.0 libgstreamer-plugins-base1.0-dev libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-doc gstreamer1.0-tools libgtk2.0-dev libqt4-dev
2. 下载opencv4.1.1
# wget https://github.com/opencv/opencv/archive/4.1.1.zip
3. 解压缩
# unzip 4.1.1.zip
4. 编译安装
# cd opencv-4.1.1/
# mkdir build
# cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D INSTALL_PYTHON_EXAMPLES=ON -D INSTALL_C_EXAMPLES=OFF -D BUILD_EXAMPLES=ON -D BUILD_opencv_legacy=OFF -DWITH_IPP=OFF -DBUILD_opencv_python2=ON -DBUILD_opencv_python3=ON -DWITH_FFMPEG=ON -DWITH_GSTREAMER=ON -D WITH_QT=ON -DWITH_GTK=ON ..
# make -j$(nproc)
# sudo make install

# sudo sh -c 'echo "/usr/local/lib" >> /etc/ld.so.conf.d/opencv.conf'
# sudo ldconfig
```

### A: 尝试使用OpenCV+GStreamer播放本地视频
```python
// check play local video 
cap = cv2.VideoCapture('gst-launch-1.0 filesrc location=dog.mp4 ! qtdemux ! queue ! h264parse ! nvv4l2decoder ! nvvidconv ! appsink', cv2.CAP_GSTREAMER)

A: normal
```

## 最终成功使用OpenCV+GStreamer获取网络摄像头的视频流
```python
gst_str = 'rtspsrc location=location=rtsp://192.168.1.88:554/user=admin&password=admin&xxx latency = 2000 ! rtph264depay ! h264parse ! nvv4l2decoder ! nvvidconv ! \'video/x-raw,width=960,height=540,format=BGRx\' ! videoconvert ! \'video/x-raw,format=BGR\' ! appsink'
cap = cv2.VideoCapture(gst_str, cv2.CAP_GSTREAMER)
while cap.isOpened():
    ret, frame = cap.read()
    if ret:
        cv2.imshow('source', frame)
        cv2.waitKey(1)
```

# 报GStreamer没有"nvv4l2decoder"和"nvvidconv"插件错误
意外有了一台Ubuntu 20.04 x86_64的机器，在机器上按上述步骤跑，发现在使用GStreamer获取网络摄像头的rtsp流时，
```sh
gst-launch-1.0 rtspsrc location=rtsp://192.168.1.88:554/user=admin&password=admin&xxx ! rtph264depay ! h264parse ! nvv4l2decoder ! nvvidconv ! autovideosink
```
会报GStreamer没有"nvv4l2decoder"和"nvvidconv"插件的错误。
```
WARNING: erroneous pipeline: no element "nvv4l2decoder"
WARNING: erroneous pipeline: no element "nvvidconv"
```
排除掉多版本冲突、编译安装没编译完整等问题后，在官网的plugin中查找竟然没找到报错的这两个名称。最后发现这两个是DeepStream才有的，不是GStreamer本身的。

不确定新机器的显卡是否支持DeepStream，只好先尝试把"nvv4l2decoder"和"nvvidconv"换成`avdec_h264`，然后能够正常获取摄像机的视频流。
```
gst-launch-1.0 rtspsrc location='rtsp://192.168.1.88:554/user=admin&password=admin&xxx' ! rtph264depay ! h264parse ! avdec_h264 ! autovideosink
```