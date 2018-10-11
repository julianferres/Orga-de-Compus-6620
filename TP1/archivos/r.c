#include <unistd.h>

char buffer[4];

char readc(int fd)
{
	read(fd,buffer,1);
	return buffer[0];
}
		
	
