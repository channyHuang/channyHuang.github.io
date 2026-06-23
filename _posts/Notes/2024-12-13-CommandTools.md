---
layout: default
title: 视频编解码学习笔记
categories:
- Notes
tags:
- Notes
---
//Description： 视频编解码学习笔记

[toc]

***
<font color = Orange>基础篇：视频和编码</font>
***

# 视频格式和编码格式
## 视频格式
一个视频包含多类数据：图像数据、字幕数据、音频数据。视频格式决定了这些数据以一个什么样的顺序和什么样的格式排列组合。如对于数据`ABCabc123`，可能一种格式是`123ABCabc`，另一种格式是`abc123ABC`......

同样的内容使用不同的视频格式生成的大小基本一致。

## 编码格式
对原始视频数据的无损或有损压缩编码。如对于数据`ABCabc123`，可能一种编码是`A3a313`表示`A`往后3个连续字符`a`往后3个连续字符`1`往后3个连续字符，另一种编码是`XYZ`其中`X`表示`ABC`、`Y`表示`abc`、`Z`表示`123`

使用OpenCV读取同样一个证明，同样的为

| 编码格式 | 视频格式 | OpenCV写状况 |
|:---:|:---:|:---|
| H264 | mp4 | OpenCV: FFMPEG: tag 0x34363248/'H264' is not supported with codec id 27 and format 'mp4 / MP4 (MPEG-4 Part 14)'   OpenCV: FFMPEG: fallback to use tag 0x31637661/'avc1' |
| H264 | avi | -- |
| H264 | mkv | -- |
| | | |
| H265 | mp4 | OpenCV: FFMPEG: tag 0x43564548/'HEVC' is not supported with codec id 173 and format 'mp4 / MP4 (MPEG-4 Part 14)'   OpenCV: FFMPEG: fallback to use tag 0x31766568/'hev1' |
| H265 | avi | OpenCV: FFMPEG: tag 0x43564548/'HEVC' is not supported with codec id 173 and format 'avi / AVI (Audio Video Interleaved)' |
| H265 | mkv | OpenCV: FFMPEG: tag 0x43564548/'HEVC' is not supported with codec id 173 and format 'matroska / Matroska' |
| | | |
| mjpeg | mp4 | OpenCV: FFMPEG: tag 0x47504a4d/'MJPG' is not supported with codec id 7 and format 'mp4 / MP4 (MPEG-4 Part 14)'   OpenCV: FFMPEG: fallback to use tag 0x7634706d/'mp4v' |
| mjpeg2 | mp4 | OpenCV: FFMPEG: tag 0x4745504d/'MPEG' is not supported with codec id 2 and format 'mp4 / MP4 (MPEG-4 Part 14)'   OpenCV: FFMPEG: fallback to use tag 0x7634706d/'mp4v' |


***
<font color = Orange>应用篇：FFMPEG</font>
***

# ffmpeg
1. 视频格式转换，如Linux下的录屏文件转换成mp4
```sh
ffmpeg -i input.webm output.mp4
```
带`-c copy`的转换后肉眼看起来质量会变，不带`-c copy`的重新编码可以保持原质量

1. 裁剪部分视频
`-ss`开始时间，`-to`结束时间，但裁剪后的视频时间可能会出现偏差，原因暂未知
```sh
ffmpeg -i input.mp4 -ss 00:00:12 output.mp4

ffmpeg -i input.webm -ss 00:00:00 -to 00:00:30 output.webm
```

1. 合并多个视频
```filelist.txt
file 'n_calc_height.mp4'
file 'n_calc_dist.mp4'
file 'n_area.mp4'
```

```sh
ffmpeg -f concat -i filelist.txt output.mp4
```

1. 编码格式转换
```sh
ffmpeg -i input.mp4 -vcodec libx265 output_h265.mp4
ffmpeg -i input.mp4 -vcodec libx264 output_h264.mp4
```

