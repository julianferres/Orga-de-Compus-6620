#include <mips/regdef.h>
#include <sys/syscall.h>

#define a1maske	0xFC
#define a2maske	0x03 		
#define b1maske	0xF0
#define b2maske	0x0F
#define c1maske 0xC0
#define c2maske 0X3F
#define mask1d	0x30
#define mask2d	0x3C
#define mask3d	0x3F
#define FRAME_SZ 100

.data	
	errmsg: .word err_read, err_write
	succesfull: #Defino para despues no tener un desfasaje desde la funcion que vaya a imprimir el error en pantalla y su indice
	err_read: .ascii "La lectura del archivo no fue exitosa"
	err_write: .ascii "La escritura del archivo no fue exitosa"

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
	.cpload($t9)
	.set reorder
	subu $sp,$sp, FRAME_SZ
	sw $ra,(FRAME_SZ-8)($sp) #cambie aca por la constante porque me parece que va a tener que ser mas de 40
	sw $gp,(FRAME_SZ-12)($sp)
	sw $fp,(FRAME_SZ-16)($sp)
	move	$fp,$sp

	#Guardar parámetros en la pila
	sw a0, FRAME_SZ($sp) #Salvo el file descriptor de entrada en el arg building area del caller a0 -> fp
	sw a1, (FRAME_SZ+4)($sp) #Salvo el file descriptor de salida en el arg building area del caller a1 -> wfp

	#Preparar los registros temporales

	li $t0,0 #cargo un 0 en t0 para usarlo de contador
	sw $t0,16($sp) #guardo t0 en el area de la pila de las variables locales

	li $t1,1 #cargo un 1 en t1 para ir a caso1
	sw $t1,20($sp)

	li $t2,2 #cargo un 2 en t2 para ir a caso2
	sw $t2,24($sp)

	li $t3,0 
	sw $t3,28($sp) 

	li $t4,0 
	sw $t4,32($sp)

	li $t5,0
	sw $t5,36($sp)

	b lectura

lectura:
	#Leo un caracter antes del while
	la $t9, read_c 
	jal $t9 #salta a subrutina read_c
	#Parametros necesarios para leer: en a0 fd y es así

	beq b0 , 1 , readerr #Valido que no haya habido errores en read_c

	sw $v0,36($sp) #guardo el resultado de la lectura en la pila
	lw $t5,36($sp) #en t5 está el carácter leído

	#Salvo registros que pueden haberse perdido con llamado a subrutina
	lw $t0,16($sp)
	lw $t1,20($sp)
	lw $t2,24($sp)
	lw $t3,28($sp)
	lw $t4,32($sp)
	lw $t5,36($sp)
	lw $a0,FRAME_SZ($sp)
	lw $a1,(FRAME_SZ+4)($sp) 

	b ciclo_encode

ciclo_encode:	
	beq $t5, $zero, finalizar_escritura #llego a un EOF 

	#Llamo a los correspondientes casos
	beq $t0, $zero, caso0_encode
	beq $t0, $t1, caso1_encode
	beq $t0, $t2, caso2_encode

caso0_encode:
	and $t3, $t5, a1maske #a1 = buffer & a1mask; 
	srl $t3, $t3, 2 #a1 = a1 >> 2;
	sw $t3,28($sp) #actualizo valor de la pila

	and $t4, $t5, a2maske #a2 = buffer & a2mask;
	sll $t4, $t4, 4 #	a2 = a2 << 4;
	sw $t4,32($sp) #actualizo valor de la pila

	addi $t0, $t0, 1 
	sw $t0,16($sp) #actualizo valor de la pila

	b escritura 
	#Se pasan parametros a1 y la tabla con indice t3 #write_caracter(wfp,B64[a1]);

caso1_encode:
	and $t3, $t5, b1maske #b1 = buffer & b1mask;
	srl $t3, $t3, 4 #b1 = b1 >> 4;
	or $t3, $t3, $t4 #b1 = b1 | a2; 
	sw $t3,28($sp) #actualizo valor de la pila

	and $t4, $t5, b2maske #b2 = buffer & b2mask;
	sll $t4, $t4, 2 #b2 = b2 << 2;	
	sw $t4,32($sp) #actualizo valor de la pila

	addi $t0, $t0, 1 #contador++
	sw $t0,16($sp) #actualizo valor de la pila

	b escritura
	#Se pasan parametros a1 y la tabla con indice t3 #write_caracter(wfp,B64[b1]);

