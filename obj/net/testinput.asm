
obj/net/testinput:     file format elf32-i386

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
  80002c:	e8 e3 04 00 00       	call   800514 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:
	}
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
  80004c:	e8 3c 14 00 00       	call   80148d <sys_getenvid>
  800051:	89 c3                	mov    %eax,%ebx
	int i, r;

	binaryname = "testinput";
  800053:	c7 05 00 70 80 00 40 	movl   $0x803040,0x807000
  80005a:	30 80 00 

	output_envid = fork();
  80005d:	e8 07 19 00 00       	call   801969 <fork>
  800062:	a3 3c 70 80 00       	mov    %eax,0x80703c
	if (output_envid < 0)
  800067:	85 c0                	test   %eax,%eax
  800069:	79 1c                	jns    800087 <umain+0x47>
		panic("error forking");
  80006b:	c7 44 24 08 4a 30 80 	movl   $0x80304a,0x8(%esp)
  800072:	00 
  800073:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  80007a:	00 
  80007b:	c7 04 24 58 30 80 00 	movl   $0x803058,(%esp)
  800082:	e8 05 05 00 00       	call   80058c <_panic>
	else if (output_envid == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 0d                	jne    800098 <umain+0x58>
		output(ns_envid);
  80008b:	89 1c 24             	mov    %ebx,(%esp)
  80008e:	e8 71 04 00 00       	call   800504 <output>
  800093:	e9 b9 03 00 00       	jmp    800451 <umain+0x411>
		return;
	}

	input_envid = fork();
  800098:	e8 cc 18 00 00       	call   801969 <fork>
  80009d:	a3 40 70 80 00       	mov    %eax,0x807040
	if (input_envid < 0)
  8000a2:	85 c0                	test   %eax,%eax
  8000a4:	79 1c                	jns    8000c2 <umain+0x82>
		panic("error forking");
  8000a6:	c7 44 24 08 4a 30 80 	movl   $0x80304a,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 58 30 80 00 	movl   $0x803058,(%esp)
  8000bd:	e8 ca 04 00 00       	call   80058c <_panic>
	else if (input_envid == 0) {
  8000c2:	85 c0                	test   %eax,%eax
  8000c4:	75 0f                	jne    8000d5 <umain+0x95>
		input(ns_envid);
  8000c6:	89 1c 24             	mov    %ebx,(%esp)
  8000c9:	e8 26 04 00 00       	call   8004f4 <input>
  8000ce:	66 90                	xchg   %ax,%ax
  8000d0:	e9 7c 03 00 00       	jmp    800451 <umain+0x411>
		return;
	}

	cprintf("Sending ARP announcement...\n");
  8000d5:	c7 04 24 68 30 80 00 	movl   $0x803068,(%esp)
  8000dc:	e8 78 05 00 00       	call   800659 <cprintf>
	// with ARP requests.  Ideally, we would use gratuitous ARP
	// for this, but QEMU's ARP implementation is dumb and only
	// listens for very specific ARP requests, such as requests
	// for the gateway IP.

	uint8_t mac[6] = {0x52, 0x54, 0x00, 0x12, 0x34, 0x56};
  8000e1:	c6 45 9c 52          	movb   $0x52,-0x64(%ebp)
  8000e5:	c6 45 9d 54          	movb   $0x54,-0x63(%ebp)
  8000e9:	c6 45 9e 00          	movb   $0x0,-0x62(%ebp)
  8000ed:	c6 45 9f 12          	movb   $0x12,-0x61(%ebp)
  8000f1:	c6 45 a0 34          	movb   $0x34,-0x60(%ebp)
  8000f5:	c6 45 a1 56          	movb   $0x56,-0x5f(%ebp)
	uint32_t myip = inet_addr(IP);
  8000f9:	c7 04 24 85 30 80 00 	movl   $0x803085,(%esp)
  800100:	e8 59 2c 00 00       	call   802d5e <inet_addr>
  800105:	89 45 f0             	mov    %eax,-0x10(%ebp)
	uint32_t gwip = inet_addr(DEFAULT);
  800108:	c7 04 24 8f 30 80 00 	movl   $0x80308f,(%esp)
  80010f:	e8 4a 2c 00 00       	call   802d5e <inet_addr>
  800114:	89 45 ec             	mov    %eax,-0x14(%ebp)
	int r;

	if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  800117:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80011e:	00 
  80011f:	a1 28 31 80 00       	mov    0x803128,%eax
  800124:	89 44 24 04          	mov    %eax,0x4(%esp)
  800128:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80012f:	e8 c6 12 00 00       	call   8013fa <sys_page_alloc>
  800134:	85 c0                	test   %eax,%eax
  800136:	79 20                	jns    800158 <umain+0x118>
		panic("sys_page_map: %e", r);
  800138:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013c:	c7 44 24 08 98 30 80 	movl   $0x803098,0x8(%esp)
  800143:	00 
  800144:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  80014b:	00 
  80014c:	c7 04 24 58 30 80 00 	movl   $0x803058,(%esp)
  800153:	e8 34 04 00 00       	call   80058c <_panic>

	struct etharp_hdr *arp = (struct etharp_hdr*)pkt->jp_data;
  800158:	8b 1d 28 31 80 00    	mov    0x803128,%ebx
  80015e:	83 c3 04             	add    $0x4,%ebx
	pkt->jp_len = sizeof(*arp);
  800161:	8b 15 28 31 80 00    	mov    0x803128,%edx
  800167:	c7 02 2a 00 00 00    	movl   $0x2a,(%edx)

	memset(arp->ethhdr.dest.addr, 0xff, ETHARP_HWADDR_LEN);
  80016d:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  800174:	00 
  800175:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80017c:	00 
  80017d:	89 1c 24             	mov    %ebx,(%esp)
  800180:	e8 e9 0c 00 00       	call   800e6e <memset>
	memcpy(arp->ethhdr.src.addr,  mac,  ETHARP_HWADDR_LEN);
  800185:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  80018c:	00 
  80018d:	8d 75 9c             	lea    -0x64(%ebp),%esi
  800190:	89 74 24 04          	mov    %esi,0x4(%esp)
  800194:	a1 28 31 80 00       	mov    0x803128,%eax
  800199:	83 c0 0a             	add    $0xa,%eax
  80019c:	89 04 24             	mov    %eax,(%esp)
  80019f:	e8 a4 0d 00 00       	call   800f48 <memcpy>
	arp->ethhdr.type = htons(ETHTYPE_ARP);
  8001a4:	c7 04 24 06 08 00 00 	movl   $0x806,(%esp)
  8001ab:	e8 6f 29 00 00       	call   802b1f <htons>
  8001b0:	66 89 43 0c          	mov    %ax,0xc(%ebx)
	arp->hwtype = htons(1); // Ethernet
  8001b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001bb:	e8 5f 29 00 00       	call   802b1f <htons>
  8001c0:	66 89 43 0e          	mov    %ax,0xe(%ebx)
	arp->proto = htons(ETHTYPE_IP);
  8001c4:	c7 04 24 00 08 00 00 	movl   $0x800,(%esp)
  8001cb:	e8 4f 29 00 00       	call   802b1f <htons>
  8001d0:	66 89 43 10          	mov    %ax,0x10(%ebx)
	arp->_hwlen_protolen = htons((ETHARP_HWADDR_LEN << 8) | 4);
  8001d4:	c7 04 24 04 06 00 00 	movl   $0x604,(%esp)
  8001db:	e8 3f 29 00 00       	call   802b1f <htons>
  8001e0:	66 89 43 12          	mov    %ax,0x12(%ebx)
	arp->opcode = htons(ARP_REQUEST);
  8001e4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001eb:	e8 2f 29 00 00       	call   802b1f <htons>
  8001f0:	66 89 43 14          	mov    %ax,0x14(%ebx)
	memcpy(arp->shwaddr.addr,  mac,   ETHARP_HWADDR_LEN);
  8001f4:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  8001fb:	00 
  8001fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800200:	a1 28 31 80 00       	mov    0x803128,%eax
  800205:	83 c0 1a             	add    $0x1a,%eax
  800208:	89 04 24             	mov    %eax,(%esp)
  80020b:	e8 38 0d 00 00       	call   800f48 <memcpy>
	memcpy(arp->sipaddr.addrw, &myip, 4);
  800210:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800217:	00 
  800218:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80021b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021f:	a1 28 31 80 00       	mov    0x803128,%eax
  800224:	83 c0 20             	add    $0x20,%eax
  800227:	89 04 24             	mov    %eax,(%esp)
  80022a:	e8 19 0d 00 00       	call   800f48 <memcpy>
	memset(arp->dhwaddr.addr,  0x00,  ETHARP_HWADDR_LEN);
  80022f:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  800236:	00 
  800237:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80023e:	00 
  80023f:	a1 28 31 80 00       	mov    0x803128,%eax
  800244:	83 c0 24             	add    $0x24,%eax
  800247:	89 04 24             	mov    %eax,(%esp)
  80024a:	e8 1f 0c 00 00       	call   800e6e <memset>
	memcpy(arp->dipaddr.addrw, &gwip, 4);
  80024f:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800256:	00 
  800257:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80025a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025e:	a1 28 31 80 00       	mov    0x803128,%eax
  800263:	83 c0 2a             	add    $0x2a,%eax
  800266:	89 04 24             	mov    %eax,(%esp)
  800269:	e8 da 0c 00 00       	call   800f48 <memcpy>

	ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  80026e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800275:	00 
  800276:	a1 28 31 80 00       	mov    0x803128,%eax
  80027b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027f:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  800286:	00 
  800287:	a1 3c 70 80 00       	mov    0x80703c,%eax
  80028c:	89 04 24             	mov    %eax,(%esp)
  80028f:	e8 dc 17 00 00       	call   801a70 <ipc_send>
	sys_page_unmap(0, pkt);
  800294:	8b 15 28 31 80 00    	mov    0x803128,%edx
  80029a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80029e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002a5:	e8 94 10 00 00       	call   80133e <sys_page_unmap>
	}

	cprintf("Sending ARP announcement...\n");
	announce();

	cprintf("Waiting for packets...\n");
  8002aa:	c7 04 24 a9 30 80 00 	movl   $0x8030a9,(%esp)
  8002b1:	e8 a3 03 00 00       	call   800659 <cprintf>
	while (1) {
		envid_t whom;
		int perm;

		int32_t req = ipc_recv((int32_t *)&whom, pkt, &perm);
  8002b6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8002b9:	89 45 88             	mov    %eax,-0x78(%ebp)
  8002bc:	8d 55 f0             	lea    -0x10(%ebp),%edx
  8002bf:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002c3:	a1 28 31 80 00       	mov    0x803128,%eax
  8002c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cc:	8d 55 ec             	lea    -0x14(%ebp),%edx
  8002cf:	89 14 24             	mov    %edx,(%esp)
  8002d2:	e8 4d 18 00 00       	call   801b24 <ipc_recv>
		if (req < 0)
  8002d7:	85 c0                	test   %eax,%eax
  8002d9:	79 20                	jns    8002fb <umain+0x2bb>
			panic("ipc_recv: %e", req);
  8002db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002df:	c7 44 24 08 c1 30 80 	movl   $0x8030c1,0x8(%esp)
  8002e6:	00 
  8002e7:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
  8002ee:	00 
  8002ef:	c7 04 24 58 30 80 00 	movl   $0x803058,(%esp)
  8002f6:	e8 91 02 00 00       	call   80058c <_panic>
		if (whom != input_envid)
  8002fb:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8002fe:	3b 15 40 70 80 00    	cmp    0x807040,%edx
  800304:	74 20                	je     800326 <umain+0x2e6>
			panic("IPC from unexpected environment %08x", whom);
  800306:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80030a:	c7 44 24 08 00 31 80 	movl   $0x803100,0x8(%esp)
  800311:	00 
  800312:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  800319:	00 
  80031a:	c7 04 24 58 30 80 00 	movl   $0x803058,(%esp)
  800321:	e8 66 02 00 00       	call   80058c <_panic>
		if (req != NSREQ_INPUT)
  800326:	83 f8 0a             	cmp    $0xa,%eax
  800329:	74 20                	je     80034b <umain+0x30b>
			panic("Unexpected IPC %d", req);
  80032b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80032f:	c7 44 24 08 ce 30 80 	movl   $0x8030ce,0x8(%esp)
  800336:	00 
  800337:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
  80033e:	00 
  80033f:	c7 04 24 58 30 80 00 	movl   $0x803058,(%esp)
  800346:	e8 41 02 00 00       	call   80058c <_panic>

		hexdump("input: ", pkt->jp_data, pkt->jp_len);
  80034b:	a1 28 31 80 00       	mov    0x803128,%eax
  800350:	8b 00                	mov    (%eax),%eax
  800352:	89 45 8c             	mov    %eax,-0x74(%ebp)
  800355:	8b 15 28 31 80 00    	mov    0x803128,%edx
  80035b:	83 c2 04             	add    $0x4,%edx
  80035e:	89 55 90             	mov    %edx,-0x70(%ebp)
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
  800361:	85 c0                	test   %eax,%eax
  800363:	0f 8e d7 00 00 00    	jle    800440 <umain+0x400>
  800369:	bb 00 00 00 00       	mov    $0x0,%ebx
  80036e:	be 00 00 00 00       	mov    $0x0,%esi
		if (i % 16 == 0)
			out = buf + snprintf(buf, end - buf,
  800373:	8d 45 9c             	lea    -0x64(%ebp),%eax
  800376:	89 45 84             	mov    %eax,-0x7c(%ebp)
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
  800379:	89 df                	mov    %ebx,%edi
		if (i % 16 == 0)
  80037b:	f6 c3 0f             	test   $0xf,%bl
  80037e:	75 2e                	jne    8003ae <umain+0x36e>
			out = buf + snprintf(buf, end - buf,
  800380:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800384:	c7 44 24 0c e0 30 80 	movl   $0x8030e0,0xc(%esp)
  80038b:	00 
  80038c:	c7 44 24 08 e8 30 80 	movl   $0x8030e8,0x8(%esp)
  800393:	00 
  800394:	8b 45 88             	mov    -0x78(%ebp),%eax
  800397:	2b 45 84             	sub    -0x7c(%ebp),%eax
  80039a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039e:	8d 55 9c             	lea    -0x64(%ebp),%edx
  8003a1:	89 14 24             	mov    %edx,(%esp)
  8003a4:	e8 71 08 00 00       	call   800c1a <snprintf>
  8003a9:	8d 75 9c             	lea    -0x64(%ebp),%esi
  8003ac:	01 c6                	add    %eax,%esi
					     "%s%04x   ", prefix, i);
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
  8003ae:	8b 55 90             	mov    -0x70(%ebp),%edx
  8003b1:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  8003b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003b9:	c7 44 24 08 f2 30 80 	movl   $0x8030f2,0x8(%esp)
  8003c0:	00 
  8003c1:	8b 45 88             	mov    -0x78(%ebp),%eax
  8003c4:	29 f0                	sub    %esi,%eax
  8003c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ca:	89 34 24             	mov    %esi,(%esp)
  8003cd:	e8 48 08 00 00       	call   800c1a <snprintf>
  8003d2:	01 c6                	add    %eax,%esi
		if (i % 16 == 15 || i == len - 1)
  8003d4:	89 da                	mov    %ebx,%edx
  8003d6:	c1 fa 1f             	sar    $0x1f,%edx
  8003d9:	c1 ea 1c             	shr    $0x1c,%edx
  8003dc:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  8003df:	83 e0 0f             	and    $0xf,%eax
  8003e2:	89 c7                	mov    %eax,%edi
  8003e4:	29 d7                	sub    %edx,%edi
  8003e6:	83 ff 0f             	cmp    $0xf,%edi
  8003e9:	74 0a                	je     8003f5 <umain+0x3b5>
  8003eb:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8003ee:	83 e8 01             	sub    $0x1,%eax
  8003f1:	39 d8                	cmp    %ebx,%eax
  8003f3:	75 1c                	jne    800411 <umain+0x3d1>
			cprintf("%.*s\n", out - buf, buf);
  8003f5:	8d 45 9c             	lea    -0x64(%ebp),%eax
  8003f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003fc:	89 f0                	mov    %esi,%eax
  8003fe:	2b 45 84             	sub    -0x7c(%ebp),%eax
  800401:	89 44 24 04          	mov    %eax,0x4(%esp)
  800405:	c7 04 24 f7 30 80 00 	movl   $0x8030f7,(%esp)
  80040c:	e8 48 02 00 00       	call   800659 <cprintf>
		if (i % 2 == 1)
  800411:	89 da                	mov    %ebx,%edx
  800413:	c1 ea 1f             	shr    $0x1f,%edx
  800416:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  800419:	83 e0 01             	and    $0x1,%eax
  80041c:	29 d0                	sub    %edx,%eax
  80041e:	83 f8 01             	cmp    $0x1,%eax
  800421:	75 06                	jne    800429 <umain+0x3e9>
			*(out++) = ' ';
  800423:	c6 06 20             	movb   $0x20,(%esi)
  800426:	83 c6 01             	add    $0x1,%esi
		if (i % 16 == 7)
  800429:	83 ff 07             	cmp    $0x7,%edi
  80042c:	75 06                	jne    800434 <umain+0x3f4>
			*(out++) = ' ';
  80042e:	c6 06 20             	movb   $0x20,(%esi)
  800431:	83 c6 01             	add    $0x1,%esi
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
  800434:	83 c3 01             	add    $0x1,%ebx
  800437:	3b 5d 8c             	cmp    -0x74(%ebp),%ebx
  80043a:	0f 85 39 ff ff ff    	jne    800379 <umain+0x339>
			panic("IPC from unexpected environment %08x", whom);
		if (req != NSREQ_INPUT)
			panic("Unexpected IPC %d", req);

		hexdump("input: ", pkt->jp_data, pkt->jp_len);
		cprintf("\n");
  800440:	c7 04 24 bf 30 80 00 	movl   $0x8030bf,(%esp)
  800447:	e8 0d 02 00 00       	call   800659 <cprintf>
  80044c:	e9 6b fe ff ff       	jmp    8002bc <umain+0x27c>
	}
}
  800451:	81 c4 8c 00 00 00    	add    $0x8c,%esp
  800457:	5b                   	pop    %ebx
  800458:	5e                   	pop    %esi
  800459:	5f                   	pop    %edi
  80045a:	5d                   	pop    %ebp
  80045b:	c3                   	ret    
  80045c:	00 00                	add    %al,(%eax)
	...

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
  80046c:	e8 ea 0c 00 00       	call   80115b <sys_time_msec>
  800471:	89 c3                	mov    %eax,%ebx
  800473:	03 5d 0c             	add    0xc(%ebp),%ebx

	binaryname = "ns_timer";
  800476:	c7 05 00 70 80 00 2c 	movl   $0x80312c,0x807000
  80047d:	31 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  800480:	8d 75 f0             	lea    -0x10(%ebp),%esi
  800483:	eb 05                	jmp    80048a <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while(sys_time_msec() < stop) {
			sys_yield();
  800485:	e8 cf 0f 00 00       	call   801459 <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while(sys_time_msec() < stop) {
  80048a:	e8 cc 0c 00 00       	call   80115b <sys_time_msec>
  80048f:	39 c3                	cmp    %eax,%ebx
  800491:	77 f2                	ja     800485 <timer+0x25>
			sys_yield();
		}

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  800493:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80049a:	00 
  80049b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004a2:	00 
  8004a3:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
  8004aa:	00 
  8004ab:	89 3c 24             	mov    %edi,(%esp)
  8004ae:	e8 bd 15 00 00       	call   801a70 <ipc_send>

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8004b3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004ba:	00 
  8004bb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004c2:	00 
  8004c3:	89 34 24             	mov    %esi,(%esp)
  8004c6:	e8 59 16 00 00       	call   801b24 <ipc_recv>
  8004cb:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  8004cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004d0:	39 c7                	cmp    %eax,%edi
  8004d2:	74 12                	je     8004e6 <timer+0x86>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  8004d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d8:	c7 04 24 38 31 80 00 	movl   $0x803138,(%esp)
  8004df:	e8 75 01 00 00       	call   800659 <cprintf>
  8004e4:	eb cd                	jmp    8004b3 <timer+0x53>
				continue;
			}

			stop = sys_time_msec() + to;
  8004e6:	e8 70 0c 00 00       	call   80115b <sys_time_msec>
  8004eb:	01 c3                	add    %eax,%ebx
  8004ed:	8d 76 00             	lea    0x0(%esi),%esi
  8004f0:	eb 98                	jmp    80048a <timer+0x2a>
	...

008004f4 <input>:

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_input";
  8004f7:	c7 05 00 70 80 00 73 	movl   $0x803173,0x807000
  8004fe:	31 80 00 
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
  800507:	c7 05 00 70 80 00 7c 	movl   $0x80317c,0x807000
  80050e:	31 80 00 

	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
}
  800511:	5d                   	pop    %ebp
  800512:	c3                   	ret    
	...

00800514 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800514:	55                   	push   %ebp
  800515:	89 e5                	mov    %esp,%ebp
  800517:	83 ec 18             	sub    $0x18,%esp
  80051a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80051d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800520:	8b 75 08             	mov    0x8(%ebp),%esi
  800523:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  800526:	c7 05 54 70 80 00 00 	movl   $0x0,0x807054
  80052d:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  800530:	e8 58 0f 00 00       	call   80148d <sys_getenvid>
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

	// call user main routine
	umain(argc, argv);
  800552:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800556:	89 34 24             	mov    %esi,(%esp)
  800559:	e8 e2 fa ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  80055e:	e8 0d 00 00 00       	call   800570 <exit>
}
  800563:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800566:	8b 75 fc             	mov    -0x4(%ebp),%esi
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
  800576:	e8 85 1c 00 00       	call   802200 <close_all>
	sys_env_destroy(0);
  80057b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800582:	e8 3a 0f 00 00       	call   8014c1 <sys_env_destroy>
}
  800587:	c9                   	leave  
  800588:	c3                   	ret    
  800589:	00 00                	add    %al,(%eax)
	...

0080058c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
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
  800595:	89 45 fc             	mov    %eax,-0x4(%ebp)

	// Print the panic message
	if (argv0)
  800598:	a1 58 70 80 00       	mov    0x807058,%eax
  80059d:	85 c0                	test   %eax,%eax
  80059f:	74 10                	je     8005b1 <_panic+0x25>
		cprintf("%s: ", argv0);
  8005a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a5:	c7 04 24 9d 31 80 00 	movl   $0x80319d,(%esp)
  8005ac:	e8 a8 00 00 00       	call   800659 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8005b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8005bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005bf:	a1 00 70 80 00       	mov    0x807000,%eax
  8005c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c8:	c7 04 24 a2 31 80 00 	movl   $0x8031a2,(%esp)
  8005cf:	e8 85 00 00 00       	call   800659 <cprintf>
	vcprintf(fmt, ap);
  8005d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8005d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005db:	8b 45 10             	mov    0x10(%ebp),%eax
  8005de:	89 04 24             	mov    %eax,(%esp)
  8005e1:	e8 12 00 00 00       	call   8005f8 <vcprintf>
	cprintf("\n");
  8005e6:	c7 04 24 bf 30 80 00 	movl   $0x8030bf,(%esp)
  8005ed:	e8 67 00 00 00       	call   800659 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8005f2:	cc                   	int3   
  8005f3:	eb fd                	jmp    8005f2 <_panic+0x66>
  8005f5:	00 00                	add    %al,(%eax)
	...

008005f8 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8005f8:	55                   	push   %ebp
  8005f9:	89 e5                	mov    %esp,%ebp
  8005fb:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800601:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800608:	00 00 00 
	b.cnt = 0;
  80060b:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  800612:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800615:	8b 45 0c             	mov    0xc(%ebp),%eax
  800618:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80061c:	8b 45 08             	mov    0x8(%ebp),%eax
  80061f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800623:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800629:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062d:	c7 04 24 76 06 80 00 	movl   $0x800676,(%esp)
  800634:	e8 cc 01 00 00       	call   800805 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800639:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
  80063f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800643:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  800649:	89 04 24             	mov    %eax,(%esp)
  80064c:	e8 d7 0a 00 00       	call   801128 <sys_cputs>
  800651:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

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
  800662:	89 45 fc             	mov    %eax,-0x4(%ebp)
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
};


