
obj/kern/kernel:     file format elf32-i386

Disassembly of section .text:

f0100000 <_start-0xc>:
.long MULTIBOOT_HEADER_FLAGS
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
f0100021:	8e d8                	mov    %eax,%ds
	movw	%ax,%es				# -> ES: Extra Segment
f0100023:	8e c0                	mov    %eax,%es
	movw	%ax,%ss				# -> SS: Stack Segment
f0100025:	8e d0                	mov    %eax,%ss
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
}

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
f0100049:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cprintf("kernel warning at %s:%d: ", file, line);
f010004c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010004f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100053:	8b 45 08             	mov    0x8(%ebp),%eax
f0100056:	89 44 24 04          	mov    %eax,0x4(%esp)
f010005a:	c7 04 24 40 a7 10 f0 	movl   $0xf010a740,(%esp)
f0100061:	e8 81 39 00 00       	call   f01039e7 <cprintf>
	vcprintf(fmt, ap);
f0100066:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0100069:	89 44 24 04          	mov    %eax,0x4(%esp)
f010006d:	8b 45 10             	mov    0x10(%ebp),%eax
f0100070:	89 04 24             	mov    %eax,(%esp)
f0100073:	e8 3c 39 00 00       	call   f01039b4 <vcprintf>
	cprintf("\n");
f0100078:	c7 04 24 29 ab 10 f0 	movl   $0xf010ab29,(%esp)
f010007f:	e8 63 39 00 00       	call   f01039e7 <cprintf>
	va_end(ap);
}
f0100084:	c9                   	leave  
f0100085:	c3                   	ret    

f0100086 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100086:	55                   	push   %ebp
f0100087:	89 e5                	mov    %esp,%ebp
f0100089:	53                   	push   %ebx
f010008a:	83 ec 24             	sub    $0x24,%esp
f010008d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	va_list ap;

	if (panicstr)
f0100090:	83 3d e0 42 29 f0 00 	cmpl   $0x0,0xf02942e0
f0100097:	75 43                	jne    f01000dc <_panic+0x56>
		goto dead;
	panicstr = fmt;
f0100099:	89 1d e0 42 29 f0    	mov    %ebx,0xf02942e0

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010009f:	fa                   	cli    
f01000a0:	fc                   	cld    

	va_start(ap, fmt);
f01000a1:	8d 45 14             	lea    0x14(%ebp),%eax
f01000a4:	89 45 f8             	mov    %eax,-0x8(%ebp)
	cprintf("kernel panic at %s:%d: ", file, line);
f01000a7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000aa:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01000b1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000b5:	c7 04 24 5a a7 10 f0 	movl   $0xf010a75a,(%esp)
f01000bc:	e8 26 39 00 00       	call   f01039e7 <cprintf>
	vcprintf(fmt, ap);
f01000c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01000c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000c8:	89 1c 24             	mov    %ebx,(%esp)
f01000cb:	e8 e4 38 00 00       	call   f01039b4 <vcprintf>
	cprintf("\n");
f01000d0:	c7 04 24 29 ab 10 f0 	movl   $0xf010ab29,(%esp)
f01000d7:	e8 0b 39 00 00       	call   f01039e7 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000e3:	e8 9f 08 00 00       	call   f0100987 <monitor>
f01000e8:	eb f2                	jmp    f01000dc <_panic+0x56>

f01000ea <i386_init>:
#include <kern/pci.h>


void
i386_init(void)
{
f01000ea:	55                   	push   %ebp
f01000eb:	89 e5                	mov    %esp,%ebp
f01000ed:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000f0:	b8 00 55 29 f0       	mov    $0xf0295500,%eax
f01000f5:	2d d6 42 29 f0       	sub    $0xf02942d6,%eax
f01000fa:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100105:	00 
f0100106:	c7 04 24 d6 42 29 f0 	movl   $0xf02942d6,(%esp)
f010010d:	e8 cc 95 00 00       	call   f01096de <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100112:	e8 63 03 00 00       	call   f010047a <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100117:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f010011e:	00 
f010011f:	c7 04 24 72 a7 10 f0 	movl   $0xf010a772,(%esp)
f0100126:	e8 bc 38 00 00       	call   f01039e7 <cprintf>

	// Lab 2 memory management initialization functions
	i386_detect_memory();
f010012b:	e8 74 16 00 00       	call   f01017a4 <i386_detect_memory>
	i386_vm_init();
f0100130:	e8 62 1d 00 00       	call   f0101e97 <i386_vm_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100135:	e8 86 30 00 00       	call   f01031c0 <env_init>
	idt_init();
f010013a:	e8 e1 38 00 00       	call   f0103a20 <idt_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010013f:	90                   	nop    
f0100140:	e8 e3 37 00 00       	call   f0103928 <pic_init>
	kclock_init();
f0100145:	e8 17 37 00 00       	call   f0103861 <kclock_init>

	time_init();
f010014a:	e8 75 9f 00 00       	call   f010a0c4 <time_init>
	pci_init();
f010014f:	90                   	nop    
f0100150:	e8 60 9e 00 00       	call   f0109fb5 <pci_init>

	// Should always have an idle process as first one.
	ENV_CREATE(user_idle);
f0100155:	c7 44 24 04 8b 1f 01 	movl   $0x11f8b,0x4(%esp)
f010015c:	00 
f010015d:	c7 04 24 94 17 13 f0 	movl   $0xf0131794,(%esp)
f0100164:	e8 dc 32 00 00       	call   f0103445 <env_create>

	// Start fs.
	ENV_CREATE(fs_fs);
f0100169:	c7 44 24 04 45 c6 01 	movl   $0x1c645,0x4(%esp)
f0100170:	00 
f0100171:	c7 04 24 f8 f8 1f f0 	movl   $0xf01ff8f8,(%esp)
f0100178:	e8 c8 32 00 00       	call   f0103445 <env_create>

#if !defined(TEST_NO_NS)
	//Start ns.
	ENV_CREATE(net_ns);
f010017d:	c7 44 24 04 2a d0 04 	movl   $0x4d02a,0x4(%esp)
f0100184:	00 
f0100185:	c7 04 24 ac 72 24 f0 	movl   $0xf02472ac,(%esp)
f010018c:	e8 b4 32 00 00       	call   f0103445 <env_create>
	// ENV_CREATE(user_testfile);
	// ENV_CREATE(user_icode);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f0100191:	e8 ba 49 00 00       	call   f0104b50 <sched_yield>
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
f01001bd:	8b 15 24 45 29 f0    	mov    0xf0294524,%edx
f01001c3:	88 82 20 43 29 f0    	mov    %al,-0xfd6bce0(%edx)
f01001c9:	83 c2 01             	add    $0x1,%edx
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
f01001cc:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001d2:	0f 94 c0             	sete   %al
f01001d5:	0f b6 c0             	movzbl %al,%eax
f01001d8:	83 e8 01             	sub    $0x1,%eax
f01001db:	21 c2                	and    %eax,%edx
f01001dd:	89 15 24 45 29 f0    	mov    %edx,0xf0294524
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001e3:	ff d3                	call   *%ebx
f01001e5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001e8:	75 cf                	jne    f01001b9 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001ea:	83 c4 04             	add    $0x4,%esp
f01001ed:	5b                   	pop    %ebx
f01001ee:	5d                   	pop    %ebp
f01001ef:	c3                   	ret    

f01001f0 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01001f0:	55                   	push   %ebp
f01001f1:	89 e5                	mov    %esp,%ebp
f01001f3:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01001f6:	b8 aa 05 10 f0       	mov    $0xf01005aa,%eax
f01001fb:	e8 ae ff ff ff       	call   f01001ae <cons_intr>
}
f0100200:	c9                   	leave  
f0100201:	c3                   	ret    

f0100202 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100202:	55                   	push   %ebp
f0100203:	89 e5                	mov    %esp,%ebp
f0100205:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100208:	83 3d 04 43 29 f0 00 	cmpl   $0x0,0xf0294304
f010020f:	74 0a                	je     f010021b <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100211:	b8 8b 05 10 f0       	mov    $0xf010058b,%eax
f0100216:	e8 93 ff ff ff       	call   f01001ae <cons_intr>
}
f010021b:	c9                   	leave  
f010021c:	c3                   	ret    

f010021d <cons_getc>:
}

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
f010022d:	a1 20 45 29 f0       	mov    0xf0294520,%eax
f0100232:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100237:	3b 05 24 45 29 f0    	cmp    0xf0294524,%eax
f010023d:	74 21                	je     f0100260 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f010023f:	0f b6 88 20 43 29 f0 	movzbl -0xfd6bce0(%eax),%ecx
f0100246:	8d 50 01             	lea    0x1(%eax),%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f0100249:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010024f:	0f 94 c0             	sete   %al
f0100252:	0f b6 c0             	movzbl %al,%eax
f0100255:	83 e8 01             	sub    $0x1,%eax
f0100258:	21 c2                	and    %eax,%edx
f010025a:	89 15 20 45 29 f0    	mov    %edx,0xf0294520
		return c;
	}
	return 0;
}
f0100260:	89 c8                	mov    %ecx,%eax
f0100262:	c9                   	leave  
f0100263:	c3                   	ret    

f0100264 <getchar>:
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
}

// output a character to the console
static void
cons_putc(int c)
{
f010027f:	55                   	push   %ebp
f0100280:	89 e5                	mov    %esp,%ebp
f0100282:	57                   	push   %edi
f0100283:	56                   	push   %esi
f0100284:	53                   	push   %ebx
f0100285:	83 ec 0c             	sub    $0xc,%esp
f0100288:	89 c7                	mov    %eax,%edi
f010028a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010028f:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;
	
	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100290:	a8 20                	test   $0x20,%al
f0100292:	75 1f                	jne    f01002b3 <cons_putc+0x34>
f0100294:	bb 00 00 00 00       	mov    $0x0,%ebx
	     i++)
		delay();
f0100299:	e8 02 ff ff ff       	call   f01001a0 <delay>
f010029e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002a3:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;
	
	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002a4:	a8 20                	test   $0x20,%al
f01002a6:	75 0b                	jne    f01002b3 <cons_putc+0x34>
	     i++)
f01002a8:	83 c3 01             	add    $0x1,%ebx
serial_putc(int c)
{
	int i;
	
	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002ab:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01002b1:	75 e6                	jne    f0100299 <cons_putc+0x1a>
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
f01002b3:	89 fe                	mov    %edi,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002b5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002ba:	89 f8                	mov    %edi,%eax
f01002bc:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002bd:	b2 79                	mov    $0x79,%dl
f01002bf:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002c0:	84 c0                	test   %al,%al
f01002c2:	78 1f                	js     f01002e3 <cons_putc+0x64>
f01002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
		delay();
f01002c9:	e8 d2 fe ff ff       	call   f01001a0 <delay>
f01002ce:	ba 79 03 00 00       	mov    $0x379,%edx
f01002d3:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002d4:	84 c0                	test   %al,%al
f01002d6:	78 0b                	js     f01002e3 <cons_putc+0x64>
f01002d8:	83 c3 01             	add    $0x1,%ebx
f01002db:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01002e1:	75 e6                	jne    f01002c9 <cons_putc+0x4a>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002e3:	ba 78 03 00 00       	mov    $0x378,%edx
f01002e8:	89 f0                	mov    %esi,%eax
f01002ea:	ee                   	out    %al,(%dx)
f01002eb:	b8 0d 00 00 00       	mov    $0xd,%eax
f01002f0:	b2 7a                	mov    $0x7a,%dl
f01002f2:	ee                   	out    %al,(%dx)
f01002f3:	b8 08 00 00 00       	mov    $0x8,%eax
f01002f8:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01002f9:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f01002ff:	75 06                	jne    f0100307 <cons_putc+0x88>
		c |= 0x0700;
f0100301:	81 cf 00 07 00 00    	or     $0x700,%edi

	switch (c & 0xff) {
f0100307:	89 f8                	mov    %edi,%eax
f0100309:	25 ff 00 00 00       	and    $0xff,%eax
f010030e:	83 f8 09             	cmp    $0x9,%eax
f0100311:	74 7e                	je     f0100391 <cons_putc+0x112>
f0100313:	83 f8 09             	cmp    $0x9,%eax
f0100316:	7f 0b                	jg     f0100323 <cons_putc+0xa4>
f0100318:	83 f8 08             	cmp    $0x8,%eax
f010031b:	0f 85 a4 00 00 00    	jne    f01003c5 <cons_putc+0x146>
f0100321:	eb 15                	jmp    f0100338 <cons_putc+0xb9>
f0100323:	83 f8 0a             	cmp    $0xa,%eax
f0100326:	74 3f                	je     f0100367 <cons_putc+0xe8>
f0100328:	83 f8 0d             	cmp    $0xd,%eax
f010032b:	90                   	nop    
f010032c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0100330:	0f 85 8f 00 00 00    	jne    f01003c5 <cons_putc+0x146>
f0100336:	eb 37                	jmp    f010036f <cons_putc+0xf0>
	case '\b':
		if (crt_pos > 0) {
f0100338:	0f b7 05 10 43 29 f0 	movzwl 0xf0294310,%eax
f010033f:	66 85 c0             	test   %ax,%ax
f0100342:	0f 84 ea 00 00 00    	je     f0100432 <cons_putc+0x1b3>
			crt_pos--;
f0100348:	83 e8 01             	sub    $0x1,%eax
f010034b:	66 a3 10 43 29 f0    	mov    %ax,0xf0294310
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100351:	0f b7 c0             	movzwl %ax,%eax
f0100354:	89 fa                	mov    %edi,%edx
f0100356:	b2 00                	mov    $0x0,%dl
f0100358:	83 ca 20             	or     $0x20,%edx
f010035b:	8b 0d 0c 43 29 f0    	mov    0xf029430c,%ecx
f0100361:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f0100365:	eb 7b                	jmp    f01003e2 <cons_putc+0x163>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100367:	66 83 05 10 43 29 f0 	addw   $0x50,0xf0294310
f010036e:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010036f:	0f b7 05 10 43 29 f0 	movzwl 0xf0294310,%eax
f0100376:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010037c:	c1 e8 10             	shr    $0x10,%eax
f010037f:	66 c1 e8 06          	shr    $0x6,%ax
f0100383:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100386:	c1 e0 04             	shl    $0x4,%eax
f0100389:	66 a3 10 43 29 f0    	mov    %ax,0xf0294310
f010038f:	eb 51                	jmp    f01003e2 <cons_putc+0x163>
		break;
	case '\t':
		cons_putc(' ');
f0100391:	b8 20 00 00 00       	mov    $0x20,%eax
f0100396:	e8 e4 fe ff ff       	call   f010027f <cons_putc>
		cons_putc(' ');
f010039b:	b8 20 00 00 00       	mov    $0x20,%eax
f01003a0:	e8 da fe ff ff       	call   f010027f <cons_putc>
		cons_putc(' ');
f01003a5:	b8 20 00 00 00       	mov    $0x20,%eax
f01003aa:	e8 d0 fe ff ff       	call   f010027f <cons_putc>
		cons_putc(' ');
f01003af:	b8 20 00 00 00       	mov    $0x20,%eax
f01003b4:	e8 c6 fe ff ff       	call   f010027f <cons_putc>
		cons_putc(' ');
f01003b9:	b8 20 00 00 00       	mov    $0x20,%eax
f01003be:	e8 bc fe ff ff       	call   f010027f <cons_putc>
f01003c3:	eb 1d                	jmp    f01003e2 <cons_putc+0x163>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003c5:	0f b7 05 10 43 29 f0 	movzwl 0xf0294310,%eax
f01003cc:	0f b7 c8             	movzwl %ax,%ecx
f01003cf:	8b 15 0c 43 29 f0    	mov    0xf029430c,%edx
f01003d5:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f01003d9:	83 c0 01             	add    $0x1,%eax
f01003dc:	66 a3 10 43 29 f0    	mov    %ax,0xf0294310
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01003e2:	66 81 3d 10 43 29 f0 	cmpw   $0x7cf,0xf0294310
f01003e9:	cf 07 
f01003eb:	76 45                	jbe    f0100432 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01003ed:	8b 15 0c 43 29 f0    	mov    0xf029430c,%edx
f01003f3:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01003fa:	00 
f01003fb:	8d 82 a0 00 00 00    	lea    0xa0(%edx),%eax
f0100401:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100405:	89 14 24             	mov    %edx,(%esp)
f0100408:	e8 2b 93 00 00       	call   f0109738 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010040d:	8b 15 0c 43 29 f0    	mov    0xf029430c,%edx
f0100413:	b8 00 00 00 00       	mov    $0x0,%eax
f0100418:	66 c7 84 42 00 0f 00 	movw   $0x720,0xf00(%edx,%eax,2)
f010041f:	00 20 07 
f0100422:	83 c0 01             	add    $0x1,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100425:	83 f8 50             	cmp    $0x50,%eax
f0100428:	75 ee                	jne    f0100418 <cons_putc+0x199>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010042a:	66 83 2d 10 43 29 f0 	subw   $0x50,0xf0294310
f0100431:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100432:	8b 35 08 43 29 f0    	mov    0xf0294308,%esi
f0100438:	89 f3                	mov    %esi,%ebx
f010043a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010043f:	89 f2                	mov    %esi,%edx
f0100441:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100442:	0f b7 0d 10 43 29 f0 	movzwl 0xf0294310,%ecx
f0100449:	83 c6 01             	add    $0x1,%esi
f010044c:	89 c8                	mov    %ecx,%eax
f010044e:	66 c1 e8 08          	shr    $0x8,%ax
f0100452:	89 f2                	mov    %esi,%edx
f0100454:	ee                   	out    %al,(%dx)
f0100455:	b8 0f 00 00 00       	mov    $0xf,%eax
f010045a:	89 da                	mov    %ebx,%edx
f010045c:	ee                   	out    %al,(%dx)
f010045d:	89 c8                	mov    %ecx,%eax
f010045f:	89 f2                	mov    %esi,%edx
f0100461:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100462:	83 c4 0c             	add    $0xc,%esp
f0100465:	5b                   	pop    %ebx
f0100466:	5e                   	pop    %esi
f0100467:	5f                   	pop    %edi
f0100468:	5d                   	pop    %ebp
f0100469:	c3                   	ret    

f010046a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010046a:	55                   	push   %ebp
f010046b:	89 e5                	mov    %esp,%ebp
f010046d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100470:	8b 45 08             	mov    0x8(%ebp),%eax
f0100473:	e8 07 fe ff ff       	call   f010027f <cons_putc>
}
f0100478:	c9                   	leave  
f0100479:	c3                   	ret    

f010047a <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010047a:	55                   	push   %ebp
f010047b:	89 e5                	mov    %esp,%ebp
f010047d:	57                   	push   %edi
f010047e:	56                   	push   %esi
f010047f:	53                   	push   %ebx
f0100480:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100483:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010048a:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100491:	5a a5 
	if (*cp != 0xA55A) {
f0100493:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010049a:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010049e:	74 11                	je     f01004b1 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01004a0:	c7 05 08 43 29 f0 b4 	movl   $0x3b4,0xf0294308
f01004a7:	03 00 00 
f01004aa:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01004af:	eb 16                	jmp    f01004c7 <cons_init+0x4d>
	} else {
		*cp = was;
f01004b1:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01004b8:	c7 05 08 43 29 f0 d4 	movl   $0x3d4,0xf0294308
f01004bf:	03 00 00 
f01004c2:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f01004c7:	8b 1d 08 43 29 f0    	mov    0xf0294308,%ebx
f01004cd:	89 d9                	mov    %ebx,%ecx
f01004cf:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004d4:	89 da                	mov    %ebx,%edx
f01004d6:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01004d7:	8d 7b 01             	lea    0x1(%ebx),%edi

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004da:	89 fa                	mov    %edi,%edx
f01004dc:	ec                   	in     (%dx),%al
f01004dd:	0f b6 c0             	movzbl %al,%eax
f01004e0:	89 c3                	mov    %eax,%ebx
f01004e2:	c1 e3 08             	shl    $0x8,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004e5:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004ea:	89 ca                	mov    %ecx,%edx
f01004ec:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004ed:	89 fa                	mov    %edi,%edx
f01004ef:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01004f0:	89 35 0c 43 29 f0    	mov    %esi,0xf029430c
	crt_pos = pos;
f01004f6:	0f b6 c0             	movzbl %al,%eax
f01004f9:	09 d8                	or     %ebx,%eax
f01004fb:	66 a3 10 43 29 f0    	mov    %ax,0xf0294310

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f0100501:	e8 ea fc ff ff       	call   f01001f0 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100506:	0f b7 05 58 13 13 f0 	movzwl 0xf0131358,%eax
f010050d:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100512:	89 04 24             	mov    %eax,(%esp)
f0100515:	e8 96 33 00 00       	call   f01038b0 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010051a:	b8 00 00 00 00       	mov    $0x0,%eax
f010051f:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100524:	89 da                	mov    %ebx,%edx
f0100526:	ee                   	out    %al,(%dx)
f0100527:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010052c:	b2 fb                	mov    $0xfb,%dl
f010052e:	ee                   	out    %al,(%dx)
f010052f:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100534:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100539:	89 ca                	mov    %ecx,%edx
f010053b:	ee                   	out    %al,(%dx)
f010053c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100541:	b2 f9                	mov    $0xf9,%dl
f0100543:	ee                   	out    %al,(%dx)
f0100544:	b8 03 00 00 00       	mov    $0x3,%eax
f0100549:	b2 fb                	mov    $0xfb,%dl
f010054b:	ee                   	out    %al,(%dx)
f010054c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100551:	b2 fc                	mov    $0xfc,%dl
f0100553:	ee                   	out    %al,(%dx)
f0100554:	b8 01 00 00 00       	mov    $0x1,%eax
f0100559:	b2 f9                	mov    $0xf9,%dl
f010055b:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010055c:	b2 fd                	mov    $0xfd,%dl
f010055e:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010055f:	3c ff                	cmp    $0xff,%al
f0100561:	0f 95 c0             	setne  %al
f0100564:	0f b6 f0             	movzbl %al,%esi
f0100567:	89 35 04 43 29 f0    	mov    %esi,0xf0294304
f010056d:	89 da                	mov    %ebx,%edx
f010056f:	ec                   	in     (%dx),%al
f0100570:	89 ca                	mov    %ecx,%edx
f0100572:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100573:	85 f6                	test   %esi,%esi
f0100575:	75 0c                	jne    f0100583 <cons_init+0x109>
		cprintf("Serial port does not exist!\n");
f0100577:	c7 04 24 8d a7 10 f0 	movl   $0xf010a78d,(%esp)
f010057e:	e8 64 34 00 00       	call   f01039e7 <cprintf>
}
f0100583:	83 c4 0c             	add    $0xc,%esp
f0100586:	5b                   	pop    %ebx
f0100587:	5e                   	pop    %esi
f0100588:	5f                   	pop    %edi
f0100589:	5d                   	pop    %ebp
f010058a:	c3                   	ret    

f010058b <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010058b:	55                   	push   %ebp
f010058c:	89 e5                	mov    %esp,%ebp
f010058e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100593:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100594:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100599:	a8 01                	test   $0x1,%al
f010059b:	74 09                	je     f01005a6 <serial_proc_data+0x1b>
f010059d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01005a2:	ec                   	in     (%dx),%al
	return data;
f01005a3:	0f b6 d0             	movzbl %al,%edx
		return -1;
	return inb(COM1+COM_RX);
}
f01005a6:	89 d0                	mov    %edx,%eax
f01005a8:	5d                   	pop    %ebp
f01005a9:	c3                   	ret    

f01005aa <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01005aa:	55                   	push   %ebp
f01005ab:	89 e5                	mov    %esp,%ebp
f01005ad:	53                   	push   %ebx
f01005ae:	83 ec 04             	sub    $0x4,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b1:	ba 64 00 00 00       	mov    $0x64,%edx
f01005b6:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01005b7:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01005bc:	a8 01                	test   $0x1,%al
f01005be:	0f 84 d9 00 00 00    	je     f010069d <kbd_proc_data+0xf3>
f01005c4:	ba 60 00 00 00       	mov    $0x60,%edx
f01005c9:	ec                   	in     (%dx),%al
f01005ca:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01005cc:	3c e0                	cmp    $0xe0,%al
f01005ce:	75 11                	jne    f01005e1 <kbd_proc_data+0x37>
		// E0 escape character
		shift |= E0ESC;
f01005d0:	83 0d 00 43 29 f0 40 	orl    $0x40,0xf0294300
f01005d7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01005dc:	e9 bc 00 00 00       	jmp    f010069d <kbd_proc_data+0xf3>
		return 0;
	} else if (data & 0x80) {
f01005e1:	84 c0                	test   %al,%al
f01005e3:	79 31                	jns    f0100616 <kbd_proc_data+0x6c>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01005e5:	8b 0d 00 43 29 f0    	mov    0xf0294300,%ecx
f01005eb:	f6 c1 40             	test   $0x40,%cl
f01005ee:	75 03                	jne    f01005f3 <kbd_proc_data+0x49>
f01005f0:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01005f3:	0f b6 c2             	movzbl %dl,%eax
f01005f6:	0f b6 80 c0 a7 10 f0 	movzbl -0xfef5840(%eax),%eax
f01005fd:	83 c8 40             	or     $0x40,%eax
f0100600:	0f b6 c0             	movzbl %al,%eax
f0100603:	f7 d0                	not    %eax
f0100605:	21 c8                	and    %ecx,%eax
f0100607:	a3 00 43 29 f0       	mov    %eax,0xf0294300
f010060c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100611:	e9 87 00 00 00       	jmp    f010069d <kbd_proc_data+0xf3>
		return 0;
	} else if (shift & E0ESC) {
f0100616:	a1 00 43 29 f0       	mov    0xf0294300,%eax
f010061b:	a8 40                	test   $0x40,%al
f010061d:	74 0b                	je     f010062a <kbd_proc_data+0x80>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010061f:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f0100622:	83 e0 bf             	and    $0xffffffbf,%eax
f0100625:	a3 00 43 29 f0       	mov    %eax,0xf0294300
	}

	shift |= shiftcode[data];
f010062a:	0f b6 ca             	movzbl %dl,%ecx
	shift ^= togglecode[data];
f010062d:	0f b6 81 c0 a7 10 f0 	movzbl -0xfef5840(%ecx),%eax
f0100634:	0b 05 00 43 29 f0    	or     0xf0294300,%eax
f010063a:	0f b6 91 c0 a8 10 f0 	movzbl -0xfef5740(%ecx),%edx
f0100641:	31 c2                	xor    %eax,%edx
f0100643:	89 15 00 43 29 f0    	mov    %edx,0xf0294300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100649:	89 d0                	mov    %edx,%eax
f010064b:	83 e0 03             	and    $0x3,%eax
f010064e:	8b 04 85 c0 a9 10 f0 	mov    -0xfef5640(,%eax,4),%eax
f0100655:	0f b6 1c 08          	movzbl (%eax,%ecx,1),%ebx
	if (shift & CAPSLOCK) {
f0100659:	f6 c2 08             	test   $0x8,%dl
f010065c:	74 18                	je     f0100676 <kbd_proc_data+0xcc>
		if ('a' <= c && c <= 'z')
f010065e:	8d 43 9f             	lea    -0x61(%ebx),%eax
f0100661:	83 f8 19             	cmp    $0x19,%eax
f0100664:	77 05                	ja     f010066b <kbd_proc_data+0xc1>
			c += 'A' - 'a';
f0100666:	83 eb 20             	sub    $0x20,%ebx
f0100669:	eb 0b                	jmp    f0100676 <kbd_proc_data+0xcc>
		else if ('A' <= c && c <= 'Z')
f010066b:	8d 43 bf             	lea    -0x41(%ebx),%eax
f010066e:	83 f8 19             	cmp    $0x19,%eax
f0100671:	77 03                	ja     f0100676 <kbd_proc_data+0xcc>
			c += 'a' - 'A';
f0100673:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100676:	89 d0                	mov    %edx,%eax
f0100678:	f7 d0                	not    %eax
f010067a:	a8 06                	test   $0x6,%al
f010067c:	75 1f                	jne    f010069d <kbd_proc_data+0xf3>
f010067e:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100684:	75 17                	jne    f010069d <kbd_proc_data+0xf3>
		cprintf("Rebooting!\n");
f0100686:	c7 04 24 aa a7 10 f0 	movl   $0xf010a7aa,(%esp)
f010068d:	e8 55 33 00 00       	call   f01039e7 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100692:	b8 03 00 00 00       	mov    $0x3,%eax
f0100697:	ba 92 00 00 00       	mov    $0x92,%edx
f010069c:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010069d:	89 d8                	mov    %ebx,%eax
f010069f:	83 c4 04             	add    $0x4,%esp
f01006a2:	5b                   	pop    %ebx
f01006a3:	5d                   	pop    %ebp
f01006a4:	c3                   	ret    
	...

f01006b0 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f01006b0:	55                   	push   %ebp
f01006b1:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f01006b3:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f01006b6:	5d                   	pop    %ebp
f01006b7:	c3                   	ret    

f01006b8 <getva>:
        }while(ebp!=0);
	return 0;
}
uint32_t
getva(char *vastring,int base)
{
f01006b8:	55                   	push   %ebp
f01006b9:	89 e5                	mov    %esp,%ebp
f01006bb:	57                   	push   %edi
f01006bc:	56                   	push   %esi
f01006bd:	53                   	push   %ebx
f01006be:	83 ec 0c             	sub    $0xc,%esp
f01006c1:	8b 7d 08             	mov    0x8(%ebp),%edi
f01006c4:	8b 45 0c             	mov    0xc(%ebp),%eax
	uint32_t va=0;
	int i,length=0;
	if(vastring){
f01006c7:	85 ff                	test   %edi,%edi
f01006c9:	0f 84 20 01 00 00    	je     f01007ef <getva+0x137>
		for(length=0;vastring[length]!='\0';length++);
f01006cf:	0f b6 17             	movzbl (%edi),%edx
f01006d2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006d7:	84 d2                	test   %dl,%dl
f01006d9:	74 0e                	je     f01006e9 <getva+0x31>
f01006db:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006e0:	83 c3 01             	add    $0x1,%ebx
f01006e3:	80 3c 3b 00          	cmpb   $0x0,(%ebx,%edi,1)
f01006e7:	75 f7                	jne    f01006e0 <getva+0x28>
		//cprintf("vastring[0]=%c vastring[1]=%c length=%d\n",vastring[0],vastring[1],length);
		if(base==16){
f01006e9:	83 f8 10             	cmp    $0x10,%eax
f01006ec:	0f 85 99 00 00 00    	jne    f010078b <getva+0xd3>
			if(vastring[0]!='0'||vastring[1]!='x'||(length>10)){
f01006f2:	80 fa 30             	cmp    $0x30,%dl
f01006f5:	75 26                	jne    f010071d <getva+0x65>
f01006f7:	80 7f 01 78          	cmpb   $0x78,0x1(%edi)
f01006fb:	90                   	nop    
f01006fc:	8d 74 26 00          	lea    0x0(%esi),%esi
f0100700:	75 1b                	jne    f010071d <getva+0x65>
f0100702:	83 fb 0a             	cmp    $0xa,%ebx
f0100705:	7f 16                	jg     f010071d <getva+0x65>
				cprintf("Virtual Address is not hex!\n");
				return 0;
f0100707:	be 00 00 00 00       	mov    $0x0,%esi
f010070c:	c7 45 f0 02 00 00 00 	movl   $0x2,-0x10(%ebp)
			}
		
			for(i=2;i<length;i++){
f0100713:	83 fb 02             	cmp    $0x2,%ebx
f0100716:	7f 1b                	jg     f0100733 <getva+0x7b>
f0100718:	e9 e5 00 00 00       	jmp    f0100802 <getva+0x14a>
	if(vastring){
		for(length=0;vastring[length]!='\0';length++);
		//cprintf("vastring[0]=%c vastring[1]=%c length=%d\n",vastring[0],vastring[1],length);
		if(base==16){
			if(vastring[0]!='0'||vastring[1]!='x'||(length>10)){
				cprintf("Virtual Address is not hex!\n");
f010071d:	c7 04 24 d0 a9 10 f0 	movl   $0xf010a9d0,(%esp)
f0100724:	e8 be 32 00 00       	call   f01039e7 <cprintf>
f0100729:	be 00 00 00 00       	mov    $0x0,%esi
f010072e:	e9 d4 00 00 00       	jmp    f0100807 <getva+0x14f>
				return 0;
			}
		
			for(i=2;i<length;i++){
				if(vastring[i]>='0'&&vastring[i]<='9')
f0100733:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100736:	0f b6 14 38          	movzbl (%eax,%edi,1),%edx
f010073a:	89 d1                	mov    %edx,%ecx
f010073c:	8d 42 d0             	lea    -0x30(%edx),%eax
f010073f:	3c 09                	cmp    $0x9,%al
f0100741:	77 0e                	ja     f0100751 <getva+0x99>
					va=vastring[i]-'0'+va*base;
f0100743:	0f be d2             	movsbl %dl,%edx
f0100746:	89 f0                	mov    %esi,%eax
f0100748:	c1 e0 04             	shl    $0x4,%eax
f010074b:	8d 74 02 d0          	lea    -0x30(%edx,%eax,1),%esi
f010074f:	eb 2b                	jmp    f010077c <getva+0xc4>
				else if(vastring[i]>='a'&&vastring[i]<='f')
f0100751:	8d 41 9f             	lea    -0x61(%ecx),%eax
f0100754:	3c 05                	cmp    $0x5,%al
f0100756:	77 0e                	ja     f0100766 <getva+0xae>
					va=vastring[i]-'a'+10+va*base;
f0100758:	0f be d2             	movsbl %dl,%edx
f010075b:	89 f0                	mov    %esi,%eax
f010075d:	c1 e0 04             	shl    $0x4,%eax
f0100760:	8d 74 02 a9          	lea    -0x57(%edx,%eax,1),%esi
f0100764:	eb 16                	jmp    f010077c <getva+0xc4>
				else{
					cprintf("Virtual Address is bad!\n");
f0100766:	c7 04 24 ed a9 10 f0 	movl   $0xf010a9ed,(%esp)
f010076d:	e8 75 32 00 00       	call   f01039e7 <cprintf>
f0100772:	be 00 00 00 00       	mov    $0x0,%esi
f0100777:	e9 8b 00 00 00       	jmp    f0100807 <getva+0x14f>
			if(vastring[0]!='0'||vastring[1]!='x'||(length>10)){
				cprintf("Virtual Address is not hex!\n");
				return 0;
			}
		
			for(i=2;i<length;i++){
f010077c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f0100780:	39 5d f0             	cmp    %ebx,-0x10(%ebp)
f0100783:	0f 84 7e 00 00 00    	je     f0100807 <getva+0x14f>
f0100789:	eb a8                	jmp    f0100733 <getva+0x7b>
					va=0;
					break;
				}
			}
		}
		else if(base==10){
f010078b:	83 f8 0a             	cmp    $0xa,%eax
f010078e:	66 90                	xchg   %ax,%ax
f0100790:	75 4a                	jne    f01007dc <getva+0x124>
			 for(i=0;i<length;i++){
f0100792:	85 db                	test   %ebx,%ebx
f0100794:	7f 33                	jg     f01007c9 <getva+0x111>
f0100796:	eb 6a                	jmp    f0100802 <getva+0x14a>
                                if(vastring[i]>='0'&&vastring[i]<='9')
f0100798:	0f b6 14 39          	movzbl (%ecx,%edi,1),%edx
f010079c:	8d 42 d0             	lea    -0x30(%edx),%eax
f010079f:	3c 09                	cmp    $0x9,%al
f01007a1:	77 13                	ja     f01007b6 <getva+0xfe>
                                        va=vastring[i]-'0'+va*base;
f01007a3:	0f be d2             	movsbl %dl,%edx
f01007a6:	8d 04 b6             	lea    (%esi,%esi,4),%eax
f01007a9:	8d 74 42 d0          	lea    -0x30(%edx,%eax,2),%esi
					break;
				}
			}
		}
		else if(base==10){
			 for(i=0;i<length;i++){
f01007ad:	83 c1 01             	add    $0x1,%ecx
f01007b0:	39 d9                	cmp    %ebx,%ecx
f01007b2:	75 e4                	jne    f0100798 <getva+0xe0>
f01007b4:	eb 51                	jmp    f0100807 <getva+0x14f>
                                if(vastring[i]>='0'&&vastring[i]<='9')
                                        va=vastring[i]-'0'+va*base;
                                else{
                                        cprintf("The number string is bad!\n");
f01007b6:	c7 04 24 06 aa 10 f0 	movl   $0xf010aa06,(%esp)
f01007bd:	e8 25 32 00 00       	call   f01039e7 <cprintf>
f01007c2:	be 00 00 00 00       	mov    $0x0,%esi
f01007c7:	eb 3e                	jmp    f0100807 <getva+0x14f>
				}
			}
		}
		else if(base==10){
			 for(i=0;i<length;i++){
                                if(vastring[i]>='0'&&vastring[i]<='9')
f01007c9:	8d 42 d0             	lea    -0x30(%edx),%eax
f01007cc:	be 00 00 00 00       	mov    $0x0,%esi
f01007d1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01007d6:	3c 09                	cmp    $0x9,%al
f01007d8:	76 c9                	jbe    f01007a3 <getva+0xeb>
f01007da:	eb da                	jmp    f01007b6 <getva+0xfe>
                                        va=0;
                                        break;
                                }
			}
		}
		else cprintf("Can not handdle\n");	
f01007dc:	c7 04 24 21 aa 10 f0 	movl   $0xf010aa21,(%esp)
f01007e3:	e8 ff 31 00 00       	call   f01039e7 <cprintf>
f01007e8:	be 00 00 00 00       	mov    $0x0,%esi
f01007ed:	eb 18                	jmp    f0100807 <getva+0x14f>
	}
	else{
		cprintf("Virtual Address is NULL!\n");
f01007ef:	c7 04 24 32 aa 10 f0 	movl   $0xf010aa32,(%esp)
f01007f6:	e8 ec 31 00 00       	call   f01039e7 <cprintf>
f01007fb:	be 00 00 00 00       	mov    $0x0,%esi
f0100800:	eb 05                	jmp    f0100807 <getva+0x14f>
f0100802:	be 00 00 00 00       	mov    $0x0,%esi
	}
	return va;
}
f0100807:	89 f0                	mov    %esi,%eax
f0100809:	83 c4 0c             	add    $0xc,%esp
f010080c:	5b                   	pop    %ebx
f010080d:	5e                   	pop    %esi
f010080e:	5f                   	pop    %edi
f010080f:	5d                   	pop    %ebp
f0100810:	c3                   	ret    

f0100811 <mon_dumpx>:
	return 0;
}

int
mon_dumpx(int argc, char **argv, struct Trapframe *tf)
{
f0100811:	55                   	push   %ebp
f0100812:	89 e5                	mov    %esp,%ebp
f0100814:	57                   	push   %edi
f0100815:	56                   	push   %esi
f0100816:	53                   	push   %ebx
f0100817:	83 ec 0c             	sub    $0xc,%esp
f010081a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	uint32_t a,*content;
	int i,n;
	if(argc<3)
f010081d:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100821:	7f 0e                	jg     f0100831 <mon_dumpx+0x20>
        {
                cprintf("Command argument is illegle!\n");
f0100823:	c7 04 24 4c aa 10 f0 	movl   $0xf010aa4c,(%esp)
f010082a:	e8 b8 31 00 00       	call   f01039e7 <cprintf>
f010082f:	eb 59                	jmp    f010088a <mon_dumpx+0x79>
                return 0;
        }
	n=(int)getva(argv[1],10);
f0100831:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
f0100838:	00 
f0100839:	8b 43 04             	mov    0x4(%ebx),%eax
f010083c:	89 04 24             	mov    %eax,(%esp)
f010083f:	e8 74 fe ff ff       	call   f01006b8 <getva>
f0100844:	89 c7                	mov    %eax,%edi
	a=getva(argv[2],16);
f0100846:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f010084d:	00 
f010084e:	8b 43 08             	mov    0x8(%ebx),%eax
f0100851:	89 04 24             	mov    %eax,(%esp)
f0100854:	e8 5f fe ff ff       	call   f01006b8 <getva>
f0100859:	89 c6                	mov    %eax,%esi
	content=(uint32_t *)a;
	for(i=0;i<n;i++)
f010085b:	85 ff                	test   %edi,%edi
f010085d:	7e 1f                	jle    f010087e <mon_dumpx+0x6d>
f010085f:	bb 00 00 00 00       	mov    $0x0,%ebx
		cprintf("%x ",*(content+i));
f0100864:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
f0100867:	89 44 24 04          	mov    %eax,0x4(%esp)
f010086b:	c7 04 24 6a aa 10 f0 	movl   $0xf010aa6a,(%esp)
f0100872:	e8 70 31 00 00       	call   f01039e7 <cprintf>
                return 0;
        }
	n=(int)getva(argv[1],10);
	a=getva(argv[2],16);
	content=(uint32_t *)a;
	for(i=0;i<n;i++)
f0100877:	83 c3 01             	add    $0x1,%ebx
f010087a:	39 df                	cmp    %ebx,%edi
f010087c:	75 e6                	jne    f0100864 <mon_dumpx+0x53>
		cprintf("%x ",*(content+i));
	cprintf("\n");
f010087e:	c7 04 24 29 ab 10 f0 	movl   $0xf010ab29,(%esp)
f0100885:	e8 5d 31 00 00       	call   f01039e7 <cprintf>
	return 0;
}
f010088a:	b8 00 00 00 00       	mov    $0x0,%eax
f010088f:	83 c4 0c             	add    $0xc,%esp
f0100892:	5b                   	pop    %ebx
f0100893:	5e                   	pop    %esi
f0100894:	5f                   	pop    %edi
f0100895:	5d                   	pop    %ebp
f0100896:	c3                   	ret    

f0100897 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100897:	55                   	push   %ebp
f0100898:	89 e5                	mov    %esp,%ebp
f010089a:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010089d:	c7 04 24 6e aa 10 f0 	movl   $0xf010aa6e,(%esp)
f01008a4:	e8 3e 31 00 00       	call   f01039e7 <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f01008a9:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01008b0:	00 
f01008b1:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01008b8:	f0 
f01008b9:	c7 04 24 e0 ab 10 f0 	movl   $0xf010abe0,(%esp)
f01008c0:	e8 22 31 00 00       	call   f01039e7 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01008c5:	c7 44 24 08 40 a7 10 	movl   $0x10a740,0x8(%esp)
f01008cc:	00 
f01008cd:	c7 44 24 04 40 a7 10 	movl   $0xf010a740,0x4(%esp)
f01008d4:	f0 
f01008d5:	c7 04 24 04 ac 10 f0 	movl   $0xf010ac04,(%esp)
f01008dc:	e8 06 31 00 00       	call   f01039e7 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01008e1:	c7 44 24 08 d6 42 29 	movl   $0x2942d6,0x8(%esp)
f01008e8:	00 
f01008e9:	c7 44 24 04 d6 42 29 	movl   $0xf02942d6,0x4(%esp)
f01008f0:	f0 
f01008f1:	c7 04 24 28 ac 10 f0 	movl   $0xf010ac28,(%esp)
f01008f8:	e8 ea 30 00 00       	call   f01039e7 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01008fd:	c7 44 24 08 00 55 29 	movl   $0x295500,0x8(%esp)
f0100904:	00 
f0100905:	c7 44 24 04 00 55 29 	movl   $0xf0295500,0x4(%esp)
f010090c:	f0 
f010090d:	c7 04 24 4c ac 10 f0 	movl   $0xf010ac4c,(%esp)
f0100914:	e8 ce 30 00 00       	call   f01039e7 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100919:	ba ff 58 29 f0       	mov    $0xf02958ff,%edx
f010091e:	81 ea 0c 00 10 f0    	sub    $0xf010000c,%edx
f0100924:	89 d0                	mov    %edx,%eax
f0100926:	c1 f8 1f             	sar    $0x1f,%eax
f0100929:	c1 e8 16             	shr    $0x16,%eax
f010092c:	01 d0                	add    %edx,%eax
f010092e:	c1 f8 0a             	sar    $0xa,%eax
f0100931:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100935:	c7 04 24 70 ac 10 f0 	movl   $0xf010ac70,(%esp)
f010093c:	e8 a6 30 00 00       	call   f01039e7 <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
f0100941:	b8 00 00 00 00       	mov    $0x0,%eax
f0100946:	c9                   	leave  
f0100947:	c3                   	ret    

f0100948 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100948:	55                   	push   %ebp
f0100949:	89 e5                	mov    %esp,%ebp
f010094b:	53                   	push   %ebx
f010094c:	83 ec 14             	sub    $0x14,%esp
f010094f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100954:	8b 83 04 b0 10 f0    	mov    -0xfef4ffc(%ebx),%eax
f010095a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010095e:	8b 83 00 b0 10 f0    	mov    -0xfef5000(%ebx),%eax
f0100964:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100968:	c7 04 24 87 aa 10 f0 	movl   $0xf010aa87,(%esp)
f010096f:	e8 73 30 00 00       	call   f01039e7 <cprintf>
f0100974:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100977:	83 fb 6c             	cmp    $0x6c,%ebx
f010097a:	75 d8                	jne    f0100954 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f010097c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100981:	83 c4 14             	add    $0x14,%esp
f0100984:	5b                   	pop    %ebx
f0100985:	5d                   	pop    %ebp
f0100986:	c3                   	ret    

f0100987 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100987:	55                   	push   %ebp
f0100988:	89 e5                	mov    %esp,%ebp
f010098a:	57                   	push   %edi
f010098b:	56                   	push   %esi
f010098c:	53                   	push   %ebx
f010098d:	83 ec 4c             	sub    $0x4c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100990:	c7 04 24 9c ac 10 f0 	movl   $0xf010ac9c,(%esp)
f0100997:	e8 4b 30 00 00       	call   f01039e7 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010099c:	c7 04 24 c0 ac 10 f0 	movl   $0xf010acc0,(%esp)
f01009a3:	e8 3f 30 00 00       	call   f01039e7 <cprintf>

	if (tf != NULL)
f01009a8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01009ac:	74 0b                	je     f01009b9 <monitor+0x32>
		print_trapframe(tf);
f01009ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01009b1:	89 04 24             	mov    %eax,(%esp)
f01009b4:	e8 95 32 00 00       	call   f0103c4e <print_trapframe>

	while (1) {
		buf = readline("K> ");
f01009b9:	c7 04 24 90 aa 10 f0 	movl   $0xf010aa90,(%esp)
f01009c0:	e8 3b 8a 00 00       	call   f0109400 <readline>
f01009c5:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009c7:	85 c0                	test   %eax,%eax
f01009c9:	74 ee                	je     f01009b9 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009cb:	c7 45 b4 00 00 00 00 	movl   $0x0,-0x4c(%ebp)
f01009d2:	bf 00 00 00 00       	mov    $0x0,%edi
f01009d7:	eb 06                	jmp    f01009df <monitor+0x58>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01009d9:	c6 03 00             	movb   $0x0,(%ebx)
f01009dc:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01009df:	0f b6 03             	movzbl (%ebx),%eax
f01009e2:	84 c0                	test   %al,%al
f01009e4:	74 6a                	je     f0100a50 <monitor+0xc9>
f01009e6:	0f be c0             	movsbl %al,%eax
f01009e9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009ed:	c7 04 24 94 aa 10 f0 	movl   $0xf010aa94,(%esp)
f01009f4:	e8 8e 8c 00 00       	call   f0109687 <strchr>
f01009f9:	85 c0                	test   %eax,%eax
f01009fb:	75 dc                	jne    f01009d9 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f01009fd:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a00:	74 4e                	je     f0100a50 <monitor+0xc9>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100a02:	83 ff 0f             	cmp    $0xf,%edi
f0100a05:	75 16                	jne    f0100a1d <monitor+0x96>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a07:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100a0e:	00 
f0100a0f:	c7 04 24 99 aa 10 f0 	movl   $0xf010aa99,(%esp)
f0100a16:	e8 cc 2f 00 00       	call   f01039e7 <cprintf>
f0100a1b:	eb 9c                	jmp    f01009b9 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100a1d:	89 5c bd b4          	mov    %ebx,-0x4c(%ebp,%edi,4)
f0100a21:	83 c7 01             	add    $0x1,%edi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a24:	0f b6 03             	movzbl (%ebx),%eax
f0100a27:	84 c0                	test   %al,%al
f0100a29:	75 0c                	jne    f0100a37 <monitor+0xb0>
f0100a2b:	eb b2                	jmp    f01009df <monitor+0x58>
			buf++;
f0100a2d:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a30:	0f b6 03             	movzbl (%ebx),%eax
f0100a33:	84 c0                	test   %al,%al
f0100a35:	74 a8                	je     f01009df <monitor+0x58>
f0100a37:	0f be c0             	movsbl %al,%eax
f0100a3a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a3e:	c7 04 24 94 aa 10 f0 	movl   $0xf010aa94,(%esp)
f0100a45:	e8 3d 8c 00 00       	call   f0109687 <strchr>
f0100a4a:	85 c0                	test   %eax,%eax
f0100a4c:	74 df                	je     f0100a2d <monitor+0xa6>
f0100a4e:	eb 8f                	jmp    f01009df <monitor+0x58>
			buf++;
	}
	argv[argc] = 0;
f0100a50:	c7 44 bd b4 00 00 00 	movl   $0x0,-0x4c(%ebp,%edi,4)
f0100a57:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a58:	85 ff                	test   %edi,%edi
f0100a5a:	0f 84 59 ff ff ff    	je     f01009b9 <monitor+0x32>
f0100a60:	be 00 00 00 00       	mov    $0x0,%esi
f0100a65:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a6a:	8b 83 00 b0 10 f0    	mov    -0xfef5000(%ebx),%eax
f0100a70:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a74:	8b 45 b4             	mov    -0x4c(%ebp),%eax
f0100a77:	89 04 24             	mov    %eax,(%esp)
f0100a7a:	e8 92 8b 00 00       	call   f0109611 <strcmp>
f0100a7f:	85 c0                	test   %eax,%eax
f0100a81:	75 25                	jne    f0100aa8 <monitor+0x121>
			return commands[i].func(argc, argv, tf);
f0100a83:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100a86:	8b 55 08             	mov    0x8(%ebp),%edx
f0100a89:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100a8d:	8d 55 b4             	lea    -0x4c(%ebp),%edx
f0100a90:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a94:	89 3c 24             	mov    %edi,(%esp)
f0100a97:	ff 14 85 08 b0 10 f0 	call   *-0xfef4ff8(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a9e:	85 c0                	test   %eax,%eax
f0100aa0:	0f 89 13 ff ff ff    	jns    f01009b9 <monitor+0x32>
f0100aa6:	eb 23                	jmp    f0100acb <monitor+0x144>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100aa8:	83 c6 01             	add    $0x1,%esi
f0100aab:	83 c3 0c             	add    $0xc,%ebx
f0100aae:	83 fe 09             	cmp    $0x9,%esi
f0100ab1:	75 b7                	jne    f0100a6a <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100ab3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
f0100ab6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100aba:	c7 04 24 b6 aa 10 f0 	movl   $0xf010aab6,(%esp)
f0100ac1:	e8 21 2f 00 00       	call   f01039e7 <cprintf>
f0100ac6:	e9 ee fe ff ff       	jmp    f01009b9 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100acb:	83 c4 4c             	add    $0x4c,%esp
f0100ace:	5b                   	pop    %ebx
f0100acf:	5e                   	pop    %esi
f0100ad0:	5f                   	pop    %edi
f0100ad1:	5d                   	pop    %ebp
f0100ad2:	c3                   	ret    

f0100ad3 <mon_stepi>:
	}
	return 0;
}
int 
mon_stepi(int argc, char **argv, struct Trapframe *tf)
{
f0100ad3:	55                   	push   %ebp
f0100ad4:	89 e5                	mov    %esp,%ebp
f0100ad6:	53                   	push   %ebx
f0100ad7:	83 ec 14             	sub    $0x14,%esp
	uint32_t retesp;
        struct Trapframe *tf1;
        retesp=tf->tf_regs.reg_oesp-0x20;//看看pushal指令做了什么，就知道为什么减0x20,
f0100ada:	8b 45 10             	mov    0x10(%ebp),%eax
f0100add:	8b 58 0c             	mov    0xc(%eax),%ebx
f0100ae0:	83 eb 20             	sub    $0x20,%ebx
                                        //找到异常产生，进行现场保护后的内核栈栈顶指针
        //cprintf("edi=%x oldesp=%x ebp=%x\n",tf1->tf_regs.reg_edi,retesp,read_ebp());
        tf1=(struct Trapframe*)retesp;
	monitor_disas(tf1->tf_eip,1);
f0100ae3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0100aea:	00 
f0100aeb:	8b 43 30             	mov    0x30(%ebx),%eax
f0100aee:	89 04 24             	mov    %eax,(%esp)
f0100af1:	e8 44 81 00 00       	call   f0108c3a <monitor_disas>

        //tf1->tf_eflags|=0x10000;//设置EFLAGS中的RF
        tf1->tf_eflags|=0x100;//设置EFLAGS中的TF
f0100af6:	81 4b 38 00 01 00 00 	orl    $0x100,0x38(%ebx)
}
//LAB 3: add write esp here
static __inline void
write_esp(uint32_t esp)
{
        __asm __volatile("movl %0,%%esp" : : "r" (esp));
f0100afd:	89 dc                	mov    %ebx,%esp
        //print_trapframe(tf1);
        //cprintf("edi=%x oldesp=%x esp=%x\n",tf1->tf_regs.reg_edi,retesp,read_esp());
      	write_esp(retesp);//恢复栈顶指针
      	trapret();
f0100aff:	e8 40 40 00 00       	call   f0104b44 <trapret>
      	return 0;
}
f0100b04:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b09:	83 c4 14             	add    $0x14,%esp
f0100b0c:	5b                   	pop    %ebx
f0100b0d:	5d                   	pop    %ebp
f0100b0e:	c3                   	ret    

f0100b0f <mon_dumpxp>:
	cprintf("\n");
	return 0;
}
int
mon_dumpxp(int argc, char **argv, struct Trapframe *tf)
{
f0100b0f:	55                   	push   %ebp
f0100b10:	89 e5                	mov    %esp,%ebp
f0100b12:	57                   	push   %edi
f0100b13:	56                   	push   %esi
f0100b14:	53                   	push   %ebx
f0100b15:	83 ec 1c             	sub    $0x1c,%esp
f0100b18:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	uint32_t va,pa,*content;
        int i,n;
        if(argc<3)
f0100b1b:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100b1f:	7f 11                	jg     f0100b32 <mon_dumpxp+0x23>
        {
                cprintf("Command argument is illegle!\n");
f0100b21:	c7 04 24 4c aa 10 f0 	movl   $0xf010aa4c,(%esp)
f0100b28:	e8 ba 2e 00 00       	call   f01039e7 <cprintf>
f0100b2d:	e9 88 00 00 00       	jmp    f0100bba <mon_dumpxp+0xab>
                return 0;
        }
	n=(int)getva(argv[1],10);
f0100b32:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
f0100b39:	00 
f0100b3a:	8b 43 04             	mov    0x4(%ebx),%eax
f0100b3d:	89 04 24             	mov    %eax,(%esp)
f0100b40:	e8 73 fb ff ff       	call   f01006b8 <getva>
f0100b45:	89 c7                	mov    %eax,%edi
	pa = getva(argv[2],16);
f0100b47:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100b4e:	00 
f0100b4f:	8b 43 08             	mov    0x8(%ebx),%eax
f0100b52:	89 04 24             	mov    %eax,(%esp)
f0100b55:	e8 5e fb ff ff       	call   f01006b8 <getva>
f0100b5a:	89 c6                	mov    %eax,%esi
	va = (uint32_t)KADDR(pa);
f0100b5c:	c1 e8 0c             	shr    $0xc,%eax
f0100b5f:	3b 05 f0 54 29 f0    	cmp    0xf02954f0,%eax
f0100b65:	72 20                	jb     f0100b87 <mon_dumpxp+0x78>
f0100b67:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100b6b:	c7 44 24 08 e8 ac 10 	movl   $0xf010ace8,0x8(%esp)
f0100b72:	f0 
f0100b73:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
f0100b7a:	00 
f0100b7b:	c7 04 24 cc aa 10 f0 	movl   $0xf010aacc,(%esp)
f0100b82:	e8 ff f4 ff ff       	call   f0100086 <_panic>
	content=(uint32_t *)va;
	for(i=0;i<n;i++)
f0100b87:	85 ff                	test   %edi,%edi
f0100b89:	7e 23                	jle    f0100bae <mon_dumpxp+0x9f>
f0100b8b:	bb 00 00 00 00       	mov    $0x0,%ebx
                cprintf("%x ",*(content+i));
f0100b90:	8b 84 9e 00 00 00 f0 	mov    -0x10000000(%esi,%ebx,4),%eax
f0100b97:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b9b:	c7 04 24 6a aa 10 f0 	movl   $0xf010aa6a,(%esp)
f0100ba2:	e8 40 2e 00 00       	call   f01039e7 <cprintf>
        }
	n=(int)getva(argv[1],10);
	pa = getva(argv[2],16);
	va = (uint32_t)KADDR(pa);
	content=(uint32_t *)va;
	for(i=0;i<n;i++)
f0100ba7:	83 c3 01             	add    $0x1,%ebx
f0100baa:	39 df                	cmp    %ebx,%edi
f0100bac:	75 e2                	jne    f0100b90 <mon_dumpxp+0x81>
                cprintf("%x ",*(content+i));
        cprintf("\n");
f0100bae:	c7 04 24 29 ab 10 f0 	movl   $0xf010ab29,(%esp)
f0100bb5:	e8 2d 2e 00 00       	call   f01039e7 <cprintf>
        return 0;
}
f0100bba:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bbf:	83 c4 1c             	add    $0x1c,%esp
f0100bc2:	5b                   	pop    %ebx
f0100bc3:	5e                   	pop    %esi
f0100bc4:	5f                   	pop    %edi
f0100bc5:	5d                   	pop    %ebp
f0100bc6:	c3                   	ret    

f0100bc7 <mon_permission>:
	}
	return 0;
}
int
mon_permission(int argc, char **argv, struct Trapframe *tf)
{
f0100bc7:	55                   	push   %ebp
f0100bc8:	89 e5                	mov    %esp,%ebp
f0100bca:	83 ec 28             	sub    $0x28,%esp
f0100bcd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100bd0:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100bd3:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0100bd6:	8b 75 0c             	mov    0xc(%ebp),%esi
	uint32_t a=0;
	int i;
	pte_t *pte;
	struct Page *onepage;
	char operator,pte_ch=0,pte_perm;
	if(argc<4)
f0100bd9:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100bdd:	7f 11                	jg     f0100bf0 <mon_permission+0x29>
	{
		cprintf("Command argument is illegle!\n"); 
f0100bdf:	c7 04 24 4c aa 10 f0 	movl   $0xf010aa4c,(%esp)
f0100be6:	e8 fc 2d 00 00       	call   f01039e7 <cprintf>
f0100beb:	e9 63 01 00 00       	jmp    f0100d53 <mon_permission+0x18c>
		return 0;
	}
	a=getva(argv[2],16);
f0100bf0:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100bf7:	00 
f0100bf8:	8b 46 08             	mov    0x8(%esi),%eax
f0100bfb:	89 04 24             	mov    %eax,(%esp)
f0100bfe:	e8 b5 fa ff ff       	call   f01006b8 <getva>
f0100c03:	89 c3                	mov    %eax,%ebx
	operator=argv[1][0];
f0100c05:	8b 46 04             	mov    0x4(%esi),%eax
f0100c08:	0f b6 38             	movzbl (%eax),%edi
	if((onepage=page_lookup(boot_pgdir,(void *)a,&pte))){
f0100c0b:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0100c0e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c12:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100c16:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f0100c1b:	89 04 24             	mov    %eax,(%esp)
f0100c1e:	e8 08 08 00 00       	call   f010142b <page_lookup>
f0100c23:	85 c0                	test   %eax,%eax
f0100c25:	0f 84 18 01 00 00    	je     f0100d43 <mon_permission+0x17c>
f0100c2b:	b9 03 00 00 00       	mov    $0x3,%ecx
f0100c30:	bb 00 00 00 00       	mov    $0x0,%ebx
		for(i=3;i<argc;i++)
		{
			pte_perm=argv[i][0];
f0100c35:	8b 14 8e             	mov    (%esi,%ecx,4),%edx
			switch(pte_perm){
f0100c38:	0f b6 02             	movzbl (%edx),%eax
f0100c3b:	83 e8 41             	sub    $0x41,%eax
f0100c3e:	3c 16                	cmp    $0x16,%al
f0100c40:	0f 87 86 00 00 00    	ja     f0100ccc <mon_permission+0x105>
f0100c46:	0f b6 c0             	movzbl %al,%eax
f0100c49:	ff 24 85 a0 af 10 f0 	jmp    *-0xfef5060(,%eax,4)
				case 'P':
					 if((argv[i][1]!='\0')&&(argv[i][3]=='\0')){
f0100c50:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f0100c54:	84 c0                	test   %al,%al
f0100c56:	74 3f                	je     f0100c97 <mon_permission+0xd0>
f0100c58:	80 7a 03 00          	cmpb   $0x0,0x3(%edx)
f0100c5c:	75 3e                	jne    f0100c9c <mon_permission+0xd5>
                               			 if((argv[i][0]=='P')&&(argv[i][1]=='W')&&(argv[i][2]=='T'))
f0100c5e:	3c 57                	cmp    $0x57,%al
f0100c60:	75 10                	jne    f0100c72 <mon_permission+0xab>
f0100c62:	80 7a 02 54          	cmpb   $0x54,0x2(%edx)
f0100c66:	75 0a                	jne    f0100c72 <mon_permission+0xab>
                                        		 pte_ch|=PTE_PWT;
f0100c68:	83 cb 08             	or     $0x8,%ebx
f0100c6b:	90                   	nop    
f0100c6c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0100c70:	eb 6c                	jmp    f0100cde <mon_permission+0x117>
                               			 else if((argv[i][0]=='P')&&(argv[i][1]=='C')&&(argv[i][2]=='D'))
f0100c72:	3c 43                	cmp    $0x43,%al
f0100c74:	75 0c                	jne    f0100c82 <mon_permission+0xbb>
f0100c76:	80 7a 02 44          	cmpb   $0x44,0x2(%edx)
f0100c7a:	75 06                	jne    f0100c82 <mon_permission+0xbb>
                                        		 pte_ch|=PTE_PCD;
f0100c7c:	83 cb 10             	or     $0x10,%ebx
f0100c7f:	90                   	nop    
f0100c80:	eb 5c                	jmp    f0100cde <mon_permission+0x117>
                               			 else {cprintf("permission %s is not exist\n",argv[i]);return 0;}
f0100c82:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100c86:	c7 04 24 db aa 10 f0 	movl   $0xf010aadb,(%esp)
f0100c8d:	e8 55 2d 00 00       	call   f01039e7 <cprintf>
f0100c92:	e9 bc 00 00 00       	jmp    f0100d53 <mon_permission+0x18c>
                       			 }
					else if(argv[i][1]=='\0')	pte_ch|=PTE_P;
f0100c97:	83 cb 01             	or     $0x1,%ebx
f0100c9a:	eb 42                	jmp    f0100cde <mon_permission+0x117>
					else {cprintf("permission %s is not exist\n",argv[i]);return 0;}
f0100c9c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100ca0:	c7 04 24 db aa 10 f0 	movl   $0xf010aadb,(%esp)
f0100ca7:	e8 3b 2d 00 00       	call   f01039e7 <cprintf>
f0100cac:	e9 a2 00 00 00       	jmp    f0100d53 <mon_permission+0x18c>
					break;
				case 'W':pte_ch|=PTE_W;break;
f0100cb1:	83 cb 02             	or     $0x2,%ebx
f0100cb4:	eb 28                	jmp    f0100cde <mon_permission+0x117>
				case 'U':pte_ch|=PTE_U;break;
f0100cb6:	83 cb 04             	or     $0x4,%ebx
f0100cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
f0100cc0:	eb 1c                	jmp    f0100cde <mon_permission+0x117>
				case 'D':pte_ch|=PTE_D;break;
f0100cc2:	83 cb 40             	or     $0x40,%ebx
f0100cc5:	eb 17                	jmp    f0100cde <mon_permission+0x117>
				case 'A':pte_ch|=PTE_A;break;
f0100cc7:	83 cb 20             	or     $0x20,%ebx
f0100cca:	eb 12                	jmp    f0100cde <mon_permission+0x117>
				default:
					cprintf("permission %s is not exist\n",argv[i]);
f0100ccc:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100cd0:	c7 04 24 db aa 10 f0 	movl   $0xf010aadb,(%esp)
f0100cd7:	e8 0b 2d 00 00       	call   f01039e7 <cprintf>
f0100cdc:	eb 75                	jmp    f0100d53 <mon_permission+0x18c>
		return 0;
	}
	a=getva(argv[2],16);
	operator=argv[1][0];
	if((onepage=page_lookup(boot_pgdir,(void *)a,&pte))){
		for(i=3;i<argc;i++)
f0100cde:	83 c1 01             	add    $0x1,%ecx
f0100ce1:	3b 4d 08             	cmp    0x8(%ebp),%ecx
f0100ce4:	0f 85 4b ff ff ff    	jne    f0100c35 <mon_permission+0x6e>
				default:
					cprintf("permission %s is not exist\n",argv[i]);
					return 0;
			}
		}
		switch(operator){
f0100cea:	89 f8                	mov    %edi,%eax
f0100cec:	3c 63                	cmp    $0x63,%al
f0100cee:	66 90                	xchg   %ax,%ax
f0100cf0:	74 0e                	je     f0100d00 <mon_permission+0x139>
f0100cf2:	3c 73                	cmp    $0x73,%al
f0100cf4:	75 28                	jne    f0100d1e <mon_permission+0x157>
			case 's':
				*pte|=pte_ch;break;
f0100cf6:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100cf9:	0f be c3             	movsbl %bl,%eax
f0100cfc:	09 02                	or     %eax,(%edx)
f0100cfe:	eb 35                	jmp    f0100d35 <mon_permission+0x16e>
			case 'c':
				if(pte_ch&PTE_P)
f0100d00:	0f be c3             	movsbl %bl,%eax
f0100d03:	a8 01                	test   $0x1,%al
f0100d05:	74 0e                	je     f0100d15 <mon_permission+0x14e>
					{cprintf("clearing PTE_P is denied\n");return 0;}
f0100d07:	c7 04 24 f7 aa 10 f0 	movl   $0xf010aaf7,(%esp)
f0100d0e:	e8 d4 2c 00 00       	call   f01039e7 <cprintf>
f0100d13:	eb 3e                	jmp    f0100d53 <mon_permission+0x18c>
				else
					{*pte&=(~pte_ch);break;}
f0100d15:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100d18:	f7 d0                	not    %eax
f0100d1a:	21 02                	and    %eax,(%edx)
f0100d1c:	eb 17                	jmp    f0100d35 <mon_permission+0x16e>
			default:
				cprintf("oprator %c is not setting or clearing permission\n",operator);
f0100d1e:	89 fa                	mov    %edi,%edx
f0100d20:	0f be c2             	movsbl %dl,%eax
f0100d23:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d27:	c7 04 24 0c ad 10 f0 	movl   $0xf010ad0c,(%esp)
f0100d2e:	e8 b4 2c 00 00       	call   f01039e7 <cprintf>
f0100d33:	eb 1e                	jmp    f0100d53 <mon_permission+0x18c>
				return 0;
		}
		cprintf("permission is changed successfully!\n");
f0100d35:	c7 04 24 40 ad 10 f0 	movl   $0xf010ad40,(%esp)
f0100d3c:	e8 a6 2c 00 00       	call   f01039e7 <cprintf>
f0100d41:	eb 10                	jmp    f0100d53 <mon_permission+0x18c>
	}
	else cprintf("this physical page corresponding to %x is not exiting\n",a);
f0100d43:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100d47:	c7 04 24 68 ad 10 f0 	movl   $0xf010ad68,(%esp)
f0100d4e:	e8 94 2c 00 00       	call   f01039e7 <cprintf>
	return 0;
}
f0100d53:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d58:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0100d5b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0100d5e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0100d61:	89 ec                	mov    %ebp,%esp
f0100d63:	5d                   	pop    %ebp
f0100d64:	c3                   	ret    

f0100d65 <mon_showmappings>:
	}
	return va;
}
int
mon_showmappings(int argc,char **argv,struct Trapframe *tf)
{
f0100d65:	55                   	push   %ebp
f0100d66:	89 e5                	mov    %esp,%ebp
f0100d68:	57                   	push   %edi
f0100d69:	56                   	push   %esi
f0100d6a:	53                   	push   %ebx
f0100d6b:	83 ec 1c             	sub    $0x1c,%esp
	int i;
	uint32_t a,la;
	pte_t *pte;
	struct Page *onepage;
	physaddr_t physaddr;
	if(argc!=3)
f0100d6e:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100d72:	74 11                	je     f0100d85 <mon_showmappings+0x20>
	{
		cprintf("Command argument is illegle!\n"); 
f0100d74:	c7 04 24 4c aa 10 f0 	movl   $0xf010aa4c,(%esp)
f0100d7b:	e8 67 2c 00 00       	call   f01039e7 <cprintf>
f0100d80:	e9 6f 01 00 00       	jmp    f0100ef4 <mon_showmappings+0x18f>
		return 0;
	}
	//for(i=0;i<argc;i++){
	//	cprintf("%s\n",argv[i]);
	//}
	a=getva(argv[1],16);
f0100d85:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100d8c:	00 
f0100d8d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100d90:	8b 42 04             	mov    0x4(%edx),%eax
f0100d93:	89 04 24             	mov    %eax,(%esp)
f0100d96:	e8 1d f9 ff ff       	call   f01006b8 <getva>
f0100d9b:	89 c3                	mov    %eax,%ebx
	la=getva(argv[2],16);
f0100d9d:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100da4:	00 
f0100da5:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100da8:	8b 42 08             	mov    0x8(%edx),%eax
f0100dab:	89 04 24             	mov    %eax,(%esp)
f0100dae:	e8 05 f9 ff ff       	call   f01006b8 <getva>
f0100db3:	89 c6                	mov    %eax,%esi
	for(;;)
	{
		if((onepage=page_lookup(boot_pgdir,(void *)a,&pte))){
f0100db5:	8d 7d f0             	lea    -0x10(%ebp),%edi
f0100db8:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100dbc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100dc0:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f0100dc5:	89 04 24             	mov    %eax,(%esp)
f0100dc8:	e8 5e 06 00 00       	call   f010142b <page_lookup>
f0100dcd:	85 c0                	test   %eax,%eax
f0100dcf:	0f 84 00 01 00 00    	je     f0100ed5 <mon_showmappings+0x170>
			physaddr=page2pa(onepage);
			cprintf("virtual addr=%x page physaddr=%x permission: ",a,physaddr);
f0100dd5:	2b 05 fc 54 29 f0    	sub    0xf02954fc,%eax
f0100ddb:	c1 f8 02             	sar    $0x2,%eax
f0100dde:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100de4:	c1 e0 0c             	shl    $0xc,%eax
f0100de7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100deb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100def:	c7 04 24 a0 ad 10 f0 	movl   $0xf010ada0,(%esp)
f0100df6:	e8 ec 2b 00 00       	call   f01039e7 <cprintf>
			if((*pte)&PTE_D) cprintf("D ");
f0100dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100dfe:	f6 00 40             	testb  $0x40,(%eax)
f0100e01:	74 0e                	je     f0100e11 <mon_showmappings+0xac>
f0100e03:	c7 04 24 19 ab 10 f0 	movl   $0xf010ab19,(%esp)
f0100e0a:	e8 d8 2b 00 00       	call   f01039e7 <cprintf>
f0100e0f:	eb 0c                	jmp    f0100e1d <mon_showmappings+0xb8>
			else cprintf("- ");
f0100e11:	c7 04 24 11 ab 10 f0 	movl   $0xf010ab11,(%esp)
f0100e18:	e8 ca 2b 00 00       	call   f01039e7 <cprintf>
			if(*pte&PTE_A) cprintf("A ");
f0100e1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100e20:	f6 00 20             	testb  $0x20,(%eax)
f0100e23:	74 0e                	je     f0100e33 <mon_showmappings+0xce>
f0100e25:	c7 04 24 14 ab 10 f0 	movl   $0xf010ab14,(%esp)
f0100e2c:	e8 b6 2b 00 00       	call   f01039e7 <cprintf>
f0100e31:	eb 0c                	jmp    f0100e3f <mon_showmappings+0xda>
                        else cprintf("- ");
f0100e33:	c7 04 24 11 ab 10 f0 	movl   $0xf010ab11,(%esp)
f0100e3a:	e8 a8 2b 00 00       	call   f01039e7 <cprintf>
			if(*pte&PTE_PCD) cprintf("PCD ");
f0100e3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100e42:	f6 00 10             	testb  $0x10,(%eax)
f0100e45:	74 0e                	je     f0100e55 <mon_showmappings+0xf0>
f0100e47:	c7 04 24 17 ab 10 f0 	movl   $0xf010ab17,(%esp)
f0100e4e:	e8 94 2b 00 00       	call   f01039e7 <cprintf>
f0100e53:	eb 0c                	jmp    f0100e61 <mon_showmappings+0xfc>
                        else cprintf("- ");
f0100e55:	c7 04 24 11 ab 10 f0 	movl   $0xf010ab11,(%esp)
f0100e5c:	e8 86 2b 00 00       	call   f01039e7 <cprintf>
			if(*pte&PTE_PWT) cprintf("PWT ");
f0100e61:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100e64:	f6 00 08             	testb  $0x8,(%eax)
f0100e67:	74 0e                	je     f0100e77 <mon_showmappings+0x112>
f0100e69:	c7 04 24 1c ab 10 f0 	movl   $0xf010ab1c,(%esp)
f0100e70:	e8 72 2b 00 00       	call   f01039e7 <cprintf>
f0100e75:	eb 0c                	jmp    f0100e83 <mon_showmappings+0x11e>
                        else cprintf("- ");
f0100e77:	c7 04 24 11 ab 10 f0 	movl   $0xf010ab11,(%esp)
f0100e7e:	e8 64 2b 00 00       	call   f01039e7 <cprintf>
			if(*pte&PTE_U) cprintf("U ");
f0100e83:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100e86:	f6 00 04             	testb  $0x4,(%eax)
f0100e89:	74 0e                	je     f0100e99 <mon_showmappings+0x134>
f0100e8b:	c7 04 24 21 ab 10 f0 	movl   $0xf010ab21,(%esp)
f0100e92:	e8 50 2b 00 00       	call   f01039e7 <cprintf>
f0100e97:	eb 0c                	jmp    f0100ea5 <mon_showmappings+0x140>
                        else cprintf("- ");
f0100e99:	c7 04 24 11 ab 10 f0 	movl   $0xf010ab11,(%esp)
f0100ea0:	e8 42 2b 00 00       	call   f01039e7 <cprintf>
			if(*pte&PTE_W) cprintf("W ");
f0100ea5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100ea8:	f6 00 02             	testb  $0x2,(%eax)
f0100eab:	74 0e                	je     f0100ebb <mon_showmappings+0x156>
f0100ead:	c7 04 24 24 ab 10 f0 	movl   $0xf010ab24,(%esp)
f0100eb4:	e8 2e 2b 00 00       	call   f01039e7 <cprintf>
f0100eb9:	eb 0c                	jmp    f0100ec7 <mon_showmappings+0x162>
                        else cprintf("- ");
f0100ebb:	c7 04 24 11 ab 10 f0 	movl   $0xf010ab11,(%esp)
f0100ec2:	e8 20 2b 00 00       	call   f01039e7 <cprintf>
			cprintf("P \n");
f0100ec7:	c7 04 24 27 ab 10 f0 	movl   $0xf010ab27,(%esp)
f0100ece:	e8 14 2b 00 00       	call   f01039e7 <cprintf>
f0100ed3:	eb 10                	jmp    f0100ee5 <mon_showmappings+0x180>
		}	
		else cprintf("this physical page corresponding to %x is not exiting\n",a);
f0100ed5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ed9:	c7 04 24 68 ad 10 f0 	movl   $0xf010ad68,(%esp)
f0100ee0:	e8 02 2b 00 00       	call   f01039e7 <cprintf>
		if(a==la) break;
f0100ee5:	39 f3                	cmp    %esi,%ebx
f0100ee7:	74 0b                	je     f0100ef4 <mon_showmappings+0x18f>
		a+=PGSIZE;
f0100ee9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100eef:	e9 c4 fe ff ff       	jmp    f0100db8 <mon_showmappings+0x53>
	}
	return 0;
}
f0100ef4:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ef9:	83 c4 1c             	add    $0x1c,%esp
f0100efc:	5b                   	pop    %ebx
f0100efd:	5e                   	pop    %esi
f0100efe:	5f                   	pop    %edi
f0100eff:	5d                   	pop    %ebp
f0100f00:	c3                   	ret    

f0100f01 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100f01:	55                   	push   %ebp
f0100f02:	89 e5                	mov    %esp,%ebp
f0100f04:	57                   	push   %edi
f0100f05:	56                   	push   %esi
f0100f06:	53                   	push   %ebx
f0100f07:	83 ec 4c             	sub    $0x4c,%esp

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100f0a:	89 eb                	mov    %ebp,%ebx
	int i;
	struct Eipdebuginfo eipinfo;
        uint32_t ebp,eip,arg[5];
        ebp=read_ebp();

        cprintf("Stack backtrace :\n");
f0100f0c:	c7 04 24 2b ab 10 f0 	movl   $0xf010ab2b,(%esp)
f0100f13:	e8 cf 2a 00 00       	call   f01039e7 <cprintf>
        do{

		eip=*((uint32_t *)ebp+1);
                for(i=0;i<5;i++)
                        arg[i]=*((uint32_t *)ebp+i+2);
f0100f18:	8d 7d c8             	lea    -0x38(%ebp),%edi
        ebp=read_ebp();

        cprintf("Stack backtrace :\n");
        do{

		eip=*((uint32_t *)ebp+1);
f0100f1b:	89 5d c0             	mov    %ebx,-0x40(%ebp)
f0100f1e:	8b 73 04             	mov    0x4(%ebx),%esi
f0100f21:	ba 00 00 00 00       	mov    $0x0,%edx
                for(i=0;i<5;i++)
                        arg[i]=*((uint32_t *)ebp+i+2);
f0100f26:	8b 44 93 08          	mov    0x8(%ebx,%edx,4),%eax
f0100f2a:	89 04 97             	mov    %eax,(%edi,%edx,4)

        cprintf("Stack backtrace :\n");
        do{

		eip=*((uint32_t *)ebp+1);
                for(i=0;i<5;i++)
f0100f2d:	83 c2 01             	add    $0x1,%edx
f0100f30:	83 fa 05             	cmp    $0x5,%edx
f0100f33:	75 f1                	jne    f0100f26 <mon_backtrace+0x25>
                        arg[i]=*((uint32_t *)ebp+i+2);
                cprintf("ebp %08x eip %08x ",ebp,eip);
f0100f35:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100f39:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f3d:	c7 04 24 3e ab 10 f0 	movl   $0xf010ab3e,(%esp)
f0100f44:	e8 9e 2a 00 00       	call   f01039e7 <cprintf>
                cprintf("args %08x %08x %08x %08x %08x\n",arg[0],arg[1],arg[2],arg[3],arg[4]);
f0100f49:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f4c:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100f50:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100f53:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100f57:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100f5a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f5e:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0100f61:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f65:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0100f68:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f6c:	c7 04 24 d0 ad 10 f0 	movl   $0xf010add0,(%esp)
f0100f73:	e8 6f 2a 00 00       	call   f01039e7 <cprintf>
                if(!debuginfo_eip((uintptr_t)eip,&eipinfo))
f0100f78:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0100f7b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f7f:	89 34 24             	mov    %esi,(%esp)
f0100f82:	e8 4b 44 00 00       	call   f01053d2 <debuginfo_eip>
f0100f87:	85 c0                	test   %eax,%eax
f0100f89:	75 31                	jne    f0100fbc <mon_backtrace+0xbb>
                {
                        cprintf("       %s:%d: %.*s+%d\n",eipinfo.eip_file,eipinfo.eip_line,eipinfo.eip_fn_namelen,eipinfo.eip_fn_name,eip-eipinfo.eip_fn_addr);
f0100f8b:	89 f0                	mov    %esi,%eax
f0100f8d:	2b 45 ec             	sub    -0x14(%ebp),%eax
f0100f90:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100f94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f97:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100f9b:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100f9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fa2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100fa5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100fa9:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100fac:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fb0:	c7 04 24 51 ab 10 f0 	movl   $0xf010ab51,(%esp)
f0100fb7:	e8 2b 2a 00 00       	call   f01039e7 <cprintf>
                }
                ebp=*(uint32_t *)ebp;
f0100fbc:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100fbf:	8b 18                	mov    (%eax),%ebx
        }while(ebp!=0);
f0100fc1:	85 db                	test   %ebx,%ebx
f0100fc3:	0f 85 52 ff ff ff    	jne    f0100f1b <mon_backtrace+0x1a>
	return 0;
}
f0100fc9:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fce:	83 c4 4c             	add    $0x4c,%esp
f0100fd1:	5b                   	pop    %ebx
f0100fd2:	5e                   	pop    %esi
f0100fd3:	5f                   	pop    %edi
f0100fd4:	5d                   	pop    %ebp
f0100fd5:	c3                   	ret    

f0100fd6 <mon_continue>:
        cprintf("\n");
        return 0;
}
int
mon_continue(int argc, char **argv, struct Trapframe *tf)
{
f0100fd6:	55                   	push   %ebp
f0100fd7:	89 e5                	mov    %esp,%ebp
f0100fd9:	83 ec 08             	sub    $0x8,%esp
f0100fdc:	8b 55 10             	mov    0x10(%ebp),%edx
	uint32_t retesp;
	struct Trapframe *tf1;
	if(tf->tf_trapno==3||tf->tf_trapno==1)
f0100fdf:	8b 42 28             	mov    0x28(%edx),%eax
f0100fe2:	83 f8 03             	cmp    $0x3,%eax
f0100fe5:	74 05                	je     f0100fec <mon_continue+0x16>
f0100fe7:	83 f8 01             	cmp    $0x1,%eax
f0100fea:	75 1b                	jne    f0101007 <mon_continue+0x31>
	{
		retesp=tf->tf_regs.reg_oesp-0x20;//看看pushal指令做了什么，就知道为什么减0x20,
f0100fec:	8b 52 0c             	mov    0xc(%edx),%edx
f0100fef:	83 ea 20             	sub    $0x20,%edx
					//找到异常产生，进行现场保护后的内核栈栈顶指针
		//cprintf("edi=%x oldesp=%x ebp=%x\n",tf1->tf_regs.reg_edi,retesp,read_ebp());
		tf1=(struct Trapframe*)retesp;
		tf1->tf_eflags|=0x10000;//设置EFLAGS中的RF
		tf1->tf_eflags&=~0x100;//复位EFLAGS中的TF
f0100ff2:	8b 42 38             	mov    0x38(%edx),%eax
f0100ff5:	0d 00 00 01 00       	or     $0x10000,%eax
f0100ffa:	80 e4 fe             	and    $0xfe,%ah
f0100ffd:	89 42 38             	mov    %eax,0x38(%edx)
}
//LAB 3: add write esp here
static __inline void
write_esp(uint32_t esp)
{
        __asm __volatile("movl %0,%%esp" : : "r" (esp));
f0101000:	89 d4                	mov    %edx,%esp
		//print_trapframe(tf1);
 		//cprintf("edi=%x oldesp=%x esp=%x\n",tf1->tf_regs.reg_edi,retesp,read_esp());
		write_esp(retesp);//恢复栈顶指针
		trapret();
f0101002:	e8 3d 3b 00 00       	call   f0104b44 <trapret>
	}
	return 0;
}
f0101007:	b8 00 00 00 00       	mov    $0x0,%eax
f010100c:	c9                   	leave  
f010100d:	c3                   	ret    
	...

f0101010 <boot_alloc>:
// This function may ONLY be used during initialization,
// before the page_free_list has been set up.
// 
static void*
boot_alloc(uint32_t n, uint32_t align)
{
f0101010:	55                   	push   %ebp
f0101011:	89 e5                	mov    %esp,%ebp
f0101013:	83 ec 0c             	sub    $0xc,%esp
f0101016:	89 1c 24             	mov    %ebx,(%esp)
f0101019:	89 74 24 04          	mov    %esi,0x4(%esp)
f010101d:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101021:	89 c3                	mov    %eax,%ebx
	// Initialize boot_freemem if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment -
	// i.e., the first virtual address that the linker
	// did _not_ assign to any kernel code or global variables.
	if (boot_freemem == 0)
f0101023:	83 3d 34 45 29 f0 00 	cmpl   $0x0,0xf0294534
f010102a:	75 0a                	jne    f0101036 <boot_alloc+0x26>
		boot_freemem = end;
f010102c:	c7 05 34 45 29 f0 00 	movl   $0xf0295500,0xf0294534
f0101033:	55 29 f0 
	//	Step 1: round boot_freemem up to be aligned properly
	//		(hint: look in types.h for some handy macros)
	//	Step 2: save current value of boot_freemem as allocated chunk
	//	Step 3: increase boot_freemem to record allocation
	//	Step 4: return allocated chunk
	boot_freemem=ROUNDUP(boot_freemem,align);
f0101036:	a1 34 45 29 f0       	mov    0xf0294534,%eax
f010103b:	83 e8 01             	sub    $0x1,%eax
f010103e:	8d 3c 10             	lea    (%eax,%edx,1),%edi
f0101041:	89 f8                	mov    %edi,%eax
f0101043:	89 d6                	mov    %edx,%esi
f0101045:	ba 00 00 00 00       	mov    $0x0,%edx
f010104a:	f7 f6                	div    %esi
f010104c:	89 f8                	mov    %edi,%eax
f010104e:	29 d0                	sub    %edx,%eax
	v=(void *)boot_freemem;
	boot_freemem=boot_freemem+n;
f0101050:	8d 14 18             	lea    (%eax,%ebx,1),%edx
f0101053:	89 15 34 45 29 f0    	mov    %edx,0xf0294534
	return v;//这里v是个虚拟地址
	//return NULL;
}
f0101059:	8b 1c 24             	mov    (%esp),%ebx
f010105c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101060:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0101064:	89 ec                	mov    %ebp,%esp
f0101066:	5d                   	pop    %ebp
f0101067:	c3                   	ret    

f0101068 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f0101068:	55                   	push   %ebp
f0101069:	89 e5                	mov    %esp,%ebp
f010106b:	8b 4d 08             	mov    0x8(%ebp),%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f010106e:	8b 15 fc 54 29 f0    	mov    0xf02954fc,%edx
	// Fill this function in
	if(pages[page2ppn(pp)].pp_ref==0){
f0101074:	89 c8                	mov    %ecx,%eax
f0101076:	29 d0                	sub    %edx,%eax
f0101078:	83 e0 fc             	and    $0xfffffffc,%eax
f010107b:	66 83 7c 10 08 00    	cmpw   $0x0,0x8(%eax,%edx,1)
f0101081:	75 20                	jne    f01010a3 <page_free+0x3b>
		LIST_INSERT_HEAD(&page_free_list,pp,pp_link);
f0101083:	a1 38 45 29 f0       	mov    0xf0294538,%eax
f0101088:	89 01                	mov    %eax,(%ecx)
f010108a:	85 c0                	test   %eax,%eax
f010108c:	74 08                	je     f0101096 <page_free+0x2e>
f010108e:	a1 38 45 29 f0       	mov    0xf0294538,%eax
f0101093:	89 48 04             	mov    %ecx,0x4(%eax)
f0101096:	89 0d 38 45 29 f0    	mov    %ecx,0xf0294538
f010109c:	c7 41 04 38 45 29 f0 	movl   $0xf0294538,0x4(%ecx)
	}
}
f01010a3:	5d                   	pop    %ebp
f01010a4:	c3                   	ret    

f01010a5 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f01010a5:	55                   	push   %ebp
f01010a6:	89 e5                	mov    %esp,%ebp
f01010a8:	83 ec 04             	sub    $0x4,%esp
f01010ab:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01010ae:	0f b7 42 08          	movzwl 0x8(%edx),%eax
f01010b2:	83 e8 01             	sub    $0x1,%eax
f01010b5:	66 89 42 08          	mov    %ax,0x8(%edx)
f01010b9:	66 85 c0             	test   %ax,%ax
f01010bc:	75 08                	jne    f01010c6 <page_decref+0x21>
		page_free(pp);
f01010be:	89 14 24             	mov    %edx,(%esp)
f01010c1:	e8 a2 ff ff ff       	call   f0101068 <page_free>
}
f01010c6:	c9                   	leave  
f01010c7:	c3                   	ret    

f01010c8 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01010c8:	55                   	push   %ebp
f01010c9:	89 e5                	mov    %esp,%ebp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01010cb:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f01010d0:	85 c0                	test   %eax,%eax
f01010d2:	74 08                	je     f01010dc <tlb_invalidate+0x14>
f01010d4:	8b 55 08             	mov    0x8(%ebp),%edx
f01010d7:	39 50 5c             	cmp    %edx,0x5c(%eax)
f01010da:	75 06                	jne    f01010e2 <tlb_invalidate+0x1a>
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01010dc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010df:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01010e2:	5d                   	pop    %ebp
f01010e3:	c3                   	ret    

f01010e4 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01010e4:	55                   	push   %ebp
f01010e5:	89 e5                	mov    %esp,%ebp
f01010e7:	56                   	push   %esi
f01010e8:	53                   	push   %ebx
f01010e9:	83 ec 10             	sub    $0x10,%esp
	//     in physical memory?  Which pages are already in use for
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&page_free_list);
f01010ec:	c7 05 38 45 29 f0 00 	movl   $0x0,0xf0294538
f01010f3:	00 00 00 
	for (i = 0; i < npage; i++) {
f01010f6:	83 3d f0 54 29 f0 00 	cmpl   $0x0,0xf02954f0
f01010fd:	74 63                	je     f0101162 <page_init+0x7e>
f01010ff:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101104:	b8 00 00 00 00       	mov    $0x0,%eax
		pages[i].pp_ref = 0;
f0101109:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010110c:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
f0101113:	a1 fc 54 29 f0       	mov    0xf02954fc,%eax
f0101118:	66 c7 44 01 08 00 00 	movw   $0x0,0x8(%ecx,%eax,1)
		LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
f010111f:	8b 15 38 45 29 f0    	mov    0xf0294538,%edx
f0101125:	a1 fc 54 29 f0       	mov    0xf02954fc,%eax
f010112a:	89 14 01             	mov    %edx,(%ecx,%eax,1)
f010112d:	85 d2                	test   %edx,%edx
f010112f:	74 10                	je     f0101141 <page_init+0x5d>
f0101131:	89 ca                	mov    %ecx,%edx
f0101133:	03 15 fc 54 29 f0    	add    0xf02954fc,%edx
f0101139:	a1 38 45 29 f0       	mov    0xf0294538,%eax
f010113e:	89 50 04             	mov    %edx,0x4(%eax)
f0101141:	89 c8                	mov    %ecx,%eax
f0101143:	03 05 fc 54 29 f0    	add    0xf02954fc,%eax
f0101149:	a3 38 45 29 f0       	mov    %eax,0xf0294538
f010114e:	c7 40 04 38 45 29 f0 	movl   $0xf0294538,0x4(%eax)
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&page_free_list);
	for (i = 0; i < npage; i++) {
f0101155:	83 c3 01             	add    $0x1,%ebx
f0101158:	89 d8                	mov    %ebx,%eax
f010115a:	39 1d f0 54 29 f0    	cmp    %ebx,0xf02954f0
f0101160:	77 a7                	ja     f0101109 <page_init+0x25>
		pages[i].pp_ref = 0;
		LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
	}
	pages[0].pp_ref=1;
f0101162:	a1 fc 54 29 f0       	mov    0xf02954fc,%eax
f0101167:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
	LIST_REMOVE(&pages[0],pp_link);
f010116d:	a1 fc 54 29 f0       	mov    0xf02954fc,%eax
f0101172:	8b 10                	mov    (%eax),%edx
f0101174:	85 d2                	test   %edx,%edx
f0101176:	74 06                	je     f010117e <page_init+0x9a>
f0101178:	8b 40 04             	mov    0x4(%eax),%eax
f010117b:	89 42 04             	mov    %eax,0x4(%edx)
f010117e:	a1 fc 54 29 f0       	mov    0xf02954fc,%eax
f0101183:	8b 50 04             	mov    0x4(%eax),%edx
f0101186:	8b 00                	mov    (%eax),%eax
f0101188:	89 02                	mov    %eax,(%edx)
	for(i=PPN(IOPHYSMEM);i<=PPN(ROUNDUP(PADDR(boot_freemem),PGSIZE));i++){
f010118a:	a1 34 45 29 f0       	mov    0xf0294534,%eax
f010118f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101194:	76 62                	jbe    f01011f8 <page_init+0x114>
f0101196:	05 ff 0f 00 10       	add    $0x10000fff,%eax
f010119b:	89 c6                	mov    %eax,%esi
f010119d:	c1 ee 0c             	shr    $0xc,%esi
f01011a0:	81 fe 9f 00 00 00    	cmp    $0x9f,%esi
f01011a6:	76 7d                	jbe    f0101225 <page_init+0x141>
f01011a8:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01011ad:	bb a1 00 00 00       	mov    $0xa1,%ebx
							//这里要使用boot_freemem的物理地址,这个bug在做lab3时才发现
		pages[i].pp_ref=1;
f01011b2:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01011b5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01011bc:	a1 fc 54 29 f0       	mov    0xf02954fc,%eax
f01011c1:	66 c7 44 02 08 01 00 	movw   $0x1,0x8(%edx,%eax,1)
		LIST_REMOVE(&pages[i],pp_link);
f01011c8:	89 d0                	mov    %edx,%eax
f01011ca:	03 05 fc 54 29 f0    	add    0xf02954fc,%eax
f01011d0:	8b 08                	mov    (%eax),%ecx
f01011d2:	85 c9                	test   %ecx,%ecx
f01011d4:	74 17                	je     f01011ed <page_init+0x109>
f01011d6:	8b 40 04             	mov    0x4(%eax),%eax
f01011d9:	89 41 04             	mov    %eax,0x4(%ecx)
f01011dc:	89 d0                	mov    %edx,%eax
f01011de:	03 05 fc 54 29 f0    	add    0xf02954fc,%eax
f01011e4:	8b 50 04             	mov    0x4(%eax),%edx
f01011e7:	8b 00                	mov    (%eax),%eax
f01011e9:	89 02                	mov    %eax,(%edx)
f01011eb:	eb 2b                	jmp    f0101218 <page_init+0x134>
f01011ed:	8b 40 04             	mov    0x4(%eax),%eax
f01011f0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f01011f6:	eb 20                	jmp    f0101218 <page_init+0x134>
		pages[i].pp_ref = 0;
		LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
	}
	pages[0].pp_ref=1;
	LIST_REMOVE(&pages[0],pp_link);
	for(i=PPN(IOPHYSMEM);i<=PPN(ROUNDUP(PADDR(boot_freemem),PGSIZE));i++){
f01011f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011fc:	c7 44 24 08 6c b0 10 	movl   $0xf010b06c,0x8(%esp)
f0101203:	f0 
f0101204:	c7 44 24 04 df 01 00 	movl   $0x1df,0x4(%esp)
f010120b:	00 
f010120c:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101213:	e8 6e ee ff ff       	call   f0100086 <_panic>
f0101218:	8d 53 01             	lea    0x1(%ebx),%edx
f010121b:	39 de                	cmp    %ebx,%esi
f010121d:	72 06                	jb     f0101225 <page_init+0x141>
f010121f:	89 d8                	mov    %ebx,%eax
f0101221:	89 d3                	mov    %edx,%ebx
f0101223:	eb 8d                	jmp    f01011b2 <page_init+0xce>
							//这里要使用boot_freemem的物理地址,这个bug在做lab3时才发现
		pages[i].pp_ref=1;
		LIST_REMOVE(&pages[i],pp_link);
	}
}
f0101225:	83 c4 10             	add    $0x10,%esp
f0101228:	5b                   	pop    %ebx
f0101229:	5e                   	pop    %esi
f010122a:	5d                   	pop    %ebp
f010122b:	c3                   	ret    

f010122c <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_boot_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f010122c:	55                   	push   %ebp
f010122d:	89 e5                	mov    %esp,%ebp
f010122f:	83 ec 18             	sub    $0x18,%esp
f0101232:	89 d1                	mov    %edx,%ecx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0101234:	c1 ea 16             	shr    $0x16,%edx
f0101237:	8b 04 90             	mov    (%eax,%edx,4),%eax
f010123a:	a8 01                	test   $0x1,%al
f010123c:	74 51                	je     f010128f <check_va2pa+0x63>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f010123e:	89 c2                	mov    %eax,%edx
f0101240:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101246:	89 d0                	mov    %edx,%eax
f0101248:	c1 e8 0c             	shr    $0xc,%eax
f010124b:	3b 05 f0 54 29 f0    	cmp    0xf02954f0,%eax
f0101251:	72 20                	jb     f0101273 <check_va2pa+0x47>
f0101253:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101257:	c7 44 24 08 e8 ac 10 	movl   $0xf010ace8,0x8(%esp)
f010125e:	f0 
f010125f:	c7 44 24 04 b4 01 00 	movl   $0x1b4,0x4(%esp)
f0101266:	00 
f0101267:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f010126e:	e8 13 ee ff ff       	call   f0100086 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0101273:	89 c8                	mov    %ecx,%eax
f0101275:	c1 e8 0c             	shr    $0xc,%eax
f0101278:	25 ff 03 00 00       	and    $0x3ff,%eax
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f010127d:	8b 84 82 00 00 00 f0 	mov    -0x10000000(%edx,%eax,4),%eax
	if (!(p[PTX(va)] & PTE_P))
f0101284:	a8 01                	test   $0x1,%al
f0101286:	74 07                	je     f010128f <check_va2pa+0x63>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0101288:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010128d:	eb 05                	jmp    f0101294 <check_va2pa+0x68>
f010128f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0101294:	c9                   	leave  
f0101295:	c3                   	ret    

f0101296 <page_alloc>:
//   -E_NO_MEM -- otherwise 
//
// Hint: use LIST_FIRST, LIST_REMOVE, and page_initpp
int
page_alloc(struct Page **pp_store)
{
f0101296:	55                   	push   %ebp
f0101297:	89 e5                	mov    %esp,%ebp
f0101299:	53                   	push   %ebx
f010129a:	83 ec 14             	sub    $0x14,%esp
f010129d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// Fill this function in
	if(!LIST_EMPTY(&page_free_list)){
f01012a0:	8b 15 38 45 29 f0    	mov    0xf0294538,%edx
f01012a6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01012ab:	85 d2                	test   %edx,%edx
f01012ad:	74 36                	je     f01012e5 <page_alloc+0x4f>
		*pp_store=(struct Page*)LIST_FIRST(&page_free_list);
f01012af:	89 13                	mov    %edx,(%ebx)
		LIST_REMOVE(*pp_store,pp_link);
f01012b1:	8b 0a                	mov    (%edx),%ecx
f01012b3:	85 c9                	test   %ecx,%ecx
f01012b5:	74 06                	je     f01012bd <page_alloc+0x27>
f01012b7:	8b 42 04             	mov    0x4(%edx),%eax
f01012ba:	89 41 04             	mov    %eax,0x4(%ecx)
f01012bd:	8b 03                	mov    (%ebx),%eax
f01012bf:	8b 50 04             	mov    0x4(%eax),%edx
f01012c2:	8b 00                	mov    (%eax),%eax
f01012c4:	89 02                	mov    %eax,(%edx)
// Note that the corresponding physical page is NOT initialized!
//
static void
page_initpp(struct Page *pp)
{
	memset(pp, 0, sizeof(*pp));
f01012c6:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f01012cd:	00 
f01012ce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01012d5:	00 
f01012d6:	8b 03                	mov    (%ebx),%eax
f01012d8:	89 04 24             	mov    %eax,(%esp)
f01012db:	e8 fe 83 00 00       	call   f01096de <memset>
f01012e0:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
	}
	else
		return -E_NO_MEM;
	return -E_NO_MEM;
}
f01012e5:	83 c4 14             	add    $0x14,%esp
f01012e8:	5b                   	pop    %ebx
f01012e9:	5d                   	pop    %ebp
f01012ea:	c3                   	ret    

f01012eb <pgdir_walk>:
// Hint 2: the x86 MMU checks permission bits in both the page directory
// and the page table, so it's safe to leave permissions in the page
// more permissive than strictly necessary.
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01012eb:	55                   	push   %ebp
f01012ec:	89 e5                	mov    %esp,%ebp
f01012ee:	83 ec 38             	sub    $0x38,%esp
f01012f1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01012f4:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01012f7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// Fill this function in
	pde_t *pde;
	pte_t *pgtab;
	pte_t *pp_store;
	struct Page *pgfortab;
	pde = &pgdir[PDX(va)];
f01012fa:	8b 75 0c             	mov    0xc(%ebp),%esi
f01012fd:	89 f0                	mov    %esi,%eax
f01012ff:	c1 e8 16             	shr    $0x16,%eax
f0101302:	c1 e0 02             	shl    $0x2,%eax
f0101305:	89 c7                	mov    %eax,%edi
f0101307:	03 7d 08             	add    0x8(%ebp),%edi

	//看一下对应的页表是否存在
	if(*pde & PTE_P){
f010130a:	8b 07                	mov    (%edi),%eax
f010130c:	a8 01                	test   $0x1,%al
f010130e:	74 3f                	je     f010134f <pgdir_walk+0x64>
		pgtab = (pte_t*)KADDR(PTE_ADDR(*pde));//存在对应页表,访问页表需要用虚拟地址
f0101310:	89 c2                	mov    %eax,%edx
f0101312:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101318:	89 d0                	mov    %edx,%eax
f010131a:	c1 e8 0c             	shr    $0xc,%eax
f010131d:	8d 9a 00 00 00 f0    	lea    -0x10000000(%edx),%ebx
f0101323:	3b 05 f0 54 29 f0    	cmp    0xf02954f0,%eax
f0101329:	0f 82 dc 00 00 00    	jb     f010140b <pgdir_walk+0x120>
f010132f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101333:	c7 44 24 08 e8 ac 10 	movl   $0xf010ace8,0x8(%esp)
f010133a:	f0 
f010133b:	c7 44 24 04 46 02 00 	movl   $0x246,0x4(%esp)
f0101342:	00 
f0101343:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f010134a:	e8 37 ed ff ff       	call   f0100086 <_panic>
	}else{//create==0或者分配页面失败,返回NULL
		if(!create)
f010134f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101353:	0f 84 c0 00 00 00    	je     f0101419 <pgdir_walk+0x12e>
			return NULL;
		if(page_alloc(&pgfortab)<0)
f0101359:	8d 45 f0             	lea    -0x10(%ebp),%eax
f010135c:	89 04 24             	mov    %eax,(%esp)
f010135f:	e8 32 ff ff ff       	call   f0101296 <page_alloc>
f0101364:	85 c0                	test   %eax,%eax
f0101366:	0f 88 ad 00 00 00    	js     f0101419 <pgdir_walk+0x12e>
			return NULL;
		pgfortab->pp_ref=1;//设置引用标志为1,这个页做为了页表
f010136c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010136f:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101375:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101378:	2b 05 fc 54 29 f0    	sub    0xf02954fc,%eax
f010137e:	c1 f8 02             	sar    $0x2,%eax
f0101381:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101387:	89 c2                	mov    %eax,%edx
f0101389:	c1 e2 0c             	shl    $0xc,%edx
		//cprintf("welcome to pgdir_walk:va=%x pgfortab=%x\n",va,KADDR(page2pa(pgfortab)));
		pgtab = (pte_t*)KADDR(page2pa(pgfortab));//获取页面物理地址,访问页表要用虚拟地址
f010138c:	89 d0                	mov    %edx,%eax
f010138e:	c1 e8 0c             	shr    $0xc,%eax
f0101391:	3b 05 f0 54 29 f0    	cmp    0xf02954f0,%eax
f0101397:	72 20                	jb     f01013b9 <pgdir_walk+0xce>
f0101399:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010139d:	c7 44 24 08 e8 ac 10 	movl   $0xf010ace8,0x8(%esp)
f01013a4:	f0 
f01013a5:	c7 44 24 04 4e 02 00 	movl   $0x24e,0x4(%esp)
f01013ac:	00 
f01013ad:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f01013b4:	e8 cd ec ff ff       	call   f0100086 <_panic>
f01013b9:	8d 9a 00 00 00 f0    	lea    -0x10000000(%edx),%ebx
		
		memset(pgtab,0,PGSIZE);
f01013bf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01013c6:	00 
f01013c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01013ce:	00 
f01013cf:	89 1c 24             	mov    %ebx,(%esp)
f01013d2:	e8 07 83 00 00       	call   f01096de <memset>
		*pde = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;//填写相应页目录项,需要填写相应物理地址
f01013d7:	89 d8                	mov    %ebx,%eax
f01013d9:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01013df:	77 20                	ja     f0101401 <pgdir_walk+0x116>
f01013e1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01013e5:	c7 44 24 08 6c b0 10 	movl   $0xf010b06c,0x8(%esp)
f01013ec:	f0 
f01013ed:	c7 44 24 04 51 02 00 	movl   $0x251,0x4(%esp)
f01013f4:	00 
f01013f5:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f01013fc:	e8 85 ec ff ff       	call   f0100086 <_panic>
f0101401:	05 00 00 00 10       	add    $0x10000000,%eax
f0101406:	83 c8 07             	or     $0x7,%eax
f0101409:	89 07                	mov    %eax,(%edi)
		//cprintf("pde=%x *pde=%x &pgtab[PTX(va)]=%x\n",&pgdir[PDX(va)],pgdir[PDX(va)],&pgtab[PTX(va)]);
	}
	pp_store=&pgtab[PTX(va)];
f010140b:	89 f0                	mov    %esi,%eax
f010140d:	c1 e8 0a             	shr    $0xa,%eax
f0101410:	25 fc 0f 00 00       	and    $0xffc,%eax
f0101415:	01 d8                	add    %ebx,%eax
f0101417:	eb 05                	jmp    f010141e <pgdir_walk+0x133>
	return pp_store;
f0101419:	b8 00 00 00 00       	mov    $0x0,%eax
	//return NULL;
}
f010141e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101421:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101424:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101427:	89 ec                	mov    %ebp,%esp
f0101429:	5d                   	pop    %ebp
f010142a:	c3                   	ret    

f010142b <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010142b:	55                   	push   %ebp
f010142c:	89 e5                	mov    %esp,%ebp
f010142e:	53                   	push   %ebx
f010142f:	83 ec 14             	sub    $0x14,%esp
f0101432:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	struct Page *pageforva;
	pte_t *pte;
	if(!(pte=pgdir_walk(pgdir,va,0)))
f0101435:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010143c:	00 
f010143d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101440:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101444:	8b 45 08             	mov    0x8(%ebp),%eax
f0101447:	89 04 24             	mov    %eax,(%esp)
f010144a:	e8 9c fe ff ff       	call   f01012eb <pgdir_walk>
f010144f:	89 c2                	mov    %eax,%edx
f0101451:	b8 00 00 00 00       	mov    $0x0,%eax
f0101456:	85 d2                	test   %edx,%edx
f0101458:	74 40                	je     f010149a <page_lookup+0x6f>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f010145a:	8b 02                	mov    (%edx),%eax
f010145c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101461:	c1 e8 0c             	shr    $0xc,%eax
f0101464:	3b 05 f0 54 29 f0    	cmp    0xf02954f0,%eax
f010146a:	72 1c                	jb     f0101488 <page_lookup+0x5d>
		panic("pa2page called with invalid pa");
f010146c:	c7 44 24 08 90 b0 10 	movl   $0xf010b090,0x8(%esp)
f0101473:	f0 
f0101474:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f010147b:	00 
f010147c:	c7 04 24 6f b6 10 f0 	movl   $0xf010b66f,(%esp)
f0101483:	e8 fe eb ff ff       	call   f0100086 <_panic>
	return &pages[PPN(pa)];
f0101488:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010148b:	c1 e0 02             	shl    $0x2,%eax
f010148e:	03 05 fc 54 29 f0    	add    0xf02954fc,%eax
		return NULL;
	else{
		pageforva=pa2page(PTE_ADDR(*pte));

		if(pte_store)//这个地方传递pte容易错，小心编写
f0101494:	85 db                	test   %ebx,%ebx
f0101496:	74 02                	je     f010149a <page_lookup+0x6f>
			*pte_store=pte;
f0101498:	89 13                	mov    %edx,(%ebx)
	}
	return pageforva;
	//return NULL;
}
f010149a:	83 c4 14             	add    $0x14,%esp
f010149d:	5b                   	pop    %ebx
f010149e:	5d                   	pop    %ebp
f010149f:	c3                   	ret    

f01014a0 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01014a0:	55                   	push   %ebp
f01014a1:	89 e5                	mov    %esp,%ebp
f01014a3:	57                   	push   %edi
f01014a4:	56                   	push   %esi
f01014a5:	53                   	push   %ebx
f01014a6:	83 ec 1c             	sub    $0x1c,%esp
f01014a9:	8b 45 0c             	mov    0xc(%ebp),%eax
	// LAB 3: Your code here.
	uintptr_t a,last;
	pte_t *pte;
	struct Page *onepage;
	a=(uintptr_t)va;
	user_mem_check_addr=a;
f01014ac:	a3 3c 45 29 f0       	mov    %eax,0xf029453c
	a=ROUNDDOWN(a,PGSIZE);
f01014b1:	89 c3                	mov    %eax,%ebx
f01014b3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	last=ROUNDDOWN(a+len,PGSIZE);
f01014b9:	89 d8                	mov    %ebx,%eax
f01014bb:	03 45 10             	add    0x10(%ebp),%eax
f01014be:	89 c6                	mov    %eax,%esi
f01014c0:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
			if((user_mem_check_addr&0xfffff000)!=a)
				user_mem_check_addr=a;
			return -E_FAULT;
		}
		else{
			if(!(onepage=page_lookup(env->env_pgdir,(void *)a,&pte)))
f01014c6:	8d 7d f0             	lea    -0x10(%ebp),%edi
	a=(uintptr_t)va;
	user_mem_check_addr=a;
	a=ROUNDDOWN(a,PGSIZE);
	last=ROUNDDOWN(a+len,PGSIZE);
	for(;;){
		if(a>=ULIM) {
f01014c9:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01014cf:	76 27                	jbe    f01014f8 <user_mem_check+0x58>
f01014d1:	e9 9c 00 00 00       	jmp    f0101572 <user_mem_check+0xd2>
			if((user_mem_check_addr&0xfffff000)!=a)
f01014d6:	a1 3c 45 29 f0       	mov    0xf029453c,%eax
f01014db:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01014e0:	39 d8                	cmp    %ebx,%eax
f01014e2:	0f 84 8a 00 00 00    	je     f0101572 <user_mem_check+0xd2>
				user_mem_check_addr=a;
f01014e8:	89 1d 3c 45 29 f0    	mov    %ebx,0xf029453c
f01014ee:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01014f3:	e9 7f 00 00 00       	jmp    f0101577 <user_mem_check+0xd7>
			return -E_FAULT;
		}
		else{
			if(!(onepage=page_lookup(env->env_pgdir,(void *)a,&pte)))
f01014f8:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01014fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101500:	8b 55 08             	mov    0x8(%ebp),%edx
f0101503:	8b 42 5c             	mov    0x5c(%edx),%eax
f0101506:	89 04 24             	mov    %eax,(%esp)
f0101509:	e8 1d ff ff ff       	call   f010142b <page_lookup>
f010150e:	85 c0                	test   %eax,%eax
f0101510:	75 1b                	jne    f010152d <user_mem_check+0x8d>
			{	
				if((user_mem_check_addr&0xfffff000)!=a)
f0101512:	a1 3c 45 29 f0       	mov    0xf029453c,%eax
f0101517:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010151c:	39 d8                	cmp    %ebx,%eax
f010151e:	74 52                	je     f0101572 <user_mem_check+0xd2>
                                	user_mem_check_addr=a;
f0101520:	89 1d 3c 45 29 f0    	mov    %ebx,0xf029453c
f0101526:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010152b:	eb 4a                	jmp    f0101577 <user_mem_check+0xd7>
				return -E_FAULT;
			}
			if(!(*pte&perm))
f010152d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101530:	8b 55 14             	mov    0x14(%ebp),%edx
f0101533:	85 10                	test   %edx,(%eax)
f0101535:	75 1b                	jne    f0101552 <user_mem_check+0xb2>
			{
				if((user_mem_check_addr&0xfffff000)!=a)
f0101537:	a1 3c 45 29 f0       	mov    0xf029453c,%eax
f010153c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101541:	39 d8                	cmp    %ebx,%eax
f0101543:	74 2d                	je     f0101572 <user_mem_check+0xd2>
                                	user_mem_check_addr=a;
f0101545:	89 1d 3c 45 29 f0    	mov    %ebx,0xf029453c
f010154b:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0101550:	eb 25                	jmp    f0101577 <user_mem_check+0xd7>
				return -E_FAULT;
			}
			
			
		}
		if(a==last) 
f0101552:	39 f3                	cmp    %esi,%ebx
f0101554:	74 14                	je     f010156a <user_mem_check+0xca>
			break;	
		a+=PGSIZE;
f0101556:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	a=(uintptr_t)va;
	user_mem_check_addr=a;
	a=ROUNDDOWN(a,PGSIZE);
	last=ROUNDDOWN(a+len,PGSIZE);
	for(;;){
		if(a>=ULIM) {
f010155c:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101562:	0f 87 6e ff ff ff    	ja     f01014d6 <user_mem_check+0x36>
f0101568:	eb 8e                	jmp    f01014f8 <user_mem_check+0x58>
f010156a:	b8 00 00 00 00       	mov    $0x0,%eax
f010156f:	90                   	nop    
f0101570:	eb 05                	jmp    f0101577 <user_mem_check+0xd7>
f0101572:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
		if(a==last) 
			break;	
		a+=PGSIZE;
	}		
	return 0; 
}
f0101577:	83 c4 1c             	add    $0x1c,%esp
f010157a:	5b                   	pop    %ebx
f010157b:	5e                   	pop    %esi
f010157c:	5f                   	pop    %edi
f010157d:	5d                   	pop    %ebp
f010157e:	c3                   	ret    

f010157f <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f010157f:	55                   	push   %ebp
f0101580:	89 e5                	mov    %esp,%ebp
f0101582:	53                   	push   %ebx
f0101583:	83 ec 14             	sub    $0x14,%esp
f0101586:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0101589:	8b 45 14             	mov    0x14(%ebp),%eax
f010158c:	83 c8 04             	or     $0x4,%eax
f010158f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101593:	8b 45 10             	mov    0x10(%ebp),%eax
f0101596:	89 44 24 08          	mov    %eax,0x8(%esp)
f010159a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010159d:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015a1:	89 1c 24             	mov    %ebx,(%esp)
f01015a4:	e8 f7 fe ff ff       	call   f01014a0 <user_mem_check>
f01015a9:	85 c0                	test   %eax,%eax
f01015ab:	79 24                	jns    f01015d1 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f01015ad:	a1 3c 45 29 f0       	mov    0xf029453c,%eax
f01015b2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01015b6:	8b 43 4c             	mov    0x4c(%ebx),%eax
f01015b9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015bd:	c7 04 24 b0 b0 10 f0 	movl   $0xf010b0b0,(%esp)
f01015c4:	e8 1e 24 00 00       	call   f01039e7 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01015c9:	89 1c 24             	mov    %ebx,(%esp)
f01015cc:	e8 35 22 00 00       	call   f0103806 <env_destroy>
	}
}
f01015d1:	83 c4 14             	add    $0x14,%esp
f01015d4:	5b                   	pop    %ebx
f01015d5:	5d                   	pop    %ebp
f01015d6:	c3                   	ret    

f01015d7 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01015d7:	55                   	push   %ebp
f01015d8:	89 e5                	mov    %esp,%ebp
f01015da:	83 ec 28             	sub    $0x28,%esp
f01015dd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01015e0:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01015e3:	8b 75 08             	mov    0x8(%ebp),%esi
f01015e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	struct Page *pageforva;
	pte_t *pte=NULL;
f01015e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	if((pageforva=page_lookup(pgdir,va,&pte))){
f01015f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01015f3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01015f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01015fb:	89 34 24             	mov    %esi,(%esp)
f01015fe:	e8 28 fe ff ff       	call   f010142b <page_lookup>
f0101603:	85 c0                	test   %eax,%eax
f0101605:	74 21                	je     f0101628 <page_remove+0x51>
		page_decref(pageforva);
f0101607:	89 04 24             	mov    %eax,(%esp)
f010160a:	e8 96 fa ff ff       	call   f01010a5 <page_decref>

		if(pte)
f010160f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101612:	85 c0                	test   %eax,%eax
f0101614:	74 06                	je     f010161c <page_remove+0x45>
			*pte=0;
f0101616:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir,va);
f010161c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101620:	89 34 24             	mov    %esi,(%esp)
f0101623:	e8 a0 fa ff ff       	call   f01010c8 <tlb_invalidate>
	}
}
f0101628:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f010162b:	8b 75 fc             	mov    -0x4(%ebp),%esi
f010162e:	89 ec                	mov    %ebp,%esp
f0101630:	5d                   	pop    %ebp
f0101631:	c3                   	ret    

f0101632 <boot_map_segment>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
{
f0101632:	55                   	push   %ebp
f0101633:	89 e5                	mov    %esp,%ebp
f0101635:	57                   	push   %edi
f0101636:	56                   	push   %esi
f0101637:	53                   	push   %ebx
f0101638:	83 ec 1c             	sub    $0x1c,%esp
f010163b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010163e:	8b 75 08             	mov    0x8(%ebp),%esi
	// Fill this function in
	uintptr_t a,last;
	pte_t *pte;
	//cprintf("----------------------------\n");
	a=ROUNDDOWN(la,PGSIZE);
f0101641:	89 d3                	mov    %edx,%ebx
f0101643:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	last=ROUNDDOWN(la+size-1,PGSIZE);//这个地方要小心编写,防止重映射
f0101649:	8d 54 0a ff          	lea    -0x1(%edx,%ecx,1),%edx
f010164d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101653:	89 55 f0             	mov    %edx,-0x10(%ebp)
		pte = pgdir_walk(pgdir,(void *)a,1);
		if(pte==NULL)
			return;
		if(*pte&PTE_P)
			panic("remap");
		*pte=pa | perm | PTE_P;
f0101656:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101659:	83 cf 01             	or     $0x1,%edi
	//cprintf("----------------------------\n");
	a=ROUNDDOWN(la,PGSIZE);
	last=ROUNDDOWN(la+size-1,PGSIZE);//这个地方要小心编写,防止重映射
	//cprintf("\nlast=%x\n",last);
	for(;;){
		pte = pgdir_walk(pgdir,(void *)a,1);
f010165c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101663:	00 
f0101664:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101668:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010166b:	89 04 24             	mov    %eax,(%esp)
f010166e:	e8 78 fc ff ff       	call   f01012eb <pgdir_walk>
f0101673:	89 c2                	mov    %eax,%edx
		if(pte==NULL)
f0101675:	85 c0                	test   %eax,%eax
f0101677:	74 3a                	je     f01016b3 <boot_map_segment+0x81>
			return;
		if(*pte&PTE_P)
f0101679:	f6 00 01             	testb  $0x1,(%eax)
f010167c:	74 1c                	je     f010169a <boot_map_segment+0x68>
			panic("remap");
f010167e:	c7 44 24 08 7d b6 10 	movl   $0xf010b67d,0x8(%esp)
f0101685:	f0 
f0101686:	c7 44 24 04 9f 02 00 	movl   $0x29f,0x4(%esp)
f010168d:	00 
f010168e:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101695:	e8 ec e9 ff ff       	call   f0100086 <_panic>
		*pte=pa | perm | PTE_P;
f010169a:	89 f8                	mov    %edi,%eax
f010169c:	09 f0                	or     %esi,%eax
f010169e:	89 02                	mov    %eax,(%edx)
		//if(a==0xf0400000)
		//	cprintf("a=%x *pte=%x\n",a,*pte);
		//if(a>=KERNBASE)
		//	cprintf("a=%x *pte=%x ********",a,*pte);
		if(a==last)
f01016a0:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01016a3:	74 0e                	je     f01016b3 <boot_map_segment+0x81>
			break;
		a+=PGSIZE;
f01016a5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		pa+=PGSIZE;
f01016ab:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01016b1:	eb a9                	jmp    f010165c <boot_map_segment+0x2a>
	}
	return;
}
f01016b3:	83 c4 1c             	add    $0x1c,%esp
f01016b6:	5b                   	pop    %ebx
f01016b7:	5e                   	pop    %esi
f01016b8:	5f                   	pop    %edi
f01016b9:	5d                   	pop    %ebp
f01016ba:	c3                   	ret    

f01016bb <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm) 
{
f01016bb:	55                   	push   %ebp
f01016bc:	89 e5                	mov    %esp,%ebp
f01016be:	83 ec 18             	sub    $0x18,%esp
f01016c1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01016c4:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01016c7:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01016ca:	8b 75 0c             	mov    0xc(%ebp),%esi
f01016cd:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *pte;
	if(!(pte=pgdir_walk(pgdir, va, 1)))//查找或创建虚拟地址va对应的页表项pte
f01016d0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01016d7:	00 
f01016d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01016dc:	8b 45 08             	mov    0x8(%ebp),%eax
f01016df:	89 04 24             	mov    %eax,(%esp)
f01016e2:	e8 04 fc ff ff       	call   f01012eb <pgdir_walk>
f01016e7:	89 c3                	mov    %eax,%ebx
f01016e9:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01016ee:	85 db                	test   %ebx,%ebx
f01016f0:	74 73                	je     f0101765 <page_insert+0xaa>
		return -E_NO_MEM;
	else{
		if(*pte&PTE_P){//对应va的实际物理页面存在
f01016f2:	8b 03                	mov    (%ebx),%eax
f01016f4:	a8 01                	test   $0x1,%al
f01016f6:	74 36                	je     f010172e <page_insert+0x73>
			if(PTE_ADDR(*pte)!=page2pa(pp))//va指向了不同的物理页面
f01016f8:	89 c2                	mov    %eax,%edx
f01016fa:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101700:	89 f0                	mov    %esi,%eax
f0101702:	2b 05 fc 54 29 f0    	sub    0xf02954fc,%eax
f0101708:	c1 f8 02             	sar    $0x2,%eax
f010170b:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101711:	c1 e0 0c             	shl    $0xc,%eax
f0101714:	39 c2                	cmp    %eax,%edx
f0101716:	74 11                	je     f0101729 <page_insert+0x6e>
				page_remove(pgdir,va);
f0101718:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010171c:	8b 45 08             	mov    0x8(%ebp),%eax
f010171f:	89 04 24             	mov    %eax,(%esp)
f0101722:	e8 b0 fe ff ff       	call   f01015d7 <page_remove>
f0101727:	eb 05                	jmp    f010172e <page_insert+0x73>
			else				//va指向了需要分配的物理页面
				pp->pp_ref--;
f0101729:	66 83 6e 08 01       	subw   $0x1,0x8(%esi)
		}
		*pte = page2pa(pp) | perm | PTE_P;//填写页表项
f010172e:	8b 55 14             	mov    0x14(%ebp),%edx
f0101731:	83 ca 01             	or     $0x1,%edx
f0101734:	89 f0                	mov    %esi,%eax
f0101736:	2b 05 fc 54 29 f0    	sub    0xf02954fc,%eax
f010173c:	c1 f8 02             	sar    $0x2,%eax
f010173f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101745:	c1 e0 0c             	shl    $0xc,%eax
f0101748:	09 c2                	or     %eax,%edx
f010174a:	89 13                	mov    %edx,(%ebx)
		//cprintf("pte=%x *pte=%x\n",pte,*pte);
		pp->pp_ref++;//映射的实际物理页的引用情况
f010174c:	66 83 46 08 01       	addw   $0x1,0x8(%esi)
		tlb_invalidate(pgdir,va);//更新TLB
f0101751:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101755:	8b 45 08             	mov    0x8(%ebp),%eax
f0101758:	89 04 24             	mov    %eax,(%esp)
f010175b:	e8 68 f9 ff ff       	call   f01010c8 <tlb_invalidate>
f0101760:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
	}
	//return 0;
}
f0101765:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101768:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010176b:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010176e:	89 ec                	mov    %ebp,%esp
f0101770:	5d                   	pop    %ebp
f0101771:	c3                   	ret    

f0101772 <nvram_read>:
	sizeof(gdt) - 1, (unsigned long) gdt
};

static int
nvram_read(int r)
{
f0101772:	55                   	push   %ebp
f0101773:	89 e5                	mov    %esp,%ebp
f0101775:	83 ec 18             	sub    $0x18,%esp
f0101778:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f010177b:	89 75 fc             	mov    %esi,-0x4(%ebp)
f010177e:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101780:	89 04 24             	mov    %eax,(%esp)
f0101783:	e8 b0 20 00 00       	call   f0103838 <mc146818_read>
f0101788:	89 c3                	mov    %eax,%ebx
f010178a:	8d 46 01             	lea    0x1(%esi),%eax
f010178d:	89 04 24             	mov    %eax,(%esp)
f0101790:	e8 a3 20 00 00       	call   f0103838 <mc146818_read>
f0101795:	c1 e0 08             	shl    $0x8,%eax
f0101798:	09 d8                	or     %ebx,%eax
}
f010179a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f010179d:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01017a0:	89 ec                	mov    %ebp,%esp
f01017a2:	5d                   	pop    %ebp
f01017a3:	c3                   	ret    

f01017a4 <i386_detect_memory>:

void
i386_detect_memory(void)
{
f01017a4:	55                   	push   %ebp
f01017a5:	89 e5                	mov    %esp,%ebp
f01017a7:	83 ec 18             	sub    $0x18,%esp
	// CMOS tells us how many kilobytes there are
	basemem = ROUNDDOWN(nvram_read(NVRAM_BASELO)*1024, PGSIZE);
f01017aa:	b8 15 00 00 00       	mov    $0x15,%eax
f01017af:	e8 be ff ff ff       	call   f0101772 <nvram_read>
f01017b4:	c1 e0 0a             	shl    $0xa,%eax
f01017b7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01017bc:	a3 2c 45 29 f0       	mov    %eax,0xf029452c
	extmem = ROUNDDOWN(nvram_read(NVRAM_EXTLO)*1024, PGSIZE);
f01017c1:	b8 17 00 00 00       	mov    $0x17,%eax
f01017c6:	e8 a7 ff ff ff       	call   f0101772 <nvram_read>
f01017cb:	c1 e0 0a             	shl    $0xa,%eax
f01017ce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01017d3:	a3 30 45 29 f0       	mov    %eax,0xf0294530

	// Calculate the maximum physical address based on whether
	// or not there is any extended memory.  See comment in <inc/mmu.h>.
	if (extmem)
f01017d8:	85 c0                	test   %eax,%eax
f01017da:	74 0c                	je     f01017e8 <i386_detect_memory+0x44>
		maxpa = EXTPHYSMEM + extmem;
f01017dc:	05 00 00 10 00       	add    $0x100000,%eax
f01017e1:	a3 28 45 29 f0       	mov    %eax,0xf0294528
f01017e6:	eb 0a                	jmp    f01017f2 <i386_detect_memory+0x4e>
	else
		maxpa = basemem;
f01017e8:	a1 2c 45 29 f0       	mov    0xf029452c,%eax
f01017ed:	a3 28 45 29 f0       	mov    %eax,0xf0294528

	npage = maxpa / PGSIZE;
f01017f2:	a1 28 45 29 f0       	mov    0xf0294528,%eax
f01017f7:	89 c2                	mov    %eax,%edx
f01017f9:	c1 ea 0c             	shr    $0xc,%edx
f01017fc:	89 15 f0 54 29 f0    	mov    %edx,0xf02954f0

	cprintf("Physical memory: %dK available, ", (int)(maxpa/1024));
f0101802:	c1 e8 0a             	shr    $0xa,%eax
f0101805:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101809:	c7 04 24 e8 b0 10 f0 	movl   $0xf010b0e8,(%esp)
f0101810:	e8 d2 21 00 00       	call   f01039e7 <cprintf>
	cprintf("base = %dK, extended = %dK\n", (int)(basemem/1024), (int)(extmem/1024));
f0101815:	a1 30 45 29 f0       	mov    0xf0294530,%eax
f010181a:	c1 e8 0a             	shr    $0xa,%eax
f010181d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101821:	a1 2c 45 29 f0       	mov    0xf029452c,%eax
f0101826:	c1 e8 0a             	shr    $0xa,%eax
f0101829:	89 44 24 04          	mov    %eax,0x4(%esp)
f010182d:	c7 04 24 83 b6 10 f0 	movl   $0xf010b683,(%esp)
f0101834:	e8 ae 21 00 00       	call   f01039e7 <cprintf>
}
f0101839:	c9                   	leave  
f010183a:	c3                   	ret    

f010183b <check_page_alloc>:
// Check the physical page allocator (page_alloc(), page_free(),
// and page_init()).
//
static void
check_page_alloc()
{
f010183b:	55                   	push   %ebp
f010183c:	89 e5                	mov    %esp,%ebp
f010183e:	57                   	push   %edi
f010183f:	56                   	push   %esi
f0101840:	53                   	push   %ebx
f0101841:	83 ec 2c             	sub    $0x2c,%esp
	struct Page_list fl;

	// if there's a page that shouldn't be on
	// the free list, try to make sure it
	// eventually causes trouble.
	LIST_FOREACH(pp0, &page_free_list, pp_link)
f0101844:	a1 38 45 29 f0       	mov    0xf0294538,%eax
f0101849:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010184c:	85 c0                	test   %eax,%eax
f010184e:	0f 84 41 02 00 00    	je     f0101a95 <check_page_alloc+0x25a>
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101854:	2b 05 fc 54 29 f0    	sub    0xf02954fc,%eax
f010185a:	c1 f8 02             	sar    $0x2,%eax
f010185d:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101863:	89 c2                	mov    %eax,%edx
f0101865:	c1 e2 0c             	shl    $0xc,%edx
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0101868:	89 d0                	mov    %edx,%eax
f010186a:	c1 e8 0c             	shr    $0xc,%eax
f010186d:	39 05 f0 54 29 f0    	cmp    %eax,0xf02954f0
f0101873:	77 43                	ja     f01018b8 <check_page_alloc+0x7d>
f0101875:	eb 21                	jmp    f0101898 <check_page_alloc+0x5d>
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101877:	2b 05 fc 54 29 f0    	sub    0xf02954fc,%eax
f010187d:	c1 f8 02             	sar    $0x2,%eax
f0101880:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101886:	89 c2                	mov    %eax,%edx
f0101888:	c1 e2 0c             	shl    $0xc,%edx
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f010188b:	89 d0                	mov    %edx,%eax
f010188d:	c1 e8 0c             	shr    $0xc,%eax
f0101890:	3b 05 f0 54 29 f0    	cmp    0xf02954f0,%eax
f0101896:	72 20                	jb     f01018b8 <check_page_alloc+0x7d>
f0101898:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010189c:	c7 44 24 08 e8 ac 10 	movl   $0xf010ace8,0x8(%esp)
f01018a3:	f0 
f01018a4:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f01018ab:	00 
f01018ac:	c7 04 24 6f b6 10 f0 	movl   $0xf010b66f,(%esp)
f01018b3:	e8 ce e7 ff ff       	call   f0100086 <_panic>
		memset(page2kva(pp0), 0x97, 128);
f01018b8:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f01018bf:	00 
f01018c0:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f01018c7:	00 
f01018c8:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01018ce:	89 04 24             	mov    %eax,(%esp)
f01018d1:	e8 08 7e 00 00       	call   f01096de <memset>
	struct Page_list fl;

	// if there's a page that shouldn't be on
	// the free list, try to make sure it
	// eventually causes trouble.
	LIST_FOREACH(pp0, &page_free_list, pp_link)
f01018d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01018d9:	8b 00                	mov    (%eax),%eax
f01018db:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01018de:	85 c0                	test   %eax,%eax
f01018e0:	75 95                	jne    f0101877 <check_page_alloc+0x3c>
		memset(page2kva(pp0), 0x97, 128);

	LIST_FOREACH(pp0, &page_free_list, pp_link) {
f01018e2:	8b 0d 38 45 29 f0    	mov    0xf0294538,%ecx
f01018e8:	89 4d ec             	mov    %ecx,-0x14(%ebp)
f01018eb:	85 c9                	test   %ecx,%ecx
f01018ed:	0f 84 a2 01 00 00    	je     f0101a95 <check_page_alloc+0x25a>
		// check that we didn't corrupt the free list itself
		assert(pp0 >= pages);
f01018f3:	8b 1d fc 54 29 f0    	mov    0xf02954fc,%ebx
f01018f9:	39 d9                	cmp    %ebx,%ecx
f01018fb:	72 19                	jb     f0101916 <check_page_alloc+0xdb>
		assert(pp0 < pages + npage);
f01018fd:	8b 35 f0 54 29 f0    	mov    0xf02954f0,%esi
f0101903:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0101906:	8d 04 83             	lea    (%ebx,%eax,4),%eax
f0101909:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010190c:	39 c1                	cmp    %eax,%ecx
f010190e:	72 53                	jb     f0101963 <check_page_alloc+0x128>
f0101910:	eb 2d                	jmp    f010193f <check_page_alloc+0x104>
	LIST_FOREACH(pp0, &page_free_list, pp_link)
		memset(page2kva(pp0), 0x97, 128);

	LIST_FOREACH(pp0, &page_free_list, pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp0 >= pages);
f0101912:	39 cb                	cmp    %ecx,%ebx
f0101914:	76 24                	jbe    f010193a <check_page_alloc+0xff>
f0101916:	c7 44 24 0c 9f b6 10 	movl   $0xf010b69f,0xc(%esp)
f010191d:	f0 
f010191e:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0101925:	f0 
f0101926:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
f010192d:	00 
f010192e:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101935:	e8 4c e7 ff ff       	call   f0100086 <_panic>
		assert(pp0 < pages + npage);
f010193a:	39 4d e0             	cmp    %ecx,-0x20(%ebp)
f010193d:	77 34                	ja     f0101973 <check_page_alloc+0x138>
f010193f:	c7 44 24 0c c1 b6 10 	movl   $0xf010b6c1,0xc(%esp)
f0101946:	f0 
f0101947:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f010194e:	f0 
f010194f:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
f0101956:	00 
f0101957:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f010195e:	e8 23 e7 ff ff       	call   f0100086 <_panic>
		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp0) != 0);
		assert(page2pa(pp0) != IOPHYSMEM);
		assert(page2pa(pp0) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp0) != EXTPHYSMEM);
		assert(page2kva(pp0) != ROUNDDOWN(boot_freemem - 1, PGSIZE));
f0101963:	a1 34 45 29 f0       	mov    0xf0294534,%eax
f0101968:	83 e8 01             	sub    $0x1,%eax
f010196b:	89 c7                	mov    %eax,%edi
f010196d:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101973:	89 c8                	mov    %ecx,%eax
f0101975:	29 d8                	sub    %ebx,%eax
f0101977:	c1 f8 02             	sar    $0x2,%eax
f010197a:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101980:	89 c2                	mov    %eax,%edx
f0101982:	c1 e2 0c             	shl    $0xc,%edx
		// check that we didn't corrupt the free list itself
		assert(pp0 >= pages);
		assert(pp0 < pages + npage);

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp0) != 0);
f0101985:	85 d2                	test   %edx,%edx
f0101987:	75 24                	jne    f01019ad <check_page_alloc+0x172>
f0101989:	c7 44 24 0c d5 b6 10 	movl   $0xf010b6d5,0xc(%esp)
f0101990:	f0 
f0101991:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0101998:	f0 
f0101999:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
f01019a0:	00 
f01019a1:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f01019a8:	e8 d9 e6 ff ff       	call   f0100086 <_panic>
		assert(page2pa(pp0) != IOPHYSMEM);
f01019ad:	81 fa 00 00 0a 00    	cmp    $0xa0000,%edx
f01019b3:	75 24                	jne    f01019d9 <check_page_alloc+0x19e>
f01019b5:	c7 44 24 0c e7 b6 10 	movl   $0xf010b6e7,0xc(%esp)
f01019bc:	f0 
f01019bd:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f01019c4:	f0 
f01019c5:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
f01019cc:	00 
f01019cd:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f01019d4:	e8 ad e6 ff ff       	call   f0100086 <_panic>
		assert(page2pa(pp0) != EXTPHYSMEM - PGSIZE);
f01019d9:	81 fa 00 f0 0f 00    	cmp    $0xff000,%edx
f01019df:	75 24                	jne    f0101a05 <check_page_alloc+0x1ca>
f01019e1:	c7 44 24 0c 0c b1 10 	movl   $0xf010b10c,0xc(%esp)
f01019e8:	f0 
f01019e9:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f01019f0:	f0 
f01019f1:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
f01019f8:	00 
f01019f9:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101a00:	e8 81 e6 ff ff       	call   f0100086 <_panic>
		assert(page2pa(pp0) != EXTPHYSMEM);
f0101a05:	81 fa 00 00 10 00    	cmp    $0x100000,%edx
f0101a0b:	75 24                	jne    f0101a31 <check_page_alloc+0x1f6>
f0101a0d:	c7 44 24 0c 01 b7 10 	movl   $0xf010b701,0xc(%esp)
f0101a14:	f0 
f0101a15:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0101a1c:	f0 
f0101a1d:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
f0101a24:	00 
f0101a25:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101a2c:	e8 55 e6 ff ff       	call   f0100086 <_panic>
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0101a31:	89 d0                	mov    %edx,%eax
f0101a33:	c1 e8 0c             	shr    $0xc,%eax
f0101a36:	39 c6                	cmp    %eax,%esi
f0101a38:	77 20                	ja     f0101a5a <check_page_alloc+0x21f>
f0101a3a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101a3e:	c7 44 24 08 e8 ac 10 	movl   $0xf010ace8,0x8(%esp)
f0101a45:	f0 
f0101a46:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0101a4d:	00 
f0101a4e:	c7 04 24 6f b6 10 f0 	movl   $0xf010b66f,(%esp)
f0101a55:	e8 2c e6 ff ff       	call   f0100086 <_panic>
f0101a5a:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101a60:	39 f8                	cmp    %edi,%eax
f0101a62:	75 24                	jne    f0101a88 <check_page_alloc+0x24d>
		assert(page2kva(pp0) != ROUNDDOWN(boot_freemem - 1, PGSIZE));
f0101a64:	c7 44 24 0c 30 b1 10 	movl   $0xf010b130,0xc(%esp)
f0101a6b:	f0 
f0101a6c:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0101a73:	f0 
f0101a74:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
f0101a7b:	00 
f0101a7c:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101a83:	e8 fe e5 ff ff       	call   f0100086 <_panic>
	// the free list, try to make sure it
	// eventually causes trouble.
	LIST_FOREACH(pp0, &page_free_list, pp_link)
		memset(page2kva(pp0), 0x97, 128);

	LIST_FOREACH(pp0, &page_free_list, pp_link) {
f0101a88:	8b 09                	mov    (%ecx),%ecx
f0101a8a:	89 4d ec             	mov    %ecx,-0x14(%ebp)
f0101a8d:	85 c9                	test   %ecx,%ecx
f0101a8f:	0f 85 7d fe ff ff    	jne    f0101912 <check_page_alloc+0xd7>
		assert(page2pa(pp0) != EXTPHYSMEM);
		assert(page2kva(pp0) != ROUNDDOWN(boot_freemem - 1, PGSIZE));
	}

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
f0101a95:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0101a9c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f0101aa3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	assert(page_alloc(&pp0) == 0);
f0101aaa:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101aad:	89 04 24             	mov    %eax,(%esp)
f0101ab0:	e8 e1 f7 ff ff       	call   f0101296 <page_alloc>
f0101ab5:	85 c0                	test   %eax,%eax
f0101ab7:	74 24                	je     f0101add <check_page_alloc+0x2a2>
f0101ab9:	c7 44 24 0c 1c b7 10 	movl   $0xf010b71c,0xc(%esp)
f0101ac0:	f0 
f0101ac1:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0101ac8:	f0 
f0101ac9:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
f0101ad0:	00 
f0101ad1:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101ad8:	e8 a9 e5 ff ff       	call   f0100086 <_panic>
	assert(page_alloc(&pp1) == 0);
f0101add:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0101ae0:	89 04 24             	mov    %eax,(%esp)
f0101ae3:	e8 ae f7 ff ff       	call   f0101296 <page_alloc>
f0101ae8:	85 c0                	test   %eax,%eax
f0101aea:	74 24                	je     f0101b10 <check_page_alloc+0x2d5>
f0101aec:	c7 44 24 0c 32 b7 10 	movl   $0xf010b732,0xc(%esp)
f0101af3:	f0 
f0101af4:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0101afb:	f0 
f0101afc:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
f0101b03:	00 
f0101b04:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101b0b:	e8 76 e5 ff ff       	call   f0100086 <_panic>
	assert(page_alloc(&pp2) == 0);
f0101b10:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101b13:	89 04 24             	mov    %eax,(%esp)
f0101b16:	e8 7b f7 ff ff       	call   f0101296 <page_alloc>
f0101b1b:	85 c0                	test   %eax,%eax
f0101b1d:	74 24                	je     f0101b43 <check_page_alloc+0x308>
f0101b1f:	c7 44 24 0c 48 b7 10 	movl   $0xf010b748,0xc(%esp)
f0101b26:	f0 
f0101b27:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0101b2e:	f0 
f0101b2f:	c7 44 24 04 45 01 00 	movl   $0x145,0x4(%esp)
f0101b36:	00 
f0101b37:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101b3e:	e8 43 e5 ff ff       	call   f0100086 <_panic>

	assert(pp0);
f0101b43:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0101b46:	85 d2                	test   %edx,%edx
f0101b48:	75 24                	jne    f0101b6e <check_page_alloc+0x333>
f0101b4a:	c7 44 24 0c 6c b7 10 	movl   $0xf010b76c,0xc(%esp)
f0101b51:	f0 
f0101b52:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0101b59:	f0 
f0101b5a:	c7 44 24 04 47 01 00 	movl   $0x147,0x4(%esp)
f0101b61:	00 
f0101b62:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101b69:	e8 18 e5 ff ff       	call   f0100086 <_panic>
	assert(pp1 && pp1 != pp0);
f0101b6e:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0101b71:	85 c9                	test   %ecx,%ecx
f0101b73:	74 04                	je     f0101b79 <check_page_alloc+0x33e>
f0101b75:	39 ca                	cmp    %ecx,%edx
f0101b77:	75 24                	jne    f0101b9d <check_page_alloc+0x362>
f0101b79:	c7 44 24 0c 5e b7 10 	movl   $0xf010b75e,0xc(%esp)
f0101b80:	f0 
f0101b81:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0101b88:	f0 
f0101b89:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
f0101b90:	00 
f0101b91:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101b98:	e8 e9 e4 ff ff       	call   f0100086 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b9d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101ba0:	85 db                	test   %ebx,%ebx
f0101ba2:	74 08                	je     f0101bac <check_page_alloc+0x371>
f0101ba4:	39 d9                	cmp    %ebx,%ecx
f0101ba6:	74 04                	je     f0101bac <check_page_alloc+0x371>
f0101ba8:	39 da                	cmp    %ebx,%edx
f0101baa:	75 24                	jne    f0101bd0 <check_page_alloc+0x395>
f0101bac:	c7 44 24 0c 68 b1 10 	movl   $0xf010b168,0xc(%esp)
f0101bb3:	f0 
f0101bb4:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0101bbb:	f0 
f0101bbc:	c7 44 24 04 49 01 00 	movl   $0x149,0x4(%esp)
f0101bc3:	00 
f0101bc4:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101bcb:	e8 b6 e4 ff ff       	call   f0100086 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101bd0:	8b 35 fc 54 29 f0    	mov    0xf02954fc,%esi
	assert(page2pa(pp0) < npage*PGSIZE);
f0101bd6:	a1 f0 54 29 f0       	mov    0xf02954f0,%eax
f0101bdb:	89 c7                	mov    %eax,%edi
f0101bdd:	c1 e7 0c             	shl    $0xc,%edi
f0101be0:	89 d0                	mov    %edx,%eax
f0101be2:	29 f0                	sub    %esi,%eax
f0101be4:	c1 f8 02             	sar    $0x2,%eax
f0101be7:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101bed:	c1 e0 0c             	shl    $0xc,%eax
f0101bf0:	39 f8                	cmp    %edi,%eax
f0101bf2:	72 24                	jb     f0101c18 <check_page_alloc+0x3dd>
f0101bf4:	c7 44 24 0c 70 b7 10 	movl   $0xf010b770,0xc(%esp)
f0101bfb:	f0 
f0101bfc:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0101c03:	f0 
f0101c04:	c7 44 24 04 4a 01 00 	movl   $0x14a,0x4(%esp)
f0101c0b:	00 
f0101c0c:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101c13:	e8 6e e4 ff ff       	call   f0100086 <_panic>
	assert(page2pa(pp1) < npage*PGSIZE);
f0101c18:	89 c8                	mov    %ecx,%eax
f0101c1a:	29 f0                	sub    %esi,%eax
f0101c1c:	c1 f8 02             	sar    $0x2,%eax
f0101c1f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101c25:	c1 e0 0c             	shl    $0xc,%eax
f0101c28:	39 c7                	cmp    %eax,%edi
f0101c2a:	77 24                	ja     f0101c50 <check_page_alloc+0x415>
f0101c2c:	c7 44 24 0c 8c b7 10 	movl   $0xf010b78c,0xc(%esp)
f0101c33:	f0 
f0101c34:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0101c3b:	f0 
f0101c3c:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
f0101c43:	00 
f0101c44:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101c4b:	e8 36 e4 ff ff       	call   f0100086 <_panic>
	assert(page2pa(pp2) < npage*PGSIZE);
f0101c50:	89 d8                	mov    %ebx,%eax
f0101c52:	29 f0                	sub    %esi,%eax
f0101c54:	c1 f8 02             	sar    $0x2,%eax
f0101c57:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101c5d:	c1 e0 0c             	shl    $0xc,%eax
f0101c60:	39 c7                	cmp    %eax,%edi
f0101c62:	77 24                	ja     f0101c88 <check_page_alloc+0x44d>
f0101c64:	c7 44 24 0c a8 b7 10 	movl   $0xf010b7a8,0xc(%esp)
f0101c6b:	f0 
f0101c6c:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0101c73:	f0 
f0101c74:	c7 44 24 04 4c 01 00 	movl   $0x14c,0x4(%esp)
f0101c7b:	00 
f0101c7c:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101c83:	e8 fe e3 ff ff       	call   f0100086 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101c88:	8b 1d 38 45 29 f0    	mov    0xf0294538,%ebx
	LIST_INIT(&page_free_list);
f0101c8e:	c7 05 38 45 29 f0 00 	movl   $0x0,0xf0294538
f0101c95:	00 00 00 

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101c98:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0101c9b:	89 04 24             	mov    %eax,(%esp)
f0101c9e:	e8 f3 f5 ff ff       	call   f0101296 <page_alloc>
f0101ca3:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101ca6:	74 24                	je     f0101ccc <check_page_alloc+0x491>
f0101ca8:	c7 44 24 0c c4 b7 10 	movl   $0xf010b7c4,0xc(%esp)
f0101caf:	f0 
f0101cb0:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0101cb7:	f0 
f0101cb8:	c7 44 24 04 53 01 00 	movl   $0x153,0x4(%esp)
f0101cbf:	00 
f0101cc0:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101cc7:	e8 ba e3 ff ff       	call   f0100086 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101ccc:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101ccf:	89 04 24             	mov    %eax,(%esp)
f0101cd2:	e8 91 f3 ff ff       	call   f0101068 <page_free>
	page_free(pp1);
f0101cd7:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101cda:	89 04 24             	mov    %eax,(%esp)
f0101cdd:	e8 86 f3 ff ff       	call   f0101068 <page_free>
	page_free(pp2);
f0101ce2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101ce5:	89 04 24             	mov    %eax,(%esp)
f0101ce8:	e8 7b f3 ff ff       	call   f0101068 <page_free>
	pp0 = pp1 = pp2 = 0;
f0101ced:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0101cf4:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f0101cfb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	assert(page_alloc(&pp0) == 0);
f0101d02:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101d05:	89 04 24             	mov    %eax,(%esp)
f0101d08:	e8 89 f5 ff ff       	call   f0101296 <page_alloc>
f0101d0d:	85 c0                	test   %eax,%eax
f0101d0f:	74 24                	je     f0101d35 <check_page_alloc+0x4fa>
f0101d11:	c7 44 24 0c 1c b7 10 	movl   $0xf010b71c,0xc(%esp)
f0101d18:	f0 
f0101d19:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0101d20:	f0 
f0101d21:	c7 44 24 04 5a 01 00 	movl   $0x15a,0x4(%esp)
f0101d28:	00 
f0101d29:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101d30:	e8 51 e3 ff ff       	call   f0100086 <_panic>
	assert(page_alloc(&pp1) == 0);
f0101d35:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0101d38:	89 04 24             	mov    %eax,(%esp)
f0101d3b:	e8 56 f5 ff ff       	call   f0101296 <page_alloc>
f0101d40:	85 c0                	test   %eax,%eax
f0101d42:	74 24                	je     f0101d68 <check_page_alloc+0x52d>
f0101d44:	c7 44 24 0c 32 b7 10 	movl   $0xf010b732,0xc(%esp)
f0101d4b:	f0 
f0101d4c:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0101d53:	f0 
f0101d54:	c7 44 24 04 5b 01 00 	movl   $0x15b,0x4(%esp)
f0101d5b:	00 
f0101d5c:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101d63:	e8 1e e3 ff ff       	call   f0100086 <_panic>
	assert(page_alloc(&pp2) == 0);
f0101d68:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101d6b:	89 04 24             	mov    %eax,(%esp)
f0101d6e:	e8 23 f5 ff ff       	call   f0101296 <page_alloc>
f0101d73:	85 c0                	test   %eax,%eax
f0101d75:	74 24                	je     f0101d9b <check_page_alloc+0x560>
f0101d77:	c7 44 24 0c 48 b7 10 	movl   $0xf010b748,0xc(%esp)
f0101d7e:	f0 
f0101d7f:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0101d86:	f0 
f0101d87:	c7 44 24 04 5c 01 00 	movl   $0x15c,0x4(%esp)
f0101d8e:	00 
f0101d8f:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101d96:	e8 eb e2 ff ff       	call   f0100086 <_panic>
	assert(pp0);
f0101d9b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0101d9e:	85 c9                	test   %ecx,%ecx
f0101da0:	75 24                	jne    f0101dc6 <check_page_alloc+0x58b>
f0101da2:	c7 44 24 0c 6c b7 10 	movl   $0xf010b76c,0xc(%esp)
f0101da9:	f0 
f0101daa:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0101db1:	f0 
f0101db2:	c7 44 24 04 5d 01 00 	movl   $0x15d,0x4(%esp)
f0101db9:	00 
f0101dba:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101dc1:	e8 c0 e2 ff ff       	call   f0100086 <_panic>
	assert(pp1 && pp1 != pp0);
f0101dc6:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0101dc9:	85 d2                	test   %edx,%edx
f0101dcb:	74 04                	je     f0101dd1 <check_page_alloc+0x596>
f0101dcd:	39 d1                	cmp    %edx,%ecx
f0101dcf:	75 24                	jne    f0101df5 <check_page_alloc+0x5ba>
f0101dd1:	c7 44 24 0c 5e b7 10 	movl   $0xf010b75e,0xc(%esp)
f0101dd8:	f0 
f0101dd9:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0101de0:	f0 
f0101de1:	c7 44 24 04 5e 01 00 	movl   $0x15e,0x4(%esp)
f0101de8:	00 
f0101de9:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101df0:	e8 91 e2 ff ff       	call   f0100086 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101df5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101df8:	85 c0                	test   %eax,%eax
f0101dfa:	74 08                	je     f0101e04 <check_page_alloc+0x5c9>
f0101dfc:	39 c2                	cmp    %eax,%edx
f0101dfe:	74 04                	je     f0101e04 <check_page_alloc+0x5c9>
f0101e00:	39 c1                	cmp    %eax,%ecx
f0101e02:	75 24                	jne    f0101e28 <check_page_alloc+0x5ed>
f0101e04:	c7 44 24 0c 68 b1 10 	movl   $0xf010b168,0xc(%esp)
f0101e0b:	f0 
f0101e0c:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0101e13:	f0 
f0101e14:	c7 44 24 04 5f 01 00 	movl   $0x15f,0x4(%esp)
f0101e1b:	00 
f0101e1c:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101e23:	e8 5e e2 ff ff       	call   f0100086 <_panic>
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101e28:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0101e2b:	89 04 24             	mov    %eax,(%esp)
f0101e2e:	e8 63 f4 ff ff       	call   f0101296 <page_alloc>
f0101e33:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101e36:	74 24                	je     f0101e5c <check_page_alloc+0x621>
f0101e38:	c7 44 24 0c c4 b7 10 	movl   $0xf010b7c4,0xc(%esp)
f0101e3f:	f0 
f0101e40:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0101e47:	f0 
f0101e48:	c7 44 24 04 60 01 00 	movl   $0x160,0x4(%esp)
f0101e4f:	00 
f0101e50:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101e57:	e8 2a e2 ff ff       	call   f0100086 <_panic>

	// give free list back
	page_free_list = fl;
f0101e5c:	89 1d 38 45 29 f0    	mov    %ebx,0xf0294538

	// free the pages we took
	page_free(pp0);
f0101e62:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101e65:	89 04 24             	mov    %eax,(%esp)
f0101e68:	e8 fb f1 ff ff       	call   f0101068 <page_free>
	page_free(pp1);
f0101e6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101e70:	89 04 24             	mov    %eax,(%esp)
f0101e73:	e8 f0 f1 ff ff       	call   f0101068 <page_free>
	page_free(pp2);
f0101e78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101e7b:	89 04 24             	mov    %eax,(%esp)
f0101e7e:	e8 e5 f1 ff ff       	call   f0101068 <page_free>

	cprintf("check_page_alloc() succeeded!\n");
f0101e83:	c7 04 24 88 b1 10 f0 	movl   $0xf010b188,(%esp)
f0101e8a:	e8 58 1b 00 00       	call   f01039e7 <cprintf>
}
f0101e8f:	83 c4 2c             	add    $0x2c,%esp
f0101e92:	5b                   	pop    %ebx
f0101e93:	5e                   	pop    %esi
f0101e94:	5f                   	pop    %edi
f0101e95:	5d                   	pop    %ebp
f0101e96:	c3                   	ret    

f0101e97 <i386_vm_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
{
f0101e97:	55                   	push   %ebp
f0101e98:	89 e5                	mov    %esp,%ebp
f0101e9a:	57                   	push   %edi
f0101e9b:	56                   	push   %esi
f0101e9c:	53                   	push   %ebx
f0101e9d:	83 ec 3c             	sub    $0x3c,%esp
	// Delete this line:
	//panic("i386_vm_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	pgdir = boot_alloc(PGSIZE, PGSIZE);
f0101ea0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ea5:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101eaa:	e8 61 f1 ff ff       	call   f0101010 <boot_alloc>
f0101eaf:	89 c3                	mov    %eax,%ebx
	memset(pgdir, 0, PGSIZE);
f0101eb1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101eb8:	00 
f0101eb9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101ec0:	00 
f0101ec1:	89 04 24             	mov    %eax,(%esp)
f0101ec4:	e8 15 78 00 00       	call   f01096de <memset>
	boot_pgdir = pgdir;
f0101ec9:	89 1d f8 54 29 f0    	mov    %ebx,0xf02954f8
	boot_cr3 = PADDR(pgdir);
f0101ecf:	89 d8                	mov    %ebx,%eax
f0101ed1:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0101ed7:	77 20                	ja     f0101ef9 <i386_vm_init+0x62>
f0101ed9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101edd:	c7 44 24 08 6c b0 10 	movl   $0xf010b06c,0x8(%esp)
f0101ee4:	f0 
f0101ee5:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
f0101eec:	00 
f0101eed:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101ef4:	e8 8d e1 ff ff       	call   f0100086 <_panic>
f0101ef9:	05 00 00 00 10       	add    $0x10000000,%eax
f0101efe:	a3 f4 54 29 f0       	mov    %eax,0xf02954f4
	// a virtual page table at virtual address VPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel RW, user NONE
	pgdir[PDX(VPT)] = PADDR(pgdir)|PTE_W|PTE_P;
f0101f03:	89 c2                	mov    %eax,%edx
f0101f05:	83 ca 03             	or     $0x3,%edx
f0101f08:	89 93 fc 0e 00 00    	mov    %edx,0xefc(%ebx)

	// same for UVPT
	// Permissions: kernel R, user R 
	pgdir[PDX(UVPT)] = PADDR(pgdir)|PTE_U|PTE_P;
f0101f0e:	83 c8 05             	or     $0x5,%eax
f0101f11:	89 83 f4 0e 00 00    	mov    %eax,0xef4(%ebx)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct Page in this
	// array.  'npage' is the number of physical pages in memory.
	// User-level programs will get read-only access to the array as well.
	// Your code goes here:
	pages=(struct Page*)boot_alloc(npage*sizeof(struct Page),PGSIZE);
f0101f17:	a1 f0 54 29 f0       	mov    0xf02954f0,%eax
f0101f1c:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0101f1f:	c1 e0 02             	shl    $0x2,%eax
f0101f22:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f27:	e8 e4 f0 ff ff       	call   f0101010 <boot_alloc>
f0101f2c:	a3 fc 54 29 f0       	mov    %eax,0xf02954fc

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs=(struct Env*)boot_alloc(NENV*sizeof(struct Env),PGSIZE);
f0101f31:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f36:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101f3b:	e8 d0 f0 ff ff       	call   f0101010 <boot_alloc>
f0101f40:	a3 40 45 29 f0       	mov    %eax,0xf0294540
	//////////////////////////////////////////////////////////////////////
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_segment or page_insert
	page_init();
f0101f45:	e8 9a f1 ff ff       	call   f01010e4 <page_init>

	check_page_alloc();
f0101f4a:	e8 ec f8 ff ff       	call   f010183b <check_page_alloc>
	pte_t *ptep, *ptep1;
	void *va;
	int i;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
f0101f4f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0101f56:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f0101f5d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	assert(page_alloc(&pp0) == 0);
f0101f64:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101f67:	89 04 24             	mov    %eax,(%esp)
f0101f6a:	e8 27 f3 ff ff       	call   f0101296 <page_alloc>
f0101f6f:	85 c0                	test   %eax,%eax
f0101f71:	74 24                	je     f0101f97 <i386_vm_init+0x100>
f0101f73:	c7 44 24 0c 1c b7 10 	movl   $0xf010b71c,0xc(%esp)
f0101f7a:	f0 
f0101f7b:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0101f82:	f0 
f0101f83:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f0101f8a:	00 
f0101f8b:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101f92:	e8 ef e0 ff ff       	call   f0100086 <_panic>
	assert(page_alloc(&pp1) == 0);
f0101f97:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0101f9a:	89 04 24             	mov    %eax,(%esp)
f0101f9d:	e8 f4 f2 ff ff       	call   f0101296 <page_alloc>
f0101fa2:	85 c0                	test   %eax,%eax
f0101fa4:	74 24                	je     f0101fca <i386_vm_init+0x133>
f0101fa6:	c7 44 24 0c 32 b7 10 	movl   $0xf010b732,0xc(%esp)
f0101fad:	f0 
f0101fae:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0101fb5:	f0 
f0101fb6:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f0101fbd:	00 
f0101fbe:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101fc5:	e8 bc e0 ff ff       	call   f0100086 <_panic>
	assert(page_alloc(&pp2) == 0);
f0101fca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101fcd:	89 04 24             	mov    %eax,(%esp)
f0101fd0:	e8 c1 f2 ff ff       	call   f0101296 <page_alloc>
f0101fd5:	85 c0                	test   %eax,%eax
f0101fd7:	74 24                	je     f0101ffd <i386_vm_init+0x166>
f0101fd9:	c7 44 24 0c 48 b7 10 	movl   $0xf010b748,0xc(%esp)
f0101fe0:	f0 
f0101fe1:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0101fe8:	f0 
f0101fe9:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f0101ff0:	00 
f0101ff1:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0101ff8:	e8 89 e0 ff ff       	call   f0100086 <_panic>

	assert(pp0);
f0101ffd:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102000:	85 c9                	test   %ecx,%ecx
f0102002:	75 24                	jne    f0102028 <i386_vm_init+0x191>
f0102004:	c7 44 24 0c 6c b7 10 	movl   $0xf010b76c,0xc(%esp)
f010200b:	f0 
f010200c:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102013:	f0 
f0102014:	c7 44 24 04 51 03 00 	movl   $0x351,0x4(%esp)
f010201b:	00 
f010201c:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102023:	e8 5e e0 ff ff       	call   f0100086 <_panic>
	assert(pp1 && pp1 != pp0);
f0102028:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010202b:	85 d2                	test   %edx,%edx
f010202d:	74 04                	je     f0102033 <i386_vm_init+0x19c>
f010202f:	39 d1                	cmp    %edx,%ecx
f0102031:	75 24                	jne    f0102057 <i386_vm_init+0x1c0>
f0102033:	c7 44 24 0c 5e b7 10 	movl   $0xf010b75e,0xc(%esp)
f010203a:	f0 
f010203b:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102042:	f0 
f0102043:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
f010204a:	00 
f010204b:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102052:	e8 2f e0 ff ff       	call   f0100086 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102057:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010205a:	85 c0                	test   %eax,%eax
f010205c:	74 08                	je     f0102066 <i386_vm_init+0x1cf>
f010205e:	39 c2                	cmp    %eax,%edx
f0102060:	74 04                	je     f0102066 <i386_vm_init+0x1cf>
f0102062:	39 c1                	cmp    %eax,%ecx
f0102064:	75 24                	jne    f010208a <i386_vm_init+0x1f3>
f0102066:	c7 44 24 0c 68 b1 10 	movl   $0xf010b168,0xc(%esp)
f010206d:	f0 
f010206e:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102075:	f0 
f0102076:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f010207d:	00 
f010207e:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102085:	e8 fc df ff ff       	call   f0100086 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010208a:	8b 35 38 45 29 f0    	mov    0xf0294538,%esi
	LIST_INIT(&page_free_list);
f0102090:	c7 05 38 45 29 f0 00 	movl   $0x0,0xf0294538
f0102097:	00 00 00 

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f010209a:	8d 45 f0             	lea    -0x10(%ebp),%eax
f010209d:	89 04 24             	mov    %eax,(%esp)
f01020a0:	e8 f1 f1 ff ff       	call   f0101296 <page_alloc>
f01020a5:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01020a8:	74 24                	je     f01020ce <i386_vm_init+0x237>
f01020aa:	c7 44 24 0c c4 b7 10 	movl   $0xf010b7c4,0xc(%esp)
f01020b1:	f0 
f01020b2:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f01020b9:	f0 
f01020ba:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
f01020c1:	00 
f01020c2:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f01020c9:	e8 b8 df ff ff       	call   f0100086 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(boot_pgdir, (void *) 0x0, &ptep) == NULL);
f01020ce:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01020d1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01020d5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01020dc:	00 
f01020dd:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f01020e2:	89 04 24             	mov    %eax,(%esp)
f01020e5:	e8 41 f3 ff ff       	call   f010142b <page_lookup>
f01020ea:	85 c0                	test   %eax,%eax
f01020ec:	74 24                	je     f0102112 <i386_vm_init+0x27b>
f01020ee:	c7 44 24 0c a8 b1 10 	movl   $0xf010b1a8,0xc(%esp)
f01020f5:	f0 
f01020f6:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f01020fd:	f0 
f01020fe:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
f0102105:	00 
f0102106:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f010210d:	e8 74 df ff ff       	call   f0100086 <_panic>

	// there is no free memory, so we can't allocate a page table 
	assert(page_insert(boot_pgdir, pp1, 0x0, 0) < 0);
f0102112:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102119:	00 
f010211a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102121:	00 
f0102122:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102125:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102129:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f010212e:	89 04 24             	mov    %eax,(%esp)
f0102131:	e8 85 f5 ff ff       	call   f01016bb <page_insert>
f0102136:	85 c0                	test   %eax,%eax
f0102138:	78 24                	js     f010215e <i386_vm_init+0x2c7>
f010213a:	c7 44 24 0c e0 b1 10 	movl   $0xf010b1e0,0xc(%esp)
f0102141:	f0 
f0102142:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102149:	f0 
f010214a:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
f0102151:	00 
f0102152:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102159:	e8 28 df ff ff       	call   f0100086 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010215e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102161:	89 04 24             	mov    %eax,(%esp)
f0102164:	e8 ff ee ff ff       	call   f0101068 <page_free>
	assert(page_insert(boot_pgdir, pp1, 0x0, 0) == 0);
f0102169:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102170:	00 
f0102171:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102178:	00 
f0102179:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010217c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102180:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f0102185:	89 04 24             	mov    %eax,(%esp)
f0102188:	e8 2e f5 ff ff       	call   f01016bb <page_insert>
f010218d:	85 c0                	test   %eax,%eax
f010218f:	74 24                	je     f01021b5 <i386_vm_init+0x31e>
f0102191:	c7 44 24 0c 0c b2 10 	movl   $0xf010b20c,0xc(%esp)
f0102198:	f0 
f0102199:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f01021a0:	f0 
f01021a1:	c7 44 24 04 64 03 00 	movl   $0x364,0x4(%esp)
f01021a8:	00 
f01021a9:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f01021b0:	e8 d1 de ff ff       	call   f0100086 <_panic>
	assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f01021b5:	8b 0d f8 54 29 f0    	mov    0xf02954f8,%ecx
f01021bb:	8b 11                	mov    (%ecx),%edx
f01021bd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01021c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01021c6:	2b 05 fc 54 29 f0    	sub    0xf02954fc,%eax
f01021cc:	c1 f8 02             	sar    $0x2,%eax
f01021cf:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01021d5:	c1 e0 0c             	shl    $0xc,%eax
f01021d8:	39 c2                	cmp    %eax,%edx
f01021da:	74 24                	je     f0102200 <i386_vm_init+0x369>
f01021dc:	c7 44 24 0c 38 b2 10 	movl   $0xf010b238,0xc(%esp)
f01021e3:	f0 
f01021e4:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f01021eb:	f0 
f01021ec:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f01021f3:	00 
f01021f4:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f01021fb:	e8 86 de ff ff       	call   f0100086 <_panic>
	assert(check_va2pa(boot_pgdir, 0x0) == page2pa(pp1));
f0102200:	ba 00 00 00 00       	mov    $0x0,%edx
f0102205:	89 c8                	mov    %ecx,%eax
f0102207:	e8 20 f0 ff ff       	call   f010122c <check_va2pa>
f010220c:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f010220f:	89 ca                	mov    %ecx,%edx
f0102211:	2b 15 fc 54 29 f0    	sub    0xf02954fc,%edx
f0102217:	c1 fa 02             	sar    $0x2,%edx
f010221a:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102220:	c1 e2 0c             	shl    $0xc,%edx
f0102223:	39 d0                	cmp    %edx,%eax
f0102225:	74 24                	je     f010224b <i386_vm_init+0x3b4>
f0102227:	c7 44 24 0c 60 b2 10 	movl   $0xf010b260,0xc(%esp)
f010222e:	f0 
f010222f:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102236:	f0 
f0102237:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f010223e:	00 
f010223f:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102246:	e8 3b de ff ff       	call   f0100086 <_panic>
	assert(pp1->pp_ref == 1);
f010224b:	66 83 79 08 01       	cmpw   $0x1,0x8(%ecx)
f0102250:	74 24                	je     f0102276 <i386_vm_init+0x3df>
f0102252:	c7 44 24 0c e1 b7 10 	movl   $0xf010b7e1,0xc(%esp)
f0102259:	f0 
f010225a:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102261:	f0 
f0102262:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
f0102269:	00 
f010226a:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102271:	e8 10 de ff ff       	call   f0100086 <_panic>
	assert(pp0->pp_ref == 1);
f0102276:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102279:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f010227e:	74 24                	je     f01022a4 <i386_vm_init+0x40d>
f0102280:	c7 44 24 0c f2 b7 10 	movl   $0xf010b7f2,0xc(%esp)
f0102287:	f0 
f0102288:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f010228f:	f0 
f0102290:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0102297:	00 
f0102298:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f010229f:	e8 e2 dd ff ff       	call   f0100086 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f01022a4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01022ab:	00 
f01022ac:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01022b3:	00 
f01022b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01022b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01022bb:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f01022c0:	89 04 24             	mov    %eax,(%esp)
f01022c3:	e8 f3 f3 ff ff       	call   f01016bb <page_insert>
f01022c8:	85 c0                	test   %eax,%eax
f01022ca:	74 24                	je     f01022f0 <i386_vm_init+0x459>
f01022cc:	c7 44 24 0c 90 b2 10 	movl   $0xf010b290,0xc(%esp)
f01022d3:	f0 
f01022d4:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f01022db:	f0 
f01022dc:	c7 44 24 04 6b 03 00 	movl   $0x36b,0x4(%esp)
f01022e3:	00 
f01022e4:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f01022eb:	e8 96 dd ff ff       	call   f0100086 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f01022f0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022f5:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f01022fa:	e8 2d ef ff ff       	call   f010122c <check_va2pa>
f01022ff:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102302:	89 ca                	mov    %ecx,%edx
f0102304:	2b 15 fc 54 29 f0    	sub    0xf02954fc,%edx
f010230a:	c1 fa 02             	sar    $0x2,%edx
f010230d:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102313:	c1 e2 0c             	shl    $0xc,%edx
f0102316:	39 d0                	cmp    %edx,%eax
f0102318:	74 24                	je     f010233e <i386_vm_init+0x4a7>
f010231a:	c7 44 24 0c c8 b2 10 	movl   $0xf010b2c8,0xc(%esp)
f0102321:	f0 
f0102322:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102329:	f0 
f010232a:	c7 44 24 04 6c 03 00 	movl   $0x36c,0x4(%esp)
f0102331:	00 
f0102332:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102339:	e8 48 dd ff ff       	call   f0100086 <_panic>
	assert(pp2->pp_ref == 1);
f010233e:	66 83 79 08 01       	cmpw   $0x1,0x8(%ecx)
f0102343:	74 24                	je     f0102369 <i386_vm_init+0x4d2>
f0102345:	c7 44 24 0c 03 b8 10 	movl   $0xf010b803,0xc(%esp)
f010234c:	f0 
f010234d:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102354:	f0 
f0102355:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f010235c:	00 
f010235d:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102364:	e8 1d dd ff ff       	call   f0100086 <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0102369:	8d 45 f0             	lea    -0x10(%ebp),%eax
f010236c:	89 04 24             	mov    %eax,(%esp)
f010236f:	e8 22 ef ff ff       	call   f0101296 <page_alloc>
f0102374:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102377:	74 24                	je     f010239d <i386_vm_init+0x506>
f0102379:	c7 44 24 0c c4 b7 10 	movl   $0xf010b7c4,0xc(%esp)
f0102380:	f0 
f0102381:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102388:	f0 
f0102389:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f0102390:	00 
f0102391:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102398:	e8 e9 dc ff ff       	call   f0100086 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f010239d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01023a4:	00 
f01023a5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01023ac:	00 
f01023ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01023b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01023b4:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f01023b9:	89 04 24             	mov    %eax,(%esp)
f01023bc:	e8 fa f2 ff ff       	call   f01016bb <page_insert>
f01023c1:	85 c0                	test   %eax,%eax
f01023c3:	74 24                	je     f01023e9 <i386_vm_init+0x552>
f01023c5:	c7 44 24 0c 90 b2 10 	movl   $0xf010b290,0xc(%esp)
f01023cc:	f0 
f01023cd:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f01023d4:	f0 
f01023d5:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
f01023dc:	00 
f01023dd:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f01023e4:	e8 9d dc ff ff       	call   f0100086 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f01023e9:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023ee:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f01023f3:	e8 34 ee ff ff       	call   f010122c <check_va2pa>
f01023f8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01023fb:	89 ca                	mov    %ecx,%edx
f01023fd:	2b 15 fc 54 29 f0    	sub    0xf02954fc,%edx
f0102403:	c1 fa 02             	sar    $0x2,%edx
f0102406:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f010240c:	c1 e2 0c             	shl    $0xc,%edx
f010240f:	39 d0                	cmp    %edx,%eax
f0102411:	74 24                	je     f0102437 <i386_vm_init+0x5a0>
f0102413:	c7 44 24 0c c8 b2 10 	movl   $0xf010b2c8,0xc(%esp)
f010241a:	f0 
f010241b:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102422:	f0 
f0102423:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f010242a:	00 
f010242b:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102432:	e8 4f dc ff ff       	call   f0100086 <_panic>
	assert(pp2->pp_ref == 1);
f0102437:	66 83 79 08 01       	cmpw   $0x1,0x8(%ecx)
f010243c:	74 24                	je     f0102462 <i386_vm_init+0x5cb>
f010243e:	c7 44 24 0c 03 b8 10 	movl   $0xf010b803,0xc(%esp)
f0102445:	f0 
f0102446:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f010244d:	f0 
f010244e:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f0102455:	00 
f0102456:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f010245d:	e8 24 dc ff ff       	call   f0100086 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(page_alloc(&pp) == -E_NO_MEM);
f0102462:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0102465:	89 04 24             	mov    %eax,(%esp)
f0102468:	e8 29 ee ff ff       	call   f0101296 <page_alloc>
f010246d:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102470:	74 24                	je     f0102496 <i386_vm_init+0x5ff>
f0102472:	c7 44 24 0c c4 b7 10 	movl   $0xf010b7c4,0xc(%esp)
f0102479:	f0 
f010247a:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102481:	f0 
f0102482:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0102489:	00 
f010248a:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102491:	e8 f0 db ff ff       	call   f0100086 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = KADDR(PTE_ADDR(boot_pgdir[PDX(PGSIZE)]));
f0102496:	8b 0d f8 54 29 f0    	mov    0xf02954f8,%ecx
f010249c:	8b 11                	mov    (%ecx),%edx
f010249e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01024a4:	89 d0                	mov    %edx,%eax
f01024a6:	c1 e8 0c             	shr    $0xc,%eax
f01024a9:	3b 05 f0 54 29 f0    	cmp    0xf02954f0,%eax
f01024af:	72 20                	jb     f01024d1 <i386_vm_init+0x63a>
f01024b1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01024b5:	c7 44 24 08 e8 ac 10 	movl   $0xf010ace8,0x8(%esp)
f01024bc:	f0 
f01024bd:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f01024c4:	00 
f01024c5:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f01024cc:	e8 b5 db ff ff       	call   f0100086 <_panic>
f01024d1:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01024d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
	assert(pgdir_walk(boot_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01024da:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01024e1:	00 
f01024e2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01024e9:	00 
f01024ea:	89 0c 24             	mov    %ecx,(%esp)
f01024ed:	e8 f9 ed ff ff       	call   f01012eb <pgdir_walk>
f01024f2:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01024f5:	83 c2 04             	add    $0x4,%edx
f01024f8:	39 d0                	cmp    %edx,%eax
f01024fa:	74 24                	je     f0102520 <i386_vm_init+0x689>
f01024fc:	c7 44 24 0c f8 b2 10 	movl   $0xf010b2f8,0xc(%esp)
f0102503:	f0 
f0102504:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f010250b:	f0 
f010250c:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0102513:	00 
f0102514:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f010251b:	e8 66 db ff ff       	call   f0100086 <_panic>

	// should be able to change permissions too.
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, PTE_U) == 0);
f0102520:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0102527:	00 
f0102528:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010252f:	00 
f0102530:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102533:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102537:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f010253c:	89 04 24             	mov    %eax,(%esp)
f010253f:	e8 77 f1 ff ff       	call   f01016bb <page_insert>
f0102544:	85 c0                	test   %eax,%eax
f0102546:	74 24                	je     f010256c <i386_vm_init+0x6d5>
f0102548:	c7 44 24 0c 38 b3 10 	movl   $0xf010b338,0xc(%esp)
f010254f:	f0 
f0102550:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102557:	f0 
f0102558:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
f010255f:	00 
f0102560:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102567:	e8 1a db ff ff       	call   f0100086 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f010256c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102571:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f0102576:	e8 b1 ec ff ff       	call   f010122c <check_va2pa>
f010257b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010257e:	89 ca                	mov    %ecx,%edx
f0102580:	2b 15 fc 54 29 f0    	sub    0xf02954fc,%edx
f0102586:	c1 fa 02             	sar    $0x2,%edx
f0102589:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f010258f:	c1 e2 0c             	shl    $0xc,%edx
f0102592:	39 d0                	cmp    %edx,%eax
f0102594:	74 24                	je     f01025ba <i386_vm_init+0x723>
f0102596:	c7 44 24 0c c8 b2 10 	movl   $0xf010b2c8,0xc(%esp)
f010259d:	f0 
f010259e:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f01025a5:	f0 
f01025a6:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f01025ad:	00 
f01025ae:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f01025b5:	e8 cc da ff ff       	call   f0100086 <_panic>
	assert(pp2->pp_ref == 1);
f01025ba:	66 83 79 08 01       	cmpw   $0x1,0x8(%ecx)
f01025bf:	74 24                	je     f01025e5 <i386_vm_init+0x74e>
f01025c1:	c7 44 24 0c 03 b8 10 	movl   $0xf010b803,0xc(%esp)
f01025c8:	f0 
f01025c9:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f01025d0:	f0 
f01025d1:	c7 44 24 04 82 03 00 	movl   $0x382,0x4(%esp)
f01025d8:	00 
f01025d9:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f01025e0:	e8 a1 da ff ff       	call   f0100086 <_panic>
	assert(*pgdir_walk(boot_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01025e5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01025ec:	00 
f01025ed:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01025f4:	00 
f01025f5:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f01025fa:	89 04 24             	mov    %eax,(%esp)
f01025fd:	e8 e9 ec ff ff       	call   f01012eb <pgdir_walk>
f0102602:	f6 00 04             	testb  $0x4,(%eax)
f0102605:	75 24                	jne    f010262b <i386_vm_init+0x794>
f0102607:	c7 44 24 0c 74 b3 10 	movl   $0xf010b374,0xc(%esp)
f010260e:	f0 
f010260f:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102616:	f0 
f0102617:	c7 44 24 04 83 03 00 	movl   $0x383,0x4(%esp)
f010261e:	00 
f010261f:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102626:	e8 5b da ff ff       	call   f0100086 <_panic>
	assert(boot_pgdir[0] & PTE_U);
f010262b:	8b 15 f8 54 29 f0    	mov    0xf02954f8,%edx
f0102631:	f6 02 04             	testb  $0x4,(%edx)
f0102634:	75 24                	jne    f010265a <i386_vm_init+0x7c3>
f0102636:	c7 44 24 0c 14 b8 10 	movl   $0xf010b814,0xc(%esp)
f010263d:	f0 
f010263e:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102645:	f0 
f0102646:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f010264d:	00 
f010264e:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102655:	e8 2c da ff ff       	call   f0100086 <_panic>
	
	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(boot_pgdir, pp0, (void*) PTSIZE, 0) < 0);
f010265a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102661:	00 
f0102662:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102669:	00 
f010266a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010266d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102671:	89 14 24             	mov    %edx,(%esp)
f0102674:	e8 42 f0 ff ff       	call   f01016bb <page_insert>
f0102679:	85 c0                	test   %eax,%eax
f010267b:	78 24                	js     f01026a1 <i386_vm_init+0x80a>
f010267d:	c7 44 24 0c a8 b3 10 	movl   $0xf010b3a8,0xc(%esp)
f0102684:	f0 
f0102685:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f010268c:	f0 
f010268d:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0102694:	00 
f0102695:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f010269c:	e8 e5 d9 ff ff       	call   f0100086 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(boot_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01026a1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01026a8:	00 
f01026a9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01026b0:	00 
f01026b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01026b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01026b8:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f01026bd:	89 04 24             	mov    %eax,(%esp)
f01026c0:	e8 f6 ef ff ff       	call   f01016bb <page_insert>
f01026c5:	85 c0                	test   %eax,%eax
f01026c7:	74 24                	je     f01026ed <i386_vm_init+0x856>
f01026c9:	c7 44 24 0c dc b3 10 	movl   $0xf010b3dc,0xc(%esp)
f01026d0:	f0 
f01026d1:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f01026d8:	f0 
f01026d9:	c7 44 24 04 8a 03 00 	movl   $0x38a,0x4(%esp)
f01026e0:	00 
f01026e1:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f01026e8:	e8 99 d9 ff ff       	call   f0100086 <_panic>
	assert(!(*pgdir_walk(boot_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01026ed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01026f4:	00 
f01026f5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01026fc:	00 
f01026fd:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f0102702:	89 04 24             	mov    %eax,(%esp)
f0102705:	e8 e1 eb ff ff       	call   f01012eb <pgdir_walk>
f010270a:	f6 00 04             	testb  $0x4,(%eax)
f010270d:	74 24                	je     f0102733 <i386_vm_init+0x89c>
f010270f:	c7 44 24 0c 14 b4 10 	movl   $0xf010b414,0xc(%esp)
f0102716:	f0 
f0102717:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f010271e:	f0 
f010271f:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
f0102726:	00 
f0102727:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f010272e:	e8 53 d9 ff ff       	call   f0100086 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(boot_pgdir, 0) == page2pa(pp1));
f0102733:	ba 00 00 00 00       	mov    $0x0,%edx
f0102738:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f010273d:	e8 ea ea ff ff       	call   f010122c <check_va2pa>
f0102742:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0102745:	2b 15 fc 54 29 f0    	sub    0xf02954fc,%edx
f010274b:	c1 fa 02             	sar    $0x2,%edx
f010274e:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102754:	c1 e2 0c             	shl    $0xc,%edx
f0102757:	39 d0                	cmp    %edx,%eax
f0102759:	74 24                	je     f010277f <i386_vm_init+0x8e8>
f010275b:	c7 44 24 0c 4c b4 10 	movl   $0xf010b44c,0xc(%esp)
f0102762:	f0 
f0102763:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f010276a:	f0 
f010276b:	c7 44 24 04 8e 03 00 	movl   $0x38e,0x4(%esp)
f0102772:	00 
f0102773:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f010277a:	e8 07 d9 ff ff       	call   f0100086 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f010277f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102784:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f0102789:	e8 9e ea ff ff       	call   f010122c <check_va2pa>
f010278e:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102791:	89 ca                	mov    %ecx,%edx
f0102793:	2b 15 fc 54 29 f0    	sub    0xf02954fc,%edx
f0102799:	c1 fa 02             	sar    $0x2,%edx
f010279c:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01027a2:	c1 e2 0c             	shl    $0xc,%edx
f01027a5:	39 d0                	cmp    %edx,%eax
f01027a7:	74 24                	je     f01027cd <i386_vm_init+0x936>
f01027a9:	c7 44 24 0c 78 b4 10 	movl   $0xf010b478,0xc(%esp)
f01027b0:	f0 
f01027b1:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f01027b8:	f0 
f01027b9:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f01027c0:	00 
f01027c1:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f01027c8:	e8 b9 d8 ff ff       	call   f0100086 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01027cd:	66 83 79 08 02       	cmpw   $0x2,0x8(%ecx)
f01027d2:	74 24                	je     f01027f8 <i386_vm_init+0x961>
f01027d4:	c7 44 24 0c 2a b8 10 	movl   $0xf010b82a,0xc(%esp)
f01027db:	f0 
f01027dc:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f01027e3:	f0 
f01027e4:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f01027eb:	00 
f01027ec:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f01027f3:	e8 8e d8 ff ff       	call   f0100086 <_panic>
	assert(pp2->pp_ref == 0);
f01027f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01027fb:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0102800:	74 24                	je     f0102826 <i386_vm_init+0x98f>
f0102802:	c7 44 24 0c 3b b8 10 	movl   $0xf010b83b,0xc(%esp)
f0102809:	f0 
f010280a:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102811:	f0 
f0102812:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0102819:	00 
f010281a:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102821:	e8 60 d8 ff ff       	call   f0100086 <_panic>

	// pp2 should be returned by page_alloc
	assert(page_alloc(&pp) == 0 && pp == pp2);
f0102826:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0102829:	89 04 24             	mov    %eax,(%esp)
f010282c:	e8 65 ea ff ff       	call   f0101296 <page_alloc>
f0102831:	85 c0                	test   %eax,%eax
f0102833:	75 08                	jne    f010283d <i386_vm_init+0x9a6>
f0102835:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102838:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
f010283b:	74 24                	je     f0102861 <i386_vm_init+0x9ca>
f010283d:	c7 44 24 0c a8 b4 10 	movl   $0xf010b4a8,0xc(%esp)
f0102844:	f0 
f0102845:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f010284c:	f0 
f010284d:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f0102854:	00 
f0102855:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f010285c:	e8 25 d8 ff ff       	call   f0100086 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(boot_pgdir, 0x0);
f0102861:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102868:	00 
f0102869:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f010286e:	89 04 24             	mov    %eax,(%esp)
f0102871:	e8 61 ed ff ff       	call   f01015d7 <page_remove>
	assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f0102876:	ba 00 00 00 00       	mov    $0x0,%edx
f010287b:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f0102880:	e8 a7 e9 ff ff       	call   f010122c <check_va2pa>
f0102885:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102888:	74 24                	je     f01028ae <i386_vm_init+0xa17>
f010288a:	c7 44 24 0c cc b4 10 	movl   $0xf010b4cc,0xc(%esp)
f0102891:	f0 
f0102892:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102899:	f0 
f010289a:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f01028a1:	00 
f01028a2:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f01028a9:	e8 d8 d7 ff ff       	call   f0100086 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f01028ae:	ba 00 10 00 00       	mov    $0x1000,%edx
f01028b3:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f01028b8:	e8 6f e9 ff ff       	call   f010122c <check_va2pa>
f01028bd:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01028c0:	89 ca                	mov    %ecx,%edx
f01028c2:	2b 15 fc 54 29 f0    	sub    0xf02954fc,%edx
f01028c8:	c1 fa 02             	sar    $0x2,%edx
f01028cb:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01028d1:	c1 e2 0c             	shl    $0xc,%edx
f01028d4:	39 d0                	cmp    %edx,%eax
f01028d6:	74 24                	je     f01028fc <i386_vm_init+0xa65>
f01028d8:	c7 44 24 0c 78 b4 10 	movl   $0xf010b478,0xc(%esp)
f01028df:	f0 
f01028e0:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f01028e7:	f0 
f01028e8:	c7 44 24 04 9a 03 00 	movl   $0x39a,0x4(%esp)
f01028ef:	00 
f01028f0:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f01028f7:	e8 8a d7 ff ff       	call   f0100086 <_panic>
	assert(pp1->pp_ref == 1);
f01028fc:	66 83 79 08 01       	cmpw   $0x1,0x8(%ecx)
f0102901:	74 24                	je     f0102927 <i386_vm_init+0xa90>
f0102903:	c7 44 24 0c e1 b7 10 	movl   $0xf010b7e1,0xc(%esp)
f010290a:	f0 
f010290b:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102912:	f0 
f0102913:	c7 44 24 04 9b 03 00 	movl   $0x39b,0x4(%esp)
f010291a:	00 
f010291b:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102922:	e8 5f d7 ff ff       	call   f0100086 <_panic>
	assert(pp2->pp_ref == 0);
f0102927:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010292a:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f010292f:	74 24                	je     f0102955 <i386_vm_init+0xabe>
f0102931:	c7 44 24 0c 3b b8 10 	movl   $0xf010b83b,0xc(%esp)
f0102938:	f0 
f0102939:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102940:	f0 
f0102941:	c7 44 24 04 9c 03 00 	movl   $0x39c,0x4(%esp)
f0102948:	00 
f0102949:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102950:	e8 31 d7 ff ff       	call   f0100086 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(boot_pgdir, (void*) PGSIZE);
f0102955:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010295c:	00 
f010295d:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f0102962:	89 04 24             	mov    %eax,(%esp)
f0102965:	e8 6d ec ff ff       	call   f01015d7 <page_remove>
	assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f010296a:	ba 00 00 00 00       	mov    $0x0,%edx
f010296f:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f0102974:	e8 b3 e8 ff ff       	call   f010122c <check_va2pa>
f0102979:	83 f8 ff             	cmp    $0xffffffff,%eax
f010297c:	74 24                	je     f01029a2 <i386_vm_init+0xb0b>
f010297e:	c7 44 24 0c cc b4 10 	movl   $0xf010b4cc,0xc(%esp)
f0102985:	f0 
f0102986:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f010298d:	f0 
f010298e:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f0102995:	00 
f0102996:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f010299d:	e8 e4 d6 ff ff       	call   f0100086 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == ~0);
f01029a2:	ba 00 10 00 00       	mov    $0x1000,%edx
f01029a7:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f01029ac:	e8 7b e8 ff ff       	call   f010122c <check_va2pa>
f01029b1:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029b4:	74 24                	je     f01029da <i386_vm_init+0xb43>
f01029b6:	c7 44 24 0c f0 b4 10 	movl   $0xf010b4f0,0xc(%esp)
f01029bd:	f0 
f01029be:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f01029c5:	f0 
f01029c6:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f01029cd:	00 
f01029ce:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f01029d5:	e8 ac d6 ff ff       	call   f0100086 <_panic>
	assert(pp1->pp_ref == 0);
f01029da:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01029dd:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f01029e2:	74 24                	je     f0102a08 <i386_vm_init+0xb71>
f01029e4:	c7 44 24 0c 4c b8 10 	movl   $0xf010b84c,0xc(%esp)
f01029eb:	f0 
f01029ec:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f01029f3:	f0 
f01029f4:	c7 44 24 04 a2 03 00 	movl   $0x3a2,0x4(%esp)
f01029fb:	00 
f01029fc:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102a03:	e8 7e d6 ff ff       	call   f0100086 <_panic>
	assert(pp2->pp_ref == 0);
f0102a08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102a0b:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0102a10:	74 24                	je     f0102a36 <i386_vm_init+0xb9f>
f0102a12:	c7 44 24 0c 3b b8 10 	movl   $0xf010b83b,0xc(%esp)
f0102a19:	f0 
f0102a1a:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102a21:	f0 
f0102a22:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f0102a29:	00 
f0102a2a:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102a31:	e8 50 d6 ff ff       	call   f0100086 <_panic>

	// so it should be returned by page_alloc
	assert(page_alloc(&pp) == 0 && pp == pp1);
f0102a36:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0102a39:	89 04 24             	mov    %eax,(%esp)
f0102a3c:	e8 55 e8 ff ff       	call   f0101296 <page_alloc>
f0102a41:	85 c0                	test   %eax,%eax
f0102a43:	75 08                	jne    f0102a4d <i386_vm_init+0xbb6>
f0102a45:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102a48:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0102a4b:	74 24                	je     f0102a71 <i386_vm_init+0xbda>
f0102a4d:	c7 44 24 0c 18 b5 10 	movl   $0xf010b518,0xc(%esp)
f0102a54:	f0 
f0102a55:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102a5c:	f0 
f0102a5d:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0102a64:	00 
f0102a65:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102a6c:	e8 15 d6 ff ff       	call   f0100086 <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0102a71:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0102a74:	89 04 24             	mov    %eax,(%esp)
f0102a77:	e8 1a e8 ff ff       	call   f0101296 <page_alloc>
f0102a7c:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102a7f:	74 24                	je     f0102aa5 <i386_vm_init+0xc0e>
f0102a81:	c7 44 24 0c c4 b7 10 	movl   $0xf010b7c4,0xc(%esp)
f0102a88:	f0 
f0102a89:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102a90:	f0 
f0102a91:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f0102a98:	00 
f0102a99:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102aa0:	e8 e1 d5 ff ff       	call   f0100086 <_panic>
	page_remove(boot_pgdir, 0x0);
	assert(pp2->pp_ref == 0);
#endif

	// forcibly take pp0 back
	assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f0102aa5:	8b 0d f8 54 29 f0    	mov    0xf02954f8,%ecx
f0102aab:	8b 11                	mov    (%ecx),%edx
f0102aad:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102ab3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102ab6:	2b 05 fc 54 29 f0    	sub    0xf02954fc,%eax
f0102abc:	c1 f8 02             	sar    $0x2,%eax
f0102abf:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102ac5:	c1 e0 0c             	shl    $0xc,%eax
f0102ac8:	39 c2                	cmp    %eax,%edx
f0102aca:	74 24                	je     f0102af0 <i386_vm_init+0xc59>
f0102acc:	c7 44 24 0c 38 b2 10 	movl   $0xf010b238,0xc(%esp)
f0102ad3:	f0 
f0102ad4:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102adb:	f0 
f0102adc:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f0102ae3:	00 
f0102ae4:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102aeb:	e8 96 d5 ff ff       	call   f0100086 <_panic>
	boot_pgdir[0] = 0;
f0102af0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102af6:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102af9:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0102afe:	74 24                	je     f0102b24 <i386_vm_init+0xc8d>
f0102b00:	c7 44 24 0c f2 b7 10 	movl   $0xf010b7f2,0xc(%esp)
f0102b07:	f0 
f0102b08:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102b0f:	f0 
f0102b10:	c7 44 24 04 be 03 00 	movl   $0x3be,0x4(%esp)
f0102b17:	00 
f0102b18:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102b1f:	e8 62 d5 ff ff       	call   f0100086 <_panic>
	pp0->pp_ref = 0;
f0102b24:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
	
	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102b2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102b2d:	89 04 24             	mov    %eax,(%esp)
f0102b30:	e8 33 e5 ff ff       	call   f0101068 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(boot_pgdir, va, 1);
f0102b35:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102b3c:	00 
f0102b3d:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102b44:	00 
f0102b45:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f0102b4a:	89 04 24             	mov    %eax,(%esp)
f0102b4d:	e8 99 e7 ff ff       	call   f01012eb <pgdir_walk>
f0102b52:	89 c1                	mov    %eax,%ecx
f0102b54:	89 45 e0             	mov    %eax,-0x20(%ebp)
	ptep1 = KADDR(PTE_ADDR(boot_pgdir[PDX(va)]));
f0102b57:	8b 3d f8 54 29 f0    	mov    0xf02954f8,%edi
f0102b5d:	83 c7 04             	add    $0x4,%edi
f0102b60:	8b 17                	mov    (%edi),%edx
f0102b62:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102b68:	89 d0                	mov    %edx,%eax
f0102b6a:	c1 e8 0c             	shr    $0xc,%eax
f0102b6d:	3b 05 f0 54 29 f0    	cmp    0xf02954f0,%eax
f0102b73:	72 20                	jb     f0102b95 <i386_vm_init+0xcfe>
f0102b75:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102b79:	c7 44 24 08 e8 ac 10 	movl   $0xf010ace8,0x8(%esp)
f0102b80:	f0 
f0102b81:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f0102b88:	00 
f0102b89:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102b90:	e8 f1 d4 ff ff       	call   f0100086 <_panic>
f0102b95:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
f0102b9b:	39 c1                	cmp    %eax,%ecx
f0102b9d:	74 24                	je     f0102bc3 <i386_vm_init+0xd2c>
	assert(ptep == ptep1 + PTX(va));
f0102b9f:	c7 44 24 0c 5d b8 10 	movl   $0xf010b85d,0xc(%esp)
f0102ba6:	f0 
f0102ba7:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102bae:	f0 
f0102baf:	c7 44 24 04 c6 03 00 	movl   $0x3c6,0x4(%esp)
f0102bb6:	00 
f0102bb7:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102bbe:	e8 c3 d4 ff ff       	call   f0100086 <_panic>
	boot_pgdir[PDX(va)] = 0;
f0102bc3:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	pp0->pp_ref = 0;
f0102bc9:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102bcc:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0102bd2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102bd5:	2b 05 fc 54 29 f0    	sub    0xf02954fc,%eax
f0102bdb:	c1 f8 02             	sar    $0x2,%eax
f0102bde:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102be4:	89 c2                	mov    %eax,%edx
f0102be6:	c1 e2 0c             	shl    $0xc,%edx
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0102be9:	89 d0                	mov    %edx,%eax
f0102beb:	c1 e8 0c             	shr    $0xc,%eax
f0102bee:	3b 05 f0 54 29 f0    	cmp    0xf02954f0,%eax
f0102bf4:	72 20                	jb     f0102c16 <i386_vm_init+0xd7f>
f0102bf6:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102bfa:	c7 44 24 08 e8 ac 10 	movl   $0xf010ace8,0x8(%esp)
f0102c01:	f0 
f0102c02:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0102c09:	00 
f0102c0a:	c7 04 24 6f b6 10 f0 	movl   $0xf010b66f,(%esp)
f0102c11:	e8 70 d4 ff ff       	call   f0100086 <_panic>
	
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102c16:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c1d:	00 
f0102c1e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102c25:	00 
f0102c26:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0102c2c:	89 04 24             	mov    %eax,(%esp)
f0102c2f:	e8 aa 6a 00 00       	call   f01096de <memset>
	page_free(pp0);
f0102c34:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102c37:	89 04 24             	mov    %eax,(%esp)
f0102c3a:	e8 29 e4 ff ff       	call   f0101068 <page_free>
	pgdir_walk(boot_pgdir, 0x0, 1);
f0102c3f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102c46:	00 
f0102c47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102c4e:	00 
f0102c4f:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f0102c54:	89 04 24             	mov    %eax,(%esp)
f0102c57:	e8 8f e6 ff ff       	call   f01012eb <pgdir_walk>
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0102c5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102c5f:	2b 05 fc 54 29 f0    	sub    0xf02954fc,%eax
f0102c65:	c1 f8 02             	sar    $0x2,%eax
f0102c68:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102c6e:	89 c2                	mov    %eax,%edx
f0102c70:	c1 e2 0c             	shl    $0xc,%edx
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0102c73:	89 d0                	mov    %edx,%eax
f0102c75:	c1 e8 0c             	shr    $0xc,%eax
f0102c78:	3b 05 f0 54 29 f0    	cmp    0xf02954f0,%eax
f0102c7e:	72 20                	jb     f0102ca0 <i386_vm_init+0xe09>
f0102c80:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102c84:	c7 44 24 08 e8 ac 10 	movl   $0xf010ace8,0x8(%esp)
f0102c8b:	f0 
f0102c8c:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0102c93:	00 
f0102c94:	c7 04 24 6f b6 10 f0 	movl   $0xf010b66f,(%esp)
f0102c9b:	e8 e6 d3 ff ff       	call   f0100086 <_panic>
f0102ca0:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0102ca6:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102ca9:	b8 00 00 00 00       	mov    $0x0,%eax
	ptep = page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102cae:	f6 84 82 00 00 00 f0 	testb  $0x1,-0x10000000(%edx,%eax,4)
f0102cb5:	01 
f0102cb6:	74 24                	je     f0102cdc <i386_vm_init+0xe45>
f0102cb8:	c7 44 24 0c 75 b8 10 	movl   $0xf010b875,0xc(%esp)
f0102cbf:	f0 
f0102cc0:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102cc7:	f0 
f0102cc8:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f0102ccf:	00 
f0102cd0:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102cd7:	e8 aa d3 ff ff       	call   f0100086 <_panic>
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(boot_pgdir, 0x0, 1);
	ptep = page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102cdc:	83 c0 01             	add    $0x1,%eax
f0102cdf:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102ce4:	75 c8                	jne    f0102cae <i386_vm_init+0xe17>
		assert((ptep[i] & PTE_P) == 0);
	boot_pgdir[0] = 0;
f0102ce6:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f0102ceb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102cf1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102cf4:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)

	// give free list back
	page_free_list = fl;
f0102cfa:	89 35 38 45 29 f0    	mov    %esi,0xf0294538

	// free the pages we took
	page_free(pp0);
f0102d00:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102d03:	89 04 24             	mov    %eax,(%esp)
f0102d06:	e8 5d e3 ff ff       	call   f0101068 <page_free>
	page_free(pp1);
f0102d0b:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102d0e:	89 04 24             	mov    %eax,(%esp)
f0102d11:	e8 52 e3 ff ff       	call   f0101068 <page_free>
	page_free(pp2);
f0102d16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102d19:	89 04 24             	mov    %eax,(%esp)
f0102d1c:	e8 47 e3 ff ff       	call   f0101068 <page_free>
	
	cprintf("page_check() succeeded!\n");
f0102d21:	c7 04 24 8c b8 10 f0 	movl   $0xf010b88c,(%esp)
f0102d28:	e8 ba 0c 00 00       	call   f01039e7 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_segment(boot_pgdir,UPAGES,npage*sizeof(struct Page),PADDR(pages),PTE_U|PTE_P);
f0102d2d:	a1 fc 54 29 f0       	mov    0xf02954fc,%eax
f0102d32:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d37:	77 20                	ja     f0102d59 <i386_vm_init+0xec2>
f0102d39:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d3d:	c7 44 24 08 6c b0 10 	movl   $0xf010b06c,0x8(%esp)
f0102d44:	f0 
f0102d45:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
f0102d4c:	00 
f0102d4d:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102d54:	e8 2d d3 ff ff       	call   f0100086 <_panic>
f0102d59:	8b 0d f0 54 29 f0    	mov    0xf02954f0,%ecx
f0102d5f:	8d 0c 49             	lea    (%ecx,%ecx,2),%ecx
f0102d62:	c1 e1 02             	shl    $0x2,%ecx
f0102d65:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102d6c:	00 
f0102d6d:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d72:	89 04 24             	mov    %eax,(%esp)
f0102d75:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102d7a:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f0102d7f:	e8 ae e8 ff ff       	call   f0101632 <boot_map_segment>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_segment(boot_pgdir,UENVS,NENV*sizeof(struct Env),PADDR(envs),PTE_U|PTE_P);
f0102d84:	a1 40 45 29 f0       	mov    0xf0294540,%eax
f0102d89:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d8e:	77 20                	ja     f0102db0 <i386_vm_init+0xf19>
f0102d90:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d94:	c7 44 24 08 6c b0 10 	movl   $0xf010b06c,0x8(%esp)
f0102d9b:	f0 
f0102d9c:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
f0102da3:	00 
f0102da4:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102dab:	e8 d6 d2 ff ff       	call   f0100086 <_panic>
f0102db0:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102db7:	00 
f0102db8:	05 00 00 00 10       	add    $0x10000000,%eax
f0102dbd:	89 04 24             	mov    %eax,(%esp)
f0102dc0:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102dc5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102dca:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f0102dcf:	e8 5e e8 ff ff       	call   f0101632 <boot_map_segment>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_segment(boot_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W |PTE_P);
f0102dd4:	b8 00 90 12 f0       	mov    $0xf0129000,%eax
f0102dd9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102dde:	77 20                	ja     f0102e00 <i386_vm_init+0xf69>
f0102de0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102de4:	c7 44 24 08 6c b0 10 	movl   $0xf010b06c,0x8(%esp)
f0102deb:	f0 
f0102dec:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
f0102df3:	00 
f0102df4:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102dfb:	e8 86 d2 ff ff       	call   f0100086 <_panic>
f0102e00:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102e07:	00 
f0102e08:	05 00 00 00 10       	add    $0x10000000,%eax
f0102e0d:	89 04 24             	mov    %eax,(%esp)
f0102e10:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102e15:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f0102e1a:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f0102e1f:	e8 0e e8 ff ff       	call   f0101632 <boot_map_segment>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here: 
	boot_map_segment(boot_pgdir,KERNBASE,0xffffffff-KERNBASE,0x0,PTE_W | PTE_P);
f0102e24:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102e2b:	00 
f0102e2c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102e33:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102e38:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102e3d:	a1 f8 54 29 f0       	mov    0xf02954f8,%eax
f0102e42:	e8 eb e7 ff ff       	call   f0101632 <boot_map_segment>
check_boot_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = boot_pgdir;
f0102e47:	8b 3d f8 54 29 f0    	mov    0xf02954f8,%edi

	// check pages array
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
f0102e4d:	a1 f0 54 29 f0       	mov    0xf02954f0,%eax
f0102e52:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102e55:	8d 04 85 ff 0f 00 00 	lea    0xfff(,%eax,4),%eax
	for (i = 0; i < n; i += PGSIZE)
f0102e5c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102e61:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102e64:	74 7a                	je     f0102ee0 <i386_vm_init+0x1049>
f0102e66:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e6b:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0102e71:	89 f8                	mov    %edi,%eax
f0102e73:	e8 b4 e3 ff ff       	call   f010122c <check_va2pa>
f0102e78:	89 c2                	mov    %eax,%edx
f0102e7a:	a1 fc 54 29 f0       	mov    0xf02954fc,%eax
f0102e7f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e84:	77 20                	ja     f0102ea6 <i386_vm_init+0x100f>
f0102e86:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102e8a:	c7 44 24 08 6c b0 10 	movl   $0xf010b06c,0x8(%esp)
f0102e91:	f0 
f0102e92:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
f0102e99:	00 
f0102e9a:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102ea1:	e8 e0 d1 ff ff       	call   f0100086 <_panic>
f0102ea6:	8d 84 06 00 00 00 10 	lea    0x10000000(%esi,%eax,1),%eax
f0102ead:	39 c2                	cmp    %eax,%edx
f0102eaf:	74 24                	je     f0102ed5 <i386_vm_init+0x103e>
f0102eb1:	c7 44 24 0c 3c b5 10 	movl   $0xf010b53c,0xc(%esp)
f0102eb8:	f0 
f0102eb9:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102ec0:	f0 
f0102ec1:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
f0102ec8:	00 
f0102ec9:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102ed0:	e8 b1 d1 ff ff       	call   f0100086 <_panic>

	pgdir = boot_pgdir;

	// check pages array
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102ed5:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102edb:	39 75 d0             	cmp    %esi,-0x30(%ebp)
f0102ede:	77 8b                	ja     f0102e6b <i386_vm_init+0xfd4>
f0102ee0:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
	
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102ee5:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
f0102eeb:	89 f8                	mov    %edi,%eax
f0102eed:	e8 3a e3 ff ff       	call   f010122c <check_va2pa>
f0102ef2:	89 c2                	mov    %eax,%edx
f0102ef4:	a1 40 45 29 f0       	mov    0xf0294540,%eax
f0102ef9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102efe:	77 20                	ja     f0102f20 <i386_vm_init+0x1089>
f0102f00:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102f04:	c7 44 24 08 6c b0 10 	movl   $0xf010b06c,0x8(%esp)
f0102f0b:	f0 
f0102f0c:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
f0102f13:	00 
f0102f14:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102f1b:	e8 66 d1 ff ff       	call   f0100086 <_panic>
f0102f20:	8d 84 06 00 00 00 10 	lea    0x10000000(%esi,%eax,1),%eax
f0102f27:	39 c2                	cmp    %eax,%edx
f0102f29:	74 24                	je     f0102f4f <i386_vm_init+0x10b8>
f0102f2b:	c7 44 24 0c 70 b5 10 	movl   $0xf010b570,0xc(%esp)
f0102f32:	f0 
f0102f33:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102f3a:	f0 
f0102f3b:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
f0102f42:	00 
f0102f43:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102f4a:	e8 37 d1 ff ff       	call   f0100086 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
	
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102f4f:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102f55:	81 fe 00 f0 01 00    	cmp    $0x1f000,%esi
f0102f5b:	75 88                	jne    f0102ee5 <i386_vm_init+0x104e>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npage * PGSIZE; i += PGSIZE)
f0102f5d:	a1 f0 54 29 f0       	mov    0xf02954f0,%eax
f0102f62:	c1 e0 0c             	shl    $0xc,%eax
f0102f65:	85 c0                	test   %eax,%eax
f0102f67:	74 4c                	je     f0102fb5 <i386_vm_init+0x111e>
f0102f69:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102f6e:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102f74:	89 f8                	mov    %edi,%eax
f0102f76:	e8 b1 e2 ff ff       	call   f010122c <check_va2pa>
f0102f7b:	39 f0                	cmp    %esi,%eax
f0102f7d:	74 24                	je     f0102fa3 <i386_vm_init+0x110c>
f0102f7f:	c7 44 24 0c a4 b5 10 	movl   $0xf010b5a4,0xc(%esp)
f0102f86:	f0 
f0102f87:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102f8e:	f0 
f0102f8f:	c7 44 24 04 8b 01 00 	movl   $0x18b,0x4(%esp)
f0102f96:	00 
f0102f97:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102f9e:	e8 e3 d0 ff ff       	call   f0100086 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npage * PGSIZE; i += PGSIZE)
f0102fa3:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
f0102fa9:	a1 f0 54 29 f0       	mov    0xf02954f0,%eax
f0102fae:	c1 e0 0c             	shl    $0xc,%eax
f0102fb1:	39 f0                	cmp    %esi,%eax
f0102fb3:	77 b9                	ja     f0102f6e <i386_vm_init+0x10d7>
f0102fb5:	be 00 80 bf ef       	mov    $0xefbf8000,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102fba:	89 f2                	mov    %esi,%edx
f0102fbc:	89 f8                	mov    %edi,%eax
f0102fbe:	e8 69 e2 ff ff       	call   f010122c <check_va2pa>
f0102fc3:	8d 96 00 10 53 10    	lea    0x10531000(%esi),%edx
f0102fc9:	39 d0                	cmp    %edx,%eax
f0102fcb:	74 24                	je     f0102ff1 <i386_vm_init+0x115a>
f0102fcd:	c7 44 24 0c cc b5 10 	movl   $0xf010b5cc,0xc(%esp)
f0102fd4:	f0 
f0102fd5:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0102fdc:	f0 
f0102fdd:	c7 44 24 04 8f 01 00 	movl   $0x18f,0x4(%esp)
f0102fe4:	00 
f0102fe5:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0102fec:	e8 95 d0 ff ff       	call   f0100086 <_panic>
f0102ff1:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npage * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102ff7:	81 fe 00 00 c0 ef    	cmp    $0xefc00000,%esi
f0102ffd:	75 bb                	jne    f0102fba <i386_vm_init+0x1123>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102fff:	ba 00 00 80 ef       	mov    $0xef800000,%edx
f0103004:	89 f8                	mov    %edi,%eax
f0103006:	e8 21 e2 ff ff       	call   f010122c <check_va2pa>
f010300b:	ba 00 00 00 00       	mov    $0x0,%edx
f0103010:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103013:	74 24                	je     f0103039 <i386_vm_init+0x11a2>
f0103015:	c7 44 24 0c 14 b6 10 	movl   $0xf010b614,0xc(%esp)
f010301c:	f0 
f010301d:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0103024:	f0 
f0103025:	c7 44 24 04 90 01 00 	movl   $0x190,0x4(%esp)
f010302c:	00 
f010302d:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f0103034:	e8 4d d0 ff ff       	call   f0100086 <_panic>

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0103039:	8d 82 45 fc ff ff    	lea    -0x3bb(%edx),%eax
f010303f:	83 f8 04             	cmp    $0x4,%eax
f0103042:	77 2e                	ja     f0103072 <i386_vm_init+0x11db>
		case PDX(VPT):
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i]);
f0103044:	83 3c 97 00          	cmpl   $0x0,(%edi,%edx,4)
f0103048:	0f 85 80 00 00 00    	jne    f01030ce <i386_vm_init+0x1237>
f010304e:	c7 44 24 0c a5 b8 10 	movl   $0xf010b8a5,0xc(%esp)
f0103055:	f0 
f0103056:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f010305d:	f0 
f010305e:	c7 44 24 04 9a 01 00 	movl   $0x19a,0x4(%esp)
f0103065:	00 
f0103066:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f010306d:	e8 14 d0 ff ff       	call   f0100086 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE))
f0103072:	81 fa bf 03 00 00    	cmp    $0x3bf,%edx
f0103078:	76 2a                	jbe    f01030a4 <i386_vm_init+0x120d>
				assert(pgdir[i]);
f010307a:	83 3c 97 00          	cmpl   $0x0,(%edi,%edx,4)
f010307e:	75 4e                	jne    f01030ce <i386_vm_init+0x1237>
f0103080:	c7 44 24 0c a5 b8 10 	movl   $0xf010b8a5,0xc(%esp)
f0103087:	f0 
f0103088:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f010308f:	f0 
f0103090:	c7 44 24 04 9e 01 00 	movl   $0x19e,0x4(%esp)
f0103097:	00 
f0103098:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f010309f:	e8 e2 cf ff ff       	call   f0100086 <_panic>
			else
				assert(pgdir[i] == 0);
f01030a4:	83 3c 97 00          	cmpl   $0x0,(%edi,%edx,4)
f01030a8:	74 24                	je     f01030ce <i386_vm_init+0x1237>
f01030aa:	c7 44 24 0c ae b8 10 	movl   $0xf010b8ae,0xc(%esp)
f01030b1:	f0 
f01030b2:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f01030b9:	f0 
f01030ba:	c7 44 24 04 a0 01 00 	movl   $0x1a0,0x4(%esp)
f01030c1:	00 
f01030c2:	c7 04 24 63 b6 10 f0 	movl   $0xf010b663,(%esp)
f01030c9:	e8 b8 cf ff ff       	call   f0100086 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) {
f01030ce:	83 c2 01             	add    $0x1,%edx
f01030d1:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f01030d7:	0f 85 5c ff ff ff    	jne    f0103039 <i386_vm_init+0x11a2>
			else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_boot_pgdir() succeeded!\n");
f01030dd:	c7 04 24 44 b6 10 f0 	movl   $0xf010b644,(%esp)
f01030e4:	e8 fe 08 00 00       	call   f01039e7 <cprintf>
	// mapping, even though we are turning on paging and reconfiguring
	// segmentation.

	// Map VA 0:4MB same as VA KERNBASE, i.e. to PA 0:4MB.
	// (Limits our kernel to <4MB)
	pgdir[0] = pgdir[PDX(KERNBASE)];
f01030e9:	8b 83 00 0f 00 00    	mov    0xf00(%ebx),%eax
f01030ef:	89 03                	mov    %eax,(%ebx)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01030f1:	a1 f4 54 29 f0       	mov    0xf02954f4,%eax
f01030f6:	0f 22 d8             	mov    %eax,%cr3

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01030f9:	0f 20 c0             	mov    %cr0,%eax
	// Install page table.
	lcr3(boot_cr3);

	// Turn on paging.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_TS|CR0_EM|CR0_MP;
f01030fc:	0d 2f 00 05 80       	or     $0x8005002f,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0103101:	83 e0 f3             	and    $0xfffffff3,%eax
f0103104:	0f 22 c0             	mov    %eax,%cr0

	// Current mapping: KERNBASE+x => x => x.
	// (x < 4MB so uses paging pgdir[0])

	// Reload all segment registers.
	asm volatile("lgdt gdt_pd");
f0103107:	0f 01 15 50 13 13 f0 	lgdtl  0xf0131350
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f010310e:	b8 23 00 00 00       	mov    $0x23,%eax
f0103113:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103115:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103117:	b0 10                	mov    $0x10,%al
f0103119:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f010311b:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010311d:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));  // reload cs
f010311f:	ea 26 31 10 f0 08 00 	ljmp   $0x8,$0xf0103126
	asm volatile("lldt %%ax" :: "a" (0));
f0103126:	b0 00                	mov    $0x0,%al
f0103128:	0f 00 d0             	lldt   %ax

	// Final mapping: KERNBASE+x => KERNBASE+x => x.

	// This mapping was only used after paging was turned on but
	// before the segment registers were reloaded.
	pgdir[0] = 0;
f010312b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103131:	a1 f4 54 29 f0       	mov    0xf02954f4,%eax
f0103136:	0f 22 d8             	mov    %eax,%cr3

	// Flush the TLB for good measure, to kill the pgdir[0] mapping.
	lcr3(boot_cr3);
}
f0103139:	83 c4 3c             	add    $0x3c,%esp
f010313c:	5b                   	pop    %ebx
f010313d:	5e                   	pop    %esi
f010313e:	5f                   	pop    %edi
f010313f:	5d                   	pop    %ebp
f0103140:	c3                   	ret    
f0103141:	00 00                	add    %al,(%eax)
	...

f0103144 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103144:	55                   	push   %ebp
f0103145:	89 e5                	mov    %esp,%ebp
f0103147:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Env *e;
	//0代表当前对象
	// If envid is zero, return the current environment.
	if (envid == 0) {
f010314a:	85 d2                	test   %edx,%edx
f010314c:	75 11                	jne    f010315f <envid2env+0x1b>
		*env_store = curenv;
f010314e:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f0103153:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103156:	89 02                	mov    %eax,(%edx)
f0103158:	b8 00 00 00 00       	mov    $0x0,%eax
f010315d:	eb 5f                	jmp    f01031be <envid2env+0x7a>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010315f:	89 d0                	mov    %edx,%eax
f0103161:	25 ff 03 00 00       	and    $0x3ff,%eax
f0103166:	6b c0 7c             	imul   $0x7c,%eax,%eax
f0103169:	89 c1                	mov    %eax,%ecx
f010316b:	03 0d 40 45 29 f0    	add    0xf0294540,%ecx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103171:	83 79 54 00          	cmpl   $0x0,0x54(%ecx)
f0103175:	74 05                	je     f010317c <envid2env+0x38>
f0103177:	39 51 4c             	cmp    %edx,0x4c(%ecx)
f010317a:	74 10                	je     f010318c <envid2env+0x48>
		*env_store = 0;
f010317c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010317f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0103185:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010318a:	eb 32                	jmp    f01031be <envid2env+0x7a>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010318c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0103190:	74 22                	je     f01031b4 <envid2env+0x70>
f0103192:	8b 15 44 45 29 f0    	mov    0xf0294544,%edx
f0103198:	39 d1                	cmp    %edx,%ecx
f010319a:	74 18                	je     f01031b4 <envid2env+0x70>
f010319c:	8b 41 50             	mov    0x50(%ecx),%eax
f010319f:	3b 42 4c             	cmp    0x4c(%edx),%eax
f01031a2:	74 10                	je     f01031b4 <envid2env+0x70>
		*env_store = 0;
f01031a4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01031a7:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
f01031ad:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01031b2:	eb 0a                	jmp    f01031be <envid2env+0x7a>
		return -E_BAD_ENV;
	}

	*env_store = e;
f01031b4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031b7:	89 08                	mov    %ecx,(%eax)
f01031b9:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f01031be:	5d                   	pop    %ebp
f01031bf:	c3                   	ret    

f01031c0 <env_init>:
// Insert in reverse order, so that the first call to env_alloc()
// returns envs[0].
//
void
env_init(void)
{
f01031c0:	55                   	push   %ebp
f01031c1:	89 e5                	mov    %esp,%ebp
f01031c3:	53                   	push   %ebx
	// LAB 3: Your code here.
	int i;
	LIST_INIT(&env_free_list);
f01031c4:	c7 05 48 45 29 f0 00 	movl   $0x0,0xf0294548
f01031cb:	00 00 00 
f01031ce:	b9 84 ef 01 00       	mov    $0x1ef84,%ecx
f01031d3:	89 cb                	mov    %ecx,%ebx
	for(i=NENV-1;i>=0;i--)
	{
		envs[i].env_id=0;
f01031d5:	a1 40 45 29 f0       	mov    0xf0294540,%eax
f01031da:	c7 44 08 4c 00 00 00 	movl   $0x0,0x4c(%eax,%ecx,1)
f01031e1:	00 
		envs[i].env_status=ENV_FREE;
f01031e2:	a1 40 45 29 f0       	mov    0xf0294540,%eax
f01031e7:	c7 44 08 54 00 00 00 	movl   $0x0,0x54(%eax,%ecx,1)
f01031ee:	00 
		LIST_INSERT_HEAD(&env_free_list,&envs[i],env_link);	
f01031ef:	8b 15 48 45 29 f0    	mov    0xf0294548,%edx
f01031f5:	a1 40 45 29 f0       	mov    0xf0294540,%eax
f01031fa:	89 54 08 44          	mov    %edx,0x44(%eax,%ecx,1)
f01031fe:	85 d2                	test   %edx,%edx
f0103200:	74 14                	je     f0103216 <env_init+0x56>
f0103202:	89 c8                	mov    %ecx,%eax
f0103204:	03 05 40 45 29 f0    	add    0xf0294540,%eax
f010320a:	83 c0 44             	add    $0x44,%eax
f010320d:	8b 15 48 45 29 f0    	mov    0xf0294548,%edx
f0103213:	89 42 48             	mov    %eax,0x48(%edx)
f0103216:	89 d8                	mov    %ebx,%eax
f0103218:	03 05 40 45 29 f0    	add    0xf0294540,%eax
f010321e:	a3 48 45 29 f0       	mov    %eax,0xf0294548
f0103223:	c7 40 48 48 45 29 f0 	movl   $0xf0294548,0x48(%eax)
f010322a:	83 e9 7c             	sub    $0x7c,%ecx
env_init(void)
{
	// LAB 3: Your code here.
	int i;
	LIST_INIT(&env_free_list);
	for(i=NENV-1;i>=0;i--)
f010322d:	83 f9 84             	cmp    $0xffffff84,%ecx
f0103230:	75 a1                	jne    f01031d3 <env_init+0x13>
	{
		envs[i].env_id=0;
		envs[i].env_status=ENV_FREE;
		LIST_INSERT_HEAD(&env_free_list,&envs[i],env_link);	
	}
}
f0103232:	5b                   	pop    %ebx
f0103233:	5d                   	pop    %ebp
f0103234:	c3                   	ret    

f0103235 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103235:	55                   	push   %ebp
f0103236:	89 e5                	mov    %esp,%ebp
f0103238:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f010323b:	8b 65 08             	mov    0x8(%ebp),%esp
f010323e:	61                   	popa   
f010323f:	07                   	pop    %es
f0103240:	1f                   	pop    %ds
f0103241:	83 c4 08             	add    $0x8,%esp
f0103244:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103245:	c7 44 24 08 bc b8 10 	movl   $0xf010b8bc,0x8(%esp)
f010324c:	f0 
f010324d:	c7 44 24 04 b8 01 00 	movl   $0x1b8,0x4(%esp)
f0103254:	00 
f0103255:	c7 04 24 c8 b8 10 f0 	movl   $0xf010b8c8,(%esp)
f010325c:	e8 25 ce ff ff       	call   f0100086 <_panic>

f0103261 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103261:	55                   	push   %ebp
f0103262:	89 e5                	mov    %esp,%ebp
f0103264:	83 ec 08             	sub    $0x8,%esp
f0103267:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.
	
	// LAB 3: Your code here.
	curenv=e;
f010326a:	a3 44 45 29 f0       	mov    %eax,0xf0294544
	curenv->env_runs++;
f010326f:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(curenv->env_cr3);
f0103273:	8b 15 44 45 29 f0    	mov    0xf0294544,%edx
f0103279:	8b 42 60             	mov    0x60(%edx),%eax
f010327c:	0f 22 d8             	mov    %eax,%cr3
	//cprintf("\nenv_run:curenvid=%x\n",curenv->env_id);
	env_pop_tf(&curenv->env_tf);
f010327f:	89 14 24             	mov    %edx,(%esp)
f0103282:	e8 ae ff ff ff       	call   f0103235 <env_pop_tf>

f0103287 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103287:	55                   	push   %ebp
f0103288:	89 e5                	mov    %esp,%ebp
f010328a:	53                   	push   %ebx
f010328b:	83 ec 24             	sub    $0x24,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = LIST_FIRST(&env_free_list)))
f010328e:	8b 1d 48 45 29 f0    	mov    0xf0294548,%ebx
f0103294:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103299:	85 db                	test   %ebx,%ebx
f010329b:	0f 84 9e 01 00 00    	je     f010343f <env_alloc+0x1b8>
//
static int
env_setup_vm(struct Env *e)
{
	int i, r;
	struct Page *p = NULL;
f01032a1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// Allocate a page for the page directory
	if ((r = page_alloc(&p)) < 0)
f01032a8:	8d 45 f8             	lea    -0x8(%ebp),%eax
f01032ab:	89 04 24             	mov    %eax,(%esp)
f01032ae:	e8 e3 df ff ff       	call   f0101296 <page_alloc>
f01032b3:	85 c0                	test   %eax,%eax
f01032b5:	0f 88 84 01 00 00    	js     f010343f <env_alloc+0x1b8>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_cr3=page2pa(p);
f01032bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01032be:	2b 05 fc 54 29 f0    	sub    0xf02954fc,%eax
f01032c4:	c1 f8 02             	sar    $0x2,%eax
f01032c7:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01032cd:	c1 e0 0c             	shl    $0xc,%eax
f01032d0:	89 43 60             	mov    %eax,0x60(%ebx)
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f01032d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01032d6:	2b 05 fc 54 29 f0    	sub    0xf02954fc,%eax
f01032dc:	c1 f8 02             	sar    $0x2,%eax
f01032df:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01032e5:	89 c2                	mov    %eax,%edx
f01032e7:	c1 e2 0c             	shl    $0xc,%edx
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f01032ea:	89 d0                	mov    %edx,%eax
f01032ec:	c1 e8 0c             	shr    $0xc,%eax
f01032ef:	3b 05 f0 54 29 f0    	cmp    0xf02954f0,%eax
f01032f5:	72 20                	jb     f0103317 <env_alloc+0x90>
f01032f7:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01032fb:	c7 44 24 08 e8 ac 10 	movl   $0xf010ace8,0x8(%esp)
f0103302:	f0 
f0103303:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f010330a:	00 
f010330b:	c7 04 24 6f b6 10 f0 	movl   $0xf010b66f,(%esp)
f0103312:	e8 6f cd ff ff       	call   f0100086 <_panic>
f0103317:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f010331d:	89 43 5c             	mov    %eax,0x5c(%ebx)
	e->env_pgdir=(pde_t*)page2kva(p);
	p->pp_ref++;
f0103320:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0103323:	66 83 40 08 01       	addw   $0x1,0x8(%eax)
	memset(e->env_pgdir,0,PGSIZE);//initialize env's pgdir
f0103328:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010332f:	00 
f0103330:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103337:	00 
f0103338:	8b 43 5c             	mov    0x5c(%ebx),%eax
f010333b:	89 04 24             	mov    %eax,(%esp)
f010333e:	e8 9b 63 00 00       	call   f01096de <memset>
f0103343:	b9 ec 0e 00 00       	mov    $0xeec,%ecx
	for(i=PDX(UTOP);i<NPDENTRIES;i++)//内核部分映射，直接从boot_pgdir拷贝
		e->env_pgdir[i]=boot_pgdir[i];
f0103348:	8b 43 5c             	mov    0x5c(%ebx),%eax
f010334b:	8b 15 f8 54 29 f0    	mov    0xf02954f8,%edx
f0103351:	8b 14 0a             	mov    (%edx,%ecx,1),%edx
f0103354:	89 14 08             	mov    %edx,(%eax,%ecx,1)
f0103357:	83 c1 04             	add    $0x4,%ecx
	// LAB 3: Your code here.
	e->env_cr3=page2pa(p);
	e->env_pgdir=(pde_t*)page2kva(p);
	p->pp_ref++;
	memset(e->env_pgdir,0,PGSIZE);//initialize env's pgdir
	for(i=PDX(UTOP);i<NPDENTRIES;i++)//内核部分映射，直接从boot_pgdir拷贝
f010335a:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
f0103360:	75 e6                	jne    f0103348 <env_alloc+0xc1>
		e->env_pgdir[i]=boot_pgdir[i];
	// VPT and UVPT map the env's own page table, with
	// different permissions.
	e->env_pgdir[PDX(VPT)]  = e->env_cr3 | PTE_P | PTE_W;
f0103362:	8b 53 5c             	mov    0x5c(%ebx),%edx
f0103365:	8b 43 60             	mov    0x60(%ebx),%eax
f0103368:	83 c8 03             	or     $0x3,%eax
f010336b:	89 82 fc 0e 00 00    	mov    %eax,0xefc(%edx)
	e->env_pgdir[PDX(UVPT)] = e->env_cr3 | PTE_P | PTE_U;
f0103371:	8b 53 5c             	mov    0x5c(%ebx),%edx
f0103374:	8b 43 60             	mov    0x60(%ebx),%eax
f0103377:	83 c8 05             	or     $0x5,%eax
f010337a:	89 82 f4 0e 00 00    	mov    %eax,0xef4(%edx)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103380:	8b 43 4c             	mov    0x4c(%ebx),%eax
f0103383:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103388:	89 c2                	mov    %eax,%edx
f010338a:	81 e2 00 fc ff ff    	and    $0xfffffc00,%edx
f0103390:	7f 05                	jg     f0103397 <env_alloc+0x110>
f0103392:	ba 00 10 00 00       	mov    $0x1000,%edx
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f0103397:	89 d8                	mov    %ebx,%eax
f0103399:	2b 05 40 45 29 f0    	sub    0xf0294540,%eax
f010339f:	c1 f8 02             	sar    $0x2,%eax
f01033a2:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
f01033a8:	09 d0                	or     %edx,%eax
f01033aa:	89 43 4c             	mov    %eax,0x4c(%ebx)
	
	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01033ad:	8b 45 0c             	mov    0xc(%ebp),%eax
f01033b0:	89 43 50             	mov    %eax,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01033b3:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
	e->env_runs = 0;
f01033ba:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01033c1:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f01033c8:	00 
f01033c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01033d0:	00 
f01033d1:	89 1c 24             	mov    %ebx,(%esp)
f01033d4:	e8 05 63 00 00       	call   f01096de <memset>
	// Set up appropriate initial values for the segment registers.
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.
	e->env_tf.tf_ds = GD_UD | 3;
f01033d9:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01033df:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01033e5:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01033eb:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01033f2:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags|=FL_IF;
f01033f8:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01033ff:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103406:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)

	// If this is the file server (e == &envs[1]) give it I/O privileges.
	// LAB 5: Your code here.
	if(e==&envs[1])
f010340d:	a1 40 45 29 f0       	mov    0xf0294540,%eax
f0103412:	83 c0 7c             	add    $0x7c,%eax
f0103415:	39 d8                	cmp    %ebx,%eax
f0103417:	75 07                	jne    f0103420 <env_alloc+0x199>
		e->env_tf.tf_eflags|=FL_IOPL_3;
f0103419:	81 4b 38 00 30 00 00 	orl    $0x3000,0x38(%ebx)
	// commit the allocation
	LIST_REMOVE(e, env_link);
f0103420:	8b 53 44             	mov    0x44(%ebx),%edx
f0103423:	85 d2                	test   %edx,%edx
f0103425:	74 06                	je     f010342d <env_alloc+0x1a6>
f0103427:	8b 43 48             	mov    0x48(%ebx),%eax
f010342a:	89 42 48             	mov    %eax,0x48(%edx)
f010342d:	8b 53 48             	mov    0x48(%ebx),%edx
f0103430:	8b 43 44             	mov    0x44(%ebx),%eax
f0103433:	89 02                	mov    %eax,(%edx)
	*newenv_store = e;
f0103435:	8b 45 08             	mov    0x8(%ebp),%eax
f0103438:	89 18                	mov    %ebx,(%eax)
f010343a:	b8 00 00 00 00       	mov    $0x0,%eax

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f010343f:	83 c4 24             	add    $0x24,%esp
f0103442:	5b                   	pop    %ebx
f0103443:	5d                   	pop    %ebp
f0103444:	c3                   	ret    

f0103445 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size)
{
f0103445:	55                   	push   %ebp
f0103446:	89 e5                	mov    %esp,%ebp
f0103448:	57                   	push   %edi
f0103449:	56                   	push   %esi
f010344a:	53                   	push   %ebx
f010344b:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 3: Your code here.
	int r;
	struct Env *newenv;
	if((r=env_alloc(&newenv,0))<0)
f010344e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103455:	00 
f0103456:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0103459:	89 04 24             	mov    %eax,(%esp)
f010345c:	e8 26 fe ff ff       	call   f0103287 <env_alloc>
f0103461:	85 c0                	test   %eax,%eax
f0103463:	79 20                	jns    f0103485 <env_create+0x40>
		panic("env_create:%e",r);
f0103465:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103469:	c7 44 24 08 d3 b8 10 	movl   $0xf010b8d3,0x8(%esp)
f0103470:	f0 
f0103471:	c7 44 24 04 5e 01 00 	movl   $0x15e,0x4(%esp)
f0103478:	00 
f0103479:	c7 04 24 c8 b8 10 f0 	movl   $0xf010b8c8,(%esp)
f0103480:	e8 01 cc ff ff       	call   f0100086 <_panic>
	load_icode(newenv,binary,size);
f0103485:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103488:	89 45 e0             	mov    %eax,-0x20(%ebp)

static __inline uint32_t
rcr3(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr3,%0" : "=r" (val));
f010348b:	0f 20 da             	mov    %cr3,%edx
f010348e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103491:	8b 40 60             	mov    0x60(%eax),%eax
f0103494:	0f 22 d8             	mov    %eax,%cr3
	struct Proghdr *ph,*eph;
	struct Page *onepage;
	
	old_cr3=rcr3();//要在新环境中加载用户程序，所以必须切换到新环境的页目录
	lcr3(e->env_cr3);
	elfhdr=(struct Elf*)binary;
f0103497:	8b 45 08             	mov    0x8(%ebp),%eax
f010349a:	89 45 dc             	mov    %eax,-0x24(%ebp)

	if(elfhdr->e_magic!=ELF_MAGIC)
f010349d:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f01034a3:	74 1c                	je     f01034c1 <env_create+0x7c>
		panic("This binary is not ELF format!\n");
f01034a5:	c7 44 24 08 14 b9 10 	movl   $0xf010b914,0x8(%esp)
f01034ac:	f0 
f01034ad:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
f01034b4:	00 
f01034b5:	c7 04 24 c8 b8 10 f0 	movl   $0xf010b8c8,(%esp)
f01034bc:	e8 c5 cb ff ff       	call   f0100086 <_panic>
	ph = (struct Proghdr*)(binary+elfhdr->e_phoff);
f01034c1:	8b 75 08             	mov    0x8(%ebp),%esi
f01034c4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034c7:	03 72 1c             	add    0x1c(%edx),%esi
	eph = ph+elfhdr->e_phnum;
f01034ca:	0f b7 42 2c          	movzwl 0x2c(%edx),%eax
f01034ce:	c1 e0 05             	shl    $0x5,%eax
f01034d1:	01 f0                	add    %esi,%eax
f01034d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
	for(;ph<eph;ph++){
f01034d6:	39 c6                	cmp    %eax,%esi
f01034d8:	0f 83 de 00 00 00    	jae    f01035bc <env_create+0x177>
		if(ph->p_type == ELF_PROG_LOAD)
f01034de:	83 3e 01             	cmpl   $0x1,(%esi)
f01034e1:	0f 85 c9 00 00 00    	jne    f01035b0 <env_create+0x16b>
		{
			segment_alloc(e,(void*)ph->p_va,ph->p_memsz);
f01034e7:	8b 46 08             	mov    0x8(%esi),%eax
	// Hint: It is easier to use segment_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	uintptr_t a,last;
	struct Page *onepage;
	a=ROUNDDOWN((physaddr_t)va,PGSIZE);
f01034ea:	89 c3                	mov    %eax,%ebx
f01034ec:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	last=ROUNDDOWN((physaddr_t)(va+len),PGSIZE);
f01034f2:	03 46 14             	add    0x14(%esi),%eax
f01034f5:	89 c7                	mov    %eax,%edi
f01034f7:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for(;;){
		if(page_alloc(&onepage)<0)
f01034fd:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0103500:	89 04 24             	mov    %eax,(%esp)
f0103503:	e8 8e dd ff ff       	call   f0101296 <page_alloc>
f0103508:	85 c0                	test   %eax,%eax
f010350a:	79 1c                	jns    f0103528 <env_create+0xe3>
			panic("Alloc physical page failed!\n");
f010350c:	c7 44 24 08 e1 b8 10 	movl   $0xf010b8e1,0x8(%esp)
f0103513:	f0 
f0103514:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
f010351b:	00 
f010351c:	c7 04 24 c8 b8 10 f0 	movl   $0xf010b8c8,(%esp)
f0103523:	e8 5e cb ff ff       	call   f0100086 <_panic>
		//cprintf("segment_alloc:onepage physaddr=%x\n",page2pa(onepage));
		if(page_insert(e->env_pgdir,onepage,(void*)a,PTE_U|PTE_W)<0)
f0103528:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010352f:	00 
f0103530:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103534:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103537:	89 44 24 04          	mov    %eax,0x4(%esp)
f010353b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010353e:	8b 42 5c             	mov    0x5c(%edx),%eax
f0103541:	89 04 24             	mov    %eax,(%esp)
f0103544:	e8 72 e1 ff ff       	call   f01016bb <page_insert>
f0103549:	85 c0                	test   %eax,%eax
f010354b:	79 1c                	jns    f0103569 <env_create+0x124>
			panic("Insert page failed!\n");
f010354d:	c7 44 24 08 fe b8 10 	movl   $0xf010b8fe,0x8(%esp)
f0103554:	f0 
f0103555:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
f010355c:	00 
f010355d:	c7 04 24 c8 b8 10 f0 	movl   $0xf010b8c8,(%esp)
f0103564:	e8 1d cb ff ff       	call   f0100086 <_panic>
		if(a==last) break;
f0103569:	39 fb                	cmp    %edi,%ebx
f010356b:	74 08                	je     f0103575 <env_create+0x130>
		a=a+PGSIZE;
f010356d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103573:	eb 88                	jmp    f01034fd <env_create+0xb8>
	for(;ph<eph;ph++){
		if(ph->p_type == ELF_PROG_LOAD)
		{
			segment_alloc(e,(void*)ph->p_va,ph->p_memsz);
			//cprintf("p_va=%x binary+p_offset=%x filesz=%x memsz=%x\n",ph->p_va,binary+ph->p_offset,ph->p_filesz,ph->p_memsz);
			memset((void*)(ph->p_va+ph->p_filesz),0,ph->p_memsz-ph->p_filesz);
f0103575:	8b 56 10             	mov    0x10(%esi),%edx
f0103578:	8b 46 14             	mov    0x14(%esi),%eax
f010357b:	29 d0                	sub    %edx,%eax
f010357d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103581:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103588:	00 
f0103589:	03 56 08             	add    0x8(%esi),%edx
f010358c:	89 14 24             	mov    %edx,(%esp)
f010358f:	e8 4a 61 00 00       	call   f01096de <memset>
			memmove((void*)ph->p_va,(void*)(binary+ph->p_offset),ph->p_filesz);	
f0103594:	8b 46 10             	mov    0x10(%esi),%eax
f0103597:	89 44 24 08          	mov    %eax,0x8(%esp)
f010359b:	8b 45 08             	mov    0x8(%ebp),%eax
f010359e:	03 46 04             	add    0x4(%esi),%eax
f01035a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035a5:	8b 46 08             	mov    0x8(%esi),%eax
f01035a8:	89 04 24             	mov    %eax,(%esp)
f01035ab:	e8 88 61 00 00       	call   f0109738 <memmove>

	if(elfhdr->e_magic!=ELF_MAGIC)
		panic("This binary is not ELF format!\n");
	ph = (struct Proghdr*)(binary+elfhdr->e_phoff);
	eph = ph+elfhdr->e_phnum;
	for(;ph<eph;ph++){
f01035b0:	83 c6 20             	add    $0x20,%esi
f01035b3:	39 75 d8             	cmp    %esi,-0x28(%ebp)
f01035b6:	0f 87 22 ff ff ff    	ja     f01034de <env_create+0x99>
			memmove((void*)ph->p_va,(void*)(binary+ph->p_offset),ph->p_filesz);	
		}
	} 
	//cprintf("memsize=%x filesize=%x\n",ph->p_memsz,ph->p_filesz);
	//cprintf("e_entry=%x\n",elfhdr->e_entry);
	e->env_tf.tf_eip=elfhdr->e_entry;
f01035bc:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01035bf:	8b 42 18             	mov    0x18(%edx),%eax
f01035c2:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01035c5:	89 42 30             	mov    %eax,0x30(%edx)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	if(page_alloc(&onepage)<0)
f01035c8:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01035cb:	89 04 24             	mov    %eax,(%esp)
f01035ce:	e8 c3 dc ff ff       	call   f0101296 <page_alloc>
f01035d3:	85 c0                	test   %eax,%eax
f01035d5:	79 1c                	jns    f01035f3 <env_create+0x1ae>
              panic("Alloc one page in load_icode failed\n");
f01035d7:	c7 44 24 08 34 b9 10 	movl   $0xf010b934,0x8(%esp)
f01035de:	f0 
f01035df:	c7 44 24 04 49 01 00 	movl   $0x149,0x4(%esp)
f01035e6:	00 
f01035e7:	c7 04 24 c8 b8 10 f0 	movl   $0xf010b8c8,(%esp)
f01035ee:	e8 93 ca ff ff       	call   f0100086 <_panic>
        if(page_insert(e->env_pgdir,onepage,(void*)(USTACKTOP-PGSIZE),PTE_U|PTE_W)<0)
f01035f3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01035fa:	00 
f01035fb:	c7 44 24 08 00 d0 bf 	movl   $0xeebfd000,0x8(%esp)
f0103602:	ee 
f0103603:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103606:	89 44 24 04          	mov    %eax,0x4(%esp)
f010360a:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010360d:	8b 42 5c             	mov    0x5c(%edx),%eax
f0103610:	89 04 24             	mov    %eax,(%esp)
f0103613:	e8 a3 e0 ff ff       	call   f01016bb <page_insert>
f0103618:	85 c0                	test   %eax,%eax
f010361a:	79 1c                	jns    f0103638 <env_create+0x1f3>
              panic("Insert one page in load_icode failed\n");
f010361c:	c7 44 24 08 5c b9 10 	movl   $0xf010b95c,0x8(%esp)
f0103623:	f0 
f0103624:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
f010362b:	00 
f010362c:	c7 04 24 c8 b8 10 f0 	movl   $0xf010b8c8,(%esp)
f0103633:	e8 4e ca ff ff       	call   f0100086 <_panic>
	memset((void*)(USTACKTOP-PGSIZE),0,PGSIZE);
f0103638:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010363f:	00 
f0103640:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103647:	00 
f0103648:	c7 04 24 00 d0 bf ee 	movl   $0xeebfd000,(%esp)
f010364f:	e8 8a 60 00 00       	call   f01096de <memset>
f0103654:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103657:	0f 22 d8             	mov    %eax,%cr3
	int r;
	struct Env *newenv;
	if((r=env_alloc(&newenv,0))<0)
		panic("env_create:%e",r);
	load_icode(newenv,binary,size);
}
f010365a:	83 c4 3c             	add    $0x3c,%esp
f010365d:	5b                   	pop    %ebx
f010365e:	5e                   	pop    %esi
f010365f:	5f                   	pop    %edi
f0103660:	5d                   	pop    %ebp
f0103661:	c3                   	ret    

f0103662 <env_free>:
//
// Frees env e and all memory it uses.
// 
void
env_free(struct Env *e)
{
f0103662:	55                   	push   %ebp
f0103663:	89 e5                	mov    %esp,%ebp
f0103665:	57                   	push   %edi
f0103666:	56                   	push   %esi
f0103667:	53                   	push   %ebx
f0103668:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t pa;
	
	// If freeing the current environment, switch to boot_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010366b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f0103672:	8b 45 08             	mov    0x8(%ebp),%eax
f0103675:	3b 05 44 45 29 f0    	cmp    0xf0294544,%eax
f010367b:	75 0f                	jne    f010368c <env_free+0x2a>
f010367d:	a1 f4 54 29 f0       	mov    0xf02954f4,%eax
f0103682:	0f 22 d8             	mov    %eax,%cr3
f0103685:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f010368c:	8b 55 ec             	mov    -0x14(%ebp),%edx
f010368f:	c1 e2 02             	shl    $0x2,%edx
f0103692:	89 55 e8             	mov    %edx,-0x18(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103695:	8b 55 08             	mov    0x8(%ebp),%edx
f0103698:	8b 42 5c             	mov    0x5c(%edx),%eax
f010369b:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010369e:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01036a1:	a8 01                	test   $0x1,%al
f01036a3:	0f 84 bf 00 00 00    	je     f0103768 <env_free+0x106>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01036a9:	89 c6                	mov    %eax,%esi
f01036ab:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		pt = (pte_t*) KADDR(pa);
f01036b1:	89 f0                	mov    %esi,%eax
f01036b3:	c1 e8 0c             	shr    $0xc,%eax
f01036b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01036b9:	3b 05 f0 54 29 f0    	cmp    0xf02954f0,%eax
f01036bf:	72 20                	jb     f01036e1 <env_free+0x7f>
f01036c1:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01036c5:	c7 44 24 08 e8 ac 10 	movl   $0xf010ace8,0x8(%esp)
f01036cc:	f0 
f01036cd:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f01036d4:	00 
f01036d5:	c7 04 24 c8 b8 10 f0 	movl   $0xf010b8c8,(%esp)
f01036dc:	e8 a5 c9 ff ff       	call   f0100086 <_panic>
f01036e1:	bb 00 00 00 00       	mov    $0x0,%ebx

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01036e6:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01036e9:	c1 e7 16             	shl    $0x16,%edi
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
f01036ec:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01036f3:	01 
f01036f4:	74 19                	je     f010370f <env_free+0xad>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01036f6:	89 d8                	mov    %ebx,%eax
f01036f8:	c1 e0 0c             	shl    $0xc,%eax
f01036fb:	09 f8                	or     %edi,%eax
f01036fd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103701:	8b 55 08             	mov    0x8(%ebp),%edx
f0103704:	8b 42 5c             	mov    0x5c(%edx),%eax
f0103707:	89 04 24             	mov    %eax,(%esp)
f010370a:	e8 c8 de ff ff       	call   f01015d7 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010370f:	83 c3 01             	add    $0x1,%ebx
f0103712:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103718:	75 d2                	jne    f01036ec <env_free+0x8a>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010371a:	8b 55 08             	mov    0x8(%ebp),%edx
f010371d:	8b 42 5c             	mov    0x5c(%edx),%eax
f0103720:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103723:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f010372a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010372d:	3b 05 f0 54 29 f0    	cmp    0xf02954f0,%eax
f0103733:	72 1c                	jb     f0103751 <env_free+0xef>
		panic("pa2page called with invalid pa");
f0103735:	c7 44 24 08 90 b0 10 	movl   $0xf010b090,0x8(%esp)
f010373c:	f0 
f010373d:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0103744:	00 
f0103745:	c7 04 24 6f b6 10 f0 	movl   $0xf010b66f,(%esp)
f010374c:	e8 35 c9 ff ff       	call   f0100086 <_panic>
		page_decref(pa2page(pa));
f0103751:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103754:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0103757:	c1 e0 02             	shl    $0x2,%eax
f010375a:	03 05 fc 54 29 f0    	add    0xf02954fc,%eax
f0103760:	89 04 24             	mov    %eax,(%esp)
f0103763:	e8 3d d9 ff ff       	call   f01010a5 <page_decref>
	// Note the environment's demise.
	//cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103768:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
f010376c:	81 7d ec bb 03 00 00 	cmpl   $0x3bb,-0x14(%ebp)
f0103773:	0f 85 13 ff ff ff    	jne    f010368c <env_free+0x2a>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = e->env_cr3;
f0103779:	8b 55 08             	mov    0x8(%ebp),%edx
f010377c:	8b 42 60             	mov    0x60(%edx),%eax
	e->env_pgdir = 0;
f010377f:	c7 42 5c 00 00 00 00 	movl   $0x0,0x5c(%edx)
	e->env_cr3 = 0;
f0103786:	c7 42 60 00 00 00 00 	movl   $0x0,0x60(%edx)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f010378d:	c1 e8 0c             	shr    $0xc,%eax
f0103790:	3b 05 f0 54 29 f0    	cmp    0xf02954f0,%eax
f0103796:	72 1c                	jb     f01037b4 <env_free+0x152>
		panic("pa2page called with invalid pa");
f0103798:	c7 44 24 08 90 b0 10 	movl   $0xf010b090,0x8(%esp)
f010379f:	f0 
f01037a0:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f01037a7:	00 
f01037a8:	c7 04 24 6f b6 10 f0 	movl   $0xf010b66f,(%esp)
f01037af:	e8 d2 c8 ff ff       	call   f0100086 <_panic>
	page_decref(pa2page(pa));
f01037b4:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01037b7:	c1 e0 02             	shl    $0x2,%eax
f01037ba:	03 05 fc 54 29 f0    	add    0xf02954fc,%eax
f01037c0:	89 04 24             	mov    %eax,(%esp)
f01037c3:	e8 dd d8 ff ff       	call   f01010a5 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01037c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01037cb:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	LIST_INSERT_HEAD(&env_free_list, e, env_link);
f01037d2:	a1 48 45 29 f0       	mov    0xf0294548,%eax
f01037d7:	8b 55 08             	mov    0x8(%ebp),%edx
f01037da:	89 42 44             	mov    %eax,0x44(%edx)
f01037dd:	85 c0                	test   %eax,%eax
f01037df:	74 0e                	je     f01037ef <env_free+0x18d>
f01037e1:	8b 55 08             	mov    0x8(%ebp),%edx
f01037e4:	83 c2 44             	add    $0x44,%edx
f01037e7:	a1 48 45 29 f0       	mov    0xf0294548,%eax
f01037ec:	89 50 48             	mov    %edx,0x48(%eax)
f01037ef:	8b 45 08             	mov    0x8(%ebp),%eax
f01037f2:	a3 48 45 29 f0       	mov    %eax,0xf0294548
f01037f7:	c7 40 48 48 45 29 f0 	movl   $0xf0294548,0x48(%eax)
}
f01037fe:	83 c4 1c             	add    $0x1c,%esp
f0103801:	5b                   	pop    %ebx
f0103802:	5e                   	pop    %esi
f0103803:	5f                   	pop    %edi
f0103804:	5d                   	pop    %ebp
f0103805:	c3                   	ret    

f0103806 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) 
{
f0103806:	55                   	push   %ebp
f0103807:	89 e5                	mov    %esp,%ebp
f0103809:	53                   	push   %ebx
f010380a:	83 ec 04             	sub    $0x4,%esp
f010380d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	env_free(e);
f0103810:	89 1c 24             	mov    %ebx,(%esp)
f0103813:	e8 4a fe ff ff       	call   f0103662 <env_free>

	if (curenv == e) {
f0103818:	39 1d 44 45 29 f0    	cmp    %ebx,0xf0294544
f010381e:	75 0f                	jne    f010382f <env_destroy+0x29>
		curenv = NULL;
f0103820:	c7 05 44 45 29 f0 00 	movl   $0x0,0xf0294544
f0103827:	00 00 00 
		sched_yield();
f010382a:	e8 21 13 00 00       	call   f0104b50 <sched_yield>
	}
}
f010382f:	83 c4 04             	add    $0x4,%esp
f0103832:	5b                   	pop    %ebx
f0103833:	5d                   	pop    %ebp
f0103834:	c3                   	ret    
f0103835:	00 00                	add    %al,(%eax)
	...

f0103838 <mc146818_read>:
#include <kern/picirq.h>


unsigned
mc146818_read(unsigned reg)
{
f0103838:	55                   	push   %ebp
f0103839:	89 e5                	mov    %esp,%ebp
f010383b:	8b 45 08             	mov    0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010383e:	ba 70 00 00 00       	mov    $0x70,%edx
f0103843:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103844:	b2 71                	mov    $0x71,%dl
f0103846:	ec                   	in     (%dx),%al
f0103847:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f010384a:	5d                   	pop    %ebp
f010384b:	c3                   	ret    

f010384c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010384c:	55                   	push   %ebp
f010384d:	89 e5                	mov    %esp,%ebp
f010384f:	8b 45 08             	mov    0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103852:	ba 70 00 00 00       	mov    $0x70,%edx
f0103857:	ee                   	out    %al,(%dx)
f0103858:	b2 71                	mov    $0x71,%dl
f010385a:	0f b6 45 0c          	movzbl 0xc(%ebp),%eax
f010385e:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010385f:	5d                   	pop    %ebp
f0103860:	c3                   	ret    

f0103861 <kclock_init>:


void
kclock_init(void)
{
f0103861:	55                   	push   %ebp
f0103862:	89 e5                	mov    %esp,%ebp
f0103864:	83 ec 08             	sub    $0x8,%esp
f0103867:	b8 34 00 00 00       	mov    $0x34,%eax
f010386c:	ba 43 00 00 00       	mov    $0x43,%edx
f0103871:	ee                   	out    %al,(%dx)
f0103872:	b8 9c ff ff ff       	mov    $0xffffff9c,%eax
f0103877:	b2 40                	mov    $0x40,%dl
f0103879:	ee                   	out    %al,(%dx)
f010387a:	b8 2e 00 00 00       	mov    $0x2e,%eax
f010387f:	ee                   	out    %al,(%dx)
	/* initialize 8253 clock to interrupt 100 times/sec */
	outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
	outb(IO_TIMER1, TIMER_DIV(100) % 256);
	outb(IO_TIMER1, TIMER_DIV(100) / 256);
	cprintf("	Setup timer interrupts via 8259A\n");
f0103880:	c7 04 24 84 b9 10 f0 	movl   $0xf010b984,(%esp)
f0103887:	e8 5b 01 00 00       	call   f01039e7 <cprintf>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<0));
f010388c:	0f b7 05 58 13 13 f0 	movzwl 0xf0131358,%eax
f0103893:	25 fe ff 00 00       	and    $0xfffe,%eax
f0103898:	89 04 24             	mov    %eax,(%esp)
f010389b:	e8 10 00 00 00       	call   f01038b0 <irq_setmask_8259A>
	cprintf("	unmasked timer interrupt\n");
f01038a0:	c7 04 24 a7 b9 10 f0 	movl   $0xf010b9a7,(%esp)
f01038a7:	e8 3b 01 00 00       	call   f01039e7 <cprintf>
}
f01038ac:	c9                   	leave  
f01038ad:	c3                   	ret    
	...

f01038b0 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01038b0:	55                   	push   %ebp
f01038b1:	89 e5                	mov    %esp,%ebp
f01038b3:	56                   	push   %esi
f01038b4:	53                   	push   %ebx
f01038b5:	83 ec 10             	sub    $0x10,%esp
f01038b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01038bb:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f01038bd:	66 a3 58 13 13 f0    	mov    %ax,0xf0131358
	if (!didinit)
f01038c3:	83 3d 4c 45 29 f0 00 	cmpl   $0x0,0xf029454c
f01038ca:	74 55                	je     f0103921 <irq_setmask_8259A+0x71>
f01038cc:	ba 21 00 00 00       	mov    $0x21,%edx
f01038d1:	ee                   	out    %al,(%dx)
f01038d2:	89 f0                	mov    %esi,%eax
f01038d4:	66 c1 e8 08          	shr    $0x8,%ax
f01038d8:	b2 a1                	mov    $0xa1,%dl
f01038da:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f01038db:	c7 04 24 c2 b9 10 f0 	movl   $0xf010b9c2,(%esp)
f01038e2:	e8 00 01 00 00       	call   f01039e7 <cprintf>
f01038e7:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
f01038ec:	0f b7 c6             	movzwl %si,%eax
f01038ef:	89 c6                	mov    %eax,%esi
f01038f1:	f7 d6                	not    %esi
f01038f3:	89 f0                	mov    %esi,%eax
f01038f5:	89 d9                	mov    %ebx,%ecx
f01038f7:	d3 f8                	sar    %cl,%eax
f01038f9:	a8 01                	test   $0x1,%al
f01038fb:	74 10                	je     f010390d <irq_setmask_8259A+0x5d>
			cprintf(" %d", i);
f01038fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103901:	c7 04 24 1c 43 11 f0 	movl   $0xf011431c,(%esp)
f0103908:	e8 da 00 00 00       	call   f01039e7 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010390d:	83 c3 01             	add    $0x1,%ebx
f0103910:	83 fb 10             	cmp    $0x10,%ebx
f0103913:	75 de                	jne    f01038f3 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103915:	c7 04 24 29 ab 10 f0 	movl   $0xf010ab29,(%esp)
f010391c:	e8 c6 00 00 00       	call   f01039e7 <cprintf>
}
f0103921:	83 c4 10             	add    $0x10,%esp
f0103924:	5b                   	pop    %ebx
f0103925:	5e                   	pop    %esi
f0103926:	5d                   	pop    %ebp
f0103927:	c3                   	ret    

f0103928 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103928:	55                   	push   %ebp
f0103929:	89 e5                	mov    %esp,%ebp
f010392b:	83 ec 08             	sub    $0x8,%esp
	didinit = 1;
f010392e:	c7 05 4c 45 29 f0 01 	movl   $0x1,0xf029454c
f0103935:	00 00 00 
f0103938:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010393d:	ba 21 00 00 00       	mov    $0x21,%edx
f0103942:	ee                   	out    %al,(%dx)
f0103943:	b2 a1                	mov    $0xa1,%dl
f0103945:	ee                   	out    %al,(%dx)
f0103946:	b8 11 00 00 00       	mov    $0x11,%eax
f010394b:	b2 20                	mov    $0x20,%dl
f010394d:	ee                   	out    %al,(%dx)
f010394e:	b8 20 00 00 00       	mov    $0x20,%eax
f0103953:	b2 21                	mov    $0x21,%dl
f0103955:	ee                   	out    %al,(%dx)
f0103956:	b8 04 00 00 00       	mov    $0x4,%eax
f010395b:	ee                   	out    %al,(%dx)
f010395c:	b8 03 00 00 00       	mov    $0x3,%eax
f0103961:	ee                   	out    %al,(%dx)
f0103962:	b8 11 00 00 00       	mov    $0x11,%eax
f0103967:	b2 a0                	mov    $0xa0,%dl
f0103969:	ee                   	out    %al,(%dx)
f010396a:	b8 28 00 00 00       	mov    $0x28,%eax
f010396f:	b2 a1                	mov    $0xa1,%dl
f0103971:	ee                   	out    %al,(%dx)
f0103972:	b8 02 00 00 00       	mov    $0x2,%eax
f0103977:	ee                   	out    %al,(%dx)
f0103978:	b8 01 00 00 00       	mov    $0x1,%eax
f010397d:	ee                   	out    %al,(%dx)
f010397e:	b8 68 00 00 00       	mov    $0x68,%eax
f0103983:	b2 20                	mov    $0x20,%dl
f0103985:	ee                   	out    %al,(%dx)
f0103986:	b8 0a 00 00 00       	mov    $0xa,%eax
f010398b:	ee                   	out    %al,(%dx)
f010398c:	b8 68 00 00 00       	mov    $0x68,%eax
f0103991:	b2 a0                	mov    $0xa0,%dl
f0103993:	ee                   	out    %al,(%dx)
f0103994:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103999:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f010399a:	0f b7 05 58 13 13 f0 	movzwl 0xf0131358,%eax
f01039a1:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f01039a5:	74 0b                	je     f01039b2 <pic_init+0x8a>
		irq_setmask_8259A(irq_mask_8259A);
f01039a7:	0f b7 c0             	movzwl %ax,%eax
f01039aa:	89 04 24             	mov    %eax,(%esp)
f01039ad:	e8 fe fe ff ff       	call   f01038b0 <irq_setmask_8259A>
}
f01039b2:	c9                   	leave  
f01039b3:	c3                   	ret    

f01039b4 <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f01039b4:	55                   	push   %ebp
f01039b5:	89 e5                	mov    %esp,%ebp
f01039b7:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01039ba:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01039c1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01039c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01039cb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01039cf:	8d 45 fc             	lea    -0x4(%ebp),%eax
f01039d2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039d6:	c7 04 24 04 3a 10 f0 	movl   $0xf0103a04,(%esp)
f01039dd:	e8 b3 55 00 00       	call   f0108f95 <vprintfmt>
f01039e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
	return cnt;
}
f01039e5:	c9                   	leave  
f01039e6:	c3                   	ret    

f01039e7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01039e7:	55                   	push   %ebp
f01039e8:	89 e5                	mov    %esp,%ebp
f01039ea:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01039ed:	8d 45 0c             	lea    0xc(%ebp),%eax
f01039f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
f01039f3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039f7:	8b 45 08             	mov    0x8(%ebp),%eax
f01039fa:	89 04 24             	mov    %eax,(%esp)
f01039fd:	e8 b2 ff ff ff       	call   f01039b4 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103a02:	c9                   	leave  
f0103a03:	c3                   	ret    

f0103a04 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103a04:	55                   	push   %ebp
f0103a05:	89 e5                	mov    %esp,%ebp
f0103a07:	83 ec 08             	sub    $0x8,%esp
	cputchar(ch);
f0103a0a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a0d:	89 04 24             	mov    %eax,(%esp)
f0103a10:	e8 55 ca ff ff       	call   f010046a <cputchar>
	*cnt++;
}
f0103a15:	c9                   	leave  
f0103a16:	c3                   	ret    
	...

f0103a20 <idt_init>:
}


void
idt_init(void)
{
f0103a20:	55                   	push   %ebp
f0103a21:	89 e5                	mov    %esp,%ebp
f0103a23:	ba 00 00 00 00       	mov    $0x0,%edx
	extern struct Segdesc gdt[];
	
	// LAB 3: Your code here.
	int i;
	for(i=0;i<32;i++)
		SETGATE(idt[i],0,GD_KT,vectors[i],0);//陷阱门
f0103a28:	8b 04 95 64 13 13 f0 	mov    -0xfecec9c(,%edx,4),%eax
f0103a2f:	66 89 04 d5 60 45 29 	mov    %ax,-0xfd6baa0(,%edx,8)
f0103a36:	f0 
f0103a37:	66 c7 04 d5 62 45 29 	movw   $0x8,-0xfd6ba9e(,%edx,8)
f0103a3e:	f0 08 00 
f0103a41:	c6 04 d5 64 45 29 f0 	movb   $0x0,-0xfd6ba9c(,%edx,8)
f0103a48:	00 
f0103a49:	c6 04 d5 65 45 29 f0 	movb   $0x8e,-0xfd6ba9b(,%edx,8)
f0103a50:	8e 
f0103a51:	c1 e8 10             	shr    $0x10,%eax
f0103a54:	66 89 04 d5 66 45 29 	mov    %ax,-0xfd6ba9a(,%edx,8)
f0103a5b:	f0 
{
	extern struct Segdesc gdt[];
	
	// LAB 3: Your code here.
	int i;
	for(i=0;i<32;i++)
f0103a5c:	83 c2 01             	add    $0x1,%edx
f0103a5f:	83 fa 20             	cmp    $0x20,%edx
f0103a62:	75 c4                	jne    f0103a28 <idt_init+0x8>
		SETGATE(idt[i],0,GD_KT,vectors[i],0);//陷阱门
	SETGATE(idt[3],0,GD_KT,vectors[3],3);//系统中断门
f0103a64:	a1 70 13 13 f0       	mov    0xf0131370,%eax
f0103a69:	66 a3 78 45 29 f0    	mov    %ax,0xf0294578
f0103a6f:	66 c7 05 7a 45 29 f0 	movw   $0x8,0xf029457a
f0103a76:	08 00 
f0103a78:	c6 05 7c 45 29 f0 00 	movb   $0x0,0xf029457c
f0103a7f:	c6 05 7d 45 29 f0 ee 	movb   $0xee,0xf029457d
f0103a86:	c1 e8 10             	shr    $0x10,%eax
f0103a89:	66 a3 7e 45 29 f0    	mov    %ax,0xf029457e
	SETGATE(idt[4],0,GD_KT,vectors[4],3);//系统陷阱门
f0103a8f:	a1 74 13 13 f0       	mov    0xf0131374,%eax
f0103a94:	66 a3 80 45 29 f0    	mov    %ax,0xf0294580
f0103a9a:	66 c7 05 82 45 29 f0 	movw   $0x8,0xf0294582
f0103aa1:	08 00 
f0103aa3:	c6 05 84 45 29 f0 00 	movb   $0x0,0xf0294584
f0103aaa:	c6 05 85 45 29 f0 ee 	movb   $0xee,0xf0294585
f0103ab1:	c1 e8 10             	shr    $0x10,%eax
f0103ab4:	66 a3 86 45 29 f0    	mov    %ax,0xf0294586
	SETGATE(idt[5],0,GD_KT,vectors[5],3);
f0103aba:	a1 78 13 13 f0       	mov    0xf0131378,%eax
f0103abf:	66 a3 88 45 29 f0    	mov    %ax,0xf0294588
f0103ac5:	66 c7 05 8a 45 29 f0 	movw   $0x8,0xf029458a
f0103acc:	08 00 
f0103ace:	c6 05 8c 45 29 f0 00 	movb   $0x0,0xf029458c
f0103ad5:	c6 05 8d 45 29 f0 ee 	movb   $0xee,0xf029458d
f0103adc:	c1 e8 10             	shr    $0x10,%eax
f0103adf:	66 a3 8e 45 29 f0    	mov    %ax,0xf029458e
	for(i=32;i<48;i++)
               SETGATE(idt[i],0,GD_KT,vectors[i],0);//中断门,外部硬件中断 16个
f0103ae5:	8b 04 95 64 13 13 f0 	mov    -0xfecec9c(,%edx,4),%eax
f0103aec:	66 89 04 d5 60 45 29 	mov    %ax,-0xfd6baa0(,%edx,8)
f0103af3:	f0 
f0103af4:	66 c7 04 d5 62 45 29 	movw   $0x8,-0xfd6ba9e(,%edx,8)
f0103afb:	f0 08 00 
f0103afe:	c6 04 d5 64 45 29 f0 	movb   $0x0,-0xfd6ba9c(,%edx,8)
f0103b05:	00 
f0103b06:	c6 04 d5 65 45 29 f0 	movb   $0x8e,-0xfd6ba9b(,%edx,8)
f0103b0d:	8e 
f0103b0e:	c1 e8 10             	shr    $0x10,%eax
f0103b11:	66 89 04 d5 66 45 29 	mov    %ax,-0xfd6ba9a(,%edx,8)
f0103b18:	f0 
	for(i=0;i<32;i++)
		SETGATE(idt[i],0,GD_KT,vectors[i],0);//陷阱门
	SETGATE(idt[3],0,GD_KT,vectors[3],3);//系统中断门
	SETGATE(idt[4],0,GD_KT,vectors[4],3);//系统陷阱门
	SETGATE(idt[5],0,GD_KT,vectors[5],3);
	for(i=32;i<48;i++)
f0103b19:	83 c2 01             	add    $0x1,%edx
f0103b1c:	83 fa 30             	cmp    $0x30,%edx
f0103b1f:	75 c4                	jne    f0103ae5 <idt_init+0xc5>
               SETGATE(idt[i],0,GD_KT,vectors[i],0);//中断门,外部硬件中断 16个
	 SETGATE(idt[48],0,GD_KT,vectors[48],3);//系统调用,系统陷阱门
f0103b21:	a1 24 14 13 f0       	mov    0xf0131424,%eax
f0103b26:	66 a3 e0 46 29 f0    	mov    %ax,0xf02946e0
f0103b2c:	66 c7 05 e2 46 29 f0 	movw   $0x8,0xf02946e2
f0103b33:	08 00 
f0103b35:	c6 05 e4 46 29 f0 00 	movb   $0x0,0xf02946e4
f0103b3c:	c6 05 e5 46 29 f0 ee 	movb   $0xee,0xf02946e5
f0103b43:	c1 e8 10             	shr    $0x10,%eax
f0103b46:	66 a3 e6 46 29 f0    	mov    %ax,0xf02946e6
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103b4c:	c7 05 64 4d 29 f0 00 	movl   $0xefc00000,0xf0294d64
f0103b53:	00 c0 ef 
	ts.ts_ss0 = GD_KD;
f0103b56:	66 c7 05 68 4d 29 f0 	movw   $0x10,0xf0294d68
f0103b5d:	10 00 

	// Initialize the TSS field of the gdt.
	gdt[GD_TSS >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103b5f:	ba 60 4d 29 f0       	mov    $0xf0294d60,%edx
f0103b64:	89 d0                	mov    %edx,%eax
f0103b66:	c1 e8 18             	shr    $0x18,%eax
f0103b69:	a2 4f 13 13 f0       	mov    %al,0xf013134f
f0103b6e:	c6 05 4e 13 13 f0 40 	movb   $0x40,0xf013134e
f0103b75:	89 d0                	mov    %edx,%eax
f0103b77:	c1 e8 10             	shr    $0x10,%eax
f0103b7a:	a2 4c 13 13 f0       	mov    %al,0xf013134c
f0103b7f:	66 89 15 4a 13 13 f0 	mov    %dx,0xf013134a
f0103b86:	66 c7 05 48 13 13 f0 	movw   $0x68,0xf0131348
f0103b8d:	68 00 
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS >> 3].sd_s = 0;
f0103b8f:	c6 05 4d 13 13 f0 89 	movb   $0x89,0xf013134d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103b96:	b8 28 00 00 00       	mov    $0x28,%eax
f0103b9b:	0f 00 d8             	ltr    %ax

	// Load the TSS
	ltr(GD_TSS);

	// Load the IDT
	asm volatile("lidt idt_pd");
f0103b9e:	0f 01 1d 5c 13 13 f0 	lidtl  0xf013135c
}
f0103ba5:	5d                   	pop    %ebp
f0103ba6:	c3                   	ret    

f0103ba7 <print_regs>:
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
}

void
print_regs(struct PushRegs *regs)
{
f0103ba7:	55                   	push   %ebp
f0103ba8:	89 e5                	mov    %esp,%ebp
f0103baa:	53                   	push   %ebx
f0103bab:	83 ec 14             	sub    $0x14,%esp
f0103bae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103bb1:	8b 03                	mov    (%ebx),%eax
f0103bb3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bb7:	c7 04 24 d6 b9 10 f0 	movl   $0xf010b9d6,(%esp)
f0103bbe:	e8 24 fe ff ff       	call   f01039e7 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103bc3:	8b 43 04             	mov    0x4(%ebx),%eax
f0103bc6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bca:	c7 04 24 e5 b9 10 f0 	movl   $0xf010b9e5,(%esp)
f0103bd1:	e8 11 fe ff ff       	call   f01039e7 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103bd6:	8b 43 08             	mov    0x8(%ebx),%eax
f0103bd9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bdd:	c7 04 24 f4 b9 10 f0 	movl   $0xf010b9f4,(%esp)
f0103be4:	e8 fe fd ff ff       	call   f01039e7 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103be9:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103bec:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bf0:	c7 04 24 03 ba 10 f0 	movl   $0xf010ba03,(%esp)
f0103bf7:	e8 eb fd ff ff       	call   f01039e7 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103bfc:	8b 43 10             	mov    0x10(%ebx),%eax
f0103bff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c03:	c7 04 24 12 ba 10 f0 	movl   $0xf010ba12,(%esp)
f0103c0a:	e8 d8 fd ff ff       	call   f01039e7 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103c0f:	8b 43 14             	mov    0x14(%ebx),%eax
f0103c12:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c16:	c7 04 24 21 ba 10 f0 	movl   $0xf010ba21,(%esp)
f0103c1d:	e8 c5 fd ff ff       	call   f01039e7 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103c22:	8b 43 18             	mov    0x18(%ebx),%eax
f0103c25:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c29:	c7 04 24 30 ba 10 f0 	movl   $0xf010ba30,(%esp)
f0103c30:	e8 b2 fd ff ff       	call   f01039e7 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103c35:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103c38:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c3c:	c7 04 24 3f ba 10 f0 	movl   $0xf010ba3f,(%esp)
f0103c43:	e8 9f fd ff ff       	call   f01039e7 <cprintf>
}
f0103c48:	83 c4 14             	add    $0x14,%esp
f0103c4b:	5b                   	pop    %ebx
f0103c4c:	5d                   	pop    %ebp
f0103c4d:	c3                   	ret    

f0103c4e <print_trapframe>:
	asm volatile("lidt idt_pd");
}

void
print_trapframe(struct Trapframe *tf)
{
f0103c4e:	55                   	push   %ebp
f0103c4f:	89 e5                	mov    %esp,%ebp
f0103c51:	53                   	push   %ebx
f0103c52:	83 ec 14             	sub    $0x14,%esp
f0103c55:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103c58:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103c5c:	c7 04 24 4e ba 10 f0 	movl   $0xf010ba4e,(%esp)
f0103c63:	e8 7f fd ff ff       	call   f01039e7 <cprintf>
	print_regs(&tf->tf_regs);
f0103c68:	89 1c 24             	mov    %ebx,(%esp)
f0103c6b:	e8 37 ff ff ff       	call   f0103ba7 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103c70:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103c74:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c78:	c7 04 24 60 ba 10 f0 	movl   $0xf010ba60,(%esp)
f0103c7f:	e8 63 fd ff ff       	call   f01039e7 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103c84:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103c88:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c8c:	c7 04 24 73 ba 10 f0 	movl   $0xf010ba73,(%esp)
f0103c93:	e8 4f fd ff ff       	call   f01039e7 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103c98:	8b 53 28             	mov    0x28(%ebx),%edx
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103c9b:	83 fa 13             	cmp    $0x13,%edx
f0103c9e:	77 09                	ja     f0103ca9 <print_trapframe+0x5b>
		return excnames[trapno];
f0103ca0:	8b 0c 95 20 bd 10 f0 	mov    -0xfef42e0(,%edx,4),%ecx
f0103ca7:	eb 1c                	jmp    f0103cc5 <print_trapframe+0x77>
	if (trapno == T_SYSCALL)
f0103ca9:	b9 86 ba 10 f0       	mov    $0xf010ba86,%ecx
f0103cae:	83 fa 30             	cmp    $0x30,%edx
f0103cb1:	74 12                	je     f0103cc5 <print_trapframe+0x77>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103cb3:	8d 42 e0             	lea    -0x20(%edx),%eax
f0103cb6:	b9 92 ba 10 f0       	mov    $0xf010ba92,%ecx
f0103cbb:	83 f8 0f             	cmp    $0xf,%eax
f0103cbe:	76 05                	jbe    f0103cc5 <print_trapframe+0x77>
f0103cc0:	b9 a5 ba 10 f0       	mov    $0xf010baa5,%ecx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103cc5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103cc9:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103ccd:	c7 04 24 b4 ba 10 f0 	movl   $0xf010bab4,(%esp)
f0103cd4:	e8 0e fd ff ff       	call   f01039e7 <cprintf>
	cprintf("  err  0x%08x\n", tf->tf_err);
f0103cd9:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103cdc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ce0:	c7 04 24 c6 ba 10 f0 	movl   $0xf010bac6,(%esp)
f0103ce7:	e8 fb fc ff ff       	call   f01039e7 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103cec:	8b 43 30             	mov    0x30(%ebx),%eax
f0103cef:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cf3:	c7 04 24 d5 ba 10 f0 	movl   $0xf010bad5,(%esp)
f0103cfa:	e8 e8 fc ff ff       	call   f01039e7 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103cff:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103d03:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d07:	c7 04 24 e4 ba 10 f0 	movl   $0xf010bae4,(%esp)
f0103d0e:	e8 d4 fc ff ff       	call   f01039e7 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103d13:	8b 43 38             	mov    0x38(%ebx),%eax
f0103d16:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d1a:	c7 04 24 f7 ba 10 f0 	movl   $0xf010baf7,(%esp)
f0103d21:	e8 c1 fc ff ff       	call   f01039e7 <cprintf>
	cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103d26:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103d29:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d2d:	c7 04 24 06 bb 10 f0 	movl   $0xf010bb06,(%esp)
f0103d34:	e8 ae fc ff ff       	call   f01039e7 <cprintf>
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103d39:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103d3d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d41:	c7 04 24 15 bb 10 f0 	movl   $0xf010bb15,(%esp)
f0103d48:	e8 9a fc ff ff       	call   f01039e7 <cprintf>
}
f0103d4d:	83 c4 14             	add    $0x14,%esp
f0103d50:	5b                   	pop    %ebx
f0103d51:	5d                   	pop    %ebp
f0103d52:	c3                   	ret    

f0103d53 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103d53:	55                   	push   %ebp
f0103d54:	89 e5                	mov    %esp,%ebp
f0103d56:	56                   	push   %esi
f0103d57:	53                   	push   %ebx
f0103d58:	83 ec 10             	sub    $0x10,%esp
f0103d5b:	8b 5d 08             	mov    0x8(%ebp),%ebx

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103d5e:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	
	// LAB 3: Your code here.还可以通过页故障异常的错误码的位2判断
	if((tf->tf_cs&3)==0)
f0103d61:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103d65:	75 1c                	jne    f0103d83 <page_fault_handler+0x30>
		panic("Page Fault in Kernel Mode");
f0103d67:	c7 44 24 08 28 bb 10 	movl   $0xf010bb28,0x8(%esp)
f0103d6e:	f0 
f0103d6f:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
f0103d76:	00 
f0103d77:	c7 04 24 42 bb 10 f0 	movl   $0xf010bb42,(%esp)
f0103d7e:	e8 03 c3 ff ff       	call   f0100086 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	struct UTrapframe *utf;
	if((tf->tf_err&FEC_U)&&curenv->env_pgfault_upcall)
f0103d83:	f6 43 2c 04          	testb  $0x4,0x2c(%ebx)
f0103d87:	0f 84 d9 00 00 00    	je     f0103e66 <page_fault_handler+0x113>
f0103d8d:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f0103d92:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103d96:	0f 84 ca 00 00 00    	je     f0103e66 <page_fault_handler+0x113>
	{
		user_mem_assert(curenv,(void*)(UXSTACKTOP-0x34),0x34,0);
f0103d9c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103da3:	00 
f0103da4:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f0103dab:	00 
f0103dac:	c7 44 24 04 cc ff bf 	movl   $0xeebfffcc,0x4(%esp)
f0103db3:	ee 
f0103db4:	89 04 24             	mov    %eax,(%esp)
f0103db7:	e8 c3 d7 ff ff       	call   f010157f <user_mem_assert>
		if(tf->tf_esp>(UXSTACKTOP-PGSIZE)&&tf->tf_esp<UXSTACKTOP)
f0103dbc:	8b 4b 3c             	mov    0x3c(%ebx),%ecx
f0103dbf:	8d 81 ff 0f 40 11    	lea    0x11400fff(%ecx),%eax
f0103dc5:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f0103dca:	3d fe 0f 00 00       	cmp    $0xffe,%eax
f0103dcf:	77 03                	ja     f0103dd4 <page_fault_handler+0x81>
		{
			utf=(struct UTrapframe*)(tf->tf_esp-0x38);
f0103dd1:	8d 51 c8             	lea    -0x38(%ecx),%edx
		}
		else{
			utf = (struct UTrapframe*)(UXSTACKTOP-0x34);   
		}
					//在用户异常栈上设置一个页故障帧栈
		utf->utf_fault_va=fault_va;
f0103dd4:	89 32                	mov    %esi,(%edx)
		utf->utf_err=tf->tf_err;
f0103dd6:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103dd9:	89 42 04             	mov    %eax,0x4(%edx)
		utf->utf_regs=tf->tf_regs;
f0103ddc:	8b 03                	mov    (%ebx),%eax
f0103dde:	89 42 08             	mov    %eax,0x8(%edx)
f0103de1:	8b 43 04             	mov    0x4(%ebx),%eax
f0103de4:	89 42 0c             	mov    %eax,0xc(%edx)
f0103de7:	8b 43 08             	mov    0x8(%ebx),%eax
f0103dea:	89 42 10             	mov    %eax,0x10(%edx)
f0103ded:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103df0:	89 42 14             	mov    %eax,0x14(%edx)
f0103df3:	8b 43 10             	mov    0x10(%ebx),%eax
f0103df6:	89 42 18             	mov    %eax,0x18(%edx)
f0103df9:	8b 43 14             	mov    0x14(%ebx),%eax
f0103dfc:	89 42 1c             	mov    %eax,0x1c(%edx)
f0103dff:	8b 43 18             	mov    0x18(%ebx),%eax
f0103e02:	89 42 20             	mov    %eax,0x20(%edx)
f0103e05:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103e08:	89 42 24             	mov    %eax,0x24(%edx)
		utf->utf_eip=tf->tf_eip;
f0103e0b:	8b 43 30             	mov    0x30(%ebx),%eax
f0103e0e:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags=tf->tf_eflags;
f0103e11:	8b 43 38             	mov    0x38(%ebx),%eax
f0103e14:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp=tf->tf_esp;
f0103e17:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103e1a:	89 42 30             	mov    %eax,0x30(%edx)
		curenv->env_tf.tf_esp=(uintptr_t)utf;
f0103e1d:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f0103e22:	89 50 3c             	mov    %edx,0x3c(%eax)
		//curenv->env_tf.tf_eflags=utf->utf_eflags;
		//cprintf("utf:utf_esp=%x utf_eip=%x\n",utf->utf_esp,utf->utf_eip);
		//cprintf("curenv:tf_esp=%x utf=%x\n",curenv->env_tf.tf_esp,(uintptr_t)utf);
		//cprintf("tf->tf_eflags=%x curenv_eflages=%x\n",tf->tf_eflags,curenv->env_tf.tf_eflags);
		if(curenv->env_pgfault_upcall)
f0103e25:	8b 15 44 45 29 f0    	mov    0xf0294544,%edx
f0103e2b:	8b 42 64             	mov    0x64(%edx),%eax
f0103e2e:	85 c0                	test   %eax,%eax
f0103e30:	74 34                	je     f0103e66 <page_fault_handler+0x113>
		{	
			user_mem_assert(curenv,(void*)curenv->env_pgfault_upcall,PGSIZE,0);
f0103e32:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103e39:	00 
f0103e3a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103e41:	00 
f0103e42:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e46:	89 14 24             	mov    %edx,(%esp)
f0103e49:	e8 31 d7 ff ff       	call   f010157f <user_mem_assert>
			curenv->env_tf.tf_eip=(uintptr_t)curenv->env_pgfault_upcall;
f0103e4e:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f0103e53:	8b 50 64             	mov    0x64(%eax),%edx
f0103e56:	89 50 30             	mov    %edx,0x30(%eax)
			env_run(curenv);
f0103e59:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f0103e5e:	89 04 24             	mov    %eax,(%esp)
f0103e61:	e8 fb f3 ff ff       	call   f0103261 <env_run>
		}
	}
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103e66:	8b 43 30             	mov    0x30(%ebx),%eax
f0103e69:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e6d:	89 74 24 08          	mov    %esi,0x8(%esp)
f0103e71:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f0103e76:	8b 40 4c             	mov    0x4c(%eax),%eax
f0103e79:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e7d:	c7 04 24 e8 bc 10 f0 	movl   $0xf010bce8,(%esp)
f0103e84:	e8 5e fb ff ff       	call   f01039e7 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103e89:	89 1c 24             	mov    %ebx,(%esp)
f0103e8c:	e8 bd fd ff ff       	call   f0103c4e <print_trapframe>
	env_destroy(curenv);
f0103e91:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f0103e96:	89 04 24             	mov    %eax,(%esp)
f0103e99:	e8 68 f9 ff ff       	call   f0103806 <env_destroy>
}
f0103e9e:	83 c4 10             	add    $0x10,%esp
f0103ea1:	5b                   	pop    %ebx
f0103ea2:	5e                   	pop    %esi
f0103ea3:	5d                   	pop    %ebp
f0103ea4:	c3                   	ret    

f0103ea5 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103ea5:	55                   	push   %ebp
f0103ea6:	89 e5                	mov    %esp,%ebp
f0103ea8:	56                   	push   %esi
f0103ea9:	53                   	push   %ebx
f0103eaa:	83 ec 20             	sub    $0x20,%esp
f0103ead:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103eb0:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103eb1:	9c                   	pushf  
f0103eb2:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103eb3:	f6 c4 02             	test   $0x2,%ah
f0103eb6:	74 24                	je     f0103edc <trap+0x37>
f0103eb8:	c7 44 24 0c 4e bb 10 	movl   $0xf010bb4e,0xc(%esp)
f0103ebf:	f0 
f0103ec0:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0103ec7:	f0 
f0103ec8:	c7 44 24 04 b8 00 00 	movl   $0xb8,0x4(%esp)
f0103ecf:	00 
f0103ed0:	c7 04 24 42 bb 10 f0 	movl   $0xf010bb42,(%esp)
f0103ed7:	e8 aa c1 ff ff       	call   f0100086 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0103edc:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103ee0:	83 e0 03             	and    $0x3,%eax
f0103ee3:	83 f8 03             	cmp    $0x3,%eax
f0103ee6:	75 47                	jne    f0103f2f <trap+0x8a>
		// Trapped from user mode.
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		assert(curenv);
f0103ee8:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f0103eed:	85 c0                	test   %eax,%eax
f0103eef:	75 24                	jne    f0103f15 <trap+0x70>
f0103ef1:	c7 44 24 0c 67 bb 10 	movl   $0xf010bb67,0xc(%esp)
f0103ef8:	f0 
f0103ef9:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0103f00:	f0 
f0103f01:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
f0103f08:	00 
f0103f09:	c7 04 24 42 bb 10 f0 	movl   $0xf010bb42,(%esp)
f0103f10:	e8 71 c1 ff ff       	call   f0100086 <_panic>
		curenv->env_tf = *tf;
f0103f15:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103f1c:	00 
f0103f1d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103f21:	89 04 24             	mov    %eax,(%esp)
f0103f24:	e8 8f 58 00 00       	call   f01097b8 <memcpy>
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103f29:	8b 35 44 45 29 f0    	mov    0xf0294544,%esi
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	switch(tf->tf_trapno){
f0103f2f:	8b 46 28             	mov    0x28(%esi),%eax
f0103f32:	83 f8 03             	cmp    $0x3,%eax
f0103f35:	74 33                	je     f0103f6a <trap+0xc5>
f0103f37:	83 f8 03             	cmp    $0x3,%eax
f0103f3a:	77 0b                	ja     f0103f47 <trap+0xa2>
f0103f3c:	83 f8 01             	cmp    $0x1,%eax
f0103f3f:	0f 85 78 00 00 00    	jne    f0103fbd <trap+0x118>
f0103f45:	eb 30                	jmp    f0103f77 <trap+0xd2>
f0103f47:	83 f8 0e             	cmp    $0xe,%eax
f0103f4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103f50:	74 07                	je     f0103f59 <trap+0xb4>
f0103f52:	83 f8 30             	cmp    $0x30,%eax
f0103f55:	75 66                	jne    f0103fbd <trap+0x118>
f0103f57:	eb 2c                	jmp    f0103f85 <trap+0xe0>
		case T_PGFLT:
			page_fault_handler(tf);
f0103f59:	89 34 24             	mov    %esi,(%esp)
f0103f5c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0103f60:	e8 ee fd ff ff       	call   f0103d53 <page_fault_handler>
f0103f65:	e9 b6 00 00 00       	jmp    f0104020 <trap+0x17b>
			break;
		case T_BRKPT:
			monitor(tf);
f0103f6a:	89 34 24             	mov    %esi,(%esp)
f0103f6d:	e8 15 ca ff ff       	call   f0100987 <monitor>
f0103f72:	e9 a9 00 00 00       	jmp    f0104020 <trap+0x17b>
			break;
		case T_DEBUG:
			monitor(tf);
f0103f77:	89 34 24             	mov    %esi,(%esp)
f0103f7a:	e8 08 ca ff ff       	call   f0100987 <monitor>
f0103f7f:	90                   	nop    
f0103f80:	e9 9b 00 00 00       	jmp    f0104020 <trap+0x17b>
			break;
		case T_SYSCALL:
			curenv->env_tf.tf_regs.reg_eax=syscall(tf->tf_regs.reg_eax,tf->tf_regs.reg_edx,tf->tf_regs.reg_ecx,tf->tf_regs.reg_ebx,tf->tf_regs.reg_edi,tf->tf_regs.reg_esi);
f0103f85:	8b 1d 44 45 29 f0    	mov    0xf0294544,%ebx
f0103f8b:	8b 46 04             	mov    0x4(%esi),%eax
f0103f8e:	89 44 24 14          	mov    %eax,0x14(%esp)
f0103f92:	8b 06                	mov    (%esi),%eax
f0103f94:	89 44 24 10          	mov    %eax,0x10(%esp)
f0103f98:	8b 46 10             	mov    0x10(%esi),%eax
f0103f9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f9f:	8b 46 18             	mov    0x18(%esi),%eax
f0103fa2:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103fa6:	8b 46 14             	mov    0x14(%esi),%eax
f0103fa9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fad:	8b 46 1c             	mov    0x1c(%esi),%eax
f0103fb0:	89 04 24             	mov    %eax,(%esp)
f0103fb3:	e8 49 0d 00 00       	call   f0104d01 <syscall>
f0103fb8:	89 43 1c             	mov    %eax,0x1c(%ebx)
f0103fbb:	eb 63                	jmp    f0104020 <trap+0x17b>
		default:	
		// Handle clock interrupts.
		// LAB 4: Your code here.
		// Add time tick increment to clock interrupts.
		// LAB 6: Your code here.
		if(tf->tf_trapno==IRQ_OFFSET + IRQ_TIMER){
f0103fbd:	83 f8 20             	cmp    $0x20,%eax
f0103fc0:	75 0a                	jne    f0103fcc <trap+0x127>
			time_tick();
f0103fc2:	e8 1b 61 00 00       	call   f010a0e2 <time_tick>
			sched_yield();//内核层的环境切换，需要在环境切换中思考
f0103fc7:	e8 84 0b 00 00       	call   f0104b50 <sched_yield>


		// Handle spurious interrupts
		// The hardware sometimes raises these because of noise on the
		// IRQ line or other reasons. We don't care.
		if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0103fcc:	83 f8 27             	cmp    $0x27,%eax
f0103fcf:	90                   	nop    
f0103fd0:	75 16                	jne    f0103fe8 <trap+0x143>
			cprintf("Spurious interrupt on irq 7\n");
f0103fd2:	c7 04 24 6e bb 10 f0 	movl   $0xf010bb6e,(%esp)
f0103fd9:	e8 09 fa ff ff       	call   f01039e7 <cprintf>
			print_trapframe(tf);
f0103fde:	89 34 24             	mov    %esi,(%esp)
f0103fe1:	e8 68 fc ff ff       	call   f0103c4e <print_trapframe>
f0103fe6:	eb 38                	jmp    f0104020 <trap+0x17b>
		}
	


		// Unexpected trap: The user process or the kernel has a bug.
		print_trapframe(tf);
f0103fe8:	89 34 24             	mov    %esi,(%esp)
f0103feb:	e8 5e fc ff ff       	call   f0103c4e <print_trapframe>
		if (tf->tf_cs == GD_KT)
f0103ff0:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103ff5:	75 1c                	jne    f0104013 <trap+0x16e>
			panic("unhandled trap in kernel");
f0103ff7:	c7 44 24 08 8b bb 10 	movl   $0xf010bb8b,0x8(%esp)
f0103ffe:	f0 
f0103fff:	c7 44 24 04 a6 00 00 	movl   $0xa6,0x4(%esp)
f0104006:	00 
f0104007:	c7 04 24 42 bb 10 f0 	movl   $0xf010bb42,(%esp)
f010400e:	e8 73 c0 ff ff       	call   f0100086 <_panic>
		else {
			env_destroy(curenv);
f0104013:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f0104018:	89 04 24             	mov    %eax,(%esp)
f010401b:	e8 e6 f7 ff ff       	call   f0103806 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNABLE)
f0104020:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f0104025:	85 c0                	test   %eax,%eax
f0104027:	74 0e                	je     f0104037 <trap+0x192>
f0104029:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010402d:	75 08                	jne    f0104037 <trap+0x192>
		env_run(curenv);
f010402f:	89 04 24             	mov    %eax,(%esp)
f0104032:	e8 2a f2 ff ff       	call   f0103261 <env_run>
	else
		sched_yield();
f0104037:	e8 14 0b 00 00       	call   f0104b50 <sched_yield>

f010403c <vector0>:
f010403c:	6a 00                	push   $0x0
f010403e:	6a 00                	push   $0x0
f0104040:	e9 eb 0a 00 00       	jmp    f0104b30 <_alltraps>
f0104045:	90                   	nop    

f0104046 <vector1>:
f0104046:	6a 00                	push   $0x0
f0104048:	6a 01                	push   $0x1
f010404a:	e9 e1 0a 00 00       	jmp    f0104b30 <_alltraps>
f010404f:	90                   	nop    

f0104050 <vector2>:
f0104050:	6a 00                	push   $0x0
f0104052:	6a 02                	push   $0x2
f0104054:	e9 d7 0a 00 00       	jmp    f0104b30 <_alltraps>
f0104059:	90                   	nop    

f010405a <vector3>:
f010405a:	6a 00                	push   $0x0
f010405c:	6a 03                	push   $0x3
f010405e:	e9 cd 0a 00 00       	jmp    f0104b30 <_alltraps>
f0104063:	90                   	nop    

f0104064 <vector4>:
f0104064:	6a 00                	push   $0x0
f0104066:	6a 04                	push   $0x4
f0104068:	e9 c3 0a 00 00       	jmp    f0104b30 <_alltraps>
f010406d:	90                   	nop    

f010406e <vector5>:
f010406e:	6a 00                	push   $0x0
f0104070:	6a 05                	push   $0x5
f0104072:	e9 b9 0a 00 00       	jmp    f0104b30 <_alltraps>
f0104077:	90                   	nop    

f0104078 <vector6>:
f0104078:	6a 00                	push   $0x0
f010407a:	6a 06                	push   $0x6
f010407c:	e9 af 0a 00 00       	jmp    f0104b30 <_alltraps>
f0104081:	90                   	nop    

f0104082 <vector7>:
f0104082:	6a 00                	push   $0x0
f0104084:	6a 07                	push   $0x7
f0104086:	e9 a5 0a 00 00       	jmp    f0104b30 <_alltraps>
f010408b:	90                   	nop    

f010408c <vector8>:
f010408c:	6a 08                	push   $0x8
f010408e:	e9 9d 0a 00 00       	jmp    f0104b30 <_alltraps>
f0104093:	90                   	nop    

f0104094 <vector9>:
f0104094:	6a 00                	push   $0x0
f0104096:	6a 09                	push   $0x9
f0104098:	e9 93 0a 00 00       	jmp    f0104b30 <_alltraps>
f010409d:	90                   	nop    

f010409e <vector10>:
f010409e:	6a 0a                	push   $0xa
f01040a0:	e9 8b 0a 00 00       	jmp    f0104b30 <_alltraps>
f01040a5:	90                   	nop    

f01040a6 <vector11>:
f01040a6:	6a 0b                	push   $0xb
f01040a8:	e9 83 0a 00 00       	jmp    f0104b30 <_alltraps>
f01040ad:	90                   	nop    

f01040ae <vector12>:
f01040ae:	6a 0c                	push   $0xc
f01040b0:	e9 7b 0a 00 00       	jmp    f0104b30 <_alltraps>
f01040b5:	90                   	nop    

f01040b6 <vector13>:
f01040b6:	6a 0d                	push   $0xd
f01040b8:	e9 73 0a 00 00       	jmp    f0104b30 <_alltraps>
f01040bd:	90                   	nop    

f01040be <vector14>:
f01040be:	6a 0e                	push   $0xe
f01040c0:	e9 6b 0a 00 00       	jmp    f0104b30 <_alltraps>
f01040c5:	90                   	nop    

f01040c6 <vector15>:
f01040c6:	6a 00                	push   $0x0
f01040c8:	6a 0f                	push   $0xf
f01040ca:	e9 61 0a 00 00       	jmp    f0104b30 <_alltraps>
f01040cf:	90                   	nop    

f01040d0 <vector16>:
f01040d0:	6a 00                	push   $0x0
f01040d2:	6a 10                	push   $0x10
f01040d4:	e9 57 0a 00 00       	jmp    f0104b30 <_alltraps>
f01040d9:	90                   	nop    

f01040da <vector17>:
f01040da:	6a 00                	push   $0x0
f01040dc:	6a 11                	push   $0x11
f01040de:	e9 4d 0a 00 00       	jmp    f0104b30 <_alltraps>
f01040e3:	90                   	nop    

f01040e4 <vector18>:
f01040e4:	6a 00                	push   $0x0
f01040e6:	6a 12                	push   $0x12
f01040e8:	e9 43 0a 00 00       	jmp    f0104b30 <_alltraps>
f01040ed:	90                   	nop    

f01040ee <vector19>:
f01040ee:	6a 00                	push   $0x0
f01040f0:	6a 13                	push   $0x13
f01040f2:	e9 39 0a 00 00       	jmp    f0104b30 <_alltraps>
f01040f7:	90                   	nop    

f01040f8 <vector20>:
f01040f8:	6a 00                	push   $0x0
f01040fa:	6a 14                	push   $0x14
f01040fc:	e9 2f 0a 00 00       	jmp    f0104b30 <_alltraps>
f0104101:	90                   	nop    

f0104102 <vector21>:
f0104102:	6a 00                	push   $0x0
f0104104:	6a 15                	push   $0x15
f0104106:	e9 25 0a 00 00       	jmp    f0104b30 <_alltraps>
f010410b:	90                   	nop    

f010410c <vector22>:
f010410c:	6a 00                	push   $0x0
f010410e:	6a 16                	push   $0x16
f0104110:	e9 1b 0a 00 00       	jmp    f0104b30 <_alltraps>
f0104115:	90                   	nop    

f0104116 <vector23>:
f0104116:	6a 00                	push   $0x0
f0104118:	6a 17                	push   $0x17
f010411a:	e9 11 0a 00 00       	jmp    f0104b30 <_alltraps>
f010411f:	90                   	nop    

f0104120 <vector24>:
f0104120:	6a 00                	push   $0x0
f0104122:	6a 18                	push   $0x18
f0104124:	e9 07 0a 00 00       	jmp    f0104b30 <_alltraps>
f0104129:	90                   	nop    

f010412a <vector25>:
f010412a:	6a 00                	push   $0x0
f010412c:	6a 19                	push   $0x19
f010412e:	e9 fd 09 00 00       	jmp    f0104b30 <_alltraps>
f0104133:	90                   	nop    

f0104134 <vector26>:
f0104134:	6a 00                	push   $0x0
f0104136:	6a 1a                	push   $0x1a
f0104138:	e9 f3 09 00 00       	jmp    f0104b30 <_alltraps>
f010413d:	90                   	nop    

f010413e <vector27>:
f010413e:	6a 00                	push   $0x0
f0104140:	6a 1b                	push   $0x1b
f0104142:	e9 e9 09 00 00       	jmp    f0104b30 <_alltraps>
f0104147:	90                   	nop    

f0104148 <vector28>:
f0104148:	6a 00                	push   $0x0
f010414a:	6a 1c                	push   $0x1c
f010414c:	e9 df 09 00 00       	jmp    f0104b30 <_alltraps>
f0104151:	90                   	nop    

f0104152 <vector29>:
f0104152:	6a 00                	push   $0x0
f0104154:	6a 1d                	push   $0x1d
f0104156:	e9 d5 09 00 00       	jmp    f0104b30 <_alltraps>
f010415b:	90                   	nop    

f010415c <vector30>:
f010415c:	6a 00                	push   $0x0
f010415e:	6a 1e                	push   $0x1e
f0104160:	e9 cb 09 00 00       	jmp    f0104b30 <_alltraps>
f0104165:	90                   	nop    

f0104166 <vector31>:
f0104166:	6a 00                	push   $0x0
f0104168:	6a 1f                	push   $0x1f
f010416a:	e9 c1 09 00 00       	jmp    f0104b30 <_alltraps>
f010416f:	90                   	nop    

f0104170 <vector32>:
f0104170:	6a 00                	push   $0x0
f0104172:	6a 20                	push   $0x20
f0104174:	e9 b7 09 00 00       	jmp    f0104b30 <_alltraps>
f0104179:	90                   	nop    

f010417a <vector33>:
f010417a:	6a 00                	push   $0x0
f010417c:	6a 21                	push   $0x21
f010417e:	e9 ad 09 00 00       	jmp    f0104b30 <_alltraps>
f0104183:	90                   	nop    

f0104184 <vector34>:
f0104184:	6a 00                	push   $0x0
f0104186:	6a 22                	push   $0x22
f0104188:	e9 a3 09 00 00       	jmp    f0104b30 <_alltraps>
f010418d:	90                   	nop    

f010418e <vector35>:
f010418e:	6a 00                	push   $0x0
f0104190:	6a 23                	push   $0x23
f0104192:	e9 99 09 00 00       	jmp    f0104b30 <_alltraps>
f0104197:	90                   	nop    

f0104198 <vector36>:
f0104198:	6a 00                	push   $0x0
f010419a:	6a 24                	push   $0x24
f010419c:	e9 8f 09 00 00       	jmp    f0104b30 <_alltraps>
f01041a1:	90                   	nop    

f01041a2 <vector37>:
f01041a2:	6a 00                	push   $0x0
f01041a4:	6a 25                	push   $0x25
f01041a6:	e9 85 09 00 00       	jmp    f0104b30 <_alltraps>
f01041ab:	90                   	nop    

f01041ac <vector38>:
f01041ac:	6a 00                	push   $0x0
f01041ae:	6a 26                	push   $0x26
f01041b0:	e9 7b 09 00 00       	jmp    f0104b30 <_alltraps>
f01041b5:	90                   	nop    

f01041b6 <vector39>:
f01041b6:	6a 00                	push   $0x0
f01041b8:	6a 27                	push   $0x27
f01041ba:	e9 71 09 00 00       	jmp    f0104b30 <_alltraps>
f01041bf:	90                   	nop    

f01041c0 <vector40>:
f01041c0:	6a 00                	push   $0x0
f01041c2:	6a 28                	push   $0x28
f01041c4:	e9 67 09 00 00       	jmp    f0104b30 <_alltraps>
f01041c9:	90                   	nop    

f01041ca <vector41>:
f01041ca:	6a 00                	push   $0x0
f01041cc:	6a 29                	push   $0x29
f01041ce:	e9 5d 09 00 00       	jmp    f0104b30 <_alltraps>
f01041d3:	90                   	nop    

f01041d4 <vector42>:
f01041d4:	6a 00                	push   $0x0
f01041d6:	6a 2a                	push   $0x2a
f01041d8:	e9 53 09 00 00       	jmp    f0104b30 <_alltraps>
f01041dd:	90                   	nop    

f01041de <vector43>:
f01041de:	6a 00                	push   $0x0
f01041e0:	6a 2b                	push   $0x2b
f01041e2:	e9 49 09 00 00       	jmp    f0104b30 <_alltraps>
f01041e7:	90                   	nop    

f01041e8 <vector44>:
f01041e8:	6a 00                	push   $0x0
f01041ea:	6a 2c                	push   $0x2c
f01041ec:	e9 3f 09 00 00       	jmp    f0104b30 <_alltraps>
f01041f1:	90                   	nop    

f01041f2 <vector45>:
f01041f2:	6a 00                	push   $0x0
f01041f4:	6a 2d                	push   $0x2d
f01041f6:	e9 35 09 00 00       	jmp    f0104b30 <_alltraps>
f01041fb:	90                   	nop    

f01041fc <vector46>:
f01041fc:	6a 00                	push   $0x0
f01041fe:	6a 2e                	push   $0x2e
f0104200:	e9 2b 09 00 00       	jmp    f0104b30 <_alltraps>
f0104205:	90                   	nop    

f0104206 <vector47>:
f0104206:	6a 00                	push   $0x0
f0104208:	6a 2f                	push   $0x2f
f010420a:	e9 21 09 00 00       	jmp    f0104b30 <_alltraps>
f010420f:	90                   	nop    

f0104210 <vector48>:
f0104210:	6a 00                	push   $0x0
f0104212:	6a 30                	push   $0x30
f0104214:	e9 17 09 00 00       	jmp    f0104b30 <_alltraps>
f0104219:	90                   	nop    

f010421a <vector49>:
f010421a:	6a 00                	push   $0x0
f010421c:	6a 31                	push   $0x31
f010421e:	e9 0d 09 00 00       	jmp    f0104b30 <_alltraps>
f0104223:	90                   	nop    

f0104224 <vector50>:
f0104224:	6a 00                	push   $0x0
f0104226:	6a 32                	push   $0x32
f0104228:	e9 03 09 00 00       	jmp    f0104b30 <_alltraps>
f010422d:	90                   	nop    

f010422e <vector51>:
f010422e:	6a 00                	push   $0x0
f0104230:	6a 33                	push   $0x33
f0104232:	e9 f9 08 00 00       	jmp    f0104b30 <_alltraps>
f0104237:	90                   	nop    

f0104238 <vector52>:
f0104238:	6a 00                	push   $0x0
f010423a:	6a 34                	push   $0x34
f010423c:	e9 ef 08 00 00       	jmp    f0104b30 <_alltraps>
f0104241:	90                   	nop    

f0104242 <vector53>:
f0104242:	6a 00                	push   $0x0
f0104244:	6a 35                	push   $0x35
f0104246:	e9 e5 08 00 00       	jmp    f0104b30 <_alltraps>
f010424b:	90                   	nop    

f010424c <vector54>:
f010424c:	6a 00                	push   $0x0
f010424e:	6a 36                	push   $0x36
f0104250:	e9 db 08 00 00       	jmp    f0104b30 <_alltraps>
f0104255:	90                   	nop    

f0104256 <vector55>:
f0104256:	6a 00                	push   $0x0
f0104258:	6a 37                	push   $0x37
f010425a:	e9 d1 08 00 00       	jmp    f0104b30 <_alltraps>
f010425f:	90                   	nop    

f0104260 <vector56>:
f0104260:	6a 00                	push   $0x0
f0104262:	6a 38                	push   $0x38
f0104264:	e9 c7 08 00 00       	jmp    f0104b30 <_alltraps>
f0104269:	90                   	nop    

f010426a <vector57>:
f010426a:	6a 00                	push   $0x0
f010426c:	6a 39                	push   $0x39
f010426e:	e9 bd 08 00 00       	jmp    f0104b30 <_alltraps>
f0104273:	90                   	nop    

f0104274 <vector58>:
f0104274:	6a 00                	push   $0x0
f0104276:	6a 3a                	push   $0x3a
f0104278:	e9 b3 08 00 00       	jmp    f0104b30 <_alltraps>
f010427d:	90                   	nop    

f010427e <vector59>:
f010427e:	6a 00                	push   $0x0
f0104280:	6a 3b                	push   $0x3b
f0104282:	e9 a9 08 00 00       	jmp    f0104b30 <_alltraps>
f0104287:	90                   	nop    

f0104288 <vector60>:
f0104288:	6a 00                	push   $0x0
f010428a:	6a 3c                	push   $0x3c
f010428c:	e9 9f 08 00 00       	jmp    f0104b30 <_alltraps>
f0104291:	90                   	nop    

f0104292 <vector61>:
f0104292:	6a 00                	push   $0x0
f0104294:	6a 3d                	push   $0x3d
f0104296:	e9 95 08 00 00       	jmp    f0104b30 <_alltraps>
f010429b:	90                   	nop    

f010429c <vector62>:
f010429c:	6a 00                	push   $0x0
f010429e:	6a 3e                	push   $0x3e
f01042a0:	e9 8b 08 00 00       	jmp    f0104b30 <_alltraps>
f01042a5:	90                   	nop    

f01042a6 <vector63>:
f01042a6:	6a 00                	push   $0x0
f01042a8:	6a 3f                	push   $0x3f
f01042aa:	e9 81 08 00 00       	jmp    f0104b30 <_alltraps>
f01042af:	90                   	nop    

f01042b0 <vector64>:
f01042b0:	6a 00                	push   $0x0
f01042b2:	6a 40                	push   $0x40
f01042b4:	e9 77 08 00 00       	jmp    f0104b30 <_alltraps>
f01042b9:	90                   	nop    

f01042ba <vector65>:
f01042ba:	6a 00                	push   $0x0
f01042bc:	6a 41                	push   $0x41
f01042be:	e9 6d 08 00 00       	jmp    f0104b30 <_alltraps>
f01042c3:	90                   	nop    

f01042c4 <vector66>:
f01042c4:	6a 00                	push   $0x0
f01042c6:	6a 42                	push   $0x42
f01042c8:	e9 63 08 00 00       	jmp    f0104b30 <_alltraps>
f01042cd:	90                   	nop    

f01042ce <vector67>:
f01042ce:	6a 00                	push   $0x0
f01042d0:	6a 43                	push   $0x43
f01042d2:	e9 59 08 00 00       	jmp    f0104b30 <_alltraps>
f01042d7:	90                   	nop    

f01042d8 <vector68>:
f01042d8:	6a 00                	push   $0x0
f01042da:	6a 44                	push   $0x44
f01042dc:	e9 4f 08 00 00       	jmp    f0104b30 <_alltraps>
f01042e1:	90                   	nop    

f01042e2 <vector69>:
f01042e2:	6a 00                	push   $0x0
f01042e4:	6a 45                	push   $0x45
f01042e6:	e9 45 08 00 00       	jmp    f0104b30 <_alltraps>
f01042eb:	90                   	nop    

f01042ec <vector70>:
f01042ec:	6a 00                	push   $0x0
f01042ee:	6a 46                	push   $0x46
f01042f0:	e9 3b 08 00 00       	jmp    f0104b30 <_alltraps>
f01042f5:	90                   	nop    

f01042f6 <vector71>:
f01042f6:	6a 00                	push   $0x0
f01042f8:	6a 47                	push   $0x47
f01042fa:	e9 31 08 00 00       	jmp    f0104b30 <_alltraps>
f01042ff:	90                   	nop    

f0104300 <vector72>:
f0104300:	6a 00                	push   $0x0
f0104302:	6a 48                	push   $0x48
f0104304:	e9 27 08 00 00       	jmp    f0104b30 <_alltraps>
f0104309:	90                   	nop    

f010430a <vector73>:
f010430a:	6a 00                	push   $0x0
f010430c:	6a 49                	push   $0x49
f010430e:	e9 1d 08 00 00       	jmp    f0104b30 <_alltraps>
f0104313:	90                   	nop    

f0104314 <vector74>:
f0104314:	6a 00                	push   $0x0
f0104316:	6a 4a                	push   $0x4a
f0104318:	e9 13 08 00 00       	jmp    f0104b30 <_alltraps>
f010431d:	90                   	nop    

f010431e <vector75>:
f010431e:	6a 00                	push   $0x0
f0104320:	6a 4b                	push   $0x4b
f0104322:	e9 09 08 00 00       	jmp    f0104b30 <_alltraps>
f0104327:	90                   	nop    

f0104328 <vector76>:
f0104328:	6a 00                	push   $0x0
f010432a:	6a 4c                	push   $0x4c
f010432c:	e9 ff 07 00 00       	jmp    f0104b30 <_alltraps>
f0104331:	90                   	nop    

f0104332 <vector77>:
f0104332:	6a 00                	push   $0x0
f0104334:	6a 4d                	push   $0x4d
f0104336:	e9 f5 07 00 00       	jmp    f0104b30 <_alltraps>
f010433b:	90                   	nop    

f010433c <vector78>:
f010433c:	6a 00                	push   $0x0
f010433e:	6a 4e                	push   $0x4e
f0104340:	e9 eb 07 00 00       	jmp    f0104b30 <_alltraps>
f0104345:	90                   	nop    

f0104346 <vector79>:
f0104346:	6a 00                	push   $0x0
f0104348:	6a 4f                	push   $0x4f
f010434a:	e9 e1 07 00 00       	jmp    f0104b30 <_alltraps>
f010434f:	90                   	nop    

f0104350 <vector80>:
f0104350:	6a 00                	push   $0x0
f0104352:	6a 50                	push   $0x50
f0104354:	e9 d7 07 00 00       	jmp    f0104b30 <_alltraps>
f0104359:	90                   	nop    

f010435a <vector81>:
f010435a:	6a 00                	push   $0x0
f010435c:	6a 51                	push   $0x51
f010435e:	e9 cd 07 00 00       	jmp    f0104b30 <_alltraps>
f0104363:	90                   	nop    

f0104364 <vector82>:
f0104364:	6a 00                	push   $0x0
f0104366:	6a 52                	push   $0x52
f0104368:	e9 c3 07 00 00       	jmp    f0104b30 <_alltraps>
f010436d:	90                   	nop    

f010436e <vector83>:
f010436e:	6a 00                	push   $0x0
f0104370:	6a 53                	push   $0x53
f0104372:	e9 b9 07 00 00       	jmp    f0104b30 <_alltraps>
f0104377:	90                   	nop    

f0104378 <vector84>:
f0104378:	6a 00                	push   $0x0
f010437a:	6a 54                	push   $0x54
f010437c:	e9 af 07 00 00       	jmp    f0104b30 <_alltraps>
f0104381:	90                   	nop    

f0104382 <vector85>:
f0104382:	6a 00                	push   $0x0
f0104384:	6a 55                	push   $0x55
f0104386:	e9 a5 07 00 00       	jmp    f0104b30 <_alltraps>
f010438b:	90                   	nop    

f010438c <vector86>:
f010438c:	6a 00                	push   $0x0
f010438e:	6a 56                	push   $0x56
f0104390:	e9 9b 07 00 00       	jmp    f0104b30 <_alltraps>
f0104395:	90                   	nop    

f0104396 <vector87>:
f0104396:	6a 00                	push   $0x0
f0104398:	6a 57                	push   $0x57
f010439a:	e9 91 07 00 00       	jmp    f0104b30 <_alltraps>
f010439f:	90                   	nop    

f01043a0 <vector88>:
f01043a0:	6a 00                	push   $0x0
f01043a2:	6a 58                	push   $0x58
f01043a4:	e9 87 07 00 00       	jmp    f0104b30 <_alltraps>
f01043a9:	90                   	nop    

f01043aa <vector89>:
f01043aa:	6a 00                	push   $0x0
f01043ac:	6a 59                	push   $0x59
f01043ae:	e9 7d 07 00 00       	jmp    f0104b30 <_alltraps>
f01043b3:	90                   	nop    

f01043b4 <vector90>:
f01043b4:	6a 00                	push   $0x0
f01043b6:	6a 5a                	push   $0x5a
f01043b8:	e9 73 07 00 00       	jmp    f0104b30 <_alltraps>
f01043bd:	90                   	nop    

f01043be <vector91>:
f01043be:	6a 00                	push   $0x0
f01043c0:	6a 5b                	push   $0x5b
f01043c2:	e9 69 07 00 00       	jmp    f0104b30 <_alltraps>
f01043c7:	90                   	nop    

f01043c8 <vector92>:
f01043c8:	6a 00                	push   $0x0
f01043ca:	6a 5c                	push   $0x5c
f01043cc:	e9 5f 07 00 00       	jmp    f0104b30 <_alltraps>
f01043d1:	90                   	nop    

f01043d2 <vector93>:
f01043d2:	6a 00                	push   $0x0
f01043d4:	6a 5d                	push   $0x5d
f01043d6:	e9 55 07 00 00       	jmp    f0104b30 <_alltraps>
f01043db:	90                   	nop    

f01043dc <vector94>:
f01043dc:	6a 00                	push   $0x0
f01043de:	6a 5e                	push   $0x5e
f01043e0:	e9 4b 07 00 00       	jmp    f0104b30 <_alltraps>
f01043e5:	90                   	nop    

f01043e6 <vector95>:
f01043e6:	6a 00                	push   $0x0
f01043e8:	6a 5f                	push   $0x5f
f01043ea:	e9 41 07 00 00       	jmp    f0104b30 <_alltraps>
f01043ef:	90                   	nop    

f01043f0 <vector96>:
f01043f0:	6a 00                	push   $0x0
f01043f2:	6a 60                	push   $0x60
f01043f4:	e9 37 07 00 00       	jmp    f0104b30 <_alltraps>
f01043f9:	90                   	nop    

f01043fa <vector97>:
f01043fa:	6a 00                	push   $0x0
f01043fc:	6a 61                	push   $0x61
f01043fe:	e9 2d 07 00 00       	jmp    f0104b30 <_alltraps>
f0104403:	90                   	nop    

f0104404 <vector98>:
f0104404:	6a 00                	push   $0x0
f0104406:	6a 62                	push   $0x62
f0104408:	e9 23 07 00 00       	jmp    f0104b30 <_alltraps>
f010440d:	90                   	nop    

f010440e <vector99>:
f010440e:	6a 00                	push   $0x0
f0104410:	6a 63                	push   $0x63
f0104412:	e9 19 07 00 00       	jmp    f0104b30 <_alltraps>
f0104417:	90                   	nop    

f0104418 <vector100>:
f0104418:	6a 00                	push   $0x0
f010441a:	6a 64                	push   $0x64
f010441c:	e9 0f 07 00 00       	jmp    f0104b30 <_alltraps>
f0104421:	90                   	nop    

f0104422 <vector101>:
f0104422:	6a 00                	push   $0x0
f0104424:	6a 65                	push   $0x65
f0104426:	e9 05 07 00 00       	jmp    f0104b30 <_alltraps>
f010442b:	90                   	nop    

f010442c <vector102>:
f010442c:	6a 00                	push   $0x0
f010442e:	6a 66                	push   $0x66
f0104430:	e9 fb 06 00 00       	jmp    f0104b30 <_alltraps>
f0104435:	90                   	nop    

f0104436 <vector103>:
f0104436:	6a 00                	push   $0x0
f0104438:	6a 67                	push   $0x67
f010443a:	e9 f1 06 00 00       	jmp    f0104b30 <_alltraps>
f010443f:	90                   	nop    

f0104440 <vector104>:
f0104440:	6a 00                	push   $0x0
f0104442:	6a 68                	push   $0x68
f0104444:	e9 e7 06 00 00       	jmp    f0104b30 <_alltraps>
f0104449:	90                   	nop    

f010444a <vector105>:
f010444a:	6a 00                	push   $0x0
f010444c:	6a 69                	push   $0x69
f010444e:	e9 dd 06 00 00       	jmp    f0104b30 <_alltraps>
f0104453:	90                   	nop    

f0104454 <vector106>:
f0104454:	6a 00                	push   $0x0
f0104456:	6a 6a                	push   $0x6a
f0104458:	e9 d3 06 00 00       	jmp    f0104b30 <_alltraps>
f010445d:	90                   	nop    

f010445e <vector107>:
f010445e:	6a 00                	push   $0x0
f0104460:	6a 6b                	push   $0x6b
f0104462:	e9 c9 06 00 00       	jmp    f0104b30 <_alltraps>
f0104467:	90                   	nop    

f0104468 <vector108>:
f0104468:	6a 00                	push   $0x0
f010446a:	6a 6c                	push   $0x6c
f010446c:	e9 bf 06 00 00       	jmp    f0104b30 <_alltraps>
f0104471:	90                   	nop    

f0104472 <vector109>:
f0104472:	6a 00                	push   $0x0
f0104474:	6a 6d                	push   $0x6d
f0104476:	e9 b5 06 00 00       	jmp    f0104b30 <_alltraps>
f010447b:	90                   	nop    

f010447c <vector110>:
f010447c:	6a 00                	push   $0x0
f010447e:	6a 6e                	push   $0x6e
f0104480:	e9 ab 06 00 00       	jmp    f0104b30 <_alltraps>
f0104485:	90                   	nop    

f0104486 <vector111>:
f0104486:	6a 00                	push   $0x0
f0104488:	6a 6f                	push   $0x6f
f010448a:	e9 a1 06 00 00       	jmp    f0104b30 <_alltraps>
f010448f:	90                   	nop    

f0104490 <vector112>:
f0104490:	6a 00                	push   $0x0
f0104492:	6a 70                	push   $0x70
f0104494:	e9 97 06 00 00       	jmp    f0104b30 <_alltraps>
f0104499:	90                   	nop    

f010449a <vector113>:
f010449a:	6a 00                	push   $0x0
f010449c:	6a 71                	push   $0x71
f010449e:	e9 8d 06 00 00       	jmp    f0104b30 <_alltraps>
f01044a3:	90                   	nop    

f01044a4 <vector114>:
f01044a4:	6a 00                	push   $0x0
f01044a6:	6a 72                	push   $0x72
f01044a8:	e9 83 06 00 00       	jmp    f0104b30 <_alltraps>
f01044ad:	90                   	nop    

f01044ae <vector115>:
f01044ae:	6a 00                	push   $0x0
f01044b0:	6a 73                	push   $0x73
f01044b2:	e9 79 06 00 00       	jmp    f0104b30 <_alltraps>
f01044b7:	90                   	nop    

f01044b8 <vector116>:
f01044b8:	6a 00                	push   $0x0
f01044ba:	6a 74                	push   $0x74
f01044bc:	e9 6f 06 00 00       	jmp    f0104b30 <_alltraps>
f01044c1:	90                   	nop    

f01044c2 <vector117>:
f01044c2:	6a 00                	push   $0x0
f01044c4:	6a 75                	push   $0x75
f01044c6:	e9 65 06 00 00       	jmp    f0104b30 <_alltraps>
f01044cb:	90                   	nop    

f01044cc <vector118>:
f01044cc:	6a 00                	push   $0x0
f01044ce:	6a 76                	push   $0x76
f01044d0:	e9 5b 06 00 00       	jmp    f0104b30 <_alltraps>
f01044d5:	90                   	nop    

f01044d6 <vector119>:
f01044d6:	6a 00                	push   $0x0
f01044d8:	6a 77                	push   $0x77
f01044da:	e9 51 06 00 00       	jmp    f0104b30 <_alltraps>
f01044df:	90                   	nop    

f01044e0 <vector120>:
f01044e0:	6a 00                	push   $0x0
f01044e2:	6a 78                	push   $0x78
f01044e4:	e9 47 06 00 00       	jmp    f0104b30 <_alltraps>
f01044e9:	90                   	nop    

f01044ea <vector121>:
f01044ea:	6a 00                	push   $0x0
f01044ec:	6a 79                	push   $0x79
f01044ee:	e9 3d 06 00 00       	jmp    f0104b30 <_alltraps>
f01044f3:	90                   	nop    

f01044f4 <vector122>:
f01044f4:	6a 00                	push   $0x0
f01044f6:	6a 7a                	push   $0x7a
f01044f8:	e9 33 06 00 00       	jmp    f0104b30 <_alltraps>
f01044fd:	90                   	nop    

f01044fe <vector123>:
f01044fe:	6a 00                	push   $0x0
f0104500:	6a 7b                	push   $0x7b
f0104502:	e9 29 06 00 00       	jmp    f0104b30 <_alltraps>
f0104507:	90                   	nop    

f0104508 <vector124>:
f0104508:	6a 00                	push   $0x0
f010450a:	6a 7c                	push   $0x7c
f010450c:	e9 1f 06 00 00       	jmp    f0104b30 <_alltraps>
f0104511:	90                   	nop    

f0104512 <vector125>:
f0104512:	6a 00                	push   $0x0
f0104514:	6a 7d                	push   $0x7d
f0104516:	e9 15 06 00 00       	jmp    f0104b30 <_alltraps>
f010451b:	90                   	nop    

f010451c <vector126>:
f010451c:	6a 00                	push   $0x0
f010451e:	6a 7e                	push   $0x7e
f0104520:	e9 0b 06 00 00       	jmp    f0104b30 <_alltraps>
f0104525:	90                   	nop    

f0104526 <vector127>:
f0104526:	6a 00                	push   $0x0
f0104528:	6a 7f                	push   $0x7f
f010452a:	e9 01 06 00 00       	jmp    f0104b30 <_alltraps>
f010452f:	90                   	nop    

f0104530 <vector128>:
f0104530:	6a 00                	push   $0x0
f0104532:	68 80 00 00 00       	push   $0x80
f0104537:	e9 f4 05 00 00       	jmp    f0104b30 <_alltraps>

f010453c <vector129>:
f010453c:	6a 00                	push   $0x0
f010453e:	68 81 00 00 00       	push   $0x81
f0104543:	e9 e8 05 00 00       	jmp    f0104b30 <_alltraps>

f0104548 <vector130>:
f0104548:	6a 00                	push   $0x0
f010454a:	68 82 00 00 00       	push   $0x82
f010454f:	e9 dc 05 00 00       	jmp    f0104b30 <_alltraps>

f0104554 <vector131>:
f0104554:	6a 00                	push   $0x0
f0104556:	68 83 00 00 00       	push   $0x83
f010455b:	e9 d0 05 00 00       	jmp    f0104b30 <_alltraps>

f0104560 <vector132>:
f0104560:	6a 00                	push   $0x0
f0104562:	68 84 00 00 00       	push   $0x84
f0104567:	e9 c4 05 00 00       	jmp    f0104b30 <_alltraps>

f010456c <vector133>:
f010456c:	6a 00                	push   $0x0
f010456e:	68 85 00 00 00       	push   $0x85
f0104573:	e9 b8 05 00 00       	jmp    f0104b30 <_alltraps>

f0104578 <vector134>:
f0104578:	6a 00                	push   $0x0
f010457a:	68 86 00 00 00       	push   $0x86
f010457f:	e9 ac 05 00 00       	jmp    f0104b30 <_alltraps>

f0104584 <vector135>:
f0104584:	6a 00                	push   $0x0
f0104586:	68 87 00 00 00       	push   $0x87
f010458b:	e9 a0 05 00 00       	jmp    f0104b30 <_alltraps>

f0104590 <vector136>:
f0104590:	6a 00                	push   $0x0
f0104592:	68 88 00 00 00       	push   $0x88
f0104597:	e9 94 05 00 00       	jmp    f0104b30 <_alltraps>

f010459c <vector137>:
f010459c:	6a 00                	push   $0x0
f010459e:	68 89 00 00 00       	push   $0x89
f01045a3:	e9 88 05 00 00       	jmp    f0104b30 <_alltraps>

f01045a8 <vector138>:
f01045a8:	6a 00                	push   $0x0
f01045aa:	68 8a 00 00 00       	push   $0x8a
f01045af:	e9 7c 05 00 00       	jmp    f0104b30 <_alltraps>

f01045b4 <vector139>:
f01045b4:	6a 00                	push   $0x0
f01045b6:	68 8b 00 00 00       	push   $0x8b
f01045bb:	e9 70 05 00 00       	jmp    f0104b30 <_alltraps>

f01045c0 <vector140>:
f01045c0:	6a 00                	push   $0x0
f01045c2:	68 8c 00 00 00       	push   $0x8c
f01045c7:	e9 64 05 00 00       	jmp    f0104b30 <_alltraps>

f01045cc <vector141>:
f01045cc:	6a 00                	push   $0x0
f01045ce:	68 8d 00 00 00       	push   $0x8d
f01045d3:	e9 58 05 00 00       	jmp    f0104b30 <_alltraps>

f01045d8 <vector142>:
f01045d8:	6a 00                	push   $0x0
f01045da:	68 8e 00 00 00       	push   $0x8e
f01045df:	e9 4c 05 00 00       	jmp    f0104b30 <_alltraps>

f01045e4 <vector143>:
f01045e4:	6a 00                	push   $0x0
f01045e6:	68 8f 00 00 00       	push   $0x8f
f01045eb:	e9 40 05 00 00       	jmp    f0104b30 <_alltraps>

f01045f0 <vector144>:
f01045f0:	6a 00                	push   $0x0
f01045f2:	68 90 00 00 00       	push   $0x90
f01045f7:	e9 34 05 00 00       	jmp    f0104b30 <_alltraps>

f01045fc <vector145>:
f01045fc:	6a 00                	push   $0x0
f01045fe:	68 91 00 00 00       	push   $0x91
f0104603:	e9 28 05 00 00       	jmp    f0104b30 <_alltraps>

f0104608 <vector146>:
f0104608:	6a 00                	push   $0x0
f010460a:	68 92 00 00 00       	push   $0x92
f010460f:	e9 1c 05 00 00       	jmp    f0104b30 <_alltraps>

f0104614 <vector147>:
f0104614:	6a 00                	push   $0x0
f0104616:	68 93 00 00 00       	push   $0x93
f010461b:	e9 10 05 00 00       	jmp    f0104b30 <_alltraps>

f0104620 <vector148>:
f0104620:	6a 00                	push   $0x0
f0104622:	68 94 00 00 00       	push   $0x94
f0104627:	e9 04 05 00 00       	jmp    f0104b30 <_alltraps>

f010462c <vector149>:
f010462c:	6a 00                	push   $0x0
f010462e:	68 95 00 00 00       	push   $0x95
f0104633:	e9 f8 04 00 00       	jmp    f0104b30 <_alltraps>

f0104638 <vector150>:
f0104638:	6a 00                	push   $0x0
f010463a:	68 96 00 00 00       	push   $0x96
f010463f:	e9 ec 04 00 00       	jmp    f0104b30 <_alltraps>

f0104644 <vector151>:
f0104644:	6a 00                	push   $0x0
f0104646:	68 97 00 00 00       	push   $0x97
f010464b:	e9 e0 04 00 00       	jmp    f0104b30 <_alltraps>

f0104650 <vector152>:
f0104650:	6a 00                	push   $0x0
f0104652:	68 98 00 00 00       	push   $0x98
f0104657:	e9 d4 04 00 00       	jmp    f0104b30 <_alltraps>

f010465c <vector153>:
f010465c:	6a 00                	push   $0x0
f010465e:	68 99 00 00 00       	push   $0x99
f0104663:	e9 c8 04 00 00       	jmp    f0104b30 <_alltraps>

f0104668 <vector154>:
f0104668:	6a 00                	push   $0x0
f010466a:	68 9a 00 00 00       	push   $0x9a
f010466f:	e9 bc 04 00 00       	jmp    f0104b30 <_alltraps>

f0104674 <vector155>:
f0104674:	6a 00                	push   $0x0
f0104676:	68 9b 00 00 00       	push   $0x9b
f010467b:	e9 b0 04 00 00       	jmp    f0104b30 <_alltraps>

f0104680 <vector156>:
f0104680:	6a 00                	push   $0x0
f0104682:	68 9c 00 00 00       	push   $0x9c
f0104687:	e9 a4 04 00 00       	jmp    f0104b30 <_alltraps>

f010468c <vector157>:
f010468c:	6a 00                	push   $0x0
f010468e:	68 9d 00 00 00       	push   $0x9d
f0104693:	e9 98 04 00 00       	jmp    f0104b30 <_alltraps>

f0104698 <vector158>:
f0104698:	6a 00                	push   $0x0
f010469a:	68 9e 00 00 00       	push   $0x9e
f010469f:	e9 8c 04 00 00       	jmp    f0104b30 <_alltraps>

f01046a4 <vector159>:
f01046a4:	6a 00                	push   $0x0
f01046a6:	68 9f 00 00 00       	push   $0x9f
f01046ab:	e9 80 04 00 00       	jmp    f0104b30 <_alltraps>

f01046b0 <vector160>:
f01046b0:	6a 00                	push   $0x0
f01046b2:	68 a0 00 00 00       	push   $0xa0
f01046b7:	e9 74 04 00 00       	jmp    f0104b30 <_alltraps>

f01046bc <vector161>:
f01046bc:	6a 00                	push   $0x0
f01046be:	68 a1 00 00 00       	push   $0xa1
f01046c3:	e9 68 04 00 00       	jmp    f0104b30 <_alltraps>

f01046c8 <vector162>:
f01046c8:	6a 00                	push   $0x0
f01046ca:	68 a2 00 00 00       	push   $0xa2
f01046cf:	e9 5c 04 00 00       	jmp    f0104b30 <_alltraps>

f01046d4 <vector163>:
f01046d4:	6a 00                	push   $0x0
f01046d6:	68 a3 00 00 00       	push   $0xa3
f01046db:	e9 50 04 00 00       	jmp    f0104b30 <_alltraps>

f01046e0 <vector164>:
f01046e0:	6a 00                	push   $0x0
f01046e2:	68 a4 00 00 00       	push   $0xa4
f01046e7:	e9 44 04 00 00       	jmp    f0104b30 <_alltraps>

f01046ec <vector165>:
f01046ec:	6a 00                	push   $0x0
f01046ee:	68 a5 00 00 00       	push   $0xa5
f01046f3:	e9 38 04 00 00       	jmp    f0104b30 <_alltraps>

f01046f8 <vector166>:
f01046f8:	6a 00                	push   $0x0
f01046fa:	68 a6 00 00 00       	push   $0xa6
f01046ff:	e9 2c 04 00 00       	jmp    f0104b30 <_alltraps>

f0104704 <vector167>:
f0104704:	6a 00                	push   $0x0
f0104706:	68 a7 00 00 00       	push   $0xa7
f010470b:	e9 20 04 00 00       	jmp    f0104b30 <_alltraps>

f0104710 <vector168>:
f0104710:	6a 00                	push   $0x0
f0104712:	68 a8 00 00 00       	push   $0xa8
f0104717:	e9 14 04 00 00       	jmp    f0104b30 <_alltraps>

f010471c <vector169>:
f010471c:	6a 00                	push   $0x0
f010471e:	68 a9 00 00 00       	push   $0xa9
f0104723:	e9 08 04 00 00       	jmp    f0104b30 <_alltraps>

f0104728 <vector170>:
f0104728:	6a 00                	push   $0x0
f010472a:	68 aa 00 00 00       	push   $0xaa
f010472f:	e9 fc 03 00 00       	jmp    f0104b30 <_alltraps>

f0104734 <vector171>:
f0104734:	6a 00                	push   $0x0
f0104736:	68 ab 00 00 00       	push   $0xab
f010473b:	e9 f0 03 00 00       	jmp    f0104b30 <_alltraps>

f0104740 <vector172>:
f0104740:	6a 00                	push   $0x0
f0104742:	68 ac 00 00 00       	push   $0xac
f0104747:	e9 e4 03 00 00       	jmp    f0104b30 <_alltraps>

f010474c <vector173>:
f010474c:	6a 00                	push   $0x0
f010474e:	68 ad 00 00 00       	push   $0xad
f0104753:	e9 d8 03 00 00       	jmp    f0104b30 <_alltraps>

f0104758 <vector174>:
f0104758:	6a 00                	push   $0x0
f010475a:	68 ae 00 00 00       	push   $0xae
f010475f:	e9 cc 03 00 00       	jmp    f0104b30 <_alltraps>

f0104764 <vector175>:
f0104764:	6a 00                	push   $0x0
f0104766:	68 af 00 00 00       	push   $0xaf
f010476b:	e9 c0 03 00 00       	jmp    f0104b30 <_alltraps>

f0104770 <vector176>:
f0104770:	6a 00                	push   $0x0
f0104772:	68 b0 00 00 00       	push   $0xb0
f0104777:	e9 b4 03 00 00       	jmp    f0104b30 <_alltraps>

f010477c <vector177>:
f010477c:	6a 00                	push   $0x0
f010477e:	68 b1 00 00 00       	push   $0xb1
f0104783:	e9 a8 03 00 00       	jmp    f0104b30 <_alltraps>

f0104788 <vector178>:
f0104788:	6a 00                	push   $0x0
f010478a:	68 b2 00 00 00       	push   $0xb2
f010478f:	e9 9c 03 00 00       	jmp    f0104b30 <_alltraps>

f0104794 <vector179>:
f0104794:	6a 00                	push   $0x0
f0104796:	68 b3 00 00 00       	push   $0xb3
f010479b:	e9 90 03 00 00       	jmp    f0104b30 <_alltraps>

f01047a0 <vector180>:
f01047a0:	6a 00                	push   $0x0
f01047a2:	68 b4 00 00 00       	push   $0xb4
f01047a7:	e9 84 03 00 00       	jmp    f0104b30 <_alltraps>

f01047ac <vector181>:
f01047ac:	6a 00                	push   $0x0
f01047ae:	68 b5 00 00 00       	push   $0xb5
f01047b3:	e9 78 03 00 00       	jmp    f0104b30 <_alltraps>

f01047b8 <vector182>:
f01047b8:	6a 00                	push   $0x0
f01047ba:	68 b6 00 00 00       	push   $0xb6
f01047bf:	e9 6c 03 00 00       	jmp    f0104b30 <_alltraps>

f01047c4 <vector183>:
f01047c4:	6a 00                	push   $0x0
f01047c6:	68 b7 00 00 00       	push   $0xb7
f01047cb:	e9 60 03 00 00       	jmp    f0104b30 <_alltraps>

f01047d0 <vector184>:
f01047d0:	6a 00                	push   $0x0
f01047d2:	68 b8 00 00 00       	push   $0xb8
f01047d7:	e9 54 03 00 00       	jmp    f0104b30 <_alltraps>

f01047dc <vector185>:
f01047dc:	6a 00                	push   $0x0
f01047de:	68 b9 00 00 00       	push   $0xb9
f01047e3:	e9 48 03 00 00       	jmp    f0104b30 <_alltraps>

f01047e8 <vector186>:
f01047e8:	6a 00                	push   $0x0
f01047ea:	68 ba 00 00 00       	push   $0xba
f01047ef:	e9 3c 03 00 00       	jmp    f0104b30 <_alltraps>

f01047f4 <vector187>:
f01047f4:	6a 00                	push   $0x0
f01047f6:	68 bb 00 00 00       	push   $0xbb
f01047fb:	e9 30 03 00 00       	jmp    f0104b30 <_alltraps>

f0104800 <vector188>:
f0104800:	6a 00                	push   $0x0
f0104802:	68 bc 00 00 00       	push   $0xbc
f0104807:	e9 24 03 00 00       	jmp    f0104b30 <_alltraps>

f010480c <vector189>:
f010480c:	6a 00                	push   $0x0
f010480e:	68 bd 00 00 00       	push   $0xbd
f0104813:	e9 18 03 00 00       	jmp    f0104b30 <_alltraps>

f0104818 <vector190>:
f0104818:	6a 00                	push   $0x0
f010481a:	68 be 00 00 00       	push   $0xbe
f010481f:	e9 0c 03 00 00       	jmp    f0104b30 <_alltraps>

f0104824 <vector191>:
f0104824:	6a 00                	push   $0x0
f0104826:	68 bf 00 00 00       	push   $0xbf
f010482b:	e9 00 03 00 00       	jmp    f0104b30 <_alltraps>

f0104830 <vector192>:
f0104830:	6a 00                	push   $0x0
f0104832:	68 c0 00 00 00       	push   $0xc0
f0104837:	e9 f4 02 00 00       	jmp    f0104b30 <_alltraps>

f010483c <vector193>:
f010483c:	6a 00                	push   $0x0
f010483e:	68 c1 00 00 00       	push   $0xc1
f0104843:	e9 e8 02 00 00       	jmp    f0104b30 <_alltraps>

f0104848 <vector194>:
f0104848:	6a 00                	push   $0x0
f010484a:	68 c2 00 00 00       	push   $0xc2
f010484f:	e9 dc 02 00 00       	jmp    f0104b30 <_alltraps>

f0104854 <vector195>:
f0104854:	6a 00                	push   $0x0
f0104856:	68 c3 00 00 00       	push   $0xc3
f010485b:	e9 d0 02 00 00       	jmp    f0104b30 <_alltraps>

f0104860 <vector196>:
f0104860:	6a 00                	push   $0x0
f0104862:	68 c4 00 00 00       	push   $0xc4
f0104867:	e9 c4 02 00 00       	jmp    f0104b30 <_alltraps>

f010486c <vector197>:
f010486c:	6a 00                	push   $0x0
f010486e:	68 c5 00 00 00       	push   $0xc5
f0104873:	e9 b8 02 00 00       	jmp    f0104b30 <_alltraps>

f0104878 <vector198>:
f0104878:	6a 00                	push   $0x0
f010487a:	68 c6 00 00 00       	push   $0xc6
f010487f:	e9 ac 02 00 00       	jmp    f0104b30 <_alltraps>

f0104884 <vector199>:
f0104884:	6a 00                	push   $0x0
f0104886:	68 c7 00 00 00       	push   $0xc7
f010488b:	e9 a0 02 00 00       	jmp    f0104b30 <_alltraps>

f0104890 <vector200>:
f0104890:	6a 00                	push   $0x0
f0104892:	68 c8 00 00 00       	push   $0xc8
f0104897:	e9 94 02 00 00       	jmp    f0104b30 <_alltraps>

f010489c <vector201>:
f010489c:	6a 00                	push   $0x0
f010489e:	68 c9 00 00 00       	push   $0xc9
f01048a3:	e9 88 02 00 00       	jmp    f0104b30 <_alltraps>

f01048a8 <vector202>:
f01048a8:	6a 00                	push   $0x0
f01048aa:	68 ca 00 00 00       	push   $0xca
f01048af:	e9 7c 02 00 00       	jmp    f0104b30 <_alltraps>

f01048b4 <vector203>:
f01048b4:	6a 00                	push   $0x0
f01048b6:	68 cb 00 00 00       	push   $0xcb
f01048bb:	e9 70 02 00 00       	jmp    f0104b30 <_alltraps>

f01048c0 <vector204>:
f01048c0:	6a 00                	push   $0x0
f01048c2:	68 cc 00 00 00       	push   $0xcc
f01048c7:	e9 64 02 00 00       	jmp    f0104b30 <_alltraps>

f01048cc <vector205>:
f01048cc:	6a 00                	push   $0x0
f01048ce:	68 cd 00 00 00       	push   $0xcd
f01048d3:	e9 58 02 00 00       	jmp    f0104b30 <_alltraps>

f01048d8 <vector206>:
f01048d8:	6a 00                	push   $0x0
f01048da:	68 ce 00 00 00       	push   $0xce
f01048df:	e9 4c 02 00 00       	jmp    f0104b30 <_alltraps>

f01048e4 <vector207>:
f01048e4:	6a 00                	push   $0x0
f01048e6:	68 cf 00 00 00       	push   $0xcf
f01048eb:	e9 40 02 00 00       	jmp    f0104b30 <_alltraps>

f01048f0 <vector208>:
f01048f0:	6a 00                	push   $0x0
f01048f2:	68 d0 00 00 00       	push   $0xd0
f01048f7:	e9 34 02 00 00       	jmp    f0104b30 <_alltraps>

f01048fc <vector209>:
f01048fc:	6a 00                	push   $0x0
f01048fe:	68 d1 00 00 00       	push   $0xd1
f0104903:	e9 28 02 00 00       	jmp    f0104b30 <_alltraps>

f0104908 <vector210>:
f0104908:	6a 00                	push   $0x0
f010490a:	68 d2 00 00 00       	push   $0xd2
f010490f:	e9 1c 02 00 00       	jmp    f0104b30 <_alltraps>

f0104914 <vector211>:
f0104914:	6a 00                	push   $0x0
f0104916:	68 d3 00 00 00       	push   $0xd3
f010491b:	e9 10 02 00 00       	jmp    f0104b30 <_alltraps>

f0104920 <vector212>:
f0104920:	6a 00                	push   $0x0
f0104922:	68 d4 00 00 00       	push   $0xd4
f0104927:	e9 04 02 00 00       	jmp    f0104b30 <_alltraps>

f010492c <vector213>:
f010492c:	6a 00                	push   $0x0
f010492e:	68 d5 00 00 00       	push   $0xd5
f0104933:	e9 f8 01 00 00       	jmp    f0104b30 <_alltraps>

f0104938 <vector214>:
f0104938:	6a 00                	push   $0x0
f010493a:	68 d6 00 00 00       	push   $0xd6
f010493f:	e9 ec 01 00 00       	jmp    f0104b30 <_alltraps>

f0104944 <vector215>:
f0104944:	6a 00                	push   $0x0
f0104946:	68 d7 00 00 00       	push   $0xd7
f010494b:	e9 e0 01 00 00       	jmp    f0104b30 <_alltraps>

f0104950 <vector216>:
f0104950:	6a 00                	push   $0x0
f0104952:	68 d8 00 00 00       	push   $0xd8
f0104957:	e9 d4 01 00 00       	jmp    f0104b30 <_alltraps>

f010495c <vector217>:
f010495c:	6a 00                	push   $0x0
f010495e:	68 d9 00 00 00       	push   $0xd9
f0104963:	e9 c8 01 00 00       	jmp    f0104b30 <_alltraps>

f0104968 <vector218>:
f0104968:	6a 00                	push   $0x0
f010496a:	68 da 00 00 00       	push   $0xda
f010496f:	e9 bc 01 00 00       	jmp    f0104b30 <_alltraps>

f0104974 <vector219>:
f0104974:	6a 00                	push   $0x0
f0104976:	68 db 00 00 00       	push   $0xdb
f010497b:	e9 b0 01 00 00       	jmp    f0104b30 <_alltraps>

f0104980 <vector220>:
f0104980:	6a 00                	push   $0x0
f0104982:	68 dc 00 00 00       	push   $0xdc
f0104987:	e9 a4 01 00 00       	jmp    f0104b30 <_alltraps>

f010498c <vector221>:
f010498c:	6a 00                	push   $0x0
f010498e:	68 dd 00 00 00       	push   $0xdd
f0104993:	e9 98 01 00 00       	jmp    f0104b30 <_alltraps>

f0104998 <vector222>:
f0104998:	6a 00                	push   $0x0
f010499a:	68 de 00 00 00       	push   $0xde
f010499f:	e9 8c 01 00 00       	jmp    f0104b30 <_alltraps>

f01049a4 <vector223>:
f01049a4:	6a 00                	push   $0x0
f01049a6:	68 df 00 00 00       	push   $0xdf
f01049ab:	e9 80 01 00 00       	jmp    f0104b30 <_alltraps>

f01049b0 <vector224>:
f01049b0:	6a 00                	push   $0x0
f01049b2:	68 e0 00 00 00       	push   $0xe0
f01049b7:	e9 74 01 00 00       	jmp    f0104b30 <_alltraps>

f01049bc <vector225>:
f01049bc:	6a 00                	push   $0x0
f01049be:	68 e1 00 00 00       	push   $0xe1
f01049c3:	e9 68 01 00 00       	jmp    f0104b30 <_alltraps>

f01049c8 <vector226>:
f01049c8:	6a 00                	push   $0x0
f01049ca:	68 e2 00 00 00       	push   $0xe2
f01049cf:	e9 5c 01 00 00       	jmp    f0104b30 <_alltraps>

f01049d4 <vector227>:
f01049d4:	6a 00                	push   $0x0
f01049d6:	68 e3 00 00 00       	push   $0xe3
f01049db:	e9 50 01 00 00       	jmp    f0104b30 <_alltraps>

f01049e0 <vector228>:
f01049e0:	6a 00                	push   $0x0
f01049e2:	68 e4 00 00 00       	push   $0xe4
f01049e7:	e9 44 01 00 00       	jmp    f0104b30 <_alltraps>

f01049ec <vector229>:
f01049ec:	6a 00                	push   $0x0
f01049ee:	68 e5 00 00 00       	push   $0xe5
f01049f3:	e9 38 01 00 00       	jmp    f0104b30 <_alltraps>

f01049f8 <vector230>:
f01049f8:	6a 00                	push   $0x0
f01049fa:	68 e6 00 00 00       	push   $0xe6
f01049ff:	e9 2c 01 00 00       	jmp    f0104b30 <_alltraps>

f0104a04 <vector231>:
f0104a04:	6a 00                	push   $0x0
f0104a06:	68 e7 00 00 00       	push   $0xe7
f0104a0b:	e9 20 01 00 00       	jmp    f0104b30 <_alltraps>

f0104a10 <vector232>:
f0104a10:	6a 00                	push   $0x0
f0104a12:	68 e8 00 00 00       	push   $0xe8
f0104a17:	e9 14 01 00 00       	jmp    f0104b30 <_alltraps>

f0104a1c <vector233>:
f0104a1c:	6a 00                	push   $0x0
f0104a1e:	68 e9 00 00 00       	push   $0xe9
f0104a23:	e9 08 01 00 00       	jmp    f0104b30 <_alltraps>

f0104a28 <vector234>:
f0104a28:	6a 00                	push   $0x0
f0104a2a:	68 ea 00 00 00       	push   $0xea
f0104a2f:	e9 fc 00 00 00       	jmp    f0104b30 <_alltraps>

f0104a34 <vector235>:
f0104a34:	6a 00                	push   $0x0
f0104a36:	68 eb 00 00 00       	push   $0xeb
f0104a3b:	e9 f0 00 00 00       	jmp    f0104b30 <_alltraps>

f0104a40 <vector236>:
f0104a40:	6a 00                	push   $0x0
f0104a42:	68 ec 00 00 00       	push   $0xec
f0104a47:	e9 e4 00 00 00       	jmp    f0104b30 <_alltraps>

f0104a4c <vector237>:
f0104a4c:	6a 00                	push   $0x0
f0104a4e:	68 ed 00 00 00       	push   $0xed
f0104a53:	e9 d8 00 00 00       	jmp    f0104b30 <_alltraps>

f0104a58 <vector238>:
f0104a58:	6a 00                	push   $0x0
f0104a5a:	68 ee 00 00 00       	push   $0xee
f0104a5f:	e9 cc 00 00 00       	jmp    f0104b30 <_alltraps>

f0104a64 <vector239>:
f0104a64:	6a 00                	push   $0x0
f0104a66:	68 ef 00 00 00       	push   $0xef
f0104a6b:	e9 c0 00 00 00       	jmp    f0104b30 <_alltraps>

f0104a70 <vector240>:
f0104a70:	6a 00                	push   $0x0
f0104a72:	68 f0 00 00 00       	push   $0xf0
f0104a77:	e9 b4 00 00 00       	jmp    f0104b30 <_alltraps>

f0104a7c <vector241>:
f0104a7c:	6a 00                	push   $0x0
f0104a7e:	68 f1 00 00 00       	push   $0xf1
f0104a83:	e9 a8 00 00 00       	jmp    f0104b30 <_alltraps>

f0104a88 <vector242>:
f0104a88:	6a 00                	push   $0x0
f0104a8a:	68 f2 00 00 00       	push   $0xf2
f0104a8f:	e9 9c 00 00 00       	jmp    f0104b30 <_alltraps>

f0104a94 <vector243>:
f0104a94:	6a 00                	push   $0x0
f0104a96:	68 f3 00 00 00       	push   $0xf3
f0104a9b:	e9 90 00 00 00       	jmp    f0104b30 <_alltraps>

f0104aa0 <vector244>:
f0104aa0:	6a 00                	push   $0x0
f0104aa2:	68 f4 00 00 00       	push   $0xf4
f0104aa7:	e9 84 00 00 00       	jmp    f0104b30 <_alltraps>

f0104aac <vector245>:
f0104aac:	6a 00                	push   $0x0
f0104aae:	68 f5 00 00 00       	push   $0xf5
f0104ab3:	e9 78 00 00 00       	jmp    f0104b30 <_alltraps>

f0104ab8 <vector246>:
f0104ab8:	6a 00                	push   $0x0
f0104aba:	68 f6 00 00 00       	push   $0xf6
f0104abf:	e9 6c 00 00 00       	jmp    f0104b30 <_alltraps>

f0104ac4 <vector247>:
f0104ac4:	6a 00                	push   $0x0
f0104ac6:	68 f7 00 00 00       	push   $0xf7
f0104acb:	e9 60 00 00 00       	jmp    f0104b30 <_alltraps>

f0104ad0 <vector248>:
f0104ad0:	6a 00                	push   $0x0
f0104ad2:	68 f8 00 00 00       	push   $0xf8
f0104ad7:	e9 54 00 00 00       	jmp    f0104b30 <_alltraps>

f0104adc <vector249>:
f0104adc:	6a 00                	push   $0x0
f0104ade:	68 f9 00 00 00       	push   $0xf9
f0104ae3:	e9 48 00 00 00       	jmp    f0104b30 <_alltraps>

f0104ae8 <vector250>:
f0104ae8:	6a 00                	push   $0x0
f0104aea:	68 fa 00 00 00       	push   $0xfa
f0104aef:	e9 3c 00 00 00       	jmp    f0104b30 <_alltraps>

f0104af4 <vector251>:
f0104af4:	6a 00                	push   $0x0
f0104af6:	68 fb 00 00 00       	push   $0xfb
f0104afb:	e9 30 00 00 00       	jmp    f0104b30 <_alltraps>

f0104b00 <vector252>:
f0104b00:	6a 00                	push   $0x0
f0104b02:	68 fc 00 00 00       	push   $0xfc
f0104b07:	e9 24 00 00 00       	jmp    f0104b30 <_alltraps>

f0104b0c <vector253>:
f0104b0c:	6a 00                	push   $0x0
f0104b0e:	68 fd 00 00 00       	push   $0xfd
f0104b13:	e9 18 00 00 00       	jmp    f0104b30 <_alltraps>

f0104b18 <vector254>:
f0104b18:	6a 00                	push   $0x0
f0104b1a:	68 fe 00 00 00       	push   $0xfe
f0104b1f:	e9 0c 00 00 00       	jmp    f0104b30 <_alltraps>

f0104b24 <vector255>:
f0104b24:	6a 00                	push   $0x0
f0104b26:	68 ff 00 00 00       	push   $0xff
f0104b2b:	e9 00 00 00 00       	jmp    f0104b30 <_alltraps>

f0104b30 <_alltraps>:
f0104b30:	1e                   	push   %ds
f0104b31:	06                   	push   %es
f0104b32:	60                   	pusha  
f0104b33:	66 b8 10 00          	mov    $0x10,%ax
f0104b37:	8e d8                	mov    %eax,%ds
f0104b39:	8e c0                	mov    %eax,%es
f0104b3b:	54                   	push   %esp
f0104b3c:	e8 64 f3 ff ff       	call   f0103ea5 <trap>
f0104b41:	83 c4 04             	add    $0x4,%esp

f0104b44 <trapret>:
f0104b44:	83 c4 04             	add    $0x4,%esp
f0104b47:	61                   	popa   
f0104b48:	07                   	pop    %es
f0104b49:	1f                   	pop    %ds
f0104b4a:	83 c4 08             	add    $0x8,%esp
f0104b4d:	cf                   	iret   
	...

f0104b50 <sched_yield>:


// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104b50:	55                   	push   %ebp
f0104b51:	89 e5                	mov    %esp,%ebp
f0104b53:	56                   	push   %esi
f0104b54:	53                   	push   %ebx
f0104b55:	83 ec 10             	sub    $0x10,%esp

	// LAB 4: Your code here.
	uint32_t retesp;
	envid_t envid;
	int index=0,i;
	if(curenv){
f0104b58:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f0104b5d:	be 00 00 00 00       	mov    $0x0,%esi
f0104b62:	85 c0                	test   %eax,%eax
f0104b64:	74 1b                	je     f0104b81 <sched_yield+0x31>
		//retesp=curenv->env_tf.tf_regs.reg_oesp-0x20;
		index=ENVX(curenv->env_id)-ENVX(envs[0].env_id);
f0104b66:	8b 40 4c             	mov    0x4c(%eax),%eax
f0104b69:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104b6e:	8b 15 40 45 29 f0    	mov    0xf0294540,%edx
f0104b74:	8b 52 4c             	mov    0x4c(%edx),%edx
f0104b77:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0104b7d:	89 c6                	mov    %eax,%esi
f0104b7f:	29 d6                	sub    %edx,%esi
	//	}
	//下面代码更简洁
	for(i=1;i<=NENV;i++)
	{
		envid=(i+index)%NENV;
		if(envs[envid].env_status==ENV_RUNNABLE)
f0104b81:	8b 1d 40 45 29 f0    	mov    0xf0294540,%ebx
f0104b87:	b9 01 00 00 00       	mov    $0x1,%ecx
	//		trapret();
	//	}
	//下面代码更简洁
	for(i=1;i<=NENV;i++)
	{
		envid=(i+index)%NENV;
f0104b8c:	8d 04 31             	lea    (%ecx,%esi,1),%eax
f0104b8f:	89 c2                	mov    %eax,%edx
f0104b91:	c1 fa 1f             	sar    $0x1f,%edx
f0104b94:	c1 ea 16             	shr    $0x16,%edx
f0104b97:	01 d0                	add    %edx,%eax
f0104b99:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104b9e:	29 d0                	sub    %edx,%eax
f0104ba0:	89 c2                	mov    %eax,%edx
		if(envs[envid].env_status==ENV_RUNNABLE)
f0104ba2:	6b c0 7c             	imul   $0x7c,%eax,%eax
f0104ba5:	01 d8                	add    %ebx,%eax
f0104ba7:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104bab:	75 0c                	jne    f0104bb9 <sched_yield+0x69>
		{
			if(envid==0)
f0104bad:	85 d2                	test   %edx,%edx
f0104baf:	74 08                	je     f0104bb9 <sched_yield+0x69>
				continue;
			//cprintf("\nslected env:%x\n",envs[envid].env_id);
			env_run(&envs[envid]);
f0104bb1:	89 04 24             	mov    %eax,(%esp)
f0104bb4:	e8 a8 e6 ff ff       	call   f0103261 <env_run>
	//		env_run(&envs[i]);
	//		write_esp(retesp);
	//		trapret();
	//	}
	//下面代码更简洁
	for(i=1;i<=NENV;i++)
f0104bb9:	83 c1 01             	add    $0x1,%ecx
f0104bbc:	81 f9 01 04 00 00    	cmp    $0x401,%ecx
f0104bc2:	75 c8                	jne    f0104b8c <sched_yield+0x3c>
			//write_esp(retesp);
			//trapret();
		}
	}
	// Run the special idle environment when nothing else is runnable.
	if (envs[0].env_status == ENV_RUNNABLE)
f0104bc4:	83 7b 54 01          	cmpl   $0x1,0x54(%ebx)
f0104bc8:	75 08                	jne    f0104bd2 <sched_yield+0x82>
		env_run(&envs[0]);
f0104bca:	89 1c 24             	mov    %ebx,(%esp)
f0104bcd:	e8 8f e6 ff ff       	call   f0103261 <env_run>
	else {
		cprintf("Destroyed all environments - nothing more to do!\n");
f0104bd2:	c7 04 24 70 bd 10 f0 	movl   $0xf010bd70,(%esp)
f0104bd9:	e8 09 ee ff ff       	call   f01039e7 <cprintf>
		while (1)
			monitor(NULL);
f0104bde:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104be5:	e8 9d bd ff ff       	call   f0100987 <monitor>
f0104bea:	eb f2                	jmp    f0104bde <sched_yield+0x8e>
f0104bec:	00 00                	add    %al,(%eax)
	...

f0104bf0 <sys_page_map>:
//		address space.
//	-E_NO_MEM if there's no memory to allocate any necessary page tables.
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
f0104bf0:	55                   	push   %ebp
f0104bf1:	89 e5                	mov    %esp,%ebp
f0104bf3:	83 ec 38             	sub    $0x38,%esp
f0104bf6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104bf9:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104bfc:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104bff:	89 c3                	mov    %eax,%ebx
f0104c01:	89 d7                	mov    %edx,%edi
f0104c03:	89 ce                	mov    %ecx,%esi
	struct Env *srcenv,*dstenv;
	struct Page *pg;
	pte_t *pte;
	physaddr_t old_cr3;
	//cprintf("srcenvid=%x dstenvid=%x srcva=%x dstva=%x perm=%x\n",srcenvid,dstenvid,(uint32_t)srcva,(uint32_t)dstva,perm);
	if(srcenvid==0)
f0104c05:	85 c0                	test   %eax,%eax
f0104c07:	75 0a                	jne    f0104c13 <sys_page_map+0x23>
		srcenv=curenv;
f0104c09:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f0104c0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c11:	eb 1f                	jmp    f0104c32 <sys_page_map+0x42>
	else
		if((r=envid2env(srcenvid,&srcenv,0))<0)//LAB 5:be carefull to use envid2env
f0104c13:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104c1a:	00 
f0104c1b:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104c1e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c22:	89 1c 24             	mov    %ebx,(%esp)
f0104c25:	e8 1a e5 ff ff       	call   f0103144 <envid2env>
f0104c2a:	85 c0                	test   %eax,%eax
f0104c2c:	0f 88 c2 00 00 00    	js     f0104cf4 <sys_page_map+0x104>
        	{
                	return r;
        	}
	if(dstenvid==0)
f0104c32:	85 f6                	test   %esi,%esi
f0104c34:	75 0a                	jne    f0104c40 <sys_page_map+0x50>
		dstenv=curenv;
f0104c36:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f0104c3b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104c3e:	eb 1f                	jmp    f0104c5f <sys_page_map+0x6f>
	else
		if((r=envid2env(dstenvid,&dstenv,0))<0)
f0104c40:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104c47:	00 
f0104c48:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104c4b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c4f:	89 34 24             	mov    %esi,(%esp)
f0104c52:	e8 ed e4 ff ff       	call   f0103144 <envid2env>
f0104c57:	85 c0                	test   %eax,%eax
f0104c59:	0f 88 95 00 00 00    	js     f0104cf4 <sys_page_map+0x104>
        	{
                	return r;
        	}
	if(((uint32_t)srcva>=UTOP)||((uint32_t)srcva&0xfff)||((uint32_t)dstva>=UTOP)||((uint32_t)srcva&0xfff))
f0104c5f:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0104c65:	0f 87 84 00 00 00    	ja     f0104cef <sys_page_map+0xff>
f0104c6b:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0104c71:	75 7c                	jne    f0104cef <sys_page_map+0xff>
f0104c73:	81 7d 08 ff ff bf ee 	cmpl   $0xeebfffff,0x8(%ebp)
f0104c7a:	77 73                	ja     f0104cef <sys_page_map+0xff>
                return -E_INVAL;
	if(perm&(~PTE_USER))
f0104c7c:	f7 45 0c f8 f1 ff ff 	testl  $0xfffff1f8,0xc(%ebp)
f0104c83:	75 6a                	jne    f0104cef <sys_page_map+0xff>

static __inline uint32_t
rcr3(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr3,%0" : "=r" (val));
f0104c85:	0f 20 db             	mov    %cr3,%ebx
                return -E_INVAL;
	old_cr3=rcr3();
	lcr3(srcenv->env_cr3);
f0104c88:	8b 55 f0             	mov    -0x10(%ebp),%edx
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104c8b:	8b 42 60             	mov    0x60(%edx),%eax
f0104c8e:	0f 22 d8             	mov    %eax,%cr3
	if(!(pg=page_lookup(srcenv->env_pgdir,srcva,&pte)))
f0104c91:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0104c94:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104c98:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104c9c:	8b 42 5c             	mov    0x5c(%edx),%eax
f0104c9f:	89 04 24             	mov    %eax,(%esp)
f0104ca2:	e8 84 c7 ff ff       	call   f010142b <page_lookup>
f0104ca7:	89 c1                	mov    %eax,%ecx
f0104ca9:	85 c0                	test   %eax,%eax
f0104cab:	74 42                	je     f0104cef <sys_page_map+0xff>
		return -E_INVAL;
	if(!(*pte&PTE_W)&&(perm&PTE_W))	//当srcva页面是只读时，perm不能有写权限
f0104cad:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104cb0:	f6 00 02             	testb  $0x2,(%eax)
f0104cb3:	75 06                	jne    f0104cbb <sys_page_map+0xcb>
f0104cb5:	f6 45 0c 02          	testb  $0x2,0xc(%ebp)
f0104cb9:	75 34                	jne    f0104cef <sys_page_map+0xff>
		return -E_INVAL;
	lcr3(dstenv->env_cr3);
f0104cbb:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104cbe:	8b 50 60             	mov    0x60(%eax),%edx
f0104cc1:	0f 22 da             	mov    %edx,%cr3
	if((r=page_insert(dstenv->env_pgdir,pg,dstva,perm))<0)
f0104cc4:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104cc7:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104ccb:	8b 55 08             	mov    0x8(%ebp),%edx
f0104cce:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104cd2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104cd6:	8b 40 5c             	mov    0x5c(%eax),%eax
f0104cd9:	89 04 24             	mov    %eax,(%esp)
f0104cdc:	e8 da c9 ff ff       	call   f01016bb <page_insert>
f0104ce1:	85 c0                	test   %eax,%eax
f0104ce3:	78 0f                	js     f0104cf4 <sys_page_map+0x104>
f0104ce5:	0f 22 db             	mov    %ebx,%cr3
f0104ce8:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ced:	eb 05                	jmp    f0104cf4 <sys_page_map+0x104>
		return r;
	lcr3(old_cr3);
	return 0;
f0104cef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	//panic("sys_page_map not implemented");
}
f0104cf4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104cf7:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0104cfa:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0104cfd:	89 ec                	mov    %ebp,%esp
f0104cff:	5d                   	pop    %ebp
f0104d00:	c3                   	ret    

f0104d01 <syscall>:
	//panic("sys_time_msec not implemented");
}
// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104d01:	55                   	push   %ebp
f0104d02:	89 e5                	mov    %esp,%ebp
f0104d04:	83 ec 38             	sub    $0x38,%esp
f0104d07:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104d0a:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104d0d:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104d10:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int r;
	switch(syscallno){
f0104d13:	83 f8 0e             	cmp    $0xe,%eax
f0104d16:	0f 87 57 05 00 00    	ja     f0105273 <syscall+0x572>
f0104d1c:	ff 24 85 0c be 10 f0 	jmp    *-0xfef41f4(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.
	
	// LAB 3: Your code here.
	user_mem_assert(curenv,(void*)s,len,0);
f0104d23:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104d2a:	00 
f0104d2b:	8b 45 10             	mov    0x10(%ebp),%eax
f0104d2e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104d32:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104d35:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104d39:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f0104d3e:	89 04 24             	mov    %eax,(%esp)
f0104d41:	e8 39 c8 ff ff       	call   f010157f <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104d46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104d49:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104d4d:	8b 45 10             	mov    0x10(%ebp),%eax
f0104d50:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d54:	c7 04 24 a2 bd 10 f0 	movl   $0xf010bda2,(%esp)
f0104d5b:	e8 87 ec ff ff       	call   f01039e7 <cprintf>
f0104d60:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104d65:	e9 2a 05 00 00       	jmp    f0105294 <syscall+0x593>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104d6a:	e8 ae b4 ff ff       	call   f010021d <cons_getc>
f0104d6f:	89 c3                	mov    %eax,%ebx
f0104d71:	e9 1e 05 00 00       	jmp    f0105294 <syscall+0x593>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104d76:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f0104d7b:	8b 58 4c             	mov    0x4c(%eax),%ebx
f0104d7e:	e9 11 05 00 00       	jmp    f0105294 <syscall+0x593>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104d83:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104d8a:	00 
f0104d8b:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104d8e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d92:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104d95:	89 14 24             	mov    %edx,(%esp)
f0104d98:	e8 a7 e3 ff ff       	call   f0103144 <envid2env>
f0104d9d:	89 c3                	mov    %eax,%ebx
f0104d9f:	85 c0                	test   %eax,%eax
f0104da1:	0f 88 ed 04 00 00    	js     f0105294 <syscall+0x593>
		return r;
	env_destroy(e);
f0104da7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104daa:	89 04 24             	mov    %eax,(%esp)
f0104dad:	e8 54 ea ff ff       	call   f0103806 <env_destroy>
f0104db2:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104db7:	e9 d8 04 00 00       	jmp    f0105294 <syscall+0x593>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104dbc:	e8 8f fd ff ff       	call   f0104b50 <sched_yield>
	// will appear to return 0.

	// LAB 4: Your code here.
	int r;
	struct Env *childenv;
	if((r=env_alloc(&childenv,curenv->env_id))<0)
f0104dc1:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f0104dc6:	8b 40 4c             	mov    0x4c(%eax),%eax
f0104dc9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104dcd:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104dd0:	89 04 24             	mov    %eax,(%esp)
f0104dd3:	e8 af e4 ff ff       	call   f0103287 <env_alloc>
f0104dd8:	89 c3                	mov    %eax,%ebx
f0104dda:	85 c0                	test   %eax,%eax
f0104ddc:	79 11                	jns    f0104def <syscall+0xee>
	{
		cprintf("env_alloc failed\n");
f0104dde:	c7 04 24 a7 bd 10 f0 	movl   $0xf010bda7,(%esp)
f0104de5:	e8 fd eb ff ff       	call   f01039e7 <cprintf>
f0104dea:	e9 a5 04 00 00       	jmp    f0105294 <syscall+0x593>
		return r;
	}
	childenv->env_status=ENV_NOT_RUNNABLE;
f0104def:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104df2:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	//cprintf("curenv=%x childenv=%x\n",curenv->env_id,childenv->env_id);
	memmove(&childenv->env_tf,&curenv->env_tf,sizeof(struct Trapframe));//拷贝父进程的寄存器状态
f0104df9:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0104e00:	00 
f0104e01:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f0104e06:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104e0d:	89 04 24             	mov    %eax,(%esp)
f0104e10:	e8 23 49 00 00       	call   f0109738 <memmove>
	childenv->env_tf.tf_regs.reg_eax=0;//在子进程中，返回0
f0104e15:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104e18:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
		
	return childenv->env_id;
f0104e1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104e22:	8b 58 4c             	mov    0x4c(%eax),%ebx
f0104e25:	e9 6a 04 00 00       	jmp    f0105294 <syscall+0x593>
	// envid's status.

	// LAB 4: Your code here.
	int r;
	struct Env *e;
	if(status>2||status<0)
f0104e2a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104e2f:	83 7d 10 02          	cmpl   $0x2,0x10(%ebp)
f0104e33:	0f 87 5b 04 00 00    	ja     f0105294 <syscall+0x593>
		return -E_INVAL;
	if(envid==0)
f0104e39:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104e3d:	75 0a                	jne    f0104e49 <syscall+0x148>
		e=curenv;
f0104e3f:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f0104e44:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104e47:	eb 24                	jmp    f0104e6d <syscall+0x16c>
	else
		if((r=envid2env(envid,&e,1))<0)
f0104e49:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e50:	00 
f0104e51:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104e54:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104e5b:	89 0c 24             	mov    %ecx,(%esp)
f0104e5e:	e8 e1 e2 ff ff       	call   f0103144 <envid2env>
f0104e63:	89 c3                	mov    %eax,%ebx
f0104e65:	85 c0                	test   %eax,%eax
f0104e67:	0f 88 27 04 00 00    	js     f0105294 <syscall+0x593>
		{
			return r;
		}
	e->env_status=status;
f0104e6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104e70:	8b 55 10             	mov    0x10(%ebp),%edx
f0104e73:	89 50 54             	mov    %edx,0x54(%eax)
f0104e76:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104e7b:	e9 14 04 00 00       	jmp    f0105294 <syscall+0x593>
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	int r;
	struct Env *e;
	if(envid==0)
f0104e80:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104e84:	75 0a                	jne    f0104e90 <syscall+0x18f>
		e=curenv;
f0104e86:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f0104e8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104e8e:	eb 24                	jmp    f0104eb4 <syscall+0x1b3>
	else
		if((r=envid2env(envid,&e,1))<0)
f0104e90:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e97:	00 
f0104e98:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104e9b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104ea2:	89 0c 24             	mov    %ecx,(%esp)
f0104ea5:	e8 9a e2 ff ff       	call   f0103144 <envid2env>
f0104eaa:	89 c3                	mov    %eax,%ebx
f0104eac:	85 c0                	test   %eax,%eax
f0104eae:	0f 88 e0 03 00 00    	js     f0105294 <syscall+0x593>
			return r;
	user_mem_assert(e,(void*)tf,sizeof(struct Trapframe),0);
f0104eb4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104ebb:	00 
f0104ebc:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0104ec3:	00 
f0104ec4:	8b 45 10             	mov    0x10(%ebp),%eax
f0104ec7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ecb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104ece:	89 04 24             	mov    %eax,(%esp)
f0104ed1:	e8 a9 c6 ff ff       	call   f010157f <user_mem_assert>
	if(tf)
f0104ed6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0104eda:	74 1a                	je     f0104ef6 <syscall+0x1f5>
		e->env_tf=*tf;
f0104edc:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0104ee3:	00 
f0104ee4:	8b 55 10             	mov    0x10(%ebp),%edx
f0104ee7:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104eeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104eee:	89 04 24             	mov    %eax,(%esp)
f0104ef1:	e8 c2 48 00 00       	call   f01097b8 <memcpy>
	e->env_tf.tf_eflags|=FL_IF;
f0104ef6:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104ef9:	81 48 38 00 02 00 00 	orl    $0x200,0x38(%eax)
f0104f00:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104f05:	e9 8a 03 00 00       	jmp    f0105294 <syscall+0x593>
	int r;//检查envid的合法性
        struct Env *e;
	struct Page *pg;
	physaddr_t old_cr3;//需要切换cr3
	uint32_t *page;
	if(envid==0)
f0104f0a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104f0e:	75 0a                	jne    f0104f1a <syscall+0x219>
		e=curenv;
f0104f10:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f0104f15:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104f18:	eb 24                	jmp    f0104f3e <syscall+0x23d>
	else
        	if((r=envid2env(envid,&e,0))<0)
f0104f1a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104f21:	00 
f0104f22:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104f25:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104f2c:	89 0c 24             	mov    %ecx,(%esp)
f0104f2f:	e8 10 e2 ff ff       	call   f0103144 <envid2env>
f0104f34:	89 c3                	mov    %eax,%ebx
f0104f36:	85 c0                	test   %eax,%eax
f0104f38:	0f 88 56 03 00 00    	js     f0105294 <syscall+0x593>
			break;
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1,(struct Trapframe*)a2);
			break;
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
f0104f3e:	8b 75 10             	mov    0x10(%ebp),%esi
	else
        	if((r=envid2env(envid,&e,0))<0)
        	{
                	return r;
        	}
	if((uint32_t)va>=UTOP||((uint32_t)va&0xfff))
f0104f41:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104f47:	0f 87 e3 00 00 00    	ja     f0105030 <syscall+0x32f>
f0104f4d:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0104f53:	0f 85 d7 00 00 00    	jne    f0105030 <syscall+0x32f>
			break;
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1,(struct Trapframe*)a2);
			break;
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
f0104f59:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f5c:	89 45 e0             	mov    %eax,-0x20(%ebp)
        	{
                	return r;
        	}
	if((uint32_t)va>=UTOP||((uint32_t)va&0xfff))
		return -E_INVAL;
	if(perm&(~PTE_USER))
f0104f5f:	a9 f8 f1 ff ff       	test   $0xfffff1f8,%eax
f0104f64:	0f 85 c6 00 00 00    	jne    f0105030 <syscall+0x32f>
		return -E_INVAL;
	if((r=page_alloc(&pg))<0)
f0104f6a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104f6d:	89 04 24             	mov    %eax,(%esp)
f0104f70:	e8 21 c3 ff ff       	call   f0101296 <page_alloc>
f0104f75:	89 c3                	mov    %eax,%ebx
f0104f77:	85 c0                	test   %eax,%eax
f0104f79:	0f 88 15 03 00 00    	js     f0105294 <syscall+0x593>
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0104f7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104f82:	2b 05 fc 54 29 f0    	sub    0xf02954fc,%eax
f0104f88:	c1 f8 02             	sar    $0x2,%eax
f0104f8b:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104f91:	89 c2                	mov    %eax,%edx
f0104f93:	c1 e2 0c             	shl    $0xc,%edx
		return r;
	page = (uint32_t*)KADDR(page2pa(pg));
f0104f96:	89 d0                	mov    %edx,%eax
f0104f98:	c1 e8 0c             	shr    $0xc,%eax
f0104f9b:	3b 05 f0 54 29 f0    	cmp    0xf02954f0,%eax
f0104fa1:	72 20                	jb     f0104fc3 <syscall+0x2c2>
f0104fa3:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104fa7:	c7 44 24 08 e8 ac 10 	movl   $0xf010ace8,0x8(%esp)
f0104fae:	f0 
f0104faf:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
f0104fb6:	00 
f0104fb7:	c7 04 24 b9 bd 10 f0 	movl   $0xf010bdb9,(%esp)
f0104fbe:	e8 c3 b0 ff ff       	call   f0100086 <_panic>
		//计算物理页面的虚拟起始地址，pg是页面管理结构节点指针
	memset(page,0,PGSIZE);
f0104fc3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0104fca:	00 
f0104fcb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0104fd2:	00 
		return -E_INVAL;
	if(perm&(~PTE_USER))
		return -E_INVAL;
	if((r=page_alloc(&pg))<0)
		return r;
	page = (uint32_t*)KADDR(page2pa(pg));
f0104fd3:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0104fd9:	89 04 24             	mov    %eax,(%esp)
f0104fdc:	e8 fd 46 00 00       	call   f01096de <memset>

static __inline uint32_t
rcr3(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr3,%0" : "=r" (val));
f0104fe1:	0f 20 df             	mov    %cr3,%edi
		//计算物理页面的虚拟起始地址，pg是页面管理结构节点指针
	memset(page,0,PGSIZE);
	old_cr3=rcr3();
	lcr3(e->env_cr3);
f0104fe4:	8b 55 f0             	mov    -0x10(%ebp),%edx
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104fe7:	8b 42 60             	mov    0x60(%edx),%eax
f0104fea:	0f 22 d8             	mov    %eax,%cr3
	if((r=page_insert(e->env_pgdir,pg,va,perm))<0)
f0104fed:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104ff0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104ff4:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104ff8:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104ffb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104fff:	8b 42 5c             	mov    0x5c(%edx),%eax
f0105002:	89 04 24             	mov    %eax,(%esp)
f0105005:	e8 b1 c6 ff ff       	call   f01016bb <page_insert>
f010500a:	89 c3                	mov    %eax,%ebx
f010500c:	85 c0                	test   %eax,%eax
f010500e:	79 13                	jns    f0105023 <syscall+0x322>
	{
		page_free(pg);
f0105010:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105013:	89 04 24             	mov    %eax,(%esp)
f0105016:	e8 4d c0 ff ff       	call   f0101068 <page_free>
f010501b:	0f 22 df             	mov    %edi,%cr3
f010501e:	e9 71 02 00 00       	jmp    f0105294 <syscall+0x593>
f0105023:	0f 22 df             	mov    %edi,%cr3
f0105026:	bb 00 00 00 00       	mov    $0x0,%ebx
f010502b:	e9 64 02 00 00       	jmp    f0105294 <syscall+0x593>
f0105030:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105035:	e9 5a 02 00 00       	jmp    f0105294 <syscall+0x593>
			break;
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
			break;
		case SYS_page_map:
			return sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,(int)a5);
f010503a:	8b 45 1c             	mov    0x1c(%ebp),%eax
f010503d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105041:	8b 55 18             	mov    0x18(%ebp),%edx
f0105044:	89 14 24             	mov    %edx,(%esp)
f0105047:	8b 4d 14             	mov    0x14(%ebp),%ecx
f010504a:	8b 55 10             	mov    0x10(%ebp),%edx
f010504d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105050:	e8 9b fb ff ff       	call   f0104bf0 <sys_page_map>
f0105055:	89 c3                	mov    %eax,%ebx
f0105057:	e9 38 02 00 00       	jmp    f0105294 <syscall+0x593>

	// LAB 4: Your code here.
	int r;
	struct Env *e;
	physaddr_t old_cr3;
	if(envid==0)
f010505c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105060:	75 0a                	jne    f010506c <syscall+0x36b>
		e=curenv;
f0105062:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f0105067:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010506a:	eb 24                	jmp    f0105090 <syscall+0x38f>
	else
		if((r=envid2env(envid,&e,0))<0)
f010506c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0105073:	00 
f0105074:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105077:	89 44 24 04          	mov    %eax,0x4(%esp)
f010507b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010507e:	89 0c 24             	mov    %ecx,(%esp)
f0105081:	e8 be e0 ff ff       	call   f0103144 <envid2env>
f0105086:	89 c3                	mov    %eax,%ebx
f0105088:	85 c0                	test   %eax,%eax
f010508a:	0f 88 04 02 00 00    	js     f0105294 <syscall+0x593>
        	{
                	return r;
        	}
        if((uint32_t)va>=UTOP||((uint32_t)va&0xfff))
f0105090:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105097:	77 34                	ja     f01050cd <syscall+0x3cc>
f0105099:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01050a0:	75 2b                	jne    f01050cd <syscall+0x3cc>

static __inline uint32_t
rcr3(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr3,%0" : "=r" (val));
f01050a2:	0f 20 db             	mov    %cr3,%ebx
                return -E_INVAL;
	old_cr3=rcr3();
	lcr3(e->env_cr3);
f01050a5:	8b 55 ec             	mov    -0x14(%ebp),%edx
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01050a8:	8b 42 60             	mov    0x60(%edx),%eax
f01050ab:	0f 22 d8             	mov    %eax,%cr3
	page_remove(e->env_pgdir,va);
f01050ae:	8b 45 10             	mov    0x10(%ebp),%eax
f01050b1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050b5:	8b 42 5c             	mov    0x5c(%edx),%eax
f01050b8:	89 04 24             	mov    %eax,(%esp)
f01050bb:	e8 17 c5 ff ff       	call   f01015d7 <page_remove>
f01050c0:	0f 22 db             	mov    %ebx,%cr3
f01050c3:	bb 00 00 00 00       	mov    $0x0,%ebx
f01050c8:	e9 c7 01 00 00       	jmp    f0105294 <syscall+0x593>
f01050cd:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01050d2:	e9 bd 01 00 00       	jmp    f0105294 <syscall+0x593>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	int r;
	struct Env *e;
	if(envid==0)
f01050d7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01050db:	75 0a                	jne    f01050e7 <syscall+0x3e6>
		e=curenv;
f01050dd:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f01050e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01050e5:	eb 24                	jmp    f010510b <syscall+0x40a>
	else
		if((r=envid2env(envid,&e,1))<0)
f01050e7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01050ee:	00 
f01050ef:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01050f2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050f6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01050f9:	89 14 24             	mov    %edx,(%esp)
f01050fc:	e8 43 e0 ff ff       	call   f0103144 <envid2env>
f0105101:	89 c3                	mov    %eax,%ebx
f0105103:	85 c0                	test   %eax,%eax
f0105105:	0f 88 89 01 00 00    	js     f0105294 <syscall+0x593>
			return r;
	e->env_pgfault_upcall=func;
f010510b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010510e:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105111:	89 48 64             	mov    %ecx,0x64(%eax)
f0105114:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105119:	e9 76 01 00 00       	jmp    f0105294 <syscall+0x593>
			break;
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1,(void*)a2);
			break;
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1,(uint32_t)a2,(void*)a3,(unsigned)a4);
f010511e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	//cprintf("sys_ipc_try_send:here envid=%x\n",envid);
	//当一个环境正在等待接收一个信息，任何其他环境都能给它发送信息
	//这不限于特定环境，也不需要发送环境与接收环境有父子关系，
	//envid2env中的第3个参数置0
	//下面用到了页面映射函数，因此也需要该函数中的envid2env中的第3个参数置0
	if((envid==0)||(envid==curenv->env_id))
f0105121:	85 ff                	test   %edi,%edi
f0105123:	74 0a                	je     f010512f <syscall+0x42e>
f0105125:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f010512a:	3b 78 4c             	cmp    0x4c(%eax),%edi
f010512d:	75 22                	jne    f0105151 <syscall+0x450>
	{
		cprintf("the same send:envid=%x\n",curenv->env_id);
f010512f:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f0105134:	8b 40 4c             	mov    0x4c(%eax),%eax
f0105137:	89 44 24 04          	mov    %eax,0x4(%esp)
f010513b:	c7 04 24 c8 bd 10 f0 	movl   $0xf010bdc8,(%esp)
f0105142:	e8 a0 e8 ff ff       	call   f01039e7 <cprintf>
		e=curenv;
f0105147:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f010514c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010514f:	eb 32                	jmp    f0105183 <syscall+0x482>
	}
	else
		if((r=envid2env(envid,&e,0))<0)
f0105151:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0105158:	00 
f0105159:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010515c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105160:	89 3c 24             	mov    %edi,(%esp)
f0105163:	e8 dc df ff ff       	call   f0103144 <envid2env>
f0105168:	89 c3                	mov    %eax,%ebx
f010516a:	85 c0                	test   %eax,%eax
f010516c:	79 15                	jns    f0105183 <syscall+0x482>
		{
			cprintf("envid2env:id=%x\n",envid);
f010516e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105172:	c7 04 24 e0 bd 10 f0 	movl   $0xf010bde0,(%esp)
f0105179:	e8 69 e8 ff ff       	call   f01039e7 <cprintf>
f010517e:	e9 11 01 00 00       	jmp    f0105294 <syscall+0x593>
			return r;
		}
	if(!e->env_ipc_recving)
f0105183:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0105186:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f010518b:	83 7a 68 00          	cmpl   $0x0,0x68(%edx)
f010518f:	0f 84 ff 00 00 00    	je     f0105294 <syscall+0x593>
		return -E_IPC_NOT_RECV;
	if(srcva){//在一次成功ipc后，sender保持自己地址空间srcva处原来物理页面映射
f0105195:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
f0105199:	75 09                	jne    f01051a4 <syscall+0x4a3>
f010519b:	c7 45 18 00 00 00 00 	movl   $0x0,0x18(%ebp)
f01051a2:	eb 47                	jmp    f01051eb <syscall+0x4ea>
			break;
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1,(void*)a2);
			break;
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1,(uint32_t)a2,(void*)a3,(unsigned)a4);
f01051a4:	8b 75 14             	mov    0x14(%ebp),%esi
		return -E_IPC_NOT_RECV;
	if(srcva){//在一次成功ipc后，sender保持自己地址空间srcva处原来物理页面映射
		  //receiver将在自己地址空间dstva处获得同一物理页面映射
		  //sender和receiver共享同一页面
		srcaddr=(uint32_t)srcva;
		if(srcaddr<(uint32_t)UTOP){
f01051a7:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f01051ad:	8d 76 00             	lea    0x0(%esi),%esi
f01051b0:	77 39                	ja     f01051eb <syscall+0x4ea>
			if(srcaddr&0xfff)
f01051b2:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01051b7:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f01051bd:	0f 85 d1 00 00 00    	jne    f0105294 <syscall+0x593>
				return -E_INVAL;
			//cprintf("ipc send:some bugs in page mapping\n");
			//cprintf("srcid=%x srcva=%x\n",curenv->env_id,srcva);
			//cprintf("dstid=%x dstva=%x\n",envid,e->env_ipc_dstva);
			if((r=sys_page_map(curenv->env_id,srcva,envid,e->env_ipc_dstva,perm))<0)
f01051c3:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f01051c8:	8b 40 4c             	mov    0x4c(%eax),%eax
f01051cb:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01051ce:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01051d2:	8b 52 6c             	mov    0x6c(%edx),%edx
f01051d5:	89 14 24             	mov    %edx,(%esp)
f01051d8:	89 f9                	mov    %edi,%ecx
f01051da:	89 f2                	mov    %esi,%edx
f01051dc:	e8 0f fa ff ff       	call   f0104bf0 <sys_page_map>
f01051e1:	89 c3                	mov    %eax,%ebx
f01051e3:	85 c0                	test   %eax,%eax
f01051e5:	0f 88 a9 00 00 00    	js     f0105294 <syscall+0x593>
				return r;
			//cprintf("ipc send:no bugs in page mapping\n");
		}
	}
	else perm=0;
	e->env_ipc_from=curenv->env_id;
f01051eb:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f01051f0:	8b 50 4c             	mov    0x4c(%eax),%edx
f01051f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01051f6:	89 50 74             	mov    %edx,0x74(%eax)
	e->env_ipc_perm=perm;
f01051f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01051fc:	8b 55 18             	mov    0x18(%ebp),%edx
f01051ff:	89 50 78             	mov    %edx,0x78(%eax)
	e->env_ipc_value=value;
f0105202:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105205:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105208:	89 48 70             	mov    %ecx,0x70(%eax)
	e->env_ipc_recving=0;
f010520b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010520e:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)
	e->env_status=ENV_RUNNABLE;
f0105215:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105218:	c7 40 54 01 00 00 00 	movl   $0x1,0x54(%eax)
f010521f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105224:	eb 6e                	jmp    f0105294 <syscall+0x593>
			break;
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1,(uint32_t)a2,(void*)a3,(unsigned)a4);
			break;
		case SYS_ipc_recv:
			return sys_ipc_recv((void*)a1);
f0105226:	8b 55 0c             	mov    0xc(%ebp),%edx
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	uint32_t dstaddr;
	dstaddr=(uint32_t)dstva;
	if((dstaddr<(uint32_t)UTOP)&&(dstaddr&0xfff))
f0105229:	81 fa ff ff bf ee    	cmp    $0xeebfffff,%edx
f010522f:	77 08                	ja     f0105239 <syscall+0x538>
f0105231:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0105237:	75 56                	jne    f010528f <syscall+0x58e>
		return -E_INVAL;
	curenv->env_ipc_dstva=dstva;
f0105239:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f010523e:	89 50 6c             	mov    %edx,0x6c(%eax)
	curenv->env_ipc_recving=1;
f0105241:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f0105246:	c7 40 68 01 00 00 00 	movl   $0x1,0x68(%eax)
	curenv->env_tf.tf_regs.reg_eax=0;//设置返回值，jos都是利用evn_run从内核态返回用户态
f010524d:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f0105252:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	curenv->env_status=ENV_NOT_RUNNABLE;
f0105259:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f010525e:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	sched_yield();
f0105265:	e8 e6 f8 ff ff       	call   f0104b50 <sched_yield>
// Return the current time.
static int
sys_time_msec(void) 
{
	// LAB 6: Your code here.
	return time_msec();
f010526a:	e8 64 4e 00 00       	call   f010a0d3 <time_msec>
f010526f:	89 c3                	mov    %eax,%ebx
f0105271:	eb 21                	jmp    f0105294 <syscall+0x593>
			return sys_ipc_recv((void*)a1);
			break;
		case SYS_time_msec:
			return sys_time_msec();
		default:
			panic("syscall is not implemented");
f0105273:	c7 44 24 08 f1 bd 10 	movl   $0xf010bdf1,0x8(%esp)
f010527a:	f0 
f010527b:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
f0105282:	00 
f0105283:	c7 04 24 b9 bd 10 f0 	movl   $0xf010bdb9,(%esp)
f010528a:	e8 f7 ad ff ff       	call   f0100086 <_panic>
f010528f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	}
	return 0;
	//panic("syscall not implemented");
}
f0105294:	89 d8                	mov    %ebx,%eax
f0105296:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0105299:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010529c:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010529f:	89 ec                	mov    %ebp,%esp
f01052a1:	5d                   	pop    %ebp
f01052a2:	c3                   	ret    
	...

f01052b0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01052b0:	55                   	push   %ebp
f01052b1:	89 e5                	mov    %esp,%ebp
f01052b3:	57                   	push   %edi
f01052b4:	56                   	push   %esi
f01052b5:	53                   	push   %ebx
f01052b6:	83 ec 14             	sub    $0x14,%esp
f01052b9:	89 45 e8             	mov    %eax,-0x18(%ebp)
f01052bc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01052bf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01052c2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01052c5:	8b 1a                	mov    (%edx),%ebx
f01052c7:	8b 01                	mov    (%ecx),%eax
f01052c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f01052cc:	39 c3                	cmp    %eax,%ebx
f01052ce:	0f 8f aa 00 00 00    	jg     f010537e <stab_binsearch+0xce>
f01052d4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f01052db:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01052de:	01 da                	add    %ebx,%edx
f01052e0:	89 d0                	mov    %edx,%eax
f01052e2:	c1 e8 1f             	shr    $0x1f,%eax
f01052e5:	01 d0                	add    %edx,%eax
f01052e7:	89 c6                	mov    %eax,%esi
f01052e9:	d1 fe                	sar    %esi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01052eb:	39 de                	cmp    %ebx,%esi
f01052ed:	7c 2e                	jl     f010531d <stab_binsearch+0x6d>
f01052ef:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01052f2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01052f9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01052fc:	0f b6 44 0a 04       	movzbl 0x4(%edx,%ecx,1),%eax
f0105301:	39 f8                	cmp    %edi,%eax
f0105303:	74 1d                	je     f0105322 <stab_binsearch+0x72>
f0105305:	01 ca                	add    %ecx,%edx
f0105307:	89 f1                	mov    %esi,%ecx
			m--;
f0105309:	83 e9 01             	sub    $0x1,%ecx
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010530c:	39 d9                	cmp    %ebx,%ecx
f010530e:	7c 0d                	jl     f010531d <stab_binsearch+0x6d>
f0105310:	0f b6 42 f8          	movzbl -0x8(%edx),%eax
f0105314:	83 ea 0c             	sub    $0xc,%edx
f0105317:	39 f8                	cmp    %edi,%eax
f0105319:	74 09                	je     f0105324 <stab_binsearch+0x74>
f010531b:	eb ec                	jmp    f0105309 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010531d:	8d 5e 01             	lea    0x1(%esi),%ebx
f0105320:	eb 4d                	jmp    f010536f <stab_binsearch+0xbf>
			continue;
f0105322:	89 f1                	mov    %esi,%ecx
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105324:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0105327:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010532a:	8b 44 82 08          	mov    0x8(%edx,%eax,4),%eax
f010532e:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0105331:	73 11                	jae    f0105344 <stab_binsearch+0x94>
			*region_left = m;
f0105333:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105336:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
f0105338:	8d 5e 01             	lea    0x1(%esi),%ebx
f010533b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
f0105342:	eb 2b                	jmp    f010536f <stab_binsearch+0xbf>
		} else if (stabs[m].n_value > addr) {
f0105344:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0105347:	76 14                	jbe    f010535d <stab_binsearch+0xad>
			*region_right = m - 1;
f0105349:	83 e9 01             	sub    $0x1,%ecx
f010534c:	89 4d ec             	mov    %ecx,-0x14(%ebp)
f010534f:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105352:	89 0a                	mov    %ecx,(%edx)
f0105354:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
f010535b:	eb 12                	jmp    f010536f <stab_binsearch+0xbf>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010535d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105360:	89 0e                	mov    %ecx,(%esi)
			l = m;
			addr++;
f0105362:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0105366:	89 cb                	mov    %ecx,%ebx
f0105368:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f010536f:	3b 5d ec             	cmp    -0x14(%ebp),%ebx
f0105372:	0f 8e 63 ff ff ff    	jle    f01052db <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105378:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010537c:	75 0f                	jne    f010538d <stab_binsearch+0xdd>
		*region_right = *region_left - 1;
f010537e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105381:	8b 02                	mov    (%edx),%eax
f0105383:	83 e8 01             	sub    $0x1,%eax
f0105386:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105389:	89 01                	mov    %eax,(%ecx)
f010538b:	eb 3d                	jmp    f01053ca <stab_binsearch+0x11a>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010538d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105390:	8b 0e                	mov    (%esi),%ecx
		     l > *region_left && stabs[l].n_type != type;
f0105392:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105395:	8b 18                	mov    (%eax),%ebx
f0105397:	39 d9                	cmp    %ebx,%ecx
f0105399:	7e 2a                	jle    f01053c5 <stab_binsearch+0x115>
f010539b:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f010539e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01053a5:	8b 75 e8             	mov    -0x18(%ebp),%esi
f01053a8:	0f b6 44 32 04       	movzbl 0x4(%edx,%esi,1),%eax
f01053ad:	39 f8                	cmp    %edi,%eax
f01053af:	74 14                	je     f01053c5 <stab_binsearch+0x115>
f01053b1:	01 f2                	add    %esi,%edx
		     l--)
f01053b3:	83 e9 01             	sub    $0x1,%ecx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f01053b6:	39 d9                	cmp    %ebx,%ecx
f01053b8:	7e 0b                	jle    f01053c5 <stab_binsearch+0x115>
f01053ba:	0f b6 42 f8          	movzbl -0x8(%edx),%eax
f01053be:	83 ea 0c             	sub    $0xc,%edx
f01053c1:	39 f8                	cmp    %edi,%eax
f01053c3:	75 ee                	jne    f01053b3 <stab_binsearch+0x103>
		     l--)
			/* do nothing */;
		*region_left = l;
f01053c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01053c8:	89 08                	mov    %ecx,(%eax)
	}
}
f01053ca:	83 c4 14             	add    $0x14,%esp
f01053cd:	5b                   	pop    %ebx
f01053ce:	5e                   	pop    %esi
f01053cf:	5f                   	pop    %edi
f01053d0:	5d                   	pop    %ebp
f01053d1:	c3                   	ret    

f01053d2 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01053d2:	55                   	push   %ebp
f01053d3:	89 e5                	mov    %esp,%ebp
f01053d5:	83 ec 48             	sub    $0x48,%esp
f01053d8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01053db:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01053de:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01053e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01053e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01053e7:	c7 06 48 be 10 f0    	movl   $0xf010be48,(%esi)
	info->eip_line = 0;
f01053ed:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f01053f4:	c7 46 08 48 be 10 f0 	movl   $0xf010be48,0x8(%esi)
	info->eip_fn_namelen = 9;
f01053fb:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0105402:	89 5e 10             	mov    %ebx,0x10(%esi)
	info->eip_fn_narg = 0;
f0105405:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010540c:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0105412:	76 1f                	jbe    f0105433 <debuginfo_eip+0x61>
f0105414:	c7 45 c8 c0 49 11 f0 	movl   $0xf01149c0,-0x38(%ebp)
f010541b:	bf 54 30 12 f0       	mov    $0xf0123054,%edi
f0105420:	c7 45 cc 55 30 12 f0 	movl   $0xf0123055,-0x34(%ebp)
f0105427:	c7 45 d0 11 86 12 f0 	movl   $0xf0128611,-0x30(%ebp)
f010542e:	e9 99 00 00 00       	jmp    f01054cc <debuginfo_eip+0xfa>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		user_mem_check(curenv,(void*)usd,sizeof(struct UserStabData),0);
f0105433:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010543a:	00 
f010543b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0105442:	00 
f0105443:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f010544a:	00 
f010544b:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f0105450:	89 04 24             	mov    %eax,(%esp)
f0105453:	e8 48 c0 ff ff       	call   f01014a0 <user_mem_check>
		stabs = usd->stabs;
f0105458:	a1 00 00 20 00       	mov    0x200000,%eax
f010545d:	89 45 c8             	mov    %eax,-0x38(%ebp)
		stab_end = usd->stab_end;
f0105460:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0105466:	8b 15 08 00 20 00    	mov    0x200008,%edx
f010546c:	89 55 cc             	mov    %edx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f010546f:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f0105475:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		user_mem_check(curenv,(void*)stabs,stab_end-stabs,0);
f0105478:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010547f:	00 
f0105480:	89 f8                	mov    %edi,%eax
f0105482:	2b 45 c8             	sub    -0x38(%ebp),%eax
f0105485:	c1 f8 02             	sar    $0x2,%eax
f0105488:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010548e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105492:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0105495:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105499:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f010549e:	89 04 24             	mov    %eax,(%esp)
f01054a1:	e8 fa bf ff ff       	call   f01014a0 <user_mem_check>
		user_mem_check(curenv,(void*)stabstr,stabstr_end-stabstr,0);
f01054a6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01054ad:	00 
f01054ae:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01054b1:	2b 45 cc             	sub    -0x34(%ebp),%eax
f01054b4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01054b8:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01054bb:	89 54 24 04          	mov    %edx,0x4(%esp)
f01054bf:	a1 44 45 29 f0       	mov    0xf0294544,%eax
f01054c4:	89 04 24             	mov    %eax,(%esp)
f01054c7:	e8 d4 bf ff ff       	call   f01014a0 <user_mem_check>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01054cc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01054cf:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f01054d2:	0f 83 aa 01 00 00    	jae    f0105682 <debuginfo_eip+0x2b0>
f01054d8:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f01054dc:	0f 85 a0 01 00 00    	jne    f0105682 <debuginfo_eip+0x2b0>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01054e2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	rfile = (stab_end - stabs) - 1;
f01054e9:	89 f8                	mov    %edi,%eax
f01054eb:	2b 45 c8             	sub    -0x38(%ebp),%eax
f01054ee:	c1 f8 02             	sar    $0x2,%eax
f01054f1:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01054f7:	83 e8 01             	sub    $0x1,%eax
f01054fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01054fd:	8d 4d ec             	lea    -0x14(%ebp),%ecx
f0105500:	8d 55 f0             	lea    -0x10(%ebp),%edx
f0105503:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105507:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f010550e:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0105511:	e8 9a fd ff ff       	call   f01052b0 <stab_binsearch>
	if (lfile == 0)
f0105516:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105519:	85 c0                	test   %eax,%eax
f010551b:	0f 84 61 01 00 00    	je     f0105682 <debuginfo_eip+0x2b0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105521:	89 45 e8             	mov    %eax,-0x18(%ebp)
	rfun = rfile;
f0105524:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105527:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010552a:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
f010552d:	8d 55 e8             	lea    -0x18(%ebp),%edx
f0105530:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105534:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f010553b:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010553e:	e8 6d fd ff ff       	call   f01052b0 <stab_binsearch>

	if (lfun <= rfun) {
f0105543:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0105546:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
f0105549:	7f 39                	jg     f0105584 <debuginfo_eip+0x1b2>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010554b:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010554e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0105551:	8b 14 81             	mov    (%ecx,%eax,4),%edx
f0105554:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105557:	2b 45 cc             	sub    -0x34(%ebp),%eax
f010555a:	39 c2                	cmp    %eax,%edx
f010555c:	73 09                	jae    f0105567 <debuginfo_eip+0x195>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010555e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0105561:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
f0105564:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105567:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010556a:	8d 04 52             	lea    (%edx,%edx,2),%eax
f010556d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0105570:	8b 44 81 08          	mov    0x8(%ecx,%eax,4),%eax
f0105574:	89 46 10             	mov    %eax,0x10(%esi)
		addr -= info->eip_fn_addr;
f0105577:	29 c3                	sub    %eax,%ebx
		// Search within the function definition for the line number.
		lline = lfun;
f0105579:	89 55 e0             	mov    %edx,-0x20(%ebp)
		rline = rfun;
f010557c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010557f:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105582:	eb 0f                	jmp    f0105593 <debuginfo_eip+0x1c1>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105584:	89 5e 10             	mov    %ebx,0x10(%esi)
		lline = lfile;
f0105587:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010558a:	89 45 e0             	mov    %eax,-0x20(%ebp)
		rline = rfile;
f010558d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105590:	89 45 dc             	mov    %eax,-0x24(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105593:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f010559a:	00 
f010559b:	8b 46 08             	mov    0x8(%esi),%eax
f010559e:	89 04 24             	mov    %eax,(%esp)
f01055a1:	e8 0d 41 00 00       	call   f01096b3 <strfind>
f01055a6:	2b 46 08             	sub    0x8(%esi),%eax
f01055a9:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs,&lline,&rline,N_SLINE,addr);
f01055ac:	8d 4d dc             	lea    -0x24(%ebp),%ecx
f01055af:	8d 55 e0             	lea    -0x20(%ebp),%edx
f01055b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01055b6:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01055bd:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01055c0:	e8 eb fc ff ff       	call   f01052b0 <stab_binsearch>
	if(lline==0)
f01055c5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01055c8:	85 d2                	test   %edx,%edx
f01055ca:	0f 84 b2 00 00 00    	je     f0105682 <debuginfo_eip+0x2b0>
		return -1;
	info->eip_line=stabs[lline].n_desc;
f01055d0:	8d 04 52             	lea    (%edx,%edx,2),%eax
f01055d3:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
f01055da:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01055dd:	0f b7 44 0b 06       	movzwl 0x6(%ebx,%ecx,1),%eax
f01055e2:	89 46 04             	mov    %eax,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01055e5:	89 d1                	mov    %edx,%ecx
f01055e7:	8b 7d f0             	mov    -0x10(%ebp),%edi
f01055ea:	39 d7                	cmp    %edx,%edi
f01055ec:	7f 52                	jg     f0105640 <debuginfo_eip+0x26e>
f01055ee:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01055f1:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f01055f4:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f01055f8:	8d 58 f4             	lea    -0xc(%eax),%ebx
f01055fb:	80 fa 84             	cmp    $0x84,%dl
f01055fe:	75 1a                	jne    f010561a <debuginfo_eip+0x248>
f0105600:	eb 23                	jmp    f0105625 <debuginfo_eip+0x253>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0105602:	83 e9 01             	sub    $0x1,%ecx
f0105605:	89 4d e0             	mov    %ecx,-0x20(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105608:	39 cf                	cmp    %ecx,%edi
f010560a:	7f 34                	jg     f0105640 <debuginfo_eip+0x26e>
f010560c:	89 d8                	mov    %ebx,%eax
f010560e:	0f b6 53 04          	movzbl 0x4(%ebx),%edx
f0105612:	8d 5b f4             	lea    -0xc(%ebx),%ebx
f0105615:	80 fa 84             	cmp    $0x84,%dl
f0105618:	74 0b                	je     f0105625 <debuginfo_eip+0x253>
f010561a:	80 fa 64             	cmp    $0x64,%dl
f010561d:	75 e3                	jne    f0105602 <debuginfo_eip+0x230>
f010561f:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0105623:	74 dd                	je     f0105602 <debuginfo_eip+0x230>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105625:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0105628:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010562b:	8b 14 81             	mov    (%ecx,%eax,4),%edx
f010562e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105631:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0105634:	39 c2                	cmp    %eax,%edx
f0105636:	73 08                	jae    f0105640 <debuginfo_eip+0x26e>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105638:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010563b:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
f010563e:	89 06                	mov    %eax,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105640:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0105643:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105646:	39 d0                	cmp    %edx,%eax
f0105648:	7d 3f                	jge    f0105689 <debuginfo_eip+0x2b7>
		for (lline = lfun + 1;
f010564a:	83 c0 01             	add    $0x1,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010564d:	39 c2                	cmp    %eax,%edx
f010564f:	7e 38                	jle    f0105689 <debuginfo_eip+0x2b7>


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105651:	89 45 e0             	mov    %eax,-0x20(%ebp)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105654:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105657:	8b 55 c8             	mov    -0x38(%ebp),%edx
f010565a:	80 7c 82 04 a0       	cmpb   $0xa0,0x4(%edx,%eax,4)
f010565f:	75 28                	jne    f0105689 <debuginfo_eip+0x2b7>
		     lline++)
			info->eip_fn_narg++;
f0105661:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0105665:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105668:	83 c0 01             	add    $0x1,%eax

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010566b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f010566e:	7e 19                	jle    f0105689 <debuginfo_eip+0x2b7>
		     lline++)
f0105670:	89 45 e0             	mov    %eax,-0x20(%ebp)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105673:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105676:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0105679:	80 7c 81 04 a0       	cmpb   $0xa0,0x4(%ecx,%eax,4)
f010567e:	75 09                	jne    f0105689 <debuginfo_eip+0x2b7>
f0105680:	eb df                	jmp    f0105661 <debuginfo_eip+0x28f>
f0105682:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105687:	eb 05                	jmp    f010568e <debuginfo_eip+0x2bc>
f0105689:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
}
f010568e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0105691:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0105694:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0105697:	89 ec                	mov    %ebp,%esp
f0105699:	5d                   	pop    %ebp
f010569a:	c3                   	ret    
f010569b:	00 00                	add    %al,(%eax)
f010569d:	00 00                	add    %al,(%eax)
	...

f01056a0 <fetch_data>:

static int
fetch_data (info, addr)
     struct disassemble_info *info;
     bfd_byte *addr;
{
f01056a0:	55                   	push   %ebp
f01056a1:	89 e5                	mov    %esp,%ebp
f01056a3:	83 ec 38             	sub    $0x38,%esp
f01056a6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01056a9:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01056ac:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01056af:	89 c6                	mov    %eax,%esi
f01056b1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  int status;
  struct dis_private *priv = (struct dis_private *) info->private_data;
f01056b4:	8b 58 20             	mov    0x20(%eax),%ebx
  bfd_vma start_vma = priv->insn_start + (priv->max_fetched - priv->the_buffer);
f01056b7:	8b 03                	mov    (%ebx),%eax
f01056b9:	8d 7b 04             	lea    0x4(%ebx),%edi
f01056bc:	89 c2                	mov    %eax,%edx
f01056be:	29 fa                	sub    %edi,%edx
f01056c0:	89 d1                	mov    %edx,%ecx
f01056c2:	c1 f9 1f             	sar    $0x1f,%ecx
f01056c5:	03 53 18             	add    0x18(%ebx),%edx
f01056c8:	13 4b 1c             	adc    0x1c(%ebx),%ecx
f01056cb:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01056ce:	89 4d ec             	mov    %ecx,-0x14(%ebp)
 //cprintf("fetch_data:info=%x max_fetched=%x length=%d\n",info,priv->max_fetched,addr-priv->max_fetched);
  status = (*info->read_memory_func)(start_vma,priv->max_fetched,addr-priv->max_fetched,info);
f01056d1:	89 74 24 10          	mov    %esi,0x10(%esp)
f01056d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01056d8:	29 c2                	sub    %eax,%edx
f01056da:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01056de:	89 44 24 08          	mov    %eax,0x8(%esp)
f01056e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01056e5:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01056e8:	89 04 24             	mov    %eax,(%esp)
f01056eb:	89 54 24 04          	mov    %edx,0x4(%esp)
f01056ef:	ff 56 24             	call   *0x24(%esi)
  if (status != 0)
f01056f2:	85 c0                	test   %eax,%eax
f01056f4:	74 1e                	je     f0105714 <fetch_data+0x74>
    {
      /* If we did manage to read at least one byte, then
         print_insn_i386 will do something sensible.  Otherwise, print
         an error.  We do that here because this is where we know
         STATUS.  */
      if (priv->max_fetched == priv->the_buffer)
f01056f6:	39 3b                	cmp    %edi,(%ebx)
f01056f8:	75 1f                	jne    f0105719 <fetch_data+0x79>
	(*info->memory_error_func) (status, start_vma, info);
f01056fa:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01056fe:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105701:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105704:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105708:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010570c:	89 04 24             	mov    %eax,(%esp)
f010570f:	ff 56 28             	call   *0x28(%esi)
f0105712:	eb 05                	jmp    f0105719 <fetch_data+0x79>
      //longjmp (priv->bailout, 1);
    }
  else
    priv->max_fetched = addr;
f0105714:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105717:	89 0b                	mov    %ecx,(%ebx)
  return 1;
}
f0105719:	b8 01 00 00 00       	mov    $0x1,%eax
f010571e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0105721:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0105724:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0105727:	89 ec                	mov    %ebp,%esp
f0105729:	5d                   	pop    %ebp
f010572a:	c3                   	ret    

f010572b <prefix_name>:

static const char *
prefix_name (pref, sizeflag)
     int pref;
     int sizeflag;
{
f010572b:	55                   	push   %ebp
f010572c:	89 e5                	mov    %esp,%ebp
  switch (pref)
f010572e:	83 e8 26             	sub    $0x26,%eax
f0105731:	3d cd 00 00 00       	cmp    $0xcd,%eax
f0105736:	77 11                	ja     f0105749 <prefix_name+0x1e>
f0105738:	ff 24 85 60 d1 10 f0 	jmp    *-0xfef2ea0(,%eax,4)
f010573f:	b8 52 be 10 f0       	mov    $0xf010be52,%eax
f0105744:	e9 22 01 00 00       	jmp    f010586b <prefix_name+0x140>
f0105749:	b8 00 00 00 00       	mov    $0x0,%eax
f010574e:	66 90                	xchg   %ax,%ax
f0105750:	e9 16 01 00 00       	jmp    f010586b <prefix_name+0x140>
f0105755:	b8 58 be 10 f0       	mov    $0xf010be58,%eax
f010575a:	e9 0c 01 00 00       	jmp    f010586b <prefix_name+0x140>
    {
    /* REX prefixes family.  */
    case 0x40:
      return "rex";
f010575f:	b8 5c be 10 f0       	mov    $0xf010be5c,%eax
f0105764:	e9 02 01 00 00       	jmp    f010586b <prefix_name+0x140>
    case 0x41:
      return "rexZ";
f0105769:	b8 61 be 10 f0       	mov    $0xf010be61,%eax
f010576e:	e9 f8 00 00 00       	jmp    f010586b <prefix_name+0x140>
    case 0x42:
      return "rexY";
f0105773:	b8 66 be 10 f0       	mov    $0xf010be66,%eax
f0105778:	e9 ee 00 00 00       	jmp    f010586b <prefix_name+0x140>
    case 0x43:
      return "rexYZ";
f010577d:	b8 6c be 10 f0       	mov    $0xf010be6c,%eax
f0105782:	e9 e4 00 00 00       	jmp    f010586b <prefix_name+0x140>
    case 0x44:
      return "rexX";
f0105787:	b8 71 be 10 f0       	mov    $0xf010be71,%eax
f010578c:	e9 da 00 00 00       	jmp    f010586b <prefix_name+0x140>
    case 0x45:
      return "rexXZ";
f0105791:	b8 77 be 10 f0       	mov    $0xf010be77,%eax
f0105796:	e9 d0 00 00 00       	jmp    f010586b <prefix_name+0x140>
    case 0x46:
      return "rexXY";
f010579b:	b8 7d be 10 f0       	mov    $0xf010be7d,%eax
f01057a0:	e9 c6 00 00 00       	jmp    f010586b <prefix_name+0x140>
    case 0x47:
      return "rexXYZ";
f01057a5:	b8 84 be 10 f0       	mov    $0xf010be84,%eax
f01057aa:	e9 bc 00 00 00       	jmp    f010586b <prefix_name+0x140>
    case 0x48:
      return "rex64";
f01057af:	b8 8a be 10 f0       	mov    $0xf010be8a,%eax
f01057b4:	e9 b2 00 00 00       	jmp    f010586b <prefix_name+0x140>
    case 0x49:
      return "rex64Z";
f01057b9:	b8 91 be 10 f0       	mov    $0xf010be91,%eax
f01057be:	e9 a8 00 00 00       	jmp    f010586b <prefix_name+0x140>
    case 0x4a:
      return "rex64Y";
f01057c3:	b8 98 be 10 f0       	mov    $0xf010be98,%eax
f01057c8:	e9 9e 00 00 00       	jmp    f010586b <prefix_name+0x140>
    case 0x4b:
      return "rex64YZ";
f01057cd:	b8 a0 be 10 f0       	mov    $0xf010bea0,%eax
f01057d2:	e9 94 00 00 00       	jmp    f010586b <prefix_name+0x140>
    case 0x4c:
      return "rex64X";
f01057d7:	b8 a7 be 10 f0       	mov    $0xf010bea7,%eax
f01057dc:	e9 8a 00 00 00       	jmp    f010586b <prefix_name+0x140>
    case 0x4d:
      return "rex64XZ";
f01057e1:	b8 af be 10 f0       	mov    $0xf010beaf,%eax
f01057e6:	e9 80 00 00 00       	jmp    f010586b <prefix_name+0x140>
    case 0x4e:
      return "rex64XY";
f01057eb:	b8 b7 be 10 f0       	mov    $0xf010beb7,%eax
f01057f0:	eb 79                	jmp    f010586b <prefix_name+0x140>
    case 0x4f:
      return "rex64XYZ";
f01057f2:	b8 c0 be 10 f0       	mov    $0xf010bec0,%eax
f01057f7:	eb 72                	jmp    f010586b <prefix_name+0x140>
    case 0xf3:
      return "repz";
f01057f9:	b8 c5 be 10 f0       	mov    $0xf010bec5,%eax
f01057fe:	eb 6b                	jmp    f010586b <prefix_name+0x140>
    case 0xf2:
      return "repnz";
f0105800:	b8 cb be 10 f0       	mov    $0xf010becb,%eax
f0105805:	eb 64                	jmp    f010586b <prefix_name+0x140>
    case 0xf0:
      return "lock";
f0105807:	b8 06 c2 10 f0       	mov    $0xf010c206,%eax
f010580c:	eb 5d                	jmp    f010586b <prefix_name+0x140>
    case 0x2e:
      return "cs";
f010580e:	b8 0a c2 10 f0       	mov    $0xf010c20a,%eax
f0105813:	eb 56                	jmp    f010586b <prefix_name+0x140>
    case 0x36:
      return "ss";
f0105815:	b8 0e c2 10 f0       	mov    $0xf010c20e,%eax
f010581a:	eb 4f                	jmp    f010586b <prefix_name+0x140>
    case 0x3e:
      return "ds";
f010581c:	b8 02 c2 10 f0       	mov    $0xf010c202,%eax
f0105821:	eb 48                	jmp    f010586b <prefix_name+0x140>
    case 0x26:
      return "es";
f0105823:	b8 12 c2 10 f0       	mov    $0xf010c212,%eax
f0105828:	eb 41                	jmp    f010586b <prefix_name+0x140>
    case 0x64:
      return "fs";
f010582a:	b8 16 c2 10 f0       	mov    $0xf010c216,%eax
f010582f:	eb 3a                	jmp    f010586b <prefix_name+0x140>
    case 0x65:
      return "gs";
    case 0x66:
      return (sizeflag & DFLAG) ? "data16" : "data32";
f0105831:	b8 d0 be 10 f0       	mov    $0xf010bed0,%eax
f0105836:	f6 c2 01             	test   $0x1,%dl
f0105839:	75 30                	jne    f010586b <prefix_name+0x140>
f010583b:	b8 d7 be 10 f0       	mov    $0xf010bed7,%eax
f0105840:	eb 29                	jmp    f010586b <prefix_name+0x140>
    case 0x67:
      if (mode_64bit)
f0105842:	83 3d e0 4d 29 f0 00 	cmpl   $0x0,0xf0294de0
f0105849:	74 11                	je     f010585c <prefix_name+0x131>
        return (sizeflag & AFLAG) ? "addr32" : "addr64";
f010584b:	b8 de be 10 f0       	mov    $0xf010bede,%eax
f0105850:	f6 c2 02             	test   $0x2,%dl
f0105853:	75 16                	jne    f010586b <prefix_name+0x140>
f0105855:	b8 e5 be 10 f0       	mov    $0xf010bee5,%eax
f010585a:	eb 0f                	jmp    f010586b <prefix_name+0x140>
      else
        return ((sizeflag & AFLAG) && !mode_64bit) ? "addr16" : "addr32";
f010585c:	b8 ec be 10 f0       	mov    $0xf010beec,%eax
f0105861:	f6 c2 02             	test   $0x2,%dl
f0105864:	75 05                	jne    f010586b <prefix_name+0x140>
f0105866:	b8 de be 10 f0       	mov    $0xf010bede,%eax
    case FWAIT_OPCODE:
      return "fwait";
    default:
      return NULL;
    }
}
f010586b:	5d                   	pop    %ebp
f010586c:	c3                   	ret    

f010586d <get64>:
    }
}

static bfd_vma
get64 ()
{
f010586d:	55                   	push   %ebp
f010586e:	89 e5                	mov    %esp,%ebp
f0105870:	83 ec 18             	sub    $0x18,%esp
f0105873:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0105876:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0105879:	89 7d fc             	mov    %edi,-0x4(%ebp)
  bfd_vma x;
#ifdef BFD64
  unsigned int a;
  unsigned int b;

  FETCH_DATA (the_info, codep + 8);
f010587c:	8b 15 ec 4e 29 f0    	mov    0xf0294eec,%edx
f0105882:	83 c2 08             	add    $0x8,%edx
f0105885:	8b 0d f0 4e 29 f0    	mov    0xf0294ef0,%ecx
f010588b:	8b 41 20             	mov    0x20(%ecx),%eax
f010588e:	3b 10                	cmp    (%eax),%edx
f0105890:	76 07                	jbe    f0105899 <get64+0x2c>
f0105892:	89 c8                	mov    %ecx,%eax
f0105894:	e8 07 fe ff ff       	call   f01056a0 <fetch_data>
  a = *codep++ & 0xff;
f0105899:	8b 3d ec 4e 29 f0    	mov    0xf0294eec,%edi
f010589f:	0f b6 07             	movzbl (%edi),%eax
  a |= (*codep++ & 0xff) << 8;
f01058a2:	0f b6 5f 01          	movzbl 0x1(%edi),%ebx
f01058a6:	c1 e3 08             	shl    $0x8,%ebx
f01058a9:	09 c3                	or     %eax,%ebx
  a |= (*codep++ & 0xff) << 16;
f01058ab:	0f b6 47 02          	movzbl 0x2(%edi),%eax
f01058af:	c1 e0 10             	shl    $0x10,%eax
f01058b2:	09 c3                	or     %eax,%ebx
  a |= (*codep++ & 0xff) << 24;
f01058b4:	0f b6 47 03          	movzbl 0x3(%edi),%eax
f01058b8:	c1 e0 18             	shl    $0x18,%eax
f01058bb:	09 c3                	or     %eax,%ebx
  b = *codep++ & 0xff;
f01058bd:	0f b6 4f 04          	movzbl 0x4(%edi),%ecx
  b |= (*codep++ & 0xff) << 8;
f01058c1:	0f b6 47 05          	movzbl 0x5(%edi),%eax
f01058c5:	c1 e0 08             	shl    $0x8,%eax
f01058c8:	09 c8                	or     %ecx,%eax
  b |= (*codep++ & 0xff) << 16;
f01058ca:	0f b6 4f 06          	movzbl 0x6(%edi),%ecx
f01058ce:	c1 e1 10             	shl    $0x10,%ecx
f01058d1:	09 c8                	or     %ecx,%eax
  b |= (*codep++ & 0xff) << 24;
f01058d3:	0f b6 4f 07          	movzbl 0x7(%edi),%ecx
f01058d7:	c1 e1 18             	shl    $0x18,%ecx
f01058da:	09 c8                	or     %ecx,%eax
f01058dc:	83 c7 08             	add    $0x8,%edi
f01058df:	89 3d ec 4e 29 f0    	mov    %edi,0xf0294eec
f01058e5:	89 c2                	mov    %eax,%edx
f01058e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01058ec:	be 00 00 00 00       	mov    $0x0,%esi
f01058f1:	01 d8                	add    %ebx,%eax
f01058f3:	11 f2                	adc    %esi,%edx
  abort ();
   panic("get64:erron occured");
  x = 0;
#endif
  return x;
}
f01058f5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01058f8:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01058fb:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01058fe:	89 ec                	mov    %ebp,%esp
f0105900:	5d                   	pop    %ebp
f0105901:	c3                   	ret    

f0105902 <get32>:

static bfd_signed_vma
get32 ()
{
f0105902:	55                   	push   %ebp
f0105903:	89 e5                	mov    %esp,%ebp
f0105905:	56                   	push   %esi
f0105906:	53                   	push   %ebx
  bfd_signed_vma x = 0;

  FETCH_DATA (the_info, codep + 4);
f0105907:	8b 15 ec 4e 29 f0    	mov    0xf0294eec,%edx
f010590d:	83 c2 04             	add    $0x4,%edx
f0105910:	8b 0d f0 4e 29 f0    	mov    0xf0294ef0,%ecx
f0105916:	8b 41 20             	mov    0x20(%ecx),%eax
f0105919:	3b 10                	cmp    (%eax),%edx
f010591b:	76 07                	jbe    f0105924 <get32+0x22>
f010591d:	89 c8                	mov    %ecx,%eax
f010591f:	e8 7c fd ff ff       	call   f01056a0 <fetch_data>
  x = *codep++ & (bfd_signed_vma) 0xff;
f0105924:	8b 35 ec 4e 29 f0    	mov    0xf0294eec,%esi
f010592a:	0f b6 0e             	movzbl (%esi),%ecx
f010592d:	bb 00 00 00 00       	mov    $0x0,%ebx
  x |= (*codep++ & (bfd_signed_vma) 0xff) << 8;
f0105932:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0105936:	ba 00 00 00 00       	mov    $0x0,%edx
f010593b:	0f a4 c2 08          	shld   $0x8,%eax,%edx
f010593f:	c1 e0 08             	shl    $0x8,%eax
f0105942:	09 c8                	or     %ecx,%eax
f0105944:	09 da                	or     %ebx,%edx
  x |= (*codep++ & (bfd_signed_vma) 0xff) << 16;
f0105946:	0f b6 4e 02          	movzbl 0x2(%esi),%ecx
f010594a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010594f:	0f a4 cb 10          	shld   $0x10,%ecx,%ebx
f0105953:	c1 e1 10             	shl    $0x10,%ecx
f0105956:	09 c8                	or     %ecx,%eax
f0105958:	09 da                	or     %ebx,%edx
  x |= (*codep++ & (bfd_signed_vma) 0xff) << 24;
f010595a:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
f010595e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105963:	0f a4 cb 18          	shld   $0x18,%ecx,%ebx
f0105967:	c1 e1 18             	shl    $0x18,%ecx
f010596a:	09 c8                	or     %ecx,%eax
f010596c:	09 da                	or     %ebx,%edx
f010596e:	83 c6 04             	add    $0x4,%esi
f0105971:	89 35 ec 4e 29 f0    	mov    %esi,0xf0294eec
  return x;
}
f0105977:	5b                   	pop    %ebx
f0105978:	5e                   	pop    %esi
f0105979:	5d                   	pop    %ebp
f010597a:	c3                   	ret    

f010597b <get32s>:

static bfd_signed_vma
get32s ()
{
f010597b:	55                   	push   %ebp
f010597c:	89 e5                	mov    %esp,%ebp
f010597e:	56                   	push   %esi
f010597f:	53                   	push   %ebx
  bfd_signed_vma x = 0;

  FETCH_DATA (the_info, codep + 4);
f0105980:	8b 15 ec 4e 29 f0    	mov    0xf0294eec,%edx
f0105986:	83 c2 04             	add    $0x4,%edx
f0105989:	8b 0d f0 4e 29 f0    	mov    0xf0294ef0,%ecx
f010598f:	8b 41 20             	mov    0x20(%ecx),%eax
f0105992:	3b 10                	cmp    (%eax),%edx
f0105994:	76 07                	jbe    f010599d <get32s+0x22>
f0105996:	89 c8                	mov    %ecx,%eax
f0105998:	e8 03 fd ff ff       	call   f01056a0 <fetch_data>
  x = *codep++ & (bfd_signed_vma) 0xff;
f010599d:	8b 35 ec 4e 29 f0    	mov    0xf0294eec,%esi
f01059a3:	0f b6 0e             	movzbl (%esi),%ecx
f01059a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  x |= (*codep++ & (bfd_signed_vma) 0xff) << 8;
f01059ab:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f01059af:	ba 00 00 00 00       	mov    $0x0,%edx
f01059b4:	0f a4 c2 08          	shld   $0x8,%eax,%edx
f01059b8:	c1 e0 08             	shl    $0x8,%eax
f01059bb:	09 c8                	or     %ecx,%eax
f01059bd:	09 da                	or     %ebx,%edx
  x |= (*codep++ & (bfd_signed_vma) 0xff) << 16;
f01059bf:	0f b6 4e 02          	movzbl 0x2(%esi),%ecx
f01059c3:	bb 00 00 00 00       	mov    $0x0,%ebx
f01059c8:	0f a4 cb 10          	shld   $0x10,%ecx,%ebx
f01059cc:	c1 e1 10             	shl    $0x10,%ecx
f01059cf:	09 c8                	or     %ecx,%eax
f01059d1:	09 da                	or     %ebx,%edx
  x |= (*codep++ & (bfd_signed_vma) 0xff) << 24;
f01059d3:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
f01059d7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01059dc:	0f a4 cb 18          	shld   $0x18,%ecx,%ebx
f01059e0:	c1 e1 18             	shl    $0x18,%ecx
f01059e3:	09 c8                	or     %ecx,%eax
f01059e5:	09 da                	or     %ebx,%edx
f01059e7:	83 c6 04             	add    $0x4,%esi
f01059ea:	89 35 ec 4e 29 f0    	mov    %esi,0xf0294eec

  x = (x ^ ((bfd_signed_vma) 1 << 31)) - ((bfd_signed_vma) 1 << 31);
f01059f0:	2d 00 00 00 80       	sub    $0x80000000,%eax
f01059f5:	05 00 00 00 80       	add    $0x80000000,%eax
f01059fa:	83 d2 ff             	adc    $0xffffffff,%edx

  return x;
}
f01059fd:	5b                   	pop    %ebx
f01059fe:	5e                   	pop    %esi
f01059ff:	5d                   	pop    %ebp
f0105a00:	c3                   	ret    

f0105a01 <get16>:

static int
get16 ()
{
f0105a01:	55                   	push   %ebp
f0105a02:	89 e5                	mov    %esp,%ebp
f0105a04:	83 ec 08             	sub    $0x8,%esp
  int x = 0;

  FETCH_DATA (the_info, codep + 2);
f0105a07:	8b 15 ec 4e 29 f0    	mov    0xf0294eec,%edx
f0105a0d:	83 c2 02             	add    $0x2,%edx
f0105a10:	8b 0d f0 4e 29 f0    	mov    0xf0294ef0,%ecx
f0105a16:	8b 41 20             	mov    0x20(%ecx),%eax
f0105a19:	3b 10                	cmp    (%eax),%edx
f0105a1b:	76 07                	jbe    f0105a24 <get16+0x23>
f0105a1d:	89 c8                	mov    %ecx,%eax
f0105a1f:	e8 7c fc ff ff       	call   f01056a0 <fetch_data>
  x = *codep++ & 0xff;
f0105a24:	8b 15 ec 4e 29 f0    	mov    0xf0294eec,%edx
f0105a2a:	0f b6 0a             	movzbl (%edx),%ecx
  x |= (*codep++ & 0xff) << 8;
f0105a2d:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f0105a31:	c1 e0 08             	shl    $0x8,%eax
f0105a34:	09 c8                	or     %ecx,%eax
f0105a36:	83 c2 02             	add    $0x2,%edx
f0105a39:	89 15 ec 4e 29 f0    	mov    %edx,0xf0294eec
  return x;
}
f0105a3f:	c9                   	leave  
f0105a40:	c3                   	ret    

f0105a41 <set_op>:

static void
set_op (op, riprel)
     bfd_vma op;
     int riprel;
{
f0105a41:	55                   	push   %ebp
f0105a42:	89 e5                	mov    %esp,%ebp
f0105a44:	83 ec 08             	sub    $0x8,%esp
f0105a47:	89 1c 24             	mov    %ebx,(%esp)
f0105a4a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105a4e:	89 c3                	mov    %eax,%ebx
  op_index[op_ad] = op_ad;
f0105a50:	a1 84 50 29 f0       	mov    0xf0295084,%eax
f0105a55:	89 04 85 88 50 29 f0 	mov    %eax,-0xfd6af78(,%eax,4)
  if (mode_64bit)
f0105a5c:	83 3d e0 4d 29 f0 00 	cmpl   $0x0,0xf0294de0
f0105a63:	74 23                	je     f0105a88 <set_op+0x47>
    {
      op_address[op_ad] = op;
f0105a65:	89 1c c5 98 50 29 f0 	mov    %ebx,-0xfd6af68(,%eax,8)
f0105a6c:	89 14 c5 9c 50 29 f0 	mov    %edx,-0xfd6af64(,%eax,8)
      op_riprel[op_ad] = riprel;
f0105a73:	89 0c c5 b0 50 29 f0 	mov    %ecx,-0xfd6af50(,%eax,8)
f0105a7a:	89 ca                	mov    %ecx,%edx
f0105a7c:	c1 fa 1f             	sar    $0x1f,%edx
f0105a7f:	89 14 c5 b4 50 29 f0 	mov    %edx,-0xfd6af4c(,%eax,8)
f0105a86:	eb 24                	jmp    f0105aac <set_op+0x6b>
    }
  else
    {
      /* Mask to get a 32-bit address.  */
      op_address[op_ad] = op & 0xffffffff;
f0105a88:	89 1c c5 98 50 29 f0 	mov    %ebx,-0xfd6af68(,%eax,8)
f0105a8f:	c7 04 c5 9c 50 29 f0 	movl   $0x0,-0xfd6af64(,%eax,8)
f0105a96:	00 00 00 00 
      op_riprel[op_ad] = riprel & 0xffffffff;
f0105a9a:	89 0c c5 b0 50 29 f0 	mov    %ecx,-0xfd6af50(,%eax,8)
f0105aa1:	c7 04 c5 b4 50 29 f0 	movl   $0x0,-0xfd6af4c(,%eax,8)
f0105aa8:	00 00 00 00 
    }
}
f0105aac:	8b 1c 24             	mov    (%esp),%ebx
f0105aaf:	8b 74 24 04          	mov    0x4(%esp),%esi
f0105ab3:	89 ec                	mov    %ebp,%esp
f0105ab5:	5d                   	pop    %ebp
f0105ab6:	c3                   	ret    

f0105ab7 <putop>:
/* Capital letters in template are macros.  */
static int
putop (template, sizeflag)
     const char *template;
     int sizeflag;
{
f0105ab7:	55                   	push   %ebp
f0105ab8:	89 e5                	mov    %esp,%ebp
f0105aba:	57                   	push   %edi
f0105abb:	56                   	push   %esi
f0105abc:	53                   	push   %ebx
f0105abd:	83 ec 4c             	sub    $0x4c,%esp
f0105ac0:	89 c6                	mov    %eax,%esi
f0105ac2:	89 55 b8             	mov    %edx,-0x48(%ebp)
  const char *p;
  int alt;

  for (p = template; *p; p++)
f0105ac5:	0f b6 18             	movzbl (%eax),%ebx
f0105ac8:	84 db                	test   %bl,%bl
f0105aca:	0f 84 1b 05 00 00    	je     f0105feb <putop+0x534>
f0105ad0:	80 3d d0 50 29 f0 00 	cmpb   $0x0,0xf02950d0
f0105ad7:	0f 95 45 eb          	setne  -0x15(%ebp)
f0105adb:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
f0105adf:	89 45 f0             	mov    %eax,-0x10(%ebp)
	  break;
	case '{':
	  alt = 0;
	  if (intel_syntax)
	    alt += 1;
	  if (mode_64bit)
f0105ae2:	8b 15 e0 4d 29 f0    	mov    0xf0294de0,%edx
f0105ae8:	89 55 bc             	mov    %edx,-0x44(%ebp)
	    alt += 2;
f0105aeb:	83 c0 02             	add    $0x2,%eax
f0105aee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	case '}':
	  break;
	case 'A':
          if (intel_syntax)
            break;
	  if (mod != 3 || (sizeflag & SUFFIX_ALWAYS))
f0105af1:	a1 f4 4e 29 f0       	mov    0xf0294ef4,%eax
f0105af6:	89 45 c0             	mov    %eax,-0x40(%ebp)
		*obufp++ = 'e';
	    }
	  else
	    if (sizeflag & AFLAG)
	      *obufp++ = 'e';
	  used_prefixes |= (prefixes & PREFIX_ADDR);
f0105af9:	a1 e4 4d 29 f0       	mov    0xf0294de4,%eax
f0105afe:	89 c2                	mov    %eax,%edx
f0105b00:	81 e2 00 04 00 00    	and    $0x400,%edx
f0105b06:	89 55 c4             	mov    %edx,-0x3c(%ebp)
	    }
	  break;
	case 'H':
          if (intel_syntax)
            break;
	  if ((prefixes & (PREFIX_CS | PREFIX_DS)) == PREFIX_CS
f0105b09:	89 c2                	mov    %eax,%edx
f0105b0b:	83 e2 28             	and    $0x28,%edx
f0105b0e:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0105b11:	83 fa 08             	cmp    $0x8,%edx
f0105b14:	0f 94 c1             	sete   %cl
f0105b17:	83 fa 20             	cmp    $0x20,%edx
f0105b1a:	0f 94 c2             	sete   %dl
f0105b1d:	09 d1                	or     %edx,%ecx
f0105b1f:	88 4d cf             	mov    %cl,-0x31(%ebp)
	      || (prefixes & (PREFIX_CS | PREFIX_DS)) == PREFIX_DS)
	    {
	      used_prefixes |= prefixes & (PREFIX_CS | PREFIX_DS);
	      *obufp++ = ',';
	      *obufp++ = 'p';
	      if (prefixes & PREFIX_DS)
f0105b22:	89 c2                	mov    %eax,%edx
f0105b24:	83 e2 20             	and    $0x20,%edx
f0105b27:	89 55 d0             	mov    %edx,-0x30(%ebp)
            break;
	  if (sizeflag & SUFFIX_ALWAYS)
	    *obufp++ = 'l';
	  break;
	case 'N':
	  if ((prefixes & PREFIX_FWAIT) == 0)
f0105b2a:	89 c2                	mov    %eax,%edx
f0105b2c:	81 e2 00 08 00 00    	and    $0x800,%edx
f0105b32:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	    *obufp++ = 'n';
	  else
	    used_prefixes |= PREFIX_FWAIT;
	  break;
	case 'O':
	  USED_REX (REX_MODE64);
f0105b35:	8b 15 e8 4d 29 f0    	mov    0xf0294de8,%edx
f0105b3b:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0105b3e:	83 e2 08             	and    $0x8,%edx
f0105b41:	89 55 dc             	mov    %edx,-0x24(%ebp)
	    }
	  /* Fall through.  */
	case 'P':
          if (intel_syntax)
            break;
	  if ((prefixes & PREFIX_DATA)
f0105b44:	25 00 02 00 00       	and    $0x200,%eax
f0105b49:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105b4c:	a1 ec 4d 29 f0       	mov    0xf0294dec,%eax
f0105b51:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105b54:	8b 3d f0 4d 29 f0    	mov    0xf0294df0,%edi
f0105b5a:	8b 0d 64 4e 29 f0    	mov    0xf0294e64,%ecx
f0105b60:	89 f2                	mov    %esi,%edx
	      if (rex)
		{
		  *obufp++ = 'q';
		  *obufp++ = 'e';
		}
	      if (sizeflag & DFLAG)
f0105b62:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0105b65:	83 e0 01             	and    $0x1,%eax
f0105b68:	89 45 b4             	mov    %eax,-0x4c(%ebp)
	    used_prefixes |= (prefixes & PREFIX_DATA);
	  break;
	case 'S':
          if (intel_syntax)
            break;
	  if (sizeflag & SUFFIX_ALWAYS)
f0105b6b:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0105b6e:	83 e6 04             	and    $0x4,%esi
  const char *p;
  int alt;

  for (p = template; *p; p++)
    {
      switch (*p)
f0105b71:	8d 43 bf             	lea    -0x41(%ebx),%eax
f0105b74:	3c 3c                	cmp    $0x3c,%al
f0105b76:	77 0a                	ja     f0105b82 <putop+0xcb>
f0105b78:	0f b6 c0             	movzbl %al,%eax
f0105b7b:	ff 24 85 98 d4 10 f0 	jmp    *-0xfef2b68(,%eax,4)
	{
	default:
	  *obufp++ = *p;
f0105b82:	88 19                	mov    %bl,(%ecx)
f0105b84:	83 c1 01             	add    $0x1,%ecx
f0105b87:	e9 3d 04 00 00       	jmp    f0105fc9 <putop+0x512>
	  break;
	case '{':
	  alt = 0;
	  if (intel_syntax)
	    alt += 1;
	  if (mode_64bit)
f0105b8c:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0105b8f:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
f0105b93:	74 03                	je     f0105b98 <putop+0xe1>
f0105b95:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	    alt += 2;
	  while (alt != 0)
f0105b98:	85 db                	test   %ebx,%ebx
f0105b9a:	75 60                	jne    f0105bfc <putop+0x145>
f0105b9c:	e9 28 04 00 00       	jmp    f0105fc9 <putop+0x512>
	    {
	      while (*++p != '|')
		{
		  if (*p == '}')
f0105ba1:	3c 7d                	cmp    $0x7d,%al
f0105ba3:	75 23                	jne    f0105bc8 <putop+0x111>
f0105ba5:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0105ba8:	89 15 ec 4d 29 f0    	mov    %edx,0xf0294dec
f0105bae:	89 3d f0 4d 29 f0    	mov    %edi,0xf0294df0
		    {
		      /* Alternative not valid.  */
                      //pstrcpy (obuf, sizeof(obuf), "(bad)");
                      //add your code here
                      
		      obufp = obuf + 5;
f0105bb4:	c7 05 64 4e 29 f0 05 	movl   $0xf0294e05,0xf0294e64
f0105bbb:	4e 29 f0 
f0105bbe:	b8 01 00 00 00       	mov    $0x1,%eax
f0105bc3:	e9 46 04 00 00       	jmp    f010600e <putop+0x557>
		      return 1;
		    }
		  else if (*p == '\0')
f0105bc8:	84 c0                	test   %al,%al
f0105bca:	75 30                	jne    f0105bfc <putop+0x145>
f0105bcc:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105bcf:	a3 ec 4d 29 f0       	mov    %eax,0xf0294dec
f0105bd4:	89 3d f0 4d 29 f0    	mov    %edi,0xf0294df0
f0105bda:	89 0d 64 4e 29 f0    	mov    %ecx,0xf0294e64
		    //abort ();
		    panic("putop:erron occured");
f0105be0:	c7 44 24 08 f3 be 10 	movl   $0xf010bef3,0x8(%esp)
f0105be7:	f0 
f0105be8:	c7 44 24 04 40 0a 00 	movl   $0xa40,0x4(%esp)
f0105bef:	00 
f0105bf0:	c7 04 24 07 bf 10 f0 	movl   $0xf010bf07,(%esp)
f0105bf7:	e8 8a a4 ff ff       	call   f0100086 <_panic>
	    alt += 1;
	  if (mode_64bit)
	    alt += 2;
	  while (alt != 0)
	    {
	      while (*++p != '|')
f0105bfc:	83 c2 01             	add    $0x1,%edx
f0105bff:	0f b6 02             	movzbl (%edx),%eax
f0105c02:	3c 7c                	cmp    $0x7c,%al
f0105c04:	75 9b                	jne    f0105ba1 <putop+0xea>
	  alt = 0;
	  if (intel_syntax)
	    alt += 1;
	  if (mode_64bit)
	    alt += 2;
	  while (alt != 0)
f0105c06:	83 eb 01             	sub    $0x1,%ebx
f0105c09:	0f 84 ba 03 00 00    	je     f0105fc9 <putop+0x512>
f0105c0f:	90                   	nop    
f0105c10:	eb ea                	jmp    f0105bfc <putop+0x145>
	    }
	  break;
	case '|':
	  while (*++p != '}')
	    {
	      if (*p == '\0')
f0105c12:	84 c0                	test   %al,%al
f0105c14:	75 31                	jne    f0105c47 <putop+0x190>
f0105c16:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0105c19:	89 15 ec 4d 29 f0    	mov    %edx,0xf0294dec
f0105c1f:	89 3d f0 4d 29 f0    	mov    %edi,0xf0294df0
f0105c25:	89 0d 64 4e 29 f0    	mov    %ecx,0xf0294e64
		//abort ();
		panic("putop:erron occured");
f0105c2b:	c7 44 24 08 f3 be 10 	movl   $0xf010bef3,0x8(%esp)
f0105c32:	f0 
f0105c33:	c7 44 24 04 4a 0a 00 	movl   $0xa4a,0x4(%esp)
f0105c3a:	00 
f0105c3b:	c7 04 24 07 bf 10 f0 	movl   $0xf010bf07,(%esp)
f0105c42:	e8 3f a4 ff ff       	call   f0100086 <_panic>
		}
	      alt--;
	    }
	  break;
	case '|':
	  while (*++p != '}')
f0105c47:	83 c2 01             	add    $0x1,%edx
f0105c4a:	0f b6 02             	movzbl (%edx),%eax
f0105c4d:	3c 7d                	cmp    $0x7d,%al
f0105c4f:	75 c1                	jne    f0105c12 <putop+0x15b>
f0105c51:	e9 73 03 00 00       	jmp    f0105fc9 <putop+0x512>
	    }
	  break;
	case '}':
	  break;
	case 'A':
          if (intel_syntax)
f0105c56:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105c5a:	0f 85 69 03 00 00    	jne    f0105fc9 <putop+0x512>
            break;
	  if (mod != 3 || (sizeflag & SUFFIX_ALWAYS))
f0105c60:	83 7d c0 03          	cmpl   $0x3,-0x40(%ebp)
f0105c64:	75 08                	jne    f0105c6e <putop+0x1b7>
f0105c66:	85 f6                	test   %esi,%esi
f0105c68:	0f 84 5b 03 00 00    	je     f0105fc9 <putop+0x512>
	    *obufp++ = 'b';
f0105c6e:	c6 01 62             	movb   $0x62,(%ecx)
f0105c71:	83 c1 01             	add    $0x1,%ecx
f0105c74:	e9 50 03 00 00       	jmp    f0105fc9 <putop+0x512>
	  break;
	case 'B':
          if (intel_syntax)
f0105c79:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105c7d:	8d 76 00             	lea    0x0(%esi),%esi
f0105c80:	0f 85 43 03 00 00    	jne    f0105fc9 <putop+0x512>
            break;
	  if (sizeflag & SUFFIX_ALWAYS)
f0105c86:	85 f6                	test   %esi,%esi
f0105c88:	0f 84 3b 03 00 00    	je     f0105fc9 <putop+0x512>
	    *obufp++ = 'b';
f0105c8e:	c6 01 62             	movb   $0x62,(%ecx)
f0105c91:	83 c1 01             	add    $0x1,%ecx
f0105c94:	e9 30 03 00 00       	jmp    f0105fc9 <putop+0x512>
	  break;
	case 'E':		/* For jcxz/jecxz */
	  if (mode_64bit)
f0105c99:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
f0105c9d:	8d 76 00             	lea    0x0(%esi),%esi
f0105ca0:	74 18                	je     f0105cba <putop+0x203>
	    {
	      if (sizeflag & AFLAG)
f0105ca2:	f6 45 b8 02          	testb  $0x2,-0x48(%ebp)
f0105ca6:	74 0a                	je     f0105cb2 <putop+0x1fb>
		*obufp++ = 'r';
f0105ca8:	c6 01 72             	movb   $0x72,(%ecx)
f0105cab:	83 c1 01             	add    $0x1,%ecx
f0105cae:	66 90                	xchg   %ax,%ax
f0105cb0:	eb 14                	jmp    f0105cc6 <putop+0x20f>
	      else
		*obufp++ = 'e';
f0105cb2:	c6 01 65             	movb   $0x65,(%ecx)
f0105cb5:	83 c1 01             	add    $0x1,%ecx
f0105cb8:	eb 0c                	jmp    f0105cc6 <putop+0x20f>
	    }
	  else
	    if (sizeflag & AFLAG)
f0105cba:	f6 45 b8 02          	testb  $0x2,-0x48(%ebp)
f0105cbe:	74 06                	je     f0105cc6 <putop+0x20f>
	      *obufp++ = 'e';
f0105cc0:	c6 01 65             	movb   $0x65,(%ecx)
f0105cc3:	83 c1 01             	add    $0x1,%ecx
	  used_prefixes |= (prefixes & PREFIX_ADDR);
f0105cc6:	0b 7d c4             	or     -0x3c(%ebp),%edi
f0105cc9:	e9 fb 02 00 00       	jmp    f0105fc9 <putop+0x512>
	  break;
	case 'F':
          if (intel_syntax)
f0105cce:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105cd2:	0f 85 f1 02 00 00    	jne    f0105fc9 <putop+0x512>
            break;
	  if ((prefixes & PREFIX_ADDR) || (sizeflag & SUFFIX_ALWAYS))
f0105cd8:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f0105cdc:	75 08                	jne    f0105ce6 <putop+0x22f>
f0105cde:	85 f6                	test   %esi,%esi
f0105ce0:	0f 84 e3 02 00 00    	je     f0105fc9 <putop+0x512>
	    {
	      if (sizeflag & AFLAG)
f0105ce6:	f6 45 b8 02          	testb  $0x2,-0x48(%ebp)
f0105cea:	74 13                	je     f0105cff <putop+0x248>
		*obufp++ = mode_64bit ? 'q' : 'l';
f0105cec:	83 7d bc 01          	cmpl   $0x1,-0x44(%ebp)
f0105cf0:	19 c0                	sbb    %eax,%eax
f0105cf2:	83 e0 fb             	and    $0xfffffffb,%eax
f0105cf5:	83 c0 71             	add    $0x71,%eax
f0105cf8:	88 01                	mov    %al,(%ecx)
f0105cfa:	83 c1 01             	add    $0x1,%ecx
f0105cfd:	eb 11                	jmp    f0105d10 <putop+0x259>
	      else
		*obufp++ = mode_64bit ? 'l' : 'w';
f0105cff:	83 7d bc 01          	cmpl   $0x1,-0x44(%ebp)
f0105d03:	19 c0                	sbb    %eax,%eax
f0105d05:	83 e0 0b             	and    $0xb,%eax
f0105d08:	83 c0 6c             	add    $0x6c,%eax
f0105d0b:	88 01                	mov    %al,(%ecx)
f0105d0d:	83 c1 01             	add    $0x1,%ecx
	      used_prefixes |= (prefixes & PREFIX_ADDR);
f0105d10:	0b 7d c4             	or     -0x3c(%ebp),%edi
f0105d13:	e9 b1 02 00 00       	jmp    f0105fc9 <putop+0x512>
	    }
	  break;
	case 'H':
          if (intel_syntax)
f0105d18:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105d1c:	0f 85 a7 02 00 00    	jne    f0105fc9 <putop+0x512>
            break;
	  if ((prefixes & (PREFIX_CS | PREFIX_DS)) == PREFIX_CS
f0105d22:	80 7d cf 00          	cmpb   $0x0,-0x31(%ebp)
f0105d26:	0f 84 9d 02 00 00    	je     f0105fc9 <putop+0x512>
	      || (prefixes & (PREFIX_CS | PREFIX_DS)) == PREFIX_DS)
	    {
	      used_prefixes |= prefixes & (PREFIX_CS | PREFIX_DS);
f0105d2c:	0b 7d c8             	or     -0x38(%ebp),%edi
	      *obufp++ = ',';
f0105d2f:	c6 01 2c             	movb   $0x2c,(%ecx)
	      *obufp++ = 'p';
f0105d32:	c6 41 01 70          	movb   $0x70,0x1(%ecx)
f0105d36:	8d 41 02             	lea    0x2(%ecx),%eax
	      if (prefixes & PREFIX_DS)
f0105d39:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0105d3d:	74 0c                	je     f0105d4b <putop+0x294>
		*obufp++ = 't';
f0105d3f:	c6 41 02 74          	movb   $0x74,0x2(%ecx)
f0105d43:	83 c1 03             	add    $0x3,%ecx
f0105d46:	e9 7e 02 00 00       	jmp    f0105fc9 <putop+0x512>
	      else
		*obufp++ = 'n';
f0105d4b:	c6 00 6e             	movb   $0x6e,(%eax)
f0105d4e:	8d 48 01             	lea    0x1(%eax),%ecx
f0105d51:	e9 73 02 00 00       	jmp    f0105fc9 <putop+0x512>
	    }
	  break;
	case 'L':
          if (intel_syntax)
f0105d56:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105d5a:	0f 85 69 02 00 00    	jne    f0105fc9 <putop+0x512>
            break;
	  if (sizeflag & SUFFIX_ALWAYS)
f0105d60:	85 f6                	test   %esi,%esi
f0105d62:	0f 84 61 02 00 00    	je     f0105fc9 <putop+0x512>
	    *obufp++ = 'l';
f0105d68:	c6 01 6c             	movb   $0x6c,(%ecx)
f0105d6b:	83 c1 01             	add    $0x1,%ecx
f0105d6e:	66 90                	xchg   %ax,%ax
f0105d70:	e9 54 02 00 00       	jmp    f0105fc9 <putop+0x512>
	  break;
	case 'N':
	  if ((prefixes & PREFIX_FWAIT) == 0)
f0105d75:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0105d79:	75 0b                	jne    f0105d86 <putop+0x2cf>
	    *obufp++ = 'n';
f0105d7b:	c6 01 6e             	movb   $0x6e,(%ecx)
f0105d7e:	83 c1 01             	add    $0x1,%ecx
f0105d81:	e9 43 02 00 00       	jmp    f0105fc9 <putop+0x512>
	  else
	    used_prefixes |= PREFIX_FWAIT;
f0105d86:	81 cf 00 08 00 00    	or     $0x800,%edi
f0105d8c:	e9 38 02 00 00       	jmp    f0105fc9 <putop+0x512>
	  break;
	case 'O':
	  USED_REX (REX_MODE64);
f0105d91:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105d95:	0f 84 5f 02 00 00    	je     f0105ffa <putop+0x543>
f0105d9b:	83 4d ec 48          	orl    $0x48,-0x14(%ebp)
	  if (rex & REX_MODE64)
	    *obufp++ = 'o';
f0105d9f:	c6 01 6f             	movb   $0x6f,(%ecx)
f0105da2:	83 c1 01             	add    $0x1,%ecx
f0105da5:	e9 1f 02 00 00       	jmp    f0105fc9 <putop+0x512>
	  else
	    *obufp++ = 'd';
	  break;
	case 'T':
          if (intel_syntax)
f0105daa:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105dae:	0f 85 15 02 00 00    	jne    f0105fc9 <putop+0x512>
            break;
	  if (mode_64bit)
f0105db4:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
f0105db8:	74 15                	je     f0105dcf <putop+0x318>
	    {
	      *obufp++ = 'q';
f0105dba:	c6 01 71             	movb   $0x71,(%ecx)
f0105dbd:	83 c1 01             	add    $0x1,%ecx
f0105dc0:	e9 04 02 00 00       	jmp    f0105fc9 <putop+0x512>
	      break;
	    }
	  /* Fall through.  */
	case 'P':
          if (intel_syntax)
f0105dc5:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105dc9:	0f 85 fa 01 00 00    	jne    f0105fc9 <putop+0x512>
            break;
	  if ((prefixes & PREFIX_DATA)
f0105dcf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105dd3:	75 13                	jne    f0105de8 <putop+0x331>
f0105dd5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105dd9:	0f 85 23 02 00 00    	jne    f0106002 <putop+0x54b>
f0105ddf:	85 f6                	test   %esi,%esi
f0105de1:	75 13                	jne    f0105df6 <putop+0x33f>
f0105de3:	e9 e1 01 00 00       	jmp    f0105fc9 <putop+0x512>
	      || (rex & REX_MODE64)
	      || (sizeflag & SUFFIX_ALWAYS))
	    {
	      USED_REX (REX_MODE64);
f0105de8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105dec:	8d 74 26 00          	lea    0x0(%esi),%esi
f0105df0:	0f 85 0c 02 00 00    	jne    f0106002 <putop+0x54b>
	      if (rex & REX_MODE64)
		*obufp++ = 'q';
	      else
		{
		   if (sizeflag & DFLAG)
f0105df6:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
f0105dfa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105e00:	74 08                	je     f0105e0a <putop+0x353>
		      *obufp++ = 'l';
f0105e02:	c6 01 6c             	movb   $0x6c,(%ecx)
f0105e05:	83 c1 01             	add    $0x1,%ecx
f0105e08:	eb 06                	jmp    f0105e10 <putop+0x359>
		   else
		     *obufp++ = 'w';
f0105e0a:	c6 01 77             	movb   $0x77,(%ecx)
f0105e0d:	83 c1 01             	add    $0x1,%ecx
		   used_prefixes |= (prefixes & PREFIX_DATA);
f0105e10:	0b 7d e0             	or     -0x20(%ebp),%edi
f0105e13:	e9 b1 01 00 00       	jmp    f0105fc9 <putop+0x512>
		}
	    }
	  break;
	case 'U':
          if (intel_syntax)
f0105e18:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105e1c:	0f 85 a7 01 00 00    	jne    f0105fc9 <putop+0x512>
            break;
	  if (mode_64bit)
f0105e22:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
f0105e26:	74 17                	je     f0105e3f <putop+0x388>
	    {
	      *obufp++ = 'q';
f0105e28:	c6 01 71             	movb   $0x71,(%ecx)
f0105e2b:	83 c1 01             	add    $0x1,%ecx
f0105e2e:	66 90                	xchg   %ax,%ax
f0105e30:	e9 94 01 00 00       	jmp    f0105fc9 <putop+0x512>
	      break;
	    }
	  /* Fall through.  */
	case 'Q':
          if (intel_syntax)
f0105e35:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105e39:	0f 85 8a 01 00 00    	jne    f0105fc9 <putop+0x512>
            break;
	  USED_REX (REX_MODE64);
f0105e3f:	83 7d dc 01          	cmpl   $0x1,-0x24(%ebp)
f0105e43:	19 c0                	sbb    %eax,%eax
f0105e45:	f7 d0                	not    %eax
f0105e47:	83 e0 48             	and    $0x48,%eax
f0105e4a:	09 45 ec             	or     %eax,-0x14(%ebp)
	  if (mod != 3 || (sizeflag & SUFFIX_ALWAYS))
f0105e4d:	83 7d c0 03          	cmpl   $0x3,-0x40(%ebp)
f0105e51:	75 08                	jne    f0105e5b <putop+0x3a4>
f0105e53:	85 f6                	test   %esi,%esi
f0105e55:	0f 84 6e 01 00 00    	je     f0105fc9 <putop+0x512>
	    {
	      if (rex & REX_MODE64)
f0105e5b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105e5f:	74 0b                	je     f0105e6c <putop+0x3b5>
		*obufp++ = 'q';
f0105e61:	c6 01 71             	movb   $0x71,(%ecx)
f0105e64:	83 c1 01             	add    $0x1,%ecx
f0105e67:	e9 5d 01 00 00       	jmp    f0105fc9 <putop+0x512>
	      else
		{
		  if (sizeflag & DFLAG)
f0105e6c:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
f0105e70:	74 08                	je     f0105e7a <putop+0x3c3>
		    *obufp++ = 'l';
f0105e72:	c6 01 6c             	movb   $0x6c,(%ecx)
f0105e75:	83 c1 01             	add    $0x1,%ecx
f0105e78:	eb 06                	jmp    f0105e80 <putop+0x3c9>
		  else
		    *obufp++ = 'w';
f0105e7a:	c6 01 77             	movb   $0x77,(%ecx)
f0105e7d:	83 c1 01             	add    $0x1,%ecx
		  used_prefixes |= (prefixes & PREFIX_DATA);
f0105e80:	0b 7d e0             	or     -0x20(%ebp),%edi
f0105e83:	e9 41 01 00 00       	jmp    f0105fc9 <putop+0x512>
		}
	    }
	  break;
	case 'R':
	  USED_REX (REX_MODE64);
f0105e88:	83 7d dc 01          	cmpl   $0x1,-0x24(%ebp)
f0105e8c:	19 c0                	sbb    %eax,%eax
f0105e8e:	f7 d0                	not    %eax
f0105e90:	83 e0 48             	and    $0x48,%eax
f0105e93:	09 45 ec             	or     %eax,-0x14(%ebp)
          if (intel_syntax)
f0105e96:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105e9a:	74 33                	je     f0105ecf <putop+0x418>
	    {
	      if (rex & REX_MODE64)
f0105e9c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105ea0:	74 0f                	je     f0105eb1 <putop+0x3fa>
		{
		  *obufp++ = 'q';
f0105ea2:	c6 01 71             	movb   $0x71,(%ecx)
		  *obufp++ = 't';
f0105ea5:	c6 41 01 74          	movb   $0x74,0x1(%ecx)
f0105ea9:	83 c1 02             	add    $0x2,%ecx
f0105eac:	e9 18 01 00 00       	jmp    f0105fc9 <putop+0x512>
		}
	      else if (sizeflag & DFLAG)
f0105eb1:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
f0105eb5:	74 0c                	je     f0105ec3 <putop+0x40c>
		{
		  *obufp++ = 'd';
f0105eb7:	c6 01 64             	movb   $0x64,(%ecx)
		  *obufp++ = 'q';
f0105eba:	c6 41 01 71          	movb   $0x71,0x1(%ecx)
f0105ebe:	83 c1 02             	add    $0x2,%ecx
f0105ec1:	eb 31                	jmp    f0105ef4 <putop+0x43d>
		}
	      else
		{
		  *obufp++ = 'w';
f0105ec3:	c6 01 77             	movb   $0x77,(%ecx)
		  *obufp++ = 'd';
f0105ec6:	c6 41 01 64          	movb   $0x64,0x1(%ecx)
f0105eca:	83 c1 02             	add    $0x2,%ecx
f0105ecd:	eb 25                	jmp    f0105ef4 <putop+0x43d>
		}
	    }
	  else
	    {
	      if (rex & REX_MODE64)
f0105ecf:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105ed3:	74 0b                	je     f0105ee0 <putop+0x429>
		*obufp++ = 'q';
f0105ed5:	c6 01 71             	movb   $0x71,(%ecx)
f0105ed8:	83 c1 01             	add    $0x1,%ecx
f0105edb:	e9 e9 00 00 00       	jmp    f0105fc9 <putop+0x512>
	      else if (sizeflag & DFLAG)
f0105ee0:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
f0105ee4:	74 08                	je     f0105eee <putop+0x437>
		*obufp++ = 'l';
f0105ee6:	c6 01 6c             	movb   $0x6c,(%ecx)
f0105ee9:	83 c1 01             	add    $0x1,%ecx
f0105eec:	eb 06                	jmp    f0105ef4 <putop+0x43d>
	      else
		*obufp++ = 'w';
f0105eee:	c6 01 77             	movb   $0x77,(%ecx)
f0105ef1:	83 c1 01             	add    $0x1,%ecx
	    }
	  if (!(rex & REX_MODE64))
	    used_prefixes |= (prefixes & PREFIX_DATA);
f0105ef4:	0b 7d e0             	or     -0x20(%ebp),%edi
f0105ef7:	e9 cd 00 00 00       	jmp    f0105fc9 <putop+0x512>
	  break;
	case 'S':
          if (intel_syntax)
f0105efc:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105f00:	0f 85 c3 00 00 00    	jne    f0105fc9 <putop+0x512>
            break;
	  if (sizeflag & SUFFIX_ALWAYS)
f0105f06:	85 f6                	test   %esi,%esi
f0105f08:	0f 84 bb 00 00 00    	je     f0105fc9 <putop+0x512>
	    {
	      if (rex & REX_MODE64)
f0105f0e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105f12:	74 0b                	je     f0105f1f <putop+0x468>
		*obufp++ = 'q';
f0105f14:	c6 01 71             	movb   $0x71,(%ecx)
f0105f17:	83 c1 01             	add    $0x1,%ecx
f0105f1a:	e9 aa 00 00 00       	jmp    f0105fc9 <putop+0x512>
	      else
		{
		  if (sizeflag & DFLAG)
f0105f1f:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
f0105f23:	74 08                	je     f0105f2d <putop+0x476>
		    *obufp++ = 'l';
f0105f25:	c6 01 6c             	movb   $0x6c,(%ecx)
f0105f28:	83 c1 01             	add    $0x1,%ecx
f0105f2b:	eb 06                	jmp    f0105f33 <putop+0x47c>
		  else
		    *obufp++ = 'w';
f0105f2d:	c6 01 77             	movb   $0x77,(%ecx)
f0105f30:	83 c1 01             	add    $0x1,%ecx
		  used_prefixes |= (prefixes & PREFIX_DATA);
f0105f33:	0b 7d e0             	or     -0x20(%ebp),%edi
f0105f36:	e9 8e 00 00 00       	jmp    f0105fc9 <putop+0x512>
		}
	    }
	  break;
	case 'X':
	  if (prefixes & PREFIX_DATA)
f0105f3b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105f3f:	74 08                	je     f0105f49 <putop+0x492>
	    *obufp++ = 'd';
f0105f41:	c6 01 64             	movb   $0x64,(%ecx)
f0105f44:	83 c1 01             	add    $0x1,%ecx
f0105f47:	eb 06                	jmp    f0105f4f <putop+0x498>
	  else
	    *obufp++ = 's';
f0105f49:	c6 01 73             	movb   $0x73,(%ecx)
f0105f4c:	83 c1 01             	add    $0x1,%ecx
          used_prefixes |= (prefixes & PREFIX_DATA);
f0105f4f:	0b 7d e0             	or     -0x20(%ebp),%edi
f0105f52:	eb 75                	jmp    f0105fc9 <putop+0x512>
	  break;
	case 'Y':
          if (intel_syntax)
f0105f54:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105f58:	75 6f                	jne    f0105fc9 <putop+0x512>
            break;
	  if (rex & REX_MODE64)
f0105f5a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105f5e:	74 69                	je     f0105fc9 <putop+0x512>
	    {
	      USED_REX (REX_MODE64);
f0105f60:	83 4d ec 48          	orl    $0x48,-0x14(%ebp)
	      *obufp++ = 'q';
f0105f64:	c6 01 71             	movb   $0x71,(%ecx)
f0105f67:	83 c1 01             	add    $0x1,%ecx
f0105f6a:	eb 5d                	jmp    f0105fc9 <putop+0x512>
	    }
	  break;
	  /* implicit operand size 'l' for i386 or 'q' for x86-64 */
	case 'W':
	  /* operand size flag for cwtl, cbtw */
	  USED_REX (0);
f0105f6c:	83 4d ec 40          	orl    $0x40,-0x14(%ebp)
	  if (rex)
f0105f70:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105f74:	74 08                	je     f0105f7e <putop+0x4c7>
	    *obufp++ = 'l';
f0105f76:	c6 01 6c             	movb   $0x6c,(%ecx)
f0105f79:	83 c1 01             	add    $0x1,%ecx
f0105f7c:	eb 14                	jmp    f0105f92 <putop+0x4db>
	  else if (sizeflag & DFLAG)
f0105f7e:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
f0105f82:	74 08                	je     f0105f8c <putop+0x4d5>
	    *obufp++ = 'w';
f0105f84:	c6 01 77             	movb   $0x77,(%ecx)
f0105f87:	83 c1 01             	add    $0x1,%ecx
f0105f8a:	eb 06                	jmp    f0105f92 <putop+0x4db>
	  else
	    *obufp++ = 'b';
f0105f8c:	c6 01 62             	movb   $0x62,(%ecx)
f0105f8f:	83 c1 01             	add    $0x1,%ecx
          if (intel_syntax)
f0105f92:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105f96:	74 28                	je     f0105fc0 <putop+0x509>
	    {
	      if (rex)
f0105f98:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105f9c:	74 0a                	je     f0105fa8 <putop+0x4f1>
		{
		  *obufp++ = 'q';
f0105f9e:	c6 01 71             	movb   $0x71,(%ecx)
		  *obufp++ = 'e';
f0105fa1:	c6 41 01 65          	movb   $0x65,0x1(%ecx)
f0105fa5:	83 c1 02             	add    $0x2,%ecx
		}
	      if (sizeflag & DFLAG)
f0105fa8:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
f0105fac:	74 0c                	je     f0105fba <putop+0x503>
		{
		  *obufp++ = 'd';
f0105fae:	c6 01 64             	movb   $0x64,(%ecx)
		  *obufp++ = 'e';
f0105fb1:	c6 41 01 65          	movb   $0x65,0x1(%ecx)
f0105fb5:	83 c1 02             	add    $0x2,%ecx
f0105fb8:	eb 06                	jmp    f0105fc0 <putop+0x509>
		}
	      else
		{
		  *obufp++ = 'w';
f0105fba:	c6 01 77             	movb   $0x77,(%ecx)
f0105fbd:	83 c1 01             	add    $0x1,%ecx
		}
	    }
	  if (!rex)
f0105fc0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105fc4:	75 03                	jne    f0105fc9 <putop+0x512>
	    used_prefixes |= (prefixes & PREFIX_DATA);
f0105fc6:	0b 7d e0             	or     -0x20(%ebp),%edi
     int sizeflag;
{
  const char *p;
  int alt;

  for (p = template; *p; p++)
f0105fc9:	83 c2 01             	add    $0x1,%edx
f0105fcc:	0f b6 1a             	movzbl (%edx),%ebx
f0105fcf:	84 db                	test   %bl,%bl
f0105fd1:	0f 85 9a fb ff ff    	jne    f0105b71 <putop+0xba>
f0105fd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105fda:	a3 ec 4d 29 f0       	mov    %eax,0xf0294dec
f0105fdf:	89 3d f0 4d 29 f0    	mov    %edi,0xf0294df0
f0105fe5:	89 0d 64 4e 29 f0    	mov    %ecx,0xf0294e64
	  if (!rex)
	    used_prefixes |= (prefixes & PREFIX_DATA);
	  break;
	}
    }
  *obufp = 0;
f0105feb:	a1 64 4e 29 f0       	mov    0xf0294e64,%eax
f0105ff0:	c6 00 00             	movb   $0x0,(%eax)
f0105ff3:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ff8:	eb 14                	jmp    f010600e <putop+0x557>
	case 'O':
	  USED_REX (REX_MODE64);
	  if (rex & REX_MODE64)
	    *obufp++ = 'o';
	  else
	    *obufp++ = 'd';
f0105ffa:	c6 01 64             	movb   $0x64,(%ecx)
f0105ffd:	83 c1 01             	add    $0x1,%ecx
f0106000:	eb c7                	jmp    f0105fc9 <putop+0x512>
            break;
	  if ((prefixes & PREFIX_DATA)
	      || (rex & REX_MODE64)
	      || (sizeflag & SUFFIX_ALWAYS))
	    {
	      USED_REX (REX_MODE64);
f0106002:	83 4d ec 48          	orl    $0x48,-0x14(%ebp)
	      if (rex & REX_MODE64)
		*obufp++ = 'q';
f0106006:	c6 01 71             	movb   $0x71,(%ecx)
f0106009:	83 c1 01             	add    $0x1,%ecx
f010600c:	eb bb                	jmp    f0105fc9 <putop+0x512>
	  break;
	}
    }
  *obufp = 0;
  return 0;
}
f010600e:	83 c4 4c             	add    $0x4c,%esp
f0106011:	5b                   	pop    %ebx
f0106012:	5e                   	pop    %esi
f0106013:	5f                   	pop    %edi
f0106014:	5d                   	pop    %ebp
f0106015:	c3                   	ret    

f0106016 <SIMD_Fixup>:

static void
SIMD_Fixup (extrachar, sizeflag)
     int extrachar;
     int sizeflag;
{
f0106016:	55                   	push   %ebp
f0106017:	89 e5                	mov    %esp,%ebp
f0106019:	83 ec 08             	sub    $0x8,%esp
  /* Change movlps/movhps to movhlps/movlhps for 2 register operand
     forms of these instructions.  */
  if (mod == 3)
f010601c:	83 3d f4 4e 29 f0 03 	cmpl   $0x3,0xf0294ef4
f0106023:	75 35                	jne    f010605a <SIMD_Fixup+0x44>
    {
      char *p = obuf + strlen (obuf);
f0106025:	c7 04 24 00 4e 29 f0 	movl   $0xf0294e00,(%esp)
f010602c:	e8 af 34 00 00       	call   f01094e0 <strlen>
f0106031:	8d 90 00 4e 29 f0    	lea    -0xfd6b200(%eax),%edx
      *(p + 1) = '\0';
f0106037:	c6 42 01 00          	movb   $0x0,0x1(%edx)
      *p       = *(p - 1);
f010603b:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
f010603f:	88 88 00 4e 29 f0    	mov    %cl,-0xfd6b200(%eax)
      *(p - 1) = *(p - 2);
f0106045:	0f b6 42 fe          	movzbl -0x2(%edx),%eax
f0106049:	88 42 ff             	mov    %al,-0x1(%edx)
      *(p - 2) = *(p - 3);
f010604c:	0f b6 42 fd          	movzbl -0x3(%edx),%eax
f0106050:	88 42 fe             	mov    %al,-0x2(%edx)
      *(p - 3) = extrachar;
f0106053:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
f0106057:	88 42 fd             	mov    %al,-0x3(%edx)
    }
}
f010605a:	c9                   	leave  
f010605b:	c3                   	ret    

f010605c <print_operand_value>:
  OP_E (bytemode, sizeflag);
}

static void
print_operand_value (char *buf, size_t bufsize, int hex, bfd_vma disp)
{
f010605c:	55                   	push   %ebp
f010605d:	89 e5                	mov    %esp,%ebp
f010605f:	57                   	push   %edi
f0106060:	56                   	push   %esi
f0106061:	53                   	push   %ebx
f0106062:	83 ec 4c             	sub    $0x4c,%esp
f0106065:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0106068:	89 55 c8             	mov    %edx,-0x38(%ebp)
f010606b:	8b 45 08             	mov    0x8(%ebp),%eax
f010606e:	8b 55 0c             	mov    0xc(%ebp),%edx
  if (mode_64bit)
f0106071:	83 3d e0 4d 29 f0 00 	cmpl   $0x0,0xf0294de0
f0106078:	0f 84 55 01 00 00    	je     f01061d3 <print_operand_value+0x177>
    {
      if (hex)
f010607e:	85 c9                	test   %ecx,%ecx
f0106080:	74 6d                	je     f01060ef <print_operand_value+0x93>
	{
	  char tmp[30];
	  int i;
	  buf[0] = '0';
f0106082:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0106085:	c6 01 30             	movb   $0x30,(%ecx)
	  buf[1] = 'x';
f0106088:	c6 41 01 78          	movb   $0x78,0x1(%ecx)
          snprintf_vma (tmp, sizeof(tmp), disp);
f010608c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106090:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106094:	c7 44 24 08 17 bf 10 	movl   $0xf010bf17,0x8(%esp)
f010609b:	f0 
f010609c:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
f01060a3:	00 
f01060a4:	8d 45 d6             	lea    -0x2a(%ebp),%eax
f01060a7:	89 04 24             	mov    %eax,(%esp)
f01060aa:	e8 fb 32 00 00       	call   f01093aa <snprintf>
f01060af:	ba 00 00 00 00       	mov    $0x0,%edx
          //add your code here
	  for (i = 0; tmp[i] == '0' && tmp[i + 1]; i++);
f01060b4:	8d 4d d6             	lea    -0x2a(%ebp),%ecx
f01060b7:	80 3c 0a 30          	cmpb   $0x30,(%edx,%ecx,1)
f01060bb:	75 0d                	jne    f01060ca <print_operand_value+0x6e>
f01060bd:	8d 42 01             	lea    0x1(%edx),%eax
f01060c0:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
f01060c4:	74 04                	je     f01060ca <print_operand_value+0x6e>
f01060c6:	89 c2                	mov    %eax,%edx
f01060c8:	eb ed                	jmp    f01060b7 <print_operand_value+0x5b>
          pstrcpy (buf + 2, bufsize - 2, tmp + i);
f01060ca:	8d 44 15 d6          	lea    -0x2a(%ebp,%edx,1),%eax
f01060ce:	89 44 24 08          	mov    %eax,0x8(%esp)
f01060d2:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01060d5:	83 e8 02             	sub    $0x2,%eax
f01060d8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01060dc:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01060df:	83 c0 02             	add    $0x2,%eax
f01060e2:	89 04 24             	mov    %eax,(%esp)
f01060e5:	e8 e3 34 00 00       	call   f01095cd <pstrcpy>
f01060ea:	e9 26 01 00 00       	jmp    f0106215 <print_operand_value+0x1b9>
          //add your code here
	}
      else
	{
	  bfd_signed_vma v = disp;
f01060ef:	89 c6                	mov    %eax,%esi
f01060f1:	89 d7                	mov    %edx,%edi
	  char tmp[30];
	  int i;
	  if (v < 0)
f01060f3:	85 d2                	test   %edx,%edx
f01060f5:	79 33                	jns    f010612a <print_operand_value+0xce>
	    {
	      *(buf++) = '-';
f01060f7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01060fa:	c6 01 2d             	movb   $0x2d,(%ecx)
f01060fd:	83 c1 01             	add    $0x1,%ecx
f0106100:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	      v = -disp;
f0106103:	f7 de                	neg    %esi
f0106105:	83 d7 00             	adc    $0x0,%edi
f0106108:	f7 df                	neg    %edi
	      /* Check for possible overflow on 0x8000000000000000.  */
	      if (v < 0)
f010610a:	85 ff                	test   %edi,%edi
f010610c:	79 1c                	jns    f010612a <print_operand_value+0xce>
		{
                  pstrcpy (buf, bufsize, "9223372036854775808");
f010610e:	c7 44 24 08 1b bf 10 	movl   $0xf010bf1b,0x8(%esp)
f0106115:	f0 
f0106116:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0106119:	89 44 24 04          	mov    %eax,0x4(%esp)
f010611d:	89 0c 24             	mov    %ecx,(%esp)
f0106120:	e8 a8 34 00 00       	call   f01095cd <pstrcpy>
f0106125:	e9 eb 00 00 00       	jmp    f0106215 <print_operand_value+0x1b9>
                  //add your code here
		  return;
		}
	    }
	  if (!v)
f010612a:	89 f9                	mov    %edi,%ecx
f010612c:	09 f1                	or     %esi,%ecx
f010612e:	75 1f                	jne    f010614f <print_operand_value+0xf3>
	    {
                pstrcpy (buf, bufsize, "0");
f0106130:	c7 44 24 08 e5 b6 10 	movl   $0xf010b6e5,0x8(%esp)
f0106137:	f0 
f0106138:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010613b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010613f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0106142:	89 0c 24             	mov    %ecx,(%esp)
f0106145:	e8 83 34 00 00       	call   f01095cd <pstrcpy>
f010614a:	e9 c6 00 00 00       	jmp    f0106215 <print_operand_value+0x1b9>
                //add your code here
	      return;
	    }

	  i = 0;
	  tmp[29] = 0;
f010614f:	c6 45 f3 00          	movb   $0x0,-0xd(%ebp)
f0106153:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
	  while (v)
	    {
	      tmp[28 - i] = (v % 10) + '0';
f010615a:	8d 45 d6             	lea    -0x2a(%ebp),%eax
f010615d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0106160:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0106163:	f7 db                	neg    %ebx
f0106165:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f010616c:	00 
f010616d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0106174:	00 
f0106175:	89 34 24             	mov    %esi,(%esp)
f0106178:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010617c:	e8 1f 41 00 00       	call   f010a2a0 <__moddi3>
f0106181:	83 c0 30             	add    $0x30,%eax
f0106184:	88 44 2b f2          	mov    %al,-0xe(%ebx,%ebp,1)
	      v /= 10;
f0106188:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f010618f:	00 
f0106190:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0106197:	00 
f0106198:	89 34 24             	mov    %esi,(%esp)
f010619b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010619f:	e8 7c 3f 00 00       	call   f010a120 <__divdi3>
f01061a4:	89 c6                	mov    %eax,%esi
f01061a6:	89 d7                	mov    %edx,%edi
	      i++;
f01061a8:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	      return;
	    }

	  i = 0;
	  tmp[29] = 0;
	  while (v)
f01061ac:	89 d1                	mov    %edx,%ecx
f01061ae:	09 c1                	or     %eax,%ecx
f01061b0:	75 a8                	jne    f010615a <print_operand_value+0xfe>
	    {
	      tmp[28 - i] = (v % 10) + '0';
	      v /= 10;
	      i++;
	    }
          pstrcpy (buf, bufsize, tmp + 29 - i);
f01061b2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01061b5:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01061b8:	83 c0 1d             	add    $0x1d,%eax
f01061bb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01061bf:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01061c2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01061c6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01061c9:	89 0c 24             	mov    %ecx,(%esp)
f01061cc:	e8 fc 33 00 00       	call   f01095cd <pstrcpy>
f01061d1:	eb 42                	jmp    f0106215 <print_operand_value+0x1b9>
          //add your code here
	}
    }
  else
    {
      if (hex)
f01061d3:	85 c9                	test   %ecx,%ecx
f01061d5:	74 20                	je     f01061f7 <print_operand_value+0x19b>
        snprintf (buf, bufsize, "0x%x", (unsigned int) disp);
f01061d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01061db:	c7 44 24 08 7d bf 10 	movl   $0xf010bf7d,0x8(%esp)
f01061e2:	f0 
f01061e3:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01061e6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01061ea:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01061ed:	89 0c 24             	mov    %ecx,(%esp)
f01061f0:	e8 b5 31 00 00       	call   f01093aa <snprintf>
f01061f5:	eb 1e                	jmp    f0106215 <print_operand_value+0x1b9>
      else
        snprintf (buf, bufsize, "%d", (int) disp);
f01061f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01061fb:	c7 44 24 08 1d 43 11 	movl   $0xf011431d,0x8(%esp)
f0106202:	f0 
f0106203:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0106206:	89 44 24 04          	mov    %eax,0x4(%esp)
f010620a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010620d:	89 0c 24             	mov    %ecx,(%esp)
f0106210:	e8 95 31 00 00       	call   f01093aa <snprintf>
    }
}
f0106215:	83 c4 4c             	add    $0x4c,%esp
f0106218:	5b                   	pop    %ebx
f0106219:	5e                   	pop    %esi
f010621a:	5f                   	pop    %edi
f010621b:	5d                   	pop    %ebp
f010621c:	c3                   	ret    

f010621d <oappend>:
}

static void
oappend (s)
     const char *s;
{
f010621d:	55                   	push   %ebp
f010621e:	89 e5                	mov    %esp,%ebp
f0106220:	53                   	push   %ebx
f0106221:	83 ec 14             	sub    $0x14,%esp
f0106224:	89 c3                	mov    %eax,%ebx
  strcpy (obufp, s);
f0106226:	89 44 24 04          	mov    %eax,0x4(%esp)
f010622a:	a1 64 4e 29 f0       	mov    0xf0294e64,%eax
f010622f:	89 04 24             	mov    %eax,(%esp)
f0106232:	e8 fa 32 00 00       	call   f0109531 <strcpy>
  obufp += strlen (s);
f0106237:	89 1c 24             	mov    %ebx,(%esp)
f010623a:	e8 a1 32 00 00       	call   f01094e0 <strlen>
f010623f:	01 05 64 4e 29 f0    	add    %eax,0xf0294e64
}
f0106245:	83 c4 14             	add    $0x14,%esp
f0106248:	5b                   	pop    %ebx
f0106249:	5d                   	pop    %ebp
f010624a:	c3                   	ret    

f010624b <BadOp>:
    }
}

static void
BadOp (void)
{
f010624b:	55                   	push   %ebp
f010624c:	89 e5                	mov    %esp,%ebp
f010624e:	83 ec 08             	sub    $0x8,%esp
  /* Throw away prefixes and 1st. opcode byte.  */
  codep = insn_codep + 1;
f0106251:	a1 e8 4e 29 f0       	mov    0xf0294ee8,%eax
f0106256:	83 c0 01             	add    $0x1,%eax
f0106259:	a3 ec 4e 29 f0       	mov    %eax,0xf0294eec
  oappend ("(bad)");
f010625e:	b8 2f bf 10 f0       	mov    $0xf010bf2f,%eax
f0106263:	e8 b5 ff ff ff       	call   f010621d <oappend>
}
f0106268:	c9                   	leave  
f0106269:	c3                   	ret    

f010626a <OP_SIMD_Suffix>:

static void
OP_SIMD_Suffix (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f010626a:	55                   	push   %ebp
f010626b:	89 e5                	mov    %esp,%ebp
f010626d:	83 ec 28             	sub    $0x28,%esp
f0106270:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0106273:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0106276:	89 7d fc             	mov    %edi,-0x4(%ebp)
  unsigned int cmp_type;

  FETCH_DATA (the_info, codep + 1);
f0106279:	8b 15 ec 4e 29 f0    	mov    0xf0294eec,%edx
f010627f:	83 c2 01             	add    $0x1,%edx
f0106282:	8b 0d f0 4e 29 f0    	mov    0xf0294ef0,%ecx
f0106288:	8b 41 20             	mov    0x20(%ecx),%eax
f010628b:	3b 10                	cmp    (%eax),%edx
f010628d:	76 07                	jbe    f0106296 <OP_SIMD_Suffix+0x2c>
f010628f:	89 c8                	mov    %ecx,%eax
f0106291:	e8 0a f4 ff ff       	call   f01056a0 <fetch_data>
  obufp = obuf + strlen (obuf);
f0106296:	c7 04 24 00 4e 29 f0 	movl   $0xf0294e00,(%esp)
f010629d:	e8 3e 32 00 00       	call   f01094e0 <strlen>
f01062a2:	05 00 4e 29 f0       	add    $0xf0294e00,%eax
f01062a7:	a3 64 4e 29 f0       	mov    %eax,0xf0294e64
  cmp_type = *codep++ & 0xff;
f01062ac:	a1 ec 4e 29 f0       	mov    0xf0294eec,%eax
f01062b1:	0f b6 38             	movzbl (%eax),%edi
f01062b4:	83 c0 01             	add    $0x1,%eax
f01062b7:	a3 ec 4e 29 f0       	mov    %eax,0xf0294eec
  if (cmp_type < 8)
f01062bc:	83 ff 07             	cmp    $0x7,%edi
f01062bf:	0f 87 b7 00 00 00    	ja     f010637c <OP_SIMD_Suffix+0x112>
    {
      char suffix1 = 'p', suffix2 = 's';
      used_prefixes |= (prefixes & PREFIX_REPZ);
f01062c5:	8b 15 e4 4d 29 f0    	mov    0xf0294de4,%edx
f01062cb:	89 d0                	mov    %edx,%eax
f01062cd:	83 e0 01             	and    $0x1,%eax
f01062d0:	89 c3                	mov    %eax,%ebx
f01062d2:	0b 1d f0 4d 29 f0    	or     0xf0294df0,%ebx
f01062d8:	89 1d f0 4d 29 f0    	mov    %ebx,0xf0294df0
      if (prefixes & PREFIX_REPZ)
f01062de:	be 73 00 00 00       	mov    $0x73,%esi
f01062e3:	b9 73 00 00 00       	mov    $0x73,%ecx
f01062e8:	85 c0                	test   %eax,%eax
f01062ea:	75 3f                	jne    f010632b <OP_SIMD_Suffix+0xc1>
	suffix1 = 's';
      else
	{
	  used_prefixes |= (prefixes & PREFIX_DATA);
f01062ec:	89 d0                	mov    %edx,%eax
f01062ee:	25 00 02 00 00       	and    $0x200,%eax
f01062f3:	09 c3                	or     %eax,%ebx
f01062f5:	89 1d f0 4d 29 f0    	mov    %ebx,0xf0294df0
	  if (prefixes & PREFIX_DATA)
f01062fb:	be 70 00 00 00       	mov    $0x70,%esi
f0106300:	b9 64 00 00 00       	mov    $0x64,%ecx
f0106305:	85 c0                	test   %eax,%eax
f0106307:	75 22                	jne    f010632b <OP_SIMD_Suffix+0xc1>
	    suffix2 = 'd';
	  else
	    {
	      used_prefixes |= (prefixes & PREFIX_REPNZ);
f0106309:	83 e2 02             	and    $0x2,%edx
f010630c:	89 d8                	mov    %ebx,%eax
f010630e:	09 d0                	or     %edx,%eax
f0106310:	a3 f0 4d 29 f0       	mov    %eax,0xf0294df0
	      if (prefixes & PREFIX_REPNZ)
f0106315:	83 fa 01             	cmp    $0x1,%edx
f0106318:	19 f6                	sbb    %esi,%esi
f010631a:	83 e6 fd             	and    $0xfffffffd,%esi
f010631d:	83 c6 73             	add    $0x73,%esi
f0106320:	83 fa 01             	cmp    $0x1,%edx
f0106323:	19 c9                	sbb    %ecx,%ecx
f0106325:	83 e1 0f             	and    $0xf,%ecx
f0106328:	83 c1 64             	add    $0x64,%ecx
		suffix1 = 's', suffix2 = 'd';
	    }
	}
      snprintf (scratchbuf, sizeof(scratchbuf), "cmp%s%c%c",
f010632b:	0f be c1             	movsbl %cl,%eax
f010632e:	89 44 24 14          	mov    %eax,0x14(%esp)
f0106332:	89 f2                	mov    %esi,%edx
f0106334:	0f be c2             	movsbl %dl,%eax
f0106337:	89 44 24 10          	mov    %eax,0x10(%esp)
f010633b:	8b 04 bd 80 35 11 f0 	mov    -0xfeeca80(,%edi,4),%eax
f0106342:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106346:	c7 44 24 08 35 bf 10 	movl   $0xf010bf35,0x8(%esp)
f010634d:	f0 
f010634e:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0106355:	00 
f0106356:	c7 04 24 80 4e 29 f0 	movl   $0xf0294e80,(%esp)
f010635d:	e8 48 30 00 00       	call   f01093aa <snprintf>
                simd_cmp_op[cmp_type], suffix1, suffix2);
      used_prefixes |= (prefixes & PREFIX_REPZ);
f0106362:	a1 e4 4d 29 f0       	mov    0xf0294de4,%eax
f0106367:	83 e0 01             	and    $0x1,%eax
f010636a:	09 05 f0 4d 29 f0    	or     %eax,0xf0294df0
      oappend (scratchbuf);
f0106370:	b8 80 4e 29 f0       	mov    $0xf0294e80,%eax
f0106375:	e8 a3 fe ff ff       	call   f010621d <oappend>
f010637a:	eb 13                	jmp    f010638f <OP_SIMD_Suffix+0x125>
    }
  else
    {
      /* We have a bad extension byte.  Clean up.  */
      op1out[0] = '\0';
f010637c:	c6 05 20 4f 29 f0 00 	movb   $0x0,0xf0294f20
      op2out[0] = '\0';
f0106383:	c6 05 a0 4f 29 f0 00 	movb   $0x0,0xf0294fa0
      BadOp ();
f010638a:	e8 bc fe ff ff       	call   f010624b <BadOp>
    }
}
f010638f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0106392:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0106395:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0106398:	89 ec                	mov    %ebp,%esp
f010639a:	5d                   	pop    %ebp
f010639b:	c3                   	ret    

f010639c <OP_3DNowSuffix>:

static void
OP_3DNowSuffix (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f010639c:	55                   	push   %ebp
f010639d:	89 e5                	mov    %esp,%ebp
f010639f:	83 ec 08             	sub    $0x8,%esp
  const char *mnemonic;

  FETCH_DATA (the_info, codep + 1);
f01063a2:	8b 15 ec 4e 29 f0    	mov    0xf0294eec,%edx
f01063a8:	83 c2 01             	add    $0x1,%edx
f01063ab:	8b 0d f0 4e 29 f0    	mov    0xf0294ef0,%ecx
f01063b1:	8b 41 20             	mov    0x20(%ecx),%eax
f01063b4:	3b 10                	cmp    (%eax),%edx
f01063b6:	76 07                	jbe    f01063bf <OP_3DNowSuffix+0x23>
f01063b8:	89 c8                	mov    %ecx,%eax
f01063ba:	e8 e1 f2 ff ff       	call   f01056a0 <fetch_data>
  /* AMD 3DNow! instructions are specified by an opcode suffix in the
     place where an 8-bit immediate would normally go.  ie. the last
     byte of the instruction.  */
  obufp = obuf + strlen (obuf);
f01063bf:	c7 04 24 00 4e 29 f0 	movl   $0xf0294e00,(%esp)
f01063c6:	e8 15 31 00 00       	call   f01094e0 <strlen>
f01063cb:	05 00 4e 29 f0       	add    $0xf0294e00,%eax
f01063d0:	a3 64 4e 29 f0       	mov    %eax,0xf0294e64
  mnemonic = Suffix3DNow[*codep++ & 0xff];
f01063d5:	a1 ec 4e 29 f0       	mov    0xf0294eec,%eax
f01063da:	0f b6 10             	movzbl (%eax),%edx
f01063dd:	8b 14 95 a0 35 11 f0 	mov    -0xfeeca60(,%edx,4),%edx
f01063e4:	83 c0 01             	add    $0x1,%eax
f01063e7:	a3 ec 4e 29 f0       	mov    %eax,0xf0294eec
  if (mnemonic)
f01063ec:	85 d2                	test   %edx,%edx
f01063ee:	74 09                	je     f01063f9 <OP_3DNowSuffix+0x5d>
    oappend (mnemonic);
f01063f0:	89 d0                	mov    %edx,%eax
f01063f2:	e8 26 fe ff ff       	call   f010621d <oappend>
f01063f7:	eb 13                	jmp    f010640c <OP_3DNowSuffix+0x70>
    {
      /* Since a variable sized modrm/sib chunk is between the start
	 of the opcode (0x0f0f) and the opcode suffix, we need to do
	 all the modrm processing first, and don't know until now that
	 we have a bad opcode.  This necessitates some cleaning up.  */
      op1out[0] = '\0';
f01063f9:	c6 05 20 4f 29 f0 00 	movb   $0x0,0xf0294f20
      op2out[0] = '\0';
f0106400:	c6 05 a0 4f 29 f0 00 	movb   $0x0,0xf0294fa0
      BadOp ();
f0106407:	e8 3f fe ff ff       	call   f010624b <BadOp>
    }
}
f010640c:	c9                   	leave  
f010640d:	c3                   	ret    

f010640e <OP_XMM>:

static void
OP_XMM (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f010640e:	55                   	push   %ebp
f010640f:	89 e5                	mov    %esp,%ebp
f0106411:	83 ec 18             	sub    $0x18,%esp
  int add = 0;
  USED_REX (REX_EXTX);
f0106414:	b8 00 00 00 00       	mov    $0x0,%eax
f0106419:	f6 05 e8 4d 29 f0 04 	testb  $0x4,0xf0294de8
f0106420:	74 09                	je     f010642b <OP_XMM+0x1d>
f0106422:	83 0d ec 4d 29 f0 44 	orl    $0x44,0xf0294dec
f0106429:	b0 08                	mov    $0x8,%al
  if (rex & REX_EXTX)
    add = 8;
  snprintf (scratchbuf, sizeof(scratchbuf), "%%xmm%d", reg + add);
f010642b:	03 05 fc 4e 29 f0    	add    0xf0294efc,%eax
f0106431:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106435:	c7 44 24 08 3f bf 10 	movl   $0xf010bf3f,0x8(%esp)
f010643c:	f0 
f010643d:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0106444:	00 
f0106445:	c7 04 24 80 4e 29 f0 	movl   $0xf0294e80,(%esp)
f010644c:	e8 59 2f 00 00       	call   f01093aa <snprintf>
  oappend (scratchbuf + intel_syntax);
f0106451:	0f be 05 d0 50 29 f0 	movsbl 0xf02950d0,%eax
f0106458:	05 80 4e 29 f0       	add    $0xf0294e80,%eax
f010645d:	e8 bb fd ff ff       	call   f010621d <oappend>
}
f0106462:	c9                   	leave  
f0106463:	c3                   	ret    

f0106464 <OP_MMX>:

static void
OP_MMX (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f0106464:	55                   	push   %ebp
f0106465:	89 e5                	mov    %esp,%ebp
f0106467:	83 ec 18             	sub    $0x18,%esp
  int add = 0;
  USED_REX (REX_EXTX);
f010646a:	ba 00 00 00 00       	mov    $0x0,%edx
f010646f:	f6 05 e8 4d 29 f0 04 	testb  $0x4,0xf0294de8
f0106476:	74 09                	je     f0106481 <OP_MMX+0x1d>
f0106478:	83 0d ec 4d 29 f0 44 	orl    $0x44,0xf0294dec
f010647f:	b2 08                	mov    $0x8,%dl
  if (rex & REX_EXTX)
    add = 8;
  used_prefixes |= (prefixes & PREFIX_DATA);
f0106481:	a1 e4 4d 29 f0       	mov    0xf0294de4,%eax
f0106486:	25 00 02 00 00       	and    $0x200,%eax
f010648b:	09 05 f0 4d 29 f0    	or     %eax,0xf0294df0
  if (prefixes & PREFIX_DATA)
f0106491:	85 c0                	test   %eax,%eax
f0106493:	74 2a                	je     f01064bf <OP_MMX+0x5b>
    snprintf (scratchbuf, sizeof(scratchbuf), "%%xmm%d", reg + add);
f0106495:	89 d0                	mov    %edx,%eax
f0106497:	03 05 fc 4e 29 f0    	add    0xf0294efc,%eax
f010649d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01064a1:	c7 44 24 08 3f bf 10 	movl   $0xf010bf3f,0x8(%esp)
f01064a8:	f0 
f01064a9:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f01064b0:	00 
f01064b1:	c7 04 24 80 4e 29 f0 	movl   $0xf0294e80,(%esp)
f01064b8:	e8 ed 2e 00 00       	call   f01093aa <snprintf>
f01064bd:	eb 28                	jmp    f01064e7 <OP_MMX+0x83>
  else
    snprintf (scratchbuf, sizeof(scratchbuf), "%%mm%d", reg + add);
f01064bf:	89 d0                	mov    %edx,%eax
f01064c1:	03 05 fc 4e 29 f0    	add    0xf0294efc,%eax
f01064c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01064cb:	c7 44 24 08 47 bf 10 	movl   $0xf010bf47,0x8(%esp)
f01064d2:	f0 
f01064d3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f01064da:	00 
f01064db:	c7 04 24 80 4e 29 f0 	movl   $0xf0294e80,(%esp)
f01064e2:	e8 c3 2e 00 00       	call   f01093aa <snprintf>
  oappend (scratchbuf + intel_syntax);
f01064e7:	0f be 05 d0 50 29 f0 	movsbl 0xf02950d0,%eax
f01064ee:	05 80 4e 29 f0       	add    $0xf0294e80,%eax
f01064f3:	e8 25 fd ff ff       	call   f010621d <oappend>
}
f01064f8:	c9                   	leave  
f01064f9:	c3                   	ret    

f01064fa <OP_T>:

static void
OP_T (dummy, sizeflag)
     int dummy;
     int sizeflag;
{
f01064fa:	55                   	push   %ebp
f01064fb:	89 e5                	mov    %esp,%ebp
f01064fd:	83 ec 18             	sub    $0x18,%esp
  snprintf (scratchbuf, sizeof(scratchbuf), "%%tr%d", reg);
f0106500:	a1 fc 4e 29 f0       	mov    0xf0294efc,%eax
f0106505:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106509:	c7 44 24 08 4e bf 10 	movl   $0xf010bf4e,0x8(%esp)
f0106510:	f0 
f0106511:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0106518:	00 
f0106519:	c7 04 24 80 4e 29 f0 	movl   $0xf0294e80,(%esp)
f0106520:	e8 85 2e 00 00       	call   f01093aa <snprintf>
  oappend (scratchbuf + intel_syntax);
f0106525:	0f be 05 d0 50 29 f0 	movsbl 0xf02950d0,%eax
f010652c:	05 80 4e 29 f0       	add    $0xf0294e80,%eax
f0106531:	e8 e7 fc ff ff       	call   f010621d <oappend>
}
f0106536:	c9                   	leave  
f0106537:	c3                   	ret    

f0106538 <OP_D>:

static void
OP_D (dummy, sizeflag)
     int dummy;
     int sizeflag;
{
f0106538:	55                   	push   %ebp
f0106539:	89 e5                	mov    %esp,%ebp
f010653b:	83 ec 18             	sub    $0x18,%esp
  int add = 0;
  USED_REX (REX_EXTX);
f010653e:	b8 00 00 00 00       	mov    $0x0,%eax
f0106543:	f6 05 e8 4d 29 f0 04 	testb  $0x4,0xf0294de8
f010654a:	74 09                	je     f0106555 <OP_D+0x1d>
f010654c:	83 0d ec 4d 29 f0 44 	orl    $0x44,0xf0294dec
f0106553:	b0 08                	mov    $0x8,%al
  if (rex & REX_EXTX)
    add = 8;
  if (intel_syntax)
f0106555:	80 3d d0 50 29 f0 00 	cmpb   $0x0,0xf02950d0
f010655c:	74 28                	je     f0106586 <OP_D+0x4e>
    snprintf (scratchbuf, sizeof(scratchbuf), "db%d", reg + add);
f010655e:	03 05 fc 4e 29 f0    	add    0xf0294efc,%eax
f0106564:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106568:	c7 44 24 08 57 bf 10 	movl   $0xf010bf57,0x8(%esp)
f010656f:	f0 
f0106570:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0106577:	00 
f0106578:	c7 04 24 80 4e 29 f0 	movl   $0xf0294e80,(%esp)
f010657f:	e8 26 2e 00 00       	call   f01093aa <snprintf>
f0106584:	eb 26                	jmp    f01065ac <OP_D+0x74>
  else
    snprintf (scratchbuf, sizeof(scratchbuf), "%%db%d", reg + add);
f0106586:	03 05 fc 4e 29 f0    	add    0xf0294efc,%eax
f010658c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106590:	c7 44 24 08 55 bf 10 	movl   $0xf010bf55,0x8(%esp)
f0106597:	f0 
f0106598:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f010659f:	00 
f01065a0:	c7 04 24 80 4e 29 f0 	movl   $0xf0294e80,(%esp)
f01065a7:	e8 fe 2d 00 00       	call   f01093aa <snprintf>
  oappend (scratchbuf);
f01065ac:	b8 80 4e 29 f0       	mov    $0xf0294e80,%eax
f01065b1:	e8 67 fc ff ff       	call   f010621d <oappend>
}
f01065b6:	c9                   	leave  
f01065b7:	c3                   	ret    

f01065b8 <OP_C>:

static void
OP_C (dummy, sizeflag)
     int dummy;
     int sizeflag;
{
f01065b8:	55                   	push   %ebp
f01065b9:	89 e5                	mov    %esp,%ebp
f01065bb:	83 ec 18             	sub    $0x18,%esp
  int add = 0;
  USED_REX (REX_EXTX);
f01065be:	b8 00 00 00 00       	mov    $0x0,%eax
f01065c3:	f6 05 e8 4d 29 f0 04 	testb  $0x4,0xf0294de8
f01065ca:	74 09                	je     f01065d5 <OP_C+0x1d>
f01065cc:	83 0d ec 4d 29 f0 44 	orl    $0x44,0xf0294dec
f01065d3:	b0 08                	mov    $0x8,%al
  if (rex & REX_EXTX)
    add = 8;
  snprintf (scratchbuf, sizeof(scratchbuf), "%%cr%d", reg + add);
f01065d5:	03 05 fc 4e 29 f0    	add    0xf0294efc,%eax
f01065db:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01065df:	c7 44 24 08 5c bf 10 	movl   $0xf010bf5c,0x8(%esp)
f01065e6:	f0 
f01065e7:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f01065ee:	00 
f01065ef:	c7 04 24 80 4e 29 f0 	movl   $0xf0294e80,(%esp)
f01065f6:	e8 af 2d 00 00       	call   f01093aa <snprintf>
  oappend (scratchbuf + intel_syntax);
f01065fb:	0f be 05 d0 50 29 f0 	movsbl 0xf02950d0,%eax
f0106602:	05 80 4e 29 f0       	add    $0xf0294e80,%eax
f0106607:	e8 11 fc ff ff       	call   f010621d <oappend>
}
f010660c:	c9                   	leave  
f010660d:	c3                   	ret    

f010660e <ptr_reg>:

static void
ptr_reg (code, sizeflag)
     int code;
     int sizeflag;
{
f010660e:	55                   	push   %ebp
f010660f:	89 e5                	mov    %esp,%ebp
f0106611:	56                   	push   %esi
f0106612:	53                   	push   %ebx
f0106613:	89 c3                	mov    %eax,%ebx
f0106615:	89 d6                	mov    %edx,%esi
  const char *s;
  if (intel_syntax)
f0106617:	80 3d d0 50 29 f0 00 	cmpb   $0x0,0xf02950d0
f010661e:	74 0c                	je     f010662c <ptr_reg+0x1e>
    oappend ("[");
f0106620:	b8 63 bf 10 f0       	mov    $0xf010bf63,%eax
f0106625:	e8 f3 fb ff ff       	call   f010621d <oappend>
f010662a:	eb 0a                	jmp    f0106636 <ptr_reg+0x28>
  else
    oappend ("(");
f010662c:	b8 65 bf 10 f0       	mov    $0xf010bf65,%eax
f0106631:	e8 e7 fb ff ff       	call   f010621d <oappend>

  USED_REX (REX_MODE64);
f0106636:	f6 05 e8 4d 29 f0 08 	testb  $0x8,0xf0294de8
f010663d:	74 6b                	je     f01066aa <ptr_reg+0x9c>
f010663f:	83 0d ec 4d 29 f0 48 	orl    $0x48,0xf0294dec
  if (rex & REX_MODE64)
    {
      if (!(sizeflag & AFLAG))
f0106646:	f7 c6 02 00 00 00    	test   $0x2,%esi
f010664c:	75 0e                	jne    f010665c <ptr_reg+0x4e>
        s = names32[code - eAX_reg];
f010664e:	a1 08 4f 29 f0       	mov    0xf0294f08,%eax
f0106653:	8b 84 98 50 fe ff ff 	mov    -0x1b0(%eax,%ebx,4),%eax
f010665a:	eb 28                	jmp    f0106684 <ptr_reg+0x76>
      else
        s = names64[code - eAX_reg];
f010665c:	a1 04 4f 29 f0       	mov    0xf0294f04,%eax
f0106661:	8b 84 98 50 fe ff ff 	mov    -0x1b0(%eax,%ebx,4),%eax
f0106668:	eb 1a                	jmp    f0106684 <ptr_reg+0x76>
    }
  else if (sizeflag & AFLAG)
    s = names32[code - eAX_reg];
f010666a:	a1 08 4f 29 f0       	mov    0xf0294f08,%eax
f010666f:	8b 84 98 50 fe ff ff 	mov    -0x1b0(%eax,%ebx,4),%eax
f0106676:	eb 0c                	jmp    f0106684 <ptr_reg+0x76>
  else
    s = names16[code - eAX_reg];
f0106678:	a1 0c 4f 29 f0       	mov    0xf0294f0c,%eax
f010667d:	8b 84 98 50 fe ff ff 	mov    -0x1b0(%eax,%ebx,4),%eax
  oappend (s);
f0106684:	e8 94 fb ff ff       	call   f010621d <oappend>
  if (intel_syntax)
f0106689:	80 3d d0 50 29 f0 00 	cmpb   $0x0,0xf02950d0
f0106690:	74 0c                	je     f010669e <ptr_reg+0x90>
    oappend ("]");
f0106692:	b8 ac b8 10 f0       	mov    $0xf010b8ac,%eax
f0106697:	e8 81 fb ff ff       	call   f010621d <oappend>
f010669c:	eb 16                	jmp    f01066b4 <ptr_reg+0xa6>
  else
    oappend (")");
f010669e:	b8 65 bb 10 f0       	mov    $0xf010bb65,%eax
f01066a3:	e8 75 fb ff ff       	call   f010621d <oappend>
f01066a8:	eb 0a                	jmp    f01066b4 <ptr_reg+0xa6>
      if (!(sizeflag & AFLAG))
        s = names32[code - eAX_reg];
      else
        s = names64[code - eAX_reg];
    }
  else if (sizeflag & AFLAG)
f01066aa:	f7 c6 02 00 00 00    	test   $0x2,%esi
f01066b0:	75 b8                	jne    f010666a <ptr_reg+0x5c>
f01066b2:	eb c4                	jmp    f0106678 <ptr_reg+0x6a>
  oappend (s);
  if (intel_syntax)
    oappend ("]");
  else
    oappend (")");
}
f01066b4:	5b                   	pop    %ebx
f01066b5:	5e                   	pop    %esi
f01066b6:	5d                   	pop    %ebp
f01066b7:	c3                   	ret    

f01066b8 <OP_ESreg>:

static void
OP_ESreg (code, sizeflag)
     int code;
     int sizeflag;
{
f01066b8:	55                   	push   %ebp
f01066b9:	89 e5                	mov    %esp,%ebp
f01066bb:	83 ec 08             	sub    $0x8,%esp
  oappend ("%es:" + intel_syntax);
f01066be:	0f be 05 d0 50 29 f0 	movsbl 0xf02950d0,%eax
f01066c5:	05 67 bf 10 f0       	add    $0xf010bf67,%eax
f01066ca:	e8 4e fb ff ff       	call   f010621d <oappend>
  ptr_reg (code, sizeflag);
f01066cf:	8b 55 0c             	mov    0xc(%ebp),%edx
f01066d2:	8b 45 08             	mov    0x8(%ebp),%eax
f01066d5:	e8 34 ff ff ff       	call   f010660e <ptr_reg>
}
f01066da:	c9                   	leave  
f01066db:	c3                   	ret    

f01066dc <OP_DIR>:

static void
OP_DIR (dummy, sizeflag)
     int dummy;
     int sizeflag;
{
f01066dc:	55                   	push   %ebp
f01066dd:	89 e5                	mov    %esp,%ebp
f01066df:	53                   	push   %ebx
f01066e0:	83 ec 14             	sub    $0x14,%esp
  int seg, offset;

  if (sizeflag & DFLAG)
f01066e3:	f6 45 0c 01          	testb  $0x1,0xc(%ebp)
f01066e7:	74 10                	je     f01066f9 <OP_DIR+0x1d>
    {
      offset = get32 ();
f01066e9:	e8 14 f2 ff ff       	call   f0105902 <get32>
f01066ee:	89 c3                	mov    %eax,%ebx
      seg = get16 ();
f01066f0:	e8 0c f3 ff ff       	call   f0105a01 <get16>
f01066f5:	89 c2                	mov    %eax,%edx
f01066f7:	eb 0e                	jmp    f0106707 <OP_DIR+0x2b>
    }
  else
    {
      offset = get16 ();
f01066f9:	e8 03 f3 ff ff       	call   f0105a01 <get16>
f01066fe:	89 c3                	mov    %eax,%ebx
      seg = get16 ();
f0106700:	e8 fc f2 ff ff       	call   f0105a01 <get16>
f0106705:	89 c2                	mov    %eax,%edx
    }
  used_prefixes |= (prefixes & PREFIX_DATA);
f0106707:	a1 e4 4d 29 f0       	mov    0xf0294de4,%eax
f010670c:	25 00 02 00 00       	and    $0x200,%eax
f0106711:	09 05 f0 4d 29 f0    	or     %eax,0xf0294df0
  if (intel_syntax)
f0106717:	80 3d d0 50 29 f0 00 	cmpb   $0x0,0xf02950d0
f010671e:	74 26                	je     f0106746 <OP_DIR+0x6a>
    snprintf (scratchbuf, sizeof(scratchbuf), "0x%x,0x%x", seg, offset);
f0106720:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106724:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106728:	c7 44 24 08 6c bf 10 	movl   $0xf010bf6c,0x8(%esp)
f010672f:	f0 
f0106730:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0106737:	00 
f0106738:	c7 04 24 80 4e 29 f0 	movl   $0xf0294e80,(%esp)
f010673f:	e8 66 2c 00 00       	call   f01093aa <snprintf>
f0106744:	eb 24                	jmp    f010676a <OP_DIR+0x8e>
  else
    snprintf (scratchbuf, sizeof(scratchbuf), "$0x%x,$0x%x", seg, offset);
f0106746:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f010674a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010674e:	c7 44 24 08 76 bf 10 	movl   $0xf010bf76,0x8(%esp)
f0106755:	f0 
f0106756:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f010675d:	00 
f010675e:	c7 04 24 80 4e 29 f0 	movl   $0xf0294e80,(%esp)
f0106765:	e8 40 2c 00 00       	call   f01093aa <snprintf>
  oappend (scratchbuf);
f010676a:	b8 80 4e 29 f0       	mov    $0xf0294e80,%eax
f010676f:	e8 a9 fa ff ff       	call   f010621d <oappend>
}
f0106774:	83 c4 14             	add    $0x14,%esp
f0106777:	5b                   	pop    %ebx
f0106778:	5d                   	pop    %ebp
f0106779:	c3                   	ret    

f010677a <OP_SEG>:

static void
OP_SEG (dummy, sizeflag)
     int dummy;
     int sizeflag;
{
f010677a:	55                   	push   %ebp
f010677b:	89 e5                	mov    %esp,%ebp
f010677d:	83 ec 08             	sub    $0x8,%esp
  oappend (names_seg[reg]);
f0106780:	a1 fc 4e 29 f0       	mov    0xf0294efc,%eax
f0106785:	8b 15 18 4f 29 f0    	mov    0xf0294f18,%edx
f010678b:	8b 04 82             	mov    (%edx,%eax,4),%eax
f010678e:	e8 8a fa ff ff       	call   f010621d <oappend>
}
f0106793:	c9                   	leave  
f0106794:	c3                   	ret    

f0106795 <OP_J>:

static void
OP_J (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f0106795:	55                   	push   %ebp
f0106796:	89 e5                	mov    %esp,%ebp
f0106798:	56                   	push   %esi
f0106799:	53                   	push   %ebx
f010679a:	83 ec 10             	sub    $0x10,%esp
f010679d:	8b 45 08             	mov    0x8(%ebp),%eax
  bfd_vma disp;
  bfd_vma mask = -1;

  switch (bytemode)
f01067a0:	83 f8 01             	cmp    $0x1,%eax
f01067a3:	74 0b                	je     f01067b0 <OP_J+0x1b>
f01067a5:	83 f8 02             	cmp    $0x2,%eax
f01067a8:	0f 85 8c 00 00 00    	jne    f010683a <OP_J+0xa5>
f01067ae:	eb 4f                	jmp    f01067ff <OP_J+0x6a>
    {
    case b_mode:
      FETCH_DATA (the_info, codep + 1);
f01067b0:	8b 15 ec 4e 29 f0    	mov    0xf0294eec,%edx
f01067b6:	83 c2 01             	add    $0x1,%edx
f01067b9:	8b 0d f0 4e 29 f0    	mov    0xf0294ef0,%ecx
f01067bf:	8b 41 20             	mov    0x20(%ecx),%eax
f01067c2:	3b 10                	cmp    (%eax),%edx
f01067c4:	76 07                	jbe    f01067cd <OP_J+0x38>
f01067c6:	89 c8                	mov    %ecx,%eax
f01067c8:	e8 d3 ee ff ff       	call   f01056a0 <fetch_data>
      disp = *codep++;
f01067cd:	a1 ec 4e 29 f0       	mov    0xf0294eec,%eax
f01067d2:	0f b6 08             	movzbl (%eax),%ecx
f01067d5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01067da:	83 c0 01             	add    $0x1,%eax
f01067dd:	a3 ec 4e 29 f0       	mov    %eax,0xf0294eec
	  mask = 0xffff;
	}
      break;
    default:
      oappend (INTERNAL_DISASSEMBLER_ERROR);
      return;
f01067e2:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
f01067e9:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  switch (bytemode)
    {
    case b_mode:
      FETCH_DATA (the_info, codep + 1);
      disp = *codep++;
      if ((disp & 0x80) != 0)
f01067f0:	84 c9                	test   %cl,%cl
f01067f2:	79 52                	jns    f0106846 <OP_J+0xb1>
	disp -= 0x100;
f01067f4:	81 c1 00 ff ff ff    	add    $0xffffff00,%ecx
f01067fa:	83 d3 ff             	adc    $0xffffffff,%ebx
f01067fd:	eb 47                	jmp    f0106846 <OP_J+0xb1>
      break;
    case v_mode:
      if (sizeflag & DFLAG)
f01067ff:	f6 45 0c 01          	testb  $0x1,0xc(%ebp)
f0106803:	74 19                	je     f010681e <OP_J+0x89>
	disp = get32s ();
f0106805:	e8 71 f1 ff ff       	call   f010597b <get32s>
f010680a:	89 c1                	mov    %eax,%ecx
f010680c:	89 d3                	mov    %edx,%ebx
f010680e:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
f0106815:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
f010681c:	eb 28                	jmp    f0106846 <OP_J+0xb1>
      else
	{
	  disp = get16 ();
f010681e:	e8 de f1 ff ff       	call   f0105a01 <get16>
f0106823:	89 c1                	mov    %eax,%ecx
f0106825:	89 c3                	mov    %eax,%ebx
f0106827:	c1 fb 1f             	sar    $0x1f,%ebx
f010682a:	c7 45 f0 ff ff 00 00 	movl   $0xffff,-0x10(%ebp)
f0106831:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0106838:	eb 0c                	jmp    f0106846 <OP_J+0xb1>
	     displacement is added!  */
	  mask = 0xffff;
	}
      break;
    default:
      oappend (INTERNAL_DISASSEMBLER_ERROR);
f010683a:	b8 82 bf 10 f0       	mov    $0xf010bf82,%eax
f010683f:	e8 d9 f9 ff ff       	call   f010621d <oappend>
f0106844:	eb 57                	jmp    f010689d <OP_J+0x108>
      return;
    }
  disp = (start_pc + codep - start_codep + disp) & mask;
f0106846:	a1 ec 4e 29 f0       	mov    0xf0294eec,%eax
f010684b:	03 05 c8 50 29 f0    	add    0xf02950c8,%eax
f0106851:	2b 05 e4 4e 29 f0    	sub    0xf0294ee4,%eax
f0106857:	89 c2                	mov    %eax,%edx
f0106859:	c1 fa 1f             	sar    $0x1f,%edx
f010685c:	89 de                	mov    %ebx,%esi
f010685e:	89 cb                	mov    %ecx,%ebx
f0106860:	01 c3                	add    %eax,%ebx
f0106862:	11 d6                	adc    %edx,%esi
f0106864:	23 5d f0             	and    -0x10(%ebp),%ebx
f0106867:	23 75 f4             	and    -0xc(%ebp),%esi
  set_op (disp, 0);
f010686a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010686f:	89 d8                	mov    %ebx,%eax
f0106871:	89 f2                	mov    %esi,%edx
f0106873:	e8 c9 f1 ff ff       	call   f0105a41 <set_op>
  print_operand_value (scratchbuf, sizeof(scratchbuf), 1, disp);
f0106878:	89 1c 24             	mov    %ebx,(%esp)
f010687b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010687f:	b9 01 00 00 00       	mov    $0x1,%ecx
f0106884:	ba 64 00 00 00       	mov    $0x64,%edx
f0106889:	b8 80 4e 29 f0       	mov    $0xf0294e80,%eax
f010688e:	e8 c9 f7 ff ff       	call   f010605c <print_operand_value>
  oappend (scratchbuf);
f0106893:	b8 80 4e 29 f0       	mov    $0xf0294e80,%eax
f0106898:	e8 80 f9 ff ff       	call   f010621d <oappend>
}
f010689d:	83 c4 10             	add    $0x10,%esp
f01068a0:	5b                   	pop    %ebx
f01068a1:	5e                   	pop    %esi
f01068a2:	5d                   	pop    %ebp
f01068a3:	c3                   	ret    

f01068a4 <OP_sI>:

static void
OP_sI (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f01068a4:	55                   	push   %ebp
f01068a5:	89 e5                	mov    %esp,%ebp
f01068a7:	83 ec 08             	sub    $0x8,%esp
f01068aa:	8b 45 08             	mov    0x8(%ebp),%eax
  bfd_signed_vma op;
  bfd_signed_vma mask = -1;

  switch (bytemode)
f01068ad:	83 f8 02             	cmp    $0x2,%eax
f01068b0:	74 57                	je     f0106909 <OP_sI+0x65>
f01068b2:	83 f8 03             	cmp    $0x3,%eax
f01068b5:	0f 84 a4 00 00 00    	je     f010695f <OP_sI+0xbb>
f01068bb:	83 f8 01             	cmp    $0x1,%eax
f01068be:	0f 85 b7 00 00 00    	jne    f010697b <OP_sI+0xd7>
    {
    case b_mode:
      FETCH_DATA (the_info, codep + 1);
f01068c4:	8b 15 ec 4e 29 f0    	mov    0xf0294eec,%edx
f01068ca:	83 c2 01             	add    $0x1,%edx
f01068cd:	8b 0d f0 4e 29 f0    	mov    0xf0294ef0,%ecx
f01068d3:	8b 41 20             	mov    0x20(%ecx),%eax
f01068d6:	3b 10                	cmp    (%eax),%edx
f01068d8:	76 07                	jbe    f01068e1 <OP_sI+0x3d>
f01068da:	89 c8                	mov    %ecx,%eax
f01068dc:	e8 bf ed ff ff       	call   f01056a0 <fetch_data>
      op = *codep++;
f01068e1:	a1 ec 4e 29 f0       	mov    0xf0294eec,%eax
f01068e6:	0f b6 10             	movzbl (%eax),%edx
f01068e9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01068ee:	83 c0 01             	add    $0x1,%eax
f01068f1:	a3 ec 4e 29 f0       	mov    %eax,0xf0294eec
      if ((op & 0x80) != 0)
f01068f6:	84 d2                	test   %dl,%dl
f01068f8:	0f 89 89 00 00 00    	jns    f0106987 <OP_sI+0xe3>
	op -= 0x100;
f01068fe:	81 c2 00 ff ff ff    	add    $0xffffff00,%edx
f0106904:	83 d1 ff             	adc    $0xffffffff,%ecx
f0106907:	eb 7e                	jmp    f0106987 <OP_sI+0xe3>
      mask = 0xffffffff;
      break;
    case v_mode:
      USED_REX (REX_MODE64);
f0106909:	f6 05 e8 4d 29 f0 08 	testb  $0x8,0xf0294de8
f0106910:	0f 84 a6 00 00 00    	je     f01069bc <OP_sI+0x118>
f0106916:	83 0d ec 4d 29 f0 48 	orl    $0x48,0xf0294dec
      if (rex & REX_MODE64)
	op = get32s ();
f010691d:	e8 59 f0 ff ff       	call   f010597b <get32s>
f0106922:	89 d1                	mov    %edx,%ecx
f0106924:	89 c2                	mov    %eax,%edx
f0106926:	eb 25                	jmp    f010694d <OP_sI+0xa9>
      else if (sizeflag & DFLAG)
	{
	  op = get32s ();
f0106928:	e8 4e f0 ff ff       	call   f010597b <get32s>
f010692d:	89 d1                	mov    %edx,%ecx
f010692f:	89 c2                	mov    %eax,%edx
f0106931:	eb 1a                	jmp    f010694d <OP_sI+0xa9>
	  mask = 0xffffffff;
	}
      else
	{
	  mask = 0xffffffff;
	  op = get16 ();
f0106933:	e8 c9 f0 ff ff       	call   f0105a01 <get16>
f0106938:	89 c2                	mov    %eax,%edx
f010693a:	89 c1                	mov    %eax,%ecx
f010693c:	c1 f9 1f             	sar    $0x1f,%ecx
	  if ((op & 0x8000) != 0)
f010693f:	66 85 c0             	test   %ax,%ax
f0106942:	79 09                	jns    f010694d <OP_sI+0xa9>
	    op -= 0x10000;
f0106944:	81 c2 00 00 ff ff    	add    $0xffff0000,%edx
f010694a:	83 d1 ff             	adc    $0xffffffff,%ecx
	}
      used_prefixes |= (prefixes & PREFIX_DATA);
f010694d:	a1 e4 4d 29 f0       	mov    0xf0294de4,%eax
f0106952:	25 00 02 00 00       	and    $0x200,%eax
f0106957:	09 05 f0 4d 29 f0    	or     %eax,0xf0294df0
f010695d:	eb 28                	jmp    f0106987 <OP_sI+0xe3>
      break;
    case w_mode:
      op = get16 ();
f010695f:	e8 9d f0 ff ff       	call   f0105a01 <get16>
f0106964:	89 c2                	mov    %eax,%edx
f0106966:	89 c1                	mov    %eax,%ecx
f0106968:	c1 f9 1f             	sar    $0x1f,%ecx
      mask = 0xffffffff;
      if ((op & 0x8000) != 0)
f010696b:	66 85 c0             	test   %ax,%ax
f010696e:	79 17                	jns    f0106987 <OP_sI+0xe3>
	op -= 0x10000;
f0106970:	81 c2 00 00 ff ff    	add    $0xffff0000,%edx
f0106976:	83 d1 ff             	adc    $0xffffffff,%ecx
f0106979:	eb 0c                	jmp    f0106987 <OP_sI+0xe3>
      break;
    default:
      oappend (INTERNAL_DISASSEMBLER_ERROR);
f010697b:	b8 82 bf 10 f0       	mov    $0xf010bf82,%eax
f0106980:	e8 98 f8 ff ff       	call   f010621d <oappend>
f0106985:	eb 44                	jmp    f01069cb <OP_sI+0x127>
      return;
    }

  scratchbuf[0] = '$';
f0106987:	c6 05 80 4e 29 f0 24 	movb   $0x24,0xf0294e80
  print_operand_value (scratchbuf + 1, sizeof(scratchbuf) - 1, 1, op);
f010698e:	89 14 24             	mov    %edx,(%esp)
f0106991:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106995:	b9 01 00 00 00       	mov    $0x1,%ecx
f010699a:	ba 63 00 00 00       	mov    $0x63,%edx
f010699f:	b8 81 4e 29 f0       	mov    $0xf0294e81,%eax
f01069a4:	e8 b3 f6 ff ff       	call   f010605c <print_operand_value>
  oappend (scratchbuf + intel_syntax);
f01069a9:	0f be 05 d0 50 29 f0 	movsbl 0xf02950d0,%eax
f01069b0:	05 80 4e 29 f0       	add    $0xf0294e80,%eax
f01069b5:	e8 63 f8 ff ff       	call   f010621d <oappend>
f01069ba:	eb 0f                	jmp    f01069cb <OP_sI+0x127>
      break;
    case v_mode:
      USED_REX (REX_MODE64);
      if (rex & REX_MODE64)
	op = get32s ();
      else if (sizeflag & DFLAG)
f01069bc:	f6 45 0c 01          	testb  $0x1,0xc(%ebp)
f01069c0:	0f 85 62 ff ff ff    	jne    f0106928 <OP_sI+0x84>
f01069c6:	e9 68 ff ff ff       	jmp    f0106933 <OP_sI+0x8f>
    }

  scratchbuf[0] = '$';
  print_operand_value (scratchbuf + 1, sizeof(scratchbuf) - 1, 1, op);
  oappend (scratchbuf + intel_syntax);
}
f01069cb:	c9                   	leave  
f01069cc:	8d 74 26 00          	lea    0x0(%esi),%esi
f01069d0:	c3                   	ret    

f01069d1 <OP_I>:

static void
OP_I (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f01069d1:	55                   	push   %ebp
f01069d2:	89 e5                	mov    %esp,%ebp
f01069d4:	83 ec 18             	sub    $0x18,%esp
f01069d7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01069da:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01069dd:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01069e0:	8b 45 08             	mov    0x8(%ebp),%eax
  bfd_signed_vma op;
  bfd_signed_vma mask = -1;

  switch (bytemode)
f01069e3:	83 f8 02             	cmp    $0x2,%eax
f01069e6:	0f 84 8e 00 00 00    	je     f0106a7a <OP_I+0xa9>
f01069ec:	83 f8 02             	cmp    $0x2,%eax
f01069ef:	7f 11                	jg     f0106a02 <OP_I+0x31>
f01069f1:	83 f8 01             	cmp    $0x1,%eax
f01069f4:	0f 85 fe 00 00 00    	jne    f0106af8 <OP_I+0x127>
f01069fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106a00:	eb 16                	jmp    f0106a18 <OP_I+0x47>
f0106a02:	83 f8 03             	cmp    $0x3,%eax
f0106a05:	0f 84 d5 00 00 00    	je     f0106ae0 <OP_I+0x10f>
f0106a0b:	83 f8 05             	cmp    $0x5,%eax
f0106a0e:	66 90                	xchg   %ax,%ax
f0106a10:	0f 85 e2 00 00 00    	jne    f0106af8 <OP_I+0x127>
f0106a16:	eb 41                	jmp    f0106a59 <OP_I+0x88>
    {
    case b_mode:
      FETCH_DATA (the_info, codep + 1);
f0106a18:	8b 15 ec 4e 29 f0    	mov    0xf0294eec,%edx
f0106a1e:	83 c2 01             	add    $0x1,%edx
f0106a21:	8b 0d f0 4e 29 f0    	mov    0xf0294ef0,%ecx
f0106a27:	8b 41 20             	mov    0x20(%ecx),%eax
f0106a2a:	3b 10                	cmp    (%eax),%edx
f0106a2c:	76 07                	jbe    f0106a35 <OP_I+0x64>
f0106a2e:	89 c8                	mov    %ecx,%eax
f0106a30:	e8 6b ec ff ff       	call   f01056a0 <fetch_data>
      op = *codep++;
f0106a35:	a1 ec 4e 29 f0       	mov    0xf0294eec,%eax
f0106a3a:	0f b6 08             	movzbl (%eax),%ecx
f0106a3d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106a42:	83 c0 01             	add    $0x1,%eax
f0106a45:	a3 ec 4e 29 f0       	mov    %eax,0xf0294eec
f0106a4a:	be ff 00 00 00       	mov    $0xff,%esi
f0106a4f:	bf 00 00 00 00       	mov    $0x0,%edi
f0106a54:	e9 ab 00 00 00       	jmp    f0106b04 <OP_I+0x133>
      mask = 0xff;
      break;
    case q_mode:
      if (mode_64bit)
f0106a59:	83 3d e0 4d 29 f0 00 	cmpl   $0x0,0xf0294de0
f0106a60:	74 18                	je     f0106a7a <OP_I+0xa9>
	{
	  op = get32s ();
f0106a62:	e8 14 ef ff ff       	call   f010597b <get32s>
f0106a67:	89 c1                	mov    %eax,%ecx
f0106a69:	89 d3                	mov    %edx,%ebx
f0106a6b:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0106a70:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0106a75:	e9 8a 00 00 00       	jmp    f0106b04 <OP_I+0x133>
	  break;
	}
      /* Fall through.  */
    case v_mode:
      USED_REX (REX_MODE64);
f0106a7a:	f6 05 e8 4d 29 f0 08 	testb  $0x8,0xf0294de8
f0106a81:	0f 84 c1 00 00 00    	je     f0106b48 <OP_I+0x177>
f0106a87:	83 0d ec 4d 29 f0 48 	orl    $0x48,0xf0294dec
      if (rex & REX_MODE64)
	op = get32s ();
f0106a8e:	e8 e8 ee ff ff       	call   f010597b <get32s>
f0106a93:	89 c1                	mov    %eax,%ecx
f0106a95:	89 d3                	mov    %edx,%ebx
f0106a97:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0106a9c:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0106aa1:	eb 2b                	jmp    f0106ace <OP_I+0xfd>
      else if (sizeflag & DFLAG)
	{
	  op = get32 ();
f0106aa3:	e8 5a ee ff ff       	call   f0105902 <get32>
f0106aa8:	89 c1                	mov    %eax,%ecx
f0106aaa:	89 d3                	mov    %edx,%ebx
f0106aac:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0106ab1:	bf 00 00 00 00       	mov    $0x0,%edi
f0106ab6:	eb 16                	jmp    f0106ace <OP_I+0xfd>
	  mask = 0xffffffff;
	}
      else
	{
	  op = get16 ();
f0106ab8:	e8 44 ef ff ff       	call   f0105a01 <get16>
f0106abd:	89 c1                	mov    %eax,%ecx
f0106abf:	89 c3                	mov    %eax,%ebx
f0106ac1:	c1 fb 1f             	sar    $0x1f,%ebx
f0106ac4:	be ff ff 0f 00       	mov    $0xfffff,%esi
f0106ac9:	bf 00 00 00 00       	mov    $0x0,%edi
	  mask = 0xfffff;
	}
      used_prefixes |= (prefixes & PREFIX_DATA);
f0106ace:	a1 e4 4d 29 f0       	mov    0xf0294de4,%eax
f0106ad3:	25 00 02 00 00       	and    $0x200,%eax
f0106ad8:	09 05 f0 4d 29 f0    	or     %eax,0xf0294df0
f0106ade:	eb 24                	jmp    f0106b04 <OP_I+0x133>
      break;
    case w_mode:
      mask = 0xfffff;
      op = get16 ();
f0106ae0:	e8 1c ef ff ff       	call   f0105a01 <get16>
f0106ae5:	89 c1                	mov    %eax,%ecx
f0106ae7:	89 c3                	mov    %eax,%ebx
f0106ae9:	c1 fb 1f             	sar    $0x1f,%ebx
f0106aec:	be ff ff 0f 00       	mov    $0xfffff,%esi
f0106af1:	bf 00 00 00 00       	mov    $0x0,%edi
f0106af6:	eb 0c                	jmp    f0106b04 <OP_I+0x133>
      break;
    default:
      oappend (INTERNAL_DISASSEMBLER_ERROR);
f0106af8:	b8 82 bf 10 f0       	mov    $0xf010bf82,%eax
f0106afd:	e8 1b f7 ff ff       	call   f010621d <oappend>
f0106b02:	eb 53                	jmp    f0106b57 <OP_I+0x186>
      return;
    }

  op &= mask;
  scratchbuf[0] = '$';
f0106b04:	c6 05 80 4e 29 f0 24 	movb   $0x24,0xf0294e80
  print_operand_value (scratchbuf + 1, sizeof(scratchbuf) - 1, 1, op);
f0106b0b:	89 f0                	mov    %esi,%eax
f0106b0d:	21 c8                	and    %ecx,%eax
f0106b0f:	89 fa                	mov    %edi,%edx
f0106b11:	21 da                	and    %ebx,%edx
f0106b13:	89 04 24             	mov    %eax,(%esp)
f0106b16:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106b1a:	b9 01 00 00 00       	mov    $0x1,%ecx
f0106b1f:	ba 63 00 00 00       	mov    $0x63,%edx
f0106b24:	b8 81 4e 29 f0       	mov    $0xf0294e81,%eax
f0106b29:	e8 2e f5 ff ff       	call   f010605c <print_operand_value>
  oappend (scratchbuf + intel_syntax);
f0106b2e:	0f be 05 d0 50 29 f0 	movsbl 0xf02950d0,%eax
f0106b35:	05 80 4e 29 f0       	add    $0xf0294e80,%eax
f0106b3a:	e8 de f6 ff ff       	call   f010621d <oappend>
  scratchbuf[0] = '\0';
f0106b3f:	c6 05 80 4e 29 f0 00 	movb   $0x0,0xf0294e80
f0106b46:	eb 0f                	jmp    f0106b57 <OP_I+0x186>
      /* Fall through.  */
    case v_mode:
      USED_REX (REX_MODE64);
      if (rex & REX_MODE64)
	op = get32s ();
      else if (sizeflag & DFLAG)
f0106b48:	f6 45 0c 01          	testb  $0x1,0xc(%ebp)
f0106b4c:	0f 85 51 ff ff ff    	jne    f0106aa3 <OP_I+0xd2>
f0106b52:	e9 61 ff ff ff       	jmp    f0106ab8 <OP_I+0xe7>
  op &= mask;
  scratchbuf[0] = '$';
  print_operand_value (scratchbuf + 1, sizeof(scratchbuf) - 1, 1, op);
  oappend (scratchbuf + intel_syntax);
  scratchbuf[0] = '\0';
}
f0106b57:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0106b5a:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0106b5d:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0106b60:	89 ec                	mov    %ebp,%esp
f0106b62:	5d                   	pop    %ebp
f0106b63:	c3                   	ret    

f0106b64 <OP_I64>:

static void
OP_I64 (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f0106b64:	55                   	push   %ebp
f0106b65:	89 e5                	mov    %esp,%ebp
f0106b67:	83 ec 18             	sub    $0x18,%esp
f0106b6a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0106b6d:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0106b70:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0106b73:	8b 45 08             	mov    0x8(%ebp),%eax
  bfd_signed_vma op;
  bfd_signed_vma mask = -1;

  if (!mode_64bit)
f0106b76:	83 3d e0 4d 29 f0 00 	cmpl   $0x0,0xf0294de0
f0106b7d:	75 14                	jne    f0106b93 <OP_I64+0x2f>
    {
      OP_I (bytemode, sizeflag);
f0106b7f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106b82:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106b86:	89 04 24             	mov    %eax,(%esp)
f0106b89:	e8 43 fe ff ff       	call   f01069d1 <OP_I>
f0106b8e:	e9 3a 01 00 00       	jmp    f0106ccd <OP_I64+0x169>
      return;
    }

  switch (bytemode)
f0106b93:	83 f8 02             	cmp    $0x2,%eax
f0106b96:	74 58                	je     f0106bf0 <OP_I64+0x8c>
f0106b98:	83 f8 03             	cmp    $0x3,%eax
f0106b9b:	90                   	nop    
f0106b9c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0106ba0:	0f 84 b0 00 00 00    	je     f0106c56 <OP_I64+0xf2>
f0106ba6:	83 f8 01             	cmp    $0x1,%eax
f0106ba9:	0f 85 bf 00 00 00    	jne    f0106c6e <OP_I64+0x10a>
    {
    case b_mode:
      FETCH_DATA (the_info, codep + 1);
f0106baf:	8b 15 ec 4e 29 f0    	mov    0xf0294eec,%edx
f0106bb5:	83 c2 01             	add    $0x1,%edx
f0106bb8:	8b 0d f0 4e 29 f0    	mov    0xf0294ef0,%ecx
f0106bbe:	8b 41 20             	mov    0x20(%ecx),%eax
f0106bc1:	3b 10                	cmp    (%eax),%edx
f0106bc3:	76 07                	jbe    f0106bcc <OP_I64+0x68>
f0106bc5:	89 c8                	mov    %ecx,%eax
f0106bc7:	e8 d4 ea ff ff       	call   f01056a0 <fetch_data>
      op = *codep++;
f0106bcc:	a1 ec 4e 29 f0       	mov    0xf0294eec,%eax
f0106bd1:	0f b6 08             	movzbl (%eax),%ecx
f0106bd4:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106bd9:	83 c0 01             	add    $0x1,%eax
f0106bdc:	a3 ec 4e 29 f0       	mov    %eax,0xf0294eec
f0106be1:	be ff 00 00 00       	mov    $0xff,%esi
f0106be6:	bf 00 00 00 00       	mov    $0x0,%edi
f0106beb:	e9 8a 00 00 00       	jmp    f0106c7a <OP_I64+0x116>
      mask = 0xff;
      break;
    case v_mode:
      USED_REX (REX_MODE64);
f0106bf0:	f6 05 e8 4d 29 f0 08 	testb  $0x8,0xf0294de8
f0106bf7:	0f 84 c1 00 00 00    	je     f0106cbe <OP_I64+0x15a>
f0106bfd:	83 0d ec 4d 29 f0 48 	orl    $0x48,0xf0294dec
      if (rex & REX_MODE64)
	op = get64 ();
f0106c04:	e8 64 ec ff ff       	call   f010586d <get64>
f0106c09:	89 c1                	mov    %eax,%ecx
f0106c0b:	89 d3                	mov    %edx,%ebx
f0106c0d:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0106c12:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0106c17:	eb 2b                	jmp    f0106c44 <OP_I64+0xe0>
      else if (sizeflag & DFLAG)
	{
	  op = get32 ();
f0106c19:	e8 e4 ec ff ff       	call   f0105902 <get32>
f0106c1e:	89 c1                	mov    %eax,%ecx
f0106c20:	89 d3                	mov    %edx,%ebx
f0106c22:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0106c27:	bf 00 00 00 00       	mov    $0x0,%edi
f0106c2c:	eb 16                	jmp    f0106c44 <OP_I64+0xe0>
	  mask = 0xffffffff;
	}
      else
	{
	  op = get16 ();
f0106c2e:	e8 ce ed ff ff       	call   f0105a01 <get16>
f0106c33:	89 c1                	mov    %eax,%ecx
f0106c35:	89 c3                	mov    %eax,%ebx
f0106c37:	c1 fb 1f             	sar    $0x1f,%ebx
f0106c3a:	be ff ff 0f 00       	mov    $0xfffff,%esi
f0106c3f:	bf 00 00 00 00       	mov    $0x0,%edi
	  mask = 0xfffff;
	}
      used_prefixes |= (prefixes & PREFIX_DATA);
f0106c44:	a1 e4 4d 29 f0       	mov    0xf0294de4,%eax
f0106c49:	25 00 02 00 00       	and    $0x200,%eax
f0106c4e:	09 05 f0 4d 29 f0    	or     %eax,0xf0294df0
f0106c54:	eb 24                	jmp    f0106c7a <OP_I64+0x116>
      break;
    case w_mode:
      mask = 0xfffff;
      op = get16 ();
f0106c56:	e8 a6 ed ff ff       	call   f0105a01 <get16>
f0106c5b:	89 c1                	mov    %eax,%ecx
f0106c5d:	89 c3                	mov    %eax,%ebx
f0106c5f:	c1 fb 1f             	sar    $0x1f,%ebx
f0106c62:	be ff ff 0f 00       	mov    $0xfffff,%esi
f0106c67:	bf 00 00 00 00       	mov    $0x0,%edi
f0106c6c:	eb 0c                	jmp    f0106c7a <OP_I64+0x116>
      break;
    default:
      oappend (INTERNAL_DISASSEMBLER_ERROR);
f0106c6e:	b8 82 bf 10 f0       	mov    $0xf010bf82,%eax
f0106c73:	e8 a5 f5 ff ff       	call   f010621d <oappend>
f0106c78:	eb 53                	jmp    f0106ccd <OP_I64+0x169>
      return;
    }

  op &= mask;
  scratchbuf[0] = '$';
f0106c7a:	c6 05 80 4e 29 f0 24 	movb   $0x24,0xf0294e80
  print_operand_value (scratchbuf + 1, sizeof(scratchbuf) - 1, 1, op);
f0106c81:	89 f0                	mov    %esi,%eax
f0106c83:	21 c8                	and    %ecx,%eax
f0106c85:	89 fa                	mov    %edi,%edx
f0106c87:	21 da                	and    %ebx,%edx
f0106c89:	89 04 24             	mov    %eax,(%esp)
f0106c8c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106c90:	b9 01 00 00 00       	mov    $0x1,%ecx
f0106c95:	ba 63 00 00 00       	mov    $0x63,%edx
f0106c9a:	b8 81 4e 29 f0       	mov    $0xf0294e81,%eax
f0106c9f:	e8 b8 f3 ff ff       	call   f010605c <print_operand_value>
  oappend (scratchbuf + intel_syntax);
f0106ca4:	0f be 05 d0 50 29 f0 	movsbl 0xf02950d0,%eax
f0106cab:	05 80 4e 29 f0       	add    $0xf0294e80,%eax
f0106cb0:	e8 68 f5 ff ff       	call   f010621d <oappend>
  scratchbuf[0] = '\0';
f0106cb5:	c6 05 80 4e 29 f0 00 	movb   $0x0,0xf0294e80
f0106cbc:	eb 0f                	jmp    f0106ccd <OP_I64+0x169>
      break;
    case v_mode:
      USED_REX (REX_MODE64);
      if (rex & REX_MODE64)
	op = get64 ();
      else if (sizeflag & DFLAG)
f0106cbe:	f6 45 0c 01          	testb  $0x1,0xc(%ebp)
f0106cc2:	0f 85 51 ff ff ff    	jne    f0106c19 <OP_I64+0xb5>
f0106cc8:	e9 61 ff ff ff       	jmp    f0106c2e <OP_I64+0xca>
  op &= mask;
  scratchbuf[0] = '$';
  print_operand_value (scratchbuf + 1, sizeof(scratchbuf) - 1, 1, op);
  oappend (scratchbuf + intel_syntax);
  scratchbuf[0] = '\0';
}
f0106ccd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0106cd0:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0106cd3:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0106cd6:	89 ec                	mov    %ebp,%esp
f0106cd8:	5d                   	pop    %ebp
f0106cd9:	c3                   	ret    

f0106cda <OP_IMREG>:

static void
OP_IMREG (code, sizeflag)
     int code;
     int sizeflag;
{
f0106cda:	55                   	push   %ebp
f0106cdb:	89 e5                	mov    %esp,%ebp
f0106cdd:	83 ec 08             	sub    $0x8,%esp
f0106ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  const char *s;

  switch (code)
f0106ce3:	8d 42 9c             	lea    -0x64(%edx),%eax
f0106ce6:	83 f8 32             	cmp    $0x32,%eax
f0106ce9:	77 07                	ja     f0106cf2 <OP_IMREG+0x18>
f0106ceb:	ff 24 85 8c d5 10 f0 	jmp    *-0xfef2a74(,%eax,4)
f0106cf2:	ba 82 bf 10 f0       	mov    $0xf010bf82,%edx
f0106cf7:	e9 af 00 00 00       	jmp    f0106dab <OP_IMREG+0xd1>
    {
    case indir_dx_reg:
      if (intel_syntax)
f0106cfc:	ba a0 bf 10 f0       	mov    $0xf010bfa0,%edx
f0106d01:	80 3d d0 50 29 f0 00 	cmpb   $0x0,0xf02950d0
f0106d08:	0f 85 9d 00 00 00    	jne    f0106dab <OP_IMREG+0xd1>
f0106d0e:	ba a5 bf 10 f0       	mov    $0xf010bfa5,%edx
f0106d13:	e9 93 00 00 00       	jmp    f0106dab <OP_IMREG+0xd1>
      else
        s = "(%dx)";
      break;
    case ax_reg: case cx_reg: case dx_reg: case bx_reg:
    case sp_reg: case bp_reg: case si_reg: case di_reg:
      s = names16[code - ax_reg];
f0106d18:	a1 0c 4f 29 f0       	mov    0xf0294f0c,%eax
f0106d1d:	8b 94 90 10 fe ff ff 	mov    -0x1f0(%eax,%edx,4),%edx
f0106d24:	e9 82 00 00 00       	jmp    f0106dab <OP_IMREG+0xd1>
      break;
    case es_reg: case ss_reg: case cs_reg:
    case ds_reg: case fs_reg: case gs_reg:
      s = names_seg[code - es_reg];
f0106d29:	a1 18 4f 29 f0       	mov    0xf0294f18,%eax
f0106d2e:	8b 94 90 70 fe ff ff 	mov    -0x190(%eax,%edx,4),%edx
f0106d35:	eb 74                	jmp    f0106dab <OP_IMREG+0xd1>
      break;
    case al_reg: case ah_reg: case cl_reg: case ch_reg:
    case dl_reg: case dh_reg: case bl_reg: case bh_reg:
      USED_REX (0);
f0106d37:	83 0d ec 4d 29 f0 40 	orl    $0x40,0xf0294dec
      if (rex)
f0106d3e:	83 3d e8 4d 29 f0 00 	cmpl   $0x0,0xf0294de8
f0106d45:	74 0e                	je     f0106d55 <OP_IMREG+0x7b>
	s = names8rex[code - al_reg];
f0106d47:	a1 14 4f 29 f0       	mov    0xf0294f14,%eax
f0106d4c:	8b 94 90 30 fe ff ff 	mov    -0x1d0(%eax,%edx,4),%edx
f0106d53:	eb 56                	jmp    f0106dab <OP_IMREG+0xd1>
      else
	s = names8[code - al_reg];
f0106d55:	a1 10 4f 29 f0       	mov    0xf0294f10,%eax
f0106d5a:	8b 94 90 30 fe ff ff 	mov    -0x1d0(%eax,%edx,4),%edx
f0106d61:	eb 48                	jmp    f0106dab <OP_IMREG+0xd1>
      break;
    case eAX_reg: case eCX_reg: case eDX_reg: case eBX_reg:
    case eSP_reg: case eBP_reg: case eSI_reg: case eDI_reg:
      USED_REX (REX_MODE64);
f0106d63:	f6 05 e8 4d 29 f0 08 	testb  $0x8,0xf0294de8
f0106d6a:	74 48                	je     f0106db4 <OP_IMREG+0xda>
f0106d6c:	83 0d ec 4d 29 f0 48 	orl    $0x48,0xf0294dec
      if (rex & REX_MODE64)
	s = names64[code - eAX_reg];
f0106d73:	a1 04 4f 29 f0       	mov    0xf0294f04,%eax
f0106d78:	8b 94 90 50 fe ff ff 	mov    -0x1b0(%eax,%edx,4),%edx
f0106d7f:	eb 1a                	jmp    f0106d9b <OP_IMREG+0xc1>
      else if (sizeflag & DFLAG)
	s = names32[code - eAX_reg];
f0106d81:	a1 08 4f 29 f0       	mov    0xf0294f08,%eax
f0106d86:	8b 94 90 50 fe ff ff 	mov    -0x1b0(%eax,%edx,4),%edx
f0106d8d:	eb 0c                	jmp    f0106d9b <OP_IMREG+0xc1>
      else
	s = names16[code - eAX_reg];
f0106d8f:	a1 0c 4f 29 f0       	mov    0xf0294f0c,%eax
f0106d94:	8b 94 90 50 fe ff ff 	mov    -0x1b0(%eax,%edx,4),%edx
      used_prefixes |= (prefixes & PREFIX_DATA);
f0106d9b:	a1 e4 4d 29 f0       	mov    0xf0294de4,%eax
f0106da0:	25 00 02 00 00       	and    $0x200,%eax
f0106da5:	09 05 f0 4d 29 f0    	or     %eax,0xf0294df0
      break;
    default:
      s = INTERNAL_DISASSEMBLER_ERROR;
      break;
    }
  oappend (s);
f0106dab:	89 d0                	mov    %edx,%eax
f0106dad:	e8 6b f4 ff ff       	call   f010621d <oappend>
}
f0106db2:	c9                   	leave  
f0106db3:	c3                   	ret    
    case eAX_reg: case eCX_reg: case eDX_reg: case eBX_reg:
    case eSP_reg: case eBP_reg: case eSI_reg: case eDI_reg:
      USED_REX (REX_MODE64);
      if (rex & REX_MODE64)
	s = names64[code - eAX_reg];
      else if (sizeflag & DFLAG)
f0106db4:	f6 45 0c 01          	testb  $0x1,0xc(%ebp)
f0106db8:	75 c7                	jne    f0106d81 <OP_IMREG+0xa7>
f0106dba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106dc0:	eb cd                	jmp    f0106d8f <OP_IMREG+0xb5>

f0106dc2 <OP_REG>:

static void
OP_REG (code, sizeflag)
     int code;
     int sizeflag;
{
f0106dc2:	55                   	push   %ebp
f0106dc3:	89 e5                	mov    %esp,%ebp
f0106dc5:	83 ec 08             	sub    $0x8,%esp
f0106dc8:	89 1c 24             	mov    %ebx,(%esp)
f0106dcb:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106dcf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  const char *s;
  int add = 0;
  USED_REX (REX_EXTZ);
f0106dd2:	8b 0d e8 4d 29 f0    	mov    0xf0294de8,%ecx
f0106dd8:	f6 c1 01             	test   $0x1,%cl
f0106ddb:	0f 84 05 01 00 00    	je     f0106ee6 <OP_REG+0x124>
f0106de1:	a1 ec 4d 29 f0       	mov    0xf0294dec,%eax
f0106de6:	83 c8 41             	or     $0x41,%eax
f0106de9:	a3 ec 4d 29 f0       	mov    %eax,0xf0294dec
f0106dee:	be 08 00 00 00       	mov    $0x8,%esi
  if (rex & REX_EXTZ)
    add = 8;

  switch (code)
f0106df3:	8d 53 9c             	lea    -0x64(%ebx),%edx
f0106df6:	83 fa 32             	cmp    $0x32,%edx
f0106df9:	77 07                	ja     f0106e02 <OP_REG+0x40>
f0106dfb:	ff 24 95 58 d6 10 f0 	jmp    *-0xfef29a8(,%edx,4)
f0106e02:	ba 82 bf 10 f0       	mov    $0xf010bf82,%edx
f0106e07:	e9 c8 00 00 00       	jmp    f0106ed4 <OP_REG+0x112>
    {
    case indir_dx_reg:
      if (intel_syntax)
f0106e0c:	ba a0 bf 10 f0       	mov    $0xf010bfa0,%edx
f0106e11:	80 3d d0 50 29 f0 00 	cmpb   $0x0,0xf02950d0
f0106e18:	0f 85 b6 00 00 00    	jne    f0106ed4 <OP_REG+0x112>
f0106e1e:	ba a5 bf 10 f0       	mov    $0xf010bfa5,%edx
f0106e23:	e9 ac 00 00 00       	jmp    f0106ed4 <OP_REG+0x112>
      else
        s = "(%dx)";
      break;
    case ax_reg: case cx_reg: case dx_reg: case bx_reg:
    case sp_reg: case bp_reg: case si_reg: case di_reg:
      s = names16[code - ax_reg + add];
f0106e28:	8d 54 1e 84          	lea    -0x7c(%esi,%ebx,1),%edx
f0106e2c:	a1 0c 4f 29 f0       	mov    0xf0294f0c,%eax
f0106e31:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0106e34:	e9 9b 00 00 00       	jmp    f0106ed4 <OP_REG+0x112>
      break;
    case es_reg: case ss_reg: case cs_reg:
    case ds_reg: case fs_reg: case gs_reg:
      s = names_seg[code - es_reg + add];
f0106e39:	8d 54 1e 9c          	lea    -0x64(%esi,%ebx,1),%edx
f0106e3d:	a1 18 4f 29 f0       	mov    0xf0294f18,%eax
f0106e42:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0106e45:	e9 8a 00 00 00       	jmp    f0106ed4 <OP_REG+0x112>
      break;
    case al_reg: case ah_reg: case cl_reg: case ch_reg:
    case dl_reg: case dh_reg: case bl_reg: case bh_reg:
      USED_REX (0);
f0106e4a:	83 c8 40             	or     $0x40,%eax
f0106e4d:	a3 ec 4d 29 f0       	mov    %eax,0xf0294dec
      if (rex)
f0106e52:	85 c9                	test   %ecx,%ecx
f0106e54:	74 0e                	je     f0106e64 <OP_REG+0xa2>
	s = names8rex[code - al_reg + add];
f0106e56:	8d 54 1e 8c          	lea    -0x74(%esi,%ebx,1),%edx
f0106e5a:	a1 14 4f 29 f0       	mov    0xf0294f14,%eax
f0106e5f:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0106e62:	eb 70                	jmp    f0106ed4 <OP_REG+0x112>
      else
	s = names8[code - al_reg];
f0106e64:	a1 10 4f 29 f0       	mov    0xf0294f10,%eax
f0106e69:	8b 94 98 30 fe ff ff 	mov    -0x1d0(%eax,%ebx,4),%edx
f0106e70:	eb 62                	jmp    f0106ed4 <OP_REG+0x112>
      break;
    case rAX_reg: case rCX_reg: case rDX_reg: case rBX_reg:
    case rSP_reg: case rBP_reg: case rSI_reg: case rDI_reg:
      if (mode_64bit)
f0106e72:	83 3d e0 4d 29 f0 00 	cmpl   $0x0,0xf0294de0
f0106e79:	74 11                	je     f0106e8c <OP_REG+0xca>
	{
	  s = names64[code - rAX_reg + add];
f0106e7b:	8d 94 1e 7c ff ff ff 	lea    -0x84(%esi,%ebx,1),%edx
f0106e82:	a1 04 4f 29 f0       	mov    0xf0294f04,%eax
f0106e87:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0106e8a:	eb 48                	jmp    f0106ed4 <OP_REG+0x112>
	  break;
	}
      code += eAX_reg - rAX_reg;
f0106e8c:	83 eb 18             	sub    $0x18,%ebx
      /* Fall through.  */
    case eAX_reg: case eCX_reg: case eDX_reg: case eBX_reg:
    case eSP_reg: case eBP_reg: case eSI_reg: case eDI_reg:
      USED_REX (REX_MODE64);
f0106e8f:	f6 c1 08             	test   $0x8,%cl
f0106e92:	74 61                	je     f0106ef5 <OP_REG+0x133>
f0106e94:	83 c8 48             	or     $0x48,%eax
f0106e97:	a3 ec 4d 29 f0       	mov    %eax,0xf0294dec
      if (rex & REX_MODE64)
	s = names64[code - eAX_reg + add];
f0106e9c:	8d 54 1e 94          	lea    -0x6c(%esi,%ebx,1),%edx
f0106ea0:	a1 04 4f 29 f0       	mov    0xf0294f04,%eax
f0106ea5:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0106ea8:	eb 1a                	jmp    f0106ec4 <OP_REG+0x102>
      else if (sizeflag & DFLAG)
	s = names32[code - eAX_reg + add];
f0106eaa:	8d 54 1e 94          	lea    -0x6c(%esi,%ebx,1),%edx
f0106eae:	a1 08 4f 29 f0       	mov    0xf0294f08,%eax
f0106eb3:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0106eb6:	eb 0c                	jmp    f0106ec4 <OP_REG+0x102>
      else
	s = names16[code - eAX_reg + add];
f0106eb8:	8d 54 1e 94          	lea    -0x6c(%esi,%ebx,1),%edx
f0106ebc:	a1 0c 4f 29 f0       	mov    0xf0294f0c,%eax
f0106ec1:	8b 14 90             	mov    (%eax,%edx,4),%edx
      used_prefixes |= (prefixes & PREFIX_DATA);
f0106ec4:	a1 e4 4d 29 f0       	mov    0xf0294de4,%eax
f0106ec9:	25 00 02 00 00       	and    $0x200,%eax
f0106ece:	09 05 f0 4d 29 f0    	or     %eax,0xf0294df0
      break;
    default:
      s = INTERNAL_DISASSEMBLER_ERROR;
      break;
    }
  oappend (s);
f0106ed4:	89 d0                	mov    %edx,%eax
f0106ed6:	e8 42 f3 ff ff       	call   f010621d <oappend>
}
f0106edb:	8b 1c 24             	mov    (%esp),%ebx
f0106ede:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106ee2:	89 ec                	mov    %ebp,%esp
f0106ee4:	5d                   	pop    %ebp
f0106ee5:	c3                   	ret    
     int code;
     int sizeflag;
{
  const char *s;
  int add = 0;
  USED_REX (REX_EXTZ);
f0106ee6:	a1 ec 4d 29 f0       	mov    0xf0294dec,%eax
f0106eeb:	be 00 00 00 00       	mov    $0x0,%esi
f0106ef0:	e9 fe fe ff ff       	jmp    f0106df3 <OP_REG+0x31>
	}
      code += eAX_reg - rAX_reg;
      /* Fall through.  */
    case eAX_reg: case eCX_reg: case eDX_reg: case eBX_reg:
    case eSP_reg: case eBP_reg: case eSI_reg: case eDI_reg:
      USED_REX (REX_MODE64);
f0106ef5:	a3 ec 4d 29 f0       	mov    %eax,0xf0294dec
      if (rex & REX_MODE64)
	s = names64[code - eAX_reg + add];
      else if (sizeflag & DFLAG)
f0106efa:	f6 45 0c 01          	testb  $0x1,0xc(%ebp)
f0106efe:	75 aa                	jne    f0106eaa <OP_REG+0xe8>
f0106f00:	eb b6                	jmp    f0106eb8 <OP_REG+0xf6>

f0106f02 <OP_G>:

static void
OP_G (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f0106f02:	55                   	push   %ebp
f0106f03:	89 e5                	mov    %esp,%ebp
f0106f05:	53                   	push   %ebx
f0106f06:	83 ec 04             	sub    $0x4,%esp
f0106f09:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int add = 0;
  USED_REX (REX_EXTX);
f0106f0c:	8b 0d e8 4d 29 f0    	mov    0xf0294de8,%ecx
f0106f12:	f6 c1 04             	test   $0x4,%cl
f0106f15:	0f 84 23 01 00 00    	je     f010703e <OP_G+0x13c>
f0106f1b:	a1 ec 4d 29 f0       	mov    0xf0294dec,%eax
f0106f20:	83 c8 44             	or     $0x44,%eax
f0106f23:	a3 ec 4d 29 f0       	mov    %eax,0xf0294dec
f0106f28:	ba 08 00 00 00       	mov    $0x8,%edx
  if (rex & REX_EXTX)
    add += 8;
  switch (bytemode)
f0106f2d:	83 fb 05             	cmp    $0x5,%ebx
f0106f30:	0f 87 fc 00 00 00    	ja     f0107032 <OP_G+0x130>
f0106f36:	ff 24 9d 24 d7 10 f0 	jmp    *-0xfef28dc(,%ebx,4)
    {
    case b_mode:
      USED_REX (0);
f0106f3d:	83 c8 40             	or     $0x40,%eax
f0106f40:	a3 ec 4d 29 f0       	mov    %eax,0xf0294dec
      if (rex)
f0106f45:	85 c9                	test   %ecx,%ecx
f0106f47:	74 1b                	je     f0106f64 <OP_G+0x62>
	oappend (names8rex[reg + add]);
f0106f49:	89 d0                	mov    %edx,%eax
f0106f4b:	03 05 fc 4e 29 f0    	add    0xf0294efc,%eax
f0106f51:	8b 15 14 4f 29 f0    	mov    0xf0294f14,%edx
f0106f57:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0106f5a:	e8 be f2 ff ff       	call   f010621d <oappend>
f0106f5f:	e9 f6 00 00 00       	jmp    f010705a <OP_G+0x158>
      else
	oappend (names8[reg + add]);
f0106f64:	89 d0                	mov    %edx,%eax
f0106f66:	03 05 fc 4e 29 f0    	add    0xf0294efc,%eax
f0106f6c:	8b 15 10 4f 29 f0    	mov    0xf0294f10,%edx
f0106f72:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0106f75:	e8 a3 f2 ff ff       	call   f010621d <oappend>
f0106f7a:	e9 db 00 00 00       	jmp    f010705a <OP_G+0x158>
      break;
    case w_mode:
      oappend (names16[reg + add]);
f0106f7f:	89 d0                	mov    %edx,%eax
f0106f81:	03 05 fc 4e 29 f0    	add    0xf0294efc,%eax
f0106f87:	8b 15 0c 4f 29 f0    	mov    0xf0294f0c,%edx
f0106f8d:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0106f90:	e8 88 f2 ff ff       	call   f010621d <oappend>
f0106f95:	e9 c0 00 00 00       	jmp    f010705a <OP_G+0x158>
      break;
    case d_mode:
      oappend (names32[reg + add]);
f0106f9a:	89 d0                	mov    %edx,%eax
f0106f9c:	03 05 fc 4e 29 f0    	add    0xf0294efc,%eax
f0106fa2:	8b 15 08 4f 29 f0    	mov    0xf0294f08,%edx
f0106fa8:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0106fab:	e8 6d f2 ff ff       	call   f010621d <oappend>
f0106fb0:	e9 a5 00 00 00       	jmp    f010705a <OP_G+0x158>
      break;
    case q_mode:
      oappend (names64[reg + add]);
f0106fb5:	89 d0                	mov    %edx,%eax
f0106fb7:	03 05 fc 4e 29 f0    	add    0xf0294efc,%eax
f0106fbd:	8b 15 04 4f 29 f0    	mov    0xf0294f04,%edx
f0106fc3:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0106fc6:	e8 52 f2 ff ff       	call   f010621d <oappend>
f0106fcb:	e9 8a 00 00 00       	jmp    f010705a <OP_G+0x158>
      break;
    case v_mode:
      USED_REX (REX_MODE64);
f0106fd0:	f6 c1 08             	test   $0x8,%cl
f0106fd3:	74 78                	je     f010704d <OP_G+0x14b>
f0106fd5:	83 c8 48             	or     $0x48,%eax
f0106fd8:	a3 ec 4d 29 f0       	mov    %eax,0xf0294dec
      if (rex & REX_MODE64)
	oappend (names64[reg + add]);
f0106fdd:	03 15 fc 4e 29 f0    	add    0xf0294efc,%edx
f0106fe3:	a1 04 4f 29 f0       	mov    0xf0294f04,%eax
f0106fe8:	8b 04 90             	mov    (%eax,%edx,4),%eax
f0106feb:	e8 2d f2 ff ff       	call   f010621d <oappend>
f0106ff0:	eb 2e                	jmp    f0107020 <OP_G+0x11e>
      else if (sizeflag & DFLAG)
	oappend (names32[reg + add]);
f0106ff2:	89 d0                	mov    %edx,%eax
f0106ff4:	03 05 fc 4e 29 f0    	add    0xf0294efc,%eax
f0106ffa:	8b 15 08 4f 29 f0    	mov    0xf0294f08,%edx
f0107000:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0107003:	e8 15 f2 ff ff       	call   f010621d <oappend>
f0107008:	eb 16                	jmp    f0107020 <OP_G+0x11e>
      else
	oappend (names16[reg + add]);
f010700a:	89 d0                	mov    %edx,%eax
f010700c:	03 05 fc 4e 29 f0    	add    0xf0294efc,%eax
f0107012:	8b 15 0c 4f 29 f0    	mov    0xf0294f0c,%edx
f0107018:	8b 04 82             	mov    (%edx,%eax,4),%eax
f010701b:	e8 fd f1 ff ff       	call   f010621d <oappend>
      used_prefixes |= (prefixes & PREFIX_DATA);
f0107020:	a1 e4 4d 29 f0       	mov    0xf0294de4,%eax
f0107025:	25 00 02 00 00       	and    $0x200,%eax
f010702a:	09 05 f0 4d 29 f0    	or     %eax,0xf0294df0
f0107030:	eb 28                	jmp    f010705a <OP_G+0x158>
      break;
    default:
      oappend (INTERNAL_DISASSEMBLER_ERROR);
f0107032:	b8 82 bf 10 f0       	mov    $0xf010bf82,%eax
f0107037:	e8 e1 f1 ff ff       	call   f010621d <oappend>
f010703c:	eb 1c                	jmp    f010705a <OP_G+0x158>
OP_G (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
  int add = 0;
  USED_REX (REX_EXTX);
f010703e:	a1 ec 4d 29 f0       	mov    0xf0294dec,%eax
f0107043:	ba 00 00 00 00       	mov    $0x0,%edx
f0107048:	e9 e0 fe ff ff       	jmp    f0106f2d <OP_G+0x2b>
      break;
    case q_mode:
      oappend (names64[reg + add]);
      break;
    case v_mode:
      USED_REX (REX_MODE64);
f010704d:	a3 ec 4d 29 f0       	mov    %eax,0xf0294dec
      if (rex & REX_MODE64)
	oappend (names64[reg + add]);
      else if (sizeflag & DFLAG)
f0107052:	f6 45 0c 01          	testb  $0x1,0xc(%ebp)
f0107056:	75 9a                	jne    f0106ff2 <OP_G+0xf0>
f0107058:	eb b0                	jmp    f010700a <OP_G+0x108>
      break;
    default:
      oappend (INTERNAL_DISASSEMBLER_ERROR);
      break;
    }
}
f010705a:	83 c4 04             	add    $0x4,%esp
f010705d:	5b                   	pop    %ebx
f010705e:	5d                   	pop    %ebp
f010705f:	c3                   	ret    

f0107060 <append_seg>:
  obufp += strlen (s);
}

static void
append_seg ()
{
f0107060:	55                   	push   %ebp
f0107061:	89 e5                	mov    %esp,%ebp
f0107063:	83 ec 08             	sub    $0x8,%esp
  if (prefixes & PREFIX_CS)
f0107066:	f6 05 e4 4d 29 f0 08 	testb  $0x8,0xf0294de4
f010706d:	74 18                	je     f0107087 <append_seg+0x27>
    {
      used_prefixes |= PREFIX_CS;
f010706f:	83 0d f0 4d 29 f0 08 	orl    $0x8,0xf0294df0
      oappend ("%cs:" + intel_syntax);
f0107076:	0f be 05 d0 50 29 f0 	movsbl 0xf02950d0,%eax
f010707d:	05 ab bf 10 f0       	add    $0xf010bfab,%eax
f0107082:	e8 96 f1 ff ff       	call   f010621d <oappend>
    }
  if (prefixes & PREFIX_DS)
f0107087:	f6 05 e4 4d 29 f0 20 	testb  $0x20,0xf0294de4
f010708e:	74 18                	je     f01070a8 <append_seg+0x48>
    {
      used_prefixes |= PREFIX_DS;
f0107090:	83 0d f0 4d 29 f0 20 	orl    $0x20,0xf0294df0
      oappend ("%ds:" + intel_syntax);
f0107097:	0f be 05 d0 50 29 f0 	movsbl 0xf02950d0,%eax
f010709e:	05 b0 bf 10 f0       	add    $0xf010bfb0,%eax
f01070a3:	e8 75 f1 ff ff       	call   f010621d <oappend>
    }
  if (prefixes & PREFIX_SS)
f01070a8:	f6 05 e4 4d 29 f0 10 	testb  $0x10,0xf0294de4
f01070af:	74 18                	je     f01070c9 <append_seg+0x69>
    {
      used_prefixes |= PREFIX_SS;
f01070b1:	83 0d f0 4d 29 f0 10 	orl    $0x10,0xf0294df0
      oappend ("%ss:" + intel_syntax);
f01070b8:	0f be 05 d0 50 29 f0 	movsbl 0xf02950d0,%eax
f01070bf:	05 b5 bf 10 f0       	add    $0xf010bfb5,%eax
f01070c4:	e8 54 f1 ff ff       	call   f010621d <oappend>
    }
  if (prefixes & PREFIX_ES)
f01070c9:	f6 05 e4 4d 29 f0 40 	testb  $0x40,0xf0294de4
f01070d0:	74 18                	je     f01070ea <append_seg+0x8a>
    {
      used_prefixes |= PREFIX_ES;
f01070d2:	83 0d f0 4d 29 f0 40 	orl    $0x40,0xf0294df0
      oappend ("%es:" + intel_syntax);
f01070d9:	0f be 05 d0 50 29 f0 	movsbl 0xf02950d0,%eax
f01070e0:	05 67 bf 10 f0       	add    $0xf010bf67,%eax
f01070e5:	e8 33 f1 ff ff       	call   f010621d <oappend>
    }
  if (prefixes & PREFIX_FS)
f01070ea:	80 3d e4 4d 29 f0 00 	cmpb   $0x0,0xf0294de4
f01070f1:	79 1b                	jns    f010710e <append_seg+0xae>
    {
      used_prefixes |= PREFIX_FS;
f01070f3:	81 0d f0 4d 29 f0 80 	orl    $0x80,0xf0294df0
f01070fa:	00 00 00 
      oappend ("%fs:" + intel_syntax);
f01070fd:	0f be 05 d0 50 29 f0 	movsbl 0xf02950d0,%eax
f0107104:	05 ba bf 10 f0       	add    $0xf010bfba,%eax
f0107109:	e8 0f f1 ff ff       	call   f010621d <oappend>
    }
  if (prefixes & PREFIX_GS)
f010710e:	f6 05 e5 4d 29 f0 01 	testb  $0x1,0xf0294de5
f0107115:	74 1b                	je     f0107132 <append_seg+0xd2>
    {
      used_prefixes |= PREFIX_GS;
f0107117:	81 0d f0 4d 29 f0 00 	orl    $0x100,0xf0294df0
f010711e:	01 00 00 
      oappend ("%gs:" + intel_syntax);
f0107121:	0f be 05 d0 50 29 f0 	movsbl 0xf02950d0,%eax
f0107128:	05 bf bf 10 f0       	add    $0xf010bfbf,%eax
f010712d:	e8 eb f0 ff ff       	call   f010621d <oappend>
    }
}
f0107132:	c9                   	leave  
f0107133:	c3                   	ret    

f0107134 <OP_DSreg>:

static void
OP_DSreg (code, sizeflag)
     int code;
     int sizeflag;
{
f0107134:	55                   	push   %ebp
f0107135:	89 e5                	mov    %esp,%ebp
f0107137:	83 ec 08             	sub    $0x8,%esp
  if ((prefixes
f010713a:	a1 e4 4d 29 f0       	mov    0xf0294de4,%eax
f010713f:	a9 f8 01 00 00       	test   $0x1f8,%eax
f0107144:	75 08                	jne    f010714e <OP_DSreg+0x1a>
	  | PREFIX_DS
	  | PREFIX_SS
	  | PREFIX_ES
	  | PREFIX_FS
	  | PREFIX_GS)) == 0)
    prefixes |= PREFIX_DS;
f0107146:	83 c8 20             	or     $0x20,%eax
f0107149:	a3 e4 4d 29 f0       	mov    %eax,0xf0294de4
  append_seg ();
f010714e:	e8 0d ff ff ff       	call   f0107060 <append_seg>
  ptr_reg (code, sizeflag);
f0107153:	8b 55 0c             	mov    0xc(%ebp),%edx
f0107156:	8b 45 08             	mov    0x8(%ebp),%eax
f0107159:	e8 b0 f4 ff ff       	call   f010660e <ptr_reg>
}
f010715e:	c9                   	leave  
f010715f:	c3                   	ret    

f0107160 <OP_OFF64>:

static void
OP_OFF64 (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f0107160:	55                   	push   %ebp
f0107161:	89 e5                	mov    %esp,%ebp
f0107163:	83 ec 18             	sub    $0x18,%esp
f0107166:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0107169:	89 75 fc             	mov    %esi,-0x4(%ebp)
  bfd_vma off;

  if (!mode_64bit)
f010716c:	83 3d e0 4d 29 f0 00 	cmpl   $0x0,0xf0294de0
f0107173:	75 7e                	jne    f01071f3 <OP_OFF64+0x93>
     int bytemode;
     int sizeflag;
{
  bfd_vma off;

  append_seg ();
f0107175:	e8 e6 fe ff ff       	call   f0107060 <append_seg>

  if ((sizeflag & AFLAG) || mode_64bit)
f010717a:	f6 45 0c 02          	testb  $0x2,0xc(%ebp)
f010717e:	75 09                	jne    f0107189 <OP_OFF64+0x29>
f0107180:	83 3d e0 4d 29 f0 00 	cmpl   $0x0,0xf0294de0
f0107187:	74 0b                	je     f0107194 <OP_OFF64+0x34>
    off = get32 ();
f0107189:	e8 74 e7 ff ff       	call   f0105902 <get32>
f010718e:	89 c3                	mov    %eax,%ebx
f0107190:	89 d6                	mov    %edx,%esi
f0107192:	eb 0c                	jmp    f01071a0 <OP_OFF64+0x40>
  else
    off = get16 ();
f0107194:	e8 68 e8 ff ff       	call   f0105a01 <get16>
f0107199:	89 c3                	mov    %eax,%ebx
f010719b:	89 c6                	mov    %eax,%esi
f010719d:	c1 fe 1f             	sar    $0x1f,%esi

  if (intel_syntax)
f01071a0:	80 3d d0 50 29 f0 00 	cmpb   $0x0,0xf02950d0
f01071a7:	74 23                	je     f01071cc <OP_OFF64+0x6c>
    {
      if (!(prefixes & (PREFIX_CS | PREFIX_SS | PREFIX_DS
f01071a9:	f7 05 e4 4d 29 f0 f8 	testl  $0x1f8,0xf0294de4
f01071b0:	01 00 00 
f01071b3:	75 17                	jne    f01071cc <OP_OFF64+0x6c>
		        | PREFIX_ES | PREFIX_FS | PREFIX_GS)))
	{
	  oappend (names_seg[ds_reg - es_reg]);
f01071b5:	a1 18 4f 29 f0       	mov    0xf0294f18,%eax
f01071ba:	8b 40 0c             	mov    0xc(%eax),%eax
f01071bd:	e8 5b f0 ff ff       	call   f010621d <oappend>
	  oappend (":");
f01071c2:	b8 ae bf 10 f0       	mov    $0xf010bfae,%eax
f01071c7:	e8 51 f0 ff ff       	call   f010621d <oappend>
	}
    }
  print_operand_value (scratchbuf, sizeof(scratchbuf), 1, off);
f01071cc:	89 1c 24             	mov    %ebx,(%esp)
f01071cf:	89 74 24 04          	mov    %esi,0x4(%esp)
f01071d3:	b9 01 00 00 00       	mov    $0x1,%ecx
f01071d8:	ba 64 00 00 00       	mov    $0x64,%edx
f01071dd:	b8 80 4e 29 f0       	mov    $0xf0294e80,%eax
f01071e2:	e8 75 ee ff ff       	call   f010605c <print_operand_value>
  oappend (scratchbuf);
f01071e7:	b8 80 4e 29 f0       	mov    $0xf0294e80,%eax
f01071ec:	e8 2c f0 ff ff       	call   f010621d <oappend>
f01071f1:	eb 67                	jmp    f010725a <OP_OFF64+0xfa>
    {
      OP_OFF (bytemode, sizeflag);
      return;
    }

  append_seg ();
f01071f3:	e8 68 fe ff ff       	call   f0107060 <append_seg>

  off = get64 ();
f01071f8:	90                   	nop    
f01071f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
f0107200:	e8 68 e6 ff ff       	call   f010586d <get64>
f0107205:	89 c3                	mov    %eax,%ebx
f0107207:	89 d6                	mov    %edx,%esi

  if (intel_syntax)
f0107209:	80 3d d0 50 29 f0 00 	cmpb   $0x0,0xf02950d0
f0107210:	74 23                	je     f0107235 <OP_OFF64+0xd5>
    {
      if (!(prefixes & (PREFIX_CS | PREFIX_SS | PREFIX_DS
f0107212:	f7 05 e4 4d 29 f0 f8 	testl  $0x1f8,0xf0294de4
f0107219:	01 00 00 
f010721c:	75 17                	jne    f0107235 <OP_OFF64+0xd5>
		        | PREFIX_ES | PREFIX_FS | PREFIX_GS)))
	{
	  oappend (names_seg[ds_reg - es_reg]);
f010721e:	a1 18 4f 29 f0       	mov    0xf0294f18,%eax
f0107223:	8b 40 0c             	mov    0xc(%eax),%eax
f0107226:	e8 f2 ef ff ff       	call   f010621d <oappend>
	  oappend (":");
f010722b:	b8 ae bf 10 f0       	mov    $0xf010bfae,%eax
f0107230:	e8 e8 ef ff ff       	call   f010621d <oappend>
	}
    }
  print_operand_value (scratchbuf, sizeof(scratchbuf), 1, off);
f0107235:	89 1c 24             	mov    %ebx,(%esp)
f0107238:	89 74 24 04          	mov    %esi,0x4(%esp)
f010723c:	b9 01 00 00 00       	mov    $0x1,%ecx
f0107241:	ba 64 00 00 00       	mov    $0x64,%edx
f0107246:	b8 80 4e 29 f0       	mov    $0xf0294e80,%eax
f010724b:	e8 0c ee ff ff       	call   f010605c <print_operand_value>
  oappend (scratchbuf);
f0107250:	b8 80 4e 29 f0       	mov    $0xf0294e80,%eax
f0107255:	e8 c3 ef ff ff       	call   f010621d <oappend>
}
f010725a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f010725d:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0107260:	89 ec                	mov    %ebp,%esp
f0107262:	5d                   	pop    %ebp
f0107263:	c3                   	ret    

f0107264 <OP_E>:

static void
OP_E (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f0107264:	55                   	push   %ebp
f0107265:	89 e5                	mov    %esp,%ebp
f0107267:	57                   	push   %edi
f0107268:	56                   	push   %esi
f0107269:	53                   	push   %ebx
f010726a:	83 ec 2c             	sub    $0x2c,%esp
  bfd_vma disp;
  int add = 0;
  int riprel = 0;
  USED_REX (REX_EXTZ);
f010726d:	8b 0d e8 4d 29 f0    	mov    0xf0294de8,%ecx
f0107273:	f6 c1 01             	test   $0x1,%cl
f0107276:	0f 84 d3 08 00 00    	je     f0107b4f <OP_E+0x8eb>
f010727c:	a1 ec 4d 29 f0       	mov    0xf0294dec,%eax
f0107281:	83 c8 41             	or     $0x41,%eax
f0107284:	a3 ec 4d 29 f0       	mov    %eax,0xf0294dec
f0107289:	bb 08 00 00 00       	mov    $0x8,%ebx
  if (rex & REX_EXTZ)
    add += 8;

  /* Skip mod/rm byte.  */
  MODRM_CHECK;
f010728e:	80 3d 00 4f 29 f0 00 	cmpb   $0x0,0xf0294f00
f0107295:	75 1c                	jne    f01072b3 <OP_E+0x4f>
f0107297:	c7 44 24 08 c4 bf 10 	movl   $0xf010bfc4,0x8(%esp)
f010729e:	f0 
f010729f:	c7 44 24 04 b3 0b 00 	movl   $0xbb3,0x4(%esp)
f01072a6:	00 
f01072a7:	c7 04 24 07 bf 10 f0 	movl   $0xf010bf07,(%esp)
f01072ae:	e8 d3 8d ff ff       	call   f0100086 <_panic>
  codep++;
f01072b3:	8b 15 ec 4e 29 f0    	mov    0xf0294eec,%edx
f01072b9:	83 c2 01             	add    $0x1,%edx
f01072bc:	89 15 ec 4e 29 f0    	mov    %edx,0xf0294eec

  if (mod == 3)
f01072c2:	83 3d f4 4e 29 f0 03 	cmpl   $0x3,0xf0294ef4
f01072c9:	0f 85 8c 01 00 00    	jne    f010745b <OP_E+0x1f7>
    {
      switch (bytemode)
f01072cf:	83 7d 08 07          	cmpl   $0x7,0x8(%ebp)
f01072d3:	0f 87 73 01 00 00    	ja     f010744c <OP_E+0x1e8>
f01072d9:	8b 75 08             	mov    0x8(%ebp),%esi
f01072dc:	ff 24 b5 3c d7 10 f0 	jmp    *-0xfef28c4(,%esi,4)
	{
	case b_mode:
	  USED_REX (0);
f01072e3:	83 c8 40             	or     $0x40,%eax
f01072e6:	a3 ec 4d 29 f0       	mov    %eax,0xf0294dec
	  if (rex)
f01072eb:	85 c9                	test   %ecx,%ecx
f01072ed:	74 1b                	je     f010730a <OP_E+0xa6>
	    oappend (names8rex[rm + add]);
f01072ef:	89 d8                	mov    %ebx,%eax
f01072f1:	03 05 f8 4e 29 f0    	add    0xf0294ef8,%eax
f01072f7:	8b 15 14 4f 29 f0    	mov    0xf0294f14,%edx
f01072fd:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0107300:	e8 18 ef ff ff       	call   f010621d <oappend>
f0107305:	e9 83 08 00 00       	jmp    f0107b8d <OP_E+0x929>
	  else
	    oappend (names8[rm + add]);
f010730a:	89 d8                	mov    %ebx,%eax
f010730c:	03 05 f8 4e 29 f0    	add    0xf0294ef8,%eax
f0107312:	8b 15 10 4f 29 f0    	mov    0xf0294f10,%edx
f0107318:	8b 04 82             	mov    (%edx,%eax,4),%eax
f010731b:	e8 fd ee ff ff       	call   f010621d <oappend>
f0107320:	e9 68 08 00 00       	jmp    f0107b8d <OP_E+0x929>
	  break;
	case w_mode:
	  oappend (names16[rm + add]);
f0107325:	89 d8                	mov    %ebx,%eax
f0107327:	03 05 f8 4e 29 f0    	add    0xf0294ef8,%eax
f010732d:	8b 15 0c 4f 29 f0    	mov    0xf0294f0c,%edx
f0107333:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0107336:	e8 e2 ee ff ff       	call   f010621d <oappend>
f010733b:	e9 4d 08 00 00       	jmp    f0107b8d <OP_E+0x929>
	  break;
	case d_mode:
	  oappend (names32[rm + add]);
f0107340:	89 d8                	mov    %ebx,%eax
f0107342:	03 05 f8 4e 29 f0    	add    0xf0294ef8,%eax
f0107348:	8b 15 08 4f 29 f0    	mov    0xf0294f08,%edx
f010734e:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0107351:	e8 c7 ee ff ff       	call   f010621d <oappend>
f0107356:	e9 32 08 00 00       	jmp    f0107b8d <OP_E+0x929>
	  break;
	case q_mode:
	  oappend (names64[rm + add]);
f010735b:	89 d8                	mov    %ebx,%eax
f010735d:	03 05 f8 4e 29 f0    	add    0xf0294ef8,%eax
f0107363:	8b 15 04 4f 29 f0    	mov    0xf0294f04,%edx
f0107369:	8b 04 82             	mov    (%edx,%eax,4),%eax
f010736c:	e8 ac ee ff ff       	call   f010621d <oappend>
f0107371:	e9 17 08 00 00       	jmp    f0107b8d <OP_E+0x929>
	  break;
	case m_mode:
	  if (mode_64bit)
f0107376:	83 3d e0 4d 29 f0 00 	cmpl   $0x0,0xf0294de0
f010737d:	74 1b                	je     f010739a <OP_E+0x136>
	    oappend (names64[rm + add]);
f010737f:	89 d8                	mov    %ebx,%eax
f0107381:	03 05 f8 4e 29 f0    	add    0xf0294ef8,%eax
f0107387:	8b 15 04 4f 29 f0    	mov    0xf0294f04,%edx
f010738d:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0107390:	e8 88 ee ff ff       	call   f010621d <oappend>
f0107395:	e9 f3 07 00 00       	jmp    f0107b8d <OP_E+0x929>
	  else
	    oappend (names32[rm + add]);
f010739a:	89 d8                	mov    %ebx,%eax
f010739c:	03 05 f8 4e 29 f0    	add    0xf0294ef8,%eax
f01073a2:	8b 15 08 4f 29 f0    	mov    0xf0294f08,%edx
f01073a8:	8b 04 82             	mov    (%edx,%eax,4),%eax
f01073ab:	e8 6d ee ff ff       	call   f010621d <oappend>
f01073b0:	e9 d8 07 00 00       	jmp    f0107b8d <OP_E+0x929>
	  break;
	case v_mode:
	  USED_REX (REX_MODE64);
f01073b5:	f6 c1 08             	test   $0x8,%cl
f01073b8:	0f 84 a0 07 00 00    	je     f0107b5e <OP_E+0x8fa>
f01073be:	83 c8 48             	or     $0x48,%eax
f01073c1:	a3 ec 4d 29 f0       	mov    %eax,0xf0294dec
	  if (rex & REX_MODE64)
	    oappend (names64[rm + add]);
f01073c6:	89 da                	mov    %ebx,%edx
f01073c8:	03 15 f8 4e 29 f0    	add    0xf0294ef8,%edx
f01073ce:	a1 04 4f 29 f0       	mov    0xf0294f04,%eax
f01073d3:	8b 04 90             	mov    (%eax,%edx,4),%eax
f01073d6:	e8 42 ee ff ff       	call   f010621d <oappend>
f01073db:	eb 2e                	jmp    f010740b <OP_E+0x1a7>
	  else if (sizeflag & DFLAG)
	    oappend (names32[rm + add]);
f01073dd:	89 d8                	mov    %ebx,%eax
f01073df:	03 05 f8 4e 29 f0    	add    0xf0294ef8,%eax
f01073e5:	8b 15 08 4f 29 f0    	mov    0xf0294f08,%edx
f01073eb:	8b 04 82             	mov    (%edx,%eax,4),%eax
f01073ee:	e8 2a ee ff ff       	call   f010621d <oappend>
f01073f3:	eb 16                	jmp    f010740b <OP_E+0x1a7>
	  else
	    oappend (names16[rm + add]);
f01073f5:	89 d8                	mov    %ebx,%eax
f01073f7:	03 05 f8 4e 29 f0    	add    0xf0294ef8,%eax
f01073fd:	8b 15 0c 4f 29 f0    	mov    0xf0294f0c,%edx
f0107403:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0107406:	e8 12 ee ff ff       	call   f010621d <oappend>
	  used_prefixes |= (prefixes & PREFIX_DATA);
f010740b:	a1 e4 4d 29 f0       	mov    0xf0294de4,%eax
f0107410:	25 00 02 00 00       	and    $0x200,%eax
f0107415:	09 05 f0 4d 29 f0    	or     %eax,0xf0294df0
f010741b:	e9 6d 07 00 00       	jmp    f0107b8d <OP_E+0x929>
	  break;
	case 0:
	  if (!(codep[-2] == 0xAE && codep[-1] == 0xF8 /* sfence */)
f0107420:	80 7a fe ae          	cmpb   $0xae,-0x2(%edx)
f0107424:	75 1c                	jne    f0107442 <OP_E+0x1de>
f0107426:	0f b6 42 ff          	movzbl -0x1(%edx),%eax
f010742a:	3c f8                	cmp    $0xf8,%al
f010742c:	0f 84 5b 07 00 00    	je     f0107b8d <OP_E+0x929>
f0107432:	3c f0                	cmp    $0xf0,%al
f0107434:	0f 84 53 07 00 00    	je     f0107b8d <OP_E+0x929>
f010743a:	3c e8                	cmp    $0xe8,%al
f010743c:	0f 84 4b 07 00 00    	je     f0107b8d <OP_E+0x929>
	      && !(codep[-2] == 0xAE && codep[-1] == 0xF0 /* mfence */)
	      && !(codep[-2] == 0xAE && codep[-1] == 0xe8 /* lfence */))
	    BadOp ();	/* bad sfence,lea,lds,les,lfs,lgs,lss modrm */
f0107442:	e8 04 ee ff ff       	call   f010624b <BadOp>
f0107447:	e9 41 07 00 00       	jmp    f0107b8d <OP_E+0x929>
	  break;
	default:
	  oappend (INTERNAL_DISASSEMBLER_ERROR);
f010744c:	b8 82 bf 10 f0       	mov    $0xf010bf82,%eax
f0107451:	e8 c7 ed ff ff       	call   f010621d <oappend>
f0107456:	e9 32 07 00 00       	jmp    f0107b8d <OP_E+0x929>
	}
      return;
    }

  disp = 0;
  append_seg ();
f010745b:	e8 00 fc ff ff       	call   f0107060 <append_seg>
  //cprintf("append_seg:obufp=%s op1out=%s\n",obufp,op1out);
  if ((sizeflag & AFLAG) || mode_64bit) /* 32 bit address mode */
f0107460:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107463:	83 e0 02             	and    $0x2,%eax
f0107466:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0107469:	75 0d                	jne    f0107478 <OP_E+0x214>
f010746b:	83 3d e0 4d 29 f0 00 	cmpl   $0x0,0xf0294de0
f0107472:	0f 84 85 05 00 00    	je     f01079fd <OP_E+0x799>
      int index = 0;
      int scale = 0;

      havesib = 0;
      havebase = 1;
      base = rm;
f0107478:	8b 3d f8 4e 29 f0    	mov    0xf0294ef8,%edi
      //cprintf("base=%d\n",base);
     // panic("*****************");
      if (base == 4)
f010747e:	83 ff 04             	cmp    $0x4,%edi
f0107481:	74 1a                	je     f010749d <OP_E+0x239>
f0107483:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010748a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f0107491:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f0107498:	e9 9e 00 00 00       	jmp    f010753b <OP_E+0x2d7>
	{
	  havesib = 1;
	  FETCH_DATA (the_info, codep + 1);
f010749d:	8b 15 ec 4e 29 f0    	mov    0xf0294eec,%edx
f01074a3:	83 c2 01             	add    $0x1,%edx
f01074a6:	8b 0d f0 4e 29 f0    	mov    0xf0294ef0,%ecx
f01074ac:	8b 41 20             	mov    0x20(%ecx),%eax
f01074af:	3b 10                	cmp    (%eax),%edx
f01074b1:	76 07                	jbe    f01074ba <OP_E+0x256>
f01074b3:	89 c8                	mov    %ecx,%eax
f01074b5:	e8 e6 e1 ff ff       	call   f01056a0 <fetch_data>
	  scale = (*codep >> 6) & 3;
f01074ba:	8b 15 ec 4e 29 f0    	mov    0xf0294eec,%edx
f01074c0:	89 55 f0             	mov    %edx,-0x10(%ebp)
f01074c3:	0f b6 1a             	movzbl (%edx),%ebx
	  index = (*codep >> 3) & 7;
f01074c6:	89 d8                	mov    %ebx,%eax
f01074c8:	c0 e8 03             	shr    $0x3,%al
f01074cb:	89 c1                	mov    %eax,%ecx
f01074cd:	83 e1 07             	and    $0x7,%ecx
f01074d0:	89 4d e8             	mov    %ecx,-0x18(%ebp)
	  base = *codep & 7;
f01074d3:	bf 07 00 00 00       	mov    $0x7,%edi
f01074d8:	21 df                	and    %ebx,%edi
	  USED_REX (REX_EXTY);
f01074da:	a1 e8 4d 29 f0       	mov    0xf0294de8,%eax
f01074df:	89 c1                	mov    %eax,%ecx
f01074e1:	83 e1 02             	and    $0x2,%ecx
f01074e4:	83 f9 01             	cmp    $0x1,%ecx
f01074e7:	19 d2                	sbb    %edx,%edx
f01074e9:	f7 d2                	not    %edx
f01074eb:	83 e2 42             	and    $0x42,%edx
f01074ee:	0b 15 ec 4d 29 f0    	or     0xf0294dec,%edx
	  USED_REX (REX_EXTZ);
f01074f4:	83 e0 01             	and    $0x1,%eax
f01074f7:	89 c6                	mov    %eax,%esi
f01074f9:	89 f0                	mov    %esi,%eax
f01074fb:	c1 e0 1f             	shl    $0x1f,%eax
f01074fe:	c1 f8 1f             	sar    $0x1f,%eax
f0107501:	83 e0 41             	and    $0x41,%eax
f0107504:	09 d0                	or     %edx,%eax
f0107506:	a3 ec 4d 29 f0       	mov    %eax,0xf0294dec
	  //cprintf("esp_insn1:codep=%x scale=%d index=%d\n",*codep,scale,index);
	  //panic("*****************");
	  if (rex & REX_EXTY)
f010750b:	85 c9                	test   %ecx,%ecx
f010750d:	74 04                	je     f0107513 <OP_E+0x2af>
	    index += 8;
f010750f:	83 45 e8 08          	addl   $0x8,-0x18(%ebp)
	  if (rex & REX_EXTZ)
f0107513:	89 f0                	mov    %esi,%eax
f0107515:	84 c0                	test   %al,%al
f0107517:	74 03                	je     f010751c <OP_E+0x2b8>
	    base += 8;
f0107519:	83 c7 08             	add    $0x8,%edi
     // panic("*****************");
      if (base == 4)
	{
	  havesib = 1;
	  FETCH_DATA (the_info, codep + 1);
	  scale = (*codep >> 6) & 3;
f010751c:	89 d8                	mov    %ebx,%eax
f010751e:	c0 e8 06             	shr    $0x6,%al
f0107521:	89 c2                	mov    %eax,%edx
f0107523:	83 e2 03             	and    $0x3,%edx
f0107526:	89 55 ec             	mov    %edx,-0x14(%ebp)
	  if (rex & REX_EXTY)
	    index += 8;
	  if (rex & REX_EXTZ)
	    base += 8;
	  //cprintf("esp_insn2:codep=%x scale=%d index=%d mod=%x base=%x\n",*codep,scale,index,mod,base);
	  codep++;
f0107529:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010752c:	83 c0 01             	add    $0x1,%eax
f010752f:	a3 ec 4e 29 f0       	mov    %eax,0xf0294eec
f0107534:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
	  
	}

      switch (mod)
f010753b:	a1 f4 4e 29 f0       	mov    0xf0294ef4,%eax
f0107540:	83 f8 01             	cmp    $0x1,%eax
f0107543:	74 59                	je     f010759e <OP_E+0x33a>
f0107545:	83 f8 02             	cmp    $0x2,%eax
f0107548:	0f 84 ad 00 00 00    	je     f01075fb <OP_E+0x397>
f010754e:	85 c0                	test   %eax,%eax
f0107550:	0f 85 be 00 00 00    	jne    f0107614 <OP_E+0x3b0>
	{
	case 0:
	  if ((base & 7) == 5)
f0107556:	89 f8                	mov    %edi,%eax
f0107558:	83 e0 07             	and    $0x7,%eax
f010755b:	83 f8 05             	cmp    $0x5,%eax
f010755e:	0f 85 b0 00 00 00    	jne    f0107614 <OP_E+0x3b0>
	    {
	      havebase = 0;
	      if (mode_64bit && !havesib && (sizeflag & AFLAG))
f0107564:	83 3d e0 4d 29 f0 00 	cmpl   $0x0,0xf0294de0
f010756b:	74 06                	je     f0107573 <OP_E+0x30f>
f010756d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0107571:	74 09                	je     f010757c <OP_E+0x318>
f0107573:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f010757a:	eb 0d                	jmp    f0107589 <OP_E+0x325>
f010757c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0107580:	0f 95 c0             	setne  %al
f0107583:	0f b6 c0             	movzbl %al,%eax
f0107586:	89 45 dc             	mov    %eax,-0x24(%ebp)
		riprel = 1;
	      disp = get32s ();
f0107589:	e8 ed e3 ff ff       	call   f010597b <get32s>
f010758e:	89 c3                	mov    %eax,%ebx
f0107590:	89 d6                	mov    %edx,%esi
f0107592:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0107599:	e9 8e 00 00 00       	jmp    f010762c <OP_E+0x3c8>
	    }
	  break;
	case 1:
	  FETCH_DATA (the_info, codep + 1);
f010759e:	8b 15 ec 4e 29 f0    	mov    0xf0294eec,%edx
f01075a4:	83 c2 01             	add    $0x1,%edx
f01075a7:	8b 0d f0 4e 29 f0    	mov    0xf0294ef0,%ecx
f01075ad:	8b 41 20             	mov    0x20(%ecx),%eax
f01075b0:	3b 10                	cmp    (%eax),%edx
f01075b2:	76 07                	jbe    f01075bb <OP_E+0x357>
f01075b4:	89 c8                	mov    %ecx,%eax
f01075b6:	e8 e5 e0 ff ff       	call   f01056a0 <fetch_data>
	  disp = *codep++;
f01075bb:	a1 ec 4e 29 f0       	mov    0xf0294eec,%eax
f01075c0:	0f b6 18             	movzbl (%eax),%ebx
f01075c3:	be 00 00 00 00       	mov    $0x0,%esi
f01075c8:	83 c0 01             	add    $0x1,%eax
f01075cb:	a3 ec 4e 29 f0       	mov    %eax,0xf0294eec
	  if ((disp & 0x80) != 0)
f01075d0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01075d7:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01075de:	84 db                	test   %bl,%bl
f01075e0:	79 4a                	jns    f010762c <OP_E+0x3c8>
	    disp -= 0x100;
f01075e2:	81 c3 00 ff ff ff    	add    $0xffffff00,%ebx
f01075e8:	83 d6 ff             	adc    $0xffffffff,%esi
f01075eb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01075f2:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01075f9:	eb 31                	jmp    f010762c <OP_E+0x3c8>
	  break;
	case 2:
	  disp = get32s ();
f01075fb:	e8 7b e3 ff ff       	call   f010597b <get32s>
f0107600:	89 c3                	mov    %eax,%ebx
f0107602:	89 d6                	mov    %edx,%esi
f0107604:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f010760b:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0107612:	eb 18                	jmp    f010762c <OP_E+0x3c8>
f0107614:	bb 00 00 00 00       	mov    $0x0,%ebx
f0107619:	be 00 00 00 00       	mov    $0x0,%esi
f010761e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0107625:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
	  break;
	}
      //cprintf("intel_syntax=%d\n",intel_syntax);
      if (!intel_syntax)
f010762c:	80 3d d0 50 29 f0 00 	cmpb   $0x0,0xf02950d0
f0107633:	75 5b                	jne    f0107690 <OP_E+0x42c>
        if (mod != 0 || (base & 7) == 5)
f0107635:	83 3d f4 4e 29 f0 00 	cmpl   $0x0,0xf0294ef4
f010763c:	75 0a                	jne    f0107648 <OP_E+0x3e4>
f010763e:	89 f8                	mov    %edi,%eax
f0107640:	83 e0 07             	and    $0x7,%eax
f0107643:	83 f8 05             	cmp    $0x5,%eax
f0107646:	75 48                	jne    f0107690 <OP_E+0x42c>
          {
            print_operand_value (scratchbuf, sizeof(scratchbuf), !riprel, disp);
f0107648:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010764c:	0f 94 c1             	sete   %cl
f010764f:	0f b6 c9             	movzbl %cl,%ecx
f0107652:	89 1c 24             	mov    %ebx,(%esp)
f0107655:	89 74 24 04          	mov    %esi,0x4(%esp)
f0107659:	ba 64 00 00 00       	mov    $0x64,%edx
f010765e:	b8 80 4e 29 f0       	mov    $0xf0294e80,%eax
f0107663:	e8 f4 e9 ff ff       	call   f010605c <print_operand_value>
            oappend (scratchbuf);
f0107668:	b8 80 4e 29 f0       	mov    $0xf0294e80,%eax
f010766d:	e8 ab eb ff ff       	call   f010621d <oappend>
	    if (riprel)
f0107672:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0107676:	74 18                	je     f0107690 <OP_E+0x42c>
	      {
		set_op (disp, 1);
f0107678:	b9 01 00 00 00       	mov    $0x1,%ecx
f010767d:	89 d8                	mov    %ebx,%eax
f010767f:	89 f2                	mov    %esi,%edx
f0107681:	e8 bb e3 ff ff       	call   f0105a41 <set_op>
		oappend ("(%rip)");
f0107686:	b8 d0 bf 10 f0       	mov    $0xf010bfd0,%eax
f010768b:	e8 8d eb ff ff       	call   f010621d <oappend>
	      }
          }
      //cprintf("havebase=%d havesib=%d\n",havebase,havesib);
      if (havebase || (havesib && (index != 4 || scale != 0)))
f0107690:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0107694:	75 1a                	jne    f01076b0 <OP_E+0x44c>
f0107696:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010769a:	0f 84 ec 02 00 00    	je     f010798c <OP_E+0x728>
f01076a0:	83 7d e8 04          	cmpl   $0x4,-0x18(%ebp)
f01076a4:	75 0a                	jne    f01076b0 <OP_E+0x44c>
f01076a6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f01076aa:	0f 84 dc 02 00 00    	je     f010798c <OP_E+0x728>
	{
          if (intel_syntax)
f01076b0:	80 3d d0 50 29 f0 00 	cmpb   $0x0,0xf02950d0
f01076b7:	0f 84 b5 04 00 00    	je     f0107b72 <OP_E+0x90e>
            {
              switch (bytemode)
f01076bd:	83 7d 08 07          	cmpl   $0x7,0x8(%ebp)
f01076c1:	77 69                	ja     f010772c <OP_E+0x4c8>
f01076c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01076c6:	ff 24 8d 5c d7 10 f0 	jmp    *-0xfef28a4(,%ecx,4)
                {
                case b_mode:
                  oappend ("BYTE PTR ");
f01076cd:	b8 d7 bf 10 f0       	mov    $0xf010bfd7,%eax
f01076d2:	e8 46 eb ff ff       	call   f010621d <oappend>
f01076d7:	eb 53                	jmp    f010772c <OP_E+0x4c8>
                  break;
                case w_mode:
                  oappend ("WORD PTR ");
f01076d9:	b8 e2 bf 10 f0       	mov    $0xf010bfe2,%eax
f01076de:	e8 3a eb ff ff       	call   f010621d <oappend>
f01076e3:	eb 47                	jmp    f010772c <OP_E+0x4c8>
                  break;
                case v_mode:
                  oappend ("DWORD PTR ");
f01076e5:	b8 e1 bf 10 f0       	mov    $0xf010bfe1,%eax
f01076ea:	e8 2e eb ff ff       	call   f010621d <oappend>
f01076ef:	90                   	nop    
f01076f0:	eb 3a                	jmp    f010772c <OP_E+0x4c8>
                  break;
                case d_mode:
                  oappend ("QWORD PTR ");
f01076f2:	b8 ec bf 10 f0       	mov    $0xf010bfec,%eax
f01076f7:	e8 21 eb ff ff       	call   f010621d <oappend>
f01076fc:	eb 2e                	jmp    f010772c <OP_E+0x4c8>
                  break;
                case m_mode:
		  if (mode_64bit)
f01076fe:	83 3d e0 4d 29 f0 00 	cmpl   $0x0,0xf0294de0
f0107705:	74 0c                	je     f0107713 <OP_E+0x4af>
		    oappend ("DWORD PTR ");
f0107707:	b8 e1 bf 10 f0       	mov    $0xf010bfe1,%eax
f010770c:	e8 0c eb ff ff       	call   f010621d <oappend>
f0107711:	eb 19                	jmp    f010772c <OP_E+0x4c8>
		  else
		    oappend ("QWORD PTR ");
f0107713:	b8 ec bf 10 f0       	mov    $0xf010bfec,%eax
f0107718:	e8 00 eb ff ff       	call   f010621d <oappend>
f010771d:	8d 76 00             	lea    0x0(%esi),%esi
f0107720:	eb 0a                	jmp    f010772c <OP_E+0x4c8>
		  break;
                case x_mode:
                  oappend ("XWORD PTR ");
f0107722:	b8 f7 bf 10 f0       	mov    $0xf010bff7,%eax
f0107727:	e8 f1 ea ff ff       	call   f010621d <oappend>
                default:
                  break;
                }
             }
         // cprintf("aaaaaaaaaaaaaaa\n");
	  *obufp++ = open_char;
f010772c:	a1 64 4e 29 f0       	mov    0xf0294e64,%eax
f0107731:	0f b6 15 d1 50 29 f0 	movzbl 0xf02950d1,%edx
f0107738:	88 10                	mov    %dl,(%eax)
f010773a:	83 c0 01             	add    $0x1,%eax
f010773d:	a3 64 4e 29 f0       	mov    %eax,0xf0294e64
	  if (intel_syntax && riprel)
f0107742:	80 3d d0 50 29 f0 00 	cmpb   $0x0,0xf02950d0
f0107749:	74 10                	je     f010775b <OP_E+0x4f7>
f010774b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010774f:	74 0a                	je     f010775b <OP_E+0x4f7>
	    oappend ("rip + ");
f0107751:	b8 02 c0 10 f0       	mov    $0xf010c002,%eax
f0107756:	e8 c2 ea ff ff       	call   f010621d <oappend>
          *obufp = '\0';
f010775b:	a1 64 4e 29 f0       	mov    0xf0294e64,%eax
f0107760:	c6 00 00             	movb   $0x0,(%eax)
	  USED_REX (REX_EXTZ);
f0107763:	0f b6 15 e8 4d 29 f0 	movzbl 0xf0294de8,%edx
f010776a:	83 e2 01             	and    $0x1,%edx
f010776d:	89 d0                	mov    %edx,%eax
f010776f:	c1 e0 1f             	shl    $0x1f,%eax
f0107772:	c1 f8 1f             	sar    $0x1f,%eax
f0107775:	83 e0 41             	and    $0x41,%eax
f0107778:	09 05 ec 4d 29 f0    	or     %eax,0xf0294dec
	  if (!havesib && (rex & REX_EXTZ))
f010777e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0107782:	75 07                	jne    f010778b <OP_E+0x527>
f0107784:	84 d2                	test   %dl,%dl
f0107786:	74 03                	je     f010778b <OP_E+0x527>
	    base += 8;
f0107788:	83 c7 08             	add    $0x8,%edi
	  if (havebase)
f010778b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010778f:	74 26                	je     f01077b7 <OP_E+0x553>
	    oappend (mode_64bit && (sizeflag & AFLAG)
f0107791:	83 3d e0 4d 29 f0 00 	cmpl   $0x0,0xf0294de0
f0107798:	74 10                	je     f01077aa <OP_E+0x546>
f010779a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010779e:	74 0a                	je     f01077aa <OP_E+0x546>
f01077a0:	a1 04 4f 29 f0       	mov    0xf0294f04,%eax
f01077a5:	8b 04 b8             	mov    (%eax,%edi,4),%eax
f01077a8:	eb 08                	jmp    f01077b2 <OP_E+0x54e>
f01077aa:	a1 08 4f 29 f0       	mov    0xf0294f08,%eax
f01077af:	8b 04 b8             	mov    (%eax,%edi,4),%eax
f01077b2:	e8 66 ea ff ff       	call   f010621d <oappend>
		     ? names64[base] : names32[base]);
	  if (havesib)
f01077b7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01077bb:	0f 84 41 01 00 00    	je     f0107902 <OP_E+0x69e>
	    {
	      if (index != 4)
f01077c1:	83 7d e8 04          	cmpl   $0x4,-0x18(%ebp)
f01077c5:	0f 84 c4 00 00 00    	je     f010788f <OP_E+0x62b>
		{
                  if (intel_syntax)
f01077cb:	80 3d d0 50 29 f0 00 	cmpb   $0x0,0xf02950d0
f01077d2:	74 6a                	je     f010783e <OP_E+0x5da>
                    {
                      if (havebase)
f01077d4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01077d8:	74 1b                	je     f01077f5 <OP_E+0x591>
                        {
                          *obufp++ = separator_char;
f01077da:	a1 64 4e 29 f0       	mov    0xf0294e64,%eax
f01077df:	0f b6 15 d3 50 29 f0 	movzbl 0xf02950d3,%edx
f01077e6:	88 10                	mov    %dl,(%eax)
f01077e8:	8d 50 01             	lea    0x1(%eax),%edx
f01077eb:	89 15 64 4e 29 f0    	mov    %edx,0xf0294e64
                          *obufp = '\0';
f01077f1:	c6 40 01 00          	movb   $0x0,0x1(%eax)
                        }
                      snprintf (scratchbuf, sizeof(scratchbuf), "%s",
f01077f5:	83 3d e0 4d 29 f0 00 	cmpl   $0x0,0xf0294de0
f01077fc:	74 13                	je     f0107811 <OP_E+0x5ad>
f01077fe:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0107802:	74 0d                	je     f0107811 <OP_E+0x5ad>
f0107804:	a1 04 4f 29 f0       	mov    0xf0294f04,%eax
f0107809:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010780c:	8b 04 90             	mov    (%eax,%edx,4),%eax
f010780f:	eb 0b                	jmp    f010781c <OP_E+0x5b8>
f0107811:	a1 08 4f 29 f0       	mov    0xf0294f08,%eax
f0107816:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0107819:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f010781c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107820:	c7 44 24 08 be b6 10 	movl   $0xf010b6be,0x8(%esp)
f0107827:	f0 
f0107828:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f010782f:	00 
f0107830:	c7 04 24 80 4e 29 f0 	movl   $0xf0294e80,(%esp)
f0107837:	e8 6e 1b 00 00       	call   f01093aa <snprintf>
f010783c:	eb 47                	jmp    f0107885 <OP_E+0x621>
                                mode_64bit && (sizeflag & AFLAG)
                                ? names64[index] : names32[index]);
                    }
                  else
                      snprintf (scratchbuf, sizeof(scratchbuf), ",%s",
f010783e:	83 3d e0 4d 29 f0 00 	cmpl   $0x0,0xf0294de0
f0107845:	74 13                	je     f010785a <OP_E+0x5f6>
f0107847:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010784b:	74 0d                	je     f010785a <OP_E+0x5f6>
f010784d:	a1 04 4f 29 f0       	mov    0xf0294f04,%eax
f0107852:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0107855:	8b 04 90             	mov    (%eax,%edx,4),%eax
f0107858:	eb 0b                	jmp    f0107865 <OP_E+0x601>
f010785a:	a1 08 4f 29 f0       	mov    0xf0294f08,%eax
f010785f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0107862:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0107865:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107869:	c7 44 24 08 09 c0 10 	movl   $0xf010c009,0x8(%esp)
f0107870:	f0 
f0107871:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0107878:	00 
f0107879:	c7 04 24 80 4e 29 f0 	movl   $0xf0294e80,(%esp)
f0107880:	e8 25 1b 00 00       	call   f01093aa <snprintf>
                                mode_64bit && (sizeflag & AFLAG)
                                ? names64[index] : names32[index]);
		  oappend (scratchbuf);
f0107885:	b8 80 4e 29 f0       	mov    $0xf0294e80,%eax
f010788a:	e8 8e e9 ff ff       	call   f010621d <oappend>
		}
              if (!intel_syntax
f010788f:	80 3d d0 50 29 f0 00 	cmpb   $0x0,0xf02950d0
f0107896:	74 12                	je     f01078aa <OP_E+0x646>
f0107898:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f010789c:	74 6d                	je     f010790b <OP_E+0x6a7>
f010789e:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f01078a2:	74 67                	je     f010790b <OP_E+0x6a7>
f01078a4:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f01078a8:	74 61                	je     f010790b <OP_E+0x6a7>
                  || (intel_syntax
                      && bytemode != b_mode
                      && bytemode != w_mode
                      && bytemode != v_mode))
                {
                  if(scale){
f01078aa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f01078ae:	66 90                	xchg   %ax,%ax
f01078b0:	74 50                	je     f0107902 <OP_E+0x69e>
                       *obufp++ = scale_char;
f01078b2:	8b 15 64 4e 29 f0    	mov    0xf0294e64,%edx
f01078b8:	0f b6 05 d4 50 29 f0 	movzbl 0xf02950d4,%eax
f01078bf:	88 02                	mov    %al,(%edx)
f01078c1:	8d 42 01             	lea    0x1(%edx),%eax
f01078c4:	a3 64 4e 29 f0       	mov    %eax,0xf0294e64
                       *obufp = '\0';
f01078c9:	c6 42 01 00          	movb   $0x0,0x1(%edx)
                       snprintf (scratchbuf, sizeof(scratchbuf), "%d", 1 << scale);
f01078cd:	b8 01 00 00 00       	mov    $0x1,%eax
f01078d2:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01078d6:	d3 e0                	shl    %cl,%eax
f01078d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01078dc:	c7 44 24 08 1d 43 11 	movl   $0xf011431d,0x8(%esp)
f01078e3:	f0 
f01078e4:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f01078eb:	00 
f01078ec:	c7 04 24 80 4e 29 f0 	movl   $0xf0294e80,(%esp)
f01078f3:	e8 b2 1a 00 00       	call   f01093aa <snprintf>
	               oappend (scratchbuf);
f01078f8:	b8 80 4e 29 f0       	mov    $0xf0294e80,%eax
f01078fd:	e8 1b e9 ff ff       	call   f010621d <oappend>
		  }
                }
		//cprintf("obufp=%s op1out=%s scale=%d scale1=%d\n",obufp,op1out,1<<scale,scale);
	    }
	  //cprintf("bbbbbbbbbbbbbbbbbbbbbbbb\n");
          if (intel_syntax)
f0107902:	80 3d d0 50 29 f0 00 	cmpb   $0x0,0xf02950d0
f0107909:	74 61                	je     f010796c <OP_E+0x708>
            if (mod != 0 || (base & 7) == 5)
f010790b:	83 3d f4 4e 29 f0 00 	cmpl   $0x0,0xf0294ef4
f0107912:	75 0a                	jne    f010791e <OP_E+0x6ba>
f0107914:	89 f8                	mov    %edi,%eax
f0107916:	83 e0 07             	and    $0x7,%eax
f0107919:	83 f8 05             	cmp    $0x5,%eax
f010791c:	75 4e                	jne    f010796c <OP_E+0x708>
              {
		/* Don't print zero displacements.  */
                if (disp != 0)
f010791e:	89 f0                	mov    %esi,%eax
f0107920:	09 d8                	or     %ebx,%eax
f0107922:	74 48                	je     f010796c <OP_E+0x708>
                  {
		    if ((bfd_signed_vma) disp > 0)
f0107924:	85 f6                	test   %esi,%esi
f0107926:	78 1f                	js     f0107947 <OP_E+0x6e3>
f0107928:	85 f6                	test   %esi,%esi
f010792a:	7f 06                	jg     f0107932 <OP_E+0x6ce>
f010792c:	83 fb 00             	cmp    $0x0,%ebx
f010792f:	90                   	nop    
f0107930:	76 15                	jbe    f0107947 <OP_E+0x6e3>
		      {
			*obufp++ = '+';
f0107932:	a1 64 4e 29 f0       	mov    0xf0294e64,%eax
f0107937:	c6 00 2b             	movb   $0x2b,(%eax)
f010793a:	8d 50 01             	lea    0x1(%eax),%edx
f010793d:	89 15 64 4e 29 f0    	mov    %edx,0xf0294e64
			*obufp = '\0';
f0107943:	c6 40 01 00          	movb   $0x0,0x1(%eax)
		      }

                    print_operand_value (scratchbuf, sizeof(scratchbuf), 0,
f0107947:	89 1c 24             	mov    %ebx,(%esp)
f010794a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010794e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0107953:	ba 64 00 00 00       	mov    $0x64,%edx
f0107958:	b8 80 4e 29 f0       	mov    $0xf0294e80,%eax
f010795d:	e8 fa e6 ff ff       	call   f010605c <print_operand_value>
                                         disp);
                    oappend (scratchbuf);
f0107962:	b8 80 4e 29 f0       	mov    $0xf0294e80,%eax
f0107967:	e8 b1 e8 ff ff       	call   f010621d <oappend>
                  }
              }

	  *obufp++ = close_char;
f010796c:	a1 64 4e 29 f0       	mov    0xf0294e64,%eax
f0107971:	0f b6 15 d2 50 29 f0 	movzbl 0xf02950d2,%edx
f0107978:	88 10                	mov    %dl,(%eax)
f010797a:	8d 50 01             	lea    0x1(%eax),%edx
f010797d:	89 15 64 4e 29 f0    	mov    %edx,0xf0294e64
          *obufp = '\0';	
f0107983:	c6 40 01 00          	movb   $0x0,0x1(%eax)
f0107987:	e9 01 02 00 00       	jmp    f0107b8d <OP_E+0x929>
	}
      else if (intel_syntax)
f010798c:	80 3d d0 50 29 f0 00 	cmpb   $0x0,0xf02950d0
f0107993:	0f 84 f4 01 00 00    	je     f0107b8d <OP_E+0x929>
        {
          if (mod != 0 || (base & 7) == 5)
f0107999:	83 3d f4 4e 29 f0 00 	cmpl   $0x0,0xf0294ef4
f01079a0:	75 0e                	jne    f01079b0 <OP_E+0x74c>
f01079a2:	89 f8                	mov    %edi,%eax
f01079a4:	83 e0 07             	and    $0x7,%eax
f01079a7:	83 f8 05             	cmp    $0x5,%eax
f01079aa:	0f 85 dd 01 00 00    	jne    f0107b8d <OP_E+0x929>
            {
	      if (prefixes & (PREFIX_CS | PREFIX_SS | PREFIX_DS
f01079b0:	f7 05 e4 4d 29 f0 f8 	testl  $0x1f8,0xf0294de4
f01079b7:	01 00 00 
f01079ba:	75 17                	jne    f01079d3 <OP_E+0x76f>
			      | PREFIX_ES | PREFIX_FS | PREFIX_GS))
		;
	      else
		{
		  oappend (names_seg[ds_reg - es_reg]);
f01079bc:	a1 18 4f 29 f0       	mov    0xf0294f18,%eax
f01079c1:	8b 40 0c             	mov    0xc(%eax),%eax
f01079c4:	e8 54 e8 ff ff       	call   f010621d <oappend>
		  oappend (":");
f01079c9:	b8 ae bf 10 f0       	mov    $0xf010bfae,%eax
f01079ce:	e8 4a e8 ff ff       	call   f010621d <oappend>
		}
              print_operand_value (scratchbuf, sizeof(scratchbuf), 1, disp);
f01079d3:	89 1c 24             	mov    %ebx,(%esp)
f01079d6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01079da:	b9 01 00 00 00       	mov    $0x1,%ecx
f01079df:	ba 64 00 00 00       	mov    $0x64,%edx
f01079e4:	b8 80 4e 29 f0       	mov    $0xf0294e80,%eax
f01079e9:	e8 6e e6 ff ff       	call   f010605c <print_operand_value>
              oappend (scratchbuf);
f01079ee:	b8 80 4e 29 f0       	mov    $0xf0294e80,%eax
f01079f3:	e8 25 e8 ff ff       	call   f010621d <oappend>
f01079f8:	e9 90 01 00 00       	jmp    f0107b8d <OP_E+0x929>
	//cprintf("obufp=%s op1out=%s\n",obufp,op1out);
    	//panic("**************");
    }
  else
    { /* 16 bit address mode */
      switch (mod)
f01079fd:	a1 f4 4e 29 f0       	mov    0xf0294ef4,%eax
f0107a02:	83 f8 01             	cmp    $0x1,%eax
f0107a05:	74 36                	je     f0107a3d <OP_E+0x7d9>
f0107a07:	83 f8 02             	cmp    $0x2,%eax
f0107a0a:	74 72                	je     f0107a7e <OP_E+0x81a>
f0107a0c:	85 c0                	test   %eax,%eax
f0107a0e:	0f 85 86 00 00 00    	jne    f0107a9a <OP_E+0x836>
	{
	case 0:
	  if ((rm & 7) == 6)
f0107a14:	a1 f8 4e 29 f0       	mov    0xf0294ef8,%eax
f0107a19:	83 e0 07             	and    $0x7,%eax
f0107a1c:	83 f8 06             	cmp    $0x6,%eax
f0107a1f:	75 79                	jne    f0107a9a <OP_E+0x836>
	    {
	      disp = get16 ();
f0107a21:	e8 db df ff ff       	call   f0105a01 <get16>
f0107a26:	89 c2                	mov    %eax,%edx
f0107a28:	89 c1                	mov    %eax,%ecx
f0107a2a:	c1 f9 1f             	sar    $0x1f,%ecx
	      if ((disp & 0x8000) != 0)
f0107a2d:	66 85 c0             	test   %ax,%ax
f0107a30:	79 72                	jns    f0107aa4 <OP_E+0x840>
		disp -= 0x10000;
f0107a32:	81 c2 00 00 ff ff    	add    $0xffff0000,%edx
f0107a38:	83 d1 ff             	adc    $0xffffffff,%ecx
f0107a3b:	eb 67                	jmp    f0107aa4 <OP_E+0x840>
	    }
	  break;
	case 1:
	  FETCH_DATA (the_info, codep + 1);
f0107a3d:	8b 15 ec 4e 29 f0    	mov    0xf0294eec,%edx
f0107a43:	83 c2 01             	add    $0x1,%edx
f0107a46:	8b 0d f0 4e 29 f0    	mov    0xf0294ef0,%ecx
f0107a4c:	8b 41 20             	mov    0x20(%ecx),%eax
f0107a4f:	3b 10                	cmp    (%eax),%edx
f0107a51:	76 07                	jbe    f0107a5a <OP_E+0x7f6>
f0107a53:	89 c8                	mov    %ecx,%eax
f0107a55:	e8 46 dc ff ff       	call   f01056a0 <fetch_data>
	  disp = *codep++;
f0107a5a:	a1 ec 4e 29 f0       	mov    0xf0294eec,%eax
f0107a5f:	0f b6 10             	movzbl (%eax),%edx
f0107a62:	b9 00 00 00 00       	mov    $0x0,%ecx
f0107a67:	83 c0 01             	add    $0x1,%eax
f0107a6a:	a3 ec 4e 29 f0       	mov    %eax,0xf0294eec
	  if ((disp & 0x80) != 0)
f0107a6f:	84 d2                	test   %dl,%dl
f0107a71:	79 31                	jns    f0107aa4 <OP_E+0x840>
	    disp -= 0x100;
f0107a73:	81 c2 00 ff ff ff    	add    $0xffffff00,%edx
f0107a79:	83 d1 ff             	adc    $0xffffffff,%ecx
f0107a7c:	eb 26                	jmp    f0107aa4 <OP_E+0x840>
	  break;
	case 2:
	  disp = get16 ();
f0107a7e:	e8 7e df ff ff       	call   f0105a01 <get16>
f0107a83:	89 c2                	mov    %eax,%edx
f0107a85:	89 c1                	mov    %eax,%ecx
f0107a87:	c1 f9 1f             	sar    $0x1f,%ecx
	  if ((disp & 0x8000) != 0)
f0107a8a:	66 85 c0             	test   %ax,%ax
f0107a8d:	79 15                	jns    f0107aa4 <OP_E+0x840>
	    disp -= 0x10000;
f0107a8f:	81 c2 00 00 ff ff    	add    $0xffff0000,%edx
f0107a95:	83 d1 ff             	adc    $0xffffffff,%ecx
f0107a98:	eb 0a                	jmp    f0107aa4 <OP_E+0x840>
f0107a9a:	ba 00 00 00 00       	mov    $0x0,%edx
f0107a9f:	b9 00 00 00 00       	mov    $0x0,%ecx
	  break;
	}

      if (!intel_syntax)
f0107aa4:	80 3d d0 50 29 f0 00 	cmpb   $0x0,0xf02950d0
f0107aab:	75 3b                	jne    f0107ae8 <OP_E+0x884>
        if (mod != 0 || (rm & 7) == 6)
f0107aad:	83 3d f4 4e 29 f0 00 	cmpl   $0x0,0xf0294ef4
f0107ab4:	75 0d                	jne    f0107ac3 <OP_E+0x85f>
f0107ab6:	a1 f8 4e 29 f0       	mov    0xf0294ef8,%eax
f0107abb:	83 e0 07             	and    $0x7,%eax
f0107abe:	83 f8 06             	cmp    $0x6,%eax
f0107ac1:	75 3f                	jne    f0107b02 <OP_E+0x89e>
          {
            print_operand_value (scratchbuf, sizeof(scratchbuf), 0, disp);
f0107ac3:	89 14 24             	mov    %edx,(%esp)
f0107ac6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0107aca:	b9 00 00 00 00       	mov    $0x0,%ecx
f0107acf:	ba 64 00 00 00       	mov    $0x64,%edx
f0107ad4:	b8 80 4e 29 f0       	mov    $0xf0294e80,%eax
f0107ad9:	e8 7e e5 ff ff       	call   f010605c <print_operand_value>
            oappend (scratchbuf);
f0107ade:	b8 80 4e 29 f0       	mov    $0xf0294e80,%eax
f0107ae3:	e8 35 e7 ff ff       	call   f010621d <oappend>
          }

      if (mod != 0 || (rm & 7) != 6)
f0107ae8:	83 3d f4 4e 29 f0 00 	cmpl   $0x0,0xf0294ef4
f0107aef:	75 11                	jne    f0107b02 <OP_E+0x89e>
f0107af1:	a1 f8 4e 29 f0       	mov    0xf0294ef8,%eax
f0107af6:	83 e0 07             	and    $0x7,%eax
f0107af9:	83 f8 06             	cmp    $0x6,%eax
f0107afc:	0f 84 8b 00 00 00    	je     f0107b8d <OP_E+0x929>
	{
	  *obufp++ = open_char;
f0107b02:	8b 15 64 4e 29 f0    	mov    0xf0294e64,%edx
f0107b08:	0f b6 05 d1 50 29 f0 	movzbl 0xf02950d1,%eax
f0107b0f:	88 02                	mov    %al,(%edx)
f0107b11:	8d 42 01             	lea    0x1(%edx),%eax
f0107b14:	a3 64 4e 29 f0       	mov    %eax,0xf0294e64
          *obufp = '\0';
f0107b19:	c6 42 01 00          	movb   $0x0,0x1(%edx)
	  oappend (index16[rm + add]);
f0107b1d:	89 da                	mov    %ebx,%edx
f0107b1f:	03 15 f8 4e 29 f0    	add    0xf0294ef8,%edx
f0107b25:	a1 1c 4f 29 f0       	mov    0xf0294f1c,%eax
f0107b2a:	8b 04 90             	mov    (%eax,%edx,4),%eax
f0107b2d:	e8 eb e6 ff ff       	call   f010621d <oappend>
          *obufp++ = close_char;
f0107b32:	8b 15 64 4e 29 f0    	mov    0xf0294e64,%edx
f0107b38:	0f b6 05 d2 50 29 f0 	movzbl 0xf02950d2,%eax
f0107b3f:	88 02                	mov    %al,(%edx)
f0107b41:	8d 42 01             	lea    0x1(%edx),%eax
f0107b44:	a3 64 4e 29 f0       	mov    %eax,0xf0294e64
          *obufp = '\0';
f0107b49:	c6 42 01 00          	movb   $0x0,0x1(%edx)
f0107b4d:	eb 3e                	jmp    f0107b8d <OP_E+0x929>
     int sizeflag;
{
  bfd_vma disp;
  int add = 0;
  int riprel = 0;
  USED_REX (REX_EXTZ);
f0107b4f:	a1 ec 4d 29 f0       	mov    0xf0294dec,%eax
f0107b54:	bb 00 00 00 00       	mov    $0x0,%ebx
f0107b59:	e9 30 f7 ff ff       	jmp    f010728e <OP_E+0x2a>
	    oappend (names64[rm + add]);
	  else
	    oappend (names32[rm + add]);
	  break;
	case v_mode:
	  USED_REX (REX_MODE64);
f0107b5e:	a3 ec 4d 29 f0       	mov    %eax,0xf0294dec
	  if (rex & REX_MODE64)
	    oappend (names64[rm + add]);
	  else if (sizeflag & DFLAG)
f0107b63:	f6 45 0c 01          	testb  $0x1,0xc(%ebp)
f0107b67:	0f 85 70 f8 ff ff    	jne    f01073dd <OP_E+0x179>
f0107b6d:	e9 83 f8 ff ff       	jmp    f01073f5 <OP_E+0x191>
                default:
                  break;
                }
             }
         // cprintf("aaaaaaaaaaaaaaa\n");
	  *obufp++ = open_char;
f0107b72:	a1 64 4e 29 f0       	mov    0xf0294e64,%eax
f0107b77:	0f b6 15 d1 50 29 f0 	movzbl 0xf02950d1,%edx
f0107b7e:	88 10                	mov    %dl,(%eax)
f0107b80:	83 c0 01             	add    $0x1,%eax
f0107b83:	a3 64 4e 29 f0       	mov    %eax,0xf0294e64
f0107b88:	e9 ce fb ff ff       	jmp    f010775b <OP_E+0x4f7>
	}

    }
    //cprintf("3269:obufp=%s op1out=%s\n",obufp,op1out);
    //panic("**************");
}
f0107b8d:	83 c4 2c             	add    $0x2c,%esp
f0107b90:	5b                   	pop    %ebx
f0107b91:	5e                   	pop    %esi
f0107b92:	5f                   	pop    %edi
f0107b93:	5d                   	pop    %ebp
f0107b94:	c3                   	ret    

f0107b95 <OP_EX>:

static void
OP_EX (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f0107b95:	55                   	push   %ebp
f0107b96:	89 e5                	mov    %esp,%ebp
f0107b98:	83 ec 18             	sub    $0x18,%esp
  int add = 0;
  if (mod != 3)
f0107b9b:	83 3d f4 4e 29 f0 03 	cmpl   $0x3,0xf0294ef4
f0107ba2:	74 14                	je     f0107bb8 <OP_EX+0x23>
    {
      OP_E (bytemode, sizeflag);
f0107ba4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107ba7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107bab:	8b 45 08             	mov    0x8(%ebp),%eax
f0107bae:	89 04 24             	mov    %eax,(%esp)
f0107bb1:	e8 ae f6 ff ff       	call   f0107264 <OP_E>
f0107bb6:	eb 7a                	jmp    f0107c32 <OP_EX+0x9d>
      return;
    }
  USED_REX (REX_EXTZ);
f0107bb8:	b8 00 00 00 00       	mov    $0x0,%eax
f0107bbd:	f6 05 e8 4d 29 f0 01 	testb  $0x1,0xf0294de8
f0107bc4:	74 09                	je     f0107bcf <OP_EX+0x3a>
f0107bc6:	83 0d ec 4d 29 f0 41 	orl    $0x41,0xf0294dec
f0107bcd:	b0 08                	mov    $0x8,%al
  if (rex & REX_EXTZ)
    add = 8;

  /* Skip mod/rm byte.  */
  MODRM_CHECK;
f0107bcf:	80 3d 00 4f 29 f0 00 	cmpb   $0x0,0xf0294f00
f0107bd6:	75 1c                	jne    f0107bf4 <OP_EX+0x5f>
f0107bd8:	c7 44 24 08 c4 bf 10 	movl   $0xf010bfc4,0x8(%esp)
f0107bdf:	f0 
f0107be0:	c7 44 24 04 90 0f 00 	movl   $0xf90,0x4(%esp)
f0107be7:	00 
f0107be8:	c7 04 24 07 bf 10 f0 	movl   $0xf010bf07,(%esp)
f0107bef:	e8 92 84 ff ff       	call   f0100086 <_panic>
  codep++;
f0107bf4:	83 05 ec 4e 29 f0 01 	addl   $0x1,0xf0294eec
  snprintf (scratchbuf, sizeof(scratchbuf), "%%xmm%d", rm + add);
f0107bfb:	03 05 f8 4e 29 f0    	add    0xf0294ef8,%eax
f0107c01:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107c05:	c7 44 24 08 3f bf 10 	movl   $0xf010bf3f,0x8(%esp)
f0107c0c:	f0 
f0107c0d:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0107c14:	00 
f0107c15:	c7 04 24 80 4e 29 f0 	movl   $0xf0294e80,(%esp)
f0107c1c:	e8 89 17 00 00       	call   f01093aa <snprintf>
  oappend (scratchbuf + intel_syntax);
f0107c21:	0f be 05 d0 50 29 f0 	movsbl 0xf02950d0,%eax
f0107c28:	05 80 4e 29 f0       	add    $0xf0294e80,%eax
f0107c2d:	e8 eb e5 ff ff       	call   f010621d <oappend>
}
f0107c32:	c9                   	leave  
f0107c33:	c3                   	ret    

f0107c34 <OP_XS>:

static void
OP_XS (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f0107c34:	55                   	push   %ebp
f0107c35:	89 e5                	mov    %esp,%ebp
f0107c37:	83 ec 08             	sub    $0x8,%esp
  if (mod == 3)
f0107c3a:	83 3d f4 4e 29 f0 03 	cmpl   $0x3,0xf0294ef4
f0107c41:	75 14                	jne    f0107c57 <OP_XS+0x23>
    OP_EX (bytemode, sizeflag);
f0107c43:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107c46:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107c4a:	8b 45 08             	mov    0x8(%ebp),%eax
f0107c4d:	89 04 24             	mov    %eax,(%esp)
f0107c50:	e8 40 ff ff ff       	call   f0107b95 <OP_EX>
f0107c55:	eb 05                	jmp    f0107c5c <OP_XS+0x28>
  else
    BadOp ();
f0107c57:	e8 ef e5 ff ff       	call   f010624b <BadOp>
}
f0107c5c:	c9                   	leave  
f0107c5d:	8d 76 00             	lea    0x0(%esi),%esi
f0107c60:	c3                   	ret    

f0107c61 <OP_EM>:

static void
OP_EM (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f0107c61:	55                   	push   %ebp
f0107c62:	89 e5                	mov    %esp,%ebp
f0107c64:	83 ec 18             	sub    $0x18,%esp
  int add = 0;
  if (mod != 3)
f0107c67:	83 3d f4 4e 29 f0 03 	cmpl   $0x3,0xf0294ef4
f0107c6e:	74 17                	je     f0107c87 <OP_EM+0x26>
    {
      OP_E (bytemode, sizeflag);
f0107c70:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107c73:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107c77:	8b 45 08             	mov    0x8(%ebp),%eax
f0107c7a:	89 04 24             	mov    %eax,(%esp)
f0107c7d:	e8 e2 f5 ff ff       	call   f0107264 <OP_E>
f0107c82:	e9 ba 00 00 00       	jmp    f0107d41 <OP_EM+0xe0>
      return;
    }
  USED_REX (REX_EXTZ);
f0107c87:	ba 00 00 00 00       	mov    $0x0,%edx
f0107c8c:	f6 05 e8 4d 29 f0 01 	testb  $0x1,0xf0294de8
f0107c93:	74 09                	je     f0107c9e <OP_EM+0x3d>
f0107c95:	83 0d ec 4d 29 f0 41 	orl    $0x41,0xf0294dec
f0107c9c:	b2 08                	mov    $0x8,%dl
  if (rex & REX_EXTZ)
    add = 8;

  /* Skip mod/rm byte.  */
  MODRM_CHECK;
f0107c9e:	80 3d 00 4f 29 f0 00 	cmpb   $0x0,0xf0294f00
f0107ca5:	75 1c                	jne    f0107cc3 <OP_EM+0x62>
f0107ca7:	c7 44 24 08 c4 bf 10 	movl   $0xf010bfc4,0x8(%esp)
f0107cae:	f0 
f0107caf:	c7 44 24 04 76 0f 00 	movl   $0xf76,0x4(%esp)
f0107cb6:	00 
f0107cb7:	c7 04 24 07 bf 10 f0 	movl   $0xf010bf07,(%esp)
f0107cbe:	e8 c3 83 ff ff       	call   f0100086 <_panic>
  codep++;
f0107cc3:	83 05 ec 4e 29 f0 01 	addl   $0x1,0xf0294eec
  used_prefixes |= (prefixes & PREFIX_DATA);
f0107cca:	a1 e4 4d 29 f0       	mov    0xf0294de4,%eax
f0107ccf:	25 00 02 00 00       	and    $0x200,%eax
f0107cd4:	09 05 f0 4d 29 f0    	or     %eax,0xf0294df0
  if (prefixes & PREFIX_DATA)
f0107cda:	85 c0                	test   %eax,%eax
f0107cdc:	74 2a                	je     f0107d08 <OP_EM+0xa7>
    snprintf (scratchbuf, sizeof(scratchbuf), "%%xmm%d", rm + add);
f0107cde:	89 d0                	mov    %edx,%eax
f0107ce0:	03 05 f8 4e 29 f0    	add    0xf0294ef8,%eax
f0107ce6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107cea:	c7 44 24 08 3f bf 10 	movl   $0xf010bf3f,0x8(%esp)
f0107cf1:	f0 
f0107cf2:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0107cf9:	00 
f0107cfa:	c7 04 24 80 4e 29 f0 	movl   $0xf0294e80,(%esp)
f0107d01:	e8 a4 16 00 00       	call   f01093aa <snprintf>
f0107d06:	eb 28                	jmp    f0107d30 <OP_EM+0xcf>
  else
    snprintf (scratchbuf, sizeof(scratchbuf), "%%mm%d", rm + add);
f0107d08:	89 d0                	mov    %edx,%eax
f0107d0a:	03 05 f8 4e 29 f0    	add    0xf0294ef8,%eax
f0107d10:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107d14:	c7 44 24 08 47 bf 10 	movl   $0xf010bf47,0x8(%esp)
f0107d1b:	f0 
f0107d1c:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0107d23:	00 
f0107d24:	c7 04 24 80 4e 29 f0 	movl   $0xf0294e80,(%esp)
f0107d2b:	e8 7a 16 00 00       	call   f01093aa <snprintf>
  oappend (scratchbuf + intel_syntax);
f0107d30:	0f be 05 d0 50 29 f0 	movsbl 0xf02950d0,%eax
f0107d37:	05 80 4e 29 f0       	add    $0xf0294e80,%eax
f0107d3c:	e8 dc e4 ff ff       	call   f010621d <oappend>
}
f0107d41:	c9                   	leave  
f0107d42:	c3                   	ret    

f0107d43 <OP_MS>:

static void
OP_MS (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f0107d43:	55                   	push   %ebp
f0107d44:	89 e5                	mov    %esp,%ebp
f0107d46:	83 ec 08             	sub    $0x8,%esp
  if (mod == 3)
f0107d49:	83 3d f4 4e 29 f0 03 	cmpl   $0x3,0xf0294ef4
f0107d50:	75 14                	jne    f0107d66 <OP_MS+0x23>
    OP_EM (bytemode, sizeflag);
f0107d52:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107d55:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107d59:	8b 45 08             	mov    0x8(%ebp),%eax
f0107d5c:	89 04 24             	mov    %eax,(%esp)
f0107d5f:	e8 fd fe ff ff       	call   f0107c61 <OP_EM>
f0107d64:	eb 05                	jmp    f0107d6b <OP_MS+0x28>
  else
    BadOp ();
f0107d66:	e8 e0 e4 ff ff       	call   f010624b <BadOp>
}
f0107d6b:	c9                   	leave  
f0107d6c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0107d70:	c3                   	ret    

f0107d71 <OP_Rd>:

static void
OP_Rd (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f0107d71:	55                   	push   %ebp
f0107d72:	89 e5                	mov    %esp,%ebp
f0107d74:	83 ec 08             	sub    $0x8,%esp
  if (mod == 3)
f0107d77:	83 3d f4 4e 29 f0 03 	cmpl   $0x3,0xf0294ef4
f0107d7e:	75 14                	jne    f0107d94 <OP_Rd+0x23>
    OP_E (bytemode, sizeflag);
f0107d80:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107d83:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107d87:	8b 45 08             	mov    0x8(%ebp),%eax
f0107d8a:	89 04 24             	mov    %eax,(%esp)
f0107d8d:	e8 d2 f4 ff ff       	call   f0107264 <OP_E>
f0107d92:	eb 05                	jmp    f0107d99 <OP_Rd+0x28>
  else
    BadOp ();
f0107d94:	e8 b2 e4 ff ff       	call   f010624b <BadOp>
}
f0107d99:	c9                   	leave  
f0107d9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0107da0:	c3                   	ret    

f0107da1 <OP_indirE>:

static void
OP_indirE (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f0107da1:	55                   	push   %ebp
f0107da2:	89 e5                	mov    %esp,%ebp
f0107da4:	83 ec 08             	sub    $0x8,%esp
  if (!intel_syntax)
f0107da7:	80 3d d0 50 29 f0 00 	cmpb   $0x0,0xf02950d0
f0107dae:	75 0a                	jne    f0107dba <OP_indirE+0x19>
    oappend ("*");
f0107db0:	b8 0d c0 10 f0       	mov    $0xf010c00d,%eax
f0107db5:	e8 63 e4 ff ff       	call   f010621d <oappend>
  OP_E (bytemode, sizeflag);
f0107dba:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107dbd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107dc1:	8b 45 08             	mov    0x8(%ebp),%eax
f0107dc4:	89 04 24             	mov    %eax,(%esp)
f0107dc7:	e8 98 f4 ff ff       	call   f0107264 <OP_E>
}
f0107dcc:	c9                   	leave  
f0107dcd:	c3                   	ret    

f0107dce <OP_STi>:

static void
OP_STi (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f0107dce:	55                   	push   %ebp
f0107dcf:	89 e5                	mov    %esp,%ebp
f0107dd1:	83 ec 18             	sub    $0x18,%esp
  snprintf (scratchbuf, sizeof(scratchbuf), "%%st(%d)", rm);
f0107dd4:	a1 f8 4e 29 f0       	mov    0xf0294ef8,%eax
f0107dd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107ddd:	c7 44 24 08 0f c0 10 	movl   $0xf010c00f,0x8(%esp)
f0107de4:	f0 
f0107de5:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0107dec:	00 
f0107ded:	c7 04 24 80 4e 29 f0 	movl   $0xf0294e80,(%esp)
f0107df4:	e8 b1 15 00 00       	call   f01093aa <snprintf>
  oappend (scratchbuf + intel_syntax);
f0107df9:	0f be 05 d0 50 29 f0 	movsbl 0xf02950d0,%eax
f0107e00:	05 80 4e 29 f0       	add    $0xf0294e80,%eax
f0107e05:	e8 13 e4 ff ff       	call   f010621d <oappend>
}
f0107e0a:	c9                   	leave  
f0107e0b:	c3                   	ret    

f0107e0c <OP_ST>:

static void
OP_ST (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f0107e0c:	55                   	push   %ebp
f0107e0d:	89 e5                	mov    %esp,%ebp
f0107e0f:	83 ec 08             	sub    $0x8,%esp
  oappend ("%st");
f0107e12:	b8 18 c0 10 f0       	mov    $0xf010c018,%eax
f0107e17:	e8 01 e4 ff ff       	call   f010621d <oappend>
}
f0107e1c:	c9                   	leave  
f0107e1d:	c3                   	ret    

f0107e1e <print_insn_i386>:

int
print_insn_i386 (pc, info)
     bfd_vma pc;
     disassemble_info *info;
{
f0107e1e:	55                   	push   %ebp
f0107e1f:	89 e5                	mov    %esp,%ebp
f0107e21:	57                   	push   %edi
f0107e22:	56                   	push   %esi
f0107e23:	53                   	push   %ebx
f0107e24:	83 ec 4c             	sub    $0x4c,%esp
f0107e27:	8b 75 08             	mov    0x8(%ebp),%esi
f0107e2a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  unsigned char uses_SSE_prefix;
  int sizeflag;
  const char *p;
  struct dis_private priv;

  mode_64bit = (info->mach == bfd_mach_x86_64_intel_syntax
f0107e2d:	8b 45 10             	mov    0x10(%ebp),%eax
f0107e30:	8b 48 0c             	mov    0xc(%eax),%ecx
f0107e33:	8d 41 fd             	lea    -0x3(%ecx),%eax
f0107e36:	83 f8 01             	cmp    $0x1,%eax
f0107e39:	0f 96 c0             	setbe  %al
f0107e3c:	0f b6 c0             	movzbl %al,%eax
f0107e3f:	a3 e0 4d 29 f0       	mov    %eax,0xf0294de0
		|| info->mach == bfd_mach_x86_64);

  if (intel_syntax == -1)
    intel_syntax = (info->mach == bfd_mach_i386_i386_intel_syntax
f0107e44:	83 f9 02             	cmp    $0x2,%ecx
f0107e47:	0f 94 c2             	sete   %dl
f0107e4a:	83 f9 04             	cmp    $0x4,%ecx
f0107e4d:	0f 94 c0             	sete   %al
f0107e50:	09 d0                	or     %edx,%eax
f0107e52:	a2 d0 50 29 f0       	mov    %al,0xf02950d0
		    || info->mach == bfd_mach_x86_64_intel_syntax);

  if (info->mach == bfd_mach_i386_i386
f0107e57:	85 c9                	test   %ecx,%ecx
f0107e59:	74 0f                	je     f0107e6a <print_insn_i386+0x4c>
f0107e5b:	83 f9 03             	cmp    $0x3,%ecx
f0107e5e:	74 0a                	je     f0107e6a <print_insn_i386+0x4c>
f0107e60:	83 f9 02             	cmp    $0x2,%ecx
f0107e63:	74 05                	je     f0107e6a <print_insn_i386+0x4c>
f0107e65:	83 f9 04             	cmp    $0x4,%ecx
f0107e68:	75 09                	jne    f0107e73 <print_insn_i386+0x55>
      || info->mach == bfd_mach_x86_64
      || info->mach == bfd_mach_i386_i386_intel_syntax
      || info->mach == bfd_mach_x86_64_intel_syntax)
    priv.orig_sizeflag = AFLAG | DFLAG;
f0107e6a:	c7 45 f0 03 00 00 00 	movl   $0x3,-0x10(%ebp)
f0107e71:	eb 2b                	jmp    f0107e9e <print_insn_i386+0x80>
  else if (info->mach == bfd_mach_i386_i8086)
f0107e73:	83 f9 01             	cmp    $0x1,%ecx
f0107e76:	75 0a                	jne    f0107e82 <print_insn_i386+0x64>
    priv.orig_sizeflag = 0;
f0107e78:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0107e7f:	90                   	nop    
f0107e80:	eb 1c                	jmp    f0107e9e <print_insn_i386+0x80>
  else
    panic("print_insn:error occured");
f0107e82:	c7 44 24 08 1c c0 10 	movl   $0xf010c01c,0x8(%esp)
f0107e89:	f0 
f0107e8a:	c7 44 24 04 52 07 00 	movl   $0x752,0x4(%esp)
f0107e91:	00 
f0107e92:	c7 04 24 07 bf 10 f0 	movl   $0xf010bf07,(%esp)
f0107e99:	e8 e8 81 ff ff       	call   f0100086 <_panic>

  for (p = info->disassembler_options; p != NULL; )
f0107e9e:	8b 55 10             	mov    0x10(%ebp),%edx
f0107ea1:	8b 5a 68             	mov    0x68(%edx),%ebx
f0107ea4:	85 db                	test   %ebx,%ebx
f0107ea6:	0f 84 a5 01 00 00    	je     f0108051 <print_insn_i386+0x233>
    {
      if (strncmp (p, "x86-64", 6) == 0)
f0107eac:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
f0107eb3:	00 
f0107eb4:	c7 44 24 04 35 c0 10 	movl   $0xf010c035,0x4(%esp)
f0107ebb:	f0 
f0107ebc:	89 1c 24             	mov    %ebx,(%esp)
f0107ebf:	e8 7d 17 00 00       	call   f0109641 <strncmp>
f0107ec4:	85 c0                	test   %eax,%eax
f0107ec6:	75 16                	jne    f0107ede <print_insn_i386+0xc0>
	{
	  mode_64bit = 1;
f0107ec8:	c7 05 e0 4d 29 f0 01 	movl   $0x1,0xf0294de0
f0107ecf:	00 00 00 
	  priv.orig_sizeflag = AFLAG | DFLAG;
f0107ed2:	c7 45 f0 03 00 00 00 	movl   $0x3,-0x10(%ebp)
f0107ed9:	e9 54 01 00 00       	jmp    f0108032 <print_insn_i386+0x214>
	}
      else if (strncmp (p, "i386", 4) == 0)
f0107ede:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0107ee5:	00 
f0107ee6:	c7 44 24 04 3c c0 10 	movl   $0xf010c03c,0x4(%esp)
f0107eed:	f0 
f0107eee:	89 1c 24             	mov    %ebx,(%esp)
f0107ef1:	e8 4b 17 00 00       	call   f0109641 <strncmp>
f0107ef6:	85 c0                	test   %eax,%eax
f0107ef8:	75 16                	jne    f0107f10 <print_insn_i386+0xf2>
	{
	  mode_64bit = 0;
f0107efa:	c7 05 e0 4d 29 f0 00 	movl   $0x0,0xf0294de0
f0107f01:	00 00 00 
	  priv.orig_sizeflag = AFLAG | DFLAG;
f0107f04:	c7 45 f0 03 00 00 00 	movl   $0x3,-0x10(%ebp)
f0107f0b:	e9 22 01 00 00       	jmp    f0108032 <print_insn_i386+0x214>
	}
      else if (strncmp (p, "i8086", 5) == 0)
f0107f10:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
f0107f17:	00 
f0107f18:	c7 44 24 04 41 c0 10 	movl   $0xf010c041,0x4(%esp)
f0107f1f:	f0 
f0107f20:	89 1c 24             	mov    %ebx,(%esp)
f0107f23:	e8 19 17 00 00       	call   f0109641 <strncmp>
f0107f28:	85 c0                	test   %eax,%eax
f0107f2a:	75 16                	jne    f0107f42 <print_insn_i386+0x124>
	{
	  mode_64bit = 0;
f0107f2c:	c7 05 e0 4d 29 f0 00 	movl   $0x0,0xf0294de0
f0107f33:	00 00 00 
	  priv.orig_sizeflag = 0;
f0107f36:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0107f3d:	e9 f0 00 00 00       	jmp    f0108032 <print_insn_i386+0x214>
	}
      else if (strncmp (p, "intel", 5) == 0)
f0107f42:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
f0107f49:	00 
f0107f4a:	c7 44 24 04 47 c0 10 	movl   $0xf010c047,0x4(%esp)
f0107f51:	f0 
f0107f52:	89 1c 24             	mov    %ebx,(%esp)
f0107f55:	e8 e7 16 00 00       	call   f0109641 <strncmp>
f0107f5a:	85 c0                	test   %eax,%eax
f0107f5c:	75 0c                	jne    f0107f6a <print_insn_i386+0x14c>
	{
	  intel_syntax = 1;
f0107f5e:	c6 05 d0 50 29 f0 01 	movb   $0x1,0xf02950d0
f0107f65:	e9 c8 00 00 00       	jmp    f0108032 <print_insn_i386+0x214>
	}
      else if (strncmp (p, "att", 3) == 0)
f0107f6a:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
f0107f71:	00 
f0107f72:	c7 44 24 04 4d c0 10 	movl   $0xf010c04d,0x4(%esp)
f0107f79:	f0 
f0107f7a:	89 1c 24             	mov    %ebx,(%esp)
f0107f7d:	e8 bf 16 00 00       	call   f0109641 <strncmp>
f0107f82:	85 c0                	test   %eax,%eax
f0107f84:	75 0c                	jne    f0107f92 <print_insn_i386+0x174>
	{
	  intel_syntax = 0;
f0107f86:	c6 05 d0 50 29 f0 00 	movb   $0x0,0xf02950d0
f0107f8d:	e9 a0 00 00 00       	jmp    f0108032 <print_insn_i386+0x214>
	}
      else if (strncmp (p, "addr", 4) == 0)
f0107f92:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0107f99:	00 
f0107f9a:	c7 44 24 04 51 c0 10 	movl   $0xf010c051,0x4(%esp)
f0107fa1:	f0 
f0107fa2:	89 1c 24             	mov    %ebx,(%esp)
f0107fa5:	e8 97 16 00 00       	call   f0109641 <strncmp>
f0107faa:	85 c0                	test   %eax,%eax
f0107fac:	75 24                	jne    f0107fd2 <print_insn_i386+0x1b4>
	{
	  if (p[4] == '1' && p[5] == '6')
f0107fae:	0f b6 43 04          	movzbl 0x4(%ebx),%eax
f0107fb2:	3c 31                	cmp    $0x31,%al
f0107fb4:	75 0c                	jne    f0107fc2 <print_insn_i386+0x1a4>
f0107fb6:	80 7b 05 36          	cmpb   $0x36,0x5(%ebx)
f0107fba:	75 06                	jne    f0107fc2 <print_insn_i386+0x1a4>
	    priv.orig_sizeflag &= ~AFLAG;
f0107fbc:	83 65 f0 fd          	andl   $0xfffffffd,-0x10(%ebp)
f0107fc0:	eb 70                	jmp    f0108032 <print_insn_i386+0x214>
	  else if (p[4] == '3' && p[5] == '2')
f0107fc2:	3c 33                	cmp    $0x33,%al
f0107fc4:	75 6c                	jne    f0108032 <print_insn_i386+0x214>
f0107fc6:	80 7b 05 32          	cmpb   $0x32,0x5(%ebx)
f0107fca:	75 66                	jne    f0108032 <print_insn_i386+0x214>
	    priv.orig_sizeflag |= AFLAG;
f0107fcc:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
f0107fd0:	eb 60                	jmp    f0108032 <print_insn_i386+0x214>
	}
      else if (strncmp (p, "data", 4) == 0)
f0107fd2:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0107fd9:	00 
f0107fda:	c7 44 24 04 56 c0 10 	movl   $0xf010c056,0x4(%esp)
f0107fe1:	f0 
f0107fe2:	89 1c 24             	mov    %ebx,(%esp)
f0107fe5:	e8 57 16 00 00       	call   f0109641 <strncmp>
f0107fea:	85 c0                	test   %eax,%eax
f0107fec:	75 24                	jne    f0108012 <print_insn_i386+0x1f4>
	{
	  if (p[4] == '1' && p[5] == '6')
f0107fee:	0f b6 43 04          	movzbl 0x4(%ebx),%eax
f0107ff2:	3c 31                	cmp    $0x31,%al
f0107ff4:	75 0c                	jne    f0108002 <print_insn_i386+0x1e4>
f0107ff6:	80 7b 05 36          	cmpb   $0x36,0x5(%ebx)
f0107ffa:	75 06                	jne    f0108002 <print_insn_i386+0x1e4>
	    priv.orig_sizeflag &= ~DFLAG;
f0107ffc:	83 65 f0 fe          	andl   $0xfffffffe,-0x10(%ebp)
f0108000:	eb 30                	jmp    f0108032 <print_insn_i386+0x214>
	  else if (p[4] == '3' && p[5] == '2')
f0108002:	3c 33                	cmp    $0x33,%al
f0108004:	75 2c                	jne    f0108032 <print_insn_i386+0x214>
f0108006:	80 7b 05 32          	cmpb   $0x32,0x5(%ebx)
f010800a:	75 26                	jne    f0108032 <print_insn_i386+0x214>
	    priv.orig_sizeflag |= DFLAG;
f010800c:	83 4d f0 01          	orl    $0x1,-0x10(%ebp)
f0108010:	eb 20                	jmp    f0108032 <print_insn_i386+0x214>
	}
      else if (strncmp (p, "suffix", 6) == 0)
f0108012:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
f0108019:	00 
f010801a:	c7 44 24 04 5b c0 10 	movl   $0xf010c05b,0x4(%esp)
f0108021:	f0 
f0108022:	89 1c 24             	mov    %ebx,(%esp)
f0108025:	e8 17 16 00 00       	call   f0109641 <strncmp>
f010802a:	85 c0                	test   %eax,%eax
f010802c:	75 04                	jne    f0108032 <print_insn_i386+0x214>
	priv.orig_sizeflag |= SUFFIX_ALWAYS;
f010802e:	83 4d f0 04          	orl    $0x4,-0x10(%ebp)

      p = strchr (p, ',');
f0108032:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
f0108039:	00 
f010803a:	89 1c 24             	mov    %ebx,(%esp)
f010803d:	e8 45 16 00 00       	call   f0109687 <strchr>
      if (p != NULL)
f0108042:	85 c0                	test   %eax,%eax
f0108044:	74 0b                	je     f0108051 <print_insn_i386+0x233>
  else if (info->mach == bfd_mach_i386_i8086)
    priv.orig_sizeflag = 0;
  else
    panic("print_insn:error occured");

  for (p = info->disassembler_options; p != NULL; )
f0108046:	89 c3                	mov    %eax,%ebx
f0108048:	83 c3 01             	add    $0x1,%ebx
f010804b:	0f 85 5b fe ff ff    	jne    f0107eac <print_insn_i386+0x8e>
      p = strchr (p, ',');
      if (p != NULL)
	p++;
    }

  if (intel_syntax)
f0108051:	80 3d d0 50 29 f0 00 	cmpb   $0x0,0xf02950d0
f0108058:	74 64                	je     f01080be <print_insn_i386+0x2a0>
    {
      names64 = intel_names64;
f010805a:	c7 05 04 4f 29 f0 80 	movl   $0xf010d780,0xf0294f04
f0108061:	d7 10 f0 
      names32 = intel_names32;
f0108064:	c7 05 08 4f 29 f0 c0 	movl   $0xf010d7c0,0xf0294f08
f010806b:	d7 10 f0 
      names16 = intel_names16;
f010806e:	c7 05 0c 4f 29 f0 00 	movl   $0xf010d800,0xf0294f0c
f0108075:	d8 10 f0 
      names8 = intel_names8;
f0108078:	c7 05 10 4f 29 f0 40 	movl   $0xf010d840,0xf0294f10
f010807f:	d8 10 f0 
      names8rex = intel_names8rex;
f0108082:	c7 05 14 4f 29 f0 60 	movl   $0xf010d860,0xf0294f14
f0108089:	d8 10 f0 
      names_seg = intel_names_seg;
f010808c:	c7 05 18 4f 29 f0 a0 	movl   $0xf010d8a0,0xf0294f18
f0108093:	d8 10 f0 
      index16 = intel_index16;
f0108096:	c7 05 1c 4f 29 f0 c0 	movl   $0xf010d8c0,0xf0294f1c
f010809d:	d8 10 f0 
      open_char = '[';
f01080a0:	c6 05 d1 50 29 f0 5b 	movb   $0x5b,0xf02950d1
      close_char = ']';
f01080a7:	c6 05 d2 50 29 f0 5d 	movb   $0x5d,0xf02950d2
      separator_char = '+';
f01080ae:	c6 05 d3 50 29 f0 2b 	movb   $0x2b,0xf02950d3
      scale_char = '*';
f01080b5:	c6 05 d4 50 29 f0 2a 	movb   $0x2a,0xf02950d4
f01080bc:	eb 62                	jmp    f0108120 <print_insn_i386+0x302>
    }
  else
    {
      names64 = att_names64;
f01080be:	c7 05 04 4f 29 f0 e0 	movl   $0xf010d8e0,0xf0294f04
f01080c5:	d8 10 f0 
      names32 = att_names32;
f01080c8:	c7 05 08 4f 29 f0 20 	movl   $0xf010d920,0xf0294f08
f01080cf:	d9 10 f0 
      names16 = att_names16;
f01080d2:	c7 05 0c 4f 29 f0 60 	movl   $0xf010d960,0xf0294f0c
f01080d9:	d9 10 f0 
      names8 = att_names8;
f01080dc:	c7 05 10 4f 29 f0 a0 	movl   $0xf010d9a0,0xf0294f10
f01080e3:	d9 10 f0 
      names8rex = att_names8rex;
f01080e6:	c7 05 14 4f 29 f0 c0 	movl   $0xf010d9c0,0xf0294f14
f01080ed:	d9 10 f0 
      names_seg = att_names_seg;
f01080f0:	c7 05 18 4f 29 f0 00 	movl   $0xf010da00,0xf0294f18
f01080f7:	da 10 f0 
      index16 = att_index16;
f01080fa:	c7 05 1c 4f 29 f0 20 	movl   $0xf010da20,0xf0294f1c
f0108101:	da 10 f0 
      open_char = '(';
f0108104:	c6 05 d1 50 29 f0 28 	movb   $0x28,0xf02950d1
      close_char =  ')';
f010810b:	c6 05 d2 50 29 f0 29 	movb   $0x29,0xf02950d2
      separator_char = ',';
f0108112:	c6 05 d3 50 29 f0 2c 	movb   $0x2c,0xf02950d3
      scale_char = ',';
f0108119:	c6 05 d4 50 29 f0 2c 	movb   $0x2c,0xf02950d4
    }
   //cprintf("intel_syntax2=%d\n",intel_syntax);
  /* The output looks better if we put 7 bytes on a line, since that
     puts most long word instructions on a single line.  */
  info->bytes_per_line = 7;
f0108120:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0108123:	c7 41 44 07 00 00 00 	movl   $0x7,0x44(%ecx)
  
  info->private_data = (PTR) &priv;
f010812a:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010812d:	89 41 20             	mov    %eax,0x20(%ecx)
  priv.max_fetched = priv.the_buffer;
f0108130:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f0108133:	89 45 d0             	mov    %eax,-0x30(%ebp)
  priv.insn_start = pc;
f0108136:	89 75 e8             	mov    %esi,-0x18(%ebp)
f0108139:	89 7d ec             	mov    %edi,-0x14(%ebp)

  obuf[0] = 0;
f010813c:	c6 05 00 4e 29 f0 00 	movb   $0x0,0xf0294e00
  op1out[0] = 0;
f0108143:	c6 05 20 4f 29 f0 00 	movb   $0x0,0xf0294f20
  op2out[0] = 0;
f010814a:	c6 05 a0 4f 29 f0 00 	movb   $0x0,0xf0294fa0
  op3out[0] = 0;
f0108151:	c6 05 20 50 29 f0 00 	movb   $0x0,0xf0295020

  op_index[0] = op_index[1] = op_index[2] = -1;
f0108158:	c7 05 90 50 29 f0 ff 	movl   $0xffffffff,0xf0295090
f010815f:	ff ff ff 
f0108162:	c7 05 8c 50 29 f0 ff 	movl   $0xffffffff,0xf029508c
f0108169:	ff ff ff 
f010816c:	c7 05 88 50 29 f0 ff 	movl   $0xffffffff,0xf0295088
f0108173:	ff ff ff 

  the_info = info;
f0108176:	89 0d f0 4e 29 f0    	mov    %ecx,0xf0294ef0
 // cprintf("the_info:buffer_length=%d\n",the_info->buffer_length);
  start_pc = pc;
f010817c:	89 35 c8 50 29 f0    	mov    %esi,0xf02950c8
f0108182:	89 3d cc 50 29 f0    	mov    %edi,0xf02950cc
  start_codep = priv.the_buffer;
f0108188:	a3 e4 4e 29 f0       	mov    %eax,0xf0294ee4
  codep = priv.the_buffer;
f010818d:	a3 ec 4e 29 f0       	mov    %eax,0xf0294eec
	}

      return -1;
    }

  obufp = obuf;
f0108192:	c7 05 64 4e 29 f0 00 	movl   $0xf0294e00,0xf0294e64
f0108199:	4e 29 f0 

static void
ckprefix ()
{
  int newrex;
  rex = 0;
f010819c:	c7 05 e8 4d 29 f0 00 	movl   $0x0,0xf0294de8
f01081a3:	00 00 00 
  prefixes = 0;
f01081a6:	c7 05 e4 4d 29 f0 00 	movl   $0x0,0xf0294de4
f01081ad:	00 00 00 
  used_prefixes = 0;
f01081b0:	c7 05 f0 4d 29 f0 00 	movl   $0x0,0xf0294df0
f01081b7:	00 00 00 
  rex_used = 0;
f01081ba:	c7 05 ec 4d 29 f0 00 	movl   $0x0,0xf0294dec
f01081c1:	00 00 00 
  while (1)
    {
      FETCH_DATA (the_info, codep + 1);
f01081c4:	8b 15 ec 4e 29 f0    	mov    0xf0294eec,%edx
f01081ca:	83 c2 01             	add    $0x1,%edx
f01081cd:	8b 0d f0 4e 29 f0    	mov    0xf0294ef0,%ecx
f01081d3:	8b 41 20             	mov    0x20(%ecx),%eax
f01081d6:	3b 10                	cmp    (%eax),%edx
f01081d8:	76 07                	jbe    f01081e1 <print_insn_i386+0x3c3>
f01081da:	89 c8                	mov    %ecx,%eax
f01081dc:	e8 bf d4 ff ff       	call   f01056a0 <fetch_data>
      newrex = 0;
      switch (*codep)
f01081e1:	8b 0d ec 4e 29 f0    	mov    0xf0294eec,%ecx
f01081e7:	0f b6 11             	movzbl (%ecx),%edx
f01081ea:	80 fa 64             	cmp    $0x64,%dl
f01081ed:	0f 84 25 01 00 00    	je     f0108318 <print_insn_i386+0x4fa>
f01081f3:	80 fa 64             	cmp    $0x64,%dl
f01081f6:	77 4b                	ja     f0108243 <print_insn_i386+0x425>
f01081f8:	80 fa 36             	cmp    $0x36,%dl
f01081fb:	0f 84 ea 00 00 00    	je     f01082eb <print_insn_i386+0x4cd>
f0108201:	80 fa 36             	cmp    $0x36,%dl
f0108204:	77 17                	ja     f010821d <print_insn_i386+0x3ff>
f0108206:	80 fa 26             	cmp    $0x26,%dl
f0108209:	0f 84 fb 00 00 00    	je     f010830a <print_insn_i386+0x4ec>
f010820f:	80 fa 2e             	cmp    $0x2e,%dl
f0108212:	0f 85 a2 01 00 00    	jne    f01083ba <print_insn_i386+0x59c>
f0108218:	e9 bd 00 00 00       	jmp    f01082da <print_insn_i386+0x4bc>
f010821d:	80 fa 3e             	cmp    $0x3e,%dl
f0108220:	0f 84 d6 00 00 00    	je     f01082fc <print_insn_i386+0x4de>
f0108226:	80 fa 3e             	cmp    $0x3e,%dl
f0108229:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
f0108230:	0f 82 84 01 00 00    	jb     f01083ba <print_insn_i386+0x59c>
f0108236:	8d 42 c0             	lea    -0x40(%edx),%eax
f0108239:	3c 0f                	cmp    $0xf,%al
f010823b:	0f 87 79 01 00 00    	ja     f01083ba <print_insn_i386+0x59c>
f0108241:	eb 4f                	jmp    f0108292 <print_insn_i386+0x474>
f0108243:	80 fa 9b             	cmp    $0x9b,%dl
f0108246:	0f 84 10 01 00 00    	je     f010835c <print_insn_i386+0x53e>
f010824c:	80 fa 9b             	cmp    $0x9b,%dl
f010824f:	90                   	nop    
f0108250:	77 23                	ja     f0108275 <print_insn_i386+0x457>
f0108252:	80 fa 66             	cmp    $0x66,%dl
f0108255:	0f 84 df 00 00 00    	je     f010833a <print_insn_i386+0x51c>
f010825b:	80 fa 66             	cmp    $0x66,%dl
f010825e:	66 90                	xchg   %ax,%ax
f0108260:	0f 82 c3 00 00 00    	jb     f0108329 <print_insn_i386+0x50b>
f0108266:	80 fa 67             	cmp    $0x67,%dl
f0108269:	0f 85 4b 01 00 00    	jne    f01083ba <print_insn_i386+0x59c>
f010826f:	90                   	nop    
f0108270:	e9 d6 00 00 00       	jmp    f010834b <print_insn_i386+0x52d>
f0108275:	80 fa f2             	cmp    $0xf2,%dl
f0108278:	74 3e                	je     f01082b8 <print_insn_i386+0x49a>
f010827a:	80 fa f3             	cmp    $0xf3,%dl
f010827d:	8d 76 00             	lea    0x0(%esi),%esi
f0108280:	74 25                	je     f01082a7 <print_insn_i386+0x489>
f0108282:	80 fa f0             	cmp    $0xf0,%dl
f0108285:	0f 85 2f 01 00 00    	jne    f01083ba <print_insn_i386+0x59c>
f010828b:	90                   	nop    
f010828c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0108290:	eb 37                	jmp    f01082c9 <print_insn_i386+0x4ab>
	case 0x4b:
	case 0x4c:
	case 0x4d:
	case 0x4e:
	case 0x4f:
	    if (mode_64bit)
f0108292:	83 3d e0 4d 29 f0 00 	cmpl   $0x0,0xf0294de0
f0108299:	0f 84 1b 01 00 00    	je     f01083ba <print_insn_i386+0x59c>
  rex_used = 0;
  while (1)
    {
      FETCH_DATA (the_info, codep + 1);
      newrex = 0;
      switch (*codep)
f010829f:	0f b6 da             	movzbl %dl,%ebx
f01082a2:	e9 df 00 00 00       	jmp    f0108386 <print_insn_i386+0x568>
	      newrex = *codep;
	    else
	      return;
	  break;
	case 0xf3:
	  prefixes |= PREFIX_REPZ;
f01082a7:	83 0d e4 4d 29 f0 01 	orl    $0x1,0xf0294de4
f01082ae:	bb 00 00 00 00       	mov    $0x0,%ebx
f01082b3:	e9 ce 00 00 00       	jmp    f0108386 <print_insn_i386+0x568>
	  break;
	case 0xf2:
	  prefixes |= PREFIX_REPNZ;
f01082b8:	83 0d e4 4d 29 f0 02 	orl    $0x2,0xf0294de4
f01082bf:	bb 00 00 00 00       	mov    $0x0,%ebx
f01082c4:	e9 bd 00 00 00       	jmp    f0108386 <print_insn_i386+0x568>
	  break;
	case 0xf0:
	  prefixes |= PREFIX_LOCK;
f01082c9:	83 0d e4 4d 29 f0 04 	orl    $0x4,0xf0294de4
f01082d0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01082d5:	e9 ac 00 00 00       	jmp    f0108386 <print_insn_i386+0x568>
	  break;
	case 0x2e:
	  prefixes |= PREFIX_CS;
f01082da:	83 0d e4 4d 29 f0 08 	orl    $0x8,0xf0294de4
f01082e1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01082e6:	e9 9b 00 00 00       	jmp    f0108386 <print_insn_i386+0x568>
	  break;
	case 0x36:
	  prefixes |= PREFIX_SS;
f01082eb:	83 0d e4 4d 29 f0 10 	orl    $0x10,0xf0294de4
f01082f2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01082f7:	e9 8a 00 00 00       	jmp    f0108386 <print_insn_i386+0x568>
	  break;
	case 0x3e:
	  prefixes |= PREFIX_DS;
f01082fc:	83 0d e4 4d 29 f0 20 	orl    $0x20,0xf0294de4
f0108303:	bb 00 00 00 00       	mov    $0x0,%ebx
f0108308:	eb 7c                	jmp    f0108386 <print_insn_i386+0x568>
	  break;
	case 0x26:
	  prefixes |= PREFIX_ES;
f010830a:	83 0d e4 4d 29 f0 40 	orl    $0x40,0xf0294de4
f0108311:	bb 00 00 00 00       	mov    $0x0,%ebx
f0108316:	eb 6e                	jmp    f0108386 <print_insn_i386+0x568>
	  break;
	case 0x64:
	  prefixes |= PREFIX_FS;
f0108318:	81 0d e4 4d 29 f0 80 	orl    $0x80,0xf0294de4
f010831f:	00 00 00 
f0108322:	bb 00 00 00 00       	mov    $0x0,%ebx
f0108327:	eb 5d                	jmp    f0108386 <print_insn_i386+0x568>
	  break;
	case 0x65:
	  prefixes |= PREFIX_GS;
f0108329:	81 0d e4 4d 29 f0 00 	orl    $0x100,0xf0294de4
f0108330:	01 00 00 
f0108333:	bb 00 00 00 00       	mov    $0x0,%ebx
f0108338:	eb 4c                	jmp    f0108386 <print_insn_i386+0x568>
	  break;
	case 0x66:
	  prefixes |= PREFIX_DATA;
f010833a:	81 0d e4 4d 29 f0 00 	orl    $0x200,0xf0294de4
f0108341:	02 00 00 
f0108344:	bb 00 00 00 00       	mov    $0x0,%ebx
f0108349:	eb 3b                	jmp    f0108386 <print_insn_i386+0x568>
	  break;
	case 0x67:
	  prefixes |= PREFIX_ADDR;
f010834b:	81 0d e4 4d 29 f0 00 	orl    $0x400,0xf0294de4
f0108352:	04 00 00 
f0108355:	bb 00 00 00 00       	mov    $0x0,%ebx
f010835a:	eb 2a                	jmp    f0108386 <print_insn_i386+0x568>
	  break;
	case FWAIT_OPCODE:
	  /* fwait is really an instruction.  If there are prefixes
	     before the fwait, they belong to the fwait, *not* to the
	     following instruction.  */
	  if (prefixes)
f010835c:	a1 e4 4d 29 f0       	mov    0xf0294de4,%eax
f0108361:	85 c0                	test   %eax,%eax
f0108363:	74 12                	je     f0108377 <print_insn_i386+0x559>
	    {
	      prefixes |= PREFIX_FWAIT;
f0108365:	80 cc 08             	or     $0x8,%ah
f0108368:	a3 e4 4d 29 f0       	mov    %eax,0xf0294de4
	      codep++;
f010836d:	8d 41 01             	lea    0x1(%ecx),%eax
f0108370:	a3 ec 4e 29 f0       	mov    %eax,0xf0294eec
f0108375:	eb 43                	jmp    f01083ba <print_insn_i386+0x59c>
	      return;
	    }
	  prefixes = PREFIX_FWAIT;
f0108377:	c7 05 e4 4d 29 f0 00 	movl   $0x800,0xf0294de4
f010837e:	08 00 00 
f0108381:	bb 00 00 00 00       	mov    $0x0,%ebx
	  break;
	default:
	  return;
	}
      /* Rex is ignored when followed by another prefix.  */
      if (rex)
f0108386:	a1 e8 4d 29 f0       	mov    0xf0294de8,%eax
f010838b:	85 c0                	test   %eax,%eax
f010838d:	74 19                	je     f01083a8 <print_insn_i386+0x58a>
	{
	  oappend (prefix_name (rex, 0));
f010838f:	ba 00 00 00 00       	mov    $0x0,%edx
f0108394:	e8 92 d3 ff ff       	call   f010572b <prefix_name>
f0108399:	e8 7f de ff ff       	call   f010621d <oappend>
	  oappend (" ");
f010839e:	b8 97 aa 10 f0       	mov    $0xf010aa97,%eax
f01083a3:	e8 75 de ff ff       	call   f010621d <oappend>
	}
      rex = newrex;
f01083a8:	89 1d e8 4d 29 f0    	mov    %ebx,0xf0294de8
      codep++;
f01083ae:	83 05 ec 4e 29 f0 01 	addl   $0x1,0xf0294eec
f01083b5:	e9 0a fe ff ff       	jmp    f01081c4 <print_insn_i386+0x3a6>
    }

  obufp = obuf;
  ckprefix ();

  insn_codep = codep;
f01083ba:	a1 ec 4e 29 f0       	mov    0xf0294eec,%eax
f01083bf:	a3 e8 4e 29 f0       	mov    %eax,0xf0294ee8
  sizeflag = priv.orig_sizeflag;
f01083c4:	8b 7d f0             	mov    -0x10(%ebp),%edi

  FETCH_DATA (info, codep + 1);
f01083c7:	8d 50 01             	lea    0x1(%eax),%edx
f01083ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01083cd:	8b 41 20             	mov    0x20(%ecx),%eax
f01083d0:	3b 10                	cmp    (%eax),%edx
f01083d2:	76 07                	jbe    f01083db <print_insn_i386+0x5bd>
f01083d4:	89 c8                	mov    %ecx,%eax
f01083d6:	e8 c5 d2 ff ff       	call   f01056a0 <fetch_data>
  //cprintf("***************print_insn:codep1=%x******************\n",*codep);
  two_source_ops = (*codep == 0x62) || (*codep == 0xc8);
f01083db:	8b 0d ec 4e 29 f0    	mov    0xf0294eec,%ecx
f01083e1:	0f b6 01             	movzbl (%ecx),%eax
f01083e4:	88 45 c3             	mov    %al,-0x3d(%ebp)

  if ((prefixes & PREFIX_FWAIT)
f01083e7:	f6 05 e5 4d 29 f0 08 	testb  $0x8,0xf0294de5
f01083ee:	74 36                	je     f0108426 <print_insn_i386+0x608>
f01083f0:	83 c0 28             	add    $0x28,%eax
f01083f3:	3c 07                	cmp    $0x7,%al
f01083f5:	76 2f                	jbe    f0108426 <print_insn_i386+0x608>
    {
      const char *name;

      /* fwait not followed by floating point instruction.  Print the
         first prefix, which is probably fwait itself.  */
      name = prefix_name (priv.the_buffer[0], priv.orig_sizeflag);
f01083f7:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01083fa:	0f b6 45 d4          	movzbl -0x2c(%ebp),%eax
f01083fe:	e8 28 d3 ff ff       	call   f010572b <prefix_name>
      if (name == NULL)
f0108403:	85 c0                	test   %eax,%eax
f0108405:	75 05                	jne    f010840c <print_insn_i386+0x5ee>
f0108407:	b8 82 bf 10 f0       	mov    $0xf010bf82,%eax
	name = INTERNAL_DISASSEMBLER_ERROR;
      /*****************************************/
      //Add your code here,print name
      cprintf("%s",name);
f010840c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108410:	c7 04 24 be b6 10 f0 	movl   $0xf010b6be,(%esp)
f0108417:	e8 cb b5 ff ff       	call   f01039e7 <cprintf>
f010841c:	b8 01 00 00 00       	mov    $0x1,%eax
f0108421:	e9 5f 07 00 00       	jmp    f0108b85 <print_insn_i386+0xd67>
      return 1;
    }

  if (*codep == 0x0f)
f0108426:	80 7d c3 0f          	cmpb   $0xf,-0x3d(%ebp)
f010842a:	75 4d                	jne    f0108479 <print_insn_i386+0x65b>
    {
      FETCH_DATA (info, codep + 2);
f010842c:	8d 51 02             	lea    0x2(%ecx),%edx
f010842f:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0108432:	8b 41 20             	mov    0x20(%ecx),%eax
f0108435:	3b 10                	cmp    (%eax),%edx
f0108437:	76 07                	jbe    f0108440 <print_insn_i386+0x622>
f0108439:	89 c8                	mov    %ecx,%eax
f010843b:	e8 60 d2 ff ff       	call   f01056a0 <fetch_data>
      dp = &dis386_twobyte[*++codep];
f0108440:	8b 0d ec 4e 29 f0    	mov    0xf0294eec,%ecx
f0108446:	83 c1 01             	add    $0x1,%ecx
f0108449:	0f b6 11             	movzbl (%ecx),%edx
f010844c:	6b c2 1c             	imul   $0x1c,%edx,%eax
f010844f:	8d 98 40 da 10 f0    	lea    -0xfef25c0(%eax),%ebx
      need_modrm = twobyte_has_modrm[*codep];
f0108455:	0f b6 82 40 f6 10 f0 	movzbl -0xfef09c0(%edx),%eax
f010845c:	a2 00 4f 29 f0       	mov    %al,0xf0294f00
      uses_SSE_prefix = twobyte_uses_SSE_prefix[*codep];
f0108461:	0f b6 b2 40 f7 10 f0 	movzbl -0xfef08c0(%edx),%esi
      dp = &dis386[*codep];
      need_modrm = onebyte_has_modrm[*codep];
      uses_SSE_prefix = 0;
      //cprintf("codep=%x neda_modrm=%d\n",*codep,need_modrm);
    }
  codep++;
f0108468:	83 c1 01             	add    $0x1,%ecx
f010846b:	89 0d ec 4e 29 f0    	mov    %ecx,0xf0294eec

  if (!uses_SSE_prefix && (prefixes & PREFIX_REPZ))
f0108471:	89 f0                	mov    %esi,%eax
f0108473:	84 c0                	test   %al,%al
f0108475:	74 28                	je     f010849f <print_insn_i386+0x681>
f0108477:	eb 5a                	jmp    f01084d3 <print_insn_i386+0x6b5>
      uses_SSE_prefix = twobyte_uses_SSE_prefix[*codep];
    }
  else
    {
     // cprintf("**********codep=%x*********\n",*codep);	
      dp = &dis386[*codep];
f0108479:	0f b6 55 c3          	movzbl -0x3d(%ebp),%edx
f010847d:	6b c2 1c             	imul   $0x1c,%edx,%eax
f0108480:	8d 98 40 f8 10 f0    	lea    -0xfef07c0(%eax),%ebx
      need_modrm = onebyte_has_modrm[*codep];
f0108486:	0f b6 82 40 14 11 f0 	movzbl -0xfeeebc0(%edx),%eax
f010848d:	a2 00 4f 29 f0       	mov    %al,0xf0294f00
      uses_SSE_prefix = 0;
      //cprintf("codep=%x neda_modrm=%d\n",*codep,need_modrm);
    }
  codep++;
f0108492:	8d 41 01             	lea    0x1(%ecx),%eax
f0108495:	a3 ec 4e 29 f0       	mov    %eax,0xf0294eec
f010849a:	be 00 00 00 00       	mov    $0x0,%esi

  if (!uses_SSE_prefix && (prefixes & PREFIX_REPZ))
f010849f:	f6 05 e4 4d 29 f0 01 	testb  $0x1,0xf0294de4
f01084a6:	0f 84 bc 06 00 00    	je     f0108b68 <print_insn_i386+0xd4a>
    {
      oappend ("repz ");
f01084ac:	b8 62 c0 10 f0       	mov    $0xf010c062,%eax
f01084b1:	e8 67 dd ff ff       	call   f010621d <oappend>
      used_prefixes |= PREFIX_REPZ;
f01084b6:	83 0d f0 4d 29 f0 01 	orl    $0x1,0xf0294df0
f01084bd:	e9 a6 06 00 00       	jmp    f0108b68 <print_insn_i386+0xd4a>
    }
  if (!uses_SSE_prefix && (prefixes & PREFIX_REPNZ))
    {
      oappend ("repnz ");
f01084c2:	b8 68 c0 10 f0       	mov    $0xf010c068,%eax
f01084c7:	e8 51 dd ff ff       	call   f010621d <oappend>
      used_prefixes |= PREFIX_REPNZ;
f01084cc:	83 0d f0 4d 29 f0 02 	orl    $0x2,0xf0294df0
    }
  if (prefixes & PREFIX_LOCK)
f01084d3:	f6 05 e4 4d 29 f0 04 	testb  $0x4,0xf0294de4
f01084da:	74 11                	je     f01084ed <print_insn_i386+0x6cf>
    {
      oappend ("lock ");
f01084dc:	b8 6f c0 10 f0       	mov    $0xf010c06f,%eax
f01084e1:	e8 37 dd ff ff       	call   f010621d <oappend>
      used_prefixes |= PREFIX_LOCK;
f01084e6:	83 0d f0 4d 29 f0 04 	orl    $0x4,0xf0294df0
    }

  if (prefixes & PREFIX_ADDR)
f01084ed:	f6 05 e5 4d 29 f0 04 	testb  $0x4,0xf0294de5
f01084f4:	74 43                	je     f0108539 <print_insn_i386+0x71b>
    {
      sizeflag ^= AFLAG;
f01084f6:	83 f7 02             	xor    $0x2,%edi
      if (dp->bytemode3 != loop_jcxz_mode || intel_syntax)
f01084f9:	83 7b 18 09          	cmpl   $0x9,0x18(%ebx)
f01084fd:	75 09                	jne    f0108508 <print_insn_i386+0x6ea>
f01084ff:	80 3d d0 50 29 f0 00 	cmpb   $0x0,0xf02950d0
f0108506:	74 31                	je     f0108539 <print_insn_i386+0x71b>
	{
	  if ((sizeflag & AFLAG) || mode_64bit)
f0108508:	f7 c7 02 00 00 00    	test   $0x2,%edi
f010850e:	75 09                	jne    f0108519 <print_insn_i386+0x6fb>
f0108510:	83 3d e0 4d 29 f0 00 	cmpl   $0x0,0xf0294de0
f0108517:	74 0c                	je     f0108525 <print_insn_i386+0x707>
	    oappend ("addr32 ");
f0108519:	b8 75 c0 10 f0       	mov    $0xf010c075,%eax
f010851e:	e8 fa dc ff ff       	call   f010621d <oappend>
f0108523:	eb 0a                	jmp    f010852f <print_insn_i386+0x711>
	  else
	    oappend ("addr16 ");
f0108525:	b8 7d c0 10 f0       	mov    $0xf010c07d,%eax
f010852a:	e8 ee dc ff ff       	call   f010621d <oappend>
	  used_prefixes |= PREFIX_ADDR;
f010852f:	81 0d f0 4d 29 f0 00 	orl    $0x400,0xf0294df0
f0108536:	04 00 00 
	}
    }

  if (!uses_SSE_prefix && (prefixes & PREFIX_DATA))
f0108539:	89 f2                	mov    %esi,%edx
f010853b:	84 d2                	test   %dl,%dl
f010853d:	75 49                	jne    f0108588 <print_insn_i386+0x76a>
f010853f:	f6 05 e5 4d 29 f0 02 	testb  $0x2,0xf0294de5
f0108546:	74 40                	je     f0108588 <print_insn_i386+0x76a>
    {
      sizeflag ^= DFLAG;
f0108548:	83 f7 01             	xor    $0x1,%edi
      if (dp->bytemode3 == cond_jump_mode
f010854b:	83 7b 18 08          	cmpl   $0x8,0x18(%ebx)
f010854f:	75 37                	jne    f0108588 <print_insn_i386+0x76a>
f0108551:	83 7b 08 02          	cmpl   $0x2,0x8(%ebx)
f0108555:	75 31                	jne    f0108588 <print_insn_i386+0x76a>
f0108557:	80 3d d0 50 29 f0 00 	cmpb   $0x0,0xf02950d0
f010855e:	75 28                	jne    f0108588 <print_insn_i386+0x76a>
	  && dp->bytemode1 == v_mode
	  && !intel_syntax)
	{
	  if (sizeflag & DFLAG)
f0108560:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0108566:	74 0c                	je     f0108574 <print_insn_i386+0x756>
	    oappend ("data32 ");
f0108568:	b8 85 c0 10 f0       	mov    $0xf010c085,%eax
f010856d:	e8 ab dc ff ff       	call   f010621d <oappend>
f0108572:	eb 0a                	jmp    f010857e <print_insn_i386+0x760>
	  else
	    oappend ("data16 ");
f0108574:	b8 8d c0 10 f0       	mov    $0xf010c08d,%eax
f0108579:	e8 9f dc ff ff       	call   f010621d <oappend>
	  used_prefixes |= PREFIX_DATA;
f010857e:	81 0d f0 4d 29 f0 00 	orl    $0x200,0xf0294df0
f0108585:	02 00 00 
	}
    }

  if (need_modrm)
f0108588:	80 3d 00 4f 29 f0 00 	cmpb   $0x0,0xf0294f00
f010858f:	74 45                	je     f01085d6 <print_insn_i386+0x7b8>
    {
      FETCH_DATA (info, codep + 1);
f0108591:	8b 15 ec 4e 29 f0    	mov    0xf0294eec,%edx
f0108597:	83 c2 01             	add    $0x1,%edx
f010859a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010859d:	8b 41 20             	mov    0x20(%ecx),%eax
f01085a0:	3b 10                	cmp    (%eax),%edx
f01085a2:	76 07                	jbe    f01085ab <print_insn_i386+0x78d>
f01085a4:	89 c8                	mov    %ecx,%eax
f01085a6:	e8 f5 d0 ff ff       	call   f01056a0 <fetch_data>
      mod = (*codep >> 6) & 3;
f01085ab:	a1 ec 4e 29 f0       	mov    0xf0294eec,%eax
f01085b0:	0f b6 10             	movzbl (%eax),%edx
f01085b3:	89 d0                	mov    %edx,%eax
f01085b5:	c0 e8 06             	shr    $0x6,%al
f01085b8:	83 e0 03             	and    $0x3,%eax
f01085bb:	a3 f4 4e 29 f0       	mov    %eax,0xf0294ef4
      reg = (*codep >> 3) & 7;
f01085c0:	89 d0                	mov    %edx,%eax
f01085c2:	c0 e8 03             	shr    $0x3,%al
f01085c5:	83 e0 07             	and    $0x7,%eax
f01085c8:	a3 fc 4e 29 f0       	mov    %eax,0xf0294efc
      rm = *codep & 7;
f01085cd:	83 e2 07             	and    $0x7,%edx
f01085d0:	89 15 f8 4e 29 f0    	mov    %edx,0xf0294ef8
      //cprintf("need_modrm:mod=%x reg=%x rm=%x\n",mod,reg,rm);
    }

  if (dp->name == NULL && dp->bytemode1 == FLOATCODE)
f01085d6:	83 3b 00             	cmpl   $0x0,(%ebx)
f01085d9:	0f 85 26 02 00 00    	jne    f0108805 <print_insn_i386+0x9e7>
f01085df:	8b 43 08             	mov    0x8(%ebx),%eax
f01085e2:	83 f8 01             	cmp    $0x1,%eax
f01085e5:	0f 85 6e 01 00 00    	jne    f0108759 <print_insn_i386+0x93b>
     int sizeflag;
{
  const struct dis386 *dp;
  unsigned char floatop;

  floatop = codep[-1];
f01085eb:	a1 ec 4e 29 f0       	mov    0xf0294eec,%eax
f01085f0:	0f b6 58 ff          	movzbl -0x1(%eax),%ebx

  if (mod != 3)
f01085f4:	83 3d f4 4e 29 f0 03 	cmpl   $0x3,0xf0294ef4
f01085fb:	74 6d                	je     f010866a <print_insn_i386+0x84c>
    {
      putop (float_mem[(floatop - 0xd8) * 8 + reg], sizeflag);
f01085fd:	0f b6 c3             	movzbl %bl,%eax
f0108600:	c1 e0 03             	shl    $0x3,%eax
f0108603:	03 05 fc 4e 29 f0    	add    0xf0294efc,%eax
f0108609:	8b 04 85 a0 1e 11 f0 	mov    -0xfeee160(,%eax,4),%eax
f0108610:	89 fa                	mov    %edi,%edx
f0108612:	e8 a0 d4 ff ff       	call   f0105ab7 <putop>
      obufp = op1out;
f0108617:	c7 05 64 4e 29 f0 20 	movl   $0xf0294f20,0xf0294e64
f010861e:	4f 29 f0 
      if (floatop == 0xdb)
f0108621:	80 fb db             	cmp    $0xdb,%bl
f0108624:	75 15                	jne    f010863b <print_insn_i386+0x81d>
        OP_E (x_mode, sizeflag);
f0108626:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010862a:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
f0108631:	e8 2e ec ff ff       	call   f0107264 <OP_E>
f0108636:	e9 4c 02 00 00       	jmp    f0108887 <print_insn_i386+0xa69>
      else if (floatop == 0xdd)
f010863b:	80 fb dd             	cmp    $0xdd,%bl
f010863e:	75 15                	jne    f0108655 <print_insn_i386+0x837>
        OP_E (d_mode, sizeflag);
f0108640:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0108644:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
f010864b:	e8 14 ec ff ff       	call   f0107264 <OP_E>
f0108650:	e9 32 02 00 00       	jmp    f0108887 <print_insn_i386+0xa69>
      else
        OP_E (v_mode, sizeflag);
f0108655:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0108659:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
f0108660:	e8 ff eb ff ff       	call   f0107264 <OP_E>
f0108665:	e9 1d 02 00 00       	jmp    f0108887 <print_insn_i386+0xa69>
      return;
    }
  /* Skip mod/rm byte.  */
  MODRM_CHECK;
f010866a:	80 3d 00 4f 29 f0 00 	cmpb   $0x0,0xf0294f00
f0108671:	75 1c                	jne    f010868f <print_insn_i386+0x871>
f0108673:	c7 44 24 08 c4 bf 10 	movl   $0xf010bfc4,0x8(%esp)
f010867a:	f0 
f010867b:	c7 44 24 04 ef 09 00 	movl   $0x9ef,0x4(%esp)
f0108682:	00 
f0108683:	c7 04 24 07 bf 10 f0 	movl   $0xf010bf07,(%esp)
f010868a:	e8 f7 79 ff ff       	call   f0100086 <_panic>
  codep++;
f010868f:	83 c0 01             	add    $0x1,%eax
f0108692:	a3 ec 4e 29 f0       	mov    %eax,0xf0294eec
  dp = &float_reg[floatop - 0xd8][reg];
f0108697:	0f b6 c3             	movzbl %bl,%eax
f010869a:	69 c0 e0 00 00 00    	imul   $0xe0,%eax,%eax
f01086a0:	6b 15 fc 4e 29 f0 1c 	imul   $0x1c,0xf0294efc,%edx
f01086a7:	01 d0                	add    %edx,%eax
f01086a9:	8d b0 a0 7d 10 f0    	lea    -0xfef8260(%eax),%esi
  if (dp->name == NULL)
f01086af:	8b 80 a0 7d 10 f0    	mov    -0xfef8260(%eax),%eax
f01086b5:	85 c0                	test   %eax,%eax
f01086b7:	75 56                	jne    f010870f <print_insn_i386+0x8f1>
    {
      putop (fgrps[dp->bytemode1][rm], sizeflag);
f01086b9:	8b 46 08             	mov    0x8(%esi),%eax
f01086bc:	c1 e0 03             	shl    $0x3,%eax
f01086bf:	03 05 f8 4e 29 f0    	add    0xf0294ef8,%eax
f01086c5:	8b 04 85 a0 41 11 f0 	mov    -0xfeebe60(,%eax,4),%eax
f01086cc:	89 fa                	mov    %edi,%edx
f01086ce:	e8 e4 d3 ff ff       	call   f0105ab7 <putop>

      /* Instruction fnstsw is only one with strange arg.  */
      if (floatop == 0xdf && codep[-1] == 0xe0)
f01086d3:	80 fb df             	cmp    $0xdf,%bl
f01086d6:	0f 85 ab 01 00 00    	jne    f0108887 <print_insn_i386+0xa69>
f01086dc:	a1 ec 4e 29 f0       	mov    0xf0294eec,%eax
f01086e1:	80 78 ff e0          	cmpb   $0xe0,-0x1(%eax)
f01086e5:	0f 85 9c 01 00 00    	jne    f0108887 <print_insn_i386+0xa69>
	{
        	pstrcpy (op1out, sizeof(op1out), names16[0]);
f01086eb:	a1 0c 4f 29 f0       	mov    0xf0294f0c,%eax
f01086f0:	8b 00                	mov    (%eax),%eax
f01086f2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01086f6:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f01086fd:	00 
f01086fe:	c7 04 24 20 4f 29 f0 	movl   $0xf0294f20,(%esp)
f0108705:	e8 c3 0e 00 00       	call   f01095cd <pstrcpy>
f010870a:	e9 78 01 00 00       	jmp    f0108887 <print_insn_i386+0xa69>
        	//add your code here
        }
    }
  else
    {
      putop (dp->name, sizeflag);
f010870f:	89 fa                	mov    %edi,%edx
f0108711:	e8 a1 d3 ff ff       	call   f0105ab7 <putop>

      obufp = op1out;
f0108716:	c7 05 64 4e 29 f0 20 	movl   $0xf0294f20,0xf0294e64
f010871d:	4f 29 f0 
      if (dp->op1)
f0108720:	8b 56 04             	mov    0x4(%esi),%edx
f0108723:	85 d2                	test   %edx,%edx
f0108725:	74 0c                	je     f0108733 <print_insn_i386+0x915>
	(*dp->op1) (dp->bytemode1, sizeflag);
f0108727:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010872b:	8b 46 08             	mov    0x8(%esi),%eax
f010872e:	89 04 24             	mov    %eax,(%esp)
f0108731:	ff d2                	call   *%edx
      obufp = op2out;
f0108733:	c7 05 64 4e 29 f0 a0 	movl   $0xf0294fa0,0xf0294e64
f010873a:	4f 29 f0 
      if (dp->op2)
f010873d:	8b 56 0c             	mov    0xc(%esi),%edx
f0108740:	85 d2                	test   %edx,%edx
f0108742:	0f 84 3f 01 00 00    	je     f0108887 <print_insn_i386+0xa69>
	(*dp->op2) (dp->bytemode2, sizeflag);
f0108748:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010874c:	8b 46 10             	mov    0x10(%esi),%eax
f010874f:	89 04 24             	mov    %eax,(%esp)
f0108752:	ff d2                	call   *%edx
f0108754:	e9 2e 01 00 00       	jmp    f0108887 <print_insn_i386+0xa69>
  else
    {
      int index;
      if (dp->name == NULL)
	{
	  switch (dp->bytemode1)
f0108759:	83 f8 03             	cmp    $0x3,%eax
f010875c:	74 29                	je     f0108787 <print_insn_i386+0x969>
f010875e:	83 f8 04             	cmp    $0x4,%eax
f0108761:	0f 84 80 00 00 00    	je     f01087e7 <print_insn_i386+0x9c9>
f0108767:	83 f8 02             	cmp    $0x2,%eax
f010876a:	0f 85 8b 00 00 00    	jne    f01087fb <print_insn_i386+0x9dd>
	    {
	    case USE_GROUPS:
	      dp = &grps[dp->bytemode2][reg];
f0108770:	69 53 10 e0 00 00 00 	imul   $0xe0,0x10(%ebx),%edx
f0108777:	6b 05 fc 4e 29 f0 1c 	imul   $0x1c,0xf0294efc,%eax
f010877e:	8d 9c 02 40 15 11 f0 	lea    -0xfeeeac0(%edx,%eax,1),%ebx
f0108785:	eb 7e                	jmp    f0108805 <print_insn_i386+0x9e7>
	      break;

	    case USE_PREFIX_USER_TABLE:
	      index = 0;
	      used_prefixes |= (prefixes & PREFIX_REPZ);
f0108787:	8b 15 e4 4d 29 f0    	mov    0xf0294de4,%edx
f010878d:	89 d0                	mov    %edx,%eax
f010878f:	83 e0 01             	and    $0x1,%eax
f0108792:	89 c6                	mov    %eax,%esi
f0108794:	0b 35 f0 4d 29 f0    	or     0xf0294df0,%esi
f010879a:	89 35 f0 4d 29 f0    	mov    %esi,0xf0294df0
	      if (prefixes & PREFIX_REPZ)
f01087a0:	b9 01 00 00 00       	mov    $0x1,%ecx
f01087a5:	85 c0                	test   %eax,%eax
f01087a7:	75 2e                	jne    f01087d7 <print_insn_i386+0x9b9>
		index = 1;
	      else
		{
		  used_prefixes |= (prefixes & PREFIX_DATA);
f01087a9:	89 d0                	mov    %edx,%eax
f01087ab:	25 00 02 00 00       	and    $0x200,%eax
f01087b0:	09 c6                	or     %eax,%esi
f01087b2:	89 35 f0 4d 29 f0    	mov    %esi,0xf0294df0
		  if (prefixes & PREFIX_DATA)
f01087b8:	b9 02 00 00 00       	mov    $0x2,%ecx
f01087bd:	85 c0                	test   %eax,%eax
f01087bf:	75 16                	jne    f01087d7 <print_insn_i386+0x9b9>
		    index = 2;
		  else
		    {
		      used_prefixes |= (prefixes & PREFIX_REPNZ);
f01087c1:	83 e2 02             	and    $0x2,%edx
f01087c4:	89 f0                	mov    %esi,%eax
f01087c6:	09 d0                	or     %edx,%eax
f01087c8:	a3 f0 4d 29 f0       	mov    %eax,0xf0294df0
		      if (prefixes & PREFIX_REPNZ)
f01087cd:	83 fa 01             	cmp    $0x1,%edx
f01087d0:	19 c9                	sbb    %ecx,%ecx
f01087d2:	f7 d1                	not    %ecx
f01087d4:	83 e1 03             	and    $0x3,%ecx
			index = 3;
		    }
		}
	      dp = &prefix_user_table[dp->bytemode2][index];
f01087d7:	6b 53 10 70          	imul   $0x70,0x10(%ebx),%edx
f01087db:	6b c1 1c             	imul   $0x1c,%ecx,%eax
f01087de:	8d 9c 02 60 29 11 f0 	lea    -0xfeed6a0(%edx,%eax,1),%ebx
f01087e5:	eb 1e                	jmp    f0108805 <print_insn_i386+0x9e7>
	      break;

	    case X86_64_SPECIAL:
	      dp = &x86_64_table[dp->bytemode2][mode_64bit];
f01087e7:	6b 53 10 38          	imul   $0x38,0x10(%ebx),%edx
f01087eb:	6b 05 e0 4d 29 f0 1c 	imul   $0x1c,0xf0294de0,%eax
f01087f2:	8d 9c 02 40 35 11 f0 	lea    -0xfeecac0(%edx,%eax,1),%ebx
f01087f9:	eb 0a                	jmp    f0108805 <print_insn_i386+0x9e7>
	      break;

	    default:
	      oappend (INTERNAL_DISASSEMBLER_ERROR);
f01087fb:	b8 82 bf 10 f0       	mov    $0xf010bf82,%eax
f0108800:	e8 18 da ff ff       	call   f010621d <oappend>
	      break;
	    }
	}
      //cprintf("*****op1out=%s*****\n",op1out);
      if (putop (dp->name, sizeflag) == 0)
f0108805:	89 fa                	mov    %edi,%edx
f0108807:	8b 03                	mov    (%ebx),%eax
f0108809:	e8 a9 d2 ff ff       	call   f0105ab7 <putop>
f010880e:	85 c0                	test   %eax,%eax
f0108810:	75 75                	jne    f0108887 <print_insn_i386+0xa69>
	{
	  obufp = op1out;
f0108812:	c7 05 64 4e 29 f0 20 	movl   $0xf0294f20,0xf0294e64
f0108819:	4f 29 f0 
	  op_ad = 2;
f010881c:	c7 05 84 50 29 f0 02 	movl   $0x2,0xf0295084
f0108823:	00 00 00 
	  if (dp->op1)
f0108826:	8b 53 04             	mov    0x4(%ebx),%edx
f0108829:	85 d2                	test   %edx,%edx
f010882b:	74 0c                	je     f0108839 <print_insn_i386+0xa1b>
	    (*dp->op1) (dp->bytemode1, sizeflag);
f010882d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0108831:	8b 43 08             	mov    0x8(%ebx),%eax
f0108834:	89 04 24             	mov    %eax,(%esp)
f0108837:	ff d2                	call   *%edx
	  //obufp = op1out;
	  //cprintf("obufp=%c%c%c%c%c\n",obufp[0],obufp[1],obufp[2],obufp[3],obufp[4]);
	//  cprintf("obufp=%s op1out=%s\n",obufp,op1out);
	  obufp = op2out;
f0108839:	c7 05 64 4e 29 f0 a0 	movl   $0xf0294fa0,0xf0294e64
f0108840:	4f 29 f0 
	  op_ad = 1;
f0108843:	c7 05 84 50 29 f0 01 	movl   $0x1,0xf0295084
f010884a:	00 00 00 
	  if (dp->op2)
f010884d:	8b 53 0c             	mov    0xc(%ebx),%edx
f0108850:	85 d2                	test   %edx,%edx
f0108852:	74 0c                	je     f0108860 <print_insn_i386+0xa42>
	    (*dp->op2) (dp->bytemode2, sizeflag);
f0108854:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0108858:	8b 43 10             	mov    0x10(%ebx),%eax
f010885b:	89 04 24             	mov    %eax,(%esp)
f010885e:	ff d2                	call   *%edx

	  obufp = op3out;
f0108860:	c7 05 64 4e 29 f0 20 	movl   $0xf0295020,0xf0294e64
f0108867:	50 29 f0 
	  op_ad = 0;
f010886a:	c7 05 84 50 29 f0 00 	movl   $0x0,0xf0295084
f0108871:	00 00 00 
	  if (dp->op3)
f0108874:	8b 53 14             	mov    0x14(%ebx),%edx
f0108877:	85 d2                	test   %edx,%edx
f0108879:	74 0c                	je     f0108887 <print_insn_i386+0xa69>
	    (*dp->op3) (dp->bytemode3, sizeflag);
f010887b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010887f:	8b 43 18             	mov    0x18(%ebx),%eax
f0108882:	89 04 24             	mov    %eax,(%esp)
f0108885:	ff d2                	call   *%edx
    //cprintf("***op1out=%s******\n",op1out);	
  /* See if any prefixes were not used.  If so, print the first one
     separately.  If we don't do this, we'll wind up printing an
     instruction stream which does not precisely correspond to the
     bytes we are disassembling.  */
  if ((prefixes & ~used_prefixes) != 0)
f0108887:	a1 f0 4d 29 f0       	mov    0xf0294df0,%eax
f010888c:	f7 d0                	not    %eax
f010888e:	85 05 e4 4d 29 f0    	test   %eax,0xf0294de4
f0108894:	74 2f                	je     f01088c5 <print_insn_i386+0xaa7>
    {
      const char *name;

      name = prefix_name (priv.the_buffer[0], priv.orig_sizeflag);
f0108896:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0108899:	0f b6 45 d4          	movzbl -0x2c(%ebp),%eax
f010889d:	e8 89 ce ff ff       	call   f010572b <prefix_name>
      if (name == NULL)
f01088a2:	85 c0                	test   %eax,%eax
f01088a4:	75 05                	jne    f01088ab <print_insn_i386+0xa8d>
f01088a6:	b8 82 bf 10 f0       	mov    $0xf010bf82,%eax
	name = INTERNAL_DISASSEMBLER_ERROR;
      /*****************************************/
      //Add your code here,print name
      cprintf("%s",name);
f01088ab:	89 44 24 04          	mov    %eax,0x4(%esp)
f01088af:	c7 04 24 be b6 10 f0 	movl   $0xf010b6be,(%esp)
f01088b6:	e8 2c b1 ff ff       	call   f01039e7 <cprintf>
f01088bb:	b8 01 00 00 00       	mov    $0x1,%eax
f01088c0:	e9 c0 02 00 00       	jmp    f0108b85 <print_insn_i386+0xd67>
      return 1;
    }
  if (rex & ~rex_used)
f01088c5:	8b 0d e8 4d 29 f0    	mov    0xf0294de8,%ecx
f01088cb:	a1 ec 4d 29 f0       	mov    0xf0294dec,%eax
f01088d0:	f7 d0                	not    %eax
f01088d2:	85 c8                	test   %ecx,%eax
f01088d4:	74 26                	je     f01088fc <print_insn_i386+0xade>
    {
      const char *name;
      name = prefix_name (rex | 0x40, priv.orig_sizeflag);
f01088d6:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01088d9:	89 c8                	mov    %ecx,%eax
f01088db:	83 c8 40             	or     $0x40,%eax
f01088de:	e8 48 ce ff ff       	call   f010572b <prefix_name>
      if (name == NULL)
f01088e3:	85 c0                	test   %eax,%eax
f01088e5:	75 05                	jne    f01088ec <print_insn_i386+0xace>
f01088e7:	b8 82 bf 10 f0       	mov    $0xf010bf82,%eax
	name = INTERNAL_DISASSEMBLER_ERROR;
      /*****************************************/
      //Add your code here,print name
      cprintf("%s",name);
f01088ec:	89 44 24 04          	mov    %eax,0x4(%esp)
f01088f0:	c7 04 24 be b6 10 f0 	movl   $0xf010b6be,(%esp)
f01088f7:	e8 eb b0 ff ff       	call   f01039e7 <cprintf>
    }

  obufp = obuf + strlen (obuf);
f01088fc:	c7 04 24 00 4e 29 f0 	movl   $0xf0294e00,(%esp)
f0108903:	e8 d8 0b 00 00       	call   f01094e0 <strlen>
f0108908:	05 00 4e 29 f0       	add    $0xf0294e00,%eax
f010890d:	a3 64 4e 29 f0       	mov    %eax,0xf0294e64
  for (i = strlen (obuf); i < 6; i++)
f0108912:	c7 04 24 00 4e 29 f0 	movl   $0xf0294e00,(%esp)
f0108919:	e8 c2 0b 00 00       	call   f01094e0 <strlen>
f010891e:	89 c3                	mov    %eax,%ebx
f0108920:	83 f8 05             	cmp    $0x5,%eax
f0108923:	7f 12                	jg     f0108937 <print_insn_i386+0xb19>
    oappend (" ");
f0108925:	b8 97 aa 10 f0       	mov    $0xf010aa97,%eax
f010892a:	e8 ee d8 ff ff       	call   f010621d <oappend>
      //Add your code here,print name
      cprintf("%s",name);
    }

  obufp = obuf + strlen (obuf);
  for (i = strlen (obuf); i < 6; i++)
f010892f:	83 c3 01             	add    $0x1,%ebx
f0108932:	83 fb 05             	cmp    $0x5,%ebx
f0108935:	7e ee                	jle    f0108925 <print_insn_i386+0xb07>
    oappend (" ");
  oappend (" ");
f0108937:	b8 97 aa 10 f0       	mov    $0xf010aa97,%eax
f010893c:	e8 dc d8 ff ff       	call   f010621d <oappend>
  /*****************************************/
  //Add your code here,print obuf
  //cprintf("print_insn:operands is here\n");
  cprintf("%s",obuf);
f0108941:	c7 44 24 04 00 4e 29 	movl   $0xf0294e00,0x4(%esp)
f0108948:	f0 
f0108949:	c7 04 24 be b6 10 f0 	movl   $0xf010b6be,(%esp)
f0108950:	e8 92 b0 ff ff       	call   f01039e7 <cprintf>
  //cprintf("\nop1out=%s op2out=%s op3out=%s\n",op1out,op2out,op3out);
  /* The enter and bound instructions are printed with operands in the same
     order as the intel book; everything else is printed in reverse order.  */
  if (intel_syntax || two_source_ops)
f0108955:	80 3d d0 50 29 f0 00 	cmpb   $0x0,0xf02950d0
f010895c:	75 16                	jne    f0108974 <print_insn_i386+0xb56>
f010895e:	80 7d c3 62          	cmpb   $0x62,-0x3d(%ebp)
f0108962:	74 10                	je     f0108974 <print_insn_i386+0xb56>
f0108964:	b9 20 50 29 f0       	mov    $0xf0295020,%ecx
f0108969:	bb 20 4f 29 f0       	mov    $0xf0294f20,%ebx
f010896e:	80 7d c3 c8          	cmpb   $0xc8,-0x3d(%ebp)
f0108972:	75 26                	jne    f010899a <print_insn_i386+0xb7c>
    {
      first = op1out;
      second = op2out;
      third = op3out;
      op_ad = op_index[0];
f0108974:	8b 15 88 50 29 f0    	mov    0xf0295088,%edx
f010897a:	89 15 84 50 29 f0    	mov    %edx,0xf0295084
      op_index[0] = op_index[2];
f0108980:	a1 90 50 29 f0       	mov    0xf0295090,%eax
f0108985:	a3 88 50 29 f0       	mov    %eax,0xf0295088
      op_index[2] = op_ad;
f010898a:	89 15 90 50 29 f0    	mov    %edx,0xf0295090
f0108990:	b9 20 4f 29 f0       	mov    $0xf0294f20,%ecx
f0108995:	bb 20 50 29 f0       	mov    $0xf0295020,%ebx
      first = op3out;
      second = op2out;
      third = op1out;
    }
  needcomma = 0;
  if (*first)
f010899a:	b8 00 00 00 00       	mov    $0x0,%eax
f010899f:	80 39 00             	cmpb   $0x0,(%ecx)
f01089a2:	74 56                	je     f01089fa <print_insn_i386+0xbdc>
    {
      if (op_index[0] != -1 && !op_riprel[0])
f01089a4:	8b 15 88 50 29 f0    	mov    0xf0295088,%edx
f01089aa:	83 fa ff             	cmp    $0xffffffff,%edx
f01089ad:	74 36                	je     f01089e5 <print_insn_i386+0xbc7>
f01089af:	a1 b0 50 29 f0       	mov    0xf02950b0,%eax
f01089b4:	0b 05 b4 50 29 f0    	or     0xf02950b4,%eax
f01089ba:	75 29                	jne    f01089e5 <print_insn_i386+0xbc7>
	(*info->print_address_func) ((bfd_vma) op_address[op_index[0]], info);
f01089bc:	8b 45 10             	mov    0x10(%ebp),%eax
f01089bf:	89 44 24 08          	mov    %eax,0x8(%esp)
f01089c3:	8b 04 d5 98 50 29 f0 	mov    -0xfd6af68(,%edx,8),%eax
f01089ca:	8b 14 d5 9c 50 29 f0 	mov    -0xfd6af64(,%edx,8),%edx
f01089d1:	89 04 24             	mov    %eax,(%esp)
f01089d4:	89 54 24 04          	mov    %edx,0x4(%esp)
f01089d8:	8b 55 10             	mov    0x10(%ebp),%edx
f01089db:	ff 52 2c             	call   *0x2c(%edx)
f01089de:	b8 01 00 00 00       	mov    $0x1,%eax
f01089e3:	eb 15                	jmp    f01089fa <print_insn_i386+0xbdc>
      else
	{
		/*****************************************/
      		//Add your code here,print first
      		cprintf("%s",first);
f01089e5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01089e9:	c7 04 24 be b6 10 f0 	movl   $0xf010b6be,(%esp)
f01089f0:	e8 f2 af ff ff       	call   f01039e7 <cprintf>
f01089f5:	b8 01 00 00 00       	mov    $0x1,%eax
	}
      needcomma = 1;
    }
  if (*second)
f01089fa:	80 3d a0 4f 29 f0 00 	cmpb   $0x0,0xf0294fa0
f0108a01:	74 6f                	je     f0108a72 <print_insn_i386+0xc54>
    {
      if (needcomma)
f0108a03:	85 c0                	test   %eax,%eax
f0108a05:	74 14                	je     f0108a1b <print_insn_i386+0xbfd>
	{
		/*****************************************/
      		//Add your code here,print ,
      		cprintf("%c",',');
f0108a07:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
f0108a0e:	00 
f0108a0f:	c7 04 24 3c bf 10 f0 	movl   $0xf010bf3c,(%esp)
f0108a16:	e8 cc af ff ff       	call   f01039e7 <cprintf>

	}
      if (op_index[1] != -1 && !op_riprel[1])
f0108a1b:	8b 15 8c 50 29 f0    	mov    0xf029508c,%edx
f0108a21:	83 fa ff             	cmp    $0xffffffff,%edx
f0108a24:	74 33                	je     f0108a59 <print_insn_i386+0xc3b>
f0108a26:	a1 b8 50 29 f0       	mov    0xf02950b8,%eax
f0108a2b:	0b 05 bc 50 29 f0    	or     0xf02950bc,%eax
f0108a31:	75 26                	jne    f0108a59 <print_insn_i386+0xc3b>
	(*info->print_address_func) ((bfd_vma) op_address[op_index[1]], info);
f0108a33:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0108a36:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0108a3a:	8b 04 d5 98 50 29 f0 	mov    -0xfd6af68(,%edx,8),%eax
f0108a41:	8b 14 d5 9c 50 29 f0 	mov    -0xfd6af64(,%edx,8),%edx
f0108a48:	89 04 24             	mov    %eax,(%esp)
f0108a4b:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108a4f:	ff 51 2c             	call   *0x2c(%ecx)
f0108a52:	b8 01 00 00 00       	mov    $0x1,%eax
f0108a57:	eb 19                	jmp    f0108a72 <print_insn_i386+0xc54>
      else
	{
		/*****************************************/
      		//Add your code here,print second
      		cprintf("%s",second);
f0108a59:	c7 44 24 04 a0 4f 29 	movl   $0xf0294fa0,0x4(%esp)
f0108a60:	f0 
f0108a61:	c7 04 24 be b6 10 f0 	movl   $0xf010b6be,(%esp)
f0108a68:	e8 7a af ff ff       	call   f01039e7 <cprintf>
f0108a6d:	b8 01 00 00 00       	mov    $0x1,%eax

	}
      needcomma = 1;
    }
  if (*third)
f0108a72:	80 3b 00             	cmpb   $0x0,(%ebx)
f0108a75:	0f 84 ff 00 00 00    	je     f0108b7a <print_insn_i386+0xd5c>
    {
      if (needcomma)
f0108a7b:	85 c0                	test   %eax,%eax
f0108a7d:	74 14                	je     f0108a93 <print_insn_i386+0xc75>
	{
                /*****************************************/
                //Add your code here,print ,
                cprintf("%c",',');
f0108a7f:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
f0108a86:	00 
f0108a87:	c7 04 24 3c bf 10 f0 	movl   $0xf010bf3c,(%esp)
f0108a8e:	e8 54 af ff ff       	call   f01039e7 <cprintf>
                
        }
      if (op_index[2] != -1 && !op_riprel[2])
f0108a93:	8b 15 90 50 29 f0    	mov    0xf0295090,%edx
f0108a99:	83 fa ff             	cmp    $0xffffffff,%edx
f0108a9c:	74 34                	je     f0108ad2 <print_insn_i386+0xcb4>
f0108a9e:	a1 c0 50 29 f0       	mov    0xf02950c0,%eax
f0108aa3:	0b 05 c4 50 29 f0    	or     0xf02950c4,%eax
f0108aa9:	75 27                	jne    f0108ad2 <print_insn_i386+0xcb4>
	(*info->print_address_func) ((bfd_vma) op_address[op_index[2]], info);
f0108aab:	8b 45 10             	mov    0x10(%ebp),%eax
f0108aae:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108ab2:	8b 04 d5 98 50 29 f0 	mov    -0xfd6af68(,%edx,8),%eax
f0108ab9:	8b 14 d5 9c 50 29 f0 	mov    -0xfd6af64(,%edx,8),%edx
f0108ac0:	89 04 24             	mov    %eax,(%esp)
f0108ac3:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108ac7:	8b 55 10             	mov    0x10(%ebp),%edx
f0108aca:	ff 52 2c             	call   *0x2c(%edx)
f0108acd:	e9 a8 00 00 00       	jmp    f0108b7a <print_insn_i386+0xd5c>
      else
	{
                /*****************************************/
                //Add your code here,print third
                cprintf("%s",third);
f0108ad2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0108ad6:	c7 04 24 be b6 10 f0 	movl   $0xf010b6be,(%esp)
f0108add:	e8 05 af ff ff       	call   f01039e7 <cprintf>
f0108ae2:	e9 93 00 00 00       	jmp    f0108b7a <print_insn_i386+0xd5c>
        }
    }
  //panic("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb");
  for (i = 0; i < 3; i++)
    if (op_index[i] != -1 && op_riprel[i])
f0108ae7:	83 3c 9d 88 50 29 f0 	cmpl   $0xffffffff,-0xfd6af78(,%ebx,4)
f0108aee:	ff 
f0108aef:	74 63                	je     f0108b54 <print_insn_i386+0xd36>
f0108af1:	8b 04 dd b0 50 29 f0 	mov    -0xfd6af50(,%ebx,8),%eax
f0108af8:	0b 04 dd b4 50 29 f0 	or     -0xfd6af4c(,%ebx,8),%eax
f0108aff:	74 53                	je     f0108b54 <print_insn_i386+0xd36>
      {
	/*****************************************/
        //Add your code here,print #
        cprintf("%s","      #");
f0108b01:	c7 44 24 04 95 c0 10 	movl   $0xf010c095,0x4(%esp)
f0108b08:	f0 
f0108b09:	c7 04 24 be b6 10 f0 	movl   $0xf010b6be,(%esp)
f0108b10:	e8 d2 ae ff ff       	call   f01039e7 <cprintf>
	(*info->print_address_func) ((bfd_vma) (start_pc + codep - start_codep
f0108b15:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0108b18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0108b1c:	a1 ec 4e 29 f0       	mov    0xf0294eec,%eax
f0108b21:	03 05 c8 50 29 f0    	add    0xf02950c8,%eax
f0108b27:	2b 05 e4 4e 29 f0    	sub    0xf0294ee4,%eax
f0108b2d:	89 c2                	mov    %eax,%edx
f0108b2f:	c1 fa 1f             	sar    $0x1f,%edx
f0108b32:	8b 0c 9d 88 50 29 f0 	mov    -0xfd6af78(,%ebx,4),%ecx
f0108b39:	03 04 cd 98 50 29 f0 	add    -0xfd6af68(,%ecx,8),%eax
f0108b40:	13 14 cd 9c 50 29 f0 	adc    -0xfd6af64(,%ecx,8),%edx
f0108b47:	89 04 24             	mov    %eax,(%esp)
f0108b4a:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108b4e:	8b 45 10             	mov    0x10(%ebp),%eax
f0108b51:	ff 50 2c             	call   *0x2c(%eax)
                //Add your code here,print third
                cprintf("%s",third);
        }
    }
  //panic("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb");
  for (i = 0; i < 3; i++)
f0108b54:	83 c3 01             	add    $0x1,%ebx
f0108b57:	83 fb 03             	cmp    $0x3,%ebx
f0108b5a:	75 8b                	jne    f0108ae7 <print_insn_i386+0xcc9>
        //Add your code here,print #
        cprintf("%s","      #");
	(*info->print_address_func) ((bfd_vma) (start_pc + codep - start_codep
						+ op_address[op_index[i]]), info);
      }
  return codep - priv.the_buffer;
f0108b5c:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0108b5f:	a1 ec 4e 29 f0       	mov    0xf0294eec,%eax
f0108b64:	29 d0                	sub    %edx,%eax
f0108b66:	eb 1d                	jmp    f0108b85 <print_insn_i386+0xd67>
  if (!uses_SSE_prefix && (prefixes & PREFIX_REPZ))
    {
      oappend ("repz ");
      used_prefixes |= PREFIX_REPZ;
    }
  if (!uses_SSE_prefix && (prefixes & PREFIX_REPNZ))
f0108b68:	f6 05 e4 4d 29 f0 02 	testb  $0x2,0xf0294de4
f0108b6f:	0f 84 5e f9 ff ff    	je     f01084d3 <print_insn_i386+0x6b5>
f0108b75:	e9 48 f9 ff ff       	jmp    f01084c2 <print_insn_i386+0x6a4>
f0108b7a:	bb 00 00 00 00       	mov    $0x0,%ebx
f0108b7f:	90                   	nop    
f0108b80:	e9 62 ff ff ff       	jmp    f0108ae7 <print_insn_i386+0xcc9>
     disassemble_info *info;
{
  intel_syntax = -1;
  //cprintf("intel_syntax1=%d\n",intel_syntax);
  return print_insn (pc, info);
}
f0108b85:	83 c4 4c             	add    $0x4c,%esp
f0108b88:	5b                   	pop    %ebx
f0108b89:	5e                   	pop    %esi
f0108b8a:	5f                   	pop    %edi
f0108b8b:	5d                   	pop    %ebp
f0108b8c:	c3                   	ret    
f0108b8d:	00 00                	add    %al,(%eax)
	...

f0108b90 <generic_symbol_at_address>:

/* Just return the given address.  */

int
generic_symbol_at_address (bfd_vma addr, struct disassemble_info *info)
{
f0108b90:	55                   	push   %ebp
f0108b91:	89 e5                	mov    %esp,%ebp
  return 1;
}
f0108b93:	b8 01 00 00 00       	mov    $0x1,%eax
f0108b98:	5d                   	pop    %ebp
f0108b99:	c3                   	ret    

f0108b9a <bfd_getl32>:

bfd_vma bfd_getl32 (const bfd_byte *addr)
{
f0108b9a:	55                   	push   %ebp
f0108b9b:	89 e5                	mov    %esp,%ebp
f0108b9d:	83 ec 08             	sub    $0x8,%esp
f0108ba0:	89 1c 24             	mov    %ebx,(%esp)
f0108ba3:	89 74 24 04          	mov    %esi,0x4(%esp)
f0108ba7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  unsigned long v;

  v = (unsigned long) addr[0];
f0108baa:	0f b6 33             	movzbl (%ebx),%esi
  v |= (unsigned long) addr[1] << 8;
f0108bad:	0f b6 43 01          	movzbl 0x1(%ebx),%eax
f0108bb1:	c1 e0 08             	shl    $0x8,%eax
f0108bb4:	0f b6 4b 02          	movzbl 0x2(%ebx),%ecx
f0108bb8:	c1 e1 10             	shl    $0x10,%ecx
f0108bbb:	09 c8                	or     %ecx,%eax
  v |= (unsigned long) addr[2] << 16;
f0108bbd:	09 f0                	or     %esi,%eax
f0108bbf:	0f b6 4b 03          	movzbl 0x3(%ebx),%ecx
f0108bc3:	c1 e1 18             	shl    $0x18,%ecx
f0108bc6:	09 c8                	or     %ecx,%eax
f0108bc8:	ba 00 00 00 00       	mov    $0x0,%edx
  v |= (unsigned long) addr[3] << 24;
  return (bfd_vma) v;
}
f0108bcd:	8b 1c 24             	mov    (%esp),%ebx
f0108bd0:	8b 74 24 04          	mov    0x4(%esp),%esi
f0108bd4:	89 ec                	mov    %ebp,%esp
f0108bd6:	5d                   	pop    %ebp
f0108bd7:	c3                   	ret    

f0108bd8 <bfd_getb32>:

bfd_vma bfd_getb32 (const bfd_byte *addr)
{
f0108bd8:	55                   	push   %ebp
f0108bd9:	89 e5                	mov    %esp,%ebp
f0108bdb:	53                   	push   %ebx
f0108bdc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  unsigned long v;

  v = (unsigned long) addr[0] << 24;
f0108bdf:	0f b6 0b             	movzbl (%ebx),%ecx
f0108be2:	c1 e1 18             	shl    $0x18,%ecx
  v |= (unsigned long) addr[1] << 16;
f0108be5:	0f b6 43 03          	movzbl 0x3(%ebx),%eax
f0108be9:	09 c8                	or     %ecx,%eax
  v |= (unsigned long) addr[2] << 8;
f0108beb:	0f b6 4b 01          	movzbl 0x1(%ebx),%ecx
f0108bef:	c1 e1 10             	shl    $0x10,%ecx
f0108bf2:	09 c8                	or     %ecx,%eax
f0108bf4:	0f b6 4b 02          	movzbl 0x2(%ebx),%ecx
f0108bf8:	c1 e1 08             	shl    $0x8,%ecx
f0108bfb:	09 c8                	or     %ecx,%eax
f0108bfd:	ba 00 00 00 00       	mov    $0x0,%edx
  v |= (unsigned long) addr[3];
  return (bfd_vma) v;
}
f0108c02:	5b                   	pop    %ebx
f0108c03:	5d                   	pop    %ebp
f0108c04:	c3                   	ret    

f0108c05 <bfd_getl16>:

bfd_vma bfd_getl16 (const bfd_byte *addr)
{
f0108c05:	55                   	push   %ebp
f0108c06:	89 e5                	mov    %esp,%ebp
f0108c08:	8b 45 08             	mov    0x8(%ebp),%eax
  unsigned long v;

  v = (unsigned long) addr[0];
f0108c0b:	0f b6 08             	movzbl (%eax),%ecx
f0108c0e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
f0108c12:	c1 e0 08             	shl    $0x8,%eax
f0108c15:	09 c8                	or     %ecx,%eax
f0108c17:	ba 00 00 00 00       	mov    $0x0,%edx
  v |= (unsigned long) addr[1] << 8;
  return (bfd_vma) v;
}
f0108c1c:	5d                   	pop    %ebp
f0108c1d:	c3                   	ret    

f0108c1e <bfd_getb16>:

bfd_vma bfd_getb16 (const bfd_byte *addr)
{
f0108c1e:	55                   	push   %ebp
f0108c1f:	89 e5                	mov    %esp,%ebp
f0108c21:	8b 45 08             	mov    0x8(%ebp),%eax
  unsigned long v;

  v = (unsigned long) addr[0] << 24;
f0108c24:	0f b6 08             	movzbl (%eax),%ecx
f0108c27:	c1 e1 18             	shl    $0x18,%ecx
f0108c2a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
f0108c2e:	c1 e0 10             	shl    $0x10,%eax
f0108c31:	09 c8                	or     %ecx,%eax
f0108c33:	ba 00 00 00 00       	mov    $0x0,%edx
  v |= (unsigned long) addr[1] << 16;
  return (bfd_vma) v;
}
f0108c38:	5d                   	pop    %ebp
f0108c39:	c3                   	ret    

f0108c3a <monitor_disas>:

void monitor_disas(uint32_t pc, int nb_insn)
{
f0108c3a:	55                   	push   %ebp
f0108c3b:	89 e5                	mov    %esp,%ebp
f0108c3d:	57                   	push   %edi
f0108c3e:	56                   	push   %esi
f0108c3f:	53                   	push   %ebx
f0108c40:	83 ec 7c             	sub    $0x7c,%esp
f0108c43:	8b 75 08             	mov    0x8(%ebp),%esi
    int count, i;
    struct disassemble_info disasm_info;
    int (*print_insn)(bfd_vma pc, disassemble_info *info);
    
    INIT_DISASSEMBLE_INFO(disasm_info, NULL, cprintf);
f0108c46:	c7 45 8c 00 00 00 00 	movl   $0x0,-0x74(%ebp)
f0108c4d:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
f0108c54:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
f0108c5b:	c7 45 98 02 00 00 00 	movl   $0x2,-0x68(%ebp)
f0108c62:	c7 45 9c 00 00 00 00 	movl   $0x0,-0x64(%ebp)
f0108c69:	c7 45 a0 00 00 00 00 	movl   $0x0,-0x60(%ebp)
f0108c70:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f0108c77:	c7 45 ac 9e 8d 10 f0 	movl   $0xf0108d9e,-0x54(%ebp)
f0108c7e:	c7 45 b0 62 8d 10 f0 	movl   $0xf0108d62,-0x50(%ebp)
f0108c85:	c7 45 b4 40 8d 10 f0 	movl   $0xf0108d40,-0x4c(%ebp)
f0108c8c:	c7 45 b8 90 8b 10 f0 	movl   $0xf0108b90,-0x48(%ebp)
f0108c93:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0108c9a:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f0108ca1:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f0108ca8:	c7 45 d4 02 00 00 00 	movl   $0x2,-0x2c(%ebp)
f0108caf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0108cb6:	c6 45 d8 00          	movb   $0x0,-0x28(%ebp)

    //monitor_disas_env = env;
    //monitor_disas_is_physical = is_physical;
    //disasm_info.read_memory_func = monitor_read_memory;

    disasm_info.buffer_vma = pc;
f0108cba:	89 75 c0             	mov    %esi,-0x40(%ebp)
f0108cbd:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
    disasm_info.buffer_length=7;
f0108cc4:	c7 45 c8 07 00 00 00 	movl   $0x7,-0x38(%ebp)
    disasm_info.buffer=(bfd_byte *)pc;
f0108ccb:	89 75 bc             	mov    %esi,-0x44(%ebp)
    //cprintf("disasm_info=%x\n",&disasm_info);
    //for(i=0;i<7;i++)
    	//cprintf("%x",disasm_info.buffer[i]);
    cprintf("\n");
f0108cce:	c7 04 24 29 ab 10 f0 	movl   $0xf010ab29,(%esp)
f0108cd5:	e8 0d ad ff ff       	call   f01039e7 <cprintf>
    disasm_info.endian = BFD_ENDIAN_LITTLE;

    disasm_info.mach = bfd_mach_i386_i386;
    print_insn = print_insn_i386;

    for(i = 0; i < nb_insn; i++) {
f0108cda:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0108cde:	7e 58                	jle    f0108d38 <monitor_disas+0xfe>
    disasm_info.buffer=(bfd_byte *)pc;
    //cprintf("disasm_info=%x\n",&disasm_info);
    //for(i=0;i<7;i++)
    	//cprintf("%x",disasm_info.buffer[i]);
    cprintf("\n");
    disasm_info.endian = BFD_ENDIAN_LITTLE;
f0108ce0:	c7 45 98 01 00 00 00 	movl   $0x1,-0x68(%ebp)

    disasm_info.mach = bfd_mach_i386_i386;
f0108ce7:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
f0108cee:	bf 00 00 00 00       	mov    $0x0,%edi
    print_insn = print_insn_i386;

    for(i = 0; i < nb_insn; i++) {
        cprintf("0x%08x:  ", pc);
f0108cf3:	89 74 24 04          	mov    %esi,0x4(%esp)
f0108cf7:	c7 04 24 c0 42 11 f0 	movl   $0xf01142c0,(%esp)
f0108cfe:	e8 e4 ac ff ff       	call   f01039e7 <cprintf>
	//cprintf("%08x  ", (int)bfd_getl32((const bfd_byte *)pc));
	count = print_insn(pc, &disasm_info);
f0108d03:	8d 45 88             	lea    -0x78(%ebp),%eax
f0108d06:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108d0a:	89 34 24             	mov    %esi,(%esp)
f0108d0d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0108d14:	00 
f0108d15:	e8 04 f1 ff ff       	call   f0107e1e <print_insn_i386>
f0108d1a:	89 c3                	mov    %eax,%ebx
        cprintf("\n");
f0108d1c:	c7 04 24 29 ab 10 f0 	movl   $0xf010ab29,(%esp)
f0108d23:	e8 bf ac ff ff       	call   f01039e7 <cprintf>
        if (count < 0)
f0108d28:	85 db                	test   %ebx,%ebx
f0108d2a:	78 0c                	js     f0108d38 <monitor_disas+0xfe>
    disasm_info.endian = BFD_ENDIAN_LITTLE;

    disasm_info.mach = bfd_mach_i386_i386;
    print_insn = print_insn_i386;

    for(i = 0; i < nb_insn; i++) {
f0108d2c:	83 c7 01             	add    $0x1,%edi
f0108d2f:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0108d32:	74 04                	je     f0108d38 <monitor_disas+0xfe>
	//cprintf("%08x  ", (int)bfd_getl32((const bfd_byte *)pc));
	count = print_insn(pc, &disasm_info);
        cprintf("\n");
        if (count < 0)
            break;
        pc += count;
f0108d34:	01 de                	add    %ebx,%esi
f0108d36:	eb bb                	jmp    f0108cf3 <monitor_disas+0xb9>
    }
}
f0108d38:	83 c4 7c             	add    $0x7c,%esp
f0108d3b:	5b                   	pop    %ebx
f0108d3c:	5e                   	pop    %esi
f0108d3d:	5f                   	pop    %edi
f0108d3e:	5d                   	pop    %ebp
f0108d3f:	c3                   	ret    

f0108d40 <generic_print_address>:
    cprintf("Address 0x%08x is out of bounds.\n", memaddr);
}

void
generic_print_address (bfd_vma addr, struct disassemble_info *info)
{
f0108d40:	55                   	push   %ebp
f0108d41:	89 e5                	mov    %esp,%ebp
f0108d43:	83 ec 18             	sub    $0x18,%esp
    cprintf("0x%08x",addr);
f0108d46:	8b 45 08             	mov    0x8(%ebp),%eax
f0108d49:	8b 55 0c             	mov    0xc(%ebp),%edx
f0108d4c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108d50:	89 54 24 08          	mov    %edx,0x8(%esp)
f0108d54:	c7 04 24 ca 42 11 f0 	movl   $0xf01142ca,(%esp)
f0108d5b:	e8 87 ac ff ff       	call   f01039e7 <cprintf>
}
f0108d60:	c9                   	leave  
f0108d61:	c3                   	ret    

f0108d62 <perror_memory>:
}
/* Print an error message.  We can assume that this is in response to
 *    an error return from buffer_read_memory.  */
void
perror_memory (int status, bfd_vma memaddr, struct disassemble_info *info)
{
f0108d62:	55                   	push   %ebp
f0108d63:	89 e5                	mov    %esp,%ebp
f0108d65:	83 ec 18             	sub    $0x18,%esp
f0108d68:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0108d6b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108d6e:	8b 55 10             	mov    0x10(%ebp),%edx
  if (status != -1)
f0108d71:	83 f9 ff             	cmp    $0xffffffff,%ecx
f0108d74:	74 12                	je     f0108d88 <perror_memory+0x26>
    /* Can't happen.  */
    cprintf("Unknown error %d\n", status);
f0108d76:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0108d7a:	c7 04 24 d1 42 11 f0 	movl   $0xf01142d1,(%esp)
f0108d81:	e8 61 ac ff ff       	call   f01039e7 <cprintf>
f0108d86:	eb 14                	jmp    f0108d9c <perror_memory+0x3a>
  else
    /* Actually, address between memaddr and memaddr + len was
 *        out of bounds.  */
    cprintf("Address 0x%08x is out of bounds.\n", memaddr);
f0108d88:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108d8c:	89 54 24 08          	mov    %edx,0x8(%esp)
f0108d90:	c7 04 24 e4 42 11 f0 	movl   $0xf01142e4,(%esp)
f0108d97:	e8 4b ac ff ff       	call   f01039e7 <cprintf>
}
f0108d9c:	c9                   	leave  
f0108d9d:	c3                   	ret    

f0108d9e <buffer_read_memory>:
#include <inc/string.h>
/* Get LENGTH bytes from info's buffer, at target address memaddr.
 *    Transfer them to myaddr.  */
int
buffer_read_memory(bfd_vma memaddr,bfd_byte *myaddr,int length,struct disassemble_info *info)
{
f0108d9e:	55                   	push   %ebp
f0108d9f:	89 e5                	mov    %esp,%ebp
f0108da1:	83 ec 48             	sub    $0x48,%esp
f0108da4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0108da7:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0108daa:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0108dad:	8b 75 08             	mov    0x8(%ebp),%esi
f0108db0:	8b 7d 0c             	mov    0xc(%ebp),%edi
    //cprintf("read:myaddr=%x\n",myaddr);
    if ((memaddr < info->buffer_vma)
f0108db3:	8b 45 18             	mov    0x18(%ebp),%eax
f0108db6:	8b 48 38             	mov    0x38(%eax),%ecx
f0108db9:	8b 58 3c             	mov    0x3c(%eax),%ebx
f0108dbc:	39 fb                	cmp    %edi,%ebx
f0108dbe:	77 78                	ja     f0108e38 <buffer_read_memory+0x9a>
f0108dc0:	72 04                	jb     f0108dc6 <buffer_read_memory+0x28>
f0108dc2:	39 f1                	cmp    %esi,%ecx
f0108dc4:	77 72                	ja     f0108e38 <buffer_read_memory+0x9a>
f0108dc6:	8b 45 14             	mov    0x14(%ebp),%eax
f0108dc9:	89 c2                	mov    %eax,%edx
f0108dcb:	c1 fa 1f             	sar    $0x1f,%edx
f0108dce:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0108dd1:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0108dd4:	01 f0                	add    %esi,%eax
f0108dd6:	11 fa                	adc    %edi,%edx
f0108dd8:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0108ddb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0108dde:	8b 55 18             	mov    0x18(%ebp),%edx
f0108de1:	8b 42 40             	mov    0x40(%edx),%eax
f0108de4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0108de7:	89 c2                	mov    %eax,%edx
f0108de9:	c1 fa 1f             	sar    $0x1f,%edx
f0108dec:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0108def:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0108df2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0108df5:	01 c8                	add    %ecx,%eax
f0108df7:	11 da                	adc    %ebx,%edx
f0108df9:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0108dfc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0108dff:	39 55 e4             	cmp    %edx,-0x1c(%ebp)
f0108e02:	77 34                	ja     f0108e38 <buffer_read_memory+0x9a>
f0108e04:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0108e07:	39 55 e4             	cmp    %edx,-0x1c(%ebp)
f0108e0a:	72 05                	jb     f0108e11 <buffer_read_memory+0x73>
f0108e0c:	39 45 e0             	cmp    %eax,-0x20(%ebp)
f0108e0f:	77 27                	ja     f0108e38 <buffer_read_memory+0x9a>
        /* Out of bounds.  Use EIO because GDB uses it.  */
	{
		//cprintf("read memory error\n");
        	return -1;
	}
    memmove (myaddr, info->buffer + (memaddr - info->buffer_vma), length);  
f0108e11:	8b 45 14             	mov    0x14(%ebp),%eax
f0108e14:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108e18:	89 f0                	mov    %esi,%eax
f0108e1a:	29 c8                	sub    %ecx,%eax
f0108e1c:	8b 55 18             	mov    0x18(%ebp),%edx
f0108e1f:	03 42 34             	add    0x34(%edx),%eax
f0108e22:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108e26:	8b 45 10             	mov    0x10(%ebp),%eax
f0108e29:	89 04 24             	mov    %eax,(%esp)
f0108e2c:	e8 07 09 00 00       	call   f0109738 <memmove>
f0108e31:	b8 00 00 00 00       	mov    $0x0,%eax
f0108e36:	eb 05                	jmp    f0108e3d <buffer_read_memory+0x9f>
    return 0;
f0108e38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0108e3d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0108e40:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0108e43:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0108e46:	89 ec                	mov    %ebp,%esp
f0108e48:	5d                   	pop    %ebp
f0108e49:	c3                   	ret    
f0108e4a:	00 00                	add    %al,(%eax)
f0108e4c:	00 00                	add    %al,(%eax)
	...

f0108e50 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0108e50:	55                   	push   %ebp
f0108e51:	89 e5                	mov    %esp,%ebp
f0108e53:	57                   	push   %edi
f0108e54:	56                   	push   %esi
f0108e55:	53                   	push   %ebx
f0108e56:	83 ec 3c             	sub    $0x3c,%esp
f0108e59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0108e5c:	89 d7                	mov    %edx,%edi
f0108e5e:	8b 45 08             	mov    0x8(%ebp),%eax
f0108e61:	8b 55 0c             	mov    0xc(%ebp),%edx
f0108e64:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0108e67:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0108e6a:	8b 55 10             	mov    0x10(%ebp),%edx
f0108e6d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0108e70:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0108e73:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f0108e7a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0108e7d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
f0108e80:	72 14                	jb     f0108e96 <printnum+0x46>
f0108e82:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0108e85:	39 45 e8             	cmp    %eax,-0x18(%ebp)
f0108e88:	76 0c                	jbe    f0108e96 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0108e8a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0108e8d:	83 eb 01             	sub    $0x1,%ebx
f0108e90:	85 db                	test   %ebx,%ebx
f0108e92:	7f 57                	jg     f0108eeb <printnum+0x9b>
f0108e94:	eb 64                	jmp    f0108efa <printnum+0xaa>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0108e96:	89 74 24 10          	mov    %esi,0x10(%esp)
f0108e9a:	8b 45 14             	mov    0x14(%ebp),%eax
f0108e9d:	83 e8 01             	sub    $0x1,%eax
f0108ea0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0108ea4:	89 54 24 08          	mov    %edx,0x8(%esp)
f0108ea8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0108eac:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0108eb0:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0108eb3:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0108eb6:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108eba:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0108ebe:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0108ec1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0108ec4:	89 04 24             	mov    %eax,(%esp)
f0108ec7:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108ecb:	e8 d0 15 00 00       	call   f010a4a0 <__udivdi3>
f0108ed0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0108ed4:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0108ed8:	89 04 24             	mov    %eax,(%esp)
f0108edb:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108edf:	89 fa                	mov    %edi,%edx
f0108ee1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0108ee4:	e8 67 ff ff ff       	call   f0108e50 <printnum>
f0108ee9:	eb 0f                	jmp    f0108efa <printnum+0xaa>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0108eeb:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0108eef:	89 34 24             	mov    %esi,(%esp)
f0108ef2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0108ef5:	83 eb 01             	sub    $0x1,%ebx
f0108ef8:	75 f1                	jne    f0108eeb <printnum+0x9b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0108efa:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0108efe:	8b 74 24 04          	mov    0x4(%esp),%esi
f0108f02:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0108f05:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0108f08:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108f0c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0108f10:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0108f13:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0108f16:	89 04 24             	mov    %eax,(%esp)
f0108f19:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108f1d:	e8 ae 16 00 00       	call   f010a5d0 <__umoddi3>
f0108f22:	89 74 24 04          	mov    %esi,0x4(%esp)
f0108f26:	0f be 80 06 43 11 f0 	movsbl -0xfeebcfa(%eax),%eax
f0108f2d:	89 04 24             	mov    %eax,(%esp)
f0108f30:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0108f33:	83 c4 3c             	add    $0x3c,%esp
f0108f36:	5b                   	pop    %ebx
f0108f37:	5e                   	pop    %esi
f0108f38:	5f                   	pop    %edi
f0108f39:	5d                   	pop    %ebp
f0108f3a:	c3                   	ret    

f0108f3b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0108f3b:	55                   	push   %ebp
f0108f3c:	89 e5                	mov    %esp,%ebp
f0108f3e:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
f0108f40:	83 fa 01             	cmp    $0x1,%edx
f0108f43:	7e 0e                	jle    f0108f53 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
f0108f45:	8b 10                	mov    (%eax),%edx
f0108f47:	8d 42 08             	lea    0x8(%edx),%eax
f0108f4a:	89 01                	mov    %eax,(%ecx)
f0108f4c:	8b 02                	mov    (%edx),%eax
f0108f4e:	8b 52 04             	mov    0x4(%edx),%edx
f0108f51:	eb 22                	jmp    f0108f75 <getuint+0x3a>
	else if (lflag)
f0108f53:	85 d2                	test   %edx,%edx
f0108f55:	74 10                	je     f0108f67 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
f0108f57:	8b 10                	mov    (%eax),%edx
f0108f59:	8d 42 04             	lea    0x4(%edx),%eax
f0108f5c:	89 01                	mov    %eax,(%ecx)
f0108f5e:	8b 02                	mov    (%edx),%eax
f0108f60:	ba 00 00 00 00       	mov    $0x0,%edx
f0108f65:	eb 0e                	jmp    f0108f75 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
f0108f67:	8b 10                	mov    (%eax),%edx
f0108f69:	8d 42 04             	lea    0x4(%edx),%eax
f0108f6c:	89 01                	mov    %eax,(%ecx)
f0108f6e:	8b 02                	mov    (%edx),%eax
f0108f70:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0108f75:	5d                   	pop    %ebp
f0108f76:	c3                   	ret    

f0108f77 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0108f77:	55                   	push   %ebp
f0108f78:	89 e5                	mov    %esp,%ebp
f0108f7a:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
f0108f7d:	83 42 08 01          	addl   $0x1,0x8(%edx)
	if (b->buf < b->ebuf)
f0108f81:	8b 02                	mov    (%edx),%eax
f0108f83:	3b 42 04             	cmp    0x4(%edx),%eax
f0108f86:	73 0b                	jae    f0108f93 <sprintputch+0x1c>
		*b->buf++ = ch;
f0108f88:	0f b6 4d 08          	movzbl 0x8(%ebp),%ecx
f0108f8c:	88 08                	mov    %cl,(%eax)
f0108f8e:	83 c0 01             	add    $0x1,%eax
f0108f91:	89 02                	mov    %eax,(%edx)
}
f0108f93:	5d                   	pop    %ebp
f0108f94:	c3                   	ret    

f0108f95 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0108f95:	55                   	push   %ebp
f0108f96:	89 e5                	mov    %esp,%ebp
f0108f98:	57                   	push   %edi
f0108f99:	56                   	push   %esi
f0108f9a:	53                   	push   %ebx
f0108f9b:	83 ec 3c             	sub    $0x3c,%esp
f0108f9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0108fa1:	eb 18                	jmp    f0108fbb <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0108fa3:	84 c0                	test   %al,%al
f0108fa5:	0f 84 9f 03 00 00    	je     f010934a <vprintfmt+0x3b5>
				return;
			putch(ch, putdat);
f0108fab:	8b 55 0c             	mov    0xc(%ebp),%edx
f0108fae:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108fb2:	0f b6 c0             	movzbl %al,%eax
f0108fb5:	89 04 24             	mov    %eax,(%esp)
f0108fb8:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0108fbb:	0f b6 03             	movzbl (%ebx),%eax
f0108fbe:	83 c3 01             	add    $0x1,%ebx
f0108fc1:	3c 25                	cmp    $0x25,%al
f0108fc3:	75 de                	jne    f0108fa3 <vprintfmt+0xe>
f0108fc5:	b9 00 00 00 00       	mov    $0x0,%ecx
f0108fca:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
f0108fd1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0108fd6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0108fdd:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
f0108fe1:	eb 07                	jmp    f0108fea <vprintfmt+0x55>
f0108fe3:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0108fea:	0f b6 13             	movzbl (%ebx),%edx
f0108fed:	83 c3 01             	add    $0x1,%ebx
f0108ff0:	8d 42 dd             	lea    -0x23(%edx),%eax
f0108ff3:	3c 55                	cmp    $0x55,%al
f0108ff5:	0f 87 22 03 00 00    	ja     f010931d <vprintfmt+0x388>
f0108ffb:	0f b6 c0             	movzbl %al,%eax
f0108ffe:	ff 24 85 40 44 11 f0 	jmp    *-0xfeebbc0(,%eax,4)
f0109005:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
f0109009:	eb df                	jmp    f0108fea <vprintfmt+0x55>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010900b:	0f b6 c2             	movzbl %dl,%eax
f010900e:	8d 78 d0             	lea    -0x30(%eax),%edi
				ch = *fmt;
f0109011:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f0109014:	8d 42 d0             	lea    -0x30(%edx),%eax
f0109017:	83 f8 09             	cmp    $0x9,%eax
f010901a:	76 08                	jbe    f0109024 <vprintfmt+0x8f>
f010901c:	eb 39                	jmp    f0109057 <vprintfmt+0xc2>
f010901e:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
f0109022:	eb c6                	jmp    f0108fea <vprintfmt+0x55>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0109024:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f0109027:	8d 04 bf             	lea    (%edi,%edi,4),%eax
f010902a:	8d 7c 42 d0          	lea    -0x30(%edx,%eax,2),%edi
				ch = *fmt;
f010902e:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f0109031:	8d 42 d0             	lea    -0x30(%edx),%eax
f0109034:	83 f8 09             	cmp    $0x9,%eax
f0109037:	77 1e                	ja     f0109057 <vprintfmt+0xc2>
f0109039:	eb e9                	jmp    f0109024 <vprintfmt+0x8f>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010903b:	8b 55 14             	mov    0x14(%ebp),%edx
f010903e:	8d 42 04             	lea    0x4(%edx),%eax
f0109041:	89 45 14             	mov    %eax,0x14(%ebp)
f0109044:	8b 3a                	mov    (%edx),%edi
f0109046:	eb 0f                	jmp    f0109057 <vprintfmt+0xc2>
			goto process_precision;

		case '.':
			if (width < 0)
f0109048:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010904c:	79 9c                	jns    f0108fea <vprintfmt+0x55>
f010904e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0109055:	eb 93                	jmp    f0108fea <vprintfmt+0x55>
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0109057:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010905b:	90                   	nop    
f010905c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0109060:	79 88                	jns    f0108fea <vprintfmt+0x55>
f0109062:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0109065:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f010906a:	e9 7b ff ff ff       	jmp    f0108fea <vprintfmt+0x55>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010906f:	83 c1 01             	add    $0x1,%ecx
f0109072:	e9 73 ff ff ff       	jmp    f0108fea <vprintfmt+0x55>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0109077:	8b 45 14             	mov    0x14(%ebp),%eax
f010907a:	8d 50 04             	lea    0x4(%eax),%edx
f010907d:	89 55 14             	mov    %edx,0x14(%ebp)
f0109080:	8b 55 0c             	mov    0xc(%ebp),%edx
f0109083:	89 54 24 04          	mov    %edx,0x4(%esp)
f0109087:	8b 00                	mov    (%eax),%eax
f0109089:	89 04 24             	mov    %eax,(%esp)
f010908c:	ff 55 08             	call   *0x8(%ebp)
f010908f:	e9 27 ff ff ff       	jmp    f0108fbb <vprintfmt+0x26>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0109094:	8b 55 14             	mov    0x14(%ebp),%edx
f0109097:	8d 42 04             	lea    0x4(%edx),%eax
f010909a:	89 45 14             	mov    %eax,0x14(%ebp)
f010909d:	8b 02                	mov    (%edx),%eax
f010909f:	89 c2                	mov    %eax,%edx
f01090a1:	c1 fa 1f             	sar    $0x1f,%edx
f01090a4:	31 d0                	xor    %edx,%eax
f01090a6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f01090a8:	83 f8 0f             	cmp    $0xf,%eax
f01090ab:	7f 0b                	jg     f01090b8 <vprintfmt+0x123>
f01090ad:	8b 14 85 a0 45 11 f0 	mov    -0xfeeba60(,%eax,4),%edx
f01090b4:	85 d2                	test   %edx,%edx
f01090b6:	75 23                	jne    f01090db <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f01090b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01090bc:	c7 44 24 08 17 43 11 	movl   $0xf0114317,0x8(%esp)
f01090c3:	f0 
f01090c4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01090c7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01090cb:	8b 55 08             	mov    0x8(%ebp),%edx
f01090ce:	89 14 24             	mov    %edx,(%esp)
f01090d1:	e8 ff 02 00 00       	call   f01093d5 <printfmt>
f01090d6:	e9 e0 fe ff ff       	jmp    f0108fbb <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f01090db:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01090df:	c7 44 24 08 be b6 10 	movl   $0xf010b6be,0x8(%esp)
f01090e6:	f0 
f01090e7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01090ea:	89 44 24 04          	mov    %eax,0x4(%esp)
f01090ee:	8b 55 08             	mov    0x8(%ebp),%edx
f01090f1:	89 14 24             	mov    %edx,(%esp)
f01090f4:	e8 dc 02 00 00       	call   f01093d5 <printfmt>
f01090f9:	e9 bd fe ff ff       	jmp    f0108fbb <vprintfmt+0x26>
f01090fe:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0109101:	89 f9                	mov    %edi,%ecx
f0109103:	89 5d ec             	mov    %ebx,-0x14(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0109106:	8b 55 14             	mov    0x14(%ebp),%edx
f0109109:	8d 42 04             	lea    0x4(%edx),%eax
f010910c:	89 45 14             	mov    %eax,0x14(%ebp)
f010910f:	8b 12                	mov    (%edx),%edx
f0109111:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0109114:	85 d2                	test   %edx,%edx
f0109116:	75 07                	jne    f010911f <vprintfmt+0x18a>
f0109118:	c7 45 dc 20 43 11 f0 	movl   $0xf0114320,-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f010911f:	85 f6                	test   %esi,%esi
f0109121:	7e 41                	jle    f0109164 <vprintfmt+0x1cf>
f0109123:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
f0109127:	74 3b                	je     f0109164 <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
f0109129:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010912d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0109130:	89 04 24             	mov    %eax,(%esp)
f0109133:	e8 c8 03 00 00       	call   f0109500 <strnlen>
f0109138:	29 c6                	sub    %eax,%esi
f010913a:	89 75 f0             	mov    %esi,-0x10(%ebp)
f010913d:	85 f6                	test   %esi,%esi
f010913f:	7e 23                	jle    f0109164 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0109141:	0f be 55 eb          	movsbl -0x15(%ebp),%edx
f0109145:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0109148:	8b 45 0c             	mov    0xc(%ebp),%eax
f010914b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010914f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0109152:	89 14 24             	mov    %edx,(%esp)
f0109155:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0109158:	83 ee 01             	sub    $0x1,%esi
f010915b:	75 eb                	jne    f0109148 <vprintfmt+0x1b3>
f010915d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0109164:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0109167:	0f b6 02             	movzbl (%edx),%eax
f010916a:	0f be d0             	movsbl %al,%edx
f010916d:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0109170:	84 c0                	test   %al,%al
f0109172:	75 42                	jne    f01091b6 <vprintfmt+0x221>
f0109174:	eb 49                	jmp    f01091bf <vprintfmt+0x22a>
				if (altflag && (ch < ' ' || ch > '~'))
f0109176:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010917a:	74 1b                	je     f0109197 <vprintfmt+0x202>
f010917c:	8d 42 e0             	lea    -0x20(%edx),%eax
f010917f:	83 f8 5e             	cmp    $0x5e,%eax
f0109182:	76 13                	jbe    f0109197 <vprintfmt+0x202>
					putch('?', putdat);
f0109184:	8b 45 0c             	mov    0xc(%ebp),%eax
f0109187:	89 44 24 04          	mov    %eax,0x4(%esp)
f010918b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0109192:	ff 55 08             	call   *0x8(%ebp)
f0109195:	eb 0d                	jmp    f01091a4 <vprintfmt+0x20f>
				else
					putch(ch, putdat);
f0109197:	8b 45 0c             	mov    0xc(%ebp),%eax
f010919a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010919e:	89 14 24             	mov    %edx,(%esp)
f01091a1:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01091a4:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
f01091a8:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f01091ac:	83 c6 01             	add    $0x1,%esi
f01091af:	84 c0                	test   %al,%al
f01091b1:	74 0c                	je     f01091bf <vprintfmt+0x22a>
f01091b3:	0f be d0             	movsbl %al,%edx
f01091b6:	85 ff                	test   %edi,%edi
f01091b8:	78 bc                	js     f0109176 <vprintfmt+0x1e1>
f01091ba:	83 ef 01             	sub    $0x1,%edi
f01091bd:	79 b7                	jns    f0109176 <vprintfmt+0x1e1>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01091bf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f01091c3:	0f 8e f2 fd ff ff    	jle    f0108fbb <vprintfmt+0x26>
				putch(' ', putdat);
f01091c9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01091cc:	89 54 24 04          	mov    %edx,0x4(%esp)
f01091d0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01091d7:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01091da:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
f01091de:	75 e9                	jne    f01091c9 <vprintfmt+0x234>
f01091e0:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f01091e3:	e9 d3 fd ff ff       	jmp    f0108fbb <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01091e8:	83 f9 01             	cmp    $0x1,%ecx
f01091eb:	90                   	nop    
f01091ec:	8d 74 26 00          	lea    0x0(%esi),%esi
f01091f0:	7e 10                	jle    f0109202 <vprintfmt+0x26d>
		return va_arg(*ap, long long);
f01091f2:	8b 55 14             	mov    0x14(%ebp),%edx
f01091f5:	8d 42 08             	lea    0x8(%edx),%eax
f01091f8:	89 45 14             	mov    %eax,0x14(%ebp)
f01091fb:	8b 32                	mov    (%edx),%esi
f01091fd:	8b 7a 04             	mov    0x4(%edx),%edi
f0109200:	eb 2a                	jmp    f010922c <vprintfmt+0x297>
	else if (lflag)
f0109202:	85 c9                	test   %ecx,%ecx
f0109204:	74 14                	je     f010921a <vprintfmt+0x285>
		return va_arg(*ap, long);
f0109206:	8b 45 14             	mov    0x14(%ebp),%eax
f0109209:	8d 50 04             	lea    0x4(%eax),%edx
f010920c:	89 55 14             	mov    %edx,0x14(%ebp)
f010920f:	8b 00                	mov    (%eax),%eax
f0109211:	89 c6                	mov    %eax,%esi
f0109213:	89 c7                	mov    %eax,%edi
f0109215:	c1 ff 1f             	sar    $0x1f,%edi
f0109218:	eb 12                	jmp    f010922c <vprintfmt+0x297>
	else
		return va_arg(*ap, int);
f010921a:	8b 45 14             	mov    0x14(%ebp),%eax
f010921d:	8d 50 04             	lea    0x4(%eax),%edx
f0109220:	89 55 14             	mov    %edx,0x14(%ebp)
f0109223:	8b 00                	mov    (%eax),%eax
f0109225:	89 c6                	mov    %eax,%esi
f0109227:	89 c7                	mov    %eax,%edi
f0109229:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010922c:	89 f2                	mov    %esi,%edx
f010922e:	89 f9                	mov    %edi,%ecx
f0109230:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
			if ((long long) num < 0) {
f0109237:	85 ff                	test   %edi,%edi
f0109239:	0f 89 9b 00 00 00    	jns    f01092da <vprintfmt+0x345>
				putch('-', putdat);
f010923f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0109242:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109246:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010924d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0109250:	89 f2                	mov    %esi,%edx
f0109252:	89 f9                	mov    %edi,%ecx
f0109254:	f7 da                	neg    %edx
f0109256:	83 d1 00             	adc    $0x0,%ecx
f0109259:	f7 d9                	neg    %ecx
f010925b:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
f0109262:	eb 76                	jmp    f01092da <vprintfmt+0x345>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0109264:	89 ca                	mov    %ecx,%edx
f0109266:	8d 45 14             	lea    0x14(%ebp),%eax
f0109269:	e8 cd fc ff ff       	call   f0108f3b <getuint>
f010926e:	89 d1                	mov    %edx,%ecx
f0109270:	89 c2                	mov    %eax,%edx
f0109272:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
f0109279:	eb 5f                	jmp    f01092da <vprintfmt+0x345>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap,lflag);
f010927b:	89 ca                	mov    %ecx,%edx
f010927d:	8d 45 14             	lea    0x14(%ebp),%eax
f0109280:	e8 b6 fc ff ff       	call   f0108f3b <getuint>
f0109285:	e9 31 fd ff ff       	jmp    f0108fbb <vprintfmt+0x26>
			base=8;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f010928a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010928d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0109291:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0109298:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f010929b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010929e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01092a2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01092a9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f01092ac:	8b 55 14             	mov    0x14(%ebp),%edx
f01092af:	8d 42 04             	lea    0x4(%edx),%eax
f01092b2:	89 45 14             	mov    %eax,0x14(%ebp)
f01092b5:	8b 12                	mov    (%edx),%edx
f01092b7:	b9 00 00 00 00       	mov    $0x0,%ecx
f01092bc:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
f01092c3:	eb 15                	jmp    f01092da <vprintfmt+0x345>
			base = 16;
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01092c5:	89 ca                	mov    %ecx,%edx
f01092c7:	8d 45 14             	lea    0x14(%ebp),%eax
f01092ca:	e8 6c fc ff ff       	call   f0108f3b <getuint>
f01092cf:	89 d1                	mov    %edx,%ecx
f01092d1:	89 c2                	mov    %eax,%edx
f01092d3:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f01092da:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
f01092de:	89 44 24 10          	mov    %eax,0x10(%esp)
f01092e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01092e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01092e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01092ec:	89 44 24 08          	mov    %eax,0x8(%esp)
f01092f0:	89 14 24             	mov    %edx,(%esp)
f01092f3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01092f7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01092fa:	8b 45 08             	mov    0x8(%ebp),%eax
f01092fd:	e8 4e fb ff ff       	call   f0108e50 <printnum>
f0109302:	e9 b4 fc ff ff       	jmp    f0108fbb <vprintfmt+0x26>
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0109307:	8b 55 0c             	mov    0xc(%ebp),%edx
f010930a:	89 54 24 04          	mov    %edx,0x4(%esp)
f010930e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0109315:	ff 55 08             	call   *0x8(%ebp)
f0109318:	e9 9e fc ff ff       	jmp    f0108fbb <vprintfmt+0x26>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010931d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0109320:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109324:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f010932b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010932e:	83 eb 01             	sub    $0x1,%ebx
f0109331:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0109335:	0f 84 80 fc ff ff    	je     f0108fbb <vprintfmt+0x26>
f010933b:	83 eb 01             	sub    $0x1,%ebx
f010933e:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0109342:	0f 84 73 fc ff ff    	je     f0108fbb <vprintfmt+0x26>
f0109348:	eb f1                	jmp    f010933b <vprintfmt+0x3a6>
				/* do nothing */;
			break;
		}
	}
}
f010934a:	83 c4 3c             	add    $0x3c,%esp
f010934d:	5b                   	pop    %ebx
f010934e:	5e                   	pop    %esi
f010934f:	5f                   	pop    %edi
f0109350:	5d                   	pop    %ebp
f0109351:	c3                   	ret    

f0109352 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0109352:	55                   	push   %ebp
f0109353:	89 e5                	mov    %esp,%ebp
f0109355:	83 ec 28             	sub    $0x28,%esp
f0109358:	8b 55 08             	mov    0x8(%ebp),%edx
f010935b:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f010935e:	85 d2                	test   %edx,%edx
f0109360:	74 04                	je     f0109366 <vsnprintf+0x14>
f0109362:	85 c0                	test   %eax,%eax
f0109364:	7f 07                	jg     f010936d <vsnprintf+0x1b>
f0109366:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010936b:	eb 3b                	jmp    f01093a8 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f010936d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f0109374:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
f0109378:	89 45 f8             	mov    %eax,-0x8(%ebp)
f010937b:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010937e:	8b 45 14             	mov    0x14(%ebp),%eax
f0109381:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0109385:	8b 45 10             	mov    0x10(%ebp),%eax
f0109388:	89 44 24 08          	mov    %eax,0x8(%esp)
f010938c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010938f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109393:	c7 04 24 77 8f 10 f0 	movl   $0xf0108f77,(%esp)
f010939a:	e8 f6 fb ff ff       	call   f0108f95 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010939f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01093a2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01093a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f01093a8:	c9                   	leave  
f01093a9:	c3                   	ret    

f01093aa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01093aa:	55                   	push   %ebp
f01093ab:	89 e5                	mov    %esp,%ebp
f01093ad:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01093b0:	8d 45 14             	lea    0x14(%ebp),%eax
f01093b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
f01093b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01093ba:	8b 45 10             	mov    0x10(%ebp),%eax
f01093bd:	89 44 24 08          	mov    %eax,0x8(%esp)
f01093c1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01093c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01093c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01093cb:	89 04 24             	mov    %eax,(%esp)
f01093ce:	e8 7f ff ff ff       	call   f0109352 <vsnprintf>
	va_end(ap);

	return rc;
}
f01093d3:	c9                   	leave  
f01093d4:	c3                   	ret    

f01093d5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01093d5:	55                   	push   %ebp
f01093d6:	89 e5                	mov    %esp,%ebp
f01093d8:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
f01093db:	8d 45 14             	lea    0x14(%ebp),%eax
f01093de:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
f01093e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01093e5:	8b 45 10             	mov    0x10(%ebp),%eax
f01093e8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01093ec:	8b 45 0c             	mov    0xc(%ebp),%eax
f01093ef:	89 44 24 04          	mov    %eax,0x4(%esp)
f01093f3:	8b 45 08             	mov    0x8(%ebp),%eax
f01093f6:	89 04 24             	mov    %eax,(%esp)
f01093f9:	e8 97 fb ff ff       	call   f0108f95 <vprintfmt>
	va_end(ap);
}
f01093fe:	c9                   	leave  
f01093ff:	c3                   	ret    

f0109400 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0109400:	55                   	push   %ebp
f0109401:	89 e5                	mov    %esp,%ebp
f0109403:	57                   	push   %edi
f0109404:	56                   	push   %esi
f0109405:	53                   	push   %ebx
f0109406:	83 ec 0c             	sub    $0xc,%esp
f0109409:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010940c:	85 c0                	test   %eax,%eax
f010940e:	74 10                	je     f0109420 <readline+0x20>
		cprintf("%s", prompt);
f0109410:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109414:	c7 04 24 be b6 10 f0 	movl   $0xf010b6be,(%esp)
f010941b:	e8 c7 a5 ff ff       	call   f01039e7 <cprintf>

	i = 0;
	echoing = iscons(0);
f0109420:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0109427:	e8 49 6e ff ff       	call   f0100275 <iscons>
f010942c:	89 c7                	mov    %eax,%edi
f010942e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0109433:	e8 2c 6e ff ff       	call   f0100264 <getchar>
f0109438:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010943a:	85 c0                	test   %eax,%eax
f010943c:	79 17                	jns    f0109455 <readline+0x55>
			cprintf("read error: %e\n", c);
f010943e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109442:	c7 04 24 ff 45 11 f0 	movl   $0xf01145ff,(%esp)
f0109449:	e8 99 a5 ff ff       	call   f01039e7 <cprintf>
f010944e:	b8 00 00 00 00       	mov    $0x0,%eax
f0109453:	eb 76                	jmp    f01094cb <readline+0xcb>
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0109455:	83 f8 08             	cmp    $0x8,%eax
f0109458:	74 08                	je     f0109462 <readline+0x62>
f010945a:	83 f8 7f             	cmp    $0x7f,%eax
f010945d:	8d 76 00             	lea    0x0(%esi),%esi
f0109460:	75 19                	jne    f010947b <readline+0x7b>
f0109462:	85 f6                	test   %esi,%esi
f0109464:	7e 15                	jle    f010947b <readline+0x7b>
			if (echoing)
f0109466:	85 ff                	test   %edi,%edi
f0109468:	74 0c                	je     f0109476 <readline+0x76>
				cputchar('\b');
f010946a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0109471:	e8 f4 6f ff ff       	call   f010046a <cputchar>
			i--;
f0109476:	83 ee 01             	sub    $0x1,%esi
f0109479:	eb b8                	jmp    f0109433 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010947b:	83 fb 1f             	cmp    $0x1f,%ebx
f010947e:	66 90                	xchg   %ax,%ax
f0109480:	7e 23                	jle    f01094a5 <readline+0xa5>
f0109482:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0109488:	7f 1b                	jg     f01094a5 <readline+0xa5>
			if (echoing)
f010948a:	85 ff                	test   %edi,%edi
f010948c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0109490:	74 08                	je     f010949a <readline+0x9a>
				cputchar(c);
f0109492:	89 1c 24             	mov    %ebx,(%esp)
f0109495:	e8 d0 6f ff ff       	call   f010046a <cputchar>
			buf[i++] = c;
f010949a:	88 9e e0 50 29 f0    	mov    %bl,-0xfd6af20(%esi)
f01094a0:	83 c6 01             	add    $0x1,%esi
f01094a3:	eb 8e                	jmp    f0109433 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01094a5:	83 fb 0a             	cmp    $0xa,%ebx
f01094a8:	74 05                	je     f01094af <readline+0xaf>
f01094aa:	83 fb 0d             	cmp    $0xd,%ebx
f01094ad:	75 84                	jne    f0109433 <readline+0x33>
			if (echoing)
f01094af:	85 ff                	test   %edi,%edi
f01094b1:	74 0c                	je     f01094bf <readline+0xbf>
				cputchar('\n');
f01094b3:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01094ba:	e8 ab 6f ff ff       	call   f010046a <cputchar>
			buf[i] = 0;
f01094bf:	c6 86 e0 50 29 f0 00 	movb   $0x0,-0xfd6af20(%esi)
f01094c6:	b8 e0 50 29 f0       	mov    $0xf02950e0,%eax
			return buf;
		}
	}
}
f01094cb:	83 c4 0c             	add    $0xc,%esp
f01094ce:	5b                   	pop    %ebx
f01094cf:	5e                   	pop    %esi
f01094d0:	5f                   	pop    %edi
f01094d1:	5d                   	pop    %ebp
f01094d2:	c3                   	ret    
	...

f01094e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01094e0:	55                   	push   %ebp
f01094e1:	89 e5                	mov    %esp,%ebp
f01094e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01094e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01094eb:	80 3a 00             	cmpb   $0x0,(%edx)
f01094ee:	74 0e                	je     f01094fe <strlen+0x1e>
f01094f0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01094f5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01094f8:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
f01094fc:	75 f7                	jne    f01094f5 <strlen+0x15>
		n++;
	return n;
}
f01094fe:	5d                   	pop    %ebp
f01094ff:	c3                   	ret    

f0109500 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0109500:	55                   	push   %ebp
f0109501:	89 e5                	mov    %esp,%ebp
f0109503:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0109506:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0109509:	85 d2                	test   %edx,%edx
f010950b:	74 19                	je     f0109526 <strnlen+0x26>
f010950d:	80 39 00             	cmpb   $0x0,(%ecx)
f0109510:	74 14                	je     f0109526 <strnlen+0x26>
f0109512:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0109517:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010951a:	39 d0                	cmp    %edx,%eax
f010951c:	74 0d                	je     f010952b <strnlen+0x2b>
f010951e:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
f0109522:	74 07                	je     f010952b <strnlen+0x2b>
f0109524:	eb f1                	jmp    f0109517 <strnlen+0x17>
f0109526:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f010952b:	5d                   	pop    %ebp
f010952c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0109530:	c3                   	ret    

f0109531 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0109531:	55                   	push   %ebp
f0109532:	89 e5                	mov    %esp,%ebp
f0109534:	53                   	push   %ebx
f0109535:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0109538:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010953b:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010953d:	0f b6 01             	movzbl (%ecx),%eax
f0109540:	88 02                	mov    %al,(%edx)
f0109542:	83 c2 01             	add    $0x1,%edx
f0109545:	83 c1 01             	add    $0x1,%ecx
f0109548:	84 c0                	test   %al,%al
f010954a:	75 f1                	jne    f010953d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010954c:	89 d8                	mov    %ebx,%eax
f010954e:	5b                   	pop    %ebx
f010954f:	5d                   	pop    %ebp
f0109550:	c3                   	ret    

f0109551 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0109551:	55                   	push   %ebp
f0109552:	89 e5                	mov    %esp,%ebp
f0109554:	57                   	push   %edi
f0109555:	56                   	push   %esi
f0109556:	53                   	push   %ebx
f0109557:	8b 7d 08             	mov    0x8(%ebp),%edi
f010955a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010955d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0109560:	85 f6                	test   %esi,%esi
f0109562:	74 1c                	je     f0109580 <strncpy+0x2f>
f0109564:	89 fa                	mov    %edi,%edx
f0109566:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
f010956b:	0f b6 01             	movzbl (%ecx),%eax
f010956e:	88 02                	mov    %al,(%edx)
f0109570:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0109573:	80 39 01             	cmpb   $0x1,(%ecx)
f0109576:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0109579:	83 c3 01             	add    $0x1,%ebx
f010957c:	39 f3                	cmp    %esi,%ebx
f010957e:	75 eb                	jne    f010956b <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0109580:	89 f8                	mov    %edi,%eax
f0109582:	5b                   	pop    %ebx
f0109583:	5e                   	pop    %esi
f0109584:	5f                   	pop    %edi
f0109585:	5d                   	pop    %ebp
f0109586:	c3                   	ret    

f0109587 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0109587:	55                   	push   %ebp
f0109588:	89 e5                	mov    %esp,%ebp
f010958a:	56                   	push   %esi
f010958b:	53                   	push   %ebx
f010958c:	8b 75 08             	mov    0x8(%ebp),%esi
f010958f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0109592:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0109595:	89 f0                	mov    %esi,%eax
f0109597:	85 d2                	test   %edx,%edx
f0109599:	74 2c                	je     f01095c7 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f010959b:	89 d3                	mov    %edx,%ebx
f010959d:	83 eb 01             	sub    $0x1,%ebx
f01095a0:	74 20                	je     f01095c2 <strlcpy+0x3b>
f01095a2:	0f b6 11             	movzbl (%ecx),%edx
f01095a5:	84 d2                	test   %dl,%dl
f01095a7:	74 19                	je     f01095c2 <strlcpy+0x3b>
f01095a9:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
f01095ab:	88 10                	mov    %dl,(%eax)
f01095ad:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01095b0:	83 eb 01             	sub    $0x1,%ebx
f01095b3:	74 0f                	je     f01095c4 <strlcpy+0x3d>
f01095b5:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
f01095b9:	83 c1 01             	add    $0x1,%ecx
f01095bc:	84 d2                	test   %dl,%dl
f01095be:	74 04                	je     f01095c4 <strlcpy+0x3d>
f01095c0:	eb e9                	jmp    f01095ab <strlcpy+0x24>
f01095c2:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f01095c4:	c6 00 00             	movb   $0x0,(%eax)
f01095c7:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f01095c9:	5b                   	pop    %ebx
f01095ca:	5e                   	pop    %esi
f01095cb:	5d                   	pop    %ebp
f01095cc:	c3                   	ret    

f01095cd <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
f01095cd:	55                   	push   %ebp
f01095ce:	89 e5                	mov    %esp,%ebp
f01095d0:	56                   	push   %esi
f01095d1:	53                   	push   %ebx
f01095d2:	8b 75 08             	mov    0x8(%ebp),%esi
f01095d5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01095d8:	8b 55 10             	mov    0x10(%ebp),%edx
    int c;
    char *q = buf;

    if (buf_size <= 0)
f01095db:	85 c0                	test   %eax,%eax
f01095dd:	7e 2e                	jle    f010960d <pstrcpy+0x40>
        return;

    for(;;) {
        c = *str++;
f01095df:	0f b6 0a             	movzbl (%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
f01095e2:	84 c9                	test   %cl,%cl
f01095e4:	74 22                	je     f0109608 <pstrcpy+0x3b>
f01095e6:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
f01095ea:	89 f0                	mov    %esi,%eax
f01095ec:	39 de                	cmp    %ebx,%esi
f01095ee:	72 09                	jb     f01095f9 <pstrcpy+0x2c>
f01095f0:	eb 16                	jmp    f0109608 <pstrcpy+0x3b>
f01095f2:	83 c2 01             	add    $0x1,%edx
f01095f5:	39 d8                	cmp    %ebx,%eax
f01095f7:	73 11                	jae    f010960a <pstrcpy+0x3d>
            break;
        *q++ = c;
f01095f9:	88 08                	mov    %cl,(%eax)
f01095fb:	83 c0 01             	add    $0x1,%eax

    if (buf_size <= 0)
        return;

    for(;;) {
        c = *str++;
f01095fe:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
f0109602:	84 c9                	test   %cl,%cl
f0109604:	75 ec                	jne    f01095f2 <pstrcpy+0x25>
f0109606:	eb 02                	jmp    f010960a <pstrcpy+0x3d>
f0109608:	89 f0                	mov    %esi,%eax
            break;
        *q++ = c;
    }
    *q = '\0';
f010960a:	c6 00 00             	movb   $0x0,(%eax)
}
f010960d:	5b                   	pop    %ebx
f010960e:	5e                   	pop    %esi
f010960f:	5d                   	pop    %ebp
f0109610:	c3                   	ret    

f0109611 <strcmp>:
int
strcmp(const char *p, const char *q)
{
f0109611:	55                   	push   %ebp
f0109612:	89 e5                	mov    %esp,%ebp
f0109614:	8b 55 08             	mov    0x8(%ebp),%edx
f0109617:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
f010961a:	0f b6 02             	movzbl (%edx),%eax
f010961d:	84 c0                	test   %al,%al
f010961f:	74 16                	je     f0109637 <strcmp+0x26>
f0109621:	3a 01                	cmp    (%ecx),%al
f0109623:	75 12                	jne    f0109637 <strcmp+0x26>
		p++, q++;
f0109625:	83 c1 01             	add    $0x1,%ecx
    *q = '\0';
}
int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0109628:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f010962c:	84 c0                	test   %al,%al
f010962e:	74 07                	je     f0109637 <strcmp+0x26>
f0109630:	83 c2 01             	add    $0x1,%edx
f0109633:	3a 01                	cmp    (%ecx),%al
f0109635:	74 ee                	je     f0109625 <strcmp+0x14>
f0109637:	0f b6 c0             	movzbl %al,%eax
f010963a:	0f b6 11             	movzbl (%ecx),%edx
f010963d:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010963f:	5d                   	pop    %ebp
f0109640:	c3                   	ret    

f0109641 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0109641:	55                   	push   %ebp
f0109642:	89 e5                	mov    %esp,%ebp
f0109644:	53                   	push   %ebx
f0109645:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0109648:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010964b:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f010964e:	85 d2                	test   %edx,%edx
f0109650:	74 2d                	je     f010967f <strncmp+0x3e>
f0109652:	0f b6 01             	movzbl (%ecx),%eax
f0109655:	84 c0                	test   %al,%al
f0109657:	74 1a                	je     f0109673 <strncmp+0x32>
f0109659:	3a 03                	cmp    (%ebx),%al
f010965b:	75 16                	jne    f0109673 <strncmp+0x32>
f010965d:	83 ea 01             	sub    $0x1,%edx
f0109660:	74 1d                	je     f010967f <strncmp+0x3e>
		n--, p++, q++;
f0109662:	83 c1 01             	add    $0x1,%ecx
f0109665:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0109668:	0f b6 01             	movzbl (%ecx),%eax
f010966b:	84 c0                	test   %al,%al
f010966d:	74 04                	je     f0109673 <strncmp+0x32>
f010966f:	3a 03                	cmp    (%ebx),%al
f0109671:	74 ea                	je     f010965d <strncmp+0x1c>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0109673:	0f b6 11             	movzbl (%ecx),%edx
f0109676:	0f b6 03             	movzbl (%ebx),%eax
f0109679:	29 c2                	sub    %eax,%edx
f010967b:	89 d0                	mov    %edx,%eax
f010967d:	eb 05                	jmp    f0109684 <strncmp+0x43>
f010967f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0109684:	5b                   	pop    %ebx
f0109685:	5d                   	pop    %ebp
f0109686:	c3                   	ret    

f0109687 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0109687:	55                   	push   %ebp
f0109688:	89 e5                	mov    %esp,%ebp
f010968a:	8b 45 08             	mov    0x8(%ebp),%eax
f010968d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0109691:	0f b6 10             	movzbl (%eax),%edx
f0109694:	84 d2                	test   %dl,%dl
f0109696:	74 14                	je     f01096ac <strchr+0x25>
		if (*s == c)
f0109698:	38 ca                	cmp    %cl,%dl
f010969a:	75 06                	jne    f01096a2 <strchr+0x1b>
f010969c:	eb 13                	jmp    f01096b1 <strchr+0x2a>
f010969e:	38 ca                	cmp    %cl,%dl
f01096a0:	74 0f                	je     f01096b1 <strchr+0x2a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01096a2:	83 c0 01             	add    $0x1,%eax
f01096a5:	0f b6 10             	movzbl (%eax),%edx
f01096a8:	84 d2                	test   %dl,%dl
f01096aa:	75 f2                	jne    f010969e <strchr+0x17>
f01096ac:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f01096b1:	5d                   	pop    %ebp
f01096b2:	c3                   	ret    

f01096b3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01096b3:	55                   	push   %ebp
f01096b4:	89 e5                	mov    %esp,%ebp
f01096b6:	8b 45 08             	mov    0x8(%ebp),%eax
f01096b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01096bd:	0f b6 10             	movzbl (%eax),%edx
f01096c0:	84 d2                	test   %dl,%dl
f01096c2:	74 18                	je     f01096dc <strfind+0x29>
		if (*s == c)
f01096c4:	38 ca                	cmp    %cl,%dl
f01096c6:	75 0a                	jne    f01096d2 <strfind+0x1f>
f01096c8:	eb 12                	jmp    f01096dc <strfind+0x29>
f01096ca:	38 ca                	cmp    %cl,%dl
f01096cc:	8d 74 26 00          	lea    0x0(%esi),%esi
f01096d0:	74 0a                	je     f01096dc <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01096d2:	83 c0 01             	add    $0x1,%eax
f01096d5:	0f b6 10             	movzbl (%eax),%edx
f01096d8:	84 d2                	test   %dl,%dl
f01096da:	75 ee                	jne    f01096ca <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f01096dc:	5d                   	pop    %ebp
f01096dd:	c3                   	ret    

f01096de <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01096de:	55                   	push   %ebp
f01096df:	89 e5                	mov    %esp,%ebp
f01096e1:	83 ec 08             	sub    $0x8,%esp
f01096e4:	89 1c 24             	mov    %ebx,(%esp)
f01096e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01096eb:	8b 7d 08             	mov    0x8(%ebp),%edi
f01096ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
f01096f1:	85 db                	test   %ebx,%ebx
f01096f3:	74 36                	je     f010972b <memset+0x4d>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01096f5:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01096fb:	75 26                	jne    f0109723 <memset+0x45>
f01096fd:	f6 c3 03             	test   $0x3,%bl
f0109700:	75 21                	jne    f0109723 <memset+0x45>
		c &= 0xFF;
f0109702:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0109706:	89 d0                	mov    %edx,%eax
f0109708:	c1 e0 18             	shl    $0x18,%eax
f010970b:	89 d1                	mov    %edx,%ecx
f010970d:	c1 e1 10             	shl    $0x10,%ecx
f0109710:	09 c8                	or     %ecx,%eax
f0109712:	09 d0                	or     %edx,%eax
f0109714:	c1 e2 08             	shl    $0x8,%edx
f0109717:	09 d0                	or     %edx,%eax
f0109719:	89 d9                	mov    %ebx,%ecx
f010971b:	c1 e9 02             	shr    $0x2,%ecx
f010971e:	fc                   	cld    
f010971f:	f3 ab                	rep stos %eax,%es:(%edi)
f0109721:	eb 08                	jmp    f010972b <memset+0x4d>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0109723:	8b 45 0c             	mov    0xc(%ebp),%eax
f0109726:	89 d9                	mov    %ebx,%ecx
f0109728:	fc                   	cld    
f0109729:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010972b:	89 f8                	mov    %edi,%eax
f010972d:	8b 1c 24             	mov    (%esp),%ebx
f0109730:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0109734:	89 ec                	mov    %ebp,%esp
f0109736:	5d                   	pop    %ebp
f0109737:	c3                   	ret    

f0109738 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0109738:	55                   	push   %ebp
f0109739:	89 e5                	mov    %esp,%ebp
f010973b:	83 ec 08             	sub    $0x8,%esp
f010973e:	89 34 24             	mov    %esi,(%esp)
f0109741:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0109745:	8b 45 08             	mov    0x8(%ebp),%eax
f0109748:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
f010974b:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f010974e:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f0109750:	39 c6                	cmp    %eax,%esi
f0109752:	73 38                	jae    f010978c <memmove+0x54>
f0109754:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0109757:	39 d0                	cmp    %edx,%eax
f0109759:	73 31                	jae    f010978c <memmove+0x54>
		s += n;
		d += n;
f010975b:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010975e:	f6 c2 03             	test   $0x3,%dl
f0109761:	75 1d                	jne    f0109780 <memmove+0x48>
f0109763:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0109769:	75 15                	jne    f0109780 <memmove+0x48>
f010976b:	f6 c1 03             	test   $0x3,%cl
f010976e:	66 90                	xchg   %ax,%ax
f0109770:	75 0e                	jne    f0109780 <memmove+0x48>
			asm volatile("std; rep movsl\n"
f0109772:	8d 7e fc             	lea    -0x4(%esi),%edi
f0109775:	8d 72 fc             	lea    -0x4(%edx),%esi
f0109778:	c1 e9 02             	shr    $0x2,%ecx
f010977b:	fd                   	std    
f010977c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010977e:	eb 09                	jmp    f0109789 <memmove+0x51>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0109780:	8d 7e ff             	lea    -0x1(%esi),%edi
f0109783:	8d 72 ff             	lea    -0x1(%edx),%esi
f0109786:	fd                   	std    
f0109787:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0109789:	fc                   	cld    
f010978a:	eb 21                	jmp    f01097ad <memmove+0x75>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010978c:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0109792:	75 16                	jne    f01097aa <memmove+0x72>
f0109794:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010979a:	75 0e                	jne    f01097aa <memmove+0x72>
f010979c:	f6 c1 03             	test   $0x3,%cl
f010979f:	90                   	nop    
f01097a0:	75 08                	jne    f01097aa <memmove+0x72>
			asm volatile("cld; rep movsl\n"
f01097a2:	c1 e9 02             	shr    $0x2,%ecx
f01097a5:	fc                   	cld    
f01097a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01097a8:	eb 03                	jmp    f01097ad <memmove+0x75>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01097aa:	fc                   	cld    
f01097ab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01097ad:	8b 34 24             	mov    (%esp),%esi
f01097b0:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01097b4:	89 ec                	mov    %ebp,%esp
f01097b6:	5d                   	pop    %ebp
f01097b7:	c3                   	ret    

f01097b8 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f01097b8:	55                   	push   %ebp
f01097b9:	89 e5                	mov    %esp,%ebp
f01097bb:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01097be:	8b 45 10             	mov    0x10(%ebp),%eax
f01097c1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01097c5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01097c8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01097cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01097cf:	89 04 24             	mov    %eax,(%esp)
f01097d2:	e8 61 ff ff ff       	call   f0109738 <memmove>
}
f01097d7:	c9                   	leave  
f01097d8:	c3                   	ret    

f01097d9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01097d9:	55                   	push   %ebp
f01097da:	89 e5                	mov    %esp,%ebp
f01097dc:	57                   	push   %edi
f01097dd:	56                   	push   %esi
f01097de:	53                   	push   %ebx
f01097df:	83 ec 04             	sub    $0x4,%esp
f01097e2:	8b 45 08             	mov    0x8(%ebp),%eax
f01097e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01097e8:	8b 55 10             	mov    0x10(%ebp),%edx
f01097eb:	83 ea 01             	sub    $0x1,%edx
f01097ee:	83 fa ff             	cmp    $0xffffffff,%edx
f01097f1:	74 47                	je     f010983a <memcmp+0x61>
		if (*s1 != *s2)
f01097f3:	0f b6 30             	movzbl (%eax),%esi
f01097f6:	0f b6 39             	movzbl (%ecx),%edi
			return (int) *s1 - (int) *s2;
f01097f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
f01097fc:	89 f0                	mov    %esi,%eax
f01097fe:	89 fb                	mov    %edi,%ebx
f0109800:	38 d8                	cmp    %bl,%al
f0109802:	74 2e                	je     f0109832 <memcmp+0x59>
f0109804:	eb 1c                	jmp    f0109822 <memcmp+0x49>
f0109806:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0109809:	0f b6 70 01          	movzbl 0x1(%eax),%esi
f010980d:	0f b6 79 01          	movzbl 0x1(%ecx),%edi
f0109811:	83 c0 01             	add    $0x1,%eax
f0109814:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0109817:	83 c1 01             	add    $0x1,%ecx
f010981a:	89 f3                	mov    %esi,%ebx
f010981c:	89 f8                	mov    %edi,%eax
f010981e:	38 c3                	cmp    %al,%bl
f0109820:	74 10                	je     f0109832 <memcmp+0x59>
			return (int) *s1 - (int) *s2;
f0109822:	89 f1                	mov    %esi,%ecx
f0109824:	0f b6 d1             	movzbl %cl,%edx
f0109827:	89 fb                	mov    %edi,%ebx
f0109829:	0f b6 c3             	movzbl %bl,%eax
f010982c:	29 c2                	sub    %eax,%edx
f010982e:	89 d0                	mov    %edx,%eax
f0109830:	eb 0d                	jmp    f010983f <memcmp+0x66>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0109832:	83 ea 01             	sub    $0x1,%edx
f0109835:	83 fa ff             	cmp    $0xffffffff,%edx
f0109838:	75 cc                	jne    f0109806 <memcmp+0x2d>
f010983a:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f010983f:	83 c4 04             	add    $0x4,%esp
f0109842:	5b                   	pop    %ebx
f0109843:	5e                   	pop    %esi
f0109844:	5f                   	pop    %edi
f0109845:	5d                   	pop    %ebp
f0109846:	c3                   	ret    

f0109847 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0109847:	55                   	push   %ebp
f0109848:	89 e5                	mov    %esp,%ebp
f010984a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010984d:	89 c1                	mov    %eax,%ecx
f010984f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
f0109852:	39 c8                	cmp    %ecx,%eax
f0109854:	73 15                	jae    f010986b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0109856:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
f010985a:	38 10                	cmp    %dl,(%eax)
f010985c:	75 06                	jne    f0109864 <memfind+0x1d>
f010985e:	eb 0b                	jmp    f010986b <memfind+0x24>
f0109860:	38 10                	cmp    %dl,(%eax)
f0109862:	74 07                	je     f010986b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0109864:	83 c0 01             	add    $0x1,%eax
f0109867:	39 c8                	cmp    %ecx,%eax
f0109869:	75 f5                	jne    f0109860 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010986b:	5d                   	pop    %ebp
f010986c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0109870:	c3                   	ret    

f0109871 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0109871:	55                   	push   %ebp
f0109872:	89 e5                	mov    %esp,%ebp
f0109874:	57                   	push   %edi
f0109875:	56                   	push   %esi
f0109876:	53                   	push   %ebx
f0109877:	83 ec 04             	sub    $0x4,%esp
f010987a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010987d:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0109880:	0f b6 01             	movzbl (%ecx),%eax
f0109883:	3c 20                	cmp    $0x20,%al
f0109885:	74 04                	je     f010988b <strtol+0x1a>
f0109887:	3c 09                	cmp    $0x9,%al
f0109889:	75 0e                	jne    f0109899 <strtol+0x28>
		s++;
f010988b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010988e:	0f b6 01             	movzbl (%ecx),%eax
f0109891:	3c 20                	cmp    $0x20,%al
f0109893:	74 f6                	je     f010988b <strtol+0x1a>
f0109895:	3c 09                	cmp    $0x9,%al
f0109897:	74 f2                	je     f010988b <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f0109899:	3c 2b                	cmp    $0x2b,%al
f010989b:	75 0c                	jne    f01098a9 <strtol+0x38>
		s++;
f010989d:	83 c1 01             	add    $0x1,%ecx
f01098a0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01098a7:	eb 15                	jmp    f01098be <strtol+0x4d>
	else if (*s == '-')
f01098a9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01098b0:	3c 2d                	cmp    $0x2d,%al
f01098b2:	75 0a                	jne    f01098be <strtol+0x4d>
		s++, neg = 1;
f01098b4:	83 c1 01             	add    $0x1,%ecx
f01098b7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01098be:	85 f6                	test   %esi,%esi
f01098c0:	0f 94 c0             	sete   %al
f01098c3:	74 05                	je     f01098ca <strtol+0x59>
f01098c5:	83 fe 10             	cmp    $0x10,%esi
f01098c8:	75 18                	jne    f01098e2 <strtol+0x71>
f01098ca:	80 39 30             	cmpb   $0x30,(%ecx)
f01098cd:	75 13                	jne    f01098e2 <strtol+0x71>
f01098cf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01098d3:	75 0d                	jne    f01098e2 <strtol+0x71>
		s += 2, base = 16;
f01098d5:	83 c1 02             	add    $0x2,%ecx
f01098d8:	be 10 00 00 00       	mov    $0x10,%esi
f01098dd:	8d 76 00             	lea    0x0(%esi),%esi
f01098e0:	eb 1b                	jmp    f01098fd <strtol+0x8c>
	else if (base == 0 && s[0] == '0')
f01098e2:	85 f6                	test   %esi,%esi
f01098e4:	75 0e                	jne    f01098f4 <strtol+0x83>
f01098e6:	80 39 30             	cmpb   $0x30,(%ecx)
f01098e9:	75 09                	jne    f01098f4 <strtol+0x83>
		s++, base = 8;
f01098eb:	83 c1 01             	add    $0x1,%ecx
f01098ee:	66 be 08 00          	mov    $0x8,%si
f01098f2:	eb 09                	jmp    f01098fd <strtol+0x8c>
	else if (base == 0)
f01098f4:	84 c0                	test   %al,%al
f01098f6:	74 05                	je     f01098fd <strtol+0x8c>
f01098f8:	be 0a 00 00 00       	mov    $0xa,%esi
f01098fd:	bf 00 00 00 00       	mov    $0x0,%edi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0109902:	0f b6 11             	movzbl (%ecx),%edx
f0109905:	89 d3                	mov    %edx,%ebx
f0109907:	8d 42 d0             	lea    -0x30(%edx),%eax
f010990a:	3c 09                	cmp    $0x9,%al
f010990c:	77 08                	ja     f0109916 <strtol+0xa5>
			dig = *s - '0';
f010990e:	0f be c2             	movsbl %dl,%eax
f0109911:	8d 50 d0             	lea    -0x30(%eax),%edx
f0109914:	eb 1c                	jmp    f0109932 <strtol+0xc1>
		else if (*s >= 'a' && *s <= 'z')
f0109916:	8d 43 9f             	lea    -0x61(%ebx),%eax
f0109919:	3c 19                	cmp    $0x19,%al
f010991b:	77 08                	ja     f0109925 <strtol+0xb4>
			dig = *s - 'a' + 10;
f010991d:	0f be c2             	movsbl %dl,%eax
f0109920:	8d 50 a9             	lea    -0x57(%eax),%edx
f0109923:	eb 0d                	jmp    f0109932 <strtol+0xc1>
		else if (*s >= 'A' && *s <= 'Z')
f0109925:	8d 43 bf             	lea    -0x41(%ebx),%eax
f0109928:	3c 19                	cmp    $0x19,%al
f010992a:	77 17                	ja     f0109943 <strtol+0xd2>
			dig = *s - 'A' + 10;
f010992c:	0f be c2             	movsbl %dl,%eax
f010992f:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
f0109932:	39 f2                	cmp    %esi,%edx
f0109934:	7d 0d                	jge    f0109943 <strtol+0xd2>
			break;
		s++, val = (val * base) + dig;
f0109936:	83 c1 01             	add    $0x1,%ecx
f0109939:	89 f8                	mov    %edi,%eax
f010993b:	0f af c6             	imul   %esi,%eax
f010993e:	8d 3c 02             	lea    (%edx,%eax,1),%edi
f0109941:	eb bf                	jmp    f0109902 <strtol+0x91>
		// we don't properly detect overflow!
	}
f0109943:	89 f8                	mov    %edi,%eax

	if (endptr)
f0109945:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0109949:	74 05                	je     f0109950 <strtol+0xdf>
		*endptr = (char *) s;
f010994b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010994e:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
f0109950:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0109954:	74 04                	je     f010995a <strtol+0xe9>
f0109956:	89 c7                	mov    %eax,%edi
f0109958:	f7 df                	neg    %edi
}
f010995a:	89 f8                	mov    %edi,%eax
f010995c:	83 c4 04             	add    $0x4,%esp
f010995f:	5b                   	pop    %ebx
f0109960:	5e                   	pop    %esi
f0109961:	5f                   	pop    %edi
f0109962:	5d                   	pop    %ebp
f0109963:	c3                   	ret    

f0109964 <pci_e100_attach>:
	inb(0x84);
}
static unsigned CSR_ADDR;
int 
pci_e100_attach(struct pci_func *pcif)
{
f0109964:	55                   	push   %ebp
f0109965:	89 e5                	mov    %esp,%ebp
f0109967:	53                   	push   %ebx
f0109968:	83 ec 14             	sub    $0x14,%esp
f010996b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	pci_func_enable(pcif);
f010996e:	89 1c 24             	mov    %ebx,(%esp)
f0109971:	e8 7b 02 00 00       	call   f0109bf1 <pci_func_enable>
	cprintf("CSR Memory Mapped Base Address Register:%d bytes at 0x%x\n",pcif->reg_size[0],pcif->reg_base[0]);
f0109976:	8b 43 14             	mov    0x14(%ebx),%eax
f0109979:	89 44 24 08          	mov    %eax,0x8(%esp)
f010997d:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0109980:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109984:	c7 04 24 10 46 11 f0 	movl   $0xf0114610,(%esp)
f010998b:	e8 57 a0 ff ff       	call   f01039e7 <cprintf>
	cprintf("CSR I/O Mapped Base Address Register:%d bytes at 0x%x\n",pcif->reg_size[1],pcif->reg_base[1]);
f0109990:	8b 43 18             	mov    0x18(%ebx),%eax
f0109993:	89 44 24 08          	mov    %eax,0x8(%esp)
f0109997:	8b 43 30             	mov    0x30(%ebx),%eax
f010999a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010999e:	c7 04 24 4c 46 11 f0 	movl   $0xf011464c,(%esp)
f01099a5:	e8 3d a0 ff ff       	call   f01039e7 <cprintf>
	cprintf("Flash Memory Base Address Register:%d bytes at 0x%x\n",pcif->reg_size[2],pcif->reg_base[2]);
f01099aa:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01099ad:	89 44 24 08          	mov    %eax,0x8(%esp)
f01099b1:	8b 43 34             	mov    0x34(%ebx),%eax
f01099b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01099b8:	c7 04 24 84 46 11 f0 	movl   $0xf0114684,(%esp)
f01099bf:	e8 23 a0 ff ff       	call   f01039e7 <cprintf>
	CSR_ADDR=pcif->reg_base[1];
f01099c4:	8b 43 18             	mov    0x18(%ebx),%eax
f01099c7:	a3 e0 54 29 f0       	mov    %eax,0xf02954e0
	cprintf("port:0x%x,selective_reset=0x%x\n",CSR_ADDR+CSR_PORT,selective_reset);
f01099cc:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
f01099d3:	00 
f01099d4:	83 c0 08             	add    $0x8,%eax
f01099d7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01099db:	c7 04 24 bc 46 11 f0 	movl   $0xf01146bc,(%esp)
f01099e2:	e8 00 a0 ff ff       	call   f01039e7 <cprintf>
}

static __inline void
outl(int port, uint32_t data)
{
	__asm __volatile("outl %0,%w1" : : "a" (data), "d" (port));
f01099e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01099ec:	8b 15 e0 54 29 f0    	mov    0xf02954e0,%edx
f01099f2:	83 c2 08             	add    $0x8,%edx
f01099f5:	ef                   	out    %eax,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01099f6:	ba 84 00 00 00       	mov    $0x84,%edx
f01099fb:	ec                   	in     (%dx),%al
f01099fc:	ec                   	in     (%dx),%al
f01099fd:	ec                   	in     (%dx),%al
f01099fe:	ec                   	in     (%dx),%al
f01099ff:	ec                   	in     (%dx),%al
f0109a00:	ec                   	in     (%dx),%al
f0109a01:	ec                   	in     (%dx),%al
f0109a02:	ec                   	in     (%dx),%al
	outl(CSR_ADDR+CSR_PORT,software_reset);
	delay();
	panic("e100 initialization is not implemented\n");
f0109a03:	c7 44 24 08 dc 46 11 	movl   $0xf01146dc,0x8(%esp)
f0109a0a:	f0 
f0109a0b:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0109a12:	00 
f0109a13:	c7 04 24 04 47 11 f0 	movl   $0xf0114704,(%esp)
f0109a1a:	e8 67 66 ff ff       	call   f0100086 <_panic>
	...

f0109a20 <pci_attach_match>:
}

static int __attribute__((warn_unused_result))
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
f0109a20:	55                   	push   %ebp
f0109a21:	89 e5                	mov    %esp,%ebp
f0109a23:	57                   	push   %edi
f0109a24:	56                   	push   %esi
f0109a25:	53                   	push   %ebx
f0109a26:	83 ec 1c             	sub    $0x1c,%esp
f0109a29:	89 c7                	mov    %eax,%edi
f0109a2b:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0109a2e:	89 ce                	mov    %ecx,%esi
	uint32_t i;
	
	for (i = 0; list[i].attachfn; i++) {
f0109a30:	8b 41 08             	mov    0x8(%ecx),%eax
f0109a33:	85 c0                	test   %eax,%eax
f0109a35:	74 4d                	je     f0109a84 <pci_attach_match+0x64>
f0109a37:	8d 59 0c             	lea    0xc(%ecx),%ebx
		if (list[i].key1 == key1 && list[i].key2 == key2) {
f0109a3a:	39 3e                	cmp    %edi,(%esi)
f0109a3c:	75 3a                	jne    f0109a78 <pci_attach_match+0x58>
f0109a3e:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0109a41:	39 56 04             	cmp    %edx,0x4(%esi)
f0109a44:	75 32                	jne    f0109a78 <pci_attach_match+0x58>
			int r = list[i].attachfn(pcif);
f0109a46:	8b 55 08             	mov    0x8(%ebp),%edx
f0109a49:	89 14 24             	mov    %edx,(%esp)
f0109a4c:	ff d0                	call   *%eax
			if (r > 0)
f0109a4e:	85 c0                	test   %eax,%eax
f0109a50:	7f 37                	jg     f0109a89 <pci_attach_match+0x69>
				return r;
			if (r < 0)
f0109a52:	85 c0                	test   %eax,%eax
f0109a54:	79 22                	jns    f0109a78 <pci_attach_match+0x58>
				cprintf("pci_attach_match: attaching "
f0109a56:	89 44 24 10          	mov    %eax,0x10(%esp)
f0109a5a:	8b 46 08             	mov    0x8(%esi),%eax
f0109a5d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0109a61:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0109a64:	89 44 24 08          	mov    %eax,0x8(%esp)
f0109a68:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0109a6c:	c7 04 24 10 47 11 f0 	movl   $0xf0114710,(%esp)
f0109a73:	e8 6f 9f ff ff       	call   f01039e7 <cprintf>
f0109a78:	89 de                	mov    %ebx,%esi
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
	uint32_t i;
	
	for (i = 0; list[i].attachfn; i++) {
f0109a7a:	8b 43 08             	mov    0x8(%ebx),%eax
f0109a7d:	83 c3 0c             	add    $0xc,%ebx
f0109a80:	85 c0                	test   %eax,%eax
f0109a82:	75 b6                	jne    f0109a3a <pci_attach_match+0x1a>
f0109a84:	b8 00 00 00 00       	mov    $0x0,%eax
					"%x.%x (%p): e\n",
					key1, key2, list[i].attachfn, r);
		}
	}
	return 0;
}
f0109a89:	83 c4 1c             	add    $0x1c,%esp
f0109a8c:	5b                   	pop    %ebx
f0109a8d:	5e                   	pop    %esi
f0109a8e:	5f                   	pop    %edi
f0109a8f:	5d                   	pop    %ebp
f0109a90:	c3                   	ret    

f0109a91 <pci_conf1_set_addr>:
static void
pci_conf1_set_addr(uint32_t bus,
		   uint32_t dev,
		   uint32_t func,
		   uint32_t offset)
{
f0109a91:	55                   	push   %ebp
f0109a92:	89 e5                	mov    %esp,%ebp
f0109a94:	53                   	push   %ebx
f0109a95:	83 ec 14             	sub    $0x14,%esp
f0109a98:	89 cb                	mov    %ecx,%ebx
f0109a9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	assert(bus < 256);
f0109a9d:	3d ff 00 00 00       	cmp    $0xff,%eax
f0109aa2:	76 24                	jbe    f0109ac8 <pci_conf1_set_addr+0x37>
f0109aa4:	c7 44 24 0c b0 48 11 	movl   $0xf01148b0,0xc(%esp)
f0109aab:	f0 
f0109aac:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0109ab3:	f0 
f0109ab4:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
f0109abb:	00 
f0109abc:	c7 04 24 ba 48 11 f0 	movl   $0xf01148ba,(%esp)
f0109ac3:	e8 be 65 ff ff       	call   f0100086 <_panic>
	assert(dev < 32);
f0109ac8:	83 fa 1f             	cmp    $0x1f,%edx
f0109acb:	76 24                	jbe    f0109af1 <pci_conf1_set_addr+0x60>
f0109acd:	c7 44 24 0c c5 48 11 	movl   $0xf01148c5,0xc(%esp)
f0109ad4:	f0 
f0109ad5:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0109adc:	f0 
f0109add:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
f0109ae4:	00 
f0109ae5:	c7 04 24 ba 48 11 f0 	movl   $0xf01148ba,(%esp)
f0109aec:	e8 95 65 ff ff       	call   f0100086 <_panic>
	assert(func < 8);
f0109af1:	83 fb 07             	cmp    $0x7,%ebx
f0109af4:	76 24                	jbe    f0109b1a <pci_conf1_set_addr+0x89>
f0109af6:	c7 44 24 0c ce 48 11 	movl   $0xf01148ce,0xc(%esp)
f0109afd:	f0 
f0109afe:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0109b05:	f0 
f0109b06:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
f0109b0d:	00 
f0109b0e:	c7 04 24 ba 48 11 f0 	movl   $0xf01148ba,(%esp)
f0109b15:	e8 6c 65 ff ff       	call   f0100086 <_panic>
	assert(offset < 256);
f0109b1a:	81 f9 ff 00 00 00    	cmp    $0xff,%ecx
f0109b20:	76 24                	jbe    f0109b46 <pci_conf1_set_addr+0xb5>
f0109b22:	c7 44 24 0c d7 48 11 	movl   $0xf01148d7,0xc(%esp)
f0109b29:	f0 
f0109b2a:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0109b31:	f0 
f0109b32:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
f0109b39:	00 
f0109b3a:	c7 04 24 ba 48 11 f0 	movl   $0xf01148ba,(%esp)
f0109b41:	e8 40 65 ff ff       	call   f0100086 <_panic>
	assert((offset & 0x3) == 0);
f0109b46:	f6 c1 03             	test   $0x3,%cl
f0109b49:	74 24                	je     f0109b6f <pci_conf1_set_addr+0xde>
f0109b4b:	c7 44 24 0c e4 48 11 	movl   $0xf01148e4,0xc(%esp)
f0109b52:	f0 
f0109b53:	c7 44 24 08 ac b6 10 	movl   $0xf010b6ac,0x8(%esp)
f0109b5a:	f0 
f0109b5b:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
f0109b62:	00 
f0109b63:	c7 04 24 ba 48 11 f0 	movl   $0xf01148ba,(%esp)
f0109b6a:	e8 17 65 ff ff       	call   f0100086 <_panic>
}

static __inline void
outl(int port, uint32_t data)
{
	__asm __volatile("outl %0,%w1" : : "a" (data), "d" (port));
f0109b6f:	c1 e0 10             	shl    $0x10,%eax
f0109b72:	0d 00 00 00 80       	or     $0x80000000,%eax
f0109b77:	c1 e2 0b             	shl    $0xb,%edx
f0109b7a:	09 d0                	or     %edx,%eax
f0109b7c:	09 c8                	or     %ecx,%eax
f0109b7e:	89 da                	mov    %ebx,%edx
f0109b80:	c1 e2 08             	shl    $0x8,%edx
f0109b83:	09 d0                	or     %edx,%eax
f0109b85:	8b 15 74 49 11 f0    	mov    0xf0114974,%edx
f0109b8b:	ef                   	out    %eax,(%dx)
	
	uint32_t v = (1 << 31) |		// config-space
		(bus << 16) | (dev << 11) | (func << 8) | (offset);
	outl(pci_conf1_addr_ioport, v);
}
f0109b8c:	83 c4 14             	add    $0x14,%esp
f0109b8f:	5b                   	pop    %ebx
f0109b90:	5d                   	pop    %ebp
f0109b91:	c3                   	ret    

f0109b92 <pci_conf_write>:
	return inl(pci_conf1_data_ioport);
}

static void
pci_conf_write(struct pci_func *f, uint32_t off, uint32_t v)
{
f0109b92:	55                   	push   %ebp
f0109b93:	89 e5                	mov    %esp,%ebp
f0109b95:	83 ec 18             	sub    $0x18,%esp
f0109b98:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0109b9b:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0109b9e:	89 d3                	mov    %edx,%ebx
f0109ba0:	89 ce                	mov    %ecx,%esi
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f0109ba2:	8b 48 08             	mov    0x8(%eax),%ecx
f0109ba5:	8b 50 04             	mov    0x4(%eax),%edx
f0109ba8:	8b 00                	mov    (%eax),%eax
f0109baa:	8b 40 04             	mov    0x4(%eax),%eax
f0109bad:	89 1c 24             	mov    %ebx,(%esp)
f0109bb0:	e8 dc fe ff ff       	call   f0109a91 <pci_conf1_set_addr>
f0109bb5:	8b 15 70 49 11 f0    	mov    0xf0114970,%edx
f0109bbb:	89 f0                	mov    %esi,%eax
f0109bbd:	ef                   	out    %eax,(%dx)
	outl(pci_conf1_data_ioport, v);
}
f0109bbe:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0109bc1:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0109bc4:	89 ec                	mov    %ebp,%esp
f0109bc6:	5d                   	pop    %ebp
f0109bc7:	c3                   	ret    

f0109bc8 <pci_conf_read>:
	outl(pci_conf1_addr_ioport, v);
}

static uint32_t
pci_conf_read(struct pci_func *f, uint32_t off)
{
f0109bc8:	55                   	push   %ebp
f0109bc9:	89 e5                	mov    %esp,%ebp
f0109bcb:	53                   	push   %ebx
f0109bcc:	83 ec 04             	sub    $0x4,%esp
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f0109bcf:	8b 48 08             	mov    0x8(%eax),%ecx
f0109bd2:	8b 58 04             	mov    0x4(%eax),%ebx
f0109bd5:	8b 00                	mov    (%eax),%eax
f0109bd7:	8b 40 04             	mov    0x4(%eax),%eax
f0109bda:	89 14 24             	mov    %edx,(%esp)
f0109bdd:	89 da                	mov    %ebx,%edx
f0109bdf:	e8 ad fe ff ff       	call   f0109a91 <pci_conf1_set_addr>

static __inline uint32_t
inl(int port)
{
	uint32_t data;
	__asm __volatile("inl %w1,%0" : "=a" (data) : "d" (port));
f0109be4:	8b 15 70 49 11 f0    	mov    0xf0114970,%edx
f0109bea:	ed                   	in     (%dx),%eax
	return inl(pci_conf1_data_ioport);
}
f0109beb:	83 c4 04             	add    $0x4,%esp
f0109bee:	5b                   	pop    %ebx
f0109bef:	5d                   	pop    %ebp
f0109bf0:	c3                   	ret    

f0109bf1 <pci_func_enable>:
//查询PCI设备需要的PCI I/O和内存空间大小
//存储或I/O空间大小读取方法：写全1即0xffffffff，而后读取寄存器值，再取补。
//如读到0xffff0000，表示空间是64KB（0x10000H）
void
pci_func_enable(struct pci_func *f)
{
f0109bf1:	55                   	push   %ebp
f0109bf2:	89 e5                	mov    %esp,%ebp
f0109bf4:	57                   	push   %edi
f0109bf5:	56                   	push   %esi
f0109bf6:	53                   	push   %ebx
f0109bf7:	83 ec 3c             	sub    $0x3c,%esp
f0109bfa:	8b 75 08             	mov    0x8(%ebp),%esi
	//初始化命令寄存器PCI_COMMAND_STATUS_REG
	//PCI_COMMAND_IO_ENABLE允许设备响应I/O空间的存取
	//PCI_COMMAND_MEM_ENABLE允许设备响应内存空间存取
	//PCI_COMMAND_MASTER_ENABLE允许设备作为bus master,可以产生PCI存取
	pci_conf_write(f, PCI_COMMAND_STATUS_REG,
f0109bfd:	b9 07 00 00 00       	mov    $0x7,%ecx
f0109c02:	ba 04 00 00 00       	mov    $0x4,%edx
f0109c07:	89 f0                	mov    %esi,%eax
f0109c09:	e8 84 ff ff ff       	call   f0109b92 <pci_conf_write>
			if (PCI_MAPREG_MEM_TYPE(rv) == PCI_MAPREG_MEM_TYPE_64BIT)
				bar_width = 8;
			
			size = PCI_MAPREG_MEM_SIZE(rv);
			base = PCI_MAPREG_MEM_ADDR(oldv);
			if (pci_show_addrs)
f0109c0e:	bb 10 00 00 00       	mov    $0x10,%ebx
	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);
f0109c13:	89 da                	mov    %ebx,%edx
f0109c15:	89 f0                	mov    %esi,%eax
f0109c17:	e8 ac ff ff ff       	call   f0109bc8 <pci_conf_read>
f0109c1c:	89 45 e8             	mov    %eax,-0x18(%ebp)
		
		bar_width = 4;
		pci_conf_write(f, bar, 0xffffffff);
f0109c1f:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
f0109c24:	89 da                	mov    %ebx,%edx
f0109c26:	89 f0                	mov    %esi,%eax
f0109c28:	e8 65 ff ff ff       	call   f0109b92 <pci_conf_write>
		uint32_t rv = pci_conf_read(f, bar);
f0109c2d:	89 da                	mov    %ebx,%edx
f0109c2f:	89 f0                	mov    %esi,%eax
f0109c31:	e8 92 ff ff ff       	call   f0109bc8 <pci_conf_read>
f0109c36:	89 c2                	mov    %eax,%edx
		
		if (rv == 0)
f0109c38:	c7 45 e4 04 00 00 00 	movl   $0x4,-0x1c(%ebp)
f0109c3f:	85 c0                	test   %eax,%eax
f0109c41:	0f 84 14 01 00 00    	je     f0109d5b <pci_func_enable+0x16a>
			continue;
		
		int regnum = PCI_MAPREG_NUM(bar);
f0109c47:	8d 43 f0             	lea    -0x10(%ebx),%eax
f0109c4a:	c1 e8 02             	shr    $0x2,%eax
f0109c4d:	89 45 ec             	mov    %eax,-0x14(%ebp)
		uint32_t base, size;
		//bit[0]=0表示存储空间
		//bit[0]=1表示I/O空间
		if (PCI_MAPREG_TYPE(rv) == PCI_MAPREG_TYPE_MEM) {
f0109c50:	f6 c2 01             	test   $0x1,%dl
f0109c53:	75 52                	jne    f0109ca7 <pci_func_enable+0xb6>
			if (PCI_MAPREG_MEM_TYPE(rv) == PCI_MAPREG_MEM_TYPE_64BIT)
f0109c55:	89 d0                	mov    %edx,%eax
f0109c57:	83 e0 06             	and    $0x6,%eax
f0109c5a:	83 f8 04             	cmp    $0x4,%eax
f0109c5d:	0f 94 c0             	sete   %al
f0109c60:	0f b6 c0             	movzbl %al,%eax
f0109c63:	8d 04 85 04 00 00 00 	lea    0x4(,%eax,4),%eax
f0109c6a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				bar_width = 8;
			
			size = PCI_MAPREG_MEM_SIZE(rv);
f0109c6d:	83 e2 f0             	and    $0xfffffff0,%edx
f0109c70:	89 d0                	mov    %edx,%eax
f0109c72:	f7 d8                	neg    %eax
f0109c74:	89 d7                	mov    %edx,%edi
f0109c76:	21 c7                	and    %eax,%edi
			base = PCI_MAPREG_MEM_ADDR(oldv);
f0109c78:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0109c7b:	83 e2 f0             	and    $0xfffffff0,%edx
f0109c7e:	89 55 f0             	mov    %edx,-0x10(%ebp)
			if (pci_show_addrs)
f0109c81:	83 3d 94 49 11 f0 00 	cmpl   $0x0,0xf0114994
f0109c88:	74 66                	je     f0109cf0 <pci_func_enable+0xff>
				cprintf("  mem region %d: %d bytes at 0x%x\n",
f0109c8a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0109c8e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0109c92:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0109c95:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109c99:	c7 04 24 3c 47 11 f0 	movl   $0xf011473c,(%esp)
f0109ca0:	e8 42 9d ff ff       	call   f01039e7 <cprintf>
f0109ca5:	eb 49                	jmp    f0109cf0 <pci_func_enable+0xff>
					regnum, size, base);
		} else {
			size = PCI_MAPREG_IO_SIZE(rv);
f0109ca7:	83 e2 fc             	and    $0xfffffffc,%edx
f0109caa:	89 d0                	mov    %edx,%eax
f0109cac:	f7 d8                	neg    %eax
f0109cae:	89 d7                	mov    %edx,%edi
f0109cb0:	21 c7                	and    %eax,%edi
			base = PCI_MAPREG_IO_ADDR(oldv);
f0109cb2:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0109cb5:	83 e2 fc             	and    $0xfffffffc,%edx
f0109cb8:	89 55 f0             	mov    %edx,-0x10(%ebp)
			if (pci_show_addrs)
f0109cbb:	c7 45 e4 04 00 00 00 	movl   $0x4,-0x1c(%ebp)
f0109cc2:	83 3d 94 49 11 f0 00 	cmpl   $0x0,0xf0114994
f0109cc9:	74 25                	je     f0109cf0 <pci_func_enable+0xff>
				cprintf("  io region %d: %d bytes at 0x%x\n",
f0109ccb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0109cce:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0109cd2:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0109cd6:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0109cd9:	89 54 24 04          	mov    %edx,0x4(%esp)
f0109cdd:	c7 04 24 60 47 11 f0 	movl   $0xf0114760,(%esp)
f0109ce4:	e8 fe 9c ff ff       	call   f01039e7 <cprintf>
f0109ce9:	c7 45 e4 04 00 00 00 	movl   $0x4,-0x1c(%ebp)
					regnum, size, base);
		}
		
		pci_conf_write(f, bar, oldv);
f0109cf0:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0109cf3:	89 da                	mov    %ebx,%edx
f0109cf5:	89 f0                	mov    %esi,%eax
f0109cf7:	e8 96 fe ff ff       	call   f0109b92 <pci_conf_write>
		f->reg_base[regnum] = base;
f0109cfc:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0109cff:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0109d02:	89 54 86 14          	mov    %edx,0x14(%esi,%eax,4)
		f->reg_size[regnum] = size;
f0109d06:	89 7c 86 2c          	mov    %edi,0x2c(%esi,%eax,4)
		
		if (size && !base)
f0109d0a:	85 ff                	test   %edi,%edi
f0109d0c:	74 4d                	je     f0109d5b <pci_func_enable+0x16a>
f0109d0e:	85 d2                	test   %edx,%edx
f0109d10:	75 49                	jne    f0109d5b <pci_func_enable+0x16a>
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
f0109d12:	8b 56 0c             	mov    0xc(%esi),%edx
f0109d15:	89 7c 24 20          	mov    %edi,0x20(%esp)
f0109d19:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
f0109d20:	00 
f0109d21:	89 44 24 18          	mov    %eax,0x18(%esp)
f0109d25:	89 d0                	mov    %edx,%eax
f0109d27:	c1 e8 10             	shr    $0x10,%eax
f0109d2a:	89 44 24 14          	mov    %eax,0x14(%esp)
f0109d2e:	81 e2 ff ff 00 00    	and    $0xffff,%edx
f0109d34:	89 54 24 10          	mov    %edx,0x10(%esp)
f0109d38:	8b 46 08             	mov    0x8(%esi),%eax
f0109d3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0109d3f:	8b 46 04             	mov    0x4(%esi),%eax
f0109d42:	89 44 24 08          	mov    %eax,0x8(%esp)
f0109d46:	8b 06                	mov    (%esi),%eax
f0109d48:	8b 40 04             	mov    0x4(%eax),%eax
f0109d4b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109d4f:	c7 04 24 84 47 11 f0 	movl   $0xf0114784,(%esp)
f0109d56:	e8 8c 9c ff ff       	call   f01039e7 <cprintf>
		       PCI_COMMAND_MASTER_ENABLE);
	
	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
f0109d5b:	03 5d e4             	add    -0x1c(%ebp),%ebx
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);
	
	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f0109d5e:	83 fb 27             	cmp    $0x27,%ebx
f0109d61:	0f 86 ac fe ff ff    	jbe    f0109c13 <pci_func_enable+0x22>
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
f0109d67:	8b 46 0c             	mov    0xc(%esi),%eax
f0109d6a:	89 c2                	mov    %eax,%edx
f0109d6c:	c1 ea 10             	shr    $0x10,%edx
f0109d6f:	89 54 24 14          	mov    %edx,0x14(%esp)
f0109d73:	25 ff ff 00 00       	and    $0xffff,%eax
f0109d78:	89 44 24 10          	mov    %eax,0x10(%esp)
f0109d7c:	8b 46 08             	mov    0x8(%esi),%eax
f0109d7f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0109d83:	8b 46 04             	mov    0x4(%esi),%eax
f0109d86:	89 44 24 08          	mov    %eax,0x8(%esp)
f0109d8a:	8b 06                	mov    (%esi),%eax
f0109d8c:	8b 40 04             	mov    0x4(%eax),%eax
f0109d8f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109d93:	c7 04 24 e0 47 11 f0 	movl   $0xf01147e0,(%esp)
f0109d9a:	e8 48 9c ff ff       	call   f01039e7 <cprintf>
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
}
f0109d9f:	83 c4 3c             	add    $0x3c,%esp
f0109da2:	5b                   	pop    %ebx
f0109da3:	5e                   	pop    %esi
f0109da4:	5f                   	pop    %edi
f0109da5:	5d                   	pop    %ebp
f0109da6:	c3                   	ret    

f0109da7 <pci_scan_bus>:
		f->irq_line);
}

static int 
pci_scan_bus(struct pci_bus *bus)
{
f0109da7:	55                   	push   %ebp
f0109da8:	89 e5                	mov    %esp,%ebp
f0109daa:	57                   	push   %edi
f0109dab:	56                   	push   %esi
f0109dac:	53                   	push   %ebx
f0109dad:	81 ec 1c 01 00 00    	sub    $0x11c,%esp
f0109db3:	89 c3                	mov    %eax,%ebx
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
f0109db5:	c7 44 24 08 48 00 00 	movl   $0x48,0x8(%esp)
f0109dbc:	00 
f0109dbd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0109dc4:	00 
f0109dc5:	8d 45 ac             	lea    -0x54(%ebp),%eax
f0109dc8:	89 04 24             	mov    %eax,(%esp)
f0109dcb:	e8 0e f9 ff ff       	call   f01096de <memset>
	df.bus = bus;
f0109dd0:	89 5d ac             	mov    %ebx,-0x54(%ebp)
	
	for (df.dev = 0; df.dev < 32; df.dev++) {
f0109dd3:	c7 45 b0 00 00 00 00 	movl   $0x0,-0x50(%ebp)
};

static void 
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
f0109dda:	c7 85 10 ff ff ff 00 	movl   $0x0,-0xf0(%ebp)
f0109de1:	00 00 00 
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;
	
	for (df.dev = 0; df.dev < 32; df.dev++) {
		uint32_t bhlc = pci_conf_read(&df, PCI_BHLC_REG);
f0109de4:	ba 0c 00 00 00       	mov    $0xc,%edx
f0109de9:	8d 45 ac             	lea    -0x54(%ebp),%eax
f0109dec:	e8 d7 fd ff ff       	call   f0109bc8 <pci_conf_read>
f0109df1:	89 c3                	mov    %eax,%ebx
		//Header Type:1 Byte bit[6:0]表示PCI配置空间头部的布局类型，
		//值00h表示一个一般PCI设备的配置空间头部,参考类型0的配置空间
		//值01h表示一个PCI-to-PCI桥的配置空间头部,参考类型1的配置空间
		//值02h表示CardBus桥的配置空间头部
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
f0109df3:	c1 e8 10             	shr    $0x10,%eax
f0109df6:	83 e0 7f             	and    $0x7f,%eax
f0109df9:	83 f8 01             	cmp    $0x1,%eax
f0109dfc:	0f 87 8f 01 00 00    	ja     f0109f91 <pci_scan_bus+0x1ea>
			continue;
		
		totaldev++;
		
		struct pci_func f = df;
f0109e02:	c7 44 24 08 48 00 00 	movl   $0x48,0x8(%esp)
f0109e09:	00 
f0109e0a:	8d 45 ac             	lea    -0x54(%ebp),%eax
f0109e0d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109e11:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
f0109e17:	89 04 24             	mov    %eax,(%esp)
f0109e1a:	e8 99 f9 ff ff       	call   f01097b8 <memcpy>
		//Header Type:bit[7]＝1表示这是一个多功能设备,
		//bit[7]=0表示这是一个单功能设备
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0109e1f:	c7 85 6c ff ff ff 00 	movl   $0x0,-0x94(%ebp)
f0109e26:	00 00 00 
f0109e29:	81 e3 00 00 80 00    	and    $0x800000,%ebx
f0109e2f:	89 9d 0c ff ff ff    	mov    %ebx,-0xf4(%ebp)
		     f.func++) {
			struct pci_func af = f;
f0109e35:	8d bd 1c ff ff ff    	lea    -0xe4(%ebp),%edi
f0109e3b:	e9 2f 01 00 00       	jmp    f0109f6f <pci_scan_bus+0x1c8>
f0109e40:	c7 44 24 08 48 00 00 	movl   $0x48,0x8(%esp)
f0109e47:	00 
f0109e48:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
f0109e4e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109e52:	89 3c 24             	mov    %edi,(%esp)
f0109e55:	e8 5e f9 ff ff       	call   f01097b8 <memcpy>
			
			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
f0109e5a:	ba 00 00 00 00       	mov    $0x0,%edx
f0109e5f:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
f0109e65:	e8 5e fd ff ff       	call   f0109bc8 <pci_conf_read>
f0109e6a:	89 85 28 ff ff ff    	mov    %eax,-0xd8(%ebp)
			//判断设备是否存在，ffffh是非法ID
			if (PCI_VENDOR(af.dev_id) == 0xffff)
f0109e70:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0109e74:	0f 84 ee 00 00 00    	je     f0109f68 <pci_scan_bus+0x1c1>
				continue;
			//获取中断线编号
			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f0109e7a:	ba 3c 00 00 00       	mov    $0x3c,%edx
f0109e7f:	89 f8                	mov    %edi,%eax
f0109e81:	e8 42 fd ff ff       	call   f0109bc8 <pci_conf_read>
			af.irq_line = PCI_INTERRUPT_LINE(intr);
f0109e86:	88 85 60 ff ff ff    	mov    %al,-0xa0(%ebp)
			//获取设备class包含3部分：
			//bit[7:0]编程接口;bit[15:8]子类别编号
			//bit[23:16]基类别编号
			af.dev_class = pci_conf_read(&af, PCI_CLASS_REG);
f0109e8c:	ba 08 00 00 00       	mov    $0x8,%edx
f0109e91:	89 f8                	mov    %edi,%eax
f0109e93:	e8 30 fd ff ff       	call   f0109bc8 <pci_conf_read>
f0109e98:	89 c1                	mov    %eax,%ecx
f0109e9a:	89 85 2c ff ff ff    	mov    %eax,-0xd4(%ebp)
			if (pci_show_devs)
f0109ea0:	83 3d 6c 49 11 f0 00 	cmpl   $0x0,0xf011496c
f0109ea7:	74 7d                	je     f0109f26 <pci_scan_bus+0x17f>

static void 
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
f0109ea9:	89 c3                	mov    %eax,%ebx
f0109eab:	c1 eb 18             	shr    $0x18,%ebx
f0109eae:	be f8 48 11 f0       	mov    $0xf01148f8,%esi
f0109eb3:	83 fb 06             	cmp    $0x6,%ebx
f0109eb6:	77 07                	ja     f0109ebf <pci_scan_bus+0x118>
		class = pci_class[PCI_CLASS(f->dev_class)];
f0109eb8:	8b 34 9d 78 49 11 f0 	mov    -0xfeeb688(,%ebx,4),%esi

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
f0109ebf:	8b 95 28 ff ff ff    	mov    -0xd8(%ebp),%edx
f0109ec5:	0f b6 85 60 ff ff ff 	movzbl -0xa0(%ebp),%eax
f0109ecc:	89 44 24 24          	mov    %eax,0x24(%esp)
f0109ed0:	89 74 24 20          	mov    %esi,0x20(%esp)
f0109ed4:	89 c8                	mov    %ecx,%eax
f0109ed6:	c1 e8 10             	shr    $0x10,%eax
f0109ed9:	25 ff 00 00 00       	and    $0xff,%eax
f0109ede:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0109ee2:	89 5c 24 18          	mov    %ebx,0x18(%esp)
f0109ee6:	89 d0                	mov    %edx,%eax
f0109ee8:	c1 e8 10             	shr    $0x10,%eax
f0109eeb:	89 44 24 14          	mov    %eax,0x14(%esp)
f0109eef:	81 e2 ff ff 00 00    	and    $0xffff,%edx
f0109ef5:	89 54 24 10          	mov    %edx,0x10(%esp)
f0109ef9:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
f0109eff:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0109f03:	8b 85 20 ff ff ff    	mov    -0xe0(%ebp),%eax
f0109f09:	89 44 24 08          	mov    %eax,0x8(%esp)
f0109f0d:	8b 85 1c ff ff ff    	mov    -0xe4(%ebp),%eax
f0109f13:	8b 40 04             	mov    0x4(%eax),%eax
f0109f16:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109f1a:	c7 04 24 10 48 11 f0 	movl   $0xf0114810,(%esp)
f0109f21:	e8 c1 9a ff ff       	call   f01039e7 <cprintf>
static int
pci_attach(struct pci_func *f)
{
	//如果这个设备是个PCI-PCI桥接器则建立一个pci_bus的结构并将其
	//连接到pci_bus树中
	return
f0109f26:	8b 85 2c ff ff ff    	mov    -0xd4(%ebp),%eax
f0109f2c:	89 c2                	mov    %eax,%edx
f0109f2e:	c1 ea 10             	shr    $0x10,%edx
f0109f31:	81 e2 ff 00 00 00    	and    $0xff,%edx
f0109f37:	c1 e8 18             	shr    $0x18,%eax
f0109f3a:	89 3c 24             	mov    %edi,(%esp)
f0109f3d:	b9 64 17 13 f0       	mov    $0xf0131764,%ecx
f0109f42:	e8 d9 fa ff ff       	call   f0109a20 <pci_attach_match>
f0109f47:	85 c0                	test   %eax,%eax
f0109f49:	75 1d                	jne    f0109f68 <pci_scan_bus+0x1c1>
f0109f4b:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
f0109f51:	89 c2                	mov    %eax,%edx
f0109f53:	c1 ea 10             	shr    $0x10,%edx
f0109f56:	25 ff ff 00 00       	and    $0xffff,%eax
f0109f5b:	89 3c 24             	mov    %edi,(%esp)
f0109f5e:	b9 7c 17 13 f0       	mov    $0xf013177c,%ecx
f0109f63:	e8 b8 fa ff ff       	call   f0109a20 <pci_attach_match>
		
		struct pci_func f = df;
		//Header Type:bit[7]＝1表示这是一个多功能设备,
		//bit[7]=0表示这是一个单功能设备
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
		     f.func++) {
f0109f68:	83 85 6c ff ff ff 01 	addl   $0x1,-0x94(%ebp)
		totaldev++;
		
		struct pci_func f = df;
		//Header Type:bit[7]＝1表示这是一个多功能设备,
		//bit[7]=0表示这是一个单功能设备
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0109f6f:	83 bd 0c ff ff ff 01 	cmpl   $0x1,-0xf4(%ebp)
f0109f76:	19 c0                	sbb    %eax,%eax
f0109f78:	83 e0 f9             	and    $0xfffffff9,%eax
f0109f7b:	83 c0 08             	add    $0x8,%eax
f0109f7e:	3b 85 6c ff ff ff    	cmp    -0x94(%ebp),%eax
f0109f84:	0f 87 b6 fe ff ff    	ja     f0109e40 <pci_scan_bus+0x99>
		//值01h表示一个PCI-to-PCI桥的配置空间头部,参考类型1的配置空间
		//值02h表示CardBus桥的配置空间头部
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
			continue;
		
		totaldev++;
f0109f8a:	83 85 10 ff ff ff 01 	addl   $0x1,-0xf0(%ebp)
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;
	
	for (df.dev = 0; df.dev < 32; df.dev++) {
f0109f91:	8b 45 b0             	mov    -0x50(%ebp),%eax
f0109f94:	83 c0 01             	add    $0x1,%eax
f0109f97:	83 f8 1f             	cmp    $0x1f,%eax
f0109f9a:	77 08                	ja     f0109fa4 <pci_scan_bus+0x1fd>
f0109f9c:	89 45 b0             	mov    %eax,-0x50(%ebp)
f0109f9f:	e9 40 fe ff ff       	jmp    f0109de4 <pci_scan_bus+0x3d>
			pci_attach(&af);
		}
	}
	
	return totaldev;
}
f0109fa4:	8b 85 10 ff ff ff    	mov    -0xf0(%ebp),%eax
f0109faa:	81 c4 1c 01 00 00    	add    $0x11c,%esp
f0109fb0:	5b                   	pop    %ebx
f0109fb1:	5e                   	pop    %esi
f0109fb2:	5f                   	pop    %edi
f0109fb3:	5d                   	pop    %ebp
f0109fb4:	c3                   	ret    

f0109fb5 <pci_init>:
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
}

int
pci_init(void)
{
f0109fb5:	55                   	push   %ebp
f0109fb6:	89 e5                	mov    %esp,%ebp
f0109fb8:	83 ec 18             	sub    $0x18,%esp
	static struct pci_bus root_bus;
	memset(&root_bus, 0, sizeof(root_bus));
f0109fbb:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
f0109fc2:	00 
f0109fc3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0109fca:	00 
f0109fcb:	c7 04 24 e4 54 29 f0 	movl   $0xf02954e4,(%esp)
f0109fd2:	e8 07 f7 ff ff       	call   f01096de <memset>
	//PCI初始化代码扫描PCI总线0,建立总线树表示整个系统总线结构拓扑
	//系统初始化程序必须扫描基本PCI总线(总线0)和PCI-to-PCI桥.
	return pci_scan_bus(&root_bus);
f0109fd7:	b8 e4 54 29 f0       	mov    $0xf02954e4,%eax
f0109fdc:	e8 c6 fd ff ff       	call   f0109da7 <pci_scan_bus>
}
f0109fe1:	c9                   	leave  
f0109fe2:	c3                   	ret    

f0109fe3 <pci_bridge_attach>:
	return totaldev;
}

static int
pci_bridge_attach(struct pci_func *pcif)
{
f0109fe3:	55                   	push   %ebp
f0109fe4:	89 e5                	mov    %esp,%ebp
f0109fe6:	83 ec 38             	sub    $0x38,%esp
f0109fe9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0109fec:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0109fef:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0109ff2:	8b 75 08             	mov    0x8(%ebp),%esi
	uint32_t ioreg  = pci_conf_read(pcif, PCI_BRIDGE_STATIO_REG);
f0109ff5:	ba 1c 00 00 00       	mov    $0x1c,%edx
f0109ffa:	89 f0                	mov    %esi,%eax
f0109ffc:	e8 c7 fb ff ff       	call   f0109bc8 <pci_conf_read>
f010a001:	89 c3                	mov    %eax,%ebx
	uint32_t busreg = pci_conf_read(pcif, PCI_BRIDGE_BUS_REG);
f010a003:	ba 18 00 00 00       	mov    $0x18,%edx
f010a008:	89 f0                	mov    %esi,%eax
f010a00a:	e8 b9 fb ff ff       	call   f0109bc8 <pci_conf_read>
f010a00f:	89 c7                	mov    %eax,%edi
	//根据IO Base Register判断
	//0h:16-bit IO address decode
	//1h:32-bit IO address decode
	if (PCI_BRIDGE_IO_32BITS(ioreg)) {
f010a011:	89 d8                	mov    %ebx,%eax
f010a013:	83 e0 0f             	and    $0xf,%eax
f010a016:	83 f8 01             	cmp    $0x1,%eax
f010a019:	75 2a                	jne    f010a045 <pci_bridge_attach+0x62>
		cprintf("PCI: %02x:%02x.%d: 32-bit bridge IO not supported.\n",
f010a01b:	8b 46 08             	mov    0x8(%esi),%eax
f010a01e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010a022:	8b 46 04             	mov    0x4(%esi),%eax
f010a025:	89 44 24 08          	mov    %eax,0x8(%esp)
f010a029:	8b 06                	mov    (%esi),%eax
f010a02b:	8b 40 04             	mov    0x4(%eax),%eax
f010a02e:	89 44 24 04          	mov    %eax,0x4(%esp)
f010a032:	c7 04 24 4c 48 11 f0 	movl   $0xf011484c,(%esp)
f010a039:	e8 a9 99 ff ff       	call   f01039e7 <cprintf>
f010a03e:	b8 00 00 00 00       	mov    $0x0,%eax
f010a043:	eb 6f                	jmp    f010a0b4 <pci_bridge_attach+0xd1>
			pcif->bus->busno, pcif->dev, pcif->func);
		return 0;
	}
	
	struct pci_bus nbus;
	memset(&nbus, 0, sizeof(nbus));
f010a045:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
f010a04c:	00 
f010a04d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010a054:	00 
f010a055:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010a058:	89 04 24             	mov    %eax,(%esp)
f010a05b:	e8 7e f6 ff ff       	call   f01096de <memset>
	nbus.parent_bridge = pcif;
f010a060:	89 75 ec             	mov    %esi,-0x14(%ebp)
	//获取桥下游的PCI总线号,次级总线号(busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff
	//最大次级总线号：(busreg >> PCI_BRIDGE_BUS_SUBORDINATE_SHIFT) & 0xff
	nbus.busno = (busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff;
f010a063:	89 f8                	mov    %edi,%eax
f010a065:	0f b6 d4             	movzbl %ah,%edx
f010a068:	89 55 f0             	mov    %edx,-0x10(%ebp)
	
	if (pci_show_devs)
f010a06b:	83 3d 6c 49 11 f0 00 	cmpl   $0x0,0xf011496c
f010a072:	74 33                	je     f010a0a7 <pci_bridge_attach+0xc4>
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
f010a074:	c1 e8 10             	shr    $0x10,%eax
f010a077:	25 ff 00 00 00       	and    $0xff,%eax
f010a07c:	89 44 24 14          	mov    %eax,0x14(%esp)
f010a080:	89 54 24 10          	mov    %edx,0x10(%esp)
f010a084:	8b 46 08             	mov    0x8(%esi),%eax
f010a087:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010a08b:	8b 46 04             	mov    0x4(%esi),%eax
f010a08e:	89 44 24 08          	mov    %eax,0x8(%esp)
f010a092:	8b 06                	mov    (%esi),%eax
f010a094:	8b 40 04             	mov    0x4(%eax),%eax
f010a097:	89 44 24 04          	mov    %eax,0x4(%esp)
f010a09b:	c7 04 24 80 48 11 f0 	movl   $0xf0114880,(%esp)
f010a0a2:	e8 40 99 ff ff       	call   f01039e7 <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func,
			nbus.busno,
			(busreg >> PCI_BRIDGE_BUS_SUBORDINATE_SHIFT) & 0xff);
	//扫描次级总线
	pci_scan_bus(&nbus);
f010a0a7:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010a0aa:	e8 f8 fc ff ff       	call   f0109da7 <pci_scan_bus>
f010a0af:	b8 01 00 00 00       	mov    $0x1,%eax
	return 1;
}
f010a0b4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010a0b7:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010a0ba:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010a0bd:	89 ec                	mov    %ebp,%esp
f010a0bf:	5d                   	pop    %ebp
f010a0c0:	c3                   	ret    
f010a0c1:	00 00                	add    %al,(%eax)
	...

f010a0c4 <time_init>:

static unsigned int ticks;

void
time_init(void) 
{
f010a0c4:	55                   	push   %ebp
f010a0c5:	89 e5                	mov    %esp,%ebp
	ticks = 0;
f010a0c7:	c7 05 ec 54 29 f0 00 	movl   $0x0,0xf02954ec
f010a0ce:	00 00 00 
}
f010a0d1:	5d                   	pop    %ebp
f010a0d2:	c3                   	ret    

f010a0d3 <time_msec>:
		panic("time_tick: time overflowed");
}

unsigned int
time_msec(void) 
{
f010a0d3:	55                   	push   %ebp
f010a0d4:	89 e5                	mov    %esp,%ebp
f010a0d6:	a1 ec 54 29 f0       	mov    0xf02954ec,%eax
f010a0db:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010a0de:	01 c0                	add    %eax,%eax
	return ticks * 10;
}
f010a0e0:	5d                   	pop    %ebp
f010a0e1:	c3                   	ret    

f010a0e2 <time_tick>:

// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void) 
{
f010a0e2:	55                   	push   %ebp
f010a0e3:	89 e5                	mov    %esp,%ebp
f010a0e5:	83 ec 18             	sub    $0x18,%esp
	ticks++;
f010a0e8:	8b 15 ec 54 29 f0    	mov    0xf02954ec,%edx
f010a0ee:	83 c2 01             	add    $0x1,%edx
f010a0f1:	89 15 ec 54 29 f0    	mov    %edx,0xf02954ec
	if (ticks * 10 < ticks)
f010a0f7:	8d 04 92             	lea    (%edx,%edx,4),%eax
f010a0fa:	01 c0                	add    %eax,%eax
f010a0fc:	39 c2                	cmp    %eax,%edx
f010a0fe:	76 1c                	jbe    f010a11c <time_tick+0x3a>
		panic("time_tick: time overflowed");
f010a100:	c7 44 24 08 98 49 11 	movl   $0xf0114998,0x8(%esp)
f010a107:	f0 
f010a108:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
f010a10f:	00 
f010a110:	c7 04 24 b3 49 11 f0 	movl   $0xf01149b3,(%esp)
f010a117:	e8 6a 5f ff ff       	call   f0100086 <_panic>
}
f010a11c:	c9                   	leave  
f010a11d:	c3                   	ret    
	...

f010a120 <__divdi3>:
f010a120:	55                   	push   %ebp
f010a121:	89 e5                	mov    %esp,%ebp
f010a123:	57                   	push   %edi
f010a124:	56                   	push   %esi
f010a125:	83 ec 28             	sub    $0x28,%esp
f010a128:	8b 55 0c             	mov    0xc(%ebp),%edx
f010a12b:	8b 45 08             	mov    0x8(%ebp),%eax
f010a12e:	8b 75 10             	mov    0x10(%ebp),%esi
f010a131:	8b 7d 14             	mov    0x14(%ebp),%edi
f010a134:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010a137:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010a13a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010a13d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010a144:	89 f0                	mov    %esi,%eax
f010a146:	89 fa                	mov    %edi,%edx
f010a148:	85 c9                	test   %ecx,%ecx
f010a14a:	0f 88 a2 00 00 00    	js     f010a1f2 <__divdi3+0xd2>
f010a150:	85 ff                	test   %edi,%edi
f010a152:	0f 88 b8 00 00 00    	js     f010a210 <__divdi3+0xf0>
f010a158:	89 d7                	mov    %edx,%edi
f010a15a:	89 c6                	mov    %eax,%esi
f010a15c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010a15f:	89 c1                	mov    %eax,%ecx
f010a161:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010a164:	85 ff                	test   %edi,%edi
f010a166:	89 55 f0             	mov    %edx,-0x10(%ebp)
f010a169:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010a16c:	75 12                	jne    f010a180 <__divdi3+0x60>
f010a16e:	39 c6                	cmp    %eax,%esi
f010a170:	76 3e                	jbe    f010a1b0 <__divdi3+0x90>
f010a172:	89 d0                	mov    %edx,%eax
f010a174:	8b 55 ec             	mov    -0x14(%ebp),%edx
f010a177:	f7 f6                	div    %esi
f010a179:	31 f6                	xor    %esi,%esi
f010a17b:	89 c1                	mov    %eax,%ecx
f010a17d:	eb 11                	jmp    f010a190 <__divdi3+0x70>
f010a17f:	90                   	nop    
f010a180:	3b 7d ec             	cmp    -0x14(%ebp),%edi
f010a183:	76 4c                	jbe    f010a1d1 <__divdi3+0xb1>
f010a185:	31 c9                	xor    %ecx,%ecx
f010a187:	31 f6                	xor    %esi,%esi
f010a189:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
f010a190:	89 c8                	mov    %ecx,%eax
f010a192:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010a195:	89 f2                	mov    %esi,%edx
f010a197:	85 c9                	test   %ecx,%ecx
f010a199:	74 07                	je     f010a1a2 <__divdi3+0x82>
f010a19b:	f7 d8                	neg    %eax
f010a19d:	83 d2 00             	adc    $0x0,%edx
f010a1a0:	f7 da                	neg    %edx
f010a1a2:	83 c4 28             	add    $0x28,%esp
f010a1a5:	5e                   	pop    %esi
f010a1a6:	5f                   	pop    %edi
f010a1a7:	5d                   	pop    %ebp
f010a1a8:	c3                   	ret    
f010a1a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
f010a1b0:	85 f6                	test   %esi,%esi
f010a1b2:	75 0b                	jne    f010a1bf <__divdi3+0x9f>
f010a1b4:	b8 01 00 00 00       	mov    $0x1,%eax
f010a1b9:	31 d2                	xor    %edx,%edx
f010a1bb:	f7 f6                	div    %esi
f010a1bd:	89 c1                	mov    %eax,%ecx
f010a1bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010a1c2:	89 fa                	mov    %edi,%edx
f010a1c4:	f7 f1                	div    %ecx
f010a1c6:	89 c6                	mov    %eax,%esi
f010a1c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010a1cb:	f7 f1                	div    %ecx
f010a1cd:	89 c1                	mov    %eax,%ecx
f010a1cf:	eb bf                	jmp    f010a190 <__divdi3+0x70>
f010a1d1:	0f bd c7             	bsr    %edi,%eax
f010a1d4:	83 f0 1f             	xor    $0x1f,%eax
f010a1d7:	89 45 e8             	mov    %eax,-0x18(%ebp)
f010a1da:	75 47                	jne    f010a223 <__divdi3+0x103>
f010a1dc:	39 7d ec             	cmp    %edi,-0x14(%ebp)
f010a1df:	77 05                	ja     f010a1e6 <__divdi3+0xc6>
f010a1e1:	39 75 f0             	cmp    %esi,-0x10(%ebp)
f010a1e4:	72 9f                	jb     f010a185 <__divdi3+0x65>
f010a1e6:	b9 01 00 00 00       	mov    $0x1,%ecx
f010a1eb:	31 f6                	xor    %esi,%esi
f010a1ed:	8d 76 00             	lea    0x0(%esi),%esi
f010a1f0:	eb 9e                	jmp    f010a190 <__divdi3+0x70>
f010a1f2:	f7 5d d8             	negl   -0x28(%ebp)
f010a1f5:	83 55 dc 00          	adcl   $0x0,-0x24(%ebp)
f010a1f9:	f7 5d dc             	negl   -0x24(%ebp)
f010a1fc:	85 ff                	test   %edi,%edi
f010a1fe:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f010a205:	0f 89 4d ff ff ff    	jns    f010a158 <__divdi3+0x38>
f010a20b:	90                   	nop    
f010a20c:	8d 74 26 00          	lea    0x0(%esi),%esi
f010a210:	89 f0                	mov    %esi,%eax
f010a212:	89 fa                	mov    %edi,%edx
f010a214:	f7 d8                	neg    %eax
f010a216:	83 d2 00             	adc    $0x0,%edx
f010a219:	f7 da                	neg    %edx
f010a21b:	f7 55 e4             	notl   -0x1c(%ebp)
f010a21e:	e9 35 ff ff ff       	jmp    f010a158 <__divdi3+0x38>
f010a223:	b8 20 00 00 00       	mov    $0x20,%eax
f010a228:	89 f2                	mov    %esi,%edx
f010a22a:	2b 45 e8             	sub    -0x18(%ebp),%eax
f010a22d:	89 c1                	mov    %eax,%ecx
f010a22f:	d3 ea                	shr    %cl,%edx
f010a231:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
f010a235:	89 45 f4             	mov    %eax,-0xc(%ebp)
f010a238:	89 f8                	mov    %edi,%eax
f010a23a:	89 d7                	mov    %edx,%edi
f010a23c:	8b 55 ec             	mov    -0x14(%ebp),%edx
f010a23f:	d3 e0                	shl    %cl,%eax
f010a241:	09 c7                	or     %eax,%edi
f010a243:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010a246:	d3 e6                	shl    %cl,%esi
f010a248:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010a24c:	d3 e8                	shr    %cl,%eax
f010a24e:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
f010a252:	d3 e2                	shl    %cl,%edx
f010a254:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010a258:	09 d0                	or     %edx,%eax
f010a25a:	8b 55 ec             	mov    -0x14(%ebp),%edx
f010a25d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010a260:	d3 ea                	shr    %cl,%edx
f010a262:	f7 f7                	div    %edi
f010a264:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010a267:	89 c7                	mov    %eax,%edi
f010a269:	f7 e6                	mul    %esi
f010a26b:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f010a26e:	89 c6                	mov    %eax,%esi
f010a270:	72 1b                	jb     f010a28d <__divdi3+0x16d>
f010a272:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f010a275:	74 09                	je     f010a280 <__divdi3+0x160>
f010a277:	89 f9                	mov    %edi,%ecx
f010a279:	31 f6                	xor    %esi,%esi
f010a27b:	e9 10 ff ff ff       	jmp    f010a190 <__divdi3+0x70>
f010a280:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010a283:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
f010a287:	d3 e0                	shl    %cl,%eax
f010a289:	39 c6                	cmp    %eax,%esi
f010a28b:	76 ea                	jbe    f010a277 <__divdi3+0x157>
f010a28d:	8d 4f ff             	lea    -0x1(%edi),%ecx
f010a290:	31 f6                	xor    %esi,%esi
f010a292:	e9 f9 fe ff ff       	jmp    f010a190 <__divdi3+0x70>
	...

f010a2a0 <__moddi3>:
f010a2a0:	55                   	push   %ebp
f010a2a1:	89 e5                	mov    %esp,%ebp
f010a2a3:	57                   	push   %edi
f010a2a4:	56                   	push   %esi
f010a2a5:	83 ec 58             	sub    $0x58,%esp
f010a2a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010a2ab:	8b 55 14             	mov    0x14(%ebp),%edx
f010a2ae:	8b 45 10             	mov    0x10(%ebp),%eax
f010a2b1:	c7 45 b0 00 00 00 00 	movl   $0x0,-0x50(%ebp)
f010a2b8:	85 c9                	test   %ecx,%ecx
f010a2ba:	89 55 ac             	mov    %edx,-0x54(%ebp)
f010a2bd:	8b 55 08             	mov    0x8(%ebp),%edx
f010a2c0:	89 45 a8             	mov    %eax,-0x58(%ebp)
f010a2c3:	8b 7d ac             	mov    -0x54(%ebp),%edi
f010a2c6:	c7 45 b4 00 00 00 00 	movl   $0x0,-0x4c(%ebp)
f010a2cd:	8b 75 a8             	mov    -0x58(%ebp),%esi
f010a2d0:	c7 45 bc 00 00 00 00 	movl   $0x0,-0x44(%ebp)
f010a2d7:	0f 88 f3 00 00 00    	js     f010a3d0 <__moddi3+0x130>
f010a2dd:	8b 45 ac             	mov    -0x54(%ebp),%eax
f010a2e0:	85 c0                	test   %eax,%eax
f010a2e2:	0f 88 cf 00 00 00    	js     f010a3b7 <__moddi3+0x117>
f010a2e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
f010a2eb:	85 ff                	test   %edi,%edi
f010a2ed:	89 75 d8             	mov    %esi,-0x28(%ebp)
f010a2f0:	89 75 cc             	mov    %esi,-0x34(%ebp)
f010a2f3:	89 ce                	mov    %ecx,%esi
f010a2f5:	89 45 c0             	mov    %eax,-0x40(%ebp)
f010a2f8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010a2fb:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010a2fe:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f010a301:	75 2d                	jne    f010a330 <__moddi3+0x90>
f010a303:	39 4d d8             	cmp    %ecx,-0x28(%ebp)
f010a306:	0f 86 85 00 00 00    	jbe    f010a391 <__moddi3+0xf1>
f010a30c:	89 d0                	mov    %edx,%eax
f010a30e:	89 ca                	mov    %ecx,%edx
f010a310:	f7 75 d8             	divl   -0x28(%ebp)
f010a313:	89 55 b0             	mov    %edx,-0x50(%ebp)
f010a316:	c7 45 b4 00 00 00 00 	movl   $0x0,-0x4c(%ebp)
f010a31d:	8b 75 c0             	mov    -0x40(%ebp),%esi
f010a320:	8b 55 b0             	mov    -0x50(%ebp),%edx
f010a323:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f010a326:	89 16                	mov    %edx,(%esi)
f010a328:	89 4e 04             	mov    %ecx,0x4(%esi)
f010a32b:	eb 19                	jmp    f010a346 <__moddi3+0xa6>
f010a32d:	8d 76 00             	lea    0x0(%esi),%esi
f010a330:	39 cf                	cmp    %ecx,%edi
f010a332:	76 30                	jbe    f010a364 <__moddi3+0xc4>
f010a334:	89 55 b0             	mov    %edx,-0x50(%ebp)
f010a337:	8b 45 b0             	mov    -0x50(%ebp),%eax
f010a33a:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
f010a33d:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f010a340:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010a343:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010a346:	8b 45 bc             	mov    -0x44(%ebp),%eax
f010a349:	85 c0                	test   %eax,%eax
f010a34b:	74 0a                	je     f010a357 <__moddi3+0xb7>
f010a34d:	f7 5d f0             	negl   -0x10(%ebp)
f010a350:	83 55 f4 00          	adcl   $0x0,-0xc(%ebp)
f010a354:	f7 5d f4             	negl   -0xc(%ebp)
f010a357:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010a35a:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010a35d:	83 c4 58             	add    $0x58,%esp
f010a360:	5e                   	pop    %esi
f010a361:	5f                   	pop    %edi
f010a362:	5d                   	pop    %ebp
f010a363:	c3                   	ret    
f010a364:	0f bd c7             	bsr    %edi,%eax
f010a367:	83 f0 1f             	xor    $0x1f,%eax
f010a36a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010a36d:	75 74                	jne    f010a3e3 <__moddi3+0x143>
f010a36f:	39 f9                	cmp    %edi,%ecx
f010a371:	0f 87 07 01 00 00    	ja     f010a47e <__moddi3+0x1de>
f010a377:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010a37a:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f010a37d:	0f 83 fb 00 00 00    	jae    f010a47e <__moddi3+0x1de>
f010a383:	8b 75 dc             	mov    -0x24(%ebp),%esi
f010a386:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010a389:	89 75 b0             	mov    %esi,-0x50(%ebp)
f010a38c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
f010a38f:	eb 8c                	jmp    f010a31d <__moddi3+0x7d>
f010a391:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010a394:	85 d2                	test   %edx,%edx
f010a396:	75 0d                	jne    f010a3a5 <__moddi3+0x105>
f010a398:	b8 01 00 00 00       	mov    $0x1,%eax
f010a39d:	31 d2                	xor    %edx,%edx
f010a39f:	f7 75 d8             	divl   -0x28(%ebp)
f010a3a2:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010a3a5:	89 f0                	mov    %esi,%eax
f010a3a7:	89 fa                	mov    %edi,%edx
f010a3a9:	f7 75 cc             	divl   -0x34(%ebp)
f010a3ac:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010a3af:	f7 75 cc             	divl   -0x34(%ebp)
f010a3b2:	e9 5c ff ff ff       	jmp    f010a313 <__moddi3+0x73>
f010a3b7:	8b 75 a8             	mov    -0x58(%ebp),%esi
f010a3ba:	8b 7d ac             	mov    -0x54(%ebp),%edi
f010a3bd:	f7 de                	neg    %esi
f010a3bf:	83 d7 00             	adc    $0x0,%edi
f010a3c2:	f7 df                	neg    %edi
f010a3c4:	e9 1f ff ff ff       	jmp    f010a2e8 <__moddi3+0x48>
f010a3c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
f010a3d0:	f7 da                	neg    %edx
f010a3d2:	83 d1 00             	adc    $0x0,%ecx
f010a3d5:	f7 d9                	neg    %ecx
f010a3d7:	c7 45 bc ff ff ff ff 	movl   $0xffffffff,-0x44(%ebp)
f010a3de:	e9 fa fe ff ff       	jmp    f010a2dd <__moddi3+0x3d>
f010a3e3:	b8 20 00 00 00       	mov    $0x20,%eax
f010a3e8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010a3eb:	2b 45 c4             	sub    -0x3c(%ebp),%eax
f010a3ee:	89 c1                	mov    %eax,%ecx
f010a3f0:	d3 ea                	shr    %cl,%edx
f010a3f2:	0f b6 4d c4          	movzbl -0x3c(%ebp),%ecx
f010a3f6:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010a3f9:	89 f8                	mov    %edi,%eax
f010a3fb:	8b 7d d8             	mov    -0x28(%ebp),%edi
f010a3fe:	d3 e0                	shl    %cl,%eax
f010a400:	09 c2                	or     %eax,%edx
f010a402:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010a405:	d3 e7                	shl    %cl,%edi
f010a407:	0f b6 4d d0          	movzbl -0x30(%ebp),%ecx
f010a40b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010a40e:	89 f2                	mov    %esi,%edx
f010a410:	d3 e8                	shr    %cl,%eax
f010a412:	0f b6 4d c4          	movzbl -0x3c(%ebp),%ecx
f010a416:	d3 e2                	shl    %cl,%edx
f010a418:	09 d0                	or     %edx,%eax
f010a41a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010a41d:	d3 e2                	shl    %cl,%edx
f010a41f:	0f b6 4d d0          	movzbl -0x30(%ebp),%ecx
f010a423:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010a426:	89 f2                	mov    %esi,%edx
f010a428:	d3 ea                	shr    %cl,%edx
f010a42a:	f7 75 e4             	divl   -0x1c(%ebp)
f010a42d:	89 55 a4             	mov    %edx,-0x5c(%ebp)
f010a430:	f7 e7                	mul    %edi
f010a432:	39 55 a4             	cmp    %edx,-0x5c(%ebp)
f010a435:	72 5f                	jb     f010a496 <__moddi3+0x1f6>
f010a437:	3b 55 a4             	cmp    -0x5c(%ebp),%edx
f010a43a:	74 55                	je     f010a491 <__moddi3+0x1f1>
f010a43c:	8d 74 26 00          	lea    0x0(%esi),%esi
f010a440:	8b 75 a4             	mov    -0x5c(%ebp),%esi
f010a443:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010a446:	29 c1                	sub    %eax,%ecx
f010a448:	19 d6                	sbb    %edx,%esi
f010a44a:	89 ca                	mov    %ecx,%edx
f010a44c:	0f b6 4d c4          	movzbl -0x3c(%ebp),%ecx
f010a450:	89 f0                	mov    %esi,%eax
f010a452:	89 75 a4             	mov    %esi,-0x5c(%ebp)
f010a455:	d3 ea                	shr    %cl,%edx
f010a457:	0f b6 4d d0          	movzbl -0x30(%ebp),%ecx
f010a45b:	d3 e0                	shl    %cl,%eax
f010a45d:	0f b6 4d c4          	movzbl -0x3c(%ebp),%ecx
f010a461:	09 c2                	or     %eax,%edx
f010a463:	89 55 b0             	mov    %edx,-0x50(%ebp)
f010a466:	8b 45 b0             	mov    -0x50(%ebp),%eax
f010a469:	d3 ee                	shr    %cl,%esi
f010a46b:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f010a46e:	89 75 b4             	mov    %esi,-0x4c(%ebp)
f010a471:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f010a474:	89 01                	mov    %eax,(%ecx)
f010a476:	89 51 04             	mov    %edx,0x4(%ecx)
f010a479:	e9 c8 fe ff ff       	jmp    f010a346 <__moddi3+0xa6>
f010a47e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010a481:	2b 4d d8             	sub    -0x28(%ebp),%ecx
f010a484:	19 fe                	sbb    %edi,%esi
f010a486:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010a489:	89 75 c8             	mov    %esi,-0x38(%ebp)
f010a48c:	e9 f2 fe ff ff       	jmp    f010a383 <__moddi3+0xe3>
f010a491:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f010a494:	76 aa                	jbe    f010a440 <__moddi3+0x1a0>
f010a496:	29 f8                	sub    %edi,%eax
f010a498:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
f010a49b:	eb a3                	jmp    f010a440 <__moddi3+0x1a0>
f010a49d:	00 00                	add    %al,(%eax)
	...

f010a4a0 <__udivdi3>:
f010a4a0:	55                   	push   %ebp
f010a4a1:	89 e5                	mov    %esp,%ebp
f010a4a3:	57                   	push   %edi
f010a4a4:	56                   	push   %esi
f010a4a5:	83 ec 18             	sub    $0x18,%esp
f010a4a8:	8b 45 10             	mov    0x10(%ebp),%eax
f010a4ab:	8b 55 14             	mov    0x14(%ebp),%edx
f010a4ae:	8b 75 0c             	mov    0xc(%ebp),%esi
f010a4b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
f010a4b4:	89 c1                	mov    %eax,%ecx
f010a4b6:	8b 45 08             	mov    0x8(%ebp),%eax
f010a4b9:	85 d2                	test   %edx,%edx
f010a4bb:	89 d7                	mov    %edx,%edi
f010a4bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010a4c0:	75 1e                	jne    f010a4e0 <__udivdi3+0x40>
f010a4c2:	39 f1                	cmp    %esi,%ecx
f010a4c4:	0f 86 8d 00 00 00    	jbe    f010a557 <__udivdi3+0xb7>
f010a4ca:	89 f2                	mov    %esi,%edx
f010a4cc:	31 f6                	xor    %esi,%esi
f010a4ce:	f7 f1                	div    %ecx
f010a4d0:	89 c1                	mov    %eax,%ecx
f010a4d2:	89 c8                	mov    %ecx,%eax
f010a4d4:	89 f2                	mov    %esi,%edx
f010a4d6:	83 c4 18             	add    $0x18,%esp
f010a4d9:	5e                   	pop    %esi
f010a4da:	5f                   	pop    %edi
f010a4db:	5d                   	pop    %ebp
f010a4dc:	c3                   	ret    
f010a4dd:	8d 76 00             	lea    0x0(%esi),%esi
f010a4e0:	39 f2                	cmp    %esi,%edx
f010a4e2:	0f 87 a8 00 00 00    	ja     f010a590 <__udivdi3+0xf0>
f010a4e8:	0f bd c2             	bsr    %edx,%eax
f010a4eb:	83 f0 1f             	xor    $0x1f,%eax
f010a4ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
f010a4f1:	0f 84 89 00 00 00    	je     f010a580 <__udivdi3+0xe0>
f010a4f7:	b8 20 00 00 00       	mov    $0x20,%eax
f010a4fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010a4ff:	2b 45 e8             	sub    -0x18(%ebp),%eax
f010a502:	89 c1                	mov    %eax,%ecx
f010a504:	d3 ea                	shr    %cl,%edx
f010a506:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
f010a50a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010a50d:	89 f8                	mov    %edi,%eax
f010a50f:	8b 7d f4             	mov    -0xc(%ebp),%edi
f010a512:	d3 e0                	shl    %cl,%eax
f010a514:	09 c2                	or     %eax,%edx
f010a516:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010a519:	d3 e7                	shl    %cl,%edi
f010a51b:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f010a51f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010a522:	89 f2                	mov    %esi,%edx
f010a524:	d3 e8                	shr    %cl,%eax
f010a526:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
f010a52a:	d3 e2                	shl    %cl,%edx
f010a52c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f010a530:	09 d0                	or     %edx,%eax
f010a532:	d3 ee                	shr    %cl,%esi
f010a534:	89 f2                	mov    %esi,%edx
f010a536:	f7 75 e4             	divl   -0x1c(%ebp)
f010a539:	89 d1                	mov    %edx,%ecx
f010a53b:	89 75 e0             	mov    %esi,-0x20(%ebp)
f010a53e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010a541:	f7 e7                	mul    %edi
f010a543:	39 d1                	cmp    %edx,%ecx
f010a545:	89 c6                	mov    %eax,%esi
f010a547:	72 70                	jb     f010a5b9 <__udivdi3+0x119>
f010a549:	39 ca                	cmp    %ecx,%edx
f010a54b:	74 5f                	je     f010a5ac <__udivdi3+0x10c>
f010a54d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010a550:	31 f6                	xor    %esi,%esi
f010a552:	e9 7b ff ff ff       	jmp    f010a4d2 <__udivdi3+0x32>
f010a557:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010a55a:	85 c0                	test   %eax,%eax
f010a55c:	75 0c                	jne    f010a56a <__udivdi3+0xca>
f010a55e:	b8 01 00 00 00       	mov    $0x1,%eax
f010a563:	31 d2                	xor    %edx,%edx
f010a565:	f7 75 f4             	divl   -0xc(%ebp)
f010a568:	89 c1                	mov    %eax,%ecx
f010a56a:	89 f0                	mov    %esi,%eax
f010a56c:	89 fa                	mov    %edi,%edx
f010a56e:	f7 f1                	div    %ecx
f010a570:	89 c6                	mov    %eax,%esi
f010a572:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010a575:	f7 f1                	div    %ecx
f010a577:	89 c1                	mov    %eax,%ecx
f010a579:	e9 54 ff ff ff       	jmp    f010a4d2 <__udivdi3+0x32>
f010a57e:	66 90                	xchg   %ax,%ax
f010a580:	39 d6                	cmp    %edx,%esi
f010a582:	77 1c                	ja     f010a5a0 <__udivdi3+0x100>
f010a584:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010a587:	39 55 ec             	cmp    %edx,-0x14(%ebp)
f010a58a:	73 14                	jae    f010a5a0 <__udivdi3+0x100>
f010a58c:	8d 74 26 00          	lea    0x0(%esi),%esi
f010a590:	31 c9                	xor    %ecx,%ecx
f010a592:	31 f6                	xor    %esi,%esi
f010a594:	e9 39 ff ff ff       	jmp    f010a4d2 <__udivdi3+0x32>
f010a599:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
f010a5a0:	b9 01 00 00 00       	mov    $0x1,%ecx
f010a5a5:	31 f6                	xor    %esi,%esi
f010a5a7:	e9 26 ff ff ff       	jmp    f010a4d2 <__udivdi3+0x32>
f010a5ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010a5af:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
f010a5b3:	d3 e0                	shl    %cl,%eax
f010a5b5:	39 c6                	cmp    %eax,%esi
f010a5b7:	76 94                	jbe    f010a54d <__udivdi3+0xad>
f010a5b9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010a5bc:	31 f6                	xor    %esi,%esi
f010a5be:	83 e9 01             	sub    $0x1,%ecx
f010a5c1:	e9 0c ff ff ff       	jmp    f010a4d2 <__udivdi3+0x32>
	...

f010a5d0 <__umoddi3>:
f010a5d0:	55                   	push   %ebp
f010a5d1:	89 e5                	mov    %esp,%ebp
f010a5d3:	57                   	push   %edi
f010a5d4:	56                   	push   %esi
f010a5d5:	83 ec 30             	sub    $0x30,%esp
f010a5d8:	8b 45 10             	mov    0x10(%ebp),%eax
f010a5db:	8b 55 14             	mov    0x14(%ebp),%edx
f010a5de:	8b 75 08             	mov    0x8(%ebp),%esi
f010a5e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010a5e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010a5e7:	89 c1                	mov    %eax,%ecx
f010a5e9:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010a5ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010a5ef:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f010a5f6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f010a5fd:	89 fa                	mov    %edi,%edx
f010a5ff:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f010a602:	85 c0                	test   %eax,%eax
f010a604:	89 75 f0             	mov    %esi,-0x10(%ebp)
f010a607:	89 7d e0             	mov    %edi,-0x20(%ebp)
f010a60a:	75 14                	jne    f010a620 <__umoddi3+0x50>
f010a60c:	39 f9                	cmp    %edi,%ecx
f010a60e:	76 60                	jbe    f010a670 <__umoddi3+0xa0>
f010a610:	89 f0                	mov    %esi,%eax
f010a612:	f7 f1                	div    %ecx
f010a614:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010a617:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f010a61e:	eb 10                	jmp    f010a630 <__umoddi3+0x60>
f010a620:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010a623:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
f010a626:	76 18                	jbe    f010a640 <__umoddi3+0x70>
f010a628:	89 75 d0             	mov    %esi,-0x30(%ebp)
f010a62b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010a62e:	66 90                	xchg   %ax,%ax
f010a630:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010a633:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010a636:	83 c4 30             	add    $0x30,%esp
f010a639:	5e                   	pop    %esi
f010a63a:	5f                   	pop    %edi
f010a63b:	5d                   	pop    %ebp
f010a63c:	c3                   	ret    
f010a63d:	8d 76 00             	lea    0x0(%esi),%esi
f010a640:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
f010a644:	83 f0 1f             	xor    $0x1f,%eax
f010a647:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010a64a:	75 46                	jne    f010a692 <__umoddi3+0xc2>
f010a64c:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010a64f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
f010a652:	0f 87 c9 00 00 00    	ja     f010a721 <__umoddi3+0x151>
f010a658:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010a65b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
f010a65e:	0f 83 bd 00 00 00    	jae    f010a721 <__umoddi3+0x151>
f010a664:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f010a667:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010a66a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010a66d:	eb c1                	jmp    f010a630 <__umoddi3+0x60>
f010a66f:	90                   	nop    
f010a670:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010a673:	85 c0                	test   %eax,%eax
f010a675:	75 0c                	jne    f010a683 <__umoddi3+0xb3>
f010a677:	b8 01 00 00 00       	mov    $0x1,%eax
f010a67c:	31 d2                	xor    %edx,%edx
f010a67e:	f7 75 ec             	divl   -0x14(%ebp)
f010a681:	89 c1                	mov    %eax,%ecx
f010a683:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010a686:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010a689:	f7 f1                	div    %ecx
f010a68b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010a68e:	f7 f1                	div    %ecx
f010a690:	eb 82                	jmp    f010a614 <__umoddi3+0x44>
f010a692:	b8 20 00 00 00       	mov    $0x20,%eax
f010a697:	8b 55 ec             	mov    -0x14(%ebp),%edx
f010a69a:	2b 45 d8             	sub    -0x28(%ebp),%eax
f010a69d:	8b 75 ec             	mov    -0x14(%ebp),%esi
f010a6a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010a6a3:	89 c1                	mov    %eax,%ecx
f010a6a5:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010a6a8:	d3 ea                	shr    %cl,%edx
f010a6aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010a6ad:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
f010a6b1:	d3 e0                	shl    %cl,%eax
f010a6b3:	09 c2                	or     %eax,%edx
f010a6b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010a6b8:	d3 e6                	shl    %cl,%esi
f010a6ba:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
f010a6be:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010a6c1:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010a6c4:	d3 e8                	shr    %cl,%eax
f010a6c6:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
f010a6ca:	d3 e2                	shl    %cl,%edx
f010a6cc:	09 d0                	or     %edx,%eax
f010a6ce:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010a6d1:	d3 e7                	shl    %cl,%edi
f010a6d3:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
f010a6d7:	d3 ea                	shr    %cl,%edx
f010a6d9:	f7 75 f4             	divl   -0xc(%ebp)
f010a6dc:	89 55 cc             	mov    %edx,-0x34(%ebp)
f010a6df:	f7 e6                	mul    %esi
f010a6e1:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f010a6e4:	72 53                	jb     f010a739 <__umoddi3+0x169>
f010a6e6:	3b 55 cc             	cmp    -0x34(%ebp),%edx
f010a6e9:	74 4a                	je     f010a735 <__umoddi3+0x165>
f010a6eb:	90                   	nop    
f010a6ec:	8d 74 26 00          	lea    0x0(%esi),%esi
f010a6f0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010a6f3:	29 c7                	sub    %eax,%edi
f010a6f5:	19 d1                	sbb    %edx,%ecx
f010a6f7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f010a6fa:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
f010a6fe:	89 fa                	mov    %edi,%edx
f010a700:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010a703:	d3 ea                	shr    %cl,%edx
f010a705:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
f010a709:	d3 e0                	shl    %cl,%eax
f010a70b:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
f010a70f:	09 c2                	or     %eax,%edx
f010a711:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010a714:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010a717:	d3 e8                	shr    %cl,%eax
f010a719:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010a71c:	e9 0f ff ff ff       	jmp    f010a630 <__umoddi3+0x60>
f010a721:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010a724:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010a727:	2b 45 ec             	sub    -0x14(%ebp),%eax
f010a72a:	1b 55 e8             	sbb    -0x18(%ebp),%edx
f010a72d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010a730:	e9 2f ff ff ff       	jmp    f010a664 <__umoddi3+0x94>
f010a735:	39 f8                	cmp    %edi,%eax
f010a737:	76 b7                	jbe    f010a6f0 <__umoddi3+0x120>
f010a739:	29 f0                	sub    %esi,%eax
f010a73b:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f010a73e:	eb b0                	jmp    f010a6f0 <__umoddi3+0x120>
