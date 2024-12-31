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

```sh
git clone https://github.com/opencv/opencv.git
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

***
***
***
<font color=red> RK3588下Python3、OpenCV、GStreamer、MPP</font>
***
***
*** 

# 0 安装前置依赖
```sh
# gstreamer-rockchip需要
sudo apt install meson ninja-build 
sudo apt install librga-dev
sudo apt install libdrm-dev
# opencv需要
sudo apt install libeigen3-dev cmake-gui
```

# 1 GStreamer
##  1.1 安装gstreamer
```sh
sudo apt-get install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio

pkg-config --cflags --libs gstreamer-1.0
```

[gstreamer官网](https://gstreamer.freedesktop.org/documentation/installing/on-linux.html?gi-language=c)

##  1.2 检查gstreamer是否（默认）带有mpp插件
```sh
firefly@firefly:~$ gst-inspect-1.0 | grep mpp
```

不支持mpp的输出
```sh
typefindfunctions: audio/x-musepack: mpc, mpp, mp+
libav:  avdec_vp9_rkmpp: libav vp9 (rkmpp) decoder
libav:  avdec_vp8_rkmpp: libav vp8 (rkmpp) decoder
libav:  avdec_mpeg2_rkmpp: libav mpeg2 (rkmpp) decoder
libav:  avdec_mpeg1_rkmpp: libav mpeg1 (rkmpp) decoder
libav:  avdec_mpeg4_rkmpp: libav mpeg4 (rkmpp) decoder
libav:  avdec_hevc_rkmpp: libav hevc (rkmpp) decoder
libav:  avdec_h264_rkmpp: libav h264 (rkmpp) decoder
libav:  avdec_h263_rkmpp: libav h263 (rkmpp) decoder
```
直接安装的默认不支持mpp

## 1.3 安装gstreamer-rockchip
[gstreamer-rockchip](https://github.com/JeffyCN/rockchip_mirrors.git)
```sh
git clone https://github.com/JeffyCN/rockchip_mirrors.git --branch gstreamer-rockchip

