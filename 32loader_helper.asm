[BITS 32]
[EXTERN kernel_main]
[GLOBAL _start]
_start:
	mov esp, 0x200000-4
	call kernel_main
