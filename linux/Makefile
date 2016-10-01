export ARCH:=microblaze
export CROSS_COMPILE:=/opt/Xilinx/petalinux-v2016.2-final/tools/linux-i386/microblazeel-xilinx-linux-gnu/bin/microblazeel-xilinx-linux-gnu-
ccflags-y += -DDEBUG -std=gnu99 -Wno-declaration-after-statemenit

ifneq ($(KERNELRELEASE),)
	obj-m := pdi.o

else
	KERNELDIR ?= /home/komputer/petalinux_workspace/pdi/build/linux/kernel/xlnx-4.4/
	PWD := $(shell pwd)

default:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules
	$(CROSS_COMPILE)gcc eth_srv_mb.c -o eth_srv_mb
	$(CROSS_COMPILE)gcc eth_clnt_mb.c -o eth_clnt_mb
	gcc eth_srv_x86.c -o eth_srv_x86
	gcc eth_clnt_x86.c -o eth_clnt_x86
endif
