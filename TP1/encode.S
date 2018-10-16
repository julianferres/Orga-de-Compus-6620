#include <mips/regdef.h>
#include <sys/syscall.h>


## ASCII art del stack frame

##	   STACK FRAME
## *******************
## 28 *****	ra *******
## 24 *****	gp *******
## 20 *****	fp *******
## 16 *****	s3 *******
## 12 *****	-- *******
## 8 *****	-- *******
## 4 *****	-- *******
## 0 *****	-- *******
## *******************  
## Las 4 posiciones mas bajas son reservardas para Arg Building Area


#define FRAME_SZ 28
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

	subu 	sp,  sp, FRAME_SZ

	.cprestore (FRAME_SZ-24)
	sw 	    $fp, (FRAME_SZ - 20)(sp)
	sw 	    ra,  (FRAME_SZ - 16)(sp)
    sw      s3,  (FRAME_SZ - 12)(sp)

	move    $fp, sp

	sw 	    a0,  (FRAME_SZ     )(sp)
	sw 	    a1,  (FRAME_SZ +  4)(sp)

read:

	lw	a0, (FRAME_SZ)(sp) #a0 -> file descriptor
	la	a1, buffer_entrada #a1 -> buffer de entrada
	li	a2, 3 #a2 -> leer 3 bytes
	li	v0, SYS_read
	syscall

	bne a3, 0, error 
	beq v0, 0, end # lectura de EOF

	move s3, v0

primer_caracter:

	la t0, buffer_entrada
	la t2, buffer_salida

	## Codificación primer byte

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

	li t0, 1
	beq s3, t0, doble_padding #si leyo 1 byte que escriba doble padding

segundo_caracter:

	la t0, buffer_entrada
	la t2, buffer_salida

	## Codificación segundo byte

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

	li t0, 2
	beq s3, t0, simple_padding #si leyo 2 bytes que escriba simple padding

tercer_cuarto_caracter:

	la t0, buffer_entrada
	la t2, buffer_salida

	## Codificación tercer byte

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

	b write

doble_padding:

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

	b write

simple_padding:

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

write:

	lw	a0, (FRAME_SZ + 4)(sp) #a0 -> file descriptor de escritura
	la	a1, buffer_salida #a1 -> direccion del buffer de salida
	li	a2, 4 #a2 -> 4 bytes a escribir
	li	v0, SYS_write
	syscall

	lw a0, (FRAME_SZ)(sp) #a0 -> file descriptor real
    beq a3, 0, read
    
error:

	li a0, 1
	li v0, SYS_exit
	syscall	

end:

	lw  a1,  (FRAME_SZ +  4)(sp)
    lw 	a0,  (FRAME_SZ	   )(sp)

	lw 	gp,  (FRAME_SZ - 24)(sp)
	lw 	$fp, (FRAME_SZ - 20)(sp)
	lw 	ra,  (FRAME_SZ - 16)(sp)
    lw  s3,  (FRAME_SZ - 12)(sp)

	addu 	sp,  sp, FRAME_SZ

	jr 	ra


.end encode

.data  
.align 2

buffer_entrada: 
	.space 3
buffer_salida: 
	.space 4
