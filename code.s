	.file	1 "code.c"
	.section .mdebug.abi32
	.previous
	.abicalls
	.globl	B64
	.rdata
	.align	2
	.type	B64, @object
	.size	B64, 64
B64:
	.byte	65
	.byte	66
	.byte	67
	.byte	68
	.byte	69
	.byte	70
	.byte	71
	.byte	72
	.byte	73
	.byte	74
	.byte	75
	.byte	76
	.byte	77
	.byte	78
	.byte	79
	.byte	80
	.byte	81
	.byte	82
	.byte	83
	.byte	84
	.byte	85
	.byte	86
	.byte	87
	.byte	88
	.byte	89
	.byte	90
	.byte	97
	.byte	98
	.byte	99
	.byte	100
	.byte	101
	.byte	102
	.byte	103
	.byte	104
	.byte	105
	.byte	106
	.byte	107
	.byte	108
	.byte	109
	.byte	110
	.byte	111
	.byte	112
	.byte	113
	.byte	114
	.byte	115
	.byte	116
	.byte	117
	.byte	118
	.byte	119
	.byte	120
	.byte	121
	.byte	122
	.byte	48
	.byte	49
	.byte	50
	.byte	51
	.byte	52
	.byte	53
	.byte	54
	.byte	55
	.byte	56
	.byte	57
	.byte	43
	.byte	47
	.align	2
$LC0:
	.ascii	"%c\000"
	.align	2
$LC1:
	.ascii	"=\000"
	.align	2
$LC2:
	.ascii	"==\000"
	.text
	.align	2
	.globl	encode
	.ent	encode
encode:
	.frame	$fp,88,$ra		# vars= 48, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,88
	.cprestore 16
	sw	$ra,80($sp)
	sw	$fp,76($sp)
	sw	$gp,72($sp)
	move	$fp,$sp
	sw	$a0,88($fp)
	sw	$a1,92($fp)
	li	$v0,-4			# 0xfffffffffffffffc
	sb	$v0,24($fp)
	li	$v0,3			# 0x3
	sb	$v0,25($fp)
	li	$v0,-16			# 0xfffffffffffffff0
	sb	$v0,26($fp)
	li	$v0,15			# 0xf
	sb	$v0,27($fp)
	li	$v0,-64			# 0xffffffffffffffc0
	sb	$v0,28($fp)
	li	$v0,63			# 0x3f
	sb	$v0,29($fp)
	sw	$zero,32($fp)
	lw	$a0,88($fp)
	la	$t9,fgetc
	jal	$ra,$t9
	sw	$v0,60($fp)
$L18:
	lw	$v1,60($fp)
	li	$v0,-1			# 0xffffffffffffffff
	bne	$v1,$v0,$L20
	b	$L19
$L20:
	lbu	$v0,60($fp)
	sb	$v0,64($fp)
	lw	$v0,32($fp)
	bne	$v0,$zero,$L21
	lbu	$v1,64($fp)
	lbu	$v0,24($fp)
	and	$v0,$v1,$v0
	andi	$v0,$v0,0x00ff
	sw	$v0,36($fp)
	lw	$v0,36($fp)
	sra	$v0,$v0,2
	sw	$v0,36($fp)
	lbu	$v1,64($fp)
	lbu	$v0,25($fp)
	and	$v0,$v1,$v0
	andi	$v0,$v0,0x00ff
	sw	$v0,40($fp)
	lbu	$v0,40($fp)
	sll	$v0,$v0,4
	sw	$v0,40($fp)
	lw	$v0,32($fp)
	addu	$v0,$v0,1
	sw	$v0,32($fp)
	lw	$v1,36($fp)
	la	$v0,B64
	addu	$v0,$v1,$v0
	lb	$v0,0($v0)
	lw	$a0,92($fp)
	la	$a1,$LC0
	move	$a2,$v0
	la	$t9,fprintf
	jal	$ra,$t9
	lw	$a0,88($fp)
	la	$t9,fgetc
	jal	$ra,$t9
	sw	$v0,60($fp)
	b	$L18
