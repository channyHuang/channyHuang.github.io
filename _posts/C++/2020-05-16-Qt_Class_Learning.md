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

## QPalette

调色板，设置整个widget中各个控件的颜色。

```
    QPalette palette = this->palette();
    palette.setColor(QPalette::Window, Qt::white);
    palette.setColor(QPalette::Text, Qt::red);
    palette.setColor(QPalette::ButtonText, Qt::green);
    this->setPalette(palette);
```

[back](/)

