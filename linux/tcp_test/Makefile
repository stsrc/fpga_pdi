export ARCH:=microblaze
export CROSS_COMPILE:=/opt/Xilinx/petalinux-v2016.2-final/tools/linux-i386/microblazeel-xilinx-linux-gnu/bin/microblazeel-xilinx-linux-gnu-
default:
	$(CROSS_COMPILE)gcc tcp_clnt.c -o tcp_clnt_mb
	$(CROSS_COMPILE)gcc tcp_srv.c -o tcp_srv_mb
	gcc tcp_srv.c -o tcp_srv_x86
	gcc tcp_clnt.c -o tcp_clnt_x86
