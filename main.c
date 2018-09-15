#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <getopt.h>
#include <stdbool.h>

//Definición de la tabla B64
const char B64[64]= {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 
'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u',
'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'};

//Definición del menú de ayuda
const char HELP[] = "Usage:\n tp0 -h \n tp0 -V \n tp0 [options] \n Options: \n -V, --version Print version and quit. \n -h, --help Print this information. \n -i, --input Location of the input file. \n -a, --action Program action: encode (default) or decode. \n";

//Definición de versión del programa
const char VERSION[] = "2018.9.18 \n";

void encode(FILE* fp, FILE* wfp) {

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
			fprintf(wfp, "%c", B64[a1]);
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
			fprintf(wfp, "%c", B64[b1]);
			caracter = fgetc(fp);
			continue;
		}

		if(contador == 2) {
			c1 = buffer & c1mask;
			c1 = c1 >> 6;
			c1 = c1 | b2; //c1 resultado
			c2 = buffer & c2mask; //c2 resultado
			contador = 0;
			fprintf(wfp, "%c", B64[c1]);
			fprintf(wfp, "%c", B64[c2]);
			caracter = fgetc(fp);
			continue;
		}	
	}
	
	// finalizado el ciclo, fijarse si hay que agregar '=' o '=='
	switch (contador) {
		case 2:
			fprintf(wfp, "%c", B64[b2]);
			fprintf(wfp, "=");
			break;
		case 1:
			fprintf(wfp, "%c", B64[a2]);
			fprintf(wfp, "==");
			break;
	}
}


int get_i64(unsigned char c){
	for(int i=0; i<64; i++){
		if(B64[i] == c) {
		return i;
		}
	}
	return -1;

}

void decode(FILE* fp, FILE* wfp){

	unsigned char a, b, c, d ; 

	//Definición de las máscaras a utilizar
	unsigned char mask1 = 0x30; //00110000
	unsigned char mask2 = 0x3A; //00111100 		
	unsigned char mask3 = 0x3F; //00111111
	
	//Definición de los resultados y variables temporales
	int contador = 0;
	
	int caracter = fgetc(fp);
	//Usar fgetc, no almacena el resultado en un buffer, devuelve un int que va de 0 a 255 para caracteres validos y la representacion de -1 para el EOF 

	unsigned char buffer = (unsigned char) caracter;
	a = (unsigned char)get_i64(buffer);

	while(caracter != EOF ) {
		
		
		if(contador == 0) {
			
			caracter = fgetc(fp);
			
			unsigned char buffer = (unsigned char) caracter;
			b = (unsigned char)get_i64(buffer); //Lo paso a su indice en Base64	

			a = a << 2; 
			a = a | ((b & mask1) >> 4);

			fprintf(wfp, "%c", a);

			contador++;
			continue;
		}

		if(contador == 1) {
			
			caracter = fgetc(fp);
			
			if ( caracter == '=') break;

			unsigned char buffer = (unsigned char) caracter;
			c = (unsigned char)get_i64(buffer); //Lo paso a su indice en Base64	

			b = b << 4; //Primeros 4 bits 
			b = b | ((c & mask2) >> 2);
			
			fprintf(wfp, "%c", b);

			contador++;
			continue;
		}

		if(contador == 2) {
			
			caracter = fgetc(fp);
			
			if ( caracter == '=') break;


			unsigned char buffer = (unsigned char) caracter;
			d = (unsigned char)get_i64(buffer); //Lo paso a su indice en Base64	

			c = c << 6; //Primeros 2 bits 
			c = c | (d & mask3);

			fprintf(wfp, "%c", c);

			contador = 0;
			continue;
		}			
	}
}

int main (int argc, char const *argv[]) {
	
	static struct option long_options[] = {
            {"version",  no_argument, 0,  0 },
            {"help",  no_argument, 0,  0 },
            {"input",  optional_argument, 0,  0 },
            {"output", optional_argument, 0,  0 },
            {"action",  optional_argument, 0, 0},
            {0,  0,   0,  0 } //El ultimo elemento del struct deben ser ceros
      };

    int opt;
    FILE* fp = stdin;
    FILE* wfp = stdout;
    int option_index = 0;

    while ((opt = getopt_long(argc, argv, "Vha:i:o:" ,long_options, &option_index)) != -1) {
    	bool isencode;

    	switch (opt) {
    		case 'h':
    			fprintf(stdout, HELP);
    			break;
    		case 'V':
    			fprintf(stdout, VERSION);
    			break;
    		case 'a': 
    			if (! strcmp(optarg, "encode")) { 
    				isencode = true;
    			}	
    			if (! strcmp(optarg, "decode")) {
    				isencode = false;
    			}
    		case 'i': 
    			if (argc >= 5) { 
    				fp = fopen(argv[4], "r"); 
    				if(! fp) { fprintf(stderr, "File not found \n"); }
    			}
    		case 'o': 
    			if (argc >= 7) { 
    				wfp = fopen(argv[6], "w"); 
    				if(! wfp) { fprintf(stderr, "File Error \n"); }
    			}
    			break;
    		case 0:
    			abort();
    	}
    	if(isencode) encode(fp, wfp);
    	else decode(fp, wfp); 
    }	
    return 0;
}
