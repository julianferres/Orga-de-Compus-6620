#include <mips/regdef.h>
#include <sys/syscall.h>

#define FRAME_SZ 100

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


lectura_1:
	la t0, buffer_entrada #aca podríamos llenar de cero para verificar que quede todo en cero pero podría no ser necesario
	li t1, 0 #inicializo contador en 0

	lw	a0, (FRAME_SZ)(sp) #a0 -> file descriptor
	la	a1, buffer_entrada #a1 -> buffer de entrada
	li	a2, 1 #a2 -> leer 1 byte
	li	v0, SYS_read
	syscall

	bne a3, 0, error #agregar = FALTA

lectura_2:
	addiu t1, t1, 1 #contador ++

	lw	a0, (FRAME_SZ)(sp) #a0 -> file descriptor
 	la	a1, buffer_entrada + 1 #a1 -> buffer de entrada + 1
 	li	a2, 1 #a2 -> leer 1 byte
 	li	v0, SYS_read 
 	syscall

 	bne a3, 0, error #agregar = FALTA

lectura_3:
	addiu t1, t1, 1 #contador ++

	lw	a0, (FRAME_SZ)(sp) #a0 -> file descriptor
 	la	a1, buffer_entrada + 2 #a1 -> buffer de entrada + 1
 	li	a2, 1 #a2 -> leer 1 byte
 	li	v0, SYS_read 
 	syscall

 	bne a3, 0, error #agregar = FALTA	

ciclo:
	la t0, buffer_entrada
	la t2, buffer_salida

	## Codificación primera lectura

	lbu	t3, 0(t0) 		# t3 = buffer_entrada[0] = buffer

	and t4, t3, a1mask # t4 = a1 = buffer & a1mask
	srl t4, t4, 2     # t4 = a1 = a1 >> 2

	and t5, t3, a2mask # t5 = a2 = buffer & a2mask
	sll t5, t5, 4 # t5 = a2 = a2 <<< 4

	sb t4, 0(t2)	# buffer_salida[0] = a1

	## Codificación segunda lectura

	lbu	t3, 1(t0) 	# t3 = buffer_entrada[1] = buffer

	and t4, t3, b1mask # t4 = b1 = buffer & b1mask
	srl t4, t4, 4     # t4 = b1 = b1 >> 4
	or t4, t4, t5 # t4 = b1 = b1 | a2

	and t5, t3, b2mask # t5 = b2 = buffer & b2mask
	sll t5, t5, 2 # t5 = b2 = b2 <<< 2

	sb t4, 1(t2)	# buffer_salida[1] = b1

	## Codificación tercera lectura

	lbu	t3, 2(t0) 	# t3 = buffer_entrada[2] = buffer

	and t4, t3, c1mask # t4 = c1 = buffer & c1mask
	srl t4, t4, 6     # t4 = c1 = c1 >> 6
	or t4, t4, t5 # t4 = c1 = c1 | b2

	and t5, t3, c2mask # t5 = c2 = buffer & c2mask

	sb t4, 2(t2)	# buffer_salida[2] = c1
	sb t5, 3(t2)    # buffer_salida[3] = c2


encode_to_b64:

	la	t0, B64	# t0 = direccion de la tabla
	la	t1, buffer_salida	# t1 = direccion del buffer

	lbu	t2, 0(t1)		# t2 = buffer_salida[0]
	addu t0, t0, t2		
	lb	t0, 0(t0)		# t0 = B64[t2]
	sb	t0, 0(t1)		# buffer_salida[0] = t0

	la	t0, B64	# t0 = encode_table
	la	t1, buffer_salida	# t1 = direccion del buffer

	lbu	t2, 1(t1)		# t2 = buffer_salida[1]
	addu t0, t0, t2		
	lb	t0, 0(t0)		# t0 = B64[t2]
	sb	t0, 1(t1)		# buffer_salida[1] = t0

	la	t0, B64	# t0 = encode_table
	la	t1, buffer_salida	# t1 = direccion del buffer

	lbu	t2, 2(t1)		# t2 = buffer_salida[2]
	addu	t0, t0, t2		
	lb	t0, 0(t0)		# t0 = B64[t2]
	sb	t0, 2(t1)		# buffer_salida[2] = t0

	la	t0, B64	# t0 = encode_table
	la	t1, buffer_salida	# t1 = direccion del buffer

	lbu	t2, 3(t1)		# t2 = buffer_salida[3]
	addu	t0, t0, t2		
	lb	t0, 0(t0)		# t0 = B64[t2]
	sb	t0, 3(t1)		# buffer_salida[3] = t0

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

    beq a3, 0, end
    
error:
	li a0, 1
	li v0, SYS_exit
	syscall	

end:
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

buffer_entrada: .space 3
buffer_salida: .space 4	
