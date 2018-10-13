---
layout: default
---

//Author: channy

//Create Date: 2018-10-13 17:16:45

//Description: 

# Android_Build_Source

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

