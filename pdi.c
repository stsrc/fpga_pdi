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

static int pdi_write_test_packet(void) 
{
	uint32_t tab[16];
	
	tab[0] = 0x00010010;
	tab[1] = 0x00000100;
	tab[2] = 0x88b50001;
	tab[3] = 0x94000002;
	tab[4] = 0x06070809;
	tab[5] = 0x02030405;
	tab[6] = 0x0e0f1011;
	tab[7] = 0x0a0b0c0d;
	tab[8] = 0x16171819;
	tab[9] = 0x12131415;
	tab[10] = 0x1e1f2021;
	tab[11] = 0x1a1b1c1d;
	tab[12] = 0x26272829;
	tab[13] = 0x22232425;
	tab[14] = 0x2e2f3031;
	tab[15] = 0x2a2b2c2d;
	for (int i = 0; i < 16; i++) {
		//TODO
		//ioread32be/le???
		//
		iowrite32(tab[i], reg3);
		wmb();
	}

	iowrite32(64, reg2);
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
	for (int i = 0; i < temp/4; i++) {
		pr_info("PDI: received word: 0x%08x\n", ioread32(reg1));
		rmb();
	}
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
	pdi_write_test_packet();
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
	{ .compatible = "xlnx,xgbe-compilation-wrapper-1.0", },
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
	device = device_create(pdi_class, NULL, dev, NULL, "pdi");
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
