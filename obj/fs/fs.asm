
obj/fs/fs:     file format elf32-i386

Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 23 1d 00 00       	call   801d54 <libmain>
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
  800043:	89 c1                	mov    %eax,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800045:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80004a:	ec                   	in     (%dx),%al
	return data;
  80004b:	0f b6 d0             	movzbl %al,%edx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  80004e:	89 d0                	mov    %edx,%eax
  800050:	25 c0 00 00 00       	and    $0xc0,%eax
  800055:	83 f8 40             	cmp    $0x40,%eax
  800058:	75 eb                	jne    800045 <ide_wait_ready+0x5>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80005a:	85 c9                	test   %ecx,%ecx
  80005c:	74 0a                	je     800068 <ide_wait_ready+0x28>
  80005e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800063:	f6 c2 21             	test   $0x21,%dl
  800066:	75 05                	jne    80006d <ide_wait_ready+0x2d>
  800068:	b8 00 00 00 00       	mov    $0x0,%eax
		return -1;
	return 0;
}
  80006d:	5d                   	pop    %ebp
  80006e:	66 90                	xchg   %ax,%ax
  800070:	c3                   	ret    

00800071 <ide_set_disk>:
	return (x < 1000);
}

void
ide_set_disk(int d)
{
  800071:	55                   	push   %ebp
  800072:	89 e5                	mov    %esp,%ebp
  800074:	83 ec 18             	sub    $0x18,%esp
  800077:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  80007a:	83 f8 01             	cmp    $0x1,%eax
  80007d:	76 1c                	jbe    80009b <ide_set_disk+0x2a>
		panic("bad disk number");
  80007f:	c7 44 24 08 40 40 80 	movl   $0x804040,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  80008e:	00 
  80008f:	c7 04 24 50 40 80 00 	movl   $0x804050,(%esp)
  800096:	e8 31 1d 00 00       	call   801dcc <_panic>
	diskno = d;
  80009b:	a3 00 80 80 00       	mov    %eax,0x808000
}
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <ide_probe_disk1>:
	return 0;
}

bool
ide_probe_disk1(void)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	53                   	push   %ebx
  8000a6:	83 ec 14             	sub    $0x14,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  8000a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ae:	e8 8d ff ff ff       	call   800040 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8000b3:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  8000b8:	ba f6 01 00 00       	mov    $0x1f6,%edx
  8000bd:	ee                   	out    %al,(%dx)
  8000be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000c3:	eb 0b                	jmp    8000d0 <ide_probe_disk1+0x2e>
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0; 
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0; 
	     x++)
  8000c5:	83 c1 01             	add    $0x1,%ecx
	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0; 
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0; 
  8000c8:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  8000ce:	74 0a                	je     8000da <ide_probe_disk1+0x38>

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  8000d0:	ba f7 01 00 00       	mov    $0x1f7,%edx
  8000d5:	ec                   	in     (%dx),%al
  8000d6:	a8 a1                	test   $0xa1,%al
  8000d8:	75 eb                	jne    8000c5 <ide_probe_disk1+0x23>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8000da:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  8000df:	ba f6 01 00 00       	mov    $0x1f6,%edx
  8000e4:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000e5:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000eb:	0f 9e c3             	setle  %bl
  8000ee:	0f b6 db             	movzbl %bl,%ebx
  8000f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000f5:	c7 04 24 59 40 80 00 	movl   $0x804059,(%esp)
  8000fc:	e8 98 1d 00 00       	call   801e99 <cprintf>
	return (x < 1000);
}
  800101:	89 d8                	mov    %ebx,%eax
  800103:	83 c4 14             	add    $0x14,%esp
  800106:	5b                   	pop    %ebx
  800107:	5d                   	pop    %ebp
  800108:	c3                   	ret    

00800109 <ide_read>:
	diskno = d;
}

int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  800109:	55                   	push   %ebp
  80010a:	89 e5                	mov    %esp,%ebp
  80010c:	57                   	push   %edi
  80010d:	56                   	push   %esi
  80010e:	53                   	push   %ebx
  80010f:	83 ec 1c             	sub    $0x1c,%esp
  800112:	8b 75 08             	mov    0x8(%ebp),%esi
  800115:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int r;

	assert(nsecs <= 256);
  800118:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
  80011e:	76 24                	jbe    800144 <ide_read+0x3b>
  800120:	c7 44 24 0c 70 40 80 	movl   $0x804070,0xc(%esp)
  800127:	00 
  800128:	c7 44 24 08 7d 40 80 	movl   $0x80407d,0x8(%esp)
  80012f:	00 
  800130:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  800137:	00 
  800138:	c7 04 24 50 40 80 00 	movl   $0x804050,(%esp)
  80013f:	e8 88 1c 00 00       	call   801dcc <_panic>

	ide_wait_ready(0);
  800144:	b8 00 00 00 00       	mov    $0x0,%eax
  800149:	e8 f2 fe ff ff       	call   800040 <ide_wait_ready>
  80014e:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800153:	89 d8                	mov    %ebx,%eax
  800155:	ee                   	out    %al,(%dx)
  800156:	b2 f3                	mov    $0xf3,%dl
  800158:	89 f0                	mov    %esi,%eax
  80015a:	ee                   	out    %al,(%dx)
  80015b:	89 f0                	mov    %esi,%eax
  80015d:	c1 e8 08             	shr    $0x8,%eax
  800160:	b2 f4                	mov    $0xf4,%dl
  800162:	ee                   	out    %al,(%dx)
  800163:	89 f0                	mov    %esi,%eax
  800165:	c1 e8 10             	shr    $0x10,%eax
  800168:	b2 f5                	mov    $0xf5,%dl
  80016a:	ee                   	out    %al,(%dx)
  80016b:	0f b6 05 00 80 80 00 	movzbl 0x808000,%eax
  800172:	83 e0 01             	and    $0x1,%eax
  800175:	c1 e0 04             	shl    $0x4,%eax
  800178:	89 c2                	mov    %eax,%edx
  80017a:	83 ca e0             	or     $0xffffffe0,%edx
  80017d:	89 f0                	mov    %esi,%eax
  80017f:	c1 e8 18             	shr    $0x18,%eax
  800182:	83 e0 0f             	and    $0xf,%eax
  800185:	09 d0                	or     %edx,%eax
  800187:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80018c:	ee                   	out    %al,(%dx)
  80018d:	b8 20 00 00 00       	mov    $0x20,%eax
  800192:	b2 f7                	mov    $0xf7,%dl
  800194:	ee                   	out    %al,(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800195:	85 db                	test   %ebx,%ebx
  800197:	74 2c                	je     8001c5 <ide_read+0xbc>
		if ((r = ide_wait_ready(1)) < 0)
  800199:	b8 01 00 00 00       	mov    $0x1,%eax
  80019e:	e8 9d fe ff ff       	call   800040 <ide_wait_ready>
  8001a3:	85 c0                	test   %eax,%eax
  8001a5:	78 23                	js     8001ca <ide_read+0xc1>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
  8001a7:	ba f0 01 00 00       	mov    $0x1f0,%edx
  8001ac:	b9 80 00 00 00       	mov    $0x80,%ecx
  8001b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8001b4:	fc                   	cld    
  8001b5:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  8001b7:	83 eb 01             	sub    $0x1,%ebx
  8001ba:	74 09                	je     8001c5 <ide_read+0xbc>
  8001bc:	81 45 0c 00 02 00 00 	addl   $0x200,0xc(%ebp)
  8001c3:	eb d4                	jmp    800199 <ide_read+0x90>
  8001c5:	b8 00 00 00 00       	mov    $0x0,%eax
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}
	
	return 0;
}
  8001ca:	83 c4 1c             	add    $0x1c,%esp
  8001cd:	5b                   	pop    %ebx
  8001ce:	5e                   	pop    %esi
  8001cf:	5f                   	pop    %edi
  8001d0:	5d                   	pop    %ebp
  8001d1:	c3                   	ret    

008001d2 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	57                   	push   %edi
  8001d6:	56                   	push   %esi
  8001d7:	53                   	push   %ebx
  8001d8:	83 ec 1c             	sub    $0x1c,%esp
  8001db:	8b 7d 08             	mov    0x8(%ebp),%edi
  8001de:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int r;
	
	assert(nsecs <= 256);
  8001e1:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
  8001e7:	76 24                	jbe    80020d <ide_write+0x3b>
  8001e9:	c7 44 24 0c 70 40 80 	movl   $0x804070,0xc(%esp)
  8001f0:	00 
  8001f1:	c7 44 24 08 7d 40 80 	movl   $0x80407d,0x8(%esp)
  8001f8:	00 
  8001f9:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800200:	00 
  800201:	c7 04 24 50 40 80 00 	movl   $0x804050,(%esp)
  800208:	e8 bf 1b 00 00       	call   801dcc <_panic>

	ide_wait_ready(0);
  80020d:	b8 00 00 00 00       	mov    $0x0,%eax
  800212:	e8 29 fe ff ff       	call   800040 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800217:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80021c:	89 d8                	mov    %ebx,%eax
  80021e:	ee                   	out    %al,(%dx)
  80021f:	b2 f3                	mov    $0xf3,%dl
  800221:	89 f8                	mov    %edi,%eax
  800223:	ee                   	out    %al,(%dx)
  800224:	89 f8                	mov    %edi,%eax
  800226:	c1 e8 08             	shr    $0x8,%eax
  800229:	b2 f4                	mov    $0xf4,%dl
  80022b:	ee                   	out    %al,(%dx)
  80022c:	89 f8                	mov    %edi,%eax
  80022e:	c1 e8 10             	shr    $0x10,%eax
  800231:	b2 f5                	mov    $0xf5,%dl
  800233:	ee                   	out    %al,(%dx)
  800234:	0f b6 05 00 80 80 00 	movzbl 0x808000,%eax
  80023b:	83 e0 01             	and    $0x1,%eax
  80023e:	c1 e0 04             	shl    $0x4,%eax
  800241:	89 c2                	mov    %eax,%edx
  800243:	83 ca e0             	or     $0xffffffe0,%edx
  800246:	89 f8                	mov    %edi,%eax
  800248:	c1 e8 18             	shr    $0x18,%eax
  80024b:	83 e0 0f             	and    $0xf,%eax
  80024e:	09 d0                	or     %edx,%eax
  800250:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800255:	ee                   	out    %al,(%dx)
  800256:	b8 30 00 00 00       	mov    $0x30,%eax
  80025b:	b2 f7                	mov    $0xf7,%dl
  80025d:	ee                   	out    %al,(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80025e:	85 db                	test   %ebx,%ebx
  800260:	74 2c                	je     80028e <ide_write+0xbc>
		if ((r = ide_wait_ready(1)) < 0)
  800262:	b8 01 00 00 00       	mov    $0x1,%eax
  800267:	e8 d4 fd ff ff       	call   800040 <ide_wait_ready>
  80026c:	85 c0                	test   %eax,%eax
  80026e:	78 23                	js     800293 <ide_write+0xc1>
}

static __inline void
outsl(int port, const void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\toutsl"		:
  800270:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800275:	b9 80 00 00 00       	mov    $0x80,%ecx
  80027a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80027d:	fc                   	cld    
  80027e:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  800280:	83 eb 01             	sub    $0x1,%ebx
  800283:	74 09                	je     80028e <ide_write+0xbc>
  800285:	81 45 0c 00 02 00 00 	addl   $0x200,0xc(%ebp)
  80028c:	eb d4                	jmp    800262 <ide_write+0x90>
  80028e:	b8 00 00 00 00       	mov    $0x0,%eax
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
}
  800293:	83 c4 1c             	add    $0x1c,%esp
  800296:	5b                   	pop    %ebx
  800297:	5e                   	pop    %esi
  800298:	5f                   	pop    %edi
  800299:	5d                   	pop    %ebp
  80029a:	c3                   	ret    
  80029b:	00 00                	add    %al,(%eax)
  80029d:	00 00                	add    %al,(%eax)
	...

008002a0 <va_is_mapped>:
}

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
	return (vpd[PDX(va)] & PTE_P) && (vpt[VPN(va)] & PTE_P);
  8002a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a6:	89 d0                	mov    %edx,%eax
  8002a8:	c1 e8 16             	shr    $0x16,%eax
  8002ab:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8002b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002b7:	a8 01                	test   $0x1,%al
  8002b9:	74 11                	je     8002cc <va_is_mapped+0x2c>
  8002bb:	89 d0                	mov    %edx,%eax
  8002bd:	c1 e8 0c             	shr    $0xc,%eax
  8002c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8002c7:	89 c1                	mov    %eax,%ecx
  8002c9:	83 e1 01             	and    $0x1,%ecx
}
  8002cc:	89 c8                	mov    %ecx,%eax
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
	return (vpt[VPN(va)] & PTE_D) != 0;
  8002d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d6:	c1 e8 0c             	shr    $0xc,%eax
  8002d9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8002e0:	c1 e8 06             	shr    $0x6,%eax
  8002e3:	83 e0 01             	and    $0x1,%eax
}
  8002e6:	5d                   	pop    %ebp
  8002e7:	c3                   	ret    

008002e8 <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	83 ec 18             	sub    $0x18,%esp
  8002ee:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  8002f1:	85 c0                	test   %eax,%eax
  8002f3:	74 0f                	je     800304 <diskaddr+0x1c>
  8002f5:	8b 15 a4 c0 80 00    	mov    0x80c0a4,%edx
  8002fb:	85 d2                	test   %edx,%edx
  8002fd:	74 25                	je     800324 <diskaddr+0x3c>
  8002ff:	3b 42 04             	cmp    0x4(%edx),%eax
  800302:	72 20                	jb     800324 <diskaddr+0x3c>
		panic("bad block number %08x in diskaddr", blockno);
  800304:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800308:	c7 44 24 08 94 40 80 	movl   $0x804094,0x8(%esp)
  80030f:	00 
  800310:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  800317:	00 
  800318:	c7 04 24 30 41 80 00 	movl   $0x804130,(%esp)
  80031f:	e8 a8 1a 00 00       	call   801dcc <_panic>
  800324:	c1 e0 0c             	shl    $0xc,%eax
  800327:	05 00 00 00 10       	add    $0x10000000,%eax
	return (char*) (DISKMAP + blockno * BLKSIZE);
}
  80032c:	c9                   	leave  
  80032d:	c3                   	ret    

0080032e <bc_pgfault>:
// Fault any disk block that is read or written in to memory by
// loading it from disk.
// Hint: Use ide_read and BLKSECTS.
static void
bc_pgfault(struct UTrapframe *utf)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	56                   	push   %esi
  800332:	53                   	push   %ebx
  800333:	83 ec 20             	sub    $0x20,%esp
  800336:	8b 4d 08             	mov    0x8(%ebp),%ecx
	void *addr = (void *) utf->utf_fault_va;
  800339:	8b 11                	mov    (%ecx),%edx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
	int r;

	// Check that the fault was within the block cache region
	// 检查异常是否发生在块缓冲区
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80033b:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
  800341:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800346:	76 2e                	jbe    800376 <bc_pgfault+0x48>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800348:	8b 41 04             	mov    0x4(%ecx),%eax
  80034b:	89 44 24 14          	mov    %eax,0x14(%esp)
  80034f:	89 54 24 10          	mov    %edx,0x10(%esp)
  800353:	8b 41 28             	mov    0x28(%ecx),%eax
  800356:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80035a:	c7 44 24 08 b8 40 80 	movl   $0x8040b8,0x8(%esp)
  800361:	00 
  800362:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  800369:	00 
  80036a:	c7 04 24 30 41 80 00 	movl   $0x804130,(%esp)
  800371:	e8 56 1a 00 00       	call   801dcc <_panic>
// Hint: Use ide_read and BLKSECTS.
static void
bc_pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800376:	89 d3                	mov    %edx,%ebx

	// Allocate a page in the disk map region and read the
	// contents of the block from the disk into that page.
	//注意扇区是从0开始的
	// LAB 5: Your code here
	if((r=sys_page_alloc(0,ROUNDDOWN(addr,BLKSIZE),PTE_USER))<0)
  800378:	89 d6                	mov    %edx,%esi
  80037a:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  800380:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  800387:	00 
  800388:	89 74 24 04          	mov    %esi,0x4(%esp)
  80038c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800393:	e8 a2 28 00 00       	call   802c3a <sys_page_alloc>
  800398:	85 c0                	test   %eax,%eax
  80039a:	79 20                	jns    8003bc <bc_pgfault+0x8e>
		panic("alloc page failed:%e\n",r);
  80039c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a0:	c7 44 24 08 38 41 80 	movl   $0x804138,0x8(%esp)
  8003a7:	00 
  8003a8:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  8003af:	00 
  8003b0:	c7 04 24 30 41 80 00 	movl   $0x804130,(%esp)
  8003b7:	e8 10 1a 00 00       	call   801dcc <_panic>
// Hint: Use ide_read and BLKSECTS.
static void
bc_pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  8003bc:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  8003c2:	89 c3                	mov    %eax,%ebx
  8003c4:	c1 eb 0c             	shr    $0xc,%ebx
	//注意扇区是从0开始的
	// LAB 5: Your code here
	if((r=sys_page_alloc(0,ROUNDDOWN(addr,BLKSIZE),PTE_USER))<0)
		panic("alloc page failed:%e\n",r);
	//cprintf("sector=%d\n",blockno*BLKSECTS+1);
	ide_read(blockno*BLKSECTS,ROUNDDOWN(addr,BLKSIZE),BLKSECTS);
  8003c7:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  8003ce:	00 
  8003cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003d3:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
  8003da:	89 04 24             	mov    %eax,(%esp)
  8003dd:	e8 27 fd ff ff       	call   800109 <ide_read>
	//if(super)
	//	cprintf("fault:nblocks=%d\n",super->s_nblocks);
	// Sanity check the block number. (exercise for the reader:
	// why do we do this *after* reading the block in?)
	if (super && blockno >= super->s_nblocks)
  8003e2:	a1 a4 c0 80 00       	mov    0x80c0a4,%eax
  8003e7:	85 c0                	test   %eax,%eax
  8003e9:	74 25                	je     800410 <bc_pgfault+0xe2>
  8003eb:	3b 58 04             	cmp    0x4(%eax),%ebx
  8003ee:	72 20                	jb     800410 <bc_pgfault+0xe2>
		panic("reading non-existent block %08x\n", blockno);
  8003f0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003f4:	c7 44 24 08 e8 40 80 	movl   $0x8040e8,0x8(%esp)
  8003fb:	00 
  8003fc:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  800403:	00 
  800404:	c7 04 24 30 41 80 00 	movl   $0x804130,(%esp)
  80040b:	e8 bc 19 00 00       	call   801dcc <_panic>

	// Check that the block we read was allocated.
	if (bitmap && block_is_free(blockno))
  800410:	83 3d a0 c0 80 00 00 	cmpl   $0x0,0x80c0a0
  800417:	74 2c                	je     800445 <bc_pgfault+0x117>
  800419:	89 1c 24             	mov    %ebx,(%esp)
  80041c:	e8 cf 02 00 00       	call   8006f0 <block_is_free>
  800421:	85 c0                	test   %eax,%eax
  800423:	74 20                	je     800445 <bc_pgfault+0x117>
		panic("reading free block %08x\n", blockno);
  800425:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800429:	c7 44 24 08 4e 41 80 	movl   $0x80414e,0x8(%esp)
  800430:	00 
  800431:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  800438:	00 
  800439:	c7 04 24 30 41 80 00 	movl   $0x804130,(%esp)
  800440:	e8 87 19 00 00       	call   801dcc <_panic>
}
  800445:	83 c4 20             	add    $0x20,%esp
  800448:	5b                   	pop    %ebx
  800449:	5e                   	pop    %esi
  80044a:	5d                   	pop    %ebp
  80044b:	c3                   	ret    

0080044c <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_USER constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  80044c:	55                   	push   %ebp
  80044d:	89 e5                	mov    %esp,%ebp
  80044f:	83 ec 28             	sub    $0x28,%esp
  800452:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800455:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800458:	8b 75 08             	mov    0x8(%ebp),%esi
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80045b:	8d 86 00 00 00 f0    	lea    -0x10000000(%esi),%eax
  800461:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800466:	76 20                	jbe    800488 <flush_block+0x3c>
		panic("flush_block of bad va %08x", addr);
  800468:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80046c:	c7 44 24 08 67 41 80 	movl   $0x804167,0x8(%esp)
  800473:	00 
  800474:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  80047b:	00 
  80047c:	c7 04 24 30 41 80 00 	movl   $0x804130,(%esp)
  800483:	e8 44 19 00 00       	call   801dcc <_panic>

	// LAB 5: Your code here.
	int r;
	void *blkva;
	blkva=ROUNDDOWN(addr,BLKSIZE);
	if(va_is_mapped(addr)&&va_is_dirty(addr))
  800488:	89 34 24             	mov    %esi,(%esp)
  80048b:	e8 10 fe ff ff       	call   8002a0 <va_is_mapped>
  800490:	85 c0                	test   %eax,%eax
  800492:	74 7e                	je     800512 <flush_block+0xc6>
  800494:	89 34 24             	mov    %esi,(%esp)
  800497:	e8 34 fe ff ff       	call   8002d0 <va_is_dirty>
  80049c:	85 c0                	test   %eax,%eax
  80049e:	66 90                	xchg   %ax,%ax
  8004a0:	74 70                	je     800512 <flush_block+0xc6>
		panic("flush_block of bad va %08x", addr);

	// LAB 5: Your code here.
	int r;
	void *blkva;
	blkva=ROUNDDOWN(addr,BLKSIZE);
  8004a2:	89 f3                	mov    %esi,%ebx
  8004a4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if(va_is_mapped(addr)&&va_is_dirty(addr))
	{
		ide_write(blockno*BLKSECTS,blkva,BLKSECTS);
  8004aa:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  8004b1:	00 
  8004b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b6:	8d 86 00 00 00 f0    	lea    -0x10000000(%esi),%eax
  8004bc:	c1 e8 0c             	shr    $0xc,%eax
  8004bf:	c1 e0 03             	shl    $0x3,%eax
  8004c2:	89 04 24             	mov    %eax,(%esp)
  8004c5:	e8 08 fd ff ff       	call   8001d2 <ide_write>
		if((r=sys_page_map(0,blkva,0,blkva,PTE_USER))<0)
  8004ca:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  8004d1:	00 
  8004d2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004d6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004dd:	00 
  8004de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8004e9:	e8 ee 26 00 00       	call   802bdc <sys_page_map>
  8004ee:	85 c0                	test   %eax,%eax
  8004f0:	79 20                	jns    800512 <flush_block+0xc6>
			panic("page mapping failed:%e\n",r);
  8004f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f6:	c7 44 24 08 82 41 80 	movl   $0x804182,0x8(%esp)
  8004fd:	00 
  8004fe:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  800505:	00 
  800506:	c7 04 24 30 41 80 00 	movl   $0x804130,(%esp)
  80050d:	e8 ba 18 00 00       	call   801dcc <_panic>
		
	}
	//panic("flush_block not implemented");
}
  800512:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800515:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800518:	89 ec                	mov    %ebp,%esp
  80051a:	5d                   	pop    %ebp
  80051b:	c3                   	ret    

0080051c <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  80051c:	55                   	push   %ebp
  80051d:	89 e5                	mov    %esp,%ebp
  80051f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	set_pgfault_handler(bc_pgfault);
  800525:	c7 04 24 2e 03 80 00 	movl   $0x80032e,(%esp)
  80052c:	e8 2f 28 00 00       	call   802d60 <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  800531:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800538:	e8 ab fd ff ff       	call   8002e8 <diskaddr>
  80053d:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  800544:	00 
  800545:	89 44 24 04          	mov    %eax,0x4(%esp)
  800549:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80054f:	89 04 24             	mov    %eax,(%esp)
  800552:	e8 b1 21 00 00       	call   802708 <memmove>
	//cprintf("check bc:magic=%x nblocks=%x\n",backup.s_magic,backup.s_nblocks);
	// smash it 
	strcpy(diskaddr(1), "OOPS!\n");
  800557:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80055e:	e8 85 fd ff ff       	call   8002e8 <diskaddr>
  800563:	c7 44 24 04 9a 41 80 	movl   $0x80419a,0x4(%esp)
  80056a:	00 
  80056b:	89 04 24             	mov    %eax,(%esp)
  80056e:	e8 8e 1f 00 00       	call   802501 <strcpy>
	flush_block(diskaddr(1));
  800573:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80057a:	e8 69 fd ff ff       	call   8002e8 <diskaddr>
  80057f:	89 04 24             	mov    %eax,(%esp)
  800582:	e8 c5 fe ff ff       	call   80044c <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800587:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80058e:	e8 55 fd ff ff       	call   8002e8 <diskaddr>
  800593:	89 04 24             	mov    %eax,(%esp)
  800596:	e8 05 fd ff ff       	call   8002a0 <va_is_mapped>
  80059b:	85 c0                	test   %eax,%eax
  80059d:	75 24                	jne    8005c3 <bc_init+0xa7>
  80059f:	c7 44 24 0c bc 41 80 	movl   $0x8041bc,0xc(%esp)
  8005a6:	00 
  8005a7:	c7 44 24 08 7d 40 80 	movl   $0x80407d,0x8(%esp)
  8005ae:	00 
  8005af:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
  8005b6:	00 
  8005b7:	c7 04 24 30 41 80 00 	movl   $0x804130,(%esp)
  8005be:	e8 09 18 00 00       	call   801dcc <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  8005c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005ca:	e8 19 fd ff ff       	call   8002e8 <diskaddr>
  8005cf:	89 04 24             	mov    %eax,(%esp)
  8005d2:	e8 f9 fc ff ff       	call   8002d0 <va_is_dirty>
  8005d7:	85 c0                	test   %eax,%eax
  8005d9:	74 24                	je     8005ff <bc_init+0xe3>
  8005db:	c7 44 24 0c a1 41 80 	movl   $0x8041a1,0xc(%esp)
  8005e2:	00 
  8005e3:	c7 44 24 08 7d 40 80 	movl   $0x80407d,0x8(%esp)
  8005ea:	00 
  8005eb:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
  8005f2:	00 
  8005f3:	c7 04 24 30 41 80 00 	movl   $0x804130,(%esp)
  8005fa:	e8 cd 17 00 00       	call   801dcc <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  8005ff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800606:	e8 dd fc ff ff       	call   8002e8 <diskaddr>
  80060b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800616:	e8 63 25 00 00       	call   802b7e <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  80061b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800622:	e8 c1 fc ff ff       	call   8002e8 <diskaddr>
  800627:	89 04 24             	mov    %eax,(%esp)
  80062a:	e8 71 fc ff ff       	call   8002a0 <va_is_mapped>
  80062f:	85 c0                	test   %eax,%eax
  800631:	74 24                	je     800657 <bc_init+0x13b>
  800633:	c7 44 24 0c bb 41 80 	movl   $0x8041bb,0xc(%esp)
  80063a:	00 
  80063b:	c7 44 24 08 7d 40 80 	movl   $0x80407d,0x8(%esp)
  800642:	00 
  800643:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  80064a:	00 
  80064b:	c7 04 24 30 41 80 00 	movl   $0x804130,(%esp)
  800652:	e8 75 17 00 00       	call   801dcc <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  800657:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80065e:	e8 85 fc ff ff       	call   8002e8 <diskaddr>
  800663:	c7 44 24 04 9a 41 80 	movl   $0x80419a,0x4(%esp)
  80066a:	00 
  80066b:	89 04 24             	mov    %eax,(%esp)
  80066e:	e8 6e 1f 00 00       	call   8025e1 <strcmp>
  800673:	85 c0                	test   %eax,%eax
  800675:	74 24                	je     80069b <bc_init+0x17f>
  800677:	c7 44 24 0c 0c 41 80 	movl   $0x80410c,0xc(%esp)
  80067e:	00 
  80067f:	c7 44 24 08 7d 40 80 	movl   $0x80407d,0x8(%esp)
  800686:	00 
  800687:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  80068e:	00 
  80068f:	c7 04 24 30 41 80 00 	movl   $0x804130,(%esp)
  800696:	e8 31 17 00 00       	call   801dcc <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  80069b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006a2:	e8 41 fc ff ff       	call   8002e8 <diskaddr>
  8006a7:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  8006ae:	00 
  8006af:	8d 95 f8 fe ff ff    	lea    -0x108(%ebp),%edx
  8006b5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006b9:	89 04 24             	mov    %eax,(%esp)
  8006bc:	e8 47 20 00 00       	call   802708 <memmove>
	flush_block(diskaddr(1));
  8006c1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006c8:	e8 1b fc ff ff       	call   8002e8 <diskaddr>
  8006cd:	89 04 24             	mov    %eax,(%esp)
  8006d0:	e8 77 fd ff ff       	call   80044c <flush_block>

	cprintf("block cache is good\n");
  8006d5:	c7 04 24 d6 41 80 00 	movl   $0x8041d6,(%esp)
  8006dc:	e8 b8 17 00 00       	call   801e99 <cprintf>
void
bc_init(void)
{
	set_pgfault_handler(bc_pgfault);
	check_bc();
}
  8006e1:	c9                   	leave  
  8006e2:	c3                   	ret    
	...

008006f0 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	53                   	push   %ebx
  8006f4:	8b 55 08             	mov    0x8(%ebp),%edx
	if (super == 0 || blockno >= super->s_nblocks)
  8006f7:	a1 a4 c0 80 00       	mov    0x80c0a4,%eax
  8006fc:	85 c0                	test   %eax,%eax
  8006fe:	74 27                	je     800727 <block_is_free+0x37>
  800700:	39 50 04             	cmp    %edx,0x4(%eax)
  800703:	76 22                	jbe    800727 <block_is_free+0x37>
  800705:	89 d3                	mov    %edx,%ebx
  800707:	c1 eb 05             	shr    $0x5,%ebx
  80070a:	89 d1                	mov    %edx,%ecx
  80070c:	83 e1 1f             	and    $0x1f,%ecx
  80070f:	b8 01 00 00 00       	mov    $0x1,%eax
  800714:	d3 e0                	shl    %cl,%eax
  800716:	8b 15 a0 c0 80 00    	mov    0x80c0a0,%edx
  80071c:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  80071f:	0f 95 c0             	setne  %al
  800722:	0f b6 c0             	movzbl %al,%eax
  800725:	eb 05                	jmp    80072c <block_is_free+0x3c>
  800727:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  80072c:	5b                   	pop    %ebx
  80072d:	5d                   	pop    %ebp
  80072e:	c3                   	ret    

0080072f <skip_slash>:
}

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
	while (*p == '/')
  800732:	80 38 2f             	cmpb   $0x2f,(%eax)
  800735:	75 08                	jne    80073f <skip_slash+0x10>
		p++;
  800737:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  80073a:	80 38 2f             	cmpb   $0x2f,(%eax)
  80073d:	74 f8                	je     800737 <skip_slash+0x8>
		p++;
	return p;
}
  80073f:	5d                   	pop    %ebp
  800740:	c3                   	ret    

00800741 <fs_sync>:
}

// Sync the entire file system.  A big hammer.同步真个文件系统
void
fs_sync(void)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	53                   	push   %ebx
  800745:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  800748:	a1 a4 c0 80 00       	mov    0x80c0a4,%eax
  80074d:	83 78 04 01          	cmpl   $0x1,0x4(%eax)
  800751:	76 29                	jbe    80077c <fs_sync+0x3b>
  800753:	bb 01 00 00 00       	mov    $0x1,%ebx
  800758:	ba 01 00 00 00       	mov    $0x1,%edx
		flush_block(diskaddr(i));
  80075d:	89 14 24             	mov    %edx,(%esp)
  800760:	e8 83 fb ff ff       	call   8002e8 <diskaddr>
  800765:	89 04 24             	mov    %eax,(%esp)
  800768:	e8 df fc ff ff       	call   80044c <flush_block>
// Sync the entire file system.  A big hammer.同步真个文件系统
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  80076d:	83 c3 01             	add    $0x1,%ebx
  800770:	89 da                	mov    %ebx,%edx
  800772:	a1 a4 c0 80 00       	mov    0x80c0a4,%eax
  800777:	39 58 04             	cmp    %ebx,0x4(%eax)
  80077a:	77 e1                	ja     80075d <fs_sync+0x1c>
		flush_block(diskaddr(i));
}
  80077c:	83 c4 04             	add    $0x4,%esp
  80077f:	5b                   	pop    %ebx
  800780:	5d                   	pop    %ebp
  800781:	c3                   	ret    

00800782 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	56                   	push   %esi
  800786:	53                   	push   %ebx
  800787:	83 ec 10             	sub    $0x10,%esp
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	uint32_t blockno;
	for(blockno=1;blockno<super->s_nblocks;blockno++)
  80078a:	a1 a4 c0 80 00       	mov    0x80c0a4,%eax
  80078f:	8b 70 04             	mov    0x4(%eax),%esi
  800792:	83 fe 01             	cmp    $0x1,%esi
  800795:	76 4b                	jbe    8007e2 <alloc_block+0x60>
  800797:	bb 01 00 00 00       	mov    $0x1,%ebx
		if(block_is_free(blockno))
  80079c:	89 1c 24             	mov    %ebx,(%esp)
  80079f:	e8 4c ff ff ff       	call   8006f0 <block_is_free>
  8007a4:	85 c0                	test   %eax,%eax
  8007a6:	74 32                	je     8007da <alloc_block+0x58>
		{
			bitmap[blockno/32] &= ~(1<<(blockno%32));
  8007a8:	89 da                	mov    %ebx,%edx
  8007aa:	c1 ea 05             	shr    $0x5,%edx
  8007ad:	c1 e2 02             	shl    $0x2,%edx
  8007b0:	03 15 a0 c0 80 00    	add    0x80c0a0,%edx
  8007b6:	89 d9                	mov    %ebx,%ecx
  8007b8:	83 e1 1f             	and    $0x1f,%ecx
  8007bb:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  8007c0:	d3 c0                	rol    %cl,%eax
  8007c2:	21 02                	and    %eax,(%edx)
			flush_block(diskaddr(2));
  8007c4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8007cb:	e8 18 fb ff ff       	call   8002e8 <diskaddr>
  8007d0:	89 04 24             	mov    %eax,(%esp)
  8007d3:	e8 74 fc ff ff       	call   80044c <flush_block>
  8007d8:	eb 0d                	jmp    8007e7 <alloc_block+0x65>
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	uint32_t blockno;
	for(blockno=1;blockno<super->s_nblocks;blockno++)
  8007da:	83 c3 01             	add    $0x1,%ebx
  8007dd:	39 f3                	cmp    %esi,%ebx
  8007df:	90                   	nop    
  8007e0:	75 ba                	jne    80079c <alloc_block+0x1a>
  8007e2:	bb f7 ff ff ff       	mov    $0xfffffff7,%ebx
			flush_block(diskaddr(2));
			return blockno;
		}
	//panic("alloc_block not implemented");
	return -E_NO_DISK;
}
  8007e7:	89 d8                	mov    %ebx,%eax
  8007e9:	83 c4 10             	add    $0x10,%esp
  8007ec:	5b                   	pop    %ebx
  8007ed:	5e                   	pop    %esi
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <free_block>:
}

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	83 ec 18             	sub    $0x18,%esp
  8007f6:	8b 55 08             	mov    0x8(%ebp),%edx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  8007f9:	85 d2                	test   %edx,%edx
  8007fb:	75 1c                	jne    800819 <free_block+0x29>
		panic("attempt to free zero block");
  8007fd:	c7 44 24 08 eb 41 80 	movl   $0x8041eb,0x8(%esp)
  800804:	00 
  800805:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80080c:	00 
  80080d:	c7 04 24 06 42 80 00 	movl   $0x804206,(%esp)
  800814:	e8 b3 15 00 00       	call   801dcc <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800819:	89 d0                	mov    %edx,%eax
  80081b:	c1 e8 05             	shr    $0x5,%eax
  80081e:	c1 e0 02             	shl    $0x2,%eax
  800821:	03 05 a0 c0 80 00    	add    0x80c0a0,%eax
  800827:	89 d1                	mov    %edx,%ecx
  800829:	83 e1 1f             	and    $0x1f,%ecx
  80082c:	ba 01 00 00 00       	mov    $0x1,%edx
  800831:	d3 e2                	shl    %cl,%edx
  800833:	09 10                	or     %edx,(%eax)
}
  800835:	c9                   	leave  
  800836:	c3                   	ret    

