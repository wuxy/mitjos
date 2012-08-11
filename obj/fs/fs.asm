
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
  80002c:	e8 bb 1d 00 00       	call   801dec <libmain>
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
  80007f:	c7 44 24 08 00 3c 80 	movl   $0x803c00,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  80008e:	00 
  80008f:	c7 04 24 10 3c 80 00 	movl   $0x803c10,(%esp)
  800096:	e8 c9 1d 00 00       	call   801e64 <_panic>
	diskno = d;
  80009b:	a3 00 70 80 00       	mov    %eax,0x807000
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
  8000f5:	c7 04 24 19 3c 80 00 	movl   $0x803c19,(%esp)
  8000fc:	e8 30 1e 00 00       	call   801f31 <cprintf>
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
  800120:	c7 44 24 0c 30 3c 80 	movl   $0x803c30,0xc(%esp)
  800127:	00 
  800128:	c7 44 24 08 3d 3c 80 	movl   $0x803c3d,0x8(%esp)
  80012f:	00 
  800130:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  800137:	00 
  800138:	c7 04 24 10 3c 80 00 	movl   $0x803c10,(%esp)
  80013f:	e8 20 1d 00 00       	call   801e64 <_panic>

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
  80016b:	0f b6 05 00 70 80 00 	movzbl 0x807000,%eax
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
  8001e9:	c7 44 24 0c 30 3c 80 	movl   $0x803c30,0xc(%esp)
  8001f0:	00 
  8001f1:	c7 44 24 08 3d 3c 80 	movl   $0x803c3d,0x8(%esp)
  8001f8:	00 
  8001f9:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800200:	00 
  800201:	c7 04 24 10 3c 80 00 	movl   $0x803c10,(%esp)
  800208:	e8 57 1c 00 00       	call   801e64 <_panic>

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
  800234:	0f b6 05 00 70 80 00 	movzbl 0x807000,%eax
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
  8002f5:	8b 15 88 b0 80 00    	mov    0x80b088,%edx
  8002fb:	85 d2                	test   %edx,%edx
  8002fd:	74 25                	je     800324 <diskaddr+0x3c>
  8002ff:	3b 42 04             	cmp    0x4(%edx),%eax
  800302:	72 20                	jb     800324 <diskaddr+0x3c>
		panic("bad block number %08x in diskaddr", blockno);
  800304:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800308:	c7 44 24 08 54 3c 80 	movl   $0x803c54,0x8(%esp)
  80030f:	00 
  800310:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  800317:	00 
  800318:	c7 04 24 f0 3c 80 00 	movl   $0x803cf0,(%esp)
  80031f:	e8 40 1b 00 00       	call   801e64 <_panic>
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
  80035a:	c7 44 24 08 78 3c 80 	movl   $0x803c78,0x8(%esp)
  800361:	00 
  800362:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  800369:	00 
  80036a:	c7 04 24 f0 3c 80 00 	movl   $0x803cf0,(%esp)
  800371:	e8 ee 1a 00 00       	call   801e64 <_panic>
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
  800393:	e8 fe 28 00 00       	call   802c96 <sys_page_alloc>
  800398:	85 c0                	test   %eax,%eax
  80039a:	79 20                	jns    8003bc <bc_pgfault+0x8e>
		panic("alloc page failed:%e\n",r);
  80039c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a0:	c7 44 24 08 f8 3c 80 	movl   $0x803cf8,0x8(%esp)
  8003a7:	00 
  8003a8:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  8003af:	00 
  8003b0:	c7 04 24 f0 3c 80 00 	movl   $0x803cf0,(%esp)
  8003b7:	e8 a8 1a 00 00       	call   801e64 <_panic>
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
  8003e2:	a1 88 b0 80 00       	mov    0x80b088,%eax
  8003e7:	85 c0                	test   %eax,%eax
  8003e9:	74 25                	je     800410 <bc_pgfault+0xe2>
  8003eb:	3b 58 04             	cmp    0x4(%eax),%ebx
  8003ee:	72 20                	jb     800410 <bc_pgfault+0xe2>
		panic("reading non-existent block %08x\n", blockno);
  8003f0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003f4:	c7 44 24 08 a8 3c 80 	movl   $0x803ca8,0x8(%esp)
  8003fb:	00 
  8003fc:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  800403:	00 
  800404:	c7 04 24 f0 3c 80 00 	movl   $0x803cf0,(%esp)
  80040b:	e8 54 1a 00 00       	call   801e64 <_panic>

	// Check that the block we read was allocated.
	if (bitmap && block_is_free(blockno))
  800410:	83 3d 84 b0 80 00 00 	cmpl   $0x0,0x80b084
  800417:	74 2c                	je     800445 <bc_pgfault+0x117>
  800419:	89 1c 24             	mov    %ebx,(%esp)
  80041c:	e8 cf 02 00 00       	call   8006f0 <block_is_free>
  800421:	85 c0                	test   %eax,%eax
  800423:	74 20                	je     800445 <bc_pgfault+0x117>
		panic("reading free block %08x\n", blockno);
  800425:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800429:	c7 44 24 08 0e 3d 80 	movl   $0x803d0e,0x8(%esp)
  800430:	00 
  800431:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  800438:	00 
  800439:	c7 04 24 f0 3c 80 00 	movl   $0x803cf0,(%esp)
  800440:	e8 1f 1a 00 00       	call   801e64 <_panic>
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
  80046c:	c7 44 24 08 27 3d 80 	movl   $0x803d27,0x8(%esp)
  800473:	00 
  800474:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  80047b:	00 
  80047c:	c7 04 24 f0 3c 80 00 	movl   $0x803cf0,(%esp)
  800483:	e8 dc 19 00 00       	call   801e64 <_panic>

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
  8004e9:	e8 4a 27 00 00       	call   802c38 <sys_page_map>
  8004ee:	85 c0                	test   %eax,%eax
  8004f0:	79 20                	jns    800512 <flush_block+0xc6>
			panic("page mapping failed:%e\n",r);
  8004f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f6:	c7 44 24 08 42 3d 80 	movl   $0x803d42,0x8(%esp)
  8004fd:	00 
  8004fe:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  800505:	00 
  800506:	c7 04 24 f0 3c 80 00 	movl   $0x803cf0,(%esp)
  80050d:	e8 52 19 00 00       	call   801e64 <_panic>
		
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
  80052c:	e8 8b 28 00 00       	call   802dbc <set_pgfault_handler>
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
  800552:	e8 41 22 00 00       	call   802798 <memmove>
	//cprintf("check bc:magic=%x nblocks=%x\n",backup.s_magic,backup.s_nblocks);
	// smash it 
	strcpy(diskaddr(1), "OOPS!\n");
  800557:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80055e:	e8 85 fd ff ff       	call   8002e8 <diskaddr>
  800563:	c7 44 24 04 5a 3d 80 	movl   $0x803d5a,0x4(%esp)
  80056a:	00 
  80056b:	89 04 24             	mov    %eax,(%esp)
  80056e:	e8 1e 20 00 00       	call   802591 <strcpy>
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
  80059f:	c7 44 24 0c 7c 3d 80 	movl   $0x803d7c,0xc(%esp)
  8005a6:	00 
  8005a7:	c7 44 24 08 3d 3c 80 	movl   $0x803c3d,0x8(%esp)
  8005ae:	00 
  8005af:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
  8005b6:	00 
  8005b7:	c7 04 24 f0 3c 80 00 	movl   $0x803cf0,(%esp)
  8005be:	e8 a1 18 00 00       	call   801e64 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  8005c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005ca:	e8 19 fd ff ff       	call   8002e8 <diskaddr>
  8005cf:	89 04 24             	mov    %eax,(%esp)
  8005d2:	e8 f9 fc ff ff       	call   8002d0 <va_is_dirty>
  8005d7:	85 c0                	test   %eax,%eax
  8005d9:	74 24                	je     8005ff <bc_init+0xe3>
  8005db:	c7 44 24 0c 61 3d 80 	movl   $0x803d61,0xc(%esp)
  8005e2:	00 
  8005e3:	c7 44 24 08 3d 3c 80 	movl   $0x803c3d,0x8(%esp)
  8005ea:	00 
  8005eb:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
  8005f2:	00 
  8005f3:	c7 04 24 f0 3c 80 00 	movl   $0x803cf0,(%esp)
  8005fa:	e8 65 18 00 00       	call   801e64 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  8005ff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800606:	e8 dd fc ff ff       	call   8002e8 <diskaddr>
  80060b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800616:	e8 bf 25 00 00       	call   802bda <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  80061b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800622:	e8 c1 fc ff ff       	call   8002e8 <diskaddr>
  800627:	89 04 24             	mov    %eax,(%esp)
  80062a:	e8 71 fc ff ff       	call   8002a0 <va_is_mapped>
  80062f:	85 c0                	test   %eax,%eax
  800631:	74 24                	je     800657 <bc_init+0x13b>
  800633:	c7 44 24 0c 7b 3d 80 	movl   $0x803d7b,0xc(%esp)
  80063a:	00 
  80063b:	c7 44 24 08 3d 3c 80 	movl   $0x803c3d,0x8(%esp)
  800642:	00 
  800643:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  80064a:	00 
  80064b:	c7 04 24 f0 3c 80 00 	movl   $0x803cf0,(%esp)
  800652:	e8 0d 18 00 00       	call   801e64 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  800657:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80065e:	e8 85 fc ff ff       	call   8002e8 <diskaddr>
  800663:	c7 44 24 04 5a 3d 80 	movl   $0x803d5a,0x4(%esp)
  80066a:	00 
  80066b:	89 04 24             	mov    %eax,(%esp)
  80066e:	e8 fe 1f 00 00       	call   802671 <strcmp>
  800673:	85 c0                	test   %eax,%eax
  800675:	74 24                	je     80069b <bc_init+0x17f>
  800677:	c7 44 24 0c cc 3c 80 	movl   $0x803ccc,0xc(%esp)
  80067e:	00 
  80067f:	c7 44 24 08 3d 3c 80 	movl   $0x803c3d,0x8(%esp)
  800686:	00 
  800687:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  80068e:	00 
  80068f:	c7 04 24 f0 3c 80 00 	movl   $0x803cf0,(%esp)
  800696:	e8 c9 17 00 00       	call   801e64 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  80069b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006a2:	e8 41 fc ff ff       	call   8002e8 <diskaddr>
  8006a7:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  8006ae:	00 
  8006af:	8d 95 f8 fe ff ff    	lea    -0x108(%ebp),%edx
  8006b5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006b9:	89 04 24             	mov    %eax,(%esp)
  8006bc:	e8 d7 20 00 00       	call   802798 <memmove>
	flush_block(diskaddr(1));
  8006c1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006c8:	e8 1b fc ff ff       	call   8002e8 <diskaddr>
  8006cd:	89 04 24             	mov    %eax,(%esp)
  8006d0:	e8 77 fd ff ff       	call   80044c <flush_block>

	cprintf("block cache is good\n");
  8006d5:	c7 04 24 96 3d 80 00 	movl   $0x803d96,(%esp)
  8006dc:	e8 50 18 00 00       	call   801f31 <cprintf>
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
  8006f7:	a1 88 b0 80 00       	mov    0x80b088,%eax
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
  800716:	8b 15 84 b0 80 00    	mov    0x80b084,%edx
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
  800748:	a1 88 b0 80 00       	mov    0x80b088,%eax
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
  800772:	a1 88 b0 80 00       	mov    0x80b088,%eax
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
  80078a:	a1 88 b0 80 00       	mov    0x80b088,%eax
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
  8007b0:	03 15 84 b0 80 00    	add    0x80b084,%edx
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
  8007fd:	c7 44 24 08 ab 3d 80 	movl   $0x803dab,0x8(%esp)
  800804:	00 
  800805:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80080c:	00 
  80080d:	c7 04 24 c6 3d 80 00 	movl   $0x803dc6,(%esp)
  800814:	e8 4b 16 00 00       	call   801e64 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800819:	89 d0                	mov    %edx,%eax
  80081b:	c1 e8 05             	shr    $0x5,%eax
  80081e:	c1 e0 02             	shl    $0x2,%eax
  800821:	03 05 84 b0 80 00    	add    0x80b084,%eax
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
  80083f:	a1 88 b0 80 00       	mov    0x80b088,%eax
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
  80085f:	c7 44 24 0c ce 3d 80 	movl   $0x803dce,0xc(%esp)
  800866:	00 
  800867:	c7 44 24 08 3d 3c 80 	movl   $0x803c3d,0x8(%esp)
  80086e:	00 
  80086f:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  800876:	00 
  800877:	c7 04 24 c6 3d 80 00 	movl   $0x803dc6,(%esp)
  80087e:	e8 e1 15 00 00       	call   801e64 <_panic>
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
  80089f:	c7 44 24 0c e2 3d 80 	movl   $0x803de2,0xc(%esp)
  8008a6:	00 
  8008a7:	c7 44 24 08 3d 3c 80 	movl   $0x803c3d,0x8(%esp)
  8008ae:	00 
  8008af:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  8008b6:	00 
  8008b7:	c7 04 24 c6 3d 80 00 	movl   $0x803dc6,(%esp)
  8008be:	e8 a1 15 00 00       	call   801e64 <_panic>
	assert(!block_is_free(1));
  8008c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8008ca:	e8 21 fe ff ff       	call   8006f0 <block_is_free>
  8008cf:	85 c0                	test   %eax,%eax
  8008d1:	74 24                	je     8008f7 <check_bitmap+0xc0>
  8008d3:	c7 44 24 0c f4 3d 80 	movl   $0x803df4,0xc(%esp)
  8008da:	00 
  8008db:	c7 44 24 08 3d 3c 80 	movl   $0x803c3d,0x8(%esp)
  8008e2:	00 
  8008e3:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  8008ea:	00 
  8008eb:	c7 04 24 c6 3d 80 00 	movl   $0x803dc6,(%esp)
  8008f2:	e8 6d 15 00 00       	call   801e64 <_panic>

	cprintf("bitmap is good\n");
  8008f7:	c7 04 24 06 3e 80 00 	movl   $0x803e06,(%esp)
  8008fe:	e8 2e 16 00 00       	call   801f31 <cprintf>
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
  800910:	a1 88 b0 80 00       	mov    0x80b088,%eax
  800915:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  80091b:	74 1c                	je     800939 <check_super+0x2f>
		panic("bad file system magic number");
  80091d:	c7 44 24 08 16 3e 80 	movl   $0x803e16,0x8(%esp)
  800924:	00 
  800925:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80092c:	00 
  80092d:	c7 04 24 c6 3d 80 00 	movl   $0x803dc6,(%esp)
  800934:	e8 2b 15 00 00       	call   801e64 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  800939:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  800940:	76 1c                	jbe    80095e <check_super+0x54>
		panic("file system is too large");
  800942:	c7 44 24 08 33 3e 80 	movl   $0x803e33,0x8(%esp)
  800949:	00 
  80094a:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800951:	00 
  800952:	c7 04 24 c6 3d 80 00 	movl   $0x803dc6,(%esp)
  800959:	e8 06 15 00 00       	call   801e64 <_panic>

	cprintf("superblock is good\n");
  80095e:	c7 04 24 4c 3e 80 00 	movl   $0x803e4c,(%esp)
  800965:	e8 c7 15 00 00       	call   801f31 <cprintf>
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
  8009e9:	e8 50 1d 00 00       	call   80273e <memset>
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
  800b44:	c7 04 24 60 3e 80 00 	movl   $0x803e60,(%esp)
  800b4b:	e8 e1 13 00 00       	call   801f31 <cprintf>
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
  800c41:	e8 f8 1a 00 00       	call   80273e <memset>
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
  800d38:	e8 5b 1a 00 00       	call   802798 <memmove>
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
  800df8:	e8 9b 19 00 00       	call   802798 <memmove>
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
  800e3c:	a1 88 b0 80 00       	mov    0x80b088,%eax
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
  800ee3:	e8 b0 18 00 00       	call   802798 <memmove>
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
  800f1e:	c7 44 24 0c 7d 3e 80 	movl   $0x803e7d,0xc(%esp)
  800f25:	00 
  800f26:	c7 44 24 08 3d 3c 80 	movl   $0x803c3d,0x8(%esp)
  800f2d:	00 
  800f2e:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
  800f35:	00 
  800f36:	c7 04 24 c6 3d 80 00 	movl   $0x803dc6,(%esp)
  800f3d:	e8 22 0f 00 00       	call   801e64 <_panic>
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
  800fa8:	e8 c4 16 00 00       	call   802671 <strcmp>
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
  801030:	e8 5c 15 00 00       	call   802591 <strcpy>
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
  80114e:	c7 44 24 0c 7d 3e 80 	movl   $0x803e7d,0xc(%esp)
  801155:	00 
  801156:	c7 44 24 08 3d 3c 80 	movl   $0x803c3d,0x8(%esp)
  80115d:	00 
  80115e:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
  801165:	00 
  801166:	c7 04 24 c6 3d 80 00 	movl   $0x803dc6,(%esp)
  80116d:	e8 f2 0c 00 00       	call   801e64 <_panic>
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
  801240:	e8 4c 13 00 00       	call   802591 <strcpy>
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
  8012b1:	a3 88 b0 80 00       	mov    %eax,0x80b088
	//cprintf("super block:magic=%x nblocks=%x\n",super->s_magic,super->s_nblocks);
	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  8012b6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8012bd:	e8 26 f0 ff ff       	call   8002e8 <diskaddr>
  8012c2:	a3 84 b0 80 00       	mov    %eax,0x80b084

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
  8012f2:	89 90 20 70 80 00    	mov    %edx,0x807020(%eax)
		opentab[i].o_fd = (struct Fd*) va;
  8012f8:	89 88 2c 70 80 00    	mov    %ecx,0x80702c(%eax)
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
  801348:	e8 4b 14 00 00       	call   802798 <memmove>
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
  80137b:	8d b3 20 70 80 00    	lea    0x807020(%ebx),%esi
	if (pageref(o->o_fd) == 1 || o->o_fileid != fileid)
  801381:	8b 46 0c             	mov    0xc(%esi),%eax
  801384:	89 04 24             	mov    %eax,(%esp)
  801387:	e8 80 25 00 00       	call   80390c <pageref>
  80138c:	83 f8 01             	cmp    $0x1,%eax
  80138f:	74 17                	je     8013a8 <openfile_lookup+0x46>
  801391:	8b 45 0c             	mov    0xc(%ebp),%eax
  801394:	39 83 20 70 80 00    	cmp    %eax,0x807020(%ebx)
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
  801424:	e8 68 11 00 00       	call   802591 <strcpy>
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
  801571:	8b 80 2c 70 80 00    	mov    0x80702c(%eax),%eax
  801577:	89 04 24             	mov    %eax,(%esp)
  80157a:	e8 8d 23 00 00       	call   80390c <pageref>
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
  801597:	8b 80 2c 70 80 00    	mov    0x80702c(%eax),%eax
  80159d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015a8:	e8 e9 16 00 00       	call   802c96 <sys_page_alloc>
  8015ad:	85 c0                	test   %eax,%eax
  8015af:	78 4f                	js     801600 <openfile_alloc+0xa4>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  8015b1:	89 da                	mov    %ebx,%edx
  8015b3:	c1 e2 04             	shl    $0x4,%edx
  8015b6:	81 82 20 70 80 00 00 	addl   $0x400,0x807020(%edx)
  8015bd:	04 00 00 
			*o = &opentab[i];
  8015c0:	8d 82 20 70 80 00    	lea    0x807020(%edx),%eax
  8015c6:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  8015c8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8015cf:	00 
  8015d0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015d7:	00 
  8015d8:	8b 82 2c 70 80 00    	mov    0x80702c(%edx),%eax
  8015de:	89 04 24             	mov    %eax,(%esp)
  8015e1:	e8 58 11 00 00       	call   80273e <memset>
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
  801612:	8b 75 0c             	mov    0xc(%ebp),%esi
	int fileid;
	int r;
	struct OpenFile *o;

	//if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);
  801615:	8b 86 00 04 00 00    	mov    0x400(%esi),%eax
  80161b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80161f:	89 74 24 08          	mov    %esi,0x8(%esp)
  801623:	8b 45 08             	mov    0x8(%ebp),%eax
  801626:	89 44 24 04          	mov    %eax,0x4(%esp)
  80162a:	c7 04 24 9a 3e 80 00 	movl   $0x803e9a,(%esp)
  801631:	e8 fb 08 00 00       	call   801f31 <cprintf>

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801636:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  80163d:	00 
  80163e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801642:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801648:	89 04 24             	mov    %eax,(%esp)
  80164b:	e8 48 11 00 00       	call   802798 <memmove>
	path[MAXPATHLEN-1] = 0;
  801650:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  801654:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  80165a:	89 04 24             	mov    %eax,(%esp)
  80165d:	e8 fa fe ff ff       	call   80155c <openfile_alloc>
  801662:	89 c3                	mov    %eax,%ebx
  801664:	85 c0                	test   %eax,%eax
  801666:	79 15                	jns    80167d <serve_open+0x76>
		//if (debug)
			cprintf("openfile_alloc failed: %e", r);
  801668:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166c:	c7 04 24 b3 3e 80 00 	movl   $0x803eb3,(%esp)
  801673:	e8 b9 08 00 00       	call   801f31 <cprintf>
  801678:	e9 4d 01 00 00       	jmp    8017ca <serve_open+0x1c3>
		return r;
	}
	fileid = r;
	cprintf("serve_open:fileid=%x\n",fileid);
  80167d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801681:	c7 04 24 cd 3e 80 00 	movl   $0x803ecd,(%esp)
  801688:	e8 a4 08 00 00       	call   801f31 <cprintf>
	// Open the file
	if (req->req_omode & O_CREAT) {
  80168d:	f6 86 01 04 00 00 01 	testb  $0x1,0x401(%esi)
  801694:	74 41                	je     8016d7 <serve_open+0xd0>
		if ((r = file_create(path, &f)) < 0) {
  801696:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  80169c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a0:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8016a6:	89 04 24             	mov    %eax,(%esp)
  8016a9:	e8 42 fa ff ff       	call   8010f0 <file_create>
  8016ae:	89 c3                	mov    %eax,%ebx
  8016b0:	85 c0                	test   %eax,%eax
  8016b2:	79 56                	jns    80170a <serve_open+0x103>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  8016b4:	f6 86 01 04 00 00 04 	testb  $0x4,0x401(%esi)
  8016bb:	75 05                	jne    8016c2 <serve_open+0xbb>
  8016bd:	83 f8 f3             	cmp    $0xfffffff3,%eax
  8016c0:	74 15                	je     8016d7 <serve_open+0xd0>
				goto try_open;
			//if (debug)
				cprintf("file_create failed: %e", r);
  8016c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016c6:	c7 04 24 e3 3e 80 00 	movl   $0x803ee3,(%esp)
  8016cd:	e8 5f 08 00 00       	call   801f31 <cprintf>
  8016d2:	e9 f3 00 00 00       	jmp    8017ca <serve_open+0x1c3>
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  8016d7:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8016dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e1:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8016e7:	89 04 24             	mov    %eax,(%esp)
  8016ea:	e8 e2 f9 ff ff       	call   8010d1 <file_open>
  8016ef:	89 c3                	mov    %eax,%ebx
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	79 15                	jns    80170a <serve_open+0x103>
			//if (debug)
				cprintf("file_open failed: %e", r);
  8016f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f9:	c7 04 24 fa 3e 80 00 	movl   $0x803efa,(%esp)
  801700:	e8 2c 08 00 00       	call   801f31 <cprintf>
  801705:	e9 c0 00 00 00       	jmp    8017ca <serve_open+0x1c3>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  80170a:	f6 86 01 04 00 00 02 	testb  $0x2,0x401(%esi)
  801711:	74 31                	je     801744 <serve_open+0x13d>
		if ((r = file_set_size(f, 0)) < 0) {
  801713:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80171a:	00 
  80171b:	8b 85 f4 fb ff ff    	mov    -0x40c(%ebp),%eax
  801721:	89 04 24             	mov    %eax,(%esp)
  801724:	e8 58 f4 ff ff       	call   800b81 <file_set_size>
  801729:	89 c3                	mov    %eax,%ebx
  80172b:	85 c0                	test   %eax,%eax
  80172d:	79 15                	jns    801744 <serve_open+0x13d>
			//if (debug)
				cprintf("file_set_size failed: %e", r);
  80172f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801733:	c7 04 24 0f 3f 80 00 	movl   $0x803f0f,(%esp)
  80173a:	e8 f2 07 00 00       	call   801f31 <cprintf>
  80173f:	e9 86 00 00 00       	jmp    8017ca <serve_open+0x1c3>
			return r;
		}
	}

	// Save the file pointer
	o->o_file = f;
  801744:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  80174a:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801750:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  801753:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801759:	8b 50 0c             	mov    0xc(%eax),%edx
  80175c:	8b 00                	mov    (%eax),%eax
  80175e:	89 42 0c             	mov    %eax,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  801761:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801767:	8b 50 0c             	mov    0xc(%eax),%edx
  80176a:	8b 86 00 04 00 00    	mov    0x400(%esi),%eax
  801770:	83 e0 03             	and    $0x3,%eax
  801773:	89 42 08             	mov    %eax,0x8(%edx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  801776:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  80177c:	8b 50 0c             	mov    0xc(%eax),%edx
  80177f:	a1 68 b0 80 00       	mov    0x80b068,%eax
  801784:	89 02                	mov    %eax,(%edx)
	o->o_mode = req->req_omode;
  801786:	8b 96 00 04 00 00    	mov    0x400(%esi),%edx
  80178c:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801792:	89 50 08             	mov    %edx,0x8(%eax)

	//if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);
  801795:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  80179b:	8b 40 0c             	mov    0xc(%eax),%eax
  80179e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a2:	c7 04 24 28 3f 80 00 	movl   $0x803f28,(%esp)
  8017a9:	e8 83 07 00 00       	call   801f31 <cprintf>

	// Share the FD page with the caller
	*pg_store = o->o_fd;
  8017ae:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8017b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b7:	8b 55 10             	mov    0x10(%ebp),%edx
  8017ba:	89 02                	mov    %eax,(%edx)
	*perm_store = PTE_P|PTE_U|PTE_W;
  8017bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8017bf:	c7 00 07 00 00 00    	movl   $0x7,(%eax)
  8017c5:	bb 00 00 00 00       	mov    $0x0,%ebx
	return 0;
}
  8017ca:	89 d8                	mov    %ebx,%eax
  8017cc:	81 c4 20 04 00 00    	add    $0x420,%esp
  8017d2:	5b                   	pop    %ebx
  8017d3:	5e                   	pop    %esi
  8017d4:	5d                   	pop    %ebp
  8017d5:	c3                   	ret    

008017d6 <serve>:
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	56                   	push   %esi
  8017da:	53                   	push   %ebx
  8017db:	83 ec 20             	sub    $0x20,%esp
	void *pg;

	while (1) {
		perm = 0;
		//cprintf("****serve is runing,start to recive******\n");
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  8017de:	8d 75 f4             	lea    -0xc(%ebp),%esi
  8017e1:	8d 5d f0             	lea    -0x10(%ebp),%ebx
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  8017e4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		//cprintf("****serve is runing,start to recive******\n");
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  8017eb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017ef:	a1 20 b0 80 00       	mov    0x80b020,%eax
  8017f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f8:	89 34 24             	mov    %esi,(%esp)
  8017fb:	e8 24 17 00 00       	call   802f24 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, vpt[VPN(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  801800:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  801804:	75 15                	jne    80181b <serve+0x45>
			cprintf("Invalid request from %08x: no argument page\n",
  801806:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801809:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180d:	c7 04 24 68 3f 80 00 	movl   $0x803f68,(%esp)
  801814:	e8 18 07 00 00       	call   801f31 <cprintf>
  801819:	eb c9                	jmp    8017e4 <serve+0xe>
				whom);
			continue; // just leave it hanging...
		}

		pg = NULL;
  80181b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  801822:	83 f8 01             	cmp    $0x1,%eax
  801825:	75 23                	jne    80184a <serve+0x74>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  801827:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80182b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80182e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801832:	a1 20 b0 80 00       	mov    0x80b020,%eax
  801837:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80183e:	89 04 24             	mov    %eax,(%esp)
  801841:	e8 c1 fd ff ff       	call   801607 <serve_open>
  801846:	89 c2                	mov    %eax,%edx
  801848:	eb 41                	jmp    80188b <serve+0xb5>
		} else if (req < NHANDLERS && handlers[req]) {
  80184a:	83 f8 08             	cmp    $0x8,%eax
  80184d:	77 20                	ja     80186f <serve+0x99>
  80184f:	8b 14 85 40 b0 80 00 	mov    0x80b040(,%eax,4),%edx
  801856:	85 d2                	test   %edx,%edx
  801858:	74 15                	je     80186f <serve+0x99>
			r = handlers[req](whom, fsreq);
  80185a:	a1 20 b0 80 00       	mov    0x80b020,%eax
  80185f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801863:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801866:	89 04 24             	mov    %eax,(%esp)
  801869:	ff d2                	call   *%edx
  80186b:	89 c2                	mov    %eax,%edx
  80186d:	eb 1c                	jmp    80188b <serve+0xb5>
		} else {
			cprintf("Invalid request code %d from %08x\n", whom, req);
  80186f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801873:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801876:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187a:	c7 04 24 98 3f 80 00 	movl   $0x803f98,(%esp)
  801881:	e8 ab 06 00 00       	call   801f31 <cprintf>
  801886:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
			r = -E_INVAL;
		}
		ipc_send(whom, r, pg, perm);
  80188b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80188e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801892:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801895:	89 44 24 08          	mov    %eax,0x8(%esp)
  801899:	89 54 24 04          	mov    %edx,0x4(%esp)
  80189d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a0:	89 04 24             	mov    %eax,(%esp)
  8018a3:	e8 c8 15 00 00       	call   802e70 <ipc_send>
		sys_page_unmap(0, fsreq);
  8018a8:	a1 20 b0 80 00       	mov    0x80b020,%eax
  8018ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018b8:	e8 1d 13 00 00       	call   802bda <sys_page_unmap>
  8018bd:	e9 22 ff ff ff       	jmp    8017e4 <serve+0xe>

008018c2 <umain>:
	}
}

