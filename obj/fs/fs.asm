
obj/fs/fs:     file format elf32-i386

Disassembly of section .text:

00800020 <_start>:
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,内核启动该进程，内核不知道传递什么参数
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 4b 1d 00 00       	call   801d7c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <ide_wait_ready>:
static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	53                   	push   %ebx
  800044:	89 c3                	mov    %eax,%ebx
  800046:	b9 f7 01 00 00       	mov    $0x1f7,%ecx
static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  80004b:	89 ca                	mov    %ecx,%edx
  80004d:	ec                   	in     (%dx),%al
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  80004e:	0f b6 d0             	movzbl %al,%edx
  800051:	89 d0                	mov    %edx,%eax
  800053:	25 c0 00 00 00       	and    $0xc0,%eax
  800058:	83 f8 40             	cmp    $0x40,%eax
  80005b:	75 ee                	jne    80004b <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80005d:	85 db                	test   %ebx,%ebx
  80005f:	74 0a                	je     80006b <ide_wait_ready+0x2b>
  800061:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800066:	f6 c2 21             	test   $0x21,%dl
  800069:	75 05                	jne    800070 <ide_wait_ready+0x30>
  80006b:	b8 00 00 00 00       	mov    $0x0,%eax
		return -1;
	return 0;
}
  800070:	5b                   	pop    %ebx
  800071:	5d                   	pop    %ebp
  800072:	c3                   	ret    

00800073 <ide_set_disk>:

bool
ide_probe_disk1(void)
{
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0; 
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0; 
	     x++)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
	return (x < 1000);
}

void
ide_set_disk(int d)
{
  800073:	55                   	push   %ebp
  800074:	89 e5                	mov    %esp,%ebp
  800076:	83 ec 18             	sub    $0x18,%esp
  800079:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  80007c:	83 f8 01             	cmp    $0x1,%eax
  80007f:	76 1c                	jbe    80009d <ide_set_disk+0x2a>
		panic("bad disk number");
  800081:	c7 44 24 08 c0 40 80 	movl   $0x8040c0,0x8(%esp)
  800088:	00 
  800089:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  800090:	00 
  800091:	c7 04 24 d0 40 80 00 	movl   $0x8040d0,(%esp)
  800098:	e8 57 1d 00 00       	call   801df4 <_panic>
	diskno = d;
  80009d:	a3 00 80 80 00       	mov    %eax,0x808000
}
  8000a2:	c9                   	leave  
  8000a3:	c3                   	ret    

008000a4 <ide_probe_disk1>:
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	53                   	push   %ebx
  8000a8:	83 ec 14             	sub    $0x14,%esp
  8000ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b0:	e8 8b ff ff ff       	call   800040 <ide_wait_ready>

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8000b5:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  8000ba:	ba f6 01 00 00       	mov    $0x1f6,%edx
  8000bf:	ee                   	out    %al,(%dx)
  8000c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000c5:	b2 f7                	mov    $0xf7,%dl
  8000c7:	eb 0b                	jmp    8000d4 <ide_probe_disk1+0x30>
  8000c9:	83 c1 01             	add    $0x1,%ecx
  8000cc:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  8000d2:	74 05                	je     8000d9 <ide_probe_disk1+0x35>
static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  8000d4:	ec                   	in     (%dx),%al
  8000d5:	a8 a1                	test   $0xa1,%al
  8000d7:	75 f0                	jne    8000c9 <ide_probe_disk1+0x25>

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8000d9:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  8000de:	ba f6 01 00 00       	mov    $0x1f6,%edx
  8000e3:	ee                   	out    %al,(%dx)
  8000e4:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000ea:	0f 9e c3             	setle  %bl
  8000ed:	0f b6 db             	movzbl %bl,%ebx
  8000f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000f4:	c7 04 24 d9 40 80 00 	movl   $0x8040d9,(%esp)
  8000fb:	e8 c1 1d 00 00       	call   801ec1 <cprintf>
  800100:	89 d8                	mov    %ebx,%eax
  800102:	83 c4 14             	add    $0x14,%esp
  800105:	5b                   	pop    %ebx
  800106:	5d                   	pop    %ebp
  800107:	c3                   	ret    

00800108 <ide_read>:

int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	57                   	push   %edi
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
  80010e:	83 ec 1c             	sub    $0x1c,%esp
  800111:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;

	assert(nsecs <= 256);
  800114:	81 7d 10 00 01 00 00 	cmpl   $0x100,0x10(%ebp)
  80011b:	76 24                	jbe    800141 <ide_read+0x39>
  80011d:	c7 44 24 0c f0 40 80 	movl   $0x8040f0,0xc(%esp)
  800124:	00 
  800125:	c7 44 24 08 fd 40 80 	movl   $0x8040fd,0x8(%esp)
  80012c:	00 
  80012d:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  800134:	00 
  800135:	c7 04 24 d0 40 80 00 	movl   $0x8040d0,(%esp)
  80013c:	e8 b3 1c 00 00       	call   801df4 <_panic>

	ide_wait_ready(0);
  800141:	b8 00 00 00 00       	mov    $0x0,%eax
  800146:	e8 f5 fe ff ff       	call   800040 <ide_wait_ready>

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80014b:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800150:	0f b6 45 10          	movzbl 0x10(%ebp),%eax
  800154:	ee                   	out    %al,(%dx)
  800155:	b2 f3                	mov    $0xf3,%dl
  800157:	89 d8                	mov    %ebx,%eax
  800159:	ee                   	out    %al,(%dx)
  80015a:	0f b6 c7             	movzbl %bh,%eax
  80015d:	b2 f4                	mov    $0xf4,%dl
  80015f:	ee                   	out    %al,(%dx)
  800160:	89 d8                	mov    %ebx,%eax
  800162:	c1 e8 10             	shr    $0x10,%eax
  800165:	b2 f5                	mov    $0xf5,%dl
  800167:	ee                   	out    %al,(%dx)
  800168:	0f b6 05 00 80 80 00 	movzbl 0x808000,%eax
  80016f:	83 e0 01             	and    $0x1,%eax
  800172:	c1 e0 04             	shl    $0x4,%eax
  800175:	89 c2                	mov    %eax,%edx
  800177:	83 ca e0             	or     $0xffffffe0,%edx
  80017a:	89 d8                	mov    %ebx,%eax
  80017c:	c1 e8 18             	shr    $0x18,%eax
  80017f:	83 e0 0f             	and    $0xf,%eax
  800182:	09 d0                	or     %edx,%eax
  800184:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800189:	ee                   	out    %al,(%dx)
  80018a:	b8 20 00 00 00       	mov    $0x20,%eax
  80018f:	b2 f7                	mov    $0xf7,%dl
  800191:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800192:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800196:	74 31                	je     8001c9 <ide_read+0xc1>
  800198:	be f0 01 00 00       	mov    $0x1f0,%esi
  80019d:	bb 80 00 00 00       	mov    $0x80,%ebx
		if ((r = ide_wait_ready(1)) < 0)
  8001a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8001a7:	e8 94 fe ff ff       	call   800040 <ide_wait_ready>
  8001ac:	85 c0                	test   %eax,%eax
  8001ae:	78 1e                	js     8001ce <ide_read+0xc6>

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
  8001b0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8001b3:	89 d9                	mov    %ebx,%ecx
  8001b5:	89 f2                	mov    %esi,%edx
  8001b7:	fc                   	cld    
  8001b8:	f2 6d                	repnz insl (%dx),%es:(%edi)
  8001ba:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8001be:	74 09                	je     8001c9 <ide_read+0xc1>
  8001c0:	81 45 0c 00 02 00 00 	addl   $0x200,0xc(%ebp)
  8001c7:	eb d9                	jmp    8001a2 <ide_read+0x9a>
  8001c9:	b8 00 00 00 00       	mov    $0x0,%eax
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}
	
	return 0;
}
  8001ce:	83 c4 1c             	add    $0x1c,%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    

008001d6 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	57                   	push   %edi
  8001da:	56                   	push   %esi
  8001db:	53                   	push   %ebx
  8001dc:	83 ec 1c             	sub    $0x1c,%esp
  8001df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	
	assert(nsecs <= 256);
  8001e2:	81 7d 10 00 01 00 00 	cmpl   $0x100,0x10(%ebp)
  8001e9:	76 24                	jbe    80020f <ide_write+0x39>
  8001eb:	c7 44 24 0c f0 40 80 	movl   $0x8040f0,0xc(%esp)
  8001f2:	00 
  8001f3:	c7 44 24 08 fd 40 80 	movl   $0x8040fd,0x8(%esp)
  8001fa:	00 
  8001fb:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800202:	00 
  800203:	c7 04 24 d0 40 80 00 	movl   $0x8040d0,(%esp)
  80020a:	e8 e5 1b 00 00       	call   801df4 <_panic>

	ide_wait_ready(0);
  80020f:	b8 00 00 00 00       	mov    $0x0,%eax
  800214:	e8 27 fe ff ff       	call   800040 <ide_wait_ready>

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800219:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80021e:	0f b6 45 10          	movzbl 0x10(%ebp),%eax
  800222:	ee                   	out    %al,(%dx)
  800223:	b2 f3                	mov    $0xf3,%dl
  800225:	89 d8                	mov    %ebx,%eax
  800227:	ee                   	out    %al,(%dx)
  800228:	0f b6 c7             	movzbl %bh,%eax
  80022b:	b2 f4                	mov    $0xf4,%dl
  80022d:	ee                   	out    %al,(%dx)
  80022e:	89 d8                	mov    %ebx,%eax
  800230:	c1 e8 10             	shr    $0x10,%eax
  800233:	b2 f5                	mov    $0xf5,%dl
  800235:	ee                   	out    %al,(%dx)
  800236:	0f b6 05 00 80 80 00 	movzbl 0x808000,%eax
  80023d:	83 e0 01             	and    $0x1,%eax
  800240:	c1 e0 04             	shl    $0x4,%eax
  800243:	89 c2                	mov    %eax,%edx
  800245:	83 ca e0             	or     $0xffffffe0,%edx
  800248:	89 d8                	mov    %ebx,%eax
  80024a:	c1 e8 18             	shr    $0x18,%eax
  80024d:	83 e0 0f             	and    $0xf,%eax
  800250:	09 d0                	or     %edx,%eax
  800252:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800257:	ee                   	out    %al,(%dx)
  800258:	b8 30 00 00 00       	mov    $0x30,%eax
  80025d:	b2 f7                	mov    $0xf7,%dl
  80025f:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  800260:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800264:	74 31                	je     800297 <ide_write+0xc1>
  800266:	bf f0 01 00 00       	mov    $0x1f0,%edi
  80026b:	bb 80 00 00 00       	mov    $0x80,%ebx
		if ((r = ide_wait_ready(1)) < 0)
  800270:	b8 01 00 00 00       	mov    $0x1,%eax
  800275:	e8 c6 fd ff ff       	call   800040 <ide_wait_ready>
  80027a:	85 c0                	test   %eax,%eax
  80027c:	78 1e                	js     80029c <ide_write+0xc6>

static __inline void
outsl(int port, const void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\toutsl"		:
  80027e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800281:	89 d9                	mov    %ebx,%ecx
  800283:	89 fa                	mov    %edi,%edx
  800285:	fc                   	cld    
  800286:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
  800288:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80028c:	74 09                	je     800297 <ide_write+0xc1>
  80028e:	81 45 0c 00 02 00 00 	addl   $0x200,0xc(%ebp)
  800295:	eb d9                	jmp    800270 <ide_write+0x9a>
  800297:	b8 00 00 00 00       	mov    $0x0,%eax
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
}
  80029c:	83 c4 1c             	add    $0x1c,%esp
  80029f:	5b                   	pop    %ebx
  8002a0:	5e                   	pop    %esi
  8002a1:	5f                   	pop    %edi
  8002a2:	5d                   	pop    %ebp
  8002a3:	c3                   	ret    
	...

008002b0 <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
	return (vpd[PDX(va)] & PTE_P) && (vpt[VPN(va)] & PTE_P);
  8002b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b6:	89 d0                	mov    %edx,%eax
  8002b8:	c1 e8 16             	shr    $0x16,%eax
  8002bb:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  8002c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002c7:	a8 01                	test   $0x1,%al
  8002c9:	74 11                	je     8002dc <va_is_mapped+0x2c>
  8002cb:	89 d0                	mov    %edx,%eax
  8002cd:	c1 e8 0c             	shr    $0xc,%eax
  8002d0:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  8002d7:	89 c1                	mov    %eax,%ecx
  8002d9:	83 e1 01             	and    $0x1,%ecx
}
  8002dc:	89 c8                	mov    %ecx,%eax
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    

008002e0 <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
	return (vpt[VPN(va)] & PTE_D) != 0;
  8002e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e6:	c1 e8 0c             	shr    $0xc,%eax
  8002e9:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  8002f0:	c1 e8 06             	shr    $0x6,%eax
  8002f3:	83 e0 01             	and    $0x1,%eax
}
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <diskaddr>:
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 18             	sub    $0x18,%esp
  8002fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800301:	85 c0                	test   %eax,%eax
  800303:	74 0f                	je     800314 <diskaddr+0x1c>
  800305:	8b 15 a4 c0 80 00    	mov    0x80c0a4,%edx
  80030b:	85 d2                	test   %edx,%edx
  80030d:	74 25                	je     800334 <diskaddr+0x3c>
  80030f:	3b 42 04             	cmp    0x4(%edx),%eax
  800312:	72 20                	jb     800334 <diskaddr+0x3c>
  800314:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800318:	c7 44 24 08 14 41 80 	movl   $0x804114,0x8(%esp)
  80031f:	00 
  800320:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  800327:	00 
  800328:	c7 04 24 b0 41 80 00 	movl   $0x8041b0,(%esp)
  80032f:	e8 c0 1a 00 00       	call   801df4 <_panic>
  800334:	c1 e0 0c             	shl    $0xc,%eax
  800337:	05 00 00 00 10       	add    $0x10000000,%eax
  80033c:	c9                   	leave  
  80033d:	c3                   	ret    

0080033e <bc_pgfault>:

// Fault any disk block that is read or written in to memory by
// loading it from disk.
// Hint: Use ide_read and BLKSECTS.
static void
bc_pgfault(struct UTrapframe *utf)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	56                   	push   %esi
  800342:	53                   	push   %ebx
  800343:	83 ec 20             	sub    $0x20,%esp
  800346:	8b 4d 08             	mov    0x8(%ebp),%ecx
	void *addr = (void *) utf->utf_fault_va;
  800349:	8b 11                	mov    (%ecx),%edx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
	int r;

	// Check that the fault was within the block cache region
	// 检查异常是否发生在块缓冲区
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80034b:	8d 82 00 00 00 f0    	lea    0xf0000000(%edx),%eax
  800351:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800356:	76 2e                	jbe    800386 <bc_pgfault+0x48>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800358:	8b 41 04             	mov    0x4(%ecx),%eax
  80035b:	89 44 24 14          	mov    %eax,0x14(%esp)
  80035f:	89 54 24 10          	mov    %edx,0x10(%esp)
  800363:	8b 41 28             	mov    0x28(%ecx),%eax
  800366:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80036a:	c7 44 24 08 38 41 80 	movl   $0x804138,0x8(%esp)
  800371:	00 
  800372:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  800379:	00 
  80037a:	c7 04 24 b0 41 80 00 	movl   $0x8041b0,(%esp)
  800381:	e8 6e 1a 00 00       	call   801df4 <_panic>
  800386:	89 d3                	mov    %edx,%ebx
		      utf->utf_eip, addr, utf->utf_err);

	// Allocate a page in the disk map region and read the
	// contents of the block from the disk into that page.
	//注意扇区是从0开始的
	// LAB 5: Your code here
	if((r=sys_page_alloc(0,ROUNDDOWN(addr,BLKSIZE),PTE_USER))<0)
  800388:	89 d6                	mov    %edx,%esi
  80038a:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  800390:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  800397:	00 
  800398:	89 74 24 04          	mov    %esi,0x4(%esp)
  80039c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003a3:	e8 c2 28 00 00       	call   802c6a <sys_page_alloc>
  8003a8:	85 c0                	test   %eax,%eax
  8003aa:	79 20                	jns    8003cc <bc_pgfault+0x8e>
		panic("alloc page failed:%e\n",r);
  8003ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003b0:	c7 44 24 08 b8 41 80 	movl   $0x8041b8,0x8(%esp)
  8003b7:	00 
  8003b8:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  8003bf:	00 
  8003c0:	c7 04 24 b0 41 80 00 	movl   $0x8041b0,(%esp)
  8003c7:	e8 28 1a 00 00       	call   801df4 <_panic>
  8003cc:	8d 83 00 00 00 f0    	lea    0xf0000000(%ebx),%eax
  8003d2:	89 c3                	mov    %eax,%ebx
  8003d4:	c1 eb 0c             	shr    $0xc,%ebx
	//cprintf("sector=%d\n",blockno*BLKSECTS+1);
	ide_read(blockno*BLKSECTS,ROUNDDOWN(addr,BLKSIZE),BLKSECTS);
  8003d7:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  8003de:	00 
  8003df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003e3:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
  8003ea:	89 04 24             	mov    %eax,(%esp)
  8003ed:	e8 16 fd ff ff       	call   800108 <ide_read>
	//if(super)
	//	cprintf("fault:nblocks=%d\n",super->s_nblocks);
	// Sanity check the block number. (exercise for the reader:
	// why do we do this *after* reading the block in?)
	if (super && blockno >= super->s_nblocks)
  8003f2:	a1 a4 c0 80 00       	mov    0x80c0a4,%eax
  8003f7:	85 c0                	test   %eax,%eax
  8003f9:	74 25                	je     800420 <bc_pgfault+0xe2>
  8003fb:	3b 58 04             	cmp    0x4(%eax),%ebx
  8003fe:	72 20                	jb     800420 <bc_pgfault+0xe2>
		panic("reading non-existent block %08x\n", blockno);
  800400:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800404:	c7 44 24 08 68 41 80 	movl   $0x804168,0x8(%esp)
  80040b:	00 
  80040c:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  800413:	00 
  800414:	c7 04 24 b0 41 80 00 	movl   $0x8041b0,(%esp)
  80041b:	e8 d4 19 00 00       	call   801df4 <_panic>

	// Check that the block we read was allocated.
	if (bitmap && block_is_free(blockno))
  800420:	83 3d a0 c0 80 00 00 	cmpl   $0x0,0x80c0a0
  800427:	74 2c                	je     800455 <bc_pgfault+0x117>
  800429:	89 1c 24             	mov    %ebx,(%esp)
  80042c:	e8 cf 02 00 00       	call   800700 <block_is_free>
  800431:	85 c0                	test   %eax,%eax
  800433:	74 20                	je     800455 <bc_pgfault+0x117>
		panic("reading free block %08x\n", blockno);
  800435:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800439:	c7 44 24 08 ce 41 80 	movl   $0x8041ce,0x8(%esp)
  800440:	00 
  800441:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  800448:	00 
  800449:	c7 04 24 b0 41 80 00 	movl   $0x8041b0,(%esp)
  800450:	e8 9f 19 00 00       	call   801df4 <_panic>
}
  800455:	83 c4 20             	add    $0x20,%esp
  800458:	5b                   	pop    %ebx
  800459:	5e                   	pop    %esi
  80045a:	5d                   	pop    %ebp
  80045b:	c3                   	ret    

0080045c <flush_block>:

// Flush the contents of the block containing VA out to disk if
// necessary, then clear the PTE_D bit using sys_page_map.
// If the block is not in the block cache or is not dirty, does
// nothing.
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_USER constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  80045c:	55                   	push   %ebp
  80045d:	89 e5                	mov    %esp,%ebp
  80045f:	83 ec 28             	sub    $0x28,%esp
  800462:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  800465:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  800468:	8b 75 08             	mov    0x8(%ebp),%esi
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80046b:	8d 86 00 00 00 f0    	lea    0xf0000000(%esi),%eax
  800471:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800476:	76 20                	jbe    800498 <flush_block+0x3c>
		panic("flush_block of bad va %08x", addr);
  800478:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80047c:	c7 44 24 08 e7 41 80 	movl   $0x8041e7,0x8(%esp)
  800483:	00 
  800484:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  80048b:	00 
  80048c:	c7 04 24 b0 41 80 00 	movl   $0x8041b0,(%esp)
  800493:	e8 5c 19 00 00       	call   801df4 <_panic>

	// LAB 5: Your code here.
	int r;
	void *blkva;
	blkva=ROUNDDOWN(addr,BLKSIZE);
	if(va_is_mapped(addr)&&va_is_dirty(addr))
  800498:	89 34 24             	mov    %esi,(%esp)
  80049b:	e8 10 fe ff ff       	call   8002b0 <va_is_mapped>
  8004a0:	85 c0                	test   %eax,%eax
  8004a2:	74 7e                	je     800522 <flush_block+0xc6>
  8004a4:	89 34 24             	mov    %esi,(%esp)
  8004a7:	e8 34 fe ff ff       	call   8002e0 <va_is_dirty>
  8004ac:	85 c0                	test   %eax,%eax
  8004ae:	66 90                	xchg   %ax,%ax
  8004b0:	74 70                	je     800522 <flush_block+0xc6>
  8004b2:	89 f3                	mov    %esi,%ebx
  8004b4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	{
		ide_write(blockno*BLKSECTS,blkva,BLKSECTS);
  8004ba:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  8004c1:	00 
  8004c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c6:	8d 86 00 00 00 f0    	lea    0xf0000000(%esi),%eax
  8004cc:	c1 e8 0c             	shr    $0xc,%eax
  8004cf:	c1 e0 03             	shl    $0x3,%eax
  8004d2:	89 04 24             	mov    %eax,(%esp)
  8004d5:	e8 fc fc ff ff       	call   8001d6 <ide_write>
		if((r=sys_page_map(0,blkva,0,blkva,PTE_USER))<0)
  8004da:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  8004e1:	00 
  8004e2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004e6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004ed:	00 
  8004ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8004f9:	e8 0e 27 00 00       	call   802c0c <sys_page_map>
  8004fe:	85 c0                	test   %eax,%eax
  800500:	79 20                	jns    800522 <flush_block+0xc6>
			panic("page mapping failed:%e\n",r);
  800502:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800506:	c7 44 24 08 02 42 80 	movl   $0x804202,0x8(%esp)
  80050d:	00 
  80050e:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  800515:	00 
  800516:	c7 04 24 b0 41 80 00 	movl   $0x8041b0,(%esp)
  80051d:	e8 d2 18 00 00       	call   801df4 <_panic>
		
	}
	//panic("flush_block not implemented");
}
  800522:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  800525:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  800528:	89 ec                	mov    %ebp,%esp
  80052a:	5d                   	pop    %ebp
  80052b:	c3                   	ret    

0080052c <bc_init>:

// Test that the block cache works, by smashing the superblock and
// reading it back.
static void
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
	//cprintf("check bc:magic=%x nblocks=%x\n",backup.s_magic,backup.s_nblocks);
	// smash it 
	strcpy(diskaddr(1), "OOPS!\n");
	flush_block(diskaddr(1));
	assert(va_is_mapped(diskaddr(1)));
	assert(!va_is_dirty(diskaddr(1)));

	// clear it out
	sys_page_unmap(0, diskaddr(1));
	assert(!va_is_mapped(diskaddr(1)));

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
	flush_block(diskaddr(1));

	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  80052c:	55                   	push   %ebp
  80052d:	89 e5                	mov    %esp,%ebp
  80052f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	set_pgfault_handler(bc_pgfault);
  800535:	c7 04 24 3e 03 80 00 	movl   $0x80033e,(%esp)
  80053c:	e8 4f 28 00 00       	call   802d90 <set_pgfault_handler>
  800541:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800548:	e8 ab fd ff ff       	call   8002f8 <diskaddr>
  80054d:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  800554:	00 
  800555:	89 44 24 04          	mov    %eax,0x4(%esp)
  800559:	8d 85 f8 fe ff ff    	lea    0xfffffef8(%ebp),%eax
  80055f:	89 04 24             	mov    %eax,(%esp)
  800562:	e8 e3 21 00 00       	call   80274a <memmove>
  800567:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80056e:	e8 85 fd ff ff       	call   8002f8 <diskaddr>
  800573:	c7 44 24 04 1a 42 80 	movl   $0x80421a,0x4(%esp)
  80057a:	00 
  80057b:	89 04 24             	mov    %eax,(%esp)
  80057e:	e8 be 1f 00 00       	call   802541 <strcpy>
  800583:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80058a:	e8 69 fd ff ff       	call   8002f8 <diskaddr>
  80058f:	89 04 24             	mov    %eax,(%esp)
  800592:	e8 c5 fe ff ff       	call   80045c <flush_block>
  800597:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80059e:	e8 55 fd ff ff       	call   8002f8 <diskaddr>
  8005a3:	89 04 24             	mov    %eax,(%esp)
  8005a6:	e8 05 fd ff ff       	call   8002b0 <va_is_mapped>
  8005ab:	85 c0                	test   %eax,%eax
  8005ad:	75 24                	jne    8005d3 <bc_init+0xa7>
  8005af:	c7 44 24 0c 3c 42 80 	movl   $0x80423c,0xc(%esp)
  8005b6:	00 
  8005b7:	c7 44 24 08 fd 40 80 	movl   $0x8040fd,0x8(%esp)
  8005be:	00 
  8005bf:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
  8005c6:	00 
  8005c7:	c7 04 24 b0 41 80 00 	movl   $0x8041b0,(%esp)
  8005ce:	e8 21 18 00 00       	call   801df4 <_panic>
  8005d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005da:	e8 19 fd ff ff       	call   8002f8 <diskaddr>
  8005df:	89 04 24             	mov    %eax,(%esp)
  8005e2:	e8 f9 fc ff ff       	call   8002e0 <va_is_dirty>
  8005e7:	85 c0                	test   %eax,%eax
  8005e9:	74 24                	je     80060f <bc_init+0xe3>
  8005eb:	c7 44 24 0c 21 42 80 	movl   $0x804221,0xc(%esp)
  8005f2:	00 
  8005f3:	c7 44 24 08 fd 40 80 	movl   $0x8040fd,0x8(%esp)
  8005fa:	00 
  8005fb:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
  800602:	00 
  800603:	c7 04 24 b0 41 80 00 	movl   $0x8041b0,(%esp)
  80060a:	e8 e5 17 00 00       	call   801df4 <_panic>
  80060f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800616:	e8 dd fc ff ff       	call   8002f8 <diskaddr>
  80061b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800626:	e8 83 25 00 00       	call   802bae <sys_page_unmap>
  80062b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800632:	e8 c1 fc ff ff       	call   8002f8 <diskaddr>
  800637:	89 04 24             	mov    %eax,(%esp)
  80063a:	e8 71 fc ff ff       	call   8002b0 <va_is_mapped>
  80063f:	85 c0                	test   %eax,%eax
  800641:	74 24                	je     800667 <bc_init+0x13b>
  800643:	c7 44 24 0c 3b 42 80 	movl   $0x80423b,0xc(%esp)
  80064a:	00 
  80064b:	c7 44 24 08 fd 40 80 	movl   $0x8040fd,0x8(%esp)
  800652:	00 
  800653:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  80065a:	00 
  80065b:	c7 04 24 b0 41 80 00 	movl   $0x8041b0,(%esp)
  800662:	e8 8d 17 00 00       	call   801df4 <_panic>
  800667:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80066e:	e8 85 fc ff ff       	call   8002f8 <diskaddr>
  800673:	c7 44 24 04 1a 42 80 	movl   $0x80421a,0x4(%esp)
  80067a:	00 
  80067b:	89 04 24             	mov    %eax,(%esp)
  80067e:	e8 a2 1f 00 00       	call   802625 <strcmp>
  800683:	85 c0                	test   %eax,%eax
  800685:	74 24                	je     8006ab <bc_init+0x17f>
  800687:	c7 44 24 0c 8c 41 80 	movl   $0x80418c,0xc(%esp)
  80068e:	00 
  80068f:	c7 44 24 08 fd 40 80 	movl   $0x8040fd,0x8(%esp)
  800696:	00 
  800697:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  80069e:	00 
  80069f:	c7 04 24 b0 41 80 00 	movl   $0x8041b0,(%esp)
  8006a6:	e8 49 17 00 00       	call   801df4 <_panic>
  8006ab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006b2:	e8 41 fc ff ff       	call   8002f8 <diskaddr>
  8006b7:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  8006be:	00 
  8006bf:	8d 95 f8 fe ff ff    	lea    0xfffffef8(%ebp),%edx
  8006c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006c9:	89 04 24             	mov    %eax,(%esp)
  8006cc:	e8 79 20 00 00       	call   80274a <memmove>
  8006d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006d8:	e8 1b fc ff ff       	call   8002f8 <diskaddr>
  8006dd:	89 04 24             	mov    %eax,(%esp)
  8006e0:	e8 77 fd ff ff       	call   80045c <flush_block>
  8006e5:	c7 04 24 56 42 80 00 	movl   $0x804256,(%esp)
  8006ec:	e8 d0 17 00 00       	call   801ec1 <cprintf>
	check_bc();
}
  8006f1:	c9                   	leave  
  8006f2:	c3                   	ret    
	...

00800700 <block_is_free>:
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	53                   	push   %ebx
  800704:	8b 55 08             	mov    0x8(%ebp),%edx
	if (super == 0 || blockno >= super->s_nblocks)
  800707:	a1 a4 c0 80 00       	mov    0x80c0a4,%eax
  80070c:	85 c0                	test   %eax,%eax
  80070e:	74 27                	je     800737 <block_is_free+0x37>
  800710:	39 50 04             	cmp    %edx,0x4(%eax)
  800713:	76 22                	jbe    800737 <block_is_free+0x37>
  800715:	89 d3                	mov    %edx,%ebx
  800717:	c1 eb 05             	shr    $0x5,%ebx
  80071a:	89 d1                	mov    %edx,%ecx
  80071c:	83 e1 1f             	and    $0x1f,%ecx
  80071f:	b8 01 00 00 00       	mov    $0x1,%eax
  800724:	d3 e0                	shl    %cl,%eax
  800726:	8b 15 a0 c0 80 00    	mov    0x80c0a0,%edx
  80072c:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  80072f:	0f 95 c0             	setne  %al
  800732:	0f b6 c0             	movzbl %al,%eax
  800735:	eb 05                	jmp    80073c <block_is_free+0x3c>
  800737:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  80073c:	5b                   	pop    %ebx
  80073d:	5d                   	pop    %ebp
  80073e:	c3                   	ret    

0080073f <skip_slash>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
		panic("attempt to free zero block");
	bitmap[blockno/32] |= 1<<(blockno%32);
}

// Search the bitmap for a free block and allocate it.  When you
// allocate a block, immediately flush the changed bitmap block
// to disk.
// 
// Return block number allocated on success,
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	uint32_t blockno;
	for(blockno=1;blockno<super->s_nblocks;blockno++)
		if(block_is_free(blockno))
		{
			bitmap[blockno/32] &= ~(1<<(blockno%32));
			flush_block(diskaddr(2));
			return blockno;
		}
	//panic("alloc_block not implemented");
	return -E_NO_DISK;
}

// Validate the file system bitmap.
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
	assert(!block_is_free(1));

	cprintf("bitmap is good\n");
}

// --------------------------------------------------------------
// File system structures
// --------------------------------------------------------------

// Initialize the file system
void
fs_init(void)
{
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available.
	if (ide_probe_disk1())
		ide_set_disk(1);
	else
		ide_set_disk(0);
	bc_init();

	// Set "super" to point to the super block.
	super = (struct Super*)diskaddr(1);
	//cprintf("super block:magic=%x nblocks=%x\n",super->s_magic,super->s_nblocks);
	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);

	check_super();
	check_bitmap();
}

// Find the disk block number slot for the 'filebno'th block in file 'f'.
// Set '*ppdiskbno' to point to that slot.
// The slot will be one of the f->f_direct[] entries,
// or an entry in the indirect block.
// When 'alloc' is set, this function will allocate an indirect block
// if necessary.
//
// Returns:
//	0 on success (but note that *ppdiskbno might equal 0).
//	-E_NOT_FOUND if the function needed to allocate an indirect block, but
//		alloc was 0.
//	-E_NO_DISK if there's no space on the disk for an indirect block.
//	-E_INVAL if filebno is out of range (it's >= NDIRECT + NINDIRECT).
//
// Analogy: This is like pgdir_walk for files.  
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
	// LAB 5: Your code here.
	int blkno;
	if(filebno<NDIRECT)
	{	
		//cprintf("walk:filebno=%d file block num=%d\n",filebno,f->f_direct[filebno]);
		*ppdiskbno=&f->f_direct[filebno];
	}
	else if((filebno<NDIRECT+NINDIRECT)&&(filebno>=NDIRECT))
	{
		if(!f->f_indirect)
		{
			if(!alloc)
				return -E_NOT_FOUND;
			if((blkno=alloc_block())<0)
				return -E_NO_DISK;
			//cprintf("walk:blkno=%d\n",blkno);
			f->f_indirect=blkno;
			memset(diskaddr(blkno),0,BLKSIZE);
			*ppdiskbno=NULL;
		}
		else{
			*ppdiskbno=(uint32_t *)diskaddr(f->f_indirect)+filebno-10;
		}
		
	}
	else
		return -E_INVAL;
	//cprintf("file walk:ppdiskbno=%x\n",*ppdiskbno);
	return 0;
	//panic("file_block_walk not implemented");
}

// Set *blk to point at the filebno'th block in file 'f'.
// Allocate the block if it doesn't yet exist.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_NO_DISK if a block needed to be allocated but the disk is full.
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
	// LAB 5: Your code here.
	int r;
	uint32_t *pdiskbno;
	if(filebno<NDIRECT+NINDIRECT&&filebno>=0)
	{
		if((r=file_block_walk(f,filebno,&pdiskbno,1))<0)
			return r;
		//cprintf("get block:pdiskbno=%x\n",*pdiskbno);
		if(pdiskbno&&*pdiskbno)
		{
			*blk=(char *)diskaddr(*pdiskbno);
		}
		else{
			if((*pdiskbno=(uint32_t)alloc_block())<0)
				return -E_NO_DISK;
			memset(diskaddr(*pdiskbno),0,BLKSIZE);
			*blk=(char *)diskaddr(*pdiskbno);
			if(filebno<NDIRECT)
				f->f_direct[filebno]=*pdiskbno;
			else
				*((uint32_t *)diskaddr(f->f_indirect)+filebno-10)=*pdiskbno;
		}
	}
	else
		return -E_INVAL;
	return 0;
	//panic("file_get_block not implemented");
}

// Try to find a file named "name" in dir.  If so, set *file to it.
//
// Returns 0 and sets *file on success, < 0 on error.  Errors are:
//	-E_NOT_FOUND if the file is not found
static int
dir_lookup(struct File *dir, const char *name, struct File **file)
{
	int r;
	uint32_t i, j, nblock;
	char *blk;
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
				*file = &f[j];
				return 0;
			}
	}
	return -E_NOT_FOUND;
}

// Set *file to point at a free File structure in dir.  The caller is
// responsible for filling in the File fields.
static int
dir_alloc_file(struct File *dir, struct File **file)
{
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
	if ((r = file_get_block(dir, i, &blk)) < 0)
		return r;
	f = (struct File*) blk;
	*file = &f[0];
	return 0;
}

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
	while (*p == '/')
  800742:	80 38 2f             	cmpb   $0x2f,(%eax)
  800745:	75 08                	jne    80074f <skip_slash+0x10>
		p++;
  800747:	83 c0 01             	add    $0x1,%eax
  80074a:	80 38 2f             	cmpb   $0x2f,(%eax)
  80074d:	74 f8                	je     800747 <skip_slash+0x8>
	return p;
}
  80074f:	5d                   	pop    %ebp
  800750:	c3                   	ret    

00800751 <fs_sync>:

// Evaluate a path name, starting at the root.
// On success, set *pf to the file we found
// and set *pdir to the directory the file is in.
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
	const char *p;
	char name[MAXNAMELEN];
	struct File *dir, *f;
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
				if (pdir)
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
		}
	}

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}

// --------------------------------------------------------------
// File operations
// --------------------------------------------------------------

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
	if (dir_alloc_file(dir, &f) < 0)
		return r;
	strcpy(f->f_name, name);
	*pf = f;
	file_flush(dir);
	return 0;
}

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
	return walk_path(path, 0, pf, 0);
}

// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
	int r, bn;
	off_t pos;
	char *blk;
	//偏移量不超过文件f的size
	if (offset >= f->f_size)
		return 0;
	//根据偏移来计算，需要真正读取文件的字节数count
	count = MIN(count, f->f_size - offset);
	//
	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
}

// Write count bytes from buf into f, starting at seek position
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
}

// Remove a block from file f.  If it's not there, just silently succeed.
// Returns 0 on success, < 0 on error.
// 从文件f中删除一个块
static int
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
		return r;
	if (*ptr) {
		free_block(*ptr);
		*ptr = 0;
	}
	return 0;
}

// Remove any blocks currently used by file 'f',
// but not necessary for a file of size 'newsize'.
// For both the old and new sizes, figure out the number of blocks required,
// and then clear the blocks from new_nblocks to old_nblocks.
// If the new_nblocks is no more than NDIRECT, and the indirect block has
// been allocated (f->f_indirect != 0), then free the indirect block too.
// (Remember to clear the f->f_indirect pointer so you'll know
// whether it's valid!)
// Do not change f->f_size.
static void
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
		free_block(f->f_indirect);
		f->f_indirect = 0;
	}
}

// Set the size of file f, truncating or extending as necessary.
// 设置文件f的大小
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
	flush_block(f);
	return 0;
}

