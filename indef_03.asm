%define CYLS_TO_READ 10
%define MAX_READ_ERRORS 5

entry:
	cli
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, start
	sti

	mov ax, 0x07c0
	mov ds, ax

	mov ax, 0x9000
	mov es, ax

	xor si, si
	xor di, di
	mov cx, 128
	rep movsd
	jmp 0x9000:start

start:
	mov ax, cs
	mov ds, ax
	mov ss, ax

	mov si, msg_loading
	call kputs

	mov di, 1
	mov ax, 0x290
	xor bx, bx

.loop:
	mov cx, 0x50
	mov es, cx
	push di

	shr di, 1
	setc dh
	mov cx, di
	xchg cl, ch
	pop di
	
	cmp di, CYLS_TO_READ
	je .quit

	call kread_cylinder
	pusha
	push ds

	mov cx, 0x50
	mov ds, cx
	mov es, ax
	xor di, di
	xor si, si
	mov cx, 0x2400
	rep movsb
	pop ds
	popa
	inc di
	add ax, 0x240
	jmp short .loop

.quit:
	mov ax, 0x50
	mov es, ax
	mov bx, 0
	mov ch, 0
	mov dh, 0
	call kread_cylinder
	jmp 0x0000:0x0700

kread_cylinder:
	mov [.errors_counter], byte 0
	pusha

	mov si, msg_cylinder
	call kputs
	mov ah, ch
	call kputhex
	mov si, msg_crlf
	call kputs

	popa
	pusha

.start:
	mov ah, 0x02
	mov al, 18
	mov c1, 1
	int 0x13
	jc .read_error

	popa
	ret

.errors_counter: db 0
.read_error:
	inc byte [.errors_counter]
	mov si, msg_reading_error
	call kputs
	call kputhex
	mov si, msg_crlf
	call kputs
	cmp byte [.errors_counter], MAX_READ_ERRORS
	jl .start

	mov si, msg_giving_up
	call kputs
	hlt
	jmp short $

hex_table: db "0123456789ABCDEF"
kputhex:
	pusha
	xor bx, bx
	mov bl, ah
	and bl, 11110000b
	shr bl, 4
	mov al, [hex_table+bx]
	call kputchar

	popa
	ret

kputchar:
	pusha
	mov ah, 0x0E
	int 0x10
	popa
	ret

kputs:	
	pusha
.loop:
	lodsb
	test al, al
	jz .quit	
	mov ah, 0x0e
	int 0x10
	jmp short .loop

.quit:
	popa
	ret


msg_loading: 	db	"Indifirenza OS is loading...", 0x0A, 0x0D, 0
msg_cylinder:   db	"Cylinder:", 0
msg_head:	db	", head:", 0
msg_reading_error: db	"Error reading from floppy, error code:", 0
msg_giving_up:	db	"Too many errors, cannot load OS", 0x0A, 0x0D, 
"Reboot your system, please", 0
msg_crlf:	db	0x0A, 0x0D, 0

TIMES 510-($-$$) db 0
db 0xAA, 0x55
incbin '32loader.bin'
