export ARCH:=microblaze
export CROSS_COMPILE:=/opt/Xilinx/petalinux-v2016.2-final/tools/linux-i386/microblazeel-xilinx-linux-gnu/bin/microblazeel-xilinx-linux-gnu-
default:
	$(CROSS_COMPILE)gcc eth_clnt_tcp_mb.c -o eth_clnt_tcp_mb
	$(CROSS_COMPILE)gcc eth_clnt_tcp_mb_2.c -o clnt_loopback
	$(CROSS_COMPILE)gcc eth_srv_tcp_mb_2.c -o srv_loopback
	gcc eth_srv_tcp_x86.c -o eth_srv_tcp_x86
