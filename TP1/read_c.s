#include <mips/regdet.h>
#include<sys/syscall.h>

.text
.abicalls
.align 2
.globl read_c
.ent read_c

read_c:
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

	 #Si no funciona la opcion A
	 #sw t0,16($fp)
	 #lw a1, t0
	 #...
	 #lw b0, 16($fp)

	 lw a0, 40(sp) # cargo en a0 el fileDescriptor(no sabemos si es lw o lb)
	 lw a1, $b0  #opcion A
	 li a2, 1 # Escribo solo un caracter(1byte)
	 
	 li v0, sys_read #en v0 se almacena el syscall a ejecutar "sys_read" es una macro

	 syscall #busca en v0 que funcion va a ejecutar y la ejecuta

	 beq a3, 0, end #success

	 li a0, 2 # cargo en a0 el FD de stderr
	 lb a1, error # cargo en a1 el error a escribir
	 li a2, 17 # Escribo solo un caracter(1byte)

	 syscall

end:
	lw ra,32(sp)
	lw gp,28(sp)
	lw $fp,24(sp)

	addu sp,sp,FRAME_SZ #Libero el stackFrame

	jr ra
	.end read_c
	.rdata #que va aca???????????
	.align 2

error: .asciiz "Error de lectura" #strlen = 17bytes