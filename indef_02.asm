[BITS 16]
[ORG 0x7C00]
_start:
	cli
	mov ax, cs
	mov ds, ax
	mov ss, ax
	mov sp, _start

	;; loading GDTR register
	lgdt [gd_reg]
	;; turning A20 on
	in al, 0x92
	or al, 2
	out 0x92, al

	;; setting PE bit of CR0 register
	mov eax, cr0
	or al, 1
	mov cr0, eax

	jmp 0x8: _protected

[BITS 32]
_protected:
	;; loading DS, SS registers with data segment selector
	mov ax, 0x10
	mov ds, ax
	mov ss, ax

	mov esi, msg_hello
	call kputs

	;; pause cpu
	hlt
	jmp short $

cursor: dd 0
%define VIDEO_RAM 0xB8000

kputs:
	pusha
.loop:
	lodsb
	test al, al
	jz .quit

	mov ecx, [cursor]
	mov [VIDEO_RAM+ecx*2], al
	inc dword [cursor]
	jmp short .loop

.quit:
	popa
	ret

gdt:

	dw 0, 0, 0, 0
	db 0xFF
	db 0xFF
	db 0x00
	db 0x00
	db 0x00
	db 10011010b
	db 0xCF
	db 0x00

	db 0xFF
	db 0xFF
	db 0x00
	db 0x00
	db 0x00
	db 10010010b
	db 0xCF
	db 0x00

gd_reg:
	dw 8192
	dd gdt

msg_hello: db "Indifirenza 0.0.0.1 32bit mode: ON", 0
times 510-($-$$) db 0
db 0xaa, 0x55