static void
putch(int ch, struct printbuf *b)
{
  800676:	55                   	push   %ebp
  800677:	89 e5                	mov    %esp,%ebp
  800679:	53                   	push   %ebx
  80067a:	83 ec 14             	sub    $0x14,%esp
  80067d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800680:	8b 03                	mov    (%ebx),%eax
  800682:	8b 55 08             	mov    0x8(%ebp),%edx
  800685:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800689:	83 c0 01             	add    $0x1,%eax
  80068c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80068e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800693:	75 19                	jne    8006ae <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800695:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80069c:	00 
  80069d:	8d 43 08             	lea    0x8(%ebx),%eax
  8006a0:	89 04 24             	mov    %eax,(%esp)
  8006a3:	e8 80 0a 00 00       	call   801128 <sys_cputs>
		b->idx = 0;
  8006a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8006ae:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8006b2:	83 c4 14             	add    $0x14,%esp
  8006b5:	5b                   	pop    %ebx
  8006b6:	5d                   	pop    %ebp
  8006b7:	c3                   	ret    
	...

008006c0 <printnum>:
 * using specified putch function and associated pointer putdat.
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
  8006c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006cc:	89 d7                	mov    %edx,%edi
  8006ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006da:	8b 55 10             	mov    0x10(%ebp),%edx
  8006dd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006e0:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8006e3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  8006ea:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006ed:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  8006f0:	72 14                	jb     800706 <printnum+0x46>
  8006f2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006f5:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  8006f8:	76 0c                	jbe    800706 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8006fd:	83 eb 01             	sub    $0x1,%ebx
  800700:	85 db                	test   %ebx,%ebx
  800702:	7f 57                	jg     80075b <printnum+0x9b>
  800704:	eb 64                	jmp    80076a <printnum+0xaa>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800706:	89 74 24 10          	mov    %esi,0x10(%esp)
  80070a:	8b 45 14             	mov    0x14(%ebp),%eax
  80070d:	83 e8 01             	sub    $0x1,%eax
  800710:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800714:	89 54 24 08          	mov    %edx,0x8(%esp)
  800718:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80071c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800720:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800723:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800726:	89 44 24 08          	mov    %eax,0x8(%esp)
  80072a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80072e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800731:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800734:	89 04 24             	mov    %eax,(%esp)
  800737:	89 54 24 04          	mov    %edx,0x4(%esp)
  80073b:	e8 60 26 00 00       	call   802da0 <__udivdi3>
  800740:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800744:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800748:	89 04 24             	mov    %eax,(%esp)
  80074b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80074f:	89 fa                	mov    %edi,%edx
  800751:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800754:	e8 67 ff ff ff       	call   8006c0 <printnum>
  800759:	eb 0f                	jmp    80076a <printnum+0xaa>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80075b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80075f:	89 34 24             	mov    %esi,(%esp)
  800762:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800765:	83 eb 01             	sub    $0x1,%ebx
  800768:	75 f1                	jne    80075b <printnum+0x9b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80076a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800772:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800775:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800778:	89 44 24 08          	mov    %eax,0x8(%esp)
  80077c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800780:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800783:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800786:	89 04 24             	mov    %eax,(%esp)
  800789:	89 54 24 04          	mov    %edx,0x4(%esp)
  80078d:	e8 3e 27 00 00       	call   802ed0 <__umoddi3>
  800792:	89 74 24 04          	mov    %esi,0x4(%esp)
  800796:	0f be 80 be 31 80 00 	movsbl 0x8031be(%eax),%eax
  80079d:	89 04 24             	mov    %eax,(%esp)
  8007a0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8007a3:	83 c4 3c             	add    $0x3c,%esp
  8007a6:	5b                   	pop    %ebx
  8007a7:	5e                   	pop    %esi
  8007a8:	5f                   	pop    %edi
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8007b0:	83 fa 01             	cmp    $0x1,%edx
  8007b3:	7e 0e                	jle    8007c3 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8007b5:	8b 10                	mov    (%eax),%edx
  8007b7:	8d 42 08             	lea    0x8(%edx),%eax
  8007ba:	89 01                	mov    %eax,(%ecx)
  8007bc:	8b 02                	mov    (%edx),%eax
  8007be:	8b 52 04             	mov    0x4(%edx),%edx
  8007c1:	eb 22                	jmp    8007e5 <getuint+0x3a>
	else if (lflag)
  8007c3:	85 d2                	test   %edx,%edx
  8007c5:	74 10                	je     8007d7 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8007c7:	8b 10                	mov    (%eax),%edx
  8007c9:	8d 42 04             	lea    0x4(%edx),%eax
  8007cc:	89 01                	mov    %eax,(%ecx)
  8007ce:	8b 02                	mov    (%edx),%eax
  8007d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d5:	eb 0e                	jmp    8007e5 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8007d7:	8b 10                	mov    (%eax),%edx
  8007d9:	8d 42 04             	lea    0x4(%edx),%eax
  8007dc:	89 01                	mov    %eax,(%ecx)
  8007de:	8b 02                	mov    (%edx),%eax
  8007e0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  8007ed:	83 42 08 01          	addl   $0x1,0x8(%edx)
	if (b->buf < b->ebuf)
  8007f1:	8b 02                	mov    (%edx),%eax
  8007f3:	3b 42 04             	cmp    0x4(%edx),%eax
  8007f6:	73 0b                	jae    800803 <sprintputch+0x1c>
		*b->buf++ = ch;
  8007f8:	0f b6 4d 08          	movzbl 0x8(%ebp),%ecx
  8007fc:	88 08                	mov    %cl,(%eax)
  8007fe:	83 c0 01             	add    $0x1,%eax
  800801:	89 02                	mov    %eax,(%edx)
}
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    

00800805 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	57                   	push   %edi
  800809:	56                   	push   %esi
  80080a:	53                   	push   %ebx
  80080b:	83 ec 3c             	sub    $0x3c,%esp
  80080e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800811:	eb 18                	jmp    80082b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800813:	84 c0                	test   %al,%al
  800815:	0f 84 9f 03 00 00    	je     800bba <vprintfmt+0x3b5>
				return;
			putch(ch, putdat);
  80081b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800822:	0f b6 c0             	movzbl %al,%eax
  800825:	89 04 24             	mov    %eax,(%esp)
  800828:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80082b:	0f b6 03             	movzbl (%ebx),%eax
  80082e:	83 c3 01             	add    $0x1,%ebx
  800831:	3c 25                	cmp    $0x25,%al
  800833:	75 de                	jne    800813 <vprintfmt+0xe>
  800835:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083a:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
  800841:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800846:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80084d:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
  800851:	eb 07                	jmp    80085a <vprintfmt+0x55>
  800853:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085a:	0f b6 13             	movzbl (%ebx),%edx
  80085d:	83 c3 01             	add    $0x1,%ebx
  800860:	8d 42 dd             	lea    -0x23(%edx),%eax
  800863:	3c 55                	cmp    $0x55,%al
  800865:	0f 87 22 03 00 00    	ja     800b8d <vprintfmt+0x388>
  80086b:	0f b6 c0             	movzbl %al,%eax
  80086e:	ff 24 85 00 33 80 00 	jmp    *0x803300(,%eax,4)
  800875:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
  800879:	eb df                	jmp    80085a <vprintfmt+0x55>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80087b:	0f b6 c2             	movzbl %dl,%eax
  80087e:	8d 78 d0             	lea    -0x30(%eax),%edi
				ch = *fmt;
  800881:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800884:	8d 42 d0             	lea    -0x30(%edx),%eax
  800887:	83 f8 09             	cmp    $0x9,%eax
  80088a:	76 08                	jbe    800894 <vprintfmt+0x8f>
  80088c:	eb 39                	jmp    8008c7 <vprintfmt+0xc2>
  80088e:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
  800892:	eb c6                	jmp    80085a <vprintfmt+0x55>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800894:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800897:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  80089a:	8d 7c 42 d0          	lea    -0x30(%edx,%eax,2),%edi
				ch = *fmt;
  80089e:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8008a1:	8d 42 d0             	lea    -0x30(%edx),%eax
  8008a4:	83 f8 09             	cmp    $0x9,%eax
  8008a7:	77 1e                	ja     8008c7 <vprintfmt+0xc2>
  8008a9:	eb e9                	jmp    800894 <vprintfmt+0x8f>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008ab:	8b 55 14             	mov    0x14(%ebp),%edx
  8008ae:	8d 42 04             	lea    0x4(%edx),%eax
  8008b1:	89 45 14             	mov    %eax,0x14(%ebp)
  8008b4:	8b 3a                	mov    (%edx),%edi
  8008b6:	eb 0f                	jmp    8008c7 <vprintfmt+0xc2>
			goto process_precision;

		case '.':
			if (width < 0)
  8008b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8008bc:	79 9c                	jns    80085a <vprintfmt+0x55>
  8008be:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8008c5:	eb 93                	jmp    80085a <vprintfmt+0x55>
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8008c7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8008cb:	90                   	nop    
  8008cc:	8d 74 26 00          	lea    0x0(%esi),%esi
  8008d0:	79 88                	jns    80085a <vprintfmt+0x55>
  8008d2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8008d5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8008da:	e9 7b ff ff ff       	jmp    80085a <vprintfmt+0x55>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008df:	83 c1 01             	add    $0x1,%ecx
  8008e2:	e9 73 ff ff ff       	jmp    80085a <vprintfmt+0x55>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ea:	8d 50 04             	lea    0x4(%eax),%edx
  8008ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8008f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008f7:	8b 00                	mov    (%eax),%eax
  8008f9:	89 04 24             	mov    %eax,(%esp)
  8008fc:	ff 55 08             	call   *0x8(%ebp)
  8008ff:	e9 27 ff ff ff       	jmp    80082b <vprintfmt+0x26>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800904:	8b 55 14             	mov    0x14(%ebp),%edx
  800907:	8d 42 04             	lea    0x4(%edx),%eax
  80090a:	89 45 14             	mov    %eax,0x14(%ebp)
  80090d:	8b 02                	mov    (%edx),%eax
  80090f:	89 c2                	mov    %eax,%edx
  800911:	c1 fa 1f             	sar    $0x1f,%edx
  800914:	31 d0                	xor    %edx,%eax
  800916:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800918:	83 f8 0f             	cmp    $0xf,%eax
  80091b:	7f 0b                	jg     800928 <vprintfmt+0x123>
  80091d:	8b 14 85 60 34 80 00 	mov    0x803460(,%eax,4),%edx
  800924:	85 d2                	test   %edx,%edx
  800926:	75 23                	jne    80094b <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800928:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80092c:	c7 44 24 08 cf 31 80 	movl   $0x8031cf,0x8(%esp)
  800933:	00 
  800934:	8b 45 0c             	mov    0xc(%ebp),%eax
  800937:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093b:	8b 55 08             	mov    0x8(%ebp),%edx
  80093e:	89 14 24             	mov    %edx,(%esp)
  800941:	e8 ff 02 00 00       	call   800c45 <printfmt>
  800946:	e9 e0 fe ff ff       	jmp    80082b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80094b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80094f:	c7 44 24 08 ea 36 80 	movl   $0x8036ea,0x8(%esp)
  800956:	00 
  800957:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095e:	8b 55 08             	mov    0x8(%ebp),%edx
  800961:	89 14 24             	mov    %edx,(%esp)
  800964:	e8 dc 02 00 00       	call   800c45 <printfmt>
  800969:	e9 bd fe ff ff       	jmp    80082b <vprintfmt+0x26>
  80096e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800971:	89 f9                	mov    %edi,%ecx
  800973:	89 5d ec             	mov    %ebx,-0x14(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800976:	8b 55 14             	mov    0x14(%ebp),%edx
  800979:	8d 42 04             	lea    0x4(%edx),%eax
  80097c:	89 45 14             	mov    %eax,0x14(%ebp)
  80097f:	8b 12                	mov    (%edx),%edx
  800981:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800984:	85 d2                	test   %edx,%edx
  800986:	75 07                	jne    80098f <vprintfmt+0x18a>
  800988:	c7 45 dc d8 31 80 00 	movl   $0x8031d8,-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80098f:	85 f6                	test   %esi,%esi
  800991:	7e 41                	jle    8009d4 <vprintfmt+0x1cf>
  800993:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  800997:	74 3b                	je     8009d4 <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
  800999:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80099d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8009a0:	89 04 24             	mov    %eax,(%esp)
  8009a3:	e8 e8 02 00 00       	call   800c90 <strnlen>
  8009a8:	29 c6                	sub    %eax,%esi
  8009aa:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8009ad:	85 f6                	test   %esi,%esi
  8009af:	7e 23                	jle    8009d4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8009b1:	0f be 55 eb          	movsbl -0x15(%ebp),%edx
  8009b5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8009b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8009c2:	89 14 24             	mov    %edx,(%esp)
  8009c5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c8:	83 ee 01             	sub    $0x1,%esi
  8009cb:	75 eb                	jne    8009b8 <vprintfmt+0x1b3>
  8009cd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009d4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009d7:	0f b6 02             	movzbl (%edx),%eax
  8009da:	0f be d0             	movsbl %al,%edx
  8009dd:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8009e0:	84 c0                	test   %al,%al
  8009e2:	75 42                	jne    800a26 <vprintfmt+0x221>
  8009e4:	eb 49                	jmp    800a2f <vprintfmt+0x22a>
				if (altflag && (ch < ' ' || ch > '~'))
  8009e6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009ea:	74 1b                	je     800a07 <vprintfmt+0x202>
  8009ec:	8d 42 e0             	lea    -0x20(%edx),%eax
  8009ef:	83 f8 5e             	cmp    $0x5e,%eax
  8009f2:	76 13                	jbe    800a07 <vprintfmt+0x202>
					putch('?', putdat);
  8009f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009fb:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a02:	ff 55 08             	call   *0x8(%ebp)
  800a05:	eb 0d                	jmp    800a14 <vprintfmt+0x20f>
				else
					putch(ch, putdat);
  800a07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0e:	89 14 24             	mov    %edx,(%esp)
  800a11:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a14:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  800a18:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800a1c:	83 c6 01             	add    $0x1,%esi
  800a1f:	84 c0                	test   %al,%al
  800a21:	74 0c                	je     800a2f <vprintfmt+0x22a>
  800a23:	0f be d0             	movsbl %al,%edx
  800a26:	85 ff                	test   %edi,%edi
  800a28:	78 bc                	js     8009e6 <vprintfmt+0x1e1>
  800a2a:	83 ef 01             	sub    $0x1,%edi
  800a2d:	79 b7                	jns    8009e6 <vprintfmt+0x1e1>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a2f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800a33:	0f 8e f2 fd ff ff    	jle    80082b <vprintfmt+0x26>
				putch(' ', putdat);
  800a39:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a40:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a47:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a4a:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  800a4e:	75 e9                	jne    800a39 <vprintfmt+0x234>
  800a50:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800a53:	e9 d3 fd ff ff       	jmp    80082b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a58:	83 f9 01             	cmp    $0x1,%ecx
  800a5b:	90                   	nop    
  800a5c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800a60:	7e 10                	jle    800a72 <vprintfmt+0x26d>
		return va_arg(*ap, long long);
  800a62:	8b 55 14             	mov    0x14(%ebp),%edx
  800a65:	8d 42 08             	lea    0x8(%edx),%eax
  800a68:	89 45 14             	mov    %eax,0x14(%ebp)
  800a6b:	8b 32                	mov    (%edx),%esi
  800a6d:	8b 7a 04             	mov    0x4(%edx),%edi
  800a70:	eb 2a                	jmp    800a9c <vprintfmt+0x297>
	else if (lflag)
  800a72:	85 c9                	test   %ecx,%ecx
  800a74:	74 14                	je     800a8a <vprintfmt+0x285>
		return va_arg(*ap, long);
  800a76:	8b 45 14             	mov    0x14(%ebp),%eax
  800a79:	8d 50 04             	lea    0x4(%eax),%edx
  800a7c:	89 55 14             	mov    %edx,0x14(%ebp)
  800a7f:	8b 00                	mov    (%eax),%eax
  800a81:	89 c6                	mov    %eax,%esi
  800a83:	89 c7                	mov    %eax,%edi
  800a85:	c1 ff 1f             	sar    $0x1f,%edi
  800a88:	eb 12                	jmp    800a9c <vprintfmt+0x297>
	else
		return va_arg(*ap, int);
  800a8a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8d:	8d 50 04             	lea    0x4(%eax),%edx
  800a90:	89 55 14             	mov    %edx,0x14(%ebp)
  800a93:	8b 00                	mov    (%eax),%eax
  800a95:	89 c6                	mov    %eax,%esi
  800a97:	89 c7                	mov    %eax,%edi
  800a99:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a9c:	89 f2                	mov    %esi,%edx
  800a9e:	89 f9                	mov    %edi,%ecx
  800aa0:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
			if ((long long) num < 0) {
  800aa7:	85 ff                	test   %edi,%edi
  800aa9:	0f 89 9b 00 00 00    	jns    800b4a <vprintfmt+0x345>
				putch('-', putdat);
  800aaf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800abd:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800ac0:	89 f2                	mov    %esi,%edx
  800ac2:	89 f9                	mov    %edi,%ecx
  800ac4:	f7 da                	neg    %edx
  800ac6:	83 d1 00             	adc    $0x0,%ecx
  800ac9:	f7 d9                	neg    %ecx
  800acb:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  800ad2:	eb 76                	jmp    800b4a <vprintfmt+0x345>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800ad4:	89 ca                	mov    %ecx,%edx
  800ad6:	8d 45 14             	lea    0x14(%ebp),%eax
  800ad9:	e8 cd fc ff ff       	call   8007ab <getuint>
  800ade:	89 d1                	mov    %edx,%ecx
  800ae0:	89 c2                	mov    %eax,%edx
  800ae2:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  800ae9:	eb 5f                	jmp    800b4a <vprintfmt+0x345>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap,lflag);
  800aeb:	89 ca                	mov    %ecx,%edx
  800aed:	8d 45 14             	lea    0x14(%ebp),%eax
  800af0:	e8 b6 fc ff ff       	call   8007ab <getuint>
  800af5:	e9 31 fd ff ff       	jmp    80082b <vprintfmt+0x26>
			base=8;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800afa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800afd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b01:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b08:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b12:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b19:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800b1c:	8b 55 14             	mov    0x14(%ebp),%edx
  800b1f:	8d 42 04             	lea    0x4(%edx),%eax
  800b22:	89 45 14             	mov    %eax,0x14(%ebp)
  800b25:	8b 12                	mov    (%edx),%edx
  800b27:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2c:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  800b33:	eb 15                	jmp    800b4a <vprintfmt+0x345>
			base = 16;
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b35:	89 ca                	mov    %ecx,%edx
  800b37:	8d 45 14             	lea    0x14(%ebp),%eax
  800b3a:	e8 6c fc ff ff       	call   8007ab <getuint>
  800b3f:	89 d1                	mov    %edx,%ecx
  800b41:	89 c2                	mov    %eax,%edx
  800b43:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b4a:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800b4e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b55:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b59:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b60:	89 14 24             	mov    %edx,(%esp)
  800b63:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800b67:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6d:	e8 4e fb ff ff       	call   8006c0 <printnum>
  800b72:	e9 b4 fc ff ff       	jmp    80082b <vprintfmt+0x26>
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b77:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7a:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b7e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b85:	ff 55 08             	call   *0x8(%ebp)
  800b88:	e9 9e fc ff ff       	jmp    80082b <vprintfmt+0x26>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b90:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b94:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b9b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b9e:	83 eb 01             	sub    $0x1,%ebx
  800ba1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800ba5:	0f 84 80 fc ff ff    	je     80082b <vprintfmt+0x26>
  800bab:	83 eb 01             	sub    $0x1,%ebx
  800bae:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800bb2:	0f 84 73 fc ff ff    	je     80082b <vprintfmt+0x26>
  800bb8:	eb f1                	jmp    800bab <vprintfmt+0x3a6>
				/* do nothing */;
			break;
		}
	}
}
  800bba:	83 c4 3c             	add    $0x3c,%esp
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	83 ec 28             	sub    $0x28,%esp
  800bc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800bce:	85 d2                	test   %edx,%edx
  800bd0:	74 04                	je     800bd6 <vsnprintf+0x14>
  800bd2:	85 c0                	test   %eax,%eax
  800bd4:	7f 07                	jg     800bdd <vsnprintf+0x1b>
  800bd6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bdb:	eb 3b                	jmp    800c18 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bdd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800be4:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
  800be8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800beb:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bee:	8b 45 14             	mov    0x14(%ebp),%eax
  800bf1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bf5:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bfc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c03:	c7 04 24 e7 07 80 00 	movl   $0x8007e7,(%esp)
  800c0a:	e8 f6 fb ff ff       	call   800805 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c12:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c15:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c18:	c9                   	leave  
  800c19:	c3                   	ret    

00800c1a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c20:	8d 45 14             	lea    0x14(%ebp),%eax
  800c23:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800c26:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c2a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c2d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c31:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c34:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c38:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3b:	89 04 24             	mov    %eax,(%esp)
  800c3e:	e8 7f ff ff ff       	call   800bc2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c43:	c9                   	leave  
  800c44:	c3                   	ret    

00800c45 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800c4b:	8d 45 14             	lea    0x14(%ebp),%eax
  800c4e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800c51:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c55:	8b 45 10             	mov    0x10(%ebp),%eax
  800c58:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c63:	8b 45 08             	mov    0x8(%ebp),%eax
  800c66:	89 04 24             	mov    %eax,(%esp)
  800c69:	e8 97 fb ff ff       	call   800805 <vprintfmt>
	va_end(ap);
}
  800c6e:	c9                   	leave  
  800c6f:	c3                   	ret    

00800c70 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c76:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7b:	80 3a 00             	cmpb   $0x0,(%edx)
  800c7e:	74 0e                	je     800c8e <strlen+0x1e>
  800c80:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800c85:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c88:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  800c8c:	75 f7                	jne    800c85 <strlen+0x15>
		n++;
	return n;
}
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c96:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c99:	85 d2                	test   %edx,%edx
  800c9b:	74 19                	je     800cb6 <strnlen+0x26>
  800c9d:	80 39 00             	cmpb   $0x0,(%ecx)
  800ca0:	74 14                	je     800cb6 <strnlen+0x26>
  800ca2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800ca7:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800caa:	39 d0                	cmp    %edx,%eax
  800cac:	74 0d                	je     800cbb <strnlen+0x2b>
  800cae:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800cb2:	74 07                	je     800cbb <strnlen+0x2b>
  800cb4:	eb f1                	jmp    800ca7 <strnlen+0x17>
  800cb6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800cbb:	5d                   	pop    %ebp
  800cbc:	8d 74 26 00          	lea    0x0(%esi),%esi
  800cc0:	c3                   	ret    

00800cc1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	53                   	push   %ebx
  800cc5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccb:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ccd:	0f b6 01             	movzbl (%ecx),%eax
  800cd0:	88 02                	mov    %al,(%edx)
  800cd2:	83 c2 01             	add    $0x1,%edx
  800cd5:	83 c1 01             	add    $0x1,%ecx
  800cd8:	84 c0                	test   %al,%al
  800cda:	75 f1                	jne    800ccd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800cdc:	89 d8                	mov    %ebx,%eax
  800cde:	5b                   	pop    %ebx
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	57                   	push   %edi
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
  800ce7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ced:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cf0:	85 f6                	test   %esi,%esi
  800cf2:	74 1c                	je     800d10 <strncpy+0x2f>
  800cf4:	89 fa                	mov    %edi,%edx
  800cf6:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  800cfb:	0f b6 01             	movzbl (%ecx),%eax
  800cfe:	88 02                	mov    %al,(%edx)
  800d00:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d03:	80 39 01             	cmpb   $0x1,(%ecx)
  800d06:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d09:	83 c3 01             	add    $0x1,%ebx
  800d0c:	39 f3                	cmp    %esi,%ebx
  800d0e:	75 eb                	jne    800cfb <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d10:	89 f8                	mov    %edi,%eax
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	56                   	push   %esi
  800d1b:	53                   	push   %ebx
  800d1c:	8b 75 08             	mov    0x8(%ebp),%esi
  800d1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d22:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d25:	89 f0                	mov    %esi,%eax
  800d27:	85 d2                	test   %edx,%edx
  800d29:	74 2c                	je     800d57 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800d2b:	89 d3                	mov    %edx,%ebx
  800d2d:	83 eb 01             	sub    $0x1,%ebx
  800d30:	74 20                	je     800d52 <strlcpy+0x3b>
  800d32:	0f b6 11             	movzbl (%ecx),%edx
  800d35:	84 d2                	test   %dl,%dl
  800d37:	74 19                	je     800d52 <strlcpy+0x3b>
  800d39:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800d3b:	88 10                	mov    %dl,(%eax)
  800d3d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d40:	83 eb 01             	sub    $0x1,%ebx
  800d43:	74 0f                	je     800d54 <strlcpy+0x3d>
  800d45:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  800d49:	83 c1 01             	add    $0x1,%ecx
  800d4c:	84 d2                	test   %dl,%dl
  800d4e:	74 04                	je     800d54 <strlcpy+0x3d>
  800d50:	eb e9                	jmp    800d3b <strlcpy+0x24>
  800d52:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d54:	c6 00 00             	movb   $0x0,(%eax)
  800d57:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	56                   	push   %esi
  800d61:	53                   	push   %ebx
  800d62:	8b 75 08             	mov    0x8(%ebp),%esi
  800d65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d68:	8b 55 10             	mov    0x10(%ebp),%edx
    int c;
    char *q = buf;

    if (buf_size <= 0)
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	7e 2e                	jle    800d9d <pstrcpy+0x40>
        return;

    for(;;) {
        c = *str++;
  800d6f:	0f b6 0a             	movzbl (%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  800d72:	84 c9                	test   %cl,%cl
  800d74:	74 22                	je     800d98 <pstrcpy+0x3b>
  800d76:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  800d7a:	89 f0                	mov    %esi,%eax
  800d7c:	39 de                	cmp    %ebx,%esi
  800d7e:	72 09                	jb     800d89 <pstrcpy+0x2c>
  800d80:	eb 16                	jmp    800d98 <pstrcpy+0x3b>
  800d82:	83 c2 01             	add    $0x1,%edx
  800d85:	39 d8                	cmp    %ebx,%eax
  800d87:	73 11                	jae    800d9a <pstrcpy+0x3d>
            break;
        *q++ = c;
  800d89:	88 08                	mov    %cl,(%eax)
  800d8b:	83 c0 01             	add    $0x1,%eax

    if (buf_size <= 0)
        return;

    for(;;) {
        c = *str++;
  800d8e:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  800d92:	84 c9                	test   %cl,%cl
  800d94:	75 ec                	jne    800d82 <pstrcpy+0x25>
  800d96:	eb 02                	jmp    800d9a <pstrcpy+0x3d>
  800d98:	89 f0                	mov    %esi,%eax
            break;
        *q++ = c;
    }
    *q = '\0';
  800d9a:	c6 00 00             	movb   $0x0,(%eax)
}
  800d9d:	5b                   	pop    %ebx
  800d9e:	5e                   	pop    %esi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  800daa:	0f b6 02             	movzbl (%edx),%eax
  800dad:	84 c0                	test   %al,%al
  800daf:	74 16                	je     800dc7 <strcmp+0x26>
  800db1:	3a 01                	cmp    (%ecx),%al
  800db3:	75 12                	jne    800dc7 <strcmp+0x26>
		p++, q++;
  800db5:	83 c1 01             	add    $0x1,%ecx
    *q = '\0';
}
int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800db8:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  800dbc:	84 c0                	test   %al,%al
  800dbe:	74 07                	je     800dc7 <strcmp+0x26>
  800dc0:	83 c2 01             	add    $0x1,%edx
  800dc3:	3a 01                	cmp    (%ecx),%al
  800dc5:	74 ee                	je     800db5 <strcmp+0x14>
  800dc7:	0f b6 c0             	movzbl %al,%eax
  800dca:	0f b6 11             	movzbl (%ecx),%edx
  800dcd:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800dcf:	5d                   	pop    %ebp
  800dd0:	c3                   	ret    

