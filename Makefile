export ARCH:=microblaze
export CROSS_COMPILE:=/home/kgodfryd/petalinux/petalinux-v2016.2-final/tools/linux-i386/microblazeel-xilinx-linux-gnu/bin/microblazeel-xilinx-linux-gnu-
ccflags-y += -DDEBUG -std=gnu99 -Wno-declaration-after-statemenit

ifneq ($(KERNELRELEASE),)
	obj-m := pdi.o pdi_1.o pdi_2.o

else
	KERNELDIR ?= /home/kgodfryd/petalinux/workspace/first_project/build/linux/kernel/xlnx-4.4/
	PWD := $(shell pwd)

default:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules

endif
