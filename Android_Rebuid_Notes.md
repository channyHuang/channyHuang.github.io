---
layout: default
---

//Author: channy

//Create Date: 2018-10-10 09:57:46

//Description: 

# Android_Rebuid_Notes
# Android逆向笔记

工具都大同小异

shakaapktool

反编译一切顺利

找字符串改smali一切顺利

回编译一切失败

```
Can't set aapt binary as executable
>Exception in thread "main" com.rover12421.shaka.b.l:
Caused by: java.lang.NullPointerException
😌😌😌
原因查找
apktool版本旧，换新，无果
java版本新9.0，换旧8.0，尼玛过了
😤😤😤
```

改的第一个apk: 法语角

要vip才能查看解析，把检测vip的跳转改了，eqz改成nez，回编，安装，perfect! 愉快地做题去了

啊喂喂这是笔记不是日记，用词能不能走点心 🤕

20180227

IDA pro貌似比较强大的样子😍

各种反编译错误后根据某书的教程，从此踏上了smali的不归路😇

突然间觉得android好脆弱，不堪一击😌

明天继续 #^_^#

20180301

卡住了

工具不管用了，反编译失败。。。

exception in thread main java.lang.illegalargumentexception: excepted element name style and not resources

20180302

用最新的apktool能反编译成功，拿到了smali文件。改的第二个apk: hellotalk

要vip才能设置多种语言。同样的，定位到代码位置，gtz改成了lez，回编译失败了。。。还是要看apktool的源代码。待办。明天刷题o

20180303

线程这块不熟，待充电

20180310

编译shakaapktool一直报错说找不到资源什么什么的，local en_gb😌搞了半天原来是语言问题，语言包里只有中文和美式英文，偏偏我电脑是英式英文😌😌😌把语言包copy了一个换了名字，编译过了😅great british还是最爱英伦腔😍😍😍

20180322

换了个工具把resources.asrc中坑爹的0xxxxx给找出来了，然而不会改😂初步猜测是加了不侮辱智商的保护措施的吧-_-b已放弃。goodbye hellotalk

