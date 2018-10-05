#include <mips/regdet.h>
#include<sys/syscall.h>

.text
.abicalls
.align 2
.globl write_c
.ent write_c

write_c:
	.frame
	.set norder
	.upload(t9)
	.set reorder
#define FRAME_SZ 40
	subu sp,sp, FRAME_SZ
	sw ra,32(sp)
	sw gp,28(sp)
	sw $fp,24(sp)
	.move $fp,sp

	 sw a0, 40(sp) #Salvo el file descritptor en el arg building area del caller
	 sw a1, 44(sp) #Salvo el caracter a escribir en el 	arg building area del caller 

	 lw a0, 40(sp) # cargo en a0 el fileDescriptor(no sabemos si es lw o lb)
	 lb a1, 44(sp) # cargo en a1 el caracter a escribir
	 li a2, 1 # Escribo solo un caracter(1byte)
	 
	 li v0, sys_write #en v0 se almacena el syscall a ejecutar "sys_write" es una macro

	 syscall #busca en v0 que funcion va a ejecutar y la ejecuta

	
	 beq a3, 0, end #success

	 li a0, 2 # cargo en a0 el FD de stderr
	 lb a1, error # cargo en a1 el error a escribir
	 li a2, 19 # Escribo solo un caracter(1byte)

	 syscall

end:
	lw ra,32(sp)
	lw gp,28(sp)
	lw $fp,24(sp)

	addu sp,sp,FRAME_SZ #Libero el stackFrame

	jr ra
	.end write_c
	.rdata #que va aca???????????
	.align 2

error: .asciiz "Error de escritura" #strlen = 19bytes