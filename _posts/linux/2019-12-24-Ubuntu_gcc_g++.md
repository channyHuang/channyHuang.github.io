---
layout: default
title: Ubuntu_gcc_g++
categories:
- Linux
tags:
- Linux
- Command
---
//Description: Notes when initialize in linux

//Create Date: 2018-12-24 10:25:19

//Author: channy

# Ubuntu 18.04安装gcc、g++ 4.8

sudo apt-get install gcc-4.8 g++-4.8

sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 100
sudo update-alternatives --config gcc

sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 100
sudo update-alternatives --config g++
