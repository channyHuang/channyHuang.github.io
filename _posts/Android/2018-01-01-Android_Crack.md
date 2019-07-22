---
layout: default
title: Android Reverse (Android逆向)
categories:
- Android
tags:
- Android
---
//Description: 笔记，Android逆向

# Android逆向

工具：androidKiller
环境：windows 7, 64 bit

顺利状态下：

step 1:
androidKiller反编译，得smali文件

![AndroidKiller](https://github.com/qanny/qanny.github.io/blob/master/assets/images/androidKiller.png)

step 2:
查找关键字

![AndroidKeyword](https://github.com/qanny/qanny.github.io/blob/master/assets/images/androidKeyword.png)

step 3:
修改跳转条件

![AndroidCondition](https://github.com/qanny/qanny.github.io/blob/master/assets/images/androidCondition.png)

不顺利的情况下：
用的apktool 3.0

µ±Ç° Apktool Ê¹ÓÃ°æ±Ÿ£ºAndroid Killer Default APKTOOL
ÕýÔÚ·Ž±àÒë APK£¬ÇëÉÔµÈ...
>ÈýÔÂ 11, 2018 10:05:40 ÉÏÎç com.rover12421.shaka.lib.LogHelper info_aroundBody2
>ÐÅÏ¢: Ê¹ÓÃ ShakaApktool 4.0.0-master-1587672-20180310
>ÈýÔÂ 11, 2018 10:05:41 ÉÏÎç brut.androlib.res.AndrolibResources info_aroundBody0
>ÐÅÏ¢: ÕýÔÚŒÓÔØ×ÊÔŽÁÐ±í...
>ÈýÔÂ 11, 2018 10:05:44 ÉÏÎç brut.androlib.res.AndrolibResources info_aroundBody14
>ÐÅÏ¢: ·Ž±àÒë AndroidManifest.xml Óë×ÊÔŽ...
>ÈýÔÂ 11, 2018 10:05:44 ÉÏÎç brut.androlib.res.AndrolibResources info_aroundBody6
>ÐÅÏ¢: ÕýÔÚŽÓ¿òŒÜÎÄŒþŒÓÔØ×ÊÔŽÁÐ±í: C:\Users\Administrator\AppData\Local\ShakaApktool\framework\1.apk
>ÈýÔÂ 11, 2018 10:06:07 ÉÏÎç brut.androlib.res.AndrolibResources info_aroundBody10
>ÐÅÏ¢: ³£¹æ×ÊÔŽÁÐ±í...
>ÈýÔÂ 11, 2018 10:06:07 ÉÏÎç brut.androlib.res.AndrolibResources info_aroundBody16
>ÐÅÏ¢: ·Ž±àÒë×ÊÔŽÎÄŒþ...
>ÈýÔÂ 11, 2018 10:07:22 ÉÏÎç brut.androlib.res.AndrolibResources info_aroundBody18
>ÐÅÏ¢: ·Ž±àÒë values */* XMLs...
>java.lang.NullPointerException
>	at brut.androlib.res.data.value.ResStyleValue.serializeToResValuesXml_aroundBody5$advice(ResStyleValue.java:73)
>	at brut.androlib.res.data.value.ResStyleValue.serializeToResValuesXml(ResStyleValue.java:1)
>	at brut.androlib.res.AndrolibResources.generateValuesFile(AndrolibResources.java:518)
>	at brut.androlib.res.AndrolibResources.decode(AndrolibResources.java:268)
>	at brut.androlib.Androlib.decodeResourcesFull(Androlib.java:132)
>	at brut.androlib.ApkDecoder.decode(ApkDecoder.java:115)
>	at com.rover12421.shaka.cli.apktool.DecodeCommand.run(DecodeCommand.java:196)
>	at com.rover12421.shaka.cli.Main.main(Main.java:156)
>java.lang.NullPointerException
>	at brut.androlib.res.data.value.ResStyleValue.serializeToResValuesXml_aroundBody5$advice(ResStyleValue.java:73)
>	at brut.androlib.res.data.value.ResStyleValue.serializeToResValuesXml(ResStyleValue.java:1)
>	at brut.androlib.res.AndrolibResources.generateValuesFile(AndrolibResources.java:518)
>	at brut.androlib.res.AndrolibResources.decode(AndrolibResources.java:268)
>	at brut.androlib.Androlib.decodeResourcesFull(Androlib.java:132)
>	at brut.androlib.ApkDecoder.decode(ApkDecoder.java:115)
>	at com.rover12421.shaka.cli.apktool.DecodeCommand.run(DecodeCommand.java:196)
>	at com.rover12421.shaka.cli.Main.main(Main.java:156)
>Exception in thread "main" java.lang.IllegalArgumentException: expected element name 'style' and not 'resources'
>	at org.xmlpull.renamed.MXSerializer.endTag(MXSerializer.java:785)
>	at brut.androlib.res.AndrolibResources.generateValuesFile(AndrolibResources.java:521)
>	at brut.androlib.res.AndrolibResources.decode(AndrolibResources.java:268)
>	at brut.androlib.Androlib.decodeResourcesFull(Androlib.java:132)
>	at brut.androlib.ApkDecoder.decode(ApkDecoder.java:115)
>	at com.rover12421.shaka.cli.apktool.DecodeCommand.run(DecodeCommand.java:196)
>	at com.rover12421.shaka.cli.Main.main(Main.java:156)
APK ·Ž±àÒëÊ§°Ü£¬ÎÞ·šŒÌÐøÏÂÒ»²œÔŽÂë·Ž±àÒë!


当前 Apktool 使用版本：Android Killer Default APKTOOL
正在反编译 APK，请稍等...
>三月 23, 2018 7:48:43 上午 com.rover12421.shaka.lib.LogHelper info_aroundBody2
>信息: 使用 ShakaApktool 4.0.0-master-1587672-20180310
>三月 23, 2018 7:48:45 上午 brut.androlib.res.AndrolibResources info_aroundBody0
>信息: 正在加载资源列表...
>三月 23, 2018 7:48:49 上午 brut.androlib.res.AndrolibResources info_aroundBody14
>信息: 反编译 AndroidManifest.xml 与资源...
>三月 23, 2018 7:48:49 上午 brut.androlib.res.AndrolibResources info_aroundBody6
>信息: 正在从框架文件加载资源列表: C:\Users\Administrator\AppData\Local\ShakaApktool\framework\1.apk
>三月 23, 2018 7:49:32 上午 brut.androlib.res.AndrolibResources info_aroundBody10
>信息: 常规资源列表...
>三月 23, 2018 7:49:34 上午 brut.androlib.res.AndrolibResources info_aroundBody16
>信息: 反编译资源文件...
>三月 23, 2018 7:51:31 上午 brut.androlib.res.AndrolibResources info_aroundBody18
>信息: 反编译 values */* XMLs...
>java.lang.NullPointerException
>	at brut.androlib.res.data.value.ResStyleValue.serializeToResValuesXml_aroundBody5$advice(ResStyleValue.java:73)
>	at brut.androlib.res.data.value.ResStyleValue.serializeToResValuesXml(ResStyleValue.java:1)
>	at brut.androlib.res.AndrolibResources.generateValuesFile(AndrolibResources.java:518)
>	at brut.androlib.res.AndrolibResources.decode(AndrolibResources.java:268)
>	at brut.androlib.Androlib.decodeResourcesFull(Androlib.java:132)
>	at brut.androlib.ApkDecoder.decode(ApkDecoder.java:115)
>	at com.rover12421.shaka.cli.apktool.DecodeCommand.run(DecodeCommand.java:196)
>	at com.rover12421.shaka.cli.Main.main(Main.java:156)
>java.lang.NullPointerException
>	at brut.androlib.res.data.value.ResStyleValue.serializeToResValuesXml_aroundBody5$advice(ResStyleValue.java:73)
>	at brut.androlib.res.data.value.ResStyleValue.serializeToResValuesXml(ResStyleValue.java:1)
>	at brut.androlib.res.AndrolibResources.generateValuesFile(AndrolibResources.java:518)
>	at brut.androlib.res.AndrolibResources.decode(AndrolibResources.java:268)
>	at brut.androlib.Androlib.decodeResourcesFull(Androlib.java:132)
>	at brut.androlib.ApkDecoder.decode(ApkDecoder.java:115)
>	at com.rover12421.shaka.cli.apktool.DecodeCommand.run(DecodeCommand.java:196)
>	at com.rover12421.shaka.cli.Main.main(Main.java:156)
>Exception in thread "main" java.lang.IllegalArgumentException: expected element name 'style' and not 'resources'
>	at org.xmlpull.renamed.MXSerializer.endTag(MXSerializer.java:785)
>	at brut.androlib.res.AndrolibResources.generateValuesFile(AndrolibResources.java:521)
>	at brut.androlib.res.AndrolibResources.decode(AndrolibResources.java:268)
>	at brut.androlib.Androlib.decodeResourcesFull(Androlib.java:132)
>	at brut.androlib.ApkDecoder.decode(ApkDecoder.java:115)
>	at com.rover12421.shaka.cli.apktool.DecodeCommand.run(DecodeCommand.java:196)
>	at com.rover12421.shaka.cli.Main.main(Main.java:156)
APK 反编译失败，无法继续下一步源码反编译!
