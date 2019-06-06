---
layout: default
---

//Author: channy

//Create Date: 2019-04-24 16:30:25

//Description: notes about how to publish qt execute files in linux machines without Qt 

# Normal Method
## Prepare files
> Qt libraries
> Qt plugins/platforms, put platforms, imageformats and others in the same folder with target files
> other dependent files

## Set environment path
in ~/username/.bashrc file, add in the end:
```
# libraries needed in qt execute files, here I put them in /media/sf_LaneGen/libs
export LD_LIBRARY_PATH=/media/sf_LaneGen/lib:$LD_LIBRARY_PATH
# libraries of Qt
export LD_LIBRARY_PATH=/media/sf_LaneGen/libs/libQt5:$LD_LIBRARY_PATH
```

Then do not forget to source .bashrc
```
source .bashrc
```

## Run target execute files
Here I catch another error, segmentation fault "已放弃 (核心已转储)", but it can run normally in another machine which installed Qt.

The reason is that I build it with super permission, so it can't be start normally without root permission.

here can set QT_DEBUG_PLUGINS=1 to debug which plugin cause such issue
```
export QT_DEBUG_PLUGINS=1
# run target execute file
./xxx 
```

There is also another reason will cause this error "Segmentation fault", that is the qt library in target PC is not the same as the compiling PC. This can auso use `QT_DEBUG_PLUGINS=1` to locate where the problem is.

# Optimize Method
## Write install files
```
```
[back](./)