00800dd1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	53                   	push   %ebx
  800dd5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ddb:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800dde:	85 d2                	test   %edx,%edx
  800de0:	74 2d                	je     800e0f <strncmp+0x3e>
  800de2:	0f b6 01             	movzbl (%ecx),%eax
  800de5:	84 c0                	test   %al,%al
  800de7:	74 1a                	je     800e03 <strncmp+0x32>
  800de9:	3a 03                	cmp    (%ebx),%al
  800deb:	75 16                	jne    800e03 <strncmp+0x32>
  800ded:	83 ea 01             	sub    $0x1,%edx
  800df0:	74 1d                	je     800e0f <strncmp+0x3e>
		n--, p++, q++;
  800df2:	83 c1 01             	add    $0x1,%ecx
  800df5:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800df8:	0f b6 01             	movzbl (%ecx),%eax
  800dfb:	84 c0                	test   %al,%al
  800dfd:	74 04                	je     800e03 <strncmp+0x32>
  800dff:	3a 03                	cmp    (%ebx),%al
  800e01:	74 ea                	je     800ded <strncmp+0x1c>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e03:	0f b6 11             	movzbl (%ecx),%edx
  800e06:	0f b6 03             	movzbl (%ebx),%eax
  800e09:	29 c2                	sub    %eax,%edx
  800e0b:	89 d0                	mov    %edx,%eax
  800e0d:	eb 05                	jmp    800e14 <strncmp+0x43>
  800e0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e14:	5b                   	pop    %ebx
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    

00800e17 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e21:	0f b6 10             	movzbl (%eax),%edx
  800e24:	84 d2                	test   %dl,%dl
  800e26:	74 14                	je     800e3c <strchr+0x25>
		if (*s == c)
  800e28:	38 ca                	cmp    %cl,%dl
  800e2a:	75 06                	jne    800e32 <strchr+0x1b>
  800e2c:	eb 13                	jmp    800e41 <strchr+0x2a>
  800e2e:	38 ca                	cmp    %cl,%dl
  800e30:	74 0f                	je     800e41 <strchr+0x2a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e32:	83 c0 01             	add    $0x1,%eax
  800e35:	0f b6 10             	movzbl (%eax),%edx
  800e38:	84 d2                	test   %dl,%dl
  800e3a:	75 f2                	jne    800e2e <strchr+0x17>
  800e3c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    

00800e43 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	8b 45 08             	mov    0x8(%ebp),%eax
  800e49:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e4d:	0f b6 10             	movzbl (%eax),%edx
  800e50:	84 d2                	test   %dl,%dl
  800e52:	74 18                	je     800e6c <strfind+0x29>
		if (*s == c)
  800e54:	38 ca                	cmp    %cl,%dl
  800e56:	75 0a                	jne    800e62 <strfind+0x1f>
  800e58:	eb 12                	jmp    800e6c <strfind+0x29>
  800e5a:	38 ca                	cmp    %cl,%dl
  800e5c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800e60:	74 0a                	je     800e6c <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e62:	83 c0 01             	add    $0x1,%eax
  800e65:	0f b6 10             	movzbl (%eax),%edx
  800e68:	84 d2                	test   %dl,%dl
  800e6a:	75 ee                	jne    800e5a <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800e6c:	5d                   	pop    %ebp
  800e6d:	c3                   	ret    

00800e6e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	83 ec 08             	sub    $0x8,%esp
  800e74:	89 1c 24             	mov    %ebx,(%esp)
  800e77:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e7b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800e81:	85 db                	test   %ebx,%ebx
  800e83:	74 36                	je     800ebb <memset+0x4d>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e85:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e8b:	75 26                	jne    800eb3 <memset+0x45>
  800e8d:	f6 c3 03             	test   $0x3,%bl
  800e90:	75 21                	jne    800eb3 <memset+0x45>
		c &= 0xFF;
  800e92:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e96:	89 d0                	mov    %edx,%eax
  800e98:	c1 e0 18             	shl    $0x18,%eax
  800e9b:	89 d1                	mov    %edx,%ecx
  800e9d:	c1 e1 10             	shl    $0x10,%ecx
  800ea0:	09 c8                	or     %ecx,%eax
  800ea2:	09 d0                	or     %edx,%eax
  800ea4:	c1 e2 08             	shl    $0x8,%edx
  800ea7:	09 d0                	or     %edx,%eax
  800ea9:	89 d9                	mov    %ebx,%ecx
  800eab:	c1 e9 02             	shr    $0x2,%ecx
  800eae:	fc                   	cld    
  800eaf:	f3 ab                	rep stos %eax,%es:(%edi)
  800eb1:	eb 08                	jmp    800ebb <memset+0x4d>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eb6:	89 d9                	mov    %ebx,%ecx
  800eb8:	fc                   	cld    
  800eb9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ebb:	89 f8                	mov    %edi,%eax
  800ebd:	8b 1c 24             	mov    (%esp),%ebx
  800ec0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ec4:	89 ec                	mov    %ebp,%esp
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    

00800ec8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	83 ec 08             	sub    $0x8,%esp
  800ece:	89 34 24             	mov    %esi,(%esp)
  800ed1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ed5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800edb:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800ede:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800ee0:	39 c6                	cmp    %eax,%esi
  800ee2:	73 38                	jae    800f1c <memmove+0x54>
  800ee4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ee7:	39 d0                	cmp    %edx,%eax
  800ee9:	73 31                	jae    800f1c <memmove+0x54>
		s += n;
		d += n;
  800eeb:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eee:	f6 c2 03             	test   $0x3,%dl
  800ef1:	75 1d                	jne    800f10 <memmove+0x48>
  800ef3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ef9:	75 15                	jne    800f10 <memmove+0x48>
  800efb:	f6 c1 03             	test   $0x3,%cl
  800efe:	66 90                	xchg   %ax,%ax
  800f00:	75 0e                	jne    800f10 <memmove+0x48>
			asm volatile("std; rep movsl\n"
  800f02:	8d 7e fc             	lea    -0x4(%esi),%edi
  800f05:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f08:	c1 e9 02             	shr    $0x2,%ecx
  800f0b:	fd                   	std    
  800f0c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f0e:	eb 09                	jmp    800f19 <memmove+0x51>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f10:	8d 7e ff             	lea    -0x1(%esi),%edi
  800f13:	8d 72 ff             	lea    -0x1(%edx),%esi
  800f16:	fd                   	std    
  800f17:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f19:	fc                   	cld    
  800f1a:	eb 21                	jmp    800f3d <memmove+0x75>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f1c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f22:	75 16                	jne    800f3a <memmove+0x72>
  800f24:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f2a:	75 0e                	jne    800f3a <memmove+0x72>
  800f2c:	f6 c1 03             	test   $0x3,%cl
  800f2f:	90                   	nop    
  800f30:	75 08                	jne    800f3a <memmove+0x72>
			asm volatile("cld; rep movsl\n"
  800f32:	c1 e9 02             	shr    $0x2,%ecx
  800f35:	fc                   	cld    
  800f36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f38:	eb 03                	jmp    800f3d <memmove+0x75>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f3a:	fc                   	cld    
  800f3b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f3d:	8b 34 24             	mov    (%esp),%esi
  800f40:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f44:	89 ec                	mov    %ebp,%esp
  800f46:	5d                   	pop    %ebp
  800f47:	c3                   	ret    

00800f48 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800f48:	55                   	push   %ebp
  800f49:	89 e5                	mov    %esp,%ebp
  800f4b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f4e:	8b 45 10             	mov    0x10(%ebp),%eax
  800f51:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f58:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5f:	89 04 24             	mov    %eax,(%esp)
  800f62:	e8 61 ff ff ff       	call   800ec8 <memmove>
}
  800f67:	c9                   	leave  
  800f68:	c3                   	ret    

00800f69 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	57                   	push   %edi
  800f6d:	56                   	push   %esi
  800f6e:	53                   	push   %ebx
  800f6f:	83 ec 04             	sub    $0x4,%esp
  800f72:	8b 45 08             	mov    0x8(%ebp),%eax
  800f75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f78:	8b 55 10             	mov    0x10(%ebp),%edx
  800f7b:	83 ea 01             	sub    $0x1,%edx
  800f7e:	83 fa ff             	cmp    $0xffffffff,%edx
  800f81:	74 47                	je     800fca <memcmp+0x61>
		if (*s1 != *s2)
  800f83:	0f b6 30             	movzbl (%eax),%esi
  800f86:	0f b6 39             	movzbl (%ecx),%edi
			return (int) *s1 - (int) *s2;
  800f89:	89 45 f0             	mov    %eax,-0x10(%ebp)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800f8c:	89 f0                	mov    %esi,%eax
  800f8e:	89 fb                	mov    %edi,%ebx
  800f90:	38 d8                	cmp    %bl,%al
  800f92:	74 2e                	je     800fc2 <memcmp+0x59>
  800f94:	eb 1c                	jmp    800fb2 <memcmp+0x49>
  800f96:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f99:	0f b6 70 01          	movzbl 0x1(%eax),%esi
  800f9d:	0f b6 79 01          	movzbl 0x1(%ecx),%edi
  800fa1:	83 c0 01             	add    $0x1,%eax
  800fa4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800fa7:	83 c1 01             	add    $0x1,%ecx
  800faa:	89 f3                	mov    %esi,%ebx
  800fac:	89 f8                	mov    %edi,%eax
  800fae:	38 c3                	cmp    %al,%bl
  800fb0:	74 10                	je     800fc2 <memcmp+0x59>
			return (int) *s1 - (int) *s2;
  800fb2:	89 f1                	mov    %esi,%ecx
  800fb4:	0f b6 d1             	movzbl %cl,%edx
  800fb7:	89 fb                	mov    %edi,%ebx
  800fb9:	0f b6 c3             	movzbl %bl,%eax
  800fbc:	29 c2                	sub    %eax,%edx
  800fbe:	89 d0                	mov    %edx,%eax
  800fc0:	eb 0d                	jmp    800fcf <memcmp+0x66>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fc2:	83 ea 01             	sub    $0x1,%edx
  800fc5:	83 fa ff             	cmp    $0xffffffff,%edx
  800fc8:	75 cc                	jne    800f96 <memcmp+0x2d>
  800fca:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800fcf:	83 c4 04             	add    $0x4,%esp
  800fd2:	5b                   	pop    %ebx
  800fd3:	5e                   	pop    %esi
  800fd4:	5f                   	pop    %edi
  800fd5:	5d                   	pop    %ebp
  800fd6:	c3                   	ret    

00800fd7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800fdd:	89 c1                	mov    %eax,%ecx
  800fdf:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
  800fe2:	39 c8                	cmp    %ecx,%eax
  800fe4:	73 15                	jae    800ffb <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fe6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
  800fea:	38 10                	cmp    %dl,(%eax)
  800fec:	75 06                	jne    800ff4 <memfind+0x1d>
  800fee:	eb 0b                	jmp    800ffb <memfind+0x24>
  800ff0:	38 10                	cmp    %dl,(%eax)
  800ff2:	74 07                	je     800ffb <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ff4:	83 c0 01             	add    $0x1,%eax
  800ff7:	39 c8                	cmp    %ecx,%eax
  800ff9:	75 f5                	jne    800ff0 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ffb:	5d                   	pop    %ebp
  800ffc:	8d 74 26 00          	lea    0x0(%esi),%esi
  801000:	c3                   	ret    

00801001 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	57                   	push   %edi
  801005:	56                   	push   %esi
  801006:	53                   	push   %ebx
  801007:	83 ec 04             	sub    $0x4,%esp
  80100a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80100d:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801010:	0f b6 01             	movzbl (%ecx),%eax
  801013:	3c 20                	cmp    $0x20,%al
  801015:	74 04                	je     80101b <strtol+0x1a>
  801017:	3c 09                	cmp    $0x9,%al
  801019:	75 0e                	jne    801029 <strtol+0x28>
		s++;
  80101b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80101e:	0f b6 01             	movzbl (%ecx),%eax
  801021:	3c 20                	cmp    $0x20,%al
  801023:	74 f6                	je     80101b <strtol+0x1a>
  801025:	3c 09                	cmp    $0x9,%al
  801027:	74 f2                	je     80101b <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801029:	3c 2b                	cmp    $0x2b,%al
  80102b:	75 0c                	jne    801039 <strtol+0x38>
		s++;
  80102d:	83 c1 01             	add    $0x1,%ecx
  801030:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801037:	eb 15                	jmp    80104e <strtol+0x4d>
	else if (*s == '-')
  801039:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801040:	3c 2d                	cmp    $0x2d,%al
  801042:	75 0a                	jne    80104e <strtol+0x4d>
		s++, neg = 1;
  801044:	83 c1 01             	add    $0x1,%ecx
  801047:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80104e:	85 f6                	test   %esi,%esi
  801050:	0f 94 c0             	sete   %al
  801053:	74 05                	je     80105a <strtol+0x59>
  801055:	83 fe 10             	cmp    $0x10,%esi
  801058:	75 18                	jne    801072 <strtol+0x71>
  80105a:	80 39 30             	cmpb   $0x30,(%ecx)
  80105d:	75 13                	jne    801072 <strtol+0x71>
  80105f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801063:	75 0d                	jne    801072 <strtol+0x71>
		s += 2, base = 16;
  801065:	83 c1 02             	add    $0x2,%ecx
  801068:	be 10 00 00 00       	mov    $0x10,%esi
  80106d:	8d 76 00             	lea    0x0(%esi),%esi
  801070:	eb 1b                	jmp    80108d <strtol+0x8c>
	else if (base == 0 && s[0] == '0')
  801072:	85 f6                	test   %esi,%esi
  801074:	75 0e                	jne    801084 <strtol+0x83>
  801076:	80 39 30             	cmpb   $0x30,(%ecx)
  801079:	75 09                	jne    801084 <strtol+0x83>
		s++, base = 8;
  80107b:	83 c1 01             	add    $0x1,%ecx
  80107e:	66 be 08 00          	mov    $0x8,%si
  801082:	eb 09                	jmp    80108d <strtol+0x8c>
	else if (base == 0)
  801084:	84 c0                	test   %al,%al
  801086:	74 05                	je     80108d <strtol+0x8c>
  801088:	be 0a 00 00 00       	mov    $0xa,%esi
  80108d:	bf 00 00 00 00       	mov    $0x0,%edi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801092:	0f b6 11             	movzbl (%ecx),%edx
  801095:	89 d3                	mov    %edx,%ebx
  801097:	8d 42 d0             	lea    -0x30(%edx),%eax
  80109a:	3c 09                	cmp    $0x9,%al
  80109c:	77 08                	ja     8010a6 <strtol+0xa5>
			dig = *s - '0';
  80109e:	0f be c2             	movsbl %dl,%eax
  8010a1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8010a4:	eb 1c                	jmp    8010c2 <strtol+0xc1>
		else if (*s >= 'a' && *s <= 'z')
  8010a6:	8d 43 9f             	lea    -0x61(%ebx),%eax
  8010a9:	3c 19                	cmp    $0x19,%al
  8010ab:	77 08                	ja     8010b5 <strtol+0xb4>
			dig = *s - 'a' + 10;
  8010ad:	0f be c2             	movsbl %dl,%eax
  8010b0:	8d 50 a9             	lea    -0x57(%eax),%edx
  8010b3:	eb 0d                	jmp    8010c2 <strtol+0xc1>
		else if (*s >= 'A' && *s <= 'Z')
  8010b5:	8d 43 bf             	lea    -0x41(%ebx),%eax
  8010b8:	3c 19                	cmp    $0x19,%al
  8010ba:	77 17                	ja     8010d3 <strtol+0xd2>
			dig = *s - 'A' + 10;
  8010bc:	0f be c2             	movsbl %dl,%eax
  8010bf:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  8010c2:	39 f2                	cmp    %esi,%edx
  8010c4:	7d 0d                	jge    8010d3 <strtol+0xd2>
			break;
		s++, val = (val * base) + dig;
  8010c6:	83 c1 01             	add    $0x1,%ecx
  8010c9:	89 f8                	mov    %edi,%eax
  8010cb:	0f af c6             	imul   %esi,%eax
  8010ce:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  8010d1:	eb bf                	jmp    801092 <strtol+0x91>
		// we don't properly detect overflow!
	}
  8010d3:	89 f8                	mov    %edi,%eax

	if (endptr)
  8010d5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8010d9:	74 05                	je     8010e0 <strtol+0xdf>
		*endptr = (char *) s;
  8010db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010de:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  8010e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8010e4:	74 04                	je     8010ea <strtol+0xe9>
  8010e6:	89 c7                	mov    %eax,%edi
  8010e8:	f7 df                	neg    %edi
}
  8010ea:	89 f8                	mov    %edi,%eax
  8010ec:	83 c4 04             	add    $0x4,%esp
  8010ef:	5b                   	pop    %ebx
  8010f0:	5e                   	pop    %esi
  8010f1:	5f                   	pop    %edi
  8010f2:	5d                   	pop    %ebp
  8010f3:	c3                   	ret    

008010f4 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	83 ec 0c             	sub    $0xc,%esp
  8010fa:	89 1c 24             	mov    %ebx,(%esp)
  8010fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801101:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801105:	b8 01 00 00 00       	mov    $0x1,%eax
  80110a:	bf 00 00 00 00       	mov    $0x0,%edi
  80110f:	89 fa                	mov    %edi,%edx
  801111:	89 f9                	mov    %edi,%ecx
  801113:	89 fb                	mov    %edi,%ebx
  801115:	89 fe                	mov    %edi,%esi
  801117:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801119:	8b 1c 24             	mov    (%esp),%ebx
  80111c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801120:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801124:	89 ec                	mov    %ebp,%esp
  801126:	5d                   	pop    %ebp
  801127:	c3                   	ret    

00801128 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	83 ec 0c             	sub    $0xc,%esp
  80112e:	89 1c 24             	mov    %ebx,(%esp)
  801131:	89 74 24 04          	mov    %esi,0x4(%esp)
  801135:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801139:	8b 55 08             	mov    0x8(%ebp),%edx
  80113c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113f:	bf 00 00 00 00       	mov    $0x0,%edi
  801144:	89 f8                	mov    %edi,%eax
  801146:	89 fb                	mov    %edi,%ebx
  801148:	89 fe                	mov    %edi,%esi
  80114a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80114c:	8b 1c 24             	mov    (%esp),%ebx
  80114f:	8b 74 24 04          	mov    0x4(%esp),%esi
  801153:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801157:	89 ec                	mov    %ebp,%esp
  801159:	5d                   	pop    %ebp
  80115a:	c3                   	ret    

0080115b <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
  80115e:	83 ec 0c             	sub    $0xc,%esp
  801161:	89 1c 24             	mov    %ebx,(%esp)
  801164:	89 74 24 04          	mov    %esi,0x4(%esp)
  801168:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80116c:	b8 0e 00 00 00       	mov    $0xe,%eax
  801171:	bf 00 00 00 00       	mov    $0x0,%edi
  801176:	89 fa                	mov    %edi,%edx
  801178:	89 f9                	mov    %edi,%ecx
  80117a:	89 fb                	mov    %edi,%ebx
  80117c:	89 fe                	mov    %edi,%esi
  80117e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801180:	8b 1c 24             	mov    (%esp),%ebx
  801183:	8b 74 24 04          	mov    0x4(%esp),%esi
  801187:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80118b:	89 ec                	mov    %ebp,%esp
  80118d:	5d                   	pop    %ebp
  80118e:	c3                   	ret    

0080118f <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
  801192:	83 ec 28             	sub    $0x28,%esp
  801195:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801198:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80119b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80119e:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8011a6:	bf 00 00 00 00       	mov    $0x0,%edi
  8011ab:	89 f9                	mov    %edi,%ecx
  8011ad:	89 fb                	mov    %edi,%ebx
  8011af:	89 fe                	mov    %edi,%esi
  8011b1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	7e 28                	jle    8011df <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011bb:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8011c2:	00 
  8011c3:	c7 44 24 08 bf 34 80 	movl   $0x8034bf,0x8(%esp)
  8011ca:	00 
  8011cb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011d2:	00 
  8011d3:	c7 04 24 dc 34 80 00 	movl   $0x8034dc,(%esp)
  8011da:	e8 ad f3 ff ff       	call   80058c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011df:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011e2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011e5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011e8:	89 ec                	mov    %ebp,%esp
  8011ea:	5d                   	pop    %ebp
  8011eb:	c3                   	ret    

008011ec <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	83 ec 0c             	sub    $0xc,%esp
  8011f2:	89 1c 24             	mov    %ebx,(%esp)
  8011f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011f9:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8011fd:	8b 55 08             	mov    0x8(%ebp),%edx
  801200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801203:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801206:	8b 7d 14             	mov    0x14(%ebp),%edi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801209:	b8 0c 00 00 00       	mov    $0xc,%eax
  80120e:	be 00 00 00 00       	mov    $0x0,%esi
  801213:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801215:	8b 1c 24             	mov    (%esp),%ebx
  801218:	8b 74 24 04          	mov    0x4(%esp),%esi
  80121c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801220:	89 ec                	mov    %ebp,%esp
  801222:	5d                   	pop    %ebp
  801223:	c3                   	ret    

00801224 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
  801227:	83 ec 28             	sub    $0x28,%esp
  80122a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80122d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801230:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801233:	8b 55 08             	mov    0x8(%ebp),%edx
  801236:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801239:	b8 0a 00 00 00       	mov    $0xa,%eax
  80123e:	bf 00 00 00 00       	mov    $0x0,%edi
  801243:	89 fb                	mov    %edi,%ebx
  801245:	89 fe                	mov    %edi,%esi
  801247:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801249:	85 c0                	test   %eax,%eax
  80124b:	7e 28                	jle    801275 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80124d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801251:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801258:	00 
  801259:	c7 44 24 08 bf 34 80 	movl   $0x8034bf,0x8(%esp)
  801260:	00 
  801261:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801268:	00 
  801269:	c7 04 24 dc 34 80 00 	movl   $0x8034dc,(%esp)
  801270:	e8 17 f3 ff ff       	call   80058c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801275:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801278:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80127b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80127e:	89 ec                	mov    %ebp,%esp
  801280:	5d                   	pop    %ebp
  801281:	c3                   	ret    

00801282 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	83 ec 28             	sub    $0x28,%esp
  801288:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80128b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80128e:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801291:	8b 55 08             	mov    0x8(%ebp),%edx
  801294:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801297:	b8 09 00 00 00       	mov    $0x9,%eax
  80129c:	bf 00 00 00 00       	mov    $0x0,%edi
  8012a1:	89 fb                	mov    %edi,%ebx
  8012a3:	89 fe                	mov    %edi,%esi
  8012a5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	7e 28                	jle    8012d3 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012ab:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012af:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8012b6:	00 
  8012b7:	c7 44 24 08 bf 34 80 	movl   $0x8034bf,0x8(%esp)
  8012be:	00 
  8012bf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012c6:	00 
  8012c7:	c7 04 24 dc 34 80 00 	movl   $0x8034dc,(%esp)
  8012ce:	e8 b9 f2 ff ff       	call   80058c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8012d3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8012d6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8012d9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012dc:	89 ec                	mov    %ebp,%esp
  8012de:	5d                   	pop    %ebp
  8012df:	c3                   	ret    

008012e0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
  8012e3:	83 ec 28             	sub    $0x28,%esp
  8012e6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012e9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012ec:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8012ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012f5:	b8 08 00 00 00       	mov    $0x8,%eax
  8012fa:	bf 00 00 00 00       	mov    $0x0,%edi
  8012ff:	89 fb                	mov    %edi,%ebx
  801301:	89 fe                	mov    %edi,%esi
  801303:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801305:	85 c0                	test   %eax,%eax
  801307:	7e 28                	jle    801331 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801309:	89 44 24 10          	mov    %eax,0x10(%esp)
  80130d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801314:	00 
  801315:	c7 44 24 08 bf 34 80 	movl   $0x8034bf,0x8(%esp)
  80131c:	00 
  80131d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801324:	00 
  801325:	c7 04 24 dc 34 80 00 	movl   $0x8034dc,(%esp)
  80132c:	e8 5b f2 ff ff       	call   80058c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801331:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801334:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801337:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80133a:	89 ec                	mov    %ebp,%esp
  80133c:	5d                   	pop    %ebp
  80133d:	c3                   	ret    

0080133e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80133e:	55                   	push   %ebp
  80133f:	89 e5                	mov    %esp,%ebp
  801341:	83 ec 28             	sub    $0x28,%esp
  801344:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801347:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80134a:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80134d:	8b 55 08             	mov    0x8(%ebp),%edx
  801350:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801353:	b8 06 00 00 00       	mov    $0x6,%eax
  801358:	bf 00 00 00 00       	mov    $0x0,%edi
  80135d:	89 fb                	mov    %edi,%ebx
  80135f:	89 fe                	mov    %edi,%esi
  801361:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801363:	85 c0                	test   %eax,%eax
  801365:	7e 28                	jle    80138f <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801367:	89 44 24 10          	mov    %eax,0x10(%esp)
  80136b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801372:	00 
  801373:	c7 44 24 08 bf 34 80 	movl   $0x8034bf,0x8(%esp)
  80137a:	00 
  80137b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801382:	00 
  801383:	c7 04 24 dc 34 80 00 	movl   $0x8034dc,(%esp)
  80138a:	e8 fd f1 ff ff       	call   80058c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80138f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801392:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801395:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801398:	89 ec                	mov    %ebp,%esp
  80139a:	5d                   	pop    %ebp
  80139b:	c3                   	ret    

