bits 16

section _TEXT class=CODE

; args: character, page

global __x86_div64_32
__x86_div64_32:
    push bp
    mov bp, sp

    push bx

    mov eax, [bp + 8]
    mov ecx, [bp + 12]
    xor edx, edx
    div ecx

    ; store upper 32 bits
    mov bx, [bp + 16]
    mov [bx + 4], eax

    mov eax, [bp + 4]

    div ecx
    ; store result
    mov [bx], eax
    mov bx, [bp + 18]
    mov [bx], edx

    pop bx

    mov sp, bp
    pop bp
    ret


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