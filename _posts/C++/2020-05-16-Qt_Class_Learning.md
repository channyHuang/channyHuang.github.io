---
layout: default
title: Qt_Class_Learning
categories:
- C++
tags:
- C++
---
//Description: 记录学习Qt中用到过的各种类及简单用法，基于Qt 5.14. Qt_Class_Learning.

//Create Date: 2020-05-16 23:09:19

//Author: channy

[toc]

***<font color = Orange>界面相关</font>***

# 界面相关
## Qt Designer

中文名Qt设计师，主要为写布局用，可调各widget的参数并直接看效果。
可直接在Qt Designer中调好布局，导出为.ui文件，再在代码中直接用QUiLoader加载.ui文件。

QMetaObject QObject.staticMetaObject

QObject Q_PROPERTY 显示属性

信号/槽

## QLayout

1. **QBoxLayout** QHBoxLayout/QVBoxLayout

1. **QFormLayout** 表单

1. **QGridLayout**

1. **QStackedLayout** 栈
```c++
QVBoxLayout *rootLayout = new QVBoxLayout(this);
rootLayout->setEnabled(false);

QGridLayout *mainLayout = new QGridLayout(this);

//Attempting to add QLayout "" to Widget "Widget", which already has a layout
```
上面这段是不能正确地设置mainLayout为主布局的。。。所以，setEnabled最好只用在子布局上。。。

## ui布局问题 
如果有一个widget以当前widget为parent初始化了，那么不管它有没有被增加到当前widget的layout中，都会在当前layout占有一席之地，一般是左上方。会出现挡住其它widget然而其它widget显示正常的问题，点击无效。

## QScrollArea布局问题

又双叒叕是祖传代码的问题

因为用在指定硬件上，所以用QxxScrollArea封装了一下QScrollArea，然后就发现，当文字小于给定的高度时，setWidget之后widget底部对齐了，最后一行还扩展了高度。。。

看封装只有
```c++
setWidgetResizable(true);
setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
```
然后是一些触屏处理。并且把set的widget替换成Qt自带的widget后能正常显示。最后发现是`setWidgetResizable(true);`的锅。

猜测这个应该是和Android的渲染流程一样吧，先从下往上渲染确定父控件的大小，再从上往下渲染，这时候如果原来的子控件比父控件要小得多，那么子控件就会被扩展拉伸？？？

又一个坑。。。

## QToolButton 多用于工具栏的button
## QShortcut 按钮快捷键
```c++
QShortcut *key = new QShortcut(QKeySequence(Qt::Key_Q), this);
connect(key, SIGNAL(activated()), this, SLOT(action()));
```

## 获取某点的颜色
```c++
const QDesktopWidget *desktop = QApplication::desktop();
const QPixmap pixmap = QGuiApplication::primaryScreen()->grabWindow(desktop->winId(), p.x(), p.y(), 1, 1);
QImage i = pixmap.toImage();
return i.pixel(0, 0);
```

## QWidget
QWidget.paintEvent 可由QWidget.update进行刷新

## QDialog
QDialog.show 和 QDialog.open，前者在显示的同时不影响其它操作，后者显示后屏蔽了其它对父窗口的操作，特别地，当鼠标press后如果触发了QDialog.open，那么不管鼠标的release是否在QDialog.close后，原父窗口都无法再接收到该release事件。

## QPalette
调色板，设置整个widget中各个控件的颜色。
```c++
    QPalette palette = this->palette();
    palette.setColor(QPalette::Window, Qt::white);
    palette.setColor(QPalette::Text, Qt::red);
    palette.setColor(QPalette::ButtonText, Qt::green);
    this->setPalette(palette);
```

## QFont
主要是QFont::Weight
```c++
QFont ft("Helvetica Neue", 20, 400);
for (int i = 125; i <= 130; i++) {
    ft.setWeight(i);
    qDebug() << "set weight: " << i << ", actual weight: " << ft.weight();
}

ft.setWeight(QFont::Normal);
qDebug() << "set weight: " << QFont::Normal << ", actual weight: " << ft.weight();

// result
set weight:  125 , actual weight:  125
set weight:  126 , actual weight:  126
set weight:  127 , actual weight:  127
set weight:  128 , actual weight:  0
set weight:  129 , actual weight:  1
set weight:  130 , actual weight:  2
set weight:  50 , actual weight:  50

// Mapping OpenType weight value.
enum Weight {
    Thin     = 0,    // 100
    ExtraLight = 12, // 200
    Light    = 25,   // 300
    Normal   = 50,   // 400
    Medium   = 57,   // 500
    DemiBold = 63,   // 600
    Bold     = 75,   // 700
    ExtraBold = 81,  // 800
    Black    = 87    // 900
};
```

