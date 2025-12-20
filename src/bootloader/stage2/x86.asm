bits 16

section _TEXT class=CODE

; args: character, page

global __x86_Video_WriteCharTeletype
__x86_Video_WriteCharTeletype:
    push bp
    mov bp, sp

    mov ah, 0Eh
    mov al, [bp + 4]
    mov bh, [bp + 6]

    int 10h

    pop bx

    mov sp, bp
    pop bp
    ret