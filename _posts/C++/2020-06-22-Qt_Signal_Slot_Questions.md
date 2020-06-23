---
layout: default
title: Qt_Signal_Slot_Questions
categories:
- C++
tags:
- C++
---
//Description: 最近老是遇到不响应信号的问题，做此记录

//Create Date: 2020-06-22 19:17:58

//Author: channy

# Qt_Signal_Slot_Questions

[代码地址](https://github.com/channyHuang/baseProject.git)

上述项目中的readAllLabelsInXml部分

原意是想要统计一个文件(许多xml组成)中出现过的label信息

1. 创建了一个ThreadObject类并移到线程中，处理每一行数据，从中提取出label名称并存储在map中

2. MainWidget用来读取文件内容并调用ThreadObject

```c++
    m_thread = new QThread();
    threadObject = new ThreadObject();
    threadObject->moveToThread(m_thread);
    connect(this, &MainWidget::sigHasData, threadObject, &ThreadObject::analyse);


    QFile file(qsFileName);
    if (!file.exists()) {
        std::cout << "File " << qsFileName.toStdString().c_str() << " does not exist" << std::endl;
        return;
    }
    int nIdx = 0;
    if(file.open(QIODevice::ReadOnly)) {
        char buffer[1024];
        qint64 lineLen = file.readLine(buffer , sizeof(buffer));
        std::cout << "start to read files" << std::endl;
        while (lineLen != -1)
        {
            m_qsBuffer = QString(buffer);
            std::cout << "main thread " << QThread::currentThreadId() << std::endl;
            QTimer::singleShot(0, this, &MainWidget::sendSig);

            lineLen = file.readLine(buffer , sizeof(buffer));

            if (++nIdx >= 5) break;
        }
    }
    file.close();
```

MainWidget中每读取一行内容就调用槽函数发送信号。从log上看信号是发送了，可是ThreadObject没收到呀。。。

没收到信号可能的原因:

> 类没有继承QObject或没有声明Q_OBJECT
> 信号或槽函数没有正确定义，没有放到Q_SIGNALS或Q_SLOTS等等下面
> 信号被子控件过滤掉了
> 传递参数是自定义的类型且没有register，需要用qRegisterMetaType<类型>("名称")才能作为signal-slot的参数
> 就是上面这种，emmm......线程没起来~~~哭晕~~~

为什么moveToThread后还要手工thread->start?

如果不手工start的话，调用该类的函数也会触发start，而信号不会

修改后生效
```c++
    m_thread = new QThread();
    threadObject = new ThreadObject();
    threadObject->moveToThread(m_thread);
    m_thread->start();
    QMetaObject::Connection res = connect(this, &MainWidget::sigHasData, threadObject, &ThreadObject::analyse);
    std::cout << "connect res " << (bool)res << std::endl;

    QFile file(qsFileName);
    if (!file.exists()) {
        std::cout << "File " << qsFileName.toStdString().c_str() << " does not exist" << std::endl;
        return;
    }
    int nIdx = 0;
    if(file.open(QIODevice::ReadOnly)) {
        char buffer[1024];
        qint64 lineLen = file.readLine(buffer , sizeof(buffer));
        std::cout << "start to read files" << std::endl;
        while (lineLen != -1)
        {
            QString qsBuffer = QString(buffer);
            std::cout << "main thread " << QThread::currentThreadId() << std::endl;
            QTimer::singleShot(0, this, [this, qsBuffer]{
                emit sigHasData(qsBuffer);
            });

            lineLen = file.readLine(buffer , sizeof(buffer));

            if (++nIdx >= 5) break;
        }
    }
    file.close();
```

[back](/)

