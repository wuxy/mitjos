
obj/user/testfile:     file format elf32-i386

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
  80002c:	e8 7f 05 00 00       	call   8005b0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;

	strcpy(fsipcbuf.open.req_path, path);
  80003d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800041:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  800048:	e8 14 0d 00 00       	call   800d61 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80004d:	89 1d 00 34 80 00    	mov    %ebx,0x803400

	ipc_send(envs[1].env_id, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800053:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  800058:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80005f:	00 
  800060:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  800067:	00 
  800068:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80006f:	00 
  800070:	89 04 24             	mov    %eax,(%esp)
  800073:	e8 48 15 00 00       	call   8015c0 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800078:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80007f:	00 
  800080:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  800087:	cc 
  800088:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80008f:	e8 e0 15 00 00       	call   801674 <ipc_recv>
}
  800094:	83 c4 14             	add    $0x14,%esp
  800097:	5b                   	pop    %ebx
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <umain>:

void
umain(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	53                   	push   %ebx
  80009e:	81 ec b4 02 00 00    	sub    $0x2b4,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8000a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000a9:	b8 c0 27 80 00       	mov    $0x8027c0,%eax
  8000ae:	e8 81 ff ff ff       	call   800034 <xopen>
  8000b3:	85 c0                	test   %eax,%eax
  8000b5:	79 25                	jns    8000dc <umain+0x42>
  8000b7:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000ba:	74 3c                	je     8000f8 <umain+0x5e>
		panic("serve_open /not-found: %e", r);
  8000bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c0:	c7 44 24 08 cb 27 80 	movl   $0x8027cb,0x8(%esp)
  8000c7:	00 
  8000c8:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8000cf:	00 
  8000d0:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  8000d7:	e8 4c 05 00 00       	call   800628 <_panic>
	else if (r >= 0)
		panic("serve_open /not-found succeeded!");
  8000dc:	c7 44 24 08 24 29 80 	movl   $0x802924,0x8(%esp)
  8000e3:	00 
  8000e4:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8000eb:	00 
  8000ec:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  8000f3:	e8 30 05 00 00       	call   800628 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000fd:	b8 f5 27 80 00       	mov    $0x8027f5,%eax
  800102:	e8 2d ff ff ff       	call   800034 <xopen>
  800107:	85 c0                	test   %eax,%eax
  800109:	79 20                	jns    80012b <umain+0x91>
		panic("serve_open /newmotd: %e", r);
  80010b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80010f:	c7 44 24 08 fe 27 80 	movl   $0x8027fe,0x8(%esp)
  800116:	00 
  800117:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80011e:	00 
  80011f:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  800126:	e8 fd 04 00 00       	call   800628 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  80012b:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  800132:	75 12                	jne    800146 <umain+0xac>
  800134:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  80013b:	75 09                	jne    800146 <umain+0xac>
  80013d:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  800144:	74 1c                	je     800162 <umain+0xc8>
		panic("serve_open did not fill struct Fd correctly\n");
  800146:	c7 44 24 08 48 29 80 	movl   $0x802948,0x8(%esp)
  80014d:	00 
  80014e:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800155:	00 
  800156:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  80015d:	e8 c6 04 00 00       	call   800628 <_panic>
	cprintf("serve_open is good\n");
  800162:	c7 04 24 16 28 80 00 	movl   $0x802816,(%esp)
  800169:	e8 87 05 00 00       	call   8006f5 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  80016e:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
  800174:	89 44 24 04          	mov    %eax,0x4(%esp)
  800178:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80017f:	ff 15 1c 60 80 00    	call   *0x80601c
  800185:	85 c0                	test   %eax,%eax
  800187:	79 20                	jns    8001a9 <umain+0x10f>
		panic("file_stat: %e", r);
  800189:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018d:	c7 44 24 08 2a 28 80 	movl   $0x80282a,0x8(%esp)
  800194:	00 
  800195:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  80019c:	00 
  80019d:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  8001a4:	e8 7f 04 00 00       	call   800628 <_panic>
	if (strlen(msg) != st.st_size)
  8001a9:	a1 00 60 80 00       	mov    0x806000,%eax
  8001ae:	89 04 24             	mov    %eax,(%esp)
  8001b1:	e8 5a 0b 00 00       	call   800d10 <strlen>
  8001b6:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001b9:	74 34                	je     8001ef <umain+0x155>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  8001bb:	a1 00 60 80 00       	mov    0x806000,%eax
  8001c0:	89 04 24             	mov    %eax,(%esp)
  8001c3:	e8 48 0b 00 00       	call   800d10 <strlen>
  8001c8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d3:	c7 44 24 08 78 29 80 	movl   $0x802978,0x8(%esp)
  8001da:	00 
  8001db:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8001e2:	00 
  8001e3:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  8001ea:	e8 39 04 00 00       	call   800628 <_panic>
	cprintf("file_stat is good\n");
  8001ef:	c7 04 24 38 28 80 00 	movl   $0x802838,(%esp)
  8001f6:	e8 fa 04 00 00       	call   8006f5 <cprintf>

	memset(buf, 0, sizeof buf);
  8001fb:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800202:	00 
  800203:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80020a:	00 
  80020b:	8d 9d 60 fd ff ff    	lea    -0x2a0(%ebp),%ebx
  800211:	89 1c 24             	mov    %ebx,(%esp)
  800214:	e8 f5 0c 00 00       	call   800f0e <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800219:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800220:	00 
  800221:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800225:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80022c:	ff 15 10 60 80 00    	call   *0x806010
  800232:	85 c0                	test   %eax,%eax
  800234:	79 20                	jns    800256 <umain+0x1bc>
		panic("file_read: %e", r);
  800236:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80023a:	c7 44 24 08 4b 28 80 	movl   $0x80284b,0x8(%esp)
  800241:	00 
  800242:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  800249:	00 
  80024a:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  800251:	e8 d2 03 00 00       	call   800628 <_panic>
	if (strcmp(buf, msg) != 0)
  800256:	a1 00 60 80 00       	mov    0x806000,%eax
  80025b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025f:	8d 85 60 fd ff ff    	lea    -0x2a0(%ebp),%eax
  800265:	89 04 24             	mov    %eax,(%esp)
  800268:	e8 d4 0b 00 00       	call   800e41 <strcmp>
  80026d:	85 c0                	test   %eax,%eax
  80026f:	74 1c                	je     80028d <umain+0x1f3>
		panic("file_read returned wrong data");
  800271:	c7 44 24 08 59 28 80 	movl   $0x802859,0x8(%esp)
  800278:	00 
  800279:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  800280:	00 
  800281:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  800288:	e8 9b 03 00 00       	call   800628 <_panic>
	cprintf("file_read is good\n");
  80028d:	c7 04 24 77 28 80 00 	movl   $0x802877,(%esp)
  800294:	e8 5c 04 00 00       	call   8006f5 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800299:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8002a0:	ff 15 18 60 80 00    	call   *0x806018
  8002a6:	85 c0                	test   %eax,%eax
  8002a8:	79 20                	jns    8002ca <umain+0x230>
		panic("file_close: %e", r);
  8002aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ae:	c7 44 24 08 8a 28 80 	movl   $0x80288a,0x8(%esp)
  8002b5:	00 
  8002b6:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  8002bd:	00 
  8002be:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  8002c5:	e8 5e 03 00 00       	call   800628 <_panic>
	cprintf("file_close is good\n");
  8002ca:	c7 04 24 99 28 80 00 	movl   $0x802899,(%esp)
  8002d1:	e8 1f 04 00 00       	call   8006f5 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  8002d6:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  8002db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8002de:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  8002e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8002e6:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  8002eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8002ee:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  8002f3:	89 45 f8             	mov    %eax,-0x8(%ebp)
	sys_page_unmap(0, FVA);
  8002f6:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  8002fd:	cc 
  8002fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800305:	e8 d4 10 00 00       	call   8013de <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80030a:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800311:	00 
  800312:	8d 85 60 fd ff ff    	lea    -0x2a0(%ebp),%eax
  800318:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80031f:	89 04 24             	mov    %eax,(%esp)
  800322:	ff 15 10 60 80 00    	call   *0x806010
  800328:	83 f8 fd             	cmp    $0xfffffffd,%eax
  80032b:	74 20                	je     80034d <umain+0x2b3>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  80032d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800331:	c7 44 24 08 a0 29 80 	movl   $0x8029a0,0x8(%esp)
  800338:	00 
  800339:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  800340:	00 
  800341:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  800348:	e8 db 02 00 00       	call   800628 <_panic>
	cprintf("stale fileid is good\n");
  80034d:	c7 04 24 ad 28 80 00 	movl   $0x8028ad,(%esp)
  800354:	e8 9c 03 00 00       	call   8006f5 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  800359:	ba 02 01 00 00       	mov    $0x102,%edx
  80035e:	b8 c3 28 80 00       	mov    $0x8028c3,%eax
  800363:	e8 cc fc ff ff       	call   800034 <xopen>
  800368:	85 c0                	test   %eax,%eax
  80036a:	79 20                	jns    80038c <umain+0x2f2>
		panic("serve_open /new-file: %e", r);
  80036c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800370:	c7 44 24 08 cd 28 80 	movl   $0x8028cd,0x8(%esp)
  800377:	00 
  800378:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80037f:	00 
  800380:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  800387:	e8 9c 02 00 00       	call   800628 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  80038c:	8b 1d 14 60 80 00    	mov    0x806014,%ebx
  800392:	a1 00 60 80 00       	mov    0x806000,%eax
  800397:	89 04 24             	mov    %eax,(%esp)
  80039a:	e8 71 09 00 00       	call   800d10 <strlen>
  80039f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a3:	a1 00 60 80 00       	mov    0x806000,%eax
  8003a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ac:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8003b3:	ff d3                	call   *%ebx
  8003b5:	89 c3                	mov    %eax,%ebx
  8003b7:	a1 00 60 80 00       	mov    0x806000,%eax
  8003bc:	89 04 24             	mov    %eax,(%esp)
  8003bf:	e8 4c 09 00 00       	call   800d10 <strlen>
  8003c4:	39 c3                	cmp    %eax,%ebx
  8003c6:	74 20                	je     8003e8 <umain+0x34e>
		panic("file_write: %e", r);
  8003c8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003cc:	c7 44 24 08 e6 28 80 	movl   $0x8028e6,0x8(%esp)
  8003d3:	00 
  8003d4:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  8003db:	00 
  8003dc:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  8003e3:	e8 40 02 00 00       	call   800628 <_panic>
	cprintf("file_write is good\n");
  8003e8:	c7 04 24 f5 28 80 00 	movl   $0x8028f5,(%esp)
  8003ef:	e8 01 03 00 00       	call   8006f5 <cprintf>

	FVA->fd_offset = 0;
  8003f4:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  8003fb:	00 00 00 
	memset(buf, 0, sizeof buf);
  8003fe:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800405:	00 
  800406:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80040d:	00 
  80040e:	8d 9d 60 fd ff ff    	lea    -0x2a0(%ebp),%ebx
  800414:	89 1c 24             	mov    %ebx,(%esp)
  800417:	e8 f2 0a 00 00       	call   800f0e <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  80041c:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800423:	00 
  800424:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800428:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80042f:	ff 15 10 60 80 00    	call   *0x806010
  800435:	89 c3                	mov    %eax,%ebx
  800437:	85 c0                	test   %eax,%eax
  800439:	79 20                	jns    80045b <umain+0x3c1>
		panic("file_read after file_write: %e", r);
  80043b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80043f:	c7 44 24 08 d8 29 80 	movl   $0x8029d8,0x8(%esp)
  800446:	00 
  800447:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  80044e:	00 
  80044f:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  800456:	e8 cd 01 00 00       	call   800628 <_panic>
	if (r != strlen(msg))
  80045b:	a1 00 60 80 00       	mov    0x806000,%eax
  800460:	89 04 24             	mov    %eax,(%esp)
  800463:	e8 a8 08 00 00       	call   800d10 <strlen>
  800468:	39 c3                	cmp    %eax,%ebx
  80046a:	74 20                	je     80048c <umain+0x3f2>
		panic("file_read after file_write returned wrong length: %d", r);
  80046c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800470:	c7 44 24 08 f8 29 80 	movl   $0x8029f8,0x8(%esp)
  800477:	00 
  800478:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  80047f:	00 
  800480:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  800487:	e8 9c 01 00 00       	call   800628 <_panic>
	if (strcmp(buf, msg) != 0)
  80048c:	a1 00 60 80 00       	mov    0x806000,%eax
  800491:	89 44 24 04          	mov    %eax,0x4(%esp)
  800495:	8d 85 60 fd ff ff    	lea    -0x2a0(%ebp),%eax
  80049b:	89 04 24             	mov    %eax,(%esp)
  80049e:	e8 9e 09 00 00       	call   800e41 <strcmp>
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	74 1c                	je     8004c3 <umain+0x429>
		panic("file_read after file_write returned wrong data");
  8004a7:	c7 44 24 08 30 2a 80 	movl   $0x802a30,0x8(%esp)
  8004ae:	00 
  8004af:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8004b6:	00 
  8004b7:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  8004be:	e8 65 01 00 00       	call   800628 <_panic>
	cprintf("file_read after file_write is good\n");
  8004c3:	c7 04 24 60 2a 80 00 	movl   $0x802a60,(%esp)
  8004ca:	e8 26 02 00 00       	call   8006f5 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8004cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004d6:	00 
  8004d7:	c7 04 24 c0 27 80 00 	movl   $0x8027c0,(%esp)
  8004de:	e8 7c 1a 00 00       	call   801f5f <open>
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	79 25                	jns    80050c <umain+0x472>
  8004e7:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8004ea:	74 3c                	je     800528 <umain+0x48e>
		panic("open /not-found: %e", r);
  8004ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f0:	c7 44 24 08 d1 27 80 	movl   $0x8027d1,0x8(%esp)
  8004f7:	00 
  8004f8:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8004ff:	00 
  800500:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  800507:	e8 1c 01 00 00       	call   800628 <_panic>
	else if (r >= 0)
		panic("open /not-found succeeded!");
  80050c:	c7 44 24 08 09 29 80 	movl   $0x802909,0x8(%esp)
  800513:	00 
  800514:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  80051b:	00 
  80051c:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  800523:	e8 00 01 00 00       	call   800628 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  800528:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80052f:	00 
  800530:	c7 04 24 f5 27 80 00 	movl   $0x8027f5,(%esp)
  800537:	e8 23 1a 00 00       	call   801f5f <open>
  80053c:	85 c0                	test   %eax,%eax
  80053e:	79 20                	jns    800560 <umain+0x4c6>
		panic("open /newmotd: %e", r);
  800540:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800544:	c7 44 24 08 04 28 80 	movl   $0x802804,0x8(%esp)
  80054b:	00 
  80054c:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  800553:	00 
  800554:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  80055b:	e8 c8 00 00 00       	call   800628 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800560:	c1 e0 0c             	shl    $0xc,%eax
  800563:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800569:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  800570:	75 0c                	jne    80057e <umain+0x4e4>
  800572:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
  800576:	75 06                	jne    80057e <umain+0x4e4>
  800578:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  80057c:	74 1c                	je     80059a <umain+0x500>
		panic("open did not fill struct Fd correctly\n");
  80057e:	c7 44 24 08 84 2a 80 	movl   $0x802a84,0x8(%esp)
  800585:	00 
  800586:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  80058d:	00 
  80058e:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  800595:	e8 8e 00 00 00       	call   800628 <_panic>
	cprintf("open is good\n");
  80059a:	c7 04 24 1c 28 80 00 	movl   $0x80281c,(%esp)
  8005a1:	e8 4f 01 00 00       	call   8006f5 <cprintf>
}
  8005a6:	81 c4 b4 02 00 00    	add    $0x2b4,%esp
  8005ac:	5b                   	pop    %ebx
  8005ad:	5d                   	pop    %ebp
  8005ae:	c3                   	ret    
	...

008005b0 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8005b0:	55                   	push   %ebp
  8005b1:	89 e5                	mov    %esp,%ebp
  8005b3:	83 ec 18             	sub    $0x18,%esp
  8005b6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8005b9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8005bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8005bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  8005c2:	c7 05 40 60 80 00 00 	movl   $0x0,0x806040
  8005c9:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  8005cc:	e8 5c 0f 00 00       	call   80152d <sys_getenvid>
  8005d1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005d6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005de:	a3 40 60 80 00       	mov    %eax,0x806040
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005e3:	85 f6                	test   %esi,%esi
  8005e5:	7e 07                	jle    8005ee <libmain+0x3e>
		binaryname = argv[0];
  8005e7:	8b 03                	mov    (%ebx),%eax
  8005e9:	a3 04 60 80 00       	mov    %eax,0x806004

	// call user main routine
	umain(argc, argv);
  8005ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f2:	89 34 24             	mov    %esi,(%esp)
  8005f5:	e8 a0 fa ff ff       	call   80009a <umain>

	// exit gracefully
	exit();
  8005fa:	e8 0d 00 00 00       	call   80060c <exit>
}
  8005ff:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800602:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800605:	89 ec                	mov    %ebp,%esp
  800607:	5d                   	pop    %ebp
  800608:	c3                   	ret    
  800609:	00 00                	add    %al,(%eax)
	...

0080060c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80060c:	55                   	push   %ebp
  80060d:	89 e5                	mov    %esp,%ebp
  80060f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800612:	e8 39 17 00 00       	call   801d50 <close_all>
	sys_env_destroy(0);
  800617:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80061e:	e8 3e 0f 00 00       	call   801561 <sys_env_destroy>
}
  800623:	c9                   	leave  
  800624:	c3                   	ret    
  800625:	00 00                	add    %al,(%eax)
	...

00800628 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800628:	55                   	push   %ebp
  800629:	89 e5                	mov    %esp,%ebp
  80062b:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  80062e:	8d 45 14             	lea    0x14(%ebp),%eax
  800631:	89 45 fc             	mov    %eax,-0x4(%ebp)

	// Print the panic message
	if (argv0)
  800634:	a1 44 60 80 00       	mov    0x806044,%eax
  800639:	85 c0                	test   %eax,%eax
  80063b:	74 10                	je     80064d <_panic+0x25>
		cprintf("%s: ", argv0);
  80063d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800641:	c7 04 24 e9 2a 80 00 	movl   $0x802ae9,(%esp)
  800648:	e8 a8 00 00 00       	call   8006f5 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80064d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800650:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800654:	8b 45 08             	mov    0x8(%ebp),%eax
  800657:	89 44 24 08          	mov    %eax,0x8(%esp)
  80065b:	a1 04 60 80 00       	mov    0x806004,%eax
  800660:	89 44 24 04          	mov    %eax,0x4(%esp)
  800664:	c7 04 24 ee 2a 80 00 	movl   $0x802aee,(%esp)
  80066b:	e8 85 00 00 00       	call   8006f5 <cprintf>
	vcprintf(fmt, ap);
  800670:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800673:	89 44 24 04          	mov    %eax,0x4(%esp)
  800677:	8b 45 10             	mov    0x10(%ebp),%eax
  80067a:	89 04 24             	mov    %eax,(%esp)
  80067d:	e8 12 00 00 00       	call   800694 <vcprintf>
	cprintf("\n");
  800682:	c7 04 24 6c 2e 80 00 	movl   $0x802e6c,(%esp)
  800689:	e8 67 00 00 00       	call   8006f5 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80068e:	cc                   	int3   
  80068f:	eb fd                	jmp    80068e <_panic+0x66>
  800691:	00 00                	add    %al,(%eax)
	...

