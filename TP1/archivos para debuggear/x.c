#include <stdio.h>

char readc(int fd);

int main(void)
{
	printf("char read: %c\n", readc(0));
	return 0;
}
