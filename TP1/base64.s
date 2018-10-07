#include <mips/regdet.h>
#include<sys/syscall.h>

.text
.abicalls
.align 2
.globl encode
.ent encode
.globl decode
.ent decode

encode:

.frame
	.set norder
	.upload(t9)
	.set reorder
	subu sp,sp, FRAME_SZ
	sw ra,(FRAME_SZ-8)(sp) #cambie aca por la constante porque me parece que va a tener que ser mas de 40
	sw gp,(FRAME_SZ-12)(sp)
	sw $fp,(FRAME_SZ-16)(sp)
	.move $fp,sp

	#Guardar parámetros en la pila
	sw a0, FRAME_SZ(sp) #Salvo el file descriptor de entrada en el arg building area del caller a0 -> fp
	sw a1, (FRAME_SZ+4)(sp) #Salvo el file descriptor de salida en el arg building area del caller a1 -> wfp

	#Preparar los registros temporales

	li t0,0 #cargo un 0 en t0 para usarlo de contador
	sw t0,16(sp) #guardo t0 en el area de la pila de las variables locales

	li t1,1 #cargo un 1 en t1 para ir a caso1
	sw t1,20(sp)

	li t2,2 #cargo un 2 en t2 para ir a caso2
	sw t2,24(sp)

	#DUDOSO. Necesito cargar dos variables temporales para poder entrar a cada caso. 
	#Los cargo inicialmente con 0 para ponerlos en la pila?

	li t3,0 
	sw t3,28(sp) 

	li t4,0 
	sw t4,32(sp)

	ba lectura

lectura:
	#Leo un caracter
	la t9, read_c #en t9 está la subrutina read_c?
	jal t9 #salta a subrutina read_c

	sw v0,36(sp) #guardo el resultado de la lectura en la pila
	lw t5,36(sp) #en t5 está el carácter leído

	#Salvo registros que pueden haberse perdido con llamado a subrutina
	lw t0,16(sp)
	lw t1,20(sp)
	lw t2,24(sp)
	lw t3,28(sp)
	lw t4,32(sp)

	ba ciclo 

ciclo:	
	beq t5, $zero, finalizar_escritura #llego a un EOF 

	#Llamo a los correspondientes casos
	beq t0, $zero, caso0
	beq t0, t1, caso1
	beq t0, t2, caso2

caso0:
	and t3, t5, a1maske #a1 = buffer & a1mask; 
	srl t3, t3, 2 #a1 = a1 >> 2;
	sw t3,28(sp) #actualizo valor de la pila

	and t4, t5, a2maske #a2 = buffer & a2mask;
	sll t4, t4, 4 #	a2 = a2 << 4;
	sw t4,32(sp) #actualizo valor de la pila

	addi t0, t0, 1 #contador++. PUEDE FALLAR
	sw t0,16(sp) #actualizo valor de la pila

	ba escritura 
	#Problema: no sé cómo pasar parametros a1 y la tabla con indice t3 #write_caracter(wfp,B64[a1]);

caso1:
	and t3, t5, b1maske #b1 = buffer & b1mask;
	srl t3, t3, 4 #b1 = b1 >> 4;
	or t3, t3, t4 #b1 = b1 | a2; 
	sw t3,28(sp) #actualizo valor de la pila

	and t4, t5, b2maske #b2 = buffer & b2mask;
	sll t4, t4, 2 #b2 = b2 << 2;	
	sw t4,32(sp)

	addi t0, t0, 1 #contador++. PUEDE FALLAR
	sw t0,16(sp) #actualizo valor de la pila

	ba escritura
	#Problema: no sé cómo pasar parametros a1 y la tabla con indice t3 #write_caracter(wfp,B64[b1]);

caso2:
	and t3, t5, c1maske #c1 = buffer & c1mask;
	srl t3, t3, 6 #c1 = c1 >> 6;
	or t3, t3, t4 #c1 = c1 | b2;
	sw t3,28(sp) #actualizo valor de la pila

	and t4, t5, c2maske #c2 = buffer & c2mask;
	sw t4,32(sp)

	li t0, 0 #contador = 0;
	sw t0,16(sp)

	ba escritura
	#Problema: no sé cómo pasar parametros a1 y la tabla con indice t3 #write_caracter(wfp,B64[c1]);
	#Problema: no sé cómo pasar parametros a1 y la tabla con indice t4 #write_caracter(wfp,B64[c2]);

