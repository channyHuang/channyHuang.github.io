
shellcodeTest:     file format elf64-x86-64


Disassembly of section .init:

00000000000004b8 <_init>:
 4b8:	48 83 ec 08          	sub    $0x8,%rsp
 4bc:	48 8b 05 25 0b 20 00 	mov    0x200b25(%rip),%rax        # 200fe8 <__gmon_start__>
 4c3:	48 85 c0             	test   %rax,%rax
 4c6:	74 02                	je     4ca <_init+0x12>
 4c8:	ff d0                	callq  *%rax
 4ca:	48 83 c4 08          	add    $0x8,%rsp
 4ce:	c3                   	retq   

Disassembly of section .plt:

00000000000004d0 <.plt>:
 4d0:	ff 35 f2 0a 20 00    	pushq  0x200af2(%rip)        # 200fc8 <_GLOBAL_OFFSET_TABLE_+0x8>
 4d6:	ff 25 f4 0a 20 00    	jmpq   *0x200af4(%rip)        # 200fd0 <_GLOBAL_OFFSET_TABLE_+0x10>
 4dc:	0f 1f 40 00          	nopl   0x0(%rax)

Disassembly of section .plt.got:

00000000000004e0 <__cxa_finalize@plt>:
 4e0:	ff 25 12 0b 20 00    	jmpq   *0x200b12(%rip)        # 200ff8 <__cxa_finalize@GLIBC_2.2.5>
 4e6:	66 90                	xchg   %ax,%ax

Disassembly of section .text:

00000000000004f0 <_start>:
 4f0:	31 ed                	xor    %ebp,%ebp
 4f2:	49 89 d1             	mov    %rdx,%r9
 4f5:	5e                   	pop    %rsi
 4f6:	48 89 e2             	mov    %rsp,%rdx
 4f9:	48 83 e4 f0          	and    $0xfffffffffffffff0,%rsp
 4fd:	50                   	push   %rax
 4fe:	54                   	push   %rsp
 4ff:	4c 8d 05 9a 01 00 00 	lea    0x19a(%rip),%r8        # 6a0 <__libc_csu_fini>
 506:	48 8d 0d 23 01 00 00 	lea    0x123(%rip),%rcx        # 630 <__libc_csu_init>
 50d:	48 8d 3d e6 00 00 00 	lea    0xe6(%rip),%rdi        # 5fa <main>
 514:	ff 15 c6 0a 20 00    	callq  *0x200ac6(%rip)        # 200fe0 <__libc_start_main@GLIBC_2.2.5>
 51a:	f4                   	hlt    
 51b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

0000000000000520 <deregister_tm_clones>:
 520:	48 8d 3d 31 0b 20 00 	lea    0x200b31(%rip),%rdi        # 201058 <__TMC_END__>
 527:	55                   	push   %rbp
 528:	48 8d 05 29 0b 20 00 	lea    0x200b29(%rip),%rax        # 201058 <__TMC_END__>
 52f:	48 39 f8             	cmp    %rdi,%rax
 532:	48 89 e5             	mov    %rsp,%rbp
 535:	74 19                	je     550 <deregister_tm_clones+0x30>
 537:	48 8b 05 9a 0a 20 00 	mov    0x200a9a(%rip),%rax        # 200fd8 <_ITM_deregisterTMCloneTable>
 53e:	48 85 c0             	test   %rax,%rax
 541:	74 0d                	je     550 <deregister_tm_clones+0x30>
 543:	5d                   	pop    %rbp
 544:	ff e0                	jmpq   *%rax
 546:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 54d:	00 00 00 
 550:	5d                   	pop    %rbp
 551:	c3                   	retq   
 552:	0f 1f 40 00          	nopl   0x0(%rax)
 556:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 55d:	00 00 00 

0000000000000560 <register_tm_clones>:
 560:	48 8d 3d f1 0a 20 00 	lea    0x200af1(%rip),%rdi        # 201058 <__TMC_END__>
 567:	48 8d 35 ea 0a 20 00 	lea    0x200aea(%rip),%rsi        # 201058 <__TMC_END__>
 56e:	55                   	push   %rbp
 56f:	48 29 fe             	sub    %rdi,%rsi
 572:	48 89 e5             	mov    %rsp,%rbp
 575:	48 c1 fe 03          	sar    $0x3,%rsi
 579:	48 89 f0             	mov    %rsi,%rax
 57c:	48 c1 e8 3f          	shr    $0x3f,%rax
 580:	48 01 c6             	add    %rax,%rsi
 583:	48 d1 fe             	sar    %rsi
 586:	74 18                	je     5a0 <register_tm_clones+0x40>
 588:	48 8b 05 61 0a 20 00 	mov    0x200a61(%rip),%rax        # 200ff0 <_ITM_registerTMCloneTable>
 58f:	48 85 c0             	test   %rax,%rax
 592:	74 0c                	je     5a0 <register_tm_clones+0x40>
 594:	5d                   	pop    %rbp
 595:	ff e0                	jmpq   *%rax
 597:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
 59e:	00 00 
 5a0:	5d                   	pop    %rbp
 5a1:	c3                   	retq   
 5a2:	0f 1f 40 00          	nopl   0x0(%rax)
 5a6:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 5ad:	00 00 00 