$L21:
	lw	$v1,32($fp)
	li	$v0,1			# 0x1
	bne	$v1,$v0,$L22
	lbu	$v1,64($fp)
	lbu	$v0,26($fp)
	and	$v0,$v1,$v0
	andi	$v0,$v0,0x00ff
	sw	$v0,44($fp)
	lw	$v0,44($fp)
	sra	$v0,$v0,4
	sw	$v0,44($fp)
	lw	$v1,44($fp)
	lw	$v0,40($fp)
	or	$v0,$v1,$v0
	sw	$v0,44($fp)
	lbu	$v1,64($fp)
	lbu	$v0,27($fp)
	and	$v0,$v1,$v0
	andi	$v0,$v0,0x00ff
	sw	$v0,48($fp)
	lbu	$v0,48($fp)
	sll	$v0,$v0,2
	sw	$v0,48($fp)
	lw	$v0,32($fp)
	addu	$v0,$v0,1
	sw	$v0,32($fp)
	lw	$v1,44($fp)
	la	$v0,B64
	addu	$v0,$v1,$v0
	lb	$v0,0($v0)
	lw	$a0,92($fp)
	la	$a1,$LC0
	move	$a2,$v0
	la	$t9,fprintf
	jal	$ra,$t9
	lw	$a0,88($fp)
	la	$t9,fgetc
	jal	$ra,$t9
	sw	$v0,60($fp)
	b	$L18
$L22:
	lw	$v1,32($fp)
	li	$v0,2			# 0x2
	bne	$v1,$v0,$L18
	lbu	$v1,64($fp)
	lbu	$v0,28($fp)
	and	$v0,$v1,$v0
	andi	$v0,$v0,0x00ff
	sw	$v0,52($fp)
	lw	$v0,52($fp)
	sra	$v0,$v0,6
	sw	$v0,52($fp)
	lw	$v1,52($fp)
	lw	$v0,48($fp)
	or	$v0,$v1,$v0
	sw	$v0,52($fp)
	lbu	$v1,64($fp)
	lbu	$v0,29($fp)
	and	$v0,$v1,$v0
	andi	$v0,$v0,0x00ff
	sw	$v0,56($fp)
	sw	$zero,32($fp)
	lw	$v1,52($fp)
	la	$v0,B64
	addu	$v0,$v1,$v0
	lb	$v0,0($v0)
	lw	$a0,92($fp)
	la	$a1,$LC0
	move	$a2,$v0
	la	$t9,fprintf
	jal	$ra,$t9
	lw	$v1,56($fp)
	la	$v0,B64
	addu	$v0,$v1,$v0
	lb	$v0,0($v0)
	lw	$a0,92($fp)
	la	$a1,$LC0
	move	$a2,$v0
	la	$t9,fprintf
	jal	$ra,$t9
	lw	$a0,88($fp)
	la	$t9,fgetc
	jal	$ra,$t9
	sw	$v0,60($fp)
	b	$L18
$L19:
	lw	$v0,32($fp)
	sw	$v0,68($fp)
	li	$v0,1			# 0x1
	lw	$v1,68($fp)
	beq	$v1,$v0,$L26
	li	$v0,2			# 0x2
	lw	$v1,68($fp)
	beq	$v1,$v0,$L25
	b	$L17
$L25:
	lw	$v1,48($fp)
	la	$v0,B64
	addu	$v0,$v1,$v0
	lb	$v0,0($v0)
	lw	$a0,92($fp)
	la	$a1,$LC0
	move	$a2,$v0
	la	$t9,fprintf
	jal	$ra,$t9
	lw	$a0,92($fp)
	la	$a1,$LC1
	la	$t9,fprintf
	jal	$ra,$t9
	b	$L17
