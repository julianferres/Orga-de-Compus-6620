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

	 nop #lw a0, 40(sp) # cargo en a0 el fileDescriptor(no sabemos si es lw o lb)
	 
	 la a1, buffer  #opcion A
	 li a2, 1 # leo 1 byte
	
	 li v0, SYS_read #en v0 se almacena el syscall a ejecutar "sys_read"

	 syscall #busca en v0 que funcion va a ejecutar y la ejecuta
	 beq a3, 0, end #success
error:
	li a0, 1
	li v0, SYS_exit
	syscall

end:
	la t0, buffer
	lb v0, 0(t0)
	lw ra,32(sp)
	lw gp,28(sp)
	lw $fp,24(sp)

	addu sp,sp,FRAME_SZ #Libero el stackFrame

	jr ra #para volver a la direccion original

.end readc

.data  
.align 2

buffer: .space 4