00800694 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800694:	55                   	push   %ebp
  800695:	89 e5                	mov    %esp,%ebp
  800697:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80069d:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  8006a4:	00 00 00 
	b.cnt = 0;
  8006a7:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  8006ae:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006bf:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c9:	c7 04 24 12 07 80 00 	movl   $0x800712,(%esp)
  8006d0:	e8 d0 01 00 00       	call   8008a5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006d5:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
  8006db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006df:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8006e5:	89 04 24             	mov    %eax,(%esp)
  8006e8:	e8 db 0a 00 00       	call   8011c8 <sys_cputs>
  8006ed:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  8006f3:	c9                   	leave  
  8006f4:	c3                   	ret    

008006f5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006fb:	8d 45 0c             	lea    0xc(%ebp),%eax
  8006fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800701:	89 44 24 04          	mov    %eax,0x4(%esp)
  800705:	8b 45 08             	mov    0x8(%ebp),%eax
  800708:	89 04 24             	mov    %eax,(%esp)
  80070b:	e8 84 ff ff ff       	call   800694 <vcprintf>
	va_end(ap);

	return cnt;
}
  800710:	c9                   	leave  
  800711:	c3                   	ret    

00800712 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	53                   	push   %ebx
  800716:	83 ec 14             	sub    $0x14,%esp
  800719:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80071c:	8b 03                	mov    (%ebx),%eax
  80071e:	8b 55 08             	mov    0x8(%ebp),%edx
  800721:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800725:	83 c0 01             	add    $0x1,%eax
  800728:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80072a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80072f:	75 19                	jne    80074a <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800731:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800738:	00 
  800739:	8d 43 08             	lea    0x8(%ebx),%eax
  80073c:	89 04 24             	mov    %eax,(%esp)
  80073f:	e8 84 0a 00 00       	call   8011c8 <sys_cputs>
		b->idx = 0;
  800744:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80074a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80074e:	83 c4 14             	add    $0x14,%esp
  800751:	5b                   	pop    %ebx
  800752:	5d                   	pop    %ebp
  800753:	c3                   	ret    
	...

00800760 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	57                   	push   %edi
  800764:	56                   	push   %esi
  800765:	53                   	push   %ebx
  800766:	83 ec 3c             	sub    $0x3c,%esp
  800769:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80076c:	89 d7                	mov    %edx,%edi
  80076e:	8b 45 08             	mov    0x8(%ebp),%eax
  800771:	8b 55 0c             	mov    0xc(%ebp),%edx
  800774:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800777:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80077a:	8b 55 10             	mov    0x10(%ebp),%edx
  80077d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800780:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800783:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  80078a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80078d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  800790:	72 14                	jb     8007a6 <printnum+0x46>
  800792:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800795:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800798:	76 0c                	jbe    8007a6 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80079a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80079d:	83 eb 01             	sub    $0x1,%ebx
  8007a0:	85 db                	test   %ebx,%ebx
  8007a2:	7f 57                	jg     8007fb <printnum+0x9b>
  8007a4:	eb 64                	jmp    80080a <printnum+0xaa>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8007a6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8007aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ad:	83 e8 01             	sub    $0x1,%eax
  8007b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007b4:	89 54 24 08          	mov    %edx,0x8(%esp)
  8007b8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8007bc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8007c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8007c3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8007c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ca:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007d1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007d4:	89 04 24             	mov    %eax,(%esp)
  8007d7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007db:	e8 30 1d 00 00       	call   802510 <__udivdi3>
  8007e0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007e4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8007e8:	89 04 24             	mov    %eax,(%esp)
  8007eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ef:	89 fa                	mov    %edi,%edx
  8007f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007f4:	e8 67 ff ff ff       	call   800760 <printnum>
  8007f9:	eb 0f                	jmp    80080a <printnum+0xaa>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ff:	89 34 24             	mov    %esi,(%esp)
  800802:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800805:	83 eb 01             	sub    $0x1,%ebx
  800808:	75 f1                	jne    8007fb <printnum+0x9b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80080a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80080e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800812:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800815:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800818:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800820:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800823:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800826:	89 04 24             	mov    %eax,(%esp)
  800829:	89 54 24 04          	mov    %edx,0x4(%esp)
  80082d:	e8 0e 1e 00 00       	call   802640 <__umoddi3>
  800832:	89 74 24 04          	mov    %esi,0x4(%esp)
  800836:	0f be 80 0a 2b 80 00 	movsbl 0x802b0a(%eax),%eax
  80083d:	89 04 24             	mov    %eax,(%esp)
  800840:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800843:	83 c4 3c             	add    $0x3c,%esp
  800846:	5b                   	pop    %ebx
  800847:	5e                   	pop    %esi
  800848:	5f                   	pop    %edi
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800850:	83 fa 01             	cmp    $0x1,%edx
  800853:	7e 0e                	jle    800863 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800855:	8b 10                	mov    (%eax),%edx
  800857:	8d 42 08             	lea    0x8(%edx),%eax
  80085a:	89 01                	mov    %eax,(%ecx)
  80085c:	8b 02                	mov    (%edx),%eax
  80085e:	8b 52 04             	mov    0x4(%edx),%edx
  800861:	eb 22                	jmp    800885 <getuint+0x3a>
	else if (lflag)
  800863:	85 d2                	test   %edx,%edx
  800865:	74 10                	je     800877 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800867:	8b 10                	mov    (%eax),%edx
  800869:	8d 42 04             	lea    0x4(%edx),%eax
  80086c:	89 01                	mov    %eax,(%ecx)
  80086e:	8b 02                	mov    (%edx),%eax
  800870:	ba 00 00 00 00       	mov    $0x0,%edx
  800875:	eb 0e                	jmp    800885 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800877:	8b 10                	mov    (%eax),%edx
  800879:	8d 42 04             	lea    0x4(%edx),%eax
  80087c:	89 01                	mov    %eax,(%ecx)
  80087e:	8b 02                	mov    (%edx),%eax
  800880:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  80088d:	83 42 08 01          	addl   $0x1,0x8(%edx)
	if (b->buf < b->ebuf)
  800891:	8b 02                	mov    (%edx),%eax
  800893:	3b 42 04             	cmp    0x4(%edx),%eax
  800896:	73 0b                	jae    8008a3 <sprintputch+0x1c>
		*b->buf++ = ch;
  800898:	0f b6 4d 08          	movzbl 0x8(%ebp),%ecx
  80089c:	88 08                	mov    %cl,(%eax)
  80089e:	83 c0 01             	add    $0x1,%eax
  8008a1:	89 02                	mov    %eax,(%edx)
}
  8008a3:	5d                   	pop    %ebp
  8008a4:	c3                   	ret    

008008a5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	57                   	push   %edi
  8008a9:	56                   	push   %esi
  8008aa:	53                   	push   %ebx
  8008ab:	83 ec 3c             	sub    $0x3c,%esp
  8008ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8008b1:	eb 18                	jmp    8008cb <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008b3:	84 c0                	test   %al,%al
  8008b5:	0f 84 9f 03 00 00    	je     800c5a <vprintfmt+0x3b5>
				return;
			putch(ch, putdat);
  8008bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c2:	0f b6 c0             	movzbl %al,%eax
  8008c5:	89 04 24             	mov    %eax,(%esp)
  8008c8:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008cb:	0f b6 03             	movzbl (%ebx),%eax
  8008ce:	83 c3 01             	add    $0x1,%ebx
  8008d1:	3c 25                	cmp    $0x25,%al
  8008d3:	75 de                	jne    8008b3 <vprintfmt+0xe>
  8008d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008da:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
  8008e1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8008e6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8008ed:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
  8008f1:	eb 07                	jmp    8008fa <vprintfmt+0x55>
  8008f3:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fa:	0f b6 13             	movzbl (%ebx),%edx
  8008fd:	83 c3 01             	add    $0x1,%ebx
  800900:	8d 42 dd             	lea    -0x23(%edx),%eax
  800903:	3c 55                	cmp    $0x55,%al
  800905:	0f 87 22 03 00 00    	ja     800c2d <vprintfmt+0x388>
  80090b:	0f b6 c0             	movzbl %al,%eax
  80090e:	ff 24 85 40 2c 80 00 	jmp    *0x802c40(,%eax,4)
  800915:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
  800919:	eb df                	jmp    8008fa <vprintfmt+0x55>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80091b:	0f b6 c2             	movzbl %dl,%eax
  80091e:	8d 78 d0             	lea    -0x30(%eax),%edi
				ch = *fmt;
  800921:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800924:	8d 42 d0             	lea    -0x30(%edx),%eax
  800927:	83 f8 09             	cmp    $0x9,%eax
  80092a:	76 08                	jbe    800934 <vprintfmt+0x8f>
  80092c:	eb 39                	jmp    800967 <vprintfmt+0xc2>
  80092e:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
  800932:	eb c6                	jmp    8008fa <vprintfmt+0x55>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800934:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800937:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  80093a:	8d 7c 42 d0          	lea    -0x30(%edx,%eax,2),%edi
				ch = *fmt;
  80093e:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800941:	8d 42 d0             	lea    -0x30(%edx),%eax
  800944:	83 f8 09             	cmp    $0x9,%eax
  800947:	77 1e                	ja     800967 <vprintfmt+0xc2>
  800949:	eb e9                	jmp    800934 <vprintfmt+0x8f>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80094b:	8b 55 14             	mov    0x14(%ebp),%edx
  80094e:	8d 42 04             	lea    0x4(%edx),%eax
  800951:	89 45 14             	mov    %eax,0x14(%ebp)
  800954:	8b 3a                	mov    (%edx),%edi
  800956:	eb 0f                	jmp    800967 <vprintfmt+0xc2>
			goto process_precision;

		case '.':
			if (width < 0)
  800958:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80095c:	79 9c                	jns    8008fa <vprintfmt+0x55>
  80095e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800965:	eb 93                	jmp    8008fa <vprintfmt+0x55>
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800967:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80096b:	90                   	nop    
  80096c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800970:	79 88                	jns    8008fa <vprintfmt+0x55>
  800972:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800975:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80097a:	e9 7b ff ff ff       	jmp    8008fa <vprintfmt+0x55>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80097f:	83 c1 01             	add    $0x1,%ecx
  800982:	e9 73 ff ff ff       	jmp    8008fa <vprintfmt+0x55>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800987:	8b 45 14             	mov    0x14(%ebp),%eax
  80098a:	8d 50 04             	lea    0x4(%eax),%edx
  80098d:	89 55 14             	mov    %edx,0x14(%ebp)
  800990:	8b 55 0c             	mov    0xc(%ebp),%edx
  800993:	89 54 24 04          	mov    %edx,0x4(%esp)
  800997:	8b 00                	mov    (%eax),%eax
  800999:	89 04 24             	mov    %eax,(%esp)
  80099c:	ff 55 08             	call   *0x8(%ebp)
  80099f:	e9 27 ff ff ff       	jmp    8008cb <vprintfmt+0x26>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009a4:	8b 55 14             	mov    0x14(%ebp),%edx
  8009a7:	8d 42 04             	lea    0x4(%edx),%eax
  8009aa:	89 45 14             	mov    %eax,0x14(%ebp)
  8009ad:	8b 02                	mov    (%edx),%eax
  8009af:	89 c2                	mov    %eax,%edx
  8009b1:	c1 fa 1f             	sar    $0x1f,%edx
  8009b4:	31 d0                	xor    %edx,%eax
  8009b6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8009b8:	83 f8 0f             	cmp    $0xf,%eax
  8009bb:	7f 0b                	jg     8009c8 <vprintfmt+0x123>
  8009bd:	8b 14 85 a0 2d 80 00 	mov    0x802da0(,%eax,4),%edx
  8009c4:	85 d2                	test   %edx,%edx
  8009c6:	75 23                	jne    8009eb <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8009c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009cc:	c7 44 24 08 1b 2b 80 	movl   $0x802b1b,0x8(%esp)
  8009d3:	00 
  8009d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009db:	8b 55 08             	mov    0x8(%ebp),%edx
  8009de:	89 14 24             	mov    %edx,(%esp)
  8009e1:	e8 ff 02 00 00       	call   800ce5 <printfmt>
  8009e6:	e9 e0 fe ff ff       	jmp    8008cb <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8009eb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009ef:	c7 44 24 08 26 2f 80 	movl   $0x802f26,0x8(%esp)
  8009f6:	00 
  8009f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800a01:	89 14 24             	mov    %edx,(%esp)
  800a04:	e8 dc 02 00 00       	call   800ce5 <printfmt>
  800a09:	e9 bd fe ff ff       	jmp    8008cb <vprintfmt+0x26>
  800a0e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800a11:	89 f9                	mov    %edi,%ecx
  800a13:	89 5d ec             	mov    %ebx,-0x14(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a16:	8b 55 14             	mov    0x14(%ebp),%edx
  800a19:	8d 42 04             	lea    0x4(%edx),%eax
  800a1c:	89 45 14             	mov    %eax,0x14(%ebp)
  800a1f:	8b 12                	mov    (%edx),%edx
  800a21:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a24:	85 d2                	test   %edx,%edx
  800a26:	75 07                	jne    800a2f <vprintfmt+0x18a>
  800a28:	c7 45 dc 24 2b 80 00 	movl   $0x802b24,-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800a2f:	85 f6                	test   %esi,%esi
  800a31:	7e 41                	jle    800a74 <vprintfmt+0x1cf>
  800a33:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  800a37:	74 3b                	je     800a74 <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a39:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a3d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a40:	89 04 24             	mov    %eax,(%esp)
  800a43:	e8 e8 02 00 00       	call   800d30 <strnlen>
  800a48:	29 c6                	sub    %eax,%esi
  800a4a:	89 75 f0             	mov    %esi,-0x10(%ebp)
  800a4d:	85 f6                	test   %esi,%esi
  800a4f:	7e 23                	jle    800a74 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800a51:	0f be 55 eb          	movsbl -0x15(%ebp),%edx
  800a55:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800a58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a5f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800a62:	89 14 24             	mov    %edx,(%esp)
  800a65:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a68:	83 ee 01             	sub    $0x1,%esi
  800a6b:	75 eb                	jne    800a58 <vprintfmt+0x1b3>
  800a6d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a74:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800a77:	0f b6 02             	movzbl (%edx),%eax
  800a7a:	0f be d0             	movsbl %al,%edx
  800a7d:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800a80:	84 c0                	test   %al,%al
  800a82:	75 42                	jne    800ac6 <vprintfmt+0x221>
  800a84:	eb 49                	jmp    800acf <vprintfmt+0x22a>
				if (altflag && (ch < ' ' || ch > '~'))
  800a86:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a8a:	74 1b                	je     800aa7 <vprintfmt+0x202>
  800a8c:	8d 42 e0             	lea    -0x20(%edx),%eax
  800a8f:	83 f8 5e             	cmp    $0x5e,%eax
  800a92:	76 13                	jbe    800aa7 <vprintfmt+0x202>
					putch('?', putdat);
  800a94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a97:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a9b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800aa2:	ff 55 08             	call   *0x8(%ebp)
  800aa5:	eb 0d                	jmp    800ab4 <vprintfmt+0x20f>
				else
					putch(ch, putdat);
  800aa7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aaa:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aae:	89 14 24             	mov    %edx,(%esp)
  800ab1:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ab4:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  800ab8:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800abc:	83 c6 01             	add    $0x1,%esi
  800abf:	84 c0                	test   %al,%al
  800ac1:	74 0c                	je     800acf <vprintfmt+0x22a>
  800ac3:	0f be d0             	movsbl %al,%edx
  800ac6:	85 ff                	test   %edi,%edi
  800ac8:	78 bc                	js     800a86 <vprintfmt+0x1e1>
  800aca:	83 ef 01             	sub    $0x1,%edi
  800acd:	79 b7                	jns    800a86 <vprintfmt+0x1e1>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800acf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800ad3:	0f 8e f2 fd ff ff    	jle    8008cb <vprintfmt+0x26>
				putch(' ', putdat);
  800ad9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800adc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ae0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800ae7:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800aea:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  800aee:	75 e9                	jne    800ad9 <vprintfmt+0x234>
  800af0:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800af3:	e9 d3 fd ff ff       	jmp    8008cb <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800af8:	83 f9 01             	cmp    $0x1,%ecx
  800afb:	90                   	nop    
  800afc:	8d 74 26 00          	lea    0x0(%esi),%esi
  800b00:	7e 10                	jle    800b12 <vprintfmt+0x26d>
		return va_arg(*ap, long long);
  800b02:	8b 55 14             	mov    0x14(%ebp),%edx
  800b05:	8d 42 08             	lea    0x8(%edx),%eax
  800b08:	89 45 14             	mov    %eax,0x14(%ebp)
  800b0b:	8b 32                	mov    (%edx),%esi
  800b0d:	8b 7a 04             	mov    0x4(%edx),%edi
  800b10:	eb 2a                	jmp    800b3c <vprintfmt+0x297>
	else if (lflag)
  800b12:	85 c9                	test   %ecx,%ecx
  800b14:	74 14                	je     800b2a <vprintfmt+0x285>
		return va_arg(*ap, long);
  800b16:	8b 45 14             	mov    0x14(%ebp),%eax
  800b19:	8d 50 04             	lea    0x4(%eax),%edx
  800b1c:	89 55 14             	mov    %edx,0x14(%ebp)
  800b1f:	8b 00                	mov    (%eax),%eax
  800b21:	89 c6                	mov    %eax,%esi
  800b23:	89 c7                	mov    %eax,%edi
  800b25:	c1 ff 1f             	sar    $0x1f,%edi
  800b28:	eb 12                	jmp    800b3c <vprintfmt+0x297>
	else
		return va_arg(*ap, int);
  800b2a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2d:	8d 50 04             	lea    0x4(%eax),%edx
  800b30:	89 55 14             	mov    %edx,0x14(%ebp)
  800b33:	8b 00                	mov    (%eax),%eax
  800b35:	89 c6                	mov    %eax,%esi
  800b37:	89 c7                	mov    %eax,%edi
  800b39:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b3c:	89 f2                	mov    %esi,%edx
  800b3e:	89 f9                	mov    %edi,%ecx
  800b40:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
			if ((long long) num < 0) {
  800b47:	85 ff                	test   %edi,%edi
  800b49:	0f 89 9b 00 00 00    	jns    800bea <vprintfmt+0x345>
				putch('-', putdat);
  800b4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b52:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b56:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b5d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800b60:	89 f2                	mov    %esi,%edx
  800b62:	89 f9                	mov    %edi,%ecx
  800b64:	f7 da                	neg    %edx
  800b66:	83 d1 00             	adc    $0x0,%ecx
  800b69:	f7 d9                	neg    %ecx
  800b6b:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  800b72:	eb 76                	jmp    800bea <vprintfmt+0x345>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b74:	89 ca                	mov    %ecx,%edx
  800b76:	8d 45 14             	lea    0x14(%ebp),%eax
  800b79:	e8 cd fc ff ff       	call   80084b <getuint>
  800b7e:	89 d1                	mov    %edx,%ecx
  800b80:	89 c2                	mov    %eax,%edx
  800b82:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  800b89:	eb 5f                	jmp    800bea <vprintfmt+0x345>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap,lflag);
  800b8b:	89 ca                	mov    %ecx,%edx
  800b8d:	8d 45 14             	lea    0x14(%ebp),%eax
  800b90:	e8 b6 fc ff ff       	call   80084b <getuint>
  800b95:	e9 31 fd ff ff       	jmp    8008cb <vprintfmt+0x26>
			base=8;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800b9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b9d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ba1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800ba8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800bab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bae:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800bb9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800bbc:	8b 55 14             	mov    0x14(%ebp),%edx
  800bbf:	8d 42 04             	lea    0x4(%edx),%eax
  800bc2:	89 45 14             	mov    %eax,0x14(%ebp)
  800bc5:	8b 12                	mov    (%edx),%edx
  800bc7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bcc:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  800bd3:	eb 15                	jmp    800bea <vprintfmt+0x345>
			base = 16;
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bd5:	89 ca                	mov    %ecx,%edx
  800bd7:	8d 45 14             	lea    0x14(%ebp),%eax
  800bda:	e8 6c fc ff ff       	call   80084b <getuint>
  800bdf:	89 d1                	mov    %edx,%ecx
  800be1:	89 c2                	mov    %eax,%edx
  800be3:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bea:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800bee:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bf5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bf9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800bfc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c00:	89 14 24             	mov    %edx,(%esp)
  800c03:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0d:	e8 4e fb ff ff       	call   800760 <printnum>
  800c12:	e9 b4 fc ff ff       	jmp    8008cb <vprintfmt+0x26>
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c17:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1a:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c1e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800c25:	ff 55 08             	call   *0x8(%ebp)
  800c28:	e9 9e fc ff ff       	jmp    8008cb <vprintfmt+0x26>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c30:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c34:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800c3b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c3e:	83 eb 01             	sub    $0x1,%ebx
  800c41:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800c45:	0f 84 80 fc ff ff    	je     8008cb <vprintfmt+0x26>
  800c4b:	83 eb 01             	sub    $0x1,%ebx
  800c4e:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800c52:	0f 84 73 fc ff ff    	je     8008cb <vprintfmt+0x26>
  800c58:	eb f1                	jmp    800c4b <vprintfmt+0x3a6>
				/* do nothing */;
			break;
		}
	}
}
  800c5a:	83 c4 3c             	add    $0x3c,%esp
  800c5d:	5b                   	pop    %ebx
  800c5e:	5e                   	pop    %esi
  800c5f:	5f                   	pop    %edi
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    