escritura: 
	la t9, write_c #en t9 está la subrutina write_c?
	jal t9 #salta a subrutina write_c

	sw v0,40(sp) #guardo el resultado de la escritura en la pila
	lw t6,40(sp) #en t6 está el resultado de la escritura ?

	#Salvo registros que pueden haberse perdido con llamado a subrutina
	lw t0,16(sp)
	lw t1,20(sp)
	lw t2,24(sp)
	lw t3,28(sp)
	lw t4,32(sp)

	ba lectura

finalizar_escritura: 
	beq t0, t1, casodobleigual #se que es malo el nombre 
	beq t0, t2, casoigual 
	ba end

casodobleigual:
	#escribir lo que esté en t3
	#escribir doble igual
	ba end

casoigual:
	#escribir lo que esté en t3
	#escribir un igual
	ba end

end:
	lw ra,(FRAME_SZ-8)(sp) 
	lw gp,(FRAME_SZ-12)(sp)
	lw $fp,(FRAME_SZ-16)(sp)

	addu sp,sp,FRAME_SZ #Libero el stackFrame

	jr ra
	.end write_c
	.rdata #que va aca???????????
	.align 2


#define a1maske 0xFC
#define a2maske 0x03 		
#define b1maske 0xF0
#define b2maske 0x0F
#define c1maske 0xC0
#define c2maske 0X3F
#define FRAME_SZ 

###############Decode##########################

decode:

.frame
	.set norder
	.upload(t9)
	.set reorder
	subu sp,sp, FRAME_SZ
	sw ra,(FRAME_SZ-8)(sp) #cambie aca por la constante porque me parece que va a tener que ser mas de 40
	sw gp,(FRAME_SZ-12)(sp)
	sw $fp,(FRAME_SZ-16)(sp)
	.move $fp,sp

	#Guardar parámetros en la pila
	sw a0, FRAME_SZ(sp) #Salvo el file descriptor de entrada en el arg building area del caller a0 -> fp
	sw a1, (FRAME_SZ+4)(sp) #Salvo el file descriptor de salida en el arg building area del caller a1 -> wfp

	#Preparar los registros temporales

	li t0,0 #cargo un 0 en t0 para usarlo de contador
	sw t0,16(sp) #guardo t0 en el area de la pila de las variables locales

	li t1,1 #cargo un 1 en t1 para ir a caso1
	sw t1,20(sp)

	li t2,2 #cargo un 2 en t2 para ir a caso2
	sw t2,24(sp)

	#DUDOSO. Necesito cargar dos variables temporales para poder entrar a cada caso. 
	#Los cargo inicialmente con 0 para ponerlos en la pila?

	li t3,5 #guardo numero distinto de 0
	sw t3,28(sp) 

	li t4,5 #guardo numero distinto de 0
	sw t4,32(sp)

	li t5, 0 #completamente temporal
	sw t5,36(sp)

	ba lectura_inicial

lectura_inicial: 
	la t9, read_c #en t9 está la subrutina read_c?
	jal t9 #salta a subrutina read_c

	sw v0,28(sp) #guardo el resultado de la lectura en la pila
	lw t3,28(sp) #en t3 está el carácter leído
	#PASAR A B64 LO QUE ESTÁ EN T3

	#Salvo registros que pueden haberse perdido con llamado a subrutina
	lw t0,16(sp)
	lw t1,20(sp)
	lw t2,24(sp)
	lw t3,28(sp)
	lw t4,32(sp)
	lw t5,36(sp)

	ba ciclo 

ciclo:
	beq t3, $zero, end  
	beq t4, $zero, end #en los dos registros se lee

	#Llamo a los correspondientes casos
	beq t0, $zero, caso0
	beq t0, t1, caso1
	beq t0, t2, caso2

