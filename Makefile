# macros, use as $(macro)
ASM=nasm

SRC_DIR=src
BUILD_DIR=build


# boot the OS in qemu virtualiser
boot: store
	sudo qemu-system-i386 -fda /dev/sdb

# store the bootloader.bin (512B) into the first sector of the USB stick
store: $(BUILD_DIR)/bootloader.bin
	sudo dd if=$(SRC_DIR)/bootloader.bin of=/dev/sdb

# if the bootloader has been modified (it's a prerequisite in this
# makefile), again assemble the bootloader into a .bin binary
$(BUILD_DIR)/bootloader.bin: $(SRC_DIR)/bootloader.asm
	$(ASM) $(SRC_DIR)/bootloader.asm -f bin -o $(BUILD_DIR)/bootloader.bin