0080139c <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	83 ec 28             	sub    $0x28,%esp
  8013a2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013a5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013a8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8013ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013b4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8013b7:	8b 75 18             	mov    0x18(%ebp),%esi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8013bf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	7e 28                	jle    8013ed <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013c9:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8013d0:	00 
  8013d1:	c7 44 24 08 bf 34 80 	movl   $0x8034bf,0x8(%esp)
  8013d8:	00 
  8013d9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013e0:	00 
  8013e1:	c7 04 24 dc 34 80 00 	movl   $0x8034dc,(%esp)
  8013e8:	e8 9f f1 ff ff       	call   80058c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8013ed:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013f0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8013f3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013f6:	89 ec                	mov    %ebp,%esp
  8013f8:	5d                   	pop    %ebp
  8013f9:	c3                   	ret    

008013fa <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8013fa:	55                   	push   %ebp
  8013fb:	89 e5                	mov    %esp,%ebp
  8013fd:	83 ec 28             	sub    $0x28,%esp
  801400:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801403:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801406:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801409:	8b 55 08             	mov    0x8(%ebp),%edx
  80140c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80140f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801412:	b8 04 00 00 00       	mov    $0x4,%eax
  801417:	bf 00 00 00 00       	mov    $0x0,%edi
  80141c:	89 fe                	mov    %edi,%esi
  80141e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801420:	85 c0                	test   %eax,%eax
  801422:	7e 28                	jle    80144c <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  801424:	89 44 24 10          	mov    %eax,0x10(%esp)
  801428:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80142f:	00 
  801430:	c7 44 24 08 bf 34 80 	movl   $0x8034bf,0x8(%esp)
  801437:	00 
  801438:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80143f:	00 
  801440:	c7 04 24 dc 34 80 00 	movl   $0x8034dc,(%esp)
  801447:	e8 40 f1 ff ff       	call   80058c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80144c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80144f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801452:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801455:	89 ec                	mov    %ebp,%esp
  801457:	5d                   	pop    %ebp
  801458:	c3                   	ret    

00801459 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  801459:	55                   	push   %ebp
  80145a:	89 e5                	mov    %esp,%ebp
  80145c:	83 ec 0c             	sub    $0xc,%esp
  80145f:	89 1c 24             	mov    %ebx,(%esp)
  801462:	89 74 24 04          	mov    %esi,0x4(%esp)
  801466:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80146a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80146f:	bf 00 00 00 00       	mov    $0x0,%edi
  801474:	89 fa                	mov    %edi,%edx
  801476:	89 f9                	mov    %edi,%ecx
  801478:	89 fb                	mov    %edi,%ebx
  80147a:	89 fe                	mov    %edi,%esi
  80147c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80147e:	8b 1c 24             	mov    (%esp),%ebx
  801481:	8b 74 24 04          	mov    0x4(%esp),%esi
  801485:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801489:	89 ec                	mov    %ebp,%esp
  80148b:	5d                   	pop    %ebp
  80148c:	c3                   	ret    

0080148d <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  80148d:	55                   	push   %ebp
  80148e:	89 e5                	mov    %esp,%ebp
  801490:	83 ec 0c             	sub    $0xc,%esp
  801493:	89 1c 24             	mov    %ebx,(%esp)
  801496:	89 74 24 04          	mov    %esi,0x4(%esp)
  80149a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80149e:	b8 02 00 00 00       	mov    $0x2,%eax
  8014a3:	bf 00 00 00 00       	mov    $0x0,%edi
  8014a8:	89 fa                	mov    %edi,%edx
  8014aa:	89 f9                	mov    %edi,%ecx
  8014ac:	89 fb                	mov    %edi,%ebx
  8014ae:	89 fe                	mov    %edi,%esi
  8014b0:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8014b2:	8b 1c 24             	mov    (%esp),%ebx
  8014b5:	8b 74 24 04          	mov    0x4(%esp),%esi
  8014b9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8014bd:	89 ec                	mov    %ebp,%esp
  8014bf:	5d                   	pop    %ebp
  8014c0:	c3                   	ret    

008014c1 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
  8014c4:	83 ec 28             	sub    $0x28,%esp
  8014c7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8014ca:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8014cd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8014d0:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014d3:	b8 03 00 00 00       	mov    $0x3,%eax
  8014d8:	bf 00 00 00 00       	mov    $0x0,%edi
  8014dd:	89 f9                	mov    %edi,%ecx
  8014df:	89 fb                	mov    %edi,%ebx
  8014e1:	89 fe                	mov    %edi,%esi
  8014e3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8014e5:	85 c0                	test   %eax,%eax
  8014e7:	7e 28                	jle    801511 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014e9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014ed:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8014f4:	00 
  8014f5:	c7 44 24 08 bf 34 80 	movl   $0x8034bf,0x8(%esp)
  8014fc:	00 
  8014fd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801504:	00 
  801505:	c7 04 24 dc 34 80 00 	movl   $0x8034dc,(%esp)
  80150c:	e8 7b f0 ff ff       	call   80058c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801511:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801514:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801517:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80151a:	89 ec                	mov    %ebp,%esp
  80151c:	5d                   	pop    %ebp
  80151d:	c3                   	ret    
	...

00801520 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
// 
static int
duppage(envid_t envid, unsigned pn)
{
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
  801523:	53                   	push   %ebx
  801524:	83 ec 14             	sub    $0x14,%esp
  801527:	89 c1                	mov    %eax,%ecx
	int r;

	// LAB 4: Your code here.
	pde_t *pde;
	pte_t *pte;
	void *addr=(void*)(pn*PGSIZE);
  801529:	89 d3                	mov    %edx,%ebx
  80152b:	c1 e3 0c             	shl    $0xc,%ebx
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
  80152e:	89 d8                	mov    %ebx,%eax
  801530:	c1 e8 16             	shr    $0x16,%eax
  801533:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  80153a:	01 
  80153b:	74 14                	je     801551 <duppage+0x31>
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else    panic("page table for pn page is not exist");
	if((*pte&PTE_W)||(*pte&PTE_COW))
  80153d:	89 d8                	mov    %ebx,%eax
  80153f:	c1 e8 0c             	shr    $0xc,%eax
  801542:	f7 04 85 00 00 40 ef 	testl  $0x802,-0x10c00000(,%eax,4)
  801549:	02 08 00 00 
  80154d:	75 1e                	jne    80156d <duppage+0x4d>
  80154f:	eb 73                	jmp    8015c4 <duppage+0xa4>
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else    panic("page table for pn page is not exist");
  801551:	c7 44 24 08 ec 34 80 	movl   $0x8034ec,0x8(%esp)
  801558:	00 
  801559:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
  801560:	00 
  801561:	c7 04 24 aa 35 80 00 	movl   $0x8035aa,(%esp)
  801568:	e8 1f f0 ff ff       	call   80058c <_panic>
	if((*pte&PTE_W)||(*pte&PTE_COW))
	{
		if((r=sys_page_map(0,addr,envid,addr,PTE_COW|PTE_U))<0)
  80156d:	c7 44 24 10 04 08 00 	movl   $0x804,0x10(%esp)
  801574:	00 
  801575:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801579:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80157d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801581:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801588:	e8 0f fe ff ff       	call   80139c <sys_page_map>
  80158d:	85 c0                	test   %eax,%eax
  80158f:	78 60                	js     8015f1 <duppage+0xd1>
			return r;
		if((r=sys_page_map(0,addr,0,addr,PTE_COW|PTE_U))<0)//映射的时候注意env的id
  801591:	c7 44 24 10 04 08 00 	movl   $0x804,0x10(%esp)
  801598:	00 
  801599:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80159d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015a4:	00 
  8015a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015b0:	e8 e7 fd ff ff       	call   80139c <sys_page_map>
  8015b5:	85 c0                	test   %eax,%eax
  8015b7:	0f 9f c2             	setg   %dl
  8015ba:	0f b6 d2             	movzbl %dl,%edx
  8015bd:	83 ea 01             	sub    $0x1,%edx
  8015c0:	21 d0                	and    %edx,%eax
  8015c2:	eb 2d                	jmp    8015f1 <duppage+0xd1>
                        return r;
	}
	else{	
		if((r=sys_page_map(0,addr,envid,addr,PTE_U|PTE_P))<0)
  8015c4:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8015cb:	00 
  8015cc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8015d0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015df:	e8 b8 fd ff ff       	call   80139c <sys_page_map>
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	0f 9f c2             	setg   %dl
  8015e9:	0f b6 d2             	movzbl %dl,%edx
  8015ec:	83 ea 01             	sub    $0x1,%edx
  8015ef:	21 d0                	and    %edx,%eax
			return r;
	}
	//panic("duppage not implemented");
	return 0;
}
  8015f1:	83 c4 14             	add    $0x14,%esp
  8015f4:	5b                   	pop    %ebx
  8015f5:	5d                   	pop    %ebp
  8015f6:	c3                   	ret    

