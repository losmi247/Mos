org 0x7C00  ; BIOS loads the bootloader into RAM at 0x7C00.
bits 16		; Make asm emit 16 bit code while booting the system.


; macros
%define ENDL 0x0D,0x0A


; main is the  entry point of program
start:
	jmp main


; Function that prints a string to the screen using BIOS interrupts.
; Parameters:
; 			a string at memory address ds:si (si - index register) 
; The String finishes with a NULL byte, i.e. 00000000.
puts:
	; save register values on stack
	; Index register si will be changed for iterating through bytes,
	; and 
	push si
	push ax

.loop:
	; load next character (from default address ds:si) in register al (8-bit)
	; increments si by one after each  byte is loaded
	lodsb
	or al,al
	; if previous or was 0, zero flag will be set, and we have reached String end
	jz .done

	; Set accumulator register ah to code 0eh to call  BIOS interrupt for writing
	; a character in TTY mode.
	mov ah,0x0E
	; set page number for writing to 0
	mov bh,0
	; Call a BIOS interrupt for Video, writing TTY, whose interrupt handler writes
	; contents of register al to screen.
	int 0x10
	
	; continue reading bytes/characters	
	jmp .loop

.done:
	; restore register values from stack
	pop ax
	pop si
	ret



main:
	; We use x86 memory segmentation ([16 bit segment]:[16 bit offset])
	; with 64kB segments, so we have to initialise registers for it.

	; Setup the Data Segment register ds and Extra Register es.
	; But we can't write a constant to them directly, only through 
	; accumulator register (ax). Register ds is default address for
	; memory accesses, along with index register si (ds:si).
	mov ax,0
	mov ds,ax
	mov es,ax

	; Setup Stack Segment register ss (current memory segment of stack top)
	; and Stack Pointer register sp (current offset of stack top in the segment).
	mov ss,ax
	; Set top of stack to bootloader beginning in memory, so memory above OS
	; is reserved for the stack (stack grows downwards to address 0).
	mov sp,0x7C00


	; Print a hello message on boot.
	; Set the index register (si) to point to message location in memory.
	mov si,msg_hello
	; call function to print the string
	call puts

	
	hlt

.halt:
	jmp .halt



; message to print at boot - db directive can write as many characters as needed
msg_hello:
	db 'Hello MOS!', ENDL, 0


; We put the bootloader into first sector (512B) of a USB drive.
; Need a 0x55AA signature at end so that BIOS knows it's a bootloader,
; so we manually fill the rest 512-2-($-$$) bytes of this program 
; with zero bytes.
times 512-2-($-$$) db 0
dw 0xAA55