#ifndef CODE_H
#define CODE_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

void encode(FILE* fp, FILE* wfp);
unsigned char get_i64(unsigned char c);
void decode(FILE* fp, FILE* wfp);

#endif
