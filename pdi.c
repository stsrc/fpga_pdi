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

#include <asm/io.h>

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
	iowrite32(temp, reg0);
		
	if (temp != ioread32(reg0)) {
		pr_info("pdi: test 1 failed!\n");
		return -EINVAL;
	} else {
		pr_info("pdi: test 2 passed.\n");
	}

	temp = 0x87654321;
	iowrite32(temp, reg1);
	
	if (temp != ioread32(reg1)) {
		pr_info("pdi: test 2 failed!\n");
		return -EINVAL;
	} else {
		pr_info("pdi: test 2 passed.\n");
	}

	temp = ioread32(reg2);
	if (temp != 0x99999999) {
		pr_info("pdi: test 3 failed.\n");
		return -EINVAL;
	} else {
		pr_info("pdi: test 3 passed.\n");
	}
	return 0;
}

const struct file_operations pdi_fops = {
	.write = pdi_write,
	.read = pdi_read,
	.open = pdi_open,
	.release = pdi_release,
};

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
