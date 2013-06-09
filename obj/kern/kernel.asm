
obj/kern/kernel:     file format elf32-i386

Disassembly of section .text:

f0100000 <_start-0xc>:
.long CHECKSUM

.globl		_start
_start:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 03 00    	add    0x31bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fb                   	sti    
f0100009:	4f                   	dec    %edi
f010000a:	52                   	push   %edx
f010000b:	e4 66                	in     $0x66,%al

f010000c <_start>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 

	# Establish our own GDT in place of the boot loader's temporary GDT.
	lgdt	RELOC(mygdtdesc)		# load descriptor table
f0100015:	0f 01 15 18 10 13 00 	lgdtl  0x131018

	# Immediately reload all segment registers (including CS!)
	# with segment selectors from the new GDT.
	movl	$DATA_SEL, %eax			# Data segment selector
f010001c:	b8 10 00 00 00       	mov    $0x10,%eax
	movw	%ax,%ds				# -> DS: Data Segment
f0100021:	8e d8                	movl   %eax,%ds
	movw	%ax,%es				# -> ES: Extra Segment
f0100023:	8e c0                	movl   %eax,%es
	movw	%ax,%ss				# -> SS: Stack Segment
f0100025:	8e d0                	movl   %eax,%ss
	ljmp	$CODE_SEL,$relocated		# reload CS by jumping
f0100027:	ea 2e 00 10 f0 08 00 	ljmp   $0x8,$0xf010002e

f010002e <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002e:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Leave a few words on the stack for the user trap frame
	movl	$(bootstacktop-SIZEOF_STRUCT_TRAPFRAME),%esp
f0100033:	bc bc 0f 13 f0       	mov    $0xf0130fbc,%esp

	# now to C code
	call	i386_init
f0100038:	e8 ad 00 00 00       	call   f01000ea <i386_init>

f010003d <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003d:	eb fe                	jmp    f010003d <spin>
	...

f0100040 <_warn>:

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
f0100046:	8d 45 14             	lea    0x14(%ebp),%eax
f0100049:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
	cprintf("kernel warning at %s:%d: ", file, line);
f010004c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010004f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100053:	8b 45 08             	mov    0x8(%ebp),%eax
f0100056:	89 44 24 04          	mov    %eax,0x4(%esp)
f010005a:	c7 04 24 20 a8 10 f0 	movl   $0xf010a820,(%esp)
f0100061:	e8 d1 39 00 00       	call   f0103a37 <cprintf>
	vcprintf(fmt, ap);
f0100066:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
f0100069:	89 44 24 04          	mov    %eax,0x4(%esp)
f010006d:	8b 45 10             	mov    0x10(%ebp),%eax
f0100070:	89 04 24             	mov    %eax,(%esp)
f0100073:	e8 8c 39 00 00       	call   f0103a04 <vcprintf>
	cprintf("\n");
f0100078:	c7 04 24 09 ac 10 f0 	movl   $0xf010ac09,(%esp)
f010007f:	e8 b3 39 00 00       	call   f0103a37 <cprintf>
	va_end(ap);
}
f0100084:	c9                   	leave  
f0100085:	c3                   	ret    

f0100086 <_panic>:
f0100086:	55                   	push   %ebp
f0100087:	89 e5                	mov    %esp,%ebp
f0100089:	53                   	push   %ebx
f010008a:	83 ec 24             	sub    $0x24,%esp
f010008d:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0100090:	83 3d 60 86 2a f0 00 	cmpl   $0x0,0xf02a8660
f0100097:	75 43                	jne    f01000dc <_panic+0x56>
f0100099:	89 1d 60 86 2a f0    	mov    %ebx,0xf02a8660
f010009f:	fa                   	cli    
f01000a0:	fc                   	cld    
f01000a1:	8d 45 14             	lea    0x14(%ebp),%eax
f01000a4:	89 45 f8             	mov    %eax,0xfffffff8(%ebp)
f01000a7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000aa:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01000b1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000b5:	c7 04 24 3a a8 10 f0 	movl   $0xf010a83a,(%esp)
f01000bc:	e8 76 39 00 00       	call   f0103a37 <cprintf>
f01000c1:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
f01000c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000c8:	89 1c 24             	mov    %ebx,(%esp)
f01000cb:	e8 34 39 00 00       	call   f0103a04 <vcprintf>
f01000d0:	c7 04 24 09 ac 10 f0 	movl   $0xf010ac09,(%esp)
f01000d7:	e8 5b 39 00 00       	call   f0103a37 <cprintf>
f01000dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000e3:	e8 af 08 00 00       	call   f0100997 <monitor>
f01000e8:	eb f2                	jmp    f01000dc <_panic+0x56>

f01000ea <i386_init>:
f01000ea:	55                   	push   %ebp
f01000eb:	89 e5                	mov    %esp,%ebp
f01000ed:	83 ec 18             	sub    $0x18,%esp
f01000f0:	b8 8c 98 2a f0       	mov    $0xf02a988c,%eax
f01000f5:	2d 47 86 2a f0       	sub    $0xf02a8647,%eax
f01000fa:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100105:	00 
f0100106:	c7 04 24 47 86 2a f0 	movl   $0xf02a8647,(%esp)
f010010d:	e8 9f 96 00 00       	call   f01097b1 <memset>
f0100112:	e8 76 03 00 00       	call   f010048d <cons_init>
f0100117:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f010011e:	00 
f010011f:	c7 04 24 52 a8 10 f0 	movl   $0xf010a852,(%esp)
f0100126:	e8 0c 39 00 00       	call   f0103a37 <cprintf>
f010012b:	e8 72 16 00 00       	call   f01017a2 <i386_detect_memory>
f0100130:	e8 60 1d 00 00       	call   f0101e95 <i386_vm_init>
f0100135:	e8 9b 30 00 00       	call   f01031d5 <env_init>
f010013a:	e8 31 39 00 00       	call   f0103a70 <idt_init>
f010013f:	90                   	nop    
f0100140:	e8 31 38 00 00       	call   f0103976 <pic_init>
f0100145:	e8 65 37 00 00       	call   f01038af <kclock_init>
f010014a:	e8 01 a0 00 00       	call   f010a150 <time_init>
f010014f:	90                   	nop    
f0100150:	e8 ec 9e 00 00       	call   f010a041 <pci_init>
f0100155:	c7 44 24 04 a7 1f 01 	movl   $0x11fa7,0x4(%esp)
f010015c:	00 
f010015d:	c7 04 24 94 17 13 f0 	movl   $0xf0131794,(%esp)
f0100164:	e8 1f 33 00 00       	call   f0103488 <env_create>
f0100169:	c7 44 24 04 7f c6 01 	movl   $0x1c67f,0x4(%esp)
f0100170:	00 
f0100171:	c7 04 24 55 3b 21 f0 	movl   $0xf0213b55,(%esp)
f0100178:	e8 0b 33 00 00       	call   f0103488 <env_create>
f010017d:	c7 44 24 04 ed 30 01 	movl   $0x130ed,0x4(%esp)
f0100184:	00 
f0100185:	c7 04 24 3b 37 14 f0 	movl   $0xf014373b,(%esp)
f010018c:	e8 f7 32 00 00       	call   f0103488 <env_create>
f0100191:	e8 06 4a 00 00       	call   f0104b9c <sched_yield>
	...

f01001a0 <delay>:
// Stupid I/O delay routine necessitated by historical PC design flaws
// 延时5us
static void
delay(void)
{
f01001a0:	55                   	push   %ebp
f01001a1:	89 e5                	mov    %esp,%ebp
static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001a3:	ba 84 00 00 00       	mov    $0x84,%edx
f01001a8:	ec                   	in     (%dx),%al
f01001a9:	ec                   	in     (%dx),%al
f01001aa:	ec                   	in     (%dx),%al
f01001ab:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01001ac:	5d                   	pop    %ebp
f01001ad:	c3                   	ret    

f01001ae <cons_intr>:

/***** Serial I/O code *****/

#define COM1		0x3F8

#define COM_RX		0	// In:	Receive buffer (DLAB=0)
#define COM_TX		0	// Out: Transmit buffer (DLAB=0)
#define COM_DLL		0	// Out: Divisor Latch Low (DLAB=1)
#define COM_DLM		1	// Out: Divisor Latch High (DLAB=1)
#define COM_IER		1	// Out: Interrupt Enable Register
#define   COM_IER_RDI	0x01	//   Enable receiver data interrupt
#define COM_IIR		2	// In:	Interrupt ID Register
#define COM_FCR		2	// Out: FIFO Control Register
#define COM_LCR		3	// Out: Line Control Register
#define	  COM_LCR_DLAB	0x80	//   Divisor latch access bit
#define	  COM_LCR_WLEN8	0x03	//   Wordlength: 8 bits
#define COM_MCR		4	// Out: Modem Control Register
#define	  COM_MCR_RTS	0x02	// RTS complement
#define	  COM_MCR_DTR	0x01	// DTR complement
#define	  COM_MCR_OUT2	0x08	// Out2 complement
#define COM_LSR		5	// In:	Line Status Register
#define   COM_LSR_DATA	0x01	//   Data available
#define   COM_LSR_TXRDY	0x20	//   Transmit buffer avail
#define   COM_LSR_TSRE	0x40	//   Transmitter off

static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
	if (serial_exists)
		cons_intr(serial_proc_data);
}

static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
}

static void
serial_init(void)
{
	// Turn off the FIFO
	outb(COM1+COM_FCR, 0);
	
	// Set speed; requires DLAB latch
	outb(COM1+COM_LCR, COM_LCR_DLAB);
	outb(COM1+COM_DLL, (uint8_t) (115200 / 9600));
	outb(COM1+COM_DLM, 0);

	// 8 data bits, 1 stop bit, parity off; turn off DLAB latch
	outb(COM1+COM_LCR, COM_LCR_WLEN8 & ~COM_LCR_DLAB);

	// No modem controls
	outb(COM1+COM_MCR, 0);
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

}



/***** Parallel port output code *****/
// For information on PC parallel port programming, see the class References
// page.

static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
	outb(0x378+0, c);
	outb(0x378+2, 0x08|0x04|0x01);
	outb(0x378+2, 0x08);
}




/***** Text-mode CGA/VGA display output *****/

static unsigned addr_6845;
static uint16_t *crt_buf;
static uint16_t crt_pos;

static void
cga_init(void)
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
		addr_6845 = CGA_BASE;
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
}



static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
		c |= 0x0700;

	switch (c & 0xff) {
	case '\b':
		if (crt_pos > 0) {
			crt_pos--;
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
		break;
	case '\t':
		cons_putc(' ');
		cons_putc(' ');
		cons_putc(' ');
		cons_putc(' ');
		cons_putc(' ');
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
	outb(addr_6845 + 1, crt_pos >> 8);
	outb(addr_6845, 15);
	outb(addr_6845 + 1, crt_pos);
}


/***** Keyboard input code *****/

#define NO		0

#define SHIFT		(1<<0)
#define CTL		(1<<1)
#define ALT		(1<<2)

#define CAPSLOCK	(1<<3)
#define NUMLOCK		(1<<4)
#define SCROLLLOCK	(1<<5)

#define E0ESC		(1<<6)

static uint8_t shiftcode[256] = 
{
	[0x1D] = CTL,
	[0x2A] = SHIFT,
	[0x36] = SHIFT,
	[0x38] = ALT,
	[0x9D] = CTL,
	[0xB8] = ALT
};

static uint8_t togglecode[256] = 
{
	[0x3A] = CAPSLOCK,
	[0x45] = NUMLOCK,
	[0x46] = SCROLLLOCK
};

static uint8_t normalmap[256] =
{
	NO,   0x1B, '1',  '2',  '3',  '4',  '5',  '6',	// 0x00
	'7',  '8',  '9',  '0',  '-',  '=',  '\b', '\t',
	'q',  'w',  'e',  'r',  't',  'y',  'u',  'i',	// 0x10
	'o',  'p',  '[',  ']',  '\n', NO,   'a',  's',
	'd',  'f',  'g',  'h',  'j',  'k',  'l',  ';',	// 0x20
	'\'', '`',  NO,   '\\', 'z',  'x',  'c',  'v',
	'b',  'n',  'm',  ',',  '.',  '/',  NO,   '*',	// 0x30
	NO,   ' ',  NO,   NO,   NO,   NO,   NO,   NO,
	NO,   NO,   NO,   NO,   NO,   NO,   NO,   '7',	// 0x40
	'8',  '9',  '-',  '4',  '5',  '6',  '+',  '1',
	'2',  '3',  '0',  '.',  NO,   NO,   NO,   NO,	// 0x50
	[0xC7] = KEY_HOME,	      [0x9C] = '\n' /*KP_Enter*/,
	[0xB5] = '/' /*KP_Div*/,      [0xC8] = KEY_UP,
	[0xC9] = KEY_PGUP,	      [0xCB] = KEY_LF,
	[0xCD] = KEY_RT,	      [0xCF] = KEY_END,
	[0xD0] = KEY_DN,	      [0xD1] = KEY_PGDN,
	[0xD2] = KEY_INS,	      [0xD3] = KEY_DEL
};

static uint8_t shiftmap[256] = 
{
	NO,   033,  '!',  '@',  '#',  '$',  '%',  '^',	// 0x00
	'&',  '*',  '(',  ')',  '_',  '+',  '\b', '\t',
	'Q',  'W',  'E',  'R',  'T',  'Y',  'U',  'I',	// 0x10
	'O',  'P',  '{',  '}',  '\n', NO,   'A',  'S',
	'D',  'F',  'G',  'H',  'J',  'K',  'L',  ':',	// 0x20
	'"',  '~',  NO,   '|',  'Z',  'X',  'C',  'V',
	'B',  'N',  'M',  '<',  '>',  '?',  NO,   '*',	// 0x30
	NO,   ' ',  NO,   NO,   NO,   NO,   NO,   NO,
	NO,   NO,   NO,   NO,   NO,   NO,   NO,   '7',	// 0x40
	'8',  '9',  '-',  '4',  '5',  '6',  '+',  '1',
	'2',  '3',  '0',  '.',  NO,   NO,   NO,   NO,	// 0x50
	[0xC7] = KEY_HOME,	      [0x9C] = '\n' /*KP_Enter*/,
	[0xB5] = '/' /*KP_Div*/,      [0xC8] = KEY_UP,
	[0xC9] = KEY_PGUP,	      [0xCB] = KEY_LF,
	[0xCD] = KEY_RT,	      [0xCF] = KEY_END,
	[0xD0] = KEY_DN,	      [0xD1] = KEY_PGDN,
	[0xD2] = KEY_INS,	      [0xD3] = KEY_DEL
};

#define C(x) (x - '@')

static uint8_t ctlmap[256] = 
{
	NO,      NO,      NO,      NO,      NO,      NO,      NO,      NO, 
	NO,      NO,      NO,      NO,      NO,      NO,      NO,      NO, 
	C('Q'),  C('W'),  C('E'),  C('R'),  C('T'),  C('Y'),  C('U'),  C('I'),
	C('O'),  C('P'),  NO,      NO,      '\r',    NO,      C('A'),  C('S'),
	C('D'),  C('F'),  C('G'),  C('H'),  C('J'),  C('K'),  C('L'),  NO, 
	NO,      NO,      NO,      C('\\'), C('Z'),  C('X'),  C('C'),  C('V'),
	C('B'),  C('N'),  C('M'),  NO,      NO,      C('/'),  NO,      NO,
	[0x97] = KEY_HOME,
	[0xB5] = C('/'),		[0xC8] = KEY_UP,
	[0xC9] = KEY_PGUP,		[0xCB] = KEY_LF,
	[0xCD] = KEY_RT,		[0xCF] = KEY_END,
	[0xD0] = KEY_DN,		[0xD1] = KEY_PGDN,
	[0xD2] = KEY_INS,		[0xD3] = KEY_DEL
};

static uint8_t *charcode[4] = {
	normalmap,
	shiftmap,
	ctlmap,
	ctlmap
};

/*
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
		shift &= ~(shiftcode[data] | E0ESC);
		return 0;
	} else if (shift & E0ESC) {
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
		shift &= ~E0ESC;
	}

	shift |= shiftcode[data];
	shift ^= togglecode[data];

	c = charcode[shift & (CTL | SHIFT)][data];
	if (shift & CAPSLOCK) {
		if ('a' <= c && c <= 'z')
			c += 'A' - 'a';
		else if ('A' <= c && c <= 'Z')
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}

void
kbd_intr(void)
{
	cons_intr(kbd_proc_data);
}

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
}



/***** General device-independent console code *****/
// Here we manage the console input buffer,
// where we stash characters received from the keyboard or serial port
// whenever the corresponding interrupt occurs.

#define CONSBUFSIZE 512

static struct {
	uint8_t buf[CONSBUFSIZE];
	uint32_t rpos;
	uint32_t wpos;
} cons;

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001ae:	55                   	push   %ebp
f01001af:	89 e5                	mov    %esp,%ebp
f01001b1:	53                   	push   %ebx
f01001b2:	83 ec 04             	sub    $0x4,%esp
f01001b5:	89 c3                	mov    %eax,%ebx
f01001b7:	eb 2a                	jmp    f01001e3 <cons_intr+0x35>
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
f01001b9:	85 c0                	test   %eax,%eax
f01001bb:	74 26                	je     f01001e3 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01001bd:	8b 15 a4 88 2a f0    	mov    0xf02a88a4,%edx
f01001c3:	88 82 a0 86 2a f0    	mov    %al,0xf02a86a0(%edx)
f01001c9:	83 c2 01             	add    $0x1,%edx
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
f01001cc:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001d2:	0f 94 c0             	sete   %al
f01001d5:	0f b6 c0             	movzbl %al,%eax
f01001d8:	83 e8 01             	sub    $0x1,%eax
f01001db:	21 c2                	and    %eax,%edx
f01001dd:	89 15 a4 88 2a f0    	mov    %edx,0xf02a88a4
f01001e3:	ff d3                	call   *%ebx
f01001e5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001e8:	75 cf                	jne    f01001b9 <cons_intr+0xb>
	}
}
f01001ea:	83 c4 04             	add    $0x4,%esp
f01001ed:	5b                   	pop    %ebx
f01001ee:	5d                   	pop    %ebp
f01001ef:	c3                   	ret    

f01001f0 <kbd_intr>:
f01001f0:	55                   	push   %ebp
f01001f1:	89 e5                	mov    %esp,%ebp
f01001f3:	83 ec 08             	sub    $0x8,%esp
f01001f6:	b8 bd 05 10 f0       	mov    $0xf01005bd,%eax
f01001fb:	e8 ae ff ff ff       	call   f01001ae <cons_intr>
f0100200:	c9                   	leave  
f0100201:	c3                   	ret    

f0100202 <serial_intr>:
f0100202:	55                   	push   %ebp
f0100203:	89 e5                	mov    %esp,%ebp
f0100205:	83 ec 08             	sub    $0x8,%esp
f0100208:	83 3d 84 86 2a f0 00 	cmpl   $0x0,0xf02a8684
f010020f:	74 0a                	je     f010021b <serial_intr+0x19>
f0100211:	b8 9e 05 10 f0       	mov    $0xf010059e,%eax
f0100216:	e8 93 ff ff ff       	call   f01001ae <cons_intr>
f010021b:	c9                   	leave  
f010021c:	c3                   	ret    

f010021d <cons_getc>:

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010021d:	55                   	push   %ebp
f010021e:	89 e5                	mov    %esp,%ebp
f0100220:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100223:	e8 da ff ff ff       	call   f0100202 <serial_intr>
	kbd_intr();
f0100228:	e8 c3 ff ff ff       	call   f01001f0 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010022d:	a1 a0 88 2a f0       	mov    0xf02a88a0,%eax
f0100232:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100237:	3b 05 a4 88 2a f0    	cmp    0xf02a88a4,%eax
f010023d:	74 21                	je     f0100260 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f010023f:	0f b6 88 a0 86 2a f0 	movzbl 0xf02a86a0(%eax),%ecx
f0100246:	8d 50 01             	lea    0x1(%eax),%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f0100249:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010024f:	0f 94 c0             	sete   %al
f0100252:	0f b6 c0             	movzbl %al,%eax
f0100255:	83 e8 01             	sub    $0x1,%eax
f0100258:	21 c2                	and    %eax,%edx
f010025a:	89 15 a0 88 2a f0    	mov    %edx,0xf02a88a0
		return c;
	}
	return 0;
}
f0100260:	89 c8                	mov    %ecx,%eax
f0100262:	c9                   	leave  
f0100263:	c3                   	ret    

f0100264 <getchar>:

// output a character to the console
static void
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}

// initialize the console devices
void
cons_init(void)
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
		cprintf("Serial port does not exist!\n");
}


// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
	cons_putc(c);
}

int
getchar(void)
{
f0100264:	55                   	push   %ebp
f0100265:	89 e5                	mov    %esp,%ebp
f0100267:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010026a:	e8 ae ff ff ff       	call   f010021d <cons_getc>
f010026f:	85 c0                	test   %eax,%eax
f0100271:	74 f7                	je     f010026a <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100273:	c9                   	leave  
f0100274:	c3                   	ret    

f0100275 <iscons>:

int
iscons(int fdnum)
{
f0100275:	55                   	push   %ebp
f0100276:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100278:	b8 01 00 00 00       	mov    $0x1,%eax
f010027d:	5d                   	pop    %ebp
f010027e:	c3                   	ret    

f010027f <cons_putc>:
f010027f:	55                   	push   %ebp
f0100280:	89 e5                	mov    %esp,%ebp
f0100282:	57                   	push   %edi
f0100283:	56                   	push   %esi
f0100284:	53                   	push   %ebx
f0100285:	83 ec 1c             	sub    $0x1c,%esp
f0100288:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010028b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100290:	ec                   	in     (%dx),%al
f0100291:	a8 20                	test   $0x20,%al
f0100293:	75 21                	jne    f01002b6 <cons_putc+0x37>
f0100295:	bb 00 00 00 00       	mov    $0x0,%ebx
f010029a:	be fd 03 00 00       	mov    $0x3fd,%esi
f010029f:	e8 fc fe ff ff       	call   f01001a0 <delay>
static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002a4:	89 f2                	mov    %esi,%edx
f01002a6:	ec                   	in     (%dx),%al
f01002a7:	a8 20                	test   $0x20,%al
f01002a9:	75 0b                	jne    f01002b6 <cons_putc+0x37>
f01002ab:	83 c3 01             	add    $0x1,%ebx
f01002ae:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01002b4:	75 e9                	jne    f010029f <cons_putc+0x20>
f01002b6:	0f b6 7d f0          	movzbl 0xfffffff0(%ebp),%edi

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ba:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002bf:	89 f8                	mov    %edi,%eax
f01002c1:	ee                   	out    %al,(%dx)
f01002c2:	b2 79                	mov    $0x79,%dl
f01002c4:	ec                   	in     (%dx),%al
f01002c5:	84 c0                	test   %al,%al
f01002c7:	78 21                	js     f01002ea <cons_putc+0x6b>
f01002c9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01002ce:	be 79 03 00 00       	mov    $0x379,%esi
f01002d3:	e8 c8 fe ff ff       	call   f01001a0 <delay>
static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002d8:	89 f2                	mov    %esi,%edx
f01002da:	ec                   	in     (%dx),%al
f01002db:	84 c0                	test   %al,%al
f01002dd:	78 0b                	js     f01002ea <cons_putc+0x6b>
f01002df:	83 c3 01             	add    $0x1,%ebx
f01002e2:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01002e8:	75 e9                	jne    f01002d3 <cons_putc+0x54>

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ea:	ba 78 03 00 00       	mov    $0x378,%edx
f01002ef:	89 f8                	mov    %edi,%eax
f01002f1:	ee                   	out    %al,(%dx)
f01002f2:	b8 0d 00 00 00       	mov    $0xd,%eax
f01002f7:	b2 7a                	mov    $0x7a,%dl
f01002f9:	ee                   	out    %al,(%dx)
f01002fa:	b8 08 00 00 00       	mov    $0x8,%eax
f01002ff:	ee                   	out    %al,(%dx)
f0100300:	f7 45 f0 00 ff ff ff 	testl  $0xffffff00,0xfffffff0(%ebp)
f0100307:	75 07                	jne    f0100310 <cons_putc+0x91>
f0100309:	81 4d f0 00 07 00 00 	orl    $0x700,0xfffffff0(%ebp)
f0100310:	0f b6 45 f0          	movzbl 0xfffffff0(%ebp),%eax
f0100314:	83 f8 09             	cmp    $0x9,%eax
f0100317:	0f 84 86 00 00 00    	je     f01003a3 <cons_putc+0x124>
f010031d:	83 f8 09             	cmp    $0x9,%eax
f0100320:	7f 10                	jg     f0100332 <cons_putc+0xb3>
f0100322:	83 f8 08             	cmp    $0x8,%eax
f0100325:	0f 85 ac 00 00 00    	jne    f01003d7 <cons_putc+0x158>
f010032b:	90                   	nop    
f010032c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0100330:	eb 16                	jmp    f0100348 <cons_putc+0xc9>
f0100332:	83 f8 0a             	cmp    $0xa,%eax
f0100335:	74 42                	je     f0100379 <cons_putc+0xfa>
f0100337:	83 f8 0d             	cmp    $0xd,%eax
f010033a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0100340:	0f 85 91 00 00 00    	jne    f01003d7 <cons_putc+0x158>
f0100346:	eb 39                	jmp    f0100381 <cons_putc+0x102>
f0100348:	0f b7 05 90 86 2a f0 	movzwl 0xf02a8690,%eax
f010034f:	66 85 c0             	test   %ax,%ax
f0100352:	0f 84 f0 00 00 00    	je     f0100448 <cons_putc+0x1c9>
f0100358:	83 e8 01             	sub    $0x1,%eax
f010035b:	66 a3 90 86 2a f0    	mov    %ax,0xf02a8690
f0100361:	0f b7 c0             	movzwl %ax,%eax
f0100364:	0f b7 55 f0          	movzwl 0xfffffff0(%ebp),%edx
f0100368:	b2 00                	mov    $0x0,%dl
f010036a:	83 ca 20             	or     $0x20,%edx
f010036d:	8b 0d 8c 86 2a f0    	mov    0xf02a868c,%ecx
f0100373:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f0100377:	eb 7f                	jmp    f01003f8 <cons_putc+0x179>
f0100379:	66 83 05 90 86 2a f0 	addw   $0x50,0xf02a8690
f0100380:	50 
f0100381:	0f b7 05 90 86 2a f0 	movzwl 0xf02a8690,%eax
f0100388:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010038e:	c1 e8 10             	shr    $0x10,%eax
f0100391:	66 c1 e8 06          	shr    $0x6,%ax
f0100395:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100398:	c1 e0 04             	shl    $0x4,%eax
f010039b:	66 a3 90 86 2a f0    	mov    %ax,0xf02a8690
f01003a1:	eb 55                	jmp    f01003f8 <cons_putc+0x179>
f01003a3:	b8 20 00 00 00       	mov    $0x20,%eax
f01003a8:	e8 d2 fe ff ff       	call   f010027f <cons_putc>
f01003ad:	b8 20 00 00 00       	mov    $0x20,%eax
f01003b2:	e8 c8 fe ff ff       	call   f010027f <cons_putc>
f01003b7:	b8 20 00 00 00       	mov    $0x20,%eax
f01003bc:	e8 be fe ff ff       	call   f010027f <cons_putc>
f01003c1:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c6:	e8 b4 fe ff ff       	call   f010027f <cons_putc>
f01003cb:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d0:	e8 aa fe ff ff       	call   f010027f <cons_putc>
f01003d5:	eb 21                	jmp    f01003f8 <cons_putc+0x179>
f01003d7:	0f b7 05 90 86 2a f0 	movzwl 0xf02a8690,%eax
f01003de:	0f b7 c8             	movzwl %ax,%ecx
f01003e1:	8b 15 8c 86 2a f0    	mov    0xf02a868c,%edx
f01003e7:	0f b7 5d f0          	movzwl 0xfffffff0(%ebp),%ebx
f01003eb:	66 89 1c 4a          	mov    %bx,(%edx,%ecx,2)
f01003ef:	83 c0 01             	add    $0x1,%eax
f01003f2:	66 a3 90 86 2a f0    	mov    %ax,0xf02a8690
f01003f8:	66 81 3d 90 86 2a f0 	cmpw   $0x7cf,0xf02a8690
f01003ff:	cf 07 
f0100401:	76 45                	jbe    f0100448 <cons_putc+0x1c9>
f0100403:	8b 15 8c 86 2a f0    	mov    0xf02a868c,%edx
f0100409:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100410:	00 
f0100411:	8d 82 a0 00 00 00    	lea    0xa0(%edx),%eax
f0100417:	89 44 24 04          	mov    %eax,0x4(%esp)
f010041b:	89 14 24             	mov    %edx,(%esp)
f010041e:	e8 e7 93 00 00       	call   f010980a <memmove>
f0100423:	8b 15 8c 86 2a f0    	mov    0xf02a868c,%edx
f0100429:	b8 00 00 00 00       	mov    $0x0,%eax
f010042e:	66 c7 84 42 00 0f 00 	movw   $0x720,0xf00(%edx,%eax,2)
f0100435:	00 20 07 
f0100438:	83 c0 01             	add    $0x1,%eax
f010043b:	83 f8 50             	cmp    $0x50,%eax
f010043e:	75 ee                	jne    f010042e <cons_putc+0x1af>
f0100440:	66 83 2d 90 86 2a f0 	subw   $0x50,0xf02a8690
f0100447:	50 
f0100448:	8b 35 88 86 2a f0    	mov    0xf02a8688,%esi
f010044e:	89 f3                	mov    %esi,%ebx

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100450:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100455:	89 f2                	mov    %esi,%edx
f0100457:	ee                   	out    %al,(%dx)
f0100458:	0f b7 0d 90 86 2a f0 	movzwl 0xf02a8690,%ecx
f010045f:	83 c6 01             	add    $0x1,%esi

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100462:	0f b6 c5             	movzbl %ch,%eax
f0100465:	89 f2                	mov    %esi,%edx
f0100467:	ee                   	out    %al,(%dx)
f0100468:	b8 0f 00 00 00       	mov    $0xf,%eax
f010046d:	89 da                	mov    %ebx,%edx
f010046f:	ee                   	out    %al,(%dx)
f0100470:	89 c8                	mov    %ecx,%eax
f0100472:	89 f2                	mov    %esi,%edx
f0100474:	ee                   	out    %al,(%dx)
f0100475:	83 c4 1c             	add    $0x1c,%esp
f0100478:	5b                   	pop    %ebx
f0100479:	5e                   	pop    %esi
f010047a:	5f                   	pop    %edi
f010047b:	5d                   	pop    %ebp
f010047c:	c3                   	ret    

f010047d <cputchar>:
f010047d:	55                   	push   %ebp
f010047e:	89 e5                	mov    %esp,%ebp
f0100480:	83 ec 08             	sub    $0x8,%esp
f0100483:	8b 45 08             	mov    0x8(%ebp),%eax
f0100486:	e8 f4 fd ff ff       	call   f010027f <cons_putc>
f010048b:	c9                   	leave  
f010048c:	c3                   	ret    

f010048d <cons_init>:
f010048d:	55                   	push   %ebp
f010048e:	89 e5                	mov    %esp,%ebp
f0100490:	57                   	push   %edi
f0100491:	56                   	push   %esi
f0100492:	53                   	push   %ebx
f0100493:	83 ec 0c             	sub    $0xc,%esp
f0100496:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
f010049d:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01004a4:	5a a5 
f01004a6:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01004ad:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01004b1:	74 11                	je     f01004c4 <cons_init+0x37>
f01004b3:	c7 05 88 86 2a f0 b4 	movl   $0x3b4,0xf02a8688
f01004ba:	03 00 00 
f01004bd:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01004c2:	eb 16                	jmp    f01004da <cons_init+0x4d>
f01004c4:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f01004cb:	c7 05 88 86 2a f0 d4 	movl   $0x3d4,0xf02a8688
f01004d2:	03 00 00 
f01004d5:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f01004da:	8b 1d 88 86 2a f0    	mov    0xf02a8688,%ebx
f01004e0:	89 d9                	mov    %ebx,%ecx

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004e2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004e7:	89 da                	mov    %ebx,%edx
f01004e9:	ee                   	out    %al,(%dx)
f01004ea:	8d 7b 01             	lea    0x1(%ebx),%edi
static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004ed:	89 fa                	mov    %edi,%edx
f01004ef:	ec                   	in     (%dx),%al
f01004f0:	0f b6 c0             	movzbl %al,%eax
f01004f3:	89 c3                	mov    %eax,%ebx
f01004f5:	c1 e3 08             	shl    $0x8,%ebx

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004f8:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004fd:	89 ca                	mov    %ecx,%edx
f01004ff:	ee                   	out    %al,(%dx)
f0100500:	89 fa                	mov    %edi,%edx
f0100502:	ec                   	in     (%dx),%al
f0100503:	89 35 8c 86 2a f0    	mov    %esi,0xf02a868c
f0100509:	0f b6 c0             	movzbl %al,%eax
f010050c:	09 d8                	or     %ebx,%eax
f010050e:	66 a3 90 86 2a f0    	mov    %ax,0xf02a8690
f0100514:	e8 d7 fc ff ff       	call   f01001f0 <kbd_intr>
f0100519:	0f b7 05 58 13 13 f0 	movzwl 0xf0131358,%eax
f0100520:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100525:	89 04 24             	mov    %eax,(%esp)
f0100528:	e8 cf 33 00 00       	call   f01038fc <irq_setmask_8259A>

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010052d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100532:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100537:	89 da                	mov    %ebx,%edx
f0100539:	ee                   	out    %al,(%dx)
f010053a:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010053f:	b2 fb                	mov    $0xfb,%dl
f0100541:	ee                   	out    %al,(%dx)
f0100542:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100547:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f010054c:	89 ca                	mov    %ecx,%edx
f010054e:	ee                   	out    %al,(%dx)
f010054f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100554:	b2 f9                	mov    $0xf9,%dl
f0100556:	ee                   	out    %al,(%dx)
f0100557:	b8 03 00 00 00       	mov    $0x3,%eax
f010055c:	b2 fb                	mov    $0xfb,%dl
f010055e:	ee                   	out    %al,(%dx)
f010055f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100564:	b2 fc                	mov    $0xfc,%dl
f0100566:	ee                   	out    %al,(%dx)
f0100567:	b8 01 00 00 00       	mov    $0x1,%eax
f010056c:	b2 f9                	mov    $0xf9,%dl
f010056e:	ee                   	out    %al,(%dx)
f010056f:	b2 fd                	mov    $0xfd,%dl
f0100571:	ec                   	in     (%dx),%al
f0100572:	3c ff                	cmp    $0xff,%al
f0100574:	0f 95 c0             	setne  %al
f0100577:	0f b6 f0             	movzbl %al,%esi
f010057a:	89 35 84 86 2a f0    	mov    %esi,0xf02a8684
static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100580:	89 da                	mov    %ebx,%edx
f0100582:	ec                   	in     (%dx),%al
f0100583:	89 ca                	mov    %ecx,%edx
f0100585:	ec                   	in     (%dx),%al
f0100586:	85 f6                	test   %esi,%esi
f0100588:	75 0c                	jne    f0100596 <cons_init+0x109>
f010058a:	c7 04 24 6d a8 10 f0 	movl   $0xf010a86d,(%esp)
f0100591:	e8 a1 34 00 00       	call   f0103a37 <cprintf>
f0100596:	83 c4 0c             	add    $0xc,%esp
f0100599:	5b                   	pop    %ebx
f010059a:	5e                   	pop    %esi
f010059b:	5f                   	pop    %edi
f010059c:	5d                   	pop    %ebp
f010059d:	c3                   	ret    

f010059e <serial_proc_data>:
f010059e:	55                   	push   %ebp
f010059f:	89 e5                	mov    %esp,%ebp
static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005a1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005a6:	ec                   	in     (%dx),%al
f01005a7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01005ac:	a8 01                	test   $0x1,%al
f01005ae:	74 09                	je     f01005b9 <serial_proc_data+0x1b>
static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01005b5:	ec                   	in     (%dx),%al
f01005b6:	0f b6 d0             	movzbl %al,%edx
f01005b9:	89 d0                	mov    %edx,%eax
f01005bb:	5d                   	pop    %ebp
f01005bc:	c3                   	ret    

f01005bd <kbd_proc_data>:
f01005bd:	55                   	push   %ebp
f01005be:	89 e5                	mov    %esp,%ebp
f01005c0:	53                   	push   %ebx
f01005c1:	83 ec 04             	sub    $0x4,%esp
static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005c4:	ba 64 00 00 00       	mov    $0x64,%edx
f01005c9:	ec                   	in     (%dx),%al
f01005ca:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01005cf:	a8 01                	test   $0x1,%al
f01005d1:	0f 84 d9 00 00 00    	je     f01006b0 <kbd_proc_data+0xf3>
static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005d7:	ba 60 00 00 00       	mov    $0x60,%edx
f01005dc:	ec                   	in     (%dx),%al
f01005dd:	89 c2                	mov    %eax,%edx
f01005df:	3c e0                	cmp    $0xe0,%al
f01005e1:	75 11                	jne    f01005f4 <kbd_proc_data+0x37>
f01005e3:	83 0d 80 86 2a f0 40 	orl    $0x40,0xf02a8680
f01005ea:	bb 00 00 00 00       	mov    $0x0,%ebx
f01005ef:	e9 bc 00 00 00       	jmp    f01006b0 <kbd_proc_data+0xf3>
f01005f4:	84 c0                	test   %al,%al
f01005f6:	79 31                	jns    f0100629 <kbd_proc_data+0x6c>
f01005f8:	8b 0d 80 86 2a f0    	mov    0xf02a8680,%ecx
f01005fe:	f6 c1 40             	test   $0x40,%cl
f0100601:	75 03                	jne    f0100606 <kbd_proc_data+0x49>
f0100603:	83 e2 7f             	and    $0x7f,%edx
f0100606:	0f b6 c2             	movzbl %dl,%eax
f0100609:	0f b6 80 a0 a8 10 f0 	movzbl 0xf010a8a0(%eax),%eax
f0100610:	83 c8 40             	or     $0x40,%eax
f0100613:	0f b6 c0             	movzbl %al,%eax
f0100616:	f7 d0                	not    %eax
f0100618:	21 c8                	and    %ecx,%eax
f010061a:	a3 80 86 2a f0       	mov    %eax,0xf02a8680
f010061f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100624:	e9 87 00 00 00       	jmp    f01006b0 <kbd_proc_data+0xf3>
f0100629:	a1 80 86 2a f0       	mov    0xf02a8680,%eax
f010062e:	a8 40                	test   $0x40,%al
f0100630:	74 0b                	je     f010063d <kbd_proc_data+0x80>
f0100632:	83 ca 80             	or     $0xffffff80,%edx
f0100635:	83 e0 bf             	and    $0xffffffbf,%eax
f0100638:	a3 80 86 2a f0       	mov    %eax,0xf02a8680
f010063d:	0f b6 ca             	movzbl %dl,%ecx
f0100640:	0f b6 81 a0 a8 10 f0 	movzbl 0xf010a8a0(%ecx),%eax
f0100647:	0b 05 80 86 2a f0    	or     0xf02a8680,%eax
f010064d:	0f b6 91 a0 a9 10 f0 	movzbl 0xf010a9a0(%ecx),%edx
f0100654:	31 c2                	xor    %eax,%edx
f0100656:	89 15 80 86 2a f0    	mov    %edx,0xf02a8680
f010065c:	89 d0                	mov    %edx,%eax
f010065e:	83 e0 03             	and    $0x3,%eax
f0100661:	8b 04 85 a0 aa 10 f0 	mov    0xf010aaa0(,%eax,4),%eax
f0100668:	0f b6 1c 08          	movzbl (%eax,%ecx,1),%ebx
f010066c:	f6 c2 08             	test   $0x8,%dl
f010066f:	74 18                	je     f0100689 <kbd_proc_data+0xcc>
f0100671:	8d 43 9f             	lea    0xffffff9f(%ebx),%eax
f0100674:	83 f8 19             	cmp    $0x19,%eax
f0100677:	77 05                	ja     f010067e <kbd_proc_data+0xc1>
f0100679:	83 eb 20             	sub    $0x20,%ebx
f010067c:	eb 0b                	jmp    f0100689 <kbd_proc_data+0xcc>
f010067e:	8d 43 bf             	lea    0xffffffbf(%ebx),%eax
f0100681:	83 f8 19             	cmp    $0x19,%eax
f0100684:	77 03                	ja     f0100689 <kbd_proc_data+0xcc>
f0100686:	83 c3 20             	add    $0x20,%ebx
f0100689:	89 d0                	mov    %edx,%eax
f010068b:	f7 d0                	not    %eax
f010068d:	a8 06                	test   $0x6,%al
f010068f:	75 1f                	jne    f01006b0 <kbd_proc_data+0xf3>
f0100691:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100697:	75 17                	jne    f01006b0 <kbd_proc_data+0xf3>
f0100699:	c7 04 24 8a a8 10 f0 	movl   $0xf010a88a,(%esp)
f01006a0:	e8 92 33 00 00       	call   f0103a37 <cprintf>

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006a5:	b8 03 00 00 00       	mov    $0x3,%eax
f01006aa:	ba 92 00 00 00       	mov    $0x92,%edx
f01006af:	ee                   	out    %al,(%dx)
f01006b0:	89 d8                	mov    %ebx,%eax
f01006b2:	83 c4 04             	add    $0x4,%esp
f01006b5:	5b                   	pop    %ebx
f01006b6:	5d                   	pop    %ebp
f01006b7:	c3                   	ret    
	...

f01006c0 <read_eip>:
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f01006c0:	55                   	push   %ebp
f01006c1:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f01006c3:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f01006c6:	5d                   	pop    %ebp
f01006c7:	c3                   	ret    

f01006c8 <getva>:
f01006c8:	55                   	push   %ebp
f01006c9:	89 e5                	mov    %esp,%ebp
f01006cb:	57                   	push   %edi
f01006cc:	56                   	push   %esi
f01006cd:	53                   	push   %ebx
f01006ce:	83 ec 0c             	sub    $0xc,%esp
f01006d1:	8b 75 08             	mov    0x8(%ebp),%esi
f01006d4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01006d7:	85 f6                	test   %esi,%esi
f01006d9:	0f 84 20 01 00 00    	je     f01007ff <getva+0x137>
f01006df:	0f b6 16             	movzbl (%esi),%edx
f01006e2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006e7:	84 d2                	test   %dl,%dl
f01006e9:	74 0e                	je     f01006f9 <getva+0x31>
f01006eb:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006f0:	83 c3 01             	add    $0x1,%ebx
f01006f3:	80 3c 33 00          	cmpb   $0x0,(%ebx,%esi,1)
f01006f7:	75 f7                	jne    f01006f0 <getva+0x28>
f01006f9:	83 f8 10             	cmp    $0x10,%eax
f01006fc:	0f 85 99 00 00 00    	jne    f010079b <getva+0xd3>
f0100702:	80 fa 30             	cmp    $0x30,%dl
f0100705:	75 26                	jne    f010072d <getva+0x65>
f0100707:	80 7e 01 78          	cmpb   $0x78,0x1(%esi)
f010070b:	90                   	nop    
f010070c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0100710:	75 1b                	jne    f010072d <getva+0x65>
f0100712:	83 fb 0a             	cmp    $0xa,%ebx
f0100715:	7f 16                	jg     f010072d <getva+0x65>
f0100717:	bf 00 00 00 00       	mov    $0x0,%edi
f010071c:	c7 45 f0 02 00 00 00 	movl   $0x2,0xfffffff0(%ebp)
f0100723:	83 fb 02             	cmp    $0x2,%ebx
f0100726:	7f 1b                	jg     f0100743 <getva+0x7b>
f0100728:	e9 e5 00 00 00       	jmp    f0100812 <getva+0x14a>
f010072d:	c7 04 24 b0 aa 10 f0 	movl   $0xf010aab0,(%esp)
f0100734:	e8 fe 32 00 00       	call   f0103a37 <cprintf>
f0100739:	bf 00 00 00 00       	mov    $0x0,%edi
f010073e:	e9 d4 00 00 00       	jmp    f0100817 <getva+0x14f>
f0100743:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0100746:	0f b6 14 30          	movzbl (%eax,%esi,1),%edx
f010074a:	89 d1                	mov    %edx,%ecx
f010074c:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
f010074f:	3c 09                	cmp    $0x9,%al
f0100751:	77 0e                	ja     f0100761 <getva+0x99>
f0100753:	0f be d2             	movsbl %dl,%edx
f0100756:	89 f8                	mov    %edi,%eax
f0100758:	c1 e0 04             	shl    $0x4,%eax
f010075b:	8d 7c 02 d0          	lea    0xffffffd0(%edx,%eax,1),%edi
f010075f:	eb 2b                	jmp    f010078c <getva+0xc4>
f0100761:	8d 41 9f             	lea    0xffffff9f(%ecx),%eax
f0100764:	3c 05                	cmp    $0x5,%al
f0100766:	77 0e                	ja     f0100776 <getva+0xae>
f0100768:	0f be d2             	movsbl %dl,%edx
f010076b:	89 f8                	mov    %edi,%eax
f010076d:	c1 e0 04             	shl    $0x4,%eax
f0100770:	8d 7c 02 a9          	lea    0xffffffa9(%edx,%eax,1),%edi
f0100774:	eb 16                	jmp    f010078c <getva+0xc4>
f0100776:	c7 04 24 cd aa 10 f0 	movl   $0xf010aacd,(%esp)
f010077d:	e8 b5 32 00 00       	call   f0103a37 <cprintf>
f0100782:	bf 00 00 00 00       	mov    $0x0,%edi
f0100787:	e9 8b 00 00 00       	jmp    f0100817 <getva+0x14f>
f010078c:	83 45 f0 01          	addl   $0x1,0xfffffff0(%ebp)
f0100790:	39 5d f0             	cmp    %ebx,0xfffffff0(%ebp)
f0100793:	0f 84 7e 00 00 00    	je     f0100817 <getva+0x14f>
f0100799:	eb a8                	jmp    f0100743 <getva+0x7b>
f010079b:	83 f8 0a             	cmp    $0xa,%eax
f010079e:	66 90                	xchg   %ax,%ax
f01007a0:	75 4a                	jne    f01007ec <getva+0x124>
f01007a2:	85 db                	test   %ebx,%ebx
f01007a4:	7f 33                	jg     f01007d9 <getva+0x111>
f01007a6:	eb 6a                	jmp    f0100812 <getva+0x14a>
f01007a8:	0f b6 14 31          	movzbl (%ecx,%esi,1),%edx
f01007ac:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
f01007af:	3c 09                	cmp    $0x9,%al
f01007b1:	77 13                	ja     f01007c6 <getva+0xfe>
f01007b3:	0f be d2             	movsbl %dl,%edx
f01007b6:	8d 04 bf             	lea    (%edi,%edi,4),%eax
f01007b9:	8d 7c 42 d0          	lea    0xffffffd0(%edx,%eax,2),%edi
f01007bd:	83 c1 01             	add    $0x1,%ecx
f01007c0:	39 d9                	cmp    %ebx,%ecx
f01007c2:	75 e4                	jne    f01007a8 <getva+0xe0>
f01007c4:	eb 51                	jmp    f0100817 <getva+0x14f>
f01007c6:	c7 04 24 e6 aa 10 f0 	movl   $0xf010aae6,(%esp)
f01007cd:	e8 65 32 00 00       	call   f0103a37 <cprintf>
f01007d2:	bf 00 00 00 00       	mov    $0x0,%edi
f01007d7:	eb 3e                	jmp    f0100817 <getva+0x14f>
f01007d9:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
f01007dc:	bf 00 00 00 00       	mov    $0x0,%edi
f01007e1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01007e6:	3c 09                	cmp    $0x9,%al
f01007e8:	76 c9                	jbe    f01007b3 <getva+0xeb>
f01007ea:	eb da                	jmp    f01007c6 <getva+0xfe>
f01007ec:	c7 04 24 01 ab 10 f0 	movl   $0xf010ab01,(%esp)
f01007f3:	e8 3f 32 00 00       	call   f0103a37 <cprintf>
f01007f8:	bf 00 00 00 00       	mov    $0x0,%edi
f01007fd:	eb 18                	jmp    f0100817 <getva+0x14f>
f01007ff:	c7 04 24 12 ab 10 f0 	movl   $0xf010ab12,(%esp)
f0100806:	e8 2c 32 00 00       	call   f0103a37 <cprintf>
f010080b:	bf 00 00 00 00       	mov    $0x0,%edi
f0100810:	eb 05                	jmp    f0100817 <getva+0x14f>
f0100812:	bf 00 00 00 00       	mov    $0x0,%edi
f0100817:	89 f8                	mov    %edi,%eax
f0100819:	83 c4 0c             	add    $0xc,%esp
f010081c:	5b                   	pop    %ebx
f010081d:	5e                   	pop    %esi
f010081e:	5f                   	pop    %edi
f010081f:	5d                   	pop    %ebp
f0100820:	c3                   	ret    

f0100821 <mon_dumpx>:
f0100821:	55                   	push   %ebp
f0100822:	89 e5                	mov    %esp,%ebp
f0100824:	57                   	push   %edi
f0100825:	56                   	push   %esi
f0100826:	53                   	push   %ebx
f0100827:	83 ec 0c             	sub    $0xc,%esp
f010082a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010082d:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100831:	7f 0e                	jg     f0100841 <mon_dumpx+0x20>
f0100833:	c7 04 24 2c ab 10 f0 	movl   $0xf010ab2c,(%esp)
f010083a:	e8 f8 31 00 00       	call   f0103a37 <cprintf>
f010083f:	eb 59                	jmp    f010089a <mon_dumpx+0x79>
f0100841:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
f0100848:	00 
f0100849:	8b 43 04             	mov    0x4(%ebx),%eax
f010084c:	89 04 24             	mov    %eax,(%esp)
f010084f:	e8 74 fe ff ff       	call   f01006c8 <getva>
f0100854:	89 c7                	mov    %eax,%edi
f0100856:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f010085d:	00 
f010085e:	8b 43 08             	mov    0x8(%ebx),%eax
f0100861:	89 04 24             	mov    %eax,(%esp)
f0100864:	e8 5f fe ff ff       	call   f01006c8 <getva>
f0100869:	89 c6                	mov    %eax,%esi
f010086b:	85 ff                	test   %edi,%edi
f010086d:	7e 1f                	jle    f010088e <mon_dumpx+0x6d>
f010086f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100874:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
f0100877:	89 44 24 04          	mov    %eax,0x4(%esp)
f010087b:	c7 04 24 4a ab 10 f0 	movl   $0xf010ab4a,(%esp)
f0100882:	e8 b0 31 00 00       	call   f0103a37 <cprintf>
f0100887:	83 c3 01             	add    $0x1,%ebx
f010088a:	39 df                	cmp    %ebx,%edi
f010088c:	75 e6                	jne    f0100874 <mon_dumpx+0x53>
f010088e:	c7 04 24 09 ac 10 f0 	movl   $0xf010ac09,(%esp)
f0100895:	e8 9d 31 00 00       	call   f0103a37 <cprintf>
f010089a:	b8 00 00 00 00       	mov    $0x0,%eax
f010089f:	83 c4 0c             	add    $0xc,%esp
f01008a2:	5b                   	pop    %ebx
f01008a3:	5e                   	pop    %esi
f01008a4:	5f                   	pop    %edi
f01008a5:	5d                   	pop    %ebp
f01008a6:	c3                   	ret    

f01008a7 <mon_kerninfo>:
f01008a7:	55                   	push   %ebp
f01008a8:	89 e5                	mov    %esp,%ebp
f01008aa:	83 ec 18             	sub    $0x18,%esp
f01008ad:	c7 04 24 4e ab 10 f0 	movl   $0xf010ab4e,(%esp)
f01008b4:	e8 7e 31 00 00       	call   f0103a37 <cprintf>
f01008b9:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01008c0:	00 
f01008c1:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01008c8:	f0 
f01008c9:	c7 04 24 c0 ac 10 f0 	movl   $0xf010acc0,(%esp)
f01008d0:	e8 62 31 00 00       	call   f0103a37 <cprintf>
f01008d5:	c7 44 24 08 17 a8 10 	movl   $0x10a817,0x8(%esp)
f01008dc:	00 
f01008dd:	c7 44 24 04 17 a8 10 	movl   $0xf010a817,0x4(%esp)
f01008e4:	f0 
f01008e5:	c7 04 24 e4 ac 10 f0 	movl   $0xf010ace4,(%esp)
f01008ec:	e8 46 31 00 00       	call   f0103a37 <cprintf>
f01008f1:	c7 44 24 08 47 86 2a 	movl   $0x2a8647,0x8(%esp)
f01008f8:	00 
f01008f9:	c7 44 24 04 47 86 2a 	movl   $0xf02a8647,0x4(%esp)
f0100900:	f0 
f0100901:	c7 04 24 08 ad 10 f0 	movl   $0xf010ad08,(%esp)
f0100908:	e8 2a 31 00 00       	call   f0103a37 <cprintf>
f010090d:	c7 44 24 08 8c 98 2a 	movl   $0x2a988c,0x8(%esp)
f0100914:	00 
f0100915:	c7 44 24 04 8c 98 2a 	movl   $0xf02a988c,0x4(%esp)
f010091c:	f0 
f010091d:	c7 04 24 2c ad 10 f0 	movl   $0xf010ad2c,(%esp)
f0100924:	e8 0e 31 00 00       	call   f0103a37 <cprintf>
f0100929:	ba 8b 9c 2a f0       	mov    $0xf02a9c8b,%edx
f010092e:	81 ea 0c 00 10 f0    	sub    $0xf010000c,%edx
f0100934:	89 d0                	mov    %edx,%eax
f0100936:	c1 f8 1f             	sar    $0x1f,%eax
f0100939:	c1 e8 16             	shr    $0x16,%eax
f010093c:	01 d0                	add    %edx,%eax
f010093e:	c1 f8 0a             	sar    $0xa,%eax
f0100941:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100945:	c7 04 24 50 ad 10 f0 	movl   $0xf010ad50,(%esp)
f010094c:	e8 e6 30 00 00       	call   f0103a37 <cprintf>
f0100951:	b8 00 00 00 00       	mov    $0x0,%eax
f0100956:	c9                   	leave  
f0100957:	c3                   	ret    

f0100958 <mon_help>:
f0100958:	55                   	push   %ebp
f0100959:	89 e5                	mov    %esp,%ebp
f010095b:	53                   	push   %ebx
f010095c:	83 ec 14             	sub    $0x14,%esp
f010095f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100964:	8b 83 e4 b0 10 f0    	mov    0xf010b0e4(%ebx),%eax
f010096a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010096e:	8b 83 e0 b0 10 f0    	mov    0xf010b0e0(%ebx),%eax
f0100974:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100978:	c7 04 24 67 ab 10 f0 	movl   $0xf010ab67,(%esp)
f010097f:	e8 b3 30 00 00       	call   f0103a37 <cprintf>
f0100984:	83 c3 0c             	add    $0xc,%ebx
f0100987:	83 fb 6c             	cmp    $0x6c,%ebx
f010098a:	75 d8                	jne    f0100964 <mon_help+0xc>
f010098c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100991:	83 c4 14             	add    $0x14,%esp
f0100994:	5b                   	pop    %ebx
f0100995:	5d                   	pop    %ebp
f0100996:	c3                   	ret    

f0100997 <monitor>:
f0100997:	55                   	push   %ebp
f0100998:	89 e5                	mov    %esp,%ebp
f010099a:	57                   	push   %edi
f010099b:	56                   	push   %esi
f010099c:	53                   	push   %ebx
f010099d:	83 ec 4c             	sub    $0x4c,%esp
f01009a0:	c7 04 24 7c ad 10 f0 	movl   $0xf010ad7c,(%esp)
f01009a7:	e8 8b 30 00 00       	call   f0103a37 <cprintf>
f01009ac:	c7 04 24 a0 ad 10 f0 	movl   $0xf010ada0,(%esp)
f01009b3:	e8 7f 30 00 00       	call   f0103a37 <cprintf>
f01009b8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01009bc:	74 0b                	je     f01009c9 <monitor+0x32>
f01009be:	8b 45 08             	mov    0x8(%ebp),%eax
f01009c1:	89 04 24             	mov    %eax,(%esp)
f01009c4:	e8 d3 32 00 00       	call   f0103c9c <print_trapframe>
f01009c9:	c7 04 24 70 ab 10 f0 	movl   $0xf010ab70,(%esp)
f01009d0:	e8 fb 8a 00 00       	call   f01094d0 <readline>
f01009d5:	89 c3                	mov    %eax,%ebx
f01009d7:	85 c0                	test   %eax,%eax
f01009d9:	74 ee                	je     f01009c9 <monitor+0x32>
f01009db:	c7 45 b4 00 00 00 00 	movl   $0x0,0xffffffb4(%ebp)
f01009e2:	bf 00 00 00 00       	mov    $0x0,%edi
f01009e7:	eb 06                	jmp    f01009ef <monitor+0x58>
f01009e9:	c6 03 00             	movb   $0x0,(%ebx)
f01009ec:	83 c3 01             	add    $0x1,%ebx
f01009ef:	0f b6 03             	movzbl (%ebx),%eax
f01009f2:	84 c0                	test   %al,%al
f01009f4:	74 6a                	je     f0100a60 <monitor+0xc9>
f01009f6:	0f be c0             	movsbl %al,%eax
f01009f9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009fd:	c7 04 24 74 ab 10 f0 	movl   $0xf010ab74,(%esp)
f0100a04:	e8 52 8d 00 00       	call   f010975b <strchr>
f0100a09:	85 c0                	test   %eax,%eax
f0100a0b:	75 dc                	jne    f01009e9 <monitor+0x52>
f0100a0d:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a10:	74 4e                	je     f0100a60 <monitor+0xc9>
f0100a12:	83 ff 0f             	cmp    $0xf,%edi
f0100a15:	75 16                	jne    f0100a2d <monitor+0x96>
f0100a17:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100a1e:	00 
f0100a1f:	c7 04 24 79 ab 10 f0 	movl   $0xf010ab79,(%esp)
f0100a26:	e8 0c 30 00 00       	call   f0103a37 <cprintf>
f0100a2b:	eb 9c                	jmp    f01009c9 <monitor+0x32>
f0100a2d:	89 5c bd b4          	mov    %ebx,0xffffffb4(%ebp,%edi,4)
f0100a31:	83 c7 01             	add    $0x1,%edi
f0100a34:	0f b6 03             	movzbl (%ebx),%eax
f0100a37:	84 c0                	test   %al,%al
f0100a39:	75 0c                	jne    f0100a47 <monitor+0xb0>
f0100a3b:	eb b2                	jmp    f01009ef <monitor+0x58>
f0100a3d:	83 c3 01             	add    $0x1,%ebx
f0100a40:	0f b6 03             	movzbl (%ebx),%eax
f0100a43:	84 c0                	test   %al,%al
f0100a45:	74 a8                	je     f01009ef <monitor+0x58>
f0100a47:	0f be c0             	movsbl %al,%eax
f0100a4a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a4e:	c7 04 24 74 ab 10 f0 	movl   $0xf010ab74,(%esp)
f0100a55:	e8 01 8d 00 00       	call   f010975b <strchr>
f0100a5a:	85 c0                	test   %eax,%eax
f0100a5c:	74 df                	je     f0100a3d <monitor+0xa6>
f0100a5e:	eb 8f                	jmp    f01009ef <monitor+0x58>
f0100a60:	c7 44 bd b4 00 00 00 	movl   $0x0,0xffffffb4(%ebp,%edi,4)
f0100a67:	00 
f0100a68:	85 ff                	test   %edi,%edi
f0100a6a:	0f 84 59 ff ff ff    	je     f01009c9 <monitor+0x32>
f0100a70:	be 00 00 00 00       	mov    $0x0,%esi
f0100a75:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100a7a:	8b 83 e0 b0 10 f0    	mov    0xf010b0e0(%ebx),%eax
f0100a80:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a84:	8b 45 b4             	mov    0xffffffb4(%ebp),%eax
f0100a87:	89 04 24             	mov    %eax,(%esp)
f0100a8a:	e8 56 8c 00 00       	call   f01096e5 <strcmp>
f0100a8f:	85 c0                	test   %eax,%eax
f0100a91:	75 25                	jne    f0100ab8 <monitor+0x121>
f0100a93:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100a96:	8b 55 08             	mov    0x8(%ebp),%edx
f0100a99:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100a9d:	8d 55 b4             	lea    0xffffffb4(%ebp),%edx
f0100aa0:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100aa4:	89 3c 24             	mov    %edi,(%esp)
f0100aa7:	ff 14 85 e8 b0 10 f0 	call   *0xf010b0e8(,%eax,4)
f0100aae:	85 c0                	test   %eax,%eax
f0100ab0:	0f 89 13 ff ff ff    	jns    f01009c9 <monitor+0x32>
f0100ab6:	eb 23                	jmp    f0100adb <monitor+0x144>
f0100ab8:	83 c6 01             	add    $0x1,%esi
f0100abb:	83 c3 0c             	add    $0xc,%ebx
f0100abe:	83 fe 09             	cmp    $0x9,%esi
f0100ac1:	75 b7                	jne    f0100a7a <monitor+0xe3>
f0100ac3:	8b 45 b4             	mov    0xffffffb4(%ebp),%eax
f0100ac6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100aca:	c7 04 24 96 ab 10 f0 	movl   $0xf010ab96,(%esp)
f0100ad1:	e8 61 2f 00 00       	call   f0103a37 <cprintf>
f0100ad6:	e9 ee fe ff ff       	jmp    f01009c9 <monitor+0x32>
f0100adb:	83 c4 4c             	add    $0x4c,%esp
f0100ade:	5b                   	pop    %ebx
f0100adf:	5e                   	pop    %esi
f0100ae0:	5f                   	pop    %edi
f0100ae1:	5d                   	pop    %ebp
f0100ae2:	c3                   	ret    

f0100ae3 <mon_stepi>:
f0100ae3:	55                   	push   %ebp
f0100ae4:	89 e5                	mov    %esp,%ebp
f0100ae6:	53                   	push   %ebx
f0100ae7:	83 ec 14             	sub    $0x14,%esp
f0100aea:	8b 45 10             	mov    0x10(%ebp),%eax
f0100aed:	8b 58 0c             	mov    0xc(%eax),%ebx
f0100af0:	83 eb 20             	sub    $0x20,%ebx
f0100af3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0100afa:	00 
f0100afb:	8b 43 30             	mov    0x30(%ebx),%eax
f0100afe:	89 04 24             	mov    %eax,(%esp)
f0100b01:	e8 f4 81 00 00       	call   f0108cfa <monitor_disas>
f0100b06:	81 4b 38 00 01 00 00 	orl    $0x100,0x38(%ebx)
//LAB 3: add write esp here
static __inline void
write_esp(uint32_t esp)
{
        __asm __volatile("movl %0,%%esp" : : "r" (esp));
f0100b0d:	89 dc                	mov    %ebx,%esp
f0100b0f:	e8 7e 40 00 00       	call   f0104b92 <trapret>
f0100b14:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b19:	83 c4 14             	add    $0x14,%esp
f0100b1c:	5b                   	pop    %ebx
f0100b1d:	5d                   	pop    %ebp
f0100b1e:	c3                   	ret    

f0100b1f <mon_dumpxp>:
f0100b1f:	55                   	push   %ebp
f0100b20:	89 e5                	mov    %esp,%ebp
f0100b22:	57                   	push   %edi
f0100b23:	56                   	push   %esi
f0100b24:	53                   	push   %ebx
f0100b25:	83 ec 1c             	sub    $0x1c,%esp
f0100b28:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100b2b:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100b2f:	7f 11                	jg     f0100b42 <mon_dumpxp+0x23>
f0100b31:	c7 04 24 2c ab 10 f0 	movl   $0xf010ab2c,(%esp)
f0100b38:	e8 fa 2e 00 00       	call   f0103a37 <cprintf>
f0100b3d:	e9 88 00 00 00       	jmp    f0100bca <mon_dumpxp+0xab>
f0100b42:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
f0100b49:	00 
f0100b4a:	8b 43 04             	mov    0x4(%ebx),%eax
f0100b4d:	89 04 24             	mov    %eax,(%esp)
f0100b50:	e8 73 fb ff ff       	call   f01006c8 <getva>
f0100b55:	89 c7                	mov    %eax,%edi
f0100b57:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100b5e:	00 
f0100b5f:	8b 43 08             	mov    0x8(%ebx),%eax
f0100b62:	89 04 24             	mov    %eax,(%esp)
f0100b65:	e8 5e fb ff ff       	call   f01006c8 <getva>
f0100b6a:	89 c6                	mov    %eax,%esi
f0100b6c:	c1 e8 0c             	shr    $0xc,%eax
f0100b6f:	3b 05 70 98 2a f0    	cmp    0xf02a9870,%eax
f0100b75:	72 20                	jb     f0100b97 <mon_dumpxp+0x78>
f0100b77:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100b7b:	c7 44 24 08 c8 ad 10 	movl   $0xf010adc8,0x8(%esp)
f0100b82:	f0 
f0100b83:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
f0100b8a:	00 
f0100b8b:	c7 04 24 ac ab 10 f0 	movl   $0xf010abac,(%esp)
f0100b92:	e8 ef f4 ff ff       	call   f0100086 <_panic>
f0100b97:	85 ff                	test   %edi,%edi
f0100b99:	7e 23                	jle    f0100bbe <mon_dumpxp+0x9f>
f0100b9b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ba0:	8b 84 9e 00 00 00 f0 	mov    0xf0000000(%esi,%ebx,4),%eax
f0100ba7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bab:	c7 04 24 4a ab 10 f0 	movl   $0xf010ab4a,(%esp)
f0100bb2:	e8 80 2e 00 00       	call   f0103a37 <cprintf>
f0100bb7:	83 c3 01             	add    $0x1,%ebx
f0100bba:	39 df                	cmp    %ebx,%edi
f0100bbc:	75 e2                	jne    f0100ba0 <mon_dumpxp+0x81>
f0100bbe:	c7 04 24 09 ac 10 f0 	movl   $0xf010ac09,(%esp)
f0100bc5:	e8 6d 2e 00 00       	call   f0103a37 <cprintf>
f0100bca:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bcf:	83 c4 1c             	add    $0x1c,%esp
f0100bd2:	5b                   	pop    %ebx
f0100bd3:	5e                   	pop    %esi
f0100bd4:	5f                   	pop    %edi
f0100bd5:	5d                   	pop    %ebp
f0100bd6:	c3                   	ret    

f0100bd7 <mon_permission>:
f0100bd7:	55                   	push   %ebp
f0100bd8:	89 e5                	mov    %esp,%ebp
f0100bda:	83 ec 38             	sub    $0x38,%esp
f0100bdd:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
f0100be0:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
f0100be3:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
f0100be6:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100be9:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100bec:	83 ff 03             	cmp    $0x3,%edi
f0100bef:	7f 11                	jg     f0100c02 <mon_permission+0x2b>
f0100bf1:	c7 04 24 2c ab 10 f0 	movl   $0xf010ab2c,(%esp)
f0100bf8:	e8 3a 2e 00 00       	call   f0103a37 <cprintf>
f0100bfd:	e9 62 01 00 00       	jmp    f0100d64 <mon_permission+0x18d>
f0100c02:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100c09:	00 
f0100c0a:	8b 46 08             	mov    0x8(%esi),%eax
f0100c0d:	89 04 24             	mov    %eax,(%esp)
f0100c10:	e8 b3 fa ff ff       	call   f01006c8 <getva>
f0100c15:	89 c3                	mov    %eax,%ebx
f0100c17:	8b 46 04             	mov    0x4(%esi),%eax
f0100c1a:	0f b6 00             	movzbl (%eax),%eax
f0100c1d:	88 45 e3             	mov    %al,0xffffffe3(%ebp)
f0100c20:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0100c23:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c27:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100c2b:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f0100c30:	89 04 24             	mov    %eax,(%esp)
f0100c33:	e8 f5 07 00 00       	call   f010142d <page_lookup>
f0100c38:	85 c0                	test   %eax,%eax
f0100c3a:	0f 84 14 01 00 00    	je     f0100d54 <mon_permission+0x17d>
f0100c40:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100c45:	b9 03 00 00 00       	mov    $0x3,%ecx
f0100c4a:	8b 14 8e             	mov    (%esi,%ecx,4),%edx
f0100c4d:	0f b6 02             	movzbl (%edx),%eax
f0100c50:	83 e8 41             	sub    $0x41,%eax
f0100c53:	3c 16                	cmp    $0x16,%al
f0100c55:	0f 87 81 00 00 00    	ja     f0100cdc <mon_permission+0x105>
f0100c5b:	0f b6 c0             	movzbl %al,%eax
f0100c5e:	ff 24 85 80 b0 10 f0 	jmp    *0xf010b080(,%eax,4)
f0100c65:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f0100c69:	84 c0                	test   %al,%al
f0100c6b:	74 3f                	je     f0100cac <mon_permission+0xd5>
f0100c6d:	80 7a 03 00          	cmpb   $0x0,0x3(%edx)
f0100c71:	75 3e                	jne    f0100cb1 <mon_permission+0xda>
f0100c73:	3c 57                	cmp    $0x57,%al
f0100c75:	75 10                	jne    f0100c87 <mon_permission+0xb0>
f0100c77:	80 7a 02 54          	cmpb   $0x54,0x2(%edx)
f0100c7b:	90                   	nop    
f0100c7c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0100c80:	75 15                	jne    f0100c97 <mon_permission+0xc0>
f0100c82:	83 cb 08             	or     $0x8,%ebx
f0100c85:	eb 67                	jmp    f0100cee <mon_permission+0x117>
f0100c87:	3c 43                	cmp    $0x43,%al
f0100c89:	75 0c                	jne    f0100c97 <mon_permission+0xc0>
f0100c8b:	80 7a 02 44          	cmpb   $0x44,0x2(%edx)
f0100c8f:	90                   	nop    
f0100c90:	75 05                	jne    f0100c97 <mon_permission+0xc0>
f0100c92:	83 cb 10             	or     $0x10,%ebx
f0100c95:	eb 57                	jmp    f0100cee <mon_permission+0x117>
f0100c97:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100c9b:	c7 04 24 bb ab 10 f0 	movl   $0xf010abbb,(%esp)
f0100ca2:	e8 90 2d 00 00       	call   f0103a37 <cprintf>
f0100ca7:	e9 b8 00 00 00       	jmp    f0100d64 <mon_permission+0x18d>
f0100cac:	83 cb 01             	or     $0x1,%ebx
f0100caf:	eb 3d                	jmp    f0100cee <mon_permission+0x117>
f0100cb1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100cb5:	c7 04 24 bb ab 10 f0 	movl   $0xf010abbb,(%esp)
f0100cbc:	e8 76 2d 00 00       	call   f0103a37 <cprintf>
f0100cc1:	e9 9e 00 00 00       	jmp    f0100d64 <mon_permission+0x18d>
f0100cc6:	83 cb 02             	or     $0x2,%ebx
f0100cc9:	eb 23                	jmp    f0100cee <mon_permission+0x117>
f0100ccb:	83 cb 04             	or     $0x4,%ebx
f0100cce:	66 90                	xchg   %ax,%ax
f0100cd0:	eb 1c                	jmp    f0100cee <mon_permission+0x117>
f0100cd2:	83 cb 40             	or     $0x40,%ebx
f0100cd5:	eb 17                	jmp    f0100cee <mon_permission+0x117>
f0100cd7:	83 cb 20             	or     $0x20,%ebx
f0100cda:	eb 12                	jmp    f0100cee <mon_permission+0x117>
f0100cdc:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100ce0:	c7 04 24 bb ab 10 f0 	movl   $0xf010abbb,(%esp)
f0100ce7:	e8 4b 2d 00 00       	call   f0103a37 <cprintf>
f0100cec:	eb 76                	jmp    f0100d64 <mon_permission+0x18d>
f0100cee:	83 c1 01             	add    $0x1,%ecx
f0100cf1:	39 f9                	cmp    %edi,%ecx
f0100cf3:	0f 85 51 ff ff ff    	jne    f0100c4a <mon_permission+0x73>
f0100cf9:	80 7d e3 63          	cmpb   $0x63,0xffffffe3(%ebp)
f0100cfd:	8d 76 00             	lea    0x0(%esi),%esi
f0100d00:	74 10                	je     f0100d12 <mon_permission+0x13b>
f0100d02:	80 7d e3 73          	cmpb   $0x73,0xffffffe3(%ebp)
f0100d06:	75 28                	jne    f0100d30 <mon_permission+0x159>
f0100d08:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
f0100d0b:	0f be c3             	movsbl %bl,%eax
f0100d0e:	09 02                	or     %eax,(%edx)
f0100d10:	eb 34                	jmp    f0100d46 <mon_permission+0x16f>
f0100d12:	0f be c3             	movsbl %bl,%eax
f0100d15:	a8 01                	test   $0x1,%al
f0100d17:	74 0e                	je     f0100d27 <mon_permission+0x150>
f0100d19:	c7 04 24 d7 ab 10 f0 	movl   $0xf010abd7,(%esp)
f0100d20:	e8 12 2d 00 00       	call   f0103a37 <cprintf>
f0100d25:	eb 3d                	jmp    f0100d64 <mon_permission+0x18d>
f0100d27:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
f0100d2a:	f7 d0                	not    %eax
f0100d2c:	21 02                	and    %eax,(%edx)
f0100d2e:	eb 16                	jmp    f0100d46 <mon_permission+0x16f>
f0100d30:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
f0100d34:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d38:	c7 04 24 ec ad 10 f0 	movl   $0xf010adec,(%esp)
f0100d3f:	e8 f3 2c 00 00       	call   f0103a37 <cprintf>
f0100d44:	eb 1e                	jmp    f0100d64 <mon_permission+0x18d>
f0100d46:	c7 04 24 20 ae 10 f0 	movl   $0xf010ae20,(%esp)
f0100d4d:	e8 e5 2c 00 00       	call   f0103a37 <cprintf>
f0100d52:	eb 10                	jmp    f0100d64 <mon_permission+0x18d>
f0100d54:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100d58:	c7 04 24 48 ae 10 f0 	movl   $0xf010ae48,(%esp)
f0100d5f:	e8 d3 2c 00 00       	call   f0103a37 <cprintf>
f0100d64:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d69:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
f0100d6c:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
f0100d6f:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
f0100d72:	89 ec                	mov    %ebp,%esp
f0100d74:	5d                   	pop    %ebp
f0100d75:	c3                   	ret    

f0100d76 <mon_showmappings>:
f0100d76:	55                   	push   %ebp
f0100d77:	89 e5                	mov    %esp,%ebp
f0100d79:	56                   	push   %esi
f0100d7a:	53                   	push   %ebx
f0100d7b:	83 ec 20             	sub    $0x20,%esp
f0100d7e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100d81:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100d85:	74 11                	je     f0100d98 <mon_showmappings+0x22>
f0100d87:	c7 04 24 2c ab 10 f0 	movl   $0xf010ab2c,(%esp)
f0100d8e:	e8 a4 2c 00 00       	call   f0103a37 <cprintf>
f0100d93:	e9 69 01 00 00       	jmp    f0100f01 <mon_showmappings+0x18b>
f0100d98:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100d9f:	00 
f0100da0:	8b 46 04             	mov    0x4(%esi),%eax
f0100da3:	89 04 24             	mov    %eax,(%esp)
f0100da6:	e8 1d f9 ff ff       	call   f01006c8 <getva>
f0100dab:	89 c3                	mov    %eax,%ebx
f0100dad:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100db4:	00 
f0100db5:	8b 46 08             	mov    0x8(%esi),%eax
f0100db8:	89 04 24             	mov    %eax,(%esp)
f0100dbb:	e8 08 f9 ff ff       	call   f01006c8 <getva>
f0100dc0:	89 c6                	mov    %eax,%esi
f0100dc2:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
f0100dc5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100dc9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100dcd:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f0100dd2:	89 04 24             	mov    %eax,(%esp)
f0100dd5:	e8 53 06 00 00       	call   f010142d <page_lookup>
f0100dda:	85 c0                	test   %eax,%eax
f0100ddc:	0f 84 00 01 00 00    	je     f0100ee2 <mon_showmappings+0x16c>
f0100de2:	2b 05 7c 98 2a f0    	sub    0xf02a987c,%eax
f0100de8:	c1 f8 02             	sar    $0x2,%eax
f0100deb:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100df1:	c1 e0 0c             	shl    $0xc,%eax
f0100df4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100df8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100dfc:	c7 04 24 80 ae 10 f0 	movl   $0xf010ae80,(%esp)
f0100e03:	e8 2f 2c 00 00       	call   f0103a37 <cprintf>
f0100e08:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0100e0b:	f6 00 40             	testb  $0x40,(%eax)
f0100e0e:	74 0e                	je     f0100e1e <mon_showmappings+0xa8>
f0100e10:	c7 04 24 f9 ab 10 f0 	movl   $0xf010abf9,(%esp)
f0100e17:	e8 1b 2c 00 00       	call   f0103a37 <cprintf>
f0100e1c:	eb 0c                	jmp    f0100e2a <mon_showmappings+0xb4>
f0100e1e:	c7 04 24 f1 ab 10 f0 	movl   $0xf010abf1,(%esp)
f0100e25:	e8 0d 2c 00 00       	call   f0103a37 <cprintf>
f0100e2a:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0100e2d:	f6 00 20             	testb  $0x20,(%eax)
f0100e30:	74 0e                	je     f0100e40 <mon_showmappings+0xca>
f0100e32:	c7 04 24 f4 ab 10 f0 	movl   $0xf010abf4,(%esp)
f0100e39:	e8 f9 2b 00 00       	call   f0103a37 <cprintf>
f0100e3e:	eb 0c                	jmp    f0100e4c <mon_showmappings+0xd6>
f0100e40:	c7 04 24 f1 ab 10 f0 	movl   $0xf010abf1,(%esp)
f0100e47:	e8 eb 2b 00 00       	call   f0103a37 <cprintf>
f0100e4c:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0100e4f:	f6 00 10             	testb  $0x10,(%eax)
f0100e52:	74 0e                	je     f0100e62 <mon_showmappings+0xec>
f0100e54:	c7 04 24 f7 ab 10 f0 	movl   $0xf010abf7,(%esp)
f0100e5b:	e8 d7 2b 00 00       	call   f0103a37 <cprintf>
f0100e60:	eb 0c                	jmp    f0100e6e <mon_showmappings+0xf8>
f0100e62:	c7 04 24 f1 ab 10 f0 	movl   $0xf010abf1,(%esp)
f0100e69:	e8 c9 2b 00 00       	call   f0103a37 <cprintf>
f0100e6e:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0100e71:	f6 00 08             	testb  $0x8,(%eax)
f0100e74:	74 0e                	je     f0100e84 <mon_showmappings+0x10e>
f0100e76:	c7 04 24 fc ab 10 f0 	movl   $0xf010abfc,(%esp)
f0100e7d:	e8 b5 2b 00 00       	call   f0103a37 <cprintf>
f0100e82:	eb 0c                	jmp    f0100e90 <mon_showmappings+0x11a>
f0100e84:	c7 04 24 f1 ab 10 f0 	movl   $0xf010abf1,(%esp)
f0100e8b:	e8 a7 2b 00 00       	call   f0103a37 <cprintf>
f0100e90:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0100e93:	f6 00 04             	testb  $0x4,(%eax)
f0100e96:	74 0e                	je     f0100ea6 <mon_showmappings+0x130>
f0100e98:	c7 04 24 01 ac 10 f0 	movl   $0xf010ac01,(%esp)
f0100e9f:	e8 93 2b 00 00       	call   f0103a37 <cprintf>
f0100ea4:	eb 0c                	jmp    f0100eb2 <mon_showmappings+0x13c>
f0100ea6:	c7 04 24 f1 ab 10 f0 	movl   $0xf010abf1,(%esp)
f0100ead:	e8 85 2b 00 00       	call   f0103a37 <cprintf>
f0100eb2:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0100eb5:	f6 00 02             	testb  $0x2,(%eax)
f0100eb8:	74 0e                	je     f0100ec8 <mon_showmappings+0x152>
f0100eba:	c7 04 24 04 ac 10 f0 	movl   $0xf010ac04,(%esp)
f0100ec1:	e8 71 2b 00 00       	call   f0103a37 <cprintf>
f0100ec6:	eb 0c                	jmp    f0100ed4 <mon_showmappings+0x15e>
f0100ec8:	c7 04 24 f1 ab 10 f0 	movl   $0xf010abf1,(%esp)
f0100ecf:	e8 63 2b 00 00       	call   f0103a37 <cprintf>
f0100ed4:	c7 04 24 07 ac 10 f0 	movl   $0xf010ac07,(%esp)
f0100edb:	e8 57 2b 00 00       	call   f0103a37 <cprintf>
f0100ee0:	eb 10                	jmp    f0100ef2 <mon_showmappings+0x17c>
f0100ee2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ee6:	c7 04 24 48 ae 10 f0 	movl   $0xf010ae48,(%esp)
f0100eed:	e8 45 2b 00 00       	call   f0103a37 <cprintf>
f0100ef2:	39 f3                	cmp    %esi,%ebx
f0100ef4:	74 0b                	je     f0100f01 <mon_showmappings+0x18b>
f0100ef6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100efc:	e9 c1 fe ff ff       	jmp    f0100dc2 <mon_showmappings+0x4c>
f0100f01:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f06:	83 c4 20             	add    $0x20,%esp
f0100f09:	5b                   	pop    %ebx
f0100f0a:	5e                   	pop    %esi
f0100f0b:	5d                   	pop    %ebp
f0100f0c:	c3                   	ret    

f0100f0d <mon_backtrace>:
f0100f0d:	55                   	push   %ebp
f0100f0e:	89 e5                	mov    %esp,%ebp
f0100f10:	57                   	push   %edi
f0100f11:	56                   	push   %esi
f0100f12:	53                   	push   %ebx
f0100f13:	83 ec 4c             	sub    $0x4c,%esp
static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100f16:	89 eb                	mov    %ebp,%ebx
f0100f18:	c7 04 24 0b ac 10 f0 	movl   $0xf010ac0b,(%esp)
f0100f1f:	e8 13 2b 00 00       	call   f0103a37 <cprintf>
f0100f24:	8d 7d c8             	lea    0xffffffc8(%ebp),%edi
f0100f27:	89 5d c0             	mov    %ebx,0xffffffc0(%ebp)
f0100f2a:	8b 73 04             	mov    0x4(%ebx),%esi
f0100f2d:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f32:	8b 44 93 08          	mov    0x8(%ebx,%edx,4),%eax
f0100f36:	89 04 97             	mov    %eax,(%edi,%edx,4)
f0100f39:	83 c2 01             	add    $0x1,%edx
f0100f3c:	83 fa 05             	cmp    $0x5,%edx
f0100f3f:	75 f1                	jne    f0100f32 <mon_backtrace+0x25>
f0100f41:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100f45:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f49:	c7 04 24 1e ac 10 f0 	movl   $0xf010ac1e,(%esp)
f0100f50:	e8 e2 2a 00 00       	call   f0103a37 <cprintf>
f0100f55:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f0100f58:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100f5c:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
f0100f5f:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100f63:	8b 45 d0             	mov    0xffffffd0(%ebp),%eax
f0100f66:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f6a:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
f0100f6d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f71:	8b 45 c8             	mov    0xffffffc8(%ebp),%eax
f0100f74:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f78:	c7 04 24 b0 ae 10 f0 	movl   $0xf010aeb0,(%esp)
f0100f7f:	e8 b3 2a 00 00       	call   f0103a37 <cprintf>
f0100f84:	8d 45 dc             	lea    0xffffffdc(%ebp),%eax
f0100f87:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f8b:	89 34 24             	mov    %esi,(%esp)
f0100f8e:	e8 73 44 00 00       	call   f0105406 <debuginfo_eip>
f0100f93:	85 c0                	test   %eax,%eax
f0100f95:	75 31                	jne    f0100fc8 <mon_backtrace+0xbb>
f0100f97:	89 f0                	mov    %esi,%eax
f0100f99:	2b 45 ec             	sub    0xffffffec(%ebp),%eax
f0100f9c:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100fa0:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
f0100fa3:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100fa7:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f0100faa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fae:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
f0100fb1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100fb5:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
f0100fb8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fbc:	c7 04 24 31 ac 10 f0 	movl   $0xf010ac31,(%esp)
f0100fc3:	e8 6f 2a 00 00       	call   f0103a37 <cprintf>
f0100fc8:	8b 45 c0             	mov    0xffffffc0(%ebp),%eax
f0100fcb:	8b 18                	mov    (%eax),%ebx
f0100fcd:	85 db                	test   %ebx,%ebx
f0100fcf:	0f 85 52 ff ff ff    	jne    f0100f27 <mon_backtrace+0x1a>
f0100fd5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fda:	83 c4 4c             	add    $0x4c,%esp
f0100fdd:	5b                   	pop    %ebx
f0100fde:	5e                   	pop    %esi
f0100fdf:	5f                   	pop    %edi
f0100fe0:	5d                   	pop    %ebp
f0100fe1:	c3                   	ret    

f0100fe2 <mon_continue>:
f0100fe2:	55                   	push   %ebp
f0100fe3:	89 e5                	mov    %esp,%ebp
f0100fe5:	83 ec 08             	sub    $0x8,%esp
f0100fe8:	8b 55 10             	mov    0x10(%ebp),%edx
f0100feb:	8b 42 28             	mov    0x28(%edx),%eax
f0100fee:	83 f8 03             	cmp    $0x3,%eax
f0100ff1:	74 05                	je     f0100ff8 <mon_continue+0x16>
f0100ff3:	83 f8 01             	cmp    $0x1,%eax
f0100ff6:	75 1b                	jne    f0101013 <mon_continue+0x31>
f0100ff8:	8b 52 0c             	mov    0xc(%edx),%edx
f0100ffb:	83 ea 20             	sub    $0x20,%edx
f0100ffe:	8b 42 38             	mov    0x38(%edx),%eax
f0101001:	0d 00 00 01 00       	or     $0x10000,%eax
f0101006:	80 e4 fe             	and    $0xfe,%ah
f0101009:	89 42 38             	mov    %eax,0x38(%edx)
//LAB 3: add write esp here
static __inline void
write_esp(uint32_t esp)
{
        __asm __volatile("movl %0,%%esp" : : "r" (esp));
f010100c:	89 d4                	mov    %edx,%esp
f010100e:	e8 7f 3b 00 00       	call   f0104b92 <trapret>
f0101013:	b8 00 00 00 00       	mov    $0x0,%eax
f0101018:	c9                   	leave  
f0101019:	c3                   	ret    
f010101a:	00 00                	add    %al,(%eax)
f010101c:	00 00                	add    %al,(%eax)
	...

f0101020 <boot_alloc>:
// before the page_free_list has been set up.
// 
static void*
boot_alloc(uint32_t n, uint32_t align)
{
f0101020:	55                   	push   %ebp
f0101021:	89 e5                	mov    %esp,%ebp
f0101023:	83 ec 0c             	sub    $0xc,%esp
f0101026:	89 1c 24             	mov    %ebx,(%esp)
f0101029:	89 74 24 04          	mov    %esi,0x4(%esp)
f010102d:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101031:	89 c3                	mov    %eax,%ebx
	extern char end[];//指向内核bss段的末尾
	void *v;

	// Initialize boot_freemem if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment -
	// i.e., the first virtual address that the linker
	// did _not_ assign to any kernel code or global variables.
	if (boot_freemem == 0)
f0101033:	83 3d b4 88 2a f0 00 	cmpl   $0x0,0xf02a88b4
f010103a:	75 0a                	jne    f0101046 <boot_alloc+0x26>
		boot_freemem = end;
f010103c:	c7 05 b4 88 2a f0 8c 	movl   $0xf02a988c,0xf02a88b4
f0101043:	98 2a f0 

	// LAB 2: Your code here:
	//	Step 1: round boot_freemem up to be aligned properly
	//		(hint: look in types.h for some handy macros)
	//	Step 2: save current value of boot_freemem as allocated chunk
	//	Step 3: increase boot_freemem to record allocation
	//	Step 4: return allocated chunk
	boot_freemem=ROUNDUP(boot_freemem,align);
f0101046:	a1 b4 88 2a f0       	mov    0xf02a88b4,%eax
f010104b:	83 e8 01             	sub    $0x1,%eax
f010104e:	8d 3c 10             	lea    (%eax,%edx,1),%edi
f0101051:	89 f8                	mov    %edi,%eax
f0101053:	89 d6                	mov    %edx,%esi
f0101055:	ba 00 00 00 00       	mov    $0x0,%edx
f010105a:	f7 f6                	div    %esi
f010105c:	89 f8                	mov    %edi,%eax
f010105e:	29 d0                	sub    %edx,%eax
	v=(void *)boot_freemem;
	boot_freemem=boot_freemem+n;
f0101060:	8d 14 18             	lea    (%eax,%ebx,1),%edx
f0101063:	89 15 b4 88 2a f0    	mov    %edx,0xf02a88b4
	return v;//这里v是个虚拟地址
	//return NULL;
}
f0101069:	8b 1c 24             	mov    (%esp),%ebx
f010106c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101070:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0101074:	89 ec                	mov    %ebp,%esp
f0101076:	5d                   	pop    %ebp
f0101077:	c3                   	ret    

f0101078 <page_free>:

// Set up a two-level page table:
//    boot_pgdir is its linear (virtual) address of the root
//    boot_cr3 is the physical adresss of the root
// Then turn on paging.  Then effectively turn off segmentation.
// (i.e., the segment base addrs are set to zero).
// 
// This function only sets up the kernel part of the address space
// (ie. addresses >= UTOP).  The user part of the address space
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
{
	pde_t* pgdir;
	uint32_t cr0;
	size_t n;

	// Delete this line:
	//panic("i386_vm_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	pgdir = boot_alloc(PGSIZE, PGSIZE);
	memset(pgdir, 0, PGSIZE);
	boot_pgdir = pgdir;
	boot_cr3 = PADDR(pgdir);

	//////////////////////////////////////////////////////////////////////
	// Recursively insert PD in itself as a page table, to form
	// a virtual page table at virtual address VPT.
	//把页目录表当成一个页表，并填写相应页目录项.该虚拟页表在VPT处。
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)
	//内核使用的当前页表，内核可读写，用户无法访问
	// Permissions: kernel RW, user NONE
	pgdir[PDX(VPT)] = PADDR(pgdir)|PTE_W|PTE_P;

	// same for UVPT
	// Permissions: kernel R, user R 
	pgdir[PDX(UVPT)] = PADDR(pgdir)|PTE_U|PTE_P;

	//////////////////////////////////////////////////////////////////////
	// Allocate an array of npage 'struct Page's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct Page in this
	// array.  'npage' is the number of physical pages in memory.
	// User-level programs will get read-only access to the array as well.
	// Your code goes here:
	pages=(struct Page*)boot_alloc(npage*sizeof(struct Page),PGSIZE);

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs=(struct Env*)boot_alloc(NENV*sizeof(struct Env),PGSIZE);
	//////////////////////////////////////////////////////////////////////
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_segment or page_insert
	page_init();

	check_page_alloc();

	page_check();

	//////////////////////////////////////////////////////////////////////
	// Now we set up virtual memory 
	
	//////////////////////////////////////////////////////////////////////
	// Map 'pages' read-only by the user at linear address UPAGES
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_segment(boot_pgdir,UPAGES,npage*sizeof(struct Page),PADDR(pages),PTE_U|PTE_P);
	//////////////////////////////////////////////////////////////////////
	// Map the 'envs' array read-only by the user at linear address UENVS
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_segment(boot_pgdir,UENVS,NENV*sizeof(struct Env),PADDR(envs),PTE_U|PTE_P);
	//////////////////////////////////////////////////////////////////////
	// Use the physical memory that 'bootstack' refers to as the kernel
	// stack.  The kernel stack grows down from virtual address KSTACKTOP.
	// We consider the entire range from [KSTACKTOP-PTSIZE, KSTACKTOP) 
	// to be the kernel stack, but break this into two pieces:
	//     * [KSTACKTOP-KSTKSIZE, KSTACKTOP) -- backed by physical memory
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_segment(boot_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W |PTE_P);
	//////////////////////////////////////////////////////////////////////
	// Map all of physical memory at KERNBASE. 
	// Ie.  the VA range [KERNBASE, 2^32-1) should map to
	//      the PA range [0, 2^32-1 - KERNBASE)
	// 虚拟地址范围[0xf0000000,0xffffffff]===>物理地址范围[0x0,0x0fffffff]
	// 内核的链接地址的开始地址是0xf0100000===>物理地址0x100000
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here: 
	boot_map_segment(boot_pgdir,KERNBASE,0xffffffff-KERNBASE,0x0,PTE_W | PTE_P);
	// Check that the initial page directory has been set up correctly.
	check_boot_pgdir();

	//////////////////////////////////////////////////////////////////////
	// On x86, segmentation maps a VA to a LA (linear addr) and
	// paging maps the LA to a PA.  I.e. VA => LA => PA.  If paging is
	// turned off the LA is used as the PA.  Note: there is no way to
	// turn off segmentation.  The closest thing is to set the base
	// address to 0, so the VA => LA mapping is the identity.

	// Current mapping: VA KERNBASE+x => PA x.
	//     (segmentation base=-KERNBASE and paging is off)

	// From here on down we must maintain this VA KERNBASE + x => PA x
	// mapping, even though we are turning on paging and reconfiguring
	// segmentation.

	// Map VA 0:4MB same as VA KERNBASE, i.e. to PA 0:4MB.
	// (Limits our kernel to <4MB)
	pgdir[0] = pgdir[PDX(KERNBASE)];

	// Install page table.
	lcr3(boot_cr3);

	// Turn on paging.完成虚拟内存相关设置后，开启分页机制
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_TS|CR0_EM|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Current mapping: KERNBASE+x => x => x.
	// (x < 4MB so uses paging pgdir[0])

	// Reload all segment registers.初始化GDT,将GDT这中
	//段基地址设置为0，关闭分段机制，这时候kernel的
	//虚拟地址和线性地址是一样的，都是链接地址。
	//内核的物理地址是加载地址。
	asm volatile("lgdt gdt_pd");
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));  // reload cs
	asm volatile("lldt %%ax" :: "a" (0));

	// Final mapping: KERNBASE+x => KERNBASE+x => x.

	// This mapping was only used after paging was turned on but
	// before the segment registers were reloaded.
	pgdir[0] = 0;

	// Flush the TLB for good measure, to kill the pgdir[0] mapping.
	lcr3(boot_cr3);
}

//
// Check the physical page allocator (page_alloc(), page_free(),
// and page_init()).
//
static void
check_page_alloc()
{
	struct Page *pp, *pp0, *pp1, *pp2;
	struct Page_list fl;

	// if there's a page that shouldn't be on
	// the free list, try to make sure it
	// eventually causes trouble.
	LIST_FOREACH(pp0, &page_free_list, pp_link)
		memset(page2kva(pp0), 0x97, 128);

	LIST_FOREACH(pp0, &page_free_list, pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp0 >= pages);
		assert(pp0 < pages + npage);

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp0) != 0);
		assert(page2pa(pp0) != IOPHYSMEM);
		assert(page2pa(pp0) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp0) != EXTPHYSMEM);
		assert(page2kva(pp0) != ROUNDDOWN(boot_freemem - 1, PGSIZE));
	}

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert(page_alloc(&pp0) == 0);
	assert(page_alloc(&pp1) == 0);
	assert(page_alloc(&pp2) == 0);

	assert(pp0);
	assert(pp1 && pp1 != pp0);
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
	assert(page2pa(pp0) < npage*PGSIZE);
	assert(page2pa(pp1) < npage*PGSIZE);
	assert(page2pa(pp2) < npage*PGSIZE);

	// temporarily steal the rest of the free pages
	fl = page_free_list;
	LIST_INIT(&page_free_list);

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);

	// free and re-allocate?
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);
	pp0 = pp1 = pp2 = 0;
	assert(page_alloc(&pp0) == 0);
	assert(page_alloc(&pp1) == 0);
	assert(page_alloc(&pp2) == 0);
	assert(pp0);
	assert(pp1 && pp1 != pp0);
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
	assert(page_alloc(&pp) == -E_NO_MEM);

	// give free list back
	page_free_list = fl;

	// free the pages we took
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	cprintf("check_page_alloc() succeeded!\n");
}

//
// Checks that the kernel part of virtual address space
// has been setup roughly correctly(by i386_vm_init()).
//
// This function doesn't test every corner case,
// in fact it doesn't test the permission bits at all,
// but it is a pretty good sanity check. 
//
static physaddr_t check_va2pa(pde_t *pgdir, uintptr_t va);

static void
check_boot_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = boot_pgdir;

	// check pages array
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
	
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npage * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
		case PDX(VPT):
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i]);
			break;
		default:
			if (i >= PDX(KERNBASE))
				assert(pgdir[i]);
			else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_boot_pgdir() succeeded!\n");
}

// This function returns the physical address of the page containing 'va',
// defined by the page directory 'pgdir'.  The hardware normally performs
// this functionality for us!  We define our own version to help check
// the check_boot_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
		
// --------------------------------------------------------------
// Tracking of physical pages.
// The 'pages' array has one 'struct Page' entry per physical page.
// Pages are reference counted, and free pages are kept on a linked list.
// --------------------------------------------------------------

//
// Initialize page structure and memory free list.
// After this is done, NEVER use boot_alloc again.  ONLY use the page
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
	// The example code here marks all physical pages as free.
	// However this is not truly the case.  What memory is free?
	//  1) Mark physical page 0 as in use.
	//     This way we preserve the real-mode IDT and BIOS structures
	//     in case we ever need them.  (Currently we don't, but...)
	//  2) The rest of base memory, [PGSIZE, basemem) is free.
	//  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM).
	//     Mark it as in use so that it can never be allocated.
	//  4) Then extended memory [EXTPHYSMEM, ...).
	//     Some of it is in use, some is free. Where is the kernel
	//     in physical memory?  Which pages are already in use for
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&page_free_list);
	for (i = 0; i < npage; i++) {
		pages[i].pp_ref = 0;
		LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
	}
	pages[0].pp_ref=1;
	LIST_REMOVE(&pages[0],pp_link);
	for(i=PPN(IOPHYSMEM);i<=PPN(ROUNDUP(PADDR(boot_freemem),PGSIZE));i++){
							//这里要使用boot_freemem的物理地址,这个bug在做lab3时才发现
		pages[i].pp_ref=1;
		LIST_REMOVE(&pages[i],pp_link);
	}
}

//
// Initialize a Page structure.
// The result has null links and 0 refcount.
// Note that the corresponding physical page is NOT initialized!
//
static void
page_initpp(struct Page *pp)
{
	memset(pp, 0, sizeof(*pp));
}

//
// Allocates a physical page.
// Does NOT set the contents of the physical page to zero, NOR does it
// increment the reference count of the page - the caller must do
// these if necessary. 
//
// *pp_store -- is set to point to the Page struct of the newly allocated
// page
//
// RETURNS 
//   0 -- on success
//   -E_NO_MEM -- otherwise 
//
// Hint: use LIST_FIRST, LIST_REMOVE, and page_initpp
int
page_alloc(struct Page **pp_store)
{
	// Fill this function in
	if(!LIST_EMPTY(&page_free_list)){
		*pp_store=(struct Page*)LIST_FIRST(&page_free_list);
		LIST_REMOVE(*pp_store,pp_link);
		page_initpp(*pp_store);//需要初始化获得的空闲页面管理结构，真正对应物理页面的初始化在后面进行
		//jos的物理页面管理是通过页面数组pages进行，要知道某个页面onepage的物理地址，通过其管理结构
		//struct Page在pages的下标就可以知道了，struct Page中没有显示的用指针来指向其对应页面哦
		return 0;
	}
	else
		return -E_NO_MEM;
	return -E_NO_MEM;
}

//
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f0101078:	55                   	push   %ebp
f0101079:	89 e5                	mov    %esp,%ebp
f010107b:	8b 4d 08             	mov    0x8(%ebp),%ecx

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f010107e:	8b 15 7c 98 2a f0    	mov    0xf02a987c,%edx
	// Fill this function in
	if(pages[page2ppn(pp)].pp_ref==0){
f0101084:	89 c8                	mov    %ecx,%eax
f0101086:	29 d0                	sub    %edx,%eax
f0101088:	83 e0 fc             	and    $0xfffffffc,%eax
f010108b:	66 83 7c 10 08 00    	cmpw   $0x0,0x8(%eax,%edx,1)
f0101091:	75 20                	jne    f01010b3 <page_free+0x3b>
		LIST_INSERT_HEAD(&page_free_list,pp,pp_link);
f0101093:	a1 b8 88 2a f0       	mov    0xf02a88b8,%eax
f0101098:	89 01                	mov    %eax,(%ecx)
f010109a:	85 c0                	test   %eax,%eax
f010109c:	74 08                	je     f01010a6 <page_free+0x2e>
f010109e:	a1 b8 88 2a f0       	mov    0xf02a88b8,%eax
f01010a3:	89 48 04             	mov    %ecx,0x4(%eax)
f01010a6:	89 0d b8 88 2a f0    	mov    %ecx,0xf02a88b8
f01010ac:	c7 41 04 b8 88 2a f0 	movl   $0xf02a88b8,0x4(%ecx)
	}
}
f01010b3:	5d                   	pop    %ebp
f01010b4:	c3                   	ret    

f01010b5 <page_decref>:

//
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f01010b5:	55                   	push   %ebp
f01010b6:	89 e5                	mov    %esp,%ebp
f01010b8:	83 ec 04             	sub    $0x4,%esp
f01010bb:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01010be:	0f b7 42 08          	movzwl 0x8(%edx),%eax
f01010c2:	83 e8 01             	sub    $0x1,%eax
f01010c5:	66 89 42 08          	mov    %ax,0x8(%edx)
f01010c9:	66 85 c0             	test   %ax,%ax
f01010cc:	75 08                	jne    f01010d6 <page_decref+0x21>
		page_free(pp);
f01010ce:	89 14 24             	mov    %edx,(%esp)
f01010d1:	e8 a2 ff ff ff       	call   f0101078 <page_free>
}
f01010d6:	c9                   	leave  
f01010d7:	c3                   	ret    

f01010d8 <tlb_invalidate>:

// Given 'pgdir', a pointer to a page directory, pgdir_walk returns
// a pointer to the page table entry (PTE) for linear address 'va'.
// This requires walking the two-level page table structure.
//
// If the relevant page table doesn't exist in the page directory, then:
//    - If create == 0, pgdir_walk returns NULL.
//    - Otherwise, pgdir_walk tries to allocate a new page table
//	with page_alloc.  If this fails, pgdir_walk returns NULL.
//    - pgdir_walk sets pp_ref to 1 for the new page table.
//    - pgdir_walk clears the new page table.
//    - Finally, pgdir_walk returns a pointer into the new page table.
//
// Hint: you can turn a Page * into the physical address of the
// page it refers to with page2pa() from kern/pmap.h.
//
// Hint 2: the x86 MMU checks permission bits in both the page directory
// and the page table, so it's safe to leave permissions in the page
// more permissive than strictly necessary.
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	// Fill this function in
	pde_t *pde;
	pte_t *pgtab;
	pte_t *pp_store;
	struct Page *pgfortab;
	pde = &pgdir[PDX(va)];

	//看一下对应的页表是否存在
	if(*pde & PTE_P){
		pgtab = (pte_t*)KADDR(PTE_ADDR(*pde));//存在对应页表,访问页表需要用虚拟地址
	}else{//create==0或者分配页面失败,返回NULL
		if(!create)
			return NULL;
		if(page_alloc(&pgfortab)<0)
			return NULL;
		pgfortab->pp_ref=1;//设置引用标志为1,这个页作为了页表
		//cprintf("welcome to pgdir_walk:va=%x pgfortab=%x\n",va,KADDR(page2pa(pgfortab)));
		pgtab = (pte_t*)KADDR(page2pa(pgfortab));//获取页面物理地址,访问页表要用虚拟地址
		
		memset(pgtab,0,PGSIZE);
		*pde = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;//填写相应页目录项,需要填写相应物理地址
		//cprintf("pde=%x *pde=%x &pgtab[PTX(va)]=%x\n",&pgdir[PDX(va)],pgdir[PDX(va)],&pgtab[PTX(va)]);
	}
	pp_store=&pgtab[PTX(va)];
	return pp_store;
	//return NULL;
}

//
// Map the physical page 'pp' at virtual address 'va'.
// The permissions (the low 12 bits) of the page table
//  entry should be set to 'perm|PTE_P'.
//
// Requirements
//   - If there is already a page mapped at 'va', it should be page_remove()d.
//   - If necessary, on demand, a page table should be allocated and inserted
//     into 'pgdir'.
//   - pp->pp_ref should be incremented if the insertion succeeds.
//   - The TLB must be invalidated if a page was formerly present at 'va'.
//
// Corner-case hint: Make sure to consider what happens when the same 
// pp is re-inserted at the same virtual address in the same pgdir.
//
// RETURNS: 
//   0 on success
//   -E_NO_MEM, if page table couldn't be allocated
//
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm) 
{
	// Fill this function in
	pte_t *pte;
	if(!(pte=pgdir_walk(pgdir, va, 1)))//查找或创建虚拟地址va对应的页表项pte
		return -E_NO_MEM;
	else{
		if(*pte&PTE_P){//对应va的实际物理页面存在
			if(PTE_ADDR(*pte)!=page2pa(pp))//va指向了不同的物理页面
				page_remove(pgdir,va);
			else				//va指向了需要分配的物理页面
				pp->pp_ref--;
		}
		*pte = page2pa(pp) | perm | PTE_P;//填写页表项
		//cprintf("pte=%x *pte=%x\n",pte,*pte);
		pp->pp_ref++;//映射的实际物理页的引用情况
		tlb_invalidate(pgdir,va);//更新TLB
		return 0;
	}
	//return 0;
}

//
// Map [la, la+size) of linear address space to physical [pa, pa+size)
// in the page table rooted at pgdir.  Size is a multiple of PGSIZE.
// Use permission bits perm|PTE_P for the entries.
//
// This function is only intended to set up the ``static'' mappings
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	uintptr_t a,last;
	pte_t *pte;
	//cprintf("----------------------------\n");
	a=ROUNDDOWN(la,PGSIZE);
	last=ROUNDDOWN(la+size-1,PGSIZE);//这个地方要小心编写,防止重映射
	//cprintf("\nlast=%x\n",last);
	for(;;){
		pte = pgdir_walk(pgdir,(void *)a,1);
		if(pte==NULL)
			return;
		if(*pte&PTE_P)
			panic("remap");
		*pte=pa | perm | PTE_P;
		//if(a==0xf0400000)
		//	cprintf("a=%x *pte=%x\n",a,*pte);
		//if(a>=KERNBASE)
		//	cprintf("a=%x *pte=%x ********",a,*pte);
		if(a==last)
			break;
		a+=PGSIZE;
		pa+=PGSIZE;
	}
	return;
}

//
// Return the page mapped at virtual address 'va'.
// If pte_store is not zero, then we store in it the address
// of the pte for this page.  This is used by page_remove and
// can be used to verify page permissions for syscall arguments,
// but should not be used by most callers.
//
// Return NULL if there is no page mapped at va.
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	struct Page *pageforva;
	pte_t *pte;
	if(!(pte=pgdir_walk(pgdir,va,0)))
		return NULL;
	else{
		pageforva=pa2page(PTE_ADDR(*pte));

		if(pte_store)//这个地方传递pte容易错，小心编写
			*pte_store=pte;
	}
	return pageforva;
	//return NULL;
}

//
// Unmaps the physical page at virtual address 'va'.
// If there is no physical page at that address, silently does nothing.
//
// Details:
//   - The ref count on the physical page should decrement.
//   - The physical page should be freed if the refcount reaches 0.
//   - The pg table entry corresponding to 'va' should be set to 0.
//     (if such a PTE exists)
//   - The TLB must be invalidated if you remove an entry from
//     the pg dir/pg table.
//
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
	// Fill this function in
	struct Page *pageforva;
	pte_t *pte=NULL;
	if((pageforva=page_lookup(pgdir,va,&pte))){
		page_decref(pageforva);

		if(pte)
			*pte=0;
		tlb_invalidate(pgdir,va);
	}
}

//
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01010d8:	55                   	push   %ebp
f01010d9:	89 e5                	mov    %esp,%ebp
f01010db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01010de:	8b 15 c4 88 2a f0    	mov    0xf02a88c4,%edx
f01010e4:	85 d2                	test   %edx,%edx
f01010e6:	74 08                	je     f01010f0 <tlb_invalidate+0x18>
f01010e8:	8b 45 08             	mov    0x8(%ebp),%eax
f01010eb:	39 42 5c             	cmp    %eax,0x5c(%edx)
f01010ee:	75 03                	jne    f01010f3 <tlb_invalidate+0x1b>

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01010f0:	0f 01 39             	invlpg (%ecx)
		invlpg(va);
}
f01010f3:	5d                   	pop    %ebp
f01010f4:	c3                   	ret    

f01010f5 <page_init>:
f01010f5:	55                   	push   %ebp
f01010f6:	89 e5                	mov    %esp,%ebp
f01010f8:	56                   	push   %esi
f01010f9:	53                   	push   %ebx
f01010fa:	83 ec 10             	sub    $0x10,%esp
f01010fd:	c7 05 b8 88 2a f0 00 	movl   $0x0,0xf02a88b8
f0101104:	00 00 00 
f0101107:	83 3d 70 98 2a f0 00 	cmpl   $0x0,0xf02a9870
f010110e:	74 63                	je     f0101173 <page_init+0x7e>
f0101110:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101115:	b8 00 00 00 00       	mov    $0x0,%eax
f010111a:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010111d:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
f0101124:	a1 7c 98 2a f0       	mov    0xf02a987c,%eax
f0101129:	66 c7 44 01 08 00 00 	movw   $0x0,0x8(%ecx,%eax,1)
f0101130:	8b 15 b8 88 2a f0    	mov    0xf02a88b8,%edx
f0101136:	a1 7c 98 2a f0       	mov    0xf02a987c,%eax
f010113b:	89 14 01             	mov    %edx,(%ecx,%eax,1)
f010113e:	85 d2                	test   %edx,%edx
f0101140:	74 10                	je     f0101152 <page_init+0x5d>
f0101142:	89 ca                	mov    %ecx,%edx
f0101144:	03 15 7c 98 2a f0    	add    0xf02a987c,%edx
f010114a:	a1 b8 88 2a f0       	mov    0xf02a88b8,%eax
f010114f:	89 50 04             	mov    %edx,0x4(%eax)
f0101152:	89 c8                	mov    %ecx,%eax
f0101154:	03 05 7c 98 2a f0    	add    0xf02a987c,%eax
f010115a:	a3 b8 88 2a f0       	mov    %eax,0xf02a88b8
f010115f:	c7 40 04 b8 88 2a f0 	movl   $0xf02a88b8,0x4(%eax)
f0101166:	83 c3 01             	add    $0x1,%ebx
f0101169:	89 d8                	mov    %ebx,%eax
f010116b:	39 1d 70 98 2a f0    	cmp    %ebx,0xf02a9870
f0101171:	77 a7                	ja     f010111a <page_init+0x25>
f0101173:	a1 7c 98 2a f0       	mov    0xf02a987c,%eax
f0101178:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
f010117e:	a1 7c 98 2a f0       	mov    0xf02a987c,%eax
f0101183:	8b 10                	mov    (%eax),%edx
f0101185:	85 d2                	test   %edx,%edx
f0101187:	74 06                	je     f010118f <page_init+0x9a>
f0101189:	8b 40 04             	mov    0x4(%eax),%eax
f010118c:	89 42 04             	mov    %eax,0x4(%edx)
f010118f:	a1 7c 98 2a f0       	mov    0xf02a987c,%eax
f0101194:	8b 50 04             	mov    0x4(%eax),%edx
f0101197:	8b 00                	mov    (%eax),%eax
f0101199:	89 02                	mov    %eax,(%edx)
f010119b:	a1 b4 88 2a f0       	mov    0xf02a88b4,%eax
f01011a0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01011a5:	76 60                	jbe    f0101207 <page_init+0x112>
f01011a7:	05 ff 0f 00 10       	add    $0x10000fff,%eax
f01011ac:	89 c6                	mov    %eax,%esi
f01011ae:	c1 ee 0c             	shr    $0xc,%esi
f01011b1:	81 fe 9f 00 00 00    	cmp    $0x9f,%esi
f01011b7:	76 6e                	jbe    f0101227 <page_init+0x132>
f01011b9:	bb a0 00 00 00       	mov    $0xa0,%ebx
f01011be:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01011c3:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01011c6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01011cd:	a1 7c 98 2a f0       	mov    0xf02a987c,%eax
f01011d2:	66 c7 44 02 08 01 00 	movw   $0x1,0x8(%edx,%eax,1)
f01011d9:	89 d0                	mov    %edx,%eax
f01011db:	03 05 7c 98 2a f0    	add    0xf02a987c,%eax
f01011e1:	8b 08                	mov    (%eax),%ecx
f01011e3:	85 c9                	test   %ecx,%ecx
f01011e5:	74 06                	je     f01011ed <page_init+0xf8>
f01011e7:	8b 40 04             	mov    0x4(%eax),%eax
f01011ea:	89 41 04             	mov    %eax,0x4(%ecx)
f01011ed:	89 d0                	mov    %edx,%eax
f01011ef:	03 05 7c 98 2a f0    	add    0xf02a987c,%eax
f01011f5:	8b 50 04             	mov    0x4(%eax),%edx
f01011f8:	8b 00                	mov    (%eax),%eax
f01011fa:	89 02                	mov    %eax,(%edx)
f01011fc:	83 c3 01             	add    $0x1,%ebx
f01011ff:	89 d8                	mov    %ebx,%eax
f0101201:	39 f3                	cmp    %esi,%ebx
f0101203:	77 22                	ja     f0101227 <page_init+0x132>
f0101205:	eb bc                	jmp    f01011c3 <page_init+0xce>
f0101207:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010120b:	c7 44 24 08 4c b1 10 	movl   $0xf010b14c,0x8(%esp)
f0101212:	f0 
f0101213:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
f010121a:	00 
f010121b:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101222:	e8 5f ee ff ff       	call   f0100086 <_panic>
f0101227:	83 c4 10             	add    $0x10,%esp
f010122a:	5b                   	pop    %ebx
f010122b:	5e                   	pop    %esi
f010122c:	5d                   	pop    %ebp
f010122d:	c3                   	ret    

f010122e <check_va2pa>:
f010122e:	55                   	push   %ebp
f010122f:	89 e5                	mov    %esp,%ebp
f0101231:	83 ec 18             	sub    $0x18,%esp
f0101234:	89 d1                	mov    %edx,%ecx
f0101236:	c1 ea 16             	shr    $0x16,%edx
f0101239:	8b 04 90             	mov    (%eax,%edx,4),%eax
f010123c:	a8 01                	test   $0x1,%al
f010123e:	74 51                	je     f0101291 <check_va2pa+0x63>
f0101240:	89 c2                	mov    %eax,%edx
f0101242:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101248:	89 d0                	mov    %edx,%eax
f010124a:	c1 e8 0c             	shr    $0xc,%eax
f010124d:	3b 05 70 98 2a f0    	cmp    0xf02a9870,%eax
f0101253:	72 20                	jb     f0101275 <check_va2pa+0x47>
f0101255:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101259:	c7 44 24 08 c8 ad 10 	movl   $0xf010adc8,0x8(%esp)
f0101260:	f0 
f0101261:	c7 44 24 04 ba 01 00 	movl   $0x1ba,0x4(%esp)
f0101268:	00 
f0101269:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101270:	e8 11 ee ff ff       	call   f0100086 <_panic>
f0101275:	89 c8                	mov    %ecx,%eax
f0101277:	c1 e8 0c             	shr    $0xc,%eax
f010127a:	25 ff 03 00 00       	and    $0x3ff,%eax
f010127f:	8b 84 82 00 00 00 f0 	mov    0xf0000000(%edx,%eax,4),%eax
f0101286:	a8 01                	test   $0x1,%al
f0101288:	74 07                	je     f0101291 <check_va2pa+0x63>
f010128a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010128f:	eb 05                	jmp    f0101296 <check_va2pa+0x68>
f0101291:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101296:	c9                   	leave  
f0101297:	c3                   	ret    

f0101298 <page_alloc>:
f0101298:	55                   	push   %ebp
f0101299:	89 e5                	mov    %esp,%ebp
f010129b:	53                   	push   %ebx
f010129c:	83 ec 14             	sub    $0x14,%esp
f010129f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01012a2:	8b 15 b8 88 2a f0    	mov    0xf02a88b8,%edx
f01012a8:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01012ad:	85 d2                	test   %edx,%edx
f01012af:	74 36                	je     f01012e7 <page_alloc+0x4f>
f01012b1:	89 13                	mov    %edx,(%ebx)
f01012b3:	8b 0a                	mov    (%edx),%ecx
f01012b5:	85 c9                	test   %ecx,%ecx
f01012b7:	74 06                	je     f01012bf <page_alloc+0x27>
f01012b9:	8b 42 04             	mov    0x4(%edx),%eax
f01012bc:	89 41 04             	mov    %eax,0x4(%ecx)
f01012bf:	8b 03                	mov    (%ebx),%eax
f01012c1:	8b 50 04             	mov    0x4(%eax),%edx
f01012c4:	8b 00                	mov    (%eax),%eax
f01012c6:	89 02                	mov    %eax,(%edx)
f01012c8:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f01012cf:	00 
f01012d0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01012d7:	00 
f01012d8:	8b 03                	mov    (%ebx),%eax
f01012da:	89 04 24             	mov    %eax,(%esp)
f01012dd:	e8 cf 84 00 00       	call   f01097b1 <memset>
f01012e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01012e7:	83 c4 14             	add    $0x14,%esp
f01012ea:	5b                   	pop    %ebx
f01012eb:	5d                   	pop    %ebp
f01012ec:	c3                   	ret    

f01012ed <pgdir_walk>:
f01012ed:	55                   	push   %ebp
f01012ee:	89 e5                	mov    %esp,%ebp
f01012f0:	83 ec 38             	sub    $0x38,%esp
f01012f3:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
f01012f6:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
f01012f9:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
f01012fc:	8b 75 0c             	mov    0xc(%ebp),%esi
f01012ff:	89 f0                	mov    %esi,%eax
f0101301:	c1 e8 16             	shr    $0x16,%eax
f0101304:	c1 e0 02             	shl    $0x2,%eax
f0101307:	89 c7                	mov    %eax,%edi
f0101309:	03 7d 08             	add    0x8(%ebp),%edi
f010130c:	8b 07                	mov    (%edi),%eax
f010130e:	a8 01                	test   $0x1,%al
f0101310:	74 3f                	je     f0101351 <pgdir_walk+0x64>
f0101312:	89 c2                	mov    %eax,%edx
f0101314:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010131a:	89 d0                	mov    %edx,%eax
f010131c:	c1 e8 0c             	shr    $0xc,%eax
f010131f:	8d 9a 00 00 00 f0    	lea    0xf0000000(%edx),%ebx
f0101325:	3b 05 70 98 2a f0    	cmp    0xf02a9870,%eax
f010132b:	0f 82 dc 00 00 00    	jb     f010140d <pgdir_walk+0x120>
f0101331:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101335:	c7 44 24 08 c8 ad 10 	movl   $0xf010adc8,0x8(%esp)
f010133c:	f0 
f010133d:	c7 44 24 04 4c 02 00 	movl   $0x24c,0x4(%esp)
f0101344:	00 
f0101345:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f010134c:	e8 35 ed ff ff       	call   f0100086 <_panic>
f0101351:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101355:	0f 84 c0 00 00 00    	je     f010141b <pgdir_walk+0x12e>
f010135b:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f010135e:	89 04 24             	mov    %eax,(%esp)
f0101361:	e8 32 ff ff ff       	call   f0101298 <page_alloc>
f0101366:	85 c0                	test   %eax,%eax
f0101368:	0f 88 ad 00 00 00    	js     f010141b <pgdir_walk+0x12e>
f010136e:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0101371:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101377:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f010137a:	2b 05 7c 98 2a f0    	sub    0xf02a987c,%eax
f0101380:	c1 f8 02             	sar    $0x2,%eax
f0101383:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101389:	89 c2                	mov    %eax,%edx
f010138b:	c1 e2 0c             	shl    $0xc,%edx
f010138e:	89 d0                	mov    %edx,%eax
f0101390:	c1 e8 0c             	shr    $0xc,%eax
f0101393:	3b 05 70 98 2a f0    	cmp    0xf02a9870,%eax
f0101399:	72 20                	jb     f01013bb <pgdir_walk+0xce>
f010139b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010139f:	c7 44 24 08 c8 ad 10 	movl   $0xf010adc8,0x8(%esp)
f01013a6:	f0 
f01013a7:	c7 44 24 04 54 02 00 	movl   $0x254,0x4(%esp)
f01013ae:	00 
f01013af:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f01013b6:	e8 cb ec ff ff       	call   f0100086 <_panic>
f01013bb:	8d 9a 00 00 00 f0    	lea    0xf0000000(%edx),%ebx
f01013c1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01013c8:	00 
f01013c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01013d0:	00 
f01013d1:	89 1c 24             	mov    %ebx,(%esp)
f01013d4:	e8 d8 83 00 00       	call   f01097b1 <memset>
f01013d9:	89 d8                	mov    %ebx,%eax
f01013db:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01013e1:	77 20                	ja     f0101403 <pgdir_walk+0x116>
f01013e3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01013e7:	c7 44 24 08 4c b1 10 	movl   $0xf010b14c,0x8(%esp)
f01013ee:	f0 
f01013ef:	c7 44 24 04 57 02 00 	movl   $0x257,0x4(%esp)
f01013f6:	00 
f01013f7:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f01013fe:	e8 83 ec ff ff       	call   f0100086 <_panic>
f0101403:	05 00 00 00 10       	add    $0x10000000,%eax
f0101408:	83 c8 07             	or     $0x7,%eax
f010140b:	89 07                	mov    %eax,(%edi)
f010140d:	89 f0                	mov    %esi,%eax
f010140f:	c1 e8 0a             	shr    $0xa,%eax
f0101412:	25 fc 0f 00 00       	and    $0xffc,%eax
f0101417:	01 d8                	add    %ebx,%eax
f0101419:	eb 05                	jmp    f0101420 <pgdir_walk+0x133>
f010141b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101420:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
f0101423:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
f0101426:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
f0101429:	89 ec                	mov    %ebp,%esp
f010142b:	5d                   	pop    %ebp
f010142c:	c3                   	ret    

f010142d <page_lookup>:
f010142d:	55                   	push   %ebp
f010142e:	89 e5                	mov    %esp,%ebp
f0101430:	53                   	push   %ebx
f0101431:	83 ec 14             	sub    $0x14,%esp
f0101434:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0101437:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010143e:	00 
f010143f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101442:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101446:	8b 45 08             	mov    0x8(%ebp),%eax
f0101449:	89 04 24             	mov    %eax,(%esp)
f010144c:	e8 9c fe ff ff       	call   f01012ed <pgdir_walk>
f0101451:	89 c2                	mov    %eax,%edx
f0101453:	b8 00 00 00 00       	mov    $0x0,%eax
f0101458:	85 d2                	test   %edx,%edx
f010145a:	74 40                	je     f010149c <page_lookup+0x6f>

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f010145c:	8b 02                	mov    (%edx),%eax
f010145e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101463:	c1 e8 0c             	shr    $0xc,%eax
f0101466:	3b 05 70 98 2a f0    	cmp    0xf02a9870,%eax
f010146c:	72 1c                	jb     f010148a <page_lookup+0x5d>
		panic("pa2page called with invalid pa");
f010146e:	c7 44 24 08 70 b1 10 	movl   $0xf010b170,0x8(%esp)
f0101475:	f0 
f0101476:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f010147d:	00 
f010147e:	c7 04 24 4f b7 10 f0 	movl   $0xf010b74f,(%esp)
f0101485:	e8 fc eb ff ff       	call   f0100086 <_panic>
	return &pages[PPN(pa)];
f010148a:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010148d:	c1 e0 02             	shl    $0x2,%eax
f0101490:	03 05 7c 98 2a f0    	add    0xf02a987c,%eax
f0101496:	85 db                	test   %ebx,%ebx
f0101498:	74 02                	je     f010149c <page_lookup+0x6f>
f010149a:	89 13                	mov    %edx,(%ebx)
f010149c:	83 c4 14             	add    $0x14,%esp
f010149f:	5b                   	pop    %ebx
f01014a0:	5d                   	pop    %ebp
f01014a1:	c3                   	ret    

f01014a2 <user_mem_check>:

static uintptr_t user_mem_check_addr;

//
// Check that an environment is allowed to access the range of memory
// [va, va+len) with permissions 'perm | PTE_P'.
// Normally 'perm' will contain PTE_U at least, but this is not required.
// 'va' and 'len' need not be page-aligned; you must test every page that
// contains any of that range.  You will test either 'len/PGSIZE',
// 'len/PGSIZE + 1', or 'len/PGSIZE + 2' pages.
//
// A user program can access a virtual address if (1) the address is below
// ULIM, and (2) the page table gives it permission.  These are exactly
// the tests you should implement here.
//
// If there is an error, set the 'user_mem_check_addr' variable to the first
// erroneous virtual address.
//
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01014a2:	55                   	push   %ebp
f01014a3:	89 e5                	mov    %esp,%ebp
f01014a5:	57                   	push   %edi
f01014a6:	56                   	push   %esi
f01014a7:	53                   	push   %ebx
f01014a8:	83 ec 1c             	sub    $0x1c,%esp
f01014ab:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014ae:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 3: Your code here.
	uintptr_t a,last;
	pte_t *pte;
	struct Page *onepage;
	a=(uintptr_t)va;
	user_mem_check_addr=a;
f01014b1:	a3 bc 88 2a f0       	mov    %eax,0xf02a88bc
	a=ROUNDDOWN(a,PGSIZE);
f01014b6:	89 c3                	mov    %eax,%ebx
f01014b8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	last=ROUNDDOWN(a+len,PGSIZE);
f01014be:	89 d8                	mov    %ebx,%eax
f01014c0:	03 45 10             	add    0x10(%ebp),%eax
f01014c3:	89 c6                	mov    %eax,%esi
f01014c5:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for(;;){
		if(a>=ULIM) {
f01014cb:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01014d1:	76 27                	jbe    f01014fa <user_mem_check+0x58>
f01014d3:	e9 9b 00 00 00       	jmp    f0101573 <user_mem_check+0xd1>
			if((user_mem_check_addr&0xfffff000)!=a)
f01014d8:	a1 bc 88 2a f0       	mov    0xf02a88bc,%eax
f01014dd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01014e2:	39 d8                	cmp    %ebx,%eax
f01014e4:	0f 84 89 00 00 00    	je     f0101573 <user_mem_check+0xd1>
				user_mem_check_addr=a;
f01014ea:	89 1d bc 88 2a f0    	mov    %ebx,0xf02a88bc
f01014f0:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01014f5:	e9 7e 00 00 00       	jmp    f0101578 <user_mem_check+0xd6>
			return -E_FAULT;
		}
		else{
			if(!(onepage=page_lookup(env->env_pgdir,(void *)a,&pte)))
f01014fa:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f01014fd:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101501:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101505:	8b 55 08             	mov    0x8(%ebp),%edx
f0101508:	8b 42 5c             	mov    0x5c(%edx),%eax
f010150b:	89 04 24             	mov    %eax,(%esp)
f010150e:	e8 1a ff ff ff       	call   f010142d <page_lookup>
f0101513:	85 c0                	test   %eax,%eax
f0101515:	75 1b                	jne    f0101532 <user_mem_check+0x90>
			{	
				if((user_mem_check_addr&0xfffff000)!=a)
f0101517:	a1 bc 88 2a f0       	mov    0xf02a88bc,%eax
f010151c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101521:	39 d8                	cmp    %ebx,%eax
f0101523:	74 4e                	je     f0101573 <user_mem_check+0xd1>
                                	user_mem_check_addr=a;
f0101525:	89 1d bc 88 2a f0    	mov    %ebx,0xf02a88bc
f010152b:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0101530:	eb 46                	jmp    f0101578 <user_mem_check+0xd6>
				return -E_FAULT;
			}
			if(!(*pte&perm))
f0101532:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0101535:	85 38                	test   %edi,(%eax)
f0101537:	75 1b                	jne    f0101554 <user_mem_check+0xb2>
			{
				if((user_mem_check_addr&0xfffff000)!=a)
f0101539:	a1 bc 88 2a f0       	mov    0xf02a88bc,%eax
f010153e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101543:	39 d8                	cmp    %ebx,%eax
f0101545:	74 2c                	je     f0101573 <user_mem_check+0xd1>
                                	user_mem_check_addr=a;
f0101547:	89 1d bc 88 2a f0    	mov    %ebx,0xf02a88bc
f010154d:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0101552:	eb 24                	jmp    f0101578 <user_mem_check+0xd6>
				return -E_FAULT;
			}
			
			
		}
		if(a==last) 
f0101554:	39 f3                	cmp    %esi,%ebx
f0101556:	74 14                	je     f010156c <user_mem_check+0xca>
			break;	
		a+=PGSIZE;
f0101558:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010155e:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101564:	0f 87 6e ff ff ff    	ja     f01014d8 <user_mem_check+0x36>
f010156a:	eb 8e                	jmp    f01014fa <user_mem_check+0x58>
f010156c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101571:	eb 05                	jmp    f0101578 <user_mem_check+0xd6>
f0101573:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
	}		
	return 0; 
}
f0101578:	83 c4 1c             	add    $0x1c,%esp
f010157b:	5b                   	pop    %ebx
f010157c:	5e                   	pop    %esi
f010157d:	5f                   	pop    %edi
f010157e:	5d                   	pop    %ebp
f010157f:	90                   	nop    
f0101580:	c3                   	ret    

f0101581 <user_mem_assert>:

//
// Checks that environment 'env' is allowed to access the range
// of memory [va, va+len) with permissions 'perm | PTE_U'.
// If it can, then the function simply returns.
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0101581:	55                   	push   %ebp
f0101582:	89 e5                	mov    %esp,%ebp
f0101584:	53                   	push   %ebx
f0101585:	83 ec 14             	sub    $0x14,%esp
f0101588:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f010158b:	8b 45 14             	mov    0x14(%ebp),%eax
f010158e:	83 c8 04             	or     $0x4,%eax
f0101591:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101595:	8b 45 10             	mov    0x10(%ebp),%eax
f0101598:	89 44 24 08          	mov    %eax,0x8(%esp)
f010159c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010159f:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015a3:	89 1c 24             	mov    %ebx,(%esp)
f01015a6:	e8 f7 fe ff ff       	call   f01014a2 <user_mem_check>
f01015ab:	85 c0                	test   %eax,%eax
f01015ad:	79 24                	jns    f01015d3 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f01015af:	a1 bc 88 2a f0       	mov    0xf02a88bc,%eax
f01015b4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01015b8:	8b 43 4c             	mov    0x4c(%ebx),%eax
f01015bb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015bf:	c7 04 24 90 b1 10 f0 	movl   $0xf010b190,(%esp)
f01015c6:	e8 6c 24 00 00       	call   f0103a37 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01015cb:	89 1c 24             	mov    %ebx,(%esp)
f01015ce:	e8 81 22 00 00       	call   f0103854 <env_destroy>
	}
}
f01015d3:	83 c4 14             	add    $0x14,%esp
f01015d6:	5b                   	pop    %ebx
f01015d7:	5d                   	pop    %ebp
f01015d8:	c3                   	ret    

f01015d9 <page_remove>:
f01015d9:	55                   	push   %ebp
f01015da:	89 e5                	mov    %esp,%ebp
f01015dc:	83 ec 28             	sub    $0x28,%esp
f01015df:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
f01015e2:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
f01015e5:	8b 75 08             	mov    0x8(%ebp),%esi
f01015e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01015eb:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
f01015f2:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
f01015f5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01015f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01015fd:	89 34 24             	mov    %esi,(%esp)
f0101600:	e8 28 fe ff ff       	call   f010142d <page_lookup>
f0101605:	85 c0                	test   %eax,%eax
f0101607:	74 21                	je     f010162a <page_remove+0x51>
f0101609:	89 04 24             	mov    %eax,(%esp)
f010160c:	e8 a4 fa ff ff       	call   f01010b5 <page_decref>
f0101611:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0101614:	85 c0                	test   %eax,%eax
f0101616:	74 06                	je     f010161e <page_remove+0x45>
f0101618:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f010161e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101622:	89 34 24             	mov    %esi,(%esp)
f0101625:	e8 ae fa ff ff       	call   f01010d8 <tlb_invalidate>
f010162a:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
f010162d:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
f0101630:	89 ec                	mov    %ebp,%esp
f0101632:	5d                   	pop    %ebp
f0101633:	c3                   	ret    

f0101634 <boot_map_segment>:
f0101634:	55                   	push   %ebp
f0101635:	89 e5                	mov    %esp,%ebp
f0101637:	57                   	push   %edi
f0101638:	56                   	push   %esi
f0101639:	53                   	push   %ebx
f010163a:	83 ec 1c             	sub    $0x1c,%esp
f010163d:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
f0101640:	8b 75 08             	mov    0x8(%ebp),%esi
f0101643:	89 d3                	mov    %edx,%ebx
f0101645:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010164b:	8d 54 0a ff          	lea    0xffffffff(%edx,%ecx,1),%edx
f010164f:	89 d7                	mov    %edx,%edi
f0101651:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0101657:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010165e:	00 
f010165f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101663:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0101666:	89 04 24             	mov    %eax,(%esp)
f0101669:	e8 7f fc ff ff       	call   f01012ed <pgdir_walk>
f010166e:	89 c2                	mov    %eax,%edx
f0101670:	85 c0                	test   %eax,%eax
f0101672:	74 3d                	je     f01016b1 <boot_map_segment+0x7d>
f0101674:	f6 00 01             	testb  $0x1,(%eax)
f0101677:	74 1c                	je     f0101695 <boot_map_segment+0x61>
f0101679:	c7 44 24 08 5d b7 10 	movl   $0xf010b75d,0x8(%esp)
f0101680:	f0 
f0101681:	c7 44 24 04 a5 02 00 	movl   $0x2a5,0x4(%esp)
f0101688:	00 
f0101689:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101690:	e8 f1 e9 ff ff       	call   f0100086 <_panic>
f0101695:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101698:	83 c8 01             	or     $0x1,%eax
f010169b:	09 f0                	or     %esi,%eax
f010169d:	89 02                	mov    %eax,(%edx)
f010169f:	39 fb                	cmp    %edi,%ebx
f01016a1:	74 0e                	je     f01016b1 <boot_map_segment+0x7d>
f01016a3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01016a9:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01016af:	eb a6                	jmp    f0101657 <boot_map_segment+0x23>
f01016b1:	83 c4 1c             	add    $0x1c,%esp
f01016b4:	5b                   	pop    %ebx
f01016b5:	5e                   	pop    %esi
f01016b6:	5f                   	pop    %edi
f01016b7:	5d                   	pop    %ebp
f01016b8:	c3                   	ret    

f01016b9 <page_insert>:
f01016b9:	55                   	push   %ebp
f01016ba:	89 e5                	mov    %esp,%ebp
f01016bc:	83 ec 18             	sub    $0x18,%esp
f01016bf:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
f01016c2:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
f01016c5:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
f01016c8:	8b 75 0c             	mov    0xc(%ebp),%esi
f01016cb:	8b 7d 10             	mov    0x10(%ebp),%edi
f01016ce:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01016d5:	00 
f01016d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01016da:	8b 45 08             	mov    0x8(%ebp),%eax
f01016dd:	89 04 24             	mov    %eax,(%esp)
f01016e0:	e8 08 fc ff ff       	call   f01012ed <pgdir_walk>
f01016e5:	89 c3                	mov    %eax,%ebx
f01016e7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01016ec:	85 db                	test   %ebx,%ebx
f01016ee:	74 73                	je     f0101763 <page_insert+0xaa>
f01016f0:	8b 03                	mov    (%ebx),%eax
f01016f2:	a8 01                	test   $0x1,%al
f01016f4:	74 36                	je     f010172c <page_insert+0x73>
f01016f6:	89 c2                	mov    %eax,%edx
f01016f8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01016fe:	89 f0                	mov    %esi,%eax
f0101700:	2b 05 7c 98 2a f0    	sub    0xf02a987c,%eax
f0101706:	c1 f8 02             	sar    $0x2,%eax
f0101709:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010170f:	c1 e0 0c             	shl    $0xc,%eax
f0101712:	39 c2                	cmp    %eax,%edx
f0101714:	74 11                	je     f0101727 <page_insert+0x6e>
f0101716:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010171a:	8b 45 08             	mov    0x8(%ebp),%eax
f010171d:	89 04 24             	mov    %eax,(%esp)
f0101720:	e8 b4 fe ff ff       	call   f01015d9 <page_remove>
f0101725:	eb 05                	jmp    f010172c <page_insert+0x73>
f0101727:	66 83 6e 08 01       	subw   $0x1,0x8(%esi)
f010172c:	8b 55 14             	mov    0x14(%ebp),%edx
f010172f:	83 ca 01             	or     $0x1,%edx
f0101732:	89 f0                	mov    %esi,%eax
f0101734:	2b 05 7c 98 2a f0    	sub    0xf02a987c,%eax
f010173a:	c1 f8 02             	sar    $0x2,%eax
f010173d:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101743:	c1 e0 0c             	shl    $0xc,%eax
f0101746:	09 c2                	or     %eax,%edx
f0101748:	89 13                	mov    %edx,(%ebx)
f010174a:	66 83 46 08 01       	addw   $0x1,0x8(%esi)
f010174f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101753:	8b 45 08             	mov    0x8(%ebp),%eax
f0101756:	89 04 24             	mov    %eax,(%esp)
f0101759:	e8 7a f9 ff ff       	call   f01010d8 <tlb_invalidate>
f010175e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101763:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
f0101766:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
f0101769:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
f010176c:	89 ec                	mov    %ebp,%esp
f010176e:	5d                   	pop    %ebp
f010176f:	c3                   	ret    

f0101770 <nvram_read>:
f0101770:	55                   	push   %ebp
f0101771:	89 e5                	mov    %esp,%ebp
f0101773:	83 ec 18             	sub    $0x18,%esp
f0101776:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
f0101779:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
f010177c:	89 c6                	mov    %eax,%esi
f010177e:	89 04 24             	mov    %eax,(%esp)
f0101781:	e8 fe 20 00 00       	call   f0103884 <mc146818_read>
f0101786:	89 c3                	mov    %eax,%ebx
f0101788:	8d 46 01             	lea    0x1(%esi),%eax
f010178b:	89 04 24             	mov    %eax,(%esp)
f010178e:	e8 f1 20 00 00       	call   f0103884 <mc146818_read>
f0101793:	c1 e0 08             	shl    $0x8,%eax
f0101796:	09 d8                	or     %ebx,%eax
f0101798:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
f010179b:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
f010179e:	89 ec                	mov    %ebp,%esp
f01017a0:	5d                   	pop    %ebp
f01017a1:	c3                   	ret    

f01017a2 <i386_detect_memory>:
f01017a2:	55                   	push   %ebp
f01017a3:	89 e5                	mov    %esp,%ebp
f01017a5:	83 ec 18             	sub    $0x18,%esp
f01017a8:	b8 15 00 00 00       	mov    $0x15,%eax
f01017ad:	e8 be ff ff ff       	call   f0101770 <nvram_read>
f01017b2:	c1 e0 0a             	shl    $0xa,%eax
f01017b5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01017ba:	a3 ac 88 2a f0       	mov    %eax,0xf02a88ac
f01017bf:	b8 17 00 00 00       	mov    $0x17,%eax
f01017c4:	e8 a7 ff ff ff       	call   f0101770 <nvram_read>
f01017c9:	c1 e0 0a             	shl    $0xa,%eax
f01017cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01017d1:	a3 b0 88 2a f0       	mov    %eax,0xf02a88b0
f01017d6:	85 c0                	test   %eax,%eax
f01017d8:	74 0c                	je     f01017e6 <i386_detect_memory+0x44>
f01017da:	05 00 00 10 00       	add    $0x100000,%eax
f01017df:	a3 a8 88 2a f0       	mov    %eax,0xf02a88a8
f01017e4:	eb 0a                	jmp    f01017f0 <i386_detect_memory+0x4e>
f01017e6:	a1 ac 88 2a f0       	mov    0xf02a88ac,%eax
f01017eb:	a3 a8 88 2a f0       	mov    %eax,0xf02a88a8
f01017f0:	a1 a8 88 2a f0       	mov    0xf02a88a8,%eax
f01017f5:	89 c2                	mov    %eax,%edx
f01017f7:	c1 ea 0c             	shr    $0xc,%edx
f01017fa:	89 15 70 98 2a f0    	mov    %edx,0xf02a9870
f0101800:	c1 e8 0a             	shr    $0xa,%eax
f0101803:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101807:	c7 04 24 c8 b1 10 f0 	movl   $0xf010b1c8,(%esp)
f010180e:	e8 24 22 00 00       	call   f0103a37 <cprintf>
f0101813:	a1 b0 88 2a f0       	mov    0xf02a88b0,%eax
f0101818:	c1 e8 0a             	shr    $0xa,%eax
f010181b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010181f:	a1 ac 88 2a f0       	mov    0xf02a88ac,%eax
f0101824:	c1 e8 0a             	shr    $0xa,%eax
f0101827:	89 44 24 04          	mov    %eax,0x4(%esp)
f010182b:	c7 04 24 63 b7 10 f0 	movl   $0xf010b763,(%esp)
f0101832:	e8 00 22 00 00       	call   f0103a37 <cprintf>
f0101837:	c9                   	leave  
f0101838:	c3                   	ret    

f0101839 <check_page_alloc>:
f0101839:	55                   	push   %ebp
f010183a:	89 e5                	mov    %esp,%ebp
f010183c:	57                   	push   %edi
f010183d:	56                   	push   %esi
f010183e:	53                   	push   %ebx
f010183f:	83 ec 2c             	sub    $0x2c,%esp
f0101842:	a1 b8 88 2a f0       	mov    0xf02a88b8,%eax
f0101847:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
f010184a:	85 c0                	test   %eax,%eax
f010184c:	0f 84 41 02 00 00    	je     f0101a93 <check_page_alloc+0x25a>

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101852:	2b 05 7c 98 2a f0    	sub    0xf02a987c,%eax
f0101858:	c1 f8 02             	sar    $0x2,%eax
f010185b:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101861:	89 c2                	mov    %eax,%edx
f0101863:	c1 e2 0c             	shl    $0xc,%edx
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
		panic("pa2page called with invalid pa");
	return &pages[PPN(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0101866:	89 d0                	mov    %edx,%eax
f0101868:	c1 e8 0c             	shr    $0xc,%eax
f010186b:	39 05 70 98 2a f0    	cmp    %eax,0xf02a9870
f0101871:	77 43                	ja     f01018b6 <check_page_alloc+0x7d>
f0101873:	eb 21                	jmp    f0101896 <check_page_alloc+0x5d>
f0101875:	2b 05 7c 98 2a f0    	sub    0xf02a987c,%eax
f010187b:	c1 f8 02             	sar    $0x2,%eax
f010187e:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101884:	89 c2                	mov    %eax,%edx
f0101886:	c1 e2 0c             	shl    $0xc,%edx
f0101889:	89 d0                	mov    %edx,%eax
f010188b:	c1 e8 0c             	shr    $0xc,%eax
f010188e:	3b 05 70 98 2a f0    	cmp    0xf02a9870,%eax
f0101894:	72 20                	jb     f01018b6 <check_page_alloc+0x7d>
f0101896:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010189a:	c7 44 24 08 c8 ad 10 	movl   $0xf010adc8,0x8(%esp)
f01018a1:	f0 
f01018a2:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f01018a9:	00 
f01018aa:	c7 04 24 4f b7 10 f0 	movl   $0xf010b74f,(%esp)
f01018b1:	e8 d0 e7 ff ff       	call   f0100086 <_panic>
f01018b6:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f01018bd:	00 
f01018be:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f01018c5:	00 

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f01018c6:	8d 82 00 00 00 f0    	lea    0xf0000000(%edx),%eax
f01018cc:	89 04 24             	mov    %eax,(%esp)
f01018cf:	e8 dd 7e 00 00       	call   f01097b1 <memset>
f01018d4:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f01018d7:	8b 00                	mov    (%eax),%eax
f01018d9:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
f01018dc:	85 c0                	test   %eax,%eax
f01018de:	75 95                	jne    f0101875 <check_page_alloc+0x3c>
f01018e0:	8b 0d b8 88 2a f0    	mov    0xf02a88b8,%ecx
f01018e6:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
f01018e9:	85 c9                	test   %ecx,%ecx
f01018eb:	0f 84 a2 01 00 00    	je     f0101a93 <check_page_alloc+0x25a>
f01018f1:	8b 1d 7c 98 2a f0    	mov    0xf02a987c,%ebx
f01018f7:	39 d9                	cmp    %ebx,%ecx
f01018f9:	72 19                	jb     f0101914 <check_page_alloc+0xdb>
f01018fb:	8b 35 70 98 2a f0    	mov    0xf02a9870,%esi
f0101901:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0101904:	8d 04 83             	lea    (%ebx,%eax,4),%eax
f0101907:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
f010190a:	39 c1                	cmp    %eax,%ecx
f010190c:	72 53                	jb     f0101961 <check_page_alloc+0x128>
f010190e:	eb 2d                	jmp    f010193d <check_page_alloc+0x104>
f0101910:	39 cb                	cmp    %ecx,%ebx
f0101912:	76 24                	jbe    f0101938 <check_page_alloc+0xff>
f0101914:	c7 44 24 0c 7f b7 10 	movl   $0xf010b77f,0xc(%esp)
f010191b:	f0 
f010191c:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0101923:	f0 
f0101924:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
f010192b:	00 
f010192c:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101933:	e8 4e e7 ff ff       	call   f0100086 <_panic>
f0101938:	39 4d e0             	cmp    %ecx,0xffffffe0(%ebp)
f010193b:	77 34                	ja     f0101971 <check_page_alloc+0x138>
f010193d:	c7 44 24 0c a1 b7 10 	movl   $0xf010b7a1,0xc(%esp)
f0101944:	f0 
f0101945:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f010194c:	f0 
f010194d:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
f0101954:	00 
f0101955:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f010195c:	e8 25 e7 ff ff       	call   f0100086 <_panic>
f0101961:	a1 b4 88 2a f0       	mov    0xf02a88b4,%eax
f0101966:	83 e8 01             	sub    $0x1,%eax
f0101969:	89 c7                	mov    %eax,%edi
f010196b:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101971:	89 c8                	mov    %ecx,%eax
f0101973:	29 d8                	sub    %ebx,%eax
f0101975:	c1 f8 02             	sar    $0x2,%eax
f0101978:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010197e:	89 c2                	mov    %eax,%edx
f0101980:	c1 e2 0c             	shl    $0xc,%edx
f0101983:	85 d2                	test   %edx,%edx
f0101985:	75 24                	jne    f01019ab <check_page_alloc+0x172>
f0101987:	c7 44 24 0c b5 b7 10 	movl   $0xf010b7b5,0xc(%esp)
f010198e:	f0 
f010198f:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0101996:	f0 
f0101997:	c7 44 24 04 40 01 00 	movl   $0x140,0x4(%esp)
f010199e:	00 
f010199f:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f01019a6:	e8 db e6 ff ff       	call   f0100086 <_panic>
f01019ab:	81 fa 00 00 0a 00    	cmp    $0xa0000,%edx
f01019b1:	75 24                	jne    f01019d7 <check_page_alloc+0x19e>
f01019b3:	c7 44 24 0c c7 b7 10 	movl   $0xf010b7c7,0xc(%esp)
f01019ba:	f0 
f01019bb:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f01019c2:	f0 
f01019c3:	c7 44 24 04 41 01 00 	movl   $0x141,0x4(%esp)
f01019ca:	00 
f01019cb:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f01019d2:	e8 af e6 ff ff       	call   f0100086 <_panic>
f01019d7:	81 fa 00 f0 0f 00    	cmp    $0xff000,%edx
f01019dd:	75 24                	jne    f0101a03 <check_page_alloc+0x1ca>
f01019df:	c7 44 24 0c ec b1 10 	movl   $0xf010b1ec,0xc(%esp)
f01019e6:	f0 
f01019e7:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f01019ee:	f0 
f01019ef:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
f01019f6:	00 
f01019f7:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f01019fe:	e8 83 e6 ff ff       	call   f0100086 <_panic>
f0101a03:	81 fa 00 00 10 00    	cmp    $0x100000,%edx
f0101a09:	75 24                	jne    f0101a2f <check_page_alloc+0x1f6>
f0101a0b:	c7 44 24 0c e1 b7 10 	movl   $0xf010b7e1,0xc(%esp)
f0101a12:	f0 
f0101a13:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0101a1a:	f0 
f0101a1b:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
f0101a22:	00 
f0101a23:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101a2a:	e8 57 e6 ff ff       	call   f0100086 <_panic>

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0101a2f:	89 d0                	mov    %edx,%eax
f0101a31:	c1 e8 0c             	shr    $0xc,%eax
f0101a34:	39 c6                	cmp    %eax,%esi
f0101a36:	77 20                	ja     f0101a58 <check_page_alloc+0x21f>
f0101a38:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101a3c:	c7 44 24 08 c8 ad 10 	movl   $0xf010adc8,0x8(%esp)
f0101a43:	f0 
f0101a44:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0101a4b:	00 
f0101a4c:	c7 04 24 4f b7 10 f0 	movl   $0xf010b74f,(%esp)
f0101a53:	e8 2e e6 ff ff       	call   f0100086 <_panic>
f0101a58:	8d 82 00 00 00 f0    	lea    0xf0000000(%edx),%eax
f0101a5e:	39 f8                	cmp    %edi,%eax
f0101a60:	75 24                	jne    f0101a86 <check_page_alloc+0x24d>
f0101a62:	c7 44 24 0c 10 b2 10 	movl   $0xf010b210,0xc(%esp)
f0101a69:	f0 
f0101a6a:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0101a71:	f0 
f0101a72:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
f0101a79:	00 
f0101a7a:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101a81:	e8 00 e6 ff ff       	call   f0100086 <_panic>
f0101a86:	8b 09                	mov    (%ecx),%ecx
f0101a88:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
f0101a8b:	85 c9                	test   %ecx,%ecx
f0101a8d:	0f 85 7d fe ff ff    	jne    f0101910 <check_page_alloc+0xd7>
f0101a93:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
f0101a9a:	c7 45 e8 00 00 00 00 	movl   $0x0,0xffffffe8(%ebp)
f0101aa1:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
f0101aa8:	8d 45 ec             	lea    0xffffffec(%ebp),%eax
f0101aab:	89 04 24             	mov    %eax,(%esp)
f0101aae:	e8 e5 f7 ff ff       	call   f0101298 <page_alloc>
f0101ab3:	85 c0                	test   %eax,%eax
f0101ab5:	74 24                	je     f0101adb <check_page_alloc+0x2a2>
f0101ab7:	c7 44 24 0c fc b7 10 	movl   $0xf010b7fc,0xc(%esp)
f0101abe:	f0 
f0101abf:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0101ac6:	f0 
f0101ac7:	c7 44 24 04 49 01 00 	movl   $0x149,0x4(%esp)
f0101ace:	00 
f0101acf:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101ad6:	e8 ab e5 ff ff       	call   f0100086 <_panic>
f0101adb:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f0101ade:	89 04 24             	mov    %eax,(%esp)
f0101ae1:	e8 b2 f7 ff ff       	call   f0101298 <page_alloc>
f0101ae6:	85 c0                	test   %eax,%eax
f0101ae8:	74 24                	je     f0101b0e <check_page_alloc+0x2d5>
f0101aea:	c7 44 24 0c 12 b8 10 	movl   $0xf010b812,0xc(%esp)
f0101af1:	f0 
f0101af2:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0101af9:	f0 
f0101afa:	c7 44 24 04 4a 01 00 	movl   $0x14a,0x4(%esp)
f0101b01:	00 
f0101b02:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101b09:	e8 78 e5 ff ff       	call   f0100086 <_panic>
f0101b0e:	8d 45 e4             	lea    0xffffffe4(%ebp),%eax
f0101b11:	89 04 24             	mov    %eax,(%esp)
f0101b14:	e8 7f f7 ff ff       	call   f0101298 <page_alloc>
f0101b19:	85 c0                	test   %eax,%eax
f0101b1b:	74 24                	je     f0101b41 <check_page_alloc+0x308>
f0101b1d:	c7 44 24 0c 28 b8 10 	movl   $0xf010b828,0xc(%esp)
f0101b24:	f0 
f0101b25:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0101b2c:	f0 
f0101b2d:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
f0101b34:	00 
f0101b35:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101b3c:	e8 45 e5 ff ff       	call   f0100086 <_panic>
f0101b41:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
f0101b44:	85 d2                	test   %edx,%edx
f0101b46:	75 24                	jne    f0101b6c <check_page_alloc+0x333>
f0101b48:	c7 44 24 0c 4c b8 10 	movl   $0xf010b84c,0xc(%esp)
f0101b4f:	f0 
f0101b50:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0101b57:	f0 
f0101b58:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
f0101b5f:	00 
f0101b60:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101b67:	e8 1a e5 ff ff       	call   f0100086 <_panic>
f0101b6c:	8b 4d e8             	mov    0xffffffe8(%ebp),%ecx
f0101b6f:	85 c9                	test   %ecx,%ecx
f0101b71:	74 04                	je     f0101b77 <check_page_alloc+0x33e>
f0101b73:	39 ca                	cmp    %ecx,%edx
f0101b75:	75 24                	jne    f0101b9b <check_page_alloc+0x362>
f0101b77:	c7 44 24 0c 3e b8 10 	movl   $0xf010b83e,0xc(%esp)
f0101b7e:	f0 
f0101b7f:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0101b86:	f0 
f0101b87:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
f0101b8e:	00 
f0101b8f:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101b96:	e8 eb e4 ff ff       	call   f0100086 <_panic>
f0101b9b:	8b 5d e4             	mov    0xffffffe4(%ebp),%ebx
f0101b9e:	85 db                	test   %ebx,%ebx
f0101ba0:	74 08                	je     f0101baa <check_page_alloc+0x371>
f0101ba2:	39 d9                	cmp    %ebx,%ecx
f0101ba4:	74 04                	je     f0101baa <check_page_alloc+0x371>
f0101ba6:	39 da                	cmp    %ebx,%edx
f0101ba8:	75 24                	jne    f0101bce <check_page_alloc+0x395>
f0101baa:	c7 44 24 0c 48 b2 10 	movl   $0xf010b248,0xc(%esp)
f0101bb1:	f0 
f0101bb2:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0101bb9:	f0 
f0101bba:	c7 44 24 04 4f 01 00 	movl   $0x14f,0x4(%esp)
f0101bc1:	00 
f0101bc2:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101bc9:	e8 b8 e4 ff ff       	call   f0100086 <_panic>

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101bce:	8b 35 7c 98 2a f0    	mov    0xf02a987c,%esi
f0101bd4:	a1 70 98 2a f0       	mov    0xf02a9870,%eax
f0101bd9:	89 c7                	mov    %eax,%edi
f0101bdb:	c1 e7 0c             	shl    $0xc,%edi
f0101bde:	89 d0                	mov    %edx,%eax
f0101be0:	29 f0                	sub    %esi,%eax
f0101be2:	c1 f8 02             	sar    $0x2,%eax
f0101be5:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101beb:	c1 e0 0c             	shl    $0xc,%eax
f0101bee:	39 f8                	cmp    %edi,%eax
f0101bf0:	72 24                	jb     f0101c16 <check_page_alloc+0x3dd>
f0101bf2:	c7 44 24 0c 50 b8 10 	movl   $0xf010b850,0xc(%esp)
f0101bf9:	f0 
f0101bfa:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0101c01:	f0 
f0101c02:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
f0101c09:	00 
f0101c0a:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101c11:	e8 70 e4 ff ff       	call   f0100086 <_panic>
f0101c16:	89 c8                	mov    %ecx,%eax
f0101c18:	29 f0                	sub    %esi,%eax
f0101c1a:	c1 f8 02             	sar    $0x2,%eax
f0101c1d:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101c23:	c1 e0 0c             	shl    $0xc,%eax
f0101c26:	39 c7                	cmp    %eax,%edi
f0101c28:	77 24                	ja     f0101c4e <check_page_alloc+0x415>
f0101c2a:	c7 44 24 0c 6c b8 10 	movl   $0xf010b86c,0xc(%esp)
f0101c31:	f0 
f0101c32:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0101c39:	f0 
f0101c3a:	c7 44 24 04 51 01 00 	movl   $0x151,0x4(%esp)
f0101c41:	00 
f0101c42:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101c49:	e8 38 e4 ff ff       	call   f0100086 <_panic>
f0101c4e:	89 d8                	mov    %ebx,%eax
f0101c50:	29 f0                	sub    %esi,%eax
f0101c52:	c1 f8 02             	sar    $0x2,%eax
f0101c55:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101c5b:	c1 e0 0c             	shl    $0xc,%eax
f0101c5e:	39 c7                	cmp    %eax,%edi
f0101c60:	77 24                	ja     f0101c86 <check_page_alloc+0x44d>
f0101c62:	c7 44 24 0c 88 b8 10 	movl   $0xf010b888,0xc(%esp)
f0101c69:	f0 
f0101c6a:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0101c71:	f0 
f0101c72:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
f0101c79:	00 
f0101c7a:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101c81:	e8 00 e4 ff ff       	call   f0100086 <_panic>
f0101c86:	8b 1d b8 88 2a f0    	mov    0xf02a88b8,%ebx
f0101c8c:	c7 05 b8 88 2a f0 00 	movl   $0x0,0xf02a88b8
f0101c93:	00 00 00 
f0101c96:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0101c99:	89 04 24             	mov    %eax,(%esp)
f0101c9c:	e8 f7 f5 ff ff       	call   f0101298 <page_alloc>
f0101ca1:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101ca4:	74 24                	je     f0101cca <check_page_alloc+0x491>
f0101ca6:	c7 44 24 0c a4 b8 10 	movl   $0xf010b8a4,0xc(%esp)
f0101cad:	f0 
f0101cae:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0101cb5:	f0 
f0101cb6:	c7 44 24 04 59 01 00 	movl   $0x159,0x4(%esp)
f0101cbd:	00 
f0101cbe:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101cc5:	e8 bc e3 ff ff       	call   f0100086 <_panic>
f0101cca:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0101ccd:	89 04 24             	mov    %eax,(%esp)
f0101cd0:	e8 a3 f3 ff ff       	call   f0101078 <page_free>
f0101cd5:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f0101cd8:	89 04 24             	mov    %eax,(%esp)
f0101cdb:	e8 98 f3 ff ff       	call   f0101078 <page_free>
f0101ce0:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
f0101ce3:	89 04 24             	mov    %eax,(%esp)
f0101ce6:	e8 8d f3 ff ff       	call   f0101078 <page_free>
f0101ceb:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
f0101cf2:	c7 45 e8 00 00 00 00 	movl   $0x0,0xffffffe8(%ebp)
f0101cf9:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
f0101d00:	8d 45 ec             	lea    0xffffffec(%ebp),%eax
f0101d03:	89 04 24             	mov    %eax,(%esp)
f0101d06:	e8 8d f5 ff ff       	call   f0101298 <page_alloc>
f0101d0b:	85 c0                	test   %eax,%eax
f0101d0d:	74 24                	je     f0101d33 <check_page_alloc+0x4fa>
f0101d0f:	c7 44 24 0c fc b7 10 	movl   $0xf010b7fc,0xc(%esp)
f0101d16:	f0 
f0101d17:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0101d1e:	f0 
f0101d1f:	c7 44 24 04 60 01 00 	movl   $0x160,0x4(%esp)
f0101d26:	00 
f0101d27:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101d2e:	e8 53 e3 ff ff       	call   f0100086 <_panic>
f0101d33:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f0101d36:	89 04 24             	mov    %eax,(%esp)
f0101d39:	e8 5a f5 ff ff       	call   f0101298 <page_alloc>
f0101d3e:	85 c0                	test   %eax,%eax
f0101d40:	74 24                	je     f0101d66 <check_page_alloc+0x52d>
f0101d42:	c7 44 24 0c 12 b8 10 	movl   $0xf010b812,0xc(%esp)
f0101d49:	f0 
f0101d4a:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0101d51:	f0 
f0101d52:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
f0101d59:	00 
f0101d5a:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101d61:	e8 20 e3 ff ff       	call   f0100086 <_panic>
f0101d66:	8d 45 e4             	lea    0xffffffe4(%ebp),%eax
f0101d69:	89 04 24             	mov    %eax,(%esp)
f0101d6c:	e8 27 f5 ff ff       	call   f0101298 <page_alloc>
f0101d71:	85 c0                	test   %eax,%eax
f0101d73:	74 24                	je     f0101d99 <check_page_alloc+0x560>
f0101d75:	c7 44 24 0c 28 b8 10 	movl   $0xf010b828,0xc(%esp)
f0101d7c:	f0 
f0101d7d:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0101d84:	f0 
f0101d85:	c7 44 24 04 62 01 00 	movl   $0x162,0x4(%esp)
f0101d8c:	00 
f0101d8d:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101d94:	e8 ed e2 ff ff       	call   f0100086 <_panic>
f0101d99:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
f0101d9c:	85 c9                	test   %ecx,%ecx
f0101d9e:	75 24                	jne    f0101dc4 <check_page_alloc+0x58b>
f0101da0:	c7 44 24 0c 4c b8 10 	movl   $0xf010b84c,0xc(%esp)
f0101da7:	f0 
f0101da8:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0101daf:	f0 
f0101db0:	c7 44 24 04 63 01 00 	movl   $0x163,0x4(%esp)
f0101db7:	00 
f0101db8:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101dbf:	e8 c2 e2 ff ff       	call   f0100086 <_panic>
f0101dc4:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
f0101dc7:	85 d2                	test   %edx,%edx
f0101dc9:	74 04                	je     f0101dcf <check_page_alloc+0x596>
f0101dcb:	39 d1                	cmp    %edx,%ecx
f0101dcd:	75 24                	jne    f0101df3 <check_page_alloc+0x5ba>
f0101dcf:	c7 44 24 0c 3e b8 10 	movl   $0xf010b83e,0xc(%esp)
f0101dd6:	f0 
f0101dd7:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0101dde:	f0 
f0101ddf:	c7 44 24 04 64 01 00 	movl   $0x164,0x4(%esp)
f0101de6:	00 
f0101de7:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101dee:	e8 93 e2 ff ff       	call   f0100086 <_panic>
f0101df3:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
f0101df6:	85 c0                	test   %eax,%eax
f0101df8:	74 08                	je     f0101e02 <check_page_alloc+0x5c9>
f0101dfa:	39 c2                	cmp    %eax,%edx
f0101dfc:	74 04                	je     f0101e02 <check_page_alloc+0x5c9>
f0101dfe:	39 c1                	cmp    %eax,%ecx
f0101e00:	75 24                	jne    f0101e26 <check_page_alloc+0x5ed>
f0101e02:	c7 44 24 0c 48 b2 10 	movl   $0xf010b248,0xc(%esp)
f0101e09:	f0 
f0101e0a:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0101e11:	f0 
f0101e12:	c7 44 24 04 65 01 00 	movl   $0x165,0x4(%esp)
f0101e19:	00 
f0101e1a:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101e21:	e8 60 e2 ff ff       	call   f0100086 <_panic>
f0101e26:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0101e29:	89 04 24             	mov    %eax,(%esp)
f0101e2c:	e8 67 f4 ff ff       	call   f0101298 <page_alloc>
f0101e31:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101e34:	74 24                	je     f0101e5a <check_page_alloc+0x621>
f0101e36:	c7 44 24 0c a4 b8 10 	movl   $0xf010b8a4,0xc(%esp)
f0101e3d:	f0 
f0101e3e:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0101e45:	f0 
f0101e46:	c7 44 24 04 66 01 00 	movl   $0x166,0x4(%esp)
f0101e4d:	00 
f0101e4e:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101e55:	e8 2c e2 ff ff       	call   f0100086 <_panic>
f0101e5a:	89 1d b8 88 2a f0    	mov    %ebx,0xf02a88b8
f0101e60:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0101e63:	89 04 24             	mov    %eax,(%esp)
f0101e66:	e8 0d f2 ff ff       	call   f0101078 <page_free>
f0101e6b:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f0101e6e:	89 04 24             	mov    %eax,(%esp)
f0101e71:	e8 02 f2 ff ff       	call   f0101078 <page_free>
f0101e76:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
f0101e79:	89 04 24             	mov    %eax,(%esp)
f0101e7c:	e8 f7 f1 ff ff       	call   f0101078 <page_free>
f0101e81:	c7 04 24 68 b2 10 f0 	movl   $0xf010b268,(%esp)
f0101e88:	e8 aa 1b 00 00       	call   f0103a37 <cprintf>
f0101e8d:	83 c4 2c             	add    $0x2c,%esp
f0101e90:	5b                   	pop    %ebx
f0101e91:	5e                   	pop    %esi
f0101e92:	5f                   	pop    %edi
f0101e93:	5d                   	pop    %ebp
f0101e94:	c3                   	ret    

f0101e95 <i386_vm_init>:
f0101e95:	55                   	push   %ebp
f0101e96:	89 e5                	mov    %esp,%ebp
f0101e98:	57                   	push   %edi
f0101e99:	56                   	push   %esi
f0101e9a:	53                   	push   %ebx
f0101e9b:	83 ec 3c             	sub    $0x3c,%esp
f0101e9e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ea3:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101ea8:	e8 73 f1 ff ff       	call   f0101020 <boot_alloc>
f0101ead:	89 c3                	mov    %eax,%ebx
f0101eaf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101eb6:	00 
f0101eb7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101ebe:	00 
f0101ebf:	89 04 24             	mov    %eax,(%esp)
f0101ec2:	e8 ea 78 00 00       	call   f01097b1 <memset>
f0101ec7:	89 1d 78 98 2a f0    	mov    %ebx,0xf02a9878
f0101ecd:	89 d8                	mov    %ebx,%eax
f0101ecf:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0101ed5:	77 20                	ja     f0101ef7 <i386_vm_init+0x62>
f0101ed7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101edb:	c7 44 24 08 4c b1 10 	movl   $0xf010b14c,0x8(%esp)
f0101ee2:	f0 
f0101ee3:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
f0101eea:	00 
f0101eeb:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101ef2:	e8 8f e1 ff ff       	call   f0100086 <_panic>
f0101ef7:	05 00 00 00 10       	add    $0x10000000,%eax
f0101efc:	a3 74 98 2a f0       	mov    %eax,0xf02a9874
f0101f01:	89 c2                	mov    %eax,%edx
f0101f03:	83 ca 03             	or     $0x3,%edx
f0101f06:	89 93 fc 0e 00 00    	mov    %edx,0xefc(%ebx)
f0101f0c:	83 c8 05             	or     $0x5,%eax
f0101f0f:	89 83 f4 0e 00 00    	mov    %eax,0xef4(%ebx)
f0101f15:	a1 70 98 2a f0       	mov    0xf02a9870,%eax
f0101f1a:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0101f1d:	c1 e0 02             	shl    $0x2,%eax
f0101f20:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f25:	e8 f6 f0 ff ff       	call   f0101020 <boot_alloc>
f0101f2a:	a3 7c 98 2a f0       	mov    %eax,0xf02a987c
f0101f2f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f34:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101f39:	e8 e2 f0 ff ff       	call   f0101020 <boot_alloc>
f0101f3e:	a3 c0 88 2a f0       	mov    %eax,0xf02a88c0
f0101f43:	e8 ad f1 ff ff       	call   f01010f5 <page_init>
f0101f48:	e8 ec f8 ff ff       	call   f0101839 <check_page_alloc>

// check page_insert, page_remove, &c
static void
page_check(void)
{
	struct Page *pp, *pp0, *pp1, *pp2;
	struct Page_list fl;
	pte_t *ptep, *ptep1;
	void *va;
	int i;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
f0101f4d:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
f0101f54:	c7 45 e8 00 00 00 00 	movl   $0x0,0xffffffe8(%ebp)
f0101f5b:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
	assert(page_alloc(&pp0) == 0);
f0101f62:	8d 45 ec             	lea    0xffffffec(%ebp),%eax
f0101f65:	89 04 24             	mov    %eax,(%esp)
f0101f68:	e8 2b f3 ff ff       	call   f0101298 <page_alloc>
f0101f6d:	85 c0                	test   %eax,%eax
f0101f6f:	74 24                	je     f0101f95 <i386_vm_init+0x100>
f0101f71:	c7 44 24 0c fc b7 10 	movl   $0xf010b7fc,0xc(%esp)
f0101f78:	f0 
f0101f79:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0101f80:	f0 
f0101f81:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f0101f88:	00 
f0101f89:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101f90:	e8 f1 e0 ff ff       	call   f0100086 <_panic>
	assert(page_alloc(&pp1) == 0);
f0101f95:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f0101f98:	89 04 24             	mov    %eax,(%esp)
f0101f9b:	e8 f8 f2 ff ff       	call   f0101298 <page_alloc>
f0101fa0:	85 c0                	test   %eax,%eax
f0101fa2:	74 24                	je     f0101fc8 <i386_vm_init+0x133>
f0101fa4:	c7 44 24 0c 12 b8 10 	movl   $0xf010b812,0xc(%esp)
f0101fab:	f0 
f0101fac:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0101fb3:	f0 
f0101fb4:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f0101fbb:	00 
f0101fbc:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101fc3:	e8 be e0 ff ff       	call   f0100086 <_panic>
	assert(page_alloc(&pp2) == 0);
f0101fc8:	8d 45 e4             	lea    0xffffffe4(%ebp),%eax
f0101fcb:	89 04 24             	mov    %eax,(%esp)
f0101fce:	e8 c5 f2 ff ff       	call   f0101298 <page_alloc>
f0101fd3:	85 c0                	test   %eax,%eax
f0101fd5:	74 24                	je     f0101ffb <i386_vm_init+0x166>
f0101fd7:	c7 44 24 0c 28 b8 10 	movl   $0xf010b828,0xc(%esp)
f0101fde:	f0 
f0101fdf:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0101fe6:	f0 
f0101fe7:	c7 44 24 04 55 03 00 	movl   $0x355,0x4(%esp)
f0101fee:	00 
f0101fef:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0101ff6:	e8 8b e0 ff ff       	call   f0100086 <_panic>

	assert(pp0);
f0101ffb:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
f0101ffe:	85 c9                	test   %ecx,%ecx
f0102000:	75 24                	jne    f0102026 <i386_vm_init+0x191>
f0102002:	c7 44 24 0c 4c b8 10 	movl   $0xf010b84c,0xc(%esp)
f0102009:	f0 
f010200a:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102011:	f0 
f0102012:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f0102019:	00 
f010201a:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102021:	e8 60 e0 ff ff       	call   f0100086 <_panic>
	assert(pp1 && pp1 != pp0);
f0102026:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
f0102029:	85 d2                	test   %edx,%edx
f010202b:	74 04                	je     f0102031 <i386_vm_init+0x19c>
f010202d:	39 d1                	cmp    %edx,%ecx
f010202f:	75 24                	jne    f0102055 <i386_vm_init+0x1c0>
f0102031:	c7 44 24 0c 3e b8 10 	movl   $0xf010b83e,0xc(%esp)
f0102038:	f0 
f0102039:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102040:	f0 
f0102041:	c7 44 24 04 58 03 00 	movl   $0x358,0x4(%esp)
f0102048:	00 
f0102049:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102050:	e8 31 e0 ff ff       	call   f0100086 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102055:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
f0102058:	85 c0                	test   %eax,%eax
f010205a:	74 08                	je     f0102064 <i386_vm_init+0x1cf>
f010205c:	39 c2                	cmp    %eax,%edx
f010205e:	74 04                	je     f0102064 <i386_vm_init+0x1cf>
f0102060:	39 c1                	cmp    %eax,%ecx
f0102062:	75 24                	jne    f0102088 <i386_vm_init+0x1f3>
f0102064:	c7 44 24 0c 48 b2 10 	movl   $0xf010b248,0xc(%esp)
f010206b:	f0 
f010206c:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102073:	f0 
f0102074:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f010207b:	00 
f010207c:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102083:	e8 fe df ff ff       	call   f0100086 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102088:	8b 35 b8 88 2a f0    	mov    0xf02a88b8,%esi
	LIST_INIT(&page_free_list);
f010208e:	c7 05 b8 88 2a f0 00 	movl   $0x0,0xf02a88b8
f0102095:	00 00 00 

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0102098:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f010209b:	89 04 24             	mov    %eax,(%esp)
f010209e:	e8 f5 f1 ff ff       	call   f0101298 <page_alloc>
f01020a3:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01020a6:	74 24                	je     f01020cc <i386_vm_init+0x237>
f01020a8:	c7 44 24 0c a4 b8 10 	movl   $0xf010b8a4,0xc(%esp)
f01020af:	f0 
f01020b0:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f01020b7:	f0 
f01020b8:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
f01020bf:	00 
f01020c0:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f01020c7:	e8 ba df ff ff       	call   f0100086 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(boot_pgdir, (void *) 0x0, &ptep) == NULL);
f01020cc:	8d 45 e0             	lea    0xffffffe0(%ebp),%eax
f01020cf:	89 44 24 08          	mov    %eax,0x8(%esp)
f01020d3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01020da:	00 
f01020db:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f01020e0:	89 04 24             	mov    %eax,(%esp)
f01020e3:	e8 45 f3 ff ff       	call   f010142d <page_lookup>
f01020e8:	85 c0                	test   %eax,%eax
f01020ea:	74 24                	je     f0102110 <i386_vm_init+0x27b>
f01020ec:	c7 44 24 0c 88 b2 10 	movl   $0xf010b288,0xc(%esp)
f01020f3:	f0 
f01020f4:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f01020fb:	f0 
f01020fc:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
f0102103:	00 
f0102104:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f010210b:	e8 76 df ff ff       	call   f0100086 <_panic>

	// there is no free memory, so we can't allocate a page table 
	assert(page_insert(boot_pgdir, pp1, 0x0, 0) < 0);
f0102110:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102117:	00 
f0102118:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010211f:	00 
f0102120:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f0102123:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102127:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f010212c:	89 04 24             	mov    %eax,(%esp)
f010212f:	e8 85 f5 ff ff       	call   f01016b9 <page_insert>
f0102134:	85 c0                	test   %eax,%eax
f0102136:	78 24                	js     f010215c <i386_vm_init+0x2c7>
f0102138:	c7 44 24 0c c0 b2 10 	movl   $0xf010b2c0,0xc(%esp)
f010213f:	f0 
f0102140:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102147:	f0 
f0102148:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f010214f:	00 
f0102150:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102157:	e8 2a df ff ff       	call   f0100086 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010215c:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f010215f:	89 04 24             	mov    %eax,(%esp)
f0102162:	e8 11 ef ff ff       	call   f0101078 <page_free>
	assert(page_insert(boot_pgdir, pp1, 0x0, 0) == 0);
f0102167:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010216e:	00 
f010216f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102176:	00 
f0102177:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f010217a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010217e:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f0102183:	89 04 24             	mov    %eax,(%esp)
f0102186:	e8 2e f5 ff ff       	call   f01016b9 <page_insert>
f010218b:	85 c0                	test   %eax,%eax
f010218d:	74 24                	je     f01021b3 <i386_vm_init+0x31e>
f010218f:	c7 44 24 0c ec b2 10 	movl   $0xf010b2ec,0xc(%esp)
f0102196:	f0 
f0102197:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f010219e:	f0 
f010219f:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f01021a6:	00 
f01021a7:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f01021ae:	e8 d3 de ff ff       	call   f0100086 <_panic>
	assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f01021b3:	8b 0d 78 98 2a f0    	mov    0xf02a9878,%ecx
f01021b9:	8b 11                	mov    (%ecx),%edx
f01021bb:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01021c1:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f01021c4:	2b 05 7c 98 2a f0    	sub    0xf02a987c,%eax
f01021ca:	c1 f8 02             	sar    $0x2,%eax
f01021cd:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01021d3:	c1 e0 0c             	shl    $0xc,%eax
f01021d6:	39 c2                	cmp    %eax,%edx
f01021d8:	74 24                	je     f01021fe <i386_vm_init+0x369>
f01021da:	c7 44 24 0c 18 b3 10 	movl   $0xf010b318,0xc(%esp)
f01021e1:	f0 
f01021e2:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f01021e9:	f0 
f01021ea:	c7 44 24 04 6b 03 00 	movl   $0x36b,0x4(%esp)
f01021f1:	00 
f01021f2:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f01021f9:	e8 88 de ff ff       	call   f0100086 <_panic>
	assert(check_va2pa(boot_pgdir, 0x0) == page2pa(pp1));
f01021fe:	ba 00 00 00 00       	mov    $0x0,%edx
f0102203:	89 c8                	mov    %ecx,%eax
f0102205:	e8 24 f0 ff ff       	call   f010122e <check_va2pa>
f010220a:	8b 4d e8             	mov    0xffffffe8(%ebp),%ecx
f010220d:	89 ca                	mov    %ecx,%edx
f010220f:	2b 15 7c 98 2a f0    	sub    0xf02a987c,%edx
f0102215:	c1 fa 02             	sar    $0x2,%edx
f0102218:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f010221e:	c1 e2 0c             	shl    $0xc,%edx
f0102221:	39 d0                	cmp    %edx,%eax
f0102223:	74 24                	je     f0102249 <i386_vm_init+0x3b4>
f0102225:	c7 44 24 0c 40 b3 10 	movl   $0xf010b340,0xc(%esp)
f010222c:	f0 
f010222d:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102234:	f0 
f0102235:	c7 44 24 04 6c 03 00 	movl   $0x36c,0x4(%esp)
f010223c:	00 
f010223d:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102244:	e8 3d de ff ff       	call   f0100086 <_panic>
	assert(pp1->pp_ref == 1);
f0102249:	66 83 79 08 01       	cmpw   $0x1,0x8(%ecx)
f010224e:	74 24                	je     f0102274 <i386_vm_init+0x3df>
f0102250:	c7 44 24 0c c1 b8 10 	movl   $0xf010b8c1,0xc(%esp)
f0102257:	f0 
f0102258:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f010225f:	f0 
f0102260:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f0102267:	00 
f0102268:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f010226f:	e8 12 de ff ff       	call   f0100086 <_panic>
	assert(pp0->pp_ref == 1);
f0102274:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0102277:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f010227c:	74 24                	je     f01022a2 <i386_vm_init+0x40d>
f010227e:	c7 44 24 0c d2 b8 10 	movl   $0xf010b8d2,0xc(%esp)
f0102285:	f0 
f0102286:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f010228d:	f0 
f010228e:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f0102295:	00 
f0102296:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f010229d:	e8 e4 dd ff ff       	call   f0100086 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f01022a2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01022a9:	00 
f01022aa:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01022b1:	00 
f01022b2:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
f01022b5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01022b9:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f01022be:	89 04 24             	mov    %eax,(%esp)
f01022c1:	e8 f3 f3 ff ff       	call   f01016b9 <page_insert>
f01022c6:	85 c0                	test   %eax,%eax
f01022c8:	74 24                	je     f01022ee <i386_vm_init+0x459>
f01022ca:	c7 44 24 0c 70 b3 10 	movl   $0xf010b370,0xc(%esp)
f01022d1:	f0 
f01022d2:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f01022d9:	f0 
f01022da:	c7 44 24 04 71 03 00 	movl   $0x371,0x4(%esp)
f01022e1:	00 
f01022e2:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f01022e9:	e8 98 dd ff ff       	call   f0100086 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f01022ee:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022f3:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f01022f8:	e8 31 ef ff ff       	call   f010122e <check_va2pa>
f01022fd:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
f0102300:	89 ca                	mov    %ecx,%edx
f0102302:	2b 15 7c 98 2a f0    	sub    0xf02a987c,%edx
f0102308:	c1 fa 02             	sar    $0x2,%edx
f010230b:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102311:	c1 e2 0c             	shl    $0xc,%edx
f0102314:	39 d0                	cmp    %edx,%eax
f0102316:	74 24                	je     f010233c <i386_vm_init+0x4a7>
f0102318:	c7 44 24 0c a8 b3 10 	movl   $0xf010b3a8,0xc(%esp)
f010231f:	f0 
f0102320:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102327:	f0 
f0102328:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f010232f:	00 
f0102330:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102337:	e8 4a dd ff ff       	call   f0100086 <_panic>
	assert(pp2->pp_ref == 1);
f010233c:	66 83 79 08 01       	cmpw   $0x1,0x8(%ecx)
f0102341:	74 24                	je     f0102367 <i386_vm_init+0x4d2>
f0102343:	c7 44 24 0c e3 b8 10 	movl   $0xf010b8e3,0xc(%esp)
f010234a:	f0 
f010234b:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102352:	f0 
f0102353:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
f010235a:	00 
f010235b:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102362:	e8 1f dd ff ff       	call   f0100086 <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0102367:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f010236a:	89 04 24             	mov    %eax,(%esp)
f010236d:	e8 26 ef ff ff       	call   f0101298 <page_alloc>
f0102372:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102375:	74 24                	je     f010239b <i386_vm_init+0x506>
f0102377:	c7 44 24 0c a4 b8 10 	movl   $0xf010b8a4,0xc(%esp)
f010237e:	f0 
f010237f:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102386:	f0 
f0102387:	c7 44 24 04 76 03 00 	movl   $0x376,0x4(%esp)
f010238e:	00 
f010238f:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102396:	e8 eb dc ff ff       	call   f0100086 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f010239b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01023a2:	00 
f01023a3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01023aa:	00 
f01023ab:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
f01023ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01023b2:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f01023b7:	89 04 24             	mov    %eax,(%esp)
f01023ba:	e8 fa f2 ff ff       	call   f01016b9 <page_insert>
f01023bf:	85 c0                	test   %eax,%eax
f01023c1:	74 24                	je     f01023e7 <i386_vm_init+0x552>
f01023c3:	c7 44 24 0c 70 b3 10 	movl   $0xf010b370,0xc(%esp)
f01023ca:	f0 
f01023cb:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f01023d2:	f0 
f01023d3:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f01023da:	00 
f01023db:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f01023e2:	e8 9f dc ff ff       	call   f0100086 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f01023e7:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023ec:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f01023f1:	e8 38 ee ff ff       	call   f010122e <check_va2pa>
f01023f6:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
f01023f9:	89 ca                	mov    %ecx,%edx
f01023fb:	2b 15 7c 98 2a f0    	sub    0xf02a987c,%edx
f0102401:	c1 fa 02             	sar    $0x2,%edx
f0102404:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f010240a:	c1 e2 0c             	shl    $0xc,%edx
f010240d:	39 d0                	cmp    %edx,%eax
f010240f:	74 24                	je     f0102435 <i386_vm_init+0x5a0>
f0102411:	c7 44 24 0c a8 b3 10 	movl   $0xf010b3a8,0xc(%esp)
f0102418:	f0 
f0102419:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102420:	f0 
f0102421:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0102428:	00 
f0102429:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102430:	e8 51 dc ff ff       	call   f0100086 <_panic>
	assert(pp2->pp_ref == 1);
f0102435:	66 83 79 08 01       	cmpw   $0x1,0x8(%ecx)
f010243a:	74 24                	je     f0102460 <i386_vm_init+0x5cb>
f010243c:	c7 44 24 0c e3 b8 10 	movl   $0xf010b8e3,0xc(%esp)
f0102443:	f0 
f0102444:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f010244b:	f0 
f010244c:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f0102453:	00 
f0102454:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f010245b:	e8 26 dc ff ff       	call   f0100086 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(page_alloc(&pp) == -E_NO_MEM);
f0102460:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0102463:	89 04 24             	mov    %eax,(%esp)
f0102466:	e8 2d ee ff ff       	call   f0101298 <page_alloc>
f010246b:	83 f8 fc             	cmp    $0xfffffffc,%eax
f010246e:	74 24                	je     f0102494 <i386_vm_init+0x5ff>
f0102470:	c7 44 24 0c a4 b8 10 	movl   $0xf010b8a4,0xc(%esp)
f0102477:	f0 
f0102478:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f010247f:	f0 
f0102480:	c7 44 24 04 7f 03 00 	movl   $0x37f,0x4(%esp)
f0102487:	00 
f0102488:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f010248f:	e8 f2 db ff ff       	call   f0100086 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = KADDR(PTE_ADDR(boot_pgdir[PDX(PGSIZE)]));
f0102494:	8b 0d 78 98 2a f0    	mov    0xf02a9878,%ecx
f010249a:	8b 11                	mov    (%ecx),%edx
f010249c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01024a2:	89 d0                	mov    %edx,%eax
f01024a4:	c1 e8 0c             	shr    $0xc,%eax
f01024a7:	3b 05 70 98 2a f0    	cmp    0xf02a9870,%eax
f01024ad:	72 20                	jb     f01024cf <i386_vm_init+0x63a>
f01024af:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01024b3:	c7 44 24 08 c8 ad 10 	movl   $0xf010adc8,0x8(%esp)
f01024ba:	f0 
f01024bb:	c7 44 24 04 82 03 00 	movl   $0x382,0x4(%esp)
f01024c2:	00 
f01024c3:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f01024ca:	e8 b7 db ff ff       	call   f0100086 <_panic>
f01024cf:	8d 82 00 00 00 f0    	lea    0xf0000000(%edx),%eax
f01024d5:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
	assert(pgdir_walk(boot_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01024d8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01024df:	00 
f01024e0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01024e7:	00 
f01024e8:	89 0c 24             	mov    %ecx,(%esp)
f01024eb:	e8 fd ed ff ff       	call   f01012ed <pgdir_walk>
f01024f0:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
f01024f3:	83 c2 04             	add    $0x4,%edx
f01024f6:	39 d0                	cmp    %edx,%eax
f01024f8:	74 24                	je     f010251e <i386_vm_init+0x689>
f01024fa:	c7 44 24 0c d8 b3 10 	movl   $0xf010b3d8,0xc(%esp)
f0102501:	f0 
f0102502:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102509:	f0 
f010250a:	c7 44 24 04 83 03 00 	movl   $0x383,0x4(%esp)
f0102511:	00 
f0102512:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102519:	e8 68 db ff ff       	call   f0100086 <_panic>

	// should be able to change permissions too.
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, PTE_U) == 0);
f010251e:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0102525:	00 
f0102526:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010252d:	00 
f010252e:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
f0102531:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102535:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f010253a:	89 04 24             	mov    %eax,(%esp)
f010253d:	e8 77 f1 ff ff       	call   f01016b9 <page_insert>
f0102542:	85 c0                	test   %eax,%eax
f0102544:	74 24                	je     f010256a <i386_vm_init+0x6d5>
f0102546:	c7 44 24 0c 18 b4 10 	movl   $0xf010b418,0xc(%esp)
f010254d:	f0 
f010254e:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102555:	f0 
f0102556:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f010255d:	00 
f010255e:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102565:	e8 1c db ff ff       	call   f0100086 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f010256a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010256f:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f0102574:	e8 b5 ec ff ff       	call   f010122e <check_va2pa>
f0102579:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
f010257c:	89 ca                	mov    %ecx,%edx
f010257e:	2b 15 7c 98 2a f0    	sub    0xf02a987c,%edx
f0102584:	c1 fa 02             	sar    $0x2,%edx
f0102587:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f010258d:	c1 e2 0c             	shl    $0xc,%edx
f0102590:	39 d0                	cmp    %edx,%eax
f0102592:	74 24                	je     f01025b8 <i386_vm_init+0x723>
f0102594:	c7 44 24 0c a8 b3 10 	movl   $0xf010b3a8,0xc(%esp)
f010259b:	f0 
f010259c:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f01025a3:	f0 
f01025a4:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f01025ab:	00 
f01025ac:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f01025b3:	e8 ce da ff ff       	call   f0100086 <_panic>
	assert(pp2->pp_ref == 1);
f01025b8:	66 83 79 08 01       	cmpw   $0x1,0x8(%ecx)
f01025bd:	74 24                	je     f01025e3 <i386_vm_init+0x74e>
f01025bf:	c7 44 24 0c e3 b8 10 	movl   $0xf010b8e3,0xc(%esp)
f01025c6:	f0 
f01025c7:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f01025ce:	f0 
f01025cf:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f01025d6:	00 
f01025d7:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f01025de:	e8 a3 da ff ff       	call   f0100086 <_panic>
	assert(*pgdir_walk(boot_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01025e3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01025ea:	00 
f01025eb:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01025f2:	00 
f01025f3:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f01025f8:	89 04 24             	mov    %eax,(%esp)
f01025fb:	e8 ed ec ff ff       	call   f01012ed <pgdir_walk>
f0102600:	f6 00 04             	testb  $0x4,(%eax)
f0102603:	75 24                	jne    f0102629 <i386_vm_init+0x794>
f0102605:	c7 44 24 0c 54 b4 10 	movl   $0xf010b454,0xc(%esp)
f010260c:	f0 
f010260d:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102614:	f0 
f0102615:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f010261c:	00 
f010261d:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102624:	e8 5d da ff ff       	call   f0100086 <_panic>
	assert(boot_pgdir[0] & PTE_U);
f0102629:	8b 15 78 98 2a f0    	mov    0xf02a9878,%edx
f010262f:	f6 02 04             	testb  $0x4,(%edx)
f0102632:	75 24                	jne    f0102658 <i386_vm_init+0x7c3>
f0102634:	c7 44 24 0c f4 b8 10 	movl   $0xf010b8f4,0xc(%esp)
f010263b:	f0 
f010263c:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102643:	f0 
f0102644:	c7 44 24 04 8a 03 00 	movl   $0x38a,0x4(%esp)
f010264b:	00 
f010264c:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102653:	e8 2e da ff ff       	call   f0100086 <_panic>
	
	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(boot_pgdir, pp0, (void*) PTSIZE, 0) < 0);
f0102658:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010265f:	00 
f0102660:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102667:	00 
f0102668:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f010266b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010266f:	89 14 24             	mov    %edx,(%esp)
f0102672:	e8 42 f0 ff ff       	call   f01016b9 <page_insert>
f0102677:	85 c0                	test   %eax,%eax
f0102679:	78 24                	js     f010269f <i386_vm_init+0x80a>
f010267b:	c7 44 24 0c 88 b4 10 	movl   $0xf010b488,0xc(%esp)
f0102682:	f0 
f0102683:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f010268a:	f0 
f010268b:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f0102692:	00 
f0102693:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f010269a:	e8 e7 d9 ff ff       	call   f0100086 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(boot_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010269f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01026a6:	00 
f01026a7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01026ae:	00 
f01026af:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f01026b2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01026b6:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f01026bb:	89 04 24             	mov    %eax,(%esp)
f01026be:	e8 f6 ef ff ff       	call   f01016b9 <page_insert>
f01026c3:	85 c0                	test   %eax,%eax
f01026c5:	74 24                	je     f01026eb <i386_vm_init+0x856>
f01026c7:	c7 44 24 0c bc b4 10 	movl   $0xf010b4bc,0xc(%esp)
f01026ce:	f0 
f01026cf:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f01026d6:	f0 
f01026d7:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f01026de:	00 
f01026df:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f01026e6:	e8 9b d9 ff ff       	call   f0100086 <_panic>
	assert(!(*pgdir_walk(boot_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01026eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01026f2:	00 
f01026f3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01026fa:	00 
f01026fb:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f0102700:	89 04 24             	mov    %eax,(%esp)
f0102703:	e8 e5 eb ff ff       	call   f01012ed <pgdir_walk>
f0102708:	f6 00 04             	testb  $0x4,(%eax)
f010270b:	74 24                	je     f0102731 <i386_vm_init+0x89c>
f010270d:	c7 44 24 0c f4 b4 10 	movl   $0xf010b4f4,0xc(%esp)
f0102714:	f0 
f0102715:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f010271c:	f0 
f010271d:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0102724:	00 
f0102725:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f010272c:	e8 55 d9 ff ff       	call   f0100086 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(boot_pgdir, 0) == page2pa(pp1));
f0102731:	ba 00 00 00 00       	mov    $0x0,%edx
f0102736:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f010273b:	e8 ee ea ff ff       	call   f010122e <check_va2pa>
f0102740:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
f0102743:	2b 15 7c 98 2a f0    	sub    0xf02a987c,%edx
f0102749:	c1 fa 02             	sar    $0x2,%edx
f010274c:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102752:	c1 e2 0c             	shl    $0xc,%edx
f0102755:	39 d0                	cmp    %edx,%eax
f0102757:	74 24                	je     f010277d <i386_vm_init+0x8e8>
f0102759:	c7 44 24 0c 2c b5 10 	movl   $0xf010b52c,0xc(%esp)
f0102760:	f0 
f0102761:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102768:	f0 
f0102769:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0102770:	00 
f0102771:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102778:	e8 09 d9 ff ff       	call   f0100086 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f010277d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102782:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f0102787:	e8 a2 ea ff ff       	call   f010122e <check_va2pa>
f010278c:	8b 4d e8             	mov    0xffffffe8(%ebp),%ecx
f010278f:	89 ca                	mov    %ecx,%edx
f0102791:	2b 15 7c 98 2a f0    	sub    0xf02a987c,%edx
f0102797:	c1 fa 02             	sar    $0x2,%edx
f010279a:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01027a0:	c1 e2 0c             	shl    $0xc,%edx
f01027a3:	39 d0                	cmp    %edx,%eax
f01027a5:	74 24                	je     f01027cb <i386_vm_init+0x936>
f01027a7:	c7 44 24 0c 58 b5 10 	movl   $0xf010b558,0xc(%esp)
f01027ae:	f0 
f01027af:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f01027b6:	f0 
f01027b7:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f01027be:	00 
f01027bf:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f01027c6:	e8 bb d8 ff ff       	call   f0100086 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01027cb:	66 83 79 08 02       	cmpw   $0x2,0x8(%ecx)
f01027d0:	74 24                	je     f01027f6 <i386_vm_init+0x961>
f01027d2:	c7 44 24 0c 0a b9 10 	movl   $0xf010b90a,0xc(%esp)
f01027d9:	f0 
f01027da:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f01027e1:	f0 
f01027e2:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f01027e9:	00 
f01027ea:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f01027f1:	e8 90 d8 ff ff       	call   f0100086 <_panic>
	assert(pp2->pp_ref == 0);
f01027f6:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
f01027f9:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f01027fe:	74 24                	je     f0102824 <i386_vm_init+0x98f>
f0102800:	c7 44 24 0c 1b b9 10 	movl   $0xf010b91b,0xc(%esp)
f0102807:	f0 
f0102808:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f010280f:	f0 
f0102810:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f0102817:	00 
f0102818:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f010281f:	e8 62 d8 ff ff       	call   f0100086 <_panic>

	// pp2 should be returned by page_alloc
	assert(page_alloc(&pp) == 0 && pp == pp2);
f0102824:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0102827:	89 04 24             	mov    %eax,(%esp)
f010282a:	e8 69 ea ff ff       	call   f0101298 <page_alloc>
f010282f:	85 c0                	test   %eax,%eax
f0102831:	75 08                	jne    f010283b <i386_vm_init+0x9a6>
f0102833:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0102836:	3b 45 e4             	cmp    0xffffffe4(%ebp),%eax
f0102839:	74 24                	je     f010285f <i386_vm_init+0x9ca>
f010283b:	c7 44 24 0c 88 b5 10 	movl   $0xf010b588,0xc(%esp)
f0102842:	f0 
f0102843:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f010284a:	f0 
f010284b:	c7 44 24 04 9b 03 00 	movl   $0x39b,0x4(%esp)
f0102852:	00 
f0102853:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f010285a:	e8 27 d8 ff ff       	call   f0100086 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(boot_pgdir, 0x0);
f010285f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102866:	00 
f0102867:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f010286c:	89 04 24             	mov    %eax,(%esp)
f010286f:	e8 65 ed ff ff       	call   f01015d9 <page_remove>
	assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f0102874:	ba 00 00 00 00       	mov    $0x0,%edx
f0102879:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f010287e:	e8 ab e9 ff ff       	call   f010122e <check_va2pa>
f0102883:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102886:	74 24                	je     f01028ac <i386_vm_init+0xa17>
f0102888:	c7 44 24 0c ac b5 10 	movl   $0xf010b5ac,0xc(%esp)
f010288f:	f0 
f0102890:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102897:	f0 
f0102898:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f010289f:	00 
f01028a0:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f01028a7:	e8 da d7 ff ff       	call   f0100086 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f01028ac:	ba 00 10 00 00       	mov    $0x1000,%edx
f01028b1:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f01028b6:	e8 73 e9 ff ff       	call   f010122e <check_va2pa>
f01028bb:	8b 4d e8             	mov    0xffffffe8(%ebp),%ecx
f01028be:	89 ca                	mov    %ecx,%edx
f01028c0:	2b 15 7c 98 2a f0    	sub    0xf02a987c,%edx
f01028c6:	c1 fa 02             	sar    $0x2,%edx
f01028c9:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01028cf:	c1 e2 0c             	shl    $0xc,%edx
f01028d2:	39 d0                	cmp    %edx,%eax
f01028d4:	74 24                	je     f01028fa <i386_vm_init+0xa65>
f01028d6:	c7 44 24 0c 58 b5 10 	movl   $0xf010b558,0xc(%esp)
f01028dd:	f0 
f01028de:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f01028e5:	f0 
f01028e6:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f01028ed:	00 
f01028ee:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f01028f5:	e8 8c d7 ff ff       	call   f0100086 <_panic>
	assert(pp1->pp_ref == 1);
f01028fa:	66 83 79 08 01       	cmpw   $0x1,0x8(%ecx)
f01028ff:	74 24                	je     f0102925 <i386_vm_init+0xa90>
f0102901:	c7 44 24 0c c1 b8 10 	movl   $0xf010b8c1,0xc(%esp)
f0102908:	f0 
f0102909:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102910:	f0 
f0102911:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f0102918:	00 
f0102919:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102920:	e8 61 d7 ff ff       	call   f0100086 <_panic>
	assert(pp2->pp_ref == 0);
f0102925:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
f0102928:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f010292d:	74 24                	je     f0102953 <i386_vm_init+0xabe>
f010292f:	c7 44 24 0c 1b b9 10 	movl   $0xf010b91b,0xc(%esp)
f0102936:	f0 
f0102937:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f010293e:	f0 
f010293f:	c7 44 24 04 a2 03 00 	movl   $0x3a2,0x4(%esp)
f0102946:	00 
f0102947:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f010294e:	e8 33 d7 ff ff       	call   f0100086 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(boot_pgdir, (void*) PGSIZE);
f0102953:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010295a:	00 
f010295b:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f0102960:	89 04 24             	mov    %eax,(%esp)
f0102963:	e8 71 ec ff ff       	call   f01015d9 <page_remove>
	assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f0102968:	ba 00 00 00 00       	mov    $0x0,%edx
f010296d:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f0102972:	e8 b7 e8 ff ff       	call   f010122e <check_va2pa>
f0102977:	83 f8 ff             	cmp    $0xffffffff,%eax
f010297a:	74 24                	je     f01029a0 <i386_vm_init+0xb0b>
f010297c:	c7 44 24 0c ac b5 10 	movl   $0xf010b5ac,0xc(%esp)
f0102983:	f0 
f0102984:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f010298b:	f0 
f010298c:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0102993:	00 
f0102994:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f010299b:	e8 e6 d6 ff ff       	call   f0100086 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == ~0);
f01029a0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01029a5:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f01029aa:	e8 7f e8 ff ff       	call   f010122e <check_va2pa>
f01029af:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029b2:	74 24                	je     f01029d8 <i386_vm_init+0xb43>
f01029b4:	c7 44 24 0c d0 b5 10 	movl   $0xf010b5d0,0xc(%esp)
f01029bb:	f0 
f01029bc:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f01029c3:	f0 
f01029c4:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f01029cb:	00 
f01029cc:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f01029d3:	e8 ae d6 ff ff       	call   f0100086 <_panic>
	assert(pp1->pp_ref == 0);
f01029d8:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f01029db:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f01029e0:	74 24                	je     f0102a06 <i386_vm_init+0xb71>
f01029e2:	c7 44 24 0c 2c b9 10 	movl   $0xf010b92c,0xc(%esp)
f01029e9:	f0 
f01029ea:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f01029f1:	f0 
f01029f2:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f01029f9:	00 
f01029fa:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102a01:	e8 80 d6 ff ff       	call   f0100086 <_panic>
	assert(pp2->pp_ref == 0);
f0102a06:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
f0102a09:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0102a0e:	74 24                	je     f0102a34 <i386_vm_init+0xb9f>
f0102a10:	c7 44 24 0c 1b b9 10 	movl   $0xf010b91b,0xc(%esp)
f0102a17:	f0 
f0102a18:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102a1f:	f0 
f0102a20:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f0102a27:	00 
f0102a28:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102a2f:	e8 52 d6 ff ff       	call   f0100086 <_panic>

	// so it should be returned by page_alloc
	assert(page_alloc(&pp) == 0 && pp == pp1);
f0102a34:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0102a37:	89 04 24             	mov    %eax,(%esp)
f0102a3a:	e8 59 e8 ff ff       	call   f0101298 <page_alloc>
f0102a3f:	85 c0                	test   %eax,%eax
f0102a41:	75 08                	jne    f0102a4b <i386_vm_init+0xbb6>
f0102a43:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0102a46:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
f0102a49:	74 24                	je     f0102a6f <i386_vm_init+0xbda>
f0102a4b:	c7 44 24 0c f8 b5 10 	movl   $0xf010b5f8,0xc(%esp)
f0102a52:	f0 
f0102a53:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102a5a:	f0 
f0102a5b:	c7 44 24 04 ac 03 00 	movl   $0x3ac,0x4(%esp)
f0102a62:	00 
f0102a63:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102a6a:	e8 17 d6 ff ff       	call   f0100086 <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0102a6f:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0102a72:	89 04 24             	mov    %eax,(%esp)
f0102a75:	e8 1e e8 ff ff       	call   f0101298 <page_alloc>
f0102a7a:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102a7d:	74 24                	je     f0102aa3 <i386_vm_init+0xc0e>
f0102a7f:	c7 44 24 0c a4 b8 10 	movl   $0xf010b8a4,0xc(%esp)
f0102a86:	f0 
f0102a87:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102a8e:	f0 
f0102a8f:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f0102a96:	00 
f0102a97:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102a9e:	e8 e3 d5 ff ff       	call   f0100086 <_panic>
	
#if 0
	// should be able to page_insert to change a page
	// and see the new data immediately.
	memset(page2kva(pp1), 1, PGSIZE);
	memset(page2kva(pp2), 2, PGSIZE);
	page_insert(boot_pgdir, pp1, 0x0, 0);
	assert(pp1->pp_ref == 1);
	assert(*(int*)0 == 0x01010101);
	page_insert(boot_pgdir, pp2, 0x0, 0);
	assert(*(int*)0 == 0x02020202);
	assert(pp2->pp_ref == 1);
	assert(pp1->pp_ref == 0);
	page_remove(boot_pgdir, 0x0);
	assert(pp2->pp_ref == 0);
#endif

	// forcibly take pp0 back
	assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f0102aa3:	8b 0d 78 98 2a f0    	mov    0xf02a9878,%ecx
f0102aa9:	8b 11                	mov    (%ecx),%edx
f0102aab:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102ab1:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0102ab4:	2b 05 7c 98 2a f0    	sub    0xf02a987c,%eax
f0102aba:	c1 f8 02             	sar    $0x2,%eax
f0102abd:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102ac3:	c1 e0 0c             	shl    $0xc,%eax
f0102ac6:	39 c2                	cmp    %eax,%edx
f0102ac8:	74 24                	je     f0102aee <i386_vm_init+0xc59>
f0102aca:	c7 44 24 0c 18 b3 10 	movl   $0xf010b318,0xc(%esp)
f0102ad1:	f0 
f0102ad2:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102ad9:	f0 
f0102ada:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f0102ae1:	00 
f0102ae2:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102ae9:	e8 98 d5 ff ff       	call   f0100086 <_panic>
	boot_pgdir[0] = 0;
f0102aee:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102af4:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0102af7:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0102afc:	74 24                	je     f0102b22 <i386_vm_init+0xc8d>
f0102afe:	c7 44 24 0c d2 b8 10 	movl   $0xf010b8d2,0xc(%esp)
f0102b05:	f0 
f0102b06:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102b0d:	f0 
f0102b0e:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0102b15:	00 
f0102b16:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102b1d:	e8 64 d5 ff ff       	call   f0100086 <_panic>
	pp0->pp_ref = 0;
f0102b22:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
	
	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102b28:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0102b2b:	89 04 24             	mov    %eax,(%esp)
f0102b2e:	e8 45 e5 ff ff       	call   f0101078 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(boot_pgdir, va, 1);
f0102b33:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102b3a:	00 
f0102b3b:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102b42:	00 
f0102b43:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f0102b48:	89 04 24             	mov    %eax,(%esp)
f0102b4b:	e8 9d e7 ff ff       	call   f01012ed <pgdir_walk>
f0102b50:	89 c1                	mov    %eax,%ecx
f0102b52:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
	ptep1 = KADDR(PTE_ADDR(boot_pgdir[PDX(va)]));
f0102b55:	8b 3d 78 98 2a f0    	mov    0xf02a9878,%edi
f0102b5b:	83 c7 04             	add    $0x4,%edi
f0102b5e:	8b 17                	mov    (%edi),%edx
f0102b60:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102b66:	89 d0                	mov    %edx,%eax
f0102b68:	c1 e8 0c             	shr    $0xc,%eax
f0102b6b:	3b 05 70 98 2a f0    	cmp    0xf02a9870,%eax
f0102b71:	72 20                	jb     f0102b93 <i386_vm_init+0xcfe>
f0102b73:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102b77:	c7 44 24 08 c8 ad 10 	movl   $0xf010adc8,0x8(%esp)
f0102b7e:	f0 
f0102b7f:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f0102b86:	00 
f0102b87:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102b8e:	e8 f3 d4 ff ff       	call   f0100086 <_panic>
f0102b93:	8d 82 04 00 00 f0    	lea    0xf0000004(%edx),%eax
f0102b99:	39 c1                	cmp    %eax,%ecx
f0102b9b:	74 24                	je     f0102bc1 <i386_vm_init+0xd2c>
	assert(ptep == ptep1 + PTX(va));
f0102b9d:	c7 44 24 0c 3d b9 10 	movl   $0xf010b93d,0xc(%esp)
f0102ba4:	f0 
f0102ba5:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102bac:	f0 
f0102bad:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0102bb4:	00 
f0102bb5:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102bbc:	e8 c5 d4 ff ff       	call   f0100086 <_panic>
	boot_pgdir[PDX(va)] = 0;
f0102bc1:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	pp0->pp_ref = 0;
f0102bc7:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0102bca:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0102bd0:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0102bd3:	2b 05 7c 98 2a f0    	sub    0xf02a987c,%eax
f0102bd9:	c1 f8 02             	sar    $0x2,%eax
f0102bdc:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102be2:	89 c2                	mov    %eax,%edx
f0102be4:	c1 e2 0c             	shl    $0xc,%edx
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
		panic("pa2page called with invalid pa");
	return &pages[PPN(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0102be7:	89 d0                	mov    %edx,%eax
f0102be9:	c1 e8 0c             	shr    $0xc,%eax
f0102bec:	3b 05 70 98 2a f0    	cmp    0xf02a9870,%eax
f0102bf2:	72 20                	jb     f0102c14 <i386_vm_init+0xd7f>
f0102bf4:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102bf8:	c7 44 24 08 c8 ad 10 	movl   $0xf010adc8,0x8(%esp)
f0102bff:	f0 
f0102c00:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0102c07:	00 
f0102c08:	c7 04 24 4f b7 10 f0 	movl   $0xf010b74f,(%esp)
f0102c0f:	e8 72 d4 ff ff       	call   f0100086 <_panic>
	
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102c14:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c1b:	00 
f0102c1c:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102c23:	00 

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0102c24:	8d 82 00 00 00 f0    	lea    0xf0000000(%edx),%eax
f0102c2a:	89 04 24             	mov    %eax,(%esp)
f0102c2d:	e8 7f 6b 00 00       	call   f01097b1 <memset>
	page_free(pp0);
f0102c32:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0102c35:	89 04 24             	mov    %eax,(%esp)
f0102c38:	e8 3b e4 ff ff       	call   f0101078 <page_free>
	pgdir_walk(boot_pgdir, 0x0, 1);
f0102c3d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102c44:	00 
f0102c45:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102c4c:	00 
f0102c4d:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f0102c52:	89 04 24             	mov    %eax,(%esp)
f0102c55:	e8 93 e6 ff ff       	call   f01012ed <pgdir_walk>

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0102c5a:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0102c5d:	2b 05 7c 98 2a f0    	sub    0xf02a987c,%eax
f0102c63:	c1 f8 02             	sar    $0x2,%eax
f0102c66:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102c6c:	89 c2                	mov    %eax,%edx
f0102c6e:	c1 e2 0c             	shl    $0xc,%edx
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
		panic("pa2page called with invalid pa");
	return &pages[PPN(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0102c71:	89 d0                	mov    %edx,%eax
f0102c73:	c1 e8 0c             	shr    $0xc,%eax
f0102c76:	3b 05 70 98 2a f0    	cmp    0xf02a9870,%eax
f0102c7c:	72 20                	jb     f0102c9e <i386_vm_init+0xe09>
f0102c7e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102c82:	c7 44 24 08 c8 ad 10 	movl   $0xf010adc8,0x8(%esp)
f0102c89:	f0 
f0102c8a:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0102c91:	00 
f0102c92:	c7 04 24 4f b7 10 f0 	movl   $0xf010b74f,(%esp)
f0102c99:	e8 e8 d3 ff ff       	call   f0100086 <_panic>
f0102c9e:	8d 82 00 00 00 f0    	lea    0xf0000000(%edx),%eax
f0102ca4:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
f0102ca7:	b8 00 00 00 00       	mov    $0x0,%eax
	ptep = page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102cac:	f6 84 82 00 00 00 f0 	testb  $0x1,0xf0000000(%edx,%eax,4)
f0102cb3:	01 
f0102cb4:	74 24                	je     f0102cda <i386_vm_init+0xe45>
f0102cb6:	c7 44 24 0c 55 b9 10 	movl   $0xf010b955,0xc(%esp)
f0102cbd:	f0 
f0102cbe:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102cc5:	f0 
f0102cc6:	c7 44 24 04 d6 03 00 	movl   $0x3d6,0x4(%esp)
f0102ccd:	00 
f0102cce:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102cd5:	e8 ac d3 ff ff       	call   f0100086 <_panic>
f0102cda:	83 c0 01             	add    $0x1,%eax
f0102cdd:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102ce2:	75 c8                	jne    f0102cac <i386_vm_init+0xe17>
	boot_pgdir[0] = 0;
f0102ce4:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f0102ce9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102cef:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0102cf2:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)

	// give free list back
	page_free_list = fl;
f0102cf8:	89 35 b8 88 2a f0    	mov    %esi,0xf02a88b8

	// free the pages we took
	page_free(pp0);
f0102cfe:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0102d01:	89 04 24             	mov    %eax,(%esp)
f0102d04:	e8 6f e3 ff ff       	call   f0101078 <page_free>
	page_free(pp1);
f0102d09:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f0102d0c:	89 04 24             	mov    %eax,(%esp)
f0102d0f:	e8 64 e3 ff ff       	call   f0101078 <page_free>
	page_free(pp2);
f0102d14:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
f0102d17:	89 04 24             	mov    %eax,(%esp)
f0102d1a:	e8 59 e3 ff ff       	call   f0101078 <page_free>
	
	cprintf("page_check() succeeded!\n");
f0102d1f:	c7 04 24 6c b9 10 f0 	movl   $0xf010b96c,(%esp)
f0102d26:	e8 0c 0d 00 00       	call   f0103a37 <cprintf>
f0102d2b:	a1 7c 98 2a f0       	mov    0xf02a987c,%eax
f0102d30:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d35:	77 20                	ja     f0102d57 <i386_vm_init+0xec2>
f0102d37:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d3b:	c7 44 24 08 4c b1 10 	movl   $0xf010b14c,0x8(%esp)
f0102d42:	f0 
f0102d43:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
f0102d4a:	00 
f0102d4b:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102d52:	e8 2f d3 ff ff       	call   f0100086 <_panic>
f0102d57:	8b 0d 70 98 2a f0    	mov    0xf02a9870,%ecx
f0102d5d:	8d 0c 49             	lea    (%ecx,%ecx,2),%ecx
f0102d60:	c1 e1 02             	shl    $0x2,%ecx
f0102d63:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102d6a:	00 
f0102d6b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d70:	89 04 24             	mov    %eax,(%esp)
f0102d73:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102d78:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f0102d7d:	e8 b2 e8 ff ff       	call   f0101634 <boot_map_segment>
f0102d82:	a1 c0 88 2a f0       	mov    0xf02a88c0,%eax
f0102d87:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d8c:	77 20                	ja     f0102dae <i386_vm_init+0xf19>
f0102d8e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d92:	c7 44 24 08 4c b1 10 	movl   $0xf010b14c,0x8(%esp)
f0102d99:	f0 
f0102d9a:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
f0102da1:	00 
f0102da2:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102da9:	e8 d8 d2 ff ff       	call   f0100086 <_panic>
f0102dae:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102db5:	00 
f0102db6:	05 00 00 00 10       	add    $0x10000000,%eax
f0102dbb:	89 04 24             	mov    %eax,(%esp)
f0102dbe:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102dc3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102dc8:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f0102dcd:	e8 62 e8 ff ff       	call   f0101634 <boot_map_segment>
f0102dd2:	b8 00 90 12 f0       	mov    $0xf0129000,%eax
f0102dd7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ddc:	77 20                	ja     f0102dfe <i386_vm_init+0xf69>
f0102dde:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102de2:	c7 44 24 08 4c b1 10 	movl   $0xf010b14c,0x8(%esp)
f0102de9:	f0 
f0102dea:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
f0102df1:	00 
f0102df2:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102df9:	e8 88 d2 ff ff       	call   f0100086 <_panic>
f0102dfe:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102e05:	00 
f0102e06:	05 00 00 00 10       	add    $0x10000000,%eax
f0102e0b:	89 04 24             	mov    %eax,(%esp)
f0102e0e:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102e13:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f0102e18:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f0102e1d:	e8 12 e8 ff ff       	call   f0101634 <boot_map_segment>
f0102e22:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102e29:	00 
f0102e2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102e31:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102e36:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102e3b:	a1 78 98 2a f0       	mov    0xf02a9878,%eax
f0102e40:	e8 ef e7 ff ff       	call   f0101634 <boot_map_segment>
f0102e45:	8b 3d 78 98 2a f0    	mov    0xf02a9878,%edi
f0102e4b:	a1 70 98 2a f0       	mov    0xf02a9870,%eax
f0102e50:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102e53:	8d 04 85 ff 0f 00 00 	lea    0xfff(,%eax,4),%eax
f0102e5a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102e5f:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
f0102e62:	0f 84 e1 02 00 00    	je     f0103149 <i386_vm_init+0x12b4>
f0102e68:	be 00 00 00 00       	mov    $0x0,%esi
f0102e6d:	8d 96 00 00 00 ef    	lea    0xef000000(%esi),%edx
f0102e73:	89 f8                	mov    %edi,%eax
f0102e75:	e8 b4 e3 ff ff       	call   f010122e <check_va2pa>
f0102e7a:	89 c2                	mov    %eax,%edx
f0102e7c:	a1 7c 98 2a f0       	mov    0xf02a987c,%eax
f0102e81:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e86:	77 20                	ja     f0102ea8 <i386_vm_init+0x1013>
f0102e88:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102e8c:	c7 44 24 08 4c b1 10 	movl   $0xf010b14c,0x8(%esp)
f0102e93:	f0 
f0102e94:	c7 44 24 04 88 01 00 	movl   $0x188,0x4(%esp)
f0102e9b:	00 
f0102e9c:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102ea3:	e8 de d1 ff ff       	call   f0100086 <_panic>
f0102ea8:	8d 84 30 00 00 00 10 	lea    0x10000000(%eax,%esi,1),%eax
f0102eaf:	39 c2                	cmp    %eax,%edx
f0102eb1:	74 24                	je     f0102ed7 <i386_vm_init+0x1042>
f0102eb3:	c7 44 24 0c 1c b6 10 	movl   $0xf010b61c,0xc(%esp)
f0102eba:	f0 
f0102ebb:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102ec2:	f0 
f0102ec3:	c7 44 24 04 88 01 00 	movl   $0x188,0x4(%esp)
f0102eca:	00 
f0102ecb:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102ed2:	e8 af d1 ff ff       	call   f0100086 <_panic>
f0102ed7:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102edd:	39 75 d0             	cmp    %esi,0xffffffd0(%ebp)
f0102ee0:	0f 86 63 02 00 00    	jbe    f0103149 <i386_vm_init+0x12b4>
f0102ee6:	eb 85                	jmp    f0102e6d <i386_vm_init+0xfd8>
f0102ee8:	8d 96 00 00 c0 ee    	lea    0xeec00000(%esi),%edx
f0102eee:	89 f8                	mov    %edi,%eax
f0102ef0:	e8 39 e3 ff ff       	call   f010122e <check_va2pa>
f0102ef5:	89 c2                	mov    %eax,%edx
f0102ef7:	a1 c0 88 2a f0       	mov    0xf02a88c0,%eax
f0102efc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102f01:	77 20                	ja     f0102f23 <i386_vm_init+0x108e>
f0102f03:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102f07:	c7 44 24 08 4c b1 10 	movl   $0xf010b14c,0x8(%esp)
f0102f0e:	f0 
f0102f0f:	c7 44 24 04 8d 01 00 	movl   $0x18d,0x4(%esp)
f0102f16:	00 
f0102f17:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102f1e:	e8 63 d1 ff ff       	call   f0100086 <_panic>
f0102f23:	8d 84 30 00 00 00 10 	lea    0x10000000(%eax,%esi,1),%eax
f0102f2a:	39 c2                	cmp    %eax,%edx
f0102f2c:	74 24                	je     f0102f52 <i386_vm_init+0x10bd>
f0102f2e:	c7 44 24 0c 50 b6 10 	movl   $0xf010b650,0xc(%esp)
f0102f35:	f0 
f0102f36:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102f3d:	f0 
f0102f3e:	c7 44 24 04 8d 01 00 	movl   $0x18d,0x4(%esp)
f0102f45:	00 
f0102f46:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102f4d:	e8 34 d1 ff ff       	call   f0100086 <_panic>
f0102f52:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102f58:	81 fe 00 f0 01 00    	cmp    $0x1f000,%esi
f0102f5e:	75 88                	jne    f0102ee8 <i386_vm_init+0x1053>
f0102f60:	a1 70 98 2a f0       	mov    0xf02a9870,%eax
f0102f65:	c1 e0 0c             	shl    $0xc,%eax
f0102f68:	85 c0                	test   %eax,%eax
f0102f6a:	0f 84 e3 01 00 00    	je     f0103153 <i386_vm_init+0x12be>
f0102f70:	be 00 00 00 00       	mov    $0x0,%esi
f0102f75:	8d 96 00 00 00 f0    	lea    0xf0000000(%esi),%edx
f0102f7b:	89 f8                	mov    %edi,%eax
f0102f7d:	e8 ac e2 ff ff       	call   f010122e <check_va2pa>
f0102f82:	39 f0                	cmp    %esi,%eax
f0102f84:	74 24                	je     f0102faa <i386_vm_init+0x1115>
f0102f86:	c7 44 24 0c 84 b6 10 	movl   $0xf010b684,0xc(%esp)
f0102f8d:	f0 
f0102f8e:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102f95:	f0 
f0102f96:	c7 44 24 04 91 01 00 	movl   $0x191,0x4(%esp)
f0102f9d:	00 
f0102f9e:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102fa5:	e8 dc d0 ff ff       	call   f0100086 <_panic>
f0102faa:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
f0102fb0:	a1 70 98 2a f0       	mov    0xf02a9870,%eax
f0102fb5:	c1 e0 0c             	shl    $0xc,%eax
f0102fb8:	39 f0                	cmp    %esi,%eax
f0102fba:	0f 86 93 01 00 00    	jbe    f0103153 <i386_vm_init+0x12be>
f0102fc0:	eb b3                	jmp    f0102f75 <i386_vm_init+0x10e0>
f0102fc2:	89 f2                	mov    %esi,%edx
f0102fc4:	89 f8                	mov    %edi,%eax
f0102fc6:	e8 63 e2 ff ff       	call   f010122e <check_va2pa>
f0102fcb:	8d 96 00 10 53 10    	lea    0x10531000(%esi),%edx
f0102fd1:	39 c2                	cmp    %eax,%edx
f0102fd3:	74 24                	je     f0102ff9 <i386_vm_init+0x1164>
f0102fd5:	c7 44 24 0c ac b6 10 	movl   $0xf010b6ac,0xc(%esp)
f0102fdc:	f0 
f0102fdd:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0102fe4:	f0 
f0102fe5:	c7 44 24 04 95 01 00 	movl   $0x195,0x4(%esp)
f0102fec:	00 
f0102fed:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0102ff4:	e8 8d d0 ff ff       	call   f0100086 <_panic>
f0102ff9:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102fff:	81 fe 00 00 c0 ef    	cmp    $0xefc00000,%esi
f0103005:	75 bb                	jne    f0102fc2 <i386_vm_init+0x112d>
f0103007:	ba 00 00 80 ef       	mov    $0xef800000,%edx
f010300c:	89 f8                	mov    %edi,%eax
f010300e:	e8 1b e2 ff ff       	call   f010122e <check_va2pa>
f0103013:	ba 00 00 00 00       	mov    $0x0,%edx
f0103018:	83 f8 ff             	cmp    $0xffffffff,%eax
f010301b:	74 24                	je     f0103041 <i386_vm_init+0x11ac>
f010301d:	c7 44 24 0c f4 b6 10 	movl   $0xf010b6f4,0xc(%esp)
f0103024:	f0 
f0103025:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f010302c:	f0 
f010302d:	c7 44 24 04 96 01 00 	movl   $0x196,0x4(%esp)
f0103034:	00 
f0103035:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f010303c:	e8 45 d0 ff ff       	call   f0100086 <_panic>
f0103041:	8d 82 45 fc ff ff    	lea    0xfffffc45(%edx),%eax
f0103047:	83 f8 04             	cmp    $0x4,%eax
f010304a:	77 2e                	ja     f010307a <i386_vm_init+0x11e5>
f010304c:	83 3c 97 00          	cmpl   $0x0,(%edi,%edx,4)
f0103050:	0f 85 80 00 00 00    	jne    f01030d6 <i386_vm_init+0x1241>
f0103056:	c7 44 24 0c 85 b9 10 	movl   $0xf010b985,0xc(%esp)
f010305d:	f0 
f010305e:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0103065:	f0 
f0103066:	c7 44 24 04 a0 01 00 	movl   $0x1a0,0x4(%esp)
f010306d:	00 
f010306e:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f0103075:	e8 0c d0 ff ff       	call   f0100086 <_panic>
f010307a:	81 fa bf 03 00 00    	cmp    $0x3bf,%edx
f0103080:	76 2a                	jbe    f01030ac <i386_vm_init+0x1217>
f0103082:	83 3c 97 00          	cmpl   $0x0,(%edi,%edx,4)
f0103086:	75 4e                	jne    f01030d6 <i386_vm_init+0x1241>
f0103088:	c7 44 24 0c 85 b9 10 	movl   $0xf010b985,0xc(%esp)
f010308f:	f0 
f0103090:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0103097:	f0 
f0103098:	c7 44 24 04 a4 01 00 	movl   $0x1a4,0x4(%esp)
f010309f:	00 
f01030a0:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f01030a7:	e8 da cf ff ff       	call   f0100086 <_panic>
f01030ac:	83 3c 97 00          	cmpl   $0x0,(%edi,%edx,4)
f01030b0:	74 24                	je     f01030d6 <i386_vm_init+0x1241>
f01030b2:	c7 44 24 0c 8e b9 10 	movl   $0xf010b98e,0xc(%esp)
f01030b9:	f0 
f01030ba:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f01030c1:	f0 
f01030c2:	c7 44 24 04 a6 01 00 	movl   $0x1a6,0x4(%esp)
f01030c9:	00 
f01030ca:	c7 04 24 43 b7 10 f0 	movl   $0xf010b743,(%esp)
f01030d1:	e8 b0 cf ff ff       	call   f0100086 <_panic>
f01030d6:	83 c2 01             	add    $0x1,%edx
f01030d9:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f01030df:	0f 85 5c ff ff ff    	jne    f0103041 <i386_vm_init+0x11ac>
f01030e5:	c7 04 24 24 b7 10 f0 	movl   $0xf010b724,(%esp)
f01030ec:	e8 46 09 00 00       	call   f0103a37 <cprintf>
f01030f1:	8b 83 00 0f 00 00    	mov    0xf00(%ebx),%eax
f01030f7:	89 03                	mov    %eax,(%ebx)

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01030f9:	a1 74 98 2a f0       	mov    0xf02a9874,%eax
f01030fe:	0f 22 d8             	mov    %eax,%cr3
f0103101:	0f 20 c0             	mov    %cr0,%eax
f0103104:	0d 2f 00 05 80       	or     $0x8005002f,%eax

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0103109:	83 e0 f3             	and    $0xfffffff3,%eax
f010310c:	0f 22 c0             	mov    %eax,%cr0
f010310f:	0f 01 15 50 13 13 f0 	lgdtl  0xf0131350
f0103116:	b8 23 00 00 00       	mov    $0x23,%eax
f010311b:	8e e8                	movl   %eax,%gs
f010311d:	8e e0                	movl   %eax,%fs
f010311f:	b0 10                	mov    $0x10,%al
f0103121:	8e c0                	movl   %eax,%es
f0103123:	8e d8                	movl   %eax,%ds
f0103125:	8e d0                	movl   %eax,%ss
f0103127:	ea 2e 31 10 f0 08 00 	ljmp   $0x8,$0xf010312e
f010312e:	b0 00                	mov    $0x0,%al
f0103130:	0f 00 d0             	lldt   %ax
f0103133:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103139:	a1 74 98 2a f0       	mov    0xf02a9874,%eax
f010313e:	0f 22 d8             	mov    %eax,%cr3
f0103141:	83 c4 3c             	add    $0x3c,%esp
f0103144:	5b                   	pop    %ebx
f0103145:	5e                   	pop    %esi
f0103146:	5f                   	pop    %edi
f0103147:	5d                   	pop    %ebp
f0103148:	c3                   	ret    
f0103149:	be 00 00 00 00       	mov    $0x0,%esi
f010314e:	e9 95 fd ff ff       	jmp    f0102ee8 <i386_vm_init+0x1053>
f0103153:	be 00 80 bf ef       	mov    $0xefbf8000,%esi
f0103158:	e9 65 fe ff ff       	jmp    f0102fc2 <i386_vm_init+0x112d>
f010315d:	00 00                	add    %al,(%eax)
	...

f0103160 <envid2env>:
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103160:	55                   	push   %ebp
f0103161:	89 e5                	mov    %esp,%ebp
f0103163:	53                   	push   %ebx
f0103164:	8b 55 08             	mov    0x8(%ebp),%edx
f0103167:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Env *e;
	//0代表当前对象
	// If envid is zero, return the current environment.
	if (envid == 0) {
f010316a:	85 d2                	test   %edx,%edx
f010316c:	75 0e                	jne    f010317c <envid2env+0x1c>
		*env_store = curenv;
f010316e:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0103173:	89 03                	mov    %eax,(%ebx)
f0103175:	b8 00 00 00 00       	mov    $0x0,%eax
f010317a:	eb 56                	jmp    f01031d2 <envid2env+0x72>
		return 0;
	}

	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010317c:	89 d0                	mov    %edx,%eax
f010317e:	25 ff 03 00 00       	and    $0x3ff,%eax
f0103183:	6b c0 7c             	imul   $0x7c,%eax,%eax
f0103186:	89 c1                	mov    %eax,%ecx
f0103188:	03 0d c0 88 2a f0    	add    0xf02a88c0,%ecx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010318e:	83 79 54 00          	cmpl   $0x0,0x54(%ecx)
f0103192:	74 05                	je     f0103199 <envid2env+0x39>
f0103194:	39 51 4c             	cmp    %edx,0x4c(%ecx)
f0103197:	74 0d                	je     f01031a6 <envid2env+0x46>
		*env_store = 0;
f0103199:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
f010319f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01031a4:	eb 2c                	jmp    f01031d2 <envid2env+0x72>
		return -E_BAD_ENV;
	}

	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01031a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01031aa:	74 1f                	je     f01031cb <envid2env+0x6b>
f01031ac:	8b 15 c4 88 2a f0    	mov    0xf02a88c4,%edx
f01031b2:	39 d1                	cmp    %edx,%ecx
f01031b4:	74 15                	je     f01031cb <envid2env+0x6b>
f01031b6:	8b 41 50             	mov    0x50(%ecx),%eax
f01031b9:	3b 42 4c             	cmp    0x4c(%edx),%eax
f01031bc:	74 0d                	je     f01031cb <envid2env+0x6b>
		*env_store = 0;
f01031be:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
f01031c4:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01031c9:	eb 07                	jmp    f01031d2 <envid2env+0x72>
		return -E_BAD_ENV;
	}

	*env_store = e;
f01031cb:	89 0b                	mov    %ecx,(%ebx)
f01031cd:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f01031d2:	5b                   	pop    %ebx
f01031d3:	5d                   	pop    %ebp
f01031d4:	c3                   	ret    

f01031d5 <env_init>:

//
// Mark all environments in 'envs' as free, set their env_ids to 0,
// and insert them into the env_free_list.
// Insert in reverse order, so that the first call to env_alloc()
// returns envs[0].
//
void
env_init(void)
{
f01031d5:	55                   	push   %ebp
f01031d6:	89 e5                	mov    %esp,%ebp
f01031d8:	53                   	push   %ebx
	// LAB 3: Your code here.
	int i;
	LIST_INIT(&env_free_list);
f01031d9:	c7 05 c8 88 2a f0 00 	movl   $0x0,0xf02a88c8
f01031e0:	00 00 00 
f01031e3:	b9 84 ef 01 00       	mov    $0x1ef84,%ecx
f01031e8:	89 cb                	mov    %ecx,%ebx
	for(i=NENV-1;i>=0;i--)
	{
		envs[i].env_id=0;
f01031ea:	a1 c0 88 2a f0       	mov    0xf02a88c0,%eax
f01031ef:	c7 44 08 4c 00 00 00 	movl   $0x0,0x4c(%eax,%ecx,1)
f01031f6:	00 
		envs[i].env_status=ENV_FREE;
f01031f7:	a1 c0 88 2a f0       	mov    0xf02a88c0,%eax
f01031fc:	c7 44 08 54 00 00 00 	movl   $0x0,0x54(%eax,%ecx,1)
f0103203:	00 
		LIST_INSERT_HEAD(&env_free_list,&envs[i],env_link);	
f0103204:	8b 15 c8 88 2a f0    	mov    0xf02a88c8,%edx
f010320a:	a1 c0 88 2a f0       	mov    0xf02a88c0,%eax
f010320f:	89 54 08 44          	mov    %edx,0x44(%eax,%ecx,1)
f0103213:	85 d2                	test   %edx,%edx
f0103215:	74 14                	je     f010322b <env_init+0x56>
f0103217:	89 c8                	mov    %ecx,%eax
f0103219:	03 05 c0 88 2a f0    	add    0xf02a88c0,%eax
f010321f:	83 c0 44             	add    $0x44,%eax
f0103222:	8b 15 c8 88 2a f0    	mov    0xf02a88c8,%edx
f0103228:	89 42 48             	mov    %eax,0x48(%edx)
f010322b:	89 d8                	mov    %ebx,%eax
f010322d:	03 05 c0 88 2a f0    	add    0xf02a88c0,%eax
f0103233:	a3 c8 88 2a f0       	mov    %eax,0xf02a88c8
f0103238:	c7 40 48 c8 88 2a f0 	movl   $0xf02a88c8,0x48(%eax)
f010323f:	83 e9 7c             	sub    $0x7c,%ecx
f0103242:	83 f9 84             	cmp    $0xffffff84,%ecx
f0103245:	75 a1                	jne    f01031e8 <env_init+0x13>
	}
}
f0103247:	5b                   	pop    %ebx
f0103248:	5d                   	pop    %ebp
f0103249:	c3                   	ret    

f010324a <env_pop_tf>:

//
// Initialize the kernel virtual memory layout for environment e.
// Allocate a page directory, set e->env_pgdir and e->env_cr3 accordingly,
// and initialize the kernel portion of the new environment's address space.
// Do NOT (yet) map anything into the user portion
// of the environment's virtual address space.
//
// Returns 0 on success, < 0 on error.  Errors include:
//	-E_NO_MEM if page directory or table could not be allocated.
//
static int
env_setup_vm(struct Env *e)
{
	int i, r;
	struct Page *p = NULL;
	
	// Allocate a page for the page directory
	if ((r = page_alloc(&p)) < 0)
		return r;

	// Now, set e->env_pgdir and e->env_cr3,
	// and initialize the page directory.
	//
	// Hint:
	//    - Remember that page_alloc doesn't zero the page.
	//    - The VA space of all envs is identical above UTOP
	//	(except at VPT and UVPT, which we've set below).
	//	See inc/memlayout.h for permissions and layout.
	//	Can you use boot_pgdir as a template?  Hint: Yes.
	//	(Make sure you got the permissions right in Lab 2.)
	//    - The initial VA below UTOP is empty.
	//    - You do not need to make any more calls to page_alloc.
	//    - Note: In general, pp_ref is not maintained for
	//	physical pages mapped only above UTOP, but env_pgdir
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_cr3=page2pa(p);//每个进程有自己的页目录表
	e->env_pgdir=(pde_t*)page2kva(p);

	p->pp_ref++;
	memset(e->env_pgdir,0,PGSIZE);//initialize env's pgdir

	for(i=PDX(UTOP);i<NPDENTRIES;i++)//内核部分映射，直接从boot_pgdir拷贝
		e->env_pgdir[i]=boot_pgdir[i];
	// VPT and UVPT map the env's own page table, with
	// different permissions.
	e->env_pgdir[PDX(VPT)]  = e->env_cr3 | PTE_P | PTE_W;
	e->env_pgdir[PDX(UVPT)] = e->env_cr3 | PTE_P | PTE_U;

	return 0;
}

//
// Allocates and initializes a new environment.
// On success, the new environment is stored in *newenv_store.
//
// Returns 0 on success, < 0 on failure.  Errors include:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = LIST_FIRST(&env_free_list)))
		return -E_NO_FREE_ENV;
	//为进程分配一个物理页面作为页目录表，并设置该页目录表和相关页表
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
	if (generation <= 0)	// Don't create a negative env_id.
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
	
	// Set the basic status variables.
	e->env_parent_id = parent_id;
	e->env_status = ENV_RUNNABLE;
	e->env_runs = 0;

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	//清空进程的上下文
	memset(&e->env_tf, 0, sizeof(e->env_tf));

	// Set up appropriate initial values for the segment registers.
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.
	e->env_tf.tf_ds = GD_UD | 3;//初始化段寄存器
	e->env_tf.tf_es = GD_UD | 3;
	e->env_tf.tf_ss = GD_UD | 3;
	e->env_tf.tf_esp = USTACKTOP;//初始化用户态栈顶指针
	e->env_tf.tf_cs = GD_UT | 3;
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags|=FL_IF;
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;

	// If this is the file server (e == &envs[1]) give it I/O privileges.
	// LAB 5: Your code here.
	if(e==&envs[1])
		e->env_tf.tf_eflags|=FL_IOPL_3;
	// commit the allocation
	LIST_REMOVE(e, env_link);
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}

//
// Allocate len bytes of physical memory for environment env,
// and map it at virtual address va in the environment's address space.
// Does not zero or otherwise initialize the mapped pages in any way.
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
segment_alloc(struct Env *e, void *va, size_t len)
{
	// LAB 3: Your code here.
	// (But only if you need it for load_icode.)
	//
	// Hint: It is easier to use segment_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	uintptr_t a,last;
	struct Page *onepage;
	a=ROUNDDOWN((physaddr_t)va,PGSIZE);
	last=ROUNDDOWN((physaddr_t)(va+len),PGSIZE);
	for(;;){
		if(page_alloc(&onepage)<0)
			panic("Alloc physical page failed!\n");
		//cprintf("segment_alloc:onepage physaddr=%x\n",page2pa(onepage));
		if(page_insert(e->env_pgdir,onepage,(void*)a,PTE_U|PTE_W)<0)
			panic("Insert page failed!\n");
		if(a==last) break;
		a=a+PGSIZE;
	}
}

//
// Set up the initial program binary, stack, and processor flags
// for a user process.
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
//
// This function loads all loadable segments from the ELF binary image
// into the environment's user memory, starting at the appropriate
// virtual addresses indicated in the ELF program header.
// At the same time it clears to zero any portions of these segments
// that are marked in the program header as being mapped
// but not actually present in the ELF file - i.e., the program's bss section.
//
// All this is very similar to what our boot loader does, except the boot
// loader also needs to read the code from disk.  Take a look at
// boot/main.c to get ideas.
//
// Finally, this function maps one page for the program's initial stack.
//
// load_icode panics if it encounters problems.
//  - How might load_icode fail?  What might be wrong with the given input?
//
static void
load_icode(struct Env *e, uint8_t *binary, size_t size)
{
	// Hints: 
	//  Load each program segment into virtual memory
	//  at the address specified in the ELF section header.
	//  You should only load segments with ph->p_type == ELF_PROG_LOAD.
	//  Each segment's virtual address can be found in ph->p_va
	//  and its size in memory can be found in ph->p_memsz.
	//  The ph->p_filesz bytes from the ELF binary, starting at
	//  'binary + ph->p_offset', should be copied to virtual address
	//  ph->p_va.  Any remaining memory bytes should be cleared to zero.
	//  (The ELF header should have ph->p_filesz <= ph->p_memsz.)
	//  Use functions from the previous lab to allocate and map pages.
	//
	//  All page protection bits should be user read/write for now.
	//  ELF segments are not necessarily page-aligned, but you can
	//  assume for this function that no two segments will touch
	//  the same virtual page.
	//
	//  You may find a function like segment_alloc useful.
	//
	//  Loading the segments is much simpler if you can move data
	//  directly into the virtual addresses stored in the ELF binary.
	//  So which page directory should be in force during
	//  this function?
	//
	//  You must also do something with the program's entry point,
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	physaddr_t old_cr3;
	struct Elf *elfhdr;
	struct Proghdr *ph,*eph;
	struct Page *onepage;
	
	old_cr3=rcr3();//要在新环境中加载用户程序，所以必须切换到新环境的页目录
	lcr3(e->env_cr3);
	elfhdr=(struct Elf*)binary;

	if(elfhdr->e_magic!=ELF_MAGIC)
		panic("This binary is not ELF format!\n");
	ph = (struct Proghdr*)(binary+elfhdr->e_phoff);
	                /*e_phoff：程序头部表格的偏移量*/
	eph = ph+elfhdr->e_phnum;/*e_phnum：程序头部表格的表项数目*/
	for(;ph<eph;ph++){       /*程序头部：描述与程序执行直接相关的目标文件结构信息。
				  *用来在文件中定位各个段的映像。
				  */
		if(ph->p_type == ELF_PROG_LOAD)
		{
			segment_alloc(e,(void*)ph->p_va,ph->p_memsz);
			//cprintf("p_va=%x binary+p_offset=%x filesz=%x memsz=%x\n",ph->p_va,binary+ph->p_offset,ph->p_filesz,ph->p_memsz);
			/*如果p_memsz大于p_filesz，剩余的字节要清零。p_filesz不能大于p_memsz*/
			memset((void*)(ph->p_va+ph->p_filesz),0,ph->p_memsz-ph->p_filesz);
			memmove((void*)ph->p_va,(void*)(binary+ph->p_offset),ph->p_filesz);	
		}
	} 
	//cprintf("memsize=%x filesize=%x\n",ph->p_memsz,ph->p_filesz);
	//cprintf("e_entry=%x\n",elfhdr->e_entry);
	e->env_tf.tf_eip=elfhdr->e_entry;//用户态进程的第一条指令地址保存在e->env_tf.tf_eip中
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	if(page_alloc(&onepage)<0)
              panic("Alloc one page in load_icode failed\n");
        if(page_insert(e->env_pgdir,onepage,(void*)(USTACKTOP-PGSIZE),PTE_U|PTE_W)<0)
              panic("Insert one page in load_icode failed\n");
	memset((void*)(USTACKTOP-PGSIZE),0,PGSIZE);
	lcr3(old_cr3);//加载完毕后，切回到原来页目录
}

//
// Allocates a new env with env_alloc and loads the named elf
// binary into it with load_icode.
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//由JOS内核创建用户进程
void
env_create(uint8_t *binary, size_t size)
{
	// LAB 3: Your code here.
	int r;
	struct Env *newenv;
	if((r=env_alloc(&newenv,0))<0)
		panic("env_create:%e",r);
	load_icode(newenv,binary,size);
}

//
// Frees env e and all memory it uses.
// 
void
env_free(struct Env *e)
{
	pte_t *pt;
	uint32_t pdeno, pteno;
	physaddr_t pa;
	
	// If freeing the current environment, switch to boot_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
		lcr3(boot_cr3);

	// Note the environment's demise.
	//cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = e->env_cr3;
	e->env_pgdir = 0;
	e->env_cr3 = 0;
	page_decref(pa2page(pa));

	// return the environment to the free list
	e->env_status = ENV_FREE;
	LIST_INSERT_HEAD(&env_free_list, e, env_link);
}

//
// Frees environment e.
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) 
{
	env_free(e);

	if (curenv == e) {
		curenv = NULL;
		sched_yield();
	}
}


//
// Restores the register values in the Trapframe with the 'iret' instruction.
// This exits the kernel and starts executing some environment's code.
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010324a:	55                   	push   %ebp
f010324b:	89 e5                	mov    %esp,%ebp
f010324d:	83 ec 18             	sub    $0x18,%esp
f0103250:	8b 45 08             	mov    0x8(%ebp),%eax
	__asm __volatile("movl %0,%%esp\n"
f0103253:	89 c4                	mov    %eax,%esp
f0103255:	61                   	popa   
f0103256:	07                   	pop    %es
f0103257:	1f                   	pop    %ds
f0103258:	83 c4 08             	add    $0x8,%esp
f010325b:	cf                   	iret   
		"\tpopal\n"
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010325c:	c7 44 24 08 9c b9 10 	movl   $0xf010b99c,0x8(%esp)
f0103263:	f0 
f0103264:	c7 44 24 04 bf 01 00 	movl   $0x1bf,0x4(%esp)
f010326b:	00 
f010326c:	c7 04 24 a8 b9 10 f0 	movl   $0xf010b9a8,(%esp)
f0103273:	e8 0e ce ff ff       	call   f0100086 <_panic>

f0103278 <env_run>:
}

//
// Context switch from curenv to env e.
// Note: if this is the first call to env_run, curenv is NULL.
//
// This function does not return.
//JOS内核启动一个进程，并切换到用户态，运行该进程
void
env_run(struct Env *e)
{
f0103278:	55                   	push   %ebp
f0103279:	89 e5                	mov    %esp,%ebp
f010327b:	83 ec 18             	sub    $0x18,%esp
f010327e:	8b 45 08             	mov    0x8(%ebp),%eax
	// Step 1: If this is a context switch (a new environment is running),
	//	   then set 'curenv' to the new environment,
	//	   update its 'env_runs' counter, and
	//	   and use lcr3() to switch to its address space.
	// Step 2: Use env_pop_tf() to restore the environment's
	//	   registers and drop into user mode in the
	//	   environment.

	// Hint: This function loads the new environment's state from
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.
	
	// LAB 3: Your code here.
	if(e==NULL)
f0103281:	85 c0                	test   %eax,%eax
f0103283:	75 1c                	jne    f01032a1 <env_run+0x29>
	{
		panic("This is bad env,panic in env_run");
f0103285:	c7 44 24 08 f4 b9 10 	movl   $0xf010b9f4,0x8(%esp)
f010328c:	f0 
f010328d:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
f0103294:	00 
f0103295:	c7 04 24 a8 b9 10 f0 	movl   $0xf010b9a8,(%esp)
f010329c:	e8 e5 cd ff ff       	call   f0100086 <_panic>
	}
	if(e!=curenv)//如果e指向当前进程，就不需要切换地址空间，lcr3会刷新TLB
f01032a1:	3b 05 c4 88 2a f0    	cmp    0xf02a88c4,%eax
f01032a7:	74 0b                	je     f01032b4 <env_run+0x3c>
	{
		curenv=e;
f01032a9:	a3 c4 88 2a f0       	mov    %eax,0xf02a88c4

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01032ae:	8b 40 60             	mov    0x60(%eax),%eax
f01032b1:	0f 22 d8             	mov    %eax,%cr3
		lcr3(curenv->env_cr3);//切换到进程的地址空间
	}
	curenv->env_runs++;
f01032b4:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f01032b9:	83 40 58 01          	addl   $0x1,0x58(%eax)
	//cprintf("\nenv_run:curenvid=%x\n",curenv->env_id);
	env_pop_tf(&curenv->env_tf);
f01032bd:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f01032c2:	89 04 24             	mov    %eax,(%esp)
f01032c5:	e8 80 ff ff ff       	call   f010324a <env_pop_tf>

f01032ca <env_alloc>:
f01032ca:	55                   	push   %ebp
f01032cb:	89 e5                	mov    %esp,%ebp
f01032cd:	53                   	push   %ebx
f01032ce:	83 ec 24             	sub    $0x24,%esp
f01032d1:	8b 1d c8 88 2a f0    	mov    0xf02a88c8,%ebx
f01032d7:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01032dc:	85 db                	test   %ebx,%ebx
f01032de:	0f 84 9e 01 00 00    	je     f0103482 <env_alloc+0x1b8>
f01032e4:	c7 45 f8 00 00 00 00 	movl   $0x0,0xfffffff8(%ebp)
f01032eb:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
f01032ee:	89 04 24             	mov    %eax,(%esp)
f01032f1:	e8 a2 df ff ff       	call   f0101298 <page_alloc>
f01032f6:	85 c0                	test   %eax,%eax
f01032f8:	0f 88 84 01 00 00    	js     f0103482 <env_alloc+0x1b8>
f01032fe:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
f0103301:	2b 05 7c 98 2a f0    	sub    0xf02a987c,%eax
f0103307:	c1 f8 02             	sar    $0x2,%eax
f010330a:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103310:	c1 e0 0c             	shl    $0xc,%eax
f0103313:	89 43 60             	mov    %eax,0x60(%ebx)

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0103316:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
f0103319:	2b 05 7c 98 2a f0    	sub    0xf02a987c,%eax
f010331f:	c1 f8 02             	sar    $0x2,%eax
f0103322:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103328:	89 c2                	mov    %eax,%edx
f010332a:	c1 e2 0c             	shl    $0xc,%edx
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
		panic("pa2page called with invalid pa");
	return &pages[PPN(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f010332d:	89 d0                	mov    %edx,%eax
f010332f:	c1 e8 0c             	shr    $0xc,%eax
f0103332:	3b 05 70 98 2a f0    	cmp    0xf02a9870,%eax
f0103338:	72 20                	jb     f010335a <env_alloc+0x90>
f010333a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010333e:	c7 44 24 08 c8 ad 10 	movl   $0xf010adc8,0x8(%esp)
f0103345:	f0 
f0103346:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f010334d:	00 
f010334e:	c7 04 24 4f b7 10 f0 	movl   $0xf010b74f,(%esp)
f0103355:	e8 2c cd ff ff       	call   f0100086 <_panic>
f010335a:	8d 82 00 00 00 f0    	lea    0xf0000000(%edx),%eax
f0103360:	89 43 5c             	mov    %eax,0x5c(%ebx)
f0103363:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
f0103366:	66 83 40 08 01       	addw   $0x1,0x8(%eax)
f010336b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103372:	00 
f0103373:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010337a:	00 
f010337b:	8b 43 5c             	mov    0x5c(%ebx),%eax
f010337e:	89 04 24             	mov    %eax,(%esp)
f0103381:	e8 2b 64 00 00       	call   f01097b1 <memset>
f0103386:	b9 ec 0e 00 00       	mov    $0xeec,%ecx
f010338b:	8b 43 5c             	mov    0x5c(%ebx),%eax
f010338e:	8b 15 78 98 2a f0    	mov    0xf02a9878,%edx
f0103394:	8b 14 0a             	mov    (%edx,%ecx,1),%edx
f0103397:	89 14 08             	mov    %edx,(%eax,%ecx,1)
f010339a:	83 c1 04             	add    $0x4,%ecx
f010339d:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
f01033a3:	75 e6                	jne    f010338b <env_alloc+0xc1>
f01033a5:	8b 53 5c             	mov    0x5c(%ebx),%edx
f01033a8:	8b 43 60             	mov    0x60(%ebx),%eax
f01033ab:	83 c8 03             	or     $0x3,%eax
f01033ae:	89 82 fc 0e 00 00    	mov    %eax,0xefc(%edx)
f01033b4:	8b 53 5c             	mov    0x5c(%ebx),%edx
f01033b7:	8b 43 60             	mov    0x60(%ebx),%eax
f01033ba:	83 c8 05             	or     $0x5,%eax
f01033bd:	89 82 f4 0e 00 00    	mov    %eax,0xef4(%edx)
f01033c3:	8b 43 4c             	mov    0x4c(%ebx),%eax
f01033c6:	05 00 10 00 00       	add    $0x1000,%eax
f01033cb:	89 c2                	mov    %eax,%edx
f01033cd:	81 e2 00 fc ff ff    	and    $0xfffffc00,%edx
f01033d3:	7f 05                	jg     f01033da <env_alloc+0x110>
f01033d5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01033da:	89 d8                	mov    %ebx,%eax
f01033dc:	2b 05 c0 88 2a f0    	sub    0xf02a88c0,%eax
f01033e2:	c1 f8 02             	sar    $0x2,%eax
f01033e5:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
f01033eb:	09 d0                	or     %edx,%eax
f01033ed:	89 43 4c             	mov    %eax,0x4c(%ebx)
f01033f0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01033f3:	89 43 50             	mov    %eax,0x50(%ebx)
f01033f6:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
f01033fd:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
f0103404:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f010340b:	00 
f010340c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103413:	00 
f0103414:	89 1c 24             	mov    %ebx,(%esp)
f0103417:	e8 95 63 00 00       	call   f01097b1 <memset>
f010341c:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
f0103422:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
f0103428:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
f010342e:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
f0103435:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
f010343b:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
f0103442:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
f0103449:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)
f0103450:	a1 c0 88 2a f0       	mov    0xf02a88c0,%eax
f0103455:	83 c0 7c             	add    $0x7c,%eax
f0103458:	39 d8                	cmp    %ebx,%eax
f010345a:	75 07                	jne    f0103463 <env_alloc+0x199>
f010345c:	81 4b 38 00 30 00 00 	orl    $0x3000,0x38(%ebx)
f0103463:	8b 53 44             	mov    0x44(%ebx),%edx
f0103466:	85 d2                	test   %edx,%edx
f0103468:	74 06                	je     f0103470 <env_alloc+0x1a6>
f010346a:	8b 43 48             	mov    0x48(%ebx),%eax
f010346d:	89 42 48             	mov    %eax,0x48(%edx)
f0103470:	8b 53 48             	mov    0x48(%ebx),%edx
f0103473:	8b 43 44             	mov    0x44(%ebx),%eax
f0103476:	89 02                	mov    %eax,(%edx)
f0103478:	8b 45 08             	mov    0x8(%ebp),%eax
f010347b:	89 18                	mov    %ebx,(%eax)
f010347d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103482:	83 c4 24             	add    $0x24,%esp
f0103485:	5b                   	pop    %ebx
f0103486:	5d                   	pop    %ebp
f0103487:	c3                   	ret    

f0103488 <env_create>:
f0103488:	55                   	push   %ebp
f0103489:	89 e5                	mov    %esp,%ebp
f010348b:	57                   	push   %edi
f010348c:	56                   	push   %esi
f010348d:	53                   	push   %ebx
f010348e:	83 ec 3c             	sub    $0x3c,%esp
f0103491:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103498:	00 
f0103499:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f010349c:	89 04 24             	mov    %eax,(%esp)
f010349f:	e8 26 fe ff ff       	call   f01032ca <env_alloc>
f01034a4:	85 c0                	test   %eax,%eax
f01034a6:	79 20                	jns    f01034c8 <env_create+0x40>
f01034a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01034ac:	c7 44 24 08 b3 b9 10 	movl   $0xf010b9b3,0x8(%esp)
f01034b3:	f0 
f01034b4:	c7 44 24 04 65 01 00 	movl   $0x165,0x4(%esp)
f01034bb:	00 
f01034bc:	c7 04 24 a8 b9 10 f0 	movl   $0xf010b9a8,(%esp)
f01034c3:	e8 be cb ff ff       	call   f0100086 <_panic>
f01034c8:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f01034cb:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
static __inline uint32_t
rcr3(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr3,%0" : "=r" (val));
f01034ce:	0f 20 da             	mov    %cr3,%edx
f01034d1:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
f01034d4:	8b 40 60             	mov    0x60(%eax),%eax
f01034d7:	0f 22 d8             	mov    %eax,%cr3
f01034da:	8b 45 08             	mov    0x8(%ebp),%eax
f01034dd:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
f01034e0:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f01034e6:	74 1c                	je     f0103504 <env_create+0x7c>
f01034e8:	c7 44 24 08 18 ba 10 	movl   $0xf010ba18,0x8(%esp)
f01034ef:	f0 
f01034f0:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
f01034f7:	00 
f01034f8:	c7 04 24 a8 b9 10 f0 	movl   $0xf010b9a8,(%esp)
f01034ff:	e8 82 cb ff ff       	call   f0100086 <_panic>
f0103504:	8b 75 08             	mov    0x8(%ebp),%esi
f0103507:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
f010350a:	03 72 1c             	add    0x1c(%edx),%esi
f010350d:	0f b7 42 2c          	movzwl 0x2c(%edx),%eax
f0103511:	c1 e0 05             	shl    $0x5,%eax
f0103514:	01 f0                	add    %esi,%eax
f0103516:	89 45 d4             	mov    %eax,0xffffffd4(%ebp)
f0103519:	39 c6                	cmp    %eax,%esi
f010351b:	0f 83 e9 00 00 00    	jae    f010360a <env_create+0x182>
f0103521:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
f0103524:	83 3e 01             	cmpl   $0x1,(%esi)
f0103527:	0f 85 d1 00 00 00    	jne    f01035fe <env_create+0x176>
f010352d:	8b 46 08             	mov    0x8(%esi),%eax
f0103530:	89 c3                	mov    %eax,%ebx
f0103532:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0103538:	03 46 14             	add    0x14(%esi),%eax
f010353b:	89 c7                	mov    %eax,%edi
f010353d:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0103543:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f0103546:	89 04 24             	mov    %eax,(%esp)
f0103549:	e8 4a dd ff ff       	call   f0101298 <page_alloc>
f010354e:	85 c0                	test   %eax,%eax
f0103550:	79 1c                	jns    f010356e <env_create+0xe6>
f0103552:	c7 44 24 08 c1 b9 10 	movl   $0xf010b9c1,0x8(%esp)
f0103559:	f0 
f010355a:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
f0103561:	00 
f0103562:	c7 04 24 a8 b9 10 f0 	movl   $0xf010b9a8,(%esp)
f0103569:	e8 18 cb ff ff       	call   f0100086 <_panic>
f010356e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103575:	00 
f0103576:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010357a:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f010357d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103581:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
f0103584:	8b 41 5c             	mov    0x5c(%ecx),%eax
f0103587:	89 04 24             	mov    %eax,(%esp)
f010358a:	e8 2a e1 ff ff       	call   f01016b9 <page_insert>
f010358f:	85 c0                	test   %eax,%eax
f0103591:	79 1c                	jns    f01035af <env_create+0x127>
f0103593:	c7 44 24 08 de b9 10 	movl   $0xf010b9de,0x8(%esp)
f010359a:	f0 
f010359b:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
f01035a2:	00 
f01035a3:	c7 04 24 a8 b9 10 f0 	movl   $0xf010b9a8,(%esp)
f01035aa:	e8 d7 ca ff ff       	call   f0100086 <_panic>
f01035af:	39 fb                	cmp    %edi,%ebx
f01035b1:	74 08                	je     f01035bb <env_create+0x133>
f01035b3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01035b9:	eb 88                	jmp    f0103543 <env_create+0xbb>
f01035bb:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
f01035be:	8b 50 10             	mov    0x10(%eax),%edx
f01035c1:	89 c1                	mov    %eax,%ecx
f01035c3:	8b 40 14             	mov    0x14(%eax),%eax
f01035c6:	29 d0                	sub    %edx,%eax
f01035c8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01035cc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01035d3:	00 
f01035d4:	03 51 08             	add    0x8(%ecx),%edx
f01035d7:	89 14 24             	mov    %edx,(%esp)
f01035da:	e8 d2 61 00 00       	call   f01097b1 <memset>
f01035df:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
f01035e2:	8b 42 10             	mov    0x10(%edx),%eax
f01035e5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01035e9:	8b 45 08             	mov    0x8(%ebp),%eax
f01035ec:	03 42 04             	add    0x4(%edx),%eax
f01035ef:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035f3:	8b 42 08             	mov    0x8(%edx),%eax
f01035f6:	89 04 24             	mov    %eax,(%esp)
f01035f9:	e8 0c 62 00 00       	call   f010980a <memmove>
f01035fe:	83 c6 20             	add    $0x20,%esi
f0103601:	39 75 d4             	cmp    %esi,0xffffffd4(%ebp)
f0103604:	0f 87 17 ff ff ff    	ja     f0103521 <env_create+0x99>
f010360a:	8b 4d d8             	mov    0xffffffd8(%ebp),%ecx
f010360d:	8b 41 18             	mov    0x18(%ecx),%eax
f0103610:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
f0103613:	89 42 30             	mov    %eax,0x30(%edx)
f0103616:	8d 45 ec             	lea    0xffffffec(%ebp),%eax
f0103619:	89 04 24             	mov    %eax,(%esp)
f010361c:	e8 77 dc ff ff       	call   f0101298 <page_alloc>
f0103621:	85 c0                	test   %eax,%eax
f0103623:	79 1c                	jns    f0103641 <env_create+0x1b9>
f0103625:	c7 44 24 08 38 ba 10 	movl   $0xf010ba38,0x8(%esp)
f010362c:	f0 
f010362d:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
f0103634:	00 
f0103635:	c7 04 24 a8 b9 10 f0 	movl   $0xf010b9a8,(%esp)
f010363c:	e8 45 ca ff ff       	call   f0100086 <_panic>
f0103641:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103648:	00 
f0103649:	c7 44 24 08 00 d0 bf 	movl   $0xeebfd000,0x8(%esp)
f0103650:	ee 
f0103651:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0103654:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103658:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
f010365b:	8b 41 5c             	mov    0x5c(%ecx),%eax
f010365e:	89 04 24             	mov    %eax,(%esp)
f0103661:	e8 53 e0 ff ff       	call   f01016b9 <page_insert>
f0103666:	85 c0                	test   %eax,%eax
f0103668:	79 1c                	jns    f0103686 <env_create+0x1fe>
f010366a:	c7 44 24 08 60 ba 10 	movl   $0xf010ba60,0x8(%esp)
f0103671:	f0 
f0103672:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
f0103679:	00 
f010367a:	c7 04 24 a8 b9 10 f0 	movl   $0xf010b9a8,(%esp)
f0103681:	e8 00 ca ff ff       	call   f0100086 <_panic>
f0103686:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010368d:	00 
f010368e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103695:	00 
f0103696:	c7 04 24 00 d0 bf ee 	movl   $0xeebfd000,(%esp)
f010369d:	e8 0f 61 00 00       	call   f01097b1 <memset>

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01036a2:	8b 45 d0             	mov    0xffffffd0(%ebp),%eax
f01036a5:	0f 22 d8             	mov    %eax,%cr3
f01036a8:	83 c4 3c             	add    $0x3c,%esp
f01036ab:	5b                   	pop    %ebx
f01036ac:	5e                   	pop    %esi
f01036ad:	5f                   	pop    %edi
f01036ae:	5d                   	pop    %ebp
f01036af:	c3                   	ret    

f01036b0 <env_free>:
f01036b0:	55                   	push   %ebp
f01036b1:	89 e5                	mov    %esp,%ebp
f01036b3:	57                   	push   %edi
f01036b4:	56                   	push   %esi
f01036b5:	53                   	push   %ebx
f01036b6:	83 ec 1c             	sub    $0x1c,%esp
f01036b9:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
f01036c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01036c3:	3b 05 c4 88 2a f0    	cmp    0xf02a88c4,%eax
f01036c9:	75 0f                	jne    f01036da <env_free+0x2a>

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01036cb:	a1 74 98 2a f0       	mov    0xf02a9874,%eax
f01036d0:	0f 22 d8             	mov    %eax,%cr3
f01036d3:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
f01036da:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
f01036dd:	c1 e2 02             	shl    $0x2,%edx
f01036e0:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
f01036e3:	8b 55 08             	mov    0x8(%ebp),%edx
f01036e6:	8b 42 5c             	mov    0x5c(%edx),%eax
f01036e9:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
f01036ec:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01036ef:	a8 01                	test   $0x1,%al
f01036f1:	0f 84 bf 00 00 00    	je     f01037b6 <env_free+0x106>
f01036f7:	89 c6                	mov    %eax,%esi
f01036f9:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f01036ff:	89 f0                	mov    %esi,%eax
f0103701:	c1 e8 0c             	shr    $0xc,%eax
f0103704:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
f0103707:	3b 05 70 98 2a f0    	cmp    0xf02a9870,%eax
f010370d:	72 20                	jb     f010372f <env_free+0x7f>
f010370f:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103713:	c7 44 24 08 c8 ad 10 	movl   $0xf010adc8,0x8(%esp)
f010371a:	f0 
f010371b:	c7 44 24 04 86 01 00 	movl   $0x186,0x4(%esp)
f0103722:	00 
f0103723:	c7 04 24 a8 b9 10 f0 	movl   $0xf010b9a8,(%esp)
f010372a:	e8 57 c9 ff ff       	call   f0100086 <_panic>
f010372f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103734:	8b 7d ec             	mov    0xffffffec(%ebp),%edi
f0103737:	c1 e7 16             	shl    $0x16,%edi
f010373a:	f6 84 9e 00 00 00 f0 	testb  $0x1,0xf0000000(%esi,%ebx,4)
f0103741:	01 
f0103742:	74 19                	je     f010375d <env_free+0xad>
f0103744:	89 d8                	mov    %ebx,%eax
f0103746:	c1 e0 0c             	shl    $0xc,%eax
f0103749:	09 f8                	or     %edi,%eax
f010374b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010374f:	8b 55 08             	mov    0x8(%ebp),%edx
f0103752:	8b 42 5c             	mov    0x5c(%edx),%eax
f0103755:	89 04 24             	mov    %eax,(%esp)
f0103758:	e8 7c de ff ff       	call   f01015d9 <page_remove>
f010375d:	83 c3 01             	add    $0x1,%ebx
f0103760:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103766:	75 d2                	jne    f010373a <env_free+0x8a>
f0103768:	8b 55 08             	mov    0x8(%ebp),%edx
f010376b:	8b 42 5c             	mov    0x5c(%edx),%eax
f010376e:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
f0103771:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0103778:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f010377b:	3b 05 70 98 2a f0    	cmp    0xf02a9870,%eax
f0103781:	72 1c                	jb     f010379f <env_free+0xef>
		panic("pa2page called with invalid pa");
f0103783:	c7 44 24 08 70 b1 10 	movl   $0xf010b170,0x8(%esp)
f010378a:	f0 
f010378b:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0103792:	00 
f0103793:	c7 04 24 4f b7 10 f0 	movl   $0xf010b74f,(%esp)
f010379a:	e8 e7 c8 ff ff       	call   f0100086 <_panic>
f010379f:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
f01037a2:	8d 04 52             	lea    (%edx,%edx,2),%eax
f01037a5:	c1 e0 02             	shl    $0x2,%eax
f01037a8:	03 05 7c 98 2a f0    	add    0xf02a987c,%eax
f01037ae:	89 04 24             	mov    %eax,(%esp)
f01037b1:	e8 ff d8 ff ff       	call   f01010b5 <page_decref>
f01037b6:	83 45 ec 01          	addl   $0x1,0xffffffec(%ebp)
f01037ba:	81 7d ec bb 03 00 00 	cmpl   $0x3bb,0xffffffec(%ebp)
f01037c1:	0f 85 13 ff ff ff    	jne    f01036da <env_free+0x2a>
f01037c7:	8b 55 08             	mov    0x8(%ebp),%edx
f01037ca:	8b 42 60             	mov    0x60(%edx),%eax
f01037cd:	c7 42 5c 00 00 00 00 	movl   $0x0,0x5c(%edx)
f01037d4:	c7 42 60 00 00 00 00 	movl   $0x0,0x60(%edx)

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f01037db:	c1 e8 0c             	shr    $0xc,%eax
f01037de:	3b 05 70 98 2a f0    	cmp    0xf02a9870,%eax
f01037e4:	72 1c                	jb     f0103802 <env_free+0x152>
		panic("pa2page called with invalid pa");
f01037e6:	c7 44 24 08 70 b1 10 	movl   $0xf010b170,0x8(%esp)
f01037ed:	f0 
f01037ee:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f01037f5:	00 
f01037f6:	c7 04 24 4f b7 10 f0 	movl   $0xf010b74f,(%esp)
f01037fd:	e8 84 c8 ff ff       	call   f0100086 <_panic>
f0103802:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103805:	c1 e0 02             	shl    $0x2,%eax
f0103808:	03 05 7c 98 2a f0    	add    0xf02a987c,%eax
f010380e:	89 04 24             	mov    %eax,(%esp)
f0103811:	e8 9f d8 ff ff       	call   f01010b5 <page_decref>
f0103816:	8b 45 08             	mov    0x8(%ebp),%eax
f0103819:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
f0103820:	a1 c8 88 2a f0       	mov    0xf02a88c8,%eax
f0103825:	8b 55 08             	mov    0x8(%ebp),%edx
f0103828:	89 42 44             	mov    %eax,0x44(%edx)
f010382b:	85 c0                	test   %eax,%eax
f010382d:	74 0e                	je     f010383d <env_free+0x18d>
f010382f:	8b 55 08             	mov    0x8(%ebp),%edx
f0103832:	83 c2 44             	add    $0x44,%edx
f0103835:	a1 c8 88 2a f0       	mov    0xf02a88c8,%eax
f010383a:	89 50 48             	mov    %edx,0x48(%eax)
f010383d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103840:	a3 c8 88 2a f0       	mov    %eax,0xf02a88c8
f0103845:	c7 40 48 c8 88 2a f0 	movl   $0xf02a88c8,0x48(%eax)
f010384c:	83 c4 1c             	add    $0x1c,%esp
f010384f:	5b                   	pop    %ebx
f0103850:	5e                   	pop    %esi
f0103851:	5f                   	pop    %edi
f0103852:	5d                   	pop    %ebp
f0103853:	c3                   	ret    

f0103854 <env_destroy>:
f0103854:	55                   	push   %ebp
f0103855:	89 e5                	mov    %esp,%ebp
f0103857:	53                   	push   %ebx
f0103858:	83 ec 04             	sub    $0x4,%esp
f010385b:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010385e:	89 1c 24             	mov    %ebx,(%esp)
f0103861:	e8 4a fe ff ff       	call   f01036b0 <env_free>
f0103866:	39 1d c4 88 2a f0    	cmp    %ebx,0xf02a88c4
f010386c:	75 0f                	jne    f010387d <env_destroy+0x29>
f010386e:	c7 05 c4 88 2a f0 00 	movl   $0x0,0xf02a88c4
f0103875:	00 00 00 
f0103878:	e8 1f 13 00 00       	call   f0104b9c <sched_yield>
f010387d:	83 c4 04             	add    $0x4,%esp
f0103880:	5b                   	pop    %ebx
f0103881:	5d                   	pop    %ebp
f0103882:	c3                   	ret    
	...

f0103884 <mc146818_read>:


unsigned
mc146818_read(unsigned reg)
{
f0103884:	55                   	push   %ebp
f0103885:	89 e5                	mov    %esp,%ebp

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103887:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
f010388b:	ba 70 00 00 00       	mov    $0x70,%edx
f0103890:	ee                   	out    %al,(%dx)
f0103891:	b2 71                	mov    $0x71,%dl
f0103893:	ec                   	in     (%dx),%al
f0103894:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f0103897:	5d                   	pop    %ebp
f0103898:	c3                   	ret    

f0103899 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103899:	55                   	push   %ebp
f010389a:	89 e5                	mov    %esp,%ebp

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010389c:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
f01038a0:	ba 70 00 00 00       	mov    $0x70,%edx
f01038a5:	ee                   	out    %al,(%dx)
f01038a6:	b2 71                	mov    $0x71,%dl
f01038a8:	0f b6 45 0c          	movzbl 0xc(%ebp),%eax
f01038ac:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01038ad:	5d                   	pop    %ebp
f01038ae:	c3                   	ret    

f01038af <kclock_init>:


void
kclock_init(void)
{
f01038af:	55                   	push   %ebp
f01038b0:	89 e5                	mov    %esp,%ebp
f01038b2:	83 ec 08             	sub    $0x8,%esp

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01038b5:	b8 34 00 00 00       	mov    $0x34,%eax
f01038ba:	ba 43 00 00 00       	mov    $0x43,%edx
f01038bf:	ee                   	out    %al,(%dx)
f01038c0:	b8 9c ff ff ff       	mov    $0xffffff9c,%eax
f01038c5:	b2 40                	mov    $0x40,%dl
f01038c7:	ee                   	out    %al,(%dx)
f01038c8:	b8 2e 00 00 00       	mov    $0x2e,%eax
f01038cd:	ee                   	out    %al,(%dx)
	/* initialize 8253 clock to interrupt 100 times/sec */
	outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
	outb(IO_TIMER1, TIMER_DIV(100) % 256);
	outb(IO_TIMER1, TIMER_DIV(100) / 256);
	cprintf("	Setup timer interrupts via 8259A\n");
f01038ce:	c7 04 24 88 ba 10 f0 	movl   $0xf010ba88,(%esp)
f01038d5:	e8 5d 01 00 00       	call   f0103a37 <cprintf>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<0));
f01038da:	0f b7 05 58 13 13 f0 	movzwl 0xf0131358,%eax
f01038e1:	25 fe ff 00 00       	and    $0xfffe,%eax
f01038e6:	89 04 24             	mov    %eax,(%esp)
f01038e9:	e8 0e 00 00 00       	call   f01038fc <irq_setmask_8259A>
	cprintf("	unmasked timer interrupt\n");
f01038ee:	c7 04 24 ab ba 10 f0 	movl   $0xf010baab,(%esp)
f01038f5:	e8 3d 01 00 00       	call   f0103a37 <cprintf>
}
f01038fa:	c9                   	leave  
f01038fb:	c3                   	ret    

f01038fc <irq_setmask_8259A>:
}

void
irq_setmask_8259A(uint16_t mask)
{
f01038fc:	55                   	push   %ebp
f01038fd:	89 e5                	mov    %esp,%ebp
f01038ff:	56                   	push   %esi
f0103900:	53                   	push   %ebx
f0103901:	83 ec 10             	sub    $0x10,%esp
f0103904:	8b 45 08             	mov    0x8(%ebp),%eax
f0103907:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0103909:	66 a3 58 13 13 f0    	mov    %ax,0xf0131358
	if (!didinit)
f010390f:	83 3d cc 88 2a f0 00 	cmpl   $0x0,0xf02a88cc
f0103916:	74 57                	je     f010396f <irq_setmask_8259A+0x73>

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103918:	ba 21 00 00 00       	mov    $0x21,%edx
f010391d:	ee                   	out    %al,(%dx)
f010391e:	89 f2                	mov    %esi,%edx
f0103920:	0f b6 c6             	movzbl %dh,%eax
f0103923:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103928:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103929:	c7 04 24 c6 ba 10 f0 	movl   $0xf010bac6,(%esp)
f0103930:	e8 02 01 00 00       	call   f0103a37 <cprintf>
f0103935:	bb 00 00 00 00       	mov    $0x0,%ebx
f010393a:	0f b7 c6             	movzwl %si,%eax
f010393d:	89 c6                	mov    %eax,%esi
f010393f:	f7 d6                	not    %esi
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
f0103941:	89 f0                	mov    %esi,%eax
f0103943:	89 d9                	mov    %ebx,%ecx
f0103945:	d3 f8                	sar    %cl,%eax
f0103947:	a8 01                	test   $0x1,%al
f0103949:	74 10                	je     f010395b <irq_setmask_8259A+0x5f>
			cprintf(" %d", i);
f010394b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010394f:	c7 04 24 1c 44 11 f0 	movl   $0xf011441c,(%esp)
f0103956:	e8 dc 00 00 00       	call   f0103a37 <cprintf>
f010395b:	83 c3 01             	add    $0x1,%ebx
f010395e:	83 fb 10             	cmp    $0x10,%ebx
f0103961:	75 de                	jne    f0103941 <irq_setmask_8259A+0x45>
	cprintf("\n");
f0103963:	c7 04 24 09 ac 10 f0 	movl   $0xf010ac09,(%esp)
f010396a:	e8 c8 00 00 00       	call   f0103a37 <cprintf>
}
f010396f:	83 c4 10             	add    $0x10,%esp
f0103972:	5b                   	pop    %ebx
f0103973:	5e                   	pop    %esi
f0103974:	5d                   	pop    %ebp
f0103975:	c3                   	ret    

f0103976 <pic_init>:
f0103976:	55                   	push   %ebp
f0103977:	89 e5                	mov    %esp,%ebp
f0103979:	83 ec 08             	sub    $0x8,%esp
f010397c:	c7 05 cc 88 2a f0 01 	movl   $0x1,0xf02a88cc
f0103983:	00 00 00 

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103986:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010398b:	ba 21 00 00 00       	mov    $0x21,%edx
f0103990:	ee                   	out    %al,(%dx)
f0103991:	b2 a1                	mov    $0xa1,%dl
f0103993:	ee                   	out    %al,(%dx)
f0103994:	b8 11 00 00 00       	mov    $0x11,%eax
f0103999:	b2 20                	mov    $0x20,%dl
f010399b:	ee                   	out    %al,(%dx)
f010399c:	b8 20 00 00 00       	mov    $0x20,%eax
f01039a1:	b2 21                	mov    $0x21,%dl
f01039a3:	ee                   	out    %al,(%dx)
f01039a4:	b8 04 00 00 00       	mov    $0x4,%eax
f01039a9:	ee                   	out    %al,(%dx)
f01039aa:	b8 03 00 00 00       	mov    $0x3,%eax
f01039af:	ee                   	out    %al,(%dx)
f01039b0:	b8 11 00 00 00       	mov    $0x11,%eax
f01039b5:	b2 a0                	mov    $0xa0,%dl
f01039b7:	ee                   	out    %al,(%dx)
f01039b8:	b8 28 00 00 00       	mov    $0x28,%eax
f01039bd:	b2 a1                	mov    $0xa1,%dl
f01039bf:	ee                   	out    %al,(%dx)
f01039c0:	b8 02 00 00 00       	mov    $0x2,%eax
f01039c5:	ee                   	out    %al,(%dx)
f01039c6:	b8 01 00 00 00       	mov    $0x1,%eax
f01039cb:	ee                   	out    %al,(%dx)
f01039cc:	b8 68 00 00 00       	mov    $0x68,%eax
f01039d1:	b2 20                	mov    $0x20,%dl
f01039d3:	ee                   	out    %al,(%dx)
f01039d4:	b8 0a 00 00 00       	mov    $0xa,%eax
f01039d9:	ee                   	out    %al,(%dx)
f01039da:	b8 68 00 00 00       	mov    $0x68,%eax
f01039df:	b2 a0                	mov    $0xa0,%dl
f01039e1:	ee                   	out    %al,(%dx)
f01039e2:	b8 0a 00 00 00       	mov    $0xa,%eax
f01039e7:	ee                   	out    %al,(%dx)
f01039e8:	0f b7 05 58 13 13 f0 	movzwl 0xf0131358,%eax
f01039ef:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f01039f3:	74 0b                	je     f0103a00 <pic_init+0x8a>
f01039f5:	0f b7 c0             	movzwl %ax,%eax
f01039f8:	89 04 24             	mov    %eax,(%esp)
f01039fb:	e8 fc fe ff ff       	call   f01038fc <irq_setmask_8259A>
f0103a00:	c9                   	leave  
f0103a01:	c3                   	ret    
	...

f0103a04 <vcprintf>:
}

int
vcprintf(const char *fmt, va_list ap)
{
f0103a04:	55                   	push   %ebp
f0103a05:	89 e5                	mov    %esp,%ebp
f0103a07:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103a0a:	c7 45 fc 00 00 00 00 	movl   $0x0,0xfffffffc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103a11:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a14:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a18:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a1b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a1f:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
f0103a22:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a26:	c7 04 24 54 3a 10 f0 	movl   $0xf0103a54,(%esp)
f0103a2d:	e8 0f 56 00 00       	call   f0109041 <vprintfmt>
f0103a32:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
	return cnt;
}
f0103a35:	c9                   	leave  
f0103a36:	c3                   	ret    

f0103a37 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103a37:	55                   	push   %ebp
f0103a38:	89 e5                	mov    %esp,%ebp
f0103a3a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103a3d:	8d 45 0c             	lea    0xc(%ebp),%eax
f0103a40:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
	cnt = vcprintf(fmt, ap);
f0103a43:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a47:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a4a:	89 04 24             	mov    %eax,(%esp)
f0103a4d:	e8 b2 ff ff ff       	call   f0103a04 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103a52:	c9                   	leave  
f0103a53:	c3                   	ret    

f0103a54 <putch>:
f0103a54:	55                   	push   %ebp
f0103a55:	89 e5                	mov    %esp,%ebp
f0103a57:	83 ec 08             	sub    $0x8,%esp
f0103a5a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a5d:	89 04 24             	mov    %eax,(%esp)
f0103a60:	e8 18 ca ff ff       	call   f010047d <cputchar>
f0103a65:	c9                   	leave  
f0103a66:	c3                   	ret    
	...

f0103a70 <idt_init>:


void
idt_init(void)
{
f0103a70:	55                   	push   %ebp
f0103a71:	89 e5                	mov    %esp,%ebp
f0103a73:	ba 00 00 00 00       	mov    $0x0,%edx
	extern struct Segdesc gdt[];
	/*中断门和陷阱门的DPL只有使用INT n指令引起中断/异常时才检查，
	 *硬件产生的中断/异常不检查。 
	 *这里初始化使用的都是中断门。中断发生后，处理器器自动复位
	 *EFLAGES中的IF位，在内核中中断是关闭的。
	 */
	// LAB 3: Your code here.
	int i;
	for(i=0;i<IRQ_OFFSET;i++)
		SETGATE(idt[i],0,GD_KT,vectors[i],0);//陷阱门
f0103a78:	8b 04 95 64 13 13 f0 	mov    0xf0131364(,%edx,4),%eax
f0103a7f:	66 89 04 d5 e0 88 2a 	mov    %ax,0xf02a88e0(,%edx,8)
f0103a86:	f0 
f0103a87:	66 c7 04 d5 e2 88 2a 	movw   $0x8,0xf02a88e2(,%edx,8)
f0103a8e:	f0 08 00 
f0103a91:	c6 04 d5 e4 88 2a f0 	movb   $0x0,0xf02a88e4(,%edx,8)
f0103a98:	00 
f0103a99:	c6 04 d5 e5 88 2a f0 	movb   $0x8e,0xf02a88e5(,%edx,8)
f0103aa0:	8e 
f0103aa1:	c1 e8 10             	shr    $0x10,%eax
f0103aa4:	66 89 04 d5 e6 88 2a 	mov    %ax,0xf02a88e6(,%edx,8)
f0103aab:	f0 
f0103aac:	83 c2 01             	add    $0x1,%edx
f0103aaf:	83 fa 20             	cmp    $0x20,%edx
f0103ab2:	75 c4                	jne    f0103a78 <idt_init+0x8>
	SETGATE(idt[T_BRKPT],0,GD_KT,vectors[T_BRKPT],3);//系统中断门,断点异常，DPL＝3
f0103ab4:	a1 70 13 13 f0       	mov    0xf0131370,%eax
f0103ab9:	66 a3 f8 88 2a f0    	mov    %ax,0xf02a88f8
f0103abf:	66 c7 05 fa 88 2a f0 	movw   $0x8,0xf02a88fa
f0103ac6:	08 00 
f0103ac8:	c6 05 fc 88 2a f0 00 	movb   $0x0,0xf02a88fc
f0103acf:	c6 05 fd 88 2a f0 ee 	movb   $0xee,0xf02a88fd
f0103ad6:	c1 e8 10             	shr    $0x10,%eax
f0103ad9:	66 a3 fe 88 2a f0    	mov    %ax,0xf02a88fe
	SETGATE(idt[T_OFLOW],0,GD_KT,vectors[T_OFLOW],3);//系统陷阱门，溢出异常，DPL＝3
f0103adf:	a1 74 13 13 f0       	mov    0xf0131374,%eax
f0103ae4:	66 a3 00 89 2a f0    	mov    %ax,0xf02a8900
f0103aea:	66 c7 05 02 89 2a f0 	movw   $0x8,0xf02a8902
f0103af1:	08 00 
f0103af3:	c6 05 04 89 2a f0 00 	movb   $0x0,0xf02a8904
f0103afa:	c6 05 05 89 2a f0 ee 	movb   $0xee,0xf02a8905
f0103b01:	c1 e8 10             	shr    $0x10,%eax
f0103b04:	66 a3 06 89 2a f0    	mov    %ax,0xf02a8906
	SETGATE(idt[T_BOUND],0,GD_KT,vectors[T_BOUND],3);
f0103b0a:	a1 78 13 13 f0       	mov    0xf0131378,%eax
f0103b0f:	66 a3 08 89 2a f0    	mov    %ax,0xf02a8908
f0103b15:	66 c7 05 0a 89 2a f0 	movw   $0x8,0xf02a890a
f0103b1c:	08 00 
f0103b1e:	c6 05 0c 89 2a f0 00 	movb   $0x0,0xf02a890c
f0103b25:	c6 05 0d 89 2a f0 ee 	movb   $0xee,0xf02a890d
f0103b2c:	c1 e8 10             	shr    $0x10,%eax
f0103b2f:	66 a3 0e 89 2a f0    	mov    %ax,0xf02a890e
	for(i=IRQ_OFFSET;i<IRQ_OFFSET+MAX_IRQS;i++)
               SETGATE(idt[i],0,GD_KT,vectors[i],0);//中断门,外部硬件中断 16个
f0103b35:	8b 04 95 64 13 13 f0 	mov    0xf0131364(,%edx,4),%eax
f0103b3c:	66 89 04 d5 e0 88 2a 	mov    %ax,0xf02a88e0(,%edx,8)
f0103b43:	f0 
f0103b44:	66 c7 04 d5 e2 88 2a 	movw   $0x8,0xf02a88e2(,%edx,8)
f0103b4b:	f0 08 00 
f0103b4e:	c6 04 d5 e4 88 2a f0 	movb   $0x0,0xf02a88e4(,%edx,8)
f0103b55:	00 
f0103b56:	c6 04 d5 e5 88 2a f0 	movb   $0x8e,0xf02a88e5(,%edx,8)
f0103b5d:	8e 
f0103b5e:	c1 e8 10             	shr    $0x10,%eax
f0103b61:	66 89 04 d5 e6 88 2a 	mov    %ax,0xf02a88e6(,%edx,8)
f0103b68:	f0 
f0103b69:	83 c2 01             	add    $0x1,%edx
f0103b6c:	83 fa 30             	cmp    $0x30,%edx
f0103b6f:	75 c4                	jne    f0103b35 <idt_init+0xc5>
	 SETGATE(idt[T_SYSCALL],0,GD_KT,vectors[T_SYSCALL],3);//系统调用,系统陷阱门，DPL＝3
f0103b71:	a1 24 14 13 f0       	mov    0xf0131424,%eax
f0103b76:	66 a3 60 8a 2a f0    	mov    %ax,0xf02a8a60
f0103b7c:	66 c7 05 62 8a 2a f0 	movw   $0x8,0xf02a8a62
f0103b83:	08 00 
f0103b85:	c6 05 64 8a 2a f0 00 	movb   $0x0,0xf02a8a64
f0103b8c:	c6 05 65 8a 2a f0 ee 	movb   $0xee,0xf02a8a65
f0103b93:	c1 e8 10             	shr    $0x10,%eax
f0103b96:	66 a3 66 8a 2a f0    	mov    %ax,0xf02a8a66
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	//在内核模式中，处理器使用TSS中的ESP0和SS0字段定义内核栈
	//JOS不使用TSS的其他字段
	ts.ts_esp0 = KSTACKTOP;
f0103b9c:	c7 05 e4 90 2a f0 00 	movl   $0xefc00000,0xf02a90e4
f0103ba3:	00 c0 ef 
	ts.ts_ss0 = GD_KD;
f0103ba6:	66 c7 05 e8 90 2a f0 	movw   $0x10,0xf02a90e8
f0103bad:	10 00 

	// Initialize the TSS field of the gdt.初始化任务状态段，
	//该段存放在GDT表中
	gdt[GD_TSS >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103baf:	66 c7 05 48 13 13 f0 	movw   $0x68,0xf0131348
f0103bb6:	68 00 
f0103bb8:	b8 e0 90 2a f0       	mov    $0xf02a90e0,%eax
f0103bbd:	66 a3 4a 13 13 f0    	mov    %ax,0xf013134a
f0103bc3:	89 c2                	mov    %eax,%edx
f0103bc5:	c1 ea 10             	shr    $0x10,%edx
f0103bc8:	88 15 4c 13 13 f0    	mov    %dl,0xf013134c
f0103bce:	c6 05 4e 13 13 f0 40 	movb   $0x40,0xf013134e
f0103bd5:	c1 e8 18             	shr    $0x18,%eax
f0103bd8:	a2 4f 13 13 f0       	mov    %al,0xf013134f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS >> 3].sd_s = 0;
f0103bdd:	c6 05 4d 13 13 f0 89 	movb   $0x89,0xf013134d

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103be4:	b8 28 00 00 00       	mov    $0x28,%eax
f0103be9:	0f 00 d8             	ltr    %ax

	// Load the TSS
	ltr(GD_TSS);

	// Load the IDT
	asm volatile("lidt idt_pd");
f0103bec:	0f 01 1d 5c 13 13 f0 	lidtl  0xf013135c
}
f0103bf3:	5d                   	pop    %ebp
f0103bf4:	c3                   	ret    

f0103bf5 <print_regs>:

void
print_trapframe(struct Trapframe *tf)
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
	cprintf("  err  0x%08x\n", tf->tf_err);
	cprintf("  eip  0x%08x\n", tf->tf_eip);
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
	cprintf("  esp  0x%08x\n", tf->tf_esp);
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
}

void
print_regs(struct PushRegs *regs)
{
f0103bf5:	55                   	push   %ebp
f0103bf6:	89 e5                	mov    %esp,%ebp
f0103bf8:	53                   	push   %ebx
f0103bf9:	83 ec 14             	sub    $0x14,%esp
f0103bfc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103bff:	8b 03                	mov    (%ebx),%eax
f0103c01:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c05:	c7 04 24 da ba 10 f0 	movl   $0xf010bada,(%esp)
f0103c0c:	e8 26 fe ff ff       	call   f0103a37 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103c11:	8b 43 04             	mov    0x4(%ebx),%eax
f0103c14:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c18:	c7 04 24 e9 ba 10 f0 	movl   $0xf010bae9,(%esp)
f0103c1f:	e8 13 fe ff ff       	call   f0103a37 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103c24:	8b 43 08             	mov    0x8(%ebx),%eax
f0103c27:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c2b:	c7 04 24 f8 ba 10 f0 	movl   $0xf010baf8,(%esp)
f0103c32:	e8 00 fe ff ff       	call   f0103a37 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103c37:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103c3a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c3e:	c7 04 24 07 bb 10 f0 	movl   $0xf010bb07,(%esp)
f0103c45:	e8 ed fd ff ff       	call   f0103a37 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103c4a:	8b 43 10             	mov    0x10(%ebx),%eax
f0103c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c51:	c7 04 24 16 bb 10 f0 	movl   $0xf010bb16,(%esp)
f0103c58:	e8 da fd ff ff       	call   f0103a37 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103c5d:	8b 43 14             	mov    0x14(%ebx),%eax
f0103c60:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c64:	c7 04 24 25 bb 10 f0 	movl   $0xf010bb25,(%esp)
f0103c6b:	e8 c7 fd ff ff       	call   f0103a37 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103c70:	8b 43 18             	mov    0x18(%ebx),%eax
f0103c73:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c77:	c7 04 24 34 bb 10 f0 	movl   $0xf010bb34,(%esp)
f0103c7e:	e8 b4 fd ff ff       	call   f0103a37 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103c83:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103c86:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c8a:	c7 04 24 43 bb 10 f0 	movl   $0xf010bb43,(%esp)
f0103c91:	e8 a1 fd ff ff       	call   f0103a37 <cprintf>
}
f0103c96:	83 c4 14             	add    $0x14,%esp
f0103c99:	5b                   	pop    %ebx
f0103c9a:	5d                   	pop    %ebp
f0103c9b:	c3                   	ret    

f0103c9c <print_trapframe>:
f0103c9c:	55                   	push   %ebp
f0103c9d:	89 e5                	mov    %esp,%ebp
f0103c9f:	53                   	push   %ebx
f0103ca0:	83 ec 14             	sub    $0x14,%esp
f0103ca3:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103ca6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103caa:	c7 04 24 52 bb 10 f0 	movl   $0xf010bb52,(%esp)
f0103cb1:	e8 81 fd ff ff       	call   f0103a37 <cprintf>
f0103cb6:	89 1c 24             	mov    %ebx,(%esp)
f0103cb9:	e8 37 ff ff ff       	call   f0103bf5 <print_regs>
f0103cbe:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103cc2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cc6:	c7 04 24 64 bb 10 f0 	movl   $0xf010bb64,(%esp)
f0103ccd:	e8 65 fd ff ff       	call   f0103a37 <cprintf>
f0103cd2:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103cd6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cda:	c7 04 24 77 bb 10 f0 	movl   $0xf010bb77,(%esp)
f0103ce1:	e8 51 fd ff ff       	call   f0103a37 <cprintf>
f0103ce6:	8b 53 28             	mov    0x28(%ebx),%edx
f0103ce9:	89 d0                	mov    %edx,%eax
f0103ceb:	83 fa 13             	cmp    $0x13,%edx
f0103cee:	77 09                	ja     f0103cf9 <print_trapframe+0x5d>
f0103cf0:	8b 0c 95 20 be 10 f0 	mov    0xf010be20(,%edx,4),%ecx
f0103cf7:	eb 1c                	jmp    f0103d15 <print_trapframe+0x79>
f0103cf9:	b9 8a bb 10 f0       	mov    $0xf010bb8a,%ecx
f0103cfe:	83 fa 30             	cmp    $0x30,%edx
f0103d01:	74 12                	je     f0103d15 <print_trapframe+0x79>
f0103d03:	83 e8 20             	sub    $0x20,%eax
f0103d06:	b9 96 bb 10 f0       	mov    $0xf010bb96,%ecx
f0103d0b:	83 f8 0f             	cmp    $0xf,%eax
f0103d0e:	76 05                	jbe    f0103d15 <print_trapframe+0x79>
f0103d10:	b9 a9 bb 10 f0       	mov    $0xf010bba9,%ecx
f0103d15:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103d19:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103d1d:	c7 04 24 b8 bb 10 f0 	movl   $0xf010bbb8,(%esp)
f0103d24:	e8 0e fd ff ff       	call   f0103a37 <cprintf>
f0103d29:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103d2c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d30:	c7 04 24 ca bb 10 f0 	movl   $0xf010bbca,(%esp)
f0103d37:	e8 fb fc ff ff       	call   f0103a37 <cprintf>
f0103d3c:	8b 43 30             	mov    0x30(%ebx),%eax
f0103d3f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d43:	c7 04 24 d9 bb 10 f0 	movl   $0xf010bbd9,(%esp)
f0103d4a:	e8 e8 fc ff ff       	call   f0103a37 <cprintf>
f0103d4f:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103d53:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d57:	c7 04 24 e8 bb 10 f0 	movl   $0xf010bbe8,(%esp)
f0103d5e:	e8 d4 fc ff ff       	call   f0103a37 <cprintf>
f0103d63:	8b 43 38             	mov    0x38(%ebx),%eax
f0103d66:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d6a:	c7 04 24 fb bb 10 f0 	movl   $0xf010bbfb,(%esp)
f0103d71:	e8 c1 fc ff ff       	call   f0103a37 <cprintf>
f0103d76:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103d79:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d7d:	c7 04 24 0a bc 10 f0 	movl   $0xf010bc0a,(%esp)
f0103d84:	e8 ae fc ff ff       	call   f0103a37 <cprintf>
f0103d89:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103d8d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d91:	c7 04 24 19 bc 10 f0 	movl   $0xf010bc19,(%esp)
f0103d98:	e8 9a fc ff ff       	call   f0103a37 <cprintf>
f0103d9d:	83 c4 14             	add    $0x14,%esp
f0103da0:	5b                   	pop    %ebx
f0103da1:	5d                   	pop    %ebp
f0103da2:	c3                   	ret    

f0103da3 <page_fault_handler>:

static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	switch(tf->tf_trapno){
		case T_PGFLT:
			page_fault_handler(tf);
			break;
		case T_BRKPT:
			monitor(tf);
			break;
		case T_DEBUG:
			monitor(tf);
			break;
		case T_SYSCALL:
			curenv->env_tf.tf_regs.reg_eax=syscall(tf->tf_regs.reg_eax,tf->tf_regs.reg_edx,tf->tf_regs.reg_ecx,tf->tf_regs.reg_ebx,tf->tf_regs.reg_edi,tf->tf_regs.reg_esi);
			break;
		default:	
		// Handle clock interrupts.
		// LAB 4: Your code here.
		// Add time tick increment to clock interrupts.
		// LAB 6: Your code here.
		if(tf->tf_trapno==IRQ_OFFSET + IRQ_TIMER){
			time_tick();
			sched_yield();//内核层的环境切换，需要在环境切换中思考
		}


		// Handle spurious interrupts
		// The hardware sometimes raises these because of noise on the
		// IRQ line or other reasons. We don't care.
		if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
			cprintf("Spurious interrupt on irq 7\n");
			print_trapframe(tf);
			return;
		}
	


		// Unexpected trap: The user process or the kernel has a bug.
		print_trapframe(tf);
		if (tf->tf_cs == GD_KT)
			panic("unhandled trap in kernel");
		else {
			env_destroy(curenv);
			return;
		}
	}
}

void
trap(struct Trapframe *tf)
{
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));

	if ((tf->tf_cs & 3) == 3) {
		// Trapped from user mode.
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		assert(curenv);
		curenv->env_tf = *tf;
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
	}
	
	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNABLE)
		env_run(curenv);
	else
		sched_yield();
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103da3:	55                   	push   %ebp
f0103da4:	89 e5                	mov    %esp,%ebp
f0103da6:	56                   	push   %esi
f0103da7:	53                   	push   %ebx
f0103da8:	83 ec 10             	sub    $0x10,%esp
f0103dab:	8b 5d 08             	mov    0x8(%ebp),%ebx
static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103dae:	0f 20 d6             	mov    %cr2,%esi
	uint32_t fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	
	// LAB 3: Your code here.还可以通过页故障异常的错误码的位2判断
	if((tf->tf_cs&3)==0)
f0103db1:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103db5:	75 1c                	jne    f0103dd3 <page_fault_handler+0x30>
		panic("Page Fault in Kernel Mode");
f0103db7:	c7 44 24 08 2c bc 10 	movl   $0xf010bc2c,0x8(%esp)
f0103dbe:	f0 
f0103dbf:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
f0103dc6:	00 
f0103dc7:	c7 04 24 46 bc 10 f0 	movl   $0xf010bc46,(%esp)
f0103dce:	e8 b3 c2 ff ff       	call   f0100086 <_panic>
	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Call the environment's page fault upcall, if one exists.  Set up a
	// page fault stack frame on the user exception stack (below
	// UXSTACKTOP), then branch to curenv->env_pgfault_upcall.
	//
	// The page fault upcall might cause another page fault, in which case
	// we branch to the page fault upcall recursively, pushing another
	// page fault stack frame on top of the user exception stack.
	//
	// The trap handler needs one word of scratch space at the top of the
	// trap-time stack in order to return.  In the non-recursive case, we
	// don't have to worry about this because the top of the regular user
	// stack is free.  In the recursive case, this means we have to leave
	// an extra word between the current top of the exception stack and
	// the new stack frame because the exception stack _is_ the trap-time
	// stack.
	//
	// If there's no page fault upcall, the environment didn't allocate a
	// page for its exception stack or can't write to it, or the exception
	// stack overflows, then destroy the environment that caused the fault.
	// Note that the grade script assumes you will first check for the page
	// fault upcall and print the "user fault va" message below if there is
	// none.  The remaining three checks can be combined into a single test.
	//
	// Hints:
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	struct UTrapframe *utf;
	size_t utf_size;
	if((tf->tf_err&FEC_U)&&curenv->env_pgfault_upcall)
f0103dd3:	f6 43 2c 04          	testb  $0x4,0x2c(%ebx)
f0103dd7:	0f 84 d9 00 00 00    	je     f0103eb6 <page_fault_handler+0x113>
f0103ddd:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0103de2:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103de6:	0f 84 ca 00 00 00    	je     f0103eb6 <page_fault_handler+0x113>
	{
		utf_size = sizeof(struct UTrapframe);
		user_mem_assert(curenv,(void*)(UXSTACKTOP-utf_size),utf_size,0);
f0103dec:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103df3:	00 
f0103df4:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f0103dfb:	00 
f0103dfc:	c7 44 24 04 cc ff bf 	movl   $0xeebfffcc,0x4(%esp)
f0103e03:	ee 
f0103e04:	89 04 24             	mov    %eax,(%esp)
f0103e07:	e8 75 d7 ff ff       	call   f0101581 <user_mem_assert>
		if(tf->tf_esp>(UXSTACKTOP-PGSIZE)&&tf->tf_esp<UXSTACKTOP)
f0103e0c:	8b 4b 3c             	mov    0x3c(%ebx),%ecx
f0103e0f:	8d 81 ff 0f 40 11    	lea    0x11400fff(%ecx),%eax
f0103e15:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f0103e1a:	3d fe 0f 00 00       	cmp    $0xffe,%eax
f0103e1f:	77 03                	ja     f0103e24 <page_fault_handler+0x81>
		{
			utf=(struct UTrapframe*)(tf->tf_esp-utf_size-sizeof(utf->utf_eip));
f0103e21:	8d 51 c8             	lea    0xffffffc8(%ecx),%edx
					//这一步处理page fault handler中出现缺页异常
					//先压入一32位空值，再压入UTrapframe,这个空出来的位置在_pgfault_upcall中存放utf->utf_eip
		}
		else{
			utf = (struct UTrapframe*)(UXSTACKTOP-utf_size);   
		}
					//在用户异常栈上设置一个页故障帧栈
		utf->utf_fault_va=fault_va;
f0103e24:	89 32                	mov    %esi,(%edx)
		utf->utf_err=tf->tf_err;
f0103e26:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103e29:	89 42 04             	mov    %eax,0x4(%edx)
		utf->utf_regs=tf->tf_regs;
f0103e2c:	8b 03                	mov    (%ebx),%eax
f0103e2e:	89 42 08             	mov    %eax,0x8(%edx)
f0103e31:	8b 43 04             	mov    0x4(%ebx),%eax
f0103e34:	89 42 0c             	mov    %eax,0xc(%edx)
f0103e37:	8b 43 08             	mov    0x8(%ebx),%eax
f0103e3a:	89 42 10             	mov    %eax,0x10(%edx)
f0103e3d:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103e40:	89 42 14             	mov    %eax,0x14(%edx)
f0103e43:	8b 43 10             	mov    0x10(%ebx),%eax
f0103e46:	89 42 18             	mov    %eax,0x18(%edx)
f0103e49:	8b 43 14             	mov    0x14(%ebx),%eax
f0103e4c:	89 42 1c             	mov    %eax,0x1c(%edx)
f0103e4f:	8b 43 18             	mov    0x18(%ebx),%eax
f0103e52:	89 42 20             	mov    %eax,0x20(%edx)
f0103e55:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103e58:	89 42 24             	mov    %eax,0x24(%edx)
		utf->utf_eip=tf->tf_eip;
f0103e5b:	8b 43 30             	mov    0x30(%ebx),%eax
f0103e5e:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags=tf->tf_eflags;
f0103e61:	8b 43 38             	mov    0x38(%ebx),%eax
f0103e64:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp=tf->tf_esp;
f0103e67:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103e6a:	89 42 30             	mov    %eax,0x30(%edx)
		curenv->env_tf.tf_esp=(uintptr_t)utf;
f0103e6d:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0103e72:	89 50 3c             	mov    %edx,0x3c(%eax)
		//curenv->env_tf.tf_eflags=utf->utf_eflags;
		//cprintf("utf:utf_esp=%x utf_eip=%x\n",utf->utf_esp,utf->utf_eip);
		//cprintf("curenv:tf_esp=%x utf=%x\n",curenv->env_tf.tf_esp,(uintptr_t)utf);
		//cprintf("tf->tf_eflags=%x curenv_eflages=%x\n",tf->tf_eflags,curenv->env_tf.tf_eflags);
		if(curenv->env_pgfault_upcall)
f0103e75:	8b 15 c4 88 2a f0    	mov    0xf02a88c4,%edx
f0103e7b:	8b 42 64             	mov    0x64(%edx),%eax
f0103e7e:	85 c0                	test   %eax,%eax
f0103e80:	74 34                	je     f0103eb6 <page_fault_handler+0x113>
		{	
			user_mem_assert(curenv,(void*)curenv->env_pgfault_upcall,PGSIZE,0);
f0103e82:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103e89:	00 
f0103e8a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103e91:	00 
f0103e92:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e96:	89 14 24             	mov    %edx,(%esp)
f0103e99:	e8 e3 d6 ff ff       	call   f0101581 <user_mem_assert>
			curenv->env_tf.tf_eip=(uintptr_t)curenv->env_pgfault_upcall;
f0103e9e:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0103ea3:	8b 50 64             	mov    0x64(%eax),%edx
f0103ea6:	89 50 30             	mov    %edx,0x30(%eax)
			env_run(curenv);
f0103ea9:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0103eae:	89 04 24             	mov    %eax,(%esp)
f0103eb1:	e8 c2 f3 ff ff       	call   f0103278 <env_run>
		}
	}
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103eb6:	8b 43 30             	mov    0x30(%ebx),%eax
f0103eb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ebd:	89 74 24 08          	mov    %esi,0x8(%esp)
f0103ec1:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0103ec6:	8b 40 4c             	mov    0x4c(%eax),%eax
f0103ec9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ecd:	c7 04 24 ec bd 10 f0 	movl   $0xf010bdec,(%esp)
f0103ed4:	e8 5e fb ff ff       	call   f0103a37 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103ed9:	89 1c 24             	mov    %ebx,(%esp)
f0103edc:	e8 bb fd ff ff       	call   f0103c9c <print_trapframe>
	env_destroy(curenv);
f0103ee1:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0103ee6:	89 04 24             	mov    %eax,(%esp)
f0103ee9:	e8 66 f9 ff ff       	call   f0103854 <env_destroy>
}
f0103eee:	83 c4 10             	add    $0x10,%esp
f0103ef1:	5b                   	pop    %ebx
f0103ef2:	5e                   	pop    %esi
f0103ef3:	5d                   	pop    %ebp
f0103ef4:	c3                   	ret    

f0103ef5 <trap>:
f0103ef5:	55                   	push   %ebp
f0103ef6:	89 e5                	mov    %esp,%ebp
f0103ef8:	56                   	push   %esi
f0103ef9:	53                   	push   %ebx
f0103efa:	83 ec 20             	sub    $0x20,%esp
f0103efd:	8b 75 08             	mov    0x8(%ebp),%esi
f0103f00:	fc                   	cld    
static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103f01:	9c                   	pushf  
f0103f02:	58                   	pop    %eax
f0103f03:	f6 c4 02             	test   $0x2,%ah
f0103f06:	74 24                	je     f0103f2c <trap+0x37>
f0103f08:	c7 44 24 0c 52 bc 10 	movl   $0xf010bc52,0xc(%esp)
f0103f0f:	f0 
f0103f10:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0103f17:	f0 
f0103f18:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
f0103f1f:	00 
f0103f20:	c7 04 24 46 bc 10 f0 	movl   $0xf010bc46,(%esp)
f0103f27:	e8 5a c1 ff ff       	call   f0100086 <_panic>
f0103f2c:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103f30:	83 e0 03             	and    $0x3,%eax
f0103f33:	83 f8 03             	cmp    $0x3,%eax
f0103f36:	75 47                	jne    f0103f7f <trap+0x8a>
f0103f38:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0103f3d:	85 c0                	test   %eax,%eax
f0103f3f:	75 24                	jne    f0103f65 <trap+0x70>
f0103f41:	c7 44 24 0c 6b bc 10 	movl   $0xf010bc6b,0xc(%esp)
f0103f48:	f0 
f0103f49:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0103f50:	f0 
f0103f51:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
f0103f58:	00 
f0103f59:	c7 04 24 46 bc 10 f0 	movl   $0xf010bc46,(%esp)
f0103f60:	e8 21 c1 ff ff       	call   f0100086 <_panic>
f0103f65:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103f6c:	00 
f0103f6d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103f71:	89 04 24             	mov    %eax,(%esp)
f0103f74:	e8 0f 59 00 00       	call   f0109888 <memcpy>
f0103f79:	8b 35 c4 88 2a f0    	mov    0xf02a88c4,%esi
f0103f7f:	8b 46 28             	mov    0x28(%esi),%eax
f0103f82:	83 f8 03             	cmp    $0x3,%eax
f0103f85:	74 33                	je     f0103fba <trap+0xc5>
f0103f87:	83 f8 03             	cmp    $0x3,%eax
f0103f8a:	77 0b                	ja     f0103f97 <trap+0xa2>
f0103f8c:	83 f8 01             	cmp    $0x1,%eax
f0103f8f:	0f 85 78 00 00 00    	jne    f010400d <trap+0x118>
f0103f95:	eb 30                	jmp    f0103fc7 <trap+0xd2>
f0103f97:	83 f8 0e             	cmp    $0xe,%eax
f0103f9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103fa0:	74 07                	je     f0103fa9 <trap+0xb4>
f0103fa2:	83 f8 30             	cmp    $0x30,%eax
f0103fa5:	75 66                	jne    f010400d <trap+0x118>
f0103fa7:	eb 2c                	jmp    f0103fd5 <trap+0xe0>
f0103fa9:	89 34 24             	mov    %esi,(%esp)
f0103fac:	8d 74 26 00          	lea    0x0(%esi),%esi
f0103fb0:	e8 ee fd ff ff       	call   f0103da3 <page_fault_handler>
f0103fb5:	e9 b6 00 00 00       	jmp    f0104070 <trap+0x17b>
f0103fba:	89 34 24             	mov    %esi,(%esp)
f0103fbd:	e8 d5 c9 ff ff       	call   f0100997 <monitor>
f0103fc2:	e9 a9 00 00 00       	jmp    f0104070 <trap+0x17b>
f0103fc7:	89 34 24             	mov    %esi,(%esp)
f0103fca:	e8 c8 c9 ff ff       	call   f0100997 <monitor>
f0103fcf:	90                   	nop    
f0103fd0:	e9 9b 00 00 00       	jmp    f0104070 <trap+0x17b>
f0103fd5:	8b 1d c4 88 2a f0    	mov    0xf02a88c4,%ebx
f0103fdb:	8b 46 04             	mov    0x4(%esi),%eax
f0103fde:	89 44 24 14          	mov    %eax,0x14(%esp)
f0103fe2:	8b 06                	mov    (%esi),%eax
f0103fe4:	89 44 24 10          	mov    %eax,0x10(%esp)
f0103fe8:	8b 46 10             	mov    0x10(%esi),%eax
f0103feb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103fef:	8b 46 18             	mov    0x18(%esi),%eax
f0103ff2:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103ff6:	8b 46 14             	mov    0x14(%esi),%eax
f0103ff9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ffd:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104000:	89 04 24             	mov    %eax,(%esp)
f0104003:	e8 49 0d 00 00       	call   f0104d51 <syscall>
f0104008:	89 43 1c             	mov    %eax,0x1c(%ebx)
f010400b:	eb 63                	jmp    f0104070 <trap+0x17b>
f010400d:	83 f8 20             	cmp    $0x20,%eax
f0104010:	75 0a                	jne    f010401c <trap+0x127>
f0104012:	e8 57 61 00 00       	call   f010a16e <time_tick>
f0104017:	e8 80 0b 00 00       	call   f0104b9c <sched_yield>
f010401c:	83 f8 27             	cmp    $0x27,%eax
f010401f:	90                   	nop    
f0104020:	75 16                	jne    f0104038 <trap+0x143>
f0104022:	c7 04 24 72 bc 10 f0 	movl   $0xf010bc72,(%esp)
f0104029:	e8 09 fa ff ff       	call   f0103a37 <cprintf>
f010402e:	89 34 24             	mov    %esi,(%esp)
f0104031:	e8 66 fc ff ff       	call   f0103c9c <print_trapframe>
f0104036:	eb 38                	jmp    f0104070 <trap+0x17b>
f0104038:	89 34 24             	mov    %esi,(%esp)
f010403b:	e8 5c fc ff ff       	call   f0103c9c <print_trapframe>
f0104040:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104045:	75 1c                	jne    f0104063 <trap+0x16e>
f0104047:	c7 44 24 08 8f bc 10 	movl   $0xf010bc8f,0x8(%esp)
f010404e:	f0 
f010404f:	c7 44 24 04 ad 00 00 	movl   $0xad,0x4(%esp)
f0104056:	00 
f0104057:	c7 04 24 46 bc 10 f0 	movl   $0xf010bc46,(%esp)
f010405e:	e8 23 c0 ff ff       	call   f0100086 <_panic>
f0104063:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0104068:	89 04 24             	mov    %eax,(%esp)
f010406b:	e8 e4 f7 ff ff       	call   f0103854 <env_destroy>
f0104070:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0104075:	85 c0                	test   %eax,%eax
f0104077:	74 0e                	je     f0104087 <trap+0x192>
f0104079:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010407d:	75 08                	jne    f0104087 <trap+0x192>
f010407f:	89 04 24             	mov    %eax,(%esp)
f0104082:	e8 f1 f1 ff ff       	call   f0103278 <env_run>
f0104087:	e8 10 0b 00 00       	call   f0104b9c <sched_yield>

f010408c <vector0>:
f010408c:	6a 00                	push   $0x0
f010408e:	6a 00                	push   $0x0
f0104090:	e9 e9 0a 00 00       	jmp    f0104b7e <_alltraps>
f0104095:	90                   	nop    

f0104096 <vector1>:
f0104096:	6a 00                	push   $0x0
f0104098:	6a 01                	push   $0x1
f010409a:	e9 df 0a 00 00       	jmp    f0104b7e <_alltraps>
f010409f:	90                   	nop    

f01040a0 <vector2>:
f01040a0:	6a 00                	push   $0x0
f01040a2:	6a 02                	push   $0x2
f01040a4:	e9 d5 0a 00 00       	jmp    f0104b7e <_alltraps>
f01040a9:	90                   	nop    

f01040aa <vector3>:
f01040aa:	6a 00                	push   $0x0
f01040ac:	6a 03                	push   $0x3
f01040ae:	e9 cb 0a 00 00       	jmp    f0104b7e <_alltraps>
f01040b3:	90                   	nop    

f01040b4 <vector4>:
f01040b4:	6a 00                	push   $0x0
f01040b6:	6a 04                	push   $0x4
f01040b8:	e9 c1 0a 00 00       	jmp    f0104b7e <_alltraps>
f01040bd:	90                   	nop    

f01040be <vector5>:
f01040be:	6a 00                	push   $0x0
f01040c0:	6a 05                	push   $0x5
f01040c2:	e9 b7 0a 00 00       	jmp    f0104b7e <_alltraps>
f01040c7:	90                   	nop    

f01040c8 <vector6>:
f01040c8:	6a 00                	push   $0x0
f01040ca:	6a 06                	push   $0x6
f01040cc:	e9 ad 0a 00 00       	jmp    f0104b7e <_alltraps>
f01040d1:	90                   	nop    

f01040d2 <vector7>:
f01040d2:	6a 00                	push   $0x0
f01040d4:	6a 07                	push   $0x7
f01040d6:	e9 a3 0a 00 00       	jmp    f0104b7e <_alltraps>
f01040db:	90                   	nop    

f01040dc <vector8>:
f01040dc:	6a 08                	push   $0x8
f01040de:	e9 9b 0a 00 00       	jmp    f0104b7e <_alltraps>
f01040e3:	90                   	nop    

f01040e4 <vector9>:
f01040e4:	6a 00                	push   $0x0
f01040e6:	6a 09                	push   $0x9
f01040e8:	e9 91 0a 00 00       	jmp    f0104b7e <_alltraps>
f01040ed:	90                   	nop    

f01040ee <vector10>:
f01040ee:	6a 0a                	push   $0xa
f01040f0:	e9 89 0a 00 00       	jmp    f0104b7e <_alltraps>
f01040f5:	90                   	nop    

f01040f6 <vector11>:
f01040f6:	6a 0b                	push   $0xb
f01040f8:	e9 81 0a 00 00       	jmp    f0104b7e <_alltraps>
f01040fd:	90                   	nop    

f01040fe <vector12>:
f01040fe:	6a 0c                	push   $0xc
f0104100:	e9 79 0a 00 00       	jmp    f0104b7e <_alltraps>
f0104105:	90                   	nop    

f0104106 <vector13>:
f0104106:	6a 0d                	push   $0xd
f0104108:	e9 71 0a 00 00       	jmp    f0104b7e <_alltraps>
f010410d:	90                   	nop    

f010410e <vector14>:
f010410e:	6a 0e                	push   $0xe
f0104110:	e9 69 0a 00 00       	jmp    f0104b7e <_alltraps>
f0104115:	90                   	nop    

f0104116 <vector15>:
f0104116:	6a 00                	push   $0x0
f0104118:	6a 0f                	push   $0xf
f010411a:	e9 5f 0a 00 00       	jmp    f0104b7e <_alltraps>
f010411f:	90                   	nop    

f0104120 <vector16>:
f0104120:	6a 00                	push   $0x0
f0104122:	6a 10                	push   $0x10
f0104124:	e9 55 0a 00 00       	jmp    f0104b7e <_alltraps>
f0104129:	90                   	nop    

f010412a <vector17>:
f010412a:	6a 11                	push   $0x11
f010412c:	e9 4d 0a 00 00       	jmp    f0104b7e <_alltraps>
f0104131:	90                   	nop    

f0104132 <vector18>:
f0104132:	6a 00                	push   $0x0
f0104134:	6a 12                	push   $0x12
f0104136:	e9 43 0a 00 00       	jmp    f0104b7e <_alltraps>
f010413b:	90                   	nop    

f010413c <vector19>:
f010413c:	6a 00                	push   $0x0
f010413e:	6a 13                	push   $0x13
f0104140:	e9 39 0a 00 00       	jmp    f0104b7e <_alltraps>
f0104145:	90                   	nop    

f0104146 <vector20>:
f0104146:	6a 00                	push   $0x0
f0104148:	6a 14                	push   $0x14
f010414a:	e9 2f 0a 00 00       	jmp    f0104b7e <_alltraps>
f010414f:	90                   	nop    

f0104150 <vector21>:
f0104150:	6a 00                	push   $0x0
f0104152:	6a 15                	push   $0x15
f0104154:	e9 25 0a 00 00       	jmp    f0104b7e <_alltraps>
f0104159:	90                   	nop    

f010415a <vector22>:
f010415a:	6a 00                	push   $0x0
f010415c:	6a 16                	push   $0x16
f010415e:	e9 1b 0a 00 00       	jmp    f0104b7e <_alltraps>
f0104163:	90                   	nop    

f0104164 <vector23>:
f0104164:	6a 00                	push   $0x0
f0104166:	6a 17                	push   $0x17
f0104168:	e9 11 0a 00 00       	jmp    f0104b7e <_alltraps>
f010416d:	90                   	nop    

f010416e <vector24>:
f010416e:	6a 00                	push   $0x0
f0104170:	6a 18                	push   $0x18
f0104172:	e9 07 0a 00 00       	jmp    f0104b7e <_alltraps>
f0104177:	90                   	nop    

f0104178 <vector25>:
f0104178:	6a 00                	push   $0x0
f010417a:	6a 19                	push   $0x19
f010417c:	e9 fd 09 00 00       	jmp    f0104b7e <_alltraps>
f0104181:	90                   	nop    

f0104182 <vector26>:
f0104182:	6a 00                	push   $0x0
f0104184:	6a 1a                	push   $0x1a
f0104186:	e9 f3 09 00 00       	jmp    f0104b7e <_alltraps>
f010418b:	90                   	nop    

f010418c <vector27>:
f010418c:	6a 00                	push   $0x0
f010418e:	6a 1b                	push   $0x1b
f0104190:	e9 e9 09 00 00       	jmp    f0104b7e <_alltraps>
f0104195:	90                   	nop    

f0104196 <vector28>:
f0104196:	6a 00                	push   $0x0
f0104198:	6a 1c                	push   $0x1c
f010419a:	e9 df 09 00 00       	jmp    f0104b7e <_alltraps>
f010419f:	90                   	nop    

f01041a0 <vector29>:
f01041a0:	6a 00                	push   $0x0
f01041a2:	6a 1d                	push   $0x1d
f01041a4:	e9 d5 09 00 00       	jmp    f0104b7e <_alltraps>
f01041a9:	90                   	nop    

f01041aa <vector30>:
f01041aa:	6a 00                	push   $0x0
f01041ac:	6a 1e                	push   $0x1e
f01041ae:	e9 cb 09 00 00       	jmp    f0104b7e <_alltraps>
f01041b3:	90                   	nop    

f01041b4 <vector31>:
f01041b4:	6a 00                	push   $0x0
f01041b6:	6a 1f                	push   $0x1f
f01041b8:	e9 c1 09 00 00       	jmp    f0104b7e <_alltraps>
f01041bd:	90                   	nop    

f01041be <vector32>:
f01041be:	6a 00                	push   $0x0
f01041c0:	6a 20                	push   $0x20
f01041c2:	e9 b7 09 00 00       	jmp    f0104b7e <_alltraps>
f01041c7:	90                   	nop    

f01041c8 <vector33>:
f01041c8:	6a 00                	push   $0x0
f01041ca:	6a 21                	push   $0x21
f01041cc:	e9 ad 09 00 00       	jmp    f0104b7e <_alltraps>
f01041d1:	90                   	nop    

f01041d2 <vector34>:
f01041d2:	6a 00                	push   $0x0
f01041d4:	6a 22                	push   $0x22
f01041d6:	e9 a3 09 00 00       	jmp    f0104b7e <_alltraps>
f01041db:	90                   	nop    

f01041dc <vector35>:
f01041dc:	6a 00                	push   $0x0
f01041de:	6a 23                	push   $0x23
f01041e0:	e9 99 09 00 00       	jmp    f0104b7e <_alltraps>
f01041e5:	90                   	nop    

f01041e6 <vector36>:
f01041e6:	6a 00                	push   $0x0
f01041e8:	6a 24                	push   $0x24
f01041ea:	e9 8f 09 00 00       	jmp    f0104b7e <_alltraps>
f01041ef:	90                   	nop    

f01041f0 <vector37>:
f01041f0:	6a 00                	push   $0x0
f01041f2:	6a 25                	push   $0x25
f01041f4:	e9 85 09 00 00       	jmp    f0104b7e <_alltraps>
f01041f9:	90                   	nop    

f01041fa <vector38>:
f01041fa:	6a 00                	push   $0x0
f01041fc:	6a 26                	push   $0x26
f01041fe:	e9 7b 09 00 00       	jmp    f0104b7e <_alltraps>
f0104203:	90                   	nop    

f0104204 <vector39>:
f0104204:	6a 00                	push   $0x0
f0104206:	6a 27                	push   $0x27
f0104208:	e9 71 09 00 00       	jmp    f0104b7e <_alltraps>
f010420d:	90                   	nop    

f010420e <vector40>:
f010420e:	6a 00                	push   $0x0
f0104210:	6a 28                	push   $0x28
f0104212:	e9 67 09 00 00       	jmp    f0104b7e <_alltraps>
f0104217:	90                   	nop    

f0104218 <vector41>:
f0104218:	6a 00                	push   $0x0
f010421a:	6a 29                	push   $0x29
f010421c:	e9 5d 09 00 00       	jmp    f0104b7e <_alltraps>
f0104221:	90                   	nop    

f0104222 <vector42>:
f0104222:	6a 00                	push   $0x0
f0104224:	6a 2a                	push   $0x2a
f0104226:	e9 53 09 00 00       	jmp    f0104b7e <_alltraps>
f010422b:	90                   	nop    

f010422c <vector43>:
f010422c:	6a 00                	push   $0x0
f010422e:	6a 2b                	push   $0x2b
f0104230:	e9 49 09 00 00       	jmp    f0104b7e <_alltraps>
f0104235:	90                   	nop    

f0104236 <vector44>:
f0104236:	6a 00                	push   $0x0
f0104238:	6a 2c                	push   $0x2c
f010423a:	e9 3f 09 00 00       	jmp    f0104b7e <_alltraps>
f010423f:	90                   	nop    

f0104240 <vector45>:
f0104240:	6a 00                	push   $0x0
f0104242:	6a 2d                	push   $0x2d
f0104244:	e9 35 09 00 00       	jmp    f0104b7e <_alltraps>
f0104249:	90                   	nop    

f010424a <vector46>:
f010424a:	6a 00                	push   $0x0
f010424c:	6a 2e                	push   $0x2e
f010424e:	e9 2b 09 00 00       	jmp    f0104b7e <_alltraps>
f0104253:	90                   	nop    

f0104254 <vector47>:
f0104254:	6a 00                	push   $0x0
f0104256:	6a 2f                	push   $0x2f
f0104258:	e9 21 09 00 00       	jmp    f0104b7e <_alltraps>
f010425d:	90                   	nop    

f010425e <vector48>:
f010425e:	6a 00                	push   $0x0
f0104260:	6a 30                	push   $0x30
f0104262:	e9 17 09 00 00       	jmp    f0104b7e <_alltraps>
f0104267:	90                   	nop    

f0104268 <vector49>:
f0104268:	6a 00                	push   $0x0
f010426a:	6a 31                	push   $0x31
f010426c:	e9 0d 09 00 00       	jmp    f0104b7e <_alltraps>
f0104271:	90                   	nop    

f0104272 <vector50>:
f0104272:	6a 00                	push   $0x0
f0104274:	6a 32                	push   $0x32
f0104276:	e9 03 09 00 00       	jmp    f0104b7e <_alltraps>
f010427b:	90                   	nop    

f010427c <vector51>:
f010427c:	6a 00                	push   $0x0
f010427e:	6a 33                	push   $0x33
f0104280:	e9 f9 08 00 00       	jmp    f0104b7e <_alltraps>
f0104285:	90                   	nop    

f0104286 <vector52>:
f0104286:	6a 00                	push   $0x0
f0104288:	6a 34                	push   $0x34
f010428a:	e9 ef 08 00 00       	jmp    f0104b7e <_alltraps>
f010428f:	90                   	nop    

f0104290 <vector53>:
f0104290:	6a 00                	push   $0x0
f0104292:	6a 35                	push   $0x35
f0104294:	e9 e5 08 00 00       	jmp    f0104b7e <_alltraps>
f0104299:	90                   	nop    

f010429a <vector54>:
f010429a:	6a 00                	push   $0x0
f010429c:	6a 36                	push   $0x36
f010429e:	e9 db 08 00 00       	jmp    f0104b7e <_alltraps>
f01042a3:	90                   	nop    

f01042a4 <vector55>:
f01042a4:	6a 00                	push   $0x0
f01042a6:	6a 37                	push   $0x37
f01042a8:	e9 d1 08 00 00       	jmp    f0104b7e <_alltraps>
f01042ad:	90                   	nop    

f01042ae <vector56>:
f01042ae:	6a 00                	push   $0x0
f01042b0:	6a 38                	push   $0x38
f01042b2:	e9 c7 08 00 00       	jmp    f0104b7e <_alltraps>
f01042b7:	90                   	nop    

f01042b8 <vector57>:
f01042b8:	6a 00                	push   $0x0
f01042ba:	6a 39                	push   $0x39
f01042bc:	e9 bd 08 00 00       	jmp    f0104b7e <_alltraps>
f01042c1:	90                   	nop    

f01042c2 <vector58>:
f01042c2:	6a 00                	push   $0x0
f01042c4:	6a 3a                	push   $0x3a
f01042c6:	e9 b3 08 00 00       	jmp    f0104b7e <_alltraps>
f01042cb:	90                   	nop    

f01042cc <vector59>:
f01042cc:	6a 00                	push   $0x0
f01042ce:	6a 3b                	push   $0x3b
f01042d0:	e9 a9 08 00 00       	jmp    f0104b7e <_alltraps>
f01042d5:	90                   	nop    

f01042d6 <vector60>:
f01042d6:	6a 00                	push   $0x0
f01042d8:	6a 3c                	push   $0x3c
f01042da:	e9 9f 08 00 00       	jmp    f0104b7e <_alltraps>
f01042df:	90                   	nop    

f01042e0 <vector61>:
f01042e0:	6a 00                	push   $0x0
f01042e2:	6a 3d                	push   $0x3d
f01042e4:	e9 95 08 00 00       	jmp    f0104b7e <_alltraps>
f01042e9:	90                   	nop    

f01042ea <vector62>:
f01042ea:	6a 00                	push   $0x0
f01042ec:	6a 3e                	push   $0x3e
f01042ee:	e9 8b 08 00 00       	jmp    f0104b7e <_alltraps>
f01042f3:	90                   	nop    

f01042f4 <vector63>:
f01042f4:	6a 00                	push   $0x0
f01042f6:	6a 3f                	push   $0x3f
f01042f8:	e9 81 08 00 00       	jmp    f0104b7e <_alltraps>
f01042fd:	90                   	nop    

f01042fe <vector64>:
f01042fe:	6a 00                	push   $0x0
f0104300:	6a 40                	push   $0x40
f0104302:	e9 77 08 00 00       	jmp    f0104b7e <_alltraps>
f0104307:	90                   	nop    

f0104308 <vector65>:
f0104308:	6a 00                	push   $0x0
f010430a:	6a 41                	push   $0x41
f010430c:	e9 6d 08 00 00       	jmp    f0104b7e <_alltraps>
f0104311:	90                   	nop    

f0104312 <vector66>:
f0104312:	6a 00                	push   $0x0
f0104314:	6a 42                	push   $0x42
f0104316:	e9 63 08 00 00       	jmp    f0104b7e <_alltraps>
f010431b:	90                   	nop    

f010431c <vector67>:
f010431c:	6a 00                	push   $0x0
f010431e:	6a 43                	push   $0x43
f0104320:	e9 59 08 00 00       	jmp    f0104b7e <_alltraps>
f0104325:	90                   	nop    

f0104326 <vector68>:
f0104326:	6a 00                	push   $0x0
f0104328:	6a 44                	push   $0x44
f010432a:	e9 4f 08 00 00       	jmp    f0104b7e <_alltraps>
f010432f:	90                   	nop    

f0104330 <vector69>:
f0104330:	6a 00                	push   $0x0
f0104332:	6a 45                	push   $0x45
f0104334:	e9 45 08 00 00       	jmp    f0104b7e <_alltraps>
f0104339:	90                   	nop    

f010433a <vector70>:
f010433a:	6a 00                	push   $0x0
f010433c:	6a 46                	push   $0x46
f010433e:	e9 3b 08 00 00       	jmp    f0104b7e <_alltraps>
f0104343:	90                   	nop    

f0104344 <vector71>:
f0104344:	6a 00                	push   $0x0
f0104346:	6a 47                	push   $0x47
f0104348:	e9 31 08 00 00       	jmp    f0104b7e <_alltraps>
f010434d:	90                   	nop    

f010434e <vector72>:
f010434e:	6a 00                	push   $0x0
f0104350:	6a 48                	push   $0x48
f0104352:	e9 27 08 00 00       	jmp    f0104b7e <_alltraps>
f0104357:	90                   	nop    

f0104358 <vector73>:
f0104358:	6a 00                	push   $0x0
f010435a:	6a 49                	push   $0x49
f010435c:	e9 1d 08 00 00       	jmp    f0104b7e <_alltraps>
f0104361:	90                   	nop    

f0104362 <vector74>:
f0104362:	6a 00                	push   $0x0
f0104364:	6a 4a                	push   $0x4a
f0104366:	e9 13 08 00 00       	jmp    f0104b7e <_alltraps>
f010436b:	90                   	nop    

f010436c <vector75>:
f010436c:	6a 00                	push   $0x0
f010436e:	6a 4b                	push   $0x4b
f0104370:	e9 09 08 00 00       	jmp    f0104b7e <_alltraps>
f0104375:	90                   	nop    

f0104376 <vector76>:
f0104376:	6a 00                	push   $0x0
f0104378:	6a 4c                	push   $0x4c
f010437a:	e9 ff 07 00 00       	jmp    f0104b7e <_alltraps>
f010437f:	90                   	nop    

f0104380 <vector77>:
f0104380:	6a 00                	push   $0x0
f0104382:	6a 4d                	push   $0x4d
f0104384:	e9 f5 07 00 00       	jmp    f0104b7e <_alltraps>
f0104389:	90                   	nop    

f010438a <vector78>:
f010438a:	6a 00                	push   $0x0
f010438c:	6a 4e                	push   $0x4e
f010438e:	e9 eb 07 00 00       	jmp    f0104b7e <_alltraps>
f0104393:	90                   	nop    

f0104394 <vector79>:
f0104394:	6a 00                	push   $0x0
f0104396:	6a 4f                	push   $0x4f
f0104398:	e9 e1 07 00 00       	jmp    f0104b7e <_alltraps>
f010439d:	90                   	nop    

f010439e <vector80>:
f010439e:	6a 00                	push   $0x0
f01043a0:	6a 50                	push   $0x50
f01043a2:	e9 d7 07 00 00       	jmp    f0104b7e <_alltraps>
f01043a7:	90                   	nop    

f01043a8 <vector81>:
f01043a8:	6a 00                	push   $0x0
f01043aa:	6a 51                	push   $0x51
f01043ac:	e9 cd 07 00 00       	jmp    f0104b7e <_alltraps>
f01043b1:	90                   	nop    

f01043b2 <vector82>:
f01043b2:	6a 00                	push   $0x0
f01043b4:	6a 52                	push   $0x52
f01043b6:	e9 c3 07 00 00       	jmp    f0104b7e <_alltraps>
f01043bb:	90                   	nop    

f01043bc <vector83>:
f01043bc:	6a 00                	push   $0x0
f01043be:	6a 53                	push   $0x53
f01043c0:	e9 b9 07 00 00       	jmp    f0104b7e <_alltraps>
f01043c5:	90                   	nop    

f01043c6 <vector84>:
f01043c6:	6a 00                	push   $0x0
f01043c8:	6a 54                	push   $0x54
f01043ca:	e9 af 07 00 00       	jmp    f0104b7e <_alltraps>
f01043cf:	90                   	nop    

f01043d0 <vector85>:
f01043d0:	6a 00                	push   $0x0
f01043d2:	6a 55                	push   $0x55
f01043d4:	e9 a5 07 00 00       	jmp    f0104b7e <_alltraps>
f01043d9:	90                   	nop    

f01043da <vector86>:
f01043da:	6a 00                	push   $0x0
f01043dc:	6a 56                	push   $0x56
f01043de:	e9 9b 07 00 00       	jmp    f0104b7e <_alltraps>
f01043e3:	90                   	nop    

f01043e4 <vector87>:
f01043e4:	6a 00                	push   $0x0
f01043e6:	6a 57                	push   $0x57
f01043e8:	e9 91 07 00 00       	jmp    f0104b7e <_alltraps>
f01043ed:	90                   	nop    

f01043ee <vector88>:
f01043ee:	6a 00                	push   $0x0
f01043f0:	6a 58                	push   $0x58
f01043f2:	e9 87 07 00 00       	jmp    f0104b7e <_alltraps>
f01043f7:	90                   	nop    

f01043f8 <vector89>:
f01043f8:	6a 00                	push   $0x0
f01043fa:	6a 59                	push   $0x59
f01043fc:	e9 7d 07 00 00       	jmp    f0104b7e <_alltraps>
f0104401:	90                   	nop    

f0104402 <vector90>:
f0104402:	6a 00                	push   $0x0
f0104404:	6a 5a                	push   $0x5a
f0104406:	e9 73 07 00 00       	jmp    f0104b7e <_alltraps>
f010440b:	90                   	nop    

f010440c <vector91>:
f010440c:	6a 00                	push   $0x0
f010440e:	6a 5b                	push   $0x5b
f0104410:	e9 69 07 00 00       	jmp    f0104b7e <_alltraps>
f0104415:	90                   	nop    

f0104416 <vector92>:
f0104416:	6a 00                	push   $0x0
f0104418:	6a 5c                	push   $0x5c
f010441a:	e9 5f 07 00 00       	jmp    f0104b7e <_alltraps>
f010441f:	90                   	nop    

f0104420 <vector93>:
f0104420:	6a 00                	push   $0x0
f0104422:	6a 5d                	push   $0x5d
f0104424:	e9 55 07 00 00       	jmp    f0104b7e <_alltraps>
f0104429:	90                   	nop    

f010442a <vector94>:
f010442a:	6a 00                	push   $0x0
f010442c:	6a 5e                	push   $0x5e
f010442e:	e9 4b 07 00 00       	jmp    f0104b7e <_alltraps>
f0104433:	90                   	nop    

f0104434 <vector95>:
f0104434:	6a 00                	push   $0x0
f0104436:	6a 5f                	push   $0x5f
f0104438:	e9 41 07 00 00       	jmp    f0104b7e <_alltraps>
f010443d:	90                   	nop    

f010443e <vector96>:
f010443e:	6a 00                	push   $0x0
f0104440:	6a 60                	push   $0x60
f0104442:	e9 37 07 00 00       	jmp    f0104b7e <_alltraps>
f0104447:	90                   	nop    

f0104448 <vector97>:
f0104448:	6a 00                	push   $0x0
f010444a:	6a 61                	push   $0x61
f010444c:	e9 2d 07 00 00       	jmp    f0104b7e <_alltraps>
f0104451:	90                   	nop    

f0104452 <vector98>:
f0104452:	6a 00                	push   $0x0
f0104454:	6a 62                	push   $0x62
f0104456:	e9 23 07 00 00       	jmp    f0104b7e <_alltraps>
f010445b:	90                   	nop    

f010445c <vector99>:
f010445c:	6a 00                	push   $0x0
f010445e:	6a 63                	push   $0x63
f0104460:	e9 19 07 00 00       	jmp    f0104b7e <_alltraps>
f0104465:	90                   	nop    

f0104466 <vector100>:
f0104466:	6a 00                	push   $0x0
f0104468:	6a 64                	push   $0x64
f010446a:	e9 0f 07 00 00       	jmp    f0104b7e <_alltraps>
f010446f:	90                   	nop    

f0104470 <vector101>:
f0104470:	6a 00                	push   $0x0
f0104472:	6a 65                	push   $0x65
f0104474:	e9 05 07 00 00       	jmp    f0104b7e <_alltraps>
f0104479:	90                   	nop    

f010447a <vector102>:
f010447a:	6a 00                	push   $0x0
f010447c:	6a 66                	push   $0x66
f010447e:	e9 fb 06 00 00       	jmp    f0104b7e <_alltraps>
f0104483:	90                   	nop    

f0104484 <vector103>:
f0104484:	6a 00                	push   $0x0
f0104486:	6a 67                	push   $0x67
f0104488:	e9 f1 06 00 00       	jmp    f0104b7e <_alltraps>
f010448d:	90                   	nop    

f010448e <vector104>:
f010448e:	6a 00                	push   $0x0
f0104490:	6a 68                	push   $0x68
f0104492:	e9 e7 06 00 00       	jmp    f0104b7e <_alltraps>
f0104497:	90                   	nop    

f0104498 <vector105>:
f0104498:	6a 00                	push   $0x0
f010449a:	6a 69                	push   $0x69
f010449c:	e9 dd 06 00 00       	jmp    f0104b7e <_alltraps>
f01044a1:	90                   	nop    

f01044a2 <vector106>:
f01044a2:	6a 00                	push   $0x0
f01044a4:	6a 6a                	push   $0x6a
f01044a6:	e9 d3 06 00 00       	jmp    f0104b7e <_alltraps>
f01044ab:	90                   	nop    

f01044ac <vector107>:
f01044ac:	6a 00                	push   $0x0
f01044ae:	6a 6b                	push   $0x6b
f01044b0:	e9 c9 06 00 00       	jmp    f0104b7e <_alltraps>
f01044b5:	90                   	nop    

f01044b6 <vector108>:
f01044b6:	6a 00                	push   $0x0
f01044b8:	6a 6c                	push   $0x6c
f01044ba:	e9 bf 06 00 00       	jmp    f0104b7e <_alltraps>
f01044bf:	90                   	nop    

f01044c0 <vector109>:
f01044c0:	6a 00                	push   $0x0
f01044c2:	6a 6d                	push   $0x6d
f01044c4:	e9 b5 06 00 00       	jmp    f0104b7e <_alltraps>
f01044c9:	90                   	nop    

f01044ca <vector110>:
f01044ca:	6a 00                	push   $0x0
f01044cc:	6a 6e                	push   $0x6e
f01044ce:	e9 ab 06 00 00       	jmp    f0104b7e <_alltraps>
f01044d3:	90                   	nop    

f01044d4 <vector111>:
f01044d4:	6a 00                	push   $0x0
f01044d6:	6a 6f                	push   $0x6f
f01044d8:	e9 a1 06 00 00       	jmp    f0104b7e <_alltraps>
f01044dd:	90                   	nop    

f01044de <vector112>:
f01044de:	6a 00                	push   $0x0
f01044e0:	6a 70                	push   $0x70
f01044e2:	e9 97 06 00 00       	jmp    f0104b7e <_alltraps>
f01044e7:	90                   	nop    

f01044e8 <vector113>:
f01044e8:	6a 00                	push   $0x0
f01044ea:	6a 71                	push   $0x71
f01044ec:	e9 8d 06 00 00       	jmp    f0104b7e <_alltraps>
f01044f1:	90                   	nop    

f01044f2 <vector114>:
f01044f2:	6a 00                	push   $0x0
f01044f4:	6a 72                	push   $0x72
f01044f6:	e9 83 06 00 00       	jmp    f0104b7e <_alltraps>
f01044fb:	90                   	nop    

f01044fc <vector115>:
f01044fc:	6a 00                	push   $0x0
f01044fe:	6a 73                	push   $0x73
f0104500:	e9 79 06 00 00       	jmp    f0104b7e <_alltraps>
f0104505:	90                   	nop    

f0104506 <vector116>:
f0104506:	6a 00                	push   $0x0
f0104508:	6a 74                	push   $0x74
f010450a:	e9 6f 06 00 00       	jmp    f0104b7e <_alltraps>
f010450f:	90                   	nop    

f0104510 <vector117>:
f0104510:	6a 00                	push   $0x0
f0104512:	6a 75                	push   $0x75
f0104514:	e9 65 06 00 00       	jmp    f0104b7e <_alltraps>
f0104519:	90                   	nop    

f010451a <vector118>:
f010451a:	6a 00                	push   $0x0
f010451c:	6a 76                	push   $0x76
f010451e:	e9 5b 06 00 00       	jmp    f0104b7e <_alltraps>
f0104523:	90                   	nop    

f0104524 <vector119>:
f0104524:	6a 00                	push   $0x0
f0104526:	6a 77                	push   $0x77
f0104528:	e9 51 06 00 00       	jmp    f0104b7e <_alltraps>
f010452d:	90                   	nop    

f010452e <vector120>:
f010452e:	6a 00                	push   $0x0
f0104530:	6a 78                	push   $0x78
f0104532:	e9 47 06 00 00       	jmp    f0104b7e <_alltraps>
f0104537:	90                   	nop    

f0104538 <vector121>:
f0104538:	6a 00                	push   $0x0
f010453a:	6a 79                	push   $0x79
f010453c:	e9 3d 06 00 00       	jmp    f0104b7e <_alltraps>
f0104541:	90                   	nop    

f0104542 <vector122>:
f0104542:	6a 00                	push   $0x0
f0104544:	6a 7a                	push   $0x7a
f0104546:	e9 33 06 00 00       	jmp    f0104b7e <_alltraps>
f010454b:	90                   	nop    

f010454c <vector123>:
f010454c:	6a 00                	push   $0x0
f010454e:	6a 7b                	push   $0x7b
f0104550:	e9 29 06 00 00       	jmp    f0104b7e <_alltraps>
f0104555:	90                   	nop    

f0104556 <vector124>:
f0104556:	6a 00                	push   $0x0
f0104558:	6a 7c                	push   $0x7c
f010455a:	e9 1f 06 00 00       	jmp    f0104b7e <_alltraps>
f010455f:	90                   	nop    

f0104560 <vector125>:
f0104560:	6a 00                	push   $0x0
f0104562:	6a 7d                	push   $0x7d
f0104564:	e9 15 06 00 00       	jmp    f0104b7e <_alltraps>
f0104569:	90                   	nop    

f010456a <vector126>:
f010456a:	6a 00                	push   $0x0
f010456c:	6a 7e                	push   $0x7e
f010456e:	e9 0b 06 00 00       	jmp    f0104b7e <_alltraps>
f0104573:	90                   	nop    

f0104574 <vector127>:
f0104574:	6a 00                	push   $0x0
f0104576:	6a 7f                	push   $0x7f
f0104578:	e9 01 06 00 00       	jmp    f0104b7e <_alltraps>
f010457d:	90                   	nop    

f010457e <vector128>:
f010457e:	6a 00                	push   $0x0
f0104580:	68 80 00 00 00       	push   $0x80
f0104585:	e9 f4 05 00 00       	jmp    f0104b7e <_alltraps>

f010458a <vector129>:
f010458a:	6a 00                	push   $0x0
f010458c:	68 81 00 00 00       	push   $0x81
f0104591:	e9 e8 05 00 00       	jmp    f0104b7e <_alltraps>

f0104596 <vector130>:
f0104596:	6a 00                	push   $0x0
f0104598:	68 82 00 00 00       	push   $0x82
f010459d:	e9 dc 05 00 00       	jmp    f0104b7e <_alltraps>

f01045a2 <vector131>:
f01045a2:	6a 00                	push   $0x0
f01045a4:	68 83 00 00 00       	push   $0x83
f01045a9:	e9 d0 05 00 00       	jmp    f0104b7e <_alltraps>

f01045ae <vector132>:
f01045ae:	6a 00                	push   $0x0
f01045b0:	68 84 00 00 00       	push   $0x84
f01045b5:	e9 c4 05 00 00       	jmp    f0104b7e <_alltraps>

f01045ba <vector133>:
f01045ba:	6a 00                	push   $0x0
f01045bc:	68 85 00 00 00       	push   $0x85
f01045c1:	e9 b8 05 00 00       	jmp    f0104b7e <_alltraps>

f01045c6 <vector134>:
f01045c6:	6a 00                	push   $0x0
f01045c8:	68 86 00 00 00       	push   $0x86
f01045cd:	e9 ac 05 00 00       	jmp    f0104b7e <_alltraps>

f01045d2 <vector135>:
f01045d2:	6a 00                	push   $0x0
f01045d4:	68 87 00 00 00       	push   $0x87
f01045d9:	e9 a0 05 00 00       	jmp    f0104b7e <_alltraps>

f01045de <vector136>:
f01045de:	6a 00                	push   $0x0
f01045e0:	68 88 00 00 00       	push   $0x88
f01045e5:	e9 94 05 00 00       	jmp    f0104b7e <_alltraps>

f01045ea <vector137>:
f01045ea:	6a 00                	push   $0x0
f01045ec:	68 89 00 00 00       	push   $0x89
f01045f1:	e9 88 05 00 00       	jmp    f0104b7e <_alltraps>

f01045f6 <vector138>:
f01045f6:	6a 00                	push   $0x0
f01045f8:	68 8a 00 00 00       	push   $0x8a
f01045fd:	e9 7c 05 00 00       	jmp    f0104b7e <_alltraps>

f0104602 <vector139>:
f0104602:	6a 00                	push   $0x0
f0104604:	68 8b 00 00 00       	push   $0x8b
f0104609:	e9 70 05 00 00       	jmp    f0104b7e <_alltraps>

f010460e <vector140>:
f010460e:	6a 00                	push   $0x0
f0104610:	68 8c 00 00 00       	push   $0x8c
f0104615:	e9 64 05 00 00       	jmp    f0104b7e <_alltraps>

f010461a <vector141>:
f010461a:	6a 00                	push   $0x0
f010461c:	68 8d 00 00 00       	push   $0x8d
f0104621:	e9 58 05 00 00       	jmp    f0104b7e <_alltraps>

f0104626 <vector142>:
f0104626:	6a 00                	push   $0x0
f0104628:	68 8e 00 00 00       	push   $0x8e
f010462d:	e9 4c 05 00 00       	jmp    f0104b7e <_alltraps>

f0104632 <vector143>:
f0104632:	6a 00                	push   $0x0
f0104634:	68 8f 00 00 00       	push   $0x8f
f0104639:	e9 40 05 00 00       	jmp    f0104b7e <_alltraps>

f010463e <vector144>:
f010463e:	6a 00                	push   $0x0
f0104640:	68 90 00 00 00       	push   $0x90
f0104645:	e9 34 05 00 00       	jmp    f0104b7e <_alltraps>

f010464a <vector145>:
f010464a:	6a 00                	push   $0x0
f010464c:	68 91 00 00 00       	push   $0x91
f0104651:	e9 28 05 00 00       	jmp    f0104b7e <_alltraps>

f0104656 <vector146>:
f0104656:	6a 00                	push   $0x0
f0104658:	68 92 00 00 00       	push   $0x92
f010465d:	e9 1c 05 00 00       	jmp    f0104b7e <_alltraps>

f0104662 <vector147>:
f0104662:	6a 00                	push   $0x0
f0104664:	68 93 00 00 00       	push   $0x93
f0104669:	e9 10 05 00 00       	jmp    f0104b7e <_alltraps>

f010466e <vector148>:
f010466e:	6a 00                	push   $0x0
f0104670:	68 94 00 00 00       	push   $0x94
f0104675:	e9 04 05 00 00       	jmp    f0104b7e <_alltraps>

f010467a <vector149>:
f010467a:	6a 00                	push   $0x0
f010467c:	68 95 00 00 00       	push   $0x95
f0104681:	e9 f8 04 00 00       	jmp    f0104b7e <_alltraps>

f0104686 <vector150>:
f0104686:	6a 00                	push   $0x0
f0104688:	68 96 00 00 00       	push   $0x96
f010468d:	e9 ec 04 00 00       	jmp    f0104b7e <_alltraps>

f0104692 <vector151>:
f0104692:	6a 00                	push   $0x0
f0104694:	68 97 00 00 00       	push   $0x97
f0104699:	e9 e0 04 00 00       	jmp    f0104b7e <_alltraps>

f010469e <vector152>:
f010469e:	6a 00                	push   $0x0
f01046a0:	68 98 00 00 00       	push   $0x98
f01046a5:	e9 d4 04 00 00       	jmp    f0104b7e <_alltraps>

f01046aa <vector153>:
f01046aa:	6a 00                	push   $0x0
f01046ac:	68 99 00 00 00       	push   $0x99
f01046b1:	e9 c8 04 00 00       	jmp    f0104b7e <_alltraps>

f01046b6 <vector154>:
f01046b6:	6a 00                	push   $0x0
f01046b8:	68 9a 00 00 00       	push   $0x9a
f01046bd:	e9 bc 04 00 00       	jmp    f0104b7e <_alltraps>

f01046c2 <vector155>:
f01046c2:	6a 00                	push   $0x0
f01046c4:	68 9b 00 00 00       	push   $0x9b
f01046c9:	e9 b0 04 00 00       	jmp    f0104b7e <_alltraps>

f01046ce <vector156>:
f01046ce:	6a 00                	push   $0x0
f01046d0:	68 9c 00 00 00       	push   $0x9c
f01046d5:	e9 a4 04 00 00       	jmp    f0104b7e <_alltraps>

f01046da <vector157>:
f01046da:	6a 00                	push   $0x0
f01046dc:	68 9d 00 00 00       	push   $0x9d
f01046e1:	e9 98 04 00 00       	jmp    f0104b7e <_alltraps>

f01046e6 <vector158>:
f01046e6:	6a 00                	push   $0x0
f01046e8:	68 9e 00 00 00       	push   $0x9e
f01046ed:	e9 8c 04 00 00       	jmp    f0104b7e <_alltraps>

f01046f2 <vector159>:
f01046f2:	6a 00                	push   $0x0
f01046f4:	68 9f 00 00 00       	push   $0x9f
f01046f9:	e9 80 04 00 00       	jmp    f0104b7e <_alltraps>

f01046fe <vector160>:
f01046fe:	6a 00                	push   $0x0
f0104700:	68 a0 00 00 00       	push   $0xa0
f0104705:	e9 74 04 00 00       	jmp    f0104b7e <_alltraps>

f010470a <vector161>:
f010470a:	6a 00                	push   $0x0
f010470c:	68 a1 00 00 00       	push   $0xa1
f0104711:	e9 68 04 00 00       	jmp    f0104b7e <_alltraps>

f0104716 <vector162>:
f0104716:	6a 00                	push   $0x0
f0104718:	68 a2 00 00 00       	push   $0xa2
f010471d:	e9 5c 04 00 00       	jmp    f0104b7e <_alltraps>

f0104722 <vector163>:
f0104722:	6a 00                	push   $0x0
f0104724:	68 a3 00 00 00       	push   $0xa3
f0104729:	e9 50 04 00 00       	jmp    f0104b7e <_alltraps>

f010472e <vector164>:
f010472e:	6a 00                	push   $0x0
f0104730:	68 a4 00 00 00       	push   $0xa4
f0104735:	e9 44 04 00 00       	jmp    f0104b7e <_alltraps>

f010473a <vector165>:
f010473a:	6a 00                	push   $0x0
f010473c:	68 a5 00 00 00       	push   $0xa5
f0104741:	e9 38 04 00 00       	jmp    f0104b7e <_alltraps>

f0104746 <vector166>:
f0104746:	6a 00                	push   $0x0
f0104748:	68 a6 00 00 00       	push   $0xa6
f010474d:	e9 2c 04 00 00       	jmp    f0104b7e <_alltraps>

f0104752 <vector167>:
f0104752:	6a 00                	push   $0x0
f0104754:	68 a7 00 00 00       	push   $0xa7
f0104759:	e9 20 04 00 00       	jmp    f0104b7e <_alltraps>

f010475e <vector168>:
f010475e:	6a 00                	push   $0x0
f0104760:	68 a8 00 00 00       	push   $0xa8
f0104765:	e9 14 04 00 00       	jmp    f0104b7e <_alltraps>

f010476a <vector169>:
f010476a:	6a 00                	push   $0x0
f010476c:	68 a9 00 00 00       	push   $0xa9
f0104771:	e9 08 04 00 00       	jmp    f0104b7e <_alltraps>

f0104776 <vector170>:
f0104776:	6a 00                	push   $0x0
f0104778:	68 aa 00 00 00       	push   $0xaa
f010477d:	e9 fc 03 00 00       	jmp    f0104b7e <_alltraps>

f0104782 <vector171>:
f0104782:	6a 00                	push   $0x0
f0104784:	68 ab 00 00 00       	push   $0xab
f0104789:	e9 f0 03 00 00       	jmp    f0104b7e <_alltraps>

f010478e <vector172>:
f010478e:	6a 00                	push   $0x0
f0104790:	68 ac 00 00 00       	push   $0xac
f0104795:	e9 e4 03 00 00       	jmp    f0104b7e <_alltraps>

f010479a <vector173>:
f010479a:	6a 00                	push   $0x0
f010479c:	68 ad 00 00 00       	push   $0xad
f01047a1:	e9 d8 03 00 00       	jmp    f0104b7e <_alltraps>

f01047a6 <vector174>:
f01047a6:	6a 00                	push   $0x0
f01047a8:	68 ae 00 00 00       	push   $0xae
f01047ad:	e9 cc 03 00 00       	jmp    f0104b7e <_alltraps>

f01047b2 <vector175>:
f01047b2:	6a 00                	push   $0x0
f01047b4:	68 af 00 00 00       	push   $0xaf
f01047b9:	e9 c0 03 00 00       	jmp    f0104b7e <_alltraps>

f01047be <vector176>:
f01047be:	6a 00                	push   $0x0
f01047c0:	68 b0 00 00 00       	push   $0xb0
f01047c5:	e9 b4 03 00 00       	jmp    f0104b7e <_alltraps>

f01047ca <vector177>:
f01047ca:	6a 00                	push   $0x0
f01047cc:	68 b1 00 00 00       	push   $0xb1
f01047d1:	e9 a8 03 00 00       	jmp    f0104b7e <_alltraps>

f01047d6 <vector178>:
f01047d6:	6a 00                	push   $0x0
f01047d8:	68 b2 00 00 00       	push   $0xb2
f01047dd:	e9 9c 03 00 00       	jmp    f0104b7e <_alltraps>

f01047e2 <vector179>:
f01047e2:	6a 00                	push   $0x0
f01047e4:	68 b3 00 00 00       	push   $0xb3
f01047e9:	e9 90 03 00 00       	jmp    f0104b7e <_alltraps>

f01047ee <vector180>:
f01047ee:	6a 00                	push   $0x0
f01047f0:	68 b4 00 00 00       	push   $0xb4
f01047f5:	e9 84 03 00 00       	jmp    f0104b7e <_alltraps>

f01047fa <vector181>:
f01047fa:	6a 00                	push   $0x0
f01047fc:	68 b5 00 00 00       	push   $0xb5
f0104801:	e9 78 03 00 00       	jmp    f0104b7e <_alltraps>

f0104806 <vector182>:
f0104806:	6a 00                	push   $0x0
f0104808:	68 b6 00 00 00       	push   $0xb6
f010480d:	e9 6c 03 00 00       	jmp    f0104b7e <_alltraps>

f0104812 <vector183>:
f0104812:	6a 00                	push   $0x0
f0104814:	68 b7 00 00 00       	push   $0xb7
f0104819:	e9 60 03 00 00       	jmp    f0104b7e <_alltraps>

f010481e <vector184>:
f010481e:	6a 00                	push   $0x0
f0104820:	68 b8 00 00 00       	push   $0xb8
f0104825:	e9 54 03 00 00       	jmp    f0104b7e <_alltraps>

f010482a <vector185>:
f010482a:	6a 00                	push   $0x0
f010482c:	68 b9 00 00 00       	push   $0xb9
f0104831:	e9 48 03 00 00       	jmp    f0104b7e <_alltraps>

f0104836 <vector186>:
f0104836:	6a 00                	push   $0x0
f0104838:	68 ba 00 00 00       	push   $0xba
f010483d:	e9 3c 03 00 00       	jmp    f0104b7e <_alltraps>

f0104842 <vector187>:
f0104842:	6a 00                	push   $0x0
f0104844:	68 bb 00 00 00       	push   $0xbb
f0104849:	e9 30 03 00 00       	jmp    f0104b7e <_alltraps>

f010484e <vector188>:
f010484e:	6a 00                	push   $0x0
f0104850:	68 bc 00 00 00       	push   $0xbc
f0104855:	e9 24 03 00 00       	jmp    f0104b7e <_alltraps>

f010485a <vector189>:
f010485a:	6a 00                	push   $0x0
f010485c:	68 bd 00 00 00       	push   $0xbd
f0104861:	e9 18 03 00 00       	jmp    f0104b7e <_alltraps>

f0104866 <vector190>:
f0104866:	6a 00                	push   $0x0
f0104868:	68 be 00 00 00       	push   $0xbe
f010486d:	e9 0c 03 00 00       	jmp    f0104b7e <_alltraps>

f0104872 <vector191>:
f0104872:	6a 00                	push   $0x0
f0104874:	68 bf 00 00 00       	push   $0xbf
f0104879:	e9 00 03 00 00       	jmp    f0104b7e <_alltraps>

f010487e <vector192>:
f010487e:	6a 00                	push   $0x0
f0104880:	68 c0 00 00 00       	push   $0xc0
f0104885:	e9 f4 02 00 00       	jmp    f0104b7e <_alltraps>

f010488a <vector193>:
f010488a:	6a 00                	push   $0x0
f010488c:	68 c1 00 00 00       	push   $0xc1
f0104891:	e9 e8 02 00 00       	jmp    f0104b7e <_alltraps>

f0104896 <vector194>:
f0104896:	6a 00                	push   $0x0
f0104898:	68 c2 00 00 00       	push   $0xc2
f010489d:	e9 dc 02 00 00       	jmp    f0104b7e <_alltraps>

f01048a2 <vector195>:
f01048a2:	6a 00                	push   $0x0
f01048a4:	68 c3 00 00 00       	push   $0xc3
f01048a9:	e9 d0 02 00 00       	jmp    f0104b7e <_alltraps>

f01048ae <vector196>:
f01048ae:	6a 00                	push   $0x0
f01048b0:	68 c4 00 00 00       	push   $0xc4
f01048b5:	e9 c4 02 00 00       	jmp    f0104b7e <_alltraps>

f01048ba <vector197>:
f01048ba:	6a 00                	push   $0x0
f01048bc:	68 c5 00 00 00       	push   $0xc5
f01048c1:	e9 b8 02 00 00       	jmp    f0104b7e <_alltraps>

f01048c6 <vector198>:
f01048c6:	6a 00                	push   $0x0
f01048c8:	68 c6 00 00 00       	push   $0xc6
f01048cd:	e9 ac 02 00 00       	jmp    f0104b7e <_alltraps>

f01048d2 <vector199>:
f01048d2:	6a 00                	push   $0x0
f01048d4:	68 c7 00 00 00       	push   $0xc7
f01048d9:	e9 a0 02 00 00       	jmp    f0104b7e <_alltraps>

f01048de <vector200>:
f01048de:	6a 00                	push   $0x0
f01048e0:	68 c8 00 00 00       	push   $0xc8
f01048e5:	e9 94 02 00 00       	jmp    f0104b7e <_alltraps>

f01048ea <vector201>:
f01048ea:	6a 00                	push   $0x0
f01048ec:	68 c9 00 00 00       	push   $0xc9
f01048f1:	e9 88 02 00 00       	jmp    f0104b7e <_alltraps>

f01048f6 <vector202>:
f01048f6:	6a 00                	push   $0x0
f01048f8:	68 ca 00 00 00       	push   $0xca
f01048fd:	e9 7c 02 00 00       	jmp    f0104b7e <_alltraps>

f0104902 <vector203>:
f0104902:	6a 00                	push   $0x0
f0104904:	68 cb 00 00 00       	push   $0xcb
f0104909:	e9 70 02 00 00       	jmp    f0104b7e <_alltraps>

f010490e <vector204>:
f010490e:	6a 00                	push   $0x0
f0104910:	68 cc 00 00 00       	push   $0xcc
f0104915:	e9 64 02 00 00       	jmp    f0104b7e <_alltraps>

f010491a <vector205>:
f010491a:	6a 00                	push   $0x0
f010491c:	68 cd 00 00 00       	push   $0xcd
f0104921:	e9 58 02 00 00       	jmp    f0104b7e <_alltraps>

f0104926 <vector206>:
f0104926:	6a 00                	push   $0x0
f0104928:	68 ce 00 00 00       	push   $0xce
f010492d:	e9 4c 02 00 00       	jmp    f0104b7e <_alltraps>

f0104932 <vector207>:
f0104932:	6a 00                	push   $0x0
f0104934:	68 cf 00 00 00       	push   $0xcf
f0104939:	e9 40 02 00 00       	jmp    f0104b7e <_alltraps>

f010493e <vector208>:
f010493e:	6a 00                	push   $0x0
f0104940:	68 d0 00 00 00       	push   $0xd0
f0104945:	e9 34 02 00 00       	jmp    f0104b7e <_alltraps>

f010494a <vector209>:
f010494a:	6a 00                	push   $0x0
f010494c:	68 d1 00 00 00       	push   $0xd1
f0104951:	e9 28 02 00 00       	jmp    f0104b7e <_alltraps>

f0104956 <vector210>:
f0104956:	6a 00                	push   $0x0
f0104958:	68 d2 00 00 00       	push   $0xd2
f010495d:	e9 1c 02 00 00       	jmp    f0104b7e <_alltraps>

f0104962 <vector211>:
f0104962:	6a 00                	push   $0x0
f0104964:	68 d3 00 00 00       	push   $0xd3
f0104969:	e9 10 02 00 00       	jmp    f0104b7e <_alltraps>

f010496e <vector212>:
f010496e:	6a 00                	push   $0x0
f0104970:	68 d4 00 00 00       	push   $0xd4
f0104975:	e9 04 02 00 00       	jmp    f0104b7e <_alltraps>

f010497a <vector213>:
f010497a:	6a 00                	push   $0x0
f010497c:	68 d5 00 00 00       	push   $0xd5
f0104981:	e9 f8 01 00 00       	jmp    f0104b7e <_alltraps>

f0104986 <vector214>:
f0104986:	6a 00                	push   $0x0
f0104988:	68 d6 00 00 00       	push   $0xd6
f010498d:	e9 ec 01 00 00       	jmp    f0104b7e <_alltraps>

f0104992 <vector215>:
f0104992:	6a 00                	push   $0x0
f0104994:	68 d7 00 00 00       	push   $0xd7
f0104999:	e9 e0 01 00 00       	jmp    f0104b7e <_alltraps>

f010499e <vector216>:
f010499e:	6a 00                	push   $0x0
f01049a0:	68 d8 00 00 00       	push   $0xd8
f01049a5:	e9 d4 01 00 00       	jmp    f0104b7e <_alltraps>

f01049aa <vector217>:
f01049aa:	6a 00                	push   $0x0
f01049ac:	68 d9 00 00 00       	push   $0xd9
f01049b1:	e9 c8 01 00 00       	jmp    f0104b7e <_alltraps>

f01049b6 <vector218>:
f01049b6:	6a 00                	push   $0x0
f01049b8:	68 da 00 00 00       	push   $0xda
f01049bd:	e9 bc 01 00 00       	jmp    f0104b7e <_alltraps>

f01049c2 <vector219>:
f01049c2:	6a 00                	push   $0x0
f01049c4:	68 db 00 00 00       	push   $0xdb
f01049c9:	e9 b0 01 00 00       	jmp    f0104b7e <_alltraps>

f01049ce <vector220>:
f01049ce:	6a 00                	push   $0x0
f01049d0:	68 dc 00 00 00       	push   $0xdc
f01049d5:	e9 a4 01 00 00       	jmp    f0104b7e <_alltraps>

f01049da <vector221>:
f01049da:	6a 00                	push   $0x0
f01049dc:	68 dd 00 00 00       	push   $0xdd
f01049e1:	e9 98 01 00 00       	jmp    f0104b7e <_alltraps>

f01049e6 <vector222>:
f01049e6:	6a 00                	push   $0x0
f01049e8:	68 de 00 00 00       	push   $0xde
f01049ed:	e9 8c 01 00 00       	jmp    f0104b7e <_alltraps>

f01049f2 <vector223>:
f01049f2:	6a 00                	push   $0x0
f01049f4:	68 df 00 00 00       	push   $0xdf
f01049f9:	e9 80 01 00 00       	jmp    f0104b7e <_alltraps>

f01049fe <vector224>:
f01049fe:	6a 00                	push   $0x0
f0104a00:	68 e0 00 00 00       	push   $0xe0
f0104a05:	e9 74 01 00 00       	jmp    f0104b7e <_alltraps>

f0104a0a <vector225>:
f0104a0a:	6a 00                	push   $0x0
f0104a0c:	68 e1 00 00 00       	push   $0xe1
f0104a11:	e9 68 01 00 00       	jmp    f0104b7e <_alltraps>

f0104a16 <vector226>:
f0104a16:	6a 00                	push   $0x0
f0104a18:	68 e2 00 00 00       	push   $0xe2
f0104a1d:	e9 5c 01 00 00       	jmp    f0104b7e <_alltraps>

f0104a22 <vector227>:
f0104a22:	6a 00                	push   $0x0
f0104a24:	68 e3 00 00 00       	push   $0xe3
f0104a29:	e9 50 01 00 00       	jmp    f0104b7e <_alltraps>

f0104a2e <vector228>:
f0104a2e:	6a 00                	push   $0x0
f0104a30:	68 e4 00 00 00       	push   $0xe4
f0104a35:	e9 44 01 00 00       	jmp    f0104b7e <_alltraps>

f0104a3a <vector229>:
f0104a3a:	6a 00                	push   $0x0
f0104a3c:	68 e5 00 00 00       	push   $0xe5
f0104a41:	e9 38 01 00 00       	jmp    f0104b7e <_alltraps>

f0104a46 <vector230>:
f0104a46:	6a 00                	push   $0x0
f0104a48:	68 e6 00 00 00       	push   $0xe6
f0104a4d:	e9 2c 01 00 00       	jmp    f0104b7e <_alltraps>

f0104a52 <vector231>:
f0104a52:	6a 00                	push   $0x0
f0104a54:	68 e7 00 00 00       	push   $0xe7
f0104a59:	e9 20 01 00 00       	jmp    f0104b7e <_alltraps>

f0104a5e <vector232>:
f0104a5e:	6a 00                	push   $0x0
f0104a60:	68 e8 00 00 00       	push   $0xe8
f0104a65:	e9 14 01 00 00       	jmp    f0104b7e <_alltraps>

f0104a6a <vector233>:
f0104a6a:	6a 00                	push   $0x0
f0104a6c:	68 e9 00 00 00       	push   $0xe9
f0104a71:	e9 08 01 00 00       	jmp    f0104b7e <_alltraps>

f0104a76 <vector234>:
f0104a76:	6a 00                	push   $0x0
f0104a78:	68 ea 00 00 00       	push   $0xea
f0104a7d:	e9 fc 00 00 00       	jmp    f0104b7e <_alltraps>

f0104a82 <vector235>:
f0104a82:	6a 00                	push   $0x0
f0104a84:	68 eb 00 00 00       	push   $0xeb
f0104a89:	e9 f0 00 00 00       	jmp    f0104b7e <_alltraps>

f0104a8e <vector236>:
f0104a8e:	6a 00                	push   $0x0
f0104a90:	68 ec 00 00 00       	push   $0xec
f0104a95:	e9 e4 00 00 00       	jmp    f0104b7e <_alltraps>

f0104a9a <vector237>:
f0104a9a:	6a 00                	push   $0x0
f0104a9c:	68 ed 00 00 00       	push   $0xed
f0104aa1:	e9 d8 00 00 00       	jmp    f0104b7e <_alltraps>

f0104aa6 <vector238>:
f0104aa6:	6a 00                	push   $0x0
f0104aa8:	68 ee 00 00 00       	push   $0xee
f0104aad:	e9 cc 00 00 00       	jmp    f0104b7e <_alltraps>

f0104ab2 <vector239>:
f0104ab2:	6a 00                	push   $0x0
f0104ab4:	68 ef 00 00 00       	push   $0xef
f0104ab9:	e9 c0 00 00 00       	jmp    f0104b7e <_alltraps>

f0104abe <vector240>:
f0104abe:	6a 00                	push   $0x0
f0104ac0:	68 f0 00 00 00       	push   $0xf0
f0104ac5:	e9 b4 00 00 00       	jmp    f0104b7e <_alltraps>

f0104aca <vector241>:
f0104aca:	6a 00                	push   $0x0
f0104acc:	68 f1 00 00 00       	push   $0xf1
f0104ad1:	e9 a8 00 00 00       	jmp    f0104b7e <_alltraps>

f0104ad6 <vector242>:
f0104ad6:	6a 00                	push   $0x0
f0104ad8:	68 f2 00 00 00       	push   $0xf2
f0104add:	e9 9c 00 00 00       	jmp    f0104b7e <_alltraps>

f0104ae2 <vector243>:
f0104ae2:	6a 00                	push   $0x0
f0104ae4:	68 f3 00 00 00       	push   $0xf3
f0104ae9:	e9 90 00 00 00       	jmp    f0104b7e <_alltraps>

f0104aee <vector244>:
f0104aee:	6a 00                	push   $0x0
f0104af0:	68 f4 00 00 00       	push   $0xf4
f0104af5:	e9 84 00 00 00       	jmp    f0104b7e <_alltraps>

f0104afa <vector245>:
f0104afa:	6a 00                	push   $0x0
f0104afc:	68 f5 00 00 00       	push   $0xf5
f0104b01:	e9 78 00 00 00       	jmp    f0104b7e <_alltraps>

f0104b06 <vector246>:
f0104b06:	6a 00                	push   $0x0
f0104b08:	68 f6 00 00 00       	push   $0xf6
f0104b0d:	e9 6c 00 00 00       	jmp    f0104b7e <_alltraps>

f0104b12 <vector247>:
f0104b12:	6a 00                	push   $0x0
f0104b14:	68 f7 00 00 00       	push   $0xf7
f0104b19:	e9 60 00 00 00       	jmp    f0104b7e <_alltraps>

f0104b1e <vector248>:
f0104b1e:	6a 00                	push   $0x0
f0104b20:	68 f8 00 00 00       	push   $0xf8
f0104b25:	e9 54 00 00 00       	jmp    f0104b7e <_alltraps>

f0104b2a <vector249>:
f0104b2a:	6a 00                	push   $0x0
f0104b2c:	68 f9 00 00 00       	push   $0xf9
f0104b31:	e9 48 00 00 00       	jmp    f0104b7e <_alltraps>

f0104b36 <vector250>:
f0104b36:	6a 00                	push   $0x0
f0104b38:	68 fa 00 00 00       	push   $0xfa
f0104b3d:	e9 3c 00 00 00       	jmp    f0104b7e <_alltraps>

f0104b42 <vector251>:
f0104b42:	6a 00                	push   $0x0
f0104b44:	68 fb 00 00 00       	push   $0xfb
f0104b49:	e9 30 00 00 00       	jmp    f0104b7e <_alltraps>

f0104b4e <vector252>:
f0104b4e:	6a 00                	push   $0x0
f0104b50:	68 fc 00 00 00       	push   $0xfc
f0104b55:	e9 24 00 00 00       	jmp    f0104b7e <_alltraps>

f0104b5a <vector253>:
f0104b5a:	6a 00                	push   $0x0
f0104b5c:	68 fd 00 00 00       	push   $0xfd
f0104b61:	e9 18 00 00 00       	jmp    f0104b7e <_alltraps>

f0104b66 <vector254>:
f0104b66:	6a 00                	push   $0x0
f0104b68:	68 fe 00 00 00       	push   $0xfe
f0104b6d:	e9 0c 00 00 00       	jmp    f0104b7e <_alltraps>

f0104b72 <vector255>:
f0104b72:	6a 00                	push   $0x0
f0104b74:	68 ff 00 00 00       	push   $0xff
f0104b79:	e9 00 00 00 00       	jmp    f0104b7e <_alltraps>

f0104b7e <_alltraps>:
f0104b7e:	1e                   	push   %ds
f0104b7f:	06                   	push   %es
f0104b80:	60                   	pusha  
f0104b81:	66 b8 10 00          	mov    $0x10,%ax
f0104b85:	8e d8                	movl   %eax,%ds
f0104b87:	8e c0                	movl   %eax,%es
f0104b89:	54                   	push   %esp
f0104b8a:	e8 66 f3 ff ff       	call   f0103ef5 <trap>
f0104b8f:	83 c4 04             	add    $0x4,%esp

f0104b92 <trapret>:
f0104b92:	83 c4 04             	add    $0x4,%esp
f0104b95:	61                   	popa   
f0104b96:	07                   	pop    %es
f0104b97:	1f                   	pop    %ds
f0104b98:	83 c4 08             	add    $0x8,%esp
f0104b9b:	cf                   	iret   

f0104b9c <sched_yield>:
// Choose a user environment to run and run it.
//根据调度算法选择待运行的进程，运行选择的进程
void
sched_yield(void)
{
f0104b9c:	55                   	push   %ebp
f0104b9d:	89 e5                	mov    %esp,%ebp
f0104b9f:	56                   	push   %esi
f0104ba0:	53                   	push   %ebx
f0104ba1:	83 ec 10             	sub    $0x10,%esp
	// Implement simple round-robin scheduling.
	// Search through 'envs' for a runnable environment,
	// in circular fashion starting after the previously running env,
	// and switch to the first such environment found.
	// It's OK to choose the previously running env if no other env
	// is runnable.
	// But never choose envs[0], the idle environment,
	// unless NOTHING else is runnable.

	// LAB 4: Your code here.
	uint32_t retesp;
	envid_t envid;
	int index=0,i;
	if(curenv){
f0104ba4:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0104ba9:	be 00 00 00 00       	mov    $0x0,%esi
f0104bae:	85 c0                	test   %eax,%eax
f0104bb0:	74 1b                	je     f0104bcd <sched_yield+0x31>
		//retesp=curenv->env_tf.tf_regs.reg_oesp-0x20;
		index=ENVX(curenv->env_id)-ENVX(envs[0].env_id);
f0104bb2:	8b 40 4c             	mov    0x4c(%eax),%eax
f0104bb5:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104bba:	8b 15 c0 88 2a f0    	mov    0xf02a88c0,%edx
f0104bc0:	8b 52 4c             	mov    0x4c(%edx),%edx
f0104bc3:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0104bc9:	89 c6                	mov    %eax,%esi
f0104bcb:	29 d6                	sub    %edx,%esi
		//cprintf("curenv->env_id=%x\n",curenv->env_id);
	}
	//cprintf("all:");
	//for(i=0;i<NENV;i++)
	//	if(envs[i].env_status==ENV_RUNNABLE)
	//	{
	//		cprintf("envs[%d].env_id=%x  ",i,envs[i].env_id);
	//	}
	//for(i=index+1;i<NENV;i++)
	//	if(envs[i].env_status==ENV_RUNNABLE)
	//	{
	//		env_run(&envs[i]);
	//		write_esp(retesp);
	//		trapret();
	//	}
	//for(i=1;i<=index;i++)
	//	if(envs[i].env_status==ENV_RUNNABLE)
	//	{
	//		env_run(&envs[i]);
	//		write_esp(retesp);
	//		trapret();
	//	}
	//下面代码更简洁
	for(i=1;i<=NENV;i++)
	{
		envid=(i+index)%NENV;
		if(envs[envid].env_status==ENV_RUNNABLE)
f0104bcd:	8b 1d c0 88 2a f0    	mov    0xf02a88c0,%ebx
f0104bd3:	b9 01 00 00 00       	mov    $0x1,%ecx
f0104bd8:	8d 04 31             	lea    (%ecx,%esi,1),%eax
f0104bdb:	89 c2                	mov    %eax,%edx
f0104bdd:	c1 fa 1f             	sar    $0x1f,%edx
f0104be0:	c1 ea 16             	shr    $0x16,%edx
f0104be3:	01 d0                	add    %edx,%eax
f0104be5:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104bea:	29 d0                	sub    %edx,%eax
f0104bec:	89 c2                	mov    %eax,%edx
f0104bee:	6b c0 7c             	imul   $0x7c,%eax,%eax
f0104bf1:	01 d8                	add    %ebx,%eax
f0104bf3:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104bf7:	75 0c                	jne    f0104c05 <sched_yield+0x69>
		{
			if(envid==0)
f0104bf9:	85 d2                	test   %edx,%edx
f0104bfb:	74 08                	je     f0104c05 <sched_yield+0x69>
				continue;
			//cprintf("\nslected env:%x\n",envs[envid].env_id);
			env_run(&envs[envid]);
f0104bfd:	89 04 24             	mov    %eax,(%esp)
f0104c00:	e8 73 e6 ff ff       	call   f0103278 <env_run>
f0104c05:	83 c1 01             	add    $0x1,%ecx
f0104c08:	81 f9 01 04 00 00    	cmp    $0x401,%ecx
f0104c0e:	75 c8                	jne    f0104bd8 <sched_yield+0x3c>
			//write_esp(retesp);
			//trapret();
		}
	}
	// Run the special idle environment when nothing else is runnable.
	if (envs[0].env_status == ENV_RUNNABLE)
f0104c10:	83 7b 54 01          	cmpl   $0x1,0x54(%ebx)
f0104c14:	75 08                	jne    f0104c1e <sched_yield+0x82>
		env_run(&envs[0]);
f0104c16:	89 1c 24             	mov    %ebx,(%esp)
f0104c19:	e8 5a e6 ff ff       	call   f0103278 <env_run>
	else {
		cprintf("Destroyed all environments - nothing more to do!\n");
f0104c1e:	c7 04 24 70 be 10 f0 	movl   $0xf010be70,(%esp)
f0104c25:	e8 0d ee ff ff       	call   f0103a37 <cprintf>
		while (1)
			monitor(NULL);
f0104c2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104c31:	e8 61 bd ff ff       	call   f0100997 <monitor>
f0104c36:	eb f2                	jmp    f0104c2a <sched_yield+0x8e>
	...

f0104c40 <sys_page_map>:
//	-E_NO_MEM if there's no memory to allocate any necessary page tables.
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
f0104c40:	55                   	push   %ebp
f0104c41:	89 e5                	mov    %esp,%ebp
f0104c43:	83 ec 38             	sub    $0x38,%esp
f0104c46:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
f0104c49:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
f0104c4c:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
f0104c4f:	89 c3                	mov    %eax,%ebx
f0104c51:	89 d7                	mov    %edx,%edi
f0104c53:	89 ce                	mov    %ecx,%esi
	// Hint: This function is a wrapper around page_lookup() and
	//   page_insert() from kern/pmap.c.
	//   Again, most of the new code you write should be to check the
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	int r;
	struct Env *srcenv,*dstenv;
	struct Page *pg;
	pte_t *pte;
	physaddr_t old_cr3;
	//cprintf("srcenvid=%x dstenvid=%x srcva=%x dstva=%x perm=%x\n",srcenvid,dstenvid,(uint32_t)srcva,(uint32_t)dstva,perm);
	if(srcenvid==0)
f0104c55:	85 c0                	test   %eax,%eax
f0104c57:	75 0a                	jne    f0104c63 <sys_page_map+0x23>
		srcenv=curenv;
f0104c59:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0104c5e:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
f0104c61:	eb 1f                	jmp    f0104c82 <sys_page_map+0x42>
	else
		if((r=envid2env(srcenvid,&srcenv,0))<0)//LAB 5:be carefull to use envid2env
f0104c63:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104c6a:	00 
f0104c6b:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0104c6e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c72:	89 1c 24             	mov    %ebx,(%esp)
f0104c75:	e8 e6 e4 ff ff       	call   f0103160 <envid2env>
f0104c7a:	85 c0                	test   %eax,%eax
f0104c7c:	0f 88 c2 00 00 00    	js     f0104d44 <sys_page_map+0x104>
        	{
                	return r;
        	}
	if(dstenvid==0)
f0104c82:	85 f6                	test   %esi,%esi
f0104c84:	75 0a                	jne    f0104c90 <sys_page_map+0x50>
		dstenv=curenv;
f0104c86:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0104c8b:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
f0104c8e:	eb 1f                	jmp    f0104caf <sys_page_map+0x6f>
	else
		if((r=envid2env(dstenvid,&dstenv,0))<0)
f0104c90:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104c97:	00 
f0104c98:	8d 45 ec             	lea    0xffffffec(%ebp),%eax
f0104c9b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c9f:	89 34 24             	mov    %esi,(%esp)
f0104ca2:	e8 b9 e4 ff ff       	call   f0103160 <envid2env>
f0104ca7:	85 c0                	test   %eax,%eax
f0104ca9:	0f 88 95 00 00 00    	js     f0104d44 <sys_page_map+0x104>
        	{
                	return r;
        	}
	if(((uint32_t)srcva>=UTOP)||((uint32_t)srcva&0xfff)||((uint32_t)dstva>=UTOP)||((uint32_t)srcva&0xfff))
f0104caf:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0104cb5:	0f 87 84 00 00 00    	ja     f0104d3f <sys_page_map+0xff>
f0104cbb:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0104cc1:	75 7c                	jne    f0104d3f <sys_page_map+0xff>
f0104cc3:	81 7d 08 ff ff bf ee 	cmpl   $0xeebfffff,0x8(%ebp)
f0104cca:	77 73                	ja     f0104d3f <sys_page_map+0xff>
                return -E_INVAL;
	if(perm&(~PTE_USER))
f0104ccc:	f7 45 0c f8 f1 ff ff 	testl  $0xfffff1f8,0xc(%ebp)
f0104cd3:	75 6a                	jne    f0104d3f <sys_page_map+0xff>
static __inline uint32_t
rcr3(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr3,%0" : "=r" (val));
f0104cd5:	0f 20 db             	mov    %cr3,%ebx
                return -E_INVAL;
	old_cr3=rcr3();
	lcr3(srcenv->env_cr3);
f0104cd8:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104cdb:	8b 42 60             	mov    0x60(%edx),%eax
f0104cde:	0f 22 d8             	mov    %eax,%cr3
	if(!(pg=page_lookup(srcenv->env_pgdir,srcva,&pte)))
f0104ce1:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f0104ce4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104ce8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104cec:	8b 42 5c             	mov    0x5c(%edx),%eax
f0104cef:	89 04 24             	mov    %eax,(%esp)
f0104cf2:	e8 36 c7 ff ff       	call   f010142d <page_lookup>
f0104cf7:	89 c1                	mov    %eax,%ecx
f0104cf9:	85 c0                	test   %eax,%eax
f0104cfb:	74 42                	je     f0104d3f <sys_page_map+0xff>
		return -E_INVAL;
	if(!(*pte&PTE_W)&&(perm&PTE_W))	//当srcva页面是只读时，perm不能有写权限
f0104cfd:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f0104d00:	f6 00 02             	testb  $0x2,(%eax)
f0104d03:	75 06                	jne    f0104d0b <sys_page_map+0xcb>
f0104d05:	f6 45 0c 02          	testb  $0x2,0xc(%ebp)
f0104d09:	75 34                	jne    f0104d3f <sys_page_map+0xff>
		return -E_INVAL;
	lcr3(dstenv->env_cr3);
f0104d0b:	8b 45 ec             	mov    0xffffffec(%ebp),%eax

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104d0e:	8b 50 60             	mov    0x60(%eax),%edx
f0104d11:	0f 22 da             	mov    %edx,%cr3
	if((r=page_insert(dstenv->env_pgdir,pg,dstva,perm))<0)
f0104d14:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104d17:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104d1b:	8b 55 08             	mov    0x8(%ebp),%edx
f0104d1e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104d22:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104d26:	8b 40 5c             	mov    0x5c(%eax),%eax
f0104d29:	89 04 24             	mov    %eax,(%esp)
f0104d2c:	e8 88 c9 ff ff       	call   f01016b9 <page_insert>
f0104d31:	85 c0                	test   %eax,%eax
f0104d33:	78 0f                	js     f0104d44 <sys_page_map+0x104>

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104d35:	0f 22 db             	mov    %ebx,%cr3
f0104d38:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d3d:	eb 05                	jmp    f0104d44 <sys_page_map+0x104>
		return r;
	lcr3(old_cr3);
	return 0;
f0104d3f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	//panic("sys_page_map not implemented");
}
f0104d44:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
f0104d47:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
f0104d4a:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
f0104d4d:	89 ec                	mov    %ebp,%esp
f0104d4f:	5d                   	pop    %ebp
f0104d50:	c3                   	ret    

f0104d51 <syscall>:

// Unmap the page of memory at 'va' in the address space of 'envid'.
// If no page is mapped, the function silently succeeds.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
static int
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	int r;
	struct Env *e;
	physaddr_t old_cr3;
	if(envid==0)
		e=curenv;
	else
		if((r=envid2env(envid,&e,0))<0)
        	{
                	return r;
        	}
        if((uint32_t)va>=UTOP||((uint32_t)va&0xfff))
                return -E_INVAL;
	old_cr3=rcr3();
	lcr3(e->env_cr3);
	page_remove(e->env_pgdir,va);
	lcr3(old_cr3);
	return 0;
	//panic("sys_page_unmap not implemented");
}

// Try to send 'value' to the target env 'envid'.
// If srcva < UTOP, then also send page currently mapped at 'srcva',
// so that receiver gets a duplicate mapping of the same page.
//
// The send fails with a return value of -E_IPC_NOT_RECV if the
// target is not blocked, waiting for an IPC.
//
// The send also can fail for the other reasons listed below.
//
// Otherwise, the send succeeds, and the target's ipc fields are
// updated as follows:
//    env_ipc_recving is set to 0 to block future sends;
//    env_ipc_from is set to the sending envid;
//    env_ipc_value is set to the 'value' parameter;
//    env_ipc_perm is set to 'perm' if a page was transferred, 0 otherwise.
// The target environment is marked runnable again, returning 0
// from the paused sys_ipc_recv system call.  (Hint: does the
// sys_ipc_recv function ever actually return?)
//
// If the sender wants to send a page but the receiver isn't asking for one,
// then no page mapping is transferred, but no error occurs.
// The ipc only happens when no errors occur.
//
// Returns 0 on success, < 0 on error.
// Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist.
//		(No need to check permissions.)
//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
//		or another environment managed to send first.
//	-E_INVAL if srcva < UTOP but srcva is not page-aligned.
//	-E_INVAL if srcva < UTOP and perm is inappropriate
//		(see sys_page_alloc).
//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's
//		address space.
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in the
//		current environment's address space.
//	-E_NO_MEM if there's not enough memory to map srcva in envid's
//		address space.
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	int r;
	struct Env *e;
	struct Page *pg;
	pte_t *pte;
	uint32_t srcaddr=0;
	//cprintf("sys_ipc_try_send:here envid=%x\n",envid);
	//当一个环境正在等待接收一个信息，任何其他环境都能给它发送信息
	//这不限于特定环境，也不需要发送环境与接收环境有父子关系，
	//envid2env中的第3个参数置0
	//下面用到了页面映射函数，因此也需要该函数中的envid2env中的第3个参数置0
	if((envid==0)||(envid==curenv->env_id))
	{
		cprintf("the same send:envid=%x\n",curenv->env_id);
		e=curenv;
	}
	else
		if((r=envid2env(envid,&e,0))<0)
		{
			cprintf("envid2env:id=%x\n",envid);
			return r;
		}
	if(!e->env_ipc_recving)
		return -E_IPC_NOT_RECV;
	if(srcva){//在一次成功ipc后，sender保持自己地址空间srcva处原来物理页面映射
		  //receiver将在自己地址空间dstva处获得同一物理页面映射
		  //sender和receiver共享同一页面
		srcaddr=(uint32_t)srcva;
		if(srcaddr<(uint32_t)UTOP){
			if(srcaddr&0xfff)
				return -E_INVAL;
			//cprintf("ipc send:some bugs in page mapping\n");
			//cprintf("srcid=%x srcva=%x\n",curenv->env_id,srcva);
			//cprintf("dstid=%x dstva=%x\n",envid,e->env_ipc_dstva);
			if((r=sys_page_map(curenv->env_id,srcva,envid,e->env_ipc_dstva,perm))<0)
				return r;
			//cprintf("ipc send:no bugs in page mapping\n");
		}
	}
	else perm=0;
	e->env_ipc_from=curenv->env_id;
	e->env_ipc_perm=perm;
	e->env_ipc_value=value;
	e->env_ipc_recving=0;
	e->env_status=ENV_RUNNABLE;
	//cprintf("send will successful\n");
	return 0;
	//panic("sys_ipc_try_send not implemented");
}

// Block until a value is ready.  Record that you want to receive
// using the env_ipc_recving and env_ipc_dstva fields of struct Env,
// mark yourself not runnable, and then give up the CPU.
//
// If 'dstva' is < UTOP, then you are willing to receive a page of data.
// 'dstva' is the virtual address at which the sent page should be mapped.
//
// This function only returns on error, but the system call will eventually
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	uint32_t dstaddr;
	dstaddr=(uint32_t)dstva;
	if((dstaddr<(uint32_t)UTOP)&&(dstaddr&0xfff))
		return -E_INVAL;
	curenv->env_ipc_dstva=dstva;
	curenv->env_ipc_recving=1;
	curenv->env_tf.tf_regs.reg_eax=0;//设置返回值，jos都是利用evn_run从内核态返回用户态
	curenv->env_status=ENV_NOT_RUNNABLE;
	sched_yield();
	//panic("sys_ipc_recv not implemented");
	return 0;
}
// Return the current time.
static int
sys_time_msec(void) 
{
	// LAB 6: Your code here.
	return time_msec();
	//panic("sys_time_msec not implemented");
}
// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104d51:	55                   	push   %ebp
f0104d52:	89 e5                	mov    %esp,%ebp
f0104d54:	83 ec 38             	sub    $0x38,%esp
f0104d57:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
f0104d5a:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
f0104d5d:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
f0104d60:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d63:	8b 75 18             	mov    0x18(%ebp),%esi
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int r;
	switch(syscallno){
f0104d66:	83 f8 0e             	cmp    $0xe,%eax
f0104d69:	0f 87 32 05 00 00    	ja     f01052a1 <syscall+0x550>
f0104d6f:	ff 24 85 0c bf 10 f0 	jmp    *0xf010bf0c(,%eax,4)
f0104d76:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104d7d:	00 
f0104d7e:	8b 45 10             	mov    0x10(%ebp),%eax
f0104d81:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104d85:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104d88:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104d8c:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0104d91:	89 04 24             	mov    %eax,(%esp)
f0104d94:	e8 e8 c7 ff ff       	call   f0101581 <user_mem_assert>
f0104d99:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d9c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104da0:	8b 55 10             	mov    0x10(%ebp),%edx
f0104da3:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104da7:	c7 04 24 a2 be 10 f0 	movl   $0xf010bea2,(%esp)
f0104dae:	e8 84 ec ff ff       	call   f0103a37 <cprintf>
f0104db3:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104db8:	e9 05 05 00 00       	jmp    f01052c2 <syscall+0x571>
f0104dbd:	e8 5b b4 ff ff       	call   f010021d <cons_getc>
f0104dc2:	89 c3                	mov    %eax,%ebx
f0104dc4:	e9 f9 04 00 00       	jmp    f01052c2 <syscall+0x571>
f0104dc9:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0104dce:	8b 58 4c             	mov    0x4c(%eax),%ebx
f0104dd1:	e9 ec 04 00 00       	jmp    f01052c2 <syscall+0x571>
f0104dd6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104ddd:	00 
f0104dde:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0104de1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104de5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104de8:	89 04 24             	mov    %eax,(%esp)
f0104deb:	e8 70 e3 ff ff       	call   f0103160 <envid2env>
f0104df0:	89 c3                	mov    %eax,%ebx
f0104df2:	85 c0                	test   %eax,%eax
f0104df4:	0f 88 c8 04 00 00    	js     f01052c2 <syscall+0x571>
f0104dfa:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0104dfd:	89 04 24             	mov    %eax,(%esp)
f0104e00:	e8 4f ea ff ff       	call   f0103854 <env_destroy>
f0104e05:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104e0a:	e9 b3 04 00 00       	jmp    f01052c2 <syscall+0x571>
f0104e0f:	e8 88 fd ff ff       	call   f0104b9c <sched_yield>
f0104e14:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0104e19:	8b 40 4c             	mov    0x4c(%eax),%eax
f0104e1c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e20:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0104e23:	89 04 24             	mov    %eax,(%esp)
f0104e26:	e8 9f e4 ff ff       	call   f01032ca <env_alloc>
f0104e2b:	89 c3                	mov    %eax,%ebx
f0104e2d:	85 c0                	test   %eax,%eax
f0104e2f:	79 11                	jns    f0104e42 <syscall+0xf1>
f0104e31:	c7 04 24 a7 be 10 f0 	movl   $0xf010bea7,(%esp)
f0104e38:	e8 fa eb ff ff       	call   f0103a37 <cprintf>
f0104e3d:	e9 80 04 00 00       	jmp    f01052c2 <syscall+0x571>
f0104e42:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0104e45:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0104e4c:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0104e53:	00 
f0104e54:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0104e59:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e5d:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0104e60:	89 04 24             	mov    %eax,(%esp)
f0104e63:	e8 a2 49 00 00       	call   f010980a <memmove>
f0104e68:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0104e6b:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
f0104e72:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0104e75:	8b 58 4c             	mov    0x4c(%eax),%ebx
f0104e78:	e9 45 04 00 00       	jmp    f01052c2 <syscall+0x571>
f0104e7d:	8b 75 10             	mov    0x10(%ebp),%esi
f0104e80:	83 fe 02             	cmp    $0x2,%esi
f0104e83:	0f 87 34 04 00 00    	ja     f01052bd <syscall+0x56c>
f0104e89:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104e8d:	75 0a                	jne    f0104e99 <syscall+0x148>
f0104e8f:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0104e94:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
f0104e97:	eb 24                	jmp    f0104ebd <syscall+0x16c>
f0104e99:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104ea0:	00 
f0104ea1:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0104ea4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ea8:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104eab:	89 14 24             	mov    %edx,(%esp)
f0104eae:	e8 ad e2 ff ff       	call   f0103160 <envid2env>
f0104eb3:	89 c3                	mov    %eax,%ebx
f0104eb5:	85 c0                	test   %eax,%eax
f0104eb7:	0f 88 05 04 00 00    	js     f01052c2 <syscall+0x571>
f0104ebd:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0104ec0:	89 70 54             	mov    %esi,0x54(%eax)
f0104ec3:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104ec8:	e9 f5 03 00 00       	jmp    f01052c2 <syscall+0x571>
f0104ecd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104ed1:	75 0a                	jne    f0104edd <syscall+0x18c>
f0104ed3:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0104ed8:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
f0104edb:	eb 24                	jmp    f0104f01 <syscall+0x1b0>
f0104edd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104ee4:	00 
f0104ee5:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0104ee8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104eec:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104eef:	89 04 24             	mov    %eax,(%esp)
f0104ef2:	e8 69 e2 ff ff       	call   f0103160 <envid2env>
f0104ef7:	89 c3                	mov    %eax,%ebx
f0104ef9:	85 c0                	test   %eax,%eax
f0104efb:	0f 88 c1 03 00 00    	js     f01052c2 <syscall+0x571>
f0104f01:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104f08:	00 
f0104f09:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0104f10:	00 
f0104f11:	8b 55 10             	mov    0x10(%ebp),%edx
f0104f14:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104f18:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0104f1b:	89 04 24             	mov    %eax,(%esp)
f0104f1e:	e8 5e c6 ff ff       	call   f0101581 <user_mem_assert>
f0104f23:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0104f27:	74 1a                	je     f0104f43 <syscall+0x1f2>
f0104f29:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0104f30:	00 
f0104f31:	8b 45 10             	mov    0x10(%ebp),%eax
f0104f34:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f38:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0104f3b:	89 04 24             	mov    %eax,(%esp)
f0104f3e:	e8 45 49 00 00       	call   f0109888 <memcpy>
f0104f43:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0104f46:	81 48 38 00 02 00 00 	orl    $0x200,0x38(%eax)
f0104f4d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104f52:	e9 6b 03 00 00       	jmp    f01052c2 <syscall+0x571>
f0104f57:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104f5b:	75 0a                	jne    f0104f67 <syscall+0x216>
f0104f5d:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0104f62:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
f0104f65:	eb 24                	jmp    f0104f8b <syscall+0x23a>
f0104f67:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104f6e:	00 
f0104f6f:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0104f72:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f76:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104f79:	89 14 24             	mov    %edx,(%esp)
f0104f7c:	e8 df e1 ff ff       	call   f0103160 <envid2env>
f0104f81:	89 c3                	mov    %eax,%ebx
f0104f83:	85 c0                	test   %eax,%eax
f0104f85:	0f 88 37 03 00 00    	js     f01052c2 <syscall+0x571>
		case SYS_cputs:
			sys_cputs((char*)a1,(size_t)a2);
			break;
		case SYS_cgetc:
			return sys_cgetc();
			break;
		case SYS_getenvid:
			return sys_getenvid();
			break;
		case SYS_env_destroy:
			return sys_env_destroy((envid_t)a1);
			break;
		case SYS_yield:
			sys_yield();
			break;
		case SYS_exofork:
			return sys_exofork(); //该系统调用有返回值，需要return
			break;
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1,(int)a2);
			break;
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1,(struct Trapframe*)a2);
			break;
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
f0104f8b:	8b 75 10             	mov    0x10(%ebp),%esi
f0104f8e:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104f94:	0f 87 23 03 00 00    	ja     f01052bd <syscall+0x56c>
f0104f9a:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0104fa0:	0f 85 17 03 00 00    	jne    f01052bd <syscall+0x56c>
f0104fa6:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fa9:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
f0104fac:	a9 f8 f1 ff ff       	test   $0xfffff1f8,%eax
f0104fb1:	0f 85 06 03 00 00    	jne    f01052bd <syscall+0x56c>
f0104fb7:	8d 45 ec             	lea    0xffffffec(%ebp),%eax
f0104fba:	89 04 24             	mov    %eax,(%esp)
f0104fbd:	e8 d6 c2 ff ff       	call   f0101298 <page_alloc>
f0104fc2:	89 c3                	mov    %eax,%ebx
f0104fc4:	85 c0                	test   %eax,%eax
f0104fc6:	0f 88 f6 02 00 00    	js     f01052c2 <syscall+0x571>

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0104fcc:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0104fcf:	2b 05 7c 98 2a f0    	sub    0xf02a987c,%eax
f0104fd5:	c1 f8 02             	sar    $0x2,%eax
f0104fd8:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104fde:	89 c2                	mov    %eax,%edx
f0104fe0:	c1 e2 0c             	shl    $0xc,%edx
f0104fe3:	89 d0                	mov    %edx,%eax
f0104fe5:	c1 e8 0c             	shr    $0xc,%eax
f0104fe8:	3b 05 70 98 2a f0    	cmp    0xf02a9870,%eax
f0104fee:	72 20                	jb     f0105010 <syscall+0x2bf>
f0104ff0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104ff4:	c7 44 24 08 c8 ad 10 	movl   $0xf010adc8,0x8(%esp)
f0104ffb:	f0 
f0104ffc:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
f0105003:	00 
f0105004:	c7 04 24 b9 be 10 f0 	movl   $0xf010beb9,(%esp)
f010500b:	e8 76 b0 ff ff       	call   f0100086 <_panic>
f0105010:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0105017:	00 
f0105018:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010501f:	00 
f0105020:	8d 82 00 00 00 f0    	lea    0xf0000000(%edx),%eax
f0105026:	89 04 24             	mov    %eax,(%esp)
f0105029:	e8 83 47 00 00       	call   f01097b1 <memset>
static __inline uint32_t
rcr3(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr3,%0" : "=r" (val));
f010502e:	0f 20 df             	mov    %cr3,%edi
f0105031:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0105034:	8b 42 60             	mov    0x60(%edx),%eax
f0105037:	0f 22 d8             	mov    %eax,%cr3
f010503a:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
f010503d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105041:	89 74 24 08          	mov    %esi,0x8(%esp)
f0105045:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0105048:	89 44 24 04          	mov    %eax,0x4(%esp)
f010504c:	8b 42 5c             	mov    0x5c(%edx),%eax
f010504f:	89 04 24             	mov    %eax,(%esp)
f0105052:	e8 62 c6 ff ff       	call   f01016b9 <page_insert>
f0105057:	89 c3                	mov    %eax,%ebx
f0105059:	85 c0                	test   %eax,%eax
f010505b:	79 13                	jns    f0105070 <syscall+0x31f>
f010505d:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0105060:	89 04 24             	mov    %eax,(%esp)
f0105063:	e8 10 c0 ff ff       	call   f0101078 <page_free>

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0105068:	0f 22 df             	mov    %edi,%cr3
f010506b:	e9 52 02 00 00       	jmp    f01052c2 <syscall+0x571>
f0105070:	0f 22 df             	mov    %edi,%cr3
f0105073:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105078:	e9 45 02 00 00       	jmp    f01052c2 <syscall+0x571>
			break;
		case SYS_page_map:
			return sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,(int)a5);
f010507d:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0105080:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105084:	89 34 24             	mov    %esi,(%esp)
f0105087:	8b 4d 14             	mov    0x14(%ebp),%ecx
f010508a:	8b 55 10             	mov    0x10(%ebp),%edx
f010508d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105090:	e8 ab fb ff ff       	call   f0104c40 <sys_page_map>
f0105095:	89 c3                	mov    %eax,%ebx
f0105097:	e9 26 02 00 00       	jmp    f01052c2 <syscall+0x571>
f010509c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01050a0:	75 0a                	jne    f01050ac <syscall+0x35b>
f01050a2:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f01050a7:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
f01050aa:	eb 24                	jmp    f01050d0 <syscall+0x37f>
f01050ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01050b3:	00 
f01050b4:	8d 45 ec             	lea    0xffffffec(%ebp),%eax
f01050b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050bb:	8b 55 0c             	mov    0xc(%ebp),%edx
f01050be:	89 14 24             	mov    %edx,(%esp)
f01050c1:	e8 9a e0 ff ff       	call   f0103160 <envid2env>
f01050c6:	89 c3                	mov    %eax,%ebx
f01050c8:	85 c0                	test   %eax,%eax
f01050ca:	0f 88 f2 01 00 00    	js     f01052c2 <syscall+0x571>
f01050d0:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01050d7:	0f 87 e0 01 00 00    	ja     f01052bd <syscall+0x56c>
f01050dd:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01050e4:	0f 85 d3 01 00 00    	jne    f01052bd <syscall+0x56c>
static __inline uint32_t
rcr3(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr3,%0" : "=r" (val));
f01050ea:	0f 20 db             	mov    %cr3,%ebx
f01050ed:	8b 55 ec             	mov    0xffffffec(%ebp),%edx

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01050f0:	8b 42 60             	mov    0x60(%edx),%eax
f01050f3:	0f 22 d8             	mov    %eax,%cr3
f01050f6:	8b 45 10             	mov    0x10(%ebp),%eax
f01050f9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050fd:	8b 42 5c             	mov    0x5c(%edx),%eax
f0105100:	89 04 24             	mov    %eax,(%esp)
f0105103:	e8 d1 c4 ff ff       	call   f01015d9 <page_remove>

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0105108:	0f 22 db             	mov    %ebx,%cr3
f010510b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105110:	e9 ad 01 00 00       	jmp    f01052c2 <syscall+0x571>
f0105115:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105119:	75 0a                	jne    f0105125 <syscall+0x3d4>
f010511b:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0105120:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
f0105123:	eb 24                	jmp    f0105149 <syscall+0x3f8>
f0105125:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010512c:	00 
f010512d:	8d 45 ec             	lea    0xffffffec(%ebp),%eax
f0105130:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105134:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105137:	89 14 24             	mov    %edx,(%esp)
f010513a:	e8 21 e0 ff ff       	call   f0103160 <envid2env>
f010513f:	89 c3                	mov    %eax,%ebx
f0105141:	85 c0                	test   %eax,%eax
f0105143:	0f 88 79 01 00 00    	js     f01052c2 <syscall+0x571>
f0105149:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f010514c:	8b 55 10             	mov    0x10(%ebp),%edx
f010514f:	89 50 64             	mov    %edx,0x64(%eax)
f0105152:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105157:	e9 66 01 00 00       	jmp    f01052c2 <syscall+0x571>
			break;
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1,(void*)a2);
			break;
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1,(void*)a2);
			break;
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1,(uint32_t)a2,(void*)a3,(unsigned)a4);
f010515c:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010515f:	85 ff                	test   %edi,%edi
f0105161:	74 0a                	je     f010516d <syscall+0x41c>
f0105163:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0105168:	3b 78 4c             	cmp    0x4c(%eax),%edi
f010516b:	75 22                	jne    f010518f <syscall+0x43e>
f010516d:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0105172:	8b 40 4c             	mov    0x4c(%eax),%eax
f0105175:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105179:	c7 04 24 c8 be 10 f0 	movl   $0xf010bec8,(%esp)
f0105180:	e8 b2 e8 ff ff       	call   f0103a37 <cprintf>
f0105185:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f010518a:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
f010518d:	eb 32                	jmp    f01051c1 <syscall+0x470>
f010518f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0105196:	00 
f0105197:	8d 45 ec             	lea    0xffffffec(%ebp),%eax
f010519a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010519e:	89 3c 24             	mov    %edi,(%esp)
f01051a1:	e8 ba df ff ff       	call   f0103160 <envid2env>
f01051a6:	89 c3                	mov    %eax,%ebx
f01051a8:	85 c0                	test   %eax,%eax
f01051aa:	79 15                	jns    f01051c1 <syscall+0x470>
f01051ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01051b0:	c7 04 24 e0 be 10 f0 	movl   $0xf010bee0,(%esp)
f01051b7:	e8 7b e8 ff ff       	call   f0103a37 <cprintf>
f01051bc:	e9 01 01 00 00       	jmp    f01052c2 <syscall+0x571>
f01051c1:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
f01051c4:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f01051c9:	83 7a 68 00          	cmpl   $0x0,0x68(%edx)
f01051cd:	0f 84 ef 00 00 00    	je     f01052c2 <syscall+0x571>
f01051d3:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
f01051d7:	75 07                	jne    f01051e0 <syscall+0x48f>
f01051d9:	be 00 00 00 00       	mov    $0x0,%esi
f01051de:	eb 3c                	jmp    f010521c <syscall+0x4cb>
f01051e0:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f01051e7:	77 33                	ja     f010521c <syscall+0x4cb>
f01051e9:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f01051f0:	0f 85 c7 00 00 00    	jne    f01052bd <syscall+0x56c>
f01051f6:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f01051fb:	8b 40 4c             	mov    0x4c(%eax),%eax
f01051fe:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105202:	8b 52 6c             	mov    0x6c(%edx),%edx
f0105205:	89 14 24             	mov    %edx,(%esp)
f0105208:	89 f9                	mov    %edi,%ecx
f010520a:	8b 55 14             	mov    0x14(%ebp),%edx
f010520d:	e8 2e fa ff ff       	call   f0104c40 <sys_page_map>
f0105212:	89 c3                	mov    %eax,%ebx
f0105214:	85 c0                	test   %eax,%eax
f0105216:	0f 88 a6 00 00 00    	js     f01052c2 <syscall+0x571>
f010521c:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0105221:	8b 50 4c             	mov    0x4c(%eax),%edx
f0105224:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0105227:	89 50 74             	mov    %edx,0x74(%eax)
f010522a:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f010522d:	89 70 78             	mov    %esi,0x78(%eax)
f0105230:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0105233:	8b 55 10             	mov    0x10(%ebp),%edx
f0105236:	89 50 70             	mov    %edx,0x70(%eax)
f0105239:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f010523c:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)
f0105243:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0105246:	c7 40 54 01 00 00 00 	movl   $0x1,0x54(%eax)
f010524d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105252:	eb 6e                	jmp    f01052c2 <syscall+0x571>
			break;
		case SYS_ipc_recv:
			return sys_ipc_recv((void*)a1);
f0105254:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105257:	81 fa ff ff bf ee    	cmp    $0xeebfffff,%edx
f010525d:	77 08                	ja     f0105267 <syscall+0x516>
f010525f:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0105265:	75 56                	jne    f01052bd <syscall+0x56c>
f0105267:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f010526c:	89 50 6c             	mov    %edx,0x6c(%eax)
f010526f:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0105274:	c7 40 68 01 00 00 00 	movl   $0x1,0x68(%eax)
f010527b:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0105280:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
f0105287:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f010528c:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0105293:	e8 04 f9 ff ff       	call   f0104b9c <sched_yield>
f0105298:	e8 c2 4e 00 00       	call   f010a15f <time_msec>
f010529d:	89 c3                	mov    %eax,%ebx
f010529f:	eb 21                	jmp    f01052c2 <syscall+0x571>
			break;
		case SYS_time_msec:
			return sys_time_msec();
		default:
			panic("syscall is not implemented");
f01052a1:	c7 44 24 08 f1 be 10 	movl   $0xf010bef1,0x8(%esp)
f01052a8:	f0 
f01052a9:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
f01052b0:	00 
f01052b1:	c7 04 24 b9 be 10 f0 	movl   $0xf010beb9,(%esp)
f01052b8:	e8 c9 ad ff ff       	call   f0100086 <_panic>
f01052bd:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	}
	return 0;
	//panic("syscall not implemented");
}
f01052c2:	89 d8                	mov    %ebx,%eax
f01052c4:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
f01052c7:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
f01052ca:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
f01052cd:	89 ec                	mov    %ebp,%esp
f01052cf:	5d                   	pop    %ebp
f01052d0:	c3                   	ret    
	...

f01052e0 <stab_binsearch>:
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01052e0:	55                   	push   %ebp
f01052e1:	89 e5                	mov    %esp,%ebp
f01052e3:	57                   	push   %edi
f01052e4:	56                   	push   %esi
f01052e5:	53                   	push   %ebx
f01052e6:	83 ec 14             	sub    $0x14,%esp
f01052e9:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
f01052ec:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
f01052ef:	89 4d e0             	mov    %ecx,0xffffffe0(%ebp)
f01052f2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01052f5:	8b 1a                	mov    (%edx),%ebx
f01052f7:	8b 01                	mov    (%ecx),%eax
f01052f9:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
	
	while (l <= r) {
f01052fc:	39 c3                	cmp    %eax,%ebx
f01052fe:	0f 8f ac 00 00 00    	jg     f01053b0 <stab_binsearch+0xd0>
f0105304:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f010530b:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
f010530e:	01 da                	add    %ebx,%edx
f0105310:	89 d0                	mov    %edx,%eax
f0105312:	c1 e8 1f             	shr    $0x1f,%eax
f0105315:	01 d0                	add    %edx,%eax
f0105317:	89 c6                	mov    %eax,%esi
f0105319:	d1 fe                	sar    %esi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010531b:	39 de                	cmp    %ebx,%esi
f010531d:	7c 30                	jl     f010534f <stab_binsearch+0x6f>
f010531f:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0105322:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0105329:	8b 4d e8             	mov    0xffffffe8(%ebp),%ecx
f010532c:	0f b6 44 0a 04       	movzbl 0x4(%edx,%ecx,1),%eax
f0105331:	39 f8                	cmp    %edi,%eax
f0105333:	74 1f                	je     f0105354 <stab_binsearch+0x74>
f0105335:	8d 54 0a f4          	lea    0xfffffff4(%edx,%ecx,1),%edx
f0105339:	89 f1                	mov    %esi,%ecx
			m--;
f010533b:	83 e9 01             	sub    $0x1,%ecx
f010533e:	39 d9                	cmp    %ebx,%ecx
f0105340:	7c 0d                	jl     f010534f <stab_binsearch+0x6f>
f0105342:	0f b6 42 04          	movzbl 0x4(%edx),%eax
f0105346:	83 ea 0c             	sub    $0xc,%edx
f0105349:	39 f8                	cmp    %edi,%eax
f010534b:	74 09                	je     f0105356 <stab_binsearch+0x76>
f010534d:	eb ec                	jmp    f010533b <stab_binsearch+0x5b>
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010534f:	8d 5e 01             	lea    0x1(%esi),%ebx
f0105352:	eb 4d                	jmp    f01053a1 <stab_binsearch+0xc1>
			continue;
f0105354:	89 f1                	mov    %esi,%ecx
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105356:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0105359:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
f010535c:	8b 44 82 08          	mov    0x8(%edx,%eax,4),%eax
f0105360:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0105363:	73 11                	jae    f0105376 <stab_binsearch+0x96>
			*region_left = m;
f0105365:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
f0105368:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
f010536a:	8d 5e 01             	lea    0x1(%esi),%ebx
f010536d:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)
f0105374:	eb 2b                	jmp    f01053a1 <stab_binsearch+0xc1>
		} else if (stabs[m].n_value > addr) {
f0105376:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0105379:	76 14                	jbe    f010538f <stab_binsearch+0xaf>
			*region_right = m - 1;
f010537b:	83 e9 01             	sub    $0x1,%ecx
f010537e:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
f0105381:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
f0105384:	89 0a                	mov    %ecx,(%edx)
f0105386:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)
f010538d:	eb 12                	jmp    f01053a1 <stab_binsearch+0xc1>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010538f:	8b 75 e4             	mov    0xffffffe4(%ebp),%esi
f0105392:	89 0e                	mov    %ecx,(%esi)
			l = m;
			addr++;
f0105394:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0105398:	89 cb                	mov    %ecx,%ebx
f010539a:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)
f01053a1:	3b 5d ec             	cmp    0xffffffec(%ebp),%ebx
f01053a4:	0f 8e 61 ff ff ff    	jle    f010530b <stab_binsearch+0x2b>
		}
	}

	if (!any_matches)
f01053aa:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f01053ae:	75 0f                	jne    f01053bf <stab_binsearch+0xdf>
		*region_right = *region_left - 1;
f01053b0:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
f01053b3:	8b 02                	mov    (%edx),%eax
f01053b5:	83 e8 01             	sub    $0x1,%eax
f01053b8:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
f01053bb:	89 01                	mov    %eax,(%ecx)
f01053bd:	eb 3f                	jmp    f01053fe <stab_binsearch+0x11e>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01053bf:	8b 75 e0             	mov    0xffffffe0(%ebp),%esi
f01053c2:	8b 0e                	mov    (%esi),%ecx
		     l > *region_left && stabs[l].n_type != type;
f01053c4:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
f01053c7:	8b 18                	mov    (%eax),%ebx
f01053c9:	39 d9                	cmp    %ebx,%ecx
f01053cb:	7e 2c                	jle    f01053f9 <stab_binsearch+0x119>
f01053cd:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f01053d0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01053d7:	8b 75 e8             	mov    0xffffffe8(%ebp),%esi
f01053da:	0f b6 44 32 04       	movzbl 0x4(%edx,%esi,1),%eax
f01053df:	39 f8                	cmp    %edi,%eax
f01053e1:	74 16                	je     f01053f9 <stab_binsearch+0x119>
f01053e3:	8d 54 32 f4          	lea    0xfffffff4(%edx,%esi,1),%edx
		     l--)
f01053e7:	83 e9 01             	sub    $0x1,%ecx
f01053ea:	39 d9                	cmp    %ebx,%ecx
f01053ec:	7e 0b                	jle    f01053f9 <stab_binsearch+0x119>
f01053ee:	0f b6 42 04          	movzbl 0x4(%edx),%eax
f01053f2:	83 ea 0c             	sub    $0xc,%edx
f01053f5:	39 f8                	cmp    %edi,%eax
f01053f7:	75 ee                	jne    f01053e7 <stab_binsearch+0x107>
			/* do nothing */;
		*region_left = l;
f01053f9:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
f01053fc:	89 08                	mov    %ecx,(%eax)
	}
}
f01053fe:	83 c4 14             	add    $0x14,%esp
f0105401:	5b                   	pop    %ebx
f0105402:	5e                   	pop    %esi
f0105403:	5f                   	pop    %edi
f0105404:	5d                   	pop    %ebp
f0105405:	c3                   	ret    

f0105406 <debuginfo_eip>:


// debuginfo_eip(addr, info)
//
//	Fill in the 'info' structure with information about the specified
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105406:	55                   	push   %ebp
f0105407:	89 e5                	mov    %esp,%ebp
f0105409:	83 ec 58             	sub    $0x58,%esp
f010540c:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
f010540f:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
f0105412:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
f0105415:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105418:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010541b:	c7 06 48 bf 10 f0    	movl   $0xf010bf48,(%esi)
	info->eip_line = 0;
f0105421:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0105428:	c7 46 08 48 bf 10 f0 	movl   $0xf010bf48,0x8(%esi)
	info->eip_fn_namelen = 9;
f010542f:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0105436:	89 5e 10             	mov    %ebx,0x10(%esi)
	info->eip_fn_narg = 0;
f0105439:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105440:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0105446:	76 1f                	jbe    f0105467 <debuginfo_eip+0x61>
f0105448:	c7 45 c4 6c 4a 11 f0 	movl   $0xf0114a6c,0xffffffc4(%ebp)
f010544f:	bf e0 2f 12 f0       	mov    $0xf0122fe0,%edi
f0105454:	c7 45 c8 e1 2f 12 f0 	movl   $0xf0122fe1,0xffffffc8(%ebp)
f010545b:	c7 45 cc c9 85 12 f0 	movl   $0xf01285c9,0xffffffcc(%ebp)
f0105462:	e9 99 00 00 00       	jmp    f0105500 <debuginfo_eip+0xfa>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// The user-application linker script, user/user.ld,
		// puts information about the application's stabs (equivalent
		// to __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__, and
		// __STABSTR_END__) in a structure located at virtual address
		// USTABDATA.
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		user_mem_check(curenv,(void*)usd,sizeof(struct UserStabData),0);
f0105467:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010546e:	00 
f010546f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0105476:	00 
f0105477:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f010547e:	00 
f010547f:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f0105484:	89 04 24             	mov    %eax,(%esp)
f0105487:	e8 16 c0 ff ff       	call   f01014a2 <user_mem_check>
		stabs = usd->stabs;
f010548c:	a1 00 00 20 00       	mov    0x200000,%eax
f0105491:	89 45 c4             	mov    %eax,0xffffffc4(%ebp)
		stab_end = usd->stab_end;
f0105494:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f010549a:	8b 15 08 00 20 00    	mov    0x200008,%edx
f01054a0:	89 55 c8             	mov    %edx,0xffffffc8(%ebp)
		stabstr_end = usd->stabstr_end;
f01054a3:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f01054a9:	89 4d cc             	mov    %ecx,0xffffffcc(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		user_mem_check(curenv,(void*)stabs,stab_end-stabs,0);
f01054ac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01054b3:	00 
f01054b4:	89 f8                	mov    %edi,%eax
f01054b6:	2b 45 c4             	sub    0xffffffc4(%ebp),%eax
f01054b9:	c1 f8 02             	sar    $0x2,%eax
f01054bc:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01054c2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01054c6:	8b 45 c4             	mov    0xffffffc4(%ebp),%eax
f01054c9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054cd:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f01054d2:	89 04 24             	mov    %eax,(%esp)
f01054d5:	e8 c8 bf ff ff       	call   f01014a2 <user_mem_check>
		user_mem_check(curenv,(void*)stabstr,stabstr_end-stabstr,0);
f01054da:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01054e1:	00 
f01054e2:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
f01054e5:	2b 45 c8             	sub    0xffffffc8(%ebp),%eax
f01054e8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01054ec:	8b 55 c8             	mov    0xffffffc8(%ebp),%edx
f01054ef:	89 54 24 04          	mov    %edx,0x4(%esp)
f01054f3:	a1 c4 88 2a f0       	mov    0xf02a88c4,%eax
f01054f8:	89 04 24             	mov    %eax,(%esp)
f01054fb:	e8 a2 bf ff ff       	call   f01014a2 <user_mem_check>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105500:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
f0105503:	39 4d c8             	cmp    %ecx,0xffffffc8(%ebp)
f0105506:	0f 83 b2 01 00 00    	jae    f01056be <debuginfo_eip+0x2b8>
f010550c:	80 79 ff 00          	cmpb   $0x0,0xffffffff(%ecx)
f0105510:	0f 85 a8 01 00 00    	jne    f01056be <debuginfo_eip+0x2b8>
		return -1;

	// Now we find the right stabs that define the function containing
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105516:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	rfile = (stab_end - stabs) - 1;
f010551d:	89 f8                	mov    %edi,%eax
f010551f:	2b 45 c4             	sub    0xffffffc4(%ebp),%eax
f0105522:	c1 f8 02             	sar    $0x2,%eax
f0105525:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010552b:	83 e8 01             	sub    $0x1,%eax
f010552e:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105531:	8d 4d ec             	lea    0xffffffec(%ebp),%ecx
f0105534:	8d 55 f0             	lea    0xfffffff0(%ebp),%edx
f0105537:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010553b:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105542:	8b 45 c4             	mov    0xffffffc4(%ebp),%eax
f0105545:	e8 96 fd ff ff       	call   f01052e0 <stab_binsearch>
	if (lfile == 0)
f010554a:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f010554d:	85 c0                	test   %eax,%eax
f010554f:	0f 84 69 01 00 00    	je     f01056be <debuginfo_eip+0x2b8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105555:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
	rfun = rfile;
f0105558:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f010555b:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010555e:	8d 4d e4             	lea    0xffffffe4(%ebp),%ecx
f0105561:	8d 55 e8             	lea    0xffffffe8(%ebp),%edx
f0105564:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105568:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f010556f:	8b 45 c4             	mov    0xffffffc4(%ebp),%eax
f0105572:	e8 69 fd ff ff       	call   f01052e0 <stab_binsearch>

	if (lfun <= rfun) {
f0105577:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f010557a:	3b 45 e4             	cmp    0xffffffe4(%ebp),%eax
f010557d:	7f 39                	jg     f01055b8 <debuginfo_eip+0x1b2>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010557f:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105582:	8b 4d c4             	mov    0xffffffc4(%ebp),%ecx
f0105585:	8b 14 81             	mov    (%ecx,%eax,4),%edx
f0105588:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
f010558b:	2b 45 c8             	sub    0xffffffc8(%ebp),%eax
f010558e:	39 c2                	cmp    %eax,%edx
f0105590:	73 09                	jae    f010559b <debuginfo_eip+0x195>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105592:	8b 4d c8             	mov    0xffffffc8(%ebp),%ecx
f0105595:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
f0105598:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f010559b:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
f010559e:	8d 04 52             	lea    (%edx,%edx,2),%eax
f01055a1:	8b 4d c4             	mov    0xffffffc4(%ebp),%ecx
f01055a4:	8b 44 81 08          	mov    0x8(%ecx,%eax,4),%eax
f01055a8:	89 46 10             	mov    %eax,0x10(%esi)
		addr -= info->eip_fn_addr;
f01055ab:	29 c3                	sub    %eax,%ebx
		// Search within the function definition for the line number.
		lline = lfun;
f01055ad:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
		rline = rfun;
f01055b0:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
f01055b3:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
f01055b6:	eb 0f                	jmp    f01055c7 <debuginfo_eip+0x1c1>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01055b8:	89 5e 10             	mov    %ebx,0x10(%esi)
		lline = lfile;
f01055bb:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f01055be:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
		rline = rfile;
f01055c1:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f01055c4:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01055c7:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01055ce:	00 
f01055cf:	8b 46 08             	mov    0x8(%esi),%eax
f01055d2:	89 04 24             	mov    %eax,(%esp)
f01055d5:	e8 af 41 00 00       	call   f0109789 <strfind>
f01055da:	2b 46 08             	sub    0x8(%esi),%eax
f01055dd:	89 46 0c             	mov    %eax,0xc(%esi)

	
	// Search within [lline, rline] for the line number stab.
	// If found, set info->eip_line to the right line number.
	// If not found, return -1.
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs,&lline,&rline,N_SLINE,addr);
f01055e0:	8d 4d dc             	lea    0xffffffdc(%ebp),%ecx
f01055e3:	8d 55 e0             	lea    0xffffffe0(%ebp),%edx
f01055e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01055ea:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01055f1:	8b 45 c4             	mov    0xffffffc4(%ebp),%eax
f01055f4:	e8 e7 fc ff ff       	call   f01052e0 <stab_binsearch>
	if(lline==0)
f01055f9:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
f01055fc:	85 d2                	test   %edx,%edx
f01055fe:	0f 84 ba 00 00 00    	je     f01056be <debuginfo_eip+0x2b8>
		return -1;
	info->eip_line=stabs[lline].n_desc;
f0105604:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0105607:	8d 3c 85 00 00 00 00 	lea    0x0(,%eax,4),%edi
f010560e:	8b 4d c4             	mov    0xffffffc4(%ebp),%ecx
f0105611:	0f b7 44 0f 06       	movzwl 0x6(%edi,%ecx,1),%eax
f0105616:	89 46 04             	mov    %eax,0x4(%esi)
	
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105619:	89 d1                	mov    %edx,%ecx
f010561b:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f010561e:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
f0105621:	39 c2                	cmp    %eax,%edx
f0105623:	7c 57                	jl     f010567c <debuginfo_eip+0x276>
f0105625:	8b 55 c4             	mov    0xffffffc4(%ebp),%edx
f0105628:	8d 1c 17             	lea    (%edi,%edx,1),%ebx
f010562b:	0f b6 53 04          	movzbl 0x4(%ebx),%edx
f010562f:	8b 45 c4             	mov    0xffffffc4(%ebp),%eax
f0105632:	8d 7c 07 f4          	lea    0xfffffff4(%edi,%eax,1),%edi
f0105636:	80 fa 84             	cmp    $0x84,%dl
f0105639:	75 1b                	jne    f0105656 <debuginfo_eip+0x250>
f010563b:	eb 24                	jmp    f0105661 <debuginfo_eip+0x25b>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f010563d:	83 e9 01             	sub    $0x1,%ecx
f0105640:	89 4d e0             	mov    %ecx,0xffffffe0(%ebp)
f0105643:	39 4d d0             	cmp    %ecx,0xffffffd0(%ebp)
f0105646:	7f 34                	jg     f010567c <debuginfo_eip+0x276>
f0105648:	89 fb                	mov    %edi,%ebx
f010564a:	0f b6 57 04          	movzbl 0x4(%edi),%edx
f010564e:	8d 7f f4             	lea    0xfffffff4(%edi),%edi
f0105651:	80 fa 84             	cmp    $0x84,%dl
f0105654:	74 0b                	je     f0105661 <debuginfo_eip+0x25b>
f0105656:	80 fa 64             	cmp    $0x64,%dl
f0105659:	75 e2                	jne    f010563d <debuginfo_eip+0x237>
f010565b:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
f010565f:	74 dc                	je     f010563d <debuginfo_eip+0x237>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105661:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0105664:	8b 4d c4             	mov    0xffffffc4(%ebp),%ecx
f0105667:	8b 14 81             	mov    (%ecx,%eax,4),%edx
f010566a:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
f010566d:	2b 45 c8             	sub    0xffffffc8(%ebp),%eax
f0105670:	39 c2                	cmp    %eax,%edx
f0105672:	73 08                	jae    f010567c <debuginfo_eip+0x276>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105674:	8b 4d c8             	mov    0xffffffc8(%ebp),%ecx
f0105677:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
f010567a:	89 06                	mov    %eax,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010567c:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f010567f:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
f0105682:	39 d0                	cmp    %edx,%eax
f0105684:	7d 3f                	jge    f01056c5 <debuginfo_eip+0x2bf>
		for (lline = lfun + 1;
f0105686:	83 c0 01             	add    $0x1,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105689:	39 c2                	cmp    %eax,%edx
f010568b:	7e 38                	jle    f01056c5 <debuginfo_eip+0x2bf>
f010568d:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
f0105690:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105693:	8b 55 c4             	mov    0xffffffc4(%ebp),%edx
f0105696:	80 7c 82 04 a0       	cmpb   $0xa0,0x4(%edx,%eax,4)
f010569b:	75 28                	jne    f01056c5 <debuginfo_eip+0x2bf>
		     lline++)
			info->eip_fn_narg++;
f010569d:	83 46 14 01          	addl   $0x1,0x14(%esi)
f01056a1:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
f01056a4:	83 c0 01             	add    $0x1,%eax
f01056a7:	39 45 e4             	cmp    %eax,0xffffffe4(%ebp)
f01056aa:	7e 19                	jle    f01056c5 <debuginfo_eip+0x2bf>
f01056ac:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
f01056af:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01056b2:	8b 4d c4             	mov    0xffffffc4(%ebp),%ecx
f01056b5:	80 7c 81 04 a0       	cmpb   $0xa0,0x4(%ecx,%eax,4)
f01056ba:	75 09                	jne    f01056c5 <debuginfo_eip+0x2bf>
f01056bc:	eb df                	jmp    f010569d <debuginfo_eip+0x297>
f01056be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01056c3:	eb 05                	jmp    f01056ca <debuginfo_eip+0x2c4>
f01056c5:	b8 00 00 00 00       	mov    $0x0,%eax
	
	return 0;
}
f01056ca:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
f01056cd:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
f01056d0:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
f01056d3:	89 ec                	mov    %ebp,%esp
f01056d5:	5d                   	pop    %ebp
f01056d6:	c3                   	ret    
	...

f01056e0 <fetch_data>:
static int
fetch_data (info, addr)
     struct disassemble_info *info;
     bfd_byte *addr;
{
f01056e0:	55                   	push   %ebp
f01056e1:	89 e5                	mov    %esp,%ebp
f01056e3:	83 ec 38             	sub    $0x38,%esp
f01056e6:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
f01056e9:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
f01056ec:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
f01056ef:	89 c6                	mov    %eax,%esi
f01056f1:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  int status;
  struct dis_private *priv = (struct dis_private *) info->private_data;
f01056f4:	8b 58 20             	mov    0x20(%eax),%ebx
  bfd_vma start_vma = priv->insn_start + (priv->max_fetched - priv->the_buffer);
f01056f7:	8b 03                	mov    (%ebx),%eax
f01056f9:	8d 7b 04             	lea    0x4(%ebx),%edi
f01056fc:	89 c2                	mov    %eax,%edx
f01056fe:	29 fa                	sub    %edi,%edx
f0105700:	89 d1                	mov    %edx,%ecx
f0105702:	c1 f9 1f             	sar    $0x1f,%ecx
f0105705:	03 53 18             	add    0x18(%ebx),%edx
f0105708:	13 4b 1c             	adc    0x1c(%ebx),%ecx
f010570b:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
f010570e:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
 //cprintf("fetch_data:info=%x max_fetched=%x length=%d\n",info,priv->max_fetched,addr-priv->max_fetched);
  status = (*info->read_memory_func)(start_vma,priv->max_fetched,addr-priv->max_fetched,info);
f0105711:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105715:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
f0105718:	29 c2                	sub    %eax,%edx
f010571a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010571e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105722:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f0105725:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
f0105728:	89 04 24             	mov    %eax,(%esp)
f010572b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010572f:	ff 56 24             	call   *0x24(%esi)
  if (status != 0)
f0105732:	85 c0                	test   %eax,%eax
f0105734:	74 1e                	je     f0105754 <fetch_data+0x74>
    {
      /* If we did manage to read at least one byte, then
         print_insn_i386 will do something sensible.  Otherwise, print
         an error.  We do that here because this is where we know
         STATUS.  */
      if (priv->max_fetched == priv->the_buffer)
f0105736:	39 3b                	cmp    %edi,(%ebx)
f0105738:	75 1f                	jne    f0105759 <fetch_data+0x79>
	(*info->memory_error_func) (status, start_vma, info);
f010573a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010573e:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
f0105741:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
f0105744:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105748:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010574c:	89 04 24             	mov    %eax,(%esp)
f010574f:	ff 56 28             	call   *0x28(%esi)
f0105752:	eb 05                	jmp    f0105759 <fetch_data+0x79>
      //longjmp (priv->bailout, 1);
    }
  else
    priv->max_fetched = addr;
f0105754:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
f0105757:	89 0b                	mov    %ecx,(%ebx)
  return 1;
}
f0105759:	b8 01 00 00 00       	mov    $0x1,%eax
f010575e:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
f0105761:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
f0105764:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
f0105767:	89 ec                	mov    %ebp,%esp
f0105769:	5d                   	pop    %ebp
f010576a:	c3                   	ret    

f010576b <prefix_name>:

#define XX NULL, 0

#define Eb OP_E, b_mode
#define Ev OP_E, v_mode
#define Ed OP_E, d_mode
#define indirEb OP_indirE, b_mode
#define indirEv OP_indirE, v_mode
#define Ew OP_E, w_mode
#define Ma OP_E, v_mode
#define M OP_E, 0		/* lea, lgdt, etc. */
#define Mp OP_E, 0		/* 32 or 48 bit memory operand for LDS, LES etc */
#define Gb OP_G, b_mode
#define Gv OP_G, v_mode
#define Gd OP_G, d_mode
#define Gw OP_G, w_mode
#define Rd OP_Rd, d_mode
#define Rm OP_Rd, m_mode
#define Ib OP_I, b_mode
#define sIb OP_sI, b_mode	/* sign extened byte */
#define Iv OP_I, v_mode
#define Iq OP_I, q_mode
#define Iv64 OP_I64, v_mode
#define Iw OP_I, w_mode
#define Jb OP_J, b_mode
#define Jv OP_J, v_mode
#define Cm OP_C, m_mode
#define Dm OP_D, m_mode
#define Td OP_T, d_mode

#define RMeAX OP_REG, eAX_reg
#define RMeBX OP_REG, eBX_reg
#define RMeCX OP_REG, eCX_reg
#define RMeDX OP_REG, eDX_reg
#define RMeSP OP_REG, eSP_reg
#define RMeBP OP_REG, eBP_reg
#define RMeSI OP_REG, eSI_reg
#define RMeDI OP_REG, eDI_reg
#define RMrAX OP_REG, rAX_reg
#define RMrBX OP_REG, rBX_reg
#define RMrCX OP_REG, rCX_reg
#define RMrDX OP_REG, rDX_reg
#define RMrSP OP_REG, rSP_reg
#define RMrBP OP_REG, rBP_reg
#define RMrSI OP_REG, rSI_reg
#define RMrDI OP_REG, rDI_reg
#define RMAL OP_REG, al_reg
#define RMAL OP_REG, al_reg
#define RMCL OP_REG, cl_reg
#define RMDL OP_REG, dl_reg
#define RMBL OP_REG, bl_reg
#define RMAH OP_REG, ah_reg
#define RMCH OP_REG, ch_reg
#define RMDH OP_REG, dh_reg
#define RMBH OP_REG, bh_reg
#define RMAX OP_REG, ax_reg
#define RMDX OP_REG, dx_reg

#define eAX OP_IMREG, eAX_reg
#define eBX OP_IMREG, eBX_reg
#define eCX OP_IMREG, eCX_reg
#define eDX OP_IMREG, eDX_reg
#define eSP OP_IMREG, eSP_reg
#define eBP OP_IMREG, eBP_reg
#define eSI OP_IMREG, eSI_reg
#define eDI OP_IMREG, eDI_reg
#define AL OP_IMREG, al_reg
#define AL OP_IMREG, al_reg
#define CL OP_IMREG, cl_reg
#define DL OP_IMREG, dl_reg
#define BL OP_IMREG, bl_reg
#define AH OP_IMREG, ah_reg
#define CH OP_IMREG, ch_reg
#define DH OP_IMREG, dh_reg
#define BH OP_IMREG, bh_reg
#define AX OP_IMREG, ax_reg
#define DX OP_IMREG, dx_reg
#define indirDX OP_IMREG, indir_dx_reg

#define Sw OP_SEG, w_mode
#define Ap OP_DIR, 0
#define Ob OP_OFF, b_mode
#define Ob64 OP_OFF64, b_mode
#define Ov OP_OFF, v_mode
#define Ov64 OP_OFF64, v_mode
#define Xb OP_DSreg, eSI_reg
#define Xv OP_DSreg, eSI_reg
#define Yb OP_ESreg, eDI_reg
#define Yv OP_ESreg, eDI_reg
#define DSBX OP_DSreg, eBX_reg

#define es OP_REG, es_reg
#define ss OP_REG, ss_reg
#define cs OP_REG, cs_reg
#define ds OP_REG, ds_reg
#define fs OP_REG, fs_reg
#define gs OP_REG, gs_reg

#define MX OP_MMX, 0
#define XM OP_XMM, 0
#define EM OP_EM, v_mode
#define EX OP_EX, v_mode
#define MS OP_MS, v_mode
#define XS OP_XS, v_mode
#define None OP_E, 0
#define OPSUF OP_3DNowSuffix, 0
#define OPSIMD OP_SIMD_Suffix, 0

#define cond_jump_flag NULL, cond_jump_mode
#define loop_jcxz_flag NULL, loop_jcxz_mode

/* bits in sizeflag */
#define SUFFIX_ALWAYS 4
#define AFLAG 2
#define DFLAG 1

#define b_mode 1  /* byte operand */
#define v_mode 2  /* operand size depends on prefixes */
#define w_mode 3  /* word operand */
#define d_mode 4  /* double word operand  */
#define q_mode 5  /* quad word operand */
#define x_mode 6
#define m_mode 7  /* d_mode in 32bit, q_mode in 64bit mode.  */
#define cond_jump_mode 8
#define loop_jcxz_mode 9

#define es_reg 100
#define cs_reg 101
#define ss_reg 102
#define ds_reg 103
#define fs_reg 104
#define gs_reg 105

#define eAX_reg 108
#define eCX_reg 109
#define eDX_reg 110
#define eBX_reg 111
#define eSP_reg 112
#define eBP_reg 113
#define eSI_reg 114
#define eDI_reg 115

#define al_reg 116
#define cl_reg 117
#define dl_reg 118
#define bl_reg 119
#define ah_reg 120
#define ch_reg 121
#define dh_reg 122
#define bh_reg 123

#define ax_reg 124
#define cx_reg 125
#define dx_reg 126
#define bx_reg 127
#define sp_reg 128
#define bp_reg 129
#define si_reg 130
#define di_reg 131

#define rAX_reg 132
#define rCX_reg 133
#define rDX_reg 134
#define rBX_reg 135
#define rSP_reg 136
#define rBP_reg 137
#define rSI_reg 138
#define rDI_reg 139

#define indir_dx_reg 150

#define FLOATCODE 1
#define USE_GROUPS 2
#define USE_PREFIX_USER_TABLE 3
#define X86_64_SPECIAL 4

#define FLOAT	  NULL, NULL, FLOATCODE, NULL, 0, NULL, 0

#define GRP1b	  NULL, NULL, USE_GROUPS, NULL,  0, NULL, 0
#define GRP1S	  NULL, NULL, USE_GROUPS, NULL,  1, NULL, 0
#define GRP1Ss	  NULL, NULL, USE_GROUPS, NULL,  2, NULL, 0
#define GRP2b	  NULL, NULL, USE_GROUPS, NULL,  3, NULL, 0
#define GRP2S	  NULL, NULL, USE_GROUPS, NULL,  4, NULL, 0
#define GRP2b_one NULL, NULL, USE_GROUPS, NULL,  5, NULL, 0
#define GRP2S_one NULL, NULL, USE_GROUPS, NULL,  6, NULL, 0
#define GRP2b_cl  NULL, NULL, USE_GROUPS, NULL,  7, NULL, 0
#define GRP2S_cl  NULL, NULL, USE_GROUPS, NULL,  8, NULL, 0
#define GRP3b	  NULL, NULL, USE_GROUPS, NULL,  9, NULL, 0
#define GRP3S	  NULL, NULL, USE_GROUPS, NULL, 10, NULL, 0
#define GRP4	  NULL, NULL, USE_GROUPS, NULL, 11, NULL, 0
#define GRP5	  NULL, NULL, USE_GROUPS, NULL, 12, NULL, 0
#define GRP6	  NULL, NULL, USE_GROUPS, NULL, 13, NULL, 0
#define GRP7	  NULL, NULL, USE_GROUPS, NULL, 14, NULL, 0
#define GRP8	  NULL, NULL, USE_GROUPS, NULL, 15, NULL, 0
#define GRP9	  NULL, NULL, USE_GROUPS, NULL, 16, NULL, 0
#define GRP10	  NULL, NULL, USE_GROUPS, NULL, 17, NULL, 0
#define GRP11	  NULL, NULL, USE_GROUPS, NULL, 18, NULL, 0
#define GRP12	  NULL, NULL, USE_GROUPS, NULL, 19, NULL, 0
#define GRP13	  NULL, NULL, USE_GROUPS, NULL, 20, NULL, 0
#define GRP14	  NULL, NULL, USE_GROUPS, NULL, 21, NULL, 0
#define GRPAMD	  NULL, NULL, USE_GROUPS, NULL, 22, NULL, 0

#define PREGRP0   NULL, NULL, USE_PREFIX_USER_TABLE, NULL,  0, NULL, 0
#define PREGRP1   NULL, NULL, USE_PREFIX_USER_TABLE, NULL,  1, NULL, 0
#define PREGRP2   NULL, NULL, USE_PREFIX_USER_TABLE, NULL,  2, NULL, 0
#define PREGRP3   NULL, NULL, USE_PREFIX_USER_TABLE, NULL,  3, NULL, 0
#define PREGRP4   NULL, NULL, USE_PREFIX_USER_TABLE, NULL,  4, NULL, 0
#define PREGRP5   NULL, NULL, USE_PREFIX_USER_TABLE, NULL,  5, NULL, 0
#define PREGRP6   NULL, NULL, USE_PREFIX_USER_TABLE, NULL,  6, NULL, 0
#define PREGRP7   NULL, NULL, USE_PREFIX_USER_TABLE, NULL,  7, NULL, 0
#define PREGRP8   NULL, NULL, USE_PREFIX_USER_TABLE, NULL,  8, NULL, 0
#define PREGRP9   NULL, NULL, USE_PREFIX_USER_TABLE, NULL,  9, NULL, 0
#define PREGRP10  NULL, NULL, USE_PREFIX_USER_TABLE, NULL, 10, NULL, 0
#define PREGRP11  NULL, NULL, USE_PREFIX_USER_TABLE, NULL, 11, NULL, 0
#define PREGRP12  NULL, NULL, USE_PREFIX_USER_TABLE, NULL, 12, NULL, 0
#define PREGRP13  NULL, NULL, USE_PREFIX_USER_TABLE, NULL, 13, NULL, 0
#define PREGRP14  NULL, NULL, USE_PREFIX_USER_TABLE, NULL, 14, NULL, 0
#define PREGRP15  NULL, NULL, USE_PREFIX_USER_TABLE, NULL, 15, NULL, 0
#define PREGRP16  NULL, NULL, USE_PREFIX_USER_TABLE, NULL, 16, NULL, 0
#define PREGRP17  NULL, NULL, USE_PREFIX_USER_TABLE, NULL, 17, NULL, 0
#define PREGRP18  NULL, NULL, USE_PREFIX_USER_TABLE, NULL, 18, NULL, 0
#define PREGRP19  NULL, NULL, USE_PREFIX_USER_TABLE, NULL, 19, NULL, 0
#define PREGRP20  NULL, NULL, USE_PREFIX_USER_TABLE, NULL, 20, NULL, 0
#define PREGRP21  NULL, NULL, USE_PREFIX_USER_TABLE, NULL, 21, NULL, 0
#define PREGRP22  NULL, NULL, USE_PREFIX_USER_TABLE, NULL, 22, NULL, 0
#define PREGRP23  NULL, NULL, USE_PREFIX_USER_TABLE, NULL, 23, NULL, 0
#define PREGRP24  NULL, NULL, USE_PREFIX_USER_TABLE, NULL, 24, NULL, 0
#define PREGRP25  NULL, NULL, USE_PREFIX_USER_TABLE, NULL, 25, NULL, 0
#define PREGRP26  NULL, NULL, USE_PREFIX_USER_TABLE, NULL, 26, NULL, 0

#define X86_64_0  NULL, NULL, X86_64_SPECIAL, NULL,  0, NULL, 0

typedef void (*op_rtn) PARAMS ((int bytemode, int sizeflag));

struct dis386 {
  const char *name;
  op_rtn op1;
  int bytemode1;
  op_rtn op2;
  int bytemode2;
  op_rtn op3;
  int bytemode3;
};

/* Upper case letters in the instruction names here are macros.
   'A' => print 'b' if no register operands or suffix_always is true
   'B' => print 'b' if suffix_always is true
   'E' => print 'e' if 32-bit form of jcxz
   'F' => print 'w' or 'l' depending on address size prefix (loop insns)
   'H' => print ",pt" or ",pn" branch hint
   'L' => print 'l' if suffix_always is true
   'N' => print 'n' if instruction has no wait "prefix"
   'O' => print 'd', or 'o'
   'P' => print 'w', 'l' or 'q' if instruction has an operand size prefix,
   .      or suffix_always is true.  print 'q' if rex prefix is present.
   'Q' => print 'w', 'l' or 'q' if no register operands or suffix_always
   .      is true
   'R' => print 'w', 'l' or 'q' ("wd" or "dq" in intel mode)
   'S' => print 'w', 'l' or 'q' if suffix_always is true
   'T' => print 'q' in 64bit mode and behave as 'P' otherwise
   'U' => print 'q' in 64bit mode and behave as 'Q' otherwise
   'X' => print 's', 'd' depending on data16 prefix (for XMM)
   'W' => print 'b' or 'w' ("w" or "de" in intel mode)
   'Y' => 'q' if instruction has an REX 64bit overwrite prefix

   Many of the above letters print nothing in Intel mode.  See "putop"
   for the details.

   Braces '{' and '}', and vertical bars '|', indicate alternative
   mnemonic strings for AT&T, Intel, X86_64 AT&T, and X86_64 Intel
   modes.  In cases where there are only two alternatives, the X86_64
   instruction is reserved, and "(bad)" is printed.
*/

static const struct dis386 dis386[] = {
  /* 00 */
  { "addB",		Eb, Gb, XX },
  { "addS",		Ev, Gv, XX },
  { "addB",		Gb, Eb, XX },
  { "addS",		Gv, Ev, XX },
  { "addB",		AL, Ib, XX },
  { "addS",		eAX, Iv, XX },
  { "push{T|}",		es, XX, XX },
  { "pop{T|}",		es, XX, XX },
  /* 08 */
  { "orB",		Eb, Gb, XX },
  { "orS",		Ev, Gv, XX },
  { "orB",		Gb, Eb, XX },
  { "orS",		Gv, Ev, XX },
  { "orB",		AL, Ib, XX },
  { "orS",		eAX, Iv, XX },
  { "push{T|}",		cs, XX, XX },
  { "(bad)",		XX, XX, XX },	/* 0x0f extended opcode escape */
  /* 10 */
  { "adcB",		Eb, Gb, XX },
  { "adcS",		Ev, Gv, XX },
  { "adcB",		Gb, Eb, XX },
  { "adcS",		Gv, Ev, XX },
  { "adcB",		AL, Ib, XX },
  { "adcS",		eAX, Iv, XX },
  { "push{T|}",		ss, XX, XX },
  { "popT|}",		ss, XX, XX },
  /* 18 */
  { "sbbB",		Eb, Gb, XX },
  { "sbbS",		Ev, Gv, XX },
  { "sbbB",		Gb, Eb, XX },
  { "sbbS",		Gv, Ev, XX },
  { "sbbB",		AL, Ib, XX },
  { "sbbS",		eAX, Iv, XX },
  { "push{T|}",		ds, XX, XX },
  { "pop{T|}",		ds, XX, XX },
  /* 20 */
  { "andB",		Eb, Gb, XX },
  { "andS",		Ev, Gv, XX },
  { "andB",		Gb, Eb, XX },
  { "andS",		Gv, Ev, XX },
  { "andB",		AL, Ib, XX },
  { "andS",		eAX, Iv, XX },
  { "(bad)",		XX, XX, XX },	/* SEG ES prefix */
  { "daa{|}",		XX, XX, XX },
  /* 28 */
  { "subB",		Eb, Gb, XX },
  { "subS",		Ev, Gv, XX },
  { "subB",		Gb, Eb, XX },
  { "subS",		Gv, Ev, XX },
  { "subB",		AL, Ib, XX },
  { "subS",		eAX, Iv, XX },
  { "(bad)",		XX, XX, XX },	/* SEG CS prefix */
  { "das{|}",		XX, XX, XX },
  /* 30 */
  { "xorB",		Eb, Gb, XX },
  { "xorS",		Ev, Gv, XX },
  { "xorB",		Gb, Eb, XX },
  { "xorS",		Gv, Ev, XX },
  { "xorB",		AL, Ib, XX },
  { "xorS",		eAX, Iv, XX },
  { "(bad)",		XX, XX, XX },	/* SEG SS prefix */
  { "aaa{|}",		XX, XX, XX },
  /* 38 */
  { "cmpB",		Eb, Gb, XX },
  { "cmpS",		Ev, Gv, XX },
  { "cmpB",		Gb, Eb, XX },
  { "cmpS",		Gv, Ev, XX },
  { "cmpB",		AL, Ib, XX },
  { "cmpS",		eAX, Iv, XX },
  { "(bad)",		XX, XX, XX },	/* SEG DS prefix */
  { "aas{|}",		XX, XX, XX },
  /* 40 */
  { "inc{S|}",		RMeAX, XX, XX },
  { "inc{S|}",		RMeCX, XX, XX },
  { "inc{S|}",		RMeDX, XX, XX },
  { "inc{S|}",		RMeBX, XX, XX },
  { "inc{S|}",		RMeSP, XX, XX },
  { "inc{S|}",		RMeBP, XX, XX },
  { "inc{S|}",		RMeSI, XX, XX },
  { "inc{S|}",		RMeDI, XX, XX },
  /* 48 */
  { "dec{S|}",		RMeAX, XX, XX },
  { "dec{S|}",		RMeCX, XX, XX },
  { "dec{S|}",		RMeDX, XX, XX },
  { "dec{S|}",		RMeBX, XX, XX },
  { "dec{S|}",		RMeSP, XX, XX },
  { "dec{S|}",		RMeBP, XX, XX },
  { "dec{S|}",		RMeSI, XX, XX },
  { "dec{S|}",		RMeDI, XX, XX },
  /* 50 */
  { "pushS",		RMrAX, XX, XX },
  { "pushS",		RMrCX, XX, XX },
  { "pushS",		RMrDX, XX, XX },
  { "pushS",		RMrBX, XX, XX },
  { "pushS",		RMrSP, XX, XX },
  { "pushS",		RMrBP, XX, XX },
  { "pushS",		RMrSI, XX, XX },
  { "pushS",		RMrDI, XX, XX },
  /* 58 */
  { "popS",		RMrAX, XX, XX },
  { "popS",		RMrCX, XX, XX },
  { "popS",		RMrDX, XX, XX },
  { "popS",		RMrBX, XX, XX },
  { "popS",		RMrSP, XX, XX },
  { "popS",		RMrBP, XX, XX },
  { "popS",		RMrSI, XX, XX },
  { "popS",		RMrDI, XX, XX },
  /* 60 */
  { "pusha{P|}",	XX, XX, XX },
  { "popa{P|}",		XX, XX, XX },
  { "bound{S|}",	Gv, Ma, XX },
  { X86_64_0 },
  { "(bad)",		XX, XX, XX },	/* seg fs */
  { "(bad)",		XX, XX, XX },	/* seg gs */
  { "(bad)",		XX, XX, XX },	/* op size prefix */
  { "(bad)",		XX, XX, XX },	/* adr size prefix */
  /* 68 */
  { "pushT",		Iq, XX, XX },
  { "imulS",		Gv, Ev, Iv },
  { "pushT",		sIb, XX, XX },
  { "imulS",		Gv, Ev, sIb },
  { "ins{b||b|}",	Yb, indirDX, XX },
  { "ins{R||R|}",	Yv, indirDX, XX },
  { "outs{b||b|}",	indirDX, Xb, XX },
  { "outs{R||R|}",	indirDX, Xv, XX },
  /* 70 */
  { "joH",		Jb, XX, cond_jump_flag },
  { "jnoH",		Jb, XX, cond_jump_flag },
  { "jbH",		Jb, XX, cond_jump_flag },
  { "jaeH",		Jb, XX, cond_jump_flag },
  { "jeH",		Jb, XX, cond_jump_flag },
  { "jneH",		Jb, XX, cond_jump_flag },
  { "jbeH",		Jb, XX, cond_jump_flag },
  { "jaH",		Jb, XX, cond_jump_flag },
  /* 78 */
  { "jsH",		Jb, XX, cond_jump_flag },
  { "jnsH",		Jb, XX, cond_jump_flag },
  { "jpH",		Jb, XX, cond_jump_flag },
  { "jnpH",		Jb, XX, cond_jump_flag },
  { "jlH",		Jb, XX, cond_jump_flag },
  { "jgeH",		Jb, XX, cond_jump_flag },
  { "jleH",		Jb, XX, cond_jump_flag },
  { "jgH",		Jb, XX, cond_jump_flag },
  /* 80 */
  { GRP1b },
  { GRP1S },
  { "(bad)",		XX, XX, XX },
  { GRP1Ss },
  { "testB",		Eb, Gb, XX },
  { "testS",		Ev, Gv, XX },
  { "xchgB",		Eb, Gb, XX },
  { "xchgS",		Ev, Gv, XX },
  /* 88 */
  { "movB",		Eb, Gb, XX },
  { "movS",		Ev, Gv, XX },
  { "movB",		Gb, Eb, XX },
  { "movS",		Gv, Ev, XX },
  { "movQ",		Ev, Sw, XX },
  { "leaS",		Gv, M, XX },
  { "movQ",		Sw, Ev, XX },
  { "popU",		Ev, XX, XX },
  /* 90 */
  { "nop",		XX, XX, XX },
  /* FIXME: NOP with REPz prefix is called PAUSE.  */
  { "xchgS",		RMeCX, eAX, XX },
  { "xchgS",		RMeDX, eAX, XX },
  { "xchgS",		RMeBX, eAX, XX },
  { "xchgS",		RMeSP, eAX, XX },
  { "xchgS",		RMeBP, eAX, XX },
  { "xchgS",		RMeSI, eAX, XX },
  { "xchgS",		RMeDI, eAX, XX },
  /* 98 */
  { "cW{tR||tR|}",	XX, XX, XX },
  { "cR{tO||tO|}",	XX, XX, XX },
  { "lcall{T|}",	Ap, XX, XX },
  { "(bad)",		XX, XX, XX },	/* fwait */
  { "pushfT",		XX, XX, XX },
  { "popfT",		XX, XX, XX },
  { "sahf{|}",		XX, XX, XX },
  { "lahf{|}",		XX, XX, XX },
  /* a0 */
  { "movB",		AL, Ob64, XX },
  { "movS",		eAX, Ov64, XX },
  { "movB",		Ob64, AL, XX },
  { "movS",		Ov64, eAX, XX },
  { "movs{b||b|}",	Yb, Xb, XX },
  { "movs{R||R|}",	Yv, Xv, XX },
  { "cmps{b||b|}",	Xb, Yb, XX },
  { "cmps{R||R|}",	Xv, Yv, XX },
  /* a8 */
  { "testB",		AL, Ib, XX },
  { "testS",		eAX, Iv, XX },
  { "stosB",		Yb, AL, XX },
  { "stosS",		Yv, eAX, XX },
  { "lodsB",		AL, Xb, XX },
  { "lodsS",		eAX, Xv, XX },
  { "scasB",		AL, Yb, XX },
  { "scasS",		eAX, Yv, XX },
  /* b0 */
  { "movB",		RMAL, Ib, XX },
  { "movB",		RMCL, Ib, XX },
  { "movB",		RMDL, Ib, XX },
  { "movB",		RMBL, Ib, XX },
  { "movB",		RMAH, Ib, XX },
  { "movB",		RMCH, Ib, XX },
  { "movB",		RMDH, Ib, XX },
  { "movB",		RMBH, Ib, XX },
  /* b8 */
  { "movS",		RMeAX, Iv64, XX },
  { "movS",		RMeCX, Iv64, XX },
  { "movS",		RMeDX, Iv64, XX },
  { "movS",		RMeBX, Iv64, XX },
  { "movS",		RMeSP, Iv64, XX },
  { "movS",		RMeBP, Iv64, XX },
  { "movS",		RMeSI, Iv64, XX },
  { "movS",		RMeDI, Iv64, XX },
  /* c0 */
  { GRP2b },
  { GRP2S },
  { "retT",		Iw, XX, XX },
  { "retT",		XX, XX, XX },
  { "les{S|}",		Gv, Mp, XX },
  { "ldsS",		Gv, Mp, XX },
  { "movA",		Eb, Ib, XX },
  { "movQ",		Ev, Iv, XX },
  /* c8 */
  { "enterT",		Iw, Ib, XX },
  { "leaveT",		XX, XX, XX },
  { "lretP",		Iw, XX, XX },
  { "lretP",		XX, XX, XX },
  { "int3",		XX, XX, XX },
  { "int",		Ib, XX, XX },
  { "into{|}",		XX, XX, XX },
  { "iretP",		XX, XX, XX },
  /* d0 */
  { GRP2b_one },
  { GRP2S_one },
  { GRP2b_cl },
  { GRP2S_cl },
  { "aam{|}",		sIb, XX, XX },
  { "aad{|}",		sIb, XX, XX },
  { "(bad)",		XX, XX, XX },
  { "xlat",		DSBX, XX, XX },
  /* d8 */
  { FLOAT },
  { FLOAT },
  { FLOAT },
  { FLOAT },
  { FLOAT },
  { FLOAT },
  { FLOAT },
  { FLOAT },
  /* e0 */
  { "loopneFH",		Jb, XX, loop_jcxz_flag },
  { "loopeFH",		Jb, XX, loop_jcxz_flag },
  { "loopFH",		Jb, XX, loop_jcxz_flag },
  { "jEcxzH",		Jb, XX, loop_jcxz_flag },
  { "inB",		AL, Ib, XX },
  { "inS",		eAX, Ib, XX },
  { "outB",		Ib, AL, XX },
  { "outS",		Ib, eAX, XX },
  /* e8 */
  { "callT",		Jv, XX, XX },
  { "jmpT",		Jv, XX, XX },
  { "ljmp{T|}",		Ap, XX, XX },
  { "jmp",		Jb, XX, XX },
  { "inB",		AL, indirDX, XX },
  { "inS",		eAX, indirDX, XX },
  { "outB",		indirDX, AL, XX },
  { "outS",		indirDX, eAX, XX },
  /* f0 */
  { "(bad)",		XX, XX, XX },	/* lock prefix */
  { "(bad)",		XX, XX, XX },
  { "(bad)",		XX, XX, XX },	/* repne */
  { "(bad)",		XX, XX, XX },	/* repz */
  { "hlt",		XX, XX, XX },
  { "cmc",		XX, XX, XX },
  { GRP3b },
  { GRP3S },
  /* f8 */
  { "clc",		XX, XX, XX },
  { "stc",		XX, XX, XX },
  { "cli",		XX, XX, XX },
  { "sti",		XX, XX, XX },
  { "cld",		XX, XX, XX },
  { "std",		XX, XX, XX },
  { GRP4 },
  { GRP5 },
};

static const struct dis386 dis386_twobyte[] = {
  /* 00 */
  { GRP6 },
  { GRP7 },
  { "larS",		Gv, Ew, XX },
  { "lslS",		Gv, Ew, XX },
  { "(bad)",		XX, XX, XX },
  { "syscall",		XX, XX, XX },
  { "clts",		XX, XX, XX },
  { "sysretP",		XX, XX, XX },
  /* 08 */
  { "invd",		XX, XX, XX },
  { "wbinvd",		XX, XX, XX },
  { "(bad)",		XX, XX, XX },
  { "ud2a",		XX, XX, XX },
  { "(bad)",		XX, XX, XX },
  { GRPAMD },
  { "femms",		XX, XX, XX },
  { "",			MX, EM, OPSUF }, /* See OP_3DNowSuffix.  */
  /* 10 */
  { PREGRP8 },
  { PREGRP9 },
  { "movlpX",		XM, EX, SIMD_Fixup, 'h' }, /* really only 2 operands */
  { "movlpX",		EX, XM, SIMD_Fixup, 'h' },
  { "unpcklpX",		XM, EX, XX },
  { "unpckhpX",		XM, EX, XX },
  { "movhpX",		XM, EX, SIMD_Fixup, 'l' },
  { "movhpX",		EX, XM, SIMD_Fixup, 'l' },
  /* 18 */
  { GRP14 },
  { "(bad)",		XX, XX, XX },
  { "(bad)",		XX, XX, XX },
  { "(bad)",		XX, XX, XX },
  { "(bad)",		XX, XX, XX },
  { "(bad)",		XX, XX, XX },
  { "(bad)",		XX, XX, XX },
  { "(bad)",		XX, XX, XX },
  /* 20 */
  { "movL",		Rm, Cm, XX },
  { "movL",		Rm, Dm, XX },
  { "movL",		Cm, Rm, XX },
  { "movL",		Dm, Rm, XX },
  { "movL",		Rd, Td, XX },
  { "(bad)",		XX, XX, XX },
  { "movL",		Td, Rd, XX },
  { "(bad)",		XX, XX, XX },
  /* 28 */
  { "movapX",		XM, EX, XX },
  { "movapX",		EX, XM, XX },
  { PREGRP2 },
  { "movntpX",		Ev, XM, XX },
  { PREGRP4 },
  { PREGRP3 },
  { "ucomisX",		XM,EX, XX },
  { "comisX",		XM,EX, XX },
  /* 30 */
  { "wrmsr",		XX, XX, XX },
  { "rdtsc",		XX, XX, XX },
  { "rdmsr",		XX, XX, XX },
  { "rdpmc",		XX, XX, XX },
  { "sysenter",		XX, XX, XX },
  { "sysexit",		XX, XX, XX },
  { "(bad)",		XX, XX, XX },
  { "(bad)",		XX, XX, XX },
  /* 38 */
  { "(bad)",		XX, XX, XX },
  { "(bad)",		XX, XX, XX },
  { "(bad)",		XX, XX, XX },
  { "(bad)",		XX, XX, XX },
  { "(bad)",		XX, XX, XX },
  { "(bad)",		XX, XX, XX },
  { "(bad)",		XX, XX, XX },
  { "(bad)",		XX, XX, XX },
  /* 40 */
  { "cmovo",		Gv, Ev, XX },
  { "cmovno",		Gv, Ev, XX },
  { "cmovb",		Gv, Ev, XX },
  { "cmovae",		Gv, Ev, XX },
  { "cmove",		Gv, Ev, XX },
  { "cmovne",		Gv, Ev, XX },
  { "cmovbe",		Gv, Ev, XX },
  { "cmova",		Gv, Ev, XX },
  /* 48 */
  { "cmovs",		Gv, Ev, XX },
  { "cmovns",		Gv, Ev, XX },
  { "cmovp",		Gv, Ev, XX },
  { "cmovnp",		Gv, Ev, XX },
  { "cmovl",		Gv, Ev, XX },
  { "cmovge",		Gv, Ev, XX },
  { "cmovle",		Gv, Ev, XX },
  { "cmovg",		Gv, Ev, XX },
  /* 50 */
  { "movmskpX",		Gd, XS, XX },
  { PREGRP13 },
  { PREGRP12 },
  { PREGRP11 },
  { "andpX",		XM, EX, XX },
  { "andnpX",		XM, EX, XX },
  { "orpX",		XM, EX, XX },
  { "xorpX",		XM, EX, XX },
  /* 58 */
  { PREGRP0 },
  { PREGRP10 },
  { PREGRP17 },
  { PREGRP16 },
  { PREGRP14 },
  { PREGRP7 },
  { PREGRP5 },
  { PREGRP6 },
  /* 60 */
  { "punpcklbw",	MX, EM, XX },
  { "punpcklwd",	MX, EM, XX },
  { "punpckldq",	MX, EM, XX },
  { "packsswb",		MX, EM, XX },
  { "pcmpgtb",		MX, EM, XX },
  { "pcmpgtw",		MX, EM, XX },
  { "pcmpgtd",		MX, EM, XX },
  { "packuswb",		MX, EM, XX },
  /* 68 */
  { "punpckhbw",	MX, EM, XX },
  { "punpckhwd",	MX, EM, XX },
  { "punpckhdq",	MX, EM, XX },
  { "packssdw",		MX, EM, XX },
  { PREGRP26 },
  { PREGRP24 },
  { "movd",		MX, Ed, XX },
  { PREGRP19 },
  /* 70 */
  { PREGRP22 },
  { GRP10 },
  { GRP11 },
  { GRP12 },
  { "pcmpeqb",		MX, EM, XX },
  { "pcmpeqw",		MX, EM, XX },
  { "pcmpeqd",		MX, EM, XX },
  { "emms",		XX, XX, XX },
  /* 78 */
  { "(bad)",		XX, XX, XX },
  { "(bad)",		XX, XX, XX },
  { "(bad)",		XX, XX, XX },
  { "(bad)",		XX, XX, XX },
  { "(bad)",		XX, XX, XX },
  { "(bad)",		XX, XX, XX },
  { PREGRP23 },
  { PREGRP20 },
  /* 80 */
  { "joH",		Jv, XX, cond_jump_flag },
  { "jnoH",		Jv, XX, cond_jump_flag },
  { "jbH",		Jv, XX, cond_jump_flag },
  { "jaeH",		Jv, XX, cond_jump_flag },
  { "jeH",		Jv, XX, cond_jump_flag },
  { "jneH",		Jv, XX, cond_jump_flag },
  { "jbeH",		Jv, XX, cond_jump_flag },
  { "jaH",		Jv, XX, cond_jump_flag },
  /* 88 */
  { "jsH",		Jv, XX, cond_jump_flag },
  { "jnsH",		Jv, XX, cond_jump_flag },
  { "jpH",		Jv, XX, cond_jump_flag },
  { "jnpH",		Jv, XX, cond_jump_flag },
  { "jlH",		Jv, XX, cond_jump_flag },
  { "jgeH",		Jv, XX, cond_jump_flag },
  { "jleH",		Jv, XX, cond_jump_flag },
  { "jgH",		Jv, XX, cond_jump_flag },
  /* 90 */
  { "seto",		Eb, XX, XX },
  { "setno",		Eb, XX, XX },
  { "setb",		Eb, XX, XX },
  { "setae",		Eb, XX, XX },
  { "sete",		Eb, XX, XX },
  { "setne",		Eb, XX, XX },
  { "setbe",		Eb, XX, XX },
  { "seta",		Eb, XX, XX },
  /* 98 */
  { "sets",		Eb, XX, XX },
  { "setns",		Eb, XX, XX },
  { "setp",		Eb, XX, XX },
  { "setnp",		Eb, XX, XX },
  { "setl",		Eb, XX, XX },
  { "setge",		Eb, XX, XX },
  { "setle",		Eb, XX, XX },
  { "setg",		Eb, XX, XX },
  /* a0 */
  { "pushT",		fs, XX, XX },
  { "popT",		fs, XX, XX },
  { "cpuid",		XX, XX, XX },
  { "btS",		Ev, Gv, XX },
  { "shldS",		Ev, Gv, Ib },
  { "shldS",		Ev, Gv, CL },
  { "(bad)",		XX, XX, XX },
  { "(bad)",		XX, XX, XX },
  /* a8 */
  { "pushT",		gs, XX, XX },
  { "popT",		gs, XX, XX },
  { "rsm",		XX, XX, XX },
  { "btsS",		Ev, Gv, XX },
  { "shrdS",		Ev, Gv, Ib },
  { "shrdS",		Ev, Gv, CL },
  { GRP13 },
  { "imulS",		Gv, Ev, XX },
  /* b0 */
  { "cmpxchgB",		Eb, Gb, XX },
  { "cmpxchgS",		Ev, Gv, XX },
  { "lssS",		Gv, Mp, XX },
  { "btrS",		Ev, Gv, XX },
  { "lfsS",		Gv, Mp, XX },
  { "lgsS",		Gv, Mp, XX },
  { "movz{bR|x|bR|x}",	Gv, Eb, XX },
  { "movz{wR|x|wR|x}",	Gv, Ew, XX }, /* yes, there really is movzww ! */
  /* b8 */
  { "(bad)",		XX, XX, XX },
  { "ud2b",		XX, XX, XX },
  { GRP8 },
  { "btcS",		Ev, Gv, XX },
  { "bsfS",		Gv, Ev, XX },
  { "bsrS",		Gv, Ev, XX },
  { "movs{bR|x|bR|x}",	Gv, Eb, XX },
  { "movs{wR|x|wR|x}",	Gv, Ew, XX }, /* yes, there really is movsww ! */
  /* c0 */
  { "xaddB",		Eb, Gb, XX },
  { "xaddS",		Ev, Gv, XX },
  { PREGRP1 },
  { "movntiS",		Ev, Gv, XX },
  { "pinsrw",		MX, Ed, Ib },
  { "pextrw",		Gd, MS, Ib },
  { "shufpX",		XM, EX, Ib },
  { GRP9 },
  /* c8 */
  { "bswap",		RMeAX, XX, XX },
  { "bswap",		RMeCX, XX, XX },
  { "bswap",		RMeDX, XX, XX },
  { "bswap",		RMeBX, XX, XX },
  { "bswap",		RMeSP, XX, XX },
  { "bswap",		RMeBP, XX, XX },
  { "bswap",		RMeSI, XX, XX },
  { "bswap",		RMeDI, XX, XX },
  /* d0 */
  { "(bad)",		XX, XX, XX },
  { "psrlw",		MX, EM, XX },
  { "psrld",		MX, EM, XX },
  { "psrlq",		MX, EM, XX },
  { "paddq",		MX, EM, XX },
  { "pmullw",		MX, EM, XX },
  { PREGRP21 },
  { "pmovmskb",		Gd, MS, XX },
  /* d8 */
  { "psubusb",		MX, EM, XX },
  { "psubusw",		MX, EM, XX },
  { "pminub",		MX, EM, XX },
  { "pand",		MX, EM, XX },
  { "paddusb",		MX, EM, XX },
  { "paddusw",		MX, EM, XX },
  { "pmaxub",		MX, EM, XX },
  { "pandn",		MX, EM, XX },
  /* e0 */
  { "pavgb",		MX, EM, XX },
  { "psraw",		MX, EM, XX },
  { "psrad",		MX, EM, XX },
  { "pavgw",		MX, EM, XX },
  { "pmulhuw",		MX, EM, XX },
  { "pmulhw",		MX, EM, XX },
  { PREGRP15 },
  { PREGRP25 },
  /* e8 */
  { "psubsb",		MX, EM, XX },
  { "psubsw",		MX, EM, XX },
  { "pminsw",		MX, EM, XX },
  { "por",		MX, EM, XX },
  { "paddsb",		MX, EM, XX },
  { "paddsw",		MX, EM, XX },
  { "pmaxsw",		MX, EM, XX },
  { "pxor",		MX, EM, XX },
  /* f0 */
  { "(bad)",		XX, XX, XX },
  { "psllw",		MX, EM, XX },
  { "pslld",		MX, EM, XX },
  { "psllq",		MX, EM, XX },
  { "pmuludq",		MX, EM, XX },
  { "pmaddwd",		MX, EM, XX },
  { "psadbw",		MX, EM, XX },
  { PREGRP18 },
  /* f8 */
  { "psubb",		MX, EM, XX },
  { "psubw",		MX, EM, XX },
  { "psubd",		MX, EM, XX },
  { "psubq",		MX, EM, XX },
  { "paddb",		MX, EM, XX },
  { "paddw",		MX, EM, XX },
  { "paddd",		MX, EM, XX },
  { "(bad)",		XX, XX, XX }
};

static const unsigned char onebyte_has_modrm[256] = {
  /*       0 1 2 3 4 5 6 7 8 9 a b c d e f        */
  /*       -------------------------------        */
  /* 00 */ 1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0, /* 00 */
  /* 10 */ 1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0, /* 10 */
  /* 20 */ 1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0, /* 20 */
  /* 30 */ 1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0, /* 30 */
  /* 40 */ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* 40 */
  /* 50 */ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* 50 */
  /* 60 */ 0,0,1,1,0,0,0,0,0,1,0,1,0,0,0,0, /* 60 */
  /* 70 */ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* 70 */
  /* 80 */ 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, /* 80 */
  /* 90 */ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* 90 */
  /* a0 */ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* a0 */
  /* b0 */ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* b0 */
  /* c0 */ 1,1,0,0,1,1,1,1,0,0,0,0,0,0,0,0, /* c0 */
  /* d0 */ 1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1, /* d0 */
  /* e0 */ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* e0 */
  /* f0 */ 0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1  /* f0 */
  /*       -------------------------------        */
  /*       0 1 2 3 4 5 6 7 8 9 a b c d e f        */
};

static const unsigned char twobyte_has_modrm[256] = {
  /*       0 1 2 3 4 5 6 7 8 9 a b c d e f        */
  /*       -------------------------------        */
  /* 00 */ 1,1,1,1,0,0,0,0,0,0,0,0,0,1,0,1, /* 0f */
  /* 10 */ 1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0, /* 1f */
  /* 20 */ 1,1,1,1,1,0,1,0,1,1,1,1,1,1,1,1, /* 2f */
  /* 30 */ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* 3f */
  /* 40 */ 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, /* 4f */
  /* 50 */ 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, /* 5f */
  /* 60 */ 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, /* 6f */
  /* 70 */ 1,1,1,1,1,1,1,0,0,0,0,0,0,0,1,1, /* 7f */
  /* 80 */ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* 8f */
  /* 90 */ 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, /* 9f */
  /* a0 */ 0,0,0,1,1,1,0,0,0,0,0,1,1,1,1,1, /* af */
  /* b0 */ 1,1,1,1,1,1,1,1,0,0,1,1,1,1,1,1, /* bf */
  /* c0 */ 1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0, /* cf */
  /* d0 */ 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, /* df */
  /* e0 */ 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, /* ef */
  /* f0 */ 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0  /* ff */
  /*       -------------------------------        */
  /*       0 1 2 3 4 5 6 7 8 9 a b c d e f        */
};

static const unsigned char twobyte_uses_SSE_prefix[256] = {
  /*       0 1 2 3 4 5 6 7 8 9 a b c d e f        */
  /*       -------------------------------        */
  /* 00 */ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* 0f */
  /* 10 */ 1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* 1f */
  /* 20 */ 0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,0, /* 2f */
  /* 30 */ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* 3f */
  /* 40 */ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* 4f */
  /* 50 */ 0,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1, /* 5f */
  /* 60 */ 0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1, /* 6f */
  /* 70 */ 1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1, /* 7f */
  /* 80 */ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* 8f */
  /* 90 */ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* 9f */
  /* a0 */ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* af */
  /* b0 */ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* bf */
  /* c0 */ 0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0, /* cf */
  /* d0 */ 0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0, /* df */
  /* e0 */ 0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0, /* ef */
  /* f0 */ 0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0  /* ff */
  /*       -------------------------------        */
  /*       0 1 2 3 4 5 6 7 8 9 a b c d e f        */
};

static char obuf[100];
static char *obufp;
static char scratchbuf[100];
static unsigned char *start_codep;
static unsigned char *insn_codep;
static unsigned char *codep;
static disassemble_info *the_info;
static int mod;
static int rm;
static int reg;
static unsigned char need_modrm;

/* If we are accessing mod/rm/reg without need_modrm set, then the
   values are stale.  Hitting this abort likely indicates that you
   need to update onebyte_has_modrm or twobyte_has_modrm.  */
#define MODRM_CHECK  if (!need_modrm) panic("moder check");

static const char * const *names64;
static const char * const *names32;
static const char * const *names16;
static const char * const *names8;
static const char * const *names8rex;
static const char * const *names_seg;
static const char * const *index16;

static const char * const intel_names64[] = {
  "rax", "rcx", "rdx", "rbx", "rsp", "rbp", "rsi", "rdi",
  "r8", "r9", "r10", "r11", "r12", "r13", "r14", "r15"
};
static const char * const intel_names32[] = {
  "eax", "ecx", "edx", "ebx", "esp", "ebp", "esi", "edi",
  "r8d", "r9d", "r10d", "r11d", "r12d", "r13d", "r14d", "r15d"
};
static const char * const intel_names16[] = {
  "ax", "cx", "dx", "bx", "sp", "bp", "si", "di",
  "r8w", "r9w", "r10w", "r11w", "r12w", "r13w", "r14w", "r15w"
};
static const char * const intel_names8[] = {
  "al", "cl", "dl", "bl", "ah", "ch", "dh", "bh",
};
static const char * const intel_names8rex[] = {
  "al", "cl", "dl", "bl", "spl", "bpl", "sil", "dil",
  "r8b", "r9b", "r10b", "r11b", "r12b", "r13b", "r14b", "r15b"
};
static const char * const intel_names_seg[] = {
  "es", "cs", "ss", "ds", "fs", "gs", "?", "?",
};
static const char * const intel_index16[] = {
  "bx+si", "bx+di", "bp+si", "bp+di", "si", "di", "bp", "bx"
};

static const char * const att_names64[] = {
  "%rax", "%rcx", "%rdx", "%rbx", "%rsp", "%rbp", "%rsi", "%rdi",
  "%r8", "%r9", "%r10", "%r11", "%r12", "%r13", "%r14", "%r15"
};
static const char * const att_names32[] = {
  "%eax", "%ecx", "%edx", "%ebx", "%esp", "%ebp", "%esi", "%edi",
  "%r8d", "%r9d", "%r10d", "%r11d", "%r12d", "%r13d", "%r14d", "%r15d"
};
static const char * const att_names16[] = {
  "%ax", "%cx", "%dx", "%bx", "%sp", "%bp", "%si", "%di",
  "%r8w", "%r9w", "%r10w", "%r11w", "%r12w", "%r13w", "%r14w", "%r15w"
};
static const char * const att_names8[] = {
  "%al", "%cl", "%dl", "%bl", "%ah", "%ch", "%dh", "%bh",
};
static const char * const att_names8rex[] = {
  "%al", "%cl", "%dl", "%bl", "%spl", "%bpl", "%sil", "%dil",
  "%r8b", "%r9b", "%r10b", "%r11b", "%r12b", "%r13b", "%r14b", "%r15b"
};
static const char * const att_names_seg[] = {
  "%es", "%cs", "%ss", "%ds", "%fs", "%gs", "%?", "%?",
};
static const char * const att_index16[] = {
  "%bx,%si", "%bx,%di", "%bp,%si", "%bp,%di", "%si", "%di", "%bp", "%bx"
};

static const struct dis386 grps[][8] = {
  /* GRP1b */
  {
    { "addA",	Eb, Ib, XX },
    { "orA",	Eb, Ib, XX },
    { "adcA",	Eb, Ib, XX },
    { "sbbA",	Eb, Ib, XX },
    { "andA",	Eb, Ib, XX },
    { "subA",	Eb, Ib, XX },
    { "xorA",	Eb, Ib, XX },
    { "cmpA",	Eb, Ib, XX }
  },
  /* GRP1S */
  {
    { "addQ",	Ev, Iv, XX },
    { "orQ",	Ev, Iv, XX },
    { "adcQ",	Ev, Iv, XX },
    { "sbbQ",	Ev, Iv, XX },
    { "andQ",	Ev, Iv, XX },
    { "subQ",	Ev, Iv, XX },
    { "xorQ",	Ev, Iv, XX },
    { "cmpQ",	Ev, Iv, XX }
  },
  /* GRP1Ss */
  {
    { "addQ",	Ev, sIb, XX },
    { "orQ",	Ev, sIb, XX },
    { "adcQ",	Ev, sIb, XX },
    { "sbbQ",	Ev, sIb, XX },
    { "andQ",	Ev, sIb, XX },
    { "subQ",	Ev, sIb, XX },
    { "xorQ",	Ev, sIb, XX },
    { "cmpQ",	Ev, sIb, XX }
  },
  /* GRP2b */
  {
    { "rolA",	Eb, Ib, XX },
    { "rorA",	Eb, Ib, XX },
    { "rclA",	Eb, Ib, XX },
    { "rcrA",	Eb, Ib, XX },
    { "shlA",	Eb, Ib, XX },
    { "shrA",	Eb, Ib, XX },
    { "(bad)",	XX, XX, XX },
    { "sarA",	Eb, Ib, XX },
  },
  /* GRP2S */
  {
    { "rolQ",	Ev, Ib, XX },
    { "rorQ",	Ev, Ib, XX },
    { "rclQ",	Ev, Ib, XX },
    { "rcrQ",	Ev, Ib, XX },
    { "shlQ",	Ev, Ib, XX },
    { "shrQ",	Ev, Ib, XX },
    { "(bad)",	XX, XX, XX },
    { "sarQ",	Ev, Ib, XX },
  },
  /* GRP2b_one */
  {
    { "rolA",	Eb, XX, XX },
    { "rorA",	Eb, XX, XX },
    { "rclA",	Eb, XX, XX },
    { "rcrA",	Eb, XX, XX },
    { "shlA",	Eb, XX, XX },
    { "shrA",	Eb, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "sarA",	Eb, XX, XX },
  },
  /* GRP2S_one */
  {
    { "rolQ",	Ev, XX, XX },
    { "rorQ",	Ev, XX, XX },
    { "rclQ",	Ev, XX, XX },
    { "rcrQ",	Ev, XX, XX },
    { "shlQ",	Ev, XX, XX },
    { "shrQ",	Ev, XX, XX },
    { "(bad)",	XX, XX, XX},
    { "sarQ",	Ev, XX, XX },
  },
  /* GRP2b_cl */
  {
    { "rolA",	Eb, CL, XX },
    { "rorA",	Eb, CL, XX },
    { "rclA",	Eb, CL, XX },
    { "rcrA",	Eb, CL, XX },
    { "shlA",	Eb, CL, XX },
    { "shrA",	Eb, CL, XX },
    { "(bad)",	XX, XX, XX },
    { "sarA",	Eb, CL, XX },
  },
  /* GRP2S_cl */
  {
    { "rolQ",	Ev, CL, XX },
    { "rorQ",	Ev, CL, XX },
    { "rclQ",	Ev, CL, XX },
    { "rcrQ",	Ev, CL, XX },
    { "shlQ",	Ev, CL, XX },
    { "shrQ",	Ev, CL, XX },
    { "(bad)",	XX, XX, XX },
    { "sarQ",	Ev, CL, XX }
  },
  /* GRP3b */
  {
    { "testA",	Eb, Ib, XX },
    { "(bad)",	Eb, XX, XX },
    { "notA",	Eb, XX, XX },
    { "negA",	Eb, XX, XX },
    { "mulA",	Eb, XX, XX },	/* Don't print the implicit %al register,  */
    { "imulA",	Eb, XX, XX },	/* to distinguish these opcodes from other */
    { "divA",	Eb, XX, XX },	/* mul/imul opcodes.  Do the same for div  */
    { "idivA",	Eb, XX, XX }	/* and idiv for consistency.		   */
  },
  /* GRP3S */
  {
    { "testQ",	Ev, Iv, XX },
    { "(bad)",	XX, XX, XX },
    { "notQ",	Ev, XX, XX },
    { "negQ",	Ev, XX, XX },
    { "mulQ",	Ev, XX, XX },	/* Don't print the implicit register.  */
    { "imulQ",	Ev, XX, XX },
    { "divQ",	Ev, XX, XX },
    { "idivQ",	Ev, XX, XX },
  },
  /* GRP4 */
  {
    { "incA",	Eb, XX, XX },
    { "decA",	Eb, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
  },
  /* GRP5 */
  {
    { "incQ",	Ev, XX, XX },
    { "decQ",	Ev, XX, XX },
    { "callT",	indirEv, XX, XX },
    { "lcallT",	indirEv, XX, XX },
    { "jmpT",	indirEv, XX, XX },
    { "ljmpT",	indirEv, XX, XX },
    { "pushU",	Ev, XX, XX },
    { "(bad)",	XX, XX, XX },
  },
  /* GRP6 */
  {
    { "sldtQ",	Ev, XX, XX },
    { "strQ",	Ev, XX, XX },
    { "lldt",	Ew, XX, XX },
    { "ltr",	Ew, XX, XX },
    { "verr",	Ew, XX, XX },
    { "verw",	Ew, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX }
  },
  /* GRP7 */
  {
    { "sgdtQ",	 M, XX, XX },
    { "sidtQ",	 M, XX, XX },
    { "lgdtQ",	 M, XX, XX },
    { "lidtQ",	 M, XX, XX },
    { "smswQ",	Ev, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "lmsw",	Ew, XX, XX },
    { "invlpg",	Ew, XX, XX },
  },
  /* GRP8 */
  {
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "btQ",	Ev, Ib, XX },
    { "btsQ",	Ev, Ib, XX },
    { "btrQ",	Ev, Ib, XX },
    { "btcQ",	Ev, Ib, XX },
  },
  /* GRP9 */
  {
    { "(bad)",	XX, XX, XX },
    { "cmpxchg8b", Ev, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
  },
  /* GRP10 */
  {
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "psrlw",	MS, Ib, XX },
    { "(bad)",	XX, XX, XX },
    { "psraw",	MS, Ib, XX },
    { "(bad)",	XX, XX, XX },
    { "psllw",	MS, Ib, XX },
    { "(bad)",	XX, XX, XX },
  },
  /* GRP11 */
  {
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "psrld",	MS, Ib, XX },
    { "(bad)",	XX, XX, XX },
    { "psrad",	MS, Ib, XX },
    { "(bad)",	XX, XX, XX },
    { "pslld",	MS, Ib, XX },
    { "(bad)",	XX, XX, XX },
  },
  /* GRP12 */
  {
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "psrlq",	MS, Ib, XX },
    { "psrldq",	MS, Ib, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "psllq",	MS, Ib, XX },
    { "pslldq",	MS, Ib, XX },
  },
  /* GRP13 */
  {
    { "fxsave", Ev, XX, XX },
    { "fxrstor", Ev, XX, XX },
    { "ldmxcsr", Ev, XX, XX },
    { "stmxcsr", Ev, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "lfence", None, XX, XX },
    { "mfence", None, XX, XX },
    { "sfence", None, XX, XX },
    /* FIXME: the sfence with memory operand is clflush!  */
  },
  /* GRP14 */
  {
    { "prefetchnta", Ev, XX, XX },
    { "prefetcht0", Ev, XX, XX },
    { "prefetcht1", Ev, XX, XX },
    { "prefetcht2", Ev, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
  },
  /* GRPAMD */
  {
    { "prefetch", Eb, XX, XX },
    { "prefetchw", Eb, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
  }
};

static const struct dis386 prefix_user_table[][4] = {
  /* PREGRP0 */
  {
    { "addps", XM, EX, XX },
    { "addss", XM, EX, XX },
    { "addpd", XM, EX, XX },
    { "addsd", XM, EX, XX },
  },
  /* PREGRP1 */
  {
    { "", XM, EX, OPSIMD },	/* See OP_SIMD_SUFFIX.  */
    { "", XM, EX, OPSIMD },
    { "", XM, EX, OPSIMD },
    { "", XM, EX, OPSIMD },
  },
  /* PREGRP2 */
  {
    { "cvtpi2ps", XM, EM, XX },
    { "cvtsi2ssY", XM, Ev, XX },
    { "cvtpi2pd", XM, EM, XX },
    { "cvtsi2sdY", XM, Ev, XX },
  },
  /* PREGRP3 */
  {
    { "cvtps2pi", MX, EX, XX },
    { "cvtss2siY", Gv, EX, XX },
    { "cvtpd2pi", MX, EX, XX },
    { "cvtsd2siY", Gv, EX, XX },
  },
  /* PREGRP4 */
  {
    { "cvttps2pi", MX, EX, XX },
    { "cvttss2siY", Gv, EX, XX },
    { "cvttpd2pi", MX, EX, XX },
    { "cvttsd2siY", Gv, EX, XX },
  },
  /* PREGRP5 */
  {
    { "divps", XM, EX, XX },
    { "divss", XM, EX, XX },
    { "divpd", XM, EX, XX },
    { "divsd", XM, EX, XX },
  },
  /* PREGRP6 */
  {
    { "maxps", XM, EX, XX },
    { "maxss", XM, EX, XX },
    { "maxpd", XM, EX, XX },
    { "maxsd", XM, EX, XX },
  },
  /* PREGRP7 */
  {
    { "minps", XM, EX, XX },
    { "minss", XM, EX, XX },
    { "minpd", XM, EX, XX },
    { "minsd", XM, EX, XX },
  },
  /* PREGRP8 */
  {
    { "movups", XM, EX, XX },
    { "movss", XM, EX, XX },
    { "movupd", XM, EX, XX },
    { "movsd", XM, EX, XX },
  },
  /* PREGRP9 */
  {
    { "movups", EX, XM, XX },
    { "movss", EX, XM, XX },
    { "movupd", EX, XM, XX },
    { "movsd", EX, XM, XX },
  },
  /* PREGRP10 */
  {
    { "mulps", XM, EX, XX },
    { "mulss", XM, EX, XX },
    { "mulpd", XM, EX, XX },
    { "mulsd", XM, EX, XX },
  },
  /* PREGRP11 */
  {
    { "rcpps", XM, EX, XX },
    { "rcpss", XM, EX, XX },
    { "(bad)", XM, EX, XX },
    { "(bad)", XM, EX, XX },
  },
  /* PREGRP12 */
  {
    { "rsqrtps", XM, EX, XX },
    { "rsqrtss", XM, EX, XX },
    { "(bad)", XM, EX, XX },
    { "(bad)", XM, EX, XX },
  },
  /* PREGRP13 */
  {
    { "sqrtps", XM, EX, XX },
    { "sqrtss", XM, EX, XX },
    { "sqrtpd", XM, EX, XX },
    { "sqrtsd", XM, EX, XX },
  },
  /* PREGRP14 */
  {
    { "subps", XM, EX, XX },
    { "subss", XM, EX, XX },
    { "subpd", XM, EX, XX },
    { "subsd", XM, EX, XX },
  },
  /* PREGRP15 */
  {
    { "(bad)", XM, EX, XX },
    { "cvtdq2pd", XM, EX, XX },
    { "cvttpd2dq", XM, EX, XX },
    { "cvtpd2dq", XM, EX, XX },
  },
  /* PREGRP16 */
  {
    { "cvtdq2ps", XM, EX, XX },
    { "cvttps2dq",XM, EX, XX },
    { "cvtps2dq",XM, EX, XX },
    { "(bad)", XM, EX, XX },
  },
  /* PREGRP17 */
  {
    { "cvtps2pd", XM, EX, XX },
    { "cvtss2sd", XM, EX, XX },
    { "cvtpd2ps", XM, EX, XX },
    { "cvtsd2ss", XM, EX, XX },
  },
  /* PREGRP18 */
  {
    { "maskmovq", MX, MS, XX },
    { "(bad)", XM, EX, XX },
    { "maskmovdqu", XM, EX, XX },
    { "(bad)", XM, EX, XX },
  },
  /* PREGRP19 */
  {
    { "movq", MX, EM, XX },
    { "movdqu", XM, EX, XX },
    { "movdqa", XM, EX, XX },
    { "(bad)", XM, EX, XX },
  },
  /* PREGRP20 */
  {
    { "movq", EM, MX, XX },
    { "movdqu", EX, XM, XX },
    { "movdqa", EX, XM, XX },
    { "(bad)", EX, XM, XX },
  },
  /* PREGRP21 */
  {
    { "(bad)", EX, XM, XX },
    { "movq2dq", XM, MS, XX },
    { "movq", EX, XM, XX },
    { "movdq2q", MX, XS, XX },
  },
  /* PREGRP22 */
  {
    { "pshufw", MX, EM, Ib },
    { "pshufhw", XM, EX, Ib },
    { "pshufd", XM, EX, Ib },
    { "pshuflw", XM, EX, Ib },
  },
  /* PREGRP23 */
  {
    { "movd", Ed, MX, XX },
    { "movq", XM, EX, XX },
    { "movd", Ed, XM, XX },
    { "(bad)", Ed, XM, XX },
  },
  /* PREGRP24 */
  {
    { "(bad)", MX, EX, XX },
    { "(bad)", XM, EX, XX },
    { "punpckhqdq", XM, EX, XX },
    { "(bad)", XM, EX, XX },
  },
  /* PREGRP25 */
  {
  { "movntq", Ev, MX, XX },
  { "(bad)", Ev, XM, XX },
  { "movntdq", Ev, XM, XX },
  { "(bad)", Ev, XM, XX },
  },
  /* PREGRP26 */
  {
    { "(bad)", MX, EX, XX },
    { "(bad)", XM, EX, XX },
    { "punpcklqdq", XM, EX, XX },
    { "(bad)", XM, EX, XX },
  },
};

static const struct dis386 x86_64_table[][2] = {
  {
    { "arpl", Ew, Gw, XX },
    { "movs{||lq|xd}", Gv, Ed, XX },
  },
};

#define INTERNAL_DISASSEMBLER_ERROR _("<internal disassembler error>")

static void
ckprefix ()
{
  int newrex;
  rex = 0;
  prefixes = 0;
  used_prefixes = 0;
  rex_used = 0;
  while (1)
    {
      FETCH_DATA (the_info, codep + 1);
      newrex = 0;
      switch (*codep)
	{
	/* REX prefixes family.  */
	case 0x40:
	case 0x41:
	case 0x42:
	case 0x43:
	case 0x44:
	case 0x45:
	case 0x46:
	case 0x47:
	case 0x48:
	case 0x49:
	case 0x4a:
	case 0x4b:
	case 0x4c:
	case 0x4d:
	case 0x4e:
	case 0x4f:
	    if (mode_64bit)
	      newrex = *codep;
	    else
	      return;
	  break;
	case 0xf3:
	  prefixes |= PREFIX_REPZ;
	  break;
	case 0xf2:
	  prefixes |= PREFIX_REPNZ;
	  break;
	case 0xf0:
	  prefixes |= PREFIX_LOCK;
	  break;
	case 0x2e:
	  prefixes |= PREFIX_CS;
	  break;
	case 0x36:
	  prefixes |= PREFIX_SS;
	  break;
	case 0x3e:
	  prefixes |= PREFIX_DS;
	  break;
	case 0x26:
	  prefixes |= PREFIX_ES;
	  break;
	case 0x64:
	  prefixes |= PREFIX_FS;
	  break;
	case 0x65:
	  prefixes |= PREFIX_GS;
	  break;
	case 0x66:
	  prefixes |= PREFIX_DATA;
	  break;
	case 0x67:
	  prefixes |= PREFIX_ADDR;
	  break;
	case FWAIT_OPCODE:
	  /* fwait is really an instruction.  If there are prefixes
	     before the fwait, they belong to the fwait, *not* to the
	     following instruction.  */
	  if (prefixes)
	    {
	      prefixes |= PREFIX_FWAIT;
	      codep++;
	      return;
	    }
	  prefixes = PREFIX_FWAIT;
	  break;
	default:
	  return;
	}
      /* Rex is ignored when followed by another prefix.  */
      if (rex)
	{
	  oappend (prefix_name (rex, 0));
	  oappend (" ");
	}
      rex = newrex;
      codep++;
    }
}

/* Return the name of the prefix byte PREF, or NULL if PREF is not a
   prefix byte.  */

static const char *
prefix_name (pref, sizeflag)
     int pref;
     int sizeflag;
{
f010576b:	55                   	push   %ebp
f010576c:	89 e5                	mov    %esp,%ebp
  switch (pref)
f010576e:	83 e8 26             	sub    $0x26,%eax
f0105771:	3d cd 00 00 00       	cmp    $0xcd,%eax
f0105776:	77 11                	ja     f0105789 <prefix_name+0x1e>
f0105778:	ff 24 85 60 d2 10 f0 	jmp    *0xf010d260(,%eax,4)
f010577f:	b8 52 bf 10 f0       	mov    $0xf010bf52,%eax
f0105784:	e9 22 01 00 00       	jmp    f01058ab <prefix_name+0x140>
f0105789:	b8 00 00 00 00       	mov    $0x0,%eax
f010578e:	66 90                	xchg   %ax,%ax
f0105790:	e9 16 01 00 00       	jmp    f01058ab <prefix_name+0x140>
f0105795:	b8 58 bf 10 f0       	mov    $0xf010bf58,%eax
f010579a:	e9 0c 01 00 00       	jmp    f01058ab <prefix_name+0x140>
    {
    /* REX prefixes family.  */
    case 0x40:
      return "rex";
f010579f:	b8 5c bf 10 f0       	mov    $0xf010bf5c,%eax
f01057a4:	e9 02 01 00 00       	jmp    f01058ab <prefix_name+0x140>
    case 0x41:
      return "rexZ";
f01057a9:	b8 61 bf 10 f0       	mov    $0xf010bf61,%eax
f01057ae:	e9 f8 00 00 00       	jmp    f01058ab <prefix_name+0x140>
    case 0x42:
      return "rexY";
f01057b3:	b8 66 bf 10 f0       	mov    $0xf010bf66,%eax
f01057b8:	e9 ee 00 00 00       	jmp    f01058ab <prefix_name+0x140>
    case 0x43:
      return "rexYZ";
f01057bd:	b8 6c bf 10 f0       	mov    $0xf010bf6c,%eax
f01057c2:	e9 e4 00 00 00       	jmp    f01058ab <prefix_name+0x140>
    case 0x44:
      return "rexX";
f01057c7:	b8 71 bf 10 f0       	mov    $0xf010bf71,%eax
f01057cc:	e9 da 00 00 00       	jmp    f01058ab <prefix_name+0x140>
    case 0x45:
      return "rexXZ";
f01057d1:	b8 77 bf 10 f0       	mov    $0xf010bf77,%eax
f01057d6:	e9 d0 00 00 00       	jmp    f01058ab <prefix_name+0x140>
    case 0x46:
      return "rexXY";
f01057db:	b8 7d bf 10 f0       	mov    $0xf010bf7d,%eax
f01057e0:	e9 c6 00 00 00       	jmp    f01058ab <prefix_name+0x140>
    case 0x47:
      return "rexXYZ";
f01057e5:	b8 84 bf 10 f0       	mov    $0xf010bf84,%eax
f01057ea:	e9 bc 00 00 00       	jmp    f01058ab <prefix_name+0x140>
    case 0x48:
      return "rex64";
f01057ef:	b8 8a bf 10 f0       	mov    $0xf010bf8a,%eax
f01057f4:	e9 b2 00 00 00       	jmp    f01058ab <prefix_name+0x140>
    case 0x49:
      return "rex64Z";
f01057f9:	b8 91 bf 10 f0       	mov    $0xf010bf91,%eax
f01057fe:	e9 a8 00 00 00       	jmp    f01058ab <prefix_name+0x140>
    case 0x4a:
      return "rex64Y";
f0105803:	b8 98 bf 10 f0       	mov    $0xf010bf98,%eax
f0105808:	e9 9e 00 00 00       	jmp    f01058ab <prefix_name+0x140>
    case 0x4b:
      return "rex64YZ";
f010580d:	b8 a0 bf 10 f0       	mov    $0xf010bfa0,%eax
f0105812:	e9 94 00 00 00       	jmp    f01058ab <prefix_name+0x140>
    case 0x4c:
      return "rex64X";
f0105817:	b8 a7 bf 10 f0       	mov    $0xf010bfa7,%eax
f010581c:	e9 8a 00 00 00       	jmp    f01058ab <prefix_name+0x140>
    case 0x4d:
      return "rex64XZ";
f0105821:	b8 af bf 10 f0       	mov    $0xf010bfaf,%eax
f0105826:	e9 80 00 00 00       	jmp    f01058ab <prefix_name+0x140>
    case 0x4e:
      return "rex64XY";
f010582b:	b8 b7 bf 10 f0       	mov    $0xf010bfb7,%eax
f0105830:	eb 79                	jmp    f01058ab <prefix_name+0x140>
    case 0x4f:
      return "rex64XYZ";
f0105832:	b8 c0 bf 10 f0       	mov    $0xf010bfc0,%eax
f0105837:	eb 72                	jmp    f01058ab <prefix_name+0x140>
    case 0xf3:
      return "repz";
f0105839:	b8 c5 bf 10 f0       	mov    $0xf010bfc5,%eax
f010583e:	eb 6b                	jmp    f01058ab <prefix_name+0x140>
    case 0xf2:
      return "repnz";
f0105840:	b8 cb bf 10 f0       	mov    $0xf010bfcb,%eax
f0105845:	eb 64                	jmp    f01058ab <prefix_name+0x140>
    case 0xf0:
      return "lock";
f0105847:	b8 06 c3 10 f0       	mov    $0xf010c306,%eax
f010584c:	eb 5d                	jmp    f01058ab <prefix_name+0x140>
    case 0x2e:
      return "cs";
f010584e:	b8 0a c3 10 f0       	mov    $0xf010c30a,%eax
f0105853:	eb 56                	jmp    f01058ab <prefix_name+0x140>
    case 0x36:
      return "ss";
f0105855:	b8 0e c3 10 f0       	mov    $0xf010c30e,%eax
f010585a:	eb 4f                	jmp    f01058ab <prefix_name+0x140>
    case 0x3e:
      return "ds";
f010585c:	b8 02 c3 10 f0       	mov    $0xf010c302,%eax
f0105861:	eb 48                	jmp    f01058ab <prefix_name+0x140>
    case 0x26:
      return "es";
f0105863:	b8 12 c3 10 f0       	mov    $0xf010c312,%eax
f0105868:	eb 41                	jmp    f01058ab <prefix_name+0x140>
    case 0x64:
      return "fs";
f010586a:	b8 16 c3 10 f0       	mov    $0xf010c316,%eax
f010586f:	eb 3a                	jmp    f01058ab <prefix_name+0x140>
    case 0x65:
      return "gs";
    case 0x66:
      return (sizeflag & DFLAG) ? "data16" : "data32";
f0105871:	b8 d0 bf 10 f0       	mov    $0xf010bfd0,%eax
f0105876:	f6 c2 01             	test   $0x1,%dl
f0105879:	75 30                	jne    f01058ab <prefix_name+0x140>
f010587b:	b8 d7 bf 10 f0       	mov    $0xf010bfd7,%eax
f0105880:	eb 29                	jmp    f01058ab <prefix_name+0x140>
    case 0x67:
      if (mode_64bit)
f0105882:	83 3d 60 91 2a f0 00 	cmpl   $0x0,0xf02a9160
f0105889:	74 11                	je     f010589c <prefix_name+0x131>
        return (sizeflag & AFLAG) ? "addr32" : "addr64";
f010588b:	b8 de bf 10 f0       	mov    $0xf010bfde,%eax
f0105890:	f6 c2 02             	test   $0x2,%dl
f0105893:	75 16                	jne    f01058ab <prefix_name+0x140>
f0105895:	b8 e5 bf 10 f0       	mov    $0xf010bfe5,%eax
f010589a:	eb 0f                	jmp    f01058ab <prefix_name+0x140>
      else
        return ((sizeflag & AFLAG) && !mode_64bit) ? "addr16" : "addr32";
f010589c:	b8 ec bf 10 f0       	mov    $0xf010bfec,%eax
f01058a1:	f6 c2 02             	test   $0x2,%dl
f01058a4:	75 05                	jne    f01058ab <prefix_name+0x140>
f01058a6:	b8 de bf 10 f0       	mov    $0xf010bfde,%eax
    case FWAIT_OPCODE:
      return "fwait";
    default:
      return NULL;
    }
}
f01058ab:	5d                   	pop    %ebp
f01058ac:	c3                   	ret    

f01058ad <get64>:

static char op1out[100], op2out[100], op3out[100];
static int op_ad, op_index[3];
static bfd_vma op_address[3];
static bfd_vma op_riprel[3];
static bfd_vma start_pc;

/*
 *   On the 386's of 1988, the maximum length of an instruction is 15 bytes.
 *   (see topic "Redundant prefixes" in the "Differences from 8086"
 *   section of the "Virtual 8086 Mode" chapter.)
 * 'pc' should be the address of this instruction, it will
 *   be used to print the target address if this is a relative jump or call
 * The function returns the length of this instruction in bytes.
 */

static int8_t intel_syntax;
static char open_char;
static char close_char;
static char separator_char;
static char scale_char;

int
print_insn_i386 (pc, info)
     bfd_vma pc;
     disassemble_info *info;
{
  intel_syntax = -1;
  //cprintf("intel_syntax1=%d\n",intel_syntax);
  return print_insn (pc, info);
}

static int
print_insn (pc, info)
     bfd_vma pc;
     disassemble_info *info;
{
  const struct dis386 *dp;
  int i;
  int two_source_ops;
  char *first, *second, *third;
  int needcomma;
  unsigned char uses_SSE_prefix;
  int sizeflag;
  const char *p;
  struct dis_private priv;

  mode_64bit = (info->mach == bfd_mach_x86_64_intel_syntax
		|| info->mach == bfd_mach_x86_64);

  if (intel_syntax == -1)
    intel_syntax = (info->mach == bfd_mach_i386_i386_intel_syntax
		    || info->mach == bfd_mach_x86_64_intel_syntax);

  if (info->mach == bfd_mach_i386_i386
      || info->mach == bfd_mach_x86_64
      || info->mach == bfd_mach_i386_i386_intel_syntax
      || info->mach == bfd_mach_x86_64_intel_syntax)
    priv.orig_sizeflag = AFLAG | DFLAG;
  else if (info->mach == bfd_mach_i386_i8086)
    priv.orig_sizeflag = 0;
  else
    panic("print_insn:error occured");

  for (p = info->disassembler_options; p != NULL; )
    {
      if (strncmp (p, "x86-64", 6) == 0)
	{
	  mode_64bit = 1;
	  priv.orig_sizeflag = AFLAG | DFLAG;
	}
      else if (strncmp (p, "i386", 4) == 0)
	{
	  mode_64bit = 0;
	  priv.orig_sizeflag = AFLAG | DFLAG;
	}
      else if (strncmp (p, "i8086", 5) == 0)
	{
	  mode_64bit = 0;
	  priv.orig_sizeflag = 0;
	}
      else if (strncmp (p, "intel", 5) == 0)
	{
	  intel_syntax = 1;
	}
      else if (strncmp (p, "att", 3) == 0)
	{
	  intel_syntax = 0;
	}
      else if (strncmp (p, "addr", 4) == 0)
	{
	  if (p[4] == '1' && p[5] == '6')
	    priv.orig_sizeflag &= ~AFLAG;
	  else if (p[4] == '3' && p[5] == '2')
	    priv.orig_sizeflag |= AFLAG;
	}
      else if (strncmp (p, "data", 4) == 0)
	{
	  if (p[4] == '1' && p[5] == '6')
	    priv.orig_sizeflag &= ~DFLAG;
	  else if (p[4] == '3' && p[5] == '2')
	    priv.orig_sizeflag |= DFLAG;
	}
      else if (strncmp (p, "suffix", 6) == 0)
	priv.orig_sizeflag |= SUFFIX_ALWAYS;

      p = strchr (p, ',');
      if (p != NULL)
	p++;
    }

  if (intel_syntax)
    {
      names64 = intel_names64;
      names32 = intel_names32;
      names16 = intel_names16;
      names8 = intel_names8;
      names8rex = intel_names8rex;
      names_seg = intel_names_seg;
      index16 = intel_index16;
      open_char = '[';
      close_char = ']';
      separator_char = '+';
      scale_char = '*';
    }
  else
    {
      names64 = att_names64;
      names32 = att_names32;
      names16 = att_names16;
      names8 = att_names8;
      names8rex = att_names8rex;
      names_seg = att_names_seg;
      index16 = att_index16;
      open_char = '(';
      close_char =  ')';
      separator_char = ',';
      scale_char = ',';
    }
   //cprintf("intel_syntax2=%d\n",intel_syntax);
  /* The output looks better if we put 7 bytes on a line, since that
     puts most long word instructions on a single line.  */
  info->bytes_per_line = 7;
  
  info->private_data = (PTR) &priv;
  priv.max_fetched = priv.the_buffer;
  priv.insn_start = pc;

  obuf[0] = 0;
  op1out[0] = 0;
  op2out[0] = 0;
  op3out[0] = 0;

  op_index[0] = op_index[1] = op_index[2] = -1;

  the_info = info;
 // cprintf("the_info:buffer_length=%d\n",the_info->buffer_length);
  start_pc = pc;
  start_codep = priv.the_buffer;
  codep = priv.the_buffer;

  //if (setjmp (priv.bailout) != 0)
  if(0)
    {
      const char *name;

      /* Getting here means we tried for data but didn't get it.  That
	 means we have an incomplete instruction of some sort.  Just
	 print the first byte as a prefix or a .byte pseudo-op.  */
      if (codep > priv.the_buffer)
	{
	  name = prefix_name (priv.the_buffer[0], priv.orig_sizeflag);
	  if (name != NULL)
	   { /*****************************************/
	    //Add your code here	
	   }
	  else
	    {
	      /* Just print the first byte as a .byte instruction.  */
	      /*****************************************/
              //Add your code here  
	    }

	  return 1;
	}

      return -1;
    }

  obufp = obuf;
  ckprefix ();

  insn_codep = codep;
  sizeflag = priv.orig_sizeflag;

  FETCH_DATA (info, codep + 1);
  //cprintf("***************print_insn:codep1=%x******************\n",*codep);
  two_source_ops = (*codep == 0x62) || (*codep == 0xc8);

  if ((prefixes & PREFIX_FWAIT)
      && ((*codep < 0xd8) || (*codep > 0xdf)))
    {
      const char *name;

      /* fwait not followed by floating point instruction.  Print the
         first prefix, which is probably fwait itself.  */
      name = prefix_name (priv.the_buffer[0], priv.orig_sizeflag);
      if (name == NULL)
	name = INTERNAL_DISASSEMBLER_ERROR;
      /*****************************************/
      //Add your code here,print name
      cprintf("%s",name);
      return 1;
    }

  if (*codep == 0x0f)
    {
      FETCH_DATA (info, codep + 2);
      dp = &dis386_twobyte[*++codep];
      need_modrm = twobyte_has_modrm[*codep];
      uses_SSE_prefix = twobyte_uses_SSE_prefix[*codep];
    }
  else
    {
     // cprintf("**********codep=%x*********\n",*codep);	
      dp = &dis386[*codep];
      need_modrm = onebyte_has_modrm[*codep];
      uses_SSE_prefix = 0;
      //cprintf("codep=%x neda_modrm=%d\n",*codep,need_modrm);
    }
  codep++;

  if (!uses_SSE_prefix && (prefixes & PREFIX_REPZ))
    {
      oappend ("repz ");
      used_prefixes |= PREFIX_REPZ;
    }
  if (!uses_SSE_prefix && (prefixes & PREFIX_REPNZ))
    {
      oappend ("repnz ");
      used_prefixes |= PREFIX_REPNZ;
    }
  if (prefixes & PREFIX_LOCK)
    {
      oappend ("lock ");
      used_prefixes |= PREFIX_LOCK;
    }

  if (prefixes & PREFIX_ADDR)
    {
      sizeflag ^= AFLAG;
      if (dp->bytemode3 != loop_jcxz_mode || intel_syntax)
	{
	  if ((sizeflag & AFLAG) || mode_64bit)
	    oappend ("addr32 ");
	  else
	    oappend ("addr16 ");
	  used_prefixes |= PREFIX_ADDR;
	}
    }

  if (!uses_SSE_prefix && (prefixes & PREFIX_DATA))
    {
      sizeflag ^= DFLAG;
      if (dp->bytemode3 == cond_jump_mode
	  && dp->bytemode1 == v_mode
	  && !intel_syntax)
	{
	  if (sizeflag & DFLAG)
	    oappend ("data32 ");
	  else
	    oappend ("data16 ");
	  used_prefixes |= PREFIX_DATA;
	}
    }

  if (need_modrm)
    {
      FETCH_DATA (info, codep + 1);
      mod = (*codep >> 6) & 3;
      reg = (*codep >> 3) & 7;
      rm = *codep & 7;
      //cprintf("need_modrm:mod=%x reg=%x rm=%x\n",mod,reg,rm);
    }

  if (dp->name == NULL && dp->bytemode1 == FLOATCODE)
    {
      dofloat (sizeflag);
    }
  else
    {
      int index;
      if (dp->name == NULL)
	{
	  switch (dp->bytemode1)
	    {
	    case USE_GROUPS:
	      dp = &grps[dp->bytemode2][reg];
	      break;

	    case USE_PREFIX_USER_TABLE:
	      index = 0;
	      used_prefixes |= (prefixes & PREFIX_REPZ);
	      if (prefixes & PREFIX_REPZ)
		index = 1;
	      else
		{
		  used_prefixes |= (prefixes & PREFIX_DATA);
		  if (prefixes & PREFIX_DATA)
		    index = 2;
		  else
		    {
		      used_prefixes |= (prefixes & PREFIX_REPNZ);
		      if (prefixes & PREFIX_REPNZ)
			index = 3;
		    }
		}
	      dp = &prefix_user_table[dp->bytemode2][index];
	      break;

	    case X86_64_SPECIAL:
	      dp = &x86_64_table[dp->bytemode2][mode_64bit];
	      break;

	    default:
	      oappend (INTERNAL_DISASSEMBLER_ERROR);
	      break;
	    }
	}
      //cprintf("*****op1out=%s*****\n",op1out);
      if (putop (dp->name, sizeflag) == 0)
	{
	  obufp = op1out;
	  op_ad = 2;
	  if (dp->op1)
	    (*dp->op1) (dp->bytemode1, sizeflag);
	  //obufp = op1out;
	  //cprintf("obufp=%c%c%c%c%c\n",obufp[0],obufp[1],obufp[2],obufp[3],obufp[4]);
	//  cprintf("obufp=%s op1out=%s\n",obufp,op1out);
	  obufp = op2out;
	  op_ad = 1;
	  if (dp->op2)
	    (*dp->op2) (dp->bytemode2, sizeflag);

	  obufp = op3out;
	  op_ad = 0;
	  if (dp->op3)
	    (*dp->op3) (dp->bytemode3, sizeflag);
	}
    }
    //cprintf("***op1out=%s******\n",op1out);	
  /* See if any prefixes were not used.  If so, print the first one
     separately.  If we don't do this, we'll wind up printing an
     instruction stream which does not precisely correspond to the
     bytes we are disassembling.  */
  if ((prefixes & ~used_prefixes) != 0)
    {
      const char *name;

      name = prefix_name (priv.the_buffer[0], priv.orig_sizeflag);
      if (name == NULL)
	name = INTERNAL_DISASSEMBLER_ERROR;
      /*****************************************/
      //Add your code here,print name
      cprintf("%s",name);
      return 1;
    }
  if (rex & ~rex_used)
    {
      const char *name;
      name = prefix_name (rex | 0x40, priv.orig_sizeflag);
      if (name == NULL)
	name = INTERNAL_DISASSEMBLER_ERROR;
      /*****************************************/
      //Add your code here,print name
      cprintf("%s",name);
    }

  obufp = obuf + strlen (obuf);
  for (i = strlen (obuf); i < 6; i++)
    oappend (" ");
  oappend (" ");
  /*****************************************/
  //Add your code here,print obuf
  //cprintf("print_insn:operands is here\n");
  cprintf("%s",obuf);
  //cprintf("\nop1out=%s op2out=%s op3out=%s\n",op1out,op2out,op3out);
  /* The enter and bound instructions are printed with operands in the same
     order as the intel book; everything else is printed in reverse order.  */
  if (intel_syntax || two_source_ops)
    {
      first = op1out;
      second = op2out;
      third = op3out;
      op_ad = op_index[0];
      op_index[0] = op_index[2];
      op_index[2] = op_ad;
    }
  else
    {
      first = op3out;
      second = op2out;
      third = op1out;
    }
  needcomma = 0;
  if (*first)
    {
      if (op_index[0] != -1 && !op_riprel[0])
	(*info->print_address_func) ((bfd_vma) op_address[op_index[0]], info);
      else
	{
		/*****************************************/
      		//Add your code here,print first
      		cprintf("%s",first);
	}
      needcomma = 1;
    }
  if (*second)
    {
      if (needcomma)
	{
		/*****************************************/
      		//Add your code here,print ,
      		cprintf("%c",',');

	}
      if (op_index[1] != -1 && !op_riprel[1])
	(*info->print_address_func) ((bfd_vma) op_address[op_index[1]], info);
      else
	{
		/*****************************************/
      		//Add your code here,print second
      		cprintf("%s",second);

	}
      needcomma = 1;
    }
  if (*third)
    {
      if (needcomma)
	{
                /*****************************************/
                //Add your code here,print ,
                cprintf("%c",',');
                
        }
      if (op_index[2] != -1 && !op_riprel[2])
	(*info->print_address_func) ((bfd_vma) op_address[op_index[2]], info);
      else
	{
                /*****************************************/
                //Add your code here,print third
                cprintf("%s",third);
        }
    }
  //panic("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb");
  for (i = 0; i < 3; i++)
    if (op_index[i] != -1 && op_riprel[i])
      {
	/*****************************************/
        //Add your code here,print #
        cprintf("%s","      #");
	(*info->print_address_func) ((bfd_vma) (start_pc + codep - start_codep
						+ op_address[op_index[i]]), info);
      }
  return codep - priv.the_buffer;
}

static const char *float_mem[] = {
  /* d8 */
  "fadd{s||s|}",
  "fmul{s||s|}",
  "fcom{s||s|}",
  "fcomp{s||s|}",
  "fsub{s||s|}",
  "fsubr{s||s|}",
  "fdiv{s||s|}",
  "fdivr{s||s|}",
  /*  d9 */
  "fld{s||s|}",
  "(bad)",
  "fst{s||s|}",
  "fstp{s||s|}",
  "fldenv",
  "fldcw",
  "fNstenv",
  "fNstcw",
  /* da */
  "fiadd{l||l|}",
  "fimul{l||l|}",
  "ficom{l||l|}",
  "ficomp{l||l|}",
  "fisub{l||l|}",
  "fisubr{l||l|}",
  "fidiv{l||l|}",
  "fidivr{l||l|}",
  /* db */
  "fild{l||l|}",
  "(bad)",
  "fist{l||l|}",
  "fistp{l||l|}",
  "(bad)",
  "fld{t||t|}",
  "(bad)",
  "fstp{t||t|}",
  /* dc */
  "fadd{l||l|}",
  "fmul{l||l|}",
  "fcom{l||l|}",
  "fcomp{l||l|}",
  "fsub{l||l|}",
  "fsubr{l||l|}",
  "fdiv{l||l|}",
  "fdivr{l||l|}",
  /* dd */
  "fld{l||l|}",
  "(bad)",
  "fst{l||l|}",
  "fstp{l||l|}",
  "frstor",
  "(bad)",
  "fNsave",
  "fNstsw",
  /* de */
  "fiadd",
  "fimul",
  "ficom",
  "ficomp",
  "fisub",
  "fisubr",
  "fidiv",
  "fidivr",
  /* df */
  "fild",
  "(bad)",
  "fist",
  "fistp",
  "fbld",
  "fild{ll||ll|}",
  "fbstp",
  "fistpll",
};

#define ST OP_ST, 0
#define STi OP_STi, 0

#define FGRPd9_2 NULL, NULL, 0, NULL, 0, NULL, 0
#define FGRPd9_4 NULL, NULL, 1, NULL, 0, NULL, 0
#define FGRPd9_5 NULL, NULL, 2, NULL, 0, NULL, 0
#define FGRPd9_6 NULL, NULL, 3, NULL, 0, NULL, 0
#define FGRPd9_7 NULL, NULL, 4, NULL, 0, NULL, 0
#define FGRPda_5 NULL, NULL, 5, NULL, 0, NULL, 0
#define FGRPdb_4 NULL, NULL, 6, NULL, 0, NULL, 0
#define FGRPde_3 NULL, NULL, 7, NULL, 0, NULL, 0
#define FGRPdf_4 NULL, NULL, 8, NULL, 0, NULL, 0

static const struct dis386 float_reg[][8] = {
  /* d8 */
  {
    { "fadd",	ST, STi, XX },
    { "fmul",	ST, STi, XX },
    { "fcom",	STi, XX, XX },
    { "fcomp",	STi, XX, XX },
    { "fsub",	ST, STi, XX },
    { "fsubr",	ST, STi, XX },
    { "fdiv",	ST, STi, XX },
    { "fdivr",	ST, STi, XX },
  },
  /* d9 */
  {
    { "fld",	STi, XX, XX },
    { "fxch",	STi, XX, XX },
    { FGRPd9_2 },
    { "(bad)",	XX, XX, XX },
    { FGRPd9_4 },
    { FGRPd9_5 },
    { FGRPd9_6 },
    { FGRPd9_7 },
  },
  /* da */
  {
    { "fcmovb",	ST, STi, XX },
    { "fcmove",	ST, STi, XX },
    { "fcmovbe",ST, STi, XX },
    { "fcmovu",	ST, STi, XX },
    { "(bad)",	XX, XX, XX },
    { FGRPda_5 },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
  },
  /* db */
  {
    { "fcmovnb",ST, STi, XX },
    { "fcmovne",ST, STi, XX },
    { "fcmovnbe",ST, STi, XX },
    { "fcmovnu",ST, STi, XX },
    { FGRPdb_4 },
    { "fucomi",	ST, STi, XX },
    { "fcomi",	ST, STi, XX },
    { "(bad)",	XX, XX, XX },
  },
  /* dc */
  {
    { "fadd",	STi, ST, XX },
    { "fmul",	STi, ST, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
#if UNIXWARE_COMPAT
    { "fsub",	STi, ST, XX },
    { "fsubr",	STi, ST, XX },
    { "fdiv",	STi, ST, XX },
    { "fdivr",	STi, ST, XX },
#else
    { "fsubr",	STi, ST, XX },
    { "fsub",	STi, ST, XX },
    { "fdivr",	STi, ST, XX },
    { "fdiv",	STi, ST, XX },
#endif
  },
  /* dd */
  {
    { "ffree",	STi, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "fst",	STi, XX, XX },
    { "fstp",	STi, XX, XX },
    { "fucom",	STi, XX, XX },
    { "fucomp",	STi, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
  },
  /* de */
  {
    { "faddp",	STi, ST, XX },
    { "fmulp",	STi, ST, XX },
    { "(bad)",	XX, XX, XX },
    { FGRPde_3 },
#if UNIXWARE_COMPAT
    { "fsubp",	STi, ST, XX },
    { "fsubrp",	STi, ST, XX },
    { "fdivp",	STi, ST, XX },
    { "fdivrp",	STi, ST, XX },
#else
    { "fsubrp",	STi, ST, XX },
    { "fsubp",	STi, ST, XX },
    { "fdivrp",	STi, ST, XX },
    { "fdivp",	STi, ST, XX },
#endif
  },
  /* df */
  {
    { "ffreep",	STi, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
    { "(bad)",	XX, XX, XX },
    { FGRPdf_4 },
    { "fucomip",ST, STi, XX },
    { "fcomip", ST, STi, XX },
    { "(bad)",	XX, XX, XX },
  },
};

static const char *fgrps[][8] = {
  /* d9_2  0 */
  {
    "fnop","(bad)","(bad)","(bad)","(bad)","(bad)","(bad)","(bad)",
  },

  /* d9_4  1 */
  {
    "fchs","fabs","(bad)","(bad)","ftst","fxam","(bad)","(bad)",
  },

  /* d9_5  2 */
  {
    "fld1","fldl2t","fldl2e","fldpi","fldlg2","fldln2","fldz","(bad)",
  },

  /* d9_6  3 */
  {
    "f2xm1","fyl2x","fptan","fpatan","fxtract","fprem1","fdecstp","fincstp",
  },

  /* d9_7  4 */
  {
    "fprem","fyl2xp1","fsqrt","fsincos","frndint","fscale","fsin","fcos",
  },

  /* da_5  5 */
  {
    "(bad)","fucompp","(bad)","(bad)","(bad)","(bad)","(bad)","(bad)",
  },

  /* db_4  6 */
  {
    "feni(287 only)","fdisi(287 only)","fNclex","fNinit",
    "fNsetpm(287 only)","(bad)","(bad)","(bad)",
  },

  /* de_3  7 */
  {
    "(bad)","fcompp","(bad)","(bad)","(bad)","(bad)","(bad)","(bad)",
  },

  /* df_4  8 */
  {
    "fNstsw","(bad)","(bad)","(bad)","(bad)","(bad)","(bad)","(bad)",
  },
};

static void
dofloat (sizeflag)
     int sizeflag;
{
  const struct dis386 *dp;
  unsigned char floatop;

  floatop = codep[-1];

  if (mod != 3)
    {
      putop (float_mem[(floatop - 0xd8) * 8 + reg], sizeflag);
      obufp = op1out;
      if (floatop == 0xdb)
        OP_E (x_mode, sizeflag);
      else if (floatop == 0xdd)
        OP_E (d_mode, sizeflag);
      else
        OP_E (v_mode, sizeflag);
      return;
    }
  /* Skip mod/rm byte.  */
  MODRM_CHECK;
  codep++;
  dp = &float_reg[floatop - 0xd8][reg];
  if (dp->name == NULL)
    {
      putop (fgrps[dp->bytemode1][rm], sizeflag);

      /* Instruction fnstsw is only one with strange arg.  */
      if (floatop == 0xdf && codep[-1] == 0xe0)
	{
        	pstrcpy (op1out, sizeof(op1out), names16[0]);
        	//add your code here
        }
    }
  else
    {
      putop (dp->name, sizeflag);

      obufp = op1out;
      if (dp->op1)
	(*dp->op1) (dp->bytemode1, sizeflag);
      obufp = op2out;
      if (dp->op2)
	(*dp->op2) (dp->bytemode2, sizeflag);
    }
}

static void
OP_ST (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
  oappend ("%st");
}

static void
OP_STi (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
  snprintf (scratchbuf, sizeof(scratchbuf), "%%st(%d)", rm);
  oappend (scratchbuf + intel_syntax);
}

/* Capital letters in template are macros.  */
static int
putop (template, sizeflag)
     const char *template;
     int sizeflag;
{
  const char *p;
  int alt;

  for (p = template; *p; p++)
    {
      switch (*p)
	{
	default:
	  *obufp++ = *p;
	  break;
	case '{':
	  alt = 0;
	  if (intel_syntax)
	    alt += 1;
	  if (mode_64bit)
	    alt += 2;
	  while (alt != 0)
	    {
	      while (*++p != '|')
		{
		  if (*p == '}')
		    {
		      /* Alternative not valid.  */
                      //pstrcpy (obuf, sizeof(obuf), "(bad)");
                      //add your code here
                      
		      obufp = obuf + 5;
		      return 1;
		    }
		  else if (*p == '\0')
		    //abort ();
		    panic("putop:erron occured");
		}
	      alt--;
	    }
	  break;
	case '|':
	  while (*++p != '}')
	    {
	      if (*p == '\0')
		//abort ();
		panic("putop:erron occured");
	    }
	  break;
	case '}':
	  break;
	case 'A':
          if (intel_syntax)
            break;
	  if (mod != 3 || (sizeflag & SUFFIX_ALWAYS))
	    *obufp++ = 'b';
	  break;
	case 'B':
          if (intel_syntax)
            break;
	  if (sizeflag & SUFFIX_ALWAYS)
	    *obufp++ = 'b';
	  break;
	case 'E':		/* For jcxz/jecxz */
	  if (mode_64bit)
	    {
	      if (sizeflag & AFLAG)
		*obufp++ = 'r';
	      else
		*obufp++ = 'e';
	    }
	  else
	    if (sizeflag & AFLAG)
	      *obufp++ = 'e';
	  used_prefixes |= (prefixes & PREFIX_ADDR);
	  break;
	case 'F':
          if (intel_syntax)
            break;
	  if ((prefixes & PREFIX_ADDR) || (sizeflag & SUFFIX_ALWAYS))
	    {
	      if (sizeflag & AFLAG)
		*obufp++ = mode_64bit ? 'q' : 'l';
	      else
		*obufp++ = mode_64bit ? 'l' : 'w';
	      used_prefixes |= (prefixes & PREFIX_ADDR);
	    }
	  break;
	case 'H':
          if (intel_syntax)
            break;
	  if ((prefixes & (PREFIX_CS | PREFIX_DS)) == PREFIX_CS
	      || (prefixes & (PREFIX_CS | PREFIX_DS)) == PREFIX_DS)
	    {
	      used_prefixes |= prefixes & (PREFIX_CS | PREFIX_DS);
	      *obufp++ = ',';
	      *obufp++ = 'p';
	      if (prefixes & PREFIX_DS)
		*obufp++ = 't';
	      else
		*obufp++ = 'n';
	    }
	  break;
	case 'L':
          if (intel_syntax)
            break;
	  if (sizeflag & SUFFIX_ALWAYS)
	    *obufp++ = 'l';
	  break;
	case 'N':
	  if ((prefixes & PREFIX_FWAIT) == 0)
	    *obufp++ = 'n';
	  else
	    used_prefixes |= PREFIX_FWAIT;
	  break;
	case 'O':
	  USED_REX (REX_MODE64);
	  if (rex & REX_MODE64)
	    *obufp++ = 'o';
	  else
	    *obufp++ = 'd';
	  break;
	case 'T':
          if (intel_syntax)
            break;
	  if (mode_64bit)
	    {
	      *obufp++ = 'q';
	      break;
	    }
	  /* Fall through.  */
	case 'P':
          if (intel_syntax)
            break;
	  if ((prefixes & PREFIX_DATA)
	      || (rex & REX_MODE64)
	      || (sizeflag & SUFFIX_ALWAYS))
	    {
	      USED_REX (REX_MODE64);
	      if (rex & REX_MODE64)
		*obufp++ = 'q';
	      else
		{
		   if (sizeflag & DFLAG)
		      *obufp++ = 'l';
		   else
		     *obufp++ = 'w';
		   used_prefixes |= (prefixes & PREFIX_DATA);
		}
	    }
	  break;
	case 'U':
          if (intel_syntax)
            break;
	  if (mode_64bit)
	    {
	      *obufp++ = 'q';
	      break;
	    }
	  /* Fall through.  */
	case 'Q':
          if (intel_syntax)
            break;
	  USED_REX (REX_MODE64);
	  if (mod != 3 || (sizeflag & SUFFIX_ALWAYS))
	    {
	      if (rex & REX_MODE64)
		*obufp++ = 'q';
	      else
		{
		  if (sizeflag & DFLAG)
		    *obufp++ = 'l';
		  else
		    *obufp++ = 'w';
		  used_prefixes |= (prefixes & PREFIX_DATA);
		}
	    }
	  break;
	case 'R':
	  USED_REX (REX_MODE64);
          if (intel_syntax)
	    {
	      if (rex & REX_MODE64)
		{
		  *obufp++ = 'q';
		  *obufp++ = 't';
		}
	      else if (sizeflag & DFLAG)
		{
		  *obufp++ = 'd';
		  *obufp++ = 'q';
		}
	      else
		{
		  *obufp++ = 'w';
		  *obufp++ = 'd';
		}
	    }
	  else
	    {
	      if (rex & REX_MODE64)
		*obufp++ = 'q';
	      else if (sizeflag & DFLAG)
		*obufp++ = 'l';
	      else
		*obufp++ = 'w';
	    }
	  if (!(rex & REX_MODE64))
	    used_prefixes |= (prefixes & PREFIX_DATA);
	  break;
	case 'S':
          if (intel_syntax)
            break;
	  if (sizeflag & SUFFIX_ALWAYS)
	    {
	      if (rex & REX_MODE64)
		*obufp++ = 'q';
	      else
		{
		  if (sizeflag & DFLAG)
		    *obufp++ = 'l';
		  else
		    *obufp++ = 'w';
		  used_prefixes |= (prefixes & PREFIX_DATA);
		}
	    }
	  break;
	case 'X':
	  if (prefixes & PREFIX_DATA)
	    *obufp++ = 'd';
	  else
	    *obufp++ = 's';
          used_prefixes |= (prefixes & PREFIX_DATA);
	  break;
	case 'Y':
          if (intel_syntax)
            break;
	  if (rex & REX_MODE64)
	    {
	      USED_REX (REX_MODE64);
	      *obufp++ = 'q';
	    }
	  break;
	  /* implicit operand size 'l' for i386 or 'q' for x86-64 */
	case 'W':
	  /* operand size flag for cwtl, cbtw */
	  USED_REX (0);
	  if (rex)
	    *obufp++ = 'l';
	  else if (sizeflag & DFLAG)
	    *obufp++ = 'w';
	  else
	    *obufp++ = 'b';
          if (intel_syntax)
	    {
	      if (rex)
		{
		  *obufp++ = 'q';
		  *obufp++ = 'e';
		}
	      if (sizeflag & DFLAG)
		{
		  *obufp++ = 'd';
		  *obufp++ = 'e';
		}
	      else
		{
		  *obufp++ = 'w';
		}
	    }
	  if (!rex)
	    used_prefixes |= (prefixes & PREFIX_DATA);
	  break;
	}
    }
  *obufp = 0;
  return 0;
}

static void
oappend (s)
     const char *s;
{
  strcpy (obufp, s);
  obufp += strlen (s);
}

static void
append_seg ()
{
  if (prefixes & PREFIX_CS)
    {
      used_prefixes |= PREFIX_CS;
      oappend ("%cs:" + intel_syntax);
    }
  if (prefixes & PREFIX_DS)
    {
      used_prefixes |= PREFIX_DS;
      oappend ("%ds:" + intel_syntax);
    }
  if (prefixes & PREFIX_SS)
    {
      used_prefixes |= PREFIX_SS;
      oappend ("%ss:" + intel_syntax);
    }
  if (prefixes & PREFIX_ES)
    {
      used_prefixes |= PREFIX_ES;
      oappend ("%es:" + intel_syntax);
    }
  if (prefixes & PREFIX_FS)
    {
      used_prefixes |= PREFIX_FS;
      oappend ("%fs:" + intel_syntax);
    }
  if (prefixes & PREFIX_GS)
    {
      used_prefixes |= PREFIX_GS;
      oappend ("%gs:" + intel_syntax);
    }
}

static void
OP_indirE (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
  if (!intel_syntax)
    oappend ("*");
  OP_E (bytemode, sizeflag);
}

static void
print_operand_value (char *buf, size_t bufsize, int hex, bfd_vma disp)
{
  if (mode_64bit)
    {
      if (hex)
	{
	  char tmp[30];
	  int i;
	  buf[0] = '0';
	  buf[1] = 'x';
          snprintf_vma (tmp, sizeof(tmp), disp);
          //add your code here
	  for (i = 0; tmp[i] == '0' && tmp[i + 1]; i++);
          pstrcpy (buf + 2, bufsize - 2, tmp + i);
          //add your code here
	}
      else
	{
	  bfd_signed_vma v = disp;
	  char tmp[30];
	  int i;
	  if (v < 0)
	    {
	      *(buf++) = '-';
	      v = -disp;
	      /* Check for possible overflow on 0x8000000000000000.  */
	      if (v < 0)
		{
                  pstrcpy (buf, bufsize, "9223372036854775808");
                  //add your code here
		  return;
		}
	    }
	  if (!v)
	    {
                pstrcpy (buf, bufsize, "0");
                //add your code here
	      return;
	    }

	  i = 0;
	  tmp[29] = 0;
	  while (v)
	    {
	      tmp[28 - i] = (v % 10) + '0';
	      v /= 10;
	      i++;
	    }
          pstrcpy (buf, bufsize, tmp + 29 - i);
          //add your code here
	}
    }
  else
    {
      if (hex)
        snprintf (buf, bufsize, "0x%x", (unsigned int) disp);
      else
        snprintf (buf, bufsize, "%d", (int) disp);
    }
}

static void
OP_E (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
  bfd_vma disp;
  int add = 0;
  int riprel = 0;
  USED_REX (REX_EXTZ);
  if (rex & REX_EXTZ)
    add += 8;

  /* Skip mod/rm byte.  */
  MODRM_CHECK;
  codep++;

  if (mod == 3)
    {
      switch (bytemode)
	{
	case b_mode:
	  USED_REX (0);
	  if (rex)
	    oappend (names8rex[rm + add]);
	  else
	    oappend (names8[rm + add]);
	  break;
	case w_mode:
	  oappend (names16[rm + add]);
	  break;
	case d_mode:
	  oappend (names32[rm + add]);
	  break;
	case q_mode:
	  oappend (names64[rm + add]);
	  break;
	case m_mode:
	  if (mode_64bit)
	    oappend (names64[rm + add]);
	  else
	    oappend (names32[rm + add]);
	  break;
	case v_mode:
	  USED_REX (REX_MODE64);
	  if (rex & REX_MODE64)
	    oappend (names64[rm + add]);
	  else if (sizeflag & DFLAG)
	    oappend (names32[rm + add]);
	  else
	    oappend (names16[rm + add]);
	  used_prefixes |= (prefixes & PREFIX_DATA);
	  break;
	case 0:
	  if (!(codep[-2] == 0xAE && codep[-1] == 0xF8 /* sfence */)
	      && !(codep[-2] == 0xAE && codep[-1] == 0xF0 /* mfence */)
	      && !(codep[-2] == 0xAE && codep[-1] == 0xe8 /* lfence */))
	    BadOp ();	/* bad sfence,lea,lds,les,lfs,lgs,lss modrm */
	  break;
	default:
	  oappend (INTERNAL_DISASSEMBLER_ERROR);
	  break;
	}
      return;
    }

  disp = 0;
  append_seg ();
  //cprintf("append_seg:obufp=%s op1out=%s\n",obufp,op1out);
  if ((sizeflag & AFLAG) || mode_64bit) /* 32 bit address mode */
    {
      int havesib;
      int havebase;
      int base;
      int index = 0;
      int scale = 0;

      havesib = 0;
      havebase = 1;
      base = rm;
      //cprintf("base=%d\n",base);
     // panic("*****************");
      if (base == 4)
	{
	  havesib = 1;
	  FETCH_DATA (the_info, codep + 1);
	  scale = (*codep >> 6) & 3;
	  index = (*codep >> 3) & 7;
	  base = *codep & 7;
	  USED_REX (REX_EXTY);
	  USED_REX (REX_EXTZ);
	  //cprintf("esp_insn1:codep=%x scale=%d index=%d\n",*codep,scale,index);
	  //panic("*****************");
	  if (rex & REX_EXTY)
	    index += 8;
	  if (rex & REX_EXTZ)
	    base += 8;
	  //cprintf("esp_insn2:codep=%x scale=%d index=%d mod=%x base=%x\n",*codep,scale,index,mod,base);
	  codep++;
	  
	}

      switch (mod)
	{
	case 0:
	  if ((base & 7) == 5)
	    {
	      havebase = 0;
	      if (mode_64bit && !havesib && (sizeflag & AFLAG))
		riprel = 1;
	      disp = get32s ();
	    }
	  break;
	case 1:
	  FETCH_DATA (the_info, codep + 1);
	  disp = *codep++;
	  if ((disp & 0x80) != 0)
	    disp -= 0x100;
	  break;
	case 2:
	  disp = get32s ();
	  break;
	}
      //cprintf("intel_syntax=%d\n",intel_syntax);
      if (!intel_syntax)
        if (mod != 0 || (base & 7) == 5)
          {
            print_operand_value (scratchbuf, sizeof(scratchbuf), !riprel, disp);
            oappend (scratchbuf);
	    if (riprel)
	      {
		set_op (disp, 1);
		oappend ("(%rip)");
	      }
          }
      //cprintf("havebase=%d havesib=%d\n",havebase,havesib);
      if (havebase || (havesib && (index != 4 || scale != 0)))
	{
          if (intel_syntax)
            {
              switch (bytemode)
                {
                case b_mode:
                  oappend ("BYTE PTR ");
                  break;
                case w_mode:
                  oappend ("WORD PTR ");
                  break;
                case v_mode:
                  oappend ("DWORD PTR ");
                  break;
                case d_mode:
                  oappend ("QWORD PTR ");
                  break;
                case m_mode:
		  if (mode_64bit)
		    oappend ("DWORD PTR ");
		  else
		    oappend ("QWORD PTR ");
		  break;
                case x_mode:
                  oappend ("XWORD PTR ");
                  break;
                default:
                  break;
                }
             }
         // cprintf("aaaaaaaaaaaaaaa\n");
	  *obufp++ = open_char;
	  if (intel_syntax && riprel)
	    oappend ("rip + ");
          *obufp = '\0';
	  USED_REX (REX_EXTZ);
	  if (!havesib && (rex & REX_EXTZ))
	    base += 8;
	  if (havebase)
	    oappend (mode_64bit && (sizeflag & AFLAG)
		     ? names64[base] : names32[base]);
	  if (havesib)
	    {
	      if (index != 4)
		{
                  if (intel_syntax)
                    {
                      if (havebase)
                        {
                          *obufp++ = separator_char;
                          *obufp = '\0';
                        }
                      snprintf (scratchbuf, sizeof(scratchbuf), "%s",
                                mode_64bit && (sizeflag & AFLAG)
                                ? names64[index] : names32[index]);
                    }
                  else
                      snprintf (scratchbuf, sizeof(scratchbuf), ",%s",
                                mode_64bit && (sizeflag & AFLAG)
                                ? names64[index] : names32[index]);
		  oappend (scratchbuf);
		}
              if (!intel_syntax
                  || (intel_syntax
                      && bytemode != b_mode
                      && bytemode != w_mode
                      && bytemode != v_mode))
                {
                  if(scale){
                       *obufp++ = scale_char;
                       *obufp = '\0';
                       snprintf (scratchbuf, sizeof(scratchbuf), "%d", 1 << scale);
	               oappend (scratchbuf);
		  }
                }
		//cprintf("obufp=%s op1out=%s scale=%d scale1=%d\n",obufp,op1out,1<<scale,scale);
	    }
	  //cprintf("bbbbbbbbbbbbbbbbbbbbbbbb\n");
          if (intel_syntax)
            if (mod != 0 || (base & 7) == 5)
              {
		/* Don't print zero displacements.  */
                if (disp != 0)
                  {
		    if ((bfd_signed_vma) disp > 0)
		      {
			*obufp++ = '+';
			*obufp = '\0';
		      }

                    print_operand_value (scratchbuf, sizeof(scratchbuf), 0,
                                         disp);
                    oappend (scratchbuf);
                  }
              }

	  *obufp++ = close_char;
          *obufp = '\0';	
	}
      else if (intel_syntax)
        {
          if (mod != 0 || (base & 7) == 5)
            {
	      if (prefixes & (PREFIX_CS | PREFIX_SS | PREFIX_DS
			      | PREFIX_ES | PREFIX_FS | PREFIX_GS))
		;
	      else
		{
		  oappend (names_seg[ds_reg - es_reg]);
		  oappend (":");
		}
              print_operand_value (scratchbuf, sizeof(scratchbuf), 1, disp);
              oappend (scratchbuf);
            }
        }
	//cprintf("obufp=%s op1out=%s\n",obufp,op1out);
    	//panic("**************");
    }
  else
    { /* 16 bit address mode */
      switch (mod)
	{
	case 0:
	  if ((rm & 7) == 6)
	    {
	      disp = get16 ();
	      if ((disp & 0x8000) != 0)
		disp -= 0x10000;
	    }
	  break;
	case 1:
	  FETCH_DATA (the_info, codep + 1);
	  disp = *codep++;
	  if ((disp & 0x80) != 0)
	    disp -= 0x100;
	  break;
	case 2:
	  disp = get16 ();
	  if ((disp & 0x8000) != 0)
	    disp -= 0x10000;
	  break;
	}

      if (!intel_syntax)
        if (mod != 0 || (rm & 7) == 6)
          {
            print_operand_value (scratchbuf, sizeof(scratchbuf), 0, disp);
            oappend (scratchbuf);
          }

      if (mod != 0 || (rm & 7) != 6)
	{
	  *obufp++ = open_char;
          *obufp = '\0';
	  oappend (index16[rm + add]);
          *obufp++ = close_char;
          *obufp = '\0';
	}

    }
    //cprintf("3269:obufp=%s op1out=%s\n",obufp,op1out);
    //panic("**************");
}

static void
OP_G (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
  int add = 0;
  USED_REX (REX_EXTX);
  if (rex & REX_EXTX)
    add += 8;
  switch (bytemode)
    {
    case b_mode:
      USED_REX (0);
      if (rex)
	oappend (names8rex[reg + add]);
      else
	oappend (names8[reg + add]);
      break;
    case w_mode:
      oappend (names16[reg + add]);
      break;
    case d_mode:
      oappend (names32[reg + add]);
      break;
    case q_mode:
      oappend (names64[reg + add]);
      break;
    case v_mode:
      USED_REX (REX_MODE64);
      if (rex & REX_MODE64)
	oappend (names64[reg + add]);
      else if (sizeflag & DFLAG)
	oappend (names32[reg + add]);
      else
	oappend (names16[reg + add]);
      used_prefixes |= (prefixes & PREFIX_DATA);
      break;
    default:
      oappend (INTERNAL_DISASSEMBLER_ERROR);
      break;
    }
}

static bfd_vma
get64 ()
{
f01058ad:	55                   	push   %ebp
f01058ae:	89 e5                	mov    %esp,%ebp
f01058b0:	83 ec 18             	sub    $0x18,%esp
f01058b3:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
f01058b6:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
f01058b9:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  bfd_vma x;
#ifdef BFD64
  unsigned int a;
  unsigned int b;

  FETCH_DATA (the_info, codep + 8);
f01058bc:	8b 15 6c 92 2a f0    	mov    0xf02a926c,%edx
f01058c2:	83 c2 08             	add    $0x8,%edx
f01058c5:	8b 0d 70 92 2a f0    	mov    0xf02a9270,%ecx
f01058cb:	8b 41 20             	mov    0x20(%ecx),%eax
f01058ce:	3b 10                	cmp    (%eax),%edx
f01058d0:	76 07                	jbe    f01058d9 <get64+0x2c>
f01058d2:	89 c8                	mov    %ecx,%eax
f01058d4:	e8 07 fe ff ff       	call   f01056e0 <fetch_data>
  a = *codep++ & 0xff;
f01058d9:	8b 3d 6c 92 2a f0    	mov    0xf02a926c,%edi
f01058df:	0f b6 07             	movzbl (%edi),%eax
  a |= (*codep++ & 0xff) << 8;
f01058e2:	0f b6 5f 01          	movzbl 0x1(%edi),%ebx
f01058e6:	c1 e3 08             	shl    $0x8,%ebx
f01058e9:	09 c3                	or     %eax,%ebx
  a |= (*codep++ & 0xff) << 16;
f01058eb:	0f b6 47 02          	movzbl 0x2(%edi),%eax
f01058ef:	c1 e0 10             	shl    $0x10,%eax
f01058f2:	09 c3                	or     %eax,%ebx
  a |= (*codep++ & 0xff) << 24;
f01058f4:	0f b6 47 03          	movzbl 0x3(%edi),%eax
f01058f8:	c1 e0 18             	shl    $0x18,%eax
f01058fb:	09 c3                	or     %eax,%ebx
  b = *codep++ & 0xff;
f01058fd:	0f b6 4f 04          	movzbl 0x4(%edi),%ecx
  b |= (*codep++ & 0xff) << 8;
f0105901:	0f b6 47 05          	movzbl 0x5(%edi),%eax
f0105905:	c1 e0 08             	shl    $0x8,%eax
f0105908:	09 c8                	or     %ecx,%eax
  b |= (*codep++ & 0xff) << 16;
f010590a:	0f b6 4f 06          	movzbl 0x6(%edi),%ecx
f010590e:	c1 e1 10             	shl    $0x10,%ecx
f0105911:	09 c8                	or     %ecx,%eax
  b |= (*codep++ & 0xff) << 24;
f0105913:	0f b6 4f 07          	movzbl 0x7(%edi),%ecx
f0105917:	c1 e1 18             	shl    $0x18,%ecx
f010591a:	09 c8                	or     %ecx,%eax
f010591c:	83 c7 08             	add    $0x8,%edi
f010591f:	89 3d 6c 92 2a f0    	mov    %edi,0xf02a926c
f0105925:	89 c2                	mov    %eax,%edx
f0105927:	b8 00 00 00 00       	mov    $0x0,%eax
f010592c:	be 00 00 00 00       	mov    $0x0,%esi
f0105931:	01 d8                	add    %ebx,%eax
f0105933:	11 f2                	adc    %esi,%edx
  x = a + ((bfd_vma) b << 32);
#else
  abort ();
   panic("get64:erron occured");
  x = 0;
#endif
  return x;
}
f0105935:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
f0105938:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
f010593b:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
f010593e:	89 ec                	mov    %ebp,%esp
f0105940:	5d                   	pop    %ebp
f0105941:	c3                   	ret    

f0105942 <get32>:

static bfd_signed_vma
get32 ()
{
f0105942:	55                   	push   %ebp
f0105943:	89 e5                	mov    %esp,%ebp
f0105945:	56                   	push   %esi
f0105946:	53                   	push   %ebx
  bfd_signed_vma x = 0;

  FETCH_DATA (the_info, codep + 4);
f0105947:	8b 15 6c 92 2a f0    	mov    0xf02a926c,%edx
f010594d:	83 c2 04             	add    $0x4,%edx
f0105950:	8b 0d 70 92 2a f0    	mov    0xf02a9270,%ecx
f0105956:	8b 41 20             	mov    0x20(%ecx),%eax
f0105959:	3b 10                	cmp    (%eax),%edx
f010595b:	76 07                	jbe    f0105964 <get32+0x22>
f010595d:	89 c8                	mov    %ecx,%eax
f010595f:	e8 7c fd ff ff       	call   f01056e0 <fetch_data>
  x = *codep++ & (bfd_signed_vma) 0xff;
f0105964:	8b 35 6c 92 2a f0    	mov    0xf02a926c,%esi
f010596a:	0f b6 0e             	movzbl (%esi),%ecx
f010596d:	bb 00 00 00 00       	mov    $0x0,%ebx
  x |= (*codep++ & (bfd_signed_vma) 0xff) << 8;
f0105972:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0105976:	ba 00 00 00 00       	mov    $0x0,%edx
f010597b:	0f a4 c2 08          	shld   $0x8,%eax,%edx
f010597f:	c1 e0 08             	shl    $0x8,%eax
f0105982:	09 c8                	or     %ecx,%eax
f0105984:	09 da                	or     %ebx,%edx
  x |= (*codep++ & (bfd_signed_vma) 0xff) << 16;
f0105986:	0f b6 4e 02          	movzbl 0x2(%esi),%ecx
f010598a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010598f:	0f a4 cb 10          	shld   $0x10,%ecx,%ebx
f0105993:	c1 e1 10             	shl    $0x10,%ecx
f0105996:	09 c8                	or     %ecx,%eax
f0105998:	09 da                	or     %ebx,%edx
  x |= (*codep++ & (bfd_signed_vma) 0xff) << 24;
f010599a:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
f010599e:	bb 00 00 00 00       	mov    $0x0,%ebx
f01059a3:	0f a4 cb 18          	shld   $0x18,%ecx,%ebx
f01059a7:	c1 e1 18             	shl    $0x18,%ecx
f01059aa:	09 c8                	or     %ecx,%eax
f01059ac:	09 da                	or     %ebx,%edx
f01059ae:	83 c6 04             	add    $0x4,%esi
f01059b1:	89 35 6c 92 2a f0    	mov    %esi,0xf02a926c
  return x;
}
f01059b7:	5b                   	pop    %ebx
f01059b8:	5e                   	pop    %esi
f01059b9:	5d                   	pop    %ebp
f01059ba:	c3                   	ret    

f01059bb <get32s>:

static bfd_signed_vma
get32s ()
{
f01059bb:	55                   	push   %ebp
f01059bc:	89 e5                	mov    %esp,%ebp
f01059be:	56                   	push   %esi
f01059bf:	53                   	push   %ebx
  bfd_signed_vma x = 0;

  FETCH_DATA (the_info, codep + 4);
f01059c0:	8b 15 6c 92 2a f0    	mov    0xf02a926c,%edx
f01059c6:	83 c2 04             	add    $0x4,%edx
f01059c9:	8b 0d 70 92 2a f0    	mov    0xf02a9270,%ecx
f01059cf:	8b 41 20             	mov    0x20(%ecx),%eax
f01059d2:	3b 10                	cmp    (%eax),%edx
f01059d4:	76 07                	jbe    f01059dd <get32s+0x22>
f01059d6:	89 c8                	mov    %ecx,%eax
f01059d8:	e8 03 fd ff ff       	call   f01056e0 <fetch_data>
  x = *codep++ & (bfd_signed_vma) 0xff;
f01059dd:	8b 35 6c 92 2a f0    	mov    0xf02a926c,%esi
f01059e3:	0f b6 0e             	movzbl (%esi),%ecx
f01059e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  x |= (*codep++ & (bfd_signed_vma) 0xff) << 8;
f01059eb:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f01059ef:	ba 00 00 00 00       	mov    $0x0,%edx
f01059f4:	0f a4 c2 08          	shld   $0x8,%eax,%edx
f01059f8:	c1 e0 08             	shl    $0x8,%eax
f01059fb:	09 c8                	or     %ecx,%eax
f01059fd:	09 da                	or     %ebx,%edx
  x |= (*codep++ & (bfd_signed_vma) 0xff) << 16;
f01059ff:	0f b6 4e 02          	movzbl 0x2(%esi),%ecx
f0105a03:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105a08:	0f a4 cb 10          	shld   $0x10,%ecx,%ebx
f0105a0c:	c1 e1 10             	shl    $0x10,%ecx
f0105a0f:	09 c8                	or     %ecx,%eax
f0105a11:	09 da                	or     %ebx,%edx
  x |= (*codep++ & (bfd_signed_vma) 0xff) << 24;
f0105a13:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
f0105a17:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105a1c:	0f a4 cb 18          	shld   $0x18,%ecx,%ebx
f0105a20:	c1 e1 18             	shl    $0x18,%ecx
f0105a23:	09 c8                	or     %ecx,%eax
f0105a25:	09 da                	or     %ebx,%edx
f0105a27:	83 c6 04             	add    $0x4,%esi
f0105a2a:	89 35 6c 92 2a f0    	mov    %esi,0xf02a926c
f0105a30:	2d 00 00 00 80       	sub    $0x80000000,%eax
f0105a35:	2d 00 00 00 80       	sub    $0x80000000,%eax
f0105a3a:	83 da 00             	sbb    $0x0,%edx

  x = (x ^ ((bfd_signed_vma) 1 << 31)) - ((bfd_signed_vma) 1 << 31);

  return x;
}
f0105a3d:	5b                   	pop    %ebx
f0105a3e:	5e                   	pop    %esi
f0105a3f:	5d                   	pop    %ebp
f0105a40:	c3                   	ret    

f0105a41 <get16>:

static int
get16 ()
{
f0105a41:	55                   	push   %ebp
f0105a42:	89 e5                	mov    %esp,%ebp
f0105a44:	83 ec 08             	sub    $0x8,%esp
  int x = 0;

  FETCH_DATA (the_info, codep + 2);
f0105a47:	8b 15 6c 92 2a f0    	mov    0xf02a926c,%edx
f0105a4d:	83 c2 02             	add    $0x2,%edx
f0105a50:	8b 0d 70 92 2a f0    	mov    0xf02a9270,%ecx
f0105a56:	8b 41 20             	mov    0x20(%ecx),%eax
f0105a59:	3b 10                	cmp    (%eax),%edx
f0105a5b:	76 07                	jbe    f0105a64 <get16+0x23>
f0105a5d:	89 c8                	mov    %ecx,%eax
f0105a5f:	e8 7c fc ff ff       	call   f01056e0 <fetch_data>
  x = *codep++ & 0xff;
f0105a64:	8b 15 6c 92 2a f0    	mov    0xf02a926c,%edx
f0105a6a:	0f b6 0a             	movzbl (%edx),%ecx
  x |= (*codep++ & 0xff) << 8;
f0105a6d:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f0105a71:	c1 e0 08             	shl    $0x8,%eax
f0105a74:	09 c8                	or     %ecx,%eax
f0105a76:	83 c2 02             	add    $0x2,%edx
f0105a79:	89 15 6c 92 2a f0    	mov    %edx,0xf02a926c
  return x;
}
f0105a7f:	c9                   	leave  
f0105a80:	c3                   	ret    

f0105a81 <set_op>:

static void
set_op (op, riprel)
     bfd_vma op;
     int riprel;
{
f0105a81:	55                   	push   %ebp
f0105a82:	89 e5                	mov    %esp,%ebp
f0105a84:	83 ec 08             	sub    $0x8,%esp
f0105a87:	89 1c 24             	mov    %ebx,(%esp)
f0105a8a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105a8e:	89 c3                	mov    %eax,%ebx
  op_index[op_ad] = op_ad;
f0105a90:	a1 04 94 2a f0       	mov    0xf02a9404,%eax
f0105a95:	89 04 85 08 94 2a f0 	mov    %eax,0xf02a9408(,%eax,4)
  if (mode_64bit)
f0105a9c:	83 3d 60 91 2a f0 00 	cmpl   $0x0,0xf02a9160
f0105aa3:	74 23                	je     f0105ac8 <set_op+0x47>
    {
      op_address[op_ad] = op;
f0105aa5:	89 1c c5 18 94 2a f0 	mov    %ebx,0xf02a9418(,%eax,8)
f0105aac:	89 14 c5 1c 94 2a f0 	mov    %edx,0xf02a941c(,%eax,8)
      op_riprel[op_ad] = riprel;
f0105ab3:	89 0c c5 30 94 2a f0 	mov    %ecx,0xf02a9430(,%eax,8)
f0105aba:	89 ca                	mov    %ecx,%edx
f0105abc:	c1 fa 1f             	sar    $0x1f,%edx
f0105abf:	89 14 c5 34 94 2a f0 	mov    %edx,0xf02a9434(,%eax,8)
f0105ac6:	eb 24                	jmp    f0105aec <set_op+0x6b>
    }
  else
    {
      /* Mask to get a 32-bit address.  */
      op_address[op_ad] = op & 0xffffffff;
f0105ac8:	89 1c c5 18 94 2a f0 	mov    %ebx,0xf02a9418(,%eax,8)
f0105acf:	c7 04 c5 1c 94 2a f0 	movl   $0x0,0xf02a941c(,%eax,8)
f0105ad6:	00 00 00 00 
      op_riprel[op_ad] = riprel & 0xffffffff;
f0105ada:	89 0c c5 30 94 2a f0 	mov    %ecx,0xf02a9430(,%eax,8)
f0105ae1:	c7 04 c5 34 94 2a f0 	movl   $0x0,0xf02a9434(,%eax,8)
f0105ae8:	00 00 00 00 
    }
}
f0105aec:	8b 1c 24             	mov    (%esp),%ebx
f0105aef:	8b 74 24 04          	mov    0x4(%esp),%esi
f0105af3:	89 ec                	mov    %ebp,%esp
f0105af5:	5d                   	pop    %ebp
f0105af6:	c3                   	ret    

f0105af7 <putop>:
f0105af7:	55                   	push   %ebp
f0105af8:	89 e5                	mov    %esp,%ebp
f0105afa:	57                   	push   %edi
f0105afb:	56                   	push   %esi
f0105afc:	53                   	push   %ebx
f0105afd:	83 ec 4c             	sub    $0x4c,%esp
f0105b00:	89 c7                	mov    %eax,%edi
f0105b02:	89 55 b8             	mov    %edx,0xffffffb8(%ebp)
f0105b05:	0f b6 18             	movzbl (%eax),%ebx
f0105b08:	84 db                	test   %bl,%bl
f0105b0a:	0f 84 29 05 00 00    	je     f0106039 <putop+0x542>
f0105b10:	a1 6c 91 2a f0       	mov    0xf02a916c,%eax
f0105b15:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
f0105b18:	8b 15 70 91 2a f0    	mov    0xf02a9170,%edx
f0105b1e:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
f0105b21:	8b 35 e4 91 2a f0    	mov    0xf02a91e4,%esi
f0105b27:	a1 68 91 2a f0       	mov    0xf02a9168,%eax
f0105b2c:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
f0105b2f:	a1 64 91 2a f0       	mov    0xf02a9164,%eax
f0105b34:	89 c2                	mov    %eax,%edx
f0105b36:	81 e2 00 02 00 00    	and    $0x200,%edx
f0105b3c:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
f0105b3f:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
f0105b42:	83 e2 08             	and    $0x8,%edx
f0105b45:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
f0105b48:	8b 15 74 92 2a f0    	mov    0xf02a9274,%edx
f0105b4e:	89 55 c0             	mov    %edx,0xffffffc0(%ebp)
f0105b51:	8b 15 60 91 2a f0    	mov    0xf02a9160,%edx
f0105b57:	89 55 bc             	mov    %edx,0xffffffbc(%ebp)
f0105b5a:	89 c2                	mov    %eax,%edx
f0105b5c:	81 e2 00 08 00 00    	and    $0x800,%edx
f0105b62:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
f0105b65:	89 c2                	mov    %eax,%edx
f0105b67:	83 e2 28             	and    $0x28,%edx
f0105b6a:	89 55 c8             	mov    %edx,0xffffffc8(%ebp)
f0105b6d:	83 fa 08             	cmp    $0x8,%edx
f0105b70:	0f 94 c1             	sete   %cl
f0105b73:	83 fa 20             	cmp    $0x20,%edx
f0105b76:	0f 94 c2             	sete   %dl
f0105b79:	09 d1                	or     %edx,%ecx
f0105b7b:	88 4d cf             	mov    %cl,0xffffffcf(%ebp)
f0105b7e:	89 c2                	mov    %eax,%edx
f0105b80:	83 e2 20             	and    $0x20,%edx
f0105b83:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
f0105b86:	25 00 04 00 00       	and    $0x400,%eax
f0105b8b:	89 45 c4             	mov    %eax,0xffffffc4(%ebp)
f0105b8e:	80 3d 50 94 2a f0 00 	cmpb   $0x0,0xf02a9450
f0105b95:	0f 95 c1             	setne  %cl
f0105b98:	0f b6 c1             	movzbl %cl,%eax
f0105b9b:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
f0105b9e:	83 c0 02             	add    $0x2,%eax
f0105ba1:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
f0105ba4:	89 fa                	mov    %edi,%edx
f0105ba6:	8d 43 bf             	lea    0xffffffbf(%ebx),%eax
f0105ba9:	3c 3c                	cmp    $0x3c,%al
f0105bab:	77 0a                	ja     f0105bb7 <putop+0xc0>
f0105bad:	0f b6 c0             	movzbl %al,%eax
f0105bb0:	ff 24 85 98 d5 10 f0 	jmp    *0xf010d598(,%eax,4)
f0105bb7:	88 1e                	mov    %bl,(%esi)
f0105bb9:	83 c6 01             	add    $0x1,%esi
f0105bbc:	e9 53 04 00 00       	jmp    f0106014 <putop+0x51d>
f0105bc1:	8b 5d ec             	mov    0xffffffec(%ebp),%ebx
f0105bc4:	83 7d bc 00          	cmpl   $0x0,0xffffffbc(%ebp)
f0105bc8:	74 03                	je     f0105bcd <putop+0xd6>
f0105bca:	8b 5d f0             	mov    0xfffffff0(%ebp),%ebx
f0105bcd:	85 db                	test   %ebx,%ebx
f0105bcf:	75 65                	jne    f0105c36 <putop+0x13f>
f0105bd1:	e9 3e 04 00 00       	jmp    f0106014 <putop+0x51d>
f0105bd6:	3c 7d                	cmp    $0x7d,%al
f0105bd8:	75 25                	jne    f0105bff <putop+0x108>
f0105bda:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
f0105bdd:	89 15 6c 91 2a f0    	mov    %edx,0xf02a916c
f0105be3:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f0105be6:	a3 70 91 2a f0       	mov    %eax,0xf02a9170
f0105beb:	c7 05 e4 91 2a f0 85 	movl   $0xf02a9185,0xf02a91e4
f0105bf2:	91 2a f0 
f0105bf5:	b8 01 00 00 00       	mov    $0x1,%eax
f0105bfa:	e9 5d 04 00 00       	jmp    f010605c <putop+0x565>
f0105bff:	84 c0                	test   %al,%al
f0105c01:	75 33                	jne    f0105c36 <putop+0x13f>
f0105c03:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
f0105c06:	89 15 6c 91 2a f0    	mov    %edx,0xf02a916c
f0105c0c:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f0105c0f:	a3 70 91 2a f0       	mov    %eax,0xf02a9170
f0105c14:	89 35 e4 91 2a f0    	mov    %esi,0xf02a91e4
f0105c1a:	c7 44 24 08 f3 bf 10 	movl   $0xf010bff3,0x8(%esp)
f0105c21:	f0 
f0105c22:	c7 44 24 04 40 0a 00 	movl   $0xa40,0x4(%esp)
f0105c29:	00 
f0105c2a:	c7 04 24 07 c0 10 f0 	movl   $0xf010c007,(%esp)
f0105c31:	e8 50 a4 ff ff       	call   f0100086 <_panic>
f0105c36:	83 c2 01             	add    $0x1,%edx
f0105c39:	0f b6 02             	movzbl (%edx),%eax
f0105c3c:	3c 7c                	cmp    $0x7c,%al
f0105c3e:	75 96                	jne    f0105bd6 <putop+0xdf>
f0105c40:	83 eb 01             	sub    $0x1,%ebx
f0105c43:	0f 84 cb 03 00 00    	je     f0106014 <putop+0x51d>
f0105c49:	eb eb                	jmp    f0105c36 <putop+0x13f>
f0105c4b:	84 c0                	test   %al,%al
f0105c4d:	8d 76 00             	lea    0x0(%esi),%esi
f0105c50:	75 33                	jne    f0105c85 <putop+0x18e>
f0105c52:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
f0105c55:	89 15 6c 91 2a f0    	mov    %edx,0xf02a916c
f0105c5b:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f0105c5e:	a3 70 91 2a f0       	mov    %eax,0xf02a9170
f0105c63:	89 35 e4 91 2a f0    	mov    %esi,0xf02a91e4
f0105c69:	c7 44 24 08 f3 bf 10 	movl   $0xf010bff3,0x8(%esp)
f0105c70:	f0 
f0105c71:	c7 44 24 04 4a 0a 00 	movl   $0xa4a,0x4(%esp)
f0105c78:	00 
f0105c79:	c7 04 24 07 c0 10 f0 	movl   $0xf010c007,(%esp)
f0105c80:	e8 01 a4 ff ff       	call   f0100086 <_panic>
f0105c85:	83 c2 01             	add    $0x1,%edx
f0105c88:	0f b6 02             	movzbl (%edx),%eax
f0105c8b:	3c 7d                	cmp    $0x7d,%al
f0105c8d:	75 bc                	jne    f0105c4b <putop+0x154>
f0105c8f:	e9 80 03 00 00       	jmp    f0106014 <putop+0x51d>
f0105c94:	84 c9                	test   %cl,%cl
f0105c96:	0f 85 78 03 00 00    	jne    f0106014 <putop+0x51d>
f0105c9c:	83 7d c0 03          	cmpl   $0x3,0xffffffc0(%ebp)
f0105ca0:	75 0a                	jne    f0105cac <putop+0x1b5>
f0105ca2:	f6 45 b8 04          	testb  $0x4,0xffffffb8(%ebp)
f0105ca6:	0f 84 68 03 00 00    	je     f0106014 <putop+0x51d>
f0105cac:	c6 06 62             	movb   $0x62,(%esi)
f0105caf:	83 c6 01             	add    $0x1,%esi
f0105cb2:	e9 5d 03 00 00       	jmp    f0106014 <putop+0x51d>
f0105cb7:	84 c9                	test   %cl,%cl
f0105cb9:	0f 85 55 03 00 00    	jne    f0106014 <putop+0x51d>
f0105cbf:	f6 45 b8 04          	testb  $0x4,0xffffffb8(%ebp)
f0105cc3:	0f 84 4b 03 00 00    	je     f0106014 <putop+0x51d>
f0105cc9:	c6 06 62             	movb   $0x62,(%esi)
f0105ccc:	83 c6 01             	add    $0x1,%esi
f0105ccf:	90                   	nop    
f0105cd0:	e9 3f 03 00 00       	jmp    f0106014 <putop+0x51d>
f0105cd5:	83 7d bc 00          	cmpl   $0x0,0xffffffbc(%ebp)
f0105cd9:	74 17                	je     f0105cf2 <putop+0x1fb>
f0105cdb:	f6 45 b8 02          	testb  $0x2,0xffffffb8(%ebp)
f0105cdf:	90                   	nop    
f0105ce0:	74 08                	je     f0105cea <putop+0x1f3>
f0105ce2:	c6 06 72             	movb   $0x72,(%esi)
f0105ce5:	83 c6 01             	add    $0x1,%esi
f0105ce8:	eb 14                	jmp    f0105cfe <putop+0x207>
f0105cea:	c6 06 65             	movb   $0x65,(%esi)
f0105ced:	83 c6 01             	add    $0x1,%esi
f0105cf0:	eb 0c                	jmp    f0105cfe <putop+0x207>
f0105cf2:	f6 45 b8 02          	testb  $0x2,0xffffffb8(%ebp)
f0105cf6:	74 06                	je     f0105cfe <putop+0x207>
f0105cf8:	c6 06 65             	movb   $0x65,(%esi)
f0105cfb:	83 c6 01             	add    $0x1,%esi
f0105cfe:	8b 45 c4             	mov    0xffffffc4(%ebp),%eax
f0105d01:	09 45 e8             	or     %eax,0xffffffe8(%ebp)
f0105d04:	e9 0b 03 00 00       	jmp    f0106014 <putop+0x51d>
f0105d09:	84 c9                	test   %cl,%cl
f0105d0b:	0f 85 03 03 00 00    	jne    f0106014 <putop+0x51d>
f0105d11:	83 7d c4 00          	cmpl   $0x0,0xffffffc4(%ebp)
f0105d15:	75 0f                	jne    f0105d26 <putop+0x22f>
f0105d17:	f6 45 b8 04          	testb  $0x4,0xffffffb8(%ebp)
f0105d1b:	90                   	nop    
f0105d1c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0105d20:	0f 84 ee 02 00 00    	je     f0106014 <putop+0x51d>
f0105d26:	f6 45 b8 02          	testb  $0x2,0xffffffb8(%ebp)
f0105d2a:	74 13                	je     f0105d3f <putop+0x248>
f0105d2c:	83 7d bc 01          	cmpl   $0x1,0xffffffbc(%ebp)
f0105d30:	19 c0                	sbb    %eax,%eax
f0105d32:	83 e0 fb             	and    $0xfffffffb,%eax
f0105d35:	83 c0 71             	add    $0x71,%eax
f0105d38:	88 06                	mov    %al,(%esi)
f0105d3a:	83 c6 01             	add    $0x1,%esi
f0105d3d:	eb 11                	jmp    f0105d50 <putop+0x259>
f0105d3f:	83 7d bc 01          	cmpl   $0x1,0xffffffbc(%ebp)
f0105d43:	19 c0                	sbb    %eax,%eax
f0105d45:	83 e0 0b             	and    $0xb,%eax
f0105d48:	83 c0 6c             	add    $0x6c,%eax
f0105d4b:	88 06                	mov    %al,(%esi)
f0105d4d:	83 c6 01             	add    $0x1,%esi
f0105d50:	8b 45 c4             	mov    0xffffffc4(%ebp),%eax
f0105d53:	09 45 e8             	or     %eax,0xffffffe8(%ebp)
f0105d56:	e9 b9 02 00 00       	jmp    f0106014 <putop+0x51d>
f0105d5b:	84 c9                	test   %cl,%cl
f0105d5d:	0f 85 b1 02 00 00    	jne    f0106014 <putop+0x51d>
f0105d63:	80 7d cf 00          	cmpb   $0x0,0xffffffcf(%ebp)
f0105d67:	0f 84 a7 02 00 00    	je     f0106014 <putop+0x51d>
f0105d6d:	8b 45 c8             	mov    0xffffffc8(%ebp),%eax
f0105d70:	09 45 e8             	or     %eax,0xffffffe8(%ebp)
f0105d73:	c6 06 2c             	movb   $0x2c,(%esi)
f0105d76:	c6 46 01 70          	movb   $0x70,0x1(%esi)
f0105d7a:	8d 46 02             	lea    0x2(%esi),%eax
f0105d7d:	83 7d d0 00          	cmpl   $0x0,0xffffffd0(%ebp)
f0105d81:	74 0c                	je     f0105d8f <putop+0x298>
f0105d83:	c6 46 02 74          	movb   $0x74,0x2(%esi)
f0105d87:	83 c6 03             	add    $0x3,%esi
f0105d8a:	e9 85 02 00 00       	jmp    f0106014 <putop+0x51d>
f0105d8f:	c6 00 6e             	movb   $0x6e,(%eax)
f0105d92:	8d 70 01             	lea    0x1(%eax),%esi
f0105d95:	e9 7a 02 00 00       	jmp    f0106014 <putop+0x51d>
f0105d9a:	84 c9                	test   %cl,%cl
f0105d9c:	0f 85 72 02 00 00    	jne    f0106014 <putop+0x51d>
f0105da2:	f6 45 b8 04          	testb  $0x4,0xffffffb8(%ebp)
f0105da6:	0f 84 68 02 00 00    	je     f0106014 <putop+0x51d>
f0105dac:	c6 06 6c             	movb   $0x6c,(%esi)
f0105daf:	83 c6 01             	add    $0x1,%esi
f0105db2:	e9 5d 02 00 00       	jmp    f0106014 <putop+0x51d>
f0105db7:	83 7d d4 00          	cmpl   $0x0,0xffffffd4(%ebp)
f0105dbb:	75 0b                	jne    f0105dc8 <putop+0x2d1>
f0105dbd:	c6 06 6e             	movb   $0x6e,(%esi)
f0105dc0:	83 c6 01             	add    $0x1,%esi
f0105dc3:	e9 4c 02 00 00       	jmp    f0106014 <putop+0x51d>
f0105dc8:	81 4d e8 00 08 00 00 	orl    $0x800,0xffffffe8(%ebp)
f0105dcf:	90                   	nop    
f0105dd0:	e9 3f 02 00 00       	jmp    f0106014 <putop+0x51d>
f0105dd5:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
f0105dd9:	0f 84 69 02 00 00    	je     f0106048 <putop+0x551>
f0105ddf:	83 4d e4 48          	orl    $0x48,0xffffffe4(%ebp)
f0105de3:	c6 06 6f             	movb   $0x6f,(%esi)
f0105de6:	83 c6 01             	add    $0x1,%esi
f0105de9:	e9 26 02 00 00       	jmp    f0106014 <putop+0x51d>
f0105dee:	84 c9                	test   %cl,%cl
f0105df0:	0f 85 1e 02 00 00    	jne    f0106014 <putop+0x51d>
f0105df6:	83 7d bc 00          	cmpl   $0x0,0xffffffbc(%ebp)
f0105dfa:	74 13                	je     f0105e0f <putop+0x318>
f0105dfc:	c6 06 71             	movb   $0x71,(%esi)
f0105dff:	83 c6 01             	add    $0x1,%esi
f0105e02:	e9 0d 02 00 00       	jmp    f0106014 <putop+0x51d>
f0105e07:	84 c9                	test   %cl,%cl
f0105e09:	0f 85 05 02 00 00    	jne    f0106014 <putop+0x51d>
f0105e0f:	83 7d e0 00          	cmpl   $0x0,0xffffffe0(%ebp)
f0105e13:	75 15                	jne    f0105e2a <putop+0x333>
f0105e15:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
f0105e19:	0f 85 31 02 00 00    	jne    f0106050 <putop+0x559>
f0105e1f:	f6 45 b8 04          	testb  $0x4,0xffffffb8(%ebp)
f0105e23:	75 11                	jne    f0105e36 <putop+0x33f>
f0105e25:	e9 ea 01 00 00       	jmp    f0106014 <putop+0x51d>
f0105e2a:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
f0105e2e:	66 90                	xchg   %ax,%ax
f0105e30:	0f 85 1a 02 00 00    	jne    f0106050 <putop+0x559>
f0105e36:	f6 45 b8 01          	testb  $0x1,0xffffffb8(%ebp)
f0105e3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105e40:	74 08                	je     f0105e4a <putop+0x353>
f0105e42:	c6 06 6c             	movb   $0x6c,(%esi)
f0105e45:	83 c6 01             	add    $0x1,%esi
f0105e48:	eb 06                	jmp    f0105e50 <putop+0x359>
f0105e4a:	c6 06 77             	movb   $0x77,(%esi)
f0105e4d:	83 c6 01             	add    $0x1,%esi
f0105e50:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
f0105e53:	09 45 e8             	or     %eax,0xffffffe8(%ebp)
f0105e56:	e9 b9 01 00 00       	jmp    f0106014 <putop+0x51d>
f0105e5b:	84 c9                	test   %cl,%cl
f0105e5d:	0f 85 b1 01 00 00    	jne    f0106014 <putop+0x51d>
f0105e63:	83 7d bc 00          	cmpl   $0x0,0xffffffbc(%ebp)
f0105e67:	74 14                	je     f0105e7d <putop+0x386>
f0105e69:	c6 06 71             	movb   $0x71,(%esi)
f0105e6c:	83 c6 01             	add    $0x1,%esi
f0105e6f:	90                   	nop    
f0105e70:	e9 9f 01 00 00       	jmp    f0106014 <putop+0x51d>
f0105e75:	84 c9                	test   %cl,%cl
f0105e77:	0f 85 97 01 00 00    	jne    f0106014 <putop+0x51d>
f0105e7d:	83 7d dc 01          	cmpl   $0x1,0xffffffdc(%ebp)
f0105e81:	19 c0                	sbb    %eax,%eax
f0105e83:	f7 d0                	not    %eax
f0105e85:	83 e0 48             	and    $0x48,%eax
f0105e88:	09 45 e4             	or     %eax,0xffffffe4(%ebp)
f0105e8b:	83 7d c0 03          	cmpl   $0x3,0xffffffc0(%ebp)
f0105e8f:	75 0a                	jne    f0105e9b <putop+0x3a4>
f0105e91:	f6 45 b8 04          	testb  $0x4,0xffffffb8(%ebp)
f0105e95:	0f 84 79 01 00 00    	je     f0106014 <putop+0x51d>
f0105e9b:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
f0105e9f:	74 0b                	je     f0105eac <putop+0x3b5>
f0105ea1:	c6 06 71             	movb   $0x71,(%esi)
f0105ea4:	83 c6 01             	add    $0x1,%esi
f0105ea7:	e9 68 01 00 00       	jmp    f0106014 <putop+0x51d>
f0105eac:	f6 45 b8 01          	testb  $0x1,0xffffffb8(%ebp)
f0105eb0:	74 08                	je     f0105eba <putop+0x3c3>
f0105eb2:	c6 06 6c             	movb   $0x6c,(%esi)
f0105eb5:	83 c6 01             	add    $0x1,%esi
f0105eb8:	eb 06                	jmp    f0105ec0 <putop+0x3c9>
f0105eba:	c6 06 77             	movb   $0x77,(%esi)
f0105ebd:	83 c6 01             	add    $0x1,%esi
f0105ec0:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
f0105ec3:	09 45 e8             	or     %eax,0xffffffe8(%ebp)
f0105ec6:	e9 49 01 00 00       	jmp    f0106014 <putop+0x51d>
f0105ecb:	83 7d dc 01          	cmpl   $0x1,0xffffffdc(%ebp)
f0105ecf:	19 c0                	sbb    %eax,%eax
f0105ed1:	f7 d0                	not    %eax
f0105ed3:	83 e0 48             	and    $0x48,%eax
f0105ed6:	09 45 e4             	or     %eax,0xffffffe4(%ebp)
f0105ed9:	84 c9                	test   %cl,%cl
f0105edb:	74 33                	je     f0105f10 <putop+0x419>
f0105edd:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
f0105ee1:	74 0f                	je     f0105ef2 <putop+0x3fb>
f0105ee3:	c6 06 71             	movb   $0x71,(%esi)
f0105ee6:	c6 46 01 74          	movb   $0x74,0x1(%esi)
f0105eea:	83 c6 02             	add    $0x2,%esi
f0105eed:	e9 22 01 00 00       	jmp    f0106014 <putop+0x51d>
f0105ef2:	f6 45 b8 01          	testb  $0x1,0xffffffb8(%ebp)
f0105ef6:	74 0c                	je     f0105f04 <putop+0x40d>
f0105ef8:	c6 06 64             	movb   $0x64,(%esi)
f0105efb:	c6 46 01 71          	movb   $0x71,0x1(%esi)
f0105eff:	83 c6 02             	add    $0x2,%esi
f0105f02:	eb 31                	jmp    f0105f35 <putop+0x43e>
f0105f04:	c6 06 77             	movb   $0x77,(%esi)
f0105f07:	c6 46 01 64          	movb   $0x64,0x1(%esi)
f0105f0b:	83 c6 02             	add    $0x2,%esi
f0105f0e:	eb 25                	jmp    f0105f35 <putop+0x43e>
f0105f10:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
f0105f14:	74 0b                	je     f0105f21 <putop+0x42a>
f0105f16:	c6 06 71             	movb   $0x71,(%esi)
f0105f19:	83 c6 01             	add    $0x1,%esi
f0105f1c:	e9 f3 00 00 00       	jmp    f0106014 <putop+0x51d>
f0105f21:	f6 45 b8 01          	testb  $0x1,0xffffffb8(%ebp)
f0105f25:	74 08                	je     f0105f2f <putop+0x438>
f0105f27:	c6 06 6c             	movb   $0x6c,(%esi)
f0105f2a:	83 c6 01             	add    $0x1,%esi
f0105f2d:	eb 06                	jmp    f0105f35 <putop+0x43e>
f0105f2f:	c6 06 77             	movb   $0x77,(%esi)
f0105f32:	83 c6 01             	add    $0x1,%esi
f0105f35:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
f0105f38:	09 45 e8             	or     %eax,0xffffffe8(%ebp)
f0105f3b:	e9 d4 00 00 00       	jmp    f0106014 <putop+0x51d>
f0105f40:	84 c9                	test   %cl,%cl
f0105f42:	0f 85 cc 00 00 00    	jne    f0106014 <putop+0x51d>
f0105f48:	f6 45 b8 04          	testb  $0x4,0xffffffb8(%ebp)
f0105f4c:	0f 84 c2 00 00 00    	je     f0106014 <putop+0x51d>
f0105f52:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
f0105f56:	74 0d                	je     f0105f65 <putop+0x46e>
f0105f58:	c6 06 71             	movb   $0x71,(%esi)
f0105f5b:	83 c6 01             	add    $0x1,%esi
f0105f5e:	66 90                	xchg   %ax,%ax
f0105f60:	e9 af 00 00 00       	jmp    f0106014 <putop+0x51d>
f0105f65:	f6 45 b8 01          	testb  $0x1,0xffffffb8(%ebp)
f0105f69:	74 08                	je     f0105f73 <putop+0x47c>
f0105f6b:	c6 06 6c             	movb   $0x6c,(%esi)
f0105f6e:	83 c6 01             	add    $0x1,%esi
f0105f71:	eb 06                	jmp    f0105f79 <putop+0x482>
f0105f73:	c6 06 77             	movb   $0x77,(%esi)
f0105f76:	83 c6 01             	add    $0x1,%esi
f0105f79:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
f0105f7c:	09 45 e8             	or     %eax,0xffffffe8(%ebp)
f0105f7f:	e9 90 00 00 00       	jmp    f0106014 <putop+0x51d>
f0105f84:	83 7d e0 00          	cmpl   $0x0,0xffffffe0(%ebp)
f0105f88:	74 08                	je     f0105f92 <putop+0x49b>
f0105f8a:	c6 06 64             	movb   $0x64,(%esi)
f0105f8d:	83 c6 01             	add    $0x1,%esi
f0105f90:	eb 06                	jmp    f0105f98 <putop+0x4a1>
f0105f92:	c6 06 73             	movb   $0x73,(%esi)
f0105f95:	83 c6 01             	add    $0x1,%esi
f0105f98:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
f0105f9b:	09 45 e8             	or     %eax,0xffffffe8(%ebp)
f0105f9e:	eb 74                	jmp    f0106014 <putop+0x51d>
f0105fa0:	84 c9                	test   %cl,%cl
f0105fa2:	75 70                	jne    f0106014 <putop+0x51d>
f0105fa4:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
f0105fa8:	74 6a                	je     f0106014 <putop+0x51d>
f0105faa:	83 4d e4 48          	orl    $0x48,0xffffffe4(%ebp)
f0105fae:	c6 06 71             	movb   $0x71,(%esi)
f0105fb1:	83 c6 01             	add    $0x1,%esi
f0105fb4:	eb 5e                	jmp    f0106014 <putop+0x51d>
f0105fb6:	83 4d e4 40          	orl    $0x40,0xffffffe4(%ebp)
f0105fba:	83 7d d8 00          	cmpl   $0x0,0xffffffd8(%ebp)
f0105fbe:	74 08                	je     f0105fc8 <putop+0x4d1>
f0105fc0:	c6 06 6c             	movb   $0x6c,(%esi)
f0105fc3:	83 c6 01             	add    $0x1,%esi
f0105fc6:	eb 14                	jmp    f0105fdc <putop+0x4e5>
f0105fc8:	f6 45 b8 01          	testb  $0x1,0xffffffb8(%ebp)
f0105fcc:	74 08                	je     f0105fd6 <putop+0x4df>
f0105fce:	c6 06 77             	movb   $0x77,(%esi)
f0105fd1:	83 c6 01             	add    $0x1,%esi
f0105fd4:	eb 06                	jmp    f0105fdc <putop+0x4e5>
f0105fd6:	c6 06 62             	movb   $0x62,(%esi)
f0105fd9:	83 c6 01             	add    $0x1,%esi
f0105fdc:	84 c9                	test   %cl,%cl
f0105fde:	74 28                	je     f0106008 <putop+0x511>
f0105fe0:	83 7d d8 00          	cmpl   $0x0,0xffffffd8(%ebp)
f0105fe4:	74 0a                	je     f0105ff0 <putop+0x4f9>
f0105fe6:	c6 06 71             	movb   $0x71,(%esi)
f0105fe9:	c6 46 01 65          	movb   $0x65,0x1(%esi)
f0105fed:	83 c6 02             	add    $0x2,%esi
f0105ff0:	f6 45 b8 01          	testb  $0x1,0xffffffb8(%ebp)
f0105ff4:	74 0c                	je     f0106002 <putop+0x50b>
f0105ff6:	c6 06 64             	movb   $0x64,(%esi)
f0105ff9:	c6 46 01 65          	movb   $0x65,0x1(%esi)
f0105ffd:	83 c6 02             	add    $0x2,%esi
f0106000:	eb 06                	jmp    f0106008 <putop+0x511>
f0106002:	c6 06 77             	movb   $0x77,(%esi)
f0106005:	83 c6 01             	add    $0x1,%esi
f0106008:	83 7d d8 00          	cmpl   $0x0,0xffffffd8(%ebp)
f010600c:	75 06                	jne    f0106014 <putop+0x51d>
f010600e:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
f0106011:	09 45 e8             	or     %eax,0xffffffe8(%ebp)
f0106014:	83 c2 01             	add    $0x1,%edx
f0106017:	0f b6 1a             	movzbl (%edx),%ebx
f010601a:	84 db                	test   %bl,%bl
f010601c:	0f 85 84 fb ff ff    	jne    f0105ba6 <putop+0xaf>
f0106022:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
f0106025:	89 15 6c 91 2a f0    	mov    %edx,0xf02a916c
f010602b:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f010602e:	a3 70 91 2a f0       	mov    %eax,0xf02a9170
f0106033:	89 35 e4 91 2a f0    	mov    %esi,0xf02a91e4
f0106039:	a1 e4 91 2a f0       	mov    0xf02a91e4,%eax
f010603e:	c6 00 00             	movb   $0x0,(%eax)
f0106041:	b8 00 00 00 00       	mov    $0x0,%eax
f0106046:	eb 14                	jmp    f010605c <putop+0x565>
f0106048:	c6 06 64             	movb   $0x64,(%esi)
f010604b:	83 c6 01             	add    $0x1,%esi
f010604e:	eb c4                	jmp    f0106014 <putop+0x51d>
f0106050:	83 4d e4 48          	orl    $0x48,0xffffffe4(%ebp)
f0106054:	c6 06 71             	movb   $0x71,(%esi)
f0106057:	83 c6 01             	add    $0x1,%esi
f010605a:	eb b8                	jmp    f0106014 <putop+0x51d>
f010605c:	83 c4 4c             	add    $0x4c,%esp
f010605f:	5b                   	pop    %ebx
f0106060:	5e                   	pop    %esi
f0106061:	5f                   	pop    %edi
f0106062:	5d                   	pop    %ebp
f0106063:	c3                   	ret    

f0106064 <SIMD_Fixup>:

static void
OP_REG (code, sizeflag)
     int code;
     int sizeflag;
{
  const char *s;
  int add = 0;
  USED_REX (REX_EXTZ);
  if (rex & REX_EXTZ)
    add = 8;

  switch (code)
    {
    case indir_dx_reg:
      if (intel_syntax)
        s = "[dx]";
      else
        s = "(%dx)";
      break;
    case ax_reg: case cx_reg: case dx_reg: case bx_reg:
    case sp_reg: case bp_reg: case si_reg: case di_reg:
      s = names16[code - ax_reg + add];
      break;
    case es_reg: case ss_reg: case cs_reg:
    case ds_reg: case fs_reg: case gs_reg:
      s = names_seg[code - es_reg + add];
      break;
    case al_reg: case ah_reg: case cl_reg: case ch_reg:
    case dl_reg: case dh_reg: case bl_reg: case bh_reg:
      USED_REX (0);
      if (rex)
	s = names8rex[code - al_reg + add];
      else
	s = names8[code - al_reg];
      break;
    case rAX_reg: case rCX_reg: case rDX_reg: case rBX_reg:
    case rSP_reg: case rBP_reg: case rSI_reg: case rDI_reg:
      if (mode_64bit)
	{
	  s = names64[code - rAX_reg + add];
	  break;
	}
      code += eAX_reg - rAX_reg;
      /* Fall through.  */
    case eAX_reg: case eCX_reg: case eDX_reg: case eBX_reg:
    case eSP_reg: case eBP_reg: case eSI_reg: case eDI_reg:
      USED_REX (REX_MODE64);
      if (rex & REX_MODE64)
	s = names64[code - eAX_reg + add];
      else if (sizeflag & DFLAG)
	s = names32[code - eAX_reg + add];
      else
	s = names16[code - eAX_reg + add];
      used_prefixes |= (prefixes & PREFIX_DATA);
      break;
    default:
      s = INTERNAL_DISASSEMBLER_ERROR;
      break;
    }
  oappend (s);
}

static void
OP_IMREG (code, sizeflag)
     int code;
     int sizeflag;
{
  const char *s;

  switch (code)
    {
    case indir_dx_reg:
      if (intel_syntax)
        s = "[dx]";
      else
        s = "(%dx)";
      break;
    case ax_reg: case cx_reg: case dx_reg: case bx_reg:
    case sp_reg: case bp_reg: case si_reg: case di_reg:
      s = names16[code - ax_reg];
      break;
    case es_reg: case ss_reg: case cs_reg:
    case ds_reg: case fs_reg: case gs_reg:
      s = names_seg[code - es_reg];
      break;
    case al_reg: case ah_reg: case cl_reg: case ch_reg:
    case dl_reg: case dh_reg: case bl_reg: case bh_reg:
      USED_REX (0);
      if (rex)
	s = names8rex[code - al_reg];
      else
	s = names8[code - al_reg];
      break;
    case eAX_reg: case eCX_reg: case eDX_reg: case eBX_reg:
    case eSP_reg: case eBP_reg: case eSI_reg: case eDI_reg:
      USED_REX (REX_MODE64);
      if (rex & REX_MODE64)
	s = names64[code - eAX_reg];
      else if (sizeflag & DFLAG)
	s = names32[code - eAX_reg];
      else
	s = names16[code - eAX_reg];
      used_prefixes |= (prefixes & PREFIX_DATA);
      break;
    default:
      s = INTERNAL_DISASSEMBLER_ERROR;
      break;
    }
  oappend (s);
}

static void
OP_I (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
  bfd_signed_vma op;
  bfd_signed_vma mask = -1;

  switch (bytemode)
    {
    case b_mode:
      FETCH_DATA (the_info, codep + 1);
      op = *codep++;
      mask = 0xff;
      break;
    case q_mode:
      if (mode_64bit)
	{
	  op = get32s ();
	  break;
	}
      /* Fall through.  */
    case v_mode:
      USED_REX (REX_MODE64);
      if (rex & REX_MODE64)
	op = get32s ();
      else if (sizeflag & DFLAG)
	{
	  op = get32 ();
	  mask = 0xffffffff;
	}
      else
	{
	  op = get16 ();
	  mask = 0xfffff;
	}
      used_prefixes |= (prefixes & PREFIX_DATA);
      break;
    case w_mode:
      mask = 0xfffff;
      op = get16 ();
      break;
    default:
      oappend (INTERNAL_DISASSEMBLER_ERROR);
      return;
    }

  op &= mask;
  scratchbuf[0] = '$';
  print_operand_value (scratchbuf + 1, sizeof(scratchbuf) - 1, 1, op);
  oappend (scratchbuf + intel_syntax);
  scratchbuf[0] = '\0';
}

static void
OP_I64 (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
  bfd_signed_vma op;
  bfd_signed_vma mask = -1;

  if (!mode_64bit)
    {
      OP_I (bytemode, sizeflag);
      return;
    }

  switch (bytemode)
    {
    case b_mode:
      FETCH_DATA (the_info, codep + 1);
      op = *codep++;
      mask = 0xff;
      break;
    case v_mode:
      USED_REX (REX_MODE64);
      if (rex & REX_MODE64)
	op = get64 ();
      else if (sizeflag & DFLAG)
	{
	  op = get32 ();
	  mask = 0xffffffff;
	}
      else
	{
	  op = get16 ();
	  mask = 0xfffff;
	}
      used_prefixes |= (prefixes & PREFIX_DATA);
      break;
    case w_mode:
      mask = 0xfffff;
      op = get16 ();
      break;
    default:
      oappend (INTERNAL_DISASSEMBLER_ERROR);
      return;
    }

  op &= mask;
  scratchbuf[0] = '$';
  print_operand_value (scratchbuf + 1, sizeof(scratchbuf) - 1, 1, op);
  oappend (scratchbuf + intel_syntax);
  scratchbuf[0] = '\0';
}

static void
OP_sI (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
  bfd_signed_vma op;
  bfd_signed_vma mask = -1;

  switch (bytemode)
    {
    case b_mode:
      FETCH_DATA (the_info, codep + 1);
      op = *codep++;
      if ((op & 0x80) != 0)
	op -= 0x100;
      mask = 0xffffffff;
      break;
    case v_mode:
      USED_REX (REX_MODE64);
      if (rex & REX_MODE64)
	op = get32s ();
      else if (sizeflag & DFLAG)
	{
	  op = get32s ();
	  mask = 0xffffffff;
	}
      else
	{
	  mask = 0xffffffff;
	  op = get16 ();
	  if ((op & 0x8000) != 0)
	    op -= 0x10000;
	}
      used_prefixes |= (prefixes & PREFIX_DATA);
      break;
    case w_mode:
      op = get16 ();
      mask = 0xffffffff;
      if ((op & 0x8000) != 0)
	op -= 0x10000;
      break;
    default:
      oappend (INTERNAL_DISASSEMBLER_ERROR);
      return;
    }

  scratchbuf[0] = '$';
  print_operand_value (scratchbuf + 1, sizeof(scratchbuf) - 1, 1, op);
  oappend (scratchbuf + intel_syntax);
}

static void
OP_J (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
  bfd_vma disp;
  bfd_vma mask = -1;

  switch (bytemode)
    {
    case b_mode:
      FETCH_DATA (the_info, codep + 1);
      disp = *codep++;
      if ((disp & 0x80) != 0)
	disp -= 0x100;
      break;
    case v_mode:
      if (sizeflag & DFLAG)
	disp = get32s ();
      else
	{
	  disp = get16 ();
	  /* For some reason, a data16 prefix on a jump instruction
	     means that the pc is masked to 16 bits after the
	     displacement is added!  */
	  mask = 0xffff;
	}
      break;
    default:
      oappend (INTERNAL_DISASSEMBLER_ERROR);
      return;
    }
  disp = (start_pc + codep - start_codep + disp) & mask;
  set_op (disp, 0);
  print_operand_value (scratchbuf, sizeof(scratchbuf), 1, disp);
  oappend (scratchbuf);
}

static void
OP_SEG (dummy, sizeflag)
     int dummy;
     int sizeflag;
{
  oappend (names_seg[reg]);
}

static void
OP_DIR (dummy, sizeflag)
     int dummy;
     int sizeflag;
{
  int seg, offset;

  if (sizeflag & DFLAG)
    {
      offset = get32 ();
      seg = get16 ();
    }
  else
    {
      offset = get16 ();
      seg = get16 ();
    }
  used_prefixes |= (prefixes & PREFIX_DATA);
  if (intel_syntax)
    snprintf (scratchbuf, sizeof(scratchbuf), "0x%x,0x%x", seg, offset);
  else
    snprintf (scratchbuf, sizeof(scratchbuf), "$0x%x,$0x%x", seg, offset);
  oappend (scratchbuf);
}

static void
OP_OFF (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
  bfd_vma off;

  append_seg ();

  if ((sizeflag & AFLAG) || mode_64bit)
    off = get32 ();
  else
    off = get16 ();

  if (intel_syntax)
    {
      if (!(prefixes & (PREFIX_CS | PREFIX_SS | PREFIX_DS
		        | PREFIX_ES | PREFIX_FS | PREFIX_GS)))
	{
	  oappend (names_seg[ds_reg - es_reg]);
	  oappend (":");
	}
    }
  print_operand_value (scratchbuf, sizeof(scratchbuf), 1, off);
  oappend (scratchbuf);
}

static void
OP_OFF64 (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
  bfd_vma off;

  if (!mode_64bit)
    {
      OP_OFF (bytemode, sizeflag);
      return;
    }

  append_seg ();

  off = get64 ();

  if (intel_syntax)
    {
      if (!(prefixes & (PREFIX_CS | PREFIX_SS | PREFIX_DS
		        | PREFIX_ES | PREFIX_FS | PREFIX_GS)))
	{
	  oappend (names_seg[ds_reg - es_reg]);
	  oappend (":");
	}
    }
  print_operand_value (scratchbuf, sizeof(scratchbuf), 1, off);
  oappend (scratchbuf);
}

static void
ptr_reg (code, sizeflag)
     int code;
     int sizeflag;
{
  const char *s;
  if (intel_syntax)
    oappend ("[");
  else
    oappend ("(");

  USED_REX (REX_MODE64);
  if (rex & REX_MODE64)
    {
      if (!(sizeflag & AFLAG))
        s = names32[code - eAX_reg];
      else
        s = names64[code - eAX_reg];
    }
  else if (sizeflag & AFLAG)
    s = names32[code - eAX_reg];
  else
    s = names16[code - eAX_reg];
  oappend (s);
  if (intel_syntax)
    oappend ("]");
  else
    oappend (")");
}

static void
OP_ESreg (code, sizeflag)
     int code;
     int sizeflag;
{
  oappend ("%es:" + intel_syntax);
  ptr_reg (code, sizeflag);
}

static void
OP_DSreg (code, sizeflag)
     int code;
     int sizeflag;
{
  if ((prefixes
       & (PREFIX_CS
	  | PREFIX_DS
	  | PREFIX_SS
	  | PREFIX_ES
	  | PREFIX_FS
	  | PREFIX_GS)) == 0)
    prefixes |= PREFIX_DS;
  append_seg ();
  ptr_reg (code, sizeflag);
}

static void
OP_C (dummy, sizeflag)
     int dummy;
     int sizeflag;
{
  int add = 0;
  USED_REX (REX_EXTX);
  if (rex & REX_EXTX)
    add = 8;
  snprintf (scratchbuf, sizeof(scratchbuf), "%%cr%d", reg + add);
  oappend (scratchbuf + intel_syntax);
}

static void
OP_D (dummy, sizeflag)
     int dummy;
     int sizeflag;
{
  int add = 0;
  USED_REX (REX_EXTX);
  if (rex & REX_EXTX)
    add = 8;
  if (intel_syntax)
    snprintf (scratchbuf, sizeof(scratchbuf), "db%d", reg + add);
  else
    snprintf (scratchbuf, sizeof(scratchbuf), "%%db%d", reg + add);
  oappend (scratchbuf);
}

static void
OP_T (dummy, sizeflag)
     int dummy;
     int sizeflag;
{
  snprintf (scratchbuf, sizeof(scratchbuf), "%%tr%d", reg);
  oappend (scratchbuf + intel_syntax);
}

static void
OP_Rd (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
  if (mod == 3)
    OP_E (bytemode, sizeflag);
  else
    BadOp ();
}

static void
OP_MMX (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
  int add = 0;
  USED_REX (REX_EXTX);
  if (rex & REX_EXTX)
    add = 8;
  used_prefixes |= (prefixes & PREFIX_DATA);
  if (prefixes & PREFIX_DATA)
    snprintf (scratchbuf, sizeof(scratchbuf), "%%xmm%d", reg + add);
  else
    snprintf (scratchbuf, sizeof(scratchbuf), "%%mm%d", reg + add);
  oappend (scratchbuf + intel_syntax);
}

static void
OP_XMM (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
  int add = 0;
  USED_REX (REX_EXTX);
  if (rex & REX_EXTX)
    add = 8;
  snprintf (scratchbuf, sizeof(scratchbuf), "%%xmm%d", reg + add);
  oappend (scratchbuf + intel_syntax);
}

static void
OP_EM (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
  int add = 0;
  if (mod != 3)
    {
      OP_E (bytemode, sizeflag);
      return;
    }
  USED_REX (REX_EXTZ);
  if (rex & REX_EXTZ)
    add = 8;

  /* Skip mod/rm byte.  */
  MODRM_CHECK;
  codep++;
  used_prefixes |= (prefixes & PREFIX_DATA);
  if (prefixes & PREFIX_DATA)
    snprintf (scratchbuf, sizeof(scratchbuf), "%%xmm%d", rm + add);
  else
    snprintf (scratchbuf, sizeof(scratchbuf), "%%mm%d", rm + add);
  oappend (scratchbuf + intel_syntax);
}

static void
OP_EX (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
  int add = 0;
  if (mod != 3)
    {
      OP_E (bytemode, sizeflag);
      return;
    }
  USED_REX (REX_EXTZ);
  if (rex & REX_EXTZ)
    add = 8;

  /* Skip mod/rm byte.  */
  MODRM_CHECK;
  codep++;
  snprintf (scratchbuf, sizeof(scratchbuf), "%%xmm%d", rm + add);
  oappend (scratchbuf + intel_syntax);
}

static void
OP_MS (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
  if (mod == 3)
    OP_EM (bytemode, sizeflag);
  else
    BadOp ();
}

static void
OP_XS (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
  if (mod == 3)
    OP_EX (bytemode, sizeflag);
  else
    BadOp ();
}

static const char *Suffix3DNow[] = {
/* 00 */	NULL,		NULL,		NULL,		NULL,
/* 04 */	NULL,		NULL,		NULL,		NULL,
/* 08 */	NULL,		NULL,		NULL,		NULL,
/* 0C */	"pi2fw",	"pi2fd",	NULL,		NULL,
/* 10 */	NULL,		NULL,		NULL,		NULL,
/* 14 */	NULL,		NULL,		NULL,		NULL,
/* 18 */	NULL,		NULL,		NULL,		NULL,
/* 1C */	"pf2iw",	"pf2id",	NULL,		NULL,
/* 20 */	NULL,		NULL,		NULL,		NULL,
/* 24 */	NULL,		NULL,		NULL,		NULL,
/* 28 */	NULL,		NULL,		NULL,		NULL,
/* 2C */	NULL,		NULL,		NULL,		NULL,
/* 30 */	NULL,		NULL,		NULL,		NULL,
/* 34 */	NULL,		NULL,		NULL,		NULL,
/* 38 */	NULL,		NULL,		NULL,		NULL,
/* 3C */	NULL,		NULL,		NULL,		NULL,
/* 40 */	NULL,		NULL,		NULL,		NULL,
/* 44 */	NULL,		NULL,		NULL,		NULL,
/* 48 */	NULL,		NULL,		NULL,		NULL,
/* 4C */	NULL,		NULL,		NULL,		NULL,
/* 50 */	NULL,		NULL,		NULL,		NULL,
/* 54 */	NULL,		NULL,		NULL,		NULL,
/* 58 */	NULL,		NULL,		NULL,		NULL,
/* 5C */	NULL,		NULL,		NULL,		NULL,
/* 60 */	NULL,		NULL,		NULL,		NULL,
/* 64 */	NULL,		NULL,		NULL,		NULL,
/* 68 */	NULL,		NULL,		NULL,		NULL,
/* 6C */	NULL,		NULL,		NULL,		NULL,
/* 70 */	NULL,		NULL,		NULL,		NULL,
/* 74 */	NULL,		NULL,		NULL,		NULL,
/* 78 */	NULL,		NULL,		NULL,		NULL,
/* 7C */	NULL,		NULL,		NULL,		NULL,
/* 80 */	NULL,		NULL,		NULL,		NULL,
/* 84 */	NULL,		NULL,		NULL,		NULL,
/* 88 */	NULL,		NULL,		"pfnacc",	NULL,
/* 8C */	NULL,		NULL,		"pfpnacc",	NULL,
/* 90 */	"pfcmpge",	NULL,		NULL,		NULL,
/* 94 */	"pfmin",	NULL,		"pfrcp",	"pfrsqrt",
/* 98 */	NULL,		NULL,		"pfsub",	NULL,
/* 9C */	NULL,		NULL,		"pfadd",	NULL,
/* A0 */	"pfcmpgt",	NULL,		NULL,		NULL,
/* A4 */	"pfmax",	NULL,		"pfrcpit1",	"pfrsqit1",
/* A8 */	NULL,		NULL,		"pfsubr",	NULL,
/* AC */	NULL,		NULL,		"pfacc",	NULL,
/* B0 */	"pfcmpeq",	NULL,		NULL,		NULL,
/* B4 */	"pfmul",	NULL,		"pfrcpit2",	"pfmulhrw",
/* B8 */	NULL,		NULL,		NULL,		"pswapd",
/* BC */	NULL,		NULL,		NULL,		"pavgusb",
/* C0 */	NULL,		NULL,		NULL,		NULL,
/* C4 */	NULL,		NULL,		NULL,		NULL,
/* C8 */	NULL,		NULL,		NULL,		NULL,
/* CC */	NULL,		NULL,		NULL,		NULL,
/* D0 */	NULL,		NULL,		NULL,		NULL,
/* D4 */	NULL,		NULL,		NULL,		NULL,
/* D8 */	NULL,		NULL,		NULL,		NULL,
/* DC */	NULL,		NULL,		NULL,		NULL,
/* E0 */	NULL,		NULL,		NULL,		NULL,
/* E4 */	NULL,		NULL,		NULL,		NULL,
/* E8 */	NULL,		NULL,		NULL,		NULL,
/* EC */	NULL,		NULL,		NULL,		NULL,
/* F0 */	NULL,		NULL,		NULL,		NULL,
/* F4 */	NULL,		NULL,		NULL,		NULL,
/* F8 */	NULL,		NULL,		NULL,		NULL,
/* FC */	NULL,		NULL,		NULL,		NULL,
};

static void
OP_3DNowSuffix (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
  const char *mnemonic;

  FETCH_DATA (the_info, codep + 1);
  /* AMD 3DNow! instructions are specified by an opcode suffix in the
     place where an 8-bit immediate would normally go.  ie. the last
     byte of the instruction.  */
  obufp = obuf + strlen (obuf);
  mnemonic = Suffix3DNow[*codep++ & 0xff];
  if (mnemonic)
    oappend (mnemonic);
  else
    {
      /* Since a variable sized modrm/sib chunk is between the start
	 of the opcode (0x0f0f) and the opcode suffix, we need to do
	 all the modrm processing first, and don't know until now that
	 we have a bad opcode.  This necessitates some cleaning up.  */
      op1out[0] = '\0';
      op2out[0] = '\0';
      BadOp ();
    }
}

static const char *simd_cmp_op[] = {
  "eq",
  "lt",
  "le",
  "unord",
  "neq",
  "nlt",
  "nle",
  "ord"
};

static void
OP_SIMD_Suffix (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
  unsigned int cmp_type;

  FETCH_DATA (the_info, codep + 1);
  obufp = obuf + strlen (obuf);
  cmp_type = *codep++ & 0xff;
  if (cmp_type < 8)
    {
      char suffix1 = 'p', suffix2 = 's';
      used_prefixes |= (prefixes & PREFIX_REPZ);
      if (prefixes & PREFIX_REPZ)
	suffix1 = 's';
      else
	{
	  used_prefixes |= (prefixes & PREFIX_DATA);
	  if (prefixes & PREFIX_DATA)
	    suffix2 = 'd';
	  else
	    {
	      used_prefixes |= (prefixes & PREFIX_REPNZ);
	      if (prefixes & PREFIX_REPNZ)
		suffix1 = 's', suffix2 = 'd';
	    }
	}
      snprintf (scratchbuf, sizeof(scratchbuf), "cmp%s%c%c",
                simd_cmp_op[cmp_type], suffix1, suffix2);
      used_prefixes |= (prefixes & PREFIX_REPZ);
      oappend (scratchbuf);
    }
  else
    {
      /* We have a bad extension byte.  Clean up.  */
      op1out[0] = '\0';
      op2out[0] = '\0';
      BadOp ();
    }
}

static void
SIMD_Fixup (extrachar, sizeflag)
     int extrachar;
     int sizeflag;
{
f0106064:	55                   	push   %ebp
f0106065:	89 e5                	mov    %esp,%ebp
f0106067:	83 ec 08             	sub    $0x8,%esp
  /* Change movlps/movhps to movhlps/movlhps for 2 register operand
     forms of these instructions.  */
  if (mod == 3)
f010606a:	83 3d 74 92 2a f0 03 	cmpl   $0x3,0xf02a9274
f0106071:	75 34                	jne    f01060a7 <SIMD_Fixup+0x43>
    {
      char *p = obuf + strlen (obuf);
f0106073:	c7 04 24 80 91 2a f0 	movl   $0xf02a9180,(%esp)
f010607a:	e8 31 35 00 00       	call   f01095b0 <strlen>
f010607f:	8d 90 80 91 2a f0    	lea    0xf02a9180(%eax),%edx
      *(p + 1) = '\0';
f0106085:	c6 42 01 00          	movb   $0x0,0x1(%edx)
      *p       = *(p - 1);
f0106089:	0f b6 4a ff          	movzbl 0xffffffff(%edx),%ecx
f010608d:	88 88 80 91 2a f0    	mov    %cl,0xf02a9180(%eax)
      *(p - 1) = *(p - 2);
f0106093:	0f b6 42 fe          	movzbl 0xfffffffe(%edx),%eax
f0106097:	88 42 ff             	mov    %al,0xffffffff(%edx)
      *(p - 2) = *(p - 3);
f010609a:	0f b6 42 fd          	movzbl 0xfffffffd(%edx),%eax
f010609e:	88 42 fe             	mov    %al,0xfffffffe(%edx)
      *(p - 3) = extrachar;
f01060a1:	8b 45 08             	mov    0x8(%ebp),%eax
f01060a4:	88 42 fd             	mov    %al,0xfffffffd(%edx)
    }
}
f01060a7:	c9                   	leave  
f01060a8:	c3                   	ret    

f01060a9 <print_operand_value>:
f01060a9:	55                   	push   %ebp
f01060aa:	89 e5                	mov    %esp,%ebp
f01060ac:	57                   	push   %edi
f01060ad:	56                   	push   %esi
f01060ae:	53                   	push   %ebx
f01060af:	83 ec 3c             	sub    $0x3c,%esp
f01060b2:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
f01060b5:	89 55 cc             	mov    %edx,0xffffffcc(%ebp)
f01060b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01060bb:	8b 55 0c             	mov    0xc(%ebp),%edx
f01060be:	83 3d 60 91 2a f0 00 	cmpl   $0x0,0xf02a9160
f01060c5:	0f 84 4a 01 00 00    	je     f0106215 <print_operand_value+0x16c>
f01060cb:	85 c9                	test   %ecx,%ecx
f01060cd:	74 6d                	je     f010613c <print_operand_value+0x93>
f01060cf:	8b 4d d0             	mov    0xffffffd0(%ebp),%ecx
f01060d2:	c6 01 30             	movb   $0x30,(%ecx)
f01060d5:	c6 41 01 78          	movb   $0x78,0x1(%ecx)
f01060d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01060dd:	89 54 24 10          	mov    %edx,0x10(%esp)
f01060e1:	c7 44 24 08 17 c0 10 	movl   $0xf010c017,0x8(%esp)
f01060e8:	f0 
f01060e9:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
f01060f0:	00 
f01060f1:	8d 45 d6             	lea    0xffffffd6(%ebp),%eax
f01060f4:	89 04 24             	mov    %eax,(%esp)
f01060f7:	e8 73 33 00 00       	call   f010946f <snprintf>
f01060fc:	ba 00 00 00 00       	mov    $0x0,%edx
f0106101:	8d 4d d6             	lea    0xffffffd6(%ebp),%ecx
f0106104:	80 3c 0a 30          	cmpb   $0x30,(%edx,%ecx,1)
f0106108:	75 0d                	jne    f0106117 <print_operand_value+0x6e>
f010610a:	8d 42 01             	lea    0x1(%edx),%eax
f010610d:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
f0106111:	74 04                	je     f0106117 <print_operand_value+0x6e>
f0106113:	89 c2                	mov    %eax,%edx
f0106115:	eb ed                	jmp    f0106104 <print_operand_value+0x5b>
f0106117:	8d 44 15 d6          	lea    0xffffffd6(%ebp,%edx,1),%eax
f010611b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010611f:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
f0106122:	83 e8 02             	sub    $0x2,%eax
f0106125:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106129:	8b 45 d0             	mov    0xffffffd0(%ebp),%eax
f010612c:	83 c0 02             	add    $0x2,%eax
f010612f:	89 04 24             	mov    %eax,(%esp)
f0106132:	e8 66 35 00 00       	call   f010969d <pstrcpy>
f0106137:	e9 1b 01 00 00       	jmp    f0106257 <print_operand_value+0x1ae>
f010613c:	89 c3                	mov    %eax,%ebx
f010613e:	89 d6                	mov    %edx,%esi
f0106140:	85 d2                	test   %edx,%edx
f0106142:	79 33                	jns    f0106177 <print_operand_value+0xce>
f0106144:	8b 4d d0             	mov    0xffffffd0(%ebp),%ecx
f0106147:	c6 01 2d             	movb   $0x2d,(%ecx)
f010614a:	83 c1 01             	add    $0x1,%ecx
f010614d:	89 4d d0             	mov    %ecx,0xffffffd0(%ebp)
f0106150:	f7 db                	neg    %ebx
f0106152:	83 d6 00             	adc    $0x0,%esi
f0106155:	f7 de                	neg    %esi
f0106157:	85 f6                	test   %esi,%esi
f0106159:	79 1c                	jns    f0106177 <print_operand_value+0xce>
f010615b:	c7 44 24 08 1b c0 10 	movl   $0xf010c01b,0x8(%esp)
f0106162:	f0 
f0106163:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
f0106166:	89 44 24 04          	mov    %eax,0x4(%esp)
f010616a:	89 0c 24             	mov    %ecx,(%esp)
f010616d:	e8 2b 35 00 00       	call   f010969d <pstrcpy>
f0106172:	e9 e0 00 00 00       	jmp    f0106257 <print_operand_value+0x1ae>
f0106177:	89 f1                	mov    %esi,%ecx
f0106179:	09 d9                	or     %ebx,%ecx
f010617b:	75 1f                	jne    f010619c <print_operand_value+0xf3>
f010617d:	c7 44 24 08 c5 b7 10 	movl   $0xf010b7c5,0x8(%esp)
f0106184:	f0 
f0106185:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
f0106188:	89 44 24 04          	mov    %eax,0x4(%esp)
f010618c:	8b 4d d0             	mov    0xffffffd0(%ebp),%ecx
f010618f:	89 0c 24             	mov    %ecx,(%esp)
f0106192:	e8 06 35 00 00       	call   f010969d <pstrcpy>
f0106197:	e9 bb 00 00 00       	jmp    f0106257 <print_operand_value+0x1ae>
f010619c:	c6 45 f3 00          	movb   $0x0,0xfffffff3(%ebp)
f01061a0:	bf 1c 00 00 00       	mov    $0x1c,%edi
f01061a5:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f01061ac:	00 
f01061ad:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01061b4:	00 
f01061b5:	89 1c 24             	mov    %ebx,(%esp)
f01061b8:	89 74 24 04          	mov    %esi,0x4(%esp)
f01061bc:	e8 8f 41 00 00       	call   f010a350 <__moddi3>
f01061c1:	83 c0 30             	add    $0x30,%eax
f01061c4:	88 44 3d d6          	mov    %al,0xffffffd6(%ebp,%edi,1)
f01061c8:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f01061cf:	00 
f01061d0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01061d7:	00 
f01061d8:	89 1c 24             	mov    %ebx,(%esp)
f01061db:	89 74 24 04          	mov    %esi,0x4(%esp)
f01061df:	e8 cc 3f 00 00       	call   f010a1b0 <__divdi3>
f01061e4:	89 c3                	mov    %eax,%ebx
f01061e6:	89 d6                	mov    %edx,%esi
f01061e8:	83 ef 01             	sub    $0x1,%edi
f01061eb:	89 d0                	mov    %edx,%eax
f01061ed:	09 d8                	or     %ebx,%eax
f01061ef:	75 b4                	jne    f01061a5 <print_operand_value+0xfc>
f01061f1:	8d 55 f3             	lea    0xfffffff3(%ebp),%edx
f01061f4:	b8 1c 00 00 00       	mov    $0x1c,%eax
f01061f9:	29 f8                	sub    %edi,%eax
f01061fb:	29 c2                	sub    %eax,%edx
f01061fd:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106201:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
f0106204:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106208:	8b 45 d0             	mov    0xffffffd0(%ebp),%eax
f010620b:	89 04 24             	mov    %eax,(%esp)
f010620e:	e8 8a 34 00 00       	call   f010969d <pstrcpy>
f0106213:	eb 42                	jmp    f0106257 <print_operand_value+0x1ae>
f0106215:	85 c9                	test   %ecx,%ecx
f0106217:	74 20                	je     f0106239 <print_operand_value+0x190>
f0106219:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010621d:	c7 44 24 08 7d c0 10 	movl   $0xf010c07d,0x8(%esp)
f0106224:	f0 
f0106225:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
f0106228:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010622c:	8b 45 d0             	mov    0xffffffd0(%ebp),%eax
f010622f:	89 04 24             	mov    %eax,(%esp)
f0106232:	e8 38 32 00 00       	call   f010946f <snprintf>
f0106237:	eb 1e                	jmp    f0106257 <print_operand_value+0x1ae>
f0106239:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010623d:	c7 44 24 08 1d 44 11 	movl   $0xf011441d,0x8(%esp)
f0106244:	f0 
f0106245:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
f0106248:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010624c:	8b 45 d0             	mov    0xffffffd0(%ebp),%eax
f010624f:	89 04 24             	mov    %eax,(%esp)
f0106252:	e8 18 32 00 00       	call   f010946f <snprintf>
f0106257:	83 c4 3c             	add    $0x3c,%esp
f010625a:	5b                   	pop    %ebx
f010625b:	5e                   	pop    %esi
f010625c:	5f                   	pop    %edi
f010625d:	5d                   	pop    %ebp
f010625e:	c3                   	ret    

f010625f <oappend>:
f010625f:	55                   	push   %ebp
f0106260:	89 e5                	mov    %esp,%ebp
f0106262:	53                   	push   %ebx
f0106263:	83 ec 14             	sub    $0x14,%esp
f0106266:	89 c3                	mov    %eax,%ebx
f0106268:	89 44 24 04          	mov    %eax,0x4(%esp)
f010626c:	a1 e4 91 2a f0       	mov    0xf02a91e4,%eax
f0106271:	89 04 24             	mov    %eax,(%esp)
f0106274:	e8 88 33 00 00       	call   f0109601 <strcpy>
f0106279:	89 1c 24             	mov    %ebx,(%esp)
f010627c:	e8 2f 33 00 00       	call   f01095b0 <strlen>
f0106281:	01 05 e4 91 2a f0    	add    %eax,0xf02a91e4
f0106287:	83 c4 14             	add    $0x14,%esp
f010628a:	5b                   	pop    %ebx
f010628b:	5d                   	pop    %ebp
f010628c:	c3                   	ret    

f010628d <BadOp>:

static void
BadOp (void)
{
f010628d:	55                   	push   %ebp
f010628e:	89 e5                	mov    %esp,%ebp
f0106290:	83 ec 08             	sub    $0x8,%esp
  /* Throw away prefixes and 1st. opcode byte.  */
  codep = insn_codep + 1;
f0106293:	a1 68 92 2a f0       	mov    0xf02a9268,%eax
f0106298:	83 c0 01             	add    $0x1,%eax
f010629b:	a3 6c 92 2a f0       	mov    %eax,0xf02a926c
  oappend ("(bad)");
f01062a0:	b8 2f c0 10 f0       	mov    $0xf010c02f,%eax
f01062a5:	e8 b5 ff ff ff       	call   f010625f <oappend>
}
f01062aa:	c9                   	leave  
f01062ab:	c3                   	ret    

f01062ac <OP_SIMD_Suffix>:
f01062ac:	55                   	push   %ebp
f01062ad:	89 e5                	mov    %esp,%ebp
f01062af:	83 ec 28             	sub    $0x28,%esp
f01062b2:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
f01062b5:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
f01062b8:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
f01062bb:	8b 15 6c 92 2a f0    	mov    0xf02a926c,%edx
f01062c1:	83 c2 01             	add    $0x1,%edx
f01062c4:	8b 0d 70 92 2a f0    	mov    0xf02a9270,%ecx
f01062ca:	8b 41 20             	mov    0x20(%ecx),%eax
f01062cd:	3b 10                	cmp    (%eax),%edx
f01062cf:	76 07                	jbe    f01062d8 <OP_SIMD_Suffix+0x2c>
f01062d1:	89 c8                	mov    %ecx,%eax
f01062d3:	e8 08 f4 ff ff       	call   f01056e0 <fetch_data>
f01062d8:	c7 04 24 80 91 2a f0 	movl   $0xf02a9180,(%esp)
f01062df:	e8 cc 32 00 00       	call   f01095b0 <strlen>
f01062e4:	05 80 91 2a f0       	add    $0xf02a9180,%eax
f01062e9:	a3 e4 91 2a f0       	mov    %eax,0xf02a91e4
f01062ee:	a1 6c 92 2a f0       	mov    0xf02a926c,%eax
f01062f3:	0f b6 38             	movzbl (%eax),%edi
f01062f6:	83 c0 01             	add    $0x1,%eax
f01062f9:	a3 6c 92 2a f0       	mov    %eax,0xf02a926c
f01062fe:	83 ff 07             	cmp    $0x7,%edi
f0106301:	0f 87 b9 00 00 00    	ja     f01063c0 <OP_SIMD_Suffix+0x114>
f0106307:	8b 15 64 91 2a f0    	mov    0xf02a9164,%edx
f010630d:	89 d0                	mov    %edx,%eax
f010630f:	83 e0 01             	and    $0x1,%eax
f0106312:	89 c1                	mov    %eax,%ecx
f0106314:	0b 0d 70 91 2a f0    	or     0xf02a9170,%ecx
f010631a:	89 0d 70 91 2a f0    	mov    %ecx,0xf02a9170
f0106320:	be 73 00 00 00       	mov    $0x73,%esi
f0106325:	bb 73 00 00 00       	mov    $0x73,%ebx
f010632a:	85 c0                	test   %eax,%eax
f010632c:	75 41                	jne    f010636f <OP_SIMD_Suffix+0xc3>
f010632e:	89 d0                	mov    %edx,%eax
f0106330:	25 00 02 00 00       	and    $0x200,%eax
f0106335:	09 c1                	or     %eax,%ecx
f0106337:	89 0d 70 91 2a f0    	mov    %ecx,0xf02a9170
f010633d:	be 70 00 00 00       	mov    $0x70,%esi
f0106342:	bb 64 00 00 00       	mov    $0x64,%ebx
f0106347:	85 c0                	test   %eax,%eax
f0106349:	75 24                	jne    f010636f <OP_SIMD_Suffix+0xc3>
f010634b:	83 e2 02             	and    $0x2,%edx
f010634e:	89 c8                	mov    %ecx,%eax
f0106350:	09 d0                	or     %edx,%eax
f0106352:	a3 70 91 2a f0       	mov    %eax,0xf02a9170
f0106357:	be 73 00 00 00       	mov    $0x73,%esi
f010635c:	bb 64 00 00 00       	mov    $0x64,%ebx
f0106361:	85 d2                	test   %edx,%edx
f0106363:	75 0a                	jne    f010636f <OP_SIMD_Suffix+0xc3>
f0106365:	be 70 00 00 00       	mov    $0x70,%esi
f010636a:	bb 73 00 00 00       	mov    $0x73,%ebx
f010636f:	0f be c3             	movsbl %bl,%eax
f0106372:	89 44 24 14          	mov    %eax,0x14(%esp)
f0106376:	89 f2                	mov    %esi,%edx
f0106378:	0f be c2             	movsbl %dl,%eax
f010637b:	89 44 24 10          	mov    %eax,0x10(%esp)
f010637f:	8b 04 bd 80 36 11 f0 	mov    0xf0113680(,%edi,4),%eax
f0106386:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010638a:	c7 44 24 08 35 c0 10 	movl   $0xf010c035,0x8(%esp)
f0106391:	f0 
f0106392:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0106399:	00 
f010639a:	c7 04 24 00 92 2a f0 	movl   $0xf02a9200,(%esp)
f01063a1:	e8 c9 30 00 00       	call   f010946f <snprintf>
f01063a6:	a1 64 91 2a f0       	mov    0xf02a9164,%eax
f01063ab:	83 e0 01             	and    $0x1,%eax
f01063ae:	09 05 70 91 2a f0    	or     %eax,0xf02a9170
f01063b4:	b8 00 92 2a f0       	mov    $0xf02a9200,%eax
f01063b9:	e8 a1 fe ff ff       	call   f010625f <oappend>
f01063be:	eb 13                	jmp    f01063d3 <OP_SIMD_Suffix+0x127>
f01063c0:	c6 05 a0 92 2a f0 00 	movb   $0x0,0xf02a92a0
f01063c7:	c6 05 20 93 2a f0 00 	movb   $0x0,0xf02a9320
f01063ce:	e8 ba fe ff ff       	call   f010628d <BadOp>
f01063d3:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
f01063d6:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
f01063d9:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
f01063dc:	89 ec                	mov    %ebp,%esp
f01063de:	5d                   	pop    %ebp
f01063df:	c3                   	ret    

f01063e0 <OP_3DNowSuffix>:
f01063e0:	55                   	push   %ebp
f01063e1:	89 e5                	mov    %esp,%ebp
f01063e3:	83 ec 08             	sub    $0x8,%esp
f01063e6:	8b 15 6c 92 2a f0    	mov    0xf02a926c,%edx
f01063ec:	83 c2 01             	add    $0x1,%edx
f01063ef:	8b 0d 70 92 2a f0    	mov    0xf02a9270,%ecx
f01063f5:	8b 41 20             	mov    0x20(%ecx),%eax
f01063f8:	3b 10                	cmp    (%eax),%edx
f01063fa:	76 07                	jbe    f0106403 <OP_3DNowSuffix+0x23>
f01063fc:	89 c8                	mov    %ecx,%eax
f01063fe:	e8 dd f2 ff ff       	call   f01056e0 <fetch_data>
f0106403:	c7 04 24 80 91 2a f0 	movl   $0xf02a9180,(%esp)
f010640a:	e8 a1 31 00 00       	call   f01095b0 <strlen>
f010640f:	05 80 91 2a f0       	add    $0xf02a9180,%eax
f0106414:	a3 e4 91 2a f0       	mov    %eax,0xf02a91e4
f0106419:	a1 6c 92 2a f0       	mov    0xf02a926c,%eax
f010641e:	0f b6 10             	movzbl (%eax),%edx
f0106421:	8b 14 95 a0 36 11 f0 	mov    0xf01136a0(,%edx,4),%edx
f0106428:	83 c0 01             	add    $0x1,%eax
f010642b:	a3 6c 92 2a f0       	mov    %eax,0xf02a926c
f0106430:	85 d2                	test   %edx,%edx
f0106432:	74 09                	je     f010643d <OP_3DNowSuffix+0x5d>
f0106434:	89 d0                	mov    %edx,%eax
f0106436:	e8 24 fe ff ff       	call   f010625f <oappend>
f010643b:	eb 13                	jmp    f0106450 <OP_3DNowSuffix+0x70>
f010643d:	c6 05 a0 92 2a f0 00 	movb   $0x0,0xf02a92a0
f0106444:	c6 05 20 93 2a f0 00 	movb   $0x0,0xf02a9320
f010644b:	e8 3d fe ff ff       	call   f010628d <BadOp>
f0106450:	c9                   	leave  
f0106451:	c3                   	ret    

f0106452 <OP_XMM>:
f0106452:	55                   	push   %ebp
f0106453:	89 e5                	mov    %esp,%ebp
f0106455:	83 ec 18             	sub    $0x18,%esp
f0106458:	b8 00 00 00 00       	mov    $0x0,%eax
f010645d:	f6 05 68 91 2a f0 04 	testb  $0x4,0xf02a9168
f0106464:	74 09                	je     f010646f <OP_XMM+0x1d>
f0106466:	83 0d 6c 91 2a f0 44 	orl    $0x44,0xf02a916c
f010646d:	b0 08                	mov    $0x8,%al
f010646f:	03 05 7c 92 2a f0    	add    0xf02a927c,%eax
f0106475:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106479:	c7 44 24 08 3f c0 10 	movl   $0xf010c03f,0x8(%esp)
f0106480:	f0 
f0106481:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0106488:	00 
f0106489:	c7 04 24 00 92 2a f0 	movl   $0xf02a9200,(%esp)
f0106490:	e8 da 2f 00 00       	call   f010946f <snprintf>
f0106495:	0f be 05 50 94 2a f0 	movsbl 0xf02a9450,%eax
f010649c:	05 00 92 2a f0       	add    $0xf02a9200,%eax
f01064a1:	e8 b9 fd ff ff       	call   f010625f <oappend>
f01064a6:	c9                   	leave  
f01064a7:	c3                   	ret    

f01064a8 <OP_MMX>:
f01064a8:	55                   	push   %ebp
f01064a9:	89 e5                	mov    %esp,%ebp
f01064ab:	83 ec 18             	sub    $0x18,%esp
f01064ae:	ba 00 00 00 00       	mov    $0x0,%edx
f01064b3:	f6 05 68 91 2a f0 04 	testb  $0x4,0xf02a9168
f01064ba:	74 09                	je     f01064c5 <OP_MMX+0x1d>
f01064bc:	83 0d 6c 91 2a f0 44 	orl    $0x44,0xf02a916c
f01064c3:	b2 08                	mov    $0x8,%dl
f01064c5:	a1 64 91 2a f0       	mov    0xf02a9164,%eax
f01064ca:	25 00 02 00 00       	and    $0x200,%eax
f01064cf:	09 05 70 91 2a f0    	or     %eax,0xf02a9170
f01064d5:	85 c0                	test   %eax,%eax
f01064d7:	74 2a                	je     f0106503 <OP_MMX+0x5b>
f01064d9:	89 d0                	mov    %edx,%eax
f01064db:	03 05 7c 92 2a f0    	add    0xf02a927c,%eax
f01064e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01064e5:	c7 44 24 08 3f c0 10 	movl   $0xf010c03f,0x8(%esp)
f01064ec:	f0 
f01064ed:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f01064f4:	00 
f01064f5:	c7 04 24 00 92 2a f0 	movl   $0xf02a9200,(%esp)
f01064fc:	e8 6e 2f 00 00       	call   f010946f <snprintf>
f0106501:	eb 28                	jmp    f010652b <OP_MMX+0x83>
f0106503:	89 d0                	mov    %edx,%eax
f0106505:	03 05 7c 92 2a f0    	add    0xf02a927c,%eax
f010650b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010650f:	c7 44 24 08 47 c0 10 	movl   $0xf010c047,0x8(%esp)
f0106516:	f0 
f0106517:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f010651e:	00 
f010651f:	c7 04 24 00 92 2a f0 	movl   $0xf02a9200,(%esp)
f0106526:	e8 44 2f 00 00       	call   f010946f <snprintf>
f010652b:	0f be 05 50 94 2a f0 	movsbl 0xf02a9450,%eax
f0106532:	05 00 92 2a f0       	add    $0xf02a9200,%eax
f0106537:	e8 23 fd ff ff       	call   f010625f <oappend>
f010653c:	c9                   	leave  
f010653d:	c3                   	ret    

f010653e <OP_T>:
f010653e:	55                   	push   %ebp
f010653f:	89 e5                	mov    %esp,%ebp
f0106541:	83 ec 18             	sub    $0x18,%esp
f0106544:	a1 7c 92 2a f0       	mov    0xf02a927c,%eax
f0106549:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010654d:	c7 44 24 08 4e c0 10 	movl   $0xf010c04e,0x8(%esp)
f0106554:	f0 
f0106555:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f010655c:	00 
f010655d:	c7 04 24 00 92 2a f0 	movl   $0xf02a9200,(%esp)
f0106564:	e8 06 2f 00 00       	call   f010946f <snprintf>
f0106569:	0f be 05 50 94 2a f0 	movsbl 0xf02a9450,%eax
f0106570:	05 00 92 2a f0       	add    $0xf02a9200,%eax
f0106575:	e8 e5 fc ff ff       	call   f010625f <oappend>
f010657a:	c9                   	leave  
f010657b:	c3                   	ret    

f010657c <OP_D>:
f010657c:	55                   	push   %ebp
f010657d:	89 e5                	mov    %esp,%ebp
f010657f:	83 ec 18             	sub    $0x18,%esp
f0106582:	b8 00 00 00 00       	mov    $0x0,%eax
f0106587:	f6 05 68 91 2a f0 04 	testb  $0x4,0xf02a9168
f010658e:	74 09                	je     f0106599 <OP_D+0x1d>
f0106590:	83 0d 6c 91 2a f0 44 	orl    $0x44,0xf02a916c
f0106597:	b0 08                	mov    $0x8,%al
f0106599:	80 3d 50 94 2a f0 00 	cmpb   $0x0,0xf02a9450
f01065a0:	74 28                	je     f01065ca <OP_D+0x4e>
f01065a2:	03 05 7c 92 2a f0    	add    0xf02a927c,%eax
f01065a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01065ac:	c7 44 24 08 57 c0 10 	movl   $0xf010c057,0x8(%esp)
f01065b3:	f0 
f01065b4:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f01065bb:	00 
f01065bc:	c7 04 24 00 92 2a f0 	movl   $0xf02a9200,(%esp)
f01065c3:	e8 a7 2e 00 00       	call   f010946f <snprintf>
f01065c8:	eb 26                	jmp    f01065f0 <OP_D+0x74>
f01065ca:	03 05 7c 92 2a f0    	add    0xf02a927c,%eax
f01065d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01065d4:	c7 44 24 08 55 c0 10 	movl   $0xf010c055,0x8(%esp)
f01065db:	f0 
f01065dc:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f01065e3:	00 
f01065e4:	c7 04 24 00 92 2a f0 	movl   $0xf02a9200,(%esp)
f01065eb:	e8 7f 2e 00 00       	call   f010946f <snprintf>
f01065f0:	b8 00 92 2a f0       	mov    $0xf02a9200,%eax
f01065f5:	e8 65 fc ff ff       	call   f010625f <oappend>
f01065fa:	c9                   	leave  
f01065fb:	c3                   	ret    

f01065fc <OP_C>:
f01065fc:	55                   	push   %ebp
f01065fd:	89 e5                	mov    %esp,%ebp
f01065ff:	83 ec 18             	sub    $0x18,%esp
f0106602:	b8 00 00 00 00       	mov    $0x0,%eax
f0106607:	f6 05 68 91 2a f0 04 	testb  $0x4,0xf02a9168
f010660e:	74 09                	je     f0106619 <OP_C+0x1d>
f0106610:	83 0d 6c 91 2a f0 44 	orl    $0x44,0xf02a916c
f0106617:	b0 08                	mov    $0x8,%al
f0106619:	03 05 7c 92 2a f0    	add    0xf02a927c,%eax
f010661f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106623:	c7 44 24 08 5c c0 10 	movl   $0xf010c05c,0x8(%esp)
f010662a:	f0 
f010662b:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0106632:	00 
f0106633:	c7 04 24 00 92 2a f0 	movl   $0xf02a9200,(%esp)
f010663a:	e8 30 2e 00 00       	call   f010946f <snprintf>
f010663f:	0f be 05 50 94 2a f0 	movsbl 0xf02a9450,%eax
f0106646:	05 00 92 2a f0       	add    $0xf02a9200,%eax
f010664b:	e8 0f fc ff ff       	call   f010625f <oappend>
f0106650:	c9                   	leave  
f0106651:	c3                   	ret    

f0106652 <ptr_reg>:
f0106652:	55                   	push   %ebp
f0106653:	89 e5                	mov    %esp,%ebp
f0106655:	56                   	push   %esi
f0106656:	53                   	push   %ebx
f0106657:	89 c3                	mov    %eax,%ebx
f0106659:	89 d6                	mov    %edx,%esi
f010665b:	80 3d 50 94 2a f0 00 	cmpb   $0x0,0xf02a9450
f0106662:	74 0c                	je     f0106670 <ptr_reg+0x1e>
f0106664:	b8 63 c0 10 f0       	mov    $0xf010c063,%eax
f0106669:	e8 f1 fb ff ff       	call   f010625f <oappend>
f010666e:	eb 0a                	jmp    f010667a <ptr_reg+0x28>
f0106670:	b8 65 c0 10 f0       	mov    $0xf010c065,%eax
f0106675:	e8 e5 fb ff ff       	call   f010625f <oappend>
f010667a:	f6 05 68 91 2a f0 08 	testb  $0x8,0xf02a9168
f0106681:	74 6b                	je     f01066ee <ptr_reg+0x9c>
f0106683:	83 0d 6c 91 2a f0 48 	orl    $0x48,0xf02a916c
f010668a:	f7 c6 02 00 00 00    	test   $0x2,%esi
f0106690:	75 0e                	jne    f01066a0 <ptr_reg+0x4e>
f0106692:	a1 88 92 2a f0       	mov    0xf02a9288,%eax
f0106697:	8b 84 98 50 fe ff ff 	mov    0xfffffe50(%eax,%ebx,4),%eax
f010669e:	eb 28                	jmp    f01066c8 <ptr_reg+0x76>
f01066a0:	a1 84 92 2a f0       	mov    0xf02a9284,%eax
f01066a5:	8b 84 98 50 fe ff ff 	mov    0xfffffe50(%eax,%ebx,4),%eax
f01066ac:	eb 1a                	jmp    f01066c8 <ptr_reg+0x76>
f01066ae:	a1 88 92 2a f0       	mov    0xf02a9288,%eax
f01066b3:	8b 84 98 50 fe ff ff 	mov    0xfffffe50(%eax,%ebx,4),%eax
f01066ba:	eb 0c                	jmp    f01066c8 <ptr_reg+0x76>
f01066bc:	a1 8c 92 2a f0       	mov    0xf02a928c,%eax
f01066c1:	8b 84 98 50 fe ff ff 	mov    0xfffffe50(%eax,%ebx,4),%eax
f01066c8:	e8 92 fb ff ff       	call   f010625f <oappend>
f01066cd:	80 3d 50 94 2a f0 00 	cmpb   $0x0,0xf02a9450
f01066d4:	74 0c                	je     f01066e2 <ptr_reg+0x90>
f01066d6:	b8 8c b9 10 f0       	mov    $0xf010b98c,%eax
f01066db:	e8 7f fb ff ff       	call   f010625f <oappend>
f01066e0:	eb 16                	jmp    f01066f8 <ptr_reg+0xa6>
f01066e2:	b8 69 bc 10 f0       	mov    $0xf010bc69,%eax
f01066e7:	e8 73 fb ff ff       	call   f010625f <oappend>
f01066ec:	eb 0a                	jmp    f01066f8 <ptr_reg+0xa6>
f01066ee:	f7 c6 02 00 00 00    	test   $0x2,%esi
f01066f4:	75 b8                	jne    f01066ae <ptr_reg+0x5c>
f01066f6:	eb c4                	jmp    f01066bc <ptr_reg+0x6a>
f01066f8:	5b                   	pop    %ebx
f01066f9:	5e                   	pop    %esi
f01066fa:	5d                   	pop    %ebp
f01066fb:	90                   	nop    
f01066fc:	8d 74 26 00          	lea    0x0(%esi),%esi
f0106700:	c3                   	ret    

f0106701 <OP_ESreg>:
f0106701:	55                   	push   %ebp
f0106702:	89 e5                	mov    %esp,%ebp
f0106704:	83 ec 08             	sub    $0x8,%esp
f0106707:	0f be 05 50 94 2a f0 	movsbl 0xf02a9450,%eax
f010670e:	05 67 c0 10 f0       	add    $0xf010c067,%eax
f0106713:	e8 47 fb ff ff       	call   f010625f <oappend>
f0106718:	8b 55 0c             	mov    0xc(%ebp),%edx
f010671b:	8b 45 08             	mov    0x8(%ebp),%eax
f010671e:	e8 2f ff ff ff       	call   f0106652 <ptr_reg>
f0106723:	c9                   	leave  
f0106724:	c3                   	ret    

f0106725 <OP_DIR>:
f0106725:	55                   	push   %ebp
f0106726:	89 e5                	mov    %esp,%ebp
f0106728:	53                   	push   %ebx
f0106729:	83 ec 14             	sub    $0x14,%esp
f010672c:	f6 45 0c 01          	testb  $0x1,0xc(%ebp)
f0106730:	74 10                	je     f0106742 <OP_DIR+0x1d>
f0106732:	e8 0b f2 ff ff       	call   f0105942 <get32>
f0106737:	89 c3                	mov    %eax,%ebx
f0106739:	e8 03 f3 ff ff       	call   f0105a41 <get16>
f010673e:	89 c2                	mov    %eax,%edx
f0106740:	eb 0e                	jmp    f0106750 <OP_DIR+0x2b>
f0106742:	e8 fa f2 ff ff       	call   f0105a41 <get16>
f0106747:	89 c3                	mov    %eax,%ebx
f0106749:	e8 f3 f2 ff ff       	call   f0105a41 <get16>
f010674e:	89 c2                	mov    %eax,%edx
f0106750:	a1 64 91 2a f0       	mov    0xf02a9164,%eax
f0106755:	25 00 02 00 00       	and    $0x200,%eax
f010675a:	09 05 70 91 2a f0    	or     %eax,0xf02a9170
f0106760:	80 3d 50 94 2a f0 00 	cmpb   $0x0,0xf02a9450
f0106767:	74 26                	je     f010678f <OP_DIR+0x6a>
f0106769:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f010676d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106771:	c7 44 24 08 6c c0 10 	movl   $0xf010c06c,0x8(%esp)
f0106778:	f0 
f0106779:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0106780:	00 
f0106781:	c7 04 24 00 92 2a f0 	movl   $0xf02a9200,(%esp)
f0106788:	e8 e2 2c 00 00       	call   f010946f <snprintf>
f010678d:	eb 24                	jmp    f01067b3 <OP_DIR+0x8e>
f010678f:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106793:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106797:	c7 44 24 08 76 c0 10 	movl   $0xf010c076,0x8(%esp)
f010679e:	f0 
f010679f:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f01067a6:	00 
f01067a7:	c7 04 24 00 92 2a f0 	movl   $0xf02a9200,(%esp)
f01067ae:	e8 bc 2c 00 00       	call   f010946f <snprintf>
f01067b3:	b8 00 92 2a f0       	mov    $0xf02a9200,%eax
f01067b8:	e8 a2 fa ff ff       	call   f010625f <oappend>
f01067bd:	83 c4 14             	add    $0x14,%esp
f01067c0:	5b                   	pop    %ebx
f01067c1:	5d                   	pop    %ebp
f01067c2:	c3                   	ret    

f01067c3 <OP_SEG>:
f01067c3:	55                   	push   %ebp
f01067c4:	89 e5                	mov    %esp,%ebp
f01067c6:	83 ec 08             	sub    $0x8,%esp
f01067c9:	a1 7c 92 2a f0       	mov    0xf02a927c,%eax
f01067ce:	8b 15 98 92 2a f0    	mov    0xf02a9298,%edx
f01067d4:	8b 04 82             	mov    (%edx,%eax,4),%eax
f01067d7:	e8 83 fa ff ff       	call   f010625f <oappend>
f01067dc:	c9                   	leave  
f01067dd:	c3                   	ret    

f01067de <OP_J>:
f01067de:	55                   	push   %ebp
f01067df:	89 e5                	mov    %esp,%ebp
f01067e1:	56                   	push   %esi
f01067e2:	53                   	push   %ebx
f01067e3:	83 ec 10             	sub    $0x10,%esp
f01067e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01067e9:	83 f8 01             	cmp    $0x1,%eax
f01067ec:	74 0b                	je     f01067f9 <OP_J+0x1b>
f01067ee:	83 f8 02             	cmp    $0x2,%eax
f01067f1:	0f 85 9e 00 00 00    	jne    f0106895 <OP_J+0xb7>
f01067f7:	eb 5d                	jmp    f0106856 <OP_J+0x78>
f01067f9:	8b 15 6c 92 2a f0    	mov    0xf02a926c,%edx
f01067ff:	83 c2 01             	add    $0x1,%edx
f0106802:	8b 0d 70 92 2a f0    	mov    0xf02a9270,%ecx
f0106808:	8b 41 20             	mov    0x20(%ecx),%eax
f010680b:	3b 10                	cmp    (%eax),%edx
f010680d:	76 07                	jbe    f0106816 <OP_J+0x38>
f010680f:	89 c8                	mov    %ecx,%eax
f0106811:	e8 ca ee ff ff       	call   f01056e0 <fetch_data>
f0106816:	a1 6c 92 2a f0       	mov    0xf02a926c,%eax
f010681b:	0f b6 08             	movzbl (%eax),%ecx
f010681e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106823:	83 c0 01             	add    $0x1,%eax
f0106826:	a3 6c 92 2a f0       	mov    %eax,0xf02a926c
f010682b:	89 c8                	mov    %ecx,%eax
f010682d:	25 80 00 00 00       	and    $0x80,%eax
f0106832:	ba 00 00 00 00       	mov    $0x0,%edx
f0106837:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
f010683e:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,0xfffffff4(%ebp)
f0106845:	89 d6                	mov    %edx,%esi
f0106847:	09 c6                	or     %eax,%esi
f0106849:	74 56                	je     f01068a1 <OP_J+0xc3>
f010684b:	81 c1 00 ff ff ff    	add    $0xffffff00,%ecx
f0106851:	83 d3 ff             	adc    $0xffffffff,%ebx
f0106854:	eb 4b                	jmp    f01068a1 <OP_J+0xc3>
f0106856:	f6 45 0c 01          	testb  $0x1,0xc(%ebp)
f010685a:	74 1d                	je     f0106879 <OP_J+0x9b>
f010685c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0106860:	e8 56 f1 ff ff       	call   f01059bb <get32s>
f0106865:	89 c1                	mov    %eax,%ecx
f0106867:	89 d3                	mov    %edx,%ebx
f0106869:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
f0106870:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,0xfffffff4(%ebp)
f0106877:	eb 28                	jmp    f01068a1 <OP_J+0xc3>
f0106879:	e8 c3 f1 ff ff       	call   f0105a41 <get16>
f010687e:	89 c1                	mov    %eax,%ecx
f0106880:	89 c3                	mov    %eax,%ebx
f0106882:	c1 fb 1f             	sar    $0x1f,%ebx
f0106885:	c7 45 f0 ff ff 00 00 	movl   $0xffff,0xfffffff0(%ebp)
f010688c:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
f0106893:	eb 0c                	jmp    f01068a1 <OP_J+0xc3>
f0106895:	b8 82 c0 10 f0       	mov    $0xf010c082,%eax
f010689a:	e8 c0 f9 ff ff       	call   f010625f <oappend>
f010689f:	eb 57                	jmp    f01068f8 <OP_J+0x11a>
f01068a1:	a1 6c 92 2a f0       	mov    0xf02a926c,%eax
f01068a6:	03 05 48 94 2a f0    	add    0xf02a9448,%eax
f01068ac:	2b 05 64 92 2a f0    	sub    0xf02a9264,%eax
f01068b2:	89 c2                	mov    %eax,%edx
f01068b4:	c1 fa 1f             	sar    $0x1f,%edx
f01068b7:	89 de                	mov    %ebx,%esi
f01068b9:	89 cb                	mov    %ecx,%ebx
f01068bb:	01 c3                	add    %eax,%ebx
f01068bd:	11 d6                	adc    %edx,%esi
f01068bf:	23 5d f0             	and    0xfffffff0(%ebp),%ebx
f01068c2:	23 75 f4             	and    0xfffffff4(%ebp),%esi
f01068c5:	b9 00 00 00 00       	mov    $0x0,%ecx
f01068ca:	89 d8                	mov    %ebx,%eax
f01068cc:	89 f2                	mov    %esi,%edx
f01068ce:	e8 ae f1 ff ff       	call   f0105a81 <set_op>
f01068d3:	89 1c 24             	mov    %ebx,(%esp)
f01068d6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01068da:	b9 01 00 00 00       	mov    $0x1,%ecx
f01068df:	ba 64 00 00 00       	mov    $0x64,%edx
f01068e4:	b8 00 92 2a f0       	mov    $0xf02a9200,%eax
f01068e9:	e8 bb f7 ff ff       	call   f01060a9 <print_operand_value>
f01068ee:	b8 00 92 2a f0       	mov    $0xf02a9200,%eax
f01068f3:	e8 67 f9 ff ff       	call   f010625f <oappend>
f01068f8:	83 c4 10             	add    $0x10,%esp
f01068fb:	5b                   	pop    %ebx
f01068fc:	5e                   	pop    %esi
f01068fd:	5d                   	pop    %ebp
f01068fe:	c3                   	ret    

f01068ff <OP_sI>:
f01068ff:	55                   	push   %ebp
f0106900:	89 e5                	mov    %esp,%ebp
f0106902:	56                   	push   %esi
f0106903:	53                   	push   %ebx
f0106904:	83 ec 10             	sub    $0x10,%esp
f0106907:	8b 45 08             	mov    0x8(%ebp),%eax
f010690a:	83 f8 02             	cmp    $0x2,%eax
f010690d:	74 68                	je     f0106977 <OP_sI+0x78>
f010690f:	83 f8 03             	cmp    $0x3,%eax
f0106912:	0f 84 c0 00 00 00    	je     f01069d8 <OP_sI+0xd9>
f0106918:	83 f8 01             	cmp    $0x1,%eax
f010691b:	0f 85 de 00 00 00    	jne    f01069ff <OP_sI+0x100>
f0106921:	8b 15 6c 92 2a f0    	mov    0xf02a926c,%edx
f0106927:	83 c2 01             	add    $0x1,%edx
f010692a:	8b 0d 70 92 2a f0    	mov    0xf02a9270,%ecx
f0106930:	8b 41 20             	mov    0x20(%ecx),%eax
f0106933:	3b 10                	cmp    (%eax),%edx
f0106935:	76 07                	jbe    f010693e <OP_sI+0x3f>
f0106937:	89 c8                	mov    %ecx,%eax
f0106939:	e8 a2 ed ff ff       	call   f01056e0 <fetch_data>
f010693e:	a1 6c 92 2a f0       	mov    0xf02a926c,%eax
f0106943:	0f b6 08             	movzbl (%eax),%ecx
f0106946:	bb 00 00 00 00       	mov    $0x0,%ebx
f010694b:	83 c0 01             	add    $0x1,%eax
f010694e:	a3 6c 92 2a f0       	mov    %eax,0xf02a926c
f0106953:	89 c8                	mov    %ecx,%eax
f0106955:	25 80 00 00 00       	and    $0x80,%eax
f010695a:	ba 00 00 00 00       	mov    $0x0,%edx
f010695f:	89 d6                	mov    %edx,%esi
f0106961:	09 c6                	or     %eax,%esi
f0106963:	0f 84 a2 00 00 00    	je     f0106a0b <OP_sI+0x10c>
f0106969:	81 c1 00 ff ff ff    	add    $0xffffff00,%ecx
f010696f:	83 d3 ff             	adc    $0xffffffff,%ebx
f0106972:	e9 94 00 00 00       	jmp    f0106a0b <OP_sI+0x10c>
f0106977:	f6 05 68 91 2a f0 08 	testb  $0x8,0xf02a9168
f010697e:	0f 84 bc 00 00 00    	je     f0106a40 <OP_sI+0x141>
f0106984:	83 0d 6c 91 2a f0 48 	orl    $0x48,0xf02a916c
f010698b:	e8 2b f0 ff ff       	call   f01059bb <get32s>
f0106990:	89 c1                	mov    %eax,%ecx
f0106992:	89 d3                	mov    %edx,%ebx
f0106994:	eb 30                	jmp    f01069c6 <OP_sI+0xc7>
f0106996:	e8 20 f0 ff ff       	call   f01059bb <get32s>
f010699b:	89 c1                	mov    %eax,%ecx
f010699d:	89 d3                	mov    %edx,%ebx
f010699f:	eb 25                	jmp    f01069c6 <OP_sI+0xc7>
f01069a1:	e8 9b f0 ff ff       	call   f0105a41 <get16>
f01069a6:	89 c1                	mov    %eax,%ecx
f01069a8:	89 c3                	mov    %eax,%ebx
f01069aa:	c1 fb 1f             	sar    $0x1f,%ebx
f01069ad:	25 00 80 00 00       	and    $0x8000,%eax
f01069b2:	ba 00 00 00 00       	mov    $0x0,%edx
f01069b7:	89 d6                	mov    %edx,%esi
f01069b9:	09 c6                	or     %eax,%esi
f01069bb:	74 09                	je     f01069c6 <OP_sI+0xc7>
f01069bd:	81 c1 00 00 ff ff    	add    $0xffff0000,%ecx
f01069c3:	83 d3 ff             	adc    $0xffffffff,%ebx
f01069c6:	a1 64 91 2a f0       	mov    0xf02a9164,%eax
f01069cb:	25 00 02 00 00       	and    $0x200,%eax
f01069d0:	09 05 70 91 2a f0    	or     %eax,0xf02a9170
f01069d6:	eb 33                	jmp    f0106a0b <OP_sI+0x10c>
f01069d8:	e8 64 f0 ff ff       	call   f0105a41 <get16>
f01069dd:	89 c1                	mov    %eax,%ecx
f01069df:	89 c3                	mov    %eax,%ebx
f01069e1:	c1 fb 1f             	sar    $0x1f,%ebx
f01069e4:	25 00 80 00 00       	and    $0x8000,%eax
f01069e9:	ba 00 00 00 00       	mov    $0x0,%edx
f01069ee:	89 d6                	mov    %edx,%esi
f01069f0:	09 c6                	or     %eax,%esi
f01069f2:	74 17                	je     f0106a0b <OP_sI+0x10c>
f01069f4:	81 c1 00 00 ff ff    	add    $0xffff0000,%ecx
f01069fa:	83 d3 ff             	adc    $0xffffffff,%ebx
f01069fd:	eb 0c                	jmp    f0106a0b <OP_sI+0x10c>
f01069ff:	b8 82 c0 10 f0       	mov    $0xf010c082,%eax
f0106a04:	e8 56 f8 ff ff       	call   f010625f <oappend>
f0106a09:	eb 4a                	jmp    f0106a55 <OP_sI+0x156>
f0106a0b:	c6 05 00 92 2a f0 24 	movb   $0x24,0xf02a9200
f0106a12:	89 0c 24             	mov    %ecx,(%esp)
f0106a15:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106a19:	b9 01 00 00 00       	mov    $0x1,%ecx
f0106a1e:	ba 63 00 00 00       	mov    $0x63,%edx
f0106a23:	b8 01 92 2a f0       	mov    $0xf02a9201,%eax
f0106a28:	e8 7c f6 ff ff       	call   f01060a9 <print_operand_value>
f0106a2d:	0f be 05 50 94 2a f0 	movsbl 0xf02a9450,%eax
f0106a34:	05 00 92 2a f0       	add    $0xf02a9200,%eax
f0106a39:	e8 21 f8 ff ff       	call   f010625f <oappend>
f0106a3e:	eb 15                	jmp    f0106a55 <OP_sI+0x156>
f0106a40:	f6 45 0c 01          	testb  $0x1,0xc(%ebp)
f0106a44:	0f 85 4c ff ff ff    	jne    f0106996 <OP_sI+0x97>
f0106a4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106a50:	e9 4c ff ff ff       	jmp    f01069a1 <OP_sI+0xa2>
f0106a55:	83 c4 10             	add    $0x10,%esp
f0106a58:	5b                   	pop    %ebx
f0106a59:	5e                   	pop    %esi
f0106a5a:	5d                   	pop    %ebp
f0106a5b:	c3                   	ret    

f0106a5c <OP_I>:
f0106a5c:	55                   	push   %ebp
f0106a5d:	89 e5                	mov    %esp,%ebp
f0106a5f:	83 ec 18             	sub    $0x18,%esp
f0106a62:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
f0106a65:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
f0106a68:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
f0106a6b:	8b 45 08             	mov    0x8(%ebp),%eax
f0106a6e:	83 f8 02             	cmp    $0x2,%eax
f0106a71:	0f 84 93 00 00 00    	je     f0106b0a <OP_I+0xae>
f0106a77:	83 f8 02             	cmp    $0x2,%eax
f0106a7a:	7f 0b                	jg     f0106a87 <OP_I+0x2b>
f0106a7c:	83 f8 01             	cmp    $0x1,%eax
f0106a7f:	0f 85 03 01 00 00    	jne    f0106b88 <OP_I+0x12c>
f0106a85:	eb 21                	jmp    f0106aa8 <OP_I+0x4c>
f0106a87:	83 f8 03             	cmp    $0x3,%eax
f0106a8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106a90:	0f 84 da 00 00 00    	je     f0106b70 <OP_I+0x114>
f0106a96:	83 f8 05             	cmp    $0x5,%eax
f0106a99:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
f0106aa0:	0f 85 e2 00 00 00    	jne    f0106b88 <OP_I+0x12c>
f0106aa6:	eb 41                	jmp    f0106ae9 <OP_I+0x8d>
f0106aa8:	8b 15 6c 92 2a f0    	mov    0xf02a926c,%edx
f0106aae:	83 c2 01             	add    $0x1,%edx
f0106ab1:	8b 0d 70 92 2a f0    	mov    0xf02a9270,%ecx
f0106ab7:	8b 41 20             	mov    0x20(%ecx),%eax
f0106aba:	3b 10                	cmp    (%eax),%edx
f0106abc:	76 07                	jbe    f0106ac5 <OP_I+0x69>
f0106abe:	89 c8                	mov    %ecx,%eax
f0106ac0:	e8 1b ec ff ff       	call   f01056e0 <fetch_data>
f0106ac5:	a1 6c 92 2a f0       	mov    0xf02a926c,%eax
f0106aca:	0f b6 08             	movzbl (%eax),%ecx
f0106acd:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106ad2:	83 c0 01             	add    $0x1,%eax
f0106ad5:	a3 6c 92 2a f0       	mov    %eax,0xf02a926c
f0106ada:	be ff 00 00 00       	mov    $0xff,%esi
f0106adf:	bf 00 00 00 00       	mov    $0x0,%edi
f0106ae4:	e9 ab 00 00 00       	jmp    f0106b94 <OP_I+0x138>
f0106ae9:	83 3d 60 91 2a f0 00 	cmpl   $0x0,0xf02a9160
f0106af0:	74 18                	je     f0106b0a <OP_I+0xae>
f0106af2:	e8 c4 ee ff ff       	call   f01059bb <get32s>
f0106af7:	89 c1                	mov    %eax,%ecx
f0106af9:	89 d3                	mov    %edx,%ebx
f0106afb:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0106b00:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0106b05:	e9 8a 00 00 00       	jmp    f0106b94 <OP_I+0x138>
f0106b0a:	f6 05 68 91 2a f0 08 	testb  $0x8,0xf02a9168
f0106b11:	0f 84 c1 00 00 00    	je     f0106bd8 <OP_I+0x17c>
f0106b17:	83 0d 6c 91 2a f0 48 	orl    $0x48,0xf02a916c
f0106b1e:	e8 98 ee ff ff       	call   f01059bb <get32s>
f0106b23:	89 c1                	mov    %eax,%ecx
f0106b25:	89 d3                	mov    %edx,%ebx
f0106b27:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0106b2c:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0106b31:	eb 2b                	jmp    f0106b5e <OP_I+0x102>
f0106b33:	e8 0a ee ff ff       	call   f0105942 <get32>
f0106b38:	89 c1                	mov    %eax,%ecx
f0106b3a:	89 d3                	mov    %edx,%ebx
f0106b3c:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0106b41:	bf 00 00 00 00       	mov    $0x0,%edi
f0106b46:	eb 16                	jmp    f0106b5e <OP_I+0x102>
f0106b48:	e8 f4 ee ff ff       	call   f0105a41 <get16>
f0106b4d:	89 c1                	mov    %eax,%ecx
f0106b4f:	89 c3                	mov    %eax,%ebx
f0106b51:	c1 fb 1f             	sar    $0x1f,%ebx
f0106b54:	be ff ff 0f 00       	mov    $0xfffff,%esi
f0106b59:	bf 00 00 00 00       	mov    $0x0,%edi
f0106b5e:	a1 64 91 2a f0       	mov    0xf02a9164,%eax
f0106b63:	25 00 02 00 00       	and    $0x200,%eax
f0106b68:	09 05 70 91 2a f0    	or     %eax,0xf02a9170
f0106b6e:	eb 24                	jmp    f0106b94 <OP_I+0x138>
f0106b70:	e8 cc ee ff ff       	call   f0105a41 <get16>
f0106b75:	89 c1                	mov    %eax,%ecx
f0106b77:	89 c3                	mov    %eax,%ebx
f0106b79:	c1 fb 1f             	sar    $0x1f,%ebx
f0106b7c:	be ff ff 0f 00       	mov    $0xfffff,%esi
f0106b81:	bf 00 00 00 00       	mov    $0x0,%edi
f0106b86:	eb 0c                	jmp    f0106b94 <OP_I+0x138>
f0106b88:	b8 82 c0 10 f0       	mov    $0xf010c082,%eax
f0106b8d:	e8 cd f6 ff ff       	call   f010625f <oappend>
f0106b92:	eb 53                	jmp    f0106be7 <OP_I+0x18b>
f0106b94:	c6 05 00 92 2a f0 24 	movb   $0x24,0xf02a9200
f0106b9b:	89 c8                	mov    %ecx,%eax
f0106b9d:	21 f0                	and    %esi,%eax
f0106b9f:	89 da                	mov    %ebx,%edx
f0106ba1:	21 fa                	and    %edi,%edx
f0106ba3:	89 04 24             	mov    %eax,(%esp)
f0106ba6:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106baa:	b9 01 00 00 00       	mov    $0x1,%ecx
f0106baf:	ba 63 00 00 00       	mov    $0x63,%edx
f0106bb4:	b8 01 92 2a f0       	mov    $0xf02a9201,%eax
f0106bb9:	e8 eb f4 ff ff       	call   f01060a9 <print_operand_value>
f0106bbe:	0f be 05 50 94 2a f0 	movsbl 0xf02a9450,%eax
f0106bc5:	05 00 92 2a f0       	add    $0xf02a9200,%eax
f0106bca:	e8 90 f6 ff ff       	call   f010625f <oappend>
f0106bcf:	c6 05 00 92 2a f0 00 	movb   $0x0,0xf02a9200
f0106bd6:	eb 0f                	jmp    f0106be7 <OP_I+0x18b>
f0106bd8:	f6 45 0c 01          	testb  $0x1,0xc(%ebp)
f0106bdc:	0f 85 51 ff ff ff    	jne    f0106b33 <OP_I+0xd7>
f0106be2:	e9 61 ff ff ff       	jmp    f0106b48 <OP_I+0xec>
f0106be7:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
f0106bea:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
f0106bed:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
f0106bf0:	89 ec                	mov    %ebp,%esp
f0106bf2:	5d                   	pop    %ebp
f0106bf3:	c3                   	ret    

f0106bf4 <OP_I64>:
f0106bf4:	55                   	push   %ebp
f0106bf5:	89 e5                	mov    %esp,%ebp
f0106bf7:	83 ec 18             	sub    $0x18,%esp
f0106bfa:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
f0106bfd:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
f0106c00:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
f0106c03:	8b 45 08             	mov    0x8(%ebp),%eax
f0106c06:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106c09:	83 3d 60 91 2a f0 00 	cmpl   $0x0,0xf02a9160
f0106c10:	75 11                	jne    f0106c23 <OP_I64+0x2f>
f0106c12:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106c16:	89 04 24             	mov    %eax,(%esp)
f0106c19:	e8 3e fe ff ff       	call   f0106a5c <OP_I>
f0106c1e:	e9 39 01 00 00       	jmp    f0106d5c <OP_I64+0x168>
f0106c23:	83 f8 02             	cmp    $0x2,%eax
f0106c26:	74 58                	je     f0106c80 <OP_I64+0x8c>
f0106c28:	83 f8 03             	cmp    $0x3,%eax
f0106c2b:	90                   	nop    
f0106c2c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0106c30:	0f 84 b0 00 00 00    	je     f0106ce6 <OP_I64+0xf2>
f0106c36:	83 f8 01             	cmp    $0x1,%eax
f0106c39:	0f 85 bf 00 00 00    	jne    f0106cfe <OP_I64+0x10a>
f0106c3f:	8b 15 6c 92 2a f0    	mov    0xf02a926c,%edx
f0106c45:	83 c2 01             	add    $0x1,%edx
f0106c48:	8b 0d 70 92 2a f0    	mov    0xf02a9270,%ecx
f0106c4e:	8b 41 20             	mov    0x20(%ecx),%eax
f0106c51:	3b 10                	cmp    (%eax),%edx
f0106c53:	76 07                	jbe    f0106c5c <OP_I64+0x68>
f0106c55:	89 c8                	mov    %ecx,%eax
f0106c57:	e8 84 ea ff ff       	call   f01056e0 <fetch_data>
f0106c5c:	a1 6c 92 2a f0       	mov    0xf02a926c,%eax
f0106c61:	0f b6 08             	movzbl (%eax),%ecx
f0106c64:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106c69:	83 c0 01             	add    $0x1,%eax
f0106c6c:	a3 6c 92 2a f0       	mov    %eax,0xf02a926c
f0106c71:	be ff 00 00 00       	mov    $0xff,%esi
f0106c76:	bf 00 00 00 00       	mov    $0x0,%edi
f0106c7b:	e9 8a 00 00 00       	jmp    f0106d0a <OP_I64+0x116>
f0106c80:	f6 05 68 91 2a f0 08 	testb  $0x8,0xf02a9168
f0106c87:	0f 84 c1 00 00 00    	je     f0106d4e <OP_I64+0x15a>
f0106c8d:	83 0d 6c 91 2a f0 48 	orl    $0x48,0xf02a916c
f0106c94:	e8 14 ec ff ff       	call   f01058ad <get64>
f0106c99:	89 c1                	mov    %eax,%ecx
f0106c9b:	89 d3                	mov    %edx,%ebx
f0106c9d:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0106ca2:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0106ca7:	eb 2b                	jmp    f0106cd4 <OP_I64+0xe0>
f0106ca9:	e8 94 ec ff ff       	call   f0105942 <get32>
f0106cae:	89 c1                	mov    %eax,%ecx
f0106cb0:	89 d3                	mov    %edx,%ebx
f0106cb2:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0106cb7:	bf 00 00 00 00       	mov    $0x0,%edi
f0106cbc:	eb 16                	jmp    f0106cd4 <OP_I64+0xe0>
f0106cbe:	e8 7e ed ff ff       	call   f0105a41 <get16>
f0106cc3:	89 c1                	mov    %eax,%ecx
f0106cc5:	89 c3                	mov    %eax,%ebx
f0106cc7:	c1 fb 1f             	sar    $0x1f,%ebx
f0106cca:	be ff ff 0f 00       	mov    $0xfffff,%esi
f0106ccf:	bf 00 00 00 00       	mov    $0x0,%edi
f0106cd4:	a1 64 91 2a f0       	mov    0xf02a9164,%eax
f0106cd9:	25 00 02 00 00       	and    $0x200,%eax
f0106cde:	09 05 70 91 2a f0    	or     %eax,0xf02a9170
f0106ce4:	eb 24                	jmp    f0106d0a <OP_I64+0x116>
f0106ce6:	e8 56 ed ff ff       	call   f0105a41 <get16>
f0106ceb:	89 c1                	mov    %eax,%ecx
f0106ced:	89 c3                	mov    %eax,%ebx
f0106cef:	c1 fb 1f             	sar    $0x1f,%ebx
f0106cf2:	be ff ff 0f 00       	mov    $0xfffff,%esi
f0106cf7:	bf 00 00 00 00       	mov    $0x0,%edi
f0106cfc:	eb 0c                	jmp    f0106d0a <OP_I64+0x116>
f0106cfe:	b8 82 c0 10 f0       	mov    $0xf010c082,%eax
f0106d03:	e8 57 f5 ff ff       	call   f010625f <oappend>
f0106d08:	eb 52                	jmp    f0106d5c <OP_I64+0x168>
f0106d0a:	c6 05 00 92 2a f0 24 	movb   $0x24,0xf02a9200
f0106d11:	89 f0                	mov    %esi,%eax
f0106d13:	21 c8                	and    %ecx,%eax
f0106d15:	89 fa                	mov    %edi,%edx
f0106d17:	21 da                	and    %ebx,%edx
f0106d19:	89 04 24             	mov    %eax,(%esp)
f0106d1c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106d20:	b9 01 00 00 00       	mov    $0x1,%ecx
f0106d25:	ba 63 00 00 00       	mov    $0x63,%edx
f0106d2a:	b8 01 92 2a f0       	mov    $0xf02a9201,%eax
f0106d2f:	e8 75 f3 ff ff       	call   f01060a9 <print_operand_value>
f0106d34:	0f be 05 50 94 2a f0 	movsbl 0xf02a9450,%eax
f0106d3b:	05 00 92 2a f0       	add    $0xf02a9200,%eax
f0106d40:	e8 1a f5 ff ff       	call   f010625f <oappend>
f0106d45:	c6 05 00 92 2a f0 00 	movb   $0x0,0xf02a9200
f0106d4c:	eb 0e                	jmp    f0106d5c <OP_I64+0x168>
f0106d4e:	f6 c2 01             	test   $0x1,%dl
f0106d51:	0f 85 52 ff ff ff    	jne    f0106ca9 <OP_I64+0xb5>
f0106d57:	e9 62 ff ff ff       	jmp    f0106cbe <OP_I64+0xca>
f0106d5c:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
f0106d5f:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
f0106d62:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
f0106d65:	89 ec                	mov    %ebp,%esp
f0106d67:	5d                   	pop    %ebp
f0106d68:	c3                   	ret    

f0106d69 <OP_IMREG>:
f0106d69:	55                   	push   %ebp
f0106d6a:	89 e5                	mov    %esp,%ebp
f0106d6c:	83 ec 08             	sub    $0x8,%esp
f0106d6f:	8b 55 08             	mov    0x8(%ebp),%edx
f0106d72:	8d 42 9c             	lea    0xffffff9c(%edx),%eax
f0106d75:	83 f8 32             	cmp    $0x32,%eax
f0106d78:	77 07                	ja     f0106d81 <OP_IMREG+0x18>
f0106d7a:	ff 24 85 8c d6 10 f0 	jmp    *0xf010d68c(,%eax,4)
f0106d81:	ba 82 c0 10 f0       	mov    $0xf010c082,%edx
f0106d86:	e9 af 00 00 00       	jmp    f0106e3a <OP_IMREG+0xd1>
f0106d8b:	ba a0 c0 10 f0       	mov    $0xf010c0a0,%edx
f0106d90:	80 3d 50 94 2a f0 00 	cmpb   $0x0,0xf02a9450
f0106d97:	0f 85 9d 00 00 00    	jne    f0106e3a <OP_IMREG+0xd1>
f0106d9d:	ba a5 c0 10 f0       	mov    $0xf010c0a5,%edx
f0106da2:	e9 93 00 00 00       	jmp    f0106e3a <OP_IMREG+0xd1>
f0106da7:	a1 8c 92 2a f0       	mov    0xf02a928c,%eax
f0106dac:	8b 94 90 10 fe ff ff 	mov    0xfffffe10(%eax,%edx,4),%edx
f0106db3:	e9 82 00 00 00       	jmp    f0106e3a <OP_IMREG+0xd1>
f0106db8:	a1 98 92 2a f0       	mov    0xf02a9298,%eax
f0106dbd:	8b 94 90 70 fe ff ff 	mov    0xfffffe70(%eax,%edx,4),%edx
f0106dc4:	eb 74                	jmp    f0106e3a <OP_IMREG+0xd1>
f0106dc6:	83 0d 6c 91 2a f0 40 	orl    $0x40,0xf02a916c
f0106dcd:	83 3d 68 91 2a f0 00 	cmpl   $0x0,0xf02a9168
f0106dd4:	74 0e                	je     f0106de4 <OP_IMREG+0x7b>
f0106dd6:	a1 94 92 2a f0       	mov    0xf02a9294,%eax
f0106ddb:	8b 94 90 30 fe ff ff 	mov    0xfffffe30(%eax,%edx,4),%edx
f0106de2:	eb 56                	jmp    f0106e3a <OP_IMREG+0xd1>
f0106de4:	a1 90 92 2a f0       	mov    0xf02a9290,%eax
f0106de9:	8b 94 90 30 fe ff ff 	mov    0xfffffe30(%eax,%edx,4),%edx
f0106df0:	eb 48                	jmp    f0106e3a <OP_IMREG+0xd1>
f0106df2:	f6 05 68 91 2a f0 08 	testb  $0x8,0xf02a9168
f0106df9:	74 48                	je     f0106e43 <OP_IMREG+0xda>
f0106dfb:	83 0d 6c 91 2a f0 48 	orl    $0x48,0xf02a916c
f0106e02:	a1 84 92 2a f0       	mov    0xf02a9284,%eax
f0106e07:	8b 94 90 50 fe ff ff 	mov    0xfffffe50(%eax,%edx,4),%edx
f0106e0e:	eb 1a                	jmp    f0106e2a <OP_IMREG+0xc1>
f0106e10:	a1 88 92 2a f0       	mov    0xf02a9288,%eax
f0106e15:	8b 94 90 50 fe ff ff 	mov    0xfffffe50(%eax,%edx,4),%edx
f0106e1c:	eb 0c                	jmp    f0106e2a <OP_IMREG+0xc1>
f0106e1e:	a1 8c 92 2a f0       	mov    0xf02a928c,%eax
f0106e23:	8b 94 90 50 fe ff ff 	mov    0xfffffe50(%eax,%edx,4),%edx
f0106e2a:	a1 64 91 2a f0       	mov    0xf02a9164,%eax
f0106e2f:	25 00 02 00 00       	and    $0x200,%eax
f0106e34:	09 05 70 91 2a f0    	or     %eax,0xf02a9170
f0106e3a:	89 d0                	mov    %edx,%eax
f0106e3c:	e8 1e f4 ff ff       	call   f010625f <oappend>
f0106e41:	c9                   	leave  
f0106e42:	c3                   	ret    
f0106e43:	f6 45 0c 01          	testb  $0x1,0xc(%ebp)
f0106e47:	75 c7                	jne    f0106e10 <OP_IMREG+0xa7>
f0106e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
f0106e50:	eb cc                	jmp    f0106e1e <OP_IMREG+0xb5>

f0106e52 <OP_REG>:
f0106e52:	55                   	push   %ebp
f0106e53:	89 e5                	mov    %esp,%ebp
f0106e55:	83 ec 08             	sub    $0x8,%esp
f0106e58:	89 1c 24             	mov    %ebx,(%esp)
f0106e5b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106e5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0106e62:	8b 0d 68 91 2a f0    	mov    0xf02a9168,%ecx
f0106e68:	f6 c1 01             	test   $0x1,%cl
f0106e6b:	0f 84 05 01 00 00    	je     f0106f76 <OP_REG+0x124>
f0106e71:	a1 6c 91 2a f0       	mov    0xf02a916c,%eax
f0106e76:	83 c8 41             	or     $0x41,%eax
f0106e79:	a3 6c 91 2a f0       	mov    %eax,0xf02a916c
f0106e7e:	be 08 00 00 00       	mov    $0x8,%esi
f0106e83:	8d 53 9c             	lea    0xffffff9c(%ebx),%edx
f0106e86:	83 fa 32             	cmp    $0x32,%edx
f0106e89:	77 07                	ja     f0106e92 <OP_REG+0x40>
f0106e8b:	ff 24 95 58 d7 10 f0 	jmp    *0xf010d758(,%edx,4)
f0106e92:	ba 82 c0 10 f0       	mov    $0xf010c082,%edx
f0106e97:	e9 c8 00 00 00       	jmp    f0106f64 <OP_REG+0x112>
f0106e9c:	ba a0 c0 10 f0       	mov    $0xf010c0a0,%edx
f0106ea1:	80 3d 50 94 2a f0 00 	cmpb   $0x0,0xf02a9450
f0106ea8:	0f 85 b6 00 00 00    	jne    f0106f64 <OP_REG+0x112>
f0106eae:	ba a5 c0 10 f0       	mov    $0xf010c0a5,%edx
f0106eb3:	e9 ac 00 00 00       	jmp    f0106f64 <OP_REG+0x112>
f0106eb8:	8d 54 33 84          	lea    0xffffff84(%ebx,%esi,1),%edx
f0106ebc:	a1 8c 92 2a f0       	mov    0xf02a928c,%eax
f0106ec1:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0106ec4:	e9 9b 00 00 00       	jmp    f0106f64 <OP_REG+0x112>
f0106ec9:	8d 54 33 9c          	lea    0xffffff9c(%ebx,%esi,1),%edx
f0106ecd:	a1 98 92 2a f0       	mov    0xf02a9298,%eax
f0106ed2:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0106ed5:	e9 8a 00 00 00       	jmp    f0106f64 <OP_REG+0x112>
f0106eda:	83 c8 40             	or     $0x40,%eax
f0106edd:	a3 6c 91 2a f0       	mov    %eax,0xf02a916c
f0106ee2:	85 c9                	test   %ecx,%ecx
f0106ee4:	74 0e                	je     f0106ef4 <OP_REG+0xa2>
f0106ee6:	8d 54 33 8c          	lea    0xffffff8c(%ebx,%esi,1),%edx
f0106eea:	a1 94 92 2a f0       	mov    0xf02a9294,%eax
f0106eef:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0106ef2:	eb 70                	jmp    f0106f64 <OP_REG+0x112>
f0106ef4:	a1 90 92 2a f0       	mov    0xf02a9290,%eax
f0106ef9:	8b 94 98 30 fe ff ff 	mov    0xfffffe30(%eax,%ebx,4),%edx
f0106f00:	eb 62                	jmp    f0106f64 <OP_REG+0x112>
f0106f02:	83 3d 60 91 2a f0 00 	cmpl   $0x0,0xf02a9160
f0106f09:	74 11                	je     f0106f1c <OP_REG+0xca>
f0106f0b:	8d 94 33 7c ff ff ff 	lea    0xffffff7c(%ebx,%esi,1),%edx
f0106f12:	a1 84 92 2a f0       	mov    0xf02a9284,%eax
f0106f17:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0106f1a:	eb 48                	jmp    f0106f64 <OP_REG+0x112>
f0106f1c:	83 eb 18             	sub    $0x18,%ebx
f0106f1f:	f6 c1 08             	test   $0x8,%cl
f0106f22:	74 61                	je     f0106f85 <OP_REG+0x133>
f0106f24:	83 c8 48             	or     $0x48,%eax
f0106f27:	a3 6c 91 2a f0       	mov    %eax,0xf02a916c
f0106f2c:	8d 54 1e 94          	lea    0xffffff94(%esi,%ebx,1),%edx
f0106f30:	a1 84 92 2a f0       	mov    0xf02a9284,%eax
f0106f35:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0106f38:	eb 1a                	jmp    f0106f54 <OP_REG+0x102>
f0106f3a:	8d 54 1e 94          	lea    0xffffff94(%esi,%ebx,1),%edx
f0106f3e:	a1 88 92 2a f0       	mov    0xf02a9288,%eax
f0106f43:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0106f46:	eb 0c                	jmp    f0106f54 <OP_REG+0x102>
f0106f48:	8d 54 1e 94          	lea    0xffffff94(%esi,%ebx,1),%edx
f0106f4c:	a1 8c 92 2a f0       	mov    0xf02a928c,%eax
f0106f51:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0106f54:	a1 64 91 2a f0       	mov    0xf02a9164,%eax
f0106f59:	25 00 02 00 00       	and    $0x200,%eax
f0106f5e:	09 05 70 91 2a f0    	or     %eax,0xf02a9170
f0106f64:	89 d0                	mov    %edx,%eax
f0106f66:	e8 f4 f2 ff ff       	call   f010625f <oappend>
f0106f6b:	8b 1c 24             	mov    (%esp),%ebx
f0106f6e:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106f72:	89 ec                	mov    %ebp,%esp
f0106f74:	5d                   	pop    %ebp
f0106f75:	c3                   	ret    
f0106f76:	a1 6c 91 2a f0       	mov    0xf02a916c,%eax
f0106f7b:	be 00 00 00 00       	mov    $0x0,%esi
f0106f80:	e9 fe fe ff ff       	jmp    f0106e83 <OP_REG+0x31>
f0106f85:	a3 6c 91 2a f0       	mov    %eax,0xf02a916c
f0106f8a:	f6 45 0c 01          	testb  $0x1,0xc(%ebp)
f0106f8e:	75 aa                	jne    f0106f3a <OP_REG+0xe8>
f0106f90:	eb b6                	jmp    f0106f48 <OP_REG+0xf6>

f0106f92 <OP_G>:
f0106f92:	55                   	push   %ebp
f0106f93:	89 e5                	mov    %esp,%ebp
f0106f95:	53                   	push   %ebx
f0106f96:	83 ec 04             	sub    $0x4,%esp
f0106f99:	8b 55 08             	mov    0x8(%ebp),%edx
f0106f9c:	8b 0d 68 91 2a f0    	mov    0xf02a9168,%ecx
f0106fa2:	f6 c1 04             	test   $0x4,%cl
f0106fa5:	0f 84 25 01 00 00    	je     f01070d0 <OP_G+0x13e>
f0106fab:	a1 6c 91 2a f0       	mov    0xf02a916c,%eax
f0106fb0:	83 c8 44             	or     $0x44,%eax
f0106fb3:	a3 6c 91 2a f0       	mov    %eax,0xf02a916c
f0106fb8:	bb 08 00 00 00       	mov    $0x8,%ebx
f0106fbd:	83 fa 05             	cmp    $0x5,%edx
f0106fc0:	0f 87 fe 00 00 00    	ja     f01070c4 <OP_G+0x132>
f0106fc6:	ff 24 95 24 d8 10 f0 	jmp    *0xf010d824(,%edx,4)
f0106fcd:	83 c8 40             	or     $0x40,%eax
f0106fd0:	a3 6c 91 2a f0       	mov    %eax,0xf02a916c
f0106fd5:	85 c9                	test   %ecx,%ecx
f0106fd7:	74 1b                	je     f0106ff4 <OP_G+0x62>
f0106fd9:	89 d8                	mov    %ebx,%eax
f0106fdb:	03 05 7c 92 2a f0    	add    0xf02a927c,%eax
f0106fe1:	8b 15 94 92 2a f0    	mov    0xf02a9294,%edx
f0106fe7:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0106fea:	e8 70 f2 ff ff       	call   f010625f <oappend>
f0106fef:	e9 f8 00 00 00       	jmp    f01070ec <OP_G+0x15a>
f0106ff4:	89 d8                	mov    %ebx,%eax
f0106ff6:	03 05 7c 92 2a f0    	add    0xf02a927c,%eax
f0106ffc:	8b 15 90 92 2a f0    	mov    0xf02a9290,%edx
f0107002:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0107005:	e8 55 f2 ff ff       	call   f010625f <oappend>
f010700a:	e9 dd 00 00 00       	jmp    f01070ec <OP_G+0x15a>
f010700f:	89 d8                	mov    %ebx,%eax
f0107011:	03 05 7c 92 2a f0    	add    0xf02a927c,%eax
f0107017:	8b 15 8c 92 2a f0    	mov    0xf02a928c,%edx
f010701d:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0107020:	e8 3a f2 ff ff       	call   f010625f <oappend>
f0107025:	e9 c2 00 00 00       	jmp    f01070ec <OP_G+0x15a>
f010702a:	89 d8                	mov    %ebx,%eax
f010702c:	03 05 7c 92 2a f0    	add    0xf02a927c,%eax
f0107032:	8b 15 88 92 2a f0    	mov    0xf02a9288,%edx
f0107038:	8b 04 82             	mov    (%edx,%eax,4),%eax
f010703b:	e8 1f f2 ff ff       	call   f010625f <oappend>
f0107040:	e9 a7 00 00 00       	jmp    f01070ec <OP_G+0x15a>
f0107045:	89 d8                	mov    %ebx,%eax
f0107047:	03 05 7c 92 2a f0    	add    0xf02a927c,%eax
f010704d:	8b 15 84 92 2a f0    	mov    0xf02a9284,%edx
f0107053:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0107056:	e8 04 f2 ff ff       	call   f010625f <oappend>
f010705b:	e9 8c 00 00 00       	jmp    f01070ec <OP_G+0x15a>
f0107060:	f6 c1 08             	test   $0x8,%cl
f0107063:	74 7a                	je     f01070df <OP_G+0x14d>
f0107065:	83 c8 48             	or     $0x48,%eax
f0107068:	a3 6c 91 2a f0       	mov    %eax,0xf02a916c
f010706d:	89 da                	mov    %ebx,%edx
f010706f:	03 15 7c 92 2a f0    	add    0xf02a927c,%edx
f0107075:	a1 84 92 2a f0       	mov    0xf02a9284,%eax
f010707a:	8b 04 90             	mov    (%eax,%edx,4),%eax
f010707d:	e8 dd f1 ff ff       	call   f010625f <oappend>
f0107082:	eb 2e                	jmp    f01070b2 <OP_G+0x120>
f0107084:	89 d8                	mov    %ebx,%eax
f0107086:	03 05 7c 92 2a f0    	add    0xf02a927c,%eax
f010708c:	8b 15 88 92 2a f0    	mov    0xf02a9288,%edx
f0107092:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0107095:	e8 c5 f1 ff ff       	call   f010625f <oappend>
f010709a:	eb 16                	jmp    f01070b2 <OP_G+0x120>
f010709c:	89 d8                	mov    %ebx,%eax
f010709e:	03 05 7c 92 2a f0    	add    0xf02a927c,%eax
f01070a4:	8b 15 8c 92 2a f0    	mov    0xf02a928c,%edx
f01070aa:	8b 04 82             	mov    (%edx,%eax,4),%eax
f01070ad:	e8 ad f1 ff ff       	call   f010625f <oappend>
f01070b2:	a1 64 91 2a f0       	mov    0xf02a9164,%eax
f01070b7:	25 00 02 00 00       	and    $0x200,%eax
f01070bc:	09 05 70 91 2a f0    	or     %eax,0xf02a9170
f01070c2:	eb 28                	jmp    f01070ec <OP_G+0x15a>
f01070c4:	b8 82 c0 10 f0       	mov    $0xf010c082,%eax
f01070c9:	e8 91 f1 ff ff       	call   f010625f <oappend>
f01070ce:	eb 1c                	jmp    f01070ec <OP_G+0x15a>
f01070d0:	a1 6c 91 2a f0       	mov    0xf02a916c,%eax
f01070d5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01070da:	e9 de fe ff ff       	jmp    f0106fbd <OP_G+0x2b>
f01070df:	a3 6c 91 2a f0       	mov    %eax,0xf02a916c
f01070e4:	f6 45 0c 01          	testb  $0x1,0xc(%ebp)
f01070e8:	75 9a                	jne    f0107084 <OP_G+0xf2>
f01070ea:	eb b0                	jmp    f010709c <OP_G+0x10a>
f01070ec:	83 c4 04             	add    $0x4,%esp
f01070ef:	5b                   	pop    %ebx
f01070f0:	5d                   	pop    %ebp
f01070f1:	c3                   	ret    

f01070f2 <append_seg>:
f01070f2:	55                   	push   %ebp
f01070f3:	89 e5                	mov    %esp,%ebp
f01070f5:	83 ec 08             	sub    $0x8,%esp
f01070f8:	f6 05 64 91 2a f0 08 	testb  $0x8,0xf02a9164
f01070ff:	74 18                	je     f0107119 <append_seg+0x27>
f0107101:	83 0d 70 91 2a f0 08 	orl    $0x8,0xf02a9170
f0107108:	0f be 05 50 94 2a f0 	movsbl 0xf02a9450,%eax
f010710f:	05 ab c0 10 f0       	add    $0xf010c0ab,%eax
f0107114:	e8 46 f1 ff ff       	call   f010625f <oappend>
f0107119:	f6 05 64 91 2a f0 20 	testb  $0x20,0xf02a9164
f0107120:	74 18                	je     f010713a <append_seg+0x48>
f0107122:	83 0d 70 91 2a f0 20 	orl    $0x20,0xf02a9170
f0107129:	0f be 05 50 94 2a f0 	movsbl 0xf02a9450,%eax
f0107130:	05 b0 c0 10 f0       	add    $0xf010c0b0,%eax
f0107135:	e8 25 f1 ff ff       	call   f010625f <oappend>
f010713a:	f6 05 64 91 2a f0 10 	testb  $0x10,0xf02a9164
f0107141:	74 18                	je     f010715b <append_seg+0x69>
f0107143:	83 0d 70 91 2a f0 10 	orl    $0x10,0xf02a9170
f010714a:	0f be 05 50 94 2a f0 	movsbl 0xf02a9450,%eax
f0107151:	05 b5 c0 10 f0       	add    $0xf010c0b5,%eax
f0107156:	e8 04 f1 ff ff       	call   f010625f <oappend>
f010715b:	f6 05 64 91 2a f0 40 	testb  $0x40,0xf02a9164
f0107162:	74 18                	je     f010717c <append_seg+0x8a>
f0107164:	83 0d 70 91 2a f0 40 	orl    $0x40,0xf02a9170
f010716b:	0f be 05 50 94 2a f0 	movsbl 0xf02a9450,%eax
f0107172:	05 67 c0 10 f0       	add    $0xf010c067,%eax
f0107177:	e8 e3 f0 ff ff       	call   f010625f <oappend>
f010717c:	80 3d 64 91 2a f0 00 	cmpb   $0x0,0xf02a9164
f0107183:	79 1b                	jns    f01071a0 <append_seg+0xae>
f0107185:	81 0d 70 91 2a f0 80 	orl    $0x80,0xf02a9170
f010718c:	00 00 00 
f010718f:	0f be 05 50 94 2a f0 	movsbl 0xf02a9450,%eax
f0107196:	05 ba c0 10 f0       	add    $0xf010c0ba,%eax
f010719b:	e8 bf f0 ff ff       	call   f010625f <oappend>
f01071a0:	f6 05 65 91 2a f0 01 	testb  $0x1,0xf02a9165
f01071a7:	74 1b                	je     f01071c4 <append_seg+0xd2>
f01071a9:	81 0d 70 91 2a f0 00 	orl    $0x100,0xf02a9170
f01071b0:	01 00 00 
f01071b3:	0f be 05 50 94 2a f0 	movsbl 0xf02a9450,%eax
f01071ba:	05 bf c0 10 f0       	add    $0xf010c0bf,%eax
f01071bf:	e8 9b f0 ff ff       	call   f010625f <oappend>
f01071c4:	c9                   	leave  
f01071c5:	c3                   	ret    

f01071c6 <OP_DSreg>:
f01071c6:	55                   	push   %ebp
f01071c7:	89 e5                	mov    %esp,%ebp
f01071c9:	83 ec 08             	sub    $0x8,%esp
f01071cc:	a1 64 91 2a f0       	mov    0xf02a9164,%eax
f01071d1:	a9 f8 01 00 00       	test   $0x1f8,%eax
f01071d6:	75 08                	jne    f01071e0 <OP_DSreg+0x1a>
f01071d8:	83 c8 20             	or     $0x20,%eax
f01071db:	a3 64 91 2a f0       	mov    %eax,0xf02a9164
f01071e0:	e8 0d ff ff ff       	call   f01070f2 <append_seg>
f01071e5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01071e8:	8b 45 08             	mov    0x8(%ebp),%eax
f01071eb:	e8 62 f4 ff ff       	call   f0106652 <ptr_reg>
f01071f0:	c9                   	leave  
f01071f1:	c3                   	ret    

f01071f2 <OP_OFF64>:
f01071f2:	55                   	push   %ebp
f01071f3:	89 e5                	mov    %esp,%ebp
f01071f5:	83 ec 18             	sub    $0x18,%esp
f01071f8:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
f01071fb:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
f01071fe:	83 3d 60 91 2a f0 00 	cmpl   $0x0,0xf02a9160
f0107205:	75 7e                	jne    f0107285 <OP_OFF64+0x93>
f0107207:	e8 e6 fe ff ff       	call   f01070f2 <append_seg>
f010720c:	f6 45 0c 02          	testb  $0x2,0xc(%ebp)
f0107210:	75 09                	jne    f010721b <OP_OFF64+0x29>
f0107212:	83 3d 60 91 2a f0 00 	cmpl   $0x0,0xf02a9160
f0107219:	74 0b                	je     f0107226 <OP_OFF64+0x34>
f010721b:	e8 22 e7 ff ff       	call   f0105942 <get32>
f0107220:	89 c3                	mov    %eax,%ebx
f0107222:	89 d6                	mov    %edx,%esi
f0107224:	eb 0c                	jmp    f0107232 <OP_OFF64+0x40>
f0107226:	e8 16 e8 ff ff       	call   f0105a41 <get16>
f010722b:	89 c3                	mov    %eax,%ebx
f010722d:	89 c6                	mov    %eax,%esi
f010722f:	c1 fe 1f             	sar    $0x1f,%esi
f0107232:	80 3d 50 94 2a f0 00 	cmpb   $0x0,0xf02a9450
f0107239:	74 23                	je     f010725e <OP_OFF64+0x6c>
f010723b:	f7 05 64 91 2a f0 f8 	testl  $0x1f8,0xf02a9164
f0107242:	01 00 00 
f0107245:	75 17                	jne    f010725e <OP_OFF64+0x6c>
f0107247:	a1 98 92 2a f0       	mov    0xf02a9298,%eax
f010724c:	8b 40 0c             	mov    0xc(%eax),%eax
f010724f:	e8 0b f0 ff ff       	call   f010625f <oappend>
f0107254:	b8 ae c0 10 f0       	mov    $0xf010c0ae,%eax
f0107259:	e8 01 f0 ff ff       	call   f010625f <oappend>
f010725e:	89 1c 24             	mov    %ebx,(%esp)
f0107261:	89 74 24 04          	mov    %esi,0x4(%esp)
f0107265:	b9 01 00 00 00       	mov    $0x1,%ecx
f010726a:	ba 64 00 00 00       	mov    $0x64,%edx
f010726f:	b8 00 92 2a f0       	mov    $0xf02a9200,%eax
f0107274:	e8 30 ee ff ff       	call   f01060a9 <print_operand_value>
f0107279:	b8 00 92 2a f0       	mov    $0xf02a9200,%eax
f010727e:	e8 dc ef ff ff       	call   f010625f <oappend>
f0107283:	eb 65                	jmp    f01072ea <OP_OFF64+0xf8>
f0107285:	e8 68 fe ff ff       	call   f01070f2 <append_seg>
f010728a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0107290:	e8 18 e6 ff ff       	call   f01058ad <get64>
f0107295:	89 c3                	mov    %eax,%ebx
f0107297:	89 d6                	mov    %edx,%esi
f0107299:	80 3d 50 94 2a f0 00 	cmpb   $0x0,0xf02a9450
f01072a0:	74 23                	je     f01072c5 <OP_OFF64+0xd3>
f01072a2:	f7 05 64 91 2a f0 f8 	testl  $0x1f8,0xf02a9164
f01072a9:	01 00 00 
f01072ac:	75 17                	jne    f01072c5 <OP_OFF64+0xd3>
f01072ae:	a1 98 92 2a f0       	mov    0xf02a9298,%eax
f01072b3:	8b 40 0c             	mov    0xc(%eax),%eax
f01072b6:	e8 a4 ef ff ff       	call   f010625f <oappend>
f01072bb:	b8 ae c0 10 f0       	mov    $0xf010c0ae,%eax
f01072c0:	e8 9a ef ff ff       	call   f010625f <oappend>
f01072c5:	89 1c 24             	mov    %ebx,(%esp)
f01072c8:	89 74 24 04          	mov    %esi,0x4(%esp)
f01072cc:	b9 01 00 00 00       	mov    $0x1,%ecx
f01072d1:	ba 64 00 00 00       	mov    $0x64,%edx
f01072d6:	b8 00 92 2a f0       	mov    $0xf02a9200,%eax
f01072db:	e8 c9 ed ff ff       	call   f01060a9 <print_operand_value>
f01072e0:	b8 00 92 2a f0       	mov    $0xf02a9200,%eax
f01072e5:	e8 75 ef ff ff       	call   f010625f <oappend>
f01072ea:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
f01072ed:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
f01072f0:	89 ec                	mov    %ebp,%esp
f01072f2:	5d                   	pop    %ebp
f01072f3:	c3                   	ret    

f01072f4 <OP_E>:
f01072f4:	55                   	push   %ebp
f01072f5:	89 e5                	mov    %esp,%ebp
f01072f7:	57                   	push   %edi
f01072f8:	56                   	push   %esi
f01072f9:	53                   	push   %ebx
f01072fa:	83 ec 2c             	sub    $0x2c,%esp
f01072fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0107300:	8b 0d 68 91 2a f0    	mov    0xf02a9168,%ecx
f0107306:	f6 c1 01             	test   $0x1,%cl
f0107309:	0f 84 19 09 00 00    	je     f0107c28 <OP_E+0x934>
f010730f:	a1 6c 91 2a f0       	mov    0xf02a916c,%eax
f0107314:	83 c8 41             	or     $0x41,%eax
f0107317:	a3 6c 91 2a f0       	mov    %eax,0xf02a916c
f010731c:	be 08 00 00 00       	mov    $0x8,%esi
f0107321:	80 3d 80 92 2a f0 00 	cmpb   $0x0,0xf02a9280
f0107328:	75 1c                	jne    f0107346 <OP_E+0x52>
f010732a:	c7 44 24 08 c4 c0 10 	movl   $0xf010c0c4,0x8(%esp)
f0107331:	f0 
f0107332:	c7 44 24 04 b3 0b 00 	movl   $0xbb3,0x4(%esp)
f0107339:	00 
f010733a:	c7 04 24 07 c0 10 f0 	movl   $0xf010c007,(%esp)
f0107341:	e8 40 8d ff ff       	call   f0100086 <_panic>
f0107346:	8b 15 6c 92 2a f0    	mov    0xf02a926c,%edx
f010734c:	83 c2 01             	add    $0x1,%edx
f010734f:	89 15 6c 92 2a f0    	mov    %edx,0xf02a926c
f0107355:	83 3d 74 92 2a f0 03 	cmpl   $0x3,0xf02a9274
f010735c:	0f 85 93 01 00 00    	jne    f01074f5 <OP_E+0x201>
f0107362:	83 7d 08 07          	cmpl   $0x7,0x8(%ebp)
f0107366:	0f 87 79 01 00 00    	ja     f01074e5 <OP_E+0x1f1>
f010736c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010736f:	ff 24 bd 3c d8 10 f0 	jmp    *0xf010d83c(,%edi,4)
f0107376:	83 c8 40             	or     $0x40,%eax
f0107379:	a3 6c 91 2a f0       	mov    %eax,0xf02a916c
f010737e:	85 c9                	test   %ecx,%ecx
f0107380:	74 1b                	je     f010739d <OP_E+0xa9>
f0107382:	89 f0                	mov    %esi,%eax
f0107384:	03 05 78 92 2a f0    	add    0xf02a9278,%eax
f010738a:	8b 15 94 92 2a f0    	mov    0xf02a9294,%edx
f0107390:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0107393:	e8 c7 ee ff ff       	call   f010625f <oappend>
f0107398:	e9 c8 08 00 00       	jmp    f0107c65 <OP_E+0x971>
f010739d:	89 f0                	mov    %esi,%eax
f010739f:	03 05 78 92 2a f0    	add    0xf02a9278,%eax
f01073a5:	8b 15 90 92 2a f0    	mov    0xf02a9290,%edx
f01073ab:	8b 04 82             	mov    (%edx,%eax,4),%eax
f01073ae:	e8 ac ee ff ff       	call   f010625f <oappend>
f01073b3:	e9 ad 08 00 00       	jmp    f0107c65 <OP_E+0x971>
f01073b8:	89 f0                	mov    %esi,%eax
f01073ba:	03 05 78 92 2a f0    	add    0xf02a9278,%eax
f01073c0:	8b 15 8c 92 2a f0    	mov    0xf02a928c,%edx
f01073c6:	8b 04 82             	mov    (%edx,%eax,4),%eax
f01073c9:	e8 91 ee ff ff       	call   f010625f <oappend>
f01073ce:	e9 92 08 00 00       	jmp    f0107c65 <OP_E+0x971>
f01073d3:	89 f0                	mov    %esi,%eax
f01073d5:	03 05 78 92 2a f0    	add    0xf02a9278,%eax
f01073db:	8b 15 88 92 2a f0    	mov    0xf02a9288,%edx
f01073e1:	8b 04 82             	mov    (%edx,%eax,4),%eax
f01073e4:	e8 76 ee ff ff       	call   f010625f <oappend>
f01073e9:	e9 77 08 00 00       	jmp    f0107c65 <OP_E+0x971>
f01073ee:	89 f0                	mov    %esi,%eax
f01073f0:	03 05 78 92 2a f0    	add    0xf02a9278,%eax
f01073f6:	8b 15 84 92 2a f0    	mov    0xf02a9284,%edx
f01073fc:	8b 04 82             	mov    (%edx,%eax,4),%eax
f01073ff:	e8 5b ee ff ff       	call   f010625f <oappend>
f0107404:	e9 5c 08 00 00       	jmp    f0107c65 <OP_E+0x971>
f0107409:	83 3d 60 91 2a f0 00 	cmpl   $0x0,0xf02a9160
f0107410:	74 1b                	je     f010742d <OP_E+0x139>
f0107412:	89 f0                	mov    %esi,%eax
f0107414:	03 05 78 92 2a f0    	add    0xf02a9278,%eax
f010741a:	8b 15 84 92 2a f0    	mov    0xf02a9284,%edx
f0107420:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0107423:	e8 37 ee ff ff       	call   f010625f <oappend>
f0107428:	e9 38 08 00 00       	jmp    f0107c65 <OP_E+0x971>
f010742d:	89 f0                	mov    %esi,%eax
f010742f:	03 05 78 92 2a f0    	add    0xf02a9278,%eax
f0107435:	8b 15 88 92 2a f0    	mov    0xf02a9288,%edx
f010743b:	8b 04 82             	mov    (%edx,%eax,4),%eax
f010743e:	e8 1c ee ff ff       	call   f010625f <oappend>
f0107443:	e9 1d 08 00 00       	jmp    f0107c65 <OP_E+0x971>
f0107448:	f6 c1 08             	test   $0x8,%cl
f010744b:	0f 84 e6 07 00 00    	je     f0107c37 <OP_E+0x943>
f0107451:	83 c8 48             	or     $0x48,%eax
f0107454:	a3 6c 91 2a f0       	mov    %eax,0xf02a916c
f0107459:	89 f2                	mov    %esi,%edx
f010745b:	03 15 78 92 2a f0    	add    0xf02a9278,%edx
f0107461:	a1 84 92 2a f0       	mov    0xf02a9284,%eax
f0107466:	8b 04 90             	mov    (%eax,%edx,4),%eax
f0107469:	e8 f1 ed ff ff       	call   f010625f <oappend>
f010746e:	eb 2e                	jmp    f010749e <OP_E+0x1aa>
f0107470:	89 f0                	mov    %esi,%eax
f0107472:	03 05 78 92 2a f0    	add    0xf02a9278,%eax
f0107478:	8b 15 88 92 2a f0    	mov    0xf02a9288,%edx
f010747e:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0107481:	e8 d9 ed ff ff       	call   f010625f <oappend>
f0107486:	eb 16                	jmp    f010749e <OP_E+0x1aa>
f0107488:	89 f0                	mov    %esi,%eax
f010748a:	03 05 78 92 2a f0    	add    0xf02a9278,%eax
f0107490:	8b 15 8c 92 2a f0    	mov    0xf02a928c,%edx
f0107496:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0107499:	e8 c1 ed ff ff       	call   f010625f <oappend>
f010749e:	a1 64 91 2a f0       	mov    0xf02a9164,%eax
f01074a3:	25 00 02 00 00       	and    $0x200,%eax
f01074a8:	09 05 70 91 2a f0    	or     %eax,0xf02a9170
f01074ae:	e9 b2 07 00 00       	jmp    f0107c65 <OP_E+0x971>
f01074b3:	80 7a fe ae          	cmpb   $0xae,0xfffffffe(%edx)
f01074b7:	75 1d                	jne    f01074d6 <OP_E+0x1e2>
f01074b9:	0f b6 42 ff          	movzbl 0xffffffff(%edx),%eax
f01074bd:	3c f8                	cmp    $0xf8,%al
f01074bf:	0f 84 a0 07 00 00    	je     f0107c65 <OP_E+0x971>
f01074c5:	3c f0                	cmp    $0xf0,%al
f01074c7:	0f 84 98 07 00 00    	je     f0107c65 <OP_E+0x971>
f01074cd:	3c e8                	cmp    $0xe8,%al
f01074cf:	90                   	nop    
f01074d0:	0f 84 8f 07 00 00    	je     f0107c65 <OP_E+0x971>
f01074d6:	e8 b2 ed ff ff       	call   f010628d <BadOp>
f01074db:	90                   	nop    
f01074dc:	8d 74 26 00          	lea    0x0(%esi),%esi
f01074e0:	e9 80 07 00 00       	jmp    f0107c65 <OP_E+0x971>
f01074e5:	b8 82 c0 10 f0       	mov    $0xf010c082,%eax
f01074ea:	e8 70 ed ff ff       	call   f010625f <oappend>
f01074ef:	90                   	nop    
f01074f0:	e9 70 07 00 00       	jmp    f0107c65 <OP_E+0x971>
f01074f5:	e8 f8 fb ff ff       	call   f01070f2 <append_seg>
f01074fa:	83 e3 02             	and    $0x2,%ebx
f01074fd:	89 5d d8             	mov    %ebx,0xffffffd8(%ebp)
f0107500:	75 0d                	jne    f010750f <OP_E+0x21b>
f0107502:	83 3d 60 91 2a f0 00 	cmpl   $0x0,0xf02a9160
f0107509:	0f 84 93 05 00 00    	je     f0107aa2 <OP_E+0x7ae>
f010750f:	8b 3d 78 92 2a f0    	mov    0xf02a9278,%edi
f0107515:	83 ff 04             	cmp    $0x4,%edi
f0107518:	74 1a                	je     f0107534 <OP_E+0x240>
f010751a:	c7 45 e0 00 00 00 00 	movl   $0x0,0xffffffe0(%ebp)
f0107521:	c7 45 e8 00 00 00 00 	movl   $0x0,0xffffffe8(%ebp)
f0107528:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
f010752f:	e9 9b 00 00 00       	jmp    f01075cf <OP_E+0x2db>
f0107534:	8b 15 6c 92 2a f0    	mov    0xf02a926c,%edx
f010753a:	83 c2 01             	add    $0x1,%edx
f010753d:	8b 0d 70 92 2a f0    	mov    0xf02a9270,%ecx
f0107543:	8b 41 20             	mov    0x20(%ecx),%eax
f0107546:	3b 10                	cmp    (%eax),%edx
f0107548:	76 07                	jbe    f0107551 <OP_E+0x25d>
f010754a:	89 c8                	mov    %ecx,%eax
f010754c:	e8 8f e1 ff ff       	call   f01056e0 <fetch_data>
f0107551:	a1 6c 92 2a f0       	mov    0xf02a926c,%eax
f0107556:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
f0107559:	0f b6 18             	movzbl (%eax),%ebx
f010755c:	89 d8                	mov    %ebx,%eax
f010755e:	c0 e8 03             	shr    $0x3,%al
f0107561:	89 c2                	mov    %eax,%edx
f0107563:	83 e2 07             	and    $0x7,%edx
f0107566:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
f0107569:	bf 07 00 00 00       	mov    $0x7,%edi
f010756e:	21 df                	and    %ebx,%edi
f0107570:	a1 68 91 2a f0       	mov    0xf02a9168,%eax
f0107575:	89 c1                	mov    %eax,%ecx
f0107577:	83 e1 02             	and    $0x2,%ecx
f010757a:	83 f9 01             	cmp    $0x1,%ecx
f010757d:	19 d2                	sbb    %edx,%edx
f010757f:	f7 d2                	not    %edx
f0107581:	83 e2 42             	and    $0x42,%edx
f0107584:	0b 15 6c 91 2a f0    	or     0xf02a916c,%edx
f010758a:	83 e0 01             	and    $0x1,%eax
f010758d:	89 c6                	mov    %eax,%esi
f010758f:	c1 e0 1f             	shl    $0x1f,%eax
f0107592:	c1 f8 1f             	sar    $0x1f,%eax
f0107595:	83 e0 41             	and    $0x41,%eax
f0107598:	09 d0                	or     %edx,%eax
f010759a:	a3 6c 91 2a f0       	mov    %eax,0xf02a916c
f010759f:	85 c9                	test   %ecx,%ecx
f01075a1:	74 04                	je     f01075a7 <OP_E+0x2b3>
f01075a3:	83 45 e8 08          	addl   $0x8,0xffffffe8(%ebp)
f01075a7:	89 f1                	mov    %esi,%ecx
f01075a9:	84 c9                	test   %cl,%cl
f01075ab:	74 03                	je     f01075b0 <OP_E+0x2bc>
f01075ad:	83 c7 08             	add    $0x8,%edi
f01075b0:	89 d8                	mov    %ebx,%eax
f01075b2:	c0 e8 06             	shr    $0x6,%al
f01075b5:	89 c2                	mov    %eax,%edx
f01075b7:	83 e2 03             	and    $0x3,%edx
f01075ba:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
f01075bd:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f01075c0:	83 c0 01             	add    $0x1,%eax
f01075c3:	a3 6c 92 2a f0       	mov    %eax,0xf02a926c
f01075c8:	c7 45 e0 01 00 00 00 	movl   $0x1,0xffffffe0(%ebp)
f01075cf:	a1 74 92 2a f0       	mov    0xf02a9274,%eax
f01075d4:	83 f8 01             	cmp    $0x1,%eax
f01075d7:	74 5b                	je     f0107634 <OP_E+0x340>
f01075d9:	83 f8 02             	cmp    $0x2,%eax
f01075dc:	0f 84 bd 00 00 00    	je     f010769f <OP_E+0x3ab>
f01075e2:	85 c0                	test   %eax,%eax
f01075e4:	0f 85 ce 00 00 00    	jne    f01076b8 <OP_E+0x3c4>
f01075ea:	89 f8                	mov    %edi,%eax
f01075ec:	83 e0 07             	and    $0x7,%eax
f01075ef:	83 f8 05             	cmp    $0x5,%eax
f01075f2:	0f 85 c0 00 00 00    	jne    f01076b8 <OP_E+0x3c4>
f01075f8:	83 3d 60 91 2a f0 00 	cmpl   $0x0,0xf02a9160
f01075ff:	74 06                	je     f0107607 <OP_E+0x313>
f0107601:	83 7d e0 00          	cmpl   $0x0,0xffffffe0(%ebp)
f0107605:	74 0b                	je     f0107612 <OP_E+0x31e>
f0107607:	c7 45 dc 00 00 00 00 	movl   $0x0,0xffffffdc(%ebp)
f010760e:	66 90                	xchg   %ax,%ax
f0107610:	eb 0d                	jmp    f010761f <OP_E+0x32b>
f0107612:	83 7d d8 00          	cmpl   $0x0,0xffffffd8(%ebp)
f0107616:	0f 95 c0             	setne  %al
f0107619:	0f b6 c0             	movzbl %al,%eax
f010761c:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
f010761f:	e8 97 e3 ff ff       	call   f01059bb <get32s>
f0107624:	89 c3                	mov    %eax,%ebx
f0107626:	89 d6                	mov    %edx,%esi
f0107628:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
f010762f:	e9 9c 00 00 00       	jmp    f01076d0 <OP_E+0x3dc>
f0107634:	8b 15 6c 92 2a f0    	mov    0xf02a926c,%edx
f010763a:	83 c2 01             	add    $0x1,%edx
f010763d:	8b 0d 70 92 2a f0    	mov    0xf02a9270,%ecx
f0107643:	8b 41 20             	mov    0x20(%ecx),%eax
f0107646:	3b 10                	cmp    (%eax),%edx
f0107648:	76 07                	jbe    f0107651 <OP_E+0x35d>
f010764a:	89 c8                	mov    %ecx,%eax
f010764c:	e8 8f e0 ff ff       	call   f01056e0 <fetch_data>
f0107651:	a1 6c 92 2a f0       	mov    0xf02a926c,%eax
f0107656:	0f b6 18             	movzbl (%eax),%ebx
f0107659:	be 00 00 00 00       	mov    $0x0,%esi
f010765e:	83 c0 01             	add    $0x1,%eax
f0107661:	a3 6c 92 2a f0       	mov    %eax,0xf02a926c
f0107666:	89 d8                	mov    %ebx,%eax
f0107668:	25 80 00 00 00       	and    $0x80,%eax
f010766d:	ba 00 00 00 00       	mov    $0x0,%edx
f0107672:	c7 45 dc 00 00 00 00 	movl   $0x0,0xffffffdc(%ebp)
f0107679:	c7 45 e4 01 00 00 00 	movl   $0x1,0xffffffe4(%ebp)
f0107680:	89 d1                	mov    %edx,%ecx
f0107682:	09 c1                	or     %eax,%ecx
f0107684:	74 4a                	je     f01076d0 <OP_E+0x3dc>
f0107686:	81 c3 00 ff ff ff    	add    $0xffffff00,%ebx
f010768c:	83 d6 ff             	adc    $0xffffffff,%esi
f010768f:	c7 45 dc 00 00 00 00 	movl   $0x0,0xffffffdc(%ebp)
f0107696:	c7 45 e4 01 00 00 00 	movl   $0x1,0xffffffe4(%ebp)
f010769d:	eb 31                	jmp    f01076d0 <OP_E+0x3dc>
f010769f:	e8 17 e3 ff ff       	call   f01059bb <get32s>
f01076a4:	89 c3                	mov    %eax,%ebx
f01076a6:	89 d6                	mov    %edx,%esi
f01076a8:	c7 45 dc 00 00 00 00 	movl   $0x0,0xffffffdc(%ebp)
f01076af:	c7 45 e4 01 00 00 00 	movl   $0x1,0xffffffe4(%ebp)
f01076b6:	eb 18                	jmp    f01076d0 <OP_E+0x3dc>
f01076b8:	bb 00 00 00 00       	mov    $0x0,%ebx
f01076bd:	be 00 00 00 00       	mov    $0x0,%esi
f01076c2:	c7 45 dc 00 00 00 00 	movl   $0x0,0xffffffdc(%ebp)
f01076c9:	c7 45 e4 01 00 00 00 	movl   $0x1,0xffffffe4(%ebp)
f01076d0:	80 3d 50 94 2a f0 00 	cmpb   $0x0,0xf02a9450
f01076d7:	75 5b                	jne    f0107734 <OP_E+0x440>
f01076d9:	83 3d 74 92 2a f0 00 	cmpl   $0x0,0xf02a9274
f01076e0:	75 0a                	jne    f01076ec <OP_E+0x3f8>
f01076e2:	89 f8                	mov    %edi,%eax
f01076e4:	83 e0 07             	and    $0x7,%eax
f01076e7:	83 f8 05             	cmp    $0x5,%eax
f01076ea:	75 48                	jne    f0107734 <OP_E+0x440>
f01076ec:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
f01076f0:	0f 94 c1             	sete   %cl
f01076f3:	0f b6 c9             	movzbl %cl,%ecx
f01076f6:	89 1c 24             	mov    %ebx,(%esp)
f01076f9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01076fd:	ba 64 00 00 00       	mov    $0x64,%edx
f0107702:	b8 00 92 2a f0       	mov    $0xf02a9200,%eax
f0107707:	e8 9d e9 ff ff       	call   f01060a9 <print_operand_value>
f010770c:	b8 00 92 2a f0       	mov    $0xf02a9200,%eax
f0107711:	e8 49 eb ff ff       	call   f010625f <oappend>
f0107716:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
f010771a:	74 18                	je     f0107734 <OP_E+0x440>
f010771c:	b9 01 00 00 00       	mov    $0x1,%ecx
f0107721:	89 d8                	mov    %ebx,%eax
f0107723:	89 f2                	mov    %esi,%edx
f0107725:	e8 57 e3 ff ff       	call   f0105a81 <set_op>
f010772a:	b8 d0 c0 10 f0       	mov    $0xf010c0d0,%eax
f010772f:	e8 2b eb ff ff       	call   f010625f <oappend>
f0107734:	83 7d e4 00          	cmpl   $0x0,0xffffffe4(%ebp)
f0107738:	75 1c                	jne    f0107756 <OP_E+0x462>
f010773a:	83 7d e0 00          	cmpl   $0x0,0xffffffe0(%ebp)
f010773e:	0f 84 ed 02 00 00    	je     f0107a31 <OP_E+0x73d>
f0107744:	83 7d e8 04          	cmpl   $0x4,0xffffffe8(%ebp)
f0107748:	75 0c                	jne    f0107756 <OP_E+0x462>
f010774a:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
f010774e:	66 90                	xchg   %ax,%ax
f0107750:	0f 84 db 02 00 00    	je     f0107a31 <OP_E+0x73d>
f0107756:	80 3d 50 94 2a f0 00 	cmpb   $0x0,0xf02a9450
f010775d:	0f 84 e7 04 00 00    	je     f0107c4a <OP_E+0x956>
f0107763:	83 7d 08 07          	cmpl   $0x7,0x8(%ebp)
f0107767:	77 65                	ja     f01077ce <OP_E+0x4da>
f0107769:	8b 45 08             	mov    0x8(%ebp),%eax
f010776c:	ff 24 85 5c d8 10 f0 	jmp    *0xf010d85c(,%eax,4)
f0107773:	b8 d7 c0 10 f0       	mov    $0xf010c0d7,%eax
f0107778:	e8 e2 ea ff ff       	call   f010625f <oappend>
f010777d:	eb 4f                	jmp    f01077ce <OP_E+0x4da>
f010777f:	b8 e2 c0 10 f0       	mov    $0xf010c0e2,%eax
f0107784:	e8 d6 ea ff ff       	call   f010625f <oappend>
f0107789:	eb 43                	jmp    f01077ce <OP_E+0x4da>
f010778b:	b8 e1 c0 10 f0       	mov    $0xf010c0e1,%eax
f0107790:	e8 ca ea ff ff       	call   f010625f <oappend>
f0107795:	eb 37                	jmp    f01077ce <OP_E+0x4da>
f0107797:	b8 ec c0 10 f0       	mov    $0xf010c0ec,%eax
f010779c:	e8 be ea ff ff       	call   f010625f <oappend>
f01077a1:	eb 2b                	jmp    f01077ce <OP_E+0x4da>
f01077a3:	83 3d 60 91 2a f0 00 	cmpl   $0x0,0xf02a9160
f01077aa:	74 0c                	je     f01077b8 <OP_E+0x4c4>
f01077ac:	b8 e1 c0 10 f0       	mov    $0xf010c0e1,%eax
f01077b1:	e8 a9 ea ff ff       	call   f010625f <oappend>
f01077b6:	eb 16                	jmp    f01077ce <OP_E+0x4da>
f01077b8:	b8 ec c0 10 f0       	mov    $0xf010c0ec,%eax
f01077bd:	e8 9d ea ff ff       	call   f010625f <oappend>
f01077c2:	eb 0a                	jmp    f01077ce <OP_E+0x4da>
f01077c4:	b8 f7 c0 10 f0       	mov    $0xf010c0f7,%eax
f01077c9:	e8 91 ea ff ff       	call   f010625f <oappend>
f01077ce:	a1 e4 91 2a f0       	mov    0xf02a91e4,%eax
f01077d3:	0f b6 15 51 94 2a f0 	movzbl 0xf02a9451,%edx
f01077da:	88 10                	mov    %dl,(%eax)
f01077dc:	83 c0 01             	add    $0x1,%eax
f01077df:	a3 e4 91 2a f0       	mov    %eax,0xf02a91e4
f01077e4:	80 3d 50 94 2a f0 00 	cmpb   $0x0,0xf02a9450
f01077eb:	74 10                	je     f01077fd <OP_E+0x509>
f01077ed:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
f01077f1:	74 0a                	je     f01077fd <OP_E+0x509>
f01077f3:	b8 02 c1 10 f0       	mov    $0xf010c102,%eax
f01077f8:	e8 62 ea ff ff       	call   f010625f <oappend>
f01077fd:	a1 e4 91 2a f0       	mov    0xf02a91e4,%eax
f0107802:	c6 00 00             	movb   $0x0,(%eax)
f0107805:	0f b6 15 68 91 2a f0 	movzbl 0xf02a9168,%edx
f010780c:	83 e2 01             	and    $0x1,%edx
f010780f:	89 d0                	mov    %edx,%eax
f0107811:	c1 e0 1f             	shl    $0x1f,%eax
f0107814:	c1 f8 1f             	sar    $0x1f,%eax
f0107817:	83 e0 41             	and    $0x41,%eax
f010781a:	09 05 6c 91 2a f0    	or     %eax,0xf02a916c
f0107820:	83 7d e0 00          	cmpl   $0x0,0xffffffe0(%ebp)
f0107824:	75 07                	jne    f010782d <OP_E+0x539>
f0107826:	84 d2                	test   %dl,%dl
f0107828:	74 03                	je     f010782d <OP_E+0x539>
f010782a:	83 c7 08             	add    $0x8,%edi
f010782d:	83 7d e4 00          	cmpl   $0x0,0xffffffe4(%ebp)
f0107831:	74 26                	je     f0107859 <OP_E+0x565>
f0107833:	83 3d 60 91 2a f0 00 	cmpl   $0x0,0xf02a9160
f010783a:	74 10                	je     f010784c <OP_E+0x558>
f010783c:	83 7d d8 00          	cmpl   $0x0,0xffffffd8(%ebp)
f0107840:	74 0a                	je     f010784c <OP_E+0x558>
f0107842:	a1 84 92 2a f0       	mov    0xf02a9284,%eax
f0107847:	8b 04 b8             	mov    (%eax,%edi,4),%eax
f010784a:	eb 08                	jmp    f0107854 <OP_E+0x560>
f010784c:	a1 88 92 2a f0       	mov    0xf02a9288,%eax
f0107851:	8b 04 b8             	mov    (%eax,%edi,4),%eax
f0107854:	e8 06 ea ff ff       	call   f010625f <oappend>
f0107859:	83 7d e0 00          	cmpl   $0x0,0xffffffe0(%ebp)
f010785d:	0f 84 45 01 00 00    	je     f01079a8 <OP_E+0x6b4>
f0107863:	83 7d e8 04          	cmpl   $0x4,0xffffffe8(%ebp)
f0107867:	0f 84 c7 00 00 00    	je     f0107934 <OP_E+0x640>
f010786d:	80 3d 50 94 2a f0 00 	cmpb   $0x0,0xf02a9450
f0107874:	74 6a                	je     f01078e0 <OP_E+0x5ec>
f0107876:	83 7d e4 00          	cmpl   $0x0,0xffffffe4(%ebp)
f010787a:	74 1b                	je     f0107897 <OP_E+0x5a3>
f010787c:	a1 e4 91 2a f0       	mov    0xf02a91e4,%eax
f0107881:	0f b6 15 53 94 2a f0 	movzbl 0xf02a9453,%edx
f0107888:	88 10                	mov    %dl,(%eax)
f010788a:	8d 50 01             	lea    0x1(%eax),%edx
f010788d:	89 15 e4 91 2a f0    	mov    %edx,0xf02a91e4
f0107893:	c6 40 01 00          	movb   $0x0,0x1(%eax)
f0107897:	83 3d 60 91 2a f0 00 	cmpl   $0x0,0xf02a9160
f010789e:	74 13                	je     f01078b3 <OP_E+0x5bf>
f01078a0:	83 7d d8 00          	cmpl   $0x0,0xffffffd8(%ebp)
f01078a4:	74 0d                	je     f01078b3 <OP_E+0x5bf>
f01078a6:	a1 84 92 2a f0       	mov    0xf02a9284,%eax
f01078ab:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
f01078ae:	8b 04 90             	mov    (%eax,%edx,4),%eax
f01078b1:	eb 0b                	jmp    f01078be <OP_E+0x5ca>
f01078b3:	a1 88 92 2a f0       	mov    0xf02a9288,%eax
f01078b8:	8b 4d e8             	mov    0xffffffe8(%ebp),%ecx
f01078bb:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01078be:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01078c2:	c7 44 24 08 9e b7 10 	movl   $0xf010b79e,0x8(%esp)
f01078c9:	f0 
f01078ca:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f01078d1:	00 
f01078d2:	c7 04 24 00 92 2a f0 	movl   $0xf02a9200,(%esp)
f01078d9:	e8 91 1b 00 00       	call   f010946f <snprintf>
f01078de:	eb 4a                	jmp    f010792a <OP_E+0x636>
f01078e0:	83 3d 60 91 2a f0 00 	cmpl   $0x0,0xf02a9160
f01078e7:	74 16                	je     f01078ff <OP_E+0x60b>
f01078e9:	83 7d d8 00          	cmpl   $0x0,0xffffffd8(%ebp)
f01078ed:	8d 76 00             	lea    0x0(%esi),%esi
f01078f0:	74 0d                	je     f01078ff <OP_E+0x60b>
f01078f2:	a1 84 92 2a f0       	mov    0xf02a9284,%eax
f01078f7:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
f01078fa:	8b 04 90             	mov    (%eax,%edx,4),%eax
f01078fd:	eb 0b                	jmp    f010790a <OP_E+0x616>
f01078ff:	a1 88 92 2a f0       	mov    0xf02a9288,%eax
f0107904:	8b 4d e8             	mov    0xffffffe8(%ebp),%ecx
f0107907:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f010790a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010790e:	c7 44 24 08 09 c1 10 	movl   $0xf010c109,0x8(%esp)
f0107915:	f0 
f0107916:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f010791d:	00 
f010791e:	c7 04 24 00 92 2a f0 	movl   $0xf02a9200,(%esp)
f0107925:	e8 45 1b 00 00       	call   f010946f <snprintf>
f010792a:	b8 00 92 2a f0       	mov    $0xf02a9200,%eax
f010792f:	e8 2b e9 ff ff       	call   f010625f <oappend>
f0107934:	80 3d 50 94 2a f0 00 	cmpb   $0x0,0xf02a9450
f010793b:	74 15                	je     f0107952 <OP_E+0x65e>
f010793d:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0107941:	74 6e                	je     f01079b1 <OP_E+0x6bd>
f0107943:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0107947:	74 68                	je     f01079b1 <OP_E+0x6bd>
f0107949:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f010794d:	8d 76 00             	lea    0x0(%esi),%esi
f0107950:	74 5f                	je     f01079b1 <OP_E+0x6bd>
f0107952:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
f0107956:	74 50                	je     f01079a8 <OP_E+0x6b4>
f0107958:	8b 15 e4 91 2a f0    	mov    0xf02a91e4,%edx
f010795e:	0f b6 05 54 94 2a f0 	movzbl 0xf02a9454,%eax
f0107965:	88 02                	mov    %al,(%edx)
f0107967:	8d 42 01             	lea    0x1(%edx),%eax
f010796a:	a3 e4 91 2a f0       	mov    %eax,0xf02a91e4
f010796f:	c6 42 01 00          	movb   $0x0,0x1(%edx)
f0107973:	b8 01 00 00 00       	mov    $0x1,%eax
f0107978:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
f010797c:	d3 e0                	shl    %cl,%eax
f010797e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107982:	c7 44 24 08 1d 44 11 	movl   $0xf011441d,0x8(%esp)
f0107989:	f0 
f010798a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0107991:	00 
f0107992:	c7 04 24 00 92 2a f0 	movl   $0xf02a9200,(%esp)
f0107999:	e8 d1 1a 00 00       	call   f010946f <snprintf>
f010799e:	b8 00 92 2a f0       	mov    $0xf02a9200,%eax
f01079a3:	e8 b7 e8 ff ff       	call   f010625f <oappend>
f01079a8:	80 3d 50 94 2a f0 00 	cmpb   $0x0,0xf02a9450
f01079af:	74 60                	je     f0107a11 <OP_E+0x71d>
f01079b1:	83 3d 74 92 2a f0 00 	cmpl   $0x0,0xf02a9274
f01079b8:	75 0a                	jne    f01079c4 <OP_E+0x6d0>
f01079ba:	89 f8                	mov    %edi,%eax
f01079bc:	83 e0 07             	and    $0x7,%eax
f01079bf:	83 f8 05             	cmp    $0x5,%eax
f01079c2:	75 4d                	jne    f0107a11 <OP_E+0x71d>
f01079c4:	89 f7                	mov    %esi,%edi
f01079c6:	09 df                	or     %ebx,%edi
f01079c8:	74 47                	je     f0107a11 <OP_E+0x71d>
f01079ca:	85 f6                	test   %esi,%esi
f01079cc:	78 1e                	js     f01079ec <OP_E+0x6f8>
f01079ce:	85 f6                	test   %esi,%esi
f01079d0:	7f 05                	jg     f01079d7 <OP_E+0x6e3>
f01079d2:	83 fb 00             	cmp    $0x0,%ebx
f01079d5:	76 15                	jbe    f01079ec <OP_E+0x6f8>
f01079d7:	a1 e4 91 2a f0       	mov    0xf02a91e4,%eax
f01079dc:	c6 00 2b             	movb   $0x2b,(%eax)
f01079df:	8d 50 01             	lea    0x1(%eax),%edx
f01079e2:	89 15 e4 91 2a f0    	mov    %edx,0xf02a91e4
f01079e8:	c6 40 01 00          	movb   $0x0,0x1(%eax)
f01079ec:	89 1c 24             	mov    %ebx,(%esp)
f01079ef:	89 74 24 04          	mov    %esi,0x4(%esp)
f01079f3:	b9 00 00 00 00       	mov    $0x0,%ecx
f01079f8:	ba 64 00 00 00       	mov    $0x64,%edx
f01079fd:	b8 00 92 2a f0       	mov    $0xf02a9200,%eax
f0107a02:	e8 a2 e6 ff ff       	call   f01060a9 <print_operand_value>
f0107a07:	b8 00 92 2a f0       	mov    $0xf02a9200,%eax
f0107a0c:	e8 4e e8 ff ff       	call   f010625f <oappend>
f0107a11:	a1 e4 91 2a f0       	mov    0xf02a91e4,%eax
f0107a16:	0f b6 15 52 94 2a f0 	movzbl 0xf02a9452,%edx
f0107a1d:	88 10                	mov    %dl,(%eax)
f0107a1f:	8d 50 01             	lea    0x1(%eax),%edx
f0107a22:	89 15 e4 91 2a f0    	mov    %edx,0xf02a91e4
f0107a28:	c6 40 01 00          	movb   $0x0,0x1(%eax)
f0107a2c:	e9 34 02 00 00       	jmp    f0107c65 <OP_E+0x971>
f0107a31:	80 3d 50 94 2a f0 00 	cmpb   $0x0,0xf02a9450
f0107a38:	0f 84 27 02 00 00    	je     f0107c65 <OP_E+0x971>
f0107a3e:	83 3d 74 92 2a f0 00 	cmpl   $0x0,0xf02a9274
f0107a45:	75 0e                	jne    f0107a55 <OP_E+0x761>
f0107a47:	89 f8                	mov    %edi,%eax
f0107a49:	83 e0 07             	and    $0x7,%eax
f0107a4c:	83 f8 05             	cmp    $0x5,%eax
f0107a4f:	0f 85 10 02 00 00    	jne    f0107c65 <OP_E+0x971>
f0107a55:	f7 05 64 91 2a f0 f8 	testl  $0x1f8,0xf02a9164
f0107a5c:	01 00 00 
f0107a5f:	75 17                	jne    f0107a78 <OP_E+0x784>
f0107a61:	a1 98 92 2a f0       	mov    0xf02a9298,%eax
f0107a66:	8b 40 0c             	mov    0xc(%eax),%eax
f0107a69:	e8 f1 e7 ff ff       	call   f010625f <oappend>
f0107a6e:	b8 ae c0 10 f0       	mov    $0xf010c0ae,%eax
f0107a73:	e8 e7 e7 ff ff       	call   f010625f <oappend>
f0107a78:	89 1c 24             	mov    %ebx,(%esp)
f0107a7b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0107a7f:	b9 01 00 00 00       	mov    $0x1,%ecx
f0107a84:	ba 64 00 00 00       	mov    $0x64,%edx
f0107a89:	b8 00 92 2a f0       	mov    $0xf02a9200,%eax
f0107a8e:	e8 16 e6 ff ff       	call   f01060a9 <print_operand_value>
f0107a93:	b8 00 92 2a f0       	mov    $0xf02a9200,%eax
f0107a98:	e8 c2 e7 ff ff       	call   f010625f <oappend>
f0107a9d:	e9 c3 01 00 00       	jmp    f0107c65 <OP_E+0x971>
f0107aa2:	a1 74 92 2a f0       	mov    0xf02a9274,%eax
f0107aa7:	83 f8 01             	cmp    $0x1,%eax
f0107aaa:	74 51                	je     f0107afd <OP_E+0x809>
f0107aac:	83 f8 02             	cmp    $0x2,%eax
f0107aaf:	90                   	nop    
f0107ab0:	0f 84 96 00 00 00    	je     f0107b4c <OP_E+0x858>
f0107ab6:	85 c0                	test   %eax,%eax
f0107ab8:	0f 85 b5 00 00 00    	jne    f0107b73 <OP_E+0x87f>
f0107abe:	a1 78 92 2a f0       	mov    0xf02a9278,%eax
f0107ac3:	83 e0 07             	and    $0x7,%eax
f0107ac6:	83 f8 06             	cmp    $0x6,%eax
f0107ac9:	0f 85 a4 00 00 00    	jne    f0107b73 <OP_E+0x87f>
f0107acf:	e8 6d df ff ff       	call   f0105a41 <get16>
f0107ad4:	89 c1                	mov    %eax,%ecx
f0107ad6:	89 c3                	mov    %eax,%ebx
f0107ad8:	c1 fb 1f             	sar    $0x1f,%ebx
f0107adb:	25 00 80 00 00       	and    $0x8000,%eax
f0107ae0:	ba 00 00 00 00       	mov    $0x0,%edx
f0107ae5:	89 d7                	mov    %edx,%edi
f0107ae7:	09 c7                	or     %eax,%edi
f0107ae9:	0f 84 8e 00 00 00    	je     f0107b7d <OP_E+0x889>
f0107aef:	81 c1 00 00 ff ff    	add    $0xffff0000,%ecx
f0107af5:	83 d3 ff             	adc    $0xffffffff,%ebx
f0107af8:	e9 80 00 00 00       	jmp    f0107b7d <OP_E+0x889>
f0107afd:	8b 15 6c 92 2a f0    	mov    0xf02a926c,%edx
f0107b03:	83 c2 01             	add    $0x1,%edx
f0107b06:	8b 0d 70 92 2a f0    	mov    0xf02a9270,%ecx
f0107b0c:	8b 41 20             	mov    0x20(%ecx),%eax
f0107b0f:	3b 10                	cmp    (%eax),%edx
f0107b11:	76 07                	jbe    f0107b1a <OP_E+0x826>
f0107b13:	89 c8                	mov    %ecx,%eax
f0107b15:	e8 c6 db ff ff       	call   f01056e0 <fetch_data>
f0107b1a:	a1 6c 92 2a f0       	mov    0xf02a926c,%eax
f0107b1f:	0f b6 08             	movzbl (%eax),%ecx
f0107b22:	bb 00 00 00 00       	mov    $0x0,%ebx
f0107b27:	83 c0 01             	add    $0x1,%eax
f0107b2a:	a3 6c 92 2a f0       	mov    %eax,0xf02a926c
f0107b2f:	89 c8                	mov    %ecx,%eax
f0107b31:	25 80 00 00 00       	and    $0x80,%eax
f0107b36:	ba 00 00 00 00       	mov    $0x0,%edx
f0107b3b:	89 d7                	mov    %edx,%edi
f0107b3d:	09 c7                	or     %eax,%edi
f0107b3f:	74 3c                	je     f0107b7d <OP_E+0x889>
f0107b41:	81 c1 00 ff ff ff    	add    $0xffffff00,%ecx
f0107b47:	83 d3 ff             	adc    $0xffffffff,%ebx
f0107b4a:	eb 31                	jmp    f0107b7d <OP_E+0x889>
f0107b4c:	e8 f0 de ff ff       	call   f0105a41 <get16>
f0107b51:	89 c1                	mov    %eax,%ecx
f0107b53:	89 c3                	mov    %eax,%ebx
f0107b55:	c1 fb 1f             	sar    $0x1f,%ebx
f0107b58:	25 00 80 00 00       	and    $0x8000,%eax
f0107b5d:	ba 00 00 00 00       	mov    $0x0,%edx
f0107b62:	89 d7                	mov    %edx,%edi
f0107b64:	09 c7                	or     %eax,%edi
f0107b66:	74 15                	je     f0107b7d <OP_E+0x889>
f0107b68:	81 c1 00 00 ff ff    	add    $0xffff0000,%ecx
f0107b6e:	83 d3 ff             	adc    $0xffffffff,%ebx
f0107b71:	eb 0a                	jmp    f0107b7d <OP_E+0x889>
f0107b73:	b9 00 00 00 00       	mov    $0x0,%ecx
f0107b78:	bb 00 00 00 00       	mov    $0x0,%ebx
f0107b7d:	80 3d 50 94 2a f0 00 	cmpb   $0x0,0xf02a9450
f0107b84:	75 3b                	jne    f0107bc1 <OP_E+0x8cd>
f0107b86:	83 3d 74 92 2a f0 00 	cmpl   $0x0,0xf02a9274
f0107b8d:	75 0d                	jne    f0107b9c <OP_E+0x8a8>
f0107b8f:	a1 78 92 2a f0       	mov    0xf02a9278,%eax
f0107b94:	83 e0 07             	and    $0x7,%eax
f0107b97:	83 f8 06             	cmp    $0x6,%eax
f0107b9a:	75 3f                	jne    f0107bdb <OP_E+0x8e7>
f0107b9c:	89 0c 24             	mov    %ecx,(%esp)
f0107b9f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0107ba3:	b9 00 00 00 00       	mov    $0x0,%ecx
f0107ba8:	ba 64 00 00 00       	mov    $0x64,%edx
f0107bad:	b8 00 92 2a f0       	mov    $0xf02a9200,%eax
f0107bb2:	e8 f2 e4 ff ff       	call   f01060a9 <print_operand_value>
f0107bb7:	b8 00 92 2a f0       	mov    $0xf02a9200,%eax
f0107bbc:	e8 9e e6 ff ff       	call   f010625f <oappend>
f0107bc1:	83 3d 74 92 2a f0 00 	cmpl   $0x0,0xf02a9274
f0107bc8:	75 11                	jne    f0107bdb <OP_E+0x8e7>
f0107bca:	a1 78 92 2a f0       	mov    0xf02a9278,%eax
f0107bcf:	83 e0 07             	and    $0x7,%eax
f0107bd2:	83 f8 06             	cmp    $0x6,%eax
f0107bd5:	0f 84 8a 00 00 00    	je     f0107c65 <OP_E+0x971>
f0107bdb:	8b 15 e4 91 2a f0    	mov    0xf02a91e4,%edx
f0107be1:	0f b6 05 51 94 2a f0 	movzbl 0xf02a9451,%eax
f0107be8:	88 02                	mov    %al,(%edx)
f0107bea:	8d 42 01             	lea    0x1(%edx),%eax
f0107bed:	a3 e4 91 2a f0       	mov    %eax,0xf02a91e4
f0107bf2:	c6 42 01 00          	movb   $0x0,0x1(%edx)
f0107bf6:	89 f2                	mov    %esi,%edx
f0107bf8:	03 15 78 92 2a f0    	add    0xf02a9278,%edx
f0107bfe:	a1 9c 92 2a f0       	mov    0xf02a929c,%eax
f0107c03:	8b 04 90             	mov    (%eax,%edx,4),%eax
f0107c06:	e8 54 e6 ff ff       	call   f010625f <oappend>
f0107c0b:	8b 15 e4 91 2a f0    	mov    0xf02a91e4,%edx
f0107c11:	0f b6 05 52 94 2a f0 	movzbl 0xf02a9452,%eax
f0107c18:	88 02                	mov    %al,(%edx)
f0107c1a:	8d 42 01             	lea    0x1(%edx),%eax
f0107c1d:	a3 e4 91 2a f0       	mov    %eax,0xf02a91e4
f0107c22:	c6 42 01 00          	movb   $0x0,0x1(%edx)
f0107c26:	eb 3d                	jmp    f0107c65 <OP_E+0x971>
f0107c28:	a1 6c 91 2a f0       	mov    0xf02a916c,%eax
f0107c2d:	be 00 00 00 00       	mov    $0x0,%esi
f0107c32:	e9 ea f6 ff ff       	jmp    f0107321 <OP_E+0x2d>
f0107c37:	a3 6c 91 2a f0       	mov    %eax,0xf02a916c
f0107c3c:	f6 c3 01             	test   $0x1,%bl
f0107c3f:	0f 85 2b f8 ff ff    	jne    f0107470 <OP_E+0x17c>
f0107c45:	e9 3e f8 ff ff       	jmp    f0107488 <OP_E+0x194>
f0107c4a:	a1 e4 91 2a f0       	mov    0xf02a91e4,%eax
f0107c4f:	0f b6 15 51 94 2a f0 	movzbl 0xf02a9451,%edx
f0107c56:	88 10                	mov    %dl,(%eax)
f0107c58:	83 c0 01             	add    $0x1,%eax
f0107c5b:	a3 e4 91 2a f0       	mov    %eax,0xf02a91e4
f0107c60:	e9 98 fb ff ff       	jmp    f01077fd <OP_E+0x509>
f0107c65:	83 c4 2c             	add    $0x2c,%esp
f0107c68:	5b                   	pop    %ebx
f0107c69:	5e                   	pop    %esi
f0107c6a:	5f                   	pop    %edi
f0107c6b:	5d                   	pop    %ebp
f0107c6c:	c3                   	ret    

f0107c6d <OP_EX>:
f0107c6d:	55                   	push   %ebp
f0107c6e:	89 e5                	mov    %esp,%ebp
f0107c70:	83 ec 18             	sub    $0x18,%esp
f0107c73:	83 3d 74 92 2a f0 03 	cmpl   $0x3,0xf02a9274
f0107c7a:	74 14                	je     f0107c90 <OP_EX+0x23>
f0107c7c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107c7f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107c83:	8b 45 08             	mov    0x8(%ebp),%eax
f0107c86:	89 04 24             	mov    %eax,(%esp)
f0107c89:	e8 66 f6 ff ff       	call   f01072f4 <OP_E>
f0107c8e:	eb 7a                	jmp    f0107d0a <OP_EX+0x9d>
f0107c90:	b8 00 00 00 00       	mov    $0x0,%eax
f0107c95:	f6 05 68 91 2a f0 01 	testb  $0x1,0xf02a9168
f0107c9c:	74 09                	je     f0107ca7 <OP_EX+0x3a>
f0107c9e:	83 0d 6c 91 2a f0 41 	orl    $0x41,0xf02a916c
f0107ca5:	b0 08                	mov    $0x8,%al
f0107ca7:	80 3d 80 92 2a f0 00 	cmpb   $0x0,0xf02a9280
f0107cae:	75 1c                	jne    f0107ccc <OP_EX+0x5f>
f0107cb0:	c7 44 24 08 c4 c0 10 	movl   $0xf010c0c4,0x8(%esp)
f0107cb7:	f0 
f0107cb8:	c7 44 24 04 90 0f 00 	movl   $0xf90,0x4(%esp)
f0107cbf:	00 
f0107cc0:	c7 04 24 07 c0 10 f0 	movl   $0xf010c007,(%esp)
f0107cc7:	e8 ba 83 ff ff       	call   f0100086 <_panic>
f0107ccc:	83 05 6c 92 2a f0 01 	addl   $0x1,0xf02a926c
f0107cd3:	03 05 78 92 2a f0    	add    0xf02a9278,%eax
f0107cd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107cdd:	c7 44 24 08 3f c0 10 	movl   $0xf010c03f,0x8(%esp)
f0107ce4:	f0 
f0107ce5:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0107cec:	00 
f0107ced:	c7 04 24 00 92 2a f0 	movl   $0xf02a9200,(%esp)
f0107cf4:	e8 76 17 00 00       	call   f010946f <snprintf>
f0107cf9:	0f be 05 50 94 2a f0 	movsbl 0xf02a9450,%eax
f0107d00:	05 00 92 2a f0       	add    $0xf02a9200,%eax
f0107d05:	e8 55 e5 ff ff       	call   f010625f <oappend>
f0107d0a:	c9                   	leave  
f0107d0b:	c3                   	ret    

f0107d0c <OP_XS>:
f0107d0c:	55                   	push   %ebp
f0107d0d:	89 e5                	mov    %esp,%ebp
f0107d0f:	83 ec 08             	sub    $0x8,%esp
f0107d12:	83 3d 74 92 2a f0 03 	cmpl   $0x3,0xf02a9274
f0107d19:	75 14                	jne    f0107d2f <OP_XS+0x23>
f0107d1b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107d1e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107d22:	8b 45 08             	mov    0x8(%ebp),%eax
f0107d25:	89 04 24             	mov    %eax,(%esp)
f0107d28:	e8 40 ff ff ff       	call   f0107c6d <OP_EX>
f0107d2d:	eb 05                	jmp    f0107d34 <OP_XS+0x28>
f0107d2f:	e8 59 e5 ff ff       	call   f010628d <BadOp>
f0107d34:	c9                   	leave  
f0107d35:	c3                   	ret    

f0107d36 <OP_EM>:
f0107d36:	55                   	push   %ebp
f0107d37:	89 e5                	mov    %esp,%ebp
f0107d39:	83 ec 18             	sub    $0x18,%esp
f0107d3c:	83 3d 74 92 2a f0 03 	cmpl   $0x3,0xf02a9274
f0107d43:	74 17                	je     f0107d5c <OP_EM+0x26>
f0107d45:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107d48:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107d4c:	8b 45 08             	mov    0x8(%ebp),%eax
f0107d4f:	89 04 24             	mov    %eax,(%esp)
f0107d52:	e8 9d f5 ff ff       	call   f01072f4 <OP_E>
f0107d57:	e9 ba 00 00 00       	jmp    f0107e16 <OP_EM+0xe0>
f0107d5c:	ba 00 00 00 00       	mov    $0x0,%edx
f0107d61:	f6 05 68 91 2a f0 01 	testb  $0x1,0xf02a9168
f0107d68:	74 09                	je     f0107d73 <OP_EM+0x3d>
f0107d6a:	83 0d 6c 91 2a f0 41 	orl    $0x41,0xf02a916c
f0107d71:	b2 08                	mov    $0x8,%dl
f0107d73:	80 3d 80 92 2a f0 00 	cmpb   $0x0,0xf02a9280
f0107d7a:	75 1c                	jne    f0107d98 <OP_EM+0x62>
f0107d7c:	c7 44 24 08 c4 c0 10 	movl   $0xf010c0c4,0x8(%esp)
f0107d83:	f0 
f0107d84:	c7 44 24 04 76 0f 00 	movl   $0xf76,0x4(%esp)
f0107d8b:	00 
f0107d8c:	c7 04 24 07 c0 10 f0 	movl   $0xf010c007,(%esp)
f0107d93:	e8 ee 82 ff ff       	call   f0100086 <_panic>
f0107d98:	83 05 6c 92 2a f0 01 	addl   $0x1,0xf02a926c
f0107d9f:	a1 64 91 2a f0       	mov    0xf02a9164,%eax
f0107da4:	25 00 02 00 00       	and    $0x200,%eax
f0107da9:	09 05 70 91 2a f0    	or     %eax,0xf02a9170
f0107daf:	85 c0                	test   %eax,%eax
f0107db1:	74 2a                	je     f0107ddd <OP_EM+0xa7>
f0107db3:	89 d0                	mov    %edx,%eax
f0107db5:	03 05 78 92 2a f0    	add    0xf02a9278,%eax
f0107dbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107dbf:	c7 44 24 08 3f c0 10 	movl   $0xf010c03f,0x8(%esp)
f0107dc6:	f0 
f0107dc7:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0107dce:	00 
f0107dcf:	c7 04 24 00 92 2a f0 	movl   $0xf02a9200,(%esp)
f0107dd6:	e8 94 16 00 00       	call   f010946f <snprintf>
f0107ddb:	eb 28                	jmp    f0107e05 <OP_EM+0xcf>
f0107ddd:	89 d0                	mov    %edx,%eax
f0107ddf:	03 05 78 92 2a f0    	add    0xf02a9278,%eax
f0107de5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107de9:	c7 44 24 08 47 c0 10 	movl   $0xf010c047,0x8(%esp)
f0107df0:	f0 
f0107df1:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0107df8:	00 
f0107df9:	c7 04 24 00 92 2a f0 	movl   $0xf02a9200,(%esp)
f0107e00:	e8 6a 16 00 00       	call   f010946f <snprintf>
f0107e05:	0f be 05 50 94 2a f0 	movsbl 0xf02a9450,%eax
f0107e0c:	05 00 92 2a f0       	add    $0xf02a9200,%eax
f0107e11:	e8 49 e4 ff ff       	call   f010625f <oappend>
f0107e16:	c9                   	leave  
f0107e17:	c3                   	ret    

f0107e18 <OP_MS>:
f0107e18:	55                   	push   %ebp
f0107e19:	89 e5                	mov    %esp,%ebp
f0107e1b:	83 ec 08             	sub    $0x8,%esp
f0107e1e:	83 3d 74 92 2a f0 03 	cmpl   $0x3,0xf02a9274
f0107e25:	75 14                	jne    f0107e3b <OP_MS+0x23>
f0107e27:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107e2a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107e2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0107e31:	89 04 24             	mov    %eax,(%esp)
f0107e34:	e8 fd fe ff ff       	call   f0107d36 <OP_EM>
f0107e39:	eb 05                	jmp    f0107e40 <OP_MS+0x28>
f0107e3b:	e8 4d e4 ff ff       	call   f010628d <BadOp>
f0107e40:	c9                   	leave  
f0107e41:	c3                   	ret    

f0107e42 <OP_Rd>:
f0107e42:	55                   	push   %ebp
f0107e43:	89 e5                	mov    %esp,%ebp
f0107e45:	83 ec 08             	sub    $0x8,%esp
f0107e48:	83 3d 74 92 2a f0 03 	cmpl   $0x3,0xf02a9274
f0107e4f:	75 14                	jne    f0107e65 <OP_Rd+0x23>
f0107e51:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107e54:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107e58:	8b 45 08             	mov    0x8(%ebp),%eax
f0107e5b:	89 04 24             	mov    %eax,(%esp)
f0107e5e:	e8 91 f4 ff ff       	call   f01072f4 <OP_E>
f0107e63:	eb 05                	jmp    f0107e6a <OP_Rd+0x28>
f0107e65:	e8 23 e4 ff ff       	call   f010628d <BadOp>
f0107e6a:	c9                   	leave  
f0107e6b:	90                   	nop    
f0107e6c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0107e70:	c3                   	ret    

f0107e71 <OP_indirE>:
f0107e71:	55                   	push   %ebp
f0107e72:	89 e5                	mov    %esp,%ebp
f0107e74:	83 ec 08             	sub    $0x8,%esp
f0107e77:	80 3d 50 94 2a f0 00 	cmpb   $0x0,0xf02a9450
f0107e7e:	75 0a                	jne    f0107e8a <OP_indirE+0x19>
f0107e80:	b8 0d c1 10 f0       	mov    $0xf010c10d,%eax
f0107e85:	e8 d5 e3 ff ff       	call   f010625f <oappend>
f0107e8a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107e8d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107e91:	8b 45 08             	mov    0x8(%ebp),%eax
f0107e94:	89 04 24             	mov    %eax,(%esp)
f0107e97:	e8 58 f4 ff ff       	call   f01072f4 <OP_E>
f0107e9c:	c9                   	leave  
f0107e9d:	c3                   	ret    

f0107e9e <OP_STi>:
f0107e9e:	55                   	push   %ebp
f0107e9f:	89 e5                	mov    %esp,%ebp
f0107ea1:	83 ec 18             	sub    $0x18,%esp
f0107ea4:	a1 78 92 2a f0       	mov    0xf02a9278,%eax
f0107ea9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107ead:	c7 44 24 08 0f c1 10 	movl   $0xf010c10f,0x8(%esp)
f0107eb4:	f0 
f0107eb5:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0107ebc:	00 
f0107ebd:	c7 04 24 00 92 2a f0 	movl   $0xf02a9200,(%esp)
f0107ec4:	e8 a6 15 00 00       	call   f010946f <snprintf>
f0107ec9:	0f be 05 50 94 2a f0 	movsbl 0xf02a9450,%eax
f0107ed0:	05 00 92 2a f0       	add    $0xf02a9200,%eax
f0107ed5:	e8 85 e3 ff ff       	call   f010625f <oappend>
f0107eda:	c9                   	leave  
f0107edb:	c3                   	ret    

f0107edc <OP_ST>:
f0107edc:	55                   	push   %ebp
f0107edd:	89 e5                	mov    %esp,%ebp
f0107edf:	83 ec 08             	sub    $0x8,%esp
f0107ee2:	b8 18 c1 10 f0       	mov    $0xf010c118,%eax
f0107ee7:	e8 73 e3 ff ff       	call   f010625f <oappend>
f0107eec:	c9                   	leave  
f0107eed:	c3                   	ret    

f0107eee <print_insn_i386>:
f0107eee:	55                   	push   %ebp
f0107eef:	89 e5                	mov    %esp,%ebp
f0107ef1:	57                   	push   %edi
f0107ef2:	56                   	push   %esi
f0107ef3:	53                   	push   %ebx
f0107ef4:	83 ec 4c             	sub    $0x4c,%esp
f0107ef7:	8b 75 08             	mov    0x8(%ebp),%esi
f0107efa:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0107efd:	8b 45 10             	mov    0x10(%ebp),%eax
f0107f00:	8b 48 0c             	mov    0xc(%eax),%ecx
f0107f03:	8d 41 fd             	lea    0xfffffffd(%ecx),%eax
f0107f06:	83 f8 01             	cmp    $0x1,%eax
f0107f09:	0f 96 c0             	setbe  %al
f0107f0c:	0f b6 c0             	movzbl %al,%eax
f0107f0f:	a3 60 91 2a f0       	mov    %eax,0xf02a9160
f0107f14:	83 f9 02             	cmp    $0x2,%ecx
f0107f17:	0f 94 c2             	sete   %dl
f0107f1a:	83 f9 04             	cmp    $0x4,%ecx
f0107f1d:	0f 94 c0             	sete   %al
f0107f20:	09 d0                	or     %edx,%eax
f0107f22:	a2 50 94 2a f0       	mov    %al,0xf02a9450
f0107f27:	85 c9                	test   %ecx,%ecx
f0107f29:	74 0f                	je     f0107f3a <print_insn_i386+0x4c>
f0107f2b:	83 f9 03             	cmp    $0x3,%ecx
f0107f2e:	74 0a                	je     f0107f3a <print_insn_i386+0x4c>
f0107f30:	83 f9 02             	cmp    $0x2,%ecx
f0107f33:	74 05                	je     f0107f3a <print_insn_i386+0x4c>
f0107f35:	83 f9 04             	cmp    $0x4,%ecx
f0107f38:	75 09                	jne    f0107f43 <print_insn_i386+0x55>
f0107f3a:	c7 45 f0 03 00 00 00 	movl   $0x3,0xfffffff0(%ebp)
f0107f41:	eb 2b                	jmp    f0107f6e <print_insn_i386+0x80>
f0107f43:	83 f9 01             	cmp    $0x1,%ecx
f0107f46:	75 0a                	jne    f0107f52 <print_insn_i386+0x64>
f0107f48:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
f0107f4f:	90                   	nop    
f0107f50:	eb 1c                	jmp    f0107f6e <print_insn_i386+0x80>
f0107f52:	c7 44 24 08 1c c1 10 	movl   $0xf010c11c,0x8(%esp)
f0107f59:	f0 
f0107f5a:	c7 44 24 04 52 07 00 	movl   $0x752,0x4(%esp)
f0107f61:	00 
f0107f62:	c7 04 24 07 c0 10 f0 	movl   $0xf010c007,(%esp)
f0107f69:	e8 18 81 ff ff       	call   f0100086 <_panic>
f0107f6e:	8b 55 10             	mov    0x10(%ebp),%edx
f0107f71:	8b 5a 68             	mov    0x68(%edx),%ebx
f0107f74:	85 db                	test   %ebx,%ebx
f0107f76:	0f 84 a5 01 00 00    	je     f0108121 <print_insn_i386+0x233>
f0107f7c:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
f0107f83:	00 
f0107f84:	c7 44 24 04 35 c1 10 	movl   $0xf010c135,0x4(%esp)
f0107f8b:	f0 
f0107f8c:	89 1c 24             	mov    %ebx,(%esp)
f0107f8f:	e8 81 17 00 00       	call   f0109715 <strncmp>
f0107f94:	85 c0                	test   %eax,%eax
f0107f96:	75 16                	jne    f0107fae <print_insn_i386+0xc0>
f0107f98:	c7 05 60 91 2a f0 01 	movl   $0x1,0xf02a9160
f0107f9f:	00 00 00 
f0107fa2:	c7 45 f0 03 00 00 00 	movl   $0x3,0xfffffff0(%ebp)
f0107fa9:	e9 54 01 00 00       	jmp    f0108102 <print_insn_i386+0x214>
f0107fae:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0107fb5:	00 
f0107fb6:	c7 44 24 04 3c c1 10 	movl   $0xf010c13c,0x4(%esp)
f0107fbd:	f0 
f0107fbe:	89 1c 24             	mov    %ebx,(%esp)
f0107fc1:	e8 4f 17 00 00       	call   f0109715 <strncmp>
f0107fc6:	85 c0                	test   %eax,%eax
f0107fc8:	75 16                	jne    f0107fe0 <print_insn_i386+0xf2>
f0107fca:	c7 05 60 91 2a f0 00 	movl   $0x0,0xf02a9160
f0107fd1:	00 00 00 
f0107fd4:	c7 45 f0 03 00 00 00 	movl   $0x3,0xfffffff0(%ebp)
f0107fdb:	e9 22 01 00 00       	jmp    f0108102 <print_insn_i386+0x214>
f0107fe0:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
f0107fe7:	00 
f0107fe8:	c7 44 24 04 41 c1 10 	movl   $0xf010c141,0x4(%esp)
f0107fef:	f0 
f0107ff0:	89 1c 24             	mov    %ebx,(%esp)
f0107ff3:	e8 1d 17 00 00       	call   f0109715 <strncmp>
f0107ff8:	85 c0                	test   %eax,%eax
f0107ffa:	75 16                	jne    f0108012 <print_insn_i386+0x124>
f0107ffc:	c7 05 60 91 2a f0 00 	movl   $0x0,0xf02a9160
f0108003:	00 00 00 
f0108006:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
f010800d:	e9 f0 00 00 00       	jmp    f0108102 <print_insn_i386+0x214>
f0108012:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
f0108019:	00 
f010801a:	c7 44 24 04 47 c1 10 	movl   $0xf010c147,0x4(%esp)
f0108021:	f0 
f0108022:	89 1c 24             	mov    %ebx,(%esp)
f0108025:	e8 eb 16 00 00       	call   f0109715 <strncmp>
f010802a:	85 c0                	test   %eax,%eax
f010802c:	75 0c                	jne    f010803a <print_insn_i386+0x14c>
f010802e:	c6 05 50 94 2a f0 01 	movb   $0x1,0xf02a9450
f0108035:	e9 c8 00 00 00       	jmp    f0108102 <print_insn_i386+0x214>
f010803a:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
f0108041:	00 
f0108042:	c7 44 24 04 4d c1 10 	movl   $0xf010c14d,0x4(%esp)
f0108049:	f0 
f010804a:	89 1c 24             	mov    %ebx,(%esp)
f010804d:	e8 c3 16 00 00       	call   f0109715 <strncmp>
f0108052:	85 c0                	test   %eax,%eax
f0108054:	75 0c                	jne    f0108062 <print_insn_i386+0x174>
f0108056:	c6 05 50 94 2a f0 00 	movb   $0x0,0xf02a9450
f010805d:	e9 a0 00 00 00       	jmp    f0108102 <print_insn_i386+0x214>
f0108062:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0108069:	00 
f010806a:	c7 44 24 04 51 c1 10 	movl   $0xf010c151,0x4(%esp)
f0108071:	f0 
f0108072:	89 1c 24             	mov    %ebx,(%esp)
f0108075:	e8 9b 16 00 00       	call   f0109715 <strncmp>
f010807a:	85 c0                	test   %eax,%eax
f010807c:	75 24                	jne    f01080a2 <print_insn_i386+0x1b4>
f010807e:	0f b6 43 04          	movzbl 0x4(%ebx),%eax
f0108082:	3c 31                	cmp    $0x31,%al
f0108084:	75 0c                	jne    f0108092 <print_insn_i386+0x1a4>
f0108086:	80 7b 05 36          	cmpb   $0x36,0x5(%ebx)
f010808a:	75 76                	jne    f0108102 <print_insn_i386+0x214>
f010808c:	83 65 f0 fd          	andl   $0xfffffffd,0xfffffff0(%ebp)
f0108090:	eb 70                	jmp    f0108102 <print_insn_i386+0x214>
f0108092:	3c 33                	cmp    $0x33,%al
f0108094:	75 6c                	jne    f0108102 <print_insn_i386+0x214>
f0108096:	80 7b 05 32          	cmpb   $0x32,0x5(%ebx)
f010809a:	75 66                	jne    f0108102 <print_insn_i386+0x214>
f010809c:	83 4d f0 02          	orl    $0x2,0xfffffff0(%ebp)
f01080a0:	eb 60                	jmp    f0108102 <print_insn_i386+0x214>
f01080a2:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01080a9:	00 
f01080aa:	c7 44 24 04 56 c1 10 	movl   $0xf010c156,0x4(%esp)
f01080b1:	f0 
f01080b2:	89 1c 24             	mov    %ebx,(%esp)
f01080b5:	e8 5b 16 00 00       	call   f0109715 <strncmp>
f01080ba:	85 c0                	test   %eax,%eax
f01080bc:	75 24                	jne    f01080e2 <print_insn_i386+0x1f4>
f01080be:	0f b6 43 04          	movzbl 0x4(%ebx),%eax
f01080c2:	3c 31                	cmp    $0x31,%al
f01080c4:	75 0c                	jne    f01080d2 <print_insn_i386+0x1e4>
f01080c6:	80 7b 05 36          	cmpb   $0x36,0x5(%ebx)
f01080ca:	75 36                	jne    f0108102 <print_insn_i386+0x214>
f01080cc:	83 65 f0 fe          	andl   $0xfffffffe,0xfffffff0(%ebp)
f01080d0:	eb 30                	jmp    f0108102 <print_insn_i386+0x214>
f01080d2:	3c 33                	cmp    $0x33,%al
f01080d4:	75 2c                	jne    f0108102 <print_insn_i386+0x214>
f01080d6:	80 7b 05 32          	cmpb   $0x32,0x5(%ebx)
f01080da:	75 26                	jne    f0108102 <print_insn_i386+0x214>
f01080dc:	83 4d f0 01          	orl    $0x1,0xfffffff0(%ebp)
f01080e0:	eb 20                	jmp    f0108102 <print_insn_i386+0x214>
f01080e2:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
f01080e9:	00 
f01080ea:	c7 44 24 04 5b c1 10 	movl   $0xf010c15b,0x4(%esp)
f01080f1:	f0 
f01080f2:	89 1c 24             	mov    %ebx,(%esp)
f01080f5:	e8 1b 16 00 00       	call   f0109715 <strncmp>
f01080fa:	85 c0                	test   %eax,%eax
f01080fc:	75 04                	jne    f0108102 <print_insn_i386+0x214>
f01080fe:	83 4d f0 04          	orl    $0x4,0xfffffff0(%ebp)
f0108102:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
f0108109:	00 
f010810a:	89 1c 24             	mov    %ebx,(%esp)
f010810d:	e8 49 16 00 00       	call   f010975b <strchr>
f0108112:	85 c0                	test   %eax,%eax
f0108114:	74 0b                	je     f0108121 <print_insn_i386+0x233>
f0108116:	89 c3                	mov    %eax,%ebx
f0108118:	83 c3 01             	add    $0x1,%ebx
f010811b:	0f 85 5b fe ff ff    	jne    f0107f7c <print_insn_i386+0x8e>
f0108121:	80 3d 50 94 2a f0 00 	cmpb   $0x0,0xf02a9450
f0108128:	74 79                	je     f01081a3 <print_insn_i386+0x2b5>
f010812a:	c7 05 84 92 2a f0 80 	movl   $0xf010d880,0xf02a9284
f0108131:	d8 10 f0 
f0108134:	c7 05 88 92 2a f0 c0 	movl   $0xf010d8c0,0xf02a9288
f010813b:	d8 10 f0 
f010813e:	c7 05 8c 92 2a f0 00 	movl   $0xf010d900,0xf02a928c
f0108145:	d9 10 f0 
f0108148:	c7 05 90 92 2a f0 40 	movl   $0xf010d940,0xf02a9290
f010814f:	d9 10 f0 
f0108152:	c7 05 94 92 2a f0 60 	movl   $0xf010d960,0xf02a9294
f0108159:	d9 10 f0 
f010815c:	c7 05 98 92 2a f0 a0 	movl   $0xf010d9a0,0xf02a9298
f0108163:	d9 10 f0 
f0108166:	c7 05 9c 92 2a f0 c0 	movl   $0xf010d9c0,0xf02a929c
f010816d:	d9 10 f0 
f0108170:	c6 05 51 94 2a f0 5b 	movb   $0x5b,0xf02a9451
f0108177:	c6 05 52 94 2a f0 5d 	movb   $0x5d,0xf02a9452
f010817e:	c6 05 53 94 2a f0 2b 	movb   $0x2b,0xf02a9453
f0108185:	c6 05 54 94 2a f0 2a 	movb   $0x2a,0xf02a9454
f010818c:	eb 77                	jmp    f0108205 <print_insn_i386+0x317>
f010818e:	80 cc 08             	or     $0x8,%ah
f0108191:	a3 64 91 2a f0       	mov    %eax,0xf02a9164
f0108196:	8d 41 01             	lea    0x1(%ecx),%eax
f0108199:	a3 6c 92 2a f0       	mov    %eax,0xf02a926c
f010819e:	e9 e6 02 00 00       	jmp    f0108489 <print_insn_i386+0x59b>
f01081a3:	c7 05 84 92 2a f0 e0 	movl   $0xf010d9e0,0xf02a9284
f01081aa:	d9 10 f0 
f01081ad:	c7 05 88 92 2a f0 20 	movl   $0xf010da20,0xf02a9288
f01081b4:	da 10 f0 
f01081b7:	c7 05 8c 92 2a f0 60 	movl   $0xf010da60,0xf02a928c
f01081be:	da 10 f0 
f01081c1:	c7 05 90 92 2a f0 a0 	movl   $0xf010daa0,0xf02a9290
f01081c8:	da 10 f0 
f01081cb:	c7 05 94 92 2a f0 c0 	movl   $0xf010dac0,0xf02a9294
f01081d2:	da 10 f0 
f01081d5:	c7 05 98 92 2a f0 00 	movl   $0xf010db00,0xf02a9298
f01081dc:	db 10 f0 
f01081df:	c7 05 9c 92 2a f0 20 	movl   $0xf010db20,0xf02a929c
f01081e6:	db 10 f0 
f01081e9:	c6 05 51 94 2a f0 28 	movb   $0x28,0xf02a9451
f01081f0:	c6 05 52 94 2a f0 29 	movb   $0x29,0xf02a9452
f01081f7:	c6 05 53 94 2a f0 2c 	movb   $0x2c,0xf02a9453
f01081fe:	c6 05 54 94 2a f0 2c 	movb   $0x2c,0xf02a9454
f0108205:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0108208:	c7 41 44 07 00 00 00 	movl   $0x7,0x44(%ecx)
f010820f:	8d 45 d0             	lea    0xffffffd0(%ebp),%eax
f0108212:	89 41 20             	mov    %eax,0x20(%ecx)
f0108215:	8d 45 d4             	lea    0xffffffd4(%ebp),%eax
f0108218:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
f010821b:	89 75 e8             	mov    %esi,0xffffffe8(%ebp)
f010821e:	89 7d ec             	mov    %edi,0xffffffec(%ebp)
f0108221:	c6 05 80 91 2a f0 00 	movb   $0x0,0xf02a9180
f0108228:	c6 05 a0 92 2a f0 00 	movb   $0x0,0xf02a92a0
f010822f:	c6 05 20 93 2a f0 00 	movb   $0x0,0xf02a9320
f0108236:	c6 05 a0 93 2a f0 00 	movb   $0x0,0xf02a93a0
f010823d:	c7 05 10 94 2a f0 ff 	movl   $0xffffffff,0xf02a9410
f0108244:	ff ff ff 
f0108247:	c7 05 0c 94 2a f0 ff 	movl   $0xffffffff,0xf02a940c
f010824e:	ff ff ff 
f0108251:	c7 05 08 94 2a f0 ff 	movl   $0xffffffff,0xf02a9408
f0108258:	ff ff ff 
f010825b:	89 0d 70 92 2a f0    	mov    %ecx,0xf02a9270
f0108261:	89 35 48 94 2a f0    	mov    %esi,0xf02a9448
f0108267:	89 3d 4c 94 2a f0    	mov    %edi,0xf02a944c
f010826d:	a3 64 92 2a f0       	mov    %eax,0xf02a9264
f0108272:	a3 6c 92 2a f0       	mov    %eax,0xf02a926c
f0108277:	c7 05 e4 91 2a f0 80 	movl   $0xf02a9180,0xf02a91e4
f010827e:	91 2a f0 
f0108281:	c7 05 68 91 2a f0 00 	movl   $0x0,0xf02a9168
f0108288:	00 00 00 
f010828b:	c7 05 64 91 2a f0 00 	movl   $0x0,0xf02a9164
f0108292:	00 00 00 
f0108295:	c7 05 70 91 2a f0 00 	movl   $0x0,0xf02a9170
f010829c:	00 00 00 
f010829f:	c7 05 6c 91 2a f0 00 	movl   $0x0,0xf02a916c
f01082a6:	00 00 00 
f01082a9:	8b 15 6c 92 2a f0    	mov    0xf02a926c,%edx
f01082af:	83 c2 01             	add    $0x1,%edx
f01082b2:	8b 0d 70 92 2a f0    	mov    0xf02a9270,%ecx
f01082b8:	8b 41 20             	mov    0x20(%ecx),%eax
f01082bb:	3b 10                	cmp    (%eax),%edx
f01082bd:	76 07                	jbe    f01082c6 <print_insn_i386+0x3d8>
f01082bf:	89 c8                	mov    %ecx,%eax
f01082c1:	e8 1a d4 ff ff       	call   f01056e0 <fetch_data>
f01082c6:	8b 0d 6c 92 2a f0    	mov    0xf02a926c,%ecx
f01082cc:	0f b6 11             	movzbl (%ecx),%edx
f01082cf:	80 fa 64             	cmp    $0x64,%dl
f01082d2:	0f 84 1d 01 00 00    	je     f01083f5 <print_insn_i386+0x507>
f01082d8:	80 fa 64             	cmp    $0x64,%dl
f01082db:	77 47                	ja     f0108324 <print_insn_i386+0x436>
f01082dd:	80 fa 36             	cmp    $0x36,%dl
f01082e0:	0f 84 e5 00 00 00    	je     f01083cb <print_insn_i386+0x4dd>
f01082e6:	80 fa 36             	cmp    $0x36,%dl
f01082e9:	77 1a                	ja     f0108305 <print_insn_i386+0x417>
f01082eb:	80 fa 26             	cmp    $0x26,%dl
f01082ee:	66 90                	xchg   %ax,%ax
f01082f0:	0f 84 f1 00 00 00    	je     f01083e7 <print_insn_i386+0x4f9>
f01082f6:	80 fa 2e             	cmp    $0x2e,%dl
f01082f9:	0f 85 8a 01 00 00    	jne    f0108489 <print_insn_i386+0x59b>
f01082ff:	90                   	nop    
f0108300:	e9 b5 00 00 00       	jmp    f01083ba <print_insn_i386+0x4cc>
f0108305:	80 fa 3e             	cmp    $0x3e,%dl
f0108308:	0f 84 cb 00 00 00    	je     f01083d9 <print_insn_i386+0x4eb>
f010830e:	80 fa 3e             	cmp    $0x3e,%dl
f0108311:	0f 82 72 01 00 00    	jb     f0108489 <print_insn_i386+0x59b>
f0108317:	8d 42 c0             	lea    0xffffffc0(%edx),%eax
f010831a:	3c 0f                	cmp    $0xf,%al
f010831c:	0f 87 67 01 00 00    	ja     f0108489 <print_insn_i386+0x59b>
f0108322:	eb 4e                	jmp    f0108372 <print_insn_i386+0x484>
f0108324:	80 fa 9b             	cmp    $0x9b,%dl
f0108327:	0f 84 0c 01 00 00    	je     f0108439 <print_insn_i386+0x54b>
f010832d:	80 fa 9b             	cmp    $0x9b,%dl
f0108330:	77 23                	ja     f0108355 <print_insn_i386+0x467>
f0108332:	80 fa 66             	cmp    $0x66,%dl
f0108335:	0f 84 dc 00 00 00    	je     f0108417 <print_insn_i386+0x529>
f010833b:	80 fa 66             	cmp    $0x66,%dl
f010833e:	66 90                	xchg   %ax,%ax
f0108340:	0f 82 c0 00 00 00    	jb     f0108406 <print_insn_i386+0x518>
f0108346:	80 fa 67             	cmp    $0x67,%dl
f0108349:	0f 85 3a 01 00 00    	jne    f0108489 <print_insn_i386+0x59b>
f010834f:	90                   	nop    
f0108350:	e9 d3 00 00 00       	jmp    f0108428 <print_insn_i386+0x53a>
f0108355:	80 fa f2             	cmp    $0xf2,%dl
f0108358:	74 3e                	je     f0108398 <print_insn_i386+0x4aa>
f010835a:	80 fa f3             	cmp    $0xf3,%dl
f010835d:	8d 76 00             	lea    0x0(%esi),%esi
f0108360:	74 25                	je     f0108387 <print_insn_i386+0x499>
f0108362:	80 fa f0             	cmp    $0xf0,%dl
f0108365:	0f 85 1e 01 00 00    	jne    f0108489 <print_insn_i386+0x59b>
f010836b:	90                   	nop    
f010836c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0108370:	eb 37                	jmp    f01083a9 <print_insn_i386+0x4bb>
f0108372:	83 3d 60 91 2a f0 00 	cmpl   $0x0,0xf02a9160
f0108379:	0f 84 0a 01 00 00    	je     f0108489 <print_insn_i386+0x59b>
f010837f:	0f b6 da             	movzbl %dl,%ebx
f0108382:	e9 ce 00 00 00       	jmp    f0108455 <print_insn_i386+0x567>
f0108387:	83 0d 64 91 2a f0 01 	orl    $0x1,0xf02a9164
f010838e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0108393:	e9 bd 00 00 00       	jmp    f0108455 <print_insn_i386+0x567>
f0108398:	83 0d 64 91 2a f0 02 	orl    $0x2,0xf02a9164
f010839f:	bb 00 00 00 00       	mov    $0x0,%ebx
f01083a4:	e9 ac 00 00 00       	jmp    f0108455 <print_insn_i386+0x567>
f01083a9:	83 0d 64 91 2a f0 04 	orl    $0x4,0xf02a9164
f01083b0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01083b5:	e9 9b 00 00 00       	jmp    f0108455 <print_insn_i386+0x567>
f01083ba:	83 0d 64 91 2a f0 08 	orl    $0x8,0xf02a9164
f01083c1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01083c6:	e9 8a 00 00 00       	jmp    f0108455 <print_insn_i386+0x567>
f01083cb:	83 0d 64 91 2a f0 10 	orl    $0x10,0xf02a9164
f01083d2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01083d7:	eb 7c                	jmp    f0108455 <print_insn_i386+0x567>
f01083d9:	83 0d 64 91 2a f0 20 	orl    $0x20,0xf02a9164
f01083e0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01083e5:	eb 6e                	jmp    f0108455 <print_insn_i386+0x567>
f01083e7:	83 0d 64 91 2a f0 40 	orl    $0x40,0xf02a9164
f01083ee:	bb 00 00 00 00       	mov    $0x0,%ebx
f01083f3:	eb 60                	jmp    f0108455 <print_insn_i386+0x567>
f01083f5:	81 0d 64 91 2a f0 80 	orl    $0x80,0xf02a9164
f01083fc:	00 00 00 
f01083ff:	bb 00 00 00 00       	mov    $0x0,%ebx
f0108404:	eb 4f                	jmp    f0108455 <print_insn_i386+0x567>
f0108406:	81 0d 64 91 2a f0 00 	orl    $0x100,0xf02a9164
f010840d:	01 00 00 
f0108410:	bb 00 00 00 00       	mov    $0x0,%ebx
f0108415:	eb 3e                	jmp    f0108455 <print_insn_i386+0x567>
f0108417:	81 0d 64 91 2a f0 00 	orl    $0x200,0xf02a9164
f010841e:	02 00 00 
f0108421:	bb 00 00 00 00       	mov    $0x0,%ebx
f0108426:	eb 2d                	jmp    f0108455 <print_insn_i386+0x567>
f0108428:	81 0d 64 91 2a f0 00 	orl    $0x400,0xf02a9164
f010842f:	04 00 00 
f0108432:	bb 00 00 00 00       	mov    $0x0,%ebx
f0108437:	eb 1c                	jmp    f0108455 <print_insn_i386+0x567>
f0108439:	a1 64 91 2a f0       	mov    0xf02a9164,%eax
f010843e:	85 c0                	test   %eax,%eax
f0108440:	0f 85 48 fd ff ff    	jne    f010818e <print_insn_i386+0x2a0>
f0108446:	c7 05 64 91 2a f0 00 	movl   $0x800,0xf02a9164
f010844d:	08 00 00 
f0108450:	bb 00 00 00 00       	mov    $0x0,%ebx
f0108455:	a1 68 91 2a f0       	mov    0xf02a9168,%eax
f010845a:	85 c0                	test   %eax,%eax
f010845c:	74 19                	je     f0108477 <print_insn_i386+0x589>
f010845e:	ba 00 00 00 00       	mov    $0x0,%edx
f0108463:	e8 03 d3 ff ff       	call   f010576b <prefix_name>
f0108468:	e8 f2 dd ff ff       	call   f010625f <oappend>
f010846d:	b8 77 ab 10 f0       	mov    $0xf010ab77,%eax
f0108472:	e8 e8 dd ff ff       	call   f010625f <oappend>
f0108477:	89 1d 68 91 2a f0    	mov    %ebx,0xf02a9168
f010847d:	83 05 6c 92 2a f0 01 	addl   $0x1,0xf02a926c
f0108484:	e9 20 fe ff ff       	jmp    f01082a9 <print_insn_i386+0x3bb>
f0108489:	a1 6c 92 2a f0       	mov    0xf02a926c,%eax
f010848e:	a3 68 92 2a f0       	mov    %eax,0xf02a9268
f0108493:	8b 7d f0             	mov    0xfffffff0(%ebp),%edi
f0108496:	8d 50 01             	lea    0x1(%eax),%edx
f0108499:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010849c:	8b 41 20             	mov    0x20(%ecx),%eax
f010849f:	3b 10                	cmp    (%eax),%edx
f01084a1:	76 07                	jbe    f01084aa <print_insn_i386+0x5bc>
f01084a3:	89 c8                	mov    %ecx,%eax
f01084a5:	e8 36 d2 ff ff       	call   f01056e0 <fetch_data>
f01084aa:	8b 0d 6c 92 2a f0    	mov    0xf02a926c,%ecx
f01084b0:	0f b6 01             	movzbl (%ecx),%eax
f01084b3:	88 45 c3             	mov    %al,0xffffffc3(%ebp)
f01084b6:	f6 05 65 91 2a f0 08 	testb  $0x8,0xf02a9165
f01084bd:	74 36                	je     f01084f5 <print_insn_i386+0x607>
f01084bf:	83 c0 28             	add    $0x28,%eax
f01084c2:	3c 07                	cmp    $0x7,%al
f01084c4:	76 2f                	jbe    f01084f5 <print_insn_i386+0x607>
f01084c6:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
f01084c9:	0f b6 45 d4          	movzbl 0xffffffd4(%ebp),%eax
f01084cd:	e8 99 d2 ff ff       	call   f010576b <prefix_name>
f01084d2:	85 c0                	test   %eax,%eax
f01084d4:	75 05                	jne    f01084db <print_insn_i386+0x5ed>
f01084d6:	b8 82 c0 10 f0       	mov    $0xf010c082,%eax
f01084db:	89 44 24 04          	mov    %eax,0x4(%esp)
f01084df:	c7 04 24 9e b7 10 f0 	movl   $0xf010b79e,(%esp)
f01084e6:	e8 4c b5 ff ff       	call   f0103a37 <cprintf>
f01084eb:	b8 01 00 00 00       	mov    $0x1,%eax
f01084f0:	e9 4d 07 00 00       	jmp    f0108c42 <print_insn_i386+0xd54>
f01084f5:	80 7d c3 0f          	cmpb   $0xf,0xffffffc3(%ebp)
f01084f9:	75 4d                	jne    f0108548 <print_insn_i386+0x65a>
f01084fb:	8d 51 02             	lea    0x2(%ecx),%edx
f01084fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0108501:	8b 41 20             	mov    0x20(%ecx),%eax
f0108504:	3b 10                	cmp    (%eax),%edx
f0108506:	76 07                	jbe    f010850f <print_insn_i386+0x621>
f0108508:	89 c8                	mov    %ecx,%eax
f010850a:	e8 d1 d1 ff ff       	call   f01056e0 <fetch_data>
f010850f:	8b 0d 6c 92 2a f0    	mov    0xf02a926c,%ecx
f0108515:	83 c1 01             	add    $0x1,%ecx
f0108518:	0f b6 11             	movzbl (%ecx),%edx
f010851b:	6b c2 1c             	imul   $0x1c,%edx,%eax
f010851e:	8d 98 40 db 10 f0    	lea    0xf010db40(%eax),%ebx
f0108524:	0f b6 82 40 f7 10 f0 	movzbl 0xf010f740(%edx),%eax
f010852b:	a2 80 92 2a f0       	mov    %al,0xf02a9280
f0108530:	0f b6 b2 40 f8 10 f0 	movzbl 0xf010f840(%edx),%esi
f0108537:	83 c1 01             	add    $0x1,%ecx
f010853a:	89 0d 6c 92 2a f0    	mov    %ecx,0xf02a926c
f0108540:	89 f0                	mov    %esi,%eax
f0108542:	84 c0                	test   %al,%al
f0108544:	74 28                	je     f010856e <print_insn_i386+0x680>
f0108546:	eb 5a                	jmp    f01085a2 <print_insn_i386+0x6b4>
f0108548:	0f b6 55 c3          	movzbl 0xffffffc3(%ebp),%edx
f010854c:	6b c2 1c             	imul   $0x1c,%edx,%eax
f010854f:	8d 98 40 f9 10 f0    	lea    0xf010f940(%eax),%ebx
f0108555:	0f b6 82 40 15 11 f0 	movzbl 0xf0111540(%edx),%eax
f010855c:	a2 80 92 2a f0       	mov    %al,0xf02a9280
f0108561:	8d 41 01             	lea    0x1(%ecx),%eax
f0108564:	a3 6c 92 2a f0       	mov    %eax,0xf02a926c
f0108569:	be 00 00 00 00       	mov    $0x0,%esi
f010856e:	f6 05 64 91 2a f0 01 	testb  $0x1,0xf02a9164
f0108575:	0f 84 b5 06 00 00    	je     f0108c30 <print_insn_i386+0xd42>
f010857b:	b8 62 c1 10 f0       	mov    $0xf010c162,%eax
f0108580:	e8 da dc ff ff       	call   f010625f <oappend>
f0108585:	83 0d 70 91 2a f0 01 	orl    $0x1,0xf02a9170
f010858c:	e9 9f 06 00 00       	jmp    f0108c30 <print_insn_i386+0xd42>
f0108591:	b8 68 c1 10 f0       	mov    $0xf010c168,%eax
f0108596:	e8 c4 dc ff ff       	call   f010625f <oappend>
f010859b:	83 0d 70 91 2a f0 02 	orl    $0x2,0xf02a9170
f01085a2:	f6 05 64 91 2a f0 04 	testb  $0x4,0xf02a9164
f01085a9:	74 11                	je     f01085bc <print_insn_i386+0x6ce>
f01085ab:	b8 6f c1 10 f0       	mov    $0xf010c16f,%eax
f01085b0:	e8 aa dc ff ff       	call   f010625f <oappend>
f01085b5:	83 0d 70 91 2a f0 04 	orl    $0x4,0xf02a9170
f01085bc:	f6 05 65 91 2a f0 04 	testb  $0x4,0xf02a9165
f01085c3:	74 43                	je     f0108608 <print_insn_i386+0x71a>
f01085c5:	83 f7 02             	xor    $0x2,%edi
f01085c8:	83 7b 18 09          	cmpl   $0x9,0x18(%ebx)
f01085cc:	75 09                	jne    f01085d7 <print_insn_i386+0x6e9>
f01085ce:	80 3d 50 94 2a f0 00 	cmpb   $0x0,0xf02a9450
f01085d5:	74 31                	je     f0108608 <print_insn_i386+0x71a>
f01085d7:	f7 c7 02 00 00 00    	test   $0x2,%edi
f01085dd:	75 09                	jne    f01085e8 <print_insn_i386+0x6fa>
f01085df:	83 3d 60 91 2a f0 00 	cmpl   $0x0,0xf02a9160
f01085e6:	74 0c                	je     f01085f4 <print_insn_i386+0x706>
f01085e8:	b8 75 c1 10 f0       	mov    $0xf010c175,%eax
f01085ed:	e8 6d dc ff ff       	call   f010625f <oappend>
f01085f2:	eb 0a                	jmp    f01085fe <print_insn_i386+0x710>
f01085f4:	b8 7d c1 10 f0       	mov    $0xf010c17d,%eax
f01085f9:	e8 61 dc ff ff       	call   f010625f <oappend>
f01085fe:	81 0d 70 91 2a f0 00 	orl    $0x400,0xf02a9170
f0108605:	04 00 00 
f0108608:	89 f2                	mov    %esi,%edx
f010860a:	84 d2                	test   %dl,%dl
f010860c:	75 49                	jne    f0108657 <print_insn_i386+0x769>
f010860e:	f6 05 65 91 2a f0 02 	testb  $0x2,0xf02a9165
f0108615:	74 40                	je     f0108657 <print_insn_i386+0x769>
f0108617:	83 f7 01             	xor    $0x1,%edi
f010861a:	83 7b 18 08          	cmpl   $0x8,0x18(%ebx)
f010861e:	75 37                	jne    f0108657 <print_insn_i386+0x769>
f0108620:	83 7b 08 02          	cmpl   $0x2,0x8(%ebx)
f0108624:	75 31                	jne    f0108657 <print_insn_i386+0x769>
f0108626:	80 3d 50 94 2a f0 00 	cmpb   $0x0,0xf02a9450
f010862d:	75 28                	jne    f0108657 <print_insn_i386+0x769>
f010862f:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0108635:	74 0c                	je     f0108643 <print_insn_i386+0x755>
f0108637:	b8 85 c1 10 f0       	mov    $0xf010c185,%eax
f010863c:	e8 1e dc ff ff       	call   f010625f <oappend>
f0108641:	eb 0a                	jmp    f010864d <print_insn_i386+0x75f>
f0108643:	b8 8d c1 10 f0       	mov    $0xf010c18d,%eax
f0108648:	e8 12 dc ff ff       	call   f010625f <oappend>
f010864d:	81 0d 70 91 2a f0 00 	orl    $0x200,0xf02a9170
f0108654:	02 00 00 
f0108657:	80 3d 80 92 2a f0 00 	cmpb   $0x0,0xf02a9280
f010865e:	74 45                	je     f01086a5 <print_insn_i386+0x7b7>
f0108660:	8b 15 6c 92 2a f0    	mov    0xf02a926c,%edx
f0108666:	83 c2 01             	add    $0x1,%edx
f0108669:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010866c:	8b 41 20             	mov    0x20(%ecx),%eax
f010866f:	3b 10                	cmp    (%eax),%edx
f0108671:	76 07                	jbe    f010867a <print_insn_i386+0x78c>
f0108673:	89 c8                	mov    %ecx,%eax
f0108675:	e8 66 d0 ff ff       	call   f01056e0 <fetch_data>
f010867a:	a1 6c 92 2a f0       	mov    0xf02a926c,%eax
f010867f:	0f b6 10             	movzbl (%eax),%edx
f0108682:	89 d0                	mov    %edx,%eax
f0108684:	c0 e8 06             	shr    $0x6,%al
f0108687:	83 e0 03             	and    $0x3,%eax
f010868a:	a3 74 92 2a f0       	mov    %eax,0xf02a9274
f010868f:	89 d0                	mov    %edx,%eax
f0108691:	c0 e8 03             	shr    $0x3,%al
f0108694:	83 e0 07             	and    $0x7,%eax
f0108697:	a3 7c 92 2a f0       	mov    %eax,0xf02a927c
f010869c:	83 e2 07             	and    $0x7,%edx
f010869f:	89 15 78 92 2a f0    	mov    %edx,0xf02a9278
f01086a5:	83 3b 00             	cmpl   $0x0,(%ebx)
f01086a8:	0f 85 26 02 00 00    	jne    f01088d4 <print_insn_i386+0x9e6>
f01086ae:	8b 43 08             	mov    0x8(%ebx),%eax
f01086b1:	83 f8 01             	cmp    $0x1,%eax
f01086b4:	0f 85 6e 01 00 00    	jne    f0108828 <print_insn_i386+0x93a>
f01086ba:	a1 6c 92 2a f0       	mov    0xf02a926c,%eax
f01086bf:	0f b6 58 ff          	movzbl 0xffffffff(%eax),%ebx
f01086c3:	83 3d 74 92 2a f0 03 	cmpl   $0x3,0xf02a9274
f01086ca:	74 6d                	je     f0108739 <print_insn_i386+0x84b>
f01086cc:	0f b6 c3             	movzbl %bl,%eax
f01086cf:	c1 e0 03             	shl    $0x3,%eax
f01086d2:	03 05 7c 92 2a f0    	add    0xf02a927c,%eax
f01086d8:	8b 04 85 a0 1f 11 f0 	mov    0xf0111fa0(,%eax,4),%eax
f01086df:	89 fa                	mov    %edi,%edx
f01086e1:	e8 11 d4 ff ff       	call   f0105af7 <putop>
f01086e6:	c7 05 e4 91 2a f0 a0 	movl   $0xf02a92a0,0xf02a91e4
f01086ed:	92 2a f0 
f01086f0:	80 fb db             	cmp    $0xdb,%bl
f01086f3:	75 15                	jne    f010870a <print_insn_i386+0x81c>
f01086f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01086f9:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
f0108700:	e8 ef eb ff ff       	call   f01072f4 <OP_E>
f0108705:	e9 4c 02 00 00       	jmp    f0108956 <print_insn_i386+0xa68>
f010870a:	80 fb dd             	cmp    $0xdd,%bl
f010870d:	75 15                	jne    f0108724 <print_insn_i386+0x836>
f010870f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0108713:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
f010871a:	e8 d5 eb ff ff       	call   f01072f4 <OP_E>
f010871f:	e9 32 02 00 00       	jmp    f0108956 <print_insn_i386+0xa68>
f0108724:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0108728:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
f010872f:	e8 c0 eb ff ff       	call   f01072f4 <OP_E>
f0108734:	e9 1d 02 00 00       	jmp    f0108956 <print_insn_i386+0xa68>
f0108739:	80 3d 80 92 2a f0 00 	cmpb   $0x0,0xf02a9280
f0108740:	75 1c                	jne    f010875e <print_insn_i386+0x870>
f0108742:	c7 44 24 08 c4 c0 10 	movl   $0xf010c0c4,0x8(%esp)
f0108749:	f0 
f010874a:	c7 44 24 04 ef 09 00 	movl   $0x9ef,0x4(%esp)
f0108751:	00 
f0108752:	c7 04 24 07 c0 10 f0 	movl   $0xf010c007,(%esp)
f0108759:	e8 28 79 ff ff       	call   f0100086 <_panic>
f010875e:	83 c0 01             	add    $0x1,%eax
f0108761:	a3 6c 92 2a f0       	mov    %eax,0xf02a926c
f0108766:	0f b6 c3             	movzbl %bl,%eax
f0108769:	69 c0 e0 00 00 00    	imul   $0xe0,%eax,%eax
f010876f:	6b 15 7c 92 2a f0 1c 	imul   $0x1c,0xf02a927c,%edx
f0108776:	01 d0                	add    %edx,%eax
f0108778:	8d b0 a0 7e 10 f0    	lea    0xf0107ea0(%eax),%esi
f010877e:	8b 80 a0 7e 10 f0    	mov    0xf0107ea0(%eax),%eax
f0108784:	85 c0                	test   %eax,%eax
f0108786:	75 56                	jne    f01087de <print_insn_i386+0x8f0>
f0108788:	8b 46 08             	mov    0x8(%esi),%eax
f010878b:	c1 e0 03             	shl    $0x3,%eax
f010878e:	03 05 78 92 2a f0    	add    0xf02a9278,%eax
f0108794:	8b 04 85 a0 42 11 f0 	mov    0xf01142a0(,%eax,4),%eax
f010879b:	89 fa                	mov    %edi,%edx
f010879d:	e8 55 d3 ff ff       	call   f0105af7 <putop>
f01087a2:	80 fb df             	cmp    $0xdf,%bl
f01087a5:	0f 85 ab 01 00 00    	jne    f0108956 <print_insn_i386+0xa68>
f01087ab:	a1 6c 92 2a f0       	mov    0xf02a926c,%eax
f01087b0:	80 78 ff e0          	cmpb   $0xe0,0xffffffff(%eax)
f01087b4:	0f 85 9c 01 00 00    	jne    f0108956 <print_insn_i386+0xa68>
f01087ba:	a1 8c 92 2a f0       	mov    0xf02a928c,%eax
f01087bf:	8b 00                	mov    (%eax),%eax
f01087c1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01087c5:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f01087cc:	00 
f01087cd:	c7 04 24 a0 92 2a f0 	movl   $0xf02a92a0,(%esp)
f01087d4:	e8 c4 0e 00 00       	call   f010969d <pstrcpy>
f01087d9:	e9 78 01 00 00       	jmp    f0108956 <print_insn_i386+0xa68>
f01087de:	89 fa                	mov    %edi,%edx
f01087e0:	e8 12 d3 ff ff       	call   f0105af7 <putop>
f01087e5:	c7 05 e4 91 2a f0 a0 	movl   $0xf02a92a0,0xf02a91e4
f01087ec:	92 2a f0 
f01087ef:	8b 56 04             	mov    0x4(%esi),%edx
f01087f2:	85 d2                	test   %edx,%edx
f01087f4:	74 0c                	je     f0108802 <print_insn_i386+0x914>
f01087f6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01087fa:	8b 46 08             	mov    0x8(%esi),%eax
f01087fd:	89 04 24             	mov    %eax,(%esp)
f0108800:	ff d2                	call   *%edx
f0108802:	c7 05 e4 91 2a f0 20 	movl   $0xf02a9320,0xf02a91e4
f0108809:	93 2a f0 
f010880c:	8b 56 0c             	mov    0xc(%esi),%edx
f010880f:	85 d2                	test   %edx,%edx
f0108811:	0f 84 3f 01 00 00    	je     f0108956 <print_insn_i386+0xa68>
f0108817:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010881b:	8b 46 10             	mov    0x10(%esi),%eax
f010881e:	89 04 24             	mov    %eax,(%esp)
f0108821:	ff d2                	call   *%edx
f0108823:	e9 2e 01 00 00       	jmp    f0108956 <print_insn_i386+0xa68>
f0108828:	83 f8 03             	cmp    $0x3,%eax
f010882b:	74 29                	je     f0108856 <print_insn_i386+0x968>
f010882d:	83 f8 04             	cmp    $0x4,%eax
f0108830:	0f 84 80 00 00 00    	je     f01088b6 <print_insn_i386+0x9c8>
f0108836:	83 f8 02             	cmp    $0x2,%eax
f0108839:	0f 85 8b 00 00 00    	jne    f01088ca <print_insn_i386+0x9dc>
f010883f:	69 53 10 e0 00 00 00 	imul   $0xe0,0x10(%ebx),%edx
f0108846:	6b 05 7c 92 2a f0 1c 	imul   $0x1c,0xf02a927c,%eax
f010884d:	8d 9c 02 40 16 11 f0 	lea    0xf0111640(%edx,%eax,1),%ebx
f0108854:	eb 7e                	jmp    f01088d4 <print_insn_i386+0x9e6>
f0108856:	8b 15 64 91 2a f0    	mov    0xf02a9164,%edx
f010885c:	89 d0                	mov    %edx,%eax
f010885e:	83 e0 01             	and    $0x1,%eax
f0108861:	89 c6                	mov    %eax,%esi
f0108863:	0b 35 70 91 2a f0    	or     0xf02a9170,%esi
f0108869:	89 35 70 91 2a f0    	mov    %esi,0xf02a9170
f010886f:	b9 01 00 00 00       	mov    $0x1,%ecx
f0108874:	85 c0                	test   %eax,%eax
f0108876:	75 2e                	jne    f01088a6 <print_insn_i386+0x9b8>
f0108878:	89 d0                	mov    %edx,%eax
f010887a:	25 00 02 00 00       	and    $0x200,%eax
f010887f:	09 c6                	or     %eax,%esi
f0108881:	89 35 70 91 2a f0    	mov    %esi,0xf02a9170
f0108887:	b9 02 00 00 00       	mov    $0x2,%ecx
f010888c:	85 c0                	test   %eax,%eax
f010888e:	75 16                	jne    f01088a6 <print_insn_i386+0x9b8>
f0108890:	83 e2 02             	and    $0x2,%edx
f0108893:	89 f0                	mov    %esi,%eax
f0108895:	09 d0                	or     %edx,%eax
f0108897:	a3 70 91 2a f0       	mov    %eax,0xf02a9170
f010889c:	83 fa 01             	cmp    $0x1,%edx
f010889f:	19 c9                	sbb    %ecx,%ecx
f01088a1:	f7 d1                	not    %ecx
f01088a3:	83 e1 03             	and    $0x3,%ecx
f01088a6:	6b 53 10 70          	imul   $0x70,0x10(%ebx),%edx
f01088aa:	6b c1 1c             	imul   $0x1c,%ecx,%eax
f01088ad:	8d 9c 02 60 2a 11 f0 	lea    0xf0112a60(%edx,%eax,1),%ebx
f01088b4:	eb 1e                	jmp    f01088d4 <print_insn_i386+0x9e6>
f01088b6:	6b 53 10 38          	imul   $0x38,0x10(%ebx),%edx
f01088ba:	6b 05 60 91 2a f0 1c 	imul   $0x1c,0xf02a9160,%eax
f01088c1:	8d 9c 02 40 36 11 f0 	lea    0xf0113640(%edx,%eax,1),%ebx
f01088c8:	eb 0a                	jmp    f01088d4 <print_insn_i386+0x9e6>
f01088ca:	b8 82 c0 10 f0       	mov    $0xf010c082,%eax
f01088cf:	e8 8b d9 ff ff       	call   f010625f <oappend>
f01088d4:	89 fa                	mov    %edi,%edx
f01088d6:	8b 03                	mov    (%ebx),%eax
f01088d8:	e8 1a d2 ff ff       	call   f0105af7 <putop>
f01088dd:	85 c0                	test   %eax,%eax
f01088df:	75 75                	jne    f0108956 <print_insn_i386+0xa68>
f01088e1:	c7 05 e4 91 2a f0 a0 	movl   $0xf02a92a0,0xf02a91e4
f01088e8:	92 2a f0 
f01088eb:	c7 05 04 94 2a f0 02 	movl   $0x2,0xf02a9404
f01088f2:	00 00 00 
f01088f5:	8b 53 04             	mov    0x4(%ebx),%edx
f01088f8:	85 d2                	test   %edx,%edx
f01088fa:	74 0c                	je     f0108908 <print_insn_i386+0xa1a>
f01088fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0108900:	8b 43 08             	mov    0x8(%ebx),%eax
f0108903:	89 04 24             	mov    %eax,(%esp)
f0108906:	ff d2                	call   *%edx
f0108908:	c7 05 e4 91 2a f0 20 	movl   $0xf02a9320,0xf02a91e4
f010890f:	93 2a f0 
f0108912:	c7 05 04 94 2a f0 01 	movl   $0x1,0xf02a9404
f0108919:	00 00 00 
f010891c:	8b 53 0c             	mov    0xc(%ebx),%edx
f010891f:	85 d2                	test   %edx,%edx
f0108921:	74 0c                	je     f010892f <print_insn_i386+0xa41>
f0108923:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0108927:	8b 43 10             	mov    0x10(%ebx),%eax
f010892a:	89 04 24             	mov    %eax,(%esp)
f010892d:	ff d2                	call   *%edx
f010892f:	c7 05 e4 91 2a f0 a0 	movl   $0xf02a93a0,0xf02a91e4
f0108936:	93 2a f0 
f0108939:	c7 05 04 94 2a f0 00 	movl   $0x0,0xf02a9404
f0108940:	00 00 00 
f0108943:	8b 53 14             	mov    0x14(%ebx),%edx
f0108946:	85 d2                	test   %edx,%edx
f0108948:	74 0c                	je     f0108956 <print_insn_i386+0xa68>
f010894a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010894e:	8b 43 18             	mov    0x18(%ebx),%eax
f0108951:	89 04 24             	mov    %eax,(%esp)
f0108954:	ff d2                	call   *%edx
f0108956:	a1 70 91 2a f0       	mov    0xf02a9170,%eax
f010895b:	f7 d0                	not    %eax
f010895d:	85 05 64 91 2a f0    	test   %eax,0xf02a9164
f0108963:	74 2f                	je     f0108994 <print_insn_i386+0xaa6>
f0108965:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
f0108968:	0f b6 45 d4          	movzbl 0xffffffd4(%ebp),%eax
f010896c:	e8 fa cd ff ff       	call   f010576b <prefix_name>
f0108971:	85 c0                	test   %eax,%eax
f0108973:	75 05                	jne    f010897a <print_insn_i386+0xa8c>
f0108975:	b8 82 c0 10 f0       	mov    $0xf010c082,%eax
f010897a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010897e:	c7 04 24 9e b7 10 f0 	movl   $0xf010b79e,(%esp)
f0108985:	e8 ad b0 ff ff       	call   f0103a37 <cprintf>
f010898a:	b8 01 00 00 00       	mov    $0x1,%eax
f010898f:	e9 ae 02 00 00       	jmp    f0108c42 <print_insn_i386+0xd54>
f0108994:	8b 0d 68 91 2a f0    	mov    0xf02a9168,%ecx
f010899a:	a1 6c 91 2a f0       	mov    0xf02a916c,%eax
f010899f:	f7 d0                	not    %eax
f01089a1:	85 c1                	test   %eax,%ecx
f01089a3:	74 26                	je     f01089cb <print_insn_i386+0xadd>
f01089a5:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
f01089a8:	89 c8                	mov    %ecx,%eax
f01089aa:	83 c8 40             	or     $0x40,%eax
f01089ad:	e8 b9 cd ff ff       	call   f010576b <prefix_name>
f01089b2:	85 c0                	test   %eax,%eax
f01089b4:	75 05                	jne    f01089bb <print_insn_i386+0xacd>
f01089b6:	b8 82 c0 10 f0       	mov    $0xf010c082,%eax
f01089bb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01089bf:	c7 04 24 9e b7 10 f0 	movl   $0xf010b79e,(%esp)
f01089c6:	e8 6c b0 ff ff       	call   f0103a37 <cprintf>
f01089cb:	c7 04 24 80 91 2a f0 	movl   $0xf02a9180,(%esp)
f01089d2:	e8 d9 0b 00 00       	call   f01095b0 <strlen>
f01089d7:	05 80 91 2a f0       	add    $0xf02a9180,%eax
f01089dc:	a3 e4 91 2a f0       	mov    %eax,0xf02a91e4
f01089e1:	c7 04 24 80 91 2a f0 	movl   $0xf02a9180,(%esp)
f01089e8:	e8 c3 0b 00 00       	call   f01095b0 <strlen>
f01089ed:	89 c3                	mov    %eax,%ebx
f01089ef:	83 f8 05             	cmp    $0x5,%eax
f01089f2:	7f 12                	jg     f0108a06 <print_insn_i386+0xb18>
f01089f4:	b8 77 ab 10 f0       	mov    $0xf010ab77,%eax
f01089f9:	e8 61 d8 ff ff       	call   f010625f <oappend>
f01089fe:	83 c3 01             	add    $0x1,%ebx
f0108a01:	83 fb 06             	cmp    $0x6,%ebx
f0108a04:	75 ee                	jne    f01089f4 <print_insn_i386+0xb06>
f0108a06:	b8 77 ab 10 f0       	mov    $0xf010ab77,%eax
f0108a0b:	e8 4f d8 ff ff       	call   f010625f <oappend>
f0108a10:	c7 44 24 04 80 91 2a 	movl   $0xf02a9180,0x4(%esp)
f0108a17:	f0 
f0108a18:	c7 04 24 9e b7 10 f0 	movl   $0xf010b79e,(%esp)
f0108a1f:	e8 13 b0 ff ff       	call   f0103a37 <cprintf>
f0108a24:	80 3d 50 94 2a f0 00 	cmpb   $0x0,0xf02a9450
f0108a2b:	75 16                	jne    f0108a43 <print_insn_i386+0xb55>
f0108a2d:	80 7d c3 62          	cmpb   $0x62,0xffffffc3(%ebp)
f0108a31:	74 10                	je     f0108a43 <print_insn_i386+0xb55>
f0108a33:	ba a0 93 2a f0       	mov    $0xf02a93a0,%edx
f0108a38:	bb a0 92 2a f0       	mov    $0xf02a92a0,%ebx
f0108a3d:	80 7d c3 c8          	cmpb   $0xc8,0xffffffc3(%ebp)
f0108a41:	75 26                	jne    f0108a69 <print_insn_i386+0xb7b>
f0108a43:	8b 15 08 94 2a f0    	mov    0xf02a9408,%edx
f0108a49:	89 15 04 94 2a f0    	mov    %edx,0xf02a9404
f0108a4f:	a1 10 94 2a f0       	mov    0xf02a9410,%eax
f0108a54:	a3 08 94 2a f0       	mov    %eax,0xf02a9408
f0108a59:	89 15 10 94 2a f0    	mov    %edx,0xf02a9410
f0108a5f:	ba a0 92 2a f0       	mov    $0xf02a92a0,%edx
f0108a64:	bb a0 93 2a f0       	mov    $0xf02a93a0,%ebx
f0108a69:	b8 00 00 00 00       	mov    $0x0,%eax
f0108a6e:	80 3a 00             	cmpb   $0x0,(%edx)
f0108a71:	74 56                	je     f0108ac9 <print_insn_i386+0xbdb>
f0108a73:	8b 0d 08 94 2a f0    	mov    0xf02a9408,%ecx
f0108a79:	83 f9 ff             	cmp    $0xffffffff,%ecx
f0108a7c:	74 36                	je     f0108ab4 <print_insn_i386+0xbc6>
f0108a7e:	a1 30 94 2a f0       	mov    0xf02a9430,%eax
f0108a83:	0b 05 34 94 2a f0    	or     0xf02a9434,%eax
f0108a89:	75 29                	jne    f0108ab4 <print_insn_i386+0xbc6>
f0108a8b:	8b 45 10             	mov    0x10(%ebp),%eax
f0108a8e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108a92:	8b 04 cd 18 94 2a f0 	mov    0xf02a9418(,%ecx,8),%eax
f0108a99:	8b 14 cd 1c 94 2a f0 	mov    0xf02a941c(,%ecx,8),%edx
f0108aa0:	89 04 24             	mov    %eax,(%esp)
f0108aa3:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108aa7:	8b 55 10             	mov    0x10(%ebp),%edx
f0108aaa:	ff 52 2c             	call   *0x2c(%edx)
f0108aad:	b8 01 00 00 00       	mov    $0x1,%eax
f0108ab2:	eb 15                	jmp    f0108ac9 <print_insn_i386+0xbdb>
f0108ab4:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108ab8:	c7 04 24 9e b7 10 f0 	movl   $0xf010b79e,(%esp)
f0108abf:	e8 73 af ff ff       	call   f0103a37 <cprintf>
f0108ac4:	b8 01 00 00 00       	mov    $0x1,%eax
f0108ac9:	80 3d 20 93 2a f0 00 	cmpb   $0x0,0xf02a9320
f0108ad0:	74 6f                	je     f0108b41 <print_insn_i386+0xc53>
f0108ad2:	85 c0                	test   %eax,%eax
f0108ad4:	74 14                	je     f0108aea <print_insn_i386+0xbfc>
f0108ad6:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
f0108add:	00 
f0108ade:	c7 04 24 3c c0 10 f0 	movl   $0xf010c03c,(%esp)
f0108ae5:	e8 4d af ff ff       	call   f0103a37 <cprintf>
f0108aea:	8b 15 0c 94 2a f0    	mov    0xf02a940c,%edx
f0108af0:	83 fa ff             	cmp    $0xffffffff,%edx
f0108af3:	74 33                	je     f0108b28 <print_insn_i386+0xc3a>
f0108af5:	a1 38 94 2a f0       	mov    0xf02a9438,%eax
f0108afa:	0b 05 3c 94 2a f0    	or     0xf02a943c,%eax
f0108b00:	75 26                	jne    f0108b28 <print_insn_i386+0xc3a>
f0108b02:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0108b05:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0108b09:	8b 04 d5 18 94 2a f0 	mov    0xf02a9418(,%edx,8),%eax
f0108b10:	8b 14 d5 1c 94 2a f0 	mov    0xf02a941c(,%edx,8),%edx
f0108b17:	89 04 24             	mov    %eax,(%esp)
f0108b1a:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108b1e:	ff 51 2c             	call   *0x2c(%ecx)
f0108b21:	b8 01 00 00 00       	mov    $0x1,%eax
f0108b26:	eb 19                	jmp    f0108b41 <print_insn_i386+0xc53>
f0108b28:	c7 44 24 04 20 93 2a 	movl   $0xf02a9320,0x4(%esp)
f0108b2f:	f0 
f0108b30:	c7 04 24 9e b7 10 f0 	movl   $0xf010b79e,(%esp)
f0108b37:	e8 fb ae ff ff       	call   f0103a37 <cprintf>
f0108b3c:	b8 01 00 00 00       	mov    $0x1,%eax
f0108b41:	80 3b 00             	cmpb   $0x0,(%ebx)
f0108b44:	74 64                	je     f0108baa <print_insn_i386+0xcbc>
f0108b46:	85 c0                	test   %eax,%eax
f0108b48:	74 14                	je     f0108b5e <print_insn_i386+0xc70>
f0108b4a:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
f0108b51:	00 
f0108b52:	c7 04 24 3c c0 10 f0 	movl   $0xf010c03c,(%esp)
f0108b59:	e8 d9 ae ff ff       	call   f0103a37 <cprintf>
f0108b5e:	8b 15 10 94 2a f0    	mov    0xf02a9410,%edx
f0108b64:	83 fa ff             	cmp    $0xffffffff,%edx
f0108b67:	74 31                	je     f0108b9a <print_insn_i386+0xcac>
f0108b69:	a1 40 94 2a f0       	mov    0xf02a9440,%eax
f0108b6e:	0b 05 44 94 2a f0    	or     0xf02a9444,%eax
f0108b74:	75 24                	jne    f0108b9a <print_insn_i386+0xcac>
f0108b76:	8b 45 10             	mov    0x10(%ebp),%eax
f0108b79:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108b7d:	8b 04 d5 18 94 2a f0 	mov    0xf02a9418(,%edx,8),%eax
f0108b84:	8b 14 d5 1c 94 2a f0 	mov    0xf02a941c(,%edx,8),%edx
f0108b8b:	89 04 24             	mov    %eax,(%esp)
f0108b8e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108b92:	8b 55 10             	mov    0x10(%ebp),%edx
f0108b95:	ff 52 2c             	call   *0x2c(%edx)
f0108b98:	eb 10                	jmp    f0108baa <print_insn_i386+0xcbc>
f0108b9a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0108b9e:	c7 04 24 9e b7 10 f0 	movl   $0xf010b79e,(%esp)
f0108ba5:	e8 8d ae ff ff       	call   f0103a37 <cprintf>
f0108baa:	bb 00 00 00 00       	mov    $0x0,%ebx
f0108baf:	83 3c 9d 08 94 2a f0 	cmpl   $0xffffffff,0xf02a9408(,%ebx,4)
f0108bb6:	ff 
f0108bb7:	74 63                	je     f0108c1c <print_insn_i386+0xd2e>
f0108bb9:	8b 04 dd 30 94 2a f0 	mov    0xf02a9430(,%ebx,8),%eax
f0108bc0:	0b 04 dd 34 94 2a f0 	or     0xf02a9434(,%ebx,8),%eax
f0108bc7:	74 53                	je     f0108c1c <print_insn_i386+0xd2e>
f0108bc9:	c7 44 24 04 95 c1 10 	movl   $0xf010c195,0x4(%esp)
f0108bd0:	f0 
f0108bd1:	c7 04 24 9e b7 10 f0 	movl   $0xf010b79e,(%esp)
f0108bd8:	e8 5a ae ff ff       	call   f0103a37 <cprintf>
f0108bdd:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0108be0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0108be4:	a1 6c 92 2a f0       	mov    0xf02a926c,%eax
f0108be9:	03 05 48 94 2a f0    	add    0xf02a9448,%eax
f0108bef:	2b 05 64 92 2a f0    	sub    0xf02a9264,%eax
f0108bf5:	89 c2                	mov    %eax,%edx
f0108bf7:	c1 fa 1f             	sar    $0x1f,%edx
f0108bfa:	8b 0c 9d 08 94 2a f0 	mov    0xf02a9408(,%ebx,4),%ecx
f0108c01:	03 04 cd 18 94 2a f0 	add    0xf02a9418(,%ecx,8),%eax
f0108c08:	13 14 cd 1c 94 2a f0 	adc    0xf02a941c(,%ecx,8),%edx
f0108c0f:	89 04 24             	mov    %eax,(%esp)
f0108c12:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108c16:	8b 45 10             	mov    0x10(%ebp),%eax
f0108c19:	ff 50 2c             	call   *0x2c(%eax)
f0108c1c:	83 c3 01             	add    $0x1,%ebx
f0108c1f:	83 fb 03             	cmp    $0x3,%ebx
f0108c22:	75 8b                	jne    f0108baf <print_insn_i386+0xcc1>
f0108c24:	8d 55 d4             	lea    0xffffffd4(%ebp),%edx
f0108c27:	a1 6c 92 2a f0       	mov    0xf02a926c,%eax
f0108c2c:	29 d0                	sub    %edx,%eax
f0108c2e:	eb 12                	jmp    f0108c42 <print_insn_i386+0xd54>
f0108c30:	f6 05 64 91 2a f0 02 	testb  $0x2,0xf02a9164
f0108c37:	0f 84 65 f9 ff ff    	je     f01085a2 <print_insn_i386+0x6b4>
f0108c3d:	e9 4f f9 ff ff       	jmp    f0108591 <print_insn_i386+0x6a3>
f0108c42:	83 c4 4c             	add    $0x4c,%esp
f0108c45:	5b                   	pop    %ebx
f0108c46:	5e                   	pop    %esi
f0108c47:	5f                   	pop    %edi
f0108c48:	5d                   	pop    %ebp
f0108c49:	c3                   	ret    
f0108c4a:	00 00                	add    %al,(%eax)
f0108c4c:	00 00                	add    %al,(%eax)
	...

f0108c50 <generic_symbol_at_address>:
/* Just return the given address.  */

int
generic_symbol_at_address (bfd_vma addr, struct disassemble_info *info)
{
f0108c50:	55                   	push   %ebp
f0108c51:	89 e5                	mov    %esp,%ebp
  return 1;
}
f0108c53:	b8 01 00 00 00       	mov    $0x1,%eax
f0108c58:	5d                   	pop    %ebp
f0108c59:	c3                   	ret    

f0108c5a <bfd_getl32>:

bfd_vma bfd_getl32 (const bfd_byte *addr)
{
f0108c5a:	55                   	push   %ebp
f0108c5b:	89 e5                	mov    %esp,%ebp
f0108c5d:	83 ec 08             	sub    $0x8,%esp
f0108c60:	89 1c 24             	mov    %ebx,(%esp)
f0108c63:	89 74 24 04          	mov    %esi,0x4(%esp)
f0108c67:	8b 5d 08             	mov    0x8(%ebp),%ebx
  unsigned long v;

  v = (unsigned long) addr[0];
f0108c6a:	0f b6 33             	movzbl (%ebx),%esi
  v |= (unsigned long) addr[1] << 8;
f0108c6d:	0f b6 43 01          	movzbl 0x1(%ebx),%eax
f0108c71:	c1 e0 08             	shl    $0x8,%eax
f0108c74:	0f b6 4b 02          	movzbl 0x2(%ebx),%ecx
f0108c78:	c1 e1 10             	shl    $0x10,%ecx
f0108c7b:	09 c8                	or     %ecx,%eax
  v |= (unsigned long) addr[2] << 16;
f0108c7d:	09 f0                	or     %esi,%eax
f0108c7f:	0f b6 4b 03          	movzbl 0x3(%ebx),%ecx
f0108c83:	c1 e1 18             	shl    $0x18,%ecx
f0108c86:	09 c8                	or     %ecx,%eax
f0108c88:	ba 00 00 00 00       	mov    $0x0,%edx
  v |= (unsigned long) addr[3] << 24;
  return (bfd_vma) v;
}
f0108c8d:	8b 1c 24             	mov    (%esp),%ebx
f0108c90:	8b 74 24 04          	mov    0x4(%esp),%esi
f0108c94:	89 ec                	mov    %ebp,%esp
f0108c96:	5d                   	pop    %ebp
f0108c97:	c3                   	ret    

f0108c98 <bfd_getb32>:

bfd_vma bfd_getb32 (const bfd_byte *addr)
{
f0108c98:	55                   	push   %ebp
f0108c99:	89 e5                	mov    %esp,%ebp
f0108c9b:	53                   	push   %ebx
f0108c9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  unsigned long v;

  v = (unsigned long) addr[0] << 24;
f0108c9f:	0f b6 0b             	movzbl (%ebx),%ecx
f0108ca2:	c1 e1 18             	shl    $0x18,%ecx
  v |= (unsigned long) addr[1] << 16;
f0108ca5:	0f b6 43 03          	movzbl 0x3(%ebx),%eax
f0108ca9:	09 c8                	or     %ecx,%eax
  v |= (unsigned long) addr[2] << 8;
f0108cab:	0f b6 4b 01          	movzbl 0x1(%ebx),%ecx
f0108caf:	c1 e1 10             	shl    $0x10,%ecx
f0108cb2:	09 c8                	or     %ecx,%eax
f0108cb4:	0f b6 4b 02          	movzbl 0x2(%ebx),%ecx
f0108cb8:	c1 e1 08             	shl    $0x8,%ecx
f0108cbb:	09 c8                	or     %ecx,%eax
f0108cbd:	ba 00 00 00 00       	mov    $0x0,%edx
  v |= (unsigned long) addr[3];
  return (bfd_vma) v;
}
f0108cc2:	5b                   	pop    %ebx
f0108cc3:	5d                   	pop    %ebp
f0108cc4:	c3                   	ret    

f0108cc5 <bfd_getl16>:

bfd_vma bfd_getl16 (const bfd_byte *addr)
{
f0108cc5:	55                   	push   %ebp
f0108cc6:	89 e5                	mov    %esp,%ebp
f0108cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  unsigned long v;

  v = (unsigned long) addr[0];
f0108ccb:	0f b6 08             	movzbl (%eax),%ecx
f0108cce:	0f b6 40 01          	movzbl 0x1(%eax),%eax
f0108cd2:	c1 e0 08             	shl    $0x8,%eax
f0108cd5:	09 c8                	or     %ecx,%eax
f0108cd7:	ba 00 00 00 00       	mov    $0x0,%edx
  v |= (unsigned long) addr[1] << 8;
  return (bfd_vma) v;
}
f0108cdc:	5d                   	pop    %ebp
f0108cdd:	c3                   	ret    

f0108cde <bfd_getb16>:

bfd_vma bfd_getb16 (const bfd_byte *addr)
{
f0108cde:	55                   	push   %ebp
f0108cdf:	89 e5                	mov    %esp,%ebp
f0108ce1:	8b 45 08             	mov    0x8(%ebp),%eax
  unsigned long v;

  v = (unsigned long) addr[0] << 24;
f0108ce4:	0f b6 08             	movzbl (%eax),%ecx
f0108ce7:	c1 e1 18             	shl    $0x18,%ecx
f0108cea:	0f b6 40 01          	movzbl 0x1(%eax),%eax
f0108cee:	c1 e0 10             	shl    $0x10,%eax
f0108cf1:	09 c8                	or     %ecx,%eax
f0108cf3:	ba 00 00 00 00       	mov    $0x0,%edx
  v |= (unsigned long) addr[1] << 16;
  return (bfd_vma) v;
}
f0108cf8:	5d                   	pop    %ebp
f0108cf9:	c3                   	ret    

f0108cfa <monitor_disas>:

void monitor_disas(uint32_t pc, int nb_insn)
{
f0108cfa:	55                   	push   %ebp
f0108cfb:	89 e5                	mov    %esp,%ebp
f0108cfd:	57                   	push   %edi
f0108cfe:	56                   	push   %esi
f0108cff:	53                   	push   %ebx
f0108d00:	83 ec 7c             	sub    $0x7c,%esp
f0108d03:	8b 75 08             	mov    0x8(%ebp),%esi
    int count, i;
    struct disassemble_info disasm_info;
    int (*print_insn)(bfd_vma pc, disassemble_info *info);
    
    INIT_DISASSEMBLE_INFO(disasm_info, NULL, cprintf);
f0108d06:	c7 45 8c 00 00 00 00 	movl   $0x0,0xffffff8c(%ebp)
f0108d0d:	c7 45 90 00 00 00 00 	movl   $0x0,0xffffff90(%ebp)
f0108d14:	c7 45 94 00 00 00 00 	movl   $0x0,0xffffff94(%ebp)
f0108d1b:	c7 45 98 02 00 00 00 	movl   $0x2,0xffffff98(%ebp)
f0108d22:	c7 45 9c 00 00 00 00 	movl   $0x0,0xffffff9c(%ebp)
f0108d29:	c7 45 a0 00 00 00 00 	movl   $0x0,0xffffffa0(%ebp)
f0108d30:	c7 45 a8 00 00 00 00 	movl   $0x0,0xffffffa8(%ebp)
f0108d37:	c7 45 ac 5e 8e 10 f0 	movl   $0xf0108e5e,0xffffffac(%ebp)
f0108d3e:	c7 45 b0 22 8e 10 f0 	movl   $0xf0108e22,0xffffffb0(%ebp)
f0108d45:	c7 45 b4 00 8e 10 f0 	movl   $0xf0108e00,0xffffffb4(%ebp)
f0108d4c:	c7 45 b8 50 8c 10 f0 	movl   $0xf0108c50,0xffffffb8(%ebp)
f0108d53:	c7 45 a4 00 00 00 00 	movl   $0x0,0xffffffa4(%ebp)
f0108d5a:	c7 45 cc 00 00 00 00 	movl   $0x0,0xffffffcc(%ebp)
f0108d61:	c7 45 d0 00 00 00 00 	movl   $0x0,0xffffffd0(%ebp)
f0108d68:	c7 45 d4 02 00 00 00 	movl   $0x2,0xffffffd4(%ebp)
f0108d6f:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
f0108d76:	c6 45 d8 00          	movb   $0x0,0xffffffd8(%ebp)

    //monitor_disas_env = env;
    //monitor_disas_is_physical = is_physical;
    //disasm_info.read_memory_func = monitor_read_memory;

    disasm_info.buffer_vma = pc;
f0108d7a:	89 75 c0             	mov    %esi,0xffffffc0(%ebp)
f0108d7d:	c7 45 c4 00 00 00 00 	movl   $0x0,0xffffffc4(%ebp)
    disasm_info.buffer_length=7;
f0108d84:	c7 45 c8 07 00 00 00 	movl   $0x7,0xffffffc8(%ebp)
    disasm_info.buffer=(bfd_byte *)pc;
f0108d8b:	89 75 bc             	mov    %esi,0xffffffbc(%ebp)
    //cprintf("disasm_info=%x\n",&disasm_info);
    //for(i=0;i<7;i++)
    	//cprintf("%x",disasm_info.buffer[i]);
    cprintf("\n");
f0108d8e:	c7 04 24 09 ac 10 f0 	movl   $0xf010ac09,(%esp)
f0108d95:	e8 9d ac ff ff       	call   f0103a37 <cprintf>
    disasm_info.endian = BFD_ENDIAN_LITTLE;

    disasm_info.mach = bfd_mach_i386_i386;
    print_insn = print_insn_i386;

    for(i = 0; i < nb_insn; i++) {
f0108d9a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0108d9e:	7e 58                	jle    f0108df8 <monitor_disas+0xfe>
f0108da0:	c7 45 98 01 00 00 00 	movl   $0x1,0xffffff98(%ebp)
f0108da7:	c7 45 94 00 00 00 00 	movl   $0x0,0xffffff94(%ebp)
f0108dae:	bf 00 00 00 00       	mov    $0x0,%edi
        cprintf("0x%08x:  ", pc);
f0108db3:	89 74 24 04          	mov    %esi,0x4(%esp)
f0108db7:	c7 04 24 c0 43 11 f0 	movl   $0xf01143c0,(%esp)
f0108dbe:	e8 74 ac ff ff       	call   f0103a37 <cprintf>
	//cprintf("%08x  ", (int)bfd_getl32((const bfd_byte *)pc));
	count = print_insn(pc, &disasm_info);
f0108dc3:	8d 45 88             	lea    0xffffff88(%ebp),%eax
f0108dc6:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108dca:	89 34 24             	mov    %esi,(%esp)
f0108dcd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0108dd4:	00 
f0108dd5:	e8 14 f1 ff ff       	call   f0107eee <print_insn_i386>
f0108dda:	89 c3                	mov    %eax,%ebx
        cprintf("\n");
f0108ddc:	c7 04 24 09 ac 10 f0 	movl   $0xf010ac09,(%esp)
f0108de3:	e8 4f ac ff ff       	call   f0103a37 <cprintf>
        if (count < 0)
f0108de8:	85 db                	test   %ebx,%ebx
f0108dea:	78 0c                	js     f0108df8 <monitor_disas+0xfe>
f0108dec:	83 c7 01             	add    $0x1,%edi
f0108def:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0108df2:	74 04                	je     f0108df8 <monitor_disas+0xfe>
            break;
        pc += count;
f0108df4:	01 de                	add    %ebx,%esi
f0108df6:	eb bb                	jmp    f0108db3 <monitor_disas+0xb9>
    }
}
f0108df8:	83 c4 7c             	add    $0x7c,%esp
f0108dfb:	5b                   	pop    %ebx
f0108dfc:	5e                   	pop    %esi
f0108dfd:	5f                   	pop    %edi
f0108dfe:	5d                   	pop    %ebp
f0108dff:	c3                   	ret    

f0108e00 <generic_print_address>:
f0108e00:	55                   	push   %ebp
f0108e01:	89 e5                	mov    %esp,%ebp
f0108e03:	83 ec 18             	sub    $0x18,%esp
f0108e06:	8b 45 08             	mov    0x8(%ebp),%eax
f0108e09:	8b 55 0c             	mov    0xc(%ebp),%edx
f0108e0c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108e10:	89 54 24 08          	mov    %edx,0x8(%esp)
f0108e14:	c7 04 24 ca 43 11 f0 	movl   $0xf01143ca,(%esp)
f0108e1b:	e8 17 ac ff ff       	call   f0103a37 <cprintf>
f0108e20:	c9                   	leave  
f0108e21:	c3                   	ret    

f0108e22 <perror_memory>:
f0108e22:	55                   	push   %ebp
f0108e23:	89 e5                	mov    %esp,%ebp
f0108e25:	83 ec 18             	sub    $0x18,%esp
f0108e28:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0108e2b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108e2e:	8b 55 10             	mov    0x10(%ebp),%edx
f0108e31:	83 f9 ff             	cmp    $0xffffffff,%ecx
f0108e34:	74 12                	je     f0108e48 <perror_memory+0x26>
f0108e36:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0108e3a:	c7 04 24 d1 43 11 f0 	movl   $0xf01143d1,(%esp)
f0108e41:	e8 f1 ab ff ff       	call   f0103a37 <cprintf>
f0108e46:	eb 14                	jmp    f0108e5c <perror_memory+0x3a>
f0108e48:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108e4c:	89 54 24 08          	mov    %edx,0x8(%esp)
f0108e50:	c7 04 24 e4 43 11 f0 	movl   $0xf01143e4,(%esp)
f0108e57:	e8 db ab ff ff       	call   f0103a37 <cprintf>
f0108e5c:	c9                   	leave  
f0108e5d:	c3                   	ret    

f0108e5e <buffer_read_memory>:
f0108e5e:	55                   	push   %ebp
f0108e5f:	89 e5                	mov    %esp,%ebp
f0108e61:	83 ec 38             	sub    $0x38,%esp
f0108e64:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
f0108e67:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
f0108e6a:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
f0108e6d:	8b 75 08             	mov    0x8(%ebp),%esi
f0108e70:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0108e73:	8b 45 18             	mov    0x18(%ebp),%eax
f0108e76:	8b 48 38             	mov    0x38(%eax),%ecx
f0108e79:	8b 58 3c             	mov    0x3c(%eax),%ebx
f0108e7c:	39 fb                	cmp    %edi,%ebx
f0108e7e:	77 60                	ja     f0108ee0 <buffer_read_memory+0x82>
f0108e80:	72 04                	jb     f0108e86 <buffer_read_memory+0x28>
f0108e82:	39 f1                	cmp    %esi,%ecx
f0108e84:	77 5a                	ja     f0108ee0 <buffer_read_memory+0x82>
f0108e86:	8b 45 14             	mov    0x14(%ebp),%eax
f0108e89:	89 c2                	mov    %eax,%edx
f0108e8b:	c1 fa 1f             	sar    $0x1f,%edx
f0108e8e:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
f0108e91:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
f0108e94:	01 f0                	add    %esi,%eax
f0108e96:	11 fa                	adc    %edi,%edx
f0108e98:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
f0108e9b:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
f0108e9e:	8b 55 18             	mov    0x18(%ebp),%edx
f0108ea1:	8b 42 40             	mov    0x40(%edx),%eax
f0108ea4:	89 c2                	mov    %eax,%edx
f0108ea6:	c1 fa 1f             	sar    $0x1f,%edx
f0108ea9:	01 c8                	add    %ecx,%eax
f0108eab:	11 da                	adc    %ebx,%edx
f0108ead:	39 55 ec             	cmp    %edx,0xffffffec(%ebp)
f0108eb0:	77 2e                	ja     f0108ee0 <buffer_read_memory+0x82>
f0108eb2:	72 05                	jb     f0108eb9 <buffer_read_memory+0x5b>
f0108eb4:	39 45 e8             	cmp    %eax,0xffffffe8(%ebp)
f0108eb7:	77 27                	ja     f0108ee0 <buffer_read_memory+0x82>
f0108eb9:	8b 45 14             	mov    0x14(%ebp),%eax
f0108ebc:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108ec0:	89 f0                	mov    %esi,%eax
f0108ec2:	29 c8                	sub    %ecx,%eax
f0108ec4:	8b 55 18             	mov    0x18(%ebp),%edx
f0108ec7:	03 42 34             	add    0x34(%edx),%eax
f0108eca:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108ece:	8b 45 10             	mov    0x10(%ebp),%eax
f0108ed1:	89 04 24             	mov    %eax,(%esp)
f0108ed4:	e8 31 09 00 00       	call   f010980a <memmove>
f0108ed9:	b8 00 00 00 00       	mov    $0x0,%eax
f0108ede:	eb 05                	jmp    f0108ee5 <buffer_read_memory+0x87>
f0108ee0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0108ee5:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
f0108ee8:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
f0108eeb:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
f0108eee:	89 ec                	mov    %ebp,%esp
f0108ef0:	5d                   	pop    %ebp
f0108ef1:	c3                   	ret    
	...

f0108f00 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0108f00:	55                   	push   %ebp
f0108f01:	89 e5                	mov    %esp,%ebp
f0108f03:	57                   	push   %edi
f0108f04:	56                   	push   %esi
f0108f05:	53                   	push   %ebx
f0108f06:	83 ec 3c             	sub    $0x3c,%esp
f0108f09:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
f0108f0c:	89 d7                	mov    %edx,%edi
f0108f0e:	8b 45 08             	mov    0x8(%ebp),%eax
f0108f11:	8b 55 0c             	mov    0xc(%ebp),%edx
f0108f14:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
f0108f17:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
f0108f1a:	8b 55 10             	mov    0x10(%ebp),%edx
f0108f1d:	8b 45 14             	mov    0x14(%ebp),%eax
f0108f20:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0108f23:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
f0108f26:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
f0108f2d:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
f0108f30:	39 4d ec             	cmp    %ecx,0xffffffec(%ebp)
f0108f33:	72 11                	jb     f0108f46 <printnum+0x46>
f0108f35:	8b 4d d8             	mov    0xffffffd8(%ebp),%ecx
f0108f38:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
f0108f3b:	76 09                	jbe    f0108f46 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0108f3d:	8d 58 ff             	lea    0xffffffff(%eax),%ebx
f0108f40:	85 db                	test   %ebx,%ebx
f0108f42:	7f 54                	jg     f0108f98 <printnum+0x98>
f0108f44:	eb 61                	jmp    f0108fa7 <printnum+0xa7>
f0108f46:	89 74 24 10          	mov    %esi,0x10(%esp)
f0108f4a:	83 e8 01             	sub    $0x1,%eax
f0108f4d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0108f51:	89 54 24 08          	mov    %edx,0x8(%esp)
f0108f55:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0108f59:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0108f5d:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f0108f60:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
f0108f63:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108f67:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0108f6b:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
f0108f6e:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
f0108f71:	89 14 24             	mov    %edx,(%esp)
f0108f74:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0108f78:	e8 e3 15 00 00       	call   f010a560 <__udivdi3>
f0108f7d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0108f81:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0108f85:	89 04 24             	mov    %eax,(%esp)
f0108f88:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108f8c:	89 fa                	mov    %edi,%edx
f0108f8e:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
f0108f91:	e8 6a ff ff ff       	call   f0108f00 <printnum>
f0108f96:	eb 0f                	jmp    f0108fa7 <printnum+0xa7>
			putch(padc, putdat);
f0108f98:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0108f9c:	89 34 24             	mov    %esi,(%esp)
f0108f9f:	ff 55 e4             	call   *0xffffffe4(%ebp)
f0108fa2:	83 eb 01             	sub    $0x1,%ebx
f0108fa5:	75 f1                	jne    f0108f98 <printnum+0x98>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0108fa7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0108fab:	8b 74 24 04          	mov    0x4(%esp),%esi
f0108faf:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f0108fb2:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
f0108fb5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108fb9:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0108fbd:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
f0108fc0:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
f0108fc3:	89 14 24             	mov    %edx,(%esp)
f0108fc6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0108fca:	e8 c1 16 00 00       	call   f010a690 <__umoddi3>
f0108fcf:	89 74 24 04          	mov    %esi,0x4(%esp)
f0108fd3:	0f be 80 06 44 11 f0 	movsbl 0xf0114406(%eax),%eax
f0108fda:	89 04 24             	mov    %eax,(%esp)
f0108fdd:	ff 55 e4             	call   *0xffffffe4(%ebp)
}
f0108fe0:	83 c4 3c             	add    $0x3c,%esp
f0108fe3:	5b                   	pop    %ebx
f0108fe4:	5e                   	pop    %esi
f0108fe5:	5f                   	pop    %edi
f0108fe6:	5d                   	pop    %ebp
f0108fe7:	c3                   	ret    

f0108fe8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0108fe8:	55                   	push   %ebp
f0108fe9:	89 e5                	mov    %esp,%ebp
f0108feb:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
f0108fed:	83 fa 01             	cmp    $0x1,%edx
f0108ff0:	7e 0e                	jle    f0109000 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
f0108ff2:	8b 10                	mov    (%eax),%edx
f0108ff4:	8d 42 08             	lea    0x8(%edx),%eax
f0108ff7:	89 01                	mov    %eax,(%ecx)
f0108ff9:	8b 02                	mov    (%edx),%eax
f0108ffb:	8b 52 04             	mov    0x4(%edx),%edx
f0108ffe:	eb 22                	jmp    f0109022 <getuint+0x3a>
	else if (lflag)
f0109000:	85 d2                	test   %edx,%edx
f0109002:	74 10                	je     f0109014 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
f0109004:	8b 10                	mov    (%eax),%edx
f0109006:	8d 42 04             	lea    0x4(%edx),%eax
f0109009:	89 01                	mov    %eax,(%ecx)
f010900b:	8b 02                	mov    (%edx),%eax
f010900d:	ba 00 00 00 00       	mov    $0x0,%edx
f0109012:	eb 0e                	jmp    f0109022 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
f0109014:	8b 10                	mov    (%eax),%edx
f0109016:	8d 42 04             	lea    0x4(%edx),%eax
f0109019:	89 01                	mov    %eax,(%ecx)
f010901b:	8b 02                	mov    (%edx),%eax
f010901d:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0109022:	5d                   	pop    %ebp
f0109023:	c3                   	ret    

f0109024 <sprintputch>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}


// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;

		// width field
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap,lflag);
			base=8;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
	va_end(ap);
}

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0109024:	55                   	push   %ebp
f0109025:	89 e5                	mov    %esp,%ebp
f0109027:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
f010902a:	83 41 08 01          	addl   $0x1,0x8(%ecx)
	if (b->buf < b->ebuf)
f010902e:	8b 11                	mov    (%ecx),%edx
f0109030:	3b 51 04             	cmp    0x4(%ecx),%edx
f0109033:	73 0a                	jae    f010903f <sprintputch+0x1b>
		*b->buf++ = ch;
f0109035:	8b 45 08             	mov    0x8(%ebp),%eax
f0109038:	88 02                	mov    %al,(%edx)
f010903a:	8d 42 01             	lea    0x1(%edx),%eax
f010903d:	89 01                	mov    %eax,(%ecx)
}
f010903f:	5d                   	pop    %ebp
f0109040:	c3                   	ret    

f0109041 <vprintfmt>:
f0109041:	55                   	push   %ebp
f0109042:	89 e5                	mov    %esp,%ebp
f0109044:	57                   	push   %edi
f0109045:	56                   	push   %esi
f0109046:	53                   	push   %ebx
f0109047:	83 ec 4c             	sub    $0x4c,%esp
f010904a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010904d:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0109050:	eb 03                	jmp    f0109055 <vprintfmt+0x14>
f0109052:	8b 5d e8             	mov    0xffffffe8(%ebp),%ebx
f0109055:	0f b6 03             	movzbl (%ebx),%eax
f0109058:	83 c3 01             	add    $0x1,%ebx
f010905b:	3c 25                	cmp    $0x25,%al
f010905d:	74 30                	je     f010908f <vprintfmt+0x4e>
f010905f:	84 c0                	test   %al,%al
f0109061:	0f 84 a8 03 00 00    	je     f010940f <vprintfmt+0x3ce>
f0109067:	0f b6 d0             	movzbl %al,%edx
f010906a:	eb 0a                	jmp    f0109076 <vprintfmt+0x35>
f010906c:	84 c0                	test   %al,%al
f010906e:	66 90                	xchg   %ax,%ax
f0109070:	0f 84 99 03 00 00    	je     f010940f <vprintfmt+0x3ce>
f0109076:	8b 45 0c             	mov    0xc(%ebp),%eax
f0109079:	89 44 24 04          	mov    %eax,0x4(%esp)
f010907d:	89 14 24             	mov    %edx,(%esp)
f0109080:	ff d7                	call   *%edi
f0109082:	0f b6 03             	movzbl (%ebx),%eax
f0109085:	0f b6 d0             	movzbl %al,%edx
f0109088:	83 c3 01             	add    $0x1,%ebx
f010908b:	3c 25                	cmp    $0x25,%al
f010908d:	75 dd                	jne    f010906c <vprintfmt+0x2b>
f010908f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0109094:	c7 45 ec ff ff ff ff 	movl   $0xffffffff,0xffffffec(%ebp)
f010909b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
f01090a2:	c7 45 dc 00 00 00 00 	movl   $0x0,0xffffffdc(%ebp)
f01090a9:	c6 45 e3 20          	movb   $0x20,0xffffffe3(%ebp)
f01090ad:	eb 07                	jmp    f01090b6 <vprintfmt+0x75>
f01090af:	c7 45 dc 01 00 00 00 	movl   $0x1,0xffffffdc(%ebp)
f01090b6:	0f b6 03             	movzbl (%ebx),%eax
f01090b9:	0f b6 d0             	movzbl %al,%edx
f01090bc:	83 c3 01             	add    $0x1,%ebx
f01090bf:	83 e8 23             	sub    $0x23,%eax
f01090c2:	3c 55                	cmp    $0x55,%al
f01090c4:	0f 87 11 03 00 00    	ja     f01093db <vprintfmt+0x39a>
f01090ca:	0f b6 c0             	movzbl %al,%eax
f01090cd:	ff 24 85 40 45 11 f0 	jmp    *0xf0114540(,%eax,4)
f01090d4:	c6 45 e3 30          	movb   $0x30,0xffffffe3(%ebp)
f01090d8:	eb dc                	jmp    f01090b6 <vprintfmt+0x75>
f01090da:	83 ea 30             	sub    $0x30,%edx
f01090dd:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
f01090e0:	0f be 13             	movsbl (%ebx),%edx
f01090e3:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
f01090e6:	83 f8 09             	cmp    $0x9,%eax
f01090e9:	76 08                	jbe    f01090f3 <vprintfmt+0xb2>
f01090eb:	eb 42                	jmp    f010912f <vprintfmt+0xee>
f01090ed:	c6 45 e3 2d          	movb   $0x2d,0xffffffe3(%ebp)
f01090f1:	eb c3                	jmp    f01090b6 <vprintfmt+0x75>
f01090f3:	83 c3 01             	add    $0x1,%ebx
f01090f6:	8b 75 e4             	mov    0xffffffe4(%ebp),%esi
f01090f9:	8d 04 b6             	lea    (%esi,%esi,4),%eax
f01090fc:	8d 44 42 d0          	lea    0xffffffd0(%edx,%eax,2),%eax
f0109100:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
f0109103:	0f be 13             	movsbl (%ebx),%edx
f0109106:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
f0109109:	83 f8 09             	cmp    $0x9,%eax
f010910c:	77 21                	ja     f010912f <vprintfmt+0xee>
f010910e:	eb e3                	jmp    f01090f3 <vprintfmt+0xb2>
f0109110:	8b 55 14             	mov    0x14(%ebp),%edx
f0109113:	8d 42 04             	lea    0x4(%edx),%eax
f0109116:	89 45 14             	mov    %eax,0x14(%ebp)
f0109119:	8b 12                	mov    (%edx),%edx
f010911b:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
f010911e:	eb 0f                	jmp    f010912f <vprintfmt+0xee>
f0109120:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
f0109124:	79 90                	jns    f01090b6 <vprintfmt+0x75>
f0109126:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
f010912d:	eb 87                	jmp    f01090b6 <vprintfmt+0x75>
f010912f:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
f0109133:	79 81                	jns    f01090b6 <vprintfmt+0x75>
f0109135:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
f0109138:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
f010913b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
f0109142:	e9 6f ff ff ff       	jmp    f01090b6 <vprintfmt+0x75>
f0109147:	83 c1 01             	add    $0x1,%ecx
f010914a:	e9 67 ff ff ff       	jmp    f01090b6 <vprintfmt+0x75>
f010914f:	8b 45 14             	mov    0x14(%ebp),%eax
f0109152:	8d 50 04             	lea    0x4(%eax),%edx
f0109155:	89 55 14             	mov    %edx,0x14(%ebp)
f0109158:	8b 55 0c             	mov    0xc(%ebp),%edx
f010915b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010915f:	8b 00                	mov    (%eax),%eax
f0109161:	89 04 24             	mov    %eax,(%esp)
f0109164:	ff d7                	call   *%edi
f0109166:	e9 ea fe ff ff       	jmp    f0109055 <vprintfmt+0x14>
f010916b:	8b 55 14             	mov    0x14(%ebp),%edx
f010916e:	8d 42 04             	lea    0x4(%edx),%eax
f0109171:	89 45 14             	mov    %eax,0x14(%ebp)
f0109174:	8b 02                	mov    (%edx),%eax
f0109176:	89 c2                	mov    %eax,%edx
f0109178:	c1 fa 1f             	sar    $0x1f,%edx
f010917b:	31 d0                	xor    %edx,%eax
f010917d:	29 d0                	sub    %edx,%eax
f010917f:	83 f8 0f             	cmp    $0xf,%eax
f0109182:	7f 0b                	jg     f010918f <vprintfmt+0x14e>
f0109184:	8b 14 85 a0 46 11 f0 	mov    0xf01146a0(,%eax,4),%edx
f010918b:	85 d2                	test   %edx,%edx
f010918d:	75 20                	jne    f01091af <vprintfmt+0x16e>
f010918f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0109193:	c7 44 24 08 17 44 11 	movl   $0xf0114417,0x8(%esp)
f010919a:	f0 
f010919b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010919e:	89 74 24 04          	mov    %esi,0x4(%esp)
f01091a2:	89 3c 24             	mov    %edi,(%esp)
f01091a5:	e8 f0 02 00 00       	call   f010949a <printfmt>
f01091aa:	e9 a6 fe ff ff       	jmp    f0109055 <vprintfmt+0x14>
f01091af:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01091b3:	c7 44 24 08 9e b7 10 	movl   $0xf010b79e,0x8(%esp)
f01091ba:	f0 
f01091bb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01091be:	89 44 24 04          	mov    %eax,0x4(%esp)
f01091c2:	89 3c 24             	mov    %edi,(%esp)
f01091c5:	e8 d0 02 00 00       	call   f010949a <printfmt>
f01091ca:	e9 86 fe ff ff       	jmp    f0109055 <vprintfmt+0x14>
f01091cf:	8b 75 ec             	mov    0xffffffec(%ebp),%esi
f01091d2:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
f01091d5:	89 5d e8             	mov    %ebx,0xffffffe8(%ebp)
f01091d8:	8b 55 14             	mov    0x14(%ebp),%edx
f01091db:	8d 42 04             	lea    0x4(%edx),%eax
f01091de:	89 45 14             	mov    %eax,0x14(%ebp)
f01091e1:	8b 12                	mov    (%edx),%edx
f01091e3:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
f01091e6:	85 d2                	test   %edx,%edx
f01091e8:	75 07                	jne    f01091f1 <vprintfmt+0x1b0>
f01091ea:	c7 45 d8 20 44 11 f0 	movl   $0xf0114420,0xffffffd8(%ebp)
f01091f1:	85 f6                	test   %esi,%esi
f01091f3:	7e 40                	jle    f0109235 <vprintfmt+0x1f4>
f01091f5:	80 7d e3 2d          	cmpb   $0x2d,0xffffffe3(%ebp)
f01091f9:	74 3a                	je     f0109235 <vprintfmt+0x1f4>
f01091fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01091ff:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
f0109202:	89 14 24             	mov    %edx,(%esp)
f0109205:	e8 c6 03 00 00       	call   f01095d0 <strnlen>
f010920a:	29 c6                	sub    %eax,%esi
f010920c:	89 75 ec             	mov    %esi,0xffffffec(%ebp)
f010920f:	85 f6                	test   %esi,%esi
f0109211:	7e 22                	jle    f0109235 <vprintfmt+0x1f4>
f0109213:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
f0109217:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
f010921a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010921d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0109221:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
f0109224:	89 04 24             	mov    %eax,(%esp)
f0109227:	ff d7                	call   *%edi
f0109229:	83 ee 01             	sub    $0x1,%esi
f010922c:	75 ec                	jne    f010921a <vprintfmt+0x1d9>
f010922e:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
f0109235:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
f0109238:	0f b6 02             	movzbl (%edx),%eax
f010923b:	0f be d0             	movsbl %al,%edx
f010923e:	8b 75 d8             	mov    0xffffffd8(%ebp),%esi
f0109241:	84 c0                	test   %al,%al
f0109243:	75 40                	jne    f0109285 <vprintfmt+0x244>
f0109245:	eb 4a                	jmp    f0109291 <vprintfmt+0x250>
f0109247:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
f010924b:	74 1a                	je     f0109267 <vprintfmt+0x226>
f010924d:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
f0109250:	83 f8 5e             	cmp    $0x5e,%eax
f0109253:	76 12                	jbe    f0109267 <vprintfmt+0x226>
f0109255:	8b 45 0c             	mov    0xc(%ebp),%eax
f0109258:	89 44 24 04          	mov    %eax,0x4(%esp)
f010925c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0109263:	ff d7                	call   *%edi
f0109265:	eb 0c                	jmp    f0109273 <vprintfmt+0x232>
f0109267:	8b 45 0c             	mov    0xc(%ebp),%eax
f010926a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010926e:	89 14 24             	mov    %edx,(%esp)
f0109271:	ff d7                	call   *%edi
f0109273:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
f0109277:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f010927b:	83 c6 01             	add    $0x1,%esi
f010927e:	84 c0                	test   %al,%al
f0109280:	74 0f                	je     f0109291 <vprintfmt+0x250>
f0109282:	0f be d0             	movsbl %al,%edx
f0109285:	83 7d e4 00          	cmpl   $0x0,0xffffffe4(%ebp)
f0109289:	78 bc                	js     f0109247 <vprintfmt+0x206>
f010928b:	83 6d e4 01          	subl   $0x1,0xffffffe4(%ebp)
f010928f:	79 b6                	jns    f0109247 <vprintfmt+0x206>
f0109291:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
f0109295:	0f 8e ba fd ff ff    	jle    f0109055 <vprintfmt+0x14>
f010929b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010929e:	89 54 24 04          	mov    %edx,0x4(%esp)
f01092a2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01092a9:	ff d7                	call   *%edi
f01092ab:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
f01092af:	0f 84 9d fd ff ff    	je     f0109052 <vprintfmt+0x11>
f01092b5:	eb e4                	jmp    f010929b <vprintfmt+0x25a>
f01092b7:	83 f9 01             	cmp    $0x1,%ecx
f01092ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01092c0:	7e 10                	jle    f01092d2 <vprintfmt+0x291>
f01092c2:	8b 55 14             	mov    0x14(%ebp),%edx
f01092c5:	8d 42 08             	lea    0x8(%edx),%eax
f01092c8:	89 45 14             	mov    %eax,0x14(%ebp)
f01092cb:	8b 02                	mov    (%edx),%eax
f01092cd:	8b 52 04             	mov    0x4(%edx),%edx
f01092d0:	eb 26                	jmp    f01092f8 <vprintfmt+0x2b7>
f01092d2:	85 c9                	test   %ecx,%ecx
f01092d4:	74 12                	je     f01092e8 <vprintfmt+0x2a7>
f01092d6:	8b 45 14             	mov    0x14(%ebp),%eax
f01092d9:	8d 50 04             	lea    0x4(%eax),%edx
f01092dc:	89 55 14             	mov    %edx,0x14(%ebp)
f01092df:	8b 00                	mov    (%eax),%eax
f01092e1:	89 c2                	mov    %eax,%edx
f01092e3:	c1 fa 1f             	sar    $0x1f,%edx
f01092e6:	eb 10                	jmp    f01092f8 <vprintfmt+0x2b7>
f01092e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01092eb:	8d 50 04             	lea    0x4(%eax),%edx
f01092ee:	89 55 14             	mov    %edx,0x14(%ebp)
f01092f1:	8b 00                	mov    (%eax),%eax
f01092f3:	89 c2                	mov    %eax,%edx
f01092f5:	c1 fa 1f             	sar    $0x1f,%edx
f01092f8:	89 d1                	mov    %edx,%ecx
f01092fa:	89 c2                	mov    %eax,%edx
f01092fc:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
f01092ff:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
f0109302:	be 0a 00 00 00       	mov    $0xa,%esi
f0109307:	85 c9                	test   %ecx,%ecx
f0109309:	0f 89 92 00 00 00    	jns    f01093a1 <vprintfmt+0x360>
f010930f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0109312:	89 74 24 04          	mov    %esi,0x4(%esp)
f0109316:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010931d:	ff d7                	call   *%edi
f010931f:	8b 55 d0             	mov    0xffffffd0(%ebp),%edx
f0109322:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
f0109325:	f7 da                	neg    %edx
f0109327:	83 d1 00             	adc    $0x0,%ecx
f010932a:	f7 d9                	neg    %ecx
f010932c:	be 0a 00 00 00       	mov    $0xa,%esi
f0109331:	eb 6e                	jmp    f01093a1 <vprintfmt+0x360>
f0109333:	8d 45 14             	lea    0x14(%ebp),%eax
f0109336:	89 ca                	mov    %ecx,%edx
f0109338:	e8 ab fc ff ff       	call   f0108fe8 <getuint>
f010933d:	89 d1                	mov    %edx,%ecx
f010933f:	89 c2                	mov    %eax,%edx
f0109341:	be 0a 00 00 00       	mov    $0xa,%esi
f0109346:	eb 59                	jmp    f01093a1 <vprintfmt+0x360>
f0109348:	8d 45 14             	lea    0x14(%ebp),%eax
f010934b:	89 ca                	mov    %ecx,%edx
f010934d:	e8 96 fc ff ff       	call   f0108fe8 <getuint>
f0109352:	e9 fe fc ff ff       	jmp    f0109055 <vprintfmt+0x14>
f0109357:	8b 45 0c             	mov    0xc(%ebp),%eax
f010935a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010935e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0109365:	ff d7                	call   *%edi
f0109367:	8b 55 0c             	mov    0xc(%ebp),%edx
f010936a:	89 54 24 04          	mov    %edx,0x4(%esp)
f010936e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0109375:	ff d7                	call   *%edi
f0109377:	8b 55 14             	mov    0x14(%ebp),%edx
f010937a:	8d 42 04             	lea    0x4(%edx),%eax
f010937d:	89 45 14             	mov    %eax,0x14(%ebp)
f0109380:	8b 12                	mov    (%edx),%edx
f0109382:	b9 00 00 00 00       	mov    $0x0,%ecx
f0109387:	be 10 00 00 00       	mov    $0x10,%esi
f010938c:	eb 13                	jmp    f01093a1 <vprintfmt+0x360>
f010938e:	8d 45 14             	lea    0x14(%ebp),%eax
f0109391:	89 ca                	mov    %ecx,%edx
f0109393:	e8 50 fc ff ff       	call   f0108fe8 <getuint>
f0109398:	89 d1                	mov    %edx,%ecx
f010939a:	89 c2                	mov    %eax,%edx
f010939c:	be 10 00 00 00       	mov    $0x10,%esi
f01093a1:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
f01093a5:	89 44 24 10          	mov    %eax,0x10(%esp)
f01093a9:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f01093ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01093b0:	89 74 24 08          	mov    %esi,0x8(%esp)
f01093b4:	89 14 24             	mov    %edx,(%esp)
f01093b7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01093bb:	8b 55 0c             	mov    0xc(%ebp),%edx
f01093be:	89 f8                	mov    %edi,%eax
f01093c0:	e8 3b fb ff ff       	call   f0108f00 <printnum>
f01093c5:	e9 8b fc ff ff       	jmp    f0109055 <vprintfmt+0x14>
f01093ca:	8b 75 0c             	mov    0xc(%ebp),%esi
f01093cd:	89 74 24 04          	mov    %esi,0x4(%esp)
f01093d1:	89 14 24             	mov    %edx,(%esp)
f01093d4:	ff d7                	call   *%edi
f01093d6:	e9 7a fc ff ff       	jmp    f0109055 <vprintfmt+0x14>
f01093db:	89 de                	mov    %ebx,%esi
f01093dd:	8b 45 0c             	mov    0xc(%ebp),%eax
f01093e0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01093e4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01093eb:	ff d7                	call   *%edi
f01093ed:	83 eb 01             	sub    $0x1,%ebx
f01093f0:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
f01093f4:	0f 84 5b fc ff ff    	je     f0109055 <vprintfmt+0x14>
f01093fa:	8d 56 fd             	lea    0xfffffffd(%esi),%edx
f01093fd:	0f b6 02             	movzbl (%edx),%eax
f0109400:	83 ea 01             	sub    $0x1,%edx
f0109403:	3c 25                	cmp    $0x25,%al
f0109405:	75 f6                	jne    f01093fd <vprintfmt+0x3bc>
f0109407:	8d 5a 02             	lea    0x2(%edx),%ebx
f010940a:	e9 46 fc ff ff       	jmp    f0109055 <vprintfmt+0x14>
f010940f:	83 c4 4c             	add    $0x4c,%esp
f0109412:	5b                   	pop    %ebx
f0109413:	5e                   	pop    %esi
f0109414:	5f                   	pop    %edi
f0109415:	5d                   	pop    %ebp
f0109416:	c3                   	ret    

f0109417 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0109417:	55                   	push   %ebp
f0109418:	89 e5                	mov    %esp,%ebp
f010941a:	83 ec 28             	sub    $0x28,%esp
f010941d:	8b 55 08             	mov    0x8(%ebp),%edx
f0109420:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f0109423:	85 d2                	test   %edx,%edx
f0109425:	74 04                	je     f010942b <vsnprintf+0x14>
f0109427:	85 c0                	test   %eax,%eax
f0109429:	7f 07                	jg     f0109432 <vsnprintf+0x1b>
f010942b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0109430:	eb 3b                	jmp    f010946d <vsnprintf+0x56>
f0109432:	c7 45 fc 00 00 00 00 	movl   $0x0,0xfffffffc(%ebp)
f0109439:	8d 44 02 ff          	lea    0xffffffff(%edx,%eax,1),%eax
f010943d:	89 45 f8             	mov    %eax,0xfffffff8(%ebp)
f0109440:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0109443:	8b 45 14             	mov    0x14(%ebp),%eax
f0109446:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010944a:	8b 45 10             	mov    0x10(%ebp),%eax
f010944d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0109451:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
f0109454:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109458:	c7 04 24 24 90 10 f0 	movl   $0xf0109024,(%esp)
f010945f:	e8 dd fb ff ff       	call   f0109041 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0109464:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0109467:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010946a:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
}
f010946d:	c9                   	leave  
f010946e:	c3                   	ret    

f010946f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010946f:	55                   	push   %ebp
f0109470:	89 e5                	mov    %esp,%ebp
f0109472:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0109475:	8d 45 14             	lea    0x14(%ebp),%eax
f0109478:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
f010947b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010947f:	8b 45 10             	mov    0x10(%ebp),%eax
f0109482:	89 44 24 08          	mov    %eax,0x8(%esp)
f0109486:	8b 45 0c             	mov    0xc(%ebp),%eax
f0109489:	89 44 24 04          	mov    %eax,0x4(%esp)
f010948d:	8b 45 08             	mov    0x8(%ebp),%eax
f0109490:	89 04 24             	mov    %eax,(%esp)
f0109493:	e8 7f ff ff ff       	call   f0109417 <vsnprintf>
	va_end(ap);

	return rc;
}
f0109498:	c9                   	leave  
f0109499:	c3                   	ret    

f010949a <printfmt>:
f010949a:	55                   	push   %ebp
f010949b:	89 e5                	mov    %esp,%ebp
f010949d:	83 ec 28             	sub    $0x28,%esp
f01094a0:	8d 45 14             	lea    0x14(%ebp),%eax
f01094a3:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
f01094a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01094aa:	8b 45 10             	mov    0x10(%ebp),%eax
f01094ad:	89 44 24 08          	mov    %eax,0x8(%esp)
f01094b1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01094b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01094b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01094bb:	89 04 24             	mov    %eax,(%esp)
f01094be:	e8 7e fb ff ff       	call   f0109041 <vprintfmt>
f01094c3:	c9                   	leave  
f01094c4:	c3                   	ret    
	...

f01094d0 <readline>:
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01094d0:	55                   	push   %ebp
f01094d1:	89 e5                	mov    %esp,%ebp
f01094d3:	57                   	push   %edi
f01094d4:	56                   	push   %esi
f01094d5:	53                   	push   %ebx
f01094d6:	83 ec 0c             	sub    $0xc,%esp
f01094d9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01094dc:	85 c0                	test   %eax,%eax
f01094de:	74 10                	je     f01094f0 <readline+0x20>
		cprintf("%s", prompt);
f01094e0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01094e4:	c7 04 24 9e b7 10 f0 	movl   $0xf010b79e,(%esp)
f01094eb:	e8 47 a5 ff ff       	call   f0103a37 <cprintf>

	i = 0;
	echoing = iscons(0);
f01094f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01094f7:	e8 79 6d ff ff       	call   f0100275 <iscons>
f01094fc:	89 c7                	mov    %eax,%edi
f01094fe:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0109503:	e8 5c 6d ff ff       	call   f0100264 <getchar>
f0109508:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010950a:	85 c0                	test   %eax,%eax
f010950c:	79 17                	jns    f0109525 <readline+0x55>
			cprintf("read error: %e\n", c);
f010950e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109512:	c7 04 24 ff 46 11 f0 	movl   $0xf01146ff,(%esp)
f0109519:	e8 19 a5 ff ff       	call   f0103a37 <cprintf>
f010951e:	b8 00 00 00 00       	mov    $0x0,%eax
f0109523:	eb 76                	jmp    f010959b <readline+0xcb>
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0109525:	83 f8 08             	cmp    $0x8,%eax
f0109528:	74 08                	je     f0109532 <readline+0x62>
f010952a:	83 f8 7f             	cmp    $0x7f,%eax
f010952d:	8d 76 00             	lea    0x0(%esi),%esi
f0109530:	75 19                	jne    f010954b <readline+0x7b>
f0109532:	85 f6                	test   %esi,%esi
f0109534:	7e 15                	jle    f010954b <readline+0x7b>
			if (echoing)
f0109536:	85 ff                	test   %edi,%edi
f0109538:	74 0c                	je     f0109546 <readline+0x76>
				cputchar('\b');
f010953a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0109541:	e8 37 6f ff ff       	call   f010047d <cputchar>
			i--;
f0109546:	83 ee 01             	sub    $0x1,%esi
f0109549:	eb b8                	jmp    f0109503 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010954b:	83 fb 1f             	cmp    $0x1f,%ebx
f010954e:	66 90                	xchg   %ax,%ax
f0109550:	7e 23                	jle    f0109575 <readline+0xa5>
f0109552:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0109558:	7f 1b                	jg     f0109575 <readline+0xa5>
			if (echoing)
f010955a:	85 ff                	test   %edi,%edi
f010955c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0109560:	74 08                	je     f010956a <readline+0x9a>
				cputchar(c);
f0109562:	89 1c 24             	mov    %ebx,(%esp)
f0109565:	e8 13 6f ff ff       	call   f010047d <cputchar>
			buf[i++] = c;
f010956a:	88 9e 60 94 2a f0    	mov    %bl,0xf02a9460(%esi)
f0109570:	83 c6 01             	add    $0x1,%esi
f0109573:	eb 8e                	jmp    f0109503 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0109575:	83 fb 0a             	cmp    $0xa,%ebx
f0109578:	74 05                	je     f010957f <readline+0xaf>
f010957a:	83 fb 0d             	cmp    $0xd,%ebx
f010957d:	75 84                	jne    f0109503 <readline+0x33>
			if (echoing)
f010957f:	85 ff                	test   %edi,%edi
f0109581:	74 0c                	je     f010958f <readline+0xbf>
				cputchar('\n');
f0109583:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f010958a:	e8 ee 6e ff ff       	call   f010047d <cputchar>
			buf[i] = 0;
f010958f:	c6 86 60 94 2a f0 00 	movb   $0x0,0xf02a9460(%esi)
f0109596:	b8 60 94 2a f0       	mov    $0xf02a9460,%eax
			return buf;
		}
	}
}
f010959b:	83 c4 0c             	add    $0xc,%esp
f010959e:	5b                   	pop    %ebx
f010959f:	5e                   	pop    %esi
f01095a0:	5f                   	pop    %edi
f01095a1:	5d                   	pop    %ebp
f01095a2:	c3                   	ret    
	...

f01095b0 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
f01095b0:	55                   	push   %ebp
f01095b1:	89 e5                	mov    %esp,%ebp
f01095b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01095b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01095bb:	80 3a 00             	cmpb   $0x0,(%edx)
f01095be:	74 0e                	je     f01095ce <strlen+0x1e>
f01095c0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01095c5:	83 c0 01             	add    $0x1,%eax
f01095c8:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
f01095cc:	75 f7                	jne    f01095c5 <strlen+0x15>
	return n;
}
f01095ce:	5d                   	pop    %ebp
f01095cf:	c3                   	ret    

f01095d0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01095d0:	55                   	push   %ebp
f01095d1:	89 e5                	mov    %esp,%ebp
f01095d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01095d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01095d9:	85 d2                	test   %edx,%edx
f01095db:	74 19                	je     f01095f6 <strnlen+0x26>
f01095dd:	80 39 00             	cmpb   $0x0,(%ecx)
f01095e0:	74 14                	je     f01095f6 <strnlen+0x26>
f01095e2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01095e7:	83 c0 01             	add    $0x1,%eax
f01095ea:	39 d0                	cmp    %edx,%eax
f01095ec:	74 0d                	je     f01095fb <strnlen+0x2b>
f01095ee:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
f01095f2:	74 07                	je     f01095fb <strnlen+0x2b>
f01095f4:	eb f1                	jmp    f01095e7 <strnlen+0x17>
f01095f6:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
f01095fb:	5d                   	pop    %ebp
f01095fc:	8d 74 26 00          	lea    0x0(%esi),%esi
f0109600:	c3                   	ret    

f0109601 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0109601:	55                   	push   %ebp
f0109602:	89 e5                	mov    %esp,%ebp
f0109604:	53                   	push   %ebx
f0109605:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0109608:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010960b:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010960d:	0f b6 01             	movzbl (%ecx),%eax
f0109610:	88 02                	mov    %al,(%edx)
f0109612:	83 c2 01             	add    $0x1,%edx
f0109615:	83 c1 01             	add    $0x1,%ecx
f0109618:	84 c0                	test   %al,%al
f010961a:	75 f1                	jne    f010960d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010961c:	89 d8                	mov    %ebx,%eax
f010961e:	5b                   	pop    %ebx
f010961f:	5d                   	pop    %ebp
f0109620:	c3                   	ret    

f0109621 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0109621:	55                   	push   %ebp
f0109622:	89 e5                	mov    %esp,%ebp
f0109624:	57                   	push   %edi
f0109625:	56                   	push   %esi
f0109626:	53                   	push   %ebx
f0109627:	8b 7d 08             	mov    0x8(%ebp),%edi
f010962a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010962d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0109630:	85 f6                	test   %esi,%esi
f0109632:	74 1c                	je     f0109650 <strncpy+0x2f>
f0109634:	89 fa                	mov    %edi,%edx
f0109636:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
f010963b:	0f b6 01             	movzbl (%ecx),%eax
f010963e:	88 02                	mov    %al,(%edx)
f0109640:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0109643:	80 39 01             	cmpb   $0x1,(%ecx)
f0109646:	83 d9 ff             	sbb    $0xffffffff,%ecx
f0109649:	83 c3 01             	add    $0x1,%ebx
f010964c:	39 f3                	cmp    %esi,%ebx
f010964e:	75 eb                	jne    f010963b <strncpy+0x1a>
	}
	return ret;
}
f0109650:	89 f8                	mov    %edi,%eax
f0109652:	5b                   	pop    %ebx
f0109653:	5e                   	pop    %esi
f0109654:	5f                   	pop    %edi
f0109655:	5d                   	pop    %ebp
f0109656:	c3                   	ret    

f0109657 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0109657:	55                   	push   %ebp
f0109658:	89 e5                	mov    %esp,%ebp
f010965a:	56                   	push   %esi
f010965b:	53                   	push   %ebx
f010965c:	8b 75 08             	mov    0x8(%ebp),%esi
f010965f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0109662:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0109665:	89 f0                	mov    %esi,%eax
f0109667:	85 d2                	test   %edx,%edx
f0109669:	74 2c                	je     f0109697 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f010966b:	89 d3                	mov    %edx,%ebx
f010966d:	83 eb 01             	sub    $0x1,%ebx
f0109670:	74 20                	je     f0109692 <strlcpy+0x3b>
f0109672:	0f b6 11             	movzbl (%ecx),%edx
f0109675:	84 d2                	test   %dl,%dl
f0109677:	74 19                	je     f0109692 <strlcpy+0x3b>
f0109679:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
f010967b:	88 10                	mov    %dl,(%eax)
f010967d:	83 c0 01             	add    $0x1,%eax
f0109680:	83 eb 01             	sub    $0x1,%ebx
f0109683:	74 0f                	je     f0109694 <strlcpy+0x3d>
f0109685:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
f0109689:	83 c1 01             	add    $0x1,%ecx
f010968c:	84 d2                	test   %dl,%dl
f010968e:	74 04                	je     f0109694 <strlcpy+0x3d>
f0109690:	eb e9                	jmp    f010967b <strlcpy+0x24>
f0109692:	89 f0                	mov    %esi,%eax
		*dst = '\0';
f0109694:	c6 00 00             	movb   $0x0,(%eax)
f0109697:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0109699:	5b                   	pop    %ebx
f010969a:	5e                   	pop    %esi
f010969b:	5d                   	pop    %ebp
f010969c:	c3                   	ret    

f010969d <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
f010969d:	55                   	push   %ebp
f010969e:	89 e5                	mov    %esp,%ebp
f01096a0:	57                   	push   %edi
f01096a1:	56                   	push   %esi
f01096a2:	53                   	push   %ebx
f01096a3:	8b 55 08             	mov    0x8(%ebp),%edx
f01096a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01096a9:	8b 7d 10             	mov    0x10(%ebp),%edi
    int c;
    char *q = buf;

    if (buf_size <= 0)
f01096ac:	85 c9                	test   %ecx,%ecx
f01096ae:	7e 30                	jle    f01096e0 <pstrcpy+0x43>
        return;

    for(;;) {
        c = *str++;
f01096b0:	0f b6 07             	movzbl (%edi),%eax
        if (c == 0 || q >= buf + buf_size - 1)
f01096b3:	84 c0                	test   %al,%al
f01096b5:	74 26                	je     f01096dd <pstrcpy+0x40>
f01096b7:	8d 74 0a ff          	lea    0xffffffff(%edx,%ecx,1),%esi
f01096bb:	0f be d8             	movsbl %al,%ebx
f01096be:	89 f9                	mov    %edi,%ecx
f01096c0:	39 f2                	cmp    %esi,%edx
f01096c2:	72 09                	jb     f01096cd <pstrcpy+0x30>
f01096c4:	eb 17                	jmp    f01096dd <pstrcpy+0x40>
f01096c6:	83 c1 01             	add    $0x1,%ecx
f01096c9:	39 f2                	cmp    %esi,%edx
f01096cb:	73 10                	jae    f01096dd <pstrcpy+0x40>
            break;
        *q++ = c;
f01096cd:	88 1a                	mov    %bl,(%edx)
f01096cf:	83 c2 01             	add    $0x1,%edx
f01096d2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f01096d6:	0f be d8             	movsbl %al,%ebx
f01096d9:	84 c0                	test   %al,%al
f01096db:	75 e9                	jne    f01096c6 <pstrcpy+0x29>
    }
    *q = '\0';
f01096dd:	c6 02 00             	movb   $0x0,(%edx)
}
f01096e0:	5b                   	pop    %ebx
f01096e1:	5e                   	pop    %esi
f01096e2:	5f                   	pop    %edi
f01096e3:	5d                   	pop    %ebp
f01096e4:	c3                   	ret    

f01096e5 <strcmp>:
int
strcmp(const char *p, const char *q)
{
f01096e5:	55                   	push   %ebp
f01096e6:	89 e5                	mov    %esp,%ebp
f01096e8:	8b 55 08             	mov    0x8(%ebp),%edx
f01096eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
f01096ee:	0f b6 02             	movzbl (%edx),%eax
f01096f1:	84 c0                	test   %al,%al
f01096f3:	74 16                	je     f010970b <strcmp+0x26>
f01096f5:	3a 01                	cmp    (%ecx),%al
f01096f7:	75 12                	jne    f010970b <strcmp+0x26>
		p++, q++;
f01096f9:	83 c1 01             	add    $0x1,%ecx
f01096fc:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f0109700:	84 c0                	test   %al,%al
f0109702:	74 07                	je     f010970b <strcmp+0x26>
f0109704:	83 c2 01             	add    $0x1,%edx
f0109707:	3a 01                	cmp    (%ecx),%al
f0109709:	74 ee                	je     f01096f9 <strcmp+0x14>
f010970b:	0f b6 c0             	movzbl %al,%eax
f010970e:	0f b6 11             	movzbl (%ecx),%edx
f0109711:	29 d0                	sub    %edx,%eax
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0109713:	5d                   	pop    %ebp
f0109714:	c3                   	ret    

f0109715 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0109715:	55                   	push   %ebp
f0109716:	89 e5                	mov    %esp,%ebp
f0109718:	53                   	push   %ebx
f0109719:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010971c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010971f:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0109722:	85 d2                	test   %edx,%edx
f0109724:	74 2d                	je     f0109753 <strncmp+0x3e>
f0109726:	0f b6 01             	movzbl (%ecx),%eax
f0109729:	84 c0                	test   %al,%al
f010972b:	74 1a                	je     f0109747 <strncmp+0x32>
f010972d:	3a 03                	cmp    (%ebx),%al
f010972f:	75 16                	jne    f0109747 <strncmp+0x32>
f0109731:	83 ea 01             	sub    $0x1,%edx
f0109734:	74 1d                	je     f0109753 <strncmp+0x3e>
		n--, p++, q++;
f0109736:	83 c1 01             	add    $0x1,%ecx
f0109739:	83 c3 01             	add    $0x1,%ebx
f010973c:	0f b6 01             	movzbl (%ecx),%eax
f010973f:	84 c0                	test   %al,%al
f0109741:	74 04                	je     f0109747 <strncmp+0x32>
f0109743:	3a 03                	cmp    (%ebx),%al
f0109745:	74 ea                	je     f0109731 <strncmp+0x1c>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0109747:	0f b6 11             	movzbl (%ecx),%edx
f010974a:	0f b6 03             	movzbl (%ebx),%eax
f010974d:	29 c2                	sub    %eax,%edx
f010974f:	89 d0                	mov    %edx,%eax
f0109751:	eb 05                	jmp    f0109758 <strncmp+0x43>
f0109753:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0109758:	5b                   	pop    %ebx
f0109759:	5d                   	pop    %ebp
f010975a:	c3                   	ret    

f010975b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010975b:	55                   	push   %ebp
f010975c:	89 e5                	mov    %esp,%ebp
f010975e:	8b 45 08             	mov    0x8(%ebp),%eax
f0109761:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0109765:	0f b6 10             	movzbl (%eax),%edx
f0109768:	84 d2                	test   %dl,%dl
f010976a:	74 16                	je     f0109782 <strchr+0x27>
		if (*s == c)
f010976c:	38 ca                	cmp    %cl,%dl
f010976e:	75 06                	jne    f0109776 <strchr+0x1b>
f0109770:	eb 15                	jmp    f0109787 <strchr+0x2c>
f0109772:	38 ca                	cmp    %cl,%dl
f0109774:	74 11                	je     f0109787 <strchr+0x2c>
f0109776:	83 c0 01             	add    $0x1,%eax
f0109779:	0f b6 10             	movzbl (%eax),%edx
f010977c:	84 d2                	test   %dl,%dl
f010977e:	66 90                	xchg   %ax,%ax
f0109780:	75 f0                	jne    f0109772 <strchr+0x17>
f0109782:	b8 00 00 00 00       	mov    $0x0,%eax
			return (char *) s;
	return 0;
}
f0109787:	5d                   	pop    %ebp
f0109788:	c3                   	ret    

f0109789 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0109789:	55                   	push   %ebp
f010978a:	89 e5                	mov    %esp,%ebp
f010978c:	8b 45 08             	mov    0x8(%ebp),%eax
f010978f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0109793:	0f b6 10             	movzbl (%eax),%edx
f0109796:	84 d2                	test   %dl,%dl
f0109798:	74 14                	je     f01097ae <strfind+0x25>
		if (*s == c)
f010979a:	38 ca                	cmp    %cl,%dl
f010979c:	75 06                	jne    f01097a4 <strfind+0x1b>
f010979e:	eb 0e                	jmp    f01097ae <strfind+0x25>
f01097a0:	38 ca                	cmp    %cl,%dl
f01097a2:	74 0a                	je     f01097ae <strfind+0x25>
f01097a4:	83 c0 01             	add    $0x1,%eax
f01097a7:	0f b6 10             	movzbl (%eax),%edx
f01097aa:	84 d2                	test   %dl,%dl
f01097ac:	75 f2                	jne    f01097a0 <strfind+0x17>
			break;
	return (char *) s;
}
f01097ae:	5d                   	pop    %ebp
f01097af:	90                   	nop    
f01097b0:	c3                   	ret    

f01097b1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01097b1:	55                   	push   %ebp
f01097b2:	89 e5                	mov    %esp,%ebp
f01097b4:	83 ec 08             	sub    $0x8,%esp
f01097b7:	89 1c 24             	mov    %ebx,(%esp)
f01097ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01097be:	8b 7d 08             	mov    0x8(%ebp),%edi
f01097c1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01097c4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
f01097c7:	85 db                	test   %ebx,%ebx
f01097c9:	74 32                	je     f01097fd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01097cb:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01097d1:	75 25                	jne    f01097f8 <memset+0x47>
f01097d3:	f6 c3 03             	test   $0x3,%bl
f01097d6:	75 20                	jne    f01097f8 <memset+0x47>
		c &= 0xFF;
f01097d8:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01097db:	89 d0                	mov    %edx,%eax
f01097dd:	c1 e0 18             	shl    $0x18,%eax
f01097e0:	89 d1                	mov    %edx,%ecx
f01097e2:	c1 e1 10             	shl    $0x10,%ecx
f01097e5:	09 c8                	or     %ecx,%eax
f01097e7:	09 d0                	or     %edx,%eax
f01097e9:	c1 e2 08             	shl    $0x8,%edx
f01097ec:	09 d0                	or     %edx,%eax
f01097ee:	89 d9                	mov    %ebx,%ecx
f01097f0:	c1 e9 02             	shr    $0x2,%ecx
f01097f3:	fc                   	cld    
f01097f4:	f3 ab                	rep stos %eax,%es:(%edi)
f01097f6:	eb 05                	jmp    f01097fd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01097f8:	89 d9                	mov    %ebx,%ecx
f01097fa:	fc                   	cld    
f01097fb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01097fd:	89 f8                	mov    %edi,%eax
f01097ff:	8b 1c 24             	mov    (%esp),%ebx
f0109802:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0109806:	89 ec                	mov    %ebp,%esp
f0109808:	5d                   	pop    %ebp
f0109809:	c3                   	ret    

f010980a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010980a:	55                   	push   %ebp
f010980b:	89 e5                	mov    %esp,%ebp
f010980d:	83 ec 08             	sub    $0x8,%esp
f0109810:	89 34 24             	mov    %esi,(%esp)
f0109813:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0109817:	8b 45 08             	mov    0x8(%ebp),%eax
f010981a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
f010981d:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f0109820:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f0109822:	39 c6                	cmp    %eax,%esi
f0109824:	73 36                	jae    f010985c <memmove+0x52>
f0109826:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0109829:	39 d0                	cmp    %edx,%eax
f010982b:	73 2f                	jae    f010985c <memmove+0x52>
		s += n;
		d += n;
f010982d:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0109830:	f6 c2 03             	test   $0x3,%dl
f0109833:	75 1b                	jne    f0109850 <memmove+0x46>
f0109835:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010983b:	75 13                	jne    f0109850 <memmove+0x46>
f010983d:	f6 c1 03             	test   $0x3,%cl
f0109840:	75 0e                	jne    f0109850 <memmove+0x46>
			asm volatile("std; rep movsl\n"
f0109842:	8d 7e fc             	lea    0xfffffffc(%esi),%edi
f0109845:	8d 72 fc             	lea    0xfffffffc(%edx),%esi
f0109848:	c1 e9 02             	shr    $0x2,%ecx
f010984b:	fd                   	std    
f010984c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010984e:	eb 09                	jmp    f0109859 <memmove+0x4f>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0109850:	8d 7e ff             	lea    0xffffffff(%esi),%edi
f0109853:	8d 72 ff             	lea    0xffffffff(%edx),%esi
f0109856:	fd                   	std    
f0109857:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0109859:	fc                   	cld    
f010985a:	eb 21                	jmp    f010987d <memmove+0x73>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010985c:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0109862:	75 16                	jne    f010987a <memmove+0x70>
f0109864:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010986a:	75 0e                	jne    f010987a <memmove+0x70>
f010986c:	f6 c1 03             	test   $0x3,%cl
f010986f:	90                   	nop    
f0109870:	75 08                	jne    f010987a <memmove+0x70>
			asm volatile("cld; rep movsl\n"
f0109872:	c1 e9 02             	shr    $0x2,%ecx
f0109875:	fc                   	cld    
f0109876:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0109878:	eb 03                	jmp    f010987d <memmove+0x73>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010987a:	fc                   	cld    
f010987b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010987d:	8b 34 24             	mov    (%esp),%esi
f0109880:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0109884:	89 ec                	mov    %ebp,%esp
f0109886:	5d                   	pop    %ebp
f0109887:	c3                   	ret    

f0109888 <memcpy>:

#else

void *
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;

	return v;
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;

	return dst;
}
#endif

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0109888:	55                   	push   %ebp
f0109889:	89 e5                	mov    %esp,%ebp
f010988b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010988e:	8b 45 10             	mov    0x10(%ebp),%eax
f0109891:	89 44 24 08          	mov    %eax,0x8(%esp)
f0109895:	8b 45 0c             	mov    0xc(%ebp),%eax
f0109898:	89 44 24 04          	mov    %eax,0x4(%esp)
f010989c:	8b 45 08             	mov    0x8(%ebp),%eax
f010989f:	89 04 24             	mov    %eax,(%esp)
f01098a2:	e8 63 ff ff ff       	call   f010980a <memmove>
}
f01098a7:	c9                   	leave  
f01098a8:	c3                   	ret    

f01098a9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01098a9:	55                   	push   %ebp
f01098aa:	89 e5                	mov    %esp,%ebp
f01098ac:	56                   	push   %esi
f01098ad:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01098ae:	8b 75 10             	mov    0x10(%ebp),%esi
f01098b1:	83 ee 01             	sub    $0x1,%esi
f01098b4:	83 fe ff             	cmp    $0xffffffff,%esi
f01098b7:	74 38                	je     f01098f1 <memcmp+0x48>
f01098b9:	8b 45 08             	mov    0x8(%ebp),%eax
f01098bc:	8b 55 0c             	mov    0xc(%ebp),%edx
		if (*s1 != *s2)
f01098bf:	0f b6 18             	movzbl (%eax),%ebx
f01098c2:	0f b6 0a             	movzbl (%edx),%ecx
f01098c5:	38 cb                	cmp    %cl,%bl
f01098c7:	74 20                	je     f01098e9 <memcmp+0x40>
f01098c9:	eb 12                	jmp    f01098dd <memcmp+0x34>
f01098cb:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
f01098cf:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
f01098d3:	83 c0 01             	add    $0x1,%eax
f01098d6:	83 c2 01             	add    $0x1,%edx
f01098d9:	38 cb                	cmp    %cl,%bl
f01098db:	74 0c                	je     f01098e9 <memcmp+0x40>
			return (int) *s1 - (int) *s2;
f01098dd:	0f b6 d3             	movzbl %bl,%edx
f01098e0:	0f b6 c1             	movzbl %cl,%eax
f01098e3:	29 c2                	sub    %eax,%edx
f01098e5:	89 d0                	mov    %edx,%eax
f01098e7:	eb 0d                	jmp    f01098f6 <memcmp+0x4d>
f01098e9:	83 ee 01             	sub    $0x1,%esi
f01098ec:	83 fe ff             	cmp    $0xffffffff,%esi
f01098ef:	75 da                	jne    f01098cb <memcmp+0x22>
f01098f1:	b8 00 00 00 00       	mov    $0x0,%eax
		s1++, s2++;
	}

	return 0;
}
f01098f6:	5b                   	pop    %ebx
f01098f7:	5e                   	pop    %esi
f01098f8:	5d                   	pop    %ebp
f01098f9:	c3                   	ret    

f01098fa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01098fa:	55                   	push   %ebp
f01098fb:	89 e5                	mov    %esp,%ebp
f01098fd:	53                   	push   %ebx
f01098fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	const void *ends = (const char *) s + n;
f0109901:	89 da                	mov    %ebx,%edx
f0109903:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0109906:	39 d3                	cmp    %edx,%ebx
f0109908:	73 1a                	jae    f0109924 <memfind+0x2a>
		if (*(const unsigned char *) s == (unsigned char) c)
f010990a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
			break;
f010990e:	89 d8                	mov    %ebx,%eax
f0109910:	38 0b                	cmp    %cl,(%ebx)
f0109912:	75 06                	jne    f010991a <memfind+0x20>
f0109914:	eb 0e                	jmp    f0109924 <memfind+0x2a>
f0109916:	38 08                	cmp    %cl,(%eax)
f0109918:	74 0c                	je     f0109926 <memfind+0x2c>
f010991a:	83 c0 01             	add    $0x1,%eax
f010991d:	39 d0                	cmp    %edx,%eax
f010991f:	90                   	nop    
f0109920:	75 f4                	jne    f0109916 <memfind+0x1c>
f0109922:	eb 02                	jmp    f0109926 <memfind+0x2c>
f0109924:	89 d8                	mov    %ebx,%eax
	return (void *) s;
}
f0109926:	5b                   	pop    %ebx
f0109927:	5d                   	pop    %ebp
f0109928:	c3                   	ret    

f0109929 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0109929:	55                   	push   %ebp
f010992a:	89 e5                	mov    %esp,%ebp
f010992c:	57                   	push   %edi
f010992d:	56                   	push   %esi
f010992e:	53                   	push   %ebx
f010992f:	83 ec 04             	sub    $0x4,%esp
f0109932:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0109935:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0109938:	0f b6 03             	movzbl (%ebx),%eax
f010993b:	3c 20                	cmp    $0x20,%al
f010993d:	74 04                	je     f0109943 <strtol+0x1a>
f010993f:	3c 09                	cmp    $0x9,%al
f0109941:	75 0e                	jne    f0109951 <strtol+0x28>
		s++;
f0109943:	83 c3 01             	add    $0x1,%ebx
f0109946:	0f b6 03             	movzbl (%ebx),%eax
f0109949:	3c 20                	cmp    $0x20,%al
f010994b:	74 f6                	je     f0109943 <strtol+0x1a>
f010994d:	3c 09                	cmp    $0x9,%al
f010994f:	74 f2                	je     f0109943 <strtol+0x1a>

	// plus/minus sign
	if (*s == '+')
f0109951:	3c 2b                	cmp    $0x2b,%al
f0109953:	75 0d                	jne    f0109962 <strtol+0x39>
		s++;
f0109955:	83 c3 01             	add    $0x1,%ebx
f0109958:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
f010995f:	90                   	nop    
f0109960:	eb 15                	jmp    f0109977 <strtol+0x4e>
	else if (*s == '-')
f0109962:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
f0109969:	3c 2d                	cmp    $0x2d,%al
f010996b:	75 0a                	jne    f0109977 <strtol+0x4e>
		s++, neg = 1;
f010996d:	83 c3 01             	add    $0x1,%ebx
f0109970:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0109977:	85 f6                	test   %esi,%esi
f0109979:	0f 94 c0             	sete   %al
f010997c:	84 c0                	test   %al,%al
f010997e:	75 05                	jne    f0109985 <strtol+0x5c>
f0109980:	83 fe 10             	cmp    $0x10,%esi
f0109983:	75 17                	jne    f010999c <strtol+0x73>
f0109985:	80 3b 30             	cmpb   $0x30,(%ebx)
f0109988:	75 12                	jne    f010999c <strtol+0x73>
f010998a:	80 7b 01 78          	cmpb   $0x78,0x1(%ebx)
f010998e:	66 90                	xchg   %ax,%ax
f0109990:	75 0a                	jne    f010999c <strtol+0x73>
		s += 2, base = 16;
f0109992:	83 c3 02             	add    $0x2,%ebx
f0109995:	be 10 00 00 00       	mov    $0x10,%esi
f010999a:	eb 1f                	jmp    f01099bb <strtol+0x92>
	else if (base == 0 && s[0] == '0')
f010999c:	85 f6                	test   %esi,%esi
f010999e:	66 90                	xchg   %ax,%ax
f01099a0:	75 10                	jne    f01099b2 <strtol+0x89>
f01099a2:	80 3b 30             	cmpb   $0x30,(%ebx)
f01099a5:	75 0b                	jne    f01099b2 <strtol+0x89>
		s++, base = 8;
f01099a7:	83 c3 01             	add    $0x1,%ebx
f01099aa:	66 be 08 00          	mov    $0x8,%si
f01099ae:	66 90                	xchg   %ax,%ax
f01099b0:	eb 09                	jmp    f01099bb <strtol+0x92>
	else if (base == 0)
f01099b2:	84 c0                	test   %al,%al
f01099b4:	74 05                	je     f01099bb <strtol+0x92>
f01099b6:	be 0a 00 00 00       	mov    $0xa,%esi
f01099bb:	bf 00 00 00 00       	mov    $0x0,%edi
		base = 10;

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01099c0:	0f b6 13             	movzbl (%ebx),%edx
f01099c3:	89 d1                	mov    %edx,%ecx
f01099c5:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
f01099c8:	3c 09                	cmp    $0x9,%al
f01099ca:	77 08                	ja     f01099d4 <strtol+0xab>
			dig = *s - '0';
f01099cc:	0f be c2             	movsbl %dl,%eax
f01099cf:	8d 50 d0             	lea    0xffffffd0(%eax),%edx
f01099d2:	eb 1c                	jmp    f01099f0 <strtol+0xc7>
		else if (*s >= 'a' && *s <= 'z')
f01099d4:	8d 41 9f             	lea    0xffffff9f(%ecx),%eax
f01099d7:	3c 19                	cmp    $0x19,%al
f01099d9:	77 08                	ja     f01099e3 <strtol+0xba>
			dig = *s - 'a' + 10;
f01099db:	0f be c2             	movsbl %dl,%eax
f01099de:	8d 50 a9             	lea    0xffffffa9(%eax),%edx
f01099e1:	eb 0d                	jmp    f01099f0 <strtol+0xc7>
		else if (*s >= 'A' && *s <= 'Z')
f01099e3:	8d 41 bf             	lea    0xffffffbf(%ecx),%eax
f01099e6:	3c 19                	cmp    $0x19,%al
f01099e8:	77 17                	ja     f0109a01 <strtol+0xd8>
			dig = *s - 'A' + 10;
f01099ea:	0f be c2             	movsbl %dl,%eax
f01099ed:	8d 50 c9             	lea    0xffffffc9(%eax),%edx
		else
			break;
		if (dig >= base)
f01099f0:	39 f2                	cmp    %esi,%edx
f01099f2:	7d 0d                	jge    f0109a01 <strtol+0xd8>
			break;
		s++, val = (val * base) + dig;
f01099f4:	83 c3 01             	add    $0x1,%ebx
f01099f7:	89 f8                	mov    %edi,%eax
f01099f9:	0f af c6             	imul   %esi,%eax
f01099fc:	8d 3c 02             	lea    (%edx,%eax,1),%edi
f01099ff:	eb bf                	jmp    f01099c0 <strtol+0x97>
		// we don't properly detect overflow!
	}
f0109a01:	89 f8                	mov    %edi,%eax

	if (endptr)
f0109a03:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0109a07:	74 05                	je     f0109a0e <strtol+0xe5>
		*endptr = (char *) s;
f0109a09:	8b 55 0c             	mov    0xc(%ebp),%edx
f0109a0c:	89 1a                	mov    %ebx,(%edx)
	return (neg ? -val : val);
f0109a0e:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0109a12:	74 04                	je     f0109a18 <strtol+0xef>
f0109a14:	89 c7                	mov    %eax,%edi
f0109a16:	f7 df                	neg    %edi
}
f0109a18:	89 f8                	mov    %edi,%eax
f0109a1a:	83 c4 04             	add    $0x4,%esp
f0109a1d:	5b                   	pop    %ebx
f0109a1e:	5e                   	pop    %esi
f0109a1f:	5f                   	pop    %edi
f0109a20:	5d                   	pop    %ebp
f0109a21:	c3                   	ret    
	...

f0109a24 <pci_e100_attach>:
}
static unsigned CSR_ADDR;
int 
pci_e100_attach(struct pci_func *pcif)
{
f0109a24:	55                   	push   %ebp
f0109a25:	89 e5                	mov    %esp,%ebp
f0109a27:	53                   	push   %ebx
f0109a28:	83 ec 14             	sub    $0x14,%esp
f0109a2b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	pci_func_enable(pcif);
f0109a2e:	89 1c 24             	mov    %ebx,(%esp)
f0109a31:	e8 4b 02 00 00       	call   f0109c81 <pci_func_enable>
	cprintf("CSR Memory Mapped Base Address Register:%d bytes at 0x%x\n",pcif->reg_size[0],pcif->reg_base[0]);
f0109a36:	8b 43 14             	mov    0x14(%ebx),%eax
f0109a39:	89 44 24 08          	mov    %eax,0x8(%esp)
f0109a3d:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0109a40:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109a44:	c7 04 24 10 47 11 f0 	movl   $0xf0114710,(%esp)
f0109a4b:	e8 e7 9f ff ff       	call   f0103a37 <cprintf>
	cprintf("CSR I/O Mapped Base Address Register:%d bytes at 0x%x\n",pcif->reg_size[1],pcif->reg_base[1]);
f0109a50:	8b 43 18             	mov    0x18(%ebx),%eax
f0109a53:	89 44 24 08          	mov    %eax,0x8(%esp)
f0109a57:	8b 43 30             	mov    0x30(%ebx),%eax
f0109a5a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109a5e:	c7 04 24 4c 47 11 f0 	movl   $0xf011474c,(%esp)
f0109a65:	e8 cd 9f ff ff       	call   f0103a37 <cprintf>
	cprintf("Flash Memory Base Address Register:%d bytes at 0x%x\n",pcif->reg_size[2],pcif->reg_base[2]);
f0109a6a:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0109a6d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0109a71:	8b 43 34             	mov    0x34(%ebx),%eax
f0109a74:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109a78:	c7 04 24 84 47 11 f0 	movl   $0xf0114784,(%esp)
f0109a7f:	e8 b3 9f ff ff       	call   f0103a37 <cprintf>
	CSR_ADDR=pcif->reg_base[1];//利用I/O端口操作CSR
f0109a84:	8b 53 18             	mov    0x18(%ebx),%edx
f0109a87:	89 15 60 98 2a f0    	mov    %edx,0xf02a9860

static __inline void
outl(int port, uint32_t data)
{
	__asm __volatile("outl %0,%w1" : : "a" (data), "d" (port));
f0109a8d:	b8 00 00 00 00       	mov    $0x0,%eax
f0109a92:	83 c2 08             	add    $0x8,%edx
f0109a95:	ef                   	out    %eax,(%dx)
f0109a96:	ba 84 00 00 00       	mov    $0x84,%edx
f0109a9b:	ec                   	in     (%dx),%al
f0109a9c:	ec                   	in     (%dx),%al
f0109a9d:	ec                   	in     (%dx),%al
f0109a9e:	ec                   	in     (%dx),%al
f0109a9f:	ec                   	in     (%dx),%al
f0109aa0:	ec                   	in     (%dx),%al
f0109aa1:	ec                   	in     (%dx),%al
f0109aa2:	ec                   	in     (%dx),%al
	outl(CSR_ADDR+CSR_PORT,software_reset);//向PORT中写入0,软件重启芯片
	delay();//延时10us
	//panic("e100 initialization is not implemented\n");
	return 0;
}
f0109aa3:	b8 00 00 00 00       	mov    $0x0,%eax
f0109aa8:	83 c4 14             	add    $0x14,%esp
f0109aab:	5b                   	pop    %ebx
f0109aac:	5d                   	pop    %ebp
f0109aad:	c3                   	ret    
	...

f0109ab0 <pci_attach_match>:

static int __attribute__((warn_unused_result))
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
f0109ab0:	55                   	push   %ebp
f0109ab1:	89 e5                	mov    %esp,%ebp
f0109ab3:	57                   	push   %edi
f0109ab4:	56                   	push   %esi
f0109ab5:	53                   	push   %ebx
f0109ab6:	83 ec 1c             	sub    $0x1c,%esp
f0109ab9:	89 c7                	mov    %eax,%edi
f0109abb:	89 55 f0             	mov    %edx,0xfffffff0(%ebp)
f0109abe:	89 ce                	mov    %ecx,%esi
	uint32_t i;
	
	for (i = 0; list[i].attachfn; i++) {
f0109ac0:	8b 41 08             	mov    0x8(%ecx),%eax
f0109ac3:	85 c0                	test   %eax,%eax
f0109ac5:	74 4d                	je     f0109b14 <pci_attach_match+0x64>
f0109ac7:	8d 59 0c             	lea    0xc(%ecx),%ebx
		if (list[i].key1 == key1 && list[i].key2 == key2) {
f0109aca:	39 3e                	cmp    %edi,(%esi)
f0109acc:	75 3a                	jne    f0109b08 <pci_attach_match+0x58>
f0109ace:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
f0109ad1:	39 56 04             	cmp    %edx,0x4(%esi)
f0109ad4:	75 32                	jne    f0109b08 <pci_attach_match+0x58>
			int r = list[i].attachfn(pcif);
f0109ad6:	8b 55 08             	mov    0x8(%ebp),%edx
f0109ad9:	89 14 24             	mov    %edx,(%esp)
f0109adc:	ff d0                	call   *%eax
			if (r > 0)
f0109ade:	85 c0                	test   %eax,%eax
f0109ae0:	7f 37                	jg     f0109b19 <pci_attach_match+0x69>
				return r;
			if (r < 0)
f0109ae2:	85 c0                	test   %eax,%eax
f0109ae4:	79 22                	jns    f0109b08 <pci_attach_match+0x58>
				cprintf("pci_attach_match: attaching "
f0109ae6:	89 44 24 10          	mov    %eax,0x10(%esp)
f0109aea:	8b 46 08             	mov    0x8(%esi),%eax
f0109aed:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0109af1:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0109af4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0109af8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0109afc:	c7 04 24 bc 47 11 f0 	movl   $0xf01147bc,(%esp)
f0109b03:	e8 2f 9f ff ff       	call   f0103a37 <cprintf>
f0109b08:	89 de                	mov    %ebx,%esi
f0109b0a:	8b 43 08             	mov    0x8(%ebx),%eax
f0109b0d:	83 c3 0c             	add    $0xc,%ebx
f0109b10:	85 c0                	test   %eax,%eax
f0109b12:	75 b6                	jne    f0109aca <pci_attach_match+0x1a>
f0109b14:	b8 00 00 00 00       	mov    $0x0,%eax
					"%x.%x (%p): e\n",
					key1, key2, list[i].attachfn, r);
		}
	}
	return 0;
}
f0109b19:	83 c4 1c             	add    $0x1c,%esp
f0109b1c:	5b                   	pop    %ebx
f0109b1d:	5e                   	pop    %esi
f0109b1e:	5f                   	pop    %edi
f0109b1f:	5d                   	pop    %ebp
f0109b20:	c3                   	ret    

f0109b21 <pci_conf1_set_addr>:
f0109b21:	55                   	push   %ebp
f0109b22:	89 e5                	mov    %esp,%ebp
f0109b24:	53                   	push   %ebx
f0109b25:	83 ec 14             	sub    $0x14,%esp
f0109b28:	89 cb                	mov    %ecx,%ebx
f0109b2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0109b2d:	3d ff 00 00 00       	cmp    $0xff,%eax
f0109b32:	76 24                	jbe    f0109b58 <pci_conf1_set_addr+0x37>
f0109b34:	c7 44 24 0c 5c 49 11 	movl   $0xf011495c,0xc(%esp)
f0109b3b:	f0 
f0109b3c:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0109b43:	f0 
f0109b44:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
f0109b4b:	00 
f0109b4c:	c7 04 24 66 49 11 f0 	movl   $0xf0114966,(%esp)
f0109b53:	e8 2e 65 ff ff       	call   f0100086 <_panic>
f0109b58:	83 fa 1f             	cmp    $0x1f,%edx
f0109b5b:	76 24                	jbe    f0109b81 <pci_conf1_set_addr+0x60>
f0109b5d:	c7 44 24 0c 71 49 11 	movl   $0xf0114971,0xc(%esp)
f0109b64:	f0 
f0109b65:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0109b6c:	f0 
f0109b6d:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
f0109b74:	00 
f0109b75:	c7 04 24 66 49 11 f0 	movl   $0xf0114966,(%esp)
f0109b7c:	e8 05 65 ff ff       	call   f0100086 <_panic>
f0109b81:	83 fb 07             	cmp    $0x7,%ebx
f0109b84:	76 24                	jbe    f0109baa <pci_conf1_set_addr+0x89>
f0109b86:	c7 44 24 0c 7a 49 11 	movl   $0xf011497a,0xc(%esp)
f0109b8d:	f0 
f0109b8e:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0109b95:	f0 
f0109b96:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
f0109b9d:	00 
f0109b9e:	c7 04 24 66 49 11 f0 	movl   $0xf0114966,(%esp)
f0109ba5:	e8 dc 64 ff ff       	call   f0100086 <_panic>
f0109baa:	81 f9 ff 00 00 00    	cmp    $0xff,%ecx
f0109bb0:	76 24                	jbe    f0109bd6 <pci_conf1_set_addr+0xb5>
f0109bb2:	c7 44 24 0c 83 49 11 	movl   $0xf0114983,0xc(%esp)
f0109bb9:	f0 
f0109bba:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0109bc1:	f0 
f0109bc2:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
f0109bc9:	00 
f0109bca:	c7 04 24 66 49 11 f0 	movl   $0xf0114966,(%esp)
f0109bd1:	e8 b0 64 ff ff       	call   f0100086 <_panic>
f0109bd6:	f6 c1 03             	test   $0x3,%cl
f0109bd9:	74 24                	je     f0109bff <pci_conf1_set_addr+0xde>
f0109bdb:	c7 44 24 0c 90 49 11 	movl   $0xf0114990,0xc(%esp)
f0109be2:	f0 
f0109be3:	c7 44 24 08 8c b7 10 	movl   $0xf010b78c,0x8(%esp)
f0109bea:	f0 
f0109beb:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
f0109bf2:	00 
f0109bf3:	c7 04 24 66 49 11 f0 	movl   $0xf0114966,(%esp)
f0109bfa:	e8 87 64 ff ff       	call   f0100086 <_panic>

static __inline void
outl(int port, uint32_t data)
{
	__asm __volatile("outl %0,%w1" : : "a" (data), "d" (port));
f0109bff:	c1 e0 10             	shl    $0x10,%eax
f0109c02:	0d 00 00 00 80       	or     $0x80000000,%eax
f0109c07:	c1 e2 0b             	shl    $0xb,%edx
f0109c0a:	09 d0                	or     %edx,%eax
f0109c0c:	09 c8                	or     %ecx,%eax
f0109c0e:	89 da                	mov    %ebx,%edx
f0109c10:	c1 e2 08             	shl    $0x8,%edx
f0109c13:	09 d0                	or     %edx,%eax
f0109c15:	8b 15 20 4a 11 f0    	mov    0xf0114a20,%edx
f0109c1b:	ef                   	out    %eax,(%dx)
f0109c1c:	83 c4 14             	add    $0x14,%esp
f0109c1f:	5b                   	pop    %ebx
f0109c20:	5d                   	pop    %ebp
f0109c21:	c3                   	ret    

f0109c22 <pci_conf_write>:
f0109c22:	55                   	push   %ebp
f0109c23:	89 e5                	mov    %esp,%ebp
f0109c25:	83 ec 18             	sub    $0x18,%esp
f0109c28:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
f0109c2b:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
f0109c2e:	89 d3                	mov    %edx,%ebx
f0109c30:	89 ce                	mov    %ecx,%esi
f0109c32:	8b 48 08             	mov    0x8(%eax),%ecx
f0109c35:	8b 50 04             	mov    0x4(%eax),%edx
f0109c38:	8b 00                	mov    (%eax),%eax
f0109c3a:	8b 40 04             	mov    0x4(%eax),%eax
f0109c3d:	89 1c 24             	mov    %ebx,(%esp)
f0109c40:	e8 dc fe ff ff       	call   f0109b21 <pci_conf1_set_addr>

static __inline void
outl(int port, uint32_t data)
{
	__asm __volatile("outl %0,%w1" : : "a" (data), "d" (port));
f0109c45:	8b 15 1c 4a 11 f0    	mov    0xf0114a1c,%edx
f0109c4b:	89 f0                	mov    %esi,%eax
f0109c4d:	ef                   	out    %eax,(%dx)
f0109c4e:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
f0109c51:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
f0109c54:	89 ec                	mov    %ebp,%esp
f0109c56:	5d                   	pop    %ebp
f0109c57:	c3                   	ret    

f0109c58 <pci_conf_read>:
f0109c58:	55                   	push   %ebp
f0109c59:	89 e5                	mov    %esp,%ebp
f0109c5b:	53                   	push   %ebx
f0109c5c:	83 ec 04             	sub    $0x4,%esp
f0109c5f:	8b 48 08             	mov    0x8(%eax),%ecx
f0109c62:	8b 58 04             	mov    0x4(%eax),%ebx
f0109c65:	8b 00                	mov    (%eax),%eax
f0109c67:	8b 40 04             	mov    0x4(%eax),%eax
f0109c6a:	89 14 24             	mov    %edx,(%esp)
f0109c6d:	89 da                	mov    %ebx,%edx
f0109c6f:	e8 ad fe ff ff       	call   f0109b21 <pci_conf1_set_addr>
static __inline uint32_t
inl(int port)
{
	uint32_t data;
	__asm __volatile("inl %w1,%0" : "=a" (data) : "d" (port));
f0109c74:	8b 15 1c 4a 11 f0    	mov    0xf0114a1c,%edx
f0109c7a:	ed                   	in     (%dx),%eax
f0109c7b:	83 c4 04             	add    $0x4,%esp
f0109c7e:	5b                   	pop    %ebx
f0109c7f:	5d                   	pop    %ebp
f0109c80:	c3                   	ret    

f0109c81 <pci_func_enable>:

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
f0109c81:	55                   	push   %ebp
f0109c82:	89 e5                	mov    %esp,%ebp
f0109c84:	57                   	push   %edi
f0109c85:	56                   	push   %esi
f0109c86:	53                   	push   %ebx
f0109c87:	83 ec 3c             	sub    $0x3c,%esp
f0109c8a:	8b 75 08             	mov    0x8(%ebp),%esi
	//初始化命令寄存器PCI_COMMAND_STATUS_REG
	//PCI_COMMAND_IO_ENABLE允许设备响应I/O空间的存取
	//PCI_COMMAND_MEM_ENABLE允许设备响应内存空间存取
	//PCI_COMMAND_MASTER_ENABLE允许设备作为bus master,可以产生PCI存取
	pci_conf_write(f, PCI_COMMAND_STATUS_REG,
f0109c8d:	b9 07 00 00 00       	mov    $0x7,%ecx
f0109c92:	ba 04 00 00 00       	mov    $0x4,%edx
f0109c97:	89 f0                	mov    %esi,%eax
f0109c99:	e8 84 ff ff ff       	call   f0109c22 <pci_conf_write>
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
f0109c9e:	bb 10 00 00 00       	mov    $0x10,%ebx
f0109ca3:	89 da                	mov    %ebx,%edx
f0109ca5:	89 f0                	mov    %esi,%eax
f0109ca7:	e8 ac ff ff ff       	call   f0109c58 <pci_conf_read>
f0109cac:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
f0109caf:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
f0109cb4:	89 da                	mov    %ebx,%edx
f0109cb6:	89 f0                	mov    %esi,%eax
f0109cb8:	e8 65 ff ff ff       	call   f0109c22 <pci_conf_write>
f0109cbd:	89 da                	mov    %ebx,%edx
f0109cbf:	89 f0                	mov    %esi,%eax
f0109cc1:	e8 92 ff ff ff       	call   f0109c58 <pci_conf_read>
f0109cc6:	89 c2                	mov    %eax,%edx
f0109cc8:	c7 45 e4 04 00 00 00 	movl   $0x4,0xffffffe4(%ebp)
f0109ccf:	85 c0                	test   %eax,%eax
f0109cd1:	0f 84 14 01 00 00    	je     f0109deb <pci_func_enable+0x16a>
f0109cd7:	8d 43 f0             	lea    0xfffffff0(%ebx),%eax
f0109cda:	c1 e8 02             	shr    $0x2,%eax
f0109cdd:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
f0109ce0:	f6 c2 01             	test   $0x1,%dl
f0109ce3:	75 52                	jne    f0109d37 <pci_func_enable+0xb6>
f0109ce5:	89 d0                	mov    %edx,%eax
f0109ce7:	83 e0 06             	and    $0x6,%eax
f0109cea:	83 f8 04             	cmp    $0x4,%eax
f0109ced:	0f 94 c0             	sete   %al
f0109cf0:	0f b6 c0             	movzbl %al,%eax
f0109cf3:	8d 04 85 04 00 00 00 	lea    0x4(,%eax,4),%eax
f0109cfa:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
f0109cfd:	83 e2 f0             	and    $0xfffffff0,%edx
f0109d00:	89 d0                	mov    %edx,%eax
f0109d02:	f7 d8                	neg    %eax
f0109d04:	89 d7                	mov    %edx,%edi
f0109d06:	21 c7                	and    %eax,%edi
f0109d08:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
f0109d0b:	83 e2 f0             	and    $0xfffffff0,%edx
f0109d0e:	89 55 f0             	mov    %edx,0xfffffff0(%ebp)
f0109d11:	83 3d 40 4a 11 f0 00 	cmpl   $0x0,0xf0114a40
f0109d18:	74 66                	je     f0109d80 <pci_func_enable+0xff>
f0109d1a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0109d1e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0109d22:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0109d25:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109d29:	c7 04 24 e8 47 11 f0 	movl   $0xf01147e8,(%esp)
f0109d30:	e8 02 9d ff ff       	call   f0103a37 <cprintf>
f0109d35:	eb 49                	jmp    f0109d80 <pci_func_enable+0xff>
f0109d37:	83 e2 fc             	and    $0xfffffffc,%edx
f0109d3a:	89 d0                	mov    %edx,%eax
f0109d3c:	f7 d8                	neg    %eax
f0109d3e:	89 d7                	mov    %edx,%edi
f0109d40:	21 c7                	and    %eax,%edi
f0109d42:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
f0109d45:	83 e2 fc             	and    $0xfffffffc,%edx
f0109d48:	89 55 f0             	mov    %edx,0xfffffff0(%ebp)
f0109d4b:	c7 45 e4 04 00 00 00 	movl   $0x4,0xffffffe4(%ebp)
f0109d52:	83 3d 40 4a 11 f0 00 	cmpl   $0x0,0xf0114a40
f0109d59:	74 25                	je     f0109d80 <pci_func_enable+0xff>
				cprintf("  io region %d: %d bytes at 0x%x\n",
f0109d5b:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0109d5e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0109d62:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0109d66:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
f0109d69:	89 54 24 04          	mov    %edx,0x4(%esp)
f0109d6d:	c7 04 24 0c 48 11 f0 	movl   $0xf011480c,(%esp)
f0109d74:	e8 be 9c ff ff       	call   f0103a37 <cprintf>
f0109d79:	c7 45 e4 04 00 00 00 	movl   $0x4,0xffffffe4(%ebp)
					regnum, size, base);
		}
		
		pci_conf_write(f, bar, oldv);
f0109d80:	8b 4d e8             	mov    0xffffffe8(%ebp),%ecx
f0109d83:	89 da                	mov    %ebx,%edx
f0109d85:	89 f0                	mov    %esi,%eax
f0109d87:	e8 96 fe ff ff       	call   f0109c22 <pci_conf_write>
		f->reg_base[regnum] = base;
f0109d8c:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
f0109d8f:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0109d92:	89 54 86 14          	mov    %edx,0x14(%esi,%eax,4)
		f->reg_size[regnum] = size;
f0109d96:	89 7c 86 2c          	mov    %edi,0x2c(%esi,%eax,4)
		
		if (size && !base)
f0109d9a:	85 ff                	test   %edi,%edi
f0109d9c:	74 4d                	je     f0109deb <pci_func_enable+0x16a>
f0109d9e:	85 d2                	test   %edx,%edx
f0109da0:	75 49                	jne    f0109deb <pci_func_enable+0x16a>
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
f0109da2:	8b 56 0c             	mov    0xc(%esi),%edx
f0109da5:	89 7c 24 20          	mov    %edi,0x20(%esp)
f0109da9:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
f0109db0:	00 
f0109db1:	89 44 24 18          	mov    %eax,0x18(%esp)
f0109db5:	89 d0                	mov    %edx,%eax
f0109db7:	c1 e8 10             	shr    $0x10,%eax
f0109dba:	89 44 24 14          	mov    %eax,0x14(%esp)
f0109dbe:	81 e2 ff ff 00 00    	and    $0xffff,%edx
f0109dc4:	89 54 24 10          	mov    %edx,0x10(%esp)
f0109dc8:	8b 46 08             	mov    0x8(%esi),%eax
f0109dcb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0109dcf:	8b 46 04             	mov    0x4(%esi),%eax
f0109dd2:	89 44 24 08          	mov    %eax,0x8(%esp)
f0109dd6:	8b 06                	mov    (%esi),%eax
f0109dd8:	8b 40 04             	mov    0x4(%eax),%eax
f0109ddb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109ddf:	c7 04 24 30 48 11 f0 	movl   $0xf0114830,(%esp)
f0109de6:	e8 4c 9c ff ff       	call   f0103a37 <cprintf>
f0109deb:	03 5d e4             	add    0xffffffe4(%ebp),%ebx
f0109dee:	83 fb 27             	cmp    $0x27,%ebx
f0109df1:	0f 86 ac fe ff ff    	jbe    f0109ca3 <pci_func_enable+0x22>
				"may be misconfigured: "
				"region %d: base 0x%x, size %d\n",
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
f0109df7:	8b 46 0c             	mov    0xc(%esi),%eax
f0109dfa:	89 c2                	mov    %eax,%edx
f0109dfc:	c1 ea 10             	shr    $0x10,%edx
f0109dff:	89 54 24 14          	mov    %edx,0x14(%esp)
f0109e03:	25 ff ff 00 00       	and    $0xffff,%eax
f0109e08:	89 44 24 10          	mov    %eax,0x10(%esp)
f0109e0c:	8b 46 08             	mov    0x8(%esi),%eax
f0109e0f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0109e13:	8b 46 04             	mov    0x4(%esi),%eax
f0109e16:	89 44 24 08          	mov    %eax,0x8(%esp)
f0109e1a:	8b 06                	mov    (%esi),%eax
f0109e1c:	8b 40 04             	mov    0x4(%eax),%eax
f0109e1f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109e23:	c7 04 24 8c 48 11 f0 	movl   $0xf011488c,(%esp)
f0109e2a:	e8 08 9c ff ff       	call   f0103a37 <cprintf>
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
}
f0109e2f:	83 c4 3c             	add    $0x3c,%esp
f0109e32:	5b                   	pop    %ebx
f0109e33:	5e                   	pop    %esi
f0109e34:	5f                   	pop    %edi
f0109e35:	5d                   	pop    %ebp
f0109e36:	c3                   	ret    

f0109e37 <pci_scan_bus>:
f0109e37:	55                   	push   %ebp
f0109e38:	89 e5                	mov    %esp,%ebp
f0109e3a:	57                   	push   %edi
f0109e3b:	56                   	push   %esi
f0109e3c:	53                   	push   %ebx
f0109e3d:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
f0109e43:	89 c3                	mov    %eax,%ebx
f0109e45:	c7 44 24 08 48 00 00 	movl   $0x48,0x8(%esp)
f0109e4c:	00 
f0109e4d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0109e54:	00 
f0109e55:	8d 45 ac             	lea    0xffffffac(%ebp),%eax
f0109e58:	89 04 24             	mov    %eax,(%esp)
f0109e5b:	e8 51 f9 ff ff       	call   f01097b1 <memset>
f0109e60:	89 5d ac             	mov    %ebx,0xffffffac(%ebp)
f0109e63:	c7 45 b0 00 00 00 00 	movl   $0x0,0xffffffb0(%ebp)
f0109e6a:	c7 85 10 ff ff ff 00 	movl   $0x0,0xffffff10(%ebp)
f0109e71:	00 00 00 
f0109e74:	ba 0c 00 00 00       	mov    $0xc,%edx
f0109e79:	8d 45 ac             	lea    0xffffffac(%ebp),%eax
f0109e7c:	e8 d7 fd ff ff       	call   f0109c58 <pci_conf_read>
f0109e81:	89 c7                	mov    %eax,%edi
f0109e83:	c1 ef 10             	shr    $0x10,%edi
f0109e86:	89 f8                	mov    %edi,%eax
f0109e88:	83 e0 7f             	and    $0x7f,%eax
f0109e8b:	83 f8 01             	cmp    $0x1,%eax
f0109e8e:	0f 87 89 01 00 00    	ja     f010a01d <pci_scan_bus+0x1e6>
f0109e94:	c7 44 24 08 48 00 00 	movl   $0x48,0x8(%esp)
f0109e9b:	00 
f0109e9c:	8d 45 ac             	lea    0xffffffac(%ebp),%eax
f0109e9f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109ea3:	8d 85 64 ff ff ff    	lea    0xffffff64(%ebp),%eax
f0109ea9:	89 04 24             	mov    %eax,(%esp)
f0109eac:	e8 d7 f9 ff ff       	call   f0109888 <memcpy>
f0109eb1:	c7 85 6c ff ff ff 00 	movl   $0x0,0xffffff6c(%ebp)
f0109eb8:	00 00 00 
f0109ebb:	e9 3b 01 00 00       	jmp    f0109ffb <pci_scan_bus+0x1c4>
f0109ec0:	8d 9d 1c ff ff ff    	lea    0xffffff1c(%ebp),%ebx
f0109ec6:	c7 44 24 08 48 00 00 	movl   $0x48,0x8(%esp)
f0109ecd:	00 
f0109ece:	8d 85 64 ff ff ff    	lea    0xffffff64(%ebp),%eax
f0109ed4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109ed8:	89 1c 24             	mov    %ebx,(%esp)
f0109edb:	e8 a8 f9 ff ff       	call   f0109888 <memcpy>
f0109ee0:	ba 00 00 00 00       	mov    $0x0,%edx
f0109ee5:	8d 85 64 ff ff ff    	lea    0xffffff64(%ebp),%eax
f0109eeb:	e8 68 fd ff ff       	call   f0109c58 <pci_conf_read>
f0109ef0:	89 85 28 ff ff ff    	mov    %eax,0xffffff28(%ebp)
f0109ef6:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0109efa:	0f 84 f4 00 00 00    	je     f0109ff4 <pci_scan_bus+0x1bd>
f0109f00:	ba 3c 00 00 00       	mov    $0x3c,%edx
f0109f05:	89 d8                	mov    %ebx,%eax
f0109f07:	e8 4c fd ff ff       	call   f0109c58 <pci_conf_read>
f0109f0c:	88 85 60 ff ff ff    	mov    %al,0xffffff60(%ebp)
f0109f12:	ba 08 00 00 00       	mov    $0x8,%edx
f0109f17:	89 d8                	mov    %ebx,%eax
f0109f19:	e8 3a fd ff ff       	call   f0109c58 <pci_conf_read>
f0109f1e:	89 c1                	mov    %eax,%ecx
f0109f20:	89 85 2c ff ff ff    	mov    %eax,0xffffff2c(%ebp)
f0109f26:	83 3d 18 4a 11 f0 00 	cmpl   $0x0,0xf0114a18
f0109f2d:	74 7d                	je     f0109fac <pci_scan_bus+0x175>
f0109f2f:	89 c3                	mov    %eax,%ebx
f0109f31:	c1 eb 18             	shr    $0x18,%ebx
f0109f34:	be a4 49 11 f0       	mov    $0xf01149a4,%esi
f0109f39:	83 fb 06             	cmp    $0x6,%ebx
f0109f3c:	77 07                	ja     f0109f45 <pci_scan_bus+0x10e>
f0109f3e:	8b 34 9d 24 4a 11 f0 	mov    0xf0114a24(,%ebx,4),%esi
f0109f45:	8b 95 28 ff ff ff    	mov    0xffffff28(%ebp),%edx
f0109f4b:	0f b6 85 60 ff ff ff 	movzbl 0xffffff60(%ebp),%eax
f0109f52:	89 44 24 24          	mov    %eax,0x24(%esp)
f0109f56:	89 74 24 20          	mov    %esi,0x20(%esp)
f0109f5a:	89 c8                	mov    %ecx,%eax
f0109f5c:	c1 e8 10             	shr    $0x10,%eax
f0109f5f:	25 ff 00 00 00       	and    $0xff,%eax
f0109f64:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0109f68:	89 5c 24 18          	mov    %ebx,0x18(%esp)
f0109f6c:	89 d0                	mov    %edx,%eax
f0109f6e:	c1 e8 10             	shr    $0x10,%eax
f0109f71:	89 44 24 14          	mov    %eax,0x14(%esp)
f0109f75:	81 e2 ff ff 00 00    	and    $0xffff,%edx
f0109f7b:	89 54 24 10          	mov    %edx,0x10(%esp)
f0109f7f:	8b 85 24 ff ff ff    	mov    0xffffff24(%ebp),%eax
f0109f85:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0109f89:	8b 85 20 ff ff ff    	mov    0xffffff20(%ebp),%eax
f0109f8f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0109f93:	8b 85 1c ff ff ff    	mov    0xffffff1c(%ebp),%eax
f0109f99:	8b 40 04             	mov    0x4(%eax),%eax
f0109f9c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109fa0:	c7 04 24 bc 48 11 f0 	movl   $0xf01148bc,(%esp)
f0109fa7:	e8 8b 9a ff ff       	call   f0103a37 <cprintf>
f0109fac:	8b 85 2c ff ff ff    	mov    0xffffff2c(%ebp),%eax
f0109fb2:	89 c2                	mov    %eax,%edx
f0109fb4:	c1 ea 10             	shr    $0x10,%edx
f0109fb7:	81 e2 ff 00 00 00    	and    $0xff,%edx
f0109fbd:	c1 e8 18             	shr    $0x18,%eax
f0109fc0:	8d 9d 1c ff ff ff    	lea    0xffffff1c(%ebp),%ebx
f0109fc6:	89 1c 24             	mov    %ebx,(%esp)
f0109fc9:	b9 64 17 13 f0       	mov    $0xf0131764,%ecx
f0109fce:	e8 dd fa ff ff       	call   f0109ab0 <pci_attach_match>
f0109fd3:	85 c0                	test   %eax,%eax
f0109fd5:	75 1d                	jne    f0109ff4 <pci_scan_bus+0x1bd>
f0109fd7:	8b 85 28 ff ff ff    	mov    0xffffff28(%ebp),%eax
f0109fdd:	89 c2                	mov    %eax,%edx
f0109fdf:	c1 ea 10             	shr    $0x10,%edx
f0109fe2:	25 ff ff 00 00       	and    $0xffff,%eax
f0109fe7:	89 1c 24             	mov    %ebx,(%esp)
f0109fea:	b9 7c 17 13 f0       	mov    $0xf013177c,%ecx
f0109fef:	e8 bc fa ff ff       	call   f0109ab0 <pci_attach_match>
f0109ff4:	83 85 6c ff ff ff 01 	addl   $0x1,0xffffff6c(%ebp)
f0109ffb:	89 f8                	mov    %edi,%eax
f0109ffd:	83 e0 80             	and    $0xffffff80,%eax
f010a000:	3c 01                	cmp    $0x1,%al
f010a002:	19 c0                	sbb    %eax,%eax
f010a004:	83 e0 f9             	and    $0xfffffff9,%eax
f010a007:	83 c0 08             	add    $0x8,%eax
f010a00a:	3b 85 6c ff ff ff    	cmp    0xffffff6c(%ebp),%eax
f010a010:	0f 87 aa fe ff ff    	ja     f0109ec0 <pci_scan_bus+0x89>
f010a016:	83 85 10 ff ff ff 01 	addl   $0x1,0xffffff10(%ebp)
f010a01d:	8b 45 b0             	mov    0xffffffb0(%ebp),%eax
f010a020:	83 c0 01             	add    $0x1,%eax
f010a023:	83 f8 1f             	cmp    $0x1f,%eax
f010a026:	77 08                	ja     f010a030 <pci_scan_bus+0x1f9>
f010a028:	89 45 b0             	mov    %eax,0xffffffb0(%ebp)
f010a02b:	e9 44 fe ff ff       	jmp    f0109e74 <pci_scan_bus+0x3d>
f010a030:	8b 85 10 ff ff ff    	mov    0xffffff10(%ebp),%eax
f010a036:	81 c4 0c 01 00 00    	add    $0x10c,%esp
f010a03c:	5b                   	pop    %ebx
f010a03d:	5e                   	pop    %esi
f010a03e:	5f                   	pop    %edi
f010a03f:	5d                   	pop    %ebp
f010a040:	c3                   	ret    

f010a041 <pci_init>:

int
pci_init(void)
{
f010a041:	55                   	push   %ebp
f010a042:	89 e5                	mov    %esp,%ebp
f010a044:	83 ec 18             	sub    $0x18,%esp
	static struct pci_bus root_bus;
	memset(&root_bus, 0, sizeof(root_bus));
f010a047:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
f010a04e:	00 
f010a04f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010a056:	00 
f010a057:	c7 04 24 64 98 2a f0 	movl   $0xf02a9864,(%esp)
f010a05e:	e8 4e f7 ff ff       	call   f01097b1 <memset>
	//PCI初始化代码扫描PCI总线0,建立总线树表示整个系统总线结构拓扑
	//系统初始化程序必须扫描基本PCI总线(总线0)和PCI-to-PCI桥.
	return pci_scan_bus(&root_bus);
f010a063:	b8 64 98 2a f0       	mov    $0xf02a9864,%eax
f010a068:	e8 ca fd ff ff       	call   f0109e37 <pci_scan_bus>
}
f010a06d:	c9                   	leave  
f010a06e:	c3                   	ret    

f010a06f <pci_bridge_attach>:
f010a06f:	55                   	push   %ebp
f010a070:	89 e5                	mov    %esp,%ebp
f010a072:	83 ec 38             	sub    $0x38,%esp
f010a075:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
f010a078:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
f010a07b:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
f010a07e:	8b 75 08             	mov    0x8(%ebp),%esi
f010a081:	ba 1c 00 00 00       	mov    $0x1c,%edx
f010a086:	89 f0                	mov    %esi,%eax
f010a088:	e8 cb fb ff ff       	call   f0109c58 <pci_conf_read>
f010a08d:	89 c3                	mov    %eax,%ebx
f010a08f:	ba 18 00 00 00       	mov    $0x18,%edx
f010a094:	89 f0                	mov    %esi,%eax
f010a096:	e8 bd fb ff ff       	call   f0109c58 <pci_conf_read>
f010a09b:	89 c7                	mov    %eax,%edi
f010a09d:	89 d8                	mov    %ebx,%eax
f010a09f:	83 e0 0f             	and    $0xf,%eax
f010a0a2:	83 f8 01             	cmp    $0x1,%eax
f010a0a5:	75 2a                	jne    f010a0d1 <pci_bridge_attach+0x62>
f010a0a7:	8b 46 08             	mov    0x8(%esi),%eax
f010a0aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010a0ae:	8b 46 04             	mov    0x4(%esi),%eax
f010a0b1:	89 44 24 08          	mov    %eax,0x8(%esp)
f010a0b5:	8b 06                	mov    (%esi),%eax
f010a0b7:	8b 40 04             	mov    0x4(%eax),%eax
f010a0ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f010a0be:	c7 04 24 f8 48 11 f0 	movl   $0xf01148f8,(%esp)
f010a0c5:	e8 6d 99 ff ff       	call   f0103a37 <cprintf>
f010a0ca:	b8 00 00 00 00       	mov    $0x0,%eax
f010a0cf:	eb 6f                	jmp    f010a140 <pci_bridge_attach+0xd1>
f010a0d1:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
f010a0d8:	00 
f010a0d9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010a0e0:	00 
f010a0e1:	8d 45 ec             	lea    0xffffffec(%ebp),%eax
f010a0e4:	89 04 24             	mov    %eax,(%esp)
f010a0e7:	e8 c5 f6 ff ff       	call   f01097b1 <memset>
f010a0ec:	89 75 ec             	mov    %esi,0xffffffec(%ebp)
f010a0ef:	89 f8                	mov    %edi,%eax
f010a0f1:	0f b6 d4             	movzbl %ah,%edx
f010a0f4:	89 55 f0             	mov    %edx,0xfffffff0(%ebp)
f010a0f7:	83 3d 18 4a 11 f0 00 	cmpl   $0x0,0xf0114a18
f010a0fe:	74 33                	je     f010a133 <pci_bridge_attach+0xc4>
f010a100:	c1 e8 10             	shr    $0x10,%eax
f010a103:	25 ff 00 00 00       	and    $0xff,%eax
f010a108:	89 44 24 14          	mov    %eax,0x14(%esp)
f010a10c:	89 54 24 10          	mov    %edx,0x10(%esp)
f010a110:	8b 46 08             	mov    0x8(%esi),%eax
f010a113:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010a117:	8b 46 04             	mov    0x4(%esi),%eax
f010a11a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010a11e:	8b 06                	mov    (%esi),%eax
f010a120:	8b 40 04             	mov    0x4(%eax),%eax
f010a123:	89 44 24 04          	mov    %eax,0x4(%esp)
f010a127:	c7 04 24 2c 49 11 f0 	movl   $0xf011492c,(%esp)
f010a12e:	e8 04 99 ff ff       	call   f0103a37 <cprintf>
f010a133:	8d 45 ec             	lea    0xffffffec(%ebp),%eax
f010a136:	e8 fc fc ff ff       	call   f0109e37 <pci_scan_bus>
f010a13b:	b8 01 00 00 00       	mov    $0x1,%eax
f010a140:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
f010a143:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
f010a146:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
f010a149:	89 ec                	mov    %ebp,%esp
f010a14b:	5d                   	pop    %ebp
f010a14c:	c3                   	ret    
f010a14d:	00 00                	add    %al,(%eax)
	...

f010a150 <time_init>:
static unsigned int ticks;

void
time_init(void) 
{
f010a150:	55                   	push   %ebp
f010a151:	89 e5                	mov    %esp,%ebp
	ticks = 0;
f010a153:	c7 05 6c 98 2a f0 00 	movl   $0x0,0xf02a986c
f010a15a:	00 00 00 
}
f010a15d:	5d                   	pop    %ebp
f010a15e:	c3                   	ret    

f010a15f <time_msec>:

// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void) 
{
	ticks++;
	if (ticks * 10 < ticks)
		panic("time_tick: time overflowed");
}

unsigned int
time_msec(void) 
{
f010a15f:	55                   	push   %ebp
f010a160:	89 e5                	mov    %esp,%ebp
f010a162:	a1 6c 98 2a f0       	mov    0xf02a986c,%eax
f010a167:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010a16a:	01 c0                	add    %eax,%eax
	return ticks * 10;
}
f010a16c:	5d                   	pop    %ebp
f010a16d:	c3                   	ret    

f010a16e <time_tick>:
f010a16e:	55                   	push   %ebp
f010a16f:	89 e5                	mov    %esp,%ebp
f010a171:	83 ec 18             	sub    $0x18,%esp
f010a174:	8b 15 6c 98 2a f0    	mov    0xf02a986c,%edx
f010a17a:	83 c2 01             	add    $0x1,%edx
f010a17d:	89 15 6c 98 2a f0    	mov    %edx,0xf02a986c
f010a183:	8d 04 92             	lea    (%edx,%edx,4),%eax
f010a186:	01 c0                	add    %eax,%eax
f010a188:	39 c2                	cmp    %eax,%edx
f010a18a:	76 1c                	jbe    f010a1a8 <time_tick+0x3a>
f010a18c:	c7 44 24 08 44 4a 11 	movl   $0xf0114a44,0x8(%esp)
f010a193:	f0 
f010a194:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
f010a19b:	00 
f010a19c:	c7 04 24 5f 4a 11 f0 	movl   $0xf0114a5f,(%esp)
f010a1a3:	e8 de 5e ff ff       	call   f0100086 <_panic>
f010a1a8:	c9                   	leave  
f010a1a9:	c3                   	ret    
f010a1aa:	00 00                	add    %al,(%eax)
f010a1ac:	00 00                	add    %al,(%eax)
	...

f010a1b0 <__divdi3>:
f010a1b0:	55                   	push   %ebp
f010a1b1:	89 e5                	mov    %esp,%ebp
f010a1b3:	57                   	push   %edi
f010a1b4:	56                   	push   %esi
f010a1b5:	83 ec 28             	sub    $0x28,%esp
f010a1b8:	8b 55 0c             	mov    0xc(%ebp),%edx
f010a1bb:	8b 45 08             	mov    0x8(%ebp),%eax
f010a1be:	8b 75 10             	mov    0x10(%ebp),%esi
f010a1c1:	8b 7d 14             	mov    0x14(%ebp),%edi
f010a1c4:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
f010a1c7:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
f010a1ca:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
f010a1cd:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
f010a1d4:	89 f0                	mov    %esi,%eax
f010a1d6:	89 fa                	mov    %edi,%edx
f010a1d8:	85 c9                	test   %ecx,%ecx
f010a1da:	0f 88 03 01 00 00    	js     f010a2e3 <__divdi3+0x133>
f010a1e0:	85 ff                	test   %edi,%edi
f010a1e2:	0f 88 e8 00 00 00    	js     f010a2d0 <__divdi3+0x120>
f010a1e8:	89 d7                	mov    %edx,%edi
f010a1ea:	89 c6                	mov    %eax,%esi
f010a1ec:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
f010a1ef:	89 c1                	mov    %eax,%ecx
f010a1f1:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
f010a1f4:	85 ff                	test   %edi,%edi
f010a1f6:	89 55 f0             	mov    %edx,0xfffffff0(%ebp)
f010a1f9:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
f010a1fc:	75 22                	jne    f010a220 <__divdi3+0x70>
f010a1fe:	39 c6                	cmp    %eax,%esi
f010a200:	77 4e                	ja     f010a250 <__divdi3+0xa0>
f010a202:	85 f6                	test   %esi,%esi
f010a204:	0f 84 16 01 00 00    	je     f010a320 <__divdi3+0x170>
f010a20a:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f010a20d:	89 fa                	mov    %edi,%edx
f010a20f:	f7 f1                	div    %ecx
f010a211:	89 c6                	mov    %eax,%esi
f010a213:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f010a216:	f7 f1                	div    %ecx
f010a218:	89 c1                	mov    %eax,%ecx
f010a21a:	eb 14                	jmp    f010a230 <__divdi3+0x80>
f010a21c:	8d 74 26 00          	lea    0x0(%esi),%esi
f010a220:	3b 7d ec             	cmp    0xffffffec(%ebp),%edi
f010a223:	76 3b                	jbe    f010a260 <__divdi3+0xb0>
f010a225:	31 c9                	xor    %ecx,%ecx
f010a227:	31 f6                	xor    %esi,%esi
f010a229:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
f010a230:	89 c8                	mov    %ecx,%eax
f010a232:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
f010a235:	89 f2                	mov    %esi,%edx
f010a237:	85 c9                	test   %ecx,%ecx
f010a239:	74 07                	je     f010a242 <__divdi3+0x92>
f010a23b:	f7 d8                	neg    %eax
f010a23d:	83 d2 00             	adc    $0x0,%edx
f010a240:	f7 da                	neg    %edx
f010a242:	83 c4 28             	add    $0x28,%esp
f010a245:	5e                   	pop    %esi
f010a246:	5f                   	pop    %edi
f010a247:	5d                   	pop    %ebp
f010a248:	c3                   	ret    
f010a249:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
f010a250:	89 d0                	mov    %edx,%eax
f010a252:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
f010a255:	f7 f6                	div    %esi
f010a257:	31 f6                	xor    %esi,%esi
f010a259:	89 c1                	mov    %eax,%ecx
f010a25b:	eb d3                	jmp    f010a230 <__divdi3+0x80>
f010a25d:	8d 76 00             	lea    0x0(%esi),%esi
f010a260:	0f bd c7             	bsr    %edi,%eax
f010a263:	83 f0 1f             	xor    $0x1f,%eax
f010a266:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
f010a269:	0f 84 91 00 00 00    	je     f010a300 <__divdi3+0x150>
f010a26f:	b8 20 00 00 00       	mov    $0x20,%eax
f010a274:	89 f2                	mov    %esi,%edx
f010a276:	2b 45 e8             	sub    0xffffffe8(%ebp),%eax
f010a279:	89 c1                	mov    %eax,%ecx
f010a27b:	d3 ea                	shr    %cl,%edx
f010a27d:	0f b6 4d e8          	movzbl 0xffffffe8(%ebp),%ecx
f010a281:	89 45 f4             	mov    %eax,0xfffffff4(%ebp)
f010a284:	89 f8                	mov    %edi,%eax
f010a286:	89 d7                	mov    %edx,%edi
f010a288:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
f010a28b:	d3 e0                	shl    %cl,%eax
f010a28d:	09 c7                	or     %eax,%edi
f010a28f:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f010a292:	d3 e6                	shl    %cl,%esi
f010a294:	0f b6 4d f4          	movzbl 0xfffffff4(%ebp),%ecx
f010a298:	d3 e8                	shr    %cl,%eax
f010a29a:	0f b6 4d e8          	movzbl 0xffffffe8(%ebp),%ecx
f010a29e:	d3 e2                	shl    %cl,%edx
f010a2a0:	0f b6 4d f4          	movzbl 0xfffffff4(%ebp),%ecx
f010a2a4:	09 d0                	or     %edx,%eax
f010a2a6:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
f010a2a9:	89 45 d4             	mov    %eax,0xffffffd4(%ebp)
f010a2ac:	d3 ea                	shr    %cl,%edx
f010a2ae:	f7 f7                	div    %edi
f010a2b0:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
f010a2b3:	89 c7                	mov    %eax,%edi
f010a2b5:	f7 e6                	mul    %esi
f010a2b7:	39 55 d4             	cmp    %edx,0xffffffd4(%ebp)
f010a2ba:	89 c6                	mov    %eax,%esi
f010a2bc:	72 7f                	jb     f010a33d <__divdi3+0x18d>
f010a2be:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
f010a2c1:	74 6d                	je     f010a330 <__divdi3+0x180>
f010a2c3:	89 f9                	mov    %edi,%ecx
f010a2c5:	31 f6                	xor    %esi,%esi
f010a2c7:	e9 64 ff ff ff       	jmp    f010a230 <__divdi3+0x80>
f010a2cc:	8d 74 26 00          	lea    0x0(%esi),%esi
f010a2d0:	89 f0                	mov    %esi,%eax
f010a2d2:	89 fa                	mov    %edi,%edx
f010a2d4:	f7 d8                	neg    %eax
f010a2d6:	83 d2 00             	adc    $0x0,%edx
f010a2d9:	f7 da                	neg    %edx
f010a2db:	f7 55 e4             	notl   0xffffffe4(%ebp)
f010a2de:	e9 05 ff ff ff       	jmp    f010a1e8 <__divdi3+0x38>
f010a2e3:	f7 5d d8             	negl   0xffffffd8(%ebp)
f010a2e6:	83 55 dc 00          	adcl   $0x0,0xffffffdc(%ebp)
f010a2ea:	f7 5d dc             	negl   0xffffffdc(%ebp)
f010a2ed:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
f010a2f4:	e9 e7 fe ff ff       	jmp    f010a1e0 <__divdi3+0x30>
f010a2f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
f010a300:	39 7d ec             	cmp    %edi,0xffffffec(%ebp)
f010a303:	77 09                	ja     f010a30e <__divdi3+0x15e>
f010a305:	39 75 f0             	cmp    %esi,0xfffffff0(%ebp)
f010a308:	0f 82 17 ff ff ff    	jb     f010a225 <__divdi3+0x75>
f010a30e:	b9 01 00 00 00       	mov    $0x1,%ecx
f010a313:	31 f6                	xor    %esi,%esi
f010a315:	e9 16 ff ff ff       	jmp    f010a230 <__divdi3+0x80>
f010a31a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f010a320:	b8 01 00 00 00       	mov    $0x1,%eax
f010a325:	31 d2                	xor    %edx,%edx
f010a327:	f7 f6                	div    %esi
f010a329:	89 c1                	mov    %eax,%ecx
f010a32b:	e9 da fe ff ff       	jmp    f010a20a <__divdi3+0x5a>
f010a330:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f010a333:	0f b6 4d e8          	movzbl 0xffffffe8(%ebp),%ecx
f010a337:	d3 e0                	shl    %cl,%eax
f010a339:	39 c6                	cmp    %eax,%esi
f010a33b:	76 86                	jbe    f010a2c3 <__divdi3+0x113>
f010a33d:	8d 4f ff             	lea    0xffffffff(%edi),%ecx
f010a340:	31 f6                	xor    %esi,%esi
f010a342:	e9 e9 fe ff ff       	jmp    f010a230 <__divdi3+0x80>
	...

f010a350 <__moddi3>:
f010a350:	55                   	push   %ebp
f010a351:	89 e5                	mov    %esp,%ebp
f010a353:	57                   	push   %edi
f010a354:	56                   	push   %esi
f010a355:	83 ec 50             	sub    $0x50,%esp
f010a358:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010a35b:	8b 45 10             	mov    0x10(%ebp),%eax
f010a35e:	8b 55 14             	mov    0x14(%ebp),%edx
f010a361:	c7 45 b8 00 00 00 00 	movl   $0x0,0xffffffb8(%ebp)
f010a368:	8b 75 08             	mov    0x8(%ebp),%esi
f010a36b:	85 ff                	test   %edi,%edi
f010a36d:	c7 45 bc 00 00 00 00 	movl   $0x0,0xffffffbc(%ebp)
f010a374:	89 45 b0             	mov    %eax,0xffffffb0(%ebp)
f010a377:	89 55 b4             	mov    %edx,0xffffffb4(%ebp)
f010a37a:	c7 45 c4 00 00 00 00 	movl   $0x0,0xffffffc4(%ebp)
f010a381:	0f 88 6b 01 00 00    	js     f010a4f2 <__moddi3+0x1a2>
f010a387:	8b 4d b4             	mov    0xffffffb4(%ebp),%ecx
f010a38a:	85 c9                	test   %ecx,%ecx
f010a38c:	0f 88 4e 01 00 00    	js     f010a4e0 <__moddi3+0x190>
f010a392:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
f010a395:	85 d2                	test   %edx,%edx
f010a397:	89 4d dc             	mov    %ecx,0xffffffdc(%ebp)
f010a39a:	89 c1                	mov    %eax,%ecx
f010a39c:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
f010a39f:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
f010a3a2:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
f010a3a5:	89 7d cc             	mov    %edi,0xffffffcc(%ebp)
f010a3a8:	75 28                	jne    f010a3d2 <__moddi3+0x82>
f010a3aa:	39 f8                	cmp    %edi,%eax
f010a3ac:	89 fa                	mov    %edi,%edx
f010a3ae:	0f 86 0c 01 00 00    	jbe    f010a4c0 <__moddi3+0x170>
f010a3b4:	89 f0                	mov    %esi,%eax
f010a3b6:	f7 f1                	div    %ecx
f010a3b8:	89 55 b8             	mov    %edx,0xffffffb8(%ebp)
f010a3bb:	c7 45 bc 00 00 00 00 	movl   $0x0,0xffffffbc(%ebp)
f010a3c2:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
f010a3c5:	8b 45 b8             	mov    0xffffffb8(%ebp),%eax
f010a3c8:	8b 55 bc             	mov    0xffffffbc(%ebp),%edx
f010a3cb:	89 01                	mov    %eax,(%ecx)
f010a3cd:	89 51 04             	mov    %edx,0x4(%ecx)
f010a3d0:	eb 1e                	jmp    f010a3f0 <__moddi3+0xa0>
f010a3d2:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
f010a3d5:	39 45 d4             	cmp    %eax,0xffffffd4(%ebp)
f010a3d8:	76 36                	jbe    f010a410 <__moddi3+0xc0>
f010a3da:	89 75 b8             	mov    %esi,0xffffffb8(%ebp)
f010a3dd:	8b 55 b8             	mov    0xffffffb8(%ebp),%edx
f010a3e0:	89 7d bc             	mov    %edi,0xffffffbc(%ebp)
f010a3e3:	8b 4d bc             	mov    0xffffffbc(%ebp),%ecx
f010a3e6:	89 55 f0             	mov    %edx,0xfffffff0(%ebp)
f010a3e9:	89 4d f4             	mov    %ecx,0xfffffff4(%ebp)
f010a3ec:	8d 74 26 00          	lea    0x0(%esi),%esi
f010a3f0:	8b 45 c4             	mov    0xffffffc4(%ebp),%eax
f010a3f3:	85 c0                	test   %eax,%eax
f010a3f5:	74 0a                	je     f010a401 <__moddi3+0xb1>
f010a3f7:	f7 5d f0             	negl   0xfffffff0(%ebp)
f010a3fa:	83 55 f4 00          	adcl   $0x0,0xfffffff4(%ebp)
f010a3fe:	f7 5d f4             	negl   0xfffffff4(%ebp)
f010a401:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f010a404:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f010a407:	83 c4 50             	add    $0x50,%esp
f010a40a:	5e                   	pop    %esi
f010a40b:	5f                   	pop    %edi
f010a40c:	5d                   	pop    %ebp
f010a40d:	c3                   	ret    
f010a40e:	66 90                	xchg   %ax,%ax
f010a410:	0f bd 45 d4          	bsr    0xffffffd4(%ebp),%eax
f010a414:	83 f0 1f             	xor    $0x1f,%eax
f010a417:	89 45 c8             	mov    %eax,0xffffffc8(%ebp)
f010a41a:	0f 84 f3 00 00 00    	je     f010a513 <__moddi3+0x1c3>
f010a420:	b8 20 00 00 00       	mov    $0x20,%eax
f010a425:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
f010a428:	2b 45 c8             	sub    0xffffffc8(%ebp),%eax
f010a42b:	8b 7d d8             	mov    0xffffffd8(%ebp),%edi
f010a42e:	8b 75 e0             	mov    0xffffffe0(%ebp),%esi
f010a431:	89 c1                	mov    %eax,%ecx
f010a433:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
f010a436:	d3 ea                	shr    %cl,%edx
f010a438:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
f010a43b:	0f b6 4d c8          	movzbl 0xffffffc8(%ebp),%ecx
f010a43f:	d3 e0                	shl    %cl,%eax
f010a441:	09 c2                	or     %eax,%edx
f010a443:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
f010a446:	d3 e7                	shl    %cl,%edi
f010a448:	0f b6 4d d0          	movzbl 0xffffffd0(%ebp),%ecx
f010a44c:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
f010a44f:	8b 55 cc             	mov    0xffffffcc(%ebp),%edx
f010a452:	d3 e8                	shr    %cl,%eax
f010a454:	0f b6 4d c8          	movzbl 0xffffffc8(%ebp),%ecx
f010a458:	d3 e2                	shl    %cl,%edx
f010a45a:	09 d0                	or     %edx,%eax
f010a45c:	8b 55 cc             	mov    0xffffffcc(%ebp),%edx
f010a45f:	d3 e6                	shl    %cl,%esi
f010a461:	0f b6 4d d0          	movzbl 0xffffffd0(%ebp),%ecx
f010a465:	d3 ea                	shr    %cl,%edx
f010a467:	f7 75 e4             	divl   0xffffffe4(%ebp)
f010a46a:	89 55 ac             	mov    %edx,0xffffffac(%ebp)
f010a46d:	f7 e7                	mul    %edi
f010a46f:	39 55 ac             	cmp    %edx,0xffffffac(%ebp)
f010a472:	0f 82 d8 00 00 00    	jb     f010a550 <__moddi3+0x200>
f010a478:	3b 55 ac             	cmp    0xffffffac(%ebp),%edx
f010a47b:	0f 84 c7 00 00 00    	je     f010a548 <__moddi3+0x1f8>
f010a481:	8b 4d ac             	mov    0xffffffac(%ebp),%ecx
f010a484:	29 c6                	sub    %eax,%esi
f010a486:	19 d1                	sbb    %edx,%ecx
f010a488:	89 4d ac             	mov    %ecx,0xffffffac(%ebp)
f010a48b:	0f b6 4d c8          	movzbl 0xffffffc8(%ebp),%ecx
f010a48f:	89 f2                	mov    %esi,%edx
f010a491:	8b 45 ac             	mov    0xffffffac(%ebp),%eax
f010a494:	d3 ea                	shr    %cl,%edx
f010a496:	0f b6 4d d0          	movzbl 0xffffffd0(%ebp),%ecx
f010a49a:	d3 e0                	shl    %cl,%eax
f010a49c:	0f b6 4d c8          	movzbl 0xffffffc8(%ebp),%ecx
f010a4a0:	09 c2                	or     %eax,%edx
f010a4a2:	8b 45 ac             	mov    0xffffffac(%ebp),%eax
f010a4a5:	89 55 b8             	mov    %edx,0xffffffb8(%ebp)
f010a4a8:	8b 55 b8             	mov    0xffffffb8(%ebp),%edx
f010a4ab:	d3 e8                	shr    %cl,%eax
f010a4ad:	89 45 bc             	mov    %eax,0xffffffbc(%ebp)
f010a4b0:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
f010a4b3:	8b 4d bc             	mov    0xffffffbc(%ebp),%ecx
f010a4b6:	89 10                	mov    %edx,(%eax)
f010a4b8:	89 48 04             	mov    %ecx,0x4(%eax)
f010a4bb:	e9 30 ff ff ff       	jmp    f010a3f0 <__moddi3+0xa0>
f010a4c0:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
f010a4c3:	85 d2                	test   %edx,%edx
f010a4c5:	74 3e                	je     f010a505 <__moddi3+0x1b5>
f010a4c7:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
f010a4ca:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
f010a4cd:	f7 f1                	div    %ecx
f010a4cf:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
f010a4d2:	f7 f1                	div    %ecx
f010a4d4:	e9 df fe ff ff       	jmp    f010a3b8 <__moddi3+0x68>
f010a4d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
f010a4e0:	8b 45 b0             	mov    0xffffffb0(%ebp),%eax
f010a4e3:	8b 55 b4             	mov    0xffffffb4(%ebp),%edx
f010a4e6:	f7 d8                	neg    %eax
f010a4e8:	83 d2 00             	adc    $0x0,%edx
f010a4eb:	f7 da                	neg    %edx
f010a4ed:	e9 a0 fe ff ff       	jmp    f010a392 <__moddi3+0x42>
f010a4f2:	f7 de                	neg    %esi
f010a4f4:	83 d7 00             	adc    $0x0,%edi
f010a4f7:	f7 df                	neg    %edi
f010a4f9:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,0xffffffc4(%ebp)
f010a500:	e9 82 fe ff ff       	jmp    f010a387 <__moddi3+0x37>
f010a505:	b8 01 00 00 00       	mov    $0x1,%eax
f010a50a:	31 d2                	xor    %edx,%edx
f010a50c:	f7 75 d8             	divl   0xffffffd8(%ebp)
f010a50f:	89 c1                	mov    %eax,%ecx
f010a511:	eb b4                	jmp    f010a4c7 <__moddi3+0x177>
f010a513:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
f010a516:	39 4d cc             	cmp    %ecx,0xffffffcc(%ebp)
f010a519:	77 19                	ja     f010a534 <__moddi3+0x1e4>
f010a51b:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f010a51e:	39 45 e0             	cmp    %eax,0xffffffe0(%ebp)
f010a521:	73 11                	jae    f010a534 <__moddi3+0x1e4>
f010a523:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
f010a526:	8b 55 cc             	mov    0xffffffcc(%ebp),%edx
f010a529:	89 45 b8             	mov    %eax,0xffffffb8(%ebp)
f010a52c:	89 55 bc             	mov    %edx,0xffffffbc(%ebp)
f010a52f:	e9 8e fe ff ff       	jmp    f010a3c2 <__moddi3+0x72>
f010a534:	8b 55 cc             	mov    0xffffffcc(%ebp),%edx
f010a537:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
f010a53a:	2b 4d d8             	sub    0xffffffd8(%ebp),%ecx
f010a53d:	1b 55 d4             	sbb    0xffffffd4(%ebp),%edx
f010a540:	89 4d e0             	mov    %ecx,0xffffffe0(%ebp)
f010a543:	89 55 cc             	mov    %edx,0xffffffcc(%ebp)
f010a546:	eb db                	jmp    f010a523 <__moddi3+0x1d3>
f010a548:	39 f0                	cmp    %esi,%eax
f010a54a:	0f 86 31 ff ff ff    	jbe    f010a481 <__moddi3+0x131>
f010a550:	29 f8                	sub    %edi,%eax
f010a552:	1b 55 e4             	sbb    0xffffffe4(%ebp),%edx
f010a555:	e9 27 ff ff ff       	jmp    f010a481 <__moddi3+0x131>
f010a55a:	00 00                	add    %al,(%eax)
f010a55c:	00 00                	add    %al,(%eax)
	...

f010a560 <__udivdi3>:
f010a560:	55                   	push   %ebp
f010a561:	89 e5                	mov    %esp,%ebp
f010a563:	57                   	push   %edi
f010a564:	56                   	push   %esi
f010a565:	83 ec 1c             	sub    $0x1c,%esp
f010a568:	8b 45 10             	mov    0x10(%ebp),%eax
f010a56b:	8b 55 14             	mov    0x14(%ebp),%edx
f010a56e:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010a571:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
f010a574:	89 c1                	mov    %eax,%ecx
f010a576:	8b 45 08             	mov    0x8(%ebp),%eax
f010a579:	85 d2                	test   %edx,%edx
f010a57b:	89 d6                	mov    %edx,%esi
f010a57d:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
f010a580:	75 1e                	jne    f010a5a0 <__udivdi3+0x40>
f010a582:	39 f9                	cmp    %edi,%ecx
f010a584:	0f 86 8d 00 00 00    	jbe    f010a617 <__udivdi3+0xb7>
f010a58a:	89 fa                	mov    %edi,%edx
f010a58c:	f7 f1                	div    %ecx
f010a58e:	89 c1                	mov    %eax,%ecx
f010a590:	89 c8                	mov    %ecx,%eax
f010a592:	89 f2                	mov    %esi,%edx
f010a594:	83 c4 1c             	add    $0x1c,%esp
f010a597:	5e                   	pop    %esi
f010a598:	5f                   	pop    %edi
f010a599:	5d                   	pop    %ebp
f010a59a:	c3                   	ret    
f010a59b:	90                   	nop    
f010a59c:	8d 74 26 00          	lea    0x0(%esi),%esi
f010a5a0:	39 fa                	cmp    %edi,%edx
f010a5a2:	0f 87 98 00 00 00    	ja     f010a640 <__udivdi3+0xe0>
f010a5a8:	0f bd c2             	bsr    %edx,%eax
f010a5ab:	83 f0 1f             	xor    $0x1f,%eax
f010a5ae:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
f010a5b1:	74 7f                	je     f010a632 <__udivdi3+0xd2>
f010a5b3:	b8 20 00 00 00       	mov    $0x20,%eax
f010a5b8:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
f010a5bb:	2b 45 e4             	sub    0xffffffe4(%ebp),%eax
f010a5be:	89 c1                	mov    %eax,%ecx
f010a5c0:	d3 ea                	shr    %cl,%edx
f010a5c2:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
f010a5c6:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
f010a5c9:	89 f0                	mov    %esi,%eax
f010a5cb:	d3 e0                	shl    %cl,%eax
f010a5cd:	09 c2                	or     %eax,%edx
f010a5cf:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f010a5d2:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
f010a5d5:	89 fa                	mov    %edi,%edx
f010a5d7:	d3 e0                	shl    %cl,%eax
f010a5d9:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
f010a5dd:	89 45 f4             	mov    %eax,0xfffffff4(%ebp)
f010a5e0:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f010a5e3:	d3 e8                	shr    %cl,%eax
f010a5e5:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
f010a5e9:	d3 e2                	shl    %cl,%edx
f010a5eb:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
f010a5ef:	09 d0                	or     %edx,%eax
f010a5f1:	d3 ef                	shr    %cl,%edi
f010a5f3:	89 fa                	mov    %edi,%edx
f010a5f5:	f7 75 e0             	divl   0xffffffe0(%ebp)
f010a5f8:	89 d1                	mov    %edx,%ecx
f010a5fa:	89 c7                	mov    %eax,%edi
f010a5fc:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f010a5ff:	f7 e7                	mul    %edi
f010a601:	39 d1                	cmp    %edx,%ecx
f010a603:	89 c6                	mov    %eax,%esi
f010a605:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
f010a608:	72 6f                	jb     f010a679 <__udivdi3+0x119>
f010a60a:	39 ca                	cmp    %ecx,%edx
f010a60c:	74 5e                	je     f010a66c <__udivdi3+0x10c>
f010a60e:	89 f9                	mov    %edi,%ecx
f010a610:	31 f6                	xor    %esi,%esi
f010a612:	e9 79 ff ff ff       	jmp    f010a590 <__udivdi3+0x30>
f010a617:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f010a61a:	85 c0                	test   %eax,%eax
f010a61c:	74 32                	je     f010a650 <__udivdi3+0xf0>
f010a61e:	89 f2                	mov    %esi,%edx
f010a620:	89 f8                	mov    %edi,%eax
f010a622:	f7 f1                	div    %ecx
f010a624:	89 c6                	mov    %eax,%esi
f010a626:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f010a629:	f7 f1                	div    %ecx
f010a62b:	89 c1                	mov    %eax,%ecx
f010a62d:	e9 5e ff ff ff       	jmp    f010a590 <__udivdi3+0x30>
f010a632:	39 d7                	cmp    %edx,%edi
f010a634:	77 2a                	ja     f010a660 <__udivdi3+0x100>
f010a636:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
f010a639:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
f010a63c:	73 22                	jae    f010a660 <__udivdi3+0x100>
f010a63e:	66 90                	xchg   %ax,%ax
f010a640:	31 c9                	xor    %ecx,%ecx
f010a642:	31 f6                	xor    %esi,%esi
f010a644:	e9 47 ff ff ff       	jmp    f010a590 <__udivdi3+0x30>
f010a649:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
f010a650:	b8 01 00 00 00       	mov    $0x1,%eax
f010a655:	31 d2                	xor    %edx,%edx
f010a657:	f7 75 f0             	divl   0xfffffff0(%ebp)
f010a65a:	89 c1                	mov    %eax,%ecx
f010a65c:	eb c0                	jmp    f010a61e <__udivdi3+0xbe>
f010a65e:	66 90                	xchg   %ax,%ax
f010a660:	b9 01 00 00 00       	mov    $0x1,%ecx
f010a665:	31 f6                	xor    %esi,%esi
f010a667:	e9 24 ff ff ff       	jmp    f010a590 <__udivdi3+0x30>
f010a66c:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f010a66f:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
f010a673:	d3 e0                	shl    %cl,%eax
f010a675:	39 c6                	cmp    %eax,%esi
f010a677:	76 95                	jbe    f010a60e <__udivdi3+0xae>
f010a679:	8d 4f ff             	lea    0xffffffff(%edi),%ecx
f010a67c:	31 f6                	xor    %esi,%esi
f010a67e:	e9 0d ff ff ff       	jmp    f010a590 <__udivdi3+0x30>
	...

f010a690 <__umoddi3>:
f010a690:	55                   	push   %ebp
f010a691:	89 e5                	mov    %esp,%ebp
f010a693:	57                   	push   %edi
f010a694:	56                   	push   %esi
f010a695:	83 ec 30             	sub    $0x30,%esp
f010a698:	8b 55 14             	mov    0x14(%ebp),%edx
f010a69b:	8b 45 10             	mov    0x10(%ebp),%eax
f010a69e:	8b 75 08             	mov    0x8(%ebp),%esi
f010a6a1:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010a6a4:	85 d2                	test   %edx,%edx
f010a6a6:	c7 45 d0 00 00 00 00 	movl   $0x0,0xffffffd0(%ebp)
f010a6ad:	89 c1                	mov    %eax,%ecx
f010a6af:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
f010a6b6:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
f010a6b9:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
f010a6bc:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
f010a6bf:	89 7d e0             	mov    %edi,0xffffffe0(%ebp)
f010a6c2:	75 1c                	jne    f010a6e0 <__umoddi3+0x50>
f010a6c4:	39 f8                	cmp    %edi,%eax
f010a6c6:	89 fa                	mov    %edi,%edx
f010a6c8:	0f 86 d4 00 00 00    	jbe    f010a7a2 <__umoddi3+0x112>
f010a6ce:	89 f0                	mov    %esi,%eax
f010a6d0:	f7 f1                	div    %ecx
f010a6d2:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
f010a6d5:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
f010a6dc:	eb 12                	jmp    f010a6f0 <__umoddi3+0x60>
f010a6de:	66 90                	xchg   %ax,%ax
f010a6e0:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
f010a6e3:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
f010a6e6:	76 18                	jbe    f010a700 <__umoddi3+0x70>
f010a6e8:	89 75 d0             	mov    %esi,0xffffffd0(%ebp)
f010a6eb:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
f010a6ee:	66 90                	xchg   %ax,%ax
f010a6f0:	8b 45 d0             	mov    0xffffffd0(%ebp),%eax
f010a6f3:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
f010a6f6:	83 c4 30             	add    $0x30,%esp
f010a6f9:	5e                   	pop    %esi
f010a6fa:	5f                   	pop    %edi
f010a6fb:	5d                   	pop    %ebp
f010a6fc:	c3                   	ret    
f010a6fd:	8d 76 00             	lea    0x0(%esi),%esi
f010a700:	0f bd 45 e8          	bsr    0xffffffe8(%ebp),%eax
f010a704:	83 f0 1f             	xor    $0x1f,%eax
f010a707:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
f010a70a:	0f 84 c0 00 00 00    	je     f010a7d0 <__umoddi3+0x140>
f010a710:	b8 20 00 00 00       	mov    $0x20,%eax
f010a715:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
f010a718:	2b 45 dc             	sub    0xffffffdc(%ebp),%eax
f010a71b:	8b 7d ec             	mov    0xffffffec(%ebp),%edi
f010a71e:	8b 75 f0             	mov    0xfffffff0(%ebp),%esi
f010a721:	89 c1                	mov    %eax,%ecx
f010a723:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
f010a726:	d3 ea                	shr    %cl,%edx
f010a728:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f010a72b:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
f010a72f:	d3 e0                	shl    %cl,%eax
f010a731:	09 c2                	or     %eax,%edx
f010a733:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f010a736:	d3 e7                	shl    %cl,%edi
f010a738:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
f010a73c:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
f010a73f:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
f010a742:	d3 e8                	shr    %cl,%eax
f010a744:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
f010a748:	d3 e2                	shl    %cl,%edx
f010a74a:	09 d0                	or     %edx,%eax
f010a74c:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
f010a74f:	d3 e6                	shl    %cl,%esi
f010a751:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
f010a755:	d3 ea                	shr    %cl,%edx
f010a757:	f7 75 f4             	divl   0xfffffff4(%ebp)
f010a75a:	89 55 cc             	mov    %edx,0xffffffcc(%ebp)
f010a75d:	f7 e7                	mul    %edi
f010a75f:	39 55 cc             	cmp    %edx,0xffffffcc(%ebp)
f010a762:	0f 82 a5 00 00 00    	jb     f010a80d <__umoddi3+0x17d>
f010a768:	3b 55 cc             	cmp    0xffffffcc(%ebp),%edx
f010a76b:	0f 84 94 00 00 00    	je     f010a805 <__umoddi3+0x175>
f010a771:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
f010a774:	29 c6                	sub    %eax,%esi
f010a776:	19 d1                	sbb    %edx,%ecx
f010a778:	89 4d cc             	mov    %ecx,0xffffffcc(%ebp)
f010a77b:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
f010a77f:	89 f2                	mov    %esi,%edx
f010a781:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
f010a784:	d3 ea                	shr    %cl,%edx
f010a786:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
f010a78a:	d3 e0                	shl    %cl,%eax
f010a78c:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
f010a790:	09 c2                	or     %eax,%edx
f010a792:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
f010a795:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
f010a798:	d3 e8                	shr    %cl,%eax
f010a79a:	89 45 d4             	mov    %eax,0xffffffd4(%ebp)
f010a79d:	e9 4e ff ff ff       	jmp    f010a6f0 <__umoddi3+0x60>
f010a7a2:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f010a7a5:	85 c0                	test   %eax,%eax
f010a7a7:	74 17                	je     f010a7c0 <__umoddi3+0x130>
f010a7a9:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
f010a7ac:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
f010a7af:	f7 f1                	div    %ecx
f010a7b1:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f010a7b4:	f7 f1                	div    %ecx
f010a7b6:	e9 17 ff ff ff       	jmp    f010a6d2 <__umoddi3+0x42>
f010a7bb:	90                   	nop    
f010a7bc:	8d 74 26 00          	lea    0x0(%esi),%esi
f010a7c0:	b8 01 00 00 00       	mov    $0x1,%eax
f010a7c5:	31 d2                	xor    %edx,%edx
f010a7c7:	f7 75 ec             	divl   0xffffffec(%ebp)
f010a7ca:	89 c1                	mov    %eax,%ecx
f010a7cc:	eb db                	jmp    f010a7a9 <__umoddi3+0x119>
f010a7ce:	66 90                	xchg   %ax,%ax
f010a7d0:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f010a7d3:	39 45 e0             	cmp    %eax,0xffffffe0(%ebp)
f010a7d6:	77 19                	ja     f010a7f1 <__umoddi3+0x161>
f010a7d8:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
f010a7db:	39 55 f0             	cmp    %edx,0xfffffff0(%ebp)
f010a7de:	73 11                	jae    f010a7f1 <__umoddi3+0x161>
f010a7e0:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
f010a7e3:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
f010a7e6:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
f010a7e9:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
f010a7ec:	e9 ff fe ff ff       	jmp    f010a6f0 <__umoddi3+0x60>
f010a7f1:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
f010a7f4:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f010a7f7:	2b 45 ec             	sub    0xffffffec(%ebp),%eax
f010a7fa:	1b 4d e8             	sbb    0xffffffe8(%ebp),%ecx
f010a7fd:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
f010a800:	89 4d e0             	mov    %ecx,0xffffffe0(%ebp)
f010a803:	eb db                	jmp    f010a7e0 <__umoddi3+0x150>
f010a805:	39 f0                	cmp    %esi,%eax
f010a807:	0f 86 64 ff ff ff    	jbe    f010a771 <__umoddi3+0xe1>
f010a80d:	29 f8                	sub    %edi,%eax
f010a80f:	1b 55 f4             	sbb    0xfffffff4(%ebp),%edx
f010a812:	e9 5a ff ff ff       	jmp    f010a771 <__umoddi3+0xe1>
