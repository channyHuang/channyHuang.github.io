---
layout: default
title: Qt_Class_Learning
categories:
- C++
tags:
- C++
---
//Description: Qt学习笔刷V2，基于Qt 5.14

//Create Date: 2021-09-01 20:09:19

//Author: channy

# Qt_Class_Learning

## Qt Designer

中文名Qt设计师，主要为写布局用，可调各widget的参数并直接看效果

可直接在Qt Designer中调好布局，导出为.ui文件，再在代码中直接用QUiLoader加载.ui文件，

QMetaObject QObject.staticMetaObject

QObject Q_PROPERTY 显示属性

信号/槽

## QLayout

**QBoxLayout** QHBoxLayout/QVBoxLayout

**QFormLayout** 表单

**QGridLayout**

**QStackedLayout** 栈

## QToolButton 多用于工具栏的button

## 获取某点的颜色

```
const QDesktopWidget *desktop = QApplication::desktop();
const QPixmap pixmap = QGuiApplication::primaryScreen()->grabWindow(desktop->winId(), p.x(), p.y(), 1, 1);
QImage i = pixmap.toImage();
return i.pixel(0, 0);
```

## QWidget

QWidget.paintEvent 可由QWidget.update进行刷新

## QDialog

QDialog.show 和 QDialog.open，前者在显示的同时不影响其它操作，后者显示后屏蔽了其它对父窗口的操作，特别地，当鼠标press后如果触发了QDialog.open，那么不管鼠标的release是否在QDialog.close后，原父窗口都无法再接收到该release事件。

[back](/)

