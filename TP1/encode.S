#include <mips/regdef.h>
#include <sys/syscall.h>

#define FRAME_SZ 48

#define a1mask	0xFC
#define a2mask	0x03 		
#define b1mask	0xF0
#define b2mask	0x0F
#define c1mask 0xC0
#define c2mask 0X3F

.text
.abicalls
.align 2

.globl		encode
.ent		encode

encode:
	.set		noreorder
	.cpload		t9
	.set		reorder

	sub	sp,sp, FRAME_SZ

	sw	$fp,(FRAME_SZ-16)(sp)
	.cprestore (FRAME_SZ-12)
	sw	ra,(FRAME_SZ-8)(sp) 
	move	$fp,sp

	sw a0, FRAME_SZ(sp) #Salvo el file descriptor de entrada en el arg building area del caller a0 -> fp
	sw a1, (FRAME_SZ+4)(sp) #Salvo el file descriptor de salida en el arg building area del caller a1 -> wfp

limpieza_buffer:
	la t0, buffer_entrada
	sb    zero, 0(t0)
    sb    zero, 1(t0)
    sb    zero, 2(t0)

    la t1, buffer_salida
	sb    zero, 0(t1)
    sb    zero, 1(t1)
    sb    zero, 2(t1)
    sb    zero, 3(t1)

lectura_inicial:
	la t0, buffer_entrada #aca podríamos llenar de cero para verificar que quede todo en cero pero podría no ser necesario

	li t1, 0 #inicializo contador en 0
	sw t1,20(sp) #guardo t0 en el area de la pila de las variables locales

	sw t1, (20)(sp) #lo guardo en la pila

	lw	a0, (FRAME_SZ)(sp) #a0 -> file descriptor
	la	a1, buffer_entrada #a1 -> buffer de entrada
	li	a2, 1 #a2 -> leer 1 byte
	li	v0, SYS_read
	syscall

 	##Recupero t1 despues de la syscall
	lw t1, (20)(sp) 

	bne a3, 0, error 
	beq v0, 0, end #si leyo EOF que termine el programa

lectura_1:
	lw	a0, (FRAME_SZ)(sp) #a0 -> file descriptor
 	la	a1, buffer_entrada + 1 #a1 -> buffer de entrada + 1
 	li	a2, 1 #a2 -> leer 1 byte
 	li	v0, SYS_read 
 	syscall

 	##Recupero t1 despues de la syscall
	lw t1, (20)(sp) 

 	beq v0, zero, primer_caracter #si termino de leer que vaya a ciclo

 	bne a3, 0, error #agregar = FALTA

 	addiu t1, t1, 1 #contador ++
	sw t1, (20)(sp) #lo guardo en la pila

lectura_2:
	lw	a0, (FRAME_SZ)(sp) #a0 -> file descriptor
 	la	a1, buffer_entrada + 2 #a1 -> buffer de entrada + 1
 	li	a2, 1 #a2 -> leer 1 byte
 	li	v0, SYS_read 
 	syscall

 	##Recupero t1 despues de la syscall
	lw t1, (20)(sp) 

 	bne a3, 0, error #agregar = FALTA	
	addiu t1, t1, 1 #contador ++
	sw t1, (20)(sp) #lo guardo en la pila

primer_caracter:
	la t0, buffer_entrada
	la t2, buffer_salida

	## Codificación primera lectura

	lbu	t3, 0(t0) 	# t3 = buffer_entrada[0] = buffer

	and t4, t3, a1mask # t4 = a1 = buffer & a1mask
	srl t4, t4, 2     # t4 = a1 = a1 >> 2

	and t5, t3, a2mask # t5 = a2 = buffer & a2mask
	sll t5, t5, 4 # t5 = a2 = a2 <<< 4

	sb t4, 0(t2)	# buffer_salida[0] = a1

	## Pasar a B64

	la t0, B64	# t0 = direccion de la tabla

	lbu	t3, 0(t2)		# t3 = buffer_salida[0]
	addu t0, t0, t3		
	lb	t0, 0(t0)		# t0 = B64[t3]
	sb	t0, 0(t2)		# buffer_salida[0] = t0

	beq t1, zero, escribir_doble_padding #si el contador esta en 1 es porque no tenía segundo caracter para leer y hay que agregar dos iguales

segundo_caracter:

	la t0, buffer_entrada
	la t2, buffer_salida

	## Codificación segunda lectura

	lbu	t3, 1(t0) 	# t3 = buffer_entrada[1] = buffer

	and t4, t3, b1mask # t4 = b1 = buffer & b1mask
	srl t4, t4, 4     # t4 = b1 = b1 >> 4
	or t4, t4, t5 # t4 = b1 = b1 | a2

	and t5, t3, b2mask # t5 = b2 = buffer & b2mask
	sll t5, t5, 2 # t5 = b2 = b2 <<< 2

	sb t4, 1(t2)	# buffer_salida[1] = b1

	## Pasar a b64

	la t0, B64	# t0 = direccion de la tabla

	lbu	t3, 1(t2)		# t3 = buffer_salida[1]
	addu t0, t0, t3		
	lb	t0, 0(t0)		# t0 = B64[t3]
	sb	t0, 1(t2)		# buffer_salida[1] = t0

	beq v0, zero, escribir_simple_padding