void
umain(void)
{
  8018c2:	55                   	push   %ebp
  8018c3:	89 e5                	mov    %esp,%ebp
  8018c5:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  8018c8:	c7 05 64 b0 80 00 44 	movl   $0x803f44,0x80b064
  8018cf:	3f 80 00 
	cprintf("FS is running\n");
  8018d2:	c7 04 24 47 3f 80 00 	movl   $0x803f47,(%esp)
  8018d9:	e8 53 06 00 00       	call   801f31 <cprintf>
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  8018de:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  8018e3:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  8018e8:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  8018ea:	c7 04 24 56 3f 80 00 	movl   $0x803f56,(%esp)
  8018f1:	e8 3b 06 00 00       	call   801f31 <cprintf>

	serve_init();
  8018f6:	e8 e5 f9 ff ff       	call   8012e0 <serve_init>
	fs_init();
  8018fb:	e8 72 f9 ff ff       	call   801272 <fs_init>
	fs_test();
  801900:	e8 07 00 00 00       	call   80190c <fs_test>

	serve();
  801905:	e8 cc fe ff ff       	call   8017d6 <serve>
}
  80190a:	c9                   	leave  
  80190b:	c3                   	ret    

0080190c <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	53                   	push   %ebx
  801910:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  801913:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80191a:	00 
  80191b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  801922:	00 
  801923:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80192a:	e8 67 13 00 00       	call   802c96 <sys_page_alloc>
  80192f:	85 c0                	test   %eax,%eax
  801931:	79 20                	jns    801953 <fs_test+0x47>
		panic("sys_page_alloc: %e", r);
  801933:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801937:	c7 44 24 08 bb 3f 80 	movl   $0x803fbb,0x8(%esp)
  80193e:	00 
  80193f:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  801946:	00 
  801947:	c7 04 24 ce 3f 80 00 	movl   $0x803fce,(%esp)
  80194e:	e8 11 05 00 00       	call   801e64 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  801953:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80195a:	00 
  80195b:	a1 84 b0 80 00       	mov    0x80b084,%eax
  801960:	89 44 24 04          	mov    %eax,0x4(%esp)
  801964:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  80196b:	e8 28 0e 00 00       	call   802798 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  801970:	e8 0d ee ff ff       	call   800782 <alloc_block>
  801975:	85 c0                	test   %eax,%eax
  801977:	79 20                	jns    801999 <fs_test+0x8d>
		panic("alloc_block: %e", r);
  801979:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80197d:	c7 44 24 08 d8 3f 80 	movl   $0x803fd8,0x8(%esp)
  801984:	00 
  801985:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
  80198c:	00 
  80198d:	c7 04 24 ce 3f 80 00 	movl   $0x803fce,(%esp)
  801994:	e8 cb 04 00 00       	call   801e64 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  801999:	89 c2                	mov    %eax,%edx
  80199b:	c1 fa 1f             	sar    $0x1f,%edx
  80199e:	c1 ea 1b             	shr    $0x1b,%edx
  8019a1:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
  8019a4:	89 c8                	mov    %ecx,%eax
  8019a6:	c1 f8 05             	sar    $0x5,%eax
  8019a9:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
  8019b0:	83 e1 1f             	and    $0x1f,%ecx
  8019b3:	29 d1                	sub    %edx,%ecx
  8019b5:	b8 01 00 00 00       	mov    $0x1,%eax
  8019ba:	89 c2                	mov    %eax,%edx
  8019bc:	d3 e2                	shl    %cl,%edx
  8019be:	85 93 00 10 00 00    	test   %edx,0x1000(%ebx)
  8019c4:	75 24                	jne    8019ea <fs_test+0xde>
  8019c6:	c7 44 24 0c e8 3f 80 	movl   $0x803fe8,0xc(%esp)
  8019cd:	00 
  8019ce:	c7 44 24 08 3d 3c 80 	movl   $0x803c3d,0x8(%esp)
  8019d5:	00 
  8019d6:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8019dd:	00 
  8019de:	c7 04 24 ce 3f 80 00 	movl   $0x803fce,(%esp)
  8019e5:	e8 7a 04 00 00       	call   801e64 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8019ea:	89 d8                	mov    %ebx,%eax
  8019ec:	03 05 84 b0 80 00    	add    0x80b084,%eax
  8019f2:	85 10                	test   %edx,(%eax)
  8019f4:	74 24                	je     801a1a <fs_test+0x10e>
  8019f6:	c7 44 24 0c 5c 41 80 	movl   $0x80415c,0xc(%esp)
  8019fd:	00 
  8019fe:	c7 44 24 08 3d 3c 80 	movl   $0x803c3d,0x8(%esp)
  801a05:	00 
  801a06:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  801a0d:	00 
  801a0e:	c7 04 24 ce 3f 80 00 	movl   $0x803fce,(%esp)
  801a15:	e8 4a 04 00 00       	call   801e64 <_panic>
	cprintf("alloc_block is good\n");
  801a1a:	c7 04 24 03 40 80 00 	movl   $0x804003,(%esp)
  801a21:	e8 0b 05 00 00       	call   801f31 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801a26:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801a29:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a2d:	c7 04 24 18 40 80 00 	movl   $0x804018,(%esp)
  801a34:	e8 98 f6 ff ff       	call   8010d1 <file_open>
  801a39:	85 c0                	test   %eax,%eax
  801a3b:	79 25                	jns    801a62 <fs_test+0x156>
  801a3d:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801a40:	74 40                	je     801a82 <fs_test+0x176>
		panic("file_open /not-found: %e", r);
  801a42:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a46:	c7 44 24 08 23 40 80 	movl   $0x804023,0x8(%esp)
  801a4d:	00 
  801a4e:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801a55:	00 
  801a56:	c7 04 24 ce 3f 80 00 	movl   $0x803fce,(%esp)
  801a5d:	e8 02 04 00 00       	call   801e64 <_panic>
	else if (r == 0)
  801a62:	85 c0                	test   %eax,%eax
  801a64:	75 1c                	jne    801a82 <fs_test+0x176>
		panic("file_open /not-found succeeded!");
  801a66:	c7 44 24 08 7c 41 80 	movl   $0x80417c,0x8(%esp)
  801a6d:	00 
  801a6e:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801a75:	00 
  801a76:	c7 04 24 ce 3f 80 00 	movl   $0x803fce,(%esp)
  801a7d:	e8 e2 03 00 00       	call   801e64 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801a82:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801a85:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a89:	c7 04 24 3c 40 80 00 	movl   $0x80403c,(%esp)
  801a90:	e8 3c f6 ff ff       	call   8010d1 <file_open>
  801a95:	85 c0                	test   %eax,%eax
  801a97:	79 20                	jns    801ab9 <fs_test+0x1ad>
		panic("file_open /newmotd: %e", r);
  801a99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a9d:	c7 44 24 08 45 40 80 	movl   $0x804045,0x8(%esp)
  801aa4:	00 
  801aa5:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801aac:	00 
  801aad:	c7 04 24 ce 3f 80 00 	movl   $0x803fce,(%esp)
  801ab4:	e8 ab 03 00 00       	call   801e64 <_panic>
	cprintf("file_open is good\n");
  801ab9:	c7 04 24 5c 40 80 00 	movl   $0x80405c,(%esp)
  801ac0:	e8 6c 04 00 00       	call   801f31 <cprintf>
	//panic("file open is ok 000000000\n");
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801ac5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801acc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ad3:	00 
  801ad4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801ad7:	89 04 24             	mov    %eax,(%esp)
  801ada:	e8 e2 f0 ff ff       	call   800bc1 <file_get_block>
  801adf:	85 c0                	test   %eax,%eax
  801ae1:	79 20                	jns    801b03 <fs_test+0x1f7>
		panic("file_get_block: %e", r);
  801ae3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ae7:	c7 44 24 08 6f 40 80 	movl   $0x80406f,0x8(%esp)
  801aee:	00 
  801aef:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801af6:	00 
  801af7:	c7 04 24 ce 3f 80 00 	movl   $0x803fce,(%esp)
  801afe:	e8 61 03 00 00       	call   801e64 <_panic>
	//panic("000000000\n");
	if (strcmp(blk, msg) != 0)
  801b03:	8b 1d e8 41 80 00    	mov    0x8041e8,%ebx
  801b09:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b10:	89 04 24             	mov    %eax,(%esp)
  801b13:	e8 59 0b 00 00       	call   802671 <strcmp>
  801b18:	85 c0                	test   %eax,%eax
  801b1a:	74 1c                	je     801b38 <fs_test+0x22c>
		panic("file_get_block returned wrong data");
  801b1c:	c7 44 24 08 9c 41 80 	movl   $0x80419c,0x8(%esp)
  801b23:	00 
  801b24:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  801b2b:	00 
  801b2c:	c7 04 24 ce 3f 80 00 	movl   $0x803fce,(%esp)
  801b33:	e8 2c 03 00 00       	call   801e64 <_panic>
	cprintf("file_get_block is good\n");
  801b38:	c7 04 24 82 40 80 00 	movl   $0x804082,(%esp)
  801b3f:	e8 ed 03 00 00       	call   801f31 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801b44:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b47:	0f b6 02             	movzbl (%edx),%eax
  801b4a:	88 02                	mov    %al,(%edx)
	assert((vpt[VPN(blk)] & PTE_D));
  801b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b4f:	c1 e8 0c             	shr    $0xc,%eax
  801b52:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b59:	a8 40                	test   $0x40,%al
  801b5b:	75 24                	jne    801b81 <fs_test+0x275>
  801b5d:	c7 44 24 0c 9b 40 80 	movl   $0x80409b,0xc(%esp)
  801b64:	00 
  801b65:	c7 44 24 08 3d 3c 80 	movl   $0x803c3d,0x8(%esp)
  801b6c:	00 
  801b6d:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  801b74:	00 
  801b75:	c7 04 24 ce 3f 80 00 	movl   $0x803fce,(%esp)
  801b7c:	e8 e3 02 00 00       	call   801e64 <_panic>
	file_flush(f);
  801b81:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801b84:	89 04 24             	mov    %eax,(%esp)
  801b87:	e8 91 ee ff ff       	call   800a1d <file_flush>
	assert(!(vpt[VPN(blk)] & PTE_D));
  801b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b8f:	c1 e8 0c             	shr    $0xc,%eax
  801b92:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b99:	a8 40                	test   $0x40,%al
  801b9b:	74 24                	je     801bc1 <fs_test+0x2b5>
  801b9d:	c7 44 24 0c 9a 40 80 	movl   $0x80409a,0xc(%esp)
  801ba4:	00 
  801ba5:	c7 44 24 08 3d 3c 80 	movl   $0x803c3d,0x8(%esp)
  801bac:	00 
  801bad:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  801bb4:	00 
  801bb5:	c7 04 24 ce 3f 80 00 	movl   $0x803fce,(%esp)
  801bbc:	e8 a3 02 00 00       	call   801e64 <_panic>
	cprintf("file_flush is good\n");
  801bc1:	c7 04 24 b3 40 80 00 	movl   $0x8040b3,(%esp)
  801bc8:	e8 64 03 00 00       	call   801f31 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801bcd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bd4:	00 
  801bd5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801bd8:	89 04 24             	mov    %eax,(%esp)
  801bdb:	e8 a1 ef ff ff       	call   800b81 <file_set_size>
  801be0:	85 c0                	test   %eax,%eax
  801be2:	79 20                	jns    801c04 <fs_test+0x2f8>
		panic("file_set_size: %e", r);
  801be4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801be8:	c7 44 24 08 c7 40 80 	movl   $0x8040c7,0x8(%esp)
  801bef:	00 
  801bf0:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801bf7:	00 
  801bf8:	c7 04 24 ce 3f 80 00 	movl   $0x803fce,(%esp)
  801bff:	e8 60 02 00 00       	call   801e64 <_panic>
	assert(f->f_direct[0] == 0);
  801c04:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801c07:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  801c0e:	74 24                	je     801c34 <fs_test+0x328>
  801c10:	c7 44 24 0c d9 40 80 	movl   $0x8040d9,0xc(%esp)
  801c17:	00 
  801c18:	c7 44 24 08 3d 3c 80 	movl   $0x803c3d,0x8(%esp)
  801c1f:	00 
  801c20:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  801c27:	00 
  801c28:	c7 04 24 ce 3f 80 00 	movl   $0x803fce,(%esp)
  801c2f:	e8 30 02 00 00       	call   801e64 <_panic>
	assert(!(vpt[VPN(f)] & PTE_D));
  801c34:	c1 e8 0c             	shr    $0xc,%eax
  801c37:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801c3e:	a8 40                	test   $0x40,%al
  801c40:	74 24                	je     801c66 <fs_test+0x35a>
  801c42:	c7 44 24 0c ed 40 80 	movl   $0x8040ed,0xc(%esp)
  801c49:	00 
  801c4a:	c7 44 24 08 3d 3c 80 	movl   $0x803c3d,0x8(%esp)
  801c51:	00 
  801c52:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  801c59:	00 
  801c5a:	c7 04 24 ce 3f 80 00 	movl   $0x803fce,(%esp)
  801c61:	e8 fe 01 00 00       	call   801e64 <_panic>
	cprintf("file_truncate is good\n");
  801c66:	c7 04 24 04 41 80 00 	movl   $0x804104,(%esp)
  801c6d:	e8 bf 02 00 00       	call   801f31 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  801c72:	89 1c 24             	mov    %ebx,(%esp)
  801c75:	e8 c6 08 00 00       	call   802540 <strlen>
  801c7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c7e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801c81:	89 04 24             	mov    %eax,(%esp)
  801c84:	e8 f8 ee ff ff       	call   800b81 <file_set_size>
  801c89:	85 c0                	test   %eax,%eax
  801c8b:	79 20                	jns    801cad <fs_test+0x3a1>
		panic("file_set_size 2: %e", r);
  801c8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c91:	c7 44 24 08 1b 41 80 	movl   $0x80411b,0x8(%esp)
  801c98:	00 
  801c99:	c7 44 24 04 3b 00 00 	movl   $0x3b,0x4(%esp)
  801ca0:	00 
  801ca1:	c7 04 24 ce 3f 80 00 	movl   $0x803fce,(%esp)
  801ca8:	e8 b7 01 00 00       	call   801e64 <_panic>
	assert(!(vpt[VPN(f)] & PTE_D));
  801cad:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801cb0:	89 d0                	mov    %edx,%eax
  801cb2:	c1 e8 0c             	shr    $0xc,%eax
  801cb5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801cbc:	a8 40                	test   $0x40,%al
  801cbe:	74 24                	je     801ce4 <fs_test+0x3d8>
  801cc0:	c7 44 24 0c ed 40 80 	movl   $0x8040ed,0xc(%esp)
  801cc7:	00 
  801cc8:	c7 44 24 08 3d 3c 80 	movl   $0x803c3d,0x8(%esp)
  801ccf:	00 
  801cd0:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  801cd7:	00 
  801cd8:	c7 04 24 ce 3f 80 00 	movl   $0x803fce,(%esp)
  801cdf:	e8 80 01 00 00       	call   801e64 <_panic>
	//panic("aaaaaaaaaaaa\n");
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801ce4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ceb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801cf2:	00 
  801cf3:	89 14 24             	mov    %edx,(%esp)
  801cf6:	e8 c6 ee ff ff       	call   800bc1 <file_get_block>
  801cfb:	85 c0                	test   %eax,%eax
  801cfd:	79 20                	jns    801d1f <fs_test+0x413>
		panic("file_get_block 2: %e", r);
  801cff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d03:	c7 44 24 08 2f 41 80 	movl   $0x80412f,0x8(%esp)
  801d0a:	00 
  801d0b:	c7 44 24 04 3f 00 00 	movl   $0x3f,0x4(%esp)
  801d12:	00 
  801d13:	c7 04 24 ce 3f 80 00 	movl   $0x803fce,(%esp)
  801d1a:	e8 45 01 00 00       	call   801e64 <_panic>
	strcpy(blk, msg);
  801d1f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d26:	89 04 24             	mov    %eax,(%esp)
  801d29:	e8 63 08 00 00       	call   802591 <strcpy>
	assert((vpt[VPN(blk)] & PTE_D));
  801d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d31:	c1 e8 0c             	shr    $0xc,%eax
  801d34:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d3b:	a8 40                	test   $0x40,%al
  801d3d:	75 24                	jne    801d63 <fs_test+0x457>
  801d3f:	c7 44 24 0c 9b 40 80 	movl   $0x80409b,0xc(%esp)
  801d46:	00 
  801d47:	c7 44 24 08 3d 3c 80 	movl   $0x803c3d,0x8(%esp)
  801d4e:	00 
  801d4f:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801d56:	00 
  801d57:	c7 04 24 ce 3f 80 00 	movl   $0x803fce,(%esp)
  801d5e:	e8 01 01 00 00       	call   801e64 <_panic>
	file_flush(f);
  801d63:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801d66:	89 04 24             	mov    %eax,(%esp)
  801d69:	e8 af ec ff ff       	call   800a1d <file_flush>
	assert(!(vpt[VPN(blk)] & PTE_D));
  801d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d71:	c1 e8 0c             	shr    $0xc,%eax
  801d74:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d7b:	a8 40                	test   $0x40,%al
  801d7d:	74 24                	je     801da3 <fs_test+0x497>
  801d7f:	c7 44 24 0c 9a 40 80 	movl   $0x80409a,0xc(%esp)
  801d86:	00 
  801d87:	c7 44 24 08 3d 3c 80 	movl   $0x803c3d,0x8(%esp)
  801d8e:	00 
  801d8f:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  801d96:	00 
  801d97:	c7 04 24 ce 3f 80 00 	movl   $0x803fce,(%esp)
  801d9e:	e8 c1 00 00 00       	call   801e64 <_panic>
	assert(!(vpt[VPN(f)] & PTE_D));
  801da3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801da6:	c1 e8 0c             	shr    $0xc,%eax
  801da9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801db0:	a8 40                	test   $0x40,%al
  801db2:	74 24                	je     801dd8 <fs_test+0x4cc>
  801db4:	c7 44 24 0c ed 40 80 	movl   $0x8040ed,0xc(%esp)
  801dbb:	00 
  801dbc:	c7 44 24 08 3d 3c 80 	movl   $0x803c3d,0x8(%esp)
  801dc3:	00 
  801dc4:	c7 44 24 04 44 00 00 	movl   $0x44,0x4(%esp)
  801dcb:	00 
  801dcc:	c7 04 24 ce 3f 80 00 	movl   $0x803fce,(%esp)
  801dd3:	e8 8c 00 00 00       	call   801e64 <_panic>
	cprintf("file rewrite is good\n");
  801dd8:	c7 04 24 44 41 80 00 	movl   $0x804144,(%esp)
  801ddf:	e8 4d 01 00 00       	call   801f31 <cprintf>
}
  801de4:	83 c4 24             	add    $0x24,%esp
  801de7:	5b                   	pop    %ebx
  801de8:	5d                   	pop    %ebp
  801de9:	c3                   	ret    
	...

