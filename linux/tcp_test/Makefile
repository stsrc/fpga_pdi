export ARCH:=microblaze
export CROSS_COMPILE:=/opt/Xilinx/petalinux-v2016.2-final/tools/linux-i386/microblazeel-xilinx-linux-gnu/bin/microblazeel-xilinx-linux-gnu-
default:
	$(CROSS_COMPILE)gcc tcp_clnt_mb.c -o tcp_clnt_mb
	$(CROSS_COMPILE)gcc tcp_srv_mb.c -o tcp_srv_mb
	$(CROSS_COMPILE)gcc test_mb.c -o test_mb
	gcc tcp_srv_x86.c -o tcp_srv_x86
	gcc tcp_clnt_x86.c -o tcp_clnt_x86
	gcc test_x86.c -o test_x86
