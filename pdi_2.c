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
#include <linux/keyboard.h>
#include <linux/reboot.h>
#include <linux/moduleparam.h>
#include <linux/stat.h>
#include <linux/ioport.h>
#include <linux/interrupt.h>
#include <asm/io.h>
#include <linux/of.h>
#include <linux/of_address.h>
#include <linux/of_device.h>
#include <linux/of_platform.h>

#define DRIVER_NAME "pdi_2"

MODULE_LICENSE("GPL");

static struct device *pdi_device = NULL;
static struct cdev *pdi_cdev = NULL;
static dev_t pdi_dev;
static struct class *pdi_class = NULL;
static struct resource *pdi_ports = NULL;
struct resource *pdi_iomem = NULL;
static int irq = -1;

void __iomem *reg0 = NULL;
void __iomem *reg1 = NULL;
void __iomem *reg2 = NULL;
void __iomem *reg3 = NULL;

static int pdi_open(struct inode *node, struct file *f)
{
	if (f->f_mode & FMODE_READ)
		return -EPERM;
	return 0;
}

static int pdi_release(struct inode *node, struct file *f)
{
	return 0;
}

static int pdi_write(struct file *f, const char __user *buf, size_t nbytes,
			loff_t *ppos)
{
	for (int i = 0; i < 16; i++) {
		iowrite32(0xffffffff - i, reg1);
		wmb();
	}

	iowrite32(64, reg0);
	wmb();
	return nbytes;
}

static int pdi_read(struct file *f, char __user *buf, size_t nbytes, 
			loff_t *ppos)
{
	return 0;
}

const struct file_operations pdi_fops = {
	.write = pdi_write,
	.read = pdi_read,
	.open = pdi_open,
	.release = pdi_release,
};

static irqreturn_t pdi_int_handler(int irq, void *data)
{
	int temp;

	pr_info("pdi_int_handler executed.\n");
	temp = ioread32(reg0);
	rmb();
	//TODO
	for (int i = 0; i < 64/4; i++) {
		pr_info("PDI: received word: 0x%08x\n", ioread32(reg1));
		rmb();
	}
	return IRQ_HANDLED;
}

static int pdi_probe(struct platform_device *pdev)
{
	int rt;

	irq = platform_get_irq(pdev, 0);
	if (irq <= 0) {
		pr_info("platform_get_irq failed.\n");
		return -ENXIO;
	}

	rt = request_irq(irq, pdi_int_handler, 0, DRIVER_NAME, NULL);
	if (rt) {
		pr_info("request_irq failed.\n");
		goto err0;
	}
	
	pdi_iomem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	if (!pdi_iomem) {
		rt = -ENXIO;
		pr_info("platform_get_resource failed.\n");
		goto err0;
	}

	pdi_ports = request_mem_region(pdi_iomem->start, pdi_iomem->end -
					pdi_iomem->start, DRIVER_NAME);
	if (!pdi_ports) {
		rt = -ENOMEM;
		pr_info("request_mem_region failed.\n");
		goto err0;
	}

	reg0 = ioremap(pdi_iomem->start, 4);
	if (!reg0)
		goto err1;

	reg1 = ioremap(pdi_iomem->start + 4, 4);
	if (!reg1) 
		goto err2;

	reg2 = ioremap(pdi_iomem->start + 8, 4);
	if (!reg2)
		goto err3;

	reg3 = ioremap(pdi_iomem->start + 12, 4);
	if (!reg3)
		goto err4;

	return 0;

err4 :
	iounmap(reg2);
	reg2 = NULL;
err3 :
	iounmap(reg1);
	reg1 = NULL;
err2 :
	iounmap(reg0);
	reg0 = NULL;
err1 :
	pr_info("ioremap failed.\n");
	release_mem_region(pdi_iomem->start, pdi_iomem->end - pdi_iomem->start);
	pdi_iomem = NULL;
	rt = -ENOMEM;
err0 :
	free_irq(irq, NULL);
	irq = - 1;
	return rt;
}

static int pdi_remove(struct platform_device *pdev)
{
	return 0;
}

//TODO: look at drivers/tty/serial/uartlite.c
//how static struct ulite_of_match[] is defined.
//If CONFIG_OF is not defined, ulite_of_match 
//will dissapear. Futhermore, it won't compile (look at line 715).

static const struct of_device_id pdi_of_match[] = {
	{ .compatible = "xlnx,xgbe-compilation-wrapper-1.1", },
	{}
};

static struct platform_driver pdi_platform_driver = {
	.probe = pdi_probe,
	.remove = pdi_remove,
	.driver = {
		.name = DRIVER_NAME,
		.of_match_table = of_match_ptr(pdi_of_match),
	},
};

MODULE_DEVICE_TABLE(of, pdi_of_match);
MODULE_ALIAS("platform:pdi");

static int __init pdi_init(void)
{
	int rt;

	rt = alloc_chrdev_region(&pdi_dev, 0, 1, DRIVER_NAME);
	if (rt)
		return rt;

	pdi_class = class_create(THIS_MODULE, DRIVER_NAME);
	if (IS_ERR(pdi_class)) {
		rt = PTR_ERR(pdi_class);
		goto err;
	}
	pdi_cdev = cdev_alloc();
	if (!pdi_cdev) {
		rt = -ENOMEM;
		goto err;
	}
	cdev_init(pdi_cdev, &pdi_fops);
	rt = cdev_add(pdi_cdev, pdi_dev, 1);
	if (rt) {
		kfree(pdi_cdev);
		pdi_cdev = NULL;
		goto err;
	}
	pdi_device = device_create(pdi_class, NULL, pdi_dev, NULL, DRIVER_NAME);
	if (IS_ERR(pdi_device)) {
		rt = PTR_ERR(pdi_device);
		goto err;
	}
	
	rt = platform_driver_register(&pdi_platform_driver);
	if (rt) {
		pr_info("platform_driver_register failed.\n");
		platform_driver_unregister(&pdi_platform_driver);
		goto err;
	}

	pr_info("Driver loaded.\n");
	return 0;
err:
	if (pdi_device)
		device_destroy(pdi_class, pdi_dev);
	if (pdi_cdev)
		cdev_del(pdi_cdev);		
	if (pdi_class)
		class_destroy(pdi_class);
	unregister_chrdev_region(pdi_dev, 1);
	return rt;
}

static void __exit pdi_exit(void)
{
	platform_driver_unregister(&pdi_platform_driver);
	if (irq != -1)
		free_irq(irq, NULL);
	if (reg3)
		iounmap(reg3);
	if (reg2) 
		iounmap(reg2);
	if (reg1)
		iounmap(reg1);
	if (reg0)
		iounmap(reg0);
	if (pdi_iomem)
		release_mem_region(pdi_iomem->start, pdi_iomem->end - 
				   pdi_iomem->start);
	device_destroy(pdi_class, pdi_dev);
	cdev_del(pdi_cdev);
	class_destroy(pdi_class);
	unregister_chrdev_region(pdi_dev, 1);
	pr_info("pdi unloaded.\n");
}

module_init(pdi_init);
module_exit(pdi_exit);
