	.file	1 "main.c"
	.section .mdebug.abi32
	.previous
	.abicalls
	.globl	HELP
	.rdata
	.align	2
	.type	HELP, @object
	.size	HELP, 231
HELP:
	.ascii	"Usage:\n"
	.ascii	" tp0 -h \n"
	.ascii	" tp0 -V \n"
	.ascii	" tp0 [options] \n"
	.ascii	" Options: \n"
	.ascii	" -V, --version Print version and quit. \n"
	.ascii	" -h, --help Print this information. \n"
	.ascii	" -i, --input Location of the input file. \n"
	.ascii	" -a, --action Program action: encode (default) or decode"
	.ascii	". \n\000"
	.globl	VERSION
	.align	2
	.type	VERSION, @object
	.size	VERSION, 12
VERSION:
	.ascii	"2018.9.25 \n\000"
	.align	2
$LC0:
	.ascii	"version\000"
	.align	2
$LC1:
	.ascii	"help\000"
	.align	2
$LC2:
	.ascii	"input\000"
	.align	2
$LC3:
	.ascii	"output\000"
	.align	2
$LC4:
	.ascii	"action\000"
	.data
	.align	2
	.type	long_options.0, @object
	.size	long_options.0, 96
long_options.0:
	.word	$LC0
	.word	0
	.word	0
	.word	0
	.word	$LC1
	.word	0
	.word	0
	.word	0
	.word	$LC2
	.word	2
	.word	0
	.word	0
	.word	$LC3
	.word	2
	.word	0
	.word	0
	.word	$LC4
	.word	2
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.rdata
	.align	2
$LC5:
	.ascii	"Vha:i:o:\000"
	.align	2
$LC6:
	.ascii	"encode\000"
	.align	2
$LC7:
	.ascii	"decode\000"
	.align	2
$LC8:
	.ascii	"-\000"
	.align	2
$LC9:
	.ascii	"r\000"
	.align	2
$LC10:
	.ascii	"File not found \n\000"
	.align	2
$LC11:
	.ascii	"w\000"
	.text
	.align	2
	.globl	main
	.ent	main
main:
	.frame	$fp,80,$ra		# vars= 32, regs= 3/0, args= 24, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,80
	.cprestore 24
	sw	$ra,72($sp)
	sw	$fp,68($sp)
	sw	$gp,64($sp)
	move	$fp,$sp
	sw	$a0,80($fp)
	sw	$a1,84($fp)
	la	$v0,__sF
	sw	$v0,36($fp)
	la	$v0,__sF+88
	sw	$v0,40($fp)
	lw	$v0,84($fp)
	sw	$v0,44($fp)
	sw	$zero,48($fp)
	li	$v0,1			# 0x1
	sb	$v0,52($fp)
$L18:
	addu	$v0,$fp,48
	sw	$v0,16($sp)
	lw	$a0,80($fp)
	lw	$a1,44($fp)
	la	$a2,$LC5
	la	$a3,long_options.0
	la	$t9,getopt_long
	jal	$ra,$t9
	sw	$v0,32($fp)
	lw	$v1,32($fp)
	li	$v0,-1			# 0xffffffffffffffff
	bne	$v1,$v0,$L20
	b	$L19
$L20:
	lw	$v0,32($fp)
	sw	$v0,60($fp)
	li	$v0,104			# 0x68
	lw	$v1,60($fp)
	beq	$v1,$v0,$L22
	lw	$v1,60($fp)
	slt	$v0,$v1,105
	beq	$v0,$zero,$L36
	li	$v0,86			# 0x56
	lw	$v1,60($fp)
	beq	$v1,$v0,$L23
	lw	$v1,60($fp)
	slt	$v0,$v1,87
	beq	$v0,$zero,$L37
	lw	$v0,60($fp)
	beq	$v0,$zero,$L33
	b	$L18
$L37:
	li	$v0,97			# 0x61
	lw	$v1,60($fp)
	beq	$v1,$v0,$L24
	b	$L18
$L36:
	li	$v0,105			# 0x69
	lw	$v1,60($fp)
	beq	$v1,$v0,$L27
	li	$v0,111			# 0x6f
	lw	$v1,60($fp)
	beq	$v1,$v0,$L30
	b	$L18
$L22:
	la	$a0,__sF+88
	la	$a1,HELP
	la	$t9,fprintf
	jal	$ra,$t9
	sw	$zero,56($fp)
	b	$L17
$L23:
	la	$a0,__sF+88
	la	$a1,VERSION
	la	$t9,fprintf
	jal	$ra,$t9
	sw	$zero,56($fp)
	b	$L17
$L24:
	lw	$a0,optarg
	la	$a1,$LC6
	la	$t9,strcmp
	jal	$ra,$t9
	bne	$v0,$zero,$L25
	b	$L18
$L25:
	lw	$a0,optarg
	la	$a1,$LC7
	la	$t9,strcmp
	jal	$ra,$t9
	bne	$v0,$zero,$L27
	sb	$zero,52($fp)
	b	$L18
$L27:
	lw	$a0,optarg
	la	$a1,$LC8
	la	$t9,strcmp
	jal	$ra,$t9
	bne	$v0,$zero,$L28
	b	$L18
$L28:
	lw	$a0,optarg
	la	$a1,$LC9
	la	$t9,fopen
	jal	$ra,$t9
	sw	$v0,36($fp)
	lw	$v0,36($fp)
	bne	$v0,$zero,$L18
	la	$a0,__sF+176
	la	$a1,$LC10
	la	$t9,fprintf
	jal	$ra,$t9
	li	$v0,1			# 0x1
	sw	$v0,56($fp)
	b	$L17
$L30:
	lw	$a0,optarg
	la	$a1,$LC8
	la	$t9,strcmp
	jal	$ra,$t9
	bne	$v0,$zero,$L31
	b	$L18
$L31:
	lw	$a0,optarg
	la	$a1,$LC11
	la	$t9,fopen
	jal	$ra,$t9
	sw	$v0,40($fp)
	lw	$v0,40($fp)
	bne	$v0,$zero,$L18
	la	$a0,__sF+176
	la	$a1,$LC10
	la	$t9,fprintf
	jal	$ra,$t9
	li	$v1,1			# 0x1
	sw	$v1,56($fp)
	b	$L17
$L33:
	la	$t9,abort
	jal	$ra,$t9
$L19:
	lbu	$v0,52($fp)
	beq	$v0,$zero,$L38
	lw	$a0,36($fp)
	lw	$a1,40($fp)
	la	$t9,encode
	jal	$ra,$t9
	b	$L39
$L38:
	lw	$a0,36($fp)
	lw	$a1,40($fp)
	la	$t9,decode
	jal	$ra,$t9
$L39:
	lw	$a0,36($fp)
	la	$t9,fclose
	jal	$ra,$t9
	lw	$a0,40($fp)
	la	$t9,fclose
	jal	$ra,$t9
	sw	$zero,56($fp)
$L17:
	lw	$v0,56($fp)
	move	$sp,$fp
	lw	$ra,72($sp)
	lw	$fp,68($sp)
	addu	$sp,$sp,80
	j	$ra
	.end	main
	.size	main, .-main
	.ident	"GCC: (GNU) 3.3.3 (NetBSD nb3 20040520)"
