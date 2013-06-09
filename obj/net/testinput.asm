
obj/net/testinput:     file format elf32-i386

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
  80002c:	e8 e3 04 00 00       	call   800514 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:
}

void
umain(void)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	57                   	push   %edi
  800044:	56                   	push   %esi
  800045:	53                   	push   %ebx
  800046:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	envid_t ns_envid = sys_getenvid();
  80004c:	e8 4c 14 00 00       	call   80149d <sys_getenvid>
  800051:	89 c3                	mov    %eax,%ebx
	int i, r;

	binaryname = "testinput";
  800053:	c7 05 00 70 80 00 80 	movl   $0x803080,0x807000
  80005a:	30 80 00 

	output_envid = fork();
  80005d:	e8 17 19 00 00       	call   801979 <fork>
  800062:	a3 3c 70 80 00       	mov    %eax,0x80703c
	if (output_envid < 0)
  800067:	85 c0                	test   %eax,%eax
  800069:	79 1c                	jns    800087 <umain+0x47>
		panic("error forking");
  80006b:	c7 44 24 08 8a 30 80 	movl   $0x80308a,0x8(%esp)
  800072:	00 
  800073:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  80007a:	00 
  80007b:	c7 04 24 98 30 80 00 	movl   $0x803098,(%esp)
  800082:	e8 05 05 00 00       	call   80058c <_panic>
	else if (output_envid == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 0d                	jne    800098 <umain+0x58>
		output(ns_envid);
  80008b:	89 1c 24             	mov    %ebx,(%esp)
  80008e:	e8 71 04 00 00       	call   800504 <output>
  800093:	e9 bd 03 00 00       	jmp    800455 <umain+0x415>
		return;
	}

	input_envid = fork();
  800098:	e8 dc 18 00 00       	call   801979 <fork>
  80009d:	a3 40 70 80 00       	mov    %eax,0x807040
	if (input_envid < 0)
  8000a2:	85 c0                	test   %eax,%eax
  8000a4:	79 1c                	jns    8000c2 <umain+0x82>
		panic("error forking");
  8000a6:	c7 44 24 08 8a 30 80 	movl   $0x80308a,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 98 30 80 00 	movl   $0x803098,(%esp)
  8000bd:	e8 ca 04 00 00       	call   80058c <_panic>
	else if (input_envid == 0) {
  8000c2:	85 c0                	test   %eax,%eax
  8000c4:	75 0f                	jne    8000d5 <umain+0x95>
		input(ns_envid);
  8000c6:	89 1c 24             	mov    %ebx,(%esp)
  8000c9:	e8 26 04 00 00       	call   8004f4 <input>
  8000ce:	66 90                	xchg   %ax,%ax
  8000d0:	e9 80 03 00 00       	jmp    800455 <umain+0x415>
		return;
	}

	cprintf("Sending ARP announcement...\n");
  8000d5:	c7 04 24 a8 30 80 00 	movl   $0x8030a8,(%esp)
  8000dc:	e8 78 05 00 00       	call   800659 <cprintf>
  8000e1:	c6 45 9c 52          	movb   $0x52,0xffffff9c(%ebp)
  8000e5:	c6 45 9d 54          	movb   $0x54,0xffffff9d(%ebp)
  8000e9:	c6 45 9e 00          	movb   $0x0,0xffffff9e(%ebp)
  8000ed:	c6 45 9f 12          	movb   $0x12,0xffffff9f(%ebp)
  8000f1:	c6 45 a0 34          	movb   $0x34,0xffffffa0(%ebp)
  8000f5:	c6 45 a1 56          	movb   $0x56,0xffffffa1(%ebp)
  8000f9:	c7 04 24 c5 30 80 00 	movl   $0x8030c5,(%esp)
  800100:	e8 73 2c 00 00       	call   802d78 <inet_addr>
  800105:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  800108:	c7 04 24 cf 30 80 00 	movl   $0x8030cf,(%esp)
  80010f:	e8 64 2c 00 00       	call   802d78 <inet_addr>
  800114:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  800117:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80011e:	00 
  80011f:	a1 68 31 80 00       	mov    0x803168,%eax
  800124:	89 44 24 04          	mov    %eax,0x4(%esp)
  800128:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80012f:	e8 d6 12 00 00       	call   80140a <sys_page_alloc>
  800134:	85 c0                	test   %eax,%eax
  800136:	79 20                	jns    800158 <umain+0x118>
  800138:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013c:	c7 44 24 08 d8 30 80 	movl   $0x8030d8,0x8(%esp)
  800143:	00 
  800144:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  80014b:	00 
  80014c:	c7 04 24 98 30 80 00 	movl   $0x803098,(%esp)
  800153:	e8 34 04 00 00       	call   80058c <_panic>
  800158:	8b 1d 68 31 80 00    	mov    0x803168,%ebx
  80015e:	83 c3 04             	add    $0x4,%ebx
  800161:	8b 15 68 31 80 00    	mov    0x803168,%edx
  800167:	c7 02 2a 00 00 00    	movl   $0x2a,(%edx)
  80016d:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  800174:	00 
  800175:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80017c:	00 
  80017d:	89 1c 24             	mov    %ebx,(%esp)
  800180:	e8 0c 0d 00 00       	call   800e91 <memset>
  800185:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  80018c:	00 
  80018d:	8d 75 9c             	lea    0xffffff9c(%ebp),%esi
  800190:	89 74 24 04          	mov    %esi,0x4(%esp)
  800194:	a1 68 31 80 00       	mov    0x803168,%eax
  800199:	83 c0 0a             	add    $0xa,%eax
  80019c:	89 04 24             	mov    %eax,(%esp)
  80019f:	e8 c4 0d 00 00       	call   800f68 <memcpy>
  8001a4:	c7 04 24 06 08 00 00 	movl   $0x806,(%esp)
  8001ab:	e8 af 29 00 00       	call   802b5f <htons>
  8001b0:	66 89 43 0c          	mov    %ax,0xc(%ebx)
  8001b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001bb:	e8 9f 29 00 00       	call   802b5f <htons>
  8001c0:	66 89 43 0e          	mov    %ax,0xe(%ebx)
  8001c4:	c7 04 24 00 08 00 00 	movl   $0x800,(%esp)
  8001cb:	e8 8f 29 00 00       	call   802b5f <htons>
  8001d0:	66 89 43 10          	mov    %ax,0x10(%ebx)
  8001d4:	c7 04 24 04 06 00 00 	movl   $0x604,(%esp)
  8001db:	e8 7f 29 00 00       	call   802b5f <htons>
  8001e0:	66 89 43 12          	mov    %ax,0x12(%ebx)
  8001e4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001eb:	e8 6f 29 00 00       	call   802b5f <htons>
  8001f0:	66 89 43 14          	mov    %ax,0x14(%ebx)
  8001f4:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  8001fb:	00 
  8001fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800200:	a1 68 31 80 00       	mov    0x803168,%eax
  800205:	83 c0 1a             	add    $0x1a,%eax
  800208:	89 04 24             	mov    %eax,(%esp)
  80020b:	e8 58 0d 00 00       	call   800f68 <memcpy>
  800210:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800217:	00 
  800218:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  80021b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021f:	a1 68 31 80 00       	mov    0x803168,%eax
  800224:	83 c0 20             	add    $0x20,%eax
  800227:	89 04 24             	mov    %eax,(%esp)
  80022a:	e8 39 0d 00 00       	call   800f68 <memcpy>
  80022f:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  800236:	00 
  800237:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80023e:	00 
  80023f:	a1 68 31 80 00       	mov    0x803168,%eax
  800244:	83 c0 24             	add    $0x24,%eax
  800247:	89 04 24             	mov    %eax,(%esp)
  80024a:	e8 42 0c 00 00       	call   800e91 <memset>
  80024f:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800256:	00 
  800257:	8d 45 ec             	lea    0xffffffec(%ebp),%eax
  80025a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025e:	a1 68 31 80 00       	mov    0x803168,%eax
  800263:	83 c0 2a             	add    $0x2a,%eax
  800266:	89 04 24             	mov    %eax,(%esp)
  800269:	e8 fa 0c 00 00       	call   800f68 <memcpy>
  80026e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800275:	00 
  800276:	a1 68 31 80 00       	mov    0x803168,%eax
  80027b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027f:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  800286:	00 
  800287:	a1 3c 70 80 00       	mov    0x80703c,%eax
  80028c:	89 04 24             	mov    %eax,(%esp)
  80028f:	e8 ec 17 00 00       	call   801a80 <ipc_send>
  800294:	8b 15 68 31 80 00    	mov    0x803168,%edx
  80029a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80029e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002a5:	e8 a4 10 00 00       	call   80134e <sys_page_unmap>
	announce();

	cprintf("Waiting for packets...\n");
  8002aa:	c7 04 24 e9 30 80 00 	movl   $0x8030e9,(%esp)
  8002b1:	e8 a3 03 00 00       	call   800659 <cprintf>
  8002b6:	89 9d 7c ff ff ff    	mov    %ebx,0xffffff7c(%ebp)
	while (1) {
		envid_t whom;
		int perm;

		int32_t req = ipc_recv((int32_t *)&whom, pkt, &perm);
  8002bc:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  8002bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c3:	8b 15 68 31 80 00    	mov    0x803168,%edx
  8002c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002cd:	8d 45 ec             	lea    0xffffffec(%ebp),%eax
  8002d0:	89 04 24             	mov    %eax,(%esp)
  8002d3:	e8 5c 18 00 00       	call   801b34 <ipc_recv>
		if (req < 0)
  8002d8:	85 c0                	test   %eax,%eax
  8002da:	79 20                	jns    8002fc <umain+0x2bc>
			panic("ipc_recv: %e", req);
  8002dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e0:	c7 44 24 08 01 31 80 	movl   $0x803101,0x8(%esp)
  8002e7:	00 
  8002e8:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
  8002ef:	00 
  8002f0:	c7 04 24 98 30 80 00 	movl   $0x803098,(%esp)
  8002f7:	e8 90 02 00 00       	call   80058c <_panic>
		if (whom != input_envid)
  8002fc:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  8002ff:	3b 15 40 70 80 00    	cmp    0x807040,%edx
  800305:	74 20                	je     800327 <umain+0x2e7>
			panic("IPC from unexpected environment %08x", whom);
  800307:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80030b:	c7 44 24 08 40 31 80 	movl   $0x803140,0x8(%esp)
  800312:	00 
  800313:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  80031a:	00 
  80031b:	c7 04 24 98 30 80 00 	movl   $0x803098,(%esp)
  800322:	e8 65 02 00 00       	call   80058c <_panic>
		if (req != NSREQ_INPUT)
  800327:	83 f8 0a             	cmp    $0xa,%eax
  80032a:	74 20                	je     80034c <umain+0x30c>
			panic("Unexpected IPC %d", req);
  80032c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800330:	c7 44 24 08 0e 31 80 	movl   $0x80310e,0x8(%esp)
  800337:	00 
  800338:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
  80033f:	00 
  800340:	c7 04 24 98 30 80 00 	movl   $0x803098,(%esp)
  800347:	e8 40 02 00 00       	call   80058c <_panic>

		hexdump("input: ", pkt->jp_data, pkt->jp_len);
  80034c:	a1 68 31 80 00       	mov    0x803168,%eax
  800351:	8b 00                	mov    (%eax),%eax
  800353:	89 45 88             	mov    %eax,0xffffff88(%ebp)
  800356:	8b 95 7c ff ff ff    	mov    0xffffff7c(%ebp),%edx
  80035c:	89 55 8c             	mov    %edx,0xffffff8c(%ebp)
  80035f:	85 c0                	test   %eax,%eax
  800361:	0f 8e dd 00 00 00    	jle    800444 <umain+0x404>
  800367:	bb 00 00 00 00       	mov    $0x0,%ebx
  80036c:	be 00 00 00 00       	mov    $0x0,%esi
  800371:	8d 45 9c             	lea    0xffffff9c(%ebp),%eax
  800374:	89 45 84             	mov    %eax,0xffffff84(%ebp)
  800377:	8d 55 ec             	lea    0xffffffec(%ebp),%edx
  80037a:	89 55 90             	mov    %edx,0xffffff90(%ebp)
  80037d:	29 c2                	sub    %eax,%edx
  80037f:	89 55 80             	mov    %edx,0xffffff80(%ebp)
  800382:	f6 c3 0f             	test   $0xf,%bl
  800385:	75 2b                	jne    8003b2 <umain+0x372>
  800387:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80038b:	c7 44 24 0c 20 31 80 	movl   $0x803120,0xc(%esp)
  800392:	00 
  800393:	c7 44 24 08 28 31 80 	movl   $0x803128,0x8(%esp)
  80039a:	00 
  80039b:	8b 45 80             	mov    0xffffff80(%ebp),%eax
  80039e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a2:	8b 55 84             	mov    0xffffff84(%ebp),%edx
  8003a5:	89 14 24             	mov    %edx,(%esp)
  8003a8:	e8 82 08 00 00       	call   800c2f <snprintf>
  8003ad:	8b 75 84             	mov    0xffffff84(%ebp),%esi
  8003b0:	01 c6                	add    %eax,%esi
  8003b2:	8b 55 8c             	mov    0xffffff8c(%ebp),%edx
  8003b5:	0f b6 04 13          	movzbl (%ebx,%edx,1),%eax
  8003b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003bd:	c7 44 24 08 32 31 80 	movl   $0x803132,0x8(%esp)
  8003c4:	00 
  8003c5:	8b 45 90             	mov    0xffffff90(%ebp),%eax
  8003c8:	29 f0                	sub    %esi,%eax
  8003ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ce:	89 34 24             	mov    %esi,(%esp)
  8003d1:	e8 59 08 00 00       	call   800c2f <snprintf>
  8003d6:	01 c6                	add    %eax,%esi
  8003d8:	89 da                	mov    %ebx,%edx
  8003da:	c1 fa 1f             	sar    $0x1f,%edx
  8003dd:	c1 ea 1c             	shr    $0x1c,%edx
  8003e0:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  8003e3:	83 e0 0f             	and    $0xf,%eax
  8003e6:	89 c7                	mov    %eax,%edi
  8003e8:	29 d7                	sub    %edx,%edi
  8003ea:	83 ff 0f             	cmp    $0xf,%edi
  8003ed:	74 0a                	je     8003f9 <umain+0x3b9>
  8003ef:	8b 45 88             	mov    0xffffff88(%ebp),%eax
  8003f2:	83 e8 01             	sub    $0x1,%eax
  8003f5:	39 d8                	cmp    %ebx,%eax
  8003f7:	75 1c                	jne    800415 <umain+0x3d5>
  8003f9:	8b 45 84             	mov    0xffffff84(%ebp),%eax
  8003fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800400:	89 f0                	mov    %esi,%eax
  800402:	2b 45 84             	sub    0xffffff84(%ebp),%eax
  800405:	89 44 24 04          	mov    %eax,0x4(%esp)
  800409:	c7 04 24 37 31 80 00 	movl   $0x803137,(%esp)
  800410:	e8 44 02 00 00       	call   800659 <cprintf>
  800415:	89 da                	mov    %ebx,%edx
  800417:	c1 ea 1f             	shr    $0x1f,%edx
  80041a:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  80041d:	83 e0 01             	and    $0x1,%eax
  800420:	29 d0                	sub    %edx,%eax
  800422:	83 f8 01             	cmp    $0x1,%eax
  800425:	75 06                	jne    80042d <umain+0x3ed>
  800427:	c6 06 20             	movb   $0x20,(%esi)
  80042a:	83 c6 01             	add    $0x1,%esi
  80042d:	83 ff 07             	cmp    $0x7,%edi
  800430:	75 06                	jne    800438 <umain+0x3f8>
  800432:	c6 06 20             	movb   $0x20,(%esi)
  800435:	83 c6 01             	add    $0x1,%esi
  800438:	83 c3 01             	add    $0x1,%ebx
  80043b:	3b 5d 88             	cmp    0xffffff88(%ebp),%ebx
  80043e:	0f 85 3e ff ff ff    	jne    800382 <umain+0x342>
		cprintf("\n");
  800444:	c7 04 24 ff 30 80 00 	movl   $0x8030ff,(%esp)
  80044b:	e8 09 02 00 00       	call   800659 <cprintf>
  800450:	e9 67 fe ff ff       	jmp    8002bc <umain+0x27c>
	}
}
  800455:	81 c4 8c 00 00 00    	add    $0x8c,%esp
  80045b:	5b                   	pop    %ebx
  80045c:	5e                   	pop    %esi
  80045d:	5f                   	pop    %edi
  80045e:	5d                   	pop    %ebp
  80045f:	c3                   	ret    

00800460 <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  800460:	55                   	push   %ebp
  800461:	89 e5                	mov    %esp,%ebp
  800463:	57                   	push   %edi
  800464:	56                   	push   %esi
  800465:	53                   	push   %ebx
  800466:	83 ec 2c             	sub    $0x2c,%esp
  800469:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint32_t stop = sys_time_msec() + initial_to;
  80046c:	e8 fa 0c 00 00       	call   80116b <sys_time_msec>
  800471:	89 c3                	mov    %eax,%ebx
  800473:	03 5d 0c             	add    0xc(%ebp),%ebx

	binaryname = "ns_timer";
  800476:	c7 05 00 70 80 00 6c 	movl   $0x80316c,0x807000
  80047d:	31 80 00 
  800480:	eb 05                	jmp    800487 <timer+0x27>

	while (1) {
		while(sys_time_msec() < stop) {
			sys_yield();
  800482:	e8 e2 0f 00 00       	call   801469 <sys_yield>
  800487:	e8 df 0c 00 00       	call   80116b <sys_time_msec>
  80048c:	39 c3                	cmp    %eax,%ebx
  80048e:	66 90                	xchg   %ax,%ax
  800490:	77 f0                	ja     800482 <timer+0x22>
		}

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  800492:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800499:	00 
  80049a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004a1:	00 
  8004a2:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
  8004a9:	00 
  8004aa:	89 3c 24             	mov    %edi,(%esp)
  8004ad:	e8 ce 15 00 00       	call   801a80 <ipc_send>
  8004b2:	8d 75 f0             	lea    0xfffffff0(%ebp),%esi

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8004b5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004bc:	00 
  8004bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004c4:	00 
  8004c5:	89 34 24             	mov    %esi,(%esp)
  8004c8:	e8 67 16 00 00       	call   801b34 <ipc_recv>
  8004cd:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  8004cf:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8004d2:	39 c7                	cmp    %eax,%edi
  8004d4:	74 12                	je     8004e8 <timer+0x88>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  8004d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004da:	c7 04 24 78 31 80 00 	movl   $0x803178,(%esp)
  8004e1:	e8 73 01 00 00       	call   800659 <cprintf>
  8004e6:	eb cd                	jmp    8004b5 <timer+0x55>
				continue;
			}

			stop = sys_time_msec() + to;
  8004e8:	e8 7e 0c 00 00       	call   80116b <sys_time_msec>
  8004ed:	01 c3                	add    %eax,%ebx
  8004ef:	90                   	nop    
  8004f0:	eb 95                	jmp    800487 <timer+0x27>
	...

008004f4 <input>:
extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_input";
  8004f7:	c7 05 00 70 80 00 b3 	movl   $0x8031b3,0x807000
  8004fe:	31 80 00 

	// LAB 6: Your code here:
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
}
  800501:	5d                   	pop    %ebp
  800502:	c3                   	ret    
	...

00800504 <output>:
extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  800504:	55                   	push   %ebp
  800505:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_output";
  800507:	c7 05 00 70 80 00 bc 	movl   $0x8031bc,0x807000
  80050e:	31 80 00 

	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
}
  800511:	5d                   	pop    %ebp
  800512:	c3                   	ret    
	...

00800514 <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800514:	55                   	push   %ebp
  800515:	89 e5                	mov    %esp,%ebp
  800517:	83 ec 18             	sub    $0x18,%esp
  80051a:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  80051d:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  800520:	8b 75 08             	mov    0x8(%ebp),%esi
  800523:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  800526:	c7 05 54 70 80 00 00 	movl   $0x0,0x807054
  80052d:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  800530:	e8 68 0f 00 00       	call   80149d <sys_getenvid>
  800535:	25 ff 03 00 00       	and    $0x3ff,%eax
  80053a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80053d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800542:	a3 54 70 80 00       	mov    %eax,0x807054
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800547:	85 f6                	test   %esi,%esi
  800549:	7e 07                	jle    800552 <libmain+0x3e>
		binaryname = argv[0];
  80054b:	8b 03                	mov    (%ebx),%eax
  80054d:	a3 00 70 80 00       	mov    %eax,0x807000

	// call user main routine调用用户主例程
	umain(argc, argv);
  800552:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800556:	89 34 24             	mov    %esi,(%esp)
  800559:	e8 e2 fa ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  80055e:	e8 0d 00 00 00       	call   800570 <exit>
}
  800563:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  800566:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  800569:	89 ec                	mov    %ebp,%esp
  80056b:	5d                   	pop    %ebp
  80056c:	c3                   	ret    
  80056d:	00 00                	add    %al,(%eax)
	...

00800570 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  800570:	55                   	push   %ebp
  800571:	89 e5                	mov    %esp,%ebp
  800573:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800576:	e8 9b 1c 00 00       	call   802216 <close_all>
	sys_env_destroy(0);
  80057b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800582:	e8 4a 0f 00 00       	call   8014d1 <sys_env_destroy>
}
  800587:	c9                   	leave  
  800588:	c3                   	ret    
  800589:	00 00                	add    %al,(%eax)
	...

0080058c <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  80058c:	55                   	push   %ebp
  80058d:	89 e5                	mov    %esp,%ebp
  80058f:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800592:	8d 45 14             	lea    0x14(%ebp),%eax
  800595:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)

	// Print the panic message
	if (argv0)
  800598:	a1 58 70 80 00       	mov    0x807058,%eax
  80059d:	85 c0                	test   %eax,%eax
  80059f:	74 10                	je     8005b1 <_panic+0x25>
		cprintf("%s: ", argv0);
  8005a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a5:	c7 04 24 dd 31 80 00 	movl   $0x8031dd,(%esp)
  8005ac:	e8 a8 00 00 00       	call   800659 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8005b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8005bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005bf:	a1 00 70 80 00       	mov    0x807000,%eax
  8005c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c8:	c7 04 24 e2 31 80 00 	movl   $0x8031e2,(%esp)
  8005cf:	e8 85 00 00 00       	call   800659 <cprintf>
	vcprintf(fmt, ap);
  8005d4:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  8005d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005db:	8b 45 10             	mov    0x10(%ebp),%eax
  8005de:	89 04 24             	mov    %eax,(%esp)
  8005e1:	e8 12 00 00 00       	call   8005f8 <vcprintf>
	cprintf("\n");
  8005e6:	c7 04 24 ff 30 80 00 	movl   $0x8030ff,(%esp)
  8005ed:	e8 67 00 00 00       	call   800659 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8005f2:	cc                   	int3   
  8005f3:	eb fd                	jmp    8005f2 <_panic+0x66>
  8005f5:	00 00                	add    %al,(%eax)
	...

008005f8 <vcprintf>:
}

int
vcprintf(const char *fmt, va_list ap)
{
  8005f8:	55                   	push   %ebp
  8005f9:	89 e5                	mov    %esp,%ebp
  8005fb:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800601:	c7 85 f8 fe ff ff 00 	movl   $0x0,0xfffffef8(%ebp)
  800608:	00 00 00 
	b.cnt = 0;
  80060b:	c7 85 fc fe ff ff 00 	movl   $0x0,0xfffffefc(%ebp)
  800612:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800615:	8b 45 0c             	mov    0xc(%ebp),%eax
  800618:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80061c:	8b 45 08             	mov    0x8(%ebp),%eax
  80061f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800623:	8d 85 f8 fe ff ff    	lea    0xfffffef8(%ebp),%eax
  800629:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062d:	c7 04 24 76 06 80 00 	movl   $0x800676,(%esp)
  800634:	e8 c8 01 00 00       	call   800801 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800639:	8b 85 f8 fe ff ff    	mov    0xfffffef8(%ebp),%eax
  80063f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800643:	8d 85 00 ff ff ff    	lea    0xffffff00(%ebp),%eax
  800649:	89 04 24             	mov    %eax,(%esp)
  80064c:	e8 e7 0a 00 00       	call   801138 <sys_cputs>
  800651:	8b 85 fc fe ff ff    	mov    0xfffffefc(%ebp),%eax

	return b.cnt;
}
  800657:	c9                   	leave  
  800658:	c3                   	ret    

00800659 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800659:	55                   	push   %ebp
  80065a:	89 e5                	mov    %esp,%ebp
  80065c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80065f:	8d 45 0c             	lea    0xc(%ebp),%eax
  800662:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
	cnt = vcprintf(fmt, ap);
  800665:	89 44 24 04          	mov    %eax,0x4(%esp)
  800669:	8b 45 08             	mov    0x8(%ebp),%eax
  80066c:	89 04 24             	mov    %eax,(%esp)
  80066f:	e8 84 ff ff ff       	call   8005f8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800674:	c9                   	leave  
  800675:	c3                   	ret    

00800676 <putch>:
  800676:	55                   	push   %ebp
  800677:	89 e5                	mov    %esp,%ebp
  800679:	53                   	push   %ebx
  80067a:	83 ec 14             	sub    $0x14,%esp
  80067d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800680:	8b 03                	mov    (%ebx),%eax
  800682:	8b 55 08             	mov    0x8(%ebp),%edx
  800685:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800689:	83 c0 01             	add    $0x1,%eax
  80068c:	89 03                	mov    %eax,(%ebx)
  80068e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800693:	75 19                	jne    8006ae <putch+0x38>
  800695:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80069c:	00 
  80069d:	8d 43 08             	lea    0x8(%ebx),%eax
  8006a0:	89 04 24             	mov    %eax,(%esp)
  8006a3:	e8 90 0a 00 00       	call   801138 <sys_cputs>
  8006a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8006ae:	83 43 04 01          	addl   $0x1,0x4(%ebx)
  8006b2:	83 c4 14             	add    $0x14,%esp
  8006b5:	5b                   	pop    %ebx
  8006b6:	5d                   	pop    %ebp
  8006b7:	c3                   	ret    
	...

