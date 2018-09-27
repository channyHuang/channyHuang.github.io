---
layout: default
---

# Questions In Interview (C Plus & Android)
# 面试中遇到的一些问题 (C Plus & Android)

> 最近忙着找工作面试，顺手记录一下遇见的问题，就当是笔记了。

## C Plus

1. STL库，vector迭代器，map的实现

	![Iterator](https://raw.githubusercontent.com/qanny/qanny.github.io/master/assets/images/iterator.png)
	
	list: 内部维护一个list指针，双向
	
	map: 平𧗾二叉树（红黑树），二分查找
	
	unordered_map: hash_map,需要定义hash_value和==
	
	迭代器失效：remove/delete
	
	vector内存分配：当第一次申请的空间L不够时，第二次申请会申请2L的空间并把原来的数据copy过去

1. const, static

	const int n; 
	
	const char* p; -> 指针内容不可变
	
	char* const p; -> 指针不可变
	
	f(const char* p)
	
	const char* f()
	
	f() const -> 常成员函数

1. new, malloc
	
	分配大小
	
	初始化
	
	内存管理

1. 多态、继承

	多态(虚函数) -> 一个接口，多种状态，运行时确定调用的函数地址
	
	重载 -> 多个同名不同参数的函数

1. 指针、引用

1. 多线程同步方法

	临界区
	
	事件
	
	信号量
	
	互斥量

1. 智能指针

	计数器记录指针的引用对象个数

1. 进程间的通信

	pipe

	message queue
	
	signal
	
	shared memory
	
	socket

1. 实现STL中的string

	```c++
	char * strcpy(char * strDest,const char * strSrc) {
		assert((strDest!=NULL) && (strSrc !=NULL));
		char * strDestCopy=strDest;
		while ((*strDest++=*strSrc++)!='\0'); 
		return strDestCopy;
	}
	```
	
## Algorithm
1. 单向二叉树（父节点->子节点），查找两节点的公共祖先
	```c++
	inLeftOrRight(Node *parent, Node *child)
	```

1. 判断单向链表是否有环

	两个指针，一个每次递增一步，一个每次递增两步

1. 大数中找最大的100个数

	堆排序
	
1. 数组移位

1. 一个序列中一个元素出现一次，其它出现三次，找出出现一次的元素

	ps: 很想知道这种问题如果没有见过，有多少人能够自己想到答案
	
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
	
1. json和xml的区别

	突然间后悔了。。。
	
	格式，解析，语言支持，可读性，速度

## Others

[back](./)