00800837 <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	56                   	push   %esi
  80083b:	53                   	push   %ebx
  80083c:	83 ec 10             	sub    $0x10,%esp
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  80083f:	a1 a4 c0 80 00       	mov    0x80c0a4,%eax
  800844:	8b 70 04             	mov    0x4(%eax),%esi
  800847:	85 f6                	test   %esi,%esi
  800849:	74 44                	je     80088f <check_bitmap+0x58>
  80084b:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(!block_is_free(2+i));
  800850:	8d 43 02             	lea    0x2(%ebx),%eax
  800853:	89 04 24             	mov    %eax,(%esp)
  800856:	e8 95 fe ff ff       	call   8006f0 <block_is_free>
  80085b:	85 c0                	test   %eax,%eax
  80085d:	74 24                	je     800883 <check_bitmap+0x4c>
  80085f:	c7 44 24 0c 0e 42 80 	movl   $0x80420e,0xc(%esp)
  800866:	00 
  800867:	c7 44 24 08 7d 40 80 	movl   $0x80407d,0x8(%esp)
  80086e:	00 
  80086f:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  800876:	00 
  800877:	c7 04 24 06 42 80 00 	movl   $0x804206,(%esp)
  80087e:	e8 49 15 00 00       	call   801dcc <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800883:	83 c3 01             	add    $0x1,%ebx
  800886:	89 d8                	mov    %ebx,%eax
  800888:	c1 e0 0f             	shl    $0xf,%eax
  80088b:	39 c6                	cmp    %eax,%esi
  80088d:	77 c1                	ja     800850 <check_bitmap+0x19>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  80088f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800896:	e8 55 fe ff ff       	call   8006f0 <block_is_free>
  80089b:	85 c0                	test   %eax,%eax
  80089d:	74 24                	je     8008c3 <check_bitmap+0x8c>
  80089f:	c7 44 24 0c 22 42 80 	movl   $0x804222,0xc(%esp)
  8008a6:	00 
  8008a7:	c7 44 24 08 7d 40 80 	movl   $0x80407d,0x8(%esp)
  8008ae:	00 
  8008af:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  8008b6:	00 
  8008b7:	c7 04 24 06 42 80 00 	movl   $0x804206,(%esp)
  8008be:	e8 09 15 00 00       	call   801dcc <_panic>
	assert(!block_is_free(1));
  8008c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8008ca:	e8 21 fe ff ff       	call   8006f0 <block_is_free>
  8008cf:	85 c0                	test   %eax,%eax
  8008d1:	74 24                	je     8008f7 <check_bitmap+0xc0>
  8008d3:	c7 44 24 0c 34 42 80 	movl   $0x804234,0xc(%esp)
  8008da:	00 
  8008db:	c7 44 24 08 7d 40 80 	movl   $0x80407d,0x8(%esp)
  8008e2:	00 
  8008e3:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  8008ea:	00 
  8008eb:	c7 04 24 06 42 80 00 	movl   $0x804206,(%esp)
  8008f2:	e8 d5 14 00 00       	call   801dcc <_panic>

	cprintf("bitmap is good\n");
  8008f7:	c7 04 24 46 42 80 00 	movl   $0x804246,(%esp)
  8008fe:	e8 96 15 00 00       	call   801e99 <cprintf>
}
  800903:	83 c4 10             	add    $0x10,%esp
  800906:	5b                   	pop    %ebx
  800907:	5e                   	pop    %esi
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	83 ec 18             	sub    $0x18,%esp
	if (super->s_magic != FS_MAGIC)
  800910:	a1 a4 c0 80 00       	mov    0x80c0a4,%eax
  800915:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  80091b:	74 1c                	je     800939 <check_super+0x2f>
		panic("bad file system magic number");
  80091d:	c7 44 24 08 56 42 80 	movl   $0x804256,0x8(%esp)
  800924:	00 
  800925:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80092c:	00 
  80092d:	c7 04 24 06 42 80 00 	movl   $0x804206,(%esp)
  800934:	e8 93 14 00 00       	call   801dcc <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  800939:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  800940:	76 1c                	jbe    80095e <check_super+0x54>
		panic("file system is too large");
  800942:	c7 44 24 08 73 42 80 	movl   $0x804273,0x8(%esp)
  800949:	00 
  80094a:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800951:	00 
  800952:	c7 04 24 06 42 80 00 	movl   $0x804206,(%esp)
  800959:	e8 6e 14 00 00       	call   801dcc <_panic>

	cprintf("superblock is good\n");
  80095e:	c7 04 24 8c 42 80 00 	movl   $0x80428c,(%esp)
  800965:	e8 2f 15 00 00       	call   801e99 <cprintf>
}
  80096a:	c9                   	leave  
  80096b:	c3                   	ret    

0080096c <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.  
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	83 ec 18             	sub    $0x18,%esp
  800972:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800975:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800978:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80097b:	89 c6                	mov    %eax,%esi
  80097d:	89 d3                	mov    %edx,%ebx
  80097f:	89 cf                	mov    %ecx,%edi
	// LAB 5: Your code here.
	int blkno;
	if(filebno<NDIRECT)
  800981:	83 fa 09             	cmp    $0x9,%edx
  800984:	77 10                	ja     800996 <file_block_walk+0x2a>
	{	
		//cprintf("walk:filebno=%d file block num=%d\n",filebno,f->f_direct[filebno]);
		*ppdiskbno=&f->f_direct[filebno];
  800986:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
  80098d:	89 01                	mov    %eax,(%ecx)
  80098f:	ba 00 00 00 00       	mov    $0x0,%edx
  800994:	eb 78                	jmp    800a0e <file_block_walk+0xa2>
	}
	else if((filebno<NDIRECT+NINDIRECT)&&(filebno>=NDIRECT))
  800996:	8d 42 f6             	lea    -0xa(%edx),%eax
  800999:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80099e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8009a3:	77 69                	ja     800a0e <file_block_walk+0xa2>
	{
		if(!f->f_indirect)
  8009a5:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  8009ab:	85 c0                	test   %eax,%eax
  8009ad:	75 4c                	jne    8009fb <file_block_walk+0x8f>
		{
			if(!alloc)
  8009af:	ba f5 ff ff ff       	mov    $0xfffffff5,%edx
  8009b4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8009b8:	74 54                	je     800a0e <file_block_walk+0xa2>
				return -E_NOT_FOUND;
			if((blkno=alloc_block())<0)
  8009ba:	e8 c3 fd ff ff       	call   800782 <alloc_block>
  8009bf:	ba f7 ff ff ff       	mov    $0xfffffff7,%edx
  8009c4:	85 c0                	test   %eax,%eax
  8009c6:	78 46                	js     800a0e <file_block_walk+0xa2>
				return -E_NO_DISK;
			//cprintf("walk:blkno=%d\n",blkno);
			f->f_indirect=blkno;
  8009c8:	89 86 b0 00 00 00    	mov    %eax,0xb0(%esi)
			memset(diskaddr(blkno),0,BLKSIZE);
  8009ce:	89 04 24             	mov    %eax,(%esp)
  8009d1:	e8 12 f9 ff ff       	call   8002e8 <diskaddr>
  8009d6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8009dd:	00 
  8009de:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009e5:	00 
  8009e6:	89 04 24             	mov    %eax,(%esp)
  8009e9:	e8 c0 1c 00 00       	call   8026ae <memset>
			*ppdiskbno=NULL;
  8009ee:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8009f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f9:	eb 13                	jmp    800a0e <file_block_walk+0xa2>
		}
		else{
			*ppdiskbno=(uint32_t *)diskaddr(f->f_indirect)+filebno-10;
  8009fb:	89 04 24             	mov    %eax,(%esp)
  8009fe:	e8 e5 f8 ff ff       	call   8002e8 <diskaddr>
  800a03:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  800a07:	89 07                	mov    %eax,(%edi)
  800a09:	ba 00 00 00 00       	mov    $0x0,%edx
	else
		return -E_INVAL;
	//cprintf("file walk:ppdiskbno=%x\n",*ppdiskbno);
	return 0;
	//panic("file_block_walk not implemented");
}
  800a0e:	89 d0                	mov    %edx,%eax
  800a10:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a13:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a16:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a19:	89 ec                	mov    %ebp,%esp
  800a1b:	5d                   	pop    %ebp
  800a1c:	c3                   	ret    

00800a1d <file_flush>:
// Loop over all the blocks in file.循环遍历文件中所有的块
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	57                   	push   %edi
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
  800a23:	83 ec 1c             	sub    $0x1c,%esp
  800a26:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;
	//遍历文件中所有的块，并进行块刷新
	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800a29:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  800a2f:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800a35:	89 d0                	mov    %edx,%eax
  800a37:	c1 f8 1f             	sar    $0x1f,%eax
  800a3a:	c1 e8 14             	shr    $0x14,%eax
  800a3d:	01 d0                	add    %edx,%eax
  800a3f:	c1 f8 0c             	sar    $0xc,%eax
  800a42:	85 c0                	test   %eax,%eax
  800a44:	7e 5b                	jle    800aa1 <file_flush+0x84>
  800a46:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800a4b:	8d 7d f0             	lea    -0x10(%ebp),%edi
  800a4e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a55:	89 f9                	mov    %edi,%ecx
  800a57:	89 da                	mov    %ebx,%edx
  800a59:	89 f0                	mov    %esi,%eax
  800a5b:	e8 0c ff ff ff       	call   80096c <file_block_walk>
  800a60:	85 c0                	test   %eax,%eax
  800a62:	78 1d                	js     800a81 <file_flush+0x64>
  800a64:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a67:	85 c0                	test   %eax,%eax
  800a69:	74 16                	je     800a81 <file_flush+0x64>
  800a6b:	8b 00                	mov    (%eax),%eax
  800a6d:	85 c0                	test   %eax,%eax
  800a6f:	74 10                	je     800a81 <file_flush+0x64>
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
  800a71:	89 04 24             	mov    %eax,(%esp)
  800a74:	e8 6f f8 ff ff       	call   8002e8 <diskaddr>
  800a79:	89 04 24             	mov    %eax,(%esp)
  800a7c:	e8 cb f9 ff ff       	call   80044c <flush_block>
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;
	//遍历文件中所有的块，并进行块刷新
	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800a81:	83 c3 01             	add    $0x1,%ebx
  800a84:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  800a8a:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800a90:	89 d0                	mov    %edx,%eax
  800a92:	c1 f8 1f             	sar    $0x1f,%eax
  800a95:	c1 e8 14             	shr    $0x14,%eax
  800a98:	01 d0                	add    %edx,%eax
  800a9a:	c1 f8 0c             	sar    $0xc,%eax
  800a9d:	39 d8                	cmp    %ebx,%eax
  800a9f:	7f ad                	jg     800a4e <file_flush+0x31>
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	//刷新文件结构体所在块
	flush_block(f);
  800aa1:	89 34 24             	mov    %esi,(%esp)
  800aa4:	e8 a3 f9 ff ff       	call   80044c <flush_block>
	//刷新文件中的用于记录间接块号的块
	if (f->f_indirect)
  800aa9:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800aaf:	85 c0                	test   %eax,%eax
  800ab1:	74 10                	je     800ac3 <file_flush+0xa6>
		flush_block(diskaddr(f->f_indirect));
  800ab3:	89 04 24             	mov    %eax,(%esp)
  800ab6:	e8 2d f8 ff ff       	call   8002e8 <diskaddr>
  800abb:	89 04 24             	mov    %eax,(%esp)
  800abe:	e8 89 f9 ff ff       	call   80044c <flush_block>
}
  800ac3:	83 c4 1c             	add    $0x1c,%esp
  800ac6:	5b                   	pop    %ebx
  800ac7:	5e                   	pop    %esi
  800ac8:	5f                   	pop    %edi
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <file_truncate_blocks>:
// (Remember to clear the f->f_indirect pointer so you'll know
// whether it's valid!)
// Do not change f->f_size.
static void
file_truncate_blocks(struct File *f, off_t newsize)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	57                   	push   %edi
  800acf:	56                   	push   %esi
  800ad0:	53                   	push   %ebx
  800ad1:	83 ec 1c             	sub    $0x1c,%esp
  800ad4:	89 c6                	mov    %eax,%esi
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800ad6:	8b 88 80 00 00 00    	mov    0x80(%eax),%ecx
  800adc:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
  800ae2:	89 c8                	mov    %ecx,%eax
  800ae4:	c1 f8 1f             	sar    $0x1f,%eax
  800ae7:	c1 e8 14             	shr    $0x14,%eax
  800aea:	01 c8                	add    %ecx,%eax
  800aec:	89 c7                	mov    %eax,%edi
  800aee:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800af1:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800af7:	89 d0                	mov    %edx,%eax
  800af9:	c1 f8 1f             	sar    $0x1f,%eax
  800afc:	c1 e8 14             	shr    $0x14,%eax
  800aff:	01 d0                	add    %edx,%eax
  800b01:	c1 f8 0c             	sar    $0xc,%eax
  800b04:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800b07:	39 c7                	cmp    %eax,%edi
  800b09:	76 4c                	jbe    800b57 <file_truncate_blocks+0x8c>
  800b0b:	89 c3                	mov    %eax,%ebx
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800b0d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b14:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  800b17:	89 da                	mov    %ebx,%edx
  800b19:	89 f0                	mov    %esi,%eax
  800b1b:	e8 4c fe ff ff       	call   80096c <file_block_walk>
  800b20:	85 c0                	test   %eax,%eax
  800b22:	78 1c                	js     800b40 <file_truncate_blocks+0x75>
		return r;
	if (*ptr) {
  800b24:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b27:	8b 00                	mov    (%eax),%eax
  800b29:	85 c0                	test   %eax,%eax
  800b2b:	74 23                	je     800b50 <file_truncate_blocks+0x85>
		free_block(*ptr);
  800b2d:	89 04 24             	mov    %eax,(%esp)
  800b30:	e8 bb fc ff ff       	call   8007f0 <free_block>
		*ptr = 0;
  800b35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b38:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800b3e:	eb 10                	jmp    800b50 <file_truncate_blocks+0x85>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800b40:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b44:	c7 04 24 a0 42 80 00 	movl   $0x8042a0,(%esp)
  800b4b:	e8 49 13 00 00       	call   801e99 <cprintf>
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800b50:	83 c3 01             	add    $0x1,%ebx
  800b53:	39 df                	cmp    %ebx,%edi
  800b55:	75 b6                	jne    800b0d <file_truncate_blocks+0x42>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800b57:	83 7d e0 0a          	cmpl   $0xa,-0x20(%ebp)
  800b5b:	77 1c                	ja     800b79 <file_truncate_blocks+0xae>
  800b5d:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800b63:	85 c0                	test   %eax,%eax
  800b65:	74 12                	je     800b79 <file_truncate_blocks+0xae>
		free_block(f->f_indirect);
  800b67:	89 04 24             	mov    %eax,(%esp)
  800b6a:	e8 81 fc ff ff       	call   8007f0 <free_block>
		f->f_indirect = 0;
  800b6f:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800b76:	00 00 00 
	}
}
  800b79:	83 c4 1c             	add    $0x1c,%esp
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <file_set_size>:

// Set the size of file f, truncating or extending as necessary.
// 设置文件f的大小
int
file_set_size(struct File *f, off_t newsize)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	83 ec 18             	sub    $0x18,%esp
  800b87:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800b8a:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800b8d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b90:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (f->f_size > newsize)
  800b93:	39 b3 80 00 00 00    	cmp    %esi,0x80(%ebx)
  800b99:	7e 09                	jle    800ba4 <file_set_size+0x23>
		file_truncate_blocks(f, newsize);
  800b9b:	89 f2                	mov    %esi,%edx
  800b9d:	89 d8                	mov    %ebx,%eax
  800b9f:	e8 27 ff ff ff       	call   800acb <file_truncate_blocks>
	f->f_size = newsize;
  800ba4:	89 b3 80 00 00 00    	mov    %esi,0x80(%ebx)
	flush_block(f);
  800baa:	89 1c 24             	mov    %ebx,(%esp)
  800bad:	e8 9a f8 ff ff       	call   80044c <flush_block>
	return 0;
}
  800bb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800bba:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800bbd:	89 ec                	mov    %ebp,%esp
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
  800bc6:	83 ec 20             	sub    $0x20,%esp
  800bc9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 5: Your code here.
	int r;
	uint32_t *pdiskbno;
	if(filebno<NDIRECT+NINDIRECT&&filebno>=0)
  800bcc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bd1:	81 fe 09 04 00 00    	cmp    $0x409,%esi
  800bd7:	0f 87 b5 00 00 00    	ja     800c92 <file_get_block+0xd1>
	{
		if((r=file_block_walk(f,filebno,&pdiskbno,1))<0)
  800bdd:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800be0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800be7:	89 f2                	mov    %esi,%edx
  800be9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bec:	e8 7b fd ff ff       	call   80096c <file_block_walk>
  800bf1:	85 c0                	test   %eax,%eax
  800bf3:	0f 88 99 00 00 00    	js     800c92 <file_get_block+0xd1>
			return r;
		//cprintf("get block:pdiskbno=%x\n",*pdiskbno);
		if(pdiskbno&&*pdiskbno)
  800bf9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bfc:	85 db                	test   %ebx,%ebx
  800bfe:	74 1a                	je     800c1a <file_get_block+0x59>
  800c00:	8b 03                	mov    (%ebx),%eax
  800c02:	85 c0                	test   %eax,%eax
  800c04:	74 14                	je     800c1a <file_get_block+0x59>
		{
			*blk=(char *)diskaddr(*pdiskbno);
  800c06:	89 04 24             	mov    %eax,(%esp)
  800c09:	e8 da f6 ff ff       	call   8002e8 <diskaddr>
  800c0e:	8b 55 10             	mov    0x10(%ebp),%edx
  800c11:	89 02                	mov    %eax,(%edx)
  800c13:	b8 00 00 00 00       	mov    $0x0,%eax
  800c18:	eb 78                	jmp    800c92 <file_get_block+0xd1>
		}
		else{
			if((*pdiskbno=(uint32_t)alloc_block())<0)
  800c1a:	e8 63 fb ff ff       	call   800782 <alloc_block>
  800c1f:	89 03                	mov    %eax,(%ebx)
				return -E_NO_DISK;
			memset(diskaddr(*pdiskbno),0,BLKSIZE);
  800c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c24:	8b 00                	mov    (%eax),%eax
  800c26:	89 04 24             	mov    %eax,(%esp)
  800c29:	e8 ba f6 ff ff       	call   8002e8 <diskaddr>
  800c2e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800c35:	00 
  800c36:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c3d:	00 
  800c3e:	89 04 24             	mov    %eax,(%esp)
  800c41:	e8 68 1a 00 00       	call   8026ae <memset>
			*blk=(char *)diskaddr(*pdiskbno);
  800c46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c49:	8b 00                	mov    (%eax),%eax
  800c4b:	89 04 24             	mov    %eax,(%esp)
  800c4e:	e8 95 f6 ff ff       	call   8002e8 <diskaddr>
  800c53:	8b 55 10             	mov    0x10(%ebp),%edx
  800c56:	89 02                	mov    %eax,(%edx)
			if(filebno<NDIRECT)
  800c58:	83 fe 09             	cmp    $0x9,%esi
  800c5b:	77 16                	ja     800c73 <file_get_block+0xb2>
				f->f_direct[filebno]=*pdiskbno;
  800c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c60:	8b 00                	mov    (%eax),%eax
  800c62:	8b 55 08             	mov    0x8(%ebp),%edx
  800c65:	89 84 b2 88 00 00 00 	mov    %eax,0x88(%edx,%esi,4)
  800c6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c71:	eb 1f                	jmp    800c92 <file_get_block+0xd1>
			else
				*((uint32_t *)diskaddr(f->f_indirect)+filebno-10)=*pdiskbno;
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
  800c76:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  800c7c:	89 04 24             	mov    %eax,(%esp)
  800c7f:	e8 64 f6 ff ff       	call   8002e8 <diskaddr>
  800c84:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c87:	8b 12                	mov    (%edx),%edx
  800c89:	89 54 b0 d8          	mov    %edx,-0x28(%eax,%esi,4)
  800c8d:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	else
		return -E_INVAL;
	return 0;
	//panic("file_get_block not implemented");
}
  800c92:	83 c4 20             	add    $0x20,%esp
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
  800c9f:	83 ec 2c             	sub    $0x2c,%esp
  800ca2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800ca5:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  800ca8:	89 d8                	mov    %ebx,%eax
  800caa:	03 45 10             	add    0x10(%ebp),%eax
  800cad:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800cb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb3:	3b 82 80 00 00 00    	cmp    0x80(%edx),%eax
  800cb9:	76 14                	jbe    800ccf <file_write+0x36>
		if ((r = file_set_size(f, offset + count)) < 0)
  800cbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cbf:	89 14 24             	mov    %edx,(%esp)
  800cc2:	e8 ba fe ff ff       	call   800b81 <file_set_size>
  800cc7:	85 c0                	test   %eax,%eax
  800cc9:	0f 88 80 00 00 00    	js     800d4f <file_write+0xb6>
			return r;

	for (pos = offset; pos < offset + count; ) {
  800ccf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800cd2:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  800cd5:	73 75                	jae    800d4c <file_write+0xb3>
  800cd7:	89 de                	mov    %ebx,%esi
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800cd9:	8d 55 f0             	lea    -0x10(%ebp),%edx
  800cdc:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ce0:	89 f0                	mov    %esi,%eax
  800ce2:	c1 f8 1f             	sar    $0x1f,%eax
  800ce5:	89 c7                	mov    %eax,%edi
  800ce7:	c1 ef 14             	shr    $0x14,%edi
  800cea:	8d 1c 37             	lea    (%edi,%esi,1),%ebx
  800ced:	89 d8                	mov    %ebx,%eax
  800cef:	c1 f8 0c             	sar    $0xc,%eax
  800cf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cf6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf9:	89 04 24             	mov    %eax,(%esp)
  800cfc:	e8 c0 fe ff ff       	call   800bc1 <file_get_block>
  800d01:	85 c0                	test   %eax,%eax
  800d03:	78 4a                	js     800d4f <file_write+0xb6>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800d05:	89 d8                	mov    %ebx,%eax
  800d07:	25 ff 0f 00 00       	and    $0xfff,%eax
  800d0c:	89 c2                	mov    %eax,%edx
  800d0e:	29 fa                	sub    %edi,%edx
  800d10:	b8 00 10 00 00       	mov    $0x1000,%eax
  800d15:	89 c3                	mov    %eax,%ebx
  800d17:	29 d3                	sub    %edx,%ebx
  800d19:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800d1c:	2b 45 e0             	sub    -0x20(%ebp),%eax
  800d1f:	39 c3                	cmp    %eax,%ebx
  800d21:	76 02                	jbe    800d25 <file_write+0x8c>
  800d23:	89 c3                	mov    %eax,%ebx
		memmove(blk + pos % BLKSIZE, buf, bn);
  800d25:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d30:	89 d0                	mov    %edx,%eax
  800d32:	03 45 f0             	add    -0x10(%ebp),%eax
  800d35:	89 04 24             	mov    %eax,(%esp)
  800d38:	e8 cb 19 00 00       	call   802708 <memmove>
		pos += bn;
  800d3d:	01 de                	add    %ebx,%esi
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800d3f:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800d42:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  800d45:	76 05                	jbe    800d4c <file_write+0xb3>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
  800d47:	01 5d 0c             	add    %ebx,0xc(%ebp)
  800d4a:	eb 8d                	jmp    800cd9 <file_write+0x40>
	}

	return count;
  800d4c:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800d4f:	83 c4 2c             	add    $0x2c,%esp
  800d52:	5b                   	pop    %ebx
  800d53:	5e                   	pop    %esi
  800d54:	5f                   	pop    %edi
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    

00800d57 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	57                   	push   %edi
  800d5b:	56                   	push   %esi
  800d5c:	53                   	push   %ebx
  800d5d:	83 ec 2c             	sub    $0x2c,%esp
  800d60:	8b 4d 14             	mov    0x14(%ebp),%ecx
	int r, bn;
	off_t pos;
	char *blk;
	//偏移量不超过文件f的size
	if (offset >= f->f_size)
  800d63:	8b 45 08             	mov    0x8(%ebp),%eax
  800d66:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
  800d6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d71:	39 ca                	cmp    %ecx,%edx
  800d73:	0f 8e 98 00 00 00    	jle    800e11 <file_read+0xba>
		return 0;
	//根据偏移来计算，需要真正读取文件的字节数count
	count = MIN(count, f->f_size - offset);
  800d79:	29 ca                	sub    %ecx,%edx
  800d7b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800d7e:	8b 45 10             	mov    0x10(%ebp),%eax
  800d81:	39 c2                	cmp    %eax,%edx
  800d83:	76 03                	jbe    800d88 <file_read+0x31>
  800d85:	89 45 e0             	mov    %eax,-0x20(%ebp)
	//
	for (pos = offset; pos < offset + count; ) {
  800d88:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800d8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d8e:	01 c8                	add    %ecx,%eax
  800d90:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d93:	39 c1                	cmp    %eax,%ecx
  800d95:	73 77                	jae    800e0e <file_read+0xb7>
  800d97:	89 ce                	mov    %ecx,%esi
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800d99:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d9c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800da0:	89 f0                	mov    %esi,%eax
  800da2:	c1 f8 1f             	sar    $0x1f,%eax
  800da5:	89 c7                	mov    %eax,%edi
  800da7:	c1 ef 14             	shr    $0x14,%edi
  800daa:	8d 1c 37             	lea    (%edi,%esi,1),%ebx
  800dad:	89 d8                	mov    %ebx,%eax
  800daf:	c1 f8 0c             	sar    $0xc,%eax
  800db2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800db6:	8b 45 08             	mov    0x8(%ebp),%eax
  800db9:	89 04 24             	mov    %eax,(%esp)
  800dbc:	e8 00 fe ff ff       	call   800bc1 <file_get_block>
  800dc1:	85 c0                	test   %eax,%eax
  800dc3:	78 4c                	js     800e11 <file_read+0xba>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800dc5:	89 d8                	mov    %ebx,%eax
  800dc7:	25 ff 0f 00 00       	and    $0xfff,%eax
  800dcc:	89 c2                	mov    %eax,%edx
  800dce:	29 fa                	sub    %edi,%edx
  800dd0:	b8 00 10 00 00       	mov    $0x1000,%eax
  800dd5:	89 c3                	mov    %eax,%ebx
  800dd7:	29 d3                	sub    %edx,%ebx
  800dd9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ddc:	2b 45 dc             	sub    -0x24(%ebp),%eax
  800ddf:	39 c3                	cmp    %eax,%ebx
  800de1:	76 02                	jbe    800de5 <file_read+0x8e>
  800de3:	89 c3                	mov    %eax,%ebx
		memmove(buf, blk + pos % BLKSIZE, bn);
  800de5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800de9:	89 d0                	mov    %edx,%eax
  800deb:	03 45 f0             	add    -0x10(%ebp),%eax
  800dee:	89 44 24 04          	mov    %eax,0x4(%esp)
  800df2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df5:	89 04 24             	mov    %eax,(%esp)
  800df8:	e8 0b 19 00 00       	call   802708 <memmove>
		pos += bn;
  800dfd:	01 de                	add    %ebx,%esi
	if (offset >= f->f_size)
		return 0;
	//根据偏移来计算，需要真正读取文件的字节数count
	count = MIN(count, f->f_size - offset);
	//
	for (pos = offset; pos < offset + count; ) {
  800dff:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800e02:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800e05:	39 c6                	cmp    %eax,%esi
  800e07:	73 05                	jae    800e0e <file_read+0xb7>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
  800e09:	01 5d 0c             	add    %ebx,0xc(%ebp)
  800e0c:	eb 8b                	jmp    800d99 <file_read+0x42>
	}

	return count;
  800e0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  800e11:	83 c4 2c             	add    $0x2c,%esp
  800e14:	5b                   	pop    %ebx
  800e15:	5e                   	pop    %esi
  800e16:	5f                   	pop    %edi
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	57                   	push   %edi
  800e1d:	56                   	push   %esi
  800e1e:	53                   	push   %ebx
  800e1f:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  800e25:	89 95 50 ff ff ff    	mov    %edx,-0xb0(%ebp)
  800e2b:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	struct File *dir, *f;
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
  800e31:	e8 f9 f8 ff ff       	call   80072f <skip_slash>
  800e36:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
	f = &super->s_root;
  800e3c:	a1 a4 c0 80 00       	mov    0x80c0a4,%eax
  800e41:	83 c0 08             	add    $0x8,%eax
  800e44:	89 85 5c ff ff ff    	mov    %eax,-0xa4(%ebp)
	dir = 0;
	name[0] = 0;
  800e4a:	c6 85 74 ff ff ff 00 	movb   $0x0,-0x8c(%ebp)

	if (pdir)
  800e51:	83 bd 50 ff ff ff 00 	cmpl   $0x0,-0xb0(%ebp)
  800e58:	74 0c                	je     800e66 <walk_path+0x4d>
		*pdir = 0;
  800e5a:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  800e60:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	*pf = 0;
  800e66:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800e6c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (*path != '\0') {
  800e72:	8b b5 5c ff ff ff    	mov    -0xa4(%ebp),%esi
  800e78:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7d:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  800e83:	80 3a 00             	cmpb   $0x0,(%edx)
  800e86:	0f 84 c2 01 00 00    	je     80104e <walk_path+0x235>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800e8c:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  800e92:	0f b6 02             	movzbl (%edx),%eax
  800e95:	3c 2f                	cmp    $0x2f,%al
  800e97:	74 06                	je     800e9f <walk_path+0x86>
  800e99:	89 d3                	mov    %edx,%ebx
  800e9b:	84 c0                	test   %al,%al
  800e9d:	75 08                	jne    800ea7 <walk_path+0x8e>
  800e9f:	8b 9d 60 ff ff ff    	mov    -0xa0(%ebp),%ebx
  800ea5:	eb 0e                	jmp    800eb5 <walk_path+0x9c>
			path++;
  800ea7:	83 c3 01             	add    $0x1,%ebx
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800eaa:	0f b6 03             	movzbl (%ebx),%eax
  800ead:	3c 2f                	cmp    $0x2f,%al
  800eaf:	74 04                	je     800eb5 <walk_path+0x9c>
  800eb1:	84 c0                	test   %al,%al
  800eb3:	75 f2                	jne    800ea7 <walk_path+0x8e>
			path++;
		if (path - p >= MAXNAMELEN)
  800eb5:	89 de                	mov    %ebx,%esi
  800eb7:	2b b5 60 ff ff ff    	sub    -0xa0(%ebp),%esi
  800ebd:	83 fe 7f             	cmp    $0x7f,%esi
  800ec0:	7e 0a                	jle    800ecc <walk_path+0xb3>
  800ec2:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800ec7:	e9 a7 01 00 00       	jmp    801073 <walk_path+0x25a>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800ecc:	89 74 24 08          	mov    %esi,0x8(%esp)
  800ed0:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  800ed6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eda:	8d 95 74 ff ff ff    	lea    -0x8c(%ebp),%edx
  800ee0:	89 14 24             	mov    %edx,(%esp)
  800ee3:	e8 20 18 00 00       	call   802708 <memmove>
		name[path - p] = '\0';
  800ee8:	c6 84 35 74 ff ff ff 	movb   $0x0,-0x8c(%ebp,%esi,1)
  800eef:	00 
		path = skip_slash(path);
  800ef0:	89 d8                	mov    %ebx,%eax
  800ef2:	e8 38 f8 ff ff       	call   80072f <skip_slash>
  800ef7:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)

		if (dir->f_type != FTYPE_DIR)
  800efd:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  800f03:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800f0a:	0f 85 5e 01 00 00    	jne    80106e <walk_path+0x255>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800f10:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
  800f16:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
  800f1c:	74 24                	je     800f42 <walk_path+0x129>
  800f1e:	c7 44 24 0c bd 42 80 	movl   $0x8042bd,0xc(%esp)
  800f25:	00 
  800f26:	c7 44 24 08 7d 40 80 	movl   $0x80407d,0x8(%esp)
  800f2d:	00 
  800f2e:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
  800f35:	00 
  800f36:	c7 04 24 06 42 80 00 	movl   $0x804206,(%esp)
  800f3d:	e8 8a 0e 00 00       	call   801dcc <_panic>
	nblock = dir->f_size / BLKSIZE;
  800f42:	89 d0                	mov    %edx,%eax
  800f44:	c1 f8 1f             	sar    $0x1f,%eax
  800f47:	c1 e8 14             	shr    $0x14,%eax
  800f4a:	01 d0                	add    %edx,%eax
  800f4c:	c1 f8 0c             	sar    $0xc,%eax
  800f4f:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  800f55:	85 c0                	test   %eax,%eax
  800f57:	0f 84 9b 00 00 00    	je     800ff8 <walk_path+0x1df>
  800f5d:	c7 85 58 ff ff ff 00 	movl   $0x0,-0xa8(%ebp)
  800f64:	00 00 00 
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800f67:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
  800f6d:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f71:	8b 85 58 ff ff ff    	mov    -0xa8(%ebp),%eax
  800f77:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f7b:	8b 95 5c ff ff ff    	mov    -0xa4(%ebp),%edx
  800f81:	89 14 24             	mov    %edx,(%esp)
  800f84:	e8 38 fc ff ff       	call   800bc1 <file_get_block>
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	78 66                	js     800ff3 <walk_path+0x1da>
			return r;
		f = (struct File*) blk;
  800f8d:	8b bd 70 ff ff ff    	mov    -0x90(%ebp),%edi
  800f93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f98:	8d 34 1f             	lea    (%edi,%ebx,1),%esi
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800f9b:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
  800fa1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fa5:	89 34 24             	mov    %esi,(%esp)
  800fa8:	e8 34 16 00 00       	call   8025e1 <strcmp>
  800fad:	85 c0                	test   %eax,%eax
  800faf:	75 1a                	jne    800fcb <walk_path+0x1b2>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800fb1:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  800fb7:	80 3a 00             	cmpb   $0x0,(%edx)
  800fba:	0f 84 88 00 00 00    	je     801048 <walk_path+0x22f>
  800fc0:	89 b5 5c ff ff ff    	mov    %esi,-0xa4(%ebp)
  800fc6:	e9 c1 fe ff ff       	jmp    800e8c <walk_path+0x73>
  800fcb:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800fd1:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  800fd7:	75 bf                	jne    800f98 <walk_path+0x17f>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800fd9:	83 85 58 ff ff ff 01 	addl   $0x1,-0xa8(%ebp)
  800fe0:	8b 85 58 ff ff ff    	mov    -0xa8(%ebp),%eax
  800fe6:	39 85 54 ff ff ff    	cmp    %eax,-0xac(%ebp)
  800fec:	74 0a                	je     800ff8 <walk_path+0x1df>
  800fee:	e9 74 ff ff ff       	jmp    800f67 <walk_path+0x14e>

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800ff3:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800ff6:	75 7b                	jne    801073 <walk_path+0x25a>
  800ff8:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  800ffe:	80 3a 00             	cmpb   $0x0,(%edx)
  801001:	75 6b                	jne    80106e <walk_path+0x255>
				if (pdir)
  801003:	83 bd 50 ff ff ff 00 	cmpl   $0x0,-0xb0(%ebp)
  80100a:	74 0e                	je     80101a <walk_path+0x201>
					*pdir = dir;
  80100c:	8b 95 5c ff ff ff    	mov    -0xa4(%ebp),%edx
  801012:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  801018:	89 10                	mov    %edx,(%eax)
				if (lastelem)
  80101a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80101e:	74 15                	je     801035 <walk_path+0x21c>
					strcpy(lastelem, name);
  801020:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
  801026:	89 44 24 04          	mov    %eax,0x4(%esp)
  80102a:	8b 45 08             	mov    0x8(%ebp),%eax
  80102d:	89 04 24             	mov    %eax,(%esp)
  801030:	e8 cc 14 00 00       	call   802501 <strcpy>
				*pf = 0;
  801035:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
  80103b:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
  801041:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  801046:	eb 2b                	jmp    801073 <walk_path+0x25a>
  801048:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
			}
			return r;
		}
	}

	if (pdir)
  80104e:	83 bd 50 ff ff ff 00 	cmpl   $0x0,-0xb0(%ebp)
  801055:	74 08                	je     80105f <walk_path+0x246>
		*pdir = dir;
  801057:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  80105d:	89 02                	mov    %eax,(%edx)
	*pf = f;
  80105f:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  801065:	89 30                	mov    %esi,(%eax)
  801067:	b8 00 00 00 00       	mov    $0x0,%eax
  80106c:	eb 05                	jmp    801073 <walk_path+0x25a>
	return 0;
  80106e:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
}
  801073:	81 c4 bc 00 00 00    	add    $0xbc,%esp
  801079:	5b                   	pop    %ebx
  80107a:	5e                   	pop    %esi
  80107b:	5f                   	pop    %edi
  80107c:	5d                   	pop    %ebp
  80107d:	c3                   	ret    

