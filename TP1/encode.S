#include <mips/regdef.h>
#include <sys/syscall.h>

#define FRAME_SZ 100

#define a1maske	0xFC
#define a2maske	0x03 		
#define b1maske	0xF0
#define b2maske	0x0F
#define c1maske 0xC0
#define c2maske 0X3F

.text
.abicalls
.align 2

.globl		encode
.ent		encode

.set		noreorder
.cpload		t9
.set		reorder


encode:
	sub	sp,sp, FRAME_SZ
	sw	$fp,(FRAME_SZ-16)(sp)
	sw	gp,(FRAME_SZ-12)(sp)
	sw	ra,(FRAME_SZ-8)(sp) 
	move	$fp,sp

	sw a0, FRAME_SZ(sp) #Salvo el file descriptor de entrada en el arg building area del caller a0 -> fp
	sw a1, (FRAME_SZ+4)(sp) #Salvo el file descriptor de salida en el arg building area del caller a1 -> wfp

	li t0,0 #cargo un 0 en t0 para usarlo de contador
	sw t0,16(sp) #guardo t0 en el area de la pila de las variables locales

	li t1,1 #cargo un 1 en t1 para ir a caso1
	sw t1,20(sp)

	li t2,2 #cargo un 2 en t2 para ir a caso2
	sw t2,24(sp)

	li t3,0 
	sw t3,28(sp) 

	li t4,0 
	sw t4,32(sp)

	li t5,0
	sw t5,36(sp)

	b lectura

lectura:
	la t9, read_c 
	jalr t9 #salta a subrutina read_c

	#beq v1, t1, readerr #Valido que no haya habido errores en read_c

	sb v0,36(sp) #guardo el resultado de la lectura en la pila
	lb t5,36(sp) #en t5 está el carácter leído

	lw t0,16(sp)
	lw t1,20(sp)
	lw t2,24(sp)
	lw t3,28(sp)
	lw t4,32(sp)
	lw t5,36(sp)
	lw a0,FRAME_SZ(sp)
	lw v0,(FRAME_SZ+4)(sp) 

	b ciclo_encode

ciclo_encode:	
	beq t5, zero, finalizar_escritura #llego a un EOF 

	beq t0, zero, caso0_encode
	beq t0, t1, caso1_encode
	beq t0, t2, caso2_encode

caso0_encode:
	and t3, t5, a1maske #a1 = buffer & a1mask; 
	srl t3, t3, 2 #a1 = a1 >> 2;
	sw t3,28(sp) #actualizo valor de la pila

	and t4, t5, a2maske #a2 = buffer & a2mask;
	sll t4, t4, 4 #	a2 = a2 << 4;
	sw t4,32(sp) #actualizo valor de la pila

	addi t0, t0, 1 
	sw t0,16(sp) #actualizo valor de la pila

	b escritura 

caso1_encode:
	and t3, t5, b1maske #b1 = buffer & b1mask;
	srl t3, t3, 4 #b1 = b1 >> 4;
	or t3, t3, t4 #b1 = b1 | a2; 
	sw t3,28(sp) #actualizo valor de la pila

	and t4, t5, b2maske #b2 = buffer & b2mask;
	sll t4, t4, 2 #b2 = b2 << 2;	
	sw t4,32(sp) #actualizo valor de la pila

	addi t0, t0, 1 #contador++
	sw t0,16(sp) #actualizo valor de la pila

	b escritura

caso2_encode:
	and t3, t5, c1maske #c1 = buffer & c1mask;
	srl t3, t3, 6 #c1 = c1 >> 6;
	or t3, t3, t4 #c1 = c1 | b2;
	sw t3,28(sp) #actualizo valor de la pila

	and t4, t5, c2maske #c2 = buffer & c2mask;
	sw t4,32(sp) #actualizo valor de la pila

	li t0, 0 #contador = 0;
	sw t0,16(sp) #actualizo valor de la pila

	b escritura

escritura: 
	lw a0,(FRAME_SZ+4)(sp) #pongo en a0 wfd que esta en a1
	lw a1, 28(sp) #pongo en a1 el caracter a escribir que es t3

	la t9, write_c #en t9 está la subrutina write_c?
	jalr t9 #salta a subrutina write_c

	beq v1, t2, writeerr #Valido que no haya habido errores en la escritura

	beq t0,t2,volver_a_escribir

	b lectura

volver_a_escribir:
	lw a0,(FRAME_SZ+4)(sp) #pongo en a0 wfd que esta en a1
	lw a1, 32(sp) #pongo en a1 el caracter a escribir que es t4

	la t9, write_c #en t9 está la subrutina write_c?
	jalr t9 #salta a subrutina write_c

	beq v1, t2, writeerr #Valido que no haya habido errores en la escritura

	b lectura

finalizar_escritura: 
	beq t0, t1, casodobleigual #se que es malo el nombre 
	beq t0, t2, casoigual 
	b end_encode

casodobleigual:

	lw a0,(FRAME_SZ+4)(sp) #pongo en a0 wfd que esta en a1
	lw a1, 32(sp) #escribo t4

	la t9, write_c #en t9 está la subrutina write_c?
	jalr t9 #salta a subrutina write_c

	beq v1, t2, writeerr #Valido que no haya habido errores en la escritura

	lw a0,(FRAME_SZ+4)(sp) #pongo en a0 wfd que esta en a1
	li a1, 00111101 #escribo el =

	la t9, write_c #en t9 está la subrutina write_c?
	jalr t9 #salta a subrutina write_c

	beq v1, t2, writeerr #Valido que no haya habido errores en la escritura

	lw a0,(FRAME_SZ+4)(sp) #pongo en a0 wfd que esta en a1
	li a1, 00111101 #escribo el =

	la t9, write_c #en t9 está la subrutina write_c?
	jalr t9 #salta a subrutina write_c	

	beq v1, t2, writeerr #Valido que no haya habido errores en la escritura

	b end_encode

casoigual:

	lw a0,(FRAME_SZ+4)(sp) #pongo en a0 wfd que esta en a1
	lw a1, 32(sp) #escribo t4

	la t9, write_c #en t9 está la subrutina write_c?
	jalr t9 #salta a subrutina write_c

	beq v1, t2, writeerr #Valido que no haya habido errores en la escritura

	lw a0,(FRAME_SZ+4)(sp) #pongo en a0 wfd que esta en a1
	li a1, 00111101 #escribo el =

	la t9, write_c #en t9 está la subrutina write_c?
	jalr t9 #salta a subrutina write_c

	beq v1, t2, writeerr #Valido que no haya habido errores en la escritura

	b end_encode

readerr:
	
	li v0, 1

	b end_encode

writeerr:
	
	li v0, 2	

	b end_encode 

end_encode:
	lw $fp,(FRAME_SZ-16)(sp)
	lw gp,(FRAME_SZ-12)(sp)
	lw ra,(FRAME_SZ-8)(sp) #duda

	addu sp,sp,FRAME_SZ #Libero el stackFrame

	jr ra

.end encode

.data	
.align 2
errmsg: .word err_read, err_write
succesfull: #Defino para despues no tener un desfasaje desde la funcion que vaya a imprimir el error en pantalla y su indice
err_read: .ascii "La lectura del archivo no fue exitosa"
err_write: .ascii "La escritura del archivo no fue exitosa"
