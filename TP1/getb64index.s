.data 0x10000030
tablab64: 
	i1: .ascii 'A'
	i2: .ascii 'B'
	i3: .ascii 'C'
	i4: .ascii 'D'
	i5: .ascii 'E'
	i6: .ascii 'F'
	i7: .ascii 'G'
	i8: .ascii 'H'
	i9: .ascii 'I'
	i10: .ascii 'J'
	i11: .ascii 'K'
	i12: .ascii 'K'
	i13: .ascii 'L'
	i14: .ascii 'M'
	i15: .ascii 'N'
	i16: .ascii 'O'
	i17: .ascii 'P'
	i18: .ascii 'Q'
	i19: .ascii 'R'
	i20: .ascii 'S'
	i21: .ascii 'T'
	i22: .ascii 'U'
	i23: .ascii 'V' 
	i24: .ascii 'W'
	i25: .ascii 'X'
	i26: .ascii 'Y'
	i27: .ascii 'Z'
	i28: .ascii 'a'
	i29: .ascii 'b'
	i30: .ascii 'c'
	i31: .ascii 'd'
	i32: .ascii 'e'
	i33: .ascii 'f'
	i34: .ascii 'g'
	i35: .ascii 'h'
	i36: .ascii 'i'
	i37: .ascii 'j'
	i38: .ascii 'k'
	i39: .ascii 'l'
	i40: .ascii 'm'
	i41: .ascii 'o'
	i42: .ascii 'p'
	i43: .ascii 'q'
	i44: .ascii 'r'
	i45: .ascii 's'
	i46: .ascii 't'
	i47: .ascii 'u'
	i48: .ascii 'v'
	i49: .ascii 'w'
	i50: .ascii 'x'
	i51: .ascii 'y'
	i52: .ascii 'z'
	i53: .ascii '0'
	i54: .ascii '1'
	i55: .ascii '2'
	i56: .ascii '3'
	i57: .ascii '4'
	i58: .ascii '5'
	i59: .ascii '6'
	i60: .ascii '7'
	i61: .ascii '8'
	i62: .ascii '9'
	i63: .ascii '+' 
	i64: .ascii '/'

.text
.abicalls
.align 2
.globl geti64
.ent geti64

geti64:
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
	sw a0, FRAME_SZ(sp) #Salvo el caracter en el arg building area del caller a0 -> caracter

	#Preparar los registros temporales

	li t0,0 #cargo un 0 en t0 para usarlo de contador
	sw t0,16(sp) #guardo t0 en el area de la pila de las variables locales

	li t1,0x10000030 #esto va a fallar, t1 -> direccion de inicio del array
	sw t1,20(sp) #guardo t1 en el area de la pila de las variables locales

	li t2,0 #cargo un 0 en t2 para guardar los elementos del array
	sw t2,24(sp) #guardo t2 en el area de la pila de las variables locales

	b ciclo

ciclo:
	lw t2,0(t1) #accedo a elemento i del array y lo guardo en t2. puede fallar!! (t1 es una direccion de memoria, queremos el contenido)
	beq a0,t2,end
	sll t1,t1,2 #incrementar el indice 
	addi t0,t0,1

end:
	lw v0, t0 #devuelvo en v0 el indice de b64
	lw ra,(FRAME_SZ-8)(sp) 
	lw gp,(FRAME_SZ-12)(sp)
	lw $fp,(FRAME_SZ-16)(sp)

	addu sp,sp,FRAME_SZ #Libero el stackFrame

	jr ra
	.end geti64
	.rdata #que va aca???????????
	.align 2

#define FRAME_SZ 44

