#include <mips/regdef.h>
#include<sys/syscall.h>

#define FRAME_SZ 40
.data  
buffer: .space 1
.text
.abicalls
.align 2

.globl		read_c
.ent		read_c

.set		noreorder
.cpload		t9
.set		reorder

read_c:
	subu sp,sp, FRAME_SZ
	sw ra,32(sp)
	sw gp,28(sp)
	sw $fp,24(sp)
	move $fp,sp

	 sw a0, 40(sp) #Salvo el file descriptor en el arg building area del caller

	 #Si no funciona la opcion A
	 #sw t0,16($fp)
	 #lw a1, t0
	 #...
	 #lw b0, 16($fp)

	 lw a0, 40(sp) # cargo en a0 el fileDescriptor(no sabemos si es lw o lb)
	 lw a1, buffer  #opcion A
	 li a2, 1 # Escribo solo un caracter(1byte)
	 
	 li v0, SYS_read #en v0 se almacena el syscall a ejecutar "sys_read" es una macro

	 syscall #busca en v0 que funcion va a ejecutar y la ejecuta

	 lw v0, buffer

	 addi v1, v1, 0

	 beq a3, 0, end #success

	 addi v1, v1 , 1 #Si hay error, cargo el codigo de error en b0 como salida (utilizo 1 para errores de lectura)

end:
	lw ra,32(sp)
	lw gp,28(sp)
	lw $fp,24(sp)

	addu sp,sp,FRAME_SZ #Libero el stackFrame

	jr ra #para volver a la direccion original

.end read_c
