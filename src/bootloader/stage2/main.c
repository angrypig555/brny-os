#include "stdint.h"
#include "stdio.h"

/*This is not actually an error, your vscode needs to be configured with _cdecl declared*/
void _cdecl cstart_(uint16_t bootDrive) {
    puts("Hello world from stage2 in C!");
    for (;;);
}