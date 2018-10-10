#include <mips/regdef.h>
#incllude <sys/syscall.h>

	.section .mdebug.abi32
	.previous
	.abicalls
	.text
	.align	2
	.globl	readc
	.ent	readc
readc:
	.frame	$fp,40,ra		# vars= 0, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	t9
	.set	reorder
	subu	sp,sp,40
	.cprestore 16
	sw	ra,32(sp)
	sw	$fp,28(sp)
	sw	gp,24(sp)
	move	$fp,sp
	sw	a0,40($fp)
	lw	a0,40($fp)
	la	a1,buffer
	li	a2,1			# 0x1
	syscall
	lb	v0,buffer
	move	sp,$fp
	lw	ra,32(sp)
	lw	$fp,28(sp)
	addu	sp,sp,40
	j	ra
	.end	readc
	.size	readc, .-readc

	.comm	buffer,4
	.ident	"GCC: (GNU) 3.3.3 (NetBSD nb3 20040520)"
