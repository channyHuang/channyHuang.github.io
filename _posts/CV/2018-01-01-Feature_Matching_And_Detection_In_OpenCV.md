---
layout: default
title: Feature Matching And Detection In OpenCV
categories:
- Lib
tags:
- Computer Vision
- OpenCV
- Feature
---
//Description: Feature Matching And Detection In OpenCV

//Create Date: 2018-01-01 16:02:39

//Author: channy

# Feature Matching In OpenCV

```
Mat readImage(string filename) {
	Mat img = imread(filename), imgGray;
	if( img.empty()) {
		cout << "Couldn'g open image " << filename << ". Usage: detect <image_name>\n";
		return Mat();
	}
	//namedWindow( "image", 1 );
	//imshow("image", img);
	//waitKey(0);
	
	if (img.channels() == 3) {
		cvtColor(img, imgGray, COLOR_BGR2GRAY);
	} else {
		img.copyTo(imgGray);
	}
	
	return imgGray;
}

int main( int argc, char** argv ) {
	cv::CommandLineParser parser(argc, argv, "{ @input | ./fruits.jpg | ./fruits.jpg}");
    
	string filename1 = parser.get<string>("@input");
	string filename2 = parser.get<string>("@input");
	
	Mat img1 = readImage(filename1);
	Mat img2 = readImage(filename2);
	
	vector<KeyPoint> detectKeyPoint1, detectKeyPoint2;
	Mat descriptors1, descriptors2;
	Ptr<ORB> orb = ORB::create(5000);
	orb->detectAndCompute(img1, noArray(), detectKeyPoint1, descriptors1);
	orb->detectAndCompute(img2, noArray(), detectKeyPoint2, descriptors2);

	if (descriptors1.type() != CV_32F) {
		descriptors1.convertTo(descriptors1, CV_32F);
		descriptors2.convertTo(descriptors2, CV_32F);
	}
	
	FlannBasedMatcher matcher;
	vector<DMatch> matches;
	matcher.match(descriptors1, descriptors2, matches);
	
	Mat imgMatch;
	drawMatches(img1, detectKeyPoint1, img2, detectKeyPoint2, matches, imgMatch, Scalar::all(-1), Scalar::all(-1),vector<char>(), DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS );
	
	imshow("match", imgMatch);
	waitKey(0);
	
	return 0;
}
```

Let's start at `FlannBasedMatcher.match()` function. `FlannBasedMatcher` is a derived class of `DescriptorMatcher`, then will jump to `DescriptorMatcher.match()` and enter `knnMatch` to find the most k nearby matches, seems so easy.

# Feature Detection In OpenCV

Here we will analyse the implement of Feature Detection in Opencv3.

At the beginning, let's see how to use opencv to detect features.

