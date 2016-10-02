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

static struct device *cdma_device = NULL;
static struct cdev *cdma_cdev = NULL;
static dev_t cdma_dev;
static struct class *cdma_class = NULL;
static struct resource *cdma_ports = NULL;
static struct resource *cdma_iomem = NULL;
static int cdma_irq = 0;

static void __iomem *CDMACR = NULL;
static void __iomem *CDMASR = NULL;
static void __iomem *TAILDESC_PNTR = NULL;
static void __iomem *CURDESC_PNTR = NULL;

unsigned int cdma_get_cdmasr(void)
{
	unsigned int ret;
	ret = ioread32(CDMASR);
	rmb();
	return ret;	
}
EXPORT_SYMBOL(cdma_get_cdmasr);

//TODO REMOVE ACTIVE WAIT!!!
void cdma_wait_for_idle(void)
{
	u32 ret;

	do {
		mdelay(5);
		ret = ioread32(CDMASR);
		rmb();
		ret = ret & 1 << 1;
	} while (!ret);
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
	pr_info("CDMA: reset loop exited.\n");
}
EXPORT_SYMBOL(cdma_softrst);

void cdma_sg_on(void) 
{
	u32 ret;
	cdma_wait_for_idle();
	pr_info("CDMA: cdma_sg_on: idle loop exited.\n");

	ret = ioread32(CDMACR);
	rmb();
	ret |= 1 << 3;
	wmb();
	/* turn SG on */
	iowrite32(ret, CDMACR);
	wmb();
}
EXPORT_SYMBOL(cdma_sg_on);

void cdma_sg_off(void) 
{
	u32 ret;
	cdma_wait_for_idle();
	pr_info("CDMA: cdma_sg_on: idle loop exited.\n");

	ret = ioread32(CDMACR);
	rmb();
	ret &= ~(1 << 3);
	wmb();
	/* turn SG on */
	iowrite32(ret, CDMACR);
	wmb();
}
EXPORT_SYMBOL(cdma_sg_off);

//TODO REMOVE ACTIVE WAIT!!!
unsigned int cdma_set_sg(dma_addr_t head, dma_addr_t tail)
{
	cdma_wait_for_idle();
	pr_info("CDMA: cdma_set_sg idle 1st loop exited.\n");
	cdma_sg_off();
	/* set current pointer and tail pointer */
	iowrite32((u32)head, CURDESC_PNTR);
	wmb();
	iowrite32((u32)tail, TAILDESC_PNTR);
	wmb();
	cdma_sg_on();
	return 0;
}
EXPORT_SYMBOL(cdma_set_sg);

static int cdma_open(struct inode *node, struct file *f)
{
	if (f->f_mode & FMODE_READ)
		return -EPERM;
	return 0;
}

static int cdma_release(struct inode *node, struct file *f)
{
	return 0;
}

static int cdma_write(struct file *f, const char __user *buf, size_t nbytes,
			loff_t *ppos)
{
	return 0;
}

static int cdma_read(struct file *f, char __user *buf, size_t nbytes, 
			loff_t *ppos)
{
	return 0;
}

const struct file_operations cdma_fops = {
	.write = cdma_write,
	.read = cdma_read,
	.open = cdma_open,
	.release = cdma_release,
};

static irqreturn_t cdma_int_handler(int irq, void *data)
{
	return IRQ_HANDLED;
}