// Flush the contents and metadata of file f out to disk.
// Loop over all the blocks in file.循环遍历文件中所有的块
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;
	//遍历文件中所有的块，并进行块刷新
	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	//刷新文件结构体所在块
	flush_block(f);
	//刷新文件中的用于记录间接块号的块
	if (f->f_indirect)
		flush_block(diskaddr(f->f_indirect));
}

// Remove a file by truncating it and then zeroing the name.
int
file_remove(const char *path)
{
	int r;
	struct File *f;

	if ((r = walk_path(path, 0, &f, 0)) < 0)
		return r;

	file_truncate_blocks(f, 0);
	f->f_name[0] = '\0';
	f->f_size = 0;
	flush_block(f);

	return 0;
}

// Sync the entire file system.  A big hammer.同步真个文件系统
void
fs_sync(void)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	53                   	push   %ebx
  800755:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  800758:	a1 a4 c0 80 00       	mov    0x80c0a4,%eax
  80075d:	83 78 04 01          	cmpl   $0x1,0x4(%eax)
  800761:	76 29                	jbe    80078c <fs_sync+0x3b>
  800763:	bb 01 00 00 00       	mov    $0x1,%ebx
  800768:	ba 01 00 00 00       	mov    $0x1,%edx
		flush_block(diskaddr(i));
  80076d:	89 14 24             	mov    %edx,(%esp)
  800770:	e8 83 fb ff ff       	call   8002f8 <diskaddr>
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	e8 df fc ff ff       	call   80045c <flush_block>
  80077d:	83 c3 01             	add    $0x1,%ebx
  800780:	89 da                	mov    %ebx,%edx
  800782:	a1 a4 c0 80 00       	mov    0x80c0a4,%eax
  800787:	39 58 04             	cmp    %ebx,0x4(%eax)
  80078a:	77 e1                	ja     80076d <fs_sync+0x1c>
}
  80078c:	83 c4 04             	add    $0x4,%esp
  80078f:	5b                   	pop    %ebx
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <alloc_block>:
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	56                   	push   %esi
  800796:	53                   	push   %ebx
  800797:	83 ec 10             	sub    $0x10,%esp
  80079a:	a1 a4 c0 80 00       	mov    0x80c0a4,%eax
  80079f:	8b 70 04             	mov    0x4(%eax),%esi
  8007a2:	83 fe 01             	cmp    $0x1,%esi
  8007a5:	76 4b                	jbe    8007f2 <alloc_block+0x60>
  8007a7:	bb 01 00 00 00       	mov    $0x1,%ebx
  8007ac:	89 1c 24             	mov    %ebx,(%esp)
  8007af:	e8 4c ff ff ff       	call   800700 <block_is_free>
  8007b4:	85 c0                	test   %eax,%eax
  8007b6:	74 32                	je     8007ea <alloc_block+0x58>
  8007b8:	89 da                	mov    %ebx,%edx
  8007ba:	c1 ea 05             	shr    $0x5,%edx
  8007bd:	c1 e2 02             	shl    $0x2,%edx
  8007c0:	03 15 a0 c0 80 00    	add    0x80c0a0,%edx
  8007c6:	89 d9                	mov    %ebx,%ecx
  8007c8:	83 e1 1f             	and    $0x1f,%ecx
  8007cb:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  8007d0:	d3 c0                	rol    %cl,%eax
  8007d2:	21 02                	and    %eax,(%edx)
  8007d4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8007db:	e8 18 fb ff ff       	call   8002f8 <diskaddr>
  8007e0:	89 04 24             	mov    %eax,(%esp)
  8007e3:	e8 74 fc ff ff       	call   80045c <flush_block>
  8007e8:	eb 0d                	jmp    8007f7 <alloc_block+0x65>
  8007ea:	83 c3 01             	add    $0x1,%ebx
  8007ed:	39 f3                	cmp    %esi,%ebx
  8007ef:	90                   	nop    
  8007f0:	75 ba                	jne    8007ac <alloc_block+0x1a>
  8007f2:	bb f7 ff ff ff       	mov    $0xfffffff7,%ebx
  8007f7:	89 d8                	mov    %ebx,%eax
  8007f9:	83 c4 10             	add    $0x10,%esp
  8007fc:	5b                   	pop    %ebx
  8007fd:	5e                   	pop    %esi
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <free_block>:
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	83 ec 18             	sub    $0x18,%esp
  800806:	8b 55 08             	mov    0x8(%ebp),%edx
  800809:	85 d2                	test   %edx,%edx
  80080b:	75 1c                	jne    800829 <free_block+0x29>
  80080d:	c7 44 24 08 6b 42 80 	movl   $0x80426b,0x8(%esp)
  800814:	00 
  800815:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80081c:	00 
  80081d:	c7 04 24 86 42 80 00 	movl   $0x804286,(%esp)
  800824:	e8 cb 15 00 00       	call   801df4 <_panic>
  800829:	89 d0                	mov    %edx,%eax
  80082b:	c1 e8 05             	shr    $0x5,%eax
  80082e:	c1 e0 02             	shl    $0x2,%eax
  800831:	03 05 a0 c0 80 00    	add    0x80c0a0,%eax
  800837:	89 d1                	mov    %edx,%ecx
  800839:	83 e1 1f             	and    $0x1f,%ecx
  80083c:	ba 01 00 00 00       	mov    $0x1,%edx
  800841:	d3 e2                	shl    %cl,%edx
  800843:	09 10                	or     %edx,(%eax)
  800845:	c9                   	leave  
  800846:	c3                   	ret    

00800847 <check_bitmap>:
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	56                   	push   %esi
  80084b:	53                   	push   %ebx
  80084c:	83 ec 10             	sub    $0x10,%esp
  80084f:	a1 a4 c0 80 00       	mov    0x80c0a4,%eax
  800854:	8b 70 04             	mov    0x4(%eax),%esi
  800857:	85 f6                	test   %esi,%esi
  800859:	74 44                	je     80089f <check_bitmap+0x58>
  80085b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800860:	8d 43 02             	lea    0x2(%ebx),%eax
  800863:	89 04 24             	mov    %eax,(%esp)
  800866:	e8 95 fe ff ff       	call   800700 <block_is_free>
  80086b:	85 c0                	test   %eax,%eax
  80086d:	74 24                	je     800893 <check_bitmap+0x4c>
  80086f:	c7 44 24 0c 8e 42 80 	movl   $0x80428e,0xc(%esp)
  800876:	00 
  800877:	c7 44 24 08 fd 40 80 	movl   $0x8040fd,0x8(%esp)
  80087e:	00 
  80087f:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  800886:	00 
  800887:	c7 04 24 86 42 80 00 	movl   $0x804286,(%esp)
  80088e:	e8 61 15 00 00       	call   801df4 <_panic>
  800893:	83 c3 01             	add    $0x1,%ebx
  800896:	89 d8                	mov    %ebx,%eax
  800898:	c1 e0 0f             	shl    $0xf,%eax
  80089b:	39 f0                	cmp    %esi,%eax
  80089d:	72 c1                	jb     800860 <check_bitmap+0x19>
  80089f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8008a6:	e8 55 fe ff ff       	call   800700 <block_is_free>
  8008ab:	85 c0                	test   %eax,%eax
  8008ad:	74 24                	je     8008d3 <check_bitmap+0x8c>
  8008af:	c7 44 24 0c a2 42 80 	movl   $0x8042a2,0xc(%esp)
  8008b6:	00 
  8008b7:	c7 44 24 08 fd 40 80 	movl   $0x8040fd,0x8(%esp)
  8008be:	00 
  8008bf:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  8008c6:	00 
  8008c7:	c7 04 24 86 42 80 00 	movl   $0x804286,(%esp)
  8008ce:	e8 21 15 00 00       	call   801df4 <_panic>
  8008d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8008da:	e8 21 fe ff ff       	call   800700 <block_is_free>
  8008df:	85 c0                	test   %eax,%eax
  8008e1:	74 24                	je     800907 <check_bitmap+0xc0>
  8008e3:	c7 44 24 0c b4 42 80 	movl   $0x8042b4,0xc(%esp)
  8008ea:	00 
  8008eb:	c7 44 24 08 fd 40 80 	movl   $0x8040fd,0x8(%esp)
  8008f2:	00 
  8008f3:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  8008fa:	00 
  8008fb:	c7 04 24 86 42 80 00 	movl   $0x804286,(%esp)
  800902:	e8 ed 14 00 00       	call   801df4 <_panic>
  800907:	c7 04 24 c6 42 80 00 	movl   $0x8042c6,(%esp)
  80090e:	e8 ae 15 00 00       	call   801ec1 <cprintf>
  800913:	83 c4 10             	add    $0x10,%esp
  800916:	5b                   	pop    %ebx
  800917:	5e                   	pop    %esi
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <check_super>:
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	83 ec 18             	sub    $0x18,%esp
  800920:	a1 a4 c0 80 00       	mov    0x80c0a4,%eax
  800925:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  80092b:	74 1c                	je     800949 <check_super+0x2f>
  80092d:	c7 44 24 08 d6 42 80 	movl   $0x8042d6,0x8(%esp)
  800934:	00 
  800935:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80093c:	00 
  80093d:	c7 04 24 86 42 80 00 	movl   $0x804286,(%esp)
  800944:	e8 ab 14 00 00       	call   801df4 <_panic>
  800949:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  800950:	76 1c                	jbe    80096e <check_super+0x54>
  800952:	c7 44 24 08 f3 42 80 	movl   $0x8042f3,0x8(%esp)
  800959:	00 
  80095a:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800961:	00 
  800962:	c7 04 24 86 42 80 00 	movl   $0x804286,(%esp)
  800969:	e8 86 14 00 00       	call   801df4 <_panic>
  80096e:	c7 04 24 0c 43 80 00 	movl   $0x80430c,(%esp)
  800975:	e8 47 15 00 00       	call   801ec1 <cprintf>
  80097a:	c9                   	leave  
  80097b:	c3                   	ret    

0080097c <file_block_walk>:
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	83 ec 18             	sub    $0x18,%esp
  800982:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800985:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800988:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  80098b:	89 c6                	mov    %eax,%esi
  80098d:	89 d3                	mov    %edx,%ebx
  80098f:	89 cf                	mov    %ecx,%edi
  800991:	83 fa 09             	cmp    $0x9,%edx
  800994:	77 10                	ja     8009a6 <file_block_walk+0x2a>
  800996:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
  80099d:	89 01                	mov    %eax,(%ecx)
  80099f:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a4:	eb 78                	jmp    800a1e <file_block_walk+0xa2>
  8009a6:	8d 42 f6             	lea    0xfffffff6(%edx),%eax
  8009a9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8009ae:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8009b3:	77 69                	ja     800a1e <file_block_walk+0xa2>
  8009b5:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  8009bb:	85 c0                	test   %eax,%eax
  8009bd:	75 4c                	jne    800a0b <file_block_walk+0x8f>
  8009bf:	ba f5 ff ff ff       	mov    $0xfffffff5,%edx
  8009c4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8009c8:	74 54                	je     800a1e <file_block_walk+0xa2>
  8009ca:	e8 c3 fd ff ff       	call   800792 <alloc_block>
  8009cf:	ba f7 ff ff ff       	mov    $0xfffffff7,%edx
  8009d4:	85 c0                	test   %eax,%eax
  8009d6:	78 46                	js     800a1e <file_block_walk+0xa2>
  8009d8:	89 86 b0 00 00 00    	mov    %eax,0xb0(%esi)
  8009de:	89 04 24             	mov    %eax,(%esp)
  8009e1:	e8 12 f9 ff ff       	call   8002f8 <diskaddr>
  8009e6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8009ed:	00 
  8009ee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009f5:	00 
  8009f6:	89 04 24             	mov    %eax,(%esp)
  8009f9:	e8 f3 1c 00 00       	call   8026f1 <memset>
  8009fe:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  800a04:	ba 00 00 00 00       	mov    $0x0,%edx
  800a09:	eb 13                	jmp    800a1e <file_block_walk+0xa2>
  800a0b:	89 04 24             	mov    %eax,(%esp)
  800a0e:	e8 e5 f8 ff ff       	call   8002f8 <diskaddr>
  800a13:	8d 44 98 d8          	lea    0xffffffd8(%eax,%ebx,4),%eax
  800a17:	89 07                	mov    %eax,(%edi)
  800a19:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1e:	89 d0                	mov    %edx,%eax
  800a20:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800a23:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800a26:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800a29:	89 ec                	mov    %ebp,%esp
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <file_flush>:
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	57                   	push   %edi
  800a31:	56                   	push   %esi
  800a32:	53                   	push   %ebx
  800a33:	83 ec 1c             	sub    $0x1c,%esp
  800a36:	8b 75 08             	mov    0x8(%ebp),%esi
  800a39:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  800a3f:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800a45:	89 d0                	mov    %edx,%eax
  800a47:	c1 f8 1f             	sar    $0x1f,%eax
  800a4a:	c1 e8 14             	shr    $0x14,%eax
  800a4d:	01 d0                	add    %edx,%eax
  800a4f:	c1 f8 0c             	sar    $0xc,%eax
  800a52:	85 c0                	test   %eax,%eax
  800a54:	7e 5b                	jle    800ab1 <file_flush+0x84>
  800a56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a5b:	8d 7d f0             	lea    0xfffffff0(%ebp),%edi
  800a5e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a65:	89 f9                	mov    %edi,%ecx
  800a67:	89 da                	mov    %ebx,%edx
  800a69:	89 f0                	mov    %esi,%eax
  800a6b:	e8 0c ff ff ff       	call   80097c <file_block_walk>
  800a70:	85 c0                	test   %eax,%eax
  800a72:	78 1d                	js     800a91 <file_flush+0x64>
  800a74:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800a77:	85 c0                	test   %eax,%eax
  800a79:	74 16                	je     800a91 <file_flush+0x64>
  800a7b:	8b 00                	mov    (%eax),%eax
  800a7d:	85 c0                	test   %eax,%eax
  800a7f:	74 10                	je     800a91 <file_flush+0x64>
  800a81:	89 04 24             	mov    %eax,(%esp)
  800a84:	e8 6f f8 ff ff       	call   8002f8 <diskaddr>
  800a89:	89 04 24             	mov    %eax,(%esp)
  800a8c:	e8 cb f9 ff ff       	call   80045c <flush_block>
  800a91:	83 c3 01             	add    $0x1,%ebx
  800a94:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  800a9a:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800aa0:	89 d0                	mov    %edx,%eax
  800aa2:	c1 f8 1f             	sar    $0x1f,%eax
  800aa5:	c1 e8 14             	shr    $0x14,%eax
  800aa8:	01 d0                	add    %edx,%eax
  800aaa:	c1 f8 0c             	sar    $0xc,%eax
  800aad:	39 d8                	cmp    %ebx,%eax
  800aaf:	7f ad                	jg     800a5e <file_flush+0x31>
  800ab1:	89 34 24             	mov    %esi,(%esp)
  800ab4:	e8 a3 f9 ff ff       	call   80045c <flush_block>
  800ab9:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800abf:	85 c0                	test   %eax,%eax
  800ac1:	74 10                	je     800ad3 <file_flush+0xa6>
  800ac3:	89 04 24             	mov    %eax,(%esp)
  800ac6:	e8 2d f8 ff ff       	call   8002f8 <diskaddr>
  800acb:	89 04 24             	mov    %eax,(%esp)
  800ace:	e8 89 f9 ff ff       	call   80045c <flush_block>
  800ad3:	83 c4 1c             	add    $0x1c,%esp
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <file_truncate_blocks>:
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
  800ae1:	83 ec 1c             	sub    $0x1c,%esp
  800ae4:	89 c6                	mov    %eax,%esi
  800ae6:	8b 88 80 00 00 00    	mov    0x80(%eax),%ecx
  800aec:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
  800af2:	89 c8                	mov    %ecx,%eax
  800af4:	c1 f8 1f             	sar    $0x1f,%eax
  800af7:	c1 e8 14             	shr    $0x14,%eax
  800afa:	01 c8                	add    %ecx,%eax
  800afc:	89 c1                	mov    %eax,%ecx
  800afe:	c1 f9 0c             	sar    $0xc,%ecx
  800b01:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800b07:	89 d0                	mov    %edx,%eax
  800b09:	c1 f8 1f             	sar    $0x1f,%eax
  800b0c:	c1 e8 14             	shr    $0x14,%eax
  800b0f:	01 d0                	add    %edx,%eax
  800b11:	c1 f8 0c             	sar    $0xc,%eax
  800b14:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800b17:	39 c1                	cmp    %eax,%ecx
  800b19:	76 4e                	jbe    800b69 <file_truncate_blocks+0x8e>
  800b1b:	89 c3                	mov    %eax,%ebx
  800b1d:	89 cf                	mov    %ecx,%edi
  800b1f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b26:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
  800b29:	89 da                	mov    %ebx,%edx
  800b2b:	89 f0                	mov    %esi,%eax
  800b2d:	e8 4a fe ff ff       	call   80097c <file_block_walk>
  800b32:	85 c0                	test   %eax,%eax
  800b34:	78 1c                	js     800b52 <file_truncate_blocks+0x77>
  800b36:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800b39:	8b 00                	mov    (%eax),%eax
  800b3b:	85 c0                	test   %eax,%eax
  800b3d:	74 23                	je     800b62 <file_truncate_blocks+0x87>
  800b3f:	89 04 24             	mov    %eax,(%esp)
  800b42:	e8 b9 fc ff ff       	call   800800 <free_block>
  800b47:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800b4a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800b50:	eb 10                	jmp    800b62 <file_truncate_blocks+0x87>
  800b52:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b56:	c7 04 24 20 43 80 00 	movl   $0x804320,(%esp)
  800b5d:	e8 5f 13 00 00       	call   801ec1 <cprintf>
  800b62:	83 c3 01             	add    $0x1,%ebx
  800b65:	39 fb                	cmp    %edi,%ebx
  800b67:	75 b6                	jne    800b1f <file_truncate_blocks+0x44>
  800b69:	83 7d e0 0a          	cmpl   $0xa,0xffffffe0(%ebp)
  800b6d:	77 1c                	ja     800b8b <file_truncate_blocks+0xb0>
  800b6f:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800b75:	85 c0                	test   %eax,%eax
  800b77:	74 12                	je     800b8b <file_truncate_blocks+0xb0>
  800b79:	89 04 24             	mov    %eax,(%esp)
  800b7c:	e8 7f fc ff ff       	call   800800 <free_block>
  800b81:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800b88:	00 00 00 
  800b8b:	83 c4 1c             	add    $0x1c,%esp
  800b8e:	5b                   	pop    %ebx
  800b8f:	5e                   	pop    %esi
  800b90:	5f                   	pop    %edi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <file_set_size>:
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	83 ec 18             	sub    $0x18,%esp
  800b99:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  800b9c:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  800b9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ba2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba5:	39 b3 80 00 00 00    	cmp    %esi,0x80(%ebx)
  800bab:	7e 09                	jle    800bb6 <file_set_size+0x23>
  800bad:	89 f2                	mov    %esi,%edx
  800baf:	89 d8                	mov    %ebx,%eax
  800bb1:	e8 25 ff ff ff       	call   800adb <file_truncate_blocks>
  800bb6:	89 b3 80 00 00 00    	mov    %esi,0x80(%ebx)
  800bbc:	89 1c 24             	mov    %ebx,(%esp)
  800bbf:	e8 98 f8 ff ff       	call   80045c <flush_block>
  800bc4:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc9:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  800bcc:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  800bcf:	89 ec                	mov    %ebp,%esp
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <file_get_block>:
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	83 ec 28             	sub    $0x28,%esp
  800bd9:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800bdc:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800bdf:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800be2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800be5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bed:	81 fe 09 04 00 00    	cmp    $0x409,%esi
  800bf3:	0f 87 ae 00 00 00    	ja     800ca7 <file_get_block+0xd4>
  800bf9:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
  800bfc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800c03:	89 f2                	mov    %esi,%edx
  800c05:	89 f8                	mov    %edi,%eax
  800c07:	e8 70 fd ff ff       	call   80097c <file_block_walk>
  800c0c:	85 c0                	test   %eax,%eax
  800c0e:	0f 88 93 00 00 00    	js     800ca7 <file_get_block+0xd4>
  800c14:	8b 5d f0             	mov    0xfffffff0(%ebp),%ebx
  800c17:	85 db                	test   %ebx,%ebx
  800c19:	74 1a                	je     800c35 <file_get_block+0x62>
  800c1b:	8b 03                	mov    (%ebx),%eax
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	74 14                	je     800c35 <file_get_block+0x62>
  800c21:	89 04 24             	mov    %eax,(%esp)
  800c24:	e8 cf f6 ff ff       	call   8002f8 <diskaddr>
  800c29:	8b 55 10             	mov    0x10(%ebp),%edx
  800c2c:	89 02                	mov    %eax,(%edx)
  800c2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c33:	eb 72                	jmp    800ca7 <file_get_block+0xd4>
  800c35:	e8 58 fb ff ff       	call   800792 <alloc_block>
  800c3a:	89 03                	mov    %eax,(%ebx)
  800c3c:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800c3f:	8b 00                	mov    (%eax),%eax
  800c41:	89 04 24             	mov    %eax,(%esp)
  800c44:	e8 af f6 ff ff       	call   8002f8 <diskaddr>
  800c49:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800c50:	00 
  800c51:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c58:	00 
  800c59:	89 04 24             	mov    %eax,(%esp)
  800c5c:	e8 90 1a 00 00       	call   8026f1 <memset>
  800c61:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800c64:	8b 00                	mov    (%eax),%eax
  800c66:	89 04 24             	mov    %eax,(%esp)
  800c69:	e8 8a f6 ff ff       	call   8002f8 <diskaddr>
  800c6e:	8b 55 10             	mov    0x10(%ebp),%edx
  800c71:	89 02                	mov    %eax,(%edx)
  800c73:	83 fe 09             	cmp    $0x9,%esi
  800c76:	77 13                	ja     800c8b <file_get_block+0xb8>
  800c78:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800c7b:	8b 00                	mov    (%eax),%eax
  800c7d:	89 84 b7 88 00 00 00 	mov    %eax,0x88(%edi,%esi,4)
  800c84:	b8 00 00 00 00       	mov    $0x0,%eax
  800c89:	eb 1c                	jmp    800ca7 <file_get_block+0xd4>
  800c8b:	8b 87 b0 00 00 00    	mov    0xb0(%edi),%eax
  800c91:	89 04 24             	mov    %eax,(%esp)
  800c94:	e8 5f f6 ff ff       	call   8002f8 <diskaddr>
  800c99:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  800c9c:	8b 12                	mov    (%edx),%edx
  800c9e:	89 54 b0 d8          	mov    %edx,0xffffffd8(%eax,%esi,4)
  800ca2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca7:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800caa:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800cad:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800cb0:	89 ec                	mov    %ebp,%esp
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <file_write>:
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	83 ec 2c             	sub    $0x2c,%esp
  800cbd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800cc0:	89 5d e0             	mov    %ebx,0xffffffe0(%ebp)
  800cc3:	89 d8                	mov    %ebx,%eax
  800cc5:	03 45 10             	add    0x10(%ebp),%eax
  800cc8:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800ccb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cce:	3b 82 80 00 00 00    	cmp    0x80(%edx),%eax
  800cd4:	76 14                	jbe    800cea <file_write+0x36>
  800cd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cda:	89 14 24             	mov    %edx,(%esp)
  800cdd:	e8 b1 fe ff ff       	call   800b93 <file_set_size>
  800ce2:	85 c0                	test   %eax,%eax
  800ce4:	0f 88 80 00 00 00    	js     800d6a <file_write+0xb6>
  800cea:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800ced:	39 45 e0             	cmp    %eax,0xffffffe0(%ebp)
  800cf0:	73 75                	jae    800d67 <file_write+0xb3>
  800cf2:	89 de                	mov    %ebx,%esi
  800cf4:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  800cf7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cfb:	89 f0                	mov    %esi,%eax
  800cfd:	c1 f8 1f             	sar    $0x1f,%eax
  800d00:	89 c7                	mov    %eax,%edi
  800d02:	c1 ef 14             	shr    $0x14,%edi
  800d05:	8d 1c 37             	lea    (%edi,%esi,1),%ebx
  800d08:	89 d8                	mov    %ebx,%eax
  800d0a:	c1 f8 0c             	sar    $0xc,%eax
  800d0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d11:	8b 55 08             	mov    0x8(%ebp),%edx
  800d14:	89 14 24             	mov    %edx,(%esp)
  800d17:	e8 b7 fe ff ff       	call   800bd3 <file_get_block>
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	78 4a                	js     800d6a <file_write+0xb6>
  800d20:	89 d8                	mov    %ebx,%eax
  800d22:	25 ff 0f 00 00       	and    $0xfff,%eax
  800d27:	89 c2                	mov    %eax,%edx
  800d29:	29 fa                	sub    %edi,%edx
  800d2b:	b8 00 10 00 00       	mov    $0x1000,%eax
  800d30:	89 c3                	mov    %eax,%ebx
  800d32:	29 d3                	sub    %edx,%ebx
  800d34:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800d37:	2b 45 e0             	sub    0xffffffe0(%ebp),%eax
  800d3a:	39 c3                	cmp    %eax,%ebx
  800d3c:	76 02                	jbe    800d40 <file_write+0x8c>
  800d3e:	89 c3                	mov    %eax,%ebx
  800d40:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d44:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d47:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d4b:	89 d0                	mov    %edx,%eax
  800d4d:	03 45 f0             	add    0xfffffff0(%ebp),%eax
  800d50:	89 04 24             	mov    %eax,(%esp)
  800d53:	e8 f2 19 00 00       	call   80274a <memmove>
  800d58:	01 de                	add    %ebx,%esi
  800d5a:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
  800d5d:	39 75 dc             	cmp    %esi,0xffffffdc(%ebp)
  800d60:	76 05                	jbe    800d67 <file_write+0xb3>
  800d62:	01 5d 0c             	add    %ebx,0xc(%ebp)
  800d65:	eb 8d                	jmp    800cf4 <file_write+0x40>
  800d67:	8b 45 10             	mov    0x10(%ebp),%eax
  800d6a:	83 c4 2c             	add    $0x2c,%esp
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <file_read>:
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
  800d78:	83 ec 2c             	sub    $0x2c,%esp
  800d7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7e:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800d81:	8b 45 08             	mov    0x8(%ebp),%eax
  800d84:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
  800d8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d8f:	39 ca                	cmp    %ecx,%edx
  800d91:	0f 8e 95 00 00 00    	jle    800e2c <file_read+0xba>
  800d97:	29 ca                	sub    %ecx,%edx
  800d99:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  800d9c:	39 da                	cmp    %ebx,%edx
  800d9e:	76 03                	jbe    800da3 <file_read+0x31>
  800da0:	89 5d e0             	mov    %ebx,0xffffffe0(%ebp)
  800da3:	89 4d dc             	mov    %ecx,0xffffffdc(%ebp)
  800da6:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800da9:	01 c8                	add    %ecx,%eax
  800dab:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800dae:	39 c8                	cmp    %ecx,%eax
  800db0:	76 77                	jbe    800e29 <file_read+0xb7>
  800db2:	89 ce                	mov    %ecx,%esi
  800db4:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  800db7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dbb:	89 f0                	mov    %esi,%eax
  800dbd:	c1 f8 1f             	sar    $0x1f,%eax
  800dc0:	89 c7                	mov    %eax,%edi
  800dc2:	c1 ef 14             	shr    $0x14,%edi
  800dc5:	8d 1c 37             	lea    (%edi,%esi,1),%ebx
  800dc8:	89 d8                	mov    %ebx,%eax
  800dca:	c1 f8 0c             	sar    $0xc,%eax
  800dcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd4:	89 04 24             	mov    %eax,(%esp)
  800dd7:	e8 f7 fd ff ff       	call   800bd3 <file_get_block>
  800ddc:	85 c0                	test   %eax,%eax
  800dde:	78 4c                	js     800e2c <file_read+0xba>
  800de0:	89 d8                	mov    %ebx,%eax
  800de2:	25 ff 0f 00 00       	and    $0xfff,%eax
  800de7:	89 c2                	mov    %eax,%edx
  800de9:	29 fa                	sub    %edi,%edx
  800deb:	b8 00 10 00 00       	mov    $0x1000,%eax
  800df0:	89 c3                	mov    %eax,%ebx
  800df2:	29 d3                	sub    %edx,%ebx
  800df4:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800df7:	2b 45 dc             	sub    0xffffffdc(%ebp),%eax
  800dfa:	39 c3                	cmp    %eax,%ebx
  800dfc:	76 02                	jbe    800e00 <file_read+0x8e>
  800dfe:	89 c3                	mov    %eax,%ebx
  800e00:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e04:	89 d0                	mov    %edx,%eax
  800e06:	03 45 f0             	add    0xfffffff0(%ebp),%eax
  800e09:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e10:	89 04 24             	mov    %eax,(%esp)
  800e13:	e8 32 19 00 00       	call   80274a <memmove>
  800e18:	01 de                	add    %ebx,%esi
  800e1a:	89 75 dc             	mov    %esi,0xffffffdc(%ebp)
  800e1d:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800e20:	39 c6                	cmp    %eax,%esi
  800e22:	73 05                	jae    800e29 <file_read+0xb7>
  800e24:	01 5d 0c             	add    %ebx,0xc(%ebp)
  800e27:	eb 8b                	jmp    800db4 <file_read+0x42>
  800e29:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800e2c:	83 c4 2c             	add    $0x2c,%esp
  800e2f:	5b                   	pop    %ebx
  800e30:	5e                   	pop    %esi
  800e31:	5f                   	pop    %edi
  800e32:	5d                   	pop    %ebp
  800e33:	c3                   	ret    

00800e34 <walk_path>:
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	57                   	push   %edi
  800e38:	56                   	push   %esi
  800e39:	53                   	push   %ebx
  800e3a:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  800e40:	89 95 4c ff ff ff    	mov    %edx,0xffffff4c(%ebp)
  800e46:	89 8d 48 ff ff ff    	mov    %ecx,0xffffff48(%ebp)
  800e4c:	e8 ee f8 ff ff       	call   80073f <skip_slash>
  800e51:	89 85 60 ff ff ff    	mov    %eax,0xffffff60(%ebp)
  800e57:	a1 a4 c0 80 00       	mov    0x80c0a4,%eax
  800e5c:	83 c0 08             	add    $0x8,%eax
  800e5f:	89 85 5c ff ff ff    	mov    %eax,0xffffff5c(%ebp)
  800e65:	c6 85 74 ff ff ff 00 	movb   $0x0,0xffffff74(%ebp)
  800e6c:	83 bd 4c ff ff ff 00 	cmpl   $0x0,0xffffff4c(%ebp)
  800e73:	74 0c                	je     800e81 <walk_path+0x4d>
  800e75:	8b 95 4c ff ff ff    	mov    0xffffff4c(%ebp),%edx
  800e7b:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
  800e81:	8b 85 48 ff ff ff    	mov    0xffffff48(%ebp),%eax
  800e87:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800e8d:	8b b5 5c ff ff ff    	mov    0xffffff5c(%ebp),%esi
  800e93:	b8 00 00 00 00       	mov    $0x0,%eax
  800e98:	8b 95 60 ff ff ff    	mov    0xffffff60(%ebp),%edx
  800e9e:	80 3a 00             	cmpb   $0x0,(%edx)
  800ea1:	0f 84 cc 01 00 00    	je     801073 <walk_path+0x23f>
  800ea7:	8b 95 60 ff ff ff    	mov    0xffffff60(%ebp),%edx
  800ead:	0f b6 02             	movzbl (%edx),%eax
  800eb0:	3c 2f                	cmp    $0x2f,%al
  800eb2:	74 06                	je     800eba <walk_path+0x86>
  800eb4:	89 d6                	mov    %edx,%esi
  800eb6:	84 c0                	test   %al,%al
  800eb8:	75 08                	jne    800ec2 <walk_path+0x8e>
  800eba:	8b b5 60 ff ff ff    	mov    0xffffff60(%ebp),%esi
  800ec0:	eb 0e                	jmp    800ed0 <walk_path+0x9c>
  800ec2:	83 c6 01             	add    $0x1,%esi
  800ec5:	0f b6 06             	movzbl (%esi),%eax
  800ec8:	3c 2f                	cmp    $0x2f,%al
  800eca:	74 04                	je     800ed0 <walk_path+0x9c>
  800ecc:	84 c0                	test   %al,%al
  800ece:	75 f2                	jne    800ec2 <walk_path+0x8e>
  800ed0:	89 f3                	mov    %esi,%ebx
  800ed2:	2b 9d 60 ff ff ff    	sub    0xffffff60(%ebp),%ebx
  800ed8:	83 fb 7f             	cmp    $0x7f,%ebx
  800edb:	0f 8f b2 01 00 00    	jg     801093 <walk_path+0x25f>
  800ee1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ee5:	8b 85 60 ff ff ff    	mov    0xffffff60(%ebp),%eax
  800eeb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eef:	8d 85 74 ff ff ff    	lea    0xffffff74(%ebp),%eax
  800ef5:	89 04 24             	mov    %eax,(%esp)
  800ef8:	e8 4d 18 00 00       	call   80274a <memmove>
  800efd:	c6 84 1d 74 ff ff ff 	movb   $0x0,0xffffff74(%ebp,%ebx,1)
  800f04:	00 
  800f05:	89 f0                	mov    %esi,%eax
  800f07:	e8 33 f8 ff ff       	call   80073f <skip_slash>
  800f0c:	89 85 60 ff ff ff    	mov    %eax,0xffffff60(%ebp)
  800f12:	8b 95 5c ff ff ff    	mov    0xffffff5c(%ebp),%edx
  800f18:	83 ba 84 00 00 00 01 	cmpl   $0x1,0x84(%edx)
  800f1f:	0f 85 75 01 00 00    	jne    80109a <walk_path+0x266>
  800f25:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  800f2b:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
  800f31:	74 24                	je     800f57 <walk_path+0x123>
  800f33:	c7 44 24 0c 3d 43 80 	movl   $0x80433d,0xc(%esp)
  800f3a:	00 
  800f3b:	c7 44 24 08 fd 40 80 	movl   $0x8040fd,0x8(%esp)
  800f42:	00 
  800f43:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
  800f4a:	00 
  800f4b:	c7 04 24 86 42 80 00 	movl   $0x804286,(%esp)
  800f52:	e8 9d 0e 00 00       	call   801df4 <_panic>
  800f57:	89 d0                	mov    %edx,%eax
  800f59:	c1 f8 1f             	sar    $0x1f,%eax
  800f5c:	c1 e8 14             	shr    $0x14,%eax
  800f5f:	01 d0                	add    %edx,%eax
  800f61:	c1 f8 0c             	sar    $0xc,%eax
  800f64:	89 85 54 ff ff ff    	mov    %eax,0xffffff54(%ebp)
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	0f 84 ab 00 00 00    	je     80101d <walk_path+0x1e9>
  800f72:	c7 85 58 ff ff ff 00 	movl   $0x0,0xffffff58(%ebp)
  800f79:	00 00 00 
  800f7c:	8d 85 70 ff ff ff    	lea    0xffffff70(%ebp),%eax
  800f82:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f86:	8b 95 58 ff ff ff    	mov    0xffffff58(%ebp),%edx
  800f8c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f90:	8b 85 5c ff ff ff    	mov    0xffffff5c(%ebp),%eax
  800f96:	89 04 24             	mov    %eax,(%esp)
  800f99:	e8 35 fc ff ff       	call   800bd3 <file_get_block>
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	78 72                	js     801014 <walk_path+0x1e0>
  800fa2:	8b 95 70 ff ff ff    	mov    0xffffff70(%ebp),%edx
  800fa8:	89 95 50 ff ff ff    	mov    %edx,0xffffff50(%ebp)
  800fae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb3:	8d bd 74 ff ff ff    	lea    0xffffff74(%ebp),%edi
  800fb9:	8b 85 50 ff ff ff    	mov    0xffffff50(%ebp),%eax
  800fbf:	8d 34 03             	lea    (%ebx,%eax,1),%esi
  800fc2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fc6:	89 34 24             	mov    %esi,(%esp)
  800fc9:	e8 57 16 00 00       	call   802625 <strcmp>
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	75 1a                	jne    800fec <walk_path+0x1b8>
  800fd2:	8b 95 60 ff ff ff    	mov    0xffffff60(%ebp),%edx
  800fd8:	80 3a 00             	cmpb   $0x0,(%edx)
  800fdb:	0f 84 8c 00 00 00    	je     80106d <walk_path+0x239>
  800fe1:	89 b5 5c ff ff ff    	mov    %esi,0xffffff5c(%ebp)
  800fe7:	e9 bb fe ff ff       	jmp    800ea7 <walk_path+0x73>
  800fec:	81 c3 00 01 00 00    	add    $0x100,%ebx
  800ff2:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  800ff8:	75 bf                	jne    800fb9 <walk_path+0x185>
  800ffa:	83 85 58 ff ff ff 01 	addl   $0x1,0xffffff58(%ebp)
  801001:	8b 85 58 ff ff ff    	mov    0xffffff58(%ebp),%eax
  801007:	39 85 54 ff ff ff    	cmp    %eax,0xffffff54(%ebp)
  80100d:	74 0e                	je     80101d <walk_path+0x1e9>
  80100f:	e9 68 ff ff ff       	jmp    800f7c <walk_path+0x148>
  801014:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801017:	0f 85 82 00 00 00    	jne    80109f <walk_path+0x26b>
  80101d:	8b 95 60 ff ff ff    	mov    0xffffff60(%ebp),%edx
  801023:	80 3a 00             	cmpb   $0x0,(%edx)
  801026:	75 72                	jne    80109a <walk_path+0x266>
  801028:	83 bd 4c ff ff ff 00 	cmpl   $0x0,0xffffff4c(%ebp)
  80102f:	74 0e                	je     80103f <walk_path+0x20b>
  801031:	8b 95 5c ff ff ff    	mov    0xffffff5c(%ebp),%edx
  801037:	8b 85 4c ff ff ff    	mov    0xffffff4c(%ebp),%eax
  80103d:	89 10                	mov    %edx,(%eax)
  80103f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801043:	74 15                	je     80105a <walk_path+0x226>
  801045:	8d 85 74 ff ff ff    	lea    0xffffff74(%ebp),%eax
  80104b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80104f:	8b 45 08             	mov    0x8(%ebp),%eax
  801052:	89 04 24             	mov    %eax,(%esp)
  801055:	e8 e7 14 00 00       	call   802541 <strcpy>
  80105a:	8b 95 48 ff ff ff    	mov    0xffffff48(%ebp),%edx
  801060:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
  801066:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  80106b:	eb 32                	jmp    80109f <walk_path+0x26b>
  80106d:	8b 85 5c ff ff ff    	mov    0xffffff5c(%ebp),%eax
  801073:	83 bd 4c ff ff ff 00 	cmpl   $0x0,0xffffff4c(%ebp)
  80107a:	74 08                	je     801084 <walk_path+0x250>
  80107c:	8b 95 4c ff ff ff    	mov    0xffffff4c(%ebp),%edx
  801082:	89 02                	mov    %eax,(%edx)
  801084:	8b 85 48 ff ff ff    	mov    0xffffff48(%ebp),%eax
  80108a:	89 30                	mov    %esi,(%eax)
  80108c:	b8 00 00 00 00       	mov    $0x0,%eax
  801091:	eb 0c                	jmp    80109f <walk_path+0x26b>
  801093:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801098:	eb 05                	jmp    80109f <walk_path+0x26b>
  80109a:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  80109f:	81 c4 bc 00 00 00    	add    $0xbc,%esp
  8010a5:	5b                   	pop    %ebx
  8010a6:	5e                   	pop    %esi
  8010a7:	5f                   	pop    %edi
  8010a8:	5d                   	pop    %ebp
  8010a9:	c3                   	ret    