008006c0 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006c0:	55                   	push   %ebp
  8006c1:	89 e5                	mov    %esp,%ebp
  8006c3:	57                   	push   %edi
  8006c4:	56                   	push   %esi
  8006c5:	53                   	push   %ebx
  8006c6:	83 ec 3c             	sub    $0x3c,%esp
  8006c9:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8006cc:	89 d7                	mov    %edx,%edi
  8006ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006d4:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  8006d7:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  8006da:	8b 55 10             	mov    0x10(%ebp),%edx
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006e3:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  8006e6:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  8006ed:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  8006f0:	39 4d ec             	cmp    %ecx,0xffffffec(%ebp)
  8006f3:	72 11                	jb     800706 <printnum+0x46>
  8006f5:	8b 4d d8             	mov    0xffffffd8(%ebp),%ecx
  8006f8:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  8006fb:	76 09                	jbe    800706 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006fd:	8d 58 ff             	lea    0xffffffff(%eax),%ebx
  800700:	85 db                	test   %ebx,%ebx
  800702:	7f 54                	jg     800758 <printnum+0x98>
  800704:	eb 61                	jmp    800767 <printnum+0xa7>
  800706:	89 74 24 10          	mov    %esi,0x10(%esp)
  80070a:	83 e8 01             	sub    $0x1,%eax
  80070d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800711:	89 54 24 08          	mov    %edx,0x8(%esp)
  800715:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800719:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80071d:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800720:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800723:	89 44 24 08          	mov    %eax,0x8(%esp)
  800727:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80072b:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  80072e:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800731:	89 14 24             	mov    %edx,(%esp)
  800734:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800738:	e8 73 26 00 00       	call   802db0 <__udivdi3>
  80073d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800741:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800745:	89 04 24             	mov    %eax,(%esp)
  800748:	89 54 24 04          	mov    %edx,0x4(%esp)
  80074c:	89 fa                	mov    %edi,%edx
  80074e:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  800751:	e8 6a ff ff ff       	call   8006c0 <printnum>
  800756:	eb 0f                	jmp    800767 <printnum+0xa7>
			putch(padc, putdat);
  800758:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80075c:	89 34 24             	mov    %esi,(%esp)
  80075f:	ff 55 e4             	call   *0xffffffe4(%ebp)
  800762:	83 eb 01             	sub    $0x1,%ebx
  800765:	75 f1                	jne    800758 <printnum+0x98>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800767:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076b:	8b 74 24 04          	mov    0x4(%esp),%esi
  80076f:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800772:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800775:	89 44 24 08          	mov    %eax,0x8(%esp)
  800779:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80077d:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800780:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800783:	89 14 24             	mov    %edx,(%esp)
  800786:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80078a:	e8 51 27 00 00       	call   802ee0 <__umoddi3>
  80078f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800793:	0f be 80 fe 31 80 00 	movsbl 0x8031fe(%eax),%eax
  80079a:	89 04 24             	mov    %eax,(%esp)
  80079d:	ff 55 e4             	call   *0xffffffe4(%ebp)
}
  8007a0:	83 c4 3c             	add    $0x3c,%esp
  8007a3:	5b                   	pop    %ebx
  8007a4:	5e                   	pop    %esi
  8007a5:	5f                   	pop    %edi
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8007ad:	83 fa 01             	cmp    $0x1,%edx
  8007b0:	7e 0e                	jle    8007c0 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8007b2:	8b 10                	mov    (%eax),%edx
  8007b4:	8d 42 08             	lea    0x8(%edx),%eax
  8007b7:	89 01                	mov    %eax,(%ecx)
  8007b9:	8b 02                	mov    (%edx),%eax
  8007bb:	8b 52 04             	mov    0x4(%edx),%edx
  8007be:	eb 22                	jmp    8007e2 <getuint+0x3a>
	else if (lflag)
  8007c0:	85 d2                	test   %edx,%edx
  8007c2:	74 10                	je     8007d4 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8007c4:	8b 10                	mov    (%eax),%edx
  8007c6:	8d 42 04             	lea    0x4(%edx),%eax
  8007c9:	89 01                	mov    %eax,(%ecx)
  8007cb:	8b 02                	mov    (%edx),%eax
  8007cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d2:	eb 0e                	jmp    8007e2 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8007d4:	8b 10                	mov    (%eax),%edx
  8007d6:	8d 42 04             	lea    0x4(%edx),%eax
  8007d9:	89 01                	mov    %eax,(%ecx)
  8007db:	8b 02                	mov    (%edx),%eax
  8007dd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007e2:	5d                   	pop    %ebp
  8007e3:	c3                   	ret    

008007e4 <sprintputch>:

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
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  8007ea:	83 41 08 01          	addl   $0x1,0x8(%ecx)
	if (b->buf < b->ebuf)
  8007ee:	8b 11                	mov    (%ecx),%edx
  8007f0:	3b 51 04             	cmp    0x4(%ecx),%edx
  8007f3:	73 0a                	jae    8007ff <sprintputch+0x1b>
		*b->buf++ = ch;
  8007f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f8:	88 02                	mov    %al,(%edx)
  8007fa:	8d 42 01             	lea    0x1(%edx),%eax
  8007fd:	89 01                	mov    %eax,(%ecx)
}
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <vprintfmt>:
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	57                   	push   %edi
  800805:	56                   	push   %esi
  800806:	53                   	push   %ebx
  800807:	83 ec 4c             	sub    $0x4c,%esp
  80080a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80080d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800810:	eb 03                	jmp    800815 <vprintfmt+0x14>
  800812:	8b 5d e8             	mov    0xffffffe8(%ebp),%ebx
  800815:	0f b6 03             	movzbl (%ebx),%eax
  800818:	83 c3 01             	add    $0x1,%ebx
  80081b:	3c 25                	cmp    $0x25,%al
  80081d:	74 30                	je     80084f <vprintfmt+0x4e>
  80081f:	84 c0                	test   %al,%al
  800821:	0f 84 a8 03 00 00    	je     800bcf <vprintfmt+0x3ce>
  800827:	0f b6 d0             	movzbl %al,%edx
  80082a:	eb 0a                	jmp    800836 <vprintfmt+0x35>
  80082c:	84 c0                	test   %al,%al
  80082e:	66 90                	xchg   %ax,%ax
  800830:	0f 84 99 03 00 00    	je     800bcf <vprintfmt+0x3ce>
  800836:	8b 45 0c             	mov    0xc(%ebp),%eax
  800839:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083d:	89 14 24             	mov    %edx,(%esp)
  800840:	ff d7                	call   *%edi
  800842:	0f b6 03             	movzbl (%ebx),%eax
  800845:	0f b6 d0             	movzbl %al,%edx
  800848:	83 c3 01             	add    $0x1,%ebx
  80084b:	3c 25                	cmp    $0x25,%al
  80084d:	75 dd                	jne    80082c <vprintfmt+0x2b>
  80084f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800854:	c7 45 ec ff ff ff ff 	movl   $0xffffffff,0xffffffec(%ebp)
  80085b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  800862:	c7 45 dc 00 00 00 00 	movl   $0x0,0xffffffdc(%ebp)
  800869:	c6 45 e3 20          	movb   $0x20,0xffffffe3(%ebp)
  80086d:	eb 07                	jmp    800876 <vprintfmt+0x75>
  80086f:	c7 45 dc 01 00 00 00 	movl   $0x1,0xffffffdc(%ebp)
  800876:	0f b6 03             	movzbl (%ebx),%eax
  800879:	0f b6 d0             	movzbl %al,%edx
  80087c:	83 c3 01             	add    $0x1,%ebx
  80087f:	83 e8 23             	sub    $0x23,%eax
  800882:	3c 55                	cmp    $0x55,%al
  800884:	0f 87 11 03 00 00    	ja     800b9b <vprintfmt+0x39a>
  80088a:	0f b6 c0             	movzbl %al,%eax
  80088d:	ff 24 85 40 33 80 00 	jmp    *0x803340(,%eax,4)
  800894:	c6 45 e3 30          	movb   $0x30,0xffffffe3(%ebp)
  800898:	eb dc                	jmp    800876 <vprintfmt+0x75>
  80089a:	83 ea 30             	sub    $0x30,%edx
  80089d:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  8008a0:	0f be 13             	movsbl (%ebx),%edx
  8008a3:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  8008a6:	83 f8 09             	cmp    $0x9,%eax
  8008a9:	76 08                	jbe    8008b3 <vprintfmt+0xb2>
  8008ab:	eb 42                	jmp    8008ef <vprintfmt+0xee>
  8008ad:	c6 45 e3 2d          	movb   $0x2d,0xffffffe3(%ebp)
  8008b1:	eb c3                	jmp    800876 <vprintfmt+0x75>
  8008b3:	83 c3 01             	add    $0x1,%ebx
  8008b6:	8b 75 e4             	mov    0xffffffe4(%ebp),%esi
  8008b9:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8008bc:	8d 44 42 d0          	lea    0xffffffd0(%edx,%eax,2),%eax
  8008c0:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8008c3:	0f be 13             	movsbl (%ebx),%edx
  8008c6:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  8008c9:	83 f8 09             	cmp    $0x9,%eax
  8008cc:	77 21                	ja     8008ef <vprintfmt+0xee>
  8008ce:	eb e3                	jmp    8008b3 <vprintfmt+0xb2>
  8008d0:	8b 55 14             	mov    0x14(%ebp),%edx
  8008d3:	8d 42 04             	lea    0x4(%edx),%eax
  8008d6:	89 45 14             	mov    %eax,0x14(%ebp)
  8008d9:	8b 12                	mov    (%edx),%edx
  8008db:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  8008de:	eb 0f                	jmp    8008ef <vprintfmt+0xee>
  8008e0:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  8008e4:	79 90                	jns    800876 <vprintfmt+0x75>
  8008e6:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  8008ed:	eb 87                	jmp    800876 <vprintfmt+0x75>
  8008ef:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  8008f3:	79 81                	jns    800876 <vprintfmt+0x75>
  8008f5:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  8008f8:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8008fb:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  800902:	e9 6f ff ff ff       	jmp    800876 <vprintfmt+0x75>
  800907:	83 c1 01             	add    $0x1,%ecx
  80090a:	e9 67 ff ff ff       	jmp    800876 <vprintfmt+0x75>
  80090f:	8b 45 14             	mov    0x14(%ebp),%eax
  800912:	8d 50 04             	lea    0x4(%eax),%edx
  800915:	89 55 14             	mov    %edx,0x14(%ebp)
  800918:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80091f:	8b 00                	mov    (%eax),%eax
  800921:	89 04 24             	mov    %eax,(%esp)
  800924:	ff d7                	call   *%edi
  800926:	e9 ea fe ff ff       	jmp    800815 <vprintfmt+0x14>
  80092b:	8b 55 14             	mov    0x14(%ebp),%edx
  80092e:	8d 42 04             	lea    0x4(%edx),%eax
  800931:	89 45 14             	mov    %eax,0x14(%ebp)
  800934:	8b 02                	mov    (%edx),%eax
  800936:	89 c2                	mov    %eax,%edx
  800938:	c1 fa 1f             	sar    $0x1f,%edx
  80093b:	31 d0                	xor    %edx,%eax
  80093d:	29 d0                	sub    %edx,%eax
  80093f:	83 f8 0f             	cmp    $0xf,%eax
  800942:	7f 0b                	jg     80094f <vprintfmt+0x14e>
  800944:	8b 14 85 a0 34 80 00 	mov    0x8034a0(,%eax,4),%edx
  80094b:	85 d2                	test   %edx,%edx
  80094d:	75 20                	jne    80096f <vprintfmt+0x16e>
  80094f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800953:	c7 44 24 08 0f 32 80 	movl   $0x80320f,0x8(%esp)
  80095a:	00 
  80095b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800962:	89 3c 24             	mov    %edi,(%esp)
  800965:	e8 f0 02 00 00       	call   800c5a <printfmt>
  80096a:	e9 a6 fe ff ff       	jmp    800815 <vprintfmt+0x14>
  80096f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800973:	c7 44 24 08 2a 37 80 	movl   $0x80372a,0x8(%esp)
  80097a:	00 
  80097b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800982:	89 3c 24             	mov    %edi,(%esp)
  800985:	e8 d0 02 00 00       	call   800c5a <printfmt>
  80098a:	e9 86 fe ff ff       	jmp    800815 <vprintfmt+0x14>
  80098f:	8b 75 ec             	mov    0xffffffec(%ebp),%esi
  800992:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  800995:	89 5d e8             	mov    %ebx,0xffffffe8(%ebp)
  800998:	8b 55 14             	mov    0x14(%ebp),%edx
  80099b:	8d 42 04             	lea    0x4(%edx),%eax
  80099e:	89 45 14             	mov    %eax,0x14(%ebp)
  8009a1:	8b 12                	mov    (%edx),%edx
  8009a3:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  8009a6:	85 d2                	test   %edx,%edx
  8009a8:	75 07                	jne    8009b1 <vprintfmt+0x1b0>
  8009aa:	c7 45 d8 18 32 80 00 	movl   $0x803218,0xffffffd8(%ebp)
  8009b1:	85 f6                	test   %esi,%esi
  8009b3:	7e 40                	jle    8009f5 <vprintfmt+0x1f4>
  8009b5:	80 7d e3 2d          	cmpb   $0x2d,0xffffffe3(%ebp)
  8009b9:	74 3a                	je     8009f5 <vprintfmt+0x1f4>
  8009bb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009bf:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  8009c2:	89 14 24             	mov    %edx,(%esp)
  8009c5:	e8 e6 02 00 00       	call   800cb0 <strnlen>
  8009ca:	29 c6                	sub    %eax,%esi
  8009cc:	89 75 ec             	mov    %esi,0xffffffec(%ebp)
  8009cf:	85 f6                	test   %esi,%esi
  8009d1:	7e 22                	jle    8009f5 <vprintfmt+0x1f4>
  8009d3:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  8009d7:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  8009da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009e1:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  8009e4:	89 04 24             	mov    %eax,(%esp)
  8009e7:	ff d7                	call   *%edi
  8009e9:	83 ee 01             	sub    $0x1,%esi
  8009ec:	75 ec                	jne    8009da <vprintfmt+0x1d9>
  8009ee:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  8009f5:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  8009f8:	0f b6 02             	movzbl (%edx),%eax
  8009fb:	0f be d0             	movsbl %al,%edx
  8009fe:	8b 75 d8             	mov    0xffffffd8(%ebp),%esi
  800a01:	84 c0                	test   %al,%al
  800a03:	75 40                	jne    800a45 <vprintfmt+0x244>
  800a05:	eb 4a                	jmp    800a51 <vprintfmt+0x250>
  800a07:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
  800a0b:	74 1a                	je     800a27 <vprintfmt+0x226>
  800a0d:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  800a10:	83 f8 5e             	cmp    $0x5e,%eax
  800a13:	76 12                	jbe    800a27 <vprintfmt+0x226>
  800a15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a18:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a23:	ff d7                	call   *%edi
  800a25:	eb 0c                	jmp    800a33 <vprintfmt+0x232>
  800a27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a2e:	89 14 24             	mov    %edx,(%esp)
  800a31:	ff d7                	call   *%edi
  800a33:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  800a37:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800a3b:	83 c6 01             	add    $0x1,%esi
  800a3e:	84 c0                	test   %al,%al
  800a40:	74 0f                	je     800a51 <vprintfmt+0x250>
  800a42:	0f be d0             	movsbl %al,%edx
  800a45:	83 7d e4 00          	cmpl   $0x0,0xffffffe4(%ebp)
  800a49:	78 bc                	js     800a07 <vprintfmt+0x206>
  800a4b:	83 6d e4 01          	subl   $0x1,0xffffffe4(%ebp)
  800a4f:	79 b6                	jns    800a07 <vprintfmt+0x206>
  800a51:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800a55:	0f 8e ba fd ff ff    	jle    800815 <vprintfmt+0x14>
  800a5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a62:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a69:	ff d7                	call   *%edi
  800a6b:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  800a6f:	0f 84 9d fd ff ff    	je     800812 <vprintfmt+0x11>
  800a75:	eb e4                	jmp    800a5b <vprintfmt+0x25a>
  800a77:	83 f9 01             	cmp    $0x1,%ecx
  800a7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800a80:	7e 10                	jle    800a92 <vprintfmt+0x291>
  800a82:	8b 55 14             	mov    0x14(%ebp),%edx
  800a85:	8d 42 08             	lea    0x8(%edx),%eax
  800a88:	89 45 14             	mov    %eax,0x14(%ebp)
  800a8b:	8b 02                	mov    (%edx),%eax
  800a8d:	8b 52 04             	mov    0x4(%edx),%edx
  800a90:	eb 26                	jmp    800ab8 <vprintfmt+0x2b7>
  800a92:	85 c9                	test   %ecx,%ecx
  800a94:	74 12                	je     800aa8 <vprintfmt+0x2a7>
  800a96:	8b 45 14             	mov    0x14(%ebp),%eax
  800a99:	8d 50 04             	lea    0x4(%eax),%edx
  800a9c:	89 55 14             	mov    %edx,0x14(%ebp)
  800a9f:	8b 00                	mov    (%eax),%eax
  800aa1:	89 c2                	mov    %eax,%edx
  800aa3:	c1 fa 1f             	sar    $0x1f,%edx
  800aa6:	eb 10                	jmp    800ab8 <vprintfmt+0x2b7>
  800aa8:	8b 45 14             	mov    0x14(%ebp),%eax
  800aab:	8d 50 04             	lea    0x4(%eax),%edx
  800aae:	89 55 14             	mov    %edx,0x14(%ebp)
  800ab1:	8b 00                	mov    (%eax),%eax
  800ab3:	89 c2                	mov    %eax,%edx
  800ab5:	c1 fa 1f             	sar    $0x1f,%edx
  800ab8:	89 d1                	mov    %edx,%ecx
  800aba:	89 c2                	mov    %eax,%edx
  800abc:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  800abf:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  800ac2:	be 0a 00 00 00       	mov    $0xa,%esi
  800ac7:	85 c9                	test   %ecx,%ecx
  800ac9:	0f 89 92 00 00 00    	jns    800b61 <vprintfmt+0x360>
  800acf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ad6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800add:	ff d7                	call   *%edi
  800adf:	8b 55 d0             	mov    0xffffffd0(%ebp),%edx
  800ae2:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  800ae5:	f7 da                	neg    %edx
  800ae7:	83 d1 00             	adc    $0x0,%ecx
  800aea:	f7 d9                	neg    %ecx
  800aec:	be 0a 00 00 00       	mov    $0xa,%esi
  800af1:	eb 6e                	jmp    800b61 <vprintfmt+0x360>
  800af3:	8d 45 14             	lea    0x14(%ebp),%eax
  800af6:	89 ca                	mov    %ecx,%edx
  800af8:	e8 ab fc ff ff       	call   8007a8 <getuint>
  800afd:	89 d1                	mov    %edx,%ecx
  800aff:	89 c2                	mov    %eax,%edx
  800b01:	be 0a 00 00 00       	mov    $0xa,%esi
  800b06:	eb 59                	jmp    800b61 <vprintfmt+0x360>
  800b08:	8d 45 14             	lea    0x14(%ebp),%eax
  800b0b:	89 ca                	mov    %ecx,%edx
  800b0d:	e8 96 fc ff ff       	call   8007a8 <getuint>
  800b12:	e9 fe fc ff ff       	jmp    800815 <vprintfmt+0x14>
  800b17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b1e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b25:	ff d7                	call   *%edi
  800b27:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2a:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b2e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b35:	ff d7                	call   *%edi
  800b37:	8b 55 14             	mov    0x14(%ebp),%edx
  800b3a:	8d 42 04             	lea    0x4(%edx),%eax
  800b3d:	89 45 14             	mov    %eax,0x14(%ebp)
  800b40:	8b 12                	mov    (%edx),%edx
  800b42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b47:	be 10 00 00 00       	mov    $0x10,%esi
  800b4c:	eb 13                	jmp    800b61 <vprintfmt+0x360>
  800b4e:	8d 45 14             	lea    0x14(%ebp),%eax
  800b51:	89 ca                	mov    %ecx,%edx
  800b53:	e8 50 fc ff ff       	call   8007a8 <getuint>
  800b58:	89 d1                	mov    %edx,%ecx
  800b5a:	89 c2                	mov    %eax,%edx
  800b5c:	be 10 00 00 00       	mov    $0x10,%esi
  800b61:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  800b65:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b69:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  800b6c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b70:	89 74 24 08          	mov    %esi,0x8(%esp)
  800b74:	89 14 24             	mov    %edx,(%esp)
  800b77:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800b7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7e:	89 f8                	mov    %edi,%eax
  800b80:	e8 3b fb ff ff       	call   8006c0 <printnum>
  800b85:	e9 8b fc ff ff       	jmp    800815 <vprintfmt+0x14>
  800b8a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b8d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b91:	89 14 24             	mov    %edx,(%esp)
  800b94:	ff d7                	call   *%edi
  800b96:	e9 7a fc ff ff       	jmp    800815 <vprintfmt+0x14>
  800b9b:	89 de                	mov    %ebx,%esi
  800b9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800bab:	ff d7                	call   *%edi
  800bad:	83 eb 01             	sub    $0x1,%ebx
  800bb0:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800bb4:	0f 84 5b fc ff ff    	je     800815 <vprintfmt+0x14>
  800bba:	8d 56 fd             	lea    0xfffffffd(%esi),%edx
  800bbd:	0f b6 02             	movzbl (%edx),%eax
  800bc0:	83 ea 01             	sub    $0x1,%edx
  800bc3:	3c 25                	cmp    $0x25,%al
  800bc5:	75 f6                	jne    800bbd <vprintfmt+0x3bc>
  800bc7:	8d 5a 02             	lea    0x2(%edx),%ebx
  800bca:	e9 46 fc ff ff       	jmp    800815 <vprintfmt+0x14>
  800bcf:	83 c4 4c             	add    $0x4c,%esp
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	83 ec 28             	sub    $0x28,%esp
  800bdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800be0:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800be3:	85 d2                	test   %edx,%edx
  800be5:	74 04                	je     800beb <vsnprintf+0x14>
  800be7:	85 c0                	test   %eax,%eax
  800be9:	7f 07                	jg     800bf2 <vsnprintf+0x1b>
  800beb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bf0:	eb 3b                	jmp    800c2d <vsnprintf+0x56>
  800bf2:	c7 45 fc 00 00 00 00 	movl   $0x0,0xfffffffc(%ebp)
  800bf9:	8d 44 02 ff          	lea    0xffffffff(%edx,%eax,1),%eax
  800bfd:	89 45 f8             	mov    %eax,0xfffffff8(%ebp)
  800c00:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c03:	8b 45 14             	mov    0x14(%ebp),%eax
  800c06:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c0a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c0d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c11:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  800c14:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c18:	c7 04 24 e4 07 80 00 	movl   $0x8007e4,(%esp)
  800c1f:	e8 dd fb ff ff       	call   800801 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c24:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  800c27:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c2a:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
}
  800c2d:	c9                   	leave  
  800c2e:	c3                   	ret    

00800c2f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c35:	8d 45 14             	lea    0x14(%ebp),%eax
  800c38:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800c3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c3f:	8b 45 10             	mov    0x10(%ebp),%eax
  800c42:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c46:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c49:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c50:	89 04 24             	mov    %eax,(%esp)
  800c53:	e8 7f ff ff ff       	call   800bd7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c58:	c9                   	leave  
  800c59:	c3                   	ret    

00800c5a <printfmt>:
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	83 ec 28             	sub    $0x28,%esp
  800c60:	8d 45 14             	lea    0x14(%ebp),%eax
  800c63:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
  800c66:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c6a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c6d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c74:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c78:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7b:	89 04 24             	mov    %eax,(%esp)
  800c7e:	e8 7e fb ff ff       	call   800801 <vprintfmt>
  800c83:	c9                   	leave  
  800c84:	c3                   	ret    
	...

00800c90 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c96:	b8 00 00 00 00       	mov    $0x0,%eax
  800c9b:	80 3a 00             	cmpb   $0x0,(%edx)
  800c9e:	74 0e                	je     800cae <strlen+0x1e>
  800ca0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800ca5:	83 c0 01             	add    $0x1,%eax
  800ca8:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  800cac:	75 f7                	jne    800ca5 <strlen+0x15>
	return n;
}
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cb9:	85 d2                	test   %edx,%edx
  800cbb:	74 19                	je     800cd6 <strnlen+0x26>
  800cbd:	80 39 00             	cmpb   $0x0,(%ecx)
  800cc0:	74 14                	je     800cd6 <strnlen+0x26>
  800cc2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800cc7:	83 c0 01             	add    $0x1,%eax
  800cca:	39 d0                	cmp    %edx,%eax
  800ccc:	74 0d                	je     800cdb <strnlen+0x2b>
  800cce:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800cd2:	74 07                	je     800cdb <strnlen+0x2b>
  800cd4:	eb f1                	jmp    800cc7 <strnlen+0x17>
  800cd6:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800cdb:	5d                   	pop    %ebp
  800cdc:	8d 74 26 00          	lea    0x0(%esi),%esi
  800ce0:	c3                   	ret    

