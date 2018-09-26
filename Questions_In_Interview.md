---
layout: default
---

# Questions In Interview (C Plus & Android)
# 面试中遇到的一些问题 (C Plus & Android)

> 最近忙着找工作面试，顺手记录一下遇见的问题，就当是笔记了。

## C Plus

1. STL库，vector迭代器，map的实现
	![Octocat](./assets/image/iterator.png)
1. const, static

1. 多态、继承
	多态(虚函数) -> 一个接口，多种状态，运行时确定调用的函数地址
	重载 -> 多个同名不同参数的函数

1. 多线程同步方法
	临界区
	事件
	信号量
	互斥量

1. 智能指针

1. 进程间的通信

	pipe

	message queue
	
	signal
	
	shared memory
	
	socket
	
## Android
1. 进程和线程的区别（貌似是Android中经典的经典问题）

	一般情况下一个app占用一个进程（也有占用多个的）；

	一个进程有多个线程，共享进程的资源，线程也有属于自己的私有资源；

1. 进程间的通信
	
	bundle/Intent
	
	Broadcast
	
	Message
	
	AIDL
	
	ContentProvider
	
	Socket

## Others

[back](./)