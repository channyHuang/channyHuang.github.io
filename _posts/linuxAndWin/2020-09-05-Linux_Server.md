---
layout: default
title: Linux_Server
categories:
- C++
tags:
- C++
---
//Description:

//Create Date: 2020-09-05 13:14:28

//Author: channy

# Linux_Server

在virtualBox上安装ubuntu-server虚拟机

> 网络问题。apt-get update不成功有两种可能，一种是网络不通，一种是源不能用。
这次遇见的是网络问题。

```
sudo vi /etc/resolv.conf

//添加
nameserver 8.8.8.8
nameserver 223.5.5.5
nameserver 223.6.6.6
```

> 增强功能

```
sudo apt-get install dkms
sudo apt-get install build-essential
sudo reboot
sudo mount /dev/cdrom /mnt/
sudo /mnt/VBoxLinuxAdditions.run
sudo umount /mnt/
```

> 安装数据库，这里选的是postgresql

```
sudo apt-get install postgresql

pg_ctlcluster 12 main start

sudo -i -u postgres
psql
```

```
service postgres start
```

> 安装ssh，启动服务

```
sudo apt-get install ssh
service sshd restart
```

> 配置rsync

服务器和客户端分别配置rsyncd.conf、rsyncd.secrets

> 搭建web服务器,Apache2+cgi

```
sudo apt-get install apache2

//cgi
cd /etc/apache2/mods-enabled
sudo ln -s ../mods-available/cgi.load
sudo service apache2 reload

//cgi script 在/usr/lib/cgi-bin中，可以放.sh,.pl,.out等文件
```

也不难嘛，还以为技术多高深。。。

[back](./)

