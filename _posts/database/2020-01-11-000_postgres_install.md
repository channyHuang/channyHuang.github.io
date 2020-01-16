---
layout: default
title: 2020-01-11-postgres_install.md
categories:
- C++
tags:
- C++
---
//Description: postgres和AntDB源码安装过程中遇到的问题

//Create Date: 2020-01-11 11:02:07

//Author: channy

# postgres install

OS: Ubuntu 18.04

step 1: 参照文档下载源码安装，configure打开debug功能，可能会提示没有安装readline,zlib,bison,ssh等第三方库，configure之后修改src/Makefile.global去掉编译优化-O2方便调试，安装完成后，必须`再次执行configure`，否则后续重新make的时候会失败但报成功导致修改不生效！！！

step 2: 修改/etc/sysctl.d/10-ptrace.conf使非root用户也能gdb attach

step 3: 新建用户postgres, initDB后修改连接配置postgresql.conf和pg_hba.conf

step 4: pg_ctl启动服务，psql连一个客户端，gdb attach上就可以愉快地debug了

# AntDB install

OS: CentOs 8

官网下的镜像，安装完后yum -y install不管装什么都报match not found???纠结了好久偶然发现网络没连。。。设置网络为自动连接。

step 1: 参照github上的说明文档安装第三方库，截止至2020-01-11，CentOs 8中默认源没有python-devel和libssh2-devel，改用CentOs 7

step 2: configure，make，make install同pg类似

step 3: 在postgres下启动，出现Postgres-XL错误，待进一步探索。 

[back](/)