008010aa <file_remove>:
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	83 ec 18             	sub    $0x18,%esp
  8010b0:	8d 4d fc             	lea    0xfffffffc(%ebp),%ecx
  8010b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8010bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c2:	e8 6d fd ff ff       	call   800e34 <walk_path>
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	78 30                	js     8010fb <file_remove+0x51>
  8010cb:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  8010ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d3:	e8 03 fa ff ff       	call   800adb <file_truncate_blocks>
  8010d8:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  8010db:	c6 00 00             	movb   $0x0,(%eax)
  8010de:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  8010e1:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  8010e8:	00 00 00 
  8010eb:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  8010ee:	89 04 24             	mov    %eax,(%esp)
  8010f1:	e8 66 f3 ff ff       	call   80045c <flush_block>
  8010f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fb:	c9                   	leave  
  8010fc:	c3                   	ret    

008010fd <file_open>:
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
  801100:	83 ec 08             	sub    $0x8,%esp
  801103:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80110a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80110d:	ba 00 00 00 00       	mov    $0x0,%edx
  801112:	8b 45 08             	mov    0x8(%ebp),%eax
  801115:	e8 1a fd ff ff       	call   800e34 <walk_path>
  80111a:	c9                   	leave  
  80111b:	c3                   	ret    

0080111c <file_create>:
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	81 ec b8 00 00 00    	sub    $0xb8,%esp
  801125:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801128:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  80112b:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  80112e:	8d 8d 6c ff ff ff    	lea    0xffffff6c(%ebp),%ecx
  801134:	8d 95 70 ff ff ff    	lea    0xffffff70(%ebp),%edx
  80113a:	8d 85 74 ff ff ff    	lea    0xffffff74(%ebp),%eax
  801140:	89 04 24             	mov    %eax,(%esp)
  801143:	8b 45 08             	mov    0x8(%ebp),%eax
  801146:	e8 e9 fc ff ff       	call   800e34 <walk_path>
  80114b:	89 c3                	mov    %eax,%ebx
  80114d:	85 c0                	test   %eax,%eax
  80114f:	0f 84 f5 00 00 00    	je     80124a <file_create+0x12e>
  801155:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801158:	0f 85 2f 01 00 00    	jne    80128d <file_create+0x171>
  80115e:	8b b5 70 ff ff ff    	mov    0xffffff70(%ebp),%esi
  801164:	85 f6                	test   %esi,%esi
  801166:	0f 84 21 01 00 00    	je     80128d <file_create+0x171>
  80116c:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  801172:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
  801178:	74 24                	je     80119e <file_create+0x82>
  80117a:	c7 44 24 0c 3d 43 80 	movl   $0x80433d,0xc(%esp)
  801181:	00 
  801182:	c7 44 24 08 fd 40 80 	movl   $0x8040fd,0x8(%esp)
  801189:	00 
  80118a:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
  801191:	00 
  801192:	c7 04 24 86 42 80 00 	movl   $0x804286,(%esp)
  801199:	e8 56 0c 00 00       	call   801df4 <_panic>
  80119e:	89 d0                	mov    %edx,%eax
  8011a0:	c1 f8 1f             	sar    $0x1f,%eax
  8011a3:	c1 e8 14             	shr    $0x14,%eax
  8011a6:	01 d0                	add    %edx,%eax
  8011a8:	89 c7                	mov    %eax,%edi
  8011aa:	c1 ff 0c             	sar    $0xc,%edi
  8011ad:	c7 85 60 ff ff ff 00 	movl   $0x0,0xffffff60(%ebp)
  8011b4:	00 00 00 
  8011b7:	85 ff                	test   %edi,%edi
  8011b9:	74 57                	je     801212 <file_create+0xf6>
  8011bb:	c7 85 60 ff ff ff 00 	movl   $0x0,0xffffff60(%ebp)
  8011c2:	00 00 00 
  8011c5:	8d 85 68 ff ff ff    	lea    0xffffff68(%ebp),%eax
  8011cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011cf:	8b 85 60 ff ff ff    	mov    0xffffff60(%ebp),%eax
  8011d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d9:	89 34 24             	mov    %esi,(%esp)
  8011dc:	e8 f2 f9 ff ff       	call   800bd3 <file_get_block>
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	0f 88 a4 00 00 00    	js     80128d <file_create+0x171>
  8011e9:	8b 85 68 ff ff ff    	mov    0xffffff68(%ebp),%eax
  8011ef:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
  8011f5:	80 38 00             	cmpb   $0x0,(%eax)
  8011f8:	74 57                	je     801251 <file_create+0x135>
  8011fa:	05 00 01 00 00       	add    $0x100,%eax
  8011ff:	39 d0                	cmp    %edx,%eax
  801201:	75 f2                	jne    8011f5 <file_create+0xd9>
  801203:	83 85 60 ff ff ff 01 	addl   $0x1,0xffffff60(%ebp)
  80120a:	3b bd 60 ff ff ff    	cmp    0xffffff60(%ebp),%edi
  801210:	75 b3                	jne    8011c5 <file_create+0xa9>
  801212:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  801219:	10 00 00 
  80121c:	8d 85 68 ff ff ff    	lea    0xffffff68(%ebp),%eax
  801222:	89 44 24 08          	mov    %eax,0x8(%esp)
  801226:	8b 85 60 ff ff ff    	mov    0xffffff60(%ebp),%eax
  80122c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801230:	89 34 24             	mov    %esi,(%esp)
  801233:	e8 9b f9 ff ff       	call   800bd3 <file_get_block>
  801238:	85 c0                	test   %eax,%eax
  80123a:	78 51                	js     80128d <file_create+0x171>
  80123c:	8b 85 68 ff ff ff    	mov    0xffffff68(%ebp),%eax
  801242:	89 85 6c ff ff ff    	mov    %eax,0xffffff6c(%ebp)
  801248:	eb 0d                	jmp    801257 <file_create+0x13b>
  80124a:	bb f3 ff ff ff       	mov    $0xfffffff3,%ebx
  80124f:	eb 3c                	jmp    80128d <file_create+0x171>
  801251:	89 85 6c ff ff ff    	mov    %eax,0xffffff6c(%ebp)
  801257:	8d 85 74 ff ff ff    	lea    0xffffff74(%ebp),%eax
  80125d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801261:	8b 85 6c ff ff ff    	mov    0xffffff6c(%ebp),%eax
  801267:	89 04 24             	mov    %eax,(%esp)
  80126a:	e8 d2 12 00 00       	call   802541 <strcpy>
  80126f:	8b 95 6c ff ff ff    	mov    0xffffff6c(%ebp),%edx
  801275:	8b 45 0c             	mov    0xc(%ebp),%eax
  801278:	89 10                	mov    %edx,(%eax)
  80127a:	8b 85 70 ff ff ff    	mov    0xffffff70(%ebp),%eax
  801280:	89 04 24             	mov    %eax,(%esp)
  801283:	e8 a5 f7 ff ff       	call   800a2d <file_flush>
  801288:	bb 00 00 00 00       	mov    $0x0,%ebx
  80128d:	89 d8                	mov    %ebx,%eax
  80128f:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801292:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801295:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801298:	89 ec                	mov    %ebp,%esp
  80129a:	5d                   	pop    %ebp
  80129b:	c3                   	ret    

0080129c <fs_init>:
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	83 ec 08             	sub    $0x8,%esp
  8012a2:	e8 fd ed ff ff       	call   8000a4 <ide_probe_disk1>
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	74 0e                	je     8012b9 <fs_init+0x1d>
  8012ab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8012b2:	e8 bc ed ff ff       	call   800073 <ide_set_disk>
  8012b7:	eb 0c                	jmp    8012c5 <fs_init+0x29>
  8012b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012c0:	e8 ae ed ff ff       	call   800073 <ide_set_disk>
  8012c5:	e8 62 f2 ff ff       	call   80052c <bc_init>
  8012ca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8012d1:	e8 22 f0 ff ff       	call   8002f8 <diskaddr>
  8012d6:	a3 a4 c0 80 00       	mov    %eax,0x80c0a4
  8012db:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8012e2:	e8 11 f0 ff ff       	call   8002f8 <diskaddr>
  8012e7:	a3 a0 c0 80 00       	mov    %eax,0x80c0a0
  8012ec:	e8 29 f6 ff ff       	call   80091a <check_super>
  8012f1:	e8 51 f5 ff ff       	call   800847 <check_bitmap>
  8012f6:	c9                   	leave  
  8012f7:	c3                   	ret    
	...

00801300 <serve_init>:
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	ba 00 00 00 00       	mov    $0x0,%edx
  801308:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80130d:	b8 00 00 00 00       	mov    $0x0,%eax
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
		opentab[i].o_fileid = i;
  801312:	89 90 20 80 80 00    	mov    %edx,0x808020(%eax)
		opentab[i].o_fd = (struct Fd*) va;
  801318:	89 88 2c 80 80 00    	mov    %ecx,0x80802c(%eax)
		va += PGSIZE;
  80131e:	81 c1 00 10 00 00    	add    $0x1000,%ecx
  801324:	83 c2 01             	add    $0x1,%edx
  801327:	83 c0 10             	add    $0x10,%eax
  80132a:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801330:	75 e0                	jne    801312 <serve_init+0x12>
	}
}
  801332:	5d                   	pop    %ebp
  801333:	c3                   	ret    

00801334 <serve_sync>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
		switch (pageref(opentab[i].o_fd)) {
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
}

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) == 1 || o->o_fileid != fileid)
		return -E_INVAL;
	*po = o;
	return 0;
}

// Open req->req_path in mode req->req_omode, storing the Fd page and
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
	char path[MAXPATHLEN];
	struct File *f;
	int fileid;
	int r;
	struct OpenFile *o;

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
	path[MAXPATHLEN-1] = 0;

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
		if (debug)
			cprintf("openfile_alloc failed: %e", r);
		return r;
	}
	fileid = r;
	//cprintf("serve_open:fileid=%x\n",fileid);
	// Open the file
	if (req->req_omode & O_CREAT) {
		if ((r = file_create(path, &f)) < 0) {
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
				goto try_open;
			if (debug)
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
			if (debug)
				cprintf("file_open failed: %e", r);
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
		if ((r = file_set_size(f, 0)) < 0) {
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}

	// Save the file pointer
	o->o_file = f;

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
	o->o_fd->fd_dev_id = devfile.dev_id;
	o->o_mode = req->req_omode;

	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller
	*pg_store = o->o_fd;
	*perm_store = PTE_P|PTE_U|PTE_W;
	return 0;
}

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
	struct OpenFile *o;
	int r;

	if (debug)
		cprintf("serve_set_size %08x %08x %08x\n", envid, req->req_fileid, req->req_size);

	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
}

// Read at most ipc->read.req_n bytes from the current seek position
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
	struct Fsreq_read *req = &ipc->read;
	struct Fsret_read *ret = &ipc->readRet;

	if (debug)
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Look up the file id, read the bytes into 'ret', and update
	// the seek position.  Be careful if req->req_n > PGSIZE
	// (remember that read is always allowed to return fewer bytes
	// than requested).  Also, be careful because ipc is a union,
	// so filling in ret will overwrite req.
	//
	// Hint: Use file_read.
	// Hint: The seek position is stored in the struct Fd.
	// LAB 5: Your code here
	int r;
	struct OpenFile *o;
	size_t count;
	int retcount;
	if((r=openfile_lookup(envid,req->req_fileid,&o))<0){
		if(debug)
			cprintf("openfile_lookup failed: %e\n",r);
		return r;
	}
	if(req->req_n>PGSIZE)
		count=PGSIZE;
	else
		count=req->req_n;
	retcount=file_read(o->o_file,(void*)ret->ret_buf,count,o->o_fd->fd_offset);
	o->o_fd->fd_offset+=retcount;
	if(debug)
		cprintf("serve_read:ret_buf=%s\n",ret->ret_buf);
	return retcount;
	//panic("serve_read not implemented");
}

// Write req->req_n bytes from req->req_buf to req_fileid, starting at
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
	if (debug)
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// LAB 5: Your code here.
	int r;
	struct OpenFile *o;
	size_t count;
	int retcount;
	if((r=openfile_lookup(envid,req->req_fileid,&o))<0){
		return r;
	}
	count=req->req_n;
	retcount=file_write(o->o_file,(void*)req->req_buf,count,o->o_fd->fd_offset);
	o->o_fd->fd_offset+=retcount;
	return retcount;
	//panic("serve_write not implemented");
}

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
	struct Fsreq_stat *req = &ipc->stat;
	struct Fsret_stat *ret = &ipc->statRet;
	struct OpenFile *o;
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
	ret->ret_size = o->o_file->f_size;
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
	return 0;
}

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
	struct OpenFile *o;
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
		return r;
	file_flush(o->o_file);
	return 0;
}

// Remove the file req->req_path.
int
serve_remove(envid_t envid, struct Fsreq_remove *req)
{
	char path[MAXPATHLEN];
	int r;

	if (debug)
		cprintf("serve_remove %08x %s\n", envid, req->req_path);

	// Delete the named file.
	// Note: This request doesn't refer to an open file.

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
	path[MAXPATHLEN-1] = 0;

	// Delete the specified file
	return file_remove(path);
}

// Sync the file system.
int
serve_sync(envid_t envid, union Fsipc *req)
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
  801337:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  80133a:	e8 12 f4 ff ff       	call   800751 <fs_sync>
	return 0;
}
  80133f:	b8 00 00 00 00       	mov    $0x0,%eax
  801344:	c9                   	leave  
  801345:	c3                   	ret    

00801346 <serve_remove>:
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	53                   	push   %ebx
  80134a:	81 ec 14 04 00 00    	sub    $0x414,%esp
  801350:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  801357:	00 
  801358:	8b 45 0c             	mov    0xc(%ebp),%eax
  80135b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135f:	8d 9d fc fb ff ff    	lea    0xfffffbfc(%ebp),%ebx
  801365:	89 1c 24             	mov    %ebx,(%esp)
  801368:	e8 dd 13 00 00       	call   80274a <memmove>
  80136d:	c6 45 fb 00          	movb   $0x0,0xfffffffb(%ebp)
  801371:	89 1c 24             	mov    %ebx,(%esp)
  801374:	e8 31 fd ff ff       	call   8010aa <file_remove>
  801379:	81 c4 14 04 00 00    	add    $0x414,%esp
  80137f:	5b                   	pop    %ebx
  801380:	5d                   	pop    %ebp
  801381:	c3                   	ret    

00801382 <openfile_lookup>:
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	83 ec 18             	sub    $0x18,%esp
  801388:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  80138b:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  80138e:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801391:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801394:	89 f8                	mov    %edi,%eax
  801396:	25 ff 03 00 00       	and    $0x3ff,%eax
  80139b:	89 c3                	mov    %eax,%ebx
  80139d:	c1 e3 04             	shl    $0x4,%ebx
  8013a0:	8d b3 20 80 80 00    	lea    0x808020(%ebx),%esi
  8013a6:	8b 46 0c             	mov    0xc(%esi),%eax
  8013a9:	89 04 24             	mov    %eax,(%esp)
  8013ac:	e8 0b 25 00 00       	call   8038bc <pageref>
  8013b1:	83 f8 01             	cmp    $0x1,%eax
  8013b4:	74 14                	je     8013ca <openfile_lookup+0x48>
  8013b6:	39 bb 20 80 80 00    	cmp    %edi,0x808020(%ebx)
  8013bc:	75 0c                	jne    8013ca <openfile_lookup+0x48>
  8013be:	8b 45 10             	mov    0x10(%ebp),%eax
  8013c1:	89 30                	mov    %esi,(%eax)
  8013c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c8:	eb 05                	jmp    8013cf <openfile_lookup+0x4d>
  8013ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013cf:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  8013d2:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  8013d5:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  8013d8:	89 ec                	mov    %ebp,%esp
  8013da:	5d                   	pop    %ebp
  8013db:	c3                   	ret    

008013dc <serve_flush>:
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	83 ec 28             	sub    $0x28,%esp
  8013e2:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  8013e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ec:	8b 00                	mov    (%eax),%eax
  8013ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f5:	89 04 24             	mov    %eax,(%esp)
  8013f8:	e8 85 ff ff ff       	call   801382 <openfile_lookup>
  8013fd:	85 c0                	test   %eax,%eax
  8013ff:	78 13                	js     801414 <serve_flush+0x38>
  801401:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  801404:	8b 40 04             	mov    0x4(%eax),%eax
  801407:	89 04 24             	mov    %eax,(%esp)
  80140a:	e8 1e f6 ff ff       	call   800a2d <file_flush>
  80140f:	b8 00 00 00 00       	mov    $0x0,%eax
  801414:	c9                   	leave  
  801415:	c3                   	ret    

00801416 <serve_stat>:
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	53                   	push   %ebx
  80141a:	83 ec 24             	sub    $0x24,%esp
  80141d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801420:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801423:	89 44 24 08          	mov    %eax,0x8(%esp)
  801427:	8b 03                	mov    (%ebx),%eax
  801429:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142d:	8b 45 08             	mov    0x8(%ebp),%eax
  801430:	89 04 24             	mov    %eax,(%esp)
  801433:	e8 4a ff ff ff       	call   801382 <openfile_lookup>
  801438:	85 c0                	test   %eax,%eax
  80143a:	78 3f                	js     80147b <serve_stat+0x65>
  80143c:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  80143f:	8b 40 04             	mov    0x4(%eax),%eax
  801442:	89 44 24 04          	mov    %eax,0x4(%esp)
  801446:	89 1c 24             	mov    %ebx,(%esp)
  801449:	e8 f3 10 00 00       	call   802541 <strcpy>
  80144e:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801451:	8b 42 04             	mov    0x4(%edx),%eax
  801454:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  80145a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  801460:	8b 42 04             	mov    0x4(%edx),%eax
  801463:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  80146a:	0f 94 c0             	sete   %al
  80146d:	0f b6 c0             	movzbl %al,%eax
  801470:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801476:	b8 00 00 00 00       	mov    $0x0,%eax
  80147b:	83 c4 24             	add    $0x24,%esp
  80147e:	5b                   	pop    %ebx
  80147f:	5d                   	pop    %ebp
  801480:	c3                   	ret    

00801481 <serve_write>:
  801481:	55                   	push   %ebp
  801482:	89 e5                	mov    %esp,%ebp
  801484:	53                   	push   %ebx
  801485:	83 ec 24             	sub    $0x24,%esp
  801488:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80148b:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  80148e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801492:	8b 03                	mov    (%ebx),%eax
  801494:	89 44 24 04          	mov    %eax,0x4(%esp)
  801498:	8b 45 08             	mov    0x8(%ebp),%eax
  80149b:	89 04 24             	mov    %eax,(%esp)
  80149e:	e8 df fe ff ff       	call   801382 <openfile_lookup>
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	78 2f                	js     8014d6 <serve_write+0x55>
  8014a7:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  8014aa:	8b 42 0c             	mov    0xc(%edx),%eax
  8014ad:	8b 40 04             	mov    0x4(%eax),%eax
  8014b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014b4:	8b 43 04             	mov    0x4(%ebx),%eax
  8014b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014bb:	8d 43 08             	lea    0x8(%ebx),%eax
  8014be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c2:	8b 42 04             	mov    0x4(%edx),%eax
  8014c5:	89 04 24             	mov    %eax,(%esp)
  8014c8:	e8 e7 f7 ff ff       	call   800cb4 <file_write>
  8014cd:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  8014d0:	8b 52 0c             	mov    0xc(%edx),%edx
  8014d3:	01 42 04             	add    %eax,0x4(%edx)
  8014d6:	83 c4 24             	add    $0x24,%esp
  8014d9:	5b                   	pop    %ebx
  8014da:	5d                   	pop    %ebp
  8014db:	c3                   	ret    

008014dc <serve_read>:
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	53                   	push   %ebx
  8014e0:	83 ec 24             	sub    $0x24,%esp
  8014e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014e6:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  8014e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014ed:	8b 03                	mov    (%ebx),%eax
  8014ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f6:	89 04 24             	mov    %eax,(%esp)
  8014f9:	e8 84 fe ff ff       	call   801382 <openfile_lookup>
  8014fe:	85 c0                	test   %eax,%eax
  801500:	78 38                	js     80153a <serve_read+0x5e>
  801502:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801505:	8b 42 0c             	mov    0xc(%edx),%eax
  801508:	8b 40 04             	mov    0x4(%eax),%eax
  80150b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80150f:	8b 43 04             	mov    0x4(%ebx),%eax
  801512:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801517:	76 05                	jbe    80151e <serve_read+0x42>
  801519:	b8 00 10 00 00       	mov    $0x1000,%eax
  80151e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801522:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801526:	8b 42 04             	mov    0x4(%edx),%eax
  801529:	89 04 24             	mov    %eax,(%esp)
  80152c:	e8 41 f8 ff ff       	call   800d72 <file_read>
  801531:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801534:	8b 52 0c             	mov    0xc(%edx),%edx
  801537:	01 42 04             	add    %eax,0x4(%edx)
  80153a:	83 c4 24             	add    $0x24,%esp
  80153d:	5b                   	pop    %ebx
  80153e:	5d                   	pop    %ebp
  80153f:	c3                   	ret    

00801540 <serve_set_size>:
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	53                   	push   %ebx
  801544:	83 ec 24             	sub    $0x24,%esp
  801547:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80154a:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  80154d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801551:	8b 03                	mov    (%ebx),%eax
  801553:	89 44 24 04          	mov    %eax,0x4(%esp)
  801557:	8b 45 08             	mov    0x8(%ebp),%eax
  80155a:	89 04 24             	mov    %eax,(%esp)
  80155d:	e8 20 fe ff ff       	call   801382 <openfile_lookup>
  801562:	85 c0                	test   %eax,%eax
  801564:	78 15                	js     80157b <serve_set_size+0x3b>
  801566:	8b 43 04             	mov    0x4(%ebx),%eax
  801569:	89 44 24 04          	mov    %eax,0x4(%esp)
  80156d:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  801570:	8b 40 04             	mov    0x4(%eax),%eax
  801573:	89 04 24             	mov    %eax,(%esp)
  801576:	e8 18 f6 ff ff       	call   800b93 <file_set_size>
  80157b:	83 c4 24             	add    $0x24,%esp
  80157e:	5b                   	pop    %ebx
  80157f:	5d                   	pop    %ebp
  801580:	c3                   	ret    

00801581 <openfile_alloc>:
  801581:	55                   	push   %ebp
  801582:	89 e5                	mov    %esp,%ebp
  801584:	56                   	push   %esi
  801585:	53                   	push   %ebx
  801586:	83 ec 10             	sub    $0x10,%esp
  801589:	8b 75 08             	mov    0x8(%ebp),%esi
  80158c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801591:	89 d8                	mov    %ebx,%eax
  801593:	c1 e0 04             	shl    $0x4,%eax
  801596:	8b 80 2c 80 80 00    	mov    0x80802c(%eax),%eax
  80159c:	89 04 24             	mov    %eax,(%esp)
  80159f:	e8 18 23 00 00       	call   8038bc <pageref>
  8015a4:	85 c0                	test   %eax,%eax
  8015a6:	74 0a                	je     8015b2 <openfile_alloc+0x31>
  8015a8:	83 f8 01             	cmp    $0x1,%eax
  8015ab:	75 67                	jne    801614 <openfile_alloc+0x93>
  8015ad:	8d 76 00             	lea    0x0(%esi),%esi
  8015b0:	eb 27                	jmp    8015d9 <openfile_alloc+0x58>
  8015b2:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8015b9:	00 
  8015ba:	89 d8                	mov    %ebx,%eax
  8015bc:	c1 e0 04             	shl    $0x4,%eax
  8015bf:	8b 80 2c 80 80 00    	mov    0x80802c(%eax),%eax
  8015c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015d0:	e8 95 16 00 00       	call   802c6a <sys_page_alloc>
  8015d5:	85 c0                	test   %eax,%eax
  8015d7:	78 4f                	js     801628 <openfile_alloc+0xa7>
  8015d9:	89 da                	mov    %ebx,%edx
  8015db:	c1 e2 04             	shl    $0x4,%edx
  8015de:	81 82 20 80 80 00 00 	addl   $0x400,0x808020(%edx)
  8015e5:	04 00 00 
  8015e8:	8d 82 20 80 80 00    	lea    0x808020(%edx),%eax
  8015ee:	89 06                	mov    %eax,(%esi)
  8015f0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8015f7:	00 
  8015f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015ff:	00 
  801600:	8b 82 2c 80 80 00    	mov    0x80802c(%edx),%eax
  801606:	89 04 24             	mov    %eax,(%esp)
  801609:	e8 e3 10 00 00       	call   8026f1 <memset>
  80160e:	8b 06                	mov    (%esi),%eax
  801610:	8b 00                	mov    (%eax),%eax
  801612:	eb 14                	jmp    801628 <openfile_alloc+0xa7>
  801614:	83 c3 01             	add    $0x1,%ebx
  801617:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  80161d:	0f 85 6e ff ff ff    	jne    801591 <openfile_alloc+0x10>
  801623:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	5b                   	pop    %ebx
  80162c:	5e                   	pop    %esi
  80162d:	5d                   	pop    %ebp
  80162e:	c3                   	ret    

0080162f <serve_open>:
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	56                   	push   %esi
  801633:	53                   	push   %ebx
  801634:	81 ec 20 04 00 00    	sub    $0x420,%esp
  80163a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80163d:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  801644:	00 
  801645:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801649:	8d b5 f8 fb ff ff    	lea    0xfffffbf8(%ebp),%esi
  80164f:	89 34 24             	mov    %esi,(%esp)
  801652:	e8 f3 10 00 00       	call   80274a <memmove>
  801657:	c6 45 f7 00          	movb   $0x0,0xfffffff7(%ebp)
  80165b:	8d 85 f0 fb ff ff    	lea    0xfffffbf0(%ebp),%eax
  801661:	89 04 24             	mov    %eax,(%esp)
  801664:	e8 18 ff ff ff       	call   801581 <openfile_alloc>
  801669:	85 c0                	test   %eax,%eax
  80166b:	0f 88 e5 00 00 00    	js     801756 <serve_open+0x127>
  801671:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  801678:	74 2c                	je     8016a6 <serve_open+0x77>
  80167a:	8d 85 f4 fb ff ff    	lea    0xfffffbf4(%ebp),%eax
  801680:	89 44 24 04          	mov    %eax,0x4(%esp)
  801684:	89 34 24             	mov    %esi,(%esp)
  801687:	e8 90 fa ff ff       	call   80111c <file_create>
  80168c:	85 c0                	test   %eax,%eax
  80168e:	79 36                	jns    8016c6 <serve_open+0x97>
  801690:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  801697:	0f 85 b9 00 00 00    	jne    801756 <serve_open+0x127>
  80169d:	83 f8 f3             	cmp    $0xfffffff3,%eax
  8016a0:	0f 85 b0 00 00 00    	jne    801756 <serve_open+0x127>
  8016a6:	8d 85 f4 fb ff ff    	lea    0xfffffbf4(%ebp),%eax
  8016ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b0:	8d 85 f8 fb ff ff    	lea    0xfffffbf8(%ebp),%eax
  8016b6:	89 04 24             	mov    %eax,(%esp)
  8016b9:	e8 3f fa ff ff       	call   8010fd <file_open>
  8016be:	85 c0                	test   %eax,%eax
  8016c0:	0f 88 90 00 00 00    	js     801756 <serve_open+0x127>
  8016c6:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  8016cd:	74 1a                	je     8016e9 <serve_open+0xba>
  8016cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016d6:	00 
  8016d7:	8b 85 f4 fb ff ff    	mov    0xfffffbf4(%ebp),%eax
  8016dd:	89 04 24             	mov    %eax,(%esp)
  8016e0:	e8 ae f4 ff ff       	call   800b93 <file_set_size>
  8016e5:	85 c0                	test   %eax,%eax
  8016e7:	78 6d                	js     801756 <serve_open+0x127>
  8016e9:	8b 95 f4 fb ff ff    	mov    0xfffffbf4(%ebp),%edx
  8016ef:	8b 85 f0 fb ff ff    	mov    0xfffffbf0(%ebp),%eax
  8016f5:	89 50 04             	mov    %edx,0x4(%eax)
  8016f8:	8b 85 f0 fb ff ff    	mov    0xfffffbf0(%ebp),%eax
  8016fe:	8b 50 0c             	mov    0xc(%eax),%edx
  801701:	8b 00                	mov    (%eax),%eax
  801703:	89 42 0c             	mov    %eax,0xc(%edx)
  801706:	8b 85 f0 fb ff ff    	mov    0xfffffbf0(%ebp),%eax
  80170c:	8b 50 0c             	mov    0xc(%eax),%edx
  80170f:	8b 83 00 04 00 00    	mov    0x400(%ebx),%eax
  801715:	83 e0 03             	and    $0x3,%eax
  801718:	89 42 08             	mov    %eax,0x8(%edx)
  80171b:	8b 85 f0 fb ff ff    	mov    0xfffffbf0(%ebp),%eax
  801721:	8b 50 0c             	mov    0xc(%eax),%edx
  801724:	a1 68 c0 80 00       	mov    0x80c068,%eax
  801729:	89 02                	mov    %eax,(%edx)
  80172b:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801731:	8b 85 f0 fb ff ff    	mov    0xfffffbf0(%ebp),%eax
  801737:	89 50 08             	mov    %edx,0x8(%eax)
  80173a:	8b 85 f0 fb ff ff    	mov    0xfffffbf0(%ebp),%eax
  801740:	8b 50 0c             	mov    0xc(%eax),%edx
  801743:	8b 45 10             	mov    0x10(%ebp),%eax
  801746:	89 10                	mov    %edx,(%eax)
  801748:	8b 45 14             	mov    0x14(%ebp),%eax
  80174b:	c7 00 07 00 00 00    	movl   $0x7,(%eax)
  801751:	b8 00 00 00 00       	mov    $0x0,%eax
  801756:	81 c4 20 04 00 00    	add    $0x420,%esp
  80175c:	5b                   	pop    %ebx
  80175d:	5e                   	pop    %esi
  80175e:	5d                   	pop    %ebp
  80175f:	c3                   	ret    

00801760 <serve>:

typedef int (*fshandler)(envid_t envid, union Fsipc *req);

fshandler handlers[] = {
	// Open is handled specially because it passes pages
	/* [FSREQ_OPEN] =	(fshandler)serve_open, */
	[FSREQ_SET_SIZE] =	(fshandler)serve_set_size,
	[FSREQ_READ] =		serve_read,
	[FSREQ_WRITE] =		(fshandler)serve_write,
	[FSREQ_STAT] =		serve_stat,
	[FSREQ_FLUSH] =		(fshandler)serve_flush,
	[FSREQ_REMOVE] =	(fshandler)serve_remove,
	[FSREQ_SYNC] =		serve_sync
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	53                   	push   %ebx
  801764:	83 ec 24             	sub    $0x24,%esp
  801767:	8d 5d f8             	lea    0xfffffff8(%ebp),%ebx
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  80176a:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
		//cprintf("****serve is runing,start to recive******\n");
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801771:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801774:	89 44 24 08          	mov    %eax,0x8(%esp)
  801778:	a1 20 c0 80 00       	mov    0x80c020,%eax
  80177d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801781:	89 1c 24             	mov    %ebx,(%esp)
  801784:	e8 6b 17 00 00       	call   802ef4 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, vpt[VPN(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  801789:	f6 45 f4 01          	testb  $0x1,0xfffffff4(%ebp)
  80178d:	75 15                	jne    8017a4 <serve+0x44>
			cprintf("Invalid request from %08x: no argument page\n",
  80178f:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  801792:	89 44 24 04          	mov    %eax,0x4(%esp)
  801796:	c7 04 24 5c 43 80 00 	movl   $0x80435c,(%esp)
  80179d:	e8 1f 07 00 00       	call   801ec1 <cprintf>
  8017a2:	eb c6                	jmp    80176a <serve+0xa>
				whom);
			continue; // just leave it hanging...
		}

		pg = NULL;
  8017a4:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
		if (req == FSREQ_OPEN) {
  8017ab:	83 f8 01             	cmp    $0x1,%eax
  8017ae:	75 26                	jne    8017d6 <serve+0x76>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  8017b0:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8017b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017b7:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  8017ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017be:	a1 20 c0 80 00       	mov    0x80c020,%eax
  8017c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c7:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  8017ca:	89 04 24             	mov    %eax,(%esp)
  8017cd:	e8 5d fe ff ff       	call   80162f <serve_open>
  8017d2:	89 c2                	mov    %eax,%edx
  8017d4:	eb 41                	jmp    801817 <serve+0xb7>
		} else if (req < NHANDLERS && handlers[req]) {
  8017d6:	83 f8 08             	cmp    $0x8,%eax
  8017d9:	77 20                	ja     8017fb <serve+0x9b>
  8017db:	8b 14 85 40 c0 80 00 	mov    0x80c040(,%eax,4),%edx
  8017e2:	85 d2                	test   %edx,%edx
  8017e4:	74 15                	je     8017fb <serve+0x9b>
			r = handlers[req](whom, fsreq);
  8017e6:	a1 20 c0 80 00       	mov    0x80c020,%eax
  8017eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ef:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  8017f2:	89 04 24             	mov    %eax,(%esp)
  8017f5:	ff d2                	call   *%edx
  8017f7:	89 c2                	mov    %eax,%edx
  8017f9:	eb 1c                	jmp    801817 <serve+0xb7>
		} else {
			cprintf("Invalid request code %d from %08x\n", whom, req);
  8017fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017ff:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  801802:	89 44 24 04          	mov    %eax,0x4(%esp)
  801806:	c7 04 24 8c 43 80 00 	movl   $0x80438c,(%esp)
  80180d:	e8 af 06 00 00       	call   801ec1 <cprintf>
  801812:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
			r = -E_INVAL;
		}
		ipc_send(whom, r, pg, perm);
  801817:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80181a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80181e:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  801821:	89 44 24 08          	mov    %eax,0x8(%esp)
  801825:	89 54 24 04          	mov    %edx,0x4(%esp)
  801829:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  80182c:	89 04 24             	mov    %eax,(%esp)
  80182f:	e8 0c 16 00 00       	call   802e40 <ipc_send>
		sys_page_unmap(0, fsreq);
  801834:	a1 20 c0 80 00       	mov    0x80c020,%eax
  801839:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801844:	e8 65 13 00 00       	call   802bae <sys_page_unmap>
  801849:	e9 1c ff ff ff       	jmp    80176a <serve+0xa>

0080184e <umain>:
	}
}

void
umain(void)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801854:	c7 05 64 c0 80 00 af 	movl   $0x8043af,0x80c064
  80185b:	43 80 00 
	cprintf("FS is running\n");
  80185e:	c7 04 24 b2 43 80 00 	movl   $0x8043b2,(%esp)
  801865:	e8 57 06 00 00       	call   801ec1 <cprintf>

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  80186a:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  80186f:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801874:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  801876:	c7 04 24 c1 43 80 00 	movl   $0x8043c1,(%esp)
  80187d:	e8 3f 06 00 00       	call   801ec1 <cprintf>

	serve_init();
  801882:	e8 79 fa ff ff       	call   801300 <serve_init>
	fs_init();
  801887:	e8 10 fa ff ff       	call   80129c <fs_init>
	fs_test();
  80188c:	8d 74 26 00          	lea    0x0(%esi),%esi
  801890:	e8 07 00 00 00       	call   80189c <fs_test>

	serve();
  801895:	e8 c6 fe ff ff       	call   801760 <serve>
}
  80189a:	c9                   	leave  
  80189b:	c3                   	ret    

