#include <stdio.h>

int main() {
	unsigned char numero = 0x43;
	unsigned char mander = 0x45;

	unsigned char and = mander & numero;
	printf("%d \n", and);
	return 0;
}