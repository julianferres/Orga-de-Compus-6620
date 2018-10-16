#include <mips/regdef.h>
#include <sys/syscall.h>

#define FRAME_SZ 32

#define mask1d	0x30 
#define mask2d	0x3C
#define mask3d	0x3F

.data	
.text
.abicalls
.align 2

.globl		decode
.ent		decode

decode:
	.set		noreorder
	.cpload		t9
	.set		reorder

	subu 	sp,  sp, FRAME_SZ

	.cprestore (FRAME_SZ-24)
	sw 	    $fp, (FRAME_SZ - 20)(sp)
	sw 	    ra,  (FRAME_SZ - 16)(sp)
    sw      s2,  (FRAME_SZ - 12)(sp)
    sw      s3,  (FRAME_SZ - 8)(sp)

	move    $fp, sp

	sw 	    a0,  (FRAME_SZ     )(sp)
	sw 	    a1,  (FRAME_SZ +  4)(sp)

##LECTURAS 

primer_lectura: 
	
	lw a0, (FRAME_SZ)(sp)
	la a1, in_buffer
	li a2, 1
	li v0, SYS_read
	syscall

	beq a3, zero, primer_validacion_lectura
	
	b error_lectura

primer_validacion_lectura:

	li s2, 0 #La cuenta de los bytes leidos
	addu s2, s2, v0 #Suma 1 si leyo algun byte, 0 si no

	beq s2, 1, segunda_lectura #Si s2 es 0, leimos un EOF
	
	b salida_exitosa

segunda_lectura:

	lw a0, (FRAME_SZ)(sp)
	la a1, in_buffer + 1 
	li a2, 1
	li v0, SYS_read
	syscall #Leo segundo byte

    beq a3, zero, segunda_validacion_lectura
    
    b error_lectura

segunda_validacion_lectura:

	addu s2, s2, v0 #Suma 1 si leyo algun byte, 0 si no

	beq s2, 2, tercera_lectura #Si s2 es 1, leimos un EOF
	
	b cantidad_de_bytes_inconsistente

tercera_lectura:

    lw a0, (FRAME_SZ)(sp)
	la a1, in_buffer + 2
	li a2, 1
	li v0, SYS_read
	syscall

    beq a3, zero, tercer_validacion_lectura
    
    b error_lectura

tercer_validacion_lectura:

	addu s2, s2, v0 #Suma 1 si leyo algun byte, 0 si no

	beq s2, 3, cuarta_lectura #Si s2 es 2, leimos un EOF
	
	b cantidad_de_bytes_inconsistente

cuarta_lectura:
	
	lw a0, (FRAME_SZ)(sp)
	la a1, in_buffer + 3
	li a2, 1
	li v0, SYS_read
	syscall

    beq a3, zero, cuarta_validacion_lectura

    b error_lectura

cuarta_validacion_lectura:

	addu s2, s2, v0 #Suma 1 si leyo algun byte, 0 si no

	beq s2, 4, inspeccion_buffer_leido #Si s2 es 3, leimos un EOF
	
	b cantidad_de_bytes_inconsistente

inspeccion_buffer_leido:

	la t0, in_buffer #t0 = direccion in_buffer

	nop #Los iguales solo pueden estar en la tercer lectura
	nop #O solo la cuarta lectura, luego devuelvo contenido inconsistente si no es asi

	lbu t1, 0(t0) # t1 = contenido de in_buffer[0]
	li t2, '=' #Cargo el caracter '=' para comparar despues
	beq t1, t2, contenido_inconsistente

	lbu t1, 1(t0) # t1 = contenido de in_buffer[1]
	li t2, '=' #Cargo el caracter '=' para comparar despues
	beq t1, t2, contenido_inconsistente

	lbu t1, 2(t0) # t1 = contenido de in_buffer[2]
	beq t1, t2, chequeo_doble_igual

	lbu t1, 3(t0) # t1 = contenido de in_buffer[3]
	beq t1, t2, validacion_fin_archivo_1 #El archivo deberia terminar aca

	li t3, 0
	j decoding
	
chequeo_doble_igual:

	lbu t1, 3(t0) # t1 = contenido de in_buffer[3]
	li t2, '='
	beq t1, t2, validacion_fin_archivo_2 #Sin errores (se leyó **==)

	b contenido_inconsistente

validacion_fin_archivo_1:
	
	lw a0, (FRAME_SZ)(sp)
	la a1, in_buffer + 3
	li a2, 1
	li v0, SYS_read
	syscall

    bne a3, zero, error_lectura

	beq v0,0 , contador_simple_igual #Suma 1 si leyo algun byte, 0 si no
	
	b contenido_inconsistente

contador_simple_igual:
	
	li s3, 1 # Caso ***=
	j decoding

validacion_fin_archivo_2:
	
	lw a0, (FRAME_SZ)(sp)
	la a1, in_buffer + 3
	li a2, 1
	li v0, SYS_read
	syscall

    bne a3, zero, error_lectura

	beq v0,0 , contador_doble_igual 
	
	b contenido_inconsistente

contador_doble_igual:

	li s3, 2 # Caso **==
	j decoding



##RUTINA QUE BUSCA EL NUMERO DE INDICE DE B64 PARA EL CARACTER A DECODIFICAR #Le llega por t4

