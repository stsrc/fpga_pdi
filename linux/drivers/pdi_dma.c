//TODO netdev, dev, pdev - think/read about it.
//TODO spinlocks, semaphores, race conditions etc.
//TODO more then one card!!!
//TODO DETECTION OF ALREADY USED DEVICE, ETC!

/*
 * DMA part of driver based on b44 driver, which can be fond in:
 * drivers/net/ethernet/broadcom/b44.c
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

#include <linux/netdevice.h>
#include <linux/etherdevice.h>
#include <linux/skbuff.h>

#include <linux/spinlock.h>

#include <linux/dmapool.h>

#include "cdma.h"

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

struct ring_info {
	union {
		struct sk_buff *skb;
		u32 *cnt;
	} data;
	dma_addr_t map;
};

struct dma_ring {
	//TODO should be only struct cdma_sg_descriptor *desc, not *desc[64]!
	struct cdma_sg_descriptor *desc;
	dma_addr_t desc_p;

	struct ring_info *buffer;
	u32 *cnt;
	dma_addr_t cnt_p;

	u32 desc_cur;
	u32 desc_cons;

	const u32 desc_max;
};

struct pdi {
	struct device *dev;
	struct net_device *netdev;
	struct napi_struct napi;
	struct resource *ports;
	struct resource *iomem;
	int irq;

	void __iomem *reg0;
	void __iomem *reg1;
	void __iomem *reg2;
	void __iomem *reg3;

	dma_addr_t reg0_dma;
	dma_addr_t reg1_dma;

	struct dma_ring tx_ring;
	struct dma_ring rx_ring;
};

/*
 * Function pushes packet into the FPGA.
 */
static netdev_tx_t pdi_start_xmit(struct sk_buff *skb, struct net_device *dev)
{
	int ret;
	uint32_t len = 0;
	uint32_t cnt = 0;
	struct dma_ring *tx_ring;
	/* 
	 * to_add - padding bytes count. 
	 * FPGA eth 'internals' are 8 bytes aligned. 
	 */
	unsigned int to_add = 0;
	struct pdi *pdi = (struct pdi *)netdev_priv(dev);

	tx_ring = &pdi->tx_ring;

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

	/******************** NEW PART ********************/	

	if (tx_ring->desc_cur + 2 == tx_ring->desc_cons) {
		pr_info("pdi: tx_ring full! Packet will be droped.\n");
		dev_kfree_skb(skb);
		return NETDEV_TX_OK;	
	}

	cnt = tx_ring->desc_cur;

	/* TODO: RETURN VALUES/CLEARING ETC. */	

	tx_ring->buffer[cnt].data.skb = skb;
	*tx_ring->buffer[cnt + 1].data.cnt = len;
	
	tx_ring->buffer[cnt].map = dma_map_single(pdi->dev, skb->data,
					skb->len, DMA_TO_DEVICE);

	if (dma_mapping_error(pdi->dev, tx_ring->buffer[cnt].map)) {
		pr_info("pdi: dma_map_single failed!\n");
		dev_kfree_skb(skb);	
		return NETDEV_TX_BUSY;
	}

	ret = cdma_set_sg_desc(&tx_ring->desc[cnt], tx_ring->desc_p + (cnt + 1) * 64,
			       tx_ring->buffer[cnt].map, pdi->iomem->start + 4, 
			       skb->len);
	if (ret)
		pr_info("pdi: cdma_set_sg_desc returned %d\n", ret);

	ret = cdma_set_sg_desc(&tx_ring->desc[cnt + 1], tx_ring->desc_p + cnt * 64, 
			       tx_ring->buffer[cnt + 1].map, pdi->iomem->start,
			       sizeof(u32));
	/* 
	 * TODO pdi->iomem->start - why pdi->reg0_dma is not working (address 
	 * problem?) 
	 */

	if (ret)
		pr_info("pdi: cdma_set_sg_desc returned %d\n", ret);

	dma_sync_single_for_device(pdi->dev, tx_ring->buffer[cnt].map, 
				   skb->len, DMA_TO_DEVICE);

	ret = cdma_set_keyhole(CDMA_KH_WRITE);
	if (ret)
		pr_info("pdi: cdma_set_keyhole returned %d\n", ret);

	//TODO CAN I DO SUCH A POINTER ARITHMETIC?
	ret = cdma_set_cur_tail(tx_ring->desc_p + cnt * 64, tx_ring->desc_p + (cnt + 1) * 64);
	if (ret)
		pr_info("pdi: cdma_set_cur_tail returned %d\n", ret);
	
	tx_ring->desc_cur = (tx_ring->desc_cur + 2) % tx_ring->desc_max;

	netdev_sent_queue(dev, skb->len);

	return NETDEV_TX_OK;
}

