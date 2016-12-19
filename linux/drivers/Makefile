export ARCH:=microblaze
export CROSS_COMPILE:=/opt/Xilinx/petalinux-v2016.2-final/tools/linux-i386/microblazeel-xilinx-linux-gnu/bin/microblazeel-xilinx-linux-gnu-
ccflags-y += -DDEBUG -std=gnu99

ifneq ($(KERNELRELEASE),)
	obj-m := pdi_dma.o

else
	KERNELDIR ?= /home/komputer/petalinux_workspace/pdi/build/linux/kernel/xlnx-4.4/
	PWD := $(shell pwd)

default:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules
endif
