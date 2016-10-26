//TODO more then one card!!!
//TODO DETECTION OF ALREADY USED DEVICE, ETC!
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

#include <linux/spinlock.h>

#include <linux/dma/xilinx_dma.h>

#define DRIVER_NAME "pdi"
/* 
 * WARNING ABOUT MAC ADDRESS! Its least significant bit says about 
 * unicast or multicast type of transmisson! If there LSB is 1, then
 * there is a multicast transmisson and TCP will fail!
 */
#define DEVICE_MAC_BYTE 0xa0

MODULE_LICENSE("GPL");

/*
 * reg0 - packet's size in bytes. To push packet into MAC write
 * packet bytes count into it.
 * reg1 - packet's word. Write to this register data which you want to
 *        transmit.
 * reg2 - control register.
 *        1 LSB bit - reset bit.
 *                    Write '1' to reset xgbe part of design.
 *                    After write delay execution for 1 ms, to ensure that
 *		      reset ended.
 *        2 LSB bit - data reception enable bit. 
 *                    Write '1' to enable data reception.
 * reg3 - Counter of not read packets yet. Each read zeroes this reg.
 */
struct pdi {
	struct net_device *netdev;
	struct resource *ports;
	struct resource *iomem;
	int irq;
	void __iomem *reg0;
	void __iomem *reg1;
	void __iomem *reg2;
	void __iomem *reg3;
};

/*
 * Function pushes packet into the FPGA.
 */
static netdev_tx_t pdi_start_xmit(struct sk_buff *skb, struct net_device *dev)
{
	uint32_t data = 0;
	uint32_t len = 0;
	/* 
	 * to_add - padding bytes count. 
	 * FPGA eth 'internals' are 8 bytes aligned. 
	 */
	unsigned int to_add = 0;
	unsigned char *data_ptr = NULL;
	struct pdi *pdi = (struct pdi *)netdev_priv(dev);

	len = skb->len;

	if (len % 8)
		to_add = 8 - len % 8;

	if (to_add != 0) {		
		if ((unsigned int)skb->end < (unsigned int)skb->tail + to_add) {
			pr_info("PDI: FAILED TO ADD SPACE TO SKB!!!\n");
			return NETDEV_TX_BUSY;
		}

		skb_put(skb, to_add);
	}
	
	data_ptr = skb->data;

	for (int i = 0; i < skb->len / 4; i++) {
		data = 0;

		for (int i = 0; i < 4; i++) {
			data |=	*data_ptr << (8 * i);
			data_ptr++;
		}	
		iowrite32(cpu_to_le32(data), pdi->reg1);
	}
	wmb();
	iowrite32(cpu_to_le32(len), pdi->reg0);
	dev->stats.tx_packets++;
	dev->stats.tx_bytes += (unsigned long)len;
	dev_kfree_skb(skb);
	return NETDEV_TX_OK;
}

static irqreturn_t pdi_int_handler(int irq, void *data)
{
	u32 packets_cnt = 0;
	unsigned int data_in = 0;
	unsigned int data_len = 0;
	unsigned char roundoff = 0;
	struct sk_buff *skb = NULL;
	unsigned char *buf = NULL;
	int ret = 0;
	struct pdi *pdi = (struct pdi *)data;
	
	packets_cnt = le32_to_cpu(ioread32(pdi->reg3));

	if (!packets_cnt) {
		pr_info("PDI: IRQ: interrupt falsely triggered!!!\n");
		return IRQ_HANDLED;		
	}

	for (u32 i = 0; i < packets_cnt; i++) {
		data_len = le32_to_cpu(ioread32(pdi->reg0));
	
		roundoff = data_len % 8;

		skb = dev_alloc_skb(data_len + NET_IP_ALIGN);
		if (!skb) {
			pr_info("alloc_skb failed! Packet not received! "
				"FPGA IN ERROR STATE\n");
			pdi->netdev->stats.rx_errors++;
			pdi->netdev->stats.rx_dropped++;
			return IRQ_HANDLED;
		}

		skb_reserve(skb, NET_IP_ALIGN);

		buf = skb_put(skb, data_len);
		skb->dev = pdi->netdev; 

		while (data_len >= 4) {
			data_in = le32_to_cpu(ioread32(pdi->reg1));	
			data_len -= 4;
			for (int j = 0; j < 4; j++) {
				*buf = data_in & 0xff;
				buf++;
				data_in = data_in >> 8;
			}
		}

		if (data_len) {
			data_in = le32_to_cpu(ioread32(pdi->reg1));
			for (int j = 0; j < data_len; j++) {
				*buf = data_in & 0xff;
				buf++;
				data_in = data_in >> 8;
			}
		}

		/* 
		 * 4 bytes flushed from FPGA fifo, because fifo's data width is
	 	 * 8 byte, and AXI data width is 4 byte.
		 */
		if (roundoff && roundoff <= 4)
			ioread32(pdi->reg1);

		skb->protocol = eth_type_trans(skb, pdi->netdev); 	
		ret = netif_rx(skb);
		pdi->netdev->stats.rx_bytes += (unsigned long)data_len;
	}
	pdi->netdev->stats.rx_packets += (unsigned long)packets_cnt;
	return IRQ_HANDLED;
}

