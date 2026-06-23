---
layout: default
title: overthewire_wargames_notes_utumno
categories:
- Security
tags:
- Security
---
//Description: 通过wargame的utumno学习linux反编译笔记

//Create Date: 2020-02-27 16:29:58

//Author: channy

# overthewire_wargames_notes_utumno

[address](https://overthewire.org/wargames/utumno/)

> ssh -p2227 utumno0@utumno.labs.overthewire.org

```
utumno0@utumno:/utumno$ ls -lrht -a
total 84K
---s--x---  1 utumno1 utumno0 7.1K Aug 26 22:44 utumno0_hard
drwxr-xr-x 27 root    root    4.0K Aug 26 22:44 ..
---x--x---  1 utumno1 utumno0 7.1K Aug 26 22:44 utumno0
-r-sr-x---  1 utumno2 utumno1 7.9K Aug 26 22:44 utumno1
-r-sr-x---  1 utumno3 utumno2 7.4K Aug 26 22:44 utumno2
-r-sr-x---  1 utumno4 utumno3 7.3K Aug 26 22:44 utumno3
-r-sr-x---  1 utumno5 utumno4 7.5K Aug 26 22:44 utumno4
-r-sr-x---  1 utumno6 utumno5 7.8K Aug 26 22:44 utumno5
-r-sr-x---  1 utumno7 utumno6 8.0K Aug 26 22:44 utumno6
-r-sr-x---  1 utumno8 utumno7 8.4K Aug 26 22:44 utumno7
drwxr-xr-x  2 root    root    4.0K Aug 26 22:44 .
```

## 1.

```
utumno0@utumno:/utumno$ ./utumno0
Read me! :P
utumno0@utumno:/utumno$ ./utumno0_hard 
Read me! :P
```

[back](./)

