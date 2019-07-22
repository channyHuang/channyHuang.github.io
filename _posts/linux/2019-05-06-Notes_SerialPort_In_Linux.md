---
layout: default
title: Notes_SerialPort_In_Linux
categories:
- Linux
tags:
- Linux
- Qt
---
//Author: channy

//Create Date: 2019-05-06 22:35:45

//Description: 

# Notes_SerialPort_In_Linux

Tools: cutecom

工具：cutecom

first, install cutecom using the following command

先用下面的命令安装cutecom

> sudo apt install cutecom

配置，配置文件在下面路径

then, config cutecom, in ~/.config/cutecom/cutecom5

if forget this path, can use `man config` command for help. 

如果忘了该路径，可以用 `man config` 找找看

or type serialport name directory in cutecom GUI.

或者直接在cutecom的界面上输入端口号

If the target PC does not have serialport, or other situation (for example, virtual machine), then can use virtual port 

如果目标机器没有端口，可以用虚拟端口

```python
#! /usr/bin/env python
#coding=utf-8

import pty
import os
import select

def mkpty():
    master1, slave = pty.openpty()
    slaveName1 = os.ttyname(slave)
    master2, slave = pty.openpty()
    slaveName2 = os.ttyname(slave)
    print '\nslavedevice names: ', slaveName1, slaveName2
    return master1, master2

if __name__ == "__main__":

    master1, master2 = mkpty()
    while True:
        rl, wl, el = select.select([master1,master2], [], [], 1)
        for master in rl:
            data = os.read(master, 128)
            print "read %d data." % len(data)
            if master==master1:
                os.write(master2, data)
            else:
                os.write(master1, data)

```

test: using virtual port

然后就可以愉快地调试啦～

[back](./)

