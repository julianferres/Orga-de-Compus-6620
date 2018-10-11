#include <unistd.h>

char write_c(int fd , char c)
{
	write(fd,&c,1);
	return 0;
}
		
	