00801dec <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  801dec:	55                   	push   %ebp
  801ded:	89 e5                	mov    %esp,%ebp
  801def:	83 ec 18             	sub    $0x18,%esp
  801df2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801df5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801df8:	8b 75 08             	mov    0x8(%ebp),%esi
  801dfb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  801dfe:	c7 05 8c b0 80 00 00 	movl   $0x0,0x80b08c
  801e05:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  801e08:	e8 1c 0f 00 00       	call   802d29 <sys_getenvid>
  801e0d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801e12:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e15:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e1a:	a3 8c b0 80 00       	mov    %eax,0x80b08c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  801e1f:	85 f6                	test   %esi,%esi
  801e21:	7e 07                	jle    801e2a <libmain+0x3e>
		binaryname = argv[0];
  801e23:	8b 03                	mov    (%ebx),%eax
  801e25:	a3 64 b0 80 00       	mov    %eax,0x80b064

	// call user main routine
	umain(argc, argv);
  801e2a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e2e:	89 34 24             	mov    %esi,(%esp)
  801e31:	e8 8c fa ff ff       	call   8018c2 <umain>

	// exit gracefully
	exit();
  801e36:	e8 0d 00 00 00       	call   801e48 <exit>
}
  801e3b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801e3e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801e41:	89 ec                	mov    %ebp,%esp
  801e43:	5d                   	pop    %ebp
  801e44:	c3                   	ret    
  801e45:	00 00                	add    %al,(%eax)
	...

00801e48 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801e48:	55                   	push   %ebp
  801e49:	89 e5                	mov    %esp,%ebp
  801e4b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801e4e:	e8 ad 17 00 00       	call   803600 <close_all>
	sys_env_destroy(0);
  801e53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e5a:	e8 fe 0e 00 00       	call   802d5d <sys_env_destroy>
}
  801e5f:	c9                   	leave  
  801e60:	c3                   	ret    
  801e61:	00 00                	add    %al,(%eax)
	...

00801e64 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801e64:	55                   	push   %ebp
  801e65:	89 e5                	mov    %esp,%ebp
  801e67:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  801e6a:	8d 45 14             	lea    0x14(%ebp),%eax
  801e6d:	89 45 fc             	mov    %eax,-0x4(%ebp)

	// Print the panic message
	if (argv0)
  801e70:	a1 90 b0 80 00       	mov    0x80b090,%eax
  801e75:	85 c0                	test   %eax,%eax
  801e77:	74 10                	je     801e89 <_panic+0x25>
		cprintf("%s: ", argv0);
  801e79:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e7d:	c7 04 24 03 42 80 00 	movl   $0x804203,(%esp)
  801e84:	e8 a8 00 00 00       	call   801f31 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  801e89:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e8c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e90:	8b 45 08             	mov    0x8(%ebp),%eax
  801e93:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e97:	a1 64 b0 80 00       	mov    0x80b064,%eax
  801e9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea0:	c7 04 24 08 42 80 00 	movl   $0x804208,(%esp)
  801ea7:	e8 85 00 00 00       	call   801f31 <cprintf>
	vcprintf(fmt, ap);
  801eac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801eaf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb3:	8b 45 10             	mov    0x10(%ebp),%eax
  801eb6:	89 04 24             	mov    %eax,(%esp)
  801eb9:	e8 12 00 00 00       	call   801ed0 <vcprintf>
	cprintf("\n");
  801ebe:	c7 04 24 5f 3d 80 00 	movl   $0x803d5f,(%esp)
  801ec5:	e8 67 00 00 00       	call   801f31 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801eca:	cc                   	int3   
  801ecb:	eb fd                	jmp    801eca <_panic+0x66>
  801ecd:	00 00                	add    %al,(%eax)
	...

00801ed0 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801ed9:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  801ee0:	00 00 00 
	b.cnt = 0;
  801ee3:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  801eea:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801eed:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ef4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801efb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801f01:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f05:	c7 04 24 4e 1f 80 00 	movl   $0x801f4e,(%esp)
  801f0c:	e8 c4 01 00 00       	call   8020d5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801f11:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
  801f17:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f1b:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  801f21:	89 04 24             	mov    %eax,(%esp)
  801f24:	e8 cf 0a 00 00       	call   8029f8 <sys_cputs>
  801f29:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  801f2f:	c9                   	leave  
  801f30:	c3                   	ret    

00801f31 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801f31:	55                   	push   %ebp
  801f32:	89 e5                	mov    %esp,%ebp
  801f34:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801f37:	8d 45 0c             	lea    0xc(%ebp),%eax
  801f3a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  801f3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f41:	8b 45 08             	mov    0x8(%ebp),%eax
  801f44:	89 04 24             	mov    %eax,(%esp)
  801f47:	e8 84 ff ff ff       	call   801ed0 <vcprintf>
	va_end(ap);

	return cnt;
}
  801f4c:	c9                   	leave  
  801f4d:	c3                   	ret    

00801f4e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801f4e:	55                   	push   %ebp
  801f4f:	89 e5                	mov    %esp,%ebp
  801f51:	53                   	push   %ebx
  801f52:	83 ec 14             	sub    $0x14,%esp
  801f55:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801f58:	8b 03                	mov    (%ebx),%eax
  801f5a:	8b 55 08             	mov    0x8(%ebp),%edx
  801f5d:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801f61:	83 c0 01             	add    $0x1,%eax
  801f64:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801f66:	3d ff 00 00 00       	cmp    $0xff,%eax
  801f6b:	75 19                	jne    801f86 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801f6d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801f74:	00 
  801f75:	8d 43 08             	lea    0x8(%ebx),%eax
  801f78:	89 04 24             	mov    %eax,(%esp)
  801f7b:	e8 78 0a 00 00       	call   8029f8 <sys_cputs>
		b->idx = 0;
  801f80:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801f86:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801f8a:	83 c4 14             	add    $0x14,%esp
  801f8d:	5b                   	pop    %ebx
  801f8e:	5d                   	pop    %ebp
  801f8f:	c3                   	ret    

00801f90 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801f90:	55                   	push   %ebp
  801f91:	89 e5                	mov    %esp,%ebp
  801f93:	57                   	push   %edi
  801f94:	56                   	push   %esi
  801f95:	53                   	push   %ebx
  801f96:	83 ec 3c             	sub    $0x3c,%esp
  801f99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801f9c:	89 d7                	mov    %edx,%edi
  801f9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fa4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801fa7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801faa:	8b 55 10             	mov    0x10(%ebp),%edx
  801fad:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801fb0:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801fb3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  801fba:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801fbd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  801fc0:	72 14                	jb     801fd6 <printnum+0x46>
  801fc2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801fc5:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  801fc8:	76 0c                	jbe    801fd6 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801fca:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801fcd:	83 eb 01             	sub    $0x1,%ebx
  801fd0:	85 db                	test   %ebx,%ebx
  801fd2:	7f 57                	jg     80202b <printnum+0x9b>
  801fd4:	eb 64                	jmp    80203a <printnum+0xaa>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801fd6:	89 74 24 10          	mov    %esi,0x10(%esp)
  801fda:	8b 45 14             	mov    0x14(%ebp),%eax
  801fdd:	83 e8 01             	sub    $0x1,%eax
  801fe0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fe4:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fe8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801fec:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801ff0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801ff3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801ff6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ffa:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801ffe:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802001:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802004:	89 04 24             	mov    %eax,(%esp)
  802007:	89 54 24 04          	mov    %edx,0x4(%esp)
  80200b:	e8 40 19 00 00       	call   803950 <__udivdi3>
  802010:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802014:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802018:	89 04 24             	mov    %eax,(%esp)
  80201b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80201f:	89 fa                	mov    %edi,%edx
  802021:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802024:	e8 67 ff ff ff       	call   801f90 <printnum>
  802029:	eb 0f                	jmp    80203a <printnum+0xaa>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80202b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80202f:	89 34 24             	mov    %esi,(%esp)
  802032:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  802035:	83 eb 01             	sub    $0x1,%ebx
  802038:	75 f1                	jne    80202b <printnum+0x9b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80203a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80203e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802042:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802045:	8b 55 ec             	mov    -0x14(%ebp),%edx
  802048:	89 44 24 08          	mov    %eax,0x8(%esp)
  80204c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802050:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802053:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802056:	89 04 24             	mov    %eax,(%esp)
  802059:	89 54 24 04          	mov    %edx,0x4(%esp)
  80205d:	e8 1e 1a 00 00       	call   803a80 <__umoddi3>
  802062:	89 74 24 04          	mov    %esi,0x4(%esp)
  802066:	0f be 80 24 42 80 00 	movsbl 0x804224(%eax),%eax
  80206d:	89 04 24             	mov    %eax,(%esp)
  802070:	ff 55 e4             	call   *-0x1c(%ebp)
}
  802073:	83 c4 3c             	add    $0x3c,%esp
  802076:	5b                   	pop    %ebx
  802077:	5e                   	pop    %esi
  802078:	5f                   	pop    %edi
  802079:	5d                   	pop    %ebp
  80207a:	c3                   	ret    

0080207b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80207b:	55                   	push   %ebp
  80207c:	89 e5                	mov    %esp,%ebp
  80207e:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  802080:	83 fa 01             	cmp    $0x1,%edx
  802083:	7e 0e                	jle    802093 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  802085:	8b 10                	mov    (%eax),%edx
  802087:	8d 42 08             	lea    0x8(%edx),%eax
  80208a:	89 01                	mov    %eax,(%ecx)
  80208c:	8b 02                	mov    (%edx),%eax
  80208e:	8b 52 04             	mov    0x4(%edx),%edx
  802091:	eb 22                	jmp    8020b5 <getuint+0x3a>
	else if (lflag)
  802093:	85 d2                	test   %edx,%edx
  802095:	74 10                	je     8020a7 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  802097:	8b 10                	mov    (%eax),%edx
  802099:	8d 42 04             	lea    0x4(%edx),%eax
  80209c:	89 01                	mov    %eax,(%ecx)
  80209e:	8b 02                	mov    (%edx),%eax
  8020a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8020a5:	eb 0e                	jmp    8020b5 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8020a7:	8b 10                	mov    (%eax),%edx
  8020a9:	8d 42 04             	lea    0x4(%edx),%eax
  8020ac:	89 01                	mov    %eax,(%ecx)
  8020ae:	8b 02                	mov    (%edx),%eax
  8020b0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8020b5:	5d                   	pop    %ebp
  8020b6:	c3                   	ret    

008020b7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8020b7:	55                   	push   %ebp
  8020b8:	89 e5                	mov    %esp,%ebp
  8020ba:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  8020bd:	83 42 08 01          	addl   $0x1,0x8(%edx)
	if (b->buf < b->ebuf)
  8020c1:	8b 02                	mov    (%edx),%eax
  8020c3:	3b 42 04             	cmp    0x4(%edx),%eax
  8020c6:	73 0b                	jae    8020d3 <sprintputch+0x1c>
		*b->buf++ = ch;
  8020c8:	0f b6 4d 08          	movzbl 0x8(%ebp),%ecx
  8020cc:	88 08                	mov    %cl,(%eax)
  8020ce:	83 c0 01             	add    $0x1,%eax
  8020d1:	89 02                	mov    %eax,(%edx)
}
  8020d3:	5d                   	pop    %ebp
  8020d4:	c3                   	ret    

008020d5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8020d5:	55                   	push   %ebp
  8020d6:	89 e5                	mov    %esp,%ebp
  8020d8:	57                   	push   %edi
  8020d9:	56                   	push   %esi
  8020da:	53                   	push   %ebx
  8020db:	83 ec 3c             	sub    $0x3c,%esp
  8020de:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020e1:	eb 18                	jmp    8020fb <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8020e3:	84 c0                	test   %al,%al
  8020e5:	0f 84 9f 03 00 00    	je     80248a <vprintfmt+0x3b5>
				return;
			putch(ch, putdat);
  8020eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020f2:	0f b6 c0             	movzbl %al,%eax
  8020f5:	89 04 24             	mov    %eax,(%esp)
  8020f8:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8020fb:	0f b6 03             	movzbl (%ebx),%eax
  8020fe:	83 c3 01             	add    $0x1,%ebx
  802101:	3c 25                	cmp    $0x25,%al
  802103:	75 de                	jne    8020e3 <vprintfmt+0xe>
  802105:	b9 00 00 00 00       	mov    $0x0,%ecx
  80210a:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
  802111:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  802116:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80211d:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
  802121:	eb 07                	jmp    80212a <vprintfmt+0x55>
  802123:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80212a:	0f b6 13             	movzbl (%ebx),%edx
  80212d:	83 c3 01             	add    $0x1,%ebx
  802130:	8d 42 dd             	lea    -0x23(%edx),%eax
  802133:	3c 55                	cmp    $0x55,%al
  802135:	0f 87 22 03 00 00    	ja     80245d <vprintfmt+0x388>
  80213b:	0f b6 c0             	movzbl %al,%eax
  80213e:	ff 24 85 60 43 80 00 	jmp    *0x804360(,%eax,4)
  802145:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
  802149:	eb df                	jmp    80212a <vprintfmt+0x55>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80214b:	0f b6 c2             	movzbl %dl,%eax
  80214e:	8d 78 d0             	lea    -0x30(%eax),%edi
				ch = *fmt;
  802151:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  802154:	8d 42 d0             	lea    -0x30(%edx),%eax
  802157:	83 f8 09             	cmp    $0x9,%eax
  80215a:	76 08                	jbe    802164 <vprintfmt+0x8f>
  80215c:	eb 39                	jmp    802197 <vprintfmt+0xc2>
  80215e:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
  802162:	eb c6                	jmp    80212a <vprintfmt+0x55>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  802164:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  802167:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  80216a:	8d 7c 42 d0          	lea    -0x30(%edx,%eax,2),%edi
				ch = *fmt;
  80216e:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  802171:	8d 42 d0             	lea    -0x30(%edx),%eax
  802174:	83 f8 09             	cmp    $0x9,%eax
  802177:	77 1e                	ja     802197 <vprintfmt+0xc2>
  802179:	eb e9                	jmp    802164 <vprintfmt+0x8f>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80217b:	8b 55 14             	mov    0x14(%ebp),%edx
  80217e:	8d 42 04             	lea    0x4(%edx),%eax
  802181:	89 45 14             	mov    %eax,0x14(%ebp)
  802184:	8b 3a                	mov    (%edx),%edi
  802186:	eb 0f                	jmp    802197 <vprintfmt+0xc2>
			goto process_precision;

		case '.':
			if (width < 0)
  802188:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80218c:	79 9c                	jns    80212a <vprintfmt+0x55>
  80218e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  802195:	eb 93                	jmp    80212a <vprintfmt+0x55>
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  802197:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80219b:	90                   	nop    
  80219c:	8d 74 26 00          	lea    0x0(%esi),%esi
  8021a0:	79 88                	jns    80212a <vprintfmt+0x55>
  8021a2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8021a5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8021aa:	e9 7b ff ff ff       	jmp    80212a <vprintfmt+0x55>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8021af:	83 c1 01             	add    $0x1,%ecx
  8021b2:	e9 73 ff ff ff       	jmp    80212a <vprintfmt+0x55>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8021b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8021ba:	8d 50 04             	lea    0x4(%eax),%edx
  8021bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8021c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021c7:	8b 00                	mov    (%eax),%eax
  8021c9:	89 04 24             	mov    %eax,(%esp)
  8021cc:	ff 55 08             	call   *0x8(%ebp)
  8021cf:	e9 27 ff ff ff       	jmp    8020fb <vprintfmt+0x26>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8021d4:	8b 55 14             	mov    0x14(%ebp),%edx
  8021d7:	8d 42 04             	lea    0x4(%edx),%eax
  8021da:	89 45 14             	mov    %eax,0x14(%ebp)
  8021dd:	8b 02                	mov    (%edx),%eax
  8021df:	89 c2                	mov    %eax,%edx
  8021e1:	c1 fa 1f             	sar    $0x1f,%edx
  8021e4:	31 d0                	xor    %edx,%eax
  8021e6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8021e8:	83 f8 0f             	cmp    $0xf,%eax
  8021eb:	7f 0b                	jg     8021f8 <vprintfmt+0x123>
  8021ed:	8b 14 85 c0 44 80 00 	mov    0x8044c0(,%eax,4),%edx
  8021f4:	85 d2                	test   %edx,%edx
  8021f6:	75 23                	jne    80221b <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8021f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021fc:	c7 44 24 08 35 42 80 	movl   $0x804235,0x8(%esp)
  802203:	00 
  802204:	8b 45 0c             	mov    0xc(%ebp),%eax
  802207:	89 44 24 04          	mov    %eax,0x4(%esp)
  80220b:	8b 55 08             	mov    0x8(%ebp),%edx
  80220e:	89 14 24             	mov    %edx,(%esp)
  802211:	e8 ff 02 00 00       	call   802515 <printfmt>
  802216:	e9 e0 fe ff ff       	jmp    8020fb <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80221b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80221f:	c7 44 24 08 4f 3c 80 	movl   $0x803c4f,0x8(%esp)
  802226:	00 
  802227:	8b 45 0c             	mov    0xc(%ebp),%eax
  80222a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80222e:	8b 55 08             	mov    0x8(%ebp),%edx
  802231:	89 14 24             	mov    %edx,(%esp)
  802234:	e8 dc 02 00 00       	call   802515 <printfmt>
  802239:	e9 bd fe ff ff       	jmp    8020fb <vprintfmt+0x26>
  80223e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802241:	89 f9                	mov    %edi,%ecx
  802243:	89 5d ec             	mov    %ebx,-0x14(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  802246:	8b 55 14             	mov    0x14(%ebp),%edx
  802249:	8d 42 04             	lea    0x4(%edx),%eax
  80224c:	89 45 14             	mov    %eax,0x14(%ebp)
  80224f:	8b 12                	mov    (%edx),%edx
  802251:	89 55 dc             	mov    %edx,-0x24(%ebp)
  802254:	85 d2                	test   %edx,%edx
  802256:	75 07                	jne    80225f <vprintfmt+0x18a>
  802258:	c7 45 dc 3e 42 80 00 	movl   $0x80423e,-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80225f:	85 f6                	test   %esi,%esi
  802261:	7e 41                	jle    8022a4 <vprintfmt+0x1cf>
  802263:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  802267:	74 3b                	je     8022a4 <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
  802269:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80226d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  802270:	89 04 24             	mov    %eax,(%esp)
  802273:	e8 e8 02 00 00       	call   802560 <strnlen>
  802278:	29 c6                	sub    %eax,%esi
  80227a:	89 75 f0             	mov    %esi,-0x10(%ebp)
  80227d:	85 f6                	test   %esi,%esi
  80227f:	7e 23                	jle    8022a4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  802281:	0f be 55 eb          	movsbl -0x15(%ebp),%edx
  802285:	89 55 d8             	mov    %edx,-0x28(%ebp)
  802288:	8b 45 0c             	mov    0xc(%ebp),%eax
  80228b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80228f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  802292:	89 14 24             	mov    %edx,(%esp)
  802295:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  802298:	83 ee 01             	sub    $0x1,%esi
  80229b:	75 eb                	jne    802288 <vprintfmt+0x1b3>
  80229d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8022a4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8022a7:	0f b6 02             	movzbl (%edx),%eax
  8022aa:	0f be d0             	movsbl %al,%edx
  8022ad:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8022b0:	84 c0                	test   %al,%al
  8022b2:	75 42                	jne    8022f6 <vprintfmt+0x221>
  8022b4:	eb 49                	jmp    8022ff <vprintfmt+0x22a>
				if (altflag && (ch < ' ' || ch > '~'))
  8022b6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8022ba:	74 1b                	je     8022d7 <vprintfmt+0x202>
  8022bc:	8d 42 e0             	lea    -0x20(%edx),%eax
  8022bf:	83 f8 5e             	cmp    $0x5e,%eax
  8022c2:	76 13                	jbe    8022d7 <vprintfmt+0x202>
					putch('?', putdat);
  8022c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022cb:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8022d2:	ff 55 08             	call   *0x8(%ebp)
  8022d5:	eb 0d                	jmp    8022e4 <vprintfmt+0x20f>
				else
					putch(ch, putdat);
  8022d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022de:	89 14 24             	mov    %edx,(%esp)
  8022e1:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8022e4:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  8022e8:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8022ec:	83 c6 01             	add    $0x1,%esi
  8022ef:	84 c0                	test   %al,%al
  8022f1:	74 0c                	je     8022ff <vprintfmt+0x22a>
  8022f3:	0f be d0             	movsbl %al,%edx
  8022f6:	85 ff                	test   %edi,%edi
  8022f8:	78 bc                	js     8022b6 <vprintfmt+0x1e1>
  8022fa:	83 ef 01             	sub    $0x1,%edi
  8022fd:	79 b7                	jns    8022b6 <vprintfmt+0x1e1>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8022ff:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  802303:	0f 8e f2 fd ff ff    	jle    8020fb <vprintfmt+0x26>
				putch(' ', putdat);
  802309:	8b 55 0c             	mov    0xc(%ebp),%edx
  80230c:	89 54 24 04          	mov    %edx,0x4(%esp)
  802310:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  802317:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80231a:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  80231e:	75 e9                	jne    802309 <vprintfmt+0x234>
  802320:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  802323:	e9 d3 fd ff ff       	jmp    8020fb <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  802328:	83 f9 01             	cmp    $0x1,%ecx
  80232b:	90                   	nop    
  80232c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802330:	7e 10                	jle    802342 <vprintfmt+0x26d>
		return va_arg(*ap, long long);
  802332:	8b 55 14             	mov    0x14(%ebp),%edx
  802335:	8d 42 08             	lea    0x8(%edx),%eax
  802338:	89 45 14             	mov    %eax,0x14(%ebp)
  80233b:	8b 32                	mov    (%edx),%esi
  80233d:	8b 7a 04             	mov    0x4(%edx),%edi
  802340:	eb 2a                	jmp    80236c <vprintfmt+0x297>
	else if (lflag)
  802342:	85 c9                	test   %ecx,%ecx
  802344:	74 14                	je     80235a <vprintfmt+0x285>
		return va_arg(*ap, long);
  802346:	8b 45 14             	mov    0x14(%ebp),%eax
  802349:	8d 50 04             	lea    0x4(%eax),%edx
  80234c:	89 55 14             	mov    %edx,0x14(%ebp)
  80234f:	8b 00                	mov    (%eax),%eax
  802351:	89 c6                	mov    %eax,%esi
  802353:	89 c7                	mov    %eax,%edi
  802355:	c1 ff 1f             	sar    $0x1f,%edi
  802358:	eb 12                	jmp    80236c <vprintfmt+0x297>
	else
		return va_arg(*ap, int);
  80235a:	8b 45 14             	mov    0x14(%ebp),%eax
  80235d:	8d 50 04             	lea    0x4(%eax),%edx
  802360:	89 55 14             	mov    %edx,0x14(%ebp)
  802363:	8b 00                	mov    (%eax),%eax
  802365:	89 c6                	mov    %eax,%esi
  802367:	89 c7                	mov    %eax,%edi
  802369:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80236c:	89 f2                	mov    %esi,%edx
  80236e:	89 f9                	mov    %edi,%ecx
  802370:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
			if ((long long) num < 0) {
  802377:	85 ff                	test   %edi,%edi
  802379:	0f 89 9b 00 00 00    	jns    80241a <vprintfmt+0x345>
				putch('-', putdat);
  80237f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802382:	89 44 24 04          	mov    %eax,0x4(%esp)
  802386:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80238d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  802390:	89 f2                	mov    %esi,%edx
  802392:	89 f9                	mov    %edi,%ecx
  802394:	f7 da                	neg    %edx
  802396:	83 d1 00             	adc    $0x0,%ecx
  802399:	f7 d9                	neg    %ecx
  80239b:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  8023a2:	eb 76                	jmp    80241a <vprintfmt+0x345>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8023a4:	89 ca                	mov    %ecx,%edx
  8023a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8023a9:	e8 cd fc ff ff       	call   80207b <getuint>
  8023ae:	89 d1                	mov    %edx,%ecx
  8023b0:	89 c2                	mov    %eax,%edx
  8023b2:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  8023b9:	eb 5f                	jmp    80241a <vprintfmt+0x345>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap,lflag);
  8023bb:	89 ca                	mov    %ecx,%edx
  8023bd:	8d 45 14             	lea    0x14(%ebp),%eax
  8023c0:	e8 b6 fc ff ff       	call   80207b <getuint>
  8023c5:	e9 31 fd ff ff       	jmp    8020fb <vprintfmt+0x26>
			base=8;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8023ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023d1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8023d8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8023db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023e2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8023e9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8023ec:	8b 55 14             	mov    0x14(%ebp),%edx
  8023ef:	8d 42 04             	lea    0x4(%edx),%eax
  8023f2:	89 45 14             	mov    %eax,0x14(%ebp)
  8023f5:	8b 12                	mov    (%edx),%edx
  8023f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8023fc:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  802403:	eb 15                	jmp    80241a <vprintfmt+0x345>
			base = 16;
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  802405:	89 ca                	mov    %ecx,%edx
  802407:	8d 45 14             	lea    0x14(%ebp),%eax
  80240a:	e8 6c fc ff ff       	call   80207b <getuint>
  80240f:	89 d1                	mov    %edx,%ecx
  802411:	89 c2                	mov    %eax,%edx
  802413:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80241a:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  80241e:	89 44 24 10          	mov    %eax,0x10(%esp)
  802422:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802425:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802429:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80242c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802430:	89 14 24             	mov    %edx,(%esp)
  802433:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802437:	8b 55 0c             	mov    0xc(%ebp),%edx
  80243a:	8b 45 08             	mov    0x8(%ebp),%eax
  80243d:	e8 4e fb ff ff       	call   801f90 <printnum>
  802442:	e9 b4 fc ff ff       	jmp    8020fb <vprintfmt+0x26>
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  802447:	8b 55 0c             	mov    0xc(%ebp),%edx
  80244a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80244e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  802455:	ff 55 08             	call   *0x8(%ebp)
  802458:	e9 9e fc ff ff       	jmp    8020fb <vprintfmt+0x26>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80245d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802460:	89 44 24 04          	mov    %eax,0x4(%esp)
  802464:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80246b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80246e:	83 eb 01             	sub    $0x1,%ebx
  802471:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  802475:	0f 84 80 fc ff ff    	je     8020fb <vprintfmt+0x26>
  80247b:	83 eb 01             	sub    $0x1,%ebx
  80247e:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  802482:	0f 84 73 fc ff ff    	je     8020fb <vprintfmt+0x26>
  802488:	eb f1                	jmp    80247b <vprintfmt+0x3a6>
				/* do nothing */;
			break;
		}
	}
}
  80248a:	83 c4 3c             	add    $0x3c,%esp
  80248d:	5b                   	pop    %ebx
  80248e:	5e                   	pop    %esi
  80248f:	5f                   	pop    %edi
  802490:	5d                   	pop    %ebp
  802491:	c3                   	ret    