0080107e <file_remove>:
}

// Remove a file by truncating it and then zeroing the name.
int
file_remove(const char *path)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct File *f;

	if ((r = walk_path(path, 0, &f, 0)) < 0)
  801084:	8d 4d fc             	lea    -0x4(%ebp),%ecx
  801087:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80108e:	ba 00 00 00 00       	mov    $0x0,%edx
  801093:	8b 45 08             	mov    0x8(%ebp),%eax
  801096:	e8 7e fd ff ff       	call   800e19 <walk_path>
  80109b:	85 c0                	test   %eax,%eax
  80109d:	78 30                	js     8010cf <file_remove+0x51>
		return r;

	file_truncate_blocks(f, 0);
  80109f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8010a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a7:	e8 1f fa ff ff       	call   800acb <file_truncate_blocks>
	f->f_name[0] = '\0';
  8010ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8010af:	c6 00 00             	movb   $0x0,(%eax)
	f->f_size = 0;
  8010b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8010b5:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  8010bc:	00 00 00 
	flush_block(f);
  8010bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8010c2:	89 04 24             	mov    %eax,(%esp)
  8010c5:	e8 82 f3 ff ff       	call   80044c <flush_block>
  8010ca:	b8 00 00 00 00       	mov    $0x0,%eax

	return 0;
}
  8010cf:	c9                   	leave  
  8010d0:	c3                   	ret    

008010d1 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	83 ec 08             	sub    $0x8,%esp
	return walk_path(path, 0, pf, 0);
  8010d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8010e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e9:	e8 2b fd ff ff       	call   800e19 <walk_path>
}
  8010ee:	c9                   	leave  
  8010ef:	c3                   	ret    

008010f0 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	81 ec b8 00 00 00    	sub    $0xb8,%esp
  8010f9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010fc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010ff:	89 7d fc             	mov    %edi,-0x4(%ebp)
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  801102:	8d 8d 6c ff ff ff    	lea    -0x94(%ebp),%ecx
  801108:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
  80110e:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
  801114:	89 04 24             	mov    %eax,(%esp)
  801117:	8b 45 08             	mov    0x8(%ebp),%eax
  80111a:	e8 fa fc ff ff       	call   800e19 <walk_path>
  80111f:	89 c3                	mov    %eax,%ebx
  801121:	85 c0                	test   %eax,%eax
  801123:	0f 84 fd 00 00 00    	je     801226 <file_create+0x136>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  801129:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80112c:	0f 85 31 01 00 00    	jne    801263 <file_create+0x173>
  801132:	8b b5 70 ff ff ff    	mov    -0x90(%ebp),%esi
  801138:	85 f6                	test   %esi,%esi
  80113a:	0f 84 23 01 00 00    	je     801263 <file_create+0x173>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  801140:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  801146:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
  80114c:	74 24                	je     801172 <file_create+0x82>
  80114e:	c7 44 24 0c bd 42 80 	movl   $0x8042bd,0xc(%esp)
  801155:	00 
  801156:	c7 44 24 08 7d 40 80 	movl   $0x80407d,0x8(%esp)
  80115d:	00 
  80115e:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
  801165:	00 
  801166:	c7 04 24 06 42 80 00 	movl   $0x804206,(%esp)
  80116d:	e8 5a 0c 00 00       	call   801dcc <_panic>
	nblock = dir->f_size / BLKSIZE;
  801172:	89 d0                	mov    %edx,%eax
  801174:	c1 f8 1f             	sar    $0x1f,%eax
  801177:	c1 e8 14             	shr    $0x14,%eax
  80117a:	01 d0                	add    %edx,%eax
  80117c:	89 c7                	mov    %eax,%edi
  80117e:	c1 ff 0c             	sar    $0xc,%edi
	for (i = 0; i < nblock; i++) {
  801181:	c7 85 60 ff ff ff 00 	movl   $0x0,-0xa0(%ebp)
  801188:	00 00 00 
  80118b:	85 ff                	test   %edi,%edi
  80118d:	74 5f                	je     8011ee <file_create+0xfe>
  80118f:	c7 85 60 ff ff ff 00 	movl   $0x0,-0xa0(%ebp)
  801196:	00 00 00 
		if ((r = file_get_block(dir, i, &blk)) < 0)
  801199:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  80119f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011a3:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  8011a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011ad:	89 34 24             	mov    %esi,(%esp)
  8011b0:	e8 0c fa ff ff       	call   800bc1 <file_get_block>
  8011b5:	85 c0                	test   %eax,%eax
  8011b7:	0f 88 a6 00 00 00    	js     801263 <file_create+0x173>
  8011bd:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  8011c3:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
			if (f[j].f_name[0] == '\0') {
  8011c9:	80 38 00             	cmpb   $0x0,(%eax)
  8011cc:	75 08                	jne    8011d6 <file_create+0xe6>
				*file = &f[j];
  8011ce:	89 85 6c ff ff ff    	mov    %eax,-0x94(%ebp)
  8011d4:	eb 57                	jmp    80122d <file_create+0x13d>
  8011d6:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  8011db:	39 d0                	cmp    %edx,%eax
  8011dd:	75 ea                	jne    8011c9 <file_create+0xd9>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  8011df:	83 85 60 ff ff ff 01 	addl   $0x1,-0xa0(%ebp)
  8011e6:	3b bd 60 ff ff ff    	cmp    -0xa0(%ebp),%edi
  8011ec:	75 ab                	jne    801199 <file_create+0xa9>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  8011ee:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  8011f5:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  8011f8:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8011fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801202:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  801208:	89 44 24 04          	mov    %eax,0x4(%esp)
  80120c:	89 34 24             	mov    %esi,(%esp)
  80120f:	e8 ad f9 ff ff       	call   800bc1 <file_get_block>
  801214:	85 c0                	test   %eax,%eax
  801216:	78 4b                	js     801263 <file_create+0x173>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  801218:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
  80121e:	89 85 6c ff ff ff    	mov    %eax,-0x94(%ebp)
  801224:	eb 07                	jmp    80122d <file_create+0x13d>
  801226:	bb f3 ff ff ff       	mov    $0xfffffff3,%ebx
  80122b:	eb 36                	jmp    801263 <file_create+0x173>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
	if (dir_alloc_file(dir, &f) < 0)
		return r;
	strcpy(f->f_name, name);
  80122d:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
  801233:	89 44 24 04          	mov    %eax,0x4(%esp)
  801237:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
  80123d:	89 04 24             	mov    %eax,(%esp)
  801240:	e8 bc 12 00 00       	call   802501 <strcpy>
	*pf = f;
  801245:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
  80124b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124e:	89 02                	mov    %eax,(%edx)
	file_flush(dir);
  801250:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
  801256:	89 04 24             	mov    %eax,(%esp)
  801259:	e8 bf f7 ff ff       	call   800a1d <file_flush>
  80125e:	bb 00 00 00 00       	mov    $0x0,%ebx
	return 0;
}
  801263:	89 d8                	mov    %ebx,%eax
  801265:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801268:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80126b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80126e:	89 ec                	mov    %ebp,%esp
  801270:	5d                   	pop    %ebp
  801271:	c3                   	ret    

00801272 <fs_init>:
// --------------------------------------------------------------

// Initialize the file system
void
fs_init(void)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available.
	if (ide_probe_disk1())
  801278:	e8 25 ee ff ff       	call   8000a2 <ide_probe_disk1>
  80127d:	85 c0                	test   %eax,%eax
  80127f:	74 11                	je     801292 <fs_init+0x20>
		ide_set_disk(1);
  801281:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801288:	e8 e4 ed ff ff       	call   800071 <ide_set_disk>
  80128d:	8d 76 00             	lea    0x0(%esi),%esi
  801290:	eb 0c                	jmp    80129e <fs_init+0x2c>
	else
		ide_set_disk(0);
  801292:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801299:	e8 d3 ed ff ff       	call   800071 <ide_set_disk>
	bc_init();
  80129e:	66 90                	xchg   %ax,%ax
  8012a0:	e8 77 f2 ff ff       	call   80051c <bc_init>

	// Set "super" to point to the super block.
	super = (struct Super*)diskaddr(1);
  8012a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8012ac:	e8 37 f0 ff ff       	call   8002e8 <diskaddr>
  8012b1:	a3 a4 c0 80 00       	mov    %eax,0x80c0a4
	//cprintf("super block:magic=%x nblocks=%x\n",super->s_magic,super->s_nblocks);
	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  8012b6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8012bd:	e8 26 f0 ff ff       	call   8002e8 <diskaddr>
  8012c2:	a3 a0 c0 80 00       	mov    %eax,0x80c0a0

	check_super();
  8012c7:	e8 3e f6 ff ff       	call   80090a <check_super>
	check_bitmap();
  8012cc:	e8 66 f5 ff ff       	call   800837 <check_bitmap>
}
  8012d1:	c9                   	leave  
  8012d2:	c3                   	ret    
	...

008012e0 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
  8012e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e8:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8012ed:	b8 00 00 00 00       	mov    $0x0,%eax
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
		opentab[i].o_fileid = i;
  8012f2:	89 90 20 80 80 00    	mov    %edx,0x808020(%eax)
		opentab[i].o_fd = (struct Fd*) va;
  8012f8:	89 88 2c 80 80 00    	mov    %ecx,0x80802c(%eax)
		va += PGSIZE;
  8012fe:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  801304:	83 c2 01             	add    $0x1,%edx
  801307:	83 c0 10             	add    $0x10,%eax
  80130a:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801310:	75 e0                	jne    8012f2 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  801312:	5d                   	pop    %ebp
  801313:	c3                   	ret    

00801314 <serve_sync>:
}

// Sync the file system.
int
serve_sync(envid_t envid, union Fsipc *req)
{
  801314:	55                   	push   %ebp
  801315:	89 e5                	mov    %esp,%ebp
  801317:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  80131a:	e8 22 f4 ff ff       	call   800741 <fs_sync>
	return 0;
}
  80131f:	b8 00 00 00 00       	mov    $0x0,%eax
  801324:	c9                   	leave  
  801325:	c3                   	ret    

00801326 <serve_remove>:
}

// Remove the file req->req_path.
int
serve_remove(envid_t envid, struct Fsreq_remove *req)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	53                   	push   %ebx
  80132a:	81 ec 14 04 00 00    	sub    $0x414,%esp

	// Delete the named file.
	// Note: This request doesn't refer to an open file.

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801330:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  801337:	00 
  801338:	8b 45 0c             	mov    0xc(%ebp),%eax
  80133b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80133f:	8d 9d fc fb ff ff    	lea    -0x404(%ebp),%ebx
  801345:	89 1c 24             	mov    %ebx,(%esp)
  801348:	e8 bb 13 00 00       	call   802708 <memmove>
	path[MAXPATHLEN-1] = 0;
  80134d:	c6 45 fb 00          	movb   $0x0,-0x5(%ebp)

	// Delete the specified file
	return file_remove(path);
  801351:	89 1c 24             	mov    %ebx,(%esp)
  801354:	e8 25 fd ff ff       	call   80107e <file_remove>
}
  801359:	81 c4 14 04 00 00    	add    $0x414,%esp
  80135f:	5b                   	pop    %ebx
  801360:	5d                   	pop    %ebp
  801361:	c3                   	ret    

00801362 <openfile_lookup>:
}

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
  801365:	83 ec 18             	sub    $0x18,%esp
  801368:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80136b:	89 75 fc             	mov    %esi,-0x4(%ebp)
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  80136e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801371:	25 ff 03 00 00       	and    $0x3ff,%eax
  801376:	89 c3                	mov    %eax,%ebx
  801378:	c1 e3 04             	shl    $0x4,%ebx
  80137b:	8d b3 20 80 80 00    	lea    0x808020(%ebx),%esi
	if (pageref(o->o_fd) == 1 || o->o_fileid != fileid)
  801381:	8b 46 0c             	mov    0xc(%esi),%eax
  801384:	89 04 24             	mov    %eax,(%esp)
  801387:	e8 fc 24 00 00       	call   803888 <pageref>
  80138c:	83 f8 01             	cmp    $0x1,%eax
  80138f:	74 17                	je     8013a8 <openfile_lookup+0x46>
  801391:	8b 45 0c             	mov    0xc(%ebp),%eax
  801394:	39 83 20 80 80 00    	cmp    %eax,0x808020(%ebx)
  80139a:	75 0c                	jne    8013a8 <openfile_lookup+0x46>
		return -E_INVAL;
	*po = o;
  80139c:	8b 45 10             	mov    0x10(%ebp),%eax
  80139f:	89 30                	mov    %esi,(%eax)
  8013a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a6:	eb 05                	jmp    8013ad <openfile_lookup+0x4b>
	return 0;
  8013a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013ad:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013b0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8013b3:	89 ec                	mov    %ebp,%esp
  8013b5:	5d                   	pop    %ebp
  8013b6:	c3                   	ret    

008013b7 <serve_flush>:
}

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  8013b7:	55                   	push   %ebp
  8013b8:	89 e5                	mov    %esp,%ebp
  8013ba:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013bd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013c7:	8b 00                	mov    (%eax),%eax
  8013c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d0:	89 04 24             	mov    %eax,(%esp)
  8013d3:	e8 8a ff ff ff       	call   801362 <openfile_lookup>
  8013d8:	85 c0                	test   %eax,%eax
  8013da:	78 13                	js     8013ef <serve_flush+0x38>
		return r;
	file_flush(o->o_file);
  8013dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013df:	8b 40 04             	mov    0x4(%eax),%eax
  8013e2:	89 04 24             	mov    %eax,(%esp)
  8013e5:	e8 33 f6 ff ff       	call   800a1d <file_flush>
  8013ea:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8013ef:	c9                   	leave  
  8013f0:	c3                   	ret    

008013f1 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  8013f1:	55                   	push   %ebp
  8013f2:	89 e5                	mov    %esp,%ebp
  8013f4:	53                   	push   %ebx
  8013f5:	83 ec 24             	sub    $0x24,%esp
  8013f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013fb:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8013fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801402:	8b 03                	mov    (%ebx),%eax
  801404:	89 44 24 04          	mov    %eax,0x4(%esp)
  801408:	8b 45 08             	mov    0x8(%ebp),%eax
  80140b:	89 04 24             	mov    %eax,(%esp)
  80140e:	e8 4f ff ff ff       	call   801362 <openfile_lookup>
  801413:	85 c0                	test   %eax,%eax
  801415:	78 3f                	js     801456 <serve_stat+0x65>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  801417:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80141a:	8b 40 04             	mov    0x4(%eax),%eax
  80141d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801421:	89 1c 24             	mov    %ebx,(%esp)
  801424:	e8 d8 10 00 00       	call   802501 <strcpy>
	ret->ret_size = o->o_file->f_size;
  801429:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80142c:	8b 42 04             	mov    0x4(%edx),%eax
  80142f:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801435:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  80143b:	8b 42 04             	mov    0x4(%edx),%eax
  80143e:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  801445:	0f 94 c0             	sete   %al
  801448:	0f b6 c0             	movzbl %al,%eax
  80144b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801451:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801456:	83 c4 24             	add    $0x24,%esp
  801459:	5b                   	pop    %ebx
  80145a:	5d                   	pop    %ebp
  80145b:	c3                   	ret    

0080145c <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  80145c:	55                   	push   %ebp
  80145d:	89 e5                	mov    %esp,%ebp
  80145f:	53                   	push   %ebx
  801460:	83 ec 24             	sub    $0x24,%esp
  801463:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// LAB 5: Your code here.
	int r;
	struct OpenFile *o;
	size_t count;
	int retcount;
	if((r=openfile_lookup(envid,req->req_fileid,&o))<0){
  801466:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801469:	89 44 24 08          	mov    %eax,0x8(%esp)
  80146d:	8b 03                	mov    (%ebx),%eax
  80146f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801473:	8b 45 08             	mov    0x8(%ebp),%eax
  801476:	89 04 24             	mov    %eax,(%esp)
  801479:	e8 e4 fe ff ff       	call   801362 <openfile_lookup>
  80147e:	85 c0                	test   %eax,%eax
  801480:	78 2f                	js     8014b1 <serve_write+0x55>
		return r;
	}
	count=req->req_n;
	retcount=file_write(o->o_file,(void*)req->req_buf,count,o->o_fd->fd_offset);
  801482:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801485:	8b 42 0c             	mov    0xc(%edx),%eax
  801488:	8b 40 04             	mov    0x4(%eax),%eax
  80148b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80148f:	8b 43 04             	mov    0x4(%ebx),%eax
  801492:	89 44 24 08          	mov    %eax,0x8(%esp)
  801496:	8d 43 08             	lea    0x8(%ebx),%eax
  801499:	89 44 24 04          	mov    %eax,0x4(%esp)
  80149d:	8b 42 04             	mov    0x4(%edx),%eax
  8014a0:	89 04 24             	mov    %eax,(%esp)
  8014a3:	e8 f1 f7 ff ff       	call   800c99 <file_write>
	o->o_fd->fd_offset+=retcount;
  8014a8:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8014ab:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ae:	01 42 04             	add    %eax,0x4(%edx)
	return retcount;
	//panic("serve_write not implemented");
}
  8014b1:	83 c4 24             	add    $0x24,%esp
  8014b4:	5b                   	pop    %ebx
  8014b5:	5d                   	pop    %ebp
  8014b6:	c3                   	ret    

008014b7 <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  8014b7:	55                   	push   %ebp
  8014b8:	89 e5                	mov    %esp,%ebp
  8014ba:	53                   	push   %ebx
  8014bb:	83 ec 24             	sub    $0x24,%esp
  8014be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// LAB 5: Your code here
	int r;
	struct OpenFile *o;
	size_t count;
	int retcount;
	if((r=openfile_lookup(envid,req->req_fileid,&o))<0){
  8014c1:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8014c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014c8:	8b 03                	mov    (%ebx),%eax
  8014ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d1:	89 04 24             	mov    %eax,(%esp)
  8014d4:	e8 89 fe ff ff       	call   801362 <openfile_lookup>
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	78 38                	js     801515 <serve_read+0x5e>
	}
	if(req->req_n>PGSIZE)
		count=PGSIZE;
	else
		count=req->req_n;
	retcount=file_read(o->o_file,(void*)ret->ret_buf,count,o->o_fd->fd_offset);
  8014dd:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8014e0:	8b 42 0c             	mov    0xc(%edx),%eax
  8014e3:	8b 40 04             	mov    0x4(%eax),%eax
  8014e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014ea:	8b 43 04             	mov    0x4(%ebx),%eax
  8014ed:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014f2:	76 05                	jbe    8014f9 <serve_read+0x42>
  8014f4:	b8 00 10 00 00       	mov    $0x1000,%eax
  8014f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801501:	8b 42 04             	mov    0x4(%edx),%eax
  801504:	89 04 24             	mov    %eax,(%esp)
  801507:	e8 4b f8 ff ff       	call   800d57 <file_read>
	o->o_fd->fd_offset+=retcount;
  80150c:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80150f:	8b 52 0c             	mov    0xc(%edx),%edx
  801512:	01 42 04             	add    %eax,0x4(%edx)
	if(debug)
		cprintf("serve_read:ret_buf=%s\n",ret->ret_buf);
	return retcount;
	//panic("serve_read not implemented");
}
  801515:	83 c4 24             	add    $0x24,%esp
  801518:	5b                   	pop    %ebx
  801519:	5d                   	pop    %ebp
  80151a:	c3                   	ret    

0080151b <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  80151b:	55                   	push   %ebp
  80151c:	89 e5                	mov    %esp,%ebp
  80151e:	53                   	push   %ebx
  80151f:	83 ec 24             	sub    $0x24,%esp
  801522:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801525:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801528:	89 44 24 08          	mov    %eax,0x8(%esp)
  80152c:	8b 03                	mov    (%ebx),%eax
  80152e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801532:	8b 45 08             	mov    0x8(%ebp),%eax
  801535:	89 04 24             	mov    %eax,(%esp)
  801538:	e8 25 fe ff ff       	call   801362 <openfile_lookup>
  80153d:	85 c0                	test   %eax,%eax
  80153f:	78 15                	js     801556 <serve_set_size+0x3b>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  801541:	8b 43 04             	mov    0x4(%ebx),%eax
  801544:	89 44 24 04          	mov    %eax,0x4(%esp)
  801548:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80154b:	8b 40 04             	mov    0x4(%eax),%eax
  80154e:	89 04 24             	mov    %eax,(%esp)
  801551:	e8 2b f6 ff ff       	call   800b81 <file_set_size>
}
  801556:	83 c4 24             	add    $0x24,%esp
  801559:	5b                   	pop    %ebx
  80155a:	5d                   	pop    %ebp
  80155b:	c3                   	ret    

0080155c <openfile_alloc>:
}

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
  80155f:	56                   	push   %esi
  801560:	53                   	push   %ebx
  801561:	83 ec 10             	sub    $0x10,%esp
  801564:	8b 75 08             	mov    0x8(%ebp),%esi
  801567:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
		switch (pageref(opentab[i].o_fd)) {
  80156c:	89 d8                	mov    %ebx,%eax
  80156e:	c1 e0 04             	shl    $0x4,%eax
  801571:	8b 80 2c 80 80 00    	mov    0x80802c(%eax),%eax
  801577:	89 04 24             	mov    %eax,(%esp)
  80157a:	e8 09 23 00 00       	call   803888 <pageref>
  80157f:	85 c0                	test   %eax,%eax
  801581:	74 07                	je     80158a <openfile_alloc+0x2e>
  801583:	83 f8 01             	cmp    $0x1,%eax
  801586:	75 64                	jne    8015ec <openfile_alloc+0x90>
  801588:	eb 27                	jmp    8015b1 <openfile_alloc+0x55>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  80158a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801591:	00 
  801592:	89 d8                	mov    %ebx,%eax
  801594:	c1 e0 04             	shl    $0x4,%eax
  801597:	8b 80 2c 80 80 00    	mov    0x80802c(%eax),%eax
  80159d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015a8:	e8 8d 16 00 00       	call   802c3a <sys_page_alloc>
  8015ad:	85 c0                	test   %eax,%eax
  8015af:	78 4f                	js     801600 <openfile_alloc+0xa4>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  8015b1:	89 da                	mov    %ebx,%edx
  8015b3:	c1 e2 04             	shl    $0x4,%edx
  8015b6:	81 82 20 80 80 00 00 	addl   $0x400,0x808020(%edx)
  8015bd:	04 00 00 
			*o = &opentab[i];
  8015c0:	8d 82 20 80 80 00    	lea    0x808020(%edx),%eax
  8015c6:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  8015c8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8015cf:	00 
  8015d0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015d7:	00 
  8015d8:	8b 82 2c 80 80 00    	mov    0x80802c(%edx),%eax
  8015de:	89 04 24             	mov    %eax,(%esp)
  8015e1:	e8 c8 10 00 00       	call   8026ae <memset>
			return (*o)->o_fileid;
  8015e6:	8b 06                	mov    (%esi),%eax
  8015e8:	8b 00                	mov    (%eax),%eax
  8015ea:	eb 14                	jmp    801600 <openfile_alloc+0xa4>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  8015ec:	83 c3 01             	add    $0x1,%ebx
  8015ef:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  8015f5:	0f 85 71 ff ff ff    	jne    80156c <openfile_alloc+0x10>
  8015fb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
}
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	5b                   	pop    %ebx
  801604:	5e                   	pop    %esi
  801605:	5d                   	pop    %ebp
  801606:	c3                   	ret    

00801607 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	56                   	push   %esi
  80160b:	53                   	push   %ebx
  80160c:	81 ec 20 04 00 00    	sub    $0x420,%esp
  801612:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801615:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  80161c:	00 
  80161d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801621:	8d b5 f8 fb ff ff    	lea    -0x408(%ebp),%esi
  801627:	89 34 24             	mov    %esi,(%esp)
  80162a:	e8 d9 10 00 00       	call   802708 <memmove>
	path[MAXPATHLEN-1] = 0;
  80162f:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  801633:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  801639:	89 04 24             	mov    %eax,(%esp)
  80163c:	e8 1b ff ff ff       	call   80155c <openfile_alloc>
  801641:	85 c0                	test   %eax,%eax
  801643:	0f 88 e5 00 00 00    	js     80172e <serve_open+0x127>
		return r;
	}
	fileid = r;
	//cprintf("serve_open:fileid=%x\n",fileid);
	// Open the file
	if (req->req_omode & O_CREAT) {
  801649:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  801650:	74 2c                	je     80167e <serve_open+0x77>
		if ((r = file_create(path, &f)) < 0) {
  801652:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801658:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165c:	89 34 24             	mov    %esi,(%esp)
  80165f:	e8 8c fa ff ff       	call   8010f0 <file_create>
  801664:	85 c0                	test   %eax,%eax
  801666:	79 36                	jns    80169e <serve_open+0x97>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  801668:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  80166f:	0f 85 b9 00 00 00    	jne    80172e <serve_open+0x127>
  801675:	83 f8 f3             	cmp    $0xfffffff3,%eax
  801678:	0f 85 b0 00 00 00    	jne    80172e <serve_open+0x127>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  80167e:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801684:	89 44 24 04          	mov    %eax,0x4(%esp)
  801688:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80168e:	89 04 24             	mov    %eax,(%esp)
  801691:	e8 3b fa ff ff       	call   8010d1 <file_open>
  801696:	85 c0                	test   %eax,%eax
  801698:	0f 88 90 00 00 00    	js     80172e <serve_open+0x127>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  80169e:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  8016a5:	74 1a                	je     8016c1 <serve_open+0xba>
		if ((r = file_set_size(f, 0)) < 0) {
  8016a7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016ae:	00 
  8016af:	8b 85 f4 fb ff ff    	mov    -0x40c(%ebp),%eax
  8016b5:	89 04 24             	mov    %eax,(%esp)
  8016b8:	e8 c4 f4 ff ff       	call   800b81 <file_set_size>
  8016bd:	85 c0                	test   %eax,%eax
  8016bf:	78 6d                	js     80172e <serve_open+0x127>
			return r;
		}
	}

	// Save the file pointer
	o->o_file = f;
  8016c1:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  8016c7:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8016cd:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  8016d0:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8016d6:	8b 50 0c             	mov    0xc(%eax),%edx
  8016d9:	8b 00                	mov    (%eax),%eax
  8016db:	89 42 0c             	mov    %eax,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  8016de:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8016e4:	8b 50 0c             	mov    0xc(%eax),%edx
  8016e7:	8b 83 00 04 00 00    	mov    0x400(%ebx),%eax
  8016ed:	83 e0 03             	and    $0x3,%eax
  8016f0:	89 42 08             	mov    %eax,0x8(%edx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  8016f3:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8016f9:	8b 50 0c             	mov    0xc(%eax),%edx
  8016fc:	a1 68 c0 80 00       	mov    0x80c068,%eax
  801701:	89 02                	mov    %eax,(%edx)
	o->o_mode = req->req_omode;
  801703:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801709:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  80170f:	89 50 08             	mov    %edx,0x8(%eax)

	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller
	*pg_store = o->o_fd;
  801712:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801718:	8b 40 0c             	mov    0xc(%eax),%eax
  80171b:	8b 55 10             	mov    0x10(%ebp),%edx
  80171e:	89 02                	mov    %eax,(%edx)
	*perm_store = PTE_P|PTE_U|PTE_W;
  801720:	8b 45 14             	mov    0x14(%ebp),%eax
  801723:	c7 00 07 00 00 00    	movl   $0x7,(%eax)
  801729:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80172e:	81 c4 20 04 00 00    	add    $0x420,%esp
  801734:	5b                   	pop    %ebx
  801735:	5e                   	pop    %esi
  801736:	5d                   	pop    %ebp
  801737:	c3                   	ret    

00801738 <serve>:
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  801738:	55                   	push   %ebp
  801739:	89 e5                	mov    %esp,%ebp
  80173b:	56                   	push   %esi
  80173c:	53                   	push   %ebx
  80173d:	83 ec 20             	sub    $0x20,%esp
	void *pg;

	while (1) {
		perm = 0;
		//cprintf("****serve is runing,start to recive******\n");
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801740:	8d 75 f4             	lea    -0xc(%ebp),%esi
  801743:	8d 5d f0             	lea    -0x10(%ebp),%ebx
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  801746:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		//cprintf("****serve is runing,start to recive******\n");
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  80174d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801751:	a1 20 c0 80 00       	mov    0x80c020,%eax
  801756:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175a:	89 34 24             	mov    %esi,(%esp)
  80175d:	e8 62 17 00 00       	call   802ec4 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, vpt[VPN(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  801762:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  801766:	75 15                	jne    80177d <serve+0x45>
			cprintf("Invalid request from %08x: no argument page\n",
  801768:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80176b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80176f:	c7 04 24 dc 42 80 00 	movl   $0x8042dc,(%esp)
  801776:	e8 1e 07 00 00       	call   801e99 <cprintf>
  80177b:	eb c9                	jmp    801746 <serve+0xe>
				whom);
			continue; // just leave it hanging...
		}

		pg = NULL;
  80177d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  801784:	83 f8 01             	cmp    $0x1,%eax
  801787:	75 23                	jne    8017ac <serve+0x74>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  801789:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80178d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801790:	89 44 24 08          	mov    %eax,0x8(%esp)
  801794:	a1 20 c0 80 00       	mov    0x80c020,%eax
  801799:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a0:	89 04 24             	mov    %eax,(%esp)
  8017a3:	e8 5f fe ff ff       	call   801607 <serve_open>
  8017a8:	89 c2                	mov    %eax,%edx
  8017aa:	eb 41                	jmp    8017ed <serve+0xb5>
		} else if (req < NHANDLERS && handlers[req]) {
  8017ac:	83 f8 08             	cmp    $0x8,%eax
  8017af:	77 20                	ja     8017d1 <serve+0x99>
  8017b1:	8b 14 85 40 c0 80 00 	mov    0x80c040(,%eax,4),%edx
  8017b8:	85 d2                	test   %edx,%edx
  8017ba:	74 15                	je     8017d1 <serve+0x99>
			r = handlers[req](whom, fsreq);
  8017bc:	a1 20 c0 80 00       	mov    0x80c020,%eax
  8017c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c8:	89 04 24             	mov    %eax,(%esp)
  8017cb:	ff d2                	call   *%edx
  8017cd:	89 c2                	mov    %eax,%edx
  8017cf:	eb 1c                	jmp    8017ed <serve+0xb5>
		} else {
			cprintf("Invalid request code %d from %08x\n", whom, req);
  8017d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017dc:	c7 04 24 0c 43 80 00 	movl   $0x80430c,(%esp)
  8017e3:	e8 b1 06 00 00       	call   801e99 <cprintf>
  8017e8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
			r = -E_INVAL;
		}
		ipc_send(whom, r, pg, perm);
  8017ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8017f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017fb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801802:	89 04 24             	mov    %eax,(%esp)
  801805:	e8 06 16 00 00       	call   802e10 <ipc_send>
		sys_page_unmap(0, fsreq);
  80180a:	a1 20 c0 80 00       	mov    0x80c020,%eax
  80180f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801813:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80181a:	e8 5f 13 00 00       	call   802b7e <sys_page_unmap>
  80181f:	e9 22 ff ff ff       	jmp    801746 <serve+0xe>

00801824 <umain>:
	}
}

void
umain(void)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  80182a:	c7 05 64 c0 80 00 2f 	movl   $0x80432f,0x80c064
  801831:	43 80 00 
	cprintf("FS is running\n");
  801834:	c7 04 24 32 43 80 00 	movl   $0x804332,(%esp)
  80183b:	e8 59 06 00 00       	call   801e99 <cprintf>
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  801840:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  801845:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  80184a:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  80184c:	c7 04 24 41 43 80 00 	movl   $0x804341,(%esp)
  801853:	e8 41 06 00 00       	call   801e99 <cprintf>

	serve_init();
  801858:	e8 83 fa ff ff       	call   8012e0 <serve_init>
	fs_init();
  80185d:	e8 10 fa ff ff       	call   801272 <fs_init>
	fs_test();
  801862:	e8 0d 00 00 00       	call   801874 <fs_test>

	serve();
  801867:	e8 cc fe ff ff       	call   801738 <serve>
}
  80186c:	c9                   	leave  
  80186d:	8d 76 00             	lea    0x0(%esi),%esi
  801870:	c3                   	ret    
  801871:	00 00                	add    %al,(%eax)
	...