00800ce1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	53                   	push   %ebx
  800ce5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ceb:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ced:	0f b6 01             	movzbl (%ecx),%eax
  800cf0:	88 02                	mov    %al,(%edx)
  800cf2:	83 c2 01             	add    $0x1,%edx
  800cf5:	83 c1 01             	add    $0x1,%ecx
  800cf8:	84 c0                	test   %al,%al
  800cfa:	75 f1                	jne    800ced <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800cfc:	89 d8                	mov    %ebx,%eax
  800cfe:	5b                   	pop    %ebx
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	57                   	push   %edi
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
  800d07:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d10:	85 f6                	test   %esi,%esi
  800d12:	74 1c                	je     800d30 <strncpy+0x2f>
  800d14:	89 fa                	mov    %edi,%edx
  800d16:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  800d1b:	0f b6 01             	movzbl (%ecx),%eax
  800d1e:	88 02                	mov    %al,(%edx)
  800d20:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d23:	80 39 01             	cmpb   $0x1,(%ecx)
  800d26:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800d29:	83 c3 01             	add    $0x1,%ebx
  800d2c:	39 f3                	cmp    %esi,%ebx
  800d2e:	75 eb                	jne    800d1b <strncpy+0x1a>
	}
	return ret;
}
  800d30:	89 f8                	mov    %edi,%eax
  800d32:	5b                   	pop    %ebx
  800d33:	5e                   	pop    %esi
  800d34:	5f                   	pop    %edi
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
  800d3c:	8b 75 08             	mov    0x8(%ebp),%esi
  800d3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d42:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d45:	89 f0                	mov    %esi,%eax
  800d47:	85 d2                	test   %edx,%edx
  800d49:	74 2c                	je     800d77 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800d4b:	89 d3                	mov    %edx,%ebx
  800d4d:	83 eb 01             	sub    $0x1,%ebx
  800d50:	74 20                	je     800d72 <strlcpy+0x3b>
  800d52:	0f b6 11             	movzbl (%ecx),%edx
  800d55:	84 d2                	test   %dl,%dl
  800d57:	74 19                	je     800d72 <strlcpy+0x3b>
  800d59:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800d5b:	88 10                	mov    %dl,(%eax)
  800d5d:	83 c0 01             	add    $0x1,%eax
  800d60:	83 eb 01             	sub    $0x1,%ebx
  800d63:	74 0f                	je     800d74 <strlcpy+0x3d>
  800d65:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  800d69:	83 c1 01             	add    $0x1,%ecx
  800d6c:	84 d2                	test   %dl,%dl
  800d6e:	74 04                	je     800d74 <strlcpy+0x3d>
  800d70:	eb e9                	jmp    800d5b <strlcpy+0x24>
  800d72:	89 f0                	mov    %esi,%eax
		*dst = '\0';
  800d74:	c6 00 00             	movb   $0x0,(%eax)
  800d77:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
  800d83:	8b 55 08             	mov    0x8(%ebp),%edx
  800d86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d89:	8b 7d 10             	mov    0x10(%ebp),%edi
    int c;
    char *q = buf;

    if (buf_size <= 0)
  800d8c:	85 c9                	test   %ecx,%ecx
  800d8e:	7e 30                	jle    800dc0 <pstrcpy+0x43>
        return;

    for(;;) {
        c = *str++;
  800d90:	0f b6 07             	movzbl (%edi),%eax
        if (c == 0 || q >= buf + buf_size - 1)
  800d93:	84 c0                	test   %al,%al
  800d95:	74 26                	je     800dbd <pstrcpy+0x40>
  800d97:	8d 74 0a ff          	lea    0xffffffff(%edx,%ecx,1),%esi
  800d9b:	0f be d8             	movsbl %al,%ebx
  800d9e:	89 f9                	mov    %edi,%ecx
  800da0:	39 f2                	cmp    %esi,%edx
  800da2:	72 09                	jb     800dad <pstrcpy+0x30>
  800da4:	eb 17                	jmp    800dbd <pstrcpy+0x40>
  800da6:	83 c1 01             	add    $0x1,%ecx
  800da9:	39 f2                	cmp    %esi,%edx
  800dab:	73 10                	jae    800dbd <pstrcpy+0x40>
            break;
        *q++ = c;
  800dad:	88 1a                	mov    %bl,(%edx)
  800daf:	83 c2 01             	add    $0x1,%edx
  800db2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800db6:	0f be d8             	movsbl %al,%ebx
  800db9:	84 c0                	test   %al,%al
  800dbb:	75 e9                	jne    800da6 <pstrcpy+0x29>
    }
    *q = '\0';
  800dbd:	c6 02 00             	movb   $0x0,(%edx)
}
  800dc0:	5b                   	pop    %ebx
  800dc1:	5e                   	pop    %esi
  800dc2:	5f                   	pop    %edi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    

00800dc5 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  800dce:	0f b6 02             	movzbl (%edx),%eax
  800dd1:	84 c0                	test   %al,%al
  800dd3:	74 16                	je     800deb <strcmp+0x26>
  800dd5:	3a 01                	cmp    (%ecx),%al
  800dd7:	75 12                	jne    800deb <strcmp+0x26>
		p++, q++;
  800dd9:	83 c1 01             	add    $0x1,%ecx
  800ddc:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  800de0:	84 c0                	test   %al,%al
  800de2:	74 07                	je     800deb <strcmp+0x26>
  800de4:	83 c2 01             	add    $0x1,%edx
  800de7:	3a 01                	cmp    (%ecx),%al
  800de9:	74 ee                	je     800dd9 <strcmp+0x14>
  800deb:	0f b6 c0             	movzbl %al,%eax
  800dee:	0f b6 11             	movzbl (%ecx),%edx
  800df1:	29 d0                	sub    %edx,%eax
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    

00800df5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	53                   	push   %ebx
  800df9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dfc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dff:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800e02:	85 d2                	test   %edx,%edx
  800e04:	74 2d                	je     800e33 <strncmp+0x3e>
  800e06:	0f b6 01             	movzbl (%ecx),%eax
  800e09:	84 c0                	test   %al,%al
  800e0b:	74 1a                	je     800e27 <strncmp+0x32>
  800e0d:	3a 03                	cmp    (%ebx),%al
  800e0f:	75 16                	jne    800e27 <strncmp+0x32>
  800e11:	83 ea 01             	sub    $0x1,%edx
  800e14:	74 1d                	je     800e33 <strncmp+0x3e>
		n--, p++, q++;
  800e16:	83 c1 01             	add    $0x1,%ecx
  800e19:	83 c3 01             	add    $0x1,%ebx
  800e1c:	0f b6 01             	movzbl (%ecx),%eax
  800e1f:	84 c0                	test   %al,%al
  800e21:	74 04                	je     800e27 <strncmp+0x32>
  800e23:	3a 03                	cmp    (%ebx),%al
  800e25:	74 ea                	je     800e11 <strncmp+0x1c>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e27:	0f b6 11             	movzbl (%ecx),%edx
  800e2a:	0f b6 03             	movzbl (%ebx),%eax
  800e2d:	29 c2                	sub    %eax,%edx
  800e2f:	89 d0                	mov    %edx,%eax
  800e31:	eb 05                	jmp    800e38 <strncmp+0x43>
  800e33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e38:	5b                   	pop    %ebx
  800e39:	5d                   	pop    %ebp
  800e3a:	c3                   	ret    

00800e3b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e45:	0f b6 10             	movzbl (%eax),%edx
  800e48:	84 d2                	test   %dl,%dl
  800e4a:	74 16                	je     800e62 <strchr+0x27>
		if (*s == c)
  800e4c:	38 ca                	cmp    %cl,%dl
  800e4e:	75 06                	jne    800e56 <strchr+0x1b>
  800e50:	eb 15                	jmp    800e67 <strchr+0x2c>
  800e52:	38 ca                	cmp    %cl,%dl
  800e54:	74 11                	je     800e67 <strchr+0x2c>
  800e56:	83 c0 01             	add    $0x1,%eax
  800e59:	0f b6 10             	movzbl (%eax),%edx
  800e5c:	84 d2                	test   %dl,%dl
  800e5e:	66 90                	xchg   %ax,%ax
  800e60:	75 f0                	jne    800e52 <strchr+0x17>
  800e62:	b8 00 00 00 00       	mov    $0x0,%eax
			return (char *) s;
	return 0;
}
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e73:	0f b6 10             	movzbl (%eax),%edx
  800e76:	84 d2                	test   %dl,%dl
  800e78:	74 14                	je     800e8e <strfind+0x25>
		if (*s == c)
  800e7a:	38 ca                	cmp    %cl,%dl
  800e7c:	75 06                	jne    800e84 <strfind+0x1b>
  800e7e:	eb 0e                	jmp    800e8e <strfind+0x25>
  800e80:	38 ca                	cmp    %cl,%dl
  800e82:	74 0a                	je     800e8e <strfind+0x25>
  800e84:	83 c0 01             	add    $0x1,%eax
  800e87:	0f b6 10             	movzbl (%eax),%edx
  800e8a:	84 d2                	test   %dl,%dl
  800e8c:	75 f2                	jne    800e80 <strfind+0x17>
			break;
	return (char *) s;
}
  800e8e:	5d                   	pop    %ebp
  800e8f:	90                   	nop    
  800e90:	c3                   	ret    

00800e91 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	83 ec 08             	sub    $0x8,%esp
  800e97:	89 1c 24             	mov    %ebx,(%esp)
  800e9a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e9e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ea1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800ea7:	85 db                	test   %ebx,%ebx
  800ea9:	74 32                	je     800edd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800eab:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800eb1:	75 25                	jne    800ed8 <memset+0x47>
  800eb3:	f6 c3 03             	test   $0x3,%bl
  800eb6:	75 20                	jne    800ed8 <memset+0x47>
		c &= 0xFF;
  800eb8:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ebb:	89 d0                	mov    %edx,%eax
  800ebd:	c1 e0 18             	shl    $0x18,%eax
  800ec0:	89 d1                	mov    %edx,%ecx
  800ec2:	c1 e1 10             	shl    $0x10,%ecx
  800ec5:	09 c8                	or     %ecx,%eax
  800ec7:	09 d0                	or     %edx,%eax
  800ec9:	c1 e2 08             	shl    $0x8,%edx
  800ecc:	09 d0                	or     %edx,%eax
  800ece:	89 d9                	mov    %ebx,%ecx
  800ed0:	c1 e9 02             	shr    $0x2,%ecx
  800ed3:	fc                   	cld    
  800ed4:	f3 ab                	rep stos %eax,%es:(%edi)
  800ed6:	eb 05                	jmp    800edd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ed8:	89 d9                	mov    %ebx,%ecx
  800eda:	fc                   	cld    
  800edb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800edd:	89 f8                	mov    %edi,%eax
  800edf:	8b 1c 24             	mov    (%esp),%ebx
  800ee2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ee6:	89 ec                	mov    %ebp,%esp
  800ee8:	5d                   	pop    %ebp
  800ee9:	c3                   	ret    

00800eea <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	83 ec 08             	sub    $0x8,%esp
  800ef0:	89 34 24             	mov    %esi,(%esp)
  800ef3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ef7:	8b 45 08             	mov    0x8(%ebp),%eax
  800efa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800efd:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800f00:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800f02:	39 c6                	cmp    %eax,%esi
  800f04:	73 36                	jae    800f3c <memmove+0x52>
  800f06:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f09:	39 d0                	cmp    %edx,%eax
  800f0b:	73 2f                	jae    800f3c <memmove+0x52>
		s += n;
		d += n;
  800f0d:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f10:	f6 c2 03             	test   $0x3,%dl
  800f13:	75 1b                	jne    800f30 <memmove+0x46>
  800f15:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f1b:	75 13                	jne    800f30 <memmove+0x46>
  800f1d:	f6 c1 03             	test   $0x3,%cl
  800f20:	75 0e                	jne    800f30 <memmove+0x46>
			asm volatile("std; rep movsl\n"
  800f22:	8d 7e fc             	lea    0xfffffffc(%esi),%edi
  800f25:	8d 72 fc             	lea    0xfffffffc(%edx),%esi
  800f28:	c1 e9 02             	shr    $0x2,%ecx
  800f2b:	fd                   	std    
  800f2c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f2e:	eb 09                	jmp    800f39 <memmove+0x4f>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f30:	8d 7e ff             	lea    0xffffffff(%esi),%edi
  800f33:	8d 72 ff             	lea    0xffffffff(%edx),%esi
  800f36:	fd                   	std    
  800f37:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f39:	fc                   	cld    
  800f3a:	eb 21                	jmp    800f5d <memmove+0x73>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f3c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f42:	75 16                	jne    800f5a <memmove+0x70>
  800f44:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f4a:	75 0e                	jne    800f5a <memmove+0x70>
  800f4c:	f6 c1 03             	test   $0x3,%cl
  800f4f:	90                   	nop    
  800f50:	75 08                	jne    800f5a <memmove+0x70>
			asm volatile("cld; rep movsl\n"
  800f52:	c1 e9 02             	shr    $0x2,%ecx
  800f55:	fc                   	cld    
  800f56:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f58:	eb 03                	jmp    800f5d <memmove+0x73>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f5a:	fc                   	cld    
  800f5b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f5d:	8b 34 24             	mov    (%esp),%esi
  800f60:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f64:	89 ec                	mov    %ebp,%esp
  800f66:	5d                   	pop    %ebp
  800f67:	c3                   	ret    

00800f68 <memcpy>:

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
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f6e:	8b 45 10             	mov    0x10(%ebp),%eax
  800f71:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f78:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7f:	89 04 24             	mov    %eax,(%esp)
  800f82:	e8 63 ff ff ff       	call   800eea <memmove>
}
  800f87:	c9                   	leave  
  800f88:	c3                   	ret    

00800f89 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f89:	55                   	push   %ebp
  800f8a:	89 e5                	mov    %esp,%ebp
  800f8c:	56                   	push   %esi
  800f8d:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f8e:	8b 75 10             	mov    0x10(%ebp),%esi
  800f91:	83 ee 01             	sub    $0x1,%esi
  800f94:	83 fe ff             	cmp    $0xffffffff,%esi
  800f97:	74 38                	je     800fd1 <memcmp+0x48>
  800f99:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9c:	8b 55 0c             	mov    0xc(%ebp),%edx
		if (*s1 != *s2)
  800f9f:	0f b6 18             	movzbl (%eax),%ebx
  800fa2:	0f b6 0a             	movzbl (%edx),%ecx
  800fa5:	38 cb                	cmp    %cl,%bl
  800fa7:	74 20                	je     800fc9 <memcmp+0x40>
  800fa9:	eb 12                	jmp    800fbd <memcmp+0x34>
  800fab:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
  800faf:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
  800fb3:	83 c0 01             	add    $0x1,%eax
  800fb6:	83 c2 01             	add    $0x1,%edx
  800fb9:	38 cb                	cmp    %cl,%bl
  800fbb:	74 0c                	je     800fc9 <memcmp+0x40>
			return (int) *s1 - (int) *s2;
  800fbd:	0f b6 d3             	movzbl %bl,%edx
  800fc0:	0f b6 c1             	movzbl %cl,%eax
  800fc3:	29 c2                	sub    %eax,%edx
  800fc5:	89 d0                	mov    %edx,%eax
  800fc7:	eb 0d                	jmp    800fd6 <memcmp+0x4d>
  800fc9:	83 ee 01             	sub    $0x1,%esi
  800fcc:	83 fe ff             	cmp    $0xffffffff,%esi
  800fcf:	75 da                	jne    800fab <memcmp+0x22>
  800fd1:	b8 00 00 00 00       	mov    $0x0,%eax
		s1++, s2++;
	}

	return 0;
}
  800fd6:	5b                   	pop    %ebx
  800fd7:	5e                   	pop    %esi
  800fd8:	5d                   	pop    %ebp
  800fd9:	c3                   	ret    

00800fda <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	53                   	push   %ebx
  800fde:	8b 5d 08             	mov    0x8(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800fe1:	89 da                	mov    %ebx,%edx
  800fe3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800fe6:	39 d3                	cmp    %edx,%ebx
  800fe8:	73 1a                	jae    801004 <memfind+0x2a>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fea:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
			break;
  800fee:	89 d8                	mov    %ebx,%eax
  800ff0:	38 0b                	cmp    %cl,(%ebx)
  800ff2:	75 06                	jne    800ffa <memfind+0x20>
  800ff4:	eb 0e                	jmp    801004 <memfind+0x2a>
  800ff6:	38 08                	cmp    %cl,(%eax)
  800ff8:	74 0c                	je     801006 <memfind+0x2c>
  800ffa:	83 c0 01             	add    $0x1,%eax
  800ffd:	39 d0                	cmp    %edx,%eax
  800fff:	90                   	nop    
  801000:	75 f4                	jne    800ff6 <memfind+0x1c>
  801002:	eb 02                	jmp    801006 <memfind+0x2c>
  801004:	89 d8                	mov    %ebx,%eax
	return (void *) s;
}
  801006:	5b                   	pop    %ebx
  801007:	5d                   	pop    %ebp
  801008:	c3                   	ret    

00801009 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	57                   	push   %edi
  80100d:	56                   	push   %esi
  80100e:	53                   	push   %ebx
  80100f:	83 ec 04             	sub    $0x4,%esp
  801012:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801015:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801018:	0f b6 03             	movzbl (%ebx),%eax
  80101b:	3c 20                	cmp    $0x20,%al
  80101d:	74 04                	je     801023 <strtol+0x1a>
  80101f:	3c 09                	cmp    $0x9,%al
  801021:	75 0e                	jne    801031 <strtol+0x28>
		s++;
  801023:	83 c3 01             	add    $0x1,%ebx
  801026:	0f b6 03             	movzbl (%ebx),%eax
  801029:	3c 20                	cmp    $0x20,%al
  80102b:	74 f6                	je     801023 <strtol+0x1a>
  80102d:	3c 09                	cmp    $0x9,%al
  80102f:	74 f2                	je     801023 <strtol+0x1a>

	// plus/minus sign
	if (*s == '+')
  801031:	3c 2b                	cmp    $0x2b,%al
  801033:	75 0d                	jne    801042 <strtol+0x39>
		s++;
  801035:	83 c3 01             	add    $0x1,%ebx
  801038:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  80103f:	90                   	nop    
  801040:	eb 15                	jmp    801057 <strtol+0x4e>
	else if (*s == '-')
  801042:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  801049:	3c 2d                	cmp    $0x2d,%al
  80104b:	75 0a                	jne    801057 <strtol+0x4e>
		s++, neg = 1;
  80104d:	83 c3 01             	add    $0x1,%ebx
  801050:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801057:	85 f6                	test   %esi,%esi
  801059:	0f 94 c0             	sete   %al
  80105c:	84 c0                	test   %al,%al
  80105e:	75 05                	jne    801065 <strtol+0x5c>
  801060:	83 fe 10             	cmp    $0x10,%esi
  801063:	75 17                	jne    80107c <strtol+0x73>
  801065:	80 3b 30             	cmpb   $0x30,(%ebx)
  801068:	75 12                	jne    80107c <strtol+0x73>
  80106a:	80 7b 01 78          	cmpb   $0x78,0x1(%ebx)
  80106e:	66 90                	xchg   %ax,%ax
  801070:	75 0a                	jne    80107c <strtol+0x73>
		s += 2, base = 16;
  801072:	83 c3 02             	add    $0x2,%ebx
  801075:	be 10 00 00 00       	mov    $0x10,%esi
  80107a:	eb 1f                	jmp    80109b <strtol+0x92>
	else if (base == 0 && s[0] == '0')
  80107c:	85 f6                	test   %esi,%esi
  80107e:	66 90                	xchg   %ax,%ax
  801080:	75 10                	jne    801092 <strtol+0x89>
  801082:	80 3b 30             	cmpb   $0x30,(%ebx)
  801085:	75 0b                	jne    801092 <strtol+0x89>
		s++, base = 8;
  801087:	83 c3 01             	add    $0x1,%ebx
  80108a:	66 be 08 00          	mov    $0x8,%si
  80108e:	66 90                	xchg   %ax,%ax
  801090:	eb 09                	jmp    80109b <strtol+0x92>
	else if (base == 0)
  801092:	84 c0                	test   %al,%al
  801094:	74 05                	je     80109b <strtol+0x92>
  801096:	be 0a 00 00 00       	mov    $0xa,%esi
  80109b:	bf 00 00 00 00       	mov    $0x0,%edi
		base = 10;

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010a0:	0f b6 13             	movzbl (%ebx),%edx
  8010a3:	89 d1                	mov    %edx,%ecx
  8010a5:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  8010a8:	3c 09                	cmp    $0x9,%al
  8010aa:	77 08                	ja     8010b4 <strtol+0xab>
			dig = *s - '0';
  8010ac:	0f be c2             	movsbl %dl,%eax
  8010af:	8d 50 d0             	lea    0xffffffd0(%eax),%edx
  8010b2:	eb 1c                	jmp    8010d0 <strtol+0xc7>
		else if (*s >= 'a' && *s <= 'z')
  8010b4:	8d 41 9f             	lea    0xffffff9f(%ecx),%eax
  8010b7:	3c 19                	cmp    $0x19,%al
  8010b9:	77 08                	ja     8010c3 <strtol+0xba>
			dig = *s - 'a' + 10;
  8010bb:	0f be c2             	movsbl %dl,%eax
  8010be:	8d 50 a9             	lea    0xffffffa9(%eax),%edx
  8010c1:	eb 0d                	jmp    8010d0 <strtol+0xc7>
		else if (*s >= 'A' && *s <= 'Z')
  8010c3:	8d 41 bf             	lea    0xffffffbf(%ecx),%eax
  8010c6:	3c 19                	cmp    $0x19,%al
  8010c8:	77 17                	ja     8010e1 <strtol+0xd8>
			dig = *s - 'A' + 10;
  8010ca:	0f be c2             	movsbl %dl,%eax
  8010cd:	8d 50 c9             	lea    0xffffffc9(%eax),%edx
		else
			break;
		if (dig >= base)
  8010d0:	39 f2                	cmp    %esi,%edx
  8010d2:	7d 0d                	jge    8010e1 <strtol+0xd8>
			break;
		s++, val = (val * base) + dig;
  8010d4:	83 c3 01             	add    $0x1,%ebx
  8010d7:	89 f8                	mov    %edi,%eax
  8010d9:	0f af c6             	imul   %esi,%eax
  8010dc:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  8010df:	eb bf                	jmp    8010a0 <strtol+0x97>
		// we don't properly detect overflow!
	}
  8010e1:	89 f8                	mov    %edi,%eax

	if (endptr)
  8010e3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8010e7:	74 05                	je     8010ee <strtol+0xe5>
		*endptr = (char *) s;
  8010e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ec:	89 1a                	mov    %ebx,(%edx)
	return (neg ? -val : val);
  8010ee:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8010f2:	74 04                	je     8010f8 <strtol+0xef>
  8010f4:	89 c7                	mov    %eax,%edi
  8010f6:	f7 df                	neg    %edi
}
  8010f8:	89 f8                	mov    %edi,%eax
  8010fa:	83 c4 04             	add    $0x4,%esp
  8010fd:	5b                   	pop    %ebx
  8010fe:	5e                   	pop    %esi
  8010ff:	5f                   	pop    %edi
  801100:	5d                   	pop    %ebp
  801101:	c3                   	ret    
	...

00801104 <sys_cgetc>:
}

int
sys_cgetc(void)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	83 ec 0c             	sub    $0xc,%esp
  80110a:	89 1c 24             	mov    %ebx,(%esp)
  80110d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801111:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801115:	b8 01 00 00 00       	mov    $0x1,%eax
  80111a:	bf 00 00 00 00       	mov    $0x0,%edi
  80111f:	89 fa                	mov    %edi,%edx
  801121:	89 f9                	mov    %edi,%ecx
  801123:	89 fb                	mov    %edi,%ebx
  801125:	89 fe                	mov    %edi,%esi
  801127:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801129:	8b 1c 24             	mov    (%esp),%ebx
  80112c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801130:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801134:	89 ec                	mov    %ebp,%esp
  801136:	5d                   	pop    %ebp
  801137:	c3                   	ret    

00801138 <sys_cputs>:
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	83 ec 0c             	sub    $0xc,%esp
  80113e:	89 1c 24             	mov    %ebx,(%esp)
  801141:	89 74 24 04          	mov    %esi,0x4(%esp)
  801145:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801149:	8b 55 08             	mov    0x8(%ebp),%edx
  80114c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80114f:	bf 00 00 00 00       	mov    $0x0,%edi
  801154:	89 f8                	mov    %edi,%eax
  801156:	89 fb                	mov    %edi,%ebx
  801158:	89 fe                	mov    %edi,%esi
  80115a:	cd 30                	int    $0x30
  80115c:	8b 1c 24             	mov    (%esp),%ebx
  80115f:	8b 74 24 04          	mov    0x4(%esp),%esi
  801163:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801167:	89 ec                	mov    %ebp,%esp
  801169:	5d                   	pop    %ebp
  80116a:	c3                   	ret    

0080116b <sys_time_msec>:

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
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
  80116e:	83 ec 0c             	sub    $0xc,%esp
  801171:	89 1c 24             	mov    %ebx,(%esp)
  801174:	89 74 24 04          	mov    %esi,0x4(%esp)
  801178:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80117c:	b8 0e 00 00 00       	mov    $0xe,%eax
  801181:	bf 00 00 00 00       	mov    $0x0,%edi
  801186:	89 fa                	mov    %edi,%edx
  801188:	89 f9                	mov    %edi,%ecx
  80118a:	89 fb                	mov    %edi,%ebx
  80118c:	89 fe                	mov    %edi,%esi
  80118e:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801190:	8b 1c 24             	mov    (%esp),%ebx
  801193:	8b 74 24 04          	mov    0x4(%esp),%esi
  801197:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80119b:	89 ec                	mov    %ebp,%esp
  80119d:	5d                   	pop    %ebp
  80119e:	c3                   	ret    

0080119f <sys_ipc_recv>:
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
  8011a2:	83 ec 28             	sub    $0x28,%esp
  8011a5:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  8011a8:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  8011ab:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  8011ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8011b6:	bf 00 00 00 00       	mov    $0x0,%edi
  8011bb:	89 f9                	mov    %edi,%ecx
  8011bd:	89 fb                	mov    %edi,%ebx
  8011bf:	89 fe                	mov    %edi,%esi
  8011c1:	cd 30                	int    $0x30
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	7e 28                	jle    8011ef <sys_ipc_recv+0x50>
  8011c7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011cb:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8011d2:	00 
  8011d3:	c7 44 24 08 ff 34 80 	movl   $0x8034ff,0x8(%esp)
  8011da:	00 
  8011db:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011e2:	00 
  8011e3:	c7 04 24 1c 35 80 00 	movl   $0x80351c,(%esp)
  8011ea:	e8 9d f3 ff ff       	call   80058c <_panic>
  8011ef:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  8011f2:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  8011f5:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  8011f8:	89 ec                	mov    %ebp,%esp
  8011fa:	5d                   	pop    %ebp
  8011fb:	c3                   	ret    

008011fc <sys_ipc_try_send>:
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	83 ec 0c             	sub    $0xc,%esp
  801202:	89 1c 24             	mov    %ebx,(%esp)
  801205:	89 74 24 04          	mov    %esi,0x4(%esp)
  801209:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80120d:	8b 55 08             	mov    0x8(%ebp),%edx
  801210:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801213:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801216:	8b 7d 14             	mov    0x14(%ebp),%edi
  801219:	b8 0c 00 00 00       	mov    $0xc,%eax
  80121e:	be 00 00 00 00       	mov    $0x0,%esi
  801223:	cd 30                	int    $0x30
  801225:	8b 1c 24             	mov    (%esp),%ebx
  801228:	8b 74 24 04          	mov    0x4(%esp),%esi
  80122c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801230:	89 ec                	mov    %ebp,%esp
  801232:	5d                   	pop    %ebp
  801233:	c3                   	ret    