static int cdma_init_irq(struct platform_device *pdev)
{
	int rt;

	cdma_irq = platform_get_irq(pdev, 0);
	if (cdma_irq <= 0) {
		pr_info("platform_get_irq failed.\n");
		return -ENXIO;
	}

	rt = request_irq(cdma_irq, cdma_int_handler, 0, DRIVER_NAME, NULL);
	if (rt) {
		pr_info("request_irq failed.\n");
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
		pr_info("platform_get_resource failed.\n");
		return -ENXIO;
	}

	cdma_ports = request_mem_region(cdma_iomem->start, cdma_iomem->end -
					cdma_iomem->start, DRIVER_NAME);
	if (!cdma_ports) {
		pr_info("request_mem_region failed.\n");
		return -ENOMEM;
	}

	CDMACR = ioremap(cdma_iomem->start, 4);
	if (!CDMACR)
		goto err0;

	CDMASR = ioremap(cdma_iomem->start + 0x04, 4);
	if (!CDMASR) 
		goto err1;

	CURDESC_PNTR = ioremap(cdma_iomem->start + 0x18, 4);
	if (!CURDESC_PNTR)
		goto err2;

	TAILDESC_PNTR = ioremap(cdma_iomem->start + 0x20, 4);
	if (!TAILDESC_PNTR)
		goto err3;
	return 0;

err3:
	iounmap(CURDESC_PNTR);
	CURDESC_PNTR = NULL;
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

static int cdma_init_hw(void)
{
	u32 reg;

	reg = ioread32(CDMASR);
	rmb();

	if (reg & (1 << 1))
		pr_info("CDMA does not idle on cdma_probe.\n");
	else
		pr_info("CDMA does idle on cdma_probe.\n");

	return 0;	
}


static int cdma_probe(struct platform_device *pdev)
{
	//what happens when it returns negative value?
	
	int rt;
	rt = cdma_init_irq(pdev);
	if (rt)
		return rt;

	rt = cdma_init_registers(pdev);
	if (rt) {
		free_irq(cdma_irq, NULL);
		cdma_irq = - 1;
		return rt;
	}
	
	cdma_init_hw();
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

	rt = alloc_chrdev_region(&cdma_dev, 0, 1, DRIVER_NAME);
	if (rt)
		return rt;


	cdma_class = class_create(THIS_MODULE, DRIVER_NAME);
	if (IS_ERR(cdma_class)) {
		rt = PTR_ERR(cdma_class);
		goto err;
	}
	cdma_cdev = cdev_alloc();
	if (!cdma_cdev) {
		rt = -ENOMEM;
		goto err;
	}
	cdev_init(cdma_cdev, &cdma_fops);
	rt = cdev_add(cdma_cdev, cdma_dev, 1);
	if (rt) {
		kfree(cdma_cdev);
		cdma_cdev = NULL;
		goto err;
	}
	cdma_device = device_create(cdma_class, NULL, cdma_dev, NULL, 
				    DRIVER_NAME);
	if (IS_ERR(cdma_device)) {
		rt = PTR_ERR(cdma_device);
		goto err;
	}
	
	rt = platform_driver_register(&cdma_platform_driver);
	if (rt) {
		pr_info("platform_driver_register failed.\n");
		platform_driver_unregister(&cdma_platform_driver);
		goto err;
	}

	pr_info("Driver loaded.\n");
	return 0;
err:
	if (cdma_device)
		device_destroy(cdma_class, cdma_dev);
	if (cdma_cdev)
		cdev_del(cdma_cdev);		
	if (cdma_class)
		class_destroy(cdma_class);
	unregister_chrdev_region(cdma_dev, 1);
	return rt;
}

static void __exit cdma_exit(void)
{
	platform_driver_unregister(&cdma_platform_driver);

	if (cdma_irq != -1)
		free_irq(cdma_irq, NULL);

	if (CURDESC_PNTR)
		iounmap(CURDESC_PNTR);

	if (TAILDESC_PNTR)
		iounmap(TAILDESC_PNTR);

	if (CDMASR)
		iounmap(CDMASR);

	if (CDMACR)
		iounmap(CDMACR);

	if (cdma_iomem)
		release_mem_region(cdma_iomem->start, cdma_iomem->end - 
				   cdma_iomem->start);

	device_destroy(cdma_class, cdma_dev);
	cdev_del(cdma_cdev);
	class_destroy(cdma_class);
	unregister_chrdev_region(cdma_dev, 1);
	pr_info("cdma unloaded.\n");
}

module_init(cdma_init);
module_exit(cdma_exit);