00802492 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  802492:	55                   	push   %ebp
  802493:	89 e5                	mov    %esp,%ebp
  802495:	83 ec 28             	sub    $0x28,%esp
  802498:	8b 55 08             	mov    0x8(%ebp),%edx
  80249b:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80249e:	85 d2                	test   %edx,%edx
  8024a0:	74 04                	je     8024a6 <vsnprintf+0x14>
  8024a2:	85 c0                	test   %eax,%eax
  8024a4:	7f 07                	jg     8024ad <vsnprintf+0x1b>
  8024a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8024ab:	eb 3b                	jmp    8024e8 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8024ad:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8024b4:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
  8024b8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  8024bb:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8024be:	8b 45 14             	mov    0x14(%ebp),%eax
  8024c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8024c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024d3:	c7 04 24 b7 20 80 00 	movl   $0x8020b7,(%esp)
  8024da:	e8 f6 fb ff ff       	call   8020d5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8024df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024e2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8024e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8024e8:	c9                   	leave  
  8024e9:	c3                   	ret    

008024ea <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8024ea:	55                   	push   %ebp
  8024eb:	89 e5                	mov    %esp,%ebp
  8024ed:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8024f0:	8d 45 14             	lea    0x14(%ebp),%eax
  8024f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8024f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8024fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  802501:	8b 45 0c             	mov    0xc(%ebp),%eax
  802504:	89 44 24 04          	mov    %eax,0x4(%esp)
  802508:	8b 45 08             	mov    0x8(%ebp),%eax
  80250b:	89 04 24             	mov    %eax,(%esp)
  80250e:	e8 7f ff ff ff       	call   802492 <vsnprintf>
	va_end(ap);

	return rc;
}
  802513:	c9                   	leave  
  802514:	c3                   	ret    

00802515 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  802515:	55                   	push   %ebp
  802516:	89 e5                	mov    %esp,%ebp
  802518:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  80251b:	8d 45 14             	lea    0x14(%ebp),%eax
  80251e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  802521:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802525:	8b 45 10             	mov    0x10(%ebp),%eax
  802528:	89 44 24 08          	mov    %eax,0x8(%esp)
  80252c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80252f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802533:	8b 45 08             	mov    0x8(%ebp),%eax
  802536:	89 04 24             	mov    %eax,(%esp)
  802539:	e8 97 fb ff ff       	call   8020d5 <vprintfmt>
	va_end(ap);
}
  80253e:	c9                   	leave  
  80253f:	c3                   	ret    

00802540 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  802540:	55                   	push   %ebp
  802541:	89 e5                	mov    %esp,%ebp
  802543:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  802546:	b8 00 00 00 00       	mov    $0x0,%eax
  80254b:	80 3a 00             	cmpb   $0x0,(%edx)
  80254e:	74 0e                	je     80255e <strlen+0x1e>
  802550:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  802555:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  802558:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80255c:	75 f7                	jne    802555 <strlen+0x15>
		n++;
	return n;
}
  80255e:	5d                   	pop    %ebp
  80255f:	c3                   	ret    

00802560 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  802560:	55                   	push   %ebp
  802561:	89 e5                	mov    %esp,%ebp
  802563:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802566:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802569:	85 d2                	test   %edx,%edx
  80256b:	74 19                	je     802586 <strnlen+0x26>
  80256d:	80 39 00             	cmpb   $0x0,(%ecx)
  802570:	74 14                	je     802586 <strnlen+0x26>
  802572:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  802577:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80257a:	39 d0                	cmp    %edx,%eax
  80257c:	74 0d                	je     80258b <strnlen+0x2b>
  80257e:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  802582:	74 07                	je     80258b <strnlen+0x2b>
  802584:	eb f1                	jmp    802577 <strnlen+0x17>
  802586:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80258b:	5d                   	pop    %ebp
  80258c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802590:	c3                   	ret    

00802591 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  802591:	55                   	push   %ebp
  802592:	89 e5                	mov    %esp,%ebp
  802594:	53                   	push   %ebx
  802595:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802598:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80259b:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80259d:	0f b6 01             	movzbl (%ecx),%eax
  8025a0:	88 02                	mov    %al,(%edx)
  8025a2:	83 c2 01             	add    $0x1,%edx
  8025a5:	83 c1 01             	add    $0x1,%ecx
  8025a8:	84 c0                	test   %al,%al
  8025aa:	75 f1                	jne    80259d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8025ac:	89 d8                	mov    %ebx,%eax
  8025ae:	5b                   	pop    %ebx
  8025af:	5d                   	pop    %ebp
  8025b0:	c3                   	ret    

008025b1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8025b1:	55                   	push   %ebp
  8025b2:	89 e5                	mov    %esp,%ebp
  8025b4:	57                   	push   %edi
  8025b5:	56                   	push   %esi
  8025b6:	53                   	push   %ebx
  8025b7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8025ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025bd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8025c0:	85 f6                	test   %esi,%esi
  8025c2:	74 1c                	je     8025e0 <strncpy+0x2f>
  8025c4:	89 fa                	mov    %edi,%edx
  8025c6:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  8025cb:	0f b6 01             	movzbl (%ecx),%eax
  8025ce:	88 02                	mov    %al,(%edx)
  8025d0:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8025d3:	80 39 01             	cmpb   $0x1,(%ecx)
  8025d6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8025d9:	83 c3 01             	add    $0x1,%ebx
  8025dc:	39 f3                	cmp    %esi,%ebx
  8025de:	75 eb                	jne    8025cb <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8025e0:	89 f8                	mov    %edi,%eax
  8025e2:	5b                   	pop    %ebx
  8025e3:	5e                   	pop    %esi
  8025e4:	5f                   	pop    %edi
  8025e5:	5d                   	pop    %ebp
  8025e6:	c3                   	ret    

008025e7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8025e7:	55                   	push   %ebp
  8025e8:	89 e5                	mov    %esp,%ebp
  8025ea:	56                   	push   %esi
  8025eb:	53                   	push   %ebx
  8025ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8025ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025f2:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8025f5:	89 f0                	mov    %esi,%eax
  8025f7:	85 d2                	test   %edx,%edx
  8025f9:	74 2c                	je     802627 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  8025fb:	89 d3                	mov    %edx,%ebx
  8025fd:	83 eb 01             	sub    $0x1,%ebx
  802600:	74 20                	je     802622 <strlcpy+0x3b>
  802602:	0f b6 11             	movzbl (%ecx),%edx
  802605:	84 d2                	test   %dl,%dl
  802607:	74 19                	je     802622 <strlcpy+0x3b>
  802609:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  80260b:	88 10                	mov    %dl,(%eax)
  80260d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802610:	83 eb 01             	sub    $0x1,%ebx
  802613:	74 0f                	je     802624 <strlcpy+0x3d>
  802615:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  802619:	83 c1 01             	add    $0x1,%ecx
  80261c:	84 d2                	test   %dl,%dl
  80261e:	74 04                	je     802624 <strlcpy+0x3d>
  802620:	eb e9                	jmp    80260b <strlcpy+0x24>
  802622:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  802624:	c6 00 00             	movb   $0x0,(%eax)
  802627:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  802629:	5b                   	pop    %ebx
  80262a:	5e                   	pop    %esi
  80262b:	5d                   	pop    %ebp
  80262c:	c3                   	ret    

0080262d <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  80262d:	55                   	push   %ebp
  80262e:	89 e5                	mov    %esp,%ebp
  802630:	56                   	push   %esi
  802631:	53                   	push   %ebx
  802632:	8b 75 08             	mov    0x8(%ebp),%esi
  802635:	8b 45 0c             	mov    0xc(%ebp),%eax
  802638:	8b 55 10             	mov    0x10(%ebp),%edx
    int c;
    char *q = buf;

    if (buf_size <= 0)
  80263b:	85 c0                	test   %eax,%eax
  80263d:	7e 2e                	jle    80266d <pstrcpy+0x40>
        return;

    for(;;) {
        c = *str++;
  80263f:	0f b6 0a             	movzbl (%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  802642:	84 c9                	test   %cl,%cl
  802644:	74 22                	je     802668 <pstrcpy+0x3b>
  802646:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  80264a:	89 f0                	mov    %esi,%eax
  80264c:	39 de                	cmp    %ebx,%esi
  80264e:	72 09                	jb     802659 <pstrcpy+0x2c>
  802650:	eb 16                	jmp    802668 <pstrcpy+0x3b>
  802652:	83 c2 01             	add    $0x1,%edx
  802655:	39 d8                	cmp    %ebx,%eax
  802657:	73 11                	jae    80266a <pstrcpy+0x3d>
            break;
        *q++ = c;
  802659:	88 08                	mov    %cl,(%eax)
  80265b:	83 c0 01             	add    $0x1,%eax

    if (buf_size <= 0)
        return;

    for(;;) {
        c = *str++;
  80265e:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  802662:	84 c9                	test   %cl,%cl
  802664:	75 ec                	jne    802652 <pstrcpy+0x25>
  802666:	eb 02                	jmp    80266a <pstrcpy+0x3d>
  802668:	89 f0                	mov    %esi,%eax
            break;
        *q++ = c;
    }
    *q = '\0';
  80266a:	c6 00 00             	movb   $0x0,(%eax)
}
  80266d:	5b                   	pop    %ebx
  80266e:	5e                   	pop    %esi
  80266f:	5d                   	pop    %ebp
  802670:	c3                   	ret    

00802671 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  802671:	55                   	push   %ebp
  802672:	89 e5                	mov    %esp,%ebp
  802674:	8b 55 08             	mov    0x8(%ebp),%edx
  802677:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  80267a:	0f b6 02             	movzbl (%edx),%eax
  80267d:	84 c0                	test   %al,%al
  80267f:	74 16                	je     802697 <strcmp+0x26>
  802681:	3a 01                	cmp    (%ecx),%al
  802683:	75 12                	jne    802697 <strcmp+0x26>
		p++, q++;
  802685:	83 c1 01             	add    $0x1,%ecx
    *q = '\0';
}
int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  802688:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  80268c:	84 c0                	test   %al,%al
  80268e:	74 07                	je     802697 <strcmp+0x26>
  802690:	83 c2 01             	add    $0x1,%edx
  802693:	3a 01                	cmp    (%ecx),%al
  802695:	74 ee                	je     802685 <strcmp+0x14>
  802697:	0f b6 c0             	movzbl %al,%eax
  80269a:	0f b6 11             	movzbl (%ecx),%edx
  80269d:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80269f:	5d                   	pop    %ebp
  8026a0:	c3                   	ret    

008026a1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8026a1:	55                   	push   %ebp
  8026a2:	89 e5                	mov    %esp,%ebp
  8026a4:	53                   	push   %ebx
  8026a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8026ab:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8026ae:	85 d2                	test   %edx,%edx
  8026b0:	74 2d                	je     8026df <strncmp+0x3e>
  8026b2:	0f b6 01             	movzbl (%ecx),%eax
  8026b5:	84 c0                	test   %al,%al
  8026b7:	74 1a                	je     8026d3 <strncmp+0x32>
  8026b9:	3a 03                	cmp    (%ebx),%al
  8026bb:	75 16                	jne    8026d3 <strncmp+0x32>
  8026bd:	83 ea 01             	sub    $0x1,%edx
  8026c0:	74 1d                	je     8026df <strncmp+0x3e>
		n--, p++, q++;
  8026c2:	83 c1 01             	add    $0x1,%ecx
  8026c5:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8026c8:	0f b6 01             	movzbl (%ecx),%eax
  8026cb:	84 c0                	test   %al,%al
  8026cd:	74 04                	je     8026d3 <strncmp+0x32>
  8026cf:	3a 03                	cmp    (%ebx),%al
  8026d1:	74 ea                	je     8026bd <strncmp+0x1c>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8026d3:	0f b6 11             	movzbl (%ecx),%edx
  8026d6:	0f b6 03             	movzbl (%ebx),%eax
  8026d9:	29 c2                	sub    %eax,%edx
  8026db:	89 d0                	mov    %edx,%eax
  8026dd:	eb 05                	jmp    8026e4 <strncmp+0x43>
  8026df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8026e4:	5b                   	pop    %ebx
  8026e5:	5d                   	pop    %ebp
  8026e6:	c3                   	ret    

008026e7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8026e7:	55                   	push   %ebp
  8026e8:	89 e5                	mov    %esp,%ebp
  8026ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8026ed:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8026f1:	0f b6 10             	movzbl (%eax),%edx
  8026f4:	84 d2                	test   %dl,%dl
  8026f6:	74 14                	je     80270c <strchr+0x25>
		if (*s == c)
  8026f8:	38 ca                	cmp    %cl,%dl
  8026fa:	75 06                	jne    802702 <strchr+0x1b>
  8026fc:	eb 13                	jmp    802711 <strchr+0x2a>
  8026fe:	38 ca                	cmp    %cl,%dl
  802700:	74 0f                	je     802711 <strchr+0x2a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  802702:	83 c0 01             	add    $0x1,%eax
  802705:	0f b6 10             	movzbl (%eax),%edx
  802708:	84 d2                	test   %dl,%dl
  80270a:	75 f2                	jne    8026fe <strchr+0x17>
  80270c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  802711:	5d                   	pop    %ebp
  802712:	c3                   	ret    

00802713 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  802713:	55                   	push   %ebp
  802714:	89 e5                	mov    %esp,%ebp
  802716:	8b 45 08             	mov    0x8(%ebp),%eax
  802719:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80271d:	0f b6 10             	movzbl (%eax),%edx
  802720:	84 d2                	test   %dl,%dl
  802722:	74 18                	je     80273c <strfind+0x29>
		if (*s == c)
  802724:	38 ca                	cmp    %cl,%dl
  802726:	75 0a                	jne    802732 <strfind+0x1f>
  802728:	eb 12                	jmp    80273c <strfind+0x29>
  80272a:	38 ca                	cmp    %cl,%dl
  80272c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802730:	74 0a                	je     80273c <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  802732:	83 c0 01             	add    $0x1,%eax
  802735:	0f b6 10             	movzbl (%eax),%edx
  802738:	84 d2                	test   %dl,%dl
  80273a:	75 ee                	jne    80272a <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  80273c:	5d                   	pop    %ebp
  80273d:	c3                   	ret    

0080273e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80273e:	55                   	push   %ebp
  80273f:	89 e5                	mov    %esp,%ebp
  802741:	83 ec 08             	sub    $0x8,%esp
  802744:	89 1c 24             	mov    %ebx,(%esp)
  802747:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80274b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80274e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  802751:	85 db                	test   %ebx,%ebx
  802753:	74 36                	je     80278b <memset+0x4d>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802755:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80275b:	75 26                	jne    802783 <memset+0x45>
  80275d:	f6 c3 03             	test   $0x3,%bl
  802760:	75 21                	jne    802783 <memset+0x45>
		c &= 0xFF;
  802762:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  802766:	89 d0                	mov    %edx,%eax
  802768:	c1 e0 18             	shl    $0x18,%eax
  80276b:	89 d1                	mov    %edx,%ecx
  80276d:	c1 e1 10             	shl    $0x10,%ecx
  802770:	09 c8                	or     %ecx,%eax
  802772:	09 d0                	or     %edx,%eax
  802774:	c1 e2 08             	shl    $0x8,%edx
  802777:	09 d0                	or     %edx,%eax
  802779:	89 d9                	mov    %ebx,%ecx
  80277b:	c1 e9 02             	shr    $0x2,%ecx
  80277e:	fc                   	cld    
  80277f:	f3 ab                	rep stos %eax,%es:(%edi)
  802781:	eb 08                	jmp    80278b <memset+0x4d>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802783:	8b 45 0c             	mov    0xc(%ebp),%eax
  802786:	89 d9                	mov    %ebx,%ecx
  802788:	fc                   	cld    
  802789:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80278b:	89 f8                	mov    %edi,%eax
  80278d:	8b 1c 24             	mov    (%esp),%ebx
  802790:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802794:	89 ec                	mov    %ebp,%esp
  802796:	5d                   	pop    %ebp
  802797:	c3                   	ret    

