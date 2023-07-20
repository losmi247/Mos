org 0x7C00  ; BIOS loads the bootloader into RAM at 0x7C00
bits 16		; so that asm emits 16 bit code


main:
	hlt

.halt:
	jmp .halt

; we put the bootloader into first sector (512B) of a USB drive
; and we need a 0x55AA signature so that BIOS knows it's a bootloader
; so, we need to manually fill the rest 512-2-($-$$) bytes with zeros
times 512-2-($-$$) db 0
dw 0xAA55