00800c62 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	83 ec 28             	sub    $0x28,%esp
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800c6e:	85 d2                	test   %edx,%edx
  800c70:	74 04                	je     800c76 <vsnprintf+0x14>
  800c72:	85 c0                	test   %eax,%eax
  800c74:	7f 07                	jg     800c7d <vsnprintf+0x1b>
  800c76:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c7b:	eb 3b                	jmp    800cb8 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c7d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c84:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
  800c88:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800c8b:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c8e:	8b 45 14             	mov    0x14(%ebp),%eax
  800c91:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c95:	8b 45 10             	mov    0x10(%ebp),%eax
  800c98:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca3:	c7 04 24 87 08 80 00 	movl   $0x800887,(%esp)
  800caa:	e8 f6 fb ff ff       	call   8008a5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cb5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800cb8:	c9                   	leave  
  800cb9:	c3                   	ret    

00800cba <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cc0:	8d 45 14             	lea    0x14(%ebp),%eax
  800cc3:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800cc6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cca:	8b 45 10             	mov    0x10(%ebp),%eax
  800ccd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdb:	89 04 24             	mov    %eax,(%esp)
  800cde:	e8 7f ff ff ff       	call   800c62 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ce3:	c9                   	leave  
  800ce4:	c3                   	ret    

00800ce5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800ceb:	8d 45 14             	lea    0x14(%ebp),%eax
  800cee:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800cf1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cf5:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cfc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d03:	8b 45 08             	mov    0x8(%ebp),%eax
  800d06:	89 04 24             	mov    %eax,(%esp)
  800d09:	e8 97 fb ff ff       	call   8008a5 <vprintfmt>
	va_end(ap);
}
  800d0e:	c9                   	leave  
  800d0f:	c3                   	ret    

00800d10 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d16:	b8 00 00 00 00       	mov    $0x0,%eax
  800d1b:	80 3a 00             	cmpb   $0x0,(%edx)
  800d1e:	74 0e                	je     800d2e <strlen+0x1e>
  800d20:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800d25:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d28:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  800d2c:	75 f7                	jne    800d25 <strlen+0x15>
		n++;
	return n;
}
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d36:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d39:	85 d2                	test   %edx,%edx
  800d3b:	74 19                	je     800d56 <strnlen+0x26>
  800d3d:	80 39 00             	cmpb   $0x0,(%ecx)
  800d40:	74 14                	je     800d56 <strnlen+0x26>
  800d42:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800d47:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d4a:	39 d0                	cmp    %edx,%eax
  800d4c:	74 0d                	je     800d5b <strnlen+0x2b>
  800d4e:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800d52:	74 07                	je     800d5b <strnlen+0x2b>
  800d54:	eb f1                	jmp    800d47 <strnlen+0x17>
  800d56:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d5b:	5d                   	pop    %ebp
  800d5c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800d60:	c3                   	ret    

00800d61 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	53                   	push   %ebx
  800d65:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6b:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d6d:	0f b6 01             	movzbl (%ecx),%eax
  800d70:	88 02                	mov    %al,(%edx)
  800d72:	83 c2 01             	add    $0x1,%edx
  800d75:	83 c1 01             	add    $0x1,%ecx
  800d78:	84 c0                	test   %al,%al
  800d7a:	75 f1                	jne    800d6d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d7c:	89 d8                	mov    %ebx,%eax
  800d7e:	5b                   	pop    %ebx
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
  800d87:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d90:	85 f6                	test   %esi,%esi
  800d92:	74 1c                	je     800db0 <strncpy+0x2f>
  800d94:	89 fa                	mov    %edi,%edx
  800d96:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  800d9b:	0f b6 01             	movzbl (%ecx),%eax
  800d9e:	88 02                	mov    %al,(%edx)
  800da0:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800da3:	80 39 01             	cmpb   $0x1,(%ecx)
  800da6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800da9:	83 c3 01             	add    $0x1,%ebx
  800dac:	39 f3                	cmp    %esi,%ebx
  800dae:	75 eb                	jne    800d9b <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800db0:	89 f8                	mov    %edi,%eax
  800db2:	5b                   	pop    %ebx
  800db3:	5e                   	pop    %esi
  800db4:	5f                   	pop    %edi
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    

00800db7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	56                   	push   %esi
  800dbb:	53                   	push   %ebx
  800dbc:	8b 75 08             	mov    0x8(%ebp),%esi
  800dbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc2:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800dc5:	89 f0                	mov    %esi,%eax
  800dc7:	85 d2                	test   %edx,%edx
  800dc9:	74 2c                	je     800df7 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800dcb:	89 d3                	mov    %edx,%ebx
  800dcd:	83 eb 01             	sub    $0x1,%ebx
  800dd0:	74 20                	je     800df2 <strlcpy+0x3b>
  800dd2:	0f b6 11             	movzbl (%ecx),%edx
  800dd5:	84 d2                	test   %dl,%dl
  800dd7:	74 19                	je     800df2 <strlcpy+0x3b>
  800dd9:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800ddb:	88 10                	mov    %dl,(%eax)
  800ddd:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800de0:	83 eb 01             	sub    $0x1,%ebx
  800de3:	74 0f                	je     800df4 <strlcpy+0x3d>
  800de5:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  800de9:	83 c1 01             	add    $0x1,%ecx
  800dec:	84 d2                	test   %dl,%dl
  800dee:	74 04                	je     800df4 <strlcpy+0x3d>
  800df0:	eb e9                	jmp    800ddb <strlcpy+0x24>
  800df2:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800df4:	c6 00 00             	movb   $0x0,(%eax)
  800df7:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800df9:	5b                   	pop    %ebx
  800dfa:	5e                   	pop    %esi
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	56                   	push   %esi
  800e01:	53                   	push   %ebx
  800e02:	8b 75 08             	mov    0x8(%ebp),%esi
  800e05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e08:	8b 55 10             	mov    0x10(%ebp),%edx
    int c;
    char *q = buf;

    if (buf_size <= 0)
  800e0b:	85 c0                	test   %eax,%eax
  800e0d:	7e 2e                	jle    800e3d <pstrcpy+0x40>
        return;

    for(;;) {
        c = *str++;
  800e0f:	0f b6 0a             	movzbl (%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  800e12:	84 c9                	test   %cl,%cl
  800e14:	74 22                	je     800e38 <pstrcpy+0x3b>
  800e16:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  800e1a:	89 f0                	mov    %esi,%eax
  800e1c:	39 de                	cmp    %ebx,%esi
  800e1e:	72 09                	jb     800e29 <pstrcpy+0x2c>
  800e20:	eb 16                	jmp    800e38 <pstrcpy+0x3b>
  800e22:	83 c2 01             	add    $0x1,%edx
  800e25:	39 d8                	cmp    %ebx,%eax
  800e27:	73 11                	jae    800e3a <pstrcpy+0x3d>
            break;
        *q++ = c;
  800e29:	88 08                	mov    %cl,(%eax)
  800e2b:	83 c0 01             	add    $0x1,%eax

    if (buf_size <= 0)
        return;

    for(;;) {
        c = *str++;
  800e2e:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  800e32:	84 c9                	test   %cl,%cl
  800e34:	75 ec                	jne    800e22 <pstrcpy+0x25>
  800e36:	eb 02                	jmp    800e3a <pstrcpy+0x3d>
  800e38:	89 f0                	mov    %esi,%eax
            break;
        *q++ = c;
    }
    *q = '\0';
  800e3a:	c6 00 00             	movb   $0x0,(%eax)
}
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	8b 55 08             	mov    0x8(%ebp),%edx
  800e47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  800e4a:	0f b6 02             	movzbl (%edx),%eax
  800e4d:	84 c0                	test   %al,%al
  800e4f:	74 16                	je     800e67 <strcmp+0x26>
  800e51:	3a 01                	cmp    (%ecx),%al
  800e53:	75 12                	jne    800e67 <strcmp+0x26>
		p++, q++;
  800e55:	83 c1 01             	add    $0x1,%ecx
    *q = '\0';
}
int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e58:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  800e5c:	84 c0                	test   %al,%al
  800e5e:	74 07                	je     800e67 <strcmp+0x26>
  800e60:	83 c2 01             	add    $0x1,%edx
  800e63:	3a 01                	cmp    (%ecx),%al
  800e65:	74 ee                	je     800e55 <strcmp+0x14>
  800e67:	0f b6 c0             	movzbl %al,%eax
  800e6a:	0f b6 11             	movzbl (%ecx),%edx
  800e6d:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    

00800e71 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	53                   	push   %ebx
  800e75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e7b:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800e7e:	85 d2                	test   %edx,%edx
  800e80:	74 2d                	je     800eaf <strncmp+0x3e>
  800e82:	0f b6 01             	movzbl (%ecx),%eax
  800e85:	84 c0                	test   %al,%al
  800e87:	74 1a                	je     800ea3 <strncmp+0x32>
  800e89:	3a 03                	cmp    (%ebx),%al
  800e8b:	75 16                	jne    800ea3 <strncmp+0x32>
  800e8d:	83 ea 01             	sub    $0x1,%edx
  800e90:	74 1d                	je     800eaf <strncmp+0x3e>
		n--, p++, q++;
  800e92:	83 c1 01             	add    $0x1,%ecx
  800e95:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e98:	0f b6 01             	movzbl (%ecx),%eax
  800e9b:	84 c0                	test   %al,%al
  800e9d:	74 04                	je     800ea3 <strncmp+0x32>
  800e9f:	3a 03                	cmp    (%ebx),%al
  800ea1:	74 ea                	je     800e8d <strncmp+0x1c>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ea3:	0f b6 11             	movzbl (%ecx),%edx
  800ea6:	0f b6 03             	movzbl (%ebx),%eax
  800ea9:	29 c2                	sub    %eax,%edx
  800eab:	89 d0                	mov    %edx,%eax
  800ead:	eb 05                	jmp    800eb4 <strncmp+0x43>
  800eaf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eb4:	5b                   	pop    %ebx
  800eb5:	5d                   	pop    %ebp
  800eb6:	c3                   	ret    

00800eb7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ec1:	0f b6 10             	movzbl (%eax),%edx
  800ec4:	84 d2                	test   %dl,%dl
  800ec6:	74 14                	je     800edc <strchr+0x25>
		if (*s == c)
  800ec8:	38 ca                	cmp    %cl,%dl
  800eca:	75 06                	jne    800ed2 <strchr+0x1b>
  800ecc:	eb 13                	jmp    800ee1 <strchr+0x2a>
  800ece:	38 ca                	cmp    %cl,%dl
  800ed0:	74 0f                	je     800ee1 <strchr+0x2a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ed2:	83 c0 01             	add    $0x1,%eax
  800ed5:	0f b6 10             	movzbl (%eax),%edx
  800ed8:	84 d2                	test   %dl,%dl
  800eda:	75 f2                	jne    800ece <strchr+0x17>
  800edc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    

00800ee3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800eed:	0f b6 10             	movzbl (%eax),%edx
  800ef0:	84 d2                	test   %dl,%dl
  800ef2:	74 18                	je     800f0c <strfind+0x29>
		if (*s == c)
  800ef4:	38 ca                	cmp    %cl,%dl
  800ef6:	75 0a                	jne    800f02 <strfind+0x1f>
  800ef8:	eb 12                	jmp    800f0c <strfind+0x29>
  800efa:	38 ca                	cmp    %cl,%dl
  800efc:	8d 74 26 00          	lea    0x0(%esi),%esi
  800f00:	74 0a                	je     800f0c <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f02:	83 c0 01             	add    $0x1,%eax
  800f05:	0f b6 10             	movzbl (%eax),%edx
  800f08:	84 d2                	test   %dl,%dl
  800f0a:	75 ee                	jne    800efa <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800f0c:	5d                   	pop    %ebp
  800f0d:	c3                   	ret    

00800f0e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	83 ec 08             	sub    $0x8,%esp
  800f14:	89 1c 24             	mov    %ebx,(%esp)
  800f17:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f1b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800f21:	85 db                	test   %ebx,%ebx
  800f23:	74 36                	je     800f5b <memset+0x4d>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f25:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f2b:	75 26                	jne    800f53 <memset+0x45>
  800f2d:	f6 c3 03             	test   $0x3,%bl
  800f30:	75 21                	jne    800f53 <memset+0x45>
		c &= 0xFF;
  800f32:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800f36:	89 d0                	mov    %edx,%eax
  800f38:	c1 e0 18             	shl    $0x18,%eax
  800f3b:	89 d1                	mov    %edx,%ecx
  800f3d:	c1 e1 10             	shl    $0x10,%ecx
  800f40:	09 c8                	or     %ecx,%eax
  800f42:	09 d0                	or     %edx,%eax
  800f44:	c1 e2 08             	shl    $0x8,%edx
  800f47:	09 d0                	or     %edx,%eax
  800f49:	89 d9                	mov    %ebx,%ecx
  800f4b:	c1 e9 02             	shr    $0x2,%ecx
  800f4e:	fc                   	cld    
  800f4f:	f3 ab                	rep stos %eax,%es:(%edi)
  800f51:	eb 08                	jmp    800f5b <memset+0x4d>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f56:	89 d9                	mov    %ebx,%ecx
  800f58:	fc                   	cld    
  800f59:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f5b:	89 f8                	mov    %edi,%eax
  800f5d:	8b 1c 24             	mov    (%esp),%ebx
  800f60:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f64:	89 ec                	mov    %ebp,%esp
  800f66:	5d                   	pop    %ebp
  800f67:	c3                   	ret    

