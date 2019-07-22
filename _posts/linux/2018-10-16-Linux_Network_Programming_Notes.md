---
layout: default
title: Linux_Network_Programming_Notes
categories:
- Linux
tags:
- Linux
---
//Author: channy

//Create Date: 2018-10-16 11:30:25

//Description: 学习《Linux网络编程（第二版）》一书时的一点笔记

# Linux_Network_Programming_Notes

实验环境： Ubuntu 16.04, g++

## 4.4.1 pthread.c
thread.cpp: In function ‘void* start_routine(void*)’:

thread.cpp:13:17: error: invalid conversion from ‘void*’ to ‘int*’ [-fpermissive]

int *running = arg;

-> 需要显式转换(int*)arg

/usr/include/pthread.h:233:12: note:   initializing argument 3 of ‘int pthread_create(pthread_t*, const pthread_attr_t*, void* (*)(void*), void*)’
extern int pthread_create (pthread_t *__restrict __newthread,

-> start_routine不用转换

thread.cpp:40:35: error: invalid conversion from ‘void*’ to ‘void**’ [-fpermissive]
  pthread_join(pt, (void*)&ret_join);

->ret_join改为void *

thread.cpp:(.text+0x103): undefined reference to 'pthread_create'

thread.cpp:(.text+0x171): undefined reference to 'pthread_join'

-> 需要加参数-lpthread,因为pthread库不是 Linux 系统默认的库， g++ thread.cpp -lpthread


[back](./)