0080189c <fs_test>:
static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
  80189f:	53                   	push   %ebx
  8018a0:	83 ec 24             	sub    $0x24,%esp
	struct File *f;
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  8018a3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8018aa:	00 
  8018ab:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  8018b2:	00 
  8018b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018ba:	e8 ab 13 00 00       	call   802c6a <sys_page_alloc>
  8018bf:	85 c0                	test   %eax,%eax
  8018c1:	79 20                	jns    8018e3 <fs_test+0x47>
		panic("sys_page_alloc: %e", r);
  8018c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018c7:	c7 44 24 08 d0 43 80 	movl   $0x8043d0,0x8(%esp)
  8018ce:	00 
  8018cf:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  8018d6:	00 
  8018d7:	c7 04 24 e3 43 80 00 	movl   $0x8043e3,(%esp)
  8018de:	e8 11 05 00 00       	call   801df4 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  8018e3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8018ea:	00 
  8018eb:	a1 a0 c0 80 00       	mov    0x80c0a0,%eax
  8018f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f4:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  8018fb:	e8 4a 0e 00 00       	call   80274a <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  801900:	e8 8d ee ff ff       	call   800792 <alloc_block>
  801905:	85 c0                	test   %eax,%eax
  801907:	79 20                	jns    801929 <fs_test+0x8d>
		panic("alloc_block: %e", r);
  801909:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80190d:	c7 44 24 08 ed 43 80 	movl   $0x8043ed,0x8(%esp)
  801914:	00 
  801915:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
  80191c:	00 
  80191d:	c7 04 24 e3 43 80 00 	movl   $0x8043e3,(%esp)
  801924:	e8 cb 04 00 00       	call   801df4 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  801929:	89 c2                	mov    %eax,%edx
  80192b:	c1 fa 1f             	sar    $0x1f,%edx
  80192e:	c1 ea 1b             	shr    $0x1b,%edx
  801931:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
  801934:	89 c8                	mov    %ecx,%eax
  801936:	c1 f8 05             	sar    $0x5,%eax
  801939:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
  801940:	83 e1 1f             	and    $0x1f,%ecx
  801943:	29 d1                	sub    %edx,%ecx
  801945:	b8 01 00 00 00       	mov    $0x1,%eax
  80194a:	89 c2                	mov    %eax,%edx
  80194c:	d3 e2                	shl    %cl,%edx
  80194e:	85 93 00 10 00 00    	test   %edx,0x1000(%ebx)
  801954:	75 24                	jne    80197a <fs_test+0xde>
  801956:	c7 44 24 0c fd 43 80 	movl   $0x8043fd,0xc(%esp)
  80195d:	00 
  80195e:	c7 44 24 08 fd 40 80 	movl   $0x8040fd,0x8(%esp)
  801965:	00 
  801966:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  80196d:	00 
  80196e:	c7 04 24 e3 43 80 00 	movl   $0x8043e3,(%esp)
  801975:	e8 7a 04 00 00       	call   801df4 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  80197a:	89 d8                	mov    %ebx,%eax
  80197c:	03 05 a0 c0 80 00    	add    0x80c0a0,%eax
  801982:	85 10                	test   %edx,(%eax)
  801984:	74 24                	je     8019aa <fs_test+0x10e>
  801986:	c7 44 24 0c 70 45 80 	movl   $0x804570,0xc(%esp)
  80198d:	00 
  80198e:	c7 44 24 08 fd 40 80 	movl   $0x8040fd,0x8(%esp)
  801995:	00 
  801996:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  80199d:	00 
  80199e:	c7 04 24 e3 43 80 00 	movl   $0x8043e3,(%esp)
  8019a5:	e8 4a 04 00 00       	call   801df4 <_panic>
	cprintf("alloc_block is good\n");
  8019aa:	c7 04 24 18 44 80 00 	movl   $0x804418,(%esp)
  8019b1:	e8 0b 05 00 00       	call   801ec1 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  8019b6:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  8019b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019bd:	c7 04 24 2d 44 80 00 	movl   $0x80442d,(%esp)
  8019c4:	e8 34 f7 ff ff       	call   8010fd <file_open>
  8019c9:	85 c0                	test   %eax,%eax
  8019cb:	79 25                	jns    8019f2 <fs_test+0x156>
  8019cd:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8019d0:	74 40                	je     801a12 <fs_test+0x176>
		panic("file_open /not-found: %e", r);
  8019d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019d6:	c7 44 24 08 38 44 80 	movl   $0x804438,0x8(%esp)
  8019dd:	00 
  8019de:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8019e5:	00 
  8019e6:	c7 04 24 e3 43 80 00 	movl   $0x8043e3,(%esp)
  8019ed:	e8 02 04 00 00       	call   801df4 <_panic>
	else if (r == 0)
  8019f2:	85 c0                	test   %eax,%eax
  8019f4:	75 1c                	jne    801a12 <fs_test+0x176>
		panic("file_open /not-found succeeded!");
  8019f6:	c7 44 24 08 90 45 80 	movl   $0x804590,0x8(%esp)
  8019fd:	00 
  8019fe:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801a05:	00 
  801a06:	c7 04 24 e3 43 80 00 	movl   $0x8043e3,(%esp)
  801a0d:	e8 e2 03 00 00       	call   801df4 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801a12:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801a15:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a19:	c7 04 24 51 44 80 00 	movl   $0x804451,(%esp)
  801a20:	e8 d8 f6 ff ff       	call   8010fd <file_open>
  801a25:	85 c0                	test   %eax,%eax
  801a27:	79 20                	jns    801a49 <fs_test+0x1ad>
		panic("file_open /newmotd: %e", r);
  801a29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a2d:	c7 44 24 08 5a 44 80 	movl   $0x80445a,0x8(%esp)
  801a34:	00 
  801a35:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801a3c:	00 
  801a3d:	c7 04 24 e3 43 80 00 	movl   $0x8043e3,(%esp)
  801a44:	e8 ab 03 00 00       	call   801df4 <_panic>
	cprintf("file_open is good\n");
  801a49:	c7 04 24 71 44 80 00 	movl   $0x804471,(%esp)
  801a50:	e8 6c 04 00 00       	call   801ec1 <cprintf>
	//panic("file open is ok 000000000\n");
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801a55:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801a58:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a5c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a63:	00 
  801a64:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  801a67:	89 04 24             	mov    %eax,(%esp)
  801a6a:	e8 64 f1 ff ff       	call   800bd3 <file_get_block>
  801a6f:	85 c0                	test   %eax,%eax
  801a71:	79 20                	jns    801a93 <fs_test+0x1f7>
		panic("file_get_block: %e", r);
  801a73:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a77:	c7 44 24 08 84 44 80 	movl   $0x804484,0x8(%esp)
  801a7e:	00 
  801a7f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801a86:	00 
  801a87:	c7 04 24 e3 43 80 00 	movl   $0x8043e3,(%esp)
  801a8e:	e8 61 03 00 00       	call   801df4 <_panic>
	//panic("000000000\n");
	if (strcmp(blk, msg) != 0)
  801a93:	8b 1d fc 45 80 00    	mov    0x8045fc,%ebx
  801a99:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a9d:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801aa0:	89 04 24             	mov    %eax,(%esp)
  801aa3:	e8 7d 0b 00 00       	call   802625 <strcmp>
  801aa8:	85 c0                	test   %eax,%eax
  801aaa:	74 1c                	je     801ac8 <fs_test+0x22c>
		panic("file_get_block returned wrong data");
  801aac:	c7 44 24 08 b0 45 80 	movl   $0x8045b0,0x8(%esp)
  801ab3:	00 
  801ab4:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  801abb:	00 
  801abc:	c7 04 24 e3 43 80 00 	movl   $0x8043e3,(%esp)
  801ac3:	e8 2c 03 00 00       	call   801df4 <_panic>
	cprintf("file_get_block is good\n");
  801ac8:	c7 04 24 97 44 80 00 	movl   $0x804497,(%esp)
  801acf:	e8 ed 03 00 00       	call   801ec1 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801ad4:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  801ad7:	0f b6 02             	movzbl (%edx),%eax
  801ada:	88 02                	mov    %al,(%edx)
	assert((vpt[VPN(blk)] & PTE_D));
  801adc:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801adf:	c1 e8 0c             	shr    $0xc,%eax
  801ae2:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  801ae9:	a8 40                	test   $0x40,%al
  801aeb:	75 24                	jne    801b11 <fs_test+0x275>
  801aed:	c7 44 24 0c b0 44 80 	movl   $0x8044b0,0xc(%esp)
  801af4:	00 
  801af5:	c7 44 24 08 fd 40 80 	movl   $0x8040fd,0x8(%esp)
  801afc:	00 
  801afd:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  801b04:	00 
  801b05:	c7 04 24 e3 43 80 00 	movl   $0x8043e3,(%esp)
  801b0c:	e8 e3 02 00 00       	call   801df4 <_panic>
	file_flush(f);
  801b11:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  801b14:	89 04 24             	mov    %eax,(%esp)
  801b17:	e8 11 ef ff ff       	call   800a2d <file_flush>
	assert(!(vpt[VPN(blk)] & PTE_D));
  801b1c:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801b1f:	c1 e8 0c             	shr    $0xc,%eax
  801b22:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  801b29:	a8 40                	test   $0x40,%al
  801b2b:	74 24                	je     801b51 <fs_test+0x2b5>
  801b2d:	c7 44 24 0c af 44 80 	movl   $0x8044af,0xc(%esp)
  801b34:	00 
  801b35:	c7 44 24 08 fd 40 80 	movl   $0x8040fd,0x8(%esp)
  801b3c:	00 
  801b3d:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  801b44:	00 
  801b45:	c7 04 24 e3 43 80 00 	movl   $0x8043e3,(%esp)
  801b4c:	e8 a3 02 00 00       	call   801df4 <_panic>
	cprintf("file_flush is good\n");
  801b51:	c7 04 24 c8 44 80 00 	movl   $0x8044c8,(%esp)
  801b58:	e8 64 03 00 00       	call   801ec1 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801b5d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b64:	00 
  801b65:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  801b68:	89 04 24             	mov    %eax,(%esp)
  801b6b:	e8 23 f0 ff ff       	call   800b93 <file_set_size>
  801b70:	85 c0                	test   %eax,%eax
  801b72:	79 20                	jns    801b94 <fs_test+0x2f8>
		panic("file_set_size: %e", r);
  801b74:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b78:	c7 44 24 08 dc 44 80 	movl   $0x8044dc,0x8(%esp)
  801b7f:	00 
  801b80:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801b87:	00 
  801b88:	c7 04 24 e3 43 80 00 	movl   $0x8043e3,(%esp)
  801b8f:	e8 60 02 00 00       	call   801df4 <_panic>
	assert(f->f_direct[0] == 0);
  801b94:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  801b97:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  801b9e:	74 24                	je     801bc4 <fs_test+0x328>
  801ba0:	c7 44 24 0c ee 44 80 	movl   $0x8044ee,0xc(%esp)
  801ba7:	00 
  801ba8:	c7 44 24 08 fd 40 80 	movl   $0x8040fd,0x8(%esp)
  801baf:	00 
  801bb0:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  801bb7:	00 
  801bb8:	c7 04 24 e3 43 80 00 	movl   $0x8043e3,(%esp)
  801bbf:	e8 30 02 00 00       	call   801df4 <_panic>
	assert(!(vpt[VPN(f)] & PTE_D));
  801bc4:	c1 e8 0c             	shr    $0xc,%eax
  801bc7:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  801bce:	a8 40                	test   $0x40,%al
  801bd0:	74 24                	je     801bf6 <fs_test+0x35a>
  801bd2:	c7 44 24 0c 02 45 80 	movl   $0x804502,0xc(%esp)
  801bd9:	00 
  801bda:	c7 44 24 08 fd 40 80 	movl   $0x8040fd,0x8(%esp)
  801be1:	00 
  801be2:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  801be9:	00 
  801bea:	c7 04 24 e3 43 80 00 	movl   $0x8043e3,(%esp)
  801bf1:	e8 fe 01 00 00       	call   801df4 <_panic>
	cprintf("file_truncate is good\n");
  801bf6:	c7 04 24 19 45 80 00 	movl   $0x804519,(%esp)
  801bfd:	e8 bf 02 00 00       	call   801ec1 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  801c02:	89 1c 24             	mov    %ebx,(%esp)
  801c05:	e8 e6 08 00 00       	call   8024f0 <strlen>
  801c0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c0e:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  801c11:	89 04 24             	mov    %eax,(%esp)
  801c14:	e8 7a ef ff ff       	call   800b93 <file_set_size>
  801c19:	85 c0                	test   %eax,%eax
  801c1b:	79 20                	jns    801c3d <fs_test+0x3a1>
		panic("file_set_size 2: %e", r);
  801c1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c21:	c7 44 24 08 30 45 80 	movl   $0x804530,0x8(%esp)
  801c28:	00 
  801c29:	c7 44 24 04 3b 00 00 	movl   $0x3b,0x4(%esp)
  801c30:	00 
  801c31:	c7 04 24 e3 43 80 00 	movl   $0x8043e3,(%esp)
  801c38:	e8 b7 01 00 00       	call   801df4 <_panic>
	assert(!(vpt[VPN(f)] & PTE_D));
  801c3d:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801c40:	89 d0                	mov    %edx,%eax
  801c42:	c1 e8 0c             	shr    $0xc,%eax
  801c45:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  801c4c:	a8 40                	test   $0x40,%al
  801c4e:	74 24                	je     801c74 <fs_test+0x3d8>
  801c50:	c7 44 24 0c 02 45 80 	movl   $0x804502,0xc(%esp)
  801c57:	00 
  801c58:	c7 44 24 08 fd 40 80 	movl   $0x8040fd,0x8(%esp)
  801c5f:	00 
  801c60:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  801c67:	00 
  801c68:	c7 04 24 e3 43 80 00 	movl   $0x8043e3,(%esp)
  801c6f:	e8 80 01 00 00       	call   801df4 <_panic>
	//panic("aaaaaaaaaaaa\n");
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801c74:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801c77:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c7b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c82:	00 
  801c83:	89 14 24             	mov    %edx,(%esp)
  801c86:	e8 48 ef ff ff       	call   800bd3 <file_get_block>
  801c8b:	85 c0                	test   %eax,%eax
  801c8d:	79 20                	jns    801caf <fs_test+0x413>
		panic("file_get_block 2: %e", r);
  801c8f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c93:	c7 44 24 08 44 45 80 	movl   $0x804544,0x8(%esp)
  801c9a:	00 
  801c9b:	c7 44 24 04 3f 00 00 	movl   $0x3f,0x4(%esp)
  801ca2:	00 
  801ca3:	c7 04 24 e3 43 80 00 	movl   $0x8043e3,(%esp)
  801caa:	e8 45 01 00 00       	call   801df4 <_panic>
	strcpy(blk, msg);
  801caf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cb3:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801cb6:	89 04 24             	mov    %eax,(%esp)
  801cb9:	e8 83 08 00 00       	call   802541 <strcpy>
	assert((vpt[VPN(blk)] & PTE_D));
  801cbe:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801cc1:	c1 e8 0c             	shr    $0xc,%eax
  801cc4:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  801ccb:	a8 40                	test   $0x40,%al
  801ccd:	75 24                	jne    801cf3 <fs_test+0x457>
  801ccf:	c7 44 24 0c b0 44 80 	movl   $0x8044b0,0xc(%esp)
  801cd6:	00 
  801cd7:	c7 44 24 08 fd 40 80 	movl   $0x8040fd,0x8(%esp)
  801cde:	00 
  801cdf:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801ce6:	00 
  801ce7:	c7 04 24 e3 43 80 00 	movl   $0x8043e3,(%esp)
  801cee:	e8 01 01 00 00       	call   801df4 <_panic>
	file_flush(f);
  801cf3:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  801cf6:	89 04 24             	mov    %eax,(%esp)
  801cf9:	e8 2f ed ff ff       	call   800a2d <file_flush>
	assert(!(vpt[VPN(blk)] & PTE_D));
  801cfe:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801d01:	c1 e8 0c             	shr    $0xc,%eax
  801d04:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  801d0b:	a8 40                	test   $0x40,%al
  801d0d:	74 24                	je     801d33 <fs_test+0x497>
  801d0f:	c7 44 24 0c af 44 80 	movl   $0x8044af,0xc(%esp)
  801d16:	00 
  801d17:	c7 44 24 08 fd 40 80 	movl   $0x8040fd,0x8(%esp)
  801d1e:	00 
  801d1f:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  801d26:	00 
  801d27:	c7 04 24 e3 43 80 00 	movl   $0x8043e3,(%esp)
  801d2e:	e8 c1 00 00 00       	call   801df4 <_panic>
	assert(!(vpt[VPN(f)] & PTE_D));
  801d33:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  801d36:	c1 e8 0c             	shr    $0xc,%eax
  801d39:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  801d40:	a8 40                	test   $0x40,%al
  801d42:	74 24                	je     801d68 <fs_test+0x4cc>
  801d44:	c7 44 24 0c 02 45 80 	movl   $0x804502,0xc(%esp)
  801d4b:	00 
  801d4c:	c7 44 24 08 fd 40 80 	movl   $0x8040fd,0x8(%esp)
  801d53:	00 
  801d54:	c7 44 24 04 44 00 00 	movl   $0x44,0x4(%esp)
  801d5b:	00 
  801d5c:	c7 04 24 e3 43 80 00 	movl   $0x8043e3,(%esp)
  801d63:	e8 8c 00 00 00       	call   801df4 <_panic>
	cprintf("file rewrite is good\n");
  801d68:	c7 04 24 59 45 80 00 	movl   $0x804559,(%esp)
  801d6f:	e8 4d 01 00 00       	call   801ec1 <cprintf>
}
  801d74:	83 c4 24             	add    $0x24,%esp
  801d77:	5b                   	pop    %ebx
  801d78:	5d                   	pop    %ebp
  801d79:	c3                   	ret    
	...

00801d7c <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
  801d7f:	83 ec 18             	sub    $0x18,%esp
  801d82:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  801d85:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  801d88:	8b 75 08             	mov    0x8(%ebp),%esi
  801d8b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  801d8e:	c7 05 a8 c0 80 00 00 	movl   $0x0,0x80c0a8
  801d95:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  801d98:	e8 60 0f 00 00       	call   802cfd <sys_getenvid>
  801d9d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801da2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801da5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801daa:	a3 a8 c0 80 00       	mov    %eax,0x80c0a8
	// save the name of the program so that panic() can use it
	if (argc > 0)
  801daf:	85 f6                	test   %esi,%esi
  801db1:	7e 07                	jle    801dba <libmain+0x3e>
		binaryname = argv[0];
  801db3:	8b 03                	mov    (%ebx),%eax
  801db5:	a3 64 c0 80 00       	mov    %eax,0x80c064

	// call user main routine调用用户主例程
	umain(argc, argv);
  801dba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dbe:	89 34 24             	mov    %esi,(%esp)
  801dc1:	e8 88 fa ff ff       	call   80184e <umain>

	// exit gracefully
	exit();
  801dc6:	e8 0d 00 00 00       	call   801dd8 <exit>
}
  801dcb:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  801dce:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  801dd1:	89 ec                	mov    %ebp,%esp
  801dd3:	5d                   	pop    %ebp
  801dd4:	c3                   	ret    
  801dd5:	00 00                	add    %al,(%eax)
	...

00801dd8 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  801dd8:	55                   	push   %ebp
  801dd9:	89 e5                	mov    %esp,%ebp
  801ddb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801dde:	e8 f3 17 00 00       	call   8035d6 <close_all>
	sys_env_destroy(0);
  801de3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dea:	e8 42 0f 00 00       	call   802d31 <sys_env_destroy>
}
  801def:	c9                   	leave  
  801df0:	c3                   	ret    
  801df1:	00 00                	add    %al,(%eax)
	...

00801df4 <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801df4:	55                   	push   %ebp
  801df5:	89 e5                	mov    %esp,%ebp
  801df7:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  801dfa:	8d 45 14             	lea    0x14(%ebp),%eax
  801dfd:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)

	// Print the panic message
	if (argv0)
  801e00:	a1 ac c0 80 00       	mov    0x80c0ac,%eax
  801e05:	85 c0                	test   %eax,%eax
  801e07:	74 10                	je     801e19 <_panic+0x25>
		cprintf("%s: ", argv0);
  801e09:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e0d:	c7 04 24 17 46 80 00 	movl   $0x804617,(%esp)
  801e14:	e8 a8 00 00 00       	call   801ec1 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  801e19:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e20:	8b 45 08             	mov    0x8(%ebp),%eax
  801e23:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e27:	a1 64 c0 80 00       	mov    0x80c064,%eax
  801e2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e30:	c7 04 24 1c 46 80 00 	movl   $0x80461c,(%esp)
  801e37:	e8 85 00 00 00       	call   801ec1 <cprintf>
	vcprintf(fmt, ap);
  801e3c:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  801e3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e43:	8b 45 10             	mov    0x10(%ebp),%eax
  801e46:	89 04 24             	mov    %eax,(%esp)
  801e49:	e8 12 00 00 00       	call   801e60 <vcprintf>
	cprintf("\n");
  801e4e:	c7 04 24 1f 42 80 00 	movl   $0x80421f,(%esp)
  801e55:	e8 67 00 00 00       	call   801ec1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e5a:	cc                   	int3   
  801e5b:	eb fd                	jmp    801e5a <_panic+0x66>
  801e5d:	00 00                	add    %al,(%eax)
	...

00801e60 <vcprintf>:
}

int
vcprintf(const char *fmt, va_list ap)
{
  801e60:	55                   	push   %ebp
  801e61:	89 e5                	mov    %esp,%ebp
  801e63:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801e69:	c7 85 f8 fe ff ff 00 	movl   $0x0,0xfffffef8(%ebp)
  801e70:	00 00 00 
	b.cnt = 0;
  801e73:	c7 85 fc fe ff ff 00 	movl   $0x0,0xfffffefc(%ebp)
  801e7a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801e7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e80:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e84:	8b 45 08             	mov    0x8(%ebp),%eax
  801e87:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e8b:	8d 85 f8 fe ff ff    	lea    0xfffffef8(%ebp),%eax
  801e91:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e95:	c7 04 24 de 1e 80 00 	movl   $0x801ede,(%esp)
  801e9c:	e8 c0 01 00 00       	call   802061 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801ea1:	8b 85 f8 fe ff ff    	mov    0xfffffef8(%ebp),%eax
  801ea7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eab:	8d 85 00 ff ff ff    	lea    0xffffff00(%ebp),%eax
  801eb1:	89 04 24             	mov    %eax,(%esp)
  801eb4:	e8 df 0a 00 00       	call   802998 <sys_cputs>
  801eb9:	8b 85 fc fe ff ff    	mov    0xfffffefc(%ebp),%eax

	return b.cnt;
}
  801ebf:	c9                   	leave  
  801ec0:	c3                   	ret    

00801ec1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801ec1:	55                   	push   %ebp
  801ec2:	89 e5                	mov    %esp,%ebp
  801ec4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801ec7:	8d 45 0c             	lea    0xc(%ebp),%eax
  801eca:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
	cnt = vcprintf(fmt, ap);
  801ecd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed4:	89 04 24             	mov    %eax,(%esp)
  801ed7:	e8 84 ff ff ff       	call   801e60 <vcprintf>
	va_end(ap);

	return cnt;
}
  801edc:	c9                   	leave  
  801edd:	c3                   	ret    

00801ede <putch>:
  801ede:	55                   	push   %ebp
  801edf:	89 e5                	mov    %esp,%ebp
  801ee1:	53                   	push   %ebx
  801ee2:	83 ec 14             	sub    $0x14,%esp
  801ee5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ee8:	8b 03                	mov    (%ebx),%eax
  801eea:	8b 55 08             	mov    0x8(%ebp),%edx
  801eed:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801ef1:	83 c0 01             	add    $0x1,%eax
  801ef4:	89 03                	mov    %eax,(%ebx)
  801ef6:	3d ff 00 00 00       	cmp    $0xff,%eax
  801efb:	75 19                	jne    801f16 <putch+0x38>
  801efd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801f04:	00 
  801f05:	8d 43 08             	lea    0x8(%ebx),%eax
  801f08:	89 04 24             	mov    %eax,(%esp)
  801f0b:	e8 88 0a 00 00       	call   802998 <sys_cputs>
  801f10:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f16:	83 43 04 01          	addl   $0x1,0x4(%ebx)
  801f1a:	83 c4 14             	add    $0x14,%esp
  801f1d:	5b                   	pop    %ebx
  801f1e:	5d                   	pop    %ebp
  801f1f:	c3                   	ret    

00801f20 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801f20:	55                   	push   %ebp
  801f21:	89 e5                	mov    %esp,%ebp
  801f23:	57                   	push   %edi
  801f24:	56                   	push   %esi
  801f25:	53                   	push   %ebx
  801f26:	83 ec 3c             	sub    $0x3c,%esp
  801f29:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  801f2c:	89 d7                	mov    %edx,%edi
  801f2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f31:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f34:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  801f37:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  801f3a:	8b 55 10             	mov    0x10(%ebp),%edx
  801f3d:	8b 45 14             	mov    0x14(%ebp),%eax
  801f40:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801f43:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  801f46:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  801f4d:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  801f50:	39 4d ec             	cmp    %ecx,0xffffffec(%ebp)
  801f53:	72 11                	jb     801f66 <printnum+0x46>
  801f55:	8b 4d d8             	mov    0xffffffd8(%ebp),%ecx
  801f58:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  801f5b:	76 09                	jbe    801f66 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801f5d:	8d 58 ff             	lea    0xffffffff(%eax),%ebx
  801f60:	85 db                	test   %ebx,%ebx
  801f62:	7f 54                	jg     801fb8 <printnum+0x98>
  801f64:	eb 61                	jmp    801fc7 <printnum+0xa7>
  801f66:	89 74 24 10          	mov    %esi,0x10(%esp)
  801f6a:	83 e8 01             	sub    $0x1,%eax
  801f6d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f71:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f75:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801f79:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801f7d:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  801f80:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  801f83:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f87:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801f8b:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  801f8e:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  801f91:	89 14 24             	mov    %edx,(%esp)
  801f94:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801f98:	e8 63 1e 00 00       	call   803e00 <__udivdi3>
  801f9d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fa1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801fa5:	89 04 24             	mov    %eax,(%esp)
  801fa8:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fac:	89 fa                	mov    %edi,%edx
  801fae:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  801fb1:	e8 6a ff ff ff       	call   801f20 <printnum>
  801fb6:	eb 0f                	jmp    801fc7 <printnum+0xa7>
			putch(padc, putdat);
  801fb8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801fbc:	89 34 24             	mov    %esi,(%esp)
  801fbf:	ff 55 e4             	call   *0xffffffe4(%ebp)
  801fc2:	83 eb 01             	sub    $0x1,%ebx
  801fc5:	75 f1                	jne    801fb8 <printnum+0x98>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801fc7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801fcb:	8b 74 24 04          	mov    0x4(%esp),%esi
  801fcf:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  801fd2:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  801fd5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fd9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801fdd:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  801fe0:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  801fe3:	89 14 24             	mov    %edx,(%esp)
  801fe6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801fea:	e8 41 1f 00 00       	call   803f30 <__umoddi3>
  801fef:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ff3:	0f be 80 38 46 80 00 	movsbl 0x804638(%eax),%eax
  801ffa:	89 04 24             	mov    %eax,(%esp)
  801ffd:	ff 55 e4             	call   *0xffffffe4(%ebp)
}
  802000:	83 c4 3c             	add    $0x3c,%esp
  802003:	5b                   	pop    %ebx
  802004:	5e                   	pop    %esi
  802005:	5f                   	pop    %edi
  802006:	5d                   	pop    %ebp
  802007:	c3                   	ret    

00802008 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  802008:	55                   	push   %ebp
  802009:	89 e5                	mov    %esp,%ebp
  80200b:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  80200d:	83 fa 01             	cmp    $0x1,%edx
  802010:	7e 0e                	jle    802020 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  802012:	8b 10                	mov    (%eax),%edx
  802014:	8d 42 08             	lea    0x8(%edx),%eax
  802017:	89 01                	mov    %eax,(%ecx)
  802019:	8b 02                	mov    (%edx),%eax
  80201b:	8b 52 04             	mov    0x4(%edx),%edx
  80201e:	eb 22                	jmp    802042 <getuint+0x3a>
	else if (lflag)
  802020:	85 d2                	test   %edx,%edx
  802022:	74 10                	je     802034 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  802024:	8b 10                	mov    (%eax),%edx
  802026:	8d 42 04             	lea    0x4(%edx),%eax
  802029:	89 01                	mov    %eax,(%ecx)
  80202b:	8b 02                	mov    (%edx),%eax
  80202d:	ba 00 00 00 00       	mov    $0x0,%edx
  802032:	eb 0e                	jmp    802042 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  802034:	8b 10                	mov    (%eax),%edx
  802036:	8d 42 04             	lea    0x4(%edx),%eax
  802039:	89 01                	mov    %eax,(%ecx)
  80203b:	8b 02                	mov    (%edx),%eax
  80203d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  802042:	5d                   	pop    %ebp
  802043:	c3                   	ret    

00802044 <sprintputch>:

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
  802044:	55                   	push   %ebp
  802045:	89 e5                	mov    %esp,%ebp
  802047:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  80204a:	83 41 08 01          	addl   $0x1,0x8(%ecx)
	if (b->buf < b->ebuf)
  80204e:	8b 11                	mov    (%ecx),%edx
  802050:	3b 51 04             	cmp    0x4(%ecx),%edx
  802053:	73 0a                	jae    80205f <sprintputch+0x1b>
		*b->buf++ = ch;
  802055:	8b 45 08             	mov    0x8(%ebp),%eax
  802058:	88 02                	mov    %al,(%edx)
  80205a:	8d 42 01             	lea    0x1(%edx),%eax
  80205d:	89 01                	mov    %eax,(%ecx)
}
  80205f:	5d                   	pop    %ebp
  802060:	c3                   	ret    

