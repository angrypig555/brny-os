#pragma once


//bios & interrupt area
#define MEMORY_MIN  0x00000500
#define MEMORY_MAX  0x00080000

// for fat driver
#define MEMORY_FAT_MIN  ((void far*)0x00500000)
#define MEMORY_FAT_MAX  (void far*)0x00010500