caso2_encode:
	and $t3, $t5, c1maske #c1 = buffer & c1mask;
	srl $t3, $t3, 6 #c1 = c1 >> 6;
	or $t3, $t3, $t4 #c1 = c1 | b2;
	sw $t3,28($sp) #actualizo valor de la pila

	and $t4, $t5, c2maske #c2 = buffer & c2mask;
	sw $t4,32($sp) #actualizo valor de la pila

	li $t0, 0 #contador = 0;
	sw $t0,16($sp) #actualizo valor de la pila

	b escritura
	#Se pasan parametros a1 y la tabla con indice t3 #write_caracter(wfp,B64[c1]);
	#Falta pasar parametros a1 y la tabla con indice t4 #write_caracter(wfp,B64[c2]) -> volver_a_escribir

escritura: 
	#Parametros necesarios para escribir: en a0 wfd y no es así y en a1 t3

	lw $a0,(FRAME_SZ+4)($sp) #pongo en a0 wfd que esta en a1
	lw $a1, 28($sp) #pongo en a1 el caracter a escribir que es t3

	la $t9, write_c #en t9 está la subrutina write_c?
	jal $t9 #salta a subrutina write_c

	beq b0 , 2 , writeerr #Valido que no haya habido errores en la escritura

	beq $t0,$t2,volver_a_escribir

	b lectura

volver_a_escribir:
	#Agrego caso faltante: pasar parametros a1 y la tabla con indice t4 #write_caracter(wfp,B64[c2])
	#Parametros necesarios para escribir: en a0 wfd y no es así y en a1 t4

	lw $a0,(FRAME_SZ+4)($sp) #pongo en a0 wfd que esta en a1
	lw $a1, 32($sp) #pongo en a1 el caracter a escribir que es t4

	la $t9, write_c #en t9 está la subrutina write_c?
	jal $t9 #salta a subrutina write_c

	beq b0 , 2 , writeerr #Valido que no haya habido errores en la escritura

	b lectura

finalizar_escritura: 
	beq $t0, $t1, casodobleigual #se que es malo el nombre 
	beq $t0, $t2, casoigual 
	b end_encode

casodobleigual:

	lw $a0,(FRAME_SZ+4)($sp) #pongo en a0 wfd que esta en a1
	lw $a1, 32($sp) #escribo t4

	la $t9, write_c #en t9 está la subrutina write_c?
	jal $t9 #salta a subrutina write_c

	beq b0 , 2 , writeerr #Valido que no haya habido errores en la escritura

	lw $a0,(FRAME_SZ+4)($sp) #pongo en a0 wfd que esta en a1
	li $a1, 00111101 #escribo el =

	la $t9, write_c #en t9 está la subrutina write_c?
	jal $t9 #salta a subrutina write_c

	beq b0 , 2 , writeerr #Valido que no haya habido errores en la escritura

	lw $a0,(FRAME_SZ+4)($sp) #pongo en a0 wfd que esta en a1
	li $a1, 00111101 #escribo el =

	la $t9, write_c #en t9 está la subrutina write_c?
	jal $t9 #salta a subrutina write_c	

	beq b0 , 2 , writeerr #Valido que no haya habido errores en la escritura

	b end_encode

casoigual:

	lw $a0,(FRAME_SZ+4)($sp) #pongo en a0 wfd que esta en a1
	lw $a1, 32($sp) #escribo t4

	la $t9, write_c #en t9 está la subrutina write_c?
	jal $t9 #salta a subrutina write_c

	beq b0 , 2 , writeerr #Valido que no haya habido errores en la escritura

	lw $a0,(FRAME_SZ+4)($sp) #pongo en a0 wfd que esta en a1
	li $a1, 00111101 #escribo el =

	la $t9, write_c #en t9 está la subrutina write_c?
	jal $t9 #salta a subrutina write_c

	beq b0 , 2 , writeerr #Valido que no haya habido errores en la escritura

	b end_encode

end_encode:
	lw ra,(FRAME_SZ-8)($sp) 
	lw gp,(FRAME_SZ-12)($sp)
	lw $fp,(FRAME_SZ-16)($sp)

	addu sp,sp,FRAME_SZ #Libero el stackFrame

	jr ra
	.rdata #que va aca???????????
	.align 2

	.end encode

###############Decode##########################

decode:

	.frame
	.set norder
	.upload($t9)
	.set reorder
	subu sp,sp, FRAME_SZ
	sw $ra,(FRAME_SZ-8)($sp) 
	sw $gp,(FRAME_SZ-12)($sp)
	sw $fp,(FRAME_SZ-16)($sp)
	.move $fp,$sp

	#Guardar parámetros en la pila
	sw $a0, FRAME_SZ($sp) #Salvo el file descriptor de entrada en el arg building area del caller a0 -> fp
	sw $a1, (FRAME_SZ+4)($sp) #Salvo el file descriptor de salida en el arg building area del caller a1 -> wfp

	#Preparar los registros temporales

	li $t1,1 #cargo un 1 en t1 para ir a caso1
	sw $t1,20($sp)

	li $t2,2 #cargo un 2 en t2 para ir a caso2
	sw $t2,24($sp)

	b lectura_inicial

