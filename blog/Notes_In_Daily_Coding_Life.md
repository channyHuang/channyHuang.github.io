---
layout: default
---

//Author: channy

//Create Date: 2019-04-24 16:59:35

//Description: Just some notes in daily coding life

# set PC to auto start  
```
at 00:00 /every:M,T,W,Th,F,S,Su shutdown -s -t 120

at /delete
```

# add share folder to VirtualBox but without permission
```
sudo usermod -aG vboxsf $(username)
```

# pyinstall error str object has no attribute items

As other python error, the version of libraries do not match.

Update setuptools to version 40+, solved

用pyinstaller把脚本转化成exe时报错，升级setuptools到40+版本后解决~

[back](./)