00801874 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801874:	55                   	push   %ebp
  801875:	89 e5                	mov    %esp,%ebp
  801877:	53                   	push   %ebx
  801878:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  80187b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801882:	00 
  801883:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  80188a:	00 
  80188b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801892:	e8 a3 13 00 00       	call   802c3a <sys_page_alloc>
  801897:	85 c0                	test   %eax,%eax
  801899:	79 20                	jns    8018bb <fs_test+0x47>
		panic("sys_page_alloc: %e", r);
  80189b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80189f:	c7 44 24 08 50 43 80 	movl   $0x804350,0x8(%esp)
  8018a6:	00 
  8018a7:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  8018ae:	00 
  8018af:	c7 04 24 63 43 80 00 	movl   $0x804363,(%esp)
  8018b6:	e8 11 05 00 00       	call   801dcc <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  8018bb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8018c2:	00 
  8018c3:	a1 a0 c0 80 00       	mov    0x80c0a0,%eax
  8018c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018cc:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  8018d3:	e8 30 0e 00 00       	call   802708 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8018d8:	e8 a5 ee ff ff       	call   800782 <alloc_block>
  8018dd:	85 c0                	test   %eax,%eax
  8018df:	79 20                	jns    801901 <fs_test+0x8d>
		panic("alloc_block: %e", r);
  8018e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018e5:	c7 44 24 08 6d 43 80 	movl   $0x80436d,0x8(%esp)
  8018ec:	00 
  8018ed:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
  8018f4:	00 
  8018f5:	c7 04 24 63 43 80 00 	movl   $0x804363,(%esp)
  8018fc:	e8 cb 04 00 00       	call   801dcc <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  801901:	89 c2                	mov    %eax,%edx
  801903:	c1 fa 1f             	sar    $0x1f,%edx
  801906:	c1 ea 1b             	shr    $0x1b,%edx
  801909:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
  80190c:	89 c8                	mov    %ecx,%eax
  80190e:	c1 f8 05             	sar    $0x5,%eax
  801911:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
  801918:	83 e1 1f             	and    $0x1f,%ecx
  80191b:	29 d1                	sub    %edx,%ecx
  80191d:	b8 01 00 00 00       	mov    $0x1,%eax
  801922:	89 c2                	mov    %eax,%edx
  801924:	d3 e2                	shl    %cl,%edx
  801926:	85 93 00 10 00 00    	test   %edx,0x1000(%ebx)
  80192c:	75 24                	jne    801952 <fs_test+0xde>
  80192e:	c7 44 24 0c 7d 43 80 	movl   $0x80437d,0xc(%esp)
  801935:	00 
  801936:	c7 44 24 08 7d 40 80 	movl   $0x80407d,0x8(%esp)
  80193d:	00 
  80193e:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  801945:	00 
  801946:	c7 04 24 63 43 80 00 	movl   $0x804363,(%esp)
  80194d:	e8 7a 04 00 00       	call   801dcc <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801952:	89 d8                	mov    %ebx,%eax
  801954:	03 05 a0 c0 80 00    	add    0x80c0a0,%eax
  80195a:	85 10                	test   %edx,(%eax)
  80195c:	74 24                	je     801982 <fs_test+0x10e>
  80195e:	c7 44 24 0c f0 44 80 	movl   $0x8044f0,0xc(%esp)
  801965:	00 
  801966:	c7 44 24 08 7d 40 80 	movl   $0x80407d,0x8(%esp)
  80196d:	00 
  80196e:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  801975:	00 
  801976:	c7 04 24 63 43 80 00 	movl   $0x804363,(%esp)
  80197d:	e8 4a 04 00 00       	call   801dcc <_panic>
	cprintf("alloc_block is good\n");
  801982:	c7 04 24 98 43 80 00 	movl   $0x804398,(%esp)
  801989:	e8 0b 05 00 00       	call   801e99 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  80198e:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801991:	89 44 24 04          	mov    %eax,0x4(%esp)
  801995:	c7 04 24 ad 43 80 00 	movl   $0x8043ad,(%esp)
  80199c:	e8 30 f7 ff ff       	call   8010d1 <file_open>
  8019a1:	85 c0                	test   %eax,%eax
  8019a3:	79 25                	jns    8019ca <fs_test+0x156>
  8019a5:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8019a8:	74 40                	je     8019ea <fs_test+0x176>
		panic("file_open /not-found: %e", r);
  8019aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019ae:	c7 44 24 08 b8 43 80 	movl   $0x8043b8,0x8(%esp)
  8019b5:	00 
  8019b6:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8019bd:	00 
  8019be:	c7 04 24 63 43 80 00 	movl   $0x804363,(%esp)
  8019c5:	e8 02 04 00 00       	call   801dcc <_panic>
	else if (r == 0)
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	75 1c                	jne    8019ea <fs_test+0x176>
		panic("file_open /not-found succeeded!");
  8019ce:	c7 44 24 08 10 45 80 	movl   $0x804510,0x8(%esp)
  8019d5:	00 
  8019d6:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8019dd:	00 
  8019de:	c7 04 24 63 43 80 00 	movl   $0x804363,(%esp)
  8019e5:	e8 e2 03 00 00       	call   801dcc <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  8019ea:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8019ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f1:	c7 04 24 d1 43 80 00 	movl   $0x8043d1,(%esp)
  8019f8:	e8 d4 f6 ff ff       	call   8010d1 <file_open>
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	79 20                	jns    801a21 <fs_test+0x1ad>
		panic("file_open /newmotd: %e", r);
  801a01:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a05:	c7 44 24 08 da 43 80 	movl   $0x8043da,0x8(%esp)
  801a0c:	00 
  801a0d:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801a14:	00 
  801a15:	c7 04 24 63 43 80 00 	movl   $0x804363,(%esp)
  801a1c:	e8 ab 03 00 00       	call   801dcc <_panic>
	cprintf("file_open is good\n");
  801a21:	c7 04 24 f1 43 80 00 	movl   $0x8043f1,(%esp)
  801a28:	e8 6c 04 00 00       	call   801e99 <cprintf>
	//panic("file open is ok 000000000\n");
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801a2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a30:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a34:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a3b:	00 
  801a3c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801a3f:	89 04 24             	mov    %eax,(%esp)
  801a42:	e8 7a f1 ff ff       	call   800bc1 <file_get_block>
  801a47:	85 c0                	test   %eax,%eax
  801a49:	79 20                	jns    801a6b <fs_test+0x1f7>
		panic("file_get_block: %e", r);
  801a4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a4f:	c7 44 24 08 04 44 80 	movl   $0x804404,0x8(%esp)
  801a56:	00 
  801a57:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801a5e:	00 
  801a5f:	c7 04 24 63 43 80 00 	movl   $0x804363,(%esp)
  801a66:	e8 61 03 00 00       	call   801dcc <_panic>
	//panic("000000000\n");
	if (strcmp(blk, msg) != 0)
  801a6b:	8b 1d 7c 45 80 00    	mov    0x80457c,%ebx
  801a71:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a78:	89 04 24             	mov    %eax,(%esp)
  801a7b:	e8 61 0b 00 00       	call   8025e1 <strcmp>
  801a80:	85 c0                	test   %eax,%eax
  801a82:	74 1c                	je     801aa0 <fs_test+0x22c>
		panic("file_get_block returned wrong data");
  801a84:	c7 44 24 08 30 45 80 	movl   $0x804530,0x8(%esp)
  801a8b:	00 
  801a8c:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  801a93:	00 
  801a94:	c7 04 24 63 43 80 00 	movl   $0x804363,(%esp)
  801a9b:	e8 2c 03 00 00       	call   801dcc <_panic>
	cprintf("file_get_block is good\n");
  801aa0:	c7 04 24 17 44 80 00 	movl   $0x804417,(%esp)
  801aa7:	e8 ed 03 00 00       	call   801e99 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801aac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801aaf:	0f b6 02             	movzbl (%edx),%eax
  801ab2:	88 02                	mov    %al,(%edx)
	assert((vpt[VPN(blk)] & PTE_D));
  801ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab7:	c1 e8 0c             	shr    $0xc,%eax
  801aba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ac1:	a8 40                	test   $0x40,%al
  801ac3:	75 24                	jne    801ae9 <fs_test+0x275>
  801ac5:	c7 44 24 0c 30 44 80 	movl   $0x804430,0xc(%esp)
  801acc:	00 
  801acd:	c7 44 24 08 7d 40 80 	movl   $0x80407d,0x8(%esp)
  801ad4:	00 
  801ad5:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  801adc:	00 
  801add:	c7 04 24 63 43 80 00 	movl   $0x804363,(%esp)
  801ae4:	e8 e3 02 00 00       	call   801dcc <_panic>
	file_flush(f);
  801ae9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801aec:	89 04 24             	mov    %eax,(%esp)
  801aef:	e8 29 ef ff ff       	call   800a1d <file_flush>
	assert(!(vpt[VPN(blk)] & PTE_D));
  801af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af7:	c1 e8 0c             	shr    $0xc,%eax
  801afa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b01:	a8 40                	test   $0x40,%al
  801b03:	74 24                	je     801b29 <fs_test+0x2b5>
  801b05:	c7 44 24 0c 2f 44 80 	movl   $0x80442f,0xc(%esp)
  801b0c:	00 
  801b0d:	c7 44 24 08 7d 40 80 	movl   $0x80407d,0x8(%esp)
  801b14:	00 
  801b15:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  801b1c:	00 
  801b1d:	c7 04 24 63 43 80 00 	movl   $0x804363,(%esp)
  801b24:	e8 a3 02 00 00       	call   801dcc <_panic>
	cprintf("file_flush is good\n");
  801b29:	c7 04 24 48 44 80 00 	movl   $0x804448,(%esp)
  801b30:	e8 64 03 00 00       	call   801e99 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801b35:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b3c:	00 
  801b3d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801b40:	89 04 24             	mov    %eax,(%esp)
  801b43:	e8 39 f0 ff ff       	call   800b81 <file_set_size>
  801b48:	85 c0                	test   %eax,%eax
  801b4a:	79 20                	jns    801b6c <fs_test+0x2f8>
		panic("file_set_size: %e", r);
  801b4c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b50:	c7 44 24 08 5c 44 80 	movl   $0x80445c,0x8(%esp)
  801b57:	00 
  801b58:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801b5f:	00 
  801b60:	c7 04 24 63 43 80 00 	movl   $0x804363,(%esp)
  801b67:	e8 60 02 00 00       	call   801dcc <_panic>
	assert(f->f_direct[0] == 0);
  801b6c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801b6f:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  801b76:	74 24                	je     801b9c <fs_test+0x328>
  801b78:	c7 44 24 0c 6e 44 80 	movl   $0x80446e,0xc(%esp)
  801b7f:	00 
  801b80:	c7 44 24 08 7d 40 80 	movl   $0x80407d,0x8(%esp)
  801b87:	00 
  801b88:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  801b8f:	00 
  801b90:	c7 04 24 63 43 80 00 	movl   $0x804363,(%esp)
  801b97:	e8 30 02 00 00       	call   801dcc <_panic>
	assert(!(vpt[VPN(f)] & PTE_D));
  801b9c:	c1 e8 0c             	shr    $0xc,%eax
  801b9f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ba6:	a8 40                	test   $0x40,%al
  801ba8:	74 24                	je     801bce <fs_test+0x35a>
  801baa:	c7 44 24 0c 82 44 80 	movl   $0x804482,0xc(%esp)
  801bb1:	00 
  801bb2:	c7 44 24 08 7d 40 80 	movl   $0x80407d,0x8(%esp)
  801bb9:	00 
  801bba:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  801bc1:	00 
  801bc2:	c7 04 24 63 43 80 00 	movl   $0x804363,(%esp)
  801bc9:	e8 fe 01 00 00       	call   801dcc <_panic>
	cprintf("file_truncate is good\n");
  801bce:	c7 04 24 99 44 80 00 	movl   $0x804499,(%esp)
  801bd5:	e8 bf 02 00 00       	call   801e99 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  801bda:	89 1c 24             	mov    %ebx,(%esp)
  801bdd:	e8 ce 08 00 00       	call   8024b0 <strlen>
  801be2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801be9:	89 04 24             	mov    %eax,(%esp)
  801bec:	e8 90 ef ff ff       	call   800b81 <file_set_size>
  801bf1:	85 c0                	test   %eax,%eax
  801bf3:	79 20                	jns    801c15 <fs_test+0x3a1>
		panic("file_set_size 2: %e", r);
  801bf5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bf9:	c7 44 24 08 b0 44 80 	movl   $0x8044b0,0x8(%esp)
  801c00:	00 
  801c01:	c7 44 24 04 3b 00 00 	movl   $0x3b,0x4(%esp)
  801c08:	00 
  801c09:	c7 04 24 63 43 80 00 	movl   $0x804363,(%esp)
  801c10:	e8 b7 01 00 00       	call   801dcc <_panic>
	assert(!(vpt[VPN(f)] & PTE_D));
  801c15:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801c18:	89 d0                	mov    %edx,%eax
  801c1a:	c1 e8 0c             	shr    $0xc,%eax
  801c1d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801c24:	a8 40                	test   $0x40,%al
  801c26:	74 24                	je     801c4c <fs_test+0x3d8>
  801c28:	c7 44 24 0c 82 44 80 	movl   $0x804482,0xc(%esp)
  801c2f:	00 
  801c30:	c7 44 24 08 7d 40 80 	movl   $0x80407d,0x8(%esp)
  801c37:	00 
  801c38:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  801c3f:	00 
  801c40:	c7 04 24 63 43 80 00 	movl   $0x804363,(%esp)
  801c47:	e8 80 01 00 00       	call   801dcc <_panic>
	//panic("aaaaaaaaaaaa\n");
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801c4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c4f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c53:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c5a:	00 
  801c5b:	89 14 24             	mov    %edx,(%esp)
  801c5e:	e8 5e ef ff ff       	call   800bc1 <file_get_block>
  801c63:	85 c0                	test   %eax,%eax
  801c65:	79 20                	jns    801c87 <fs_test+0x413>
		panic("file_get_block 2: %e", r);
  801c67:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c6b:	c7 44 24 08 c4 44 80 	movl   $0x8044c4,0x8(%esp)
  801c72:	00 
  801c73:	c7 44 24 04 3f 00 00 	movl   $0x3f,0x4(%esp)
  801c7a:	00 
  801c7b:	c7 04 24 63 43 80 00 	movl   $0x804363,(%esp)
  801c82:	e8 45 01 00 00       	call   801dcc <_panic>
	strcpy(blk, msg);
  801c87:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8e:	89 04 24             	mov    %eax,(%esp)
  801c91:	e8 6b 08 00 00       	call   802501 <strcpy>
	assert((vpt[VPN(blk)] & PTE_D));
  801c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c99:	c1 e8 0c             	shr    $0xc,%eax
  801c9c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ca3:	a8 40                	test   $0x40,%al
  801ca5:	75 24                	jne    801ccb <fs_test+0x457>
  801ca7:	c7 44 24 0c 30 44 80 	movl   $0x804430,0xc(%esp)
  801cae:	00 
  801caf:	c7 44 24 08 7d 40 80 	movl   $0x80407d,0x8(%esp)
  801cb6:	00 
  801cb7:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801cbe:	00 
  801cbf:	c7 04 24 63 43 80 00 	movl   $0x804363,(%esp)
  801cc6:	e8 01 01 00 00       	call   801dcc <_panic>
	file_flush(f);
  801ccb:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801cce:	89 04 24             	mov    %eax,(%esp)
  801cd1:	e8 47 ed ff ff       	call   800a1d <file_flush>
	assert(!(vpt[VPN(blk)] & PTE_D));
  801cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd9:	c1 e8 0c             	shr    $0xc,%eax
  801cdc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ce3:	a8 40                	test   $0x40,%al
  801ce5:	74 24                	je     801d0b <fs_test+0x497>
  801ce7:	c7 44 24 0c 2f 44 80 	movl   $0x80442f,0xc(%esp)
  801cee:	00 
  801cef:	c7 44 24 08 7d 40 80 	movl   $0x80407d,0x8(%esp)
  801cf6:	00 
  801cf7:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  801cfe:	00 
  801cff:	c7 04 24 63 43 80 00 	movl   $0x804363,(%esp)
  801d06:	e8 c1 00 00 00       	call   801dcc <_panic>
	assert(!(vpt[VPN(f)] & PTE_D));
  801d0b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801d0e:	c1 e8 0c             	shr    $0xc,%eax
  801d11:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d18:	a8 40                	test   $0x40,%al
  801d1a:	74 24                	je     801d40 <fs_test+0x4cc>
  801d1c:	c7 44 24 0c 82 44 80 	movl   $0x804482,0xc(%esp)
  801d23:	00 
  801d24:	c7 44 24 08 7d 40 80 	movl   $0x80407d,0x8(%esp)
  801d2b:	00 
  801d2c:	c7 44 24 04 44 00 00 	movl   $0x44,0x4(%esp)
  801d33:	00 
  801d34:	c7 04 24 63 43 80 00 	movl   $0x804363,(%esp)
  801d3b:	e8 8c 00 00 00       	call   801dcc <_panic>
	cprintf("file rewrite is good\n");
  801d40:	c7 04 24 d9 44 80 00 	movl   $0x8044d9,(%esp)
  801d47:	e8 4d 01 00 00       	call   801e99 <cprintf>
}
  801d4c:	83 c4 24             	add    $0x24,%esp
  801d4f:	5b                   	pop    %ebx
  801d50:	5d                   	pop    %ebp
  801d51:	c3                   	ret    
	...

00801d54 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  801d54:	55                   	push   %ebp
  801d55:	89 e5                	mov    %esp,%ebp
  801d57:	83 ec 18             	sub    $0x18,%esp
  801d5a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d5d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801d60:	8b 75 08             	mov    0x8(%ebp),%esi
  801d63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  801d66:	c7 05 a8 c0 80 00 00 	movl   $0x0,0x80c0a8
  801d6d:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  801d70:	e8 58 0f 00 00       	call   802ccd <sys_getenvid>
  801d75:	25 ff 03 00 00       	and    $0x3ff,%eax
  801d7a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d7d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d82:	a3 a8 c0 80 00       	mov    %eax,0x80c0a8
	// save the name of the program so that panic() can use it
	if (argc > 0)
  801d87:	85 f6                	test   %esi,%esi
  801d89:	7e 07                	jle    801d92 <libmain+0x3e>
		binaryname = argv[0];
  801d8b:	8b 03                	mov    (%ebx),%eax
  801d8d:	a3 64 c0 80 00       	mov    %eax,0x80c064

	// call user main routine
	umain(argc, argv);
  801d92:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d96:	89 34 24             	mov    %esi,(%esp)
  801d99:	e8 86 fa ff ff       	call   801824 <umain>

	// exit gracefully
	exit();
  801d9e:	e8 0d 00 00 00       	call   801db0 <exit>
}
  801da3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801da6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801da9:	89 ec                	mov    %ebp,%esp
  801dab:	5d                   	pop    %ebp
  801dac:	c3                   	ret    
  801dad:	00 00                	add    %al,(%eax)
	...

00801db0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801db0:	55                   	push   %ebp
  801db1:	89 e5                	mov    %esp,%ebp
  801db3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801db6:	e8 e5 17 00 00       	call   8035a0 <close_all>
	sys_env_destroy(0);
  801dbb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dc2:	e8 3a 0f 00 00       	call   802d01 <sys_env_destroy>
}
  801dc7:	c9                   	leave  
  801dc8:	c3                   	ret    
  801dc9:	00 00                	add    %al,(%eax)
	...

00801dcc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  801dd2:	8d 45 14             	lea    0x14(%ebp),%eax
  801dd5:	89 45 fc             	mov    %eax,-0x4(%ebp)

	// Print the panic message
	if (argv0)
  801dd8:	a1 ac c0 80 00       	mov    0x80c0ac,%eax
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	74 10                	je     801df1 <_panic+0x25>
		cprintf("%s: ", argv0);
  801de1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de5:	c7 04 24 97 45 80 00 	movl   $0x804597,(%esp)
  801dec:	e8 a8 00 00 00       	call   801e99 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  801df1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801df8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dff:	a1 64 c0 80 00       	mov    0x80c064,%eax
  801e04:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e08:	c7 04 24 9c 45 80 00 	movl   $0x80459c,(%esp)
  801e0f:	e8 85 00 00 00       	call   801e99 <cprintf>
	vcprintf(fmt, ap);
  801e14:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801e17:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e1b:	8b 45 10             	mov    0x10(%ebp),%eax
  801e1e:	89 04 24             	mov    %eax,(%esp)
  801e21:	e8 12 00 00 00       	call   801e38 <vcprintf>
	cprintf("\n");
  801e26:	c7 04 24 9f 41 80 00 	movl   $0x80419f,(%esp)
  801e2d:	e8 67 00 00 00       	call   801e99 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e32:	cc                   	int3   
  801e33:	eb fd                	jmp    801e32 <_panic+0x66>
  801e35:	00 00                	add    %al,(%eax)
	...

00801e38 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
  801e3b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801e41:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  801e48:	00 00 00 
	b.cnt = 0;
  801e4b:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  801e52:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801e55:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e58:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e63:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801e69:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6d:	c7 04 24 b6 1e 80 00 	movl   $0x801eb6,(%esp)
  801e74:	e8 cc 01 00 00       	call   802045 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801e79:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
  801e7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e83:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  801e89:	89 04 24             	mov    %eax,(%esp)
  801e8c:	e8 d7 0a 00 00       	call   802968 <sys_cputs>
  801e91:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  801e97:	c9                   	leave  
  801e98:	c3                   	ret    

00801e99 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801e99:	55                   	push   %ebp
  801e9a:	89 e5                	mov    %esp,%ebp
  801e9c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801e9f:	8d 45 0c             	lea    0xc(%ebp),%eax
  801ea2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  801ea5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea9:	8b 45 08             	mov    0x8(%ebp),%eax
  801eac:	89 04 24             	mov    %eax,(%esp)
  801eaf:	e8 84 ff ff ff       	call   801e38 <vcprintf>
	va_end(ap);

	return cnt;
}
  801eb4:	c9                   	leave  
  801eb5:	c3                   	ret    

00801eb6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801eb6:	55                   	push   %ebp
  801eb7:	89 e5                	mov    %esp,%ebp
  801eb9:	53                   	push   %ebx
  801eba:	83 ec 14             	sub    $0x14,%esp
  801ebd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801ec0:	8b 03                	mov    (%ebx),%eax
  801ec2:	8b 55 08             	mov    0x8(%ebp),%edx
  801ec5:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801ec9:	83 c0 01             	add    $0x1,%eax
  801ecc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801ece:	3d ff 00 00 00       	cmp    $0xff,%eax
  801ed3:	75 19                	jne    801eee <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801ed5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801edc:	00 
  801edd:	8d 43 08             	lea    0x8(%ebx),%eax
  801ee0:	89 04 24             	mov    %eax,(%esp)
  801ee3:	e8 80 0a 00 00       	call   802968 <sys_cputs>
		b->idx = 0;
  801ee8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801eee:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801ef2:	83 c4 14             	add    $0x14,%esp
  801ef5:	5b                   	pop    %ebx
  801ef6:	5d                   	pop    %ebp
  801ef7:	c3                   	ret    
	...

00801f00 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	57                   	push   %edi
  801f04:	56                   	push   %esi
  801f05:	53                   	push   %ebx
  801f06:	83 ec 3c             	sub    $0x3c,%esp
  801f09:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801f0c:	89 d7                	mov    %edx,%edi
  801f0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f11:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f14:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f17:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801f1a:	8b 55 10             	mov    0x10(%ebp),%edx
  801f1d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801f20:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801f23:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  801f2a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801f2d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  801f30:	72 14                	jb     801f46 <printnum+0x46>
  801f32:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801f35:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  801f38:	76 0c                	jbe    801f46 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801f3a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801f3d:	83 eb 01             	sub    $0x1,%ebx
  801f40:	85 db                	test   %ebx,%ebx
  801f42:	7f 57                	jg     801f9b <printnum+0x9b>
  801f44:	eb 64                	jmp    801faa <printnum+0xaa>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801f46:	89 74 24 10          	mov    %esi,0x10(%esp)
  801f4a:	8b 45 14             	mov    0x14(%ebp),%eax
  801f4d:	83 e8 01             	sub    $0x1,%eax
  801f50:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f54:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f58:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801f5c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801f60:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801f63:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801f66:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f6a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801f6e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801f71:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801f74:	89 04 24             	mov    %eax,(%esp)
  801f77:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f7b:	e8 20 1e 00 00       	call   803da0 <__udivdi3>
  801f80:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f84:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801f88:	89 04 24             	mov    %eax,(%esp)
  801f8b:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f8f:	89 fa                	mov    %edi,%edx
  801f91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f94:	e8 67 ff ff ff       	call   801f00 <printnum>
  801f99:	eb 0f                	jmp    801faa <printnum+0xaa>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801f9b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f9f:	89 34 24             	mov    %esi,(%esp)
  801fa2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801fa5:	83 eb 01             	sub    $0x1,%ebx
  801fa8:	75 f1                	jne    801f9b <printnum+0x9b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801faa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801fae:	8b 74 24 04          	mov    0x4(%esp),%esi
  801fb2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801fb5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801fb8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fbc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801fc0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801fc3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801fc6:	89 04 24             	mov    %eax,(%esp)
  801fc9:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fcd:	e8 fe 1e 00 00       	call   803ed0 <__umoddi3>
  801fd2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fd6:	0f be 80 b8 45 80 00 	movsbl 0x8045b8(%eax),%eax
  801fdd:	89 04 24             	mov    %eax,(%esp)
  801fe0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  801fe3:	83 c4 3c             	add    $0x3c,%esp
  801fe6:	5b                   	pop    %ebx
  801fe7:	5e                   	pop    %esi
  801fe8:	5f                   	pop    %edi
  801fe9:	5d                   	pop    %ebp
  801fea:	c3                   	ret    

00801feb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801feb:	55                   	push   %ebp
  801fec:	89 e5                	mov    %esp,%ebp
  801fee:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  801ff0:	83 fa 01             	cmp    $0x1,%edx
  801ff3:	7e 0e                	jle    802003 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  801ff5:	8b 10                	mov    (%eax),%edx
  801ff7:	8d 42 08             	lea    0x8(%edx),%eax
  801ffa:	89 01                	mov    %eax,(%ecx)
  801ffc:	8b 02                	mov    (%edx),%eax
  801ffe:	8b 52 04             	mov    0x4(%edx),%edx
  802001:	eb 22                	jmp    802025 <getuint+0x3a>
	else if (lflag)
  802003:	85 d2                	test   %edx,%edx
  802005:	74 10                	je     802017 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  802007:	8b 10                	mov    (%eax),%edx
  802009:	8d 42 04             	lea    0x4(%edx),%eax
  80200c:	89 01                	mov    %eax,(%ecx)
  80200e:	8b 02                	mov    (%edx),%eax
  802010:	ba 00 00 00 00       	mov    $0x0,%edx
  802015:	eb 0e                	jmp    802025 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  802017:	8b 10                	mov    (%eax),%edx
  802019:	8d 42 04             	lea    0x4(%edx),%eax
  80201c:	89 01                	mov    %eax,(%ecx)
  80201e:	8b 02                	mov    (%edx),%eax
  802020:	ba 00 00 00 00       	mov    $0x0,%edx
}
  802025:	5d                   	pop    %ebp
  802026:	c3                   	ret    

00802027 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  802027:	55                   	push   %ebp
  802028:	89 e5                	mov    %esp,%ebp
  80202a:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  80202d:	83 42 08 01          	addl   $0x1,0x8(%edx)
	if (b->buf < b->ebuf)
  802031:	8b 02                	mov    (%edx),%eax
  802033:	3b 42 04             	cmp    0x4(%edx),%eax
  802036:	73 0b                	jae    802043 <sprintputch+0x1c>
		*b->buf++ = ch;
  802038:	0f b6 4d 08          	movzbl 0x8(%ebp),%ecx
  80203c:	88 08                	mov    %cl,(%eax)
  80203e:	83 c0 01             	add    $0x1,%eax
  802041:	89 02                	mov    %eax,(%edx)
}
  802043:	5d                   	pop    %ebp
  802044:	c3                   	ret    

