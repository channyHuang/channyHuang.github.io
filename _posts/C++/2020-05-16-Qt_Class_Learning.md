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

### QGraphicsView -> QAbstractScrollArea -> QFrame -> QWidget

视图，可设置场景scene，最终show的widget

### QGraphicsScene -> QObject

场景。是把下面的item啦、State和StateMachine啦等等结合起来形成最终的动画。主要方法有addItem()。一个scene可以在多个view中显示

### QGraphicsTextItem -> QGraphicsObject -> QGraphicsItem

可以看成动画里面的单个元素，比如 examples的sub-attaq里面的文字、小船、炸弹等等，可以设置单个元素的一些特性，显示移动停止之类的。可以setTransform、setPos等

### QStateMachine -> QState

QState -> QAbstarctState -> QObject

状态和状态机。记录元素所在的状态，比如开始状态、结束状态这种。不同的状态就可以对应不同的Animation啦。有addTransition()

### QPropertyAnimation -> QVariantAnimation -> QAbstractAnimation,  QGraphicsTransform, QGraphicsRotation, QGraphicsTransform -> QObject

在Android里动画一般分为两种：视图动画和属性动画。视图动画基本就是补间、渐变、平移、缩放、旋转及这类组合，一般只改变视觉效果，不改变属性；而属性动画顾名思义。

### QSequentialAnimationGroup, QParallelAnimationGroup -> QAnimationGroup -> QAbstractAnimation -> QObject

既然是group咯那就是Animation的集合啦？

### QAbstractTransition

类似于group，QSignalTransition接收到signal后才进行的动画

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

### QGraphicsProxyWidget -> QGraphicsWidget

examples的states里面的，可以移动的widget

### QEasingCurve

线性运动轨迹

#### Examples

样例1: 图像移动，从一点移动到另一点（参考: animatedtiles）

```c++
int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    //动画元素，如图像
    AnimationItem *item = new AnimationItem;
    item->setPixmap(QPixmap("ellipse.png"));
    //场景，坐标，元素需要加入到场景
    QGraphicsScene *scene = new QGraphicsScene(-500, -500, 500, 500);
    scene->addItem(item);
    scene->setBackgroundBrush(Qt::black);
    //状态，为了简化，只有两个，item每在一个点为一个状态，两点共两个状态
    QState *rootStates = new QState;
    QState *state1 = new QState(rootStates);
    state1->assignProperty(item, "pos", QPointF(-300, -300));
    QState *state2 = new QState(rootStates);
    state2->assignProperty(item, "pos", QPointF(100, 100));
    //视图，类似于窗口吧
    QGraphicsView *view = new QGraphicsView(scene);
    view->setWindowTitle("graphics view");
    view->setFixedSize(1000, 1000);
    view->show();
    //设置状态机，初始状态
    rootStates->setInitialState(state1);
    QStateMachine states;
    states.addState(rootStates);
    states.setInitialState(rootStates);
    //设置定时器，状态跳转
    QTimer *timer = new QTimer;
    timer->setSingleShot(true);
    timer->start(1000);

    QAbstractTransition *trans = state1->addTransition(timer, SIGNAL(timeout()), state2);
    states.start();

    return a.exec();
}


class AnimationItem
        : public QObject, public QGraphicsPixmapItem
{
    Q_OBJECT
    //这一句没有动画不会生效
    Q_PROPERTY(QPointF pos READ pos WRITE setPos)
public:
    explicit AnimationItem(QObject *parent = nullptr);
    ~AnimationItem();

signals:

public slots:
};
```

样例中用了64个item分别按照button中的形状设置各自的位置，button的click事件即为触发动画转换，同时设置了平行动画ParallelAnimation

over~

---

样例2: 元素缩放 (参考: appchooser)

```c++
int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    //动画元素，这次是widget
    AnimationWidget *item = new AnimationWidget;
    item->setPixmap(QPixmap("ellipse.png"));
    item->setGeometry(QRect(0, 0, 100, 100));

    QGraphicsScene *scene = new QGraphicsScene(0, 0, 300, 300);
    scene->setBackgroundBrush(Qt::white);
    scene->addItem(item);
    //增加了点击事件，点击回到state1
    QStateMachine states;
    QState *rootStates = new QState(&states);
    QState *state1 = new QState(rootStates);
    state1->assignProperty(item, "geometry", QRect(0, 0, 100, 100));
    rootStates->addTransition(item, SIGNAL(clicked()), state1);
    QState *state2 = new QState(rootStates);
    state2->assignProperty(item, "geometry", QRect(100, 100, 200, 200));
    rootStates->setInitialState(state1);

    QGraphicsView *view = new QGraphicsView(scene);
    view->setWindowTitle("graphics view");
    view->show();
    
    states.setGlobalRestorePolicy(QState::RestoreProperties);
    states.addDefaultAnimation(new QPropertyAnimation(item, "geometry"));
    states.setInitialState(rootStates);
    //平移加缩放
    QTimer *timer = new QTimer;
    //timer->setSingleShot(true);
    timer->start(2000);

    QAbstractTransition *trans = state1->addTransition(timer, SIGNAL(timeout()), state2);
    states.start();

    return a.exec();
}

class AnimationWidget
        : public QGraphicsWidget
{
    Q_OBJECT
public:
    AnimationWidget(QObject *parent = nullptr);
    ~AnimationWidget();
    //需要重写paint才能显示出图像
    void paint(QPainter *painter, const QStyleOptionGraphicsItem *, QWidget *) override
    {
        painter->drawPixmap(QPointF(), p);
    }
    //重写点击事件回应
    void mousePressEvent(QGraphicsSceneMouseEvent *) override
    {
        emit clicked();
    }

    void setPixmap(QPixmap qPixmap)
    {
        orig = qPixmap;
        p = qPixmap;
    }
    //缩放功能
    void setGeometry(const QRectF &rect) override
    {
        QGraphicsWidget::setGeometry(rect);

        if (rect.size().width() > orig.size().width())
            p = orig.scaled(rect.size().toSize());
        else
            p = orig;
    }
Q_SIGNALS:
    void clicked();

private:
    QPixmap orig;
    QPixmap p;
};
```

so easy, over~



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

