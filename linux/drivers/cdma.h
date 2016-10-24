/*
 * files bases a little on xilinx_cdma.c
 */

#ifndef _CDMA_H_
#define _CDMA_H_

#include <linux/dma-mapping.h>
#include <linux/delay.h>

MODULE_LICENSE("GPL");

enum cdma_keyhole {
	CDMA_KH_READ,
	CDMA_KH_WRITE,
	CDMA_KH_BOTH,
	CDMA_KH_NONE
};

/*
 * Transfer descriptors must be aligned on 16 32-bit word alignment.
 */
struct cdma_sg_desc {
	u32 next_desc_ptr;
	u32 next_desc_ptr_msb;
	u32 sa;
	u32 sa_msb;
	u32 da;
	u32 da_msb;
	u32 control;
	u32 status;
}__attribute__((packed));

struct cdma_sg_descriptor {
	struct cdma_sg_desc desc;
}__attribute__((aligned(64)));


int cdma_set_keyhole(enum cdma_keyhole keyhole);
int cdma_set_cur_tail(dma_addr_t cur, dma_addr_t tail);
unsigned int cdma_get_cdmasr(void);
void cdma_softrst(void);
int cdma_wait_for_idle(void);
int cdma_set_sg_desc(struct cdma_sg_descriptor *desc, u32 next_desc_ptr,
		      u32 sa, u32 da, u32 control);
int cdma_check_sg_finished(struct cdma_sg_descriptor *desc);

#endif
