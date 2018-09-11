#include <stdio.h>
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

	while(fgets(buffer, 1, stdin)) {

		switch (contador) {
			case 0:
				a1 = *buffer & a1mask; //a1 resultado
				a2 = *buffer & a2mask;
			case 1:
				a2 = a2 << 4;
				b1 = *buffer & b1mask;
				b1 = b1 >> 4;
				b1 = b1 & a2; //b1 resultado 
				b2 = *buffer & b2mask;
			case 2:
				b2 = b2 << 2;
				c1 = *buffer & c1mask;
				c1 = c1 >> 6;
				c1 = c1 & b2; //c1 resultado
				c2 = *buffer & c2mask; //c2 resultado
		
		}
		contador = (contador++)%3;
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