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

# RK3588固件
固件中主要包含有根系统文件rootfs.img、内核boot.img、uboot.img，其中系统由rootfs.img决定，从ubuntu到麒麟等。理论上内核应该和根系统文件相对应，如果不对应的话如内核使用ubuntu镜像中的，根系统文件使用麒麟镜像中的，则板子可能正常启动，基本功能正常，但会有小bug如部分设置界面不出现等。　

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

一定要确定删除内核文件后默认的开机内核存在且grub文件更新成功，否则容易出现再开机时进不了系统、进不了桌面等问题。  
<font color=red>包括`sudo apt-get upgrade`也是不能随意运行，有可能出现更新后因驱动不兼容等原因导致的进不了系统问题。</font>

# 无线网卡Wifi
大部分网卡都需要安装甚至自行编译驱动
```sh
sudo depmod -a
sudo modprobe 8188gu
sudo usb_modeswitch -KW -v 0bda -p 1a2b
```

命令行连接网络，当进不了桌面时救急用：
```sh
nmcli dev wifi connect xxx-wifiname password xxx-password
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
sudo chown smbuser:smbuser ./sharewithdevices/
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

iOS支持
```sh
[global]
   vfs objects = acl_xattr catia fruit streams_xattr
```
6. 重启服务
```sh
sudo service smbd restart
sudo service nmbd restart
```

# 取消录屏30s时间限制
```sh
gsettings set org.gnome.settings-daemon.plugins.media-keys max-screencast-length 0
```

# ssh冲突
```sh
ssh-keygen -f "/home/channy/.ssh/known_hosts" -R "192.168.2.66"
```