008015f7 <sfork>:
	return 0;
}
// Challenge!
int
sfork(void)
{
  8015f7:	55                   	push   %ebp
  8015f8:	89 e5                	mov    %esp,%ebp
  8015fa:	57                   	push   %edi
  8015fb:	56                   	push   %esi
  8015fc:	53                   	push   %ebx
  8015fd:	83 ec 1c             	sub    $0x1c,%esp
static __inline envid_t sys_exofork(void) __attribute__((always_inline));
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801600:	ba 07 00 00 00       	mov    $0x7,%edx
  801605:	89 d0                	mov    %edx,%eax
  801607:	cd 30                	int    $0x30
  801609:	89 45 f0             	mov    %eax,-0x10(%ebp)
	pte_t *pte;
	unsigned i;
	uint32_t addr;
	envid_t envid;
	envid = sys_exofork();//创建子环境
	if(envid < 0)
  80160c:	85 c0                	test   %eax,%eax
  80160e:	79 20                	jns    801630 <sfork+0x39>
		panic("sys_exofork: %e", envid);
  801610:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801614:	c7 44 24 08 b5 35 80 	movl   $0x8035b5,0x8(%esp)
  80161b:	00 
  80161c:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  801623:	00 
  801624:	c7 04 24 aa 35 80 00 	movl   $0x8035aa,(%esp)
  80162b:	e8 5c ef ff ff       	call   80058c <_panic>
	if(envid==0)//子环境中
  801630:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801634:	75 21                	jne    801657 <sfork+0x60>
	{
		env = &envs[ENVX(sys_getenvid())];
  801636:	e8 52 fe ff ff       	call   80148d <sys_getenvid>
  80163b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801640:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801643:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801648:	a3 54 70 80 00       	mov    %eax,0x807054
  80164d:	b8 00 00 00 00       	mov    $0x0,%eax
  801652:	e9 83 01 00 00       	jmp    8017da <sfork+0x1e3>
		return 0;
	}
	else{//父环境中,注意：这里需要设置父环境的缺页异常栈，还需要设置子环境的缺页异常栈，
	//父子环境的页异常栈不共享？具体原因还得思考
		env = &envs[ENVX(sys_getenvid())];
  801657:	e8 31 fe ff ff       	call   80148d <sys_getenvid>
  80165c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801661:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801664:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801669:	a3 54 70 80 00       	mov    %eax,0x807054
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
  80166e:	c7 04 24 e2 17 80 00 	movl   $0x8017e2,(%esp)
  801675:	e8 42 13 00 00       	call   8029bc <set_pgfault_handler>
  80167a:	be 00 00 00 00       	mov    $0x0,%esi
  80167f:	bf 00 00 00 00       	mov    $0x0,%edi
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
		{
			addr=i*PGSIZE;
			pde =(pde_t*) &vpd[VPD(addr)];
  801684:	89 f8                	mov    %edi,%eax
  801686:	c1 e8 16             	shr    $0x16,%eax
  801689:	c1 e0 02             	shl    $0x2,%eax
			if(*pde&PTE_P)//这里只处理有物理页面映射的页表项
  80168c:	f6 80 00 d0 7b ef 01 	testb  $0x1,-0x10843000(%eax)
  801693:	0f 84 dc 00 00 00    	je     801775 <sfork+0x17e>
			{
				pte=(pte_t*)&vpt[VPN(addr)];
			}
			else    continue;
			if((i==(unsigned)VPN(USTACKTOP-PGSIZE))||(i==(unsigned)VPN(PFTEMP)))
  801699:	81 fe fd eb 0e 00    	cmp    $0xeebfd,%esi
  80169f:	74 08                	je     8016a9 <sfork+0xb2>
  8016a1:	81 fe ff 07 00 00    	cmp    $0x7ff,%esi
  8016a7:	75 17                	jne    8016c0 <sfork+0xc9>
								//特殊处理，用户层普通栈
			{	
				if((r=duppage(envid,i))<0)
  8016a9:	89 f2                	mov    %esi,%edx
  8016ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ae:	e8 6d fe ff ff       	call   801520 <duppage>
  8016b3:	85 c0                	test   %eax,%eax
  8016b5:	0f 89 ba 00 00 00    	jns    801775 <sfork+0x17e>
  8016bb:	e9 1a 01 00 00       	jmp    8017da <sfork+0x1e3>
	// LAB 4: Your code here.
	pde_t *pde;
	pte_t *pte;
	void *addr=(void*)(pn*PGSIZE);
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
  8016c0:	f6 80 00 d0 7b ef 01 	testb  $0x1,-0x10843000(%eax)
  8016c7:	74 11                	je     8016da <sfork+0xe3>
	{
		pte=(pte_t*)&vpt[VPN(addr)];
  8016c9:	89 f8                	mov    %edi,%eax
  8016cb:	c1 e8 0c             	shr    $0xc,%eax
	}
	else    panic("page table for pn page is not exist");
	if(*pte&PTE_W)
  8016ce:	f6 04 85 00 00 40 ef 	testb  $0x2,-0x10c00000(,%eax,4)
  8016d5:	02 
  8016d6:	75 1e                	jne    8016f6 <sfork+0xff>
  8016d8:	eb 74                	jmp    80174e <sfork+0x157>
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else    panic("page table for pn page is not exist");
  8016da:	c7 44 24 08 ec 34 80 	movl   $0x8034ec,0x8(%esp)
  8016e1:	00 
  8016e2:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
  8016e9:	00 
  8016ea:	c7 04 24 aa 35 80 00 	movl   $0x8035aa,(%esp)
  8016f1:	e8 96 ee ff ff       	call   80058c <_panic>
	if(*pte&PTE_W)
	{
		//cprintf("sduppage:addr=%x\n",addr);
		if((r=sys_page_map(0,addr,envid,addr,PTE_W|PTE_U))<0)
  8016f6:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
  8016fd:	00 
  8016fe:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801702:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801705:	89 44 24 08          	mov    %eax,0x8(%esp)
  801709:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80170d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801714:	e8 83 fc ff ff       	call   80139c <sys_page_map>
  801719:	85 c0                	test   %eax,%eax
  80171b:	0f 88 b9 00 00 00    	js     8017da <sfork+0x1e3>
			return r;
		if((r=sys_page_map(0,addr,0,addr,PTE_W|PTE_U))<0)//映射的时候注意env的id
  801721:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
  801728:	00 
  801729:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80172d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801734:	00 
  801735:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801739:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801740:	e8 57 fc ff ff       	call   80139c <sys_page_map>
  801745:	85 c0                	test   %eax,%eax
  801747:	79 2c                	jns    801775 <sfork+0x17e>
  801749:	e9 8c 00 00 00       	jmp    8017da <sfork+0x1e3>
                        return r;
	}
	else{	
		if((r=sys_page_map(0,addr,envid,addr,PTE_U|PTE_P))<0)
  80174e:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801755:	00 
  801756:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80175a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801761:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801765:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80176c:	e8 2b fc ff ff       	call   80139c <sys_page_map>
  801771:	85 c0                	test   %eax,%eax
  801773:	78 65                	js     8017da <sfork+0x1e3>
	}
	else{//父环境中,注意：这里需要设置父环境的缺页异常栈，还需要设置子环境的缺页异常栈，
	//父子环境的页异常栈不共享？具体原因还得思考
		env = &envs[ENVX(sys_getenvid())];
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
  801775:	83 c6 01             	add    $0x1,%esi
  801778:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80177e:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  801784:	0f 85 fa fe ff ff    	jne    801684 <sfork+0x8d>
				continue;
			}
			if((r=sduppage(envid,i))<0)
				return r;
		}
		if((r=sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  80178a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801791:	00 
  801792:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801799:	ee 
  80179a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179d:	89 04 24             	mov    %eax,(%esp)
  8017a0:	e8 55 fc ff ff       	call   8013fa <sys_page_alloc>
  8017a5:	85 c0                	test   %eax,%eax
  8017a7:	78 31                	js     8017da <sfork+0x1e3>
                        return r;//设置子环境的缺页异常栈
		if((r=sys_env_set_pgfault_upcall(envid,(void*)_pgfault_upcall))<0)
  8017a9:	c7 44 24 04 40 2a 80 	movl   $0x802a40,0x4(%esp)
  8017b0:	00 
  8017b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b4:	89 04 24             	mov    %eax,(%esp)
  8017b7:	e8 68 fa ff ff       	call   801224 <sys_env_set_pgfault_upcall>
  8017bc:	85 c0                	test   %eax,%eax
  8017be:	78 1a                	js     8017da <sfork+0x1e3>
			return r;//设置子环境的缺页异常处理入口点
		if((r=sys_env_set_status(envid,ENV_RUNNABLE))<0)
  8017c0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8017c7:	00 
  8017c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017cb:	89 04 24             	mov    %eax,(%esp)
  8017ce:	e8 0d fb ff ff       	call   8012e0 <sys_env_set_status>
  8017d3:	85 c0                	test   %eax,%eax
  8017d5:	78 03                	js     8017da <sfork+0x1e3>
  8017d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
			return r;//设置子环境的状态为可运行
		return envid;
	}
	//panic("sfork not implemented");
	//return -E_INVAL;
}
  8017da:	83 c4 1c             	add    $0x1c,%esp
  8017dd:	5b                   	pop    %ebx
  8017de:	5e                   	pop    %esi
  8017df:	5f                   	pop    %edi
  8017e0:	5d                   	pop    %ebp
  8017e1:	c3                   	ret    

008017e2 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8017e2:	55                   	push   %ebp
  8017e3:	89 e5                	mov    %esp,%ebp
  8017e5:	56                   	push   %esi
  8017e6:	53                   	push   %ebx
  8017e7:	83 ec 20             	sub    $0x20,%esp
  8017ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  8017ed:	8b 71 04             	mov    0x4(%ecx),%esi

	// LAB 4: Your code here.
	pde_t *pde;
	pte_t *pte;
	uint32_t *va,*srcva,*dstva;
	pde =(pde_t*) &vpd[VPD(addr)];
  8017f0:	8b 19                	mov    (%ecx),%ebx
  8017f2:	89 d8                	mov    %ebx,%eax
  8017f4:	c1 e8 16             	shr    $0x16,%eax
  8017f7:	c1 e0 02             	shl    $0x2,%eax
  8017fa:	8d 90 00 d0 7b ef    	lea    -0x10843000(%eax),%edx
	if(*pde&PTE_P)
  801800:	f6 80 00 d0 7b ef 01 	testb  $0x1,-0x10843000(%eax)
  801807:	74 16                	je     80181f <pgfault+0x3d>
	{
		pte=(pte_t*)&vpt[VPN(addr)];
  801809:	89 d8                	mov    %ebx,%eax
  80180b:	c1 e8 0c             	shr    $0xc,%eax
  80180e:	8d 04 85 00 00 40 ef 	lea    -0x10c00000(,%eax,4),%eax
	else{
		cprintf("addr=%x err=%x *pde=%x utf_eip=%x\n",(uint32_t)addr,err,*pde,utf->utf_eip);	
		panic("page table for fault va is not exist");
	}
	//cprintf("addr=%x err=%x *pte=%x utf_eip=%x\n",(uint32_t)addr,err,*pte,utf->utf_eip);
	if(!(err&FEC_WR)||!(*pte&PTE_COW))
  801815:	f7 c6 02 00 00 00    	test   $0x2,%esi
  80181b:	75 3f                	jne    80185c <pgfault+0x7a>
  80181d:	eb 43                	jmp    801862 <pgfault+0x80>
	if(*pde&PTE_P)
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else{
		cprintf("addr=%x err=%x *pde=%x utf_eip=%x\n",(uint32_t)addr,err,*pde,utf->utf_eip);	
  80181f:	8b 41 28             	mov    0x28(%ecx),%eax
  801822:	8b 12                	mov    (%edx),%edx
  801824:	89 44 24 10          	mov    %eax,0x10(%esp)
  801828:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80182c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801830:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801834:	c7 04 24 10 35 80 00 	movl   $0x803510,(%esp)
  80183b:	e8 19 ee ff ff       	call   800659 <cprintf>
		panic("page table for fault va is not exist");
  801840:	c7 44 24 08 34 35 80 	movl   $0x803534,0x8(%esp)
  801847:	00 
  801848:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80184f:	00 
  801850:	c7 04 24 aa 35 80 00 	movl   $0x8035aa,(%esp)
  801857:	e8 30 ed ff ff       	call   80058c <_panic>
	}
	//cprintf("addr=%x err=%x *pte=%x utf_eip=%x\n",(uint32_t)addr,err,*pte,utf->utf_eip);
	if(!(err&FEC_WR)||!(*pte&PTE_COW))
  80185c:	f6 40 01 08          	testb  $0x8,0x1(%eax)
  801860:	75 49                	jne    8018ab <pgfault+0xc9>
	{	
		cprintf("envid=%x addr=%x err=%x *pte=%x utf_eip=%x\n",env->env_id,(uint32_t)addr,err,*pte,utf->utf_eip);
  801862:	8b 51 28             	mov    0x28(%ecx),%edx
  801865:	8b 08                	mov    (%eax),%ecx
  801867:	a1 54 70 80 00       	mov    0x807054,%eax
  80186c:	8b 40 4c             	mov    0x4c(%eax),%eax
  80186f:	89 54 24 14          	mov    %edx,0x14(%esp)
  801873:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801877:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80187b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80187f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801883:	c7 04 24 5c 35 80 00 	movl   $0x80355c,(%esp)
  80188a:	e8 ca ed ff ff       	call   800659 <cprintf>
		panic("faulting access is illegle");
  80188f:	c7 44 24 08 c5 35 80 	movl   $0x8035c5,0x8(%esp)
  801896:	00 
  801897:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80189e:	00 
  80189f:	c7 04 24 aa 35 80 00 	movl   $0x8035aa,(%esp)
  8018a6:	e8 e1 ec ff ff       	call   80058c <_panic>
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	//cprintf("pgfault:env_id=%x\n",env->env_id);
	if((r=sys_page_alloc(0,PFTEMP,PTE_W|PTE_U|PTE_P))<0)
  8018ab:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8018b2:	00 
  8018b3:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8018ba:	00 
  8018bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018c2:	e8 33 fb ff ff       	call   8013fa <sys_page_alloc>
  8018c7:	85 c0                	test   %eax,%eax
  8018c9:	79 20                	jns    8018eb <pgfault+0x109>
			//输入id=0表示当前环境id(curenv->env_id),这个时候不能用env->env-id,子环境中env的修改会缺页
		panic("alloc a page for PFTEMP failed:%e",r);
  8018cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018cf:	c7 44 24 08 88 35 80 	movl   $0x803588,0x8(%esp)
  8018d6:	00 
  8018d7:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8018de:	00 
  8018df:	c7 04 24 aa 35 80 00 	movl   $0x8035aa,(%esp)
  8018e6:	e8 a1 ec ff ff       	call   80058c <_panic>
	//cprintf("PFTEMP=%x add=%x\n",PFTEMP,(uint32_t)addr&0xfffff000);
	srcva = (uint32_t*)((uint32_t)addr&0xfffff000);
  8018eb:	89 de                	mov    %ebx,%esi
  8018ed:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  8018f3:	89 f2                	mov    %esi,%edx
	dstva = (uint32_t*)PFTEMP;
	//strncpy((char*)PFTEMP,(char*)((uint32_t)addr&0xfffff000),PGSIZE);
	for(;srcva<(uint32_t*)(ROUNDUP(addr,PGSIZE));srcva++)//数据拷贝要注意，用strncpy出错了，原因还得分析
  8018f5:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  8018fb:	89 c3                	mov    %eax,%ebx
  8018fd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801903:	39 de                	cmp    %ebx,%esi
  801905:	73 13                	jae    80191a <pgfault+0x138>
  801907:	b9 00 f0 7f 00       	mov    $0x7ff000,%ecx
	{
		*dstva=*srcva;
  80190c:	8b 02                	mov    (%edx),%eax
  80190e:	89 01                	mov    %eax,(%ecx)
		dstva++;
  801910:	83 c1 04             	add    $0x4,%ecx
		panic("alloc a page for PFTEMP failed:%e",r);
	//cprintf("PFTEMP=%x add=%x\n",PFTEMP,(uint32_t)addr&0xfffff000);
	srcva = (uint32_t*)((uint32_t)addr&0xfffff000);
	dstva = (uint32_t*)PFTEMP;
	//strncpy((char*)PFTEMP,(char*)((uint32_t)addr&0xfffff000),PGSIZE);
	for(;srcva<(uint32_t*)(ROUNDUP(addr,PGSIZE));srcva++)//数据拷贝要注意，用strncpy出错了，原因还得分析
  801913:	83 c2 04             	add    $0x4,%edx
  801916:	39 da                	cmp    %ebx,%edx
  801918:	72 f2                	jb     80190c <pgfault+0x12a>
	{
		*dstva=*srcva;
		dstva++;
	}
	if((r=sys_page_map(0,(void*)PFTEMP,0,(void*)((uint32_t)addr&0xfffff000),PTE_W|PTE_U|PTE_P))<0)
  80191a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801921:	00 
  801922:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801926:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80192d:	00 
  80192e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801935:	00 
  801936:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80193d:	e8 5a fa ff ff       	call   80139c <sys_page_map>
  801942:	85 c0                	test   %eax,%eax
  801944:	79 1c                	jns    801962 <pgfault+0x180>
			//输入id=0表示当前环境id(curenv->env_id),这个时候不能用env->env-id,子环境中env的修改会缺页
		panic("page mapping failed");
  801946:	c7 44 24 08 e0 35 80 	movl   $0x8035e0,0x8(%esp)
  80194d:	00 
  80194e:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801955:	00 
  801956:	c7 04 24 aa 35 80 00 	movl   $0x8035aa,(%esp)
  80195d:	e8 2a ec ff ff       	call   80058c <_panic>
	//panic("pgfault not implemented");
}
  801962:	83 c4 20             	add    $0x20,%esp
  801965:	5b                   	pop    %ebx
  801966:	5e                   	pop    %esi
  801967:	5d                   	pop    %ebp
  801968:	c3                   	ret    

00801969 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801969:	55                   	push   %ebp
  80196a:	89 e5                	mov    %esp,%ebp
  80196c:	56                   	push   %esi
  80196d:	53                   	push   %ebx
  80196e:	83 ec 10             	sub    $0x10,%esp
  801971:	ba 07 00 00 00       	mov    $0x7,%edx
  801976:	89 d0                	mov    %edx,%eax
  801978:	cd 30                	int    $0x30
  80197a:	89 c6                	mov    %eax,%esi
	pte_t *pte;
	unsigned i;
	uint32_t addr;
	envid_t envid;
	envid = sys_exofork();//创建子环境
	if(envid < 0)
  80197c:	85 c0                	test   %eax,%eax
  80197e:	79 20                	jns    8019a0 <fork+0x37>
		panic("sys_exofork: %e", envid);
  801980:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801984:	c7 44 24 08 b5 35 80 	movl   $0x8035b5,0x8(%esp)
  80198b:	00 
  80198c:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  801993:	00 
  801994:	c7 04 24 aa 35 80 00 	movl   $0x8035aa,(%esp)
  80199b:	e8 ec eb ff ff       	call   80058c <_panic>
	if(envid==0)//子环境中
  8019a0:	85 c0                	test   %eax,%eax
  8019a2:	75 21                	jne    8019c5 <fork+0x5c>
	{
		env = &envs[ENVX(sys_getenvid())];
  8019a4:	e8 e4 fa ff ff       	call   80148d <sys_getenvid>
  8019a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8019ae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8019b1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8019b6:	a3 54 70 80 00       	mov    %eax,0x807054
  8019bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c0:	e9 9e 00 00 00       	jmp    801a63 <fork+0xfa>
		return 0;
	}
	else{//父环境中
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
  8019c5:	c7 04 24 e2 17 80 00 	movl   $0x8017e2,(%esp)
  8019cc:	e8 eb 0f 00 00       	call   8029bc <set_pgfault_handler>
  8019d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019d6:	eb 08                	jmp    8019e0 <fork+0x77>
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
		{
			if(i==(unsigned)VPN(UXSTACKTOP-PGSIZE))//特殊处理，用户层缺页异常栈
  8019d8:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  8019de:	74 3d                	je     801a1d <fork+0xb4>
				continue;
  8019e0:	89 da                	mov    %ebx,%edx
  8019e2:	c1 e2 0c             	shl    $0xc,%edx
			addr=i*PGSIZE;
			pde =(pde_t*) &vpd[VPD(addr)];
  8019e5:	89 d0                	mov    %edx,%eax
  8019e7:	c1 e8 16             	shr    $0x16,%eax
			if(*pde&PTE_P)//这里只处理有物理页面映射的页表项
  8019ea:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  8019f1:	01 
  8019f2:	74 1e                	je     801a12 <fork+0xa9>
			{
				pte=(pte_t*)&vpt[VPN(addr)];
  8019f4:	89 d0                	mov    %edx,%eax
  8019f6:	c1 e8 0a             	shr    $0xa,%eax
			}
			else    continue;
			if((*pte&PTE_W)||(*pte&PTE_COW))
  8019f9:	f7 80 00 00 40 ef 02 	testl  $0x802,-0x10c00000(%eax)
  801a00:	08 00 00 
  801a03:	74 0d                	je     801a12 <fork+0xa9>
			{
				if((r=duppage(envid,i))<0)
  801a05:	89 da                	mov    %ebx,%edx
  801a07:	89 f0                	mov    %esi,%eax
  801a09:	e8 12 fb ff ff       	call   801520 <duppage>
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	78 51                	js     801a63 <fork+0xfa>
		env = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	else{//父环境中
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
  801a12:	83 c3 01             	add    $0x1,%ebx
  801a15:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  801a1b:	75 bb                	jne    8019d8 <fork+0x6f>
			{
				if((r=duppage(envid,i))<0)
					return r;
			}
		}
		if((r=sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  801a1d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801a24:	00 
  801a25:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801a2c:	ee 
  801a2d:	89 34 24             	mov    %esi,(%esp)
  801a30:	e8 c5 f9 ff ff       	call   8013fa <sys_page_alloc>
  801a35:	85 c0                	test   %eax,%eax
  801a37:	78 2a                	js     801a63 <fork+0xfa>
			return r;//设置子环境的缺页异常栈
		if((r=sys_env_set_pgfault_upcall(envid,(void*)_pgfault_upcall))<0)
  801a39:	c7 44 24 04 40 2a 80 	movl   $0x802a40,0x4(%esp)
  801a40:	00 
  801a41:	89 34 24             	mov    %esi,(%esp)
  801a44:	e8 db f7 ff ff       	call   801224 <sys_env_set_pgfault_upcall>
  801a49:	85 c0                	test   %eax,%eax
  801a4b:	78 16                	js     801a63 <fork+0xfa>
			return r;//设置子环境的缺页异常处理入口点
		if((r=sys_env_set_status(envid,ENV_RUNNABLE))<0)
  801a4d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a54:	00 
  801a55:	89 34 24             	mov    %esi,(%esp)
  801a58:	e8 83 f8 ff ff       	call   8012e0 <sys_env_set_status>
  801a5d:	85 c0                	test   %eax,%eax
  801a5f:	78 02                	js     801a63 <fork+0xfa>
  801a61:	89 f0                	mov    %esi,%eax
			return r;//设置子环境的状态为可运行
		return envid;
	}
	//panic("fork not implemented");
}
  801a63:	83 c4 10             	add    $0x10,%esp
  801a66:	5b                   	pop    %ebx
  801a67:	5e                   	pop    %esi
  801a68:	5d                   	pop    %ebp
  801a69:	c3                   	ret    
  801a6a:	00 00                	add    %al,(%eax)
  801a6c:	00 00                	add    %al,(%eax)
	...

00801a70 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	57                   	push   %edi
  801a74:	56                   	push   %esi
  801a75:	53                   	push   %ebx
  801a76:	83 ec 1c             	sub    $0x1c,%esp
  801a79:	8b 75 08             	mov    0x8(%ebp),%esi
  801a7c:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  801a7f:	e8 09 fa ff ff       	call   80148d <sys_getenvid>
  801a84:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a89:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a8c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a91:	a3 54 70 80 00       	mov    %eax,0x807054
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  801a96:	e8 f2 f9 ff ff       	call   80148d <sys_getenvid>
  801a9b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801aa0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801aa3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801aa8:	a3 54 70 80 00       	mov    %eax,0x807054
		if(env->env_id==to_env){
  801aad:	8b 40 4c             	mov    0x4c(%eax),%eax
  801ab0:	39 f0                	cmp    %esi,%eax
  801ab2:	75 0e                	jne    801ac2 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  801ab4:	c7 04 24 f4 35 80 00 	movl   $0x8035f4,(%esp)
  801abb:	e8 99 eb ff ff       	call   800659 <cprintf>
  801ac0:	eb 5a                	jmp    801b1c <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  801ac2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ac6:	8b 45 10             	mov    0x10(%ebp),%eax
  801ac9:	89 44 24 08          	mov    %eax,0x8(%esp)
  801acd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad4:	89 34 24             	mov    %esi,(%esp)
  801ad7:	e8 10 f7 ff ff       	call   8011ec <sys_ipc_try_send>
  801adc:	89 c3                	mov    %eax,%ebx
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	79 25                	jns    801b07 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  801ae2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ae5:	74 2b                	je     801b12 <ipc_send+0xa2>
				panic("send error:%e",r);
  801ae7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801aeb:	c7 44 24 08 10 36 80 	movl   $0x803610,0x8(%esp)
  801af2:	00 
  801af3:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801afa:	00 
  801afb:	c7 04 24 1e 36 80 00 	movl   $0x80361e,(%esp)
  801b02:	e8 85 ea ff ff       	call   80058c <_panic>
		}
			sys_yield();
  801b07:	e8 4d f9 ff ff       	call   801459 <sys_yield>
		
	}while(r!=0);
  801b0c:	85 db                	test   %ebx,%ebx
  801b0e:	75 86                	jne    801a96 <ipc_send+0x26>
  801b10:	eb 0a                	jmp    801b1c <ipc_send+0xac>
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
		{	
			if(r!=-E_IPC_NOT_RECV)
				panic("send error:%e",r);
		}
			sys_yield();
  801b12:	e8 42 f9 ff ff       	call   801459 <sys_yield>
  801b17:	e9 7a ff ff ff       	jmp    801a96 <ipc_send+0x26>
		
	}while(r!=0);
	return;
	//panic("ipc_send not implemented");
}
  801b1c:	83 c4 1c             	add    $0x1c,%esp
  801b1f:	5b                   	pop    %ebx
  801b20:	5e                   	pop    %esi
  801b21:	5f                   	pop    %edi
  801b22:	5d                   	pop    %ebp
  801b23:	c3                   	ret    

00801b24 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	57                   	push   %edi
  801b28:	56                   	push   %esi
  801b29:	53                   	push   %ebx
  801b2a:	83 ec 0c             	sub    $0xc,%esp
  801b2d:	8b 75 08             	mov    0x8(%ebp),%esi
  801b30:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	void *dstva=NULL;
	if(pg)
		dstva=pg;
	env = &envs[ENVX(sys_getenvid())];
  801b33:	e8 55 f9 ff ff       	call   80148d <sys_getenvid>
  801b38:	25 ff 03 00 00       	and    $0x3ff,%eax
  801b3d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b40:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b45:	a3 54 70 80 00       	mov    %eax,0x807054
	if(from_env_store&&(env->env_id==*from_env_store))
  801b4a:	85 f6                	test   %esi,%esi
  801b4c:	74 29                	je     801b77 <ipc_recv+0x53>
  801b4e:	8b 40 4c             	mov    0x4c(%eax),%eax
  801b51:	3b 06                	cmp    (%esi),%eax
  801b53:	75 22                	jne    801b77 <ipc_recv+0x53>
	{
		*from_env_store=0;
  801b55:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  801b5b:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("send:the reciver is sender\n");
  801b61:	c7 04 24 f4 35 80 00 	movl   $0x8035f4,(%esp)
  801b68:	e8 ec ea ff ff       	call   800659 <cprintf>
  801b6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b72:	e9 8a 00 00 00       	jmp    801c01 <ipc_recv+0xdd>
		return 0;
	}
	env = &envs[ENVX(sys_getenvid())];
  801b77:	e8 11 f9 ff ff       	call   80148d <sys_getenvid>
  801b7c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801b81:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b84:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b89:	a3 54 70 80 00       	mov    %eax,0x807054
	if((r=sys_ipc_recv(dstva))<0)
  801b8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b91:	89 04 24             	mov    %eax,(%esp)
  801b94:	e8 f6 f5 ff ff       	call   80118f <sys_ipc_recv>
  801b99:	89 c3                	mov    %eax,%ebx
  801b9b:	85 c0                	test   %eax,%eax
  801b9d:	79 1a                	jns    801bb9 <ipc_recv+0x95>
	{
		*from_env_store=0;
  801b9f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  801ba5:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("reciver failed\n");
  801bab:	c7 04 24 28 36 80 00 	movl   $0x803628,(%esp)
  801bb2:	e8 a2 ea ff ff       	call   800659 <cprintf>
  801bb7:	eb 48                	jmp    801c01 <ipc_recv+0xdd>
		return r;
	}
	else{//接收成功
		env = &envs[ENVX(sys_getenvid())];
  801bb9:	e8 cf f8 ff ff       	call   80148d <sys_getenvid>
  801bbe:	25 ff 03 00 00       	and    $0x3ff,%eax
  801bc3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bc6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bcb:	a3 54 70 80 00       	mov    %eax,0x807054
		if(from_env_store)
  801bd0:	85 f6                	test   %esi,%esi
  801bd2:	74 05                	je     801bd9 <ipc_recv+0xb5>
			*from_env_store=env->env_ipc_from;	
  801bd4:	8b 40 74             	mov    0x74(%eax),%eax
  801bd7:	89 06                	mov    %eax,(%esi)
		if(perm_store)
  801bd9:	85 ff                	test   %edi,%edi
  801bdb:	74 0a                	je     801be7 <ipc_recv+0xc3>
			*perm_store=env->env_ipc_perm;
  801bdd:	a1 54 70 80 00       	mov    0x807054,%eax
  801be2:	8b 40 78             	mov    0x78(%eax),%eax
  801be5:	89 07                	mov    %eax,(%edi)
		env = &envs[ENVX(sys_getenvid())];
  801be7:	e8 a1 f8 ff ff       	call   80148d <sys_getenvid>
  801bec:	25 ff 03 00 00       	and    $0x3ff,%eax
  801bf1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bf4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bf9:	a3 54 70 80 00       	mov    %eax,0x807054
		return env->env_ipc_value;
  801bfe:	8b 58 70             	mov    0x70(%eax),%ebx
	}
	//panic("ipc_recv not implemented");
	return 0;
}
  801c01:	89 d8                	mov    %ebx,%eax
  801c03:	83 c4 0c             	add    $0xc,%esp
  801c06:	5b                   	pop    %ebx
  801c07:	5e                   	pop    %esi
  801c08:	5f                   	pop    %edi
  801c09:	5d                   	pop    %ebp
  801c0a:	c3                   	ret    
  801c0b:	00 00                	add    %al,(%eax)
  801c0d:	00 00                	add    %al,(%eax)
	...

00801c10 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	8b 45 08             	mov    0x8(%ebp),%eax
  801c16:	05 00 00 00 30       	add    $0x30000000,%eax
  801c1b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  801c1e:	5d                   	pop    %ebp
  801c1f:	c3                   	ret    

00801c20 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801c26:	8b 45 08             	mov    0x8(%ebp),%eax
  801c29:	89 04 24             	mov    %eax,(%esp)
  801c2c:	e8 df ff ff ff       	call   801c10 <fd2num>
  801c31:	c1 e0 0c             	shl    $0xc,%eax
  801c34:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801c39:	c9                   	leave  
  801c3a:	c3                   	ret    

00801c3b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
  801c3e:	53                   	push   %ebx
  801c3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801c42:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801c47:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801c49:	89 d0                	mov    %edx,%eax
  801c4b:	c1 e8 16             	shr    $0x16,%eax
  801c4e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c55:	a8 01                	test   $0x1,%al
  801c57:	74 10                	je     801c69 <fd_alloc+0x2e>
  801c59:	89 d0                	mov    %edx,%eax
  801c5b:	c1 e8 0c             	shr    $0xc,%eax
  801c5e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801c65:	a8 01                	test   $0x1,%al
  801c67:	75 09                	jne    801c72 <fd_alloc+0x37>
			*fd_store = fd;
  801c69:	89 0b                	mov    %ecx,(%ebx)
  801c6b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c70:	eb 19                	jmp    801c8b <fd_alloc+0x50>
			return 0;
  801c72:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801c78:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  801c7e:	75 c7                	jne    801c47 <fd_alloc+0xc>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801c80:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801c86:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801c8b:	5b                   	pop    %ebx
  801c8c:	5d                   	pop    %ebp
  801c8d:	c3                   	ret    

00801c8e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801c8e:	55                   	push   %ebp
  801c8f:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801c91:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  801c95:	77 38                	ja     801ccf <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801c97:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9a:	c1 e0 0c             	shl    $0xc,%eax
  801c9d:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  801ca3:	89 d0                	mov    %edx,%eax
  801ca5:	c1 e8 16             	shr    $0x16,%eax
  801ca8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801caf:	a8 01                	test   $0x1,%al
  801cb1:	74 1c                	je     801ccf <fd_lookup+0x41>
  801cb3:	89 d0                	mov    %edx,%eax
  801cb5:	c1 e8 0c             	shr    $0xc,%eax
  801cb8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801cbf:	a8 01                	test   $0x1,%al
  801cc1:	74 0c                	je     801ccf <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801cc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc6:	89 10                	mov    %edx,(%eax)
  801cc8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ccd:	eb 05                	jmp    801cd4 <fd_lookup+0x46>
	return 0;
  801ccf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801cd4:	5d                   	pop    %ebp
  801cd5:	c3                   	ret    

00801cd6 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801cd6:	55                   	push   %ebp
  801cd7:	89 e5                	mov    %esp,%ebp
  801cd9:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cdc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801cdf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce6:	89 04 24             	mov    %eax,(%esp)
  801ce9:	e8 a0 ff ff ff       	call   801c8e <fd_lookup>
  801cee:	85 c0                	test   %eax,%eax
  801cf0:	78 0e                	js     801d00 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801cf2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801cf5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cf8:	89 50 04             	mov    %edx,0x4(%eax)
  801cfb:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801d00:	c9                   	leave  
  801d01:	c3                   	ret    

00801d02 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801d02:	55                   	push   %ebp
  801d03:	89 e5                	mov    %esp,%ebp
  801d05:	53                   	push   %ebx
  801d06:	83 ec 14             	sub    $0x14,%esp
  801d09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801d0f:	ba 04 70 80 00       	mov    $0x807004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801d14:	b8 00 00 00 00       	mov    $0x0,%eax
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801d19:	39 0d 04 70 80 00    	cmp    %ecx,0x807004
  801d1f:	75 11                	jne    801d32 <dev_lookup+0x30>
  801d21:	eb 04                	jmp    801d27 <dev_lookup+0x25>
  801d23:	39 0a                	cmp    %ecx,(%edx)
  801d25:	75 0b                	jne    801d32 <dev_lookup+0x30>
			*dev = devtab[i];
  801d27:	89 13                	mov    %edx,(%ebx)
  801d29:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2e:	66 90                	xchg   %ax,%ax
  801d30:	eb 35                	jmp    801d67 <dev_lookup+0x65>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801d32:	83 c0 01             	add    $0x1,%eax
  801d35:	8b 14 85 b4 36 80 00 	mov    0x8036b4(,%eax,4),%edx
  801d3c:	85 d2                	test   %edx,%edx
  801d3e:	75 e3                	jne    801d23 <dev_lookup+0x21>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  801d40:	a1 54 70 80 00       	mov    0x807054,%eax
  801d45:	8b 40 4c             	mov    0x4c(%eax),%eax
  801d48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d50:	c7 04 24 38 36 80 00 	movl   $0x803638,(%esp)
  801d57:	e8 fd e8 ff ff       	call   800659 <cprintf>
	*dev = 0;
  801d5c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801d62:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801d67:	83 c4 14             	add    $0x14,%esp
  801d6a:	5b                   	pop    %ebx
  801d6b:	5d                   	pop    %ebp
  801d6c:	c3                   	ret    

00801d6d <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  801d6d:	55                   	push   %ebp
  801d6e:	89 e5                	mov    %esp,%ebp
  801d70:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d73:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801d76:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7d:	89 04 24             	mov    %eax,(%esp)
  801d80:	e8 09 ff ff ff       	call   801c8e <fd_lookup>
  801d85:	89 c2                	mov    %eax,%edx
  801d87:	85 c0                	test   %eax,%eax
  801d89:	78 5a                	js     801de5 <fstat+0x78>
  801d8b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801d8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d92:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801d95:	8b 00                	mov    (%eax),%eax
  801d97:	89 04 24             	mov    %eax,(%esp)
  801d9a:	e8 63 ff ff ff       	call   801d02 <dev_lookup>
  801d9f:	89 c2                	mov    %eax,%edx
  801da1:	85 c0                	test   %eax,%eax
  801da3:	78 40                	js     801de5 <fstat+0x78>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801da5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  801daa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801dad:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801db1:	74 32                	je     801de5 <fstat+0x78>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801db3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db6:	c6 00 00             	movb   $0x0,(%eax)
	stat->st_size = 0;
  801db9:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  801dc0:	00 00 00 
	stat->st_isdir = 0;
  801dc3:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
  801dca:	00 00 00 
	stat->st_dev = dev;
  801dcd:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801dd0:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
	return (*dev->dev_stat)(fd, stat);
  801dd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dda:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801ddd:	89 04 24             	mov    %eax,(%esp)
  801de0:	ff 52 14             	call   *0x14(%edx)
  801de3:	89 c2                	mov    %eax,%edx
}
  801de5:	89 d0                	mov    %edx,%eax
  801de7:	c9                   	leave  
  801de8:	c3                   	ret    

00801de9 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801de9:	55                   	push   %ebp
  801dea:	89 e5                	mov    %esp,%ebp
  801dec:	53                   	push   %ebx
  801ded:	83 ec 24             	sub    $0x24,%esp
  801df0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801df3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dfa:	89 1c 24             	mov    %ebx,(%esp)
  801dfd:	e8 8c fe ff ff       	call   801c8e <fd_lookup>
  801e02:	85 c0                	test   %eax,%eax
  801e04:	78 61                	js     801e67 <ftruncate+0x7e>
  801e06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e09:	8b 10                	mov    (%eax),%edx
  801e0b:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801e0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e12:	89 14 24             	mov    %edx,(%esp)
  801e15:	e8 e8 fe ff ff       	call   801d02 <dev_lookup>
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	78 49                	js     801e67 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801e1e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801e21:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801e25:	75 23                	jne    801e4a <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801e27:	a1 54 70 80 00       	mov    0x807054,%eax
  801e2c:	8b 40 4c             	mov    0x4c(%eax),%eax
  801e2f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e33:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e37:	c7 04 24 58 36 80 00 	movl   $0x803658,(%esp)
  801e3e:	e8 16 e8 ff ff       	call   800659 <cprintf>
  801e43:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801e48:	eb 1d                	jmp    801e67 <ftruncate+0x7e>
			env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801e4a:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801e4d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801e52:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801e56:	74 0f                	je     801e67 <ftruncate+0x7e>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801e58:	8b 42 18             	mov    0x18(%edx),%eax
  801e5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e5e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e62:	89 0c 24             	mov    %ecx,(%esp)
  801e65:	ff d0                	call   *%eax
}
  801e67:	83 c4 24             	add    $0x24,%esp
  801e6a:	5b                   	pop    %ebx
  801e6b:	5d                   	pop    %ebp
  801e6c:	c3                   	ret    

00801e6d <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801e6d:	55                   	push   %ebp
  801e6e:	89 e5                	mov    %esp,%ebp
  801e70:	53                   	push   %ebx
  801e71:	83 ec 24             	sub    $0x24,%esp
  801e74:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e7e:	89 1c 24             	mov    %ebx,(%esp)
  801e81:	e8 08 fe ff ff       	call   801c8e <fd_lookup>
  801e86:	85 c0                	test   %eax,%eax
  801e88:	78 68                	js     801ef2 <write+0x85>
  801e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8d:	8b 10                	mov    (%eax),%edx
  801e8f:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801e92:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e96:	89 14 24             	mov    %edx,(%esp)
  801e99:	e8 64 fe ff ff       	call   801d02 <dev_lookup>
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	78 50                	js     801ef2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ea2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801ea5:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801ea9:	75 23                	jne    801ece <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  801eab:	a1 54 70 80 00       	mov    0x807054,%eax
  801eb0:	8b 40 4c             	mov    0x4c(%eax),%eax
  801eb3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801eb7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ebb:	c7 04 24 79 36 80 00 	movl   $0x803679,(%esp)
  801ec2:	e8 92 e7 ff ff       	call   800659 <cprintf>
  801ec7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ecc:	eb 24                	jmp    801ef2 <write+0x85>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801ece:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801ed1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801ed6:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  801eda:	74 16                	je     801ef2 <write+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801edc:	8b 42 0c             	mov    0xc(%edx),%eax
  801edf:	8b 55 10             	mov    0x10(%ebp),%edx
  801ee2:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ee6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ee9:	89 54 24 04          	mov    %edx,0x4(%esp)
  801eed:	89 0c 24             	mov    %ecx,(%esp)
  801ef0:	ff d0                	call   *%eax
}
  801ef2:	83 c4 24             	add    $0x24,%esp
  801ef5:	5b                   	pop    %ebx
  801ef6:	5d                   	pop    %ebp
  801ef7:	c3                   	ret    

00801ef8 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	53                   	push   %ebx
  801efc:	83 ec 24             	sub    $0x24,%esp
  801eff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f09:	89 1c 24             	mov    %ebx,(%esp)
  801f0c:	e8 7d fd ff ff       	call   801c8e <fd_lookup>
  801f11:	85 c0                	test   %eax,%eax
  801f13:	78 6d                	js     801f82 <read+0x8a>
  801f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f18:	8b 10                	mov    (%eax),%edx
  801f1a:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801f1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f21:	89 14 24             	mov    %edx,(%esp)
  801f24:	e8 d9 fd ff ff       	call   801d02 <dev_lookup>
  801f29:	85 c0                	test   %eax,%eax
  801f2b:	78 55                	js     801f82 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801f2d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801f30:	8b 41 08             	mov    0x8(%ecx),%eax
  801f33:	83 e0 03             	and    $0x3,%eax
  801f36:	83 f8 01             	cmp    $0x1,%eax
  801f39:	75 23                	jne    801f5e <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  801f3b:	a1 54 70 80 00       	mov    0x807054,%eax
  801f40:	8b 40 4c             	mov    0x4c(%eax),%eax
  801f43:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f4b:	c7 04 24 96 36 80 00 	movl   $0x803696,(%esp)
  801f52:	e8 02 e7 ff ff       	call   800659 <cprintf>
  801f57:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801f5c:	eb 24                	jmp    801f82 <read+0x8a>
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801f5e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801f61:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801f66:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  801f6a:	74 16                	je     801f82 <read+0x8a>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801f6c:	8b 42 08             	mov    0x8(%edx),%eax
  801f6f:	8b 55 10             	mov    0x10(%ebp),%edx
  801f72:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f76:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f79:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f7d:	89 0c 24             	mov    %ecx,(%esp)
  801f80:	ff d0                	call   *%eax
}
  801f82:	83 c4 24             	add    $0x24,%esp
  801f85:	5b                   	pop    %ebx
  801f86:	5d                   	pop    %ebp
  801f87:	c3                   	ret    

