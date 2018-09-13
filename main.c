#include <stdio.h>
#include <string.h>
#include <stdlib.h>


//Definición de la tabla B64
const char B64[64]={'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 
'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u',
'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'};


void encode() {	

	//Definición de las máscaras a utilizar
	unsigned char a1mask = 0xFC;
	unsigned char a2mask = 0x03; 		
	unsigned char b1mask = 0xF0;
	unsigned char b2mask = 0x0F;
	unsigned char c1mask = 0xC0;
	unsigned char c2mask = 0X3F;

	//Definición de los resultados y variables temporales
	int contador = 0;
	int a1, a2, b1, b2, c1, c2;
	

	FILE* wfp = fopen("output","wb");
	FILE* fp = fopen("input","rb");
	if (fp == NULL){fprintf(stderr, "no encuentro el archivo\n"); return;}
	int caracter = fgetc(fp);
	
	
	while(caracter != EOF) {
		
		//Usar fgetc, no almacena el resultado en un buffer, devuelve un int que va de 0 a 255 para caracteres validos y la representacion de -1 para el EOF 
		//man getopt_log ayuda a parsera reconocer cuakk es eo nombre del archivo, es tipo una libreria
		
		unsigned char buffer = (unsigned char) caracter;
		if(contador == 0) {
			a1 = buffer & a1mask; //a1 resultado
			a1 = a1 >> 2;
			a2 = buffer & a2mask;
			a2 = (unsigned char) a2 << 4;
			contador++;
			printf("%c", B64[a1]);
			caracter = fgetc(fp);
			continue;
		}

		if(contador == 1) {
			b1 = buffer & b1mask;
			b1 = b1 >> 4;
			b1 = b1 | a2; //b1 resultado
			b2 = buffer & b2mask;
			b2 = (unsigned char)b2 << 2;	
			contador++;
			printf("%c", B64[b1]);
			caracter = fgetc(fp);
			
			continue;
		}

		if(contador == 2) {
			c1 = buffer & c1mask;
			c1 = c1 >> 6;
			c1 = c1 | b2; //c1 resultado
			c2 = buffer & c2mask; //c2 resultado
			contador = 0;
			printf("%c", B64[c1]);
			printf("%c", B64[c2]);
			caracter = fgetc(fp);
			continue;
		}
		
	}
	

	// finalizado el ciclo, fijarse si hay que agregar '=' o '=='
	switch (contador) {
		case 2:
			printf("%c", B64[b2]);
			printf("=");
			return;
		case 1:
			printf("%c", B64[a2]);
			printf("==");
			return;
	}
}


int get_i64(unsigned char c){
	for(int i=0; i<64; i++){
		if(B64[i] == c) {printf("%d\n",i); return i;}
	}
	return -1;

}

void decode(){

	FILE* fp = fopen("input.txt","r");
	if (fp == NULL){fprintf(stderr, "no encuentro el archivo\n"); return;}
	int caracter = fgetc(fp);
	
	while(caracter != EOF) {
	
		unsigned char buffer = (unsigned char) caracter;
		unsigned char b64i = (unsigned char)get_i64(buffer);
		//printf("%d", b64i);
		caracter = fgetc(fp);
	}
	
	//ceci cierra el archivo

}

int main (int argc, char const *argv[]) {
	encode();
	//decode();
	printf("\n");
}
