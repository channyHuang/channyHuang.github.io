---
layout: default
---

//Author: channy

//Create Date: 2018-10-13 17:16:45

//Description: 

# Android_Build_Source

## Audio 
> summarized by others

l         AudioTrack被new出来，然后set了一堆信息，同时会通过Binder机制调用另外一端的AudioFlinger，得到IAudioTrack对象，通过它和AudioFlinger交互。

l         调用start函数后，会启动一个线程专门做回调处理，代码里边也会有那种数据拷贝的回调，但是JNI层的回调函数实际并没有往里边写数据，大家只要看write就可以了

l         用户一次次得write，那AudioTrack无非就是把数据memcpy到共享buffer中咯

l         可想而知，AudioFlinger那一定有一个线程在memcpy数据到音频设备中去。我们拭目以待

---

l         在AudioTrack中，调用set函数

l         这个函数会通过AudioSystem::getOutput来得到一个output的句柄

l         AS的getOutput会调用AudioPolicyService的getOutput

l         然后我们就没继续讲APS的getOutPut了，而是去看看APS创建的东西

l         发现APS创建的时候会创建一个AudioManagerBase，这个AMB的创建又会调用APS的openOutput。

l         APS的openOutput又会调用AudioFlinger的openOutput

---

环形buffer
1. 写者的使用

我们集中到audio_track_cblk_t这个类，来看看写者是如何使用的。写者就是AudioTrack端，在这个类中，叫user

l         framesAvailable，看看是否有空余空间

l         buffer，获得写空间起始地址

l         stepUser，更新user的位置。

2. 读者的使用

读者是AF端，在这个类中加server。

l         framesReady，获得可读的位置

l         stepServer，更新读者的位置

---

l         AF创建了一个代表HAL对象的东西

l         APS创建了两个AudioCommandThread，一个用来处理命令，一个用来播放tone。我们还没看。

l         APS同时会创建AudioManagerBase，做为系统默认的音频管理

l         AMB集中管理了策略上面的事情，同时会在AF的openOutput中创建一个混音线程。同时，AMB会更新一些策略上的安排。

另外，我们分析的AMB是Generic的，但不同厂商可以实现自己的策略。例如我可以设置只要有耳机，所有类型声音都从耳机出。


## Android Build Source Code 
```
source build/envsetup.sh
lunch 
emulator
(emulator -logcat D)
(emulator -logcat V)


cd ../framework/base
mmm core/res/
mm -B


make snod


adb logcat -f ./log.txt

```

[back](./)

