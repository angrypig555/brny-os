#pragma once
#include "stdint.h"

void _cdecl _x86_div64_32(uint64_t dividend, uint32_t divisor, uint64_t* quotientOut, uint32_t* remainderOut);
void _cdecl _x86_Video_WriteCharTeletype(char c, uint8_t page);