范围0-127 

### 和QFont有关的一个显示问题
```c++
//加载字库
QFontDatabase::addApplicationFont(":/fonts/NotoSansTC-Medium.otf");
```
还需要注意修改资源文件.qrc，确保新加的字库文件在里面，否则addApplicationFont会返回-1哦~

然后需要确认要显示的文字在字库中，特别是一些罕见的字。win下可以用FontCreator打开.ttf/.otf等文件，直接复制粘贴需要显示的字进行查找，不要用输入法输入，因为从unicode上来讲，有同形字但是unicode不相同的，比如"吏讀"的"吏"字

```c++
//遇到过字形相同unicode不同的字
----- (copy) char = [吏], unicode = [63966], hex = [f9de] -----
----- (copy) char = [讀], unicode = [63834], hex = [f95a] -----
----- (copy) char = [･], unicode = [65381], hex = [ff65] -----
----- (copy) char = [吏], unicode = [63966], hex = [f9de] -----
----- (copy) char = [頭], unicode = [38957], hex = [982d] -----
----- (type) char = [吏], unicode = [21519], hex = [540f] -----
----- (type) char = [讀], unicode = [35712], hex = [8b80] -----
----- (type) char = [･], unicode = [65381], hex = [ff65] -----
----- (type) char = [吏], unicode = [21519], hex = [540f] -----
----- (type) char = [頭], unicode = [38957], hex = [982d] -----
```

只有字库中有的并且字库正确加载了(addApplicationFont返回不是-1)才能正常显示出来哦，否则只会显示对应字库中.notdef对应的字(空白或方块或其它)

## 和QFont显示有关的第二个问题
```c++
xxx* widget = new xxx(this);
widget->setTextFont("Helvetica Neue", 28, 500);
int width = QFontMetrics(widget->font()).width(qsString);
```

上面一段代码，从某个widget中取出里面的font并计算在该font下字符串qsString所需要的宽度，结果。。。貌似算出来的width不太对哦~

猜测可能的原因，这个时候widget还没有走到渲染的一步，所以从中取出的font不是设置的那个font?

把最后一句改成
```c++
int width = QFontMetrics(mkFont("Helvetica Neue", 28, 500)).width(qsString);
```
就正常了。。。

好纠结。。。

***<font color = Orange>动画相关</font>***

# 动画相关
## Animation
插话：在mac下examples里面的菜单栏不会显示，需要加上
```c++
menuBar()->setNativeMenuBar(false);
```
才会显示~

## QGraphicsView -> QAbstractScrollArea -> QFrame -> QWidget
视图，可设置场景scene，最终show的widget

## QGraphicsScene -> QObject
场景。是把下面的item啦、State和StateMachine啦等等结合起来形成最终的动画。主要方法有addItem()。一个scene可以在多个view中显示

## QGraphicsTextItem -> QGraphicsObject -> QGraphicsItem
可以看成动画里面的单个元素，比如 examples的sub-attaq里面的文字、小船、炸弹等等，可以设置单个元素的一些特性，显示移动停止之类的。可以setTransform、setPos等

## QStateMachine -> QState
QState -> QAbstarctState -> QObject

状态和状态机。记录元素所在的状态，比如开始状态、结束状态这种。不同的状态就可以对应不同的Animation啦。有addTransition()

## QPropertyAnimation -> QVariantAnimation -> QAbstractAnimation,  QGraphicsTransform, QGraphicsRotation, QGraphicsTransform -> QObject
在Android里动画一般分为两种：视图动画和属性动画。视图动画基本就是补间、渐变、平移、缩放、旋转及这类组合，一般只改变视觉效果，不改变属性；而属性动画顾名思义。

