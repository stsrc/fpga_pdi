/*
 * Warning! This driver is in conflict with xilinx_cdma.ko driver!
 * Ensure that xilinx_cdma.ko is removed before inserting this driver.
 * Good luck and have fun.
 */

#include <linux/errno.h>
#include <linux/types.h>
#include <linux/string.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/printk.h>
#include <asm/uaccess.h>
#include <linux/module.h>
#include <linux/cdev.h>
#include <linux/slab.h> 
#include <linux/device.h>
#include <linux/err.h>
#include <linux/moduleparam.h>
#include <linux/stat.h>
#include <linux/ioport.h>
#include <linux/interrupt.h>
#include <asm/io.h>
#include <linux/of.h>
#include <linux/of_address.h>
#include <linux/of_device.h>
#include <linux/of_platform.h>

#include "cdma.h"

#define DRIVER_NAME "cdma"

MODULE_LICENSE("GPL");

static struct resource *cdma_ports = NULL;
static struct resource *cdma_iomem = NULL;
static int cdma_irq = 0;

static void __iomem *CDMACR = NULL;
static void __iomem *CDMASR = NULL;
static void __iomem *CURDESC = NULL;
static void __iomem *TAILDESC = NULL;

int cdma_set_sg_desc(struct cdma_sg_descriptor *desc, u32 next_desc_ptr,
		      u32 sa, u32 da, u32 control)
{
	/* Alignment check */
	if (next_desc_ptr & 0x3F) {
		pr_info("next_desc_ptr = %u\n", next_desc_ptr);
		return -EINVAL;
	}

	desc->desc.next_desc_ptr = next_desc_ptr;
	desc->desc.next_desc_ptr_msb = 0;
	desc->desc.sa = sa;
	desc->desc.sa_msb = 0;
	desc->desc.da = da;
	desc->desc.da_msb = 0;
	desc->desc.control = control;

	return 0;
}
EXPORT_SYMBOL(cdma_set_sg_desc);

unsigned int cdma_get_cdmasr(void)
{
	unsigned int ret;
	ret = ioread32(CDMASR);
	rmb();
	return ret;	
}
EXPORT_SYMBOL(cdma_get_cdmasr);

//TODO REMOVE ACTIVE WAIT!!!
int cdma_wait_for_idle(void)
{
	u32 ret;
	u32 cnt = 0;

	do {
		mdelay(5);
		ret = ioread32(CDMASR);
		rmb();
		ret = ret & 1 << 1;
		cnt++;
	} while ((!ret) && (cnt < 1000));

	if (!ret)
		return -ETIMEDOUT;

	return 0;
}
EXPORT_SYMBOL(cdma_wait_for_idle);

void cdma_softrst(void)
{
	u32 ret = 1;

	/* reset CDMA hw */
	iowrite32(1 << 2, CDMACR);
	wmb();

	/* active wait until reset is done */
	do {
		mdelay(1);
		ret = ioread32(CDMACR);
		rmb();
		ret = ret & 1 << 2; 
	} while (ret);

}
EXPORT_SYMBOL(cdma_softrst);

static int cdma_init_hw(void)
{
	u32 ret;

	cdma_softrst();

	ret = ioread32(CDMACR);
	rmb();
	ret |= 1 << 12; /* IOC_IrqEn */
	ret |= 1 << 14; /* Err_IrqEn */
	wmb();
	iowrite32(ret, CDMACR);
	wmb();
	return 0;	
}

static int cdma_sg_off(void)
{
	u32 reg;
	int ret;

	ret = cdma_wait_for_idle();
	if (ret)
		return ret;
	reg = ioread32(CDMACR);
	rmb();
	reg &= ~(1 << 3); /* SGMode off */
	iowrite32(reg, CDMACR);
	wmb();
	ret = cdma_wait_for_idle();
	return ret;
}

static int cdma_sg_on(void)
{
	u32 reg;
	int ret;

	ret = cdma_wait_for_idle();
	if (ret)
		return ret;
	reg = ioread32(CDMACR);
	rmb();
	reg |= 1 << 3; /* SGMode on */
	iowrite32(reg, CDMACR);
	wmb();
	ret = cdma_wait_for_idle();
	return ret;
}

static int cdma_check_sgInc(void)
{
	u32 reg;
	int ret;

	reg = cdma_get_cdmasr();
	if (reg & (1 << 3))
		ret = 0;
	else
		ret = -EINVAL;

	return ret;
}

//TODO REMOVE ACTIVE WAIT!!!
int cdma_set_cur_tail(dma_addr_t cur, dma_addr_t tail)
{
	int ret;

	pr_info("CDMA: cdma_set_cur_tail entered.\n");

	ret = cdma_check_sgInc();
	if (ret) {
		pr_info("SG mode not included in hardware!\n");
		return ret;
	} else {
		pr_info("SG mode included in hardware.\n");
	}

	/*
	 * Alignment check.
	 */
	if ((unsigned int)cur & 0x3F || (unsigned int)tail & 0x3F)
		return -EINVAL;

	pr_info("CDMA: cdma_set_cur_tail 0.\n");
	if (cdma_sg_off())
		return -ETIMEDOUT;

	pr_info("CDMA: cdma_set_cur_tail 1.\n");
	if (cdma_wait_for_idle())
		return -ETIMEDOUT;

	pr_info("CDMA: cdma_set_cur_tail 2.\n");
	iowrite32((u32)cur, CURDESC);
	wmb();

	pr_info("CDMA: cdma_set_cur_tail 3.\n");
	ret = cdma_sg_on();
	if (ret)
		return ret;

	pr_info("CDMA: cdma_set_cur_tail 4.\n");	
	iowrite32((u32)tail, TAILDESC);
	wmb();

	pr_info("CDMA: cdma_set_cur_tail 5.\n");	
	return 0;
}
EXPORT_SYMBOL(cdma_set_cur_tail);