00801f88 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801f88:	55                   	push   %ebp
  801f89:	89 e5                	mov    %esp,%ebp
  801f8b:	57                   	push   %edi
  801f8c:	56                   	push   %esi
  801f8d:	53                   	push   %ebx
  801f8e:	83 ec 0c             	sub    $0xc,%esp
  801f91:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f94:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f97:	b8 00 00 00 00       	mov    $0x0,%eax
  801f9c:	85 f6                	test   %esi,%esi
  801f9e:	74 36                	je     801fd6 <readn+0x4e>
  801fa0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fa5:	ba 00 00 00 00       	mov    $0x0,%edx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801faa:	89 f0                	mov    %esi,%eax
  801fac:	29 d0                	sub    %edx,%eax
  801fae:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fb2:	8d 04 17             	lea    (%edi,%edx,1),%eax
  801fb5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fb9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fbc:	89 04 24             	mov    %eax,(%esp)
  801fbf:	e8 34 ff ff ff       	call   801ef8 <read>
		if (m < 0)
  801fc4:	85 c0                	test   %eax,%eax
  801fc6:	78 0e                	js     801fd6 <readn+0x4e>
			return m;
		if (m == 0)
  801fc8:	85 c0                	test   %eax,%eax
  801fca:	74 08                	je     801fd4 <readn+0x4c>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801fcc:	01 c3                	add    %eax,%ebx
  801fce:	89 da                	mov    %ebx,%edx
  801fd0:	39 f3                	cmp    %esi,%ebx
  801fd2:	72 d6                	jb     801faa <readn+0x22>
  801fd4:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801fd6:	83 c4 0c             	add    $0xc,%esp
  801fd9:	5b                   	pop    %ebx
  801fda:	5e                   	pop    %esi
  801fdb:	5f                   	pop    %edi
  801fdc:	5d                   	pop    %ebp
  801fdd:	c3                   	ret    

00801fde <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	83 ec 28             	sub    $0x28,%esp
  801fe4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801fe7:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801fea:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801fed:	89 34 24             	mov    %esi,(%esp)
  801ff0:	e8 1b fc ff ff       	call   801c10 <fd2num>
  801ff5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ff8:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ffc:	89 04 24             	mov    %eax,(%esp)
  801fff:	e8 8a fc ff ff       	call   801c8e <fd_lookup>
  802004:	89 c3                	mov    %eax,%ebx
  802006:	85 c0                	test   %eax,%eax
  802008:	78 05                	js     80200f <fd_close+0x31>
  80200a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80200d:	74 0d                	je     80201c <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80200f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802013:	75 44                	jne    802059 <fd_close+0x7b>
  802015:	bb 00 00 00 00       	mov    $0x0,%ebx
  80201a:	eb 3d                	jmp    802059 <fd_close+0x7b>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80201c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80201f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802023:	8b 06                	mov    (%esi),%eax
  802025:	89 04 24             	mov    %eax,(%esp)
  802028:	e8 d5 fc ff ff       	call   801d02 <dev_lookup>
  80202d:	89 c3                	mov    %eax,%ebx
  80202f:	85 c0                	test   %eax,%eax
  802031:	78 16                	js     802049 <fd_close+0x6b>
		if (dev->dev_close)
  802033:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802036:	8b 40 10             	mov    0x10(%eax),%eax
  802039:	bb 00 00 00 00       	mov    $0x0,%ebx
  80203e:	85 c0                	test   %eax,%eax
  802040:	74 07                	je     802049 <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  802042:	89 34 24             	mov    %esi,(%esp)
  802045:	ff d0                	call   *%eax
  802047:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802049:	89 74 24 04          	mov    %esi,0x4(%esp)
  80204d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802054:	e8 e5 f2 ff ff       	call   80133e <sys_page_unmap>
	return r;
}
  802059:	89 d8                	mov    %ebx,%eax
  80205b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80205e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802061:	89 ec                	mov    %ebp,%esp
  802063:	5d                   	pop    %ebp
  802064:	c3                   	ret    

00802065 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802065:	55                   	push   %ebp
  802066:	89 e5                	mov    %esp,%ebp
  802068:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80206b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80206e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802072:	8b 45 08             	mov    0x8(%ebp),%eax
  802075:	89 04 24             	mov    %eax,(%esp)
  802078:	e8 11 fc ff ff       	call   801c8e <fd_lookup>
  80207d:	85 c0                	test   %eax,%eax
  80207f:	78 13                	js     802094 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  802081:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802088:	00 
  802089:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80208c:	89 04 24             	mov    %eax,(%esp)
  80208f:	e8 4a ff ff ff       	call   801fde <fd_close>
}
  802094:	c9                   	leave  
  802095:	c3                   	ret    

00802096 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  802096:	55                   	push   %ebp
  802097:	89 e5                	mov    %esp,%ebp
  802099:	83 ec 18             	sub    $0x18,%esp
  80209c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80209f:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8020a2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8020a9:	00 
  8020aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ad:	89 04 24             	mov    %eax,(%esp)
  8020b0:	e8 5a 03 00 00       	call   80240f <open>
  8020b5:	89 c6                	mov    %eax,%esi
  8020b7:	85 c0                	test   %eax,%eax
  8020b9:	78 1b                	js     8020d6 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8020bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c2:	89 34 24             	mov    %esi,(%esp)
  8020c5:	e8 a3 fc ff ff       	call   801d6d <fstat>
  8020ca:	89 c3                	mov    %eax,%ebx
	close(fd);
  8020cc:	89 34 24             	mov    %esi,(%esp)
  8020cf:	e8 91 ff ff ff       	call   802065 <close>
  8020d4:	89 de                	mov    %ebx,%esi
	return r;
}
  8020d6:	89 f0                	mov    %esi,%eax
  8020d8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8020db:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8020de:	89 ec                	mov    %ebp,%esp
  8020e0:	5d                   	pop    %ebp
  8020e1:	c3                   	ret    

008020e2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8020e2:	55                   	push   %ebp
  8020e3:	89 e5                	mov    %esp,%ebp
  8020e5:	83 ec 38             	sub    $0x38,%esp
  8020e8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8020eb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8020ee:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8020f1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8020f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8020fe:	89 04 24             	mov    %eax,(%esp)
  802101:	e8 88 fb ff ff       	call   801c8e <fd_lookup>
  802106:	89 c3                	mov    %eax,%ebx
  802108:	85 c0                	test   %eax,%eax
  80210a:	0f 88 e1 00 00 00    	js     8021f1 <dup+0x10f>
		return r;
	close(newfdnum);
  802110:	89 3c 24             	mov    %edi,(%esp)
  802113:	e8 4d ff ff ff       	call   802065 <close>

	newfd = INDEX2FD(newfdnum);
  802118:	89 f8                	mov    %edi,%eax
  80211a:	c1 e0 0c             	shl    $0xc,%eax
  80211d:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  802123:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802126:	89 04 24             	mov    %eax,(%esp)
  802129:	e8 f2 fa ff ff       	call   801c20 <fd2data>
  80212e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  802130:	89 34 24             	mov    %esi,(%esp)
  802133:	e8 e8 fa ff ff       	call   801c20 <fd2data>
  802138:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  80213b:	89 d8                	mov    %ebx,%eax
  80213d:	c1 e8 16             	shr    $0x16,%eax
  802140:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802147:	a8 01                	test   $0x1,%al
  802149:	74 45                	je     802190 <dup+0xae>
  80214b:	89 da                	mov    %ebx,%edx
  80214d:	c1 ea 0c             	shr    $0xc,%edx
  802150:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  802157:	a8 01                	test   $0x1,%al
  802159:	74 35                	je     802190 <dup+0xae>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  80215b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  802162:	25 07 0e 00 00       	and    $0xe07,%eax
  802167:	89 44 24 10          	mov    %eax,0x10(%esp)
  80216b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80216e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802172:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802179:	00 
  80217a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80217e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802185:	e8 12 f2 ff ff       	call   80139c <sys_page_map>
  80218a:	89 c3                	mov    %eax,%ebx
  80218c:	85 c0                	test   %eax,%eax
  80218e:	78 3e                	js     8021ce <dup+0xec>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  802190:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802193:	89 d0                	mov    %edx,%eax
  802195:	c1 e8 0c             	shr    $0xc,%eax
  802198:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80219f:	25 07 0e 00 00       	and    $0xe07,%eax
  8021a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8021a8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8021ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8021b3:	00 
  8021b4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021bf:	e8 d8 f1 ff ff       	call   80139c <sys_page_map>
  8021c4:	89 c3                	mov    %eax,%ebx
  8021c6:	85 c0                	test   %eax,%eax
  8021c8:	78 04                	js     8021ce <dup+0xec>
		goto err;
  8021ca:	89 fb                	mov    %edi,%ebx
  8021cc:	eb 23                	jmp    8021f1 <dup+0x10f>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8021ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021d9:	e8 60 f1 ff ff       	call   80133e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8021de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021ec:	e8 4d f1 ff ff       	call   80133e <sys_page_unmap>
	return r;
}
  8021f1:	89 d8                	mov    %ebx,%eax
  8021f3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8021f6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8021f9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8021fc:	89 ec                	mov    %ebp,%esp
  8021fe:	5d                   	pop    %ebp
  8021ff:	c3                   	ret    

00802200 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  802200:	55                   	push   %ebp
  802201:	89 e5                	mov    %esp,%ebp
  802203:	53                   	push   %ebx
  802204:	83 ec 04             	sub    $0x4,%esp
  802207:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  80220c:	89 1c 24             	mov    %ebx,(%esp)
  80220f:	e8 51 fe ff ff       	call   802065 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802214:	83 c3 01             	add    $0x1,%ebx
  802217:	83 fb 20             	cmp    $0x20,%ebx
  80221a:	75 f0                	jne    80220c <close_all+0xc>
		close(i);
}
  80221c:	83 c4 04             	add    $0x4,%esp
  80221f:	5b                   	pop    %ebx
  802220:	5d                   	pop    %ebp
  802221:	c3                   	ret    
	...

00802224 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802224:	55                   	push   %ebp
  802225:	89 e5                	mov    %esp,%ebp
  802227:	53                   	push   %ebx
  802228:	83 ec 14             	sub    $0x14,%esp
  80222b:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80222d:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  802233:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80223a:	00 
  80223b:	c7 44 24 08 00 40 80 	movl   $0x804000,0x8(%esp)
  802242:	00 
  802243:	89 44 24 04          	mov    %eax,0x4(%esp)
  802247:	89 14 24             	mov    %edx,(%esp)
  80224a:	e8 21 f8 ff ff       	call   801a70 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80224f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802256:	00 
  802257:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80225b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802262:	e8 bd f8 ff ff       	call   801b24 <ipc_recv>
}
  802267:	83 c4 14             	add    $0x14,%esp
  80226a:	5b                   	pop    %ebx
  80226b:	5d                   	pop    %ebp
  80226c:	c3                   	ret    

0080226d <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  80226d:	55                   	push   %ebp
  80226e:	89 e5                	mov    %esp,%ebp
  802270:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802273:	ba 00 00 00 00       	mov    $0x0,%edx
  802278:	b8 08 00 00 00       	mov    $0x8,%eax
  80227d:	e8 a2 ff ff ff       	call   802224 <fsipc>
}
  802282:	c9                   	leave  
  802283:	c3                   	ret    

00802284 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802284:	55                   	push   %ebp
  802285:	89 e5                	mov    %esp,%ebp
  802287:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80228a:	8b 45 08             	mov    0x8(%ebp),%eax
  80228d:	8b 40 0c             	mov    0xc(%eax),%eax
  802290:	a3 00 40 80 00       	mov    %eax,0x804000
	fsipcbuf.set_size.req_size = newsize;
  802295:	8b 45 0c             	mov    0xc(%ebp),%eax
  802298:	a3 04 40 80 00       	mov    %eax,0x804004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80229d:	ba 00 00 00 00       	mov    $0x0,%edx
  8022a2:	b8 02 00 00 00       	mov    $0x2,%eax
  8022a7:	e8 78 ff ff ff       	call   802224 <fsipc>
}
  8022ac:	c9                   	leave  
  8022ad:	c3                   	ret    

008022ae <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8022ae:	55                   	push   %ebp
  8022af:	89 e5                	mov    %esp,%ebp
  8022b1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8022b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8022ba:	a3 00 40 80 00       	mov    %eax,0x804000
	return fsipc(FSREQ_FLUSH, NULL);
  8022bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8022c4:	b8 06 00 00 00       	mov    $0x6,%eax
  8022c9:	e8 56 ff ff ff       	call   802224 <fsipc>
}
  8022ce:	c9                   	leave  
  8022cf:	c3                   	ret    

008022d0 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8022d0:	55                   	push   %ebp
  8022d1:	89 e5                	mov    %esp,%ebp
  8022d3:	53                   	push   %ebx
  8022d4:	83 ec 14             	sub    $0x14,%esp
  8022d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8022da:	8b 45 08             	mov    0x8(%ebp),%eax
  8022dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8022e0:	a3 00 40 80 00       	mov    %eax,0x804000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8022e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8022ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8022ef:	e8 30 ff ff ff       	call   802224 <fsipc>
  8022f4:	85 c0                	test   %eax,%eax
  8022f6:	78 2b                	js     802323 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8022f8:	c7 44 24 04 00 40 80 	movl   $0x804000,0x4(%esp)
  8022ff:	00 
  802300:	89 1c 24             	mov    %ebx,(%esp)
  802303:	e8 b9 e9 ff ff       	call   800cc1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802308:	a1 80 40 80 00       	mov    0x804080,%eax
  80230d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802313:	a1 84 40 80 00       	mov    0x804084,%eax
  802318:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80231e:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  802323:	83 c4 14             	add    $0x14,%esp
  802326:	5b                   	pop    %ebx
  802327:	5d                   	pop    %ebp
  802328:	c3                   	ret    

00802329 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802329:	55                   	push   %ebp
  80232a:	89 e5                	mov    %esp,%ebp
  80232c:	83 ec 18             	sub    $0x18,%esp
  80232f:	8b 55 10             	mov    0x10(%ebp),%edx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	ssize_t writesize;
	size_t bufsize;
	fsipcbuf.write.req_fileid=fd->fd_file.id;
  802332:	8b 45 08             	mov    0x8(%ebp),%eax
  802335:	8b 40 0c             	mov    0xc(%eax),%eax
  802338:	a3 00 40 80 00       	mov    %eax,0x804000
	bufsize=sizeof(fsipcbuf.write.req_buf);
	if(n<bufsize)
  80233d:	89 d0                	mov    %edx,%eax
  80233f:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  802345:	76 05                	jbe    80234c <devfile_write+0x23>
  802347:	b8 f8 0f 00 00       	mov    $0xff8,%eax
		bufsize=n;	
	fsipcbuf.write.req_n=n;
  80234c:	89 15 04 40 80 00    	mov    %edx,0x804004
	memmove((void*)fsipcbuf.write.req_buf,buf,bufsize);
  802352:	89 44 24 08          	mov    %eax,0x8(%esp)
  802356:	8b 45 0c             	mov    0xc(%ebp),%eax
  802359:	89 44 24 04          	mov    %eax,0x4(%esp)
  80235d:	c7 04 24 08 40 80 00 	movl   $0x804008,(%esp)
  802364:	e8 5f eb ff ff       	call   800ec8 <memmove>
	writesize=(ssize_t)fsipc(FSREQ_WRITE,NULL);
  802369:	ba 00 00 00 00       	mov    $0x0,%edx
  80236e:	b8 04 00 00 00       	mov    $0x4,%eax
  802373:	e8 ac fe ff ff       	call   802224 <fsipc>
	return writesize;
	//panic("devfile_write not implemented");
}
  802378:	c9                   	leave  
  802379:	c3                   	ret    

0080237a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80237a:	55                   	push   %ebp
  80237b:	89 e5                	mov    %esp,%ebp
  80237d:	53                   	push   %ebx
  80237e:	83 ec 14             	sub    $0x14,%esp
	// system server.
	// LAB 5: Your code here
	ssize_t readsize;
	if(debug)
		cprintf("devfile_read:fileid=%x readsize=%x\n",fd->fd_file.id,n);
	fsipcbuf.read.req_fileid=fd->fd_file.id;
  802381:	8b 45 08             	mov    0x8(%ebp),%eax
  802384:	8b 40 0c             	mov    0xc(%eax),%eax
  802387:	a3 00 40 80 00       	mov    %eax,0x804000
	fsipcbuf.read.req_n=n;
  80238c:	8b 45 10             	mov    0x10(%ebp),%eax
  80238f:	a3 04 40 80 00       	mov    %eax,0x804004
	readsize=(ssize_t)fsipc(FSREQ_READ,&fsipcbuf);
  802394:	ba 00 40 80 00       	mov    $0x804000,%edx
  802399:	b8 03 00 00 00       	mov    $0x3,%eax
  80239e:	e8 81 fe ff ff       	call   802224 <fsipc>
  8023a3:	89 c3                	mov    %eax,%ebx
	//cprintf("readsize=%d\n",readsize);
	if(debug)
		cprintf("devfile_read:buf1=%s\nbuf2=%s\n",(char*)&fsipcbuf,fsipcbuf.readRet.ret_buf);
	if(readsize>0)
  8023a5:	85 c0                	test   %eax,%eax
  8023a7:	7e 17                	jle    8023c0 <devfile_read+0x46>
		memmove(buf,(void*)&fsipcbuf,(size_t)readsize);
  8023a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023ad:	c7 44 24 04 00 40 80 	movl   $0x804000,0x4(%esp)
  8023b4:	00 
  8023b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023b8:	89 04 24             	mov    %eax,(%esp)
  8023bb:	e8 08 eb ff ff       	call   800ec8 <memmove>
	//cprintf("readsize=%d",readsize);
	return readsize;
	//panic("devfile_read not implemented");
}
  8023c0:	89 d8                	mov    %ebx,%eax
  8023c2:	83 c4 14             	add    $0x14,%esp
  8023c5:	5b                   	pop    %ebx
  8023c6:	5d                   	pop    %ebp
  8023c7:	c3                   	ret    

008023c8 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8023c8:	55                   	push   %ebp
  8023c9:	89 e5                	mov    %esp,%ebp
  8023cb:	53                   	push   %ebx
  8023cc:	83 ec 14             	sub    $0x14,%esp
  8023cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8023d2:	89 1c 24             	mov    %ebx,(%esp)
  8023d5:	e8 96 e8 ff ff       	call   800c70 <strlen>
  8023da:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  8023df:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8023e4:	7f 21                	jg     802407 <remove+0x3f>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  8023e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8023ea:	c7 04 24 00 40 80 00 	movl   $0x804000,(%esp)
  8023f1:	e8 cb e8 ff ff       	call   800cc1 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  8023f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8023fb:	b8 07 00 00 00       	mov    $0x7,%eax
  802400:	e8 1f fe ff ff       	call   802224 <fsipc>
  802405:	89 c2                	mov    %eax,%edx
}
  802407:	89 d0                	mov    %edx,%eax
  802409:	83 c4 14             	add    $0x14,%esp
  80240c:	5b                   	pop    %ebx
  80240d:	5d                   	pop    %ebp
  80240e:	c3                   	ret    

0080240f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80240f:	55                   	push   %ebp
  802410:	89 e5                	mov    %esp,%ebp
  802412:	56                   	push   %esi
  802413:	53                   	push   %ebx
  802414:	83 ec 30             	sub    $0x30,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;
	void *page;
	if((r=fd_alloc(&fd))<0){
  802417:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80241a:	89 04 24             	mov    %eax,(%esp)
  80241d:	e8 19 f8 ff ff       	call   801c3b <fd_alloc>
  802422:	89 c3                	mov    %eax,%ebx
  802424:	85 c0                	test   %eax,%eax
  802426:	79 18                	jns    802440 <open+0x31>
		fd_close(fd,0);
  802428:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80242f:	00 
  802430:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802433:	89 04 24             	mov    %eax,(%esp)
  802436:	e8 a3 fb ff ff       	call   801fde <fd_close>
  80243b:	e9 9f 00 00 00       	jmp    8024df <open+0xd0>
		return r;
	}
	//cprintf("open:fd=%x\n",fd);
	strcpy(fsipcbuf.open.req_path,path);
  802440:	8b 45 08             	mov    0x8(%ebp),%eax
  802443:	89 44 24 04          	mov    %eax,0x4(%esp)
  802447:	c7 04 24 00 40 80 00 	movl   $0x804000,(%esp)
  80244e:	e8 6e e8 ff ff       	call   800cc1 <strcpy>
	fsipcbuf.open.req_omode=mode;
  802453:	8b 45 0c             	mov    0xc(%ebp),%eax
  802456:	a3 00 44 80 00       	mov    %eax,0x804400
	page=(void*)fd2data(fd);
  80245b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80245e:	89 04 24             	mov    %eax,(%esp)
  802461:	e8 ba f7 ff ff       	call   801c20 <fd2data>
  802466:	89 c6                	mov    %eax,%esi
	if((r=fsipc(FSREQ_OPEN,(void*)fd))<0)
  802468:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80246b:	b8 01 00 00 00       	mov    $0x1,%eax
  802470:	e8 af fd ff ff       	call   802224 <fsipc>
  802475:	89 c3                	mov    %eax,%ebx
  802477:	85 c0                	test   %eax,%eax
  802479:	79 15                	jns    802490 <open+0x81>
	{
		fd_close(fd,1);
  80247b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802482:	00 
  802483:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802486:	89 04 24             	mov    %eax,(%esp)
  802489:	e8 50 fb ff ff       	call   801fde <fd_close>
  80248e:	eb 4f                	jmp    8024df <open+0xd0>
		return r;	
	}
	//cprintf("open:page=%x\n",page);
	if((r=sys_page_map(0,(void*)fd,0,(void*)page,PTE_P | PTE_W | PTE_U))<0)
  802490:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  802497:	00 
  802498:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80249c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8024a3:	00 
  8024a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024b2:	e8 e5 ee ff ff       	call   80139c <sys_page_map>
  8024b7:	89 c3                	mov    %eax,%ebx
  8024b9:	85 c0                	test   %eax,%eax
  8024bb:	79 15                	jns    8024d2 <open+0xc3>
	{
		fd_close(fd,1);
  8024bd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8024c4:	00 
  8024c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024c8:	89 04 24             	mov    %eax,(%esp)
  8024cb:	e8 0e fb ff ff       	call   801fde <fd_close>
  8024d0:	eb 0d                	jmp    8024df <open+0xd0>
		return r;
	}
	//cprintf("open:fileid=%x\n",fd->fd_file.id);
	return fd2num(fd);
  8024d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024d5:	89 04 24             	mov    %eax,(%esp)
  8024d8:	e8 33 f7 ff ff       	call   801c10 <fd2num>
  8024dd:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  8024df:	89 d8                	mov    %ebx,%eax
  8024e1:	83 c4 30             	add    $0x30,%esp
  8024e4:	5b                   	pop    %ebx
  8024e5:	5e                   	pop    %esi
  8024e6:	5d                   	pop    %ebp
  8024e7:	c3                   	ret    
	...

008024f0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8024f0:	55                   	push   %ebp
  8024f1:	89 e5                	mov    %esp,%ebp
  8024f3:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  8024f6:	c7 44 24 04 c0 36 80 	movl   $0x8036c0,0x4(%esp)
  8024fd:	00 
  8024fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  802501:	89 04 24             	mov    %eax,(%esp)
  802504:	e8 b8 e7 ff ff       	call   800cc1 <strcpy>
	return 0;
}
  802509:	b8 00 00 00 00       	mov    $0x0,%eax
  80250e:	c9                   	leave  
  80250f:	c3                   	ret    

00802510 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802510:	55                   	push   %ebp
  802511:	89 e5                	mov    %esp,%ebp
  802513:	83 ec 08             	sub    $0x8,%esp
	return nsipc_close(fd->fd_sock.sockid);
  802516:	8b 45 08             	mov    0x8(%ebp),%eax
  802519:	8b 40 0c             	mov    0xc(%eax),%eax
  80251c:	89 04 24             	mov    %eax,(%esp)
  80251f:	e8 9e 02 00 00       	call   8027c2 <nsipc_close>
}
  802524:	c9                   	leave  
  802525:	c3                   	ret    

