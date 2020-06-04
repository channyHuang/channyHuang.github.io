---
layout: default
title: Qt_Class_Learning
categories:
- C++
tags:
- C++
---
//Description: 突然发现Qt中还有好多类没有用过，打算边学边写笔记，占个坑先

//Create Date: 2020-05-16 23:09:19

//Author: channy

# Qt_Class_Learning

## Animation

插话：在mac下examples里面的菜单栏不会显示，需要加上
```
menuBar()->setNativeMenuBar(false);
```
才会显示~

### QGraphicsTextItem, QGraphicsItem, QGraphicsObject

可以看成动画里面的单个元素，比如 examples的sub-attaq里面的文字、小船、炸弹等等，可以设置单个元素的一些特性，显示移动停止之类的。

### QState, QStateMachine

状态和状态机。记录元素所在的状态，比如开始状态、结束状态这种。不同的状态就可以对应不同的Animation啦。

### QPropertyAnimation, QGraphicsTransform, QGraphicsRotation, QGraphicsTransform

在Android里动画一般分为两种：视图动画和属性动画。视图动画基本就是补间、渐变、平移、缩放、旋转及这类组合，一般只改变视觉效果，不改变属性；而属性动画顾名思义。

### QSequentialAnimationGroup, QParallelAnimationGroup

既然是group咯那就是Animation的集合啦？

### QGraphicsScene

场景。是把上面的item啦、State和StateMachine啦等等结合起来形成最终的动画。

那么剩下的就很简单了

item类:

boat: 船。船的淡入淡出、移动速度、方向等

bomb: 船发射的bomb

submarine: 潜艇，速度方向等

torpedo: 鱼雷，只有出现、移动、消毁三种动画，运动曲线是InQuad

state类:

基本上只有出现、移动、消失三种

scene类:

考虑被bomb或torpedo击中的结束情况就差不多了。

### QGraphicsProxyWidget

examples的states里面的，可以移动的widget

### QEasingCurve

线性运动轨迹

## QPalette

调色板，设置整个widget中各个控件的颜色。

```
    QPalette palette = this->palette();
    palette.setColor(QPalette::Window, Qt::white);
    palette.setColor(QPalette::Text, Qt::red);
    palette.setColor(QPalette::ButtonText, Qt::green);
    this->setPalette(palette);
```

# QXmlStreamReader

读取xml文件的类

## QXmlStreamReader::TokenType

xml标签类型，有StartDocument, EndDocument, StartElement, EndElement, Characters这几种比较常用的类型

主要是Element吧，以下面的xml文件为例
```
<?xml version="1.0" encoding="UTF-8"?>
<start>
<person id="123456">Doctor
    <name>The Doctor</name>
    <age>1300</age>
</person>
</start>
```

QXmlStreamReader初始化时可以直接赋值，也可以用addData赋值。

用readNext层层遍历标签，标签头为StartElement,内容为Characters

```
    QXmlStreamReader::TokenType nToken = m_qxmlReader.readNext();
    while (!m_qxmlReader.atEnd() && !m_qxmlReader.hasError()) {
        if (nToken == QXmlStreamReader::StartElement) {
            //......
        }
        nToken = m_qxmlReader.readNext();
    }
```

标签头中的内容为Attributes，可以用hasAttribute判断是否存在对应名称的Attribute, 用value获取（如果有的>话）
```
QXmlStreamAttributes qxmlAttributes = m_qxmlReader.attributes();
```

很简单，over~

[back](/)

