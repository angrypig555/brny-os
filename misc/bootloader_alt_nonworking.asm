org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

; fat12 header
jmp short start
nop

bdb_oem: db 'MSWIN4.1' ; OEM Name
bdb_bytes_per_sector: dw 512
bdb_sectors_per_cluster: db 1
bdb_reserved_sectors: dw 1
bdb_fat_count: db 2
bdb_dir_entries_count: dw 0E0h
bdb_total_sectors: dw 2880
bdb_media_descriptor_type: db 0F0h
bdb_sectors_per_fat: dw 9
bdb_sectors_per_track: dw 18
bdb_heads: dw 2
bdb_hidden_sectors: dd 0
bdb_large_sector_count: dd 0

; extended boot record
ebr_drive_number: db 0
db 0 ; reserved
ebr_signature: db 29h
ebr_volume_id: db 12h, 34h, 56h, 78h ; serial number, can be anything
ebr_volume_label: db 'BRNYOS     ' ; volume label, must be 11 bytes
ebr_system_id: db 'FAT12   ' ; file system type, must be 8 bytes

start:
    jmp main


; prints a string
puts:
    push si
    push ax
.loop:
    lodsb
    or al, al
    jz .done
    
    mov ah, 0x0E ; call tty interrupt
    mov bh, 0
    int 0x10

    jmp .loop
.done:
    pop ax
    pop si
    ret

main:

    ; set up segments
    mov ax, 0
    mov ds, ax
    mov es, ax
    ; set up the stack
    mov ss, ax
    mov sp, 0x9000
    ; read some data
    mov [ebr_drive_number], dl
    mov ax, 1
    mov cl, 1
    mov bx, 0x7E00
    call disk_read
    ; print the hello world
    mov si, msg_hello
    call puts

    cli
    hlt
; Error handlers
floppy_error:
    mov si, msg_read_fail
    call puts
    jmp wait_key_and_reboot

wait_key_and_reboot:
    mov ah, 0
    int 16h
    jmp 0FFFFh:0 ; reboot

.halt:
    cli
    hlt

; disk routines
; lba to chs
; parameters: ax: lba address
; output: cx [bits 0-5]: sector number
;         cx [bits 6-15]: cylinder number
;         dh: head
lba_to_chs:
    push bx
    push ax
    push dx

    ; sector = (LBA % sectors_per_track) + 1
    xor dx, dx
    mov bx, [bdb_sectors_per_track]
    div bx           ; AX = LBA / spt, DX = LBA % spt
    inc dx
    mov cl, dl       ; CL = sector (bits 0-5)

    ; head = (AX % heads), cylinder = (AX / heads)
    xor dx, dx
    mov bx, [bdb_heads]
    div bx           ; AX = cylinder, DX = head
    mov dh, dl       ; DH = head
    mov ch, al       ; CH = cylinder low 8 bits

    ; put cylinder high 2 bits into CL bits 6-7
    mov al, ah
    and al, 03h
    shl al, 6
    or cl, al

    pop dx
    pop ax
    pop bx
    ret

; parameters: ax: LBA address cl: number of sectors to read dl: drive number es:bx point to memory address where to store it
disk_read:
    push cx
    push ax
    push bx
    push dx
    push di

    call lba_to_chs
    mov ah, 02h
    mov di, 3   ; retrying because floppy disks are unreliable
.retry:
    pusha
    stc
    int 13h
    jnc .done
    popa
    call disk_reset

    dec di
    test di, di
    jnz .retry
.done:
    pop di ; restore registers
    pop dx
    pop bx
    pop ax
    pop cx
    ret
.fail:
    jmp floppy_error
; Resest disk controller
; Parameters: dl: drive number
disk_reset:
    pusha
    mov ah, 0
    stc
    int 13h
    jc floppy_error
    popa
    ret


msg_hello: db 'Hello, world! Yay it works!', ENDL, 0
msg_read_fail: db '[ERROR] Reading from floppy failed! Bailing out! Press any key to restart...', ENDL, 0

times 510-($-$$) db 0
dw 0AA55h