00801234 <sys_env_set_pgfault_upcall>:
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	83 ec 28             	sub    $0x28,%esp
  80123a:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  80123d:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  801240:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801243:	8b 55 08             	mov    0x8(%ebp),%edx
  801246:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801249:	b8 0a 00 00 00       	mov    $0xa,%eax
  80124e:	bf 00 00 00 00       	mov    $0x0,%edi
  801253:	89 fb                	mov    %edi,%ebx
  801255:	89 fe                	mov    %edi,%esi
  801257:	cd 30                	int    $0x30
  801259:	85 c0                	test   %eax,%eax
  80125b:	7e 28                	jle    801285 <sys_env_set_pgfault_upcall+0x51>
  80125d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801261:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801268:	00 
  801269:	c7 44 24 08 ff 34 80 	movl   $0x8034ff,0x8(%esp)
  801270:	00 
  801271:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801278:	00 
  801279:	c7 04 24 1c 35 80 00 	movl   $0x80351c,(%esp)
  801280:	e8 07 f3 ff ff       	call   80058c <_panic>
  801285:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801288:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  80128b:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  80128e:	89 ec                	mov    %ebp,%esp
  801290:	5d                   	pop    %ebp
  801291:	c3                   	ret    

00801292 <sys_env_set_trapframe>:
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	83 ec 28             	sub    $0x28,%esp
  801298:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  80129b:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  80129e:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  8012a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a7:	b8 09 00 00 00       	mov    $0x9,%eax
  8012ac:	bf 00 00 00 00       	mov    $0x0,%edi
  8012b1:	89 fb                	mov    %edi,%ebx
  8012b3:	89 fe                	mov    %edi,%esi
  8012b5:	cd 30                	int    $0x30
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	7e 28                	jle    8012e3 <sys_env_set_trapframe+0x51>
  8012bb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012bf:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8012c6:	00 
  8012c7:	c7 44 24 08 ff 34 80 	movl   $0x8034ff,0x8(%esp)
  8012ce:	00 
  8012cf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012d6:	00 
  8012d7:	c7 04 24 1c 35 80 00 	movl   $0x80351c,(%esp)
  8012de:	e8 a9 f2 ff ff       	call   80058c <_panic>
  8012e3:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  8012e6:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  8012e9:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  8012ec:	89 ec                	mov    %ebp,%esp
  8012ee:	5d                   	pop    %ebp
  8012ef:	c3                   	ret    

008012f0 <sys_env_set_status>:
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	83 ec 28             	sub    $0x28,%esp
  8012f6:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  8012f9:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  8012fc:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  8012ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801302:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801305:	b8 08 00 00 00       	mov    $0x8,%eax
  80130a:	bf 00 00 00 00       	mov    $0x0,%edi
  80130f:	89 fb                	mov    %edi,%ebx
  801311:	89 fe                	mov    %edi,%esi
  801313:	cd 30                	int    $0x30
  801315:	85 c0                	test   %eax,%eax
  801317:	7e 28                	jle    801341 <sys_env_set_status+0x51>
  801319:	89 44 24 10          	mov    %eax,0x10(%esp)
  80131d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801324:	00 
  801325:	c7 44 24 08 ff 34 80 	movl   $0x8034ff,0x8(%esp)
  80132c:	00 
  80132d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801334:	00 
  801335:	c7 04 24 1c 35 80 00 	movl   $0x80351c,(%esp)
  80133c:	e8 4b f2 ff ff       	call   80058c <_panic>
  801341:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801344:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801347:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  80134a:	89 ec                	mov    %ebp,%esp
  80134c:	5d                   	pop    %ebp
  80134d:	c3                   	ret    

0080134e <sys_page_unmap>:
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	83 ec 28             	sub    $0x28,%esp
  801354:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801357:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  80135a:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  80135d:	8b 55 08             	mov    0x8(%ebp),%edx
  801360:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801363:	b8 06 00 00 00       	mov    $0x6,%eax
  801368:	bf 00 00 00 00       	mov    $0x0,%edi
  80136d:	89 fb                	mov    %edi,%ebx
  80136f:	89 fe                	mov    %edi,%esi
  801371:	cd 30                	int    $0x30
  801373:	85 c0                	test   %eax,%eax
  801375:	7e 28                	jle    80139f <sys_page_unmap+0x51>
  801377:	89 44 24 10          	mov    %eax,0x10(%esp)
  80137b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801382:	00 
  801383:	c7 44 24 08 ff 34 80 	movl   $0x8034ff,0x8(%esp)
  80138a:	00 
  80138b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801392:	00 
  801393:	c7 04 24 1c 35 80 00 	movl   $0x80351c,(%esp)
  80139a:	e8 ed f1 ff ff       	call   80058c <_panic>
  80139f:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  8013a2:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  8013a5:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  8013a8:	89 ec                	mov    %ebp,%esp
  8013aa:	5d                   	pop    %ebp
  8013ab:	c3                   	ret    

008013ac <sys_page_map>:
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	83 ec 28             	sub    $0x28,%esp
  8013b2:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  8013b5:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  8013b8:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  8013bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8013be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8013c7:	8b 75 18             	mov    0x18(%ebp),%esi
  8013ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8013cf:	cd 30                	int    $0x30
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	7e 28                	jle    8013fd <sys_page_map+0x51>
  8013d5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013d9:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8013e0:	00 
  8013e1:	c7 44 24 08 ff 34 80 	movl   $0x8034ff,0x8(%esp)
  8013e8:	00 
  8013e9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013f0:	00 
  8013f1:	c7 04 24 1c 35 80 00 	movl   $0x80351c,(%esp)
  8013f8:	e8 8f f1 ff ff       	call   80058c <_panic>
  8013fd:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801400:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801403:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801406:	89 ec                	mov    %ebp,%esp
  801408:	5d                   	pop    %ebp
  801409:	c3                   	ret    

0080140a <sys_page_alloc>:
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	83 ec 28             	sub    $0x28,%esp
  801410:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801413:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  801416:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801419:	8b 55 08             	mov    0x8(%ebp),%edx
  80141c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80141f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801422:	b8 04 00 00 00       	mov    $0x4,%eax
  801427:	bf 00 00 00 00       	mov    $0x0,%edi
  80142c:	89 fe                	mov    %edi,%esi
  80142e:	cd 30                	int    $0x30
  801430:	85 c0                	test   %eax,%eax
  801432:	7e 28                	jle    80145c <sys_page_alloc+0x52>
  801434:	89 44 24 10          	mov    %eax,0x10(%esp)
  801438:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80143f:	00 
  801440:	c7 44 24 08 ff 34 80 	movl   $0x8034ff,0x8(%esp)
  801447:	00 
  801448:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80144f:	00 
  801450:	c7 04 24 1c 35 80 00 	movl   $0x80351c,(%esp)
  801457:	e8 30 f1 ff ff       	call   80058c <_panic>
  80145c:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  80145f:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801462:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801465:	89 ec                	mov    %ebp,%esp
  801467:	5d                   	pop    %ebp
  801468:	c3                   	ret    

00801469 <sys_yield>:
  801469:	55                   	push   %ebp
  80146a:	89 e5                	mov    %esp,%ebp
  80146c:	83 ec 0c             	sub    $0xc,%esp
  80146f:	89 1c 24             	mov    %ebx,(%esp)
  801472:	89 74 24 04          	mov    %esi,0x4(%esp)
  801476:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80147a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80147f:	bf 00 00 00 00       	mov    $0x0,%edi
  801484:	89 fa                	mov    %edi,%edx
  801486:	89 f9                	mov    %edi,%ecx
  801488:	89 fb                	mov    %edi,%ebx
  80148a:	89 fe                	mov    %edi,%esi
  80148c:	cd 30                	int    $0x30
  80148e:	8b 1c 24             	mov    (%esp),%ebx
  801491:	8b 74 24 04          	mov    0x4(%esp),%esi
  801495:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801499:	89 ec                	mov    %ebp,%esp
  80149b:	5d                   	pop    %ebp
  80149c:	c3                   	ret    

0080149d <sys_getenvid>:
  80149d:	55                   	push   %ebp
  80149e:	89 e5                	mov    %esp,%ebp
  8014a0:	83 ec 0c             	sub    $0xc,%esp
  8014a3:	89 1c 24             	mov    %ebx,(%esp)
  8014a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014aa:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8014ae:	b8 02 00 00 00       	mov    $0x2,%eax
  8014b3:	bf 00 00 00 00       	mov    $0x0,%edi
  8014b8:	89 fa                	mov    %edi,%edx
  8014ba:	89 f9                	mov    %edi,%ecx
  8014bc:	89 fb                	mov    %edi,%ebx
  8014be:	89 fe                	mov    %edi,%esi
  8014c0:	cd 30                	int    $0x30
  8014c2:	8b 1c 24             	mov    (%esp),%ebx
  8014c5:	8b 74 24 04          	mov    0x4(%esp),%esi
  8014c9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8014cd:	89 ec                	mov    %ebp,%esp
  8014cf:	5d                   	pop    %ebp
  8014d0:	c3                   	ret    

008014d1 <sys_env_destroy>:
  8014d1:	55                   	push   %ebp
  8014d2:	89 e5                	mov    %esp,%ebp
  8014d4:	83 ec 28             	sub    $0x28,%esp
  8014d7:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  8014da:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  8014dd:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  8014e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8014e3:	b8 03 00 00 00       	mov    $0x3,%eax
  8014e8:	bf 00 00 00 00       	mov    $0x0,%edi
  8014ed:	89 f9                	mov    %edi,%ecx
  8014ef:	89 fb                	mov    %edi,%ebx
  8014f1:	89 fe                	mov    %edi,%esi
  8014f3:	cd 30                	int    $0x30
  8014f5:	85 c0                	test   %eax,%eax
  8014f7:	7e 28                	jle    801521 <sys_env_destroy+0x50>
  8014f9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014fd:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801504:	00 
  801505:	c7 44 24 08 ff 34 80 	movl   $0x8034ff,0x8(%esp)
  80150c:	00 
  80150d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801514:	00 
  801515:	c7 04 24 1c 35 80 00 	movl   $0x80351c,(%esp)
  80151c:	e8 6b f0 ff ff       	call   80058c <_panic>
  801521:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801524:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801527:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  80152a:	89 ec                	mov    %ebp,%esp
  80152c:	5d                   	pop    %ebp
  80152d:	c3                   	ret    
	...

00801530 <duppage>:
// It is also OK to panic on error.
// 
static int
duppage(envid_t envid, unsigned pn)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	53                   	push   %ebx
  801534:	83 ec 14             	sub    $0x14,%esp
  801537:	89 c1                	mov    %eax,%ecx
	int r;

	// LAB 4: Your code here.
	pde_t *pde;
	pte_t *pte;
	void *addr=(void*)(pn*PGSIZE);
  801539:	89 d3                	mov    %edx,%ebx
  80153b:	c1 e3 0c             	shl    $0xc,%ebx
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
  80153e:	89 d8                	mov    %ebx,%eax
  801540:	c1 e8 16             	shr    $0x16,%eax
  801543:	f6 04 85 00 d0 7b ef 	testb  $0x1,0xef7bd000(,%eax,4)
  80154a:	01 
  80154b:	74 14                	je     801561 <duppage+0x31>
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else    panic("page table for pn page is not exist");
	if((*pte&PTE_W)||(*pte&PTE_COW))
  80154d:	89 d8                	mov    %ebx,%eax
  80154f:	c1 e8 0c             	shr    $0xc,%eax
  801552:	f7 04 85 00 00 40 ef 	testl  $0x802,0xef400000(,%eax,4)
  801559:	02 08 00 00 
  80155d:	75 1e                	jne    80157d <duppage+0x4d>
  80155f:	eb 73                	jmp    8015d4 <duppage+0xa4>
  801561:	c7 44 24 08 2c 35 80 	movl   $0x80352c,0x8(%esp)
  801568:	00 
  801569:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
  801570:	00 
  801571:	c7 04 24 ea 35 80 00 	movl   $0x8035ea,(%esp)
  801578:	e8 0f f0 ff ff       	call   80058c <_panic>
	{
		if((r=sys_page_map(0,addr,envid,addr,PTE_COW|PTE_U))<0)
  80157d:	c7 44 24 10 04 08 00 	movl   $0x804,0x10(%esp)
  801584:	00 
  801585:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801589:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80158d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801591:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801598:	e8 0f fe ff ff       	call   8013ac <sys_page_map>
  80159d:	85 c0                	test   %eax,%eax
  80159f:	78 60                	js     801601 <duppage+0xd1>
			return r;
		if((r=sys_page_map(0,addr,0,addr,PTE_COW|PTE_U))<0)//映射的时候注意env的id
  8015a1:	c7 44 24 10 04 08 00 	movl   $0x804,0x10(%esp)
  8015a8:	00 
  8015a9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8015ad:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015b4:	00 
  8015b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015c0:	e8 e7 fd ff ff       	call   8013ac <sys_page_map>
  8015c5:	85 c0                	test   %eax,%eax
  8015c7:	0f 9f c2             	setg   %dl
  8015ca:	0f b6 d2             	movzbl %dl,%edx
  8015cd:	83 ea 01             	sub    $0x1,%edx
  8015d0:	21 d0                	and    %edx,%eax
  8015d2:	eb 2d                	jmp    801601 <duppage+0xd1>
                        return r;
	}
	else{	
		if((r=sys_page_map(0,addr,envid,addr,PTE_U|PTE_P))<0)
  8015d4:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8015db:	00 
  8015dc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8015e0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015ef:	e8 b8 fd ff ff       	call   8013ac <sys_page_map>
  8015f4:	85 c0                	test   %eax,%eax
  8015f6:	0f 9f c2             	setg   %dl
  8015f9:	0f b6 d2             	movzbl %dl,%edx
  8015fc:	83 ea 01             	sub    $0x1,%edx
  8015ff:	21 d0                	and    %edx,%eax
			return r;
	}
	//panic("duppage not implemented");
	return 0;
}
  801601:	83 c4 14             	add    $0x14,%esp
  801604:	5b                   	pop    %ebx
  801605:	5d                   	pop    %ebp
  801606:	c3                   	ret    

00801607 <sfork>:

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use vpd, vpt, and duppage.
//   Remember to fix "env" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
	// LAB 4: Your code here.	
	int r;
	pde_t *pde;
	pte_t *pte;
	unsigned i;
	uint32_t addr;
	envid_t envid;
	envid = sys_exofork();//创建子环境
	if(envid < 0)
		panic("sys_exofork: %e", envid);
	if(envid==0)//子环境中
	{
		env = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	else{//父环境中
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
		{
			if(i==(unsigned)VPN(UXSTACKTOP-PGSIZE))//特殊处理，用户层缺页异常栈
				continue;
			addr=i*PGSIZE;
			pde =(pde_t*) &vpd[VPD(addr)];
			if(*pde&PTE_P)//这里只处理有物理页面映射的页表项
			{
				pte=(pte_t*)&vpt[VPN(addr)];
			}
			else    continue;
			if((*pte&PTE_W)||(*pte&PTE_COW))
			{
				if((r=duppage(envid,i))<0)
					return r;
			}
		}
		if((r=sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
			return r;//设置子环境的缺页异常栈
		if((r=sys_env_set_pgfault_upcall(envid,(void*)_pgfault_upcall))<0)
			return r;//设置子环境的缺页异常处理入口点
		if((r=sys_env_set_status(envid,ENV_RUNNABLE))<0)
			return r;//设置子环境的状态为可运行
		return envid;
	}
	//panic("fork not implemented");
}
static int
sduppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	pde_t *pde;
	pte_t *pte;
	void *addr=(void*)(pn*PGSIZE);
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else    panic("page table for pn page is not exist");
	if(*pte&PTE_W)
	{
		//cprintf("sduppage:addr=%x\n",addr);
		if((r=sys_page_map(0,addr,envid,addr,PTE_W|PTE_U))<0)
			return r;
		if((r=sys_page_map(0,addr,0,addr,PTE_W|PTE_U))<0)//映射的时候注意env的id
                        return r;
	}
	else{	
		if((r=sys_page_map(0,addr,envid,addr,PTE_U|PTE_P))<0)
			return r;
	}
	//panic("duppage not implemented");
	return 0;
}
// Challenge!
int
sfork(void)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	57                   	push   %edi
  80160b:	56                   	push   %esi
  80160c:	53                   	push   %ebx
  80160d:	83 ec 1c             	sub    $0x1c,%esp
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801610:	ba 07 00 00 00       	mov    $0x7,%edx
  801615:	89 d0                	mov    %edx,%eax
  801617:	cd 30                	int    $0x30
  801619:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
	int r;
	pde_t *pde;
	pte_t *pte;
	unsigned i;
	uint32_t addr;
	envid_t envid;
	envid = sys_exofork();//创建子环境
	if(envid < 0)
  80161c:	85 c0                	test   %eax,%eax
  80161e:	79 20                	jns    801640 <sfork+0x39>
		panic("sys_exofork: %e", envid);
  801620:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801624:	c7 44 24 08 f5 35 80 	movl   $0x8035f5,0x8(%esp)
  80162b:	00 
  80162c:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  801633:	00 
  801634:	c7 04 24 ea 35 80 00 	movl   $0x8035ea,(%esp)
  80163b:	e8 4c ef ff ff       	call   80058c <_panic>
	if(envid==0)//子环境中
  801640:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  801644:	75 21                	jne    801667 <sfork+0x60>
	{
		env = &envs[ENVX(sys_getenvid())];
  801646:	e8 52 fe ff ff       	call   80149d <sys_getenvid>
  80164b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801650:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801653:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801658:	a3 54 70 80 00       	mov    %eax,0x807054
  80165d:	b8 00 00 00 00       	mov    $0x0,%eax
  801662:	e9 83 01 00 00       	jmp    8017ea <sfork+0x1e3>
		return 0;
	}
	else{//父环境中,注意：这里需要设置父环境的缺页异常栈，还需要设置子环境的缺页异常栈，
	//父子环境的页异常栈不共享？具体原因还得思考
		env = &envs[ENVX(sys_getenvid())];
  801667:	e8 31 fe ff ff       	call   80149d <sys_getenvid>
  80166c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801671:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801674:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801679:	a3 54 70 80 00       	mov    %eax,0x807054
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
  80167e:	c7 04 24 f2 17 80 00 	movl   $0x8017f2,(%esp)
  801685:	e8 6e 13 00 00       	call   8029f8 <set_pgfault_handler>
  80168a:	be 00 00 00 00       	mov    $0x0,%esi
  80168f:	bf 00 00 00 00       	mov    $0x0,%edi
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
		{
			addr=i*PGSIZE;
			pde =(pde_t*) &vpd[VPD(addr)];
  801694:	89 f8                	mov    %edi,%eax
  801696:	c1 e8 16             	shr    $0x16,%eax
  801699:	c1 e0 02             	shl    $0x2,%eax
			if(*pde&PTE_P)//这里只处理有物理页面映射的页表项
  80169c:	f6 80 00 d0 7b ef 01 	testb  $0x1,0xef7bd000(%eax)
  8016a3:	0f 84 dc 00 00 00    	je     801785 <sfork+0x17e>
			{
				pte=(pte_t*)&vpt[VPN(addr)];
			}
			else    continue;
			if((i==(unsigned)VPN(USTACKTOP-PGSIZE))||(i==(unsigned)VPN(PFTEMP)))
  8016a9:	81 fe fd eb 0e 00    	cmp    $0xeebfd,%esi
  8016af:	74 08                	je     8016b9 <sfork+0xb2>
  8016b1:	81 fe ff 07 00 00    	cmp    $0x7ff,%esi
  8016b7:	75 17                	jne    8016d0 <sfork+0xc9>
								//特殊处理，用户层普通栈
			{	
				if((r=duppage(envid,i))<0)
  8016b9:	89 f2                	mov    %esi,%edx
  8016bb:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8016be:	e8 6d fe ff ff       	call   801530 <duppage>
  8016c3:	85 c0                	test   %eax,%eax
  8016c5:	0f 89 ba 00 00 00    	jns    801785 <sfork+0x17e>
  8016cb:	e9 1a 01 00 00       	jmp    8017ea <sfork+0x1e3>
  8016d0:	f6 80 00 d0 7b ef 01 	testb  $0x1,0xef7bd000(%eax)
  8016d7:	74 11                	je     8016ea <sfork+0xe3>
  8016d9:	89 f8                	mov    %edi,%eax
  8016db:	c1 e8 0c             	shr    $0xc,%eax
  8016de:	f6 04 85 00 00 40 ef 	testb  $0x2,0xef400000(,%eax,4)
  8016e5:	02 
  8016e6:	75 1e                	jne    801706 <sfork+0xff>
  8016e8:	eb 74                	jmp    80175e <sfork+0x157>
  8016ea:	c7 44 24 08 2c 35 80 	movl   $0x80352c,0x8(%esp)
  8016f1:	00 
  8016f2:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
  8016f9:	00 
  8016fa:	c7 04 24 ea 35 80 00 	movl   $0x8035ea,(%esp)
  801701:	e8 86 ee ff ff       	call   80058c <_panic>
  801706:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
  80170d:	00 
  80170e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801712:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  801715:	89 44 24 08          	mov    %eax,0x8(%esp)
  801719:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80171d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801724:	e8 83 fc ff ff       	call   8013ac <sys_page_map>
  801729:	85 c0                	test   %eax,%eax
  80172b:	0f 88 b9 00 00 00    	js     8017ea <sfork+0x1e3>
  801731:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
  801738:	00 
  801739:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80173d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801744:	00 
  801745:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801749:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801750:	e8 57 fc ff ff       	call   8013ac <sys_page_map>
  801755:	85 c0                	test   %eax,%eax
  801757:	79 2c                	jns    801785 <sfork+0x17e>
  801759:	e9 8c 00 00 00       	jmp    8017ea <sfork+0x1e3>
  80175e:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801765:	00 
  801766:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80176a:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80176d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801771:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801775:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80177c:	e8 2b fc ff ff       	call   8013ac <sys_page_map>
  801781:	85 c0                	test   %eax,%eax
  801783:	78 65                	js     8017ea <sfork+0x1e3>
  801785:	83 c6 01             	add    $0x1,%esi
  801788:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80178e:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  801794:	0f 85 fa fe ff ff    	jne    801694 <sfork+0x8d>
					return r;
				continue;
			}
			if((r=sduppage(envid,i))<0)
				return r;
		}
		if((r=sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  80179a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8017a1:	00 
  8017a2:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8017a9:	ee 
  8017aa:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8017ad:	89 04 24             	mov    %eax,(%esp)
  8017b0:	e8 55 fc ff ff       	call   80140a <sys_page_alloc>
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	78 31                	js     8017ea <sfork+0x1e3>
                        return r;//设置子环境的缺页异常栈
		if((r=sys_env_set_pgfault_upcall(envid,(void*)_pgfault_upcall))<0)
  8017b9:	c7 44 24 04 7c 2a 80 	movl   $0x802a7c,0x4(%esp)
  8017c0:	00 
  8017c1:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8017c4:	89 04 24             	mov    %eax,(%esp)
  8017c7:	e8 68 fa ff ff       	call   801234 <sys_env_set_pgfault_upcall>
  8017cc:	85 c0                	test   %eax,%eax
  8017ce:	78 1a                	js     8017ea <sfork+0x1e3>
			return r;//设置子环境的缺页异常处理入口点
		if((r=sys_env_set_status(envid,ENV_RUNNABLE))<0)
  8017d0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8017d7:	00 
  8017d8:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8017db:	89 04 24             	mov    %eax,(%esp)
  8017de:	e8 0d fb ff ff       	call   8012f0 <sys_env_set_status>
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	78 03                	js     8017ea <sfork+0x1e3>
  8017e7:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
			return r;//设置子环境的状态为可运行
		return envid;
	}
	//panic("sfork not implemented");
	//return -E_INVAL;
}
  8017ea:	83 c4 1c             	add    $0x1c,%esp
  8017ed:	5b                   	pop    %ebx
  8017ee:	5e                   	pop    %esi
  8017ef:	5f                   	pop    %edi
  8017f0:	5d                   	pop    %ebp
  8017f1:	c3                   	ret    

008017f2 <pgfault>:
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	56                   	push   %esi
  8017f6:	53                   	push   %ebx
  8017f7:	83 ec 20             	sub    $0x20,%esp
  8017fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017fd:	8b 71 04             	mov    0x4(%ecx),%esi
  801800:	8b 19                	mov    (%ecx),%ebx
  801802:	89 d8                	mov    %ebx,%eax
  801804:	c1 e8 16             	shr    $0x16,%eax
  801807:	c1 e0 02             	shl    $0x2,%eax
  80180a:	8d 90 00 d0 7b ef    	lea    0xef7bd000(%eax),%edx
  801810:	f6 80 00 d0 7b ef 01 	testb  $0x1,0xef7bd000(%eax)
  801817:	74 16                	je     80182f <pgfault+0x3d>
  801819:	89 d8                	mov    %ebx,%eax
  80181b:	c1 e8 0c             	shr    $0xc,%eax
  80181e:	8d 04 85 00 00 40 ef 	lea    0xef400000(,%eax,4),%eax
  801825:	f7 c6 02 00 00 00    	test   $0x2,%esi
  80182b:	75 3f                	jne    80186c <pgfault+0x7a>
  80182d:	eb 43                	jmp    801872 <pgfault+0x80>
  80182f:	8b 41 28             	mov    0x28(%ecx),%eax
  801832:	8b 12                	mov    (%edx),%edx
  801834:	89 44 24 10          	mov    %eax,0x10(%esp)
  801838:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80183c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801840:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801844:	c7 04 24 50 35 80 00 	movl   $0x803550,(%esp)
  80184b:	e8 09 ee ff ff       	call   800659 <cprintf>
  801850:	c7 44 24 08 74 35 80 	movl   $0x803574,0x8(%esp)
  801857:	00 
  801858:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80185f:	00 
  801860:	c7 04 24 ea 35 80 00 	movl   $0x8035ea,(%esp)
  801867:	e8 20 ed ff ff       	call   80058c <_panic>
  80186c:	f6 40 01 08          	testb  $0x8,0x1(%eax)
  801870:	75 49                	jne    8018bb <pgfault+0xc9>
  801872:	8b 51 28             	mov    0x28(%ecx),%edx
  801875:	8b 08                	mov    (%eax),%ecx
  801877:	a1 54 70 80 00       	mov    0x807054,%eax
  80187c:	8b 40 4c             	mov    0x4c(%eax),%eax
  80187f:	89 54 24 14          	mov    %edx,0x14(%esp)
  801883:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801887:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80188b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80188f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801893:	c7 04 24 9c 35 80 00 	movl   $0x80359c,(%esp)
  80189a:	e8 ba ed ff ff       	call   800659 <cprintf>
  80189f:	c7 44 24 08 05 36 80 	movl   $0x803605,0x8(%esp)
  8018a6:	00 
  8018a7:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8018ae:	00 
  8018af:	c7 04 24 ea 35 80 00 	movl   $0x8035ea,(%esp)
  8018b6:	e8 d1 ec ff ff       	call   80058c <_panic>
  8018bb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8018c2:	00 
  8018c3:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8018ca:	00 
  8018cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018d2:	e8 33 fb ff ff       	call   80140a <sys_page_alloc>
  8018d7:	85 c0                	test   %eax,%eax
  8018d9:	79 20                	jns    8018fb <pgfault+0x109>
  8018db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018df:	c7 44 24 08 c8 35 80 	movl   $0x8035c8,0x8(%esp)
  8018e6:	00 
  8018e7:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8018ee:	00 
  8018ef:	c7 04 24 ea 35 80 00 	movl   $0x8035ea,(%esp)
  8018f6:	e8 91 ec ff ff       	call   80058c <_panic>
  8018fb:	89 de                	mov    %ebx,%esi
  8018fd:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801903:	89 f2                	mov    %esi,%edx
  801905:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  80190b:	89 c3                	mov    %eax,%ebx
  80190d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801913:	39 de                	cmp    %ebx,%esi
  801915:	73 13                	jae    80192a <pgfault+0x138>
  801917:	b9 00 f0 7f 00       	mov    $0x7ff000,%ecx
  80191c:	8b 02                	mov    (%edx),%eax
  80191e:	89 01                	mov    %eax,(%ecx)
  801920:	83 c1 04             	add    $0x4,%ecx
  801923:	83 c2 04             	add    $0x4,%edx
  801926:	39 d3                	cmp    %edx,%ebx
  801928:	77 f2                	ja     80191c <pgfault+0x12a>
  80192a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801931:	00 
  801932:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801936:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80193d:	00 
  80193e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801945:	00 
  801946:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80194d:	e8 5a fa ff ff       	call   8013ac <sys_page_map>
  801952:	85 c0                	test   %eax,%eax
  801954:	79 1c                	jns    801972 <pgfault+0x180>
  801956:	c7 44 24 08 20 36 80 	movl   $0x803620,0x8(%esp)
  80195d:	00 
  80195e:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801965:	00 
  801966:	c7 04 24 ea 35 80 00 	movl   $0x8035ea,(%esp)
  80196d:	e8 1a ec ff ff       	call   80058c <_panic>
  801972:	83 c4 20             	add    $0x20,%esp
  801975:	5b                   	pop    %ebx
  801976:	5e                   	pop    %esi
  801977:	5d                   	pop    %ebp
  801978:	c3                   	ret    

00801979 <fork>:
  801979:	55                   	push   %ebp
  80197a:	89 e5                	mov    %esp,%ebp
  80197c:	56                   	push   %esi
  80197d:	53                   	push   %ebx
  80197e:	83 ec 10             	sub    $0x10,%esp
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801981:	ba 07 00 00 00       	mov    $0x7,%edx
  801986:	89 d0                	mov    %edx,%eax
  801988:	cd 30                	int    $0x30
  80198a:	89 c6                	mov    %eax,%esi
  80198c:	85 c0                	test   %eax,%eax
  80198e:	79 20                	jns    8019b0 <fork+0x37>
  801990:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801994:	c7 44 24 08 f5 35 80 	movl   $0x8035f5,0x8(%esp)
  80199b:	00 
  80199c:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  8019a3:	00 
  8019a4:	c7 04 24 ea 35 80 00 	movl   $0x8035ea,(%esp)
  8019ab:	e8 dc eb ff ff       	call   80058c <_panic>
  8019b0:	85 c0                	test   %eax,%eax
  8019b2:	75 21                	jne    8019d5 <fork+0x5c>
  8019b4:	e8 e4 fa ff ff       	call   80149d <sys_getenvid>
  8019b9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8019be:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8019c1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8019c6:	a3 54 70 80 00       	mov    %eax,0x807054
  8019cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d0:	e9 9f 00 00 00       	jmp    801a74 <fork+0xfb>
  8019d5:	c7 04 24 f2 17 80 00 	movl   $0x8017f2,(%esp)
  8019dc:	e8 17 10 00 00       	call   8029f8 <set_pgfault_handler>
  8019e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019e6:	eb 08                	jmp    8019f0 <fork+0x77>
  8019e8:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  8019ee:	74 3e                	je     801a2e <fork+0xb5>
  8019f0:	89 da                	mov    %ebx,%edx
  8019f2:	c1 e2 0c             	shl    $0xc,%edx
  8019f5:	89 d0                	mov    %edx,%eax
  8019f7:	c1 e8 16             	shr    $0x16,%eax
  8019fa:	f6 04 85 00 d0 7b ef 	testb  $0x1,0xef7bd000(,%eax,4)
  801a01:	01 
  801a02:	74 1f                	je     801a23 <fork+0xaa>
  801a04:	89 d0                	mov    %edx,%eax
  801a06:	c1 e8 0c             	shr    $0xc,%eax
  801a09:	f7 04 85 00 00 40 ef 	testl  $0x802,0xef400000(,%eax,4)
  801a10:	02 08 00 00 
  801a14:	74 0d                	je     801a23 <fork+0xaa>
  801a16:	89 da                	mov    %ebx,%edx
  801a18:	89 f0                	mov    %esi,%eax
  801a1a:	e8 11 fb ff ff       	call   801530 <duppage>
  801a1f:	85 c0                	test   %eax,%eax
  801a21:	78 51                	js     801a74 <fork+0xfb>
  801a23:	83 c3 01             	add    $0x1,%ebx
  801a26:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  801a2c:	75 ba                	jne    8019e8 <fork+0x6f>
  801a2e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801a35:	00 
  801a36:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801a3d:	ee 
  801a3e:	89 34 24             	mov    %esi,(%esp)
  801a41:	e8 c4 f9 ff ff       	call   80140a <sys_page_alloc>
  801a46:	85 c0                	test   %eax,%eax
  801a48:	78 2a                	js     801a74 <fork+0xfb>
  801a4a:	c7 44 24 04 7c 2a 80 	movl   $0x802a7c,0x4(%esp)
  801a51:	00 
  801a52:	89 34 24             	mov    %esi,(%esp)
  801a55:	e8 da f7 ff ff       	call   801234 <sys_env_set_pgfault_upcall>
  801a5a:	85 c0                	test   %eax,%eax
  801a5c:	78 16                	js     801a74 <fork+0xfb>
  801a5e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a65:	00 
  801a66:	89 34 24             	mov    %esi,(%esp)
  801a69:	e8 82 f8 ff ff       	call   8012f0 <sys_env_set_status>
  801a6e:	85 c0                	test   %eax,%eax
  801a70:	78 02                	js     801a74 <fork+0xfb>
  801a72:	89 f0                	mov    %esi,%eax
  801a74:	83 c4 10             	add    $0x10,%esp
  801a77:	5b                   	pop    %ebx
  801a78:	5e                   	pop    %esi
  801a79:	5d                   	pop    %ebp
  801a7a:	c3                   	ret    
  801a7b:	00 00                	add    %al,(%eax)
  801a7d:	00 00                	add    %al,(%eax)
	...

00801a80 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	57                   	push   %edi
  801a84:	56                   	push   %esi
  801a85:	53                   	push   %ebx
  801a86:	83 ec 1c             	sub    $0x1c,%esp
  801a89:	8b 75 08             	mov    0x8(%ebp),%esi
  801a8c:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  801a8f:	e8 09 fa ff ff       	call   80149d <sys_getenvid>
  801a94:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a99:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a9c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801aa1:	a3 54 70 80 00       	mov    %eax,0x807054
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  801aa6:	e8 f2 f9 ff ff       	call   80149d <sys_getenvid>
  801aab:	25 ff 03 00 00       	and    $0x3ff,%eax
  801ab0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ab3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ab8:	a3 54 70 80 00       	mov    %eax,0x807054
		if(env->env_id==to_env){
  801abd:	8b 40 4c             	mov    0x4c(%eax),%eax
  801ac0:	39 f0                	cmp    %esi,%eax
  801ac2:	75 0e                	jne    801ad2 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  801ac4:	c7 04 24 34 36 80 00 	movl   $0x803634,(%esp)
  801acb:	e8 89 eb ff ff       	call   800659 <cprintf>
  801ad0:	eb 5a                	jmp    801b2c <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  801ad2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ad6:	8b 45 10             	mov    0x10(%ebp),%eax
  801ad9:	89 44 24 08          	mov    %eax,0x8(%esp)
  801add:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae4:	89 34 24             	mov    %esi,(%esp)
  801ae7:	e8 10 f7 ff ff       	call   8011fc <sys_ipc_try_send>
  801aec:	89 c3                	mov    %eax,%ebx
  801aee:	85 c0                	test   %eax,%eax
  801af0:	79 25                	jns    801b17 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  801af2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801af5:	74 2b                	je     801b22 <ipc_send+0xa2>
				panic("send error:%e",r);
  801af7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801afb:	c7 44 24 08 50 36 80 	movl   $0x803650,0x8(%esp)
  801b02:	00 
  801b03:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801b0a:	00 
  801b0b:	c7 04 24 5e 36 80 00 	movl   $0x80365e,(%esp)
  801b12:	e8 75 ea ff ff       	call   80058c <_panic>
		}
			sys_yield();
  801b17:	e8 4d f9 ff ff       	call   801469 <sys_yield>
		
	}while(r!=0);
  801b1c:	85 db                	test   %ebx,%ebx
  801b1e:	75 86                	jne    801aa6 <ipc_send+0x26>
  801b20:	eb 0a                	jmp    801b2c <ipc_send+0xac>
  801b22:	e8 42 f9 ff ff       	call   801469 <sys_yield>
  801b27:	e9 7a ff ff ff       	jmp    801aa6 <ipc_send+0x26>
	return;
	//panic("ipc_send not implemented");
}
  801b2c:	83 c4 1c             	add    $0x1c,%esp
  801b2f:	5b                   	pop    %ebx
  801b30:	5e                   	pop    %esi
  801b31:	5f                   	pop    %edi
  801b32:	5d                   	pop    %ebp
  801b33:	c3                   	ret    