00802061 <vprintfmt>:
  802061:	55                   	push   %ebp
  802062:	89 e5                	mov    %esp,%ebp
  802064:	57                   	push   %edi
  802065:	56                   	push   %esi
  802066:	53                   	push   %ebx
  802067:	83 ec 4c             	sub    $0x4c,%esp
  80206a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80206d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802070:	eb 03                	jmp    802075 <vprintfmt+0x14>
  802072:	8b 5d e8             	mov    0xffffffe8(%ebp),%ebx
  802075:	0f b6 03             	movzbl (%ebx),%eax
  802078:	83 c3 01             	add    $0x1,%ebx
  80207b:	3c 25                	cmp    $0x25,%al
  80207d:	74 30                	je     8020af <vprintfmt+0x4e>
  80207f:	84 c0                	test   %al,%al
  802081:	0f 84 a8 03 00 00    	je     80242f <vprintfmt+0x3ce>
  802087:	0f b6 d0             	movzbl %al,%edx
  80208a:	eb 0a                	jmp    802096 <vprintfmt+0x35>
  80208c:	84 c0                	test   %al,%al
  80208e:	66 90                	xchg   %ax,%ax
  802090:	0f 84 99 03 00 00    	je     80242f <vprintfmt+0x3ce>
  802096:	8b 45 0c             	mov    0xc(%ebp),%eax
  802099:	89 44 24 04          	mov    %eax,0x4(%esp)
  80209d:	89 14 24             	mov    %edx,(%esp)
  8020a0:	ff d7                	call   *%edi
  8020a2:	0f b6 03             	movzbl (%ebx),%eax
  8020a5:	0f b6 d0             	movzbl %al,%edx
  8020a8:	83 c3 01             	add    $0x1,%ebx
  8020ab:	3c 25                	cmp    $0x25,%al
  8020ad:	75 dd                	jne    80208c <vprintfmt+0x2b>
  8020af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8020b4:	c7 45 ec ff ff ff ff 	movl   $0xffffffff,0xffffffec(%ebp)
  8020bb:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  8020c2:	c7 45 dc 00 00 00 00 	movl   $0x0,0xffffffdc(%ebp)
  8020c9:	c6 45 e3 20          	movb   $0x20,0xffffffe3(%ebp)
  8020cd:	eb 07                	jmp    8020d6 <vprintfmt+0x75>
  8020cf:	c7 45 dc 01 00 00 00 	movl   $0x1,0xffffffdc(%ebp)
  8020d6:	0f b6 03             	movzbl (%ebx),%eax
  8020d9:	0f b6 d0             	movzbl %al,%edx
  8020dc:	83 c3 01             	add    $0x1,%ebx
  8020df:	83 e8 23             	sub    $0x23,%eax
  8020e2:	3c 55                	cmp    $0x55,%al
  8020e4:	0f 87 11 03 00 00    	ja     8023fb <vprintfmt+0x39a>
  8020ea:	0f b6 c0             	movzbl %al,%eax
  8020ed:	ff 24 85 80 47 80 00 	jmp    *0x804780(,%eax,4)
  8020f4:	c6 45 e3 30          	movb   $0x30,0xffffffe3(%ebp)
  8020f8:	eb dc                	jmp    8020d6 <vprintfmt+0x75>
  8020fa:	83 ea 30             	sub    $0x30,%edx
  8020fd:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  802100:	0f be 13             	movsbl (%ebx),%edx
  802103:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  802106:	83 f8 09             	cmp    $0x9,%eax
  802109:	76 08                	jbe    802113 <vprintfmt+0xb2>
  80210b:	eb 42                	jmp    80214f <vprintfmt+0xee>
  80210d:	c6 45 e3 2d          	movb   $0x2d,0xffffffe3(%ebp)
  802111:	eb c3                	jmp    8020d6 <vprintfmt+0x75>
  802113:	83 c3 01             	add    $0x1,%ebx
  802116:	8b 75 e4             	mov    0xffffffe4(%ebp),%esi
  802119:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  80211c:	8d 44 42 d0          	lea    0xffffffd0(%edx,%eax,2),%eax
  802120:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  802123:	0f be 13             	movsbl (%ebx),%edx
  802126:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  802129:	83 f8 09             	cmp    $0x9,%eax
  80212c:	77 21                	ja     80214f <vprintfmt+0xee>
  80212e:	eb e3                	jmp    802113 <vprintfmt+0xb2>
  802130:	8b 55 14             	mov    0x14(%ebp),%edx
  802133:	8d 42 04             	lea    0x4(%edx),%eax
  802136:	89 45 14             	mov    %eax,0x14(%ebp)
  802139:	8b 12                	mov    (%edx),%edx
  80213b:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  80213e:	eb 0f                	jmp    80214f <vprintfmt+0xee>
  802140:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  802144:	79 90                	jns    8020d6 <vprintfmt+0x75>
  802146:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  80214d:	eb 87                	jmp    8020d6 <vprintfmt+0x75>
  80214f:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  802153:	79 81                	jns    8020d6 <vprintfmt+0x75>
  802155:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  802158:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  80215b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  802162:	e9 6f ff ff ff       	jmp    8020d6 <vprintfmt+0x75>
  802167:	83 c1 01             	add    $0x1,%ecx
  80216a:	e9 67 ff ff ff       	jmp    8020d6 <vprintfmt+0x75>
  80216f:	8b 45 14             	mov    0x14(%ebp),%eax
  802172:	8d 50 04             	lea    0x4(%eax),%edx
  802175:	89 55 14             	mov    %edx,0x14(%ebp)
  802178:	8b 55 0c             	mov    0xc(%ebp),%edx
  80217b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80217f:	8b 00                	mov    (%eax),%eax
  802181:	89 04 24             	mov    %eax,(%esp)
  802184:	ff d7                	call   *%edi
  802186:	e9 ea fe ff ff       	jmp    802075 <vprintfmt+0x14>
  80218b:	8b 55 14             	mov    0x14(%ebp),%edx
  80218e:	8d 42 04             	lea    0x4(%edx),%eax
  802191:	89 45 14             	mov    %eax,0x14(%ebp)
  802194:	8b 02                	mov    (%edx),%eax
  802196:	89 c2                	mov    %eax,%edx
  802198:	c1 fa 1f             	sar    $0x1f,%edx
  80219b:	31 d0                	xor    %edx,%eax
  80219d:	29 d0                	sub    %edx,%eax
  80219f:	83 f8 0f             	cmp    $0xf,%eax
  8021a2:	7f 0b                	jg     8021af <vprintfmt+0x14e>
  8021a4:	8b 14 85 e0 48 80 00 	mov    0x8048e0(,%eax,4),%edx
  8021ab:	85 d2                	test   %edx,%edx
  8021ad:	75 20                	jne    8021cf <vprintfmt+0x16e>
  8021af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021b3:	c7 44 24 08 49 46 80 	movl   $0x804649,0x8(%esp)
  8021ba:	00 
  8021bb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021c2:	89 3c 24             	mov    %edi,(%esp)
  8021c5:	e8 f0 02 00 00       	call   8024ba <printfmt>
  8021ca:	e9 a6 fe ff ff       	jmp    802075 <vprintfmt+0x14>
  8021cf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021d3:	c7 44 24 08 0f 41 80 	movl   $0x80410f,0x8(%esp)
  8021da:	00 
  8021db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021e2:	89 3c 24             	mov    %edi,(%esp)
  8021e5:	e8 d0 02 00 00       	call   8024ba <printfmt>
  8021ea:	e9 86 fe ff ff       	jmp    802075 <vprintfmt+0x14>
  8021ef:	8b 75 ec             	mov    0xffffffec(%ebp),%esi
  8021f2:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  8021f5:	89 5d e8             	mov    %ebx,0xffffffe8(%ebp)
  8021f8:	8b 55 14             	mov    0x14(%ebp),%edx
  8021fb:	8d 42 04             	lea    0x4(%edx),%eax
  8021fe:	89 45 14             	mov    %eax,0x14(%ebp)
  802201:	8b 12                	mov    (%edx),%edx
  802203:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  802206:	85 d2                	test   %edx,%edx
  802208:	75 07                	jne    802211 <vprintfmt+0x1b0>
  80220a:	c7 45 d8 52 46 80 00 	movl   $0x804652,0xffffffd8(%ebp)
  802211:	85 f6                	test   %esi,%esi
  802213:	7e 40                	jle    802255 <vprintfmt+0x1f4>
  802215:	80 7d e3 2d          	cmpb   $0x2d,0xffffffe3(%ebp)
  802219:	74 3a                	je     802255 <vprintfmt+0x1f4>
  80221b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80221f:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  802222:	89 14 24             	mov    %edx,(%esp)
  802225:	e8 e6 02 00 00       	call   802510 <strnlen>
  80222a:	29 c6                	sub    %eax,%esi
  80222c:	89 75 ec             	mov    %esi,0xffffffec(%ebp)
  80222f:	85 f6                	test   %esi,%esi
  802231:	7e 22                	jle    802255 <vprintfmt+0x1f4>
  802233:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  802237:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  80223a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80223d:	89 54 24 04          	mov    %edx,0x4(%esp)
  802241:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  802244:	89 04 24             	mov    %eax,(%esp)
  802247:	ff d7                	call   *%edi
  802249:	83 ee 01             	sub    $0x1,%esi
  80224c:	75 ec                	jne    80223a <vprintfmt+0x1d9>
  80224e:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  802255:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  802258:	0f b6 02             	movzbl (%edx),%eax
  80225b:	0f be d0             	movsbl %al,%edx
  80225e:	8b 75 d8             	mov    0xffffffd8(%ebp),%esi
  802261:	84 c0                	test   %al,%al
  802263:	75 40                	jne    8022a5 <vprintfmt+0x244>
  802265:	eb 4a                	jmp    8022b1 <vprintfmt+0x250>
  802267:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
  80226b:	74 1a                	je     802287 <vprintfmt+0x226>
  80226d:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  802270:	83 f8 5e             	cmp    $0x5e,%eax
  802273:	76 12                	jbe    802287 <vprintfmt+0x226>
  802275:	8b 45 0c             	mov    0xc(%ebp),%eax
  802278:	89 44 24 04          	mov    %eax,0x4(%esp)
  80227c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  802283:	ff d7                	call   *%edi
  802285:	eb 0c                	jmp    802293 <vprintfmt+0x232>
  802287:	8b 45 0c             	mov    0xc(%ebp),%eax
  80228a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80228e:	89 14 24             	mov    %edx,(%esp)
  802291:	ff d7                	call   *%edi
  802293:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  802297:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80229b:	83 c6 01             	add    $0x1,%esi
  80229e:	84 c0                	test   %al,%al
  8022a0:	74 0f                	je     8022b1 <vprintfmt+0x250>
  8022a2:	0f be d0             	movsbl %al,%edx
  8022a5:	83 7d e4 00          	cmpl   $0x0,0xffffffe4(%ebp)
  8022a9:	78 bc                	js     802267 <vprintfmt+0x206>
  8022ab:	83 6d e4 01          	subl   $0x1,0xffffffe4(%ebp)
  8022af:	79 b6                	jns    802267 <vprintfmt+0x206>
  8022b1:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  8022b5:	0f 8e ba fd ff ff    	jle    802075 <vprintfmt+0x14>
  8022bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022c2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8022c9:	ff d7                	call   *%edi
  8022cb:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  8022cf:	0f 84 9d fd ff ff    	je     802072 <vprintfmt+0x11>
  8022d5:	eb e4                	jmp    8022bb <vprintfmt+0x25a>
  8022d7:	83 f9 01             	cmp    $0x1,%ecx
  8022da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022e0:	7e 10                	jle    8022f2 <vprintfmt+0x291>
  8022e2:	8b 55 14             	mov    0x14(%ebp),%edx
  8022e5:	8d 42 08             	lea    0x8(%edx),%eax
  8022e8:	89 45 14             	mov    %eax,0x14(%ebp)
  8022eb:	8b 02                	mov    (%edx),%eax
  8022ed:	8b 52 04             	mov    0x4(%edx),%edx
  8022f0:	eb 26                	jmp    802318 <vprintfmt+0x2b7>
  8022f2:	85 c9                	test   %ecx,%ecx
  8022f4:	74 12                	je     802308 <vprintfmt+0x2a7>
  8022f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8022f9:	8d 50 04             	lea    0x4(%eax),%edx
  8022fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8022ff:	8b 00                	mov    (%eax),%eax
  802301:	89 c2                	mov    %eax,%edx
  802303:	c1 fa 1f             	sar    $0x1f,%edx
  802306:	eb 10                	jmp    802318 <vprintfmt+0x2b7>
  802308:	8b 45 14             	mov    0x14(%ebp),%eax
  80230b:	8d 50 04             	lea    0x4(%eax),%edx
  80230e:	89 55 14             	mov    %edx,0x14(%ebp)
  802311:	8b 00                	mov    (%eax),%eax
  802313:	89 c2                	mov    %eax,%edx
  802315:	c1 fa 1f             	sar    $0x1f,%edx
  802318:	89 d1                	mov    %edx,%ecx
  80231a:	89 c2                	mov    %eax,%edx
  80231c:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  80231f:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  802322:	be 0a 00 00 00       	mov    $0xa,%esi
  802327:	85 c9                	test   %ecx,%ecx
  802329:	0f 89 92 00 00 00    	jns    8023c1 <vprintfmt+0x360>
  80232f:	8b 75 0c             	mov    0xc(%ebp),%esi
  802332:	89 74 24 04          	mov    %esi,0x4(%esp)
  802336:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80233d:	ff d7                	call   *%edi
  80233f:	8b 55 d0             	mov    0xffffffd0(%ebp),%edx
  802342:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  802345:	f7 da                	neg    %edx
  802347:	83 d1 00             	adc    $0x0,%ecx
  80234a:	f7 d9                	neg    %ecx
  80234c:	be 0a 00 00 00       	mov    $0xa,%esi
  802351:	eb 6e                	jmp    8023c1 <vprintfmt+0x360>
  802353:	8d 45 14             	lea    0x14(%ebp),%eax
  802356:	89 ca                	mov    %ecx,%edx
  802358:	e8 ab fc ff ff       	call   802008 <getuint>
  80235d:	89 d1                	mov    %edx,%ecx
  80235f:	89 c2                	mov    %eax,%edx
  802361:	be 0a 00 00 00       	mov    $0xa,%esi
  802366:	eb 59                	jmp    8023c1 <vprintfmt+0x360>
  802368:	8d 45 14             	lea    0x14(%ebp),%eax
  80236b:	89 ca                	mov    %ecx,%edx
  80236d:	e8 96 fc ff ff       	call   802008 <getuint>
  802372:	e9 fe fc ff ff       	jmp    802075 <vprintfmt+0x14>
  802377:	8b 45 0c             	mov    0xc(%ebp),%eax
  80237a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80237e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  802385:	ff d7                	call   *%edi
  802387:	8b 55 0c             	mov    0xc(%ebp),%edx
  80238a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80238e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  802395:	ff d7                	call   *%edi
  802397:	8b 55 14             	mov    0x14(%ebp),%edx
  80239a:	8d 42 04             	lea    0x4(%edx),%eax
  80239d:	89 45 14             	mov    %eax,0x14(%ebp)
  8023a0:	8b 12                	mov    (%edx),%edx
  8023a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8023a7:	be 10 00 00 00       	mov    $0x10,%esi
  8023ac:	eb 13                	jmp    8023c1 <vprintfmt+0x360>
  8023ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8023b1:	89 ca                	mov    %ecx,%edx
  8023b3:	e8 50 fc ff ff       	call   802008 <getuint>
  8023b8:	89 d1                	mov    %edx,%ecx
  8023ba:	89 c2                	mov    %eax,%edx
  8023bc:	be 10 00 00 00       	mov    $0x10,%esi
  8023c1:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  8023c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8023c9:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  8023cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023d0:	89 74 24 08          	mov    %esi,0x8(%esp)
  8023d4:	89 14 24             	mov    %edx,(%esp)
  8023d7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8023db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023de:	89 f8                	mov    %edi,%eax
  8023e0:	e8 3b fb ff ff       	call   801f20 <printnum>
  8023e5:	e9 8b fc ff ff       	jmp    802075 <vprintfmt+0x14>
  8023ea:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023ed:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023f1:	89 14 24             	mov    %edx,(%esp)
  8023f4:	ff d7                	call   *%edi
  8023f6:	e9 7a fc ff ff       	jmp    802075 <vprintfmt+0x14>
  8023fb:	89 de                	mov    %ebx,%esi
  8023fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  802400:	89 44 24 04          	mov    %eax,0x4(%esp)
  802404:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80240b:	ff d7                	call   *%edi
  80240d:	83 eb 01             	sub    $0x1,%ebx
  802410:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  802414:	0f 84 5b fc ff ff    	je     802075 <vprintfmt+0x14>
  80241a:	8d 56 fd             	lea    0xfffffffd(%esi),%edx
  80241d:	0f b6 02             	movzbl (%edx),%eax
  802420:	83 ea 01             	sub    $0x1,%edx
  802423:	3c 25                	cmp    $0x25,%al
  802425:	75 f6                	jne    80241d <vprintfmt+0x3bc>
  802427:	8d 5a 02             	lea    0x2(%edx),%ebx
  80242a:	e9 46 fc ff ff       	jmp    802075 <vprintfmt+0x14>
  80242f:	83 c4 4c             	add    $0x4c,%esp
  802432:	5b                   	pop    %ebx
  802433:	5e                   	pop    %esi
  802434:	5f                   	pop    %edi
  802435:	5d                   	pop    %ebp
  802436:	c3                   	ret    

00802437 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  802437:	55                   	push   %ebp
  802438:	89 e5                	mov    %esp,%ebp
  80243a:	83 ec 28             	sub    $0x28,%esp
  80243d:	8b 55 08             	mov    0x8(%ebp),%edx
  802440:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  802443:	85 d2                	test   %edx,%edx
  802445:	74 04                	je     80244b <vsnprintf+0x14>
  802447:	85 c0                	test   %eax,%eax
  802449:	7f 07                	jg     802452 <vsnprintf+0x1b>
  80244b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802450:	eb 3b                	jmp    80248d <vsnprintf+0x56>
  802452:	c7 45 fc 00 00 00 00 	movl   $0x0,0xfffffffc(%ebp)
  802459:	8d 44 02 ff          	lea    0xffffffff(%edx,%eax,1),%eax
  80245d:	89 45 f8             	mov    %eax,0xfffffff8(%ebp)
  802460:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  802463:	8b 45 14             	mov    0x14(%ebp),%eax
  802466:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80246a:	8b 45 10             	mov    0x10(%ebp),%eax
  80246d:	89 44 24 08          	mov    %eax,0x8(%esp)
  802471:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  802474:	89 44 24 04          	mov    %eax,0x4(%esp)
  802478:	c7 04 24 44 20 80 00 	movl   $0x802044,(%esp)
  80247f:	e8 dd fb ff ff       	call   802061 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  802484:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  802487:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80248a:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
}
  80248d:	c9                   	leave  
  80248e:	c3                   	ret    

0080248f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80248f:	55                   	push   %ebp
  802490:	89 e5                	mov    %esp,%ebp
  802492:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  802495:	8d 45 14             	lea    0x14(%ebp),%eax
  802498:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  80249b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80249f:	8b 45 10             	mov    0x10(%ebp),%eax
  8024a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8024b0:	89 04 24             	mov    %eax,(%esp)
  8024b3:	e8 7f ff ff ff       	call   802437 <vsnprintf>
	va_end(ap);

	return rc;
}
  8024b8:	c9                   	leave  
  8024b9:	c3                   	ret    

008024ba <printfmt>:
  8024ba:	55                   	push   %ebp
  8024bb:	89 e5                	mov    %esp,%ebp
  8024bd:	83 ec 28             	sub    $0x28,%esp
  8024c0:	8d 45 14             	lea    0x14(%ebp),%eax
  8024c3:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
  8024c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8024cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8024db:	89 04 24             	mov    %eax,(%esp)
  8024de:	e8 7e fb ff ff       	call   802061 <vprintfmt>
  8024e3:	c9                   	leave  
  8024e4:	c3                   	ret    
	...

008024f0 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  8024f0:	55                   	push   %ebp
  8024f1:	89 e5                	mov    %esp,%ebp
  8024f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8024f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8024fb:	80 3a 00             	cmpb   $0x0,(%edx)
  8024fe:	74 0e                	je     80250e <strlen+0x1e>
  802500:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  802505:	83 c0 01             	add    $0x1,%eax
  802508:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80250c:	75 f7                	jne    802505 <strlen+0x15>
	return n;
}
  80250e:	5d                   	pop    %ebp
  80250f:	c3                   	ret    

00802510 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  802510:	55                   	push   %ebp
  802511:	89 e5                	mov    %esp,%ebp
  802513:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802516:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802519:	85 d2                	test   %edx,%edx
  80251b:	74 19                	je     802536 <strnlen+0x26>
  80251d:	80 39 00             	cmpb   $0x0,(%ecx)
  802520:	74 14                	je     802536 <strnlen+0x26>
  802522:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  802527:	83 c0 01             	add    $0x1,%eax
  80252a:	39 d0                	cmp    %edx,%eax
  80252c:	74 0d                	je     80253b <strnlen+0x2b>
  80252e:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  802532:	74 07                	je     80253b <strnlen+0x2b>
  802534:	eb f1                	jmp    802527 <strnlen+0x17>
  802536:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  80253b:	5d                   	pop    %ebp
  80253c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802540:	c3                   	ret    

00802541 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  802541:	55                   	push   %ebp
  802542:	89 e5                	mov    %esp,%ebp
  802544:	53                   	push   %ebx
  802545:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802548:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80254b:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80254d:	0f b6 01             	movzbl (%ecx),%eax
  802550:	88 02                	mov    %al,(%edx)
  802552:	83 c2 01             	add    $0x1,%edx
  802555:	83 c1 01             	add    $0x1,%ecx
  802558:	84 c0                	test   %al,%al
  80255a:	75 f1                	jne    80254d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80255c:	89 d8                	mov    %ebx,%eax
  80255e:	5b                   	pop    %ebx
  80255f:	5d                   	pop    %ebp
  802560:	c3                   	ret    

00802561 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802561:	55                   	push   %ebp
  802562:	89 e5                	mov    %esp,%ebp
  802564:	57                   	push   %edi
  802565:	56                   	push   %esi
  802566:	53                   	push   %ebx
  802567:	8b 7d 08             	mov    0x8(%ebp),%edi
  80256a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80256d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802570:	85 f6                	test   %esi,%esi
  802572:	74 1c                	je     802590 <strncpy+0x2f>
  802574:	89 fa                	mov    %edi,%edx
  802576:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  80257b:	0f b6 01             	movzbl (%ecx),%eax
  80257e:	88 02                	mov    %al,(%edx)
  802580:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802583:	80 39 01             	cmpb   $0x1,(%ecx)
  802586:	83 d9 ff             	sbb    $0xffffffff,%ecx
  802589:	83 c3 01             	add    $0x1,%ebx
  80258c:	39 f3                	cmp    %esi,%ebx
  80258e:	75 eb                	jne    80257b <strncpy+0x1a>
	}
	return ret;
}
  802590:	89 f8                	mov    %edi,%eax
  802592:	5b                   	pop    %ebx
  802593:	5e                   	pop    %esi
  802594:	5f                   	pop    %edi
  802595:	5d                   	pop    %ebp
  802596:	c3                   	ret    

00802597 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802597:	55                   	push   %ebp
  802598:	89 e5                	mov    %esp,%ebp
  80259a:	56                   	push   %esi
  80259b:	53                   	push   %ebx
  80259c:	8b 75 08             	mov    0x8(%ebp),%esi
  80259f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025a2:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8025a5:	89 f0                	mov    %esi,%eax
  8025a7:	85 d2                	test   %edx,%edx
  8025a9:	74 2c                	je     8025d7 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  8025ab:	89 d3                	mov    %edx,%ebx
  8025ad:	83 eb 01             	sub    $0x1,%ebx
  8025b0:	74 20                	je     8025d2 <strlcpy+0x3b>
  8025b2:	0f b6 11             	movzbl (%ecx),%edx
  8025b5:	84 d2                	test   %dl,%dl
  8025b7:	74 19                	je     8025d2 <strlcpy+0x3b>
  8025b9:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  8025bb:	88 10                	mov    %dl,(%eax)
  8025bd:	83 c0 01             	add    $0x1,%eax
  8025c0:	83 eb 01             	sub    $0x1,%ebx
  8025c3:	74 0f                	je     8025d4 <strlcpy+0x3d>
  8025c5:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  8025c9:	83 c1 01             	add    $0x1,%ecx
  8025cc:	84 d2                	test   %dl,%dl
  8025ce:	74 04                	je     8025d4 <strlcpy+0x3d>
  8025d0:	eb e9                	jmp    8025bb <strlcpy+0x24>
  8025d2:	89 f0                	mov    %esi,%eax
		*dst = '\0';
  8025d4:	c6 00 00             	movb   $0x0,(%eax)
  8025d7:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8025d9:	5b                   	pop    %ebx
  8025da:	5e                   	pop    %esi
  8025db:	5d                   	pop    %ebp
  8025dc:	c3                   	ret    

008025dd <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  8025dd:	55                   	push   %ebp
  8025de:	89 e5                	mov    %esp,%ebp
  8025e0:	57                   	push   %edi
  8025e1:	56                   	push   %esi
  8025e2:	53                   	push   %ebx
  8025e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8025e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025e9:	8b 7d 10             	mov    0x10(%ebp),%edi
    int c;
    char *q = buf;

    if (buf_size <= 0)
  8025ec:	85 c9                	test   %ecx,%ecx
  8025ee:	7e 30                	jle    802620 <pstrcpy+0x43>
        return;

    for(;;) {
        c = *str++;
  8025f0:	0f b6 07             	movzbl (%edi),%eax
        if (c == 0 || q >= buf + buf_size - 1)
  8025f3:	84 c0                	test   %al,%al
  8025f5:	74 26                	je     80261d <pstrcpy+0x40>
  8025f7:	8d 74 0a ff          	lea    0xffffffff(%edx,%ecx,1),%esi
  8025fb:	0f be d8             	movsbl %al,%ebx
  8025fe:	89 f9                	mov    %edi,%ecx
  802600:	39 f2                	cmp    %esi,%edx
  802602:	72 09                	jb     80260d <pstrcpy+0x30>
  802604:	eb 17                	jmp    80261d <pstrcpy+0x40>
  802606:	83 c1 01             	add    $0x1,%ecx
  802609:	39 f2                	cmp    %esi,%edx
  80260b:	73 10                	jae    80261d <pstrcpy+0x40>
            break;
        *q++ = c;
  80260d:	88 1a                	mov    %bl,(%edx)
  80260f:	83 c2 01             	add    $0x1,%edx
  802612:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  802616:	0f be d8             	movsbl %al,%ebx
  802619:	84 c0                	test   %al,%al
  80261b:	75 e9                	jne    802606 <pstrcpy+0x29>
    }
    *q = '\0';
  80261d:	c6 02 00             	movb   $0x0,(%edx)
}
  802620:	5b                   	pop    %ebx
  802621:	5e                   	pop    %esi
  802622:	5f                   	pop    %edi
  802623:	5d                   	pop    %ebp
  802624:	c3                   	ret    

00802625 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  802625:	55                   	push   %ebp
  802626:	89 e5                	mov    %esp,%ebp
  802628:	8b 55 08             	mov    0x8(%ebp),%edx
  80262b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  80262e:	0f b6 02             	movzbl (%edx),%eax
  802631:	84 c0                	test   %al,%al
  802633:	74 16                	je     80264b <strcmp+0x26>
  802635:	3a 01                	cmp    (%ecx),%al
  802637:	75 12                	jne    80264b <strcmp+0x26>
		p++, q++;
  802639:	83 c1 01             	add    $0x1,%ecx
  80263c:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  802640:	84 c0                	test   %al,%al
  802642:	74 07                	je     80264b <strcmp+0x26>
  802644:	83 c2 01             	add    $0x1,%edx
  802647:	3a 01                	cmp    (%ecx),%al
  802649:	74 ee                	je     802639 <strcmp+0x14>
  80264b:	0f b6 c0             	movzbl %al,%eax
  80264e:	0f b6 11             	movzbl (%ecx),%edx
  802651:	29 d0                	sub    %edx,%eax
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  802653:	5d                   	pop    %ebp
  802654:	c3                   	ret    

00802655 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  802655:	55                   	push   %ebp
  802656:	89 e5                	mov    %esp,%ebp
  802658:	53                   	push   %ebx
  802659:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80265c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80265f:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  802662:	85 d2                	test   %edx,%edx
  802664:	74 2d                	je     802693 <strncmp+0x3e>
  802666:	0f b6 01             	movzbl (%ecx),%eax
  802669:	84 c0                	test   %al,%al
  80266b:	74 1a                	je     802687 <strncmp+0x32>
  80266d:	3a 03                	cmp    (%ebx),%al
  80266f:	75 16                	jne    802687 <strncmp+0x32>
  802671:	83 ea 01             	sub    $0x1,%edx
  802674:	74 1d                	je     802693 <strncmp+0x3e>
		n--, p++, q++;
  802676:	83 c1 01             	add    $0x1,%ecx
  802679:	83 c3 01             	add    $0x1,%ebx
  80267c:	0f b6 01             	movzbl (%ecx),%eax
  80267f:	84 c0                	test   %al,%al
  802681:	74 04                	je     802687 <strncmp+0x32>
  802683:	3a 03                	cmp    (%ebx),%al
  802685:	74 ea                	je     802671 <strncmp+0x1c>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  802687:	0f b6 11             	movzbl (%ecx),%edx
  80268a:	0f b6 03             	movzbl (%ebx),%eax
  80268d:	29 c2                	sub    %eax,%edx
  80268f:	89 d0                	mov    %edx,%eax
  802691:	eb 05                	jmp    802698 <strncmp+0x43>
  802693:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802698:	5b                   	pop    %ebx
  802699:	5d                   	pop    %ebp
  80269a:	c3                   	ret    

0080269b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80269b:	55                   	push   %ebp
  80269c:	89 e5                	mov    %esp,%ebp
  80269e:	8b 45 08             	mov    0x8(%ebp),%eax
  8026a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8026a5:	0f b6 10             	movzbl (%eax),%edx
  8026a8:	84 d2                	test   %dl,%dl
  8026aa:	74 16                	je     8026c2 <strchr+0x27>
		if (*s == c)
  8026ac:	38 ca                	cmp    %cl,%dl
  8026ae:	75 06                	jne    8026b6 <strchr+0x1b>
  8026b0:	eb 15                	jmp    8026c7 <strchr+0x2c>
  8026b2:	38 ca                	cmp    %cl,%dl
  8026b4:	74 11                	je     8026c7 <strchr+0x2c>
  8026b6:	83 c0 01             	add    $0x1,%eax
  8026b9:	0f b6 10             	movzbl (%eax),%edx
  8026bc:	84 d2                	test   %dl,%dl
  8026be:	66 90                	xchg   %ax,%ax
  8026c0:	75 f0                	jne    8026b2 <strchr+0x17>
  8026c2:	b8 00 00 00 00       	mov    $0x0,%eax
			return (char *) s;
	return 0;
}
  8026c7:	5d                   	pop    %ebp
  8026c8:	c3                   	ret    

008026c9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8026c9:	55                   	push   %ebp
  8026ca:	89 e5                	mov    %esp,%ebp
  8026cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8026cf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8026d3:	0f b6 10             	movzbl (%eax),%edx
  8026d6:	84 d2                	test   %dl,%dl
  8026d8:	74 14                	je     8026ee <strfind+0x25>
		if (*s == c)
  8026da:	38 ca                	cmp    %cl,%dl
  8026dc:	75 06                	jne    8026e4 <strfind+0x1b>
  8026de:	eb 0e                	jmp    8026ee <strfind+0x25>
  8026e0:	38 ca                	cmp    %cl,%dl
  8026e2:	74 0a                	je     8026ee <strfind+0x25>
  8026e4:	83 c0 01             	add    $0x1,%eax
  8026e7:	0f b6 10             	movzbl (%eax),%edx
  8026ea:	84 d2                	test   %dl,%dl
  8026ec:	75 f2                	jne    8026e0 <strfind+0x17>
			break;
	return (char *) s;
}
  8026ee:	5d                   	pop    %ebp
  8026ef:	90                   	nop    
  8026f0:	c3                   	ret    

008026f1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8026f1:	55                   	push   %ebp
  8026f2:	89 e5                	mov    %esp,%ebp
  8026f4:	83 ec 08             	sub    $0x8,%esp
  8026f7:	89 1c 24             	mov    %ebx,(%esp)
  8026fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8026fe:	8b 7d 08             	mov    0x8(%ebp),%edi
  802701:	8b 45 0c             	mov    0xc(%ebp),%eax
  802704:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  802707:	85 db                	test   %ebx,%ebx
  802709:	74 32                	je     80273d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80270b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802711:	75 25                	jne    802738 <memset+0x47>
  802713:	f6 c3 03             	test   $0x3,%bl
  802716:	75 20                	jne    802738 <memset+0x47>
		c &= 0xFF;
  802718:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80271b:	89 d0                	mov    %edx,%eax
  80271d:	c1 e0 18             	shl    $0x18,%eax
  802720:	89 d1                	mov    %edx,%ecx
  802722:	c1 e1 10             	shl    $0x10,%ecx
  802725:	09 c8                	or     %ecx,%eax
  802727:	09 d0                	or     %edx,%eax
  802729:	c1 e2 08             	shl    $0x8,%edx
  80272c:	09 d0                	or     %edx,%eax
  80272e:	89 d9                	mov    %ebx,%ecx
  802730:	c1 e9 02             	shr    $0x2,%ecx
  802733:	fc                   	cld    
  802734:	f3 ab                	rep stos %eax,%es:(%edi)
  802736:	eb 05                	jmp    80273d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802738:	89 d9                	mov    %ebx,%ecx
  80273a:	fc                   	cld    
  80273b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80273d:	89 f8                	mov    %edi,%eax
  80273f:	8b 1c 24             	mov    (%esp),%ebx
  802742:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802746:	89 ec                	mov    %ebp,%esp
  802748:	5d                   	pop    %ebp
  802749:	c3                   	ret    

0080274a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80274a:	55                   	push   %ebp
  80274b:	89 e5                	mov    %esp,%ebp
  80274d:	83 ec 08             	sub    $0x8,%esp
  802750:	89 34 24             	mov    %esi,(%esp)
  802753:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802757:	8b 45 08             	mov    0x8(%ebp),%eax
  80275a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  80275d:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  802760:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  802762:	39 c6                	cmp    %eax,%esi
  802764:	73 36                	jae    80279c <memmove+0x52>
  802766:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802769:	39 d0                	cmp    %edx,%eax
  80276b:	73 2f                	jae    80279c <memmove+0x52>
		s += n;
		d += n;
  80276d:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802770:	f6 c2 03             	test   $0x3,%dl
  802773:	75 1b                	jne    802790 <memmove+0x46>
  802775:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80277b:	75 13                	jne    802790 <memmove+0x46>
  80277d:	f6 c1 03             	test   $0x3,%cl
  802780:	75 0e                	jne    802790 <memmove+0x46>
			asm volatile("std; rep movsl\n"
  802782:	8d 7e fc             	lea    0xfffffffc(%esi),%edi
  802785:	8d 72 fc             	lea    0xfffffffc(%edx),%esi
  802788:	c1 e9 02             	shr    $0x2,%ecx
  80278b:	fd                   	std    
  80278c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80278e:	eb 09                	jmp    802799 <memmove+0x4f>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  802790:	8d 7e ff             	lea    0xffffffff(%esi),%edi
  802793:	8d 72 ff             	lea    0xffffffff(%edx),%esi
  802796:	fd                   	std    
  802797:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  802799:	fc                   	cld    
  80279a:	eb 21                	jmp    8027bd <memmove+0x73>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80279c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8027a2:	75 16                	jne    8027ba <memmove+0x70>
  8027a4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8027aa:	75 0e                	jne    8027ba <memmove+0x70>
  8027ac:	f6 c1 03             	test   $0x3,%cl
  8027af:	90                   	nop    
  8027b0:	75 08                	jne    8027ba <memmove+0x70>
			asm volatile("cld; rep movsl\n"
  8027b2:	c1 e9 02             	shr    $0x2,%ecx
  8027b5:	fc                   	cld    
  8027b6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8027b8:	eb 03                	jmp    8027bd <memmove+0x73>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8027ba:	fc                   	cld    
  8027bb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8027bd:	8b 34 24             	mov    (%esp),%esi
  8027c0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8027c4:	89 ec                	mov    %ebp,%esp
  8027c6:	5d                   	pop    %ebp
  8027c7:	c3                   	ret    

008027c8 <memcpy>:

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
  8027c8:	55                   	push   %ebp
  8027c9:	89 e5                	mov    %esp,%ebp
  8027cb:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8027ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8027d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8027d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8027df:	89 04 24             	mov    %eax,(%esp)
  8027e2:	e8 63 ff ff ff       	call   80274a <memmove>
}
  8027e7:	c9                   	leave  
  8027e8:	c3                   	ret    

008027e9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8027e9:	55                   	push   %ebp
  8027ea:	89 e5                	mov    %esp,%ebp
  8027ec:	56                   	push   %esi
  8027ed:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8027ee:	8b 75 10             	mov    0x10(%ebp),%esi
  8027f1:	83 ee 01             	sub    $0x1,%esi
  8027f4:	83 fe ff             	cmp    $0xffffffff,%esi
  8027f7:	74 38                	je     802831 <memcmp+0x48>
  8027f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8027fc:	8b 55 0c             	mov    0xc(%ebp),%edx
		if (*s1 != *s2)
  8027ff:	0f b6 18             	movzbl (%eax),%ebx
  802802:	0f b6 0a             	movzbl (%edx),%ecx
  802805:	38 cb                	cmp    %cl,%bl
  802807:	74 20                	je     802829 <memcmp+0x40>
  802809:	eb 12                	jmp    80281d <memcmp+0x34>
  80280b:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
  80280f:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
  802813:	83 c0 01             	add    $0x1,%eax
  802816:	83 c2 01             	add    $0x1,%edx
  802819:	38 cb                	cmp    %cl,%bl
  80281b:	74 0c                	je     802829 <memcmp+0x40>
			return (int) *s1 - (int) *s2;
  80281d:	0f b6 d3             	movzbl %bl,%edx
  802820:	0f b6 c1             	movzbl %cl,%eax
  802823:	29 c2                	sub    %eax,%edx
  802825:	89 d0                	mov    %edx,%eax
  802827:	eb 0d                	jmp    802836 <memcmp+0x4d>
  802829:	83 ee 01             	sub    $0x1,%esi
  80282c:	83 fe ff             	cmp    $0xffffffff,%esi
  80282f:	75 da                	jne    80280b <memcmp+0x22>
  802831:	b8 00 00 00 00       	mov    $0x0,%eax
		s1++, s2++;
	}

	return 0;
}
  802836:	5b                   	pop    %ebx
  802837:	5e                   	pop    %esi
  802838:	5d                   	pop    %ebp
  802839:	c3                   	ret    

0080283a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80283a:	55                   	push   %ebp
  80283b:	89 e5                	mov    %esp,%ebp
  80283d:	53                   	push   %ebx
  80283e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	const void *ends = (const char *) s + n;
  802841:	89 da                	mov    %ebx,%edx
  802843:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  802846:	39 d3                	cmp    %edx,%ebx
  802848:	73 1a                	jae    802864 <memfind+0x2a>
		if (*(const unsigned char *) s == (unsigned char) c)
  80284a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
			break;
  80284e:	89 d8                	mov    %ebx,%eax
  802850:	38 0b                	cmp    %cl,(%ebx)
  802852:	75 06                	jne    80285a <memfind+0x20>
  802854:	eb 0e                	jmp    802864 <memfind+0x2a>
  802856:	38 08                	cmp    %cl,(%eax)
  802858:	74 0c                	je     802866 <memfind+0x2c>
  80285a:	83 c0 01             	add    $0x1,%eax
  80285d:	39 d0                	cmp    %edx,%eax
  80285f:	90                   	nop    
  802860:	75 f4                	jne    802856 <memfind+0x1c>
  802862:	eb 02                	jmp    802866 <memfind+0x2c>
  802864:	89 d8                	mov    %ebx,%eax
	return (void *) s;
}
  802866:	5b                   	pop    %ebx
  802867:	5d                   	pop    %ebp
  802868:	c3                   	ret    

00802869 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802869:	55                   	push   %ebp
  80286a:	89 e5                	mov    %esp,%ebp
  80286c:	57                   	push   %edi
  80286d:	56                   	push   %esi
  80286e:	53                   	push   %ebx
  80286f:	83 ec 04             	sub    $0x4,%esp
  802872:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802875:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802878:	0f b6 03             	movzbl (%ebx),%eax
  80287b:	3c 20                	cmp    $0x20,%al
  80287d:	74 04                	je     802883 <strtol+0x1a>
  80287f:	3c 09                	cmp    $0x9,%al
  802881:	75 0e                	jne    802891 <strtol+0x28>
		s++;
  802883:	83 c3 01             	add    $0x1,%ebx
  802886:	0f b6 03             	movzbl (%ebx),%eax
  802889:	3c 20                	cmp    $0x20,%al
  80288b:	74 f6                	je     802883 <strtol+0x1a>
  80288d:	3c 09                	cmp    $0x9,%al
  80288f:	74 f2                	je     802883 <strtol+0x1a>

	// plus/minus sign
	if (*s == '+')
  802891:	3c 2b                	cmp    $0x2b,%al
  802893:	75 0d                	jne    8028a2 <strtol+0x39>
		s++;
  802895:	83 c3 01             	add    $0x1,%ebx
  802898:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  80289f:	90                   	nop    
  8028a0:	eb 15                	jmp    8028b7 <strtol+0x4e>
	else if (*s == '-')
  8028a2:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  8028a9:	3c 2d                	cmp    $0x2d,%al
  8028ab:	75 0a                	jne    8028b7 <strtol+0x4e>
		s++, neg = 1;
  8028ad:	83 c3 01             	add    $0x1,%ebx
  8028b0:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8028b7:	85 f6                	test   %esi,%esi
  8028b9:	0f 94 c0             	sete   %al
  8028bc:	84 c0                	test   %al,%al
  8028be:	75 05                	jne    8028c5 <strtol+0x5c>
  8028c0:	83 fe 10             	cmp    $0x10,%esi
  8028c3:	75 17                	jne    8028dc <strtol+0x73>
  8028c5:	80 3b 30             	cmpb   $0x30,(%ebx)
  8028c8:	75 12                	jne    8028dc <strtol+0x73>
  8028ca:	80 7b 01 78          	cmpb   $0x78,0x1(%ebx)
  8028ce:	66 90                	xchg   %ax,%ax
  8028d0:	75 0a                	jne    8028dc <strtol+0x73>
		s += 2, base = 16;
  8028d2:	83 c3 02             	add    $0x2,%ebx
  8028d5:	be 10 00 00 00       	mov    $0x10,%esi
  8028da:	eb 1f                	jmp    8028fb <strtol+0x92>
	else if (base == 0 && s[0] == '0')
  8028dc:	85 f6                	test   %esi,%esi
  8028de:	66 90                	xchg   %ax,%ax
  8028e0:	75 10                	jne    8028f2 <strtol+0x89>
  8028e2:	80 3b 30             	cmpb   $0x30,(%ebx)
  8028e5:	75 0b                	jne    8028f2 <strtol+0x89>
		s++, base = 8;
  8028e7:	83 c3 01             	add    $0x1,%ebx
  8028ea:	66 be 08 00          	mov    $0x8,%si
  8028ee:	66 90                	xchg   %ax,%ax
  8028f0:	eb 09                	jmp    8028fb <strtol+0x92>
	else if (base == 0)
  8028f2:	84 c0                	test   %al,%al
  8028f4:	74 05                	je     8028fb <strtol+0x92>
  8028f6:	be 0a 00 00 00       	mov    $0xa,%esi
  8028fb:	bf 00 00 00 00       	mov    $0x0,%edi
		base = 10;

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802900:	0f b6 13             	movzbl (%ebx),%edx
  802903:	89 d1                	mov    %edx,%ecx
  802905:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  802908:	3c 09                	cmp    $0x9,%al
  80290a:	77 08                	ja     802914 <strtol+0xab>
			dig = *s - '0';
  80290c:	0f be c2             	movsbl %dl,%eax
  80290f:	8d 50 d0             	lea    0xffffffd0(%eax),%edx
  802912:	eb 1c                	jmp    802930 <strtol+0xc7>
		else if (*s >= 'a' && *s <= 'z')
  802914:	8d 41 9f             	lea    0xffffff9f(%ecx),%eax
  802917:	3c 19                	cmp    $0x19,%al
  802919:	77 08                	ja     802923 <strtol+0xba>
			dig = *s - 'a' + 10;
  80291b:	0f be c2             	movsbl %dl,%eax
  80291e:	8d 50 a9             	lea    0xffffffa9(%eax),%edx
  802921:	eb 0d                	jmp    802930 <strtol+0xc7>
		else if (*s >= 'A' && *s <= 'Z')
  802923:	8d 41 bf             	lea    0xffffffbf(%ecx),%eax
  802926:	3c 19                	cmp    $0x19,%al
  802928:	77 17                	ja     802941 <strtol+0xd8>
			dig = *s - 'A' + 10;
  80292a:	0f be c2             	movsbl %dl,%eax
  80292d:	8d 50 c9             	lea    0xffffffc9(%eax),%edx
		else
			break;
		if (dig >= base)
  802930:	39 f2                	cmp    %esi,%edx
  802932:	7d 0d                	jge    802941 <strtol+0xd8>
			break;
		s++, val = (val * base) + dig;
  802934:	83 c3 01             	add    $0x1,%ebx
  802937:	89 f8                	mov    %edi,%eax
  802939:	0f af c6             	imul   %esi,%eax
  80293c:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  80293f:	eb bf                	jmp    802900 <strtol+0x97>
		// we don't properly detect overflow!
	}
  802941:	89 f8                	mov    %edi,%eax

	if (endptr)
  802943:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802947:	74 05                	je     80294e <strtol+0xe5>
		*endptr = (char *) s;
  802949:	8b 55 0c             	mov    0xc(%ebp),%edx
  80294c:	89 1a                	mov    %ebx,(%edx)
	return (neg ? -val : val);
  80294e:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  802952:	74 04                	je     802958 <strtol+0xef>
  802954:	89 c7                	mov    %eax,%edi
  802956:	f7 df                	neg    %edi
}
  802958:	89 f8                	mov    %edi,%eax
  80295a:	83 c4 04             	add    $0x4,%esp
  80295d:	5b                   	pop    %ebx
  80295e:	5e                   	pop    %esi
  80295f:	5f                   	pop    %edi
  802960:	5d                   	pop    %ebp
  802961:	c3                   	ret    
	...

