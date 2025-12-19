#include <stdio.h>
#include <stdint.h>

typedef uint8_t bool;
#define true 1
#define false 0

typedef struct {
    uint8_t BootJumpInstruction[3];
    uint8_t OemIdentifier[8];
    uint16_t BytesPerSector;
    uint8_t SectorsPerCluster;
    uint16_t ReservedSectors;
    uint8_t FatCount;
    uint16_t DirEntryCount;
    uint16_t TotalSectors;
    uint8_t MediaDescriptorType;
    uint16_t SectorsPerFat;
    uint16_t SectorsPerTrack;
    uint16_t Heads;
    uint32_t HiddenSectors;
    uint32_t LargeSectorCount;

    // extended boot stuff
    uint8_t DriveNumber;
    uint8_t _Reserved;
    uint8_t Signature;
    uint32_t VolumeId;
    uint8_t VolumeLabel[11];
    uint8_t SystemId[8];

    
    }   __attribute__((packed)) BootSector;

BootSector g_BootSector;

bool readBootSector(FILE* disk) {

    return fread(&g_BootSector, sizeof(g_BootSector), 1, disk);

}

bool readSectors(FILE* disk, uint32_t lba, uint32_t count, void* bufferOut) {
    bool ok = true;
    ok = ok && (fseek(disk, lba * g_BootSector.BytesPerSector, SEEK_SET) == 0);
    ok = ok && (fread(bufferOut, g_BootSector.BytesPerSector, count, disk) == count);
    return ok; 
}

int main(int argc, char** argv) {
    if (argc < 3) {
        printf("Syntax: %s <disk image> <filename>\n", argv[0]);
        return -1;
    }

    FILE* disk = fopen(argv[1], "rb"); 
    if (!disk) {
        fprintf(stderr, "Cannot open disk image %s!", argv[1]);
        return -1;
    }

    if (!readBootSector(disk)) {
        fprintf(stderr, "Couldn't read boot sector!\n");
        return -2;
    }

    return 0;
}