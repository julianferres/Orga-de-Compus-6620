//#define _POSIX_SOURCE
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <getopt.h>
#include <stdbool.h>
#include <unistd.h>
#include "base64.h"

//Definición del menú de ayuda
const char HELP[] = "Usage:\n tp0 -h \n tp0 -V \n tp0 [options] \n Options: \n -V, --version Print version and quit. \n -h, --help Print this information. \n -i, --input Location of the input file. \n -a, --action Program action: encode (default) or decode. \n";

//Definición de la versión del programa
const char VERSION[] = "2018.9.25 \n";

//Defino tabla b64
char B64[64]= {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 
'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u',
'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'};

int main (int argc, char const *argv[]) {

	static struct option long_options[] = {
            {"version",  no_argument, 0,  0 }, 
            {"help",  no_argument, 0,  0 },
            {"input",  optional_argument, 0,  0 },
            {"output", optional_argument, 0,  0 },
            {"action",  optional_argument, 0, 0},
            {0,  0,   0,  0 } 
     };

    int opt;
    int fd = 0; //stdin
    int wfd = 1; //stdout
    char* const* buffer = (char* const*) argv;
    int option_index = 0;
    bool isencode = true;
    while ((opt = getopt_long(argc, buffer, "Vha:i:o:", long_options, &option_index)) != -1) { 


    	switch (opt) {

    		case 'h':
    			write(1, HELP, strlen(HELP));
    			return 0;

    		case 'V':
    			write(1, VERSION, strlen(VERSION));
    			return 0;

    		case 'a': 
    			if (! strcmp(optarg, "encode")) { 
    				continue;
    			}	
    			if (! strcmp(optarg, "decode")) {
    				isencode = false;
                    continue;
    			}

    		case 'i': 
                if (! strcmp(optarg,"-")) continue;
                FILE* fp = fopen(optarg, "r");
    			fd = fileno(fp);
                //fclose(fp);
    			if(! fd) { fprintf(stderr, "File not found \n"); return 1; }
                continue;


    		case 'o': 
                if (! strcmp(optarg,"-")) continue;
                FILE* wfp = fopen(optarg, "w");
                wfd = fileno(wfp);
                //fclose(wfp);
                if(! wfd) { fprintf(stderr, "File not found \n"); return 1; }
    			break;

    		case 0:
    			abort();
    	}
    }
    if(isencode) encode(fd, wfd);
    else decode(fd, wfd);
    close(fd);
    close(wfd);    
    return 0;
}