00800f68 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	83 ec 08             	sub    $0x8,%esp
  800f6e:	89 34 24             	mov    %esi,(%esp)
  800f71:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f75:	8b 45 08             	mov    0x8(%ebp),%eax
  800f78:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800f7b:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800f7e:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800f80:	39 c6                	cmp    %eax,%esi
  800f82:	73 38                	jae    800fbc <memmove+0x54>
  800f84:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f87:	39 d0                	cmp    %edx,%eax
  800f89:	73 31                	jae    800fbc <memmove+0x54>
		s += n;
		d += n;
  800f8b:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f8e:	f6 c2 03             	test   $0x3,%dl
  800f91:	75 1d                	jne    800fb0 <memmove+0x48>
  800f93:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f99:	75 15                	jne    800fb0 <memmove+0x48>
  800f9b:	f6 c1 03             	test   $0x3,%cl
  800f9e:	66 90                	xchg   %ax,%ax
  800fa0:	75 0e                	jne    800fb0 <memmove+0x48>
			asm volatile("std; rep movsl\n"
  800fa2:	8d 7e fc             	lea    -0x4(%esi),%edi
  800fa5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800fa8:	c1 e9 02             	shr    $0x2,%ecx
  800fab:	fd                   	std    
  800fac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fae:	eb 09                	jmp    800fb9 <memmove+0x51>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fb0:	8d 7e ff             	lea    -0x1(%esi),%edi
  800fb3:	8d 72 ff             	lea    -0x1(%edx),%esi
  800fb6:	fd                   	std    
  800fb7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fb9:	fc                   	cld    
  800fba:	eb 21                	jmp    800fdd <memmove+0x75>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fbc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800fc2:	75 16                	jne    800fda <memmove+0x72>
  800fc4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800fca:	75 0e                	jne    800fda <memmove+0x72>
  800fcc:	f6 c1 03             	test   $0x3,%cl
  800fcf:	90                   	nop    
  800fd0:	75 08                	jne    800fda <memmove+0x72>
			asm volatile("cld; rep movsl\n"
  800fd2:	c1 e9 02             	shr    $0x2,%ecx
  800fd5:	fc                   	cld    
  800fd6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fd8:	eb 03                	jmp    800fdd <memmove+0x75>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fda:	fc                   	cld    
  800fdb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800fdd:	8b 34 24             	mov    (%esp),%esi
  800fe0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fe4:	89 ec                	mov    %ebp,%esp
  800fe6:	5d                   	pop    %ebp
  800fe7:	c3                   	ret    

00800fe8 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800fee:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ff5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ffc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fff:	89 04 24             	mov    %eax,(%esp)
  801002:	e8 61 ff ff ff       	call   800f68 <memmove>
}
  801007:	c9                   	leave  
  801008:	c3                   	ret    

00801009 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	57                   	push   %edi
  80100d:	56                   	push   %esi
  80100e:	53                   	push   %ebx
  80100f:	83 ec 04             	sub    $0x4,%esp
  801012:	8b 45 08             	mov    0x8(%ebp),%eax
  801015:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801018:	8b 55 10             	mov    0x10(%ebp),%edx
  80101b:	83 ea 01             	sub    $0x1,%edx
  80101e:	83 fa ff             	cmp    $0xffffffff,%edx
  801021:	74 47                	je     80106a <memcmp+0x61>
		if (*s1 != *s2)
  801023:	0f b6 30             	movzbl (%eax),%esi
  801026:	0f b6 39             	movzbl (%ecx),%edi
			return (int) *s1 - (int) *s2;
  801029:	89 45 f0             	mov    %eax,-0x10(%ebp)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  80102c:	89 f0                	mov    %esi,%eax
  80102e:	89 fb                	mov    %edi,%ebx
  801030:	38 d8                	cmp    %bl,%al
  801032:	74 2e                	je     801062 <memcmp+0x59>
  801034:	eb 1c                	jmp    801052 <memcmp+0x49>
  801036:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801039:	0f b6 70 01          	movzbl 0x1(%eax),%esi
  80103d:	0f b6 79 01          	movzbl 0x1(%ecx),%edi
  801041:	83 c0 01             	add    $0x1,%eax
  801044:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801047:	83 c1 01             	add    $0x1,%ecx
  80104a:	89 f3                	mov    %esi,%ebx
  80104c:	89 f8                	mov    %edi,%eax
  80104e:	38 c3                	cmp    %al,%bl
  801050:	74 10                	je     801062 <memcmp+0x59>
			return (int) *s1 - (int) *s2;
  801052:	89 f1                	mov    %esi,%ecx
  801054:	0f b6 d1             	movzbl %cl,%edx
  801057:	89 fb                	mov    %edi,%ebx
  801059:	0f b6 c3             	movzbl %bl,%eax
  80105c:	29 c2                	sub    %eax,%edx
  80105e:	89 d0                	mov    %edx,%eax
  801060:	eb 0d                	jmp    80106f <memcmp+0x66>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801062:	83 ea 01             	sub    $0x1,%edx
  801065:	83 fa ff             	cmp    $0xffffffff,%edx
  801068:	75 cc                	jne    801036 <memcmp+0x2d>
  80106a:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  80106f:	83 c4 04             	add    $0x4,%esp
  801072:	5b                   	pop    %ebx
  801073:	5e                   	pop    %esi
  801074:	5f                   	pop    %edi
  801075:	5d                   	pop    %ebp
  801076:	c3                   	ret    

00801077 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80107d:	89 c1                	mov    %eax,%ecx
  80107f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
  801082:	39 c8                	cmp    %ecx,%eax
  801084:	73 15                	jae    80109b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801086:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
  80108a:	38 10                	cmp    %dl,(%eax)
  80108c:	75 06                	jne    801094 <memfind+0x1d>
  80108e:	eb 0b                	jmp    80109b <memfind+0x24>
  801090:	38 10                	cmp    %dl,(%eax)
  801092:	74 07                	je     80109b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801094:	83 c0 01             	add    $0x1,%eax
  801097:	39 c8                	cmp    %ecx,%eax
  801099:	75 f5                	jne    801090 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80109b:	5d                   	pop    %ebp
  80109c:	8d 74 26 00          	lea    0x0(%esi),%esi
  8010a0:	c3                   	ret    

008010a1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010a1:	55                   	push   %ebp
  8010a2:	89 e5                	mov    %esp,%ebp
  8010a4:	57                   	push   %edi
  8010a5:	56                   	push   %esi
  8010a6:	53                   	push   %ebx
  8010a7:	83 ec 04             	sub    $0x4,%esp
  8010aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ad:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010b0:	0f b6 01             	movzbl (%ecx),%eax
  8010b3:	3c 20                	cmp    $0x20,%al
  8010b5:	74 04                	je     8010bb <strtol+0x1a>
  8010b7:	3c 09                	cmp    $0x9,%al
  8010b9:	75 0e                	jne    8010c9 <strtol+0x28>
		s++;
  8010bb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010be:	0f b6 01             	movzbl (%ecx),%eax
  8010c1:	3c 20                	cmp    $0x20,%al
  8010c3:	74 f6                	je     8010bb <strtol+0x1a>
  8010c5:	3c 09                	cmp    $0x9,%al
  8010c7:	74 f2                	je     8010bb <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010c9:	3c 2b                	cmp    $0x2b,%al
  8010cb:	75 0c                	jne    8010d9 <strtol+0x38>
		s++;
  8010cd:	83 c1 01             	add    $0x1,%ecx
  8010d0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8010d7:	eb 15                	jmp    8010ee <strtol+0x4d>
	else if (*s == '-')
  8010d9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8010e0:	3c 2d                	cmp    $0x2d,%al
  8010e2:	75 0a                	jne    8010ee <strtol+0x4d>
		s++, neg = 1;
  8010e4:	83 c1 01             	add    $0x1,%ecx
  8010e7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010ee:	85 f6                	test   %esi,%esi
  8010f0:	0f 94 c0             	sete   %al
  8010f3:	74 05                	je     8010fa <strtol+0x59>
  8010f5:	83 fe 10             	cmp    $0x10,%esi
  8010f8:	75 18                	jne    801112 <strtol+0x71>
  8010fa:	80 39 30             	cmpb   $0x30,(%ecx)
  8010fd:	75 13                	jne    801112 <strtol+0x71>
  8010ff:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801103:	75 0d                	jne    801112 <strtol+0x71>
		s += 2, base = 16;
  801105:	83 c1 02             	add    $0x2,%ecx
  801108:	be 10 00 00 00       	mov    $0x10,%esi
  80110d:	8d 76 00             	lea    0x0(%esi),%esi
  801110:	eb 1b                	jmp    80112d <strtol+0x8c>
	else if (base == 0 && s[0] == '0')
  801112:	85 f6                	test   %esi,%esi
  801114:	75 0e                	jne    801124 <strtol+0x83>
  801116:	80 39 30             	cmpb   $0x30,(%ecx)
  801119:	75 09                	jne    801124 <strtol+0x83>
		s++, base = 8;
  80111b:	83 c1 01             	add    $0x1,%ecx
  80111e:	66 be 08 00          	mov    $0x8,%si
  801122:	eb 09                	jmp    80112d <strtol+0x8c>
	else if (base == 0)
  801124:	84 c0                	test   %al,%al
  801126:	74 05                	je     80112d <strtol+0x8c>
  801128:	be 0a 00 00 00       	mov    $0xa,%esi
  80112d:	bf 00 00 00 00       	mov    $0x0,%edi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801132:	0f b6 11             	movzbl (%ecx),%edx
  801135:	89 d3                	mov    %edx,%ebx
  801137:	8d 42 d0             	lea    -0x30(%edx),%eax
  80113a:	3c 09                	cmp    $0x9,%al
  80113c:	77 08                	ja     801146 <strtol+0xa5>
			dig = *s - '0';
  80113e:	0f be c2             	movsbl %dl,%eax
  801141:	8d 50 d0             	lea    -0x30(%eax),%edx
  801144:	eb 1c                	jmp    801162 <strtol+0xc1>
		else if (*s >= 'a' && *s <= 'z')
  801146:	8d 43 9f             	lea    -0x61(%ebx),%eax
  801149:	3c 19                	cmp    $0x19,%al
  80114b:	77 08                	ja     801155 <strtol+0xb4>
			dig = *s - 'a' + 10;
  80114d:	0f be c2             	movsbl %dl,%eax
  801150:	8d 50 a9             	lea    -0x57(%eax),%edx
  801153:	eb 0d                	jmp    801162 <strtol+0xc1>
		else if (*s >= 'A' && *s <= 'Z')
  801155:	8d 43 bf             	lea    -0x41(%ebx),%eax
  801158:	3c 19                	cmp    $0x19,%al
  80115a:	77 17                	ja     801173 <strtol+0xd2>
			dig = *s - 'A' + 10;
  80115c:	0f be c2             	movsbl %dl,%eax
  80115f:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  801162:	39 f2                	cmp    %esi,%edx
  801164:	7d 0d                	jge    801173 <strtol+0xd2>
			break;
		s++, val = (val * base) + dig;
  801166:	83 c1 01             	add    $0x1,%ecx
  801169:	89 f8                	mov    %edi,%eax
  80116b:	0f af c6             	imul   %esi,%eax
  80116e:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  801171:	eb bf                	jmp    801132 <strtol+0x91>
		// we don't properly detect overflow!
	}
  801173:	89 f8                	mov    %edi,%eax

	if (endptr)
  801175:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801179:	74 05                	je     801180 <strtol+0xdf>
		*endptr = (char *) s;
  80117b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80117e:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  801180:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801184:	74 04                	je     80118a <strtol+0xe9>
  801186:	89 c7                	mov    %eax,%edi
  801188:	f7 df                	neg    %edi
}
  80118a:	89 f8                	mov    %edi,%eax
  80118c:	83 c4 04             	add    $0x4,%esp
  80118f:	5b                   	pop    %ebx
  801190:	5e                   	pop    %esi
  801191:	5f                   	pop    %edi
  801192:	5d                   	pop    %ebp
  801193:	c3                   	ret    

00801194 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	83 ec 0c             	sub    $0xc,%esp
  80119a:	89 1c 24             	mov    %ebx,(%esp)
  80119d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011a1:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a5:	b8 01 00 00 00       	mov    $0x1,%eax
  8011aa:	bf 00 00 00 00       	mov    $0x0,%edi
  8011af:	89 fa                	mov    %edi,%edx
  8011b1:	89 f9                	mov    %edi,%ecx
  8011b3:	89 fb                	mov    %edi,%ebx
  8011b5:	89 fe                	mov    %edi,%esi
  8011b7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8011b9:	8b 1c 24             	mov    (%esp),%ebx
  8011bc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011c0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011c4:	89 ec                	mov    %ebp,%esp
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    

008011c8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	83 ec 0c             	sub    $0xc,%esp
  8011ce:	89 1c 24             	mov    %ebx,(%esp)
  8011d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011d5:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8011d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011df:	bf 00 00 00 00       	mov    $0x0,%edi
  8011e4:	89 f8                	mov    %edi,%eax
  8011e6:	89 fb                	mov    %edi,%ebx
  8011e8:	89 fe                	mov    %edi,%esi
  8011ea:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8011ec:	8b 1c 24             	mov    (%esp),%ebx
  8011ef:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011f3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011f7:	89 ec                	mov    %ebp,%esp
  8011f9:	5d                   	pop    %ebp
  8011fa:	c3                   	ret    

008011fb <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	83 ec 0c             	sub    $0xc,%esp
  801201:	89 1c 24             	mov    %ebx,(%esp)
  801204:	89 74 24 04          	mov    %esi,0x4(%esp)
  801208:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80120c:	b8 0e 00 00 00       	mov    $0xe,%eax
  801211:	bf 00 00 00 00       	mov    $0x0,%edi
  801216:	89 fa                	mov    %edi,%edx
  801218:	89 f9                	mov    %edi,%ecx
  80121a:	89 fb                	mov    %edi,%ebx
  80121c:	89 fe                	mov    %edi,%esi
  80121e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801220:	8b 1c 24             	mov    (%esp),%ebx
  801223:	8b 74 24 04          	mov    0x4(%esp),%esi
  801227:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80122b:	89 ec                	mov    %ebp,%esp
  80122d:	5d                   	pop    %ebp
  80122e:	c3                   	ret    

0080122f <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80122f:	55                   	push   %ebp
  801230:	89 e5                	mov    %esp,%ebp
  801232:	83 ec 28             	sub    $0x28,%esp
  801235:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801238:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80123b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80123e:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801241:	b8 0d 00 00 00       	mov    $0xd,%eax
  801246:	bf 00 00 00 00       	mov    $0x0,%edi
  80124b:	89 f9                	mov    %edi,%ecx
  80124d:	89 fb                	mov    %edi,%ebx
  80124f:	89 fe                	mov    %edi,%esi
  801251:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801253:	85 c0                	test   %eax,%eax
  801255:	7e 28                	jle    80127f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801257:	89 44 24 10          	mov    %eax,0x10(%esp)
  80125b:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801262:	00 
  801263:	c7 44 24 08 ff 2d 80 	movl   $0x802dff,0x8(%esp)
  80126a:	00 
  80126b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801272:	00 
  801273:	c7 04 24 1c 2e 80 00 	movl   $0x802e1c,(%esp)
  80127a:	e8 a9 f3 ff ff       	call   800628 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80127f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801282:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801285:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801288:	89 ec                	mov    %ebp,%esp
  80128a:	5d                   	pop    %ebp
  80128b:	c3                   	ret    

0080128c <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80128c:	55                   	push   %ebp
  80128d:	89 e5                	mov    %esp,%ebp
  80128f:	83 ec 0c             	sub    $0xc,%esp
  801292:	89 1c 24             	mov    %ebx,(%esp)
  801295:	89 74 24 04          	mov    %esi,0x4(%esp)
  801299:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80129d:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012a6:	8b 7d 14             	mov    0x14(%ebp),%edi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012a9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012ae:	be 00 00 00 00       	mov    $0x0,%esi
  8012b3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012b5:	8b 1c 24             	mov    (%esp),%ebx
  8012b8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8012bc:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8012c0:	89 ec                	mov    %ebp,%esp
  8012c2:	5d                   	pop    %ebp
  8012c3:	c3                   	ret    

008012c4 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	83 ec 28             	sub    $0x28,%esp
  8012ca:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012cd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012d0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8012d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012de:	bf 00 00 00 00       	mov    $0x0,%edi
  8012e3:	89 fb                	mov    %edi,%ebx
  8012e5:	89 fe                	mov    %edi,%esi
  8012e7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8012e9:	85 c0                	test   %eax,%eax
  8012eb:	7e 28                	jle    801315 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012ed:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012f1:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8012f8:	00 
  8012f9:	c7 44 24 08 ff 2d 80 	movl   $0x802dff,0x8(%esp)
  801300:	00 
  801301:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801308:	00 
  801309:	c7 04 24 1c 2e 80 00 	movl   $0x802e1c,(%esp)
  801310:	e8 13 f3 ff ff       	call   800628 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801315:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801318:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80131b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80131e:	89 ec                	mov    %ebp,%esp
  801320:	5d                   	pop    %ebp
  801321:	c3                   	ret    

00801322 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	83 ec 28             	sub    $0x28,%esp
  801328:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80132b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80132e:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801331:	8b 55 08             	mov    0x8(%ebp),%edx
  801334:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801337:	b8 09 00 00 00       	mov    $0x9,%eax
  80133c:	bf 00 00 00 00       	mov    $0x0,%edi
  801341:	89 fb                	mov    %edi,%ebx
  801343:	89 fe                	mov    %edi,%esi
  801345:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801347:	85 c0                	test   %eax,%eax
  801349:	7e 28                	jle    801373 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80134b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80134f:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801356:	00 
  801357:	c7 44 24 08 ff 2d 80 	movl   $0x802dff,0x8(%esp)
  80135e:	00 
  80135f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801366:	00 
  801367:	c7 04 24 1c 2e 80 00 	movl   $0x802e1c,(%esp)
  80136e:	e8 b5 f2 ff ff       	call   800628 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801373:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801376:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801379:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80137c:	89 ec                	mov    %ebp,%esp
  80137e:	5d                   	pop    %ebp
  80137f:	c3                   	ret    

00801380 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	83 ec 28             	sub    $0x28,%esp
  801386:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801389:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80138c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80138f:	8b 55 08             	mov    0x8(%ebp),%edx
  801392:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801395:	b8 08 00 00 00       	mov    $0x8,%eax
  80139a:	bf 00 00 00 00       	mov    $0x0,%edi
  80139f:	89 fb                	mov    %edi,%ebx
  8013a1:	89 fe                	mov    %edi,%esi
  8013a3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8013a5:	85 c0                	test   %eax,%eax
  8013a7:	7e 28                	jle    8013d1 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013a9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013ad:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8013b4:	00 
  8013b5:	c7 44 24 08 ff 2d 80 	movl   $0x802dff,0x8(%esp)
  8013bc:	00 
  8013bd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013c4:	00 
  8013c5:	c7 04 24 1c 2e 80 00 	movl   $0x802e1c,(%esp)
  8013cc:	e8 57 f2 ff ff       	call   800628 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8013d1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013d4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8013d7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013da:	89 ec                	mov    %ebp,%esp
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	83 ec 28             	sub    $0x28,%esp
  8013e4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013e7:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013ea:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8013ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8013f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013f3:	b8 06 00 00 00       	mov    $0x6,%eax
  8013f8:	bf 00 00 00 00       	mov    $0x0,%edi
  8013fd:	89 fb                	mov    %edi,%ebx
  8013ff:	89 fe                	mov    %edi,%esi
  801401:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801403:	85 c0                	test   %eax,%eax
  801405:	7e 28                	jle    80142f <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801407:	89 44 24 10          	mov    %eax,0x10(%esp)
  80140b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801412:	00 
  801413:	c7 44 24 08 ff 2d 80 	movl   $0x802dff,0x8(%esp)
  80141a:	00 
  80141b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801422:	00 
  801423:	c7 04 24 1c 2e 80 00 	movl   $0x802e1c,(%esp)
  80142a:	e8 f9 f1 ff ff       	call   800628 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80142f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801432:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801435:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801438:	89 ec                	mov    %ebp,%esp
  80143a:	5d                   	pop    %ebp
  80143b:	c3                   	ret    

0080143c <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	83 ec 28             	sub    $0x28,%esp
  801442:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801445:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801448:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80144b:	8b 55 08             	mov    0x8(%ebp),%edx
  80144e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801451:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801454:	8b 7d 14             	mov    0x14(%ebp),%edi
  801457:	8b 75 18             	mov    0x18(%ebp),%esi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80145a:	b8 05 00 00 00       	mov    $0x5,%eax
  80145f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801461:	85 c0                	test   %eax,%eax
  801463:	7e 28                	jle    80148d <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801465:	89 44 24 10          	mov    %eax,0x10(%esp)
  801469:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801470:	00 
  801471:	c7 44 24 08 ff 2d 80 	movl   $0x802dff,0x8(%esp)
  801478:	00 
  801479:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801480:	00 
  801481:	c7 04 24 1c 2e 80 00 	movl   $0x802e1c,(%esp)
  801488:	e8 9b f1 ff ff       	call   800628 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80148d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801490:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801493:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801496:	89 ec                	mov    %ebp,%esp
  801498:	5d                   	pop    %ebp
  801499:	c3                   	ret    