```c++
#include <opencv2/core/utility.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/opencv.hpp>
#include <opencv2/features2d/features2d.hpp>

#include <cstdio>
#include <iostream>

using namespace cv;
using namespace std;

int main( int argc, char** argv ) {
	cv::CommandLineParser parser(argc, argv, "{ @input | ./fruits.jpg | }");
    
	string filename = parser.get<string>("@input");
	Mat img = imread(filename), imgGray;
	if( img.empty() )
    {
        cout << "Couldn'g open image " << filename << ". Usage: detect <image_name>\n";
        return 0;
    }
	namedWindow( "image", 1 );
	imshow("image", img);
	
	if (img.channels() == 3) {
		cvtColor(img, imgGray, COLOR_BGR2GRAY);
	} else {
		img.copyTo(imgGray);
	}
	
	vector<KeyPoint> detectKeyPoint;
	Mat imgWithKeyPoint;

	//Fast
	Ptr<FeatureDetector> detector = FastFeatureDetector::create();
	detector->detect(imgGray, detectKeyPoint);
	drawKeypoints(img, detectKeyPoint, imgWithKeyPoint, Scalar(255, 0, 0), DrawMatchesFlags::DRAW_RICH_KEYPOINTS);
	namedWindow("FAST", 1);
	imshow("FAST", imgWithKeyPoint);
	
	//AKAZE
	detector = AKAZE::create();
	detector->detect(imgGray, detectKeyPoint);
	drawKeypoints(img, detectKeyPoint, imgWithKeyPoint, Scalar(255, 0, 0), DrawMatchesFlags::DRAW_RICH_KEYPOINTS);
	namedWindow("akaze", 1);
	imshow("akaze", imgWithKeyPoint);
	
	//Brisk
	detector = BRISK::create();
	detector->detect(imgGray, detectKeyPoint);
	drawKeypoints(img, detectKeyPoint, imgWithKeyPoint, Scalar(255, 0, 0), DrawMatchesFlags::DRAW_RICH_KEYPOINTS);
	namedWindow("Brisk", 1);
	imshow("Brisk", imgWithKeyPoint);
	
	//GoodFeaturesToTrack
	detector = GFTTDetector::create();
	detector->detect(imgGray, detectKeyPoint);
	drawKeypoints(img, detectKeyPoint, imgWithKeyPoint, Scalar(255, 0, 0), DrawMatchesFlags::DRAW_RICH_KEYPOINTS);
	namedWindow("GoodFeaturesToTrack", 1);
	imshow("GoodFeaturesToTrack", imgWithKeyPoint);
	
	//ORB
	detector = ORB::create();
	detector->detect(imgGray, detectKeyPoint);
	drawKeypoints(img, detectKeyPoint, imgWithKeyPoint, Scalar(255, 0, 0), DrawMatchesFlags::DRAW_RICH_KEYPOINTS);
	namedWindow("ORB", 1);
	imshow("ORB", imgWithKeyPoint);
	
	//MSER
	detector = MSER::create();
	detector->detect(imgGray, detectKeyPoint);
	drawKeypoints(img, detectKeyPoint, imgWithKeyPoint, Scalar(255, 0, 0), DrawMatchesFlags::DRAW_RICH_KEYPOINTS);
	namedWindow("MSER", 1);
	imshow("MSER", imgWithKeyPoint);
	
	//SimpleBlobDetector
	detector = SimpleBlobDetector::create();
	detector->detect(imgGray, detectKeyPoint);
	drawKeypoints(img, detectKeyPoint, imgWithKeyPoint, Scalar(255, 0, 0), DrawMatchesFlags::DRAW_RICH_KEYPOINTS);
	namedWindow("SimpleBlobDetector", 1);
	imshow("SimpleBlobDetector", imgWithKeyPoint);

	
	waitKey(0);
	
	return 0;
}
```
Then we will begin from: `FastFeatureDetector::create()`

>actually, it is: (feature2d/src/fast.cpp)

```c++
Ptr<FastFeatureDetector> FastFeatureDetector::create( int threshold, bool nonmaxSuppression, int type ) {
    return makePtr<FastFeatureDetector_Impl>(threshold, nonmaxSuppression, type);
}
```
After create ptr, then we enter detect function of `FastFeatureDetector_Impl`:
```c++
void detect( InputArray _image, std::vector<KeyPoint>& keypoints, InputArray _mask ) {
	Mat mask = _mask.getMat(), grayImage;
	UMat ugrayImage;
	_InputArray gray = _image;
	if( _image.type() != CV_8U )
	{
		_OutputArray ogray = _image.isUMat() ? _OutputArray(ugrayImage) : _OutputArray(grayImage);
		cvtColor( _image, ogray, COLOR_BGR2GRAY );
		gray = ogray;
	}
	FAST( gray, keypoints, threshold, nonmaxSuppression, type );
	KeyPointsFilter::runByPixelsMask( keypoints, mask );
}
```
First, we need to convert input image to gray image.

Then, follow the kernel function _FAST_, actually in _FAST_t_:

```c++
template<int patternSize>
void FAST_t(InputArray _img, std::vector<KeyPoint>& keypoints, int threshold, bool nonmax_suppression)
```

[back](./)