tercer_cuarto_caracter:

	la t0, buffer_entrada
	la t2, buffer_salida

	## Codificación tercera lectura

	lbu	t3, 2(t0) 	# t3 = buffer_entrada[2] = buffer

	and t4, t3, c1mask # t4 = c1 = buffer & c1mask
	srl t4, t4, 6     # t4 = c1 = c1 >> 6
	or t4, t4, t5 # t4 = c1 = c1 | b2

	and t5, t3, c2mask # t5 = c2 = buffer & c2mask

	sb t4, 2(t2)	# buffer_salida[2] = c1
	sb t5, 3(t2)    # buffer_salida[3] = c2

	## Pasar a b64

	la	t0, B64	# t0 = direccion de la tabla

	lbu	t3, 2(t2)		# t3 = buffer_salida[2]
	addu	t0, t0, t3		
	lb	t0, 0(t0)		# t0 = B64[t3]
	sb	t0, 2(t2)		# buffer_salida[2] = t0

	la	t0, B64	# t0 = direccion de la tabla

	lbu	t3, 3(t2)		# t3 = buffer_salida[3]
	addu	t0, t0, t3		
	lb	t0, 0(t0)		# t0 = B64[t3]
	sb	t0, 3(t2)		# buffer_salida[3] = t0

	b write_1

escribir_doble_padding:

	la t2, buffer_salida

	sb t5, 1(t2)	# buffer_salida[1] = a2

	## Pasar a B64
	la t0, B64	# t0 = direccion de la tabla

	lbu	t3, 1(t2)		# t3 = buffer_salida[1]
	addu t0, t0, t3		
	lb	t0, 0(t0)		# t0 = B64[t3]
	sb	t0, 1(t2)		# buffer_salida[1] = t0

	## Escribir dos iguales
	li t0, 64

	li t0, '=' # Guardo = en t0
	sb t0, 2(t2) #buffer_salida[2] = t0
	sb t0, 3(t2) #buffer_salida[3] = t0

	b write_1

escribir_simple_padding:

	la t2, buffer_salida

	sb t5, 2(t2)	# buffer_salida[2] = b2

	## Pasar a B64
	la t0, B64	# t0 = direccion de la tabla

	lbu	t3, 2(t2)		# t3 = buffer_salida[1]
	addu t0, t0, t3		
	lb	t0, 0(t0)		# t0 = B64[t3]
	sb	t0, 2(t2)		# buffer_salida[2] = t0

	## Escribir un igual
	li t0, '=' # Guardo = en t0
	sb t0, 3(t2) #buffer_salida[3] = t0

write_1:

	lw	a0, (FRAME_SZ + 4)(sp) #a0 -> wfd
	la	a1, buffer_salida #a1-> direccion del primer caracter

	li	a2, 1 #a2-> 1 byte
	li	v0, SYS_write
	syscall

    bne a3, 0, error

write_2:    

	lw	a0, (FRAME_SZ + 4)(sp) #a0 -> wfd
	la	a1, buffer_salida + 1 #a1-> direccion del segundo caracter
	
	li	a2, 1 #a2-> 1 byte
	li	v0, SYS_write
	syscall

    bne a3, 0, error

write_3:
	lw	a0, (FRAME_SZ + 4)(sp) #a0 -> wfd
	la	a1, buffer_salida + 2 #a1-> direccion del tercer caracter

	li	a2, 1 #a2-> 1 byte
	li	v0, SYS_write
	syscall

    bne a3, 0, error

write_4:

	lw	a0, (FRAME_SZ + 4)(sp) #a0 -> wfd
	la	a1, buffer_salida + 3 #a1-> direccion del cuarto caracter

	li	a2, 1 #a2-> 1 byte
	li	v0, SYS_write
	syscall

    beq a3, 0, lectura_inicial	
    
error:

	li a0, 1
	li v0, SYS_exit
	syscall	

end:

	li v0, 0
	lw	a1,  (FRAME_SZ +  4)(sp)
	lw	a0,  (FRAME_SZ     )(sp)

	lw $fp,(FRAME_SZ-16)(sp)
	lw gp,(FRAME_SZ-12)(sp)
	lw ra,(FRAME_SZ-8)(sp) #duda

	addu sp,sp,FRAME_SZ #Libero el stackFrame

	jr ra

.end encode

.data  
.align 2

buffer_entrada: 
	.space 3
	.byte	0, 0, 0
buffer_salida: 
	.space 4
	.byte	0, 0, 0, 0		