0080149a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	83 ec 28             	sub    $0x28,%esp
  8014a0:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8014a3:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8014a6:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8014a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8014ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014af:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014b2:	b8 04 00 00 00       	mov    $0x4,%eax
  8014b7:	bf 00 00 00 00       	mov    $0x0,%edi
  8014bc:	89 fe                	mov    %edi,%esi
  8014be:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8014c0:	85 c0                	test   %eax,%eax
  8014c2:	7e 28                	jle    8014ec <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014c4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014c8:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8014cf:	00 
  8014d0:	c7 44 24 08 ff 2d 80 	movl   $0x802dff,0x8(%esp)
  8014d7:	00 
  8014d8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014df:	00 
  8014e0:	c7 04 24 1c 2e 80 00 	movl   $0x802e1c,(%esp)
  8014e7:	e8 3c f1 ff ff       	call   800628 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8014ec:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8014ef:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8014f2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014f5:	89 ec                	mov    %ebp,%esp
  8014f7:	5d                   	pop    %ebp
  8014f8:	c3                   	ret    

008014f9 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  8014f9:	55                   	push   %ebp
  8014fa:	89 e5                	mov    %esp,%ebp
  8014fc:	83 ec 0c             	sub    $0xc,%esp
  8014ff:	89 1c 24             	mov    %ebx,(%esp)
  801502:	89 74 24 04          	mov    %esi,0x4(%esp)
  801506:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80150a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80150f:	bf 00 00 00 00       	mov    $0x0,%edi
  801514:	89 fa                	mov    %edi,%edx
  801516:	89 f9                	mov    %edi,%ecx
  801518:	89 fb                	mov    %edi,%ebx
  80151a:	89 fe                	mov    %edi,%esi
  80151c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80151e:	8b 1c 24             	mov    (%esp),%ebx
  801521:	8b 74 24 04          	mov    0x4(%esp),%esi
  801525:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801529:	89 ec                	mov    %ebp,%esp
  80152b:	5d                   	pop    %ebp
  80152c:	c3                   	ret    

0080152d <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
  801530:	83 ec 0c             	sub    $0xc,%esp
  801533:	89 1c 24             	mov    %ebx,(%esp)
  801536:	89 74 24 04          	mov    %esi,0x4(%esp)
  80153a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80153e:	b8 02 00 00 00       	mov    $0x2,%eax
  801543:	bf 00 00 00 00       	mov    $0x0,%edi
  801548:	89 fa                	mov    %edi,%edx
  80154a:	89 f9                	mov    %edi,%ecx
  80154c:	89 fb                	mov    %edi,%ebx
  80154e:	89 fe                	mov    %edi,%esi
  801550:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801552:	8b 1c 24             	mov    (%esp),%ebx
  801555:	8b 74 24 04          	mov    0x4(%esp),%esi
  801559:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80155d:	89 ec                	mov    %ebp,%esp
  80155f:	5d                   	pop    %ebp
  801560:	c3                   	ret    

00801561 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801561:	55                   	push   %ebp
  801562:	89 e5                	mov    %esp,%ebp
  801564:	83 ec 28             	sub    $0x28,%esp
  801567:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80156a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80156d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801570:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801573:	b8 03 00 00 00       	mov    $0x3,%eax
  801578:	bf 00 00 00 00       	mov    $0x0,%edi
  80157d:	89 f9                	mov    %edi,%ecx
  80157f:	89 fb                	mov    %edi,%ebx
  801581:	89 fe                	mov    %edi,%esi
  801583:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801585:	85 c0                	test   %eax,%eax
  801587:	7e 28                	jle    8015b1 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801589:	89 44 24 10          	mov    %eax,0x10(%esp)
  80158d:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801594:	00 
  801595:	c7 44 24 08 ff 2d 80 	movl   $0x802dff,0x8(%esp)
  80159c:	00 
  80159d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8015a4:	00 
  8015a5:	c7 04 24 1c 2e 80 00 	movl   $0x802e1c,(%esp)
  8015ac:	e8 77 f0 ff ff       	call   800628 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8015b1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8015b4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8015b7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015ba:	89 ec                	mov    %ebp,%esp
  8015bc:	5d                   	pop    %ebp
  8015bd:	c3                   	ret    
	...

008015c0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	57                   	push   %edi
  8015c4:	56                   	push   %esi
  8015c5:	53                   	push   %ebx
  8015c6:	83 ec 1c             	sub    $0x1c,%esp
  8015c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8015cc:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  8015cf:	e8 59 ff ff ff       	call   80152d <sys_getenvid>
  8015d4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8015d9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8015dc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8015e1:	a3 40 60 80 00       	mov    %eax,0x806040
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  8015e6:	e8 42 ff ff ff       	call   80152d <sys_getenvid>
  8015eb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8015f0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8015f3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8015f8:	a3 40 60 80 00       	mov    %eax,0x806040
		if(env->env_id==to_env){
  8015fd:	8b 40 4c             	mov    0x4c(%eax),%eax
  801600:	39 f0                	cmp    %esi,%eax
  801602:	75 0e                	jne    801612 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  801604:	c7 04 24 2a 2e 80 00 	movl   $0x802e2a,(%esp)
  80160b:	e8 e5 f0 ff ff       	call   8006f5 <cprintf>
  801610:	eb 5a                	jmp    80166c <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  801612:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801616:	8b 45 10             	mov    0x10(%ebp),%eax
  801619:	89 44 24 08          	mov    %eax,0x8(%esp)
  80161d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801620:	89 44 24 04          	mov    %eax,0x4(%esp)
  801624:	89 34 24             	mov    %esi,(%esp)
  801627:	e8 60 fc ff ff       	call   80128c <sys_ipc_try_send>
  80162c:	89 c3                	mov    %eax,%ebx
  80162e:	85 c0                	test   %eax,%eax
  801630:	79 25                	jns    801657 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  801632:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801635:	74 2b                	je     801662 <ipc_send+0xa2>
				panic("send error:%e",r);
  801637:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80163b:	c7 44 24 08 46 2e 80 	movl   $0x802e46,0x8(%esp)
  801642:	00 
  801643:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80164a:	00 
  80164b:	c7 04 24 54 2e 80 00 	movl   $0x802e54,(%esp)
  801652:	e8 d1 ef ff ff       	call   800628 <_panic>
		}
			sys_yield();
  801657:	e8 9d fe ff ff       	call   8014f9 <sys_yield>
		
	}while(r!=0);
  80165c:	85 db                	test   %ebx,%ebx
  80165e:	75 86                	jne    8015e6 <ipc_send+0x26>
  801660:	eb 0a                	jmp    80166c <ipc_send+0xac>
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
		{	
			if(r!=-E_IPC_NOT_RECV)
				panic("send error:%e",r);
		}
			sys_yield();
  801662:	e8 92 fe ff ff       	call   8014f9 <sys_yield>
  801667:	e9 7a ff ff ff       	jmp    8015e6 <ipc_send+0x26>
		
	}while(r!=0);
	return;
	//panic("ipc_send not implemented");
}
  80166c:	83 c4 1c             	add    $0x1c,%esp
  80166f:	5b                   	pop    %ebx
  801670:	5e                   	pop    %esi
  801671:	5f                   	pop    %edi
  801672:	5d                   	pop    %ebp
  801673:	c3                   	ret    

00801674 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	57                   	push   %edi
  801678:	56                   	push   %esi
  801679:	53                   	push   %ebx
  80167a:	83 ec 0c             	sub    $0xc,%esp
  80167d:	8b 75 08             	mov    0x8(%ebp),%esi
  801680:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	void *dstva=NULL;
	if(pg)
		dstva=pg;
	env = &envs[ENVX(sys_getenvid())];
  801683:	e8 a5 fe ff ff       	call   80152d <sys_getenvid>
  801688:	25 ff 03 00 00       	and    $0x3ff,%eax
  80168d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801690:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801695:	a3 40 60 80 00       	mov    %eax,0x806040
	if(from_env_store&&(env->env_id==*from_env_store))
  80169a:	85 f6                	test   %esi,%esi
  80169c:	74 29                	je     8016c7 <ipc_recv+0x53>
  80169e:	8b 40 4c             	mov    0x4c(%eax),%eax
  8016a1:	3b 06                	cmp    (%esi),%eax
  8016a3:	75 22                	jne    8016c7 <ipc_recv+0x53>
	{
		*from_env_store=0;
  8016a5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  8016ab:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("send:the reciver is sender\n");
  8016b1:	c7 04 24 2a 2e 80 00 	movl   $0x802e2a,(%esp)
  8016b8:	e8 38 f0 ff ff       	call   8006f5 <cprintf>
  8016bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016c2:	e9 8a 00 00 00       	jmp    801751 <ipc_recv+0xdd>
		return 0;
	}
	env = &envs[ENVX(sys_getenvid())];
  8016c7:	e8 61 fe ff ff       	call   80152d <sys_getenvid>
  8016cc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016d1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8016d4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8016d9:	a3 40 60 80 00       	mov    %eax,0x806040
	if((r=sys_ipc_recv(dstva))<0)
  8016de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e1:	89 04 24             	mov    %eax,(%esp)
  8016e4:	e8 46 fb ff ff       	call   80122f <sys_ipc_recv>
  8016e9:	89 c3                	mov    %eax,%ebx
  8016eb:	85 c0                	test   %eax,%eax
  8016ed:	79 1a                	jns    801709 <ipc_recv+0x95>
	{
		*from_env_store=0;
  8016ef:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  8016f5:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("reciver failed\n");
  8016fb:	c7 04 24 5e 2e 80 00 	movl   $0x802e5e,(%esp)
  801702:	e8 ee ef ff ff       	call   8006f5 <cprintf>
  801707:	eb 48                	jmp    801751 <ipc_recv+0xdd>
		return r;
	}
	else{//接收成功
		env = &envs[ENVX(sys_getenvid())];
  801709:	e8 1f fe ff ff       	call   80152d <sys_getenvid>
  80170e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801713:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801716:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80171b:	a3 40 60 80 00       	mov    %eax,0x806040
		if(from_env_store)
  801720:	85 f6                	test   %esi,%esi
  801722:	74 05                	je     801729 <ipc_recv+0xb5>
			*from_env_store=env->env_ipc_from;	
  801724:	8b 40 74             	mov    0x74(%eax),%eax
  801727:	89 06                	mov    %eax,(%esi)
		if(perm_store)
  801729:	85 ff                	test   %edi,%edi
  80172b:	74 0a                	je     801737 <ipc_recv+0xc3>
			*perm_store=env->env_ipc_perm;
  80172d:	a1 40 60 80 00       	mov    0x806040,%eax
  801732:	8b 40 78             	mov    0x78(%eax),%eax
  801735:	89 07                	mov    %eax,(%edi)
		env = &envs[ENVX(sys_getenvid())];
  801737:	e8 f1 fd ff ff       	call   80152d <sys_getenvid>
  80173c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801741:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801744:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801749:	a3 40 60 80 00       	mov    %eax,0x806040
		return env->env_ipc_value;
  80174e:	8b 58 70             	mov    0x70(%eax),%ebx
	}
	//panic("ipc_recv not implemented");
	return 0;
}
  801751:	89 d8                	mov    %ebx,%eax
  801753:	83 c4 0c             	add    $0xc,%esp
  801756:	5b                   	pop    %ebx
  801757:	5e                   	pop    %esi
  801758:	5f                   	pop    %edi
  801759:	5d                   	pop    %ebp
  80175a:	c3                   	ret    
  80175b:	00 00                	add    %al,(%eax)
  80175d:	00 00                	add    %al,(%eax)
	...

00801760 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	8b 45 08             	mov    0x8(%ebp),%eax
  801766:	05 00 00 00 30       	add    $0x30000000,%eax
  80176b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80176e:	5d                   	pop    %ebp
  80176f:	c3                   	ret    

00801770 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801776:	8b 45 08             	mov    0x8(%ebp),%eax
  801779:	89 04 24             	mov    %eax,(%esp)
  80177c:	e8 df ff ff ff       	call   801760 <fd2num>
  801781:	c1 e0 0c             	shl    $0xc,%eax
  801784:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801789:	c9                   	leave  
  80178a:	c3                   	ret    

0080178b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	53                   	push   %ebx
  80178f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801792:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801797:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801799:	89 d0                	mov    %edx,%eax
  80179b:	c1 e8 16             	shr    $0x16,%eax
  80179e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8017a5:	a8 01                	test   $0x1,%al
  8017a7:	74 10                	je     8017b9 <fd_alloc+0x2e>
  8017a9:	89 d0                	mov    %edx,%eax
  8017ab:	c1 e8 0c             	shr    $0xc,%eax
  8017ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017b5:	a8 01                	test   $0x1,%al
  8017b7:	75 09                	jne    8017c2 <fd_alloc+0x37>
			*fd_store = fd;
  8017b9:	89 0b                	mov    %ecx,(%ebx)
  8017bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c0:	eb 19                	jmp    8017db <fd_alloc+0x50>
			return 0;
  8017c2:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8017c8:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  8017ce:	75 c7                	jne    801797 <fd_alloc+0xc>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8017d0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8017d6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8017db:	5b                   	pop    %ebx
  8017dc:	5d                   	pop    %ebp
  8017dd:	c3                   	ret    

008017de <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8017e1:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  8017e5:	77 38                	ja     80181f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8017e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ea:	c1 e0 0c             	shl    $0xc,%eax
  8017ed:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  8017f3:	89 d0                	mov    %edx,%eax
  8017f5:	c1 e8 16             	shr    $0x16,%eax
  8017f8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8017ff:	a8 01                	test   $0x1,%al
  801801:	74 1c                	je     80181f <fd_lookup+0x41>
  801803:	89 d0                	mov    %edx,%eax
  801805:	c1 e8 0c             	shr    $0xc,%eax
  801808:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80180f:	a8 01                	test   $0x1,%al
  801811:	74 0c                	je     80181f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801813:	8b 45 0c             	mov    0xc(%ebp),%eax
  801816:	89 10                	mov    %edx,(%eax)
  801818:	b8 00 00 00 00       	mov    $0x0,%eax
  80181d:	eb 05                	jmp    801824 <fd_lookup+0x46>
	return 0;
  80181f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801824:	5d                   	pop    %ebp
  801825:	c3                   	ret    

00801826 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801826:	55                   	push   %ebp
  801827:	89 e5                	mov    %esp,%ebp
  801829:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80182c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80182f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801833:	8b 45 08             	mov    0x8(%ebp),%eax
  801836:	89 04 24             	mov    %eax,(%esp)
  801839:	e8 a0 ff ff ff       	call   8017de <fd_lookup>
  80183e:	85 c0                	test   %eax,%eax
  801840:	78 0e                	js     801850 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801842:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801845:	8b 55 0c             	mov    0xc(%ebp),%edx
  801848:	89 50 04             	mov    %edx,0x4(%eax)
  80184b:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801850:	c9                   	leave  
  801851:	c3                   	ret    

00801852 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801852:	55                   	push   %ebp
  801853:	89 e5                	mov    %esp,%ebp
  801855:	53                   	push   %ebx
  801856:	83 ec 14             	sub    $0x14,%esp
  801859:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80185c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80185f:	ba 08 60 80 00       	mov    $0x806008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801864:	b8 00 00 00 00       	mov    $0x0,%eax
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801869:	39 0d 08 60 80 00    	cmp    %ecx,0x806008
  80186f:	75 11                	jne    801882 <dev_lookup+0x30>
  801871:	eb 04                	jmp    801877 <dev_lookup+0x25>
  801873:	39 0a                	cmp    %ecx,(%edx)
  801875:	75 0b                	jne    801882 <dev_lookup+0x30>
			*dev = devtab[i];
  801877:	89 13                	mov    %edx,(%ebx)
  801879:	b8 00 00 00 00       	mov    $0x0,%eax
  80187e:	66 90                	xchg   %ax,%ax
  801880:	eb 35                	jmp    8018b7 <dev_lookup+0x65>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801882:	83 c0 01             	add    $0x1,%eax
  801885:	8b 14 85 f0 2e 80 00 	mov    0x802ef0(,%eax,4),%edx
  80188c:	85 d2                	test   %edx,%edx
  80188e:	75 e3                	jne    801873 <dev_lookup+0x21>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  801890:	a1 40 60 80 00       	mov    0x806040,%eax
  801895:	8b 40 4c             	mov    0x4c(%eax),%eax
  801898:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80189c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a0:	c7 04 24 70 2e 80 00 	movl   $0x802e70,(%esp)
  8018a7:	e8 49 ee ff ff       	call   8006f5 <cprintf>
	*dev = 0;
  8018ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8018b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8018b7:	83 c4 14             	add    $0x14,%esp
  8018ba:	5b                   	pop    %ebx
  8018bb:	5d                   	pop    %ebp
  8018bc:	c3                   	ret    

008018bd <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8018bd:	55                   	push   %ebp
  8018be:	89 e5                	mov    %esp,%ebp
  8018c0:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018c3:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8018c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cd:	89 04 24             	mov    %eax,(%esp)
  8018d0:	e8 09 ff ff ff       	call   8017de <fd_lookup>
  8018d5:	89 c2                	mov    %eax,%edx
  8018d7:	85 c0                	test   %eax,%eax
  8018d9:	78 5a                	js     801935 <fstat+0x78>
  8018db:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8018e5:	8b 00                	mov    (%eax),%eax
  8018e7:	89 04 24             	mov    %eax,(%esp)
  8018ea:	e8 63 ff ff ff       	call   801852 <dev_lookup>
  8018ef:	89 c2                	mov    %eax,%edx
  8018f1:	85 c0                	test   %eax,%eax
  8018f3:	78 40                	js     801935 <fstat+0x78>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8018f5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  8018fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018fd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801901:	74 32                	je     801935 <fstat+0x78>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801903:	8b 45 0c             	mov    0xc(%ebp),%eax
  801906:	c6 00 00             	movb   $0x0,(%eax)
	stat->st_size = 0;
  801909:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  801910:	00 00 00 
	stat->st_isdir = 0;
  801913:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
  80191a:	00 00 00 
	stat->st_dev = dev;
  80191d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801920:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
	return (*dev->dev_stat)(fd, stat);
  801926:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80192d:	89 04 24             	mov    %eax,(%esp)
  801930:	ff 52 14             	call   *0x14(%edx)
  801933:	89 c2                	mov    %eax,%edx
}
  801935:	89 d0                	mov    %edx,%eax
  801937:	c9                   	leave  
  801938:	c3                   	ret    

00801939 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801939:	55                   	push   %ebp
  80193a:	89 e5                	mov    %esp,%ebp
  80193c:	53                   	push   %ebx
  80193d:	83 ec 24             	sub    $0x24,%esp
  801940:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801943:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801946:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194a:	89 1c 24             	mov    %ebx,(%esp)
  80194d:	e8 8c fe ff ff       	call   8017de <fd_lookup>
  801952:	85 c0                	test   %eax,%eax
  801954:	78 61                	js     8019b7 <ftruncate+0x7e>
  801956:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801959:	8b 10                	mov    (%eax),%edx
  80195b:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80195e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801962:	89 14 24             	mov    %edx,(%esp)
  801965:	e8 e8 fe ff ff       	call   801852 <dev_lookup>
  80196a:	85 c0                	test   %eax,%eax
  80196c:	78 49                	js     8019b7 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80196e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801971:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801975:	75 23                	jne    80199a <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801977:	a1 40 60 80 00       	mov    0x806040,%eax
  80197c:	8b 40 4c             	mov    0x4c(%eax),%eax
  80197f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801983:	89 44 24 04          	mov    %eax,0x4(%esp)
  801987:	c7 04 24 90 2e 80 00 	movl   $0x802e90,(%esp)
  80198e:	e8 62 ed ff ff       	call   8006f5 <cprintf>
  801993:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801998:	eb 1d                	jmp    8019b7 <ftruncate+0x7e>
			env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80199a:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80199d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019a2:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  8019a6:	74 0f                	je     8019b7 <ftruncate+0x7e>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019a8:	8b 42 18             	mov    0x18(%edx),%eax
  8019ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019b2:	89 0c 24             	mov    %ecx,(%esp)
  8019b5:	ff d0                	call   *%eax
}
  8019b7:	83 c4 24             	add    $0x24,%esp
  8019ba:	5b                   	pop    %ebx
  8019bb:	5d                   	pop    %ebp
  8019bc:	c3                   	ret    

