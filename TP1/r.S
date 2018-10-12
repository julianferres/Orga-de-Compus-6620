#include <mips/regdef.h>
#include <sys/syscall.h>

#define FRAME_SZ 40

.text
.abicalls
.align 2

.globl		readc
.ent		readc

.set		noreorder
.cpload		t9
.set		reorder

readc:
	 subu sp,sp, FRAME_SZ
	 sw $fp,24(sp)
	 .cprestore	 28
	 sw ra,32(sp)
	 move $fp,sp

	 sw a0, 40(sp) #Salvo el file descriptor en el arg building area del caller

	 lw a0, 40(sp) #a0 -> fileDescriptor(no sabemos si es lw o lb)
	 la a1, buffer  #a1 -> dirección de memoria del buffer (puntero al char)
	 li a2, 1 # a2 -> se lee 1 byte
	
	 li v0, SYS_read #en v0 se almacena el syscall a ejecutar "sys_read"
	 syscall #busca en v0 que funcion va a ejecutar y la ejecuta

	 bne a3, 0, error #si a3 es distinto de cero error
	 bne v0, 0, lee_caracter #si v0 distinto de cero leyo
	 b end #finaliza

error:
	li a0, 1
	li v0, SYS_exit
	syscall	

lee_caracter:
	la t0, buffer
	lb v0, 0(t0) #v0 puede ser 77, 97 o 110

end:
	sw zero, buffer      #limpio el buffer
	lw ra,32(sp)
	lw gp,28(sp)
	lw $fp,24(sp)

	addu sp,sp,FRAME_SZ #Libero el stackFrame

	jr ra #para volver a la direccion original

.end readc

.data  
.align 2

buffer: .space 4
