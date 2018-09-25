#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <getopt.h>
#include <stdbool.h>
#include "code.h"

//Definición del menú de ayuda
const char HELP[] = "Usage:\n tp0 -h \n tp0 -V \n tp0 [options] \n Options: \n -V, --version Print version and quit. \n -h, --help Print this information. \n -i, --input Location of the input file. \n -a, --action Program action: encode (default) or decode. \n";

//Definición de la versión del programa
const char VERSION[] = "2018.9.25 \n";

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
    FILE* fp = stdin;
    FILE* wfp = stdout;
    char* const* buffer = (char* const*) argv;
    int option_index = 0;

    while ((opt = getopt_long(argc, buffer, "Vha:i:o:", long_options, &option_index)) != -1) { 
    	bool isencode;

    	switch (opt) {

    		case 'h':
    			fprintf(stdout, HELP);
    			return 0;

    		case 'V':
    			fprintf(stdout, VERSION);
    			return 0;

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
    				return 0;
    			}
                else{isencode=true; break;}

    		case 'o': 
    			if (argc >= 7) {
                    //if (strcmp(argv[6], "-")) fp = stdin; 
    				wfp = fopen(argv[6], "w"); 
    				if(! wfp) { fprintf(stderr, "File Error \n"); }
    			}
                else{isencode=true; break;}
    			break;

    		case 0:
    			abort();
    	}
    	if(isencode) encode(fp, wfp);
    	else decode(fp, wfp);
    	fclose(fp);
    	fclose(wfp); 
    	return 0;
    }

    encode(fp, wfp); //Accion por default
    return 0;
}