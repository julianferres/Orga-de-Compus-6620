#ifndef BASE64_H
#define BASE64_H

int encode(int infd, int outfd);
int decode(int infd, int outfd);
extern char B64[64];

#endif
