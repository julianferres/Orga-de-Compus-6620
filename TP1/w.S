#include <mips/regdef.h>
#include<sys/syscall.h>

#define FRAME_SZ 40

.text
.abicalls
.align 2

.globl		write_c
.ent		write_c

.set		noreorder
.cpload		t9
.set		reorder

write_c:
	subu sp,sp, FRAME_SZ
	sw $fp,24(sp)
	.cprestore	 28
	sw ra,32(sp)
	nop#sw gp,28(sp)
	move $fp,sp

	nop#sw a0, 40(sp) #Salvo el file descriptor en el arg building area del caller
	nop#sw a1, 44(sp) #Salvo el caracter a escribir en el 	arg building area del caller

	lb t6,0(a1) #para debuggear -> caracter a escribir. Puede ser 84, 87, 70 o 117

	li a2, 1 # Escribo solo un caracter(1byte)
	 
	la v0, SYS_write #en v0 se almacena el syscall a ejecutar "sys_write" es una macro
	syscall #busca en v0 que funcion va a ejecutar y la ejecuta

	beq a3, 0, end #success

	nop#addi v1, v1, 2 #Cargo en v0 el codigo de error para devolverle al caller, quien validara.
 

end:
	lw ra,32(sp)
	lw gp,28(sp)
	lw $fp,24(sp)

	addu sp,sp,FRAME_SZ #Libero el stackFrame

	jr ra #para volver a la direccion original

.end write_c
