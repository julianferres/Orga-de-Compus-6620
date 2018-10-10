#include <mips/regdef.h>
#include <sys/syscall.h>

#define FRAME_SZ 48

#define mask1d	0x30
#define mask2d	0x3C
#define mask3d	0x3F

.data	
.text
.abicalls
.align 2

.globl		decode
.ent		decode

.set		noreorder
.cpload		t9
.set		reorder

decode:

	subu sp,sp, FRAME_SZ
	sw ra,(FRAME_SZ-8)(sp) 
	sw gp,(FRAME_SZ-12)(sp)
	sw $fp,(FRAME_SZ-16)(sp)
	move $fp,sp

	sw a0, FRAME_SZ(sp) #Salvo el file descriptor de entrada en el arg building area del caller a0 -> fp
	sw a1, (FRAME_SZ+4)(sp) #Salvo el file descriptor de salida en el arg building area del caller a1 -> wfp

	li t1,1 #cargo un 1 en t1 para ir a caso1
	sw t1,20(sp)

	li t2,2 #cargo un 2 en t2 para ir a caso2
	sw t2,24(sp)

	b lectura_inicial

lectura_inicial: 
	li t0,0 #cargo un 0 en t0 para usarlo de contador
	sw t0,16(sp) #guardo t0 en el area de la pila de las variables locales

	la t9, read_c #en t9 está la subrutina read_c
	jalr t9 #salta a subrutina read_c

	beq v1, t1, readerr #Valido que no haya habido errores en la lectura

	sw v0,28(sp) #guardo el resultado de la lectura en la pila en el espacio de t3
	lw a0,28(sp) #en a0 está el carácter leído

	la t9, geti64
	jalr t9

	sw v0,28(sp) #lo de v0 va al espacio de t3
	lw t3,28(sp) #t3 -> caracter en indiceb64

	lw t0,16(sp)
	lw t1,20(sp)
	lw t2,24(sp)
	lw t3,28(sp)
	lw t4,32(sp)
	lw t5,36(sp)	
	lw a0,FRAME_SZ(sp)
	lw a1,(FRAME_SZ+4)(sp) 

	b ciclo 

ciclo:
	beq t3, zero, end  
	beq t4, zero, end #en los dos registros se lee

	beq t0, zero, caso0
	beq t0, t1, caso1
	beq t0, t2, caso2

caso0:
	la t9, read_c #en t9 está la subrutina read_c?
	jalr t9 #salta a subrutina read_c
	nop

	beq v1 , t1, readerr #Valido que no haya habido errores en la lectura

	sw v0,32(sp) #guardo el resultado de la lectura en la pila en el espacio de t4
	lw a0,32(sp) #en a0 está el carácter leído

	la t9, geti64
	jalr t9

	sw v0,32(sp) #lo de v0 va al espacio de t4
	lw t4,32(sp) #t4 -> caracter en indiceb64

	lw t0,16(sp)
	lw t1,20(sp)
	lw t2,24(sp)	
	lw a0,FRAME_SZ(sp)
	lw a1,(FRAME_SZ+4)(sp) 

	sll t3, t3, 2 #a = a << 2
	
	and t5, t4, mask1d #b & mask1
	srl t5, t5, 4 #(b & mask1) >> 4
	or t3, t3, t5 #a = a | ((b & mask1) >> 4);
	sw t3,28(sp)

	addi t0, t0, 1 #contador++
	sw t0,16(sp) #actualizo el valor de la pila

	b escrituracaso0

caso1:
	la t9, read_c #en t9 está la subrutina read_c?
	jalr t9 #salta a subrutina read_c
	nop

	beq v1 , t1, readerr #Valido que no haya habido errores en la lectura

	sw v0,28(sp) #guardo el resultado de la lectura en la pila en el espacio de t3
	lw a0,28(sp) #en a0 está el carácter leído

	li t5, 00111101 #cargo en t5 el igual
	beq t5, a0, end

	la t9, geti64
	jalr t9

	sw v0,28(sp) #lo de v0 va al espacio de t3
	lw t3,28(sp) #t3 -> caracter en indiceb64

	lw t0,16(sp)
	lw t1,20(sp)
	lw t2,24(sp)
	lw t3,28(sp)
	lw t4,32(sp)
	lw a0,FRAME_SZ(sp)
	lw a1,(FRAME_SZ+4)(sp) 

	sll t4, t4, 4 #b << 4
	and t5, t3, mask2d #c & mask2
	srl t5, t5, 2 #(c & mask2) >> 2
	or t4, t4, t5 #b = b | ((c & mask2) >> 2);
	sw t4,32(sp)

	addi t0, t0, 1 #contador++
	sw t0,16(sp) #actualizo el valor de la pila

	b escrituracaso1

