
shellcode:     file format elf64-x86-64


Disassembly of section .init:

0000000000000548 <_init>:
 548:	48 83 ec 08          	sub    $0x8,%rsp
 54c:	48 8b 05 95 0a 20 00 	mov    0x200a95(%rip),%rax        # 200fe8 <__gmon_start__>
 553:	48 85 c0             	test   %rax,%rax
 556:	74 02                	je     55a <_init+0x12>
 558:	ff d0                	callq  *%rax
 55a:	48 83 c4 08          	add    $0x8,%rsp
 55e:	c3                   	retq   

Disassembly of section .plt:

0000000000000560 <.plt>:
 560:	ff 35 52 0a 20 00    	pushq  0x200a52(%rip)        # 200fb8 <_GLOBAL_OFFSET_TABLE_+0x8>
 566:	ff 25 54 0a 20 00    	jmpq   *0x200a54(%rip)        # 200fc0 <_GLOBAL_OFFSET_TABLE_+0x10>
 56c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000000570 <__stack_chk_fail@plt>:
 570:	ff 25 52 0a 20 00    	jmpq   *0x200a52(%rip)        # 200fc8 <__stack_chk_fail@GLIBC_2.4>
 576:	68 00 00 00 00       	pushq  $0x0
 57b:	e9 e0 ff ff ff       	jmpq   560 <.plt>

0000000000000580 <execve@plt>:
 580:	ff 25 4a 0a 20 00    	jmpq   *0x200a4a(%rip)        # 200fd0 <execve@GLIBC_2.2.5>
 586:	68 01 00 00 00       	pushq  $0x1
 58b:	e9 d0 ff ff ff       	jmpq   560 <.plt>

Disassembly of section .plt.got:

0000000000000590 <__cxa_finalize@plt>:
 590:	ff 25 62 0a 20 00    	jmpq   *0x200a62(%rip)        # 200ff8 <__cxa_finalize@GLIBC_2.2.5>
 596:	66 90                	xchg   %ax,%ax

Disassembly of section .text:

00000000000005a0 <_start>:
 5a0:	31 ed                	xor    %ebp,%ebp
 5a2:	49 89 d1             	mov    %rdx,%r9
 5a5:	5e                   	pop    %rsi
 5a6:	48 89 e2             	mov    %rsp,%rdx
 5a9:	48 83 e4 f0          	and    $0xfffffffffffffff0,%rsp
 5ad:	50                   	push   %rax
 5ae:	54                   	push   %rsp
 5af:	4c 8d 05 ca 01 00 00 	lea    0x1ca(%rip),%r8        # 780 <__libc_csu_fini>
 5b6:	48 8d 0d 53 01 00 00 	lea    0x153(%rip),%rcx        # 710 <__libc_csu_init>
 5bd:	48 8d 3d e6 00 00 00 	lea    0xe6(%rip),%rdi        # 6aa <main>
 5c4:	ff 15 16 0a 20 00    	callq  *0x200a16(%rip)        # 200fe0 <__libc_start_main@GLIBC_2.2.5>
 5ca:	f4                   	hlt    
 5cb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

00000000000005d0 <deregister_tm_clones>:
 5d0:	48 8d 3d 39 0a 20 00 	lea    0x200a39(%rip),%rdi        # 201010 <__TMC_END__>
 5d7:	55                   	push   %rbp
 5d8:	48 8d 05 31 0a 20 00 	lea    0x200a31(%rip),%rax        # 201010 <__TMC_END__>
 5df:	48 39 f8             	cmp    %rdi,%rax
 5e2:	48 89 e5             	mov    %rsp,%rbp
 5e5:	74 19                	je     600 <deregister_tm_clones+0x30>
 5e7:	48 8b 05 ea 09 20 00 	mov    0x2009ea(%rip),%rax        # 200fd8 <_ITM_deregisterTMCloneTable>
 5ee:	48 85 c0             	test   %rax,%rax
 5f1:	74 0d                	je     600 <deregister_tm_clones+0x30>
 5f3:	5d                   	pop    %rbp
 5f4:	ff e0                	jmpq   *%rax
 5f6:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 5fd:	00 00 00 
 600:	5d                   	pop    %rbp
 601:	c3                   	retq   
 602:	0f 1f 40 00          	nopl   0x0(%rax)
 606:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 60d:	00 00 00 

0000000000000610 <register_tm_clones>:
 610:	48 8d 3d f9 09 20 00 	lea    0x2009f9(%rip),%rdi        # 201010 <__TMC_END__>
 617:	48 8d 35 f2 09 20 00 	lea    0x2009f2(%rip),%rsi        # 201010 <__TMC_END__>
 61e:	55                   	push   %rbp
 61f:	48 29 fe             	sub    %rdi,%rsi
 622:	48 89 e5             	mov    %rsp,%rbp
 625:	48 c1 fe 03          	sar    $0x3,%rsi
 629:	48 89 f0             	mov    %rsi,%rax
 62c:	48 c1 e8 3f          	shr    $0x3f,%rax
 630:	48 01 c6             	add    %rax,%rsi
 633:	48 d1 fe             	sar    %rsi
 636:	74 18                	je     650 <register_tm_clones+0x40>
 638:	48 8b 05 b1 09 20 00 	mov    0x2009b1(%rip),%rax        # 200ff0 <_ITM_registerTMCloneTable>
 63f:	48 85 c0             	test   %rax,%rax
 642:	74 0c                	je     650 <register_tm_clones+0x40>
 644:	5d                   	pop    %rbp
 645:	ff e0                	jmpq   *%rax
 647:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
 64e:	00 00 
 650:	5d                   	pop    %rbp
 651:	c3                   	retq   
 652:	0f 1f 40 00          	nopl   0x0(%rax)
 656:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 65d:	00 00 00 

