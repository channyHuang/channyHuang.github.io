---
layout: default
title: overthewire_wargames_notes_behemoth
categories:
- C++
tags:
- C++
---
//Description: linux下的反编译，通过wargames学习的笔记

//Create Date: 2020-03-25 16:20:07

//Author: channy

# overthewire_wargames_notes_behemoth

相比于narnia, 没有源码，反编译

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

## 2. 

```
(gdb) disassemble main
Dump of assembler code for function main:
   0x0804844b <+0>:	push   %ebp
   0x0804844c <+1>:	mov    %esp,%ebp
   0x0804844e <+3>:	sub    $0x44,%esp
   0x08048451 <+6>:	push   $0x8048500
   0x08048456 <+11>:	call   0x8048300 <printf@plt>
   0x0804845b <+16>:	add    $0x4,%esp
   0x0804845e <+19>:	lea    -0x43(%ebp),%eax
   0x08048461 <+22>:	push   %eax
   0x08048462 <+23>:	call   0x8048310 <gets@plt>
   0x08048467 <+28>:	add    $0x4,%esp
   0x0804846a <+31>:	push   $0x804850c
   0x0804846f <+36>:	call   0x8048320 <puts@plt>
   0x08048474 <+41>:	add    $0x4,%esp
   0x08048477 <+44>:	mov    $0x0,%eax
   0x0804847c <+49>:	leave  
   0x0804847d <+50>:	ret    
End of assembler dump.
```

从逆向出来的汇编代码看，程序很简单，使用gets()得到用户输入，然后puts()输出"Authentication failure.\nSorry."提示结束就可以了，没有匹配，也就是没有正确的密码。不过从gets()这是一个不安全的函数，这里也没有边界检查，说明存在缓冲区溢出漏洞，这是可以利用的。

服务器的shellcode.s
```
//shellcode.s
00000000000006b0 <main>:                                                                        
 6b0:   55                      push   %rbp
 6b1:   48 89 e5                mov    %rsp,%rbp
 6b4:   48 83 ec 20             sub    $0x20,%rsp
 6b8:   89 7d ec                mov    %edi,-0x14(%rbp)
 6bb:   48 89 75 e0             mov    %rsi,-0x20(%rbp)
 6bf:   48 8d 05 be 00 00 00    lea    0xbe(%rip),%rax        # 784 <_IO_stdin_used+0x4>
 6c6:   48 89 45 f0             mov    %rax,-0x10(%rbp)
 6ca:   48 c7 45 f8 00 00 00    movq   $0x0,-0x8(%rbp)
 6d1:   00  
 6d2:   48 8b 45 f0             mov    -0x10(%rbp),%rax
 6d6:   48 8d 4d f0             lea    -0x10(%rbp),%rcx
 6da:   ba 00 00 00 00          mov    $0x0,%edx
 6df:   48 89 ce                mov    %rcx,%rsi
 6e2:   48 89 c7                mov    %rax,%rdi
 6e5:   e8 76 fe ff ff          callq  560 <execve@plt>
 6ea:   b8 00 00 00 00          mov    $0x0,%eax
 6ef:   c9                      leaveq     
 6f0:   c3                      retq   
 6f1:   66 2e 0f 1f 84 00 00    nopw   %cs:0x0(%rax,%rax,1)
 6f8:   00 00 00  
 6fb:   0f 1f 44 00 00          nopl   0x0(%rax,%rax,1)
```

## 3. 

## 4.

## 5.

## 6.

## 7.

## 8.

[back](./)

