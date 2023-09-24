# boot a VM from the .img floppy in qemu
qemu-system-i386 -fda build/main_floppy.img

# run this as 'bash run.sh', might need to run
# 'unset GTK_PATH' before to unset VSCode environment variable