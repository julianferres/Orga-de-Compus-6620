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
    bool isencode = true;
    while ((opt = getopt_long(argc, buffer, "Vha:i:o:", long_options, &option_index)) != -1) { 


    	switch (opt) {

    		case 'h':
    			fprintf(stdout, HELP);
    			return 0;

    		case 'V':
    			fprintf(stdout, VERSION);
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
    			fp = fopen(optarg, "r");
    			if(! fp) { fprintf(stderr, "File not found \n"); }
                continue;


    		case 'o': 
                if (! strcmp(optarg,"-")) continue;
                wfp = fopen(optarg, "w");
                if(! wfp) { fprintf(stderr, "File not found \n"); }
    			break;

    		case 0:
    			abort();
    	}

    }
    if(isencode) encode(fp, wfp);
    else decode(fp, wfp);
    fclose(fp);
    fclose(wfp); 
    return 0;
}