$L26:
	lw	$v1,40($fp)
	la	$v0,B64
	addu	$v0,$v1,$v0
	lb	$v0,0($v0)
	lw	$a0,92($fp)
	la	$a1,$LC0
	move	$a2,$v0
	la	$t9,fprintf
	jal	$ra,$t9
	lw	$a0,92($fp)
	la	$a1,$LC2
	la	$t9,fprintf
	jal	$ra,$t9
$L17:
	move	$sp,$fp
	lw	$ra,80($sp)
	lw	$fp,76($sp)
	addu	$sp,$sp,88
	j	$ra
	.end	encode
	.size	encode, .-encode
	.align	2
	.globl	get_i64
	.ent	get_i64
get_i64:
	.frame	$fp,32,$ra		# vars= 16, regs= 2/0, args= 0, extra= 8
	.mask	0x50000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,32
	.cprestore 0
	sw	$fp,28($sp)
	sw	$gp,24($sp)
	move	$fp,$sp
	move	$v0,$a0
	sb	$v0,8($fp)
	sw	$zero,12($fp)
$L30:
	lw	$v0,12($fp)
	slt	$v0,$v0,64
	bne	$v0,$zero,$L33
	b	$L31
$L33:
	lw	$v1,12($fp)
	la	$v0,B64
	addu	$v0,$v1,$v0
	lb	$v1,0($v0)
	lbu	$v0,8($fp)
	bne	$v1,$v0,$L32
	lbu	$v0,12($fp)
	sb	$v0,16($fp)
	lbu	$v0,16($fp)
	sw	$v0,20($fp)
	b	$L29
$L32:
	lw	$v0,12($fp)
	addu	$v0,$v0,1
	sw	$v0,12($fp)
	b	$L30
$L31:
	li	$v0,255			# 0xff
	sw	$v0,20($fp)
$L29:
	lw	$v0,20($fp)
	move	$sp,$fp
	lw	$fp,28($sp)
	addu	$sp,$sp,32
	j	$ra
	.end	get_i64
	.size	get_i64, .-get_i64
	.align	2
	.globl	decode
	.ent	decode
decode:
	.frame	$fp,64,$ra		# vars= 24, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,64
	.cprestore 16
	sw	$ra,56($sp)
	sw	$fp,52($sp)
	sw	$gp,48($sp)
	move	$fp,$sp
	sw	$a0,64($fp)
	sw	$a1,68($fp)
	li	$v0,48			# 0x30
	sb	$v0,24($fp)
	li	$v0,60			# 0x3c
	sb	$v0,25($fp)
	li	$v0,63			# 0x3f
	sb	$v0,26($fp)
	sw	$zero,28($fp)
	lw	$a0,64($fp)
	la	$t9,fgetc
	jal	$ra,$t9
	sw	$v0,36($fp)
	lbu	$v0,36($fp)
	sb	$v0,40($fp)
	lbu	$v0,40($fp)
	move	$a0,$v0
	la	$t9,get_i64
	jal	$ra,$t9
	sb	$v0,32($fp)
$L36:
	lw	$v1,36($fp)
	li	$v0,-1			# 0xffffffffffffffff
	bne	$v1,$v0,$L38
	b	$L35
$L38:
	lw	$v0,28($fp)
	bne	$v0,$zero,$L39
	lw	$a0,64($fp)
	la	$t9,fgetc
	jal	$ra,$t9
	sw	$v0,36($fp)
	lw	$v1,36($fp)
	li	$v0,-1			# 0xffffffffffffffff
	bne	$v1,$v0,$L40
	b	$L35