00802045 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  802045:	55                   	push   %ebp
  802046:	89 e5                	mov    %esp,%ebp
  802048:	57                   	push   %edi
  802049:	56                   	push   %esi
  80204a:	53                   	push   %ebx
  80204b:	83 ec 3c             	sub    $0x3c,%esp
  80204e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802051:	eb 18                	jmp    80206b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  802053:	84 c0                	test   %al,%al
  802055:	0f 84 9f 03 00 00    	je     8023fa <vprintfmt+0x3b5>
				return;
			putch(ch, putdat);
  80205b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80205e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802062:	0f b6 c0             	movzbl %al,%eax
  802065:	89 04 24             	mov    %eax,(%esp)
  802068:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80206b:	0f b6 03             	movzbl (%ebx),%eax
  80206e:	83 c3 01             	add    $0x1,%ebx
  802071:	3c 25                	cmp    $0x25,%al
  802073:	75 de                	jne    802053 <vprintfmt+0xe>
  802075:	b9 00 00 00 00       	mov    $0x0,%ecx
  80207a:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
  802081:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  802086:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80208d:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
  802091:	eb 07                	jmp    80209a <vprintfmt+0x55>
  802093:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80209a:	0f b6 13             	movzbl (%ebx),%edx
  80209d:	83 c3 01             	add    $0x1,%ebx
  8020a0:	8d 42 dd             	lea    -0x23(%edx),%eax
  8020a3:	3c 55                	cmp    $0x55,%al
  8020a5:	0f 87 22 03 00 00    	ja     8023cd <vprintfmt+0x388>
  8020ab:	0f b6 c0             	movzbl %al,%eax
  8020ae:	ff 24 85 00 47 80 00 	jmp    *0x804700(,%eax,4)
  8020b5:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
  8020b9:	eb df                	jmp    80209a <vprintfmt+0x55>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8020bb:	0f b6 c2             	movzbl %dl,%eax
  8020be:	8d 78 d0             	lea    -0x30(%eax),%edi
				ch = *fmt;
  8020c1:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8020c4:	8d 42 d0             	lea    -0x30(%edx),%eax
  8020c7:	83 f8 09             	cmp    $0x9,%eax
  8020ca:	76 08                	jbe    8020d4 <vprintfmt+0x8f>
  8020cc:	eb 39                	jmp    802107 <vprintfmt+0xc2>
  8020ce:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
  8020d2:	eb c6                	jmp    80209a <vprintfmt+0x55>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8020d4:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  8020d7:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  8020da:	8d 7c 42 d0          	lea    -0x30(%edx,%eax,2),%edi
				ch = *fmt;
  8020de:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8020e1:	8d 42 d0             	lea    -0x30(%edx),%eax
  8020e4:	83 f8 09             	cmp    $0x9,%eax
  8020e7:	77 1e                	ja     802107 <vprintfmt+0xc2>
  8020e9:	eb e9                	jmp    8020d4 <vprintfmt+0x8f>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8020eb:	8b 55 14             	mov    0x14(%ebp),%edx
  8020ee:	8d 42 04             	lea    0x4(%edx),%eax
  8020f1:	89 45 14             	mov    %eax,0x14(%ebp)
  8020f4:	8b 3a                	mov    (%edx),%edi
  8020f6:	eb 0f                	jmp    802107 <vprintfmt+0xc2>
			goto process_precision;

		case '.':
			if (width < 0)
  8020f8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8020fc:	79 9c                	jns    80209a <vprintfmt+0x55>
  8020fe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  802105:	eb 93                	jmp    80209a <vprintfmt+0x55>
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  802107:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80210b:	90                   	nop    
  80210c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802110:	79 88                	jns    80209a <vprintfmt+0x55>
  802112:	89 7d f0             	mov    %edi,-0x10(%ebp)
  802115:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80211a:	e9 7b ff ff ff       	jmp    80209a <vprintfmt+0x55>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80211f:	83 c1 01             	add    $0x1,%ecx
  802122:	e9 73 ff ff ff       	jmp    80209a <vprintfmt+0x55>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  802127:	8b 45 14             	mov    0x14(%ebp),%eax
  80212a:	8d 50 04             	lea    0x4(%eax),%edx
  80212d:	89 55 14             	mov    %edx,0x14(%ebp)
  802130:	8b 55 0c             	mov    0xc(%ebp),%edx
  802133:	89 54 24 04          	mov    %edx,0x4(%esp)
  802137:	8b 00                	mov    (%eax),%eax
  802139:	89 04 24             	mov    %eax,(%esp)
  80213c:	ff 55 08             	call   *0x8(%ebp)
  80213f:	e9 27 ff ff ff       	jmp    80206b <vprintfmt+0x26>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  802144:	8b 55 14             	mov    0x14(%ebp),%edx
  802147:	8d 42 04             	lea    0x4(%edx),%eax
  80214a:	89 45 14             	mov    %eax,0x14(%ebp)
  80214d:	8b 02                	mov    (%edx),%eax
  80214f:	89 c2                	mov    %eax,%edx
  802151:	c1 fa 1f             	sar    $0x1f,%edx
  802154:	31 d0                	xor    %edx,%eax
  802156:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  802158:	83 f8 0f             	cmp    $0xf,%eax
  80215b:	7f 0b                	jg     802168 <vprintfmt+0x123>
  80215d:	8b 14 85 60 48 80 00 	mov    0x804860(,%eax,4),%edx
  802164:	85 d2                	test   %edx,%edx
  802166:	75 23                	jne    80218b <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  802168:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80216c:	c7 44 24 08 c9 45 80 	movl   $0x8045c9,0x8(%esp)
  802173:	00 
  802174:	8b 45 0c             	mov    0xc(%ebp),%eax
  802177:	89 44 24 04          	mov    %eax,0x4(%esp)
  80217b:	8b 55 08             	mov    0x8(%ebp),%edx
  80217e:	89 14 24             	mov    %edx,(%esp)
  802181:	e8 ff 02 00 00       	call   802485 <printfmt>
  802186:	e9 e0 fe ff ff       	jmp    80206b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80218b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80218f:	c7 44 24 08 8f 40 80 	movl   $0x80408f,0x8(%esp)
  802196:	00 
  802197:	8b 45 0c             	mov    0xc(%ebp),%eax
  80219a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80219e:	8b 55 08             	mov    0x8(%ebp),%edx
  8021a1:	89 14 24             	mov    %edx,(%esp)
  8021a4:	e8 dc 02 00 00       	call   802485 <printfmt>
  8021a9:	e9 bd fe ff ff       	jmp    80206b <vprintfmt+0x26>
  8021ae:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8021b1:	89 f9                	mov    %edi,%ecx
  8021b3:	89 5d ec             	mov    %ebx,-0x14(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8021b6:	8b 55 14             	mov    0x14(%ebp),%edx
  8021b9:	8d 42 04             	lea    0x4(%edx),%eax
  8021bc:	89 45 14             	mov    %eax,0x14(%ebp)
  8021bf:	8b 12                	mov    (%edx),%edx
  8021c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8021c4:	85 d2                	test   %edx,%edx
  8021c6:	75 07                	jne    8021cf <vprintfmt+0x18a>
  8021c8:	c7 45 dc d2 45 80 00 	movl   $0x8045d2,-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8021cf:	85 f6                	test   %esi,%esi
  8021d1:	7e 41                	jle    802214 <vprintfmt+0x1cf>
  8021d3:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8021d7:	74 3b                	je     802214 <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
  8021d9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8021dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8021e0:	89 04 24             	mov    %eax,(%esp)
  8021e3:	e8 e8 02 00 00       	call   8024d0 <strnlen>
  8021e8:	29 c6                	sub    %eax,%esi
  8021ea:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8021ed:	85 f6                	test   %esi,%esi
  8021ef:	7e 23                	jle    802214 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8021f1:	0f be 55 eb          	movsbl -0x15(%ebp),%edx
  8021f5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8021f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
  802202:	89 14 24             	mov    %edx,(%esp)
  802205:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  802208:	83 ee 01             	sub    $0x1,%esi
  80220b:	75 eb                	jne    8021f8 <vprintfmt+0x1b3>
  80220d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  802214:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802217:	0f b6 02             	movzbl (%edx),%eax
  80221a:	0f be d0             	movsbl %al,%edx
  80221d:	8b 75 dc             	mov    -0x24(%ebp),%esi
  802220:	84 c0                	test   %al,%al
  802222:	75 42                	jne    802266 <vprintfmt+0x221>
  802224:	eb 49                	jmp    80226f <vprintfmt+0x22a>
				if (altflag && (ch < ' ' || ch > '~'))
  802226:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80222a:	74 1b                	je     802247 <vprintfmt+0x202>
  80222c:	8d 42 e0             	lea    -0x20(%edx),%eax
  80222f:	83 f8 5e             	cmp    $0x5e,%eax
  802232:	76 13                	jbe    802247 <vprintfmt+0x202>
					putch('?', putdat);
  802234:	8b 45 0c             	mov    0xc(%ebp),%eax
  802237:	89 44 24 04          	mov    %eax,0x4(%esp)
  80223b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  802242:	ff 55 08             	call   *0x8(%ebp)
  802245:	eb 0d                	jmp    802254 <vprintfmt+0x20f>
				else
					putch(ch, putdat);
  802247:	8b 45 0c             	mov    0xc(%ebp),%eax
  80224a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80224e:	89 14 24             	mov    %edx,(%esp)
  802251:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  802254:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  802258:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80225c:	83 c6 01             	add    $0x1,%esi
  80225f:	84 c0                	test   %al,%al
  802261:	74 0c                	je     80226f <vprintfmt+0x22a>
  802263:	0f be d0             	movsbl %al,%edx
  802266:	85 ff                	test   %edi,%edi
  802268:	78 bc                	js     802226 <vprintfmt+0x1e1>
  80226a:	83 ef 01             	sub    $0x1,%edi
  80226d:	79 b7                	jns    802226 <vprintfmt+0x1e1>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80226f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  802273:	0f 8e f2 fd ff ff    	jle    80206b <vprintfmt+0x26>
				putch(' ', putdat);
  802279:	8b 55 0c             	mov    0xc(%ebp),%edx
  80227c:	89 54 24 04          	mov    %edx,0x4(%esp)
  802280:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  802287:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80228a:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  80228e:	75 e9                	jne    802279 <vprintfmt+0x234>
  802290:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  802293:	e9 d3 fd ff ff       	jmp    80206b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  802298:	83 f9 01             	cmp    $0x1,%ecx
  80229b:	90                   	nop    
  80229c:	8d 74 26 00          	lea    0x0(%esi),%esi
  8022a0:	7e 10                	jle    8022b2 <vprintfmt+0x26d>
		return va_arg(*ap, long long);
  8022a2:	8b 55 14             	mov    0x14(%ebp),%edx
  8022a5:	8d 42 08             	lea    0x8(%edx),%eax
  8022a8:	89 45 14             	mov    %eax,0x14(%ebp)
  8022ab:	8b 32                	mov    (%edx),%esi
  8022ad:	8b 7a 04             	mov    0x4(%edx),%edi
  8022b0:	eb 2a                	jmp    8022dc <vprintfmt+0x297>
	else if (lflag)
  8022b2:	85 c9                	test   %ecx,%ecx
  8022b4:	74 14                	je     8022ca <vprintfmt+0x285>
		return va_arg(*ap, long);
  8022b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8022b9:	8d 50 04             	lea    0x4(%eax),%edx
  8022bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8022bf:	8b 00                	mov    (%eax),%eax
  8022c1:	89 c6                	mov    %eax,%esi
  8022c3:	89 c7                	mov    %eax,%edi
  8022c5:	c1 ff 1f             	sar    $0x1f,%edi
  8022c8:	eb 12                	jmp    8022dc <vprintfmt+0x297>
	else
		return va_arg(*ap, int);
  8022ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8022cd:	8d 50 04             	lea    0x4(%eax),%edx
  8022d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8022d3:	8b 00                	mov    (%eax),%eax
  8022d5:	89 c6                	mov    %eax,%esi
  8022d7:	89 c7                	mov    %eax,%edi
  8022d9:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8022dc:	89 f2                	mov    %esi,%edx
  8022de:	89 f9                	mov    %edi,%ecx
  8022e0:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
			if ((long long) num < 0) {
  8022e7:	85 ff                	test   %edi,%edi
  8022e9:	0f 89 9b 00 00 00    	jns    80238a <vprintfmt+0x345>
				putch('-', putdat);
  8022ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022f6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8022fd:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  802300:	89 f2                	mov    %esi,%edx
  802302:	89 f9                	mov    %edi,%ecx
  802304:	f7 da                	neg    %edx
  802306:	83 d1 00             	adc    $0x0,%ecx
  802309:	f7 d9                	neg    %ecx
  80230b:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  802312:	eb 76                	jmp    80238a <vprintfmt+0x345>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  802314:	89 ca                	mov    %ecx,%edx
  802316:	8d 45 14             	lea    0x14(%ebp),%eax
  802319:	e8 cd fc ff ff       	call   801feb <getuint>
  80231e:	89 d1                	mov    %edx,%ecx
  802320:	89 c2                	mov    %eax,%edx
  802322:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  802329:	eb 5f                	jmp    80238a <vprintfmt+0x345>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap,lflag);
  80232b:	89 ca                	mov    %ecx,%edx
  80232d:	8d 45 14             	lea    0x14(%ebp),%eax
  802330:	e8 b6 fc ff ff       	call   801feb <getuint>
  802335:	e9 31 fd ff ff       	jmp    80206b <vprintfmt+0x26>
			base=8;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80233a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80233d:	89 54 24 04          	mov    %edx,0x4(%esp)
  802341:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  802348:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80234b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80234e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802352:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  802359:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  80235c:	8b 55 14             	mov    0x14(%ebp),%edx
  80235f:	8d 42 04             	lea    0x4(%edx),%eax
  802362:	89 45 14             	mov    %eax,0x14(%ebp)
  802365:	8b 12                	mov    (%edx),%edx
  802367:	b9 00 00 00 00       	mov    $0x0,%ecx
  80236c:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  802373:	eb 15                	jmp    80238a <vprintfmt+0x345>
			base = 16;
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  802375:	89 ca                	mov    %ecx,%edx
  802377:	8d 45 14             	lea    0x14(%ebp),%eax
  80237a:	e8 6c fc ff ff       	call   801feb <getuint>
  80237f:	89 d1                	mov    %edx,%ecx
  802381:	89 c2                	mov    %eax,%edx
  802383:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80238a:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  80238e:	89 44 24 10          	mov    %eax,0x10(%esp)
  802392:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802395:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802399:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80239c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023a0:	89 14 24             	mov    %edx,(%esp)
  8023a3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8023a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ad:	e8 4e fb ff ff       	call   801f00 <printnum>
  8023b2:	e9 b4 fc ff ff       	jmp    80206b <vprintfmt+0x26>
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8023b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023ba:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023be:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8023c5:	ff 55 08             	call   *0x8(%ebp)
  8023c8:	e9 9e fc ff ff       	jmp    80206b <vprintfmt+0x26>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8023cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023d4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8023db:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8023de:	83 eb 01             	sub    $0x1,%ebx
  8023e1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8023e5:	0f 84 80 fc ff ff    	je     80206b <vprintfmt+0x26>
  8023eb:	83 eb 01             	sub    $0x1,%ebx
  8023ee:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8023f2:	0f 84 73 fc ff ff    	je     80206b <vprintfmt+0x26>
  8023f8:	eb f1                	jmp    8023eb <vprintfmt+0x3a6>
				/* do nothing */;
			break;
		}
	}
}
  8023fa:	83 c4 3c             	add    $0x3c,%esp
  8023fd:	5b                   	pop    %ebx
  8023fe:	5e                   	pop    %esi
  8023ff:	5f                   	pop    %edi
  802400:	5d                   	pop    %ebp
  802401:	c3                   	ret    

00802402 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  802402:	55                   	push   %ebp
  802403:	89 e5                	mov    %esp,%ebp
  802405:	83 ec 28             	sub    $0x28,%esp
  802408:	8b 55 08             	mov    0x8(%ebp),%edx
  80240b:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80240e:	85 d2                	test   %edx,%edx
  802410:	74 04                	je     802416 <vsnprintf+0x14>
  802412:	85 c0                	test   %eax,%eax
  802414:	7f 07                	jg     80241d <vsnprintf+0x1b>
  802416:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80241b:	eb 3b                	jmp    802458 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80241d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  802424:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
  802428:	89 45 f8             	mov    %eax,-0x8(%ebp)
  80242b:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80242e:	8b 45 14             	mov    0x14(%ebp),%eax
  802431:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802435:	8b 45 10             	mov    0x10(%ebp),%eax
  802438:	89 44 24 08          	mov    %eax,0x8(%esp)
  80243c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80243f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802443:	c7 04 24 27 20 80 00 	movl   $0x802027,(%esp)
  80244a:	e8 f6 fb ff ff       	call   802045 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80244f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802452:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  802455:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  802458:	c9                   	leave  
  802459:	c3                   	ret    

0080245a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80245a:	55                   	push   %ebp
  80245b:	89 e5                	mov    %esp,%ebp
  80245d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  802460:	8d 45 14             	lea    0x14(%ebp),%eax
  802463:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  802466:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80246a:	8b 45 10             	mov    0x10(%ebp),%eax
  80246d:	89 44 24 08          	mov    %eax,0x8(%esp)
  802471:	8b 45 0c             	mov    0xc(%ebp),%eax
  802474:	89 44 24 04          	mov    %eax,0x4(%esp)
  802478:	8b 45 08             	mov    0x8(%ebp),%eax
  80247b:	89 04 24             	mov    %eax,(%esp)
  80247e:	e8 7f ff ff ff       	call   802402 <vsnprintf>
	va_end(ap);

	return rc;
}
  802483:	c9                   	leave  
  802484:	c3                   	ret    

00802485 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  802485:	55                   	push   %ebp
  802486:	89 e5                	mov    %esp,%ebp
  802488:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  80248b:	8d 45 14             	lea    0x14(%ebp),%eax
  80248e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  802491:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802495:	8b 45 10             	mov    0x10(%ebp),%eax
  802498:	89 44 24 08          	mov    %eax,0x8(%esp)
  80249c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80249f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8024a6:	89 04 24             	mov    %eax,(%esp)
  8024a9:	e8 97 fb ff ff       	call   802045 <vprintfmt>
	va_end(ap);
}
  8024ae:	c9                   	leave  
  8024af:	c3                   	ret    

008024b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8024b0:	55                   	push   %ebp
  8024b1:	89 e5                	mov    %esp,%ebp
  8024b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8024b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8024bb:	80 3a 00             	cmpb   $0x0,(%edx)
  8024be:	74 0e                	je     8024ce <strlen+0x1e>
  8024c0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8024c5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8024c8:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8024cc:	75 f7                	jne    8024c5 <strlen+0x15>
		n++;
	return n;
}
  8024ce:	5d                   	pop    %ebp
  8024cf:	c3                   	ret    

008024d0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8024d0:	55                   	push   %ebp
  8024d1:	89 e5                	mov    %esp,%ebp
  8024d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8024d9:	85 d2                	test   %edx,%edx
  8024db:	74 19                	je     8024f6 <strnlen+0x26>
  8024dd:	80 39 00             	cmpb   $0x0,(%ecx)
  8024e0:	74 14                	je     8024f6 <strnlen+0x26>
  8024e2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8024e7:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8024ea:	39 d0                	cmp    %edx,%eax
  8024ec:	74 0d                	je     8024fb <strnlen+0x2b>
  8024ee:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  8024f2:	74 07                	je     8024fb <strnlen+0x2b>
  8024f4:	eb f1                	jmp    8024e7 <strnlen+0x17>
  8024f6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8024fb:	5d                   	pop    %ebp
  8024fc:	8d 74 26 00          	lea    0x0(%esi),%esi
  802500:	c3                   	ret    

00802501 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  802501:	55                   	push   %ebp
  802502:	89 e5                	mov    %esp,%ebp
  802504:	53                   	push   %ebx
  802505:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802508:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80250b:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80250d:	0f b6 01             	movzbl (%ecx),%eax
  802510:	88 02                	mov    %al,(%edx)
  802512:	83 c2 01             	add    $0x1,%edx
  802515:	83 c1 01             	add    $0x1,%ecx
  802518:	84 c0                	test   %al,%al
  80251a:	75 f1                	jne    80250d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80251c:	89 d8                	mov    %ebx,%eax
  80251e:	5b                   	pop    %ebx
  80251f:	5d                   	pop    %ebp
  802520:	c3                   	ret    

00802521 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802521:	55                   	push   %ebp
  802522:	89 e5                	mov    %esp,%ebp
  802524:	57                   	push   %edi
  802525:	56                   	push   %esi
  802526:	53                   	push   %ebx
  802527:	8b 7d 08             	mov    0x8(%ebp),%edi
  80252a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80252d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802530:	85 f6                	test   %esi,%esi
  802532:	74 1c                	je     802550 <strncpy+0x2f>
  802534:	89 fa                	mov    %edi,%edx
  802536:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  80253b:	0f b6 01             	movzbl (%ecx),%eax
  80253e:	88 02                	mov    %al,(%edx)
  802540:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802543:	80 39 01             	cmpb   $0x1,(%ecx)
  802546:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802549:	83 c3 01             	add    $0x1,%ebx
  80254c:	39 f3                	cmp    %esi,%ebx
  80254e:	75 eb                	jne    80253b <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  802550:	89 f8                	mov    %edi,%eax
  802552:	5b                   	pop    %ebx
  802553:	5e                   	pop    %esi
  802554:	5f                   	pop    %edi
  802555:	5d                   	pop    %ebp
  802556:	c3                   	ret    

00802557 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802557:	55                   	push   %ebp
  802558:	89 e5                	mov    %esp,%ebp
  80255a:	56                   	push   %esi
  80255b:	53                   	push   %ebx
  80255c:	8b 75 08             	mov    0x8(%ebp),%esi
  80255f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802562:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802565:	89 f0                	mov    %esi,%eax
  802567:	85 d2                	test   %edx,%edx
  802569:	74 2c                	je     802597 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  80256b:	89 d3                	mov    %edx,%ebx
  80256d:	83 eb 01             	sub    $0x1,%ebx
  802570:	74 20                	je     802592 <strlcpy+0x3b>
  802572:	0f b6 11             	movzbl (%ecx),%edx
  802575:	84 d2                	test   %dl,%dl
  802577:	74 19                	je     802592 <strlcpy+0x3b>
  802579:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  80257b:	88 10                	mov    %dl,(%eax)
  80257d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802580:	83 eb 01             	sub    $0x1,%ebx
  802583:	74 0f                	je     802594 <strlcpy+0x3d>
  802585:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  802589:	83 c1 01             	add    $0x1,%ecx
  80258c:	84 d2                	test   %dl,%dl
  80258e:	74 04                	je     802594 <strlcpy+0x3d>
  802590:	eb e9                	jmp    80257b <strlcpy+0x24>
  802592:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  802594:	c6 00 00             	movb   $0x0,(%eax)
  802597:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  802599:	5b                   	pop    %ebx
  80259a:	5e                   	pop    %esi
  80259b:	5d                   	pop    %ebp
  80259c:	c3                   	ret    

0080259d <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  80259d:	55                   	push   %ebp
  80259e:	89 e5                	mov    %esp,%ebp
  8025a0:	56                   	push   %esi
  8025a1:	53                   	push   %ebx
  8025a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8025a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025a8:	8b 55 10             	mov    0x10(%ebp),%edx
    int c;
    char *q = buf;

    if (buf_size <= 0)
  8025ab:	85 c0                	test   %eax,%eax
  8025ad:	7e 2e                	jle    8025dd <pstrcpy+0x40>
        return;

    for(;;) {
        c = *str++;
  8025af:	0f b6 0a             	movzbl (%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  8025b2:	84 c9                	test   %cl,%cl
  8025b4:	74 22                	je     8025d8 <pstrcpy+0x3b>
  8025b6:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  8025ba:	89 f0                	mov    %esi,%eax
  8025bc:	39 de                	cmp    %ebx,%esi
  8025be:	72 09                	jb     8025c9 <pstrcpy+0x2c>
  8025c0:	eb 16                	jmp    8025d8 <pstrcpy+0x3b>
  8025c2:	83 c2 01             	add    $0x1,%edx
  8025c5:	39 d8                	cmp    %ebx,%eax
  8025c7:	73 11                	jae    8025da <pstrcpy+0x3d>
            break;
        *q++ = c;
  8025c9:	88 08                	mov    %cl,(%eax)
  8025cb:	83 c0 01             	add    $0x1,%eax

    if (buf_size <= 0)
        return;

    for(;;) {
        c = *str++;
  8025ce:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  8025d2:	84 c9                	test   %cl,%cl
  8025d4:	75 ec                	jne    8025c2 <pstrcpy+0x25>
  8025d6:	eb 02                	jmp    8025da <pstrcpy+0x3d>
  8025d8:	89 f0                	mov    %esi,%eax
            break;
        *q++ = c;
    }
    *q = '\0';
  8025da:	c6 00 00             	movb   $0x0,(%eax)
}
  8025dd:	5b                   	pop    %ebx
  8025de:	5e                   	pop    %esi
  8025df:	5d                   	pop    %ebp
  8025e0:	c3                   	ret    

008025e1 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  8025e1:	55                   	push   %ebp
  8025e2:	89 e5                	mov    %esp,%ebp
  8025e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8025e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  8025ea:	0f b6 02             	movzbl (%edx),%eax
  8025ed:	84 c0                	test   %al,%al
  8025ef:	74 16                	je     802607 <strcmp+0x26>
  8025f1:	3a 01                	cmp    (%ecx),%al
  8025f3:	75 12                	jne    802607 <strcmp+0x26>
		p++, q++;
  8025f5:	83 c1 01             	add    $0x1,%ecx
    *q = '\0';
}
int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8025f8:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  8025fc:	84 c0                	test   %al,%al
  8025fe:	74 07                	je     802607 <strcmp+0x26>
  802600:	83 c2 01             	add    $0x1,%edx
  802603:	3a 01                	cmp    (%ecx),%al
  802605:	74 ee                	je     8025f5 <strcmp+0x14>
  802607:	0f b6 c0             	movzbl %al,%eax
  80260a:	0f b6 11             	movzbl (%ecx),%edx
  80260d:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80260f:	5d                   	pop    %ebp
  802610:	c3                   	ret    

00802611 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  802611:	55                   	push   %ebp
  802612:	89 e5                	mov    %esp,%ebp
  802614:	53                   	push   %ebx
  802615:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802618:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80261b:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80261e:	85 d2                	test   %edx,%edx
  802620:	74 2d                	je     80264f <strncmp+0x3e>
  802622:	0f b6 01             	movzbl (%ecx),%eax
  802625:	84 c0                	test   %al,%al
  802627:	74 1a                	je     802643 <strncmp+0x32>
  802629:	3a 03                	cmp    (%ebx),%al
  80262b:	75 16                	jne    802643 <strncmp+0x32>
  80262d:	83 ea 01             	sub    $0x1,%edx
  802630:	74 1d                	je     80264f <strncmp+0x3e>
		n--, p++, q++;
  802632:	83 c1 01             	add    $0x1,%ecx
  802635:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  802638:	0f b6 01             	movzbl (%ecx),%eax
  80263b:	84 c0                	test   %al,%al
  80263d:	74 04                	je     802643 <strncmp+0x32>
  80263f:	3a 03                	cmp    (%ebx),%al
  802641:	74 ea                	je     80262d <strncmp+0x1c>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  802643:	0f b6 11             	movzbl (%ecx),%edx
  802646:	0f b6 03             	movzbl (%ebx),%eax
  802649:	29 c2                	sub    %eax,%edx
  80264b:	89 d0                	mov    %edx,%eax
  80264d:	eb 05                	jmp    802654 <strncmp+0x43>
  80264f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802654:	5b                   	pop    %ebx
  802655:	5d                   	pop    %ebp
  802656:	c3                   	ret    

00802657 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  802657:	55                   	push   %ebp
  802658:	89 e5                	mov    %esp,%ebp
  80265a:	8b 45 08             	mov    0x8(%ebp),%eax
  80265d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802661:	0f b6 10             	movzbl (%eax),%edx
  802664:	84 d2                	test   %dl,%dl
  802666:	74 14                	je     80267c <strchr+0x25>
		if (*s == c)
  802668:	38 ca                	cmp    %cl,%dl
  80266a:	75 06                	jne    802672 <strchr+0x1b>
  80266c:	eb 13                	jmp    802681 <strchr+0x2a>
  80266e:	38 ca                	cmp    %cl,%dl
  802670:	74 0f                	je     802681 <strchr+0x2a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  802672:	83 c0 01             	add    $0x1,%eax
  802675:	0f b6 10             	movzbl (%eax),%edx
  802678:	84 d2                	test   %dl,%dl
  80267a:	75 f2                	jne    80266e <strchr+0x17>
  80267c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  802681:	5d                   	pop    %ebp
  802682:	c3                   	ret    

00802683 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  802683:	55                   	push   %ebp
  802684:	89 e5                	mov    %esp,%ebp
  802686:	8b 45 08             	mov    0x8(%ebp),%eax
  802689:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80268d:	0f b6 10             	movzbl (%eax),%edx
  802690:	84 d2                	test   %dl,%dl
  802692:	74 18                	je     8026ac <strfind+0x29>
		if (*s == c)
  802694:	38 ca                	cmp    %cl,%dl
  802696:	75 0a                	jne    8026a2 <strfind+0x1f>
  802698:	eb 12                	jmp    8026ac <strfind+0x29>
  80269a:	38 ca                	cmp    %cl,%dl
  80269c:	8d 74 26 00          	lea    0x0(%esi),%esi
  8026a0:	74 0a                	je     8026ac <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8026a2:	83 c0 01             	add    $0x1,%eax
  8026a5:	0f b6 10             	movzbl (%eax),%edx
  8026a8:	84 d2                	test   %dl,%dl
  8026aa:	75 ee                	jne    80269a <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8026ac:	5d                   	pop    %ebp
  8026ad:	c3                   	ret    

008026ae <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8026ae:	55                   	push   %ebp
  8026af:	89 e5                	mov    %esp,%ebp
  8026b1:	83 ec 08             	sub    $0x8,%esp
  8026b4:	89 1c 24             	mov    %ebx,(%esp)
  8026b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8026bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8026be:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  8026c1:	85 db                	test   %ebx,%ebx
  8026c3:	74 36                	je     8026fb <memset+0x4d>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8026c5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8026cb:	75 26                	jne    8026f3 <memset+0x45>
  8026cd:	f6 c3 03             	test   $0x3,%bl
  8026d0:	75 21                	jne    8026f3 <memset+0x45>
		c &= 0xFF;
  8026d2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8026d6:	89 d0                	mov    %edx,%eax
  8026d8:	c1 e0 18             	shl    $0x18,%eax
  8026db:	89 d1                	mov    %edx,%ecx
  8026dd:	c1 e1 10             	shl    $0x10,%ecx
  8026e0:	09 c8                	or     %ecx,%eax
  8026e2:	09 d0                	or     %edx,%eax
  8026e4:	c1 e2 08             	shl    $0x8,%edx
  8026e7:	09 d0                	or     %edx,%eax
  8026e9:	89 d9                	mov    %ebx,%ecx
  8026eb:	c1 e9 02             	shr    $0x2,%ecx
  8026ee:	fc                   	cld    
  8026ef:	f3 ab                	rep stos %eax,%es:(%edi)
  8026f1:	eb 08                	jmp    8026fb <memset+0x4d>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8026f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026f6:	89 d9                	mov    %ebx,%ecx
  8026f8:	fc                   	cld    
  8026f9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8026fb:	89 f8                	mov    %edi,%eax
  8026fd:	8b 1c 24             	mov    (%esp),%ebx
  802700:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802704:	89 ec                	mov    %ebp,%esp
  802706:	5d                   	pop    %ebp
  802707:	c3                   	ret    

00802708 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802708:	55                   	push   %ebp
  802709:	89 e5                	mov    %esp,%ebp
  80270b:	83 ec 08             	sub    $0x8,%esp
  80270e:	89 34 24             	mov    %esi,(%esp)
  802711:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802715:	8b 45 08             	mov    0x8(%ebp),%eax
  802718:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  80271b:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80271e:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  802720:	39 c6                	cmp    %eax,%esi
  802722:	73 38                	jae    80275c <memmove+0x54>
  802724:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802727:	39 d0                	cmp    %edx,%eax
  802729:	73 31                	jae    80275c <memmove+0x54>
		s += n;
		d += n;
  80272b:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80272e:	f6 c2 03             	test   $0x3,%dl
  802731:	75 1d                	jne    802750 <memmove+0x48>
  802733:	f7 c6 03 00 00 00    	test   $0x3,%esi
  802739:	75 15                	jne    802750 <memmove+0x48>
  80273b:	f6 c1 03             	test   $0x3,%cl
  80273e:	66 90                	xchg   %ax,%ax
  802740:	75 0e                	jne    802750 <memmove+0x48>
			asm volatile("std; rep movsl\n"
  802742:	8d 7e fc             	lea    -0x4(%esi),%edi
  802745:	8d 72 fc             	lea    -0x4(%edx),%esi
  802748:	c1 e9 02             	shr    $0x2,%ecx
  80274b:	fd                   	std    
  80274c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80274e:	eb 09                	jmp    802759 <memmove+0x51>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  802750:	8d 7e ff             	lea    -0x1(%esi),%edi
  802753:	8d 72 ff             	lea    -0x1(%edx),%esi
  802756:	fd                   	std    
  802757:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  802759:	fc                   	cld    
  80275a:	eb 21                	jmp    80277d <memmove+0x75>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80275c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  802762:	75 16                	jne    80277a <memmove+0x72>
  802764:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80276a:	75 0e                	jne    80277a <memmove+0x72>
  80276c:	f6 c1 03             	test   $0x3,%cl
  80276f:	90                   	nop    
  802770:	75 08                	jne    80277a <memmove+0x72>
			asm volatile("cld; rep movsl\n"
  802772:	c1 e9 02             	shr    $0x2,%ecx
  802775:	fc                   	cld    
  802776:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802778:	eb 03                	jmp    80277d <memmove+0x75>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80277a:	fc                   	cld    
  80277b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80277d:	8b 34 24             	mov    (%esp),%esi
  802780:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802784:	89 ec                	mov    %ebp,%esp
  802786:	5d                   	pop    %ebp
  802787:	c3                   	ret    

00802788 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  802788:	55                   	push   %ebp
  802789:	89 e5                	mov    %esp,%ebp
  80278b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80278e:	8b 45 10             	mov    0x10(%ebp),%eax
  802791:	89 44 24 08          	mov    %eax,0x8(%esp)
  802795:	8b 45 0c             	mov    0xc(%ebp),%eax
  802798:	89 44 24 04          	mov    %eax,0x4(%esp)
  80279c:	8b 45 08             	mov    0x8(%ebp),%eax
  80279f:	89 04 24             	mov    %eax,(%esp)
  8027a2:	e8 61 ff ff ff       	call   802708 <memmove>
}
  8027a7:	c9                   	leave  
  8027a8:	c3                   	ret    

008027a9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8027a9:	55                   	push   %ebp
  8027aa:	89 e5                	mov    %esp,%ebp
  8027ac:	57                   	push   %edi
  8027ad:	56                   	push   %esi
  8027ae:	53                   	push   %ebx
  8027af:	83 ec 04             	sub    $0x4,%esp
  8027b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8027b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8027b8:	8b 55 10             	mov    0x10(%ebp),%edx
  8027bb:	83 ea 01             	sub    $0x1,%edx
  8027be:	83 fa ff             	cmp    $0xffffffff,%edx
  8027c1:	74 47                	je     80280a <memcmp+0x61>
		if (*s1 != *s2)
  8027c3:	0f b6 30             	movzbl (%eax),%esi
  8027c6:	0f b6 39             	movzbl (%ecx),%edi
			return (int) *s1 - (int) *s2;
  8027c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  8027cc:	89 f0                	mov    %esi,%eax
  8027ce:	89 fb                	mov    %edi,%ebx
  8027d0:	38 d8                	cmp    %bl,%al
  8027d2:	74 2e                	je     802802 <memcmp+0x59>
  8027d4:	eb 1c                	jmp    8027f2 <memcmp+0x49>
  8027d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8027d9:	0f b6 70 01          	movzbl 0x1(%eax),%esi
  8027dd:	0f b6 79 01          	movzbl 0x1(%ecx),%edi
  8027e1:	83 c0 01             	add    $0x1,%eax
  8027e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8027e7:	83 c1 01             	add    $0x1,%ecx
  8027ea:	89 f3                	mov    %esi,%ebx
  8027ec:	89 f8                	mov    %edi,%eax
  8027ee:	38 c3                	cmp    %al,%bl
  8027f0:	74 10                	je     802802 <memcmp+0x59>
			return (int) *s1 - (int) *s2;
  8027f2:	89 f1                	mov    %esi,%ecx
  8027f4:	0f b6 d1             	movzbl %cl,%edx
  8027f7:	89 fb                	mov    %edi,%ebx
  8027f9:	0f b6 c3             	movzbl %bl,%eax
  8027fc:	29 c2                	sub    %eax,%edx
  8027fe:	89 d0                	mov    %edx,%eax
  802800:	eb 0d                	jmp    80280f <memcmp+0x66>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802802:	83 ea 01             	sub    $0x1,%edx
  802805:	83 fa ff             	cmp    $0xffffffff,%edx
  802808:	75 cc                	jne    8027d6 <memcmp+0x2d>
  80280a:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  80280f:	83 c4 04             	add    $0x4,%esp
  802812:	5b                   	pop    %ebx
  802813:	5e                   	pop    %esi
  802814:	5f                   	pop    %edi
  802815:	5d                   	pop    %ebp
  802816:	c3                   	ret    

00802817 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802817:	55                   	push   %ebp
  802818:	89 e5                	mov    %esp,%ebp
  80281a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80281d:	89 c1                	mov    %eax,%ecx
  80281f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
  802822:	39 c8                	cmp    %ecx,%eax
  802824:	73 15                	jae    80283b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  802826:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
  80282a:	38 10                	cmp    %dl,(%eax)
  80282c:	75 06                	jne    802834 <memfind+0x1d>
  80282e:	eb 0b                	jmp    80283b <memfind+0x24>
  802830:	38 10                	cmp    %dl,(%eax)
  802832:	74 07                	je     80283b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802834:	83 c0 01             	add    $0x1,%eax
  802837:	39 c8                	cmp    %ecx,%eax
  802839:	75 f5                	jne    802830 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80283b:	5d                   	pop    %ebp
  80283c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802840:	c3                   	ret    

00802841 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802841:	55                   	push   %ebp
  802842:	89 e5                	mov    %esp,%ebp
  802844:	57                   	push   %edi
  802845:	56                   	push   %esi
  802846:	53                   	push   %ebx
  802847:	83 ec 04             	sub    $0x4,%esp
  80284a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80284d:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802850:	0f b6 01             	movzbl (%ecx),%eax
  802853:	3c 20                	cmp    $0x20,%al
  802855:	74 04                	je     80285b <strtol+0x1a>
  802857:	3c 09                	cmp    $0x9,%al
  802859:	75 0e                	jne    802869 <strtol+0x28>
		s++;
  80285b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80285e:	0f b6 01             	movzbl (%ecx),%eax
  802861:	3c 20                	cmp    $0x20,%al
  802863:	74 f6                	je     80285b <strtol+0x1a>
  802865:	3c 09                	cmp    $0x9,%al
  802867:	74 f2                	je     80285b <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  802869:	3c 2b                	cmp    $0x2b,%al
  80286b:	75 0c                	jne    802879 <strtol+0x38>
		s++;
  80286d:	83 c1 01             	add    $0x1,%ecx
  802870:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  802877:	eb 15                	jmp    80288e <strtol+0x4d>
	else if (*s == '-')
  802879:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  802880:	3c 2d                	cmp    $0x2d,%al
  802882:	75 0a                	jne    80288e <strtol+0x4d>
		s++, neg = 1;
  802884:	83 c1 01             	add    $0x1,%ecx
  802887:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80288e:	85 f6                	test   %esi,%esi
  802890:	0f 94 c0             	sete   %al
  802893:	74 05                	je     80289a <strtol+0x59>
  802895:	83 fe 10             	cmp    $0x10,%esi
  802898:	75 18                	jne    8028b2 <strtol+0x71>
  80289a:	80 39 30             	cmpb   $0x30,(%ecx)
  80289d:	75 13                	jne    8028b2 <strtol+0x71>
  80289f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8028a3:	75 0d                	jne    8028b2 <strtol+0x71>
		s += 2, base = 16;
  8028a5:	83 c1 02             	add    $0x2,%ecx
  8028a8:	be 10 00 00 00       	mov    $0x10,%esi
  8028ad:	8d 76 00             	lea    0x0(%esi),%esi
  8028b0:	eb 1b                	jmp    8028cd <strtol+0x8c>
	else if (base == 0 && s[0] == '0')
  8028b2:	85 f6                	test   %esi,%esi
  8028b4:	75 0e                	jne    8028c4 <strtol+0x83>
  8028b6:	80 39 30             	cmpb   $0x30,(%ecx)
  8028b9:	75 09                	jne    8028c4 <strtol+0x83>
		s++, base = 8;
  8028bb:	83 c1 01             	add    $0x1,%ecx
  8028be:	66 be 08 00          	mov    $0x8,%si
  8028c2:	eb 09                	jmp    8028cd <strtol+0x8c>
	else if (base == 0)
  8028c4:	84 c0                	test   %al,%al
  8028c6:	74 05                	je     8028cd <strtol+0x8c>
  8028c8:	be 0a 00 00 00       	mov    $0xa,%esi
  8028cd:	bf 00 00 00 00       	mov    $0x0,%edi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8028d2:	0f b6 11             	movzbl (%ecx),%edx
  8028d5:	89 d3                	mov    %edx,%ebx
  8028d7:	8d 42 d0             	lea    -0x30(%edx),%eax
  8028da:	3c 09                	cmp    $0x9,%al
  8028dc:	77 08                	ja     8028e6 <strtol+0xa5>
			dig = *s - '0';
  8028de:	0f be c2             	movsbl %dl,%eax
  8028e1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8028e4:	eb 1c                	jmp    802902 <strtol+0xc1>
		else if (*s >= 'a' && *s <= 'z')
  8028e6:	8d 43 9f             	lea    -0x61(%ebx),%eax
  8028e9:	3c 19                	cmp    $0x19,%al
  8028eb:	77 08                	ja     8028f5 <strtol+0xb4>
			dig = *s - 'a' + 10;
  8028ed:	0f be c2             	movsbl %dl,%eax
  8028f0:	8d 50 a9             	lea    -0x57(%eax),%edx
  8028f3:	eb 0d                	jmp    802902 <strtol+0xc1>
		else if (*s >= 'A' && *s <= 'Z')
  8028f5:	8d 43 bf             	lea    -0x41(%ebx),%eax
  8028f8:	3c 19                	cmp    $0x19,%al
  8028fa:	77 17                	ja     802913 <strtol+0xd2>
			dig = *s - 'A' + 10;
  8028fc:	0f be c2             	movsbl %dl,%eax
  8028ff:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  802902:	39 f2                	cmp    %esi,%edx
  802904:	7d 0d                	jge    802913 <strtol+0xd2>
			break;
		s++, val = (val * base) + dig;
  802906:	83 c1 01             	add    $0x1,%ecx
  802909:	89 f8                	mov    %edi,%eax
  80290b:	0f af c6             	imul   %esi,%eax
  80290e:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  802911:	eb bf                	jmp    8028d2 <strtol+0x91>
		// we don't properly detect overflow!
	}
  802913:	89 f8                	mov    %edi,%eax

	if (endptr)
  802915:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802919:	74 05                	je     802920 <strtol+0xdf>
		*endptr = (char *) s;
  80291b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80291e:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  802920:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  802924:	74 04                	je     80292a <strtol+0xe9>
  802926:	89 c7                	mov    %eax,%edi
  802928:	f7 df                	neg    %edi
}
  80292a:	89 f8                	mov    %edi,%eax
  80292c:	83 c4 04             	add    $0x4,%esp
  80292f:	5b                   	pop    %ebx
  802930:	5e                   	pop    %esi
  802931:	5f                   	pop    %edi
  802932:	5d                   	pop    %ebp
  802933:	c3                   	ret    