00802964 <sys_cgetc>:
}

int
sys_cgetc(void)
{
  802964:	55                   	push   %ebp
  802965:	89 e5                	mov    %esp,%ebp
  802967:	83 ec 0c             	sub    $0xc,%esp
  80296a:	89 1c 24             	mov    %ebx,(%esp)
  80296d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802971:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802975:	b8 01 00 00 00       	mov    $0x1,%eax
  80297a:	bf 00 00 00 00       	mov    $0x0,%edi
  80297f:	89 fa                	mov    %edi,%edx
  802981:	89 f9                	mov    %edi,%ecx
  802983:	89 fb                	mov    %edi,%ebx
  802985:	89 fe                	mov    %edi,%esi
  802987:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  802989:	8b 1c 24             	mov    (%esp),%ebx
  80298c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802990:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802994:	89 ec                	mov    %ebp,%esp
  802996:	5d                   	pop    %ebp
  802997:	c3                   	ret    

00802998 <sys_cputs>:
  802998:	55                   	push   %ebp
  802999:	89 e5                	mov    %esp,%ebp
  80299b:	83 ec 0c             	sub    $0xc,%esp
  80299e:	89 1c 24             	mov    %ebx,(%esp)
  8029a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029a5:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8029a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8029ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8029af:	bf 00 00 00 00       	mov    $0x0,%edi
  8029b4:	89 f8                	mov    %edi,%eax
  8029b6:	89 fb                	mov    %edi,%ebx
  8029b8:	89 fe                	mov    %edi,%esi
  8029ba:	cd 30                	int    $0x30
  8029bc:	8b 1c 24             	mov    (%esp),%ebx
  8029bf:	8b 74 24 04          	mov    0x4(%esp),%esi
  8029c3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8029c7:	89 ec                	mov    %ebp,%esp
  8029c9:	5d                   	pop    %ebp
  8029ca:	c3                   	ret    

008029cb <sys_time_msec>:

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  8029cb:	55                   	push   %ebp
  8029cc:	89 e5                	mov    %esp,%ebp
  8029ce:	83 ec 0c             	sub    $0xc,%esp
  8029d1:	89 1c 24             	mov    %ebx,(%esp)
  8029d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029d8:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8029dc:	b8 0e 00 00 00       	mov    $0xe,%eax
  8029e1:	bf 00 00 00 00       	mov    $0x0,%edi
  8029e6:	89 fa                	mov    %edi,%edx
  8029e8:	89 f9                	mov    %edi,%ecx
  8029ea:	89 fb                	mov    %edi,%ebx
  8029ec:	89 fe                	mov    %edi,%esi
  8029ee:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8029f0:	8b 1c 24             	mov    (%esp),%ebx
  8029f3:	8b 74 24 04          	mov    0x4(%esp),%esi
  8029f7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8029fb:	89 ec                	mov    %ebp,%esp
  8029fd:	5d                   	pop    %ebp
  8029fe:	c3                   	ret    

008029ff <sys_ipc_recv>:
  8029ff:	55                   	push   %ebp
  802a00:	89 e5                	mov    %esp,%ebp
  802a02:	83 ec 28             	sub    $0x28,%esp
  802a05:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  802a08:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  802a0b:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  802a0e:	8b 55 08             	mov    0x8(%ebp),%edx
  802a11:	b8 0d 00 00 00       	mov    $0xd,%eax
  802a16:	bf 00 00 00 00       	mov    $0x0,%edi
  802a1b:	89 f9                	mov    %edi,%ecx
  802a1d:	89 fb                	mov    %edi,%ebx
  802a1f:	89 fe                	mov    %edi,%esi
  802a21:	cd 30                	int    $0x30
  802a23:	85 c0                	test   %eax,%eax
  802a25:	7e 28                	jle    802a4f <sys_ipc_recv+0x50>
  802a27:	89 44 24 10          	mov    %eax,0x10(%esp)
  802a2b:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  802a32:	00 
  802a33:	c7 44 24 08 3f 49 80 	movl   $0x80493f,0x8(%esp)
  802a3a:	00 
  802a3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802a42:	00 
  802a43:	c7 04 24 5c 49 80 00 	movl   $0x80495c,(%esp)
  802a4a:	e8 a5 f3 ff ff       	call   801df4 <_panic>
  802a4f:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  802a52:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  802a55:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  802a58:	89 ec                	mov    %ebp,%esp
  802a5a:	5d                   	pop    %ebp
  802a5b:	c3                   	ret    

00802a5c <sys_ipc_try_send>:
  802a5c:	55                   	push   %ebp
  802a5d:	89 e5                	mov    %esp,%ebp
  802a5f:	83 ec 0c             	sub    $0xc,%esp
  802a62:	89 1c 24             	mov    %ebx,(%esp)
  802a65:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a69:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802a6d:	8b 55 08             	mov    0x8(%ebp),%edx
  802a70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802a76:	8b 7d 14             	mov    0x14(%ebp),%edi
  802a79:	b8 0c 00 00 00       	mov    $0xc,%eax
  802a7e:	be 00 00 00 00       	mov    $0x0,%esi
  802a83:	cd 30                	int    $0x30
  802a85:	8b 1c 24             	mov    (%esp),%ebx
  802a88:	8b 74 24 04          	mov    0x4(%esp),%esi
  802a8c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802a90:	89 ec                	mov    %ebp,%esp
  802a92:	5d                   	pop    %ebp
  802a93:	c3                   	ret    

00802a94 <sys_env_set_pgfault_upcall>:
  802a94:	55                   	push   %ebp
  802a95:	89 e5                	mov    %esp,%ebp
  802a97:	83 ec 28             	sub    $0x28,%esp
  802a9a:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  802a9d:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  802aa0:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  802aa3:	8b 55 08             	mov    0x8(%ebp),%edx
  802aa6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802aa9:	b8 0a 00 00 00       	mov    $0xa,%eax
  802aae:	bf 00 00 00 00       	mov    $0x0,%edi
  802ab3:	89 fb                	mov    %edi,%ebx
  802ab5:	89 fe                	mov    %edi,%esi
  802ab7:	cd 30                	int    $0x30
  802ab9:	85 c0                	test   %eax,%eax
  802abb:	7e 28                	jle    802ae5 <sys_env_set_pgfault_upcall+0x51>
  802abd:	89 44 24 10          	mov    %eax,0x10(%esp)
  802ac1:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  802ac8:	00 
  802ac9:	c7 44 24 08 3f 49 80 	movl   $0x80493f,0x8(%esp)
  802ad0:	00 
  802ad1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802ad8:	00 
  802ad9:	c7 04 24 5c 49 80 00 	movl   $0x80495c,(%esp)
  802ae0:	e8 0f f3 ff ff       	call   801df4 <_panic>
  802ae5:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  802ae8:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  802aeb:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  802aee:	89 ec                	mov    %ebp,%esp
  802af0:	5d                   	pop    %ebp
  802af1:	c3                   	ret    

00802af2 <sys_env_set_trapframe>:
  802af2:	55                   	push   %ebp
  802af3:	89 e5                	mov    %esp,%ebp
  802af5:	83 ec 28             	sub    $0x28,%esp
  802af8:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  802afb:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  802afe:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  802b01:	8b 55 08             	mov    0x8(%ebp),%edx
  802b04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802b07:	b8 09 00 00 00       	mov    $0x9,%eax
  802b0c:	bf 00 00 00 00       	mov    $0x0,%edi
  802b11:	89 fb                	mov    %edi,%ebx
  802b13:	89 fe                	mov    %edi,%esi
  802b15:	cd 30                	int    $0x30
  802b17:	85 c0                	test   %eax,%eax
  802b19:	7e 28                	jle    802b43 <sys_env_set_trapframe+0x51>
  802b1b:	89 44 24 10          	mov    %eax,0x10(%esp)
  802b1f:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  802b26:	00 
  802b27:	c7 44 24 08 3f 49 80 	movl   $0x80493f,0x8(%esp)
  802b2e:	00 
  802b2f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802b36:	00 
  802b37:	c7 04 24 5c 49 80 00 	movl   $0x80495c,(%esp)
  802b3e:	e8 b1 f2 ff ff       	call   801df4 <_panic>
  802b43:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  802b46:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  802b49:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  802b4c:	89 ec                	mov    %ebp,%esp
  802b4e:	5d                   	pop    %ebp
  802b4f:	c3                   	ret    

00802b50 <sys_env_set_status>:
  802b50:	55                   	push   %ebp
  802b51:	89 e5                	mov    %esp,%ebp
  802b53:	83 ec 28             	sub    $0x28,%esp
  802b56:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  802b59:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  802b5c:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  802b5f:	8b 55 08             	mov    0x8(%ebp),%edx
  802b62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802b65:	b8 08 00 00 00       	mov    $0x8,%eax
  802b6a:	bf 00 00 00 00       	mov    $0x0,%edi
  802b6f:	89 fb                	mov    %edi,%ebx
  802b71:	89 fe                	mov    %edi,%esi
  802b73:	cd 30                	int    $0x30
  802b75:	85 c0                	test   %eax,%eax
  802b77:	7e 28                	jle    802ba1 <sys_env_set_status+0x51>
  802b79:	89 44 24 10          	mov    %eax,0x10(%esp)
  802b7d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  802b84:	00 
  802b85:	c7 44 24 08 3f 49 80 	movl   $0x80493f,0x8(%esp)
  802b8c:	00 
  802b8d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802b94:	00 
  802b95:	c7 04 24 5c 49 80 00 	movl   $0x80495c,(%esp)
  802b9c:	e8 53 f2 ff ff       	call   801df4 <_panic>
  802ba1:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  802ba4:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  802ba7:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  802baa:	89 ec                	mov    %ebp,%esp
  802bac:	5d                   	pop    %ebp
  802bad:	c3                   	ret    

00802bae <sys_page_unmap>:
  802bae:	55                   	push   %ebp
  802baf:	89 e5                	mov    %esp,%ebp
  802bb1:	83 ec 28             	sub    $0x28,%esp
  802bb4:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  802bb7:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  802bba:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  802bbd:	8b 55 08             	mov    0x8(%ebp),%edx
  802bc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802bc3:	b8 06 00 00 00       	mov    $0x6,%eax
  802bc8:	bf 00 00 00 00       	mov    $0x0,%edi
  802bcd:	89 fb                	mov    %edi,%ebx
  802bcf:	89 fe                	mov    %edi,%esi
  802bd1:	cd 30                	int    $0x30
  802bd3:	85 c0                	test   %eax,%eax
  802bd5:	7e 28                	jle    802bff <sys_page_unmap+0x51>
  802bd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  802bdb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  802be2:	00 
  802be3:	c7 44 24 08 3f 49 80 	movl   $0x80493f,0x8(%esp)
  802bea:	00 
  802beb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802bf2:	00 
  802bf3:	c7 04 24 5c 49 80 00 	movl   $0x80495c,(%esp)
  802bfa:	e8 f5 f1 ff ff       	call   801df4 <_panic>
  802bff:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  802c02:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  802c05:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  802c08:	89 ec                	mov    %ebp,%esp
  802c0a:	5d                   	pop    %ebp
  802c0b:	c3                   	ret    

00802c0c <sys_page_map>:
  802c0c:	55                   	push   %ebp
  802c0d:	89 e5                	mov    %esp,%ebp
  802c0f:	83 ec 28             	sub    $0x28,%esp
  802c12:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  802c15:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  802c18:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  802c1b:	8b 55 08             	mov    0x8(%ebp),%edx
  802c1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c21:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802c24:	8b 7d 14             	mov    0x14(%ebp),%edi
  802c27:	8b 75 18             	mov    0x18(%ebp),%esi
  802c2a:	b8 05 00 00 00       	mov    $0x5,%eax
  802c2f:	cd 30                	int    $0x30
  802c31:	85 c0                	test   %eax,%eax
  802c33:	7e 28                	jle    802c5d <sys_page_map+0x51>
  802c35:	89 44 24 10          	mov    %eax,0x10(%esp)
  802c39:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  802c40:	00 
  802c41:	c7 44 24 08 3f 49 80 	movl   $0x80493f,0x8(%esp)
  802c48:	00 
  802c49:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802c50:	00 
  802c51:	c7 04 24 5c 49 80 00 	movl   $0x80495c,(%esp)
  802c58:	e8 97 f1 ff ff       	call   801df4 <_panic>
  802c5d:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  802c60:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  802c63:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  802c66:	89 ec                	mov    %ebp,%esp
  802c68:	5d                   	pop    %ebp
  802c69:	c3                   	ret    

00802c6a <sys_page_alloc>:
  802c6a:	55                   	push   %ebp
  802c6b:	89 e5                	mov    %esp,%ebp
  802c6d:	83 ec 28             	sub    $0x28,%esp
  802c70:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  802c73:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  802c76:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  802c79:	8b 55 08             	mov    0x8(%ebp),%edx
  802c7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802c82:	b8 04 00 00 00       	mov    $0x4,%eax
  802c87:	bf 00 00 00 00       	mov    $0x0,%edi
  802c8c:	89 fe                	mov    %edi,%esi
  802c8e:	cd 30                	int    $0x30
  802c90:	85 c0                	test   %eax,%eax
  802c92:	7e 28                	jle    802cbc <sys_page_alloc+0x52>
  802c94:	89 44 24 10          	mov    %eax,0x10(%esp)
  802c98:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  802c9f:	00 
  802ca0:	c7 44 24 08 3f 49 80 	movl   $0x80493f,0x8(%esp)
  802ca7:	00 
  802ca8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802caf:	00 
  802cb0:	c7 04 24 5c 49 80 00 	movl   $0x80495c,(%esp)
  802cb7:	e8 38 f1 ff ff       	call   801df4 <_panic>
  802cbc:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  802cbf:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  802cc2:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  802cc5:	89 ec                	mov    %ebp,%esp
  802cc7:	5d                   	pop    %ebp
  802cc8:	c3                   	ret    

00802cc9 <sys_yield>:
  802cc9:	55                   	push   %ebp
  802cca:	89 e5                	mov    %esp,%ebp
  802ccc:	83 ec 0c             	sub    $0xc,%esp
  802ccf:	89 1c 24             	mov    %ebx,(%esp)
  802cd2:	89 74 24 04          	mov    %esi,0x4(%esp)
  802cd6:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802cda:	b8 0b 00 00 00       	mov    $0xb,%eax
  802cdf:	bf 00 00 00 00       	mov    $0x0,%edi
  802ce4:	89 fa                	mov    %edi,%edx
  802ce6:	89 f9                	mov    %edi,%ecx
  802ce8:	89 fb                	mov    %edi,%ebx
  802cea:	89 fe                	mov    %edi,%esi
  802cec:	cd 30                	int    $0x30
  802cee:	8b 1c 24             	mov    (%esp),%ebx
  802cf1:	8b 74 24 04          	mov    0x4(%esp),%esi
  802cf5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802cf9:	89 ec                	mov    %ebp,%esp
  802cfb:	5d                   	pop    %ebp
  802cfc:	c3                   	ret    

00802cfd <sys_getenvid>:
  802cfd:	55                   	push   %ebp
  802cfe:	89 e5                	mov    %esp,%ebp
  802d00:	83 ec 0c             	sub    $0xc,%esp
  802d03:	89 1c 24             	mov    %ebx,(%esp)
  802d06:	89 74 24 04          	mov    %esi,0x4(%esp)
  802d0a:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802d0e:	b8 02 00 00 00       	mov    $0x2,%eax
  802d13:	bf 00 00 00 00       	mov    $0x0,%edi
  802d18:	89 fa                	mov    %edi,%edx
  802d1a:	89 f9                	mov    %edi,%ecx
  802d1c:	89 fb                	mov    %edi,%ebx
  802d1e:	89 fe                	mov    %edi,%esi
  802d20:	cd 30                	int    $0x30
  802d22:	8b 1c 24             	mov    (%esp),%ebx
  802d25:	8b 74 24 04          	mov    0x4(%esp),%esi
  802d29:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802d2d:	89 ec                	mov    %ebp,%esp
  802d2f:	5d                   	pop    %ebp
  802d30:	c3                   	ret    

00802d31 <sys_env_destroy>:
  802d31:	55                   	push   %ebp
  802d32:	89 e5                	mov    %esp,%ebp
  802d34:	83 ec 28             	sub    $0x28,%esp
  802d37:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  802d3a:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  802d3d:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  802d40:	8b 55 08             	mov    0x8(%ebp),%edx
  802d43:	b8 03 00 00 00       	mov    $0x3,%eax
  802d48:	bf 00 00 00 00       	mov    $0x0,%edi
  802d4d:	89 f9                	mov    %edi,%ecx
  802d4f:	89 fb                	mov    %edi,%ebx
  802d51:	89 fe                	mov    %edi,%esi
  802d53:	cd 30                	int    $0x30
  802d55:	85 c0                	test   %eax,%eax
  802d57:	7e 28                	jle    802d81 <sys_env_destroy+0x50>
  802d59:	89 44 24 10          	mov    %eax,0x10(%esp)
  802d5d:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  802d64:	00 
  802d65:	c7 44 24 08 3f 49 80 	movl   $0x80493f,0x8(%esp)
  802d6c:	00 
  802d6d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802d74:	00 
  802d75:	c7 04 24 5c 49 80 00 	movl   $0x80495c,(%esp)
  802d7c:	e8 73 f0 ff ff       	call   801df4 <_panic>
  802d81:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  802d84:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  802d87:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  802d8a:	89 ec                	mov    %ebp,%esp
  802d8c:	5d                   	pop    %ebp
  802d8d:	c3                   	ret    
	...

00802d90 <set_pgfault_handler>:
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802d90:	55                   	push   %ebp
  802d91:	89 e5                	mov    %esp,%ebp
  802d93:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802d96:	83 3d b0 c0 80 00 00 	cmpl   $0x0,0x80c0b0
  802d9d:	75 6a                	jne    802e09 <set_pgfault_handler+0x79>
		// First time through!
		// LAB 4: Your code here.
		env=(struct Env*)&envs[ENVX(sys_getenvid())];
  802d9f:	e8 59 ff ff ff       	call   802cfd <sys_getenvid>
  802da4:	25 ff 03 00 00       	and    $0x3ff,%eax
  802da9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802dac:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802db1:	a3 a8 c0 80 00       	mov    %eax,0x80c0a8
		if((r=sys_page_alloc(env->env_id,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  802db6:	8b 40 4c             	mov    0x4c(%eax),%eax
  802db9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802dc0:	00 
  802dc1:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802dc8:	ee 
  802dc9:	89 04 24             	mov    %eax,(%esp)
  802dcc:	e8 99 fe ff ff       	call   802c6a <sys_page_alloc>
  802dd1:	85 c0                	test   %eax,%eax
  802dd3:	79 1c                	jns    802df1 <set_pgfault_handler+0x61>
		{
			panic("Alloc a page for an exception stack failed");
  802dd5:	c7 44 24 08 6c 49 80 	movl   $0x80496c,0x8(%esp)
  802ddc:	00 
  802ddd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802de4:	00 
  802de5:	c7 04 24 97 49 80 00 	movl   $0x804997,(%esp)
  802dec:	e8 03 f0 ff ff       	call   801df4 <_panic>
		}
		sys_env_set_pgfault_upcall(env->env_id,(void*)_pgfault_upcall);
  802df1:	a1 a8 c0 80 00       	mov    0x80c0a8,%eax
  802df6:	8b 40 4c             	mov    0x4c(%eax),%eax
  802df9:	c7 44 24 04 14 2e 80 	movl   $0x802e14,0x4(%esp)
  802e00:	00 
  802e01:	89 04 24             	mov    %eax,(%esp)
  802e04:	e8 8b fc ff ff       	call   802a94 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802e09:	8b 45 08             	mov    0x8(%ebp),%eax
  802e0c:	a3 b0 c0 80 00       	mov    %eax,0x80c0b0
}
  802e11:	c9                   	leave  
  802e12:	c3                   	ret    
	...

00802e14 <_pgfault_upcall>:
.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802e14:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802e15:	a1 b0 c0 80 00       	mov    0x80c0b0,%eax
	call *%eax
  802e1a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802e1c:	83 c4 04             	add    $0x4,%esp
	
	// Now the C page fault handler has returned and you must return
	// to the trap time state.
	// Push trap-time %eip onto the trap-time stack.
	//
	// Explanation:
	//   We must prepare the trap-time stack for our eventual return to
	//   re-execute the instruction that faulted.
	//   Unfortunately, we can't return directly from the exception stack:
	//   We can't call 'jmp', since that requires that we load the address
	//   into a register, and all registers must have their trap-time
	//   values after the return.
	//   We can't call 'ret' from the exception stack either, since if we
	//   did, %esp would have the wrong value.
	//   So instead, we push the trap-time %eip onto the *trap-time* stack!
	//   Below we'll switch to that stack and call 'ret', which will
	//   restore %eip to its pre-fault value.
	//
	//   In the case of a recursive fault on the exception stack,
	//   note that the word we're pushing now will fit in the
	//   blank word that the kernel reserved for us.
	//
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.这个有点难度，需要认真编写
	movl  0x28(%esp),%eax //把utf->utf_eip入栈
  802e1f:	8b 44 24 28          	mov    0x28(%esp),%eax
	pushl %eax
  802e23:	50                   	push   %eax
	movl %esp,%eax
  802e24:	89 e0                	mov    %esp,%eax
	movl 0x34(%eax),%esp  //切换到用户普通栈，压入utf_eip
  802e26:	8b 60 34             	mov    0x34(%eax),%esp
	pushl (%eax)
  802e29:	ff 30                	pushl  (%eax)
	movl %eax,%esp	     //切到用户异常栈
  802e2b:	89 c4                	mov    %eax,%esp
	subl $0x4,0x34(%esp) //将utf->utf_esp减去4,指向返回地址,后面不能算术操作，就在这算
  802e2d:	83 6c 24 34 04       	subl   $0x4,0x34(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0xc,%esp     //恢复通用寄存器
  802e32:	83 c4 0c             	add    $0xc,%esp
	popal
  802e35:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp  //恢复eflags
  802e36:	83 c4 04             	add    $0x4,%esp
	popfl          //在用户态，该指令能否修改eflags?可以的
  802e39:	9d                   	popf   
		       //执行完这个指令后，不能进行算术任何算术运算哦，否则eflags里面的值不对
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp     //切换到用户普通栈，用户从异常处理退出后，需要继续使用该栈
  802e3a:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802e3b:	c3                   	ret    
  802e3c:	00 00                	add    %al,(%eax)
	...

00802e40 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802e40:	55                   	push   %ebp
  802e41:	89 e5                	mov    %esp,%ebp
  802e43:	57                   	push   %edi
  802e44:	56                   	push   %esi
  802e45:	53                   	push   %ebx
  802e46:	83 ec 1c             	sub    $0x1c,%esp
  802e49:	8b 75 08             	mov    0x8(%ebp),%esi
  802e4c:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  802e4f:	e8 a9 fe ff ff       	call   802cfd <sys_getenvid>
  802e54:	25 ff 03 00 00       	and    $0x3ff,%eax
  802e59:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802e5c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802e61:	a3 a8 c0 80 00       	mov    %eax,0x80c0a8
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  802e66:	e8 92 fe ff ff       	call   802cfd <sys_getenvid>
  802e6b:	25 ff 03 00 00       	and    $0x3ff,%eax
  802e70:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802e73:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802e78:	a3 a8 c0 80 00       	mov    %eax,0x80c0a8
		if(env->env_id==to_env){
  802e7d:	8b 40 4c             	mov    0x4c(%eax),%eax
  802e80:	39 f0                	cmp    %esi,%eax
  802e82:	75 0e                	jne    802e92 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  802e84:	c7 04 24 a5 49 80 00 	movl   $0x8049a5,(%esp)
  802e8b:	e8 31 f0 ff ff       	call   801ec1 <cprintf>
  802e90:	eb 5a                	jmp    802eec <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  802e92:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802e96:	8b 45 10             	mov    0x10(%ebp),%eax
  802e99:	89 44 24 08          	mov    %eax,0x8(%esp)
  802e9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ea0:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ea4:	89 34 24             	mov    %esi,(%esp)
  802ea7:	e8 b0 fb ff ff       	call   802a5c <sys_ipc_try_send>
  802eac:	89 c3                	mov    %eax,%ebx
  802eae:	85 c0                	test   %eax,%eax
  802eb0:	79 25                	jns    802ed7 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  802eb2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802eb5:	74 2b                	je     802ee2 <ipc_send+0xa2>
				panic("send error:%e",r);
  802eb7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802ebb:	c7 44 24 08 c1 49 80 	movl   $0x8049c1,0x8(%esp)
  802ec2:	00 
  802ec3:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  802eca:	00 
  802ecb:	c7 04 24 cf 49 80 00 	movl   $0x8049cf,(%esp)
  802ed2:	e8 1d ef ff ff       	call   801df4 <_panic>
		}
			sys_yield();
  802ed7:	e8 ed fd ff ff       	call   802cc9 <sys_yield>
		
	}while(r!=0);
  802edc:	85 db                	test   %ebx,%ebx
  802ede:	75 86                	jne    802e66 <ipc_send+0x26>
  802ee0:	eb 0a                	jmp    802eec <ipc_send+0xac>
  802ee2:	e8 e2 fd ff ff       	call   802cc9 <sys_yield>
  802ee7:	e9 7a ff ff ff       	jmp    802e66 <ipc_send+0x26>
	return;
	//panic("ipc_send not implemented");
}
  802eec:	83 c4 1c             	add    $0x1c,%esp
  802eef:	5b                   	pop    %ebx
  802ef0:	5e                   	pop    %esi
  802ef1:	5f                   	pop    %edi
  802ef2:	5d                   	pop    %ebp
  802ef3:	c3                   	ret    

00802ef4 <ipc_recv>:
  802ef4:	55                   	push   %ebp
  802ef5:	89 e5                	mov    %esp,%ebp
  802ef7:	57                   	push   %edi
  802ef8:	56                   	push   %esi
  802ef9:	53                   	push   %ebx
  802efa:	83 ec 0c             	sub    $0xc,%esp
  802efd:	8b 75 08             	mov    0x8(%ebp),%esi
  802f00:	8b 7d 10             	mov    0x10(%ebp),%edi
  802f03:	e8 f5 fd ff ff       	call   802cfd <sys_getenvid>
  802f08:	25 ff 03 00 00       	and    $0x3ff,%eax
  802f0d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802f10:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802f15:	a3 a8 c0 80 00       	mov    %eax,0x80c0a8
  802f1a:	85 f6                	test   %esi,%esi
  802f1c:	74 29                	je     802f47 <ipc_recv+0x53>
  802f1e:	8b 40 4c             	mov    0x4c(%eax),%eax
  802f21:	3b 06                	cmp    (%esi),%eax
  802f23:	75 22                	jne    802f47 <ipc_recv+0x53>
  802f25:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802f2b:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  802f31:	c7 04 24 a5 49 80 00 	movl   $0x8049a5,(%esp)
  802f38:	e8 84 ef ff ff       	call   801ec1 <cprintf>
  802f3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802f42:	e9 8a 00 00 00       	jmp    802fd1 <ipc_recv+0xdd>
  802f47:	e8 b1 fd ff ff       	call   802cfd <sys_getenvid>
  802f4c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802f51:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802f54:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802f59:	a3 a8 c0 80 00       	mov    %eax,0x80c0a8
  802f5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f61:	89 04 24             	mov    %eax,(%esp)
  802f64:	e8 96 fa ff ff       	call   8029ff <sys_ipc_recv>
  802f69:	89 c3                	mov    %eax,%ebx
  802f6b:	85 c0                	test   %eax,%eax
  802f6d:	79 1a                	jns    802f89 <ipc_recv+0x95>
  802f6f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802f75:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  802f7b:	c7 04 24 d9 49 80 00 	movl   $0x8049d9,(%esp)
  802f82:	e8 3a ef ff ff       	call   801ec1 <cprintf>
  802f87:	eb 48                	jmp    802fd1 <ipc_recv+0xdd>
  802f89:	e8 6f fd ff ff       	call   802cfd <sys_getenvid>
  802f8e:	25 ff 03 00 00       	and    $0x3ff,%eax
  802f93:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802f96:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802f9b:	a3 a8 c0 80 00       	mov    %eax,0x80c0a8
  802fa0:	85 f6                	test   %esi,%esi
  802fa2:	74 05                	je     802fa9 <ipc_recv+0xb5>
  802fa4:	8b 40 74             	mov    0x74(%eax),%eax
  802fa7:	89 06                	mov    %eax,(%esi)
  802fa9:	85 ff                	test   %edi,%edi
  802fab:	74 0a                	je     802fb7 <ipc_recv+0xc3>
  802fad:	a1 a8 c0 80 00       	mov    0x80c0a8,%eax
  802fb2:	8b 40 78             	mov    0x78(%eax),%eax
  802fb5:	89 07                	mov    %eax,(%edi)
  802fb7:	e8 41 fd ff ff       	call   802cfd <sys_getenvid>
  802fbc:	25 ff 03 00 00       	and    $0x3ff,%eax
  802fc1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802fc4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802fc9:	a3 a8 c0 80 00       	mov    %eax,0x80c0a8
  802fce:	8b 58 70             	mov    0x70(%eax),%ebx
  802fd1:	89 d8                	mov    %ebx,%eax
  802fd3:	83 c4 0c             	add    $0xc,%esp
  802fd6:	5b                   	pop    %ebx
  802fd7:	5e                   	pop    %esi
  802fd8:	5f                   	pop    %edi
  802fd9:	5d                   	pop    %ebp
  802fda:	c3                   	ret    
  802fdb:	00 00                	add    %al,(%eax)
  802fdd:	00 00                	add    %al,(%eax)
	...

00802fe0 <fd2num>:
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802fe0:	55                   	push   %ebp
  802fe1:	89 e5                	mov    %esp,%ebp
  802fe3:	8b 45 08             	mov    0x8(%ebp),%eax
  802fe6:	05 00 00 00 30       	add    $0x30000000,%eax
  802feb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  802fee:	5d                   	pop    %ebp
  802fef:	c3                   	ret    

00802ff0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802ff0:	55                   	push   %ebp
  802ff1:	89 e5                	mov    %esp,%ebp
  802ff3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  802ff6:	8b 45 08             	mov    0x8(%ebp),%eax
  802ff9:	89 04 24             	mov    %eax,(%esp)
  802ffc:	e8 df ff ff ff       	call   802fe0 <fd2num>
  803001:	c1 e0 0c             	shl    $0xc,%eax
  803004:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  803009:	c9                   	leave  
  80300a:	c3                   	ret    

0080300b <fd_alloc>:

// Finds the smallest i from 0 to MAXFD-1 that doesn't have
// its fd page mapped.
// Sets *fd_store to the corresponding fd page virtual address.
//
// fd_alloc does NOT actually allocate an fd page.
// It is up to the caller to allocate the page somehow.
// This means that if someone calls fd_alloc twice in a row
// without allocating the first page we return, we'll return the same
// page the second time.
//
// Hint: Use INDEX2FD.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80300b:	55                   	push   %ebp
  80300c:	89 e5                	mov    %esp,%ebp
  80300e:	53                   	push   %ebx
  80300f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  803012:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  803017:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  803019:	89 d0                	mov    %edx,%eax
  80301b:	c1 e8 16             	shr    $0x16,%eax
  80301e:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  803025:	a8 01                	test   $0x1,%al
  803027:	74 10                	je     803039 <fd_alloc+0x2e>
  803029:	89 d0                	mov    %edx,%eax
  80302b:	c1 e8 0c             	shr    $0xc,%eax
  80302e:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  803035:	a8 01                	test   $0x1,%al
  803037:	75 09                	jne    803042 <fd_alloc+0x37>
			*fd_store = fd;
  803039:	89 0b                	mov    %ecx,(%ebx)
  80303b:	b8 00 00 00 00       	mov    $0x0,%eax
  803040:	eb 19                	jmp    80305b <fd_alloc+0x50>
			return 0;
  803042:	81 c2 00 10 00 00    	add    $0x1000,%edx
  803048:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  80304e:	75 c7                	jne    803017 <fd_alloc+0xc>
		}
	}
	*fd_store = 0;
  803050:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  803056:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  80305b:	5b                   	pop    %ebx
  80305c:	5d                   	pop    %ebp
  80305d:	c3                   	ret    

0080305e <fd_lookup>:

// Check that fdnum is in range and mapped.
// If it is, set *fd_store to the fd page virtual address.
//
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80305e:	55                   	push   %ebp
  80305f:	89 e5                	mov    %esp,%ebp
  803061:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  803064:	83 f8 1f             	cmp    $0x1f,%eax
  803067:	77 35                	ja     80309e <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  803069:	c1 e0 0c             	shl    $0xc,%eax
  80306c:	8d 90 00 00 00 d0    	lea    0xd0000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  803072:	89 d0                	mov    %edx,%eax
  803074:	c1 e8 16             	shr    $0x16,%eax
  803077:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  80307e:	a8 01                	test   $0x1,%al
  803080:	74 1c                	je     80309e <fd_lookup+0x40>
  803082:	89 d0                	mov    %edx,%eax
  803084:	c1 e8 0c             	shr    $0xc,%eax
  803087:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  80308e:	a8 01                	test   $0x1,%al
  803090:	74 0c                	je     80309e <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  803092:	8b 45 0c             	mov    0xc(%ebp),%eax
  803095:	89 10                	mov    %edx,(%eax)
  803097:	b8 00 00 00 00       	mov    $0x0,%eax
  80309c:	eb 05                	jmp    8030a3 <fd_lookup+0x45>
	return 0;
  80309e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8030a3:	5d                   	pop    %ebp
  8030a4:	c3                   	ret    

008030a5 <seek>:

// Frees file descriptor 'fd' by closing the corresponding file
// and unmapping the file descriptor page.
// If 'must_exist' is 0, then fd can be a closed or nonexistent file
// descriptor; the function will return 0 and have no other effect.
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
			r = (*dev->dev_close)(fd);
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}


// --------------------------------------------------------------
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
	&devsock,
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
	*dev = 0;
	return -E_INVAL;
}

int
close(int fdnum)
{
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
		return r;
	else
		return fd_close(fd, 1);
}

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
}

// Make file descriptor 'newfdnum' a duplicate of file descriptor 'oldfdnum'.
// For instance, writing onto either file descriptor will affect the
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
	close(newfdnum);

	newfd = INDEX2FD(newfdnum);
	ova = fd2data(oldfd);
	nva = fd2data(newfd);

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
}

ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8030a5:	55                   	push   %ebp
  8030a6:	89 e5                	mov    %esp,%ebp
  8030a8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8030ab:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  8030ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8030b5:	89 04 24             	mov    %eax,(%esp)
  8030b8:	e8 a1 ff ff ff       	call   80305e <fd_lookup>
  8030bd:	85 c0                	test   %eax,%eax
  8030bf:	78 0e                	js     8030cf <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8030c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8030c4:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  8030c7:	89 50 04             	mov    %edx,0x4(%eax)
  8030ca:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8030cf:	c9                   	leave  
  8030d0:	c3                   	ret    