00802526 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802526:	55                   	push   %ebp
  802527:	89 e5                	mov    %esp,%ebp
  802529:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80252c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802533:	00 
  802534:	8b 45 10             	mov    0x10(%ebp),%eax
  802537:	89 44 24 08          	mov    %eax,0x8(%esp)
  80253b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80253e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802542:	8b 45 08             	mov    0x8(%ebp),%eax
  802545:	8b 40 0c             	mov    0xc(%eax),%eax
  802548:	89 04 24             	mov    %eax,(%esp)
  80254b:	e8 ae 02 00 00       	call   8027fe <nsipc_send>
}
  802550:	c9                   	leave  
  802551:	c3                   	ret    

00802552 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  802552:	55                   	push   %ebp
  802553:	89 e5                	mov    %esp,%ebp
  802555:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802558:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80255f:	00 
  802560:	8b 45 10             	mov    0x10(%ebp),%eax
  802563:	89 44 24 08          	mov    %eax,0x8(%esp)
  802567:	8b 45 0c             	mov    0xc(%ebp),%eax
  80256a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80256e:	8b 45 08             	mov    0x8(%ebp),%eax
  802571:	8b 40 0c             	mov    0xc(%eax),%eax
  802574:	89 04 24             	mov    %eax,(%esp)
  802577:	e8 f5 02 00 00       	call   802871 <nsipc_recv>
}
  80257c:	c9                   	leave  
  80257d:	c3                   	ret    

0080257e <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  80257e:	55                   	push   %ebp
  80257f:	89 e5                	mov    %esp,%ebp
  802581:	56                   	push   %esi
  802582:	53                   	push   %ebx
  802583:	83 ec 20             	sub    $0x20,%esp
  802586:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802588:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80258b:	89 04 24             	mov    %eax,(%esp)
  80258e:	e8 a8 f6 ff ff       	call   801c3b <fd_alloc>
  802593:	89 c3                	mov    %eax,%ebx
  802595:	85 c0                	test   %eax,%eax
  802597:	78 21                	js     8025ba <alloc_sockfd+0x3c>
  802599:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8025a0:	00 
  8025a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025af:	e8 46 ee ff ff       	call   8013fa <sys_page_alloc>
  8025b4:	89 c3                	mov    %eax,%ebx
  8025b6:	85 c0                	test   %eax,%eax
  8025b8:	79 0a                	jns    8025c4 <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U)) < 0) {
		nsipc_close(sockid);
  8025ba:	89 34 24             	mov    %esi,(%esp)
  8025bd:	e8 00 02 00 00       	call   8027c2 <nsipc_close>
  8025c2:	eb 28                	jmp    8025ec <alloc_sockfd+0x6e>
		return r;
	}

	sfd->fd_dev_id = devsock.dev_id;
  8025c4:	8b 15 20 70 80 00    	mov    0x807020,%edx
  8025ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025cd:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8025cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025d2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8025d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025dc:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8025df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025e2:	89 04 24             	mov    %eax,(%esp)
  8025e5:	e8 26 f6 ff ff       	call   801c10 <fd2num>
  8025ea:	89 c3                	mov    %eax,%ebx
}
  8025ec:	89 d8                	mov    %ebx,%eax
  8025ee:	83 c4 20             	add    $0x20,%esp
  8025f1:	5b                   	pop    %ebx
  8025f2:	5e                   	pop    %esi
  8025f3:	5d                   	pop    %ebp
  8025f4:	c3                   	ret    

008025f5 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8025f5:	55                   	push   %ebp
  8025f6:	89 e5                	mov    %esp,%ebp
  8025f8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8025fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8025fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  802602:	8b 45 0c             	mov    0xc(%ebp),%eax
  802605:	89 44 24 04          	mov    %eax,0x4(%esp)
  802609:	8b 45 08             	mov    0x8(%ebp),%eax
  80260c:	89 04 24             	mov    %eax,(%esp)
  80260f:	e8 62 01 00 00       	call   802776 <nsipc_socket>
  802614:	85 c0                	test   %eax,%eax
  802616:	78 05                	js     80261d <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802618:	e8 61 ff ff ff       	call   80257e <alloc_sockfd>
}
  80261d:	c9                   	leave  
  80261e:	66 90                	xchg   %ax,%ax
  802620:	c3                   	ret    

00802621 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802621:	55                   	push   %ebp
  802622:	89 e5                	mov    %esp,%ebp
  802624:	83 ec 18             	sub    $0x18,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802627:	8d 55 fc             	lea    -0x4(%ebp),%edx
  80262a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80262e:	89 04 24             	mov    %eax,(%esp)
  802631:	e8 58 f6 ff ff       	call   801c8e <fd_lookup>
  802636:	89 c2                	mov    %eax,%edx
  802638:	85 c0                	test   %eax,%eax
  80263a:	78 15                	js     802651 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80263c:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  80263f:	8b 01                	mov    (%ecx),%eax
  802641:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  802646:	3b 05 20 70 80 00    	cmp    0x807020,%eax
  80264c:	75 03                	jne    802651 <fd2sockid+0x30>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80264e:	8b 51 0c             	mov    0xc(%ecx),%edx
}
  802651:	89 d0                	mov    %edx,%eax
  802653:	c9                   	leave  
  802654:	c3                   	ret    

00802655 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  802655:	55                   	push   %ebp
  802656:	89 e5                	mov    %esp,%ebp
  802658:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80265b:	8b 45 08             	mov    0x8(%ebp),%eax
  80265e:	e8 be ff ff ff       	call   802621 <fd2sockid>
  802663:	85 c0                	test   %eax,%eax
  802665:	78 0f                	js     802676 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802667:	8b 55 0c             	mov    0xc(%ebp),%edx
  80266a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80266e:	89 04 24             	mov    %eax,(%esp)
  802671:	e8 2a 01 00 00       	call   8027a0 <nsipc_listen>
}
  802676:	c9                   	leave  
  802677:	c3                   	ret    

00802678 <connect>:
	return nsipc_close(fd->fd_sock.sockid);
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802678:	55                   	push   %ebp
  802679:	89 e5                	mov    %esp,%ebp
  80267b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80267e:	8b 45 08             	mov    0x8(%ebp),%eax
  802681:	e8 9b ff ff ff       	call   802621 <fd2sockid>
  802686:	85 c0                	test   %eax,%eax
  802688:	78 16                	js     8026a0 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80268a:	8b 55 10             	mov    0x10(%ebp),%edx
  80268d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802691:	8b 55 0c             	mov    0xc(%ebp),%edx
  802694:	89 54 24 04          	mov    %edx,0x4(%esp)
  802698:	89 04 24             	mov    %eax,(%esp)
  80269b:	e8 51 02 00 00       	call   8028f1 <nsipc_connect>
}
  8026a0:	c9                   	leave  
  8026a1:	c3                   	ret    

008026a2 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  8026a2:	55                   	push   %ebp
  8026a3:	89 e5                	mov    %esp,%ebp
  8026a5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8026a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8026ab:	e8 71 ff ff ff       	call   802621 <fd2sockid>
  8026b0:	85 c0                	test   %eax,%eax
  8026b2:	78 0f                	js     8026c3 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8026b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8026b7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026bb:	89 04 24             	mov    %eax,(%esp)
  8026be:	e8 19 01 00 00       	call   8027dc <nsipc_shutdown>
}
  8026c3:	c9                   	leave  
  8026c4:	c3                   	ret    

008026c5 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8026c5:	55                   	push   %ebp
  8026c6:	89 e5                	mov    %esp,%ebp
  8026c8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8026cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8026ce:	e8 4e ff ff ff       	call   802621 <fd2sockid>
  8026d3:	85 c0                	test   %eax,%eax
  8026d5:	78 16                	js     8026ed <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  8026d7:	8b 55 10             	mov    0x10(%ebp),%edx
  8026da:	89 54 24 08          	mov    %edx,0x8(%esp)
  8026de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8026e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026e5:	89 04 24             	mov    %eax,(%esp)
  8026e8:	e8 43 02 00 00       	call   802930 <nsipc_bind>
}
  8026ed:	c9                   	leave  
  8026ee:	c3                   	ret    

008026ef <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8026ef:	55                   	push   %ebp
  8026f0:	89 e5                	mov    %esp,%ebp
  8026f2:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8026f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8026f8:	e8 24 ff ff ff       	call   802621 <fd2sockid>
  8026fd:	85 c0                	test   %eax,%eax
  8026ff:	78 1f                	js     802720 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802701:	8b 55 10             	mov    0x10(%ebp),%edx
  802704:	89 54 24 08          	mov    %edx,0x8(%esp)
  802708:	8b 55 0c             	mov    0xc(%ebp),%edx
  80270b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80270f:	89 04 24             	mov    %eax,(%esp)
  802712:	e8 58 02 00 00       	call   80296f <nsipc_accept>
  802717:	85 c0                	test   %eax,%eax
  802719:	78 05                	js     802720 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80271b:	e8 5e fe ff ff       	call   80257e <alloc_sockfd>
}
  802720:	c9                   	leave  
  802721:	c3                   	ret    
	...

00802730 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802730:	55                   	push   %ebp
  802731:	89 e5                	mov    %esp,%ebp
  802733:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802736:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  80273c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802743:	00 
  802744:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  80274b:	00 
  80274c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802750:	89 14 24             	mov    %edx,(%esp)
  802753:	e8 18 f3 ff ff       	call   801a70 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802758:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80275f:	00 
  802760:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802767:	00 
  802768:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80276f:	e8 b0 f3 ff ff       	call   801b24 <ipc_recv>
}
  802774:	c9                   	leave  
  802775:	c3                   	ret    

00802776 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802776:	55                   	push   %ebp
  802777:	89 e5                	mov    %esp,%ebp
  802779:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80277c:	8b 45 08             	mov    0x8(%ebp),%eax
  80277f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802784:	8b 45 0c             	mov    0xc(%ebp),%eax
  802787:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80278c:	8b 45 10             	mov    0x10(%ebp),%eax
  80278f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802794:	b8 09 00 00 00       	mov    $0x9,%eax
  802799:	e8 92 ff ff ff       	call   802730 <nsipc>
}
  80279e:	c9                   	leave  
  80279f:	c3                   	ret    

008027a0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  8027a0:	55                   	push   %ebp
  8027a1:	89 e5                	mov    %esp,%ebp
  8027a3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8027a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8027a9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8027ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027b1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8027b6:	b8 06 00 00 00       	mov    $0x6,%eax
  8027bb:	e8 70 ff ff ff       	call   802730 <nsipc>
}
  8027c0:	c9                   	leave  
  8027c1:	c3                   	ret    

008027c2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  8027c2:	55                   	push   %ebp
  8027c3:	89 e5                	mov    %esp,%ebp
  8027c5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8027c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8027cb:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8027d0:	b8 04 00 00 00       	mov    $0x4,%eax
  8027d5:	e8 56 ff ff ff       	call   802730 <nsipc>
}
  8027da:	c9                   	leave  
  8027db:	c3                   	ret    

008027dc <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  8027dc:	55                   	push   %ebp
  8027dd:	89 e5                	mov    %esp,%ebp
  8027df:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8027e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8027e5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8027ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027ed:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8027f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8027f7:	e8 34 ff ff ff       	call   802730 <nsipc>
}
  8027fc:	c9                   	leave  
  8027fd:	c3                   	ret    

008027fe <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8027fe:	55                   	push   %ebp
  8027ff:	89 e5                	mov    %esp,%ebp
  802801:	53                   	push   %ebx
  802802:	83 ec 14             	sub    $0x14,%esp
  802805:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802808:	8b 45 08             	mov    0x8(%ebp),%eax
  80280b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  802810:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802816:	7e 24                	jle    80283c <nsipc_send+0x3e>
  802818:	c7 44 24 0c cc 36 80 	movl   $0x8036cc,0xc(%esp)
  80281f:	00 
  802820:	c7 44 24 08 d8 36 80 	movl   $0x8036d8,0x8(%esp)
  802827:	00 
  802828:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  80282f:	00 
  802830:	c7 04 24 ed 36 80 00 	movl   $0x8036ed,(%esp)
  802837:	e8 50 dd ff ff       	call   80058c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80283c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802840:	8b 45 0c             	mov    0xc(%ebp),%eax
  802843:	89 44 24 04          	mov    %eax,0x4(%esp)
  802847:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  80284e:	e8 75 e6 ff ff       	call   800ec8 <memmove>
	nsipcbuf.send.req_size = size;
  802853:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  802859:	8b 45 14             	mov    0x14(%ebp),%eax
  80285c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  802861:	b8 08 00 00 00       	mov    $0x8,%eax
  802866:	e8 c5 fe ff ff       	call   802730 <nsipc>
}
  80286b:	83 c4 14             	add    $0x14,%esp
  80286e:	5b                   	pop    %ebx
  80286f:	5d                   	pop    %ebp
  802870:	c3                   	ret    

00802871 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802871:	55                   	push   %ebp
  802872:	89 e5                	mov    %esp,%ebp
  802874:	56                   	push   %esi
  802875:	53                   	push   %ebx
  802876:	83 ec 10             	sub    $0x10,%esp
  802879:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80287c:	8b 45 08             	mov    0x8(%ebp),%eax
  80287f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  802884:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80288a:	8b 45 14             	mov    0x14(%ebp),%eax
  80288d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802892:	b8 07 00 00 00       	mov    $0x7,%eax
  802897:	e8 94 fe ff ff       	call   802730 <nsipc>
  80289c:	89 c3                	mov    %eax,%ebx
  80289e:	85 c0                	test   %eax,%eax
  8028a0:	78 46                	js     8028e8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8028a2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8028a7:	7f 04                	jg     8028ad <nsipc_recv+0x3c>
  8028a9:	39 c6                	cmp    %eax,%esi
  8028ab:	7d 24                	jge    8028d1 <nsipc_recv+0x60>
  8028ad:	c7 44 24 0c f9 36 80 	movl   $0x8036f9,0xc(%esp)
  8028b4:	00 
  8028b5:	c7 44 24 08 d8 36 80 	movl   $0x8036d8,0x8(%esp)
  8028bc:	00 
  8028bd:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  8028c4:	00 
  8028c5:	c7 04 24 ed 36 80 00 	movl   $0x8036ed,(%esp)
  8028cc:	e8 bb dc ff ff       	call   80058c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8028d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8028d5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8028dc:	00 
  8028dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028e0:	89 04 24             	mov    %eax,(%esp)
  8028e3:	e8 e0 e5 ff ff       	call   800ec8 <memmove>
	}

	return r;
}
  8028e8:	89 d8                	mov    %ebx,%eax
  8028ea:	83 c4 10             	add    $0x10,%esp
  8028ed:	5b                   	pop    %ebx
  8028ee:	5e                   	pop    %esi
  8028ef:	5d                   	pop    %ebp
  8028f0:	c3                   	ret    

008028f1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8028f1:	55                   	push   %ebp
  8028f2:	89 e5                	mov    %esp,%ebp
  8028f4:	53                   	push   %ebx
  8028f5:	83 ec 14             	sub    $0x14,%esp
  8028f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8028fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8028fe:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802903:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802907:	8b 45 0c             	mov    0xc(%ebp),%eax
  80290a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80290e:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  802915:	e8 ae e5 ff ff       	call   800ec8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80291a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  802920:	b8 05 00 00 00       	mov    $0x5,%eax
  802925:	e8 06 fe ff ff       	call   802730 <nsipc>
}
  80292a:	83 c4 14             	add    $0x14,%esp
  80292d:	5b                   	pop    %ebx
  80292e:	5d                   	pop    %ebp
  80292f:	c3                   	ret    

00802930 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802930:	55                   	push   %ebp
  802931:	89 e5                	mov    %esp,%ebp
  802933:	53                   	push   %ebx
  802934:	83 ec 14             	sub    $0x14,%esp
  802937:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80293a:	8b 45 08             	mov    0x8(%ebp),%eax
  80293d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802942:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802946:	8b 45 0c             	mov    0xc(%ebp),%eax
  802949:	89 44 24 04          	mov    %eax,0x4(%esp)
  80294d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  802954:	e8 6f e5 ff ff       	call   800ec8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802959:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80295f:	b8 02 00 00 00       	mov    $0x2,%eax
  802964:	e8 c7 fd ff ff       	call   802730 <nsipc>
}
  802969:	83 c4 14             	add    $0x14,%esp
  80296c:	5b                   	pop    %ebx
  80296d:	5d                   	pop    %ebp
  80296e:	c3                   	ret    

0080296f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80296f:	55                   	push   %ebp
  802970:	89 e5                	mov    %esp,%ebp
  802972:	53                   	push   %ebx
  802973:	83 ec 14             	sub    $0x14,%esp
	int r;
	
	nsipcbuf.accept.req_s = s;
  802976:	8b 45 08             	mov    0x8(%ebp),%eax
  802979:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80297e:	b8 01 00 00 00       	mov    $0x1,%eax
  802983:	e8 a8 fd ff ff       	call   802730 <nsipc>
  802988:	89 c3                	mov    %eax,%ebx
  80298a:	85 c0                	test   %eax,%eax
  80298c:	78 26                	js     8029b4 <nsipc_accept+0x45>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80298e:	a1 10 60 80 00       	mov    0x806010,%eax
  802993:	89 44 24 08          	mov    %eax,0x8(%esp)
  802997:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80299e:	00 
  80299f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029a2:	89 04 24             	mov    %eax,(%esp)
  8029a5:	e8 1e e5 ff ff       	call   800ec8 <memmove>
		*addrlen = ret->ret_addrlen;
  8029aa:	a1 10 60 80 00       	mov    0x806010,%eax
  8029af:	8b 55 10             	mov    0x10(%ebp),%edx
  8029b2:	89 02                	mov    %eax,(%edx)
	}
	return r;
}
  8029b4:	89 d8                	mov    %ebx,%eax
  8029b6:	83 c4 14             	add    $0x14,%esp
  8029b9:	5b                   	pop    %ebx
  8029ba:	5d                   	pop    %ebp
  8029bb:	c3                   	ret    

008029bc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8029bc:	55                   	push   %ebp
  8029bd:	89 e5                	mov    %esp,%ebp
  8029bf:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8029c2:	83 3d 5c 70 80 00 00 	cmpl   $0x0,0x80705c
  8029c9:	75 6a                	jne    802a35 <set_pgfault_handler+0x79>
		// First time through!
		// LAB 4: Your code here.
		env=(struct Env*)&envs[ENVX(sys_getenvid())];
  8029cb:	e8 bd ea ff ff       	call   80148d <sys_getenvid>
  8029d0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8029d5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8029d8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8029dd:	a3 54 70 80 00       	mov    %eax,0x807054
		if((r=sys_page_alloc(env->env_id,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  8029e2:	8b 40 4c             	mov    0x4c(%eax),%eax
  8029e5:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8029ec:	00 
  8029ed:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8029f4:	ee 
  8029f5:	89 04 24             	mov    %eax,(%esp)
  8029f8:	e8 fd e9 ff ff       	call   8013fa <sys_page_alloc>
  8029fd:	85 c0                	test   %eax,%eax
  8029ff:	79 1c                	jns    802a1d <set_pgfault_handler+0x61>
		{
			panic("Alloc a page for an exception stack failed");
  802a01:	c7 44 24 08 10 37 80 	movl   $0x803710,0x8(%esp)
  802a08:	00 
  802a09:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802a10:	00 
  802a11:	c7 04 24 3c 37 80 00 	movl   $0x80373c,(%esp)
  802a18:	e8 6f db ff ff       	call   80058c <_panic>
		}
		sys_env_set_pgfault_upcall(env->env_id,(void*)_pgfault_upcall);
  802a1d:	a1 54 70 80 00       	mov    0x807054,%eax
  802a22:	8b 40 4c             	mov    0x4c(%eax),%eax
  802a25:	c7 44 24 04 40 2a 80 	movl   $0x802a40,0x4(%esp)
  802a2c:	00 
  802a2d:	89 04 24             	mov    %eax,(%esp)
  802a30:	e8 ef e7 ff ff       	call   801224 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802a35:	8b 45 08             	mov    0x8(%ebp),%eax
  802a38:	a3 5c 70 80 00       	mov    %eax,0x80705c
}
  802a3d:	c9                   	leave  
  802a3e:	c3                   	ret    
	...

00802a40 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802a40:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802a41:	a1 5c 70 80 00       	mov    0x80705c,%eax
	call *%eax
  802a46:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802a48:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.这个有点难度，需要认真编写
	movl  0x28(%esp),%eax //把utf->utf_eip入栈
  802a4b:	8b 44 24 28          	mov    0x28(%esp),%eax
	pushl %eax
  802a4f:	50                   	push   %eax
	movl %esp,%eax
  802a50:	89 e0                	mov    %esp,%eax
	movl 0x34(%eax),%esp  //切换到用户普通栈，压入utf_eip
  802a52:	8b 60 34             	mov    0x34(%eax),%esp
	pushl (%eax)
  802a55:	ff 30                	pushl  (%eax)
	movl %eax,%esp	     //切到用户异常栈
  802a57:	89 c4                	mov    %eax,%esp
	subl $0x4,0x34(%esp) //将utf->utf_esp减去4,指向返回地址,后面不能算术操作，就在这算
  802a59:	83 6c 24 34 04       	subl   $0x4,0x34(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0xc,%esp     //恢复通用寄存器
  802a5e:	83 c4 0c             	add    $0xc,%esp
	popal
  802a61:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp  //恢复eflags
  802a62:	83 c4 04             	add    $0x4,%esp
	popfl          //在用户态，该指令能否修改eflags?可以的
  802a65:	9d                   	popf   
		       //执行完这个指令后，不能进行算术任何算术运算哦，否则eflags里面的值不对
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp     //切换到用户普通栈，用户从异常处理退出后，需要继续使用该栈
  802a66:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802a67:	c3                   	ret    
	...

00802a70 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  802a70:	55                   	push   %ebp
  802a71:	89 e5                	mov    %esp,%ebp
  802a73:	57                   	push   %edi
  802a74:	56                   	push   %esi
  802a75:	53                   	push   %ebx
  802a76:	83 ec 18             	sub    $0x18,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  802a79:	8b 45 08             	mov    0x8(%ebp),%eax
  802a7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  802a7f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802a82:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802a85:	be 00 00 00 00       	mov    $0x0,%esi
  802a8a:	bf 44 70 80 00       	mov    $0x807044,%edi
  802a8f:	c6 45 e3 00          	movb   $0x0,-0x1d(%ebp)
  802a93:	eb 02                	jmp    802a97 <inet_ntoa+0x27>
  for(n = 0; n < 4; n++) {
  802a95:	89 c6                	mov    %eax,%esi
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  802a97:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802a9a:	0f b6 0a             	movzbl (%edx),%ecx
      *ap /= (u8_t)10;
  802a9d:	b8 cd ff ff ff       	mov    $0xffffffcd,%eax
  802aa2:	f6 e1                	mul    %cl
  802aa4:	89 c2                	mov    %eax,%edx
  802aa6:	66 c1 ea 08          	shr    $0x8,%dx
  802aaa:	c0 ea 03             	shr    $0x3,%dl
  802aad:	8b 45 dc             	mov    -0x24(%ebp),%eax
  802ab0:	88 10                	mov    %dl,(%eax)
      inv[i++] = '0' + rem;
  802ab2:	89 f0                	mov    %esi,%eax
  802ab4:	0f b6 d8             	movzbl %al,%ebx
  802ab7:	8d 04 92             	lea    (%edx,%edx,4),%eax
  802aba:	01 c0                	add    %eax,%eax
  802abc:	28 c1                	sub    %al,%cl
  802abe:	83 c1 30             	add    $0x30,%ecx
  802ac1:	88 4c 1d ed          	mov    %cl,-0x13(%ebp,%ebx,1)
  802ac5:	8d 46 01             	lea    0x1(%esi),%eax
    } while(*ap);
  802ac8:	84 d2                	test   %dl,%dl
  802aca:	75 c9                	jne    802a95 <inet_ntoa+0x25>
    while(i--)
  802acc:	89 f1                	mov    %esi,%ecx
  802ace:	80 f9 ff             	cmp    $0xff,%cl
  802ad1:	74 20                	je     802af3 <inet_ntoa+0x83>
  802ad3:	89 fa                	mov    %edi,%edx
      *rp++ = inv[i];
  802ad5:	0f b6 c1             	movzbl %cl,%eax
  802ad8:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  802add:	88 02                	mov    %al,(%edx)
  802adf:	83 c2 01             	add    $0x1,%edx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  802ae2:	83 e9 01             	sub    $0x1,%ecx
  802ae5:	80 f9 ff             	cmp    $0xff,%cl
  802ae8:	75 eb                	jne    802ad5 <inet_ntoa+0x65>
  802aea:	89 f2                	mov    %esi,%edx
  802aec:	0f b6 c2             	movzbl %dl,%eax
  802aef:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
      *rp++ = inv[i];
    *rp++ = '.';
  802af3:	c6 07 2e             	movb   $0x2e,(%edi)
  802af6:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  802af9:	80 45 e3 01          	addb   $0x1,-0x1d(%ebp)
  802afd:	80 7d e3 03          	cmpb   $0x3,-0x1d(%ebp)
  802b01:	77 0b                	ja     802b0e <inet_ntoa+0x9e>
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  802b03:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  802b07:	b8 00 00 00 00       	mov    $0x0,%eax
  802b0c:	eb 87                	jmp    802a95 <inet_ntoa+0x25>
  }
  *--rp = 0;
  802b0e:	c6 47 ff 00          	movb   $0x0,-0x1(%edi)
  return str;
}
  802b12:	b8 44 70 80 00       	mov    $0x807044,%eax
  802b17:	83 c4 18             	add    $0x18,%esp
  802b1a:	5b                   	pop    %ebx
  802b1b:	5e                   	pop    %esi
  802b1c:	5f                   	pop    %edi
  802b1d:	5d                   	pop    %ebp
  802b1e:	c3                   	ret    

00802b1f <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  802b1f:	55                   	push   %ebp
  802b20:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  802b22:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  802b26:	89 c2                	mov    %eax,%edx
  802b28:	c1 ea 08             	shr    $0x8,%edx
  802b2b:	c1 e0 08             	shl    $0x8,%eax
  802b2e:	09 d0                	or     %edx,%eax
  802b30:	0f b7 c0             	movzwl %ax,%eax
}
  802b33:	5d                   	pop    %ebp
  802b34:	c3                   	ret    

