# Constantes globales para la compilacion
EXEC =  main
CC = gcc
OBJ = main.o
CFLAGS = -g -std=c99 -Wall -pedantic -Wconversion -Wno-sign-conversion -Werror

#Instruccion que se va a ejecutar por defalut
all: $(EXEC)

#El default que se compila tiene dependencia a los objetos OBJ
#El comando compila los OBJ con CC y CFLAGS resultando el EXEC
$(EXEC): $(OBJ)
	$(CC) $(CFLAGS) $(OBJ) -o $(EXEC)
	
#Todos los objetos definidos en "OBJ=" con dependencia a los archivos .c y .h van a compilarse de la misma manera
#Podria haberlos escrito uno x uno
%.o: %.c %.h
	$(CC) $(CFLAGS) -c $<
	
#Borra todos los archivos
clean:
	rm $(OBJ) $(EXEC)

#Make compila unicamente los elementos que se hayan modificado recientemente
	