lectura_inicial: 
	li $t0,0 #cargo un 0 en t0 para usarlo de contador
	sw $t0,16($sp) #guardo t0 en el area de la pila de las variables locales
	#Parametro necesario para leer: en a0 el fd y es asi

	la $t9, read_c #en t9 está la subrutina read_c?
	jal $t9 #salta a subrutina read_c

	beq b0 , 1, readerr #Valido que no haya habido errores en la lectura

	sw $v0,28($sp) #guardo el resultado de la lectura en la pila en el espacio de t3
	lw $a0,28($sp) #en a0 está el carácter leído

	la $t9, getb64index
	jal $t9

	sw $v0,28($sp) #lo de v0 va al espacio de t3
	lw $t3,28($sp) #t3 -> caracter en indiceb64

	#Salvo registros que pueden haberse perdido con llamado a subrutina
	lw $t0,16($sp)
	lw $t1,20($sp)
	lw $t2,24($sp)
	lw $t3,28($sp)
	lw $t4,32($sp)
	lw $t5,36($sp)	
	lw $a0,FRAME_SZ($sp)
	lw $a1,(FRAME_SZ+4)($sp) 

	b ciclo 

ciclo:
	beq $t3, $zero, end  
	beq $t4, $zero, end #en los dos registros se lee

	#Llamo a los correspondientes casos
	beq $t0, $zero, caso0
	beq $t0, $t1, caso1
	beq $t0, $t2, caso2

caso0:
	#Leer un caracter, pasar a b64 y guardarlo en t4
	#Parametro necesario para leer: en a0 el fd y es asi

	la $t9, read_c #en t9 está la subrutina read_c?
	jal $t9 #salta a subrutina read_c

	beq b0 , 1, readerr #Valido que no haya habido errores en la lectura

	sw $v0,32($sp) #guardo el resultado de la lectura en la pila en el espacio de t4
	lw $a0,32($sp) #en a0 está el carácter leído

	la $t9, getb64index
	jal $t9

	sw $v0,32($sp) #lo de v0 va al espacio de t4
	lw $t4,32($sp) #t4 -> caracter en indiceb64

	#Salvo registros que pueden haberse perdido con llamado a subrutina
	lw $t0,16($sp)
	lw $t1,20($sp)
	lw $t2,24($sp)	
	lw $a0,FRAME_SZ($sp)
	lw $a1,(FRAME_SZ+4)($sp) 

	sll $t3, $t3, 2 #a = a << 2
	
	and $t5, $t4, mask1d #b & mask1
	srl $t5, $t5, 4 #(b & mask1) >> 4
	or $t3, $t3, $t5 #a = a | ((b & mask1) >> 4);
	sw $t3,28($sp)

	addi $t0, $t0, 1 #contador++
	sw $t0,16($sp) #actualizo el valor de la pila

	#Escribir caracter con valor t3(a) en ascii
	b escrituracaso0

caso1:
	#Leer un caracter, si es = ir a end
	#Parametro necesario para leer: en a0 el fd y es asi

	la $t9, read_c #en t9 está la subrutina read_c?
	jal $t9 #salta a subrutina read_c

	beq b0 , 1, readerr #Valido que no haya habido errores en la lectura

	sw $v0,28($sp) #guardo el resultado de la lectura en la pila en el espacio de t3
	lw $a0,28($sp) #en a0 está el carácter leído

	li $t5, 00111101 #cargo en t5 el igual
	beq $t5, $a0, end

	la $t9, getb64index
	jal $t9

	sw $v0,28($sp) #lo de v0 va al espacio de t3
	lw $t3,28($sp) #t3 -> caracter en indiceb64

	#Salvo registros que pueden haberse perdido con llamado a subrutina
	lw $t0,16($sp)
	lw $t1,20($sp)
	lw $t2,24($sp)
	lw $t3,28($sp)
	lw $t4,32($sp)
	lw $a0,FRAME_SZ($sp)
	lw $a1,(FRAME_SZ+4)($sp) 

	sll $t4, $t4, 4 #b << 4
	and $t5, $t3, mask2d #c & mask2
	srl $t5, $t5, 2 #(c & mask2) >> 2
	or $t4, $t4, $t5 #b = b | ((c & mask2) >> 2);
	sw $t4,32($sp)

	addi $t0, $t0, 1 #contador++
	sw $t0,16($sp) #actualizo el valor de la pila

	#Escribir caracter con valor t4(b) en ascii
	b escrituracaso1

