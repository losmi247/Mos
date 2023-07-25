ASM=nasm

SRC_DIR=src
BUILD_DIR=build

boot:
	qemu-system-i386 -fda $(BUILD_DIR)/bootloader.img

# turn bootloader.bin to a .img
$(BUILD_DIR)/bootloader.img: $(BUILD_DIR)/bootloader.bin
	cp $(BUILD_DIR)/bootloader.bin $(BUILD_DIR)/bootloader.img
	# fill the image with zeros up to 1.44MB
	truncate -s 1440k $(BUILD_DIR)/bootloader.img

# if the bootloader has been modified (it's a prerequisite in this
# makefile), again assemble the bootloader into a .bin binary
$(BUILD_DIR)/bootloader.bin: $(SRC_DIR)/bootloader.asm
	$(ASM) $(SRC_DIR)/bootloader.asm -f bin -o $(BUILD_DIR)/bootloader.bin