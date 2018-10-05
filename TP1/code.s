	#include <mips/regdet.h>
#include<sys/syscall.h>

.text
.abicalls
.align 2
.globl encode
.ent encode

encode:

.frame
	.set norder
	.upload(t9)
	.set reorder
	subu sp,sp, FRAME_SZ
	sw ra,32(sp)
	sw gp,28(sp)
	sw $fp,24(sp)
	.move $fp,sp

	li t0,0
	sw t0,16($fp)

caso0:

	and t0, buffer , b1mask
	sll t0, t0, 4
	or t0, , 

caso1:
	


caso2:
	


end:
	lw ra,32(sp)
	lw gp,28(sp)
	lw $fp,24(sp)

	addu sp,sp,FRAME_SZ #Libero el stackFrame

	jr ra
	.end write_c
	.rdata #que va aca???????????
	.align 2



#define a2mask 0x03 		
#define b1mask 0xF0
#define b2mask 0x0F
#define c1mask 0xC0
#define c2mask 0X3F
#define FRAME_SZ 40