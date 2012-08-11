
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
f0100015:	0f 01 15 18 e0 12 00 	lgdtl  0x12e018

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
f0100033:	bc bc df 12 f0       	mov    $0xf012dfbc,%esp

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
f010005a:	c7 04 24 e0 9e 10 f0 	movl   $0xf0109ee0,(%esp)
f0100061:	e8 71 39 00 00       	call   f01039d7 <cprintf>
	vcprintf(fmt, ap);
f0100066:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0100069:	89 44 24 04          	mov    %eax,0x4(%esp)
f010006d:	8b 45 10             	mov    0x10(%ebp),%eax
f0100070:	89 04 24             	mov    %eax,(%esp)
f0100073:	e8 2c 39 00 00       	call   f01039a4 <vcprintf>
	cprintf("\n");
f0100078:	c7 04 24 c9 a2 10 f0 	movl   $0xf010a2c9,(%esp)
f010007f:	e8 53 39 00 00       	call   f01039d7 <cprintf>
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
f0100090:	83 3d 60 93 1b f0 00 	cmpl   $0x0,0xf01b9360
f0100097:	75 43                	jne    f01000dc <_panic+0x56>
		goto dead;
	panicstr = fmt;
f0100099:	89 1d 60 93 1b f0    	mov    %ebx,0xf01b9360

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
f01000b5:	c7 04 24 fa 9e 10 f0 	movl   $0xf0109efa,(%esp)
f01000bc:	e8 16 39 00 00       	call   f01039d7 <cprintf>
	vcprintf(fmt, ap);
f01000c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01000c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000c8:	89 1c 24             	mov    %ebx,(%esp)
f01000cb:	e8 d4 38 00 00       	call   f01039a4 <vcprintf>
	cprintf("\n");
f01000d0:	c7 04 24 c9 a2 10 f0 	movl   $0xf010a2c9,(%esp)
f01000d7:	e8 fb 38 00 00       	call   f01039d7 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000e3:	e8 8f 08 00 00       	call   f0100977 <monitor>
f01000e8:	eb f2                	jmp    f01000dc <_panic+0x56>

f01000ea <i386_init>:
#include <kern/picirq.h>


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
f01000f0:	b8 70 a5 1b f0       	mov    $0xf01ba570,%eax
f01000f5:	2d 5d 93 1b f0       	sub    $0xf01b935d,%eax
f01000fa:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100105:	00 
f0100106:	c7 04 24 5d 93 1b f0 	movl   $0xf01b935d,(%esp)
f010010d:	e8 1c 95 00 00       	call   f010962e <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100112:	e8 53 03 00 00       	call   f010046a <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100117:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f010011e:	00 
f010011f:	c7 04 24 12 9f 10 f0 	movl   $0xf0109f12,(%esp)
f0100126:	e8 ac 38 00 00       	call   f01039d7 <cprintf>

	// Lab 2 memory management initialization functions
	i386_detect_memory();
f010012b:	e8 64 16 00 00       	call   f0101794 <i386_detect_memory>
	i386_vm_init();
f0100130:	e8 52 1d 00 00       	call   f0101e87 <i386_vm_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100135:	e8 76 30 00 00       	call   f01031b0 <env_init>
	idt_init();
f010013a:	e8 d1 38 00 00       	call   f0103a10 <idt_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010013f:	90                   	nop    
f0100140:	e8 d3 37 00 00       	call   f0103918 <pic_init>
	kclock_init();
f0100145:	e8 07 37 00 00       	call   f0103851 <kclock_init>

	// Should always have an idle process as first one.
	ENV_CREATE(user_idle);
f010014a:	c7 44 24 04 9f dc 00 	movl   $0xdc9f,0x4(%esp)
f0100151:	00 
f0100152:	c7 04 24 64 e7 12 f0 	movl   $0xf012e764,(%esp)
f0100159:	e8 d7 32 00 00       	call   f0103435 <env_create>

	// Start fs.
	ENV_CREATE(fs_fs);
f010015e:	c7 44 24 04 59 83 01 	movl   $0x18359,0x4(%esp)
f0100165:	00 
f0100166:	c7 04 24 04 10 1a f0 	movl   $0xf01a1004,(%esp)
f010016d:	e8 c3 32 00 00       	call   f0103435 <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE2(TEST, TESTSIZE);
f0100172:	c7 44 24 04 d1 dc 00 	movl   $0xdcd1,0x4(%esp)
f0100179:	00 
f010017a:	c7 04 24 0a 8d 16 f0 	movl   $0xf0168d0a,(%esp)
f0100181:	e8 af 32 00 00       	call   f0103435 <env_create>
	// ENV_CREATE(user_testfile);
	// ENV_CREATE(user_icode);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f0100186:	e8 b1 49 00 00       	call   f0104b3c <sched_yield>
f010018b:	00 00                	add    %al,(%eax)
f010018d:	00 00                	add    %al,(%eax)
	...

f0100190 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100190:	55                   	push   %ebp
f0100191:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100193:	ba 84 00 00 00       	mov    $0x84,%edx
f0100198:	ec                   	in     (%dx),%al
f0100199:	ec                   	in     (%dx),%al
f010019a:	ec                   	in     (%dx),%al
f010019b:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f010019c:	5d                   	pop    %ebp
f010019d:	c3                   	ret    

f010019e <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010019e:	55                   	push   %ebp
f010019f:	89 e5                	mov    %esp,%ebp
f01001a1:	53                   	push   %ebx
f01001a2:	83 ec 04             	sub    $0x4,%esp
f01001a5:	89 c3                	mov    %eax,%ebx
f01001a7:	eb 2a                	jmp    f01001d3 <cons_intr+0x35>
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
f01001a9:	85 c0                	test   %eax,%eax
f01001ab:	74 26                	je     f01001d3 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01001ad:	8b 15 a4 95 1b f0    	mov    0xf01b95a4,%edx
f01001b3:	88 82 a0 93 1b f0    	mov    %al,-0xfe46c60(%edx)
f01001b9:	83 c2 01             	add    $0x1,%edx
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
f01001bc:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001c2:	0f 94 c0             	sete   %al
f01001c5:	0f b6 c0             	movzbl %al,%eax
f01001c8:	83 e8 01             	sub    $0x1,%eax
f01001cb:	21 c2                	and    %eax,%edx
f01001cd:	89 15 a4 95 1b f0    	mov    %edx,0xf01b95a4
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001d3:	ff d3                	call   *%ebx
f01001d5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001d8:	75 cf                	jne    f01001a9 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001da:	83 c4 04             	add    $0x4,%esp
f01001dd:	5b                   	pop    %ebx
f01001de:	5d                   	pop    %ebp
f01001df:	c3                   	ret    

f01001e0 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01001e0:	55                   	push   %ebp
f01001e1:	89 e5                	mov    %esp,%ebp
f01001e3:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01001e6:	b8 9a 05 10 f0       	mov    $0xf010059a,%eax
f01001eb:	e8 ae ff ff ff       	call   f010019e <cons_intr>
}
f01001f0:	c9                   	leave  
f01001f1:	c3                   	ret    

f01001f2 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01001f2:	55                   	push   %ebp
f01001f3:	89 e5                	mov    %esp,%ebp
f01001f5:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f01001f8:	83 3d 84 93 1b f0 00 	cmpl   $0x0,0xf01b9384
f01001ff:	74 0a                	je     f010020b <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100201:	b8 7b 05 10 f0       	mov    $0xf010057b,%eax
f0100206:	e8 93 ff ff ff       	call   f010019e <cons_intr>
}
f010020b:	c9                   	leave  
f010020c:	c3                   	ret    

f010020d <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010020d:	55                   	push   %ebp
f010020e:	89 e5                	mov    %esp,%ebp
f0100210:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100213:	e8 da ff ff ff       	call   f01001f2 <serial_intr>
	kbd_intr();
f0100218:	e8 c3 ff ff ff       	call   f01001e0 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010021d:	a1 a0 95 1b f0       	mov    0xf01b95a0,%eax
f0100222:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100227:	3b 05 a4 95 1b f0    	cmp    0xf01b95a4,%eax
f010022d:	74 21                	je     f0100250 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f010022f:	0f b6 88 a0 93 1b f0 	movzbl -0xfe46c60(%eax),%ecx
f0100236:	8d 50 01             	lea    0x1(%eax),%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f0100239:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010023f:	0f 94 c0             	sete   %al
f0100242:	0f b6 c0             	movzbl %al,%eax
f0100245:	83 e8 01             	sub    $0x1,%eax
f0100248:	21 c2                	and    %eax,%edx
f010024a:	89 15 a0 95 1b f0    	mov    %edx,0xf01b95a0
		return c;
	}
	return 0;
}
f0100250:	89 c8                	mov    %ecx,%eax
f0100252:	c9                   	leave  
f0100253:	c3                   	ret    

f0100254 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f0100254:	55                   	push   %ebp
f0100255:	89 e5                	mov    %esp,%ebp
f0100257:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010025a:	e8 ae ff ff ff       	call   f010020d <cons_getc>
f010025f:	85 c0                	test   %eax,%eax
f0100261:	74 f7                	je     f010025a <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100263:	c9                   	leave  
f0100264:	c3                   	ret    

f0100265 <iscons>:

int
iscons(int fdnum)
{
f0100265:	55                   	push   %ebp
f0100266:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100268:	b8 01 00 00 00       	mov    $0x1,%eax
f010026d:	5d                   	pop    %ebp
f010026e:	c3                   	ret    

f010026f <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010026f:	55                   	push   %ebp
f0100270:	89 e5                	mov    %esp,%ebp
f0100272:	57                   	push   %edi
f0100273:	56                   	push   %esi
f0100274:	53                   	push   %ebx
f0100275:	83 ec 0c             	sub    $0xc,%esp
f0100278:	89 c7                	mov    %eax,%edi
f010027a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010027f:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;
	
	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100280:	a8 20                	test   $0x20,%al
f0100282:	75 1f                	jne    f01002a3 <cons_putc+0x34>
f0100284:	bb 00 00 00 00       	mov    $0x0,%ebx
	     i++)
		delay();
f0100289:	e8 02 ff ff ff       	call   f0100190 <delay>
f010028e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100293:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;
	
	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100294:	a8 20                	test   $0x20,%al
f0100296:	75 0b                	jne    f01002a3 <cons_putc+0x34>
	     i++)
f0100298:	83 c3 01             	add    $0x1,%ebx
serial_putc(int c)
{
	int i;
	
	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010029b:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01002a1:	75 e6                	jne    f0100289 <cons_putc+0x1a>
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
f01002a3:	89 fe                	mov    %edi,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002a5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002aa:	89 f8                	mov    %edi,%eax
f01002ac:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002ad:	b2 79                	mov    $0x79,%dl
f01002af:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002b0:	84 c0                	test   %al,%al
f01002b2:	78 1f                	js     f01002d3 <cons_putc+0x64>
f01002b4:	bb 00 00 00 00       	mov    $0x0,%ebx
		delay();
f01002b9:	e8 d2 fe ff ff       	call   f0100190 <delay>
f01002be:	ba 79 03 00 00       	mov    $0x379,%edx
f01002c3:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002c4:	84 c0                	test   %al,%al
f01002c6:	78 0b                	js     f01002d3 <cons_putc+0x64>
f01002c8:	83 c3 01             	add    $0x1,%ebx
f01002cb:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01002d1:	75 e6                	jne    f01002b9 <cons_putc+0x4a>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002d3:	ba 78 03 00 00       	mov    $0x378,%edx
f01002d8:	89 f0                	mov    %esi,%eax
f01002da:	ee                   	out    %al,(%dx)
f01002db:	b8 0d 00 00 00       	mov    $0xd,%eax
f01002e0:	b2 7a                	mov    $0x7a,%dl
f01002e2:	ee                   	out    %al,(%dx)
f01002e3:	b8 08 00 00 00       	mov    $0x8,%eax
f01002e8:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01002e9:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f01002ef:	75 06                	jne    f01002f7 <cons_putc+0x88>
		c |= 0x0700;
f01002f1:	81 cf 00 07 00 00    	or     $0x700,%edi

	switch (c & 0xff) {
f01002f7:	89 f8                	mov    %edi,%eax
f01002f9:	25 ff 00 00 00       	and    $0xff,%eax
f01002fe:	83 f8 09             	cmp    $0x9,%eax
f0100301:	74 7e                	je     f0100381 <cons_putc+0x112>
f0100303:	83 f8 09             	cmp    $0x9,%eax
f0100306:	7f 0b                	jg     f0100313 <cons_putc+0xa4>
f0100308:	83 f8 08             	cmp    $0x8,%eax
f010030b:	0f 85 a4 00 00 00    	jne    f01003b5 <cons_putc+0x146>
f0100311:	eb 15                	jmp    f0100328 <cons_putc+0xb9>
f0100313:	83 f8 0a             	cmp    $0xa,%eax
f0100316:	74 3f                	je     f0100357 <cons_putc+0xe8>
f0100318:	83 f8 0d             	cmp    $0xd,%eax
f010031b:	90                   	nop    
f010031c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0100320:	0f 85 8f 00 00 00    	jne    f01003b5 <cons_putc+0x146>
f0100326:	eb 37                	jmp    f010035f <cons_putc+0xf0>
	case '\b':
		if (crt_pos > 0) {
f0100328:	0f b7 05 90 93 1b f0 	movzwl 0xf01b9390,%eax
f010032f:	66 85 c0             	test   %ax,%ax
f0100332:	0f 84 ea 00 00 00    	je     f0100422 <cons_putc+0x1b3>
			crt_pos--;
f0100338:	83 e8 01             	sub    $0x1,%eax
f010033b:	66 a3 90 93 1b f0    	mov    %ax,0xf01b9390
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100341:	0f b7 c0             	movzwl %ax,%eax
f0100344:	89 fa                	mov    %edi,%edx
f0100346:	b2 00                	mov    $0x0,%dl
f0100348:	83 ca 20             	or     $0x20,%edx
f010034b:	8b 0d 8c 93 1b f0    	mov    0xf01b938c,%ecx
f0100351:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f0100355:	eb 7b                	jmp    f01003d2 <cons_putc+0x163>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100357:	66 83 05 90 93 1b f0 	addw   $0x50,0xf01b9390
f010035e:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010035f:	0f b7 05 90 93 1b f0 	movzwl 0xf01b9390,%eax
f0100366:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010036c:	c1 e8 10             	shr    $0x10,%eax
f010036f:	66 c1 e8 06          	shr    $0x6,%ax
f0100373:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100376:	c1 e0 04             	shl    $0x4,%eax
f0100379:	66 a3 90 93 1b f0    	mov    %ax,0xf01b9390
f010037f:	eb 51                	jmp    f01003d2 <cons_putc+0x163>
		break;
	case '\t':
		cons_putc(' ');
f0100381:	b8 20 00 00 00       	mov    $0x20,%eax
f0100386:	e8 e4 fe ff ff       	call   f010026f <cons_putc>
		cons_putc(' ');
f010038b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100390:	e8 da fe ff ff       	call   f010026f <cons_putc>
		cons_putc(' ');
f0100395:	b8 20 00 00 00       	mov    $0x20,%eax
f010039a:	e8 d0 fe ff ff       	call   f010026f <cons_putc>
		cons_putc(' ');
f010039f:	b8 20 00 00 00       	mov    $0x20,%eax
f01003a4:	e8 c6 fe ff ff       	call   f010026f <cons_putc>
		cons_putc(' ');
f01003a9:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ae:	e8 bc fe ff ff       	call   f010026f <cons_putc>
f01003b3:	eb 1d                	jmp    f01003d2 <cons_putc+0x163>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003b5:	0f b7 05 90 93 1b f0 	movzwl 0xf01b9390,%eax
f01003bc:	0f b7 c8             	movzwl %ax,%ecx
f01003bf:	8b 15 8c 93 1b f0    	mov    0xf01b938c,%edx
f01003c5:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f01003c9:	83 c0 01             	add    $0x1,%eax
f01003cc:	66 a3 90 93 1b f0    	mov    %ax,0xf01b9390
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01003d2:	66 81 3d 90 93 1b f0 	cmpw   $0x7cf,0xf01b9390
f01003d9:	cf 07 
f01003db:	76 45                	jbe    f0100422 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01003dd:	8b 15 8c 93 1b f0    	mov    0xf01b938c,%edx
f01003e3:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01003ea:	00 
f01003eb:	8d 82 a0 00 00 00    	lea    0xa0(%edx),%eax
f01003f1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01003f5:	89 14 24             	mov    %edx,(%esp)
f01003f8:	e8 8b 92 00 00       	call   f0109688 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01003fd:	8b 15 8c 93 1b f0    	mov    0xf01b938c,%edx
f0100403:	b8 00 00 00 00       	mov    $0x0,%eax
f0100408:	66 c7 84 42 00 0f 00 	movw   $0x720,0xf00(%edx,%eax,2)
f010040f:	00 20 07 
f0100412:	83 c0 01             	add    $0x1,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100415:	83 f8 50             	cmp    $0x50,%eax
f0100418:	75 ee                	jne    f0100408 <cons_putc+0x199>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010041a:	66 83 2d 90 93 1b f0 	subw   $0x50,0xf01b9390
f0100421:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100422:	8b 35 88 93 1b f0    	mov    0xf01b9388,%esi
f0100428:	89 f3                	mov    %esi,%ebx
f010042a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010042f:	89 f2                	mov    %esi,%edx
f0100431:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100432:	0f b7 0d 90 93 1b f0 	movzwl 0xf01b9390,%ecx
f0100439:	83 c6 01             	add    $0x1,%esi
f010043c:	89 c8                	mov    %ecx,%eax
f010043e:	66 c1 e8 08          	shr    $0x8,%ax
f0100442:	89 f2                	mov    %esi,%edx
f0100444:	ee                   	out    %al,(%dx)
f0100445:	b8 0f 00 00 00       	mov    $0xf,%eax
f010044a:	89 da                	mov    %ebx,%edx
f010044c:	ee                   	out    %al,(%dx)
f010044d:	89 c8                	mov    %ecx,%eax
f010044f:	89 f2                	mov    %esi,%edx
f0100451:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100452:	83 c4 0c             	add    $0xc,%esp
f0100455:	5b                   	pop    %ebx
f0100456:	5e                   	pop    %esi
f0100457:	5f                   	pop    %edi
f0100458:	5d                   	pop    %ebp
f0100459:	c3                   	ret    

f010045a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010045a:	55                   	push   %ebp
f010045b:	89 e5                	mov    %esp,%ebp
f010045d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100460:	8b 45 08             	mov    0x8(%ebp),%eax
f0100463:	e8 07 fe ff ff       	call   f010026f <cons_putc>
}
f0100468:	c9                   	leave  
f0100469:	c3                   	ret    

f010046a <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010046a:	55                   	push   %ebp
f010046b:	89 e5                	mov    %esp,%ebp
f010046d:	57                   	push   %edi
f010046e:	56                   	push   %esi
f010046f:	53                   	push   %ebx
f0100470:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100473:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010047a:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100481:	5a a5 
	if (*cp != 0xA55A) {
f0100483:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010048a:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010048e:	74 11                	je     f01004a1 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100490:	c7 05 88 93 1b f0 b4 	movl   $0x3b4,0xf01b9388
f0100497:	03 00 00 
f010049a:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010049f:	eb 16                	jmp    f01004b7 <cons_init+0x4d>
	} else {
		*cp = was;
f01004a1:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01004a8:	c7 05 88 93 1b f0 d4 	movl   $0x3d4,0xf01b9388
f01004af:	03 00 00 
f01004b2:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f01004b7:	8b 1d 88 93 1b f0    	mov    0xf01b9388,%ebx
f01004bd:	89 d9                	mov    %ebx,%ecx
f01004bf:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004c4:	89 da                	mov    %ebx,%edx
f01004c6:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01004c7:	8d 7b 01             	lea    0x1(%ebx),%edi

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004ca:	89 fa                	mov    %edi,%edx
f01004cc:	ec                   	in     (%dx),%al
f01004cd:	0f b6 c0             	movzbl %al,%eax
f01004d0:	89 c3                	mov    %eax,%ebx
f01004d2:	c1 e3 08             	shl    $0x8,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004d5:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004da:	89 ca                	mov    %ecx,%edx
f01004dc:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004dd:	89 fa                	mov    %edi,%edx
f01004df:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01004e0:	89 35 8c 93 1b f0    	mov    %esi,0xf01b938c
	crt_pos = pos;
f01004e6:	0f b6 c0             	movzbl %al,%eax
f01004e9:	09 d8                	or     %ebx,%eax
f01004eb:	66 a3 90 93 1b f0    	mov    %ax,0xf01b9390

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f01004f1:	e8 ea fc ff ff       	call   f01001e0 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01004f6:	0f b7 05 58 e3 12 f0 	movzwl 0xf012e358,%eax
f01004fd:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100502:	89 04 24             	mov    %eax,(%esp)
f0100505:	e8 96 33 00 00       	call   f01038a0 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010050a:	b8 00 00 00 00       	mov    $0x0,%eax
f010050f:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100514:	89 da                	mov    %ebx,%edx
f0100516:	ee                   	out    %al,(%dx)
f0100517:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010051c:	b2 fb                	mov    $0xfb,%dl
f010051e:	ee                   	out    %al,(%dx)
f010051f:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100524:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100529:	89 ca                	mov    %ecx,%edx
f010052b:	ee                   	out    %al,(%dx)
f010052c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100531:	b2 f9                	mov    $0xf9,%dl
f0100533:	ee                   	out    %al,(%dx)
f0100534:	b8 03 00 00 00       	mov    $0x3,%eax
f0100539:	b2 fb                	mov    $0xfb,%dl
f010053b:	ee                   	out    %al,(%dx)
f010053c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100541:	b2 fc                	mov    $0xfc,%dl
f0100543:	ee                   	out    %al,(%dx)
f0100544:	b8 01 00 00 00       	mov    $0x1,%eax
f0100549:	b2 f9                	mov    $0xf9,%dl
f010054b:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010054c:	b2 fd                	mov    $0xfd,%dl
f010054e:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010054f:	3c ff                	cmp    $0xff,%al
f0100551:	0f 95 c0             	setne  %al
f0100554:	0f b6 f0             	movzbl %al,%esi
f0100557:	89 35 84 93 1b f0    	mov    %esi,0xf01b9384
f010055d:	89 da                	mov    %ebx,%edx
f010055f:	ec                   	in     (%dx),%al
f0100560:	89 ca                	mov    %ecx,%edx
f0100562:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100563:	85 f6                	test   %esi,%esi
f0100565:	75 0c                	jne    f0100573 <cons_init+0x109>
		cprintf("Serial port does not exist!\n");
f0100567:	c7 04 24 2d 9f 10 f0 	movl   $0xf0109f2d,(%esp)
f010056e:	e8 64 34 00 00       	call   f01039d7 <cprintf>
}
f0100573:	83 c4 0c             	add    $0xc,%esp
f0100576:	5b                   	pop    %ebx
f0100577:	5e                   	pop    %esi
f0100578:	5f                   	pop    %edi
f0100579:	5d                   	pop    %ebp
f010057a:	c3                   	ret    

f010057b <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010057b:	55                   	push   %ebp
f010057c:	89 e5                	mov    %esp,%ebp
f010057e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100583:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100584:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100589:	a8 01                	test   $0x1,%al
f010058b:	74 09                	je     f0100596 <serial_proc_data+0x1b>
f010058d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100592:	ec                   	in     (%dx),%al
	return data;
f0100593:	0f b6 d0             	movzbl %al,%edx
		return -1;
	return inb(COM1+COM_RX);
}
f0100596:	89 d0                	mov    %edx,%eax
f0100598:	5d                   	pop    %ebp
f0100599:	c3                   	ret    

f010059a <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010059a:	55                   	push   %ebp
f010059b:	89 e5                	mov    %esp,%ebp
f010059d:	53                   	push   %ebx
f010059e:	83 ec 04             	sub    $0x4,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005a1:	ba 64 00 00 00       	mov    $0x64,%edx
f01005a6:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01005a7:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01005ac:	a8 01                	test   $0x1,%al
f01005ae:	0f 84 d9 00 00 00    	je     f010068d <kbd_proc_data+0xf3>
f01005b4:	ba 60 00 00 00       	mov    $0x60,%edx
f01005b9:	ec                   	in     (%dx),%al
f01005ba:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01005bc:	3c e0                	cmp    $0xe0,%al
f01005be:	75 11                	jne    f01005d1 <kbd_proc_data+0x37>
		// E0 escape character
		shift |= E0ESC;
f01005c0:	83 0d 80 93 1b f0 40 	orl    $0x40,0xf01b9380
f01005c7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01005cc:	e9 bc 00 00 00       	jmp    f010068d <kbd_proc_data+0xf3>
		return 0;
	} else if (data & 0x80) {
f01005d1:	84 c0                	test   %al,%al
f01005d3:	79 31                	jns    f0100606 <kbd_proc_data+0x6c>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01005d5:	8b 0d 80 93 1b f0    	mov    0xf01b9380,%ecx
f01005db:	f6 c1 40             	test   $0x40,%cl
f01005de:	75 03                	jne    f01005e3 <kbd_proc_data+0x49>
f01005e0:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01005e3:	0f b6 c2             	movzbl %dl,%eax
f01005e6:	0f b6 80 60 9f 10 f0 	movzbl -0xfef60a0(%eax),%eax
f01005ed:	83 c8 40             	or     $0x40,%eax
f01005f0:	0f b6 c0             	movzbl %al,%eax
f01005f3:	f7 d0                	not    %eax
f01005f5:	21 c8                	and    %ecx,%eax
f01005f7:	a3 80 93 1b f0       	mov    %eax,0xf01b9380
f01005fc:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100601:	e9 87 00 00 00       	jmp    f010068d <kbd_proc_data+0xf3>
		return 0;
	} else if (shift & E0ESC) {
f0100606:	a1 80 93 1b f0       	mov    0xf01b9380,%eax
f010060b:	a8 40                	test   $0x40,%al
f010060d:	74 0b                	je     f010061a <kbd_proc_data+0x80>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010060f:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f0100612:	83 e0 bf             	and    $0xffffffbf,%eax
f0100615:	a3 80 93 1b f0       	mov    %eax,0xf01b9380
	}

	shift |= shiftcode[data];
f010061a:	0f b6 ca             	movzbl %dl,%ecx
	shift ^= togglecode[data];
f010061d:	0f b6 81 60 9f 10 f0 	movzbl -0xfef60a0(%ecx),%eax
f0100624:	0b 05 80 93 1b f0    	or     0xf01b9380,%eax
f010062a:	0f b6 91 60 a0 10 f0 	movzbl -0xfef5fa0(%ecx),%edx
f0100631:	31 c2                	xor    %eax,%edx
f0100633:	89 15 80 93 1b f0    	mov    %edx,0xf01b9380

	c = charcode[shift & (CTL | SHIFT)][data];
f0100639:	89 d0                	mov    %edx,%eax
f010063b:	83 e0 03             	and    $0x3,%eax
f010063e:	8b 04 85 60 a1 10 f0 	mov    -0xfef5ea0(,%eax,4),%eax
f0100645:	0f b6 1c 08          	movzbl (%eax,%ecx,1),%ebx
	if (shift & CAPSLOCK) {
f0100649:	f6 c2 08             	test   $0x8,%dl
f010064c:	74 18                	je     f0100666 <kbd_proc_data+0xcc>
		if ('a' <= c && c <= 'z')
f010064e:	8d 43 9f             	lea    -0x61(%ebx),%eax
f0100651:	83 f8 19             	cmp    $0x19,%eax
f0100654:	77 05                	ja     f010065b <kbd_proc_data+0xc1>
			c += 'A' - 'a';
f0100656:	83 eb 20             	sub    $0x20,%ebx
f0100659:	eb 0b                	jmp    f0100666 <kbd_proc_data+0xcc>
		else if ('A' <= c && c <= 'Z')
f010065b:	8d 43 bf             	lea    -0x41(%ebx),%eax
f010065e:	83 f8 19             	cmp    $0x19,%eax
f0100661:	77 03                	ja     f0100666 <kbd_proc_data+0xcc>
			c += 'a' - 'A';
f0100663:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100666:	89 d0                	mov    %edx,%eax
f0100668:	f7 d0                	not    %eax
f010066a:	a8 06                	test   $0x6,%al
f010066c:	75 1f                	jne    f010068d <kbd_proc_data+0xf3>
f010066e:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100674:	75 17                	jne    f010068d <kbd_proc_data+0xf3>
		cprintf("Rebooting!\n");
f0100676:	c7 04 24 4a 9f 10 f0 	movl   $0xf0109f4a,(%esp)
f010067d:	e8 55 33 00 00       	call   f01039d7 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100682:	b8 03 00 00 00       	mov    $0x3,%eax
f0100687:	ba 92 00 00 00       	mov    $0x92,%edx
f010068c:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010068d:	89 d8                	mov    %ebx,%eax
f010068f:	83 c4 04             	add    $0x4,%esp
f0100692:	5b                   	pop    %ebx
f0100693:	5d                   	pop    %ebp
f0100694:	c3                   	ret    
	...

f01006a0 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f01006a0:	55                   	push   %ebp
f01006a1:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f01006a3:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f01006a6:	5d                   	pop    %ebp
f01006a7:	c3                   	ret    

f01006a8 <getva>:
        }while(ebp!=0);
	return 0;
}
uint32_t
getva(char *vastring,int base)
{
f01006a8:	55                   	push   %ebp
f01006a9:	89 e5                	mov    %esp,%ebp
f01006ab:	57                   	push   %edi
f01006ac:	56                   	push   %esi
f01006ad:	53                   	push   %ebx
f01006ae:	83 ec 0c             	sub    $0xc,%esp
f01006b1:	8b 7d 08             	mov    0x8(%ebp),%edi
f01006b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	uint32_t va=0;
	int i,length=0;
	if(vastring){
f01006b7:	85 ff                	test   %edi,%edi
f01006b9:	0f 84 20 01 00 00    	je     f01007df <getva+0x137>
		for(length=0;vastring[length]!='\0';length++);
f01006bf:	0f b6 17             	movzbl (%edi),%edx
f01006c2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006c7:	84 d2                	test   %dl,%dl
f01006c9:	74 0e                	je     f01006d9 <getva+0x31>
f01006cb:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006d0:	83 c3 01             	add    $0x1,%ebx
f01006d3:	80 3c 3b 00          	cmpb   $0x0,(%ebx,%edi,1)
f01006d7:	75 f7                	jne    f01006d0 <getva+0x28>
		//cprintf("vastring[0]=%c vastring[1]=%c length=%d\n",vastring[0],vastring[1],length);
		if(base==16){
f01006d9:	83 f8 10             	cmp    $0x10,%eax
f01006dc:	0f 85 99 00 00 00    	jne    f010077b <getva+0xd3>
			if(vastring[0]!='0'||vastring[1]!='x'||(length>10)){
f01006e2:	80 fa 30             	cmp    $0x30,%dl
f01006e5:	75 26                	jne    f010070d <getva+0x65>
f01006e7:	80 7f 01 78          	cmpb   $0x78,0x1(%edi)
f01006eb:	90                   	nop    
f01006ec:	8d 74 26 00          	lea    0x0(%esi),%esi
f01006f0:	75 1b                	jne    f010070d <getva+0x65>
f01006f2:	83 fb 0a             	cmp    $0xa,%ebx
f01006f5:	7f 16                	jg     f010070d <getva+0x65>
				cprintf("Virtual Address is not hex!\n");
				return 0;
f01006f7:	be 00 00 00 00       	mov    $0x0,%esi
f01006fc:	c7 45 f0 02 00 00 00 	movl   $0x2,-0x10(%ebp)
			}
		
			for(i=2;i<length;i++){
f0100703:	83 fb 02             	cmp    $0x2,%ebx
f0100706:	7f 1b                	jg     f0100723 <getva+0x7b>
f0100708:	e9 e5 00 00 00       	jmp    f01007f2 <getva+0x14a>
	if(vastring){
		for(length=0;vastring[length]!='\0';length++);
		//cprintf("vastring[0]=%c vastring[1]=%c length=%d\n",vastring[0],vastring[1],length);
		if(base==16){
			if(vastring[0]!='0'||vastring[1]!='x'||(length>10)){
				cprintf("Virtual Address is not hex!\n");
f010070d:	c7 04 24 70 a1 10 f0 	movl   $0xf010a170,(%esp)
f0100714:	e8 be 32 00 00       	call   f01039d7 <cprintf>
f0100719:	be 00 00 00 00       	mov    $0x0,%esi
f010071e:	e9 d4 00 00 00       	jmp    f01007f7 <getva+0x14f>
				return 0;
			}
		
			for(i=2;i<length;i++){
				if(vastring[i]>='0'&&vastring[i]<='9')
f0100723:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100726:	0f b6 14 38          	movzbl (%eax,%edi,1),%edx
f010072a:	89 d1                	mov    %edx,%ecx
f010072c:	8d 42 d0             	lea    -0x30(%edx),%eax
f010072f:	3c 09                	cmp    $0x9,%al
f0100731:	77 0e                	ja     f0100741 <getva+0x99>
					va=vastring[i]-'0'+va*base;
f0100733:	0f be d2             	movsbl %dl,%edx
f0100736:	89 f0                	mov    %esi,%eax
f0100738:	c1 e0 04             	shl    $0x4,%eax
f010073b:	8d 74 02 d0          	lea    -0x30(%edx,%eax,1),%esi
f010073f:	eb 2b                	jmp    f010076c <getva+0xc4>
				else if(vastring[i]>='a'&&vastring[i]<='f')
f0100741:	8d 41 9f             	lea    -0x61(%ecx),%eax
f0100744:	3c 05                	cmp    $0x5,%al
f0100746:	77 0e                	ja     f0100756 <getva+0xae>
					va=vastring[i]-'a'+10+va*base;
f0100748:	0f be d2             	movsbl %dl,%edx
f010074b:	89 f0                	mov    %esi,%eax
f010074d:	c1 e0 04             	shl    $0x4,%eax
f0100750:	8d 74 02 a9          	lea    -0x57(%edx,%eax,1),%esi
f0100754:	eb 16                	jmp    f010076c <getva+0xc4>
				else{
					cprintf("Virtual Address is bad!\n");
f0100756:	c7 04 24 8d a1 10 f0 	movl   $0xf010a18d,(%esp)
f010075d:	e8 75 32 00 00       	call   f01039d7 <cprintf>
f0100762:	be 00 00 00 00       	mov    $0x0,%esi
f0100767:	e9 8b 00 00 00       	jmp    f01007f7 <getva+0x14f>
			if(vastring[0]!='0'||vastring[1]!='x'||(length>10)){
				cprintf("Virtual Address is not hex!\n");
				return 0;
			}
		
			for(i=2;i<length;i++){
f010076c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f0100770:	39 5d f0             	cmp    %ebx,-0x10(%ebp)
f0100773:	0f 84 7e 00 00 00    	je     f01007f7 <getva+0x14f>
f0100779:	eb a8                	jmp    f0100723 <getva+0x7b>
					va=0;
					break;
				}
			}
		}
		else if(base==10){
f010077b:	83 f8 0a             	cmp    $0xa,%eax
f010077e:	66 90                	xchg   %ax,%ax
f0100780:	75 4a                	jne    f01007cc <getva+0x124>
			 for(i=0;i<length;i++){
f0100782:	85 db                	test   %ebx,%ebx
f0100784:	7f 33                	jg     f01007b9 <getva+0x111>
f0100786:	eb 6a                	jmp    f01007f2 <getva+0x14a>
                                if(vastring[i]>='0'&&vastring[i]<='9')
f0100788:	0f b6 14 39          	movzbl (%ecx,%edi,1),%edx
f010078c:	8d 42 d0             	lea    -0x30(%edx),%eax
f010078f:	3c 09                	cmp    $0x9,%al
f0100791:	77 13                	ja     f01007a6 <getva+0xfe>
                                        va=vastring[i]-'0'+va*base;
f0100793:	0f be d2             	movsbl %dl,%edx
f0100796:	8d 04 b6             	lea    (%esi,%esi,4),%eax
f0100799:	8d 74 42 d0          	lea    -0x30(%edx,%eax,2),%esi
					break;
				}
			}
		}
		else if(base==10){
			 for(i=0;i<length;i++){
f010079d:	83 c1 01             	add    $0x1,%ecx
f01007a0:	39 d9                	cmp    %ebx,%ecx
f01007a2:	75 e4                	jne    f0100788 <getva+0xe0>
f01007a4:	eb 51                	jmp    f01007f7 <getva+0x14f>
                                if(vastring[i]>='0'&&vastring[i]<='9')
                                        va=vastring[i]-'0'+va*base;
                                else{
                                        cprintf("The number string is bad!\n");
f01007a6:	c7 04 24 a6 a1 10 f0 	movl   $0xf010a1a6,(%esp)
f01007ad:	e8 25 32 00 00       	call   f01039d7 <cprintf>
f01007b2:	be 00 00 00 00       	mov    $0x0,%esi
f01007b7:	eb 3e                	jmp    f01007f7 <getva+0x14f>
				}
			}
		}
		else if(base==10){
			 for(i=0;i<length;i++){
                                if(vastring[i]>='0'&&vastring[i]<='9')
f01007b9:	8d 42 d0             	lea    -0x30(%edx),%eax
f01007bc:	be 00 00 00 00       	mov    $0x0,%esi
f01007c1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01007c6:	3c 09                	cmp    $0x9,%al
f01007c8:	76 c9                	jbe    f0100793 <getva+0xeb>
f01007ca:	eb da                	jmp    f01007a6 <getva+0xfe>
                                        va=0;
                                        break;
                                }
			}
		}
		else cprintf("Can not handdle\n");	
f01007cc:	c7 04 24 c1 a1 10 f0 	movl   $0xf010a1c1,(%esp)
f01007d3:	e8 ff 31 00 00       	call   f01039d7 <cprintf>
f01007d8:	be 00 00 00 00       	mov    $0x0,%esi
f01007dd:	eb 18                	jmp    f01007f7 <getva+0x14f>
	}
	else{
		cprintf("Virtual Address is NULL!\n");
f01007df:	c7 04 24 d2 a1 10 f0 	movl   $0xf010a1d2,(%esp)
f01007e6:	e8 ec 31 00 00       	call   f01039d7 <cprintf>
f01007eb:	be 00 00 00 00       	mov    $0x0,%esi
f01007f0:	eb 05                	jmp    f01007f7 <getva+0x14f>
f01007f2:	be 00 00 00 00       	mov    $0x0,%esi
	}
	return va;
}
f01007f7:	89 f0                	mov    %esi,%eax
f01007f9:	83 c4 0c             	add    $0xc,%esp
f01007fc:	5b                   	pop    %ebx
f01007fd:	5e                   	pop    %esi
f01007fe:	5f                   	pop    %edi
f01007ff:	5d                   	pop    %ebp
f0100800:	c3                   	ret    

f0100801 <mon_dumpx>:
	return 0;
}

int
mon_dumpx(int argc, char **argv, struct Trapframe *tf)
{
f0100801:	55                   	push   %ebp
f0100802:	89 e5                	mov    %esp,%ebp
f0100804:	57                   	push   %edi
f0100805:	56                   	push   %esi
f0100806:	53                   	push   %ebx
f0100807:	83 ec 0c             	sub    $0xc,%esp
f010080a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	uint32_t a,*content;
	int i,n;
	if(argc<3)
f010080d:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100811:	7f 0e                	jg     f0100821 <mon_dumpx+0x20>
        {
                cprintf("Command argument is illegle!\n");
f0100813:	c7 04 24 ec a1 10 f0 	movl   $0xf010a1ec,(%esp)
f010081a:	e8 b8 31 00 00       	call   f01039d7 <cprintf>
f010081f:	eb 59                	jmp    f010087a <mon_dumpx+0x79>
                return 0;
        }
	n=(int)getva(argv[1],10);
f0100821:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
f0100828:	00 
f0100829:	8b 43 04             	mov    0x4(%ebx),%eax
f010082c:	89 04 24             	mov    %eax,(%esp)
f010082f:	e8 74 fe ff ff       	call   f01006a8 <getva>
f0100834:	89 c7                	mov    %eax,%edi
	a=getva(argv[2],16);
f0100836:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f010083d:	00 
f010083e:	8b 43 08             	mov    0x8(%ebx),%eax
f0100841:	89 04 24             	mov    %eax,(%esp)
f0100844:	e8 5f fe ff ff       	call   f01006a8 <getva>
f0100849:	89 c6                	mov    %eax,%esi
	content=(uint32_t *)a;
	for(i=0;i<n;i++)
f010084b:	85 ff                	test   %edi,%edi
f010084d:	7e 1f                	jle    f010086e <mon_dumpx+0x6d>
f010084f:	bb 00 00 00 00       	mov    $0x0,%ebx
		cprintf("%x ",*(content+i));
f0100854:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
f0100857:	89 44 24 04          	mov    %eax,0x4(%esp)
f010085b:	c7 04 24 0a a2 10 f0 	movl   $0xf010a20a,(%esp)
f0100862:	e8 70 31 00 00       	call   f01039d7 <cprintf>
                return 0;
        }
	n=(int)getva(argv[1],10);
	a=getva(argv[2],16);
	content=(uint32_t *)a;
	for(i=0;i<n;i++)
f0100867:	83 c3 01             	add    $0x1,%ebx
f010086a:	39 df                	cmp    %ebx,%edi
f010086c:	75 e6                	jne    f0100854 <mon_dumpx+0x53>
		cprintf("%x ",*(content+i));
	cprintf("\n");
f010086e:	c7 04 24 c9 a2 10 f0 	movl   $0xf010a2c9,(%esp)
f0100875:	e8 5d 31 00 00       	call   f01039d7 <cprintf>
	return 0;
}
f010087a:	b8 00 00 00 00       	mov    $0x0,%eax
f010087f:	83 c4 0c             	add    $0xc,%esp
f0100882:	5b                   	pop    %ebx
f0100883:	5e                   	pop    %esi
f0100884:	5f                   	pop    %edi
f0100885:	5d                   	pop    %ebp
f0100886:	c3                   	ret    

f0100887 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100887:	55                   	push   %ebp
f0100888:	89 e5                	mov    %esp,%ebp
f010088a:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010088d:	c7 04 24 0e a2 10 f0 	movl   $0xf010a20e,(%esp)
f0100894:	e8 3e 31 00 00       	call   f01039d7 <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f0100899:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01008a0:	00 
f01008a1:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01008a8:	f0 
f01008a9:	c7 04 24 80 a3 10 f0 	movl   $0xf010a380,(%esp)
f01008b0:	e8 22 31 00 00       	call   f01039d7 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01008b5:	c7 44 24 08 e0 9e 10 	movl   $0x109ee0,0x8(%esp)
f01008bc:	00 
f01008bd:	c7 44 24 04 e0 9e 10 	movl   $0xf0109ee0,0x4(%esp)
f01008c4:	f0 
f01008c5:	c7 04 24 a4 a3 10 f0 	movl   $0xf010a3a4,(%esp)
f01008cc:	e8 06 31 00 00       	call   f01039d7 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01008d1:	c7 44 24 08 5d 93 1b 	movl   $0x1b935d,0x8(%esp)
f01008d8:	00 
f01008d9:	c7 44 24 04 5d 93 1b 	movl   $0xf01b935d,0x4(%esp)
f01008e0:	f0 
f01008e1:	c7 04 24 c8 a3 10 f0 	movl   $0xf010a3c8,(%esp)
f01008e8:	e8 ea 30 00 00       	call   f01039d7 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01008ed:	c7 44 24 08 70 a5 1b 	movl   $0x1ba570,0x8(%esp)
f01008f4:	00 
f01008f5:	c7 44 24 04 70 a5 1b 	movl   $0xf01ba570,0x4(%esp)
f01008fc:	f0 
f01008fd:	c7 04 24 ec a3 10 f0 	movl   $0xf010a3ec,(%esp)
f0100904:	e8 ce 30 00 00       	call   f01039d7 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100909:	ba 6f a9 1b f0       	mov    $0xf01ba96f,%edx
f010090e:	81 ea 0c 00 10 f0    	sub    $0xf010000c,%edx
f0100914:	89 d0                	mov    %edx,%eax
f0100916:	c1 f8 1f             	sar    $0x1f,%eax
f0100919:	c1 e8 16             	shr    $0x16,%eax
f010091c:	01 d0                	add    %edx,%eax
f010091e:	c1 f8 0a             	sar    $0xa,%eax
f0100921:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100925:	c7 04 24 10 a4 10 f0 	movl   $0xf010a410,(%esp)
f010092c:	e8 a6 30 00 00       	call   f01039d7 <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
f0100931:	b8 00 00 00 00       	mov    $0x0,%eax
f0100936:	c9                   	leave  
f0100937:	c3                   	ret    

f0100938 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100938:	55                   	push   %ebp
f0100939:	89 e5                	mov    %esp,%ebp
f010093b:	53                   	push   %ebx
f010093c:	83 ec 14             	sub    $0x14,%esp
f010093f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100944:	8b 83 a4 a7 10 f0    	mov    -0xfef585c(%ebx),%eax
f010094a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010094e:	8b 83 a0 a7 10 f0    	mov    -0xfef5860(%ebx),%eax
f0100954:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100958:	c7 04 24 27 a2 10 f0 	movl   $0xf010a227,(%esp)
f010095f:	e8 73 30 00 00       	call   f01039d7 <cprintf>
f0100964:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100967:	83 fb 6c             	cmp    $0x6c,%ebx
f010096a:	75 d8                	jne    f0100944 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f010096c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100971:	83 c4 14             	add    $0x14,%esp
f0100974:	5b                   	pop    %ebx
f0100975:	5d                   	pop    %ebp
f0100976:	c3                   	ret    

f0100977 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100977:	55                   	push   %ebp
f0100978:	89 e5                	mov    %esp,%ebp
f010097a:	57                   	push   %edi
f010097b:	56                   	push   %esi
f010097c:	53                   	push   %ebx
f010097d:	83 ec 4c             	sub    $0x4c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100980:	c7 04 24 3c a4 10 f0 	movl   $0xf010a43c,(%esp)
f0100987:	e8 4b 30 00 00       	call   f01039d7 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010098c:	c7 04 24 60 a4 10 f0 	movl   $0xf010a460,(%esp)
f0100993:	e8 3f 30 00 00       	call   f01039d7 <cprintf>

	if (tf != NULL)
f0100998:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010099c:	74 0b                	je     f01009a9 <monitor+0x32>
		print_trapframe(tf);
f010099e:	8b 45 08             	mov    0x8(%ebp),%eax
f01009a1:	89 04 24             	mov    %eax,(%esp)
f01009a4:	e8 95 32 00 00       	call   f0103c3e <print_trapframe>

	while (1) {
		buf = readline("K> ");
f01009a9:	c7 04 24 30 a2 10 f0 	movl   $0xf010a230,(%esp)
f01009b0:	e8 9b 89 00 00       	call   f0109350 <readline>
f01009b5:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009b7:	85 c0                	test   %eax,%eax
f01009b9:	74 ee                	je     f01009a9 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009bb:	c7 45 b4 00 00 00 00 	movl   $0x0,-0x4c(%ebp)
f01009c2:	bf 00 00 00 00       	mov    $0x0,%edi
f01009c7:	eb 06                	jmp    f01009cf <monitor+0x58>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01009c9:	c6 03 00             	movb   $0x0,(%ebx)
f01009cc:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01009cf:	0f b6 03             	movzbl (%ebx),%eax
f01009d2:	84 c0                	test   %al,%al
f01009d4:	74 6a                	je     f0100a40 <monitor+0xc9>
f01009d6:	0f be c0             	movsbl %al,%eax
f01009d9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009dd:	c7 04 24 34 a2 10 f0 	movl   $0xf010a234,(%esp)
f01009e4:	e8 ee 8b 00 00       	call   f01095d7 <strchr>
f01009e9:	85 c0                	test   %eax,%eax
f01009eb:	75 dc                	jne    f01009c9 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f01009ed:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009f0:	74 4e                	je     f0100a40 <monitor+0xc9>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01009f2:	83 ff 0f             	cmp    $0xf,%edi
f01009f5:	75 16                	jne    f0100a0d <monitor+0x96>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009f7:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01009fe:	00 
f01009ff:	c7 04 24 39 a2 10 f0 	movl   $0xf010a239,(%esp)
f0100a06:	e8 cc 2f 00 00       	call   f01039d7 <cprintf>
f0100a0b:	eb 9c                	jmp    f01009a9 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100a0d:	89 5c bd b4          	mov    %ebx,-0x4c(%ebp,%edi,4)
f0100a11:	83 c7 01             	add    $0x1,%edi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a14:	0f b6 03             	movzbl (%ebx),%eax
f0100a17:	84 c0                	test   %al,%al
f0100a19:	75 0c                	jne    f0100a27 <monitor+0xb0>
f0100a1b:	eb b2                	jmp    f01009cf <monitor+0x58>
			buf++;
f0100a1d:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a20:	0f b6 03             	movzbl (%ebx),%eax
f0100a23:	84 c0                	test   %al,%al
f0100a25:	74 a8                	je     f01009cf <monitor+0x58>
f0100a27:	0f be c0             	movsbl %al,%eax
f0100a2a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a2e:	c7 04 24 34 a2 10 f0 	movl   $0xf010a234,(%esp)
f0100a35:	e8 9d 8b 00 00       	call   f01095d7 <strchr>
f0100a3a:	85 c0                	test   %eax,%eax
f0100a3c:	74 df                	je     f0100a1d <monitor+0xa6>
f0100a3e:	eb 8f                	jmp    f01009cf <monitor+0x58>
			buf++;
	}
	argv[argc] = 0;
f0100a40:	c7 44 bd b4 00 00 00 	movl   $0x0,-0x4c(%ebp,%edi,4)
f0100a47:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a48:	85 ff                	test   %edi,%edi
f0100a4a:	0f 84 59 ff ff ff    	je     f01009a9 <monitor+0x32>
f0100a50:	be 00 00 00 00       	mov    $0x0,%esi
f0100a55:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a5a:	8b 83 a0 a7 10 f0    	mov    -0xfef5860(%ebx),%eax
f0100a60:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a64:	8b 45 b4             	mov    -0x4c(%ebp),%eax
f0100a67:	89 04 24             	mov    %eax,(%esp)
f0100a6a:	e8 f2 8a 00 00       	call   f0109561 <strcmp>
f0100a6f:	85 c0                	test   %eax,%eax
f0100a71:	75 25                	jne    f0100a98 <monitor+0x121>
			return commands[i].func(argc, argv, tf);
f0100a73:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100a76:	8b 55 08             	mov    0x8(%ebp),%edx
f0100a79:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100a7d:	8d 55 b4             	lea    -0x4c(%ebp),%edx
f0100a80:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a84:	89 3c 24             	mov    %edi,(%esp)
f0100a87:	ff 14 85 a8 a7 10 f0 	call   *-0xfef5858(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a8e:	85 c0                	test   %eax,%eax
f0100a90:	0f 89 13 ff ff ff    	jns    f01009a9 <monitor+0x32>
f0100a96:	eb 23                	jmp    f0100abb <monitor+0x144>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100a98:	83 c6 01             	add    $0x1,%esi
f0100a9b:	83 c3 0c             	add    $0xc,%ebx
f0100a9e:	83 fe 09             	cmp    $0x9,%esi
f0100aa1:	75 b7                	jne    f0100a5a <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100aa3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
f0100aa6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100aaa:	c7 04 24 56 a2 10 f0 	movl   $0xf010a256,(%esp)
f0100ab1:	e8 21 2f 00 00       	call   f01039d7 <cprintf>
f0100ab6:	e9 ee fe ff ff       	jmp    f01009a9 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100abb:	83 c4 4c             	add    $0x4c,%esp
f0100abe:	5b                   	pop    %ebx
f0100abf:	5e                   	pop    %esi
f0100ac0:	5f                   	pop    %edi
f0100ac1:	5d                   	pop    %ebp
f0100ac2:	c3                   	ret    

f0100ac3 <mon_stepi>:
	}
	return 0;
}
int 
mon_stepi(int argc, char **argv, struct Trapframe *tf)
{
f0100ac3:	55                   	push   %ebp
f0100ac4:	89 e5                	mov    %esp,%ebp
f0100ac6:	53                   	push   %ebx
f0100ac7:	83 ec 14             	sub    $0x14,%esp
	uint32_t retesp;
        struct Trapframe *tf1;
        retesp=tf->tf_regs.reg_oesp-0x20;//看看pushal指令做了什么，就知道为什么减0x20,
f0100aca:	8b 45 10             	mov    0x10(%ebp),%eax
f0100acd:	8b 58 0c             	mov    0xc(%eax),%ebx
f0100ad0:	83 eb 20             	sub    $0x20,%ebx
                                        //找到异常产生，进行现场保护后的内核栈栈顶指针
        //cprintf("edi=%x oldesp=%x ebp=%x\n",tf1->tf_regs.reg_edi,retesp,read_ebp());
        tf1=(struct Trapframe*)retesp;
	monitor_disas(tf1->tf_eip,1);
f0100ad3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0100ada:	00 
f0100adb:	8b 43 30             	mov    0x30(%ebx),%eax
f0100ade:	89 04 24             	mov    %eax,(%esp)
f0100ae1:	e8 a4 80 00 00       	call   f0108b8a <monitor_disas>

        //tf1->tf_eflags|=0x10000;//设置EFLAGS中的RF
        tf1->tf_eflags|=0x100;//设置EFLAGS中的TF
f0100ae6:	81 4b 38 00 01 00 00 	orl    $0x100,0x38(%ebx)
}
//LAB 3: add write esp here
static __inline void
write_esp(uint32_t esp)
{
        __asm __volatile("movl %0,%%esp" : : "r" (esp));
f0100aed:	89 dc                	mov    %ebx,%esp
        //print_trapframe(tf1);
        //cprintf("edi=%x oldesp=%x esp=%x\n",tf1->tf_regs.reg_edi,retesp,read_esp());
      	write_esp(retesp);//恢复栈顶指针
      	trapret();
f0100aef:	e8 3c 40 00 00       	call   f0104b30 <trapret>
      	return 0;
}
f0100af4:	b8 00 00 00 00       	mov    $0x0,%eax
f0100af9:	83 c4 14             	add    $0x14,%esp
f0100afc:	5b                   	pop    %ebx
f0100afd:	5d                   	pop    %ebp
f0100afe:	c3                   	ret    

f0100aff <mon_dumpxp>:
	cprintf("\n");
	return 0;
}
int
mon_dumpxp(int argc, char **argv, struct Trapframe *tf)
{
f0100aff:	55                   	push   %ebp
f0100b00:	89 e5                	mov    %esp,%ebp
f0100b02:	57                   	push   %edi
f0100b03:	56                   	push   %esi
f0100b04:	53                   	push   %ebx
f0100b05:	83 ec 1c             	sub    $0x1c,%esp
f0100b08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	uint32_t va,pa,*content;
        int i,n;
        if(argc<3)
f0100b0b:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100b0f:	7f 11                	jg     f0100b22 <mon_dumpxp+0x23>
        {
                cprintf("Command argument is illegle!\n");
f0100b11:	c7 04 24 ec a1 10 f0 	movl   $0xf010a1ec,(%esp)
f0100b18:	e8 ba 2e 00 00       	call   f01039d7 <cprintf>
f0100b1d:	e9 88 00 00 00       	jmp    f0100baa <mon_dumpxp+0xab>
                return 0;
        }
	n=(int)getva(argv[1],10);
f0100b22:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
f0100b29:	00 
f0100b2a:	8b 43 04             	mov    0x4(%ebx),%eax
f0100b2d:	89 04 24             	mov    %eax,(%esp)
f0100b30:	e8 73 fb ff ff       	call   f01006a8 <getva>
f0100b35:	89 c7                	mov    %eax,%edi
	pa = getva(argv[2],16);
f0100b37:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100b3e:	00 
f0100b3f:	8b 43 08             	mov    0x8(%ebx),%eax
f0100b42:	89 04 24             	mov    %eax,(%esp)
f0100b45:	e8 5e fb ff ff       	call   f01006a8 <getva>
f0100b4a:	89 c6                	mov    %eax,%esi
	va = (uint32_t)KADDR(pa);
f0100b4c:	c1 e8 0c             	shr    $0xc,%eax
f0100b4f:	3b 05 60 a5 1b f0    	cmp    0xf01ba560,%eax
f0100b55:	72 20                	jb     f0100b77 <mon_dumpxp+0x78>
f0100b57:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100b5b:	c7 44 24 08 88 a4 10 	movl   $0xf010a488,0x8(%esp)
f0100b62:	f0 
f0100b63:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
f0100b6a:	00 
f0100b6b:	c7 04 24 6c a2 10 f0 	movl   $0xf010a26c,(%esp)
f0100b72:	e8 0f f5 ff ff       	call   f0100086 <_panic>
	content=(uint32_t *)va;
	for(i=0;i<n;i++)
f0100b77:	85 ff                	test   %edi,%edi
f0100b79:	7e 23                	jle    f0100b9e <mon_dumpxp+0x9f>
f0100b7b:	bb 00 00 00 00       	mov    $0x0,%ebx
                cprintf("%x ",*(content+i));
f0100b80:	8b 84 9e 00 00 00 f0 	mov    -0x10000000(%esi,%ebx,4),%eax
f0100b87:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b8b:	c7 04 24 0a a2 10 f0 	movl   $0xf010a20a,(%esp)
f0100b92:	e8 40 2e 00 00       	call   f01039d7 <cprintf>
        }
	n=(int)getva(argv[1],10);
	pa = getva(argv[2],16);
	va = (uint32_t)KADDR(pa);
	content=(uint32_t *)va;
	for(i=0;i<n;i++)
f0100b97:	83 c3 01             	add    $0x1,%ebx
f0100b9a:	39 df                	cmp    %ebx,%edi
f0100b9c:	75 e2                	jne    f0100b80 <mon_dumpxp+0x81>
                cprintf("%x ",*(content+i));
        cprintf("\n");
f0100b9e:	c7 04 24 c9 a2 10 f0 	movl   $0xf010a2c9,(%esp)
f0100ba5:	e8 2d 2e 00 00       	call   f01039d7 <cprintf>
        return 0;
}
f0100baa:	b8 00 00 00 00       	mov    $0x0,%eax
f0100baf:	83 c4 1c             	add    $0x1c,%esp
f0100bb2:	5b                   	pop    %ebx
f0100bb3:	5e                   	pop    %esi
f0100bb4:	5f                   	pop    %edi
f0100bb5:	5d                   	pop    %ebp
f0100bb6:	c3                   	ret    

f0100bb7 <mon_permission>:
	}
	return 0;
}
int
mon_permission(int argc, char **argv, struct Trapframe *tf)
{
f0100bb7:	55                   	push   %ebp
f0100bb8:	89 e5                	mov    %esp,%ebp
f0100bba:	83 ec 28             	sub    $0x28,%esp
f0100bbd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100bc0:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100bc3:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0100bc6:	8b 75 0c             	mov    0xc(%ebp),%esi
	uint32_t a=0;
	int i;
	pte_t *pte;
	struct Page *onepage;
	char operator,pte_ch=0,pte_perm;
	if(argc<4)
f0100bc9:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100bcd:	7f 11                	jg     f0100be0 <mon_permission+0x29>
	{
		cprintf("Command argument is illegle!\n"); 
f0100bcf:	c7 04 24 ec a1 10 f0 	movl   $0xf010a1ec,(%esp)
f0100bd6:	e8 fc 2d 00 00       	call   f01039d7 <cprintf>
f0100bdb:	e9 63 01 00 00       	jmp    f0100d43 <mon_permission+0x18c>
		return 0;
	}
	a=getva(argv[2],16);
f0100be0:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100be7:	00 
f0100be8:	8b 46 08             	mov    0x8(%esi),%eax
f0100beb:	89 04 24             	mov    %eax,(%esp)
f0100bee:	e8 b5 fa ff ff       	call   f01006a8 <getva>
f0100bf3:	89 c3                	mov    %eax,%ebx
	operator=argv[1][0];
f0100bf5:	8b 46 04             	mov    0x4(%esi),%eax
f0100bf8:	0f b6 38             	movzbl (%eax),%edi
	if((onepage=page_lookup(boot_pgdir,(void *)a,&pte))){
f0100bfb:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0100bfe:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c02:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100c06:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f0100c0b:	89 04 24             	mov    %eax,(%esp)
f0100c0e:	e8 08 08 00 00       	call   f010141b <page_lookup>
f0100c13:	85 c0                	test   %eax,%eax
f0100c15:	0f 84 18 01 00 00    	je     f0100d33 <mon_permission+0x17c>
f0100c1b:	b9 03 00 00 00       	mov    $0x3,%ecx
f0100c20:	bb 00 00 00 00       	mov    $0x0,%ebx
		for(i=3;i<argc;i++)
		{
			pte_perm=argv[i][0];
f0100c25:	8b 14 8e             	mov    (%esi,%ecx,4),%edx
			switch(pte_perm){
f0100c28:	0f b6 02             	movzbl (%edx),%eax
f0100c2b:	83 e8 41             	sub    $0x41,%eax
f0100c2e:	3c 16                	cmp    $0x16,%al
f0100c30:	0f 87 86 00 00 00    	ja     f0100cbc <mon_permission+0x105>
f0100c36:	0f b6 c0             	movzbl %al,%eax
f0100c39:	ff 24 85 40 a7 10 f0 	jmp    *-0xfef58c0(,%eax,4)
				case 'P':
					 if((argv[i][1]!='\0')&&(argv[i][3]=='\0')){
f0100c40:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f0100c44:	84 c0                	test   %al,%al
f0100c46:	74 3f                	je     f0100c87 <mon_permission+0xd0>
f0100c48:	80 7a 03 00          	cmpb   $0x0,0x3(%edx)
f0100c4c:	75 3e                	jne    f0100c8c <mon_permission+0xd5>
                               			 if((argv[i][0]=='P')&&(argv[i][1]=='W')&&(argv[i][2]=='T'))
f0100c4e:	3c 57                	cmp    $0x57,%al
f0100c50:	75 10                	jne    f0100c62 <mon_permission+0xab>
f0100c52:	80 7a 02 54          	cmpb   $0x54,0x2(%edx)
f0100c56:	75 0a                	jne    f0100c62 <mon_permission+0xab>
                                        		 pte_ch|=PTE_PWT;
f0100c58:	83 cb 08             	or     $0x8,%ebx
f0100c5b:	90                   	nop    
f0100c5c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0100c60:	eb 6c                	jmp    f0100cce <mon_permission+0x117>
                               			 else if((argv[i][0]=='P')&&(argv[i][1]=='C')&&(argv[i][2]=='D'))
f0100c62:	3c 43                	cmp    $0x43,%al
f0100c64:	75 0c                	jne    f0100c72 <mon_permission+0xbb>
f0100c66:	80 7a 02 44          	cmpb   $0x44,0x2(%edx)
f0100c6a:	75 06                	jne    f0100c72 <mon_permission+0xbb>
                                        		 pte_ch|=PTE_PCD;
f0100c6c:	83 cb 10             	or     $0x10,%ebx
f0100c6f:	90                   	nop    
f0100c70:	eb 5c                	jmp    f0100cce <mon_permission+0x117>
                               			 else {cprintf("permission %s is not exist\n",argv[i]);return 0;}
f0100c72:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100c76:	c7 04 24 7b a2 10 f0 	movl   $0xf010a27b,(%esp)
f0100c7d:	e8 55 2d 00 00       	call   f01039d7 <cprintf>
f0100c82:	e9 bc 00 00 00       	jmp    f0100d43 <mon_permission+0x18c>
                       			 }
					else if(argv[i][1]=='\0')	pte_ch|=PTE_P;
f0100c87:	83 cb 01             	or     $0x1,%ebx
f0100c8a:	eb 42                	jmp    f0100cce <mon_permission+0x117>
					else {cprintf("permission %s is not exist\n",argv[i]);return 0;}
f0100c8c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100c90:	c7 04 24 7b a2 10 f0 	movl   $0xf010a27b,(%esp)
f0100c97:	e8 3b 2d 00 00       	call   f01039d7 <cprintf>
f0100c9c:	e9 a2 00 00 00       	jmp    f0100d43 <mon_permission+0x18c>
					break;
				case 'W':pte_ch|=PTE_W;break;
f0100ca1:	83 cb 02             	or     $0x2,%ebx
f0100ca4:	eb 28                	jmp    f0100cce <mon_permission+0x117>
				case 'U':pte_ch|=PTE_U;break;
f0100ca6:	83 cb 04             	or     $0x4,%ebx
f0100ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
f0100cb0:	eb 1c                	jmp    f0100cce <mon_permission+0x117>
				case 'D':pte_ch|=PTE_D;break;
f0100cb2:	83 cb 40             	or     $0x40,%ebx
f0100cb5:	eb 17                	jmp    f0100cce <mon_permission+0x117>
				case 'A':pte_ch|=PTE_A;break;
f0100cb7:	83 cb 20             	or     $0x20,%ebx
f0100cba:	eb 12                	jmp    f0100cce <mon_permission+0x117>
				default:
					cprintf("permission %s is not exist\n",argv[i]);
f0100cbc:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100cc0:	c7 04 24 7b a2 10 f0 	movl   $0xf010a27b,(%esp)
f0100cc7:	e8 0b 2d 00 00       	call   f01039d7 <cprintf>
f0100ccc:	eb 75                	jmp    f0100d43 <mon_permission+0x18c>
		return 0;
	}
	a=getva(argv[2],16);
	operator=argv[1][0];
	if((onepage=page_lookup(boot_pgdir,(void *)a,&pte))){
		for(i=3;i<argc;i++)
f0100cce:	83 c1 01             	add    $0x1,%ecx
f0100cd1:	3b 4d 08             	cmp    0x8(%ebp),%ecx
f0100cd4:	0f 85 4b ff ff ff    	jne    f0100c25 <mon_permission+0x6e>
				default:
					cprintf("permission %s is not exist\n",argv[i]);
					return 0;
			}
		}
		switch(operator){
f0100cda:	89 f8                	mov    %edi,%eax
f0100cdc:	3c 63                	cmp    $0x63,%al
f0100cde:	66 90                	xchg   %ax,%ax
f0100ce0:	74 0e                	je     f0100cf0 <mon_permission+0x139>
f0100ce2:	3c 73                	cmp    $0x73,%al
f0100ce4:	75 28                	jne    f0100d0e <mon_permission+0x157>
			case 's':
				*pte|=pte_ch;break;
f0100ce6:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100ce9:	0f be c3             	movsbl %bl,%eax
f0100cec:	09 02                	or     %eax,(%edx)
f0100cee:	eb 35                	jmp    f0100d25 <mon_permission+0x16e>
			case 'c':
				if(pte_ch&PTE_P)
f0100cf0:	0f be c3             	movsbl %bl,%eax
f0100cf3:	a8 01                	test   $0x1,%al
f0100cf5:	74 0e                	je     f0100d05 <mon_permission+0x14e>
					{cprintf("clearing PTE_P is denied\n");return 0;}
f0100cf7:	c7 04 24 97 a2 10 f0 	movl   $0xf010a297,(%esp)
f0100cfe:	e8 d4 2c 00 00       	call   f01039d7 <cprintf>
f0100d03:	eb 3e                	jmp    f0100d43 <mon_permission+0x18c>
				else
					{*pte&=(~pte_ch);break;}
f0100d05:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100d08:	f7 d0                	not    %eax
f0100d0a:	21 02                	and    %eax,(%edx)
f0100d0c:	eb 17                	jmp    f0100d25 <mon_permission+0x16e>
			default:
				cprintf("oprator %c is not setting or clearing permission\n",operator);
f0100d0e:	89 fa                	mov    %edi,%edx
f0100d10:	0f be c2             	movsbl %dl,%eax
f0100d13:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d17:	c7 04 24 ac a4 10 f0 	movl   $0xf010a4ac,(%esp)
f0100d1e:	e8 b4 2c 00 00       	call   f01039d7 <cprintf>
f0100d23:	eb 1e                	jmp    f0100d43 <mon_permission+0x18c>
				return 0;
		}
		cprintf("permission is changed successfully!\n");
f0100d25:	c7 04 24 e0 a4 10 f0 	movl   $0xf010a4e0,(%esp)
f0100d2c:	e8 a6 2c 00 00       	call   f01039d7 <cprintf>
f0100d31:	eb 10                	jmp    f0100d43 <mon_permission+0x18c>
	}
	else cprintf("this physical page corresponding to %x is not exiting\n",a);
f0100d33:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100d37:	c7 04 24 08 a5 10 f0 	movl   $0xf010a508,(%esp)
f0100d3e:	e8 94 2c 00 00       	call   f01039d7 <cprintf>
	return 0;
}
f0100d43:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d48:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0100d4b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0100d4e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0100d51:	89 ec                	mov    %ebp,%esp
f0100d53:	5d                   	pop    %ebp
f0100d54:	c3                   	ret    

f0100d55 <mon_showmappings>:
	}
	return va;
}
int
mon_showmappings(int argc,char **argv,struct Trapframe *tf)
{
f0100d55:	55                   	push   %ebp
f0100d56:	89 e5                	mov    %esp,%ebp
f0100d58:	57                   	push   %edi
f0100d59:	56                   	push   %esi
f0100d5a:	53                   	push   %ebx
f0100d5b:	83 ec 1c             	sub    $0x1c,%esp
	int i;
	uint32_t a,la;
	pte_t *pte;
	struct Page *onepage;
	physaddr_t physaddr;
	if(argc!=3)
f0100d5e:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100d62:	74 11                	je     f0100d75 <mon_showmappings+0x20>
	{
		cprintf("Command argument is illegle!\n"); 
f0100d64:	c7 04 24 ec a1 10 f0 	movl   $0xf010a1ec,(%esp)
f0100d6b:	e8 67 2c 00 00       	call   f01039d7 <cprintf>
f0100d70:	e9 6f 01 00 00       	jmp    f0100ee4 <mon_showmappings+0x18f>
		return 0;
	}
	//for(i=0;i<argc;i++){
	//	cprintf("%s\n",argv[i]);
	//}
	a=getva(argv[1],16);
f0100d75:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100d7c:	00 
f0100d7d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100d80:	8b 42 04             	mov    0x4(%edx),%eax
f0100d83:	89 04 24             	mov    %eax,(%esp)
f0100d86:	e8 1d f9 ff ff       	call   f01006a8 <getva>
f0100d8b:	89 c3                	mov    %eax,%ebx
	la=getva(argv[2],16);
f0100d8d:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100d94:	00 
f0100d95:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100d98:	8b 42 08             	mov    0x8(%edx),%eax
f0100d9b:	89 04 24             	mov    %eax,(%esp)
f0100d9e:	e8 05 f9 ff ff       	call   f01006a8 <getva>
f0100da3:	89 c6                	mov    %eax,%esi
	for(;;)
	{
		if((onepage=page_lookup(boot_pgdir,(void *)a,&pte))){
f0100da5:	8d 7d f0             	lea    -0x10(%ebp),%edi
f0100da8:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100dac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100db0:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f0100db5:	89 04 24             	mov    %eax,(%esp)
f0100db8:	e8 5e 06 00 00       	call   f010141b <page_lookup>
f0100dbd:	85 c0                	test   %eax,%eax
f0100dbf:	0f 84 00 01 00 00    	je     f0100ec5 <mon_showmappings+0x170>
			physaddr=page2pa(onepage);
			cprintf("virtual addr=%x page physaddr=%x permission: ",a,physaddr);
f0100dc5:	2b 05 6c a5 1b f0    	sub    0xf01ba56c,%eax
f0100dcb:	c1 f8 02             	sar    $0x2,%eax
f0100dce:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100dd4:	c1 e0 0c             	shl    $0xc,%eax
f0100dd7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ddb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ddf:	c7 04 24 40 a5 10 f0 	movl   $0xf010a540,(%esp)
f0100de6:	e8 ec 2b 00 00       	call   f01039d7 <cprintf>
			if((*pte)&PTE_D) cprintf("D ");
f0100deb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100dee:	f6 00 40             	testb  $0x40,(%eax)
f0100df1:	74 0e                	je     f0100e01 <mon_showmappings+0xac>
f0100df3:	c7 04 24 b9 a2 10 f0 	movl   $0xf010a2b9,(%esp)
f0100dfa:	e8 d8 2b 00 00       	call   f01039d7 <cprintf>
f0100dff:	eb 0c                	jmp    f0100e0d <mon_showmappings+0xb8>
			else cprintf("- ");
f0100e01:	c7 04 24 b1 a2 10 f0 	movl   $0xf010a2b1,(%esp)
f0100e08:	e8 ca 2b 00 00       	call   f01039d7 <cprintf>
			if(*pte&PTE_A) cprintf("A ");
f0100e0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100e10:	f6 00 20             	testb  $0x20,(%eax)
f0100e13:	74 0e                	je     f0100e23 <mon_showmappings+0xce>
f0100e15:	c7 04 24 b4 a2 10 f0 	movl   $0xf010a2b4,(%esp)
f0100e1c:	e8 b6 2b 00 00       	call   f01039d7 <cprintf>
f0100e21:	eb 0c                	jmp    f0100e2f <mon_showmappings+0xda>
                        else cprintf("- ");
f0100e23:	c7 04 24 b1 a2 10 f0 	movl   $0xf010a2b1,(%esp)
f0100e2a:	e8 a8 2b 00 00       	call   f01039d7 <cprintf>
			if(*pte&PTE_PCD) cprintf("PCD ");
f0100e2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100e32:	f6 00 10             	testb  $0x10,(%eax)
f0100e35:	74 0e                	je     f0100e45 <mon_showmappings+0xf0>
f0100e37:	c7 04 24 b7 a2 10 f0 	movl   $0xf010a2b7,(%esp)
f0100e3e:	e8 94 2b 00 00       	call   f01039d7 <cprintf>
f0100e43:	eb 0c                	jmp    f0100e51 <mon_showmappings+0xfc>
                        else cprintf("- ");
f0100e45:	c7 04 24 b1 a2 10 f0 	movl   $0xf010a2b1,(%esp)
f0100e4c:	e8 86 2b 00 00       	call   f01039d7 <cprintf>
			if(*pte&PTE_PWT) cprintf("PWT ");
f0100e51:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100e54:	f6 00 08             	testb  $0x8,(%eax)
f0100e57:	74 0e                	je     f0100e67 <mon_showmappings+0x112>
f0100e59:	c7 04 24 bc a2 10 f0 	movl   $0xf010a2bc,(%esp)
f0100e60:	e8 72 2b 00 00       	call   f01039d7 <cprintf>
f0100e65:	eb 0c                	jmp    f0100e73 <mon_showmappings+0x11e>
                        else cprintf("- ");
f0100e67:	c7 04 24 b1 a2 10 f0 	movl   $0xf010a2b1,(%esp)
f0100e6e:	e8 64 2b 00 00       	call   f01039d7 <cprintf>
			if(*pte&PTE_U) cprintf("U ");
f0100e73:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100e76:	f6 00 04             	testb  $0x4,(%eax)
f0100e79:	74 0e                	je     f0100e89 <mon_showmappings+0x134>
f0100e7b:	c7 04 24 c1 a2 10 f0 	movl   $0xf010a2c1,(%esp)
f0100e82:	e8 50 2b 00 00       	call   f01039d7 <cprintf>
f0100e87:	eb 0c                	jmp    f0100e95 <mon_showmappings+0x140>
                        else cprintf("- ");
f0100e89:	c7 04 24 b1 a2 10 f0 	movl   $0xf010a2b1,(%esp)
f0100e90:	e8 42 2b 00 00       	call   f01039d7 <cprintf>
			if(*pte&PTE_W) cprintf("W ");
f0100e95:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100e98:	f6 00 02             	testb  $0x2,(%eax)
f0100e9b:	74 0e                	je     f0100eab <mon_showmappings+0x156>
f0100e9d:	c7 04 24 c4 a2 10 f0 	movl   $0xf010a2c4,(%esp)
f0100ea4:	e8 2e 2b 00 00       	call   f01039d7 <cprintf>
f0100ea9:	eb 0c                	jmp    f0100eb7 <mon_showmappings+0x162>
                        else cprintf("- ");
f0100eab:	c7 04 24 b1 a2 10 f0 	movl   $0xf010a2b1,(%esp)
f0100eb2:	e8 20 2b 00 00       	call   f01039d7 <cprintf>
			cprintf("P \n");
f0100eb7:	c7 04 24 c7 a2 10 f0 	movl   $0xf010a2c7,(%esp)
f0100ebe:	e8 14 2b 00 00       	call   f01039d7 <cprintf>
f0100ec3:	eb 10                	jmp    f0100ed5 <mon_showmappings+0x180>
		}	
		else cprintf("this physical page corresponding to %x is not exiting\n",a);
f0100ec5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ec9:	c7 04 24 08 a5 10 f0 	movl   $0xf010a508,(%esp)
f0100ed0:	e8 02 2b 00 00       	call   f01039d7 <cprintf>
		if(a==la) break;
f0100ed5:	39 f3                	cmp    %esi,%ebx
f0100ed7:	74 0b                	je     f0100ee4 <mon_showmappings+0x18f>
		a+=PGSIZE;
f0100ed9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100edf:	e9 c4 fe ff ff       	jmp    f0100da8 <mon_showmappings+0x53>
	}
	return 0;
}
f0100ee4:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ee9:	83 c4 1c             	add    $0x1c,%esp
f0100eec:	5b                   	pop    %ebx
f0100eed:	5e                   	pop    %esi
f0100eee:	5f                   	pop    %edi
f0100eef:	5d                   	pop    %ebp
f0100ef0:	c3                   	ret    

f0100ef1 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100ef1:	55                   	push   %ebp
f0100ef2:	89 e5                	mov    %esp,%ebp
f0100ef4:	57                   	push   %edi
f0100ef5:	56                   	push   %esi
f0100ef6:	53                   	push   %ebx
f0100ef7:	83 ec 4c             	sub    $0x4c,%esp

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100efa:	89 eb                	mov    %ebp,%ebx
	int i;
	struct Eipdebuginfo eipinfo;
        uint32_t ebp,eip,arg[5];
        ebp=read_ebp();

        cprintf("Stack backtrace :\n");
f0100efc:	c7 04 24 cb a2 10 f0 	movl   $0xf010a2cb,(%esp)
f0100f03:	e8 cf 2a 00 00       	call   f01039d7 <cprintf>
        do{

		eip=*((uint32_t *)ebp+1);
                for(i=0;i<5;i++)
                        arg[i]=*((uint32_t *)ebp+i+2);
f0100f08:	8d 7d c8             	lea    -0x38(%ebp),%edi
        ebp=read_ebp();

        cprintf("Stack backtrace :\n");
        do{

		eip=*((uint32_t *)ebp+1);
f0100f0b:	89 5d c0             	mov    %ebx,-0x40(%ebp)
f0100f0e:	8b 73 04             	mov    0x4(%ebx),%esi
f0100f11:	ba 00 00 00 00       	mov    $0x0,%edx
                for(i=0;i<5;i++)
                        arg[i]=*((uint32_t *)ebp+i+2);
f0100f16:	8b 44 93 08          	mov    0x8(%ebx,%edx,4),%eax
f0100f1a:	89 04 97             	mov    %eax,(%edi,%edx,4)

        cprintf("Stack backtrace :\n");
        do{

		eip=*((uint32_t *)ebp+1);
                for(i=0;i<5;i++)
f0100f1d:	83 c2 01             	add    $0x1,%edx
f0100f20:	83 fa 05             	cmp    $0x5,%edx
f0100f23:	75 f1                	jne    f0100f16 <mon_backtrace+0x25>
                        arg[i]=*((uint32_t *)ebp+i+2);
                cprintf("ebp %08x eip %08x ",ebp,eip);
f0100f25:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100f29:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f2d:	c7 04 24 de a2 10 f0 	movl   $0xf010a2de,(%esp)
f0100f34:	e8 9e 2a 00 00       	call   f01039d7 <cprintf>
                cprintf("args %08x %08x %08x %08x %08x\n",arg[0],arg[1],arg[2],arg[3],arg[4]);
f0100f39:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f3c:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100f40:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100f43:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100f47:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100f4a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f4e:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0100f51:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f55:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0100f58:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f5c:	c7 04 24 70 a5 10 f0 	movl   $0xf010a570,(%esp)
f0100f63:	e8 6f 2a 00 00       	call   f01039d7 <cprintf>
                if(!debuginfo_eip((uintptr_t)eip,&eipinfo))
f0100f68:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0100f6b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f6f:	89 34 24             	mov    %esi,(%esp)
f0100f72:	e8 ab 43 00 00       	call   f0105322 <debuginfo_eip>
f0100f77:	85 c0                	test   %eax,%eax
f0100f79:	75 31                	jne    f0100fac <mon_backtrace+0xbb>
                {
                        cprintf("       %s:%d: %.*s+%d\n",eipinfo.eip_file,eipinfo.eip_line,eipinfo.eip_fn_namelen,eipinfo.eip_fn_name,eip-eipinfo.eip_fn_addr);
f0100f7b:	89 f0                	mov    %esi,%eax
f0100f7d:	2b 45 ec             	sub    -0x14(%ebp),%eax
f0100f80:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100f84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f87:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100f8b:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100f8e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f92:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f95:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f99:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100f9c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fa0:	c7 04 24 f1 a2 10 f0 	movl   $0xf010a2f1,(%esp)
f0100fa7:	e8 2b 2a 00 00       	call   f01039d7 <cprintf>
                }
                ebp=*(uint32_t *)ebp;
f0100fac:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100faf:	8b 18                	mov    (%eax),%ebx
        }while(ebp!=0);
f0100fb1:	85 db                	test   %ebx,%ebx
f0100fb3:	0f 85 52 ff ff ff    	jne    f0100f0b <mon_backtrace+0x1a>
	return 0;
}
f0100fb9:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fbe:	83 c4 4c             	add    $0x4c,%esp
f0100fc1:	5b                   	pop    %ebx
f0100fc2:	5e                   	pop    %esi
f0100fc3:	5f                   	pop    %edi
f0100fc4:	5d                   	pop    %ebp
f0100fc5:	c3                   	ret    

f0100fc6 <mon_continue>:
        cprintf("\n");
        return 0;
}
int
mon_continue(int argc, char **argv, struct Trapframe *tf)
{
f0100fc6:	55                   	push   %ebp
f0100fc7:	89 e5                	mov    %esp,%ebp
f0100fc9:	83 ec 08             	sub    $0x8,%esp
f0100fcc:	8b 55 10             	mov    0x10(%ebp),%edx
	uint32_t retesp;
	struct Trapframe *tf1;
	if(tf->tf_trapno==3||tf->tf_trapno==1)
f0100fcf:	8b 42 28             	mov    0x28(%edx),%eax
f0100fd2:	83 f8 03             	cmp    $0x3,%eax
f0100fd5:	74 05                	je     f0100fdc <mon_continue+0x16>
f0100fd7:	83 f8 01             	cmp    $0x1,%eax
f0100fda:	75 1b                	jne    f0100ff7 <mon_continue+0x31>
	{
		retesp=tf->tf_regs.reg_oesp-0x20;//看看pushal指令做了什么，就知道为什么减0x20,
f0100fdc:	8b 52 0c             	mov    0xc(%edx),%edx
f0100fdf:	83 ea 20             	sub    $0x20,%edx
					//找到异常产生，进行现场保护后的内核栈栈顶指针
		//cprintf("edi=%x oldesp=%x ebp=%x\n",tf1->tf_regs.reg_edi,retesp,read_ebp());
		tf1=(struct Trapframe*)retesp;
		tf1->tf_eflags|=0x10000;//设置EFLAGS中的RF
		tf1->tf_eflags&=~0x100;//复位EFLAGS中的TF
f0100fe2:	8b 42 38             	mov    0x38(%edx),%eax
f0100fe5:	0d 00 00 01 00       	or     $0x10000,%eax
f0100fea:	80 e4 fe             	and    $0xfe,%ah
f0100fed:	89 42 38             	mov    %eax,0x38(%edx)
}
//LAB 3: add write esp here
static __inline void
write_esp(uint32_t esp)
{
        __asm __volatile("movl %0,%%esp" : : "r" (esp));
f0100ff0:	89 d4                	mov    %edx,%esp
		//print_trapframe(tf1);
 		//cprintf("edi=%x oldesp=%x esp=%x\n",tf1->tf_regs.reg_edi,retesp,read_esp());
		write_esp(retesp);//恢复栈顶指针
		trapret();
f0100ff2:	e8 39 3b 00 00       	call   f0104b30 <trapret>
	}
	return 0;
}
f0100ff7:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ffc:	c9                   	leave  
f0100ffd:	c3                   	ret    
	...

f0101000 <boot_alloc>:
// This function may ONLY be used during initialization,
// before the page_free_list has been set up.
// 
static void*
boot_alloc(uint32_t n, uint32_t align)
{
f0101000:	55                   	push   %ebp
f0101001:	89 e5                	mov    %esp,%ebp
f0101003:	83 ec 0c             	sub    $0xc,%esp
f0101006:	89 1c 24             	mov    %ebx,(%esp)
f0101009:	89 74 24 04          	mov    %esi,0x4(%esp)
f010100d:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101011:	89 c3                	mov    %eax,%ebx
	// Initialize boot_freemem if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment -
	// i.e., the first virtual address that the linker
	// did _not_ assign to any kernel code or global variables.
	if (boot_freemem == 0)
f0101013:	83 3d b4 95 1b f0 00 	cmpl   $0x0,0xf01b95b4
f010101a:	75 0a                	jne    f0101026 <boot_alloc+0x26>
		boot_freemem = end;
f010101c:	c7 05 b4 95 1b f0 70 	movl   $0xf01ba570,0xf01b95b4
f0101023:	a5 1b f0 
	//	Step 1: round boot_freemem up to be aligned properly
	//		(hint: look in types.h for some handy macros)
	//	Step 2: save current value of boot_freemem as allocated chunk
	//	Step 3: increase boot_freemem to record allocation
	//	Step 4: return allocated chunk
	boot_freemem=ROUNDUP(boot_freemem,align);
f0101026:	a1 b4 95 1b f0       	mov    0xf01b95b4,%eax
f010102b:	83 e8 01             	sub    $0x1,%eax
f010102e:	8d 3c 10             	lea    (%eax,%edx,1),%edi
f0101031:	89 f8                	mov    %edi,%eax
f0101033:	89 d6                	mov    %edx,%esi
f0101035:	ba 00 00 00 00       	mov    $0x0,%edx
f010103a:	f7 f6                	div    %esi
f010103c:	89 f8                	mov    %edi,%eax
f010103e:	29 d0                	sub    %edx,%eax
	v=(void *)boot_freemem;
	boot_freemem=boot_freemem+n;
f0101040:	8d 14 18             	lea    (%eax,%ebx,1),%edx
f0101043:	89 15 b4 95 1b f0    	mov    %edx,0xf01b95b4
	return v;//这里v是个虚拟地址
	//return NULL;
}
f0101049:	8b 1c 24             	mov    (%esp),%ebx
f010104c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101050:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0101054:	89 ec                	mov    %ebp,%esp
f0101056:	5d                   	pop    %ebp
f0101057:	c3                   	ret    

f0101058 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f0101058:	55                   	push   %ebp
f0101059:	89 e5                	mov    %esp,%ebp
f010105b:	8b 4d 08             	mov    0x8(%ebp),%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f010105e:	8b 15 6c a5 1b f0    	mov    0xf01ba56c,%edx
	// Fill this function in
	if(pages[page2ppn(pp)].pp_ref==0){
f0101064:	89 c8                	mov    %ecx,%eax
f0101066:	29 d0                	sub    %edx,%eax
f0101068:	83 e0 fc             	and    $0xfffffffc,%eax
f010106b:	66 83 7c 10 08 00    	cmpw   $0x0,0x8(%eax,%edx,1)
f0101071:	75 20                	jne    f0101093 <page_free+0x3b>
		LIST_INSERT_HEAD(&page_free_list,pp,pp_link);
f0101073:	a1 b8 95 1b f0       	mov    0xf01b95b8,%eax
f0101078:	89 01                	mov    %eax,(%ecx)
f010107a:	85 c0                	test   %eax,%eax
f010107c:	74 08                	je     f0101086 <page_free+0x2e>
f010107e:	a1 b8 95 1b f0       	mov    0xf01b95b8,%eax
f0101083:	89 48 04             	mov    %ecx,0x4(%eax)
f0101086:	89 0d b8 95 1b f0    	mov    %ecx,0xf01b95b8
f010108c:	c7 41 04 b8 95 1b f0 	movl   $0xf01b95b8,0x4(%ecx)
	}
}
f0101093:	5d                   	pop    %ebp
f0101094:	c3                   	ret    

f0101095 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0101095:	55                   	push   %ebp
f0101096:	89 e5                	mov    %esp,%ebp
f0101098:	83 ec 04             	sub    $0x4,%esp
f010109b:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f010109e:	0f b7 42 08          	movzwl 0x8(%edx),%eax
f01010a2:	83 e8 01             	sub    $0x1,%eax
f01010a5:	66 89 42 08          	mov    %ax,0x8(%edx)
f01010a9:	66 85 c0             	test   %ax,%ax
f01010ac:	75 08                	jne    f01010b6 <page_decref+0x21>
		page_free(pp);
f01010ae:	89 14 24             	mov    %edx,(%esp)
f01010b1:	e8 a2 ff ff ff       	call   f0101058 <page_free>
}
f01010b6:	c9                   	leave  
f01010b7:	c3                   	ret    

f01010b8 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01010b8:	55                   	push   %ebp
f01010b9:	89 e5                	mov    %esp,%ebp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01010bb:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f01010c0:	85 c0                	test   %eax,%eax
f01010c2:	74 08                	je     f01010cc <tlb_invalidate+0x14>
f01010c4:	8b 55 08             	mov    0x8(%ebp),%edx
f01010c7:	39 50 5c             	cmp    %edx,0x5c(%eax)
f01010ca:	75 06                	jne    f01010d2 <tlb_invalidate+0x1a>
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01010cc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010cf:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01010d2:	5d                   	pop    %ebp
f01010d3:	c3                   	ret    

f01010d4 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01010d4:	55                   	push   %ebp
f01010d5:	89 e5                	mov    %esp,%ebp
f01010d7:	56                   	push   %esi
f01010d8:	53                   	push   %ebx
f01010d9:	83 ec 10             	sub    $0x10,%esp
	//     in physical memory?  Which pages are already in use for
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&page_free_list);
f01010dc:	c7 05 b8 95 1b f0 00 	movl   $0x0,0xf01b95b8
f01010e3:	00 00 00 
	for (i = 0; i < npage; i++) {
f01010e6:	83 3d 60 a5 1b f0 00 	cmpl   $0x0,0xf01ba560
f01010ed:	74 63                	je     f0101152 <page_init+0x7e>
f01010ef:	bb 00 00 00 00       	mov    $0x0,%ebx
f01010f4:	b8 00 00 00 00       	mov    $0x0,%eax
		pages[i].pp_ref = 0;
f01010f9:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01010fc:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
f0101103:	a1 6c a5 1b f0       	mov    0xf01ba56c,%eax
f0101108:	66 c7 44 01 08 00 00 	movw   $0x0,0x8(%ecx,%eax,1)
		LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
f010110f:	8b 15 b8 95 1b f0    	mov    0xf01b95b8,%edx
f0101115:	a1 6c a5 1b f0       	mov    0xf01ba56c,%eax
f010111a:	89 14 01             	mov    %edx,(%ecx,%eax,1)
f010111d:	85 d2                	test   %edx,%edx
f010111f:	74 10                	je     f0101131 <page_init+0x5d>
f0101121:	89 ca                	mov    %ecx,%edx
f0101123:	03 15 6c a5 1b f0    	add    0xf01ba56c,%edx
f0101129:	a1 b8 95 1b f0       	mov    0xf01b95b8,%eax
f010112e:	89 50 04             	mov    %edx,0x4(%eax)
f0101131:	89 c8                	mov    %ecx,%eax
f0101133:	03 05 6c a5 1b f0    	add    0xf01ba56c,%eax
f0101139:	a3 b8 95 1b f0       	mov    %eax,0xf01b95b8
f010113e:	c7 40 04 b8 95 1b f0 	movl   $0xf01b95b8,0x4(%eax)
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&page_free_list);
	for (i = 0; i < npage; i++) {
f0101145:	83 c3 01             	add    $0x1,%ebx
f0101148:	89 d8                	mov    %ebx,%eax
f010114a:	39 1d 60 a5 1b f0    	cmp    %ebx,0xf01ba560
f0101150:	77 a7                	ja     f01010f9 <page_init+0x25>
		pages[i].pp_ref = 0;
		LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
	}
	pages[0].pp_ref=1;
f0101152:	a1 6c a5 1b f0       	mov    0xf01ba56c,%eax
f0101157:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
	LIST_REMOVE(&pages[0],pp_link);
f010115d:	a1 6c a5 1b f0       	mov    0xf01ba56c,%eax
f0101162:	8b 10                	mov    (%eax),%edx
f0101164:	85 d2                	test   %edx,%edx
f0101166:	74 06                	je     f010116e <page_init+0x9a>
f0101168:	8b 40 04             	mov    0x4(%eax),%eax
f010116b:	89 42 04             	mov    %eax,0x4(%edx)
f010116e:	a1 6c a5 1b f0       	mov    0xf01ba56c,%eax
f0101173:	8b 50 04             	mov    0x4(%eax),%edx
f0101176:	8b 00                	mov    (%eax),%eax
f0101178:	89 02                	mov    %eax,(%edx)
	for(i=PPN(IOPHYSMEM);i<=PPN(ROUNDUP(PADDR(boot_freemem),PGSIZE));i++){
f010117a:	a1 b4 95 1b f0       	mov    0xf01b95b4,%eax
f010117f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101184:	76 62                	jbe    f01011e8 <page_init+0x114>
f0101186:	05 ff 0f 00 10       	add    $0x10000fff,%eax
f010118b:	89 c6                	mov    %eax,%esi
f010118d:	c1 ee 0c             	shr    $0xc,%esi
f0101190:	81 fe 9f 00 00 00    	cmp    $0x9f,%esi
f0101196:	76 7d                	jbe    f0101215 <page_init+0x141>
f0101198:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010119d:	bb a1 00 00 00       	mov    $0xa1,%ebx
							//这里要使用boot_freemem的物理地址,这个bug在做lab3时才发现
		pages[i].pp_ref=1;
f01011a2:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01011a5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01011ac:	a1 6c a5 1b f0       	mov    0xf01ba56c,%eax
f01011b1:	66 c7 44 02 08 01 00 	movw   $0x1,0x8(%edx,%eax,1)
		LIST_REMOVE(&pages[i],pp_link);
f01011b8:	89 d0                	mov    %edx,%eax
f01011ba:	03 05 6c a5 1b f0    	add    0xf01ba56c,%eax
f01011c0:	8b 08                	mov    (%eax),%ecx
f01011c2:	85 c9                	test   %ecx,%ecx
f01011c4:	74 17                	je     f01011dd <page_init+0x109>
f01011c6:	8b 40 04             	mov    0x4(%eax),%eax
f01011c9:	89 41 04             	mov    %eax,0x4(%ecx)
f01011cc:	89 d0                	mov    %edx,%eax
f01011ce:	03 05 6c a5 1b f0    	add    0xf01ba56c,%eax
f01011d4:	8b 50 04             	mov    0x4(%eax),%edx
f01011d7:	8b 00                	mov    (%eax),%eax
f01011d9:	89 02                	mov    %eax,(%edx)
f01011db:	eb 2b                	jmp    f0101208 <page_init+0x134>
f01011dd:	8b 40 04             	mov    0x4(%eax),%eax
f01011e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f01011e6:	eb 20                	jmp    f0101208 <page_init+0x134>
		pages[i].pp_ref = 0;
		LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
	}
	pages[0].pp_ref=1;
	LIST_REMOVE(&pages[0],pp_link);
	for(i=PPN(IOPHYSMEM);i<=PPN(ROUNDUP(PADDR(boot_freemem),PGSIZE));i++){
f01011e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011ec:	c7 44 24 08 0c a8 10 	movl   $0xf010a80c,0x8(%esp)
f01011f3:	f0 
f01011f4:	c7 44 24 04 df 01 00 	movl   $0x1df,0x4(%esp)
f01011fb:	00 
f01011fc:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101203:	e8 7e ee ff ff       	call   f0100086 <_panic>
f0101208:	8d 53 01             	lea    0x1(%ebx),%edx
f010120b:	39 de                	cmp    %ebx,%esi
f010120d:	72 06                	jb     f0101215 <page_init+0x141>
f010120f:	89 d8                	mov    %ebx,%eax
f0101211:	89 d3                	mov    %edx,%ebx
f0101213:	eb 8d                	jmp    f01011a2 <page_init+0xce>
							//这里要使用boot_freemem的物理地址,这个bug在做lab3时才发现
		pages[i].pp_ref=1;
		LIST_REMOVE(&pages[i],pp_link);
	}
}
f0101215:	83 c4 10             	add    $0x10,%esp
f0101218:	5b                   	pop    %ebx
f0101219:	5e                   	pop    %esi
f010121a:	5d                   	pop    %ebp
f010121b:	c3                   	ret    

f010121c <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_boot_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f010121c:	55                   	push   %ebp
f010121d:	89 e5                	mov    %esp,%ebp
f010121f:	83 ec 18             	sub    $0x18,%esp
f0101222:	89 d1                	mov    %edx,%ecx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0101224:	c1 ea 16             	shr    $0x16,%edx
f0101227:	8b 04 90             	mov    (%eax,%edx,4),%eax
f010122a:	a8 01                	test   $0x1,%al
f010122c:	74 51                	je     f010127f <check_va2pa+0x63>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f010122e:	89 c2                	mov    %eax,%edx
f0101230:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101236:	89 d0                	mov    %edx,%eax
f0101238:	c1 e8 0c             	shr    $0xc,%eax
f010123b:	3b 05 60 a5 1b f0    	cmp    0xf01ba560,%eax
f0101241:	72 20                	jb     f0101263 <check_va2pa+0x47>
f0101243:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101247:	c7 44 24 08 88 a4 10 	movl   $0xf010a488,0x8(%esp)
f010124e:	f0 
f010124f:	c7 44 24 04 b4 01 00 	movl   $0x1b4,0x4(%esp)
f0101256:	00 
f0101257:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f010125e:	e8 23 ee ff ff       	call   f0100086 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0101263:	89 c8                	mov    %ecx,%eax
f0101265:	c1 e8 0c             	shr    $0xc,%eax
f0101268:	25 ff 03 00 00       	and    $0x3ff,%eax
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f010126d:	8b 84 82 00 00 00 f0 	mov    -0x10000000(%edx,%eax,4),%eax
	if (!(p[PTX(va)] & PTE_P))
f0101274:	a8 01                	test   $0x1,%al
f0101276:	74 07                	je     f010127f <check_va2pa+0x63>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0101278:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010127d:	eb 05                	jmp    f0101284 <check_va2pa+0x68>
f010127f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0101284:	c9                   	leave  
f0101285:	c3                   	ret    

f0101286 <page_alloc>:
//   -E_NO_MEM -- otherwise 
//
// Hint: use LIST_FIRST, LIST_REMOVE, and page_initpp
int
page_alloc(struct Page **pp_store)
{
f0101286:	55                   	push   %ebp
f0101287:	89 e5                	mov    %esp,%ebp
f0101289:	53                   	push   %ebx
f010128a:	83 ec 14             	sub    $0x14,%esp
f010128d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// Fill this function in
	if(!LIST_EMPTY(&page_free_list)){
f0101290:	8b 15 b8 95 1b f0    	mov    0xf01b95b8,%edx
f0101296:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010129b:	85 d2                	test   %edx,%edx
f010129d:	74 36                	je     f01012d5 <page_alloc+0x4f>
		//page_initpp(*pp_store);
		*pp_store=(struct Page*)LIST_FIRST(&page_free_list);
f010129f:	89 13                	mov    %edx,(%ebx)
		LIST_REMOVE(*pp_store,pp_link);
f01012a1:	8b 0a                	mov    (%edx),%ecx
f01012a3:	85 c9                	test   %ecx,%ecx
f01012a5:	74 06                	je     f01012ad <page_alloc+0x27>
f01012a7:	8b 42 04             	mov    0x4(%edx),%eax
f01012aa:	89 41 04             	mov    %eax,0x4(%ecx)
f01012ad:	8b 03                	mov    (%ebx),%eax
f01012af:	8b 50 04             	mov    0x4(%eax),%edx
f01012b2:	8b 00                	mov    (%eax),%eax
f01012b4:	89 02                	mov    %eax,(%edx)
// Note that the corresponding physical page is NOT initialized!
//
static void
page_initpp(struct Page *pp)
{
	memset(pp, 0, sizeof(*pp));
f01012b6:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f01012bd:	00 
f01012be:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01012c5:	00 
f01012c6:	8b 03                	mov    (%ebx),%eax
f01012c8:	89 04 24             	mov    %eax,(%esp)
f01012cb:	e8 5e 83 00 00       	call   f010962e <memset>
f01012d0:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
	}
	else
		return -E_NO_MEM;
	return -E_NO_MEM;
}
f01012d5:	83 c4 14             	add    $0x14,%esp
f01012d8:	5b                   	pop    %ebx
f01012d9:	5d                   	pop    %ebp
f01012da:	c3                   	ret    

f01012db <pgdir_walk>:
// Hint 2: the x86 MMU checks permission bits in both the page directory
// and the page table, so it's safe to leave permissions in the page
// more permissive than strictly necessary.
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01012db:	55                   	push   %ebp
f01012dc:	89 e5                	mov    %esp,%ebp
f01012de:	83 ec 38             	sub    $0x38,%esp
f01012e1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01012e4:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01012e7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// Fill this function in
	pde_t *pde;
	pte_t *pgtab;
	pte_t *pp_store;
	struct Page *pgfortab;
	pde = &pgdir[PDX(va)];
f01012ea:	8b 75 0c             	mov    0xc(%ebp),%esi
f01012ed:	89 f0                	mov    %esi,%eax
f01012ef:	c1 e8 16             	shr    $0x16,%eax
f01012f2:	c1 e0 02             	shl    $0x2,%eax
f01012f5:	89 c7                	mov    %eax,%edi
f01012f7:	03 7d 08             	add    0x8(%ebp),%edi

	//看一下对应的页表是否存在
	if(*pde & PTE_P){
f01012fa:	8b 07                	mov    (%edi),%eax
f01012fc:	a8 01                	test   $0x1,%al
f01012fe:	74 3f                	je     f010133f <pgdir_walk+0x64>
		pgtab = (pte_t*)KADDR(PTE_ADDR(*pde));//存在对应页表,访问页表需要用虚拟地址
f0101300:	89 c2                	mov    %eax,%edx
f0101302:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101308:	89 d0                	mov    %edx,%eax
f010130a:	c1 e8 0c             	shr    $0xc,%eax
f010130d:	8d 9a 00 00 00 f0    	lea    -0x10000000(%edx),%ebx
f0101313:	3b 05 60 a5 1b f0    	cmp    0xf01ba560,%eax
f0101319:	0f 82 dc 00 00 00    	jb     f01013fb <pgdir_walk+0x120>
f010131f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101323:	c7 44 24 08 88 a4 10 	movl   $0xf010a488,0x8(%esp)
f010132a:	f0 
f010132b:	c7 44 24 04 47 02 00 	movl   $0x247,0x4(%esp)
f0101332:	00 
f0101333:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f010133a:	e8 47 ed ff ff       	call   f0100086 <_panic>
	}else{//create==0或者分配页面失败,返回NULL
		if(!create)
f010133f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101343:	0f 84 c0 00 00 00    	je     f0101409 <pgdir_walk+0x12e>
			return NULL;
		if(page_alloc(&pgfortab)<0)
f0101349:	8d 45 f0             	lea    -0x10(%ebp),%eax
f010134c:	89 04 24             	mov    %eax,(%esp)
f010134f:	e8 32 ff ff ff       	call   f0101286 <page_alloc>
f0101354:	85 c0                	test   %eax,%eax
f0101356:	0f 88 ad 00 00 00    	js     f0101409 <pgdir_walk+0x12e>
			return NULL;
		pgfortab->pp_ref=1;//设置引用标志为1,这个页做为了页表
f010135c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010135f:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101365:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101368:	2b 05 6c a5 1b f0    	sub    0xf01ba56c,%eax
f010136e:	c1 f8 02             	sar    $0x2,%eax
f0101371:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101377:	89 c2                	mov    %eax,%edx
f0101379:	c1 e2 0c             	shl    $0xc,%edx
		//cprintf("welcome to pgdir_walk:va=%x pgfortab=%x\n",va,KADDR(page2pa(pgfortab)));
		pgtab = (pte_t*)KADDR(page2pa(pgfortab));//获取页面物理地址,访问页表要用虚拟地址
f010137c:	89 d0                	mov    %edx,%eax
f010137e:	c1 e8 0c             	shr    $0xc,%eax
f0101381:	3b 05 60 a5 1b f0    	cmp    0xf01ba560,%eax
f0101387:	72 20                	jb     f01013a9 <pgdir_walk+0xce>
f0101389:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010138d:	c7 44 24 08 88 a4 10 	movl   $0xf010a488,0x8(%esp)
f0101394:	f0 
f0101395:	c7 44 24 04 4f 02 00 	movl   $0x24f,0x4(%esp)
f010139c:	00 
f010139d:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f01013a4:	e8 dd ec ff ff       	call   f0100086 <_panic>
f01013a9:	8d 9a 00 00 00 f0    	lea    -0x10000000(%edx),%ebx
		
		memset(pgtab,0,PGSIZE);
f01013af:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01013b6:	00 
f01013b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01013be:	00 
f01013bf:	89 1c 24             	mov    %ebx,(%esp)
f01013c2:	e8 67 82 00 00       	call   f010962e <memset>
		*pde = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;//填写相应页目录项,需要填写相应物理地址
f01013c7:	89 d8                	mov    %ebx,%eax
f01013c9:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01013cf:	77 20                	ja     f01013f1 <pgdir_walk+0x116>
f01013d1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01013d5:	c7 44 24 08 0c a8 10 	movl   $0xf010a80c,0x8(%esp)
f01013dc:	f0 
f01013dd:	c7 44 24 04 52 02 00 	movl   $0x252,0x4(%esp)
f01013e4:	00 
f01013e5:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f01013ec:	e8 95 ec ff ff       	call   f0100086 <_panic>
f01013f1:	05 00 00 00 10       	add    $0x10000000,%eax
f01013f6:	83 c8 07             	or     $0x7,%eax
f01013f9:	89 07                	mov    %eax,(%edi)
		//cprintf("pde=%x *pde=%x &pgtab[PTX(va)]=%x\n",&pgdir[PDX(va)],pgdir[PDX(va)],&pgtab[PTX(va)]);
	}
	pp_store=&pgtab[PTX(va)];
f01013fb:	89 f0                	mov    %esi,%eax
f01013fd:	c1 e8 0a             	shr    $0xa,%eax
f0101400:	25 fc 0f 00 00       	and    $0xffc,%eax
f0101405:	01 d8                	add    %ebx,%eax
f0101407:	eb 05                	jmp    f010140e <pgdir_walk+0x133>
	return pp_store;
f0101409:	b8 00 00 00 00       	mov    $0x0,%eax
	//return NULL;
}
f010140e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101411:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101414:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101417:	89 ec                	mov    %ebp,%esp
f0101419:	5d                   	pop    %ebp
f010141a:	c3                   	ret    

f010141b <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010141b:	55                   	push   %ebp
f010141c:	89 e5                	mov    %esp,%ebp
f010141e:	53                   	push   %ebx
f010141f:	83 ec 14             	sub    $0x14,%esp
f0101422:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	struct Page *pageforva;
	pte_t *pte;
	if(!(pte=pgdir_walk(pgdir,va,0)))
f0101425:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010142c:	00 
f010142d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101430:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101434:	8b 45 08             	mov    0x8(%ebp),%eax
f0101437:	89 04 24             	mov    %eax,(%esp)
f010143a:	e8 9c fe ff ff       	call   f01012db <pgdir_walk>
f010143f:	89 c2                	mov    %eax,%edx
f0101441:	b8 00 00 00 00       	mov    $0x0,%eax
f0101446:	85 d2                	test   %edx,%edx
f0101448:	74 40                	je     f010148a <page_lookup+0x6f>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f010144a:	8b 02                	mov    (%edx),%eax
f010144c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101451:	c1 e8 0c             	shr    $0xc,%eax
f0101454:	3b 05 60 a5 1b f0    	cmp    0xf01ba560,%eax
f010145a:	72 1c                	jb     f0101478 <page_lookup+0x5d>
		panic("pa2page called with invalid pa");
f010145c:	c7 44 24 08 30 a8 10 	movl   $0xf010a830,0x8(%esp)
f0101463:	f0 
f0101464:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f010146b:	00 
f010146c:	c7 04 24 0f ae 10 f0 	movl   $0xf010ae0f,(%esp)
f0101473:	e8 0e ec ff ff       	call   f0100086 <_panic>
	return &pages[PPN(pa)];
f0101478:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010147b:	c1 e0 02             	shl    $0x2,%eax
f010147e:	03 05 6c a5 1b f0    	add    0xf01ba56c,%eax
		return NULL;
	else{
		pageforva=pa2page(PTE_ADDR(*pte));

		if(pte_store)//这个地方传递pte容易错，小心编写
f0101484:	85 db                	test   %ebx,%ebx
f0101486:	74 02                	je     f010148a <page_lookup+0x6f>
			*pte_store=pte;
f0101488:	89 13                	mov    %edx,(%ebx)
	}
	return pageforva;
	//return NULL;
}
f010148a:	83 c4 14             	add    $0x14,%esp
f010148d:	5b                   	pop    %ebx
f010148e:	5d                   	pop    %ebp
f010148f:	c3                   	ret    

f0101490 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0101490:	55                   	push   %ebp
f0101491:	89 e5                	mov    %esp,%ebp
f0101493:	57                   	push   %edi
f0101494:	56                   	push   %esi
f0101495:	53                   	push   %ebx
f0101496:	83 ec 1c             	sub    $0x1c,%esp
f0101499:	8b 45 0c             	mov    0xc(%ebp),%eax
	// LAB 3: Your code here.
	uintptr_t a,last;
	pte_t *pte;
	struct Page *onepage;
	a=(uintptr_t)va;
	user_mem_check_addr=a;
f010149c:	a3 bc 95 1b f0       	mov    %eax,0xf01b95bc
	a=ROUNDDOWN(a,PGSIZE);
f01014a1:	89 c3                	mov    %eax,%ebx
f01014a3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	last=ROUNDDOWN(a+len,PGSIZE);
f01014a9:	89 d8                	mov    %ebx,%eax
f01014ab:	03 45 10             	add    0x10(%ebp),%eax
f01014ae:	89 c6                	mov    %eax,%esi
f01014b0:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
			if((user_mem_check_addr&0xfffff000)!=a)
				user_mem_check_addr=a;
			return -E_FAULT;
		}
		else{
			if(!(onepage=page_lookup(env->env_pgdir,(void *)a,&pte)))
f01014b6:	8d 7d f0             	lea    -0x10(%ebp),%edi
	a=(uintptr_t)va;
	user_mem_check_addr=a;
	a=ROUNDDOWN(a,PGSIZE);
	last=ROUNDDOWN(a+len,PGSIZE);
	for(;;){
		if(a>=ULIM) {
f01014b9:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01014bf:	76 27                	jbe    f01014e8 <user_mem_check+0x58>
f01014c1:	e9 9c 00 00 00       	jmp    f0101562 <user_mem_check+0xd2>
			if((user_mem_check_addr&0xfffff000)!=a)
f01014c6:	a1 bc 95 1b f0       	mov    0xf01b95bc,%eax
f01014cb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01014d0:	39 d8                	cmp    %ebx,%eax
f01014d2:	0f 84 8a 00 00 00    	je     f0101562 <user_mem_check+0xd2>
				user_mem_check_addr=a;
f01014d8:	89 1d bc 95 1b f0    	mov    %ebx,0xf01b95bc
f01014de:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01014e3:	e9 7f 00 00 00       	jmp    f0101567 <user_mem_check+0xd7>
			return -E_FAULT;
		}
		else{
			if(!(onepage=page_lookup(env->env_pgdir,(void *)a,&pte)))
f01014e8:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01014ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01014f0:	8b 55 08             	mov    0x8(%ebp),%edx
f01014f3:	8b 42 5c             	mov    0x5c(%edx),%eax
f01014f6:	89 04 24             	mov    %eax,(%esp)
f01014f9:	e8 1d ff ff ff       	call   f010141b <page_lookup>
f01014fe:	85 c0                	test   %eax,%eax
f0101500:	75 1b                	jne    f010151d <user_mem_check+0x8d>
			{	
				if((user_mem_check_addr&0xfffff000)!=a)
f0101502:	a1 bc 95 1b f0       	mov    0xf01b95bc,%eax
f0101507:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010150c:	39 d8                	cmp    %ebx,%eax
f010150e:	74 52                	je     f0101562 <user_mem_check+0xd2>
                                	user_mem_check_addr=a;
f0101510:	89 1d bc 95 1b f0    	mov    %ebx,0xf01b95bc
f0101516:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010151b:	eb 4a                	jmp    f0101567 <user_mem_check+0xd7>
				return -E_FAULT;
			}
			if(!(*pte&perm))
f010151d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101520:	8b 55 14             	mov    0x14(%ebp),%edx
f0101523:	85 10                	test   %edx,(%eax)
f0101525:	75 1b                	jne    f0101542 <user_mem_check+0xb2>
			{
				if((user_mem_check_addr&0xfffff000)!=a)
f0101527:	a1 bc 95 1b f0       	mov    0xf01b95bc,%eax
f010152c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101531:	39 d8                	cmp    %ebx,%eax
f0101533:	74 2d                	je     f0101562 <user_mem_check+0xd2>
                                	user_mem_check_addr=a;
f0101535:	89 1d bc 95 1b f0    	mov    %ebx,0xf01b95bc
f010153b:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0101540:	eb 25                	jmp    f0101567 <user_mem_check+0xd7>
				return -E_FAULT;
			}
			
			
		}
		if(a==last) 
f0101542:	39 f3                	cmp    %esi,%ebx
f0101544:	74 14                	je     f010155a <user_mem_check+0xca>
			break;	
		a+=PGSIZE;
f0101546:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	a=(uintptr_t)va;
	user_mem_check_addr=a;
	a=ROUNDDOWN(a,PGSIZE);
	last=ROUNDDOWN(a+len,PGSIZE);
	for(;;){
		if(a>=ULIM) {
f010154c:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101552:	0f 87 6e ff ff ff    	ja     f01014c6 <user_mem_check+0x36>
f0101558:	eb 8e                	jmp    f01014e8 <user_mem_check+0x58>
f010155a:	b8 00 00 00 00       	mov    $0x0,%eax
f010155f:	90                   	nop    
f0101560:	eb 05                	jmp    f0101567 <user_mem_check+0xd7>
f0101562:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
		if(a==last) 
			break;	
		a+=PGSIZE;
	}		
	return 0; 
}
f0101567:	83 c4 1c             	add    $0x1c,%esp
f010156a:	5b                   	pop    %ebx
f010156b:	5e                   	pop    %esi
f010156c:	5f                   	pop    %edi
f010156d:	5d                   	pop    %ebp
f010156e:	c3                   	ret    

f010156f <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f010156f:	55                   	push   %ebp
f0101570:	89 e5                	mov    %esp,%ebp
f0101572:	53                   	push   %ebx
f0101573:	83 ec 14             	sub    $0x14,%esp
f0101576:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0101579:	8b 45 14             	mov    0x14(%ebp),%eax
f010157c:	83 c8 04             	or     $0x4,%eax
f010157f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101583:	8b 45 10             	mov    0x10(%ebp),%eax
f0101586:	89 44 24 08          	mov    %eax,0x8(%esp)
f010158a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010158d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101591:	89 1c 24             	mov    %ebx,(%esp)
f0101594:	e8 f7 fe ff ff       	call   f0101490 <user_mem_check>
f0101599:	85 c0                	test   %eax,%eax
f010159b:	79 24                	jns    f01015c1 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f010159d:	a1 bc 95 1b f0       	mov    0xf01b95bc,%eax
f01015a2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01015a6:	8b 43 4c             	mov    0x4c(%ebx),%eax
f01015a9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015ad:	c7 04 24 50 a8 10 f0 	movl   $0xf010a850,(%esp)
f01015b4:	e8 1e 24 00 00       	call   f01039d7 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01015b9:	89 1c 24             	mov    %ebx,(%esp)
f01015bc:	e8 35 22 00 00       	call   f01037f6 <env_destroy>
	}
}
f01015c1:	83 c4 14             	add    $0x14,%esp
f01015c4:	5b                   	pop    %ebx
f01015c5:	5d                   	pop    %ebp
f01015c6:	c3                   	ret    

f01015c7 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01015c7:	55                   	push   %ebp
f01015c8:	89 e5                	mov    %esp,%ebp
f01015ca:	83 ec 28             	sub    $0x28,%esp
f01015cd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01015d0:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01015d3:	8b 75 08             	mov    0x8(%ebp),%esi
f01015d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	struct Page *pageforva;
	pte_t *pte=NULL;
f01015d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	if((pageforva=page_lookup(pgdir,va,&pte))){
f01015e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01015e3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01015e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01015eb:	89 34 24             	mov    %esi,(%esp)
f01015ee:	e8 28 fe ff ff       	call   f010141b <page_lookup>
f01015f3:	85 c0                	test   %eax,%eax
f01015f5:	74 21                	je     f0101618 <page_remove+0x51>
		page_decref(pageforva);
f01015f7:	89 04 24             	mov    %eax,(%esp)
f01015fa:	e8 96 fa ff ff       	call   f0101095 <page_decref>

		if(pte)
f01015ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101602:	85 c0                	test   %eax,%eax
f0101604:	74 06                	je     f010160c <page_remove+0x45>
			*pte=0;
f0101606:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir,va);
f010160c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101610:	89 34 24             	mov    %esi,(%esp)
f0101613:	e8 a0 fa ff ff       	call   f01010b8 <tlb_invalidate>
	}
}
f0101618:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f010161b:	8b 75 fc             	mov    -0x4(%ebp),%esi
f010161e:	89 ec                	mov    %ebp,%esp
f0101620:	5d                   	pop    %ebp
f0101621:	c3                   	ret    

f0101622 <boot_map_segment>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
{
f0101622:	55                   	push   %ebp
f0101623:	89 e5                	mov    %esp,%ebp
f0101625:	57                   	push   %edi
f0101626:	56                   	push   %esi
f0101627:	53                   	push   %ebx
f0101628:	83 ec 1c             	sub    $0x1c,%esp
f010162b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010162e:	8b 75 08             	mov    0x8(%ebp),%esi
	// Fill this function in
	uintptr_t a,last;
	pte_t *pte;
	//cprintf("----------------------------\n");
	a=ROUNDDOWN(la,PGSIZE);
f0101631:	89 d3                	mov    %edx,%ebx
f0101633:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	last=ROUNDDOWN(la+size-1,PGSIZE);//这个地方要小心编写,防止重映射
f0101639:	8d 54 0a ff          	lea    -0x1(%edx,%ecx,1),%edx
f010163d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101643:	89 55 f0             	mov    %edx,-0x10(%ebp)
		pte = pgdir_walk(pgdir,(void *)a,1);
		if(pte==NULL)
			return;
		if(*pte&PTE_P)
			panic("remap");
		*pte=pa | perm | PTE_P;
f0101646:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101649:	83 cf 01             	or     $0x1,%edi
	//cprintf("----------------------------\n");
	a=ROUNDDOWN(la,PGSIZE);
	last=ROUNDDOWN(la+size-1,PGSIZE);//这个地方要小心编写,防止重映射
	//cprintf("\nlast=%x\n",last);
	for(;;){
		pte = pgdir_walk(pgdir,(void *)a,1);
f010164c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101653:	00 
f0101654:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101658:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010165b:	89 04 24             	mov    %eax,(%esp)
f010165e:	e8 78 fc ff ff       	call   f01012db <pgdir_walk>
f0101663:	89 c2                	mov    %eax,%edx
		if(pte==NULL)
f0101665:	85 c0                	test   %eax,%eax
f0101667:	74 3a                	je     f01016a3 <boot_map_segment+0x81>
			return;
		if(*pte&PTE_P)
f0101669:	f6 00 01             	testb  $0x1,(%eax)
f010166c:	74 1c                	je     f010168a <boot_map_segment+0x68>
			panic("remap");
f010166e:	c7 44 24 08 1d ae 10 	movl   $0xf010ae1d,0x8(%esp)
f0101675:	f0 
f0101676:	c7 44 24 04 a0 02 00 	movl   $0x2a0,0x4(%esp)
f010167d:	00 
f010167e:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101685:	e8 fc e9 ff ff       	call   f0100086 <_panic>
		*pte=pa | perm | PTE_P;
f010168a:	89 f8                	mov    %edi,%eax
f010168c:	09 f0                	or     %esi,%eax
f010168e:	89 02                	mov    %eax,(%edx)
		//if(a==0xf0400000)
		//	cprintf("a=%x *pte=%x\n",a,*pte);
		//if(a>=KERNBASE)
		//	cprintf("a=%x *pte=%x ********",a,*pte);
		if(a==last)
f0101690:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0101693:	74 0e                	je     f01016a3 <boot_map_segment+0x81>
			break;
		a+=PGSIZE;
f0101695:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		pa+=PGSIZE;
f010169b:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01016a1:	eb a9                	jmp    f010164c <boot_map_segment+0x2a>
	}
	return;
}
f01016a3:	83 c4 1c             	add    $0x1c,%esp
f01016a6:	5b                   	pop    %ebx
f01016a7:	5e                   	pop    %esi
f01016a8:	5f                   	pop    %edi
f01016a9:	5d                   	pop    %ebp
f01016aa:	c3                   	ret    

f01016ab <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm) 
{
f01016ab:	55                   	push   %ebp
f01016ac:	89 e5                	mov    %esp,%ebp
f01016ae:	83 ec 18             	sub    $0x18,%esp
f01016b1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01016b4:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01016b7:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01016ba:	8b 75 0c             	mov    0xc(%ebp),%esi
f01016bd:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *pte;
	if(!(pte=pgdir_walk(pgdir, va, 1)))//查找或创建虚拟地址va对应的页表项pte
f01016c0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01016c7:	00 
f01016c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01016cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01016cf:	89 04 24             	mov    %eax,(%esp)
f01016d2:	e8 04 fc ff ff       	call   f01012db <pgdir_walk>
f01016d7:	89 c3                	mov    %eax,%ebx
f01016d9:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01016de:	85 db                	test   %ebx,%ebx
f01016e0:	74 73                	je     f0101755 <page_insert+0xaa>
		return -E_NO_MEM;
	else{
		if(*pte&PTE_P){//对应va的实际物理页面存在
f01016e2:	8b 03                	mov    (%ebx),%eax
f01016e4:	a8 01                	test   $0x1,%al
f01016e6:	74 36                	je     f010171e <page_insert+0x73>
			if(PTE_ADDR(*pte)!=page2pa(pp))//va指向了不同的物理页面
f01016e8:	89 c2                	mov    %eax,%edx
f01016ea:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01016f0:	89 f0                	mov    %esi,%eax
f01016f2:	2b 05 6c a5 1b f0    	sub    0xf01ba56c,%eax
f01016f8:	c1 f8 02             	sar    $0x2,%eax
f01016fb:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101701:	c1 e0 0c             	shl    $0xc,%eax
f0101704:	39 c2                	cmp    %eax,%edx
f0101706:	74 11                	je     f0101719 <page_insert+0x6e>
				page_remove(pgdir,va);
f0101708:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010170c:	8b 45 08             	mov    0x8(%ebp),%eax
f010170f:	89 04 24             	mov    %eax,(%esp)
f0101712:	e8 b0 fe ff ff       	call   f01015c7 <page_remove>
f0101717:	eb 05                	jmp    f010171e <page_insert+0x73>
			else				//va指向了需要分配的物理页面
				pp->pp_ref--;
f0101719:	66 83 6e 08 01       	subw   $0x1,0x8(%esi)
		}
		*pte = page2pa(pp) | perm | PTE_P;//填写页表项
f010171e:	8b 55 14             	mov    0x14(%ebp),%edx
f0101721:	83 ca 01             	or     $0x1,%edx
f0101724:	89 f0                	mov    %esi,%eax
f0101726:	2b 05 6c a5 1b f0    	sub    0xf01ba56c,%eax
f010172c:	c1 f8 02             	sar    $0x2,%eax
f010172f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101735:	c1 e0 0c             	shl    $0xc,%eax
f0101738:	09 c2                	or     %eax,%edx
f010173a:	89 13                	mov    %edx,(%ebx)
		//cprintf("pte=%x *pte=%x\n",pte,*pte);
		pp->pp_ref++;//映射的实际物理页的引用情况
f010173c:	66 83 46 08 01       	addw   $0x1,0x8(%esi)
		tlb_invalidate(pgdir,va);//更新TLB
f0101741:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101745:	8b 45 08             	mov    0x8(%ebp),%eax
f0101748:	89 04 24             	mov    %eax,(%esp)
f010174b:	e8 68 f9 ff ff       	call   f01010b8 <tlb_invalidate>
f0101750:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
	}
	//return 0;
}
f0101755:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101758:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010175b:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010175e:	89 ec                	mov    %ebp,%esp
f0101760:	5d                   	pop    %ebp
f0101761:	c3                   	ret    

f0101762 <nvram_read>:
	sizeof(gdt) - 1, (unsigned long) gdt
};

static int
nvram_read(int r)
{
f0101762:	55                   	push   %ebp
f0101763:	89 e5                	mov    %esp,%ebp
f0101765:	83 ec 18             	sub    $0x18,%esp
f0101768:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f010176b:	89 75 fc             	mov    %esi,-0x4(%ebp)
f010176e:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101770:	89 04 24             	mov    %eax,(%esp)
f0101773:	e8 b0 20 00 00       	call   f0103828 <mc146818_read>
f0101778:	89 c3                	mov    %eax,%ebx
f010177a:	8d 46 01             	lea    0x1(%esi),%eax
f010177d:	89 04 24             	mov    %eax,(%esp)
f0101780:	e8 a3 20 00 00       	call   f0103828 <mc146818_read>
f0101785:	c1 e0 08             	shl    $0x8,%eax
f0101788:	09 d8                	or     %ebx,%eax
}
f010178a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f010178d:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101790:	89 ec                	mov    %ebp,%esp
f0101792:	5d                   	pop    %ebp
f0101793:	c3                   	ret    

f0101794 <i386_detect_memory>:

void
i386_detect_memory(void)
{
f0101794:	55                   	push   %ebp
f0101795:	89 e5                	mov    %esp,%ebp
f0101797:	83 ec 18             	sub    $0x18,%esp
	// CMOS tells us how many kilobytes there are
	basemem = ROUNDDOWN(nvram_read(NVRAM_BASELO)*1024, PGSIZE);
f010179a:	b8 15 00 00 00       	mov    $0x15,%eax
f010179f:	e8 be ff ff ff       	call   f0101762 <nvram_read>
f01017a4:	c1 e0 0a             	shl    $0xa,%eax
f01017a7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01017ac:	a3 ac 95 1b f0       	mov    %eax,0xf01b95ac
	extmem = ROUNDDOWN(nvram_read(NVRAM_EXTLO)*1024, PGSIZE);
f01017b1:	b8 17 00 00 00       	mov    $0x17,%eax
f01017b6:	e8 a7 ff ff ff       	call   f0101762 <nvram_read>
f01017bb:	c1 e0 0a             	shl    $0xa,%eax
f01017be:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01017c3:	a3 b0 95 1b f0       	mov    %eax,0xf01b95b0

	// Calculate the maximum physical address based on whether
	// or not there is any extended memory.  See comment in <inc/mmu.h>.
	if (extmem)
f01017c8:	85 c0                	test   %eax,%eax
f01017ca:	74 0c                	je     f01017d8 <i386_detect_memory+0x44>
		maxpa = EXTPHYSMEM + extmem;
f01017cc:	05 00 00 10 00       	add    $0x100000,%eax
f01017d1:	a3 a8 95 1b f0       	mov    %eax,0xf01b95a8
f01017d6:	eb 0a                	jmp    f01017e2 <i386_detect_memory+0x4e>
	else
		maxpa = basemem;
f01017d8:	a1 ac 95 1b f0       	mov    0xf01b95ac,%eax
f01017dd:	a3 a8 95 1b f0       	mov    %eax,0xf01b95a8

	npage = maxpa / PGSIZE;
f01017e2:	a1 a8 95 1b f0       	mov    0xf01b95a8,%eax
f01017e7:	89 c2                	mov    %eax,%edx
f01017e9:	c1 ea 0c             	shr    $0xc,%edx
f01017ec:	89 15 60 a5 1b f0    	mov    %edx,0xf01ba560

	cprintf("Physical memory: %dK available, ", (int)(maxpa/1024));
f01017f2:	c1 e8 0a             	shr    $0xa,%eax
f01017f5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01017f9:	c7 04 24 88 a8 10 f0 	movl   $0xf010a888,(%esp)
f0101800:	e8 d2 21 00 00       	call   f01039d7 <cprintf>
	cprintf("base = %dK, extended = %dK\n", (int)(basemem/1024), (int)(extmem/1024));
f0101805:	a1 b0 95 1b f0       	mov    0xf01b95b0,%eax
f010180a:	c1 e8 0a             	shr    $0xa,%eax
f010180d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101811:	a1 ac 95 1b f0       	mov    0xf01b95ac,%eax
f0101816:	c1 e8 0a             	shr    $0xa,%eax
f0101819:	89 44 24 04          	mov    %eax,0x4(%esp)
f010181d:	c7 04 24 23 ae 10 f0 	movl   $0xf010ae23,(%esp)
f0101824:	e8 ae 21 00 00       	call   f01039d7 <cprintf>
}
f0101829:	c9                   	leave  
f010182a:	c3                   	ret    

f010182b <check_page_alloc>:
// Check the physical page allocator (page_alloc(), page_free(),
// and page_init()).
//
static void
check_page_alloc()
{
f010182b:	55                   	push   %ebp
f010182c:	89 e5                	mov    %esp,%ebp
f010182e:	57                   	push   %edi
f010182f:	56                   	push   %esi
f0101830:	53                   	push   %ebx
f0101831:	83 ec 2c             	sub    $0x2c,%esp
	struct Page_list fl;

	// if there's a page that shouldn't be on
	// the free list, try to make sure it
	// eventually causes trouble.
	LIST_FOREACH(pp0, &page_free_list, pp_link)
f0101834:	a1 b8 95 1b f0       	mov    0xf01b95b8,%eax
f0101839:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010183c:	85 c0                	test   %eax,%eax
f010183e:	0f 84 41 02 00 00    	je     f0101a85 <check_page_alloc+0x25a>
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101844:	2b 05 6c a5 1b f0    	sub    0xf01ba56c,%eax
f010184a:	c1 f8 02             	sar    $0x2,%eax
f010184d:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101853:	89 c2                	mov    %eax,%edx
f0101855:	c1 e2 0c             	shl    $0xc,%edx
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0101858:	89 d0                	mov    %edx,%eax
f010185a:	c1 e8 0c             	shr    $0xc,%eax
f010185d:	39 05 60 a5 1b f0    	cmp    %eax,0xf01ba560
f0101863:	77 43                	ja     f01018a8 <check_page_alloc+0x7d>
f0101865:	eb 21                	jmp    f0101888 <check_page_alloc+0x5d>
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101867:	2b 05 6c a5 1b f0    	sub    0xf01ba56c,%eax
f010186d:	c1 f8 02             	sar    $0x2,%eax
f0101870:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101876:	89 c2                	mov    %eax,%edx
f0101878:	c1 e2 0c             	shl    $0xc,%edx
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f010187b:	89 d0                	mov    %edx,%eax
f010187d:	c1 e8 0c             	shr    $0xc,%eax
f0101880:	3b 05 60 a5 1b f0    	cmp    0xf01ba560,%eax
f0101886:	72 20                	jb     f01018a8 <check_page_alloc+0x7d>
f0101888:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010188c:	c7 44 24 08 88 a4 10 	movl   $0xf010a488,0x8(%esp)
f0101893:	f0 
f0101894:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f010189b:	00 
f010189c:	c7 04 24 0f ae 10 f0 	movl   $0xf010ae0f,(%esp)
f01018a3:	e8 de e7 ff ff       	call   f0100086 <_panic>
		memset(page2kva(pp0), 0x97, 128);
f01018a8:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f01018af:	00 
f01018b0:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f01018b7:	00 
f01018b8:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01018be:	89 04 24             	mov    %eax,(%esp)
f01018c1:	e8 68 7d 00 00       	call   f010962e <memset>
	struct Page_list fl;

	// if there's a page that shouldn't be on
	// the free list, try to make sure it
	// eventually causes trouble.
	LIST_FOREACH(pp0, &page_free_list, pp_link)
f01018c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01018c9:	8b 00                	mov    (%eax),%eax
f01018cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01018ce:	85 c0                	test   %eax,%eax
f01018d0:	75 95                	jne    f0101867 <check_page_alloc+0x3c>
		memset(page2kva(pp0), 0x97, 128);

	LIST_FOREACH(pp0, &page_free_list, pp_link) {
f01018d2:	8b 0d b8 95 1b f0    	mov    0xf01b95b8,%ecx
f01018d8:	89 4d ec             	mov    %ecx,-0x14(%ebp)
f01018db:	85 c9                	test   %ecx,%ecx
f01018dd:	0f 84 a2 01 00 00    	je     f0101a85 <check_page_alloc+0x25a>
		// check that we didn't corrupt the free list itself
		assert(pp0 >= pages);
f01018e3:	8b 1d 6c a5 1b f0    	mov    0xf01ba56c,%ebx
f01018e9:	39 d9                	cmp    %ebx,%ecx
f01018eb:	72 19                	jb     f0101906 <check_page_alloc+0xdb>
		assert(pp0 < pages + npage);
f01018ed:	8b 35 60 a5 1b f0    	mov    0xf01ba560,%esi
f01018f3:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01018f6:	8d 04 83             	lea    (%ebx,%eax,4),%eax
f01018f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01018fc:	39 c1                	cmp    %eax,%ecx
f01018fe:	72 53                	jb     f0101953 <check_page_alloc+0x128>
f0101900:	eb 2d                	jmp    f010192f <check_page_alloc+0x104>
	LIST_FOREACH(pp0, &page_free_list, pp_link)
		memset(page2kva(pp0), 0x97, 128);

	LIST_FOREACH(pp0, &page_free_list, pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp0 >= pages);
f0101902:	39 cb                	cmp    %ecx,%ebx
f0101904:	76 24                	jbe    f010192a <check_page_alloc+0xff>
f0101906:	c7 44 24 0c 3f ae 10 	movl   $0xf010ae3f,0xc(%esp)
f010190d:	f0 
f010190e:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0101915:	f0 
f0101916:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
f010191d:	00 
f010191e:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101925:	e8 5c e7 ff ff       	call   f0100086 <_panic>
		assert(pp0 < pages + npage);
f010192a:	39 4d e0             	cmp    %ecx,-0x20(%ebp)
f010192d:	77 34                	ja     f0101963 <check_page_alloc+0x138>
f010192f:	c7 44 24 0c 61 ae 10 	movl   $0xf010ae61,0xc(%esp)
f0101936:	f0 
f0101937:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f010193e:	f0 
f010193f:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
f0101946:	00 
f0101947:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f010194e:	e8 33 e7 ff ff       	call   f0100086 <_panic>
		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp0) != 0);
		assert(page2pa(pp0) != IOPHYSMEM);
		assert(page2pa(pp0) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp0) != EXTPHYSMEM);
		assert(page2kva(pp0) != ROUNDDOWN(boot_freemem - 1, PGSIZE));
f0101953:	a1 b4 95 1b f0       	mov    0xf01b95b4,%eax
f0101958:	83 e8 01             	sub    $0x1,%eax
f010195b:	89 c7                	mov    %eax,%edi
f010195d:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101963:	89 c8                	mov    %ecx,%eax
f0101965:	29 d8                	sub    %ebx,%eax
f0101967:	c1 f8 02             	sar    $0x2,%eax
f010196a:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101970:	89 c2                	mov    %eax,%edx
f0101972:	c1 e2 0c             	shl    $0xc,%edx
		// check that we didn't corrupt the free list itself
		assert(pp0 >= pages);
		assert(pp0 < pages + npage);

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp0) != 0);
f0101975:	85 d2                	test   %edx,%edx
f0101977:	75 24                	jne    f010199d <check_page_alloc+0x172>
f0101979:	c7 44 24 0c 75 ae 10 	movl   $0xf010ae75,0xc(%esp)
f0101980:	f0 
f0101981:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0101988:	f0 
f0101989:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
f0101990:	00 
f0101991:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101998:	e8 e9 e6 ff ff       	call   f0100086 <_panic>
		assert(page2pa(pp0) != IOPHYSMEM);
f010199d:	81 fa 00 00 0a 00    	cmp    $0xa0000,%edx
f01019a3:	75 24                	jne    f01019c9 <check_page_alloc+0x19e>
f01019a5:	c7 44 24 0c 87 ae 10 	movl   $0xf010ae87,0xc(%esp)
f01019ac:	f0 
f01019ad:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f01019b4:	f0 
f01019b5:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
f01019bc:	00 
f01019bd:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f01019c4:	e8 bd e6 ff ff       	call   f0100086 <_panic>
		assert(page2pa(pp0) != EXTPHYSMEM - PGSIZE);
f01019c9:	81 fa 00 f0 0f 00    	cmp    $0xff000,%edx
f01019cf:	75 24                	jne    f01019f5 <check_page_alloc+0x1ca>
f01019d1:	c7 44 24 0c ac a8 10 	movl   $0xf010a8ac,0xc(%esp)
f01019d8:	f0 
f01019d9:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f01019e0:	f0 
f01019e1:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
f01019e8:	00 
f01019e9:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f01019f0:	e8 91 e6 ff ff       	call   f0100086 <_panic>
		assert(page2pa(pp0) != EXTPHYSMEM);
f01019f5:	81 fa 00 00 10 00    	cmp    $0x100000,%edx
f01019fb:	75 24                	jne    f0101a21 <check_page_alloc+0x1f6>
f01019fd:	c7 44 24 0c a1 ae 10 	movl   $0xf010aea1,0xc(%esp)
f0101a04:	f0 
f0101a05:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0101a0c:	f0 
f0101a0d:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
f0101a14:	00 
f0101a15:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101a1c:	e8 65 e6 ff ff       	call   f0100086 <_panic>
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0101a21:	89 d0                	mov    %edx,%eax
f0101a23:	c1 e8 0c             	shr    $0xc,%eax
f0101a26:	39 c6                	cmp    %eax,%esi
f0101a28:	77 20                	ja     f0101a4a <check_page_alloc+0x21f>
f0101a2a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101a2e:	c7 44 24 08 88 a4 10 	movl   $0xf010a488,0x8(%esp)
f0101a35:	f0 
f0101a36:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0101a3d:	00 
f0101a3e:	c7 04 24 0f ae 10 f0 	movl   $0xf010ae0f,(%esp)
f0101a45:	e8 3c e6 ff ff       	call   f0100086 <_panic>
f0101a4a:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101a50:	39 f8                	cmp    %edi,%eax
f0101a52:	75 24                	jne    f0101a78 <check_page_alloc+0x24d>
		assert(page2kva(pp0) != ROUNDDOWN(boot_freemem - 1, PGSIZE));
f0101a54:	c7 44 24 0c d0 a8 10 	movl   $0xf010a8d0,0xc(%esp)
f0101a5b:	f0 
f0101a5c:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0101a63:	f0 
f0101a64:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
f0101a6b:	00 
f0101a6c:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101a73:	e8 0e e6 ff ff       	call   f0100086 <_panic>
	// the free list, try to make sure it
	// eventually causes trouble.
	LIST_FOREACH(pp0, &page_free_list, pp_link)
		memset(page2kva(pp0), 0x97, 128);

	LIST_FOREACH(pp0, &page_free_list, pp_link) {
f0101a78:	8b 09                	mov    (%ecx),%ecx
f0101a7a:	89 4d ec             	mov    %ecx,-0x14(%ebp)
f0101a7d:	85 c9                	test   %ecx,%ecx
f0101a7f:	0f 85 7d fe ff ff    	jne    f0101902 <check_page_alloc+0xd7>
		assert(page2pa(pp0) != EXTPHYSMEM);
		assert(page2kva(pp0) != ROUNDDOWN(boot_freemem - 1, PGSIZE));
	}

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
f0101a85:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0101a8c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f0101a93:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	assert(page_alloc(&pp0) == 0);
f0101a9a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101a9d:	89 04 24             	mov    %eax,(%esp)
f0101aa0:	e8 e1 f7 ff ff       	call   f0101286 <page_alloc>
f0101aa5:	85 c0                	test   %eax,%eax
f0101aa7:	74 24                	je     f0101acd <check_page_alloc+0x2a2>
f0101aa9:	c7 44 24 0c bc ae 10 	movl   $0xf010aebc,0xc(%esp)
f0101ab0:	f0 
f0101ab1:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0101ab8:	f0 
f0101ab9:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
f0101ac0:	00 
f0101ac1:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101ac8:	e8 b9 e5 ff ff       	call   f0100086 <_panic>
	assert(page_alloc(&pp1) == 0);
f0101acd:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0101ad0:	89 04 24             	mov    %eax,(%esp)
f0101ad3:	e8 ae f7 ff ff       	call   f0101286 <page_alloc>
f0101ad8:	85 c0                	test   %eax,%eax
f0101ada:	74 24                	je     f0101b00 <check_page_alloc+0x2d5>
f0101adc:	c7 44 24 0c d2 ae 10 	movl   $0xf010aed2,0xc(%esp)
f0101ae3:	f0 
f0101ae4:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0101aeb:	f0 
f0101aec:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
f0101af3:	00 
f0101af4:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101afb:	e8 86 e5 ff ff       	call   f0100086 <_panic>
	assert(page_alloc(&pp2) == 0);
f0101b00:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101b03:	89 04 24             	mov    %eax,(%esp)
f0101b06:	e8 7b f7 ff ff       	call   f0101286 <page_alloc>
f0101b0b:	85 c0                	test   %eax,%eax
f0101b0d:	74 24                	je     f0101b33 <check_page_alloc+0x308>
f0101b0f:	c7 44 24 0c e8 ae 10 	movl   $0xf010aee8,0xc(%esp)
f0101b16:	f0 
f0101b17:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0101b1e:	f0 
f0101b1f:	c7 44 24 04 45 01 00 	movl   $0x145,0x4(%esp)
f0101b26:	00 
f0101b27:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101b2e:	e8 53 e5 ff ff       	call   f0100086 <_panic>

	assert(pp0);
f0101b33:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0101b36:	85 d2                	test   %edx,%edx
f0101b38:	75 24                	jne    f0101b5e <check_page_alloc+0x333>
f0101b3a:	c7 44 24 0c 0c af 10 	movl   $0xf010af0c,0xc(%esp)
f0101b41:	f0 
f0101b42:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0101b49:	f0 
f0101b4a:	c7 44 24 04 47 01 00 	movl   $0x147,0x4(%esp)
f0101b51:	00 
f0101b52:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101b59:	e8 28 e5 ff ff       	call   f0100086 <_panic>
	assert(pp1 && pp1 != pp0);
f0101b5e:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0101b61:	85 c9                	test   %ecx,%ecx
f0101b63:	74 04                	je     f0101b69 <check_page_alloc+0x33e>
f0101b65:	39 ca                	cmp    %ecx,%edx
f0101b67:	75 24                	jne    f0101b8d <check_page_alloc+0x362>
f0101b69:	c7 44 24 0c fe ae 10 	movl   $0xf010aefe,0xc(%esp)
f0101b70:	f0 
f0101b71:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0101b78:	f0 
f0101b79:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
f0101b80:	00 
f0101b81:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101b88:	e8 f9 e4 ff ff       	call   f0100086 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b8d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101b90:	85 db                	test   %ebx,%ebx
f0101b92:	74 08                	je     f0101b9c <check_page_alloc+0x371>
f0101b94:	39 d9                	cmp    %ebx,%ecx
f0101b96:	74 04                	je     f0101b9c <check_page_alloc+0x371>
f0101b98:	39 da                	cmp    %ebx,%edx
f0101b9a:	75 24                	jne    f0101bc0 <check_page_alloc+0x395>
f0101b9c:	c7 44 24 0c 08 a9 10 	movl   $0xf010a908,0xc(%esp)
f0101ba3:	f0 
f0101ba4:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0101bab:	f0 
f0101bac:	c7 44 24 04 49 01 00 	movl   $0x149,0x4(%esp)
f0101bb3:	00 
f0101bb4:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101bbb:	e8 c6 e4 ff ff       	call   f0100086 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101bc0:	8b 35 6c a5 1b f0    	mov    0xf01ba56c,%esi
	assert(page2pa(pp0) < npage*PGSIZE);
f0101bc6:	a1 60 a5 1b f0       	mov    0xf01ba560,%eax
f0101bcb:	89 c7                	mov    %eax,%edi
f0101bcd:	c1 e7 0c             	shl    $0xc,%edi
f0101bd0:	89 d0                	mov    %edx,%eax
f0101bd2:	29 f0                	sub    %esi,%eax
f0101bd4:	c1 f8 02             	sar    $0x2,%eax
f0101bd7:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101bdd:	c1 e0 0c             	shl    $0xc,%eax
f0101be0:	39 f8                	cmp    %edi,%eax
f0101be2:	72 24                	jb     f0101c08 <check_page_alloc+0x3dd>
f0101be4:	c7 44 24 0c 10 af 10 	movl   $0xf010af10,0xc(%esp)
f0101beb:	f0 
f0101bec:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0101bf3:	f0 
f0101bf4:	c7 44 24 04 4a 01 00 	movl   $0x14a,0x4(%esp)
f0101bfb:	00 
f0101bfc:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101c03:	e8 7e e4 ff ff       	call   f0100086 <_panic>
	assert(page2pa(pp1) < npage*PGSIZE);
f0101c08:	89 c8                	mov    %ecx,%eax
f0101c0a:	29 f0                	sub    %esi,%eax
f0101c0c:	c1 f8 02             	sar    $0x2,%eax
f0101c0f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101c15:	c1 e0 0c             	shl    $0xc,%eax
f0101c18:	39 c7                	cmp    %eax,%edi
f0101c1a:	77 24                	ja     f0101c40 <check_page_alloc+0x415>
f0101c1c:	c7 44 24 0c 2c af 10 	movl   $0xf010af2c,0xc(%esp)
f0101c23:	f0 
f0101c24:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0101c2b:	f0 
f0101c2c:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
f0101c33:	00 
f0101c34:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101c3b:	e8 46 e4 ff ff       	call   f0100086 <_panic>
	assert(page2pa(pp2) < npage*PGSIZE);
f0101c40:	89 d8                	mov    %ebx,%eax
f0101c42:	29 f0                	sub    %esi,%eax
f0101c44:	c1 f8 02             	sar    $0x2,%eax
f0101c47:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101c4d:	c1 e0 0c             	shl    $0xc,%eax
f0101c50:	39 c7                	cmp    %eax,%edi
f0101c52:	77 24                	ja     f0101c78 <check_page_alloc+0x44d>
f0101c54:	c7 44 24 0c 48 af 10 	movl   $0xf010af48,0xc(%esp)
f0101c5b:	f0 
f0101c5c:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0101c63:	f0 
f0101c64:	c7 44 24 04 4c 01 00 	movl   $0x14c,0x4(%esp)
f0101c6b:	00 
f0101c6c:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101c73:	e8 0e e4 ff ff       	call   f0100086 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101c78:	8b 1d b8 95 1b f0    	mov    0xf01b95b8,%ebx
	LIST_INIT(&page_free_list);
f0101c7e:	c7 05 b8 95 1b f0 00 	movl   $0x0,0xf01b95b8
f0101c85:	00 00 00 

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101c88:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0101c8b:	89 04 24             	mov    %eax,(%esp)
f0101c8e:	e8 f3 f5 ff ff       	call   f0101286 <page_alloc>
f0101c93:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101c96:	74 24                	je     f0101cbc <check_page_alloc+0x491>
f0101c98:	c7 44 24 0c 64 af 10 	movl   $0xf010af64,0xc(%esp)
f0101c9f:	f0 
f0101ca0:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0101ca7:	f0 
f0101ca8:	c7 44 24 04 53 01 00 	movl   $0x153,0x4(%esp)
f0101caf:	00 
f0101cb0:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101cb7:	e8 ca e3 ff ff       	call   f0100086 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101cbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101cbf:	89 04 24             	mov    %eax,(%esp)
f0101cc2:	e8 91 f3 ff ff       	call   f0101058 <page_free>
	page_free(pp1);
f0101cc7:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101cca:	89 04 24             	mov    %eax,(%esp)
f0101ccd:	e8 86 f3 ff ff       	call   f0101058 <page_free>
	page_free(pp2);
f0101cd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101cd5:	89 04 24             	mov    %eax,(%esp)
f0101cd8:	e8 7b f3 ff ff       	call   f0101058 <page_free>
	pp0 = pp1 = pp2 = 0;
f0101cdd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0101ce4:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f0101ceb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	assert(page_alloc(&pp0) == 0);
f0101cf2:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101cf5:	89 04 24             	mov    %eax,(%esp)
f0101cf8:	e8 89 f5 ff ff       	call   f0101286 <page_alloc>
f0101cfd:	85 c0                	test   %eax,%eax
f0101cff:	74 24                	je     f0101d25 <check_page_alloc+0x4fa>
f0101d01:	c7 44 24 0c bc ae 10 	movl   $0xf010aebc,0xc(%esp)
f0101d08:	f0 
f0101d09:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0101d10:	f0 
f0101d11:	c7 44 24 04 5a 01 00 	movl   $0x15a,0x4(%esp)
f0101d18:	00 
f0101d19:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101d20:	e8 61 e3 ff ff       	call   f0100086 <_panic>
	assert(page_alloc(&pp1) == 0);
f0101d25:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0101d28:	89 04 24             	mov    %eax,(%esp)
f0101d2b:	e8 56 f5 ff ff       	call   f0101286 <page_alloc>
f0101d30:	85 c0                	test   %eax,%eax
f0101d32:	74 24                	je     f0101d58 <check_page_alloc+0x52d>
f0101d34:	c7 44 24 0c d2 ae 10 	movl   $0xf010aed2,0xc(%esp)
f0101d3b:	f0 
f0101d3c:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0101d43:	f0 
f0101d44:	c7 44 24 04 5b 01 00 	movl   $0x15b,0x4(%esp)
f0101d4b:	00 
f0101d4c:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101d53:	e8 2e e3 ff ff       	call   f0100086 <_panic>
	assert(page_alloc(&pp2) == 0);
f0101d58:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101d5b:	89 04 24             	mov    %eax,(%esp)
f0101d5e:	e8 23 f5 ff ff       	call   f0101286 <page_alloc>
f0101d63:	85 c0                	test   %eax,%eax
f0101d65:	74 24                	je     f0101d8b <check_page_alloc+0x560>
f0101d67:	c7 44 24 0c e8 ae 10 	movl   $0xf010aee8,0xc(%esp)
f0101d6e:	f0 
f0101d6f:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0101d76:	f0 
f0101d77:	c7 44 24 04 5c 01 00 	movl   $0x15c,0x4(%esp)
f0101d7e:	00 
f0101d7f:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101d86:	e8 fb e2 ff ff       	call   f0100086 <_panic>
	assert(pp0);
f0101d8b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0101d8e:	85 c9                	test   %ecx,%ecx
f0101d90:	75 24                	jne    f0101db6 <check_page_alloc+0x58b>
f0101d92:	c7 44 24 0c 0c af 10 	movl   $0xf010af0c,0xc(%esp)
f0101d99:	f0 
f0101d9a:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0101da1:	f0 
f0101da2:	c7 44 24 04 5d 01 00 	movl   $0x15d,0x4(%esp)
f0101da9:	00 
f0101daa:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101db1:	e8 d0 e2 ff ff       	call   f0100086 <_panic>
	assert(pp1 && pp1 != pp0);
f0101db6:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0101db9:	85 d2                	test   %edx,%edx
f0101dbb:	74 04                	je     f0101dc1 <check_page_alloc+0x596>
f0101dbd:	39 d1                	cmp    %edx,%ecx
f0101dbf:	75 24                	jne    f0101de5 <check_page_alloc+0x5ba>
f0101dc1:	c7 44 24 0c fe ae 10 	movl   $0xf010aefe,0xc(%esp)
f0101dc8:	f0 
f0101dc9:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0101dd0:	f0 
f0101dd1:	c7 44 24 04 5e 01 00 	movl   $0x15e,0x4(%esp)
f0101dd8:	00 
f0101dd9:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101de0:	e8 a1 e2 ff ff       	call   f0100086 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101de5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101de8:	85 c0                	test   %eax,%eax
f0101dea:	74 08                	je     f0101df4 <check_page_alloc+0x5c9>
f0101dec:	39 c2                	cmp    %eax,%edx
f0101dee:	74 04                	je     f0101df4 <check_page_alloc+0x5c9>
f0101df0:	39 c1                	cmp    %eax,%ecx
f0101df2:	75 24                	jne    f0101e18 <check_page_alloc+0x5ed>
f0101df4:	c7 44 24 0c 08 a9 10 	movl   $0xf010a908,0xc(%esp)
f0101dfb:	f0 
f0101dfc:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0101e03:	f0 
f0101e04:	c7 44 24 04 5f 01 00 	movl   $0x15f,0x4(%esp)
f0101e0b:	00 
f0101e0c:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101e13:	e8 6e e2 ff ff       	call   f0100086 <_panic>
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101e18:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0101e1b:	89 04 24             	mov    %eax,(%esp)
f0101e1e:	e8 63 f4 ff ff       	call   f0101286 <page_alloc>
f0101e23:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101e26:	74 24                	je     f0101e4c <check_page_alloc+0x621>
f0101e28:	c7 44 24 0c 64 af 10 	movl   $0xf010af64,0xc(%esp)
f0101e2f:	f0 
f0101e30:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0101e37:	f0 
f0101e38:	c7 44 24 04 60 01 00 	movl   $0x160,0x4(%esp)
f0101e3f:	00 
f0101e40:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101e47:	e8 3a e2 ff ff       	call   f0100086 <_panic>

	// give free list back
	page_free_list = fl;
f0101e4c:	89 1d b8 95 1b f0    	mov    %ebx,0xf01b95b8

	// free the pages we took
	page_free(pp0);
f0101e52:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101e55:	89 04 24             	mov    %eax,(%esp)
f0101e58:	e8 fb f1 ff ff       	call   f0101058 <page_free>
	page_free(pp1);
f0101e5d:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101e60:	89 04 24             	mov    %eax,(%esp)
f0101e63:	e8 f0 f1 ff ff       	call   f0101058 <page_free>
	page_free(pp2);
f0101e68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101e6b:	89 04 24             	mov    %eax,(%esp)
f0101e6e:	e8 e5 f1 ff ff       	call   f0101058 <page_free>

	cprintf("check_page_alloc() succeeded!\n");
f0101e73:	c7 04 24 28 a9 10 f0 	movl   $0xf010a928,(%esp)
f0101e7a:	e8 58 1b 00 00       	call   f01039d7 <cprintf>
}
f0101e7f:	83 c4 2c             	add    $0x2c,%esp
f0101e82:	5b                   	pop    %ebx
f0101e83:	5e                   	pop    %esi
f0101e84:	5f                   	pop    %edi
f0101e85:	5d                   	pop    %ebp
f0101e86:	c3                   	ret    

f0101e87 <i386_vm_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
{
f0101e87:	55                   	push   %ebp
f0101e88:	89 e5                	mov    %esp,%ebp
f0101e8a:	57                   	push   %edi
f0101e8b:	56                   	push   %esi
f0101e8c:	53                   	push   %ebx
f0101e8d:	83 ec 3c             	sub    $0x3c,%esp
	// Delete this line:
	//panic("i386_vm_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	pgdir = boot_alloc(PGSIZE, PGSIZE);
f0101e90:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e95:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101e9a:	e8 61 f1 ff ff       	call   f0101000 <boot_alloc>
f0101e9f:	89 c3                	mov    %eax,%ebx
	memset(pgdir, 0, PGSIZE);
f0101ea1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ea8:	00 
f0101ea9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101eb0:	00 
f0101eb1:	89 04 24             	mov    %eax,(%esp)
f0101eb4:	e8 75 77 00 00       	call   f010962e <memset>
	boot_pgdir = pgdir;
f0101eb9:	89 1d 68 a5 1b f0    	mov    %ebx,0xf01ba568
	boot_cr3 = PADDR(pgdir);
f0101ebf:	89 d8                	mov    %ebx,%eax
f0101ec1:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0101ec7:	77 20                	ja     f0101ee9 <i386_vm_init+0x62>
f0101ec9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101ecd:	c7 44 24 08 0c a8 10 	movl   $0xf010a80c,0x8(%esp)
f0101ed4:	f0 
f0101ed5:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
f0101edc:	00 
f0101edd:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101ee4:	e8 9d e1 ff ff       	call   f0100086 <_panic>
f0101ee9:	05 00 00 00 10       	add    $0x10000000,%eax
f0101eee:	a3 64 a5 1b f0       	mov    %eax,0xf01ba564
	// a virtual page table at virtual address VPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel RW, user NONE
	pgdir[PDX(VPT)] = PADDR(pgdir)|PTE_W|PTE_P;
f0101ef3:	89 c2                	mov    %eax,%edx
f0101ef5:	83 ca 03             	or     $0x3,%edx
f0101ef8:	89 93 fc 0e 00 00    	mov    %edx,0xefc(%ebx)

	// same for UVPT
	// Permissions: kernel R, user R 
	pgdir[PDX(UVPT)] = PADDR(pgdir)|PTE_U|PTE_P;
f0101efe:	83 c8 05             	or     $0x5,%eax
f0101f01:	89 83 f4 0e 00 00    	mov    %eax,0xef4(%ebx)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct Page in this
	// array.  'npage' is the number of physical pages in memory.
	// User-level programs will get read-only access to the array as well.
	// Your code goes here:
	pages=(struct Page*)boot_alloc(npage*sizeof(struct Page),PGSIZE);
f0101f07:	a1 60 a5 1b f0       	mov    0xf01ba560,%eax
f0101f0c:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0101f0f:	c1 e0 02             	shl    $0x2,%eax
f0101f12:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f17:	e8 e4 f0 ff ff       	call   f0101000 <boot_alloc>
f0101f1c:	a3 6c a5 1b f0       	mov    %eax,0xf01ba56c

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs=(struct Env*)boot_alloc(NENV*sizeof(struct Env),PGSIZE);
f0101f21:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f26:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101f2b:	e8 d0 f0 ff ff       	call   f0101000 <boot_alloc>
f0101f30:	a3 c0 95 1b f0       	mov    %eax,0xf01b95c0
	//////////////////////////////////////////////////////////////////////
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_segment or page_insert
	page_init();
f0101f35:	e8 9a f1 ff ff       	call   f01010d4 <page_init>

	check_page_alloc();
f0101f3a:	e8 ec f8 ff ff       	call   f010182b <check_page_alloc>
	pte_t *ptep, *ptep1;
	void *va;
	int i;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
f0101f3f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0101f46:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f0101f4d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	assert(page_alloc(&pp0) == 0);
f0101f54:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101f57:	89 04 24             	mov    %eax,(%esp)
f0101f5a:	e8 27 f3 ff ff       	call   f0101286 <page_alloc>
f0101f5f:	85 c0                	test   %eax,%eax
f0101f61:	74 24                	je     f0101f87 <i386_vm_init+0x100>
f0101f63:	c7 44 24 0c bc ae 10 	movl   $0xf010aebc,0xc(%esp)
f0101f6a:	f0 
f0101f6b:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0101f72:	f0 
f0101f73:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f0101f7a:	00 
f0101f7b:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101f82:	e8 ff e0 ff ff       	call   f0100086 <_panic>
	assert(page_alloc(&pp1) == 0);
f0101f87:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0101f8a:	89 04 24             	mov    %eax,(%esp)
f0101f8d:	e8 f4 f2 ff ff       	call   f0101286 <page_alloc>
f0101f92:	85 c0                	test   %eax,%eax
f0101f94:	74 24                	je     f0101fba <i386_vm_init+0x133>
f0101f96:	c7 44 24 0c d2 ae 10 	movl   $0xf010aed2,0xc(%esp)
f0101f9d:	f0 
f0101f9e:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0101fa5:	f0 
f0101fa6:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f0101fad:	00 
f0101fae:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101fb5:	e8 cc e0 ff ff       	call   f0100086 <_panic>
	assert(page_alloc(&pp2) == 0);
f0101fba:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101fbd:	89 04 24             	mov    %eax,(%esp)
f0101fc0:	e8 c1 f2 ff ff       	call   f0101286 <page_alloc>
f0101fc5:	85 c0                	test   %eax,%eax
f0101fc7:	74 24                	je     f0101fed <i386_vm_init+0x166>
f0101fc9:	c7 44 24 0c e8 ae 10 	movl   $0xf010aee8,0xc(%esp)
f0101fd0:	f0 
f0101fd1:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0101fd8:	f0 
f0101fd9:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f0101fe0:	00 
f0101fe1:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0101fe8:	e8 99 e0 ff ff       	call   f0100086 <_panic>

	assert(pp0);
f0101fed:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0101ff0:	85 c9                	test   %ecx,%ecx
f0101ff2:	75 24                	jne    f0102018 <i386_vm_init+0x191>
f0101ff4:	c7 44 24 0c 0c af 10 	movl   $0xf010af0c,0xc(%esp)
f0101ffb:	f0 
f0101ffc:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102003:	f0 
f0102004:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
f010200b:	00 
f010200c:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102013:	e8 6e e0 ff ff       	call   f0100086 <_panic>
	assert(pp1 && pp1 != pp0);
f0102018:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010201b:	85 d2                	test   %edx,%edx
f010201d:	74 04                	je     f0102023 <i386_vm_init+0x19c>
f010201f:	39 d1                	cmp    %edx,%ecx
f0102021:	75 24                	jne    f0102047 <i386_vm_init+0x1c0>
f0102023:	c7 44 24 0c fe ae 10 	movl   $0xf010aefe,0xc(%esp)
f010202a:	f0 
f010202b:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102032:	f0 
f0102033:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f010203a:	00 
f010203b:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102042:	e8 3f e0 ff ff       	call   f0100086 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102047:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010204a:	85 c0                	test   %eax,%eax
f010204c:	74 08                	je     f0102056 <i386_vm_init+0x1cf>
f010204e:	39 c2                	cmp    %eax,%edx
f0102050:	74 04                	je     f0102056 <i386_vm_init+0x1cf>
f0102052:	39 c1                	cmp    %eax,%ecx
f0102054:	75 24                	jne    f010207a <i386_vm_init+0x1f3>
f0102056:	c7 44 24 0c 08 a9 10 	movl   $0xf010a908,0xc(%esp)
f010205d:	f0 
f010205e:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102065:	f0 
f0102066:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f010206d:	00 
f010206e:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102075:	e8 0c e0 ff ff       	call   f0100086 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010207a:	8b 35 b8 95 1b f0    	mov    0xf01b95b8,%esi
	LIST_INIT(&page_free_list);
f0102080:	c7 05 b8 95 1b f0 00 	movl   $0x0,0xf01b95b8
f0102087:	00 00 00 

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f010208a:	8d 45 f0             	lea    -0x10(%ebp),%eax
f010208d:	89 04 24             	mov    %eax,(%esp)
f0102090:	e8 f1 f1 ff ff       	call   f0101286 <page_alloc>
f0102095:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102098:	74 24                	je     f01020be <i386_vm_init+0x237>
f010209a:	c7 44 24 0c 64 af 10 	movl   $0xf010af64,0xc(%esp)
f01020a1:	f0 
f01020a2:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f01020a9:	f0 
f01020aa:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f01020b1:	00 
f01020b2:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f01020b9:	e8 c8 df ff ff       	call   f0100086 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(boot_pgdir, (void *) 0x0, &ptep) == NULL);
f01020be:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01020c1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01020c5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01020cc:	00 
f01020cd:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f01020d2:	89 04 24             	mov    %eax,(%esp)
f01020d5:	e8 41 f3 ff ff       	call   f010141b <page_lookup>
f01020da:	85 c0                	test   %eax,%eax
f01020dc:	74 24                	je     f0102102 <i386_vm_init+0x27b>
f01020de:	c7 44 24 0c 48 a9 10 	movl   $0xf010a948,0xc(%esp)
f01020e5:	f0 
f01020e6:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f01020ed:	f0 
f01020ee:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f01020f5:	00 
f01020f6:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f01020fd:	e8 84 df ff ff       	call   f0100086 <_panic>

	// there is no free memory, so we can't allocate a page table 
	assert(page_insert(boot_pgdir, pp1, 0x0, 0) < 0);
f0102102:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102109:	00 
f010210a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102111:	00 
f0102112:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102115:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102119:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f010211e:	89 04 24             	mov    %eax,(%esp)
f0102121:	e8 85 f5 ff ff       	call   f01016ab <page_insert>
f0102126:	85 c0                	test   %eax,%eax
f0102128:	78 24                	js     f010214e <i386_vm_init+0x2c7>
f010212a:	c7 44 24 0c 80 a9 10 	movl   $0xf010a980,0xc(%esp)
f0102131:	f0 
f0102132:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102139:	f0 
f010213a:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
f0102141:	00 
f0102142:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102149:	e8 38 df ff ff       	call   f0100086 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010214e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102151:	89 04 24             	mov    %eax,(%esp)
f0102154:	e8 ff ee ff ff       	call   f0101058 <page_free>
	assert(page_insert(boot_pgdir, pp1, 0x0, 0) == 0);
f0102159:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102160:	00 
f0102161:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102168:	00 
f0102169:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010216c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102170:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f0102175:	89 04 24             	mov    %eax,(%esp)
f0102178:	e8 2e f5 ff ff       	call   f01016ab <page_insert>
f010217d:	85 c0                	test   %eax,%eax
f010217f:	74 24                	je     f01021a5 <i386_vm_init+0x31e>
f0102181:	c7 44 24 0c ac a9 10 	movl   $0xf010a9ac,0xc(%esp)
f0102188:	f0 
f0102189:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102190:	f0 
f0102191:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f0102198:	00 
f0102199:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f01021a0:	e8 e1 de ff ff       	call   f0100086 <_panic>
	assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f01021a5:	8b 0d 68 a5 1b f0    	mov    0xf01ba568,%ecx
f01021ab:	8b 11                	mov    (%ecx),%edx
f01021ad:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01021b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01021b6:	2b 05 6c a5 1b f0    	sub    0xf01ba56c,%eax
f01021bc:	c1 f8 02             	sar    $0x2,%eax
f01021bf:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01021c5:	c1 e0 0c             	shl    $0xc,%eax
f01021c8:	39 c2                	cmp    %eax,%edx
f01021ca:	74 24                	je     f01021f0 <i386_vm_init+0x369>
f01021cc:	c7 44 24 0c d8 a9 10 	movl   $0xf010a9d8,0xc(%esp)
f01021d3:	f0 
f01021d4:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f01021db:	f0 
f01021dc:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f01021e3:	00 
f01021e4:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f01021eb:	e8 96 de ff ff       	call   f0100086 <_panic>
	assert(check_va2pa(boot_pgdir, 0x0) == page2pa(pp1));
f01021f0:	ba 00 00 00 00       	mov    $0x0,%edx
f01021f5:	89 c8                	mov    %ecx,%eax
f01021f7:	e8 20 f0 ff ff       	call   f010121c <check_va2pa>
f01021fc:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01021ff:	89 ca                	mov    %ecx,%edx
f0102201:	2b 15 6c a5 1b f0    	sub    0xf01ba56c,%edx
f0102207:	c1 fa 02             	sar    $0x2,%edx
f010220a:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102210:	c1 e2 0c             	shl    $0xc,%edx
f0102213:	39 d0                	cmp    %edx,%eax
f0102215:	74 24                	je     f010223b <i386_vm_init+0x3b4>
f0102217:	c7 44 24 0c 00 aa 10 	movl   $0xf010aa00,0xc(%esp)
f010221e:	f0 
f010221f:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102226:	f0 
f0102227:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
f010222e:	00 
f010222f:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102236:	e8 4b de ff ff       	call   f0100086 <_panic>
	assert(pp1->pp_ref == 1);
f010223b:	66 83 79 08 01       	cmpw   $0x1,0x8(%ecx)
f0102240:	74 24                	je     f0102266 <i386_vm_init+0x3df>
f0102242:	c7 44 24 0c 81 af 10 	movl   $0xf010af81,0xc(%esp)
f0102249:	f0 
f010224a:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102251:	f0 
f0102252:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0102259:	00 
f010225a:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102261:	e8 20 de ff ff       	call   f0100086 <_panic>
	assert(pp0->pp_ref == 1);
f0102266:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102269:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f010226e:	74 24                	je     f0102294 <i386_vm_init+0x40d>
f0102270:	c7 44 24 0c 92 af 10 	movl   $0xf010af92,0xc(%esp)
f0102277:	f0 
f0102278:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f010227f:	f0 
f0102280:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f0102287:	00 
f0102288:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f010228f:	e8 f2 dd ff ff       	call   f0100086 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f0102294:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010229b:	00 
f010229c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01022a3:	00 
f01022a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01022a7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01022ab:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f01022b0:	89 04 24             	mov    %eax,(%esp)
f01022b3:	e8 f3 f3 ff ff       	call   f01016ab <page_insert>
f01022b8:	85 c0                	test   %eax,%eax
f01022ba:	74 24                	je     f01022e0 <i386_vm_init+0x459>
f01022bc:	c7 44 24 0c 30 aa 10 	movl   $0xf010aa30,0xc(%esp)
f01022c3:	f0 
f01022c4:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f01022cb:	f0 
f01022cc:	c7 44 24 04 6c 03 00 	movl   $0x36c,0x4(%esp)
f01022d3:	00 
f01022d4:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f01022db:	e8 a6 dd ff ff       	call   f0100086 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f01022e0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022e5:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f01022ea:	e8 2d ef ff ff       	call   f010121c <check_va2pa>
f01022ef:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01022f2:	89 ca                	mov    %ecx,%edx
f01022f4:	2b 15 6c a5 1b f0    	sub    0xf01ba56c,%edx
f01022fa:	c1 fa 02             	sar    $0x2,%edx
f01022fd:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102303:	c1 e2 0c             	shl    $0xc,%edx
f0102306:	39 d0                	cmp    %edx,%eax
f0102308:	74 24                	je     f010232e <i386_vm_init+0x4a7>
f010230a:	c7 44 24 0c 68 aa 10 	movl   $0xf010aa68,0xc(%esp)
f0102311:	f0 
f0102312:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102319:	f0 
f010231a:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f0102321:	00 
f0102322:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102329:	e8 58 dd ff ff       	call   f0100086 <_panic>
	assert(pp2->pp_ref == 1);
f010232e:	66 83 79 08 01       	cmpw   $0x1,0x8(%ecx)
f0102333:	74 24                	je     f0102359 <i386_vm_init+0x4d2>
f0102335:	c7 44 24 0c a3 af 10 	movl   $0xf010afa3,0xc(%esp)
f010233c:	f0 
f010233d:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102344:	f0 
f0102345:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f010234c:	00 
f010234d:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102354:	e8 2d dd ff ff       	call   f0100086 <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0102359:	8d 45 f0             	lea    -0x10(%ebp),%eax
f010235c:	89 04 24             	mov    %eax,(%esp)
f010235f:	e8 22 ef ff ff       	call   f0101286 <page_alloc>
f0102364:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102367:	74 24                	je     f010238d <i386_vm_init+0x506>
f0102369:	c7 44 24 0c 64 af 10 	movl   $0xf010af64,0xc(%esp)
f0102370:	f0 
f0102371:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102378:	f0 
f0102379:	c7 44 24 04 71 03 00 	movl   $0x371,0x4(%esp)
f0102380:	00 
f0102381:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102388:	e8 f9 dc ff ff       	call   f0100086 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f010238d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102394:	00 
f0102395:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010239c:	00 
f010239d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01023a0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01023a4:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f01023a9:	89 04 24             	mov    %eax,(%esp)
f01023ac:	e8 fa f2 ff ff       	call   f01016ab <page_insert>
f01023b1:	85 c0                	test   %eax,%eax
f01023b3:	74 24                	je     f01023d9 <i386_vm_init+0x552>
f01023b5:	c7 44 24 0c 30 aa 10 	movl   $0xf010aa30,0xc(%esp)
f01023bc:	f0 
f01023bd:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f01023c4:	f0 
f01023c5:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f01023cc:	00 
f01023cd:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f01023d4:	e8 ad dc ff ff       	call   f0100086 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f01023d9:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023de:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f01023e3:	e8 34 ee ff ff       	call   f010121c <check_va2pa>
f01023e8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01023eb:	89 ca                	mov    %ecx,%edx
f01023ed:	2b 15 6c a5 1b f0    	sub    0xf01ba56c,%edx
f01023f3:	c1 fa 02             	sar    $0x2,%edx
f01023f6:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01023fc:	c1 e2 0c             	shl    $0xc,%edx
f01023ff:	39 d0                	cmp    %edx,%eax
f0102401:	74 24                	je     f0102427 <i386_vm_init+0x5a0>
f0102403:	c7 44 24 0c 68 aa 10 	movl   $0xf010aa68,0xc(%esp)
f010240a:	f0 
f010240b:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102412:	f0 
f0102413:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f010241a:	00 
f010241b:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102422:	e8 5f dc ff ff       	call   f0100086 <_panic>
	assert(pp2->pp_ref == 1);
f0102427:	66 83 79 08 01       	cmpw   $0x1,0x8(%ecx)
f010242c:	74 24                	je     f0102452 <i386_vm_init+0x5cb>
f010242e:	c7 44 24 0c a3 af 10 	movl   $0xf010afa3,0xc(%esp)
f0102435:	f0 
f0102436:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f010243d:	f0 
f010243e:	c7 44 24 04 76 03 00 	movl   $0x376,0x4(%esp)
f0102445:	00 
f0102446:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f010244d:	e8 34 dc ff ff       	call   f0100086 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(page_alloc(&pp) == -E_NO_MEM);
f0102452:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0102455:	89 04 24             	mov    %eax,(%esp)
f0102458:	e8 29 ee ff ff       	call   f0101286 <page_alloc>
f010245d:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102460:	74 24                	je     f0102486 <i386_vm_init+0x5ff>
f0102462:	c7 44 24 0c 64 af 10 	movl   $0xf010af64,0xc(%esp)
f0102469:	f0 
f010246a:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102471:	f0 
f0102472:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0102479:	00 
f010247a:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102481:	e8 00 dc ff ff       	call   f0100086 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = KADDR(PTE_ADDR(boot_pgdir[PDX(PGSIZE)]));
f0102486:	8b 0d 68 a5 1b f0    	mov    0xf01ba568,%ecx
f010248c:	8b 11                	mov    (%ecx),%edx
f010248e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102494:	89 d0                	mov    %edx,%eax
f0102496:	c1 e8 0c             	shr    $0xc,%eax
f0102499:	3b 05 60 a5 1b f0    	cmp    0xf01ba560,%eax
f010249f:	72 20                	jb     f01024c1 <i386_vm_init+0x63a>
f01024a1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01024a5:	c7 44 24 08 88 a4 10 	movl   $0xf010a488,0x8(%esp)
f01024ac:	f0 
f01024ad:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f01024b4:	00 
f01024b5:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f01024bc:	e8 c5 db ff ff       	call   f0100086 <_panic>
f01024c1:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01024c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
	assert(pgdir_walk(boot_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01024ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01024d1:	00 
f01024d2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01024d9:	00 
f01024da:	89 0c 24             	mov    %ecx,(%esp)
f01024dd:	e8 f9 ed ff ff       	call   f01012db <pgdir_walk>
f01024e2:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01024e5:	83 c2 04             	add    $0x4,%edx
f01024e8:	39 d0                	cmp    %edx,%eax
f01024ea:	74 24                	je     f0102510 <i386_vm_init+0x689>
f01024ec:	c7 44 24 0c 98 aa 10 	movl   $0xf010aa98,0xc(%esp)
f01024f3:	f0 
f01024f4:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f01024fb:	f0 
f01024fc:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0102503:	00 
f0102504:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f010250b:	e8 76 db ff ff       	call   f0100086 <_panic>

	// should be able to change permissions too.
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, PTE_U) == 0);
f0102510:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0102517:	00 
f0102518:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010251f:	00 
f0102520:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102523:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102527:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f010252c:	89 04 24             	mov    %eax,(%esp)
f010252f:	e8 77 f1 ff ff       	call   f01016ab <page_insert>
f0102534:	85 c0                	test   %eax,%eax
f0102536:	74 24                	je     f010255c <i386_vm_init+0x6d5>
f0102538:	c7 44 24 0c d8 aa 10 	movl   $0xf010aad8,0xc(%esp)
f010253f:	f0 
f0102540:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102547:	f0 
f0102548:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f010254f:	00 
f0102550:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102557:	e8 2a db ff ff       	call   f0100086 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f010255c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102561:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f0102566:	e8 b1 ec ff ff       	call   f010121c <check_va2pa>
f010256b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010256e:	89 ca                	mov    %ecx,%edx
f0102570:	2b 15 6c a5 1b f0    	sub    0xf01ba56c,%edx
f0102576:	c1 fa 02             	sar    $0x2,%edx
f0102579:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f010257f:	c1 e2 0c             	shl    $0xc,%edx
f0102582:	39 d0                	cmp    %edx,%eax
f0102584:	74 24                	je     f01025aa <i386_vm_init+0x723>
f0102586:	c7 44 24 0c 68 aa 10 	movl   $0xf010aa68,0xc(%esp)
f010258d:	f0 
f010258e:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102595:	f0 
f0102596:	c7 44 24 04 82 03 00 	movl   $0x382,0x4(%esp)
f010259d:	00 
f010259e:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f01025a5:	e8 dc da ff ff       	call   f0100086 <_panic>
	assert(pp2->pp_ref == 1);
f01025aa:	66 83 79 08 01       	cmpw   $0x1,0x8(%ecx)
f01025af:	74 24                	je     f01025d5 <i386_vm_init+0x74e>
f01025b1:	c7 44 24 0c a3 af 10 	movl   $0xf010afa3,0xc(%esp)
f01025b8:	f0 
f01025b9:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f01025c0:	f0 
f01025c1:	c7 44 24 04 83 03 00 	movl   $0x383,0x4(%esp)
f01025c8:	00 
f01025c9:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f01025d0:	e8 b1 da ff ff       	call   f0100086 <_panic>
	assert(*pgdir_walk(boot_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01025d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01025dc:	00 
f01025dd:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01025e4:	00 
f01025e5:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f01025ea:	89 04 24             	mov    %eax,(%esp)
f01025ed:	e8 e9 ec ff ff       	call   f01012db <pgdir_walk>
f01025f2:	f6 00 04             	testb  $0x4,(%eax)
f01025f5:	75 24                	jne    f010261b <i386_vm_init+0x794>
f01025f7:	c7 44 24 0c 14 ab 10 	movl   $0xf010ab14,0xc(%esp)
f01025fe:	f0 
f01025ff:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102606:	f0 
f0102607:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f010260e:	00 
f010260f:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102616:	e8 6b da ff ff       	call   f0100086 <_panic>
	assert(boot_pgdir[0] & PTE_U);
f010261b:	8b 15 68 a5 1b f0    	mov    0xf01ba568,%edx
f0102621:	f6 02 04             	testb  $0x4,(%edx)
f0102624:	75 24                	jne    f010264a <i386_vm_init+0x7c3>
f0102626:	c7 44 24 0c b4 af 10 	movl   $0xf010afb4,0xc(%esp)
f010262d:	f0 
f010262e:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102635:	f0 
f0102636:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f010263d:	00 
f010263e:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102645:	e8 3c da ff ff       	call   f0100086 <_panic>
	
	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(boot_pgdir, pp0, (void*) PTSIZE, 0) < 0);
f010264a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102651:	00 
f0102652:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102659:	00 
f010265a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010265d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102661:	89 14 24             	mov    %edx,(%esp)
f0102664:	e8 42 f0 ff ff       	call   f01016ab <page_insert>
f0102669:	85 c0                	test   %eax,%eax
f010266b:	78 24                	js     f0102691 <i386_vm_init+0x80a>
f010266d:	c7 44 24 0c 48 ab 10 	movl   $0xf010ab48,0xc(%esp)
f0102674:	f0 
f0102675:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f010267c:	f0 
f010267d:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f0102684:	00 
f0102685:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f010268c:	e8 f5 d9 ff ff       	call   f0100086 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(boot_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102691:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102698:	00 
f0102699:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01026a0:	00 
f01026a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01026a4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01026a8:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f01026ad:	89 04 24             	mov    %eax,(%esp)
f01026b0:	e8 f6 ef ff ff       	call   f01016ab <page_insert>
f01026b5:	85 c0                	test   %eax,%eax
f01026b7:	74 24                	je     f01026dd <i386_vm_init+0x856>
f01026b9:	c7 44 24 0c 7c ab 10 	movl   $0xf010ab7c,0xc(%esp)
f01026c0:	f0 
f01026c1:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f01026c8:	f0 
f01026c9:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
f01026d0:	00 
f01026d1:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f01026d8:	e8 a9 d9 ff ff       	call   f0100086 <_panic>
	assert(!(*pgdir_walk(boot_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01026dd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01026e4:	00 
f01026e5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01026ec:	00 
f01026ed:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f01026f2:	89 04 24             	mov    %eax,(%esp)
f01026f5:	e8 e1 eb ff ff       	call   f01012db <pgdir_walk>
f01026fa:	f6 00 04             	testb  $0x4,(%eax)
f01026fd:	74 24                	je     f0102723 <i386_vm_init+0x89c>
f01026ff:	c7 44 24 0c b4 ab 10 	movl   $0xf010abb4,0xc(%esp)
f0102706:	f0 
f0102707:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f010270e:	f0 
f010270f:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f0102716:	00 
f0102717:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f010271e:	e8 63 d9 ff ff       	call   f0100086 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(boot_pgdir, 0) == page2pa(pp1));
f0102723:	ba 00 00 00 00       	mov    $0x0,%edx
f0102728:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f010272d:	e8 ea ea ff ff       	call   f010121c <check_va2pa>
f0102732:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0102735:	2b 15 6c a5 1b f0    	sub    0xf01ba56c,%edx
f010273b:	c1 fa 02             	sar    $0x2,%edx
f010273e:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102744:	c1 e2 0c             	shl    $0xc,%edx
f0102747:	39 d0                	cmp    %edx,%eax
f0102749:	74 24                	je     f010276f <i386_vm_init+0x8e8>
f010274b:	c7 44 24 0c ec ab 10 	movl   $0xf010abec,0xc(%esp)
f0102752:	f0 
f0102753:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f010275a:	f0 
f010275b:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f0102762:	00 
f0102763:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f010276a:	e8 17 d9 ff ff       	call   f0100086 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f010276f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102774:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f0102779:	e8 9e ea ff ff       	call   f010121c <check_va2pa>
f010277e:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102781:	89 ca                	mov    %ecx,%edx
f0102783:	2b 15 6c a5 1b f0    	sub    0xf01ba56c,%edx
f0102789:	c1 fa 02             	sar    $0x2,%edx
f010278c:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102792:	c1 e2 0c             	shl    $0xc,%edx
f0102795:	39 d0                	cmp    %edx,%eax
f0102797:	74 24                	je     f01027bd <i386_vm_init+0x936>
f0102799:	c7 44 24 0c 18 ac 10 	movl   $0xf010ac18,0xc(%esp)
f01027a0:	f0 
f01027a1:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f01027a8:	f0 
f01027a9:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f01027b0:	00 
f01027b1:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f01027b8:	e8 c9 d8 ff ff       	call   f0100086 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01027bd:	66 83 79 08 02       	cmpw   $0x2,0x8(%ecx)
f01027c2:	74 24                	je     f01027e8 <i386_vm_init+0x961>
f01027c4:	c7 44 24 0c ca af 10 	movl   $0xf010afca,0xc(%esp)
f01027cb:	f0 
f01027cc:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f01027d3:	f0 
f01027d4:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f01027db:	00 
f01027dc:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f01027e3:	e8 9e d8 ff ff       	call   f0100086 <_panic>
	assert(pp2->pp_ref == 0);
f01027e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01027eb:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f01027f0:	74 24                	je     f0102816 <i386_vm_init+0x98f>
f01027f2:	c7 44 24 0c db af 10 	movl   $0xf010afdb,0xc(%esp)
f01027f9:	f0 
f01027fa:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102801:	f0 
f0102802:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f0102809:	00 
f010280a:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102811:	e8 70 d8 ff ff       	call   f0100086 <_panic>

	// pp2 should be returned by page_alloc
	assert(page_alloc(&pp) == 0 && pp == pp2);
f0102816:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0102819:	89 04 24             	mov    %eax,(%esp)
f010281c:	e8 65 ea ff ff       	call   f0101286 <page_alloc>
f0102821:	85 c0                	test   %eax,%eax
f0102823:	75 08                	jne    f010282d <i386_vm_init+0x9a6>
f0102825:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102828:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
f010282b:	74 24                	je     f0102851 <i386_vm_init+0x9ca>
f010282d:	c7 44 24 0c 48 ac 10 	movl   $0xf010ac48,0xc(%esp)
f0102834:	f0 
f0102835:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f010283c:	f0 
f010283d:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0102844:	00 
f0102845:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f010284c:	e8 35 d8 ff ff       	call   f0100086 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(boot_pgdir, 0x0);
f0102851:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102858:	00 
f0102859:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f010285e:	89 04 24             	mov    %eax,(%esp)
f0102861:	e8 61 ed ff ff       	call   f01015c7 <page_remove>
	assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f0102866:	ba 00 00 00 00       	mov    $0x0,%edx
f010286b:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f0102870:	e8 a7 e9 ff ff       	call   f010121c <check_va2pa>
f0102875:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102878:	74 24                	je     f010289e <i386_vm_init+0xa17>
f010287a:	c7 44 24 0c 6c ac 10 	movl   $0xf010ac6c,0xc(%esp)
f0102881:	f0 
f0102882:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102889:	f0 
f010288a:	c7 44 24 04 9a 03 00 	movl   $0x39a,0x4(%esp)
f0102891:	00 
f0102892:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102899:	e8 e8 d7 ff ff       	call   f0100086 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f010289e:	ba 00 10 00 00       	mov    $0x1000,%edx
f01028a3:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f01028a8:	e8 6f e9 ff ff       	call   f010121c <check_va2pa>
f01028ad:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01028b0:	89 ca                	mov    %ecx,%edx
f01028b2:	2b 15 6c a5 1b f0    	sub    0xf01ba56c,%edx
f01028b8:	c1 fa 02             	sar    $0x2,%edx
f01028bb:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01028c1:	c1 e2 0c             	shl    $0xc,%edx
f01028c4:	39 d0                	cmp    %edx,%eax
f01028c6:	74 24                	je     f01028ec <i386_vm_init+0xa65>
f01028c8:	c7 44 24 0c 18 ac 10 	movl   $0xf010ac18,0xc(%esp)
f01028cf:	f0 
f01028d0:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f01028d7:	f0 
f01028d8:	c7 44 24 04 9b 03 00 	movl   $0x39b,0x4(%esp)
f01028df:	00 
f01028e0:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f01028e7:	e8 9a d7 ff ff       	call   f0100086 <_panic>
	assert(pp1->pp_ref == 1);
f01028ec:	66 83 79 08 01       	cmpw   $0x1,0x8(%ecx)
f01028f1:	74 24                	je     f0102917 <i386_vm_init+0xa90>
f01028f3:	c7 44 24 0c 81 af 10 	movl   $0xf010af81,0xc(%esp)
f01028fa:	f0 
f01028fb:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102902:	f0 
f0102903:	c7 44 24 04 9c 03 00 	movl   $0x39c,0x4(%esp)
f010290a:	00 
f010290b:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102912:	e8 6f d7 ff ff       	call   f0100086 <_panic>
	assert(pp2->pp_ref == 0);
f0102917:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010291a:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f010291f:	74 24                	je     f0102945 <i386_vm_init+0xabe>
f0102921:	c7 44 24 0c db af 10 	movl   $0xf010afdb,0xc(%esp)
f0102928:	f0 
f0102929:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102930:	f0 
f0102931:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f0102938:	00 
f0102939:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102940:	e8 41 d7 ff ff       	call   f0100086 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(boot_pgdir, (void*) PGSIZE);
f0102945:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010294c:	00 
f010294d:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f0102952:	89 04 24             	mov    %eax,(%esp)
f0102955:	e8 6d ec ff ff       	call   f01015c7 <page_remove>
	assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f010295a:	ba 00 00 00 00       	mov    $0x0,%edx
f010295f:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f0102964:	e8 b3 e8 ff ff       	call   f010121c <check_va2pa>
f0102969:	83 f8 ff             	cmp    $0xffffffff,%eax
f010296c:	74 24                	je     f0102992 <i386_vm_init+0xb0b>
f010296e:	c7 44 24 0c 6c ac 10 	movl   $0xf010ac6c,0xc(%esp)
f0102975:	f0 
f0102976:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f010297d:	f0 
f010297e:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f0102985:	00 
f0102986:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f010298d:	e8 f4 d6 ff ff       	call   f0100086 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == ~0);
f0102992:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102997:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f010299c:	e8 7b e8 ff ff       	call   f010121c <check_va2pa>
f01029a1:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029a4:	74 24                	je     f01029ca <i386_vm_init+0xb43>
f01029a6:	c7 44 24 0c 90 ac 10 	movl   $0xf010ac90,0xc(%esp)
f01029ad:	f0 
f01029ae:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f01029b5:	f0 
f01029b6:	c7 44 24 04 a2 03 00 	movl   $0x3a2,0x4(%esp)
f01029bd:	00 
f01029be:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f01029c5:	e8 bc d6 ff ff       	call   f0100086 <_panic>
	assert(pp1->pp_ref == 0);
f01029ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01029cd:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f01029d2:	74 24                	je     f01029f8 <i386_vm_init+0xb71>
f01029d4:	c7 44 24 0c ec af 10 	movl   $0xf010afec,0xc(%esp)
f01029db:	f0 
f01029dc:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f01029e3:	f0 
f01029e4:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f01029eb:	00 
f01029ec:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f01029f3:	e8 8e d6 ff ff       	call   f0100086 <_panic>
	assert(pp2->pp_ref == 0);
f01029f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01029fb:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0102a00:	74 24                	je     f0102a26 <i386_vm_init+0xb9f>
f0102a02:	c7 44 24 0c db af 10 	movl   $0xf010afdb,0xc(%esp)
f0102a09:	f0 
f0102a0a:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102a11:	f0 
f0102a12:	c7 44 24 04 a4 03 00 	movl   $0x3a4,0x4(%esp)
f0102a19:	00 
f0102a1a:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102a21:	e8 60 d6 ff ff       	call   f0100086 <_panic>

	// so it should be returned by page_alloc
	assert(page_alloc(&pp) == 0 && pp == pp1);
f0102a26:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0102a29:	89 04 24             	mov    %eax,(%esp)
f0102a2c:	e8 55 e8 ff ff       	call   f0101286 <page_alloc>
f0102a31:	85 c0                	test   %eax,%eax
f0102a33:	75 08                	jne    f0102a3d <i386_vm_init+0xbb6>
f0102a35:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102a38:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0102a3b:	74 24                	je     f0102a61 <i386_vm_init+0xbda>
f0102a3d:	c7 44 24 0c b8 ac 10 	movl   $0xf010acb8,0xc(%esp)
f0102a44:	f0 
f0102a45:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102a4c:	f0 
f0102a4d:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f0102a54:	00 
f0102a55:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102a5c:	e8 25 d6 ff ff       	call   f0100086 <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0102a61:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0102a64:	89 04 24             	mov    %eax,(%esp)
f0102a67:	e8 1a e8 ff ff       	call   f0101286 <page_alloc>
f0102a6c:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102a6f:	74 24                	je     f0102a95 <i386_vm_init+0xc0e>
f0102a71:	c7 44 24 0c 64 af 10 	movl   $0xf010af64,0xc(%esp)
f0102a78:	f0 
f0102a79:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102a80:	f0 
f0102a81:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0102a88:	00 
f0102a89:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102a90:	e8 f1 d5 ff ff       	call   f0100086 <_panic>
	page_remove(boot_pgdir, 0x0);
	assert(pp2->pp_ref == 0);
#endif

	// forcibly take pp0 back
	assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f0102a95:	8b 0d 68 a5 1b f0    	mov    0xf01ba568,%ecx
f0102a9b:	8b 11                	mov    (%ecx),%edx
f0102a9d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102aa3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102aa6:	2b 05 6c a5 1b f0    	sub    0xf01ba56c,%eax
f0102aac:	c1 f8 02             	sar    $0x2,%eax
f0102aaf:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102ab5:	c1 e0 0c             	shl    $0xc,%eax
f0102ab8:	39 c2                	cmp    %eax,%edx
f0102aba:	74 24                	je     f0102ae0 <i386_vm_init+0xc59>
f0102abc:	c7 44 24 0c d8 a9 10 	movl   $0xf010a9d8,0xc(%esp)
f0102ac3:	f0 
f0102ac4:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102acb:	f0 
f0102acc:	c7 44 24 04 bd 03 00 	movl   $0x3bd,0x4(%esp)
f0102ad3:	00 
f0102ad4:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102adb:	e8 a6 d5 ff ff       	call   f0100086 <_panic>
	boot_pgdir[0] = 0;
f0102ae0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102ae6:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102ae9:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0102aee:	74 24                	je     f0102b14 <i386_vm_init+0xc8d>
f0102af0:	c7 44 24 0c 92 af 10 	movl   $0xf010af92,0xc(%esp)
f0102af7:	f0 
f0102af8:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102aff:	f0 
f0102b00:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f0102b07:	00 
f0102b08:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102b0f:	e8 72 d5 ff ff       	call   f0100086 <_panic>
	pp0->pp_ref = 0;
f0102b14:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
	
	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102b1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102b1d:	89 04 24             	mov    %eax,(%esp)
f0102b20:	e8 33 e5 ff ff       	call   f0101058 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(boot_pgdir, va, 1);
f0102b25:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102b2c:	00 
f0102b2d:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102b34:	00 
f0102b35:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f0102b3a:	89 04 24             	mov    %eax,(%esp)
f0102b3d:	e8 99 e7 ff ff       	call   f01012db <pgdir_walk>
f0102b42:	89 c1                	mov    %eax,%ecx
f0102b44:	89 45 e0             	mov    %eax,-0x20(%ebp)
	ptep1 = KADDR(PTE_ADDR(boot_pgdir[PDX(va)]));
f0102b47:	8b 3d 68 a5 1b f0    	mov    0xf01ba568,%edi
f0102b4d:	83 c7 04             	add    $0x4,%edi
f0102b50:	8b 17                	mov    (%edi),%edx
f0102b52:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102b58:	89 d0                	mov    %edx,%eax
f0102b5a:	c1 e8 0c             	shr    $0xc,%eax
f0102b5d:	3b 05 60 a5 1b f0    	cmp    0xf01ba560,%eax
f0102b63:	72 20                	jb     f0102b85 <i386_vm_init+0xcfe>
f0102b65:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102b69:	c7 44 24 08 88 a4 10 	movl   $0xf010a488,0x8(%esp)
f0102b70:	f0 
f0102b71:	c7 44 24 04 c6 03 00 	movl   $0x3c6,0x4(%esp)
f0102b78:	00 
f0102b79:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102b80:	e8 01 d5 ff ff       	call   f0100086 <_panic>
f0102b85:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
f0102b8b:	39 c1                	cmp    %eax,%ecx
f0102b8d:	74 24                	je     f0102bb3 <i386_vm_init+0xd2c>
	assert(ptep == ptep1 + PTX(va));
f0102b8f:	c7 44 24 0c fd af 10 	movl   $0xf010affd,0xc(%esp)
f0102b96:	f0 
f0102b97:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102b9e:	f0 
f0102b9f:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0102ba6:	00 
f0102ba7:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102bae:	e8 d3 d4 ff ff       	call   f0100086 <_panic>
	boot_pgdir[PDX(va)] = 0;
f0102bb3:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	pp0->pp_ref = 0;
f0102bb9:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102bbc:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0102bc2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102bc5:	2b 05 6c a5 1b f0    	sub    0xf01ba56c,%eax
f0102bcb:	c1 f8 02             	sar    $0x2,%eax
f0102bce:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102bd4:	89 c2                	mov    %eax,%edx
f0102bd6:	c1 e2 0c             	shl    $0xc,%edx
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0102bd9:	89 d0                	mov    %edx,%eax
f0102bdb:	c1 e8 0c             	shr    $0xc,%eax
f0102bde:	3b 05 60 a5 1b f0    	cmp    0xf01ba560,%eax
f0102be4:	72 20                	jb     f0102c06 <i386_vm_init+0xd7f>
f0102be6:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102bea:	c7 44 24 08 88 a4 10 	movl   $0xf010a488,0x8(%esp)
f0102bf1:	f0 
f0102bf2:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0102bf9:	00 
f0102bfa:	c7 04 24 0f ae 10 f0 	movl   $0xf010ae0f,(%esp)
f0102c01:	e8 80 d4 ff ff       	call   f0100086 <_panic>
	
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102c06:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c0d:	00 
f0102c0e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102c15:	00 
f0102c16:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0102c1c:	89 04 24             	mov    %eax,(%esp)
f0102c1f:	e8 0a 6a 00 00       	call   f010962e <memset>
	page_free(pp0);
f0102c24:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102c27:	89 04 24             	mov    %eax,(%esp)
f0102c2a:	e8 29 e4 ff ff       	call   f0101058 <page_free>
	pgdir_walk(boot_pgdir, 0x0, 1);
f0102c2f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102c36:	00 
f0102c37:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102c3e:	00 
f0102c3f:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f0102c44:	89 04 24             	mov    %eax,(%esp)
f0102c47:	e8 8f e6 ff ff       	call   f01012db <pgdir_walk>
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0102c4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102c4f:	2b 05 6c a5 1b f0    	sub    0xf01ba56c,%eax
f0102c55:	c1 f8 02             	sar    $0x2,%eax
f0102c58:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102c5e:	89 c2                	mov    %eax,%edx
f0102c60:	c1 e2 0c             	shl    $0xc,%edx
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0102c63:	89 d0                	mov    %edx,%eax
f0102c65:	c1 e8 0c             	shr    $0xc,%eax
f0102c68:	3b 05 60 a5 1b f0    	cmp    0xf01ba560,%eax
f0102c6e:	72 20                	jb     f0102c90 <i386_vm_init+0xe09>
f0102c70:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102c74:	c7 44 24 08 88 a4 10 	movl   $0xf010a488,0x8(%esp)
f0102c7b:	f0 
f0102c7c:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0102c83:	00 
f0102c84:	c7 04 24 0f ae 10 f0 	movl   $0xf010ae0f,(%esp)
f0102c8b:	e8 f6 d3 ff ff       	call   f0100086 <_panic>
f0102c90:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0102c96:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102c99:	b8 00 00 00 00       	mov    $0x0,%eax
	ptep = page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102c9e:	f6 84 82 00 00 00 f0 	testb  $0x1,-0x10000000(%edx,%eax,4)
f0102ca5:	01 
f0102ca6:	74 24                	je     f0102ccc <i386_vm_init+0xe45>
f0102ca8:	c7 44 24 0c 15 b0 10 	movl   $0xf010b015,0xc(%esp)
f0102caf:	f0 
f0102cb0:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102cb7:	f0 
f0102cb8:	c7 44 24 04 d1 03 00 	movl   $0x3d1,0x4(%esp)
f0102cbf:	00 
f0102cc0:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102cc7:	e8 ba d3 ff ff       	call   f0100086 <_panic>
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(boot_pgdir, 0x0, 1);
	ptep = page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102ccc:	83 c0 01             	add    $0x1,%eax
f0102ccf:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102cd4:	75 c8                	jne    f0102c9e <i386_vm_init+0xe17>
		assert((ptep[i] & PTE_P) == 0);
	boot_pgdir[0] = 0;
f0102cd6:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f0102cdb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102ce1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102ce4:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)

	// give free list back
	page_free_list = fl;
f0102cea:	89 35 b8 95 1b f0    	mov    %esi,0xf01b95b8

	// free the pages we took
	page_free(pp0);
f0102cf0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102cf3:	89 04 24             	mov    %eax,(%esp)
f0102cf6:	e8 5d e3 ff ff       	call   f0101058 <page_free>
	page_free(pp1);
f0102cfb:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102cfe:	89 04 24             	mov    %eax,(%esp)
f0102d01:	e8 52 e3 ff ff       	call   f0101058 <page_free>
	page_free(pp2);
f0102d06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102d09:	89 04 24             	mov    %eax,(%esp)
f0102d0c:	e8 47 e3 ff ff       	call   f0101058 <page_free>
	
	cprintf("page_check() succeeded!\n");
f0102d11:	c7 04 24 2c b0 10 f0 	movl   $0xf010b02c,(%esp)
f0102d18:	e8 ba 0c 00 00       	call   f01039d7 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_segment(boot_pgdir,UPAGES,npage*sizeof(struct Page),PADDR(pages),PTE_U|PTE_P);
f0102d1d:	a1 6c a5 1b f0       	mov    0xf01ba56c,%eax
f0102d22:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d27:	77 20                	ja     f0102d49 <i386_vm_init+0xec2>
f0102d29:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d2d:	c7 44 24 08 0c a8 10 	movl   $0xf010a80c,0x8(%esp)
f0102d34:	f0 
f0102d35:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
f0102d3c:	00 
f0102d3d:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102d44:	e8 3d d3 ff ff       	call   f0100086 <_panic>
f0102d49:	8b 0d 60 a5 1b f0    	mov    0xf01ba560,%ecx
f0102d4f:	8d 0c 49             	lea    (%ecx,%ecx,2),%ecx
f0102d52:	c1 e1 02             	shl    $0x2,%ecx
f0102d55:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102d5c:	00 
f0102d5d:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d62:	89 04 24             	mov    %eax,(%esp)
f0102d65:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102d6a:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f0102d6f:	e8 ae e8 ff ff       	call   f0101622 <boot_map_segment>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_segment(boot_pgdir,UENVS,NENV*sizeof(struct Env),PADDR(envs),PTE_U|PTE_P);
f0102d74:	a1 c0 95 1b f0       	mov    0xf01b95c0,%eax
f0102d79:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d7e:	77 20                	ja     f0102da0 <i386_vm_init+0xf19>
f0102d80:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d84:	c7 44 24 08 0c a8 10 	movl   $0xf010a80c,0x8(%esp)
f0102d8b:	f0 
f0102d8c:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
f0102d93:	00 
f0102d94:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102d9b:	e8 e6 d2 ff ff       	call   f0100086 <_panic>
f0102da0:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102da7:	00 
f0102da8:	05 00 00 00 10       	add    $0x10000000,%eax
f0102dad:	89 04 24             	mov    %eax,(%esp)
f0102db0:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102db5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102dba:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f0102dbf:	e8 5e e8 ff ff       	call   f0101622 <boot_map_segment>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_segment(boot_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W |PTE_P);
f0102dc4:	b8 00 60 12 f0       	mov    $0xf0126000,%eax
f0102dc9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102dce:	77 20                	ja     f0102df0 <i386_vm_init+0xf69>
f0102dd0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102dd4:	c7 44 24 08 0c a8 10 	movl   $0xf010a80c,0x8(%esp)
f0102ddb:	f0 
f0102ddc:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
f0102de3:	00 
f0102de4:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102deb:	e8 96 d2 ff ff       	call   f0100086 <_panic>
f0102df0:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102df7:	00 
f0102df8:	05 00 00 00 10       	add    $0x10000000,%eax
f0102dfd:	89 04 24             	mov    %eax,(%esp)
f0102e00:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102e05:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f0102e0a:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f0102e0f:	e8 0e e8 ff ff       	call   f0101622 <boot_map_segment>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here: 
	boot_map_segment(boot_pgdir,KERNBASE,0xffffffff-KERNBASE,0x0,PTE_W | PTE_P);
f0102e14:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102e1b:	00 
f0102e1c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102e23:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102e28:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102e2d:	a1 68 a5 1b f0       	mov    0xf01ba568,%eax
f0102e32:	e8 eb e7 ff ff       	call   f0101622 <boot_map_segment>
check_boot_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = boot_pgdir;
f0102e37:	8b 3d 68 a5 1b f0    	mov    0xf01ba568,%edi

	// check pages array
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
f0102e3d:	a1 60 a5 1b f0       	mov    0xf01ba560,%eax
f0102e42:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102e45:	8d 04 85 ff 0f 00 00 	lea    0xfff(,%eax,4),%eax
	for (i = 0; i < n; i += PGSIZE)
f0102e4c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102e51:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102e54:	74 7a                	je     f0102ed0 <i386_vm_init+0x1049>
f0102e56:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e5b:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0102e61:	89 f8                	mov    %edi,%eax
f0102e63:	e8 b4 e3 ff ff       	call   f010121c <check_va2pa>
f0102e68:	89 c2                	mov    %eax,%edx
f0102e6a:	a1 6c a5 1b f0       	mov    0xf01ba56c,%eax
f0102e6f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e74:	77 20                	ja     f0102e96 <i386_vm_init+0x100f>
f0102e76:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102e7a:	c7 44 24 08 0c a8 10 	movl   $0xf010a80c,0x8(%esp)
f0102e81:	f0 
f0102e82:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
f0102e89:	00 
f0102e8a:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102e91:	e8 f0 d1 ff ff       	call   f0100086 <_panic>
f0102e96:	8d 84 06 00 00 00 10 	lea    0x10000000(%esi,%eax,1),%eax
f0102e9d:	39 c2                	cmp    %eax,%edx
f0102e9f:	74 24                	je     f0102ec5 <i386_vm_init+0x103e>
f0102ea1:	c7 44 24 0c dc ac 10 	movl   $0xf010acdc,0xc(%esp)
f0102ea8:	f0 
f0102ea9:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102eb0:	f0 
f0102eb1:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
f0102eb8:	00 
f0102eb9:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102ec0:	e8 c1 d1 ff ff       	call   f0100086 <_panic>

	pgdir = boot_pgdir;

	// check pages array
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102ec5:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102ecb:	39 75 d0             	cmp    %esi,-0x30(%ebp)
f0102ece:	77 8b                	ja     f0102e5b <i386_vm_init+0xfd4>
f0102ed0:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
	
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102ed5:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
f0102edb:	89 f8                	mov    %edi,%eax
f0102edd:	e8 3a e3 ff ff       	call   f010121c <check_va2pa>
f0102ee2:	89 c2                	mov    %eax,%edx
f0102ee4:	a1 c0 95 1b f0       	mov    0xf01b95c0,%eax
f0102ee9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102eee:	77 20                	ja     f0102f10 <i386_vm_init+0x1089>
f0102ef0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102ef4:	c7 44 24 08 0c a8 10 	movl   $0xf010a80c,0x8(%esp)
f0102efb:	f0 
f0102efc:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
f0102f03:	00 
f0102f04:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102f0b:	e8 76 d1 ff ff       	call   f0100086 <_panic>
f0102f10:	8d 84 06 00 00 00 10 	lea    0x10000000(%esi,%eax,1),%eax
f0102f17:	39 c2                	cmp    %eax,%edx
f0102f19:	74 24                	je     f0102f3f <i386_vm_init+0x10b8>
f0102f1b:	c7 44 24 0c 10 ad 10 	movl   $0xf010ad10,0xc(%esp)
f0102f22:	f0 
f0102f23:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102f2a:	f0 
f0102f2b:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
f0102f32:	00 
f0102f33:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102f3a:	e8 47 d1 ff ff       	call   f0100086 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
	
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102f3f:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102f45:	81 fe 00 f0 01 00    	cmp    $0x1f000,%esi
f0102f4b:	75 88                	jne    f0102ed5 <i386_vm_init+0x104e>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npage * PGSIZE; i += PGSIZE)
f0102f4d:	a1 60 a5 1b f0       	mov    0xf01ba560,%eax
f0102f52:	c1 e0 0c             	shl    $0xc,%eax
f0102f55:	85 c0                	test   %eax,%eax
f0102f57:	74 4c                	je     f0102fa5 <i386_vm_init+0x111e>
f0102f59:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102f5e:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102f64:	89 f8                	mov    %edi,%eax
f0102f66:	e8 b1 e2 ff ff       	call   f010121c <check_va2pa>
f0102f6b:	39 f0                	cmp    %esi,%eax
f0102f6d:	74 24                	je     f0102f93 <i386_vm_init+0x110c>
f0102f6f:	c7 44 24 0c 44 ad 10 	movl   $0xf010ad44,0xc(%esp)
f0102f76:	f0 
f0102f77:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102f7e:	f0 
f0102f7f:	c7 44 24 04 8b 01 00 	movl   $0x18b,0x4(%esp)
f0102f86:	00 
f0102f87:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102f8e:	e8 f3 d0 ff ff       	call   f0100086 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npage * PGSIZE; i += PGSIZE)
f0102f93:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
f0102f99:	a1 60 a5 1b f0       	mov    0xf01ba560,%eax
f0102f9e:	c1 e0 0c             	shl    $0xc,%eax
f0102fa1:	39 f0                	cmp    %esi,%eax
f0102fa3:	77 b9                	ja     f0102f5e <i386_vm_init+0x10d7>
f0102fa5:	be 00 80 bf ef       	mov    $0xefbf8000,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102faa:	89 f2                	mov    %esi,%edx
f0102fac:	89 f8                	mov    %edi,%eax
f0102fae:	e8 69 e2 ff ff       	call   f010121c <check_va2pa>
f0102fb3:	8d 96 00 e0 52 10    	lea    0x1052e000(%esi),%edx
f0102fb9:	39 d0                	cmp    %edx,%eax
f0102fbb:	74 24                	je     f0102fe1 <i386_vm_init+0x115a>
f0102fbd:	c7 44 24 0c 6c ad 10 	movl   $0xf010ad6c,0xc(%esp)
f0102fc4:	f0 
f0102fc5:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0102fcc:	f0 
f0102fcd:	c7 44 24 04 8f 01 00 	movl   $0x18f,0x4(%esp)
f0102fd4:	00 
f0102fd5:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0102fdc:	e8 a5 d0 ff ff       	call   f0100086 <_panic>
f0102fe1:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npage * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102fe7:	81 fe 00 00 c0 ef    	cmp    $0xefc00000,%esi
f0102fed:	75 bb                	jne    f0102faa <i386_vm_init+0x1123>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102fef:	ba 00 00 80 ef       	mov    $0xef800000,%edx
f0102ff4:	89 f8                	mov    %edi,%eax
f0102ff6:	e8 21 e2 ff ff       	call   f010121c <check_va2pa>
f0102ffb:	ba 00 00 00 00       	mov    $0x0,%edx
f0103000:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103003:	74 24                	je     f0103029 <i386_vm_init+0x11a2>
f0103005:	c7 44 24 0c b4 ad 10 	movl   $0xf010adb4,0xc(%esp)
f010300c:	f0 
f010300d:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0103014:	f0 
f0103015:	c7 44 24 04 90 01 00 	movl   $0x190,0x4(%esp)
f010301c:	00 
f010301d:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f0103024:	e8 5d d0 ff ff       	call   f0100086 <_panic>

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0103029:	8d 82 45 fc ff ff    	lea    -0x3bb(%edx),%eax
f010302f:	83 f8 04             	cmp    $0x4,%eax
f0103032:	77 2e                	ja     f0103062 <i386_vm_init+0x11db>
		case PDX(VPT):
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i]);
f0103034:	83 3c 97 00          	cmpl   $0x0,(%edi,%edx,4)
f0103038:	0f 85 80 00 00 00    	jne    f01030be <i386_vm_init+0x1237>
f010303e:	c7 44 24 0c 45 b0 10 	movl   $0xf010b045,0xc(%esp)
f0103045:	f0 
f0103046:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f010304d:	f0 
f010304e:	c7 44 24 04 9a 01 00 	movl   $0x19a,0x4(%esp)
f0103055:	00 
f0103056:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f010305d:	e8 24 d0 ff ff       	call   f0100086 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE))
f0103062:	81 fa bf 03 00 00    	cmp    $0x3bf,%edx
f0103068:	76 2a                	jbe    f0103094 <i386_vm_init+0x120d>
				assert(pgdir[i]);
f010306a:	83 3c 97 00          	cmpl   $0x0,(%edi,%edx,4)
f010306e:	75 4e                	jne    f01030be <i386_vm_init+0x1237>
f0103070:	c7 44 24 0c 45 b0 10 	movl   $0xf010b045,0xc(%esp)
f0103077:	f0 
f0103078:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f010307f:	f0 
f0103080:	c7 44 24 04 9e 01 00 	movl   $0x19e,0x4(%esp)
f0103087:	00 
f0103088:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f010308f:	e8 f2 cf ff ff       	call   f0100086 <_panic>
			else
				assert(pgdir[i] == 0);
f0103094:	83 3c 97 00          	cmpl   $0x0,(%edi,%edx,4)
f0103098:	74 24                	je     f01030be <i386_vm_init+0x1237>
f010309a:	c7 44 24 0c 4e b0 10 	movl   $0xf010b04e,0xc(%esp)
f01030a1:	f0 
f01030a2:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f01030a9:	f0 
f01030aa:	c7 44 24 04 a0 01 00 	movl   $0x1a0,0x4(%esp)
f01030b1:	00 
f01030b2:	c7 04 24 03 ae 10 f0 	movl   $0xf010ae03,(%esp)
f01030b9:	e8 c8 cf ff ff       	call   f0100086 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) {
f01030be:	83 c2 01             	add    $0x1,%edx
f01030c1:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f01030c7:	0f 85 5c ff ff ff    	jne    f0103029 <i386_vm_init+0x11a2>
			else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_boot_pgdir() succeeded!\n");
f01030cd:	c7 04 24 e4 ad 10 f0 	movl   $0xf010ade4,(%esp)
f01030d4:	e8 fe 08 00 00       	call   f01039d7 <cprintf>
	// mapping, even though we are turning on paging and reconfiguring
	// segmentation.

	// Map VA 0:4MB same as VA KERNBASE, i.e. to PA 0:4MB.
	// (Limits our kernel to <4MB)
	pgdir[0] = pgdir[PDX(KERNBASE)];
f01030d9:	8b 83 00 0f 00 00    	mov    0xf00(%ebx),%eax
f01030df:	89 03                	mov    %eax,(%ebx)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01030e1:	a1 64 a5 1b f0       	mov    0xf01ba564,%eax
f01030e6:	0f 22 d8             	mov    %eax,%cr3

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01030e9:	0f 20 c0             	mov    %cr0,%eax
	// Install page table.
	lcr3(boot_cr3);

	// Turn on paging.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_TS|CR0_EM|CR0_MP;
f01030ec:	0d 2f 00 05 80       	or     $0x8005002f,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01030f1:	83 e0 f3             	and    $0xfffffff3,%eax
f01030f4:	0f 22 c0             	mov    %eax,%cr0

	// Current mapping: KERNBASE+x => x => x.
	// (x < 4MB so uses paging pgdir[0])

	// Reload all segment registers.
	asm volatile("lgdt gdt_pd");
f01030f7:	0f 01 15 50 e3 12 f0 	lgdtl  0xf012e350
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01030fe:	b8 23 00 00 00       	mov    $0x23,%eax
f0103103:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103105:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103107:	b0 10                	mov    $0x10,%al
f0103109:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f010310b:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010310d:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));  // reload cs
f010310f:	ea 16 31 10 f0 08 00 	ljmp   $0x8,$0xf0103116
	asm volatile("lldt %%ax" :: "a" (0));
f0103116:	b0 00                	mov    $0x0,%al
f0103118:	0f 00 d0             	lldt   %ax

	// Final mapping: KERNBASE+x => KERNBASE+x => x.

	// This mapping was only used after paging was turned on but
	// before the segment registers were reloaded.
	pgdir[0] = 0;
f010311b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103121:	a1 64 a5 1b f0       	mov    0xf01ba564,%eax
f0103126:	0f 22 d8             	mov    %eax,%cr3

	// Flush the TLB for good measure, to kill the pgdir[0] mapping.
	lcr3(boot_cr3);
}
f0103129:	83 c4 3c             	add    $0x3c,%esp
f010312c:	5b                   	pop    %ebx
f010312d:	5e                   	pop    %esi
f010312e:	5f                   	pop    %edi
f010312f:	5d                   	pop    %ebp
f0103130:	c3                   	ret    
f0103131:	00 00                	add    %al,(%eax)
	...

f0103134 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103134:	55                   	push   %ebp
f0103135:	89 e5                	mov    %esp,%ebp
f0103137:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010313a:	85 d2                	test   %edx,%edx
f010313c:	75 11                	jne    f010314f <envid2env+0x1b>
		*env_store = curenv;
f010313e:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f0103143:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103146:	89 02                	mov    %eax,(%edx)
f0103148:	b8 00 00 00 00       	mov    $0x0,%eax
f010314d:	eb 5f                	jmp    f01031ae <envid2env+0x7a>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010314f:	89 d0                	mov    %edx,%eax
f0103151:	25 ff 03 00 00       	and    $0x3ff,%eax
f0103156:	6b c0 7c             	imul   $0x7c,%eax,%eax
f0103159:	89 c1                	mov    %eax,%ecx
f010315b:	03 0d c0 95 1b f0    	add    0xf01b95c0,%ecx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103161:	83 79 54 00          	cmpl   $0x0,0x54(%ecx)
f0103165:	74 05                	je     f010316c <envid2env+0x38>
f0103167:	39 51 4c             	cmp    %edx,0x4c(%ecx)
f010316a:	74 10                	je     f010317c <envid2env+0x48>
		*env_store = 0;
f010316c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010316f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0103175:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010317a:	eb 32                	jmp    f01031ae <envid2env+0x7a>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010317c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0103180:	74 22                	je     f01031a4 <envid2env+0x70>
f0103182:	8b 15 c4 95 1b f0    	mov    0xf01b95c4,%edx
f0103188:	39 d1                	cmp    %edx,%ecx
f010318a:	74 18                	je     f01031a4 <envid2env+0x70>
f010318c:	8b 41 50             	mov    0x50(%ecx),%eax
f010318f:	3b 42 4c             	cmp    0x4c(%edx),%eax
f0103192:	74 10                	je     f01031a4 <envid2env+0x70>
		*env_store = 0;
f0103194:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103197:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
f010319d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01031a2:	eb 0a                	jmp    f01031ae <envid2env+0x7a>
		return -E_BAD_ENV;
	}

	*env_store = e;
f01031a4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031a7:	89 08                	mov    %ecx,(%eax)
f01031a9:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f01031ae:	5d                   	pop    %ebp
f01031af:	c3                   	ret    

f01031b0 <env_init>:
// Insert in reverse order, so that the first call to env_alloc()
// returns envs[0].
//
void
env_init(void)
{
f01031b0:	55                   	push   %ebp
f01031b1:	89 e5                	mov    %esp,%ebp
f01031b3:	53                   	push   %ebx
	// LAB 3: Your code here.
	int i;
	LIST_INIT(&env_free_list);
f01031b4:	c7 05 c8 95 1b f0 00 	movl   $0x0,0xf01b95c8
f01031bb:	00 00 00 
f01031be:	b9 84 ef 01 00       	mov    $0x1ef84,%ecx
f01031c3:	89 cb                	mov    %ecx,%ebx
	for(i=NENV-1;i>=0;i--)
	{
		envs[i].env_id=0;
f01031c5:	a1 c0 95 1b f0       	mov    0xf01b95c0,%eax
f01031ca:	c7 44 08 4c 00 00 00 	movl   $0x0,0x4c(%eax,%ecx,1)
f01031d1:	00 
		envs[i].env_status=ENV_FREE;
f01031d2:	a1 c0 95 1b f0       	mov    0xf01b95c0,%eax
f01031d7:	c7 44 08 54 00 00 00 	movl   $0x0,0x54(%eax,%ecx,1)
f01031de:	00 
		LIST_INSERT_HEAD(&env_free_list,&envs[i],env_link);	
f01031df:	8b 15 c8 95 1b f0    	mov    0xf01b95c8,%edx
f01031e5:	a1 c0 95 1b f0       	mov    0xf01b95c0,%eax
f01031ea:	89 54 08 44          	mov    %edx,0x44(%eax,%ecx,1)
f01031ee:	85 d2                	test   %edx,%edx
f01031f0:	74 14                	je     f0103206 <env_init+0x56>
f01031f2:	89 c8                	mov    %ecx,%eax
f01031f4:	03 05 c0 95 1b f0    	add    0xf01b95c0,%eax
f01031fa:	83 c0 44             	add    $0x44,%eax
f01031fd:	8b 15 c8 95 1b f0    	mov    0xf01b95c8,%edx
f0103203:	89 42 48             	mov    %eax,0x48(%edx)
f0103206:	89 d8                	mov    %ebx,%eax
f0103208:	03 05 c0 95 1b f0    	add    0xf01b95c0,%eax
f010320e:	a3 c8 95 1b f0       	mov    %eax,0xf01b95c8
f0103213:	c7 40 48 c8 95 1b f0 	movl   $0xf01b95c8,0x48(%eax)
f010321a:	83 e9 7c             	sub    $0x7c,%ecx
env_init(void)
{
	// LAB 3: Your code here.
	int i;
	LIST_INIT(&env_free_list);
	for(i=NENV-1;i>=0;i--)
f010321d:	83 f9 84             	cmp    $0xffffff84,%ecx
f0103220:	75 a1                	jne    f01031c3 <env_init+0x13>
	{
		envs[i].env_id=0;
		envs[i].env_status=ENV_FREE;
		LIST_INSERT_HEAD(&env_free_list,&envs[i],env_link);	
	}
}
f0103222:	5b                   	pop    %ebx
f0103223:	5d                   	pop    %ebp
f0103224:	c3                   	ret    

f0103225 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103225:	55                   	push   %ebp
f0103226:	89 e5                	mov    %esp,%ebp
f0103228:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f010322b:	8b 65 08             	mov    0x8(%ebp),%esp
f010322e:	61                   	popa   
f010322f:	07                   	pop    %es
f0103230:	1f                   	pop    %ds
f0103231:	83 c4 08             	add    $0x8,%esp
f0103234:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103235:	c7 44 24 08 5c b0 10 	movl   $0xf010b05c,0x8(%esp)
f010323c:	f0 
f010323d:	c7 44 24 04 b7 01 00 	movl   $0x1b7,0x4(%esp)
f0103244:	00 
f0103245:	c7 04 24 68 b0 10 f0 	movl   $0xf010b068,(%esp)
f010324c:	e8 35 ce ff ff       	call   f0100086 <_panic>

f0103251 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103251:	55                   	push   %ebp
f0103252:	89 e5                	mov    %esp,%ebp
f0103254:	83 ec 08             	sub    $0x8,%esp
f0103257:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.
	
	// LAB 3: Your code here.
	curenv=e;
f010325a:	a3 c4 95 1b f0       	mov    %eax,0xf01b95c4
	curenv->env_runs++;
f010325f:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(curenv->env_cr3);
f0103263:	8b 15 c4 95 1b f0    	mov    0xf01b95c4,%edx
f0103269:	8b 42 60             	mov    0x60(%edx),%eax
f010326c:	0f 22 d8             	mov    %eax,%cr3
	//cprintf("\nenv_run:curenvid=%x\n",curenv->env_id);
	env_pop_tf(&curenv->env_tf);
f010326f:	89 14 24             	mov    %edx,(%esp)
f0103272:	e8 ae ff ff ff       	call   f0103225 <env_pop_tf>

f0103277 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103277:	55                   	push   %ebp
f0103278:	89 e5                	mov    %esp,%ebp
f010327a:	53                   	push   %ebx
f010327b:	83 ec 24             	sub    $0x24,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = LIST_FIRST(&env_free_list)))
f010327e:	8b 1d c8 95 1b f0    	mov    0xf01b95c8,%ebx
f0103284:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103289:	85 db                	test   %ebx,%ebx
f010328b:	0f 84 9e 01 00 00    	je     f010342f <env_alloc+0x1b8>
//
static int
env_setup_vm(struct Env *e)
{
	int i, r;
	struct Page *p = NULL;
f0103291:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// Allocate a page for the page directory
	if ((r = page_alloc(&p)) < 0)
f0103298:	8d 45 f8             	lea    -0x8(%ebp),%eax
f010329b:	89 04 24             	mov    %eax,(%esp)
f010329e:	e8 e3 df ff ff       	call   f0101286 <page_alloc>
f01032a3:	85 c0                	test   %eax,%eax
f01032a5:	0f 88 84 01 00 00    	js     f010342f <env_alloc+0x1b8>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_cr3=page2pa(p);
f01032ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01032ae:	2b 05 6c a5 1b f0    	sub    0xf01ba56c,%eax
f01032b4:	c1 f8 02             	sar    $0x2,%eax
f01032b7:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01032bd:	c1 e0 0c             	shl    $0xc,%eax
f01032c0:	89 43 60             	mov    %eax,0x60(%ebx)
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f01032c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01032c6:	2b 05 6c a5 1b f0    	sub    0xf01ba56c,%eax
f01032cc:	c1 f8 02             	sar    $0x2,%eax
f01032cf:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01032d5:	89 c2                	mov    %eax,%edx
f01032d7:	c1 e2 0c             	shl    $0xc,%edx
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f01032da:	89 d0                	mov    %edx,%eax
f01032dc:	c1 e8 0c             	shr    $0xc,%eax
f01032df:	3b 05 60 a5 1b f0    	cmp    0xf01ba560,%eax
f01032e5:	72 20                	jb     f0103307 <env_alloc+0x90>
f01032e7:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01032eb:	c7 44 24 08 88 a4 10 	movl   $0xf010a488,0x8(%esp)
f01032f2:	f0 
f01032f3:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f01032fa:	00 
f01032fb:	c7 04 24 0f ae 10 f0 	movl   $0xf010ae0f,(%esp)
f0103302:	e8 7f cd ff ff       	call   f0100086 <_panic>
f0103307:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f010330d:	89 43 5c             	mov    %eax,0x5c(%ebx)
	e->env_pgdir=(pde_t*)page2kva(p);
	p->pp_ref++;
f0103310:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0103313:	66 83 40 08 01       	addw   $0x1,0x8(%eax)
	memset(e->env_pgdir,0,PGSIZE);//initialize env's pgdir
f0103318:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010331f:	00 
f0103320:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103327:	00 
f0103328:	8b 43 5c             	mov    0x5c(%ebx),%eax
f010332b:	89 04 24             	mov    %eax,(%esp)
f010332e:	e8 fb 62 00 00       	call   f010962e <memset>
f0103333:	b9 ec 0e 00 00       	mov    $0xeec,%ecx
	for(i=PDX(UTOP);i<NPDENTRIES;i++)//内核部分映射，直接从boot_pgdir拷贝
		e->env_pgdir[i]=boot_pgdir[i];
f0103338:	8b 43 5c             	mov    0x5c(%ebx),%eax
f010333b:	8b 15 68 a5 1b f0    	mov    0xf01ba568,%edx
f0103341:	8b 14 0a             	mov    (%edx,%ecx,1),%edx
f0103344:	89 14 08             	mov    %edx,(%eax,%ecx,1)
f0103347:	83 c1 04             	add    $0x4,%ecx
	// LAB 3: Your code here.
	e->env_cr3=page2pa(p);
	e->env_pgdir=(pde_t*)page2kva(p);
	p->pp_ref++;
	memset(e->env_pgdir,0,PGSIZE);//initialize env's pgdir
	for(i=PDX(UTOP);i<NPDENTRIES;i++)//内核部分映射，直接从boot_pgdir拷贝
f010334a:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
f0103350:	75 e6                	jne    f0103338 <env_alloc+0xc1>
		e->env_pgdir[i]=boot_pgdir[i];
	// VPT and UVPT map the env's own page table, with
	// different permissions.
	e->env_pgdir[PDX(VPT)]  = e->env_cr3 | PTE_P | PTE_W;
f0103352:	8b 53 5c             	mov    0x5c(%ebx),%edx
f0103355:	8b 43 60             	mov    0x60(%ebx),%eax
f0103358:	83 c8 03             	or     $0x3,%eax
f010335b:	89 82 fc 0e 00 00    	mov    %eax,0xefc(%edx)
	e->env_pgdir[PDX(UVPT)] = e->env_cr3 | PTE_P | PTE_U;
f0103361:	8b 53 5c             	mov    0x5c(%ebx),%edx
f0103364:	8b 43 60             	mov    0x60(%ebx),%eax
f0103367:	83 c8 05             	or     $0x5,%eax
f010336a:	89 82 f4 0e 00 00    	mov    %eax,0xef4(%edx)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103370:	8b 43 4c             	mov    0x4c(%ebx),%eax
f0103373:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103378:	89 c2                	mov    %eax,%edx
f010337a:	81 e2 00 fc ff ff    	and    $0xfffffc00,%edx
f0103380:	7f 05                	jg     f0103387 <env_alloc+0x110>
f0103382:	ba 00 10 00 00       	mov    $0x1000,%edx
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f0103387:	89 d8                	mov    %ebx,%eax
f0103389:	2b 05 c0 95 1b f0    	sub    0xf01b95c0,%eax
f010338f:	c1 f8 02             	sar    $0x2,%eax
f0103392:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
f0103398:	09 d0                	or     %edx,%eax
f010339a:	89 43 4c             	mov    %eax,0x4c(%ebx)
	
	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010339d:	8b 45 0c             	mov    0xc(%ebp),%eax
f01033a0:	89 43 50             	mov    %eax,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01033a3:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
	e->env_runs = 0;
f01033aa:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01033b1:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f01033b8:	00 
f01033b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01033c0:	00 
f01033c1:	89 1c 24             	mov    %ebx,(%esp)
f01033c4:	e8 65 62 00 00       	call   f010962e <memset>
	// Set up appropriate initial values for the segment registers.
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.
	e->env_tf.tf_ds = GD_UD | 3;
f01033c9:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01033cf:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01033d5:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01033db:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01033e2:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags|=FL_IF;
f01033e8:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01033ef:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01033f6:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)

	// If this is the file server (e == &envs[1]) give it I/O privileges.
	// LAB 5: Your code here.
	if(e==&envs[1])
f01033fd:	a1 c0 95 1b f0       	mov    0xf01b95c0,%eax
f0103402:	83 c0 7c             	add    $0x7c,%eax
f0103405:	39 d8                	cmp    %ebx,%eax
f0103407:	75 07                	jne    f0103410 <env_alloc+0x199>
		e->env_tf.tf_eflags|=FL_IOPL_3;
f0103409:	81 4b 38 00 30 00 00 	orl    $0x3000,0x38(%ebx)
	// commit the allocation
	LIST_REMOVE(e, env_link);
f0103410:	8b 53 44             	mov    0x44(%ebx),%edx
f0103413:	85 d2                	test   %edx,%edx
f0103415:	74 06                	je     f010341d <env_alloc+0x1a6>
f0103417:	8b 43 48             	mov    0x48(%ebx),%eax
f010341a:	89 42 48             	mov    %eax,0x48(%edx)
f010341d:	8b 53 48             	mov    0x48(%ebx),%edx
f0103420:	8b 43 44             	mov    0x44(%ebx),%eax
f0103423:	89 02                	mov    %eax,(%edx)
	*newenv_store = e;
f0103425:	8b 45 08             	mov    0x8(%ebp),%eax
f0103428:	89 18                	mov    %ebx,(%eax)
f010342a:	b8 00 00 00 00       	mov    $0x0,%eax

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f010342f:	83 c4 24             	add    $0x24,%esp
f0103432:	5b                   	pop    %ebx
f0103433:	5d                   	pop    %ebp
f0103434:	c3                   	ret    

f0103435 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size)
{
f0103435:	55                   	push   %ebp
f0103436:	89 e5                	mov    %esp,%ebp
f0103438:	57                   	push   %edi
f0103439:	56                   	push   %esi
f010343a:	53                   	push   %ebx
f010343b:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 3: Your code here.
	int r;
	struct Env *newenv;
	if((r=env_alloc(&newenv,0))<0)
f010343e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103445:	00 
f0103446:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0103449:	89 04 24             	mov    %eax,(%esp)
f010344c:	e8 26 fe ff ff       	call   f0103277 <env_alloc>
f0103451:	85 c0                	test   %eax,%eax
f0103453:	79 20                	jns    f0103475 <env_create+0x40>
		panic("env_create:%e",r);
f0103455:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103459:	c7 44 24 08 73 b0 10 	movl   $0xf010b073,0x8(%esp)
f0103460:	f0 
f0103461:	c7 44 24 04 5d 01 00 	movl   $0x15d,0x4(%esp)
f0103468:	00 
f0103469:	c7 04 24 68 b0 10 f0 	movl   $0xf010b068,(%esp)
f0103470:	e8 11 cc ff ff       	call   f0100086 <_panic>
	load_icode(newenv,binary,size);
f0103475:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103478:	89 45 e0             	mov    %eax,-0x20(%ebp)

static __inline uint32_t
rcr3(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr3,%0" : "=r" (val));
f010347b:	0f 20 da             	mov    %cr3,%edx
f010347e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103481:	8b 40 60             	mov    0x60(%eax),%eax
f0103484:	0f 22 d8             	mov    %eax,%cr3
	struct Proghdr *ph,*eph;
	struct Page *onepage;
	
	old_cr3=rcr3();//要在新环境中加载用户程序，所以必须切换到新环境的页目录
	lcr3(e->env_cr3);
	elfhdr=(struct Elf*)binary;
f0103487:	8b 45 08             	mov    0x8(%ebp),%eax
f010348a:	89 45 dc             	mov    %eax,-0x24(%ebp)

	if(elfhdr->e_magic!=ELF_MAGIC)
f010348d:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f0103493:	74 1c                	je     f01034b1 <env_create+0x7c>
		panic("This binary is not ELF format!\n");
f0103495:	c7 44 24 08 b4 b0 10 	movl   $0xf010b0b4,0x8(%esp)
f010349c:	f0 
f010349d:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
f01034a4:	00 
f01034a5:	c7 04 24 68 b0 10 f0 	movl   $0xf010b068,(%esp)
f01034ac:	e8 d5 cb ff ff       	call   f0100086 <_panic>
	ph = (struct Proghdr*)(binary+elfhdr->e_phoff);
f01034b1:	8b 75 08             	mov    0x8(%ebp),%esi
f01034b4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034b7:	03 72 1c             	add    0x1c(%edx),%esi
	eph = ph+elfhdr->e_phnum;
f01034ba:	0f b7 42 2c          	movzwl 0x2c(%edx),%eax
f01034be:	c1 e0 05             	shl    $0x5,%eax
f01034c1:	01 f0                	add    %esi,%eax
f01034c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
	for(;ph<eph;ph++){
f01034c6:	39 c6                	cmp    %eax,%esi
f01034c8:	0f 83 de 00 00 00    	jae    f01035ac <env_create+0x177>
		if(ph->p_type == ELF_PROG_LOAD)
f01034ce:	83 3e 01             	cmpl   $0x1,(%esi)
f01034d1:	0f 85 c9 00 00 00    	jne    f01035a0 <env_create+0x16b>
		{
			segment_alloc(e,(void*)ph->p_va,ph->p_memsz);
f01034d7:	8b 46 08             	mov    0x8(%esi),%eax
	// Hint: It is easier to use segment_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	uintptr_t a,last;
	struct Page *onepage;
	a=ROUNDDOWN((physaddr_t)va,PGSIZE);
f01034da:	89 c3                	mov    %eax,%ebx
f01034dc:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	last=ROUNDDOWN((physaddr_t)(va+len),PGSIZE);
f01034e2:	03 46 14             	add    0x14(%esi),%eax
f01034e5:	89 c7                	mov    %eax,%edi
f01034e7:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for(;;){
		if(page_alloc(&onepage)<0)
f01034ed:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01034f0:	89 04 24             	mov    %eax,(%esp)
f01034f3:	e8 8e dd ff ff       	call   f0101286 <page_alloc>
f01034f8:	85 c0                	test   %eax,%eax
f01034fa:	79 1c                	jns    f0103518 <env_create+0xe3>
			panic("Alloc physical page failed!\n");
f01034fc:	c7 44 24 08 81 b0 10 	movl   $0xf010b081,0x8(%esp)
f0103503:	f0 
f0103504:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
f010350b:	00 
f010350c:	c7 04 24 68 b0 10 f0 	movl   $0xf010b068,(%esp)
f0103513:	e8 6e cb ff ff       	call   f0100086 <_panic>
		//cprintf("segment_alloc:onepage physaddr=%x\n",page2pa(onepage));
		if(page_insert(e->env_pgdir,onepage,(void*)a,PTE_U|PTE_W)<0)
f0103518:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010351f:	00 
f0103520:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103524:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103527:	89 44 24 04          	mov    %eax,0x4(%esp)
f010352b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010352e:	8b 42 5c             	mov    0x5c(%edx),%eax
f0103531:	89 04 24             	mov    %eax,(%esp)
f0103534:	e8 72 e1 ff ff       	call   f01016ab <page_insert>
f0103539:	85 c0                	test   %eax,%eax
f010353b:	79 1c                	jns    f0103559 <env_create+0x124>
			panic("Insert page failed!\n");
f010353d:	c7 44 24 08 9e b0 10 	movl   $0xf010b09e,0x8(%esp)
f0103544:	f0 
f0103545:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
f010354c:	00 
f010354d:	c7 04 24 68 b0 10 f0 	movl   $0xf010b068,(%esp)
f0103554:	e8 2d cb ff ff       	call   f0100086 <_panic>
		if(a==last) break;
f0103559:	39 fb                	cmp    %edi,%ebx
f010355b:	74 08                	je     f0103565 <env_create+0x130>
		a=a+PGSIZE;
f010355d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103563:	eb 88                	jmp    f01034ed <env_create+0xb8>
	for(;ph<eph;ph++){
		if(ph->p_type == ELF_PROG_LOAD)
		{
			segment_alloc(e,(void*)ph->p_va,ph->p_memsz);
			//cprintf("p_va=%x binary+p_offset=%x filesz=%x memsz=%x\n",ph->p_va,binary+ph->p_offset,ph->p_filesz,ph->p_memsz);
			memset((void*)(ph->p_va+ph->p_filesz),0,ph->p_memsz-ph->p_filesz);
f0103565:	8b 56 10             	mov    0x10(%esi),%edx
f0103568:	8b 46 14             	mov    0x14(%esi),%eax
f010356b:	29 d0                	sub    %edx,%eax
f010356d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103571:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103578:	00 
f0103579:	03 56 08             	add    0x8(%esi),%edx
f010357c:	89 14 24             	mov    %edx,(%esp)
f010357f:	e8 aa 60 00 00       	call   f010962e <memset>
			memmove((void*)ph->p_va,(void*)(binary+ph->p_offset),ph->p_filesz);	
f0103584:	8b 46 10             	mov    0x10(%esi),%eax
f0103587:	89 44 24 08          	mov    %eax,0x8(%esp)
f010358b:	8b 45 08             	mov    0x8(%ebp),%eax
f010358e:	03 46 04             	add    0x4(%esi),%eax
f0103591:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103595:	8b 46 08             	mov    0x8(%esi),%eax
f0103598:	89 04 24             	mov    %eax,(%esp)
f010359b:	e8 e8 60 00 00       	call   f0109688 <memmove>

	if(elfhdr->e_magic!=ELF_MAGIC)
		panic("This binary is not ELF format!\n");
	ph = (struct Proghdr*)(binary+elfhdr->e_phoff);
	eph = ph+elfhdr->e_phnum;
	for(;ph<eph;ph++){
f01035a0:	83 c6 20             	add    $0x20,%esi
f01035a3:	39 75 d8             	cmp    %esi,-0x28(%ebp)
f01035a6:	0f 87 22 ff ff ff    	ja     f01034ce <env_create+0x99>
			memmove((void*)ph->p_va,(void*)(binary+ph->p_offset),ph->p_filesz);	
		}
	} 
	//cprintf("memsize=%x filesize=%x\n",ph->p_memsz,ph->p_filesz);
	//cprintf("e_entry=%x\n",elfhdr->e_entry);
	e->env_tf.tf_eip=elfhdr->e_entry;
f01035ac:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01035af:	8b 42 18             	mov    0x18(%edx),%eax
f01035b2:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01035b5:	89 42 30             	mov    %eax,0x30(%edx)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	if(page_alloc(&onepage)<0)
f01035b8:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01035bb:	89 04 24             	mov    %eax,(%esp)
f01035be:	e8 c3 dc ff ff       	call   f0101286 <page_alloc>
f01035c3:	85 c0                	test   %eax,%eax
f01035c5:	79 1c                	jns    f01035e3 <env_create+0x1ae>
              panic("Alloc one page in load_icode failed\n");
f01035c7:	c7 44 24 08 d4 b0 10 	movl   $0xf010b0d4,0x8(%esp)
f01035ce:	f0 
f01035cf:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
f01035d6:	00 
f01035d7:	c7 04 24 68 b0 10 f0 	movl   $0xf010b068,(%esp)
f01035de:	e8 a3 ca ff ff       	call   f0100086 <_panic>
        if(page_insert(e->env_pgdir,onepage,(void*)(USTACKTOP-PGSIZE),PTE_U|PTE_W)<0)
f01035e3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01035ea:	00 
f01035eb:	c7 44 24 08 00 d0 bf 	movl   $0xeebfd000,0x8(%esp)
f01035f2:	ee 
f01035f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01035f6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035fa:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01035fd:	8b 42 5c             	mov    0x5c(%edx),%eax
f0103600:	89 04 24             	mov    %eax,(%esp)
f0103603:	e8 a3 e0 ff ff       	call   f01016ab <page_insert>
f0103608:	85 c0                	test   %eax,%eax
f010360a:	79 1c                	jns    f0103628 <env_create+0x1f3>
              panic("Insert one page in load_icode failed\n");
f010360c:	c7 44 24 08 fc b0 10 	movl   $0xf010b0fc,0x8(%esp)
f0103613:	f0 
f0103614:	c7 44 24 04 4a 01 00 	movl   $0x14a,0x4(%esp)
f010361b:	00 
f010361c:	c7 04 24 68 b0 10 f0 	movl   $0xf010b068,(%esp)
f0103623:	e8 5e ca ff ff       	call   f0100086 <_panic>
	memset((void*)(USTACKTOP-PGSIZE),0,PGSIZE);
f0103628:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010362f:	00 
f0103630:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103637:	00 
f0103638:	c7 04 24 00 d0 bf ee 	movl   $0xeebfd000,(%esp)
f010363f:	e8 ea 5f 00 00       	call   f010962e <memset>
f0103644:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103647:	0f 22 d8             	mov    %eax,%cr3
	int r;
	struct Env *newenv;
	if((r=env_alloc(&newenv,0))<0)
		panic("env_create:%e",r);
	load_icode(newenv,binary,size);
}
f010364a:	83 c4 3c             	add    $0x3c,%esp
f010364d:	5b                   	pop    %ebx
f010364e:	5e                   	pop    %esi
f010364f:	5f                   	pop    %edi
f0103650:	5d                   	pop    %ebp
f0103651:	c3                   	ret    

f0103652 <env_free>:
//
// Frees env e and all memory it uses.
// 
void
env_free(struct Env *e)
{
f0103652:	55                   	push   %ebp
f0103653:	89 e5                	mov    %esp,%ebp
f0103655:	57                   	push   %edi
f0103656:	56                   	push   %esi
f0103657:	53                   	push   %ebx
f0103658:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t pa;
	
	// If freeing the current environment, switch to boot_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010365b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f0103662:	8b 45 08             	mov    0x8(%ebp),%eax
f0103665:	3b 05 c4 95 1b f0    	cmp    0xf01b95c4,%eax
f010366b:	75 0f                	jne    f010367c <env_free+0x2a>
f010366d:	a1 64 a5 1b f0       	mov    0xf01ba564,%eax
f0103672:	0f 22 d8             	mov    %eax,%cr3
f0103675:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f010367c:	8b 55 ec             	mov    -0x14(%ebp),%edx
f010367f:	c1 e2 02             	shl    $0x2,%edx
f0103682:	89 55 e8             	mov    %edx,-0x18(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103685:	8b 55 08             	mov    0x8(%ebp),%edx
f0103688:	8b 42 5c             	mov    0x5c(%edx),%eax
f010368b:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010368e:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0103691:	a8 01                	test   $0x1,%al
f0103693:	0f 84 bf 00 00 00    	je     f0103758 <env_free+0x106>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103699:	89 c6                	mov    %eax,%esi
f010369b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		pt = (pte_t*) KADDR(pa);
f01036a1:	89 f0                	mov    %esi,%eax
f01036a3:	c1 e8 0c             	shr    $0xc,%eax
f01036a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01036a9:	3b 05 60 a5 1b f0    	cmp    0xf01ba560,%eax
f01036af:	72 20                	jb     f01036d1 <env_free+0x7f>
f01036b1:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01036b5:	c7 44 24 08 88 a4 10 	movl   $0xf010a488,0x8(%esp)
f01036bc:	f0 
f01036bd:	c7 44 24 04 7e 01 00 	movl   $0x17e,0x4(%esp)
f01036c4:	00 
f01036c5:	c7 04 24 68 b0 10 f0 	movl   $0xf010b068,(%esp)
f01036cc:	e8 b5 c9 ff ff       	call   f0100086 <_panic>
f01036d1:	bb 00 00 00 00       	mov    $0x0,%ebx

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01036d6:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01036d9:	c1 e7 16             	shl    $0x16,%edi
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
f01036dc:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01036e3:	01 
f01036e4:	74 19                	je     f01036ff <env_free+0xad>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01036e6:	89 d8                	mov    %ebx,%eax
f01036e8:	c1 e0 0c             	shl    $0xc,%eax
f01036eb:	09 f8                	or     %edi,%eax
f01036ed:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036f1:	8b 55 08             	mov    0x8(%ebp),%edx
f01036f4:	8b 42 5c             	mov    0x5c(%edx),%eax
f01036f7:	89 04 24             	mov    %eax,(%esp)
f01036fa:	e8 c8 de ff ff       	call   f01015c7 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01036ff:	83 c3 01             	add    $0x1,%ebx
f0103702:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103708:	75 d2                	jne    f01036dc <env_free+0x8a>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010370a:	8b 55 08             	mov    0x8(%ebp),%edx
f010370d:	8b 42 5c             	mov    0x5c(%edx),%eax
f0103710:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103713:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f010371a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010371d:	3b 05 60 a5 1b f0    	cmp    0xf01ba560,%eax
f0103723:	72 1c                	jb     f0103741 <env_free+0xef>
		panic("pa2page called with invalid pa");
f0103725:	c7 44 24 08 30 a8 10 	movl   $0xf010a830,0x8(%esp)
f010372c:	f0 
f010372d:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0103734:	00 
f0103735:	c7 04 24 0f ae 10 f0 	movl   $0xf010ae0f,(%esp)
f010373c:	e8 45 c9 ff ff       	call   f0100086 <_panic>
		page_decref(pa2page(pa));
f0103741:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103744:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0103747:	c1 e0 02             	shl    $0x2,%eax
f010374a:	03 05 6c a5 1b f0    	add    0xf01ba56c,%eax
f0103750:	89 04 24             	mov    %eax,(%esp)
f0103753:	e8 3d d9 ff ff       	call   f0101095 <page_decref>
	// Note the environment's demise.
	//cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103758:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
f010375c:	81 7d ec bb 03 00 00 	cmpl   $0x3bb,-0x14(%ebp)
f0103763:	0f 85 13 ff ff ff    	jne    f010367c <env_free+0x2a>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = e->env_cr3;
f0103769:	8b 55 08             	mov    0x8(%ebp),%edx
f010376c:	8b 42 60             	mov    0x60(%edx),%eax
	e->env_pgdir = 0;
f010376f:	c7 42 5c 00 00 00 00 	movl   $0x0,0x5c(%edx)
	e->env_cr3 = 0;
f0103776:	c7 42 60 00 00 00 00 	movl   $0x0,0x60(%edx)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f010377d:	c1 e8 0c             	shr    $0xc,%eax
f0103780:	3b 05 60 a5 1b f0    	cmp    0xf01ba560,%eax
f0103786:	72 1c                	jb     f01037a4 <env_free+0x152>
		panic("pa2page called with invalid pa");
f0103788:	c7 44 24 08 30 a8 10 	movl   $0xf010a830,0x8(%esp)
f010378f:	f0 
f0103790:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0103797:	00 
f0103798:	c7 04 24 0f ae 10 f0 	movl   $0xf010ae0f,(%esp)
f010379f:	e8 e2 c8 ff ff       	call   f0100086 <_panic>
	page_decref(pa2page(pa));
f01037a4:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01037a7:	c1 e0 02             	shl    $0x2,%eax
f01037aa:	03 05 6c a5 1b f0    	add    0xf01ba56c,%eax
f01037b0:	89 04 24             	mov    %eax,(%esp)
f01037b3:	e8 dd d8 ff ff       	call   f0101095 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01037b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01037bb:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	LIST_INSERT_HEAD(&env_free_list, e, env_link);
f01037c2:	a1 c8 95 1b f0       	mov    0xf01b95c8,%eax
f01037c7:	8b 55 08             	mov    0x8(%ebp),%edx
f01037ca:	89 42 44             	mov    %eax,0x44(%edx)
f01037cd:	85 c0                	test   %eax,%eax
f01037cf:	74 0e                	je     f01037df <env_free+0x18d>
f01037d1:	8b 55 08             	mov    0x8(%ebp),%edx
f01037d4:	83 c2 44             	add    $0x44,%edx
f01037d7:	a1 c8 95 1b f0       	mov    0xf01b95c8,%eax
f01037dc:	89 50 48             	mov    %edx,0x48(%eax)
f01037df:	8b 45 08             	mov    0x8(%ebp),%eax
f01037e2:	a3 c8 95 1b f0       	mov    %eax,0xf01b95c8
f01037e7:	c7 40 48 c8 95 1b f0 	movl   $0xf01b95c8,0x48(%eax)
}
f01037ee:	83 c4 1c             	add    $0x1c,%esp
f01037f1:	5b                   	pop    %ebx
f01037f2:	5e                   	pop    %esi
f01037f3:	5f                   	pop    %edi
f01037f4:	5d                   	pop    %ebp
f01037f5:	c3                   	ret    

f01037f6 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) 
{
f01037f6:	55                   	push   %ebp
f01037f7:	89 e5                	mov    %esp,%ebp
f01037f9:	53                   	push   %ebx
f01037fa:	83 ec 04             	sub    $0x4,%esp
f01037fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	env_free(e);
f0103800:	89 1c 24             	mov    %ebx,(%esp)
f0103803:	e8 4a fe ff ff       	call   f0103652 <env_free>

	if (curenv == e) {
f0103808:	39 1d c4 95 1b f0    	cmp    %ebx,0xf01b95c4
f010380e:	75 0f                	jne    f010381f <env_destroy+0x29>
		curenv = NULL;
f0103810:	c7 05 c4 95 1b f0 00 	movl   $0x0,0xf01b95c4
f0103817:	00 00 00 
		sched_yield();
f010381a:	e8 1d 13 00 00       	call   f0104b3c <sched_yield>
	}
}
f010381f:	83 c4 04             	add    $0x4,%esp
f0103822:	5b                   	pop    %ebx
f0103823:	5d                   	pop    %ebp
f0103824:	c3                   	ret    
f0103825:	00 00                	add    %al,(%eax)
	...

f0103828 <mc146818_read>:
#include <kern/picirq.h>


unsigned
mc146818_read(unsigned reg)
{
f0103828:	55                   	push   %ebp
f0103829:	89 e5                	mov    %esp,%ebp
f010382b:	8b 45 08             	mov    0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010382e:	ba 70 00 00 00       	mov    $0x70,%edx
f0103833:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103834:	b2 71                	mov    $0x71,%dl
f0103836:	ec                   	in     (%dx),%al
f0103837:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f010383a:	5d                   	pop    %ebp
f010383b:	c3                   	ret    

f010383c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010383c:	55                   	push   %ebp
f010383d:	89 e5                	mov    %esp,%ebp
f010383f:	8b 45 08             	mov    0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103842:	ba 70 00 00 00       	mov    $0x70,%edx
f0103847:	ee                   	out    %al,(%dx)
f0103848:	b2 71                	mov    $0x71,%dl
f010384a:	0f b6 45 0c          	movzbl 0xc(%ebp),%eax
f010384e:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010384f:	5d                   	pop    %ebp
f0103850:	c3                   	ret    

f0103851 <kclock_init>:


void
kclock_init(void)
{
f0103851:	55                   	push   %ebp
f0103852:	89 e5                	mov    %esp,%ebp
f0103854:	83 ec 08             	sub    $0x8,%esp
f0103857:	b8 34 00 00 00       	mov    $0x34,%eax
f010385c:	ba 43 00 00 00       	mov    $0x43,%edx
f0103861:	ee                   	out    %al,(%dx)
f0103862:	b8 9c ff ff ff       	mov    $0xffffff9c,%eax
f0103867:	b2 40                	mov    $0x40,%dl
f0103869:	ee                   	out    %al,(%dx)
f010386a:	b8 2e 00 00 00       	mov    $0x2e,%eax
f010386f:	ee                   	out    %al,(%dx)
	/* initialize 8253 clock to interrupt 100 times/sec */
	outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
	outb(IO_TIMER1, TIMER_DIV(100) % 256);
	outb(IO_TIMER1, TIMER_DIV(100) / 256);
	cprintf("	Setup timer interrupts via 8259A\n");
f0103870:	c7 04 24 24 b1 10 f0 	movl   $0xf010b124,(%esp)
f0103877:	e8 5b 01 00 00       	call   f01039d7 <cprintf>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<0));
f010387c:	0f b7 05 58 e3 12 f0 	movzwl 0xf012e358,%eax
f0103883:	25 fe ff 00 00       	and    $0xfffe,%eax
f0103888:	89 04 24             	mov    %eax,(%esp)
f010388b:	e8 10 00 00 00       	call   f01038a0 <irq_setmask_8259A>
	cprintf("	unmasked timer interrupt\n");
f0103890:	c7 04 24 47 b1 10 f0 	movl   $0xf010b147,(%esp)
f0103897:	e8 3b 01 00 00       	call   f01039d7 <cprintf>
}
f010389c:	c9                   	leave  
f010389d:	c3                   	ret    
	...

f01038a0 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01038a0:	55                   	push   %ebp
f01038a1:	89 e5                	mov    %esp,%ebp
f01038a3:	56                   	push   %esi
f01038a4:	53                   	push   %ebx
f01038a5:	83 ec 10             	sub    $0x10,%esp
f01038a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01038ab:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f01038ad:	66 a3 58 e3 12 f0    	mov    %ax,0xf012e358
	if (!didinit)
f01038b3:	83 3d cc 95 1b f0 00 	cmpl   $0x0,0xf01b95cc
f01038ba:	74 55                	je     f0103911 <irq_setmask_8259A+0x71>
f01038bc:	ba 21 00 00 00       	mov    $0x21,%edx
f01038c1:	ee                   	out    %al,(%dx)
f01038c2:	89 f0                	mov    %esi,%eax
f01038c4:	66 c1 e8 08          	shr    $0x8,%ax
f01038c8:	b2 a1                	mov    $0xa1,%dl
f01038ca:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f01038cb:	c7 04 24 62 b1 10 f0 	movl   $0xf010b162,(%esp)
f01038d2:	e8 00 01 00 00       	call   f01039d7 <cprintf>
f01038d7:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
f01038dc:	0f b7 c6             	movzwl %si,%eax
f01038df:	89 c6                	mov    %eax,%esi
f01038e1:	f7 d6                	not    %esi
f01038e3:	89 f0                	mov    %esi,%eax
f01038e5:	89 d9                	mov    %ebx,%ecx
f01038e7:	d3 f8                	sar    %cl,%eax
f01038e9:	a8 01                	test   $0x1,%al
f01038eb:	74 10                	je     f01038fd <irq_setmask_8259A+0x5d>
			cprintf(" %d", i);
f01038ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01038f1:	c7 04 24 bc 3a 11 f0 	movl   $0xf0113abc,(%esp)
f01038f8:	e8 da 00 00 00       	call   f01039d7 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f01038fd:	83 c3 01             	add    $0x1,%ebx
f0103900:	83 fb 10             	cmp    $0x10,%ebx
f0103903:	75 de                	jne    f01038e3 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103905:	c7 04 24 c9 a2 10 f0 	movl   $0xf010a2c9,(%esp)
f010390c:	e8 c6 00 00 00       	call   f01039d7 <cprintf>
}
f0103911:	83 c4 10             	add    $0x10,%esp
f0103914:	5b                   	pop    %ebx
f0103915:	5e                   	pop    %esi
f0103916:	5d                   	pop    %ebp
f0103917:	c3                   	ret    

f0103918 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103918:	55                   	push   %ebp
f0103919:	89 e5                	mov    %esp,%ebp
f010391b:	83 ec 08             	sub    $0x8,%esp
	didinit = 1;
f010391e:	c7 05 cc 95 1b f0 01 	movl   $0x1,0xf01b95cc
f0103925:	00 00 00 
f0103928:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010392d:	ba 21 00 00 00       	mov    $0x21,%edx
f0103932:	ee                   	out    %al,(%dx)
f0103933:	b2 a1                	mov    $0xa1,%dl
f0103935:	ee                   	out    %al,(%dx)
f0103936:	b8 11 00 00 00       	mov    $0x11,%eax
f010393b:	b2 20                	mov    $0x20,%dl
f010393d:	ee                   	out    %al,(%dx)
f010393e:	b8 20 00 00 00       	mov    $0x20,%eax
f0103943:	b2 21                	mov    $0x21,%dl
f0103945:	ee                   	out    %al,(%dx)
f0103946:	b8 04 00 00 00       	mov    $0x4,%eax
f010394b:	ee                   	out    %al,(%dx)
f010394c:	b8 03 00 00 00       	mov    $0x3,%eax
f0103951:	ee                   	out    %al,(%dx)
f0103952:	b8 11 00 00 00       	mov    $0x11,%eax
f0103957:	b2 a0                	mov    $0xa0,%dl
f0103959:	ee                   	out    %al,(%dx)
f010395a:	b8 28 00 00 00       	mov    $0x28,%eax
f010395f:	b2 a1                	mov    $0xa1,%dl
f0103961:	ee                   	out    %al,(%dx)
f0103962:	b8 02 00 00 00       	mov    $0x2,%eax
f0103967:	ee                   	out    %al,(%dx)
f0103968:	b8 01 00 00 00       	mov    $0x1,%eax
f010396d:	ee                   	out    %al,(%dx)
f010396e:	b8 68 00 00 00       	mov    $0x68,%eax
f0103973:	b2 20                	mov    $0x20,%dl
f0103975:	ee                   	out    %al,(%dx)
f0103976:	b8 0a 00 00 00       	mov    $0xa,%eax
f010397b:	ee                   	out    %al,(%dx)
f010397c:	b8 68 00 00 00       	mov    $0x68,%eax
f0103981:	b2 a0                	mov    $0xa0,%dl
f0103983:	ee                   	out    %al,(%dx)
f0103984:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103989:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f010398a:	0f b7 05 58 e3 12 f0 	movzwl 0xf012e358,%eax
f0103991:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0103995:	74 0b                	je     f01039a2 <pic_init+0x8a>
		irq_setmask_8259A(irq_mask_8259A);
f0103997:	0f b7 c0             	movzwl %ax,%eax
f010399a:	89 04 24             	mov    %eax,(%esp)
f010399d:	e8 fe fe ff ff       	call   f01038a0 <irq_setmask_8259A>
}
f01039a2:	c9                   	leave  
f01039a3:	c3                   	ret    

f01039a4 <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f01039a4:	55                   	push   %ebp
f01039a5:	89 e5                	mov    %esp,%ebp
f01039a7:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01039aa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01039b1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01039b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01039bb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01039bf:	8d 45 fc             	lea    -0x4(%ebp),%eax
f01039c2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039c6:	c7 04 24 f4 39 10 f0 	movl   $0xf01039f4,(%esp)
f01039cd:	e8 13 55 00 00       	call   f0108ee5 <vprintfmt>
f01039d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
	return cnt;
}
f01039d5:	c9                   	leave  
f01039d6:	c3                   	ret    

f01039d7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01039d7:	55                   	push   %ebp
f01039d8:	89 e5                	mov    %esp,%ebp
f01039da:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01039dd:	8d 45 0c             	lea    0xc(%ebp),%eax
f01039e0:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
f01039e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039e7:	8b 45 08             	mov    0x8(%ebp),%eax
f01039ea:	89 04 24             	mov    %eax,(%esp)
f01039ed:	e8 b2 ff ff ff       	call   f01039a4 <vcprintf>
	va_end(ap);

	return cnt;
}
f01039f2:	c9                   	leave  
f01039f3:	c3                   	ret    

f01039f4 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01039f4:	55                   	push   %ebp
f01039f5:	89 e5                	mov    %esp,%ebp
f01039f7:	83 ec 08             	sub    $0x8,%esp
	cputchar(ch);
f01039fa:	8b 45 08             	mov    0x8(%ebp),%eax
f01039fd:	89 04 24             	mov    %eax,(%esp)
f0103a00:	e8 55 ca ff ff       	call   f010045a <cputchar>
	*cnt++;
}
f0103a05:	c9                   	leave  
f0103a06:	c3                   	ret    
	...

f0103a10 <idt_init>:
}


void
idt_init(void)
{
f0103a10:	55                   	push   %ebp
f0103a11:	89 e5                	mov    %esp,%ebp
f0103a13:	ba 00 00 00 00       	mov    $0x0,%edx
	extern struct Segdesc gdt[];
	
	// LAB 3: Your code here.
	int i;
	for(i=0;i<32;i++)
		SETGATE(idt[i],0,GD_KT,vectors[i],0);//陷阱门
f0103a18:	8b 04 95 64 e3 12 f0 	mov    -0xfed1c9c(,%edx,4),%eax
f0103a1f:	66 89 04 d5 e0 95 1b 	mov    %ax,-0xfe46a20(,%edx,8)
f0103a26:	f0 
f0103a27:	66 c7 04 d5 e2 95 1b 	movw   $0x8,-0xfe46a1e(,%edx,8)
f0103a2e:	f0 08 00 
f0103a31:	c6 04 d5 e4 95 1b f0 	movb   $0x0,-0xfe46a1c(,%edx,8)
f0103a38:	00 
f0103a39:	c6 04 d5 e5 95 1b f0 	movb   $0x8e,-0xfe46a1b(,%edx,8)
f0103a40:	8e 
f0103a41:	c1 e8 10             	shr    $0x10,%eax
f0103a44:	66 89 04 d5 e6 95 1b 	mov    %ax,-0xfe46a1a(,%edx,8)
f0103a4b:	f0 
{
	extern struct Segdesc gdt[];
	
	// LAB 3: Your code here.
	int i;
	for(i=0;i<32;i++)
f0103a4c:	83 c2 01             	add    $0x1,%edx
f0103a4f:	83 fa 20             	cmp    $0x20,%edx
f0103a52:	75 c4                	jne    f0103a18 <idt_init+0x8>
		SETGATE(idt[i],0,GD_KT,vectors[i],0);//陷阱门
	SETGATE(idt[3],0,GD_KT,vectors[3],3);//系统中断门
f0103a54:	a1 70 e3 12 f0       	mov    0xf012e370,%eax
f0103a59:	66 a3 f8 95 1b f0    	mov    %ax,0xf01b95f8
f0103a5f:	66 c7 05 fa 95 1b f0 	movw   $0x8,0xf01b95fa
f0103a66:	08 00 
f0103a68:	c6 05 fc 95 1b f0 00 	movb   $0x0,0xf01b95fc
f0103a6f:	c6 05 fd 95 1b f0 ee 	movb   $0xee,0xf01b95fd
f0103a76:	c1 e8 10             	shr    $0x10,%eax
f0103a79:	66 a3 fe 95 1b f0    	mov    %ax,0xf01b95fe
	SETGATE(idt[4],0,GD_KT,vectors[4],3);//系统门
f0103a7f:	a1 74 e3 12 f0       	mov    0xf012e374,%eax
f0103a84:	66 a3 00 96 1b f0    	mov    %ax,0xf01b9600
f0103a8a:	66 c7 05 02 96 1b f0 	movw   $0x8,0xf01b9602
f0103a91:	08 00 
f0103a93:	c6 05 04 96 1b f0 00 	movb   $0x0,0xf01b9604
f0103a9a:	c6 05 05 96 1b f0 ee 	movb   $0xee,0xf01b9605
f0103aa1:	c1 e8 10             	shr    $0x10,%eax
f0103aa4:	66 a3 06 96 1b f0    	mov    %ax,0xf01b9606
	SETGATE(idt[5],0,GD_KT,vectors[5],3);
f0103aaa:	a1 78 e3 12 f0       	mov    0xf012e378,%eax
f0103aaf:	66 a3 08 96 1b f0    	mov    %ax,0xf01b9608
f0103ab5:	66 c7 05 0a 96 1b f0 	movw   $0x8,0xf01b960a
f0103abc:	08 00 
f0103abe:	c6 05 0c 96 1b f0 00 	movb   $0x0,0xf01b960c
f0103ac5:	c6 05 0d 96 1b f0 ee 	movb   $0xee,0xf01b960d
f0103acc:	c1 e8 10             	shr    $0x10,%eax
f0103acf:	66 a3 0e 96 1b f0    	mov    %ax,0xf01b960e
	for(i=32;i<48;i++)
               SETGATE(idt[i],0,GD_KT,vectors[i],0);//中断门,外部硬件中断 16个
f0103ad5:	8b 04 95 64 e3 12 f0 	mov    -0xfed1c9c(,%edx,4),%eax
f0103adc:	66 89 04 d5 e0 95 1b 	mov    %ax,-0xfe46a20(,%edx,8)
f0103ae3:	f0 
f0103ae4:	66 c7 04 d5 e2 95 1b 	movw   $0x8,-0xfe46a1e(,%edx,8)
f0103aeb:	f0 08 00 
f0103aee:	c6 04 d5 e4 95 1b f0 	movb   $0x0,-0xfe46a1c(,%edx,8)
f0103af5:	00 
f0103af6:	c6 04 d5 e5 95 1b f0 	movb   $0x8e,-0xfe46a1b(,%edx,8)
f0103afd:	8e 
f0103afe:	c1 e8 10             	shr    $0x10,%eax
f0103b01:	66 89 04 d5 e6 95 1b 	mov    %ax,-0xfe46a1a(,%edx,8)
f0103b08:	f0 
	for(i=0;i<32;i++)
		SETGATE(idt[i],0,GD_KT,vectors[i],0);//陷阱门
	SETGATE(idt[3],0,GD_KT,vectors[3],3);//系统中断门
	SETGATE(idt[4],0,GD_KT,vectors[4],3);//系统门
	SETGATE(idt[5],0,GD_KT,vectors[5],3);
	for(i=32;i<48;i++)
f0103b09:	83 c2 01             	add    $0x1,%edx
f0103b0c:	83 fa 30             	cmp    $0x30,%edx
f0103b0f:	75 c4                	jne    f0103ad5 <idt_init+0xc5>
               SETGATE(idt[i],0,GD_KT,vectors[i],0);//中断门,外部硬件中断 16个
	 SETGATE(idt[48],0,GD_KT,vectors[48],3);//系统调用,系统门
f0103b11:	a1 24 e4 12 f0       	mov    0xf012e424,%eax
f0103b16:	66 a3 60 97 1b f0    	mov    %ax,0xf01b9760
f0103b1c:	66 c7 05 62 97 1b f0 	movw   $0x8,0xf01b9762
f0103b23:	08 00 
f0103b25:	c6 05 64 97 1b f0 00 	movb   $0x0,0xf01b9764
f0103b2c:	c6 05 65 97 1b f0 ee 	movb   $0xee,0xf01b9765
f0103b33:	c1 e8 10             	shr    $0x10,%eax
f0103b36:	66 a3 66 97 1b f0    	mov    %ax,0xf01b9766
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103b3c:	c7 05 e4 9d 1b f0 00 	movl   $0xefc00000,0xf01b9de4
f0103b43:	00 c0 ef 
	ts.ts_ss0 = GD_KD;
f0103b46:	66 c7 05 e8 9d 1b f0 	movw   $0x10,0xf01b9de8
f0103b4d:	10 00 

	// Initialize the TSS field of the gdt.
	gdt[GD_TSS >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103b4f:	ba e0 9d 1b f0       	mov    $0xf01b9de0,%edx
f0103b54:	89 d0                	mov    %edx,%eax
f0103b56:	c1 e8 18             	shr    $0x18,%eax
f0103b59:	a2 4f e3 12 f0       	mov    %al,0xf012e34f
f0103b5e:	c6 05 4e e3 12 f0 40 	movb   $0x40,0xf012e34e
f0103b65:	89 d0                	mov    %edx,%eax
f0103b67:	c1 e8 10             	shr    $0x10,%eax
f0103b6a:	a2 4c e3 12 f0       	mov    %al,0xf012e34c
f0103b6f:	66 89 15 4a e3 12 f0 	mov    %dx,0xf012e34a
f0103b76:	66 c7 05 48 e3 12 f0 	movw   $0x68,0xf012e348
f0103b7d:	68 00 
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS >> 3].sd_s = 0;
f0103b7f:	c6 05 4d e3 12 f0 89 	movb   $0x89,0xf012e34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103b86:	b8 28 00 00 00       	mov    $0x28,%eax
f0103b8b:	0f 00 d8             	ltr    %ax

	// Load the TSS
	ltr(GD_TSS);

	// Load the IDT
	asm volatile("lidt idt_pd");
f0103b8e:	0f 01 1d 5c e3 12 f0 	lidtl  0xf012e35c
}
f0103b95:	5d                   	pop    %ebp
f0103b96:	c3                   	ret    

f0103b97 <print_regs>:
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
}

void
print_regs(struct PushRegs *regs)
{
f0103b97:	55                   	push   %ebp
f0103b98:	89 e5                	mov    %esp,%ebp
f0103b9a:	53                   	push   %ebx
f0103b9b:	83 ec 14             	sub    $0x14,%esp
f0103b9e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103ba1:	8b 03                	mov    (%ebx),%eax
f0103ba3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ba7:	c7 04 24 76 b1 10 f0 	movl   $0xf010b176,(%esp)
f0103bae:	e8 24 fe ff ff       	call   f01039d7 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103bb3:	8b 43 04             	mov    0x4(%ebx),%eax
f0103bb6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bba:	c7 04 24 85 b1 10 f0 	movl   $0xf010b185,(%esp)
f0103bc1:	e8 11 fe ff ff       	call   f01039d7 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103bc6:	8b 43 08             	mov    0x8(%ebx),%eax
f0103bc9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bcd:	c7 04 24 94 b1 10 f0 	movl   $0xf010b194,(%esp)
f0103bd4:	e8 fe fd ff ff       	call   f01039d7 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103bd9:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103bdc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103be0:	c7 04 24 a3 b1 10 f0 	movl   $0xf010b1a3,(%esp)
f0103be7:	e8 eb fd ff ff       	call   f01039d7 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103bec:	8b 43 10             	mov    0x10(%ebx),%eax
f0103bef:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bf3:	c7 04 24 b2 b1 10 f0 	movl   $0xf010b1b2,(%esp)
f0103bfa:	e8 d8 fd ff ff       	call   f01039d7 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103bff:	8b 43 14             	mov    0x14(%ebx),%eax
f0103c02:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c06:	c7 04 24 c1 b1 10 f0 	movl   $0xf010b1c1,(%esp)
f0103c0d:	e8 c5 fd ff ff       	call   f01039d7 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103c12:	8b 43 18             	mov    0x18(%ebx),%eax
f0103c15:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c19:	c7 04 24 d0 b1 10 f0 	movl   $0xf010b1d0,(%esp)
f0103c20:	e8 b2 fd ff ff       	call   f01039d7 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103c25:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103c28:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c2c:	c7 04 24 df b1 10 f0 	movl   $0xf010b1df,(%esp)
f0103c33:	e8 9f fd ff ff       	call   f01039d7 <cprintf>
}
f0103c38:	83 c4 14             	add    $0x14,%esp
f0103c3b:	5b                   	pop    %ebx
f0103c3c:	5d                   	pop    %ebp
f0103c3d:	c3                   	ret    

f0103c3e <print_trapframe>:
	asm volatile("lidt idt_pd");
}

void
print_trapframe(struct Trapframe *tf)
{
f0103c3e:	55                   	push   %ebp
f0103c3f:	89 e5                	mov    %esp,%ebp
f0103c41:	53                   	push   %ebx
f0103c42:	83 ec 14             	sub    $0x14,%esp
f0103c45:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103c48:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103c4c:	c7 04 24 ee b1 10 f0 	movl   $0xf010b1ee,(%esp)
f0103c53:	e8 7f fd ff ff       	call   f01039d7 <cprintf>
	print_regs(&tf->tf_regs);
f0103c58:	89 1c 24             	mov    %ebx,(%esp)
f0103c5b:	e8 37 ff ff ff       	call   f0103b97 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103c60:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103c64:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c68:	c7 04 24 00 b2 10 f0 	movl   $0xf010b200,(%esp)
f0103c6f:	e8 63 fd ff ff       	call   f01039d7 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103c74:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103c78:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c7c:	c7 04 24 13 b2 10 f0 	movl   $0xf010b213,(%esp)
f0103c83:	e8 4f fd ff ff       	call   f01039d7 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103c88:	8b 53 28             	mov    0x28(%ebx),%edx
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103c8b:	83 fa 13             	cmp    $0x13,%edx
f0103c8e:	77 09                	ja     f0103c99 <print_trapframe+0x5b>
		return excnames[trapno];
f0103c90:	8b 0c 95 c0 b4 10 f0 	mov    -0xfef4b40(,%edx,4),%ecx
f0103c97:	eb 1c                	jmp    f0103cb5 <print_trapframe+0x77>
	if (trapno == T_SYSCALL)
f0103c99:	b9 26 b2 10 f0       	mov    $0xf010b226,%ecx
f0103c9e:	83 fa 30             	cmp    $0x30,%edx
f0103ca1:	74 12                	je     f0103cb5 <print_trapframe+0x77>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103ca3:	8d 42 e0             	lea    -0x20(%edx),%eax
f0103ca6:	b9 32 b2 10 f0       	mov    $0xf010b232,%ecx
f0103cab:	83 f8 0f             	cmp    $0xf,%eax
f0103cae:	76 05                	jbe    f0103cb5 <print_trapframe+0x77>
f0103cb0:	b9 45 b2 10 f0       	mov    $0xf010b245,%ecx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103cb5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103cb9:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103cbd:	c7 04 24 54 b2 10 f0 	movl   $0xf010b254,(%esp)
f0103cc4:	e8 0e fd ff ff       	call   f01039d7 <cprintf>
	cprintf("  err  0x%08x\n", tf->tf_err);
f0103cc9:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103ccc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cd0:	c7 04 24 66 b2 10 f0 	movl   $0xf010b266,(%esp)
f0103cd7:	e8 fb fc ff ff       	call   f01039d7 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103cdc:	8b 43 30             	mov    0x30(%ebx),%eax
f0103cdf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ce3:	c7 04 24 75 b2 10 f0 	movl   $0xf010b275,(%esp)
f0103cea:	e8 e8 fc ff ff       	call   f01039d7 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103cef:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103cf3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cf7:	c7 04 24 84 b2 10 f0 	movl   $0xf010b284,(%esp)
f0103cfe:	e8 d4 fc ff ff       	call   f01039d7 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103d03:	8b 43 38             	mov    0x38(%ebx),%eax
f0103d06:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d0a:	c7 04 24 97 b2 10 f0 	movl   $0xf010b297,(%esp)
f0103d11:	e8 c1 fc ff ff       	call   f01039d7 <cprintf>
	cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103d16:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103d19:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d1d:	c7 04 24 a6 b2 10 f0 	movl   $0xf010b2a6,(%esp)
f0103d24:	e8 ae fc ff ff       	call   f01039d7 <cprintf>
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103d29:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103d2d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d31:	c7 04 24 b5 b2 10 f0 	movl   $0xf010b2b5,(%esp)
f0103d38:	e8 9a fc ff ff       	call   f01039d7 <cprintf>
}
f0103d3d:	83 c4 14             	add    $0x14,%esp
f0103d40:	5b                   	pop    %ebx
f0103d41:	5d                   	pop    %ebp
f0103d42:	c3                   	ret    

f0103d43 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103d43:	55                   	push   %ebp
f0103d44:	89 e5                	mov    %esp,%ebp
f0103d46:	56                   	push   %esi
f0103d47:	53                   	push   %ebx
f0103d48:	83 ec 10             	sub    $0x10,%esp
f0103d4b:	8b 5d 08             	mov    0x8(%ebp),%ebx

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103d4e:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	
	// LAB 3: Your code here.还可以通过页故障异常的错误码的位2判断
	if((tf->tf_cs&3)==0)
f0103d51:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103d55:	75 1c                	jne    f0103d73 <page_fault_handler+0x30>
		panic("Page Fault in Kernel Mode");
f0103d57:	c7 44 24 08 c8 b2 10 	movl   $0xf010b2c8,0x8(%esp)
f0103d5e:	f0 
f0103d5f:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
f0103d66:	00 
f0103d67:	c7 04 24 e2 b2 10 f0 	movl   $0xf010b2e2,(%esp)
f0103d6e:	e8 13 c3 ff ff       	call   f0100086 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	struct UTrapframe *utf;
	if((tf->tf_err&FEC_U)&&curenv->env_pgfault_upcall)
f0103d73:	f6 43 2c 04          	testb  $0x4,0x2c(%ebx)
f0103d77:	0f 84 d9 00 00 00    	je     f0103e56 <page_fault_handler+0x113>
f0103d7d:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f0103d82:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103d86:	0f 84 ca 00 00 00    	je     f0103e56 <page_fault_handler+0x113>
	{
		user_mem_assert(curenv,(void*)(UXSTACKTOP-0x34),0x34,0);
f0103d8c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103d93:	00 
f0103d94:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f0103d9b:	00 
f0103d9c:	c7 44 24 04 cc ff bf 	movl   $0xeebfffcc,0x4(%esp)
f0103da3:	ee 
f0103da4:	89 04 24             	mov    %eax,(%esp)
f0103da7:	e8 c3 d7 ff ff       	call   f010156f <user_mem_assert>
		if(tf->tf_esp>(UXSTACKTOP-PGSIZE)&&tf->tf_esp<UXSTACKTOP)
f0103dac:	8b 4b 3c             	mov    0x3c(%ebx),%ecx
f0103daf:	8d 81 ff 0f 40 11    	lea    0x11400fff(%ecx),%eax
f0103db5:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f0103dba:	3d fe 0f 00 00       	cmp    $0xffe,%eax
f0103dbf:	77 03                	ja     f0103dc4 <page_fault_handler+0x81>
		{
			utf=(struct UTrapframe*)(tf->tf_esp-0x38);
f0103dc1:	8d 51 c8             	lea    -0x38(%ecx),%edx
		}
		else{
			utf = (struct UTrapframe*)(UXSTACKTOP-0x34);   
		}
					//在用户异常栈上设置一个页故障帧栈
		utf->utf_fault_va=fault_va;
f0103dc4:	89 32                	mov    %esi,(%edx)
		utf->utf_err=tf->tf_err;
f0103dc6:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103dc9:	89 42 04             	mov    %eax,0x4(%edx)
		utf->utf_regs=tf->tf_regs;
f0103dcc:	8b 03                	mov    (%ebx),%eax
f0103dce:	89 42 08             	mov    %eax,0x8(%edx)
f0103dd1:	8b 43 04             	mov    0x4(%ebx),%eax
f0103dd4:	89 42 0c             	mov    %eax,0xc(%edx)
f0103dd7:	8b 43 08             	mov    0x8(%ebx),%eax
f0103dda:	89 42 10             	mov    %eax,0x10(%edx)
f0103ddd:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103de0:	89 42 14             	mov    %eax,0x14(%edx)
f0103de3:	8b 43 10             	mov    0x10(%ebx),%eax
f0103de6:	89 42 18             	mov    %eax,0x18(%edx)
f0103de9:	8b 43 14             	mov    0x14(%ebx),%eax
f0103dec:	89 42 1c             	mov    %eax,0x1c(%edx)
f0103def:	8b 43 18             	mov    0x18(%ebx),%eax
f0103df2:	89 42 20             	mov    %eax,0x20(%edx)
f0103df5:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103df8:	89 42 24             	mov    %eax,0x24(%edx)
		utf->utf_eip=tf->tf_eip;
f0103dfb:	8b 43 30             	mov    0x30(%ebx),%eax
f0103dfe:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags=tf->tf_eflags;
f0103e01:	8b 43 38             	mov    0x38(%ebx),%eax
f0103e04:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp=tf->tf_esp;
f0103e07:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103e0a:	89 42 30             	mov    %eax,0x30(%edx)
		curenv->env_tf.tf_esp=(uintptr_t)utf;
f0103e0d:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f0103e12:	89 50 3c             	mov    %edx,0x3c(%eax)
		//curenv->env_tf.tf_eflags=utf->utf_eflags;
		//cprintf("utf:utf_esp=%x utf_eip=%x\n",utf->utf_esp,utf->utf_eip);
		//cprintf("curenv:tf_esp=%x utf=%x\n",curenv->env_tf.tf_esp,(uintptr_t)utf);
		//cprintf("tf->tf_eflags=%x curenv_eflages=%x\n",tf->tf_eflags,curenv->env_tf.tf_eflags);
		if(curenv->env_pgfault_upcall)
f0103e15:	8b 15 c4 95 1b f0    	mov    0xf01b95c4,%edx
f0103e1b:	8b 42 64             	mov    0x64(%edx),%eax
f0103e1e:	85 c0                	test   %eax,%eax
f0103e20:	74 34                	je     f0103e56 <page_fault_handler+0x113>
		{	
			user_mem_assert(curenv,(void*)curenv->env_pgfault_upcall,PGSIZE,0);
f0103e22:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103e29:	00 
f0103e2a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103e31:	00 
f0103e32:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e36:	89 14 24             	mov    %edx,(%esp)
f0103e39:	e8 31 d7 ff ff       	call   f010156f <user_mem_assert>
			curenv->env_tf.tf_eip=(uintptr_t)curenv->env_pgfault_upcall;
f0103e3e:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f0103e43:	8b 50 64             	mov    0x64(%eax),%edx
f0103e46:	89 50 30             	mov    %edx,0x30(%eax)
			env_run(curenv);
f0103e49:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f0103e4e:	89 04 24             	mov    %eax,(%esp)
f0103e51:	e8 fb f3 ff ff       	call   f0103251 <env_run>
		}
	}
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103e56:	8b 43 30             	mov    0x30(%ebx),%eax
f0103e59:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e5d:	89 74 24 08          	mov    %esi,0x8(%esp)
f0103e61:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f0103e66:	8b 40 4c             	mov    0x4c(%eax),%eax
f0103e69:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e6d:	c7 04 24 88 b4 10 f0 	movl   $0xf010b488,(%esp)
f0103e74:	e8 5e fb ff ff       	call   f01039d7 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103e79:	89 1c 24             	mov    %ebx,(%esp)
f0103e7c:	e8 bd fd ff ff       	call   f0103c3e <print_trapframe>
	env_destroy(curenv);
f0103e81:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f0103e86:	89 04 24             	mov    %eax,(%esp)
f0103e89:	e8 68 f9 ff ff       	call   f01037f6 <env_destroy>
}
f0103e8e:	83 c4 10             	add    $0x10,%esp
f0103e91:	5b                   	pop    %ebx
f0103e92:	5e                   	pop    %esi
f0103e93:	5d                   	pop    %ebp
f0103e94:	c3                   	ret    

f0103e95 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103e95:	55                   	push   %ebp
f0103e96:	89 e5                	mov    %esp,%ebp
f0103e98:	56                   	push   %esi
f0103e99:	53                   	push   %ebx
f0103e9a:	83 ec 20             	sub    $0x20,%esp
f0103e9d:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103ea0:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103ea1:	9c                   	pushf  
f0103ea2:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103ea3:	f6 c4 02             	test   $0x2,%ah
f0103ea6:	74 24                	je     f0103ecc <trap+0x37>
f0103ea8:	c7 44 24 0c ee b2 10 	movl   $0xf010b2ee,0xc(%esp)
f0103eaf:	f0 
f0103eb0:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0103eb7:	f0 
f0103eb8:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
f0103ebf:	00 
f0103ec0:	c7 04 24 e2 b2 10 f0 	movl   $0xf010b2e2,(%esp)
f0103ec7:	e8 ba c1 ff ff       	call   f0100086 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0103ecc:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103ed0:	83 e0 03             	and    $0x3,%eax
f0103ed3:	83 f8 03             	cmp    $0x3,%eax
f0103ed6:	75 47                	jne    f0103f1f <trap+0x8a>
		// Trapped from user mode.
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		assert(curenv);
f0103ed8:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f0103edd:	85 c0                	test   %eax,%eax
f0103edf:	75 24                	jne    f0103f05 <trap+0x70>
f0103ee1:	c7 44 24 0c 07 b3 10 	movl   $0xf010b307,0xc(%esp)
f0103ee8:	f0 
f0103ee9:	c7 44 24 08 4c ae 10 	movl   $0xf010ae4c,0x8(%esp)
f0103ef0:	f0 
f0103ef1:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
f0103ef8:	00 
f0103ef9:	c7 04 24 e2 b2 10 f0 	movl   $0xf010b2e2,(%esp)
f0103f00:	e8 81 c1 ff ff       	call   f0100086 <_panic>
		curenv->env_tf = *tf;
f0103f05:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103f0c:	00 
f0103f0d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103f11:	89 04 24             	mov    %eax,(%esp)
f0103f14:	e8 ef 57 00 00       	call   f0109708 <memcpy>
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103f19:	8b 35 c4 95 1b f0    	mov    0xf01b95c4,%esi
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	switch(tf->tf_trapno){
f0103f1f:	8b 46 28             	mov    0x28(%esi),%eax
f0103f22:	83 f8 03             	cmp    $0x3,%eax
f0103f25:	74 33                	je     f0103f5a <trap+0xc5>
f0103f27:	83 f8 03             	cmp    $0x3,%eax
f0103f2a:	77 0b                	ja     f0103f37 <trap+0xa2>
f0103f2c:	83 f8 01             	cmp    $0x1,%eax
f0103f2f:	0f 85 78 00 00 00    	jne    f0103fad <trap+0x118>
f0103f35:	eb 30                	jmp    f0103f67 <trap+0xd2>
f0103f37:	83 f8 0e             	cmp    $0xe,%eax
f0103f3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103f40:	74 07                	je     f0103f49 <trap+0xb4>
f0103f42:	83 f8 30             	cmp    $0x30,%eax
f0103f45:	75 66                	jne    f0103fad <trap+0x118>
f0103f47:	eb 2c                	jmp    f0103f75 <trap+0xe0>
		case T_PGFLT:
			page_fault_handler(tf);
f0103f49:	89 34 24             	mov    %esi,(%esp)
f0103f4c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0103f50:	e8 ee fd ff ff       	call   f0103d43 <page_fault_handler>
f0103f55:	e9 b1 00 00 00       	jmp    f010400b <trap+0x176>
			break;
		case T_BRKPT:
			monitor(tf);
f0103f5a:	89 34 24             	mov    %esi,(%esp)
f0103f5d:	e8 15 ca ff ff       	call   f0100977 <monitor>
f0103f62:	e9 a4 00 00 00       	jmp    f010400b <trap+0x176>
			break;
		case T_DEBUG:
			monitor(tf);
f0103f67:	89 34 24             	mov    %esi,(%esp)
f0103f6a:	e8 08 ca ff ff       	call   f0100977 <monitor>
f0103f6f:	90                   	nop    
f0103f70:	e9 96 00 00 00       	jmp    f010400b <trap+0x176>
			break;
		case T_SYSCALL:
			curenv->env_tf.tf_regs.reg_eax=syscall(tf->tf_regs.reg_eax,tf->tf_regs.reg_edx,tf->tf_regs.reg_ecx,tf->tf_regs.reg_ebx,tf->tf_regs.reg_edi,tf->tf_regs.reg_esi);
f0103f75:	8b 1d c4 95 1b f0    	mov    0xf01b95c4,%ebx
f0103f7b:	8b 46 04             	mov    0x4(%esi),%eax
f0103f7e:	89 44 24 14          	mov    %eax,0x14(%esp)
f0103f82:	8b 06                	mov    (%esi),%eax
f0103f84:	89 44 24 10          	mov    %eax,0x10(%esp)
f0103f88:	8b 46 10             	mov    0x10(%esi),%eax
f0103f8b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f8f:	8b 46 18             	mov    0x18(%esi),%eax
f0103f92:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f96:	8b 46 14             	mov    0x14(%esi),%eax
f0103f99:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f9d:	8b 46 1c             	mov    0x1c(%esi),%eax
f0103fa0:	89 04 24             	mov    %eax,(%esp)
f0103fa3:	e8 49 0d 00 00       	call   f0104cf1 <syscall>
f0103fa8:	89 43 1c             	mov    %eax,0x1c(%ebx)
f0103fab:	eb 5e                	jmp    f010400b <trap+0x176>
			break;
		default:	
		// Handle clock interrupts.
		// LAB 4: Your code here.
		if(tf->tf_trapno==IRQ_OFFSET + IRQ_TIMER){
f0103fad:	83 f8 20             	cmp    $0x20,%eax
f0103fb0:	75 05                	jne    f0103fb7 <trap+0x122>
			sched_yield();//内核层的环境切换，需要在环境切换中思考
f0103fb2:	e8 85 0b 00 00       	call   f0104b3c <sched_yield>
		}
		// Handle spurious interrupts
		// The hardware sometimes raises these because of noise on the
		// IRQ line or other reasons. We don't care.
		if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0103fb7:	83 f8 27             	cmp    $0x27,%eax
f0103fba:	75 16                	jne    f0103fd2 <trap+0x13d>
			cprintf("Spurious interrupt on irq 7\n");
f0103fbc:	c7 04 24 0e b3 10 f0 	movl   $0xf010b30e,(%esp)
f0103fc3:	e8 0f fa ff ff       	call   f01039d7 <cprintf>
			print_trapframe(tf);
f0103fc8:	89 34 24             	mov    %esi,(%esp)
f0103fcb:	e8 6e fc ff ff       	call   f0103c3e <print_trapframe>
f0103fd0:	eb 39                	jmp    f010400b <trap+0x176>
		}
	


		// Unexpected trap: The user process or the kernel has a bug.
		print_trapframe(tf);
f0103fd2:	89 34 24             	mov    %esi,(%esp)
f0103fd5:	e8 64 fc ff ff       	call   f0103c3e <print_trapframe>
		if (tf->tf_cs == GD_KT)
f0103fda:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103fdf:	90                   	nop    
f0103fe0:	75 1c                	jne    f0103ffe <trap+0x169>
			panic("unhandled trap in kernel");
f0103fe2:	c7 44 24 08 2b b3 10 	movl   $0xf010b32b,0x8(%esp)
f0103fe9:	f0 
f0103fea:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
f0103ff1:	00 
f0103ff2:	c7 04 24 e2 b2 10 f0 	movl   $0xf010b2e2,(%esp)
f0103ff9:	e8 88 c0 ff ff       	call   f0100086 <_panic>
		else {
			env_destroy(curenv);
f0103ffe:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f0104003:	89 04 24             	mov    %eax,(%esp)
f0104006:	e8 eb f7 ff ff       	call   f01037f6 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNABLE)
f010400b:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f0104010:	85 c0                	test   %eax,%eax
f0104012:	74 0e                	je     f0104022 <trap+0x18d>
f0104014:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104018:	75 08                	jne    f0104022 <trap+0x18d>
		env_run(curenv);
f010401a:	89 04 24             	mov    %eax,(%esp)
f010401d:	e8 2f f2 ff ff       	call   f0103251 <env_run>
	else
		sched_yield();
f0104022:	e8 15 0b 00 00       	call   f0104b3c <sched_yield>
	...

f0104028 <vector0>:
f0104028:	6a 00                	push   $0x0
f010402a:	6a 00                	push   $0x0
f010402c:	e9 eb 0a 00 00       	jmp    f0104b1c <_alltraps>
f0104031:	90                   	nop    

f0104032 <vector1>:
f0104032:	6a 00                	push   $0x0
f0104034:	6a 01                	push   $0x1
f0104036:	e9 e1 0a 00 00       	jmp    f0104b1c <_alltraps>
f010403b:	90                   	nop    

f010403c <vector2>:
f010403c:	6a 00                	push   $0x0
f010403e:	6a 02                	push   $0x2
f0104040:	e9 d7 0a 00 00       	jmp    f0104b1c <_alltraps>
f0104045:	90                   	nop    

f0104046 <vector3>:
f0104046:	6a 00                	push   $0x0
f0104048:	6a 03                	push   $0x3
f010404a:	e9 cd 0a 00 00       	jmp    f0104b1c <_alltraps>
f010404f:	90                   	nop    

f0104050 <vector4>:
f0104050:	6a 00                	push   $0x0
f0104052:	6a 04                	push   $0x4
f0104054:	e9 c3 0a 00 00       	jmp    f0104b1c <_alltraps>
f0104059:	90                   	nop    

f010405a <vector5>:
f010405a:	6a 00                	push   $0x0
f010405c:	6a 05                	push   $0x5
f010405e:	e9 b9 0a 00 00       	jmp    f0104b1c <_alltraps>
f0104063:	90                   	nop    

f0104064 <vector6>:
f0104064:	6a 00                	push   $0x0
f0104066:	6a 06                	push   $0x6
f0104068:	e9 af 0a 00 00       	jmp    f0104b1c <_alltraps>
f010406d:	90                   	nop    

f010406e <vector7>:
f010406e:	6a 00                	push   $0x0
f0104070:	6a 07                	push   $0x7
f0104072:	e9 a5 0a 00 00       	jmp    f0104b1c <_alltraps>
f0104077:	90                   	nop    

f0104078 <vector8>:
f0104078:	6a 08                	push   $0x8
f010407a:	e9 9d 0a 00 00       	jmp    f0104b1c <_alltraps>
f010407f:	90                   	nop    

f0104080 <vector9>:
f0104080:	6a 00                	push   $0x0
f0104082:	6a 09                	push   $0x9
f0104084:	e9 93 0a 00 00       	jmp    f0104b1c <_alltraps>
f0104089:	90                   	nop    

f010408a <vector10>:
f010408a:	6a 0a                	push   $0xa
f010408c:	e9 8b 0a 00 00       	jmp    f0104b1c <_alltraps>
f0104091:	90                   	nop    

f0104092 <vector11>:
f0104092:	6a 0b                	push   $0xb
f0104094:	e9 83 0a 00 00       	jmp    f0104b1c <_alltraps>
f0104099:	90                   	nop    

f010409a <vector12>:
f010409a:	6a 0c                	push   $0xc
f010409c:	e9 7b 0a 00 00       	jmp    f0104b1c <_alltraps>
f01040a1:	90                   	nop    

f01040a2 <vector13>:
f01040a2:	6a 0d                	push   $0xd
f01040a4:	e9 73 0a 00 00       	jmp    f0104b1c <_alltraps>
f01040a9:	90                   	nop    

f01040aa <vector14>:
f01040aa:	6a 0e                	push   $0xe
f01040ac:	e9 6b 0a 00 00       	jmp    f0104b1c <_alltraps>
f01040b1:	90                   	nop    

f01040b2 <vector15>:
f01040b2:	6a 00                	push   $0x0
f01040b4:	6a 0f                	push   $0xf
f01040b6:	e9 61 0a 00 00       	jmp    f0104b1c <_alltraps>
f01040bb:	90                   	nop    

f01040bc <vector16>:
f01040bc:	6a 00                	push   $0x0
f01040be:	6a 10                	push   $0x10
f01040c0:	e9 57 0a 00 00       	jmp    f0104b1c <_alltraps>
f01040c5:	90                   	nop    

f01040c6 <vector17>:
f01040c6:	6a 00                	push   $0x0
f01040c8:	6a 11                	push   $0x11
f01040ca:	e9 4d 0a 00 00       	jmp    f0104b1c <_alltraps>
f01040cf:	90                   	nop    

f01040d0 <vector18>:
f01040d0:	6a 00                	push   $0x0
f01040d2:	6a 12                	push   $0x12
f01040d4:	e9 43 0a 00 00       	jmp    f0104b1c <_alltraps>
f01040d9:	90                   	nop    

f01040da <vector19>:
f01040da:	6a 00                	push   $0x0
f01040dc:	6a 13                	push   $0x13
f01040de:	e9 39 0a 00 00       	jmp    f0104b1c <_alltraps>
f01040e3:	90                   	nop    

f01040e4 <vector20>:
f01040e4:	6a 00                	push   $0x0
f01040e6:	6a 14                	push   $0x14
f01040e8:	e9 2f 0a 00 00       	jmp    f0104b1c <_alltraps>
f01040ed:	90                   	nop    

f01040ee <vector21>:
f01040ee:	6a 00                	push   $0x0
f01040f0:	6a 15                	push   $0x15
f01040f2:	e9 25 0a 00 00       	jmp    f0104b1c <_alltraps>
f01040f7:	90                   	nop    

f01040f8 <vector22>:
f01040f8:	6a 00                	push   $0x0
f01040fa:	6a 16                	push   $0x16
f01040fc:	e9 1b 0a 00 00       	jmp    f0104b1c <_alltraps>
f0104101:	90                   	nop    

f0104102 <vector23>:
f0104102:	6a 00                	push   $0x0
f0104104:	6a 17                	push   $0x17
f0104106:	e9 11 0a 00 00       	jmp    f0104b1c <_alltraps>
f010410b:	90                   	nop    

f010410c <vector24>:
f010410c:	6a 00                	push   $0x0
f010410e:	6a 18                	push   $0x18
f0104110:	e9 07 0a 00 00       	jmp    f0104b1c <_alltraps>
f0104115:	90                   	nop    

f0104116 <vector25>:
f0104116:	6a 00                	push   $0x0
f0104118:	6a 19                	push   $0x19
f010411a:	e9 fd 09 00 00       	jmp    f0104b1c <_alltraps>
f010411f:	90                   	nop    

f0104120 <vector26>:
f0104120:	6a 00                	push   $0x0
f0104122:	6a 1a                	push   $0x1a
f0104124:	e9 f3 09 00 00       	jmp    f0104b1c <_alltraps>
f0104129:	90                   	nop    

f010412a <vector27>:
f010412a:	6a 00                	push   $0x0
f010412c:	6a 1b                	push   $0x1b
f010412e:	e9 e9 09 00 00       	jmp    f0104b1c <_alltraps>
f0104133:	90                   	nop    

f0104134 <vector28>:
f0104134:	6a 00                	push   $0x0
f0104136:	6a 1c                	push   $0x1c
f0104138:	e9 df 09 00 00       	jmp    f0104b1c <_alltraps>
f010413d:	90                   	nop    

f010413e <vector29>:
f010413e:	6a 00                	push   $0x0
f0104140:	6a 1d                	push   $0x1d
f0104142:	e9 d5 09 00 00       	jmp    f0104b1c <_alltraps>
f0104147:	90                   	nop    

f0104148 <vector30>:
f0104148:	6a 00                	push   $0x0
f010414a:	6a 1e                	push   $0x1e
f010414c:	e9 cb 09 00 00       	jmp    f0104b1c <_alltraps>
f0104151:	90                   	nop    

f0104152 <vector31>:
f0104152:	6a 00                	push   $0x0
f0104154:	6a 1f                	push   $0x1f
f0104156:	e9 c1 09 00 00       	jmp    f0104b1c <_alltraps>
f010415b:	90                   	nop    

f010415c <vector32>:
f010415c:	6a 00                	push   $0x0
f010415e:	6a 20                	push   $0x20
f0104160:	e9 b7 09 00 00       	jmp    f0104b1c <_alltraps>
f0104165:	90                   	nop    

f0104166 <vector33>:
f0104166:	6a 00                	push   $0x0
f0104168:	6a 21                	push   $0x21
f010416a:	e9 ad 09 00 00       	jmp    f0104b1c <_alltraps>
f010416f:	90                   	nop    

f0104170 <vector34>:
f0104170:	6a 00                	push   $0x0
f0104172:	6a 22                	push   $0x22
f0104174:	e9 a3 09 00 00       	jmp    f0104b1c <_alltraps>
f0104179:	90                   	nop    

f010417a <vector35>:
f010417a:	6a 00                	push   $0x0
f010417c:	6a 23                	push   $0x23
f010417e:	e9 99 09 00 00       	jmp    f0104b1c <_alltraps>
f0104183:	90                   	nop    

f0104184 <vector36>:
f0104184:	6a 00                	push   $0x0
f0104186:	6a 24                	push   $0x24
f0104188:	e9 8f 09 00 00       	jmp    f0104b1c <_alltraps>
f010418d:	90                   	nop    

f010418e <vector37>:
f010418e:	6a 00                	push   $0x0
f0104190:	6a 25                	push   $0x25
f0104192:	e9 85 09 00 00       	jmp    f0104b1c <_alltraps>
f0104197:	90                   	nop    

f0104198 <vector38>:
f0104198:	6a 00                	push   $0x0
f010419a:	6a 26                	push   $0x26
f010419c:	e9 7b 09 00 00       	jmp    f0104b1c <_alltraps>
f01041a1:	90                   	nop    

f01041a2 <vector39>:
f01041a2:	6a 00                	push   $0x0
f01041a4:	6a 27                	push   $0x27
f01041a6:	e9 71 09 00 00       	jmp    f0104b1c <_alltraps>
f01041ab:	90                   	nop    

f01041ac <vector40>:
f01041ac:	6a 00                	push   $0x0
f01041ae:	6a 28                	push   $0x28
f01041b0:	e9 67 09 00 00       	jmp    f0104b1c <_alltraps>
f01041b5:	90                   	nop    

f01041b6 <vector41>:
f01041b6:	6a 00                	push   $0x0
f01041b8:	6a 29                	push   $0x29
f01041ba:	e9 5d 09 00 00       	jmp    f0104b1c <_alltraps>
f01041bf:	90                   	nop    

f01041c0 <vector42>:
f01041c0:	6a 00                	push   $0x0
f01041c2:	6a 2a                	push   $0x2a
f01041c4:	e9 53 09 00 00       	jmp    f0104b1c <_alltraps>
f01041c9:	90                   	nop    

f01041ca <vector43>:
f01041ca:	6a 00                	push   $0x0
f01041cc:	6a 2b                	push   $0x2b
f01041ce:	e9 49 09 00 00       	jmp    f0104b1c <_alltraps>
f01041d3:	90                   	nop    

f01041d4 <vector44>:
f01041d4:	6a 00                	push   $0x0
f01041d6:	6a 2c                	push   $0x2c
f01041d8:	e9 3f 09 00 00       	jmp    f0104b1c <_alltraps>
f01041dd:	90                   	nop    

f01041de <vector45>:
f01041de:	6a 00                	push   $0x0
f01041e0:	6a 2d                	push   $0x2d
f01041e2:	e9 35 09 00 00       	jmp    f0104b1c <_alltraps>
f01041e7:	90                   	nop    

f01041e8 <vector46>:
f01041e8:	6a 00                	push   $0x0
f01041ea:	6a 2e                	push   $0x2e
f01041ec:	e9 2b 09 00 00       	jmp    f0104b1c <_alltraps>
f01041f1:	90                   	nop    

f01041f2 <vector47>:
f01041f2:	6a 00                	push   $0x0
f01041f4:	6a 2f                	push   $0x2f
f01041f6:	e9 21 09 00 00       	jmp    f0104b1c <_alltraps>
f01041fb:	90                   	nop    

f01041fc <vector48>:
f01041fc:	6a 00                	push   $0x0
f01041fe:	6a 30                	push   $0x30
f0104200:	e9 17 09 00 00       	jmp    f0104b1c <_alltraps>
f0104205:	90                   	nop    

f0104206 <vector49>:
f0104206:	6a 00                	push   $0x0
f0104208:	6a 31                	push   $0x31
f010420a:	e9 0d 09 00 00       	jmp    f0104b1c <_alltraps>
f010420f:	90                   	nop    

f0104210 <vector50>:
f0104210:	6a 00                	push   $0x0
f0104212:	6a 32                	push   $0x32
f0104214:	e9 03 09 00 00       	jmp    f0104b1c <_alltraps>
f0104219:	90                   	nop    

f010421a <vector51>:
f010421a:	6a 00                	push   $0x0
f010421c:	6a 33                	push   $0x33
f010421e:	e9 f9 08 00 00       	jmp    f0104b1c <_alltraps>
f0104223:	90                   	nop    

f0104224 <vector52>:
f0104224:	6a 00                	push   $0x0
f0104226:	6a 34                	push   $0x34
f0104228:	e9 ef 08 00 00       	jmp    f0104b1c <_alltraps>
f010422d:	90                   	nop    

f010422e <vector53>:
f010422e:	6a 00                	push   $0x0
f0104230:	6a 35                	push   $0x35
f0104232:	e9 e5 08 00 00       	jmp    f0104b1c <_alltraps>
f0104237:	90                   	nop    

f0104238 <vector54>:
f0104238:	6a 00                	push   $0x0
f010423a:	6a 36                	push   $0x36
f010423c:	e9 db 08 00 00       	jmp    f0104b1c <_alltraps>
f0104241:	90                   	nop    

f0104242 <vector55>:
f0104242:	6a 00                	push   $0x0
f0104244:	6a 37                	push   $0x37
f0104246:	e9 d1 08 00 00       	jmp    f0104b1c <_alltraps>
f010424b:	90                   	nop    

f010424c <vector56>:
f010424c:	6a 00                	push   $0x0
f010424e:	6a 38                	push   $0x38
f0104250:	e9 c7 08 00 00       	jmp    f0104b1c <_alltraps>
f0104255:	90                   	nop    

f0104256 <vector57>:
f0104256:	6a 00                	push   $0x0
f0104258:	6a 39                	push   $0x39
f010425a:	e9 bd 08 00 00       	jmp    f0104b1c <_alltraps>
f010425f:	90                   	nop    

f0104260 <vector58>:
f0104260:	6a 00                	push   $0x0
f0104262:	6a 3a                	push   $0x3a
f0104264:	e9 b3 08 00 00       	jmp    f0104b1c <_alltraps>
f0104269:	90                   	nop    

f010426a <vector59>:
f010426a:	6a 00                	push   $0x0
f010426c:	6a 3b                	push   $0x3b
f010426e:	e9 a9 08 00 00       	jmp    f0104b1c <_alltraps>
f0104273:	90                   	nop    

f0104274 <vector60>:
f0104274:	6a 00                	push   $0x0
f0104276:	6a 3c                	push   $0x3c
f0104278:	e9 9f 08 00 00       	jmp    f0104b1c <_alltraps>
f010427d:	90                   	nop    

f010427e <vector61>:
f010427e:	6a 00                	push   $0x0
f0104280:	6a 3d                	push   $0x3d
f0104282:	e9 95 08 00 00       	jmp    f0104b1c <_alltraps>
f0104287:	90                   	nop    

f0104288 <vector62>:
f0104288:	6a 00                	push   $0x0
f010428a:	6a 3e                	push   $0x3e
f010428c:	e9 8b 08 00 00       	jmp    f0104b1c <_alltraps>
f0104291:	90                   	nop    

f0104292 <vector63>:
f0104292:	6a 00                	push   $0x0
f0104294:	6a 3f                	push   $0x3f
f0104296:	e9 81 08 00 00       	jmp    f0104b1c <_alltraps>
f010429b:	90                   	nop    

f010429c <vector64>:
f010429c:	6a 00                	push   $0x0
f010429e:	6a 40                	push   $0x40
f01042a0:	e9 77 08 00 00       	jmp    f0104b1c <_alltraps>
f01042a5:	90                   	nop    

f01042a6 <vector65>:
f01042a6:	6a 00                	push   $0x0
f01042a8:	6a 41                	push   $0x41
f01042aa:	e9 6d 08 00 00       	jmp    f0104b1c <_alltraps>
f01042af:	90                   	nop    

f01042b0 <vector66>:
f01042b0:	6a 00                	push   $0x0
f01042b2:	6a 42                	push   $0x42
f01042b4:	e9 63 08 00 00       	jmp    f0104b1c <_alltraps>
f01042b9:	90                   	nop    

f01042ba <vector67>:
f01042ba:	6a 00                	push   $0x0
f01042bc:	6a 43                	push   $0x43
f01042be:	e9 59 08 00 00       	jmp    f0104b1c <_alltraps>
f01042c3:	90                   	nop    

f01042c4 <vector68>:
f01042c4:	6a 00                	push   $0x0
f01042c6:	6a 44                	push   $0x44
f01042c8:	e9 4f 08 00 00       	jmp    f0104b1c <_alltraps>
f01042cd:	90                   	nop    

f01042ce <vector69>:
f01042ce:	6a 00                	push   $0x0
f01042d0:	6a 45                	push   $0x45
f01042d2:	e9 45 08 00 00       	jmp    f0104b1c <_alltraps>
f01042d7:	90                   	nop    

f01042d8 <vector70>:
f01042d8:	6a 00                	push   $0x0
f01042da:	6a 46                	push   $0x46
f01042dc:	e9 3b 08 00 00       	jmp    f0104b1c <_alltraps>
f01042e1:	90                   	nop    

f01042e2 <vector71>:
f01042e2:	6a 00                	push   $0x0
f01042e4:	6a 47                	push   $0x47
f01042e6:	e9 31 08 00 00       	jmp    f0104b1c <_alltraps>
f01042eb:	90                   	nop    

f01042ec <vector72>:
f01042ec:	6a 00                	push   $0x0
f01042ee:	6a 48                	push   $0x48
f01042f0:	e9 27 08 00 00       	jmp    f0104b1c <_alltraps>
f01042f5:	90                   	nop    

f01042f6 <vector73>:
f01042f6:	6a 00                	push   $0x0
f01042f8:	6a 49                	push   $0x49
f01042fa:	e9 1d 08 00 00       	jmp    f0104b1c <_alltraps>
f01042ff:	90                   	nop    

f0104300 <vector74>:
f0104300:	6a 00                	push   $0x0
f0104302:	6a 4a                	push   $0x4a
f0104304:	e9 13 08 00 00       	jmp    f0104b1c <_alltraps>
f0104309:	90                   	nop    

f010430a <vector75>:
f010430a:	6a 00                	push   $0x0
f010430c:	6a 4b                	push   $0x4b
f010430e:	e9 09 08 00 00       	jmp    f0104b1c <_alltraps>
f0104313:	90                   	nop    

f0104314 <vector76>:
f0104314:	6a 00                	push   $0x0
f0104316:	6a 4c                	push   $0x4c
f0104318:	e9 ff 07 00 00       	jmp    f0104b1c <_alltraps>
f010431d:	90                   	nop    

f010431e <vector77>:
f010431e:	6a 00                	push   $0x0
f0104320:	6a 4d                	push   $0x4d
f0104322:	e9 f5 07 00 00       	jmp    f0104b1c <_alltraps>
f0104327:	90                   	nop    

f0104328 <vector78>:
f0104328:	6a 00                	push   $0x0
f010432a:	6a 4e                	push   $0x4e
f010432c:	e9 eb 07 00 00       	jmp    f0104b1c <_alltraps>
f0104331:	90                   	nop    

f0104332 <vector79>:
f0104332:	6a 00                	push   $0x0
f0104334:	6a 4f                	push   $0x4f
f0104336:	e9 e1 07 00 00       	jmp    f0104b1c <_alltraps>
f010433b:	90                   	nop    

f010433c <vector80>:
f010433c:	6a 00                	push   $0x0
f010433e:	6a 50                	push   $0x50
f0104340:	e9 d7 07 00 00       	jmp    f0104b1c <_alltraps>
f0104345:	90                   	nop    

f0104346 <vector81>:
f0104346:	6a 00                	push   $0x0
f0104348:	6a 51                	push   $0x51
f010434a:	e9 cd 07 00 00       	jmp    f0104b1c <_alltraps>
f010434f:	90                   	nop    

f0104350 <vector82>:
f0104350:	6a 00                	push   $0x0
f0104352:	6a 52                	push   $0x52
f0104354:	e9 c3 07 00 00       	jmp    f0104b1c <_alltraps>
f0104359:	90                   	nop    

f010435a <vector83>:
f010435a:	6a 00                	push   $0x0
f010435c:	6a 53                	push   $0x53
f010435e:	e9 b9 07 00 00       	jmp    f0104b1c <_alltraps>
f0104363:	90                   	nop    

f0104364 <vector84>:
f0104364:	6a 00                	push   $0x0
f0104366:	6a 54                	push   $0x54
f0104368:	e9 af 07 00 00       	jmp    f0104b1c <_alltraps>
f010436d:	90                   	nop    

f010436e <vector85>:
f010436e:	6a 00                	push   $0x0
f0104370:	6a 55                	push   $0x55
f0104372:	e9 a5 07 00 00       	jmp    f0104b1c <_alltraps>
f0104377:	90                   	nop    

f0104378 <vector86>:
f0104378:	6a 00                	push   $0x0
f010437a:	6a 56                	push   $0x56
f010437c:	e9 9b 07 00 00       	jmp    f0104b1c <_alltraps>
f0104381:	90                   	nop    

f0104382 <vector87>:
f0104382:	6a 00                	push   $0x0
f0104384:	6a 57                	push   $0x57
f0104386:	e9 91 07 00 00       	jmp    f0104b1c <_alltraps>
f010438b:	90                   	nop    

f010438c <vector88>:
f010438c:	6a 00                	push   $0x0
f010438e:	6a 58                	push   $0x58
f0104390:	e9 87 07 00 00       	jmp    f0104b1c <_alltraps>
f0104395:	90                   	nop    

f0104396 <vector89>:
f0104396:	6a 00                	push   $0x0
f0104398:	6a 59                	push   $0x59
f010439a:	e9 7d 07 00 00       	jmp    f0104b1c <_alltraps>
f010439f:	90                   	nop    

f01043a0 <vector90>:
f01043a0:	6a 00                	push   $0x0
f01043a2:	6a 5a                	push   $0x5a
f01043a4:	e9 73 07 00 00       	jmp    f0104b1c <_alltraps>
f01043a9:	90                   	nop    

f01043aa <vector91>:
f01043aa:	6a 00                	push   $0x0
f01043ac:	6a 5b                	push   $0x5b
f01043ae:	e9 69 07 00 00       	jmp    f0104b1c <_alltraps>
f01043b3:	90                   	nop    

f01043b4 <vector92>:
f01043b4:	6a 00                	push   $0x0
f01043b6:	6a 5c                	push   $0x5c
f01043b8:	e9 5f 07 00 00       	jmp    f0104b1c <_alltraps>
f01043bd:	90                   	nop    

f01043be <vector93>:
f01043be:	6a 00                	push   $0x0
f01043c0:	6a 5d                	push   $0x5d
f01043c2:	e9 55 07 00 00       	jmp    f0104b1c <_alltraps>
f01043c7:	90                   	nop    

f01043c8 <vector94>:
f01043c8:	6a 00                	push   $0x0
f01043ca:	6a 5e                	push   $0x5e
f01043cc:	e9 4b 07 00 00       	jmp    f0104b1c <_alltraps>
f01043d1:	90                   	nop    

f01043d2 <vector95>:
f01043d2:	6a 00                	push   $0x0
f01043d4:	6a 5f                	push   $0x5f
f01043d6:	e9 41 07 00 00       	jmp    f0104b1c <_alltraps>
f01043db:	90                   	nop    

f01043dc <vector96>:
f01043dc:	6a 00                	push   $0x0
f01043de:	6a 60                	push   $0x60
f01043e0:	e9 37 07 00 00       	jmp    f0104b1c <_alltraps>
f01043e5:	90                   	nop    

f01043e6 <vector97>:
f01043e6:	6a 00                	push   $0x0
f01043e8:	6a 61                	push   $0x61
f01043ea:	e9 2d 07 00 00       	jmp    f0104b1c <_alltraps>
f01043ef:	90                   	nop    

f01043f0 <vector98>:
f01043f0:	6a 00                	push   $0x0
f01043f2:	6a 62                	push   $0x62
f01043f4:	e9 23 07 00 00       	jmp    f0104b1c <_alltraps>
f01043f9:	90                   	nop    

f01043fa <vector99>:
f01043fa:	6a 00                	push   $0x0
f01043fc:	6a 63                	push   $0x63
f01043fe:	e9 19 07 00 00       	jmp    f0104b1c <_alltraps>
f0104403:	90                   	nop    

f0104404 <vector100>:
f0104404:	6a 00                	push   $0x0
f0104406:	6a 64                	push   $0x64
f0104408:	e9 0f 07 00 00       	jmp    f0104b1c <_alltraps>
f010440d:	90                   	nop    

f010440e <vector101>:
f010440e:	6a 00                	push   $0x0
f0104410:	6a 65                	push   $0x65
f0104412:	e9 05 07 00 00       	jmp    f0104b1c <_alltraps>
f0104417:	90                   	nop    

f0104418 <vector102>:
f0104418:	6a 00                	push   $0x0
f010441a:	6a 66                	push   $0x66
f010441c:	e9 fb 06 00 00       	jmp    f0104b1c <_alltraps>
f0104421:	90                   	nop    

f0104422 <vector103>:
f0104422:	6a 00                	push   $0x0
f0104424:	6a 67                	push   $0x67
f0104426:	e9 f1 06 00 00       	jmp    f0104b1c <_alltraps>
f010442b:	90                   	nop    

f010442c <vector104>:
f010442c:	6a 00                	push   $0x0
f010442e:	6a 68                	push   $0x68
f0104430:	e9 e7 06 00 00       	jmp    f0104b1c <_alltraps>
f0104435:	90                   	nop    

f0104436 <vector105>:
f0104436:	6a 00                	push   $0x0
f0104438:	6a 69                	push   $0x69
f010443a:	e9 dd 06 00 00       	jmp    f0104b1c <_alltraps>
f010443f:	90                   	nop    

f0104440 <vector106>:
f0104440:	6a 00                	push   $0x0
f0104442:	6a 6a                	push   $0x6a
f0104444:	e9 d3 06 00 00       	jmp    f0104b1c <_alltraps>
f0104449:	90                   	nop    

f010444a <vector107>:
f010444a:	6a 00                	push   $0x0
f010444c:	6a 6b                	push   $0x6b
f010444e:	e9 c9 06 00 00       	jmp    f0104b1c <_alltraps>
f0104453:	90                   	nop    

f0104454 <vector108>:
f0104454:	6a 00                	push   $0x0
f0104456:	6a 6c                	push   $0x6c
f0104458:	e9 bf 06 00 00       	jmp    f0104b1c <_alltraps>
f010445d:	90                   	nop    

f010445e <vector109>:
f010445e:	6a 00                	push   $0x0
f0104460:	6a 6d                	push   $0x6d
f0104462:	e9 b5 06 00 00       	jmp    f0104b1c <_alltraps>
f0104467:	90                   	nop    

f0104468 <vector110>:
f0104468:	6a 00                	push   $0x0
f010446a:	6a 6e                	push   $0x6e
f010446c:	e9 ab 06 00 00       	jmp    f0104b1c <_alltraps>
f0104471:	90                   	nop    

f0104472 <vector111>:
f0104472:	6a 00                	push   $0x0
f0104474:	6a 6f                	push   $0x6f
f0104476:	e9 a1 06 00 00       	jmp    f0104b1c <_alltraps>
f010447b:	90                   	nop    

f010447c <vector112>:
f010447c:	6a 00                	push   $0x0
f010447e:	6a 70                	push   $0x70
f0104480:	e9 97 06 00 00       	jmp    f0104b1c <_alltraps>
f0104485:	90                   	nop    

f0104486 <vector113>:
f0104486:	6a 00                	push   $0x0
f0104488:	6a 71                	push   $0x71
f010448a:	e9 8d 06 00 00       	jmp    f0104b1c <_alltraps>
f010448f:	90                   	nop    

f0104490 <vector114>:
f0104490:	6a 00                	push   $0x0
f0104492:	6a 72                	push   $0x72
f0104494:	e9 83 06 00 00       	jmp    f0104b1c <_alltraps>
f0104499:	90                   	nop    

f010449a <vector115>:
f010449a:	6a 00                	push   $0x0
f010449c:	6a 73                	push   $0x73
f010449e:	e9 79 06 00 00       	jmp    f0104b1c <_alltraps>
f01044a3:	90                   	nop    

f01044a4 <vector116>:
f01044a4:	6a 00                	push   $0x0
f01044a6:	6a 74                	push   $0x74
f01044a8:	e9 6f 06 00 00       	jmp    f0104b1c <_alltraps>
f01044ad:	90                   	nop    

f01044ae <vector117>:
f01044ae:	6a 00                	push   $0x0
f01044b0:	6a 75                	push   $0x75
f01044b2:	e9 65 06 00 00       	jmp    f0104b1c <_alltraps>
f01044b7:	90                   	nop    

f01044b8 <vector118>:
f01044b8:	6a 00                	push   $0x0
f01044ba:	6a 76                	push   $0x76
f01044bc:	e9 5b 06 00 00       	jmp    f0104b1c <_alltraps>
f01044c1:	90                   	nop    

f01044c2 <vector119>:
f01044c2:	6a 00                	push   $0x0
f01044c4:	6a 77                	push   $0x77
f01044c6:	e9 51 06 00 00       	jmp    f0104b1c <_alltraps>
f01044cb:	90                   	nop    

f01044cc <vector120>:
f01044cc:	6a 00                	push   $0x0
f01044ce:	6a 78                	push   $0x78
f01044d0:	e9 47 06 00 00       	jmp    f0104b1c <_alltraps>
f01044d5:	90                   	nop    

f01044d6 <vector121>:
f01044d6:	6a 00                	push   $0x0
f01044d8:	6a 79                	push   $0x79
f01044da:	e9 3d 06 00 00       	jmp    f0104b1c <_alltraps>
f01044df:	90                   	nop    

f01044e0 <vector122>:
f01044e0:	6a 00                	push   $0x0
f01044e2:	6a 7a                	push   $0x7a
f01044e4:	e9 33 06 00 00       	jmp    f0104b1c <_alltraps>
f01044e9:	90                   	nop    

f01044ea <vector123>:
f01044ea:	6a 00                	push   $0x0
f01044ec:	6a 7b                	push   $0x7b
f01044ee:	e9 29 06 00 00       	jmp    f0104b1c <_alltraps>
f01044f3:	90                   	nop    

f01044f4 <vector124>:
f01044f4:	6a 00                	push   $0x0
f01044f6:	6a 7c                	push   $0x7c
f01044f8:	e9 1f 06 00 00       	jmp    f0104b1c <_alltraps>
f01044fd:	90                   	nop    

f01044fe <vector125>:
f01044fe:	6a 00                	push   $0x0
f0104500:	6a 7d                	push   $0x7d
f0104502:	e9 15 06 00 00       	jmp    f0104b1c <_alltraps>
f0104507:	90                   	nop    

f0104508 <vector126>:
f0104508:	6a 00                	push   $0x0
f010450a:	6a 7e                	push   $0x7e
f010450c:	e9 0b 06 00 00       	jmp    f0104b1c <_alltraps>
f0104511:	90                   	nop    

f0104512 <vector127>:
f0104512:	6a 00                	push   $0x0
f0104514:	6a 7f                	push   $0x7f
f0104516:	e9 01 06 00 00       	jmp    f0104b1c <_alltraps>
f010451b:	90                   	nop    

f010451c <vector128>:
f010451c:	6a 00                	push   $0x0
f010451e:	68 80 00 00 00       	push   $0x80
f0104523:	e9 f4 05 00 00       	jmp    f0104b1c <_alltraps>

f0104528 <vector129>:
f0104528:	6a 00                	push   $0x0
f010452a:	68 81 00 00 00       	push   $0x81
f010452f:	e9 e8 05 00 00       	jmp    f0104b1c <_alltraps>

f0104534 <vector130>:
f0104534:	6a 00                	push   $0x0
f0104536:	68 82 00 00 00       	push   $0x82
f010453b:	e9 dc 05 00 00       	jmp    f0104b1c <_alltraps>

f0104540 <vector131>:
f0104540:	6a 00                	push   $0x0
f0104542:	68 83 00 00 00       	push   $0x83
f0104547:	e9 d0 05 00 00       	jmp    f0104b1c <_alltraps>

f010454c <vector132>:
f010454c:	6a 00                	push   $0x0
f010454e:	68 84 00 00 00       	push   $0x84
f0104553:	e9 c4 05 00 00       	jmp    f0104b1c <_alltraps>

f0104558 <vector133>:
f0104558:	6a 00                	push   $0x0
f010455a:	68 85 00 00 00       	push   $0x85
f010455f:	e9 b8 05 00 00       	jmp    f0104b1c <_alltraps>

f0104564 <vector134>:
f0104564:	6a 00                	push   $0x0
f0104566:	68 86 00 00 00       	push   $0x86
f010456b:	e9 ac 05 00 00       	jmp    f0104b1c <_alltraps>

f0104570 <vector135>:
f0104570:	6a 00                	push   $0x0
f0104572:	68 87 00 00 00       	push   $0x87
f0104577:	e9 a0 05 00 00       	jmp    f0104b1c <_alltraps>

f010457c <vector136>:
f010457c:	6a 00                	push   $0x0
f010457e:	68 88 00 00 00       	push   $0x88
f0104583:	e9 94 05 00 00       	jmp    f0104b1c <_alltraps>

f0104588 <vector137>:
f0104588:	6a 00                	push   $0x0
f010458a:	68 89 00 00 00       	push   $0x89
f010458f:	e9 88 05 00 00       	jmp    f0104b1c <_alltraps>

f0104594 <vector138>:
f0104594:	6a 00                	push   $0x0
f0104596:	68 8a 00 00 00       	push   $0x8a
f010459b:	e9 7c 05 00 00       	jmp    f0104b1c <_alltraps>

f01045a0 <vector139>:
f01045a0:	6a 00                	push   $0x0
f01045a2:	68 8b 00 00 00       	push   $0x8b
f01045a7:	e9 70 05 00 00       	jmp    f0104b1c <_alltraps>

f01045ac <vector140>:
f01045ac:	6a 00                	push   $0x0
f01045ae:	68 8c 00 00 00       	push   $0x8c
f01045b3:	e9 64 05 00 00       	jmp    f0104b1c <_alltraps>

f01045b8 <vector141>:
f01045b8:	6a 00                	push   $0x0
f01045ba:	68 8d 00 00 00       	push   $0x8d
f01045bf:	e9 58 05 00 00       	jmp    f0104b1c <_alltraps>

f01045c4 <vector142>:
f01045c4:	6a 00                	push   $0x0
f01045c6:	68 8e 00 00 00       	push   $0x8e
f01045cb:	e9 4c 05 00 00       	jmp    f0104b1c <_alltraps>

f01045d0 <vector143>:
f01045d0:	6a 00                	push   $0x0
f01045d2:	68 8f 00 00 00       	push   $0x8f
f01045d7:	e9 40 05 00 00       	jmp    f0104b1c <_alltraps>

f01045dc <vector144>:
f01045dc:	6a 00                	push   $0x0
f01045de:	68 90 00 00 00       	push   $0x90
f01045e3:	e9 34 05 00 00       	jmp    f0104b1c <_alltraps>

f01045e8 <vector145>:
f01045e8:	6a 00                	push   $0x0
f01045ea:	68 91 00 00 00       	push   $0x91
f01045ef:	e9 28 05 00 00       	jmp    f0104b1c <_alltraps>

f01045f4 <vector146>:
f01045f4:	6a 00                	push   $0x0
f01045f6:	68 92 00 00 00       	push   $0x92
f01045fb:	e9 1c 05 00 00       	jmp    f0104b1c <_alltraps>

f0104600 <vector147>:
f0104600:	6a 00                	push   $0x0
f0104602:	68 93 00 00 00       	push   $0x93
f0104607:	e9 10 05 00 00       	jmp    f0104b1c <_alltraps>

f010460c <vector148>:
f010460c:	6a 00                	push   $0x0
f010460e:	68 94 00 00 00       	push   $0x94
f0104613:	e9 04 05 00 00       	jmp    f0104b1c <_alltraps>

f0104618 <vector149>:
f0104618:	6a 00                	push   $0x0
f010461a:	68 95 00 00 00       	push   $0x95
f010461f:	e9 f8 04 00 00       	jmp    f0104b1c <_alltraps>

f0104624 <vector150>:
f0104624:	6a 00                	push   $0x0
f0104626:	68 96 00 00 00       	push   $0x96
f010462b:	e9 ec 04 00 00       	jmp    f0104b1c <_alltraps>

f0104630 <vector151>:
f0104630:	6a 00                	push   $0x0
f0104632:	68 97 00 00 00       	push   $0x97
f0104637:	e9 e0 04 00 00       	jmp    f0104b1c <_alltraps>

f010463c <vector152>:
f010463c:	6a 00                	push   $0x0
f010463e:	68 98 00 00 00       	push   $0x98
f0104643:	e9 d4 04 00 00       	jmp    f0104b1c <_alltraps>

f0104648 <vector153>:
f0104648:	6a 00                	push   $0x0
f010464a:	68 99 00 00 00       	push   $0x99
f010464f:	e9 c8 04 00 00       	jmp    f0104b1c <_alltraps>

f0104654 <vector154>:
f0104654:	6a 00                	push   $0x0
f0104656:	68 9a 00 00 00       	push   $0x9a
f010465b:	e9 bc 04 00 00       	jmp    f0104b1c <_alltraps>

f0104660 <vector155>:
f0104660:	6a 00                	push   $0x0
f0104662:	68 9b 00 00 00       	push   $0x9b
f0104667:	e9 b0 04 00 00       	jmp    f0104b1c <_alltraps>

f010466c <vector156>:
f010466c:	6a 00                	push   $0x0
f010466e:	68 9c 00 00 00       	push   $0x9c
f0104673:	e9 a4 04 00 00       	jmp    f0104b1c <_alltraps>

f0104678 <vector157>:
f0104678:	6a 00                	push   $0x0
f010467a:	68 9d 00 00 00       	push   $0x9d
f010467f:	e9 98 04 00 00       	jmp    f0104b1c <_alltraps>

f0104684 <vector158>:
f0104684:	6a 00                	push   $0x0
f0104686:	68 9e 00 00 00       	push   $0x9e
f010468b:	e9 8c 04 00 00       	jmp    f0104b1c <_alltraps>

f0104690 <vector159>:
f0104690:	6a 00                	push   $0x0
f0104692:	68 9f 00 00 00       	push   $0x9f
f0104697:	e9 80 04 00 00       	jmp    f0104b1c <_alltraps>

f010469c <vector160>:
f010469c:	6a 00                	push   $0x0
f010469e:	68 a0 00 00 00       	push   $0xa0
f01046a3:	e9 74 04 00 00       	jmp    f0104b1c <_alltraps>

f01046a8 <vector161>:
f01046a8:	6a 00                	push   $0x0
f01046aa:	68 a1 00 00 00       	push   $0xa1
f01046af:	e9 68 04 00 00       	jmp    f0104b1c <_alltraps>

f01046b4 <vector162>:
f01046b4:	6a 00                	push   $0x0
f01046b6:	68 a2 00 00 00       	push   $0xa2
f01046bb:	e9 5c 04 00 00       	jmp    f0104b1c <_alltraps>

f01046c0 <vector163>:
f01046c0:	6a 00                	push   $0x0
f01046c2:	68 a3 00 00 00       	push   $0xa3
f01046c7:	e9 50 04 00 00       	jmp    f0104b1c <_alltraps>

f01046cc <vector164>:
f01046cc:	6a 00                	push   $0x0
f01046ce:	68 a4 00 00 00       	push   $0xa4
f01046d3:	e9 44 04 00 00       	jmp    f0104b1c <_alltraps>

f01046d8 <vector165>:
f01046d8:	6a 00                	push   $0x0
f01046da:	68 a5 00 00 00       	push   $0xa5
f01046df:	e9 38 04 00 00       	jmp    f0104b1c <_alltraps>

f01046e4 <vector166>:
f01046e4:	6a 00                	push   $0x0
f01046e6:	68 a6 00 00 00       	push   $0xa6
f01046eb:	e9 2c 04 00 00       	jmp    f0104b1c <_alltraps>

f01046f0 <vector167>:
f01046f0:	6a 00                	push   $0x0
f01046f2:	68 a7 00 00 00       	push   $0xa7
f01046f7:	e9 20 04 00 00       	jmp    f0104b1c <_alltraps>

f01046fc <vector168>:
f01046fc:	6a 00                	push   $0x0
f01046fe:	68 a8 00 00 00       	push   $0xa8
f0104703:	e9 14 04 00 00       	jmp    f0104b1c <_alltraps>

f0104708 <vector169>:
f0104708:	6a 00                	push   $0x0
f010470a:	68 a9 00 00 00       	push   $0xa9
f010470f:	e9 08 04 00 00       	jmp    f0104b1c <_alltraps>

f0104714 <vector170>:
f0104714:	6a 00                	push   $0x0
f0104716:	68 aa 00 00 00       	push   $0xaa
f010471b:	e9 fc 03 00 00       	jmp    f0104b1c <_alltraps>

f0104720 <vector171>:
f0104720:	6a 00                	push   $0x0
f0104722:	68 ab 00 00 00       	push   $0xab
f0104727:	e9 f0 03 00 00       	jmp    f0104b1c <_alltraps>

f010472c <vector172>:
f010472c:	6a 00                	push   $0x0
f010472e:	68 ac 00 00 00       	push   $0xac
f0104733:	e9 e4 03 00 00       	jmp    f0104b1c <_alltraps>

f0104738 <vector173>:
f0104738:	6a 00                	push   $0x0
f010473a:	68 ad 00 00 00       	push   $0xad
f010473f:	e9 d8 03 00 00       	jmp    f0104b1c <_alltraps>

f0104744 <vector174>:
f0104744:	6a 00                	push   $0x0
f0104746:	68 ae 00 00 00       	push   $0xae
f010474b:	e9 cc 03 00 00       	jmp    f0104b1c <_alltraps>

f0104750 <vector175>:
f0104750:	6a 00                	push   $0x0
f0104752:	68 af 00 00 00       	push   $0xaf
f0104757:	e9 c0 03 00 00       	jmp    f0104b1c <_alltraps>

f010475c <vector176>:
f010475c:	6a 00                	push   $0x0
f010475e:	68 b0 00 00 00       	push   $0xb0
f0104763:	e9 b4 03 00 00       	jmp    f0104b1c <_alltraps>

f0104768 <vector177>:
f0104768:	6a 00                	push   $0x0
f010476a:	68 b1 00 00 00       	push   $0xb1
f010476f:	e9 a8 03 00 00       	jmp    f0104b1c <_alltraps>

f0104774 <vector178>:
f0104774:	6a 00                	push   $0x0
f0104776:	68 b2 00 00 00       	push   $0xb2
f010477b:	e9 9c 03 00 00       	jmp    f0104b1c <_alltraps>

f0104780 <vector179>:
f0104780:	6a 00                	push   $0x0
f0104782:	68 b3 00 00 00       	push   $0xb3
f0104787:	e9 90 03 00 00       	jmp    f0104b1c <_alltraps>

f010478c <vector180>:
f010478c:	6a 00                	push   $0x0
f010478e:	68 b4 00 00 00       	push   $0xb4
f0104793:	e9 84 03 00 00       	jmp    f0104b1c <_alltraps>

f0104798 <vector181>:
f0104798:	6a 00                	push   $0x0
f010479a:	68 b5 00 00 00       	push   $0xb5
f010479f:	e9 78 03 00 00       	jmp    f0104b1c <_alltraps>

f01047a4 <vector182>:
f01047a4:	6a 00                	push   $0x0
f01047a6:	68 b6 00 00 00       	push   $0xb6
f01047ab:	e9 6c 03 00 00       	jmp    f0104b1c <_alltraps>

f01047b0 <vector183>:
f01047b0:	6a 00                	push   $0x0
f01047b2:	68 b7 00 00 00       	push   $0xb7
f01047b7:	e9 60 03 00 00       	jmp    f0104b1c <_alltraps>

f01047bc <vector184>:
f01047bc:	6a 00                	push   $0x0
f01047be:	68 b8 00 00 00       	push   $0xb8
f01047c3:	e9 54 03 00 00       	jmp    f0104b1c <_alltraps>

f01047c8 <vector185>:
f01047c8:	6a 00                	push   $0x0
f01047ca:	68 b9 00 00 00       	push   $0xb9
f01047cf:	e9 48 03 00 00       	jmp    f0104b1c <_alltraps>

f01047d4 <vector186>:
f01047d4:	6a 00                	push   $0x0
f01047d6:	68 ba 00 00 00       	push   $0xba
f01047db:	e9 3c 03 00 00       	jmp    f0104b1c <_alltraps>

f01047e0 <vector187>:
f01047e0:	6a 00                	push   $0x0
f01047e2:	68 bb 00 00 00       	push   $0xbb
f01047e7:	e9 30 03 00 00       	jmp    f0104b1c <_alltraps>

f01047ec <vector188>:
f01047ec:	6a 00                	push   $0x0
f01047ee:	68 bc 00 00 00       	push   $0xbc
f01047f3:	e9 24 03 00 00       	jmp    f0104b1c <_alltraps>

f01047f8 <vector189>:
f01047f8:	6a 00                	push   $0x0
f01047fa:	68 bd 00 00 00       	push   $0xbd
f01047ff:	e9 18 03 00 00       	jmp    f0104b1c <_alltraps>

f0104804 <vector190>:
f0104804:	6a 00                	push   $0x0
f0104806:	68 be 00 00 00       	push   $0xbe
f010480b:	e9 0c 03 00 00       	jmp    f0104b1c <_alltraps>

f0104810 <vector191>:
f0104810:	6a 00                	push   $0x0
f0104812:	68 bf 00 00 00       	push   $0xbf
f0104817:	e9 00 03 00 00       	jmp    f0104b1c <_alltraps>

f010481c <vector192>:
f010481c:	6a 00                	push   $0x0
f010481e:	68 c0 00 00 00       	push   $0xc0
f0104823:	e9 f4 02 00 00       	jmp    f0104b1c <_alltraps>

f0104828 <vector193>:
f0104828:	6a 00                	push   $0x0
f010482a:	68 c1 00 00 00       	push   $0xc1
f010482f:	e9 e8 02 00 00       	jmp    f0104b1c <_alltraps>

f0104834 <vector194>:
f0104834:	6a 00                	push   $0x0
f0104836:	68 c2 00 00 00       	push   $0xc2
f010483b:	e9 dc 02 00 00       	jmp    f0104b1c <_alltraps>

f0104840 <vector195>:
f0104840:	6a 00                	push   $0x0
f0104842:	68 c3 00 00 00       	push   $0xc3
f0104847:	e9 d0 02 00 00       	jmp    f0104b1c <_alltraps>

f010484c <vector196>:
f010484c:	6a 00                	push   $0x0
f010484e:	68 c4 00 00 00       	push   $0xc4
f0104853:	e9 c4 02 00 00       	jmp    f0104b1c <_alltraps>

f0104858 <vector197>:
f0104858:	6a 00                	push   $0x0
f010485a:	68 c5 00 00 00       	push   $0xc5
f010485f:	e9 b8 02 00 00       	jmp    f0104b1c <_alltraps>

f0104864 <vector198>:
f0104864:	6a 00                	push   $0x0
f0104866:	68 c6 00 00 00       	push   $0xc6
f010486b:	e9 ac 02 00 00       	jmp    f0104b1c <_alltraps>

f0104870 <vector199>:
f0104870:	6a 00                	push   $0x0
f0104872:	68 c7 00 00 00       	push   $0xc7
f0104877:	e9 a0 02 00 00       	jmp    f0104b1c <_alltraps>

f010487c <vector200>:
f010487c:	6a 00                	push   $0x0
f010487e:	68 c8 00 00 00       	push   $0xc8
f0104883:	e9 94 02 00 00       	jmp    f0104b1c <_alltraps>

f0104888 <vector201>:
f0104888:	6a 00                	push   $0x0
f010488a:	68 c9 00 00 00       	push   $0xc9
f010488f:	e9 88 02 00 00       	jmp    f0104b1c <_alltraps>

f0104894 <vector202>:
f0104894:	6a 00                	push   $0x0
f0104896:	68 ca 00 00 00       	push   $0xca
f010489b:	e9 7c 02 00 00       	jmp    f0104b1c <_alltraps>

f01048a0 <vector203>:
f01048a0:	6a 00                	push   $0x0
f01048a2:	68 cb 00 00 00       	push   $0xcb
f01048a7:	e9 70 02 00 00       	jmp    f0104b1c <_alltraps>

f01048ac <vector204>:
f01048ac:	6a 00                	push   $0x0
f01048ae:	68 cc 00 00 00       	push   $0xcc
f01048b3:	e9 64 02 00 00       	jmp    f0104b1c <_alltraps>

f01048b8 <vector205>:
f01048b8:	6a 00                	push   $0x0
f01048ba:	68 cd 00 00 00       	push   $0xcd
f01048bf:	e9 58 02 00 00       	jmp    f0104b1c <_alltraps>

f01048c4 <vector206>:
f01048c4:	6a 00                	push   $0x0
f01048c6:	68 ce 00 00 00       	push   $0xce
f01048cb:	e9 4c 02 00 00       	jmp    f0104b1c <_alltraps>

f01048d0 <vector207>:
f01048d0:	6a 00                	push   $0x0
f01048d2:	68 cf 00 00 00       	push   $0xcf
f01048d7:	e9 40 02 00 00       	jmp    f0104b1c <_alltraps>

f01048dc <vector208>:
f01048dc:	6a 00                	push   $0x0
f01048de:	68 d0 00 00 00       	push   $0xd0
f01048e3:	e9 34 02 00 00       	jmp    f0104b1c <_alltraps>

f01048e8 <vector209>:
f01048e8:	6a 00                	push   $0x0
f01048ea:	68 d1 00 00 00       	push   $0xd1
f01048ef:	e9 28 02 00 00       	jmp    f0104b1c <_alltraps>

f01048f4 <vector210>:
f01048f4:	6a 00                	push   $0x0
f01048f6:	68 d2 00 00 00       	push   $0xd2
f01048fb:	e9 1c 02 00 00       	jmp    f0104b1c <_alltraps>

f0104900 <vector211>:
f0104900:	6a 00                	push   $0x0
f0104902:	68 d3 00 00 00       	push   $0xd3
f0104907:	e9 10 02 00 00       	jmp    f0104b1c <_alltraps>

f010490c <vector212>:
f010490c:	6a 00                	push   $0x0
f010490e:	68 d4 00 00 00       	push   $0xd4
f0104913:	e9 04 02 00 00       	jmp    f0104b1c <_alltraps>

f0104918 <vector213>:
f0104918:	6a 00                	push   $0x0
f010491a:	68 d5 00 00 00       	push   $0xd5
f010491f:	e9 f8 01 00 00       	jmp    f0104b1c <_alltraps>

f0104924 <vector214>:
f0104924:	6a 00                	push   $0x0
f0104926:	68 d6 00 00 00       	push   $0xd6
f010492b:	e9 ec 01 00 00       	jmp    f0104b1c <_alltraps>

f0104930 <vector215>:
f0104930:	6a 00                	push   $0x0
f0104932:	68 d7 00 00 00       	push   $0xd7
f0104937:	e9 e0 01 00 00       	jmp    f0104b1c <_alltraps>

f010493c <vector216>:
f010493c:	6a 00                	push   $0x0
f010493e:	68 d8 00 00 00       	push   $0xd8
f0104943:	e9 d4 01 00 00       	jmp    f0104b1c <_alltraps>

f0104948 <vector217>:
f0104948:	6a 00                	push   $0x0
f010494a:	68 d9 00 00 00       	push   $0xd9
f010494f:	e9 c8 01 00 00       	jmp    f0104b1c <_alltraps>

f0104954 <vector218>:
f0104954:	6a 00                	push   $0x0
f0104956:	68 da 00 00 00       	push   $0xda
f010495b:	e9 bc 01 00 00       	jmp    f0104b1c <_alltraps>

f0104960 <vector219>:
f0104960:	6a 00                	push   $0x0
f0104962:	68 db 00 00 00       	push   $0xdb
f0104967:	e9 b0 01 00 00       	jmp    f0104b1c <_alltraps>

f010496c <vector220>:
f010496c:	6a 00                	push   $0x0
f010496e:	68 dc 00 00 00       	push   $0xdc
f0104973:	e9 a4 01 00 00       	jmp    f0104b1c <_alltraps>

f0104978 <vector221>:
f0104978:	6a 00                	push   $0x0
f010497a:	68 dd 00 00 00       	push   $0xdd
f010497f:	e9 98 01 00 00       	jmp    f0104b1c <_alltraps>

f0104984 <vector222>:
f0104984:	6a 00                	push   $0x0
f0104986:	68 de 00 00 00       	push   $0xde
f010498b:	e9 8c 01 00 00       	jmp    f0104b1c <_alltraps>

f0104990 <vector223>:
f0104990:	6a 00                	push   $0x0
f0104992:	68 df 00 00 00       	push   $0xdf
f0104997:	e9 80 01 00 00       	jmp    f0104b1c <_alltraps>

f010499c <vector224>:
f010499c:	6a 00                	push   $0x0
f010499e:	68 e0 00 00 00       	push   $0xe0
f01049a3:	e9 74 01 00 00       	jmp    f0104b1c <_alltraps>

f01049a8 <vector225>:
f01049a8:	6a 00                	push   $0x0
f01049aa:	68 e1 00 00 00       	push   $0xe1
f01049af:	e9 68 01 00 00       	jmp    f0104b1c <_alltraps>

f01049b4 <vector226>:
f01049b4:	6a 00                	push   $0x0
f01049b6:	68 e2 00 00 00       	push   $0xe2
f01049bb:	e9 5c 01 00 00       	jmp    f0104b1c <_alltraps>

f01049c0 <vector227>:
f01049c0:	6a 00                	push   $0x0
f01049c2:	68 e3 00 00 00       	push   $0xe3
f01049c7:	e9 50 01 00 00       	jmp    f0104b1c <_alltraps>

f01049cc <vector228>:
f01049cc:	6a 00                	push   $0x0
f01049ce:	68 e4 00 00 00       	push   $0xe4
f01049d3:	e9 44 01 00 00       	jmp    f0104b1c <_alltraps>

f01049d8 <vector229>:
f01049d8:	6a 00                	push   $0x0
f01049da:	68 e5 00 00 00       	push   $0xe5
f01049df:	e9 38 01 00 00       	jmp    f0104b1c <_alltraps>

f01049e4 <vector230>:
f01049e4:	6a 00                	push   $0x0
f01049e6:	68 e6 00 00 00       	push   $0xe6
f01049eb:	e9 2c 01 00 00       	jmp    f0104b1c <_alltraps>

f01049f0 <vector231>:
f01049f0:	6a 00                	push   $0x0
f01049f2:	68 e7 00 00 00       	push   $0xe7
f01049f7:	e9 20 01 00 00       	jmp    f0104b1c <_alltraps>

f01049fc <vector232>:
f01049fc:	6a 00                	push   $0x0
f01049fe:	68 e8 00 00 00       	push   $0xe8
f0104a03:	e9 14 01 00 00       	jmp    f0104b1c <_alltraps>

f0104a08 <vector233>:
f0104a08:	6a 00                	push   $0x0
f0104a0a:	68 e9 00 00 00       	push   $0xe9
f0104a0f:	e9 08 01 00 00       	jmp    f0104b1c <_alltraps>

f0104a14 <vector234>:
f0104a14:	6a 00                	push   $0x0
f0104a16:	68 ea 00 00 00       	push   $0xea
f0104a1b:	e9 fc 00 00 00       	jmp    f0104b1c <_alltraps>

f0104a20 <vector235>:
f0104a20:	6a 00                	push   $0x0
f0104a22:	68 eb 00 00 00       	push   $0xeb
f0104a27:	e9 f0 00 00 00       	jmp    f0104b1c <_alltraps>

f0104a2c <vector236>:
f0104a2c:	6a 00                	push   $0x0
f0104a2e:	68 ec 00 00 00       	push   $0xec
f0104a33:	e9 e4 00 00 00       	jmp    f0104b1c <_alltraps>

f0104a38 <vector237>:
f0104a38:	6a 00                	push   $0x0
f0104a3a:	68 ed 00 00 00       	push   $0xed
f0104a3f:	e9 d8 00 00 00       	jmp    f0104b1c <_alltraps>

f0104a44 <vector238>:
f0104a44:	6a 00                	push   $0x0
f0104a46:	68 ee 00 00 00       	push   $0xee
f0104a4b:	e9 cc 00 00 00       	jmp    f0104b1c <_alltraps>

f0104a50 <vector239>:
f0104a50:	6a 00                	push   $0x0
f0104a52:	68 ef 00 00 00       	push   $0xef
f0104a57:	e9 c0 00 00 00       	jmp    f0104b1c <_alltraps>

f0104a5c <vector240>:
f0104a5c:	6a 00                	push   $0x0
f0104a5e:	68 f0 00 00 00       	push   $0xf0
f0104a63:	e9 b4 00 00 00       	jmp    f0104b1c <_alltraps>

f0104a68 <vector241>:
f0104a68:	6a 00                	push   $0x0
f0104a6a:	68 f1 00 00 00       	push   $0xf1
f0104a6f:	e9 a8 00 00 00       	jmp    f0104b1c <_alltraps>

f0104a74 <vector242>:
f0104a74:	6a 00                	push   $0x0
f0104a76:	68 f2 00 00 00       	push   $0xf2
f0104a7b:	e9 9c 00 00 00       	jmp    f0104b1c <_alltraps>

f0104a80 <vector243>:
f0104a80:	6a 00                	push   $0x0
f0104a82:	68 f3 00 00 00       	push   $0xf3
f0104a87:	e9 90 00 00 00       	jmp    f0104b1c <_alltraps>

f0104a8c <vector244>:
f0104a8c:	6a 00                	push   $0x0
f0104a8e:	68 f4 00 00 00       	push   $0xf4
f0104a93:	e9 84 00 00 00       	jmp    f0104b1c <_alltraps>

f0104a98 <vector245>:
f0104a98:	6a 00                	push   $0x0
f0104a9a:	68 f5 00 00 00       	push   $0xf5
f0104a9f:	e9 78 00 00 00       	jmp    f0104b1c <_alltraps>

f0104aa4 <vector246>:
f0104aa4:	6a 00                	push   $0x0
f0104aa6:	68 f6 00 00 00       	push   $0xf6
f0104aab:	e9 6c 00 00 00       	jmp    f0104b1c <_alltraps>

f0104ab0 <vector247>:
f0104ab0:	6a 00                	push   $0x0
f0104ab2:	68 f7 00 00 00       	push   $0xf7
f0104ab7:	e9 60 00 00 00       	jmp    f0104b1c <_alltraps>

f0104abc <vector248>:
f0104abc:	6a 00                	push   $0x0
f0104abe:	68 f8 00 00 00       	push   $0xf8
f0104ac3:	e9 54 00 00 00       	jmp    f0104b1c <_alltraps>

f0104ac8 <vector249>:
f0104ac8:	6a 00                	push   $0x0
f0104aca:	68 f9 00 00 00       	push   $0xf9
f0104acf:	e9 48 00 00 00       	jmp    f0104b1c <_alltraps>

f0104ad4 <vector250>:
f0104ad4:	6a 00                	push   $0x0
f0104ad6:	68 fa 00 00 00       	push   $0xfa
f0104adb:	e9 3c 00 00 00       	jmp    f0104b1c <_alltraps>

f0104ae0 <vector251>:
f0104ae0:	6a 00                	push   $0x0
f0104ae2:	68 fb 00 00 00       	push   $0xfb
f0104ae7:	e9 30 00 00 00       	jmp    f0104b1c <_alltraps>

f0104aec <vector252>:
f0104aec:	6a 00                	push   $0x0
f0104aee:	68 fc 00 00 00       	push   $0xfc
f0104af3:	e9 24 00 00 00       	jmp    f0104b1c <_alltraps>

f0104af8 <vector253>:
f0104af8:	6a 00                	push   $0x0
f0104afa:	68 fd 00 00 00       	push   $0xfd
f0104aff:	e9 18 00 00 00       	jmp    f0104b1c <_alltraps>

f0104b04 <vector254>:
f0104b04:	6a 00                	push   $0x0
f0104b06:	68 fe 00 00 00       	push   $0xfe
f0104b0b:	e9 0c 00 00 00       	jmp    f0104b1c <_alltraps>

f0104b10 <vector255>:
f0104b10:	6a 00                	push   $0x0
f0104b12:	68 ff 00 00 00       	push   $0xff
f0104b17:	e9 00 00 00 00       	jmp    f0104b1c <_alltraps>

f0104b1c <_alltraps>:
f0104b1c:	1e                   	push   %ds
f0104b1d:	06                   	push   %es
f0104b1e:	60                   	pusha  
f0104b1f:	66 b8 10 00          	mov    $0x10,%ax
f0104b23:	8e d8                	mov    %eax,%ds
f0104b25:	8e c0                	mov    %eax,%es
f0104b27:	54                   	push   %esp
f0104b28:	e8 68 f3 ff ff       	call   f0103e95 <trap>
f0104b2d:	83 c4 04             	add    $0x4,%esp

f0104b30 <trapret>:
f0104b30:	83 c4 04             	add    $0x4,%esp
f0104b33:	61                   	popa   
f0104b34:	07                   	pop    %es
f0104b35:	1f                   	pop    %ds
f0104b36:	83 c4 08             	add    $0x8,%esp
f0104b39:	cf                   	iret   
	...

f0104b3c <sched_yield>:


// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104b3c:	55                   	push   %ebp
f0104b3d:	89 e5                	mov    %esp,%ebp
f0104b3f:	56                   	push   %esi
f0104b40:	53                   	push   %ebx
f0104b41:	83 ec 10             	sub    $0x10,%esp

	// LAB 4: Your code here.
	uint32_t retesp;
	envid_t envid;
	int index=0,i;
	if(curenv){
f0104b44:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f0104b49:	be 00 00 00 00       	mov    $0x0,%esi
f0104b4e:	85 c0                	test   %eax,%eax
f0104b50:	74 1b                	je     f0104b6d <sched_yield+0x31>
		//retesp=curenv->env_tf.tf_regs.reg_oesp-0x20;
		index=ENVX(curenv->env_id)-ENVX(envs[0].env_id);
f0104b52:	8b 40 4c             	mov    0x4c(%eax),%eax
f0104b55:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104b5a:	8b 15 c0 95 1b f0    	mov    0xf01b95c0,%edx
f0104b60:	8b 52 4c             	mov    0x4c(%edx),%edx
f0104b63:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0104b69:	89 c6                	mov    %eax,%esi
f0104b6b:	29 d6                	sub    %edx,%esi
	//	}
	//下面代码更简洁
	for(i=1;i<=NENV;i++)
	{
		envid=(i+index)%NENV;
		if(envs[envid].env_status==ENV_RUNNABLE)
f0104b6d:	8b 1d c0 95 1b f0    	mov    0xf01b95c0,%ebx
f0104b73:	b9 01 00 00 00       	mov    $0x1,%ecx
	//		trapret();
	//	}
	//下面代码更简洁
	for(i=1;i<=NENV;i++)
	{
		envid=(i+index)%NENV;
f0104b78:	8d 04 31             	lea    (%ecx,%esi,1),%eax
f0104b7b:	89 c2                	mov    %eax,%edx
f0104b7d:	c1 fa 1f             	sar    $0x1f,%edx
f0104b80:	c1 ea 16             	shr    $0x16,%edx
f0104b83:	01 d0                	add    %edx,%eax
f0104b85:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104b8a:	29 d0                	sub    %edx,%eax
f0104b8c:	89 c2                	mov    %eax,%edx
		if(envs[envid].env_status==ENV_RUNNABLE)
f0104b8e:	6b c0 7c             	imul   $0x7c,%eax,%eax
f0104b91:	01 d8                	add    %ebx,%eax
f0104b93:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104b97:	75 0c                	jne    f0104ba5 <sched_yield+0x69>
		{
			if(envid==0)
f0104b99:	85 d2                	test   %edx,%edx
f0104b9b:	74 08                	je     f0104ba5 <sched_yield+0x69>
				continue;
			//cprintf("\nslected env:%x\n",envs[envid].env_id);
			env_run(&envs[envid]);
f0104b9d:	89 04 24             	mov    %eax,(%esp)
f0104ba0:	e8 ac e6 ff ff       	call   f0103251 <env_run>
	//		env_run(&envs[i]);
	//		write_esp(retesp);
	//		trapret();
	//	}
	//下面代码更简洁
	for(i=1;i<=NENV;i++)
f0104ba5:	83 c1 01             	add    $0x1,%ecx
f0104ba8:	81 f9 01 04 00 00    	cmp    $0x401,%ecx
f0104bae:	75 c8                	jne    f0104b78 <sched_yield+0x3c>
			//write_esp(retesp);
			//trapret();
		}
	}
	// Run the special idle environment when nothing else is runnable.
	if (envs[0].env_status == ENV_RUNNABLE)
f0104bb0:	83 7b 54 01          	cmpl   $0x1,0x54(%ebx)
f0104bb4:	75 08                	jne    f0104bbe <sched_yield+0x82>
		env_run(&envs[0]);
f0104bb6:	89 1c 24             	mov    %ebx,(%esp)
f0104bb9:	e8 93 e6 ff ff       	call   f0103251 <env_run>
	else {
		cprintf("Destroyed all environments - nothing more to do!\n");
f0104bbe:	c7 04 24 10 b5 10 f0 	movl   $0xf010b510,(%esp)
f0104bc5:	e8 0d ee ff ff       	call   f01039d7 <cprintf>
		while (1)
			monitor(NULL);
f0104bca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104bd1:	e8 a1 bd ff ff       	call   f0100977 <monitor>
f0104bd6:	eb f2                	jmp    f0104bca <sched_yield+0x8e>
	...

f0104be0 <sys_page_map>:
//		address space.
//	-E_NO_MEM if there's no memory to allocate any necessary page tables.
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
f0104be0:	55                   	push   %ebp
f0104be1:	89 e5                	mov    %esp,%ebp
f0104be3:	83 ec 38             	sub    $0x38,%esp
f0104be6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104be9:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104bec:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104bef:	89 c3                	mov    %eax,%ebx
f0104bf1:	89 d7                	mov    %edx,%edi
f0104bf3:	89 ce                	mov    %ecx,%esi
	struct Env *srcenv,*dstenv;
	struct Page *pg;
	pte_t *pte;
	physaddr_t old_cr3;
	//cprintf("srcenvid=%x dstenvid=%x srcva=%x dstva=%x perm=%x\n",srcenvid,dstenvid,(uint32_t)srcva,(uint32_t)dstva,perm);
	if(srcenvid==0)
f0104bf5:	85 c0                	test   %eax,%eax
f0104bf7:	75 0a                	jne    f0104c03 <sys_page_map+0x23>
		srcenv=curenv;
f0104bf9:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f0104bfe:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c01:	eb 1f                	jmp    f0104c22 <sys_page_map+0x42>
	else
		if((r=envid2env(srcenvid,&srcenv,0))<0)//LAB 5:be carefull to use envid2env
f0104c03:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104c0a:	00 
f0104c0b:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104c0e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c12:	89 1c 24             	mov    %ebx,(%esp)
f0104c15:	e8 1a e5 ff ff       	call   f0103134 <envid2env>
f0104c1a:	85 c0                	test   %eax,%eax
f0104c1c:	0f 88 c2 00 00 00    	js     f0104ce4 <sys_page_map+0x104>
        	{
                	return r;
        	}
	if(dstenvid==0)
f0104c22:	85 f6                	test   %esi,%esi
f0104c24:	75 0a                	jne    f0104c30 <sys_page_map+0x50>
		dstenv=curenv;
f0104c26:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f0104c2b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104c2e:	eb 1f                	jmp    f0104c4f <sys_page_map+0x6f>
	else
		if((r=envid2env(dstenvid,&dstenv,0))<0)
f0104c30:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104c37:	00 
f0104c38:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104c3b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c3f:	89 34 24             	mov    %esi,(%esp)
f0104c42:	e8 ed e4 ff ff       	call   f0103134 <envid2env>
f0104c47:	85 c0                	test   %eax,%eax
f0104c49:	0f 88 95 00 00 00    	js     f0104ce4 <sys_page_map+0x104>
        	{
                	return r;
        	}
	if(((uint32_t)srcva>=UTOP)||((uint32_t)srcva&0xfff)||((uint32_t)dstva>=UTOP)||((uint32_t)srcva&0xfff))
f0104c4f:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0104c55:	0f 87 84 00 00 00    	ja     f0104cdf <sys_page_map+0xff>
f0104c5b:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0104c61:	75 7c                	jne    f0104cdf <sys_page_map+0xff>
f0104c63:	81 7d 08 ff ff bf ee 	cmpl   $0xeebfffff,0x8(%ebp)
f0104c6a:	77 73                	ja     f0104cdf <sys_page_map+0xff>
                return -E_INVAL;
	if(perm&(~PTE_USER))
f0104c6c:	f7 45 0c f8 f1 ff ff 	testl  $0xfffff1f8,0xc(%ebp)
f0104c73:	75 6a                	jne    f0104cdf <sys_page_map+0xff>

static __inline uint32_t
rcr3(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr3,%0" : "=r" (val));
f0104c75:	0f 20 db             	mov    %cr3,%ebx
                return -E_INVAL;
	old_cr3=rcr3();
	lcr3(srcenv->env_cr3);
f0104c78:	8b 55 f0             	mov    -0x10(%ebp),%edx
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104c7b:	8b 42 60             	mov    0x60(%edx),%eax
f0104c7e:	0f 22 d8             	mov    %eax,%cr3
	if(!(pg=page_lookup(srcenv->env_pgdir,srcva,&pte)))
f0104c81:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0104c84:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104c88:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104c8c:	8b 42 5c             	mov    0x5c(%edx),%eax
f0104c8f:	89 04 24             	mov    %eax,(%esp)
f0104c92:	e8 84 c7 ff ff       	call   f010141b <page_lookup>
f0104c97:	89 c1                	mov    %eax,%ecx
f0104c99:	85 c0                	test   %eax,%eax
f0104c9b:	74 42                	je     f0104cdf <sys_page_map+0xff>
		return -E_INVAL;
	if(!(*pte&PTE_W)&&(perm&PTE_W))	//当srcva页面是只读时，perm不能有写权限
f0104c9d:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104ca0:	f6 00 02             	testb  $0x2,(%eax)
f0104ca3:	75 06                	jne    f0104cab <sys_page_map+0xcb>
f0104ca5:	f6 45 0c 02          	testb  $0x2,0xc(%ebp)
f0104ca9:	75 34                	jne    f0104cdf <sys_page_map+0xff>
		return -E_INVAL;
	lcr3(dstenv->env_cr3);
f0104cab:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104cae:	8b 50 60             	mov    0x60(%eax),%edx
f0104cb1:	0f 22 da             	mov    %edx,%cr3
	if((r=page_insert(dstenv->env_pgdir,pg,dstva,perm))<0)
f0104cb4:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104cb7:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104cbb:	8b 55 08             	mov    0x8(%ebp),%edx
f0104cbe:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104cc2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104cc6:	8b 40 5c             	mov    0x5c(%eax),%eax
f0104cc9:	89 04 24             	mov    %eax,(%esp)
f0104ccc:	e8 da c9 ff ff       	call   f01016ab <page_insert>
f0104cd1:	85 c0                	test   %eax,%eax
f0104cd3:	78 0f                	js     f0104ce4 <sys_page_map+0x104>
f0104cd5:	0f 22 db             	mov    %ebx,%cr3
f0104cd8:	b8 00 00 00 00       	mov    $0x0,%eax
f0104cdd:	eb 05                	jmp    f0104ce4 <sys_page_map+0x104>
		return r;
	lcr3(old_cr3);
	return 0;
f0104cdf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	//panic("sys_page_map not implemented");
}
f0104ce4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104ce7:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0104cea:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0104ced:	89 ec                	mov    %ebp,%esp
f0104cef:	5d                   	pop    %ebp
f0104cf0:	c3                   	ret    

f0104cf1 <syscall>:


// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104cf1:	55                   	push   %ebp
f0104cf2:	89 e5                	mov    %esp,%ebp
f0104cf4:	83 ec 38             	sub    $0x38,%esp
f0104cf7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104cfa:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104cfd:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104d00:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int r;
	switch(syscallno){
f0104d03:	83 f8 0d             	cmp    $0xd,%eax
f0104d06:	0f 87 c2 04 00 00    	ja     f01051ce <syscall+0x4dd>
f0104d0c:	ff 24 85 ac b5 10 f0 	jmp    *-0xfef4a54(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.
	
	// LAB 3: Your code here.
	user_mem_assert(curenv,(void*)s,len,0);
f0104d13:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104d1a:	00 
f0104d1b:	8b 45 10             	mov    0x10(%ebp),%eax
f0104d1e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104d22:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104d25:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104d29:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f0104d2e:	89 04 24             	mov    %eax,(%esp)
f0104d31:	e8 39 c8 ff ff       	call   f010156f <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104d36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104d39:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104d3d:	8b 45 10             	mov    0x10(%ebp),%eax
f0104d40:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d44:	c7 04 24 42 b5 10 f0 	movl   $0xf010b542,(%esp)
f0104d4b:	e8 87 ec ff ff       	call   f01039d7 <cprintf>
f0104d50:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104d55:	e9 95 04 00 00       	jmp    f01051ef <syscall+0x4fe>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104d5a:	e8 ae b4 ff ff       	call   f010020d <cons_getc>
f0104d5f:	89 c3                	mov    %eax,%ebx
f0104d61:	e9 89 04 00 00       	jmp    f01051ef <syscall+0x4fe>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104d66:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f0104d6b:	8b 58 4c             	mov    0x4c(%eax),%ebx
f0104d6e:	e9 7c 04 00 00       	jmp    f01051ef <syscall+0x4fe>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104d73:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104d7a:	00 
f0104d7b:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104d7e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d82:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104d85:	89 14 24             	mov    %edx,(%esp)
f0104d88:	e8 a7 e3 ff ff       	call   f0103134 <envid2env>
f0104d8d:	89 c3                	mov    %eax,%ebx
f0104d8f:	85 c0                	test   %eax,%eax
f0104d91:	0f 88 58 04 00 00    	js     f01051ef <syscall+0x4fe>
		return r;
	env_destroy(e);
f0104d97:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104d9a:	89 04 24             	mov    %eax,(%esp)
f0104d9d:	e8 54 ea ff ff       	call   f01037f6 <env_destroy>
f0104da2:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104da7:	e9 43 04 00 00       	jmp    f01051ef <syscall+0x4fe>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104dac:	e8 8b fd ff ff       	call   f0104b3c <sched_yield>
	// will appear to return 0.

	// LAB 4: Your code here.
	int r;
	struct Env *childenv;
	if((r=env_alloc(&childenv,curenv->env_id))<0)
f0104db1:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f0104db6:	8b 40 4c             	mov    0x4c(%eax),%eax
f0104db9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104dbd:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104dc0:	89 04 24             	mov    %eax,(%esp)
f0104dc3:	e8 af e4 ff ff       	call   f0103277 <env_alloc>
f0104dc8:	89 c3                	mov    %eax,%ebx
f0104dca:	85 c0                	test   %eax,%eax
f0104dcc:	79 11                	jns    f0104ddf <syscall+0xee>
	{
		cprintf("env_alloc failed\n");
f0104dce:	c7 04 24 47 b5 10 f0 	movl   $0xf010b547,(%esp)
f0104dd5:	e8 fd eb ff ff       	call   f01039d7 <cprintf>
f0104dda:	e9 10 04 00 00       	jmp    f01051ef <syscall+0x4fe>
		return r;
	}
	childenv->env_status=ENV_NOT_RUNNABLE;
f0104ddf:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104de2:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	//cprintf("curenv=%x childenv=%x\n",curenv->env_id,childenv->env_id);
	memmove(&childenv->env_tf,&curenv->env_tf,sizeof(struct Trapframe));//拷贝父进程的寄存器状态
f0104de9:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0104df0:	00 
f0104df1:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f0104df6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104dfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104dfd:	89 04 24             	mov    %eax,(%esp)
f0104e00:	e8 83 48 00 00       	call   f0109688 <memmove>
	childenv->env_tf.tf_regs.reg_eax=0;//在子进程中，返回0
f0104e05:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104e08:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
		
	return childenv->env_id;
f0104e0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104e12:	8b 58 4c             	mov    0x4c(%eax),%ebx
f0104e15:	e9 d5 03 00 00       	jmp    f01051ef <syscall+0x4fe>
	// envid's status.

	// LAB 4: Your code here.
	int r;
	struct Env *e;
	if(status>2||status<0)
f0104e1a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104e1f:	83 7d 10 02          	cmpl   $0x2,0x10(%ebp)
f0104e23:	0f 87 c6 03 00 00    	ja     f01051ef <syscall+0x4fe>
		return -E_INVAL;
	if(envid==0)
f0104e29:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104e2d:	75 0a                	jne    f0104e39 <syscall+0x148>
		e=curenv;
f0104e2f:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f0104e34:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104e37:	eb 24                	jmp    f0104e5d <syscall+0x16c>
	else
		if((r=envid2env(envid,&e,1))<0)
f0104e39:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e40:	00 
f0104e41:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104e44:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104e4b:	89 0c 24             	mov    %ecx,(%esp)
f0104e4e:	e8 e1 e2 ff ff       	call   f0103134 <envid2env>
f0104e53:	89 c3                	mov    %eax,%ebx
f0104e55:	85 c0                	test   %eax,%eax
f0104e57:	0f 88 92 03 00 00    	js     f01051ef <syscall+0x4fe>
		{
			return r;
		}
	e->env_status=status;
f0104e5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104e60:	8b 55 10             	mov    0x10(%ebp),%edx
f0104e63:	89 50 54             	mov    %edx,0x54(%eax)
f0104e66:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104e6b:	e9 7f 03 00 00       	jmp    f01051ef <syscall+0x4fe>
	int r;//检查envid的合法性
        struct Env *e;
	struct Page *pg;
	physaddr_t old_cr3;//需要切换cr3
	uint32_t *page;
	if(envid==0)
f0104e70:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104e74:	75 0a                	jne    f0104e80 <syscall+0x18f>
		e=curenv;
f0104e76:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f0104e7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104e7e:	eb 24                	jmp    f0104ea4 <syscall+0x1b3>
	else
        	if((r=envid2env(envid,&e,0))<0)
f0104e80:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104e87:	00 
f0104e88:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104e8b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104e92:	89 0c 24             	mov    %ecx,(%esp)
f0104e95:	e8 9a e2 ff ff       	call   f0103134 <envid2env>
f0104e9a:	89 c3                	mov    %eax,%ebx
f0104e9c:	85 c0                	test   %eax,%eax
f0104e9e:	0f 88 4b 03 00 00    	js     f01051ef <syscall+0x4fe>
			break;
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1,(int)a2);
			break;
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
f0104ea4:	8b 75 10             	mov    0x10(%ebp),%esi
	else
        	if((r=envid2env(envid,&e,0))<0)
        	{
                	return r;
        	}
	if((uint32_t)va>=UTOP||((uint32_t)va&0xfff))
f0104ea7:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104ead:	0f 87 e3 00 00 00    	ja     f0104f96 <syscall+0x2a5>
f0104eb3:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0104eb9:	0f 85 d7 00 00 00    	jne    f0104f96 <syscall+0x2a5>
			break;
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1,(int)a2);
			break;
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
f0104ebf:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ec2:	89 45 e0             	mov    %eax,-0x20(%ebp)
        	{
                	return r;
        	}
	if((uint32_t)va>=UTOP||((uint32_t)va&0xfff))
		return -E_INVAL;
	if(perm&(~PTE_USER))
f0104ec5:	a9 f8 f1 ff ff       	test   $0xfffff1f8,%eax
f0104eca:	0f 85 c6 00 00 00    	jne    f0104f96 <syscall+0x2a5>
		return -E_INVAL;
	if((r=page_alloc(&pg))<0)
f0104ed0:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104ed3:	89 04 24             	mov    %eax,(%esp)
f0104ed6:	e8 ab c3 ff ff       	call   f0101286 <page_alloc>
f0104edb:	89 c3                	mov    %eax,%ebx
f0104edd:	85 c0                	test   %eax,%eax
f0104edf:	0f 88 0a 03 00 00    	js     f01051ef <syscall+0x4fe>
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0104ee5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104ee8:	2b 05 6c a5 1b f0    	sub    0xf01ba56c,%eax
f0104eee:	c1 f8 02             	sar    $0x2,%eax
f0104ef1:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104ef7:	89 c2                	mov    %eax,%edx
f0104ef9:	c1 e2 0c             	shl    $0xc,%edx
		return r;
	page = (uint32_t*)KADDR(page2pa(pg));
f0104efc:	89 d0                	mov    %edx,%eax
f0104efe:	c1 e8 0c             	shr    $0xc,%eax
f0104f01:	3b 05 60 a5 1b f0    	cmp    0xf01ba560,%eax
f0104f07:	72 20                	jb     f0104f29 <syscall+0x238>
f0104f09:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104f0d:	c7 44 24 08 88 a4 10 	movl   $0xf010a488,0x8(%esp)
f0104f14:	f0 
f0104f15:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
f0104f1c:	00 
f0104f1d:	c7 04 24 59 b5 10 f0 	movl   $0xf010b559,(%esp)
f0104f24:	e8 5d b1 ff ff       	call   f0100086 <_panic>
		//计算物理页面的虚拟起始地址，pg是页面管理结构节点指针
	memset(page,0,PGSIZE);
f0104f29:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0104f30:	00 
f0104f31:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0104f38:	00 
		return -E_INVAL;
	if(perm&(~PTE_USER))
		return -E_INVAL;
	if((r=page_alloc(&pg))<0)
		return r;
	page = (uint32_t*)KADDR(page2pa(pg));
f0104f39:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0104f3f:	89 04 24             	mov    %eax,(%esp)
f0104f42:	e8 e7 46 00 00       	call   f010962e <memset>

static __inline uint32_t
rcr3(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr3,%0" : "=r" (val));
f0104f47:	0f 20 df             	mov    %cr3,%edi
		//计算物理页面的虚拟起始地址，pg是页面管理结构节点指针
	memset(page,0,PGSIZE);
	old_cr3=rcr3();
	lcr3(e->env_cr3);
f0104f4a:	8b 55 f0             	mov    -0x10(%ebp),%edx
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104f4d:	8b 42 60             	mov    0x60(%edx),%eax
f0104f50:	0f 22 d8             	mov    %eax,%cr3
	if((r=page_insert(e->env_pgdir,pg,va,perm))<0)
f0104f53:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104f56:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104f5a:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104f5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104f61:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f65:	8b 42 5c             	mov    0x5c(%edx),%eax
f0104f68:	89 04 24             	mov    %eax,(%esp)
f0104f6b:	e8 3b c7 ff ff       	call   f01016ab <page_insert>
f0104f70:	89 c3                	mov    %eax,%ebx
f0104f72:	85 c0                	test   %eax,%eax
f0104f74:	79 13                	jns    f0104f89 <syscall+0x298>
	{
		page_free(pg);
f0104f76:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104f79:	89 04 24             	mov    %eax,(%esp)
f0104f7c:	e8 d7 c0 ff ff       	call   f0101058 <page_free>
f0104f81:	0f 22 df             	mov    %edi,%cr3
f0104f84:	e9 66 02 00 00       	jmp    f01051ef <syscall+0x4fe>
f0104f89:	0f 22 df             	mov    %edi,%cr3
f0104f8c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104f91:	e9 59 02 00 00       	jmp    f01051ef <syscall+0x4fe>
f0104f96:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104f9b:	e9 4f 02 00 00       	jmp    f01051ef <syscall+0x4fe>
			break;
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
			break;
		case SYS_page_map:
			return sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,(int)a5);
f0104fa0:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104fa3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104fa7:	8b 55 18             	mov    0x18(%ebp),%edx
f0104faa:	89 14 24             	mov    %edx,(%esp)
f0104fad:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0104fb0:	8b 55 10             	mov    0x10(%ebp),%edx
f0104fb3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104fb6:	e8 25 fc ff ff       	call   f0104be0 <sys_page_map>
f0104fbb:	89 c3                	mov    %eax,%ebx
f0104fbd:	e9 2d 02 00 00       	jmp    f01051ef <syscall+0x4fe>

	// LAB 4: Your code here.
	int r;
	struct Env *e;
	physaddr_t old_cr3;
	if(envid==0)
f0104fc2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104fc6:	75 0a                	jne    f0104fd2 <syscall+0x2e1>
		e=curenv;
f0104fc8:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f0104fcd:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104fd0:	eb 24                	jmp    f0104ff6 <syscall+0x305>
	else
		if((r=envid2env(envid,&e,0))<0)
f0104fd2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104fd9:	00 
f0104fda:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104fdd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104fe1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104fe4:	89 0c 24             	mov    %ecx,(%esp)
f0104fe7:	e8 48 e1 ff ff       	call   f0103134 <envid2env>
f0104fec:	89 c3                	mov    %eax,%ebx
f0104fee:	85 c0                	test   %eax,%eax
f0104ff0:	0f 88 f9 01 00 00    	js     f01051ef <syscall+0x4fe>
        	{
                	return r;
        	}
        if((uint32_t)va>=UTOP||((uint32_t)va&0xfff))
f0104ff6:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104ffd:	77 34                	ja     f0105033 <syscall+0x342>
f0104fff:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0105006:	75 2b                	jne    f0105033 <syscall+0x342>

static __inline uint32_t
rcr3(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr3,%0" : "=r" (val));
f0105008:	0f 20 db             	mov    %cr3,%ebx
                return -E_INVAL;
	old_cr3=rcr3();
	lcr3(e->env_cr3);
f010500b:	8b 55 ec             	mov    -0x14(%ebp),%edx
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010500e:	8b 42 60             	mov    0x60(%edx),%eax
f0105011:	0f 22 d8             	mov    %eax,%cr3
	page_remove(e->env_pgdir,va);
f0105014:	8b 45 10             	mov    0x10(%ebp),%eax
f0105017:	89 44 24 04          	mov    %eax,0x4(%esp)
f010501b:	8b 42 5c             	mov    0x5c(%edx),%eax
f010501e:	89 04 24             	mov    %eax,(%esp)
f0105021:	e8 a1 c5 ff ff       	call   f01015c7 <page_remove>
f0105026:	0f 22 db             	mov    %ebx,%cr3
f0105029:	bb 00 00 00 00       	mov    $0x0,%ebx
f010502e:	e9 bc 01 00 00       	jmp    f01051ef <syscall+0x4fe>
f0105033:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105038:	e9 b2 01 00 00       	jmp    f01051ef <syscall+0x4fe>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	int r;
	struct Env *e;
	if(envid==0)
f010503d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105041:	75 0a                	jne    f010504d <syscall+0x35c>
		e=curenv;
f0105043:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f0105048:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010504b:	eb 24                	jmp    f0105071 <syscall+0x380>
	else
		if((r=envid2env(envid,&e,0))<0)
f010504d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0105054:	00 
f0105055:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105058:	89 44 24 04          	mov    %eax,0x4(%esp)
f010505c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010505f:	89 14 24             	mov    %edx,(%esp)
f0105062:	e8 cd e0 ff ff       	call   f0103134 <envid2env>
f0105067:	89 c3                	mov    %eax,%ebx
f0105069:	85 c0                	test   %eax,%eax
f010506b:	0f 88 7e 01 00 00    	js     f01051ef <syscall+0x4fe>
			return r;
	e->env_pgfault_upcall=func;
f0105071:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105074:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105077:	89 48 64             	mov    %ecx,0x64(%eax)
f010507a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010507f:	e9 6b 01 00 00       	jmp    f01051ef <syscall+0x4fe>
			break;
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1,(void*)a2);
			break;
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1,(uint32_t)a2,(void*)a3,(unsigned)a4);
f0105084:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct Env *e;
	struct Page *pg;
	pte_t *pte;
	uint32_t srcaddr=0;
	//cprintf("sys_ipc_try_send:here envid=%x\n",envid);
	if((envid==0)||(envid==curenv->env_id))
f0105087:	85 ff                	test   %edi,%edi
f0105089:	74 0a                	je     f0105095 <syscall+0x3a4>
f010508b:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f0105090:	3b 78 4c             	cmp    0x4c(%eax),%edi
f0105093:	75 22                	jne    f01050b7 <syscall+0x3c6>
	{
		cprintf("the same send:envid=%x\n",curenv->env_id);
f0105095:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f010509a:	8b 40 4c             	mov    0x4c(%eax),%eax
f010509d:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050a1:	c7 04 24 68 b5 10 f0 	movl   $0xf010b568,(%esp)
f01050a8:	e8 2a e9 ff ff       	call   f01039d7 <cprintf>
		e=curenv;
f01050ad:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f01050b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01050b5:	eb 32                	jmp    f01050e9 <syscall+0x3f8>
	}
	else
		if((r=envid2env(envid,&e,0))<0)
f01050b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01050be:	00 
f01050bf:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01050c2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050c6:	89 3c 24             	mov    %edi,(%esp)
f01050c9:	e8 66 e0 ff ff       	call   f0103134 <envid2env>
f01050ce:	89 c3                	mov    %eax,%ebx
f01050d0:	85 c0                	test   %eax,%eax
f01050d2:	79 15                	jns    f01050e9 <syscall+0x3f8>
		{
			cprintf("envid2env:id=%x\n",envid);
f01050d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01050d8:	c7 04 24 80 b5 10 f0 	movl   $0xf010b580,(%esp)
f01050df:	e8 f3 e8 ff ff       	call   f01039d7 <cprintf>
f01050e4:	e9 06 01 00 00       	jmp    f01051ef <syscall+0x4fe>
			return r;
		}
	//cprintf("panduan:env_ipc_recving\n");
	if(!e->env_ipc_recving)
f01050e9:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01050ec:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f01050f1:	83 7a 68 00          	cmpl   $0x0,0x68(%edx)
f01050f5:	0f 84 f4 00 00 00    	je     f01051ef <syscall+0x4fe>
		return -E_IPC_NOT_RECV;
	//cprintf("panduan is over\n");
	if(srcva){
f01050fb:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
f01050ff:	90                   	nop    
f0105100:	75 09                	jne    f010510b <syscall+0x41a>
f0105102:	c7 45 18 00 00 00 00 	movl   $0x0,0x18(%ebp)
f0105109:	eb 44                	jmp    f010514f <syscall+0x45e>
			break;
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1,(void*)a2);
			break;
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1,(uint32_t)a2,(void*)a3,(unsigned)a4);
f010510b:	8b 75 14             	mov    0x14(%ebp),%esi
	if(!e->env_ipc_recving)
		return -E_IPC_NOT_RECV;
	//cprintf("panduan is over\n");
	if(srcva){
		srcaddr=(uint32_t)srcva;
		if(srcaddr<(uint32_t)UTOP){
f010510e:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0105114:	77 39                	ja     f010514f <syscall+0x45e>
			if(srcaddr&0xfff)
f0105116:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010511b:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0105121:	0f 85 c8 00 00 00    	jne    f01051ef <syscall+0x4fe>
				return -E_INVAL;
			//cprintf("ipc send:some bugs in page mapping\n");
			//cprintf("srcid=%x srcva=%x\n",curenv->env_id,srcva);
			//cprintf("dstid=%x dstva=%x\n",envid,e->env_ipc_dstva);
			if((r=sys_page_map(curenv->env_id,srcva,envid,e->env_ipc_dstva,perm))<0)
f0105127:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f010512c:	8b 40 4c             	mov    0x4c(%eax),%eax
f010512f:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105132:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105136:	8b 52 6c             	mov    0x6c(%edx),%edx
f0105139:	89 14 24             	mov    %edx,(%esp)
f010513c:	89 f9                	mov    %edi,%ecx
f010513e:	89 f2                	mov    %esi,%edx
f0105140:	e8 9b fa ff ff       	call   f0104be0 <sys_page_map>
f0105145:	89 c3                	mov    %eax,%ebx
f0105147:	85 c0                	test   %eax,%eax
f0105149:	0f 88 a0 00 00 00    	js     f01051ef <syscall+0x4fe>
				return r;
			//cprintf("ipc send:no bugs in page mapping\n");
		}
	}
	else perm=0;
	e->env_ipc_from=curenv->env_id;
f010514f:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f0105154:	8b 50 4c             	mov    0x4c(%eax),%edx
f0105157:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010515a:	89 50 74             	mov    %edx,0x74(%eax)
	e->env_ipc_perm=perm;
f010515d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105160:	8b 55 18             	mov    0x18(%ebp),%edx
f0105163:	89 50 78             	mov    %edx,0x78(%eax)
	e->env_ipc_value=value;
f0105166:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105169:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010516c:	89 48 70             	mov    %ecx,0x70(%eax)
	e->env_ipc_recving=0;
f010516f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105172:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)
	e->env_status=ENV_RUNNABLE;
f0105179:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010517c:	c7 40 54 01 00 00 00 	movl   $0x1,0x54(%eax)
f0105183:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105188:	eb 65                	jmp    f01051ef <syscall+0x4fe>
			break;
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1,(uint32_t)a2,(void*)a3,(unsigned)a4);
			break;
		case SYS_ipc_recv:
			return sys_ipc_recv((void*)a1);
f010518a:	8b 55 0c             	mov    0xc(%ebp),%edx
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	uint32_t dstaddr;
	dstaddr=(uint32_t)dstva;
	if((dstaddr<(uint32_t)UTOP)&&(dstaddr&0xfff))
f010518d:	81 fa ff ff bf ee    	cmp    $0xeebfffff,%edx
f0105193:	77 08                	ja     f010519d <syscall+0x4ac>
f0105195:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f010519b:	75 4d                	jne    f01051ea <syscall+0x4f9>
		return -E_INVAL;
	curenv->env_ipc_dstva=dstva;
f010519d:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f01051a2:	89 50 6c             	mov    %edx,0x6c(%eax)
	curenv->env_ipc_recving=1;
f01051a5:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f01051aa:	c7 40 68 01 00 00 00 	movl   $0x1,0x68(%eax)
	curenv->env_tf.tf_regs.reg_eax=0;//设置返回值，jos都是利用evn_run从内核态返回用户态
f01051b1:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f01051b6:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	curenv->env_status=ENV_NOT_RUNNABLE;
f01051bd:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f01051c2:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	sched_yield();
f01051c9:	e8 6e f9 ff ff       	call   f0104b3c <sched_yield>
			break;
		case SYS_ipc_recv:
			return sys_ipc_recv((void*)a1);
			break;
		default:
			panic("syscall is not implemented");
f01051ce:	c7 44 24 08 91 b5 10 	movl   $0xf010b591,0x8(%esp)
f01051d5:	f0 
f01051d6:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
f01051dd:	00 
f01051de:	c7 04 24 59 b5 10 f0 	movl   $0xf010b559,(%esp)
f01051e5:	e8 9c ae ff ff       	call   f0100086 <_panic>
f01051ea:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	}
	return 0;
	//panic("syscall not implemented");
}
f01051ef:	89 d8                	mov    %ebx,%eax
f01051f1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01051f4:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01051f7:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01051fa:	89 ec                	mov    %ebp,%esp
f01051fc:	5d                   	pop    %ebp
f01051fd:	c3                   	ret    
	...

f0105200 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0105200:	55                   	push   %ebp
f0105201:	89 e5                	mov    %esp,%ebp
f0105203:	57                   	push   %edi
f0105204:	56                   	push   %esi
f0105205:	53                   	push   %ebx
f0105206:	83 ec 14             	sub    $0x14,%esp
f0105209:	89 45 e8             	mov    %eax,-0x18(%ebp)
f010520c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010520f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105212:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105215:	8b 1a                	mov    (%edx),%ebx
f0105217:	8b 01                	mov    (%ecx),%eax
f0105219:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f010521c:	39 c3                	cmp    %eax,%ebx
f010521e:	0f 8f aa 00 00 00    	jg     f01052ce <stab_binsearch+0xce>
f0105224:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f010522b:	8b 55 ec             	mov    -0x14(%ebp),%edx
f010522e:	01 da                	add    %ebx,%edx
f0105230:	89 d0                	mov    %edx,%eax
f0105232:	c1 e8 1f             	shr    $0x1f,%eax
f0105235:	01 d0                	add    %edx,%eax
f0105237:	89 c6                	mov    %eax,%esi
f0105239:	d1 fe                	sar    %esi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010523b:	39 de                	cmp    %ebx,%esi
f010523d:	7c 2e                	jl     f010526d <stab_binsearch+0x6d>
f010523f:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0105242:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0105249:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f010524c:	0f b6 44 0a 04       	movzbl 0x4(%edx,%ecx,1),%eax
f0105251:	39 f8                	cmp    %edi,%eax
f0105253:	74 1d                	je     f0105272 <stab_binsearch+0x72>
f0105255:	01 ca                	add    %ecx,%edx
f0105257:	89 f1                	mov    %esi,%ecx
			m--;
f0105259:	83 e9 01             	sub    $0x1,%ecx
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010525c:	39 d9                	cmp    %ebx,%ecx
f010525e:	7c 0d                	jl     f010526d <stab_binsearch+0x6d>
f0105260:	0f b6 42 f8          	movzbl -0x8(%edx),%eax
f0105264:	83 ea 0c             	sub    $0xc,%edx
f0105267:	39 f8                	cmp    %edi,%eax
f0105269:	74 09                	je     f0105274 <stab_binsearch+0x74>
f010526b:	eb ec                	jmp    f0105259 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010526d:	8d 5e 01             	lea    0x1(%esi),%ebx
f0105270:	eb 4d                	jmp    f01052bf <stab_binsearch+0xbf>
			continue;
f0105272:	89 f1                	mov    %esi,%ecx
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105274:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0105277:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010527a:	8b 44 82 08          	mov    0x8(%edx,%eax,4),%eax
f010527e:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0105281:	73 11                	jae    f0105294 <stab_binsearch+0x94>
			*region_left = m;
f0105283:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105286:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
f0105288:	8d 5e 01             	lea    0x1(%esi),%ebx
f010528b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
f0105292:	eb 2b                	jmp    f01052bf <stab_binsearch+0xbf>
		} else if (stabs[m].n_value > addr) {
f0105294:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0105297:	76 14                	jbe    f01052ad <stab_binsearch+0xad>
			*region_right = m - 1;
f0105299:	83 e9 01             	sub    $0x1,%ecx
f010529c:	89 4d ec             	mov    %ecx,-0x14(%ebp)
f010529f:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01052a2:	89 0a                	mov    %ecx,(%edx)
f01052a4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
f01052ab:	eb 12                	jmp    f01052bf <stab_binsearch+0xbf>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01052ad:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01052b0:	89 0e                	mov    %ecx,(%esi)
			l = m;
			addr++;
f01052b2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01052b6:	89 cb                	mov    %ecx,%ebx
f01052b8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f01052bf:	3b 5d ec             	cmp    -0x14(%ebp),%ebx
f01052c2:	0f 8e 63 ff ff ff    	jle    f010522b <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01052c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f01052cc:	75 0f                	jne    f01052dd <stab_binsearch+0xdd>
		*region_right = *region_left - 1;
f01052ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01052d1:	8b 02                	mov    (%edx),%eax
f01052d3:	83 e8 01             	sub    $0x1,%eax
f01052d6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01052d9:	89 01                	mov    %eax,(%ecx)
f01052db:	eb 3d                	jmp    f010531a <stab_binsearch+0x11a>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01052dd:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01052e0:	8b 0e                	mov    (%esi),%ecx
		     l > *region_left && stabs[l].n_type != type;
f01052e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01052e5:	8b 18                	mov    (%eax),%ebx
f01052e7:	39 d9                	cmp    %ebx,%ecx
f01052e9:	7e 2a                	jle    f0105315 <stab_binsearch+0x115>
f01052eb:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f01052ee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01052f5:	8b 75 e8             	mov    -0x18(%ebp),%esi
f01052f8:	0f b6 44 32 04       	movzbl 0x4(%edx,%esi,1),%eax
f01052fd:	39 f8                	cmp    %edi,%eax
f01052ff:	74 14                	je     f0105315 <stab_binsearch+0x115>
f0105301:	01 f2                	add    %esi,%edx
		     l--)
f0105303:	83 e9 01             	sub    $0x1,%ecx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0105306:	39 d9                	cmp    %ebx,%ecx
f0105308:	7e 0b                	jle    f0105315 <stab_binsearch+0x115>
f010530a:	0f b6 42 f8          	movzbl -0x8(%edx),%eax
f010530e:	83 ea 0c             	sub    $0xc,%edx
f0105311:	39 f8                	cmp    %edi,%eax
f0105313:	75 ee                	jne    f0105303 <stab_binsearch+0x103>
		     l--)
			/* do nothing */;
		*region_left = l;
f0105315:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105318:	89 08                	mov    %ecx,(%eax)
	}
}
f010531a:	83 c4 14             	add    $0x14,%esp
f010531d:	5b                   	pop    %ebx
f010531e:	5e                   	pop    %esi
f010531f:	5f                   	pop    %edi
f0105320:	5d                   	pop    %ebp
f0105321:	c3                   	ret    

f0105322 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105322:	55                   	push   %ebp
f0105323:	89 e5                	mov    %esp,%ebp
f0105325:	83 ec 48             	sub    $0x48,%esp
f0105328:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010532b:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010532e:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0105331:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105334:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105337:	c7 06 e4 b5 10 f0    	movl   $0xf010b5e4,(%esi)
	info->eip_line = 0;
f010533d:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0105344:	c7 46 08 e4 b5 10 f0 	movl   $0xf010b5e4,0x8(%esi)
	info->eip_fn_namelen = 9;
f010534b:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0105352:	89 5e 10             	mov    %ebx,0x10(%esi)
	info->eip_fn_narg = 0;
f0105355:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010535c:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0105362:	76 1f                	jbe    f0105383 <debuginfo_eip+0x61>
f0105364:	c7 45 c8 b0 3d 11 f0 	movl   $0xf0113db0,-0x38(%ebp)
f010536b:	bf 6c 14 12 f0       	mov    $0xf012146c,%edi
f0105370:	c7 45 cc 6d 14 12 f0 	movl   $0xf012146d,-0x34(%ebp)
f0105377:	c7 45 d0 74 5e 12 f0 	movl   $0xf0125e74,-0x30(%ebp)
f010537e:	e9 99 00 00 00       	jmp    f010541c <debuginfo_eip+0xfa>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		user_mem_check(curenv,(void*)usd,sizeof(struct UserStabData),0);
f0105383:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010538a:	00 
f010538b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0105392:	00 
f0105393:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f010539a:	00 
f010539b:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f01053a0:	89 04 24             	mov    %eax,(%esp)
f01053a3:	e8 e8 c0 ff ff       	call   f0101490 <user_mem_check>
		stabs = usd->stabs;
f01053a8:	a1 00 00 20 00       	mov    0x200000,%eax
f01053ad:	89 45 c8             	mov    %eax,-0x38(%ebp)
		stab_end = usd->stab_end;
f01053b0:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f01053b6:	8b 15 08 00 20 00    	mov    0x200008,%edx
f01053bc:	89 55 cc             	mov    %edx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f01053bf:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f01053c5:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		user_mem_check(curenv,(void*)stabs,stab_end-stabs,0);
f01053c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01053cf:	00 
f01053d0:	89 f8                	mov    %edi,%eax
f01053d2:	2b 45 c8             	sub    -0x38(%ebp),%eax
f01053d5:	c1 f8 02             	sar    $0x2,%eax
f01053d8:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01053de:	89 44 24 08          	mov    %eax,0x8(%esp)
f01053e2:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01053e5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053e9:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f01053ee:	89 04 24             	mov    %eax,(%esp)
f01053f1:	e8 9a c0 ff ff       	call   f0101490 <user_mem_check>
		user_mem_check(curenv,(void*)stabstr,stabstr_end-stabstr,0);
f01053f6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01053fd:	00 
f01053fe:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105401:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0105404:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105408:	8b 55 cc             	mov    -0x34(%ebp),%edx
f010540b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010540f:	a1 c4 95 1b f0       	mov    0xf01b95c4,%eax
f0105414:	89 04 24             	mov    %eax,(%esp)
f0105417:	e8 74 c0 ff ff       	call   f0101490 <user_mem_check>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010541c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010541f:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f0105422:	0f 83 aa 01 00 00    	jae    f01055d2 <debuginfo_eip+0x2b0>
f0105428:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f010542c:	0f 85 a0 01 00 00    	jne    f01055d2 <debuginfo_eip+0x2b0>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105432:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105439:	89 f8                	mov    %edi,%eax
f010543b:	2b 45 c8             	sub    -0x38(%ebp),%eax
f010543e:	c1 f8 02             	sar    $0x2,%eax
f0105441:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0105447:	83 e8 01             	sub    $0x1,%eax
f010544a:	89 45 ec             	mov    %eax,-0x14(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010544d:	8d 4d ec             	lea    -0x14(%ebp),%ecx
f0105450:	8d 55 f0             	lea    -0x10(%ebp),%edx
f0105453:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105457:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f010545e:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0105461:	e8 9a fd ff ff       	call   f0105200 <stab_binsearch>
	if (lfile == 0)
f0105466:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105469:	85 c0                	test   %eax,%eax
f010546b:	0f 84 61 01 00 00    	je     f01055d2 <debuginfo_eip+0x2b0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105471:	89 45 e8             	mov    %eax,-0x18(%ebp)
	rfun = rfile;
f0105474:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105477:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010547a:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
f010547d:	8d 55 e8             	lea    -0x18(%ebp),%edx
f0105480:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105484:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f010548b:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010548e:	e8 6d fd ff ff       	call   f0105200 <stab_binsearch>

	if (lfun <= rfun) {
f0105493:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0105496:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
f0105499:	7f 39                	jg     f01054d4 <debuginfo_eip+0x1b2>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010549b:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010549e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01054a1:	8b 14 81             	mov    (%ecx,%eax,4),%edx
f01054a4:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01054a7:	2b 45 cc             	sub    -0x34(%ebp),%eax
f01054aa:	39 c2                	cmp    %eax,%edx
f01054ac:	73 09                	jae    f01054b7 <debuginfo_eip+0x195>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01054ae:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01054b1:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
f01054b4:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f01054b7:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01054ba:	8d 04 52             	lea    (%edx,%edx,2),%eax
f01054bd:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01054c0:	8b 44 81 08          	mov    0x8(%ecx,%eax,4),%eax
f01054c4:	89 46 10             	mov    %eax,0x10(%esi)
		addr -= info->eip_fn_addr;
f01054c7:	29 c3                	sub    %eax,%ebx
		// Search within the function definition for the line number.
		lline = lfun;
f01054c9:	89 55 e0             	mov    %edx,-0x20(%ebp)
		rline = rfun;
f01054cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054cf:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01054d2:	eb 0f                	jmp    f01054e3 <debuginfo_eip+0x1c1>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01054d4:	89 5e 10             	mov    %ebx,0x10(%esi)
		lline = lfile;
f01054d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01054da:	89 45 e0             	mov    %eax,-0x20(%ebp)
		rline = rfile;
f01054dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01054e0:	89 45 dc             	mov    %eax,-0x24(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01054e3:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01054ea:	00 
f01054eb:	8b 46 08             	mov    0x8(%esi),%eax
f01054ee:	89 04 24             	mov    %eax,(%esp)
f01054f1:	e8 0d 41 00 00       	call   f0109603 <strfind>
f01054f6:	2b 46 08             	sub    0x8(%esi),%eax
f01054f9:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs,&lline,&rline,N_SLINE,addr);
f01054fc:	8d 4d dc             	lea    -0x24(%ebp),%ecx
f01054ff:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0105502:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105506:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f010550d:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0105510:	e8 eb fc ff ff       	call   f0105200 <stab_binsearch>
	if(lline==0)
f0105515:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105518:	85 d2                	test   %edx,%edx
f010551a:	0f 84 b2 00 00 00    	je     f01055d2 <debuginfo_eip+0x2b0>
		return -1;
	info->eip_line=stabs[lline].n_desc;
f0105520:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0105523:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
f010552a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010552d:	0f b7 44 0b 06       	movzwl 0x6(%ebx,%ecx,1),%eax
f0105532:	89 46 04             	mov    %eax,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105535:	89 d1                	mov    %edx,%ecx
f0105537:	8b 7d f0             	mov    -0x10(%ebp),%edi
f010553a:	39 d7                	cmp    %edx,%edi
f010553c:	7f 52                	jg     f0105590 <debuginfo_eip+0x26e>
f010553e:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0105541:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f0105544:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0105548:	8d 58 f4             	lea    -0xc(%eax),%ebx
f010554b:	80 fa 84             	cmp    $0x84,%dl
f010554e:	75 1a                	jne    f010556a <debuginfo_eip+0x248>
f0105550:	eb 23                	jmp    f0105575 <debuginfo_eip+0x253>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0105552:	83 e9 01             	sub    $0x1,%ecx
f0105555:	89 4d e0             	mov    %ecx,-0x20(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105558:	39 cf                	cmp    %ecx,%edi
f010555a:	7f 34                	jg     f0105590 <debuginfo_eip+0x26e>
f010555c:	89 d8                	mov    %ebx,%eax
f010555e:	0f b6 53 04          	movzbl 0x4(%ebx),%edx
f0105562:	8d 5b f4             	lea    -0xc(%ebx),%ebx
f0105565:	80 fa 84             	cmp    $0x84,%dl
f0105568:	74 0b                	je     f0105575 <debuginfo_eip+0x253>
f010556a:	80 fa 64             	cmp    $0x64,%dl
f010556d:	75 e3                	jne    f0105552 <debuginfo_eip+0x230>
f010556f:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0105573:	74 dd                	je     f0105552 <debuginfo_eip+0x230>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105575:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0105578:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010557b:	8b 14 81             	mov    (%ecx,%eax,4),%edx
f010557e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105581:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0105584:	39 c2                	cmp    %eax,%edx
f0105586:	73 08                	jae    f0105590 <debuginfo_eip+0x26e>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105588:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010558b:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
f010558e:	89 06                	mov    %eax,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105590:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0105593:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105596:	39 d0                	cmp    %edx,%eax
f0105598:	7d 3f                	jge    f01055d9 <debuginfo_eip+0x2b7>
		for (lline = lfun + 1;
f010559a:	83 c0 01             	add    $0x1,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010559d:	39 c2                	cmp    %eax,%edx
f010559f:	7e 38                	jle    f01055d9 <debuginfo_eip+0x2b7>


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01055a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01055a4:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01055a7:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01055aa:	80 7c 82 04 a0       	cmpb   $0xa0,0x4(%edx,%eax,4)
f01055af:	75 28                	jne    f01055d9 <debuginfo_eip+0x2b7>
		     lline++)
			info->eip_fn_narg++;
f01055b1:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f01055b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01055b8:	83 c0 01             	add    $0x1,%eax

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01055bb:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f01055be:	7e 19                	jle    f01055d9 <debuginfo_eip+0x2b7>
		     lline++)
f01055c0:	89 45 e0             	mov    %eax,-0x20(%ebp)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01055c3:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01055c6:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01055c9:	80 7c 81 04 a0       	cmpb   $0xa0,0x4(%ecx,%eax,4)
f01055ce:	75 09                	jne    f01055d9 <debuginfo_eip+0x2b7>
f01055d0:	eb df                	jmp    f01055b1 <debuginfo_eip+0x28f>
f01055d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01055d7:	eb 05                	jmp    f01055de <debuginfo_eip+0x2bc>
f01055d9:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
}
f01055de:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01055e1:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01055e4:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01055e7:	89 ec                	mov    %ebp,%esp
f01055e9:	5d                   	pop    %ebp
f01055ea:	c3                   	ret    
f01055eb:	00 00                	add    %al,(%eax)
f01055ed:	00 00                	add    %al,(%eax)
	...

f01055f0 <fetch_data>:

static int
fetch_data (info, addr)
     struct disassemble_info *info;
     bfd_byte *addr;
{
f01055f0:	55                   	push   %ebp
f01055f1:	89 e5                	mov    %esp,%ebp
f01055f3:	83 ec 38             	sub    $0x38,%esp
f01055f6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01055f9:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01055fc:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01055ff:	89 c6                	mov    %eax,%esi
f0105601:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  int status;
  struct dis_private *priv = (struct dis_private *) info->private_data;
f0105604:	8b 58 20             	mov    0x20(%eax),%ebx
  bfd_vma start_vma = priv->insn_start + (priv->max_fetched - priv->the_buffer);
f0105607:	8b 03                	mov    (%ebx),%eax
f0105609:	8d 7b 04             	lea    0x4(%ebx),%edi
f010560c:	89 c2                	mov    %eax,%edx
f010560e:	29 fa                	sub    %edi,%edx
f0105610:	89 d1                	mov    %edx,%ecx
f0105612:	c1 f9 1f             	sar    $0x1f,%ecx
f0105615:	03 53 18             	add    0x18(%ebx),%edx
f0105618:	13 4b 1c             	adc    0x1c(%ebx),%ecx
f010561b:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010561e:	89 4d ec             	mov    %ecx,-0x14(%ebp)
 //cprintf("fetch_data:info=%x max_fetched=%x length=%d\n",info,priv->max_fetched,addr-priv->max_fetched);
  status = (*info->read_memory_func)(start_vma,priv->max_fetched,addr-priv->max_fetched,info);
f0105621:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105625:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105628:	29 c2                	sub    %eax,%edx
f010562a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010562e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105632:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0105635:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0105638:	89 04 24             	mov    %eax,(%esp)
f010563b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010563f:	ff 56 24             	call   *0x24(%esi)
  if (status != 0)
f0105642:	85 c0                	test   %eax,%eax
f0105644:	74 1e                	je     f0105664 <fetch_data+0x74>
    {
      /* If we did manage to read at least one byte, then
         print_insn_i386 will do something sensible.  Otherwise, print
         an error.  We do that here because this is where we know
         STATUS.  */
      if (priv->max_fetched == priv->the_buffer)
f0105646:	39 3b                	cmp    %edi,(%ebx)
f0105648:	75 1f                	jne    f0105669 <fetch_data+0x79>
	(*info->memory_error_func) (status, start_vma, info);
f010564a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010564e:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105651:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105654:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105658:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010565c:	89 04 24             	mov    %eax,(%esp)
f010565f:	ff 56 28             	call   *0x28(%esi)
f0105662:	eb 05                	jmp    f0105669 <fetch_data+0x79>
      //longjmp (priv->bailout, 1);
    }
  else
    priv->max_fetched = addr;
f0105664:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105667:	89 0b                	mov    %ecx,(%ebx)
  return 1;
}
f0105669:	b8 01 00 00 00       	mov    $0x1,%eax
f010566e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0105671:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0105674:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0105677:	89 ec                	mov    %ebp,%esp
f0105679:	5d                   	pop    %ebp
f010567a:	c3                   	ret    

f010567b <prefix_name>:

static const char *
prefix_name (pref, sizeflag)
     int pref;
     int sizeflag;
{
f010567b:	55                   	push   %ebp
f010567c:	89 e5                	mov    %esp,%ebp
  switch (pref)
f010567e:	83 e8 26             	sub    $0x26,%eax
f0105681:	3d cd 00 00 00       	cmp    $0xcd,%eax
f0105686:	77 11                	ja     f0105699 <prefix_name+0x1e>
f0105688:	ff 24 85 00 c9 10 f0 	jmp    *-0xfef3700(,%eax,4)
f010568f:	b8 ee b5 10 f0       	mov    $0xf010b5ee,%eax
f0105694:	e9 22 01 00 00       	jmp    f01057bb <prefix_name+0x140>
f0105699:	b8 00 00 00 00       	mov    $0x0,%eax
f010569e:	66 90                	xchg   %ax,%ax
f01056a0:	e9 16 01 00 00       	jmp    f01057bb <prefix_name+0x140>
f01056a5:	b8 f4 b5 10 f0       	mov    $0xf010b5f4,%eax
f01056aa:	e9 0c 01 00 00       	jmp    f01057bb <prefix_name+0x140>
    {
    /* REX prefixes family.  */
    case 0x40:
      return "rex";
f01056af:	b8 f8 b5 10 f0       	mov    $0xf010b5f8,%eax
f01056b4:	e9 02 01 00 00       	jmp    f01057bb <prefix_name+0x140>
    case 0x41:
      return "rexZ";
f01056b9:	b8 fd b5 10 f0       	mov    $0xf010b5fd,%eax
f01056be:	e9 f8 00 00 00       	jmp    f01057bb <prefix_name+0x140>
    case 0x42:
      return "rexY";
f01056c3:	b8 02 b6 10 f0       	mov    $0xf010b602,%eax
f01056c8:	e9 ee 00 00 00       	jmp    f01057bb <prefix_name+0x140>
    case 0x43:
      return "rexYZ";
f01056cd:	b8 08 b6 10 f0       	mov    $0xf010b608,%eax
f01056d2:	e9 e4 00 00 00       	jmp    f01057bb <prefix_name+0x140>
    case 0x44:
      return "rexX";
f01056d7:	b8 0d b6 10 f0       	mov    $0xf010b60d,%eax
f01056dc:	e9 da 00 00 00       	jmp    f01057bb <prefix_name+0x140>
    case 0x45:
      return "rexXZ";
f01056e1:	b8 13 b6 10 f0       	mov    $0xf010b613,%eax
f01056e6:	e9 d0 00 00 00       	jmp    f01057bb <prefix_name+0x140>
    case 0x46:
      return "rexXY";
f01056eb:	b8 19 b6 10 f0       	mov    $0xf010b619,%eax
f01056f0:	e9 c6 00 00 00       	jmp    f01057bb <prefix_name+0x140>
    case 0x47:
      return "rexXYZ";
f01056f5:	b8 20 b6 10 f0       	mov    $0xf010b620,%eax
f01056fa:	e9 bc 00 00 00       	jmp    f01057bb <prefix_name+0x140>
    case 0x48:
      return "rex64";
f01056ff:	b8 26 b6 10 f0       	mov    $0xf010b626,%eax
f0105704:	e9 b2 00 00 00       	jmp    f01057bb <prefix_name+0x140>
    case 0x49:
      return "rex64Z";
f0105709:	b8 2d b6 10 f0       	mov    $0xf010b62d,%eax
f010570e:	e9 a8 00 00 00       	jmp    f01057bb <prefix_name+0x140>
    case 0x4a:
      return "rex64Y";
f0105713:	b8 34 b6 10 f0       	mov    $0xf010b634,%eax
f0105718:	e9 9e 00 00 00       	jmp    f01057bb <prefix_name+0x140>
    case 0x4b:
      return "rex64YZ";
f010571d:	b8 3c b6 10 f0       	mov    $0xf010b63c,%eax
f0105722:	e9 94 00 00 00       	jmp    f01057bb <prefix_name+0x140>
    case 0x4c:
      return "rex64X";
f0105727:	b8 43 b6 10 f0       	mov    $0xf010b643,%eax
f010572c:	e9 8a 00 00 00       	jmp    f01057bb <prefix_name+0x140>
    case 0x4d:
      return "rex64XZ";
f0105731:	b8 4b b6 10 f0       	mov    $0xf010b64b,%eax
f0105736:	e9 80 00 00 00       	jmp    f01057bb <prefix_name+0x140>
    case 0x4e:
      return "rex64XY";
f010573b:	b8 53 b6 10 f0       	mov    $0xf010b653,%eax
f0105740:	eb 79                	jmp    f01057bb <prefix_name+0x140>
    case 0x4f:
      return "rex64XYZ";
f0105742:	b8 5c b6 10 f0       	mov    $0xf010b65c,%eax
f0105747:	eb 72                	jmp    f01057bb <prefix_name+0x140>
    case 0xf3:
      return "repz";
f0105749:	b8 61 b6 10 f0       	mov    $0xf010b661,%eax
f010574e:	eb 6b                	jmp    f01057bb <prefix_name+0x140>
    case 0xf2:
      return "repnz";
f0105750:	b8 67 b6 10 f0       	mov    $0xf010b667,%eax
f0105755:	eb 64                	jmp    f01057bb <prefix_name+0x140>
    case 0xf0:
      return "lock";
f0105757:	b8 a2 b9 10 f0       	mov    $0xf010b9a2,%eax
f010575c:	eb 5d                	jmp    f01057bb <prefix_name+0x140>
    case 0x2e:
      return "cs";
f010575e:	b8 a6 b9 10 f0       	mov    $0xf010b9a6,%eax
f0105763:	eb 56                	jmp    f01057bb <prefix_name+0x140>
    case 0x36:
      return "ss";
f0105765:	b8 aa b9 10 f0       	mov    $0xf010b9aa,%eax
f010576a:	eb 4f                	jmp    f01057bb <prefix_name+0x140>
    case 0x3e:
      return "ds";
f010576c:	b8 9e b9 10 f0       	mov    $0xf010b99e,%eax
f0105771:	eb 48                	jmp    f01057bb <prefix_name+0x140>
    case 0x26:
      return "es";
f0105773:	b8 ae b9 10 f0       	mov    $0xf010b9ae,%eax
f0105778:	eb 41                	jmp    f01057bb <prefix_name+0x140>
    case 0x64:
      return "fs";
f010577a:	b8 b2 b9 10 f0       	mov    $0xf010b9b2,%eax
f010577f:	eb 3a                	jmp    f01057bb <prefix_name+0x140>
    case 0x65:
      return "gs";
    case 0x66:
      return (sizeflag & DFLAG) ? "data16" : "data32";
f0105781:	b8 6c b6 10 f0       	mov    $0xf010b66c,%eax
f0105786:	f6 c2 01             	test   $0x1,%dl
f0105789:	75 30                	jne    f01057bb <prefix_name+0x140>
f010578b:	b8 73 b6 10 f0       	mov    $0xf010b673,%eax
f0105790:	eb 29                	jmp    f01057bb <prefix_name+0x140>
    case 0x67:
      if (mode_64bit)
f0105792:	83 3d 60 9e 1b f0 00 	cmpl   $0x0,0xf01b9e60
f0105799:	74 11                	je     f01057ac <prefix_name+0x131>
        return (sizeflag & AFLAG) ? "addr32" : "addr64";
f010579b:	b8 7a b6 10 f0       	mov    $0xf010b67a,%eax
f01057a0:	f6 c2 02             	test   $0x2,%dl
f01057a3:	75 16                	jne    f01057bb <prefix_name+0x140>
f01057a5:	b8 81 b6 10 f0       	mov    $0xf010b681,%eax
f01057aa:	eb 0f                	jmp    f01057bb <prefix_name+0x140>
      else
        return ((sizeflag & AFLAG) && !mode_64bit) ? "addr16" : "addr32";
f01057ac:	b8 88 b6 10 f0       	mov    $0xf010b688,%eax
f01057b1:	f6 c2 02             	test   $0x2,%dl
f01057b4:	75 05                	jne    f01057bb <prefix_name+0x140>
f01057b6:	b8 7a b6 10 f0       	mov    $0xf010b67a,%eax
    case FWAIT_OPCODE:
      return "fwait";
    default:
      return NULL;
    }
}
f01057bb:	5d                   	pop    %ebp
f01057bc:	c3                   	ret    

f01057bd <get64>:
    }
}

static bfd_vma
get64 ()
{
f01057bd:	55                   	push   %ebp
f01057be:	89 e5                	mov    %esp,%ebp
f01057c0:	83 ec 18             	sub    $0x18,%esp
f01057c3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01057c6:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01057c9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  bfd_vma x;
#ifdef BFD64
  unsigned int a;
  unsigned int b;

  FETCH_DATA (the_info, codep + 8);
f01057cc:	8b 15 6c 9f 1b f0    	mov    0xf01b9f6c,%edx
f01057d2:	83 c2 08             	add    $0x8,%edx
f01057d5:	8b 0d 70 9f 1b f0    	mov    0xf01b9f70,%ecx
f01057db:	8b 41 20             	mov    0x20(%ecx),%eax
f01057de:	3b 10                	cmp    (%eax),%edx
f01057e0:	76 07                	jbe    f01057e9 <get64+0x2c>
f01057e2:	89 c8                	mov    %ecx,%eax
f01057e4:	e8 07 fe ff ff       	call   f01055f0 <fetch_data>
  a = *codep++ & 0xff;
f01057e9:	8b 3d 6c 9f 1b f0    	mov    0xf01b9f6c,%edi
f01057ef:	0f b6 07             	movzbl (%edi),%eax
  a |= (*codep++ & 0xff) << 8;
f01057f2:	0f b6 5f 01          	movzbl 0x1(%edi),%ebx
f01057f6:	c1 e3 08             	shl    $0x8,%ebx
f01057f9:	09 c3                	or     %eax,%ebx
  a |= (*codep++ & 0xff) << 16;
f01057fb:	0f b6 47 02          	movzbl 0x2(%edi),%eax
f01057ff:	c1 e0 10             	shl    $0x10,%eax
f0105802:	09 c3                	or     %eax,%ebx
  a |= (*codep++ & 0xff) << 24;
f0105804:	0f b6 47 03          	movzbl 0x3(%edi),%eax
f0105808:	c1 e0 18             	shl    $0x18,%eax
f010580b:	09 c3                	or     %eax,%ebx
  b = *codep++ & 0xff;
f010580d:	0f b6 4f 04          	movzbl 0x4(%edi),%ecx
  b |= (*codep++ & 0xff) << 8;
f0105811:	0f b6 47 05          	movzbl 0x5(%edi),%eax
f0105815:	c1 e0 08             	shl    $0x8,%eax
f0105818:	09 c8                	or     %ecx,%eax
  b |= (*codep++ & 0xff) << 16;
f010581a:	0f b6 4f 06          	movzbl 0x6(%edi),%ecx
f010581e:	c1 e1 10             	shl    $0x10,%ecx
f0105821:	09 c8                	or     %ecx,%eax
  b |= (*codep++ & 0xff) << 24;
f0105823:	0f b6 4f 07          	movzbl 0x7(%edi),%ecx
f0105827:	c1 e1 18             	shl    $0x18,%ecx
f010582a:	09 c8                	or     %ecx,%eax
f010582c:	83 c7 08             	add    $0x8,%edi
f010582f:	89 3d 6c 9f 1b f0    	mov    %edi,0xf01b9f6c
f0105835:	89 c2                	mov    %eax,%edx
f0105837:	b8 00 00 00 00       	mov    $0x0,%eax
f010583c:	be 00 00 00 00       	mov    $0x0,%esi
f0105841:	01 d8                	add    %ebx,%eax
f0105843:	11 f2                	adc    %esi,%edx
  abort ();
   panic("get64:erron occured");
  x = 0;
#endif
  return x;
}
f0105845:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0105848:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010584b:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010584e:	89 ec                	mov    %ebp,%esp
f0105850:	5d                   	pop    %ebp
f0105851:	c3                   	ret    

f0105852 <get32>:

static bfd_signed_vma
get32 ()
{
f0105852:	55                   	push   %ebp
f0105853:	89 e5                	mov    %esp,%ebp
f0105855:	56                   	push   %esi
f0105856:	53                   	push   %ebx
  bfd_signed_vma x = 0;

  FETCH_DATA (the_info, codep + 4);
f0105857:	8b 15 6c 9f 1b f0    	mov    0xf01b9f6c,%edx
f010585d:	83 c2 04             	add    $0x4,%edx
f0105860:	8b 0d 70 9f 1b f0    	mov    0xf01b9f70,%ecx
f0105866:	8b 41 20             	mov    0x20(%ecx),%eax
f0105869:	3b 10                	cmp    (%eax),%edx
f010586b:	76 07                	jbe    f0105874 <get32+0x22>
f010586d:	89 c8                	mov    %ecx,%eax
f010586f:	e8 7c fd ff ff       	call   f01055f0 <fetch_data>
  x = *codep++ & (bfd_signed_vma) 0xff;
f0105874:	8b 35 6c 9f 1b f0    	mov    0xf01b9f6c,%esi
f010587a:	0f b6 0e             	movzbl (%esi),%ecx
f010587d:	bb 00 00 00 00       	mov    $0x0,%ebx
  x |= (*codep++ & (bfd_signed_vma) 0xff) << 8;
f0105882:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0105886:	ba 00 00 00 00       	mov    $0x0,%edx
f010588b:	0f a4 c2 08          	shld   $0x8,%eax,%edx
f010588f:	c1 e0 08             	shl    $0x8,%eax
f0105892:	09 c8                	or     %ecx,%eax
f0105894:	09 da                	or     %ebx,%edx
  x |= (*codep++ & (bfd_signed_vma) 0xff) << 16;
f0105896:	0f b6 4e 02          	movzbl 0x2(%esi),%ecx
f010589a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010589f:	0f a4 cb 10          	shld   $0x10,%ecx,%ebx
f01058a3:	c1 e1 10             	shl    $0x10,%ecx
f01058a6:	09 c8                	or     %ecx,%eax
f01058a8:	09 da                	or     %ebx,%edx
  x |= (*codep++ & (bfd_signed_vma) 0xff) << 24;
f01058aa:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
f01058ae:	bb 00 00 00 00       	mov    $0x0,%ebx
f01058b3:	0f a4 cb 18          	shld   $0x18,%ecx,%ebx
f01058b7:	c1 e1 18             	shl    $0x18,%ecx
f01058ba:	09 c8                	or     %ecx,%eax
f01058bc:	09 da                	or     %ebx,%edx
f01058be:	83 c6 04             	add    $0x4,%esi
f01058c1:	89 35 6c 9f 1b f0    	mov    %esi,0xf01b9f6c
  return x;
}
f01058c7:	5b                   	pop    %ebx
f01058c8:	5e                   	pop    %esi
f01058c9:	5d                   	pop    %ebp
f01058ca:	c3                   	ret    

f01058cb <get32s>:

static bfd_signed_vma
get32s ()
{
f01058cb:	55                   	push   %ebp
f01058cc:	89 e5                	mov    %esp,%ebp
f01058ce:	56                   	push   %esi
f01058cf:	53                   	push   %ebx
  bfd_signed_vma x = 0;

  FETCH_DATA (the_info, codep + 4);
f01058d0:	8b 15 6c 9f 1b f0    	mov    0xf01b9f6c,%edx
f01058d6:	83 c2 04             	add    $0x4,%edx
f01058d9:	8b 0d 70 9f 1b f0    	mov    0xf01b9f70,%ecx
f01058df:	8b 41 20             	mov    0x20(%ecx),%eax
f01058e2:	3b 10                	cmp    (%eax),%edx
f01058e4:	76 07                	jbe    f01058ed <get32s+0x22>
f01058e6:	89 c8                	mov    %ecx,%eax
f01058e8:	e8 03 fd ff ff       	call   f01055f0 <fetch_data>
  x = *codep++ & (bfd_signed_vma) 0xff;
f01058ed:	8b 35 6c 9f 1b f0    	mov    0xf01b9f6c,%esi
f01058f3:	0f b6 0e             	movzbl (%esi),%ecx
f01058f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  x |= (*codep++ & (bfd_signed_vma) 0xff) << 8;
f01058fb:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f01058ff:	ba 00 00 00 00       	mov    $0x0,%edx
f0105904:	0f a4 c2 08          	shld   $0x8,%eax,%edx
f0105908:	c1 e0 08             	shl    $0x8,%eax
f010590b:	09 c8                	or     %ecx,%eax
f010590d:	09 da                	or     %ebx,%edx
  x |= (*codep++ & (bfd_signed_vma) 0xff) << 16;
f010590f:	0f b6 4e 02          	movzbl 0x2(%esi),%ecx
f0105913:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105918:	0f a4 cb 10          	shld   $0x10,%ecx,%ebx
f010591c:	c1 e1 10             	shl    $0x10,%ecx
f010591f:	09 c8                	or     %ecx,%eax
f0105921:	09 da                	or     %ebx,%edx
  x |= (*codep++ & (bfd_signed_vma) 0xff) << 24;
f0105923:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
f0105927:	bb 00 00 00 00       	mov    $0x0,%ebx
f010592c:	0f a4 cb 18          	shld   $0x18,%ecx,%ebx
f0105930:	c1 e1 18             	shl    $0x18,%ecx
f0105933:	09 c8                	or     %ecx,%eax
f0105935:	09 da                	or     %ebx,%edx
f0105937:	83 c6 04             	add    $0x4,%esi
f010593a:	89 35 6c 9f 1b f0    	mov    %esi,0xf01b9f6c

  x = (x ^ ((bfd_signed_vma) 1 << 31)) - ((bfd_signed_vma) 1 << 31);
f0105940:	2d 00 00 00 80       	sub    $0x80000000,%eax
f0105945:	05 00 00 00 80       	add    $0x80000000,%eax
f010594a:	83 d2 ff             	adc    $0xffffffff,%edx

  return x;
}
f010594d:	5b                   	pop    %ebx
f010594e:	5e                   	pop    %esi
f010594f:	5d                   	pop    %ebp
f0105950:	c3                   	ret    

f0105951 <get16>:

static int
get16 ()
{
f0105951:	55                   	push   %ebp
f0105952:	89 e5                	mov    %esp,%ebp
f0105954:	83 ec 08             	sub    $0x8,%esp
  int x = 0;

  FETCH_DATA (the_info, codep + 2);
f0105957:	8b 15 6c 9f 1b f0    	mov    0xf01b9f6c,%edx
f010595d:	83 c2 02             	add    $0x2,%edx
f0105960:	8b 0d 70 9f 1b f0    	mov    0xf01b9f70,%ecx
f0105966:	8b 41 20             	mov    0x20(%ecx),%eax
f0105969:	3b 10                	cmp    (%eax),%edx
f010596b:	76 07                	jbe    f0105974 <get16+0x23>
f010596d:	89 c8                	mov    %ecx,%eax
f010596f:	e8 7c fc ff ff       	call   f01055f0 <fetch_data>
  x = *codep++ & 0xff;
f0105974:	8b 15 6c 9f 1b f0    	mov    0xf01b9f6c,%edx
f010597a:	0f b6 0a             	movzbl (%edx),%ecx
  x |= (*codep++ & 0xff) << 8;
f010597d:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f0105981:	c1 e0 08             	shl    $0x8,%eax
f0105984:	09 c8                	or     %ecx,%eax
f0105986:	83 c2 02             	add    $0x2,%edx
f0105989:	89 15 6c 9f 1b f0    	mov    %edx,0xf01b9f6c
  return x;
}
f010598f:	c9                   	leave  
f0105990:	c3                   	ret    

f0105991 <set_op>:

static void
set_op (op, riprel)
     bfd_vma op;
     int riprel;
{
f0105991:	55                   	push   %ebp
f0105992:	89 e5                	mov    %esp,%ebp
f0105994:	83 ec 08             	sub    $0x8,%esp
f0105997:	89 1c 24             	mov    %ebx,(%esp)
f010599a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010599e:	89 c3                	mov    %eax,%ebx
  op_index[op_ad] = op_ad;
f01059a0:	a1 04 a1 1b f0       	mov    0xf01ba104,%eax
f01059a5:	89 04 85 08 a1 1b f0 	mov    %eax,-0xfe45ef8(,%eax,4)
  if (mode_64bit)
f01059ac:	83 3d 60 9e 1b f0 00 	cmpl   $0x0,0xf01b9e60
f01059b3:	74 23                	je     f01059d8 <set_op+0x47>
    {
      op_address[op_ad] = op;
f01059b5:	89 1c c5 18 a1 1b f0 	mov    %ebx,-0xfe45ee8(,%eax,8)
f01059bc:	89 14 c5 1c a1 1b f0 	mov    %edx,-0xfe45ee4(,%eax,8)
      op_riprel[op_ad] = riprel;
f01059c3:	89 0c c5 30 a1 1b f0 	mov    %ecx,-0xfe45ed0(,%eax,8)
f01059ca:	89 ca                	mov    %ecx,%edx
f01059cc:	c1 fa 1f             	sar    $0x1f,%edx
f01059cf:	89 14 c5 34 a1 1b f0 	mov    %edx,-0xfe45ecc(,%eax,8)
f01059d6:	eb 24                	jmp    f01059fc <set_op+0x6b>
    }
  else
    {
      /* Mask to get a 32-bit address.  */
      op_address[op_ad] = op & 0xffffffff;
f01059d8:	89 1c c5 18 a1 1b f0 	mov    %ebx,-0xfe45ee8(,%eax,8)
f01059df:	c7 04 c5 1c a1 1b f0 	movl   $0x0,-0xfe45ee4(,%eax,8)
f01059e6:	00 00 00 00 
      op_riprel[op_ad] = riprel & 0xffffffff;
f01059ea:	89 0c c5 30 a1 1b f0 	mov    %ecx,-0xfe45ed0(,%eax,8)
f01059f1:	c7 04 c5 34 a1 1b f0 	movl   $0x0,-0xfe45ecc(,%eax,8)
f01059f8:	00 00 00 00 
    }
}
f01059fc:	8b 1c 24             	mov    (%esp),%ebx
f01059ff:	8b 74 24 04          	mov    0x4(%esp),%esi
f0105a03:	89 ec                	mov    %ebp,%esp
f0105a05:	5d                   	pop    %ebp
f0105a06:	c3                   	ret    

f0105a07 <putop>:
/* Capital letters in template are macros.  */
static int
putop (template, sizeflag)
     const char *template;
     int sizeflag;
{
f0105a07:	55                   	push   %ebp
f0105a08:	89 e5                	mov    %esp,%ebp
f0105a0a:	57                   	push   %edi
f0105a0b:	56                   	push   %esi
f0105a0c:	53                   	push   %ebx
f0105a0d:	83 ec 4c             	sub    $0x4c,%esp
f0105a10:	89 c6                	mov    %eax,%esi
f0105a12:	89 55 b8             	mov    %edx,-0x48(%ebp)
  const char *p;
  int alt;

  for (p = template; *p; p++)
f0105a15:	0f b6 18             	movzbl (%eax),%ebx
f0105a18:	84 db                	test   %bl,%bl
f0105a1a:	0f 84 1b 05 00 00    	je     f0105f3b <putop+0x534>
f0105a20:	80 3d 50 a1 1b f0 00 	cmpb   $0x0,0xf01ba150
f0105a27:	0f 95 45 eb          	setne  -0x15(%ebp)
f0105a2b:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
f0105a2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	  break;
	case '{':
	  alt = 0;
	  if (intel_syntax)
	    alt += 1;
	  if (mode_64bit)
f0105a32:	8b 15 60 9e 1b f0    	mov    0xf01b9e60,%edx
f0105a38:	89 55 bc             	mov    %edx,-0x44(%ebp)
	    alt += 2;
f0105a3b:	83 c0 02             	add    $0x2,%eax
f0105a3e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	case '}':
	  break;
	case 'A':
          if (intel_syntax)
            break;
	  if (mod != 3 || (sizeflag & SUFFIX_ALWAYS))
f0105a41:	a1 74 9f 1b f0       	mov    0xf01b9f74,%eax
f0105a46:	89 45 c0             	mov    %eax,-0x40(%ebp)
		*obufp++ = 'e';
	    }
	  else
	    if (sizeflag & AFLAG)
	      *obufp++ = 'e';
	  used_prefixes |= (prefixes & PREFIX_ADDR);
f0105a49:	a1 64 9e 1b f0       	mov    0xf01b9e64,%eax
f0105a4e:	89 c2                	mov    %eax,%edx
f0105a50:	81 e2 00 04 00 00    	and    $0x400,%edx
f0105a56:	89 55 c4             	mov    %edx,-0x3c(%ebp)
	    }
	  break;
	case 'H':
          if (intel_syntax)
            break;
	  if ((prefixes & (PREFIX_CS | PREFIX_DS)) == PREFIX_CS
f0105a59:	89 c2                	mov    %eax,%edx
f0105a5b:	83 e2 28             	and    $0x28,%edx
f0105a5e:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0105a61:	83 fa 08             	cmp    $0x8,%edx
f0105a64:	0f 94 c1             	sete   %cl
f0105a67:	83 fa 20             	cmp    $0x20,%edx
f0105a6a:	0f 94 c2             	sete   %dl
f0105a6d:	09 d1                	or     %edx,%ecx
f0105a6f:	88 4d cf             	mov    %cl,-0x31(%ebp)
	      || (prefixes & (PREFIX_CS | PREFIX_DS)) == PREFIX_DS)
	    {
	      used_prefixes |= prefixes & (PREFIX_CS | PREFIX_DS);
	      *obufp++ = ',';
	      *obufp++ = 'p';
	      if (prefixes & PREFIX_DS)
f0105a72:	89 c2                	mov    %eax,%edx
f0105a74:	83 e2 20             	and    $0x20,%edx
f0105a77:	89 55 d0             	mov    %edx,-0x30(%ebp)
            break;
	  if (sizeflag & SUFFIX_ALWAYS)
	    *obufp++ = 'l';
	  break;
	case 'N':
	  if ((prefixes & PREFIX_FWAIT) == 0)
f0105a7a:	89 c2                	mov    %eax,%edx
f0105a7c:	81 e2 00 08 00 00    	and    $0x800,%edx
f0105a82:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	    *obufp++ = 'n';
	  else
	    used_prefixes |= PREFIX_FWAIT;
	  break;
	case 'O':
	  USED_REX (REX_MODE64);
f0105a85:	8b 15 68 9e 1b f0    	mov    0xf01b9e68,%edx
f0105a8b:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0105a8e:	83 e2 08             	and    $0x8,%edx
f0105a91:	89 55 dc             	mov    %edx,-0x24(%ebp)
	    }
	  /* Fall through.  */
	case 'P':
          if (intel_syntax)
            break;
	  if ((prefixes & PREFIX_DATA)
f0105a94:	25 00 02 00 00       	and    $0x200,%eax
f0105a99:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105a9c:	a1 6c 9e 1b f0       	mov    0xf01b9e6c,%eax
f0105aa1:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105aa4:	8b 3d 70 9e 1b f0    	mov    0xf01b9e70,%edi
f0105aaa:	8b 0d e4 9e 1b f0    	mov    0xf01b9ee4,%ecx
f0105ab0:	89 f2                	mov    %esi,%edx
	      if (rex)
		{
		  *obufp++ = 'q';
		  *obufp++ = 'e';
		}
	      if (sizeflag & DFLAG)
f0105ab2:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0105ab5:	83 e0 01             	and    $0x1,%eax
f0105ab8:	89 45 b4             	mov    %eax,-0x4c(%ebp)
	    used_prefixes |= (prefixes & PREFIX_DATA);
	  break;
	case 'S':
          if (intel_syntax)
            break;
	  if (sizeflag & SUFFIX_ALWAYS)
f0105abb:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0105abe:	83 e6 04             	and    $0x4,%esi
  const char *p;
  int alt;

  for (p = template; *p; p++)
    {
      switch (*p)
f0105ac1:	8d 43 bf             	lea    -0x41(%ebx),%eax
f0105ac4:	3c 3c                	cmp    $0x3c,%al
f0105ac6:	77 0a                	ja     f0105ad2 <putop+0xcb>
f0105ac8:	0f b6 c0             	movzbl %al,%eax
f0105acb:	ff 24 85 38 cc 10 f0 	jmp    *-0xfef33c8(,%eax,4)
	{
	default:
	  *obufp++ = *p;
f0105ad2:	88 19                	mov    %bl,(%ecx)
f0105ad4:	83 c1 01             	add    $0x1,%ecx
f0105ad7:	e9 3d 04 00 00       	jmp    f0105f19 <putop+0x512>
	  break;
	case '{':
	  alt = 0;
	  if (intel_syntax)
	    alt += 1;
	  if (mode_64bit)
f0105adc:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0105adf:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
f0105ae3:	74 03                	je     f0105ae8 <putop+0xe1>
f0105ae5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	    alt += 2;
	  while (alt != 0)
f0105ae8:	85 db                	test   %ebx,%ebx
f0105aea:	75 60                	jne    f0105b4c <putop+0x145>
f0105aec:	e9 28 04 00 00       	jmp    f0105f19 <putop+0x512>
	    {
	      while (*++p != '|')
		{
		  if (*p == '}')
f0105af1:	3c 7d                	cmp    $0x7d,%al
f0105af3:	75 23                	jne    f0105b18 <putop+0x111>
f0105af5:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0105af8:	89 15 6c 9e 1b f0    	mov    %edx,0xf01b9e6c
f0105afe:	89 3d 70 9e 1b f0    	mov    %edi,0xf01b9e70
		    {
		      /* Alternative not valid.  */
                      //pstrcpy (obuf, sizeof(obuf), "(bad)");
                      //add your code here
                      
		      obufp = obuf + 5;
f0105b04:	c7 05 e4 9e 1b f0 85 	movl   $0xf01b9e85,0xf01b9ee4
f0105b0b:	9e 1b f0 
f0105b0e:	b8 01 00 00 00       	mov    $0x1,%eax
f0105b13:	e9 46 04 00 00       	jmp    f0105f5e <putop+0x557>
		      return 1;
		    }
		  else if (*p == '\0')
f0105b18:	84 c0                	test   %al,%al
f0105b1a:	75 30                	jne    f0105b4c <putop+0x145>
f0105b1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105b1f:	a3 6c 9e 1b f0       	mov    %eax,0xf01b9e6c
f0105b24:	89 3d 70 9e 1b f0    	mov    %edi,0xf01b9e70
f0105b2a:	89 0d e4 9e 1b f0    	mov    %ecx,0xf01b9ee4
		    //abort ();
		    panic("putop:erron occured");
f0105b30:	c7 44 24 08 8f b6 10 	movl   $0xf010b68f,0x8(%esp)
f0105b37:	f0 
f0105b38:	c7 44 24 04 40 0a 00 	movl   $0xa40,0x4(%esp)
f0105b3f:	00 
f0105b40:	c7 04 24 a3 b6 10 f0 	movl   $0xf010b6a3,(%esp)
f0105b47:	e8 3a a5 ff ff       	call   f0100086 <_panic>
	    alt += 1;
	  if (mode_64bit)
	    alt += 2;
	  while (alt != 0)
	    {
	      while (*++p != '|')
f0105b4c:	83 c2 01             	add    $0x1,%edx
f0105b4f:	0f b6 02             	movzbl (%edx),%eax
f0105b52:	3c 7c                	cmp    $0x7c,%al
f0105b54:	75 9b                	jne    f0105af1 <putop+0xea>
	  alt = 0;
	  if (intel_syntax)
	    alt += 1;
	  if (mode_64bit)
	    alt += 2;
	  while (alt != 0)
f0105b56:	83 eb 01             	sub    $0x1,%ebx
f0105b59:	0f 84 ba 03 00 00    	je     f0105f19 <putop+0x512>
f0105b5f:	90                   	nop    
f0105b60:	eb ea                	jmp    f0105b4c <putop+0x145>
	    }
	  break;
	case '|':
	  while (*++p != '}')
	    {
	      if (*p == '\0')
f0105b62:	84 c0                	test   %al,%al
f0105b64:	75 31                	jne    f0105b97 <putop+0x190>
f0105b66:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0105b69:	89 15 6c 9e 1b f0    	mov    %edx,0xf01b9e6c
f0105b6f:	89 3d 70 9e 1b f0    	mov    %edi,0xf01b9e70
f0105b75:	89 0d e4 9e 1b f0    	mov    %ecx,0xf01b9ee4
		//abort ();
		panic("putop:erron occured");
f0105b7b:	c7 44 24 08 8f b6 10 	movl   $0xf010b68f,0x8(%esp)
f0105b82:	f0 
f0105b83:	c7 44 24 04 4a 0a 00 	movl   $0xa4a,0x4(%esp)
f0105b8a:	00 
f0105b8b:	c7 04 24 a3 b6 10 f0 	movl   $0xf010b6a3,(%esp)
f0105b92:	e8 ef a4 ff ff       	call   f0100086 <_panic>
		}
	      alt--;
	    }
	  break;
	case '|':
	  while (*++p != '}')
f0105b97:	83 c2 01             	add    $0x1,%edx
f0105b9a:	0f b6 02             	movzbl (%edx),%eax
f0105b9d:	3c 7d                	cmp    $0x7d,%al
f0105b9f:	75 c1                	jne    f0105b62 <putop+0x15b>
f0105ba1:	e9 73 03 00 00       	jmp    f0105f19 <putop+0x512>
	    }
	  break;
	case '}':
	  break;
	case 'A':
          if (intel_syntax)
f0105ba6:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105baa:	0f 85 69 03 00 00    	jne    f0105f19 <putop+0x512>
            break;
	  if (mod != 3 || (sizeflag & SUFFIX_ALWAYS))
f0105bb0:	83 7d c0 03          	cmpl   $0x3,-0x40(%ebp)
f0105bb4:	75 08                	jne    f0105bbe <putop+0x1b7>
f0105bb6:	85 f6                	test   %esi,%esi
f0105bb8:	0f 84 5b 03 00 00    	je     f0105f19 <putop+0x512>
	    *obufp++ = 'b';
f0105bbe:	c6 01 62             	movb   $0x62,(%ecx)
f0105bc1:	83 c1 01             	add    $0x1,%ecx
f0105bc4:	e9 50 03 00 00       	jmp    f0105f19 <putop+0x512>
	  break;
	case 'B':
          if (intel_syntax)
f0105bc9:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105bcd:	8d 76 00             	lea    0x0(%esi),%esi
f0105bd0:	0f 85 43 03 00 00    	jne    f0105f19 <putop+0x512>
            break;
	  if (sizeflag & SUFFIX_ALWAYS)
f0105bd6:	85 f6                	test   %esi,%esi
f0105bd8:	0f 84 3b 03 00 00    	je     f0105f19 <putop+0x512>
	    *obufp++ = 'b';
f0105bde:	c6 01 62             	movb   $0x62,(%ecx)
f0105be1:	83 c1 01             	add    $0x1,%ecx
f0105be4:	e9 30 03 00 00       	jmp    f0105f19 <putop+0x512>
	  break;
	case 'E':		/* For jcxz/jecxz */
	  if (mode_64bit)
f0105be9:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
f0105bed:	8d 76 00             	lea    0x0(%esi),%esi
f0105bf0:	74 18                	je     f0105c0a <putop+0x203>
	    {
	      if (sizeflag & AFLAG)
f0105bf2:	f6 45 b8 02          	testb  $0x2,-0x48(%ebp)
f0105bf6:	74 0a                	je     f0105c02 <putop+0x1fb>
		*obufp++ = 'r';
f0105bf8:	c6 01 72             	movb   $0x72,(%ecx)
f0105bfb:	83 c1 01             	add    $0x1,%ecx
f0105bfe:	66 90                	xchg   %ax,%ax
f0105c00:	eb 14                	jmp    f0105c16 <putop+0x20f>
	      else
		*obufp++ = 'e';
f0105c02:	c6 01 65             	movb   $0x65,(%ecx)
f0105c05:	83 c1 01             	add    $0x1,%ecx
f0105c08:	eb 0c                	jmp    f0105c16 <putop+0x20f>
	    }
	  else
	    if (sizeflag & AFLAG)
f0105c0a:	f6 45 b8 02          	testb  $0x2,-0x48(%ebp)
f0105c0e:	74 06                	je     f0105c16 <putop+0x20f>
	      *obufp++ = 'e';
f0105c10:	c6 01 65             	movb   $0x65,(%ecx)
f0105c13:	83 c1 01             	add    $0x1,%ecx
	  used_prefixes |= (prefixes & PREFIX_ADDR);
f0105c16:	0b 7d c4             	or     -0x3c(%ebp),%edi
f0105c19:	e9 fb 02 00 00       	jmp    f0105f19 <putop+0x512>
	  break;
	case 'F':
          if (intel_syntax)
f0105c1e:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105c22:	0f 85 f1 02 00 00    	jne    f0105f19 <putop+0x512>
            break;
	  if ((prefixes & PREFIX_ADDR) || (sizeflag & SUFFIX_ALWAYS))
f0105c28:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f0105c2c:	75 08                	jne    f0105c36 <putop+0x22f>
f0105c2e:	85 f6                	test   %esi,%esi
f0105c30:	0f 84 e3 02 00 00    	je     f0105f19 <putop+0x512>
	    {
	      if (sizeflag & AFLAG)
f0105c36:	f6 45 b8 02          	testb  $0x2,-0x48(%ebp)
f0105c3a:	74 13                	je     f0105c4f <putop+0x248>
		*obufp++ = mode_64bit ? 'q' : 'l';
f0105c3c:	83 7d bc 01          	cmpl   $0x1,-0x44(%ebp)
f0105c40:	19 c0                	sbb    %eax,%eax
f0105c42:	83 e0 fb             	and    $0xfffffffb,%eax
f0105c45:	83 c0 71             	add    $0x71,%eax
f0105c48:	88 01                	mov    %al,(%ecx)
f0105c4a:	83 c1 01             	add    $0x1,%ecx
f0105c4d:	eb 11                	jmp    f0105c60 <putop+0x259>
	      else
		*obufp++ = mode_64bit ? 'l' : 'w';
f0105c4f:	83 7d bc 01          	cmpl   $0x1,-0x44(%ebp)
f0105c53:	19 c0                	sbb    %eax,%eax
f0105c55:	83 e0 0b             	and    $0xb,%eax
f0105c58:	83 c0 6c             	add    $0x6c,%eax
f0105c5b:	88 01                	mov    %al,(%ecx)
f0105c5d:	83 c1 01             	add    $0x1,%ecx
	      used_prefixes |= (prefixes & PREFIX_ADDR);
f0105c60:	0b 7d c4             	or     -0x3c(%ebp),%edi
f0105c63:	e9 b1 02 00 00       	jmp    f0105f19 <putop+0x512>
	    }
	  break;
	case 'H':
          if (intel_syntax)
f0105c68:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105c6c:	0f 85 a7 02 00 00    	jne    f0105f19 <putop+0x512>
            break;
	  if ((prefixes & (PREFIX_CS | PREFIX_DS)) == PREFIX_CS
f0105c72:	80 7d cf 00          	cmpb   $0x0,-0x31(%ebp)
f0105c76:	0f 84 9d 02 00 00    	je     f0105f19 <putop+0x512>
	      || (prefixes & (PREFIX_CS | PREFIX_DS)) == PREFIX_DS)
	    {
	      used_prefixes |= prefixes & (PREFIX_CS | PREFIX_DS);
f0105c7c:	0b 7d c8             	or     -0x38(%ebp),%edi
	      *obufp++ = ',';
f0105c7f:	c6 01 2c             	movb   $0x2c,(%ecx)
	      *obufp++ = 'p';
f0105c82:	c6 41 01 70          	movb   $0x70,0x1(%ecx)
f0105c86:	8d 41 02             	lea    0x2(%ecx),%eax
	      if (prefixes & PREFIX_DS)
f0105c89:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0105c8d:	74 0c                	je     f0105c9b <putop+0x294>
		*obufp++ = 't';
f0105c8f:	c6 41 02 74          	movb   $0x74,0x2(%ecx)
f0105c93:	83 c1 03             	add    $0x3,%ecx
f0105c96:	e9 7e 02 00 00       	jmp    f0105f19 <putop+0x512>
	      else
		*obufp++ = 'n';
f0105c9b:	c6 00 6e             	movb   $0x6e,(%eax)
f0105c9e:	8d 48 01             	lea    0x1(%eax),%ecx
f0105ca1:	e9 73 02 00 00       	jmp    f0105f19 <putop+0x512>
	    }
	  break;
	case 'L':
          if (intel_syntax)
f0105ca6:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105caa:	0f 85 69 02 00 00    	jne    f0105f19 <putop+0x512>
            break;
	  if (sizeflag & SUFFIX_ALWAYS)
f0105cb0:	85 f6                	test   %esi,%esi
f0105cb2:	0f 84 61 02 00 00    	je     f0105f19 <putop+0x512>
	    *obufp++ = 'l';
f0105cb8:	c6 01 6c             	movb   $0x6c,(%ecx)
f0105cbb:	83 c1 01             	add    $0x1,%ecx
f0105cbe:	66 90                	xchg   %ax,%ax
f0105cc0:	e9 54 02 00 00       	jmp    f0105f19 <putop+0x512>
	  break;
	case 'N':
	  if ((prefixes & PREFIX_FWAIT) == 0)
f0105cc5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0105cc9:	75 0b                	jne    f0105cd6 <putop+0x2cf>
	    *obufp++ = 'n';
f0105ccb:	c6 01 6e             	movb   $0x6e,(%ecx)
f0105cce:	83 c1 01             	add    $0x1,%ecx
f0105cd1:	e9 43 02 00 00       	jmp    f0105f19 <putop+0x512>
	  else
	    used_prefixes |= PREFIX_FWAIT;
f0105cd6:	81 cf 00 08 00 00    	or     $0x800,%edi
f0105cdc:	e9 38 02 00 00       	jmp    f0105f19 <putop+0x512>
	  break;
	case 'O':
	  USED_REX (REX_MODE64);
f0105ce1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105ce5:	0f 84 5f 02 00 00    	je     f0105f4a <putop+0x543>
f0105ceb:	83 4d ec 48          	orl    $0x48,-0x14(%ebp)
	  if (rex & REX_MODE64)
	    *obufp++ = 'o';
f0105cef:	c6 01 6f             	movb   $0x6f,(%ecx)
f0105cf2:	83 c1 01             	add    $0x1,%ecx
f0105cf5:	e9 1f 02 00 00       	jmp    f0105f19 <putop+0x512>
	  else
	    *obufp++ = 'd';
	  break;
	case 'T':
          if (intel_syntax)
f0105cfa:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105cfe:	0f 85 15 02 00 00    	jne    f0105f19 <putop+0x512>
            break;
	  if (mode_64bit)
f0105d04:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
f0105d08:	74 15                	je     f0105d1f <putop+0x318>
	    {
	      *obufp++ = 'q';
f0105d0a:	c6 01 71             	movb   $0x71,(%ecx)
f0105d0d:	83 c1 01             	add    $0x1,%ecx
f0105d10:	e9 04 02 00 00       	jmp    f0105f19 <putop+0x512>
	      break;
	    }
	  /* Fall through.  */
	case 'P':
          if (intel_syntax)
f0105d15:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105d19:	0f 85 fa 01 00 00    	jne    f0105f19 <putop+0x512>
            break;
	  if ((prefixes & PREFIX_DATA)
f0105d1f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105d23:	75 13                	jne    f0105d38 <putop+0x331>
f0105d25:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105d29:	0f 85 23 02 00 00    	jne    f0105f52 <putop+0x54b>
f0105d2f:	85 f6                	test   %esi,%esi
f0105d31:	75 13                	jne    f0105d46 <putop+0x33f>
f0105d33:	e9 e1 01 00 00       	jmp    f0105f19 <putop+0x512>
	      || (rex & REX_MODE64)
	      || (sizeflag & SUFFIX_ALWAYS))
	    {
	      USED_REX (REX_MODE64);
f0105d38:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105d3c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0105d40:	0f 85 0c 02 00 00    	jne    f0105f52 <putop+0x54b>
	      if (rex & REX_MODE64)
		*obufp++ = 'q';
	      else
		{
		   if (sizeflag & DFLAG)
f0105d46:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
f0105d4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105d50:	74 08                	je     f0105d5a <putop+0x353>
		      *obufp++ = 'l';
f0105d52:	c6 01 6c             	movb   $0x6c,(%ecx)
f0105d55:	83 c1 01             	add    $0x1,%ecx
f0105d58:	eb 06                	jmp    f0105d60 <putop+0x359>
		   else
		     *obufp++ = 'w';
f0105d5a:	c6 01 77             	movb   $0x77,(%ecx)
f0105d5d:	83 c1 01             	add    $0x1,%ecx
		   used_prefixes |= (prefixes & PREFIX_DATA);
f0105d60:	0b 7d e0             	or     -0x20(%ebp),%edi
f0105d63:	e9 b1 01 00 00       	jmp    f0105f19 <putop+0x512>
		}
	    }
	  break;
	case 'U':
          if (intel_syntax)
f0105d68:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105d6c:	0f 85 a7 01 00 00    	jne    f0105f19 <putop+0x512>
            break;
	  if (mode_64bit)
f0105d72:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
f0105d76:	74 17                	je     f0105d8f <putop+0x388>
	    {
	      *obufp++ = 'q';
f0105d78:	c6 01 71             	movb   $0x71,(%ecx)
f0105d7b:	83 c1 01             	add    $0x1,%ecx
f0105d7e:	66 90                	xchg   %ax,%ax
f0105d80:	e9 94 01 00 00       	jmp    f0105f19 <putop+0x512>
	      break;
	    }
	  /* Fall through.  */
	case 'Q':
          if (intel_syntax)
f0105d85:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105d89:	0f 85 8a 01 00 00    	jne    f0105f19 <putop+0x512>
            break;
	  USED_REX (REX_MODE64);
f0105d8f:	83 7d dc 01          	cmpl   $0x1,-0x24(%ebp)
f0105d93:	19 c0                	sbb    %eax,%eax
f0105d95:	f7 d0                	not    %eax
f0105d97:	83 e0 48             	and    $0x48,%eax
f0105d9a:	09 45 ec             	or     %eax,-0x14(%ebp)
	  if (mod != 3 || (sizeflag & SUFFIX_ALWAYS))
f0105d9d:	83 7d c0 03          	cmpl   $0x3,-0x40(%ebp)
f0105da1:	75 08                	jne    f0105dab <putop+0x3a4>
f0105da3:	85 f6                	test   %esi,%esi
f0105da5:	0f 84 6e 01 00 00    	je     f0105f19 <putop+0x512>
	    {
	      if (rex & REX_MODE64)
f0105dab:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105daf:	74 0b                	je     f0105dbc <putop+0x3b5>
		*obufp++ = 'q';
f0105db1:	c6 01 71             	movb   $0x71,(%ecx)
f0105db4:	83 c1 01             	add    $0x1,%ecx
f0105db7:	e9 5d 01 00 00       	jmp    f0105f19 <putop+0x512>
	      else
		{
		  if (sizeflag & DFLAG)
f0105dbc:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
f0105dc0:	74 08                	je     f0105dca <putop+0x3c3>
		    *obufp++ = 'l';
f0105dc2:	c6 01 6c             	movb   $0x6c,(%ecx)
f0105dc5:	83 c1 01             	add    $0x1,%ecx
f0105dc8:	eb 06                	jmp    f0105dd0 <putop+0x3c9>
		  else
		    *obufp++ = 'w';
f0105dca:	c6 01 77             	movb   $0x77,(%ecx)
f0105dcd:	83 c1 01             	add    $0x1,%ecx
		  used_prefixes |= (prefixes & PREFIX_DATA);
f0105dd0:	0b 7d e0             	or     -0x20(%ebp),%edi
f0105dd3:	e9 41 01 00 00       	jmp    f0105f19 <putop+0x512>
		}
	    }
	  break;
	case 'R':
	  USED_REX (REX_MODE64);
f0105dd8:	83 7d dc 01          	cmpl   $0x1,-0x24(%ebp)
f0105ddc:	19 c0                	sbb    %eax,%eax
f0105dde:	f7 d0                	not    %eax
f0105de0:	83 e0 48             	and    $0x48,%eax
f0105de3:	09 45 ec             	or     %eax,-0x14(%ebp)
          if (intel_syntax)
f0105de6:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105dea:	74 33                	je     f0105e1f <putop+0x418>
	    {
	      if (rex & REX_MODE64)
f0105dec:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105df0:	74 0f                	je     f0105e01 <putop+0x3fa>
		{
		  *obufp++ = 'q';
f0105df2:	c6 01 71             	movb   $0x71,(%ecx)
		  *obufp++ = 't';
f0105df5:	c6 41 01 74          	movb   $0x74,0x1(%ecx)
f0105df9:	83 c1 02             	add    $0x2,%ecx
f0105dfc:	e9 18 01 00 00       	jmp    f0105f19 <putop+0x512>
		}
	      else if (sizeflag & DFLAG)
f0105e01:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
f0105e05:	74 0c                	je     f0105e13 <putop+0x40c>
		{
		  *obufp++ = 'd';
f0105e07:	c6 01 64             	movb   $0x64,(%ecx)
		  *obufp++ = 'q';
f0105e0a:	c6 41 01 71          	movb   $0x71,0x1(%ecx)
f0105e0e:	83 c1 02             	add    $0x2,%ecx
f0105e11:	eb 31                	jmp    f0105e44 <putop+0x43d>
		}
	      else
		{
		  *obufp++ = 'w';
f0105e13:	c6 01 77             	movb   $0x77,(%ecx)
		  *obufp++ = 'd';
f0105e16:	c6 41 01 64          	movb   $0x64,0x1(%ecx)
f0105e1a:	83 c1 02             	add    $0x2,%ecx
f0105e1d:	eb 25                	jmp    f0105e44 <putop+0x43d>
		}
	    }
	  else
	    {
	      if (rex & REX_MODE64)
f0105e1f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105e23:	74 0b                	je     f0105e30 <putop+0x429>
		*obufp++ = 'q';
f0105e25:	c6 01 71             	movb   $0x71,(%ecx)
f0105e28:	83 c1 01             	add    $0x1,%ecx
f0105e2b:	e9 e9 00 00 00       	jmp    f0105f19 <putop+0x512>
	      else if (sizeflag & DFLAG)
f0105e30:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
f0105e34:	74 08                	je     f0105e3e <putop+0x437>
		*obufp++ = 'l';
f0105e36:	c6 01 6c             	movb   $0x6c,(%ecx)
f0105e39:	83 c1 01             	add    $0x1,%ecx
f0105e3c:	eb 06                	jmp    f0105e44 <putop+0x43d>
	      else
		*obufp++ = 'w';
f0105e3e:	c6 01 77             	movb   $0x77,(%ecx)
f0105e41:	83 c1 01             	add    $0x1,%ecx
	    }
	  if (!(rex & REX_MODE64))
	    used_prefixes |= (prefixes & PREFIX_DATA);
f0105e44:	0b 7d e0             	or     -0x20(%ebp),%edi
f0105e47:	e9 cd 00 00 00       	jmp    f0105f19 <putop+0x512>
	  break;
	case 'S':
          if (intel_syntax)
f0105e4c:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105e50:	0f 85 c3 00 00 00    	jne    f0105f19 <putop+0x512>
            break;
	  if (sizeflag & SUFFIX_ALWAYS)
f0105e56:	85 f6                	test   %esi,%esi
f0105e58:	0f 84 bb 00 00 00    	je     f0105f19 <putop+0x512>
	    {
	      if (rex & REX_MODE64)
f0105e5e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105e62:	74 0b                	je     f0105e6f <putop+0x468>
		*obufp++ = 'q';
f0105e64:	c6 01 71             	movb   $0x71,(%ecx)
f0105e67:	83 c1 01             	add    $0x1,%ecx
f0105e6a:	e9 aa 00 00 00       	jmp    f0105f19 <putop+0x512>
	      else
		{
		  if (sizeflag & DFLAG)
f0105e6f:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
f0105e73:	74 08                	je     f0105e7d <putop+0x476>
		    *obufp++ = 'l';
f0105e75:	c6 01 6c             	movb   $0x6c,(%ecx)
f0105e78:	83 c1 01             	add    $0x1,%ecx
f0105e7b:	eb 06                	jmp    f0105e83 <putop+0x47c>
		  else
		    *obufp++ = 'w';
f0105e7d:	c6 01 77             	movb   $0x77,(%ecx)
f0105e80:	83 c1 01             	add    $0x1,%ecx
		  used_prefixes |= (prefixes & PREFIX_DATA);
f0105e83:	0b 7d e0             	or     -0x20(%ebp),%edi
f0105e86:	e9 8e 00 00 00       	jmp    f0105f19 <putop+0x512>
		}
	    }
	  break;
	case 'X':
	  if (prefixes & PREFIX_DATA)
f0105e8b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105e8f:	74 08                	je     f0105e99 <putop+0x492>
	    *obufp++ = 'd';
f0105e91:	c6 01 64             	movb   $0x64,(%ecx)
f0105e94:	83 c1 01             	add    $0x1,%ecx
f0105e97:	eb 06                	jmp    f0105e9f <putop+0x498>
	  else
	    *obufp++ = 's';
f0105e99:	c6 01 73             	movb   $0x73,(%ecx)
f0105e9c:	83 c1 01             	add    $0x1,%ecx
          used_prefixes |= (prefixes & PREFIX_DATA);
f0105e9f:	0b 7d e0             	or     -0x20(%ebp),%edi
f0105ea2:	eb 75                	jmp    f0105f19 <putop+0x512>
	  break;
	case 'Y':
          if (intel_syntax)
f0105ea4:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105ea8:	75 6f                	jne    f0105f19 <putop+0x512>
            break;
	  if (rex & REX_MODE64)
f0105eaa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105eae:	74 69                	je     f0105f19 <putop+0x512>
	    {
	      USED_REX (REX_MODE64);
f0105eb0:	83 4d ec 48          	orl    $0x48,-0x14(%ebp)
	      *obufp++ = 'q';
f0105eb4:	c6 01 71             	movb   $0x71,(%ecx)
f0105eb7:	83 c1 01             	add    $0x1,%ecx
f0105eba:	eb 5d                	jmp    f0105f19 <putop+0x512>
	    }
	  break;
	  /* implicit operand size 'l' for i386 or 'q' for x86-64 */
	case 'W':
	  /* operand size flag for cwtl, cbtw */
	  USED_REX (0);
f0105ebc:	83 4d ec 40          	orl    $0x40,-0x14(%ebp)
	  if (rex)
f0105ec0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105ec4:	74 08                	je     f0105ece <putop+0x4c7>
	    *obufp++ = 'l';
f0105ec6:	c6 01 6c             	movb   $0x6c,(%ecx)
f0105ec9:	83 c1 01             	add    $0x1,%ecx
f0105ecc:	eb 14                	jmp    f0105ee2 <putop+0x4db>
	  else if (sizeflag & DFLAG)
f0105ece:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
f0105ed2:	74 08                	je     f0105edc <putop+0x4d5>
	    *obufp++ = 'w';
f0105ed4:	c6 01 77             	movb   $0x77,(%ecx)
f0105ed7:	83 c1 01             	add    $0x1,%ecx
f0105eda:	eb 06                	jmp    f0105ee2 <putop+0x4db>
	  else
	    *obufp++ = 'b';
f0105edc:	c6 01 62             	movb   $0x62,(%ecx)
f0105edf:	83 c1 01             	add    $0x1,%ecx
          if (intel_syntax)
f0105ee2:	80 7d eb 00          	cmpb   $0x0,-0x15(%ebp)
f0105ee6:	74 28                	je     f0105f10 <putop+0x509>
	    {
	      if (rex)
f0105ee8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105eec:	74 0a                	je     f0105ef8 <putop+0x4f1>
		{
		  *obufp++ = 'q';
f0105eee:	c6 01 71             	movb   $0x71,(%ecx)
		  *obufp++ = 'e';
f0105ef1:	c6 41 01 65          	movb   $0x65,0x1(%ecx)
f0105ef5:	83 c1 02             	add    $0x2,%ecx
		}
	      if (sizeflag & DFLAG)
f0105ef8:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
f0105efc:	74 0c                	je     f0105f0a <putop+0x503>
		{
		  *obufp++ = 'd';
f0105efe:	c6 01 64             	movb   $0x64,(%ecx)
		  *obufp++ = 'e';
f0105f01:	c6 41 01 65          	movb   $0x65,0x1(%ecx)
f0105f05:	83 c1 02             	add    $0x2,%ecx
f0105f08:	eb 06                	jmp    f0105f10 <putop+0x509>
		}
	      else
		{
		  *obufp++ = 'w';
f0105f0a:	c6 01 77             	movb   $0x77,(%ecx)
f0105f0d:	83 c1 01             	add    $0x1,%ecx
		}
	    }
	  if (!rex)
f0105f10:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105f14:	75 03                	jne    f0105f19 <putop+0x512>
	    used_prefixes |= (prefixes & PREFIX_DATA);
f0105f16:	0b 7d e0             	or     -0x20(%ebp),%edi
     int sizeflag;
{
  const char *p;
  int alt;

  for (p = template; *p; p++)
f0105f19:	83 c2 01             	add    $0x1,%edx
f0105f1c:	0f b6 1a             	movzbl (%edx),%ebx
f0105f1f:	84 db                	test   %bl,%bl
f0105f21:	0f 85 9a fb ff ff    	jne    f0105ac1 <putop+0xba>
f0105f27:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105f2a:	a3 6c 9e 1b f0       	mov    %eax,0xf01b9e6c
f0105f2f:	89 3d 70 9e 1b f0    	mov    %edi,0xf01b9e70
f0105f35:	89 0d e4 9e 1b f0    	mov    %ecx,0xf01b9ee4
	  if (!rex)
	    used_prefixes |= (prefixes & PREFIX_DATA);
	  break;
	}
    }
  *obufp = 0;
f0105f3b:	a1 e4 9e 1b f0       	mov    0xf01b9ee4,%eax
f0105f40:	c6 00 00             	movb   $0x0,(%eax)
f0105f43:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f48:	eb 14                	jmp    f0105f5e <putop+0x557>
	case 'O':
	  USED_REX (REX_MODE64);
	  if (rex & REX_MODE64)
	    *obufp++ = 'o';
	  else
	    *obufp++ = 'd';
f0105f4a:	c6 01 64             	movb   $0x64,(%ecx)
f0105f4d:	83 c1 01             	add    $0x1,%ecx
f0105f50:	eb c7                	jmp    f0105f19 <putop+0x512>
            break;
	  if ((prefixes & PREFIX_DATA)
	      || (rex & REX_MODE64)
	      || (sizeflag & SUFFIX_ALWAYS))
	    {
	      USED_REX (REX_MODE64);
f0105f52:	83 4d ec 48          	orl    $0x48,-0x14(%ebp)
	      if (rex & REX_MODE64)
		*obufp++ = 'q';
f0105f56:	c6 01 71             	movb   $0x71,(%ecx)
f0105f59:	83 c1 01             	add    $0x1,%ecx
f0105f5c:	eb bb                	jmp    f0105f19 <putop+0x512>
	  break;
	}
    }
  *obufp = 0;
  return 0;
}
f0105f5e:	83 c4 4c             	add    $0x4c,%esp
f0105f61:	5b                   	pop    %ebx
f0105f62:	5e                   	pop    %esi
f0105f63:	5f                   	pop    %edi
f0105f64:	5d                   	pop    %ebp
f0105f65:	c3                   	ret    

f0105f66 <SIMD_Fixup>:

static void
SIMD_Fixup (extrachar, sizeflag)
     int extrachar;
     int sizeflag;
{
f0105f66:	55                   	push   %ebp
f0105f67:	89 e5                	mov    %esp,%ebp
f0105f69:	83 ec 08             	sub    $0x8,%esp
  /* Change movlps/movhps to movhlps/movlhps for 2 register operand
     forms of these instructions.  */
  if (mod == 3)
f0105f6c:	83 3d 74 9f 1b f0 03 	cmpl   $0x3,0xf01b9f74
f0105f73:	75 35                	jne    f0105faa <SIMD_Fixup+0x44>
    {
      char *p = obuf + strlen (obuf);
f0105f75:	c7 04 24 80 9e 1b f0 	movl   $0xf01b9e80,(%esp)
f0105f7c:	e8 af 34 00 00       	call   f0109430 <strlen>
f0105f81:	8d 90 80 9e 1b f0    	lea    -0xfe46180(%eax),%edx
      *(p + 1) = '\0';
f0105f87:	c6 42 01 00          	movb   $0x0,0x1(%edx)
      *p       = *(p - 1);
f0105f8b:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
f0105f8f:	88 88 80 9e 1b f0    	mov    %cl,-0xfe46180(%eax)
      *(p - 1) = *(p - 2);
f0105f95:	0f b6 42 fe          	movzbl -0x2(%edx),%eax
f0105f99:	88 42 ff             	mov    %al,-0x1(%edx)
      *(p - 2) = *(p - 3);
f0105f9c:	0f b6 42 fd          	movzbl -0x3(%edx),%eax
f0105fa0:	88 42 fe             	mov    %al,-0x2(%edx)
      *(p - 3) = extrachar;
f0105fa3:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
f0105fa7:	88 42 fd             	mov    %al,-0x3(%edx)
    }
}
f0105faa:	c9                   	leave  
f0105fab:	c3                   	ret    

f0105fac <print_operand_value>:
  OP_E (bytemode, sizeflag);
}

static void
print_operand_value (char *buf, size_t bufsize, int hex, bfd_vma disp)
{
f0105fac:	55                   	push   %ebp
f0105fad:	89 e5                	mov    %esp,%ebp
f0105faf:	57                   	push   %edi
f0105fb0:	56                   	push   %esi
f0105fb1:	53                   	push   %ebx
f0105fb2:	83 ec 4c             	sub    $0x4c,%esp
f0105fb5:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0105fb8:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0105fbb:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fbe:	8b 55 0c             	mov    0xc(%ebp),%edx
  if (mode_64bit)
f0105fc1:	83 3d 60 9e 1b f0 00 	cmpl   $0x0,0xf01b9e60
f0105fc8:	0f 84 55 01 00 00    	je     f0106123 <print_operand_value+0x177>
    {
      if (hex)
f0105fce:	85 c9                	test   %ecx,%ecx
f0105fd0:	74 6d                	je     f010603f <print_operand_value+0x93>
	{
	  char tmp[30];
	  int i;
	  buf[0] = '0';
f0105fd2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0105fd5:	c6 01 30             	movb   $0x30,(%ecx)
	  buf[1] = 'x';
f0105fd8:	c6 41 01 78          	movb   $0x78,0x1(%ecx)
          snprintf_vma (tmp, sizeof(tmp), disp);
f0105fdc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105fe0:	89 54 24 10          	mov    %edx,0x10(%esp)
f0105fe4:	c7 44 24 08 b3 b6 10 	movl   $0xf010b6b3,0x8(%esp)
f0105feb:	f0 
f0105fec:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
f0105ff3:	00 
f0105ff4:	8d 45 d6             	lea    -0x2a(%ebp),%eax
f0105ff7:	89 04 24             	mov    %eax,(%esp)
f0105ffa:	e8 fb 32 00 00       	call   f01092fa <snprintf>
f0105fff:	ba 00 00 00 00       	mov    $0x0,%edx
          //add your code here
	  for (i = 0; tmp[i] == '0' && tmp[i + 1]; i++);
f0106004:	8d 4d d6             	lea    -0x2a(%ebp),%ecx
f0106007:	80 3c 0a 30          	cmpb   $0x30,(%edx,%ecx,1)
f010600b:	75 0d                	jne    f010601a <print_operand_value+0x6e>
f010600d:	8d 42 01             	lea    0x1(%edx),%eax
f0106010:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
f0106014:	74 04                	je     f010601a <print_operand_value+0x6e>
f0106016:	89 c2                	mov    %eax,%edx
f0106018:	eb ed                	jmp    f0106007 <print_operand_value+0x5b>
          pstrcpy (buf + 2, bufsize - 2, tmp + i);
f010601a:	8d 44 15 d6          	lea    -0x2a(%ebp,%edx,1),%eax
f010601e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106022:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0106025:	83 e8 02             	sub    $0x2,%eax
f0106028:	89 44 24 04          	mov    %eax,0x4(%esp)
f010602c:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010602f:	83 c0 02             	add    $0x2,%eax
f0106032:	89 04 24             	mov    %eax,(%esp)
f0106035:	e8 e3 34 00 00       	call   f010951d <pstrcpy>
f010603a:	e9 26 01 00 00       	jmp    f0106165 <print_operand_value+0x1b9>
          //add your code here
	}
      else
	{
	  bfd_signed_vma v = disp;
f010603f:	89 c6                	mov    %eax,%esi
f0106041:	89 d7                	mov    %edx,%edi
	  char tmp[30];
	  int i;
	  if (v < 0)
f0106043:	85 d2                	test   %edx,%edx
f0106045:	79 33                	jns    f010607a <print_operand_value+0xce>
	    {
	      *(buf++) = '-';
f0106047:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010604a:	c6 01 2d             	movb   $0x2d,(%ecx)
f010604d:	83 c1 01             	add    $0x1,%ecx
f0106050:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	      v = -disp;
f0106053:	f7 de                	neg    %esi
f0106055:	83 d7 00             	adc    $0x0,%edi
f0106058:	f7 df                	neg    %edi
	      /* Check for possible overflow on 0x8000000000000000.  */
	      if (v < 0)
f010605a:	85 ff                	test   %edi,%edi
f010605c:	79 1c                	jns    f010607a <print_operand_value+0xce>
		{
                  pstrcpy (buf, bufsize, "9223372036854775808");
f010605e:	c7 44 24 08 b7 b6 10 	movl   $0xf010b6b7,0x8(%esp)
f0106065:	f0 
f0106066:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0106069:	89 44 24 04          	mov    %eax,0x4(%esp)
f010606d:	89 0c 24             	mov    %ecx,(%esp)
f0106070:	e8 a8 34 00 00       	call   f010951d <pstrcpy>
f0106075:	e9 eb 00 00 00       	jmp    f0106165 <print_operand_value+0x1b9>
                  //add your code here
		  return;
		}
	    }
	  if (!v)
f010607a:	89 f9                	mov    %edi,%ecx
f010607c:	09 f1                	or     %esi,%ecx
f010607e:	75 1f                	jne    f010609f <print_operand_value+0xf3>
	    {
                pstrcpy (buf, bufsize, "0");
f0106080:	c7 44 24 08 85 ae 10 	movl   $0xf010ae85,0x8(%esp)
f0106087:	f0 
f0106088:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010608b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010608f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0106092:	89 0c 24             	mov    %ecx,(%esp)
f0106095:	e8 83 34 00 00       	call   f010951d <pstrcpy>
f010609a:	e9 c6 00 00 00       	jmp    f0106165 <print_operand_value+0x1b9>
                //add your code here
	      return;
	    }

	  i = 0;
	  tmp[29] = 0;
f010609f:	c6 45 f3 00          	movb   $0x0,-0xd(%ebp)
f01060a3:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
	  while (v)
	    {
	      tmp[28 - i] = (v % 10) + '0';
f01060aa:	8d 45 d6             	lea    -0x2a(%ebp),%eax
f01060ad:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01060b0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01060b3:	f7 db                	neg    %ebx
f01060b5:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f01060bc:	00 
f01060bd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01060c4:	00 
f01060c5:	89 34 24             	mov    %esi,(%esp)
f01060c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01060cc:	e8 6f 39 00 00       	call   f0109a40 <__moddi3>
f01060d1:	83 c0 30             	add    $0x30,%eax
f01060d4:	88 44 2b f2          	mov    %al,-0xe(%ebx,%ebp,1)
	      v /= 10;
f01060d8:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f01060df:	00 
f01060e0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01060e7:	00 
f01060e8:	89 34 24             	mov    %esi,(%esp)
f01060eb:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01060ef:	e8 cc 37 00 00       	call   f01098c0 <__divdi3>
f01060f4:	89 c6                	mov    %eax,%esi
f01060f6:	89 d7                	mov    %edx,%edi
	      i++;
f01060f8:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	      return;
	    }

	  i = 0;
	  tmp[29] = 0;
	  while (v)
f01060fc:	89 d1                	mov    %edx,%ecx
f01060fe:	09 c1                	or     %eax,%ecx
f0106100:	75 a8                	jne    f01060aa <print_operand_value+0xfe>
	    {
	      tmp[28 - i] = (v % 10) + '0';
	      v /= 10;
	      i++;
	    }
          pstrcpy (buf, bufsize, tmp + 29 - i);
f0106102:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0106105:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0106108:	83 c0 1d             	add    $0x1d,%eax
f010610b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010610f:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0106112:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106116:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0106119:	89 0c 24             	mov    %ecx,(%esp)
f010611c:	e8 fc 33 00 00       	call   f010951d <pstrcpy>
f0106121:	eb 42                	jmp    f0106165 <print_operand_value+0x1b9>
          //add your code here
	}
    }
  else
    {
      if (hex)
f0106123:	85 c9                	test   %ecx,%ecx
f0106125:	74 20                	je     f0106147 <print_operand_value+0x19b>
        snprintf (buf, bufsize, "0x%x", (unsigned int) disp);
f0106127:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010612b:	c7 44 24 08 19 b7 10 	movl   $0xf010b719,0x8(%esp)
f0106132:	f0 
f0106133:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0106136:	89 44 24 04          	mov    %eax,0x4(%esp)
f010613a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010613d:	89 0c 24             	mov    %ecx,(%esp)
f0106140:	e8 b5 31 00 00       	call   f01092fa <snprintf>
f0106145:	eb 1e                	jmp    f0106165 <print_operand_value+0x1b9>
      else
        snprintf (buf, bufsize, "%d", (int) disp);
f0106147:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010614b:	c7 44 24 08 bd 3a 11 	movl   $0xf0113abd,0x8(%esp)
f0106152:	f0 
f0106153:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0106156:	89 44 24 04          	mov    %eax,0x4(%esp)
f010615a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010615d:	89 0c 24             	mov    %ecx,(%esp)
f0106160:	e8 95 31 00 00       	call   f01092fa <snprintf>
    }
}
f0106165:	83 c4 4c             	add    $0x4c,%esp
f0106168:	5b                   	pop    %ebx
f0106169:	5e                   	pop    %esi
f010616a:	5f                   	pop    %edi
f010616b:	5d                   	pop    %ebp
f010616c:	c3                   	ret    

f010616d <oappend>:
}

static void
oappend (s)
     const char *s;
{
f010616d:	55                   	push   %ebp
f010616e:	89 e5                	mov    %esp,%ebp
f0106170:	53                   	push   %ebx
f0106171:	83 ec 14             	sub    $0x14,%esp
f0106174:	89 c3                	mov    %eax,%ebx
  strcpy (obufp, s);
f0106176:	89 44 24 04          	mov    %eax,0x4(%esp)
f010617a:	a1 e4 9e 1b f0       	mov    0xf01b9ee4,%eax
f010617f:	89 04 24             	mov    %eax,(%esp)
f0106182:	e8 fa 32 00 00       	call   f0109481 <strcpy>
  obufp += strlen (s);
f0106187:	89 1c 24             	mov    %ebx,(%esp)
f010618a:	e8 a1 32 00 00       	call   f0109430 <strlen>
f010618f:	01 05 e4 9e 1b f0    	add    %eax,0xf01b9ee4
}
f0106195:	83 c4 14             	add    $0x14,%esp
f0106198:	5b                   	pop    %ebx
f0106199:	5d                   	pop    %ebp
f010619a:	c3                   	ret    

f010619b <BadOp>:
    }
}

static void
BadOp (void)
{
f010619b:	55                   	push   %ebp
f010619c:	89 e5                	mov    %esp,%ebp
f010619e:	83 ec 08             	sub    $0x8,%esp
  /* Throw away prefixes and 1st. opcode byte.  */
  codep = insn_codep + 1;
f01061a1:	a1 68 9f 1b f0       	mov    0xf01b9f68,%eax
f01061a6:	83 c0 01             	add    $0x1,%eax
f01061a9:	a3 6c 9f 1b f0       	mov    %eax,0xf01b9f6c
  oappend ("(bad)");
f01061ae:	b8 cb b6 10 f0       	mov    $0xf010b6cb,%eax
f01061b3:	e8 b5 ff ff ff       	call   f010616d <oappend>
}
f01061b8:	c9                   	leave  
f01061b9:	c3                   	ret    

f01061ba <OP_SIMD_Suffix>:

static void
OP_SIMD_Suffix (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f01061ba:	55                   	push   %ebp
f01061bb:	89 e5                	mov    %esp,%ebp
f01061bd:	83 ec 28             	sub    $0x28,%esp
f01061c0:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01061c3:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01061c6:	89 7d fc             	mov    %edi,-0x4(%ebp)
  unsigned int cmp_type;

  FETCH_DATA (the_info, codep + 1);
f01061c9:	8b 15 6c 9f 1b f0    	mov    0xf01b9f6c,%edx
f01061cf:	83 c2 01             	add    $0x1,%edx
f01061d2:	8b 0d 70 9f 1b f0    	mov    0xf01b9f70,%ecx
f01061d8:	8b 41 20             	mov    0x20(%ecx),%eax
f01061db:	3b 10                	cmp    (%eax),%edx
f01061dd:	76 07                	jbe    f01061e6 <OP_SIMD_Suffix+0x2c>
f01061df:	89 c8                	mov    %ecx,%eax
f01061e1:	e8 0a f4 ff ff       	call   f01055f0 <fetch_data>
  obufp = obuf + strlen (obuf);
f01061e6:	c7 04 24 80 9e 1b f0 	movl   $0xf01b9e80,(%esp)
f01061ed:	e8 3e 32 00 00       	call   f0109430 <strlen>
f01061f2:	05 80 9e 1b f0       	add    $0xf01b9e80,%eax
f01061f7:	a3 e4 9e 1b f0       	mov    %eax,0xf01b9ee4
  cmp_type = *codep++ & 0xff;
f01061fc:	a1 6c 9f 1b f0       	mov    0xf01b9f6c,%eax
f0106201:	0f b6 38             	movzbl (%eax),%edi
f0106204:	83 c0 01             	add    $0x1,%eax
f0106207:	a3 6c 9f 1b f0       	mov    %eax,0xf01b9f6c
  if (cmp_type < 8)
f010620c:	83 ff 07             	cmp    $0x7,%edi
f010620f:	0f 87 b7 00 00 00    	ja     f01062cc <OP_SIMD_Suffix+0x112>
    {
      char suffix1 = 'p', suffix2 = 's';
      used_prefixes |= (prefixes & PREFIX_REPZ);
f0106215:	8b 15 64 9e 1b f0    	mov    0xf01b9e64,%edx
f010621b:	89 d0                	mov    %edx,%eax
f010621d:	83 e0 01             	and    $0x1,%eax
f0106220:	89 c3                	mov    %eax,%ebx
f0106222:	0b 1d 70 9e 1b f0    	or     0xf01b9e70,%ebx
f0106228:	89 1d 70 9e 1b f0    	mov    %ebx,0xf01b9e70
      if (prefixes & PREFIX_REPZ)
f010622e:	be 73 00 00 00       	mov    $0x73,%esi
f0106233:	b9 73 00 00 00       	mov    $0x73,%ecx
f0106238:	85 c0                	test   %eax,%eax
f010623a:	75 3f                	jne    f010627b <OP_SIMD_Suffix+0xc1>
	suffix1 = 's';
      else
	{
	  used_prefixes |= (prefixes & PREFIX_DATA);
f010623c:	89 d0                	mov    %edx,%eax
f010623e:	25 00 02 00 00       	and    $0x200,%eax
f0106243:	09 c3                	or     %eax,%ebx
f0106245:	89 1d 70 9e 1b f0    	mov    %ebx,0xf01b9e70
	  if (prefixes & PREFIX_DATA)
f010624b:	be 70 00 00 00       	mov    $0x70,%esi
f0106250:	b9 64 00 00 00       	mov    $0x64,%ecx
f0106255:	85 c0                	test   %eax,%eax
f0106257:	75 22                	jne    f010627b <OP_SIMD_Suffix+0xc1>
	    suffix2 = 'd';
	  else
	    {
	      used_prefixes |= (prefixes & PREFIX_REPNZ);
f0106259:	83 e2 02             	and    $0x2,%edx
f010625c:	89 d8                	mov    %ebx,%eax
f010625e:	09 d0                	or     %edx,%eax
f0106260:	a3 70 9e 1b f0       	mov    %eax,0xf01b9e70
	      if (prefixes & PREFIX_REPNZ)
f0106265:	83 fa 01             	cmp    $0x1,%edx
f0106268:	19 f6                	sbb    %esi,%esi
f010626a:	83 e6 fd             	and    $0xfffffffd,%esi
f010626d:	83 c6 73             	add    $0x73,%esi
f0106270:	83 fa 01             	cmp    $0x1,%edx
f0106273:	19 c9                	sbb    %ecx,%ecx
f0106275:	83 e1 0f             	and    $0xf,%ecx
f0106278:	83 c1 64             	add    $0x64,%ecx
		suffix1 = 's', suffix2 = 'd';
	    }
	}
      snprintf (scratchbuf, sizeof(scratchbuf), "cmp%s%c%c",
f010627b:	0f be c1             	movsbl %cl,%eax
f010627e:	89 44 24 14          	mov    %eax,0x14(%esp)
f0106282:	89 f2                	mov    %esi,%edx
f0106284:	0f be c2             	movsbl %dl,%eax
f0106287:	89 44 24 10          	mov    %eax,0x10(%esp)
f010628b:	8b 04 bd 20 2d 11 f0 	mov    -0xfeed2e0(,%edi,4),%eax
f0106292:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106296:	c7 44 24 08 d1 b6 10 	movl   $0xf010b6d1,0x8(%esp)
f010629d:	f0 
f010629e:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f01062a5:	00 
f01062a6:	c7 04 24 00 9f 1b f0 	movl   $0xf01b9f00,(%esp)
f01062ad:	e8 48 30 00 00       	call   f01092fa <snprintf>
                simd_cmp_op[cmp_type], suffix1, suffix2);
      used_prefixes |= (prefixes & PREFIX_REPZ);
f01062b2:	a1 64 9e 1b f0       	mov    0xf01b9e64,%eax
f01062b7:	83 e0 01             	and    $0x1,%eax
f01062ba:	09 05 70 9e 1b f0    	or     %eax,0xf01b9e70
      oappend (scratchbuf);
f01062c0:	b8 00 9f 1b f0       	mov    $0xf01b9f00,%eax
f01062c5:	e8 a3 fe ff ff       	call   f010616d <oappend>
f01062ca:	eb 13                	jmp    f01062df <OP_SIMD_Suffix+0x125>
    }
  else
    {
      /* We have a bad extension byte.  Clean up.  */
      op1out[0] = '\0';
f01062cc:	c6 05 a0 9f 1b f0 00 	movb   $0x0,0xf01b9fa0
      op2out[0] = '\0';
f01062d3:	c6 05 20 a0 1b f0 00 	movb   $0x0,0xf01ba020
      BadOp ();
f01062da:	e8 bc fe ff ff       	call   f010619b <BadOp>
    }
}
f01062df:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01062e2:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01062e5:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01062e8:	89 ec                	mov    %ebp,%esp
f01062ea:	5d                   	pop    %ebp
f01062eb:	c3                   	ret    

f01062ec <OP_3DNowSuffix>:

static void
OP_3DNowSuffix (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f01062ec:	55                   	push   %ebp
f01062ed:	89 e5                	mov    %esp,%ebp
f01062ef:	83 ec 08             	sub    $0x8,%esp
  const char *mnemonic;

  FETCH_DATA (the_info, codep + 1);
f01062f2:	8b 15 6c 9f 1b f0    	mov    0xf01b9f6c,%edx
f01062f8:	83 c2 01             	add    $0x1,%edx
f01062fb:	8b 0d 70 9f 1b f0    	mov    0xf01b9f70,%ecx
f0106301:	8b 41 20             	mov    0x20(%ecx),%eax
f0106304:	3b 10                	cmp    (%eax),%edx
f0106306:	76 07                	jbe    f010630f <OP_3DNowSuffix+0x23>
f0106308:	89 c8                	mov    %ecx,%eax
f010630a:	e8 e1 f2 ff ff       	call   f01055f0 <fetch_data>
  /* AMD 3DNow! instructions are specified by an opcode suffix in the
     place where an 8-bit immediate would normally go.  ie. the last
     byte of the instruction.  */
  obufp = obuf + strlen (obuf);
f010630f:	c7 04 24 80 9e 1b f0 	movl   $0xf01b9e80,(%esp)
f0106316:	e8 15 31 00 00       	call   f0109430 <strlen>
f010631b:	05 80 9e 1b f0       	add    $0xf01b9e80,%eax
f0106320:	a3 e4 9e 1b f0       	mov    %eax,0xf01b9ee4
  mnemonic = Suffix3DNow[*codep++ & 0xff];
f0106325:	a1 6c 9f 1b f0       	mov    0xf01b9f6c,%eax
f010632a:	0f b6 10             	movzbl (%eax),%edx
f010632d:	8b 14 95 40 2d 11 f0 	mov    -0xfeed2c0(,%edx,4),%edx
f0106334:	83 c0 01             	add    $0x1,%eax
f0106337:	a3 6c 9f 1b f0       	mov    %eax,0xf01b9f6c
  if (mnemonic)
f010633c:	85 d2                	test   %edx,%edx
f010633e:	74 09                	je     f0106349 <OP_3DNowSuffix+0x5d>
    oappend (mnemonic);
f0106340:	89 d0                	mov    %edx,%eax
f0106342:	e8 26 fe ff ff       	call   f010616d <oappend>
f0106347:	eb 13                	jmp    f010635c <OP_3DNowSuffix+0x70>
    {
      /* Since a variable sized modrm/sib chunk is between the start
	 of the opcode (0x0f0f) and the opcode suffix, we need to do
	 all the modrm processing first, and don't know until now that
	 we have a bad opcode.  This necessitates some cleaning up.  */
      op1out[0] = '\0';
f0106349:	c6 05 a0 9f 1b f0 00 	movb   $0x0,0xf01b9fa0
      op2out[0] = '\0';
f0106350:	c6 05 20 a0 1b f0 00 	movb   $0x0,0xf01ba020
      BadOp ();
f0106357:	e8 3f fe ff ff       	call   f010619b <BadOp>
    }
}
f010635c:	c9                   	leave  
f010635d:	c3                   	ret    

f010635e <OP_XMM>:

static void
OP_XMM (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f010635e:	55                   	push   %ebp
f010635f:	89 e5                	mov    %esp,%ebp
f0106361:	83 ec 18             	sub    $0x18,%esp
  int add = 0;
  USED_REX (REX_EXTX);
f0106364:	b8 00 00 00 00       	mov    $0x0,%eax
f0106369:	f6 05 68 9e 1b f0 04 	testb  $0x4,0xf01b9e68
f0106370:	74 09                	je     f010637b <OP_XMM+0x1d>
f0106372:	83 0d 6c 9e 1b f0 44 	orl    $0x44,0xf01b9e6c
f0106379:	b0 08                	mov    $0x8,%al
  if (rex & REX_EXTX)
    add = 8;
  snprintf (scratchbuf, sizeof(scratchbuf), "%%xmm%d", reg + add);
f010637b:	03 05 7c 9f 1b f0    	add    0xf01b9f7c,%eax
f0106381:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106385:	c7 44 24 08 db b6 10 	movl   $0xf010b6db,0x8(%esp)
f010638c:	f0 
f010638d:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0106394:	00 
f0106395:	c7 04 24 00 9f 1b f0 	movl   $0xf01b9f00,(%esp)
f010639c:	e8 59 2f 00 00       	call   f01092fa <snprintf>
  oappend (scratchbuf + intel_syntax);
f01063a1:	0f be 05 50 a1 1b f0 	movsbl 0xf01ba150,%eax
f01063a8:	05 00 9f 1b f0       	add    $0xf01b9f00,%eax
f01063ad:	e8 bb fd ff ff       	call   f010616d <oappend>
}
f01063b2:	c9                   	leave  
f01063b3:	c3                   	ret    

f01063b4 <OP_MMX>:

static void
OP_MMX (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f01063b4:	55                   	push   %ebp
f01063b5:	89 e5                	mov    %esp,%ebp
f01063b7:	83 ec 18             	sub    $0x18,%esp
  int add = 0;
  USED_REX (REX_EXTX);
f01063ba:	ba 00 00 00 00       	mov    $0x0,%edx
f01063bf:	f6 05 68 9e 1b f0 04 	testb  $0x4,0xf01b9e68
f01063c6:	74 09                	je     f01063d1 <OP_MMX+0x1d>
f01063c8:	83 0d 6c 9e 1b f0 44 	orl    $0x44,0xf01b9e6c
f01063cf:	b2 08                	mov    $0x8,%dl
  if (rex & REX_EXTX)
    add = 8;
  used_prefixes |= (prefixes & PREFIX_DATA);
f01063d1:	a1 64 9e 1b f0       	mov    0xf01b9e64,%eax
f01063d6:	25 00 02 00 00       	and    $0x200,%eax
f01063db:	09 05 70 9e 1b f0    	or     %eax,0xf01b9e70
  if (prefixes & PREFIX_DATA)
f01063e1:	85 c0                	test   %eax,%eax
f01063e3:	74 2a                	je     f010640f <OP_MMX+0x5b>
    snprintf (scratchbuf, sizeof(scratchbuf), "%%xmm%d", reg + add);
f01063e5:	89 d0                	mov    %edx,%eax
f01063e7:	03 05 7c 9f 1b f0    	add    0xf01b9f7c,%eax
f01063ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01063f1:	c7 44 24 08 db b6 10 	movl   $0xf010b6db,0x8(%esp)
f01063f8:	f0 
f01063f9:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0106400:	00 
f0106401:	c7 04 24 00 9f 1b f0 	movl   $0xf01b9f00,(%esp)
f0106408:	e8 ed 2e 00 00       	call   f01092fa <snprintf>
f010640d:	eb 28                	jmp    f0106437 <OP_MMX+0x83>
  else
    snprintf (scratchbuf, sizeof(scratchbuf), "%%mm%d", reg + add);
f010640f:	89 d0                	mov    %edx,%eax
f0106411:	03 05 7c 9f 1b f0    	add    0xf01b9f7c,%eax
f0106417:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010641b:	c7 44 24 08 e3 b6 10 	movl   $0xf010b6e3,0x8(%esp)
f0106422:	f0 
f0106423:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f010642a:	00 
f010642b:	c7 04 24 00 9f 1b f0 	movl   $0xf01b9f00,(%esp)
f0106432:	e8 c3 2e 00 00       	call   f01092fa <snprintf>
  oappend (scratchbuf + intel_syntax);
f0106437:	0f be 05 50 a1 1b f0 	movsbl 0xf01ba150,%eax
f010643e:	05 00 9f 1b f0       	add    $0xf01b9f00,%eax
f0106443:	e8 25 fd ff ff       	call   f010616d <oappend>
}
f0106448:	c9                   	leave  
f0106449:	c3                   	ret    

f010644a <OP_T>:

static void
OP_T (dummy, sizeflag)
     int dummy;
     int sizeflag;
{
f010644a:	55                   	push   %ebp
f010644b:	89 e5                	mov    %esp,%ebp
f010644d:	83 ec 18             	sub    $0x18,%esp
  snprintf (scratchbuf, sizeof(scratchbuf), "%%tr%d", reg);
f0106450:	a1 7c 9f 1b f0       	mov    0xf01b9f7c,%eax
f0106455:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106459:	c7 44 24 08 ea b6 10 	movl   $0xf010b6ea,0x8(%esp)
f0106460:	f0 
f0106461:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0106468:	00 
f0106469:	c7 04 24 00 9f 1b f0 	movl   $0xf01b9f00,(%esp)
f0106470:	e8 85 2e 00 00       	call   f01092fa <snprintf>
  oappend (scratchbuf + intel_syntax);
f0106475:	0f be 05 50 a1 1b f0 	movsbl 0xf01ba150,%eax
f010647c:	05 00 9f 1b f0       	add    $0xf01b9f00,%eax
f0106481:	e8 e7 fc ff ff       	call   f010616d <oappend>
}
f0106486:	c9                   	leave  
f0106487:	c3                   	ret    

f0106488 <OP_D>:

static void
OP_D (dummy, sizeflag)
     int dummy;
     int sizeflag;
{
f0106488:	55                   	push   %ebp
f0106489:	89 e5                	mov    %esp,%ebp
f010648b:	83 ec 18             	sub    $0x18,%esp
  int add = 0;
  USED_REX (REX_EXTX);
f010648e:	b8 00 00 00 00       	mov    $0x0,%eax
f0106493:	f6 05 68 9e 1b f0 04 	testb  $0x4,0xf01b9e68
f010649a:	74 09                	je     f01064a5 <OP_D+0x1d>
f010649c:	83 0d 6c 9e 1b f0 44 	orl    $0x44,0xf01b9e6c
f01064a3:	b0 08                	mov    $0x8,%al
  if (rex & REX_EXTX)
    add = 8;
  if (intel_syntax)
f01064a5:	80 3d 50 a1 1b f0 00 	cmpb   $0x0,0xf01ba150
f01064ac:	74 28                	je     f01064d6 <OP_D+0x4e>
    snprintf (scratchbuf, sizeof(scratchbuf), "db%d", reg + add);
f01064ae:	03 05 7c 9f 1b f0    	add    0xf01b9f7c,%eax
f01064b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01064b8:	c7 44 24 08 f3 b6 10 	movl   $0xf010b6f3,0x8(%esp)
f01064bf:	f0 
f01064c0:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f01064c7:	00 
f01064c8:	c7 04 24 00 9f 1b f0 	movl   $0xf01b9f00,(%esp)
f01064cf:	e8 26 2e 00 00       	call   f01092fa <snprintf>
f01064d4:	eb 26                	jmp    f01064fc <OP_D+0x74>
  else
    snprintf (scratchbuf, sizeof(scratchbuf), "%%db%d", reg + add);
f01064d6:	03 05 7c 9f 1b f0    	add    0xf01b9f7c,%eax
f01064dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01064e0:	c7 44 24 08 f1 b6 10 	movl   $0xf010b6f1,0x8(%esp)
f01064e7:	f0 
f01064e8:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f01064ef:	00 
f01064f0:	c7 04 24 00 9f 1b f0 	movl   $0xf01b9f00,(%esp)
f01064f7:	e8 fe 2d 00 00       	call   f01092fa <snprintf>
  oappend (scratchbuf);
f01064fc:	b8 00 9f 1b f0       	mov    $0xf01b9f00,%eax
f0106501:	e8 67 fc ff ff       	call   f010616d <oappend>
}
f0106506:	c9                   	leave  
f0106507:	c3                   	ret    

f0106508 <OP_C>:

static void
OP_C (dummy, sizeflag)
     int dummy;
     int sizeflag;
{
f0106508:	55                   	push   %ebp
f0106509:	89 e5                	mov    %esp,%ebp
f010650b:	83 ec 18             	sub    $0x18,%esp
  int add = 0;
  USED_REX (REX_EXTX);
f010650e:	b8 00 00 00 00       	mov    $0x0,%eax
f0106513:	f6 05 68 9e 1b f0 04 	testb  $0x4,0xf01b9e68
f010651a:	74 09                	je     f0106525 <OP_C+0x1d>
f010651c:	83 0d 6c 9e 1b f0 44 	orl    $0x44,0xf01b9e6c
f0106523:	b0 08                	mov    $0x8,%al
  if (rex & REX_EXTX)
    add = 8;
  snprintf (scratchbuf, sizeof(scratchbuf), "%%cr%d", reg + add);
f0106525:	03 05 7c 9f 1b f0    	add    0xf01b9f7c,%eax
f010652b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010652f:	c7 44 24 08 f8 b6 10 	movl   $0xf010b6f8,0x8(%esp)
f0106536:	f0 
f0106537:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f010653e:	00 
f010653f:	c7 04 24 00 9f 1b f0 	movl   $0xf01b9f00,(%esp)
f0106546:	e8 af 2d 00 00       	call   f01092fa <snprintf>
  oappend (scratchbuf + intel_syntax);
f010654b:	0f be 05 50 a1 1b f0 	movsbl 0xf01ba150,%eax
f0106552:	05 00 9f 1b f0       	add    $0xf01b9f00,%eax
f0106557:	e8 11 fc ff ff       	call   f010616d <oappend>
}
f010655c:	c9                   	leave  
f010655d:	c3                   	ret    

f010655e <ptr_reg>:

static void
ptr_reg (code, sizeflag)
     int code;
     int sizeflag;
{
f010655e:	55                   	push   %ebp
f010655f:	89 e5                	mov    %esp,%ebp
f0106561:	56                   	push   %esi
f0106562:	53                   	push   %ebx
f0106563:	89 c3                	mov    %eax,%ebx
f0106565:	89 d6                	mov    %edx,%esi
  const char *s;
  if (intel_syntax)
f0106567:	80 3d 50 a1 1b f0 00 	cmpb   $0x0,0xf01ba150
f010656e:	74 0c                	je     f010657c <ptr_reg+0x1e>
    oappend ("[");
f0106570:	b8 ff b6 10 f0       	mov    $0xf010b6ff,%eax
f0106575:	e8 f3 fb ff ff       	call   f010616d <oappend>
f010657a:	eb 0a                	jmp    f0106586 <ptr_reg+0x28>
  else
    oappend ("(");
f010657c:	b8 01 b7 10 f0       	mov    $0xf010b701,%eax
f0106581:	e8 e7 fb ff ff       	call   f010616d <oappend>

  USED_REX (REX_MODE64);
f0106586:	f6 05 68 9e 1b f0 08 	testb  $0x8,0xf01b9e68
f010658d:	74 6b                	je     f01065fa <ptr_reg+0x9c>
f010658f:	83 0d 6c 9e 1b f0 48 	orl    $0x48,0xf01b9e6c
  if (rex & REX_MODE64)
    {
      if (!(sizeflag & AFLAG))
f0106596:	f7 c6 02 00 00 00    	test   $0x2,%esi
f010659c:	75 0e                	jne    f01065ac <ptr_reg+0x4e>
        s = names32[code - eAX_reg];
f010659e:	a1 88 9f 1b f0       	mov    0xf01b9f88,%eax
f01065a3:	8b 84 98 50 fe ff ff 	mov    -0x1b0(%eax,%ebx,4),%eax
f01065aa:	eb 28                	jmp    f01065d4 <ptr_reg+0x76>
      else
        s = names64[code - eAX_reg];
f01065ac:	a1 84 9f 1b f0       	mov    0xf01b9f84,%eax
f01065b1:	8b 84 98 50 fe ff ff 	mov    -0x1b0(%eax,%ebx,4),%eax
f01065b8:	eb 1a                	jmp    f01065d4 <ptr_reg+0x76>
    }
  else if (sizeflag & AFLAG)
    s = names32[code - eAX_reg];
f01065ba:	a1 88 9f 1b f0       	mov    0xf01b9f88,%eax
f01065bf:	8b 84 98 50 fe ff ff 	mov    -0x1b0(%eax,%ebx,4),%eax
f01065c6:	eb 0c                	jmp    f01065d4 <ptr_reg+0x76>
  else
    s = names16[code - eAX_reg];
f01065c8:	a1 8c 9f 1b f0       	mov    0xf01b9f8c,%eax
f01065cd:	8b 84 98 50 fe ff ff 	mov    -0x1b0(%eax,%ebx,4),%eax
  oappend (s);
f01065d4:	e8 94 fb ff ff       	call   f010616d <oappend>
  if (intel_syntax)
f01065d9:	80 3d 50 a1 1b f0 00 	cmpb   $0x0,0xf01ba150
f01065e0:	74 0c                	je     f01065ee <ptr_reg+0x90>
    oappend ("]");
f01065e2:	b8 4c b0 10 f0       	mov    $0xf010b04c,%eax
f01065e7:	e8 81 fb ff ff       	call   f010616d <oappend>
f01065ec:	eb 16                	jmp    f0106604 <ptr_reg+0xa6>
  else
    oappend (")");
f01065ee:	b8 05 b3 10 f0       	mov    $0xf010b305,%eax
f01065f3:	e8 75 fb ff ff       	call   f010616d <oappend>
f01065f8:	eb 0a                	jmp    f0106604 <ptr_reg+0xa6>
      if (!(sizeflag & AFLAG))
        s = names32[code - eAX_reg];
      else
        s = names64[code - eAX_reg];
    }
  else if (sizeflag & AFLAG)
f01065fa:	f7 c6 02 00 00 00    	test   $0x2,%esi
f0106600:	75 b8                	jne    f01065ba <ptr_reg+0x5c>
f0106602:	eb c4                	jmp    f01065c8 <ptr_reg+0x6a>
  oappend (s);
  if (intel_syntax)
    oappend ("]");
  else
    oappend (")");
}
f0106604:	5b                   	pop    %ebx
f0106605:	5e                   	pop    %esi
f0106606:	5d                   	pop    %ebp
f0106607:	c3                   	ret    

f0106608 <OP_ESreg>:

static void
OP_ESreg (code, sizeflag)
     int code;
     int sizeflag;
{
f0106608:	55                   	push   %ebp
f0106609:	89 e5                	mov    %esp,%ebp
f010660b:	83 ec 08             	sub    $0x8,%esp
  oappend ("%es:" + intel_syntax);
f010660e:	0f be 05 50 a1 1b f0 	movsbl 0xf01ba150,%eax
f0106615:	05 03 b7 10 f0       	add    $0xf010b703,%eax
f010661a:	e8 4e fb ff ff       	call   f010616d <oappend>
  ptr_reg (code, sizeflag);
f010661f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106622:	8b 45 08             	mov    0x8(%ebp),%eax
f0106625:	e8 34 ff ff ff       	call   f010655e <ptr_reg>
}
f010662a:	c9                   	leave  
f010662b:	c3                   	ret    

f010662c <OP_DIR>:

static void
OP_DIR (dummy, sizeflag)
     int dummy;
     int sizeflag;
{
f010662c:	55                   	push   %ebp
f010662d:	89 e5                	mov    %esp,%ebp
f010662f:	53                   	push   %ebx
f0106630:	83 ec 14             	sub    $0x14,%esp
  int seg, offset;

  if (sizeflag & DFLAG)
f0106633:	f6 45 0c 01          	testb  $0x1,0xc(%ebp)
f0106637:	74 10                	je     f0106649 <OP_DIR+0x1d>
    {
      offset = get32 ();
f0106639:	e8 14 f2 ff ff       	call   f0105852 <get32>
f010663e:	89 c3                	mov    %eax,%ebx
      seg = get16 ();
f0106640:	e8 0c f3 ff ff       	call   f0105951 <get16>
f0106645:	89 c2                	mov    %eax,%edx
f0106647:	eb 0e                	jmp    f0106657 <OP_DIR+0x2b>
    }
  else
    {
      offset = get16 ();
f0106649:	e8 03 f3 ff ff       	call   f0105951 <get16>
f010664e:	89 c3                	mov    %eax,%ebx
      seg = get16 ();
f0106650:	e8 fc f2 ff ff       	call   f0105951 <get16>
f0106655:	89 c2                	mov    %eax,%edx
    }
  used_prefixes |= (prefixes & PREFIX_DATA);
f0106657:	a1 64 9e 1b f0       	mov    0xf01b9e64,%eax
f010665c:	25 00 02 00 00       	and    $0x200,%eax
f0106661:	09 05 70 9e 1b f0    	or     %eax,0xf01b9e70
  if (intel_syntax)
f0106667:	80 3d 50 a1 1b f0 00 	cmpb   $0x0,0xf01ba150
f010666e:	74 26                	je     f0106696 <OP_DIR+0x6a>
    snprintf (scratchbuf, sizeof(scratchbuf), "0x%x,0x%x", seg, offset);
f0106670:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106674:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106678:	c7 44 24 08 08 b7 10 	movl   $0xf010b708,0x8(%esp)
f010667f:	f0 
f0106680:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0106687:	00 
f0106688:	c7 04 24 00 9f 1b f0 	movl   $0xf01b9f00,(%esp)
f010668f:	e8 66 2c 00 00       	call   f01092fa <snprintf>
f0106694:	eb 24                	jmp    f01066ba <OP_DIR+0x8e>
  else
    snprintf (scratchbuf, sizeof(scratchbuf), "$0x%x,$0x%x", seg, offset);
f0106696:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f010669a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010669e:	c7 44 24 08 12 b7 10 	movl   $0xf010b712,0x8(%esp)
f01066a5:	f0 
f01066a6:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f01066ad:	00 
f01066ae:	c7 04 24 00 9f 1b f0 	movl   $0xf01b9f00,(%esp)
f01066b5:	e8 40 2c 00 00       	call   f01092fa <snprintf>
  oappend (scratchbuf);
f01066ba:	b8 00 9f 1b f0       	mov    $0xf01b9f00,%eax
f01066bf:	e8 a9 fa ff ff       	call   f010616d <oappend>
}
f01066c4:	83 c4 14             	add    $0x14,%esp
f01066c7:	5b                   	pop    %ebx
f01066c8:	5d                   	pop    %ebp
f01066c9:	c3                   	ret    

f01066ca <OP_SEG>:

static void
OP_SEG (dummy, sizeflag)
     int dummy;
     int sizeflag;
{
f01066ca:	55                   	push   %ebp
f01066cb:	89 e5                	mov    %esp,%ebp
f01066cd:	83 ec 08             	sub    $0x8,%esp
  oappend (names_seg[reg]);
f01066d0:	a1 7c 9f 1b f0       	mov    0xf01b9f7c,%eax
f01066d5:	8b 15 98 9f 1b f0    	mov    0xf01b9f98,%edx
f01066db:	8b 04 82             	mov    (%edx,%eax,4),%eax
f01066de:	e8 8a fa ff ff       	call   f010616d <oappend>
}
f01066e3:	c9                   	leave  
f01066e4:	c3                   	ret    

f01066e5 <OP_J>:

static void
OP_J (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f01066e5:	55                   	push   %ebp
f01066e6:	89 e5                	mov    %esp,%ebp
f01066e8:	56                   	push   %esi
f01066e9:	53                   	push   %ebx
f01066ea:	83 ec 10             	sub    $0x10,%esp
f01066ed:	8b 45 08             	mov    0x8(%ebp),%eax
  bfd_vma disp;
  bfd_vma mask = -1;

  switch (bytemode)
f01066f0:	83 f8 01             	cmp    $0x1,%eax
f01066f3:	74 0b                	je     f0106700 <OP_J+0x1b>
f01066f5:	83 f8 02             	cmp    $0x2,%eax
f01066f8:	0f 85 8c 00 00 00    	jne    f010678a <OP_J+0xa5>
f01066fe:	eb 4f                	jmp    f010674f <OP_J+0x6a>
    {
    case b_mode:
      FETCH_DATA (the_info, codep + 1);
f0106700:	8b 15 6c 9f 1b f0    	mov    0xf01b9f6c,%edx
f0106706:	83 c2 01             	add    $0x1,%edx
f0106709:	8b 0d 70 9f 1b f0    	mov    0xf01b9f70,%ecx
f010670f:	8b 41 20             	mov    0x20(%ecx),%eax
f0106712:	3b 10                	cmp    (%eax),%edx
f0106714:	76 07                	jbe    f010671d <OP_J+0x38>
f0106716:	89 c8                	mov    %ecx,%eax
f0106718:	e8 d3 ee ff ff       	call   f01055f0 <fetch_data>
      disp = *codep++;
f010671d:	a1 6c 9f 1b f0       	mov    0xf01b9f6c,%eax
f0106722:	0f b6 08             	movzbl (%eax),%ecx
f0106725:	bb 00 00 00 00       	mov    $0x0,%ebx
f010672a:	83 c0 01             	add    $0x1,%eax
f010672d:	a3 6c 9f 1b f0       	mov    %eax,0xf01b9f6c
	  mask = 0xffff;
	}
      break;
    default:
      oappend (INTERNAL_DISASSEMBLER_ERROR);
      return;
f0106732:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
f0106739:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  switch (bytemode)
    {
    case b_mode:
      FETCH_DATA (the_info, codep + 1);
      disp = *codep++;
      if ((disp & 0x80) != 0)
f0106740:	84 c9                	test   %cl,%cl
f0106742:	79 52                	jns    f0106796 <OP_J+0xb1>
	disp -= 0x100;
f0106744:	81 c1 00 ff ff ff    	add    $0xffffff00,%ecx
f010674a:	83 d3 ff             	adc    $0xffffffff,%ebx
f010674d:	eb 47                	jmp    f0106796 <OP_J+0xb1>
      break;
    case v_mode:
      if (sizeflag & DFLAG)
f010674f:	f6 45 0c 01          	testb  $0x1,0xc(%ebp)
f0106753:	74 19                	je     f010676e <OP_J+0x89>
	disp = get32s ();
f0106755:	e8 71 f1 ff ff       	call   f01058cb <get32s>
f010675a:	89 c1                	mov    %eax,%ecx
f010675c:	89 d3                	mov    %edx,%ebx
f010675e:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
f0106765:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
f010676c:	eb 28                	jmp    f0106796 <OP_J+0xb1>
      else
	{
	  disp = get16 ();
f010676e:	e8 de f1 ff ff       	call   f0105951 <get16>
f0106773:	89 c1                	mov    %eax,%ecx
f0106775:	89 c3                	mov    %eax,%ebx
f0106777:	c1 fb 1f             	sar    $0x1f,%ebx
f010677a:	c7 45 f0 ff ff 00 00 	movl   $0xffff,-0x10(%ebp)
f0106781:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0106788:	eb 0c                	jmp    f0106796 <OP_J+0xb1>
	     displacement is added!  */
	  mask = 0xffff;
	}
      break;
    default:
      oappend (INTERNAL_DISASSEMBLER_ERROR);
f010678a:	b8 1e b7 10 f0       	mov    $0xf010b71e,%eax
f010678f:	e8 d9 f9 ff ff       	call   f010616d <oappend>
f0106794:	eb 57                	jmp    f01067ed <OP_J+0x108>
      return;
    }
  disp = (start_pc + codep - start_codep + disp) & mask;
f0106796:	a1 6c 9f 1b f0       	mov    0xf01b9f6c,%eax
f010679b:	03 05 48 a1 1b f0    	add    0xf01ba148,%eax
f01067a1:	2b 05 64 9f 1b f0    	sub    0xf01b9f64,%eax
f01067a7:	89 c2                	mov    %eax,%edx
f01067a9:	c1 fa 1f             	sar    $0x1f,%edx
f01067ac:	89 de                	mov    %ebx,%esi
f01067ae:	89 cb                	mov    %ecx,%ebx
f01067b0:	01 c3                	add    %eax,%ebx
f01067b2:	11 d6                	adc    %edx,%esi
f01067b4:	23 5d f0             	and    -0x10(%ebp),%ebx
f01067b7:	23 75 f4             	and    -0xc(%ebp),%esi
  set_op (disp, 0);
f01067ba:	b9 00 00 00 00       	mov    $0x0,%ecx
f01067bf:	89 d8                	mov    %ebx,%eax
f01067c1:	89 f2                	mov    %esi,%edx
f01067c3:	e8 c9 f1 ff ff       	call   f0105991 <set_op>
  print_operand_value (scratchbuf, sizeof(scratchbuf), 1, disp);
f01067c8:	89 1c 24             	mov    %ebx,(%esp)
f01067cb:	89 74 24 04          	mov    %esi,0x4(%esp)
f01067cf:	b9 01 00 00 00       	mov    $0x1,%ecx
f01067d4:	ba 64 00 00 00       	mov    $0x64,%edx
f01067d9:	b8 00 9f 1b f0       	mov    $0xf01b9f00,%eax
f01067de:	e8 c9 f7 ff ff       	call   f0105fac <print_operand_value>
  oappend (scratchbuf);
f01067e3:	b8 00 9f 1b f0       	mov    $0xf01b9f00,%eax
f01067e8:	e8 80 f9 ff ff       	call   f010616d <oappend>
}
f01067ed:	83 c4 10             	add    $0x10,%esp
f01067f0:	5b                   	pop    %ebx
f01067f1:	5e                   	pop    %esi
f01067f2:	5d                   	pop    %ebp
f01067f3:	c3                   	ret    

f01067f4 <OP_sI>:

static void
OP_sI (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f01067f4:	55                   	push   %ebp
f01067f5:	89 e5                	mov    %esp,%ebp
f01067f7:	83 ec 08             	sub    $0x8,%esp
f01067fa:	8b 45 08             	mov    0x8(%ebp),%eax
  bfd_signed_vma op;
  bfd_signed_vma mask = -1;

  switch (bytemode)
f01067fd:	83 f8 02             	cmp    $0x2,%eax
f0106800:	74 57                	je     f0106859 <OP_sI+0x65>
f0106802:	83 f8 03             	cmp    $0x3,%eax
f0106805:	0f 84 a4 00 00 00    	je     f01068af <OP_sI+0xbb>
f010680b:	83 f8 01             	cmp    $0x1,%eax
f010680e:	0f 85 b7 00 00 00    	jne    f01068cb <OP_sI+0xd7>
    {
    case b_mode:
      FETCH_DATA (the_info, codep + 1);
f0106814:	8b 15 6c 9f 1b f0    	mov    0xf01b9f6c,%edx
f010681a:	83 c2 01             	add    $0x1,%edx
f010681d:	8b 0d 70 9f 1b f0    	mov    0xf01b9f70,%ecx
f0106823:	8b 41 20             	mov    0x20(%ecx),%eax
f0106826:	3b 10                	cmp    (%eax),%edx
f0106828:	76 07                	jbe    f0106831 <OP_sI+0x3d>
f010682a:	89 c8                	mov    %ecx,%eax
f010682c:	e8 bf ed ff ff       	call   f01055f0 <fetch_data>
      op = *codep++;
f0106831:	a1 6c 9f 1b f0       	mov    0xf01b9f6c,%eax
f0106836:	0f b6 10             	movzbl (%eax),%edx
f0106839:	b9 00 00 00 00       	mov    $0x0,%ecx
f010683e:	83 c0 01             	add    $0x1,%eax
f0106841:	a3 6c 9f 1b f0       	mov    %eax,0xf01b9f6c
      if ((op & 0x80) != 0)
f0106846:	84 d2                	test   %dl,%dl
f0106848:	0f 89 89 00 00 00    	jns    f01068d7 <OP_sI+0xe3>
	op -= 0x100;
f010684e:	81 c2 00 ff ff ff    	add    $0xffffff00,%edx
f0106854:	83 d1 ff             	adc    $0xffffffff,%ecx
f0106857:	eb 7e                	jmp    f01068d7 <OP_sI+0xe3>
      mask = 0xffffffff;
      break;
    case v_mode:
      USED_REX (REX_MODE64);
f0106859:	f6 05 68 9e 1b f0 08 	testb  $0x8,0xf01b9e68
f0106860:	0f 84 a6 00 00 00    	je     f010690c <OP_sI+0x118>
f0106866:	83 0d 6c 9e 1b f0 48 	orl    $0x48,0xf01b9e6c
      if (rex & REX_MODE64)
	op = get32s ();
f010686d:	e8 59 f0 ff ff       	call   f01058cb <get32s>
f0106872:	89 d1                	mov    %edx,%ecx
f0106874:	89 c2                	mov    %eax,%edx
f0106876:	eb 25                	jmp    f010689d <OP_sI+0xa9>
      else if (sizeflag & DFLAG)
	{
	  op = get32s ();
f0106878:	e8 4e f0 ff ff       	call   f01058cb <get32s>
f010687d:	89 d1                	mov    %edx,%ecx
f010687f:	89 c2                	mov    %eax,%edx
f0106881:	eb 1a                	jmp    f010689d <OP_sI+0xa9>
	  mask = 0xffffffff;
	}
      else
	{
	  mask = 0xffffffff;
	  op = get16 ();
f0106883:	e8 c9 f0 ff ff       	call   f0105951 <get16>
f0106888:	89 c2                	mov    %eax,%edx
f010688a:	89 c1                	mov    %eax,%ecx
f010688c:	c1 f9 1f             	sar    $0x1f,%ecx
	  if ((op & 0x8000) != 0)
f010688f:	66 85 c0             	test   %ax,%ax
f0106892:	79 09                	jns    f010689d <OP_sI+0xa9>
	    op -= 0x10000;
f0106894:	81 c2 00 00 ff ff    	add    $0xffff0000,%edx
f010689a:	83 d1 ff             	adc    $0xffffffff,%ecx
	}
      used_prefixes |= (prefixes & PREFIX_DATA);
f010689d:	a1 64 9e 1b f0       	mov    0xf01b9e64,%eax
f01068a2:	25 00 02 00 00       	and    $0x200,%eax
f01068a7:	09 05 70 9e 1b f0    	or     %eax,0xf01b9e70
f01068ad:	eb 28                	jmp    f01068d7 <OP_sI+0xe3>
      break;
    case w_mode:
      op = get16 ();
f01068af:	e8 9d f0 ff ff       	call   f0105951 <get16>
f01068b4:	89 c2                	mov    %eax,%edx
f01068b6:	89 c1                	mov    %eax,%ecx
f01068b8:	c1 f9 1f             	sar    $0x1f,%ecx
      mask = 0xffffffff;
      if ((op & 0x8000) != 0)
f01068bb:	66 85 c0             	test   %ax,%ax
f01068be:	79 17                	jns    f01068d7 <OP_sI+0xe3>
	op -= 0x10000;
f01068c0:	81 c2 00 00 ff ff    	add    $0xffff0000,%edx
f01068c6:	83 d1 ff             	adc    $0xffffffff,%ecx
f01068c9:	eb 0c                	jmp    f01068d7 <OP_sI+0xe3>
      break;
    default:
      oappend (INTERNAL_DISASSEMBLER_ERROR);
f01068cb:	b8 1e b7 10 f0       	mov    $0xf010b71e,%eax
f01068d0:	e8 98 f8 ff ff       	call   f010616d <oappend>
f01068d5:	eb 44                	jmp    f010691b <OP_sI+0x127>
      return;
    }

  scratchbuf[0] = '$';
f01068d7:	c6 05 00 9f 1b f0 24 	movb   $0x24,0xf01b9f00
  print_operand_value (scratchbuf + 1, sizeof(scratchbuf) - 1, 1, op);
f01068de:	89 14 24             	mov    %edx,(%esp)
f01068e1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01068e5:	b9 01 00 00 00       	mov    $0x1,%ecx
f01068ea:	ba 63 00 00 00       	mov    $0x63,%edx
f01068ef:	b8 01 9f 1b f0       	mov    $0xf01b9f01,%eax
f01068f4:	e8 b3 f6 ff ff       	call   f0105fac <print_operand_value>
  oappend (scratchbuf + intel_syntax);
f01068f9:	0f be 05 50 a1 1b f0 	movsbl 0xf01ba150,%eax
f0106900:	05 00 9f 1b f0       	add    $0xf01b9f00,%eax
f0106905:	e8 63 f8 ff ff       	call   f010616d <oappend>
f010690a:	eb 0f                	jmp    f010691b <OP_sI+0x127>
      break;
    case v_mode:
      USED_REX (REX_MODE64);
      if (rex & REX_MODE64)
	op = get32s ();
      else if (sizeflag & DFLAG)
f010690c:	f6 45 0c 01          	testb  $0x1,0xc(%ebp)
f0106910:	0f 85 62 ff ff ff    	jne    f0106878 <OP_sI+0x84>
f0106916:	e9 68 ff ff ff       	jmp    f0106883 <OP_sI+0x8f>
    }

  scratchbuf[0] = '$';
  print_operand_value (scratchbuf + 1, sizeof(scratchbuf) - 1, 1, op);
  oappend (scratchbuf + intel_syntax);
}
f010691b:	c9                   	leave  
f010691c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0106920:	c3                   	ret    

f0106921 <OP_I>:

static void
OP_I (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f0106921:	55                   	push   %ebp
f0106922:	89 e5                	mov    %esp,%ebp
f0106924:	83 ec 18             	sub    $0x18,%esp
f0106927:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010692a:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010692d:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0106930:	8b 45 08             	mov    0x8(%ebp),%eax
  bfd_signed_vma op;
  bfd_signed_vma mask = -1;

  switch (bytemode)
f0106933:	83 f8 02             	cmp    $0x2,%eax
f0106936:	0f 84 8e 00 00 00    	je     f01069ca <OP_I+0xa9>
f010693c:	83 f8 02             	cmp    $0x2,%eax
f010693f:	7f 11                	jg     f0106952 <OP_I+0x31>
f0106941:	83 f8 01             	cmp    $0x1,%eax
f0106944:	0f 85 fe 00 00 00    	jne    f0106a48 <OP_I+0x127>
f010694a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106950:	eb 16                	jmp    f0106968 <OP_I+0x47>
f0106952:	83 f8 03             	cmp    $0x3,%eax
f0106955:	0f 84 d5 00 00 00    	je     f0106a30 <OP_I+0x10f>
f010695b:	83 f8 05             	cmp    $0x5,%eax
f010695e:	66 90                	xchg   %ax,%ax
f0106960:	0f 85 e2 00 00 00    	jne    f0106a48 <OP_I+0x127>
f0106966:	eb 41                	jmp    f01069a9 <OP_I+0x88>
    {
    case b_mode:
      FETCH_DATA (the_info, codep + 1);
f0106968:	8b 15 6c 9f 1b f0    	mov    0xf01b9f6c,%edx
f010696e:	83 c2 01             	add    $0x1,%edx
f0106971:	8b 0d 70 9f 1b f0    	mov    0xf01b9f70,%ecx
f0106977:	8b 41 20             	mov    0x20(%ecx),%eax
f010697a:	3b 10                	cmp    (%eax),%edx
f010697c:	76 07                	jbe    f0106985 <OP_I+0x64>
f010697e:	89 c8                	mov    %ecx,%eax
f0106980:	e8 6b ec ff ff       	call   f01055f0 <fetch_data>
      op = *codep++;
f0106985:	a1 6c 9f 1b f0       	mov    0xf01b9f6c,%eax
f010698a:	0f b6 08             	movzbl (%eax),%ecx
f010698d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106992:	83 c0 01             	add    $0x1,%eax
f0106995:	a3 6c 9f 1b f0       	mov    %eax,0xf01b9f6c
f010699a:	be ff 00 00 00       	mov    $0xff,%esi
f010699f:	bf 00 00 00 00       	mov    $0x0,%edi
f01069a4:	e9 ab 00 00 00       	jmp    f0106a54 <OP_I+0x133>
      mask = 0xff;
      break;
    case q_mode:
      if (mode_64bit)
f01069a9:	83 3d 60 9e 1b f0 00 	cmpl   $0x0,0xf01b9e60
f01069b0:	74 18                	je     f01069ca <OP_I+0xa9>
	{
	  op = get32s ();
f01069b2:	e8 14 ef ff ff       	call   f01058cb <get32s>
f01069b7:	89 c1                	mov    %eax,%ecx
f01069b9:	89 d3                	mov    %edx,%ebx
f01069bb:	be ff ff ff ff       	mov    $0xffffffff,%esi
f01069c0:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f01069c5:	e9 8a 00 00 00       	jmp    f0106a54 <OP_I+0x133>
	  break;
	}
      /* Fall through.  */
    case v_mode:
      USED_REX (REX_MODE64);
f01069ca:	f6 05 68 9e 1b f0 08 	testb  $0x8,0xf01b9e68
f01069d1:	0f 84 c1 00 00 00    	je     f0106a98 <OP_I+0x177>
f01069d7:	83 0d 6c 9e 1b f0 48 	orl    $0x48,0xf01b9e6c
      if (rex & REX_MODE64)
	op = get32s ();
f01069de:	e8 e8 ee ff ff       	call   f01058cb <get32s>
f01069e3:	89 c1                	mov    %eax,%ecx
f01069e5:	89 d3                	mov    %edx,%ebx
f01069e7:	be ff ff ff ff       	mov    $0xffffffff,%esi
f01069ec:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f01069f1:	eb 2b                	jmp    f0106a1e <OP_I+0xfd>
      else if (sizeflag & DFLAG)
	{
	  op = get32 ();
f01069f3:	e8 5a ee ff ff       	call   f0105852 <get32>
f01069f8:	89 c1                	mov    %eax,%ecx
f01069fa:	89 d3                	mov    %edx,%ebx
f01069fc:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0106a01:	bf 00 00 00 00       	mov    $0x0,%edi
f0106a06:	eb 16                	jmp    f0106a1e <OP_I+0xfd>
	  mask = 0xffffffff;
	}
      else
	{
	  op = get16 ();
f0106a08:	e8 44 ef ff ff       	call   f0105951 <get16>
f0106a0d:	89 c1                	mov    %eax,%ecx
f0106a0f:	89 c3                	mov    %eax,%ebx
f0106a11:	c1 fb 1f             	sar    $0x1f,%ebx
f0106a14:	be ff ff 0f 00       	mov    $0xfffff,%esi
f0106a19:	bf 00 00 00 00       	mov    $0x0,%edi
	  mask = 0xfffff;
	}
      used_prefixes |= (prefixes & PREFIX_DATA);
f0106a1e:	a1 64 9e 1b f0       	mov    0xf01b9e64,%eax
f0106a23:	25 00 02 00 00       	and    $0x200,%eax
f0106a28:	09 05 70 9e 1b f0    	or     %eax,0xf01b9e70
f0106a2e:	eb 24                	jmp    f0106a54 <OP_I+0x133>
      break;
    case w_mode:
      mask = 0xfffff;
      op = get16 ();
f0106a30:	e8 1c ef ff ff       	call   f0105951 <get16>
f0106a35:	89 c1                	mov    %eax,%ecx
f0106a37:	89 c3                	mov    %eax,%ebx
f0106a39:	c1 fb 1f             	sar    $0x1f,%ebx
f0106a3c:	be ff ff 0f 00       	mov    $0xfffff,%esi
f0106a41:	bf 00 00 00 00       	mov    $0x0,%edi
f0106a46:	eb 0c                	jmp    f0106a54 <OP_I+0x133>
      break;
    default:
      oappend (INTERNAL_DISASSEMBLER_ERROR);
f0106a48:	b8 1e b7 10 f0       	mov    $0xf010b71e,%eax
f0106a4d:	e8 1b f7 ff ff       	call   f010616d <oappend>
f0106a52:	eb 53                	jmp    f0106aa7 <OP_I+0x186>
      return;
    }

  op &= mask;
  scratchbuf[0] = '$';
f0106a54:	c6 05 00 9f 1b f0 24 	movb   $0x24,0xf01b9f00
  print_operand_value (scratchbuf + 1, sizeof(scratchbuf) - 1, 1, op);
f0106a5b:	89 f0                	mov    %esi,%eax
f0106a5d:	21 c8                	and    %ecx,%eax
f0106a5f:	89 fa                	mov    %edi,%edx
f0106a61:	21 da                	and    %ebx,%edx
f0106a63:	89 04 24             	mov    %eax,(%esp)
f0106a66:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106a6a:	b9 01 00 00 00       	mov    $0x1,%ecx
f0106a6f:	ba 63 00 00 00       	mov    $0x63,%edx
f0106a74:	b8 01 9f 1b f0       	mov    $0xf01b9f01,%eax
f0106a79:	e8 2e f5 ff ff       	call   f0105fac <print_operand_value>
  oappend (scratchbuf + intel_syntax);
f0106a7e:	0f be 05 50 a1 1b f0 	movsbl 0xf01ba150,%eax
f0106a85:	05 00 9f 1b f0       	add    $0xf01b9f00,%eax
f0106a8a:	e8 de f6 ff ff       	call   f010616d <oappend>
  scratchbuf[0] = '\0';
f0106a8f:	c6 05 00 9f 1b f0 00 	movb   $0x0,0xf01b9f00
f0106a96:	eb 0f                	jmp    f0106aa7 <OP_I+0x186>
      /* Fall through.  */
    case v_mode:
      USED_REX (REX_MODE64);
      if (rex & REX_MODE64)
	op = get32s ();
      else if (sizeflag & DFLAG)
f0106a98:	f6 45 0c 01          	testb  $0x1,0xc(%ebp)
f0106a9c:	0f 85 51 ff ff ff    	jne    f01069f3 <OP_I+0xd2>
f0106aa2:	e9 61 ff ff ff       	jmp    f0106a08 <OP_I+0xe7>
  op &= mask;
  scratchbuf[0] = '$';
  print_operand_value (scratchbuf + 1, sizeof(scratchbuf) - 1, 1, op);
  oappend (scratchbuf + intel_syntax);
  scratchbuf[0] = '\0';
}
f0106aa7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0106aaa:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0106aad:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0106ab0:	89 ec                	mov    %ebp,%esp
f0106ab2:	5d                   	pop    %ebp
f0106ab3:	c3                   	ret    

f0106ab4 <OP_I64>:

static void
OP_I64 (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f0106ab4:	55                   	push   %ebp
f0106ab5:	89 e5                	mov    %esp,%ebp
f0106ab7:	83 ec 18             	sub    $0x18,%esp
f0106aba:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0106abd:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0106ac0:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0106ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  bfd_signed_vma op;
  bfd_signed_vma mask = -1;

  if (!mode_64bit)
f0106ac6:	83 3d 60 9e 1b f0 00 	cmpl   $0x0,0xf01b9e60
f0106acd:	75 14                	jne    f0106ae3 <OP_I64+0x2f>
    {
      OP_I (bytemode, sizeflag);
f0106acf:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106ad2:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106ad6:	89 04 24             	mov    %eax,(%esp)
f0106ad9:	e8 43 fe ff ff       	call   f0106921 <OP_I>
f0106ade:	e9 3a 01 00 00       	jmp    f0106c1d <OP_I64+0x169>
      return;
    }

  switch (bytemode)
f0106ae3:	83 f8 02             	cmp    $0x2,%eax
f0106ae6:	74 58                	je     f0106b40 <OP_I64+0x8c>
f0106ae8:	83 f8 03             	cmp    $0x3,%eax
f0106aeb:	90                   	nop    
f0106aec:	8d 74 26 00          	lea    0x0(%esi),%esi
f0106af0:	0f 84 b0 00 00 00    	je     f0106ba6 <OP_I64+0xf2>
f0106af6:	83 f8 01             	cmp    $0x1,%eax
f0106af9:	0f 85 bf 00 00 00    	jne    f0106bbe <OP_I64+0x10a>
    {
    case b_mode:
      FETCH_DATA (the_info, codep + 1);
f0106aff:	8b 15 6c 9f 1b f0    	mov    0xf01b9f6c,%edx
f0106b05:	83 c2 01             	add    $0x1,%edx
f0106b08:	8b 0d 70 9f 1b f0    	mov    0xf01b9f70,%ecx
f0106b0e:	8b 41 20             	mov    0x20(%ecx),%eax
f0106b11:	3b 10                	cmp    (%eax),%edx
f0106b13:	76 07                	jbe    f0106b1c <OP_I64+0x68>
f0106b15:	89 c8                	mov    %ecx,%eax
f0106b17:	e8 d4 ea ff ff       	call   f01055f0 <fetch_data>
      op = *codep++;
f0106b1c:	a1 6c 9f 1b f0       	mov    0xf01b9f6c,%eax
f0106b21:	0f b6 08             	movzbl (%eax),%ecx
f0106b24:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106b29:	83 c0 01             	add    $0x1,%eax
f0106b2c:	a3 6c 9f 1b f0       	mov    %eax,0xf01b9f6c
f0106b31:	be ff 00 00 00       	mov    $0xff,%esi
f0106b36:	bf 00 00 00 00       	mov    $0x0,%edi
f0106b3b:	e9 8a 00 00 00       	jmp    f0106bca <OP_I64+0x116>
      mask = 0xff;
      break;
    case v_mode:
      USED_REX (REX_MODE64);
f0106b40:	f6 05 68 9e 1b f0 08 	testb  $0x8,0xf01b9e68
f0106b47:	0f 84 c1 00 00 00    	je     f0106c0e <OP_I64+0x15a>
f0106b4d:	83 0d 6c 9e 1b f0 48 	orl    $0x48,0xf01b9e6c
      if (rex & REX_MODE64)
	op = get64 ();
f0106b54:	e8 64 ec ff ff       	call   f01057bd <get64>
f0106b59:	89 c1                	mov    %eax,%ecx
f0106b5b:	89 d3                	mov    %edx,%ebx
f0106b5d:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0106b62:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0106b67:	eb 2b                	jmp    f0106b94 <OP_I64+0xe0>
      else if (sizeflag & DFLAG)
	{
	  op = get32 ();
f0106b69:	e8 e4 ec ff ff       	call   f0105852 <get32>
f0106b6e:	89 c1                	mov    %eax,%ecx
f0106b70:	89 d3                	mov    %edx,%ebx
f0106b72:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0106b77:	bf 00 00 00 00       	mov    $0x0,%edi
f0106b7c:	eb 16                	jmp    f0106b94 <OP_I64+0xe0>
	  mask = 0xffffffff;
	}
      else
	{
	  op = get16 ();
f0106b7e:	e8 ce ed ff ff       	call   f0105951 <get16>
f0106b83:	89 c1                	mov    %eax,%ecx
f0106b85:	89 c3                	mov    %eax,%ebx
f0106b87:	c1 fb 1f             	sar    $0x1f,%ebx
f0106b8a:	be ff ff 0f 00       	mov    $0xfffff,%esi
f0106b8f:	bf 00 00 00 00       	mov    $0x0,%edi
	  mask = 0xfffff;
	}
      used_prefixes |= (prefixes & PREFIX_DATA);
f0106b94:	a1 64 9e 1b f0       	mov    0xf01b9e64,%eax
f0106b99:	25 00 02 00 00       	and    $0x200,%eax
f0106b9e:	09 05 70 9e 1b f0    	or     %eax,0xf01b9e70
f0106ba4:	eb 24                	jmp    f0106bca <OP_I64+0x116>
      break;
    case w_mode:
      mask = 0xfffff;
      op = get16 ();
f0106ba6:	e8 a6 ed ff ff       	call   f0105951 <get16>
f0106bab:	89 c1                	mov    %eax,%ecx
f0106bad:	89 c3                	mov    %eax,%ebx
f0106baf:	c1 fb 1f             	sar    $0x1f,%ebx
f0106bb2:	be ff ff 0f 00       	mov    $0xfffff,%esi
f0106bb7:	bf 00 00 00 00       	mov    $0x0,%edi
f0106bbc:	eb 0c                	jmp    f0106bca <OP_I64+0x116>
      break;
    default:
      oappend (INTERNAL_DISASSEMBLER_ERROR);
f0106bbe:	b8 1e b7 10 f0       	mov    $0xf010b71e,%eax
f0106bc3:	e8 a5 f5 ff ff       	call   f010616d <oappend>
f0106bc8:	eb 53                	jmp    f0106c1d <OP_I64+0x169>
      return;
    }

  op &= mask;
  scratchbuf[0] = '$';
f0106bca:	c6 05 00 9f 1b f0 24 	movb   $0x24,0xf01b9f00
  print_operand_value (scratchbuf + 1, sizeof(scratchbuf) - 1, 1, op);
f0106bd1:	89 f0                	mov    %esi,%eax
f0106bd3:	21 c8                	and    %ecx,%eax
f0106bd5:	89 fa                	mov    %edi,%edx
f0106bd7:	21 da                	and    %ebx,%edx
f0106bd9:	89 04 24             	mov    %eax,(%esp)
f0106bdc:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106be0:	b9 01 00 00 00       	mov    $0x1,%ecx
f0106be5:	ba 63 00 00 00       	mov    $0x63,%edx
f0106bea:	b8 01 9f 1b f0       	mov    $0xf01b9f01,%eax
f0106bef:	e8 b8 f3 ff ff       	call   f0105fac <print_operand_value>
  oappend (scratchbuf + intel_syntax);
f0106bf4:	0f be 05 50 a1 1b f0 	movsbl 0xf01ba150,%eax
f0106bfb:	05 00 9f 1b f0       	add    $0xf01b9f00,%eax
f0106c00:	e8 68 f5 ff ff       	call   f010616d <oappend>
  scratchbuf[0] = '\0';
f0106c05:	c6 05 00 9f 1b f0 00 	movb   $0x0,0xf01b9f00
f0106c0c:	eb 0f                	jmp    f0106c1d <OP_I64+0x169>
      break;
    case v_mode:
      USED_REX (REX_MODE64);
      if (rex & REX_MODE64)
	op = get64 ();
      else if (sizeflag & DFLAG)
f0106c0e:	f6 45 0c 01          	testb  $0x1,0xc(%ebp)
f0106c12:	0f 85 51 ff ff ff    	jne    f0106b69 <OP_I64+0xb5>
f0106c18:	e9 61 ff ff ff       	jmp    f0106b7e <OP_I64+0xca>
  op &= mask;
  scratchbuf[0] = '$';
  print_operand_value (scratchbuf + 1, sizeof(scratchbuf) - 1, 1, op);
  oappend (scratchbuf + intel_syntax);
  scratchbuf[0] = '\0';
}
f0106c1d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0106c20:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0106c23:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0106c26:	89 ec                	mov    %ebp,%esp
f0106c28:	5d                   	pop    %ebp
f0106c29:	c3                   	ret    

f0106c2a <OP_IMREG>:

static void
OP_IMREG (code, sizeflag)
     int code;
     int sizeflag;
{
f0106c2a:	55                   	push   %ebp
f0106c2b:	89 e5                	mov    %esp,%ebp
f0106c2d:	83 ec 08             	sub    $0x8,%esp
f0106c30:	8b 55 08             	mov    0x8(%ebp),%edx
  const char *s;

  switch (code)
f0106c33:	8d 42 9c             	lea    -0x64(%edx),%eax
f0106c36:	83 f8 32             	cmp    $0x32,%eax
f0106c39:	77 07                	ja     f0106c42 <OP_IMREG+0x18>
f0106c3b:	ff 24 85 2c cd 10 f0 	jmp    *-0xfef32d4(,%eax,4)
f0106c42:	ba 1e b7 10 f0       	mov    $0xf010b71e,%edx
f0106c47:	e9 af 00 00 00       	jmp    f0106cfb <OP_IMREG+0xd1>
    {
    case indir_dx_reg:
      if (intel_syntax)
f0106c4c:	ba 3c b7 10 f0       	mov    $0xf010b73c,%edx
f0106c51:	80 3d 50 a1 1b f0 00 	cmpb   $0x0,0xf01ba150
f0106c58:	0f 85 9d 00 00 00    	jne    f0106cfb <OP_IMREG+0xd1>
f0106c5e:	ba 41 b7 10 f0       	mov    $0xf010b741,%edx
f0106c63:	e9 93 00 00 00       	jmp    f0106cfb <OP_IMREG+0xd1>
      else
        s = "(%dx)";
      break;
    case ax_reg: case cx_reg: case dx_reg: case bx_reg:
    case sp_reg: case bp_reg: case si_reg: case di_reg:
      s = names16[code - ax_reg];
f0106c68:	a1 8c 9f 1b f0       	mov    0xf01b9f8c,%eax
f0106c6d:	8b 94 90 10 fe ff ff 	mov    -0x1f0(%eax,%edx,4),%edx
f0106c74:	e9 82 00 00 00       	jmp    f0106cfb <OP_IMREG+0xd1>
      break;
    case es_reg: case ss_reg: case cs_reg:
    case ds_reg: case fs_reg: case gs_reg:
      s = names_seg[code - es_reg];
f0106c79:	a1 98 9f 1b f0       	mov    0xf01b9f98,%eax
f0106c7e:	8b 94 90 70 fe ff ff 	mov    -0x190(%eax,%edx,4),%edx
f0106c85:	eb 74                	jmp    f0106cfb <OP_IMREG+0xd1>
      break;
    case al_reg: case ah_reg: case cl_reg: case ch_reg:
    case dl_reg: case dh_reg: case bl_reg: case bh_reg:
      USED_REX (0);
f0106c87:	83 0d 6c 9e 1b f0 40 	orl    $0x40,0xf01b9e6c
      if (rex)
f0106c8e:	83 3d 68 9e 1b f0 00 	cmpl   $0x0,0xf01b9e68
f0106c95:	74 0e                	je     f0106ca5 <OP_IMREG+0x7b>
	s = names8rex[code - al_reg];
f0106c97:	a1 94 9f 1b f0       	mov    0xf01b9f94,%eax
f0106c9c:	8b 94 90 30 fe ff ff 	mov    -0x1d0(%eax,%edx,4),%edx
f0106ca3:	eb 56                	jmp    f0106cfb <OP_IMREG+0xd1>
      else
	s = names8[code - al_reg];
f0106ca5:	a1 90 9f 1b f0       	mov    0xf01b9f90,%eax
f0106caa:	8b 94 90 30 fe ff ff 	mov    -0x1d0(%eax,%edx,4),%edx
f0106cb1:	eb 48                	jmp    f0106cfb <OP_IMREG+0xd1>
      break;
    case eAX_reg: case eCX_reg: case eDX_reg: case eBX_reg:
    case eSP_reg: case eBP_reg: case eSI_reg: case eDI_reg:
      USED_REX (REX_MODE64);
f0106cb3:	f6 05 68 9e 1b f0 08 	testb  $0x8,0xf01b9e68
f0106cba:	74 48                	je     f0106d04 <OP_IMREG+0xda>
f0106cbc:	83 0d 6c 9e 1b f0 48 	orl    $0x48,0xf01b9e6c
      if (rex & REX_MODE64)
	s = names64[code - eAX_reg];
f0106cc3:	a1 84 9f 1b f0       	mov    0xf01b9f84,%eax
f0106cc8:	8b 94 90 50 fe ff ff 	mov    -0x1b0(%eax,%edx,4),%edx
f0106ccf:	eb 1a                	jmp    f0106ceb <OP_IMREG+0xc1>
      else if (sizeflag & DFLAG)
	s = names32[code - eAX_reg];
f0106cd1:	a1 88 9f 1b f0       	mov    0xf01b9f88,%eax
f0106cd6:	8b 94 90 50 fe ff ff 	mov    -0x1b0(%eax,%edx,4),%edx
f0106cdd:	eb 0c                	jmp    f0106ceb <OP_IMREG+0xc1>
      else
	s = names16[code - eAX_reg];
f0106cdf:	a1 8c 9f 1b f0       	mov    0xf01b9f8c,%eax
f0106ce4:	8b 94 90 50 fe ff ff 	mov    -0x1b0(%eax,%edx,4),%edx
      used_prefixes |= (prefixes & PREFIX_DATA);
f0106ceb:	a1 64 9e 1b f0       	mov    0xf01b9e64,%eax
f0106cf0:	25 00 02 00 00       	and    $0x200,%eax
f0106cf5:	09 05 70 9e 1b f0    	or     %eax,0xf01b9e70
      break;
    default:
      s = INTERNAL_DISASSEMBLER_ERROR;
      break;
    }
  oappend (s);
f0106cfb:	89 d0                	mov    %edx,%eax
f0106cfd:	e8 6b f4 ff ff       	call   f010616d <oappend>
}
f0106d02:	c9                   	leave  
f0106d03:	c3                   	ret    
    case eAX_reg: case eCX_reg: case eDX_reg: case eBX_reg:
    case eSP_reg: case eBP_reg: case eSI_reg: case eDI_reg:
      USED_REX (REX_MODE64);
      if (rex & REX_MODE64)
	s = names64[code - eAX_reg];
      else if (sizeflag & DFLAG)
f0106d04:	f6 45 0c 01          	testb  $0x1,0xc(%ebp)
f0106d08:	75 c7                	jne    f0106cd1 <OP_IMREG+0xa7>
f0106d0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106d10:	eb cd                	jmp    f0106cdf <OP_IMREG+0xb5>

f0106d12 <OP_REG>:

static void
OP_REG (code, sizeflag)
     int code;
     int sizeflag;
{
f0106d12:	55                   	push   %ebp
f0106d13:	89 e5                	mov    %esp,%ebp
f0106d15:	83 ec 08             	sub    $0x8,%esp
f0106d18:	89 1c 24             	mov    %ebx,(%esp)
f0106d1b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106d1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  const char *s;
  int add = 0;
  USED_REX (REX_EXTZ);
f0106d22:	8b 0d 68 9e 1b f0    	mov    0xf01b9e68,%ecx
f0106d28:	f6 c1 01             	test   $0x1,%cl
f0106d2b:	0f 84 05 01 00 00    	je     f0106e36 <OP_REG+0x124>
f0106d31:	a1 6c 9e 1b f0       	mov    0xf01b9e6c,%eax
f0106d36:	83 c8 41             	or     $0x41,%eax
f0106d39:	a3 6c 9e 1b f0       	mov    %eax,0xf01b9e6c
f0106d3e:	be 08 00 00 00       	mov    $0x8,%esi
  if (rex & REX_EXTZ)
    add = 8;

  switch (code)
f0106d43:	8d 53 9c             	lea    -0x64(%ebx),%edx
f0106d46:	83 fa 32             	cmp    $0x32,%edx
f0106d49:	77 07                	ja     f0106d52 <OP_REG+0x40>
f0106d4b:	ff 24 95 f8 cd 10 f0 	jmp    *-0xfef3208(,%edx,4)
f0106d52:	ba 1e b7 10 f0       	mov    $0xf010b71e,%edx
f0106d57:	e9 c8 00 00 00       	jmp    f0106e24 <OP_REG+0x112>
    {
    case indir_dx_reg:
      if (intel_syntax)
f0106d5c:	ba 3c b7 10 f0       	mov    $0xf010b73c,%edx
f0106d61:	80 3d 50 a1 1b f0 00 	cmpb   $0x0,0xf01ba150
f0106d68:	0f 85 b6 00 00 00    	jne    f0106e24 <OP_REG+0x112>
f0106d6e:	ba 41 b7 10 f0       	mov    $0xf010b741,%edx
f0106d73:	e9 ac 00 00 00       	jmp    f0106e24 <OP_REG+0x112>
      else
        s = "(%dx)";
      break;
    case ax_reg: case cx_reg: case dx_reg: case bx_reg:
    case sp_reg: case bp_reg: case si_reg: case di_reg:
      s = names16[code - ax_reg + add];
f0106d78:	8d 54 1e 84          	lea    -0x7c(%esi,%ebx,1),%edx
f0106d7c:	a1 8c 9f 1b f0       	mov    0xf01b9f8c,%eax
f0106d81:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0106d84:	e9 9b 00 00 00       	jmp    f0106e24 <OP_REG+0x112>
      break;
    case es_reg: case ss_reg: case cs_reg:
    case ds_reg: case fs_reg: case gs_reg:
      s = names_seg[code - es_reg + add];
f0106d89:	8d 54 1e 9c          	lea    -0x64(%esi,%ebx,1),%edx
f0106d8d:	a1 98 9f 1b f0       	mov    0xf01b9f98,%eax
f0106d92:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0106d95:	e9 8a 00 00 00       	jmp    f0106e24 <OP_REG+0x112>
      break;
    case al_reg: case ah_reg: case cl_reg: case ch_reg:
    case dl_reg: case dh_reg: case bl_reg: case bh_reg:
      USED_REX (0);
f0106d9a:	83 c8 40             	or     $0x40,%eax
f0106d9d:	a3 6c 9e 1b f0       	mov    %eax,0xf01b9e6c
      if (rex)
f0106da2:	85 c9                	test   %ecx,%ecx
f0106da4:	74 0e                	je     f0106db4 <OP_REG+0xa2>
	s = names8rex[code - al_reg + add];
f0106da6:	8d 54 1e 8c          	lea    -0x74(%esi,%ebx,1),%edx
f0106daa:	a1 94 9f 1b f0       	mov    0xf01b9f94,%eax
f0106daf:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0106db2:	eb 70                	jmp    f0106e24 <OP_REG+0x112>
      else
	s = names8[code - al_reg];
f0106db4:	a1 90 9f 1b f0       	mov    0xf01b9f90,%eax
f0106db9:	8b 94 98 30 fe ff ff 	mov    -0x1d0(%eax,%ebx,4),%edx
f0106dc0:	eb 62                	jmp    f0106e24 <OP_REG+0x112>
      break;
    case rAX_reg: case rCX_reg: case rDX_reg: case rBX_reg:
    case rSP_reg: case rBP_reg: case rSI_reg: case rDI_reg:
      if (mode_64bit)
f0106dc2:	83 3d 60 9e 1b f0 00 	cmpl   $0x0,0xf01b9e60
f0106dc9:	74 11                	je     f0106ddc <OP_REG+0xca>
	{
	  s = names64[code - rAX_reg + add];
f0106dcb:	8d 94 1e 7c ff ff ff 	lea    -0x84(%esi,%ebx,1),%edx
f0106dd2:	a1 84 9f 1b f0       	mov    0xf01b9f84,%eax
f0106dd7:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0106dda:	eb 48                	jmp    f0106e24 <OP_REG+0x112>
	  break;
	}
      code += eAX_reg - rAX_reg;
f0106ddc:	83 eb 18             	sub    $0x18,%ebx
      /* Fall through.  */
    case eAX_reg: case eCX_reg: case eDX_reg: case eBX_reg:
    case eSP_reg: case eBP_reg: case eSI_reg: case eDI_reg:
      USED_REX (REX_MODE64);
f0106ddf:	f6 c1 08             	test   $0x8,%cl
f0106de2:	74 61                	je     f0106e45 <OP_REG+0x133>
f0106de4:	83 c8 48             	or     $0x48,%eax
f0106de7:	a3 6c 9e 1b f0       	mov    %eax,0xf01b9e6c
      if (rex & REX_MODE64)
	s = names64[code - eAX_reg + add];
f0106dec:	8d 54 1e 94          	lea    -0x6c(%esi,%ebx,1),%edx
f0106df0:	a1 84 9f 1b f0       	mov    0xf01b9f84,%eax
f0106df5:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0106df8:	eb 1a                	jmp    f0106e14 <OP_REG+0x102>
      else if (sizeflag & DFLAG)
	s = names32[code - eAX_reg + add];
f0106dfa:	8d 54 1e 94          	lea    -0x6c(%esi,%ebx,1),%edx
f0106dfe:	a1 88 9f 1b f0       	mov    0xf01b9f88,%eax
f0106e03:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0106e06:	eb 0c                	jmp    f0106e14 <OP_REG+0x102>
      else
	s = names16[code - eAX_reg + add];
f0106e08:	8d 54 1e 94          	lea    -0x6c(%esi,%ebx,1),%edx
f0106e0c:	a1 8c 9f 1b f0       	mov    0xf01b9f8c,%eax
f0106e11:	8b 14 90             	mov    (%eax,%edx,4),%edx
      used_prefixes |= (prefixes & PREFIX_DATA);
f0106e14:	a1 64 9e 1b f0       	mov    0xf01b9e64,%eax
f0106e19:	25 00 02 00 00       	and    $0x200,%eax
f0106e1e:	09 05 70 9e 1b f0    	or     %eax,0xf01b9e70
      break;
    default:
      s = INTERNAL_DISASSEMBLER_ERROR;
      break;
    }
  oappend (s);
f0106e24:	89 d0                	mov    %edx,%eax
f0106e26:	e8 42 f3 ff ff       	call   f010616d <oappend>
}
f0106e2b:	8b 1c 24             	mov    (%esp),%ebx
f0106e2e:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106e32:	89 ec                	mov    %ebp,%esp
f0106e34:	5d                   	pop    %ebp
f0106e35:	c3                   	ret    
     int code;
     int sizeflag;
{
  const char *s;
  int add = 0;
  USED_REX (REX_EXTZ);
f0106e36:	a1 6c 9e 1b f0       	mov    0xf01b9e6c,%eax
f0106e3b:	be 00 00 00 00       	mov    $0x0,%esi
f0106e40:	e9 fe fe ff ff       	jmp    f0106d43 <OP_REG+0x31>
	}
      code += eAX_reg - rAX_reg;
      /* Fall through.  */
    case eAX_reg: case eCX_reg: case eDX_reg: case eBX_reg:
    case eSP_reg: case eBP_reg: case eSI_reg: case eDI_reg:
      USED_REX (REX_MODE64);
f0106e45:	a3 6c 9e 1b f0       	mov    %eax,0xf01b9e6c
      if (rex & REX_MODE64)
	s = names64[code - eAX_reg + add];
      else if (sizeflag & DFLAG)
f0106e4a:	f6 45 0c 01          	testb  $0x1,0xc(%ebp)
f0106e4e:	75 aa                	jne    f0106dfa <OP_REG+0xe8>
f0106e50:	eb b6                	jmp    f0106e08 <OP_REG+0xf6>

f0106e52 <OP_G>:

static void
OP_G (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f0106e52:	55                   	push   %ebp
f0106e53:	89 e5                	mov    %esp,%ebp
f0106e55:	53                   	push   %ebx
f0106e56:	83 ec 04             	sub    $0x4,%esp
f0106e59:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int add = 0;
  USED_REX (REX_EXTX);
f0106e5c:	8b 0d 68 9e 1b f0    	mov    0xf01b9e68,%ecx
f0106e62:	f6 c1 04             	test   $0x4,%cl
f0106e65:	0f 84 23 01 00 00    	je     f0106f8e <OP_G+0x13c>
f0106e6b:	a1 6c 9e 1b f0       	mov    0xf01b9e6c,%eax
f0106e70:	83 c8 44             	or     $0x44,%eax
f0106e73:	a3 6c 9e 1b f0       	mov    %eax,0xf01b9e6c
f0106e78:	ba 08 00 00 00       	mov    $0x8,%edx
  if (rex & REX_EXTX)
    add += 8;
  switch (bytemode)
f0106e7d:	83 fb 05             	cmp    $0x5,%ebx
f0106e80:	0f 87 fc 00 00 00    	ja     f0106f82 <OP_G+0x130>
f0106e86:	ff 24 9d c4 ce 10 f0 	jmp    *-0xfef313c(,%ebx,4)
    {
    case b_mode:
      USED_REX (0);
f0106e8d:	83 c8 40             	or     $0x40,%eax
f0106e90:	a3 6c 9e 1b f0       	mov    %eax,0xf01b9e6c
      if (rex)
f0106e95:	85 c9                	test   %ecx,%ecx
f0106e97:	74 1b                	je     f0106eb4 <OP_G+0x62>
	oappend (names8rex[reg + add]);
f0106e99:	89 d0                	mov    %edx,%eax
f0106e9b:	03 05 7c 9f 1b f0    	add    0xf01b9f7c,%eax
f0106ea1:	8b 15 94 9f 1b f0    	mov    0xf01b9f94,%edx
f0106ea7:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0106eaa:	e8 be f2 ff ff       	call   f010616d <oappend>
f0106eaf:	e9 f6 00 00 00       	jmp    f0106faa <OP_G+0x158>
      else
	oappend (names8[reg + add]);
f0106eb4:	89 d0                	mov    %edx,%eax
f0106eb6:	03 05 7c 9f 1b f0    	add    0xf01b9f7c,%eax
f0106ebc:	8b 15 90 9f 1b f0    	mov    0xf01b9f90,%edx
f0106ec2:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0106ec5:	e8 a3 f2 ff ff       	call   f010616d <oappend>
f0106eca:	e9 db 00 00 00       	jmp    f0106faa <OP_G+0x158>
      break;
    case w_mode:
      oappend (names16[reg + add]);
f0106ecf:	89 d0                	mov    %edx,%eax
f0106ed1:	03 05 7c 9f 1b f0    	add    0xf01b9f7c,%eax
f0106ed7:	8b 15 8c 9f 1b f0    	mov    0xf01b9f8c,%edx
f0106edd:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0106ee0:	e8 88 f2 ff ff       	call   f010616d <oappend>
f0106ee5:	e9 c0 00 00 00       	jmp    f0106faa <OP_G+0x158>
      break;
    case d_mode:
      oappend (names32[reg + add]);
f0106eea:	89 d0                	mov    %edx,%eax
f0106eec:	03 05 7c 9f 1b f0    	add    0xf01b9f7c,%eax
f0106ef2:	8b 15 88 9f 1b f0    	mov    0xf01b9f88,%edx
f0106ef8:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0106efb:	e8 6d f2 ff ff       	call   f010616d <oappend>
f0106f00:	e9 a5 00 00 00       	jmp    f0106faa <OP_G+0x158>
      break;
    case q_mode:
      oappend (names64[reg + add]);
f0106f05:	89 d0                	mov    %edx,%eax
f0106f07:	03 05 7c 9f 1b f0    	add    0xf01b9f7c,%eax
f0106f0d:	8b 15 84 9f 1b f0    	mov    0xf01b9f84,%edx
f0106f13:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0106f16:	e8 52 f2 ff ff       	call   f010616d <oappend>
f0106f1b:	e9 8a 00 00 00       	jmp    f0106faa <OP_G+0x158>
      break;
    case v_mode:
      USED_REX (REX_MODE64);
f0106f20:	f6 c1 08             	test   $0x8,%cl
f0106f23:	74 78                	je     f0106f9d <OP_G+0x14b>
f0106f25:	83 c8 48             	or     $0x48,%eax
f0106f28:	a3 6c 9e 1b f0       	mov    %eax,0xf01b9e6c
      if (rex & REX_MODE64)
	oappend (names64[reg + add]);
f0106f2d:	03 15 7c 9f 1b f0    	add    0xf01b9f7c,%edx
f0106f33:	a1 84 9f 1b f0       	mov    0xf01b9f84,%eax
f0106f38:	8b 04 90             	mov    (%eax,%edx,4),%eax
f0106f3b:	e8 2d f2 ff ff       	call   f010616d <oappend>
f0106f40:	eb 2e                	jmp    f0106f70 <OP_G+0x11e>
      else if (sizeflag & DFLAG)
	oappend (names32[reg + add]);
f0106f42:	89 d0                	mov    %edx,%eax
f0106f44:	03 05 7c 9f 1b f0    	add    0xf01b9f7c,%eax
f0106f4a:	8b 15 88 9f 1b f0    	mov    0xf01b9f88,%edx
f0106f50:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0106f53:	e8 15 f2 ff ff       	call   f010616d <oappend>
f0106f58:	eb 16                	jmp    f0106f70 <OP_G+0x11e>
      else
	oappend (names16[reg + add]);
f0106f5a:	89 d0                	mov    %edx,%eax
f0106f5c:	03 05 7c 9f 1b f0    	add    0xf01b9f7c,%eax
f0106f62:	8b 15 8c 9f 1b f0    	mov    0xf01b9f8c,%edx
f0106f68:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0106f6b:	e8 fd f1 ff ff       	call   f010616d <oappend>
      used_prefixes |= (prefixes & PREFIX_DATA);
f0106f70:	a1 64 9e 1b f0       	mov    0xf01b9e64,%eax
f0106f75:	25 00 02 00 00       	and    $0x200,%eax
f0106f7a:	09 05 70 9e 1b f0    	or     %eax,0xf01b9e70
f0106f80:	eb 28                	jmp    f0106faa <OP_G+0x158>
      break;
    default:
      oappend (INTERNAL_DISASSEMBLER_ERROR);
f0106f82:	b8 1e b7 10 f0       	mov    $0xf010b71e,%eax
f0106f87:	e8 e1 f1 ff ff       	call   f010616d <oappend>
f0106f8c:	eb 1c                	jmp    f0106faa <OP_G+0x158>
OP_G (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
  int add = 0;
  USED_REX (REX_EXTX);
f0106f8e:	a1 6c 9e 1b f0       	mov    0xf01b9e6c,%eax
f0106f93:	ba 00 00 00 00       	mov    $0x0,%edx
f0106f98:	e9 e0 fe ff ff       	jmp    f0106e7d <OP_G+0x2b>
      break;
    case q_mode:
      oappend (names64[reg + add]);
      break;
    case v_mode:
      USED_REX (REX_MODE64);
f0106f9d:	a3 6c 9e 1b f0       	mov    %eax,0xf01b9e6c
      if (rex & REX_MODE64)
	oappend (names64[reg + add]);
      else if (sizeflag & DFLAG)
f0106fa2:	f6 45 0c 01          	testb  $0x1,0xc(%ebp)
f0106fa6:	75 9a                	jne    f0106f42 <OP_G+0xf0>
f0106fa8:	eb b0                	jmp    f0106f5a <OP_G+0x108>
      break;
    default:
      oappend (INTERNAL_DISASSEMBLER_ERROR);
      break;
    }
}
f0106faa:	83 c4 04             	add    $0x4,%esp
f0106fad:	5b                   	pop    %ebx
f0106fae:	5d                   	pop    %ebp
f0106faf:	c3                   	ret    

f0106fb0 <append_seg>:
  obufp += strlen (s);
}

static void
append_seg ()
{
f0106fb0:	55                   	push   %ebp
f0106fb1:	89 e5                	mov    %esp,%ebp
f0106fb3:	83 ec 08             	sub    $0x8,%esp
  if (prefixes & PREFIX_CS)
f0106fb6:	f6 05 64 9e 1b f0 08 	testb  $0x8,0xf01b9e64
f0106fbd:	74 18                	je     f0106fd7 <append_seg+0x27>
    {
      used_prefixes |= PREFIX_CS;
f0106fbf:	83 0d 70 9e 1b f0 08 	orl    $0x8,0xf01b9e70
      oappend ("%cs:" + intel_syntax);
f0106fc6:	0f be 05 50 a1 1b f0 	movsbl 0xf01ba150,%eax
f0106fcd:	05 47 b7 10 f0       	add    $0xf010b747,%eax
f0106fd2:	e8 96 f1 ff ff       	call   f010616d <oappend>
    }
  if (prefixes & PREFIX_DS)
f0106fd7:	f6 05 64 9e 1b f0 20 	testb  $0x20,0xf01b9e64
f0106fde:	74 18                	je     f0106ff8 <append_seg+0x48>
    {
      used_prefixes |= PREFIX_DS;
f0106fe0:	83 0d 70 9e 1b f0 20 	orl    $0x20,0xf01b9e70
      oappend ("%ds:" + intel_syntax);
f0106fe7:	0f be 05 50 a1 1b f0 	movsbl 0xf01ba150,%eax
f0106fee:	05 4c b7 10 f0       	add    $0xf010b74c,%eax
f0106ff3:	e8 75 f1 ff ff       	call   f010616d <oappend>
    }
  if (prefixes & PREFIX_SS)
f0106ff8:	f6 05 64 9e 1b f0 10 	testb  $0x10,0xf01b9e64
f0106fff:	74 18                	je     f0107019 <append_seg+0x69>
    {
      used_prefixes |= PREFIX_SS;
f0107001:	83 0d 70 9e 1b f0 10 	orl    $0x10,0xf01b9e70
      oappend ("%ss:" + intel_syntax);
f0107008:	0f be 05 50 a1 1b f0 	movsbl 0xf01ba150,%eax
f010700f:	05 51 b7 10 f0       	add    $0xf010b751,%eax
f0107014:	e8 54 f1 ff ff       	call   f010616d <oappend>
    }
  if (prefixes & PREFIX_ES)
f0107019:	f6 05 64 9e 1b f0 40 	testb  $0x40,0xf01b9e64
f0107020:	74 18                	je     f010703a <append_seg+0x8a>
    {
      used_prefixes |= PREFIX_ES;
f0107022:	83 0d 70 9e 1b f0 40 	orl    $0x40,0xf01b9e70
      oappend ("%es:" + intel_syntax);
f0107029:	0f be 05 50 a1 1b f0 	movsbl 0xf01ba150,%eax
f0107030:	05 03 b7 10 f0       	add    $0xf010b703,%eax
f0107035:	e8 33 f1 ff ff       	call   f010616d <oappend>
    }
  if (prefixes & PREFIX_FS)
f010703a:	80 3d 64 9e 1b f0 00 	cmpb   $0x0,0xf01b9e64
f0107041:	79 1b                	jns    f010705e <append_seg+0xae>
    {
      used_prefixes |= PREFIX_FS;
f0107043:	81 0d 70 9e 1b f0 80 	orl    $0x80,0xf01b9e70
f010704a:	00 00 00 
      oappend ("%fs:" + intel_syntax);
f010704d:	0f be 05 50 a1 1b f0 	movsbl 0xf01ba150,%eax
f0107054:	05 56 b7 10 f0       	add    $0xf010b756,%eax
f0107059:	e8 0f f1 ff ff       	call   f010616d <oappend>
    }
  if (prefixes & PREFIX_GS)
f010705e:	f6 05 65 9e 1b f0 01 	testb  $0x1,0xf01b9e65
f0107065:	74 1b                	je     f0107082 <append_seg+0xd2>
    {
      used_prefixes |= PREFIX_GS;
f0107067:	81 0d 70 9e 1b f0 00 	orl    $0x100,0xf01b9e70
f010706e:	01 00 00 
      oappend ("%gs:" + intel_syntax);
f0107071:	0f be 05 50 a1 1b f0 	movsbl 0xf01ba150,%eax
f0107078:	05 5b b7 10 f0       	add    $0xf010b75b,%eax
f010707d:	e8 eb f0 ff ff       	call   f010616d <oappend>
    }
}
f0107082:	c9                   	leave  
f0107083:	c3                   	ret    

f0107084 <OP_DSreg>:

static void
OP_DSreg (code, sizeflag)
     int code;
     int sizeflag;
{
f0107084:	55                   	push   %ebp
f0107085:	89 e5                	mov    %esp,%ebp
f0107087:	83 ec 08             	sub    $0x8,%esp
  if ((prefixes
f010708a:	a1 64 9e 1b f0       	mov    0xf01b9e64,%eax
f010708f:	a9 f8 01 00 00       	test   $0x1f8,%eax
f0107094:	75 08                	jne    f010709e <OP_DSreg+0x1a>
	  | PREFIX_DS
	  | PREFIX_SS
	  | PREFIX_ES
	  | PREFIX_FS
	  | PREFIX_GS)) == 0)
    prefixes |= PREFIX_DS;
f0107096:	83 c8 20             	or     $0x20,%eax
f0107099:	a3 64 9e 1b f0       	mov    %eax,0xf01b9e64
  append_seg ();
f010709e:	e8 0d ff ff ff       	call   f0106fb0 <append_seg>
  ptr_reg (code, sizeflag);
f01070a3:	8b 55 0c             	mov    0xc(%ebp),%edx
f01070a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01070a9:	e8 b0 f4 ff ff       	call   f010655e <ptr_reg>
}
f01070ae:	c9                   	leave  
f01070af:	c3                   	ret    

f01070b0 <OP_OFF64>:

static void
OP_OFF64 (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f01070b0:	55                   	push   %ebp
f01070b1:	89 e5                	mov    %esp,%ebp
f01070b3:	83 ec 18             	sub    $0x18,%esp
f01070b6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01070b9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  bfd_vma off;

  if (!mode_64bit)
f01070bc:	83 3d 60 9e 1b f0 00 	cmpl   $0x0,0xf01b9e60
f01070c3:	75 7e                	jne    f0107143 <OP_OFF64+0x93>
     int bytemode;
     int sizeflag;
{
  bfd_vma off;

  append_seg ();
f01070c5:	e8 e6 fe ff ff       	call   f0106fb0 <append_seg>

  if ((sizeflag & AFLAG) || mode_64bit)
f01070ca:	f6 45 0c 02          	testb  $0x2,0xc(%ebp)
f01070ce:	75 09                	jne    f01070d9 <OP_OFF64+0x29>
f01070d0:	83 3d 60 9e 1b f0 00 	cmpl   $0x0,0xf01b9e60
f01070d7:	74 0b                	je     f01070e4 <OP_OFF64+0x34>
    off = get32 ();
f01070d9:	e8 74 e7 ff ff       	call   f0105852 <get32>
f01070de:	89 c3                	mov    %eax,%ebx
f01070e0:	89 d6                	mov    %edx,%esi
f01070e2:	eb 0c                	jmp    f01070f0 <OP_OFF64+0x40>
  else
    off = get16 ();
f01070e4:	e8 68 e8 ff ff       	call   f0105951 <get16>
f01070e9:	89 c3                	mov    %eax,%ebx
f01070eb:	89 c6                	mov    %eax,%esi
f01070ed:	c1 fe 1f             	sar    $0x1f,%esi

  if (intel_syntax)
f01070f0:	80 3d 50 a1 1b f0 00 	cmpb   $0x0,0xf01ba150
f01070f7:	74 23                	je     f010711c <OP_OFF64+0x6c>
    {
      if (!(prefixes & (PREFIX_CS | PREFIX_SS | PREFIX_DS
f01070f9:	f7 05 64 9e 1b f0 f8 	testl  $0x1f8,0xf01b9e64
f0107100:	01 00 00 
f0107103:	75 17                	jne    f010711c <OP_OFF64+0x6c>
		        | PREFIX_ES | PREFIX_FS | PREFIX_GS)))
	{
	  oappend (names_seg[ds_reg - es_reg]);
f0107105:	a1 98 9f 1b f0       	mov    0xf01b9f98,%eax
f010710a:	8b 40 0c             	mov    0xc(%eax),%eax
f010710d:	e8 5b f0 ff ff       	call   f010616d <oappend>
	  oappend (":");
f0107112:	b8 4a b7 10 f0       	mov    $0xf010b74a,%eax
f0107117:	e8 51 f0 ff ff       	call   f010616d <oappend>
	}
    }
  print_operand_value (scratchbuf, sizeof(scratchbuf), 1, off);
f010711c:	89 1c 24             	mov    %ebx,(%esp)
f010711f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0107123:	b9 01 00 00 00       	mov    $0x1,%ecx
f0107128:	ba 64 00 00 00       	mov    $0x64,%edx
f010712d:	b8 00 9f 1b f0       	mov    $0xf01b9f00,%eax
f0107132:	e8 75 ee ff ff       	call   f0105fac <print_operand_value>
  oappend (scratchbuf);
f0107137:	b8 00 9f 1b f0       	mov    $0xf01b9f00,%eax
f010713c:	e8 2c f0 ff ff       	call   f010616d <oappend>
f0107141:	eb 67                	jmp    f01071aa <OP_OFF64+0xfa>
    {
      OP_OFF (bytemode, sizeflag);
      return;
    }

  append_seg ();
f0107143:	e8 68 fe ff ff       	call   f0106fb0 <append_seg>

  off = get64 ();
f0107148:	90                   	nop    
f0107149:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
f0107150:	e8 68 e6 ff ff       	call   f01057bd <get64>
f0107155:	89 c3                	mov    %eax,%ebx
f0107157:	89 d6                	mov    %edx,%esi

  if (intel_syntax)
f0107159:	80 3d 50 a1 1b f0 00 	cmpb   $0x0,0xf01ba150
f0107160:	74 23                	je     f0107185 <OP_OFF64+0xd5>
    {
      if (!(prefixes & (PREFIX_CS | PREFIX_SS | PREFIX_DS
f0107162:	f7 05 64 9e 1b f0 f8 	testl  $0x1f8,0xf01b9e64
f0107169:	01 00 00 
f010716c:	75 17                	jne    f0107185 <OP_OFF64+0xd5>
		        | PREFIX_ES | PREFIX_FS | PREFIX_GS)))
	{
	  oappend (names_seg[ds_reg - es_reg]);
f010716e:	a1 98 9f 1b f0       	mov    0xf01b9f98,%eax
f0107173:	8b 40 0c             	mov    0xc(%eax),%eax
f0107176:	e8 f2 ef ff ff       	call   f010616d <oappend>
	  oappend (":");
f010717b:	b8 4a b7 10 f0       	mov    $0xf010b74a,%eax
f0107180:	e8 e8 ef ff ff       	call   f010616d <oappend>
	}
    }
  print_operand_value (scratchbuf, sizeof(scratchbuf), 1, off);
f0107185:	89 1c 24             	mov    %ebx,(%esp)
f0107188:	89 74 24 04          	mov    %esi,0x4(%esp)
f010718c:	b9 01 00 00 00       	mov    $0x1,%ecx
f0107191:	ba 64 00 00 00       	mov    $0x64,%edx
f0107196:	b8 00 9f 1b f0       	mov    $0xf01b9f00,%eax
f010719b:	e8 0c ee ff ff       	call   f0105fac <print_operand_value>
  oappend (scratchbuf);
f01071a0:	b8 00 9f 1b f0       	mov    $0xf01b9f00,%eax
f01071a5:	e8 c3 ef ff ff       	call   f010616d <oappend>
}
f01071aa:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01071ad:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01071b0:	89 ec                	mov    %ebp,%esp
f01071b2:	5d                   	pop    %ebp
f01071b3:	c3                   	ret    

f01071b4 <OP_E>:

static void
OP_E (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f01071b4:	55                   	push   %ebp
f01071b5:	89 e5                	mov    %esp,%ebp
f01071b7:	57                   	push   %edi
f01071b8:	56                   	push   %esi
f01071b9:	53                   	push   %ebx
f01071ba:	83 ec 2c             	sub    $0x2c,%esp
  bfd_vma disp;
  int add = 0;
  int riprel = 0;
  USED_REX (REX_EXTZ);
f01071bd:	8b 0d 68 9e 1b f0    	mov    0xf01b9e68,%ecx
f01071c3:	f6 c1 01             	test   $0x1,%cl
f01071c6:	0f 84 d3 08 00 00    	je     f0107a9f <OP_E+0x8eb>
f01071cc:	a1 6c 9e 1b f0       	mov    0xf01b9e6c,%eax
f01071d1:	83 c8 41             	or     $0x41,%eax
f01071d4:	a3 6c 9e 1b f0       	mov    %eax,0xf01b9e6c
f01071d9:	bb 08 00 00 00       	mov    $0x8,%ebx
  if (rex & REX_EXTZ)
    add += 8;

  /* Skip mod/rm byte.  */
  MODRM_CHECK;
f01071de:	80 3d 80 9f 1b f0 00 	cmpb   $0x0,0xf01b9f80
f01071e5:	75 1c                	jne    f0107203 <OP_E+0x4f>
f01071e7:	c7 44 24 08 60 b7 10 	movl   $0xf010b760,0x8(%esp)
f01071ee:	f0 
f01071ef:	c7 44 24 04 b3 0b 00 	movl   $0xbb3,0x4(%esp)
f01071f6:	00 
f01071f7:	c7 04 24 a3 b6 10 f0 	movl   $0xf010b6a3,(%esp)
f01071fe:	e8 83 8e ff ff       	call   f0100086 <_panic>
  codep++;
f0107203:	8b 15 6c 9f 1b f0    	mov    0xf01b9f6c,%edx
f0107209:	83 c2 01             	add    $0x1,%edx
f010720c:	89 15 6c 9f 1b f0    	mov    %edx,0xf01b9f6c

  if (mod == 3)
f0107212:	83 3d 74 9f 1b f0 03 	cmpl   $0x3,0xf01b9f74
f0107219:	0f 85 8c 01 00 00    	jne    f01073ab <OP_E+0x1f7>
    {
      switch (bytemode)
f010721f:	83 7d 08 07          	cmpl   $0x7,0x8(%ebp)
f0107223:	0f 87 73 01 00 00    	ja     f010739c <OP_E+0x1e8>
f0107229:	8b 75 08             	mov    0x8(%ebp),%esi
f010722c:	ff 24 b5 dc ce 10 f0 	jmp    *-0xfef3124(,%esi,4)
	{
	case b_mode:
	  USED_REX (0);
f0107233:	83 c8 40             	or     $0x40,%eax
f0107236:	a3 6c 9e 1b f0       	mov    %eax,0xf01b9e6c
	  if (rex)
f010723b:	85 c9                	test   %ecx,%ecx
f010723d:	74 1b                	je     f010725a <OP_E+0xa6>
	    oappend (names8rex[rm + add]);
f010723f:	89 d8                	mov    %ebx,%eax
f0107241:	03 05 78 9f 1b f0    	add    0xf01b9f78,%eax
f0107247:	8b 15 94 9f 1b f0    	mov    0xf01b9f94,%edx
f010724d:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0107250:	e8 18 ef ff ff       	call   f010616d <oappend>
f0107255:	e9 83 08 00 00       	jmp    f0107add <OP_E+0x929>
	  else
	    oappend (names8[rm + add]);
f010725a:	89 d8                	mov    %ebx,%eax
f010725c:	03 05 78 9f 1b f0    	add    0xf01b9f78,%eax
f0107262:	8b 15 90 9f 1b f0    	mov    0xf01b9f90,%edx
f0107268:	8b 04 82             	mov    (%edx,%eax,4),%eax
f010726b:	e8 fd ee ff ff       	call   f010616d <oappend>
f0107270:	e9 68 08 00 00       	jmp    f0107add <OP_E+0x929>
	  break;
	case w_mode:
	  oappend (names16[rm + add]);
f0107275:	89 d8                	mov    %ebx,%eax
f0107277:	03 05 78 9f 1b f0    	add    0xf01b9f78,%eax
f010727d:	8b 15 8c 9f 1b f0    	mov    0xf01b9f8c,%edx
f0107283:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0107286:	e8 e2 ee ff ff       	call   f010616d <oappend>
f010728b:	e9 4d 08 00 00       	jmp    f0107add <OP_E+0x929>
	  break;
	case d_mode:
	  oappend (names32[rm + add]);
f0107290:	89 d8                	mov    %ebx,%eax
f0107292:	03 05 78 9f 1b f0    	add    0xf01b9f78,%eax
f0107298:	8b 15 88 9f 1b f0    	mov    0xf01b9f88,%edx
f010729e:	8b 04 82             	mov    (%edx,%eax,4),%eax
f01072a1:	e8 c7 ee ff ff       	call   f010616d <oappend>
f01072a6:	e9 32 08 00 00       	jmp    f0107add <OP_E+0x929>
	  break;
	case q_mode:
	  oappend (names64[rm + add]);
f01072ab:	89 d8                	mov    %ebx,%eax
f01072ad:	03 05 78 9f 1b f0    	add    0xf01b9f78,%eax
f01072b3:	8b 15 84 9f 1b f0    	mov    0xf01b9f84,%edx
f01072b9:	8b 04 82             	mov    (%edx,%eax,4),%eax
f01072bc:	e8 ac ee ff ff       	call   f010616d <oappend>
f01072c1:	e9 17 08 00 00       	jmp    f0107add <OP_E+0x929>
	  break;
	case m_mode:
	  if (mode_64bit)
f01072c6:	83 3d 60 9e 1b f0 00 	cmpl   $0x0,0xf01b9e60
f01072cd:	74 1b                	je     f01072ea <OP_E+0x136>
	    oappend (names64[rm + add]);
f01072cf:	89 d8                	mov    %ebx,%eax
f01072d1:	03 05 78 9f 1b f0    	add    0xf01b9f78,%eax
f01072d7:	8b 15 84 9f 1b f0    	mov    0xf01b9f84,%edx
f01072dd:	8b 04 82             	mov    (%edx,%eax,4),%eax
f01072e0:	e8 88 ee ff ff       	call   f010616d <oappend>
f01072e5:	e9 f3 07 00 00       	jmp    f0107add <OP_E+0x929>
	  else
	    oappend (names32[rm + add]);
f01072ea:	89 d8                	mov    %ebx,%eax
f01072ec:	03 05 78 9f 1b f0    	add    0xf01b9f78,%eax
f01072f2:	8b 15 88 9f 1b f0    	mov    0xf01b9f88,%edx
f01072f8:	8b 04 82             	mov    (%edx,%eax,4),%eax
f01072fb:	e8 6d ee ff ff       	call   f010616d <oappend>
f0107300:	e9 d8 07 00 00       	jmp    f0107add <OP_E+0x929>
	  break;
	case v_mode:
	  USED_REX (REX_MODE64);
f0107305:	f6 c1 08             	test   $0x8,%cl
f0107308:	0f 84 a0 07 00 00    	je     f0107aae <OP_E+0x8fa>
f010730e:	83 c8 48             	or     $0x48,%eax
f0107311:	a3 6c 9e 1b f0       	mov    %eax,0xf01b9e6c
	  if (rex & REX_MODE64)
	    oappend (names64[rm + add]);
f0107316:	89 da                	mov    %ebx,%edx
f0107318:	03 15 78 9f 1b f0    	add    0xf01b9f78,%edx
f010731e:	a1 84 9f 1b f0       	mov    0xf01b9f84,%eax
f0107323:	8b 04 90             	mov    (%eax,%edx,4),%eax
f0107326:	e8 42 ee ff ff       	call   f010616d <oappend>
f010732b:	eb 2e                	jmp    f010735b <OP_E+0x1a7>
	  else if (sizeflag & DFLAG)
	    oappend (names32[rm + add]);
f010732d:	89 d8                	mov    %ebx,%eax
f010732f:	03 05 78 9f 1b f0    	add    0xf01b9f78,%eax
f0107335:	8b 15 88 9f 1b f0    	mov    0xf01b9f88,%edx
f010733b:	8b 04 82             	mov    (%edx,%eax,4),%eax
f010733e:	e8 2a ee ff ff       	call   f010616d <oappend>
f0107343:	eb 16                	jmp    f010735b <OP_E+0x1a7>
	  else
	    oappend (names16[rm + add]);
f0107345:	89 d8                	mov    %ebx,%eax
f0107347:	03 05 78 9f 1b f0    	add    0xf01b9f78,%eax
f010734d:	8b 15 8c 9f 1b f0    	mov    0xf01b9f8c,%edx
f0107353:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0107356:	e8 12 ee ff ff       	call   f010616d <oappend>
	  used_prefixes |= (prefixes & PREFIX_DATA);
f010735b:	a1 64 9e 1b f0       	mov    0xf01b9e64,%eax
f0107360:	25 00 02 00 00       	and    $0x200,%eax
f0107365:	09 05 70 9e 1b f0    	or     %eax,0xf01b9e70
f010736b:	e9 6d 07 00 00       	jmp    f0107add <OP_E+0x929>
	  break;
	case 0:
	  if (!(codep[-2] == 0xAE && codep[-1] == 0xF8 /* sfence */)
f0107370:	80 7a fe ae          	cmpb   $0xae,-0x2(%edx)
f0107374:	75 1c                	jne    f0107392 <OP_E+0x1de>
f0107376:	0f b6 42 ff          	movzbl -0x1(%edx),%eax
f010737a:	3c f8                	cmp    $0xf8,%al
f010737c:	0f 84 5b 07 00 00    	je     f0107add <OP_E+0x929>
f0107382:	3c f0                	cmp    $0xf0,%al
f0107384:	0f 84 53 07 00 00    	je     f0107add <OP_E+0x929>
f010738a:	3c e8                	cmp    $0xe8,%al
f010738c:	0f 84 4b 07 00 00    	je     f0107add <OP_E+0x929>
	      && !(codep[-2] == 0xAE && codep[-1] == 0xF0 /* mfence */)
	      && !(codep[-2] == 0xAE && codep[-1] == 0xe8 /* lfence */))
	    BadOp ();	/* bad sfence,lea,lds,les,lfs,lgs,lss modrm */
f0107392:	e8 04 ee ff ff       	call   f010619b <BadOp>
f0107397:	e9 41 07 00 00       	jmp    f0107add <OP_E+0x929>
	  break;
	default:
	  oappend (INTERNAL_DISASSEMBLER_ERROR);
f010739c:	b8 1e b7 10 f0       	mov    $0xf010b71e,%eax
f01073a1:	e8 c7 ed ff ff       	call   f010616d <oappend>
f01073a6:	e9 32 07 00 00       	jmp    f0107add <OP_E+0x929>
	}
      return;
    }

  disp = 0;
  append_seg ();
f01073ab:	e8 00 fc ff ff       	call   f0106fb0 <append_seg>
  //cprintf("append_seg:obufp=%s op1out=%s\n",obufp,op1out);
  if ((sizeflag & AFLAG) || mode_64bit) /* 32 bit address mode */
f01073b0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01073b3:	83 e0 02             	and    $0x2,%eax
f01073b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01073b9:	75 0d                	jne    f01073c8 <OP_E+0x214>
f01073bb:	83 3d 60 9e 1b f0 00 	cmpl   $0x0,0xf01b9e60
f01073c2:	0f 84 85 05 00 00    	je     f010794d <OP_E+0x799>
      int index = 0;
      int scale = 0;

      havesib = 0;
      havebase = 1;
      base = rm;
f01073c8:	8b 3d 78 9f 1b f0    	mov    0xf01b9f78,%edi
      //cprintf("base=%d\n",base);
     // panic("*****************");
      if (base == 4)
f01073ce:	83 ff 04             	cmp    $0x4,%edi
f01073d1:	74 1a                	je     f01073ed <OP_E+0x239>
f01073d3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01073da:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f01073e1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f01073e8:	e9 9e 00 00 00       	jmp    f010748b <OP_E+0x2d7>
	{
	  havesib = 1;
	  FETCH_DATA (the_info, codep + 1);
f01073ed:	8b 15 6c 9f 1b f0    	mov    0xf01b9f6c,%edx
f01073f3:	83 c2 01             	add    $0x1,%edx
f01073f6:	8b 0d 70 9f 1b f0    	mov    0xf01b9f70,%ecx
f01073fc:	8b 41 20             	mov    0x20(%ecx),%eax
f01073ff:	3b 10                	cmp    (%eax),%edx
f0107401:	76 07                	jbe    f010740a <OP_E+0x256>
f0107403:	89 c8                	mov    %ecx,%eax
f0107405:	e8 e6 e1 ff ff       	call   f01055f0 <fetch_data>
	  scale = (*codep >> 6) & 3;
f010740a:	8b 15 6c 9f 1b f0    	mov    0xf01b9f6c,%edx
f0107410:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0107413:	0f b6 1a             	movzbl (%edx),%ebx
	  index = (*codep >> 3) & 7;
f0107416:	89 d8                	mov    %ebx,%eax
f0107418:	c0 e8 03             	shr    $0x3,%al
f010741b:	89 c1                	mov    %eax,%ecx
f010741d:	83 e1 07             	and    $0x7,%ecx
f0107420:	89 4d e8             	mov    %ecx,-0x18(%ebp)
	  base = *codep & 7;
f0107423:	bf 07 00 00 00       	mov    $0x7,%edi
f0107428:	21 df                	and    %ebx,%edi
	  USED_REX (REX_EXTY);
f010742a:	a1 68 9e 1b f0       	mov    0xf01b9e68,%eax
f010742f:	89 c1                	mov    %eax,%ecx
f0107431:	83 e1 02             	and    $0x2,%ecx
f0107434:	83 f9 01             	cmp    $0x1,%ecx
f0107437:	19 d2                	sbb    %edx,%edx
f0107439:	f7 d2                	not    %edx
f010743b:	83 e2 42             	and    $0x42,%edx
f010743e:	0b 15 6c 9e 1b f0    	or     0xf01b9e6c,%edx
	  USED_REX (REX_EXTZ);
f0107444:	83 e0 01             	and    $0x1,%eax
f0107447:	89 c6                	mov    %eax,%esi
f0107449:	89 f0                	mov    %esi,%eax
f010744b:	c1 e0 1f             	shl    $0x1f,%eax
f010744e:	c1 f8 1f             	sar    $0x1f,%eax
f0107451:	83 e0 41             	and    $0x41,%eax
f0107454:	09 d0                	or     %edx,%eax
f0107456:	a3 6c 9e 1b f0       	mov    %eax,0xf01b9e6c
	  //cprintf("esp_insn1:codep=%x scale=%d index=%d\n",*codep,scale,index);
	  //panic("*****************");
	  if (rex & REX_EXTY)
f010745b:	85 c9                	test   %ecx,%ecx
f010745d:	74 04                	je     f0107463 <OP_E+0x2af>
	    index += 8;
f010745f:	83 45 e8 08          	addl   $0x8,-0x18(%ebp)
	  if (rex & REX_EXTZ)
f0107463:	89 f0                	mov    %esi,%eax
f0107465:	84 c0                	test   %al,%al
f0107467:	74 03                	je     f010746c <OP_E+0x2b8>
	    base += 8;
f0107469:	83 c7 08             	add    $0x8,%edi
     // panic("*****************");
      if (base == 4)
	{
	  havesib = 1;
	  FETCH_DATA (the_info, codep + 1);
	  scale = (*codep >> 6) & 3;
f010746c:	89 d8                	mov    %ebx,%eax
f010746e:	c0 e8 06             	shr    $0x6,%al
f0107471:	89 c2                	mov    %eax,%edx
f0107473:	83 e2 03             	and    $0x3,%edx
f0107476:	89 55 ec             	mov    %edx,-0x14(%ebp)
	  if (rex & REX_EXTY)
	    index += 8;
	  if (rex & REX_EXTZ)
	    base += 8;
	  //cprintf("esp_insn2:codep=%x scale=%d index=%d mod=%x base=%x\n",*codep,scale,index,mod,base);
	  codep++;
f0107479:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010747c:	83 c0 01             	add    $0x1,%eax
f010747f:	a3 6c 9f 1b f0       	mov    %eax,0xf01b9f6c
f0107484:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
	  
	}

      switch (mod)
f010748b:	a1 74 9f 1b f0       	mov    0xf01b9f74,%eax
f0107490:	83 f8 01             	cmp    $0x1,%eax
f0107493:	74 59                	je     f01074ee <OP_E+0x33a>
f0107495:	83 f8 02             	cmp    $0x2,%eax
f0107498:	0f 84 ad 00 00 00    	je     f010754b <OP_E+0x397>
f010749e:	85 c0                	test   %eax,%eax
f01074a0:	0f 85 be 00 00 00    	jne    f0107564 <OP_E+0x3b0>
	{
	case 0:
	  if ((base & 7) == 5)
f01074a6:	89 f8                	mov    %edi,%eax
f01074a8:	83 e0 07             	and    $0x7,%eax
f01074ab:	83 f8 05             	cmp    $0x5,%eax
f01074ae:	0f 85 b0 00 00 00    	jne    f0107564 <OP_E+0x3b0>
	    {
	      havebase = 0;
	      if (mode_64bit && !havesib && (sizeflag & AFLAG))
f01074b4:	83 3d 60 9e 1b f0 00 	cmpl   $0x0,0xf01b9e60
f01074bb:	74 06                	je     f01074c3 <OP_E+0x30f>
f01074bd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01074c1:	74 09                	je     f01074cc <OP_E+0x318>
f01074c3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01074ca:	eb 0d                	jmp    f01074d9 <OP_E+0x325>
f01074cc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01074d0:	0f 95 c0             	setne  %al
f01074d3:	0f b6 c0             	movzbl %al,%eax
f01074d6:	89 45 dc             	mov    %eax,-0x24(%ebp)
		riprel = 1;
	      disp = get32s ();
f01074d9:	e8 ed e3 ff ff       	call   f01058cb <get32s>
f01074de:	89 c3                	mov    %eax,%ebx
f01074e0:	89 d6                	mov    %edx,%esi
f01074e2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01074e9:	e9 8e 00 00 00       	jmp    f010757c <OP_E+0x3c8>
	    }
	  break;
	case 1:
	  FETCH_DATA (the_info, codep + 1);
f01074ee:	8b 15 6c 9f 1b f0    	mov    0xf01b9f6c,%edx
f01074f4:	83 c2 01             	add    $0x1,%edx
f01074f7:	8b 0d 70 9f 1b f0    	mov    0xf01b9f70,%ecx
f01074fd:	8b 41 20             	mov    0x20(%ecx),%eax
f0107500:	3b 10                	cmp    (%eax),%edx
f0107502:	76 07                	jbe    f010750b <OP_E+0x357>
f0107504:	89 c8                	mov    %ecx,%eax
f0107506:	e8 e5 e0 ff ff       	call   f01055f0 <fetch_data>
	  disp = *codep++;
f010750b:	a1 6c 9f 1b f0       	mov    0xf01b9f6c,%eax
f0107510:	0f b6 18             	movzbl (%eax),%ebx
f0107513:	be 00 00 00 00       	mov    $0x0,%esi
f0107518:	83 c0 01             	add    $0x1,%eax
f010751b:	a3 6c 9f 1b f0       	mov    %eax,0xf01b9f6c
	  if ((disp & 0x80) != 0)
f0107520:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0107527:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f010752e:	84 db                	test   %bl,%bl
f0107530:	79 4a                	jns    f010757c <OP_E+0x3c8>
	    disp -= 0x100;
f0107532:	81 c3 00 ff ff ff    	add    $0xffffff00,%ebx
f0107538:	83 d6 ff             	adc    $0xffffffff,%esi
f010753b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0107542:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0107549:	eb 31                	jmp    f010757c <OP_E+0x3c8>
	  break;
	case 2:
	  disp = get32s ();
f010754b:	e8 7b e3 ff ff       	call   f01058cb <get32s>
f0107550:	89 c3                	mov    %eax,%ebx
f0107552:	89 d6                	mov    %edx,%esi
f0107554:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f010755b:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0107562:	eb 18                	jmp    f010757c <OP_E+0x3c8>
f0107564:	bb 00 00 00 00       	mov    $0x0,%ebx
f0107569:	be 00 00 00 00       	mov    $0x0,%esi
f010756e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0107575:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
	  break;
	}
      //cprintf("intel_syntax=%d\n",intel_syntax);
      if (!intel_syntax)
f010757c:	80 3d 50 a1 1b f0 00 	cmpb   $0x0,0xf01ba150
f0107583:	75 5b                	jne    f01075e0 <OP_E+0x42c>
        if (mod != 0 || (base & 7) == 5)
f0107585:	83 3d 74 9f 1b f0 00 	cmpl   $0x0,0xf01b9f74
f010758c:	75 0a                	jne    f0107598 <OP_E+0x3e4>
f010758e:	89 f8                	mov    %edi,%eax
f0107590:	83 e0 07             	and    $0x7,%eax
f0107593:	83 f8 05             	cmp    $0x5,%eax
f0107596:	75 48                	jne    f01075e0 <OP_E+0x42c>
          {
            print_operand_value (scratchbuf, sizeof(scratchbuf), !riprel, disp);
f0107598:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010759c:	0f 94 c1             	sete   %cl
f010759f:	0f b6 c9             	movzbl %cl,%ecx
f01075a2:	89 1c 24             	mov    %ebx,(%esp)
f01075a5:	89 74 24 04          	mov    %esi,0x4(%esp)
f01075a9:	ba 64 00 00 00       	mov    $0x64,%edx
f01075ae:	b8 00 9f 1b f0       	mov    $0xf01b9f00,%eax
f01075b3:	e8 f4 e9 ff ff       	call   f0105fac <print_operand_value>
            oappend (scratchbuf);
f01075b8:	b8 00 9f 1b f0       	mov    $0xf01b9f00,%eax
f01075bd:	e8 ab eb ff ff       	call   f010616d <oappend>
	    if (riprel)
f01075c2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01075c6:	74 18                	je     f01075e0 <OP_E+0x42c>
	      {
		set_op (disp, 1);
f01075c8:	b9 01 00 00 00       	mov    $0x1,%ecx
f01075cd:	89 d8                	mov    %ebx,%eax
f01075cf:	89 f2                	mov    %esi,%edx
f01075d1:	e8 bb e3 ff ff       	call   f0105991 <set_op>
		oappend ("(%rip)");
f01075d6:	b8 6c b7 10 f0       	mov    $0xf010b76c,%eax
f01075db:	e8 8d eb ff ff       	call   f010616d <oappend>
	      }
          }
      //cprintf("havebase=%d havesib=%d\n",havebase,havesib);
      if (havebase || (havesib && (index != 4 || scale != 0)))
f01075e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01075e4:	75 1a                	jne    f0107600 <OP_E+0x44c>
f01075e6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01075ea:	0f 84 ec 02 00 00    	je     f01078dc <OP_E+0x728>
f01075f0:	83 7d e8 04          	cmpl   $0x4,-0x18(%ebp)
f01075f4:	75 0a                	jne    f0107600 <OP_E+0x44c>
f01075f6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f01075fa:	0f 84 dc 02 00 00    	je     f01078dc <OP_E+0x728>
	{
          if (intel_syntax)
f0107600:	80 3d 50 a1 1b f0 00 	cmpb   $0x0,0xf01ba150
f0107607:	0f 84 b5 04 00 00    	je     f0107ac2 <OP_E+0x90e>
            {
              switch (bytemode)
f010760d:	83 7d 08 07          	cmpl   $0x7,0x8(%ebp)
f0107611:	77 69                	ja     f010767c <OP_E+0x4c8>
f0107613:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0107616:	ff 24 8d fc ce 10 f0 	jmp    *-0xfef3104(,%ecx,4)
                {
                case b_mode:
                  oappend ("BYTE PTR ");
f010761d:	b8 73 b7 10 f0       	mov    $0xf010b773,%eax
f0107622:	e8 46 eb ff ff       	call   f010616d <oappend>
f0107627:	eb 53                	jmp    f010767c <OP_E+0x4c8>
                  break;
                case w_mode:
                  oappend ("WORD PTR ");
f0107629:	b8 7e b7 10 f0       	mov    $0xf010b77e,%eax
f010762e:	e8 3a eb ff ff       	call   f010616d <oappend>
f0107633:	eb 47                	jmp    f010767c <OP_E+0x4c8>
                  break;
                case v_mode:
                  oappend ("DWORD PTR ");
f0107635:	b8 7d b7 10 f0       	mov    $0xf010b77d,%eax
f010763a:	e8 2e eb ff ff       	call   f010616d <oappend>
f010763f:	90                   	nop    
f0107640:	eb 3a                	jmp    f010767c <OP_E+0x4c8>
                  break;
                case d_mode:
                  oappend ("QWORD PTR ");
f0107642:	b8 88 b7 10 f0       	mov    $0xf010b788,%eax
f0107647:	e8 21 eb ff ff       	call   f010616d <oappend>
f010764c:	eb 2e                	jmp    f010767c <OP_E+0x4c8>
                  break;
                case m_mode:
		  if (mode_64bit)
f010764e:	83 3d 60 9e 1b f0 00 	cmpl   $0x0,0xf01b9e60
f0107655:	74 0c                	je     f0107663 <OP_E+0x4af>
		    oappend ("DWORD PTR ");
f0107657:	b8 7d b7 10 f0       	mov    $0xf010b77d,%eax
f010765c:	e8 0c eb ff ff       	call   f010616d <oappend>
f0107661:	eb 19                	jmp    f010767c <OP_E+0x4c8>
		  else
		    oappend ("QWORD PTR ");
f0107663:	b8 88 b7 10 f0       	mov    $0xf010b788,%eax
f0107668:	e8 00 eb ff ff       	call   f010616d <oappend>
f010766d:	8d 76 00             	lea    0x0(%esi),%esi
f0107670:	eb 0a                	jmp    f010767c <OP_E+0x4c8>
		  break;
                case x_mode:
                  oappend ("XWORD PTR ");
f0107672:	b8 93 b7 10 f0       	mov    $0xf010b793,%eax
f0107677:	e8 f1 ea ff ff       	call   f010616d <oappend>
                default:
                  break;
                }
             }
         // cprintf("aaaaaaaaaaaaaaa\n");
	  *obufp++ = open_char;
f010767c:	a1 e4 9e 1b f0       	mov    0xf01b9ee4,%eax
f0107681:	0f b6 15 51 a1 1b f0 	movzbl 0xf01ba151,%edx
f0107688:	88 10                	mov    %dl,(%eax)
f010768a:	83 c0 01             	add    $0x1,%eax
f010768d:	a3 e4 9e 1b f0       	mov    %eax,0xf01b9ee4
	  if (intel_syntax && riprel)
f0107692:	80 3d 50 a1 1b f0 00 	cmpb   $0x0,0xf01ba150
f0107699:	74 10                	je     f01076ab <OP_E+0x4f7>
f010769b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010769f:	74 0a                	je     f01076ab <OP_E+0x4f7>
	    oappend ("rip + ");
f01076a1:	b8 9e b7 10 f0       	mov    $0xf010b79e,%eax
f01076a6:	e8 c2 ea ff ff       	call   f010616d <oappend>
          *obufp = '\0';
f01076ab:	a1 e4 9e 1b f0       	mov    0xf01b9ee4,%eax
f01076b0:	c6 00 00             	movb   $0x0,(%eax)
	  USED_REX (REX_EXTZ);
f01076b3:	0f b6 15 68 9e 1b f0 	movzbl 0xf01b9e68,%edx
f01076ba:	83 e2 01             	and    $0x1,%edx
f01076bd:	89 d0                	mov    %edx,%eax
f01076bf:	c1 e0 1f             	shl    $0x1f,%eax
f01076c2:	c1 f8 1f             	sar    $0x1f,%eax
f01076c5:	83 e0 41             	and    $0x41,%eax
f01076c8:	09 05 6c 9e 1b f0    	or     %eax,0xf01b9e6c
	  if (!havesib && (rex & REX_EXTZ))
f01076ce:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01076d2:	75 07                	jne    f01076db <OP_E+0x527>
f01076d4:	84 d2                	test   %dl,%dl
f01076d6:	74 03                	je     f01076db <OP_E+0x527>
	    base += 8;
f01076d8:	83 c7 08             	add    $0x8,%edi
	  if (havebase)
f01076db:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01076df:	74 26                	je     f0107707 <OP_E+0x553>
	    oappend (mode_64bit && (sizeflag & AFLAG)
f01076e1:	83 3d 60 9e 1b f0 00 	cmpl   $0x0,0xf01b9e60
f01076e8:	74 10                	je     f01076fa <OP_E+0x546>
f01076ea:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01076ee:	74 0a                	je     f01076fa <OP_E+0x546>
f01076f0:	a1 84 9f 1b f0       	mov    0xf01b9f84,%eax
f01076f5:	8b 04 b8             	mov    (%eax,%edi,4),%eax
f01076f8:	eb 08                	jmp    f0107702 <OP_E+0x54e>
f01076fa:	a1 88 9f 1b f0       	mov    0xf01b9f88,%eax
f01076ff:	8b 04 b8             	mov    (%eax,%edi,4),%eax
f0107702:	e8 66 ea ff ff       	call   f010616d <oappend>
		     ? names64[base] : names32[base]);
	  if (havesib)
f0107707:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010770b:	0f 84 41 01 00 00    	je     f0107852 <OP_E+0x69e>
	    {
	      if (index != 4)
f0107711:	83 7d e8 04          	cmpl   $0x4,-0x18(%ebp)
f0107715:	0f 84 c4 00 00 00    	je     f01077df <OP_E+0x62b>
		{
                  if (intel_syntax)
f010771b:	80 3d 50 a1 1b f0 00 	cmpb   $0x0,0xf01ba150
f0107722:	74 6a                	je     f010778e <OP_E+0x5da>
                    {
                      if (havebase)
f0107724:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0107728:	74 1b                	je     f0107745 <OP_E+0x591>
                        {
                          *obufp++ = separator_char;
f010772a:	a1 e4 9e 1b f0       	mov    0xf01b9ee4,%eax
f010772f:	0f b6 15 53 a1 1b f0 	movzbl 0xf01ba153,%edx
f0107736:	88 10                	mov    %dl,(%eax)
f0107738:	8d 50 01             	lea    0x1(%eax),%edx
f010773b:	89 15 e4 9e 1b f0    	mov    %edx,0xf01b9ee4
                          *obufp = '\0';
f0107741:	c6 40 01 00          	movb   $0x0,0x1(%eax)
                        }
                      snprintf (scratchbuf, sizeof(scratchbuf), "%s",
f0107745:	83 3d 60 9e 1b f0 00 	cmpl   $0x0,0xf01b9e60
f010774c:	74 13                	je     f0107761 <OP_E+0x5ad>
f010774e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0107752:	74 0d                	je     f0107761 <OP_E+0x5ad>
f0107754:	a1 84 9f 1b f0       	mov    0xf01b9f84,%eax
f0107759:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010775c:	8b 04 90             	mov    (%eax,%edx,4),%eax
f010775f:	eb 0b                	jmp    f010776c <OP_E+0x5b8>
f0107761:	a1 88 9f 1b f0       	mov    0xf01b9f88,%eax
f0107766:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0107769:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f010776c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107770:	c7 44 24 08 5e ae 10 	movl   $0xf010ae5e,0x8(%esp)
f0107777:	f0 
f0107778:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f010777f:	00 
f0107780:	c7 04 24 00 9f 1b f0 	movl   $0xf01b9f00,(%esp)
f0107787:	e8 6e 1b 00 00       	call   f01092fa <snprintf>
f010778c:	eb 47                	jmp    f01077d5 <OP_E+0x621>
                                mode_64bit && (sizeflag & AFLAG)
                                ? names64[index] : names32[index]);
                    }
                  else
                      snprintf (scratchbuf, sizeof(scratchbuf), ",%s",
f010778e:	83 3d 60 9e 1b f0 00 	cmpl   $0x0,0xf01b9e60
f0107795:	74 13                	je     f01077aa <OP_E+0x5f6>
f0107797:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010779b:	74 0d                	je     f01077aa <OP_E+0x5f6>
f010779d:	a1 84 9f 1b f0       	mov    0xf01b9f84,%eax
f01077a2:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01077a5:	8b 04 90             	mov    (%eax,%edx,4),%eax
f01077a8:	eb 0b                	jmp    f01077b5 <OP_E+0x601>
f01077aa:	a1 88 9f 1b f0       	mov    0xf01b9f88,%eax
f01077af:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01077b2:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01077b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01077b9:	c7 44 24 08 a5 b7 10 	movl   $0xf010b7a5,0x8(%esp)
f01077c0:	f0 
f01077c1:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f01077c8:	00 
f01077c9:	c7 04 24 00 9f 1b f0 	movl   $0xf01b9f00,(%esp)
f01077d0:	e8 25 1b 00 00       	call   f01092fa <snprintf>
                                mode_64bit && (sizeflag & AFLAG)
                                ? names64[index] : names32[index]);
		  oappend (scratchbuf);
f01077d5:	b8 00 9f 1b f0       	mov    $0xf01b9f00,%eax
f01077da:	e8 8e e9 ff ff       	call   f010616d <oappend>
		}
              if (!intel_syntax
f01077df:	80 3d 50 a1 1b f0 00 	cmpb   $0x0,0xf01ba150
f01077e6:	74 12                	je     f01077fa <OP_E+0x646>
f01077e8:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f01077ec:	74 6d                	je     f010785b <OP_E+0x6a7>
f01077ee:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f01077f2:	74 67                	je     f010785b <OP_E+0x6a7>
f01077f4:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f01077f8:	74 61                	je     f010785b <OP_E+0x6a7>
                  || (intel_syntax
                      && bytemode != b_mode
                      && bytemode != w_mode
                      && bytemode != v_mode))
                {
                  if(scale){
f01077fa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f01077fe:	66 90                	xchg   %ax,%ax
f0107800:	74 50                	je     f0107852 <OP_E+0x69e>
                       *obufp++ = scale_char;
f0107802:	8b 15 e4 9e 1b f0    	mov    0xf01b9ee4,%edx
f0107808:	0f b6 05 54 a1 1b f0 	movzbl 0xf01ba154,%eax
f010780f:	88 02                	mov    %al,(%edx)
f0107811:	8d 42 01             	lea    0x1(%edx),%eax
f0107814:	a3 e4 9e 1b f0       	mov    %eax,0xf01b9ee4
                       *obufp = '\0';
f0107819:	c6 42 01 00          	movb   $0x0,0x1(%edx)
                       snprintf (scratchbuf, sizeof(scratchbuf), "%d", 1 << scale);
f010781d:	b8 01 00 00 00       	mov    $0x1,%eax
f0107822:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0107826:	d3 e0                	shl    %cl,%eax
f0107828:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010782c:	c7 44 24 08 bd 3a 11 	movl   $0xf0113abd,0x8(%esp)
f0107833:	f0 
f0107834:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f010783b:	00 
f010783c:	c7 04 24 00 9f 1b f0 	movl   $0xf01b9f00,(%esp)
f0107843:	e8 b2 1a 00 00       	call   f01092fa <snprintf>
	               oappend (scratchbuf);
f0107848:	b8 00 9f 1b f0       	mov    $0xf01b9f00,%eax
f010784d:	e8 1b e9 ff ff       	call   f010616d <oappend>
		  }
                }
		//cprintf("obufp=%s op1out=%s scale=%d scale1=%d\n",obufp,op1out,1<<scale,scale);
	    }
	  //cprintf("bbbbbbbbbbbbbbbbbbbbbbbb\n");
          if (intel_syntax)
f0107852:	80 3d 50 a1 1b f0 00 	cmpb   $0x0,0xf01ba150
f0107859:	74 61                	je     f01078bc <OP_E+0x708>
            if (mod != 0 || (base & 7) == 5)
f010785b:	83 3d 74 9f 1b f0 00 	cmpl   $0x0,0xf01b9f74
f0107862:	75 0a                	jne    f010786e <OP_E+0x6ba>
f0107864:	89 f8                	mov    %edi,%eax
f0107866:	83 e0 07             	and    $0x7,%eax
f0107869:	83 f8 05             	cmp    $0x5,%eax
f010786c:	75 4e                	jne    f01078bc <OP_E+0x708>
              {
		/* Don't print zero displacements.  */
                if (disp != 0)
f010786e:	89 f0                	mov    %esi,%eax
f0107870:	09 d8                	or     %ebx,%eax
f0107872:	74 48                	je     f01078bc <OP_E+0x708>
                  {
		    if ((bfd_signed_vma) disp > 0)
f0107874:	85 f6                	test   %esi,%esi
f0107876:	78 1f                	js     f0107897 <OP_E+0x6e3>
f0107878:	85 f6                	test   %esi,%esi
f010787a:	7f 06                	jg     f0107882 <OP_E+0x6ce>
f010787c:	83 fb 00             	cmp    $0x0,%ebx
f010787f:	90                   	nop    
f0107880:	76 15                	jbe    f0107897 <OP_E+0x6e3>
		      {
			*obufp++ = '+';
f0107882:	a1 e4 9e 1b f0       	mov    0xf01b9ee4,%eax
f0107887:	c6 00 2b             	movb   $0x2b,(%eax)
f010788a:	8d 50 01             	lea    0x1(%eax),%edx
f010788d:	89 15 e4 9e 1b f0    	mov    %edx,0xf01b9ee4
			*obufp = '\0';
f0107893:	c6 40 01 00          	movb   $0x0,0x1(%eax)
		      }

                    print_operand_value (scratchbuf, sizeof(scratchbuf), 0,
f0107897:	89 1c 24             	mov    %ebx,(%esp)
f010789a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010789e:	b9 00 00 00 00       	mov    $0x0,%ecx
f01078a3:	ba 64 00 00 00       	mov    $0x64,%edx
f01078a8:	b8 00 9f 1b f0       	mov    $0xf01b9f00,%eax
f01078ad:	e8 fa e6 ff ff       	call   f0105fac <print_operand_value>
                                         disp);
                    oappend (scratchbuf);
f01078b2:	b8 00 9f 1b f0       	mov    $0xf01b9f00,%eax
f01078b7:	e8 b1 e8 ff ff       	call   f010616d <oappend>
                  }
              }

	  *obufp++ = close_char;
f01078bc:	a1 e4 9e 1b f0       	mov    0xf01b9ee4,%eax
f01078c1:	0f b6 15 52 a1 1b f0 	movzbl 0xf01ba152,%edx
f01078c8:	88 10                	mov    %dl,(%eax)
f01078ca:	8d 50 01             	lea    0x1(%eax),%edx
f01078cd:	89 15 e4 9e 1b f0    	mov    %edx,0xf01b9ee4
          *obufp = '\0';	
f01078d3:	c6 40 01 00          	movb   $0x0,0x1(%eax)
f01078d7:	e9 01 02 00 00       	jmp    f0107add <OP_E+0x929>
	}
      else if (intel_syntax)
f01078dc:	80 3d 50 a1 1b f0 00 	cmpb   $0x0,0xf01ba150
f01078e3:	0f 84 f4 01 00 00    	je     f0107add <OP_E+0x929>
        {
          if (mod != 0 || (base & 7) == 5)
f01078e9:	83 3d 74 9f 1b f0 00 	cmpl   $0x0,0xf01b9f74
f01078f0:	75 0e                	jne    f0107900 <OP_E+0x74c>
f01078f2:	89 f8                	mov    %edi,%eax
f01078f4:	83 e0 07             	and    $0x7,%eax
f01078f7:	83 f8 05             	cmp    $0x5,%eax
f01078fa:	0f 85 dd 01 00 00    	jne    f0107add <OP_E+0x929>
            {
	      if (prefixes & (PREFIX_CS | PREFIX_SS | PREFIX_DS
f0107900:	f7 05 64 9e 1b f0 f8 	testl  $0x1f8,0xf01b9e64
f0107907:	01 00 00 
f010790a:	75 17                	jne    f0107923 <OP_E+0x76f>
			      | PREFIX_ES | PREFIX_FS | PREFIX_GS))
		;
	      else
		{
		  oappend (names_seg[ds_reg - es_reg]);
f010790c:	a1 98 9f 1b f0       	mov    0xf01b9f98,%eax
f0107911:	8b 40 0c             	mov    0xc(%eax),%eax
f0107914:	e8 54 e8 ff ff       	call   f010616d <oappend>
		  oappend (":");
f0107919:	b8 4a b7 10 f0       	mov    $0xf010b74a,%eax
f010791e:	e8 4a e8 ff ff       	call   f010616d <oappend>
		}
              print_operand_value (scratchbuf, sizeof(scratchbuf), 1, disp);
f0107923:	89 1c 24             	mov    %ebx,(%esp)
f0107926:	89 74 24 04          	mov    %esi,0x4(%esp)
f010792a:	b9 01 00 00 00       	mov    $0x1,%ecx
f010792f:	ba 64 00 00 00       	mov    $0x64,%edx
f0107934:	b8 00 9f 1b f0       	mov    $0xf01b9f00,%eax
f0107939:	e8 6e e6 ff ff       	call   f0105fac <print_operand_value>
              oappend (scratchbuf);
f010793e:	b8 00 9f 1b f0       	mov    $0xf01b9f00,%eax
f0107943:	e8 25 e8 ff ff       	call   f010616d <oappend>
f0107948:	e9 90 01 00 00       	jmp    f0107add <OP_E+0x929>
	//cprintf("obufp=%s op1out=%s\n",obufp,op1out);
    	//panic("**************");
    }
  else
    { /* 16 bit address mode */
      switch (mod)
f010794d:	a1 74 9f 1b f0       	mov    0xf01b9f74,%eax
f0107952:	83 f8 01             	cmp    $0x1,%eax
f0107955:	74 36                	je     f010798d <OP_E+0x7d9>
f0107957:	83 f8 02             	cmp    $0x2,%eax
f010795a:	74 72                	je     f01079ce <OP_E+0x81a>
f010795c:	85 c0                	test   %eax,%eax
f010795e:	0f 85 86 00 00 00    	jne    f01079ea <OP_E+0x836>
	{
	case 0:
	  if ((rm & 7) == 6)
f0107964:	a1 78 9f 1b f0       	mov    0xf01b9f78,%eax
f0107969:	83 e0 07             	and    $0x7,%eax
f010796c:	83 f8 06             	cmp    $0x6,%eax
f010796f:	75 79                	jne    f01079ea <OP_E+0x836>
	    {
	      disp = get16 ();
f0107971:	e8 db df ff ff       	call   f0105951 <get16>
f0107976:	89 c2                	mov    %eax,%edx
f0107978:	89 c1                	mov    %eax,%ecx
f010797a:	c1 f9 1f             	sar    $0x1f,%ecx
	      if ((disp & 0x8000) != 0)
f010797d:	66 85 c0             	test   %ax,%ax
f0107980:	79 72                	jns    f01079f4 <OP_E+0x840>
		disp -= 0x10000;
f0107982:	81 c2 00 00 ff ff    	add    $0xffff0000,%edx
f0107988:	83 d1 ff             	adc    $0xffffffff,%ecx
f010798b:	eb 67                	jmp    f01079f4 <OP_E+0x840>
	    }
	  break;
	case 1:
	  FETCH_DATA (the_info, codep + 1);
f010798d:	8b 15 6c 9f 1b f0    	mov    0xf01b9f6c,%edx
f0107993:	83 c2 01             	add    $0x1,%edx
f0107996:	8b 0d 70 9f 1b f0    	mov    0xf01b9f70,%ecx
f010799c:	8b 41 20             	mov    0x20(%ecx),%eax
f010799f:	3b 10                	cmp    (%eax),%edx
f01079a1:	76 07                	jbe    f01079aa <OP_E+0x7f6>
f01079a3:	89 c8                	mov    %ecx,%eax
f01079a5:	e8 46 dc ff ff       	call   f01055f0 <fetch_data>
	  disp = *codep++;
f01079aa:	a1 6c 9f 1b f0       	mov    0xf01b9f6c,%eax
f01079af:	0f b6 10             	movzbl (%eax),%edx
f01079b2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01079b7:	83 c0 01             	add    $0x1,%eax
f01079ba:	a3 6c 9f 1b f0       	mov    %eax,0xf01b9f6c
	  if ((disp & 0x80) != 0)
f01079bf:	84 d2                	test   %dl,%dl
f01079c1:	79 31                	jns    f01079f4 <OP_E+0x840>
	    disp -= 0x100;
f01079c3:	81 c2 00 ff ff ff    	add    $0xffffff00,%edx
f01079c9:	83 d1 ff             	adc    $0xffffffff,%ecx
f01079cc:	eb 26                	jmp    f01079f4 <OP_E+0x840>
	  break;
	case 2:
	  disp = get16 ();
f01079ce:	e8 7e df ff ff       	call   f0105951 <get16>
f01079d3:	89 c2                	mov    %eax,%edx
f01079d5:	89 c1                	mov    %eax,%ecx
f01079d7:	c1 f9 1f             	sar    $0x1f,%ecx
	  if ((disp & 0x8000) != 0)
f01079da:	66 85 c0             	test   %ax,%ax
f01079dd:	79 15                	jns    f01079f4 <OP_E+0x840>
	    disp -= 0x10000;
f01079df:	81 c2 00 00 ff ff    	add    $0xffff0000,%edx
f01079e5:	83 d1 ff             	adc    $0xffffffff,%ecx
f01079e8:	eb 0a                	jmp    f01079f4 <OP_E+0x840>
f01079ea:	ba 00 00 00 00       	mov    $0x0,%edx
f01079ef:	b9 00 00 00 00       	mov    $0x0,%ecx
	  break;
	}

      if (!intel_syntax)
f01079f4:	80 3d 50 a1 1b f0 00 	cmpb   $0x0,0xf01ba150
f01079fb:	75 3b                	jne    f0107a38 <OP_E+0x884>
        if (mod != 0 || (rm & 7) == 6)
f01079fd:	83 3d 74 9f 1b f0 00 	cmpl   $0x0,0xf01b9f74
f0107a04:	75 0d                	jne    f0107a13 <OP_E+0x85f>
f0107a06:	a1 78 9f 1b f0       	mov    0xf01b9f78,%eax
f0107a0b:	83 e0 07             	and    $0x7,%eax
f0107a0e:	83 f8 06             	cmp    $0x6,%eax
f0107a11:	75 3f                	jne    f0107a52 <OP_E+0x89e>
          {
            print_operand_value (scratchbuf, sizeof(scratchbuf), 0, disp);
f0107a13:	89 14 24             	mov    %edx,(%esp)
f0107a16:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0107a1a:	b9 00 00 00 00       	mov    $0x0,%ecx
f0107a1f:	ba 64 00 00 00       	mov    $0x64,%edx
f0107a24:	b8 00 9f 1b f0       	mov    $0xf01b9f00,%eax
f0107a29:	e8 7e e5 ff ff       	call   f0105fac <print_operand_value>
            oappend (scratchbuf);
f0107a2e:	b8 00 9f 1b f0       	mov    $0xf01b9f00,%eax
f0107a33:	e8 35 e7 ff ff       	call   f010616d <oappend>
          }

      if (mod != 0 || (rm & 7) != 6)
f0107a38:	83 3d 74 9f 1b f0 00 	cmpl   $0x0,0xf01b9f74
f0107a3f:	75 11                	jne    f0107a52 <OP_E+0x89e>
f0107a41:	a1 78 9f 1b f0       	mov    0xf01b9f78,%eax
f0107a46:	83 e0 07             	and    $0x7,%eax
f0107a49:	83 f8 06             	cmp    $0x6,%eax
f0107a4c:	0f 84 8b 00 00 00    	je     f0107add <OP_E+0x929>
	{
	  *obufp++ = open_char;
f0107a52:	8b 15 e4 9e 1b f0    	mov    0xf01b9ee4,%edx
f0107a58:	0f b6 05 51 a1 1b f0 	movzbl 0xf01ba151,%eax
f0107a5f:	88 02                	mov    %al,(%edx)
f0107a61:	8d 42 01             	lea    0x1(%edx),%eax
f0107a64:	a3 e4 9e 1b f0       	mov    %eax,0xf01b9ee4
          *obufp = '\0';
f0107a69:	c6 42 01 00          	movb   $0x0,0x1(%edx)
	  oappend (index16[rm + add]);
f0107a6d:	89 da                	mov    %ebx,%edx
f0107a6f:	03 15 78 9f 1b f0    	add    0xf01b9f78,%edx
f0107a75:	a1 9c 9f 1b f0       	mov    0xf01b9f9c,%eax
f0107a7a:	8b 04 90             	mov    (%eax,%edx,4),%eax
f0107a7d:	e8 eb e6 ff ff       	call   f010616d <oappend>
          *obufp++ = close_char;
f0107a82:	8b 15 e4 9e 1b f0    	mov    0xf01b9ee4,%edx
f0107a88:	0f b6 05 52 a1 1b f0 	movzbl 0xf01ba152,%eax
f0107a8f:	88 02                	mov    %al,(%edx)
f0107a91:	8d 42 01             	lea    0x1(%edx),%eax
f0107a94:	a3 e4 9e 1b f0       	mov    %eax,0xf01b9ee4
          *obufp = '\0';
f0107a99:	c6 42 01 00          	movb   $0x0,0x1(%edx)
f0107a9d:	eb 3e                	jmp    f0107add <OP_E+0x929>
     int sizeflag;
{
  bfd_vma disp;
  int add = 0;
  int riprel = 0;
  USED_REX (REX_EXTZ);
f0107a9f:	a1 6c 9e 1b f0       	mov    0xf01b9e6c,%eax
f0107aa4:	bb 00 00 00 00       	mov    $0x0,%ebx
f0107aa9:	e9 30 f7 ff ff       	jmp    f01071de <OP_E+0x2a>
	    oappend (names64[rm + add]);
	  else
	    oappend (names32[rm + add]);
	  break;
	case v_mode:
	  USED_REX (REX_MODE64);
f0107aae:	a3 6c 9e 1b f0       	mov    %eax,0xf01b9e6c
	  if (rex & REX_MODE64)
	    oappend (names64[rm + add]);
	  else if (sizeflag & DFLAG)
f0107ab3:	f6 45 0c 01          	testb  $0x1,0xc(%ebp)
f0107ab7:	0f 85 70 f8 ff ff    	jne    f010732d <OP_E+0x179>
f0107abd:	e9 83 f8 ff ff       	jmp    f0107345 <OP_E+0x191>
                default:
                  break;
                }
             }
         // cprintf("aaaaaaaaaaaaaaa\n");
	  *obufp++ = open_char;
f0107ac2:	a1 e4 9e 1b f0       	mov    0xf01b9ee4,%eax
f0107ac7:	0f b6 15 51 a1 1b f0 	movzbl 0xf01ba151,%edx
f0107ace:	88 10                	mov    %dl,(%eax)
f0107ad0:	83 c0 01             	add    $0x1,%eax
f0107ad3:	a3 e4 9e 1b f0       	mov    %eax,0xf01b9ee4
f0107ad8:	e9 ce fb ff ff       	jmp    f01076ab <OP_E+0x4f7>
	}

    }
    //cprintf("3269:obufp=%s op1out=%s\n",obufp,op1out);
    //panic("**************");
}
f0107add:	83 c4 2c             	add    $0x2c,%esp
f0107ae0:	5b                   	pop    %ebx
f0107ae1:	5e                   	pop    %esi
f0107ae2:	5f                   	pop    %edi
f0107ae3:	5d                   	pop    %ebp
f0107ae4:	c3                   	ret    

f0107ae5 <OP_EX>:

static void
OP_EX (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f0107ae5:	55                   	push   %ebp
f0107ae6:	89 e5                	mov    %esp,%ebp
f0107ae8:	83 ec 18             	sub    $0x18,%esp
  int add = 0;
  if (mod != 3)
f0107aeb:	83 3d 74 9f 1b f0 03 	cmpl   $0x3,0xf01b9f74
f0107af2:	74 14                	je     f0107b08 <OP_EX+0x23>
    {
      OP_E (bytemode, sizeflag);
f0107af4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107af7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107afb:	8b 45 08             	mov    0x8(%ebp),%eax
f0107afe:	89 04 24             	mov    %eax,(%esp)
f0107b01:	e8 ae f6 ff ff       	call   f01071b4 <OP_E>
f0107b06:	eb 7a                	jmp    f0107b82 <OP_EX+0x9d>
      return;
    }
  USED_REX (REX_EXTZ);
f0107b08:	b8 00 00 00 00       	mov    $0x0,%eax
f0107b0d:	f6 05 68 9e 1b f0 01 	testb  $0x1,0xf01b9e68
f0107b14:	74 09                	je     f0107b1f <OP_EX+0x3a>
f0107b16:	83 0d 6c 9e 1b f0 41 	orl    $0x41,0xf01b9e6c
f0107b1d:	b0 08                	mov    $0x8,%al
  if (rex & REX_EXTZ)
    add = 8;

  /* Skip mod/rm byte.  */
  MODRM_CHECK;
f0107b1f:	80 3d 80 9f 1b f0 00 	cmpb   $0x0,0xf01b9f80
f0107b26:	75 1c                	jne    f0107b44 <OP_EX+0x5f>
f0107b28:	c7 44 24 08 60 b7 10 	movl   $0xf010b760,0x8(%esp)
f0107b2f:	f0 
f0107b30:	c7 44 24 04 90 0f 00 	movl   $0xf90,0x4(%esp)
f0107b37:	00 
f0107b38:	c7 04 24 a3 b6 10 f0 	movl   $0xf010b6a3,(%esp)
f0107b3f:	e8 42 85 ff ff       	call   f0100086 <_panic>
  codep++;
f0107b44:	83 05 6c 9f 1b f0 01 	addl   $0x1,0xf01b9f6c
  snprintf (scratchbuf, sizeof(scratchbuf), "%%xmm%d", rm + add);
f0107b4b:	03 05 78 9f 1b f0    	add    0xf01b9f78,%eax
f0107b51:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107b55:	c7 44 24 08 db b6 10 	movl   $0xf010b6db,0x8(%esp)
f0107b5c:	f0 
f0107b5d:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0107b64:	00 
f0107b65:	c7 04 24 00 9f 1b f0 	movl   $0xf01b9f00,(%esp)
f0107b6c:	e8 89 17 00 00       	call   f01092fa <snprintf>
  oappend (scratchbuf + intel_syntax);
f0107b71:	0f be 05 50 a1 1b f0 	movsbl 0xf01ba150,%eax
f0107b78:	05 00 9f 1b f0       	add    $0xf01b9f00,%eax
f0107b7d:	e8 eb e5 ff ff       	call   f010616d <oappend>
}
f0107b82:	c9                   	leave  
f0107b83:	c3                   	ret    

f0107b84 <OP_XS>:

static void
OP_XS (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f0107b84:	55                   	push   %ebp
f0107b85:	89 e5                	mov    %esp,%ebp
f0107b87:	83 ec 08             	sub    $0x8,%esp
  if (mod == 3)
f0107b8a:	83 3d 74 9f 1b f0 03 	cmpl   $0x3,0xf01b9f74
f0107b91:	75 14                	jne    f0107ba7 <OP_XS+0x23>
    OP_EX (bytemode, sizeflag);
f0107b93:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107b96:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107b9a:	8b 45 08             	mov    0x8(%ebp),%eax
f0107b9d:	89 04 24             	mov    %eax,(%esp)
f0107ba0:	e8 40 ff ff ff       	call   f0107ae5 <OP_EX>
f0107ba5:	eb 05                	jmp    f0107bac <OP_XS+0x28>
  else
    BadOp ();
f0107ba7:	e8 ef e5 ff ff       	call   f010619b <BadOp>
}
f0107bac:	c9                   	leave  
f0107bad:	8d 76 00             	lea    0x0(%esi),%esi
f0107bb0:	c3                   	ret    

f0107bb1 <OP_EM>:

static void
OP_EM (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f0107bb1:	55                   	push   %ebp
f0107bb2:	89 e5                	mov    %esp,%ebp
f0107bb4:	83 ec 18             	sub    $0x18,%esp
  int add = 0;
  if (mod != 3)
f0107bb7:	83 3d 74 9f 1b f0 03 	cmpl   $0x3,0xf01b9f74
f0107bbe:	74 17                	je     f0107bd7 <OP_EM+0x26>
    {
      OP_E (bytemode, sizeflag);
f0107bc0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107bc3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107bc7:	8b 45 08             	mov    0x8(%ebp),%eax
f0107bca:	89 04 24             	mov    %eax,(%esp)
f0107bcd:	e8 e2 f5 ff ff       	call   f01071b4 <OP_E>
f0107bd2:	e9 ba 00 00 00       	jmp    f0107c91 <OP_EM+0xe0>
      return;
    }
  USED_REX (REX_EXTZ);
f0107bd7:	ba 00 00 00 00       	mov    $0x0,%edx
f0107bdc:	f6 05 68 9e 1b f0 01 	testb  $0x1,0xf01b9e68
f0107be3:	74 09                	je     f0107bee <OP_EM+0x3d>
f0107be5:	83 0d 6c 9e 1b f0 41 	orl    $0x41,0xf01b9e6c
f0107bec:	b2 08                	mov    $0x8,%dl
  if (rex & REX_EXTZ)
    add = 8;

  /* Skip mod/rm byte.  */
  MODRM_CHECK;
f0107bee:	80 3d 80 9f 1b f0 00 	cmpb   $0x0,0xf01b9f80
f0107bf5:	75 1c                	jne    f0107c13 <OP_EM+0x62>
f0107bf7:	c7 44 24 08 60 b7 10 	movl   $0xf010b760,0x8(%esp)
f0107bfe:	f0 
f0107bff:	c7 44 24 04 76 0f 00 	movl   $0xf76,0x4(%esp)
f0107c06:	00 
f0107c07:	c7 04 24 a3 b6 10 f0 	movl   $0xf010b6a3,(%esp)
f0107c0e:	e8 73 84 ff ff       	call   f0100086 <_panic>
  codep++;
f0107c13:	83 05 6c 9f 1b f0 01 	addl   $0x1,0xf01b9f6c
  used_prefixes |= (prefixes & PREFIX_DATA);
f0107c1a:	a1 64 9e 1b f0       	mov    0xf01b9e64,%eax
f0107c1f:	25 00 02 00 00       	and    $0x200,%eax
f0107c24:	09 05 70 9e 1b f0    	or     %eax,0xf01b9e70
  if (prefixes & PREFIX_DATA)
f0107c2a:	85 c0                	test   %eax,%eax
f0107c2c:	74 2a                	je     f0107c58 <OP_EM+0xa7>
    snprintf (scratchbuf, sizeof(scratchbuf), "%%xmm%d", rm + add);
f0107c2e:	89 d0                	mov    %edx,%eax
f0107c30:	03 05 78 9f 1b f0    	add    0xf01b9f78,%eax
f0107c36:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107c3a:	c7 44 24 08 db b6 10 	movl   $0xf010b6db,0x8(%esp)
f0107c41:	f0 
f0107c42:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0107c49:	00 
f0107c4a:	c7 04 24 00 9f 1b f0 	movl   $0xf01b9f00,(%esp)
f0107c51:	e8 a4 16 00 00       	call   f01092fa <snprintf>
f0107c56:	eb 28                	jmp    f0107c80 <OP_EM+0xcf>
  else
    snprintf (scratchbuf, sizeof(scratchbuf), "%%mm%d", rm + add);
f0107c58:	89 d0                	mov    %edx,%eax
f0107c5a:	03 05 78 9f 1b f0    	add    0xf01b9f78,%eax
f0107c60:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107c64:	c7 44 24 08 e3 b6 10 	movl   $0xf010b6e3,0x8(%esp)
f0107c6b:	f0 
f0107c6c:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0107c73:	00 
f0107c74:	c7 04 24 00 9f 1b f0 	movl   $0xf01b9f00,(%esp)
f0107c7b:	e8 7a 16 00 00       	call   f01092fa <snprintf>
  oappend (scratchbuf + intel_syntax);
f0107c80:	0f be 05 50 a1 1b f0 	movsbl 0xf01ba150,%eax
f0107c87:	05 00 9f 1b f0       	add    $0xf01b9f00,%eax
f0107c8c:	e8 dc e4 ff ff       	call   f010616d <oappend>
}
f0107c91:	c9                   	leave  
f0107c92:	c3                   	ret    

f0107c93 <OP_MS>:

static void
OP_MS (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f0107c93:	55                   	push   %ebp
f0107c94:	89 e5                	mov    %esp,%ebp
f0107c96:	83 ec 08             	sub    $0x8,%esp
  if (mod == 3)
f0107c99:	83 3d 74 9f 1b f0 03 	cmpl   $0x3,0xf01b9f74
f0107ca0:	75 14                	jne    f0107cb6 <OP_MS+0x23>
    OP_EM (bytemode, sizeflag);
f0107ca2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107ca5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107ca9:	8b 45 08             	mov    0x8(%ebp),%eax
f0107cac:	89 04 24             	mov    %eax,(%esp)
f0107caf:	e8 fd fe ff ff       	call   f0107bb1 <OP_EM>
f0107cb4:	eb 05                	jmp    f0107cbb <OP_MS+0x28>
  else
    BadOp ();
f0107cb6:	e8 e0 e4 ff ff       	call   f010619b <BadOp>
}
f0107cbb:	c9                   	leave  
f0107cbc:	8d 74 26 00          	lea    0x0(%esi),%esi
f0107cc0:	c3                   	ret    

f0107cc1 <OP_Rd>:

static void
OP_Rd (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f0107cc1:	55                   	push   %ebp
f0107cc2:	89 e5                	mov    %esp,%ebp
f0107cc4:	83 ec 08             	sub    $0x8,%esp
  if (mod == 3)
f0107cc7:	83 3d 74 9f 1b f0 03 	cmpl   $0x3,0xf01b9f74
f0107cce:	75 14                	jne    f0107ce4 <OP_Rd+0x23>
    OP_E (bytemode, sizeflag);
f0107cd0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107cd3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107cd7:	8b 45 08             	mov    0x8(%ebp),%eax
f0107cda:	89 04 24             	mov    %eax,(%esp)
f0107cdd:	e8 d2 f4 ff ff       	call   f01071b4 <OP_E>
f0107ce2:	eb 05                	jmp    f0107ce9 <OP_Rd+0x28>
  else
    BadOp ();
f0107ce4:	e8 b2 e4 ff ff       	call   f010619b <BadOp>
}
f0107ce9:	c9                   	leave  
f0107cea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0107cf0:	c3                   	ret    

f0107cf1 <OP_indirE>:

static void
OP_indirE (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f0107cf1:	55                   	push   %ebp
f0107cf2:	89 e5                	mov    %esp,%ebp
f0107cf4:	83 ec 08             	sub    $0x8,%esp
  if (!intel_syntax)
f0107cf7:	80 3d 50 a1 1b f0 00 	cmpb   $0x0,0xf01ba150
f0107cfe:	75 0a                	jne    f0107d0a <OP_indirE+0x19>
    oappend ("*");
f0107d00:	b8 a9 b7 10 f0       	mov    $0xf010b7a9,%eax
f0107d05:	e8 63 e4 ff ff       	call   f010616d <oappend>
  OP_E (bytemode, sizeflag);
f0107d0a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107d0d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107d11:	8b 45 08             	mov    0x8(%ebp),%eax
f0107d14:	89 04 24             	mov    %eax,(%esp)
f0107d17:	e8 98 f4 ff ff       	call   f01071b4 <OP_E>
}
f0107d1c:	c9                   	leave  
f0107d1d:	c3                   	ret    

f0107d1e <OP_STi>:

static void
OP_STi (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f0107d1e:	55                   	push   %ebp
f0107d1f:	89 e5                	mov    %esp,%ebp
f0107d21:	83 ec 18             	sub    $0x18,%esp
  snprintf (scratchbuf, sizeof(scratchbuf), "%%st(%d)", rm);
f0107d24:	a1 78 9f 1b f0       	mov    0xf01b9f78,%eax
f0107d29:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107d2d:	c7 44 24 08 ab b7 10 	movl   $0xf010b7ab,0x8(%esp)
f0107d34:	f0 
f0107d35:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0107d3c:	00 
f0107d3d:	c7 04 24 00 9f 1b f0 	movl   $0xf01b9f00,(%esp)
f0107d44:	e8 b1 15 00 00       	call   f01092fa <snprintf>
  oappend (scratchbuf + intel_syntax);
f0107d49:	0f be 05 50 a1 1b f0 	movsbl 0xf01ba150,%eax
f0107d50:	05 00 9f 1b f0       	add    $0xf01b9f00,%eax
f0107d55:	e8 13 e4 ff ff       	call   f010616d <oappend>
}
f0107d5a:	c9                   	leave  
f0107d5b:	c3                   	ret    

f0107d5c <OP_ST>:

static void
OP_ST (bytemode, sizeflag)
     int bytemode;
     int sizeflag;
{
f0107d5c:	55                   	push   %ebp
f0107d5d:	89 e5                	mov    %esp,%ebp
f0107d5f:	83 ec 08             	sub    $0x8,%esp
  oappend ("%st");
f0107d62:	b8 b4 b7 10 f0       	mov    $0xf010b7b4,%eax
f0107d67:	e8 01 e4 ff ff       	call   f010616d <oappend>
}
f0107d6c:	c9                   	leave  
f0107d6d:	c3                   	ret    

f0107d6e <print_insn_i386>:

int
print_insn_i386 (pc, info)
     bfd_vma pc;
     disassemble_info *info;
{
f0107d6e:	55                   	push   %ebp
f0107d6f:	89 e5                	mov    %esp,%ebp
f0107d71:	57                   	push   %edi
f0107d72:	56                   	push   %esi
f0107d73:	53                   	push   %ebx
f0107d74:	83 ec 4c             	sub    $0x4c,%esp
f0107d77:	8b 75 08             	mov    0x8(%ebp),%esi
f0107d7a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  unsigned char uses_SSE_prefix;
  int sizeflag;
  const char *p;
  struct dis_private priv;

  mode_64bit = (info->mach == bfd_mach_x86_64_intel_syntax
f0107d7d:	8b 45 10             	mov    0x10(%ebp),%eax
f0107d80:	8b 48 0c             	mov    0xc(%eax),%ecx
f0107d83:	8d 41 fd             	lea    -0x3(%ecx),%eax
f0107d86:	83 f8 01             	cmp    $0x1,%eax
f0107d89:	0f 96 c0             	setbe  %al
f0107d8c:	0f b6 c0             	movzbl %al,%eax
f0107d8f:	a3 60 9e 1b f0       	mov    %eax,0xf01b9e60
		|| info->mach == bfd_mach_x86_64);

  if (intel_syntax == -1)
    intel_syntax = (info->mach == bfd_mach_i386_i386_intel_syntax
f0107d94:	83 f9 02             	cmp    $0x2,%ecx
f0107d97:	0f 94 c2             	sete   %dl
f0107d9a:	83 f9 04             	cmp    $0x4,%ecx
f0107d9d:	0f 94 c0             	sete   %al
f0107da0:	09 d0                	or     %edx,%eax
f0107da2:	a2 50 a1 1b f0       	mov    %al,0xf01ba150
		    || info->mach == bfd_mach_x86_64_intel_syntax);

  if (info->mach == bfd_mach_i386_i386
f0107da7:	85 c9                	test   %ecx,%ecx
f0107da9:	74 0f                	je     f0107dba <print_insn_i386+0x4c>
f0107dab:	83 f9 03             	cmp    $0x3,%ecx
f0107dae:	74 0a                	je     f0107dba <print_insn_i386+0x4c>
f0107db0:	83 f9 02             	cmp    $0x2,%ecx
f0107db3:	74 05                	je     f0107dba <print_insn_i386+0x4c>
f0107db5:	83 f9 04             	cmp    $0x4,%ecx
f0107db8:	75 09                	jne    f0107dc3 <print_insn_i386+0x55>
      || info->mach == bfd_mach_x86_64
      || info->mach == bfd_mach_i386_i386_intel_syntax
      || info->mach == bfd_mach_x86_64_intel_syntax)
    priv.orig_sizeflag = AFLAG | DFLAG;
f0107dba:	c7 45 f0 03 00 00 00 	movl   $0x3,-0x10(%ebp)
f0107dc1:	eb 2b                	jmp    f0107dee <print_insn_i386+0x80>
  else if (info->mach == bfd_mach_i386_i8086)
f0107dc3:	83 f9 01             	cmp    $0x1,%ecx
f0107dc6:	75 0a                	jne    f0107dd2 <print_insn_i386+0x64>
    priv.orig_sizeflag = 0;
f0107dc8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0107dcf:	90                   	nop    
f0107dd0:	eb 1c                	jmp    f0107dee <print_insn_i386+0x80>
  else
    panic("print_insn:error occured");
f0107dd2:	c7 44 24 08 b8 b7 10 	movl   $0xf010b7b8,0x8(%esp)
f0107dd9:	f0 
f0107dda:	c7 44 24 04 52 07 00 	movl   $0x752,0x4(%esp)
f0107de1:	00 
f0107de2:	c7 04 24 a3 b6 10 f0 	movl   $0xf010b6a3,(%esp)
f0107de9:	e8 98 82 ff ff       	call   f0100086 <_panic>

  for (p = info->disassembler_options; p != NULL; )
f0107dee:	8b 55 10             	mov    0x10(%ebp),%edx
f0107df1:	8b 5a 68             	mov    0x68(%edx),%ebx
f0107df4:	85 db                	test   %ebx,%ebx
f0107df6:	0f 84 a5 01 00 00    	je     f0107fa1 <print_insn_i386+0x233>
    {
      if (strncmp (p, "x86-64", 6) == 0)
f0107dfc:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
f0107e03:	00 
f0107e04:	c7 44 24 04 d1 b7 10 	movl   $0xf010b7d1,0x4(%esp)
f0107e0b:	f0 
f0107e0c:	89 1c 24             	mov    %ebx,(%esp)
f0107e0f:	e8 7d 17 00 00       	call   f0109591 <strncmp>
f0107e14:	85 c0                	test   %eax,%eax
f0107e16:	75 16                	jne    f0107e2e <print_insn_i386+0xc0>
	{
	  mode_64bit = 1;
f0107e18:	c7 05 60 9e 1b f0 01 	movl   $0x1,0xf01b9e60
f0107e1f:	00 00 00 
	  priv.orig_sizeflag = AFLAG | DFLAG;
f0107e22:	c7 45 f0 03 00 00 00 	movl   $0x3,-0x10(%ebp)
f0107e29:	e9 54 01 00 00       	jmp    f0107f82 <print_insn_i386+0x214>
	}
      else if (strncmp (p, "i386", 4) == 0)
f0107e2e:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0107e35:	00 
f0107e36:	c7 44 24 04 d8 b7 10 	movl   $0xf010b7d8,0x4(%esp)
f0107e3d:	f0 
f0107e3e:	89 1c 24             	mov    %ebx,(%esp)
f0107e41:	e8 4b 17 00 00       	call   f0109591 <strncmp>
f0107e46:	85 c0                	test   %eax,%eax
f0107e48:	75 16                	jne    f0107e60 <print_insn_i386+0xf2>
	{
	  mode_64bit = 0;
f0107e4a:	c7 05 60 9e 1b f0 00 	movl   $0x0,0xf01b9e60
f0107e51:	00 00 00 
	  priv.orig_sizeflag = AFLAG | DFLAG;
f0107e54:	c7 45 f0 03 00 00 00 	movl   $0x3,-0x10(%ebp)
f0107e5b:	e9 22 01 00 00       	jmp    f0107f82 <print_insn_i386+0x214>
	}
      else if (strncmp (p, "i8086", 5) == 0)
f0107e60:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
f0107e67:	00 
f0107e68:	c7 44 24 04 dd b7 10 	movl   $0xf010b7dd,0x4(%esp)
f0107e6f:	f0 
f0107e70:	89 1c 24             	mov    %ebx,(%esp)
f0107e73:	e8 19 17 00 00       	call   f0109591 <strncmp>
f0107e78:	85 c0                	test   %eax,%eax
f0107e7a:	75 16                	jne    f0107e92 <print_insn_i386+0x124>
	{
	  mode_64bit = 0;
f0107e7c:	c7 05 60 9e 1b f0 00 	movl   $0x0,0xf01b9e60
f0107e83:	00 00 00 
	  priv.orig_sizeflag = 0;
f0107e86:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0107e8d:	e9 f0 00 00 00       	jmp    f0107f82 <print_insn_i386+0x214>
	}
      else if (strncmp (p, "intel", 5) == 0)
f0107e92:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
f0107e99:	00 
f0107e9a:	c7 44 24 04 e3 b7 10 	movl   $0xf010b7e3,0x4(%esp)
f0107ea1:	f0 
f0107ea2:	89 1c 24             	mov    %ebx,(%esp)
f0107ea5:	e8 e7 16 00 00       	call   f0109591 <strncmp>
f0107eaa:	85 c0                	test   %eax,%eax
f0107eac:	75 0c                	jne    f0107eba <print_insn_i386+0x14c>
	{
	  intel_syntax = 1;
f0107eae:	c6 05 50 a1 1b f0 01 	movb   $0x1,0xf01ba150
f0107eb5:	e9 c8 00 00 00       	jmp    f0107f82 <print_insn_i386+0x214>
	}
      else if (strncmp (p, "att", 3) == 0)
f0107eba:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
f0107ec1:	00 
f0107ec2:	c7 44 24 04 e9 b7 10 	movl   $0xf010b7e9,0x4(%esp)
f0107ec9:	f0 
f0107eca:	89 1c 24             	mov    %ebx,(%esp)
f0107ecd:	e8 bf 16 00 00       	call   f0109591 <strncmp>
f0107ed2:	85 c0                	test   %eax,%eax
f0107ed4:	75 0c                	jne    f0107ee2 <print_insn_i386+0x174>
	{
	  intel_syntax = 0;
f0107ed6:	c6 05 50 a1 1b f0 00 	movb   $0x0,0xf01ba150
f0107edd:	e9 a0 00 00 00       	jmp    f0107f82 <print_insn_i386+0x214>
	}
      else if (strncmp (p, "addr", 4) == 0)
f0107ee2:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0107ee9:	00 
f0107eea:	c7 44 24 04 ed b7 10 	movl   $0xf010b7ed,0x4(%esp)
f0107ef1:	f0 
f0107ef2:	89 1c 24             	mov    %ebx,(%esp)
f0107ef5:	e8 97 16 00 00       	call   f0109591 <strncmp>
f0107efa:	85 c0                	test   %eax,%eax
f0107efc:	75 24                	jne    f0107f22 <print_insn_i386+0x1b4>
	{
	  if (p[4] == '1' && p[5] == '6')
f0107efe:	0f b6 43 04          	movzbl 0x4(%ebx),%eax
f0107f02:	3c 31                	cmp    $0x31,%al
f0107f04:	75 0c                	jne    f0107f12 <print_insn_i386+0x1a4>
f0107f06:	80 7b 05 36          	cmpb   $0x36,0x5(%ebx)
f0107f0a:	75 06                	jne    f0107f12 <print_insn_i386+0x1a4>
	    priv.orig_sizeflag &= ~AFLAG;
f0107f0c:	83 65 f0 fd          	andl   $0xfffffffd,-0x10(%ebp)
f0107f10:	eb 70                	jmp    f0107f82 <print_insn_i386+0x214>
	  else if (p[4] == '3' && p[5] == '2')
f0107f12:	3c 33                	cmp    $0x33,%al
f0107f14:	75 6c                	jne    f0107f82 <print_insn_i386+0x214>
f0107f16:	80 7b 05 32          	cmpb   $0x32,0x5(%ebx)
f0107f1a:	75 66                	jne    f0107f82 <print_insn_i386+0x214>
	    priv.orig_sizeflag |= AFLAG;
f0107f1c:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
f0107f20:	eb 60                	jmp    f0107f82 <print_insn_i386+0x214>
	}
      else if (strncmp (p, "data", 4) == 0)
f0107f22:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0107f29:	00 
f0107f2a:	c7 44 24 04 f2 b7 10 	movl   $0xf010b7f2,0x4(%esp)
f0107f31:	f0 
f0107f32:	89 1c 24             	mov    %ebx,(%esp)
f0107f35:	e8 57 16 00 00       	call   f0109591 <strncmp>
f0107f3a:	85 c0                	test   %eax,%eax
f0107f3c:	75 24                	jne    f0107f62 <print_insn_i386+0x1f4>
	{
	  if (p[4] == '1' && p[5] == '6')
f0107f3e:	0f b6 43 04          	movzbl 0x4(%ebx),%eax
f0107f42:	3c 31                	cmp    $0x31,%al
f0107f44:	75 0c                	jne    f0107f52 <print_insn_i386+0x1e4>
f0107f46:	80 7b 05 36          	cmpb   $0x36,0x5(%ebx)
f0107f4a:	75 06                	jne    f0107f52 <print_insn_i386+0x1e4>
	    priv.orig_sizeflag &= ~DFLAG;
f0107f4c:	83 65 f0 fe          	andl   $0xfffffffe,-0x10(%ebp)
f0107f50:	eb 30                	jmp    f0107f82 <print_insn_i386+0x214>
	  else if (p[4] == '3' && p[5] == '2')
f0107f52:	3c 33                	cmp    $0x33,%al
f0107f54:	75 2c                	jne    f0107f82 <print_insn_i386+0x214>
f0107f56:	80 7b 05 32          	cmpb   $0x32,0x5(%ebx)
f0107f5a:	75 26                	jne    f0107f82 <print_insn_i386+0x214>
	    priv.orig_sizeflag |= DFLAG;
f0107f5c:	83 4d f0 01          	orl    $0x1,-0x10(%ebp)
f0107f60:	eb 20                	jmp    f0107f82 <print_insn_i386+0x214>
	}
      else if (strncmp (p, "suffix", 6) == 0)
f0107f62:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
f0107f69:	00 
f0107f6a:	c7 44 24 04 f7 b7 10 	movl   $0xf010b7f7,0x4(%esp)
f0107f71:	f0 
f0107f72:	89 1c 24             	mov    %ebx,(%esp)
f0107f75:	e8 17 16 00 00       	call   f0109591 <strncmp>
f0107f7a:	85 c0                	test   %eax,%eax
f0107f7c:	75 04                	jne    f0107f82 <print_insn_i386+0x214>
	priv.orig_sizeflag |= SUFFIX_ALWAYS;
f0107f7e:	83 4d f0 04          	orl    $0x4,-0x10(%ebp)

      p = strchr (p, ',');
f0107f82:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
f0107f89:	00 
f0107f8a:	89 1c 24             	mov    %ebx,(%esp)
f0107f8d:	e8 45 16 00 00       	call   f01095d7 <strchr>
      if (p != NULL)
f0107f92:	85 c0                	test   %eax,%eax
f0107f94:	74 0b                	je     f0107fa1 <print_insn_i386+0x233>
  else if (info->mach == bfd_mach_i386_i8086)
    priv.orig_sizeflag = 0;
  else
    panic("print_insn:error occured");

  for (p = info->disassembler_options; p != NULL; )
f0107f96:	89 c3                	mov    %eax,%ebx
f0107f98:	83 c3 01             	add    $0x1,%ebx
f0107f9b:	0f 85 5b fe ff ff    	jne    f0107dfc <print_insn_i386+0x8e>
      p = strchr (p, ',');
      if (p != NULL)
	p++;
    }

  if (intel_syntax)
f0107fa1:	80 3d 50 a1 1b f0 00 	cmpb   $0x0,0xf01ba150
f0107fa8:	74 64                	je     f010800e <print_insn_i386+0x2a0>
    {
      names64 = intel_names64;
f0107faa:	c7 05 84 9f 1b f0 20 	movl   $0xf010cf20,0xf01b9f84
f0107fb1:	cf 10 f0 
      names32 = intel_names32;
f0107fb4:	c7 05 88 9f 1b f0 60 	movl   $0xf010cf60,0xf01b9f88
f0107fbb:	cf 10 f0 
      names16 = intel_names16;
f0107fbe:	c7 05 8c 9f 1b f0 a0 	movl   $0xf010cfa0,0xf01b9f8c
f0107fc5:	cf 10 f0 
      names8 = intel_names8;
f0107fc8:	c7 05 90 9f 1b f0 e0 	movl   $0xf010cfe0,0xf01b9f90
f0107fcf:	cf 10 f0 
      names8rex = intel_names8rex;
f0107fd2:	c7 05 94 9f 1b f0 00 	movl   $0xf010d000,0xf01b9f94
f0107fd9:	d0 10 f0 
      names_seg = intel_names_seg;
f0107fdc:	c7 05 98 9f 1b f0 40 	movl   $0xf010d040,0xf01b9f98
f0107fe3:	d0 10 f0 
      index16 = intel_index16;
f0107fe6:	c7 05 9c 9f 1b f0 60 	movl   $0xf010d060,0xf01b9f9c
f0107fed:	d0 10 f0 
      open_char = '[';
f0107ff0:	c6 05 51 a1 1b f0 5b 	movb   $0x5b,0xf01ba151
      close_char = ']';
f0107ff7:	c6 05 52 a1 1b f0 5d 	movb   $0x5d,0xf01ba152
      separator_char = '+';
f0107ffe:	c6 05 53 a1 1b f0 2b 	movb   $0x2b,0xf01ba153
      scale_char = '*';
f0108005:	c6 05 54 a1 1b f0 2a 	movb   $0x2a,0xf01ba154
f010800c:	eb 62                	jmp    f0108070 <print_insn_i386+0x302>
    }
  else
    {
      names64 = att_names64;
f010800e:	c7 05 84 9f 1b f0 80 	movl   $0xf010d080,0xf01b9f84
f0108015:	d0 10 f0 
      names32 = att_names32;
f0108018:	c7 05 88 9f 1b f0 c0 	movl   $0xf010d0c0,0xf01b9f88
f010801f:	d0 10 f0 
      names16 = att_names16;
f0108022:	c7 05 8c 9f 1b f0 00 	movl   $0xf010d100,0xf01b9f8c
f0108029:	d1 10 f0 
      names8 = att_names8;
f010802c:	c7 05 90 9f 1b f0 40 	movl   $0xf010d140,0xf01b9f90
f0108033:	d1 10 f0 
      names8rex = att_names8rex;
f0108036:	c7 05 94 9f 1b f0 60 	movl   $0xf010d160,0xf01b9f94
f010803d:	d1 10 f0 
      names_seg = att_names_seg;
f0108040:	c7 05 98 9f 1b f0 a0 	movl   $0xf010d1a0,0xf01b9f98
f0108047:	d1 10 f0 
      index16 = att_index16;
f010804a:	c7 05 9c 9f 1b f0 c0 	movl   $0xf010d1c0,0xf01b9f9c
f0108051:	d1 10 f0 
      open_char = '(';
f0108054:	c6 05 51 a1 1b f0 28 	movb   $0x28,0xf01ba151
      close_char =  ')';
f010805b:	c6 05 52 a1 1b f0 29 	movb   $0x29,0xf01ba152
      separator_char = ',';
f0108062:	c6 05 53 a1 1b f0 2c 	movb   $0x2c,0xf01ba153
      scale_char = ',';
f0108069:	c6 05 54 a1 1b f0 2c 	movb   $0x2c,0xf01ba154
    }
   //cprintf("intel_syntax2=%d\n",intel_syntax);
  /* The output looks better if we put 7 bytes on a line, since that
     puts most long word instructions on a single line.  */
  info->bytes_per_line = 7;
f0108070:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0108073:	c7 41 44 07 00 00 00 	movl   $0x7,0x44(%ecx)
  
  info->private_data = (PTR) &priv;
f010807a:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010807d:	89 41 20             	mov    %eax,0x20(%ecx)
  priv.max_fetched = priv.the_buffer;
f0108080:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f0108083:	89 45 d0             	mov    %eax,-0x30(%ebp)
  priv.insn_start = pc;
f0108086:	89 75 e8             	mov    %esi,-0x18(%ebp)
f0108089:	89 7d ec             	mov    %edi,-0x14(%ebp)

  obuf[0] = 0;
f010808c:	c6 05 80 9e 1b f0 00 	movb   $0x0,0xf01b9e80
  op1out[0] = 0;
f0108093:	c6 05 a0 9f 1b f0 00 	movb   $0x0,0xf01b9fa0
  op2out[0] = 0;
f010809a:	c6 05 20 a0 1b f0 00 	movb   $0x0,0xf01ba020
  op3out[0] = 0;
f01080a1:	c6 05 a0 a0 1b f0 00 	movb   $0x0,0xf01ba0a0

  op_index[0] = op_index[1] = op_index[2] = -1;
f01080a8:	c7 05 10 a1 1b f0 ff 	movl   $0xffffffff,0xf01ba110
f01080af:	ff ff ff 
f01080b2:	c7 05 0c a1 1b f0 ff 	movl   $0xffffffff,0xf01ba10c
f01080b9:	ff ff ff 
f01080bc:	c7 05 08 a1 1b f0 ff 	movl   $0xffffffff,0xf01ba108
f01080c3:	ff ff ff 

  the_info = info;
f01080c6:	89 0d 70 9f 1b f0    	mov    %ecx,0xf01b9f70
 // cprintf("the_info:buffer_length=%d\n",the_info->buffer_length);
  start_pc = pc;
f01080cc:	89 35 48 a1 1b f0    	mov    %esi,0xf01ba148
f01080d2:	89 3d 4c a1 1b f0    	mov    %edi,0xf01ba14c
  start_codep = priv.the_buffer;
f01080d8:	a3 64 9f 1b f0       	mov    %eax,0xf01b9f64
  codep = priv.the_buffer;
f01080dd:	a3 6c 9f 1b f0       	mov    %eax,0xf01b9f6c
	}

      return -1;
    }

  obufp = obuf;
f01080e2:	c7 05 e4 9e 1b f0 80 	movl   $0xf01b9e80,0xf01b9ee4
f01080e9:	9e 1b f0 

static void
ckprefix ()
{
  int newrex;
  rex = 0;
f01080ec:	c7 05 68 9e 1b f0 00 	movl   $0x0,0xf01b9e68
f01080f3:	00 00 00 
  prefixes = 0;
f01080f6:	c7 05 64 9e 1b f0 00 	movl   $0x0,0xf01b9e64
f01080fd:	00 00 00 
  used_prefixes = 0;
f0108100:	c7 05 70 9e 1b f0 00 	movl   $0x0,0xf01b9e70
f0108107:	00 00 00 
  rex_used = 0;
f010810a:	c7 05 6c 9e 1b f0 00 	movl   $0x0,0xf01b9e6c
f0108111:	00 00 00 
  while (1)
    {
      FETCH_DATA (the_info, codep + 1);
f0108114:	8b 15 6c 9f 1b f0    	mov    0xf01b9f6c,%edx
f010811a:	83 c2 01             	add    $0x1,%edx
f010811d:	8b 0d 70 9f 1b f0    	mov    0xf01b9f70,%ecx
f0108123:	8b 41 20             	mov    0x20(%ecx),%eax
f0108126:	3b 10                	cmp    (%eax),%edx
f0108128:	76 07                	jbe    f0108131 <print_insn_i386+0x3c3>
f010812a:	89 c8                	mov    %ecx,%eax
f010812c:	e8 bf d4 ff ff       	call   f01055f0 <fetch_data>
      newrex = 0;
      switch (*codep)
f0108131:	8b 0d 6c 9f 1b f0    	mov    0xf01b9f6c,%ecx
f0108137:	0f b6 11             	movzbl (%ecx),%edx
f010813a:	80 fa 64             	cmp    $0x64,%dl
f010813d:	0f 84 25 01 00 00    	je     f0108268 <print_insn_i386+0x4fa>
f0108143:	80 fa 64             	cmp    $0x64,%dl
f0108146:	77 4b                	ja     f0108193 <print_insn_i386+0x425>
f0108148:	80 fa 36             	cmp    $0x36,%dl
f010814b:	0f 84 ea 00 00 00    	je     f010823b <print_insn_i386+0x4cd>
f0108151:	80 fa 36             	cmp    $0x36,%dl
f0108154:	77 17                	ja     f010816d <print_insn_i386+0x3ff>
f0108156:	80 fa 26             	cmp    $0x26,%dl
f0108159:	0f 84 fb 00 00 00    	je     f010825a <print_insn_i386+0x4ec>
f010815f:	80 fa 2e             	cmp    $0x2e,%dl
f0108162:	0f 85 a2 01 00 00    	jne    f010830a <print_insn_i386+0x59c>
f0108168:	e9 bd 00 00 00       	jmp    f010822a <print_insn_i386+0x4bc>
f010816d:	80 fa 3e             	cmp    $0x3e,%dl
f0108170:	0f 84 d6 00 00 00    	je     f010824c <print_insn_i386+0x4de>
f0108176:	80 fa 3e             	cmp    $0x3e,%dl
f0108179:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
f0108180:	0f 82 84 01 00 00    	jb     f010830a <print_insn_i386+0x59c>
f0108186:	8d 42 c0             	lea    -0x40(%edx),%eax
f0108189:	3c 0f                	cmp    $0xf,%al
f010818b:	0f 87 79 01 00 00    	ja     f010830a <print_insn_i386+0x59c>
f0108191:	eb 4f                	jmp    f01081e2 <print_insn_i386+0x474>
f0108193:	80 fa 9b             	cmp    $0x9b,%dl
f0108196:	0f 84 10 01 00 00    	je     f01082ac <print_insn_i386+0x53e>
f010819c:	80 fa 9b             	cmp    $0x9b,%dl
f010819f:	90                   	nop    
f01081a0:	77 23                	ja     f01081c5 <print_insn_i386+0x457>
f01081a2:	80 fa 66             	cmp    $0x66,%dl
f01081a5:	0f 84 df 00 00 00    	je     f010828a <print_insn_i386+0x51c>
f01081ab:	80 fa 66             	cmp    $0x66,%dl
f01081ae:	66 90                	xchg   %ax,%ax
f01081b0:	0f 82 c3 00 00 00    	jb     f0108279 <print_insn_i386+0x50b>
f01081b6:	80 fa 67             	cmp    $0x67,%dl
f01081b9:	0f 85 4b 01 00 00    	jne    f010830a <print_insn_i386+0x59c>
f01081bf:	90                   	nop    
f01081c0:	e9 d6 00 00 00       	jmp    f010829b <print_insn_i386+0x52d>
f01081c5:	80 fa f2             	cmp    $0xf2,%dl
f01081c8:	74 3e                	je     f0108208 <print_insn_i386+0x49a>
f01081ca:	80 fa f3             	cmp    $0xf3,%dl
f01081cd:	8d 76 00             	lea    0x0(%esi),%esi
f01081d0:	74 25                	je     f01081f7 <print_insn_i386+0x489>
f01081d2:	80 fa f0             	cmp    $0xf0,%dl
f01081d5:	0f 85 2f 01 00 00    	jne    f010830a <print_insn_i386+0x59c>
f01081db:	90                   	nop    
f01081dc:	8d 74 26 00          	lea    0x0(%esi),%esi
f01081e0:	eb 37                	jmp    f0108219 <print_insn_i386+0x4ab>
	case 0x4b:
	case 0x4c:
	case 0x4d:
	case 0x4e:
	case 0x4f:
	    if (mode_64bit)
f01081e2:	83 3d 60 9e 1b f0 00 	cmpl   $0x0,0xf01b9e60
f01081e9:	0f 84 1b 01 00 00    	je     f010830a <print_insn_i386+0x59c>
  rex_used = 0;
  while (1)
    {
      FETCH_DATA (the_info, codep + 1);
      newrex = 0;
      switch (*codep)
f01081ef:	0f b6 da             	movzbl %dl,%ebx
f01081f2:	e9 df 00 00 00       	jmp    f01082d6 <print_insn_i386+0x568>
	      newrex = *codep;
	    else
	      return;
	  break;
	case 0xf3:
	  prefixes |= PREFIX_REPZ;
f01081f7:	83 0d 64 9e 1b f0 01 	orl    $0x1,0xf01b9e64
f01081fe:	bb 00 00 00 00       	mov    $0x0,%ebx
f0108203:	e9 ce 00 00 00       	jmp    f01082d6 <print_insn_i386+0x568>
	  break;
	case 0xf2:
	  prefixes |= PREFIX_REPNZ;
f0108208:	83 0d 64 9e 1b f0 02 	orl    $0x2,0xf01b9e64
f010820f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0108214:	e9 bd 00 00 00       	jmp    f01082d6 <print_insn_i386+0x568>
	  break;
	case 0xf0:
	  prefixes |= PREFIX_LOCK;
f0108219:	83 0d 64 9e 1b f0 04 	orl    $0x4,0xf01b9e64
f0108220:	bb 00 00 00 00       	mov    $0x0,%ebx
f0108225:	e9 ac 00 00 00       	jmp    f01082d6 <print_insn_i386+0x568>
	  break;
	case 0x2e:
	  prefixes |= PREFIX_CS;
f010822a:	83 0d 64 9e 1b f0 08 	orl    $0x8,0xf01b9e64
f0108231:	bb 00 00 00 00       	mov    $0x0,%ebx
f0108236:	e9 9b 00 00 00       	jmp    f01082d6 <print_insn_i386+0x568>
	  break;
	case 0x36:
	  prefixes |= PREFIX_SS;
f010823b:	83 0d 64 9e 1b f0 10 	orl    $0x10,0xf01b9e64
f0108242:	bb 00 00 00 00       	mov    $0x0,%ebx
f0108247:	e9 8a 00 00 00       	jmp    f01082d6 <print_insn_i386+0x568>
	  break;
	case 0x3e:
	  prefixes |= PREFIX_DS;
f010824c:	83 0d 64 9e 1b f0 20 	orl    $0x20,0xf01b9e64
f0108253:	bb 00 00 00 00       	mov    $0x0,%ebx
f0108258:	eb 7c                	jmp    f01082d6 <print_insn_i386+0x568>
	  break;
	case 0x26:
	  prefixes |= PREFIX_ES;
f010825a:	83 0d 64 9e 1b f0 40 	orl    $0x40,0xf01b9e64
f0108261:	bb 00 00 00 00       	mov    $0x0,%ebx
f0108266:	eb 6e                	jmp    f01082d6 <print_insn_i386+0x568>
	  break;
	case 0x64:
	  prefixes |= PREFIX_FS;
f0108268:	81 0d 64 9e 1b f0 80 	orl    $0x80,0xf01b9e64
f010826f:	00 00 00 
f0108272:	bb 00 00 00 00       	mov    $0x0,%ebx
f0108277:	eb 5d                	jmp    f01082d6 <print_insn_i386+0x568>
	  break;
	case 0x65:
	  prefixes |= PREFIX_GS;
f0108279:	81 0d 64 9e 1b f0 00 	orl    $0x100,0xf01b9e64
f0108280:	01 00 00 
f0108283:	bb 00 00 00 00       	mov    $0x0,%ebx
f0108288:	eb 4c                	jmp    f01082d6 <print_insn_i386+0x568>
	  break;
	case 0x66:
	  prefixes |= PREFIX_DATA;
f010828a:	81 0d 64 9e 1b f0 00 	orl    $0x200,0xf01b9e64
f0108291:	02 00 00 
f0108294:	bb 00 00 00 00       	mov    $0x0,%ebx
f0108299:	eb 3b                	jmp    f01082d6 <print_insn_i386+0x568>
	  break;
	case 0x67:
	  prefixes |= PREFIX_ADDR;
f010829b:	81 0d 64 9e 1b f0 00 	orl    $0x400,0xf01b9e64
f01082a2:	04 00 00 
f01082a5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01082aa:	eb 2a                	jmp    f01082d6 <print_insn_i386+0x568>
	  break;
	case FWAIT_OPCODE:
	  /* fwait is really an instruction.  If there are prefixes
	     before the fwait, they belong to the fwait, *not* to the
	     following instruction.  */
	  if (prefixes)
f01082ac:	a1 64 9e 1b f0       	mov    0xf01b9e64,%eax
f01082b1:	85 c0                	test   %eax,%eax
f01082b3:	74 12                	je     f01082c7 <print_insn_i386+0x559>
	    {
	      prefixes |= PREFIX_FWAIT;
f01082b5:	80 cc 08             	or     $0x8,%ah
f01082b8:	a3 64 9e 1b f0       	mov    %eax,0xf01b9e64
	      codep++;
f01082bd:	8d 41 01             	lea    0x1(%ecx),%eax
f01082c0:	a3 6c 9f 1b f0       	mov    %eax,0xf01b9f6c
f01082c5:	eb 43                	jmp    f010830a <print_insn_i386+0x59c>
	      return;
	    }
	  prefixes = PREFIX_FWAIT;
f01082c7:	c7 05 64 9e 1b f0 00 	movl   $0x800,0xf01b9e64
f01082ce:	08 00 00 
f01082d1:	bb 00 00 00 00       	mov    $0x0,%ebx
	  break;
	default:
	  return;
	}
      /* Rex is ignored when followed by another prefix.  */
      if (rex)
f01082d6:	a1 68 9e 1b f0       	mov    0xf01b9e68,%eax
f01082db:	85 c0                	test   %eax,%eax
f01082dd:	74 19                	je     f01082f8 <print_insn_i386+0x58a>
	{
	  oappend (prefix_name (rex, 0));
f01082df:	ba 00 00 00 00       	mov    $0x0,%edx
f01082e4:	e8 92 d3 ff ff       	call   f010567b <prefix_name>
f01082e9:	e8 7f de ff ff       	call   f010616d <oappend>
	  oappend (" ");
f01082ee:	b8 37 a2 10 f0       	mov    $0xf010a237,%eax
f01082f3:	e8 75 de ff ff       	call   f010616d <oappend>
	}
      rex = newrex;
f01082f8:	89 1d 68 9e 1b f0    	mov    %ebx,0xf01b9e68
      codep++;
f01082fe:	83 05 6c 9f 1b f0 01 	addl   $0x1,0xf01b9f6c
f0108305:	e9 0a fe ff ff       	jmp    f0108114 <print_insn_i386+0x3a6>
    }

  obufp = obuf;
  ckprefix ();

  insn_codep = codep;
f010830a:	a1 6c 9f 1b f0       	mov    0xf01b9f6c,%eax
f010830f:	a3 68 9f 1b f0       	mov    %eax,0xf01b9f68
  sizeflag = priv.orig_sizeflag;
f0108314:	8b 7d f0             	mov    -0x10(%ebp),%edi

  FETCH_DATA (info, codep + 1);
f0108317:	8d 50 01             	lea    0x1(%eax),%edx
f010831a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010831d:	8b 41 20             	mov    0x20(%ecx),%eax
f0108320:	3b 10                	cmp    (%eax),%edx
f0108322:	76 07                	jbe    f010832b <print_insn_i386+0x5bd>
f0108324:	89 c8                	mov    %ecx,%eax
f0108326:	e8 c5 d2 ff ff       	call   f01055f0 <fetch_data>
  //cprintf("***************print_insn:codep1=%x******************\n",*codep);
  two_source_ops = (*codep == 0x62) || (*codep == 0xc8);
f010832b:	8b 0d 6c 9f 1b f0    	mov    0xf01b9f6c,%ecx
f0108331:	0f b6 01             	movzbl (%ecx),%eax
f0108334:	88 45 c3             	mov    %al,-0x3d(%ebp)

  if ((prefixes & PREFIX_FWAIT)
f0108337:	f6 05 65 9e 1b f0 08 	testb  $0x8,0xf01b9e65
f010833e:	74 36                	je     f0108376 <print_insn_i386+0x608>
f0108340:	83 c0 28             	add    $0x28,%eax
f0108343:	3c 07                	cmp    $0x7,%al
f0108345:	76 2f                	jbe    f0108376 <print_insn_i386+0x608>
    {
      const char *name;

      /* fwait not followed by floating point instruction.  Print the
         first prefix, which is probably fwait itself.  */
      name = prefix_name (priv.the_buffer[0], priv.orig_sizeflag);
f0108347:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010834a:	0f b6 45 d4          	movzbl -0x2c(%ebp),%eax
f010834e:	e8 28 d3 ff ff       	call   f010567b <prefix_name>
      if (name == NULL)
f0108353:	85 c0                	test   %eax,%eax
f0108355:	75 05                	jne    f010835c <print_insn_i386+0x5ee>
f0108357:	b8 1e b7 10 f0       	mov    $0xf010b71e,%eax
	name = INTERNAL_DISASSEMBLER_ERROR;
      /*****************************************/
      //Add your code here,print name
      cprintf("%s",name);
f010835c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108360:	c7 04 24 5e ae 10 f0 	movl   $0xf010ae5e,(%esp)
f0108367:	e8 6b b6 ff ff       	call   f01039d7 <cprintf>
f010836c:	b8 01 00 00 00       	mov    $0x1,%eax
f0108371:	e9 5f 07 00 00       	jmp    f0108ad5 <print_insn_i386+0xd67>
      return 1;
    }

  if (*codep == 0x0f)
f0108376:	80 7d c3 0f          	cmpb   $0xf,-0x3d(%ebp)
f010837a:	75 4d                	jne    f01083c9 <print_insn_i386+0x65b>
    {
      FETCH_DATA (info, codep + 2);
f010837c:	8d 51 02             	lea    0x2(%ecx),%edx
f010837f:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0108382:	8b 41 20             	mov    0x20(%ecx),%eax
f0108385:	3b 10                	cmp    (%eax),%edx
f0108387:	76 07                	jbe    f0108390 <print_insn_i386+0x622>
f0108389:	89 c8                	mov    %ecx,%eax
f010838b:	e8 60 d2 ff ff       	call   f01055f0 <fetch_data>
      dp = &dis386_twobyte[*++codep];
f0108390:	8b 0d 6c 9f 1b f0    	mov    0xf01b9f6c,%ecx
f0108396:	83 c1 01             	add    $0x1,%ecx
f0108399:	0f b6 11             	movzbl (%ecx),%edx
f010839c:	6b c2 1c             	imul   $0x1c,%edx,%eax
f010839f:	8d 98 e0 d1 10 f0    	lea    -0xfef2e20(%eax),%ebx
      need_modrm = twobyte_has_modrm[*codep];
f01083a5:	0f b6 82 e0 ed 10 f0 	movzbl -0xfef1220(%edx),%eax
f01083ac:	a2 80 9f 1b f0       	mov    %al,0xf01b9f80
      uses_SSE_prefix = twobyte_uses_SSE_prefix[*codep];
f01083b1:	0f b6 b2 e0 ee 10 f0 	movzbl -0xfef1120(%edx),%esi
      dp = &dis386[*codep];
      need_modrm = onebyte_has_modrm[*codep];
      uses_SSE_prefix = 0;
      //cprintf("codep=%x neda_modrm=%d\n",*codep,need_modrm);
    }
  codep++;
f01083b8:	83 c1 01             	add    $0x1,%ecx
f01083bb:	89 0d 6c 9f 1b f0    	mov    %ecx,0xf01b9f6c

  if (!uses_SSE_prefix && (prefixes & PREFIX_REPZ))
f01083c1:	89 f0                	mov    %esi,%eax
f01083c3:	84 c0                	test   %al,%al
f01083c5:	74 28                	je     f01083ef <print_insn_i386+0x681>
f01083c7:	eb 5a                	jmp    f0108423 <print_insn_i386+0x6b5>
      uses_SSE_prefix = twobyte_uses_SSE_prefix[*codep];
    }
  else
    {
     // cprintf("**********codep=%x*********\n",*codep);	
      dp = &dis386[*codep];
f01083c9:	0f b6 55 c3          	movzbl -0x3d(%ebp),%edx
f01083cd:	6b c2 1c             	imul   $0x1c,%edx,%eax
f01083d0:	8d 98 e0 ef 10 f0    	lea    -0xfef1020(%eax),%ebx
      need_modrm = onebyte_has_modrm[*codep];
f01083d6:	0f b6 82 e0 0b 11 f0 	movzbl -0xfeef420(%edx),%eax
f01083dd:	a2 80 9f 1b f0       	mov    %al,0xf01b9f80
      uses_SSE_prefix = 0;
      //cprintf("codep=%x neda_modrm=%d\n",*codep,need_modrm);
    }
  codep++;
f01083e2:	8d 41 01             	lea    0x1(%ecx),%eax
f01083e5:	a3 6c 9f 1b f0       	mov    %eax,0xf01b9f6c
f01083ea:	be 00 00 00 00       	mov    $0x0,%esi

  if (!uses_SSE_prefix && (prefixes & PREFIX_REPZ))
f01083ef:	f6 05 64 9e 1b f0 01 	testb  $0x1,0xf01b9e64
f01083f6:	0f 84 bc 06 00 00    	je     f0108ab8 <print_insn_i386+0xd4a>
    {
      oappend ("repz ");
f01083fc:	b8 fe b7 10 f0       	mov    $0xf010b7fe,%eax
f0108401:	e8 67 dd ff ff       	call   f010616d <oappend>
      used_prefixes |= PREFIX_REPZ;
f0108406:	83 0d 70 9e 1b f0 01 	orl    $0x1,0xf01b9e70
f010840d:	e9 a6 06 00 00       	jmp    f0108ab8 <print_insn_i386+0xd4a>
    }
  if (!uses_SSE_prefix && (prefixes & PREFIX_REPNZ))
    {
      oappend ("repnz ");
f0108412:	b8 04 b8 10 f0       	mov    $0xf010b804,%eax
f0108417:	e8 51 dd ff ff       	call   f010616d <oappend>
      used_prefixes |= PREFIX_REPNZ;
f010841c:	83 0d 70 9e 1b f0 02 	orl    $0x2,0xf01b9e70
    }
  if (prefixes & PREFIX_LOCK)
f0108423:	f6 05 64 9e 1b f0 04 	testb  $0x4,0xf01b9e64
f010842a:	74 11                	je     f010843d <print_insn_i386+0x6cf>
    {
      oappend ("lock ");
f010842c:	b8 0b b8 10 f0       	mov    $0xf010b80b,%eax
f0108431:	e8 37 dd ff ff       	call   f010616d <oappend>
      used_prefixes |= PREFIX_LOCK;
f0108436:	83 0d 70 9e 1b f0 04 	orl    $0x4,0xf01b9e70
    }

  if (prefixes & PREFIX_ADDR)
f010843d:	f6 05 65 9e 1b f0 04 	testb  $0x4,0xf01b9e65
f0108444:	74 43                	je     f0108489 <print_insn_i386+0x71b>
    {
      sizeflag ^= AFLAG;
f0108446:	83 f7 02             	xor    $0x2,%edi
      if (dp->bytemode3 != loop_jcxz_mode || intel_syntax)
f0108449:	83 7b 18 09          	cmpl   $0x9,0x18(%ebx)
f010844d:	75 09                	jne    f0108458 <print_insn_i386+0x6ea>
f010844f:	80 3d 50 a1 1b f0 00 	cmpb   $0x0,0xf01ba150
f0108456:	74 31                	je     f0108489 <print_insn_i386+0x71b>
	{
	  if ((sizeflag & AFLAG) || mode_64bit)
f0108458:	f7 c7 02 00 00 00    	test   $0x2,%edi
f010845e:	75 09                	jne    f0108469 <print_insn_i386+0x6fb>
f0108460:	83 3d 60 9e 1b f0 00 	cmpl   $0x0,0xf01b9e60
f0108467:	74 0c                	je     f0108475 <print_insn_i386+0x707>
	    oappend ("addr32 ");
f0108469:	b8 11 b8 10 f0       	mov    $0xf010b811,%eax
f010846e:	e8 fa dc ff ff       	call   f010616d <oappend>
f0108473:	eb 0a                	jmp    f010847f <print_insn_i386+0x711>
	  else
	    oappend ("addr16 ");
f0108475:	b8 19 b8 10 f0       	mov    $0xf010b819,%eax
f010847a:	e8 ee dc ff ff       	call   f010616d <oappend>
	  used_prefixes |= PREFIX_ADDR;
f010847f:	81 0d 70 9e 1b f0 00 	orl    $0x400,0xf01b9e70
f0108486:	04 00 00 
	}
    }

  if (!uses_SSE_prefix && (prefixes & PREFIX_DATA))
f0108489:	89 f2                	mov    %esi,%edx
f010848b:	84 d2                	test   %dl,%dl
f010848d:	75 49                	jne    f01084d8 <print_insn_i386+0x76a>
f010848f:	f6 05 65 9e 1b f0 02 	testb  $0x2,0xf01b9e65
f0108496:	74 40                	je     f01084d8 <print_insn_i386+0x76a>
    {
      sizeflag ^= DFLAG;
f0108498:	83 f7 01             	xor    $0x1,%edi
      if (dp->bytemode3 == cond_jump_mode
f010849b:	83 7b 18 08          	cmpl   $0x8,0x18(%ebx)
f010849f:	75 37                	jne    f01084d8 <print_insn_i386+0x76a>
f01084a1:	83 7b 08 02          	cmpl   $0x2,0x8(%ebx)
f01084a5:	75 31                	jne    f01084d8 <print_insn_i386+0x76a>
f01084a7:	80 3d 50 a1 1b f0 00 	cmpb   $0x0,0xf01ba150
f01084ae:	75 28                	jne    f01084d8 <print_insn_i386+0x76a>
	  && dp->bytemode1 == v_mode
	  && !intel_syntax)
	{
	  if (sizeflag & DFLAG)
f01084b0:	f7 c7 01 00 00 00    	test   $0x1,%edi
f01084b6:	74 0c                	je     f01084c4 <print_insn_i386+0x756>
	    oappend ("data32 ");
f01084b8:	b8 21 b8 10 f0       	mov    $0xf010b821,%eax
f01084bd:	e8 ab dc ff ff       	call   f010616d <oappend>
f01084c2:	eb 0a                	jmp    f01084ce <print_insn_i386+0x760>
	  else
	    oappend ("data16 ");
f01084c4:	b8 29 b8 10 f0       	mov    $0xf010b829,%eax
f01084c9:	e8 9f dc ff ff       	call   f010616d <oappend>
	  used_prefixes |= PREFIX_DATA;
f01084ce:	81 0d 70 9e 1b f0 00 	orl    $0x200,0xf01b9e70
f01084d5:	02 00 00 
	}
    }

  if (need_modrm)
f01084d8:	80 3d 80 9f 1b f0 00 	cmpb   $0x0,0xf01b9f80
f01084df:	74 45                	je     f0108526 <print_insn_i386+0x7b8>
    {
      FETCH_DATA (info, codep + 1);
f01084e1:	8b 15 6c 9f 1b f0    	mov    0xf01b9f6c,%edx
f01084e7:	83 c2 01             	add    $0x1,%edx
f01084ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01084ed:	8b 41 20             	mov    0x20(%ecx),%eax
f01084f0:	3b 10                	cmp    (%eax),%edx
f01084f2:	76 07                	jbe    f01084fb <print_insn_i386+0x78d>
f01084f4:	89 c8                	mov    %ecx,%eax
f01084f6:	e8 f5 d0 ff ff       	call   f01055f0 <fetch_data>
      mod = (*codep >> 6) & 3;
f01084fb:	a1 6c 9f 1b f0       	mov    0xf01b9f6c,%eax
f0108500:	0f b6 10             	movzbl (%eax),%edx
f0108503:	89 d0                	mov    %edx,%eax
f0108505:	c0 e8 06             	shr    $0x6,%al
f0108508:	83 e0 03             	and    $0x3,%eax
f010850b:	a3 74 9f 1b f0       	mov    %eax,0xf01b9f74
      reg = (*codep >> 3) & 7;
f0108510:	89 d0                	mov    %edx,%eax
f0108512:	c0 e8 03             	shr    $0x3,%al
f0108515:	83 e0 07             	and    $0x7,%eax
f0108518:	a3 7c 9f 1b f0       	mov    %eax,0xf01b9f7c
      rm = *codep & 7;
f010851d:	83 e2 07             	and    $0x7,%edx
f0108520:	89 15 78 9f 1b f0    	mov    %edx,0xf01b9f78
      //cprintf("need_modrm:mod=%x reg=%x rm=%x\n",mod,reg,rm);
    }

  if (dp->name == NULL && dp->bytemode1 == FLOATCODE)
f0108526:	83 3b 00             	cmpl   $0x0,(%ebx)
f0108529:	0f 85 26 02 00 00    	jne    f0108755 <print_insn_i386+0x9e7>
f010852f:	8b 43 08             	mov    0x8(%ebx),%eax
f0108532:	83 f8 01             	cmp    $0x1,%eax
f0108535:	0f 85 6e 01 00 00    	jne    f01086a9 <print_insn_i386+0x93b>
     int sizeflag;
{
  const struct dis386 *dp;
  unsigned char floatop;

  floatop = codep[-1];
f010853b:	a1 6c 9f 1b f0       	mov    0xf01b9f6c,%eax
f0108540:	0f b6 58 ff          	movzbl -0x1(%eax),%ebx

  if (mod != 3)
f0108544:	83 3d 74 9f 1b f0 03 	cmpl   $0x3,0xf01b9f74
f010854b:	74 6d                	je     f01085ba <print_insn_i386+0x84c>
    {
      putop (float_mem[(floatop - 0xd8) * 8 + reg], sizeflag);
f010854d:	0f b6 c3             	movzbl %bl,%eax
f0108550:	c1 e0 03             	shl    $0x3,%eax
f0108553:	03 05 7c 9f 1b f0    	add    0xf01b9f7c,%eax
f0108559:	8b 04 85 40 16 11 f0 	mov    -0xfeee9c0(,%eax,4),%eax
f0108560:	89 fa                	mov    %edi,%edx
f0108562:	e8 a0 d4 ff ff       	call   f0105a07 <putop>
      obufp = op1out;
f0108567:	c7 05 e4 9e 1b f0 a0 	movl   $0xf01b9fa0,0xf01b9ee4
f010856e:	9f 1b f0 
      if (floatop == 0xdb)
f0108571:	80 fb db             	cmp    $0xdb,%bl
f0108574:	75 15                	jne    f010858b <print_insn_i386+0x81d>
        OP_E (x_mode, sizeflag);
f0108576:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010857a:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
f0108581:	e8 2e ec ff ff       	call   f01071b4 <OP_E>
f0108586:	e9 4c 02 00 00       	jmp    f01087d7 <print_insn_i386+0xa69>
      else if (floatop == 0xdd)
f010858b:	80 fb dd             	cmp    $0xdd,%bl
f010858e:	75 15                	jne    f01085a5 <print_insn_i386+0x837>
        OP_E (d_mode, sizeflag);
f0108590:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0108594:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
f010859b:	e8 14 ec ff ff       	call   f01071b4 <OP_E>
f01085a0:	e9 32 02 00 00       	jmp    f01087d7 <print_insn_i386+0xa69>
      else
        OP_E (v_mode, sizeflag);
f01085a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01085a9:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
f01085b0:	e8 ff eb ff ff       	call   f01071b4 <OP_E>
f01085b5:	e9 1d 02 00 00       	jmp    f01087d7 <print_insn_i386+0xa69>
      return;
    }
  /* Skip mod/rm byte.  */
  MODRM_CHECK;
f01085ba:	80 3d 80 9f 1b f0 00 	cmpb   $0x0,0xf01b9f80
f01085c1:	75 1c                	jne    f01085df <print_insn_i386+0x871>
f01085c3:	c7 44 24 08 60 b7 10 	movl   $0xf010b760,0x8(%esp)
f01085ca:	f0 
f01085cb:	c7 44 24 04 ef 09 00 	movl   $0x9ef,0x4(%esp)
f01085d2:	00 
f01085d3:	c7 04 24 a3 b6 10 f0 	movl   $0xf010b6a3,(%esp)
f01085da:	e8 a7 7a ff ff       	call   f0100086 <_panic>
  codep++;
f01085df:	83 c0 01             	add    $0x1,%eax
f01085e2:	a3 6c 9f 1b f0       	mov    %eax,0xf01b9f6c
  dp = &float_reg[floatop - 0xd8][reg];
f01085e7:	0f b6 c3             	movzbl %bl,%eax
f01085ea:	69 c0 e0 00 00 00    	imul   $0xe0,%eax,%eax
f01085f0:	6b 15 7c 9f 1b f0 1c 	imul   $0x1c,0xf01b9f7c,%edx
f01085f7:	01 d0                	add    %edx,%eax
f01085f9:	8d b0 40 75 10 f0    	lea    -0xfef8ac0(%eax),%esi
  if (dp->name == NULL)
f01085ff:	8b 80 40 75 10 f0    	mov    -0xfef8ac0(%eax),%eax
f0108605:	85 c0                	test   %eax,%eax
f0108607:	75 56                	jne    f010865f <print_insn_i386+0x8f1>
    {
      putop (fgrps[dp->bytemode1][rm], sizeflag);
f0108609:	8b 46 08             	mov    0x8(%esi),%eax
f010860c:	c1 e0 03             	shl    $0x3,%eax
f010860f:	03 05 78 9f 1b f0    	add    0xf01b9f78,%eax
f0108615:	8b 04 85 40 39 11 f0 	mov    -0xfeec6c0(,%eax,4),%eax
f010861c:	89 fa                	mov    %edi,%edx
f010861e:	e8 e4 d3 ff ff       	call   f0105a07 <putop>

      /* Instruction fnstsw is only one with strange arg.  */
      if (floatop == 0xdf && codep[-1] == 0xe0)
f0108623:	80 fb df             	cmp    $0xdf,%bl
f0108626:	0f 85 ab 01 00 00    	jne    f01087d7 <print_insn_i386+0xa69>
f010862c:	a1 6c 9f 1b f0       	mov    0xf01b9f6c,%eax
f0108631:	80 78 ff e0          	cmpb   $0xe0,-0x1(%eax)
f0108635:	0f 85 9c 01 00 00    	jne    f01087d7 <print_insn_i386+0xa69>
	{
        	pstrcpy (op1out, sizeof(op1out), names16[0]);
f010863b:	a1 8c 9f 1b f0       	mov    0xf01b9f8c,%eax
f0108640:	8b 00                	mov    (%eax),%eax
f0108642:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108646:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f010864d:	00 
f010864e:	c7 04 24 a0 9f 1b f0 	movl   $0xf01b9fa0,(%esp)
f0108655:	e8 c3 0e 00 00       	call   f010951d <pstrcpy>
f010865a:	e9 78 01 00 00       	jmp    f01087d7 <print_insn_i386+0xa69>
        	//add your code here
        }
    }
  else
    {
      putop (dp->name, sizeflag);
f010865f:	89 fa                	mov    %edi,%edx
f0108661:	e8 a1 d3 ff ff       	call   f0105a07 <putop>

      obufp = op1out;
f0108666:	c7 05 e4 9e 1b f0 a0 	movl   $0xf01b9fa0,0xf01b9ee4
f010866d:	9f 1b f0 
      if (dp->op1)
f0108670:	8b 56 04             	mov    0x4(%esi),%edx
f0108673:	85 d2                	test   %edx,%edx
f0108675:	74 0c                	je     f0108683 <print_insn_i386+0x915>
	(*dp->op1) (dp->bytemode1, sizeflag);
f0108677:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010867b:	8b 46 08             	mov    0x8(%esi),%eax
f010867e:	89 04 24             	mov    %eax,(%esp)
f0108681:	ff d2                	call   *%edx
      obufp = op2out;
f0108683:	c7 05 e4 9e 1b f0 20 	movl   $0xf01ba020,0xf01b9ee4
f010868a:	a0 1b f0 
      if (dp->op2)
f010868d:	8b 56 0c             	mov    0xc(%esi),%edx
f0108690:	85 d2                	test   %edx,%edx
f0108692:	0f 84 3f 01 00 00    	je     f01087d7 <print_insn_i386+0xa69>
	(*dp->op2) (dp->bytemode2, sizeflag);
f0108698:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010869c:	8b 46 10             	mov    0x10(%esi),%eax
f010869f:	89 04 24             	mov    %eax,(%esp)
f01086a2:	ff d2                	call   *%edx
f01086a4:	e9 2e 01 00 00       	jmp    f01087d7 <print_insn_i386+0xa69>
  else
    {
      int index;
      if (dp->name == NULL)
	{
	  switch (dp->bytemode1)
f01086a9:	83 f8 03             	cmp    $0x3,%eax
f01086ac:	74 29                	je     f01086d7 <print_insn_i386+0x969>
f01086ae:	83 f8 04             	cmp    $0x4,%eax
f01086b1:	0f 84 80 00 00 00    	je     f0108737 <print_insn_i386+0x9c9>
f01086b7:	83 f8 02             	cmp    $0x2,%eax
f01086ba:	0f 85 8b 00 00 00    	jne    f010874b <print_insn_i386+0x9dd>
	    {
	    case USE_GROUPS:
	      dp = &grps[dp->bytemode2][reg];
f01086c0:	69 53 10 e0 00 00 00 	imul   $0xe0,0x10(%ebx),%edx
f01086c7:	6b 05 7c 9f 1b f0 1c 	imul   $0x1c,0xf01b9f7c,%eax
f01086ce:	8d 9c 02 e0 0c 11 f0 	lea    -0xfeef320(%edx,%eax,1),%ebx
f01086d5:	eb 7e                	jmp    f0108755 <print_insn_i386+0x9e7>
	      break;

	    case USE_PREFIX_USER_TABLE:
	      index = 0;
	      used_prefixes |= (prefixes & PREFIX_REPZ);
f01086d7:	8b 15 64 9e 1b f0    	mov    0xf01b9e64,%edx
f01086dd:	89 d0                	mov    %edx,%eax
f01086df:	83 e0 01             	and    $0x1,%eax
f01086e2:	89 c6                	mov    %eax,%esi
f01086e4:	0b 35 70 9e 1b f0    	or     0xf01b9e70,%esi
f01086ea:	89 35 70 9e 1b f0    	mov    %esi,0xf01b9e70
	      if (prefixes & PREFIX_REPZ)
f01086f0:	b9 01 00 00 00       	mov    $0x1,%ecx
f01086f5:	85 c0                	test   %eax,%eax
f01086f7:	75 2e                	jne    f0108727 <print_insn_i386+0x9b9>
		index = 1;
	      else
		{
		  used_prefixes |= (prefixes & PREFIX_DATA);
f01086f9:	89 d0                	mov    %edx,%eax
f01086fb:	25 00 02 00 00       	and    $0x200,%eax
f0108700:	09 c6                	or     %eax,%esi
f0108702:	89 35 70 9e 1b f0    	mov    %esi,0xf01b9e70
		  if (prefixes & PREFIX_DATA)
f0108708:	b9 02 00 00 00       	mov    $0x2,%ecx
f010870d:	85 c0                	test   %eax,%eax
f010870f:	75 16                	jne    f0108727 <print_insn_i386+0x9b9>
		    index = 2;
		  else
		    {
		      used_prefixes |= (prefixes & PREFIX_REPNZ);
f0108711:	83 e2 02             	and    $0x2,%edx
f0108714:	89 f0                	mov    %esi,%eax
f0108716:	09 d0                	or     %edx,%eax
f0108718:	a3 70 9e 1b f0       	mov    %eax,0xf01b9e70
		      if (prefixes & PREFIX_REPNZ)
f010871d:	83 fa 01             	cmp    $0x1,%edx
f0108720:	19 c9                	sbb    %ecx,%ecx
f0108722:	f7 d1                	not    %ecx
f0108724:	83 e1 03             	and    $0x3,%ecx
			index = 3;
		    }
		}
	      dp = &prefix_user_table[dp->bytemode2][index];
f0108727:	6b 53 10 70          	imul   $0x70,0x10(%ebx),%edx
f010872b:	6b c1 1c             	imul   $0x1c,%ecx,%eax
f010872e:	8d 9c 02 00 21 11 f0 	lea    -0xfeedf00(%edx,%eax,1),%ebx
f0108735:	eb 1e                	jmp    f0108755 <print_insn_i386+0x9e7>
	      break;

	    case X86_64_SPECIAL:
	      dp = &x86_64_table[dp->bytemode2][mode_64bit];
f0108737:	6b 53 10 38          	imul   $0x38,0x10(%ebx),%edx
f010873b:	6b 05 60 9e 1b f0 1c 	imul   $0x1c,0xf01b9e60,%eax
f0108742:	8d 9c 02 e0 2c 11 f0 	lea    -0xfeed320(%edx,%eax,1),%ebx
f0108749:	eb 0a                	jmp    f0108755 <print_insn_i386+0x9e7>
	      break;

	    default:
	      oappend (INTERNAL_DISASSEMBLER_ERROR);
f010874b:	b8 1e b7 10 f0       	mov    $0xf010b71e,%eax
f0108750:	e8 18 da ff ff       	call   f010616d <oappend>
	      break;
	    }
	}
      //cprintf("*****op1out=%s*****\n",op1out);
      if (putop (dp->name, sizeflag) == 0)
f0108755:	89 fa                	mov    %edi,%edx
f0108757:	8b 03                	mov    (%ebx),%eax
f0108759:	e8 a9 d2 ff ff       	call   f0105a07 <putop>
f010875e:	85 c0                	test   %eax,%eax
f0108760:	75 75                	jne    f01087d7 <print_insn_i386+0xa69>
	{
	  obufp = op1out;
f0108762:	c7 05 e4 9e 1b f0 a0 	movl   $0xf01b9fa0,0xf01b9ee4
f0108769:	9f 1b f0 
	  op_ad = 2;
f010876c:	c7 05 04 a1 1b f0 02 	movl   $0x2,0xf01ba104
f0108773:	00 00 00 
	  if (dp->op1)
f0108776:	8b 53 04             	mov    0x4(%ebx),%edx
f0108779:	85 d2                	test   %edx,%edx
f010877b:	74 0c                	je     f0108789 <print_insn_i386+0xa1b>
	    (*dp->op1) (dp->bytemode1, sizeflag);
f010877d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0108781:	8b 43 08             	mov    0x8(%ebx),%eax
f0108784:	89 04 24             	mov    %eax,(%esp)
f0108787:	ff d2                	call   *%edx
	  //obufp = op1out;
	  //cprintf("obufp=%c%c%c%c%c\n",obufp[0],obufp[1],obufp[2],obufp[3],obufp[4]);
	//  cprintf("obufp=%s op1out=%s\n",obufp,op1out);
	  obufp = op2out;
f0108789:	c7 05 e4 9e 1b f0 20 	movl   $0xf01ba020,0xf01b9ee4
f0108790:	a0 1b f0 
	  op_ad = 1;
f0108793:	c7 05 04 a1 1b f0 01 	movl   $0x1,0xf01ba104
f010879a:	00 00 00 
	  if (dp->op2)
f010879d:	8b 53 0c             	mov    0xc(%ebx),%edx
f01087a0:	85 d2                	test   %edx,%edx
f01087a2:	74 0c                	je     f01087b0 <print_insn_i386+0xa42>
	    (*dp->op2) (dp->bytemode2, sizeflag);
f01087a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01087a8:	8b 43 10             	mov    0x10(%ebx),%eax
f01087ab:	89 04 24             	mov    %eax,(%esp)
f01087ae:	ff d2                	call   *%edx

	  obufp = op3out;
f01087b0:	c7 05 e4 9e 1b f0 a0 	movl   $0xf01ba0a0,0xf01b9ee4
f01087b7:	a0 1b f0 
	  op_ad = 0;
f01087ba:	c7 05 04 a1 1b f0 00 	movl   $0x0,0xf01ba104
f01087c1:	00 00 00 
	  if (dp->op3)
f01087c4:	8b 53 14             	mov    0x14(%ebx),%edx
f01087c7:	85 d2                	test   %edx,%edx
f01087c9:	74 0c                	je     f01087d7 <print_insn_i386+0xa69>
	    (*dp->op3) (dp->bytemode3, sizeflag);
f01087cb:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01087cf:	8b 43 18             	mov    0x18(%ebx),%eax
f01087d2:	89 04 24             	mov    %eax,(%esp)
f01087d5:	ff d2                	call   *%edx
    //cprintf("***op1out=%s******\n",op1out);	
  /* See if any prefixes were not used.  If so, print the first one
     separately.  If we don't do this, we'll wind up printing an
     instruction stream which does not precisely correspond to the
     bytes we are disassembling.  */
  if ((prefixes & ~used_prefixes) != 0)
f01087d7:	a1 70 9e 1b f0       	mov    0xf01b9e70,%eax
f01087dc:	f7 d0                	not    %eax
f01087de:	85 05 64 9e 1b f0    	test   %eax,0xf01b9e64
f01087e4:	74 2f                	je     f0108815 <print_insn_i386+0xaa7>
    {
      const char *name;

      name = prefix_name (priv.the_buffer[0], priv.orig_sizeflag);
f01087e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01087e9:	0f b6 45 d4          	movzbl -0x2c(%ebp),%eax
f01087ed:	e8 89 ce ff ff       	call   f010567b <prefix_name>
      if (name == NULL)
f01087f2:	85 c0                	test   %eax,%eax
f01087f4:	75 05                	jne    f01087fb <print_insn_i386+0xa8d>
f01087f6:	b8 1e b7 10 f0       	mov    $0xf010b71e,%eax
	name = INTERNAL_DISASSEMBLER_ERROR;
      /*****************************************/
      //Add your code here,print name
      cprintf("%s",name);
f01087fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01087ff:	c7 04 24 5e ae 10 f0 	movl   $0xf010ae5e,(%esp)
f0108806:	e8 cc b1 ff ff       	call   f01039d7 <cprintf>
f010880b:	b8 01 00 00 00       	mov    $0x1,%eax
f0108810:	e9 c0 02 00 00       	jmp    f0108ad5 <print_insn_i386+0xd67>
      return 1;
    }
  if (rex & ~rex_used)
f0108815:	8b 0d 68 9e 1b f0    	mov    0xf01b9e68,%ecx
f010881b:	a1 6c 9e 1b f0       	mov    0xf01b9e6c,%eax
f0108820:	f7 d0                	not    %eax
f0108822:	85 c8                	test   %ecx,%eax
f0108824:	74 26                	je     f010884c <print_insn_i386+0xade>
    {
      const char *name;
      name = prefix_name (rex | 0x40, priv.orig_sizeflag);
f0108826:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0108829:	89 c8                	mov    %ecx,%eax
f010882b:	83 c8 40             	or     $0x40,%eax
f010882e:	e8 48 ce ff ff       	call   f010567b <prefix_name>
      if (name == NULL)
f0108833:	85 c0                	test   %eax,%eax
f0108835:	75 05                	jne    f010883c <print_insn_i386+0xace>
f0108837:	b8 1e b7 10 f0       	mov    $0xf010b71e,%eax
	name = INTERNAL_DISASSEMBLER_ERROR;
      /*****************************************/
      //Add your code here,print name
      cprintf("%s",name);
f010883c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108840:	c7 04 24 5e ae 10 f0 	movl   $0xf010ae5e,(%esp)
f0108847:	e8 8b b1 ff ff       	call   f01039d7 <cprintf>
    }

  obufp = obuf + strlen (obuf);
f010884c:	c7 04 24 80 9e 1b f0 	movl   $0xf01b9e80,(%esp)
f0108853:	e8 d8 0b 00 00       	call   f0109430 <strlen>
f0108858:	05 80 9e 1b f0       	add    $0xf01b9e80,%eax
f010885d:	a3 e4 9e 1b f0       	mov    %eax,0xf01b9ee4
  for (i = strlen (obuf); i < 6; i++)
f0108862:	c7 04 24 80 9e 1b f0 	movl   $0xf01b9e80,(%esp)
f0108869:	e8 c2 0b 00 00       	call   f0109430 <strlen>
f010886e:	89 c3                	mov    %eax,%ebx
f0108870:	83 f8 05             	cmp    $0x5,%eax
f0108873:	7f 12                	jg     f0108887 <print_insn_i386+0xb19>
    oappend (" ");
f0108875:	b8 37 a2 10 f0       	mov    $0xf010a237,%eax
f010887a:	e8 ee d8 ff ff       	call   f010616d <oappend>
      //Add your code here,print name
      cprintf("%s",name);
    }

  obufp = obuf + strlen (obuf);
  for (i = strlen (obuf); i < 6; i++)
f010887f:	83 c3 01             	add    $0x1,%ebx
f0108882:	83 fb 05             	cmp    $0x5,%ebx
f0108885:	7e ee                	jle    f0108875 <print_insn_i386+0xb07>
    oappend (" ");
  oappend (" ");
f0108887:	b8 37 a2 10 f0       	mov    $0xf010a237,%eax
f010888c:	e8 dc d8 ff ff       	call   f010616d <oappend>
  /*****************************************/
  //Add your code here,print obuf
  //cprintf("print_insn:operands is here\n");
  cprintf("%s",obuf);
f0108891:	c7 44 24 04 80 9e 1b 	movl   $0xf01b9e80,0x4(%esp)
f0108898:	f0 
f0108899:	c7 04 24 5e ae 10 f0 	movl   $0xf010ae5e,(%esp)
f01088a0:	e8 32 b1 ff ff       	call   f01039d7 <cprintf>
  //cprintf("\nop1out=%s op2out=%s op3out=%s\n",op1out,op2out,op3out);
  /* The enter and bound instructions are printed with operands in the same
     order as the intel book; everything else is printed in reverse order.  */
  if (intel_syntax || two_source_ops)
f01088a5:	80 3d 50 a1 1b f0 00 	cmpb   $0x0,0xf01ba150
f01088ac:	75 16                	jne    f01088c4 <print_insn_i386+0xb56>
f01088ae:	80 7d c3 62          	cmpb   $0x62,-0x3d(%ebp)
f01088b2:	74 10                	je     f01088c4 <print_insn_i386+0xb56>
f01088b4:	b9 a0 a0 1b f0       	mov    $0xf01ba0a0,%ecx
f01088b9:	bb a0 9f 1b f0       	mov    $0xf01b9fa0,%ebx
f01088be:	80 7d c3 c8          	cmpb   $0xc8,-0x3d(%ebp)
f01088c2:	75 26                	jne    f01088ea <print_insn_i386+0xb7c>
    {
      first = op1out;
      second = op2out;
      third = op3out;
      op_ad = op_index[0];
f01088c4:	8b 15 08 a1 1b f0    	mov    0xf01ba108,%edx
f01088ca:	89 15 04 a1 1b f0    	mov    %edx,0xf01ba104
      op_index[0] = op_index[2];
f01088d0:	a1 10 a1 1b f0       	mov    0xf01ba110,%eax
f01088d5:	a3 08 a1 1b f0       	mov    %eax,0xf01ba108
      op_index[2] = op_ad;
f01088da:	89 15 10 a1 1b f0    	mov    %edx,0xf01ba110
f01088e0:	b9 a0 9f 1b f0       	mov    $0xf01b9fa0,%ecx
f01088e5:	bb a0 a0 1b f0       	mov    $0xf01ba0a0,%ebx
      first = op3out;
      second = op2out;
      third = op1out;
    }
  needcomma = 0;
  if (*first)
f01088ea:	b8 00 00 00 00       	mov    $0x0,%eax
f01088ef:	80 39 00             	cmpb   $0x0,(%ecx)
f01088f2:	74 56                	je     f010894a <print_insn_i386+0xbdc>
    {
      if (op_index[0] != -1 && !op_riprel[0])
f01088f4:	8b 15 08 a1 1b f0    	mov    0xf01ba108,%edx
f01088fa:	83 fa ff             	cmp    $0xffffffff,%edx
f01088fd:	74 36                	je     f0108935 <print_insn_i386+0xbc7>
f01088ff:	a1 30 a1 1b f0       	mov    0xf01ba130,%eax
f0108904:	0b 05 34 a1 1b f0    	or     0xf01ba134,%eax
f010890a:	75 29                	jne    f0108935 <print_insn_i386+0xbc7>
	(*info->print_address_func) ((bfd_vma) op_address[op_index[0]], info);
f010890c:	8b 45 10             	mov    0x10(%ebp),%eax
f010890f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108913:	8b 04 d5 18 a1 1b f0 	mov    -0xfe45ee8(,%edx,8),%eax
f010891a:	8b 14 d5 1c a1 1b f0 	mov    -0xfe45ee4(,%edx,8),%edx
f0108921:	89 04 24             	mov    %eax,(%esp)
f0108924:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108928:	8b 55 10             	mov    0x10(%ebp),%edx
f010892b:	ff 52 2c             	call   *0x2c(%edx)
f010892e:	b8 01 00 00 00       	mov    $0x1,%eax
f0108933:	eb 15                	jmp    f010894a <print_insn_i386+0xbdc>
      else
	{
		/*****************************************/
      		//Add your code here,print first
      		cprintf("%s",first);
f0108935:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0108939:	c7 04 24 5e ae 10 f0 	movl   $0xf010ae5e,(%esp)
f0108940:	e8 92 b0 ff ff       	call   f01039d7 <cprintf>
f0108945:	b8 01 00 00 00       	mov    $0x1,%eax
	}
      needcomma = 1;
    }
  if (*second)
f010894a:	80 3d 20 a0 1b f0 00 	cmpb   $0x0,0xf01ba020
f0108951:	74 6f                	je     f01089c2 <print_insn_i386+0xc54>
    {
      if (needcomma)
f0108953:	85 c0                	test   %eax,%eax
f0108955:	74 14                	je     f010896b <print_insn_i386+0xbfd>
	{
		/*****************************************/
      		//Add your code here,print ,
      		cprintf("%c",',');
f0108957:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
f010895e:	00 
f010895f:	c7 04 24 d8 b6 10 f0 	movl   $0xf010b6d8,(%esp)
f0108966:	e8 6c b0 ff ff       	call   f01039d7 <cprintf>

	}
      if (op_index[1] != -1 && !op_riprel[1])
f010896b:	8b 15 0c a1 1b f0    	mov    0xf01ba10c,%edx
f0108971:	83 fa ff             	cmp    $0xffffffff,%edx
f0108974:	74 33                	je     f01089a9 <print_insn_i386+0xc3b>
f0108976:	a1 38 a1 1b f0       	mov    0xf01ba138,%eax
f010897b:	0b 05 3c a1 1b f0    	or     0xf01ba13c,%eax
f0108981:	75 26                	jne    f01089a9 <print_insn_i386+0xc3b>
	(*info->print_address_func) ((bfd_vma) op_address[op_index[1]], info);
f0108983:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0108986:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010898a:	8b 04 d5 18 a1 1b f0 	mov    -0xfe45ee8(,%edx,8),%eax
f0108991:	8b 14 d5 1c a1 1b f0 	mov    -0xfe45ee4(,%edx,8),%edx
f0108998:	89 04 24             	mov    %eax,(%esp)
f010899b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010899f:	ff 51 2c             	call   *0x2c(%ecx)
f01089a2:	b8 01 00 00 00       	mov    $0x1,%eax
f01089a7:	eb 19                	jmp    f01089c2 <print_insn_i386+0xc54>
      else
	{
		/*****************************************/
      		//Add your code here,print second
      		cprintf("%s",second);
f01089a9:	c7 44 24 04 20 a0 1b 	movl   $0xf01ba020,0x4(%esp)
f01089b0:	f0 
f01089b1:	c7 04 24 5e ae 10 f0 	movl   $0xf010ae5e,(%esp)
f01089b8:	e8 1a b0 ff ff       	call   f01039d7 <cprintf>
f01089bd:	b8 01 00 00 00       	mov    $0x1,%eax

	}
      needcomma = 1;
    }
  if (*third)
f01089c2:	80 3b 00             	cmpb   $0x0,(%ebx)
f01089c5:	0f 84 ff 00 00 00    	je     f0108aca <print_insn_i386+0xd5c>
    {
      if (needcomma)
f01089cb:	85 c0                	test   %eax,%eax
f01089cd:	74 14                	je     f01089e3 <print_insn_i386+0xc75>
	{
                /*****************************************/
                //Add your code here,print ,
                cprintf("%c",',');
f01089cf:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
f01089d6:	00 
f01089d7:	c7 04 24 d8 b6 10 f0 	movl   $0xf010b6d8,(%esp)
f01089de:	e8 f4 af ff ff       	call   f01039d7 <cprintf>
                
        }
      if (op_index[2] != -1 && !op_riprel[2])
f01089e3:	8b 15 10 a1 1b f0    	mov    0xf01ba110,%edx
f01089e9:	83 fa ff             	cmp    $0xffffffff,%edx
f01089ec:	74 34                	je     f0108a22 <print_insn_i386+0xcb4>
f01089ee:	a1 40 a1 1b f0       	mov    0xf01ba140,%eax
f01089f3:	0b 05 44 a1 1b f0    	or     0xf01ba144,%eax
f01089f9:	75 27                	jne    f0108a22 <print_insn_i386+0xcb4>
	(*info->print_address_func) ((bfd_vma) op_address[op_index[2]], info);
f01089fb:	8b 45 10             	mov    0x10(%ebp),%eax
f01089fe:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108a02:	8b 04 d5 18 a1 1b f0 	mov    -0xfe45ee8(,%edx,8),%eax
f0108a09:	8b 14 d5 1c a1 1b f0 	mov    -0xfe45ee4(,%edx,8),%edx
f0108a10:	89 04 24             	mov    %eax,(%esp)
f0108a13:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108a17:	8b 55 10             	mov    0x10(%ebp),%edx
f0108a1a:	ff 52 2c             	call   *0x2c(%edx)
f0108a1d:	e9 a8 00 00 00       	jmp    f0108aca <print_insn_i386+0xd5c>
      else
	{
                /*****************************************/
                //Add your code here,print third
                cprintf("%s",third);
f0108a22:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0108a26:	c7 04 24 5e ae 10 f0 	movl   $0xf010ae5e,(%esp)
f0108a2d:	e8 a5 af ff ff       	call   f01039d7 <cprintf>
f0108a32:	e9 93 00 00 00       	jmp    f0108aca <print_insn_i386+0xd5c>
        }
    }
  //panic("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb");
  for (i = 0; i < 3; i++)
    if (op_index[i] != -1 && op_riprel[i])
f0108a37:	83 3c 9d 08 a1 1b f0 	cmpl   $0xffffffff,-0xfe45ef8(,%ebx,4)
f0108a3e:	ff 
f0108a3f:	74 63                	je     f0108aa4 <print_insn_i386+0xd36>
f0108a41:	8b 04 dd 30 a1 1b f0 	mov    -0xfe45ed0(,%ebx,8),%eax
f0108a48:	0b 04 dd 34 a1 1b f0 	or     -0xfe45ecc(,%ebx,8),%eax
f0108a4f:	74 53                	je     f0108aa4 <print_insn_i386+0xd36>
      {
	/*****************************************/
        //Add your code here,print #
        cprintf("%s","      #");
f0108a51:	c7 44 24 04 31 b8 10 	movl   $0xf010b831,0x4(%esp)
f0108a58:	f0 
f0108a59:	c7 04 24 5e ae 10 f0 	movl   $0xf010ae5e,(%esp)
f0108a60:	e8 72 af ff ff       	call   f01039d7 <cprintf>
	(*info->print_address_func) ((bfd_vma) (start_pc + codep - start_codep
f0108a65:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0108a68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0108a6c:	a1 6c 9f 1b f0       	mov    0xf01b9f6c,%eax
f0108a71:	03 05 48 a1 1b f0    	add    0xf01ba148,%eax
f0108a77:	2b 05 64 9f 1b f0    	sub    0xf01b9f64,%eax
f0108a7d:	89 c2                	mov    %eax,%edx
f0108a7f:	c1 fa 1f             	sar    $0x1f,%edx
f0108a82:	8b 0c 9d 08 a1 1b f0 	mov    -0xfe45ef8(,%ebx,4),%ecx
f0108a89:	03 04 cd 18 a1 1b f0 	add    -0xfe45ee8(,%ecx,8),%eax
f0108a90:	13 14 cd 1c a1 1b f0 	adc    -0xfe45ee4(,%ecx,8),%edx
f0108a97:	89 04 24             	mov    %eax,(%esp)
f0108a9a:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108a9e:	8b 45 10             	mov    0x10(%ebp),%eax
f0108aa1:	ff 50 2c             	call   *0x2c(%eax)
                //Add your code here,print third
                cprintf("%s",third);
        }
    }
  //panic("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb");
  for (i = 0; i < 3; i++)
f0108aa4:	83 c3 01             	add    $0x1,%ebx
f0108aa7:	83 fb 03             	cmp    $0x3,%ebx
f0108aaa:	75 8b                	jne    f0108a37 <print_insn_i386+0xcc9>
        //Add your code here,print #
        cprintf("%s","      #");
	(*info->print_address_func) ((bfd_vma) (start_pc + codep - start_codep
						+ op_address[op_index[i]]), info);
      }
  return codep - priv.the_buffer;
f0108aac:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0108aaf:	a1 6c 9f 1b f0       	mov    0xf01b9f6c,%eax
f0108ab4:	29 d0                	sub    %edx,%eax
f0108ab6:	eb 1d                	jmp    f0108ad5 <print_insn_i386+0xd67>
  if (!uses_SSE_prefix && (prefixes & PREFIX_REPZ))
    {
      oappend ("repz ");
      used_prefixes |= PREFIX_REPZ;
    }
  if (!uses_SSE_prefix && (prefixes & PREFIX_REPNZ))
f0108ab8:	f6 05 64 9e 1b f0 02 	testb  $0x2,0xf01b9e64
f0108abf:	0f 84 5e f9 ff ff    	je     f0108423 <print_insn_i386+0x6b5>
f0108ac5:	e9 48 f9 ff ff       	jmp    f0108412 <print_insn_i386+0x6a4>
f0108aca:	bb 00 00 00 00       	mov    $0x0,%ebx
f0108acf:	90                   	nop    
f0108ad0:	e9 62 ff ff ff       	jmp    f0108a37 <print_insn_i386+0xcc9>
     disassemble_info *info;
{
  intel_syntax = -1;
  //cprintf("intel_syntax1=%d\n",intel_syntax);
  return print_insn (pc, info);
}
f0108ad5:	83 c4 4c             	add    $0x4c,%esp
f0108ad8:	5b                   	pop    %ebx
f0108ad9:	5e                   	pop    %esi
f0108ada:	5f                   	pop    %edi
f0108adb:	5d                   	pop    %ebp
f0108adc:	c3                   	ret    
f0108add:	00 00                	add    %al,(%eax)
	...

f0108ae0 <generic_symbol_at_address>:

/* Just return the given address.  */

int
generic_symbol_at_address (bfd_vma addr, struct disassemble_info *info)
{
f0108ae0:	55                   	push   %ebp
f0108ae1:	89 e5                	mov    %esp,%ebp
  return 1;
}
f0108ae3:	b8 01 00 00 00       	mov    $0x1,%eax
f0108ae8:	5d                   	pop    %ebp
f0108ae9:	c3                   	ret    

f0108aea <bfd_getl32>:

bfd_vma bfd_getl32 (const bfd_byte *addr)
{
f0108aea:	55                   	push   %ebp
f0108aeb:	89 e5                	mov    %esp,%ebp
f0108aed:	83 ec 08             	sub    $0x8,%esp
f0108af0:	89 1c 24             	mov    %ebx,(%esp)
f0108af3:	89 74 24 04          	mov    %esi,0x4(%esp)
f0108af7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  unsigned long v;

  v = (unsigned long) addr[0];
f0108afa:	0f b6 33             	movzbl (%ebx),%esi
  v |= (unsigned long) addr[1] << 8;
f0108afd:	0f b6 43 01          	movzbl 0x1(%ebx),%eax
f0108b01:	c1 e0 08             	shl    $0x8,%eax
f0108b04:	0f b6 4b 02          	movzbl 0x2(%ebx),%ecx
f0108b08:	c1 e1 10             	shl    $0x10,%ecx
f0108b0b:	09 c8                	or     %ecx,%eax
  v |= (unsigned long) addr[2] << 16;
f0108b0d:	09 f0                	or     %esi,%eax
f0108b0f:	0f b6 4b 03          	movzbl 0x3(%ebx),%ecx
f0108b13:	c1 e1 18             	shl    $0x18,%ecx
f0108b16:	09 c8                	or     %ecx,%eax
f0108b18:	ba 00 00 00 00       	mov    $0x0,%edx
  v |= (unsigned long) addr[3] << 24;
  return (bfd_vma) v;
}
f0108b1d:	8b 1c 24             	mov    (%esp),%ebx
f0108b20:	8b 74 24 04          	mov    0x4(%esp),%esi
f0108b24:	89 ec                	mov    %ebp,%esp
f0108b26:	5d                   	pop    %ebp
f0108b27:	c3                   	ret    

f0108b28 <bfd_getb32>:

bfd_vma bfd_getb32 (const bfd_byte *addr)
{
f0108b28:	55                   	push   %ebp
f0108b29:	89 e5                	mov    %esp,%ebp
f0108b2b:	53                   	push   %ebx
f0108b2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  unsigned long v;

  v = (unsigned long) addr[0] << 24;
f0108b2f:	0f b6 0b             	movzbl (%ebx),%ecx
f0108b32:	c1 e1 18             	shl    $0x18,%ecx
  v |= (unsigned long) addr[1] << 16;
f0108b35:	0f b6 43 03          	movzbl 0x3(%ebx),%eax
f0108b39:	09 c8                	or     %ecx,%eax
  v |= (unsigned long) addr[2] << 8;
f0108b3b:	0f b6 4b 01          	movzbl 0x1(%ebx),%ecx
f0108b3f:	c1 e1 10             	shl    $0x10,%ecx
f0108b42:	09 c8                	or     %ecx,%eax
f0108b44:	0f b6 4b 02          	movzbl 0x2(%ebx),%ecx
f0108b48:	c1 e1 08             	shl    $0x8,%ecx
f0108b4b:	09 c8                	or     %ecx,%eax
f0108b4d:	ba 00 00 00 00       	mov    $0x0,%edx
  v |= (unsigned long) addr[3];
  return (bfd_vma) v;
}
f0108b52:	5b                   	pop    %ebx
f0108b53:	5d                   	pop    %ebp
f0108b54:	c3                   	ret    

f0108b55 <bfd_getl16>:

bfd_vma bfd_getl16 (const bfd_byte *addr)
{
f0108b55:	55                   	push   %ebp
f0108b56:	89 e5                	mov    %esp,%ebp
f0108b58:	8b 45 08             	mov    0x8(%ebp),%eax
  unsigned long v;

  v = (unsigned long) addr[0];
f0108b5b:	0f b6 08             	movzbl (%eax),%ecx
f0108b5e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
f0108b62:	c1 e0 08             	shl    $0x8,%eax
f0108b65:	09 c8                	or     %ecx,%eax
f0108b67:	ba 00 00 00 00       	mov    $0x0,%edx
  v |= (unsigned long) addr[1] << 8;
  return (bfd_vma) v;
}
f0108b6c:	5d                   	pop    %ebp
f0108b6d:	c3                   	ret    

f0108b6e <bfd_getb16>:

bfd_vma bfd_getb16 (const bfd_byte *addr)
{
f0108b6e:	55                   	push   %ebp
f0108b6f:	89 e5                	mov    %esp,%ebp
f0108b71:	8b 45 08             	mov    0x8(%ebp),%eax
  unsigned long v;

  v = (unsigned long) addr[0] << 24;
f0108b74:	0f b6 08             	movzbl (%eax),%ecx
f0108b77:	c1 e1 18             	shl    $0x18,%ecx
f0108b7a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
f0108b7e:	c1 e0 10             	shl    $0x10,%eax
f0108b81:	09 c8                	or     %ecx,%eax
f0108b83:	ba 00 00 00 00       	mov    $0x0,%edx
  v |= (unsigned long) addr[1] << 16;
  return (bfd_vma) v;
}
f0108b88:	5d                   	pop    %ebp
f0108b89:	c3                   	ret    

f0108b8a <monitor_disas>:

void monitor_disas(uint32_t pc, int nb_insn)
{
f0108b8a:	55                   	push   %ebp
f0108b8b:	89 e5                	mov    %esp,%ebp
f0108b8d:	57                   	push   %edi
f0108b8e:	56                   	push   %esi
f0108b8f:	53                   	push   %ebx
f0108b90:	83 ec 7c             	sub    $0x7c,%esp
f0108b93:	8b 75 08             	mov    0x8(%ebp),%esi
    int count, i;
    struct disassemble_info disasm_info;
    int (*print_insn)(bfd_vma pc, disassemble_info *info);
    
    INIT_DISASSEMBLE_INFO(disasm_info, NULL, cprintf);
f0108b96:	c7 45 8c 00 00 00 00 	movl   $0x0,-0x74(%ebp)
f0108b9d:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
f0108ba4:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
f0108bab:	c7 45 98 02 00 00 00 	movl   $0x2,-0x68(%ebp)
f0108bb2:	c7 45 9c 00 00 00 00 	movl   $0x0,-0x64(%ebp)
f0108bb9:	c7 45 a0 00 00 00 00 	movl   $0x0,-0x60(%ebp)
f0108bc0:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f0108bc7:	c7 45 ac ee 8c 10 f0 	movl   $0xf0108cee,-0x54(%ebp)
f0108bce:	c7 45 b0 b2 8c 10 f0 	movl   $0xf0108cb2,-0x50(%ebp)
f0108bd5:	c7 45 b4 90 8c 10 f0 	movl   $0xf0108c90,-0x4c(%ebp)
f0108bdc:	c7 45 b8 e0 8a 10 f0 	movl   $0xf0108ae0,-0x48(%ebp)
f0108be3:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0108bea:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f0108bf1:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f0108bf8:	c7 45 d4 02 00 00 00 	movl   $0x2,-0x2c(%ebp)
f0108bff:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0108c06:	c6 45 d8 00          	movb   $0x0,-0x28(%ebp)

    //monitor_disas_env = env;
    //monitor_disas_is_physical = is_physical;
    //disasm_info.read_memory_func = monitor_read_memory;

    disasm_info.buffer_vma = pc;
f0108c0a:	89 75 c0             	mov    %esi,-0x40(%ebp)
f0108c0d:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
    disasm_info.buffer_length=7;
f0108c14:	c7 45 c8 07 00 00 00 	movl   $0x7,-0x38(%ebp)
    disasm_info.buffer=(bfd_byte *)pc;
f0108c1b:	89 75 bc             	mov    %esi,-0x44(%ebp)
    //cprintf("disasm_info=%x\n",&disasm_info);
    //for(i=0;i<7;i++)
    	//cprintf("%x",disasm_info.buffer[i]);
    cprintf("\n");
f0108c1e:	c7 04 24 c9 a2 10 f0 	movl   $0xf010a2c9,(%esp)
f0108c25:	e8 ad ad ff ff       	call   f01039d7 <cprintf>
    disasm_info.endian = BFD_ENDIAN_LITTLE;

    disasm_info.mach = bfd_mach_i386_i386;
    print_insn = print_insn_i386;

    for(i = 0; i < nb_insn; i++) {
f0108c2a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0108c2e:	7e 58                	jle    f0108c88 <monitor_disas+0xfe>
    disasm_info.buffer=(bfd_byte *)pc;
    //cprintf("disasm_info=%x\n",&disasm_info);
    //for(i=0;i<7;i++)
    	//cprintf("%x",disasm_info.buffer[i]);
    cprintf("\n");
    disasm_info.endian = BFD_ENDIAN_LITTLE;
f0108c30:	c7 45 98 01 00 00 00 	movl   $0x1,-0x68(%ebp)

    disasm_info.mach = bfd_mach_i386_i386;
f0108c37:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
f0108c3e:	bf 00 00 00 00       	mov    $0x0,%edi
    print_insn = print_insn_i386;

    for(i = 0; i < nb_insn; i++) {
        cprintf("0x%08x:  ", pc);
f0108c43:	89 74 24 04          	mov    %esi,0x4(%esp)
f0108c47:	c7 04 24 60 3a 11 f0 	movl   $0xf0113a60,(%esp)
f0108c4e:	e8 84 ad ff ff       	call   f01039d7 <cprintf>
	//cprintf("%08x  ", (int)bfd_getl32((const bfd_byte *)pc));
	count = print_insn(pc, &disasm_info);
f0108c53:	8d 45 88             	lea    -0x78(%ebp),%eax
f0108c56:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108c5a:	89 34 24             	mov    %esi,(%esp)
f0108c5d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0108c64:	00 
f0108c65:	e8 04 f1 ff ff       	call   f0107d6e <print_insn_i386>
f0108c6a:	89 c3                	mov    %eax,%ebx
        cprintf("\n");
f0108c6c:	c7 04 24 c9 a2 10 f0 	movl   $0xf010a2c9,(%esp)
f0108c73:	e8 5f ad ff ff       	call   f01039d7 <cprintf>
        if (count < 0)
f0108c78:	85 db                	test   %ebx,%ebx
f0108c7a:	78 0c                	js     f0108c88 <monitor_disas+0xfe>
    disasm_info.endian = BFD_ENDIAN_LITTLE;

    disasm_info.mach = bfd_mach_i386_i386;
    print_insn = print_insn_i386;

    for(i = 0; i < nb_insn; i++) {
f0108c7c:	83 c7 01             	add    $0x1,%edi
f0108c7f:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0108c82:	74 04                	je     f0108c88 <monitor_disas+0xfe>
	//cprintf("%08x  ", (int)bfd_getl32((const bfd_byte *)pc));
	count = print_insn(pc, &disasm_info);
        cprintf("\n");
        if (count < 0)
            break;
        pc += count;
f0108c84:	01 de                	add    %ebx,%esi
f0108c86:	eb bb                	jmp    f0108c43 <monitor_disas+0xb9>
    }
}
f0108c88:	83 c4 7c             	add    $0x7c,%esp
f0108c8b:	5b                   	pop    %ebx
f0108c8c:	5e                   	pop    %esi
f0108c8d:	5f                   	pop    %edi
f0108c8e:	5d                   	pop    %ebp
f0108c8f:	c3                   	ret    

f0108c90 <generic_print_address>:
    cprintf("Address 0x%08x is out of bounds.\n", memaddr);
}

void
generic_print_address (bfd_vma addr, struct disassemble_info *info)
{
f0108c90:	55                   	push   %ebp
f0108c91:	89 e5                	mov    %esp,%ebp
f0108c93:	83 ec 18             	sub    $0x18,%esp
    cprintf("0x%08x",addr);
f0108c96:	8b 45 08             	mov    0x8(%ebp),%eax
f0108c99:	8b 55 0c             	mov    0xc(%ebp),%edx
f0108c9c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108ca0:	89 54 24 08          	mov    %edx,0x8(%esp)
f0108ca4:	c7 04 24 6a 3a 11 f0 	movl   $0xf0113a6a,(%esp)
f0108cab:	e8 27 ad ff ff       	call   f01039d7 <cprintf>
}
f0108cb0:	c9                   	leave  
f0108cb1:	c3                   	ret    

f0108cb2 <perror_memory>:
}
/* Print an error message.  We can assume that this is in response to
 *    an error return from buffer_read_memory.  */
void
perror_memory (int status, bfd_vma memaddr, struct disassemble_info *info)
{
f0108cb2:	55                   	push   %ebp
f0108cb3:	89 e5                	mov    %esp,%ebp
f0108cb5:	83 ec 18             	sub    $0x18,%esp
f0108cb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0108cbb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108cbe:	8b 55 10             	mov    0x10(%ebp),%edx
  if (status != -1)
f0108cc1:	83 f9 ff             	cmp    $0xffffffff,%ecx
f0108cc4:	74 12                	je     f0108cd8 <perror_memory+0x26>
    /* Can't happen.  */
    cprintf("Unknown error %d\n", status);
f0108cc6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0108cca:	c7 04 24 71 3a 11 f0 	movl   $0xf0113a71,(%esp)
f0108cd1:	e8 01 ad ff ff       	call   f01039d7 <cprintf>
f0108cd6:	eb 14                	jmp    f0108cec <perror_memory+0x3a>
  else
    /* Actually, address between memaddr and memaddr + len was
 *        out of bounds.  */
    cprintf("Address 0x%08x is out of bounds.\n", memaddr);
f0108cd8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108cdc:	89 54 24 08          	mov    %edx,0x8(%esp)
f0108ce0:	c7 04 24 84 3a 11 f0 	movl   $0xf0113a84,(%esp)
f0108ce7:	e8 eb ac ff ff       	call   f01039d7 <cprintf>
}
f0108cec:	c9                   	leave  
f0108ced:	c3                   	ret    

f0108cee <buffer_read_memory>:
#include <inc/string.h>
/* Get LENGTH bytes from info's buffer, at target address memaddr.
 *    Transfer them to myaddr.  */
int
buffer_read_memory(bfd_vma memaddr,bfd_byte *myaddr,int length,struct disassemble_info *info)
{
f0108cee:	55                   	push   %ebp
f0108cef:	89 e5                	mov    %esp,%ebp
f0108cf1:	83 ec 48             	sub    $0x48,%esp
f0108cf4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0108cf7:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0108cfa:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0108cfd:	8b 75 08             	mov    0x8(%ebp),%esi
f0108d00:	8b 7d 0c             	mov    0xc(%ebp),%edi
    //cprintf("read:myaddr=%x\n",myaddr);
    if ((memaddr < info->buffer_vma)
f0108d03:	8b 45 18             	mov    0x18(%ebp),%eax
f0108d06:	8b 48 38             	mov    0x38(%eax),%ecx
f0108d09:	8b 58 3c             	mov    0x3c(%eax),%ebx
f0108d0c:	39 fb                	cmp    %edi,%ebx
f0108d0e:	77 78                	ja     f0108d88 <buffer_read_memory+0x9a>
f0108d10:	72 04                	jb     f0108d16 <buffer_read_memory+0x28>
f0108d12:	39 f1                	cmp    %esi,%ecx
f0108d14:	77 72                	ja     f0108d88 <buffer_read_memory+0x9a>
f0108d16:	8b 45 14             	mov    0x14(%ebp),%eax
f0108d19:	89 c2                	mov    %eax,%edx
f0108d1b:	c1 fa 1f             	sar    $0x1f,%edx
f0108d1e:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0108d21:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0108d24:	01 f0                	add    %esi,%eax
f0108d26:	11 fa                	adc    %edi,%edx
f0108d28:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0108d2b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0108d2e:	8b 55 18             	mov    0x18(%ebp),%edx
f0108d31:	8b 42 40             	mov    0x40(%edx),%eax
f0108d34:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0108d37:	89 c2                	mov    %eax,%edx
f0108d39:	c1 fa 1f             	sar    $0x1f,%edx
f0108d3c:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0108d3f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0108d42:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0108d45:	01 c8                	add    %ecx,%eax
f0108d47:	11 da                	adc    %ebx,%edx
f0108d49:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0108d4c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0108d4f:	39 55 e4             	cmp    %edx,-0x1c(%ebp)
f0108d52:	77 34                	ja     f0108d88 <buffer_read_memory+0x9a>
f0108d54:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0108d57:	39 55 e4             	cmp    %edx,-0x1c(%ebp)
f0108d5a:	72 05                	jb     f0108d61 <buffer_read_memory+0x73>
f0108d5c:	39 45 e0             	cmp    %eax,-0x20(%ebp)
f0108d5f:	77 27                	ja     f0108d88 <buffer_read_memory+0x9a>
        /* Out of bounds.  Use EIO because GDB uses it.  */
	{
		//cprintf("read memory error\n");
        	return -1;
	}
    memmove (myaddr, info->buffer + (memaddr - info->buffer_vma), length);  
f0108d61:	8b 45 14             	mov    0x14(%ebp),%eax
f0108d64:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108d68:	89 f0                	mov    %esi,%eax
f0108d6a:	29 c8                	sub    %ecx,%eax
f0108d6c:	8b 55 18             	mov    0x18(%ebp),%edx
f0108d6f:	03 42 34             	add    0x34(%edx),%eax
f0108d72:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108d76:	8b 45 10             	mov    0x10(%ebp),%eax
f0108d79:	89 04 24             	mov    %eax,(%esp)
f0108d7c:	e8 07 09 00 00       	call   f0109688 <memmove>
f0108d81:	b8 00 00 00 00       	mov    $0x0,%eax
f0108d86:	eb 05                	jmp    f0108d8d <buffer_read_memory+0x9f>
    return 0;
f0108d88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0108d8d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0108d90:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0108d93:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0108d96:	89 ec                	mov    %ebp,%esp
f0108d98:	5d                   	pop    %ebp
f0108d99:	c3                   	ret    
f0108d9a:	00 00                	add    %al,(%eax)
f0108d9c:	00 00                	add    %al,(%eax)
	...

f0108da0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0108da0:	55                   	push   %ebp
f0108da1:	89 e5                	mov    %esp,%ebp
f0108da3:	57                   	push   %edi
f0108da4:	56                   	push   %esi
f0108da5:	53                   	push   %ebx
f0108da6:	83 ec 3c             	sub    $0x3c,%esp
f0108da9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0108dac:	89 d7                	mov    %edx,%edi
f0108dae:	8b 45 08             	mov    0x8(%ebp),%eax
f0108db1:	8b 55 0c             	mov    0xc(%ebp),%edx
f0108db4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0108db7:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0108dba:	8b 55 10             	mov    0x10(%ebp),%edx
f0108dbd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0108dc0:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0108dc3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f0108dca:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0108dcd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
f0108dd0:	72 14                	jb     f0108de6 <printnum+0x46>
f0108dd2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0108dd5:	39 45 e8             	cmp    %eax,-0x18(%ebp)
f0108dd8:	76 0c                	jbe    f0108de6 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0108dda:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0108ddd:	83 eb 01             	sub    $0x1,%ebx
f0108de0:	85 db                	test   %ebx,%ebx
f0108de2:	7f 57                	jg     f0108e3b <printnum+0x9b>
f0108de4:	eb 64                	jmp    f0108e4a <printnum+0xaa>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0108de6:	89 74 24 10          	mov    %esi,0x10(%esp)
f0108dea:	8b 45 14             	mov    0x14(%ebp),%eax
f0108ded:	83 e8 01             	sub    $0x1,%eax
f0108df0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0108df4:	89 54 24 08          	mov    %edx,0x8(%esp)
f0108df8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0108dfc:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0108e00:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0108e03:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0108e06:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108e0a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0108e0e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0108e11:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0108e14:	89 04 24             	mov    %eax,(%esp)
f0108e17:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108e1b:	e8 20 0e 00 00       	call   f0109c40 <__udivdi3>
f0108e20:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0108e24:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0108e28:	89 04 24             	mov    %eax,(%esp)
f0108e2b:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108e2f:	89 fa                	mov    %edi,%edx
f0108e31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0108e34:	e8 67 ff ff ff       	call   f0108da0 <printnum>
f0108e39:	eb 0f                	jmp    f0108e4a <printnum+0xaa>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0108e3b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0108e3f:	89 34 24             	mov    %esi,(%esp)
f0108e42:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0108e45:	83 eb 01             	sub    $0x1,%ebx
f0108e48:	75 f1                	jne    f0108e3b <printnum+0x9b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0108e4a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0108e4e:	8b 74 24 04          	mov    0x4(%esp),%esi
f0108e52:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0108e55:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0108e58:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108e5c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0108e60:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0108e63:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0108e66:	89 04 24             	mov    %eax,(%esp)
f0108e69:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108e6d:	e8 fe 0e 00 00       	call   f0109d70 <__umoddi3>
f0108e72:	89 74 24 04          	mov    %esi,0x4(%esp)
f0108e76:	0f be 80 a6 3a 11 f0 	movsbl -0xfeec55a(%eax),%eax
f0108e7d:	89 04 24             	mov    %eax,(%esp)
f0108e80:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0108e83:	83 c4 3c             	add    $0x3c,%esp
f0108e86:	5b                   	pop    %ebx
f0108e87:	5e                   	pop    %esi
f0108e88:	5f                   	pop    %edi
f0108e89:	5d                   	pop    %ebp
f0108e8a:	c3                   	ret    

f0108e8b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0108e8b:	55                   	push   %ebp
f0108e8c:	89 e5                	mov    %esp,%ebp
f0108e8e:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
f0108e90:	83 fa 01             	cmp    $0x1,%edx
f0108e93:	7e 0e                	jle    f0108ea3 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
f0108e95:	8b 10                	mov    (%eax),%edx
f0108e97:	8d 42 08             	lea    0x8(%edx),%eax
f0108e9a:	89 01                	mov    %eax,(%ecx)
f0108e9c:	8b 02                	mov    (%edx),%eax
f0108e9e:	8b 52 04             	mov    0x4(%edx),%edx
f0108ea1:	eb 22                	jmp    f0108ec5 <getuint+0x3a>
	else if (lflag)
f0108ea3:	85 d2                	test   %edx,%edx
f0108ea5:	74 10                	je     f0108eb7 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
f0108ea7:	8b 10                	mov    (%eax),%edx
f0108ea9:	8d 42 04             	lea    0x4(%edx),%eax
f0108eac:	89 01                	mov    %eax,(%ecx)
f0108eae:	8b 02                	mov    (%edx),%eax
f0108eb0:	ba 00 00 00 00       	mov    $0x0,%edx
f0108eb5:	eb 0e                	jmp    f0108ec5 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
f0108eb7:	8b 10                	mov    (%eax),%edx
f0108eb9:	8d 42 04             	lea    0x4(%edx),%eax
f0108ebc:	89 01                	mov    %eax,(%ecx)
f0108ebe:	8b 02                	mov    (%edx),%eax
f0108ec0:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0108ec5:	5d                   	pop    %ebp
f0108ec6:	c3                   	ret    

f0108ec7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0108ec7:	55                   	push   %ebp
f0108ec8:	89 e5                	mov    %esp,%ebp
f0108eca:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
f0108ecd:	83 42 08 01          	addl   $0x1,0x8(%edx)
	if (b->buf < b->ebuf)
f0108ed1:	8b 02                	mov    (%edx),%eax
f0108ed3:	3b 42 04             	cmp    0x4(%edx),%eax
f0108ed6:	73 0b                	jae    f0108ee3 <sprintputch+0x1c>
		*b->buf++ = ch;
f0108ed8:	0f b6 4d 08          	movzbl 0x8(%ebp),%ecx
f0108edc:	88 08                	mov    %cl,(%eax)
f0108ede:	83 c0 01             	add    $0x1,%eax
f0108ee1:	89 02                	mov    %eax,(%edx)
}
f0108ee3:	5d                   	pop    %ebp
f0108ee4:	c3                   	ret    

f0108ee5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0108ee5:	55                   	push   %ebp
f0108ee6:	89 e5                	mov    %esp,%ebp
f0108ee8:	57                   	push   %edi
f0108ee9:	56                   	push   %esi
f0108eea:	53                   	push   %ebx
f0108eeb:	83 ec 3c             	sub    $0x3c,%esp
f0108eee:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0108ef1:	eb 18                	jmp    f0108f0b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0108ef3:	84 c0                	test   %al,%al
f0108ef5:	0f 84 9f 03 00 00    	je     f010929a <vprintfmt+0x3b5>
				return;
			putch(ch, putdat);
f0108efb:	8b 55 0c             	mov    0xc(%ebp),%edx
f0108efe:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108f02:	0f b6 c0             	movzbl %al,%eax
f0108f05:	89 04 24             	mov    %eax,(%esp)
f0108f08:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0108f0b:	0f b6 03             	movzbl (%ebx),%eax
f0108f0e:	83 c3 01             	add    $0x1,%ebx
f0108f11:	3c 25                	cmp    $0x25,%al
f0108f13:	75 de                	jne    f0108ef3 <vprintfmt+0xe>
f0108f15:	b9 00 00 00 00       	mov    $0x0,%ecx
f0108f1a:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
f0108f21:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0108f26:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0108f2d:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
f0108f31:	eb 07                	jmp    f0108f3a <vprintfmt+0x55>
f0108f33:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0108f3a:	0f b6 13             	movzbl (%ebx),%edx
f0108f3d:	83 c3 01             	add    $0x1,%ebx
f0108f40:	8d 42 dd             	lea    -0x23(%edx),%eax
f0108f43:	3c 55                	cmp    $0x55,%al
f0108f45:	0f 87 22 03 00 00    	ja     f010926d <vprintfmt+0x388>
f0108f4b:	0f b6 c0             	movzbl %al,%eax
f0108f4e:	ff 24 85 e0 3b 11 f0 	jmp    *-0xfeec420(,%eax,4)
f0108f55:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
f0108f59:	eb df                	jmp    f0108f3a <vprintfmt+0x55>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0108f5b:	0f b6 c2             	movzbl %dl,%eax
f0108f5e:	8d 78 d0             	lea    -0x30(%eax),%edi
				ch = *fmt;
f0108f61:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f0108f64:	8d 42 d0             	lea    -0x30(%edx),%eax
f0108f67:	83 f8 09             	cmp    $0x9,%eax
f0108f6a:	76 08                	jbe    f0108f74 <vprintfmt+0x8f>
f0108f6c:	eb 39                	jmp    f0108fa7 <vprintfmt+0xc2>
f0108f6e:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
f0108f72:	eb c6                	jmp    f0108f3a <vprintfmt+0x55>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0108f74:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f0108f77:	8d 04 bf             	lea    (%edi,%edi,4),%eax
f0108f7a:	8d 7c 42 d0          	lea    -0x30(%edx,%eax,2),%edi
				ch = *fmt;
f0108f7e:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f0108f81:	8d 42 d0             	lea    -0x30(%edx),%eax
f0108f84:	83 f8 09             	cmp    $0x9,%eax
f0108f87:	77 1e                	ja     f0108fa7 <vprintfmt+0xc2>
f0108f89:	eb e9                	jmp    f0108f74 <vprintfmt+0x8f>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0108f8b:	8b 55 14             	mov    0x14(%ebp),%edx
f0108f8e:	8d 42 04             	lea    0x4(%edx),%eax
f0108f91:	89 45 14             	mov    %eax,0x14(%ebp)
f0108f94:	8b 3a                	mov    (%edx),%edi
f0108f96:	eb 0f                	jmp    f0108fa7 <vprintfmt+0xc2>
			goto process_precision;

		case '.':
			if (width < 0)
f0108f98:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0108f9c:	79 9c                	jns    f0108f3a <vprintfmt+0x55>
f0108f9e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0108fa5:	eb 93                	jmp    f0108f3a <vprintfmt+0x55>
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0108fa7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0108fab:	90                   	nop    
f0108fac:	8d 74 26 00          	lea    0x0(%esi),%esi
f0108fb0:	79 88                	jns    f0108f3a <vprintfmt+0x55>
f0108fb2:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0108fb5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0108fba:	e9 7b ff ff ff       	jmp    f0108f3a <vprintfmt+0x55>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0108fbf:	83 c1 01             	add    $0x1,%ecx
f0108fc2:	e9 73 ff ff ff       	jmp    f0108f3a <vprintfmt+0x55>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0108fc7:	8b 45 14             	mov    0x14(%ebp),%eax
f0108fca:	8d 50 04             	lea    0x4(%eax),%edx
f0108fcd:	89 55 14             	mov    %edx,0x14(%ebp)
f0108fd0:	8b 55 0c             	mov    0xc(%ebp),%edx
f0108fd3:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108fd7:	8b 00                	mov    (%eax),%eax
f0108fd9:	89 04 24             	mov    %eax,(%esp)
f0108fdc:	ff 55 08             	call   *0x8(%ebp)
f0108fdf:	e9 27 ff ff ff       	jmp    f0108f0b <vprintfmt+0x26>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0108fe4:	8b 55 14             	mov    0x14(%ebp),%edx
f0108fe7:	8d 42 04             	lea    0x4(%edx),%eax
f0108fea:	89 45 14             	mov    %eax,0x14(%ebp)
f0108fed:	8b 02                	mov    (%edx),%eax
f0108fef:	89 c2                	mov    %eax,%edx
f0108ff1:	c1 fa 1f             	sar    $0x1f,%edx
f0108ff4:	31 d0                	xor    %edx,%eax
f0108ff6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0108ff8:	83 f8 0f             	cmp    $0xf,%eax
f0108ffb:	7f 0b                	jg     f0109008 <vprintfmt+0x123>
f0108ffd:	8b 14 85 40 3d 11 f0 	mov    -0xfeec2c0(,%eax,4),%edx
f0109004:	85 d2                	test   %edx,%edx
f0109006:	75 23                	jne    f010902b <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f0109008:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010900c:	c7 44 24 08 b7 3a 11 	movl   $0xf0113ab7,0x8(%esp)
f0109013:	f0 
f0109014:	8b 45 0c             	mov    0xc(%ebp),%eax
f0109017:	89 44 24 04          	mov    %eax,0x4(%esp)
f010901b:	8b 55 08             	mov    0x8(%ebp),%edx
f010901e:	89 14 24             	mov    %edx,(%esp)
f0109021:	e8 ff 02 00 00       	call   f0109325 <printfmt>
f0109026:	e9 e0 fe ff ff       	jmp    f0108f0b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f010902b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010902f:	c7 44 24 08 5e ae 10 	movl   $0xf010ae5e,0x8(%esp)
f0109036:	f0 
f0109037:	8b 45 0c             	mov    0xc(%ebp),%eax
f010903a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010903e:	8b 55 08             	mov    0x8(%ebp),%edx
f0109041:	89 14 24             	mov    %edx,(%esp)
f0109044:	e8 dc 02 00 00       	call   f0109325 <printfmt>
f0109049:	e9 bd fe ff ff       	jmp    f0108f0b <vprintfmt+0x26>
f010904e:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0109051:	89 f9                	mov    %edi,%ecx
f0109053:	89 5d ec             	mov    %ebx,-0x14(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0109056:	8b 55 14             	mov    0x14(%ebp),%edx
f0109059:	8d 42 04             	lea    0x4(%edx),%eax
f010905c:	89 45 14             	mov    %eax,0x14(%ebp)
f010905f:	8b 12                	mov    (%edx),%edx
f0109061:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0109064:	85 d2                	test   %edx,%edx
f0109066:	75 07                	jne    f010906f <vprintfmt+0x18a>
f0109068:	c7 45 dc c0 3a 11 f0 	movl   $0xf0113ac0,-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f010906f:	85 f6                	test   %esi,%esi
f0109071:	7e 41                	jle    f01090b4 <vprintfmt+0x1cf>
f0109073:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
f0109077:	74 3b                	je     f01090b4 <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
f0109079:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010907d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0109080:	89 04 24             	mov    %eax,(%esp)
f0109083:	e8 c8 03 00 00       	call   f0109450 <strnlen>
f0109088:	29 c6                	sub    %eax,%esi
f010908a:	89 75 f0             	mov    %esi,-0x10(%ebp)
f010908d:	85 f6                	test   %esi,%esi
f010908f:	7e 23                	jle    f01090b4 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0109091:	0f be 55 eb          	movsbl -0x15(%ebp),%edx
f0109095:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0109098:	8b 45 0c             	mov    0xc(%ebp),%eax
f010909b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010909f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01090a2:	89 14 24             	mov    %edx,(%esp)
f01090a5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01090a8:	83 ee 01             	sub    $0x1,%esi
f01090ab:	75 eb                	jne    f0109098 <vprintfmt+0x1b3>
f01090ad:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01090b4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01090b7:	0f b6 02             	movzbl (%edx),%eax
f01090ba:	0f be d0             	movsbl %al,%edx
f01090bd:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01090c0:	84 c0                	test   %al,%al
f01090c2:	75 42                	jne    f0109106 <vprintfmt+0x221>
f01090c4:	eb 49                	jmp    f010910f <vprintfmt+0x22a>
				if (altflag && (ch < ' ' || ch > '~'))
f01090c6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01090ca:	74 1b                	je     f01090e7 <vprintfmt+0x202>
f01090cc:	8d 42 e0             	lea    -0x20(%edx),%eax
f01090cf:	83 f8 5e             	cmp    $0x5e,%eax
f01090d2:	76 13                	jbe    f01090e7 <vprintfmt+0x202>
					putch('?', putdat);
f01090d4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01090d7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01090db:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01090e2:	ff 55 08             	call   *0x8(%ebp)
f01090e5:	eb 0d                	jmp    f01090f4 <vprintfmt+0x20f>
				else
					putch(ch, putdat);
f01090e7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01090ea:	89 44 24 04          	mov    %eax,0x4(%esp)
f01090ee:	89 14 24             	mov    %edx,(%esp)
f01090f1:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01090f4:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
f01090f8:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f01090fc:	83 c6 01             	add    $0x1,%esi
f01090ff:	84 c0                	test   %al,%al
f0109101:	74 0c                	je     f010910f <vprintfmt+0x22a>
f0109103:	0f be d0             	movsbl %al,%edx
f0109106:	85 ff                	test   %edi,%edi
f0109108:	78 bc                	js     f01090c6 <vprintfmt+0x1e1>
f010910a:	83 ef 01             	sub    $0x1,%edi
f010910d:	79 b7                	jns    f01090c6 <vprintfmt+0x1e1>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010910f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0109113:	0f 8e f2 fd ff ff    	jle    f0108f0b <vprintfmt+0x26>
				putch(' ', putdat);
f0109119:	8b 55 0c             	mov    0xc(%ebp),%edx
f010911c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0109120:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0109127:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010912a:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
f010912e:	75 e9                	jne    f0109119 <vprintfmt+0x234>
f0109130:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0109133:	e9 d3 fd ff ff       	jmp    f0108f0b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0109138:	83 f9 01             	cmp    $0x1,%ecx
f010913b:	90                   	nop    
f010913c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0109140:	7e 10                	jle    f0109152 <vprintfmt+0x26d>
		return va_arg(*ap, long long);
f0109142:	8b 55 14             	mov    0x14(%ebp),%edx
f0109145:	8d 42 08             	lea    0x8(%edx),%eax
f0109148:	89 45 14             	mov    %eax,0x14(%ebp)
f010914b:	8b 32                	mov    (%edx),%esi
f010914d:	8b 7a 04             	mov    0x4(%edx),%edi
f0109150:	eb 2a                	jmp    f010917c <vprintfmt+0x297>
	else if (lflag)
f0109152:	85 c9                	test   %ecx,%ecx
f0109154:	74 14                	je     f010916a <vprintfmt+0x285>
		return va_arg(*ap, long);
f0109156:	8b 45 14             	mov    0x14(%ebp),%eax
f0109159:	8d 50 04             	lea    0x4(%eax),%edx
f010915c:	89 55 14             	mov    %edx,0x14(%ebp)
f010915f:	8b 00                	mov    (%eax),%eax
f0109161:	89 c6                	mov    %eax,%esi
f0109163:	89 c7                	mov    %eax,%edi
f0109165:	c1 ff 1f             	sar    $0x1f,%edi
f0109168:	eb 12                	jmp    f010917c <vprintfmt+0x297>
	else
		return va_arg(*ap, int);
f010916a:	8b 45 14             	mov    0x14(%ebp),%eax
f010916d:	8d 50 04             	lea    0x4(%eax),%edx
f0109170:	89 55 14             	mov    %edx,0x14(%ebp)
f0109173:	8b 00                	mov    (%eax),%eax
f0109175:	89 c6                	mov    %eax,%esi
f0109177:	89 c7                	mov    %eax,%edi
f0109179:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010917c:	89 f2                	mov    %esi,%edx
f010917e:	89 f9                	mov    %edi,%ecx
f0109180:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
			if ((long long) num < 0) {
f0109187:	85 ff                	test   %edi,%edi
f0109189:	0f 89 9b 00 00 00    	jns    f010922a <vprintfmt+0x345>
				putch('-', putdat);
f010918f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0109192:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109196:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010919d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01091a0:	89 f2                	mov    %esi,%edx
f01091a2:	89 f9                	mov    %edi,%ecx
f01091a4:	f7 da                	neg    %edx
f01091a6:	83 d1 00             	adc    $0x0,%ecx
f01091a9:	f7 d9                	neg    %ecx
f01091ab:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
f01091b2:	eb 76                	jmp    f010922a <vprintfmt+0x345>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01091b4:	89 ca                	mov    %ecx,%edx
f01091b6:	8d 45 14             	lea    0x14(%ebp),%eax
f01091b9:	e8 cd fc ff ff       	call   f0108e8b <getuint>
f01091be:	89 d1                	mov    %edx,%ecx
f01091c0:	89 c2                	mov    %eax,%edx
f01091c2:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
f01091c9:	eb 5f                	jmp    f010922a <vprintfmt+0x345>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap,lflag);
f01091cb:	89 ca                	mov    %ecx,%edx
f01091cd:	8d 45 14             	lea    0x14(%ebp),%eax
f01091d0:	e8 b6 fc ff ff       	call   f0108e8b <getuint>
f01091d5:	e9 31 fd ff ff       	jmp    f0108f0b <vprintfmt+0x26>
			base=8;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f01091da:	8b 55 0c             	mov    0xc(%ebp),%edx
f01091dd:	89 54 24 04          	mov    %edx,0x4(%esp)
f01091e1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01091e8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01091eb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01091ee:	89 44 24 04          	mov    %eax,0x4(%esp)
f01091f2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01091f9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f01091fc:	8b 55 14             	mov    0x14(%ebp),%edx
f01091ff:	8d 42 04             	lea    0x4(%edx),%eax
f0109202:	89 45 14             	mov    %eax,0x14(%ebp)
f0109205:	8b 12                	mov    (%edx),%edx
f0109207:	b9 00 00 00 00       	mov    $0x0,%ecx
f010920c:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
f0109213:	eb 15                	jmp    f010922a <vprintfmt+0x345>
			base = 16;
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0109215:	89 ca                	mov    %ecx,%edx
f0109217:	8d 45 14             	lea    0x14(%ebp),%eax
f010921a:	e8 6c fc ff ff       	call   f0108e8b <getuint>
f010921f:	89 d1                	mov    %edx,%ecx
f0109221:	89 c2                	mov    %eax,%edx
f0109223:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f010922a:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
f010922e:	89 44 24 10          	mov    %eax,0x10(%esp)
f0109232:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0109235:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0109239:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010923c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0109240:	89 14 24             	mov    %edx,(%esp)
f0109243:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0109247:	8b 55 0c             	mov    0xc(%ebp),%edx
f010924a:	8b 45 08             	mov    0x8(%ebp),%eax
f010924d:	e8 4e fb ff ff       	call   f0108da0 <printnum>
f0109252:	e9 b4 fc ff ff       	jmp    f0108f0b <vprintfmt+0x26>
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0109257:	8b 55 0c             	mov    0xc(%ebp),%edx
f010925a:	89 54 24 04          	mov    %edx,0x4(%esp)
f010925e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0109265:	ff 55 08             	call   *0x8(%ebp)
f0109268:	e9 9e fc ff ff       	jmp    f0108f0b <vprintfmt+0x26>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010926d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0109270:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109274:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f010927b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010927e:	83 eb 01             	sub    $0x1,%ebx
f0109281:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0109285:	0f 84 80 fc ff ff    	je     f0108f0b <vprintfmt+0x26>
f010928b:	83 eb 01             	sub    $0x1,%ebx
f010928e:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0109292:	0f 84 73 fc ff ff    	je     f0108f0b <vprintfmt+0x26>
f0109298:	eb f1                	jmp    f010928b <vprintfmt+0x3a6>
				/* do nothing */;
			break;
		}
	}
}
f010929a:	83 c4 3c             	add    $0x3c,%esp
f010929d:	5b                   	pop    %ebx
f010929e:	5e                   	pop    %esi
f010929f:	5f                   	pop    %edi
f01092a0:	5d                   	pop    %ebp
f01092a1:	c3                   	ret    

f01092a2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01092a2:	55                   	push   %ebp
f01092a3:	89 e5                	mov    %esp,%ebp
f01092a5:	83 ec 28             	sub    $0x28,%esp
f01092a8:	8b 55 08             	mov    0x8(%ebp),%edx
f01092ab:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f01092ae:	85 d2                	test   %edx,%edx
f01092b0:	74 04                	je     f01092b6 <vsnprintf+0x14>
f01092b2:	85 c0                	test   %eax,%eax
f01092b4:	7f 07                	jg     f01092bd <vsnprintf+0x1b>
f01092b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01092bb:	eb 3b                	jmp    f01092f8 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f01092bd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f01092c4:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
f01092c8:	89 45 f8             	mov    %eax,-0x8(%ebp)
f01092cb:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01092ce:	8b 45 14             	mov    0x14(%ebp),%eax
f01092d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01092d5:	8b 45 10             	mov    0x10(%ebp),%eax
f01092d8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01092dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01092df:	89 44 24 04          	mov    %eax,0x4(%esp)
f01092e3:	c7 04 24 c7 8e 10 f0 	movl   $0xf0108ec7,(%esp)
f01092ea:	e8 f6 fb ff ff       	call   f0108ee5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01092ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01092f2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01092f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f01092f8:	c9                   	leave  
f01092f9:	c3                   	ret    

f01092fa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01092fa:	55                   	push   %ebp
f01092fb:	89 e5                	mov    %esp,%ebp
f01092fd:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0109300:	8d 45 14             	lea    0x14(%ebp),%eax
f0109303:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
f0109306:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010930a:	8b 45 10             	mov    0x10(%ebp),%eax
f010930d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0109311:	8b 45 0c             	mov    0xc(%ebp),%eax
f0109314:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109318:	8b 45 08             	mov    0x8(%ebp),%eax
f010931b:	89 04 24             	mov    %eax,(%esp)
f010931e:	e8 7f ff ff ff       	call   f01092a2 <vsnprintf>
	va_end(ap);

	return rc;
}
f0109323:	c9                   	leave  
f0109324:	c3                   	ret    

f0109325 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0109325:	55                   	push   %ebp
f0109326:	89 e5                	mov    %esp,%ebp
f0109328:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
f010932b:	8d 45 14             	lea    0x14(%ebp),%eax
f010932e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
f0109331:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0109335:	8b 45 10             	mov    0x10(%ebp),%eax
f0109338:	89 44 24 08          	mov    %eax,0x8(%esp)
f010933c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010933f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109343:	8b 45 08             	mov    0x8(%ebp),%eax
f0109346:	89 04 24             	mov    %eax,(%esp)
f0109349:	e8 97 fb ff ff       	call   f0108ee5 <vprintfmt>
	va_end(ap);
}
f010934e:	c9                   	leave  
f010934f:	c3                   	ret    

f0109350 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0109350:	55                   	push   %ebp
f0109351:	89 e5                	mov    %esp,%ebp
f0109353:	57                   	push   %edi
f0109354:	56                   	push   %esi
f0109355:	53                   	push   %ebx
f0109356:	83 ec 0c             	sub    $0xc,%esp
f0109359:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010935c:	85 c0                	test   %eax,%eax
f010935e:	74 10                	je     f0109370 <readline+0x20>
		cprintf("%s", prompt);
f0109360:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109364:	c7 04 24 5e ae 10 f0 	movl   $0xf010ae5e,(%esp)
f010936b:	e8 67 a6 ff ff       	call   f01039d7 <cprintf>

	i = 0;
	echoing = iscons(0);
f0109370:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0109377:	e8 e9 6e ff ff       	call   f0100265 <iscons>
f010937c:	89 c7                	mov    %eax,%edi
f010937e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0109383:	e8 cc 6e ff ff       	call   f0100254 <getchar>
f0109388:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010938a:	85 c0                	test   %eax,%eax
f010938c:	79 17                	jns    f01093a5 <readline+0x55>
			cprintf("read error: %e\n", c);
f010938e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109392:	c7 04 24 a0 3d 11 f0 	movl   $0xf0113da0,(%esp)
f0109399:	e8 39 a6 ff ff       	call   f01039d7 <cprintf>
f010939e:	b8 00 00 00 00       	mov    $0x0,%eax
f01093a3:	eb 76                	jmp    f010941b <readline+0xcb>
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01093a5:	83 f8 08             	cmp    $0x8,%eax
f01093a8:	74 08                	je     f01093b2 <readline+0x62>
f01093aa:	83 f8 7f             	cmp    $0x7f,%eax
f01093ad:	8d 76 00             	lea    0x0(%esi),%esi
f01093b0:	75 19                	jne    f01093cb <readline+0x7b>
f01093b2:	85 f6                	test   %esi,%esi
f01093b4:	7e 15                	jle    f01093cb <readline+0x7b>
			if (echoing)
f01093b6:	85 ff                	test   %edi,%edi
f01093b8:	74 0c                	je     f01093c6 <readline+0x76>
				cputchar('\b');
f01093ba:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01093c1:	e8 94 70 ff ff       	call   f010045a <cputchar>
			i--;
f01093c6:	83 ee 01             	sub    $0x1,%esi
f01093c9:	eb b8                	jmp    f0109383 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01093cb:	83 fb 1f             	cmp    $0x1f,%ebx
f01093ce:	66 90                	xchg   %ax,%ax
f01093d0:	7e 23                	jle    f01093f5 <readline+0xa5>
f01093d2:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01093d8:	7f 1b                	jg     f01093f5 <readline+0xa5>
			if (echoing)
f01093da:	85 ff                	test   %edi,%edi
f01093dc:	8d 74 26 00          	lea    0x0(%esi),%esi
f01093e0:	74 08                	je     f01093ea <readline+0x9a>
				cputchar(c);
f01093e2:	89 1c 24             	mov    %ebx,(%esp)
f01093e5:	e8 70 70 ff ff       	call   f010045a <cputchar>
			buf[i++] = c;
f01093ea:	88 9e 60 a1 1b f0    	mov    %bl,-0xfe45ea0(%esi)
f01093f0:	83 c6 01             	add    $0x1,%esi
f01093f3:	eb 8e                	jmp    f0109383 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01093f5:	83 fb 0a             	cmp    $0xa,%ebx
f01093f8:	74 05                	je     f01093ff <readline+0xaf>
f01093fa:	83 fb 0d             	cmp    $0xd,%ebx
f01093fd:	75 84                	jne    f0109383 <readline+0x33>
			if (echoing)
f01093ff:	85 ff                	test   %edi,%edi
f0109401:	74 0c                	je     f010940f <readline+0xbf>
				cputchar('\n');
f0109403:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f010940a:	e8 4b 70 ff ff       	call   f010045a <cputchar>
			buf[i] = 0;
f010940f:	c6 86 60 a1 1b f0 00 	movb   $0x0,-0xfe45ea0(%esi)
f0109416:	b8 60 a1 1b f0       	mov    $0xf01ba160,%eax
			return buf;
		}
	}
}
f010941b:	83 c4 0c             	add    $0xc,%esp
f010941e:	5b                   	pop    %ebx
f010941f:	5e                   	pop    %esi
f0109420:	5f                   	pop    %edi
f0109421:	5d                   	pop    %ebp
f0109422:	c3                   	ret    
	...

f0109430 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0109430:	55                   	push   %ebp
f0109431:	89 e5                	mov    %esp,%ebp
f0109433:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0109436:	b8 00 00 00 00       	mov    $0x0,%eax
f010943b:	80 3a 00             	cmpb   $0x0,(%edx)
f010943e:	74 0e                	je     f010944e <strlen+0x1e>
f0109440:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0109445:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0109448:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
f010944c:	75 f7                	jne    f0109445 <strlen+0x15>
		n++;
	return n;
}
f010944e:	5d                   	pop    %ebp
f010944f:	c3                   	ret    

f0109450 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0109450:	55                   	push   %ebp
f0109451:	89 e5                	mov    %esp,%ebp
f0109453:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0109456:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0109459:	85 d2                	test   %edx,%edx
f010945b:	74 19                	je     f0109476 <strnlen+0x26>
f010945d:	80 39 00             	cmpb   $0x0,(%ecx)
f0109460:	74 14                	je     f0109476 <strnlen+0x26>
f0109462:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0109467:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010946a:	39 d0                	cmp    %edx,%eax
f010946c:	74 0d                	je     f010947b <strnlen+0x2b>
f010946e:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
f0109472:	74 07                	je     f010947b <strnlen+0x2b>
f0109474:	eb f1                	jmp    f0109467 <strnlen+0x17>
f0109476:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f010947b:	5d                   	pop    %ebp
f010947c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0109480:	c3                   	ret    

f0109481 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0109481:	55                   	push   %ebp
f0109482:	89 e5                	mov    %esp,%ebp
f0109484:	53                   	push   %ebx
f0109485:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0109488:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010948b:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010948d:	0f b6 01             	movzbl (%ecx),%eax
f0109490:	88 02                	mov    %al,(%edx)
f0109492:	83 c2 01             	add    $0x1,%edx
f0109495:	83 c1 01             	add    $0x1,%ecx
f0109498:	84 c0                	test   %al,%al
f010949a:	75 f1                	jne    f010948d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010949c:	89 d8                	mov    %ebx,%eax
f010949e:	5b                   	pop    %ebx
f010949f:	5d                   	pop    %ebp
f01094a0:	c3                   	ret    

f01094a1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01094a1:	55                   	push   %ebp
f01094a2:	89 e5                	mov    %esp,%ebp
f01094a4:	57                   	push   %edi
f01094a5:	56                   	push   %esi
f01094a6:	53                   	push   %ebx
f01094a7:	8b 7d 08             	mov    0x8(%ebp),%edi
f01094aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01094ad:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01094b0:	85 f6                	test   %esi,%esi
f01094b2:	74 1c                	je     f01094d0 <strncpy+0x2f>
f01094b4:	89 fa                	mov    %edi,%edx
f01094b6:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
f01094bb:	0f b6 01             	movzbl (%ecx),%eax
f01094be:	88 02                	mov    %al,(%edx)
f01094c0:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01094c3:	80 39 01             	cmpb   $0x1,(%ecx)
f01094c6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01094c9:	83 c3 01             	add    $0x1,%ebx
f01094cc:	39 f3                	cmp    %esi,%ebx
f01094ce:	75 eb                	jne    f01094bb <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01094d0:	89 f8                	mov    %edi,%eax
f01094d2:	5b                   	pop    %ebx
f01094d3:	5e                   	pop    %esi
f01094d4:	5f                   	pop    %edi
f01094d5:	5d                   	pop    %ebp
f01094d6:	c3                   	ret    

f01094d7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01094d7:	55                   	push   %ebp
f01094d8:	89 e5                	mov    %esp,%ebp
f01094da:	56                   	push   %esi
f01094db:	53                   	push   %ebx
f01094dc:	8b 75 08             	mov    0x8(%ebp),%esi
f01094df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01094e2:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01094e5:	89 f0                	mov    %esi,%eax
f01094e7:	85 d2                	test   %edx,%edx
f01094e9:	74 2c                	je     f0109517 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f01094eb:	89 d3                	mov    %edx,%ebx
f01094ed:	83 eb 01             	sub    $0x1,%ebx
f01094f0:	74 20                	je     f0109512 <strlcpy+0x3b>
f01094f2:	0f b6 11             	movzbl (%ecx),%edx
f01094f5:	84 d2                	test   %dl,%dl
f01094f7:	74 19                	je     f0109512 <strlcpy+0x3b>
f01094f9:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
f01094fb:	88 10                	mov    %dl,(%eax)
f01094fd:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0109500:	83 eb 01             	sub    $0x1,%ebx
f0109503:	74 0f                	je     f0109514 <strlcpy+0x3d>
f0109505:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
f0109509:	83 c1 01             	add    $0x1,%ecx
f010950c:	84 d2                	test   %dl,%dl
f010950e:	74 04                	je     f0109514 <strlcpy+0x3d>
f0109510:	eb e9                	jmp    f01094fb <strlcpy+0x24>
f0109512:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0109514:	c6 00 00             	movb   $0x0,(%eax)
f0109517:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0109519:	5b                   	pop    %ebx
f010951a:	5e                   	pop    %esi
f010951b:	5d                   	pop    %ebp
f010951c:	c3                   	ret    

f010951d <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
f010951d:	55                   	push   %ebp
f010951e:	89 e5                	mov    %esp,%ebp
f0109520:	56                   	push   %esi
f0109521:	53                   	push   %ebx
f0109522:	8b 75 08             	mov    0x8(%ebp),%esi
f0109525:	8b 45 0c             	mov    0xc(%ebp),%eax
f0109528:	8b 55 10             	mov    0x10(%ebp),%edx
    int c;
    char *q = buf;

    if (buf_size <= 0)
f010952b:	85 c0                	test   %eax,%eax
f010952d:	7e 2e                	jle    f010955d <pstrcpy+0x40>
        return;

    for(;;) {
        c = *str++;
f010952f:	0f b6 0a             	movzbl (%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
f0109532:	84 c9                	test   %cl,%cl
f0109534:	74 22                	je     f0109558 <pstrcpy+0x3b>
f0109536:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
f010953a:	89 f0                	mov    %esi,%eax
f010953c:	39 de                	cmp    %ebx,%esi
f010953e:	72 09                	jb     f0109549 <pstrcpy+0x2c>
f0109540:	eb 16                	jmp    f0109558 <pstrcpy+0x3b>
f0109542:	83 c2 01             	add    $0x1,%edx
f0109545:	39 d8                	cmp    %ebx,%eax
f0109547:	73 11                	jae    f010955a <pstrcpy+0x3d>
            break;
        *q++ = c;
f0109549:	88 08                	mov    %cl,(%eax)
f010954b:	83 c0 01             	add    $0x1,%eax

    if (buf_size <= 0)
        return;

    for(;;) {
        c = *str++;
f010954e:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
f0109552:	84 c9                	test   %cl,%cl
f0109554:	75 ec                	jne    f0109542 <pstrcpy+0x25>
f0109556:	eb 02                	jmp    f010955a <pstrcpy+0x3d>
f0109558:	89 f0                	mov    %esi,%eax
            break;
        *q++ = c;
    }
    *q = '\0';
f010955a:	c6 00 00             	movb   $0x0,(%eax)
}
f010955d:	5b                   	pop    %ebx
f010955e:	5e                   	pop    %esi
f010955f:	5d                   	pop    %ebp
f0109560:	c3                   	ret    

f0109561 <strcmp>:
int
strcmp(const char *p, const char *q)
{
f0109561:	55                   	push   %ebp
f0109562:	89 e5                	mov    %esp,%ebp
f0109564:	8b 55 08             	mov    0x8(%ebp),%edx
f0109567:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
f010956a:	0f b6 02             	movzbl (%edx),%eax
f010956d:	84 c0                	test   %al,%al
f010956f:	74 16                	je     f0109587 <strcmp+0x26>
f0109571:	3a 01                	cmp    (%ecx),%al
f0109573:	75 12                	jne    f0109587 <strcmp+0x26>
		p++, q++;
f0109575:	83 c1 01             	add    $0x1,%ecx
    *q = '\0';
}
int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0109578:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f010957c:	84 c0                	test   %al,%al
f010957e:	74 07                	je     f0109587 <strcmp+0x26>
f0109580:	83 c2 01             	add    $0x1,%edx
f0109583:	3a 01                	cmp    (%ecx),%al
f0109585:	74 ee                	je     f0109575 <strcmp+0x14>
f0109587:	0f b6 c0             	movzbl %al,%eax
f010958a:	0f b6 11             	movzbl (%ecx),%edx
f010958d:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010958f:	5d                   	pop    %ebp
f0109590:	c3                   	ret    

f0109591 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0109591:	55                   	push   %ebp
f0109592:	89 e5                	mov    %esp,%ebp
f0109594:	53                   	push   %ebx
f0109595:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0109598:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010959b:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f010959e:	85 d2                	test   %edx,%edx
f01095a0:	74 2d                	je     f01095cf <strncmp+0x3e>
f01095a2:	0f b6 01             	movzbl (%ecx),%eax
f01095a5:	84 c0                	test   %al,%al
f01095a7:	74 1a                	je     f01095c3 <strncmp+0x32>
f01095a9:	3a 03                	cmp    (%ebx),%al
f01095ab:	75 16                	jne    f01095c3 <strncmp+0x32>
f01095ad:	83 ea 01             	sub    $0x1,%edx
f01095b0:	74 1d                	je     f01095cf <strncmp+0x3e>
		n--, p++, q++;
f01095b2:	83 c1 01             	add    $0x1,%ecx
f01095b5:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01095b8:	0f b6 01             	movzbl (%ecx),%eax
f01095bb:	84 c0                	test   %al,%al
f01095bd:	74 04                	je     f01095c3 <strncmp+0x32>
f01095bf:	3a 03                	cmp    (%ebx),%al
f01095c1:	74 ea                	je     f01095ad <strncmp+0x1c>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01095c3:	0f b6 11             	movzbl (%ecx),%edx
f01095c6:	0f b6 03             	movzbl (%ebx),%eax
f01095c9:	29 c2                	sub    %eax,%edx
f01095cb:	89 d0                	mov    %edx,%eax
f01095cd:	eb 05                	jmp    f01095d4 <strncmp+0x43>
f01095cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01095d4:	5b                   	pop    %ebx
f01095d5:	5d                   	pop    %ebp
f01095d6:	c3                   	ret    

f01095d7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01095d7:	55                   	push   %ebp
f01095d8:	89 e5                	mov    %esp,%ebp
f01095da:	8b 45 08             	mov    0x8(%ebp),%eax
f01095dd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01095e1:	0f b6 10             	movzbl (%eax),%edx
f01095e4:	84 d2                	test   %dl,%dl
f01095e6:	74 14                	je     f01095fc <strchr+0x25>
		if (*s == c)
f01095e8:	38 ca                	cmp    %cl,%dl
f01095ea:	75 06                	jne    f01095f2 <strchr+0x1b>
f01095ec:	eb 13                	jmp    f0109601 <strchr+0x2a>
f01095ee:	38 ca                	cmp    %cl,%dl
f01095f0:	74 0f                	je     f0109601 <strchr+0x2a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01095f2:	83 c0 01             	add    $0x1,%eax
f01095f5:	0f b6 10             	movzbl (%eax),%edx
f01095f8:	84 d2                	test   %dl,%dl
f01095fa:	75 f2                	jne    f01095ee <strchr+0x17>
f01095fc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0109601:	5d                   	pop    %ebp
f0109602:	c3                   	ret    

f0109603 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0109603:	55                   	push   %ebp
f0109604:	89 e5                	mov    %esp,%ebp
f0109606:	8b 45 08             	mov    0x8(%ebp),%eax
f0109609:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010960d:	0f b6 10             	movzbl (%eax),%edx
f0109610:	84 d2                	test   %dl,%dl
f0109612:	74 18                	je     f010962c <strfind+0x29>
		if (*s == c)
f0109614:	38 ca                	cmp    %cl,%dl
f0109616:	75 0a                	jne    f0109622 <strfind+0x1f>
f0109618:	eb 12                	jmp    f010962c <strfind+0x29>
f010961a:	38 ca                	cmp    %cl,%dl
f010961c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0109620:	74 0a                	je     f010962c <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0109622:	83 c0 01             	add    $0x1,%eax
f0109625:	0f b6 10             	movzbl (%eax),%edx
f0109628:	84 d2                	test   %dl,%dl
f010962a:	75 ee                	jne    f010961a <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f010962c:	5d                   	pop    %ebp
f010962d:	c3                   	ret    

f010962e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010962e:	55                   	push   %ebp
f010962f:	89 e5                	mov    %esp,%ebp
f0109631:	83 ec 08             	sub    $0x8,%esp
f0109634:	89 1c 24             	mov    %ebx,(%esp)
f0109637:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010963b:	8b 7d 08             	mov    0x8(%ebp),%edi
f010963e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
f0109641:	85 db                	test   %ebx,%ebx
f0109643:	74 36                	je     f010967b <memset+0x4d>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0109645:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010964b:	75 26                	jne    f0109673 <memset+0x45>
f010964d:	f6 c3 03             	test   $0x3,%bl
f0109650:	75 21                	jne    f0109673 <memset+0x45>
		c &= 0xFF;
f0109652:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0109656:	89 d0                	mov    %edx,%eax
f0109658:	c1 e0 18             	shl    $0x18,%eax
f010965b:	89 d1                	mov    %edx,%ecx
f010965d:	c1 e1 10             	shl    $0x10,%ecx
f0109660:	09 c8                	or     %ecx,%eax
f0109662:	09 d0                	or     %edx,%eax
f0109664:	c1 e2 08             	shl    $0x8,%edx
f0109667:	09 d0                	or     %edx,%eax
f0109669:	89 d9                	mov    %ebx,%ecx
f010966b:	c1 e9 02             	shr    $0x2,%ecx
f010966e:	fc                   	cld    
f010966f:	f3 ab                	rep stos %eax,%es:(%edi)
f0109671:	eb 08                	jmp    f010967b <memset+0x4d>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0109673:	8b 45 0c             	mov    0xc(%ebp),%eax
f0109676:	89 d9                	mov    %ebx,%ecx
f0109678:	fc                   	cld    
f0109679:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010967b:	89 f8                	mov    %edi,%eax
f010967d:	8b 1c 24             	mov    (%esp),%ebx
f0109680:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0109684:	89 ec                	mov    %ebp,%esp
f0109686:	5d                   	pop    %ebp
f0109687:	c3                   	ret    

f0109688 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0109688:	55                   	push   %ebp
f0109689:	89 e5                	mov    %esp,%ebp
f010968b:	83 ec 08             	sub    $0x8,%esp
f010968e:	89 34 24             	mov    %esi,(%esp)
f0109691:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0109695:	8b 45 08             	mov    0x8(%ebp),%eax
f0109698:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
f010969b:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f010969e:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f01096a0:	39 c6                	cmp    %eax,%esi
f01096a2:	73 38                	jae    f01096dc <memmove+0x54>
f01096a4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01096a7:	39 d0                	cmp    %edx,%eax
f01096a9:	73 31                	jae    f01096dc <memmove+0x54>
		s += n;
		d += n;
f01096ab:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01096ae:	f6 c2 03             	test   $0x3,%dl
f01096b1:	75 1d                	jne    f01096d0 <memmove+0x48>
f01096b3:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01096b9:	75 15                	jne    f01096d0 <memmove+0x48>
f01096bb:	f6 c1 03             	test   $0x3,%cl
f01096be:	66 90                	xchg   %ax,%ax
f01096c0:	75 0e                	jne    f01096d0 <memmove+0x48>
			asm volatile("std; rep movsl\n"
f01096c2:	8d 7e fc             	lea    -0x4(%esi),%edi
f01096c5:	8d 72 fc             	lea    -0x4(%edx),%esi
f01096c8:	c1 e9 02             	shr    $0x2,%ecx
f01096cb:	fd                   	std    
f01096cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01096ce:	eb 09                	jmp    f01096d9 <memmove+0x51>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01096d0:	8d 7e ff             	lea    -0x1(%esi),%edi
f01096d3:	8d 72 ff             	lea    -0x1(%edx),%esi
f01096d6:	fd                   	std    
f01096d7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01096d9:	fc                   	cld    
f01096da:	eb 21                	jmp    f01096fd <memmove+0x75>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01096dc:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01096e2:	75 16                	jne    f01096fa <memmove+0x72>
f01096e4:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01096ea:	75 0e                	jne    f01096fa <memmove+0x72>
f01096ec:	f6 c1 03             	test   $0x3,%cl
f01096ef:	90                   	nop    
f01096f0:	75 08                	jne    f01096fa <memmove+0x72>
			asm volatile("cld; rep movsl\n"
f01096f2:	c1 e9 02             	shr    $0x2,%ecx
f01096f5:	fc                   	cld    
f01096f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01096f8:	eb 03                	jmp    f01096fd <memmove+0x75>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01096fa:	fc                   	cld    
f01096fb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01096fd:	8b 34 24             	mov    (%esp),%esi
f0109700:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0109704:	89 ec                	mov    %ebp,%esp
f0109706:	5d                   	pop    %ebp
f0109707:	c3                   	ret    

f0109708 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0109708:	55                   	push   %ebp
f0109709:	89 e5                	mov    %esp,%ebp
f010970b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010970e:	8b 45 10             	mov    0x10(%ebp),%eax
f0109711:	89 44 24 08          	mov    %eax,0x8(%esp)
f0109715:	8b 45 0c             	mov    0xc(%ebp),%eax
f0109718:	89 44 24 04          	mov    %eax,0x4(%esp)
f010971c:	8b 45 08             	mov    0x8(%ebp),%eax
f010971f:	89 04 24             	mov    %eax,(%esp)
f0109722:	e8 61 ff ff ff       	call   f0109688 <memmove>
}
f0109727:	c9                   	leave  
f0109728:	c3                   	ret    

f0109729 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0109729:	55                   	push   %ebp
f010972a:	89 e5                	mov    %esp,%ebp
f010972c:	57                   	push   %edi
f010972d:	56                   	push   %esi
f010972e:	53                   	push   %ebx
f010972f:	83 ec 04             	sub    $0x4,%esp
f0109732:	8b 45 08             	mov    0x8(%ebp),%eax
f0109735:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0109738:	8b 55 10             	mov    0x10(%ebp),%edx
f010973b:	83 ea 01             	sub    $0x1,%edx
f010973e:	83 fa ff             	cmp    $0xffffffff,%edx
f0109741:	74 47                	je     f010978a <memcmp+0x61>
		if (*s1 != *s2)
f0109743:	0f b6 30             	movzbl (%eax),%esi
f0109746:	0f b6 39             	movzbl (%ecx),%edi
			return (int) *s1 - (int) *s2;
f0109749:	89 45 f0             	mov    %eax,-0x10(%ebp)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
f010974c:	89 f0                	mov    %esi,%eax
f010974e:	89 fb                	mov    %edi,%ebx
f0109750:	38 d8                	cmp    %bl,%al
f0109752:	74 2e                	je     f0109782 <memcmp+0x59>
f0109754:	eb 1c                	jmp    f0109772 <memcmp+0x49>
f0109756:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0109759:	0f b6 70 01          	movzbl 0x1(%eax),%esi
f010975d:	0f b6 79 01          	movzbl 0x1(%ecx),%edi
f0109761:	83 c0 01             	add    $0x1,%eax
f0109764:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0109767:	83 c1 01             	add    $0x1,%ecx
f010976a:	89 f3                	mov    %esi,%ebx
f010976c:	89 f8                	mov    %edi,%eax
f010976e:	38 c3                	cmp    %al,%bl
f0109770:	74 10                	je     f0109782 <memcmp+0x59>
			return (int) *s1 - (int) *s2;
f0109772:	89 f1                	mov    %esi,%ecx
f0109774:	0f b6 d1             	movzbl %cl,%edx
f0109777:	89 fb                	mov    %edi,%ebx
f0109779:	0f b6 c3             	movzbl %bl,%eax
f010977c:	29 c2                	sub    %eax,%edx
f010977e:	89 d0                	mov    %edx,%eax
f0109780:	eb 0d                	jmp    f010978f <memcmp+0x66>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0109782:	83 ea 01             	sub    $0x1,%edx
f0109785:	83 fa ff             	cmp    $0xffffffff,%edx
f0109788:	75 cc                	jne    f0109756 <memcmp+0x2d>
f010978a:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f010978f:	83 c4 04             	add    $0x4,%esp
f0109792:	5b                   	pop    %ebx
f0109793:	5e                   	pop    %esi
f0109794:	5f                   	pop    %edi
f0109795:	5d                   	pop    %ebp
f0109796:	c3                   	ret    

f0109797 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0109797:	55                   	push   %ebp
f0109798:	89 e5                	mov    %esp,%ebp
f010979a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010979d:	89 c1                	mov    %eax,%ecx
f010979f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
f01097a2:	39 c8                	cmp    %ecx,%eax
f01097a4:	73 15                	jae    f01097bb <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f01097a6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
f01097aa:	38 10                	cmp    %dl,(%eax)
f01097ac:	75 06                	jne    f01097b4 <memfind+0x1d>
f01097ae:	eb 0b                	jmp    f01097bb <memfind+0x24>
f01097b0:	38 10                	cmp    %dl,(%eax)
f01097b2:	74 07                	je     f01097bb <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01097b4:	83 c0 01             	add    $0x1,%eax
f01097b7:	39 c8                	cmp    %ecx,%eax
f01097b9:	75 f5                	jne    f01097b0 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01097bb:	5d                   	pop    %ebp
f01097bc:	8d 74 26 00          	lea    0x0(%esi),%esi
f01097c0:	c3                   	ret    

f01097c1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01097c1:	55                   	push   %ebp
f01097c2:	89 e5                	mov    %esp,%ebp
f01097c4:	57                   	push   %edi
f01097c5:	56                   	push   %esi
f01097c6:	53                   	push   %ebx
f01097c7:	83 ec 04             	sub    $0x4,%esp
f01097ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01097cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01097d0:	0f b6 01             	movzbl (%ecx),%eax
f01097d3:	3c 20                	cmp    $0x20,%al
f01097d5:	74 04                	je     f01097db <strtol+0x1a>
f01097d7:	3c 09                	cmp    $0x9,%al
f01097d9:	75 0e                	jne    f01097e9 <strtol+0x28>
		s++;
f01097db:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01097de:	0f b6 01             	movzbl (%ecx),%eax
f01097e1:	3c 20                	cmp    $0x20,%al
f01097e3:	74 f6                	je     f01097db <strtol+0x1a>
f01097e5:	3c 09                	cmp    $0x9,%al
f01097e7:	74 f2                	je     f01097db <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f01097e9:	3c 2b                	cmp    $0x2b,%al
f01097eb:	75 0c                	jne    f01097f9 <strtol+0x38>
		s++;
f01097ed:	83 c1 01             	add    $0x1,%ecx
f01097f0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01097f7:	eb 15                	jmp    f010980e <strtol+0x4d>
	else if (*s == '-')
f01097f9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0109800:	3c 2d                	cmp    $0x2d,%al
f0109802:	75 0a                	jne    f010980e <strtol+0x4d>
		s++, neg = 1;
f0109804:	83 c1 01             	add    $0x1,%ecx
f0109807:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010980e:	85 f6                	test   %esi,%esi
f0109810:	0f 94 c0             	sete   %al
f0109813:	74 05                	je     f010981a <strtol+0x59>
f0109815:	83 fe 10             	cmp    $0x10,%esi
f0109818:	75 18                	jne    f0109832 <strtol+0x71>
f010981a:	80 39 30             	cmpb   $0x30,(%ecx)
f010981d:	75 13                	jne    f0109832 <strtol+0x71>
f010981f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0109823:	75 0d                	jne    f0109832 <strtol+0x71>
		s += 2, base = 16;
f0109825:	83 c1 02             	add    $0x2,%ecx
f0109828:	be 10 00 00 00       	mov    $0x10,%esi
f010982d:	8d 76 00             	lea    0x0(%esi),%esi
f0109830:	eb 1b                	jmp    f010984d <strtol+0x8c>
	else if (base == 0 && s[0] == '0')
f0109832:	85 f6                	test   %esi,%esi
f0109834:	75 0e                	jne    f0109844 <strtol+0x83>
f0109836:	80 39 30             	cmpb   $0x30,(%ecx)
f0109839:	75 09                	jne    f0109844 <strtol+0x83>
		s++, base = 8;
f010983b:	83 c1 01             	add    $0x1,%ecx
f010983e:	66 be 08 00          	mov    $0x8,%si
f0109842:	eb 09                	jmp    f010984d <strtol+0x8c>
	else if (base == 0)
f0109844:	84 c0                	test   %al,%al
f0109846:	74 05                	je     f010984d <strtol+0x8c>
f0109848:	be 0a 00 00 00       	mov    $0xa,%esi
f010984d:	bf 00 00 00 00       	mov    $0x0,%edi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0109852:	0f b6 11             	movzbl (%ecx),%edx
f0109855:	89 d3                	mov    %edx,%ebx
f0109857:	8d 42 d0             	lea    -0x30(%edx),%eax
f010985a:	3c 09                	cmp    $0x9,%al
f010985c:	77 08                	ja     f0109866 <strtol+0xa5>
			dig = *s - '0';
f010985e:	0f be c2             	movsbl %dl,%eax
f0109861:	8d 50 d0             	lea    -0x30(%eax),%edx
f0109864:	eb 1c                	jmp    f0109882 <strtol+0xc1>
		else if (*s >= 'a' && *s <= 'z')
f0109866:	8d 43 9f             	lea    -0x61(%ebx),%eax
f0109869:	3c 19                	cmp    $0x19,%al
f010986b:	77 08                	ja     f0109875 <strtol+0xb4>
			dig = *s - 'a' + 10;
f010986d:	0f be c2             	movsbl %dl,%eax
f0109870:	8d 50 a9             	lea    -0x57(%eax),%edx
f0109873:	eb 0d                	jmp    f0109882 <strtol+0xc1>
		else if (*s >= 'A' && *s <= 'Z')
f0109875:	8d 43 bf             	lea    -0x41(%ebx),%eax
f0109878:	3c 19                	cmp    $0x19,%al
f010987a:	77 17                	ja     f0109893 <strtol+0xd2>
			dig = *s - 'A' + 10;
f010987c:	0f be c2             	movsbl %dl,%eax
f010987f:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
f0109882:	39 f2                	cmp    %esi,%edx
f0109884:	7d 0d                	jge    f0109893 <strtol+0xd2>
			break;
		s++, val = (val * base) + dig;
f0109886:	83 c1 01             	add    $0x1,%ecx
f0109889:	89 f8                	mov    %edi,%eax
f010988b:	0f af c6             	imul   %esi,%eax
f010988e:	8d 3c 02             	lea    (%edx,%eax,1),%edi
f0109891:	eb bf                	jmp    f0109852 <strtol+0x91>
		// we don't properly detect overflow!
	}
f0109893:	89 f8                	mov    %edi,%eax

	if (endptr)
f0109895:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0109899:	74 05                	je     f01098a0 <strtol+0xdf>
		*endptr = (char *) s;
f010989b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010989e:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
f01098a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f01098a4:	74 04                	je     f01098aa <strtol+0xe9>
f01098a6:	89 c7                	mov    %eax,%edi
f01098a8:	f7 df                	neg    %edi
}
f01098aa:	89 f8                	mov    %edi,%eax
f01098ac:	83 c4 04             	add    $0x4,%esp
f01098af:	5b                   	pop    %ebx
f01098b0:	5e                   	pop    %esi
f01098b1:	5f                   	pop    %edi
f01098b2:	5d                   	pop    %ebp
f01098b3:	c3                   	ret    
	...

f01098c0 <__divdi3>:
f01098c0:	55                   	push   %ebp
f01098c1:	89 e5                	mov    %esp,%ebp
f01098c3:	57                   	push   %edi
f01098c4:	56                   	push   %esi
f01098c5:	83 ec 28             	sub    $0x28,%esp
f01098c8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01098cb:	8b 45 08             	mov    0x8(%ebp),%eax
f01098ce:	8b 75 10             	mov    0x10(%ebp),%esi
f01098d1:	8b 7d 14             	mov    0x14(%ebp),%edi
f01098d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01098d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01098da:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01098dd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01098e4:	89 f0                	mov    %esi,%eax
f01098e6:	89 fa                	mov    %edi,%edx
f01098e8:	85 c9                	test   %ecx,%ecx
f01098ea:	0f 88 a2 00 00 00    	js     f0109992 <__divdi3+0xd2>
f01098f0:	85 ff                	test   %edi,%edi
f01098f2:	0f 88 b8 00 00 00    	js     f01099b0 <__divdi3+0xf0>
f01098f8:	89 d7                	mov    %edx,%edi
f01098fa:	89 c6                	mov    %eax,%esi
f01098fc:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01098ff:	89 c1                	mov    %eax,%ecx
f0109901:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0109904:	85 ff                	test   %edi,%edi
f0109906:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0109909:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010990c:	75 12                	jne    f0109920 <__divdi3+0x60>
f010990e:	39 c6                	cmp    %eax,%esi
f0109910:	76 3e                	jbe    f0109950 <__divdi3+0x90>
f0109912:	89 d0                	mov    %edx,%eax
f0109914:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0109917:	f7 f6                	div    %esi
f0109919:	31 f6                	xor    %esi,%esi
f010991b:	89 c1                	mov    %eax,%ecx
f010991d:	eb 11                	jmp    f0109930 <__divdi3+0x70>
f010991f:	90                   	nop    
f0109920:	3b 7d ec             	cmp    -0x14(%ebp),%edi
f0109923:	76 4c                	jbe    f0109971 <__divdi3+0xb1>
f0109925:	31 c9                	xor    %ecx,%ecx
f0109927:	31 f6                	xor    %esi,%esi
f0109929:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
f0109930:	89 c8                	mov    %ecx,%eax
f0109932:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0109935:	89 f2                	mov    %esi,%edx
f0109937:	85 c9                	test   %ecx,%ecx
f0109939:	74 07                	je     f0109942 <__divdi3+0x82>
f010993b:	f7 d8                	neg    %eax
f010993d:	83 d2 00             	adc    $0x0,%edx
f0109940:	f7 da                	neg    %edx
f0109942:	83 c4 28             	add    $0x28,%esp
f0109945:	5e                   	pop    %esi
f0109946:	5f                   	pop    %edi
f0109947:	5d                   	pop    %ebp
f0109948:	c3                   	ret    
f0109949:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
f0109950:	85 f6                	test   %esi,%esi
f0109952:	75 0b                	jne    f010995f <__divdi3+0x9f>
f0109954:	b8 01 00 00 00       	mov    $0x1,%eax
f0109959:	31 d2                	xor    %edx,%edx
f010995b:	f7 f6                	div    %esi
f010995d:	89 c1                	mov    %eax,%ecx
f010995f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0109962:	89 fa                	mov    %edi,%edx
f0109964:	f7 f1                	div    %ecx
f0109966:	89 c6                	mov    %eax,%esi
f0109968:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010996b:	f7 f1                	div    %ecx
f010996d:	89 c1                	mov    %eax,%ecx
f010996f:	eb bf                	jmp    f0109930 <__divdi3+0x70>
f0109971:	0f bd c7             	bsr    %edi,%eax
f0109974:	83 f0 1f             	xor    $0x1f,%eax
f0109977:	89 45 e8             	mov    %eax,-0x18(%ebp)
f010997a:	75 47                	jne    f01099c3 <__divdi3+0x103>
f010997c:	39 7d ec             	cmp    %edi,-0x14(%ebp)
f010997f:	77 05                	ja     f0109986 <__divdi3+0xc6>
f0109981:	39 75 f0             	cmp    %esi,-0x10(%ebp)
f0109984:	72 9f                	jb     f0109925 <__divdi3+0x65>
f0109986:	b9 01 00 00 00       	mov    $0x1,%ecx
f010998b:	31 f6                	xor    %esi,%esi
f010998d:	8d 76 00             	lea    0x0(%esi),%esi
f0109990:	eb 9e                	jmp    f0109930 <__divdi3+0x70>
f0109992:	f7 5d d8             	negl   -0x28(%ebp)
f0109995:	83 55 dc 00          	adcl   $0x0,-0x24(%ebp)
f0109999:	f7 5d dc             	negl   -0x24(%ebp)
f010999c:	85 ff                	test   %edi,%edi
f010999e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01099a5:	0f 89 4d ff ff ff    	jns    f01098f8 <__divdi3+0x38>
f01099ab:	90                   	nop    
f01099ac:	8d 74 26 00          	lea    0x0(%esi),%esi
f01099b0:	89 f0                	mov    %esi,%eax
f01099b2:	89 fa                	mov    %edi,%edx
f01099b4:	f7 d8                	neg    %eax
f01099b6:	83 d2 00             	adc    $0x0,%edx
f01099b9:	f7 da                	neg    %edx
f01099bb:	f7 55 e4             	notl   -0x1c(%ebp)
f01099be:	e9 35 ff ff ff       	jmp    f01098f8 <__divdi3+0x38>
f01099c3:	b8 20 00 00 00       	mov    $0x20,%eax
f01099c8:	89 f2                	mov    %esi,%edx
f01099ca:	2b 45 e8             	sub    -0x18(%ebp),%eax
f01099cd:	89 c1                	mov    %eax,%ecx
f01099cf:	d3 ea                	shr    %cl,%edx
f01099d1:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
f01099d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01099d8:	89 f8                	mov    %edi,%eax
f01099da:	89 d7                	mov    %edx,%edi
f01099dc:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01099df:	d3 e0                	shl    %cl,%eax
f01099e1:	09 c7                	or     %eax,%edi
f01099e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01099e6:	d3 e6                	shl    %cl,%esi
f01099e8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01099ec:	d3 e8                	shr    %cl,%eax
f01099ee:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
f01099f2:	d3 e2                	shl    %cl,%edx
f01099f4:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01099f8:	09 d0                	or     %edx,%eax
f01099fa:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01099fd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0109a00:	d3 ea                	shr    %cl,%edx
f0109a02:	f7 f7                	div    %edi
f0109a04:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0109a07:	89 c7                	mov    %eax,%edi
f0109a09:	f7 e6                	mul    %esi
f0109a0b:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0109a0e:	89 c6                	mov    %eax,%esi
f0109a10:	72 1b                	jb     f0109a2d <__divdi3+0x16d>
f0109a12:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0109a15:	74 09                	je     f0109a20 <__divdi3+0x160>
f0109a17:	89 f9                	mov    %edi,%ecx
f0109a19:	31 f6                	xor    %esi,%esi
f0109a1b:	e9 10 ff ff ff       	jmp    f0109930 <__divdi3+0x70>
f0109a20:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0109a23:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
f0109a27:	d3 e0                	shl    %cl,%eax
f0109a29:	39 c6                	cmp    %eax,%esi
f0109a2b:	76 ea                	jbe    f0109a17 <__divdi3+0x157>
f0109a2d:	8d 4f ff             	lea    -0x1(%edi),%ecx
f0109a30:	31 f6                	xor    %esi,%esi
f0109a32:	e9 f9 fe ff ff       	jmp    f0109930 <__divdi3+0x70>
	...

f0109a40 <__moddi3>:
f0109a40:	55                   	push   %ebp
f0109a41:	89 e5                	mov    %esp,%ebp
f0109a43:	57                   	push   %edi
f0109a44:	56                   	push   %esi
f0109a45:	83 ec 58             	sub    $0x58,%esp
f0109a48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0109a4b:	8b 55 14             	mov    0x14(%ebp),%edx
f0109a4e:	8b 45 10             	mov    0x10(%ebp),%eax
f0109a51:	c7 45 b0 00 00 00 00 	movl   $0x0,-0x50(%ebp)
f0109a58:	85 c9                	test   %ecx,%ecx
f0109a5a:	89 55 ac             	mov    %edx,-0x54(%ebp)
f0109a5d:	8b 55 08             	mov    0x8(%ebp),%edx
f0109a60:	89 45 a8             	mov    %eax,-0x58(%ebp)
f0109a63:	8b 7d ac             	mov    -0x54(%ebp),%edi
f0109a66:	c7 45 b4 00 00 00 00 	movl   $0x0,-0x4c(%ebp)
f0109a6d:	8b 75 a8             	mov    -0x58(%ebp),%esi
f0109a70:	c7 45 bc 00 00 00 00 	movl   $0x0,-0x44(%ebp)
f0109a77:	0f 88 f3 00 00 00    	js     f0109b70 <__moddi3+0x130>
f0109a7d:	8b 45 ac             	mov    -0x54(%ebp),%eax
f0109a80:	85 c0                	test   %eax,%eax
f0109a82:	0f 88 cf 00 00 00    	js     f0109b57 <__moddi3+0x117>
f0109a88:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0109a8b:	85 ff                	test   %edi,%edi
f0109a8d:	89 75 d8             	mov    %esi,-0x28(%ebp)
f0109a90:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0109a93:	89 ce                	mov    %ecx,%esi
f0109a95:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0109a98:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0109a9b:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0109a9e:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0109aa1:	75 2d                	jne    f0109ad0 <__moddi3+0x90>
f0109aa3:	39 4d d8             	cmp    %ecx,-0x28(%ebp)
f0109aa6:	0f 86 85 00 00 00    	jbe    f0109b31 <__moddi3+0xf1>
f0109aac:	89 d0                	mov    %edx,%eax
f0109aae:	89 ca                	mov    %ecx,%edx
f0109ab0:	f7 75 d8             	divl   -0x28(%ebp)
f0109ab3:	89 55 b0             	mov    %edx,-0x50(%ebp)
f0109ab6:	c7 45 b4 00 00 00 00 	movl   $0x0,-0x4c(%ebp)
f0109abd:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0109ac0:	8b 55 b0             	mov    -0x50(%ebp),%edx
f0109ac3:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f0109ac6:	89 16                	mov    %edx,(%esi)
f0109ac8:	89 4e 04             	mov    %ecx,0x4(%esi)
f0109acb:	eb 19                	jmp    f0109ae6 <__moddi3+0xa6>
f0109acd:	8d 76 00             	lea    0x0(%esi),%esi
f0109ad0:	39 cf                	cmp    %ecx,%edi
f0109ad2:	76 30                	jbe    f0109b04 <__moddi3+0xc4>
f0109ad4:	89 55 b0             	mov    %edx,-0x50(%ebp)
f0109ad7:	8b 45 b0             	mov    -0x50(%ebp),%eax
f0109ada:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
f0109add:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0109ae0:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0109ae3:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0109ae6:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0109ae9:	85 c0                	test   %eax,%eax
f0109aeb:	74 0a                	je     f0109af7 <__moddi3+0xb7>
f0109aed:	f7 5d f0             	negl   -0x10(%ebp)
f0109af0:	83 55 f4 00          	adcl   $0x0,-0xc(%ebp)
f0109af4:	f7 5d f4             	negl   -0xc(%ebp)
f0109af7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0109afa:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0109afd:	83 c4 58             	add    $0x58,%esp
f0109b00:	5e                   	pop    %esi
f0109b01:	5f                   	pop    %edi
f0109b02:	5d                   	pop    %ebp
f0109b03:	c3                   	ret    
f0109b04:	0f bd c7             	bsr    %edi,%eax
f0109b07:	83 f0 1f             	xor    $0x1f,%eax
f0109b0a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0109b0d:	75 74                	jne    f0109b83 <__moddi3+0x143>
f0109b0f:	39 f9                	cmp    %edi,%ecx
f0109b11:	0f 87 07 01 00 00    	ja     f0109c1e <__moddi3+0x1de>
f0109b17:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0109b1a:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0109b1d:	0f 83 fb 00 00 00    	jae    f0109c1e <__moddi3+0x1de>
f0109b23:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0109b26:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0109b29:	89 75 b0             	mov    %esi,-0x50(%ebp)
f0109b2c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
f0109b2f:	eb 8c                	jmp    f0109abd <__moddi3+0x7d>
f0109b31:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0109b34:	85 d2                	test   %edx,%edx
f0109b36:	75 0d                	jne    f0109b45 <__moddi3+0x105>
f0109b38:	b8 01 00 00 00       	mov    $0x1,%eax
f0109b3d:	31 d2                	xor    %edx,%edx
f0109b3f:	f7 75 d8             	divl   -0x28(%ebp)
f0109b42:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0109b45:	89 f0                	mov    %esi,%eax
f0109b47:	89 fa                	mov    %edi,%edx
f0109b49:	f7 75 cc             	divl   -0x34(%ebp)
f0109b4c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0109b4f:	f7 75 cc             	divl   -0x34(%ebp)
f0109b52:	e9 5c ff ff ff       	jmp    f0109ab3 <__moddi3+0x73>
f0109b57:	8b 75 a8             	mov    -0x58(%ebp),%esi
f0109b5a:	8b 7d ac             	mov    -0x54(%ebp),%edi
f0109b5d:	f7 de                	neg    %esi
f0109b5f:	83 d7 00             	adc    $0x0,%edi
f0109b62:	f7 df                	neg    %edi
f0109b64:	e9 1f ff ff ff       	jmp    f0109a88 <__moddi3+0x48>
f0109b69:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
f0109b70:	f7 da                	neg    %edx
f0109b72:	83 d1 00             	adc    $0x0,%ecx
f0109b75:	f7 d9                	neg    %ecx
f0109b77:	c7 45 bc ff ff ff ff 	movl   $0xffffffff,-0x44(%ebp)
f0109b7e:	e9 fa fe ff ff       	jmp    f0109a7d <__moddi3+0x3d>
f0109b83:	b8 20 00 00 00       	mov    $0x20,%eax
f0109b88:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0109b8b:	2b 45 c4             	sub    -0x3c(%ebp),%eax
f0109b8e:	89 c1                	mov    %eax,%ecx
f0109b90:	d3 ea                	shr    %cl,%edx
f0109b92:	0f b6 4d c4          	movzbl -0x3c(%ebp),%ecx
f0109b96:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0109b99:	89 f8                	mov    %edi,%eax
f0109b9b:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0109b9e:	d3 e0                	shl    %cl,%eax
f0109ba0:	09 c2                	or     %eax,%edx
f0109ba2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0109ba5:	d3 e7                	shl    %cl,%edi
f0109ba7:	0f b6 4d d0          	movzbl -0x30(%ebp),%ecx
f0109bab:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0109bae:	89 f2                	mov    %esi,%edx
f0109bb0:	d3 e8                	shr    %cl,%eax
f0109bb2:	0f b6 4d c4          	movzbl -0x3c(%ebp),%ecx
f0109bb6:	d3 e2                	shl    %cl,%edx
f0109bb8:	09 d0                	or     %edx,%eax
f0109bba:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0109bbd:	d3 e2                	shl    %cl,%edx
f0109bbf:	0f b6 4d d0          	movzbl -0x30(%ebp),%ecx
f0109bc3:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0109bc6:	89 f2                	mov    %esi,%edx
f0109bc8:	d3 ea                	shr    %cl,%edx
f0109bca:	f7 75 e4             	divl   -0x1c(%ebp)
f0109bcd:	89 55 a4             	mov    %edx,-0x5c(%ebp)
f0109bd0:	f7 e7                	mul    %edi
f0109bd2:	39 55 a4             	cmp    %edx,-0x5c(%ebp)
f0109bd5:	72 5f                	jb     f0109c36 <__moddi3+0x1f6>
f0109bd7:	3b 55 a4             	cmp    -0x5c(%ebp),%edx
f0109bda:	74 55                	je     f0109c31 <__moddi3+0x1f1>
f0109bdc:	8d 74 26 00          	lea    0x0(%esi),%esi
f0109be0:	8b 75 a4             	mov    -0x5c(%ebp),%esi
f0109be3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0109be6:	29 c1                	sub    %eax,%ecx
f0109be8:	19 d6                	sbb    %edx,%esi
f0109bea:	89 ca                	mov    %ecx,%edx
f0109bec:	0f b6 4d c4          	movzbl -0x3c(%ebp),%ecx
f0109bf0:	89 f0                	mov    %esi,%eax
f0109bf2:	89 75 a4             	mov    %esi,-0x5c(%ebp)
f0109bf5:	d3 ea                	shr    %cl,%edx
f0109bf7:	0f b6 4d d0          	movzbl -0x30(%ebp),%ecx
f0109bfb:	d3 e0                	shl    %cl,%eax
f0109bfd:	0f b6 4d c4          	movzbl -0x3c(%ebp),%ecx
f0109c01:	09 c2                	or     %eax,%edx
f0109c03:	89 55 b0             	mov    %edx,-0x50(%ebp)
f0109c06:	8b 45 b0             	mov    -0x50(%ebp),%eax
f0109c09:	d3 ee                	shr    %cl,%esi
f0109c0b:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0109c0e:	89 75 b4             	mov    %esi,-0x4c(%ebp)
f0109c11:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0109c14:	89 01                	mov    %eax,(%ecx)
f0109c16:	89 51 04             	mov    %edx,0x4(%ecx)
f0109c19:	e9 c8 fe ff ff       	jmp    f0109ae6 <__moddi3+0xa6>
f0109c1e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0109c21:	2b 4d d8             	sub    -0x28(%ebp),%ecx
f0109c24:	19 fe                	sbb    %edi,%esi
f0109c26:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0109c29:	89 75 c8             	mov    %esi,-0x38(%ebp)
f0109c2c:	e9 f2 fe ff ff       	jmp    f0109b23 <__moddi3+0xe3>
f0109c31:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0109c34:	76 aa                	jbe    f0109be0 <__moddi3+0x1a0>
f0109c36:	29 f8                	sub    %edi,%eax
f0109c38:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
f0109c3b:	eb a3                	jmp    f0109be0 <__moddi3+0x1a0>
f0109c3d:	00 00                	add    %al,(%eax)
	...

f0109c40 <__udivdi3>:
f0109c40:	55                   	push   %ebp
f0109c41:	89 e5                	mov    %esp,%ebp
f0109c43:	57                   	push   %edi
f0109c44:	56                   	push   %esi
f0109c45:	83 ec 18             	sub    $0x18,%esp
f0109c48:	8b 45 10             	mov    0x10(%ebp),%eax
f0109c4b:	8b 55 14             	mov    0x14(%ebp),%edx
f0109c4e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0109c51:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0109c54:	89 c1                	mov    %eax,%ecx
f0109c56:	8b 45 08             	mov    0x8(%ebp),%eax
f0109c59:	85 d2                	test   %edx,%edx
f0109c5b:	89 d7                	mov    %edx,%edi
f0109c5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0109c60:	75 1e                	jne    f0109c80 <__udivdi3+0x40>
f0109c62:	39 f1                	cmp    %esi,%ecx
f0109c64:	0f 86 8d 00 00 00    	jbe    f0109cf7 <__udivdi3+0xb7>
f0109c6a:	89 f2                	mov    %esi,%edx
f0109c6c:	31 f6                	xor    %esi,%esi
f0109c6e:	f7 f1                	div    %ecx
f0109c70:	89 c1                	mov    %eax,%ecx
f0109c72:	89 c8                	mov    %ecx,%eax
f0109c74:	89 f2                	mov    %esi,%edx
f0109c76:	83 c4 18             	add    $0x18,%esp
f0109c79:	5e                   	pop    %esi
f0109c7a:	5f                   	pop    %edi
f0109c7b:	5d                   	pop    %ebp
f0109c7c:	c3                   	ret    
f0109c7d:	8d 76 00             	lea    0x0(%esi),%esi
f0109c80:	39 f2                	cmp    %esi,%edx
f0109c82:	0f 87 a8 00 00 00    	ja     f0109d30 <__udivdi3+0xf0>
f0109c88:	0f bd c2             	bsr    %edx,%eax
f0109c8b:	83 f0 1f             	xor    $0x1f,%eax
f0109c8e:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0109c91:	0f 84 89 00 00 00    	je     f0109d20 <__udivdi3+0xe0>
f0109c97:	b8 20 00 00 00       	mov    $0x20,%eax
f0109c9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0109c9f:	2b 45 e8             	sub    -0x18(%ebp),%eax
f0109ca2:	89 c1                	mov    %eax,%ecx
f0109ca4:	d3 ea                	shr    %cl,%edx
f0109ca6:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
f0109caa:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0109cad:	89 f8                	mov    %edi,%eax
f0109caf:	8b 7d f4             	mov    -0xc(%ebp),%edi
f0109cb2:	d3 e0                	shl    %cl,%eax
f0109cb4:	09 c2                	or     %eax,%edx
f0109cb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0109cb9:	d3 e7                	shl    %cl,%edi
f0109cbb:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0109cbf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0109cc2:	89 f2                	mov    %esi,%edx
f0109cc4:	d3 e8                	shr    %cl,%eax
f0109cc6:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
f0109cca:	d3 e2                	shl    %cl,%edx
f0109ccc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0109cd0:	09 d0                	or     %edx,%eax
f0109cd2:	d3 ee                	shr    %cl,%esi
f0109cd4:	89 f2                	mov    %esi,%edx
f0109cd6:	f7 75 e4             	divl   -0x1c(%ebp)
f0109cd9:	89 d1                	mov    %edx,%ecx
f0109cdb:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0109cde:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0109ce1:	f7 e7                	mul    %edi
f0109ce3:	39 d1                	cmp    %edx,%ecx
f0109ce5:	89 c6                	mov    %eax,%esi
f0109ce7:	72 70                	jb     f0109d59 <__udivdi3+0x119>
f0109ce9:	39 ca                	cmp    %ecx,%edx
f0109ceb:	74 5f                	je     f0109d4c <__udivdi3+0x10c>
f0109ced:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0109cf0:	31 f6                	xor    %esi,%esi
f0109cf2:	e9 7b ff ff ff       	jmp    f0109c72 <__udivdi3+0x32>
f0109cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0109cfa:	85 c0                	test   %eax,%eax
f0109cfc:	75 0c                	jne    f0109d0a <__udivdi3+0xca>
f0109cfe:	b8 01 00 00 00       	mov    $0x1,%eax
f0109d03:	31 d2                	xor    %edx,%edx
f0109d05:	f7 75 f4             	divl   -0xc(%ebp)
f0109d08:	89 c1                	mov    %eax,%ecx
f0109d0a:	89 f0                	mov    %esi,%eax
f0109d0c:	89 fa                	mov    %edi,%edx
f0109d0e:	f7 f1                	div    %ecx
f0109d10:	89 c6                	mov    %eax,%esi
f0109d12:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0109d15:	f7 f1                	div    %ecx
f0109d17:	89 c1                	mov    %eax,%ecx
f0109d19:	e9 54 ff ff ff       	jmp    f0109c72 <__udivdi3+0x32>
f0109d1e:	66 90                	xchg   %ax,%ax
f0109d20:	39 d6                	cmp    %edx,%esi
f0109d22:	77 1c                	ja     f0109d40 <__udivdi3+0x100>
f0109d24:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0109d27:	39 55 ec             	cmp    %edx,-0x14(%ebp)
f0109d2a:	73 14                	jae    f0109d40 <__udivdi3+0x100>
f0109d2c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0109d30:	31 c9                	xor    %ecx,%ecx
f0109d32:	31 f6                	xor    %esi,%esi
f0109d34:	e9 39 ff ff ff       	jmp    f0109c72 <__udivdi3+0x32>
f0109d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
f0109d40:	b9 01 00 00 00       	mov    $0x1,%ecx
f0109d45:	31 f6                	xor    %esi,%esi
f0109d47:	e9 26 ff ff ff       	jmp    f0109c72 <__udivdi3+0x32>
f0109d4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0109d4f:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
f0109d53:	d3 e0                	shl    %cl,%eax
f0109d55:	39 c6                	cmp    %eax,%esi
f0109d57:	76 94                	jbe    f0109ced <__udivdi3+0xad>
f0109d59:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0109d5c:	31 f6                	xor    %esi,%esi
f0109d5e:	83 e9 01             	sub    $0x1,%ecx
f0109d61:	e9 0c ff ff ff       	jmp    f0109c72 <__udivdi3+0x32>
	...

f0109d70 <__umoddi3>:
f0109d70:	55                   	push   %ebp
f0109d71:	89 e5                	mov    %esp,%ebp
f0109d73:	57                   	push   %edi
f0109d74:	56                   	push   %esi
f0109d75:	83 ec 30             	sub    $0x30,%esp
f0109d78:	8b 45 10             	mov    0x10(%ebp),%eax
f0109d7b:	8b 55 14             	mov    0x14(%ebp),%edx
f0109d7e:	8b 75 08             	mov    0x8(%ebp),%esi
f0109d81:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0109d84:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0109d87:	89 c1                	mov    %eax,%ecx
f0109d89:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0109d8c:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0109d8f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f0109d96:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0109d9d:	89 fa                	mov    %edi,%edx
f0109d9f:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0109da2:	85 c0                	test   %eax,%eax
f0109da4:	89 75 f0             	mov    %esi,-0x10(%ebp)
f0109da7:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0109daa:	75 14                	jne    f0109dc0 <__umoddi3+0x50>
f0109dac:	39 f9                	cmp    %edi,%ecx
f0109dae:	76 60                	jbe    f0109e10 <__umoddi3+0xa0>
f0109db0:	89 f0                	mov    %esi,%eax
f0109db2:	f7 f1                	div    %ecx
f0109db4:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0109db7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0109dbe:	eb 10                	jmp    f0109dd0 <__umoddi3+0x60>
f0109dc0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0109dc3:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
f0109dc6:	76 18                	jbe    f0109de0 <__umoddi3+0x70>
f0109dc8:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0109dcb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0109dce:	66 90                	xchg   %ax,%ax
f0109dd0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0109dd3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0109dd6:	83 c4 30             	add    $0x30,%esp
f0109dd9:	5e                   	pop    %esi
f0109dda:	5f                   	pop    %edi
f0109ddb:	5d                   	pop    %ebp
f0109ddc:	c3                   	ret    
f0109ddd:	8d 76 00             	lea    0x0(%esi),%esi
f0109de0:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
f0109de4:	83 f0 1f             	xor    $0x1f,%eax
f0109de7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0109dea:	75 46                	jne    f0109e32 <__umoddi3+0xc2>
f0109dec:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0109def:	39 45 e0             	cmp    %eax,-0x20(%ebp)
f0109df2:	0f 87 c9 00 00 00    	ja     f0109ec1 <__umoddi3+0x151>
f0109df8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0109dfb:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
f0109dfe:	0f 83 bd 00 00 00    	jae    f0109ec1 <__umoddi3+0x151>
f0109e04:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0109e07:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0109e0a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0109e0d:	eb c1                	jmp    f0109dd0 <__umoddi3+0x60>
f0109e0f:	90                   	nop    
f0109e10:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0109e13:	85 c0                	test   %eax,%eax
f0109e15:	75 0c                	jne    f0109e23 <__umoddi3+0xb3>
f0109e17:	b8 01 00 00 00       	mov    $0x1,%eax
f0109e1c:	31 d2                	xor    %edx,%edx
f0109e1e:	f7 75 ec             	divl   -0x14(%ebp)
f0109e21:	89 c1                	mov    %eax,%ecx
f0109e23:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0109e26:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0109e29:	f7 f1                	div    %ecx
f0109e2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0109e2e:	f7 f1                	div    %ecx
f0109e30:	eb 82                	jmp    f0109db4 <__umoddi3+0x44>
f0109e32:	b8 20 00 00 00       	mov    $0x20,%eax
f0109e37:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0109e3a:	2b 45 d8             	sub    -0x28(%ebp),%eax
f0109e3d:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0109e40:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0109e43:	89 c1                	mov    %eax,%ecx
f0109e45:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0109e48:	d3 ea                	shr    %cl,%edx
f0109e4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0109e4d:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
f0109e51:	d3 e0                	shl    %cl,%eax
f0109e53:	09 c2                	or     %eax,%edx
f0109e55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0109e58:	d3 e6                	shl    %cl,%esi
f0109e5a:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
f0109e5e:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0109e61:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0109e64:	d3 e8                	shr    %cl,%eax
f0109e66:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
f0109e6a:	d3 e2                	shl    %cl,%edx
f0109e6c:	09 d0                	or     %edx,%eax
f0109e6e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0109e71:	d3 e7                	shl    %cl,%edi
f0109e73:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
f0109e77:	d3 ea                	shr    %cl,%edx
f0109e79:	f7 75 f4             	divl   -0xc(%ebp)
f0109e7c:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0109e7f:	f7 e6                	mul    %esi
f0109e81:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f0109e84:	72 53                	jb     f0109ed9 <__umoddi3+0x169>
f0109e86:	3b 55 cc             	cmp    -0x34(%ebp),%edx
f0109e89:	74 4a                	je     f0109ed5 <__umoddi3+0x165>
f0109e8b:	90                   	nop    
f0109e8c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0109e90:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0109e93:	29 c7                	sub    %eax,%edi
f0109e95:	19 d1                	sbb    %edx,%ecx
f0109e97:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0109e9a:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
f0109e9e:	89 fa                	mov    %edi,%edx
f0109ea0:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0109ea3:	d3 ea                	shr    %cl,%edx
f0109ea5:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
f0109ea9:	d3 e0                	shl    %cl,%eax
f0109eab:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
f0109eaf:	09 c2                	or     %eax,%edx
f0109eb1:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0109eb4:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0109eb7:	d3 e8                	shr    %cl,%eax
f0109eb9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0109ebc:	e9 0f ff ff ff       	jmp    f0109dd0 <__umoddi3+0x60>
f0109ec1:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0109ec4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0109ec7:	2b 45 ec             	sub    -0x14(%ebp),%eax
f0109eca:	1b 55 e8             	sbb    -0x18(%ebp),%edx
f0109ecd:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0109ed0:	e9 2f ff ff ff       	jmp    f0109e04 <__umoddi3+0x94>
f0109ed5:	39 f8                	cmp    %edi,%eax
f0109ed7:	76 b7                	jbe    f0109e90 <__umoddi3+0x120>
f0109ed9:	29 f0                	sub    %esi,%eax
f0109edb:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f0109ede:	eb b0                	jmp    f0109e90 <__umoddi3+0x120>
