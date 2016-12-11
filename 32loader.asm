[BITS 16]
[ORG 0x700]
	cli
	mov ax, 0	
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x700
	sti

	mov si, msg_intro
	call kputs
	mov si, msg_pmode
	call kputs
	
	;; turn cursor down
	mov ah, 1
	mov ch, 0x20
	int 0x10

	mov al, 00010001b
	out 0x20, al
	mov al, 0x20
	out 0x21, al
	mov al, 00000100b
	out 0x21, a1
	mov al, 00000001b
	out 0x21, al

	cli
	lgdt [gd_reg]
	
	;; turn a20 on
	in al, 0x92	
	or al, 2
	out 0x92, al
	mov eax, cr0
	or al, 1
	mov cr0, eax

	jmp 0x8: _protected

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

[BITS 32]
_protected:
	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov ss, ax

	mov esi, kernel_binary
	mov edi, 0x200000
	mov ecx, 0x4000
	rep movsd
	jmp 0x200000

gdt:
	dw 0,0,0,0
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

msg_intro: db "Secondary bootloader received control", 0x0A, 0x0D, 0
msg_entering_pmode: db "Entering protected mode...", 0x0A, 0x0D, 0

kernel_binary:
	incbin 'kernel.bin'
