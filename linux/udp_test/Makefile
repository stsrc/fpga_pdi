export ARCH:=microblaze
export CROSS_COMPILE:=/opt/Xilinx/petalinux-v2016.2-final/tools/linux-i386/microblazeel-xilinx-linux-gnu/bin/microblazeel-xilinx-linux-gnu-
default:
	$(CROSS_COMPILE)gcc udp_srv.c -o udp_srv_mb
	$(CROSS_COMPILE)gcc udp_clnt.c -o udp_clnt_mb
	gcc udp_srv.c -o udp_srv_x86
	gcc udp_clnt.c -o udp_clnt_x86