008030d1 <dev_lookup>:
  8030d1:	55                   	push   %ebp
  8030d2:	89 e5                	mov    %esp,%ebp
  8030d4:	53                   	push   %ebx
  8030d5:	83 ec 14             	sub    $0x14,%esp
  8030d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8030db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8030de:	ba 68 c0 80 00       	mov    $0x80c068,%edx
  8030e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8030e8:	39 0d 68 c0 80 00    	cmp    %ecx,0x80c068
  8030ee:	75 12                	jne    803102 <dev_lookup+0x31>
  8030f0:	eb 04                	jmp    8030f6 <dev_lookup+0x25>
  8030f2:	39 0a                	cmp    %ecx,(%edx)
  8030f4:	75 0c                	jne    803102 <dev_lookup+0x31>
  8030f6:	89 13                	mov    %edx,(%ebx)
  8030f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8030fd:	8d 76 00             	lea    0x0(%esi),%esi
  803100:	eb 35                	jmp    803137 <dev_lookup+0x66>
  803102:	83 c0 01             	add    $0x1,%eax
  803105:	8b 14 85 6c 4a 80 00 	mov    0x804a6c(,%eax,4),%edx
  80310c:	85 d2                	test   %edx,%edx
  80310e:	75 e2                	jne    8030f2 <dev_lookup+0x21>
  803110:	a1 a8 c0 80 00       	mov    0x80c0a8,%eax
  803115:	8b 40 4c             	mov    0x4c(%eax),%eax
  803118:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80311c:	89 44 24 04          	mov    %eax,0x4(%esp)
  803120:	c7 04 24 ec 49 80 00 	movl   $0x8049ec,(%esp)
  803127:	e8 95 ed ff ff       	call   801ec1 <cprintf>
  80312c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  803132:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  803137:	83 c4 14             	add    $0x14,%esp
  80313a:	5b                   	pop    %ebx
  80313b:	5d                   	pop    %ebp
  80313c:	c3                   	ret    

0080313d <fstat>:

int
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80313d:	55                   	push   %ebp
  80313e:	89 e5                	mov    %esp,%ebp
  803140:	53                   	push   %ebx
  803141:	83 ec 24             	sub    $0x24,%esp
  803144:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  803147:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80314a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80314e:	8b 45 08             	mov    0x8(%ebp),%eax
  803151:	89 04 24             	mov    %eax,(%esp)
  803154:	e8 05 ff ff ff       	call   80305e <fd_lookup>
  803159:	89 c2                	mov    %eax,%edx
  80315b:	85 c0                	test   %eax,%eax
  80315d:	78 57                	js     8031b6 <fstat+0x79>
  80315f:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  803162:	89 44 24 04          	mov    %eax,0x4(%esp)
  803166:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  803169:	8b 00                	mov    (%eax),%eax
  80316b:	89 04 24             	mov    %eax,(%esp)
  80316e:	e8 5e ff ff ff       	call   8030d1 <dev_lookup>
  803173:	89 c2                	mov    %eax,%edx
  803175:	85 c0                	test   %eax,%eax
  803177:	78 3d                	js     8031b6 <fstat+0x79>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  803179:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  80317e:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  803181:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  803185:	74 2f                	je     8031b6 <fstat+0x79>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  803187:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80318a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  803191:	00 00 00 
	stat->st_isdir = 0;
  803194:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80319b:	00 00 00 
	stat->st_dev = dev;
  80319e:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  8031a1:	89 93 88 00 00 00    	mov    %edx,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8031a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8031ab:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8031ae:	89 04 24             	mov    %eax,(%esp)
  8031b1:	ff 52 14             	call   *0x14(%edx)
  8031b4:	89 c2                	mov    %eax,%edx
}
  8031b6:	89 d0                	mov    %edx,%eax
  8031b8:	83 c4 24             	add    $0x24,%esp
  8031bb:	5b                   	pop    %ebx
  8031bc:	5d                   	pop    %ebp
  8031bd:	c3                   	ret    

008031be <ftruncate>:
  8031be:	55                   	push   %ebp
  8031bf:	89 e5                	mov    %esp,%ebp
  8031c1:	53                   	push   %ebx
  8031c2:	83 ec 24             	sub    $0x24,%esp
  8031c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8031c8:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8031cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031cf:	89 1c 24             	mov    %ebx,(%esp)
  8031d2:	e8 87 fe ff ff       	call   80305e <fd_lookup>
  8031d7:	85 c0                	test   %eax,%eax
  8031d9:	78 61                	js     80323c <ftruncate+0x7e>
  8031db:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8031de:	8b 10                	mov    (%eax),%edx
  8031e0:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  8031e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031e7:	89 14 24             	mov    %edx,(%esp)
  8031ea:	e8 e2 fe ff ff       	call   8030d1 <dev_lookup>
  8031ef:	85 c0                	test   %eax,%eax
  8031f1:	78 49                	js     80323c <ftruncate+0x7e>
  8031f3:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  8031f6:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  8031fa:	75 23                	jne    80321f <ftruncate+0x61>
  8031fc:	a1 a8 c0 80 00       	mov    0x80c0a8,%eax
  803201:	8b 40 4c             	mov    0x4c(%eax),%eax
  803204:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803208:	89 44 24 04          	mov    %eax,0x4(%esp)
  80320c:	c7 04 24 0c 4a 80 00 	movl   $0x804a0c,(%esp)
  803213:	e8 a9 ec ff ff       	call   801ec1 <cprintf>
  803218:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80321d:	eb 1d                	jmp    80323c <ftruncate+0x7e>
  80321f:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  803222:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  803227:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  80322b:	74 0f                	je     80323c <ftruncate+0x7e>
  80322d:	8b 52 18             	mov    0x18(%edx),%edx
  803230:	8b 45 0c             	mov    0xc(%ebp),%eax
  803233:	89 44 24 04          	mov    %eax,0x4(%esp)
  803237:	89 0c 24             	mov    %ecx,(%esp)
  80323a:	ff d2                	call   *%edx
  80323c:	83 c4 24             	add    $0x24,%esp
  80323f:	5b                   	pop    %ebx
  803240:	5d                   	pop    %ebp
  803241:	c3                   	ret    

00803242 <write>:
  803242:	55                   	push   %ebp
  803243:	89 e5                	mov    %esp,%ebp
  803245:	53                   	push   %ebx
  803246:	83 ec 24             	sub    $0x24,%esp
  803249:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80324c:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80324f:	89 44 24 04          	mov    %eax,0x4(%esp)
  803253:	89 1c 24             	mov    %ebx,(%esp)
  803256:	e8 03 fe ff ff       	call   80305e <fd_lookup>
  80325b:	85 c0                	test   %eax,%eax
  80325d:	78 68                	js     8032c7 <write+0x85>
  80325f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  803262:	8b 10                	mov    (%eax),%edx
  803264:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  803267:	89 44 24 04          	mov    %eax,0x4(%esp)
  80326b:	89 14 24             	mov    %edx,(%esp)
  80326e:	e8 5e fe ff ff       	call   8030d1 <dev_lookup>
  803273:	85 c0                	test   %eax,%eax
  803275:	78 50                	js     8032c7 <write+0x85>
  803277:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  80327a:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  80327e:	75 23                	jne    8032a3 <write+0x61>
  803280:	a1 a8 c0 80 00       	mov    0x80c0a8,%eax
  803285:	8b 40 4c             	mov    0x4c(%eax),%eax
  803288:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80328c:	89 44 24 04          	mov    %eax,0x4(%esp)
  803290:	c7 04 24 30 4a 80 00 	movl   $0x804a30,(%esp)
  803297:	e8 25 ec ff ff       	call   801ec1 <cprintf>
  80329c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8032a1:	eb 24                	jmp    8032c7 <write+0x85>
  8032a3:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  8032a6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8032ab:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  8032af:	74 16                	je     8032c7 <write+0x85>
  8032b1:	8b 42 0c             	mov    0xc(%edx),%eax
  8032b4:	8b 55 10             	mov    0x10(%ebp),%edx
  8032b7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8032bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8032be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8032c2:	89 0c 24             	mov    %ecx,(%esp)
  8032c5:	ff d0                	call   *%eax
  8032c7:	83 c4 24             	add    $0x24,%esp
  8032ca:	5b                   	pop    %ebx
  8032cb:	5d                   	pop    %ebp
  8032cc:	c3                   	ret    

008032cd <read>:
  8032cd:	55                   	push   %ebp
  8032ce:	89 e5                	mov    %esp,%ebp
  8032d0:	53                   	push   %ebx
  8032d1:	83 ec 24             	sub    $0x24,%esp
  8032d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8032d7:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8032da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8032de:	89 1c 24             	mov    %ebx,(%esp)
  8032e1:	e8 78 fd ff ff       	call   80305e <fd_lookup>
  8032e6:	85 c0                	test   %eax,%eax
  8032e8:	78 6d                	js     803357 <read+0x8a>
  8032ea:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8032ed:	8b 10                	mov    (%eax),%edx
  8032ef:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  8032f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8032f6:	89 14 24             	mov    %edx,(%esp)
  8032f9:	e8 d3 fd ff ff       	call   8030d1 <dev_lookup>
  8032fe:	85 c0                	test   %eax,%eax
  803300:	78 55                	js     803357 <read+0x8a>
  803302:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  803305:	8b 41 08             	mov    0x8(%ecx),%eax
  803308:	83 e0 03             	and    $0x3,%eax
  80330b:	83 f8 01             	cmp    $0x1,%eax
  80330e:	75 23                	jne    803333 <read+0x66>
  803310:	a1 a8 c0 80 00       	mov    0x80c0a8,%eax
  803315:	8b 40 4c             	mov    0x4c(%eax),%eax
  803318:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80331c:	89 44 24 04          	mov    %eax,0x4(%esp)
  803320:	c7 04 24 4d 4a 80 00 	movl   $0x804a4d,(%esp)
  803327:	e8 95 eb ff ff       	call   801ec1 <cprintf>
  80332c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  803331:	eb 24                	jmp    803357 <read+0x8a>
  803333:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  803336:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80333b:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  80333f:	74 16                	je     803357 <read+0x8a>
  803341:	8b 42 08             	mov    0x8(%edx),%eax
  803344:	8b 55 10             	mov    0x10(%ebp),%edx
  803347:	89 54 24 08          	mov    %edx,0x8(%esp)
  80334b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80334e:	89 54 24 04          	mov    %edx,0x4(%esp)
  803352:	89 0c 24             	mov    %ecx,(%esp)
  803355:	ff d0                	call   *%eax
  803357:	83 c4 24             	add    $0x24,%esp
  80335a:	5b                   	pop    %ebx
  80335b:	5d                   	pop    %ebp
  80335c:	c3                   	ret    

0080335d <readn>:
  80335d:	55                   	push   %ebp
  80335e:	89 e5                	mov    %esp,%ebp
  803360:	57                   	push   %edi
  803361:	56                   	push   %esi
  803362:	53                   	push   %ebx
  803363:	83 ec 0c             	sub    $0xc,%esp
  803366:	8b 7d 0c             	mov    0xc(%ebp),%edi
  803369:	8b 75 10             	mov    0x10(%ebp),%esi
  80336c:	b8 00 00 00 00       	mov    $0x0,%eax
  803371:	85 f6                	test   %esi,%esi
  803373:	74 36                	je     8033ab <readn+0x4e>
  803375:	bb 00 00 00 00       	mov    $0x0,%ebx
  80337a:	ba 00 00 00 00       	mov    $0x0,%edx
  80337f:	89 f0                	mov    %esi,%eax
  803381:	29 d0                	sub    %edx,%eax
  803383:	89 44 24 08          	mov    %eax,0x8(%esp)
  803387:	8d 04 17             	lea    (%edi,%edx,1),%eax
  80338a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80338e:	8b 45 08             	mov    0x8(%ebp),%eax
  803391:	89 04 24             	mov    %eax,(%esp)
  803394:	e8 34 ff ff ff       	call   8032cd <read>
  803399:	85 c0                	test   %eax,%eax
  80339b:	78 0e                	js     8033ab <readn+0x4e>
  80339d:	85 c0                	test   %eax,%eax
  80339f:	74 08                	je     8033a9 <readn+0x4c>
  8033a1:	01 c3                	add    %eax,%ebx
  8033a3:	89 da                	mov    %ebx,%edx
  8033a5:	39 f3                	cmp    %esi,%ebx
  8033a7:	72 d6                	jb     80337f <readn+0x22>
  8033a9:	89 d8                	mov    %ebx,%eax
  8033ab:	83 c4 0c             	add    $0xc,%esp
  8033ae:	5b                   	pop    %ebx
  8033af:	5e                   	pop    %esi
  8033b0:	5f                   	pop    %edi
  8033b1:	5d                   	pop    %ebp
  8033b2:	c3                   	ret    

008033b3 <fd_close>:
  8033b3:	55                   	push   %ebp
  8033b4:	89 e5                	mov    %esp,%ebp
  8033b6:	83 ec 28             	sub    $0x28,%esp
  8033b9:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  8033bc:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  8033bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8033c2:	89 34 24             	mov    %esi,(%esp)
  8033c5:	e8 16 fc ff ff       	call   802fe0 <fd2num>
  8033ca:	8d 55 f4             	lea    0xfffffff4(%ebp),%edx
  8033cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8033d1:	89 04 24             	mov    %eax,(%esp)
  8033d4:	e8 85 fc ff ff       	call   80305e <fd_lookup>
  8033d9:	89 c3                	mov    %eax,%ebx
  8033db:	85 c0                	test   %eax,%eax
  8033dd:	78 05                	js     8033e4 <fd_close+0x31>
  8033df:	3b 75 f4             	cmp    0xfffffff4(%ebp),%esi
  8033e2:	74 0e                	je     8033f2 <fd_close+0x3f>
  8033e4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8033e8:	75 45                	jne    80342f <fd_close+0x7c>
  8033ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8033ef:	90                   	nop    
  8033f0:	eb 3d                	jmp    80342f <fd_close+0x7c>
  8033f2:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  8033f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8033f9:	8b 06                	mov    (%esi),%eax
  8033fb:	89 04 24             	mov    %eax,(%esp)
  8033fe:	e8 ce fc ff ff       	call   8030d1 <dev_lookup>
  803403:	89 c3                	mov    %eax,%ebx
  803405:	85 c0                	test   %eax,%eax
  803407:	78 16                	js     80341f <fd_close+0x6c>
  803409:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80340c:	8b 40 10             	mov    0x10(%eax),%eax
  80340f:	bb 00 00 00 00       	mov    $0x0,%ebx
  803414:	85 c0                	test   %eax,%eax
  803416:	74 07                	je     80341f <fd_close+0x6c>
  803418:	89 34 24             	mov    %esi,(%esp)
  80341b:	ff d0                	call   *%eax
  80341d:	89 c3                	mov    %eax,%ebx
  80341f:	89 74 24 04          	mov    %esi,0x4(%esp)
  803423:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80342a:	e8 7f f7 ff ff       	call   802bae <sys_page_unmap>
  80342f:	89 d8                	mov    %ebx,%eax
  803431:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  803434:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  803437:	89 ec                	mov    %ebp,%esp
  803439:	5d                   	pop    %ebp
  80343a:	c3                   	ret    

0080343b <close>:
  80343b:	55                   	push   %ebp
  80343c:	89 e5                	mov    %esp,%ebp
  80343e:	83 ec 18             	sub    $0x18,%esp
  803441:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  803444:	89 44 24 04          	mov    %eax,0x4(%esp)
  803448:	8b 45 08             	mov    0x8(%ebp),%eax
  80344b:	89 04 24             	mov    %eax,(%esp)
  80344e:	e8 0b fc ff ff       	call   80305e <fd_lookup>
  803453:	85 c0                	test   %eax,%eax
  803455:	78 13                	js     80346a <close+0x2f>
  803457:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80345e:	00 
  80345f:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  803462:	89 04 24             	mov    %eax,(%esp)
  803465:	e8 49 ff ff ff       	call   8033b3 <fd_close>
  80346a:	c9                   	leave  
  80346b:	c3                   	ret    

0080346c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80346c:	55                   	push   %ebp
  80346d:	89 e5                	mov    %esp,%ebp
  80346f:	83 ec 18             	sub    $0x18,%esp
  803472:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  803475:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  803478:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80347f:	00 
  803480:	8b 45 08             	mov    0x8(%ebp),%eax
  803483:	89 04 24             	mov    %eax,(%esp)
  803486:	e8 58 03 00 00       	call   8037e3 <open>
  80348b:	89 c6                	mov    %eax,%esi
  80348d:	85 c0                	test   %eax,%eax
  80348f:	78 1b                	js     8034ac <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  803491:	8b 45 0c             	mov    0xc(%ebp),%eax
  803494:	89 44 24 04          	mov    %eax,0x4(%esp)
  803498:	89 34 24             	mov    %esi,(%esp)
  80349b:	e8 9d fc ff ff       	call   80313d <fstat>
  8034a0:	89 c3                	mov    %eax,%ebx
	close(fd);
  8034a2:	89 34 24             	mov    %esi,(%esp)
  8034a5:	e8 91 ff ff ff       	call   80343b <close>
  8034aa:	89 de                	mov    %ebx,%esi
	return r;
}
  8034ac:	89 f0                	mov    %esi,%eax
  8034ae:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  8034b1:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  8034b4:	89 ec                	mov    %ebp,%esp
  8034b6:	5d                   	pop    %ebp
  8034b7:	c3                   	ret    

008034b8 <dup>:
  8034b8:	55                   	push   %ebp
  8034b9:	89 e5                	mov    %esp,%ebp
  8034bb:	83 ec 38             	sub    $0x38,%esp
  8034be:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  8034c1:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  8034c4:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  8034c7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8034ca:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  8034cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8034d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8034d4:	89 04 24             	mov    %eax,(%esp)
  8034d7:	e8 82 fb ff ff       	call   80305e <fd_lookup>
  8034dc:	89 c3                	mov    %eax,%ebx
  8034de:	85 c0                	test   %eax,%eax
  8034e0:	0f 88 e1 00 00 00    	js     8035c7 <dup+0x10f>
  8034e6:	89 3c 24             	mov    %edi,(%esp)
  8034e9:	e8 4d ff ff ff       	call   80343b <close>
  8034ee:	89 f8                	mov    %edi,%eax
  8034f0:	c1 e0 0c             	shl    $0xc,%eax
  8034f3:	8d b0 00 00 00 d0    	lea    0xd0000000(%eax),%esi
  8034f9:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8034fc:	89 04 24             	mov    %eax,(%esp)
  8034ff:	e8 ec fa ff ff       	call   802ff0 <fd2data>
  803504:	89 c3                	mov    %eax,%ebx
  803506:	89 34 24             	mov    %esi,(%esp)
  803509:	e8 e2 fa ff ff       	call   802ff0 <fd2data>
  80350e:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  803511:	89 d8                	mov    %ebx,%eax
  803513:	c1 e8 16             	shr    $0x16,%eax
  803516:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  80351d:	a8 01                	test   $0x1,%al
  80351f:	74 45                	je     803566 <dup+0xae>
  803521:	89 da                	mov    %ebx,%edx
  803523:	c1 ea 0c             	shr    $0xc,%edx
  803526:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  80352d:	a8 01                	test   $0x1,%al
  80352f:	74 35                	je     803566 <dup+0xae>
  803531:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  803538:	25 07 0e 00 00       	and    $0xe07,%eax
  80353d:	89 44 24 10          	mov    %eax,0x10(%esp)
  803541:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  803544:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803548:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80354f:	00 
  803550:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803554:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80355b:	e8 ac f6 ff ff       	call   802c0c <sys_page_map>
  803560:	89 c3                	mov    %eax,%ebx
  803562:	85 c0                	test   %eax,%eax
  803564:	78 3e                	js     8035a4 <dup+0xec>
  803566:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  803569:	89 d0                	mov    %edx,%eax
  80356b:	c1 e8 0c             	shr    $0xc,%eax
  80356e:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  803575:	25 07 0e 00 00       	and    $0xe07,%eax
  80357a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80357e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  803582:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803589:	00 
  80358a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80358e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803595:	e8 72 f6 ff ff       	call   802c0c <sys_page_map>
  80359a:	89 c3                	mov    %eax,%ebx
  80359c:	85 c0                	test   %eax,%eax
  80359e:	78 04                	js     8035a4 <dup+0xec>
  8035a0:	89 fb                	mov    %edi,%ebx
  8035a2:	eb 23                	jmp    8035c7 <dup+0x10f>
  8035a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8035a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8035af:	e8 fa f5 ff ff       	call   802bae <sys_page_unmap>
  8035b4:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  8035b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8035bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8035c2:	e8 e7 f5 ff ff       	call   802bae <sys_page_unmap>
  8035c7:	89 d8                	mov    %ebx,%eax
  8035c9:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  8035cc:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  8035cf:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  8035d2:	89 ec                	mov    %ebp,%esp
  8035d4:	5d                   	pop    %ebp
  8035d5:	c3                   	ret    

008035d6 <close_all>:
  8035d6:	55                   	push   %ebp
  8035d7:	89 e5                	mov    %esp,%ebp
  8035d9:	53                   	push   %ebx
  8035da:	83 ec 04             	sub    $0x4,%esp
  8035dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8035e2:	89 1c 24             	mov    %ebx,(%esp)
  8035e5:	e8 51 fe ff ff       	call   80343b <close>
  8035ea:	83 c3 01             	add    $0x1,%ebx
  8035ed:	83 fb 20             	cmp    $0x20,%ebx
  8035f0:	75 f0                	jne    8035e2 <close_all+0xc>
  8035f2:	83 c4 04             	add    $0x4,%esp
  8035f5:	5b                   	pop    %ebx
  8035f6:	5d                   	pop    %ebp
  8035f7:	c3                   	ret    

008035f8 <fsipc>:
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8035f8:	55                   	push   %ebp
  8035f9:	89 e5                	mov    %esp,%ebp
  8035fb:	53                   	push   %ebx
  8035fc:	83 ec 14             	sub    $0x14,%esp
  8035ff:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  803601:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  803607:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80360e:	00 
  80360f:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  803616:	00 
  803617:	89 44 24 04          	mov    %eax,0x4(%esp)
  80361b:	89 14 24             	mov    %edx,(%esp)
  80361e:	e8 1d f8 ff ff       	call   802e40 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  803623:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80362a:	00 
  80362b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80362f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803636:	e8 b9 f8 ff ff       	call   802ef4 <ipc_recv>
}
  80363b:	83 c4 14             	add    $0x14,%esp
  80363e:	5b                   	pop    %ebx
  80363f:	5d                   	pop    %ebp
  803640:	c3                   	ret    

00803641 <sync>:

static int devfile_flush(struct Fd *fd);
static ssize_t devfile_read(struct Fd *fd, void *buf, size_t n);
static ssize_t devfile_write(struct Fd *fd, const void *buf, size_t n);
static int devfile_stat(struct Fd *fd, struct Stat *stat);
static int devfile_trunc(struct Fd *fd, off_t newsize);

struct Dev devfile =
{
	.dev_id =	'f',
	.dev_name =	"file",
	.dev_read =	devfile_read,
	.dev_write =	devfile_write,
	.dev_close =	devfile_flush,
	.dev_stat =	devfile_stat,
	.dev_trunc =	devfile_trunc
};

// Open a file (or directory).
//
// Returns:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
	// Find an unused file descriptor page using fd_alloc.
	// Then send a file-open request to the file server.
	// Include 'path' and 'omode' in request,
	// and map the returned file descriptor page
	// at the appropriate fd address.
	// FSREQ_OPEN returns 0 on success, < 0 on failure.
	//
	// (fd_alloc does not allocate a page, it just returns an
	// unused fd address.  Do you need to allocate a page?)
	//
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;
	void *page;
	if((r=fd_alloc(&fd))<0){
		fd_close(fd,0);
		return r;
	}
	//cprintf("open:fd=%x\n",fd);
	strcpy(fsipcbuf.open.req_path,path);
	fsipcbuf.open.req_omode=mode;
	page=(void*)fd2data(fd);
	if((r=fsipc(FSREQ_OPEN,(void*)fd))<0)
	{
		fd_close(fd,1);
		return r;	
	}
	//cprintf("open:page=%x\n",page);
	if((r=sys_page_map(0,(void*)fd,0,(void*)page,PTE_P | PTE_W | PTE_U))<0)
	{
		fd_close(fd,1);
		return r;
	}
	//cprintf("open:fileid=%x\n",fd->fd_file.id);
	return fd2num(fd);
	//panic("open not implemented");
}

// Flush the file descriptor.  After this the fileid is invalid.
//
// This function is called by fd_close.  fd_close will take care of
// unmapping the FD page from this environment.  Since the server uses
// the reference counts on the FD pages to detect which files are
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
	return fsipc(FSREQ_FLUSH, NULL);
}

// Read at most 'n' bytes from 'fd' at the current position into 'buf'.
//
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	ssize_t readsize;
	if(debug)
		cprintf("devfile_read:fileid=%x readsize=%x\n",fd->fd_file.id,n);
	fsipcbuf.read.req_fileid=fd->fd_file.id;
	fsipcbuf.read.req_n=n;
	readsize=(ssize_t)fsipc(FSREQ_READ,&fsipcbuf);
	//cprintf("readsize=%d\n",readsize);
	if(debug)
		cprintf("devfile_read:buf1=%s\nbuf2=%s\n",(char*)&fsipcbuf,fsipcbuf.readRet.ret_buf);
	if(readsize>0)
		memmove(buf,(void*)&fsipcbuf,(size_t)readsize);
	//cprintf("readsize=%d",readsize);
	return readsize;
	//panic("devfile_read not implemented");
}

// Write at most 'n' bytes from 'buf' to 'fd' at the current seek position.
//
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	ssize_t writesize;
	size_t bufsize;
	fsipcbuf.write.req_fileid=fd->fd_file.id;
	bufsize=sizeof(fsipcbuf.write.req_buf);
	if(n<bufsize)
		bufsize=n;	
	fsipcbuf.write.req_n=n;
	memmove((void*)fsipcbuf.write.req_buf,buf,bufsize);
	writesize=(ssize_t)fsipc(FSREQ_WRITE,NULL);
	return writesize;
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
	st->st_size = fsipcbuf.statRet.ret_size;
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
	return 0;
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
	fsipcbuf.set_size.req_size = newsize;
	return fsipc(FSREQ_SET_SIZE, NULL);
}

// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}

// Synchronize disk with buffer cache
int
sync(void)
{
  803641:	55                   	push   %ebp
  803642:	89 e5                	mov    %esp,%ebp
  803644:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  803647:	ba 00 00 00 00       	mov    $0x0,%edx
  80364c:	b8 08 00 00 00       	mov    $0x8,%eax
  803651:	e8 a2 ff ff ff       	call   8035f8 <fsipc>
}
  803656:	c9                   	leave  
  803657:	c3                   	ret    

00803658 <devfile_trunc>:
  803658:	55                   	push   %ebp
  803659:	89 e5                	mov    %esp,%ebp
  80365b:	83 ec 08             	sub    $0x8,%esp
  80365e:	8b 45 08             	mov    0x8(%ebp),%eax
  803661:	8b 40 0c             	mov    0xc(%eax),%eax
  803664:	a3 00 50 80 00       	mov    %eax,0x805000
  803669:	8b 45 0c             	mov    0xc(%ebp),%eax
  80366c:	a3 04 50 80 00       	mov    %eax,0x805004
  803671:	ba 00 00 00 00       	mov    $0x0,%edx
  803676:	b8 02 00 00 00       	mov    $0x2,%eax
  80367b:	e8 78 ff ff ff       	call   8035f8 <fsipc>
  803680:	c9                   	leave  
  803681:	c3                   	ret    

00803682 <devfile_flush>:
  803682:	55                   	push   %ebp
  803683:	89 e5                	mov    %esp,%ebp
  803685:	83 ec 08             	sub    $0x8,%esp
  803688:	8b 45 08             	mov    0x8(%ebp),%eax
  80368b:	8b 40 0c             	mov    0xc(%eax),%eax
  80368e:	a3 00 50 80 00       	mov    %eax,0x805000
  803693:	ba 00 00 00 00       	mov    $0x0,%edx
  803698:	b8 06 00 00 00       	mov    $0x6,%eax
  80369d:	e8 56 ff ff ff       	call   8035f8 <fsipc>
  8036a2:	c9                   	leave  
  8036a3:	c3                   	ret    

008036a4 <devfile_stat>:
  8036a4:	55                   	push   %ebp
  8036a5:	89 e5                	mov    %esp,%ebp
  8036a7:	53                   	push   %ebx
  8036a8:	83 ec 14             	sub    $0x14,%esp
  8036ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8036ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8036b1:	8b 40 0c             	mov    0xc(%eax),%eax
  8036b4:	a3 00 50 80 00       	mov    %eax,0x805000
  8036b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8036be:	b8 05 00 00 00       	mov    $0x5,%eax
  8036c3:	e8 30 ff ff ff       	call   8035f8 <fsipc>
  8036c8:	85 c0                	test   %eax,%eax
  8036ca:	78 2b                	js     8036f7 <devfile_stat+0x53>
  8036cc:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8036d3:	00 
  8036d4:	89 1c 24             	mov    %ebx,(%esp)
  8036d7:	e8 65 ee ff ff       	call   802541 <strcpy>
  8036dc:	a1 80 50 80 00       	mov    0x805080,%eax
  8036e1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  8036e7:	a1 84 50 80 00       	mov    0x805084,%eax
  8036ec:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8036f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8036f7:	83 c4 14             	add    $0x14,%esp
  8036fa:	5b                   	pop    %ebx
  8036fb:	5d                   	pop    %ebp
  8036fc:	c3                   	ret    

008036fd <devfile_write>:
  8036fd:	55                   	push   %ebp
  8036fe:	89 e5                	mov    %esp,%ebp
  803700:	83 ec 18             	sub    $0x18,%esp
  803703:	8b 55 10             	mov    0x10(%ebp),%edx
  803706:	8b 45 08             	mov    0x8(%ebp),%eax
  803709:	8b 40 0c             	mov    0xc(%eax),%eax
  80370c:	a3 00 50 80 00       	mov    %eax,0x805000
  803711:	89 d0                	mov    %edx,%eax
  803713:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  803719:	76 05                	jbe    803720 <devfile_write+0x23>
  80371b:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  803720:	89 15 04 50 80 00    	mov    %edx,0x805004
  803726:	89 44 24 08          	mov    %eax,0x8(%esp)
  80372a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80372d:	89 44 24 04          	mov    %eax,0x4(%esp)
  803731:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  803738:	e8 0d f0 ff ff       	call   80274a <memmove>
  80373d:	ba 00 00 00 00       	mov    $0x0,%edx
  803742:	b8 04 00 00 00       	mov    $0x4,%eax
  803747:	e8 ac fe ff ff       	call   8035f8 <fsipc>
  80374c:	c9                   	leave  
  80374d:	c3                   	ret    

0080374e <devfile_read>:
  80374e:	55                   	push   %ebp
  80374f:	89 e5                	mov    %esp,%ebp
  803751:	53                   	push   %ebx
  803752:	83 ec 14             	sub    $0x14,%esp
  803755:	8b 45 08             	mov    0x8(%ebp),%eax
  803758:	8b 40 0c             	mov    0xc(%eax),%eax
  80375b:	a3 00 50 80 00       	mov    %eax,0x805000
  803760:	8b 45 10             	mov    0x10(%ebp),%eax
  803763:	a3 04 50 80 00       	mov    %eax,0x805004
  803768:	ba 00 50 80 00       	mov    $0x805000,%edx
  80376d:	b8 03 00 00 00       	mov    $0x3,%eax
  803772:	e8 81 fe ff ff       	call   8035f8 <fsipc>
  803777:	89 c3                	mov    %eax,%ebx
  803779:	85 c0                	test   %eax,%eax
  80377b:	7e 17                	jle    803794 <devfile_read+0x46>
  80377d:	89 44 24 08          	mov    %eax,0x8(%esp)
  803781:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  803788:	00 
  803789:	8b 45 0c             	mov    0xc(%ebp),%eax
  80378c:	89 04 24             	mov    %eax,(%esp)
  80378f:	e8 b6 ef ff ff       	call   80274a <memmove>
  803794:	89 d8                	mov    %ebx,%eax
  803796:	83 c4 14             	add    $0x14,%esp
  803799:	5b                   	pop    %ebx
  80379a:	5d                   	pop    %ebp
  80379b:	c3                   	ret    

0080379c <remove>:
  80379c:	55                   	push   %ebp
  80379d:	89 e5                	mov    %esp,%ebp
  80379f:	53                   	push   %ebx
  8037a0:	83 ec 14             	sub    $0x14,%esp
  8037a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8037a6:	89 1c 24             	mov    %ebx,(%esp)
  8037a9:	e8 42 ed ff ff       	call   8024f0 <strlen>
  8037ae:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  8037b3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8037b8:	7f 21                	jg     8037db <remove+0x3f>
  8037ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8037be:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8037c5:	e8 77 ed ff ff       	call   802541 <strcpy>
  8037ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8037cf:	b8 07 00 00 00       	mov    $0x7,%eax
  8037d4:	e8 1f fe ff ff       	call   8035f8 <fsipc>
  8037d9:	89 c2                	mov    %eax,%edx
  8037db:	89 d0                	mov    %edx,%eax
  8037dd:	83 c4 14             	add    $0x14,%esp
  8037e0:	5b                   	pop    %ebx
  8037e1:	5d                   	pop    %ebp
  8037e2:	c3                   	ret    

008037e3 <open>:
  8037e3:	55                   	push   %ebp
  8037e4:	89 e5                	mov    %esp,%ebp
  8037e6:	56                   	push   %esi
  8037e7:	53                   	push   %ebx
  8037e8:	83 ec 30             	sub    $0x30,%esp
  8037eb:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8037ee:	89 04 24             	mov    %eax,(%esp)
  8037f1:	e8 15 f8 ff ff       	call   80300b <fd_alloc>
  8037f6:	89 c3                	mov    %eax,%ebx
  8037f8:	85 c0                	test   %eax,%eax
  8037fa:	79 18                	jns    803814 <open+0x31>
  8037fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  803803:	00 
  803804:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  803807:	89 04 24             	mov    %eax,(%esp)
  80380a:	e8 a4 fb ff ff       	call   8033b3 <fd_close>
  80380f:	e9 9f 00 00 00       	jmp    8038b3 <open+0xd0>
  803814:	8b 45 08             	mov    0x8(%ebp),%eax
  803817:	89 44 24 04          	mov    %eax,0x4(%esp)
  80381b:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  803822:	e8 1a ed ff ff       	call   802541 <strcpy>
  803827:	8b 45 0c             	mov    0xc(%ebp),%eax
  80382a:	a3 00 54 80 00       	mov    %eax,0x805400
  80382f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  803832:	89 04 24             	mov    %eax,(%esp)
  803835:	e8 b6 f7 ff ff       	call   802ff0 <fd2data>
  80383a:	89 c6                	mov    %eax,%esi
  80383c:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  80383f:	b8 01 00 00 00       	mov    $0x1,%eax
  803844:	e8 af fd ff ff       	call   8035f8 <fsipc>
  803849:	89 c3                	mov    %eax,%ebx
  80384b:	85 c0                	test   %eax,%eax
  80384d:	79 15                	jns    803864 <open+0x81>
  80384f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  803856:	00 
  803857:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80385a:	89 04 24             	mov    %eax,(%esp)
  80385d:	e8 51 fb ff ff       	call   8033b3 <fd_close>
  803862:	eb 4f                	jmp    8038b3 <open+0xd0>
  803864:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80386b:	00 
  80386c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  803870:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803877:	00 
  803878:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80387b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80387f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803886:	e8 81 f3 ff ff       	call   802c0c <sys_page_map>
  80388b:	89 c3                	mov    %eax,%ebx
  80388d:	85 c0                	test   %eax,%eax
  80388f:	79 15                	jns    8038a6 <open+0xc3>
  803891:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  803898:	00 
  803899:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80389c:	89 04 24             	mov    %eax,(%esp)
  80389f:	e8 0f fb ff ff       	call   8033b3 <fd_close>
  8038a4:	eb 0d                	jmp    8038b3 <open+0xd0>
  8038a6:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8038a9:	89 04 24             	mov    %eax,(%esp)
  8038ac:	e8 2f f7 ff ff       	call   802fe0 <fd2num>
  8038b1:	89 c3                	mov    %eax,%ebx
  8038b3:	89 d8                	mov    %ebx,%eax
  8038b5:	83 c4 30             	add    $0x30,%esp
  8038b8:	5b                   	pop    %ebx
  8038b9:	5e                   	pop    %esi
  8038ba:	5d                   	pop    %ebp
  8038bb:	c3                   	ret    

008038bc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8038bc:	55                   	push   %ebp
  8038bd:	89 e5                	mov    %esp,%ebp
  8038bf:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  8038c2:	89 d0                	mov    %edx,%eax
  8038c4:	c1 e8 16             	shr    $0x16,%eax
  8038c7:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  8038ce:	a8 01                	test   $0x1,%al
  8038d0:	74 25                	je     8038f7 <pageref+0x3b>
		return 0;
	pte = vpt[VPN(v)];
  8038d2:	89 d0                	mov    %edx,%eax
  8038d4:	c1 e8 0c             	shr    $0xc,%eax
  8038d7:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8038de:	a8 01                	test   $0x1,%al
  8038e0:	74 15                	je     8038f7 <pageref+0x3b>
		return 0;
	return pages[PPN(pte)].pp_ref;
  8038e2:	c1 e8 0c             	shr    $0xc,%eax
  8038e5:	8d 04 40             	lea    (%eax,%eax,2),%eax
  8038e8:	c1 e0 02             	shl    $0x2,%eax
  8038eb:	0f b7 80 08 00 00 ef 	movzwl 0xef000008(%eax),%eax
  8038f2:	0f b7 c0             	movzwl %ax,%eax
  8038f5:	eb 05                	jmp    8038fc <pageref+0x40>
  8038f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8038fc:	5d                   	pop    %ebp
  8038fd:	c3                   	ret    
	...

00803900 <devsock_stat>:
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  803900:	55                   	push   %ebp
  803901:	89 e5                	mov    %esp,%ebp
  803903:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  803906:	c7 44 24 04 78 4a 80 	movl   $0x804a78,0x4(%esp)
  80390d:	00 
  80390e:	8b 45 0c             	mov    0xc(%ebp),%eax
  803911:	89 04 24             	mov    %eax,(%esp)
  803914:	e8 28 ec ff ff       	call   802541 <strcpy>
	return 0;
}
  803919:	b8 00 00 00 00       	mov    $0x0,%eax
  80391e:	c9                   	leave  
  80391f:	c3                   	ret    

