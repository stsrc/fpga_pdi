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

#define DRIVER_NAME "pdi_2"
#define DEVICE_MAC_BYTE 0xba

MODULE_LICENSE("GPL");

static struct device *pdi_device = NULL;
static struct cdev *pdi_cdev = NULL;
static dev_t pdi_dev;
static struct class *pdi_class = NULL;
static struct resource *pdi_ports = NULL;
static struct resource *pdi_iomem = NULL;
static int pdi_irq = 0;
static struct net_device *pdi_netdev = NULL;

static void __iomem *reg0 = NULL;
static void __iomem *reg1 = NULL;
static void __iomem *reg2 = NULL;
static void __iomem *reg3 = NULL;

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
	return 0;
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

/*
 * Function pushes packet into the FPGA.
 */
static netdev_tx_t pdi_start_xmit(struct sk_buff *skb, struct net_device *dev)
{
	uint32_t data = 0;
	const uint32_t len = skb->len;
	/* to_add - padding bytes count. FPGA internals are 8 bytes aligned. */
	const unsigned int to_add = 8 - len % 8;
	unsigned char *data_ptr = NULL;

	if (to_add != 0) {		
		if ((unsigned int)skb->end < (unsigned int)skb->tail + 
		    to_add) {
			pr_info("PDI: FAILED TO ADD SPACE TO SKB!!!\n");
			return NETDEV_TX_BUSY;
		}

		skb_put(skb, to_add);
	}
	
	data_ptr = skb->data;

	pr_info("PDI: data_ptr mod 4 = %d!!!\n", (unsigned int)data_ptr % 4);

	for (int i = 0; i < skb->len / 4; i++) {
		data = 0;

		/*TODO word generation */
		for (int i = 0; i < 4; i++) {
			data |=	*data_ptr << (8 * i);
			pr_info("PDI: sent byte: 0x%x\n", *data_ptr);
			data_ptr++;
		}
		

		iowrite32(data, reg1);
		wmb();
	}

	iowrite32(len, reg0);
	wmb();

	dev_kfree_skb(skb);
	return NETDEV_TX_OK;
}

static irqreturn_t pdi_int_handler(int irq, void *data)
{
	unsigned int data_in = 0;
	unsigned int data_len = 0;
	unsigned char roundoff = 0;

	struct sk_buff *skb = NULL;
	unsigned char *buf = NULL;

	pr_info("pdi_int_handler executed.\n");
	data_len = ioread32(reg0);
	rmb();
	
	roundoff = data_len % 8;

	skb = dev_alloc_skb(data_len + 2);
	/* + 2 - ALIGN IP on 16 byte boundaries, look to plip.c*/
	if (!skb) {
		pr_info("alloc_skb failed! Packet not received! "
			"FPGA IN ERROR STATE\n");
		return IRQ_HANDLED;
	}
	skb_reserve(skb, 2); /*Align IP on 16 byte boundaries */
	buf = skb_put(skb, data_len);
	skb->dev = pdi_netdev; 

	while (data_len >= 4) {
		data_in = ioread32(reg1);
		rmb();	
		data_len -= 4;
		for (int i = 0; i < 4; i++) {
			*buf = data_in & 0xff;
			pr_info("PDI: received byte: 0x%x\n", *buf);
			buf++;
			data_in = data_in >> 8;
		}
	}

	if (data_len) {
		data_in = ioread32(reg1);
		rmb();
		for (int i = 0; i < data_len; i++) {
			*buf = data_in & 0xff;
			pr_info("PDI: received byte: 0x%x\n", *buf);
			buf++;
			data_in = data_in >> 8;
		}
	}

	/* 4 bytes flushed from fifo */
	if (roundoff <= 4) {
		ioread32(reg1);
		rmb();
	}

	netif_rx_ni(skb);
	return IRQ_HANDLED;
}

static int pdi_init_irq(struct platform_device *pdev)
{
	int rt;

	pdi_irq = platform_get_irq(pdev, 0);
	if (pdi_irq <= 0) {
		pr_info("platform_get_irq failed.\n");
		return -ENXIO;
	}

	rt = request_irq(pdi_irq, pdi_int_handler, 0, DRIVER_NAME, NULL);
	if (rt) {
		pr_info("request_irq failed.\n");
		free_irq(pdi_irq, NULL);
		pdi_irq = - 1;	
		return -ENXIO;
	}

	return 0;
}

/*
 * Function maps registers into memory.
 */
static int pdi_init_registers(struct platform_device *pdev) 
{
	int rt;

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
	free_irq(pdi_irq, NULL);
	pdi_irq = - 1;
	return rt;
}

static const struct net_device_ops pdi_netdev_ops = {
	.ndo_start_xmit = pdi_start_xmit,

};

/*
 * Function sets ethernet interface.
 */
static int pdi_init_ethernet(struct platform_device *pdev)
{	
	int rt;

	pdi_netdev = alloc_etherdev(0);
	
	if (!pdi_netdev) {
		pr_info("alloc_etherdev failed.\n");
		return -ENOMEM;
	}
	
//TODO DO I NEED THIS?
	pdi_netdev->irq = pdi_irq;
	pdi_netdev->base_addr = pdi_iomem->start;

	pdi_netdev->flags = IFF_POINTOPOINT | IFF_NOARP;
	memset(pdi_netdev->dev_addr, DEVICE_MAC_BYTE, ETH_ALEN);
	
	pdi_netdev->netdev_ops = &pdi_netdev_ops;
//TODO	pdi_netdev->header_ops = &pdi_header_ops;

	rt = register_netdev(pdi_netdev);
	
	if (rt) {
		free_netdev(pdi_netdev);
		pdi_netdev = NULL;
		pr_info("register_netdev failed.\n");
		return -ENOMEM;
	}

	return 0;
}

static int pdi_probe(struct platform_device *pdev)
{
	//what happens when it returns negative value?
	
	int rt;
	rt = pdi_init_irq(pdev);
	if (rt)
		return rt;

	rt = pdi_init_registers(pdev);
	if (rt)
		return rt;

	rt = pdi_init_ethernet(pdev);
	if (rt)
		return rt;
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


//TODO WARNING ABOUT PROBLEMS WITH DEVICE DETECTION (ALREADY IN USE ETC.)
static const struct of_device_id pdi_of_match[] = {
	{ .compatible = "xlnx,xgbe-1.1", },
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

	if (pdi_netdev) {
		unregister_netdev(pdi_netdev);
		free_netdev(pdi_netdev);
	}

	if (pdi_irq != -1)
		free_irq(pdi_irq, NULL);

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
