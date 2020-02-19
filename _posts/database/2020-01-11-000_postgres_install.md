---
layout: default
title: 000_postgres_install
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

./configure --enable-debug --enable-cassert

step 2: 修改/etc/sysctl.d/10-ptrace.conf使非root用户也能gdb attach

step 3: 新建用户postgres, initDB后修改连接配置postgresql.conf和pg_hba.conf

step 4: pg_ctl启动服务，psql连一个客户端，gdb attach上就可以愉快地debug了

# AntDB install

OS: CentOs 8

官网下的镜像，安装完后yum -y install不管装什么都报match not found???纠结了好久偶然发现网络没连。。。设置网络为自动连接。

step 1: 参照github上的说明文档安装第三方库，截止至2020-01-11，CentOs 8中默认源没有python-devel和libssh2-devel，改用CentOs 7

step 2: configure，make，make install同pg类似

step 3: 在postgres下启动，出现Postgres-XL错误，待进一步探索。 

# Oracle install

OS: Ubuntu 18.04

1. 执行以下命令，安装alien，用于将rpm转为deb

> sudo apt-get install alien libaio1 unixodbc vim

2. 从Oracle官网下载 Oracle 11g express edition 安装文件

> http://www.oracle.com/technetwork/database/database-technologies/express-edition/downloads/index.html

3. 将rpm安装文件转为deb文件

> sudo alien --scripts -d oracle-xe-11.2.0-1.0.x86_64.rpm

4. 准备工作

* 创建chkconfig脚本文件

> sudo vim /sbin/chkconfig

* 将如下内容粘贴到脚本文件中

```shell
#!/bin/bash
file=/etc/init.d/oracle-xe
if [[ ! `tail -n1 $file | grep INIT` ]]; then
echo >> $file
echo '### BEGIN INIT INFO' >> $file
echo '# Provides: OracleXE' >> $file
echo '# Required-Start: $remote_fs $syslog' >> $file
echo '# Required-Stop: $remote_fs $syslog' >> $file
echo '# Default-Start: 2 3 4 5' >> $file
echo '# Default-Stop: 0 1 6' >> $file
echo '# Short-Description: Oracle 11g Express Edition' >> $file
echo '### END INIT INFO' >> $file
fi
update-rc.d oracle-xe defaults 80 01
```

* 保存以上文件并修改权限

> sudo chmod 755 /sbin/chkconfig

* 执行以下命令

```
free -m
sudo ln -s /usr/bin/awk /bin/awk
mkdir /var/lock/subsys
touch /var/lock/subsys/listener
```

5. 执行以下命令，以防Oracle安装过程中报错(忽视执行过程中的报错)

```
sudo -s
umount /dev/shm
sudo rm -rf /dev/shm
sudo mkdir /dev/shm
mount --move /run/shm /dev/shm
sudo mount -t tmpfs shmfs -o size=2048m /dev/shm
```

* 创建以下文件

> sudo vim /etc/rc2.d/S01shm_load

* 复制以下内容到上面新建文件中

```shell
#!/bin/sh
case "$1" in
start) mkdir /var/lock/subsys 2>/dev/null
touch /var/lock/subsys/listener
rm /dev/shm 2>/dev/null
mkdir /dev/shm 2>/dev/null
mount -t tmpfs shmfs -o size=2048m /dev/shm ;;
*) echo error
exit 1 ;;
esac
```

* 执行以下命令

> sudo chmod 755 /etc/rc2.d/S01shm_load

6. 重启计算机

7. 安装 Oracle 11gR2 XE

* 进入Oracle 11gR2 XE安装文件所在目录

* 运行安装包

> sudo dpkg --install oracle-xe-11.2.0-1.0.x86_64.deb

* 运行配置程序

> sudo /etc/init.d/oracle-xe configure

8. Oracle 11gR2 XE 使用前必要配置

* 环境变量配置

进入用户目录, 编辑bashrc文件, 将以下内容添加到 .bashrc文件尾

```
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export ORACLE_SID=XE
export NLS_LANG=`$ORACLE_HOME/bin/nls_lang.sh`
export ORACLE_BASE=/u01/app/oracle
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
export PATH=$ORACLE_HOME/bin:$PATH
```

* 执行如下命令，当前bash环境变量生效

> ./.profile

* 编辑root用户下配置文件，将相同内容复制到文件尾

> sudo vi /root/.bashrc

9. 重启计算机，Oracle应该正常运行

10. 运行以下命令，进入SQL提示窗

> sqlplus sys as sysdba

[参考](https://www.youtube.com/watch?v=jOrarHqj7X8)

[中文参考](https://blog.csdn.net/once_pluto/article/details/83385150)

[back](/)

