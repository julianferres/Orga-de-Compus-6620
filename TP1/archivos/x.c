#include <stdio.h>

char readc(int fd);
int write_c(int fd, char* c);

int main(void) {
	printf("anteeees\n");
	fflush(stdout);
	char a = readc(0);
	char b = readc(0);
	char c = readc(0);
	char d = readc(0);
	printf("char read: %c\n", a);
	printf("char read: %c\n", b);
	printf("despueees\n");
	fflush(stdout);

	printf("anteeees\n");
	fflush(stdout);
	write_c(1, &a);
	printf("\n");
	write_c(1, &b);
	printf("\n");
	write_c(1, &c);
	printf("\n");
	write_c(1, &d);

	fflush(stdout);
	printf("\ndespueees\n");
	fflush(stdout);
	return 0;
}