008019bd <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	53                   	push   %ebx
  8019c1:	83 ec 24             	sub    $0x24,%esp
  8019c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ce:	89 1c 24             	mov    %ebx,(%esp)
  8019d1:	e8 08 fe ff ff       	call   8017de <fd_lookup>
  8019d6:	85 c0                	test   %eax,%eax
  8019d8:	78 68                	js     801a42 <write+0x85>
  8019da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019dd:	8b 10                	mov    (%eax),%edx
  8019df:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8019e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e6:	89 14 24             	mov    %edx,(%esp)
  8019e9:	e8 64 fe ff ff       	call   801852 <dev_lookup>
  8019ee:	85 c0                	test   %eax,%eax
  8019f0:	78 50                	js     801a42 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019f2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  8019f5:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  8019f9:	75 23                	jne    801a1e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  8019fb:	a1 40 60 80 00       	mov    0x806040,%eax
  801a00:	8b 40 4c             	mov    0x4c(%eax),%eax
  801a03:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a07:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0b:	c7 04 24 b4 2e 80 00 	movl   $0x802eb4,(%esp)
  801a12:	e8 de ec ff ff       	call   8006f5 <cprintf>
  801a17:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a1c:	eb 24                	jmp    801a42 <write+0x85>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801a1e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801a21:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a26:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  801a2a:	74 16                	je     801a42 <write+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801a2c:	8b 42 0c             	mov    0xc(%edx),%eax
  801a2f:	8b 55 10             	mov    0x10(%ebp),%edx
  801a32:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a36:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a39:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a3d:	89 0c 24             	mov    %ecx,(%esp)
  801a40:	ff d0                	call   *%eax
}
  801a42:	83 c4 24             	add    $0x24,%esp
  801a45:	5b                   	pop    %ebx
  801a46:	5d                   	pop    %ebp
  801a47:	c3                   	ret    

00801a48 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
  801a4b:	53                   	push   %ebx
  801a4c:	83 ec 24             	sub    $0x24,%esp
  801a4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a59:	89 1c 24             	mov    %ebx,(%esp)
  801a5c:	e8 7d fd ff ff       	call   8017de <fd_lookup>
  801a61:	85 c0                	test   %eax,%eax
  801a63:	78 6d                	js     801ad2 <read+0x8a>
  801a65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a68:	8b 10                	mov    (%eax),%edx
  801a6a:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801a6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a71:	89 14 24             	mov    %edx,(%esp)
  801a74:	e8 d9 fd ff ff       	call   801852 <dev_lookup>
  801a79:	85 c0                	test   %eax,%eax
  801a7b:	78 55                	js     801ad2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801a7d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801a80:	8b 41 08             	mov    0x8(%ecx),%eax
  801a83:	83 e0 03             	and    $0x3,%eax
  801a86:	83 f8 01             	cmp    $0x1,%eax
  801a89:	75 23                	jne    801aae <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  801a8b:	a1 40 60 80 00       	mov    0x806040,%eax
  801a90:	8b 40 4c             	mov    0x4c(%eax),%eax
  801a93:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a97:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9b:	c7 04 24 d1 2e 80 00 	movl   $0x802ed1,(%esp)
  801aa2:	e8 4e ec ff ff       	call   8006f5 <cprintf>
  801aa7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801aac:	eb 24                	jmp    801ad2 <read+0x8a>
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801aae:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801ab1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801ab6:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  801aba:	74 16                	je     801ad2 <read+0x8a>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801abc:	8b 42 08             	mov    0x8(%edx),%eax
  801abf:	8b 55 10             	mov    0x10(%ebp),%edx
  801ac2:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ac6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ac9:	89 54 24 04          	mov    %edx,0x4(%esp)
  801acd:	89 0c 24             	mov    %ecx,(%esp)
  801ad0:	ff d0                	call   *%eax
}
  801ad2:	83 c4 24             	add    $0x24,%esp
  801ad5:	5b                   	pop    %ebx
  801ad6:	5d                   	pop    %ebp
  801ad7:	c3                   	ret    

00801ad8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	57                   	push   %edi
  801adc:	56                   	push   %esi
  801add:	53                   	push   %ebx
  801ade:	83 ec 0c             	sub    $0xc,%esp
  801ae1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ae4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801ae7:	b8 00 00 00 00       	mov    $0x0,%eax
  801aec:	85 f6                	test   %esi,%esi
  801aee:	74 36                	je     801b26 <readn+0x4e>
  801af0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801af5:	ba 00 00 00 00       	mov    $0x0,%edx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801afa:	89 f0                	mov    %esi,%eax
  801afc:	29 d0                	sub    %edx,%eax
  801afe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b02:	8d 04 17             	lea    (%edi,%edx,1),%eax
  801b05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b09:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0c:	89 04 24             	mov    %eax,(%esp)
  801b0f:	e8 34 ff ff ff       	call   801a48 <read>
		if (m < 0)
  801b14:	85 c0                	test   %eax,%eax
  801b16:	78 0e                	js     801b26 <readn+0x4e>
			return m;
		if (m == 0)
  801b18:	85 c0                	test   %eax,%eax
  801b1a:	74 08                	je     801b24 <readn+0x4c>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b1c:	01 c3                	add    %eax,%ebx
  801b1e:	89 da                	mov    %ebx,%edx
  801b20:	39 f3                	cmp    %esi,%ebx
  801b22:	72 d6                	jb     801afa <readn+0x22>
  801b24:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801b26:	83 c4 0c             	add    $0xc,%esp
  801b29:	5b                   	pop    %ebx
  801b2a:	5e                   	pop    %esi
  801b2b:	5f                   	pop    %edi
  801b2c:	5d                   	pop    %ebp
  801b2d:	c3                   	ret    

00801b2e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
  801b31:	83 ec 28             	sub    $0x28,%esp
  801b34:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b37:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801b3a:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801b3d:	89 34 24             	mov    %esi,(%esp)
  801b40:	e8 1b fc ff ff       	call   801760 <fd2num>
  801b45:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b48:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b4c:	89 04 24             	mov    %eax,(%esp)
  801b4f:	e8 8a fc ff ff       	call   8017de <fd_lookup>
  801b54:	89 c3                	mov    %eax,%ebx
  801b56:	85 c0                	test   %eax,%eax
  801b58:	78 05                	js     801b5f <fd_close+0x31>
  801b5a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801b5d:	74 0d                	je     801b6c <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801b5f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b63:	75 44                	jne    801ba9 <fd_close+0x7b>
  801b65:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b6a:	eb 3d                	jmp    801ba9 <fd_close+0x7b>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801b6c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b73:	8b 06                	mov    (%esi),%eax
  801b75:	89 04 24             	mov    %eax,(%esp)
  801b78:	e8 d5 fc ff ff       	call   801852 <dev_lookup>
  801b7d:	89 c3                	mov    %eax,%ebx
  801b7f:	85 c0                	test   %eax,%eax
  801b81:	78 16                	js     801b99 <fd_close+0x6b>
		if (dev->dev_close)
  801b83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b86:	8b 40 10             	mov    0x10(%eax),%eax
  801b89:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	74 07                	je     801b99 <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  801b92:	89 34 24             	mov    %esi,(%esp)
  801b95:	ff d0                	call   *%eax
  801b97:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801b99:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ba4:	e8 35 f8 ff ff       	call   8013de <sys_page_unmap>
	return r;
}
  801ba9:	89 d8                	mov    %ebx,%eax
  801bab:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801bae:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801bb1:	89 ec                	mov    %ebp,%esp
  801bb3:	5d                   	pop    %ebp
  801bb4:	c3                   	ret    

00801bb5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801bb5:	55                   	push   %ebp
  801bb6:	89 e5                	mov    %esp,%ebp
  801bb8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bbb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801bbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc5:	89 04 24             	mov    %eax,(%esp)
  801bc8:	e8 11 fc ff ff       	call   8017de <fd_lookup>
  801bcd:	85 c0                	test   %eax,%eax
  801bcf:	78 13                	js     801be4 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801bd1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801bd8:	00 
  801bd9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801bdc:	89 04 24             	mov    %eax,(%esp)
  801bdf:	e8 4a ff ff ff       	call   801b2e <fd_close>
}
  801be4:	c9                   	leave  
  801be5:	c3                   	ret    

00801be6 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
  801be9:	83 ec 18             	sub    $0x18,%esp
  801bec:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801bef:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801bf2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bf9:	00 
  801bfa:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfd:	89 04 24             	mov    %eax,(%esp)
  801c00:	e8 5a 03 00 00       	call   801f5f <open>
  801c05:	89 c6                	mov    %eax,%esi
  801c07:	85 c0                	test   %eax,%eax
  801c09:	78 1b                	js     801c26 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801c0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c12:	89 34 24             	mov    %esi,(%esp)
  801c15:	e8 a3 fc ff ff       	call   8018bd <fstat>
  801c1a:	89 c3                	mov    %eax,%ebx
	close(fd);
  801c1c:	89 34 24             	mov    %esi,(%esp)
  801c1f:	e8 91 ff ff ff       	call   801bb5 <close>
  801c24:	89 de                	mov    %ebx,%esi
	return r;
}
  801c26:	89 f0                	mov    %esi,%eax
  801c28:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801c2b:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c2e:	89 ec                	mov    %ebp,%esp
  801c30:	5d                   	pop    %ebp
  801c31:	c3                   	ret    

00801c32 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801c32:	55                   	push   %ebp
  801c33:	89 e5                	mov    %esp,%ebp
  801c35:	83 ec 38             	sub    $0x38,%esp
  801c38:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801c3b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801c3e:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801c41:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801c44:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4e:	89 04 24             	mov    %eax,(%esp)
  801c51:	e8 88 fb ff ff       	call   8017de <fd_lookup>
  801c56:	89 c3                	mov    %eax,%ebx
  801c58:	85 c0                	test   %eax,%eax
  801c5a:	0f 88 e1 00 00 00    	js     801d41 <dup+0x10f>
		return r;
	close(newfdnum);
  801c60:	89 3c 24             	mov    %edi,(%esp)
  801c63:	e8 4d ff ff ff       	call   801bb5 <close>

	newfd = INDEX2FD(newfdnum);
  801c68:	89 f8                	mov    %edi,%eax
  801c6a:	c1 e0 0c             	shl    $0xc,%eax
  801c6d:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  801c73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c76:	89 04 24             	mov    %eax,(%esp)
  801c79:	e8 f2 fa ff ff       	call   801770 <fd2data>
  801c7e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801c80:	89 34 24             	mov    %esi,(%esp)
  801c83:	e8 e8 fa ff ff       	call   801770 <fd2data>
  801c88:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  801c8b:	89 d8                	mov    %ebx,%eax
  801c8d:	c1 e8 16             	shr    $0x16,%eax
  801c90:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c97:	a8 01                	test   $0x1,%al
  801c99:	74 45                	je     801ce0 <dup+0xae>
  801c9b:	89 da                	mov    %ebx,%edx
  801c9d:	c1 ea 0c             	shr    $0xc,%edx
  801ca0:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801ca7:	a8 01                	test   $0x1,%al
  801ca9:	74 35                	je     801ce0 <dup+0xae>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  801cab:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801cb2:	25 07 0e 00 00       	and    $0xe07,%eax
  801cb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  801cbb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cbe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cc2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cc9:	00 
  801cca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cd5:	e8 62 f7 ff ff       	call   80143c <sys_page_map>
  801cda:	89 c3                	mov    %eax,%ebx
  801cdc:	85 c0                	test   %eax,%eax
  801cde:	78 3e                	js     801d1e <dup+0xec>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  801ce0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ce3:	89 d0                	mov    %edx,%eax
  801ce5:	c1 e8 0c             	shr    $0xc,%eax
  801ce8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801cef:	25 07 0e 00 00       	and    $0xe07,%eax
  801cf4:	89 44 24 10          	mov    %eax,0x10(%esp)
  801cf8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801cfc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d03:	00 
  801d04:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d08:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d0f:	e8 28 f7 ff ff       	call   80143c <sys_page_map>
  801d14:	89 c3                	mov    %eax,%ebx
  801d16:	85 c0                	test   %eax,%eax
  801d18:	78 04                	js     801d1e <dup+0xec>
		goto err;
  801d1a:	89 fb                	mov    %edi,%ebx
  801d1c:	eb 23                	jmp    801d41 <dup+0x10f>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801d1e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d22:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d29:	e8 b0 f6 ff ff       	call   8013de <sys_page_unmap>
	sys_page_unmap(0, nva);
  801d2e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d31:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d3c:	e8 9d f6 ff ff       	call   8013de <sys_page_unmap>
	return r;
}
  801d41:	89 d8                	mov    %ebx,%eax
  801d43:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801d46:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801d49:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801d4c:	89 ec                	mov    %ebp,%esp
  801d4e:	5d                   	pop    %ebp
  801d4f:	c3                   	ret    

00801d50 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	53                   	push   %ebx
  801d54:	83 ec 04             	sub    $0x4,%esp
  801d57:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801d5c:	89 1c 24             	mov    %ebx,(%esp)
  801d5f:	e8 51 fe ff ff       	call   801bb5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801d64:	83 c3 01             	add    $0x1,%ebx
  801d67:	83 fb 20             	cmp    $0x20,%ebx
  801d6a:	75 f0                	jne    801d5c <close_all+0xc>
		close(i);
}
  801d6c:	83 c4 04             	add    $0x4,%esp
  801d6f:	5b                   	pop    %ebx
  801d70:	5d                   	pop    %ebp
  801d71:	c3                   	ret    
	...

00801d74 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801d74:	55                   	push   %ebp
  801d75:	89 e5                	mov    %esp,%ebp
  801d77:	53                   	push   %ebx
  801d78:	83 ec 14             	sub    $0x14,%esp
  801d7b:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801d7d:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801d83:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d8a:	00 
  801d8b:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801d92:	00 
  801d93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d97:	89 14 24             	mov    %edx,(%esp)
  801d9a:	e8 21 f8 ff ff       	call   8015c0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801d9f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801da6:	00 
  801da7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801db2:	e8 bd f8 ff ff       	call   801674 <ipc_recv>
}
  801db7:	83 c4 14             	add    $0x14,%esp
  801dba:	5b                   	pop    %ebx
  801dbb:	5d                   	pop    %ebp
  801dbc:	c3                   	ret    

00801dbd <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801dbd:	55                   	push   %ebp
  801dbe:	89 e5                	mov    %esp,%ebp
  801dc0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801dc3:	ba 00 00 00 00       	mov    $0x0,%edx
  801dc8:	b8 08 00 00 00       	mov    $0x8,%eax
  801dcd:	e8 a2 ff ff ff       	call   801d74 <fsipc>
}
  801dd2:	c9                   	leave  
  801dd3:	c3                   	ret    

00801dd4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801dd4:	55                   	push   %ebp
  801dd5:	89 e5                	mov    %esp,%ebp
  801dd7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801dda:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddd:	8b 40 0c             	mov    0xc(%eax),%eax
  801de0:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  801de5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de8:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ded:	ba 00 00 00 00       	mov    $0x0,%edx
  801df2:	b8 02 00 00 00       	mov    $0x2,%eax
  801df7:	e8 78 ff ff ff       	call   801d74 <fsipc>
}
  801dfc:	c9                   	leave  
  801dfd:	c3                   	ret    

00801dfe <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801dfe:	55                   	push   %ebp
  801dff:	89 e5                	mov    %esp,%ebp
  801e01:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801e04:	8b 45 08             	mov    0x8(%ebp),%eax
  801e07:	8b 40 0c             	mov    0xc(%eax),%eax
  801e0a:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  801e0f:	ba 00 00 00 00       	mov    $0x0,%edx
  801e14:	b8 06 00 00 00       	mov    $0x6,%eax
  801e19:	e8 56 ff ff ff       	call   801d74 <fsipc>
}
  801e1e:	c9                   	leave  
  801e1f:	c3                   	ret    

00801e20 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801e20:	55                   	push   %ebp
  801e21:	89 e5                	mov    %esp,%ebp
  801e23:	53                   	push   %ebx
  801e24:	83 ec 14             	sub    $0x14,%esp
  801e27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801e2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2d:	8b 40 0c             	mov    0xc(%eax),%eax
  801e30:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801e35:	ba 00 00 00 00       	mov    $0x0,%edx
  801e3a:	b8 05 00 00 00       	mov    $0x5,%eax
  801e3f:	e8 30 ff ff ff       	call   801d74 <fsipc>
  801e44:	85 c0                	test   %eax,%eax
  801e46:	78 2b                	js     801e73 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801e48:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801e4f:	00 
  801e50:	89 1c 24             	mov    %ebx,(%esp)
  801e53:	e8 09 ef ff ff       	call   800d61 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801e58:	a1 80 30 80 00       	mov    0x803080,%eax
  801e5d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801e63:	a1 84 30 80 00       	mov    0x803084,%eax
  801e68:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801e6e:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801e73:	83 c4 14             	add    $0x14,%esp
  801e76:	5b                   	pop    %ebx
  801e77:	5d                   	pop    %ebp
  801e78:	c3                   	ret    

00801e79 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801e79:	55                   	push   %ebp
  801e7a:	89 e5                	mov    %esp,%ebp
  801e7c:	83 ec 18             	sub    $0x18,%esp
  801e7f:	8b 55 10             	mov    0x10(%ebp),%edx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	ssize_t writesize;
	size_t bufsize;
	fsipcbuf.write.req_fileid=fd->fd_file.id;
  801e82:	8b 45 08             	mov    0x8(%ebp),%eax
  801e85:	8b 40 0c             	mov    0xc(%eax),%eax
  801e88:	a3 00 30 80 00       	mov    %eax,0x803000
	bufsize=sizeof(fsipcbuf.write.req_buf);
	if(n<bufsize)
  801e8d:	89 d0                	mov    %edx,%eax
  801e8f:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  801e95:	76 05                	jbe    801e9c <devfile_write+0x23>
  801e97:	b8 f8 0f 00 00       	mov    $0xff8,%eax
		bufsize=n;	
	fsipcbuf.write.req_n=n;
  801e9c:	89 15 04 30 80 00    	mov    %edx,0x803004
	memmove((void*)fsipcbuf.write.req_buf,buf,bufsize);
  801ea2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ead:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801eb4:	e8 af f0 ff ff       	call   800f68 <memmove>
	writesize=(ssize_t)fsipc(FSREQ_WRITE,NULL);
  801eb9:	ba 00 00 00 00       	mov    $0x0,%edx
  801ebe:	b8 04 00 00 00       	mov    $0x4,%eax
  801ec3:	e8 ac fe ff ff       	call   801d74 <fsipc>
	return writesize;
	//panic("devfile_write not implemented");
}
  801ec8:	c9                   	leave  
  801ec9:	c3                   	ret    

