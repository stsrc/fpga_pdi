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

#include <linux/netdevice.h>
#include <linux/etherdevice.h>
#include <linux/skbuff.h>

#include <linux/dmapool.h>

#include "cdma.h"

#define DRIVER_NAME "CDMA_TEST"
#define DEVICE_MAC_BYTE 0xab

#define PDI_DESC_CNT 8

struct cdma_ring_info {
	u32 source;
	u32 dest;
} __aligned(16);

static struct device *cdma_device = NULL;
static struct cdev *cdma_cdev = NULL;
static dev_t cdma_dev;
static struct class *cdma_class = NULL;


struct dma_pool *pool;

void *test2;
char *tmp;
struct cdma_sg_descriptor *desc[2];
dma_addr_t desc_p[2];

struct cdma{
	struct cdma_ring_info *tx_buffers;
	struct platform_device *pdev;
};

struct cdma cdma;


static int cdma_init_buffers(struct device *dev)
{
	pool = dma_pool_create(DRIVER_NAME, dev, sizeof(struct 
		cdma_sg_descriptor), 0x40, 0);
	 
	if (!pool) {
		pr_info("cdma_test: dma_pool_create could not allocate memory."
			"\n");
		return -ENOMEM;
	}

	for (int i = 0; i < 2; i++) {
		desc_p[i] = 0;
		desc[i] = (struct cdma_sg_descriptor *)dma_pool_zalloc(pool, 
			   GFP_KERNEL, &desc_p[i]);

		pr_info("(u32)desc_p[%d] = 0x%x\n", i, (u32)desc_p[i]);

		if (!desc[i]) {
			pr_info("cdma_test: dma_pool_zalloc could not allocate"
				" memory.\n");

			for (int j = 0; j < i; j++)
				dma_pool_free(pool, (void *)desc[j], desc_p[j]);

			dma_pool_destroy(pool);
			return -ENOMEM;
		}	
	}
	
	test2 = kmalloc(1024, GFP_KERNEL | GFP_DMA);
	if (!test2) {
		pr_info("CDMA_TEST: cdma.tx_buffers could not be allocated!\n");
		return -ENOMEM;
	}
	cdma.tx_buffers = test2;
	while((u32)cdma.tx_buffers & 0x0F) {
		tmp = (char *)cdma.tx_buffers;
		tmp--;
		if ((u32)tmp < (u32) test2 - 1024) {
			pr_info("ARE U STUPID?\n");
			kfree(test2);
			return -ENOMEM;
		}
		cdma.tx_buffers = (struct cdma_ring_info *)tmp;
	}

	return 0;
}

static void cdma_deinit_buffers(void)
{
	kfree(test2);

	for (int i = 0; i < 2; i++)
		dma_pool_free(pool, (void *)desc[i], desc_p[i]);

	dma_pool_destroy(pool);
}

static int cdma_init_dma(struct platform_device *pdev)
{
	int rt;

	rt = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
	if (rt) {
		pr_info("CDMA_TEST: dma_set_mask_and_coherent failed!\n");
		return rt;
	}
	
	rt = cdma_init_buffers(&pdev->dev);
	if (rt) 
		return rt;

	return 0;
}

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
	int ret;

	struct device *dev = &cdma.pdev->dev;
	dma_addr_t source_p, dest_p;

	cdma.tx_buffers->source = 0x12345678;
	cdma.tx_buffers->dest = 0x87654321;

	pr_info("cdma_test: 1. source: %x, dest: %x", 
		cdma.tx_buffers->source, cdma.tx_buffers->dest);

	source_p = dma_map_single(dev, &cdma.tx_buffers->source, 4,
			 	  DMA_BIDIRECTIONAL);
	pr_info("source_p = 0x%x\n", (u32)source_p);
	if (source_p == 0) {
		pr_info("err 0\n");
		return nbytes;
	}
	dest_p = dma_map_single(dev, &cdma.tx_buffers->dest, 4, 
				DMA_BIDIRECTIONAL);
	pr_info("dest_p = 0x%x\n", (u32)dest_p);
	if (dest_p == 0) {
		pr_info("err 1\n");
		return nbytes;
	}

	ret = cdma_set_sg_desc(desc[0], desc_p[1], source_p, dest_p, 4); 
	if (ret) 
		pr_info("cdma_set_sg_desc 1 returned %d\n", ret);
	ret = cdma_set_sg_desc(desc[1], desc_p[0], source_p, dest_p, 4); 
	if (ret) 
		pr_info("cdma_set_sg_desc 2 returned %d\n", ret);
 	
	dma_sync_single_for_device(dev, source_p, 4, DMA_BIDIRECTIONAL);
	dma_sync_single_for_device(dev, dest_p, 4, DMA_BIDIRECTIONAL);
	dma_sync_single_for_device(dev, desc_p[0],
				   sizeof(struct cdma_sg_descriptor),
				   DMA_BIDIRECTIONAL);
	dma_sync_single_for_device(dev, desc_p[1], 
				   sizeof(struct cdma_sg_descriptor),
				   DMA_BIDIRECTIONAL);

	ret = cdma_set_cur_tail(desc_p[0], desc_p[1]);
	if (ret)
		pr_info("CDMA_TEST: cdma_set_cur_tail returned %d!\n", ret);

	mdelay(100);
	dma_sync_single_for_cpu(dev, source_p, 4, DMA_BIDIRECTIONAL);
	dma_sync_single_for_cpu(dev, dest_p, 4, DMA_BIDIRECTIONAL);
	dma_sync_single_for_cpu(dev, desc_p[0], sizeof(struct cdma_sg_descriptor),
				DMA_BIDIRECTIONAL);
	dma_sync_single_for_cpu(dev, desc_p[1], sizeof(struct cdma_sg_descriptor),
				DMA_BIDIRECTIONAL);

	pr_info("cdma_test: 2. source: %x, dest: %x", 
		cdma.tx_buffers->source, cdma.tx_buffers->dest);

	dma_unmap_single(dev, source_p, 4, DMA_BIDIRECTIONAL);
	dma_unmap_single(dev, dest_p, 4, DMA_BIDIRECTIONAL);
	return nbytes;
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


static int cdma_probe(struct platform_device *pdev)
{
	int rt;

	pr_info("CDMA_TEST probe called.\n");
	rt = cdma_init_dma(pdev);
	pr_info("CDMA_TEST probe 1.\n");
	if (rt)
		return rt;	
	cdma.pdev = pdev;

	return 0;
}

static int cdma_remove(struct platform_device *pdev)
{
	cdma_deinit_buffers();
	return 0;
}

static const struct of_device_id cdma_of_match[] = {
	{ .compatible = "xlnx,xgbe-pcs-pma-1.0", },
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
	cdma_device = device_create(cdma_class, NULL, cdma_dev, NULL, DRIVER_NAME);
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

	pr_info("cdma_test loaded.\n");
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
	device_destroy(cdma_class, cdma_dev);
	cdev_del(cdma_cdev);
	class_destroy(cdma_class);
	unregister_chrdev_region(cdma_dev, 1);
	pr_info("cdma_test unloaded.\n");
}

module_init(cdma_init);
module_exit(cdma_exit);
