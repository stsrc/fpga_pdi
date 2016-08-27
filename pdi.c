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

MODULE_LICENSE("GPL");

static struct device *device = NULL;
static struct cdev *pdi_cdev = NULL;
static dev_t dev;
static struct class *pdi_class = NULL;
static struct resource *pdi_ports = NULL;

void __iomem *reg0, *reg1, *reg2, *reg3;

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
	ssize_t ret;
	int value;
	//TODO - endianess	
	ret = copy_from_user((char *)&value, buf, sizeof(int));
	if (ret)
		return -ENOSPC;
	return 0;
}

static int pdi_read(struct file *f, char __user *buf, size_t nbytes, 
			loff_t *ppos)
{
	ssize_t ret;
	int value;

	ret = copy_to_user(buf, &value, sizeof(int));
	if (ret)
		return -ENOSPC;
	return sizeof(int);
}

static int pdi_test_simple_periph(void) 
{
	unsigned int temp;
	temp = 0x12345678;
	iowrite32(temp, reg2);
	//TODO
	//ioread32be/le???
	//
	wmb();	
	if (temp != ioread32(reg1)) {
		pr_info("pdi: test 1 failed!\n");
		pr_info("pdi: waiting for: %d, got: %d", 0x12345678, temp);
		return -EINVAL;
	} else {
		pr_info("pdi: test 1 passed.\n");
	}

	temp = 0x87654321;
	iowrite32(temp, reg2);
	wmb();
	if (temp != ioread32(reg1)) {
		pr_info("pdi: test 2 failed!\n");
		pr_info("pdi: waiting for: %d, got: %d", 0x87654321, temp);
		return -EINVAL;
	} else {
		pr_info("pdi: test 2 passed.\n");
	}
	for (int i = 0; i < 10; i++)
		iowrite32(i, reg2);
	wmb();
	for (int i = 0; i < 10; i++) {
		temp = ioread32(reg1);
		if (temp != i) {
			pr_info("pdi: test 3 failed.\n");
			pr_info("pdi: waiting for: %d, got: %d", i, temp);
			return -EINVAL;
		}
	}

	pr_info("pdi: test 3 passed.\n");

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
	pr_info("pdi_int_handler executed.\n");
	return IRQ_HANDLED;
}

static int irq;

static int pdi_probe(struct platform_device *pdev)
{
	int rt;
	irq = platform_get_irq(pdev, 0);
	if (irq <= 0) {
		pr_info("platform_get_irq failed.\n");
		return -ENXIO;
	}

	rt = request_irq(irq, pdi_int_handler, 0, "pdi", NULL);
	if (rt) {
		pr_info("request_irq failed.\n");
		return rt;
	}
	return 0;
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
	{ .compatible = "xlnx,my-simple-peripherial-1.0", },
	{}
};

static struct platform_driver pdi_platform_driver = {
	.probe = pdi_probe,
	.remove = pdi_remove,
	.driver = {
		.name = "pdi",
		.of_match_table = of_match_ptr(pdi_of_match),
	},
};

MODULE_DEVICE_TABLE(of, pdi_of_match);
MODULE_ALIAS("platform:pdi");

static int __init pdi_init(void)
{
	int rt;

	rt = alloc_chrdev_region(&dev, 0, 1, "pdi");
	if (rt)
		return rt;

	pdi_class = class_create(THIS_MODULE, "pdi");
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
	rt = cdev_add(pdi_cdev, dev, 1);
	if (rt) {
		kfree(pdi_cdev);
		pdi_cdev = NULL;
		goto err;
	}
	device = device_create(pdi_class, NULL, dev, NULL, "reminder");
	if (IS_ERR(device)) {
		rt = PTR_ERR(device);
		goto err;
	}

	pdi_ports = request_mem_region(0x44a00000, 64*1024, "pdi");
	if (!pdi_ports) {
		pr_info("request_mem_region failed.\n");
		rt = -EAGAIN;
		goto err;
	}

	reg0 = ioremap_nocache(0x44a00000, 4);
	reg1 = ioremap_nocache(0x44a00004, 4);
	reg2 = ioremap_nocache(0x44a00008, 4);
	reg3 = ioremap_nocache(0x44a0000c, 4);

	if(!reg0 || !reg1 || !reg2 || !reg3) {
		pr_info("ioremap_nocache failed.\n");
		rt = -EAGAIN;
		goto err;
	}
	
	rt = pdi_test_simple_periph();
	if (rt)
		goto err;

	rt = platform_driver_register(&pdi_platform_driver);
	if (rt) {
		pr_info("platform_driver_register failed.\n");
		goto err;
	}

	pr_info("pdi loaded.\n");
	return 0;
err:
	if (reg3)
		iounmap(reg3);
	if (reg2)
		iounmap(reg2);
	if (reg1)
		iounmap(reg1);
	if (reg0)
		iounmap(reg0);
	if (pdi_ports)
		release_mem_region(0x44a00000, 64*1024);
	if (device)
		device_destroy(pdi_class, dev);
	if (pdi_cdev)
		cdev_del(pdi_cdev);		
	if (pdi_class)
		class_destroy(pdi_class);
	unregister_chrdev_region(dev, 1);
	return rt;
}

static void __exit pdi_exit(void)
{
	platform_driver_unregister(&pdi_platform_driver);
	free_irq(irq, NULL);
	iounmap(reg3);
	iounmap(reg2);
	iounmap(reg1);
	iounmap(reg0);
	release_mem_region(0x44a00000, 64*1024);
	device_destroy(pdi_class, dev);
	cdev_del(pdi_cdev);
	class_destroy(pdi_class);
	pr_info("pdi unloaded.\n");
	unregister_chrdev_region(dev, 1);
}

module_init(pdi_init);
module_exit(pdi_exit);