00802b35 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  802b35:	55                   	push   %ebp
  802b36:	89 e5                	mov    %esp,%ebp
  802b38:	83 ec 04             	sub    $0x4,%esp
  return htons(n);
  802b3b:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  802b3f:	89 04 24             	mov    %eax,(%esp)
  802b42:	e8 d8 ff ff ff       	call   802b1f <htons>
  802b47:	0f b7 c0             	movzwl %ax,%eax
}
  802b4a:	c9                   	leave  
  802b4b:	c3                   	ret    

00802b4c <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  802b4c:	55                   	push   %ebp
  802b4d:	89 e5                	mov    %esp,%ebp
  802b4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802b52:	89 c8                	mov    %ecx,%eax
  802b54:	25 00 ff 00 00       	and    $0xff00,%eax
  802b59:	c1 e0 08             	shl    $0x8,%eax
  802b5c:	89 ca                	mov    %ecx,%edx
  802b5e:	c1 e2 18             	shl    $0x18,%edx
  802b61:	09 d0                	or     %edx,%eax
  802b63:	89 ca                	mov    %ecx,%edx
  802b65:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  802b6b:	c1 ea 08             	shr    $0x8,%edx
  802b6e:	09 d0                	or     %edx,%eax
  802b70:	c1 e9 18             	shr    $0x18,%ecx
  802b73:	09 c8                	or     %ecx,%eax
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  802b75:	5d                   	pop    %ebp
  802b76:	c3                   	ret    

00802b77 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  802b77:	55                   	push   %ebp
  802b78:	89 e5                	mov    %esp,%ebp
  802b7a:	57                   	push   %edi
  802b7b:	56                   	push   %esi
  802b7c:	53                   	push   %ebx
  802b7d:	83 ec 24             	sub    $0x24,%esp
  802b80:	8b 55 08             	mov    0x8(%ebp),%edx
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  802b83:	0f be 32             	movsbl (%edx),%esi
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  802b86:	8d 46 d0             	lea    -0x30(%esi),%eax
  802b89:	3c 09                	cmp    $0x9,%al
  802b8b:	0f 87 c0 01 00 00    	ja     802d51 <inet_aton+0x1da>
  802b91:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802b94:	89 45 e0             	mov    %eax,-0x20(%ebp)
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  802b97:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802b9a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     */
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
  802b9d:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
  802ba4:	83 fe 30             	cmp    $0x30,%esi
  802ba7:	75 24                	jne    802bcd <inet_aton+0x56>
      c = *++cp;
  802ba9:	83 c2 01             	add    $0x1,%edx
  802bac:	0f be 32             	movsbl (%edx),%esi
      if (c == 'x' || c == 'X') {
  802baf:	83 fe 78             	cmp    $0x78,%esi
  802bb2:	74 0c                	je     802bc0 <inet_aton+0x49>
  802bb4:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  802bbb:	83 fe 58             	cmp    $0x58,%esi
  802bbe:	75 0d                	jne    802bcd <inet_aton+0x56>
        base = 16;
        c = *++cp;
  802bc0:	83 c2 01             	add    $0x1,%edx
  802bc3:	0f be 32             	movsbl (%edx),%esi
  802bc6:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  802bcd:	8d 5a 01             	lea    0x1(%edx),%ebx
  802bd0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  802bd7:	eb 03                	jmp    802bdc <inet_aton+0x65>
  802bd9:	83 c3 01             	add    $0x1,%ebx
  802bdc:	8d 7b ff             	lea    -0x1(%ebx),%edi
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  802bdf:	89 f1                	mov    %esi,%ecx
  802be1:	8d 41 d0             	lea    -0x30(%ecx),%eax
  802be4:	3c 09                	cmp    $0x9,%al
  802be6:	77 13                	ja     802bfb <inet_aton+0x84>
        val = (val * base) + (int)(c - '0');
  802be8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  802beb:	0f af 45 d8          	imul   -0x28(%ebp),%eax
  802bef:	8d 74 06 d0          	lea    -0x30(%esi,%eax,1),%esi
  802bf3:	89 75 d8             	mov    %esi,-0x28(%ebp)
        c = *++cp;
  802bf6:	0f be 33             	movsbl (%ebx),%esi
  802bf9:	eb de                	jmp    802bd9 <inet_aton+0x62>
      } else if (base == 16 && isxdigit(c)) {
  802bfb:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  802bff:	75 2c                	jne    802c2d <inet_aton+0xb6>
  802c01:	8d 51 9f             	lea    -0x61(%ecx),%edx
  802c04:	80 fa 05             	cmp    $0x5,%dl
  802c07:	76 07                	jbe    802c10 <inet_aton+0x99>
  802c09:	8d 41 bf             	lea    -0x41(%ecx),%eax
  802c0c:	3c 05                	cmp    $0x5,%al
  802c0e:	77 1d                	ja     802c2d <inet_aton+0xb6>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  802c10:	80 fa 1a             	cmp    $0x1a,%dl
  802c13:	19 c0                	sbb    %eax,%eax
  802c15:	83 e0 20             	and    $0x20,%eax
  802c18:	29 c6                	sub    %eax,%esi
  802c1a:	8d 46 c9             	lea    -0x37(%esi),%eax
  802c1d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  802c20:	c1 e2 04             	shl    $0x4,%edx
  802c23:	09 d0                	or     %edx,%eax
  802c25:	89 45 d8             	mov    %eax,-0x28(%ebp)
        c = *++cp;
  802c28:	0f be 33             	movsbl (%ebx),%esi
  802c2b:	eb ac                	jmp    802bd9 <inet_aton+0x62>
      } else
        break;
    }
    if (c == '.') {
  802c2d:	83 fe 2e             	cmp    $0x2e,%esi
  802c30:	75 2c                	jne    802c5e <inet_aton+0xe7>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  802c32:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802c35:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  802c38:	0f 86 13 01 00 00    	jbe    802d51 <inet_aton+0x1da>
        return (0);
      *pp++ = val;
  802c3e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802c41:	89 02                	mov    %eax,(%edx)
      c = *++cp;
  802c43:	8d 57 01             	lea    0x1(%edi),%edx
  802c46:	0f be 77 01          	movsbl 0x1(%edi),%esi
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  802c4a:	8d 46 d0             	lea    -0x30(%esi),%eax
  802c4d:	3c 09                	cmp    $0x9,%al
  802c4f:	0f 87 fc 00 00 00    	ja     802d51 <inet_aton+0x1da>
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
      *pp++ = val;
  802c55:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
  802c59:	e9 3f ff ff ff       	jmp    802b9d <inet_aton+0x26>
  802c5e:	8b 5d d8             	mov    -0x28(%ebp),%ebx
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  802c61:	85 f6                	test   %esi,%esi
  802c63:	74 36                	je     802c9b <inet_aton+0x124>
  802c65:	80 f9 1f             	cmp    $0x1f,%cl
  802c68:	0f 86 e3 00 00 00    	jbe    802d51 <inet_aton+0x1da>
  802c6e:	89 f2                	mov    %esi,%edx
  802c70:	84 d2                	test   %dl,%dl
  802c72:	0f 88 d9 00 00 00    	js     802d51 <inet_aton+0x1da>
  802c78:	83 fe 20             	cmp    $0x20,%esi
  802c7b:	74 1e                	je     802c9b <inet_aton+0x124>
  802c7d:	83 fe 0c             	cmp    $0xc,%esi
  802c80:	74 19                	je     802c9b <inet_aton+0x124>
  802c82:	83 fe 0a             	cmp    $0xa,%esi
  802c85:	74 14                	je     802c9b <inet_aton+0x124>
  802c87:	83 fe 0d             	cmp    $0xd,%esi
  802c8a:	74 0f                	je     802c9b <inet_aton+0x124>
  802c8c:	83 fe 09             	cmp    $0x9,%esi
  802c8f:	90                   	nop    
  802c90:	74 09                	je     802c9b <inet_aton+0x124>
  802c92:	83 fe 0b             	cmp    $0xb,%esi
  802c95:	0f 85 b6 00 00 00    	jne    802d51 <inet_aton+0x1da>
    return (0);
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  802c9b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  switch (n) {
  802c9e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802ca1:	29 c2                	sub    %eax,%edx
  802ca3:	89 d0                	mov    %edx,%eax
  802ca5:	c1 f8 02             	sar    $0x2,%eax
  802ca8:	83 c0 01             	add    $0x1,%eax
  802cab:	83 f8 02             	cmp    $0x2,%eax
  802cae:	74 24                	je     802cd4 <inet_aton+0x15d>
  802cb0:	83 f8 02             	cmp    $0x2,%eax
  802cb3:	7f 0d                	jg     802cc2 <inet_aton+0x14b>
  802cb5:	85 c0                	test   %eax,%eax
  802cb7:	0f 84 94 00 00 00    	je     802d51 <inet_aton+0x1da>
  802cbd:	8d 76 00             	lea    0x0(%esi),%esi
  802cc0:	eb 6d                	jmp    802d2f <inet_aton+0x1b8>
  802cc2:	83 f8 03             	cmp    $0x3,%eax
  802cc5:	74 28                	je     802cef <inet_aton+0x178>
  802cc7:	83 f8 04             	cmp    $0x4,%eax
  802cca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802cd0:	75 5d                	jne    802d2f <inet_aton+0x1b8>
  802cd2:	eb 38                	jmp    802d0c <inet_aton+0x195>

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  802cd4:	81 fb ff ff ff 00    	cmp    $0xffffff,%ebx
  802cda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802ce0:	77 6f                	ja     802d51 <inet_aton+0x1da>
      return (0);
    val |= parts[0] << 24;
  802ce2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802ce5:	c1 e0 18             	shl    $0x18,%eax
  802ce8:	09 c3                	or     %eax,%ebx
  802cea:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  802ced:	eb 40                	jmp    802d2f <inet_aton+0x1b8>
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  802cef:	81 fb ff ff 00 00    	cmp    $0xffff,%ebx
  802cf5:	77 5a                	ja     802d51 <inet_aton+0x1da>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  802cf7:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802cfa:	c1 e2 10             	shl    $0x10,%edx
  802cfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802d00:	c1 e0 18             	shl    $0x18,%eax
  802d03:	09 c2                	or     %eax,%edx
  802d05:	09 da                	or     %ebx,%edx
  802d07:	89 55 d8             	mov    %edx,-0x28(%ebp)
  802d0a:	eb 23                	jmp    802d2f <inet_aton+0x1b8>
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  802d0c:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
  802d12:	77 3d                	ja     802d51 <inet_aton+0x1da>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  802d14:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802d17:	c1 e0 10             	shl    $0x10,%eax
  802d1a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802d1d:	c1 e2 18             	shl    $0x18,%edx
  802d20:	09 d0                	or     %edx,%eax
  802d22:	8b 55 ec             	mov    -0x14(%ebp),%edx
  802d25:	c1 e2 08             	shl    $0x8,%edx
  802d28:	09 d0                	or     %edx,%eax
  802d2a:	09 d8                	or     %ebx,%eax
  802d2c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    break;
  }
  if (addr)
  802d2f:	b8 01 00 00 00       	mov    $0x1,%eax
  802d34:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802d38:	74 1c                	je     802d56 <inet_aton+0x1df>
    addr->s_addr = htonl(val);
  802d3a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802d3d:	89 04 24             	mov    %eax,(%esp)
  802d40:	e8 07 fe ff ff       	call   802b4c <htonl>
  802d45:	8b 55 0c             	mov    0xc(%ebp),%edx
  802d48:	89 02                	mov    %eax,(%edx)
  802d4a:	b8 01 00 00 00       	mov    $0x1,%eax
  802d4f:	eb 05                	jmp    802d56 <inet_aton+0x1df>
  802d51:	b8 00 00 00 00       	mov    $0x0,%eax
  return (1);
}
  802d56:	83 c4 24             	add    $0x24,%esp
  802d59:	5b                   	pop    %ebx
  802d5a:	5e                   	pop    %esi
  802d5b:	5f                   	pop    %edi
  802d5c:	5d                   	pop    %ebp
  802d5d:	c3                   	ret    

00802d5e <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  802d5e:	55                   	push   %ebp
  802d5f:	89 e5                	mov    %esp,%ebp
  802d61:	83 ec 18             	sub    $0x18,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  802d64:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802d67:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  802d6e:	89 04 24             	mov    %eax,(%esp)
  802d71:	e8 01 fe ff ff       	call   802b77 <inet_aton>
  802d76:	83 f8 01             	cmp    $0x1,%eax
  802d79:	19 c0                	sbb    %eax,%eax
  802d7b:	0b 45 fc             	or     -0x4(%ebp),%eax
    return (val.s_addr);
  }
  return (INADDR_NONE);
}
  802d7e:	c9                   	leave  
  802d7f:	c3                   	ret    

00802d80 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  802d80:	55                   	push   %ebp
  802d81:	89 e5                	mov    %esp,%ebp
  802d83:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  802d86:	8b 45 08             	mov    0x8(%ebp),%eax
  802d89:	89 04 24             	mov    %eax,(%esp)
  802d8c:	e8 bb fd ff ff       	call   802b4c <htonl>
}
  802d91:	c9                   	leave  
  802d92:	c3                   	ret    
	...

00802da0 <__udivdi3>:
  802da0:	55                   	push   %ebp
  802da1:	89 e5                	mov    %esp,%ebp
  802da3:	57                   	push   %edi
  802da4:	56                   	push   %esi
  802da5:	83 ec 18             	sub    $0x18,%esp
  802da8:	8b 45 10             	mov    0x10(%ebp),%eax
  802dab:	8b 55 14             	mov    0x14(%ebp),%edx
  802dae:	8b 75 0c             	mov    0xc(%ebp),%esi
  802db1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802db4:	89 c1                	mov    %eax,%ecx
  802db6:	8b 45 08             	mov    0x8(%ebp),%eax
  802db9:	85 d2                	test   %edx,%edx
  802dbb:	89 d7                	mov    %edx,%edi
  802dbd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802dc0:	75 1e                	jne    802de0 <__udivdi3+0x40>
  802dc2:	39 f1                	cmp    %esi,%ecx
  802dc4:	0f 86 8d 00 00 00    	jbe    802e57 <__udivdi3+0xb7>
  802dca:	89 f2                	mov    %esi,%edx
  802dcc:	31 f6                	xor    %esi,%esi
  802dce:	f7 f1                	div    %ecx
  802dd0:	89 c1                	mov    %eax,%ecx
  802dd2:	89 c8                	mov    %ecx,%eax
  802dd4:	89 f2                	mov    %esi,%edx
  802dd6:	83 c4 18             	add    $0x18,%esp
  802dd9:	5e                   	pop    %esi
  802dda:	5f                   	pop    %edi
  802ddb:	5d                   	pop    %ebp
  802ddc:	c3                   	ret    
  802ddd:	8d 76 00             	lea    0x0(%esi),%esi
  802de0:	39 f2                	cmp    %esi,%edx
  802de2:	0f 87 a8 00 00 00    	ja     802e90 <__udivdi3+0xf0>
  802de8:	0f bd c2             	bsr    %edx,%eax
  802deb:	83 f0 1f             	xor    $0x1f,%eax
  802dee:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802df1:	0f 84 89 00 00 00    	je     802e80 <__udivdi3+0xe0>
  802df7:	b8 20 00 00 00       	mov    $0x20,%eax
  802dfc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802dff:	2b 45 e8             	sub    -0x18(%ebp),%eax
  802e02:	89 c1                	mov    %eax,%ecx
  802e04:	d3 ea                	shr    %cl,%edx
  802e06:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  802e0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802e0d:	89 f8                	mov    %edi,%eax
  802e0f:	8b 7d f4             	mov    -0xc(%ebp),%edi
  802e12:	d3 e0                	shl    %cl,%eax
  802e14:	09 c2                	or     %eax,%edx
  802e16:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802e19:	d3 e7                	shl    %cl,%edi
  802e1b:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802e1f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802e22:	89 f2                	mov    %esi,%edx
  802e24:	d3 e8                	shr    %cl,%eax
  802e26:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  802e2a:	d3 e2                	shl    %cl,%edx
  802e2c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802e30:	09 d0                	or     %edx,%eax
  802e32:	d3 ee                	shr    %cl,%esi
  802e34:	89 f2                	mov    %esi,%edx
  802e36:	f7 75 e4             	divl   -0x1c(%ebp)
  802e39:	89 d1                	mov    %edx,%ecx
  802e3b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  802e3e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802e41:	f7 e7                	mul    %edi
  802e43:	39 d1                	cmp    %edx,%ecx
  802e45:	89 c6                	mov    %eax,%esi
  802e47:	72 70                	jb     802eb9 <__udivdi3+0x119>
  802e49:	39 ca                	cmp    %ecx,%edx
  802e4b:	74 5f                	je     802eac <__udivdi3+0x10c>
  802e4d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802e50:	31 f6                	xor    %esi,%esi
  802e52:	e9 7b ff ff ff       	jmp    802dd2 <__udivdi3+0x32>
  802e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e5a:	85 c0                	test   %eax,%eax
  802e5c:	75 0c                	jne    802e6a <__udivdi3+0xca>
  802e5e:	b8 01 00 00 00       	mov    $0x1,%eax
  802e63:	31 d2                	xor    %edx,%edx
  802e65:	f7 75 f4             	divl   -0xc(%ebp)
  802e68:	89 c1                	mov    %eax,%ecx
  802e6a:	89 f0                	mov    %esi,%eax
  802e6c:	89 fa                	mov    %edi,%edx
  802e6e:	f7 f1                	div    %ecx
  802e70:	89 c6                	mov    %eax,%esi
  802e72:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802e75:	f7 f1                	div    %ecx
  802e77:	89 c1                	mov    %eax,%ecx
  802e79:	e9 54 ff ff ff       	jmp    802dd2 <__udivdi3+0x32>
  802e7e:	66 90                	xchg   %ax,%ax
  802e80:	39 d6                	cmp    %edx,%esi
  802e82:	77 1c                	ja     802ea0 <__udivdi3+0x100>
  802e84:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802e87:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  802e8a:	73 14                	jae    802ea0 <__udivdi3+0x100>
  802e8c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802e90:	31 c9                	xor    %ecx,%ecx
  802e92:	31 f6                	xor    %esi,%esi
  802e94:	e9 39 ff ff ff       	jmp    802dd2 <__udivdi3+0x32>
  802e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  802ea0:	b9 01 00 00 00       	mov    $0x1,%ecx
  802ea5:	31 f6                	xor    %esi,%esi
  802ea7:	e9 26 ff ff ff       	jmp    802dd2 <__udivdi3+0x32>
  802eac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802eaf:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  802eb3:	d3 e0                	shl    %cl,%eax
  802eb5:	39 c6                	cmp    %eax,%esi
  802eb7:	76 94                	jbe    802e4d <__udivdi3+0xad>
  802eb9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802ebc:	31 f6                	xor    %esi,%esi
  802ebe:	83 e9 01             	sub    $0x1,%ecx
  802ec1:	e9 0c ff ff ff       	jmp    802dd2 <__udivdi3+0x32>
	...

00802ed0 <__umoddi3>:
  802ed0:	55                   	push   %ebp
  802ed1:	89 e5                	mov    %esp,%ebp
  802ed3:	57                   	push   %edi
  802ed4:	56                   	push   %esi
  802ed5:	83 ec 30             	sub    $0x30,%esp
  802ed8:	8b 45 10             	mov    0x10(%ebp),%eax
  802edb:	8b 55 14             	mov    0x14(%ebp),%edx
  802ede:	8b 75 08             	mov    0x8(%ebp),%esi
  802ee1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802ee4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802ee7:	89 c1                	mov    %eax,%ecx
  802ee9:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802eec:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802eef:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  802ef6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  802efd:	89 fa                	mov    %edi,%edx
  802eff:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  802f02:	85 c0                	test   %eax,%eax
  802f04:	89 75 f0             	mov    %esi,-0x10(%ebp)
  802f07:	89 7d e0             	mov    %edi,-0x20(%ebp)
  802f0a:	75 14                	jne    802f20 <__umoddi3+0x50>
  802f0c:	39 f9                	cmp    %edi,%ecx
  802f0e:	76 60                	jbe    802f70 <__umoddi3+0xa0>
  802f10:	89 f0                	mov    %esi,%eax
  802f12:	f7 f1                	div    %ecx
  802f14:	89 55 d0             	mov    %edx,-0x30(%ebp)
  802f17:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  802f1e:	eb 10                	jmp    802f30 <__umoddi3+0x60>
  802f20:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802f23:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  802f26:	76 18                	jbe    802f40 <__umoddi3+0x70>
  802f28:	89 75 d0             	mov    %esi,-0x30(%ebp)
  802f2b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  802f2e:	66 90                	xchg   %ax,%ax
  802f30:	8b 45 d0             	mov    -0x30(%ebp),%eax
  802f33:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802f36:	83 c4 30             	add    $0x30,%esp
  802f39:	5e                   	pop    %esi
  802f3a:	5f                   	pop    %edi
  802f3b:	5d                   	pop    %ebp
  802f3c:	c3                   	ret    
  802f3d:	8d 76 00             	lea    0x0(%esi),%esi
  802f40:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
  802f44:	83 f0 1f             	xor    $0x1f,%eax
  802f47:	89 45 d8             	mov    %eax,-0x28(%ebp)
  802f4a:	75 46                	jne    802f92 <__umoddi3+0xc2>
  802f4c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802f4f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  802f52:	0f 87 c9 00 00 00    	ja     803021 <__umoddi3+0x151>
  802f58:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  802f5b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  802f5e:	0f 83 bd 00 00 00    	jae    803021 <__umoddi3+0x151>
  802f64:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802f67:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  802f6a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  802f6d:	eb c1                	jmp    802f30 <__umoddi3+0x60>
  802f6f:	90                   	nop    
  802f70:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802f73:	85 c0                	test   %eax,%eax
  802f75:	75 0c                	jne    802f83 <__umoddi3+0xb3>
  802f77:	b8 01 00 00 00       	mov    $0x1,%eax
  802f7c:	31 d2                	xor    %edx,%edx
  802f7e:	f7 75 ec             	divl   -0x14(%ebp)
  802f81:	89 c1                	mov    %eax,%ecx
  802f83:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802f86:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802f89:	f7 f1                	div    %ecx
  802f8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802f8e:	f7 f1                	div    %ecx
  802f90:	eb 82                	jmp    802f14 <__umoddi3+0x44>
  802f92:	b8 20 00 00 00       	mov    $0x20,%eax
  802f97:	8b 55 ec             	mov    -0x14(%ebp),%edx
  802f9a:	2b 45 d8             	sub    -0x28(%ebp),%eax
  802f9d:	8b 75 ec             	mov    -0x14(%ebp),%esi
  802fa0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802fa3:	89 c1                	mov    %eax,%ecx
  802fa5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802fa8:	d3 ea                	shr    %cl,%edx
  802faa:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802fad:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  802fb1:	d3 e0                	shl    %cl,%eax
  802fb3:	09 c2                	or     %eax,%edx
  802fb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802fb8:	d3 e6                	shl    %cl,%esi
  802fba:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  802fbe:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802fc1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802fc4:	d3 e8                	shr    %cl,%eax
  802fc6:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  802fca:	d3 e2                	shl    %cl,%edx
  802fcc:	09 d0                	or     %edx,%eax
  802fce:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802fd1:	d3 e7                	shl    %cl,%edi
  802fd3:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  802fd7:	d3 ea                	shr    %cl,%edx
  802fd9:	f7 75 f4             	divl   -0xc(%ebp)
  802fdc:	89 55 cc             	mov    %edx,-0x34(%ebp)
  802fdf:	f7 e6                	mul    %esi
  802fe1:	39 55 cc             	cmp    %edx,-0x34(%ebp)
  802fe4:	72 53                	jb     803039 <__umoddi3+0x169>
  802fe6:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  802fe9:	74 4a                	je     803035 <__umoddi3+0x165>
  802feb:	90                   	nop    
  802fec:	8d 74 26 00          	lea    0x0(%esi),%esi
  802ff0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  802ff3:	29 c7                	sub    %eax,%edi
  802ff5:	19 d1                	sbb    %edx,%ecx
  802ff7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  802ffa:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  802ffe:	89 fa                	mov    %edi,%edx
  803000:	8b 45 cc             	mov    -0x34(%ebp),%eax
  803003:	d3 ea                	shr    %cl,%edx
  803005:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  803009:	d3 e0                	shl    %cl,%eax
  80300b:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  80300f:	09 c2                	or     %eax,%edx
  803011:	8b 45 cc             	mov    -0x34(%ebp),%eax
  803014:	89 55 d0             	mov    %edx,-0x30(%ebp)
  803017:	d3 e8                	shr    %cl,%eax
  803019:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80301c:	e9 0f ff ff ff       	jmp    802f30 <__umoddi3+0x60>
  803021:	8b 55 e0             	mov    -0x20(%ebp),%edx
  803024:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803027:	2b 45 ec             	sub    -0x14(%ebp),%eax
  80302a:	1b 55 e8             	sbb    -0x18(%ebp),%edx
  80302d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  803030:	e9 2f ff ff ff       	jmp    802f64 <__umoddi3+0x94>
  803035:	39 f8                	cmp    %edi,%eax
  803037:	76 b7                	jbe    802ff0 <__umoddi3+0x120>
  803039:	29 f0                	sub    %esi,%eax
  80303b:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  80303e:	eb b0                	jmp    802ff0 <__umoddi3+0x120>
