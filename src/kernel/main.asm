org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

start:
    jmp main


; prints a string


main:

    ; set up segments
    mov ax, 0
    mov ds, ax
    mov es, ax
    ; set up the stack
    mov ss, ax
    mov sp, 0x7C00
    ; print the hello world
    mov si, msg_hello
    call puts

    hlt
.halt:
    jmp .halt

msg_hello: db 'Hello, world! Yay it works!', ENDL, 0

times 510-($-$$) db 0
dw 0AA55h