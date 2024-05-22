---
layout: default
title: Linux Kernel Notes
categories:
- Linux
tags:
- Server
- Linux
---
//Description: 记录因各种导致系统异常的误操作。

//Create Date: 2024-05-22 09:14:28

//Author: channy

[toc]

# Linux kernel
一般内核文件主要包括header、image和modules三个文件
[kernel 5.15](https://kernel.ubuntu.com/mainline/v5.15/)

删除grub引导时不建议如下方式直接删除内核文件，即使已经安装了其它内核
```
sudo rm ./vmlinuz-5.14.0-051400-generic ./initrd.img-5.14.0-051400-generic ./System.map-5.14.0-051400-generic ./config-5.14.0-051400-generic 

sudo rm -r /lib/modules/5.14.0-051400-generic/
```

可以通过以下命令查看系统当前已有内核并指定开机使用的内核
```sh
dpkg --get-selections | grep linux-image
grep 'menuentry' /boot/grub/grub.cfg
sudo vim /etc/default/grub
sudo update-grub
```

# 无线网卡Wifi
大部分网卡都需要安装甚至自行编译驱动
```sh
sudo depmod -a
sudo modprobe 8188gu
sudo usb_modeswitch -KW -v 0bda -p 1a2b
```

# smbda设置共享文件夹
1. 创建共享文件夹`sharewithdevices`
```sh
sudo mkdir -p sharewithdevices
```
2. 增加共享用户`smbuser`
```sh
sudo useradd smbuser -s /usr/sbin/nologin
```
3. 修改共享文件夹`sharewithdevices`的owner为共享用户`smbuser`
```sh
sudo chmown smbuser:smbuser ./sharewithdevices/
```
4. 为共享用户`smbuser`创建登录密码
```sh
sudo smbpasswd -a smbuser
```
5. 根据需求修改共享配置
```sh
sudo vim /etc/samba/smb.conf
```

```sh
[nameindevices]
    comment=sharefiles
    path=/home/channy/Downloads/sharewithdevices
    valid users=smbuser
    guest ok=yes
    browsable=yes
    public=yes
    writable=yes
```
6. 重启服务
```sh
sudo service smbd restart
sudo service nmbd restart
```