00801b34 <ipc_recv>:
  801b34:	55                   	push   %ebp
  801b35:	89 e5                	mov    %esp,%ebp
  801b37:	57                   	push   %edi
  801b38:	56                   	push   %esi
  801b39:	53                   	push   %ebx
  801b3a:	83 ec 0c             	sub    $0xc,%esp
  801b3d:	8b 75 08             	mov    0x8(%ebp),%esi
  801b40:	8b 7d 10             	mov    0x10(%ebp),%edi
  801b43:	e8 55 f9 ff ff       	call   80149d <sys_getenvid>
  801b48:	25 ff 03 00 00       	and    $0x3ff,%eax
  801b4d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b50:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b55:	a3 54 70 80 00       	mov    %eax,0x807054
  801b5a:	85 f6                	test   %esi,%esi
  801b5c:	74 29                	je     801b87 <ipc_recv+0x53>
  801b5e:	8b 40 4c             	mov    0x4c(%eax),%eax
  801b61:	3b 06                	cmp    (%esi),%eax
  801b63:	75 22                	jne    801b87 <ipc_recv+0x53>
  801b65:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801b6b:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801b71:	c7 04 24 34 36 80 00 	movl   $0x803634,(%esp)
  801b78:	e8 dc ea ff ff       	call   800659 <cprintf>
  801b7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b82:	e9 8a 00 00 00       	jmp    801c11 <ipc_recv+0xdd>
  801b87:	e8 11 f9 ff ff       	call   80149d <sys_getenvid>
  801b8c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801b91:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b94:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b99:	a3 54 70 80 00       	mov    %eax,0x807054
  801b9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba1:	89 04 24             	mov    %eax,(%esp)
  801ba4:	e8 f6 f5 ff ff       	call   80119f <sys_ipc_recv>
  801ba9:	89 c3                	mov    %eax,%ebx
  801bab:	85 c0                	test   %eax,%eax
  801bad:	79 1a                	jns    801bc9 <ipc_recv+0x95>
  801baf:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801bb5:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801bbb:	c7 04 24 68 36 80 00 	movl   $0x803668,(%esp)
  801bc2:	e8 92 ea ff ff       	call   800659 <cprintf>
  801bc7:	eb 48                	jmp    801c11 <ipc_recv+0xdd>
  801bc9:	e8 cf f8 ff ff       	call   80149d <sys_getenvid>
  801bce:	25 ff 03 00 00       	and    $0x3ff,%eax
  801bd3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bd6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bdb:	a3 54 70 80 00       	mov    %eax,0x807054
  801be0:	85 f6                	test   %esi,%esi
  801be2:	74 05                	je     801be9 <ipc_recv+0xb5>
  801be4:	8b 40 74             	mov    0x74(%eax),%eax
  801be7:	89 06                	mov    %eax,(%esi)
  801be9:	85 ff                	test   %edi,%edi
  801beb:	74 0a                	je     801bf7 <ipc_recv+0xc3>
  801bed:	a1 54 70 80 00       	mov    0x807054,%eax
  801bf2:	8b 40 78             	mov    0x78(%eax),%eax
  801bf5:	89 07                	mov    %eax,(%edi)
  801bf7:	e8 a1 f8 ff ff       	call   80149d <sys_getenvid>
  801bfc:	25 ff 03 00 00       	and    $0x3ff,%eax
  801c01:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c04:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c09:	a3 54 70 80 00       	mov    %eax,0x807054
  801c0e:	8b 58 70             	mov    0x70(%eax),%ebx
  801c11:	89 d8                	mov    %ebx,%eax
  801c13:	83 c4 0c             	add    $0xc,%esp
  801c16:	5b                   	pop    %ebx
  801c17:	5e                   	pop    %esi
  801c18:	5f                   	pop    %edi
  801c19:	5d                   	pop    %ebp
  801c1a:	c3                   	ret    
  801c1b:	00 00                	add    %al,(%eax)
  801c1d:	00 00                	add    %al,(%eax)
	...

00801c20 <fd2num>:
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	8b 45 08             	mov    0x8(%ebp),%eax
  801c26:	05 00 00 00 30       	add    $0x30000000,%eax
  801c2b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  801c2e:	5d                   	pop    %ebp
  801c2f:	c3                   	ret    

00801c30 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801c30:	55                   	push   %ebp
  801c31:	89 e5                	mov    %esp,%ebp
  801c33:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801c36:	8b 45 08             	mov    0x8(%ebp),%eax
  801c39:	89 04 24             	mov    %eax,(%esp)
  801c3c:	e8 df ff ff ff       	call   801c20 <fd2num>
  801c41:	c1 e0 0c             	shl    $0xc,%eax
  801c44:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801c49:	c9                   	leave  
  801c4a:	c3                   	ret    

00801c4b <fd_alloc>:

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
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
  801c4e:	53                   	push   %ebx
  801c4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801c52:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801c57:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801c59:	89 d0                	mov    %edx,%eax
  801c5b:	c1 e8 16             	shr    $0x16,%eax
  801c5e:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  801c65:	a8 01                	test   $0x1,%al
  801c67:	74 10                	je     801c79 <fd_alloc+0x2e>
  801c69:	89 d0                	mov    %edx,%eax
  801c6b:	c1 e8 0c             	shr    $0xc,%eax
  801c6e:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  801c75:	a8 01                	test   $0x1,%al
  801c77:	75 09                	jne    801c82 <fd_alloc+0x37>
			*fd_store = fd;
  801c79:	89 0b                	mov    %ecx,(%ebx)
  801c7b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c80:	eb 19                	jmp    801c9b <fd_alloc+0x50>
			return 0;
  801c82:	81 c2 00 10 00 00    	add    $0x1000,%edx
  801c88:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  801c8e:	75 c7                	jne    801c57 <fd_alloc+0xc>
		}
	}
	*fd_store = 0;
  801c90:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801c96:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801c9b:	5b                   	pop    %ebx
  801c9c:	5d                   	pop    %ebp
  801c9d:	c3                   	ret    

00801c9e <fd_lookup>:

// Check that fdnum is in range and mapped.
// If it is, set *fd_store to the fd page virtual address.
//
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801c9e:	55                   	push   %ebp
  801c9f:	89 e5                	mov    %esp,%ebp
  801ca1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801ca4:	83 f8 1f             	cmp    $0x1f,%eax
  801ca7:	77 35                	ja     801cde <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801ca9:	c1 e0 0c             	shl    $0xc,%eax
  801cac:	8d 90 00 00 00 d0    	lea    0xd0000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  801cb2:	89 d0                	mov    %edx,%eax
  801cb4:	c1 e8 16             	shr    $0x16,%eax
  801cb7:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  801cbe:	a8 01                	test   $0x1,%al
  801cc0:	74 1c                	je     801cde <fd_lookup+0x40>
  801cc2:	89 d0                	mov    %edx,%eax
  801cc4:	c1 e8 0c             	shr    $0xc,%eax
  801cc7:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  801cce:	a8 01                	test   $0x1,%al
  801cd0:	74 0c                	je     801cde <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801cd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd5:	89 10                	mov    %edx,(%eax)
  801cd7:	b8 00 00 00 00       	mov    $0x0,%eax
  801cdc:	eb 05                	jmp    801ce3 <fd_lookup+0x45>
	return 0;
  801cde:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    

00801ce5 <seek>:

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
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ceb:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  801cee:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf5:	89 04 24             	mov    %eax,(%esp)
  801cf8:	e8 a1 ff ff ff       	call   801c9e <fd_lookup>
  801cfd:	85 c0                	test   %eax,%eax
  801cff:	78 0e                	js     801d0f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801d01:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d04:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  801d07:	89 50 04             	mov    %edx,0x4(%eax)
  801d0a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801d0f:	c9                   	leave  
  801d10:	c3                   	ret    

00801d11 <dev_lookup>:
  801d11:	55                   	push   %ebp
  801d12:	89 e5                	mov    %esp,%ebp
  801d14:	53                   	push   %ebx
  801d15:	83 ec 14             	sub    $0x14,%esp
  801d18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d1e:	ba 04 70 80 00       	mov    $0x807004,%edx
  801d23:	b8 00 00 00 00       	mov    $0x0,%eax
  801d28:	39 0d 04 70 80 00    	cmp    %ecx,0x807004
  801d2e:	75 12                	jne    801d42 <dev_lookup+0x31>
  801d30:	eb 04                	jmp    801d36 <dev_lookup+0x25>
  801d32:	39 0a                	cmp    %ecx,(%edx)
  801d34:	75 0c                	jne    801d42 <dev_lookup+0x31>
  801d36:	89 13                	mov    %edx,(%ebx)
  801d38:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3d:	8d 76 00             	lea    0x0(%esi),%esi
  801d40:	eb 35                	jmp    801d77 <dev_lookup+0x66>
  801d42:	83 c0 01             	add    $0x1,%eax
  801d45:	8b 14 85 f4 36 80 00 	mov    0x8036f4(,%eax,4),%edx
  801d4c:	85 d2                	test   %edx,%edx
  801d4e:	75 e2                	jne    801d32 <dev_lookup+0x21>
  801d50:	a1 54 70 80 00       	mov    0x807054,%eax
  801d55:	8b 40 4c             	mov    0x4c(%eax),%eax
  801d58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d60:	c7 04 24 78 36 80 00 	movl   $0x803678,(%esp)
  801d67:	e8 ed e8 ff ff       	call   800659 <cprintf>
  801d6c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801d72:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d77:	83 c4 14             	add    $0x14,%esp
  801d7a:	5b                   	pop    %ebx
  801d7b:	5d                   	pop    %ebp
  801d7c:	c3                   	ret    

00801d7d <fstat>:

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
  801d7d:	55                   	push   %ebp
  801d7e:	89 e5                	mov    %esp,%ebp
  801d80:	53                   	push   %ebx
  801d81:	83 ec 24             	sub    $0x24,%esp
  801d84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d87:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801d8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d91:	89 04 24             	mov    %eax,(%esp)
  801d94:	e8 05 ff ff ff       	call   801c9e <fd_lookup>
  801d99:	89 c2                	mov    %eax,%edx
  801d9b:	85 c0                	test   %eax,%eax
  801d9d:	78 57                	js     801df6 <fstat+0x79>
  801d9f:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801da2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da6:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801da9:	8b 00                	mov    (%eax),%eax
  801dab:	89 04 24             	mov    %eax,(%esp)
  801dae:	e8 5e ff ff ff       	call   801d11 <dev_lookup>
  801db3:	89 c2                	mov    %eax,%edx
  801db5:	85 c0                	test   %eax,%eax
  801db7:	78 3d                	js     801df6 <fstat+0x79>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801db9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  801dbe:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  801dc1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801dc5:	74 2f                	je     801df6 <fstat+0x79>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801dc7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801dca:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801dd1:	00 00 00 
	stat->st_isdir = 0;
  801dd4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ddb:	00 00 00 
	stat->st_dev = dev;
  801dde:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801de1:	89 93 88 00 00 00    	mov    %edx,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801de7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801deb:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801dee:	89 04 24             	mov    %eax,(%esp)
  801df1:	ff 52 14             	call   *0x14(%edx)
  801df4:	89 c2                	mov    %eax,%edx
}
  801df6:	89 d0                	mov    %edx,%eax
  801df8:	83 c4 24             	add    $0x24,%esp
  801dfb:	5b                   	pop    %ebx
  801dfc:	5d                   	pop    %ebp
  801dfd:	c3                   	ret    

00801dfe <ftruncate>:
  801dfe:	55                   	push   %ebp
  801dff:	89 e5                	mov    %esp,%ebp
  801e01:	53                   	push   %ebx
  801e02:	83 ec 24             	sub    $0x24,%esp
  801e05:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801e08:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801e0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e0f:	89 1c 24             	mov    %ebx,(%esp)
  801e12:	e8 87 fe ff ff       	call   801c9e <fd_lookup>
  801e17:	85 c0                	test   %eax,%eax
  801e19:	78 61                	js     801e7c <ftruncate+0x7e>
  801e1b:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801e1e:	8b 10                	mov    (%eax),%edx
  801e20:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801e23:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e27:	89 14 24             	mov    %edx,(%esp)
  801e2a:	e8 e2 fe ff ff       	call   801d11 <dev_lookup>
  801e2f:	85 c0                	test   %eax,%eax
  801e31:	78 49                	js     801e7c <ftruncate+0x7e>
  801e33:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801e36:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801e3a:	75 23                	jne    801e5f <ftruncate+0x61>
  801e3c:	a1 54 70 80 00       	mov    0x807054,%eax
  801e41:	8b 40 4c             	mov    0x4c(%eax),%eax
  801e44:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e48:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e4c:	c7 04 24 98 36 80 00 	movl   $0x803698,(%esp)
  801e53:	e8 01 e8 ff ff       	call   800659 <cprintf>
  801e58:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801e5d:	eb 1d                	jmp    801e7c <ftruncate+0x7e>
  801e5f:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801e62:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801e67:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801e6b:	74 0f                	je     801e7c <ftruncate+0x7e>
  801e6d:	8b 52 18             	mov    0x18(%edx),%edx
  801e70:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e73:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e77:	89 0c 24             	mov    %ecx,(%esp)
  801e7a:	ff d2                	call   *%edx
  801e7c:	83 c4 24             	add    $0x24,%esp
  801e7f:	5b                   	pop    %ebx
  801e80:	5d                   	pop    %ebp
  801e81:	c3                   	ret    

00801e82 <write>:
  801e82:	55                   	push   %ebp
  801e83:	89 e5                	mov    %esp,%ebp
  801e85:	53                   	push   %ebx
  801e86:	83 ec 24             	sub    $0x24,%esp
  801e89:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801e8c:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801e8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e93:	89 1c 24             	mov    %ebx,(%esp)
  801e96:	e8 03 fe ff ff       	call   801c9e <fd_lookup>
  801e9b:	85 c0                	test   %eax,%eax
  801e9d:	78 68                	js     801f07 <write+0x85>
  801e9f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801ea2:	8b 10                	mov    (%eax),%edx
  801ea4:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801ea7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eab:	89 14 24             	mov    %edx,(%esp)
  801eae:	e8 5e fe ff ff       	call   801d11 <dev_lookup>
  801eb3:	85 c0                	test   %eax,%eax
  801eb5:	78 50                	js     801f07 <write+0x85>
  801eb7:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801eba:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801ebe:	75 23                	jne    801ee3 <write+0x61>
  801ec0:	a1 54 70 80 00       	mov    0x807054,%eax
  801ec5:	8b 40 4c             	mov    0x4c(%eax),%eax
  801ec8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ecc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed0:	c7 04 24 b9 36 80 00 	movl   $0x8036b9,(%esp)
  801ed7:	e8 7d e7 ff ff       	call   800659 <cprintf>
  801edc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ee1:	eb 24                	jmp    801f07 <write+0x85>
  801ee3:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801ee6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801eeb:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  801eef:	74 16                	je     801f07 <write+0x85>
  801ef1:	8b 42 0c             	mov    0xc(%edx),%eax
  801ef4:	8b 55 10             	mov    0x10(%ebp),%edx
  801ef7:	89 54 24 08          	mov    %edx,0x8(%esp)
  801efb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801efe:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f02:	89 0c 24             	mov    %ecx,(%esp)
  801f05:	ff d0                	call   *%eax
  801f07:	83 c4 24             	add    $0x24,%esp
  801f0a:	5b                   	pop    %ebx
  801f0b:	5d                   	pop    %ebp
  801f0c:	c3                   	ret    

00801f0d <read>:
  801f0d:	55                   	push   %ebp
  801f0e:	89 e5                	mov    %esp,%ebp
  801f10:	53                   	push   %ebx
  801f11:	83 ec 24             	sub    $0x24,%esp
  801f14:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801f17:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801f1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f1e:	89 1c 24             	mov    %ebx,(%esp)
  801f21:	e8 78 fd ff ff       	call   801c9e <fd_lookup>
  801f26:	85 c0                	test   %eax,%eax
  801f28:	78 6d                	js     801f97 <read+0x8a>
  801f2a:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801f2d:	8b 10                	mov    (%eax),%edx
  801f2f:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801f32:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f36:	89 14 24             	mov    %edx,(%esp)
  801f39:	e8 d3 fd ff ff       	call   801d11 <dev_lookup>
  801f3e:	85 c0                	test   %eax,%eax
  801f40:	78 55                	js     801f97 <read+0x8a>
  801f42:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801f45:	8b 41 08             	mov    0x8(%ecx),%eax
  801f48:	83 e0 03             	and    $0x3,%eax
  801f4b:	83 f8 01             	cmp    $0x1,%eax
  801f4e:	75 23                	jne    801f73 <read+0x66>
  801f50:	a1 54 70 80 00       	mov    0x807054,%eax
  801f55:	8b 40 4c             	mov    0x4c(%eax),%eax
  801f58:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f60:	c7 04 24 d6 36 80 00 	movl   $0x8036d6,(%esp)
  801f67:	e8 ed e6 ff ff       	call   800659 <cprintf>
  801f6c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801f71:	eb 24                	jmp    801f97 <read+0x8a>
  801f73:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801f76:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801f7b:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  801f7f:	74 16                	je     801f97 <read+0x8a>
  801f81:	8b 42 08             	mov    0x8(%edx),%eax
  801f84:	8b 55 10             	mov    0x10(%ebp),%edx
  801f87:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f8e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f92:	89 0c 24             	mov    %ecx,(%esp)
  801f95:	ff d0                	call   *%eax
  801f97:	83 c4 24             	add    $0x24,%esp
  801f9a:	5b                   	pop    %ebx
  801f9b:	5d                   	pop    %ebp
  801f9c:	c3                   	ret    

