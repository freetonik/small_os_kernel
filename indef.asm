[ORG 0x7C00]
start:
cli
mov ax, cs
mov ds, ax
mov ss, ax
mov sp, start

sti

mov si, msg
call kputs

cli
hlt
jmp short $

kputs:
.loop:
lodsb
test al, al
jz .quit
mov ah, 0x0E
int 0x10
jmp short .loop
.quit:
ret

msg: db "indifirenza 0.0.0.1", 0x0A,0x0D,0
times 510-($-$$) db 0
db 0x55, 0xAA