static irqreturn_t cdma_int_handler(int irq, void *data)
{
	const u32 clear_val = (1 << 14 | 1 << 13 | 1 << 12);
	u32 state = ioread32(CDMASR);
	rmb();
	pr_info("CDMA: cdma_int_handler invoked.\n");
	pr_info("     CDMASR = %x", state);
	iowrite32(clear_val, CDMASR);
	return IRQ_HANDLED;
}

static int cdma_init_irq(struct platform_device *pdev)
{
	int rt;

	cdma_irq = platform_get_irq(pdev, 0);
	if (cdma_irq <= 0) {
		pr_info("CDMA: platform_get_irq failed.\n");
		return -ENXIO;
	}

	rt = request_irq(cdma_irq, cdma_int_handler, 0, DRIVER_NAME, NULL);
	if (rt) {
		pr_info("CDMA: request_irq failed.\n");
		free_irq(cdma_irq, NULL);
		cdma_irq = -1;	
		return -ENXIO;
	}
	return 0;
}

/*
 * Function maps registers into memory.
 */
static int cdma_init_registers(struct platform_device *pdev) 
{
	cdma_iomem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	if (!cdma_iomem) {
		pr_info("CDMA: platform_get_resource failed.\n");
		return -ENXIO;
	}

	cdma_ports = request_mem_region(cdma_iomem->start, cdma_iomem->end -
					cdma_iomem->start, DRIVER_NAME);
	if (!cdma_ports) {
		pr_info("CDMA: request_mem_region failed.\n");
		return -ENOMEM;
	}

	CDMACR = ioremap(cdma_iomem->start, 4);
	if (!CDMACR)
		goto err0;

	CDMASR = ioremap(cdma_iomem->start + 0x04, 4);
	if (!CDMASR) 
		goto err1;

	CURDESC = ioremap(cdma_iomem->start + 0x08, 4);
	if (!CURDESC)
		goto err2;

	TAILDESC = ioremap(cdma_iomem->start + 0x10, 4);
	if (!TAILDESC)
		goto err3;
	return 0;

err3:
	iounmap(CURDESC);
	CURDESC = NULL;
err2:
	iounmap(CDMASR);
	CDMASR = NULL;
err1:
	iounmap(CDMACR);
	CDMACR = NULL;
err0:
	pr_info("ioremap failed.\n");
	release_mem_region(cdma_iomem->start, cdma_iomem->end - 
			   cdma_iomem->start);
	cdma_iomem = NULL;
	return -ENOMEM;
}

static int cdma_probe(struct platform_device *pdev)
{
	int rt;

	pr_info("CDMA: cdma_probe called!\n");	
	rt = cdma_init_irq(pdev);
	if (rt)
		return rt;
	pr_info("CDMA: cdma_probe 1!\n");	
	rt = cdma_init_registers(pdev);
	if (rt) {
		free_irq(cdma_irq, NULL);
		cdma_irq = - 1;
		return rt;
	}
	pr_info("CDMA: cdma_probe 2!\n");	
	cdma_init_hw();
	pr_info("CDMA: cdma_probe 3!\n");	
	return 0;
}

static int cdma_remove(struct platform_device *pdev)
{
	return 0;
}

static const struct of_device_id cdma_of_match[] = {
	{ .compatible = "xlnx,axi-cdma-1.00.a", },
	{}
};

static struct platform_driver cdma_platform_driver = {
	.probe = cdma_probe,
	.remove = cdma_remove,
	.driver = {
		.name = DRIVER_NAME,
		.of_match_table = of_match_ptr(cdma_of_match),
	},
};

MODULE_DEVICE_TABLE(of, cdma_of_match);
MODULE_ALIAS("platform:cdma");

static int __init cdma_init(void)
{
	int rt;
	
	rt = platform_driver_register(&cdma_platform_driver);
	if (rt) {
		pr_info("platform_driver_register failed.\n");
		platform_driver_unregister(&cdma_platform_driver);
	}

	return rt; 
}

static void __exit cdma_exit(void)
{
	platform_driver_unregister(&cdma_platform_driver);

	if (cdma_irq != -1)
		free_irq(cdma_irq, NULL);
	if (TAILDESC)
		iounmap(TAILDESC);
	if (CURDESC)
		iounmap(CURDESC);
	if (CDMASR)
		iounmap(CDMASR);
	if (CDMACR)
		iounmap(CDMACR);
	if (cdma_iomem)
		release_mem_region(cdma_iomem->start, cdma_iomem->end - 
				   cdma_iomem->start);
}

module_init(cdma_init);
module_exit(cdma_exit);
