---
layout: default
title: Compute Camera Params and Point Cloud
categories:
- Computer Vision
tags:
- Computer Vision
- 3D Reconstruction
---
//Description: Math base of 3D reconstruction

# Compute Camera Params and Point Cloud

About the theory of this part, **Multiple View Geometry in Computer Vision** is an excellent book.

Here is a simple example using OpenCV to compute Camera params. 

But if we use this to reconstruct an object, we will find that the result is too poor to use. The reason will be analized in here: 
[Difficulty In Reconstruction](./Difficulity_In_Reconstruction.html)

Now suppose that we got the params of cameras and point cloud of features. Next step is reconstruct to mesh model. **Possion Reconstruction** is a classical algorithm.

```
	int ptcount=(int) matches.size();
	Mat p1(ptcount,2,CV_32F);
	Mat p2(ptcount,2,CV_32F);

	//change keypoint to mat
	Point2f pt;
	for(int i=0;i<ptcount;i++)
	{
		pt=detectKeyPoint1[matches[i].queryIdx].pt;
		p1.at<float>(i,0)=pt.x;
		p1.at<float>(i,1)=pt.y;

		pt=detectKeyPoint2[matches[i].trainIdx].pt;
		p2.at<float>(i,0)=pt.x;
		p2.at<float>(i,1)=pt.y;
	}

	//use RANSAC to calculate F
	Mat fundamental;
	vector <uchar> RANSACStatus;
	fundamental=findFundamentalMat(p1,p2,RANSACStatus,FM_RANSAC);

	cout<<"F="<<fundamental<<endl;

	double fx,fy,cx,cy;
	fx=512;
	fy=480;
	cx=256;
	cy=240;
	//calibration
	Mat K= cv::Mat::eye(3,3,CV_64FC1);
	K.at<double>(0,0) = fx;
	K.at<double>(1,1) = fy;
	K.at<double>(0,2) = cx;
	K.at<double>(1,2) = cy;
	Mat Kt=K.t();

	cout<<"K="<<K<<endl;
	cout<<"Kt="<<Kt<<endl;

	//E=K't * F * K
	Mat E=Kt*fundamental*K;
	cout<<"E="<<E<<endl;

	SVD svd(E);
	Mat W=Mat::eye(3,3,CV_64FC1);
	W.at<double>(0,1)=-1;
	W.at<double>(1,0)=1;
	W.at<double>(2,2)=1;

	Mat_<double> R=svd.u*W*svd.vt;
	Mat_<double> t=svd.u.col(2);
	cout<<"R="<<R<<endl;
	cout<<"t="<<t<<endl;
```