00801f9d <readn>:
  801f9d:	55                   	push   %ebp
  801f9e:	89 e5                	mov    %esp,%ebp
  801fa0:	57                   	push   %edi
  801fa1:	56                   	push   %esi
  801fa2:	53                   	push   %ebx
  801fa3:	83 ec 0c             	sub    $0xc,%esp
  801fa6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801fa9:	8b 75 10             	mov    0x10(%ebp),%esi
  801fac:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb1:	85 f6                	test   %esi,%esi
  801fb3:	74 36                	je     801feb <readn+0x4e>
  801fb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fba:	ba 00 00 00 00       	mov    $0x0,%edx
  801fbf:	89 f0                	mov    %esi,%eax
  801fc1:	29 d0                	sub    %edx,%eax
  801fc3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fc7:	8d 04 17             	lea    (%edi,%edx,1),%eax
  801fca:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fce:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd1:	89 04 24             	mov    %eax,(%esp)
  801fd4:	e8 34 ff ff ff       	call   801f0d <read>
  801fd9:	85 c0                	test   %eax,%eax
  801fdb:	78 0e                	js     801feb <readn+0x4e>
  801fdd:	85 c0                	test   %eax,%eax
  801fdf:	74 08                	je     801fe9 <readn+0x4c>
  801fe1:	01 c3                	add    %eax,%ebx
  801fe3:	89 da                	mov    %ebx,%edx
  801fe5:	39 f3                	cmp    %esi,%ebx
  801fe7:	72 d6                	jb     801fbf <readn+0x22>
  801fe9:	89 d8                	mov    %ebx,%eax
  801feb:	83 c4 0c             	add    $0xc,%esp
  801fee:	5b                   	pop    %ebx
  801fef:	5e                   	pop    %esi
  801ff0:	5f                   	pop    %edi
  801ff1:	5d                   	pop    %ebp
  801ff2:	c3                   	ret    

00801ff3 <fd_close>:
  801ff3:	55                   	push   %ebp
  801ff4:	89 e5                	mov    %esp,%ebp
  801ff6:	83 ec 28             	sub    $0x28,%esp
  801ff9:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  801ffc:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  801fff:	8b 75 08             	mov    0x8(%ebp),%esi
  802002:	89 34 24             	mov    %esi,(%esp)
  802005:	e8 16 fc ff ff       	call   801c20 <fd2num>
  80200a:	8d 55 f4             	lea    0xfffffff4(%ebp),%edx
  80200d:	89 54 24 04          	mov    %edx,0x4(%esp)
  802011:	89 04 24             	mov    %eax,(%esp)
  802014:	e8 85 fc ff ff       	call   801c9e <fd_lookup>
  802019:	89 c3                	mov    %eax,%ebx
  80201b:	85 c0                	test   %eax,%eax
  80201d:	78 05                	js     802024 <fd_close+0x31>
  80201f:	3b 75 f4             	cmp    0xfffffff4(%ebp),%esi
  802022:	74 0e                	je     802032 <fd_close+0x3f>
  802024:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802028:	75 45                	jne    80206f <fd_close+0x7c>
  80202a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80202f:	90                   	nop    
  802030:	eb 3d                	jmp    80206f <fd_close+0x7c>
  802032:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  802035:	89 44 24 04          	mov    %eax,0x4(%esp)
  802039:	8b 06                	mov    (%esi),%eax
  80203b:	89 04 24             	mov    %eax,(%esp)
  80203e:	e8 ce fc ff ff       	call   801d11 <dev_lookup>
  802043:	89 c3                	mov    %eax,%ebx
  802045:	85 c0                	test   %eax,%eax
  802047:	78 16                	js     80205f <fd_close+0x6c>
  802049:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80204c:	8b 40 10             	mov    0x10(%eax),%eax
  80204f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802054:	85 c0                	test   %eax,%eax
  802056:	74 07                	je     80205f <fd_close+0x6c>
  802058:	89 34 24             	mov    %esi,(%esp)
  80205b:	ff d0                	call   *%eax
  80205d:	89 c3                	mov    %eax,%ebx
  80205f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80206a:	e8 df f2 ff ff       	call   80134e <sys_page_unmap>
  80206f:	89 d8                	mov    %ebx,%eax
  802071:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  802074:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  802077:	89 ec                	mov    %ebp,%esp
  802079:	5d                   	pop    %ebp
  80207a:	c3                   	ret    

0080207b <close>:
  80207b:	55                   	push   %ebp
  80207c:	89 e5                	mov    %esp,%ebp
  80207e:	83 ec 18             	sub    $0x18,%esp
  802081:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  802084:	89 44 24 04          	mov    %eax,0x4(%esp)
  802088:	8b 45 08             	mov    0x8(%ebp),%eax
  80208b:	89 04 24             	mov    %eax,(%esp)
  80208e:	e8 0b fc ff ff       	call   801c9e <fd_lookup>
  802093:	85 c0                	test   %eax,%eax
  802095:	78 13                	js     8020aa <close+0x2f>
  802097:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80209e:	00 
  80209f:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  8020a2:	89 04 24             	mov    %eax,(%esp)
  8020a5:	e8 49 ff ff ff       	call   801ff3 <fd_close>
  8020aa:	c9                   	leave  
  8020ab:	c3                   	ret    

008020ac <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8020ac:	55                   	push   %ebp
  8020ad:	89 e5                	mov    %esp,%ebp
  8020af:	83 ec 18             	sub    $0x18,%esp
  8020b2:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  8020b5:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8020b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8020bf:	00 
  8020c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c3:	89 04 24             	mov    %eax,(%esp)
  8020c6:	e8 58 03 00 00       	call   802423 <open>
  8020cb:	89 c6                	mov    %eax,%esi
  8020cd:	85 c0                	test   %eax,%eax
  8020cf:	78 1b                	js     8020ec <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8020d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d8:	89 34 24             	mov    %esi,(%esp)
  8020db:	e8 9d fc ff ff       	call   801d7d <fstat>
  8020e0:	89 c3                	mov    %eax,%ebx
	close(fd);
  8020e2:	89 34 24             	mov    %esi,(%esp)
  8020e5:	e8 91 ff ff ff       	call   80207b <close>
  8020ea:	89 de                	mov    %ebx,%esi
	return r;
}
  8020ec:	89 f0                	mov    %esi,%eax
  8020ee:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  8020f1:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  8020f4:	89 ec                	mov    %ebp,%esp
  8020f6:	5d                   	pop    %ebp
  8020f7:	c3                   	ret    

008020f8 <dup>:
  8020f8:	55                   	push   %ebp
  8020f9:	89 e5                	mov    %esp,%ebp
  8020fb:	83 ec 38             	sub    $0x38,%esp
  8020fe:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  802101:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  802104:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  802107:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80210a:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  80210d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802111:	8b 45 08             	mov    0x8(%ebp),%eax
  802114:	89 04 24             	mov    %eax,(%esp)
  802117:	e8 82 fb ff ff       	call   801c9e <fd_lookup>
  80211c:	89 c3                	mov    %eax,%ebx
  80211e:	85 c0                	test   %eax,%eax
  802120:	0f 88 e1 00 00 00    	js     802207 <dup+0x10f>
  802126:	89 3c 24             	mov    %edi,(%esp)
  802129:	e8 4d ff ff ff       	call   80207b <close>
  80212e:	89 f8                	mov    %edi,%eax
  802130:	c1 e0 0c             	shl    $0xc,%eax
  802133:	8d b0 00 00 00 d0    	lea    0xd0000000(%eax),%esi
  802139:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80213c:	89 04 24             	mov    %eax,(%esp)
  80213f:	e8 ec fa ff ff       	call   801c30 <fd2data>
  802144:	89 c3                	mov    %eax,%ebx
  802146:	89 34 24             	mov    %esi,(%esp)
  802149:	e8 e2 fa ff ff       	call   801c30 <fd2data>
  80214e:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  802151:	89 d8                	mov    %ebx,%eax
  802153:	c1 e8 16             	shr    $0x16,%eax
  802156:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  80215d:	a8 01                	test   $0x1,%al
  80215f:	74 45                	je     8021a6 <dup+0xae>
  802161:	89 da                	mov    %ebx,%edx
  802163:	c1 ea 0c             	shr    $0xc,%edx
  802166:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  80216d:	a8 01                	test   $0x1,%al
  80216f:	74 35                	je     8021a6 <dup+0xae>
  802171:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  802178:	25 07 0e 00 00       	and    $0xe07,%eax
  80217d:	89 44 24 10          	mov    %eax,0x10(%esp)
  802181:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  802184:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802188:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80218f:	00 
  802190:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802194:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80219b:	e8 0c f2 ff ff       	call   8013ac <sys_page_map>
  8021a0:	89 c3                	mov    %eax,%ebx
  8021a2:	85 c0                	test   %eax,%eax
  8021a4:	78 3e                	js     8021e4 <dup+0xec>
  8021a6:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  8021a9:	89 d0                	mov    %edx,%eax
  8021ab:	c1 e8 0c             	shr    $0xc,%eax
  8021ae:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  8021b5:	25 07 0e 00 00       	and    $0xe07,%eax
  8021ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  8021be:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8021c2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8021c9:	00 
  8021ca:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021d5:	e8 d2 f1 ff ff       	call   8013ac <sys_page_map>
  8021da:	89 c3                	mov    %eax,%ebx
  8021dc:	85 c0                	test   %eax,%eax
  8021de:	78 04                	js     8021e4 <dup+0xec>
  8021e0:	89 fb                	mov    %edi,%ebx
  8021e2:	eb 23                	jmp    802207 <dup+0x10f>
  8021e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021ef:	e8 5a f1 ff ff       	call   80134e <sys_page_unmap>
  8021f4:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  8021f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802202:	e8 47 f1 ff ff       	call   80134e <sys_page_unmap>
  802207:	89 d8                	mov    %ebx,%eax
  802209:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  80220c:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  80220f:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  802212:	89 ec                	mov    %ebp,%esp
  802214:	5d                   	pop    %ebp
  802215:	c3                   	ret    

00802216 <close_all>:
  802216:	55                   	push   %ebp
  802217:	89 e5                	mov    %esp,%ebp
  802219:	53                   	push   %ebx
  80221a:	83 ec 04             	sub    $0x4,%esp
  80221d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802222:	89 1c 24             	mov    %ebx,(%esp)
  802225:	e8 51 fe ff ff       	call   80207b <close>
  80222a:	83 c3 01             	add    $0x1,%ebx
  80222d:	83 fb 20             	cmp    $0x20,%ebx
  802230:	75 f0                	jne    802222 <close_all+0xc>
  802232:	83 c4 04             	add    $0x4,%esp
  802235:	5b                   	pop    %ebx
  802236:	5d                   	pop    %ebp
  802237:	c3                   	ret    

00802238 <fsipc>:
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802238:	55                   	push   %ebp
  802239:	89 e5                	mov    %esp,%ebp
  80223b:	53                   	push   %ebx
  80223c:	83 ec 14             	sub    $0x14,%esp
  80223f:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802241:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  802247:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80224e:	00 
  80224f:	c7 44 24 08 00 40 80 	movl   $0x804000,0x8(%esp)
  802256:	00 
  802257:	89 44 24 04          	mov    %eax,0x4(%esp)
  80225b:	89 14 24             	mov    %edx,(%esp)
  80225e:	e8 1d f8 ff ff       	call   801a80 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802263:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80226a:	00 
  80226b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80226f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802276:	e8 b9 f8 ff ff       	call   801b34 <ipc_recv>
}
  80227b:	83 c4 14             	add    $0x14,%esp
  80227e:	5b                   	pop    %ebx
  80227f:	5d                   	pop    %ebp
  802280:	c3                   	ret    

00802281 <sync>:

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
  802281:	55                   	push   %ebp
  802282:	89 e5                	mov    %esp,%ebp
  802284:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802287:	ba 00 00 00 00       	mov    $0x0,%edx
  80228c:	b8 08 00 00 00       	mov    $0x8,%eax
  802291:	e8 a2 ff ff ff       	call   802238 <fsipc>
}
  802296:	c9                   	leave  
  802297:	c3                   	ret    

00802298 <devfile_trunc>:
  802298:	55                   	push   %ebp
  802299:	89 e5                	mov    %esp,%ebp
  80229b:	83 ec 08             	sub    $0x8,%esp
  80229e:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8022a4:	a3 00 40 80 00       	mov    %eax,0x804000
  8022a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022ac:	a3 04 40 80 00       	mov    %eax,0x804004
  8022b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8022b6:	b8 02 00 00 00       	mov    $0x2,%eax
  8022bb:	e8 78 ff ff ff       	call   802238 <fsipc>
  8022c0:	c9                   	leave  
  8022c1:	c3                   	ret    

008022c2 <devfile_flush>:
  8022c2:	55                   	push   %ebp
  8022c3:	89 e5                	mov    %esp,%ebp
  8022c5:	83 ec 08             	sub    $0x8,%esp
  8022c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8022ce:	a3 00 40 80 00       	mov    %eax,0x804000
  8022d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8022d8:	b8 06 00 00 00       	mov    $0x6,%eax
  8022dd:	e8 56 ff ff ff       	call   802238 <fsipc>
  8022e2:	c9                   	leave  
  8022e3:	c3                   	ret    

008022e4 <devfile_stat>:
  8022e4:	55                   	push   %ebp
  8022e5:	89 e5                	mov    %esp,%ebp
  8022e7:	53                   	push   %ebx
  8022e8:	83 ec 14             	sub    $0x14,%esp
  8022eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8022ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8022f4:	a3 00 40 80 00       	mov    %eax,0x804000
  8022f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8022fe:	b8 05 00 00 00       	mov    $0x5,%eax
  802303:	e8 30 ff ff ff       	call   802238 <fsipc>
  802308:	85 c0                	test   %eax,%eax
  80230a:	78 2b                	js     802337 <devfile_stat+0x53>
  80230c:	c7 44 24 04 00 40 80 	movl   $0x804000,0x4(%esp)
  802313:	00 
  802314:	89 1c 24             	mov    %ebx,(%esp)
  802317:	e8 c5 e9 ff ff       	call   800ce1 <strcpy>
  80231c:	a1 80 40 80 00       	mov    0x804080,%eax
  802321:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  802327:	a1 84 40 80 00       	mov    0x804084,%eax
  80232c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  802332:	b8 00 00 00 00       	mov    $0x0,%eax
  802337:	83 c4 14             	add    $0x14,%esp
  80233a:	5b                   	pop    %ebx
  80233b:	5d                   	pop    %ebp
  80233c:	c3                   	ret    

0080233d <devfile_write>:
  80233d:	55                   	push   %ebp
  80233e:	89 e5                	mov    %esp,%ebp
  802340:	83 ec 18             	sub    $0x18,%esp
  802343:	8b 55 10             	mov    0x10(%ebp),%edx
  802346:	8b 45 08             	mov    0x8(%ebp),%eax
  802349:	8b 40 0c             	mov    0xc(%eax),%eax
  80234c:	a3 00 40 80 00       	mov    %eax,0x804000
  802351:	89 d0                	mov    %edx,%eax
  802353:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  802359:	76 05                	jbe    802360 <devfile_write+0x23>
  80235b:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  802360:	89 15 04 40 80 00    	mov    %edx,0x804004
  802366:	89 44 24 08          	mov    %eax,0x8(%esp)
  80236a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80236d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802371:	c7 04 24 08 40 80 00 	movl   $0x804008,(%esp)
  802378:	e8 6d eb ff ff       	call   800eea <memmove>
  80237d:	ba 00 00 00 00       	mov    $0x0,%edx
  802382:	b8 04 00 00 00       	mov    $0x4,%eax
  802387:	e8 ac fe ff ff       	call   802238 <fsipc>
  80238c:	c9                   	leave  
  80238d:	c3                   	ret    

0080238e <devfile_read>:
  80238e:	55                   	push   %ebp
  80238f:	89 e5                	mov    %esp,%ebp
  802391:	53                   	push   %ebx
  802392:	83 ec 14             	sub    $0x14,%esp
  802395:	8b 45 08             	mov    0x8(%ebp),%eax
  802398:	8b 40 0c             	mov    0xc(%eax),%eax
  80239b:	a3 00 40 80 00       	mov    %eax,0x804000
  8023a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8023a3:	a3 04 40 80 00       	mov    %eax,0x804004
  8023a8:	ba 00 40 80 00       	mov    $0x804000,%edx
  8023ad:	b8 03 00 00 00       	mov    $0x3,%eax
  8023b2:	e8 81 fe ff ff       	call   802238 <fsipc>
  8023b7:	89 c3                	mov    %eax,%ebx
  8023b9:	85 c0                	test   %eax,%eax
  8023bb:	7e 17                	jle    8023d4 <devfile_read+0x46>
  8023bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023c1:	c7 44 24 04 00 40 80 	movl   $0x804000,0x4(%esp)
  8023c8:	00 
  8023c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023cc:	89 04 24             	mov    %eax,(%esp)
  8023cf:	e8 16 eb ff ff       	call   800eea <memmove>
  8023d4:	89 d8                	mov    %ebx,%eax
  8023d6:	83 c4 14             	add    $0x14,%esp
  8023d9:	5b                   	pop    %ebx
  8023da:	5d                   	pop    %ebp
  8023db:	c3                   	ret    

008023dc <remove>:
  8023dc:	55                   	push   %ebp
  8023dd:	89 e5                	mov    %esp,%ebp
  8023df:	53                   	push   %ebx
  8023e0:	83 ec 14             	sub    $0x14,%esp
  8023e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8023e6:	89 1c 24             	mov    %ebx,(%esp)
  8023e9:	e8 a2 e8 ff ff       	call   800c90 <strlen>
  8023ee:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  8023f3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8023f8:	7f 21                	jg     80241b <remove+0x3f>
  8023fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8023fe:	c7 04 24 00 40 80 00 	movl   $0x804000,(%esp)
  802405:	e8 d7 e8 ff ff       	call   800ce1 <strcpy>
  80240a:	ba 00 00 00 00       	mov    $0x0,%edx
  80240f:	b8 07 00 00 00       	mov    $0x7,%eax
  802414:	e8 1f fe ff ff       	call   802238 <fsipc>
  802419:	89 c2                	mov    %eax,%edx
  80241b:	89 d0                	mov    %edx,%eax
  80241d:	83 c4 14             	add    $0x14,%esp
  802420:	5b                   	pop    %ebx
  802421:	5d                   	pop    %ebp
  802422:	c3                   	ret    

00802423 <open>:
  802423:	55                   	push   %ebp
  802424:	89 e5                	mov    %esp,%ebp
  802426:	56                   	push   %esi
  802427:	53                   	push   %ebx
  802428:	83 ec 30             	sub    $0x30,%esp
  80242b:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80242e:	89 04 24             	mov    %eax,(%esp)
  802431:	e8 15 f8 ff ff       	call   801c4b <fd_alloc>
  802436:	89 c3                	mov    %eax,%ebx
  802438:	85 c0                	test   %eax,%eax
  80243a:	79 18                	jns    802454 <open+0x31>
  80243c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802443:	00 
  802444:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  802447:	89 04 24             	mov    %eax,(%esp)
  80244a:	e8 a4 fb ff ff       	call   801ff3 <fd_close>
  80244f:	e9 9f 00 00 00       	jmp    8024f3 <open+0xd0>
  802454:	8b 45 08             	mov    0x8(%ebp),%eax
  802457:	89 44 24 04          	mov    %eax,0x4(%esp)
  80245b:	c7 04 24 00 40 80 00 	movl   $0x804000,(%esp)
  802462:	e8 7a e8 ff ff       	call   800ce1 <strcpy>
  802467:	8b 45 0c             	mov    0xc(%ebp),%eax
  80246a:	a3 00 44 80 00       	mov    %eax,0x804400
  80246f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  802472:	89 04 24             	mov    %eax,(%esp)
  802475:	e8 b6 f7 ff ff       	call   801c30 <fd2data>
  80247a:	89 c6                	mov    %eax,%esi
  80247c:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  80247f:	b8 01 00 00 00       	mov    $0x1,%eax
  802484:	e8 af fd ff ff       	call   802238 <fsipc>
  802489:	89 c3                	mov    %eax,%ebx
  80248b:	85 c0                	test   %eax,%eax
  80248d:	79 15                	jns    8024a4 <open+0x81>
  80248f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802496:	00 
  802497:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80249a:	89 04 24             	mov    %eax,(%esp)
  80249d:	e8 51 fb ff ff       	call   801ff3 <fd_close>
  8024a2:	eb 4f                	jmp    8024f3 <open+0xd0>
  8024a4:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8024ab:	00 
  8024ac:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8024b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8024b7:	00 
  8024b8:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8024bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024c6:	e8 e1 ee ff ff       	call   8013ac <sys_page_map>
  8024cb:	89 c3                	mov    %eax,%ebx
  8024cd:	85 c0                	test   %eax,%eax
  8024cf:	79 15                	jns    8024e6 <open+0xc3>
  8024d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8024d8:	00 
  8024d9:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8024dc:	89 04 24             	mov    %eax,(%esp)
  8024df:	e8 0f fb ff ff       	call   801ff3 <fd_close>
  8024e4:	eb 0d                	jmp    8024f3 <open+0xd0>
  8024e6:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8024e9:	89 04 24             	mov    %eax,(%esp)
  8024ec:	e8 2f f7 ff ff       	call   801c20 <fd2num>
  8024f1:	89 c3                	mov    %eax,%ebx
  8024f3:	89 d8                	mov    %ebx,%eax
  8024f5:	83 c4 30             	add    $0x30,%esp
  8024f8:	5b                   	pop    %ebx
  8024f9:	5e                   	pop    %esi
  8024fa:	5d                   	pop    %ebp
  8024fb:	c3                   	ret    
  8024fc:	00 00                	add    %al,(%eax)
	...

00802500 <devsock_stat>:
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802500:	55                   	push   %ebp
  802501:	89 e5                	mov    %esp,%ebp
  802503:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  802506:	c7 44 24 04 00 37 80 	movl   $0x803700,0x4(%esp)
  80250d:	00 
  80250e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802511:	89 04 24             	mov    %eax,(%esp)
  802514:	e8 c8 e7 ff ff       	call   800ce1 <strcpy>
	return 0;
}
  802519:	b8 00 00 00 00       	mov    $0x0,%eax
  80251e:	c9                   	leave  
  80251f:	c3                   	ret    

00802520 <devsock_close>:
  802520:	55                   	push   %ebp
  802521:	89 e5                	mov    %esp,%ebp
  802523:	83 ec 08             	sub    $0x8,%esp
  802526:	8b 45 08             	mov    0x8(%ebp),%eax
  802529:	8b 40 0c             	mov    0xc(%eax),%eax
  80252c:	89 04 24             	mov    %eax,(%esp)
  80252f:	e8 be 02 00 00       	call   8027f2 <nsipc_close>
  802534:	c9                   	leave  
  802535:	c3                   	ret    

00802536 <devsock_write>:
  802536:	55                   	push   %ebp
  802537:	89 e5                	mov    %esp,%ebp
  802539:	83 ec 18             	sub    $0x18,%esp
  80253c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802543:	00 
  802544:	8b 45 10             	mov    0x10(%ebp),%eax
  802547:	89 44 24 08          	mov    %eax,0x8(%esp)
  80254b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80254e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802552:	8b 45 08             	mov    0x8(%ebp),%eax
  802555:	8b 40 0c             	mov    0xc(%eax),%eax
  802558:	89 04 24             	mov    %eax,(%esp)
  80255b:	e8 ce 02 00 00       	call   80282e <nsipc_send>
  802560:	c9                   	leave  
  802561:	c3                   	ret    

00802562 <devsock_read>:
  802562:	55                   	push   %ebp
  802563:	89 e5                	mov    %esp,%ebp
  802565:	83 ec 18             	sub    $0x18,%esp
  802568:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80256f:	00 
  802570:	8b 45 10             	mov    0x10(%ebp),%eax
  802573:	89 44 24 08          	mov    %eax,0x8(%esp)
  802577:	8b 45 0c             	mov    0xc(%ebp),%eax
  80257a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80257e:	8b 45 08             	mov    0x8(%ebp),%eax
  802581:	8b 40 0c             	mov    0xc(%eax),%eax
  802584:	89 04 24             	mov    %eax,(%esp)
  802587:	e8 15 03 00 00       	call   8028a1 <nsipc_recv>
  80258c:	c9                   	leave  
  80258d:	c3                   	ret    

0080258e <alloc_sockfd>:
  80258e:	55                   	push   %ebp
  80258f:	89 e5                	mov    %esp,%ebp
  802591:	56                   	push   %esi
  802592:	53                   	push   %ebx
  802593:	83 ec 20             	sub    $0x20,%esp
  802596:	89 c6                	mov    %eax,%esi
  802598:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80259b:	89 04 24             	mov    %eax,(%esp)
  80259e:	e8 a8 f6 ff ff       	call   801c4b <fd_alloc>
  8025a3:	89 c3                	mov    %eax,%ebx
  8025a5:	85 c0                	test   %eax,%eax
  8025a7:	78 21                	js     8025ca <alloc_sockfd+0x3c>
  8025a9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8025b0:	00 
  8025b1:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8025b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025bf:	e8 46 ee ff ff       	call   80140a <sys_page_alloc>
  8025c4:	89 c3                	mov    %eax,%ebx
  8025c6:	85 c0                	test   %eax,%eax
  8025c8:	79 0a                	jns    8025d4 <alloc_sockfd+0x46>
  8025ca:	89 34 24             	mov    %esi,(%esp)
  8025cd:	e8 20 02 00 00       	call   8027f2 <nsipc_close>
  8025d2:	eb 28                	jmp    8025fc <alloc_sockfd+0x6e>
  8025d4:	8b 15 20 70 80 00    	mov    0x807020,%edx
  8025da:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8025dd:	89 10                	mov    %edx,(%eax)
  8025df:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8025e2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  8025e9:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8025ec:	89 70 0c             	mov    %esi,0xc(%eax)
  8025ef:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8025f2:	89 04 24             	mov    %eax,(%esp)
  8025f5:	e8 26 f6 ff ff       	call   801c20 <fd2num>
  8025fa:	89 c3                	mov    %eax,%ebx
  8025fc:	89 d8                	mov    %ebx,%eax
  8025fe:	83 c4 20             	add    $0x20,%esp
  802601:	5b                   	pop    %ebx
  802602:	5e                   	pop    %esi
  802603:	5d                   	pop    %ebp
  802604:	c3                   	ret    

