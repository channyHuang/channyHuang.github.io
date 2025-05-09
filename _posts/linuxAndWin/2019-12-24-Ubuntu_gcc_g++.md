---
layout: default
title: Ubuntu_gcc_g++
categories:
- Linux
tags:
- Linux
- Command
---
//Description: 记录在ubuntu下编写c++工程代码遇到的问题。如链接了所有用到的库却依旧报`undefined reference to`错误，最后发现是链接顺序问题。

//Create Date: 2019-12-24 10:25:19

//Author: channy

# Ubuntu 18.04安装gcc、g++ 4.8
```
sudo apt-get install gcc-4.8 g++-4.8

sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 100
sudo update-alternatives --config gcc

sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 100
sudo update-alternatives --config g++
```

# 编译
## 编译中的undefined reference问题

在Ubuntu使用AirSim的过程中，遇到了一直编译不过的问题，报错中有`undefined reference to`字样。
```sh
/usr/bin/ld: RpcLibClientBase.cpp:(.text._ZN3rpc6client10async_callIJNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEES7_fS7_bEEESt6futureIN14clmdep_msgpack2v113object_handleEERKS7_DpT_[_ZN3rpc6client10async_callIJNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEES7_fS7_bEEESt6futureIN14clmdep_msgpack2v113object_handleEERKS7_DpT_]+0x1b1): undefined reference to `rpc::client::post(std::shared_ptr<clmdep_msgpack::v1::sbuffer>, int, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, std::shared_ptr<std::promise<clmdep_msgpack::v1::object_handle> >)'
/usr/bin/ld: /home/channy/Documents/thirdlibs/AirSim/build_release/output/lib/libAirLib.a(RpcLibClientBase.cpp.o): in function `std::future<clmdep_msgpack::v1::object_handle> rpc::client::async_call<msr::airlib_rpclib::RpcLibAdaptorsBase::Vector3r, int, int, int, float, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, msr::airlib_rpclib::RpcLibAdaptorsBase::Vector3r, int, int, int, float, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >)':
```

确认了AirSim正常编译没有报错且在output文件夹下正常生成了三个`.a`文件。

单独测试rpc生成的静态库文件能够正常通信。

使用AirSim的工程也链接了三个库
```sh
target_link_libraries(${projectName} 
    ${OPENSCENEGRAPH_LIBRARIES}
    ${OpenCV_LIBS}
    #${PCL_LIBRARIES}
    imgui
    rpc
    MavLinkCom
    AirLib
    glfw
)
```

最后发现是链接的顺序问题。和一般的从小到大思维不一样，依赖其他库的库一定要放到被依赖库的前面，才不会报`undefined reference to`的错误。

# 没网linux机器共享其他linux上网机器的wifi
需求：
1. 一台没法上网的linux机器，如刚重装系统，没有有线环境，缺少依赖库安装不上无线驱动等
2. 一台能用wifi正常上网的linux机器
3. 两台机器能够用网线直连，设置同网段静态ip后能够ping通
步骤：
1. linux wifi上网机创建脚本`ipForward.sh`
```sh
#!/bin/bash

sysctl net.ipv4.ip_forward=1

iptables -t nat -A POSTROUTING -o wlp3s0 -j MASQUERADE
```

其中`-o`后接无线网卡的设备名，可通过`ip addr`查看

2. 运行`sudo ./ipForward.sh`
3. 设置上网机有线网络静态ip，记下ip地址
4. 没网的机器设置静态网络，网关设为上网机的ip地址，DNS可以设置为8.8.8.8也可以不设置
