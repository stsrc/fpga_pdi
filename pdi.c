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

MODULE_LICENSE("GPL");

static struct cdev *pdi_cdev = NULL;
static dev_t dev;
static struct class *pdi_class = NULL;

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

const struct file_operations pdi_fops = {
	.open = pdi_open,
	.release = pdi_release,
};

static int __init pdi_init(void)
{
	int rt;
	struct device *device = NULL;

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
	pr_info("pdi loaded.\n");
	return 0;
err:
	if (pdi_cdev)
		cdev_del(pdi_cdev);		
	if (pdi_class)
		class_destroy(pdi_class);
	unregister_chrdev_region(dev, 1);
	return rt;
}

static void __exit pdi_exit(void)
{
	device_destroy(pdi_class, dev);
	cdev_del(pdi_cdev);
	class_destroy(pdi_class);
	pr_info("pdi unloaded.\n");
	unregister_chrdev_region(dev, 1);
}

module_init(pdi_init);
module_exit(pdi_exit);
