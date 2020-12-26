---
layout: default
title: Qt_Interview_Questions
categories:
- C++
tags:
- C++
---
//Description:

//Create Date: 2020-12-25 12:31:38

//Author: channy

# Qt_Interview_Questions

> QString的实现原理

> 深copy与浅copy

```
QString str1 = "hello";
QString str2 = str1;
str2[1] = 'm';
```

> Qt的moc文件的作用

> Qt的信号槽机制，一个信号对应多个槽，一个槽接收多个信号

> 构造函数里QObject* parent的作用

```
QDialog dlg1 = QDialog;
QDialog dlg2 = QDialog(QObject *parent);
```

> 

[back](/)