00802934 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  802934:	55                   	push   %ebp
  802935:	89 e5                	mov    %esp,%ebp
  802937:	83 ec 0c             	sub    $0xc,%esp
  80293a:	89 1c 24             	mov    %ebx,(%esp)
  80293d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802941:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802945:	b8 01 00 00 00       	mov    $0x1,%eax
  80294a:	bf 00 00 00 00       	mov    $0x0,%edi
  80294f:	89 fa                	mov    %edi,%edx
  802951:	89 f9                	mov    %edi,%ecx
  802953:	89 fb                	mov    %edi,%ebx
  802955:	89 fe                	mov    %edi,%esi
  802957:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  802959:	8b 1c 24             	mov    (%esp),%ebx
  80295c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802960:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802964:	89 ec                	mov    %ebp,%esp
  802966:	5d                   	pop    %ebp
  802967:	c3                   	ret    

00802968 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802968:	55                   	push   %ebp
  802969:	89 e5                	mov    %esp,%ebp
  80296b:	83 ec 0c             	sub    $0xc,%esp
  80296e:	89 1c 24             	mov    %ebx,(%esp)
  802971:	89 74 24 04          	mov    %esi,0x4(%esp)
  802975:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802979:	8b 55 08             	mov    0x8(%ebp),%edx
  80297c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80297f:	bf 00 00 00 00       	mov    $0x0,%edi
  802984:	89 f8                	mov    %edi,%eax
  802986:	89 fb                	mov    %edi,%ebx
  802988:	89 fe                	mov    %edi,%esi
  80298a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80298c:	8b 1c 24             	mov    (%esp),%ebx
  80298f:	8b 74 24 04          	mov    0x4(%esp),%esi
  802993:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802997:	89 ec                	mov    %ebp,%esp
  802999:	5d                   	pop    %ebp
  80299a:	c3                   	ret    

0080299b <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  80299b:	55                   	push   %ebp
  80299c:	89 e5                	mov    %esp,%ebp
  80299e:	83 ec 0c             	sub    $0xc,%esp
  8029a1:	89 1c 24             	mov    %ebx,(%esp)
  8029a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029a8:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8029ac:	b8 0e 00 00 00       	mov    $0xe,%eax
  8029b1:	bf 00 00 00 00       	mov    $0x0,%edi
  8029b6:	89 fa                	mov    %edi,%edx
  8029b8:	89 f9                	mov    %edi,%ecx
  8029ba:	89 fb                	mov    %edi,%ebx
  8029bc:	89 fe                	mov    %edi,%esi
  8029be:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8029c0:	8b 1c 24             	mov    (%esp),%ebx
  8029c3:	8b 74 24 04          	mov    0x4(%esp),%esi
  8029c7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8029cb:	89 ec                	mov    %ebp,%esp
  8029cd:	5d                   	pop    %ebp
  8029ce:	c3                   	ret    

008029cf <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8029cf:	55                   	push   %ebp
  8029d0:	89 e5                	mov    %esp,%ebp
  8029d2:	83 ec 28             	sub    $0x28,%esp
  8029d5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8029d8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8029db:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8029de:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8029e1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8029e6:	bf 00 00 00 00       	mov    $0x0,%edi
  8029eb:	89 f9                	mov    %edi,%ecx
  8029ed:	89 fb                	mov    %edi,%ebx
  8029ef:	89 fe                	mov    %edi,%esi
  8029f1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8029f3:	85 c0                	test   %eax,%eax
  8029f5:	7e 28                	jle    802a1f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8029f7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8029fb:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  802a02:	00 
  802a03:	c7 44 24 08 bf 48 80 	movl   $0x8048bf,0x8(%esp)
  802a0a:	00 
  802a0b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802a12:	00 
  802a13:	c7 04 24 dc 48 80 00 	movl   $0x8048dc,(%esp)
  802a1a:	e8 ad f3 ff ff       	call   801dcc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  802a1f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802a22:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802a25:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802a28:	89 ec                	mov    %ebp,%esp
  802a2a:	5d                   	pop    %ebp
  802a2b:	c3                   	ret    

00802a2c <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802a2c:	55                   	push   %ebp
  802a2d:	89 e5                	mov    %esp,%ebp
  802a2f:	83 ec 0c             	sub    $0xc,%esp
  802a32:	89 1c 24             	mov    %ebx,(%esp)
  802a35:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a39:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802a3d:	8b 55 08             	mov    0x8(%ebp),%edx
  802a40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a43:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802a46:	8b 7d 14             	mov    0x14(%ebp),%edi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802a49:	b8 0c 00 00 00       	mov    $0xc,%eax
  802a4e:	be 00 00 00 00       	mov    $0x0,%esi
  802a53:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  802a55:	8b 1c 24             	mov    (%esp),%ebx
  802a58:	8b 74 24 04          	mov    0x4(%esp),%esi
  802a5c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802a60:	89 ec                	mov    %ebp,%esp
  802a62:	5d                   	pop    %ebp
  802a63:	c3                   	ret    

00802a64 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802a64:	55                   	push   %ebp
  802a65:	89 e5                	mov    %esp,%ebp
  802a67:	83 ec 28             	sub    $0x28,%esp
  802a6a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802a6d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802a70:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802a73:	8b 55 08             	mov    0x8(%ebp),%edx
  802a76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802a79:	b8 0a 00 00 00       	mov    $0xa,%eax
  802a7e:	bf 00 00 00 00       	mov    $0x0,%edi
  802a83:	89 fb                	mov    %edi,%ebx
  802a85:	89 fe                	mov    %edi,%esi
  802a87:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  802a89:	85 c0                	test   %eax,%eax
  802a8b:	7e 28                	jle    802ab5 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  802a8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  802a91:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  802a98:	00 
  802a99:	c7 44 24 08 bf 48 80 	movl   $0x8048bf,0x8(%esp)
  802aa0:	00 
  802aa1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802aa8:	00 
  802aa9:	c7 04 24 dc 48 80 00 	movl   $0x8048dc,(%esp)
  802ab0:	e8 17 f3 ff ff       	call   801dcc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802ab5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802ab8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802abb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802abe:	89 ec                	mov    %ebp,%esp
  802ac0:	5d                   	pop    %ebp
  802ac1:	c3                   	ret    

00802ac2 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802ac2:	55                   	push   %ebp
  802ac3:	89 e5                	mov    %esp,%ebp
  802ac5:	83 ec 28             	sub    $0x28,%esp
  802ac8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802acb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802ace:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802ad1:	8b 55 08             	mov    0x8(%ebp),%edx
  802ad4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802ad7:	b8 09 00 00 00       	mov    $0x9,%eax
  802adc:	bf 00 00 00 00       	mov    $0x0,%edi
  802ae1:	89 fb                	mov    %edi,%ebx
  802ae3:	89 fe                	mov    %edi,%esi
  802ae5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  802ae7:	85 c0                	test   %eax,%eax
  802ae9:	7e 28                	jle    802b13 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  802aeb:	89 44 24 10          	mov    %eax,0x10(%esp)
  802aef:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  802af6:	00 
  802af7:	c7 44 24 08 bf 48 80 	movl   $0x8048bf,0x8(%esp)
  802afe:	00 
  802aff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802b06:	00 
  802b07:	c7 04 24 dc 48 80 00 	movl   $0x8048dc,(%esp)
  802b0e:	e8 b9 f2 ff ff       	call   801dcc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  802b13:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802b16:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802b19:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802b1c:	89 ec                	mov    %ebp,%esp
  802b1e:	5d                   	pop    %ebp
  802b1f:	c3                   	ret    

00802b20 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  802b20:	55                   	push   %ebp
  802b21:	89 e5                	mov    %esp,%ebp
  802b23:	83 ec 28             	sub    $0x28,%esp
  802b26:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802b29:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802b2c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802b2f:	8b 55 08             	mov    0x8(%ebp),%edx
  802b32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802b35:	b8 08 00 00 00       	mov    $0x8,%eax
  802b3a:	bf 00 00 00 00       	mov    $0x0,%edi
  802b3f:	89 fb                	mov    %edi,%ebx
  802b41:	89 fe                	mov    %edi,%esi
  802b43:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  802b45:	85 c0                	test   %eax,%eax
  802b47:	7e 28                	jle    802b71 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  802b49:	89 44 24 10          	mov    %eax,0x10(%esp)
  802b4d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  802b54:	00 
  802b55:	c7 44 24 08 bf 48 80 	movl   $0x8048bf,0x8(%esp)
  802b5c:	00 
  802b5d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802b64:	00 
  802b65:	c7 04 24 dc 48 80 00 	movl   $0x8048dc,(%esp)
  802b6c:	e8 5b f2 ff ff       	call   801dcc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  802b71:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802b74:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802b77:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802b7a:	89 ec                	mov    %ebp,%esp
  802b7c:	5d                   	pop    %ebp
  802b7d:	c3                   	ret    

00802b7e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  802b7e:	55                   	push   %ebp
  802b7f:	89 e5                	mov    %esp,%ebp
  802b81:	83 ec 28             	sub    $0x28,%esp
  802b84:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802b87:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802b8a:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802b8d:	8b 55 08             	mov    0x8(%ebp),%edx
  802b90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802b93:	b8 06 00 00 00       	mov    $0x6,%eax
  802b98:	bf 00 00 00 00       	mov    $0x0,%edi
  802b9d:	89 fb                	mov    %edi,%ebx
  802b9f:	89 fe                	mov    %edi,%esi
  802ba1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  802ba3:	85 c0                	test   %eax,%eax
  802ba5:	7e 28                	jle    802bcf <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  802ba7:	89 44 24 10          	mov    %eax,0x10(%esp)
  802bab:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  802bb2:	00 
  802bb3:	c7 44 24 08 bf 48 80 	movl   $0x8048bf,0x8(%esp)
  802bba:	00 
  802bbb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802bc2:	00 
  802bc3:	c7 04 24 dc 48 80 00 	movl   $0x8048dc,(%esp)
  802bca:	e8 fd f1 ff ff       	call   801dcc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  802bcf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802bd2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802bd5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802bd8:	89 ec                	mov    %ebp,%esp
  802bda:	5d                   	pop    %ebp
  802bdb:	c3                   	ret    

00802bdc <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  802bdc:	55                   	push   %ebp
  802bdd:	89 e5                	mov    %esp,%ebp
  802bdf:	83 ec 28             	sub    $0x28,%esp
  802be2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802be5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802be8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802beb:	8b 55 08             	mov    0x8(%ebp),%edx
  802bee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802bf1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802bf4:	8b 7d 14             	mov    0x14(%ebp),%edi
  802bf7:	8b 75 18             	mov    0x18(%ebp),%esi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802bfa:	b8 05 00 00 00       	mov    $0x5,%eax
  802bff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  802c01:	85 c0                	test   %eax,%eax
  802c03:	7e 28                	jle    802c2d <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  802c05:	89 44 24 10          	mov    %eax,0x10(%esp)
  802c09:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  802c10:	00 
  802c11:	c7 44 24 08 bf 48 80 	movl   $0x8048bf,0x8(%esp)
  802c18:	00 
  802c19:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802c20:	00 
  802c21:	c7 04 24 dc 48 80 00 	movl   $0x8048dc,(%esp)
  802c28:	e8 9f f1 ff ff       	call   801dcc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802c2d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802c30:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802c33:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802c36:	89 ec                	mov    %ebp,%esp
  802c38:	5d                   	pop    %ebp
  802c39:	c3                   	ret    

00802c3a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802c3a:	55                   	push   %ebp
  802c3b:	89 e5                	mov    %esp,%ebp
  802c3d:	83 ec 28             	sub    $0x28,%esp
  802c40:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802c43:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802c46:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802c49:	8b 55 08             	mov    0x8(%ebp),%edx
  802c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802c52:	b8 04 00 00 00       	mov    $0x4,%eax
  802c57:	bf 00 00 00 00       	mov    $0x0,%edi
  802c5c:	89 fe                	mov    %edi,%esi
  802c5e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  802c60:	85 c0                	test   %eax,%eax
  802c62:	7e 28                	jle    802c8c <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  802c64:	89 44 24 10          	mov    %eax,0x10(%esp)
  802c68:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  802c6f:	00 
  802c70:	c7 44 24 08 bf 48 80 	movl   $0x8048bf,0x8(%esp)
  802c77:	00 
  802c78:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802c7f:	00 
  802c80:	c7 04 24 dc 48 80 00 	movl   $0x8048dc,(%esp)
  802c87:	e8 40 f1 ff ff       	call   801dcc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  802c8c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802c8f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802c92:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802c95:	89 ec                	mov    %ebp,%esp
  802c97:	5d                   	pop    %ebp
  802c98:	c3                   	ret    

00802c99 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  802c99:	55                   	push   %ebp
  802c9a:	89 e5                	mov    %esp,%ebp
  802c9c:	83 ec 0c             	sub    $0xc,%esp
  802c9f:	89 1c 24             	mov    %ebx,(%esp)
  802ca2:	89 74 24 04          	mov    %esi,0x4(%esp)
  802ca6:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802caa:	b8 0b 00 00 00       	mov    $0xb,%eax
  802caf:	bf 00 00 00 00       	mov    $0x0,%edi
  802cb4:	89 fa                	mov    %edi,%edx
  802cb6:	89 f9                	mov    %edi,%ecx
  802cb8:	89 fb                	mov    %edi,%ebx
  802cba:	89 fe                	mov    %edi,%esi
  802cbc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  802cbe:	8b 1c 24             	mov    (%esp),%ebx
  802cc1:	8b 74 24 04          	mov    0x4(%esp),%esi
  802cc5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802cc9:	89 ec                	mov    %ebp,%esp
  802ccb:	5d                   	pop    %ebp
  802ccc:	c3                   	ret    

00802ccd <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  802ccd:	55                   	push   %ebp
  802cce:	89 e5                	mov    %esp,%ebp
  802cd0:	83 ec 0c             	sub    $0xc,%esp
  802cd3:	89 1c 24             	mov    %ebx,(%esp)
  802cd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  802cda:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802cde:	b8 02 00 00 00       	mov    $0x2,%eax
  802ce3:	bf 00 00 00 00       	mov    $0x0,%edi
  802ce8:	89 fa                	mov    %edi,%edx
  802cea:	89 f9                	mov    %edi,%ecx
  802cec:	89 fb                	mov    %edi,%ebx
  802cee:	89 fe                	mov    %edi,%esi
  802cf0:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  802cf2:	8b 1c 24             	mov    (%esp),%ebx
  802cf5:	8b 74 24 04          	mov    0x4(%esp),%esi
  802cf9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802cfd:	89 ec                	mov    %ebp,%esp
  802cff:	5d                   	pop    %ebp
  802d00:	c3                   	ret    

00802d01 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  802d01:	55                   	push   %ebp
  802d02:	89 e5                	mov    %esp,%ebp
  802d04:	83 ec 28             	sub    $0x28,%esp
  802d07:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802d0a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802d0d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802d10:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802d13:	b8 03 00 00 00       	mov    $0x3,%eax
  802d18:	bf 00 00 00 00       	mov    $0x0,%edi
  802d1d:	89 f9                	mov    %edi,%ecx
  802d1f:	89 fb                	mov    %edi,%ebx
  802d21:	89 fe                	mov    %edi,%esi
  802d23:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  802d25:	85 c0                	test   %eax,%eax
  802d27:	7e 28                	jle    802d51 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  802d29:	89 44 24 10          	mov    %eax,0x10(%esp)
  802d2d:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  802d34:	00 
  802d35:	c7 44 24 08 bf 48 80 	movl   $0x8048bf,0x8(%esp)
  802d3c:	00 
  802d3d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802d44:	00 
  802d45:	c7 04 24 dc 48 80 00 	movl   $0x8048dc,(%esp)
  802d4c:	e8 7b f0 ff ff       	call   801dcc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  802d51:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802d54:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802d57:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802d5a:	89 ec                	mov    %ebp,%esp
  802d5c:	5d                   	pop    %ebp
  802d5d:	c3                   	ret    
	...

00802d60 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802d60:	55                   	push   %ebp
  802d61:	89 e5                	mov    %esp,%ebp
  802d63:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802d66:	83 3d b0 c0 80 00 00 	cmpl   $0x0,0x80c0b0
  802d6d:	75 6a                	jne    802dd9 <set_pgfault_handler+0x79>
		// First time through!
		// LAB 4: Your code here.
		env=(struct Env*)&envs[ENVX(sys_getenvid())];
  802d6f:	e8 59 ff ff ff       	call   802ccd <sys_getenvid>
  802d74:	25 ff 03 00 00       	and    $0x3ff,%eax
  802d79:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802d7c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802d81:	a3 a8 c0 80 00       	mov    %eax,0x80c0a8
		if((r=sys_page_alloc(env->env_id,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  802d86:	8b 40 4c             	mov    0x4c(%eax),%eax
  802d89:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802d90:	00 
  802d91:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802d98:	ee 
  802d99:	89 04 24             	mov    %eax,(%esp)
  802d9c:	e8 99 fe ff ff       	call   802c3a <sys_page_alloc>
  802da1:	85 c0                	test   %eax,%eax
  802da3:	79 1c                	jns    802dc1 <set_pgfault_handler+0x61>
		{
			panic("Alloc a page for an exception stack failed");
  802da5:	c7 44 24 08 ec 48 80 	movl   $0x8048ec,0x8(%esp)
  802dac:	00 
  802dad:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802db4:	00 
  802db5:	c7 04 24 17 49 80 00 	movl   $0x804917,(%esp)
  802dbc:	e8 0b f0 ff ff       	call   801dcc <_panic>
		}
		sys_env_set_pgfault_upcall(env->env_id,(void*)_pgfault_upcall);
  802dc1:	a1 a8 c0 80 00       	mov    0x80c0a8,%eax
  802dc6:	8b 40 4c             	mov    0x4c(%eax),%eax
  802dc9:	c7 44 24 04 e4 2d 80 	movl   $0x802de4,0x4(%esp)
  802dd0:	00 
  802dd1:	89 04 24             	mov    %eax,(%esp)
  802dd4:	e8 8b fc ff ff       	call   802a64 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  802ddc:	a3 b0 c0 80 00       	mov    %eax,0x80c0b0
}
  802de1:	c9                   	leave  
  802de2:	c3                   	ret    
	...

00802de4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802de4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802de5:	a1 b0 c0 80 00       	mov    0x80c0b0,%eax
	call *%eax
  802dea:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802dec:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.这个有点难度，需要认真编写
	movl  0x28(%esp),%eax //把utf->utf_eip入栈
  802def:	8b 44 24 28          	mov    0x28(%esp),%eax
	pushl %eax
  802df3:	50                   	push   %eax
	movl %esp,%eax
  802df4:	89 e0                	mov    %esp,%eax
	movl 0x34(%eax),%esp  //切换到用户普通栈，压入utf_eip
  802df6:	8b 60 34             	mov    0x34(%eax),%esp
	pushl (%eax)
  802df9:	ff 30                	pushl  (%eax)
	movl %eax,%esp	     //切到用户异常栈
  802dfb:	89 c4                	mov    %eax,%esp
	subl $0x4,0x34(%esp) //将utf->utf_esp减去4,指向返回地址,后面不能算术操作，就在这算
  802dfd:	83 6c 24 34 04       	subl   $0x4,0x34(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0xc,%esp     //恢复通用寄存器
  802e02:	83 c4 0c             	add    $0xc,%esp
	popal
  802e05:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp  //恢复eflags
  802e06:	83 c4 04             	add    $0x4,%esp
	popfl          //在用户态，该指令能否修改eflags?可以的
  802e09:	9d                   	popf   
		       //执行完这个指令后，不能进行算术任何算术运算哦，否则eflags里面的值不对
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp     //切换到用户普通栈，用户从异常处理退出后，需要继续使用该栈
  802e0a:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802e0b:	c3                   	ret    
  802e0c:	00 00                	add    %al,(%eax)
	...

00802e10 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802e10:	55                   	push   %ebp
  802e11:	89 e5                	mov    %esp,%ebp
  802e13:	57                   	push   %edi
  802e14:	56                   	push   %esi
  802e15:	53                   	push   %ebx
  802e16:	83 ec 1c             	sub    $0x1c,%esp
  802e19:	8b 75 08             	mov    0x8(%ebp),%esi
  802e1c:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  802e1f:	e8 a9 fe ff ff       	call   802ccd <sys_getenvid>
  802e24:	25 ff 03 00 00       	and    $0x3ff,%eax
  802e29:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802e2c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802e31:	a3 a8 c0 80 00       	mov    %eax,0x80c0a8
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  802e36:	e8 92 fe ff ff       	call   802ccd <sys_getenvid>
  802e3b:	25 ff 03 00 00       	and    $0x3ff,%eax
  802e40:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802e43:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802e48:	a3 a8 c0 80 00       	mov    %eax,0x80c0a8
		if(env->env_id==to_env){
  802e4d:	8b 40 4c             	mov    0x4c(%eax),%eax
  802e50:	39 f0                	cmp    %esi,%eax
  802e52:	75 0e                	jne    802e62 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  802e54:	c7 04 24 25 49 80 00 	movl   $0x804925,(%esp)
  802e5b:	e8 39 f0 ff ff       	call   801e99 <cprintf>
  802e60:	eb 5a                	jmp    802ebc <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  802e62:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802e66:	8b 45 10             	mov    0x10(%ebp),%eax
  802e69:	89 44 24 08          	mov    %eax,0x8(%esp)
  802e6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e70:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e74:	89 34 24             	mov    %esi,(%esp)
  802e77:	e8 b0 fb ff ff       	call   802a2c <sys_ipc_try_send>
  802e7c:	89 c3                	mov    %eax,%ebx
  802e7e:	85 c0                	test   %eax,%eax
  802e80:	79 25                	jns    802ea7 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  802e82:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802e85:	74 2b                	je     802eb2 <ipc_send+0xa2>
				panic("send error:%e",r);
  802e87:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802e8b:	c7 44 24 08 41 49 80 	movl   $0x804941,0x8(%esp)
  802e92:	00 
  802e93:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  802e9a:	00 
  802e9b:	c7 04 24 4f 49 80 00 	movl   $0x80494f,(%esp)
  802ea2:	e8 25 ef ff ff       	call   801dcc <_panic>
		}
			sys_yield();
  802ea7:	e8 ed fd ff ff       	call   802c99 <sys_yield>
		
	}while(r!=0);
  802eac:	85 db                	test   %ebx,%ebx
  802eae:	75 86                	jne    802e36 <ipc_send+0x26>
  802eb0:	eb 0a                	jmp    802ebc <ipc_send+0xac>
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
		{	
			if(r!=-E_IPC_NOT_RECV)
				panic("send error:%e",r);
		}
			sys_yield();
  802eb2:	e8 e2 fd ff ff       	call   802c99 <sys_yield>
  802eb7:	e9 7a ff ff ff       	jmp    802e36 <ipc_send+0x26>
		
	}while(r!=0);
	return;
	//panic("ipc_send not implemented");
}
  802ebc:	83 c4 1c             	add    $0x1c,%esp
  802ebf:	5b                   	pop    %ebx
  802ec0:	5e                   	pop    %esi
  802ec1:	5f                   	pop    %edi
  802ec2:	5d                   	pop    %ebp
  802ec3:	c3                   	ret    

00802ec4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802ec4:	55                   	push   %ebp
  802ec5:	89 e5                	mov    %esp,%ebp
  802ec7:	57                   	push   %edi
  802ec8:	56                   	push   %esi
  802ec9:	53                   	push   %ebx
  802eca:	83 ec 0c             	sub    $0xc,%esp
  802ecd:	8b 75 08             	mov    0x8(%ebp),%esi
  802ed0:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	void *dstva=NULL;
	if(pg)
		dstva=pg;
	env = &envs[ENVX(sys_getenvid())];
  802ed3:	e8 f5 fd ff ff       	call   802ccd <sys_getenvid>
  802ed8:	25 ff 03 00 00       	and    $0x3ff,%eax
  802edd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802ee0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802ee5:	a3 a8 c0 80 00       	mov    %eax,0x80c0a8
	if(from_env_store&&(env->env_id==*from_env_store))
  802eea:	85 f6                	test   %esi,%esi
  802eec:	74 29                	je     802f17 <ipc_recv+0x53>
  802eee:	8b 40 4c             	mov    0x4c(%eax),%eax
  802ef1:	3b 06                	cmp    (%esi),%eax
  802ef3:	75 22                	jne    802f17 <ipc_recv+0x53>
	{
		*from_env_store=0;
  802ef5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  802efb:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("send:the reciver is sender\n");
  802f01:	c7 04 24 25 49 80 00 	movl   $0x804925,(%esp)
  802f08:	e8 8c ef ff ff       	call   801e99 <cprintf>
  802f0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802f12:	e9 8a 00 00 00       	jmp    802fa1 <ipc_recv+0xdd>
		return 0;
	}
	env = &envs[ENVX(sys_getenvid())];
  802f17:	e8 b1 fd ff ff       	call   802ccd <sys_getenvid>
  802f1c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802f21:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802f24:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802f29:	a3 a8 c0 80 00       	mov    %eax,0x80c0a8
	if((r=sys_ipc_recv(dstva))<0)
  802f2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f31:	89 04 24             	mov    %eax,(%esp)
  802f34:	e8 96 fa ff ff       	call   8029cf <sys_ipc_recv>
  802f39:	89 c3                	mov    %eax,%ebx
  802f3b:	85 c0                	test   %eax,%eax
  802f3d:	79 1a                	jns    802f59 <ipc_recv+0x95>
	{
		*from_env_store=0;
  802f3f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  802f45:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("reciver failed\n");
  802f4b:	c7 04 24 59 49 80 00 	movl   $0x804959,(%esp)
  802f52:	e8 42 ef ff ff       	call   801e99 <cprintf>
  802f57:	eb 48                	jmp    802fa1 <ipc_recv+0xdd>
		return r;
	}
	else{//接收成功
		env = &envs[ENVX(sys_getenvid())];
  802f59:	e8 6f fd ff ff       	call   802ccd <sys_getenvid>
  802f5e:	25 ff 03 00 00       	and    $0x3ff,%eax
  802f63:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802f66:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802f6b:	a3 a8 c0 80 00       	mov    %eax,0x80c0a8
		if(from_env_store)
  802f70:	85 f6                	test   %esi,%esi
  802f72:	74 05                	je     802f79 <ipc_recv+0xb5>
			*from_env_store=env->env_ipc_from;	
  802f74:	8b 40 74             	mov    0x74(%eax),%eax
  802f77:	89 06                	mov    %eax,(%esi)
		if(perm_store)
  802f79:	85 ff                	test   %edi,%edi
  802f7b:	74 0a                	je     802f87 <ipc_recv+0xc3>
			*perm_store=env->env_ipc_perm;
  802f7d:	a1 a8 c0 80 00       	mov    0x80c0a8,%eax
  802f82:	8b 40 78             	mov    0x78(%eax),%eax
  802f85:	89 07                	mov    %eax,(%edi)
		env = &envs[ENVX(sys_getenvid())];
  802f87:	e8 41 fd ff ff       	call   802ccd <sys_getenvid>
  802f8c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802f91:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802f94:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802f99:	a3 a8 c0 80 00       	mov    %eax,0x80c0a8
		return env->env_ipc_value;
  802f9e:	8b 58 70             	mov    0x70(%eax),%ebx
	}
	//panic("ipc_recv not implemented");
	return 0;
}
  802fa1:	89 d8                	mov    %ebx,%eax
  802fa3:	83 c4 0c             	add    $0xc,%esp
  802fa6:	5b                   	pop    %ebx
  802fa7:	5e                   	pop    %esi
  802fa8:	5f                   	pop    %edi
  802fa9:	5d                   	pop    %ebp
  802faa:	c3                   	ret    
  802fab:	00 00                	add    %al,(%eax)
  802fad:	00 00                	add    %al,(%eax)
	...

00802fb0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802fb0:	55                   	push   %ebp
  802fb1:	89 e5                	mov    %esp,%ebp
  802fb3:	8b 45 08             	mov    0x8(%ebp),%eax
  802fb6:	05 00 00 00 30       	add    $0x30000000,%eax
  802fbb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  802fbe:	5d                   	pop    %ebp
  802fbf:	c3                   	ret    

00802fc0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802fc0:	55                   	push   %ebp
  802fc1:	89 e5                	mov    %esp,%ebp
  802fc3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  802fc6:	8b 45 08             	mov    0x8(%ebp),%eax
  802fc9:	89 04 24             	mov    %eax,(%esp)
  802fcc:	e8 df ff ff ff       	call   802fb0 <fd2num>
  802fd1:	c1 e0 0c             	shl    $0xc,%eax
  802fd4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  802fd9:	c9                   	leave  
  802fda:	c3                   	ret    

00802fdb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802fdb:	55                   	push   %ebp
  802fdc:	89 e5                	mov    %esp,%ebp
  802fde:	53                   	push   %ebx
  802fdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802fe2:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  802fe7:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  802fe9:	89 d0                	mov    %edx,%eax
  802feb:	c1 e8 16             	shr    $0x16,%eax
  802fee:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802ff5:	a8 01                	test   $0x1,%al
  802ff7:	74 10                	je     803009 <fd_alloc+0x2e>
  802ff9:	89 d0                	mov    %edx,%eax
  802ffb:	c1 e8 0c             	shr    $0xc,%eax
  802ffe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  803005:	a8 01                	test   $0x1,%al
  803007:	75 09                	jne    803012 <fd_alloc+0x37>
			*fd_store = fd;
  803009:	89 0b                	mov    %ecx,(%ebx)
  80300b:	b8 00 00 00 00       	mov    $0x0,%eax
  803010:	eb 19                	jmp    80302b <fd_alloc+0x50>
			return 0;
  803012:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  803018:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  80301e:	75 c7                	jne    802fe7 <fd_alloc+0xc>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  803020:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  803026:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  80302b:	5b                   	pop    %ebx
  80302c:	5d                   	pop    %ebp
  80302d:	c3                   	ret    

0080302e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80302e:	55                   	push   %ebp
  80302f:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  803031:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  803035:	77 38                	ja     80306f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  803037:	8b 45 08             	mov    0x8(%ebp),%eax
  80303a:	c1 e0 0c             	shl    $0xc,%eax
  80303d:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  803043:	89 d0                	mov    %edx,%eax
  803045:	c1 e8 16             	shr    $0x16,%eax
  803048:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80304f:	a8 01                	test   $0x1,%al
  803051:	74 1c                	je     80306f <fd_lookup+0x41>
  803053:	89 d0                	mov    %edx,%eax
  803055:	c1 e8 0c             	shr    $0xc,%eax
  803058:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80305f:	a8 01                	test   $0x1,%al
  803061:	74 0c                	je     80306f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  803063:	8b 45 0c             	mov    0xc(%ebp),%eax
  803066:	89 10                	mov    %edx,(%eax)
  803068:	b8 00 00 00 00       	mov    $0x0,%eax
  80306d:	eb 05                	jmp    803074 <fd_lookup+0x46>
	return 0;
  80306f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  803074:	5d                   	pop    %ebp
  803075:	c3                   	ret    

