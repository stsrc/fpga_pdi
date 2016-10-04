export ARCH:=microblaze
export CROSS_COMPILE:=/opt/Xilinx/petalinux-v2016.2-final/tools/linux-i386/microblazeel-xilinx-linux-gnu/bin/microblazeel-xilinx-linux-gnu-
default:
	$(CROSS_COMPILE)gcc eth_srv_mb.c -o eth_srv_mb
	$(CROSS_COMPILE)gcc eth_clnt_mb.c -o eth_clnt_mb
	gcc eth_srv_x86.c -o eth_srv_x86
	gcc eth_clnt_x86.c -o eth_clnt_x86
