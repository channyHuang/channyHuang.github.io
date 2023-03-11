---
layout: default
title: Linux_Server/Cgi_Server
categories:
- Server
tags:
- Server
- Linux
---
//Description: Linux_Server and Cgi_Server

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

# Setting_Cgi_Server

1. install apapche2

```
sudo apt-get install apache2
```

2. change cgi path in file server-cgi-bin.conf

default path: /etc/apache2/conf-available

change path to /var/www/cgi-bin

```
<IfModule mod_alias.c>
        <IfModule mod_cgi.c>
                Define ENABLE_USR_LIB_CGI_BIN
        </IfModule>

        <IfModule mod_cgid.c>
                Define ENABLE_USR_LIB_CGI_BIN
        </IfModule>

        <IfDefine ENABLE_USR_LIB_CGI_BIN>
                ScriptAlias /cgi-bin/ /var/www/cgi-bin/
                <Directory "/var/www/cgi-bin">
                        AllowOverride None
                        Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
                        Require all granted
                        AddHandler cgi-script cgi py sh
                </Directory>
        </IfDefine>
</IfModule>
```

3. add handler in file cgid.load and make soft links

default path: /etc/apache2/mods-available

add the following code

```
AddHandler cgi-script .cgi .pl .py .sh
```

then link

```
sudo ln -s /etc/apache2/mods-available/cgid.load /etc/apache2/mods-enabled/cgid.load
```

4. restart apache2

```
sudo /etc/init.d/apache2 restart
```

5. add target files in /var/www/cgi-bin

don't forget to change the permission of target files

[back](./)