00801eca <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801eca:	55                   	push   %ebp
  801ecb:	89 e5                	mov    %esp,%ebp
  801ecd:	53                   	push   %ebx
  801ece:	83 ec 14             	sub    $0x14,%esp
	// system server.
	// LAB 5: Your code here
	ssize_t readsize;
	if(debug)
		cprintf("devfile_read:fileid=%x readsize=%x\n",fd->fd_file.id,n);
	fsipcbuf.read.req_fileid=fd->fd_file.id;
  801ed1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed4:	8b 40 0c             	mov    0xc(%eax),%eax
  801ed7:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n=n;
  801edc:	8b 45 10             	mov    0x10(%ebp),%eax
  801edf:	a3 04 30 80 00       	mov    %eax,0x803004
	readsize=(ssize_t)fsipc(FSREQ_READ,&fsipcbuf);
  801ee4:	ba 00 30 80 00       	mov    $0x803000,%edx
  801ee9:	b8 03 00 00 00       	mov    $0x3,%eax
  801eee:	e8 81 fe ff ff       	call   801d74 <fsipc>
  801ef3:	89 c3                	mov    %eax,%ebx
	//cprintf("readsize=%d\n",readsize);
	if(debug)
		cprintf("devfile_read:buf1=%s\nbuf2=%s\n",(char*)&fsipcbuf,fsipcbuf.readRet.ret_buf);
	if(readsize>0)
  801ef5:	85 c0                	test   %eax,%eax
  801ef7:	7e 17                	jle    801f10 <devfile_read+0x46>
		memmove(buf,(void*)&fsipcbuf,(size_t)readsize);
  801ef9:	89 44 24 08          	mov    %eax,0x8(%esp)
  801efd:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801f04:	00 
  801f05:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f08:	89 04 24             	mov    %eax,(%esp)
  801f0b:	e8 58 f0 ff ff       	call   800f68 <memmove>
	//cprintf("readsize=%d",readsize);
	return readsize;
	//panic("devfile_read not implemented");
}
  801f10:	89 d8                	mov    %ebx,%eax
  801f12:	83 c4 14             	add    $0x14,%esp
  801f15:	5b                   	pop    %ebx
  801f16:	5d                   	pop    %ebp
  801f17:	c3                   	ret    

00801f18 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801f18:	55                   	push   %ebp
  801f19:	89 e5                	mov    %esp,%ebp
  801f1b:	53                   	push   %ebx
  801f1c:	83 ec 14             	sub    $0x14,%esp
  801f1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801f22:	89 1c 24             	mov    %ebx,(%esp)
  801f25:	e8 e6 ed ff ff       	call   800d10 <strlen>
  801f2a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  801f2f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801f34:	7f 21                	jg     801f57 <remove+0x3f>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801f36:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f3a:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801f41:	e8 1b ee ff ff       	call   800d61 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801f46:	ba 00 00 00 00       	mov    $0x0,%edx
  801f4b:	b8 07 00 00 00       	mov    $0x7,%eax
  801f50:	e8 1f fe ff ff       	call   801d74 <fsipc>
  801f55:	89 c2                	mov    %eax,%edx
}
  801f57:	89 d0                	mov    %edx,%eax
  801f59:	83 c4 14             	add    $0x14,%esp
  801f5c:	5b                   	pop    %ebx
  801f5d:	5d                   	pop    %ebp
  801f5e:	c3                   	ret    

00801f5f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801f5f:	55                   	push   %ebp
  801f60:	89 e5                	mov    %esp,%ebp
  801f62:	56                   	push   %esi
  801f63:	53                   	push   %ebx
  801f64:	83 ec 30             	sub    $0x30,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;
	void *page;
	if((r=fd_alloc(&fd))<0){
  801f67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f6a:	89 04 24             	mov    %eax,(%esp)
  801f6d:	e8 19 f8 ff ff       	call   80178b <fd_alloc>
  801f72:	89 c3                	mov    %eax,%ebx
  801f74:	85 c0                	test   %eax,%eax
  801f76:	79 18                	jns    801f90 <open+0x31>
		fd_close(fd,0);
  801f78:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f7f:	00 
  801f80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f83:	89 04 24             	mov    %eax,(%esp)
  801f86:	e8 a3 fb ff ff       	call   801b2e <fd_close>
  801f8b:	e9 9f 00 00 00       	jmp    80202f <open+0xd0>
		return r;
	}
	//cprintf("open:fd=%x\n",fd);
	strcpy(fsipcbuf.open.req_path,path);
  801f90:	8b 45 08             	mov    0x8(%ebp),%eax
  801f93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f97:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801f9e:	e8 be ed ff ff       	call   800d61 <strcpy>
	fsipcbuf.open.req_omode=mode;
  801fa3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa6:	a3 00 34 80 00       	mov    %eax,0x803400
	page=(void*)fd2data(fd);
  801fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fae:	89 04 24             	mov    %eax,(%esp)
  801fb1:	e8 ba f7 ff ff       	call   801770 <fd2data>
  801fb6:	89 c6                	mov    %eax,%esi
	if((r=fsipc(FSREQ_OPEN,(void*)fd))<0)
  801fb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fbb:	b8 01 00 00 00       	mov    $0x1,%eax
  801fc0:	e8 af fd ff ff       	call   801d74 <fsipc>
  801fc5:	89 c3                	mov    %eax,%ebx
  801fc7:	85 c0                	test   %eax,%eax
  801fc9:	79 15                	jns    801fe0 <open+0x81>
	{
		fd_close(fd,1);
  801fcb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801fd2:	00 
  801fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd6:	89 04 24             	mov    %eax,(%esp)
  801fd9:	e8 50 fb ff ff       	call   801b2e <fd_close>
  801fde:	eb 4f                	jmp    80202f <open+0xd0>
		return r;	
	}
	//cprintf("open:page=%x\n",page);
	if((r=sys_page_map(0,(void*)fd,0,(void*)page,PTE_P | PTE_W | PTE_U))<0)
  801fe0:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801fe7:	00 
  801fe8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801fec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ff3:	00 
  801ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ffb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802002:	e8 35 f4 ff ff       	call   80143c <sys_page_map>
  802007:	89 c3                	mov    %eax,%ebx
  802009:	85 c0                	test   %eax,%eax
  80200b:	79 15                	jns    802022 <open+0xc3>
	{
		fd_close(fd,1);
  80200d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802014:	00 
  802015:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802018:	89 04 24             	mov    %eax,(%esp)
  80201b:	e8 0e fb ff ff       	call   801b2e <fd_close>
  802020:	eb 0d                	jmp    80202f <open+0xd0>
		return r;
	}
	//cprintf("open:fileid=%x\n",fd->fd_file.id);
	return fd2num(fd);
  802022:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802025:	89 04 24             	mov    %eax,(%esp)
  802028:	e8 33 f7 ff ff       	call   801760 <fd2num>
  80202d:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  80202f:	89 d8                	mov    %ebx,%eax
  802031:	83 c4 30             	add    $0x30,%esp
  802034:	5b                   	pop    %ebx
  802035:	5e                   	pop    %esi
  802036:	5d                   	pop    %ebp
  802037:	c3                   	ret    
	...

00802040 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802040:	55                   	push   %ebp
  802041:	89 e5                	mov    %esp,%ebp
  802043:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  802046:	c7 44 24 04 fc 2e 80 	movl   $0x802efc,0x4(%esp)
  80204d:	00 
  80204e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802051:	89 04 24             	mov    %eax,(%esp)
  802054:	e8 08 ed ff ff       	call   800d61 <strcpy>
	return 0;
}
  802059:	b8 00 00 00 00       	mov    $0x0,%eax
  80205e:	c9                   	leave  
  80205f:	c3                   	ret    

00802060 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	83 ec 08             	sub    $0x8,%esp
	return nsipc_close(fd->fd_sock.sockid);
  802066:	8b 45 08             	mov    0x8(%ebp),%eax
  802069:	8b 40 0c             	mov    0xc(%eax),%eax
  80206c:	89 04 24             	mov    %eax,(%esp)
  80206f:	e8 9e 02 00 00       	call   802312 <nsipc_close>
}
  802074:	c9                   	leave  
  802075:	c3                   	ret    

00802076 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802076:	55                   	push   %ebp
  802077:	89 e5                	mov    %esp,%ebp
  802079:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80207c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802083:	00 
  802084:	8b 45 10             	mov    0x10(%ebp),%eax
  802087:	89 44 24 08          	mov    %eax,0x8(%esp)
  80208b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80208e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802092:	8b 45 08             	mov    0x8(%ebp),%eax
  802095:	8b 40 0c             	mov    0xc(%eax),%eax
  802098:	89 04 24             	mov    %eax,(%esp)
  80209b:	e8 ae 02 00 00       	call   80234e <nsipc_send>
}
  8020a0:	c9                   	leave  
  8020a1:	c3                   	ret    

008020a2 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8020a2:	55                   	push   %ebp
  8020a3:	89 e5                	mov    %esp,%ebp
  8020a5:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8020a8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8020af:	00 
  8020b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8020b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020be:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8020c4:	89 04 24             	mov    %eax,(%esp)
  8020c7:	e8 f5 02 00 00       	call   8023c1 <nsipc_recv>
}
  8020cc:	c9                   	leave  
  8020cd:	c3                   	ret    

008020ce <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8020ce:	55                   	push   %ebp
  8020cf:	89 e5                	mov    %esp,%ebp
  8020d1:	56                   	push   %esi
  8020d2:	53                   	push   %ebx
  8020d3:	83 ec 20             	sub    $0x20,%esp
  8020d6:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8020d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020db:	89 04 24             	mov    %eax,(%esp)
  8020de:	e8 a8 f6 ff ff       	call   80178b <fd_alloc>
  8020e3:	89 c3                	mov    %eax,%ebx
  8020e5:	85 c0                	test   %eax,%eax
  8020e7:	78 21                	js     80210a <alloc_sockfd+0x3c>
  8020e9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8020f0:	00 
  8020f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020ff:	e8 96 f3 ff ff       	call   80149a <sys_page_alloc>
  802104:	89 c3                	mov    %eax,%ebx
  802106:	85 c0                	test   %eax,%eax
  802108:	79 0a                	jns    802114 <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U)) < 0) {
		nsipc_close(sockid);
  80210a:	89 34 24             	mov    %esi,(%esp)
  80210d:	e8 00 02 00 00       	call   802312 <nsipc_close>
  802112:	eb 28                	jmp    80213c <alloc_sockfd+0x6e>
		return r;
	}

	sfd->fd_dev_id = devsock.dev_id;
  802114:	8b 15 24 60 80 00    	mov    0x806024,%edx
  80211a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80211d:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80211f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802122:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802129:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80212f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802132:	89 04 24             	mov    %eax,(%esp)
  802135:	e8 26 f6 ff ff       	call   801760 <fd2num>
  80213a:	89 c3                	mov    %eax,%ebx
}
  80213c:	89 d8                	mov    %ebx,%eax
  80213e:	83 c4 20             	add    $0x20,%esp
  802141:	5b                   	pop    %ebx
  802142:	5e                   	pop    %esi
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    

00802145 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802145:	55                   	push   %ebp
  802146:	89 e5                	mov    %esp,%ebp
  802148:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80214b:	8b 45 10             	mov    0x10(%ebp),%eax
  80214e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802152:	8b 45 0c             	mov    0xc(%ebp),%eax
  802155:	89 44 24 04          	mov    %eax,0x4(%esp)
  802159:	8b 45 08             	mov    0x8(%ebp),%eax
  80215c:	89 04 24             	mov    %eax,(%esp)
  80215f:	e8 62 01 00 00       	call   8022c6 <nsipc_socket>
  802164:	85 c0                	test   %eax,%eax
  802166:	78 05                	js     80216d <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802168:	e8 61 ff ff ff       	call   8020ce <alloc_sockfd>
}
  80216d:	c9                   	leave  
  80216e:	66 90                	xchg   %ax,%ax
  802170:	c3                   	ret    

00802171 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802171:	55                   	push   %ebp
  802172:	89 e5                	mov    %esp,%ebp
  802174:	83 ec 18             	sub    $0x18,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802177:	8d 55 fc             	lea    -0x4(%ebp),%edx
  80217a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80217e:	89 04 24             	mov    %eax,(%esp)
  802181:	e8 58 f6 ff ff       	call   8017de <fd_lookup>
  802186:	89 c2                	mov    %eax,%edx
  802188:	85 c0                	test   %eax,%eax
  80218a:	78 15                	js     8021a1 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80218c:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  80218f:	8b 01                	mov    (%ecx),%eax
  802191:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  802196:	3b 05 24 60 80 00    	cmp    0x806024,%eax
  80219c:	75 03                	jne    8021a1 <fd2sockid+0x30>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80219e:	8b 51 0c             	mov    0xc(%ecx),%edx
}
  8021a1:	89 d0                	mov    %edx,%eax
  8021a3:	c9                   	leave  
  8021a4:	c3                   	ret    

008021a5 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  8021a5:	55                   	push   %ebp
  8021a6:	89 e5                	mov    %esp,%ebp
  8021a8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ae:	e8 be ff ff ff       	call   802171 <fd2sockid>
  8021b3:	85 c0                	test   %eax,%eax
  8021b5:	78 0f                	js     8021c6 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8021b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021ba:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021be:	89 04 24             	mov    %eax,(%esp)
  8021c1:	e8 2a 01 00 00       	call   8022f0 <nsipc_listen>
}
  8021c6:	c9                   	leave  
  8021c7:	c3                   	ret    

008021c8 <connect>:
	return nsipc_close(fd->fd_sock.sockid);
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8021c8:	55                   	push   %ebp
  8021c9:	89 e5                	mov    %esp,%ebp
  8021cb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d1:	e8 9b ff ff ff       	call   802171 <fd2sockid>
  8021d6:	85 c0                	test   %eax,%eax
  8021d8:	78 16                	js     8021f0 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8021da:	8b 55 10             	mov    0x10(%ebp),%edx
  8021dd:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021e4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021e8:	89 04 24             	mov    %eax,(%esp)
  8021eb:	e8 51 02 00 00       	call   802441 <nsipc_connect>
}
  8021f0:	c9                   	leave  
  8021f1:	c3                   	ret    

008021f2 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  8021f2:	55                   	push   %ebp
  8021f3:	89 e5                	mov    %esp,%ebp
  8021f5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021fb:	e8 71 ff ff ff       	call   802171 <fd2sockid>
  802200:	85 c0                	test   %eax,%eax
  802202:	78 0f                	js     802213 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802204:	8b 55 0c             	mov    0xc(%ebp),%edx
  802207:	89 54 24 04          	mov    %edx,0x4(%esp)
  80220b:	89 04 24             	mov    %eax,(%esp)
  80220e:	e8 19 01 00 00       	call   80232c <nsipc_shutdown>
}
  802213:	c9                   	leave  
  802214:	c3                   	ret    

00802215 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802215:	55                   	push   %ebp
  802216:	89 e5                	mov    %esp,%ebp
  802218:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80221b:	8b 45 08             	mov    0x8(%ebp),%eax
  80221e:	e8 4e ff ff ff       	call   802171 <fd2sockid>
  802223:	85 c0                	test   %eax,%eax
  802225:	78 16                	js     80223d <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  802227:	8b 55 10             	mov    0x10(%ebp),%edx
  80222a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80222e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802231:	89 54 24 04          	mov    %edx,0x4(%esp)
  802235:	89 04 24             	mov    %eax,(%esp)
  802238:	e8 43 02 00 00       	call   802480 <nsipc_bind>
}
  80223d:	c9                   	leave  
  80223e:	c3                   	ret    

0080223f <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80223f:	55                   	push   %ebp
  802240:	89 e5                	mov    %esp,%ebp
  802242:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802245:	8b 45 08             	mov    0x8(%ebp),%eax
  802248:	e8 24 ff ff ff       	call   802171 <fd2sockid>
  80224d:	85 c0                	test   %eax,%eax
  80224f:	78 1f                	js     802270 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802251:	8b 55 10             	mov    0x10(%ebp),%edx
  802254:	89 54 24 08          	mov    %edx,0x8(%esp)
  802258:	8b 55 0c             	mov    0xc(%ebp),%edx
  80225b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80225f:	89 04 24             	mov    %eax,(%esp)
  802262:	e8 58 02 00 00       	call   8024bf <nsipc_accept>
  802267:	85 c0                	test   %eax,%eax
  802269:	78 05                	js     802270 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80226b:	e8 5e fe ff ff       	call   8020ce <alloc_sockfd>
}
  802270:	c9                   	leave  
  802271:	c3                   	ret    
	...

00802280 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802280:	55                   	push   %ebp
  802281:	89 e5                	mov    %esp,%ebp
  802283:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802286:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  80228c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802293:	00 
  802294:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80229b:	00 
  80229c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a0:	89 14 24             	mov    %edx,(%esp)
  8022a3:	e8 18 f3 ff ff       	call   8015c0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8022a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8022af:	00 
  8022b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8022b7:	00 
  8022b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022bf:	e8 b0 f3 ff ff       	call   801674 <ipc_recv>
}
  8022c4:	c9                   	leave  
  8022c5:	c3                   	ret    

008022c6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  8022c6:	55                   	push   %ebp
  8022c7:	89 e5                	mov    %esp,%ebp
  8022c9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8022cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8022cf:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.socket.req_type = type;
  8022d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022d7:	a3 04 50 80 00       	mov    %eax,0x805004
	nsipcbuf.socket.req_protocol = protocol;
  8022dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8022df:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SOCKET);
  8022e4:	b8 09 00 00 00       	mov    $0x9,%eax
  8022e9:	e8 92 ff ff ff       	call   802280 <nsipc>
}
  8022ee:	c9                   	leave  
  8022ef:	c3                   	ret    

008022f0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  8022f0:	55                   	push   %ebp
  8022f1:	89 e5                	mov    %esp,%ebp
  8022f3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8022f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f9:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.listen.req_backlog = backlog;
  8022fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  802301:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_LISTEN);
  802306:	b8 06 00 00 00       	mov    $0x6,%eax
  80230b:	e8 70 ff ff ff       	call   802280 <nsipc>
}
  802310:	c9                   	leave  
  802311:	c3                   	ret    

00802312 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802312:	55                   	push   %ebp
  802313:	89 e5                	mov    %esp,%ebp
  802315:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802318:	8b 45 08             	mov    0x8(%ebp),%eax
  80231b:	a3 00 50 80 00       	mov    %eax,0x805000
	return nsipc(NSREQ_CLOSE);
  802320:	b8 04 00 00 00       	mov    $0x4,%eax
  802325:	e8 56 ff ff ff       	call   802280 <nsipc>
}
  80232a:	c9                   	leave  
  80232b:	c3                   	ret    