00802798 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802798:	55                   	push   %ebp
  802799:	89 e5                	mov    %esp,%ebp
  80279b:	83 ec 08             	sub    $0x8,%esp
  80279e:	89 34 24             	mov    %esi,(%esp)
  8027a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8027a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8027a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8027ab:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8027ae:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8027b0:	39 c6                	cmp    %eax,%esi
  8027b2:	73 38                	jae    8027ec <memmove+0x54>
  8027b4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8027b7:	39 d0                	cmp    %edx,%eax
  8027b9:	73 31                	jae    8027ec <memmove+0x54>
		s += n;
		d += n;
  8027bb:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8027be:	f6 c2 03             	test   $0x3,%dl
  8027c1:	75 1d                	jne    8027e0 <memmove+0x48>
  8027c3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8027c9:	75 15                	jne    8027e0 <memmove+0x48>
  8027cb:	f6 c1 03             	test   $0x3,%cl
  8027ce:	66 90                	xchg   %ax,%ax
  8027d0:	75 0e                	jne    8027e0 <memmove+0x48>
			asm volatile("std; rep movsl\n"
  8027d2:	8d 7e fc             	lea    -0x4(%esi),%edi
  8027d5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8027d8:	c1 e9 02             	shr    $0x2,%ecx
  8027db:	fd                   	std    
  8027dc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8027de:	eb 09                	jmp    8027e9 <memmove+0x51>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8027e0:	8d 7e ff             	lea    -0x1(%esi),%edi
  8027e3:	8d 72 ff             	lea    -0x1(%edx),%esi
  8027e6:	fd                   	std    
  8027e7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8027e9:	fc                   	cld    
  8027ea:	eb 21                	jmp    80280d <memmove+0x75>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8027ec:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8027f2:	75 16                	jne    80280a <memmove+0x72>
  8027f4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8027fa:	75 0e                	jne    80280a <memmove+0x72>
  8027fc:	f6 c1 03             	test   $0x3,%cl
  8027ff:	90                   	nop    
  802800:	75 08                	jne    80280a <memmove+0x72>
			asm volatile("cld; rep movsl\n"
  802802:	c1 e9 02             	shr    $0x2,%ecx
  802805:	fc                   	cld    
  802806:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802808:	eb 03                	jmp    80280d <memmove+0x75>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80280a:	fc                   	cld    
  80280b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80280d:	8b 34 24             	mov    (%esp),%esi
  802810:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802814:	89 ec                	mov    %ebp,%esp
  802816:	5d                   	pop    %ebp
  802817:	c3                   	ret    

00802818 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  802818:	55                   	push   %ebp
  802819:	89 e5                	mov    %esp,%ebp
  80281b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80281e:	8b 45 10             	mov    0x10(%ebp),%eax
  802821:	89 44 24 08          	mov    %eax,0x8(%esp)
  802825:	8b 45 0c             	mov    0xc(%ebp),%eax
  802828:	89 44 24 04          	mov    %eax,0x4(%esp)
  80282c:	8b 45 08             	mov    0x8(%ebp),%eax
  80282f:	89 04 24             	mov    %eax,(%esp)
  802832:	e8 61 ff ff ff       	call   802798 <memmove>
}
  802837:	c9                   	leave  
  802838:	c3                   	ret    

00802839 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  802839:	55                   	push   %ebp
  80283a:	89 e5                	mov    %esp,%ebp
  80283c:	57                   	push   %edi
  80283d:	56                   	push   %esi
  80283e:	53                   	push   %ebx
  80283f:	83 ec 04             	sub    $0x4,%esp
  802842:	8b 45 08             	mov    0x8(%ebp),%eax
  802845:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802848:	8b 55 10             	mov    0x10(%ebp),%edx
  80284b:	83 ea 01             	sub    $0x1,%edx
  80284e:	83 fa ff             	cmp    $0xffffffff,%edx
  802851:	74 47                	je     80289a <memcmp+0x61>
		if (*s1 != *s2)
  802853:	0f b6 30             	movzbl (%eax),%esi
  802856:	0f b6 39             	movzbl (%ecx),%edi
			return (int) *s1 - (int) *s2;
  802859:	89 45 f0             	mov    %eax,-0x10(%ebp)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  80285c:	89 f0                	mov    %esi,%eax
  80285e:	89 fb                	mov    %edi,%ebx
  802860:	38 d8                	cmp    %bl,%al
  802862:	74 2e                	je     802892 <memcmp+0x59>
  802864:	eb 1c                	jmp    802882 <memcmp+0x49>
  802866:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802869:	0f b6 70 01          	movzbl 0x1(%eax),%esi
  80286d:	0f b6 79 01          	movzbl 0x1(%ecx),%edi
  802871:	83 c0 01             	add    $0x1,%eax
  802874:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802877:	83 c1 01             	add    $0x1,%ecx
  80287a:	89 f3                	mov    %esi,%ebx
  80287c:	89 f8                	mov    %edi,%eax
  80287e:	38 c3                	cmp    %al,%bl
  802880:	74 10                	je     802892 <memcmp+0x59>
			return (int) *s1 - (int) *s2;
  802882:	89 f1                	mov    %esi,%ecx
  802884:	0f b6 d1             	movzbl %cl,%edx
  802887:	89 fb                	mov    %edi,%ebx
  802889:	0f b6 c3             	movzbl %bl,%eax
  80288c:	29 c2                	sub    %eax,%edx
  80288e:	89 d0                	mov    %edx,%eax
  802890:	eb 0d                	jmp    80289f <memcmp+0x66>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802892:	83 ea 01             	sub    $0x1,%edx
  802895:	83 fa ff             	cmp    $0xffffffff,%edx
  802898:	75 cc                	jne    802866 <memcmp+0x2d>
  80289a:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  80289f:	83 c4 04             	add    $0x4,%esp
  8028a2:	5b                   	pop    %ebx
  8028a3:	5e                   	pop    %esi
  8028a4:	5f                   	pop    %edi
  8028a5:	5d                   	pop    %ebp
  8028a6:	c3                   	ret    

008028a7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8028a7:	55                   	push   %ebp
  8028a8:	89 e5                	mov    %esp,%ebp
  8028aa:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8028ad:	89 c1                	mov    %eax,%ecx
  8028af:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
  8028b2:	39 c8                	cmp    %ecx,%eax
  8028b4:	73 15                	jae    8028cb <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  8028b6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
  8028ba:	38 10                	cmp    %dl,(%eax)
  8028bc:	75 06                	jne    8028c4 <memfind+0x1d>
  8028be:	eb 0b                	jmp    8028cb <memfind+0x24>
  8028c0:	38 10                	cmp    %dl,(%eax)
  8028c2:	74 07                	je     8028cb <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8028c4:	83 c0 01             	add    $0x1,%eax
  8028c7:	39 c8                	cmp    %ecx,%eax
  8028c9:	75 f5                	jne    8028c0 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8028cb:	5d                   	pop    %ebp
  8028cc:	8d 74 26 00          	lea    0x0(%esi),%esi
  8028d0:	c3                   	ret    

008028d1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8028d1:	55                   	push   %ebp
  8028d2:	89 e5                	mov    %esp,%ebp
  8028d4:	57                   	push   %edi
  8028d5:	56                   	push   %esi
  8028d6:	53                   	push   %ebx
  8028d7:	83 ec 04             	sub    $0x4,%esp
  8028da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8028dd:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8028e0:	0f b6 01             	movzbl (%ecx),%eax
  8028e3:	3c 20                	cmp    $0x20,%al
  8028e5:	74 04                	je     8028eb <strtol+0x1a>
  8028e7:	3c 09                	cmp    $0x9,%al
  8028e9:	75 0e                	jne    8028f9 <strtol+0x28>
		s++;
  8028eb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8028ee:	0f b6 01             	movzbl (%ecx),%eax
  8028f1:	3c 20                	cmp    $0x20,%al
  8028f3:	74 f6                	je     8028eb <strtol+0x1a>
  8028f5:	3c 09                	cmp    $0x9,%al
  8028f7:	74 f2                	je     8028eb <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  8028f9:	3c 2b                	cmp    $0x2b,%al
  8028fb:	75 0c                	jne    802909 <strtol+0x38>
		s++;
  8028fd:	83 c1 01             	add    $0x1,%ecx
  802900:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  802907:	eb 15                	jmp    80291e <strtol+0x4d>
	else if (*s == '-')
  802909:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  802910:	3c 2d                	cmp    $0x2d,%al
  802912:	75 0a                	jne    80291e <strtol+0x4d>
		s++, neg = 1;
  802914:	83 c1 01             	add    $0x1,%ecx
  802917:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80291e:	85 f6                	test   %esi,%esi
  802920:	0f 94 c0             	sete   %al
  802923:	74 05                	je     80292a <strtol+0x59>
  802925:	83 fe 10             	cmp    $0x10,%esi
  802928:	75 18                	jne    802942 <strtol+0x71>
  80292a:	80 39 30             	cmpb   $0x30,(%ecx)
  80292d:	75 13                	jne    802942 <strtol+0x71>
  80292f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  802933:	75 0d                	jne    802942 <strtol+0x71>
		s += 2, base = 16;
  802935:	83 c1 02             	add    $0x2,%ecx
  802938:	be 10 00 00 00       	mov    $0x10,%esi
  80293d:	8d 76 00             	lea    0x0(%esi),%esi
  802940:	eb 1b                	jmp    80295d <strtol+0x8c>
	else if (base == 0 && s[0] == '0')
  802942:	85 f6                	test   %esi,%esi
  802944:	75 0e                	jne    802954 <strtol+0x83>
  802946:	80 39 30             	cmpb   $0x30,(%ecx)
  802949:	75 09                	jne    802954 <strtol+0x83>
		s++, base = 8;
  80294b:	83 c1 01             	add    $0x1,%ecx
  80294e:	66 be 08 00          	mov    $0x8,%si
  802952:	eb 09                	jmp    80295d <strtol+0x8c>
	else if (base == 0)
  802954:	84 c0                	test   %al,%al
  802956:	74 05                	je     80295d <strtol+0x8c>
  802958:	be 0a 00 00 00       	mov    $0xa,%esi
  80295d:	bf 00 00 00 00       	mov    $0x0,%edi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802962:	0f b6 11             	movzbl (%ecx),%edx
  802965:	89 d3                	mov    %edx,%ebx
  802967:	8d 42 d0             	lea    -0x30(%edx),%eax
  80296a:	3c 09                	cmp    $0x9,%al
  80296c:	77 08                	ja     802976 <strtol+0xa5>
			dig = *s - '0';
  80296e:	0f be c2             	movsbl %dl,%eax
  802971:	8d 50 d0             	lea    -0x30(%eax),%edx
  802974:	eb 1c                	jmp    802992 <strtol+0xc1>
		else if (*s >= 'a' && *s <= 'z')
  802976:	8d 43 9f             	lea    -0x61(%ebx),%eax
  802979:	3c 19                	cmp    $0x19,%al
  80297b:	77 08                	ja     802985 <strtol+0xb4>
			dig = *s - 'a' + 10;
  80297d:	0f be c2             	movsbl %dl,%eax
  802980:	8d 50 a9             	lea    -0x57(%eax),%edx
  802983:	eb 0d                	jmp    802992 <strtol+0xc1>
		else if (*s >= 'A' && *s <= 'Z')
  802985:	8d 43 bf             	lea    -0x41(%ebx),%eax
  802988:	3c 19                	cmp    $0x19,%al
  80298a:	77 17                	ja     8029a3 <strtol+0xd2>
			dig = *s - 'A' + 10;
  80298c:	0f be c2             	movsbl %dl,%eax
  80298f:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  802992:	39 f2                	cmp    %esi,%edx
  802994:	7d 0d                	jge    8029a3 <strtol+0xd2>
			break;
		s++, val = (val * base) + dig;
  802996:	83 c1 01             	add    $0x1,%ecx
  802999:	89 f8                	mov    %edi,%eax
  80299b:	0f af c6             	imul   %esi,%eax
  80299e:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  8029a1:	eb bf                	jmp    802962 <strtol+0x91>
		// we don't properly detect overflow!
	}
  8029a3:	89 f8                	mov    %edi,%eax

	if (endptr)
  8029a5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8029a9:	74 05                	je     8029b0 <strtol+0xdf>
		*endptr = (char *) s;
  8029ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8029ae:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  8029b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8029b4:	74 04                	je     8029ba <strtol+0xe9>
  8029b6:	89 c7                	mov    %eax,%edi
  8029b8:	f7 df                	neg    %edi
}
  8029ba:	89 f8                	mov    %edi,%eax
  8029bc:	83 c4 04             	add    $0x4,%esp
  8029bf:	5b                   	pop    %ebx
  8029c0:	5e                   	pop    %esi
  8029c1:	5f                   	pop    %edi
  8029c2:	5d                   	pop    %ebp
  8029c3:	c3                   	ret    

008029c4 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8029c4:	55                   	push   %ebp
  8029c5:	89 e5                	mov    %esp,%ebp
  8029c7:	83 ec 0c             	sub    $0xc,%esp
  8029ca:	89 1c 24             	mov    %ebx,(%esp)
  8029cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029d1:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8029d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8029da:	bf 00 00 00 00       	mov    $0x0,%edi
  8029df:	89 fa                	mov    %edi,%edx
  8029e1:	89 f9                	mov    %edi,%ecx
  8029e3:	89 fb                	mov    %edi,%ebx
  8029e5:	89 fe                	mov    %edi,%esi
  8029e7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8029e9:	8b 1c 24             	mov    (%esp),%ebx
  8029ec:	8b 74 24 04          	mov    0x4(%esp),%esi
  8029f0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8029f4:	89 ec                	mov    %ebp,%esp
  8029f6:	5d                   	pop    %ebp
  8029f7:	c3                   	ret    

008029f8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8029f8:	55                   	push   %ebp
  8029f9:	89 e5                	mov    %esp,%ebp
  8029fb:	83 ec 0c             	sub    $0xc,%esp
  8029fe:	89 1c 24             	mov    %ebx,(%esp)
  802a01:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a05:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802a09:	8b 55 08             	mov    0x8(%ebp),%edx
  802a0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802a0f:	bf 00 00 00 00       	mov    $0x0,%edi
  802a14:	89 f8                	mov    %edi,%eax
  802a16:	89 fb                	mov    %edi,%ebx
  802a18:	89 fe                	mov    %edi,%esi
  802a1a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  802a1c:	8b 1c 24             	mov    (%esp),%ebx
  802a1f:	8b 74 24 04          	mov    0x4(%esp),%esi
  802a23:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802a27:	89 ec                	mov    %ebp,%esp
  802a29:	5d                   	pop    %ebp
  802a2a:	c3                   	ret    

00802a2b <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  802a2b:	55                   	push   %ebp
  802a2c:	89 e5                	mov    %esp,%ebp
  802a2e:	83 ec 28             	sub    $0x28,%esp
  802a31:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802a34:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802a37:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802a3a:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802a3d:	b8 0d 00 00 00       	mov    $0xd,%eax
  802a42:	bf 00 00 00 00       	mov    $0x0,%edi
  802a47:	89 f9                	mov    %edi,%ecx
  802a49:	89 fb                	mov    %edi,%ebx
  802a4b:	89 fe                	mov    %edi,%esi
  802a4d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  802a4f:	85 c0                	test   %eax,%eax
  802a51:	7e 28                	jle    802a7b <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  802a53:	89 44 24 10          	mov    %eax,0x10(%esp)
  802a57:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  802a5e:	00 
  802a5f:	c7 44 24 08 1f 45 80 	movl   $0x80451f,0x8(%esp)
  802a66:	00 
  802a67:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802a6e:	00 
  802a6f:	c7 04 24 3c 45 80 00 	movl   $0x80453c,(%esp)
  802a76:	e8 e9 f3 ff ff       	call   801e64 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  802a7b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802a7e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802a81:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802a84:	89 ec                	mov    %ebp,%esp
  802a86:	5d                   	pop    %ebp
  802a87:	c3                   	ret    

00802a88 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802a88:	55                   	push   %ebp
  802a89:	89 e5                	mov    %esp,%ebp
  802a8b:	83 ec 0c             	sub    $0xc,%esp
  802a8e:	89 1c 24             	mov    %ebx,(%esp)
  802a91:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a95:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802a99:	8b 55 08             	mov    0x8(%ebp),%edx
  802a9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802aa2:	8b 7d 14             	mov    0x14(%ebp),%edi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802aa5:	b8 0c 00 00 00       	mov    $0xc,%eax
  802aaa:	be 00 00 00 00       	mov    $0x0,%esi
  802aaf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  802ab1:	8b 1c 24             	mov    (%esp),%ebx
  802ab4:	8b 74 24 04          	mov    0x4(%esp),%esi
  802ab8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802abc:	89 ec                	mov    %ebp,%esp
  802abe:	5d                   	pop    %ebp
  802abf:	c3                   	ret    

00802ac0 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802ac0:	55                   	push   %ebp
  802ac1:	89 e5                	mov    %esp,%ebp
  802ac3:	83 ec 28             	sub    $0x28,%esp
  802ac6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802ac9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802acc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802acf:	8b 55 08             	mov    0x8(%ebp),%edx
  802ad2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802ad5:	b8 0a 00 00 00       	mov    $0xa,%eax
  802ada:	bf 00 00 00 00       	mov    $0x0,%edi
  802adf:	89 fb                	mov    %edi,%ebx
  802ae1:	89 fe                	mov    %edi,%esi
  802ae3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  802ae5:	85 c0                	test   %eax,%eax
  802ae7:	7e 28                	jle    802b11 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  802ae9:	89 44 24 10          	mov    %eax,0x10(%esp)
  802aed:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  802af4:	00 
  802af5:	c7 44 24 08 1f 45 80 	movl   $0x80451f,0x8(%esp)
  802afc:	00 
  802afd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802b04:	00 
  802b05:	c7 04 24 3c 45 80 00 	movl   $0x80453c,(%esp)
  802b0c:	e8 53 f3 ff ff       	call   801e64 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802b11:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802b14:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802b17:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802b1a:	89 ec                	mov    %ebp,%esp
  802b1c:	5d                   	pop    %ebp
  802b1d:	c3                   	ret    

00802b1e <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802b1e:	55                   	push   %ebp
  802b1f:	89 e5                	mov    %esp,%ebp
  802b21:	83 ec 28             	sub    $0x28,%esp
  802b24:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802b27:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802b2a:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802b2d:	8b 55 08             	mov    0x8(%ebp),%edx
  802b30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802b33:	b8 09 00 00 00       	mov    $0x9,%eax
  802b38:	bf 00 00 00 00       	mov    $0x0,%edi
  802b3d:	89 fb                	mov    %edi,%ebx
  802b3f:	89 fe                	mov    %edi,%esi
  802b41:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  802b43:	85 c0                	test   %eax,%eax
  802b45:	7e 28                	jle    802b6f <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  802b47:	89 44 24 10          	mov    %eax,0x10(%esp)
  802b4b:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  802b52:	00 
  802b53:	c7 44 24 08 1f 45 80 	movl   $0x80451f,0x8(%esp)
  802b5a:	00 
  802b5b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802b62:	00 
  802b63:	c7 04 24 3c 45 80 00 	movl   $0x80453c,(%esp)
  802b6a:	e8 f5 f2 ff ff       	call   801e64 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  802b6f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802b72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802b75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802b78:	89 ec                	mov    %ebp,%esp
  802b7a:	5d                   	pop    %ebp
  802b7b:	c3                   	ret    

00802b7c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  802b7c:	55                   	push   %ebp
  802b7d:	89 e5                	mov    %esp,%ebp
  802b7f:	83 ec 28             	sub    $0x28,%esp
  802b82:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802b85:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802b88:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802b8b:	8b 55 08             	mov    0x8(%ebp),%edx
  802b8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802b91:	b8 08 00 00 00       	mov    $0x8,%eax
  802b96:	bf 00 00 00 00       	mov    $0x0,%edi
  802b9b:	89 fb                	mov    %edi,%ebx
  802b9d:	89 fe                	mov    %edi,%esi
  802b9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  802ba1:	85 c0                	test   %eax,%eax
  802ba3:	7e 28                	jle    802bcd <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  802ba5:	89 44 24 10          	mov    %eax,0x10(%esp)
  802ba9:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  802bb0:	00 
  802bb1:	c7 44 24 08 1f 45 80 	movl   $0x80451f,0x8(%esp)
  802bb8:	00 
  802bb9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802bc0:	00 
  802bc1:	c7 04 24 3c 45 80 00 	movl   $0x80453c,(%esp)
  802bc8:	e8 97 f2 ff ff       	call   801e64 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  802bcd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802bd0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802bd3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802bd6:	89 ec                	mov    %ebp,%esp
  802bd8:	5d                   	pop    %ebp
  802bd9:	c3                   	ret    

00802bda <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  802bda:	55                   	push   %ebp
  802bdb:	89 e5                	mov    %esp,%ebp
  802bdd:	83 ec 28             	sub    $0x28,%esp
  802be0:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802be3:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802be6:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802be9:	8b 55 08             	mov    0x8(%ebp),%edx
  802bec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802bef:	b8 06 00 00 00       	mov    $0x6,%eax
  802bf4:	bf 00 00 00 00       	mov    $0x0,%edi
  802bf9:	89 fb                	mov    %edi,%ebx
  802bfb:	89 fe                	mov    %edi,%esi
  802bfd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  802bff:	85 c0                	test   %eax,%eax
  802c01:	7e 28                	jle    802c2b <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  802c03:	89 44 24 10          	mov    %eax,0x10(%esp)
  802c07:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  802c0e:	00 
  802c0f:	c7 44 24 08 1f 45 80 	movl   $0x80451f,0x8(%esp)
  802c16:	00 
  802c17:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802c1e:	00 
  802c1f:	c7 04 24 3c 45 80 00 	movl   $0x80453c,(%esp)
  802c26:	e8 39 f2 ff ff       	call   801e64 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  802c2b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802c2e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802c31:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802c34:	89 ec                	mov    %ebp,%esp
  802c36:	5d                   	pop    %ebp
  802c37:	c3                   	ret    

