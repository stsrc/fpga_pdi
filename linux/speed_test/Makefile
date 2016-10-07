export ARCH:=microblaze
export CROSS_COMPILE:=/opt/Xilinx/petalinux-v2016.2-final/tools/linux-i386/microblazeel-xilinx-linux-gnu/bin/microblazeel-xilinx-linux-gnu-
default:
	$(CROSS_COMPILE)gcc downlink_mb.c -o downlink_mb
	gcc downlink_x86.c -o downlink_x86 -g3
	$(CROSS_COMPILE)gcc uplink_mb.c -o uplink_mb 
	gcc uplink_x86.c -o uplink_x86 -g3
