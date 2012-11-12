#include <inc/x86.h>
#include <inc/assert.h>
#include <inc/string.h>
#include <kern/pci.h>
#include <kern/pcireg.h>
#include <kern/e100.h>

// Flag to do "lspci" at bootup
static int pci_show_devs = 1;
static int pci_show_addrs = 1;

// PCI "configuration mechanism one"
// PCI的地址寄存器0xcf8h PCI的空间数据寄存器0xcfc
static uint32_t pci_conf1_addr_ioport = 0x0cf8;
static uint32_t pci_conf1_data_ioport = 0x0cfc;

// Forward declarations
static int pci_bridge_attach(struct pci_func *pcif);

// PCI driver table
struct pci_driver {
	uint32_t key1, key2;
	int (*attachfn) (struct pci_func *pcif);
};

// pci_attach_class matches the class and subclass of a PCI device
struct pci_driver pci_attach_class[] = {
	{ PCI_CLASS_BRIDGE, PCI_SUBCLASS_BRIDGE_PCI, &pci_bridge_attach },
	{ 0, 0, 0 },
};

// pci_attach_vendor matches the vendor ID and device ID of a PCI device
struct pci_driver pci_attach_vendor[] = {
	{PCI_VENDOR_ID_INTEL,INTEL_82559_ETHERNET_DEVICE_ID,&pci_e100_attach},
	{ 0, 0, 0 },
};

static void
pci_conf1_set_addr(uint32_t bus,
		   uint32_t dev,
		   uint32_t func,
		   uint32_t offset)
{
	assert(bus < 256);
	assert(dev < 32);
	assert(func < 8);
	assert(offset < 256);
	assert((offset & 0x3) == 0);
	
	uint32_t v = (1 << 31) |		// config-space
		(bus << 16) | (dev << 11) | (func << 8) | (offset);
	outl(pci_conf1_addr_ioport, v);
}

static uint32_t
pci_conf_read(struct pci_func *f, uint32_t off)
{
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
	return inl(pci_conf1_data_ioport);
}

static void
pci_conf_write(struct pci_func *f, uint32_t off, uint32_t v)
{
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
	outl(pci_conf1_data_ioport, v);
}

static int __attribute__((warn_unused_result))
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
	uint32_t i;
	
	for (i = 0; list[i].attachfn; i++) {
		if (list[i].key1 == key1 && list[i].key2 == key2) {
			int r = list[i].attachfn(pcif);
			if (r > 0)
				return r;
			if (r < 0)
				cprintf("pci_attach_match: attaching "
					"%x.%x (%p): e\n",
					key1, key2, list[i].attachfn, r);
		}
	}
	return 0;
}

static int
pci_attach(struct pci_func *f)
{
	//如果这个设备是个PCI-PCI桥接器则建立一个pci_bus的结构并将其
	//连接到pci_bus树中
	return
		pci_attach_match(PCI_CLASS(f->dev_class), 
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
		pci_attach_match(PCI_VENDOR(f->dev_id), 
				 PCI_PRODUCT(f->dev_id),
				 &pci_attach_vendor[0], f);
}

static const char *pci_class[] = 
{
	[0x0] = "Unknown",
	[0x1] = "Storage controller",
	[0x2] = "Network controller",
	[0x3] = "Display controller",
	[0x4] = "Multimedia device",
	[0x5] = "Memory controller",
	[0x6] = "Bridge device",
};

static void 
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
		class = pci_class[PCI_CLASS(f->dev_class)];

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
		PCI_CLASS(f->dev_class), PCI_SUBCLASS(f->dev_class), class,
		f->irq_line);
}

static int 
pci_scan_bus(struct pci_bus *bus)
{
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;
	
	for (df.dev = 0; df.dev < 32; df.dev++) {
		uint32_t bhlc = pci_conf_read(&df, PCI_BHLC_REG);
		//Header Type:1 Byte bit[6:0]表示PCI配置空间头部的布局类型，
		//值00h表示一个一般PCI设备的配置空间头部,参考类型0的配置空间
		//值01h表示一个PCI-to-PCI桥的配置空间头部,参考类型1的配置空间
		//值02h表示CardBus桥的配置空间头部
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
			continue;
		
		totaldev++;
		
		struct pci_func f = df;
		//Header Type:bit[7]＝1表示这是一个多功能设备,
		//bit[7]=0表示这是一个单功能设备
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
		     f.func++) {
			struct pci_func af = f;
			
			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
			//判断设备是否存在，ffffh是非法ID
			if (PCI_VENDOR(af.dev_id) == 0xffff)
				continue;
			//获取中断线编号
			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
			af.irq_line = PCI_INTERRUPT_LINE(intr);
			//获取设备class包含3部分：
			//bit[7:0]编程接口;bit[15:8]子类别编号
			//bit[23:16]基类别编号
			af.dev_class = pci_conf_read(&af, PCI_CLASS_REG);
			if (pci_show_devs)
				pci_print_func(&af);
			pci_attach(&af);
		}
	}
	
	return totaldev;
}