# 附录:OpenCV写视频
```c++
#include <iostream>
#include <map>
#include <vector>

#include <opencv2/opencv.hpp>

inline std::map<std::string, int> fourccByCodec() {
    std::map<std::string, int> mapFourcc;
    mapFourcc["h264"] = cv::VideoWriter::fourcc('H','2','6','4');
    mapFourcc["h265"] = cv::VideoWriter::fourcc('H','E','V','C');
    mapFourcc["mpeg2"] = cv::VideoWriter::fourcc('M','P','E','G');
    mapFourcc["mpeg4"] = cv::VideoWriter::fourcc('M','P','4','2');
    mapFourcc["mjpeg"] = cv::VideoWriter::fourcc('M','J','P','G');
    mapFourcc["vp8"] = cv::VideoWriter::fourcc('V','P','8','0');
    mapFourcc["yuv"] = cv::VideoWriter::fourcc('I','4','2','0');
    mapFourcc["flv"] = cv::VideoWriter::fourcc('V','L','V','1');
    return mapFourcc;
}

inline std::vector<std::string> extVideo() {
    std::vector<std::string> vExtVideo = {"mp4", "avi", "mkv"};
    return vExtVideo;
}

bool writeVideo(std::string sFourcc, std::string sExt, std::map<std::string, int> &mapFourcc, std::string &pUri) {
    printf("write video: %s.%s \n", sFourcc.c_str(), sExt.c_str());
    auto itr = mapFourcc.find(sFourcc);
    if (itr == mapFourcc.end()) return false;
    int nFourcc = itr->second;
    // int nWidth = 1280, nHeight = 720;

    cv::VideoCapture cap(pUri, cv::CAP_ANY);
    int nWidth = cap.get(cv::CAP_PROP_FRAME_WIDTH);
    int nHeight = cap.get(cv::CAP_PROP_FRAME_HEIGHT);
    if (!cap.isOpened()) {
        std::cerr << "VideoCapture not opened:\nuri = " << pUri << std::endl;
        return 0;
    }

    std::string sOutputVideo = "WriteVideo_" + sFourcc + "." + sExt;
    cv::VideoWriter writer;
    writer.open(sOutputVideo, nFourcc, 30, cv::Size(nWidth, nHeight));
    cv::Mat feature = cv::Mat::zeros(nHeight, nWidth, CV_8UC3);
    cv::Mat frame;
    int nFrameNum = 0;
    while (cap.isOpened()) { 
        cap.read(frame);
        if (frame.rows <= 0 || frame.cols <= 0) {
            break;
        }

        for (int i = 0; i < nHeight; ++i) {
            for (int j = 0; j < nWidth; ++j) {
                feature.at<cv::Vec3b>(i, j)[0] = frame.at<cv::Vec3b>(i, j)[0];
                feature.at<cv::Vec3b>(i, j)[1] = frame.at<cv::Vec3b>(i, j)[1];
                feature.at<cv::Vec3b>(i, j)[2] = frame.at<cv::Vec3b>(i, j)[2];
            }
        }

        // for (int i = 0; i < nHeight; ++i) {
        //     for (int j = 0; j < nWidth; ++j) {
        //         feature.at<cv::Vec3b>(i, j)[0] = rand() % 256;
        //         feature.at<cv::Vec3b>(i, j)[1] = rand() % 256;
        //         feature.at<cv::Vec3b>(i, j)[2] = rand() % 256;
        //     }
        // }
        // cv::imshow("frame", feature);
        // cv::waitKey(1);
        writer.write(feature);

        nFrameNum++;
    }
    writer.release();
    cap.release();

    return true;
}

int main() {
    std::string pUri = "/home/channy/Documents/projects/WJ_restruct/video.avi";
    

    std::map<std::string, int> mapFourcc = fourccByCodec();
    std::vector<std::string> vExtVideos = extVideo();

    for (auto itr = mapFourcc.begin(); itr != mapFourcc.end(); itr++) {
        if (itr->first != "h265") continue;
        for (int i = 0; i < vExtVideos.size(); ++i) {
            writeVideo(itr->first, vExtVideos[i], mapFourcc, pUri);
            break;
        }
    }
    
    return 0;
}
```