00802605 <socket>:

int
socket(int domain, int type, int protocol)
{
  802605:	55                   	push   %ebp
  802606:	89 e5                	mov    %esp,%ebp
  802608:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80260b:	8b 45 10             	mov    0x10(%ebp),%eax
  80260e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802612:	8b 45 0c             	mov    0xc(%ebp),%eax
  802615:	89 44 24 04          	mov    %eax,0x4(%esp)
  802619:	8b 45 08             	mov    0x8(%ebp),%eax
  80261c:	89 04 24             	mov    %eax,(%esp)
  80261f:	e8 82 01 00 00       	call   8027a6 <nsipc_socket>
  802624:	85 c0                	test   %eax,%eax
  802626:	78 05                	js     80262d <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802628:	e8 61 ff ff ff       	call   80258e <alloc_sockfd>
}
  80262d:	c9                   	leave  
  80262e:	66 90                	xchg   %ax,%ax
  802630:	c3                   	ret    

00802631 <fd2sockid>:
  802631:	55                   	push   %ebp
  802632:	89 e5                	mov    %esp,%ebp
  802634:	83 ec 18             	sub    $0x18,%esp
  802637:	8d 55 fc             	lea    0xfffffffc(%ebp),%edx
  80263a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80263e:	89 04 24             	mov    %eax,(%esp)
  802641:	e8 58 f6 ff ff       	call   801c9e <fd_lookup>
  802646:	89 c2                	mov    %eax,%edx
  802648:	85 c0                	test   %eax,%eax
  80264a:	78 15                	js     802661 <fd2sockid+0x30>
  80264c:	8b 4d fc             	mov    0xfffffffc(%ebp),%ecx
  80264f:	8b 01                	mov    (%ecx),%eax
  802651:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  802656:	3b 05 20 70 80 00    	cmp    0x807020,%eax
  80265c:	75 03                	jne    802661 <fd2sockid+0x30>
  80265e:	8b 51 0c             	mov    0xc(%ecx),%edx
  802661:	89 d0                	mov    %edx,%eax
  802663:	c9                   	leave  
  802664:	c3                   	ret    

00802665 <listen>:
  802665:	55                   	push   %ebp
  802666:	89 e5                	mov    %esp,%ebp
  802668:	83 ec 08             	sub    $0x8,%esp
  80266b:	8b 45 08             	mov    0x8(%ebp),%eax
  80266e:	e8 be ff ff ff       	call   802631 <fd2sockid>
  802673:	89 c2                	mov    %eax,%edx
  802675:	85 c0                	test   %eax,%eax
  802677:	78 11                	js     80268a <listen+0x25>
  802679:	8b 45 0c             	mov    0xc(%ebp),%eax
  80267c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802680:	89 14 24             	mov    %edx,(%esp)
  802683:	e8 48 01 00 00       	call   8027d0 <nsipc_listen>
  802688:	89 c2                	mov    %eax,%edx
  80268a:	89 d0                	mov    %edx,%eax
  80268c:	c9                   	leave  
  80268d:	c3                   	ret    

0080268e <connect>:
  80268e:	55                   	push   %ebp
  80268f:	89 e5                	mov    %esp,%ebp
  802691:	83 ec 18             	sub    $0x18,%esp
  802694:	8b 45 08             	mov    0x8(%ebp),%eax
  802697:	e8 95 ff ff ff       	call   802631 <fd2sockid>
  80269c:	89 c2                	mov    %eax,%edx
  80269e:	85 c0                	test   %eax,%eax
  8026a0:	78 18                	js     8026ba <connect+0x2c>
  8026a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8026a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026b0:	89 14 24             	mov    %edx,(%esp)
  8026b3:	e8 71 02 00 00       	call   802929 <nsipc_connect>
  8026b8:	89 c2                	mov    %eax,%edx
  8026ba:	89 d0                	mov    %edx,%eax
  8026bc:	c9                   	leave  
  8026bd:	c3                   	ret    

008026be <shutdown>:
  8026be:	55                   	push   %ebp
  8026bf:	89 e5                	mov    %esp,%ebp
  8026c1:	83 ec 08             	sub    $0x8,%esp
  8026c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8026c7:	e8 65 ff ff ff       	call   802631 <fd2sockid>
  8026cc:	89 c2                	mov    %eax,%edx
  8026ce:	85 c0                	test   %eax,%eax
  8026d0:	78 11                	js     8026e3 <shutdown+0x25>
  8026d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026d9:	89 14 24             	mov    %edx,(%esp)
  8026dc:	e8 2b 01 00 00       	call   80280c <nsipc_shutdown>
  8026e1:	89 c2                	mov    %eax,%edx
  8026e3:	89 d0                	mov    %edx,%eax
  8026e5:	c9                   	leave  
  8026e6:	c3                   	ret    

008026e7 <bind>:
  8026e7:	55                   	push   %ebp
  8026e8:	89 e5                	mov    %esp,%ebp
  8026ea:	83 ec 18             	sub    $0x18,%esp
  8026ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8026f0:	e8 3c ff ff ff       	call   802631 <fd2sockid>
  8026f5:	89 c2                	mov    %eax,%edx
  8026f7:	85 c0                	test   %eax,%eax
  8026f9:	78 18                	js     802713 <bind+0x2c>
  8026fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8026fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  802702:	8b 45 0c             	mov    0xc(%ebp),%eax
  802705:	89 44 24 04          	mov    %eax,0x4(%esp)
  802709:	89 14 24             	mov    %edx,(%esp)
  80270c:	e8 57 02 00 00       	call   802968 <nsipc_bind>
  802711:	89 c2                	mov    %eax,%edx
  802713:	89 d0                	mov    %edx,%eax
  802715:	c9                   	leave  
  802716:	c3                   	ret    

00802717 <accept>:
  802717:	55                   	push   %ebp
  802718:	89 e5                	mov    %esp,%ebp
  80271a:	83 ec 18             	sub    $0x18,%esp
  80271d:	8b 45 08             	mov    0x8(%ebp),%eax
  802720:	e8 0c ff ff ff       	call   802631 <fd2sockid>
  802725:	89 c2                	mov    %eax,%edx
  802727:	85 c0                	test   %eax,%eax
  802729:	78 23                	js     80274e <accept+0x37>
  80272b:	8b 45 10             	mov    0x10(%ebp),%eax
  80272e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802732:	8b 45 0c             	mov    0xc(%ebp),%eax
  802735:	89 44 24 04          	mov    %eax,0x4(%esp)
  802739:	89 14 24             	mov    %edx,(%esp)
  80273c:	e8 66 02 00 00       	call   8029a7 <nsipc_accept>
  802741:	89 c2                	mov    %eax,%edx
  802743:	85 c0                	test   %eax,%eax
  802745:	78 07                	js     80274e <accept+0x37>
  802747:	e8 42 fe ff ff       	call   80258e <alloc_sockfd>
  80274c:	89 c2                	mov    %eax,%edx
  80274e:	89 d0                	mov    %edx,%eax
  802750:	c9                   	leave  
  802751:	c3                   	ret    
	...

00802760 <nsipc>:
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802760:	55                   	push   %ebp
  802761:	89 e5                	mov    %esp,%ebp
  802763:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802766:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  80276c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802773:	00 
  802774:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  80277b:	00 
  80277c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802780:	89 14 24             	mov    %edx,(%esp)
  802783:	e8 f8 f2 ff ff       	call   801a80 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802788:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80278f:	00 
  802790:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802797:	00 
  802798:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80279f:	e8 90 f3 ff ff       	call   801b34 <ipc_recv>
}
  8027a4:	c9                   	leave  
  8027a5:	c3                   	ret    

008027a6 <nsipc_socket>:

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
  8027a6:	55                   	push   %ebp
  8027a7:	89 e5                	mov    %esp,%ebp
  8027a9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8027ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8027af:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8027b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027b7:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8027bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8027bf:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8027c4:	b8 09 00 00 00       	mov    $0x9,%eax
  8027c9:	e8 92 ff ff ff       	call   802760 <nsipc>
}
  8027ce:	c9                   	leave  
  8027cf:	c3                   	ret    

008027d0 <nsipc_listen>:
  8027d0:	55                   	push   %ebp
  8027d1:	89 e5                	mov    %esp,%ebp
  8027d3:	83 ec 08             	sub    $0x8,%esp
  8027d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8027d9:	a3 00 60 80 00       	mov    %eax,0x806000
  8027de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027e1:	a3 04 60 80 00       	mov    %eax,0x806004
  8027e6:	b8 06 00 00 00       	mov    $0x6,%eax
  8027eb:	e8 70 ff ff ff       	call   802760 <nsipc>
  8027f0:	c9                   	leave  
  8027f1:	c3                   	ret    

008027f2 <nsipc_close>:
  8027f2:	55                   	push   %ebp
  8027f3:	89 e5                	mov    %esp,%ebp
  8027f5:	83 ec 08             	sub    $0x8,%esp
  8027f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8027fb:	a3 00 60 80 00       	mov    %eax,0x806000
  802800:	b8 04 00 00 00       	mov    $0x4,%eax
  802805:	e8 56 ff ff ff       	call   802760 <nsipc>
  80280a:	c9                   	leave  
  80280b:	c3                   	ret    

0080280c <nsipc_shutdown>:
  80280c:	55                   	push   %ebp
  80280d:	89 e5                	mov    %esp,%ebp
  80280f:	83 ec 08             	sub    $0x8,%esp
  802812:	8b 45 08             	mov    0x8(%ebp),%eax
  802815:	a3 00 60 80 00       	mov    %eax,0x806000
  80281a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80281d:	a3 04 60 80 00       	mov    %eax,0x806004
  802822:	b8 03 00 00 00       	mov    $0x3,%eax
  802827:	e8 34 ff ff ff       	call   802760 <nsipc>
  80282c:	c9                   	leave  
  80282d:	c3                   	ret    

0080282e <nsipc_send>:
  80282e:	55                   	push   %ebp
  80282f:	89 e5                	mov    %esp,%ebp
  802831:	53                   	push   %ebx
  802832:	83 ec 14             	sub    $0x14,%esp
  802835:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802838:	8b 45 08             	mov    0x8(%ebp),%eax
  80283b:	a3 00 60 80 00       	mov    %eax,0x806000
  802840:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802846:	7e 24                	jle    80286c <nsipc_send+0x3e>
  802848:	c7 44 24 0c 0c 37 80 	movl   $0x80370c,0xc(%esp)
  80284f:	00 
  802850:	c7 44 24 08 18 37 80 	movl   $0x803718,0x8(%esp)
  802857:	00 
  802858:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  80285f:	00 
  802860:	c7 04 24 2d 37 80 00 	movl   $0x80372d,(%esp)
  802867:	e8 20 dd ff ff       	call   80058c <_panic>
  80286c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802870:	8b 45 0c             	mov    0xc(%ebp),%eax
  802873:	89 44 24 04          	mov    %eax,0x4(%esp)
  802877:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  80287e:	e8 67 e6 ff ff       	call   800eea <memmove>
  802883:	89 1d 04 60 80 00    	mov    %ebx,0x806004
  802889:	8b 45 14             	mov    0x14(%ebp),%eax
  80288c:	a3 08 60 80 00       	mov    %eax,0x806008
  802891:	b8 08 00 00 00       	mov    $0x8,%eax
  802896:	e8 c5 fe ff ff       	call   802760 <nsipc>
  80289b:	83 c4 14             	add    $0x14,%esp
  80289e:	5b                   	pop    %ebx
  80289f:	5d                   	pop    %ebp
  8028a0:	c3                   	ret    

008028a1 <nsipc_recv>:
  8028a1:	55                   	push   %ebp
  8028a2:	89 e5                	mov    %esp,%ebp
  8028a4:	83 ec 18             	sub    $0x18,%esp
  8028a7:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  8028aa:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  8028ad:	8b 75 10             	mov    0x10(%ebp),%esi
  8028b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8028b3:	a3 00 60 80 00       	mov    %eax,0x806000
  8028b8:	89 35 04 60 80 00    	mov    %esi,0x806004
  8028be:	8b 45 14             	mov    0x14(%ebp),%eax
  8028c1:	a3 08 60 80 00       	mov    %eax,0x806008
  8028c6:	b8 07 00 00 00       	mov    $0x7,%eax
  8028cb:	e8 90 fe ff ff       	call   802760 <nsipc>
  8028d0:	89 c3                	mov    %eax,%ebx
  8028d2:	85 c0                	test   %eax,%eax
  8028d4:	78 47                	js     80291d <nsipc_recv+0x7c>
  8028d6:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8028db:	7f 05                	jg     8028e2 <nsipc_recv+0x41>
  8028dd:	39 c6                	cmp    %eax,%esi
  8028df:	90                   	nop    
  8028e0:	7d 24                	jge    802906 <nsipc_recv+0x65>
  8028e2:	c7 44 24 0c 39 37 80 	movl   $0x803739,0xc(%esp)
  8028e9:	00 
  8028ea:	c7 44 24 08 18 37 80 	movl   $0x803718,0x8(%esp)
  8028f1:	00 
  8028f2:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  8028f9:	00 
  8028fa:	c7 04 24 2d 37 80 00 	movl   $0x80372d,(%esp)
  802901:	e8 86 dc ff ff       	call   80058c <_panic>
  802906:	89 44 24 08          	mov    %eax,0x8(%esp)
  80290a:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802911:	00 
  802912:	8b 45 0c             	mov    0xc(%ebp),%eax
  802915:	89 04 24             	mov    %eax,(%esp)
  802918:	e8 cd e5 ff ff       	call   800eea <memmove>
  80291d:	89 d8                	mov    %ebx,%eax
  80291f:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  802922:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  802925:	89 ec                	mov    %ebp,%esp
  802927:	5d                   	pop    %ebp
  802928:	c3                   	ret    

00802929 <nsipc_connect>:
  802929:	55                   	push   %ebp
  80292a:	89 e5                	mov    %esp,%ebp
  80292c:	53                   	push   %ebx
  80292d:	83 ec 14             	sub    $0x14,%esp
  802930:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802933:	8b 45 08             	mov    0x8(%ebp),%eax
  802936:	a3 00 60 80 00       	mov    %eax,0x806000
  80293b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80293f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802942:	89 44 24 04          	mov    %eax,0x4(%esp)
  802946:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  80294d:	e8 98 e5 ff ff       	call   800eea <memmove>
  802952:	89 1d 14 60 80 00    	mov    %ebx,0x806014
  802958:	b8 05 00 00 00       	mov    $0x5,%eax
  80295d:	e8 fe fd ff ff       	call   802760 <nsipc>
  802962:	83 c4 14             	add    $0x14,%esp
  802965:	5b                   	pop    %ebx
  802966:	5d                   	pop    %ebp
  802967:	c3                   	ret    

00802968 <nsipc_bind>:
  802968:	55                   	push   %ebp
  802969:	89 e5                	mov    %esp,%ebp
  80296b:	53                   	push   %ebx
  80296c:	83 ec 14             	sub    $0x14,%esp
  80296f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802972:	8b 45 08             	mov    0x8(%ebp),%eax
  802975:	a3 00 60 80 00       	mov    %eax,0x806000
  80297a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80297e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802981:	89 44 24 04          	mov    %eax,0x4(%esp)
  802985:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  80298c:	e8 59 e5 ff ff       	call   800eea <memmove>
  802991:	89 1d 14 60 80 00    	mov    %ebx,0x806014
  802997:	b8 02 00 00 00       	mov    $0x2,%eax
  80299c:	e8 bf fd ff ff       	call   802760 <nsipc>
  8029a1:	83 c4 14             	add    $0x14,%esp
  8029a4:	5b                   	pop    %ebx
  8029a5:	5d                   	pop    %ebp
  8029a6:	c3                   	ret    

008029a7 <nsipc_accept>:
  8029a7:	55                   	push   %ebp
  8029a8:	89 e5                	mov    %esp,%ebp
  8029aa:	53                   	push   %ebx
  8029ab:	83 ec 14             	sub    $0x14,%esp
  8029ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8029b1:	a3 00 60 80 00       	mov    %eax,0x806000
  8029b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8029bb:	e8 a0 fd ff ff       	call   802760 <nsipc>
  8029c0:	89 c3                	mov    %eax,%ebx
  8029c2:	85 c0                	test   %eax,%eax
  8029c4:	78 27                	js     8029ed <nsipc_accept+0x46>
  8029c6:	a1 10 60 80 00       	mov    0x806010,%eax
  8029cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8029cf:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8029d6:	00 
  8029d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029da:	89 04 24             	mov    %eax,(%esp)
  8029dd:	e8 08 e5 ff ff       	call   800eea <memmove>
  8029e2:	8b 15 10 60 80 00    	mov    0x806010,%edx
  8029e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8029eb:	89 10                	mov    %edx,(%eax)
  8029ed:	89 d8                	mov    %ebx,%eax
  8029ef:	83 c4 14             	add    $0x14,%esp
  8029f2:	5b                   	pop    %ebx
  8029f3:	5d                   	pop    %ebp
  8029f4:	c3                   	ret    
  8029f5:	00 00                	add    %al,(%eax)
	...

008029f8 <set_pgfault_handler>:
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8029f8:	55                   	push   %ebp
  8029f9:	89 e5                	mov    %esp,%ebp
  8029fb:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8029fe:	83 3d 5c 70 80 00 00 	cmpl   $0x0,0x80705c
  802a05:	75 6a                	jne    802a71 <set_pgfault_handler+0x79>
		// First time through!
		// LAB 4: Your code here.
		env=(struct Env*)&envs[ENVX(sys_getenvid())];
  802a07:	e8 91 ea ff ff       	call   80149d <sys_getenvid>
  802a0c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802a11:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802a14:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802a19:	a3 54 70 80 00       	mov    %eax,0x807054
		if((r=sys_page_alloc(env->env_id,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  802a1e:	8b 40 4c             	mov    0x4c(%eax),%eax
  802a21:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802a28:	00 
  802a29:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802a30:	ee 
  802a31:	89 04 24             	mov    %eax,(%esp)
  802a34:	e8 d1 e9 ff ff       	call   80140a <sys_page_alloc>
  802a39:	85 c0                	test   %eax,%eax
  802a3b:	79 1c                	jns    802a59 <set_pgfault_handler+0x61>
		{
			panic("Alloc a page for an exception stack failed");
  802a3d:	c7 44 24 08 50 37 80 	movl   $0x803750,0x8(%esp)
  802a44:	00 
  802a45:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802a4c:	00 
  802a4d:	c7 04 24 7c 37 80 00 	movl   $0x80377c,(%esp)
  802a54:	e8 33 db ff ff       	call   80058c <_panic>
		}
		sys_env_set_pgfault_upcall(env->env_id,(void*)_pgfault_upcall);
  802a59:	a1 54 70 80 00       	mov    0x807054,%eax
  802a5e:	8b 40 4c             	mov    0x4c(%eax),%eax
  802a61:	c7 44 24 04 7c 2a 80 	movl   $0x802a7c,0x4(%esp)
  802a68:	00 
  802a69:	89 04 24             	mov    %eax,(%esp)
  802a6c:	e8 c3 e7 ff ff       	call   801234 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802a71:	8b 45 08             	mov    0x8(%ebp),%eax
  802a74:	a3 5c 70 80 00       	mov    %eax,0x80705c
}
  802a79:	c9                   	leave  
  802a7a:	c3                   	ret    
	...

00802a7c <_pgfault_upcall>:
.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802a7c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802a7d:	a1 5c 70 80 00       	mov    0x80705c,%eax
	call *%eax
  802a82:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802a84:	83 c4 04             	add    $0x4,%esp
	
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
  802a87:	8b 44 24 28          	mov    0x28(%esp),%eax
	pushl %eax
  802a8b:	50                   	push   %eax
	movl %esp,%eax
  802a8c:	89 e0                	mov    %esp,%eax
	movl 0x34(%eax),%esp  //切换到用户普通栈，压入utf_eip
  802a8e:	8b 60 34             	mov    0x34(%eax),%esp
	pushl (%eax)
  802a91:	ff 30                	pushl  (%eax)
	movl %eax,%esp	     //切到用户异常栈
  802a93:	89 c4                	mov    %eax,%esp
	subl $0x4,0x34(%esp) //将utf->utf_esp减去4,指向返回地址,后面不能算术操作，就在这算
  802a95:	83 6c 24 34 04       	subl   $0x4,0x34(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0xc,%esp     //恢复通用寄存器
  802a9a:	83 c4 0c             	add    $0xc,%esp
	popal
  802a9d:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp  //恢复eflags
  802a9e:	83 c4 04             	add    $0x4,%esp
	popfl          //在用户态，该指令能否修改eflags?可以的
  802aa1:	9d                   	popf   
		       //执行完这个指令后，不能进行算术任何算术运算哦，否则eflags里面的值不对
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp     //切换到用户普通栈，用户从异常处理退出后，需要继续使用该栈
  802aa2:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802aa3:	c3                   	ret    
	...

00802ab0 <inet_ntoa>:
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  802ab0:	55                   	push   %ebp
  802ab1:	89 e5                	mov    %esp,%ebp
  802ab3:	57                   	push   %edi
  802ab4:	56                   	push   %esi
  802ab5:	53                   	push   %ebx
  802ab6:	83 ec 18             	sub    $0x18,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  802ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  802abc:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  char inv[3];
  char *rp;
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  802abf:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  802ac2:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  802ac5:	be 00 00 00 00       	mov    $0x0,%esi
  802aca:	bf 44 70 80 00       	mov    $0x807044,%edi
  802acf:	c6 45 e3 00          	movb   $0x0,0xffffffe3(%ebp)
  802ad3:	eb 02                	jmp    802ad7 <inet_ntoa+0x27>
  802ad5:	89 c6                	mov    %eax,%esi
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  802ad7:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  802ada:	0f b6 0a             	movzbl (%edx),%ecx
      *ap /= (u8_t)10;
  802add:	b8 cd ff ff ff       	mov    $0xffffffcd,%eax
  802ae2:	f6 e1                	mul    %cl
  802ae4:	89 c2                	mov    %eax,%edx
  802ae6:	66 c1 ea 08          	shr    $0x8,%dx
  802aea:	c0 ea 03             	shr    $0x3,%dl
  802aed:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  802af0:	88 10                	mov    %dl,(%eax)
      inv[i++] = '0' + rem;
  802af2:	89 f0                	mov    %esi,%eax
  802af4:	0f b6 d8             	movzbl %al,%ebx
  802af7:	8d 04 92             	lea    (%edx,%edx,4),%eax
  802afa:	01 c0                	add    %eax,%eax
  802afc:	28 c1                	sub    %al,%cl
  802afe:	83 c1 30             	add    $0x30,%ecx
  802b01:	88 4c 1d ed          	mov    %cl,0xffffffed(%ebp,%ebx,1)
  802b05:	8d 46 01             	lea    0x1(%esi),%eax
    } while(*ap);
  802b08:	84 d2                	test   %dl,%dl
  802b0a:	75 c9                	jne    802ad5 <inet_ntoa+0x25>
    while(i--)
  802b0c:	89 f1                	mov    %esi,%ecx
  802b0e:	80 f9 ff             	cmp    $0xff,%cl
  802b11:	74 20                	je     802b33 <inet_ntoa+0x83>
  802b13:	89 fa                	mov    %edi,%edx
      *rp++ = inv[i];
  802b15:	0f b6 c1             	movzbl %cl,%eax
  802b18:	0f b6 44 05 ed       	movzbl 0xffffffed(%ebp,%eax,1),%eax
  802b1d:	88 02                	mov    %al,(%edx)
  802b1f:	83 c2 01             	add    $0x1,%edx
  802b22:	83 e9 01             	sub    $0x1,%ecx
  802b25:	80 f9 ff             	cmp    $0xff,%cl
  802b28:	75 eb                	jne    802b15 <inet_ntoa+0x65>
  802b2a:	89 f2                	mov    %esi,%edx
  802b2c:	0f b6 c2             	movzbl %dl,%eax
  802b2f:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
    *rp++ = '.';
  802b33:	c6 07 2e             	movb   $0x2e,(%edi)
  802b36:	83 c7 01             	add    $0x1,%edi
  802b39:	80 45 e3 01          	addb   $0x1,0xffffffe3(%ebp)
  802b3d:	80 7d e3 03          	cmpb   $0x3,0xffffffe3(%ebp)
  802b41:	77 0b                	ja     802b4e <inet_ntoa+0x9e>
    ap++;
  802b43:	83 45 dc 01          	addl   $0x1,0xffffffdc(%ebp)
  802b47:	b8 00 00 00 00       	mov    $0x0,%eax
  802b4c:	eb 87                	jmp    802ad5 <inet_ntoa+0x25>
  }
  *--rp = 0;
  802b4e:	c6 47 ff 00          	movb   $0x0,0xffffffff(%edi)
  return str;
}
  802b52:	b8 44 70 80 00       	mov    $0x807044,%eax
  802b57:	83 c4 18             	add    $0x18,%esp
  802b5a:	5b                   	pop    %ebx
  802b5b:	5e                   	pop    %esi
  802b5c:	5f                   	pop    %edi
  802b5d:	5d                   	pop    %ebp
  802b5e:	c3                   	ret    

00802b5f <htons>:

/**
 * These are reference implementations of the byte swapping functions.
 * Again with the aim of being simple, correct and fully portable.
 * Byte swapping is the second thing you would want to optimize. You will
 * need to port it to your architecture and in your cc.h:
 * 
 * #define LWIP_PLATFORM_BYTESWAP 1
 * #define LWIP_PLATFORM_HTONS(x) <your_htons>
 * #define LWIP_PLATFORM_HTONL(x) <your_htonl>
 *
 * Note ntohs() and ntohl() are merely references to the htonx counterparts.
 */

#if (LWIP_PLATFORM_BYTESWAP == 0) && (BYTE_ORDER == LITTLE_ENDIAN)