geti64index:

	li t0,0 #cargo un 0 en t0 para usarlo de contador

	la t1,B64 #esto va a fallar, t1 -> direccion de inicio del array 

	addu t2, t0, t1 #Posicion absoluta del indice

ciclob64index:

	beq t0, 64 , contenido_inconsistente

	addu t2, t0, t1
	lb t3, 0(t2) #accedo a elemento i del array y lo guardo en t3

	beq t3,t4, indiceb64encontrado

	addi t0,t0,1

	b ciclob64index

indiceb64encontrado:
	
	j ra

##DECODE

decoding:
	
	b primer_decode

primer_decode:

	lb t4, in_buffer
	la ra, segundo_decode

	b geti64index

segundo_decode:

	sb t0, partial_decode_buffer
	lb t4, in_buffer+1
	la ra, tercer_decode

	b geti64index

tercer_decode:
	
	sb t0, partial_decode_buffer+1
	lb t4, in_buffer+2
	li t5, '=' #Tengo que ver si mi tercer leida no fue un =
	beq t4, t5, rearmado_de_bytes

	la ra, cuarto_decode

	b geti64index

cuarto_decode:

	sb t0, partial_decode_buffer+2
	lb t4, in_buffer+3
	li t5, '='
	beq t4, t5, rearmado_de_bytes

	la ra, finalizo_decode

	b geti64index

finalizo_decode:

	sb t0, partial_decode_buffer+3

rearmado_de_bytes:

	lb t0, partial_decode_buffer
	lb t1, partial_decode_buffer+1
	lb t2, partial_decode_buffer+2
	lb t3, partial_decode_buffer+3
	la t4, out_buffer

	sll t0, 2 #t0 << 2
	li t5, 0 #Limpio t5 por las dudas
	and t5, t1, mask1d #En t5 tengo los 2 LSB que faltan para out_buffer[0]
	srl t5, 4 #Muevo esos dos bits a las 2 LSB positions
	or t0, t0, t5
	sb t0, 0(t4) # output[0] = t0

	beq s3, 2, primer_escritura #Caso **== --> x

	sll t1, 4 #Los 4 bits que sobraron de t1 << 4
	li t5, 0 #Limpio t5 por las dudas
	and t5, t2 , mask2d #En t5 tengo los 4 LSB que faltan para out_buffer[1]
	srl t5, 2 #Muevo esos dos bits a las 4 LSB positions
	or t1, t1, t5
	sb t1, 1(t4) # output[1] = t1

	beq s3, 1, primer_escritura #Caso ***= --> xx
 
	sll t2, 6 #Los 2 bits que sobraron de t2 << 6
	or t2, t2, t3
	sb t2, 2(t4) # output[2] = t2

##ESCRITURA

primer_escritura:

	lw	a0, (FRAME_SZ + 4)(sp)
	la 	a1, out_buffer
	li 	a2, 1
	li 	v0, SYS_write
	syscall
	
    beq a3, 0, primer_validacion_escritura
    
    b error_escritura

primer_validacion_escritura:

	nop #Si lei dos iguales, solo deberia escribir un byte
	nop #En este ciclo, luego, habria que salir sin errores

	li t0, 2
	beq t0, s3, salida_exitosa

segunda_escritura: 

	lw	a0, (FRAME_SZ + 4)(sp)
	la 	a1, out_buffer + 1
	li 	a2, 1
	li 	v0, SYS_write
	syscall

    beq a3, 0, segunda_validacion_escritura
    
    b error_escritura

segunda_validacion_escritura:

	nop #Si lei un solo igual, solo deberia escribir dos bytes
	nop #En este ciclo, luego, habria que salir sin errores

	li t0, 1
	beq t0, s3, salida_exitosa

tercer_escritura:

	lw	a0, (FRAME_SZ + 4)(sp)
	la 	a1, out_buffer + 2
	li 	a2, 1
	li 	v0, SYS_write
	syscall

    beq a3, 0, continuo_ciclo
    
    b error_escritura

continuo_ciclo:

	j primer_lectura

##RETORNOS

salida_exitosa:

	li v0, 0
	j end

error_lectura:

	li v0, 1
	j end

error_escritura:
	
	li v0, 2
	j end

cantidad_de_bytes_inconsistente:
	
	li v0, 3
	j end

contenido_inconsistente:

	li v0, 4 # Error de contenido inconsistente
	j end

end:

	lw  a1,  (FRAME_SZ +  4)(sp)
    lw 	a0,  (FRAME_SZ	   )(sp)

	lw 	gp,  (FRAME_SZ - 24)(sp)
	lw 	$fp, (FRAME_SZ - 20)(sp)
	lw 	ra,  (FRAME_SZ - 16)(sp)
    lw  s3,  (FRAME_SZ - 12)(sp)
    lw  s2,  (FRAME_SZ -  8)(sp)

	addu 	sp,  sp, FRAME_SZ

	jr 	ra
.end decode

.data
.align 2

partial_decode_buffer:
	.space  4
	.byte 	0, 0, 0, 0
in_buffer:
	.space  4
	.byte 	0, 0, 0, 0
out_buffer:
	.space  3
	.byte 	0, 0, 0
