---
layout: default
title: Feature Matching In OpenCV
categories:
- Computer Vision
tags:
- Computer Vision
- OpenCV
- Feature
---

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