static int pdi_init_irq(struct platform_device *pdev)
{
	int rt;
	struct pdi *pdi = pdev->dev.platform_data;

	pdi->irq = platform_get_irq(pdev, 0);
	if (pdi->irq <= 0) {
		pr_info("pdi: platform_get_irq failed.\n");
		return -ENXIO;
	}

	rt = request_irq(pdi->irq, pdi_int_handler, IRQF_SHARED, DRIVER_NAME, 
			 pdi);
	if (rt) {
		pr_info("pdi: request_irq failed.\n");
		pdi->irq = -1;	
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
	struct pdi *pdi = pdev->dev.platform_data;

	if (!pdi)
		return -EINVAL;

	pdi->iomem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	if (!pdi->iomem) {
		rt = -ENXIO;
		pr_info("pdi: platform_get_resource failed.\n");
		goto err0;
	}

	pdi->ports = request_mem_region(pdi->iomem->start, pdi->iomem->end -
					pdi->iomem->start, DRIVER_NAME);
	if (!pdi->ports) {
		rt = -ENOMEM;
		pr_info("pdi: request_mem_region failed.\n");
		goto err0;
	}

	pdi->reg0 = ioremap(pdi->iomem->start, 4);
	if (!pdi->reg0)
		goto err1;

	pdi->reg1 = ioremap(pdi->iomem->start + 4, 4);
	if (!pdi->reg1) 
		goto err2;

	pdi->reg2 = ioremap(pdi->iomem->start + 8, 4);
	if (!pdi->reg2)
		goto err3;

	pdi->reg3 = ioremap(pdi->iomem->start + 12, 4);
	if (!pdi->reg3)
		goto err4;
	return 0;

err4 :
	iounmap(pdi->reg2);
	pdi->reg2 = NULL;
err3 :
	iounmap(pdi->reg1);
	pdi->reg1 = NULL;
err2 :
	iounmap(pdi->reg0);
	pdi->reg0 = NULL;
err1 :
	pr_info("ioremap failed.\n");
	release_mem_region(pdi->iomem->start, pdi->iomem->end - 
			   pdi->iomem->start);
	pdi->iomem = NULL;
	rt = -ENOMEM;
err0 :
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
	struct pdi *pdi = pdev->dev.platform_data;
	
	pdi->netdev->irq = pdi->irq;
	pdi->netdev->base_addr = pdi->iomem->start;

	memset(pdi->netdev->dev_addr, DEVICE_MAC_BYTE, ETH_ALEN);
	
	pdi->netdev->netdev_ops = &pdi_netdev_ops;

	rt = register_netdev(pdi->netdev);
	
	if (rt) {
		pr_info("pdi register_netdev failed.\n");
		return -ENOMEM;
	}

	return 0;
}

static int pdi_probe(struct platform_device *pdev)
{
	//what happens when it returns negative value?
	
	int rt;
	struct pdi *pdi;
	struct net_device *netdev; 

	if (pdev->dev.platform_data) {
		pr_info("pdi: tried to probe already probed"
			" platform device.\n");
		return -EINVAL;
	}

	netdev = alloc_etherdev(sizeof(struct pdi));

	if (!netdev) {
		pr_info("pdi: alloc_etherdev failed.\n");
		return -ENOMEM;
	}

	pdi = netdev_priv(netdev);
	pdi->netdev = netdev;
	pdev->dev.platform_data = pdi;

	rt = pdi_init_irq(pdev);
	if (rt) 
		goto err0;

	rt = pdi_init_registers(pdev);
	if (rt) 
		goto err1;

	rt = pdi_init_ethernet(pdev);
	if (rt) 
		goto err2;

	/* Software reset on xgbe part of FPGA*/
	iowrite32(cpu_to_le32(1 << 0), pdi->reg2);
	wmb();
	/* 
	 * Softrst on fPGA has delay of ~2 ticks between clock domains. 
	 * To be sure that reset was done on both clock domains,
	 * little delay is used once.
	 */
	mdelay(1);

	/* Data reception and interrupt enable on FPGA */
	iowrite32(cpu_to_le32((1 << 1) | (1 << 2)), pdi->reg2);
	wmb();

	return 0;
err2:
	iounmap(pdi->reg3);
	iounmap(pdi->reg2);
	iounmap(pdi->reg1);
	iounmap(pdi->reg0);
	release_mem_region(pdi->iomem->start, pdi->iomem->end - 
			   pdi->iomem->start);
err1:
	free_irq(pdi->irq, pdi);
err0:
	free_netdev(pdi->netdev);
	pdev->dev.platform_data = NULL;
	return rt;
}

static int pdi_remove(struct platform_device *pdev)
{
	struct pdi *pdi = pdev->dev.platform_data;

	/*Disabling data reception on FPGA */
	iowrite32(0, pdi->reg2);
	wmb();

	if (!pdi)
		return 0;

	if (pdi->irq != -1)
		free_irq(pdi->irq, pdi);

	if (pdi->netdev)
		unregister_netdev(pdi->netdev);

	if (pdi->reg3)
		iounmap(pdi->reg3);

	if (pdi->reg2)
		iounmap(pdi->reg2);

	if (pdi->reg1)
		iounmap(pdi->reg1);

	if (pdi->reg0)
		iounmap(pdi->reg0);

	if (pdi->iomem)
		release_mem_region(pdi->iomem->start, pdi->iomem->end - 
				   pdi->iomem->start);

	if (pdi->netdev)
		free_netdev(pdi->netdev);

	pdev->dev.platform_data = NULL;

	return 0;
}

//TODO: look at drivers/tty/serial/uartlite.c
//how static struct ulite_of_match[] is defined.
//If CONFIG_OF is not defined, ulite_of_match 
//will dissapear. Futhermore, it won't compile (look at line 715).

static const struct of_device_id pdi_of_match[] = {
	{ .compatible = "xlnx,xgbe-pcs-pma-1.0", },
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
	
	rt = platform_driver_register(&pdi_platform_driver);
	if (rt) 
		pr_info("pdi: platform_driver_register failed.\n");

	return rt;
}

static void __exit pdi_exit(void)
{
	platform_driver_unregister(&pdi_platform_driver);
}

module_init(pdi_init);
module_exit(pdi_exit);
