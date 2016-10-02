/*
 * files bases a little on xilinx_cdma.c
 */

#ifndef _CDMA_H_
#define _CDMA_H_

#include <linux/dma-mapping.h>
#include <linux/delay.h>

MODULE_LICENSE("GPL");

struct cdma_desc_hw {
	u32 next_desc;
	u32 next_descmsb;
	u32 src_addr;
	u32 src_addrmsb;
	u32 dest_addr;
	u32 dest_addrmsb;
	u32 control;
	u32 status; 
} __aligned(64);

/* Turn SG on/off. */
void cdma_sg_on(void);
void cdma_sg_off(void);

/*
 * Set CDMA SG pointers
 * @head: head pointer to cdma_desc_hw descriptor.
 * @tail: tail pointer to cdma_desc_hw descriptor.
 */
unsigned int cdma_set_sg(dma_addr_t head, dma_addr_t tail);

/* Get CDMA status register. */
unsigned int cdma_get_cdmasr(void);

void cdma_softrst(void);

/* Active wait until CDMA hw idles. */
void cdma_wait_for_idle(void);

#endif
