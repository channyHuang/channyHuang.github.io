---
layout: default
title: 第一次接私活的一点经验教训
categories:
- Notes
tags:
- Notes
---
//Description: 记录第一次接私活的一点经验教训

* current article content
{:toc}

sudo apt  install ruby-bundler

bundle install

bundle exec jekyll serve 

# 第一次接私活的一点经验教训 （20200902）

## 没有平台保障

因为平台要收取额外的费用，很多甲方都不太愿意，于是就私下直接交易。

优点：甲方成本降低

缺点：遇上什么人全靠运气，乙方没有任何保障，比如我这次。。。得到的教训就是：新手还是尽量在平台上接，等做过几个项目双方都有一点了解了再脱离平台不迟，比一上来就私下接活能少踩好多坑

## 频繁改需求

这个貌似网上很多人都遇到过

## 验收时找各种借口不结尾款

我这次遇到的：

背景：和铺码有关，就是那种点读书的铺码

一开始问目标机器是什么平台，不肯说，再问，含糊回答，“可能是windows吧”，我应该从这就看出端倪的，当初还是太天真

后面，给了一个win 32位机器下开发的铺码动态库，然后告诉我说目标机器是64位哦

重点来了，他们给的这个库在64位下压根不能跑，不说我的加载方法，直接dependency拉进去就报错，一片红，给他们反馈，他们就只会一直说他们的是可以运行的，让他们提供运行起来的视频，打死不同意，让他们用工具测下库，打死不同意，还一直要我这边提供我的源码，典型的想收一波韭菜，呵呵~

[back](./)