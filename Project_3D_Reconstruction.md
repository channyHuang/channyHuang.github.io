---
layout: default
---

# Project - 3D Reconstruction

Here is a little introduction about one of my previous projects -- 3D reconstruction.

## Basic Data Flow

So sorry that flow can not be shown -.-
```flow
st=>start: Start
opInput=>operation: Input images/vedio
opDetect=>operation: Feature detect and match
opCompute=>operation: Compute params of camera
opFace=>operation: Reconstruct mesh model
opFix=>operation: Fix model using DB
e=>end
st->opInput->opDetect->opCompute->opFace->opFix->e
```

Well, First step, Feature detecting and matching. (*[Feature Detection In OpenCV](./Feature_Detection_In_OpenCV.html) & 
[Feature Matching In OpenCV](./Feature_Matching_In_OpenCV.html)*)

There are many kinds of features, SIFT, SURF, FAST, ORB, BRISK, Freak, Harri, BOW...

Compared these features, we can find that in most cases, SIFT is best because it contains scale, can detect more features than others, of cause, it is not fast enough.

In this project, we combine two features: `SIFT` and `Freak`.

- [x] Difficulty 1: **What if the input images has few features?**

	Of cause we can add some texture objects in scene if possible. But if it is hard, than we can add something else, for example, detect lines or other shapes in input images according to what scene to be inputed. Building reconstruction is based on line detection. This project tries to reconstruct foot, so there is no lines.

Minimize the error of reprojection, BA algorithm, solve nonlinear least squares problem.

- [] Difficulty 2: **What if the point cloud is sparse?**

	In order to build a dense point cloud, most researchers will refer to PMVS/CMVS. This is an open source library to generate a dense point cloud. But I don't know why so many people believe it is a 3D reconstruction library. Actually, the input of PMVS/CMVS is sparse point cloud, it is just change it to dense cloud but not contains the whole flow of 3D reconstruction.

From point cloud to mesh model, use possion reconstruction.

- [] Difficulty 3: **How to improve precision?**

We have a small database of foot. At the last step in this project, we use models in database to fix the reconstruction model.

## Some reference:
> [VisualSFM](http://ccwu.me/vsfm/)

> [PMVS/CMVS](http://www.di.ens.fr/pmvs/)

[back](./)