static int pdi_complete_xmit(struct pdi *pdi)
{
	struct sk_buff *skb; 
	struct dma_ring *tx_ring = &pdi->tx_ring;
	u32 packets = 0, bytes = 0;
	u32 i = 0;

	for (i = tx_ring->desc_cons; i != tx_ring->desc_cur; 
	     i = (i + 2) % tx_ring->desc_max) {
		pr_info("i = %d; pdi->desc_cons = %d; pdi->desc_cur = %d\n", i,
		tx_ring->desc_cons, tx_ring->desc_cur);

		if (!cdma_check_sg_finished(&tx_ring->desc[i + 1])) {
			pr_info("cdma_check_sg_finished failed.\n");
			break;
		}
		pr_info("cdma_check_sg_finished not failed.\n");

		skb = tx_ring->buffer[i].data.skb;

		dma_unmap_single(pdi->dev, tx_ring->buffer[i].map, skb->len, 
				 DMA_TO_DEVICE);

		bytes += skb->len;
		packets++;

		dev_kfree_skb(skb);
	}

	netdev_completed_queue(pdi->netdev, packets, bytes);
	tx_ring->desc_cons = i;
	return 0;
}

static atomic_t enable_int;
static atomic_t to_read;

static irqreturn_t pdi_int_handler(int irq, void *data)
{
	struct pdi *pdi = (struct pdi *)data;

	atomic_add(ioread32(pdi->reg3), &to_read);

	if (atomic_read(&enable_int)) {
		atomic_set(&enable_int, 0);
		napi_schedule(&pdi->napi);
	}
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

static int pdi_rx(struct pdi *pdi)
{
	u32 packets_cnt = 0;
	unsigned int data_in = 0;
	unsigned int data_len = 0;
	unsigned char roundoff = 0;
	struct sk_buff *skb = NULL;
	unsigned char *buf = NULL;
	int ret = 0;
 	
	pr_info("pdi: pdi_rx called.\n");

	packets_cnt = atomic_read(&to_read);
	atomic_sub(packets_cnt, &to_read);
	
	if (!packets_cnt) {
		pr_info("PDI: pdi_rx falsely triggered!!!\n");
		return 0;		
	}

	for (u32 i = 0; i < packets_cnt; i++) {
		data_len = le32_to_cpu(ioread32(pdi->reg0));
	
		roundoff = data_len % 8;

		skb = dev_alloc_skb(data_len + NET_IP_ALIGN);
		if (!skb) {
			/* TODO - do something with it */
			pr_info("alloc_skb failed! Packet not received! "
				"FPGA IN ERROR STATE\n");
			pdi->netdev->stats.rx_errors++;
			pdi->netdev->stats.rx_dropped++;
			return 0;
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
		ret = netif_receive_skb(skb);
		pdi->netdev->stats.rx_bytes += (unsigned long)data_len;
	}
	pdi->netdev->stats.rx_packets += (unsigned long)packets_cnt;
	return packets_cnt;
}

static int pdi_poll(struct napi_struct *napi, int budget)
{
	int ret;
	struct pdi *pdi = container_of(napi, struct pdi, napi);
	ret = pdi_rx(pdi);
	pdi_complete_xmit(pdi);
	napi_complete(&pdi->napi);
	atomic_set(&enable_int, 1);
	return ret;
}

static int pdi_init_dma_ring(struct pdi *pdi, struct dma_ring *ring)
{
	const size_t desc_size = sizeof(struct cdma_sg_descriptor);
	

	ring->desc = dma_zalloc_coherent(pdi->dev, ring->desc_max * 
				desc_size, &ring->desc_p, GFP_KERNEL | 
				GFP_DMA);

	if (!ring->desc) 
		return -ENOMEM;
	

	ring->buffer = kzalloc(sizeof(struct ring_info) * ring->desc_max,
				 GFP_KERNEL);

	if (!ring->buffer) {
		dma_free_coherent(pdi->dev, desc_size * ring->desc_max, 
			  ring->desc, ring->desc_p);
		return -ENOMEM;		
	} 

	ring->cnt = dma_zalloc_coherent(pdi->dev, sizeof(u32) * 
				ring->desc_max / 2, &ring->cnt_p,
				GFP_KERNEL | GFP_DMA);

	if (!ring->cnt) {
		kfree(ring->buffer);
		dma_free_coherent(pdi->dev, desc_size * ring->desc_max, 
			  ring->desc, ring->desc_p);
		return -ENOMEM;
	}

	for (int i = 1; i < ring->desc_max; i += 2) {
		ring->buffer[i].data.cnt = &ring->cnt[i];
		ring->buffer[i].map = ring->cnt_p + i * sizeof(u32);
	}

	return 0;
}


static void pdi_deinit_dma_ring(struct pdi *pdi, struct dma_ring *ring)
{
	const size_t desc_size = sizeof(struct cdma_sg_descriptor);

	kfree(ring->buffer);	

	dma_free_coherent(pdi->dev, desc_size * ring->desc_max, 
			  ring->desc, ring->desc_p);

	dma_free_coherent(pdi->dev, sizeof(u32) * ring->desc_max / 2, 
			  ring->cnt, ring->cnt_p);
}

static int pdi_init_dma_rings(struct platform_device *pdev)
{
	struct pdi *pdi = pdev->dev.platform_data;
	int ret;

	ret = pdi_init_dma_ring(pdi, &pdi->tx_ring);
	if (ret)
		return ret;

	ret = pdi_init_dma_ring(pdi, &pdi->rx_ring);
	if (ret) {
		pdi_deinit_dma_ring(pdi, &pdi->tx_ring);
		return ret;
	}	

	return 0;
}

static void pdi_deinit_dma_rings(struct platform_device *pdev)
{
	struct pdi *pdi = pdev->dev.platform_data;

	pdi_deinit_dma_ring(pdi, &pdi->tx_ring);
	pdi_deinit_dma_ring(pdi, &pdi->rx_ring);
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

	pdi->reg0_dma = dma_map_single(pdi->dev, pdi->reg0, 4, 
					DMA_TO_DEVICE);
	if (dma_mapping_error(pdi->dev, pdi->reg0_dma))
		goto err5;

	pdi->reg1_dma = dma_map_single(pdi->dev, pdi->reg1, 4, 
					DMA_TO_DEVICE);
	if (dma_mapping_error(pdi->dev, pdi->reg1_dma))
		goto err6;

	return 0;

err6 :
	dma_unmap_single(pdi->dev, pdi->reg0_dma, 4, DMA_TO_DEVICE);
err5 :
	iounmap(pdi->reg3);
	pdi->reg3 = NULL;
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
	pr_info("pdi_init_registers failed.\n");
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

	netif_napi_add(pdi->netdev, &pdi->napi, pdi_poll, 4);

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

	memset(pdi, 0, sizeof(struct pdi));

	//SET_NETDEV_DEV(netdev, pdev);//TODO

	*(u32 *)&pdi->tx_ring.desc_max = 256;
	*(u32 *)&pdi->rx_ring.desc_max = 256;

	pdi->netdev = netdev;
	pdev->dev.platform_data = pdi;
	pdi->dev = &pdev->dev;

	rt = pdi_init_irq(pdev);
	if (rt) 
		goto err0;

	rt = pdi_init_registers(pdev);
	if (rt) 
		goto err1;

	rt = pdi_init_ethernet(pdev);
	if (rt) 
		goto err2;

	rt = pdi_init_dma_rings(pdev);
	if (rt)
		goto err3;

	/* Software reset on xgbe part of FPGA*/
	iowrite32(cpu_to_le32(1), pdi->reg2);
	wmb();
	/* 
	 * Softrst on fPGA has delay of ~2 ticks between clock domains. 
	 * To be sure that reset was done on both clock domains,
	 * little delay is used once.
	 */
	mdelay(1);
	
	/* Data reception enable on FPGA */
	iowrite32(cpu_to_le32(2), pdi->reg2);
	wmb();

	atomic_set(&to_read, 0);
	atomic_set(&enable_int, 1);

	/* Move both functions to netdev open. */
	netif_start_queue(netdev);	
	napi_enable(&pdi->napi);

	return 0;

err3:
	unregister_netdev(pdi->netdev);
	netif_napi_del(&pdi->napi);
err2:
	dma_unmap_single(pdi->dev, pdi->reg0_dma, 4, DMA_TO_DEVICE);
	dma_unmap_single(pdi->dev, pdi->reg1_dma, 4, DMA_TO_DEVICE);
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

	napi_disable(&pdi->napi);
	
	if (!pdi)
		return 0;

	pdi_deinit_dma_rings(pdev);

	if (pdi->irq != -1)
		free_irq(pdi->irq, pdi);

	if (pdi->netdev) {
		unregister_netdev(pdi->netdev);
		netif_napi_del(&pdi->napi);
	}
	
	if (pdi->reg1_dma)
		dma_unmap_single(pdi->dev, pdi->reg1_dma, 4, DMA_TO_DEVICE);

	if (pdi->reg0_dma)
		dma_unmap_single(pdi->dev, pdi->reg0_dma, 4, DMA_TO_DEVICE);

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
