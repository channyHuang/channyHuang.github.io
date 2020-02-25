---
layout: default
title: overthewire_wargames_notes_behemoth
categories:
- C++
tags:
- C++
---
//Description:

//Create Date: 2020-02-25 16:20:07

//Author: channy

# overthewire_wargames_notes_behemoth

反编译

[address](https://overthewire.org/wargames/behemoth/)

> ssh -p2221 behemoth0@behemoth.labs.overthewire.org

## 0.

```
behemoth0@behemoth:/behemoth$ ls -lrht
total 72K
-r-sr-x--- 1 behemoth1 behemoth0 5.8K Aug 26 22:16 behemoth0
-r-sr-x--- 1 behemoth2 behemoth1 5.0K Aug 26 22:16 behemoth1
-r-sr-x--- 1 behemoth3 behemoth2 7.4K Aug 26 22:16 behemoth2
-r-sr-x--- 1 behemoth4 behemoth3 5.1K Aug 26 22:16 behemoth3
-r-sr-x--- 1 behemoth5 behemoth4 7.4K Aug 26 22:16 behemoth4
-r-sr-x--- 1 behemoth6 behemoth5 7.7K Aug 26 22:16 behemoth5
-r-sr-x--- 1 behemoth7 behemoth6 7.4K Aug 26 22:16 behemoth6
-r-xr-x--- 1 behemoth7 behemoth6 7.4K Aug 26 22:16 behemoth6_reader
-r-sr-x--- 1 behemoth8 behemoth7 5.6K Aug 26 22:16 behemoth7
```

## 1.

```
behemoth0@behemoth:/behemoth$ ./behemoth0 
Password: 1234
Access denied..
behemoth0@behemoth:/behemoth$ ltrace ./behemoth0 
__libc_start_main(0x80485b1, 1, 0xffffd684, 0x8048680 <unfinished ...>
printf("Password: ")                             = 10
__isoc99_scanf(0x804874c, 0xffffd58b, 0xf7fc5000, 13Password: 1243
) = 1
strlen("OK^GSYBEX^Y")                            = 11
strcmp("1243", "eatmyshorts")                    = -1
puts("Access denied.."Access denied..
)                          = 16
+++ exited (status 0) +++
behemoth0@behemoth:/behemoth$ ./behemoth0 
Password: eatmyshorts
Access granted..
$ cat /etc/behemoth_pass/behemoth1
aesebootiv
```


[back](/)