caso0:
	#Leer un caracter, pasar a b64 y guardarlo en t4
	la t9, read_c #en t9 está la subrutina read_c?
	jal t9 #salta a subrutina read_c

	sw v0,32(sp) #guardo el resultado de la lectura en la pila
	lw t4,32(sp) #en t4 está el carácter leído
	#PASAR A B64 LO QUE ESTÁ EN T4

	#Salvo registros que pueden haberse perdido con llamado a subrutina
	lw t0,16(sp)
	lw t1,20(sp)
	lw t2,24(sp)
	lw t3,28(sp)
	lw t4,32(sp)
	lw t5,36(sp)

	sll t3, t3, 2 #a = a << 2
	and t5, t4, mask1d #b & mask1
	srl t5, t5, 4 #(b & mask1) >> 4
	or t3, t3, t5 #a = a | ((b & mask1) >> 4);

	#escribir caracter con valor t3(a) en ascii

	addi t0, t0, 1 #contador++
	ba ciclo #continue

caso1:
	#Leer un caracter, si es = ir a end
	la t9, read_c #en t9 está la subrutina read_c?
	jal t9 #salta a subrutina read_c

	sw v0,28(sp) #guardo el resultado de la lectura en la pila
	lw t3,28(sp) #en t3 está el carácter leído
	#PASAR A B64 LO QUE ESTÁ EN T3
	#Si es = ir a end

	#Salvo registros que pueden haberse perdido con llamado a subrutina
	lw t0,16(sp)
	lw t1,20(sp)
	lw t2,24(sp)
	lw t3,28(sp)
	lw t4,32(sp)
	lw t5,36(sp)

	sll t4, t4, 4 #b << 4
	and t5, t3, mask2d #c & mask2
	srl t5, t5, 2 #(c & mask2) >> 2
	or t4, t4, t5 #b = b | ((c & mask2) >> 2);

	#escribir caracter con valor t4(b) en ascii

	addi t0, t0, 1 #contador++
	ba ciclo #continue

caso2:
	#Leer un caracter, si es = ir a end
	la t9, read_c #en t9 está la subrutina read_c?
	jal t9 #salta a subrutina read_c

	sw v0,32(sp) #guardo el resultado de la lectura en la pila
	lw t4,32(sp) #en t4 está el carácter leído
	#PASAR A B64 LO QUE ESTÁ EN T4
	#Si es = ir a end

	#Salvo registros que pueden haberse perdido con llamado a subrutina
	lw t0,16(sp)
	lw t1,20(sp)
	lw t2,24(sp)
	lw t3,28(sp)
	lw t4,32(sp)
	lw t5,36(sp)	

	sll t3, t3, 6 #c << 6	
	and t5, t4, mask3d	#d & mask3
	or t3, t3, t5 #c = c | (d & mask3);

	#escribir caracter con valor t3(c) en ascii
	
	#leer un caracter, pasarlo a b64 y guardarlo en t3
	la t9, read_c #en t9 está la subrutina read_c?
	jal t9 #salta a subrutina read_c

	sw v0,28(sp) #guardo el resultado de la lectura en la pila
	lw t4,28(sp) #en t3 está el carácter leído
	#PASAR A B64 LO QUE ESTÁ EN T3

	#Salvo registros que pueden haberse perdido con llamado a subrutina
	lw t0,16(sp)
	lw t1,20(sp)
	lw t2,24(sp)
	lw t3,28(sp)
	lw t4,32(sp)
	lw t5,36(sp)

	li t0, 0 #contador = 0
	ba ciclo #continue

end:
	lw ra,(FRAME_SZ-8)(sp) 
	lw gp,(FRAME_SZ-12)(sp)
	lw $fp,(FRAME_SZ-16)(sp)

	addu sp,sp,FRAME_SZ #Libero el stackFrame

	jr ra
	.end write_c
	.rdata #que va aca???????????
	.align 2

#define mask1d 0x30
#define mask2d 0x3C
#define mask3d 0x3F
#define FRAME_SZ 