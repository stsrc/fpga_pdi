/*
 * files bases a little on xilinx_cdma.c
 */

#ifndef _CDMA_H_
#define _CDMA_H_

#include <linux/dma-mapping.h>
#include <linux/delay.h>

MODULE_LICENSE("GPL");

unsigned int cdma_set_sa_da(dma_addr_t source, dma_addr_t dest, u32 byte_cnt);
unsigned int cdma_get_cdmasr(void);
void cdma_softrst(void);
int cdma_wait_for_idle(void);

#endif