caso2:
	la t9, read_c #en t9 está la subrutina read_c?
	jalr t9 #salta a subrutina read_c
	nop

	beq v1 , t1, readerr #Valido que no haya habido errores en la lectura

	sw v0,32(sp) #guardo el resultado de la lectura en la pila en el espacio de t4
	lw a0,32(sp) #en a0 está el carácter leído

	li t5, 00111101 #cargo en t5 el igual
	beq t5, a0, end

	la t9, geti64
	jalr t9

	sw v0,32(sp) #lo de v0 va al espacio de t4
	lw t4,32(sp) #t4 -> caracter en indiceb64

	lw t0,16(sp)
	lw t1,20(sp)
	lw t2,24(sp)
	lw t3,28(sp)
	lw t4,32(sp)
	lw t5,36(sp)	
	lw a0,FRAME_SZ(sp)
	lw a1,(FRAME_SZ+4)(sp) 
	
	sll t3, t3, 6 #c << 6	
	and t5, t4, mask3d	#d & mask3
	or t3, t3, t5 #c = c | (d & mask3);
	sw t3,28(sp)

	b escrituracaso2

escrituracaso0:

	lw a0,(FRAME_SZ+4)(sp) #pongo en a0 wfd que esta en a1
	lw a1, 28(sp) #pongo en a1 el caracter a escribir que es t3

	la t9, write_c 
	jalr t9 #salta a subrutina write_c
	nop

	beq v1 , t2 , writeerr #Valido que no haya habido errores en la escritura

	lw t0,16(sp)
	lw t1,20(sp)
	lw t2,24(sp)
	lw t3,28(sp)
	lw t4,32(sp)	
	lw a0,FRAME_SZ(sp)
	lw a1,(FRAME_SZ+4)(sp) 

	b ciclo #continue

escrituracaso1:

	lw a0,(FRAME_SZ+4)(sp) #pongo en a0 wfd que esta en a1
	lw a1, 32(sp) #pongo en a1 el caracter a escribir que es t4

	la t9, write_c #en t9 está la subrutina write_c?
	jalr t9 #salta a subrutina write_c
	nop

	beq v1 , t2 , writeerr #Valido que no haya habido errores en la escritura

	lw t0,16(sp)
	lw t1,20(sp)
	lw	t2,24(sp)
	lw t3,28(sp)
	lw t4,32(sp)	
	lw a0,FRAME_SZ(sp)
	lw a1,(FRAME_SZ+4)(sp) 

	b ciclo #continue

escrituracaso2:

	lw a0,(FRAME_SZ+4)(sp) #pongo en a0 wfd que esta en a1
	lw a1, 28(sp) #pongo en a1 el caracter a escribir que es t3

	la t9, write_c #en t9 está la subrutina write_c?
	jalr t9 #salta a subrutina write_c
	nop

	beq v1 , t2 , writeerr #Valido que no haya habido errores en la escritura

	lw t0,16(sp)
	lw t1,20(sp)
	lw t2,24(sp)
	lw t3,28(sp)
	lw t4,32(sp)	
	lw a0,FRAME_SZ(sp)
	lw a1,(FRAME_SZ+4)(sp) 

	b lectura_inicial

readerr:
	
	li v0, 1

	b end

writeerr:
	
	li v0, 2

end:
	lw ra,(FRAME_SZ-8)(sp) 
	lw gp,(FRAME_SZ-12)(sp)
	lw $fp,(FRAME_SZ-16)(sp)

	addu sp,sp,FRAME_SZ #Libero el stackFrame

	jr ra
	
.end decode