00803076 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  803076:	55                   	push   %ebp
  803077:	89 e5                	mov    %esp,%ebp
  803079:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80307c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80307f:	89 44 24 04          	mov    %eax,0x4(%esp)
  803083:	8b 45 08             	mov    0x8(%ebp),%eax
  803086:	89 04 24             	mov    %eax,(%esp)
  803089:	e8 a0 ff ff ff       	call   80302e <fd_lookup>
  80308e:	85 c0                	test   %eax,%eax
  803090:	78 0e                	js     8030a0 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  803092:	8b 45 fc             	mov    -0x4(%ebp),%eax
  803095:	8b 55 0c             	mov    0xc(%ebp),%edx
  803098:	89 50 04             	mov    %edx,0x4(%eax)
  80309b:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8030a0:	c9                   	leave  
  8030a1:	c3                   	ret    

008030a2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8030a2:	55                   	push   %ebp
  8030a3:	89 e5                	mov    %esp,%ebp
  8030a5:	53                   	push   %ebx
  8030a6:	83 ec 14             	sub    $0x14,%esp
  8030a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8030ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8030af:	ba 68 c0 80 00       	mov    $0x80c068,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8030b4:	b8 00 00 00 00       	mov    $0x0,%eax
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8030b9:	39 0d 68 c0 80 00    	cmp    %ecx,0x80c068
  8030bf:	75 11                	jne    8030d2 <dev_lookup+0x30>
  8030c1:	eb 04                	jmp    8030c7 <dev_lookup+0x25>
  8030c3:	39 0a                	cmp    %ecx,(%edx)
  8030c5:	75 0b                	jne    8030d2 <dev_lookup+0x30>
			*dev = devtab[i];
  8030c7:	89 13                	mov    %edx,(%ebx)
  8030c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8030ce:	66 90                	xchg   %ax,%ax
  8030d0:	eb 35                	jmp    803107 <dev_lookup+0x65>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8030d2:	83 c0 01             	add    $0x1,%eax
  8030d5:	8b 14 85 ec 49 80 00 	mov    0x8049ec(,%eax,4),%edx
  8030dc:	85 d2                	test   %edx,%edx
  8030de:	75 e3                	jne    8030c3 <dev_lookup+0x21>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  8030e0:	a1 a8 c0 80 00       	mov    0x80c0a8,%eax
  8030e5:	8b 40 4c             	mov    0x4c(%eax),%eax
  8030e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8030ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030f0:	c7 04 24 6c 49 80 00 	movl   $0x80496c,(%esp)
  8030f7:	e8 9d ed ff ff       	call   801e99 <cprintf>
	*dev = 0;
  8030fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  803102:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  803107:	83 c4 14             	add    $0x14,%esp
  80310a:	5b                   	pop    %ebx
  80310b:	5d                   	pop    %ebp
  80310c:	c3                   	ret    

0080310d <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80310d:	55                   	push   %ebp
  80310e:	89 e5                	mov    %esp,%ebp
  803110:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  803113:	8d 45 f8             	lea    -0x8(%ebp),%eax
  803116:	89 44 24 04          	mov    %eax,0x4(%esp)
  80311a:	8b 45 08             	mov    0x8(%ebp),%eax
  80311d:	89 04 24             	mov    %eax,(%esp)
  803120:	e8 09 ff ff ff       	call   80302e <fd_lookup>
  803125:	89 c2                	mov    %eax,%edx
  803127:	85 c0                	test   %eax,%eax
  803129:	78 5a                	js     803185 <fstat+0x78>
  80312b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80312e:	89 44 24 04          	mov    %eax,0x4(%esp)
  803132:	8b 45 f8             	mov    -0x8(%ebp),%eax
  803135:	8b 00                	mov    (%eax),%eax
  803137:	89 04 24             	mov    %eax,(%esp)
  80313a:	e8 63 ff ff ff       	call   8030a2 <dev_lookup>
  80313f:	89 c2                	mov    %eax,%edx
  803141:	85 c0                	test   %eax,%eax
  803143:	78 40                	js     803185 <fstat+0x78>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  803145:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  80314a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80314d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  803151:	74 32                	je     803185 <fstat+0x78>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  803153:	8b 45 0c             	mov    0xc(%ebp),%eax
  803156:	c6 00 00             	movb   $0x0,(%eax)
	stat->st_size = 0;
  803159:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  803160:	00 00 00 
	stat->st_isdir = 0;
  803163:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
  80316a:	00 00 00 
	stat->st_dev = dev;
  80316d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  803170:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
	return (*dev->dev_stat)(fd, stat);
  803176:	89 44 24 04          	mov    %eax,0x4(%esp)
  80317a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80317d:	89 04 24             	mov    %eax,(%esp)
  803180:	ff 52 14             	call   *0x14(%edx)
  803183:	89 c2                	mov    %eax,%edx
}
  803185:	89 d0                	mov    %edx,%eax
  803187:	c9                   	leave  
  803188:	c3                   	ret    

00803189 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  803189:	55                   	push   %ebp
  80318a:	89 e5                	mov    %esp,%ebp
  80318c:	53                   	push   %ebx
  80318d:	83 ec 24             	sub    $0x24,%esp
  803190:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  803193:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803196:	89 44 24 04          	mov    %eax,0x4(%esp)
  80319a:	89 1c 24             	mov    %ebx,(%esp)
  80319d:	e8 8c fe ff ff       	call   80302e <fd_lookup>
  8031a2:	85 c0                	test   %eax,%eax
  8031a4:	78 61                	js     803207 <ftruncate+0x7e>
  8031a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8031a9:	8b 10                	mov    (%eax),%edx
  8031ab:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8031ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031b2:	89 14 24             	mov    %edx,(%esp)
  8031b5:	e8 e8 fe ff ff       	call   8030a2 <dev_lookup>
  8031ba:	85 c0                	test   %eax,%eax
  8031bc:	78 49                	js     803207 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8031be:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  8031c1:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  8031c5:	75 23                	jne    8031ea <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8031c7:	a1 a8 c0 80 00       	mov    0x80c0a8,%eax
  8031cc:	8b 40 4c             	mov    0x4c(%eax),%eax
  8031cf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8031d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031d7:	c7 04 24 8c 49 80 00 	movl   $0x80498c,(%esp)
  8031de:	e8 b6 ec ff ff       	call   801e99 <cprintf>
  8031e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8031e8:	eb 1d                	jmp    803207 <ftruncate+0x7e>
			env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8031ea:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8031ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8031f2:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  8031f6:	74 0f                	je     803207 <ftruncate+0x7e>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8031f8:	8b 42 18             	mov    0x18(%edx),%eax
  8031fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8031fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  803202:	89 0c 24             	mov    %ecx,(%esp)
  803205:	ff d0                	call   *%eax
}
  803207:	83 c4 24             	add    $0x24,%esp
  80320a:	5b                   	pop    %ebx
  80320b:	5d                   	pop    %ebp
  80320c:	c3                   	ret    

0080320d <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80320d:	55                   	push   %ebp
  80320e:	89 e5                	mov    %esp,%ebp
  803210:	53                   	push   %ebx
  803211:	83 ec 24             	sub    $0x24,%esp
  803214:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  803217:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80321a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80321e:	89 1c 24             	mov    %ebx,(%esp)
  803221:	e8 08 fe ff ff       	call   80302e <fd_lookup>
  803226:	85 c0                	test   %eax,%eax
  803228:	78 68                	js     803292 <write+0x85>
  80322a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80322d:	8b 10                	mov    (%eax),%edx
  80322f:	8d 45 f8             	lea    -0x8(%ebp),%eax
  803232:	89 44 24 04          	mov    %eax,0x4(%esp)
  803236:	89 14 24             	mov    %edx,(%esp)
  803239:	e8 64 fe ff ff       	call   8030a2 <dev_lookup>
  80323e:	85 c0                	test   %eax,%eax
  803240:	78 50                	js     803292 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  803242:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  803245:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  803249:	75 23                	jne    80326e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  80324b:	a1 a8 c0 80 00       	mov    0x80c0a8,%eax
  803250:	8b 40 4c             	mov    0x4c(%eax),%eax
  803253:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803257:	89 44 24 04          	mov    %eax,0x4(%esp)
  80325b:	c7 04 24 b0 49 80 00 	movl   $0x8049b0,(%esp)
  803262:	e8 32 ec ff ff       	call   801e99 <cprintf>
  803267:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80326c:	eb 24                	jmp    803292 <write+0x85>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80326e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  803271:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  803276:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  80327a:	74 16                	je     803292 <write+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80327c:	8b 42 0c             	mov    0xc(%edx),%eax
  80327f:	8b 55 10             	mov    0x10(%ebp),%edx
  803282:	89 54 24 08          	mov    %edx,0x8(%esp)
  803286:	8b 55 0c             	mov    0xc(%ebp),%edx
  803289:	89 54 24 04          	mov    %edx,0x4(%esp)
  80328d:	89 0c 24             	mov    %ecx,(%esp)
  803290:	ff d0                	call   *%eax
}
  803292:	83 c4 24             	add    $0x24,%esp
  803295:	5b                   	pop    %ebx
  803296:	5d                   	pop    %ebp
  803297:	c3                   	ret    

00803298 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  803298:	55                   	push   %ebp
  803299:	89 e5                	mov    %esp,%ebp
  80329b:	53                   	push   %ebx
  80329c:	83 ec 24             	sub    $0x24,%esp
  80329f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8032a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8032a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8032a9:	89 1c 24             	mov    %ebx,(%esp)
  8032ac:	e8 7d fd ff ff       	call   80302e <fd_lookup>
  8032b1:	85 c0                	test   %eax,%eax
  8032b3:	78 6d                	js     803322 <read+0x8a>
  8032b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8032b8:	8b 10                	mov    (%eax),%edx
  8032ba:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8032bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8032c1:	89 14 24             	mov    %edx,(%esp)
  8032c4:	e8 d9 fd ff ff       	call   8030a2 <dev_lookup>
  8032c9:	85 c0                	test   %eax,%eax
  8032cb:	78 55                	js     803322 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8032cd:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  8032d0:	8b 41 08             	mov    0x8(%ecx),%eax
  8032d3:	83 e0 03             	and    $0x3,%eax
  8032d6:	83 f8 01             	cmp    $0x1,%eax
  8032d9:	75 23                	jne    8032fe <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  8032db:	a1 a8 c0 80 00       	mov    0x80c0a8,%eax
  8032e0:	8b 40 4c             	mov    0x4c(%eax),%eax
  8032e3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8032e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8032eb:	c7 04 24 cd 49 80 00 	movl   $0x8049cd,(%esp)
  8032f2:	e8 a2 eb ff ff       	call   801e99 <cprintf>
  8032f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8032fc:	eb 24                	jmp    803322 <read+0x8a>
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8032fe:	8b 55 f8             	mov    -0x8(%ebp),%edx
  803301:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  803306:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  80330a:	74 16                	je     803322 <read+0x8a>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80330c:	8b 42 08             	mov    0x8(%edx),%eax
  80330f:	8b 55 10             	mov    0x10(%ebp),%edx
  803312:	89 54 24 08          	mov    %edx,0x8(%esp)
  803316:	8b 55 0c             	mov    0xc(%ebp),%edx
  803319:	89 54 24 04          	mov    %edx,0x4(%esp)
  80331d:	89 0c 24             	mov    %ecx,(%esp)
  803320:	ff d0                	call   *%eax
}
  803322:	83 c4 24             	add    $0x24,%esp
  803325:	5b                   	pop    %ebx
  803326:	5d                   	pop    %ebp
  803327:	c3                   	ret    

00803328 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  803328:	55                   	push   %ebp
  803329:	89 e5                	mov    %esp,%ebp
  80332b:	57                   	push   %edi
  80332c:	56                   	push   %esi
  80332d:	53                   	push   %ebx
  80332e:	83 ec 0c             	sub    $0xc,%esp
  803331:	8b 7d 0c             	mov    0xc(%ebp),%edi
  803334:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  803337:	b8 00 00 00 00       	mov    $0x0,%eax
  80333c:	85 f6                	test   %esi,%esi
  80333e:	74 36                	je     803376 <readn+0x4e>
  803340:	bb 00 00 00 00       	mov    $0x0,%ebx
  803345:	ba 00 00 00 00       	mov    $0x0,%edx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80334a:	89 f0                	mov    %esi,%eax
  80334c:	29 d0                	sub    %edx,%eax
  80334e:	89 44 24 08          	mov    %eax,0x8(%esp)
  803352:	8d 04 17             	lea    (%edi,%edx,1),%eax
  803355:	89 44 24 04          	mov    %eax,0x4(%esp)
  803359:	8b 45 08             	mov    0x8(%ebp),%eax
  80335c:	89 04 24             	mov    %eax,(%esp)
  80335f:	e8 34 ff ff ff       	call   803298 <read>
		if (m < 0)
  803364:	85 c0                	test   %eax,%eax
  803366:	78 0e                	js     803376 <readn+0x4e>
			return m;
		if (m == 0)
  803368:	85 c0                	test   %eax,%eax
  80336a:	74 08                	je     803374 <readn+0x4c>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80336c:	01 c3                	add    %eax,%ebx
  80336e:	89 da                	mov    %ebx,%edx
  803370:	39 f3                	cmp    %esi,%ebx
  803372:	72 d6                	jb     80334a <readn+0x22>
  803374:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  803376:	83 c4 0c             	add    $0xc,%esp
  803379:	5b                   	pop    %ebx
  80337a:	5e                   	pop    %esi
  80337b:	5f                   	pop    %edi
  80337c:	5d                   	pop    %ebp
  80337d:	c3                   	ret    

0080337e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80337e:	55                   	push   %ebp
  80337f:	89 e5                	mov    %esp,%ebp
  803381:	83 ec 28             	sub    $0x28,%esp
  803384:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  803387:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80338a:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80338d:	89 34 24             	mov    %esi,(%esp)
  803390:	e8 1b fc ff ff       	call   802fb0 <fd2num>
  803395:	8d 55 f4             	lea    -0xc(%ebp),%edx
  803398:	89 54 24 04          	mov    %edx,0x4(%esp)
  80339c:	89 04 24             	mov    %eax,(%esp)
  80339f:	e8 8a fc ff ff       	call   80302e <fd_lookup>
  8033a4:	89 c3                	mov    %eax,%ebx
  8033a6:	85 c0                	test   %eax,%eax
  8033a8:	78 05                	js     8033af <fd_close+0x31>
  8033aa:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8033ad:	74 0d                	je     8033bc <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8033af:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8033b3:	75 44                	jne    8033f9 <fd_close+0x7b>
  8033b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8033ba:	eb 3d                	jmp    8033f9 <fd_close+0x7b>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8033bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8033bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8033c3:	8b 06                	mov    (%esi),%eax
  8033c5:	89 04 24             	mov    %eax,(%esp)
  8033c8:	e8 d5 fc ff ff       	call   8030a2 <dev_lookup>
  8033cd:	89 c3                	mov    %eax,%ebx
  8033cf:	85 c0                	test   %eax,%eax
  8033d1:	78 16                	js     8033e9 <fd_close+0x6b>
		if (dev->dev_close)
  8033d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8033d6:	8b 40 10             	mov    0x10(%eax),%eax
  8033d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8033de:	85 c0                	test   %eax,%eax
  8033e0:	74 07                	je     8033e9 <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  8033e2:	89 34 24             	mov    %esi,(%esp)
  8033e5:	ff d0                	call   *%eax
  8033e7:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8033e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8033ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8033f4:	e8 85 f7 ff ff       	call   802b7e <sys_page_unmap>
	return r;
}
  8033f9:	89 d8                	mov    %ebx,%eax
  8033fb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8033fe:	8b 75 fc             	mov    -0x4(%ebp),%esi
  803401:	89 ec                	mov    %ebp,%esp
  803403:	5d                   	pop    %ebp
  803404:	c3                   	ret    

00803405 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  803405:	55                   	push   %ebp
  803406:	89 e5                	mov    %esp,%ebp
  803408:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80340b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80340e:	89 44 24 04          	mov    %eax,0x4(%esp)
  803412:	8b 45 08             	mov    0x8(%ebp),%eax
  803415:	89 04 24             	mov    %eax,(%esp)
  803418:	e8 11 fc ff ff       	call   80302e <fd_lookup>
  80341d:	85 c0                	test   %eax,%eax
  80341f:	78 13                	js     803434 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  803421:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  803428:	00 
  803429:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80342c:	89 04 24             	mov    %eax,(%esp)
  80342f:	e8 4a ff ff ff       	call   80337e <fd_close>
}
  803434:	c9                   	leave  
  803435:	c3                   	ret    

00803436 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  803436:	55                   	push   %ebp
  803437:	89 e5                	mov    %esp,%ebp
  803439:	83 ec 18             	sub    $0x18,%esp
  80343c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80343f:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  803442:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  803449:	00 
  80344a:	8b 45 08             	mov    0x8(%ebp),%eax
  80344d:	89 04 24             	mov    %eax,(%esp)
  803450:	e8 5a 03 00 00       	call   8037af <open>
  803455:	89 c6                	mov    %eax,%esi
  803457:	85 c0                	test   %eax,%eax
  803459:	78 1b                	js     803476 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  80345b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80345e:	89 44 24 04          	mov    %eax,0x4(%esp)
  803462:	89 34 24             	mov    %esi,(%esp)
  803465:	e8 a3 fc ff ff       	call   80310d <fstat>
  80346a:	89 c3                	mov    %eax,%ebx
	close(fd);
  80346c:	89 34 24             	mov    %esi,(%esp)
  80346f:	e8 91 ff ff ff       	call   803405 <close>
  803474:	89 de                	mov    %ebx,%esi
	return r;
}
  803476:	89 f0                	mov    %esi,%eax
  803478:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80347b:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80347e:	89 ec                	mov    %ebp,%esp
  803480:	5d                   	pop    %ebp
  803481:	c3                   	ret    

00803482 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  803482:	55                   	push   %ebp
  803483:	89 e5                	mov    %esp,%ebp
  803485:	83 ec 38             	sub    $0x38,%esp
  803488:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80348b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80348e:	89 7d fc             	mov    %edi,-0x4(%ebp)
  803491:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  803494:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803497:	89 44 24 04          	mov    %eax,0x4(%esp)
  80349b:	8b 45 08             	mov    0x8(%ebp),%eax
  80349e:	89 04 24             	mov    %eax,(%esp)
  8034a1:	e8 88 fb ff ff       	call   80302e <fd_lookup>
  8034a6:	89 c3                	mov    %eax,%ebx
  8034a8:	85 c0                	test   %eax,%eax
  8034aa:	0f 88 e1 00 00 00    	js     803591 <dup+0x10f>
		return r;
	close(newfdnum);
  8034b0:	89 3c 24             	mov    %edi,(%esp)
  8034b3:	e8 4d ff ff ff       	call   803405 <close>

	newfd = INDEX2FD(newfdnum);
  8034b8:	89 f8                	mov    %edi,%eax
  8034ba:	c1 e0 0c             	shl    $0xc,%eax
  8034bd:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  8034c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8034c6:	89 04 24             	mov    %eax,(%esp)
  8034c9:	e8 f2 fa ff ff       	call   802fc0 <fd2data>
  8034ce:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8034d0:	89 34 24             	mov    %esi,(%esp)
  8034d3:	e8 e8 fa ff ff       	call   802fc0 <fd2data>
  8034d8:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  8034db:	89 d8                	mov    %ebx,%eax
  8034dd:	c1 e8 16             	shr    $0x16,%eax
  8034e0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8034e7:	a8 01                	test   $0x1,%al
  8034e9:	74 45                	je     803530 <dup+0xae>
  8034eb:	89 da                	mov    %ebx,%edx
  8034ed:	c1 ea 0c             	shr    $0xc,%edx
  8034f0:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8034f7:	a8 01                	test   $0x1,%al
  8034f9:	74 35                	je     803530 <dup+0xae>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  8034fb:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  803502:	25 07 0e 00 00       	and    $0xe07,%eax
  803507:	89 44 24 10          	mov    %eax,0x10(%esp)
  80350b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80350e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803512:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803519:	00 
  80351a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80351e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803525:	e8 b2 f6 ff ff       	call   802bdc <sys_page_map>
  80352a:	89 c3                	mov    %eax,%ebx
  80352c:	85 c0                	test   %eax,%eax
  80352e:	78 3e                	js     80356e <dup+0xec>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  803530:	8b 55 f0             	mov    -0x10(%ebp),%edx
  803533:	89 d0                	mov    %edx,%eax
  803535:	c1 e8 0c             	shr    $0xc,%eax
  803538:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80353f:	25 07 0e 00 00       	and    $0xe07,%eax
  803544:	89 44 24 10          	mov    %eax,0x10(%esp)
  803548:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80354c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803553:	00 
  803554:	89 54 24 04          	mov    %edx,0x4(%esp)
  803558:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80355f:	e8 78 f6 ff ff       	call   802bdc <sys_page_map>
  803564:	89 c3                	mov    %eax,%ebx
  803566:	85 c0                	test   %eax,%eax
  803568:	78 04                	js     80356e <dup+0xec>
		goto err;
  80356a:	89 fb                	mov    %edi,%ebx
  80356c:	eb 23                	jmp    803591 <dup+0x10f>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80356e:	89 74 24 04          	mov    %esi,0x4(%esp)
  803572:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803579:	e8 00 f6 ff ff       	call   802b7e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80357e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803581:	89 44 24 04          	mov    %eax,0x4(%esp)
  803585:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80358c:	e8 ed f5 ff ff       	call   802b7e <sys_page_unmap>
	return r;
}
  803591:	89 d8                	mov    %ebx,%eax
  803593:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  803596:	8b 75 f8             	mov    -0x8(%ebp),%esi
  803599:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80359c:	89 ec                	mov    %ebp,%esp
  80359e:	5d                   	pop    %ebp
  80359f:	c3                   	ret    

008035a0 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8035a0:	55                   	push   %ebp
  8035a1:	89 e5                	mov    %esp,%ebp
  8035a3:	53                   	push   %ebx
  8035a4:	83 ec 04             	sub    $0x4,%esp
  8035a7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8035ac:	89 1c 24             	mov    %ebx,(%esp)
  8035af:	e8 51 fe ff ff       	call   803405 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8035b4:	83 c3 01             	add    $0x1,%ebx
  8035b7:	83 fb 20             	cmp    $0x20,%ebx
  8035ba:	75 f0                	jne    8035ac <close_all+0xc>
		close(i);
}
  8035bc:	83 c4 04             	add    $0x4,%esp
  8035bf:	5b                   	pop    %ebx
  8035c0:	5d                   	pop    %ebp
  8035c1:	c3                   	ret    
	...

008035c4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8035c4:	55                   	push   %ebp
  8035c5:	89 e5                	mov    %esp,%ebp
  8035c7:	53                   	push   %ebx
  8035c8:	83 ec 14             	sub    $0x14,%esp
  8035cb:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8035cd:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  8035d3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8035da:	00 
  8035db:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8035e2:	00 
  8035e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8035e7:	89 14 24             	mov    %edx,(%esp)
  8035ea:	e8 21 f8 ff ff       	call   802e10 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8035ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8035f6:	00 
  8035f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8035fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803602:	e8 bd f8 ff ff       	call   802ec4 <ipc_recv>
}
  803607:	83 c4 14             	add    $0x14,%esp
  80360a:	5b                   	pop    %ebx
  80360b:	5d                   	pop    %ebp
  80360c:	c3                   	ret    

0080360d <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  80360d:	55                   	push   %ebp
  80360e:	89 e5                	mov    %esp,%ebp
  803610:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  803613:	ba 00 00 00 00       	mov    $0x0,%edx
  803618:	b8 08 00 00 00       	mov    $0x8,%eax
  80361d:	e8 a2 ff ff ff       	call   8035c4 <fsipc>
}
  803622:	c9                   	leave  
  803623:	c3                   	ret    

00803624 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  803624:	55                   	push   %ebp
  803625:	89 e5                	mov    %esp,%ebp
  803627:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80362a:	8b 45 08             	mov    0x8(%ebp),%eax
  80362d:	8b 40 0c             	mov    0xc(%eax),%eax
  803630:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  803635:	8b 45 0c             	mov    0xc(%ebp),%eax
  803638:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80363d:	ba 00 00 00 00       	mov    $0x0,%edx
  803642:	b8 02 00 00 00       	mov    $0x2,%eax
  803647:	e8 78 ff ff ff       	call   8035c4 <fsipc>
}
  80364c:	c9                   	leave  
  80364d:	c3                   	ret    

0080364e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80364e:	55                   	push   %ebp
  80364f:	89 e5                	mov    %esp,%ebp
  803651:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  803654:	8b 45 08             	mov    0x8(%ebp),%eax
  803657:	8b 40 0c             	mov    0xc(%eax),%eax
  80365a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80365f:	ba 00 00 00 00       	mov    $0x0,%edx
  803664:	b8 06 00 00 00       	mov    $0x6,%eax
  803669:	e8 56 ff ff ff       	call   8035c4 <fsipc>
}
  80366e:	c9                   	leave  
  80366f:	c3                   	ret    

00803670 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  803670:	55                   	push   %ebp
  803671:	89 e5                	mov    %esp,%ebp
  803673:	53                   	push   %ebx
  803674:	83 ec 14             	sub    $0x14,%esp
  803677:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80367a:	8b 45 08             	mov    0x8(%ebp),%eax
  80367d:	8b 40 0c             	mov    0xc(%eax),%eax
  803680:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  803685:	ba 00 00 00 00       	mov    $0x0,%edx
  80368a:	b8 05 00 00 00       	mov    $0x5,%eax
  80368f:	e8 30 ff ff ff       	call   8035c4 <fsipc>
  803694:	85 c0                	test   %eax,%eax
  803696:	78 2b                	js     8036c3 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  803698:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80369f:	00 
  8036a0:	89 1c 24             	mov    %ebx,(%esp)
  8036a3:	e8 59 ee ff ff       	call   802501 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8036a8:	a1 80 50 80 00       	mov    0x805080,%eax
  8036ad:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8036b3:	a1 84 50 80 00       	mov    0x805084,%eax
  8036b8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8036be:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8036c3:	83 c4 14             	add    $0x14,%esp
  8036c6:	5b                   	pop    %ebx
  8036c7:	5d                   	pop    %ebp
  8036c8:	c3                   	ret    

008036c9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8036c9:	55                   	push   %ebp
  8036ca:	89 e5                	mov    %esp,%ebp
  8036cc:	83 ec 18             	sub    $0x18,%esp
  8036cf:	8b 55 10             	mov    0x10(%ebp),%edx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	ssize_t writesize;
	size_t bufsize;
	fsipcbuf.write.req_fileid=fd->fd_file.id;
  8036d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8036d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8036d8:	a3 00 50 80 00       	mov    %eax,0x805000
	bufsize=sizeof(fsipcbuf.write.req_buf);
	if(n<bufsize)
  8036dd:	89 d0                	mov    %edx,%eax
  8036df:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  8036e5:	76 05                	jbe    8036ec <devfile_write+0x23>
  8036e7:	b8 f8 0f 00 00       	mov    $0xff8,%eax
		bufsize=n;	
	fsipcbuf.write.req_n=n;
  8036ec:	89 15 04 50 80 00    	mov    %edx,0x805004
	memmove((void*)fsipcbuf.write.req_buf,buf,bufsize);
  8036f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8036f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8036f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8036fd:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  803704:	e8 ff ef ff ff       	call   802708 <memmove>
	writesize=(ssize_t)fsipc(FSREQ_WRITE,NULL);
  803709:	ba 00 00 00 00       	mov    $0x0,%edx
  80370e:	b8 04 00 00 00       	mov    $0x4,%eax
  803713:	e8 ac fe ff ff       	call   8035c4 <fsipc>
	return writesize;
	//panic("devfile_write not implemented");
}
  803718:	c9                   	leave  
  803719:	c3                   	ret    

0080371a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80371a:	55                   	push   %ebp
  80371b:	89 e5                	mov    %esp,%ebp
  80371d:	53                   	push   %ebx
  80371e:	83 ec 14             	sub    $0x14,%esp
	// system server.
	// LAB 5: Your code here
	ssize_t readsize;
	if(debug)
		cprintf("devfile_read:fileid=%x readsize=%x\n",fd->fd_file.id,n);
	fsipcbuf.read.req_fileid=fd->fd_file.id;
  803721:	8b 45 08             	mov    0x8(%ebp),%eax
  803724:	8b 40 0c             	mov    0xc(%eax),%eax
  803727:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n=n;
  80372c:	8b 45 10             	mov    0x10(%ebp),%eax
  80372f:	a3 04 50 80 00       	mov    %eax,0x805004
	readsize=(ssize_t)fsipc(FSREQ_READ,&fsipcbuf);
  803734:	ba 00 50 80 00       	mov    $0x805000,%edx
  803739:	b8 03 00 00 00       	mov    $0x3,%eax
  80373e:	e8 81 fe ff ff       	call   8035c4 <fsipc>
  803743:	89 c3                	mov    %eax,%ebx
	//cprintf("readsize=%d\n",readsize);
	if(debug)
		cprintf("devfile_read:buf1=%s\nbuf2=%s\n",(char*)&fsipcbuf,fsipcbuf.readRet.ret_buf);
	if(readsize>0)
  803745:	85 c0                	test   %eax,%eax
  803747:	7e 17                	jle    803760 <devfile_read+0x46>
		memmove(buf,(void*)&fsipcbuf,(size_t)readsize);
  803749:	89 44 24 08          	mov    %eax,0x8(%esp)
  80374d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  803754:	00 
  803755:	8b 45 0c             	mov    0xc(%ebp),%eax
  803758:	89 04 24             	mov    %eax,(%esp)
  80375b:	e8 a8 ef ff ff       	call   802708 <memmove>
	//cprintf("readsize=%d",readsize);
	return readsize;
	//panic("devfile_read not implemented");
}
  803760:	89 d8                	mov    %ebx,%eax
  803762:	83 c4 14             	add    $0x14,%esp
  803765:	5b                   	pop    %ebx
  803766:	5d                   	pop    %ebp
  803767:	c3                   	ret    

00803768 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  803768:	55                   	push   %ebp
  803769:	89 e5                	mov    %esp,%ebp
  80376b:	53                   	push   %ebx
  80376c:	83 ec 14             	sub    $0x14,%esp
  80376f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  803772:	89 1c 24             	mov    %ebx,(%esp)
  803775:	e8 36 ed ff ff       	call   8024b0 <strlen>
  80377a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  80377f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  803784:	7f 21                	jg     8037a7 <remove+0x3f>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  803786:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80378a:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  803791:	e8 6b ed ff ff       	call   802501 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  803796:	ba 00 00 00 00       	mov    $0x0,%edx
  80379b:	b8 07 00 00 00       	mov    $0x7,%eax
  8037a0:	e8 1f fe ff ff       	call   8035c4 <fsipc>
  8037a5:	89 c2                	mov    %eax,%edx
}
  8037a7:	89 d0                	mov    %edx,%eax
  8037a9:	83 c4 14             	add    $0x14,%esp
  8037ac:	5b                   	pop    %ebx
  8037ad:	5d                   	pop    %ebp
  8037ae:	c3                   	ret    

008037af <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8037af:	55                   	push   %ebp
  8037b0:	89 e5                	mov    %esp,%ebp
  8037b2:	56                   	push   %esi
  8037b3:	53                   	push   %ebx
  8037b4:	83 ec 30             	sub    $0x30,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;
	void *page;
	if((r=fd_alloc(&fd))<0){
  8037b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8037ba:	89 04 24             	mov    %eax,(%esp)
  8037bd:	e8 19 f8 ff ff       	call   802fdb <fd_alloc>
  8037c2:	89 c3                	mov    %eax,%ebx
  8037c4:	85 c0                	test   %eax,%eax
  8037c6:	79 18                	jns    8037e0 <open+0x31>
		fd_close(fd,0);
  8037c8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8037cf:	00 
  8037d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8037d3:	89 04 24             	mov    %eax,(%esp)
  8037d6:	e8 a3 fb ff ff       	call   80337e <fd_close>
  8037db:	e9 9f 00 00 00       	jmp    80387f <open+0xd0>
		return r;
	}
	//cprintf("open:fd=%x\n",fd);
	strcpy(fsipcbuf.open.req_path,path);
  8037e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8037e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8037e7:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8037ee:	e8 0e ed ff ff       	call   802501 <strcpy>
	fsipcbuf.open.req_omode=mode;
  8037f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8037f6:	a3 00 54 80 00       	mov    %eax,0x805400
	page=(void*)fd2data(fd);
  8037fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8037fe:	89 04 24             	mov    %eax,(%esp)
  803801:	e8 ba f7 ff ff       	call   802fc0 <fd2data>
  803806:	89 c6                	mov    %eax,%esi
	if((r=fsipc(FSREQ_OPEN,(void*)fd))<0)
  803808:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80380b:	b8 01 00 00 00       	mov    $0x1,%eax
  803810:	e8 af fd ff ff       	call   8035c4 <fsipc>
  803815:	89 c3                	mov    %eax,%ebx
  803817:	85 c0                	test   %eax,%eax
  803819:	79 15                	jns    803830 <open+0x81>
	{
		fd_close(fd,1);
  80381b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  803822:	00 
  803823:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803826:	89 04 24             	mov    %eax,(%esp)
  803829:	e8 50 fb ff ff       	call   80337e <fd_close>
  80382e:	eb 4f                	jmp    80387f <open+0xd0>
		return r;	
	}
	//cprintf("open:page=%x\n",page);
	if((r=sys_page_map(0,(void*)fd,0,(void*)page,PTE_P | PTE_W | PTE_U))<0)
  803830:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  803837:	00 
  803838:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80383c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803843:	00 
  803844:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803847:	89 44 24 04          	mov    %eax,0x4(%esp)
  80384b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803852:	e8 85 f3 ff ff       	call   802bdc <sys_page_map>
  803857:	89 c3                	mov    %eax,%ebx
  803859:	85 c0                	test   %eax,%eax
  80385b:	79 15                	jns    803872 <open+0xc3>
	{
		fd_close(fd,1);
  80385d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  803864:	00 
  803865:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803868:	89 04 24             	mov    %eax,(%esp)
  80386b:	e8 0e fb ff ff       	call   80337e <fd_close>
  803870:	eb 0d                	jmp    80387f <open+0xd0>
		return r;
	}
	//cprintf("open:fileid=%x\n",fd->fd_file.id);
	return fd2num(fd);
  803872:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803875:	89 04 24             	mov    %eax,(%esp)
  803878:	e8 33 f7 ff ff       	call   802fb0 <fd2num>
  80387d:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  80387f:	89 d8                	mov    %ebx,%eax
  803881:	83 c4 30             	add    $0x30,%esp
  803884:	5b                   	pop    %ebx
  803885:	5e                   	pop    %esi
  803886:	5d                   	pop    %ebp
  803887:	c3                   	ret    