0000000000000660 <__do_global_dtors_aux>:
 660:	80 3d a9 09 20 00 00 	cmpb   $0x0,0x2009a9(%rip)        # 201010 <__TMC_END__>
 667:	75 2f                	jne    698 <__do_global_dtors_aux+0x38>
 669:	48 83 3d 87 09 20 00 	cmpq   $0x0,0x200987(%rip)        # 200ff8 <__cxa_finalize@GLIBC_2.2.5>
 670:	00 
 671:	55                   	push   %rbp
 672:	48 89 e5             	mov    %rsp,%rbp
 675:	74 0c                	je     683 <__do_global_dtors_aux+0x23>
 677:	48 8b 3d 8a 09 20 00 	mov    0x20098a(%rip),%rdi        # 201008 <__dso_handle>
 67e:	e8 0d ff ff ff       	callq  590 <__cxa_finalize@plt>
 683:	e8 48 ff ff ff       	callq  5d0 <deregister_tm_clones>
 688:	c6 05 81 09 20 00 01 	movb   $0x1,0x200981(%rip)        # 201010 <__TMC_END__>
 68f:	5d                   	pop    %rbp
 690:	c3                   	retq   
 691:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
 698:	f3 c3                	repz retq 
 69a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)

00000000000006a0 <frame_dummy>:
 6a0:	55                   	push   %rbp
 6a1:	48 89 e5             	mov    %rsp,%rbp
 6a4:	5d                   	pop    %rbp
 6a5:	e9 66 ff ff ff       	jmpq   610 <register_tm_clones>

00000000000006aa <main>:
 6aa:	55                   	push   %rbp
 6ab:	48 89 e5             	mov    %rsp,%rbp
 6ae:	48 83 ec 30          	sub    $0x30,%rsp
 6b2:	89 7d dc             	mov    %edi,-0x24(%rbp)
 6b5:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
 6b9:	64 48 8b 04 25 28 00 	mov    %fs:0x28,%rax
 6c0:	00 00 
 6c2:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 6c6:	31 c0                	xor    %eax,%eax
 6c8:	48 8d 05 c5 00 00 00 	lea    0xc5(%rip),%rax        # 794 <_IO_stdin_used+0x4>
 6cf:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
 6d3:	48 c7 45 e8 00 00 00 	movq   $0x0,-0x18(%rbp)
 6da:	00 
 6db:	48 8d 45 e0          	lea    -0x20(%rbp),%rax
 6df:	ba 00 00 00 00       	mov    $0x0,%edx
 6e4:	48 89 c6             	mov    %rax,%rsi
 6e7:	48 8d 3d a6 00 00 00 	lea    0xa6(%rip),%rdi        # 794 <_IO_stdin_used+0x4>
 6ee:	e8 8d fe ff ff       	callq  580 <execve@plt>
 6f3:	b8 00 00 00 00       	mov    $0x0,%eax
 6f8:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
 6fc:	64 48 33 0c 25 28 00 	xor    %fs:0x28,%rcx
 703:	00 00 
 705:	74 05                	je     70c <main+0x62>
 707:	e8 64 fe ff ff       	callq  570 <__stack_chk_fail@plt>
 70c:	c9                   	leaveq 
 70d:	c3                   	retq   
 70e:	66 90                	xchg   %ax,%ax

0000000000000710 <__libc_csu_init>:
 710:	41 57                	push   %r15
 712:	41 56                	push   %r14
 714:	49 89 d7             	mov    %rdx,%r15
 717:	41 55                	push   %r13
 719:	41 54                	push   %r12
 71b:	4c 8d 25 8e 06 20 00 	lea    0x20068e(%rip),%r12        # 200db0 <__frame_dummy_init_array_entry>
 722:	55                   	push   %rbp
 723:	48 8d 2d 8e 06 20 00 	lea    0x20068e(%rip),%rbp        # 200db8 <__init_array_end>
 72a:	53                   	push   %rbx
 72b:	41 89 fd             	mov    %edi,%r13d
 72e:	49 89 f6             	mov    %rsi,%r14
 731:	4c 29 e5             	sub    %r12,%rbp
 734:	48 83 ec 08          	sub    $0x8,%rsp
 738:	48 c1 fd 03          	sar    $0x3,%rbp
 73c:	e8 07 fe ff ff       	callq  548 <_init>
 741:	48 85 ed             	test   %rbp,%rbp
 744:	74 20                	je     766 <__libc_csu_init+0x56>
 746:	31 db                	xor    %ebx,%ebx
 748:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
 74f:	00 
 750:	4c 89 fa             	mov    %r15,%rdx
 753:	4c 89 f6             	mov    %r14,%rsi
 756:	44 89 ef             	mov    %r13d,%edi
 759:	41 ff 14 dc          	callq  *(%r12,%rbx,8)
 75d:	48 83 c3 01          	add    $0x1,%rbx
 761:	48 39 dd             	cmp    %rbx,%rbp
 764:	75 ea                	jne    750 <__libc_csu_init+0x40>
 766:	48 83 c4 08          	add    $0x8,%rsp
 76a:	5b                   	pop    %rbx
 76b:	5d                   	pop    %rbp
 76c:	41 5c                	pop    %r12
 76e:	41 5d                	pop    %r13
 770:	41 5e                	pop    %r14
 772:	41 5f                	pop    %r15
 774:	c3                   	retq   
 775:	90                   	nop
 776:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 77d:	00 00 00 

0000000000000780 <__libc_csu_fini>:
 780:	f3 c3                	repz retq 

Disassembly of section .fini:

0000000000000784 <_fini>:
 784:	48 83 ec 08          	sub    $0x8,%rsp
 788:	48 83 c4 08          	add    $0x8,%rsp
 78c:	c3                   	retq   
