ASM=nasm

SRC_DIR=src
BUILD_DIR=build

# make everything
.PHONY: all floppy_image bootloader kernel clean always

#
# Floppy Image
#
floppy_image: $(BUILD_DIR)/main_floppy.img
# create a .img so it resembles a floppy disk
$(BUILD_DIR)/main_floppy.img: bootloader kernel
# fill the image with zeros, 2880 blocks each 512B, 1.44MB total size
	dd if=/dev/zero of=$(BUILD_DIR)/main_floppy.img bs=512 count=2880
# create a FAT12 file system on it (file system for floppy disks)
	mkfs.fat -F 12 -n "NBOS" $(BUILD_DIR)/main_floppy.img

# store the bootloader in the first block, don't truncate it
# this will overwrite file system header, so we have to add it manually
# to the beginning of the bootloader
	dd if=$(BUILD_DIR)/bootloader.bin of=$(BUILD_DIR)/main_floppy.img conv=notrunc

# copy the kernel to the disk image using mtools
	mcopy -i $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/kernel.bin "::kernel.bin"

#
# Bootloader
#
bootloader: $(BUILD_DIR)/bootloader.bin
# assemble the bootloader
$(BUILD_DIR)/bootloader.bin: always
	$(ASM) $(SRC_DIR)/bootloader/bootloader.asm -f bin -o $(BUILD_DIR)/bootloader.bin

#
# Kernel
#
kernel: $(BUILD_DIR)/kernel.bin
# assemble the kernel
$(BUILD_DIR)/kernel.bin: always
	$(ASM) $(SRC_DIR)/kernel/main.asm -f bin -o $(BUILD_DIR)/kernel.bin

#
# Always
#
# make the build directory if it does not exist
always:
	mkdir -p $(BUILD_DIR)

#
# Clean
#
# for a clean build, remove everything in the build directory
clean:
	rm -rf $(BUILD_DIR)/*



# to verify that image file system contains kernel: 'mdir -i build/main_floppy.img'
# inspect the image using 'bless build/main_floppy.img'