0080232c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80232c:	55                   	push   %ebp
  80232d:	89 e5                	mov    %esp,%ebp
  80232f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802332:	8b 45 08             	mov    0x8(%ebp),%eax
  802335:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.shutdown.req_how = how;
  80233a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80233d:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_SHUTDOWN);
  802342:	b8 03 00 00 00       	mov    $0x3,%eax
  802347:	e8 34 ff ff ff       	call   802280 <nsipc>
}
  80234c:	c9                   	leave  
  80234d:	c3                   	ret    

0080234e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80234e:	55                   	push   %ebp
  80234f:	89 e5                	mov    %esp,%ebp
  802351:	53                   	push   %ebx
  802352:	83 ec 14             	sub    $0x14,%esp
  802355:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802358:	8b 45 08             	mov    0x8(%ebp),%eax
  80235b:	a3 00 50 80 00       	mov    %eax,0x805000
	assert(size < 1600);
  802360:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802366:	7e 24                	jle    80238c <nsipc_send+0x3e>
  802368:	c7 44 24 0c 08 2f 80 	movl   $0x802f08,0xc(%esp)
  80236f:	00 
  802370:	c7 44 24 08 14 2f 80 	movl   $0x802f14,0x8(%esp)
  802377:	00 
  802378:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  80237f:	00 
  802380:	c7 04 24 29 2f 80 00 	movl   $0x802f29,(%esp)
  802387:	e8 9c e2 ff ff       	call   800628 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80238c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802390:	8b 45 0c             	mov    0xc(%ebp),%eax
  802393:	89 44 24 04          	mov    %eax,0x4(%esp)
  802397:	c7 04 24 0c 50 80 00 	movl   $0x80500c,(%esp)
  80239e:	e8 c5 eb ff ff       	call   800f68 <memmove>
	nsipcbuf.send.req_size = size;
  8023a3:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	nsipcbuf.send.req_flags = flags;
  8023a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8023ac:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SEND);
  8023b1:	b8 08 00 00 00       	mov    $0x8,%eax
  8023b6:	e8 c5 fe ff ff       	call   802280 <nsipc>
}
  8023bb:	83 c4 14             	add    $0x14,%esp
  8023be:	5b                   	pop    %ebx
  8023bf:	5d                   	pop    %ebp
  8023c0:	c3                   	ret    

008023c1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8023c1:	55                   	push   %ebp
  8023c2:	89 e5                	mov    %esp,%ebp
  8023c4:	56                   	push   %esi
  8023c5:	53                   	push   %ebx
  8023c6:	83 ec 10             	sub    $0x10,%esp
  8023c9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8023cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8023cf:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.recv.req_len = len;
  8023d4:	89 35 04 50 80 00    	mov    %esi,0x805004
	nsipcbuf.recv.req_flags = flags;
  8023da:	8b 45 14             	mov    0x14(%ebp),%eax
  8023dd:	a3 08 50 80 00       	mov    %eax,0x805008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8023e2:	b8 07 00 00 00       	mov    $0x7,%eax
  8023e7:	e8 94 fe ff ff       	call   802280 <nsipc>
  8023ec:	89 c3                	mov    %eax,%ebx
  8023ee:	85 c0                	test   %eax,%eax
  8023f0:	78 46                	js     802438 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8023f2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8023f7:	7f 04                	jg     8023fd <nsipc_recv+0x3c>
  8023f9:	39 c6                	cmp    %eax,%esi
  8023fb:	7d 24                	jge    802421 <nsipc_recv+0x60>
  8023fd:	c7 44 24 0c 35 2f 80 	movl   $0x802f35,0xc(%esp)
  802404:	00 
  802405:	c7 44 24 08 14 2f 80 	movl   $0x802f14,0x8(%esp)
  80240c:	00 
  80240d:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  802414:	00 
  802415:	c7 04 24 29 2f 80 00 	movl   $0x802f29,(%esp)
  80241c:	e8 07 e2 ff ff       	call   800628 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802421:	89 44 24 08          	mov    %eax,0x8(%esp)
  802425:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80242c:	00 
  80242d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802430:	89 04 24             	mov    %eax,(%esp)
  802433:	e8 30 eb ff ff       	call   800f68 <memmove>
	}

	return r;
}
  802438:	89 d8                	mov    %ebx,%eax
  80243a:	83 c4 10             	add    $0x10,%esp
  80243d:	5b                   	pop    %ebx
  80243e:	5e                   	pop    %esi
  80243f:	5d                   	pop    %ebp
  802440:	c3                   	ret    

00802441 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802441:	55                   	push   %ebp
  802442:	89 e5                	mov    %esp,%ebp
  802444:	53                   	push   %ebx
  802445:	83 ec 14             	sub    $0x14,%esp
  802448:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80244b:	8b 45 08             	mov    0x8(%ebp),%eax
  80244e:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802453:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802457:	8b 45 0c             	mov    0xc(%ebp),%eax
  80245a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80245e:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  802465:	e8 fe ea ff ff       	call   800f68 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80246a:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_CONNECT);
  802470:	b8 05 00 00 00       	mov    $0x5,%eax
  802475:	e8 06 fe ff ff       	call   802280 <nsipc>
}
  80247a:	83 c4 14             	add    $0x14,%esp
  80247d:	5b                   	pop    %ebx
  80247e:	5d                   	pop    %ebp
  80247f:	c3                   	ret    

00802480 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802480:	55                   	push   %ebp
  802481:	89 e5                	mov    %esp,%ebp
  802483:	53                   	push   %ebx
  802484:	83 ec 14             	sub    $0x14,%esp
  802487:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80248a:	8b 45 08             	mov    0x8(%ebp),%eax
  80248d:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802492:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802496:	8b 45 0c             	mov    0xc(%ebp),%eax
  802499:	89 44 24 04          	mov    %eax,0x4(%esp)
  80249d:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  8024a4:	e8 bf ea ff ff       	call   800f68 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8024a9:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_BIND);
  8024af:	b8 02 00 00 00       	mov    $0x2,%eax
  8024b4:	e8 c7 fd ff ff       	call   802280 <nsipc>
}
  8024b9:	83 c4 14             	add    $0x14,%esp
  8024bc:	5b                   	pop    %ebx
  8024bd:	5d                   	pop    %ebp
  8024be:	c3                   	ret    

008024bf <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8024bf:	55                   	push   %ebp
  8024c0:	89 e5                	mov    %esp,%ebp
  8024c2:	53                   	push   %ebx
  8024c3:	83 ec 14             	sub    $0x14,%esp
	int r;
	
	nsipcbuf.accept.req_s = s;
  8024c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8024c9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8024ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8024d3:	e8 a8 fd ff ff       	call   802280 <nsipc>
  8024d8:	89 c3                	mov    %eax,%ebx
  8024da:	85 c0                	test   %eax,%eax
  8024dc:	78 26                	js     802504 <nsipc_accept+0x45>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8024de:	a1 10 50 80 00       	mov    0x805010,%eax
  8024e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024e7:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8024ee:	00 
  8024ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024f2:	89 04 24             	mov    %eax,(%esp)
  8024f5:	e8 6e ea ff ff       	call   800f68 <memmove>
		*addrlen = ret->ret_addrlen;
  8024fa:	a1 10 50 80 00       	mov    0x805010,%eax
  8024ff:	8b 55 10             	mov    0x10(%ebp),%edx
  802502:	89 02                	mov    %eax,(%edx)
	}
	return r;
}
  802504:	89 d8                	mov    %ebx,%eax
  802506:	83 c4 14             	add    $0x14,%esp
  802509:	5b                   	pop    %ebx
  80250a:	5d                   	pop    %ebp
  80250b:	c3                   	ret    
  80250c:	00 00                	add    %al,(%eax)
	...

00802510 <__udivdi3>:
  802510:	55                   	push   %ebp
  802511:	89 e5                	mov    %esp,%ebp
  802513:	57                   	push   %edi
  802514:	56                   	push   %esi
  802515:	83 ec 18             	sub    $0x18,%esp
  802518:	8b 45 10             	mov    0x10(%ebp),%eax
  80251b:	8b 55 14             	mov    0x14(%ebp),%edx
  80251e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802521:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802524:	89 c1                	mov    %eax,%ecx
  802526:	8b 45 08             	mov    0x8(%ebp),%eax
  802529:	85 d2                	test   %edx,%edx
  80252b:	89 d7                	mov    %edx,%edi
  80252d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802530:	75 1e                	jne    802550 <__udivdi3+0x40>
  802532:	39 f1                	cmp    %esi,%ecx
  802534:	0f 86 8d 00 00 00    	jbe    8025c7 <__udivdi3+0xb7>
  80253a:	89 f2                	mov    %esi,%edx
  80253c:	31 f6                	xor    %esi,%esi
  80253e:	f7 f1                	div    %ecx
  802540:	89 c1                	mov    %eax,%ecx
  802542:	89 c8                	mov    %ecx,%eax
  802544:	89 f2                	mov    %esi,%edx
  802546:	83 c4 18             	add    $0x18,%esp
  802549:	5e                   	pop    %esi
  80254a:	5f                   	pop    %edi
  80254b:	5d                   	pop    %ebp
  80254c:	c3                   	ret    
  80254d:	8d 76 00             	lea    0x0(%esi),%esi
  802550:	39 f2                	cmp    %esi,%edx
  802552:	0f 87 a8 00 00 00    	ja     802600 <__udivdi3+0xf0>
  802558:	0f bd c2             	bsr    %edx,%eax
  80255b:	83 f0 1f             	xor    $0x1f,%eax
  80255e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802561:	0f 84 89 00 00 00    	je     8025f0 <__udivdi3+0xe0>
  802567:	b8 20 00 00 00       	mov    $0x20,%eax
  80256c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80256f:	2b 45 e8             	sub    -0x18(%ebp),%eax
  802572:	89 c1                	mov    %eax,%ecx
  802574:	d3 ea                	shr    %cl,%edx
  802576:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  80257a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80257d:	89 f8                	mov    %edi,%eax
  80257f:	8b 7d f4             	mov    -0xc(%ebp),%edi
  802582:	d3 e0                	shl    %cl,%eax
  802584:	09 c2                	or     %eax,%edx
  802586:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802589:	d3 e7                	shl    %cl,%edi
  80258b:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80258f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802592:	89 f2                	mov    %esi,%edx
  802594:	d3 e8                	shr    %cl,%eax
  802596:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  80259a:	d3 e2                	shl    %cl,%edx
  80259c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8025a0:	09 d0                	or     %edx,%eax
  8025a2:	d3 ee                	shr    %cl,%esi
  8025a4:	89 f2                	mov    %esi,%edx
  8025a6:	f7 75 e4             	divl   -0x1c(%ebp)
  8025a9:	89 d1                	mov    %edx,%ecx
  8025ab:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8025ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8025b1:	f7 e7                	mul    %edi
  8025b3:	39 d1                	cmp    %edx,%ecx
  8025b5:	89 c6                	mov    %eax,%esi
  8025b7:	72 70                	jb     802629 <__udivdi3+0x119>
  8025b9:	39 ca                	cmp    %ecx,%edx
  8025bb:	74 5f                	je     80261c <__udivdi3+0x10c>
  8025bd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8025c0:	31 f6                	xor    %esi,%esi
  8025c2:	e9 7b ff ff ff       	jmp    802542 <__udivdi3+0x32>
  8025c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025ca:	85 c0                	test   %eax,%eax
  8025cc:	75 0c                	jne    8025da <__udivdi3+0xca>
  8025ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8025d3:	31 d2                	xor    %edx,%edx
  8025d5:	f7 75 f4             	divl   -0xc(%ebp)
  8025d8:	89 c1                	mov    %eax,%ecx
  8025da:	89 f0                	mov    %esi,%eax
  8025dc:	89 fa                	mov    %edi,%edx
  8025de:	f7 f1                	div    %ecx
  8025e0:	89 c6                	mov    %eax,%esi
  8025e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8025e5:	f7 f1                	div    %ecx
  8025e7:	89 c1                	mov    %eax,%ecx
  8025e9:	e9 54 ff ff ff       	jmp    802542 <__udivdi3+0x32>
  8025ee:	66 90                	xchg   %ax,%ax
  8025f0:	39 d6                	cmp    %edx,%esi
  8025f2:	77 1c                	ja     802610 <__udivdi3+0x100>
  8025f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8025f7:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  8025fa:	73 14                	jae    802610 <__udivdi3+0x100>
  8025fc:	8d 74 26 00          	lea    0x0(%esi),%esi
  802600:	31 c9                	xor    %ecx,%ecx
  802602:	31 f6                	xor    %esi,%esi
  802604:	e9 39 ff ff ff       	jmp    802542 <__udivdi3+0x32>
  802609:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  802610:	b9 01 00 00 00       	mov    $0x1,%ecx
  802615:	31 f6                	xor    %esi,%esi
  802617:	e9 26 ff ff ff       	jmp    802542 <__udivdi3+0x32>
  80261c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80261f:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  802623:	d3 e0                	shl    %cl,%eax
  802625:	39 c6                	cmp    %eax,%esi
  802627:	76 94                	jbe    8025bd <__udivdi3+0xad>
  802629:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80262c:	31 f6                	xor    %esi,%esi
  80262e:	83 e9 01             	sub    $0x1,%ecx
  802631:	e9 0c ff ff ff       	jmp    802542 <__udivdi3+0x32>
	...

00802640 <__umoddi3>:
  802640:	55                   	push   %ebp
  802641:	89 e5                	mov    %esp,%ebp
  802643:	57                   	push   %edi
  802644:	56                   	push   %esi
  802645:	83 ec 30             	sub    $0x30,%esp
  802648:	8b 45 10             	mov    0x10(%ebp),%eax
  80264b:	8b 55 14             	mov    0x14(%ebp),%edx
  80264e:	8b 75 08             	mov    0x8(%ebp),%esi
  802651:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802654:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802657:	89 c1                	mov    %eax,%ecx
  802659:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80265c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80265f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  802666:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80266d:	89 fa                	mov    %edi,%edx
  80266f:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  802672:	85 c0                	test   %eax,%eax
  802674:	89 75 f0             	mov    %esi,-0x10(%ebp)
  802677:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80267a:	75 14                	jne    802690 <__umoddi3+0x50>
  80267c:	39 f9                	cmp    %edi,%ecx
  80267e:	76 60                	jbe    8026e0 <__umoddi3+0xa0>
  802680:	89 f0                	mov    %esi,%eax
  802682:	f7 f1                	div    %ecx
  802684:	89 55 d0             	mov    %edx,-0x30(%ebp)
  802687:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80268e:	eb 10                	jmp    8026a0 <__umoddi3+0x60>
  802690:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802693:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  802696:	76 18                	jbe    8026b0 <__umoddi3+0x70>
  802698:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80269b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80269e:	66 90                	xchg   %ax,%ax
  8026a0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8026a3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8026a6:	83 c4 30             	add    $0x30,%esp
  8026a9:	5e                   	pop    %esi
  8026aa:	5f                   	pop    %edi
  8026ab:	5d                   	pop    %ebp
  8026ac:	c3                   	ret    
  8026ad:	8d 76 00             	lea    0x0(%esi),%esi
  8026b0:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
  8026b4:	83 f0 1f             	xor    $0x1f,%eax
  8026b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8026ba:	75 46                	jne    802702 <__umoddi3+0xc2>
  8026bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8026bf:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  8026c2:	0f 87 c9 00 00 00    	ja     802791 <__umoddi3+0x151>
  8026c8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  8026cb:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8026ce:	0f 83 bd 00 00 00    	jae    802791 <__umoddi3+0x151>
  8026d4:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8026d7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8026da:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8026dd:	eb c1                	jmp    8026a0 <__umoddi3+0x60>
  8026df:	90                   	nop    
  8026e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8026e3:	85 c0                	test   %eax,%eax
  8026e5:	75 0c                	jne    8026f3 <__umoddi3+0xb3>
  8026e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8026ec:	31 d2                	xor    %edx,%edx
  8026ee:	f7 75 ec             	divl   -0x14(%ebp)
  8026f1:	89 c1                	mov    %eax,%ecx
  8026f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8026f6:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8026f9:	f7 f1                	div    %ecx
  8026fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8026fe:	f7 f1                	div    %ecx
  802700:	eb 82                	jmp    802684 <__umoddi3+0x44>
  802702:	b8 20 00 00 00       	mov    $0x20,%eax
  802707:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80270a:	2b 45 d8             	sub    -0x28(%ebp),%eax
  80270d:	8b 75 ec             	mov    -0x14(%ebp),%esi
  802710:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802713:	89 c1                	mov    %eax,%ecx
  802715:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802718:	d3 ea                	shr    %cl,%edx
  80271a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80271d:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  802721:	d3 e0                	shl    %cl,%eax
  802723:	09 c2                	or     %eax,%edx
  802725:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802728:	d3 e6                	shl    %cl,%esi
  80272a:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  80272e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802731:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802734:	d3 e8                	shr    %cl,%eax
  802736:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  80273a:	d3 e2                	shl    %cl,%edx
  80273c:	09 d0                	or     %edx,%eax
  80273e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802741:	d3 e7                	shl    %cl,%edi
  802743:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  802747:	d3 ea                	shr    %cl,%edx
  802749:	f7 75 f4             	divl   -0xc(%ebp)
  80274c:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80274f:	f7 e6                	mul    %esi
  802751:	39 55 cc             	cmp    %edx,-0x34(%ebp)
  802754:	72 53                	jb     8027a9 <__umoddi3+0x169>
  802756:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  802759:	74 4a                	je     8027a5 <__umoddi3+0x165>
  80275b:	90                   	nop    
  80275c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802760:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  802763:	29 c7                	sub    %eax,%edi
  802765:	19 d1                	sbb    %edx,%ecx
  802767:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80276a:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  80276e:	89 fa                	mov    %edi,%edx
  802770:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802773:	d3 ea                	shr    %cl,%edx
  802775:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  802779:	d3 e0                	shl    %cl,%eax
  80277b:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  80277f:	09 c2                	or     %eax,%edx
  802781:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802784:	89 55 d0             	mov    %edx,-0x30(%ebp)
  802787:	d3 e8                	shr    %cl,%eax
  802789:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80278c:	e9 0f ff ff ff       	jmp    8026a0 <__umoddi3+0x60>
  802791:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802794:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802797:	2b 45 ec             	sub    -0x14(%ebp),%eax
  80279a:	1b 55 e8             	sbb    -0x18(%ebp),%edx
  80279d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8027a0:	e9 2f ff ff ff       	jmp    8026d4 <__umoddi3+0x94>
  8027a5:	39 f8                	cmp    %edi,%eax
  8027a7:	76 b7                	jbe    802760 <__umoddi3+0x120>
  8027a9:	29 f0                	sub    %esi,%eax
  8027ab:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8027ae:	eb b0                	jmp    802760 <__umoddi3+0x120>
