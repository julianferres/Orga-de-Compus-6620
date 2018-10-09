#include <mips/regdef.h>

#define FRAME_SZ 44

.text
.abicalls
.align 2

.globl		geti64
.ent		geti64

.set		noreorder
.cpload		t9
.set		reorder

geti64:

	subu sp,sp, FRAME_SZ
	sw ra,(FRAME_SZ-8)(sp) #cambie aca por la constante porque me parece que va a tener que ser mas de 40
	sw gp,(FRAME_SZ-12)(sp)
	sw $fp,(FRAME_SZ-16)(sp)
	move $fp,sp

	sw a0, FRAME_SZ(sp) #Salvo el caracter en el arg building area del caller a0 -> caracter

	li t0,0 #cargo un 0 en t0 para usarlo de contador
	sw t0,16(sp) #guardo t0 en el area de la pila de las variables locales

	la t1,B64 #esto va a fallar, t1 -> direccion de inicio del array 
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
	addu v0, zero, t0 #devuelvo en v0 el indice de b64
	lw ra,(FRAME_SZ-8)(sp) 
	lw gp,(FRAME_SZ-12)(sp)
	lw $fp,(FRAME_SZ-16)(sp)

	addu sp,sp,FRAME_SZ #Libero el stackFrame

	jr ra

.end geti64