00000000000005b0 <__do_global_dtors_aux>:
 5b0:	80 3d a0 0a 20 00 00 	cmpb   $0x0,0x200aa0(%rip)        # 201057 <_edata>
 5b7:	75 2f                	jne    5e8 <__do_global_dtors_aux+0x38>
 5b9:	48 83 3d 37 0a 20 00 	cmpq   $0x0,0x200a37(%rip)        # 200ff8 <__cxa_finalize@GLIBC_2.2.5>
 5c0:	00 
 5c1:	55                   	push   %rbp
 5c2:	48 89 e5             	mov    %rsp,%rbp
 5c5:	74 0c                	je     5d3 <__do_global_dtors_aux+0x23>
 5c7:	48 8b 3d 3a 0a 20 00 	mov    0x200a3a(%rip),%rdi        # 201008 <__dso_handle>
 5ce:	e8 0d ff ff ff       	callq  4e0 <__cxa_finalize@plt>
 5d3:	e8 48 ff ff ff       	callq  520 <deregister_tm_clones>
 5d8:	c6 05 78 0a 20 00 01 	movb   $0x1,0x200a78(%rip)        # 201057 <_edata>
 5df:	5d                   	pop    %rbp
 5e0:	c3                   	retq   
 5e1:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
 5e8:	f3 c3                	repz retq 
 5ea:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)

00000000000005f0 <frame_dummy>:
 5f0:	55                   	push   %rbp
 5f1:	48 89 e5             	mov    %rsp,%rbp
 5f4:	5d                   	pop    %rbp
 5f5:	e9 66 ff ff ff       	jmpq   560 <register_tm_clones>

00000000000005fa <main>:
 5fa:	55                   	push   %rbp
 5fb:	48 89 e5             	mov    %rsp,%rbp
 5fe:	89 7d ec             	mov    %edi,-0x14(%rbp)
 601:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
 605:	48 8d 45 f8          	lea    -0x8(%rbp),%rax
 609:	48 83 c0 10          	add    $0x10,%rax
 60d:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 611:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 615:	48 8d 15 04 0a 20 00 	lea    0x200a04(%rip),%rdx        # 201020 <code>
 61c:	48 89 10             	mov    %rdx,(%rax)
 61f:	90                   	nop
 620:	5d                   	pop    %rbp
 621:	c3                   	retq   
 622:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 629:	00 00 00 
 62c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000000630 <__libc_csu_init>:
 630:	41 57                	push   %r15
 632:	41 56                	push   %r14
 634:	49 89 d7             	mov    %rdx,%r15
 637:	41 55                	push   %r13
 639:	41 54                	push   %r12
 63b:	4c 8d 25 ae 07 20 00 	lea    0x2007ae(%rip),%r12        # 200df0 <__frame_dummy_init_array_entry>
 642:	55                   	push   %rbp
 643:	48 8d 2d ae 07 20 00 	lea    0x2007ae(%rip),%rbp        # 200df8 <__init_array_end>
 64a:	53                   	push   %rbx
 64b:	41 89 fd             	mov    %edi,%r13d
 64e:	49 89 f6             	mov    %rsi,%r14
 651:	4c 29 e5             	sub    %r12,%rbp
 654:	48 83 ec 08          	sub    $0x8,%rsp
 658:	48 c1 fd 03          	sar    $0x3,%rbp
 65c:	e8 57 fe ff ff       	callq  4b8 <_init>
 661:	48 85 ed             	test   %rbp,%rbp
 664:	74 20                	je     686 <__libc_csu_init+0x56>
 666:	31 db                	xor    %ebx,%ebx
 668:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
 66f:	00 
 670:	4c 89 fa             	mov    %r15,%rdx
 673:	4c 89 f6             	mov    %r14,%rsi
 676:	44 89 ef             	mov    %r13d,%edi
 679:	41 ff 14 dc          	callq  *(%r12,%rbx,8)
 67d:	48 83 c3 01          	add    $0x1,%rbx
 681:	48 39 dd             	cmp    %rbx,%rbp
 684:	75 ea                	jne    670 <__libc_csu_init+0x40>
 686:	48 83 c4 08          	add    $0x8,%rsp
 68a:	5b                   	pop    %rbx
 68b:	5d                   	pop    %rbp
 68c:	41 5c                	pop    %r12
 68e:	41 5d                	pop    %r13
 690:	41 5e                	pop    %r14
 692:	41 5f                	pop    %r15
 694:	c3                   	retq   
 695:	90                   	nop
 696:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 69d:	00 00 00 

00000000000006a0 <__libc_csu_fini>:
 6a0:	f3 c3                	repz retq 

Disassembly of section .fini:

00000000000006a4 <_fini>:
 6a4:	48 83 ec 08          	sub    $0x8,%rsp
 6a8:	48 83 c4 08          	add    $0x8,%rsp
 6ac:	c3                   	retq   
