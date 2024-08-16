---
layout: default
title: Linux_Basic_Comment
categories:
- Linux
tags:
- Linux
- Command
---
//Description: Notes when coding in linux。记录Linux下常用的命令。及常用的docker命令。

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

# Docker
```sh
# 测试docker能否正常运行
docker run --rm hello-world
```
上面的命令会拉取hello-world的镜像，但常遇到网络问题导致的timeout而失败。

可在`/etc/docker/daemon.json`中添加镜像源，文件不存在可以先创建。
```sh
cd /etc/docker/
sudo vim daemon.json 
# ...
sudo systemctl daemon-reload
sudo systemctl restart docker
```

`/etc/docker/daemon.json`文件内容：
```json
{
  "registry-mirrors": [
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com",
    "https://do.nark.eu.org",
        "https://dc.j8.work",
        "https://docker.m.daocloud.io",
        "https://dockerproxy.com",
        "https://docker.mirrors.ustc.edu.cn",
        "https://docker.nju.edu.cn"
  ]
}
```

最后成功运行hello-world样例
```sh
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
c1ec31eb5944: Pull complete 
Digest: sha256:1408fec50309afee38f3535383f5b09419e6dc0925bc69891e79d84cc4cdcec6
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

## docker ros

```sh
# 拉取ros镜像
$ docker pull osrf/ros:noetic-desktop-full
$ docker images
REPOSITORY    TAG                   IMAGE ID       CREATED         SIZE
osrf/ros      noetic-desktop-full   5a2576cc4b0d   4 weeks ago     3.44GB
hello-world   latest                d2c94e258dcb   15 months ago   13.3kB

# 创建容器并进行文件映射
$ docker run --name docker_ros_name -it -v /home/channy/Documents/thirdlibs/ros_workspace:/home osrf/ros:noetic-desktop-full
# 查看已有容器的名称等信息
$ docker ps -a
CONTAINER ID   IMAGE                          COMMAND                  CREATED              STATUS          PORTS     NAMES
fb01ef7b2b1f   osrf/ros:noetic-desktop-full   "/ros_entrypoint.sh …"   About a minute ago   Up 23 seconds             docker_ros_name
# 启动
$ docker start docker_ros_name
# 命令行运行
$ docker exec -it my_container /bin/bash
# 删除容器
$ docker rm <container_idapt >
```

## docker export 
当创建好容器后发现有些参数没有设置时，可以先导出当前容器再重新导入，重新创建容器，可以保留当前容器已安装的各类工具和环境，避免重新安装。
```sh
docker export xxx_container_id > xxx.tar

docker import - xxx_image_name < xxx.tar
```

## ros1
1. No module named 'catkin'
```sh
root@4d57cc0d4f6d:/opt/ros/noetic/bin# ./catkin_make
Traceback (most recent call last):
  File "./catkin_make", line 13, in <module>
    from catkin.builder import apply_platform_specific_defaults  # noqa: E402
ModuleNotFoundError: No module named 'catkin'
```

需要
```sh
source /opt/ros/noetic/setup.bash
```

2. rviz
```sh
root@4d57cc0d4f6d:/# rviz
qt.qpa.xcb: could not connect to display 
qt.qpa.plugin: Could not load the Qt platform plugin "xcb" in "" even though it was found.
This application failed to start because no Qt platform plugin could be initialized. Reinstalling the application may fix this problem.

Available platform plugins are: eglfs, linuxfb, minimal, minimalegl, offscreen, vnc, xcb.

Aborted (core dumped)
```

```sh
export DISPLAY=':0.0'
export QT_QPA_PLATFORM='offscreen'
```

```sh
root@4d57cc0d4f6d:/# rviz
QStandardPaths: XDG_RUNTIME_DIR not set, defaulting to '/tmp/runtime-root'
[ INFO] [1723450129.941338222]: rviz version 1.14.25
[ INFO] [1723450129.941430107]: compiled against Qt version 5.12.8
[ INFO] [1723450129.941442978]: compiled against OGRE version 1.9.0 (Ghadamon)
This plugin does not support propagateSizeHints()
```

```sh
export XDG_RUNTIME_DIR=/usr/lib/
```

```sh
root@4d57cc0d4f6d:/# rviz
[ INFO] [1723450161.886054817]: rviz version 1.14.25
[ INFO] [1723450161.886091140]: compiled against Qt version 5.12.8
[ INFO] [1723450161.886097594]: compiled against OGRE version 1.9.0 (Ghadamon)
This plugin does not support propagateSizeHints()
[ INFO] [1723450317.867662631]: Forcing OpenGl version 0.
[ WARN] [1723450318.494867208]: $DISPLAY is invalid, falling back on default :0
[FATAL] [1723450318.495006705]: Can't open default or :0 display. Try setting DISPLAY environment variable.
terminate called after throwing an instance of 'std::runtime_error'
  what():  Can't open default or :0 display!

Aborted (core dumped)
```

最后发现是创建容器时没有给权限导致。重新创建容器可解决

```sh
xhost +
docker run -it --privileged -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v /dev:/dev osrf/ros:noetic-desktop-full
roscore
rosrun rviz rviz
```

```sh
sudo vim ~/.bashrc
# 注释掉
# export QT_QPA_PLATFORM='offscreen'
```

[back](./)
