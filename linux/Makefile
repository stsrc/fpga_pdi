export ARCH:=microblaze
export CROSS_COMPILE:=/opt/Xilinx/petalinux-v2016.2-final/tools/linux-i386/microblazeel-xilinx-linux-gnu/bin/microblazeel-xilinx-linux-gnu-
ccflags-y += -DDEBUG -std=gnu99 -Wno-declaration-after-statemenit

ifneq ($(KERNELRELEASE),)
	obj-m := pdi.o pdi_1.o pdi_2.o

else
	KERNELDIR ?= /home/komputer/petalinux_workspace/pdi/build/linux/kernel/xlnx-4.4/
	PWD := $(shell pwd)

default:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules
	$(CROSS_COMPILE)gcc eth_srv_test.c -o eth_srv_test
	$(CROSS_COMPILE)gcc eth_clnt_test.c -o eth_clnt_test
endif