caso2:
	#Leer un caracter, si es = ir a end
	#Parametro necesario para leer: en a0 el fd y es asi

	la $t9, read_c #en t9 está la subrutina read_c?
	jal $t9 #salta a subrutina read_c

	beq b0 , 1, readerr #Valido que no haya habido errores en la lectura

	sw $v0,32($sp) #guardo el resultado de la lectura en la pila en el espacio de t4
	lw $a0,32($sp) #en a0 está el carácter leído

	li $t5, 00111101 #cargo en t5 el igual
	beq $t5, $a0, end

	la $t9, getb64index
	jal $t9

	sw $v0,32($sp) #lo de v0 va al espacio de t4
	lw $t4,32($sp) #t4 -> caracter en indiceb64

	#Salvo registros que pueden haberse perdido con llamado a subrutina
	lw $t0,16($sp)
	lw $t1,20($sp)
	lw $t2,24($sp)
	lw $t3,28($sp)
	lw $t4,32($sp)
	lw $t5,36($sp)	
	lw $a0,FRAME_SZ($sp)
	lw $a1,(FRAME_SZ+4)($sp) 
	
	sll $t3, $t3, 6 #c << 6	
	and $t5, $t4, mask3d	#d & mask3
	or $t3, $t3, $t5 #c = c | (d & mask3);
	sw $t3,28($sp)

	#Escribir caracter con valor t3(c) en ascii
	b escrituracaso2

escrituracaso0:
	#Parametros necesarios para escribir: en a0 wfd y no es así y en a1 t3

	lw $a0,(FRAME_SZ+4)($sp) #pongo en a0 wfd que esta en a1
	lw $a1, 28($sp) #pongo en a1 el caracter a escribir que es t3

	la $t9, write_c 
	jal $t9 #salta a subrutina write_c

	beq b0 , 2 , writeerr #Valido que no haya habido errores en la escritura

	#Salvo registros que pueden haberse perdido con llamado a subrutina
	lw $t0,16($sp)
	lw $t1,20($sp)
	lw $t2,24($sp)
	lw $t3,28($sp)
	lw $t4,32($sp)	
	lw $a0,FRAME_SZ($sp)
	lw $a1,(FRAME_SZ+4)($sp) 

	b ciclo #continue

escrituracaso1:
	#Parametros necesarios para escribir: en a0 wfd y no es así y en a1 t4

	lw $a0,(FRAME_SZ+4)($sp) #pongo en a0 wfd que esta en a1
	lw $a1, 32($sp) #pongo en a1 el caracter a escribir que es t4

	la $t9, write_c #en t9 está la subrutina write_c?
	jal $t9 #salta a subrutina write_c

	beq b0 , 2 , writeerr #Valido que no haya habido errores en la escritura

	#Salvo registros que pueden haberse perdido con llamado a subrutina
	lw $t0,16($sp)
	lw $t1,20($sp)
	lw $t2,24($sp)
	lw $t3,28($sp)
	lw $t4,32($sp)	
	lw $a0,FRAME_SZ($sp)
	lw $a1,(FRAME_SZ+4)($sp) 

	b ciclo #continue

escrituracaso2:
	#Parametros necesarios para escribir: en a0 wfd y no es así y en a1 t3

	lw $a0,(FRAME_SZ+4)($sp) #pongo en a0 wfd que esta en a1
	lw $a1, 28($sp) #pongo en a1 el caracter a escribir que es t3

	la $t9, write_c #en t9 está la subrutina write_c?
	jal $t9 #salta a subrutina write_c

	beq b0 , 2 , writeerr #Valido que no haya habido errores en la escritura

	#Salvo registros que pueden haberse perdido con llamado a subrutina
	lw $t0,16($sp)
	lw $t1,20($sp)
	lw $t2,24($sp)
	lw $t3,28($sp)
	lw $t4,32($sp)	
	lw $a0,FRAME_SZ($sp)
	lw $a1,(FRAME_SZ+4)($sp) 

	b lectura_inicial

readerr:
	
	addu b0, 1, 0

	b end

writeerr:
	
	addu b0, 2, 0

end:
	lw $ra,(FRAME_SZ-8)($sp) 
	lw $gp,(FRAME_SZ-12)($sp)
	lw $fp,(FRAME_SZ-16)($sp)

	addu $sp,$sp,FRAME_SZ #Libero el stackFrame

	jr $ra
	.rdata #que va aca???????????
	.align 2

	.end decode