cd rockchip_mirrors
meson build
cd build
meson configure --prefix=/usr
ninja build
sudo ninja install
```

## 1.4 再次检查新安装的gstreamer是否带有mpp插件
支持mpp的输出
```sh
firefly@firefly:~$ gst-inspect-1.0 --plugin | grep mpp
rockchipmpp:  mppjpegdec: Rockchip's MPP JPEG image decoder
rockchipmpp:  mppvideodec: Rockchip's MPP video decoder
rockchipmpp:  mppjpegenc: Rockchip Mpp JPEG Encoder
rockchipmpp:  mpph265enc: Rockchip Mpp H265 Encoder
rockchipmpp:  mpph264enc: Rockchip Mpp H264 Encoder
typefindfunctions: audio/x-musepack: mpc, mpp, mp+
libav:  avdec_h263_rkmpp: libav h263 (rkmpp) decoder
libav:  avdec_h264_rkmpp: libav h264 (rkmpp) decoder
libav:  avdec_hevc_rkmpp: libav hevc (rkmpp) decoder
libav:  avdec_mpeg4_rkmpp: libav mpeg4 (rkmpp) decoder
libav:  avdec_mpeg1_rkmpp: libav mpeg1 (rkmpp) decoder
libav:  avdec_mpeg2_rkmpp: libav mpeg2 (rkmpp) decoder
libav:  avdec_vp8_rkmpp: libav vp8 (rkmpp) decoder
libav:  avdec_vp9_rkmpp: libav vp9 (rkmpp) decoder
```

## 1.5 检查gstreamer是否正常使用mpp
```sh
```

# 2 FFMPEG
## 检查ffmpeg是否支持rkmpp解码器
```sh
firefly@firefly:~$ ffmpeg -decoders | grep "rkmpp"
```
支持的输出
```sh
 V..... h263_rkmpp           h263 (rkmpp) (codec h263)
 V..... h264_rkmpp           h264 (rkmpp) (codec h264)
 V..... hevc_rkmpp           hevc (rkmpp) (codec hevc)
 V..... mpeg1_rkmpp          mpeg1 (rkmpp) (codec mpeg1video)
 V..... mpeg2_rkmpp          mpeg2 (rkmpp) (codec mpeg2video)
 V..... mpeg4_rkmpp          mpeg4 (rkmpp) (codec mpeg4)
 V..... vp8_rkmpp            vp8 (rkmpp) (codec vp8)
 V..... vp9_rkmpp            vp9 (rkmpp) (codec vp9)
 ```

# 3 OpenCV
## 3.1 编译OpenCV
```sh
cd /home/firefly/rknn_installs/gstreamer_mpp/opencv-4.x
mkdir build
cd build
cmake-gui ..
```
把GStreamer及其他需要选上，点`Configure`，检查编译配置输出是否满足：
1. GUI中GTK+和VTK support至少支持一个，否则cv2.imshow会报错不能正常使用
2. Media I/O中基本图像类型都支持，当打开某一类图像失败时可检查此项
3. Video I/O中FFMPEG和GStreamer都支持，否则cv2.videoCapture不能正常使用GStreamer
4. Python3有路径，否则不会编译Python接口

```sh
--   GUI:                           GTK3
--     GTK+:                        YES (ver 3.24.23)
--       GThread :                  YES (ver 2.64.6)
--       GtkGlExt:                  NO
--     VTK support:                 NO
--
--   Media I/O: 
--     ZLib:                        /usr/lib/aarch64-linux-gnu/libz.so (ver 1.2.11)
--     JPEG:                        /usr/lib/aarch64-linux-gnu/libjpeg.so (ver 80)
--     WEBP:                        build (ver encoder: 0x020f)
--     PNG:                         /usr/lib/aarch64-linux-gnu/libpng.so (ver 1.6.37)
--     TIFF:                        /usr/lib/aarch64-linux-gnu/libtiff.so (ver 42 / 4.1.0)
--     JPEG 2000:                   build (ver 2.5.0)
--     OpenEXR:                     /usr/lib/aarch64-linux-gnu/libImath.so /usr/lib/aarch64-linux-gnu/libIlmImf.so /usr/lib/aarch64-linux-gnu/libIex.so /usr/lib/aarch64-linux-gnu/libHalf.so /usr/lib/aarch64-linux-gnu/libIlmThread.so (ver 2_3)
......
--   Video I/O:
--     DC1394:                      YES (2.2.5)
--     FFMPEG:                      YES
--       avcodec:                   YES (58.54.100)
--       avformat:                  YES (58.29.100)
--       avutil:                    YES (56.31.100)
--       swscale:                   YES (5.5.100)
--       avresample:                YES (4.0.0)
--     GStreamer:                   YES (1.16.3)
--     v4l/v4l2:                    YES (linux/videodev2.h)
......
--   Python 3:
--     Interpreter:                 /usr/bin/python3 (ver 3.8.10)
--     Libraries:                   /usr/lib/aarch64-linux-gnu/libpython3.8.so (ver 3.8.10)
--     Limited API:                 NO
--     numpy:                       /usr/local/lib/python3.8/dist-packages/numpy/core/include (ver 1.24.4)
--     install path:                lib/python3.8/site-packages/cv2/python-3.8
```

确认无误后编译，需要一定时间，预计40分钟左右，等待。。。
```sh
make -j8
```

编译完无报错后安装
```sh
sudo make install
```

## 3.2 把生成的`cv2.cpy*.so`复制到Python3对应路径

## 3.3 验证OpenCV-Python支持GStreamer
```sh
firefly@firefly:~$ python3
>>> import cv2
>>> print(cv2.getBuildInformation())
......
  Video I/O:
    DC1394:                      YES (2.2.5)
    FFMPEG:                      YES
      avcodec:                   YES (58.54.100)
      avformat:                  YES (58.29.100)
      avutil:                    YES (56.31.100)
      swscale:                   YES (5.5.100)
      avresample:                YES (4.0.0)
    GStreamer:                   YES (1.16.3)
    v4l/v4l2:                    YES (linux/videodev2.h)
```

# 附录：其他问题
```sh
sudo add-apt-repository ppa:george-coolpi/multimedia
sudo: /etc/sudoers.d 可被任何人写
sudo: 无法解析主机：firefly: 未知的名称或服务
sudo: add-apt-repository：找不到命令
```

```
sudo apt install software-properties-common
```
