// LAB 6: Your driver code here
/*reference to Intel 8255x 10/100 Mbps Ethernet Controller Family
 * Open Source Software Developer Manual
 * System Control Block(SCB)---10/100 Mbps Device(8255X) Registers
 *   -         -  
 *   -         -
 *   -         -
 *   -         -
 *   -         -
 *   -         -
 *   -         ----------->Control Block---->Control Block--->Control Block
 *   -
 *   -
 *   -
 *   --------------------->Frame Descriptor--->Frame Descriptor--->Frame Descriptor
 *                                  |
 *                                  |
 *                                 \|/
 *                            Buffer Descriptor---->Buffer Descriptor--->Buffer Descriptor
 *                                  |                      |
 *                                  |                      |
 *                                 \|/                    \|/
 *                       Receive Data Buffer      Receive Data Buffer
 */
/*SCB Command Word
 * __________________________________________________________________________
 *|31                           26| 25| 24| 23           20 |19 |18        16|
 *|Specific Interrupt Mask Bits   | SI| M |  CU Command     |0  | RU Command |
 *|_______________________________|___|___|_________________|___|____________|
 * bit[23:20]=0000  NOP
 * 	      0001  CU Start
 * 	      0010  CU Resume
 */
/* CB   Control Block
 * CBL  Command Block List
 * CSR  Control/Status Registers
 * CU   Command Unit 命令单元
 * RFA  Receive Frame Area
 * RFD  Receive Frame Descriptor
 * RU   Receive Unit
 * SCB  System Control Block
 * TCB  Transmit Command Block
 */
#include<inc/x86.h>
#include<inc/assert.h>

#include<kern/e100.h>
#include<kern/pci.h>
/*Control/Status Register(CSR)*/
#define CSR_STATUS	0x0
#define CSR_STAT_ACK	0x1
#define CSR_CMD_LO	0x2
#define CSR_CMD_HI	0x3
#define CSR_GEN_PTR	0x4
#define CSR_PORT	0x8
#define CSR_FLASH_CTRL	0xc
#define CSR_EEPROM_CTRL_LO	0xe
#define CSR_EEPROM_CTRL_HI	0xf
#define CSR_MDI_CTRL	0x10
#define CSR_RX_DMA_COUNT	0x14
enum scb_status{
	rus_ready=0x10,
	rus_mask=0x3c,
};
enum ru_state{
	RU_SUSPENDED=0,
	RU_RUNNING=1,
	RU_UNINITIALIZED=-1,
};
enum scb_stat_ack{
	stat_ack_not_ours=0x00,
	stat_ack_sw_gen=0x04,
	stat_ack_rnr=0x10,
	stat_ack_cu_idle=0x20,
	stat_ack_frame_rx=0x40,
	stat_ack_cu_cmd_done=0x80,
	stat_ack_not_present=0xFF,
	stat_ack_rx=(stat_ack_sw_gen|stat_ack_rnr|stat_ack_frame_rx),
	stat_ack_tx=(stat_ack_cu_idle|stat_ack_cu_cmd_done),
};
/*
 * SCB Command Word
 * 高8位是中断控制字节，低8位是命令字节
 */
enum scb_cmd_hi{
	irq_mask_none=0x00,
	irq_mask_all=0x01,
	irq_sw_gen=0x02,/*Bit 25:this bit is used for the software generated interrupt*/
};
enum scb_cmd_lo{
	cuc_nop=0x00,/*NOP*/
	ruc_start=0x01,/*RU Start*/
	ruc_load_base=0x06,/*Load RU Base,The internal RU Base Register is loaded (p39)*/
	cuc_start=0x10,
	cuc_resume=0x20,
	cuc_dump_addr=0x40,
	cuc_dump_stats=0x50,
	cuc_load_base=0x60,
	cuc_dump_reset=0x70,
};
enum port{
	software_reset=0x0000,
	selftest=0x0001,
	selective_reset=0x0002,
};
#define CBS_MIN	64
#define CBS_MAX 128
#define CBS_COUNT 50
/*保持整个结构体32字节对齐*/
#define UCODE_SIZE	134
/*
简单方式下，传输数据紧跟在传输命令块(TCB)之后.
灵活方式下，通过传输缓冲描述符(TBD)数组来存取多个data buffers.
本驱动采用简单方式:
tbd_array=0xFFFFFFFF
tcb_byte_count=0
threshold=0xE0,当transmit FIFO中有0xE0*8个字节，才开始发送
*/
struct cb{
	volatile uint16_t status;
	uint16_t cmd;
	uint32_t link;
	union{
		uint32_t ucode[UCODE_SIZE];
		struct{
			uint32_t tbd_array;
			uint16_t tcb_byte_count;
			uint8_t threshold;
			uint8_t tbd_count;
		}tcb;
		uint32_t simple_buffer_addr;
	}u;
	struct cb *next,*prev;
	dma_addr_t dma_addr;
};

//延时10us
static void
delay(void)
{
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
static unsigned CSR_ADDR;
int 
pci_e100_attach(struct pci_func *pcif)
{
	pci_func_enable(pcif);
	cprintf("CSR Memory Mapped Base Address Register:%d bytes at 0x%x\n",pcif->reg_size[0],pcif->reg_base[0]);
	cprintf("CSR I/O Mapped Base Address Register:%d bytes at 0x%x\n",pcif->reg_size[1],pcif->reg_base[1]);
	cprintf("Flash Memory Base Address Register:%d bytes at 0x%x\n",pcif->reg_size[2],pcif->reg_base[2]);
	CSR_ADDR=pcif->reg_base[1];//利用I/O端口操作CSR
	outl(CSR_ADDR+CSR_PORT,software_reset);//向PORT中写入0,软件重启芯片
	delay();//延时10us
	//panic("e100 initialization is not implemented\n");
	return 0;
}
//构建一个DMA环(循环单链表),由CB构成,CB之间通过link指针连接
//link里面存放的是下一个CB的物理地址
dma_addr_t dma_ring;
dma_addr_t dma_ring_head;
dma_addr_t dma_ring_tail;
static int
e100_alloc_cbs()
{
	return 0;
}