00802c38 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  802c38:	55                   	push   %ebp
  802c39:	89 e5                	mov    %esp,%ebp
  802c3b:	83 ec 28             	sub    $0x28,%esp
  802c3e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802c41:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802c44:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802c47:	8b 55 08             	mov    0x8(%ebp),%edx
  802c4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802c50:	8b 7d 14             	mov    0x14(%ebp),%edi
  802c53:	8b 75 18             	mov    0x18(%ebp),%esi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802c56:	b8 05 00 00 00       	mov    $0x5,%eax
  802c5b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  802c5d:	85 c0                	test   %eax,%eax
  802c5f:	7e 28                	jle    802c89 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  802c61:	89 44 24 10          	mov    %eax,0x10(%esp)
  802c65:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  802c6c:	00 
  802c6d:	c7 44 24 08 1f 45 80 	movl   $0x80451f,0x8(%esp)
  802c74:	00 
  802c75:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802c7c:	00 
  802c7d:	c7 04 24 3c 45 80 00 	movl   $0x80453c,(%esp)
  802c84:	e8 db f1 ff ff       	call   801e64 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802c89:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802c8c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802c8f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802c92:	89 ec                	mov    %ebp,%esp
  802c94:	5d                   	pop    %ebp
  802c95:	c3                   	ret    

00802c96 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802c96:	55                   	push   %ebp
  802c97:	89 e5                	mov    %esp,%ebp
  802c99:	83 ec 28             	sub    $0x28,%esp
  802c9c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802c9f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802ca2:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802ca5:	8b 55 08             	mov    0x8(%ebp),%edx
  802ca8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802cab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802cae:	b8 04 00 00 00       	mov    $0x4,%eax
  802cb3:	bf 00 00 00 00       	mov    $0x0,%edi
  802cb8:	89 fe                	mov    %edi,%esi
  802cba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  802cbc:	85 c0                	test   %eax,%eax
  802cbe:	7e 28                	jle    802ce8 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  802cc0:	89 44 24 10          	mov    %eax,0x10(%esp)
  802cc4:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  802ccb:	00 
  802ccc:	c7 44 24 08 1f 45 80 	movl   $0x80451f,0x8(%esp)
  802cd3:	00 
  802cd4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802cdb:	00 
  802cdc:	c7 04 24 3c 45 80 00 	movl   $0x80453c,(%esp)
  802ce3:	e8 7c f1 ff ff       	call   801e64 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  802ce8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802ceb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802cee:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802cf1:	89 ec                	mov    %ebp,%esp
  802cf3:	5d                   	pop    %ebp
  802cf4:	c3                   	ret    

00802cf5 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  802cf5:	55                   	push   %ebp
  802cf6:	89 e5                	mov    %esp,%ebp
  802cf8:	83 ec 0c             	sub    $0xc,%esp
  802cfb:	89 1c 24             	mov    %ebx,(%esp)
  802cfe:	89 74 24 04          	mov    %esi,0x4(%esp)
  802d02:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802d06:	b8 0b 00 00 00       	mov    $0xb,%eax
  802d0b:	bf 00 00 00 00       	mov    $0x0,%edi
  802d10:	89 fa                	mov    %edi,%edx
  802d12:	89 f9                	mov    %edi,%ecx
  802d14:	89 fb                	mov    %edi,%ebx
  802d16:	89 fe                	mov    %edi,%esi
  802d18:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  802d1a:	8b 1c 24             	mov    (%esp),%ebx
  802d1d:	8b 74 24 04          	mov    0x4(%esp),%esi
  802d21:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802d25:	89 ec                	mov    %ebp,%esp
  802d27:	5d                   	pop    %ebp
  802d28:	c3                   	ret    

00802d29 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  802d29:	55                   	push   %ebp
  802d2a:	89 e5                	mov    %esp,%ebp
  802d2c:	83 ec 0c             	sub    $0xc,%esp
  802d2f:	89 1c 24             	mov    %ebx,(%esp)
  802d32:	89 74 24 04          	mov    %esi,0x4(%esp)
  802d36:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802d3a:	b8 02 00 00 00       	mov    $0x2,%eax
  802d3f:	bf 00 00 00 00       	mov    $0x0,%edi
  802d44:	89 fa                	mov    %edi,%edx
  802d46:	89 f9                	mov    %edi,%ecx
  802d48:	89 fb                	mov    %edi,%ebx
  802d4a:	89 fe                	mov    %edi,%esi
  802d4c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  802d4e:	8b 1c 24             	mov    (%esp),%ebx
  802d51:	8b 74 24 04          	mov    0x4(%esp),%esi
  802d55:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802d59:	89 ec                	mov    %ebp,%esp
  802d5b:	5d                   	pop    %ebp
  802d5c:	c3                   	ret    

00802d5d <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  802d5d:	55                   	push   %ebp
  802d5e:	89 e5                	mov    %esp,%ebp
  802d60:	83 ec 28             	sub    $0x28,%esp
  802d63:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802d66:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802d69:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802d6c:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802d6f:	b8 03 00 00 00       	mov    $0x3,%eax
  802d74:	bf 00 00 00 00       	mov    $0x0,%edi
  802d79:	89 f9                	mov    %edi,%ecx
  802d7b:	89 fb                	mov    %edi,%ebx
  802d7d:	89 fe                	mov    %edi,%esi
  802d7f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  802d81:	85 c0                	test   %eax,%eax
  802d83:	7e 28                	jle    802dad <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  802d85:	89 44 24 10          	mov    %eax,0x10(%esp)
  802d89:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  802d90:	00 
  802d91:	c7 44 24 08 1f 45 80 	movl   $0x80451f,0x8(%esp)
  802d98:	00 
  802d99:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802da0:	00 
  802da1:	c7 04 24 3c 45 80 00 	movl   $0x80453c,(%esp)
  802da8:	e8 b7 f0 ff ff       	call   801e64 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  802dad:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802db0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802db3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802db6:	89 ec                	mov    %ebp,%esp
  802db8:	5d                   	pop    %ebp
  802db9:	c3                   	ret    
	...

00802dbc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802dbc:	55                   	push   %ebp
  802dbd:	89 e5                	mov    %esp,%ebp
  802dbf:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802dc2:	83 3d 94 b0 80 00 00 	cmpl   $0x0,0x80b094
  802dc9:	75 6a                	jne    802e35 <set_pgfault_handler+0x79>
		// First time through!
		// LAB 4: Your code here.
		env=(struct Env*)&envs[ENVX(sys_getenvid())];
  802dcb:	e8 59 ff ff ff       	call   802d29 <sys_getenvid>
  802dd0:	25 ff 03 00 00       	and    $0x3ff,%eax
  802dd5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802dd8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802ddd:	a3 8c b0 80 00       	mov    %eax,0x80b08c
		if((r=sys_page_alloc(env->env_id,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  802de2:	8b 40 4c             	mov    0x4c(%eax),%eax
  802de5:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802dec:	00 
  802ded:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802df4:	ee 
  802df5:	89 04 24             	mov    %eax,(%esp)
  802df8:	e8 99 fe ff ff       	call   802c96 <sys_page_alloc>
  802dfd:	85 c0                	test   %eax,%eax
  802dff:	79 1c                	jns    802e1d <set_pgfault_handler+0x61>
		{
			panic("Alloc a page for an exception stack failed");
  802e01:	c7 44 24 08 4c 45 80 	movl   $0x80454c,0x8(%esp)
  802e08:	00 
  802e09:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802e10:	00 
  802e11:	c7 04 24 77 45 80 00 	movl   $0x804577,(%esp)
  802e18:	e8 47 f0 ff ff       	call   801e64 <_panic>
		}
		sys_env_set_pgfault_upcall(env->env_id,(void*)_pgfault_upcall);
  802e1d:	a1 8c b0 80 00       	mov    0x80b08c,%eax
  802e22:	8b 40 4c             	mov    0x4c(%eax),%eax
  802e25:	c7 44 24 04 40 2e 80 	movl   $0x802e40,0x4(%esp)
  802e2c:	00 
  802e2d:	89 04 24             	mov    %eax,(%esp)
  802e30:	e8 8b fc ff ff       	call   802ac0 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802e35:	8b 45 08             	mov    0x8(%ebp),%eax
  802e38:	a3 94 b0 80 00       	mov    %eax,0x80b094
}
  802e3d:	c9                   	leave  
  802e3e:	c3                   	ret    
	...

00802e40 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802e40:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802e41:	a1 94 b0 80 00       	mov    0x80b094,%eax
	call *%eax
  802e46:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802e48:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.这个有点难度，需要认真编写
	movl  0x28(%esp),%eax //把utf->utf_eip入栈
  802e4b:	8b 44 24 28          	mov    0x28(%esp),%eax
	pushl %eax
  802e4f:	50                   	push   %eax
	movl %esp,%eax
  802e50:	89 e0                	mov    %esp,%eax
	movl 0x34(%eax),%esp  //切换到用户普通栈，压入utf_eip
  802e52:	8b 60 34             	mov    0x34(%eax),%esp
	pushl (%eax)
  802e55:	ff 30                	pushl  (%eax)
	movl %eax,%esp	     //切到用户异常栈
  802e57:	89 c4                	mov    %eax,%esp
	subl $0x4,0x34(%esp) //将utf->utf_esp减去4,指向返回地址,后面不能算术操作，就在这算
  802e59:	83 6c 24 34 04       	subl   $0x4,0x34(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0xc,%esp     //恢复通用寄存器
  802e5e:	83 c4 0c             	add    $0xc,%esp
	popal
  802e61:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp  //恢复eflags
  802e62:	83 c4 04             	add    $0x4,%esp
	popfl          //在用户态，该指令能否修改eflags?可以的
  802e65:	9d                   	popf   
		       //执行完这个指令后，不能进行算术任何算术运算哦，否则eflags里面的值不对
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp     //切换到用户普通栈，用户从异常处理退出后，需要继续使用该栈
  802e66:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802e67:	c3                   	ret    
	...

00802e70 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802e70:	55                   	push   %ebp
  802e71:	89 e5                	mov    %esp,%ebp
  802e73:	57                   	push   %edi
  802e74:	56                   	push   %esi
  802e75:	53                   	push   %ebx
  802e76:	83 ec 1c             	sub    $0x1c,%esp
  802e79:	8b 75 08             	mov    0x8(%ebp),%esi
  802e7c:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  802e7f:	e8 a5 fe ff ff       	call   802d29 <sys_getenvid>
  802e84:	25 ff 03 00 00       	and    $0x3ff,%eax
  802e89:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802e8c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802e91:	a3 8c b0 80 00       	mov    %eax,0x80b08c
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  802e96:	e8 8e fe ff ff       	call   802d29 <sys_getenvid>
  802e9b:	25 ff 03 00 00       	and    $0x3ff,%eax
  802ea0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802ea3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802ea8:	a3 8c b0 80 00       	mov    %eax,0x80b08c
		if(env->env_id==to_env){
  802ead:	8b 40 4c             	mov    0x4c(%eax),%eax
  802eb0:	39 f0                	cmp    %esi,%eax
  802eb2:	75 0e                	jne    802ec2 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  802eb4:	c7 04 24 85 45 80 00 	movl   $0x804585,(%esp)
  802ebb:	e8 71 f0 ff ff       	call   801f31 <cprintf>
  802ec0:	eb 5a                	jmp    802f1c <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  802ec2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802ec6:	8b 45 10             	mov    0x10(%ebp),%eax
  802ec9:	89 44 24 08          	mov    %eax,0x8(%esp)
  802ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ed0:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ed4:	89 34 24             	mov    %esi,(%esp)
  802ed7:	e8 ac fb ff ff       	call   802a88 <sys_ipc_try_send>
  802edc:	89 c3                	mov    %eax,%ebx
  802ede:	85 c0                	test   %eax,%eax
  802ee0:	79 25                	jns    802f07 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  802ee2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802ee5:	74 2b                	je     802f12 <ipc_send+0xa2>
				panic("send error:%e",r);
  802ee7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802eeb:	c7 44 24 08 a1 45 80 	movl   $0x8045a1,0x8(%esp)
  802ef2:	00 
  802ef3:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  802efa:	00 
  802efb:	c7 04 24 af 45 80 00 	movl   $0x8045af,(%esp)
  802f02:	e8 5d ef ff ff       	call   801e64 <_panic>
		}
			sys_yield();
  802f07:	e8 e9 fd ff ff       	call   802cf5 <sys_yield>
		
	}while(r!=0);
  802f0c:	85 db                	test   %ebx,%ebx
  802f0e:	75 86                	jne    802e96 <ipc_send+0x26>
  802f10:	eb 0a                	jmp    802f1c <ipc_send+0xac>
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
		{	
			if(r!=-E_IPC_NOT_RECV)
				panic("send error:%e",r);
		}
			sys_yield();
  802f12:	e8 de fd ff ff       	call   802cf5 <sys_yield>
  802f17:	e9 7a ff ff ff       	jmp    802e96 <ipc_send+0x26>
		
	}while(r!=0);
	return;
	//panic("ipc_send not implemented");
}
  802f1c:	83 c4 1c             	add    $0x1c,%esp
  802f1f:	5b                   	pop    %ebx
  802f20:	5e                   	pop    %esi
  802f21:	5f                   	pop    %edi
  802f22:	5d                   	pop    %ebp
  802f23:	c3                   	ret    

00802f24 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802f24:	55                   	push   %ebp
  802f25:	89 e5                	mov    %esp,%ebp
  802f27:	57                   	push   %edi
  802f28:	56                   	push   %esi
  802f29:	53                   	push   %ebx
  802f2a:	83 ec 0c             	sub    $0xc,%esp
  802f2d:	8b 75 08             	mov    0x8(%ebp),%esi
  802f30:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	void *dstva=NULL;
	if(pg)
		dstva=pg;
	env = &envs[ENVX(sys_getenvid())];
  802f33:	e8 f1 fd ff ff       	call   802d29 <sys_getenvid>
  802f38:	25 ff 03 00 00       	and    $0x3ff,%eax
  802f3d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802f40:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802f45:	a3 8c b0 80 00       	mov    %eax,0x80b08c
	if(from_env_store&&(env->env_id==*from_env_store))
  802f4a:	85 f6                	test   %esi,%esi
  802f4c:	74 29                	je     802f77 <ipc_recv+0x53>
  802f4e:	8b 40 4c             	mov    0x4c(%eax),%eax
  802f51:	3b 06                	cmp    (%esi),%eax
  802f53:	75 22                	jne    802f77 <ipc_recv+0x53>
	{
		*from_env_store=0;
  802f55:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  802f5b:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("send:the reciver is sender\n");
  802f61:	c7 04 24 85 45 80 00 	movl   $0x804585,(%esp)
  802f68:	e8 c4 ef ff ff       	call   801f31 <cprintf>
  802f6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802f72:	e9 8a 00 00 00       	jmp    803001 <ipc_recv+0xdd>
		return 0;
	}
	env = &envs[ENVX(sys_getenvid())];
  802f77:	e8 ad fd ff ff       	call   802d29 <sys_getenvid>
  802f7c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802f81:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802f84:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802f89:	a3 8c b0 80 00       	mov    %eax,0x80b08c
	if((r=sys_ipc_recv(dstva))<0)
  802f8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f91:	89 04 24             	mov    %eax,(%esp)
  802f94:	e8 92 fa ff ff       	call   802a2b <sys_ipc_recv>
  802f99:	89 c3                	mov    %eax,%ebx
  802f9b:	85 c0                	test   %eax,%eax
  802f9d:	79 1a                	jns    802fb9 <ipc_recv+0x95>
	{
		*from_env_store=0;
  802f9f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  802fa5:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("reciver failed\n");
  802fab:	c7 04 24 b9 45 80 00 	movl   $0x8045b9,(%esp)
  802fb2:	e8 7a ef ff ff       	call   801f31 <cprintf>
  802fb7:	eb 48                	jmp    803001 <ipc_recv+0xdd>
		return r;
	}
	else{//接收成功
		env = &envs[ENVX(sys_getenvid())];
  802fb9:	e8 6b fd ff ff       	call   802d29 <sys_getenvid>
  802fbe:	25 ff 03 00 00       	and    $0x3ff,%eax
  802fc3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802fc6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802fcb:	a3 8c b0 80 00       	mov    %eax,0x80b08c
		if(from_env_store)
  802fd0:	85 f6                	test   %esi,%esi
  802fd2:	74 05                	je     802fd9 <ipc_recv+0xb5>
			*from_env_store=env->env_ipc_from;	
  802fd4:	8b 40 74             	mov    0x74(%eax),%eax
  802fd7:	89 06                	mov    %eax,(%esi)
		if(perm_store)
  802fd9:	85 ff                	test   %edi,%edi
  802fdb:	74 0a                	je     802fe7 <ipc_recv+0xc3>
			*perm_store=env->env_ipc_perm;
  802fdd:	a1 8c b0 80 00       	mov    0x80b08c,%eax
  802fe2:	8b 40 78             	mov    0x78(%eax),%eax
  802fe5:	89 07                	mov    %eax,(%edi)
		env = &envs[ENVX(sys_getenvid())];
  802fe7:	e8 3d fd ff ff       	call   802d29 <sys_getenvid>
  802fec:	25 ff 03 00 00       	and    $0x3ff,%eax
  802ff1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802ff4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802ff9:	a3 8c b0 80 00       	mov    %eax,0x80b08c
		return env->env_ipc_value;
  802ffe:	8b 58 70             	mov    0x70(%eax),%ebx
	}
	//panic("ipc_recv not implemented");
	return 0;
}
  803001:	89 d8                	mov    %ebx,%eax
  803003:	83 c4 0c             	add    $0xc,%esp
  803006:	5b                   	pop    %ebx
  803007:	5e                   	pop    %esi
  803008:	5f                   	pop    %edi
  803009:	5d                   	pop    %ebp
  80300a:	c3                   	ret    
  80300b:	00 00                	add    %al,(%eax)
  80300d:	00 00                	add    %al,(%eax)
	...

00803010 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  803010:	55                   	push   %ebp
  803011:	89 e5                	mov    %esp,%ebp
  803013:	8b 45 08             	mov    0x8(%ebp),%eax
  803016:	05 00 00 00 30       	add    $0x30000000,%eax
  80301b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80301e:	5d                   	pop    %ebp
  80301f:	c3                   	ret    

00803020 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  803020:	55                   	push   %ebp
  803021:	89 e5                	mov    %esp,%ebp
  803023:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  803026:	8b 45 08             	mov    0x8(%ebp),%eax
  803029:	89 04 24             	mov    %eax,(%esp)
  80302c:	e8 df ff ff ff       	call   803010 <fd2num>
  803031:	c1 e0 0c             	shl    $0xc,%eax
  803034:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  803039:	c9                   	leave  
  80303a:	c3                   	ret    

0080303b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80303b:	55                   	push   %ebp
  80303c:	89 e5                	mov    %esp,%ebp
  80303e:	53                   	push   %ebx
  80303f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  803042:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  803047:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  803049:	89 d0                	mov    %edx,%eax
  80304b:	c1 e8 16             	shr    $0x16,%eax
  80304e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  803055:	a8 01                	test   $0x1,%al
  803057:	74 10                	je     803069 <fd_alloc+0x2e>
  803059:	89 d0                	mov    %edx,%eax
  80305b:	c1 e8 0c             	shr    $0xc,%eax
  80305e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  803065:	a8 01                	test   $0x1,%al
  803067:	75 09                	jne    803072 <fd_alloc+0x37>
			*fd_store = fd;
  803069:	89 0b                	mov    %ecx,(%ebx)
  80306b:	b8 00 00 00 00       	mov    $0x0,%eax
  803070:	eb 19                	jmp    80308b <fd_alloc+0x50>
			return 0;
  803072:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  803078:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  80307e:	75 c7                	jne    803047 <fd_alloc+0xc>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  803080:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  803086:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  80308b:	5b                   	pop    %ebx
  80308c:	5d                   	pop    %ebp
  80308d:	c3                   	ret    

0080308e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80308e:	55                   	push   %ebp
  80308f:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  803091:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  803095:	77 38                	ja     8030cf <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  803097:	8b 45 08             	mov    0x8(%ebp),%eax
  80309a:	c1 e0 0c             	shl    $0xc,%eax
  80309d:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  8030a3:	89 d0                	mov    %edx,%eax
  8030a5:	c1 e8 16             	shr    $0x16,%eax
  8030a8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8030af:	a8 01                	test   $0x1,%al
  8030b1:	74 1c                	je     8030cf <fd_lookup+0x41>
  8030b3:	89 d0                	mov    %edx,%eax
  8030b5:	c1 e8 0c             	shr    $0xc,%eax
  8030b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8030bf:	a8 01                	test   $0x1,%al
  8030c1:	74 0c                	je     8030cf <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8030c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8030c6:	89 10                	mov    %edx,(%eax)
  8030c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8030cd:	eb 05                	jmp    8030d4 <fd_lookup+0x46>
	return 0;
  8030cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8030d4:	5d                   	pop    %ebp
  8030d5:	c3                   	ret    

008030d6 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8030d6:	55                   	push   %ebp
  8030d7:	89 e5                	mov    %esp,%ebp
  8030d9:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8030dc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8030df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8030e6:	89 04 24             	mov    %eax,(%esp)
  8030e9:	e8 a0 ff ff ff       	call   80308e <fd_lookup>
  8030ee:	85 c0                	test   %eax,%eax
  8030f0:	78 0e                	js     803100 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8030f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8030f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8030f8:	89 50 04             	mov    %edx,0x4(%eax)
  8030fb:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  803100:	c9                   	leave  
  803101:	c3                   	ret    

00803102 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  803102:	55                   	push   %ebp
  803103:	89 e5                	mov    %esp,%ebp
  803105:	53                   	push   %ebx
  803106:	83 ec 14             	sub    $0x14,%esp
  803109:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80310c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80310f:	ba 68 b0 80 00       	mov    $0x80b068,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  803114:	b8 00 00 00 00       	mov    $0x0,%eax
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  803119:	39 0d 68 b0 80 00    	cmp    %ecx,0x80b068
  80311f:	75 11                	jne    803132 <dev_lookup+0x30>
  803121:	eb 04                	jmp    803127 <dev_lookup+0x25>
  803123:	39 0a                	cmp    %ecx,(%edx)
  803125:	75 0b                	jne    803132 <dev_lookup+0x30>
			*dev = devtab[i];
  803127:	89 13                	mov    %edx,(%ebx)
  803129:	b8 00 00 00 00       	mov    $0x0,%eax
  80312e:	66 90                	xchg   %ax,%ax
  803130:	eb 35                	jmp    803167 <dev_lookup+0x65>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  803132:	83 c0 01             	add    $0x1,%eax
  803135:	8b 14 85 4c 46 80 00 	mov    0x80464c(,%eax,4),%edx
  80313c:	85 d2                	test   %edx,%edx
  80313e:	75 e3                	jne    803123 <dev_lookup+0x21>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  803140:	a1 8c b0 80 00       	mov    0x80b08c,%eax
  803145:	8b 40 4c             	mov    0x4c(%eax),%eax
  803148:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80314c:	89 44 24 04          	mov    %eax,0x4(%esp)
  803150:	c7 04 24 cc 45 80 00 	movl   $0x8045cc,(%esp)
  803157:	e8 d5 ed ff ff       	call   801f31 <cprintf>
	*dev = 0;
  80315c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  803162:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  803167:	83 c4 14             	add    $0x14,%esp
  80316a:	5b                   	pop    %ebx
  80316b:	5d                   	pop    %ebp
  80316c:	c3                   	ret    

