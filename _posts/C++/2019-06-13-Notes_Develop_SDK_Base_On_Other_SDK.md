---
layout: default
title: Notes_Develop_SDK_Base_On_Other_SDK（笔记：依赖各厂家sdk开发标准化接口sdk遇到的坑）
categories:
- C++
tags:
- C++
---
//Author: channy

//Create Date: 2019-06-13 17:45:01

//Description: 

# Notes_Develop_SDK_Base_On_Other_SDK (笔记：依赖各厂家sdk开发标准化接口sdk遇到的坑)

> Be careful about struct alignment, it will cause crash...

> 小心结构体对齐，会导致崩溃

> In Callback function, please jump to own threads as soon as possible. Because Callback function run in dependent sdk (you will never know that whether it will call any exception).

> 在回调函数里，尽可能快地回到自己的线程上。因为回调函数跑在别人的线程上。（你永远不知道厂家sdk会不会因此阻塞）

> Still in Callback function, please save all data in own pointers.(You will never know when these data will be covered by new data)

> 还是在回调函数里，尽可能把所有数据保存到自己的指针中。（你永远不知道厂家sdk会在什么时候覆盖掉这些数据）遇到过厂家回调回来一幅图像数据，没保存全部图像数据，只存了头指针和长度，然后图像头被厂家sdk重写了，导致得到的图像打不开。。。

> If new object in not constructed function, please consider the situation that user may call this function two times and lead to memory leak. (You will never know user how to use this sdk, even there is a specific document)

> 如果不是在构造函数中new对象，请考虑用户可能会两次调用该函数而导致内存泄漏。（你永远不知道用户会怎么使用这个sdk，哪怕有详细的说明文档）

> Be sure all threads are closed before distructor, otherwise the sdk will crash when exit. (Don't ask me how do I know it...)

> 保证在析构函数前所有的线程都已关闭，否则会在sdk退出时报错。（别问我是怎么知道的。。。）

> Use try-catch as much as possible. (You will never know what will be done in others sdk...)

> 多使用try-catch。（你永远不知道厂家的sdk里都做了些什么。。。）

> Always, always, check the input parameters. (Still, you will never know what will others sdk give you...)

> 总是，总是检查输入参数。（你永远不知道厂家sdk会传给你什么。。。）

[back](./)