/**
 * Convert an u16_t from host- to network byte order.
 *
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  802b5f:	55                   	push   %ebp
  802b60:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  802b62:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  802b66:	89 c2                	mov    %eax,%edx
  802b68:	c1 ea 08             	shr    $0x8,%edx
  802b6b:	c1 e0 08             	shl    $0x8,%eax
  802b6e:	09 d0                	or     %edx,%eax
  802b70:	0f b7 c0             	movzwl %ax,%eax
}
  802b73:	5d                   	pop    %ebp
  802b74:	c3                   	ret    

00802b75 <ntohs>:

/**
 * Convert an u16_t from network- to host byte order.
 *
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  802b75:	55                   	push   %ebp
  802b76:	89 e5                	mov    %esp,%ebp
  802b78:	83 ec 04             	sub    $0x4,%esp
  return htons(n);
  802b7b:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  802b7f:	89 04 24             	mov    %eax,(%esp)
  802b82:	e8 d8 ff ff ff       	call   802b5f <htons>
  802b87:	0f b7 c0             	movzwl %ax,%eax
}
  802b8a:	c9                   	leave  
  802b8b:	c3                   	ret    

00802b8c <htonl>:

/**
 * Convert an u32_t from host- to network byte order.
 *
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  802b8c:	55                   	push   %ebp
  802b8d:	89 e5                	mov    %esp,%ebp
  802b8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802b92:	89 c8                	mov    %ecx,%eax
  802b94:	25 00 ff 00 00       	and    $0xff00,%eax
  802b99:	c1 e0 08             	shl    $0x8,%eax
  802b9c:	89 ca                	mov    %ecx,%edx
  802b9e:	c1 e2 18             	shl    $0x18,%edx
  802ba1:	09 d0                	or     %edx,%eax
  802ba3:	89 ca                	mov    %ecx,%edx
  802ba5:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  802bab:	c1 ea 08             	shr    $0x8,%edx
  802bae:	09 d0                	or     %edx,%eax
  802bb0:	c1 e9 18             	shr    $0x18,%ecx
  802bb3:	09 c8                	or     %ecx,%eax
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  802bb5:	5d                   	pop    %ebp
  802bb6:	c3                   	ret    

00802bb7 <inet_aton>:
  802bb7:	55                   	push   %ebp
  802bb8:	89 e5                	mov    %esp,%ebp
  802bba:	57                   	push   %edi
  802bbb:	56                   	push   %esi
  802bbc:	53                   	push   %ebx
  802bbd:	83 ec 1c             	sub    $0x1c,%esp
  802bc0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802bc3:	0f be 0b             	movsbl (%ebx),%ecx
  802bc6:	8d 41 d0             	lea    0xffffffd0(%ecx),%eax
  802bc9:	3c 09                	cmp    $0x9,%al
  802bcb:	0f 87 9a 01 00 00    	ja     802d6b <inet_aton+0x1b4>
  802bd1:	8d 45 e4             	lea    0xffffffe4(%ebp),%eax
  802bd4:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  802bd7:	be 0a 00 00 00       	mov    $0xa,%esi
  802bdc:	83 f9 30             	cmp    $0x30,%ecx
  802bdf:	75 20                	jne    802c01 <inet_aton+0x4a>
  802be1:	83 c3 01             	add    $0x1,%ebx
  802be4:	0f be 0b             	movsbl (%ebx),%ecx
  802be7:	83 f9 78             	cmp    $0x78,%ecx
  802bea:	74 0a                	je     802bf6 <inet_aton+0x3f>
  802bec:	be 08 00 00 00       	mov    $0x8,%esi
  802bf1:	83 f9 58             	cmp    $0x58,%ecx
  802bf4:	75 0b                	jne    802c01 <inet_aton+0x4a>
  802bf6:	83 c3 01             	add    $0x1,%ebx
  802bf9:	0f be 0b             	movsbl (%ebx),%ecx
  802bfc:	be 10 00 00 00       	mov    $0x10,%esi
  802c01:	bf 00 00 00 00       	mov    $0x0,%edi
  802c06:	89 ca                	mov    %ecx,%edx
  802c08:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  802c0b:	3c 09                	cmp    $0x9,%al
  802c0d:	77 11                	ja     802c20 <inet_aton+0x69>
  802c0f:	89 f8                	mov    %edi,%eax
  802c11:	0f af c6             	imul   %esi,%eax
  802c14:	8d 7c 08 d0          	lea    0xffffffd0(%eax,%ecx,1),%edi
  802c18:	83 c3 01             	add    $0x1,%ebx
  802c1b:	0f be 0b             	movsbl (%ebx),%ecx
  802c1e:	eb e6                	jmp    802c06 <inet_aton+0x4f>
  802c20:	83 fe 10             	cmp    $0x10,%esi
  802c23:	75 30                	jne    802c55 <inet_aton+0x9e>
  802c25:	8d 42 9f             	lea    0xffffff9f(%edx),%eax
  802c28:	88 45 df             	mov    %al,0xffffffdf(%ebp)
  802c2b:	3c 05                	cmp    $0x5,%al
  802c2d:	76 07                	jbe    802c36 <inet_aton+0x7f>
  802c2f:	8d 42 bf             	lea    0xffffffbf(%edx),%eax
  802c32:	3c 05                	cmp    $0x5,%al
  802c34:	77 1f                	ja     802c55 <inet_aton+0x9e>
  802c36:	80 7d df 1a          	cmpb   $0x1a,0xffffffdf(%ebp)
  802c3a:	19 c0                	sbb    %eax,%eax
  802c3c:	83 e0 20             	and    $0x20,%eax
  802c3f:	29 c1                	sub    %eax,%ecx
  802c41:	8d 41 c9             	lea    0xffffffc9(%ecx),%eax
  802c44:	89 fa                	mov    %edi,%edx
  802c46:	c1 e2 04             	shl    $0x4,%edx
  802c49:	89 c7                	mov    %eax,%edi
  802c4b:	09 d7                	or     %edx,%edi
  802c4d:	83 c3 01             	add    $0x1,%ebx
  802c50:	0f be 0b             	movsbl (%ebx),%ecx
  802c53:	eb b1                	jmp    802c06 <inet_aton+0x4f>
  802c55:	83 f9 2e             	cmp    $0x2e,%ecx
  802c58:	75 2d                	jne    802c87 <inet_aton+0xd0>
  802c5a:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  802c5d:	3b 45 e0             	cmp    0xffffffe0(%ebp),%eax
  802c60:	0f 86 05 01 00 00    	jbe    802d6b <inet_aton+0x1b4>
  802c66:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  802c69:	89 3a                	mov    %edi,(%edx)
  802c6b:	83 c3 01             	add    $0x1,%ebx
  802c6e:	0f be 0b             	movsbl (%ebx),%ecx
  802c71:	8d 41 d0             	lea    0xffffffd0(%ecx),%eax
  802c74:	3c 09                	cmp    $0x9,%al
  802c76:	0f 87 ef 00 00 00    	ja     802d6b <inet_aton+0x1b4>
  802c7c:	83 c2 04             	add    $0x4,%edx
  802c7f:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  802c82:	e9 50 ff ff ff       	jmp    802bd7 <inet_aton+0x20>
  802c87:	89 fb                	mov    %edi,%ebx
  802c89:	85 c9                	test   %ecx,%ecx
  802c8b:	74 2e                	je     802cbb <inet_aton+0x104>
  802c8d:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  802c90:	3c 5f                	cmp    $0x5f,%al
  802c92:	0f 87 d3 00 00 00    	ja     802d6b <inet_aton+0x1b4>
  802c98:	83 f9 20             	cmp    $0x20,%ecx
  802c9b:	74 1e                	je     802cbb <inet_aton+0x104>
  802c9d:	83 f9 0c             	cmp    $0xc,%ecx
  802ca0:	74 19                	je     802cbb <inet_aton+0x104>
  802ca2:	83 f9 0a             	cmp    $0xa,%ecx
  802ca5:	74 14                	je     802cbb <inet_aton+0x104>
  802ca7:	83 f9 0d             	cmp    $0xd,%ecx
  802caa:	74 0f                	je     802cbb <inet_aton+0x104>
  802cac:	83 f9 09             	cmp    $0x9,%ecx
  802caf:	90                   	nop    
  802cb0:	74 09                	je     802cbb <inet_aton+0x104>
  802cb2:	83 f9 0b             	cmp    $0xb,%ecx
  802cb5:	0f 85 b0 00 00 00    	jne    802d6b <inet_aton+0x1b4>
  802cbb:	8d 45 e4             	lea    0xffffffe4(%ebp),%eax
  802cbe:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  802cc1:	29 c2                	sub    %eax,%edx
  802cc3:	89 d0                	mov    %edx,%eax
  802cc5:	c1 f8 02             	sar    $0x2,%eax
  802cc8:	83 c0 01             	add    $0x1,%eax
  802ccb:	83 f8 02             	cmp    $0x2,%eax
  802cce:	74 24                	je     802cf4 <inet_aton+0x13d>
  802cd0:	83 f8 02             	cmp    $0x2,%eax
  802cd3:	7f 0d                	jg     802ce2 <inet_aton+0x12b>
  802cd5:	85 c0                	test   %eax,%eax
  802cd7:	0f 84 8e 00 00 00    	je     802d6b <inet_aton+0x1b4>
  802cdd:	8d 76 00             	lea    0x0(%esi),%esi
  802ce0:	eb 6a                	jmp    802d4c <inet_aton+0x195>
  802ce2:	83 f8 03             	cmp    $0x3,%eax
  802ce5:	74 27                	je     802d0e <inet_aton+0x157>
  802ce7:	83 f8 04             	cmp    $0x4,%eax
  802cea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802cf0:	75 5a                	jne    802d4c <inet_aton+0x195>
  802cf2:	eb 36                	jmp    802d2a <inet_aton+0x173>
  802cf4:	81 fb ff ff ff 00    	cmp    $0xffffff,%ebx
  802cfa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802d00:	77 69                	ja     802d6b <inet_aton+0x1b4>
  802d02:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  802d05:	c1 e0 18             	shl    $0x18,%eax
  802d08:	89 df                	mov    %ebx,%edi
  802d0a:	09 c7                	or     %eax,%edi
  802d0c:	eb 3e                	jmp    802d4c <inet_aton+0x195>
  802d0e:	81 fb ff ff 00 00    	cmp    $0xffff,%ebx
  802d14:	77 55                	ja     802d6b <inet_aton+0x1b4>
  802d16:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
  802d19:	c1 e2 10             	shl    $0x10,%edx
  802d1c:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  802d1f:	c1 e0 18             	shl    $0x18,%eax
  802d22:	09 c2                	or     %eax,%edx
  802d24:	89 d7                	mov    %edx,%edi
  802d26:	09 df                	or     %ebx,%edi
  802d28:	eb 22                	jmp    802d4c <inet_aton+0x195>
  802d2a:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
  802d30:	77 39                	ja     802d6b <inet_aton+0x1b4>
  802d32:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802d35:	c1 e0 10             	shl    $0x10,%eax
  802d38:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  802d3b:	c1 e2 18             	shl    $0x18,%edx
  802d3e:	09 d0                	or     %edx,%eax
  802d40:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  802d43:	c1 e2 08             	shl    $0x8,%edx
  802d46:	09 d0                	or     %edx,%eax
  802d48:	89 c7                	mov    %eax,%edi
  802d4a:	09 df                	or     %ebx,%edi
  802d4c:	b8 01 00 00 00       	mov    $0x1,%eax
  802d51:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802d55:	74 19                	je     802d70 <inet_aton+0x1b9>
  802d57:	89 3c 24             	mov    %edi,(%esp)
  802d5a:	e8 2d fe ff ff       	call   802b8c <htonl>
  802d5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802d62:	89 02                	mov    %eax,(%edx)
  802d64:	b8 01 00 00 00       	mov    $0x1,%eax
  802d69:	eb 05                	jmp    802d70 <inet_aton+0x1b9>
  802d6b:	b8 00 00 00 00       	mov    $0x0,%eax
  802d70:	83 c4 1c             	add    $0x1c,%esp
  802d73:	5b                   	pop    %ebx
  802d74:	5e                   	pop    %esi
  802d75:	5f                   	pop    %edi
  802d76:	5d                   	pop    %ebp
  802d77:	c3                   	ret    

00802d78 <inet_addr>:
  802d78:	55                   	push   %ebp
  802d79:	89 e5                	mov    %esp,%ebp
  802d7b:	83 ec 18             	sub    $0x18,%esp
  802d7e:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  802d81:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d85:	8b 45 08             	mov    0x8(%ebp),%eax
  802d88:	89 04 24             	mov    %eax,(%esp)
  802d8b:	e8 27 fe ff ff       	call   802bb7 <inet_aton>
  802d90:	83 f8 01             	cmp    $0x1,%eax
  802d93:	19 c0                	sbb    %eax,%eax
  802d95:	0b 45 fc             	or     0xfffffffc(%ebp),%eax
  802d98:	c9                   	leave  
  802d99:	c3                   	ret    

00802d9a <ntohl>:

/**
 * Convert an u32_t from network- to host byte order.
 *
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  802d9a:	55                   	push   %ebp
  802d9b:	89 e5                	mov    %esp,%ebp
  802d9d:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  802da0:	8b 45 08             	mov    0x8(%ebp),%eax
  802da3:	89 04 24             	mov    %eax,(%esp)
  802da6:	e8 e1 fd ff ff       	call   802b8c <htonl>
}
  802dab:	c9                   	leave  
  802dac:	c3                   	ret    
  802dad:	00 00                	add    %al,(%eax)
	...

00802db0 <__udivdi3>:
  802db0:	55                   	push   %ebp
  802db1:	89 e5                	mov    %esp,%ebp
  802db3:	57                   	push   %edi
  802db4:	56                   	push   %esi
  802db5:	83 ec 1c             	sub    $0x1c,%esp
  802db8:	8b 45 10             	mov    0x10(%ebp),%eax
  802dbb:	8b 55 14             	mov    0x14(%ebp),%edx
  802dbe:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802dc1:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  802dc4:	89 c1                	mov    %eax,%ecx
  802dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  802dc9:	85 d2                	test   %edx,%edx
  802dcb:	89 d6                	mov    %edx,%esi
  802dcd:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
  802dd0:	75 1e                	jne    802df0 <__udivdi3+0x40>
  802dd2:	39 f9                	cmp    %edi,%ecx
  802dd4:	0f 86 8d 00 00 00    	jbe    802e67 <__udivdi3+0xb7>
  802dda:	89 fa                	mov    %edi,%edx
  802ddc:	f7 f1                	div    %ecx
  802dde:	89 c1                	mov    %eax,%ecx
  802de0:	89 c8                	mov    %ecx,%eax
  802de2:	89 f2                	mov    %esi,%edx
  802de4:	83 c4 1c             	add    $0x1c,%esp
  802de7:	5e                   	pop    %esi
  802de8:	5f                   	pop    %edi
  802de9:	5d                   	pop    %ebp
  802dea:	c3                   	ret    
  802deb:	90                   	nop    
  802dec:	8d 74 26 00          	lea    0x0(%esi),%esi
  802df0:	39 fa                	cmp    %edi,%edx
  802df2:	0f 87 98 00 00 00    	ja     802e90 <__udivdi3+0xe0>
  802df8:	0f bd c2             	bsr    %edx,%eax
  802dfb:	83 f0 1f             	xor    $0x1f,%eax
  802dfe:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  802e01:	74 7f                	je     802e82 <__udivdi3+0xd2>
  802e03:	b8 20 00 00 00       	mov    $0x20,%eax
  802e08:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  802e0b:	2b 45 e4             	sub    0xffffffe4(%ebp),%eax
  802e0e:	89 c1                	mov    %eax,%ecx
  802e10:	d3 ea                	shr    %cl,%edx
  802e12:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802e16:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  802e19:	89 f0                	mov    %esi,%eax
  802e1b:	d3 e0                	shl    %cl,%eax
  802e1d:	09 c2                	or     %eax,%edx
  802e1f:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802e22:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  802e25:	89 fa                	mov    %edi,%edx
  802e27:	d3 e0                	shl    %cl,%eax
  802e29:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  802e2d:	89 45 f4             	mov    %eax,0xfffffff4(%ebp)
  802e30:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802e33:	d3 e8                	shr    %cl,%eax
  802e35:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802e39:	d3 e2                	shl    %cl,%edx
  802e3b:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  802e3f:	09 d0                	or     %edx,%eax
  802e41:	d3 ef                	shr    %cl,%edi
  802e43:	89 fa                	mov    %edi,%edx
  802e45:	f7 75 e0             	divl   0xffffffe0(%ebp)
  802e48:	89 d1                	mov    %edx,%ecx
  802e4a:	89 c7                	mov    %eax,%edi
  802e4c:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  802e4f:	f7 e7                	mul    %edi
  802e51:	39 d1                	cmp    %edx,%ecx
  802e53:	89 c6                	mov    %eax,%esi
  802e55:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  802e58:	72 6f                	jb     802ec9 <__udivdi3+0x119>
  802e5a:	39 ca                	cmp    %ecx,%edx
  802e5c:	74 5e                	je     802ebc <__udivdi3+0x10c>
  802e5e:	89 f9                	mov    %edi,%ecx
  802e60:	31 f6                	xor    %esi,%esi
  802e62:	e9 79 ff ff ff       	jmp    802de0 <__udivdi3+0x30>
  802e67:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802e6a:	85 c0                	test   %eax,%eax
  802e6c:	74 32                	je     802ea0 <__udivdi3+0xf0>
  802e6e:	89 f2                	mov    %esi,%edx
  802e70:	89 f8                	mov    %edi,%eax
  802e72:	f7 f1                	div    %ecx
  802e74:	89 c6                	mov    %eax,%esi
  802e76:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802e79:	f7 f1                	div    %ecx
  802e7b:	89 c1                	mov    %eax,%ecx
  802e7d:	e9 5e ff ff ff       	jmp    802de0 <__udivdi3+0x30>
  802e82:	39 d7                	cmp    %edx,%edi
  802e84:	77 2a                	ja     802eb0 <__udivdi3+0x100>
  802e86:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  802e89:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  802e8c:	73 22                	jae    802eb0 <__udivdi3+0x100>
  802e8e:	66 90                	xchg   %ax,%ax
  802e90:	31 c9                	xor    %ecx,%ecx
  802e92:	31 f6                	xor    %esi,%esi
  802e94:	e9 47 ff ff ff       	jmp    802de0 <__udivdi3+0x30>
  802e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  802ea0:	b8 01 00 00 00       	mov    $0x1,%eax
  802ea5:	31 d2                	xor    %edx,%edx
  802ea7:	f7 75 f0             	divl   0xfffffff0(%ebp)
  802eaa:	89 c1                	mov    %eax,%ecx
  802eac:	eb c0                	jmp    802e6e <__udivdi3+0xbe>
  802eae:	66 90                	xchg   %ax,%ax
  802eb0:	b9 01 00 00 00       	mov    $0x1,%ecx
  802eb5:	31 f6                	xor    %esi,%esi
  802eb7:	e9 24 ff ff ff       	jmp    802de0 <__udivdi3+0x30>
  802ebc:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802ebf:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802ec3:	d3 e0                	shl    %cl,%eax
  802ec5:	39 c6                	cmp    %eax,%esi
  802ec7:	76 95                	jbe    802e5e <__udivdi3+0xae>
  802ec9:	8d 4f ff             	lea    0xffffffff(%edi),%ecx
  802ecc:	31 f6                	xor    %esi,%esi
  802ece:	e9 0d ff ff ff       	jmp    802de0 <__udivdi3+0x30>
	...

00802ee0 <__umoddi3>:
  802ee0:	55                   	push   %ebp
  802ee1:	89 e5                	mov    %esp,%ebp
  802ee3:	57                   	push   %edi
  802ee4:	56                   	push   %esi
  802ee5:	83 ec 30             	sub    $0x30,%esp
  802ee8:	8b 55 14             	mov    0x14(%ebp),%edx
  802eeb:	8b 45 10             	mov    0x10(%ebp),%eax
  802eee:	8b 75 08             	mov    0x8(%ebp),%esi
  802ef1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802ef4:	85 d2                	test   %edx,%edx
  802ef6:	c7 45 d0 00 00 00 00 	movl   $0x0,0xffffffd0(%ebp)
  802efd:	89 c1                	mov    %eax,%ecx
  802eff:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  802f06:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  802f09:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  802f0c:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  802f0f:	89 7d e0             	mov    %edi,0xffffffe0(%ebp)
  802f12:	75 1c                	jne    802f30 <__umoddi3+0x50>
  802f14:	39 f8                	cmp    %edi,%eax
  802f16:	89 fa                	mov    %edi,%edx
  802f18:	0f 86 d4 00 00 00    	jbe    802ff2 <__umoddi3+0x112>
  802f1e:	89 f0                	mov    %esi,%eax
  802f20:	f7 f1                	div    %ecx
  802f22:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802f25:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  802f2c:	eb 12                	jmp    802f40 <__umoddi3+0x60>
  802f2e:	66 90                	xchg   %ax,%ax
  802f30:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802f33:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  802f36:	76 18                	jbe    802f50 <__umoddi3+0x70>
  802f38:	89 75 d0             	mov    %esi,0xffffffd0(%ebp)
  802f3b:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  802f3e:	66 90                	xchg   %ax,%ax
  802f40:	8b 45 d0             	mov    0xffffffd0(%ebp),%eax
  802f43:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  802f46:	83 c4 30             	add    $0x30,%esp
  802f49:	5e                   	pop    %esi
  802f4a:	5f                   	pop    %edi
  802f4b:	5d                   	pop    %ebp
  802f4c:	c3                   	ret    
  802f4d:	8d 76 00             	lea    0x0(%esi),%esi
  802f50:	0f bd 45 e8          	bsr    0xffffffe8(%ebp),%eax
  802f54:	83 f0 1f             	xor    $0x1f,%eax
  802f57:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  802f5a:	0f 84 c0 00 00 00    	je     803020 <__umoddi3+0x140>
  802f60:	b8 20 00 00 00       	mov    $0x20,%eax
  802f65:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  802f68:	2b 45 dc             	sub    0xffffffdc(%ebp),%eax
  802f6b:	8b 7d ec             	mov    0xffffffec(%ebp),%edi
  802f6e:	8b 75 f0             	mov    0xfffffff0(%ebp),%esi
  802f71:	89 c1                	mov    %eax,%ecx
  802f73:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  802f76:	d3 ea                	shr    %cl,%edx
  802f78:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802f7b:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  802f7f:	d3 e0                	shl    %cl,%eax
  802f81:	09 c2                	or     %eax,%edx
  802f83:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802f86:	d3 e7                	shl    %cl,%edi
  802f88:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802f8c:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  802f8f:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  802f92:	d3 e8                	shr    %cl,%eax
  802f94:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  802f98:	d3 e2                	shl    %cl,%edx
  802f9a:	09 d0                	or     %edx,%eax
  802f9c:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  802f9f:	d3 e6                	shl    %cl,%esi
  802fa1:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802fa5:	d3 ea                	shr    %cl,%edx
  802fa7:	f7 75 f4             	divl   0xfffffff4(%ebp)
  802faa:	89 55 cc             	mov    %edx,0xffffffcc(%ebp)
  802fad:	f7 e7                	mul    %edi
  802faf:	39 55 cc             	cmp    %edx,0xffffffcc(%ebp)
  802fb2:	0f 82 a5 00 00 00    	jb     80305d <__umoddi3+0x17d>
  802fb8:	3b 55 cc             	cmp    0xffffffcc(%ebp),%edx
  802fbb:	0f 84 94 00 00 00    	je     803055 <__umoddi3+0x175>
  802fc1:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  802fc4:	29 c6                	sub    %eax,%esi
  802fc6:	19 d1                	sbb    %edx,%ecx
  802fc8:	89 4d cc             	mov    %ecx,0xffffffcc(%ebp)
  802fcb:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  802fcf:	89 f2                	mov    %esi,%edx
  802fd1:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  802fd4:	d3 ea                	shr    %cl,%edx
  802fd6:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802fda:	d3 e0                	shl    %cl,%eax
  802fdc:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  802fe0:	09 c2                	or     %eax,%edx
  802fe2:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  802fe5:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802fe8:	d3 e8                	shr    %cl,%eax
  802fea:	89 45 d4             	mov    %eax,0xffffffd4(%ebp)
  802fed:	e9 4e ff ff ff       	jmp    802f40 <__umoddi3+0x60>
  802ff2:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  802ff5:	85 c0                	test   %eax,%eax
  802ff7:	74 17                	je     803010 <__umoddi3+0x130>
  802ff9:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  802ffc:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
  802fff:	f7 f1                	div    %ecx
  803001:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  803004:	f7 f1                	div    %ecx
  803006:	e9 17 ff ff ff       	jmp    802f22 <__umoddi3+0x42>
  80300b:	90                   	nop    
  80300c:	8d 74 26 00          	lea    0x0(%esi),%esi
  803010:	b8 01 00 00 00       	mov    $0x1,%eax
  803015:	31 d2                	xor    %edx,%edx
  803017:	f7 75 ec             	divl   0xffffffec(%ebp)
  80301a:	89 c1                	mov    %eax,%ecx
  80301c:	eb db                	jmp    802ff9 <__umoddi3+0x119>
  80301e:	66 90                	xchg   %ax,%ax
  803020:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  803023:	39 45 e0             	cmp    %eax,0xffffffe0(%ebp)
  803026:	77 19                	ja     803041 <__umoddi3+0x161>
  803028:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  80302b:	39 55 f0             	cmp    %edx,0xfffffff0(%ebp)
  80302e:	73 11                	jae    803041 <__umoddi3+0x161>
  803030:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  803033:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  803036:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  803039:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  80303c:	e9 ff fe ff ff       	jmp    802f40 <__umoddi3+0x60>
  803041:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  803044:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  803047:	2b 45 ec             	sub    0xffffffec(%ebp),%eax
  80304a:	1b 4d e8             	sbb    0xffffffe8(%ebp),%ecx
  80304d:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  803050:	89 4d e0             	mov    %ecx,0xffffffe0(%ebp)
  803053:	eb db                	jmp    803030 <__umoddi3+0x150>
  803055:	39 f0                	cmp    %esi,%eax
  803057:	0f 86 64 ff ff ff    	jbe    802fc1 <__umoddi3+0xe1>
  80305d:	29 f8                	sub    %edi,%eax
  80305f:	1b 55 f4             	sbb    0xfffffff4(%ebp),%edx
  803062:	e9 5a ff ff ff       	jmp    802fc1 <__umoddi3+0xe1>
