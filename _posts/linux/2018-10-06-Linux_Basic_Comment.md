---
layout: default
title: Linux_Basic_Comment
categories:
- Linux
tags:
- Linux
- Command
---
//Description: Notes when coding in linux

//Create Date: 2018-10-06 10:25:19

//Author: channy

# Linux_Basic_Comment

## Add Environment Path

In ~/.bashrc file add your path like this:

```
export PATH=/media/sf_SVN/Bin/ETC-4th/freeflow/linux/bin:$PATH
```

then run 'source ~/.bashrc' to make it work. enjoy~

## Basic comment

```shell
awk
sed
top -p $(pidof xxx)
```

## disk

查看当前目录下哪个子目录占用空间大

```
du -s /root/* | sort -nr
```

查看磁盘空间占用情况

```
df -h
```

查看当前目录占用总空间，不列出详情

```
du -sh
```
[back](./)
