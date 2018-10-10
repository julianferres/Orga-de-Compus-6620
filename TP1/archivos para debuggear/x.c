#include <stdio.h>

char readc(int fd);
int write_c(int fd, char c);

int main(void)
{
	printf("anteeees\n");
	fflush(stdout);
	char a = readc(0);
	printf("char read: %c\n", a);
	printf("despueees\n");
	fflush(stdout);

	printf("anteeees\n");
	fflush(stdout);
	write_c(1, a);
	fflush(stdout);
	printf("\ndespueees\n");
	fflush(stdout);
	return 0;
}