$L40:
	lbu	$v0,36($fp)
	sb	$v0,41($fp)
	lbu	$v0,41($fp)
	move	$a0,$v0
	la	$t9,get_i64
	jal	$ra,$t9
	sb	$v0,33($fp)
	lbu	$v0,32($fp)
	sll	$v0,$v0,2
	sb	$v0,32($fp)
	lbu	$v1,33($fp)
	lbu	$v0,24($fp)
	and	$v0,$v1,$v0
	andi	$v0,$v0,0x00ff
	srl	$v0,$v0,4
	lbu	$v1,32($fp)
	or	$v0,$v1,$v0
	sb	$v0,32($fp)
	lbu	$v0,32($fp)
	lw	$a0,68($fp)
	la	$a1,$LC0
	move	$a2,$v0
	la	$t9,fprintf
	jal	$ra,$t9
	lw	$v0,28($fp)
	addu	$v0,$v0,1
	sw	$v0,28($fp)
	b	$L36
$L39:
	lw	$v1,28($fp)
	li	$v0,1			# 0x1
	bne	$v1,$v0,$L41
	lw	$a0,64($fp)
	la	$t9,fgetc
	jal	$ra,$t9
	sw	$v0,36($fp)
	lw	$v1,36($fp)
	li	$v0,61			# 0x3d
	bne	$v1,$v0,$L42
	b	$L35
$L42:
	lbu	$v0,36($fp)
	sb	$v0,41($fp)
	lbu	$v0,41($fp)
	move	$a0,$v0
	la	$t9,get_i64
	jal	$ra,$t9
	sb	$v0,34($fp)
	lbu	$v0,33($fp)
	sll	$v0,$v0,4
	sb	$v0,33($fp)
	lbu	$v1,34($fp)
	lbu	$v0,25($fp)
	and	$v0,$v1,$v0
	andi	$v0,$v0,0x00ff
	srl	$v0,$v0,2
	lbu	$v1,33($fp)
	or	$v0,$v1,$v0
	sb	$v0,33($fp)
	lbu	$v0,33($fp)
	lw	$a0,68($fp)
	la	$a1,$LC0
	move	$a2,$v0
	la	$t9,fprintf
	jal	$ra,$t9
	lw	$v0,28($fp)
	addu	$v0,$v0,1
	sw	$v0,28($fp)
	b	$L36
$L41:
	lw	$v1,28($fp)
	li	$v0,2			# 0x2
	bne	$v1,$v0,$L36
	lw	$a0,64($fp)
	la	$t9,fgetc
	jal	$ra,$t9
	sw	$v0,36($fp)
	lw	$v1,36($fp)
	li	$v0,61			# 0x3d
	bne	$v1,$v0,$L44
	b	$L35
$L44:
	lbu	$v0,36($fp)
	sb	$v0,41($fp)
	lbu	$v0,41($fp)
	move	$a0,$v0
	la	$t9,get_i64
	jal	$ra,$t9
	sb	$v0,35($fp)
	lbu	$v0,34($fp)
	sll	$v0,$v0,6
	sb	$v0,34($fp)
	lbu	$v1,35($fp)
	lbu	$v0,26($fp)
	and	$v0,$v1,$v0
	lbu	$v1,34($fp)
	or	$v0,$v1,$v0
	sb	$v0,34($fp)
	lbu	$v0,34($fp)
	lw	$a0,68($fp)
	la	$a1,$LC0
	move	$a2,$v0
	la	$t9,fprintf
	jal	$ra,$t9
	lw	$a0,64($fp)
	la	$t9,fgetc
	jal	$ra,$t9
	sw	$v0,36($fp)
	lbu	$v0,36($fp)
	sb	$v0,41($fp)
	lbu	$v0,41($fp)
	move	$a0,$v0
	la	$t9,get_i64
	jal	$ra,$t9
	sb	$v0,32($fp)
	sw	$zero,28($fp)
	b	$L36
$L35:
	move	$sp,$fp
	lw	$ra,56($sp)
	lw	$fp,52($sp)
	addu	$sp,$sp,64
	j	$ra
	.end	decode
	.size	decode, .-decode
	.ident	"GCC: (GNU) 3.3.3 (NetBSD nb3 20040520)"
