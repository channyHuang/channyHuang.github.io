---
layout: default
---

//Author: channy

//Create Date: 2019-04-24 16:30:25

//Description: notes about how to publish qt execute files in linux machines without Qt 

# Prepare files
> Qt libraries
> Qt plugins/platforms
> other dependent files

# Set environment path
in ~/username/.bashrc file, add in the end:
```
# libraries needed in qt execute files, here I put them in /media/sf_LaneGen/libs
export LD_LIBRARY_PATH=/media/sf_LaneGen/libs:$LD_LIBRARY_PATH
# libraries of Qt
export LD_LIBRARY_PATH=/media/sf_LaneGen/libs/Qt5libs:$LD_LIBRARY_PATH
# plugins of Qt, without them it will cause error  This application failed to start because it could not find or load the Qt platform plugin "xcb" when running target execute files
export LD_LIBRARY_PATH=/media/sf_LaneGen/plugins/platforms:$LD_LIBRARY_PATH
```

Then do not forget to source .bashrc
```
source .bashrc
```

# Run target execute files
Here I catch another error, segmentation fault "已放弃 (核心已转储)", but it can run normally in another machine which installed Qt.

still looking for solutions...
[back](./)