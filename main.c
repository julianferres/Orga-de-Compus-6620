#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void decodificar() {	

	//Definición de las máscaras a utilizar
	unsigned char a1mask = 0xFC;
	unsigned char a2mask = 0x03; 		
	unsigned char b1mask = 0xF0;
	unsigned char b2mask = 0x0F;
	unsigned char c1mask = 0xC0;
	unsigned char c2mask = 0X2F;

	//Definición de los resultados y variables temporales
	char buffer[1];
	int contador = 0;
	unsigned char a1, a2, b1, b2, c1, c2;

	//Definición de la tabla B64
	char B64[64]={'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 
	'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u',
	'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'};

	while(fgets(buffer, 1, stdin) != NULL) {
		
		//Usar fgetc, no almacena el resultado en un buffer, devuelve un int que va de 0 a 255 para caracteres validos y la representacion de -1 para el EOF 
		//man getopt_log ayuda a parsera reconocer cuakk es eo nombre del archivo, es tipo una libreria
		int i = strlen(buffer)-1;
  		if(buffer[i]=='\n') 
      	buffer[i] = '\0';

		if(contador == 0) {
			a1 = *buffer & a1mask; //a1 resultado
			//printf("a1= %d \n", a1);
			printf("%c", B64[a1]); 
			a2 = *buffer & a2mask;
			contador++;
		}

		if(contador == 1) {
			a2 = a2 << 4;
			b1 = *buffer & b1mask;
			b1 = b1 >> 4;
			b1 = b1 & a2; //b1 resultado
			//printf("b1= %d \n", b1);
			printf("%c", B64[b1]); 
			b2 = *buffer & b2mask;
			contador++;
		}

		if(contador == 2) {
			b2 = b2 << 2;
			c1 = *buffer & c1mask;
			c1 = c1 >> 6;
			c1 = c1 & b2; //c1 resultado
			//printf("c1= %d \n", c1);
			printf("%c", B64[c1]);
			c2 = *buffer & c2mask; //c2 resultado
			//printf("c2= %d \n", c2);
			printf("%c", B64[c2]);
			contador = 0;
		}
	}
	

	// finalizado el ciclo, fijarse si hay que agregar '=' o '=='
	switch (contador) {
		case 0:
		// aca va ==
		case 1:
		return;
		// aca va =
	}
}

int main (int argc, char const *argv[]) {
	decodificar();
}