## QSequentialAnimationGroup, QParallelAnimationGroup -> QAnimationGroup -> QAbstractAnimation -> QObject
既然是group咯那就是Animation的集合啦？

## QAbstractTransition
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

## QGraphicsProxyWidget -> QGraphicsWidget
examples的states里面的，可以移动的widget

## QEasingCurve
线性运动轨迹
### Examples
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

样例3: 曲线控制运动速度 (参考easing)

```c++
Widget::Widget(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::Widget)
{
    ui->setupUi(this);

    AnimationItem *item = new AnimationItem;
    item->setPixmap(QPixmap("ellipse.png"));
    //item->setPos(250, 250);
    QGraphicsScene *scene = new QGraphicsScene(0, 0, 300, 300);
    scene->addItem(item);
    QGraphicsView *view = new QGraphicsView;
    view->setWindowTitle("view title");
    view->setScene(scene);
    view->show();

    QPropertyAnimation *anim = new QPropertyAnimation(item, "pos");
    anim->setEasingCurve(QEasingCurve::BezierSpline);
    anim->setStartValue(QPointF(0, 0));
    anim->setEndValue(QPointF(100, 100));
    anim->setDuration(1000);
    anim->start();
}
```

view, 场景，item都和前几例一样，只需要增加QPropertyAnimation绑定item就可以了, so easy ~

样例4. 平行动画 (参考moveblocks)

四个item，位置移动，就是把两个state的移动一起吧，坐标很复杂，仿佛回到了建模时代。。。

样例5. states

集中了位置平移、缩放、透明度

样例6. stickman

从入门到放弃的好样例

样例7. sub-attaq 

成型的小游戏

# 文件相关
## QXmlStreamReader
读取xml文件的类
## QXmlStreamReader::TokenType
xml标签类型，有StartDocument, EndDocument, StartElement, EndElement, Characters这几种比较常用的类型

主要是Element吧，以下面的xml文件为例
```xml
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

```c++
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

# 其它相关
## Qt国际化
QTranslator translator.load(qmFilePath);

Qt通过加载.qm文件实现不同的语言切换。.qm文件由.qs文件用Qt Tools的linguist生成。代码中通过tr("要翻译的文字")标明，Qt Tools可以自动生成.qs文件，只需要把翻译填到.qs文件就好～

然后发现有个坑。。。如果有换行，如tr("xxxx\nxxxx")，.qs文件里

```xml
<translation>xxxx
xxxx</translation>
```

linux下写.qs换行不生效，windows下写换行再放到linux下，换了一行，要换两行的依旧不生效。

一开始以为是linux下和windows下的换行不一样导致的。后面新开了个app把这段抽出来发现并没有这个问题。呵~

然后发现工作中的label用了自定义的，setWrapAnywhere处理文本换行时一并把需要的换行给处理掉掉了。。。

果然，祖传代码，你永远不知道它会有多少坑。。。

## 在Qt中使用c++新功能
Qt5.9.0 + Qt Creater 4.3.1 使用c++17需要同时加上 CONFIG += c++17 和 QMAKE_CXXFLAGS += -std=c++17

## 在Qt不同的Library中优雅地包含其它Library或App中的文件
背景: 原架构中各Library互不干扰

需求: 新需求中其中一个Library需要分版本处理，而版本信息定义在主App的pro文件中，并在app中的一个类Setting里面保存。所以，要么Library中也加一个版本定义并且需要和app中的保持一致；要么Library需要在自身的pro中引用app中的Setting类文件。

问题: 代码不好维护，不优雅，并且违背了Library之间相互独立的原则。

解决方案: 。。。想不到啊啊啊。。。

## 编码问题
QString遇到'\0'会截断。

QByteArray中间可以包含'\0'。

QFile的write遇到'\0'也会截断。

QDataStream遇到'\0'同样会截断。

QTextStream输入QByteArray遇到'\0'不会截断。

```c++
QFile file(dataPath);
file.open(QFile::WriteOnly | QFile::Truncate);
QTextStream out(&file);
out.setCodec(QTextCodec::codecForName("utf-8"));
out << reply->readAll();
file.close();
```

## 调用和关闭外部程序
```c++
QProcess *pro = new QProcess;
pro->start("abc.exe params");
Sleep(5000);
if (pro) {
    pro->close();
}
```

[back](/)