0080316d <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80316d:	55                   	push   %ebp
  80316e:	89 e5                	mov    %esp,%ebp
  803170:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  803173:	8d 45 f8             	lea    -0x8(%ebp),%eax
  803176:	89 44 24 04          	mov    %eax,0x4(%esp)
  80317a:	8b 45 08             	mov    0x8(%ebp),%eax
  80317d:	89 04 24             	mov    %eax,(%esp)
  803180:	e8 09 ff ff ff       	call   80308e <fd_lookup>
  803185:	89 c2                	mov    %eax,%edx
  803187:	85 c0                	test   %eax,%eax
  803189:	78 5a                	js     8031e5 <fstat+0x78>
  80318b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80318e:	89 44 24 04          	mov    %eax,0x4(%esp)
  803192:	8b 45 f8             	mov    -0x8(%ebp),%eax
  803195:	8b 00                	mov    (%eax),%eax
  803197:	89 04 24             	mov    %eax,(%esp)
  80319a:	e8 63 ff ff ff       	call   803102 <dev_lookup>
  80319f:	89 c2                	mov    %eax,%edx
  8031a1:	85 c0                	test   %eax,%eax
  8031a3:	78 40                	js     8031e5 <fstat+0x78>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8031a5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  8031aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8031ad:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8031b1:	74 32                	je     8031e5 <fstat+0x78>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8031b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8031b6:	c6 00 00             	movb   $0x0,(%eax)
	stat->st_size = 0;
  8031b9:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  8031c0:	00 00 00 
	stat->st_isdir = 0;
  8031c3:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
  8031ca:	00 00 00 
	stat->st_dev = dev;
  8031cd:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8031d0:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
	return (*dev->dev_stat)(fd, stat);
  8031d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031da:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8031dd:	89 04 24             	mov    %eax,(%esp)
  8031e0:	ff 52 14             	call   *0x14(%edx)
  8031e3:	89 c2                	mov    %eax,%edx
}
  8031e5:	89 d0                	mov    %edx,%eax
  8031e7:	c9                   	leave  
  8031e8:	c3                   	ret    

008031e9 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8031e9:	55                   	push   %ebp
  8031ea:	89 e5                	mov    %esp,%ebp
  8031ec:	53                   	push   %ebx
  8031ed:	83 ec 24             	sub    $0x24,%esp
  8031f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8031f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8031f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031fa:	89 1c 24             	mov    %ebx,(%esp)
  8031fd:	e8 8c fe ff ff       	call   80308e <fd_lookup>
  803202:	85 c0                	test   %eax,%eax
  803204:	78 61                	js     803267 <ftruncate+0x7e>
  803206:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803209:	8b 10                	mov    (%eax),%edx
  80320b:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80320e:	89 44 24 04          	mov    %eax,0x4(%esp)
  803212:	89 14 24             	mov    %edx,(%esp)
  803215:	e8 e8 fe ff ff       	call   803102 <dev_lookup>
  80321a:	85 c0                	test   %eax,%eax
  80321c:	78 49                	js     803267 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80321e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  803221:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  803225:	75 23                	jne    80324a <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  803227:	a1 8c b0 80 00       	mov    0x80b08c,%eax
  80322c:	8b 40 4c             	mov    0x4c(%eax),%eax
  80322f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803233:	89 44 24 04          	mov    %eax,0x4(%esp)
  803237:	c7 04 24 ec 45 80 00 	movl   $0x8045ec,(%esp)
  80323e:	e8 ee ec ff ff       	call   801f31 <cprintf>
  803243:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  803248:	eb 1d                	jmp    803267 <ftruncate+0x7e>
			env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80324a:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80324d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  803252:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  803256:	74 0f                	je     803267 <ftruncate+0x7e>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  803258:	8b 42 18             	mov    0x18(%edx),%eax
  80325b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80325e:	89 54 24 04          	mov    %edx,0x4(%esp)
  803262:	89 0c 24             	mov    %ecx,(%esp)
  803265:	ff d0                	call   *%eax
}
  803267:	83 c4 24             	add    $0x24,%esp
  80326a:	5b                   	pop    %ebx
  80326b:	5d                   	pop    %ebp
  80326c:	c3                   	ret    

0080326d <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80326d:	55                   	push   %ebp
  80326e:	89 e5                	mov    %esp,%ebp
  803270:	53                   	push   %ebx
  803271:	83 ec 24             	sub    $0x24,%esp
  803274:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  803277:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80327a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80327e:	89 1c 24             	mov    %ebx,(%esp)
  803281:	e8 08 fe ff ff       	call   80308e <fd_lookup>
  803286:	85 c0                	test   %eax,%eax
  803288:	78 68                	js     8032f2 <write+0x85>
  80328a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80328d:	8b 10                	mov    (%eax),%edx
  80328f:	8d 45 f8             	lea    -0x8(%ebp),%eax
  803292:	89 44 24 04          	mov    %eax,0x4(%esp)
  803296:	89 14 24             	mov    %edx,(%esp)
  803299:	e8 64 fe ff ff       	call   803102 <dev_lookup>
  80329e:	85 c0                	test   %eax,%eax
  8032a0:	78 50                	js     8032f2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8032a2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  8032a5:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  8032a9:	75 23                	jne    8032ce <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  8032ab:	a1 8c b0 80 00       	mov    0x80b08c,%eax
  8032b0:	8b 40 4c             	mov    0x4c(%eax),%eax
  8032b3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8032b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8032bb:	c7 04 24 10 46 80 00 	movl   $0x804610,(%esp)
  8032c2:	e8 6a ec ff ff       	call   801f31 <cprintf>
  8032c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8032cc:	eb 24                	jmp    8032f2 <write+0x85>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8032ce:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8032d1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8032d6:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  8032da:	74 16                	je     8032f2 <write+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8032dc:	8b 42 0c             	mov    0xc(%edx),%eax
  8032df:	8b 55 10             	mov    0x10(%ebp),%edx
  8032e2:	89 54 24 08          	mov    %edx,0x8(%esp)
  8032e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8032e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8032ed:	89 0c 24             	mov    %ecx,(%esp)
  8032f0:	ff d0                	call   *%eax
}
  8032f2:	83 c4 24             	add    $0x24,%esp
  8032f5:	5b                   	pop    %ebx
  8032f6:	5d                   	pop    %ebp
  8032f7:	c3                   	ret    

008032f8 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8032f8:	55                   	push   %ebp
  8032f9:	89 e5                	mov    %esp,%ebp
  8032fb:	53                   	push   %ebx
  8032fc:	83 ec 24             	sub    $0x24,%esp
  8032ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  803302:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803305:	89 44 24 04          	mov    %eax,0x4(%esp)
  803309:	89 1c 24             	mov    %ebx,(%esp)
  80330c:	e8 7d fd ff ff       	call   80308e <fd_lookup>
  803311:	85 c0                	test   %eax,%eax
  803313:	78 6d                	js     803382 <read+0x8a>
  803315:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803318:	8b 10                	mov    (%eax),%edx
  80331a:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80331d:	89 44 24 04          	mov    %eax,0x4(%esp)
  803321:	89 14 24             	mov    %edx,(%esp)
  803324:	e8 d9 fd ff ff       	call   803102 <dev_lookup>
  803329:	85 c0                	test   %eax,%eax
  80332b:	78 55                	js     803382 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80332d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  803330:	8b 41 08             	mov    0x8(%ecx),%eax
  803333:	83 e0 03             	and    $0x3,%eax
  803336:	83 f8 01             	cmp    $0x1,%eax
  803339:	75 23                	jne    80335e <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  80333b:	a1 8c b0 80 00       	mov    0x80b08c,%eax
  803340:	8b 40 4c             	mov    0x4c(%eax),%eax
  803343:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803347:	89 44 24 04          	mov    %eax,0x4(%esp)
  80334b:	c7 04 24 2d 46 80 00 	movl   $0x80462d,(%esp)
  803352:	e8 da eb ff ff       	call   801f31 <cprintf>
  803357:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80335c:	eb 24                	jmp    803382 <read+0x8a>
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80335e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  803361:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  803366:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  80336a:	74 16                	je     803382 <read+0x8a>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80336c:	8b 42 08             	mov    0x8(%edx),%eax
  80336f:	8b 55 10             	mov    0x10(%ebp),%edx
  803372:	89 54 24 08          	mov    %edx,0x8(%esp)
  803376:	8b 55 0c             	mov    0xc(%ebp),%edx
  803379:	89 54 24 04          	mov    %edx,0x4(%esp)
  80337d:	89 0c 24             	mov    %ecx,(%esp)
  803380:	ff d0                	call   *%eax
}
  803382:	83 c4 24             	add    $0x24,%esp
  803385:	5b                   	pop    %ebx
  803386:	5d                   	pop    %ebp
  803387:	c3                   	ret    

00803388 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  803388:	55                   	push   %ebp
  803389:	89 e5                	mov    %esp,%ebp
  80338b:	57                   	push   %edi
  80338c:	56                   	push   %esi
  80338d:	53                   	push   %ebx
  80338e:	83 ec 0c             	sub    $0xc,%esp
  803391:	8b 7d 0c             	mov    0xc(%ebp),%edi
  803394:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  803397:	b8 00 00 00 00       	mov    $0x0,%eax
  80339c:	85 f6                	test   %esi,%esi
  80339e:	74 36                	je     8033d6 <readn+0x4e>
  8033a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8033a5:	ba 00 00 00 00       	mov    $0x0,%edx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8033aa:	89 f0                	mov    %esi,%eax
  8033ac:	29 d0                	sub    %edx,%eax
  8033ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8033b2:	8d 04 17             	lea    (%edi,%edx,1),%eax
  8033b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8033b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8033bc:	89 04 24             	mov    %eax,(%esp)
  8033bf:	e8 34 ff ff ff       	call   8032f8 <read>
		if (m < 0)
  8033c4:	85 c0                	test   %eax,%eax
  8033c6:	78 0e                	js     8033d6 <readn+0x4e>
			return m;
		if (m == 0)
  8033c8:	85 c0                	test   %eax,%eax
  8033ca:	74 08                	je     8033d4 <readn+0x4c>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8033cc:	01 c3                	add    %eax,%ebx
  8033ce:	89 da                	mov    %ebx,%edx
  8033d0:	39 f3                	cmp    %esi,%ebx
  8033d2:	72 d6                	jb     8033aa <readn+0x22>
  8033d4:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8033d6:	83 c4 0c             	add    $0xc,%esp
  8033d9:	5b                   	pop    %ebx
  8033da:	5e                   	pop    %esi
  8033db:	5f                   	pop    %edi
  8033dc:	5d                   	pop    %ebp
  8033dd:	c3                   	ret    

008033de <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8033de:	55                   	push   %ebp
  8033df:	89 e5                	mov    %esp,%ebp
  8033e1:	83 ec 28             	sub    $0x28,%esp
  8033e4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8033e7:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8033ea:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8033ed:	89 34 24             	mov    %esi,(%esp)
  8033f0:	e8 1b fc ff ff       	call   803010 <fd2num>
  8033f5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8033f8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8033fc:	89 04 24             	mov    %eax,(%esp)
  8033ff:	e8 8a fc ff ff       	call   80308e <fd_lookup>
  803404:	89 c3                	mov    %eax,%ebx
  803406:	85 c0                	test   %eax,%eax
  803408:	78 05                	js     80340f <fd_close+0x31>
  80340a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80340d:	74 0d                	je     80341c <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80340f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  803413:	75 44                	jne    803459 <fd_close+0x7b>
  803415:	bb 00 00 00 00       	mov    $0x0,%ebx
  80341a:	eb 3d                	jmp    803459 <fd_close+0x7b>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80341c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80341f:	89 44 24 04          	mov    %eax,0x4(%esp)
  803423:	8b 06                	mov    (%esi),%eax
  803425:	89 04 24             	mov    %eax,(%esp)
  803428:	e8 d5 fc ff ff       	call   803102 <dev_lookup>
  80342d:	89 c3                	mov    %eax,%ebx
  80342f:	85 c0                	test   %eax,%eax
  803431:	78 16                	js     803449 <fd_close+0x6b>
		if (dev->dev_close)
  803433:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803436:	8b 40 10             	mov    0x10(%eax),%eax
  803439:	bb 00 00 00 00       	mov    $0x0,%ebx
  80343e:	85 c0                	test   %eax,%eax
  803440:	74 07                	je     803449 <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  803442:	89 34 24             	mov    %esi,(%esp)
  803445:	ff d0                	call   *%eax
  803447:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  803449:	89 74 24 04          	mov    %esi,0x4(%esp)
  80344d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803454:	e8 81 f7 ff ff       	call   802bda <sys_page_unmap>
	return r;
}
  803459:	89 d8                	mov    %ebx,%eax
  80345b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80345e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  803461:	89 ec                	mov    %ebp,%esp
  803463:	5d                   	pop    %ebp
  803464:	c3                   	ret    

00803465 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  803465:	55                   	push   %ebp
  803466:	89 e5                	mov    %esp,%ebp
  803468:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80346b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80346e:	89 44 24 04          	mov    %eax,0x4(%esp)
  803472:	8b 45 08             	mov    0x8(%ebp),%eax
  803475:	89 04 24             	mov    %eax,(%esp)
  803478:	e8 11 fc ff ff       	call   80308e <fd_lookup>
  80347d:	85 c0                	test   %eax,%eax
  80347f:	78 13                	js     803494 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  803481:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  803488:	00 
  803489:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80348c:	89 04 24             	mov    %eax,(%esp)
  80348f:	e8 4a ff ff ff       	call   8033de <fd_close>
}
  803494:	c9                   	leave  
  803495:	c3                   	ret    

00803496 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  803496:	55                   	push   %ebp
  803497:	89 e5                	mov    %esp,%ebp
  803499:	83 ec 18             	sub    $0x18,%esp
  80349c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80349f:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8034a2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8034a9:	00 
  8034aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8034ad:	89 04 24             	mov    %eax,(%esp)
  8034b0:	e8 6a 03 00 00       	call   80381f <open>
  8034b5:	89 c6                	mov    %eax,%esi
  8034b7:	85 c0                	test   %eax,%eax
  8034b9:	78 1b                	js     8034d6 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8034bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8034be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8034c2:	89 34 24             	mov    %esi,(%esp)
  8034c5:	e8 a3 fc ff ff       	call   80316d <fstat>
  8034ca:	89 c3                	mov    %eax,%ebx
	close(fd);
  8034cc:	89 34 24             	mov    %esi,(%esp)
  8034cf:	e8 91 ff ff ff       	call   803465 <close>
  8034d4:	89 de                	mov    %ebx,%esi
	return r;
}
  8034d6:	89 f0                	mov    %esi,%eax
  8034d8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8034db:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8034de:	89 ec                	mov    %ebp,%esp
  8034e0:	5d                   	pop    %ebp
  8034e1:	c3                   	ret    

008034e2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8034e2:	55                   	push   %ebp
  8034e3:	89 e5                	mov    %esp,%ebp
  8034e5:	83 ec 38             	sub    $0x38,%esp
  8034e8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8034eb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8034ee:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8034f1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8034f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8034f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8034fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8034fe:	89 04 24             	mov    %eax,(%esp)
  803501:	e8 88 fb ff ff       	call   80308e <fd_lookup>
  803506:	89 c3                	mov    %eax,%ebx
  803508:	85 c0                	test   %eax,%eax
  80350a:	0f 88 e1 00 00 00    	js     8035f1 <dup+0x10f>
		return r;
	close(newfdnum);
  803510:	89 3c 24             	mov    %edi,(%esp)
  803513:	e8 4d ff ff ff       	call   803465 <close>

	newfd = INDEX2FD(newfdnum);
  803518:	89 f8                	mov    %edi,%eax
  80351a:	c1 e0 0c             	shl    $0xc,%eax
  80351d:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  803523:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803526:	89 04 24             	mov    %eax,(%esp)
  803529:	e8 f2 fa ff ff       	call   803020 <fd2data>
  80352e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  803530:	89 34 24             	mov    %esi,(%esp)
  803533:	e8 e8 fa ff ff       	call   803020 <fd2data>
  803538:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  80353b:	89 d8                	mov    %ebx,%eax
  80353d:	c1 e8 16             	shr    $0x16,%eax
  803540:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  803547:	a8 01                	test   $0x1,%al
  803549:	74 45                	je     803590 <dup+0xae>
  80354b:	89 da                	mov    %ebx,%edx
  80354d:	c1 ea 0c             	shr    $0xc,%edx
  803550:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  803557:	a8 01                	test   $0x1,%al
  803559:	74 35                	je     803590 <dup+0xae>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  80355b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  803562:	25 07 0e 00 00       	and    $0xe07,%eax
  803567:	89 44 24 10          	mov    %eax,0x10(%esp)
  80356b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80356e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803572:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803579:	00 
  80357a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80357e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803585:	e8 ae f6 ff ff       	call   802c38 <sys_page_map>
  80358a:	89 c3                	mov    %eax,%ebx
  80358c:	85 c0                	test   %eax,%eax
  80358e:	78 3e                	js     8035ce <dup+0xec>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  803590:	8b 55 f0             	mov    -0x10(%ebp),%edx
  803593:	89 d0                	mov    %edx,%eax
  803595:	c1 e8 0c             	shr    $0xc,%eax
  803598:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80359f:	25 07 0e 00 00       	and    $0xe07,%eax
  8035a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8035a8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8035ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8035b3:	00 
  8035b4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8035b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8035bf:	e8 74 f6 ff ff       	call   802c38 <sys_page_map>
  8035c4:	89 c3                	mov    %eax,%ebx
  8035c6:	85 c0                	test   %eax,%eax
  8035c8:	78 04                	js     8035ce <dup+0xec>
		goto err;
  8035ca:	89 fb                	mov    %edi,%ebx
  8035cc:	eb 23                	jmp    8035f1 <dup+0x10f>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8035ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8035d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8035d9:	e8 fc f5 ff ff       	call   802bda <sys_page_unmap>
	sys_page_unmap(0, nva);
  8035de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8035e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8035e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8035ec:	e8 e9 f5 ff ff       	call   802bda <sys_page_unmap>
	return r;
}
  8035f1:	89 d8                	mov    %ebx,%eax
  8035f3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8035f6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8035f9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8035fc:	89 ec                	mov    %ebp,%esp
  8035fe:	5d                   	pop    %ebp
  8035ff:	c3                   	ret    

00803600 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  803600:	55                   	push   %ebp
  803601:	89 e5                	mov    %esp,%ebp
  803603:	53                   	push   %ebx
  803604:	83 ec 04             	sub    $0x4,%esp
  803607:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  80360c:	89 1c 24             	mov    %ebx,(%esp)
  80360f:	e8 51 fe ff ff       	call   803465 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  803614:	83 c3 01             	add    $0x1,%ebx
  803617:	83 fb 20             	cmp    $0x20,%ebx
  80361a:	75 f0                	jne    80360c <close_all+0xc>
		close(i);
}
  80361c:	83 c4 04             	add    $0x4,%esp
  80361f:	5b                   	pop    %ebx
  803620:	5d                   	pop    %ebp
  803621:	c3                   	ret    
	...

00803624 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  803624:	55                   	push   %ebp
  803625:	89 e5                	mov    %esp,%ebp
  803627:	53                   	push   %ebx
  803628:	83 ec 14             	sub    $0x14,%esp
  80362b:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80362d:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  803633:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80363a:	00 
  80363b:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  803642:	00 
  803643:	89 44 24 04          	mov    %eax,0x4(%esp)
  803647:	89 14 24             	mov    %edx,(%esp)
  80364a:	e8 21 f8 ff ff       	call   802e70 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80364f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803656:	00 
  803657:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80365b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803662:	e8 bd f8 ff ff       	call   802f24 <ipc_recv>
}
  803667:	83 c4 14             	add    $0x14,%esp
  80366a:	5b                   	pop    %ebx
  80366b:	5d                   	pop    %ebp
  80366c:	c3                   	ret    

0080366d <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  80366d:	55                   	push   %ebp
  80366e:	89 e5                	mov    %esp,%ebp
  803670:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  803673:	ba 00 00 00 00       	mov    $0x0,%edx
  803678:	b8 08 00 00 00       	mov    $0x8,%eax
  80367d:	e8 a2 ff ff ff       	call   803624 <fsipc>
}
  803682:	c9                   	leave  
  803683:	c3                   	ret    

00803684 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  803684:	55                   	push   %ebp
  803685:	89 e5                	mov    %esp,%ebp
  803687:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80368a:	8b 45 08             	mov    0x8(%ebp),%eax
  80368d:	8b 40 0c             	mov    0xc(%eax),%eax
  803690:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  803695:	8b 45 0c             	mov    0xc(%ebp),%eax
  803698:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80369d:	ba 00 00 00 00       	mov    $0x0,%edx
  8036a2:	b8 02 00 00 00       	mov    $0x2,%eax
  8036a7:	e8 78 ff ff ff       	call   803624 <fsipc>
}
  8036ac:	c9                   	leave  
  8036ad:	c3                   	ret    

008036ae <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8036ae:	55                   	push   %ebp
  8036af:	89 e5                	mov    %esp,%ebp
  8036b1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8036b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8036b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8036ba:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8036bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8036c4:	b8 06 00 00 00       	mov    $0x6,%eax
  8036c9:	e8 56 ff ff ff       	call   803624 <fsipc>
}
  8036ce:	c9                   	leave  
  8036cf:	c3                   	ret    

008036d0 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8036d0:	55                   	push   %ebp
  8036d1:	89 e5                	mov    %esp,%ebp
  8036d3:	53                   	push   %ebx
  8036d4:	83 ec 14             	sub    $0x14,%esp
  8036d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8036da:	8b 45 08             	mov    0x8(%ebp),%eax
  8036dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8036e0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8036e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8036ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8036ef:	e8 30 ff ff ff       	call   803624 <fsipc>
  8036f4:	85 c0                	test   %eax,%eax
  8036f6:	78 2b                	js     803723 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8036f8:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8036ff:	00 
  803700:	89 1c 24             	mov    %ebx,(%esp)
  803703:	e8 89 ee ff ff       	call   802591 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  803708:	a1 80 50 80 00       	mov    0x805080,%eax
  80370d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  803713:	a1 84 50 80 00       	mov    0x805084,%eax
  803718:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80371e:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  803723:	83 c4 14             	add    $0x14,%esp
  803726:	5b                   	pop    %ebx
  803727:	5d                   	pop    %ebp
  803728:	c3                   	ret    