static int
pci_bridge_attach(struct pci_func *pcif)
{
	uint32_t ioreg  = pci_conf_read(pcif, PCI_BRIDGE_STATIO_REG);
	uint32_t busreg = pci_conf_read(pcif, PCI_BRIDGE_BUS_REG);
	//根据IO Base Register判断
	//0h:16-bit IO address decode
	//1h:32-bit IO address decode
	if (PCI_BRIDGE_IO_32BITS(ioreg)) {
		cprintf("PCI: %02x:%02x.%d: 32-bit bridge IO not supported.\n",
			pcif->bus->busno, pcif->dev, pcif->func);
		return 0;
	}
	
	struct pci_bus nbus;
	memset(&nbus, 0, sizeof(nbus));
	nbus.parent_bridge = pcif;
	//获取桥下游的PCI总线号,次级总线号(busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff
	//最大次级总线号：(busreg >> PCI_BRIDGE_BUS_SUBORDINATE_SHIFT) & 0xff
	nbus.busno = (busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff;
	
	if (pci_show_devs)
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
			pcif->bus->busno, pcif->dev, pcif->func,
			nbus.busno,
			(busreg >> PCI_BRIDGE_BUS_SUBORDINATE_SHIFT) & 0xff);
	//扫描次级总线
	pci_scan_bus(&nbus);
	return 1;
}

// External PCI subsystem interface
//查询PCI设备需要的PCI I/O和内存空间大小
//存储或I/O空间大小读取方法：写全1即0xffffffff，而后读取寄存器值，再取补。
//如读到0xffff0000，表示空间是64KB（0x10000H）
void
pci_func_enable(struct pci_func *f)
{
	//初始化命令寄存器PCI_COMMAND_STATUS_REG
	//PCI_COMMAND_IO_ENABLE允许设备响应I/O空间的存取
	//PCI_COMMAND_MEM_ENABLE允许设备响应内存空间存取
	//PCI_COMMAND_MASTER_ENABLE允许设备作为bus master,可以产生PCI存取
	pci_conf_write(f, PCI_COMMAND_STATUS_REG,
		       PCI_COMMAND_IO_ENABLE |
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);
	
	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);
		
		bar_width = 4;
		pci_conf_write(f, bar, 0xffffffff);
		uint32_t rv = pci_conf_read(f, bar);
		
		if (rv == 0)
			continue;
		
		int regnum = PCI_MAPREG_NUM(bar);
		uint32_t base, size;
		//bit[0]=0表示存储空间
		//bit[0]=1表示I/O空间
		if (PCI_MAPREG_TYPE(rv) == PCI_MAPREG_TYPE_MEM) {
			if (PCI_MAPREG_MEM_TYPE(rv) == PCI_MAPREG_MEM_TYPE_64BIT)
				bar_width = 8;
			
			size = PCI_MAPREG_MEM_SIZE(rv);
			base = PCI_MAPREG_MEM_ADDR(oldv);
			if (pci_show_addrs)
				cprintf("  mem region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		} else {
			size = PCI_MAPREG_IO_SIZE(rv);
			base = PCI_MAPREG_IO_ADDR(oldv);
			if (pci_show_addrs)
				cprintf("  io region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		}
		
		pci_conf_write(f, bar, oldv);
		f->reg_base[regnum] = base;
		f->reg_size[regnum] = size;
		
		if (size && !base)
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
				"may be misconfigured: "
				"region %d: base 0x%x, size %d\n",
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
}

int
pci_init(void)
{
	static struct pci_bus root_bus;
	memset(&root_bus, 0, sizeof(root_bus));
	//PCI初始化代码扫描PCI总线0,建立总线树表示整个系统总线结构拓扑
	//系统初始化程序必须扫描基本PCI总线(总线0)和PCI-to-PCI桥.
	return pci_scan_bus(&root_bus);
}