00803888 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803888:	55                   	push   %ebp
  803889:	89 e5                	mov    %esp,%ebp
  80388b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  80388e:	89 d0                	mov    %edx,%eax
  803890:	c1 e8 16             	shr    $0x16,%eax
  803893:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80389a:	a8 01                	test   $0x1,%al
  80389c:	74 25                	je     8038c3 <pageref+0x3b>
		return 0;
	pte = vpt[VPN(v)];
  80389e:	89 d0                	mov    %edx,%eax
  8038a0:	c1 e8 0c             	shr    $0xc,%eax
  8038a3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8038aa:	a8 01                	test   $0x1,%al
  8038ac:	74 15                	je     8038c3 <pageref+0x3b>
		return 0;
	return pages[PPN(pte)].pp_ref;
  8038ae:	c1 e8 0c             	shr    $0xc,%eax
  8038b1:	8d 04 40             	lea    (%eax,%eax,2),%eax
  8038b4:	c1 e0 02             	shl    $0x2,%eax
  8038b7:	0f b7 80 08 00 00 ef 	movzwl -0x10fffff8(%eax),%eax
  8038be:	0f b7 c0             	movzwl %ax,%eax
  8038c1:	eb 05                	jmp    8038c8 <pageref+0x40>
  8038c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8038c8:	5d                   	pop    %ebp
  8038c9:	c3                   	ret    
  8038ca:	00 00                	add    %al,(%eax)
  8038cc:	00 00                	add    %al,(%eax)
	...

008038d0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8038d0:	55                   	push   %ebp
  8038d1:	89 e5                	mov    %esp,%ebp
  8038d3:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  8038d6:	c7 44 24 04 f8 49 80 	movl   $0x8049f8,0x4(%esp)
  8038dd:	00 
  8038de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8038e1:	89 04 24             	mov    %eax,(%esp)
  8038e4:	e8 18 ec ff ff       	call   802501 <strcpy>
	return 0;
}
  8038e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8038ee:	c9                   	leave  
  8038ef:	c3                   	ret    

008038f0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8038f0:	55                   	push   %ebp
  8038f1:	89 e5                	mov    %esp,%ebp
  8038f3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_close(fd->fd_sock.sockid);
  8038f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8038f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8038fc:	89 04 24             	mov    %eax,(%esp)
  8038ff:	e8 9e 02 00 00       	call   803ba2 <nsipc_close>
}
  803904:	c9                   	leave  
  803905:	c3                   	ret    

00803906 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  803906:	55                   	push   %ebp
  803907:	89 e5                	mov    %esp,%ebp
  803909:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80390c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  803913:	00 
  803914:	8b 45 10             	mov    0x10(%ebp),%eax
  803917:	89 44 24 08          	mov    %eax,0x8(%esp)
  80391b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80391e:	89 44 24 04          	mov    %eax,0x4(%esp)
  803922:	8b 45 08             	mov    0x8(%ebp),%eax
  803925:	8b 40 0c             	mov    0xc(%eax),%eax
  803928:	89 04 24             	mov    %eax,(%esp)
  80392b:	e8 ae 02 00 00       	call   803bde <nsipc_send>
}
  803930:	c9                   	leave  
  803931:	c3                   	ret    

00803932 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  803932:	55                   	push   %ebp
  803933:	89 e5                	mov    %esp,%ebp
  803935:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  803938:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80393f:	00 
  803940:	8b 45 10             	mov    0x10(%ebp),%eax
  803943:	89 44 24 08          	mov    %eax,0x8(%esp)
  803947:	8b 45 0c             	mov    0xc(%ebp),%eax
  80394a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80394e:	8b 45 08             	mov    0x8(%ebp),%eax
  803951:	8b 40 0c             	mov    0xc(%eax),%eax
  803954:	89 04 24             	mov    %eax,(%esp)
  803957:	e8 f5 02 00 00       	call   803c51 <nsipc_recv>
}
  80395c:	c9                   	leave  
  80395d:	c3                   	ret    

0080395e <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  80395e:	55                   	push   %ebp
  80395f:	89 e5                	mov    %esp,%ebp
  803961:	56                   	push   %esi
  803962:	53                   	push   %ebx
  803963:	83 ec 20             	sub    $0x20,%esp
  803966:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  803968:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80396b:	89 04 24             	mov    %eax,(%esp)
  80396e:	e8 68 f6 ff ff       	call   802fdb <fd_alloc>
  803973:	89 c3                	mov    %eax,%ebx
  803975:	85 c0                	test   %eax,%eax
  803977:	78 21                	js     80399a <alloc_sockfd+0x3c>
  803979:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  803980:	00 
  803981:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803984:	89 44 24 04          	mov    %eax,0x4(%esp)
  803988:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80398f:	e8 a6 f2 ff ff       	call   802c3a <sys_page_alloc>
  803994:	89 c3                	mov    %eax,%ebx
  803996:	85 c0                	test   %eax,%eax
  803998:	79 0a                	jns    8039a4 <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U)) < 0) {
		nsipc_close(sockid);
  80399a:	89 34 24             	mov    %esi,(%esp)
  80399d:	e8 00 02 00 00       	call   803ba2 <nsipc_close>
  8039a2:	eb 28                	jmp    8039cc <alloc_sockfd+0x6e>
		return r;
	}

	sfd->fd_dev_id = devsock.dev_id;
  8039a4:	8b 15 84 c0 80 00    	mov    0x80c084,%edx
  8039aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8039ad:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8039af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8039b2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8039b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8039bc:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8039bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8039c2:	89 04 24             	mov    %eax,(%esp)
  8039c5:	e8 e6 f5 ff ff       	call   802fb0 <fd2num>
  8039ca:	89 c3                	mov    %eax,%ebx
}
  8039cc:	89 d8                	mov    %ebx,%eax
  8039ce:	83 c4 20             	add    $0x20,%esp
  8039d1:	5b                   	pop    %ebx
  8039d2:	5e                   	pop    %esi
  8039d3:	5d                   	pop    %ebp
  8039d4:	c3                   	ret    

008039d5 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8039d5:	55                   	push   %ebp
  8039d6:	89 e5                	mov    %esp,%ebp
  8039d8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8039db:	8b 45 10             	mov    0x10(%ebp),%eax
  8039de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8039e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8039e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8039e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8039ec:	89 04 24             	mov    %eax,(%esp)
  8039ef:	e8 62 01 00 00       	call   803b56 <nsipc_socket>
  8039f4:	85 c0                	test   %eax,%eax
  8039f6:	78 05                	js     8039fd <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8039f8:	e8 61 ff ff ff       	call   80395e <alloc_sockfd>
}
  8039fd:	c9                   	leave  
  8039fe:	66 90                	xchg   %ax,%ax
  803a00:	c3                   	ret    

00803a01 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  803a01:	55                   	push   %ebp
  803a02:	89 e5                	mov    %esp,%ebp
  803a04:	83 ec 18             	sub    $0x18,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  803a07:	8d 55 fc             	lea    -0x4(%ebp),%edx
  803a0a:	89 54 24 04          	mov    %edx,0x4(%esp)
  803a0e:	89 04 24             	mov    %eax,(%esp)
  803a11:	e8 18 f6 ff ff       	call   80302e <fd_lookup>
  803a16:	89 c2                	mov    %eax,%edx
  803a18:	85 c0                	test   %eax,%eax
  803a1a:	78 15                	js     803a31 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  803a1c:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  803a1f:	8b 01                	mov    (%ecx),%eax
  803a21:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  803a26:	3b 05 84 c0 80 00    	cmp    0x80c084,%eax
  803a2c:	75 03                	jne    803a31 <fd2sockid+0x30>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  803a2e:	8b 51 0c             	mov    0xc(%ecx),%edx
}
  803a31:	89 d0                	mov    %edx,%eax
  803a33:	c9                   	leave  
  803a34:	c3                   	ret    

00803a35 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  803a35:	55                   	push   %ebp
  803a36:	89 e5                	mov    %esp,%ebp
  803a38:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  803a3e:	e8 be ff ff ff       	call   803a01 <fd2sockid>
  803a43:	85 c0                	test   %eax,%eax
  803a45:	78 0f                	js     803a56 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  803a47:	8b 55 0c             	mov    0xc(%ebp),%edx
  803a4a:	89 54 24 04          	mov    %edx,0x4(%esp)
  803a4e:	89 04 24             	mov    %eax,(%esp)
  803a51:	e8 2a 01 00 00       	call   803b80 <nsipc_listen>
}
  803a56:	c9                   	leave  
  803a57:	c3                   	ret    

00803a58 <connect>:
	return nsipc_close(fd->fd_sock.sockid);
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  803a58:	55                   	push   %ebp
  803a59:	89 e5                	mov    %esp,%ebp
  803a5b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  803a61:	e8 9b ff ff ff       	call   803a01 <fd2sockid>
  803a66:	85 c0                	test   %eax,%eax
  803a68:	78 16                	js     803a80 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  803a6a:	8b 55 10             	mov    0x10(%ebp),%edx
  803a6d:	89 54 24 08          	mov    %edx,0x8(%esp)
  803a71:	8b 55 0c             	mov    0xc(%ebp),%edx
  803a74:	89 54 24 04          	mov    %edx,0x4(%esp)
  803a78:	89 04 24             	mov    %eax,(%esp)
  803a7b:	e8 51 02 00 00       	call   803cd1 <nsipc_connect>
}
  803a80:	c9                   	leave  
  803a81:	c3                   	ret    

00803a82 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  803a82:	55                   	push   %ebp
  803a83:	89 e5                	mov    %esp,%ebp
  803a85:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803a88:	8b 45 08             	mov    0x8(%ebp),%eax
  803a8b:	e8 71 ff ff ff       	call   803a01 <fd2sockid>
  803a90:	85 c0                	test   %eax,%eax
  803a92:	78 0f                	js     803aa3 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  803a94:	8b 55 0c             	mov    0xc(%ebp),%edx
  803a97:	89 54 24 04          	mov    %edx,0x4(%esp)
  803a9b:	89 04 24             	mov    %eax,(%esp)
  803a9e:	e8 19 01 00 00       	call   803bbc <nsipc_shutdown>
}
  803aa3:	c9                   	leave  
  803aa4:	c3                   	ret    

00803aa5 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  803aa5:	55                   	push   %ebp
  803aa6:	89 e5                	mov    %esp,%ebp
  803aa8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803aab:	8b 45 08             	mov    0x8(%ebp),%eax
  803aae:	e8 4e ff ff ff       	call   803a01 <fd2sockid>
  803ab3:	85 c0                	test   %eax,%eax
  803ab5:	78 16                	js     803acd <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  803ab7:	8b 55 10             	mov    0x10(%ebp),%edx
  803aba:	89 54 24 08          	mov    %edx,0x8(%esp)
  803abe:	8b 55 0c             	mov    0xc(%ebp),%edx
  803ac1:	89 54 24 04          	mov    %edx,0x4(%esp)
  803ac5:	89 04 24             	mov    %eax,(%esp)
  803ac8:	e8 43 02 00 00       	call   803d10 <nsipc_bind>
}
  803acd:	c9                   	leave  
  803ace:	c3                   	ret    

00803acf <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  803acf:	55                   	push   %ebp
  803ad0:	89 e5                	mov    %esp,%ebp
  803ad2:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  803ad8:	e8 24 ff ff ff       	call   803a01 <fd2sockid>
  803add:	85 c0                	test   %eax,%eax
  803adf:	78 1f                	js     803b00 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  803ae1:	8b 55 10             	mov    0x10(%ebp),%edx
  803ae4:	89 54 24 08          	mov    %edx,0x8(%esp)
  803ae8:	8b 55 0c             	mov    0xc(%ebp),%edx
  803aeb:	89 54 24 04          	mov    %edx,0x4(%esp)
  803aef:	89 04 24             	mov    %eax,(%esp)
  803af2:	e8 58 02 00 00       	call   803d4f <nsipc_accept>
  803af7:	85 c0                	test   %eax,%eax
  803af9:	78 05                	js     803b00 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  803afb:	e8 5e fe ff ff       	call   80395e <alloc_sockfd>
}
  803b00:	c9                   	leave  
  803b01:	c3                   	ret    
	...

00803b10 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  803b10:	55                   	push   %ebp
  803b11:	89 e5                	mov    %esp,%ebp
  803b13:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  803b16:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  803b1c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  803b23:	00 
  803b24:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  803b2b:	00 
  803b2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  803b30:	89 14 24             	mov    %edx,(%esp)
  803b33:	e8 d8 f2 ff ff       	call   802e10 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  803b38:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803b3f:	00 
  803b40:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  803b47:	00 
  803b48:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803b4f:	e8 70 f3 ff ff       	call   802ec4 <ipc_recv>
}
  803b54:	c9                   	leave  
  803b55:	c3                   	ret    

00803b56 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  803b56:	55                   	push   %ebp
  803b57:	89 e5                	mov    %esp,%ebp
  803b59:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  803b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  803b5f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  803b64:	8b 45 0c             	mov    0xc(%ebp),%eax
  803b67:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  803b6c:	8b 45 10             	mov    0x10(%ebp),%eax
  803b6f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  803b74:	b8 09 00 00 00       	mov    $0x9,%eax
  803b79:	e8 92 ff ff ff       	call   803b10 <nsipc>
}
  803b7e:	c9                   	leave  
  803b7f:	c3                   	ret    

00803b80 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  803b80:	55                   	push   %ebp
  803b81:	89 e5                	mov    %esp,%ebp
  803b83:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  803b86:	8b 45 08             	mov    0x8(%ebp),%eax
  803b89:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  803b8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  803b91:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  803b96:	b8 06 00 00 00       	mov    $0x6,%eax
  803b9b:	e8 70 ff ff ff       	call   803b10 <nsipc>
}
  803ba0:	c9                   	leave  
  803ba1:	c3                   	ret    

00803ba2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  803ba2:	55                   	push   %ebp
  803ba3:	89 e5                	mov    %esp,%ebp
  803ba5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  803ba8:	8b 45 08             	mov    0x8(%ebp),%eax
  803bab:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  803bb0:	b8 04 00 00 00       	mov    $0x4,%eax
  803bb5:	e8 56 ff ff ff       	call   803b10 <nsipc>
}
  803bba:	c9                   	leave  
  803bbb:	c3                   	ret    

00803bbc <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  803bbc:	55                   	push   %ebp
  803bbd:	89 e5                	mov    %esp,%ebp
  803bbf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  803bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  803bc5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  803bca:	8b 45 0c             	mov    0xc(%ebp),%eax
  803bcd:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  803bd2:	b8 03 00 00 00       	mov    $0x3,%eax
  803bd7:	e8 34 ff ff ff       	call   803b10 <nsipc>
}
  803bdc:	c9                   	leave  
  803bdd:	c3                   	ret    

00803bde <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  803bde:	55                   	push   %ebp
  803bdf:	89 e5                	mov    %esp,%ebp
  803be1:	53                   	push   %ebx
  803be2:	83 ec 14             	sub    $0x14,%esp
  803be5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  803be8:	8b 45 08             	mov    0x8(%ebp),%eax
  803beb:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  803bf0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  803bf6:	7e 24                	jle    803c1c <nsipc_send+0x3e>
  803bf8:	c7 44 24 0c 04 4a 80 	movl   $0x804a04,0xc(%esp)
  803bff:	00 
  803c00:	c7 44 24 08 7d 40 80 	movl   $0x80407d,0x8(%esp)
  803c07:	00 
  803c08:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  803c0f:	00 
  803c10:	c7 04 24 10 4a 80 00 	movl   $0x804a10,(%esp)
  803c17:	e8 b0 e1 ff ff       	call   801dcc <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  803c1c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803c20:	8b 45 0c             	mov    0xc(%ebp),%eax
  803c23:	89 44 24 04          	mov    %eax,0x4(%esp)
  803c27:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  803c2e:	e8 d5 ea ff ff       	call   802708 <memmove>
	nsipcbuf.send.req_size = size;
  803c33:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  803c39:	8b 45 14             	mov    0x14(%ebp),%eax
  803c3c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  803c41:	b8 08 00 00 00       	mov    $0x8,%eax
  803c46:	e8 c5 fe ff ff       	call   803b10 <nsipc>
}
  803c4b:	83 c4 14             	add    $0x14,%esp
  803c4e:	5b                   	pop    %ebx
  803c4f:	5d                   	pop    %ebp
  803c50:	c3                   	ret    

00803c51 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  803c51:	55                   	push   %ebp
  803c52:	89 e5                	mov    %esp,%ebp
  803c54:	56                   	push   %esi
  803c55:	53                   	push   %ebx
  803c56:	83 ec 10             	sub    $0x10,%esp
  803c59:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  803c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  803c5f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  803c64:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  803c6a:	8b 45 14             	mov    0x14(%ebp),%eax
  803c6d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  803c72:	b8 07 00 00 00       	mov    $0x7,%eax
  803c77:	e8 94 fe ff ff       	call   803b10 <nsipc>
  803c7c:	89 c3                	mov    %eax,%ebx
  803c7e:	85 c0                	test   %eax,%eax
  803c80:	78 46                	js     803cc8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  803c82:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  803c87:	7f 04                	jg     803c8d <nsipc_recv+0x3c>
  803c89:	39 c6                	cmp    %eax,%esi
  803c8b:	7d 24                	jge    803cb1 <nsipc_recv+0x60>
  803c8d:	c7 44 24 0c 1c 4a 80 	movl   $0x804a1c,0xc(%esp)
  803c94:	00 
  803c95:	c7 44 24 08 7d 40 80 	movl   $0x80407d,0x8(%esp)
  803c9c:	00 
  803c9d:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  803ca4:	00 
  803ca5:	c7 04 24 10 4a 80 00 	movl   $0x804a10,(%esp)
  803cac:	e8 1b e1 ff ff       	call   801dcc <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  803cb1:	89 44 24 08          	mov    %eax,0x8(%esp)
  803cb5:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  803cbc:	00 
  803cbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  803cc0:	89 04 24             	mov    %eax,(%esp)
  803cc3:	e8 40 ea ff ff       	call   802708 <memmove>
	}

	return r;
}
  803cc8:	89 d8                	mov    %ebx,%eax
  803cca:	83 c4 10             	add    $0x10,%esp
  803ccd:	5b                   	pop    %ebx
  803cce:	5e                   	pop    %esi
  803ccf:	5d                   	pop    %ebp
  803cd0:	c3                   	ret    

00803cd1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  803cd1:	55                   	push   %ebp
  803cd2:	89 e5                	mov    %esp,%ebp
  803cd4:	53                   	push   %ebx
  803cd5:	83 ec 14             	sub    $0x14,%esp
  803cd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  803cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  803cde:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  803ce3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803ce7:	8b 45 0c             	mov    0xc(%ebp),%eax
  803cea:	89 44 24 04          	mov    %eax,0x4(%esp)
  803cee:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  803cf5:	e8 0e ea ff ff       	call   802708 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  803cfa:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  803d00:	b8 05 00 00 00       	mov    $0x5,%eax
  803d05:	e8 06 fe ff ff       	call   803b10 <nsipc>
}
  803d0a:	83 c4 14             	add    $0x14,%esp
  803d0d:	5b                   	pop    %ebx
  803d0e:	5d                   	pop    %ebp
  803d0f:	c3                   	ret    

00803d10 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  803d10:	55                   	push   %ebp
  803d11:	89 e5                	mov    %esp,%ebp
  803d13:	53                   	push   %ebx
  803d14:	83 ec 14             	sub    $0x14,%esp
  803d17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  803d1a:	8b 45 08             	mov    0x8(%ebp),%eax
  803d1d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  803d22:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803d26:	8b 45 0c             	mov    0xc(%ebp),%eax
  803d29:	89 44 24 04          	mov    %eax,0x4(%esp)
  803d2d:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  803d34:	e8 cf e9 ff ff       	call   802708 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  803d39:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  803d3f:	b8 02 00 00 00       	mov    $0x2,%eax
  803d44:	e8 c7 fd ff ff       	call   803b10 <nsipc>
}
  803d49:	83 c4 14             	add    $0x14,%esp
  803d4c:	5b                   	pop    %ebx
  803d4d:	5d                   	pop    %ebp
  803d4e:	c3                   	ret    

00803d4f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  803d4f:	55                   	push   %ebp
  803d50:	89 e5                	mov    %esp,%ebp
  803d52:	53                   	push   %ebx
  803d53:	83 ec 14             	sub    $0x14,%esp
	int r;
	
	nsipcbuf.accept.req_s = s;
  803d56:	8b 45 08             	mov    0x8(%ebp),%eax
  803d59:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  803d5e:	b8 01 00 00 00       	mov    $0x1,%eax
  803d63:	e8 a8 fd ff ff       	call   803b10 <nsipc>
  803d68:	89 c3                	mov    %eax,%ebx
  803d6a:	85 c0                	test   %eax,%eax
  803d6c:	78 26                	js     803d94 <nsipc_accept+0x45>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  803d6e:	a1 10 70 80 00       	mov    0x807010,%eax
  803d73:	89 44 24 08          	mov    %eax,0x8(%esp)
  803d77:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  803d7e:	00 
  803d7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  803d82:	89 04 24             	mov    %eax,(%esp)
  803d85:	e8 7e e9 ff ff       	call   802708 <memmove>
		*addrlen = ret->ret_addrlen;
  803d8a:	a1 10 70 80 00       	mov    0x807010,%eax
  803d8f:	8b 55 10             	mov    0x10(%ebp),%edx
  803d92:	89 02                	mov    %eax,(%edx)
	}
	return r;
}
  803d94:	89 d8                	mov    %ebx,%eax
  803d96:	83 c4 14             	add    $0x14,%esp
  803d99:	5b                   	pop    %ebx
  803d9a:	5d                   	pop    %ebp
  803d9b:	c3                   	ret    
  803d9c:	00 00                	add    %al,(%eax)
	...

00803da0 <__udivdi3>:
  803da0:	55                   	push   %ebp
  803da1:	89 e5                	mov    %esp,%ebp
  803da3:	57                   	push   %edi
  803da4:	56                   	push   %esi
  803da5:	83 ec 18             	sub    $0x18,%esp
  803da8:	8b 45 10             	mov    0x10(%ebp),%eax
  803dab:	8b 55 14             	mov    0x14(%ebp),%edx
  803dae:	8b 75 0c             	mov    0xc(%ebp),%esi
  803db1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  803db4:	89 c1                	mov    %eax,%ecx
  803db6:	8b 45 08             	mov    0x8(%ebp),%eax
  803db9:	85 d2                	test   %edx,%edx
  803dbb:	89 d7                	mov    %edx,%edi
  803dbd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  803dc0:	75 1e                	jne    803de0 <__udivdi3+0x40>
  803dc2:	39 f1                	cmp    %esi,%ecx
  803dc4:	0f 86 8d 00 00 00    	jbe    803e57 <__udivdi3+0xb7>
  803dca:	89 f2                	mov    %esi,%edx
  803dcc:	31 f6                	xor    %esi,%esi
  803dce:	f7 f1                	div    %ecx
  803dd0:	89 c1                	mov    %eax,%ecx
  803dd2:	89 c8                	mov    %ecx,%eax
  803dd4:	89 f2                	mov    %esi,%edx
  803dd6:	83 c4 18             	add    $0x18,%esp
  803dd9:	5e                   	pop    %esi
  803dda:	5f                   	pop    %edi
  803ddb:	5d                   	pop    %ebp
  803ddc:	c3                   	ret    
  803ddd:	8d 76 00             	lea    0x0(%esi),%esi
  803de0:	39 f2                	cmp    %esi,%edx
  803de2:	0f 87 a8 00 00 00    	ja     803e90 <__udivdi3+0xf0>
  803de8:	0f bd c2             	bsr    %edx,%eax
  803deb:	83 f0 1f             	xor    $0x1f,%eax
  803dee:	89 45 e8             	mov    %eax,-0x18(%ebp)
  803df1:	0f 84 89 00 00 00    	je     803e80 <__udivdi3+0xe0>
  803df7:	b8 20 00 00 00       	mov    $0x20,%eax
  803dfc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803dff:	2b 45 e8             	sub    -0x18(%ebp),%eax
  803e02:	89 c1                	mov    %eax,%ecx
  803e04:	d3 ea                	shr    %cl,%edx
  803e06:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  803e0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  803e0d:	89 f8                	mov    %edi,%eax
  803e0f:	8b 7d f4             	mov    -0xc(%ebp),%edi
  803e12:	d3 e0                	shl    %cl,%eax
  803e14:	09 c2                	or     %eax,%edx
  803e16:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803e19:	d3 e7                	shl    %cl,%edi
  803e1b:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803e1f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  803e22:	89 f2                	mov    %esi,%edx
  803e24:	d3 e8                	shr    %cl,%eax
  803e26:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  803e2a:	d3 e2                	shl    %cl,%edx
  803e2c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803e30:	09 d0                	or     %edx,%eax
  803e32:	d3 ee                	shr    %cl,%esi
  803e34:	89 f2                	mov    %esi,%edx
  803e36:	f7 75 e4             	divl   -0x1c(%ebp)
  803e39:	89 d1                	mov    %edx,%ecx
  803e3b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  803e3e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  803e41:	f7 e7                	mul    %edi
  803e43:	39 d1                	cmp    %edx,%ecx
  803e45:	89 c6                	mov    %eax,%esi
  803e47:	72 70                	jb     803eb9 <__udivdi3+0x119>
  803e49:	39 ca                	cmp    %ecx,%edx
  803e4b:	74 5f                	je     803eac <__udivdi3+0x10c>
  803e4d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  803e50:	31 f6                	xor    %esi,%esi
  803e52:	e9 7b ff ff ff       	jmp    803dd2 <__udivdi3+0x32>
  803e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803e5a:	85 c0                	test   %eax,%eax
  803e5c:	75 0c                	jne    803e6a <__udivdi3+0xca>
  803e5e:	b8 01 00 00 00       	mov    $0x1,%eax
  803e63:	31 d2                	xor    %edx,%edx
  803e65:	f7 75 f4             	divl   -0xc(%ebp)
  803e68:	89 c1                	mov    %eax,%ecx
  803e6a:	89 f0                	mov    %esi,%eax
  803e6c:	89 fa                	mov    %edi,%edx
  803e6e:	f7 f1                	div    %ecx
  803e70:	89 c6                	mov    %eax,%esi
  803e72:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803e75:	f7 f1                	div    %ecx
  803e77:	89 c1                	mov    %eax,%ecx
  803e79:	e9 54 ff ff ff       	jmp    803dd2 <__udivdi3+0x32>
  803e7e:	66 90                	xchg   %ax,%ax
  803e80:	39 d6                	cmp    %edx,%esi
  803e82:	77 1c                	ja     803ea0 <__udivdi3+0x100>
  803e84:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803e87:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  803e8a:	73 14                	jae    803ea0 <__udivdi3+0x100>
  803e8c:	8d 74 26 00          	lea    0x0(%esi),%esi
  803e90:	31 c9                	xor    %ecx,%ecx
  803e92:	31 f6                	xor    %esi,%esi
  803e94:	e9 39 ff ff ff       	jmp    803dd2 <__udivdi3+0x32>
  803e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  803ea0:	b9 01 00 00 00       	mov    $0x1,%ecx
  803ea5:	31 f6                	xor    %esi,%esi
  803ea7:	e9 26 ff ff ff       	jmp    803dd2 <__udivdi3+0x32>
  803eac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803eaf:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  803eb3:	d3 e0                	shl    %cl,%eax
  803eb5:	39 c6                	cmp    %eax,%esi
  803eb7:	76 94                	jbe    803e4d <__udivdi3+0xad>
  803eb9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  803ebc:	31 f6                	xor    %esi,%esi
  803ebe:	83 e9 01             	sub    $0x1,%ecx
  803ec1:	e9 0c ff ff ff       	jmp    803dd2 <__udivdi3+0x32>
	...

00803ed0 <__umoddi3>:
  803ed0:	55                   	push   %ebp
  803ed1:	89 e5                	mov    %esp,%ebp
  803ed3:	57                   	push   %edi
  803ed4:	56                   	push   %esi
  803ed5:	83 ec 30             	sub    $0x30,%esp
  803ed8:	8b 45 10             	mov    0x10(%ebp),%eax
  803edb:	8b 55 14             	mov    0x14(%ebp),%edx
  803ede:	8b 75 08             	mov    0x8(%ebp),%esi
  803ee1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  803ee4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  803ee7:	89 c1                	mov    %eax,%ecx
  803ee9:	89 55 e8             	mov    %edx,-0x18(%ebp)
  803eec:	8b 45 e8             	mov    -0x18(%ebp),%eax
  803eef:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  803ef6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  803efd:	89 fa                	mov    %edi,%edx
  803eff:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  803f02:	85 c0                	test   %eax,%eax
  803f04:	89 75 f0             	mov    %esi,-0x10(%ebp)
  803f07:	89 7d e0             	mov    %edi,-0x20(%ebp)
  803f0a:	75 14                	jne    803f20 <__umoddi3+0x50>
  803f0c:	39 f9                	cmp    %edi,%ecx
  803f0e:	76 60                	jbe    803f70 <__umoddi3+0xa0>
  803f10:	89 f0                	mov    %esi,%eax
  803f12:	f7 f1                	div    %ecx
  803f14:	89 55 d0             	mov    %edx,-0x30(%ebp)
  803f17:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  803f1e:	eb 10                	jmp    803f30 <__umoddi3+0x60>
  803f20:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  803f23:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  803f26:	76 18                	jbe    803f40 <__umoddi3+0x70>
  803f28:	89 75 d0             	mov    %esi,-0x30(%ebp)
  803f2b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  803f2e:	66 90                	xchg   %ax,%ax
  803f30:	8b 45 d0             	mov    -0x30(%ebp),%eax
  803f33:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  803f36:	83 c4 30             	add    $0x30,%esp
  803f39:	5e                   	pop    %esi
  803f3a:	5f                   	pop    %edi
  803f3b:	5d                   	pop    %ebp
  803f3c:	c3                   	ret    
  803f3d:	8d 76 00             	lea    0x0(%esi),%esi
  803f40:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
  803f44:	83 f0 1f             	xor    $0x1f,%eax
  803f47:	89 45 d8             	mov    %eax,-0x28(%ebp)
  803f4a:	75 46                	jne    803f92 <__umoddi3+0xc2>
  803f4c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  803f4f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  803f52:	0f 87 c9 00 00 00    	ja     804021 <__umoddi3+0x151>
  803f58:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  803f5b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  803f5e:	0f 83 bd 00 00 00    	jae    804021 <__umoddi3+0x151>
  803f64:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  803f67:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  803f6a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  803f6d:	eb c1                	jmp    803f30 <__umoddi3+0x60>
  803f6f:	90                   	nop    
  803f70:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803f73:	85 c0                	test   %eax,%eax
  803f75:	75 0c                	jne    803f83 <__umoddi3+0xb3>
  803f77:	b8 01 00 00 00       	mov    $0x1,%eax
  803f7c:	31 d2                	xor    %edx,%edx
  803f7e:	f7 75 ec             	divl   -0x14(%ebp)
  803f81:	89 c1                	mov    %eax,%ecx
  803f83:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803f86:	8b 55 e8             	mov    -0x18(%ebp),%edx
  803f89:	f7 f1                	div    %ecx
  803f8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803f8e:	f7 f1                	div    %ecx
  803f90:	eb 82                	jmp    803f14 <__umoddi3+0x44>
  803f92:	b8 20 00 00 00       	mov    $0x20,%eax
  803f97:	8b 55 ec             	mov    -0x14(%ebp),%edx
  803f9a:	2b 45 d8             	sub    -0x28(%ebp),%eax
  803f9d:	8b 75 ec             	mov    -0x14(%ebp),%esi
  803fa0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  803fa3:	89 c1                	mov    %eax,%ecx
  803fa5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  803fa8:	d3 ea                	shr    %cl,%edx
  803faa:	8b 45 e8             	mov    -0x18(%ebp),%eax
  803fad:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  803fb1:	d3 e0                	shl    %cl,%eax
  803fb3:	09 c2                	or     %eax,%edx
  803fb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803fb8:	d3 e6                	shl    %cl,%esi
  803fba:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  803fbe:	89 55 f4             	mov    %edx,-0xc(%ebp)
  803fc1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  803fc4:	d3 e8                	shr    %cl,%eax
  803fc6:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  803fca:	d3 e2                	shl    %cl,%edx
  803fcc:	09 d0                	or     %edx,%eax
  803fce:	8b 55 e0             	mov    -0x20(%ebp),%edx
  803fd1:	d3 e7                	shl    %cl,%edi
  803fd3:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  803fd7:	d3 ea                	shr    %cl,%edx
  803fd9:	f7 75 f4             	divl   -0xc(%ebp)
  803fdc:	89 55 cc             	mov    %edx,-0x34(%ebp)
  803fdf:	f7 e6                	mul    %esi
  803fe1:	39 55 cc             	cmp    %edx,-0x34(%ebp)
  803fe4:	72 53                	jb     804039 <__umoddi3+0x169>
  803fe6:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  803fe9:	74 4a                	je     804035 <__umoddi3+0x165>
  803feb:	90                   	nop    
  803fec:	8d 74 26 00          	lea    0x0(%esi),%esi
  803ff0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  803ff3:	29 c7                	sub    %eax,%edi
  803ff5:	19 d1                	sbb    %edx,%ecx
  803ff7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  803ffa:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  803ffe:	89 fa                	mov    %edi,%edx
  804000:	8b 45 cc             	mov    -0x34(%ebp),%eax
  804003:	d3 ea                	shr    %cl,%edx
  804005:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  804009:	d3 e0                	shl    %cl,%eax
  80400b:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  80400f:	09 c2                	or     %eax,%edx
  804011:	8b 45 cc             	mov    -0x34(%ebp),%eax
  804014:	89 55 d0             	mov    %edx,-0x30(%ebp)
  804017:	d3 e8                	shr    %cl,%eax
  804019:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80401c:	e9 0f ff ff ff       	jmp    803f30 <__umoddi3+0x60>
  804021:	8b 55 e0             	mov    -0x20(%ebp),%edx
  804024:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  804027:	2b 45 ec             	sub    -0x14(%ebp),%eax
  80402a:	1b 55 e8             	sbb    -0x18(%ebp),%edx
  80402d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  804030:	e9 2f ff ff ff       	jmp    803f64 <__umoddi3+0x94>
  804035:	39 f8                	cmp    %edi,%eax
  804037:	76 b7                	jbe    803ff0 <__umoddi3+0x120>
  804039:	29 f0                	sub    %esi,%eax
  80403b:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  80403e:	eb b0                	jmp    803ff0 <__umoddi3+0x120>