00803920 <devsock_close>:
  803920:	55                   	push   %ebp
  803921:	89 e5                	mov    %esp,%ebp
  803923:	83 ec 08             	sub    $0x8,%esp
  803926:	8b 45 08             	mov    0x8(%ebp),%eax
  803929:	8b 40 0c             	mov    0xc(%eax),%eax
  80392c:	89 04 24             	mov    %eax,(%esp)
  80392f:	e8 be 02 00 00       	call   803bf2 <nsipc_close>
  803934:	c9                   	leave  
  803935:	c3                   	ret    

00803936 <devsock_write>:
  803936:	55                   	push   %ebp
  803937:	89 e5                	mov    %esp,%ebp
  803939:	83 ec 18             	sub    $0x18,%esp
  80393c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  803943:	00 
  803944:	8b 45 10             	mov    0x10(%ebp),%eax
  803947:	89 44 24 08          	mov    %eax,0x8(%esp)
  80394b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80394e:	89 44 24 04          	mov    %eax,0x4(%esp)
  803952:	8b 45 08             	mov    0x8(%ebp),%eax
  803955:	8b 40 0c             	mov    0xc(%eax),%eax
  803958:	89 04 24             	mov    %eax,(%esp)
  80395b:	e8 ce 02 00 00       	call   803c2e <nsipc_send>
  803960:	c9                   	leave  
  803961:	c3                   	ret    

00803962 <devsock_read>:
  803962:	55                   	push   %ebp
  803963:	89 e5                	mov    %esp,%ebp
  803965:	83 ec 18             	sub    $0x18,%esp
  803968:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80396f:	00 
  803970:	8b 45 10             	mov    0x10(%ebp),%eax
  803973:	89 44 24 08          	mov    %eax,0x8(%esp)
  803977:	8b 45 0c             	mov    0xc(%ebp),%eax
  80397a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80397e:	8b 45 08             	mov    0x8(%ebp),%eax
  803981:	8b 40 0c             	mov    0xc(%eax),%eax
  803984:	89 04 24             	mov    %eax,(%esp)
  803987:	e8 15 03 00 00       	call   803ca1 <nsipc_recv>
  80398c:	c9                   	leave  
  80398d:	c3                   	ret    

0080398e <alloc_sockfd>:
  80398e:	55                   	push   %ebp
  80398f:	89 e5                	mov    %esp,%ebp
  803991:	56                   	push   %esi
  803992:	53                   	push   %ebx
  803993:	83 ec 20             	sub    $0x20,%esp
  803996:	89 c6                	mov    %eax,%esi
  803998:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80399b:	89 04 24             	mov    %eax,(%esp)
  80399e:	e8 68 f6 ff ff       	call   80300b <fd_alloc>
  8039a3:	89 c3                	mov    %eax,%ebx
  8039a5:	85 c0                	test   %eax,%eax
  8039a7:	78 21                	js     8039ca <alloc_sockfd+0x3c>
  8039a9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8039b0:	00 
  8039b1:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8039b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8039b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8039bf:	e8 a6 f2 ff ff       	call   802c6a <sys_page_alloc>
  8039c4:	89 c3                	mov    %eax,%ebx
  8039c6:	85 c0                	test   %eax,%eax
  8039c8:	79 0a                	jns    8039d4 <alloc_sockfd+0x46>
  8039ca:	89 34 24             	mov    %esi,(%esp)
  8039cd:	e8 20 02 00 00       	call   803bf2 <nsipc_close>
  8039d2:	eb 28                	jmp    8039fc <alloc_sockfd+0x6e>
  8039d4:	8b 15 84 c0 80 00    	mov    0x80c084,%edx
  8039da:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8039dd:	89 10                	mov    %edx,(%eax)
  8039df:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8039e2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  8039e9:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8039ec:	89 70 0c             	mov    %esi,0xc(%eax)
  8039ef:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8039f2:	89 04 24             	mov    %eax,(%esp)
  8039f5:	e8 e6 f5 ff ff       	call   802fe0 <fd2num>
  8039fa:	89 c3                	mov    %eax,%ebx
  8039fc:	89 d8                	mov    %ebx,%eax
  8039fe:	83 c4 20             	add    $0x20,%esp
  803a01:	5b                   	pop    %ebx
  803a02:	5e                   	pop    %esi
  803a03:	5d                   	pop    %ebp
  803a04:	c3                   	ret    

00803a05 <socket>:

int
socket(int domain, int type, int protocol)
{
  803a05:	55                   	push   %ebp
  803a06:	89 e5                	mov    %esp,%ebp
  803a08:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  803a0b:	8b 45 10             	mov    0x10(%ebp),%eax
  803a0e:	89 44 24 08          	mov    %eax,0x8(%esp)
  803a12:	8b 45 0c             	mov    0xc(%ebp),%eax
  803a15:	89 44 24 04          	mov    %eax,0x4(%esp)
  803a19:	8b 45 08             	mov    0x8(%ebp),%eax
  803a1c:	89 04 24             	mov    %eax,(%esp)
  803a1f:	e8 82 01 00 00       	call   803ba6 <nsipc_socket>
  803a24:	85 c0                	test   %eax,%eax
  803a26:	78 05                	js     803a2d <socket+0x28>
		return r;
	return alloc_sockfd(r);
  803a28:	e8 61 ff ff ff       	call   80398e <alloc_sockfd>
}
  803a2d:	c9                   	leave  
  803a2e:	66 90                	xchg   %ax,%ax
  803a30:	c3                   	ret    

00803a31 <fd2sockid>:
  803a31:	55                   	push   %ebp
  803a32:	89 e5                	mov    %esp,%ebp
  803a34:	83 ec 18             	sub    $0x18,%esp
  803a37:	8d 55 fc             	lea    0xfffffffc(%ebp),%edx
  803a3a:	89 54 24 04          	mov    %edx,0x4(%esp)
  803a3e:	89 04 24             	mov    %eax,(%esp)
  803a41:	e8 18 f6 ff ff       	call   80305e <fd_lookup>
  803a46:	89 c2                	mov    %eax,%edx
  803a48:	85 c0                	test   %eax,%eax
  803a4a:	78 15                	js     803a61 <fd2sockid+0x30>
  803a4c:	8b 4d fc             	mov    0xfffffffc(%ebp),%ecx
  803a4f:	8b 01                	mov    (%ecx),%eax
  803a51:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  803a56:	3b 05 84 c0 80 00    	cmp    0x80c084,%eax
  803a5c:	75 03                	jne    803a61 <fd2sockid+0x30>
  803a5e:	8b 51 0c             	mov    0xc(%ecx),%edx
  803a61:	89 d0                	mov    %edx,%eax
  803a63:	c9                   	leave  
  803a64:	c3                   	ret    

00803a65 <listen>:
  803a65:	55                   	push   %ebp
  803a66:	89 e5                	mov    %esp,%ebp
  803a68:	83 ec 08             	sub    $0x8,%esp
  803a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  803a6e:	e8 be ff ff ff       	call   803a31 <fd2sockid>
  803a73:	89 c2                	mov    %eax,%edx
  803a75:	85 c0                	test   %eax,%eax
  803a77:	78 11                	js     803a8a <listen+0x25>
  803a79:	8b 45 0c             	mov    0xc(%ebp),%eax
  803a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  803a80:	89 14 24             	mov    %edx,(%esp)
  803a83:	e8 48 01 00 00       	call   803bd0 <nsipc_listen>
  803a88:	89 c2                	mov    %eax,%edx
  803a8a:	89 d0                	mov    %edx,%eax
  803a8c:	c9                   	leave  
  803a8d:	c3                   	ret    

00803a8e <connect>:
  803a8e:	55                   	push   %ebp
  803a8f:	89 e5                	mov    %esp,%ebp
  803a91:	83 ec 18             	sub    $0x18,%esp
  803a94:	8b 45 08             	mov    0x8(%ebp),%eax
  803a97:	e8 95 ff ff ff       	call   803a31 <fd2sockid>
  803a9c:	89 c2                	mov    %eax,%edx
  803a9e:	85 c0                	test   %eax,%eax
  803aa0:	78 18                	js     803aba <connect+0x2c>
  803aa2:	8b 45 10             	mov    0x10(%ebp),%eax
  803aa5:	89 44 24 08          	mov    %eax,0x8(%esp)
  803aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  803aac:	89 44 24 04          	mov    %eax,0x4(%esp)
  803ab0:	89 14 24             	mov    %edx,(%esp)
  803ab3:	e8 71 02 00 00       	call   803d29 <nsipc_connect>
  803ab8:	89 c2                	mov    %eax,%edx
  803aba:	89 d0                	mov    %edx,%eax
  803abc:	c9                   	leave  
  803abd:	c3                   	ret    

00803abe <shutdown>:
  803abe:	55                   	push   %ebp
  803abf:	89 e5                	mov    %esp,%ebp
  803ac1:	83 ec 08             	sub    $0x8,%esp
  803ac4:	8b 45 08             	mov    0x8(%ebp),%eax
  803ac7:	e8 65 ff ff ff       	call   803a31 <fd2sockid>
  803acc:	89 c2                	mov    %eax,%edx
  803ace:	85 c0                	test   %eax,%eax
  803ad0:	78 11                	js     803ae3 <shutdown+0x25>
  803ad2:	8b 45 0c             	mov    0xc(%ebp),%eax
  803ad5:	89 44 24 04          	mov    %eax,0x4(%esp)
  803ad9:	89 14 24             	mov    %edx,(%esp)
  803adc:	e8 2b 01 00 00       	call   803c0c <nsipc_shutdown>
  803ae1:	89 c2                	mov    %eax,%edx
  803ae3:	89 d0                	mov    %edx,%eax
  803ae5:	c9                   	leave  
  803ae6:	c3                   	ret    

00803ae7 <bind>:
  803ae7:	55                   	push   %ebp
  803ae8:	89 e5                	mov    %esp,%ebp
  803aea:	83 ec 18             	sub    $0x18,%esp
  803aed:	8b 45 08             	mov    0x8(%ebp),%eax
  803af0:	e8 3c ff ff ff       	call   803a31 <fd2sockid>
  803af5:	89 c2                	mov    %eax,%edx
  803af7:	85 c0                	test   %eax,%eax
  803af9:	78 18                	js     803b13 <bind+0x2c>
  803afb:	8b 45 10             	mov    0x10(%ebp),%eax
  803afe:	89 44 24 08          	mov    %eax,0x8(%esp)
  803b02:	8b 45 0c             	mov    0xc(%ebp),%eax
  803b05:	89 44 24 04          	mov    %eax,0x4(%esp)
  803b09:	89 14 24             	mov    %edx,(%esp)
  803b0c:	e8 57 02 00 00       	call   803d68 <nsipc_bind>
  803b11:	89 c2                	mov    %eax,%edx
  803b13:	89 d0                	mov    %edx,%eax
  803b15:	c9                   	leave  
  803b16:	c3                   	ret    

00803b17 <accept>:
  803b17:	55                   	push   %ebp
  803b18:	89 e5                	mov    %esp,%ebp
  803b1a:	83 ec 18             	sub    $0x18,%esp
  803b1d:	8b 45 08             	mov    0x8(%ebp),%eax
  803b20:	e8 0c ff ff ff       	call   803a31 <fd2sockid>
  803b25:	89 c2                	mov    %eax,%edx
  803b27:	85 c0                	test   %eax,%eax
  803b29:	78 23                	js     803b4e <accept+0x37>
  803b2b:	8b 45 10             	mov    0x10(%ebp),%eax
  803b2e:	89 44 24 08          	mov    %eax,0x8(%esp)
  803b32:	8b 45 0c             	mov    0xc(%ebp),%eax
  803b35:	89 44 24 04          	mov    %eax,0x4(%esp)
  803b39:	89 14 24             	mov    %edx,(%esp)
  803b3c:	e8 66 02 00 00       	call   803da7 <nsipc_accept>
  803b41:	89 c2                	mov    %eax,%edx
  803b43:	85 c0                	test   %eax,%eax
  803b45:	78 07                	js     803b4e <accept+0x37>
  803b47:	e8 42 fe ff ff       	call   80398e <alloc_sockfd>
  803b4c:	89 c2                	mov    %eax,%edx
  803b4e:	89 d0                	mov    %edx,%eax
  803b50:	c9                   	leave  
  803b51:	c3                   	ret    
	...

00803b60 <nsipc>:
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  803b60:	55                   	push   %ebp
  803b61:	89 e5                	mov    %esp,%ebp
  803b63:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  803b66:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  803b6c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  803b73:	00 
  803b74:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  803b7b:	00 
  803b7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  803b80:	89 14 24             	mov    %edx,(%esp)
  803b83:	e8 b8 f2 ff ff       	call   802e40 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  803b88:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803b8f:	00 
  803b90:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  803b97:	00 
  803b98:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803b9f:	e8 50 f3 ff ff       	call   802ef4 <ipc_recv>
}
  803ba4:	c9                   	leave  
  803ba5:	c3                   	ret    

00803ba6 <nsipc_socket>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	
	nsipcbuf.accept.req_s = s;
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
	nsipcbuf.bind.req_s = s;
	memmove(&nsipcbuf.bind.req_name, name, namelen);
	nsipcbuf.bind.req_namelen = namelen;
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
	nsipcbuf.shutdown.req_s = s;
	nsipcbuf.shutdown.req_how = how;
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
	nsipcbuf.close.req_s = s;
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
	nsipcbuf.connect.req_s = s;
	memmove(&nsipcbuf.connect.req_name, name, namelen);
	nsipcbuf.connect.req_namelen = namelen;
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
	nsipcbuf.listen.req_s = s;
	nsipcbuf.listen.req_backlog = backlog;
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
	int r;

	nsipcbuf.recv.req_s = s;
	nsipcbuf.recv.req_len = len;
	nsipcbuf.recv.req_flags = flags;

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
		assert(r < 1600 && r <= len);
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
	}

	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
	nsipcbuf.send.req_s = s;
	assert(size < 1600);
	memmove(&nsipcbuf.send.req_buf, buf, size);
	nsipcbuf.send.req_size = size;
	nsipcbuf.send.req_flags = flags;
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  803ba6:	55                   	push   %ebp
  803ba7:	89 e5                	mov    %esp,%ebp
  803ba9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  803bac:	8b 45 08             	mov    0x8(%ebp),%eax
  803baf:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  803bb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  803bb7:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  803bbc:	8b 45 10             	mov    0x10(%ebp),%eax
  803bbf:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  803bc4:	b8 09 00 00 00       	mov    $0x9,%eax
  803bc9:	e8 92 ff ff ff       	call   803b60 <nsipc>
}
  803bce:	c9                   	leave  
  803bcf:	c3                   	ret    

00803bd0 <nsipc_listen>:
  803bd0:	55                   	push   %ebp
  803bd1:	89 e5                	mov    %esp,%ebp
  803bd3:	83 ec 08             	sub    $0x8,%esp
  803bd6:	8b 45 08             	mov    0x8(%ebp),%eax
  803bd9:	a3 00 70 80 00       	mov    %eax,0x807000
  803bde:	8b 45 0c             	mov    0xc(%ebp),%eax
  803be1:	a3 04 70 80 00       	mov    %eax,0x807004
  803be6:	b8 06 00 00 00       	mov    $0x6,%eax
  803beb:	e8 70 ff ff ff       	call   803b60 <nsipc>
  803bf0:	c9                   	leave  
  803bf1:	c3                   	ret    

00803bf2 <nsipc_close>:
  803bf2:	55                   	push   %ebp
  803bf3:	89 e5                	mov    %esp,%ebp
  803bf5:	83 ec 08             	sub    $0x8,%esp
  803bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  803bfb:	a3 00 70 80 00       	mov    %eax,0x807000
  803c00:	b8 04 00 00 00       	mov    $0x4,%eax
  803c05:	e8 56 ff ff ff       	call   803b60 <nsipc>
  803c0a:	c9                   	leave  
  803c0b:	c3                   	ret    

00803c0c <nsipc_shutdown>:
  803c0c:	55                   	push   %ebp
  803c0d:	89 e5                	mov    %esp,%ebp
  803c0f:	83 ec 08             	sub    $0x8,%esp
  803c12:	8b 45 08             	mov    0x8(%ebp),%eax
  803c15:	a3 00 70 80 00       	mov    %eax,0x807000
  803c1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  803c1d:	a3 04 70 80 00       	mov    %eax,0x807004
  803c22:	b8 03 00 00 00       	mov    $0x3,%eax
  803c27:	e8 34 ff ff ff       	call   803b60 <nsipc>
  803c2c:	c9                   	leave  
  803c2d:	c3                   	ret    

00803c2e <nsipc_send>:
  803c2e:	55                   	push   %ebp
  803c2f:	89 e5                	mov    %esp,%ebp
  803c31:	53                   	push   %ebx
  803c32:	83 ec 14             	sub    $0x14,%esp
  803c35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  803c38:	8b 45 08             	mov    0x8(%ebp),%eax
  803c3b:	a3 00 70 80 00       	mov    %eax,0x807000
  803c40:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  803c46:	7e 24                	jle    803c6c <nsipc_send+0x3e>
  803c48:	c7 44 24 0c 84 4a 80 	movl   $0x804a84,0xc(%esp)
  803c4f:	00 
  803c50:	c7 44 24 08 fd 40 80 	movl   $0x8040fd,0x8(%esp)
  803c57:	00 
  803c58:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  803c5f:	00 
  803c60:	c7 04 24 90 4a 80 00 	movl   $0x804a90,(%esp)
  803c67:	e8 88 e1 ff ff       	call   801df4 <_panic>
  803c6c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803c70:	8b 45 0c             	mov    0xc(%ebp),%eax
  803c73:	89 44 24 04          	mov    %eax,0x4(%esp)
  803c77:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  803c7e:	e8 c7 ea ff ff       	call   80274a <memmove>
  803c83:	89 1d 04 70 80 00    	mov    %ebx,0x807004
  803c89:	8b 45 14             	mov    0x14(%ebp),%eax
  803c8c:	a3 08 70 80 00       	mov    %eax,0x807008
  803c91:	b8 08 00 00 00       	mov    $0x8,%eax
  803c96:	e8 c5 fe ff ff       	call   803b60 <nsipc>
  803c9b:	83 c4 14             	add    $0x14,%esp
  803c9e:	5b                   	pop    %ebx
  803c9f:	5d                   	pop    %ebp
  803ca0:	c3                   	ret    

00803ca1 <nsipc_recv>:
  803ca1:	55                   	push   %ebp
  803ca2:	89 e5                	mov    %esp,%ebp
  803ca4:	83 ec 18             	sub    $0x18,%esp
  803ca7:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  803caa:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  803cad:	8b 75 10             	mov    0x10(%ebp),%esi
  803cb0:	8b 45 08             	mov    0x8(%ebp),%eax
  803cb3:	a3 00 70 80 00       	mov    %eax,0x807000
  803cb8:	89 35 04 70 80 00    	mov    %esi,0x807004
  803cbe:	8b 45 14             	mov    0x14(%ebp),%eax
  803cc1:	a3 08 70 80 00       	mov    %eax,0x807008
  803cc6:	b8 07 00 00 00       	mov    $0x7,%eax
  803ccb:	e8 90 fe ff ff       	call   803b60 <nsipc>
  803cd0:	89 c3                	mov    %eax,%ebx
  803cd2:	85 c0                	test   %eax,%eax
  803cd4:	78 47                	js     803d1d <nsipc_recv+0x7c>
  803cd6:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  803cdb:	7f 05                	jg     803ce2 <nsipc_recv+0x41>
  803cdd:	39 c6                	cmp    %eax,%esi
  803cdf:	90                   	nop    
  803ce0:	7d 24                	jge    803d06 <nsipc_recv+0x65>
  803ce2:	c7 44 24 0c 9c 4a 80 	movl   $0x804a9c,0xc(%esp)
  803ce9:	00 
  803cea:	c7 44 24 08 fd 40 80 	movl   $0x8040fd,0x8(%esp)
  803cf1:	00 
  803cf2:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  803cf9:	00 
  803cfa:	c7 04 24 90 4a 80 00 	movl   $0x804a90,(%esp)
  803d01:	e8 ee e0 ff ff       	call   801df4 <_panic>
  803d06:	89 44 24 08          	mov    %eax,0x8(%esp)
  803d0a:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  803d11:	00 
  803d12:	8b 45 0c             	mov    0xc(%ebp),%eax
  803d15:	89 04 24             	mov    %eax,(%esp)
  803d18:	e8 2d ea ff ff       	call   80274a <memmove>
  803d1d:	89 d8                	mov    %ebx,%eax
  803d1f:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  803d22:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  803d25:	89 ec                	mov    %ebp,%esp
  803d27:	5d                   	pop    %ebp
  803d28:	c3                   	ret    

00803d29 <nsipc_connect>:
  803d29:	55                   	push   %ebp
  803d2a:	89 e5                	mov    %esp,%ebp
  803d2c:	53                   	push   %ebx
  803d2d:	83 ec 14             	sub    $0x14,%esp
  803d30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  803d33:	8b 45 08             	mov    0x8(%ebp),%eax
  803d36:	a3 00 70 80 00       	mov    %eax,0x807000
  803d3b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803d3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  803d42:	89 44 24 04          	mov    %eax,0x4(%esp)
  803d46:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  803d4d:	e8 f8 e9 ff ff       	call   80274a <memmove>
  803d52:	89 1d 14 70 80 00    	mov    %ebx,0x807014
  803d58:	b8 05 00 00 00       	mov    $0x5,%eax
  803d5d:	e8 fe fd ff ff       	call   803b60 <nsipc>
  803d62:	83 c4 14             	add    $0x14,%esp
  803d65:	5b                   	pop    %ebx
  803d66:	5d                   	pop    %ebp
  803d67:	c3                   	ret    

00803d68 <nsipc_bind>:
  803d68:	55                   	push   %ebp
  803d69:	89 e5                	mov    %esp,%ebp
  803d6b:	53                   	push   %ebx
  803d6c:	83 ec 14             	sub    $0x14,%esp
  803d6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  803d72:	8b 45 08             	mov    0x8(%ebp),%eax
  803d75:	a3 00 70 80 00       	mov    %eax,0x807000
  803d7a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803d7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  803d81:	89 44 24 04          	mov    %eax,0x4(%esp)
  803d85:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  803d8c:	e8 b9 e9 ff ff       	call   80274a <memmove>
  803d91:	89 1d 14 70 80 00    	mov    %ebx,0x807014
  803d97:	b8 02 00 00 00       	mov    $0x2,%eax
  803d9c:	e8 bf fd ff ff       	call   803b60 <nsipc>
  803da1:	83 c4 14             	add    $0x14,%esp
  803da4:	5b                   	pop    %ebx
  803da5:	5d                   	pop    %ebp
  803da6:	c3                   	ret    

00803da7 <nsipc_accept>:
  803da7:	55                   	push   %ebp
  803da8:	89 e5                	mov    %esp,%ebp
  803daa:	53                   	push   %ebx
  803dab:	83 ec 14             	sub    $0x14,%esp
  803dae:	8b 45 08             	mov    0x8(%ebp),%eax
  803db1:	a3 00 70 80 00       	mov    %eax,0x807000
  803db6:	b8 01 00 00 00       	mov    $0x1,%eax
  803dbb:	e8 a0 fd ff ff       	call   803b60 <nsipc>
  803dc0:	89 c3                	mov    %eax,%ebx
  803dc2:	85 c0                	test   %eax,%eax
  803dc4:	78 27                	js     803ded <nsipc_accept+0x46>
  803dc6:	a1 10 70 80 00       	mov    0x807010,%eax
  803dcb:	89 44 24 08          	mov    %eax,0x8(%esp)
  803dcf:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  803dd6:	00 
  803dd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  803dda:	89 04 24             	mov    %eax,(%esp)
  803ddd:	e8 68 e9 ff ff       	call   80274a <memmove>
  803de2:	8b 15 10 70 80 00    	mov    0x807010,%edx
  803de8:	8b 45 10             	mov    0x10(%ebp),%eax
  803deb:	89 10                	mov    %edx,(%eax)
  803ded:	89 d8                	mov    %ebx,%eax
  803def:	83 c4 14             	add    $0x14,%esp
  803df2:	5b                   	pop    %ebx
  803df3:	5d                   	pop    %ebp
  803df4:	c3                   	ret    
	...

00803e00 <__udivdi3>:
  803e00:	55                   	push   %ebp
  803e01:	89 e5                	mov    %esp,%ebp
  803e03:	57                   	push   %edi
  803e04:	56                   	push   %esi
  803e05:	83 ec 1c             	sub    $0x1c,%esp
  803e08:	8b 45 10             	mov    0x10(%ebp),%eax
  803e0b:	8b 55 14             	mov    0x14(%ebp),%edx
  803e0e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  803e11:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  803e14:	89 c1                	mov    %eax,%ecx
  803e16:	8b 45 08             	mov    0x8(%ebp),%eax
  803e19:	85 d2                	test   %edx,%edx
  803e1b:	89 d6                	mov    %edx,%esi
  803e1d:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
  803e20:	75 1e                	jne    803e40 <__udivdi3+0x40>
  803e22:	39 f9                	cmp    %edi,%ecx
  803e24:	0f 86 8d 00 00 00    	jbe    803eb7 <__udivdi3+0xb7>
  803e2a:	89 fa                	mov    %edi,%edx
  803e2c:	f7 f1                	div    %ecx
  803e2e:	89 c1                	mov    %eax,%ecx
  803e30:	89 c8                	mov    %ecx,%eax
  803e32:	89 f2                	mov    %esi,%edx
  803e34:	83 c4 1c             	add    $0x1c,%esp
  803e37:	5e                   	pop    %esi
  803e38:	5f                   	pop    %edi
  803e39:	5d                   	pop    %ebp
  803e3a:	c3                   	ret    
  803e3b:	90                   	nop    
  803e3c:	8d 74 26 00          	lea    0x0(%esi),%esi
  803e40:	39 fa                	cmp    %edi,%edx
  803e42:	0f 87 98 00 00 00    	ja     803ee0 <__udivdi3+0xe0>
  803e48:	0f bd c2             	bsr    %edx,%eax
  803e4b:	83 f0 1f             	xor    $0x1f,%eax
  803e4e:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  803e51:	74 7f                	je     803ed2 <__udivdi3+0xd2>
  803e53:	b8 20 00 00 00       	mov    $0x20,%eax
  803e58:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  803e5b:	2b 45 e4             	sub    0xffffffe4(%ebp),%eax
  803e5e:	89 c1                	mov    %eax,%ecx
  803e60:	d3 ea                	shr    %cl,%edx
  803e62:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  803e66:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  803e69:	89 f0                	mov    %esi,%eax
  803e6b:	d3 e0                	shl    %cl,%eax
  803e6d:	09 c2                	or     %eax,%edx
  803e6f:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  803e72:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  803e75:	89 fa                	mov    %edi,%edx
  803e77:	d3 e0                	shl    %cl,%eax
  803e79:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  803e7d:	89 45 f4             	mov    %eax,0xfffffff4(%ebp)
  803e80:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  803e83:	d3 e8                	shr    %cl,%eax
  803e85:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  803e89:	d3 e2                	shl    %cl,%edx
  803e8b:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  803e8f:	09 d0                	or     %edx,%eax
  803e91:	d3 ef                	shr    %cl,%edi
  803e93:	89 fa                	mov    %edi,%edx
  803e95:	f7 75 e0             	divl   0xffffffe0(%ebp)
  803e98:	89 d1                	mov    %edx,%ecx
  803e9a:	89 c7                	mov    %eax,%edi
  803e9c:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  803e9f:	f7 e7                	mul    %edi
  803ea1:	39 d1                	cmp    %edx,%ecx
  803ea3:	89 c6                	mov    %eax,%esi
  803ea5:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  803ea8:	72 6f                	jb     803f19 <__udivdi3+0x119>
  803eaa:	39 ca                	cmp    %ecx,%edx
  803eac:	74 5e                	je     803f0c <__udivdi3+0x10c>
  803eae:	89 f9                	mov    %edi,%ecx
  803eb0:	31 f6                	xor    %esi,%esi
  803eb2:	e9 79 ff ff ff       	jmp    803e30 <__udivdi3+0x30>
  803eb7:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  803eba:	85 c0                	test   %eax,%eax
  803ebc:	74 32                	je     803ef0 <__udivdi3+0xf0>
  803ebe:	89 f2                	mov    %esi,%edx
  803ec0:	89 f8                	mov    %edi,%eax
  803ec2:	f7 f1                	div    %ecx
  803ec4:	89 c6                	mov    %eax,%esi
  803ec6:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  803ec9:	f7 f1                	div    %ecx
  803ecb:	89 c1                	mov    %eax,%ecx
  803ecd:	e9 5e ff ff ff       	jmp    803e30 <__udivdi3+0x30>
  803ed2:	39 d7                	cmp    %edx,%edi
  803ed4:	77 2a                	ja     803f00 <__udivdi3+0x100>
  803ed6:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  803ed9:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  803edc:	73 22                	jae    803f00 <__udivdi3+0x100>
  803ede:	66 90                	xchg   %ax,%ax
  803ee0:	31 c9                	xor    %ecx,%ecx
  803ee2:	31 f6                	xor    %esi,%esi
  803ee4:	e9 47 ff ff ff       	jmp    803e30 <__udivdi3+0x30>
  803ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  803ef0:	b8 01 00 00 00       	mov    $0x1,%eax
  803ef5:	31 d2                	xor    %edx,%edx
  803ef7:	f7 75 f0             	divl   0xfffffff0(%ebp)
  803efa:	89 c1                	mov    %eax,%ecx
  803efc:	eb c0                	jmp    803ebe <__udivdi3+0xbe>
  803efe:	66 90                	xchg   %ax,%ax
  803f00:	b9 01 00 00 00       	mov    $0x1,%ecx
  803f05:	31 f6                	xor    %esi,%esi
  803f07:	e9 24 ff ff ff       	jmp    803e30 <__udivdi3+0x30>
  803f0c:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  803f0f:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  803f13:	d3 e0                	shl    %cl,%eax
  803f15:	39 c6                	cmp    %eax,%esi
  803f17:	76 95                	jbe    803eae <__udivdi3+0xae>
  803f19:	8d 4f ff             	lea    0xffffffff(%edi),%ecx
  803f1c:	31 f6                	xor    %esi,%esi
  803f1e:	e9 0d ff ff ff       	jmp    803e30 <__udivdi3+0x30>
	...

00803f30 <__umoddi3>:
  803f30:	55                   	push   %ebp
  803f31:	89 e5                	mov    %esp,%ebp
  803f33:	57                   	push   %edi
  803f34:	56                   	push   %esi
  803f35:	83 ec 30             	sub    $0x30,%esp
  803f38:	8b 55 14             	mov    0x14(%ebp),%edx
  803f3b:	8b 45 10             	mov    0x10(%ebp),%eax
  803f3e:	8b 75 08             	mov    0x8(%ebp),%esi
  803f41:	8b 7d 0c             	mov    0xc(%ebp),%edi
  803f44:	85 d2                	test   %edx,%edx
  803f46:	c7 45 d0 00 00 00 00 	movl   $0x0,0xffffffd0(%ebp)
  803f4d:	89 c1                	mov    %eax,%ecx
  803f4f:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  803f56:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  803f59:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  803f5c:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  803f5f:	89 7d e0             	mov    %edi,0xffffffe0(%ebp)
  803f62:	75 1c                	jne    803f80 <__umoddi3+0x50>
  803f64:	39 f8                	cmp    %edi,%eax
  803f66:	89 fa                	mov    %edi,%edx
  803f68:	0f 86 d4 00 00 00    	jbe    804042 <__umoddi3+0x112>
  803f6e:	89 f0                	mov    %esi,%eax
  803f70:	f7 f1                	div    %ecx
  803f72:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  803f75:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  803f7c:	eb 12                	jmp    803f90 <__umoddi3+0x60>
  803f7e:	66 90                	xchg   %ax,%ax
  803f80:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  803f83:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  803f86:	76 18                	jbe    803fa0 <__umoddi3+0x70>
  803f88:	89 75 d0             	mov    %esi,0xffffffd0(%ebp)
  803f8b:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  803f8e:	66 90                	xchg   %ax,%ax
  803f90:	8b 45 d0             	mov    0xffffffd0(%ebp),%eax
  803f93:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  803f96:	83 c4 30             	add    $0x30,%esp
  803f99:	5e                   	pop    %esi
  803f9a:	5f                   	pop    %edi
  803f9b:	5d                   	pop    %ebp
  803f9c:	c3                   	ret    
  803f9d:	8d 76 00             	lea    0x0(%esi),%esi
  803fa0:	0f bd 45 e8          	bsr    0xffffffe8(%ebp),%eax
  803fa4:	83 f0 1f             	xor    $0x1f,%eax
  803fa7:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  803faa:	0f 84 c0 00 00 00    	je     804070 <__umoddi3+0x140>
  803fb0:	b8 20 00 00 00       	mov    $0x20,%eax
  803fb5:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  803fb8:	2b 45 dc             	sub    0xffffffdc(%ebp),%eax
  803fbb:	8b 7d ec             	mov    0xffffffec(%ebp),%edi
  803fbe:	8b 75 f0             	mov    0xfffffff0(%ebp),%esi
  803fc1:	89 c1                	mov    %eax,%ecx
  803fc3:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  803fc6:	d3 ea                	shr    %cl,%edx
  803fc8:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  803fcb:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  803fcf:	d3 e0                	shl    %cl,%eax
  803fd1:	09 c2                	or     %eax,%edx
  803fd3:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  803fd6:	d3 e7                	shl    %cl,%edi
  803fd8:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  803fdc:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  803fdf:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  803fe2:	d3 e8                	shr    %cl,%eax
  803fe4:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  803fe8:	d3 e2                	shl    %cl,%edx
  803fea:	09 d0                	or     %edx,%eax
  803fec:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  803fef:	d3 e6                	shl    %cl,%esi
  803ff1:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  803ff5:	d3 ea                	shr    %cl,%edx
  803ff7:	f7 75 f4             	divl   0xfffffff4(%ebp)
  803ffa:	89 55 cc             	mov    %edx,0xffffffcc(%ebp)
  803ffd:	f7 e7                	mul    %edi
  803fff:	39 55 cc             	cmp    %edx,0xffffffcc(%ebp)
  804002:	0f 82 a5 00 00 00    	jb     8040ad <__umoddi3+0x17d>
  804008:	3b 55 cc             	cmp    0xffffffcc(%ebp),%edx
  80400b:	0f 84 94 00 00 00    	je     8040a5 <__umoddi3+0x175>
  804011:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  804014:	29 c6                	sub    %eax,%esi
  804016:	19 d1                	sbb    %edx,%ecx
  804018:	89 4d cc             	mov    %ecx,0xffffffcc(%ebp)
  80401b:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  80401f:	89 f2                	mov    %esi,%edx
  804021:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  804024:	d3 ea                	shr    %cl,%edx
  804026:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  80402a:	d3 e0                	shl    %cl,%eax
  80402c:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  804030:	09 c2                	or     %eax,%edx
  804032:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  804035:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  804038:	d3 e8                	shr    %cl,%eax
  80403a:	89 45 d4             	mov    %eax,0xffffffd4(%ebp)
  80403d:	e9 4e ff ff ff       	jmp    803f90 <__umoddi3+0x60>
  804042:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  804045:	85 c0                	test   %eax,%eax
  804047:	74 17                	je     804060 <__umoddi3+0x130>
  804049:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  80404c:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
  80404f:	f7 f1                	div    %ecx
  804051:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  804054:	f7 f1                	div    %ecx
  804056:	e9 17 ff ff ff       	jmp    803f72 <__umoddi3+0x42>
  80405b:	90                   	nop    
  80405c:	8d 74 26 00          	lea    0x0(%esi),%esi
  804060:	b8 01 00 00 00       	mov    $0x1,%eax
  804065:	31 d2                	xor    %edx,%edx
  804067:	f7 75 ec             	divl   0xffffffec(%ebp)
  80406a:	89 c1                	mov    %eax,%ecx
  80406c:	eb db                	jmp    804049 <__umoddi3+0x119>
  80406e:	66 90                	xchg   %ax,%ax
  804070:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  804073:	39 45 e0             	cmp    %eax,0xffffffe0(%ebp)
  804076:	77 19                	ja     804091 <__umoddi3+0x161>
  804078:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  80407b:	39 55 f0             	cmp    %edx,0xfffffff0(%ebp)
  80407e:	73 11                	jae    804091 <__umoddi3+0x161>
  804080:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  804083:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  804086:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  804089:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  80408c:	e9 ff fe ff ff       	jmp    803f90 <__umoddi3+0x60>
  804091:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  804094:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  804097:	2b 45 ec             	sub    0xffffffec(%ebp),%eax
  80409a:	1b 4d e8             	sbb    0xffffffe8(%ebp),%ecx
  80409d:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  8040a0:	89 4d e0             	mov    %ecx,0xffffffe0(%ebp)
  8040a3:	eb db                	jmp    804080 <__umoddi3+0x150>
  8040a5:	39 f0                	cmp    %esi,%eax
  8040a7:	0f 86 64 ff ff ff    	jbe    804011 <__umoddi3+0xe1>
  8040ad:	29 f8                	sub    %edi,%eax
  8040af:	1b 55 f4             	sbb    0xfffffff4(%ebp),%edx
  8040b2:	e9 5a ff ff ff       	jmp    804011 <__umoddi3+0xe1>