00803729 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  803729:	55                   	push   %ebp
  80372a:	89 e5                	mov    %esp,%ebp
  80372c:	83 ec 18             	sub    $0x18,%esp
  80372f:	8b 55 10             	mov    0x10(%ebp),%edx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	ssize_t writesize;
	size_t bufsize;
	fsipcbuf.write.req_fileid=fd->fd_file.id;
  803732:	8b 45 08             	mov    0x8(%ebp),%eax
  803735:	8b 40 0c             	mov    0xc(%eax),%eax
  803738:	a3 00 50 80 00       	mov    %eax,0x805000
	bufsize=sizeof(fsipcbuf.write.req_buf);
	if(n<bufsize)
  80373d:	89 d0                	mov    %edx,%eax
  80373f:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  803745:	76 05                	jbe    80374c <devfile_write+0x23>
  803747:	b8 f8 0f 00 00       	mov    $0xff8,%eax
		bufsize=n;	
	fsipcbuf.write.req_n=n;
  80374c:	89 15 04 50 80 00    	mov    %edx,0x805004
	memmove((void*)fsipcbuf.write.req_buf,buf,bufsize);
  803752:	89 44 24 08          	mov    %eax,0x8(%esp)
  803756:	8b 45 0c             	mov    0xc(%ebp),%eax
  803759:	89 44 24 04          	mov    %eax,0x4(%esp)
  80375d:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  803764:	e8 2f f0 ff ff       	call   802798 <memmove>
	writesize=(ssize_t)fsipc(FSREQ_WRITE,NULL);
  803769:	ba 00 00 00 00       	mov    $0x0,%edx
  80376e:	b8 04 00 00 00       	mov    $0x4,%eax
  803773:	e8 ac fe ff ff       	call   803624 <fsipc>
	return writesize;
	//panic("devfile_write not implemented");
}
  803778:	c9                   	leave  
  803779:	c3                   	ret    

0080377a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80377a:	55                   	push   %ebp
  80377b:	89 e5                	mov    %esp,%ebp
  80377d:	53                   	push   %ebx
  80377e:	83 ec 14             	sub    $0x14,%esp
	// system server.
	// LAB 5: Your code here
	ssize_t readsize;
	if(debug)
		cprintf("devfile_read:fileid=%x readsize=%x\n",fd->fd_file.id,n);
	fsipcbuf.read.req_fileid=fd->fd_file.id;
  803781:	8b 45 08             	mov    0x8(%ebp),%eax
  803784:	8b 40 0c             	mov    0xc(%eax),%eax
  803787:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n=n;
  80378c:	8b 45 10             	mov    0x10(%ebp),%eax
  80378f:	a3 04 50 80 00       	mov    %eax,0x805004
	readsize=(ssize_t)fsipc(FSREQ_READ,&fsipcbuf);
  803794:	ba 00 50 80 00       	mov    $0x805000,%edx
  803799:	b8 03 00 00 00       	mov    $0x3,%eax
  80379e:	e8 81 fe ff ff       	call   803624 <fsipc>
  8037a3:	89 c3                	mov    %eax,%ebx
	cprintf("readsize=%d\n",readsize);
  8037a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8037a9:	c7 04 24 54 46 80 00 	movl   $0x804654,(%esp)
  8037b0:	e8 7c e7 ff ff       	call   801f31 <cprintf>
	if(debug)
		cprintf("devfile_read:buf1=%s\nbuf2=%s\n",(char*)&fsipcbuf,fsipcbuf.readRet.ret_buf);
	if(readsize>0)
  8037b5:	85 db                	test   %ebx,%ebx
  8037b7:	7e 17                	jle    8037d0 <devfile_read+0x56>
		memmove(buf,(void*)&fsipcbuf,(size_t)readsize);
  8037b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8037bd:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8037c4:	00 
  8037c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8037c8:	89 04 24             	mov    %eax,(%esp)
  8037cb:	e8 c8 ef ff ff       	call   802798 <memmove>
	//cprintf("readsize=%d",readsize);
	return readsize;
	//panic("devfile_read not implemented");
}
  8037d0:	89 d8                	mov    %ebx,%eax
  8037d2:	83 c4 14             	add    $0x14,%esp
  8037d5:	5b                   	pop    %ebx
  8037d6:	5d                   	pop    %ebp
  8037d7:	c3                   	ret    

008037d8 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8037d8:	55                   	push   %ebp
  8037d9:	89 e5                	mov    %esp,%ebp
  8037db:	53                   	push   %ebx
  8037dc:	83 ec 14             	sub    $0x14,%esp
  8037df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8037e2:	89 1c 24             	mov    %ebx,(%esp)
  8037e5:	e8 56 ed ff ff       	call   802540 <strlen>
  8037ea:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  8037ef:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8037f4:	7f 21                	jg     803817 <remove+0x3f>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  8037f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8037fa:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  803801:	e8 8b ed ff ff       	call   802591 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  803806:	ba 00 00 00 00       	mov    $0x0,%edx
  80380b:	b8 07 00 00 00       	mov    $0x7,%eax
  803810:	e8 0f fe ff ff       	call   803624 <fsipc>
  803815:	89 c2                	mov    %eax,%edx
}
  803817:	89 d0                	mov    %edx,%eax
  803819:	83 c4 14             	add    $0x14,%esp
  80381c:	5b                   	pop    %ebx
  80381d:	5d                   	pop    %ebp
  80381e:	c3                   	ret    

0080381f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80381f:	55                   	push   %ebp
  803820:	89 e5                	mov    %esp,%ebp
  803822:	53                   	push   %ebx
  803823:	83 ec 24             	sub    $0x24,%esp
	// file descriptor.

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;
	if((r=fd_alloc(&fd))<0){
  803826:	8d 45 f8             	lea    -0x8(%ebp),%eax
  803829:	89 04 24             	mov    %eax,(%esp)
  80382c:	e8 0a f8 ff ff       	call   80303b <fd_alloc>
  803831:	89 c3                	mov    %eax,%ebx
  803833:	85 c0                	test   %eax,%eax
  803835:	79 18                	jns    80384f <open+0x30>
		fd_close(fd,0);
  803837:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80383e:	00 
  80383f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  803842:	89 04 24             	mov    %eax,(%esp)
  803845:	e8 94 fb ff ff       	call   8033de <fd_close>
  80384a:	e9 b4 00 00 00       	jmp    803903 <open+0xe4>
		return r;
	}
	cprintf("open:fd=%x\n",fd);
  80384f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  803852:	89 44 24 04          	mov    %eax,0x4(%esp)
  803856:	c7 04 24 61 46 80 00 	movl   $0x804661,(%esp)
  80385d:	e8 cf e6 ff ff       	call   801f31 <cprintf>
	strcpy(fsipcbuf.open.req_path,path);
  803862:	8b 45 08             	mov    0x8(%ebp),%eax
  803865:	89 44 24 04          	mov    %eax,0x4(%esp)
  803869:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  803870:	e8 1c ed ff ff       	call   802591 <strcpy>
	fsipcbuf.open.req_omode=mode;
  803875:	8b 45 0c             	mov    0xc(%ebp),%eax
  803878:	a3 00 54 80 00       	mov    %eax,0x805400
	if((r=fsipc(FSREQ_OPEN,(void*)fd))<0)
  80387d:	8b 55 f8             	mov    -0x8(%ebp),%edx
  803880:	b8 01 00 00 00       	mov    $0x1,%eax
  803885:	e8 9a fd ff ff       	call   803624 <fsipc>
  80388a:	89 c3                	mov    %eax,%ebx
  80388c:	85 c0                	test   %eax,%eax
  80388e:	79 15                	jns    8038a5 <open+0x86>
	{
		fd_close(fd,1);
  803890:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  803897:	00 
  803898:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80389b:	89 04 24             	mov    %eax,(%esp)
  80389e:	e8 3b fb ff ff       	call   8033de <fd_close>
  8038a3:	eb 5e                	jmp    803903 <open+0xe4>
		return r;	
	}
	if((r=sys_page_map(0,(void*)fd,0,(void*)fd,PTE_P | PTE_W | PTE_U))<0)
  8038a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8038a8:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8038af:	00 
  8038b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8038b4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8038bb:	00 
  8038bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8038c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8038c7:	e8 6c f3 ff ff       	call   802c38 <sys_page_map>
  8038cc:	89 c3                	mov    %eax,%ebx
  8038ce:	85 c0                	test   %eax,%eax
  8038d0:	79 15                	jns    8038e7 <open+0xc8>
	{
		fd_close(fd,1);
  8038d2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8038d9:	00 
  8038da:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8038dd:	89 04 24             	mov    %eax,(%esp)
  8038e0:	e8 f9 fa ff ff       	call   8033de <fd_close>
  8038e5:	eb 1c                	jmp    803903 <open+0xe4>
		return r;
	}
	//INDEX2DATA(fd->fd_file.id);
	cprintf("fileid=%x\n",fd->fd_file.id);
  8038e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8038ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8038ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8038f1:	c7 04 24 d8 3e 80 00 	movl   $0x803ed8,(%esp)
  8038f8:	e8 34 e6 ff ff       	call   801f31 <cprintf>
	return fd->fd_file.id;
  8038fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
  803900:	8b 58 0c             	mov    0xc(%eax),%ebx
	//panic("open not implemented");
}
  803903:	89 d8                	mov    %ebx,%eax
  803905:	83 c4 24             	add    $0x24,%esp
  803908:	5b                   	pop    %ebx
  803909:	5d                   	pop    %ebp
  80390a:	c3                   	ret    
	...

0080390c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80390c:	55                   	push   %ebp
  80390d:	89 e5                	mov    %esp,%ebp
  80390f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  803912:	89 d0                	mov    %edx,%eax
  803914:	c1 e8 16             	shr    $0x16,%eax
  803917:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80391e:	a8 01                	test   $0x1,%al
  803920:	74 25                	je     803947 <pageref+0x3b>
		return 0;
	pte = vpt[VPN(v)];
  803922:	89 d0                	mov    %edx,%eax
  803924:	c1 e8 0c             	shr    $0xc,%eax
  803927:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80392e:	a8 01                	test   $0x1,%al
  803930:	74 15                	je     803947 <pageref+0x3b>
		return 0;
	return pages[PPN(pte)].pp_ref;
  803932:	c1 e8 0c             	shr    $0xc,%eax
  803935:	8d 04 40             	lea    (%eax,%eax,2),%eax
  803938:	c1 e0 02             	shl    $0x2,%eax
  80393b:	0f b7 80 08 00 00 ef 	movzwl -0x10fffff8(%eax),%eax
  803942:	0f b7 c0             	movzwl %ax,%eax
  803945:	eb 05                	jmp    80394c <pageref+0x40>
  803947:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80394c:	5d                   	pop    %ebp
  80394d:	c3                   	ret    
	...

00803950 <__udivdi3>:
  803950:	55                   	push   %ebp
  803951:	89 e5                	mov    %esp,%ebp
  803953:	57                   	push   %edi
  803954:	56                   	push   %esi
  803955:	83 ec 18             	sub    $0x18,%esp
  803958:	8b 45 10             	mov    0x10(%ebp),%eax
  80395b:	8b 55 14             	mov    0x14(%ebp),%edx
  80395e:	8b 75 0c             	mov    0xc(%ebp),%esi
  803961:	89 45 f4             	mov    %eax,-0xc(%ebp)
  803964:	89 c1                	mov    %eax,%ecx
  803966:	8b 45 08             	mov    0x8(%ebp),%eax
  803969:	85 d2                	test   %edx,%edx
  80396b:	89 d7                	mov    %edx,%edi
  80396d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  803970:	75 1e                	jne    803990 <__udivdi3+0x40>
  803972:	39 f1                	cmp    %esi,%ecx
  803974:	0f 86 8d 00 00 00    	jbe    803a07 <__udivdi3+0xb7>
  80397a:	89 f2                	mov    %esi,%edx
  80397c:	31 f6                	xor    %esi,%esi
  80397e:	f7 f1                	div    %ecx
  803980:	89 c1                	mov    %eax,%ecx
  803982:	89 c8                	mov    %ecx,%eax
  803984:	89 f2                	mov    %esi,%edx
  803986:	83 c4 18             	add    $0x18,%esp
  803989:	5e                   	pop    %esi
  80398a:	5f                   	pop    %edi
  80398b:	5d                   	pop    %ebp
  80398c:	c3                   	ret    
  80398d:	8d 76 00             	lea    0x0(%esi),%esi
  803990:	39 f2                	cmp    %esi,%edx
  803992:	0f 87 a8 00 00 00    	ja     803a40 <__udivdi3+0xf0>
  803998:	0f bd c2             	bsr    %edx,%eax
  80399b:	83 f0 1f             	xor    $0x1f,%eax
  80399e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8039a1:	0f 84 89 00 00 00    	je     803a30 <__udivdi3+0xe0>
  8039a7:	b8 20 00 00 00       	mov    $0x20,%eax
  8039ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8039af:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8039b2:	89 c1                	mov    %eax,%ecx
  8039b4:	d3 ea                	shr    %cl,%edx
  8039b6:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  8039ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8039bd:	89 f8                	mov    %edi,%eax
  8039bf:	8b 7d f4             	mov    -0xc(%ebp),%edi
  8039c2:	d3 e0                	shl    %cl,%eax
  8039c4:	09 c2                	or     %eax,%edx
  8039c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8039c9:	d3 e7                	shl    %cl,%edi
  8039cb:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8039cf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8039d2:	89 f2                	mov    %esi,%edx
  8039d4:	d3 e8                	shr    %cl,%eax
  8039d6:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  8039da:	d3 e2                	shl    %cl,%edx
  8039dc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8039e0:	09 d0                	or     %edx,%eax
  8039e2:	d3 ee                	shr    %cl,%esi
  8039e4:	89 f2                	mov    %esi,%edx
  8039e6:	f7 75 e4             	divl   -0x1c(%ebp)
  8039e9:	89 d1                	mov    %edx,%ecx
  8039eb:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8039ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8039f1:	f7 e7                	mul    %edi
  8039f3:	39 d1                	cmp    %edx,%ecx
  8039f5:	89 c6                	mov    %eax,%esi
  8039f7:	72 70                	jb     803a69 <__udivdi3+0x119>
  8039f9:	39 ca                	cmp    %ecx,%edx
  8039fb:	74 5f                	je     803a5c <__udivdi3+0x10c>
  8039fd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  803a00:	31 f6                	xor    %esi,%esi
  803a02:	e9 7b ff ff ff       	jmp    803982 <__udivdi3+0x32>
  803a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803a0a:	85 c0                	test   %eax,%eax
  803a0c:	75 0c                	jne    803a1a <__udivdi3+0xca>
  803a0e:	b8 01 00 00 00       	mov    $0x1,%eax
  803a13:	31 d2                	xor    %edx,%edx
  803a15:	f7 75 f4             	divl   -0xc(%ebp)
  803a18:	89 c1                	mov    %eax,%ecx
  803a1a:	89 f0                	mov    %esi,%eax
  803a1c:	89 fa                	mov    %edi,%edx
  803a1e:	f7 f1                	div    %ecx
  803a20:	89 c6                	mov    %eax,%esi
  803a22:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803a25:	f7 f1                	div    %ecx
  803a27:	89 c1                	mov    %eax,%ecx
  803a29:	e9 54 ff ff ff       	jmp    803982 <__udivdi3+0x32>
  803a2e:	66 90                	xchg   %ax,%ax
  803a30:	39 d6                	cmp    %edx,%esi
  803a32:	77 1c                	ja     803a50 <__udivdi3+0x100>
  803a34:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803a37:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  803a3a:	73 14                	jae    803a50 <__udivdi3+0x100>
  803a3c:	8d 74 26 00          	lea    0x0(%esi),%esi
  803a40:	31 c9                	xor    %ecx,%ecx
  803a42:	31 f6                	xor    %esi,%esi
  803a44:	e9 39 ff ff ff       	jmp    803982 <__udivdi3+0x32>
  803a49:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  803a50:	b9 01 00 00 00       	mov    $0x1,%ecx
  803a55:	31 f6                	xor    %esi,%esi
  803a57:	e9 26 ff ff ff       	jmp    803982 <__udivdi3+0x32>
  803a5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803a5f:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  803a63:	d3 e0                	shl    %cl,%eax
  803a65:	39 c6                	cmp    %eax,%esi
  803a67:	76 94                	jbe    8039fd <__udivdi3+0xad>
  803a69:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  803a6c:	31 f6                	xor    %esi,%esi
  803a6e:	83 e9 01             	sub    $0x1,%ecx
  803a71:	e9 0c ff ff ff       	jmp    803982 <__udivdi3+0x32>
	...

00803a80 <__umoddi3>:
  803a80:	55                   	push   %ebp
  803a81:	89 e5                	mov    %esp,%ebp
  803a83:	57                   	push   %edi
  803a84:	56                   	push   %esi
  803a85:	83 ec 30             	sub    $0x30,%esp
  803a88:	8b 45 10             	mov    0x10(%ebp),%eax
  803a8b:	8b 55 14             	mov    0x14(%ebp),%edx
  803a8e:	8b 75 08             	mov    0x8(%ebp),%esi
  803a91:	8b 7d 0c             	mov    0xc(%ebp),%edi
  803a94:	89 45 ec             	mov    %eax,-0x14(%ebp)
  803a97:	89 c1                	mov    %eax,%ecx
  803a99:	89 55 e8             	mov    %edx,-0x18(%ebp)
  803a9c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  803a9f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  803aa6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  803aad:	89 fa                	mov    %edi,%edx
  803aaf:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  803ab2:	85 c0                	test   %eax,%eax
  803ab4:	89 75 f0             	mov    %esi,-0x10(%ebp)
  803ab7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  803aba:	75 14                	jne    803ad0 <__umoddi3+0x50>
  803abc:	39 f9                	cmp    %edi,%ecx
  803abe:	76 60                	jbe    803b20 <__umoddi3+0xa0>
  803ac0:	89 f0                	mov    %esi,%eax
  803ac2:	f7 f1                	div    %ecx
  803ac4:	89 55 d0             	mov    %edx,-0x30(%ebp)
  803ac7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  803ace:	eb 10                	jmp    803ae0 <__umoddi3+0x60>
  803ad0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  803ad3:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  803ad6:	76 18                	jbe    803af0 <__umoddi3+0x70>
  803ad8:	89 75 d0             	mov    %esi,-0x30(%ebp)
  803adb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  803ade:	66 90                	xchg   %ax,%ax
  803ae0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  803ae3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  803ae6:	83 c4 30             	add    $0x30,%esp
  803ae9:	5e                   	pop    %esi
  803aea:	5f                   	pop    %edi
  803aeb:	5d                   	pop    %ebp
  803aec:	c3                   	ret    
  803aed:	8d 76 00             	lea    0x0(%esi),%esi
  803af0:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
  803af4:	83 f0 1f             	xor    $0x1f,%eax
  803af7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  803afa:	75 46                	jne    803b42 <__umoddi3+0xc2>
  803afc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  803aff:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  803b02:	0f 87 c9 00 00 00    	ja     803bd1 <__umoddi3+0x151>
  803b08:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  803b0b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  803b0e:	0f 83 bd 00 00 00    	jae    803bd1 <__umoddi3+0x151>
  803b14:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  803b17:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  803b1a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  803b1d:	eb c1                	jmp    803ae0 <__umoddi3+0x60>
  803b1f:	90                   	nop    
  803b20:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803b23:	85 c0                	test   %eax,%eax
  803b25:	75 0c                	jne    803b33 <__umoddi3+0xb3>
  803b27:	b8 01 00 00 00       	mov    $0x1,%eax
  803b2c:	31 d2                	xor    %edx,%edx
  803b2e:	f7 75 ec             	divl   -0x14(%ebp)
  803b31:	89 c1                	mov    %eax,%ecx
  803b33:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803b36:	8b 55 e8             	mov    -0x18(%ebp),%edx
  803b39:	f7 f1                	div    %ecx
  803b3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803b3e:	f7 f1                	div    %ecx
  803b40:	eb 82                	jmp    803ac4 <__umoddi3+0x44>
  803b42:	b8 20 00 00 00       	mov    $0x20,%eax
  803b47:	8b 55 ec             	mov    -0x14(%ebp),%edx
  803b4a:	2b 45 d8             	sub    -0x28(%ebp),%eax
  803b4d:	8b 75 ec             	mov    -0x14(%ebp),%esi
  803b50:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  803b53:	89 c1                	mov    %eax,%ecx
  803b55:	89 45 dc             	mov    %eax,-0x24(%ebp)
  803b58:	d3 ea                	shr    %cl,%edx
  803b5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  803b5d:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  803b61:	d3 e0                	shl    %cl,%eax
  803b63:	09 c2                	or     %eax,%edx
  803b65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803b68:	d3 e6                	shl    %cl,%esi
  803b6a:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  803b6e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  803b71:	8b 55 e0             	mov    -0x20(%ebp),%edx
  803b74:	d3 e8                	shr    %cl,%eax
  803b76:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  803b7a:	d3 e2                	shl    %cl,%edx
  803b7c:	09 d0                	or     %edx,%eax
  803b7e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  803b81:	d3 e7                	shl    %cl,%edi
  803b83:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  803b87:	d3 ea                	shr    %cl,%edx
  803b89:	f7 75 f4             	divl   -0xc(%ebp)
  803b8c:	89 55 cc             	mov    %edx,-0x34(%ebp)
  803b8f:	f7 e6                	mul    %esi
  803b91:	39 55 cc             	cmp    %edx,-0x34(%ebp)
  803b94:	72 53                	jb     803be9 <__umoddi3+0x169>
  803b96:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  803b99:	74 4a                	je     803be5 <__umoddi3+0x165>
  803b9b:	90                   	nop    
  803b9c:	8d 74 26 00          	lea    0x0(%esi),%esi
  803ba0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  803ba3:	29 c7                	sub    %eax,%edi
  803ba5:	19 d1                	sbb    %edx,%ecx
  803ba7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  803baa:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  803bae:	89 fa                	mov    %edi,%edx
  803bb0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  803bb3:	d3 ea                	shr    %cl,%edx
  803bb5:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  803bb9:	d3 e0                	shl    %cl,%eax
  803bbb:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  803bbf:	09 c2                	or     %eax,%edx
  803bc1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  803bc4:	89 55 d0             	mov    %edx,-0x30(%ebp)
  803bc7:	d3 e8                	shr    %cl,%eax
  803bc9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  803bcc:	e9 0f ff ff ff       	jmp    803ae0 <__umoddi3+0x60>
  803bd1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  803bd4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803bd7:	2b 45 ec             	sub    -0x14(%ebp),%eax
  803bda:	1b 55 e8             	sbb    -0x18(%ebp),%edx
  803bdd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  803be0:	e9 2f ff ff ff       	jmp    803b14 <__umoddi3+0x94>
  803be5:	39 f8                	cmp    %edi,%eax
  803be7:	76 b7                	jbe    803ba0 <__umoddi3+0x120>
  803be9:	29 f0                	sub    %esi,%eax
  803beb:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  803bee:	eb b0                	jmp    803ba0 <__umoddi3+0x120>
