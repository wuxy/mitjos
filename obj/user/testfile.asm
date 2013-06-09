
obj/user/testfile:     file format elf32-i386

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
  800048:	e8 34 0d 00 00       	call   800d81 <strcpy>
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
  800073:	e8 58 15 00 00       	call   8015d0 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800078:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80007f:	00 
  800080:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  800087:	cc 
  800088:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80008f:	e8 f0 15 00 00       	call   801684 <ipc_recv>
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
	int r;
	struct Fd *fd;
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8000a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000a9:	b8 20 28 80 00       	mov    $0x802820,%eax
  8000ae:	e8 81 ff ff ff       	call   800034 <xopen>
  8000b3:	85 c0                	test   %eax,%eax
  8000b5:	79 25                	jns    8000dc <umain+0x42>
  8000b7:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000ba:	74 3c                	je     8000f8 <umain+0x5e>
		panic("serve_open /not-found: %e", r);
  8000bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c0:	c7 44 24 08 2b 28 80 	movl   $0x80282b,0x8(%esp)
  8000c7:	00 
  8000c8:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8000cf:	00 
  8000d0:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  8000d7:	e8 4c 05 00 00       	call   800628 <_panic>
	else if (r >= 0)
		panic("serve_open /not-found succeeded!");
  8000dc:	c7 44 24 08 84 29 80 	movl   $0x802984,0x8(%esp)
  8000e3:	00 
  8000e4:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8000eb:	00 
  8000ec:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  8000f3:	e8 30 05 00 00       	call   800628 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000fd:	b8 55 28 80 00       	mov    $0x802855,%eax
  800102:	e8 2d ff ff ff       	call   800034 <xopen>
  800107:	85 c0                	test   %eax,%eax
  800109:	79 20                	jns    80012b <umain+0x91>
		panic("serve_open /newmotd: %e", r);
  80010b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80010f:	c7 44 24 08 5e 28 80 	movl   $0x80285e,0x8(%esp)
  800116:	00 
  800117:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80011e:	00 
  80011f:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  800126:	e8 fd 04 00 00       	call   800628 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  80012b:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  800132:	75 12                	jne    800146 <umain+0xac>
  800134:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  80013b:	75 09                	jne    800146 <umain+0xac>
  80013d:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  800144:	74 1c                	je     800162 <umain+0xc8>
		panic("serve_open did not fill struct Fd correctly\n");
  800146:	c7 44 24 08 a8 29 80 	movl   $0x8029a8,0x8(%esp)
  80014d:	00 
  80014e:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800155:	00 
  800156:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  80015d:	e8 c6 04 00 00       	call   800628 <_panic>
	cprintf("serve_open is good\n");
  800162:	c7 04 24 76 28 80 00 	movl   $0x802876,(%esp)
  800169:	e8 87 05 00 00       	call   8006f5 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  80016e:	8d 85 60 ff ff ff    	lea    0xffffff60(%ebp),%eax
  800174:	89 44 24 04          	mov    %eax,0x4(%esp)
  800178:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80017f:	ff 15 1c 60 80 00    	call   *0x80601c
  800185:	85 c0                	test   %eax,%eax
  800187:	79 20                	jns    8001a9 <umain+0x10f>
		panic("file_stat: %e", r);
  800189:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018d:	c7 44 24 08 8a 28 80 	movl   $0x80288a,0x8(%esp)
  800194:	00 
  800195:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  80019c:	00 
  80019d:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  8001a4:	e8 7f 04 00 00       	call   800628 <_panic>
	if (strlen(msg) != st.st_size)
  8001a9:	a1 00 60 80 00       	mov    0x806000,%eax
  8001ae:	89 04 24             	mov    %eax,(%esp)
  8001b1:	e8 7a 0b 00 00       	call   800d30 <strlen>
  8001b6:	3b 45 e0             	cmp    0xffffffe0(%ebp),%eax
  8001b9:	74 34                	je     8001ef <umain+0x155>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  8001bb:	a1 00 60 80 00       	mov    0x806000,%eax
  8001c0:	89 04 24             	mov    %eax,(%esp)
  8001c3:	e8 68 0b 00 00       	call   800d30 <strlen>
  8001c8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001cc:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  8001cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d3:	c7 44 24 08 d8 29 80 	movl   $0x8029d8,0x8(%esp)
  8001da:	00 
  8001db:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8001e2:	00 
  8001e3:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  8001ea:	e8 39 04 00 00       	call   800628 <_panic>
	cprintf("file_stat is good\n");
  8001ef:	c7 04 24 98 28 80 00 	movl   $0x802898,(%esp)
  8001f6:	e8 fa 04 00 00       	call   8006f5 <cprintf>

	memset(buf, 0, sizeof buf);
  8001fb:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800202:	00 
  800203:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80020a:	00 
  80020b:	8d 9d 60 fd ff ff    	lea    0xfffffd60(%ebp),%ebx
  800211:	89 1c 24             	mov    %ebx,(%esp)
  800214:	e8 18 0d 00 00       	call   800f31 <memset>
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
  80023a:	c7 44 24 08 ab 28 80 	movl   $0x8028ab,0x8(%esp)
  800241:	00 
  800242:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  800249:	00 
  80024a:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  800251:	e8 d2 03 00 00       	call   800628 <_panic>
	if (strcmp(buf, msg) != 0)
  800256:	a1 00 60 80 00       	mov    0x806000,%eax
  80025b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025f:	8d 85 60 fd ff ff    	lea    0xfffffd60(%ebp),%eax
  800265:	89 04 24             	mov    %eax,(%esp)
  800268:	e8 f8 0b 00 00       	call   800e65 <strcmp>
  80026d:	85 c0                	test   %eax,%eax
  80026f:	74 1c                	je     80028d <umain+0x1f3>
		panic("file_read returned wrong data");
  800271:	c7 44 24 08 b9 28 80 	movl   $0x8028b9,0x8(%esp)
  800278:	00 
  800279:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  800280:	00 
  800281:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  800288:	e8 9b 03 00 00       	call   800628 <_panic>
	cprintf("file_read is good\n");
  80028d:	c7 04 24 d7 28 80 00 	movl   $0x8028d7,(%esp)
  800294:	e8 5c 04 00 00       	call   8006f5 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800299:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8002a0:	ff 15 18 60 80 00    	call   *0x806018
  8002a6:	85 c0                	test   %eax,%eax
  8002a8:	79 20                	jns    8002ca <umain+0x230>
		panic("file_close: %e", r);
  8002aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ae:	c7 44 24 08 ea 28 80 	movl   $0x8028ea,0x8(%esp)
  8002b5:	00 
  8002b6:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  8002bd:	00 
  8002be:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  8002c5:	e8 5e 03 00 00       	call   800628 <_panic>
	cprintf("file_close is good\n");
  8002ca:	c7 04 24 f9 28 80 00 	movl   $0x8028f9,(%esp)
  8002d1:	e8 1f 04 00 00       	call   8006f5 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  8002d6:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  8002db:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8002de:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  8002e3:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  8002e6:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  8002eb:	89 45 f4             	mov    %eax,0xfffffff4(%ebp)
  8002ee:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  8002f3:	89 45 f8             	mov    %eax,0xfffffff8(%ebp)
	sys_page_unmap(0, FVA);
  8002f6:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  8002fd:	cc 
  8002fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800305:	e8 e4 10 00 00       	call   8013ee <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80030a:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800311:	00 
  800312:	8d 85 60 fd ff ff    	lea    0xfffffd60(%ebp),%eax
  800318:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031c:	8d 45 ec             	lea    0xffffffec(%ebp),%eax
  80031f:	89 04 24             	mov    %eax,(%esp)
  800322:	ff 15 10 60 80 00    	call   *0x806010
  800328:	83 f8 fd             	cmp    $0xfffffffd,%eax
  80032b:	74 20                	je     80034d <umain+0x2b3>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  80032d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800331:	c7 44 24 08 00 2a 80 	movl   $0x802a00,0x8(%esp)
  800338:	00 
  800339:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  800340:	00 
  800341:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  800348:	e8 db 02 00 00       	call   800628 <_panic>
	cprintf("stale fileid is good\n");
  80034d:	c7 04 24 0d 29 80 00 	movl   $0x80290d,(%esp)
  800354:	e8 9c 03 00 00       	call   8006f5 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  800359:	ba 02 01 00 00       	mov    $0x102,%edx
  80035e:	b8 23 29 80 00       	mov    $0x802923,%eax
  800363:	e8 cc fc ff ff       	call   800034 <xopen>
  800368:	85 c0                	test   %eax,%eax
  80036a:	79 20                	jns    80038c <umain+0x2f2>
		panic("serve_open /new-file: %e", r);
  80036c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800370:	c7 44 24 08 2d 29 80 	movl   $0x80292d,0x8(%esp)
  800377:	00 
  800378:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80037f:	00 
  800380:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  800387:	e8 9c 02 00 00       	call   800628 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  80038c:	8b 1d 14 60 80 00    	mov    0x806014,%ebx
  800392:	a1 00 60 80 00       	mov    0x806000,%eax
  800397:	89 04 24             	mov    %eax,(%esp)
  80039a:	e8 91 09 00 00       	call   800d30 <strlen>
  80039f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a3:	a1 00 60 80 00       	mov    0x806000,%eax
  8003a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ac:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8003b3:	ff d3                	call   *%ebx
  8003b5:	89 c3                	mov    %eax,%ebx
  8003b7:	a1 00 60 80 00       	mov    0x806000,%eax
  8003bc:	89 04 24             	mov    %eax,(%esp)
  8003bf:	e8 6c 09 00 00       	call   800d30 <strlen>
  8003c4:	39 c3                	cmp    %eax,%ebx
  8003c6:	74 20                	je     8003e8 <umain+0x34e>
		panic("file_write: %e", r);
  8003c8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003cc:	c7 44 24 08 46 29 80 	movl   $0x802946,0x8(%esp)
  8003d3:	00 
  8003d4:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  8003db:	00 
  8003dc:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  8003e3:	e8 40 02 00 00       	call   800628 <_panic>
	cprintf("file_write is good\n");
  8003e8:	c7 04 24 55 29 80 00 	movl   $0x802955,(%esp)
  8003ef:	e8 01 03 00 00       	call   8006f5 <cprintf>

	FVA->fd_offset = 0;
  8003f4:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  8003fb:	00 00 00 
	memset(buf, 0, sizeof buf);
  8003fe:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800405:	00 
  800406:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80040d:	00 
  80040e:	8d 9d 60 fd ff ff    	lea    0xfffffd60(%ebp),%ebx
  800414:	89 1c 24             	mov    %ebx,(%esp)
  800417:	e8 15 0b 00 00       	call   800f31 <memset>
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
  80043f:	c7 44 24 08 38 2a 80 	movl   $0x802a38,0x8(%esp)
  800446:	00 
  800447:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  80044e:	00 
  80044f:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  800456:	e8 cd 01 00 00       	call   800628 <_panic>
	if (r != strlen(msg))
  80045b:	a1 00 60 80 00       	mov    0x806000,%eax
  800460:	89 04 24             	mov    %eax,(%esp)
  800463:	e8 c8 08 00 00       	call   800d30 <strlen>
  800468:	39 c3                	cmp    %eax,%ebx
  80046a:	74 20                	je     80048c <umain+0x3f2>
		panic("file_read after file_write returned wrong length: %d", r);
  80046c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800470:	c7 44 24 08 58 2a 80 	movl   $0x802a58,0x8(%esp)
  800477:	00 
  800478:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  80047f:	00 
  800480:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  800487:	e8 9c 01 00 00       	call   800628 <_panic>
	if (strcmp(buf, msg) != 0)
  80048c:	a1 00 60 80 00       	mov    0x806000,%eax
  800491:	89 44 24 04          	mov    %eax,0x4(%esp)
  800495:	8d 85 60 fd ff ff    	lea    0xfffffd60(%ebp),%eax
  80049b:	89 04 24             	mov    %eax,(%esp)
  80049e:	e8 c2 09 00 00       	call   800e65 <strcmp>
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	74 1c                	je     8004c3 <umain+0x429>
		panic("file_read after file_write returned wrong data");
  8004a7:	c7 44 24 08 90 2a 80 	movl   $0x802a90,0x8(%esp)
  8004ae:	00 
  8004af:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8004b6:	00 
  8004b7:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  8004be:	e8 65 01 00 00       	call   800628 <_panic>
	cprintf("file_read after file_write is good\n");
  8004c3:	c7 04 24 c0 2a 80 00 	movl   $0x802ac0,(%esp)
  8004ca:	e8 26 02 00 00       	call   8006f5 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8004cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004d6:	00 
  8004d7:	c7 04 24 20 28 80 00 	movl   $0x802820,(%esp)
  8004de:	e8 90 1a 00 00       	call   801f73 <open>
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	79 25                	jns    80050c <umain+0x472>
  8004e7:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8004ea:	74 3c                	je     800528 <umain+0x48e>
		panic("open /not-found: %e", r);
  8004ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f0:	c7 44 24 08 31 28 80 	movl   $0x802831,0x8(%esp)
  8004f7:	00 
  8004f8:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8004ff:	00 
  800500:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  800507:	e8 1c 01 00 00       	call   800628 <_panic>
	else if (r >= 0)
		panic("open /not-found succeeded!");
  80050c:	c7 44 24 08 69 29 80 	movl   $0x802969,0x8(%esp)
  800513:	00 
  800514:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  80051b:	00 
  80051c:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  800523:	e8 00 01 00 00       	call   800628 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  800528:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80052f:	00 
  800530:	c7 04 24 55 28 80 00 	movl   $0x802855,(%esp)
  800537:	e8 37 1a 00 00       	call   801f73 <open>
  80053c:	85 c0                	test   %eax,%eax
  80053e:	79 20                	jns    800560 <umain+0x4c6>
		panic("open /newmotd: %e", r);
  800540:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800544:	c7 44 24 08 64 28 80 	movl   $0x802864,0x8(%esp)
  80054b:	00 
  80054c:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  800553:	00 
  800554:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  80055b:	e8 c8 00 00 00       	call   800628 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800560:	c1 e0 0c             	shl    $0xc,%eax
  800563:	8d 90 00 00 00 d0    	lea    0xd0000000(%eax),%edx
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800569:	83 b8 00 00 00 d0 66 	cmpl   $0x66,0xd0000000(%eax)
  800570:	75 0c                	jne    80057e <umain+0x4e4>
  800572:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
  800576:	75 06                	jne    80057e <umain+0x4e4>
  800578:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  80057c:	74 1c                	je     80059a <umain+0x500>
		panic("open did not fill struct Fd correctly\n");
  80057e:	c7 44 24 08 e4 2a 80 	movl   $0x802ae4,0x8(%esp)
  800585:	00 
  800586:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  80058d:	00 
  80058e:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  800595:	e8 8e 00 00 00       	call   800628 <_panic>
	cprintf("open is good\n");
  80059a:	c7 04 24 7c 28 80 00 	movl   $0x80287c,(%esp)
  8005a1:	e8 4f 01 00 00       	call   8006f5 <cprintf>
}
  8005a6:	81 c4 b4 02 00 00    	add    $0x2b4,%esp
  8005ac:	5b                   	pop    %ebx
  8005ad:	5d                   	pop    %ebp
  8005ae:	c3                   	ret    
	...

008005b0 <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8005b0:	55                   	push   %ebp
  8005b1:	89 e5                	mov    %esp,%ebp
  8005b3:	83 ec 18             	sub    $0x18,%esp
  8005b6:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  8005b9:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  8005bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8005bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  8005c2:	c7 05 40 60 80 00 00 	movl   $0x0,0x806040
  8005c9:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  8005cc:	e8 6c 0f 00 00       	call   80153d <sys_getenvid>
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

	// call user main routine调用用户主例程
	umain(argc, argv);
  8005ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f2:	89 34 24             	mov    %esi,(%esp)
  8005f5:	e8 a0 fa ff ff       	call   80009a <umain>

	// exit gracefully
	exit();
  8005fa:	e8 0d 00 00 00       	call   80060c <exit>
}
  8005ff:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  800602:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
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
  800612:	e8 4f 17 00 00       	call   801d66 <close_all>
	sys_env_destroy(0);
  800617:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80061e:	e8 4e 0f 00 00       	call   801571 <sys_env_destroy>
}
  800623:	c9                   	leave  
  800624:	c3                   	ret    
  800625:	00 00                	add    %al,(%eax)
	...

00800628 <_panic>:
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
  800631:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)

	// Print the panic message
	if (argv0)
  800634:	a1 44 60 80 00       	mov    0x806044,%eax
  800639:	85 c0                	test   %eax,%eax
  80063b:	74 10                	je     80064d <_panic+0x25>
		cprintf("%s: ", argv0);
  80063d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800641:	c7 04 24 49 2b 80 00 	movl   $0x802b49,(%esp)
  800648:	e8 a8 00 00 00       	call   8006f5 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80064d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800650:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800654:	8b 45 08             	mov    0x8(%ebp),%eax
  800657:	89 44 24 08          	mov    %eax,0x8(%esp)
  80065b:	a1 04 60 80 00       	mov    0x806004,%eax
  800660:	89 44 24 04          	mov    %eax,0x4(%esp)
  800664:	c7 04 24 4e 2b 80 00 	movl   $0x802b4e,(%esp)
  80066b:	e8 85 00 00 00       	call   8006f5 <cprintf>
	vcprintf(fmt, ap);
  800670:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  800673:	89 44 24 04          	mov    %eax,0x4(%esp)
  800677:	8b 45 10             	mov    0x10(%ebp),%eax
  80067a:	89 04 24             	mov    %eax,(%esp)
  80067d:	e8 12 00 00 00       	call   800694 <vcprintf>
	cprintf("\n");
  800682:	c7 04 24 cc 2e 80 00 	movl   $0x802ecc,(%esp)
  800689:	e8 67 00 00 00       	call   8006f5 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80068e:	cc                   	int3   
  80068f:	eb fd                	jmp    80068e <_panic+0x66>
  800691:	00 00                	add    %al,(%eax)
	...

00800694 <vcprintf>:
}

int
vcprintf(const char *fmt, va_list ap)
{
  800694:	55                   	push   %ebp
  800695:	89 e5                	mov    %esp,%ebp
  800697:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80069d:	c7 85 f8 fe ff ff 00 	movl   $0x0,0xfffffef8(%ebp)
  8006a4:	00 00 00 
	b.cnt = 0;
  8006a7:	c7 85 fc fe ff ff 00 	movl   $0x0,0xfffffefc(%ebp)
  8006ae:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006bf:	8d 85 f8 fe ff ff    	lea    0xfffffef8(%ebp),%eax
  8006c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c9:	c7 04 24 12 07 80 00 	movl   $0x800712,(%esp)
  8006d0:	e8 cc 01 00 00       	call   8008a1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006d5:	8b 85 f8 fe ff ff    	mov    0xfffffef8(%ebp),%eax
  8006db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006df:	8d 85 00 ff ff ff    	lea    0xffffff00(%ebp),%eax
  8006e5:	89 04 24             	mov    %eax,(%esp)
  8006e8:	e8 eb 0a 00 00       	call   8011d8 <sys_cputs>
  8006ed:	8b 85 fc fe ff ff    	mov    0xfffffefc(%ebp),%eax

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
  8006fe:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
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
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	53                   	push   %ebx
  800716:	83 ec 14             	sub    $0x14,%esp
  800719:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80071c:	8b 03                	mov    (%ebx),%eax
  80071e:	8b 55 08             	mov    0x8(%ebp),%edx
  800721:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800725:	83 c0 01             	add    $0x1,%eax
  800728:	89 03                	mov    %eax,(%ebx)
  80072a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80072f:	75 19                	jne    80074a <putch+0x38>
  800731:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800738:	00 
  800739:	8d 43 08             	lea    0x8(%ebx),%eax
  80073c:	89 04 24             	mov    %eax,(%esp)
  80073f:	e8 94 0a 00 00       	call   8011d8 <sys_cputs>
  800744:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80074a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
  80074e:	83 c4 14             	add    $0x14,%esp
  800751:	5b                   	pop    %ebx
  800752:	5d                   	pop    %ebp
  800753:	c3                   	ret    
	...

00800760 <printnum>:
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
  800769:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  80076c:	89 d7                	mov    %edx,%edi
  80076e:	8b 45 08             	mov    0x8(%ebp),%eax
  800771:	8b 55 0c             	mov    0xc(%ebp),%edx
  800774:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800777:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  80077a:	8b 55 10             	mov    0x10(%ebp),%edx
  80077d:	8b 45 14             	mov    0x14(%ebp),%eax
  800780:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800783:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  800786:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  80078d:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800790:	39 4d ec             	cmp    %ecx,0xffffffec(%ebp)
  800793:	72 11                	jb     8007a6 <printnum+0x46>
  800795:	8b 4d d8             	mov    0xffffffd8(%ebp),%ecx
  800798:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  80079b:	76 09                	jbe    8007a6 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80079d:	8d 58 ff             	lea    0xffffffff(%eax),%ebx
  8007a0:	85 db                	test   %ebx,%ebx
  8007a2:	7f 54                	jg     8007f8 <printnum+0x98>
  8007a4:	eb 61                	jmp    800807 <printnum+0xa7>
  8007a6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8007aa:	83 e8 01             	sub    $0x1,%eax
  8007ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007b1:	89 54 24 08          	mov    %edx,0x8(%esp)
  8007b5:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8007b9:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8007bd:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8007c0:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  8007c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007cb:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  8007ce:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  8007d1:	89 14 24             	mov    %edx,(%esp)
  8007d4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007d8:	e8 73 1d 00 00       	call   802550 <__udivdi3>
  8007dd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007e1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8007e5:	89 04 24             	mov    %eax,(%esp)
  8007e8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ec:	89 fa                	mov    %edi,%edx
  8007ee:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  8007f1:	e8 6a ff ff ff       	call   800760 <printnum>
  8007f6:	eb 0f                	jmp    800807 <printnum+0xa7>
			putch(padc, putdat);
  8007f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007fc:	89 34 24             	mov    %esi,(%esp)
  8007ff:	ff 55 e4             	call   *0xffffffe4(%ebp)
  800802:	83 eb 01             	sub    $0x1,%ebx
  800805:	75 f1                	jne    8007f8 <printnum+0x98>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800807:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80080b:	8b 74 24 04          	mov    0x4(%esp),%esi
  80080f:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800812:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800815:	89 44 24 08          	mov    %eax,0x8(%esp)
  800819:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80081d:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800820:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800823:	89 14 24             	mov    %edx,(%esp)
  800826:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80082a:	e8 51 1e 00 00       	call   802680 <__umoddi3>
  80082f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800833:	0f be 80 6a 2b 80 00 	movsbl 0x802b6a(%eax),%eax
  80083a:	89 04 24             	mov    %eax,(%esp)
  80083d:	ff 55 e4             	call   *0xffffffe4(%ebp)
}
  800840:	83 c4 3c             	add    $0x3c,%esp
  800843:	5b                   	pop    %ebx
  800844:	5e                   	pop    %esi
  800845:	5f                   	pop    %edi
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  80084d:	83 fa 01             	cmp    $0x1,%edx
  800850:	7e 0e                	jle    800860 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800852:	8b 10                	mov    (%eax),%edx
  800854:	8d 42 08             	lea    0x8(%edx),%eax
  800857:	89 01                	mov    %eax,(%ecx)
  800859:	8b 02                	mov    (%edx),%eax
  80085b:	8b 52 04             	mov    0x4(%edx),%edx
  80085e:	eb 22                	jmp    800882 <getuint+0x3a>
	else if (lflag)
  800860:	85 d2                	test   %edx,%edx
  800862:	74 10                	je     800874 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800864:	8b 10                	mov    (%eax),%edx
  800866:	8d 42 04             	lea    0x4(%edx),%eax
  800869:	89 01                	mov    %eax,(%ecx)
  80086b:	8b 02                	mov    (%edx),%eax
  80086d:	ba 00 00 00 00       	mov    $0x0,%edx
  800872:	eb 0e                	jmp    800882 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800874:	8b 10                	mov    (%eax),%edx
  800876:	8d 42 04             	lea    0x4(%edx),%eax
  800879:	89 01                	mov    %eax,(%ecx)
  80087b:	8b 02                	mov    (%edx),%eax
  80087d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    

00800884 <sprintputch>:

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
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  80088a:	83 41 08 01          	addl   $0x1,0x8(%ecx)
	if (b->buf < b->ebuf)
  80088e:	8b 11                	mov    (%ecx),%edx
  800890:	3b 51 04             	cmp    0x4(%ecx),%edx
  800893:	73 0a                	jae    80089f <sprintputch+0x1b>
		*b->buf++ = ch;
  800895:	8b 45 08             	mov    0x8(%ebp),%eax
  800898:	88 02                	mov    %al,(%edx)
  80089a:	8d 42 01             	lea    0x1(%edx),%eax
  80089d:	89 01                	mov    %eax,(%ecx)
}
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <vprintfmt>:
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	57                   	push   %edi
  8008a5:	56                   	push   %esi
  8008a6:	53                   	push   %ebx
  8008a7:	83 ec 4c             	sub    $0x4c,%esp
  8008aa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8008b0:	eb 03                	jmp    8008b5 <vprintfmt+0x14>
  8008b2:	8b 5d e8             	mov    0xffffffe8(%ebp),%ebx
  8008b5:	0f b6 03             	movzbl (%ebx),%eax
  8008b8:	83 c3 01             	add    $0x1,%ebx
  8008bb:	3c 25                	cmp    $0x25,%al
  8008bd:	74 30                	je     8008ef <vprintfmt+0x4e>
  8008bf:	84 c0                	test   %al,%al
  8008c1:	0f 84 a8 03 00 00    	je     800c6f <vprintfmt+0x3ce>
  8008c7:	0f b6 d0             	movzbl %al,%edx
  8008ca:	eb 0a                	jmp    8008d6 <vprintfmt+0x35>
  8008cc:	84 c0                	test   %al,%al
  8008ce:	66 90                	xchg   %ax,%ax
  8008d0:	0f 84 99 03 00 00    	je     800c6f <vprintfmt+0x3ce>
  8008d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008dd:	89 14 24             	mov    %edx,(%esp)
  8008e0:	ff d7                	call   *%edi
  8008e2:	0f b6 03             	movzbl (%ebx),%eax
  8008e5:	0f b6 d0             	movzbl %al,%edx
  8008e8:	83 c3 01             	add    $0x1,%ebx
  8008eb:	3c 25                	cmp    $0x25,%al
  8008ed:	75 dd                	jne    8008cc <vprintfmt+0x2b>
  8008ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008f4:	c7 45 ec ff ff ff ff 	movl   $0xffffffff,0xffffffec(%ebp)
  8008fb:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  800902:	c7 45 dc 00 00 00 00 	movl   $0x0,0xffffffdc(%ebp)
  800909:	c6 45 e3 20          	movb   $0x20,0xffffffe3(%ebp)
  80090d:	eb 07                	jmp    800916 <vprintfmt+0x75>
  80090f:	c7 45 dc 01 00 00 00 	movl   $0x1,0xffffffdc(%ebp)
  800916:	0f b6 03             	movzbl (%ebx),%eax
  800919:	0f b6 d0             	movzbl %al,%edx
  80091c:	83 c3 01             	add    $0x1,%ebx
  80091f:	83 e8 23             	sub    $0x23,%eax
  800922:	3c 55                	cmp    $0x55,%al
  800924:	0f 87 11 03 00 00    	ja     800c3b <vprintfmt+0x39a>
  80092a:	0f b6 c0             	movzbl %al,%eax
  80092d:	ff 24 85 a0 2c 80 00 	jmp    *0x802ca0(,%eax,4)
  800934:	c6 45 e3 30          	movb   $0x30,0xffffffe3(%ebp)
  800938:	eb dc                	jmp    800916 <vprintfmt+0x75>
  80093a:	83 ea 30             	sub    $0x30,%edx
  80093d:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800940:	0f be 13             	movsbl (%ebx),%edx
  800943:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800946:	83 f8 09             	cmp    $0x9,%eax
  800949:	76 08                	jbe    800953 <vprintfmt+0xb2>
  80094b:	eb 42                	jmp    80098f <vprintfmt+0xee>
  80094d:	c6 45 e3 2d          	movb   $0x2d,0xffffffe3(%ebp)
  800951:	eb c3                	jmp    800916 <vprintfmt+0x75>
  800953:	83 c3 01             	add    $0x1,%ebx
  800956:	8b 75 e4             	mov    0xffffffe4(%ebp),%esi
  800959:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  80095c:	8d 44 42 d0          	lea    0xffffffd0(%edx,%eax,2),%eax
  800960:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800963:	0f be 13             	movsbl (%ebx),%edx
  800966:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800969:	83 f8 09             	cmp    $0x9,%eax
  80096c:	77 21                	ja     80098f <vprintfmt+0xee>
  80096e:	eb e3                	jmp    800953 <vprintfmt+0xb2>
  800970:	8b 55 14             	mov    0x14(%ebp),%edx
  800973:	8d 42 04             	lea    0x4(%edx),%eax
  800976:	89 45 14             	mov    %eax,0x14(%ebp)
  800979:	8b 12                	mov    (%edx),%edx
  80097b:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  80097e:	eb 0f                	jmp    80098f <vprintfmt+0xee>
  800980:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800984:	79 90                	jns    800916 <vprintfmt+0x75>
  800986:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  80098d:	eb 87                	jmp    800916 <vprintfmt+0x75>
  80098f:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800993:	79 81                	jns    800916 <vprintfmt+0x75>
  800995:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  800998:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  80099b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  8009a2:	e9 6f ff ff ff       	jmp    800916 <vprintfmt+0x75>
  8009a7:	83 c1 01             	add    $0x1,%ecx
  8009aa:	e9 67 ff ff ff       	jmp    800916 <vprintfmt+0x75>
  8009af:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b2:	8d 50 04             	lea    0x4(%eax),%edx
  8009b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009bf:	8b 00                	mov    (%eax),%eax
  8009c1:	89 04 24             	mov    %eax,(%esp)
  8009c4:	ff d7                	call   *%edi
  8009c6:	e9 ea fe ff ff       	jmp    8008b5 <vprintfmt+0x14>
  8009cb:	8b 55 14             	mov    0x14(%ebp),%edx
  8009ce:	8d 42 04             	lea    0x4(%edx),%eax
  8009d1:	89 45 14             	mov    %eax,0x14(%ebp)
  8009d4:	8b 02                	mov    (%edx),%eax
  8009d6:	89 c2                	mov    %eax,%edx
  8009d8:	c1 fa 1f             	sar    $0x1f,%edx
  8009db:	31 d0                	xor    %edx,%eax
  8009dd:	29 d0                	sub    %edx,%eax
  8009df:	83 f8 0f             	cmp    $0xf,%eax
  8009e2:	7f 0b                	jg     8009ef <vprintfmt+0x14e>
  8009e4:	8b 14 85 00 2e 80 00 	mov    0x802e00(,%eax,4),%edx
  8009eb:	85 d2                	test   %edx,%edx
  8009ed:	75 20                	jne    800a0f <vprintfmt+0x16e>
  8009ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009f3:	c7 44 24 08 7b 2b 80 	movl   $0x802b7b,0x8(%esp)
  8009fa:	00 
  8009fb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a02:	89 3c 24             	mov    %edi,(%esp)
  800a05:	e8 f0 02 00 00       	call   800cfa <printfmt>
  800a0a:	e9 a6 fe ff ff       	jmp    8008b5 <vprintfmt+0x14>
  800a0f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a13:	c7 44 24 08 86 2f 80 	movl   $0x802f86,0x8(%esp)
  800a1a:	00 
  800a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a22:	89 3c 24             	mov    %edi,(%esp)
  800a25:	e8 d0 02 00 00       	call   800cfa <printfmt>
  800a2a:	e9 86 fe ff ff       	jmp    8008b5 <vprintfmt+0x14>
  800a2f:	8b 75 ec             	mov    0xffffffec(%ebp),%esi
  800a32:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  800a35:	89 5d e8             	mov    %ebx,0xffffffe8(%ebp)
  800a38:	8b 55 14             	mov    0x14(%ebp),%edx
  800a3b:	8d 42 04             	lea    0x4(%edx),%eax
  800a3e:	89 45 14             	mov    %eax,0x14(%ebp)
  800a41:	8b 12                	mov    (%edx),%edx
  800a43:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  800a46:	85 d2                	test   %edx,%edx
  800a48:	75 07                	jne    800a51 <vprintfmt+0x1b0>
  800a4a:	c7 45 d8 84 2b 80 00 	movl   $0x802b84,0xffffffd8(%ebp)
  800a51:	85 f6                	test   %esi,%esi
  800a53:	7e 40                	jle    800a95 <vprintfmt+0x1f4>
  800a55:	80 7d e3 2d          	cmpb   $0x2d,0xffffffe3(%ebp)
  800a59:	74 3a                	je     800a95 <vprintfmt+0x1f4>
  800a5b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a5f:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800a62:	89 14 24             	mov    %edx,(%esp)
  800a65:	e8 e6 02 00 00       	call   800d50 <strnlen>
  800a6a:	29 c6                	sub    %eax,%esi
  800a6c:	89 75 ec             	mov    %esi,0xffffffec(%ebp)
  800a6f:	85 f6                	test   %esi,%esi
  800a71:	7e 22                	jle    800a95 <vprintfmt+0x1f4>
  800a73:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  800a77:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  800a7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a81:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  800a84:	89 04 24             	mov    %eax,(%esp)
  800a87:	ff d7                	call   *%edi
  800a89:	83 ee 01             	sub    $0x1,%esi
  800a8c:	75 ec                	jne    800a7a <vprintfmt+0x1d9>
  800a8e:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  800a95:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800a98:	0f b6 02             	movzbl (%edx),%eax
  800a9b:	0f be d0             	movsbl %al,%edx
  800a9e:	8b 75 d8             	mov    0xffffffd8(%ebp),%esi
  800aa1:	84 c0                	test   %al,%al
  800aa3:	75 40                	jne    800ae5 <vprintfmt+0x244>
  800aa5:	eb 4a                	jmp    800af1 <vprintfmt+0x250>
  800aa7:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
  800aab:	74 1a                	je     800ac7 <vprintfmt+0x226>
  800aad:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  800ab0:	83 f8 5e             	cmp    $0x5e,%eax
  800ab3:	76 12                	jbe    800ac7 <vprintfmt+0x226>
  800ab5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800abc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800ac3:	ff d7                	call   *%edi
  800ac5:	eb 0c                	jmp    800ad3 <vprintfmt+0x232>
  800ac7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aca:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ace:	89 14 24             	mov    %edx,(%esp)
  800ad1:	ff d7                	call   *%edi
  800ad3:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  800ad7:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800adb:	83 c6 01             	add    $0x1,%esi
  800ade:	84 c0                	test   %al,%al
  800ae0:	74 0f                	je     800af1 <vprintfmt+0x250>
  800ae2:	0f be d0             	movsbl %al,%edx
  800ae5:	83 7d e4 00          	cmpl   $0x0,0xffffffe4(%ebp)
  800ae9:	78 bc                	js     800aa7 <vprintfmt+0x206>
  800aeb:	83 6d e4 01          	subl   $0x1,0xffffffe4(%ebp)
  800aef:	79 b6                	jns    800aa7 <vprintfmt+0x206>
  800af1:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800af5:	0f 8e ba fd ff ff    	jle    8008b5 <vprintfmt+0x14>
  800afb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800afe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b02:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800b09:	ff d7                	call   *%edi
  800b0b:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  800b0f:	0f 84 9d fd ff ff    	je     8008b2 <vprintfmt+0x11>
  800b15:	eb e4                	jmp    800afb <vprintfmt+0x25a>
  800b17:	83 f9 01             	cmp    $0x1,%ecx
  800b1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800b20:	7e 10                	jle    800b32 <vprintfmt+0x291>
  800b22:	8b 55 14             	mov    0x14(%ebp),%edx
  800b25:	8d 42 08             	lea    0x8(%edx),%eax
  800b28:	89 45 14             	mov    %eax,0x14(%ebp)
  800b2b:	8b 02                	mov    (%edx),%eax
  800b2d:	8b 52 04             	mov    0x4(%edx),%edx
  800b30:	eb 26                	jmp    800b58 <vprintfmt+0x2b7>
  800b32:	85 c9                	test   %ecx,%ecx
  800b34:	74 12                	je     800b48 <vprintfmt+0x2a7>
  800b36:	8b 45 14             	mov    0x14(%ebp),%eax
  800b39:	8d 50 04             	lea    0x4(%eax),%edx
  800b3c:	89 55 14             	mov    %edx,0x14(%ebp)
  800b3f:	8b 00                	mov    (%eax),%eax
  800b41:	89 c2                	mov    %eax,%edx
  800b43:	c1 fa 1f             	sar    $0x1f,%edx
  800b46:	eb 10                	jmp    800b58 <vprintfmt+0x2b7>
  800b48:	8b 45 14             	mov    0x14(%ebp),%eax
  800b4b:	8d 50 04             	lea    0x4(%eax),%edx
  800b4e:	89 55 14             	mov    %edx,0x14(%ebp)
  800b51:	8b 00                	mov    (%eax),%eax
  800b53:	89 c2                	mov    %eax,%edx
  800b55:	c1 fa 1f             	sar    $0x1f,%edx
  800b58:	89 d1                	mov    %edx,%ecx
  800b5a:	89 c2                	mov    %eax,%edx
  800b5c:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  800b5f:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  800b62:	be 0a 00 00 00       	mov    $0xa,%esi
  800b67:	85 c9                	test   %ecx,%ecx
  800b69:	0f 89 92 00 00 00    	jns    800c01 <vprintfmt+0x360>
  800b6f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b72:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b76:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b7d:	ff d7                	call   *%edi
  800b7f:	8b 55 d0             	mov    0xffffffd0(%ebp),%edx
  800b82:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  800b85:	f7 da                	neg    %edx
  800b87:	83 d1 00             	adc    $0x0,%ecx
  800b8a:	f7 d9                	neg    %ecx
  800b8c:	be 0a 00 00 00       	mov    $0xa,%esi
  800b91:	eb 6e                	jmp    800c01 <vprintfmt+0x360>
  800b93:	8d 45 14             	lea    0x14(%ebp),%eax
  800b96:	89 ca                	mov    %ecx,%edx
  800b98:	e8 ab fc ff ff       	call   800848 <getuint>
  800b9d:	89 d1                	mov    %edx,%ecx
  800b9f:	89 c2                	mov    %eax,%edx
  800ba1:	be 0a 00 00 00       	mov    $0xa,%esi
  800ba6:	eb 59                	jmp    800c01 <vprintfmt+0x360>
  800ba8:	8d 45 14             	lea    0x14(%ebp),%eax
  800bab:	89 ca                	mov    %ecx,%edx
  800bad:	e8 96 fc ff ff       	call   800848 <getuint>
  800bb2:	e9 fe fc ff ff       	jmp    8008b5 <vprintfmt+0x14>
  800bb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bba:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bbe:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800bc5:	ff d7                	call   *%edi
  800bc7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bca:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bce:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800bd5:	ff d7                	call   *%edi
  800bd7:	8b 55 14             	mov    0x14(%ebp),%edx
  800bda:	8d 42 04             	lea    0x4(%edx),%eax
  800bdd:	89 45 14             	mov    %eax,0x14(%ebp)
  800be0:	8b 12                	mov    (%edx),%edx
  800be2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be7:	be 10 00 00 00       	mov    $0x10,%esi
  800bec:	eb 13                	jmp    800c01 <vprintfmt+0x360>
  800bee:	8d 45 14             	lea    0x14(%ebp),%eax
  800bf1:	89 ca                	mov    %ecx,%edx
  800bf3:	e8 50 fc ff ff       	call   800848 <getuint>
  800bf8:	89 d1                	mov    %edx,%ecx
  800bfa:	89 c2                	mov    %eax,%edx
  800bfc:	be 10 00 00 00       	mov    $0x10,%esi
  800c01:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  800c05:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c09:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  800c0c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c10:	89 74 24 08          	mov    %esi,0x8(%esp)
  800c14:	89 14 24             	mov    %edx,(%esp)
  800c17:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1e:	89 f8                	mov    %edi,%eax
  800c20:	e8 3b fb ff ff       	call   800760 <printnum>
  800c25:	e9 8b fc ff ff       	jmp    8008b5 <vprintfmt+0x14>
  800c2a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c2d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c31:	89 14 24             	mov    %edx,(%esp)
  800c34:	ff d7                	call   *%edi
  800c36:	e9 7a fc ff ff       	jmp    8008b5 <vprintfmt+0x14>
  800c3b:	89 de                	mov    %ebx,%esi
  800c3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c40:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c44:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800c4b:	ff d7                	call   *%edi
  800c4d:	83 eb 01             	sub    $0x1,%ebx
  800c50:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800c54:	0f 84 5b fc ff ff    	je     8008b5 <vprintfmt+0x14>
  800c5a:	8d 56 fd             	lea    0xfffffffd(%esi),%edx
  800c5d:	0f b6 02             	movzbl (%edx),%eax
  800c60:	83 ea 01             	sub    $0x1,%edx
  800c63:	3c 25                	cmp    $0x25,%al
  800c65:	75 f6                	jne    800c5d <vprintfmt+0x3bc>
  800c67:	8d 5a 02             	lea    0x2(%edx),%ebx
  800c6a:	e9 46 fc ff ff       	jmp    8008b5 <vprintfmt+0x14>
  800c6f:	83 c4 4c             	add    $0x4c,%esp
  800c72:	5b                   	pop    %ebx
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    

00800c77 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	83 ec 28             	sub    $0x28,%esp
  800c7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c80:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800c83:	85 d2                	test   %edx,%edx
  800c85:	74 04                	je     800c8b <vsnprintf+0x14>
  800c87:	85 c0                	test   %eax,%eax
  800c89:	7f 07                	jg     800c92 <vsnprintf+0x1b>
  800c8b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c90:	eb 3b                	jmp    800ccd <vsnprintf+0x56>
  800c92:	c7 45 fc 00 00 00 00 	movl   $0x0,0xfffffffc(%ebp)
  800c99:	8d 44 02 ff          	lea    0xffffffff(%edx,%eax,1),%eax
  800c9d:	89 45 f8             	mov    %eax,0xfffffff8(%ebp)
  800ca0:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ca3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ca6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800caa:	8b 45 10             	mov    0x10(%ebp),%eax
  800cad:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cb1:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  800cb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cb8:	c7 04 24 84 08 80 00 	movl   $0x800884,(%esp)
  800cbf:	e8 dd fb ff ff       	call   8008a1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cc4:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  800cc7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cca:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
}
  800ccd:	c9                   	leave  
  800cce:	c3                   	ret    

00800ccf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cd5:	8d 45 14             	lea    0x14(%ebp),%eax
  800cd8:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800cdb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cdf:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ce6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ced:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf0:	89 04 24             	mov    %eax,(%esp)
  800cf3:	e8 7f ff ff ff       	call   800c77 <vsnprintf>
	va_end(ap);

	return rc;
}
  800cf8:	c9                   	leave  
  800cf9:	c3                   	ret    

00800cfa <printfmt>:
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	83 ec 28             	sub    $0x28,%esp
  800d00:	8d 45 14             	lea    0x14(%ebp),%eax
  800d03:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
  800d06:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d0a:	8b 45 10             	mov    0x10(%ebp),%eax
  800d0d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d14:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d18:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1b:	89 04 24             	mov    %eax,(%esp)
  800d1e:	e8 7e fb ff ff       	call   8008a1 <vprintfmt>
  800d23:	c9                   	leave  
  800d24:	c3                   	ret    
	...

00800d30 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d36:	b8 00 00 00 00       	mov    $0x0,%eax
  800d3b:	80 3a 00             	cmpb   $0x0,(%edx)
  800d3e:	74 0e                	je     800d4e <strlen+0x1e>
  800d40:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800d45:	83 c0 01             	add    $0x1,%eax
  800d48:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  800d4c:	75 f7                	jne    800d45 <strlen+0x15>
	return n;
}
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d56:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d59:	85 d2                	test   %edx,%edx
  800d5b:	74 19                	je     800d76 <strnlen+0x26>
  800d5d:	80 39 00             	cmpb   $0x0,(%ecx)
  800d60:	74 14                	je     800d76 <strnlen+0x26>
  800d62:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800d67:	83 c0 01             	add    $0x1,%eax
  800d6a:	39 d0                	cmp    %edx,%eax
  800d6c:	74 0d                	je     800d7b <strnlen+0x2b>
  800d6e:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800d72:	74 07                	je     800d7b <strnlen+0x2b>
  800d74:	eb f1                	jmp    800d67 <strnlen+0x17>
  800d76:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800d7b:	5d                   	pop    %ebp
  800d7c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800d80:	c3                   	ret    

00800d81 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	53                   	push   %ebx
  800d85:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8b:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d8d:	0f b6 01             	movzbl (%ecx),%eax
  800d90:	88 02                	mov    %al,(%edx)
  800d92:	83 c2 01             	add    $0x1,%edx
  800d95:	83 c1 01             	add    $0x1,%ecx
  800d98:	84 c0                	test   %al,%al
  800d9a:	75 f1                	jne    800d8d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d9c:	89 d8                	mov    %ebx,%eax
  800d9e:	5b                   	pop    %ebx
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
  800da7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800daa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dad:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800db0:	85 f6                	test   %esi,%esi
  800db2:	74 1c                	je     800dd0 <strncpy+0x2f>
  800db4:	89 fa                	mov    %edi,%edx
  800db6:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  800dbb:	0f b6 01             	movzbl (%ecx),%eax
  800dbe:	88 02                	mov    %al,(%edx)
  800dc0:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800dc3:	80 39 01             	cmpb   $0x1,(%ecx)
  800dc6:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800dc9:	83 c3 01             	add    $0x1,%ebx
  800dcc:	39 f3                	cmp    %esi,%ebx
  800dce:	75 eb                	jne    800dbb <strncpy+0x1a>
	}
	return ret;
}
  800dd0:	89 f8                	mov    %edi,%eax
  800dd2:	5b                   	pop    %ebx
  800dd3:	5e                   	pop    %esi
  800dd4:	5f                   	pop    %edi
  800dd5:	5d                   	pop    %ebp
  800dd6:	c3                   	ret    

00800dd7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800dd7:	55                   	push   %ebp
  800dd8:	89 e5                	mov    %esp,%ebp
  800dda:	56                   	push   %esi
  800ddb:	53                   	push   %ebx
  800ddc:	8b 75 08             	mov    0x8(%ebp),%esi
  800ddf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de2:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800de5:	89 f0                	mov    %esi,%eax
  800de7:	85 d2                	test   %edx,%edx
  800de9:	74 2c                	je     800e17 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800deb:	89 d3                	mov    %edx,%ebx
  800ded:	83 eb 01             	sub    $0x1,%ebx
  800df0:	74 20                	je     800e12 <strlcpy+0x3b>
  800df2:	0f b6 11             	movzbl (%ecx),%edx
  800df5:	84 d2                	test   %dl,%dl
  800df7:	74 19                	je     800e12 <strlcpy+0x3b>
  800df9:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800dfb:	88 10                	mov    %dl,(%eax)
  800dfd:	83 c0 01             	add    $0x1,%eax
  800e00:	83 eb 01             	sub    $0x1,%ebx
  800e03:	74 0f                	je     800e14 <strlcpy+0x3d>
  800e05:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  800e09:	83 c1 01             	add    $0x1,%ecx
  800e0c:	84 d2                	test   %dl,%dl
  800e0e:	74 04                	je     800e14 <strlcpy+0x3d>
  800e10:	eb e9                	jmp    800dfb <strlcpy+0x24>
  800e12:	89 f0                	mov    %esi,%eax
		*dst = '\0';
  800e14:	c6 00 00             	movb   $0x0,(%eax)
  800e17:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800e19:	5b                   	pop    %ebx
  800e1a:	5e                   	pop    %esi
  800e1b:	5d                   	pop    %ebp
  800e1c:	c3                   	ret    

00800e1d <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  800e1d:	55                   	push   %ebp
  800e1e:	89 e5                	mov    %esp,%ebp
  800e20:	57                   	push   %edi
  800e21:	56                   	push   %esi
  800e22:	53                   	push   %ebx
  800e23:	8b 55 08             	mov    0x8(%ebp),%edx
  800e26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e29:	8b 7d 10             	mov    0x10(%ebp),%edi
    int c;
    char *q = buf;

    if (buf_size <= 0)
  800e2c:	85 c9                	test   %ecx,%ecx
  800e2e:	7e 30                	jle    800e60 <pstrcpy+0x43>
        return;

    for(;;) {
        c = *str++;
  800e30:	0f b6 07             	movzbl (%edi),%eax
        if (c == 0 || q >= buf + buf_size - 1)
  800e33:	84 c0                	test   %al,%al
  800e35:	74 26                	je     800e5d <pstrcpy+0x40>
  800e37:	8d 74 0a ff          	lea    0xffffffff(%edx,%ecx,1),%esi
  800e3b:	0f be d8             	movsbl %al,%ebx
  800e3e:	89 f9                	mov    %edi,%ecx
  800e40:	39 f2                	cmp    %esi,%edx
  800e42:	72 09                	jb     800e4d <pstrcpy+0x30>
  800e44:	eb 17                	jmp    800e5d <pstrcpy+0x40>
  800e46:	83 c1 01             	add    $0x1,%ecx
  800e49:	39 f2                	cmp    %esi,%edx
  800e4b:	73 10                	jae    800e5d <pstrcpy+0x40>
            break;
        *q++ = c;
  800e4d:	88 1a                	mov    %bl,(%edx)
  800e4f:	83 c2 01             	add    $0x1,%edx
  800e52:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800e56:	0f be d8             	movsbl %al,%ebx
  800e59:	84 c0                	test   %al,%al
  800e5b:	75 e9                	jne    800e46 <pstrcpy+0x29>
    }
    *q = '\0';
  800e5d:	c6 02 00             	movb   $0x0,(%edx)
}
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  800e6e:	0f b6 02             	movzbl (%edx),%eax
  800e71:	84 c0                	test   %al,%al
  800e73:	74 16                	je     800e8b <strcmp+0x26>
  800e75:	3a 01                	cmp    (%ecx),%al
  800e77:	75 12                	jne    800e8b <strcmp+0x26>
		p++, q++;
  800e79:	83 c1 01             	add    $0x1,%ecx
  800e7c:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  800e80:	84 c0                	test   %al,%al
  800e82:	74 07                	je     800e8b <strcmp+0x26>
  800e84:	83 c2 01             	add    $0x1,%edx
  800e87:	3a 01                	cmp    (%ecx),%al
  800e89:	74 ee                	je     800e79 <strcmp+0x14>
  800e8b:	0f b6 c0             	movzbl %al,%eax
  800e8e:	0f b6 11             	movzbl (%ecx),%edx
  800e91:	29 d0                	sub    %edx,%eax
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    

00800e95 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	53                   	push   %ebx
  800e99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e9c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e9f:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800ea2:	85 d2                	test   %edx,%edx
  800ea4:	74 2d                	je     800ed3 <strncmp+0x3e>
  800ea6:	0f b6 01             	movzbl (%ecx),%eax
  800ea9:	84 c0                	test   %al,%al
  800eab:	74 1a                	je     800ec7 <strncmp+0x32>
  800ead:	3a 03                	cmp    (%ebx),%al
  800eaf:	75 16                	jne    800ec7 <strncmp+0x32>
  800eb1:	83 ea 01             	sub    $0x1,%edx
  800eb4:	74 1d                	je     800ed3 <strncmp+0x3e>
		n--, p++, q++;
  800eb6:	83 c1 01             	add    $0x1,%ecx
  800eb9:	83 c3 01             	add    $0x1,%ebx
  800ebc:	0f b6 01             	movzbl (%ecx),%eax
  800ebf:	84 c0                	test   %al,%al
  800ec1:	74 04                	je     800ec7 <strncmp+0x32>
  800ec3:	3a 03                	cmp    (%ebx),%al
  800ec5:	74 ea                	je     800eb1 <strncmp+0x1c>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ec7:	0f b6 11             	movzbl (%ecx),%edx
  800eca:	0f b6 03             	movzbl (%ebx),%eax
  800ecd:	29 c2                	sub    %eax,%edx
  800ecf:	89 d0                	mov    %edx,%eax
  800ed1:	eb 05                	jmp    800ed8 <strncmp+0x43>
  800ed3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ed8:	5b                   	pop    %ebx
  800ed9:	5d                   	pop    %ebp
  800eda:	c3                   	ret    

00800edb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ee5:	0f b6 10             	movzbl (%eax),%edx
  800ee8:	84 d2                	test   %dl,%dl
  800eea:	74 16                	je     800f02 <strchr+0x27>
		if (*s == c)
  800eec:	38 ca                	cmp    %cl,%dl
  800eee:	75 06                	jne    800ef6 <strchr+0x1b>
  800ef0:	eb 15                	jmp    800f07 <strchr+0x2c>
  800ef2:	38 ca                	cmp    %cl,%dl
  800ef4:	74 11                	je     800f07 <strchr+0x2c>
  800ef6:	83 c0 01             	add    $0x1,%eax
  800ef9:	0f b6 10             	movzbl (%eax),%edx
  800efc:	84 d2                	test   %dl,%dl
  800efe:	66 90                	xchg   %ax,%ax
  800f00:	75 f0                	jne    800ef2 <strchr+0x17>
  800f02:	b8 00 00 00 00       	mov    $0x0,%eax
			return (char *) s;
	return 0;
}
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    

00800f09 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f13:	0f b6 10             	movzbl (%eax),%edx
  800f16:	84 d2                	test   %dl,%dl
  800f18:	74 14                	je     800f2e <strfind+0x25>
		if (*s == c)
  800f1a:	38 ca                	cmp    %cl,%dl
  800f1c:	75 06                	jne    800f24 <strfind+0x1b>
  800f1e:	eb 0e                	jmp    800f2e <strfind+0x25>
  800f20:	38 ca                	cmp    %cl,%dl
  800f22:	74 0a                	je     800f2e <strfind+0x25>
  800f24:	83 c0 01             	add    $0x1,%eax
  800f27:	0f b6 10             	movzbl (%eax),%edx
  800f2a:	84 d2                	test   %dl,%dl
  800f2c:	75 f2                	jne    800f20 <strfind+0x17>
			break;
	return (char *) s;
}
  800f2e:	5d                   	pop    %ebp
  800f2f:	90                   	nop    
  800f30:	c3                   	ret    

00800f31 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	83 ec 08             	sub    $0x8,%esp
  800f37:	89 1c 24             	mov    %ebx,(%esp)
  800f3a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f3e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f44:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800f47:	85 db                	test   %ebx,%ebx
  800f49:	74 32                	je     800f7d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f4b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f51:	75 25                	jne    800f78 <memset+0x47>
  800f53:	f6 c3 03             	test   $0x3,%bl
  800f56:	75 20                	jne    800f78 <memset+0x47>
		c &= 0xFF;
  800f58:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800f5b:	89 d0                	mov    %edx,%eax
  800f5d:	c1 e0 18             	shl    $0x18,%eax
  800f60:	89 d1                	mov    %edx,%ecx
  800f62:	c1 e1 10             	shl    $0x10,%ecx
  800f65:	09 c8                	or     %ecx,%eax
  800f67:	09 d0                	or     %edx,%eax
  800f69:	c1 e2 08             	shl    $0x8,%edx
  800f6c:	09 d0                	or     %edx,%eax
  800f6e:	89 d9                	mov    %ebx,%ecx
  800f70:	c1 e9 02             	shr    $0x2,%ecx
  800f73:	fc                   	cld    
  800f74:	f3 ab                	rep stos %eax,%es:(%edi)
  800f76:	eb 05                	jmp    800f7d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f78:	89 d9                	mov    %ebx,%ecx
  800f7a:	fc                   	cld    
  800f7b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f7d:	89 f8                	mov    %edi,%eax
  800f7f:	8b 1c 24             	mov    (%esp),%ebx
  800f82:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f86:	89 ec                	mov    %ebp,%esp
  800f88:	5d                   	pop    %ebp
  800f89:	c3                   	ret    

00800f8a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f8a:	55                   	push   %ebp
  800f8b:	89 e5                	mov    %esp,%ebp
  800f8d:	83 ec 08             	sub    $0x8,%esp
  800f90:	89 34 24             	mov    %esi,(%esp)
  800f93:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f97:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800f9d:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800fa0:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800fa2:	39 c6                	cmp    %eax,%esi
  800fa4:	73 36                	jae    800fdc <memmove+0x52>
  800fa6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800fa9:	39 d0                	cmp    %edx,%eax
  800fab:	73 2f                	jae    800fdc <memmove+0x52>
		s += n;
		d += n;
  800fad:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fb0:	f6 c2 03             	test   $0x3,%dl
  800fb3:	75 1b                	jne    800fd0 <memmove+0x46>
  800fb5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800fbb:	75 13                	jne    800fd0 <memmove+0x46>
  800fbd:	f6 c1 03             	test   $0x3,%cl
  800fc0:	75 0e                	jne    800fd0 <memmove+0x46>
			asm volatile("std; rep movsl\n"
  800fc2:	8d 7e fc             	lea    0xfffffffc(%esi),%edi
  800fc5:	8d 72 fc             	lea    0xfffffffc(%edx),%esi
  800fc8:	c1 e9 02             	shr    $0x2,%ecx
  800fcb:	fd                   	std    
  800fcc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fce:	eb 09                	jmp    800fd9 <memmove+0x4f>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fd0:	8d 7e ff             	lea    0xffffffff(%esi),%edi
  800fd3:	8d 72 ff             	lea    0xffffffff(%edx),%esi
  800fd6:	fd                   	std    
  800fd7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fd9:	fc                   	cld    
  800fda:	eb 21                	jmp    800ffd <memmove+0x73>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fdc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800fe2:	75 16                	jne    800ffa <memmove+0x70>
  800fe4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800fea:	75 0e                	jne    800ffa <memmove+0x70>
  800fec:	f6 c1 03             	test   $0x3,%cl
  800fef:	90                   	nop    
  800ff0:	75 08                	jne    800ffa <memmove+0x70>
			asm volatile("cld; rep movsl\n"
  800ff2:	c1 e9 02             	shr    $0x2,%ecx
  800ff5:	fc                   	cld    
  800ff6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ff8:	eb 03                	jmp    800ffd <memmove+0x73>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ffa:	fc                   	cld    
  800ffb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ffd:	8b 34 24             	mov    (%esp),%esi
  801000:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801004:	89 ec                	mov    %ebp,%esp
  801006:	5d                   	pop    %ebp
  801007:	c3                   	ret    

00801008 <memcpy>:

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
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80100e:	8b 45 10             	mov    0x10(%ebp),%eax
  801011:	89 44 24 08          	mov    %eax,0x8(%esp)
  801015:	8b 45 0c             	mov    0xc(%ebp),%eax
  801018:	89 44 24 04          	mov    %eax,0x4(%esp)
  80101c:	8b 45 08             	mov    0x8(%ebp),%eax
  80101f:	89 04 24             	mov    %eax,(%esp)
  801022:	e8 63 ff ff ff       	call   800f8a <memmove>
}
  801027:	c9                   	leave  
  801028:	c3                   	ret    

00801029 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801029:	55                   	push   %ebp
  80102a:	89 e5                	mov    %esp,%ebp
  80102c:	56                   	push   %esi
  80102d:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80102e:	8b 75 10             	mov    0x10(%ebp),%esi
  801031:	83 ee 01             	sub    $0x1,%esi
  801034:	83 fe ff             	cmp    $0xffffffff,%esi
  801037:	74 38                	je     801071 <memcmp+0x48>
  801039:	8b 45 08             	mov    0x8(%ebp),%eax
  80103c:	8b 55 0c             	mov    0xc(%ebp),%edx
		if (*s1 != *s2)
  80103f:	0f b6 18             	movzbl (%eax),%ebx
  801042:	0f b6 0a             	movzbl (%edx),%ecx
  801045:	38 cb                	cmp    %cl,%bl
  801047:	74 20                	je     801069 <memcmp+0x40>
  801049:	eb 12                	jmp    80105d <memcmp+0x34>
  80104b:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
  80104f:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
  801053:	83 c0 01             	add    $0x1,%eax
  801056:	83 c2 01             	add    $0x1,%edx
  801059:	38 cb                	cmp    %cl,%bl
  80105b:	74 0c                	je     801069 <memcmp+0x40>
			return (int) *s1 - (int) *s2;
  80105d:	0f b6 d3             	movzbl %bl,%edx
  801060:	0f b6 c1             	movzbl %cl,%eax
  801063:	29 c2                	sub    %eax,%edx
  801065:	89 d0                	mov    %edx,%eax
  801067:	eb 0d                	jmp    801076 <memcmp+0x4d>
  801069:	83 ee 01             	sub    $0x1,%esi
  80106c:	83 fe ff             	cmp    $0xffffffff,%esi
  80106f:	75 da                	jne    80104b <memcmp+0x22>
  801071:	b8 00 00 00 00       	mov    $0x0,%eax
		s1++, s2++;
	}

	return 0;
}
  801076:	5b                   	pop    %ebx
  801077:	5e                   	pop    %esi
  801078:	5d                   	pop    %ebp
  801079:	c3                   	ret    

0080107a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	53                   	push   %ebx
  80107e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	const void *ends = (const char *) s + n;
  801081:	89 da                	mov    %ebx,%edx
  801083:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801086:	39 d3                	cmp    %edx,%ebx
  801088:	73 1a                	jae    8010a4 <memfind+0x2a>
		if (*(const unsigned char *) s == (unsigned char) c)
  80108a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
			break;
  80108e:	89 d8                	mov    %ebx,%eax
  801090:	38 0b                	cmp    %cl,(%ebx)
  801092:	75 06                	jne    80109a <memfind+0x20>
  801094:	eb 0e                	jmp    8010a4 <memfind+0x2a>
  801096:	38 08                	cmp    %cl,(%eax)
  801098:	74 0c                	je     8010a6 <memfind+0x2c>
  80109a:	83 c0 01             	add    $0x1,%eax
  80109d:	39 d0                	cmp    %edx,%eax
  80109f:	90                   	nop    
  8010a0:	75 f4                	jne    801096 <memfind+0x1c>
  8010a2:	eb 02                	jmp    8010a6 <memfind+0x2c>
  8010a4:	89 d8                	mov    %ebx,%eax
	return (void *) s;
}
  8010a6:	5b                   	pop    %ebx
  8010a7:	5d                   	pop    %ebp
  8010a8:	c3                   	ret    

008010a9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010a9:	55                   	push   %ebp
  8010aa:	89 e5                	mov    %esp,%ebp
  8010ac:	57                   	push   %edi
  8010ad:	56                   	push   %esi
  8010ae:	53                   	push   %ebx
  8010af:	83 ec 04             	sub    $0x4,%esp
  8010b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8010b5:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010b8:	0f b6 03             	movzbl (%ebx),%eax
  8010bb:	3c 20                	cmp    $0x20,%al
  8010bd:	74 04                	je     8010c3 <strtol+0x1a>
  8010bf:	3c 09                	cmp    $0x9,%al
  8010c1:	75 0e                	jne    8010d1 <strtol+0x28>
		s++;
  8010c3:	83 c3 01             	add    $0x1,%ebx
  8010c6:	0f b6 03             	movzbl (%ebx),%eax
  8010c9:	3c 20                	cmp    $0x20,%al
  8010cb:	74 f6                	je     8010c3 <strtol+0x1a>
  8010cd:	3c 09                	cmp    $0x9,%al
  8010cf:	74 f2                	je     8010c3 <strtol+0x1a>

	// plus/minus sign
	if (*s == '+')
  8010d1:	3c 2b                	cmp    $0x2b,%al
  8010d3:	75 0d                	jne    8010e2 <strtol+0x39>
		s++;
  8010d5:	83 c3 01             	add    $0x1,%ebx
  8010d8:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  8010df:	90                   	nop    
  8010e0:	eb 15                	jmp    8010f7 <strtol+0x4e>
	else if (*s == '-')
  8010e2:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  8010e9:	3c 2d                	cmp    $0x2d,%al
  8010eb:	75 0a                	jne    8010f7 <strtol+0x4e>
		s++, neg = 1;
  8010ed:	83 c3 01             	add    $0x1,%ebx
  8010f0:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010f7:	85 f6                	test   %esi,%esi
  8010f9:	0f 94 c0             	sete   %al
  8010fc:	84 c0                	test   %al,%al
  8010fe:	75 05                	jne    801105 <strtol+0x5c>
  801100:	83 fe 10             	cmp    $0x10,%esi
  801103:	75 17                	jne    80111c <strtol+0x73>
  801105:	80 3b 30             	cmpb   $0x30,(%ebx)
  801108:	75 12                	jne    80111c <strtol+0x73>
  80110a:	80 7b 01 78          	cmpb   $0x78,0x1(%ebx)
  80110e:	66 90                	xchg   %ax,%ax
  801110:	75 0a                	jne    80111c <strtol+0x73>
		s += 2, base = 16;
  801112:	83 c3 02             	add    $0x2,%ebx
  801115:	be 10 00 00 00       	mov    $0x10,%esi
  80111a:	eb 1f                	jmp    80113b <strtol+0x92>
	else if (base == 0 && s[0] == '0')
  80111c:	85 f6                	test   %esi,%esi
  80111e:	66 90                	xchg   %ax,%ax
  801120:	75 10                	jne    801132 <strtol+0x89>
  801122:	80 3b 30             	cmpb   $0x30,(%ebx)
  801125:	75 0b                	jne    801132 <strtol+0x89>
		s++, base = 8;
  801127:	83 c3 01             	add    $0x1,%ebx
  80112a:	66 be 08 00          	mov    $0x8,%si
  80112e:	66 90                	xchg   %ax,%ax
  801130:	eb 09                	jmp    80113b <strtol+0x92>
	else if (base == 0)
  801132:	84 c0                	test   %al,%al
  801134:	74 05                	je     80113b <strtol+0x92>
  801136:	be 0a 00 00 00       	mov    $0xa,%esi
  80113b:	bf 00 00 00 00       	mov    $0x0,%edi
		base = 10;

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801140:	0f b6 13             	movzbl (%ebx),%edx
  801143:	89 d1                	mov    %edx,%ecx
  801145:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  801148:	3c 09                	cmp    $0x9,%al
  80114a:	77 08                	ja     801154 <strtol+0xab>
			dig = *s - '0';
  80114c:	0f be c2             	movsbl %dl,%eax
  80114f:	8d 50 d0             	lea    0xffffffd0(%eax),%edx
  801152:	eb 1c                	jmp    801170 <strtol+0xc7>
		else if (*s >= 'a' && *s <= 'z')
  801154:	8d 41 9f             	lea    0xffffff9f(%ecx),%eax
  801157:	3c 19                	cmp    $0x19,%al
  801159:	77 08                	ja     801163 <strtol+0xba>
			dig = *s - 'a' + 10;
  80115b:	0f be c2             	movsbl %dl,%eax
  80115e:	8d 50 a9             	lea    0xffffffa9(%eax),%edx
  801161:	eb 0d                	jmp    801170 <strtol+0xc7>
		else if (*s >= 'A' && *s <= 'Z')
  801163:	8d 41 bf             	lea    0xffffffbf(%ecx),%eax
  801166:	3c 19                	cmp    $0x19,%al
  801168:	77 17                	ja     801181 <strtol+0xd8>
			dig = *s - 'A' + 10;
  80116a:	0f be c2             	movsbl %dl,%eax
  80116d:	8d 50 c9             	lea    0xffffffc9(%eax),%edx
		else
			break;
		if (dig >= base)
  801170:	39 f2                	cmp    %esi,%edx
  801172:	7d 0d                	jge    801181 <strtol+0xd8>
			break;
		s++, val = (val * base) + dig;
  801174:	83 c3 01             	add    $0x1,%ebx
  801177:	89 f8                	mov    %edi,%eax
  801179:	0f af c6             	imul   %esi,%eax
  80117c:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  80117f:	eb bf                	jmp    801140 <strtol+0x97>
		// we don't properly detect overflow!
	}
  801181:	89 f8                	mov    %edi,%eax

	if (endptr)
  801183:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801187:	74 05                	je     80118e <strtol+0xe5>
		*endptr = (char *) s;
  801189:	8b 55 0c             	mov    0xc(%ebp),%edx
  80118c:	89 1a                	mov    %ebx,(%edx)
	return (neg ? -val : val);
  80118e:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  801192:	74 04                	je     801198 <strtol+0xef>
  801194:	89 c7                	mov    %eax,%edi
  801196:	f7 df                	neg    %edi
}
  801198:	89 f8                	mov    %edi,%eax
  80119a:	83 c4 04             	add    $0x4,%esp
  80119d:	5b                   	pop    %ebx
  80119e:	5e                   	pop    %esi
  80119f:	5f                   	pop    %edi
  8011a0:	5d                   	pop    %ebp
  8011a1:	c3                   	ret    
	...

008011a4 <sys_cgetc>:
}

int
sys_cgetc(void)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	83 ec 0c             	sub    $0xc,%esp
  8011aa:	89 1c 24             	mov    %ebx,(%esp)
  8011ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011b1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8011b5:	b8 01 00 00 00       	mov    $0x1,%eax
  8011ba:	bf 00 00 00 00       	mov    $0x0,%edi
  8011bf:	89 fa                	mov    %edi,%edx
  8011c1:	89 f9                	mov    %edi,%ecx
  8011c3:	89 fb                	mov    %edi,%ebx
  8011c5:	89 fe                	mov    %edi,%esi
  8011c7:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8011c9:	8b 1c 24             	mov    (%esp),%ebx
  8011cc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011d0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011d4:	89 ec                	mov    %ebp,%esp
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    

008011d8 <sys_cputs>:
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	83 ec 0c             	sub    $0xc,%esp
  8011de:	89 1c 24             	mov    %ebx,(%esp)
  8011e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011e5:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8011e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8011f4:	89 f8                	mov    %edi,%eax
  8011f6:	89 fb                	mov    %edi,%ebx
  8011f8:	89 fe                	mov    %edi,%esi
  8011fa:	cd 30                	int    $0x30
  8011fc:	8b 1c 24             	mov    (%esp),%ebx
  8011ff:	8b 74 24 04          	mov    0x4(%esp),%esi
  801203:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801207:	89 ec                	mov    %ebp,%esp
  801209:	5d                   	pop    %ebp
  80120a:	c3                   	ret    

0080120b <sys_time_msec>:

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
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	83 ec 0c             	sub    $0xc,%esp
  801211:	89 1c 24             	mov    %ebx,(%esp)
  801214:	89 74 24 04          	mov    %esi,0x4(%esp)
  801218:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80121c:	b8 0e 00 00 00       	mov    $0xe,%eax
  801221:	bf 00 00 00 00       	mov    $0x0,%edi
  801226:	89 fa                	mov    %edi,%edx
  801228:	89 f9                	mov    %edi,%ecx
  80122a:	89 fb                	mov    %edi,%ebx
  80122c:	89 fe                	mov    %edi,%esi
  80122e:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801230:	8b 1c 24             	mov    (%esp),%ebx
  801233:	8b 74 24 04          	mov    0x4(%esp),%esi
  801237:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80123b:	89 ec                	mov    %ebp,%esp
  80123d:	5d                   	pop    %ebp
  80123e:	c3                   	ret    

0080123f <sys_ipc_recv>:
  80123f:	55                   	push   %ebp
  801240:	89 e5                	mov    %esp,%ebp
  801242:	83 ec 28             	sub    $0x28,%esp
  801245:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801248:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  80124b:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  80124e:	8b 55 08             	mov    0x8(%ebp),%edx
  801251:	b8 0d 00 00 00       	mov    $0xd,%eax
  801256:	bf 00 00 00 00       	mov    $0x0,%edi
  80125b:	89 f9                	mov    %edi,%ecx
  80125d:	89 fb                	mov    %edi,%ebx
  80125f:	89 fe                	mov    %edi,%esi
  801261:	cd 30                	int    $0x30
  801263:	85 c0                	test   %eax,%eax
  801265:	7e 28                	jle    80128f <sys_ipc_recv+0x50>
  801267:	89 44 24 10          	mov    %eax,0x10(%esp)
  80126b:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801272:	00 
  801273:	c7 44 24 08 5f 2e 80 	movl   $0x802e5f,0x8(%esp)
  80127a:	00 
  80127b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801282:	00 
  801283:	c7 04 24 7c 2e 80 00 	movl   $0x802e7c,(%esp)
  80128a:	e8 99 f3 ff ff       	call   800628 <_panic>
  80128f:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801292:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801295:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801298:	89 ec                	mov    %ebp,%esp
  80129a:	5d                   	pop    %ebp
  80129b:	c3                   	ret    

0080129c <sys_ipc_try_send>:
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	83 ec 0c             	sub    $0xc,%esp
  8012a2:	89 1c 24             	mov    %ebx,(%esp)
  8012a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012a9:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8012ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012b6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012b9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012be:	be 00 00 00 00       	mov    $0x0,%esi
  8012c3:	cd 30                	int    $0x30
  8012c5:	8b 1c 24             	mov    (%esp),%ebx
  8012c8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8012cc:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8012d0:	89 ec                	mov    %ebp,%esp
  8012d2:	5d                   	pop    %ebp
  8012d3:	c3                   	ret    

008012d4 <sys_env_set_pgfault_upcall>:
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	83 ec 28             	sub    $0x28,%esp
  8012da:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  8012dd:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  8012e0:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  8012e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012ee:	bf 00 00 00 00       	mov    $0x0,%edi
  8012f3:	89 fb                	mov    %edi,%ebx
  8012f5:	89 fe                	mov    %edi,%esi
  8012f7:	cd 30                	int    $0x30
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	7e 28                	jle    801325 <sys_env_set_pgfault_upcall+0x51>
  8012fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801301:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801308:	00 
  801309:	c7 44 24 08 5f 2e 80 	movl   $0x802e5f,0x8(%esp)
  801310:	00 
  801311:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801318:	00 
  801319:	c7 04 24 7c 2e 80 00 	movl   $0x802e7c,(%esp)
  801320:	e8 03 f3 ff ff       	call   800628 <_panic>
  801325:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801328:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  80132b:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  80132e:	89 ec                	mov    %ebp,%esp
  801330:	5d                   	pop    %ebp
  801331:	c3                   	ret    

00801332 <sys_env_set_trapframe>:
  801332:	55                   	push   %ebp
  801333:	89 e5                	mov    %esp,%ebp
  801335:	83 ec 28             	sub    $0x28,%esp
  801338:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  80133b:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  80133e:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801341:	8b 55 08             	mov    0x8(%ebp),%edx
  801344:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801347:	b8 09 00 00 00       	mov    $0x9,%eax
  80134c:	bf 00 00 00 00       	mov    $0x0,%edi
  801351:	89 fb                	mov    %edi,%ebx
  801353:	89 fe                	mov    %edi,%esi
  801355:	cd 30                	int    $0x30
  801357:	85 c0                	test   %eax,%eax
  801359:	7e 28                	jle    801383 <sys_env_set_trapframe+0x51>
  80135b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80135f:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801366:	00 
  801367:	c7 44 24 08 5f 2e 80 	movl   $0x802e5f,0x8(%esp)
  80136e:	00 
  80136f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801376:	00 
  801377:	c7 04 24 7c 2e 80 00 	movl   $0x802e7c,(%esp)
  80137e:	e8 a5 f2 ff ff       	call   800628 <_panic>
  801383:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801386:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801389:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  80138c:	89 ec                	mov    %ebp,%esp
  80138e:	5d                   	pop    %ebp
  80138f:	c3                   	ret    

00801390 <sys_env_set_status>:
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	83 ec 28             	sub    $0x28,%esp
  801396:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801399:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  80139c:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  80139f:	8b 55 08             	mov    0x8(%ebp),%edx
  8013a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013a5:	b8 08 00 00 00       	mov    $0x8,%eax
  8013aa:	bf 00 00 00 00       	mov    $0x0,%edi
  8013af:	89 fb                	mov    %edi,%ebx
  8013b1:	89 fe                	mov    %edi,%esi
  8013b3:	cd 30                	int    $0x30
  8013b5:	85 c0                	test   %eax,%eax
  8013b7:	7e 28                	jle    8013e1 <sys_env_set_status+0x51>
  8013b9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013bd:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8013c4:	00 
  8013c5:	c7 44 24 08 5f 2e 80 	movl   $0x802e5f,0x8(%esp)
  8013cc:	00 
  8013cd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013d4:	00 
  8013d5:	c7 04 24 7c 2e 80 00 	movl   $0x802e7c,(%esp)
  8013dc:	e8 47 f2 ff ff       	call   800628 <_panic>
  8013e1:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  8013e4:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  8013e7:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  8013ea:	89 ec                	mov    %ebp,%esp
  8013ec:	5d                   	pop    %ebp
  8013ed:	c3                   	ret    

008013ee <sys_page_unmap>:
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	83 ec 28             	sub    $0x28,%esp
  8013f4:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  8013f7:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  8013fa:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  8013fd:	8b 55 08             	mov    0x8(%ebp),%edx
  801400:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801403:	b8 06 00 00 00       	mov    $0x6,%eax
  801408:	bf 00 00 00 00       	mov    $0x0,%edi
  80140d:	89 fb                	mov    %edi,%ebx
  80140f:	89 fe                	mov    %edi,%esi
  801411:	cd 30                	int    $0x30
  801413:	85 c0                	test   %eax,%eax
  801415:	7e 28                	jle    80143f <sys_page_unmap+0x51>
  801417:	89 44 24 10          	mov    %eax,0x10(%esp)
  80141b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801422:	00 
  801423:	c7 44 24 08 5f 2e 80 	movl   $0x802e5f,0x8(%esp)
  80142a:	00 
  80142b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801432:	00 
  801433:	c7 04 24 7c 2e 80 00 	movl   $0x802e7c,(%esp)
  80143a:	e8 e9 f1 ff ff       	call   800628 <_panic>
  80143f:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801442:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801445:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801448:	89 ec                	mov    %ebp,%esp
  80144a:	5d                   	pop    %ebp
  80144b:	c3                   	ret    

0080144c <sys_page_map>:
  80144c:	55                   	push   %ebp
  80144d:	89 e5                	mov    %esp,%ebp
  80144f:	83 ec 28             	sub    $0x28,%esp
  801452:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801455:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  801458:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  80145b:	8b 55 08             	mov    0x8(%ebp),%edx
  80145e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801461:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801464:	8b 7d 14             	mov    0x14(%ebp),%edi
  801467:	8b 75 18             	mov    0x18(%ebp),%esi
  80146a:	b8 05 00 00 00       	mov    $0x5,%eax
  80146f:	cd 30                	int    $0x30
  801471:	85 c0                	test   %eax,%eax
  801473:	7e 28                	jle    80149d <sys_page_map+0x51>
  801475:	89 44 24 10          	mov    %eax,0x10(%esp)
  801479:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801480:	00 
  801481:	c7 44 24 08 5f 2e 80 	movl   $0x802e5f,0x8(%esp)
  801488:	00 
  801489:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801490:	00 
  801491:	c7 04 24 7c 2e 80 00 	movl   $0x802e7c,(%esp)
  801498:	e8 8b f1 ff ff       	call   800628 <_panic>
  80149d:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  8014a0:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  8014a3:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  8014a6:	89 ec                	mov    %ebp,%esp
  8014a8:	5d                   	pop    %ebp
  8014a9:	c3                   	ret    

008014aa <sys_page_alloc>:
  8014aa:	55                   	push   %ebp
  8014ab:	89 e5                	mov    %esp,%ebp
  8014ad:	83 ec 28             	sub    $0x28,%esp
  8014b0:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  8014b3:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  8014b6:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  8014b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8014bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8014c2:	b8 04 00 00 00       	mov    $0x4,%eax
  8014c7:	bf 00 00 00 00       	mov    $0x0,%edi
  8014cc:	89 fe                	mov    %edi,%esi
  8014ce:	cd 30                	int    $0x30
  8014d0:	85 c0                	test   %eax,%eax
  8014d2:	7e 28                	jle    8014fc <sys_page_alloc+0x52>
  8014d4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014d8:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8014df:	00 
  8014e0:	c7 44 24 08 5f 2e 80 	movl   $0x802e5f,0x8(%esp)
  8014e7:	00 
  8014e8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014ef:	00 
  8014f0:	c7 04 24 7c 2e 80 00 	movl   $0x802e7c,(%esp)
  8014f7:	e8 2c f1 ff ff       	call   800628 <_panic>
  8014fc:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  8014ff:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801502:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801505:	89 ec                	mov    %ebp,%esp
  801507:	5d                   	pop    %ebp
  801508:	c3                   	ret    

00801509 <sys_yield>:
  801509:	55                   	push   %ebp
  80150a:	89 e5                	mov    %esp,%ebp
  80150c:	83 ec 0c             	sub    $0xc,%esp
  80150f:	89 1c 24             	mov    %ebx,(%esp)
  801512:	89 74 24 04          	mov    %esi,0x4(%esp)
  801516:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80151a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80151f:	bf 00 00 00 00       	mov    $0x0,%edi
  801524:	89 fa                	mov    %edi,%edx
  801526:	89 f9                	mov    %edi,%ecx
  801528:	89 fb                	mov    %edi,%ebx
  80152a:	89 fe                	mov    %edi,%esi
  80152c:	cd 30                	int    $0x30
  80152e:	8b 1c 24             	mov    (%esp),%ebx
  801531:	8b 74 24 04          	mov    0x4(%esp),%esi
  801535:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801539:	89 ec                	mov    %ebp,%esp
  80153b:	5d                   	pop    %ebp
  80153c:	c3                   	ret    

0080153d <sys_getenvid>:
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
  801540:	83 ec 0c             	sub    $0xc,%esp
  801543:	89 1c 24             	mov    %ebx,(%esp)
  801546:	89 74 24 04          	mov    %esi,0x4(%esp)
  80154a:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80154e:	b8 02 00 00 00       	mov    $0x2,%eax
  801553:	bf 00 00 00 00       	mov    $0x0,%edi
  801558:	89 fa                	mov    %edi,%edx
  80155a:	89 f9                	mov    %edi,%ecx
  80155c:	89 fb                	mov    %edi,%ebx
  80155e:	89 fe                	mov    %edi,%esi
  801560:	cd 30                	int    $0x30
  801562:	8b 1c 24             	mov    (%esp),%ebx
  801565:	8b 74 24 04          	mov    0x4(%esp),%esi
  801569:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80156d:	89 ec                	mov    %ebp,%esp
  80156f:	5d                   	pop    %ebp
  801570:	c3                   	ret    

00801571 <sys_env_destroy>:
  801571:	55                   	push   %ebp
  801572:	89 e5                	mov    %esp,%ebp
  801574:	83 ec 28             	sub    $0x28,%esp
  801577:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  80157a:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  80157d:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801580:	8b 55 08             	mov    0x8(%ebp),%edx
  801583:	b8 03 00 00 00       	mov    $0x3,%eax
  801588:	bf 00 00 00 00       	mov    $0x0,%edi
  80158d:	89 f9                	mov    %edi,%ecx
  80158f:	89 fb                	mov    %edi,%ebx
  801591:	89 fe                	mov    %edi,%esi
  801593:	cd 30                	int    $0x30
  801595:	85 c0                	test   %eax,%eax
  801597:	7e 28                	jle    8015c1 <sys_env_destroy+0x50>
  801599:	89 44 24 10          	mov    %eax,0x10(%esp)
  80159d:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8015a4:	00 
  8015a5:	c7 44 24 08 5f 2e 80 	movl   $0x802e5f,0x8(%esp)
  8015ac:	00 
  8015ad:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8015b4:	00 
  8015b5:	c7 04 24 7c 2e 80 00 	movl   $0x802e7c,(%esp)
  8015bc:	e8 67 f0 ff ff       	call   800628 <_panic>
  8015c1:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  8015c4:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  8015c7:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  8015ca:	89 ec                	mov    %ebp,%esp
  8015cc:	5d                   	pop    %ebp
  8015cd:	c3                   	ret    
	...

008015d0 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	57                   	push   %edi
  8015d4:	56                   	push   %esi
  8015d5:	53                   	push   %ebx
  8015d6:	83 ec 1c             	sub    $0x1c,%esp
  8015d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8015dc:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  8015df:	e8 59 ff ff ff       	call   80153d <sys_getenvid>
  8015e4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8015e9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8015ec:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8015f1:	a3 40 60 80 00       	mov    %eax,0x806040
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  8015f6:	e8 42 ff ff ff       	call   80153d <sys_getenvid>
  8015fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  801600:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801603:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801608:	a3 40 60 80 00       	mov    %eax,0x806040
		if(env->env_id==to_env){
  80160d:	8b 40 4c             	mov    0x4c(%eax),%eax
  801610:	39 f0                	cmp    %esi,%eax
  801612:	75 0e                	jne    801622 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  801614:	c7 04 24 8a 2e 80 00 	movl   $0x802e8a,(%esp)
  80161b:	e8 d5 f0 ff ff       	call   8006f5 <cprintf>
  801620:	eb 5a                	jmp    80167c <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  801622:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801626:	8b 45 10             	mov    0x10(%ebp),%eax
  801629:	89 44 24 08          	mov    %eax,0x8(%esp)
  80162d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801630:	89 44 24 04          	mov    %eax,0x4(%esp)
  801634:	89 34 24             	mov    %esi,(%esp)
  801637:	e8 60 fc ff ff       	call   80129c <sys_ipc_try_send>
  80163c:	89 c3                	mov    %eax,%ebx
  80163e:	85 c0                	test   %eax,%eax
  801640:	79 25                	jns    801667 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  801642:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801645:	74 2b                	je     801672 <ipc_send+0xa2>
				panic("send error:%e",r);
  801647:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80164b:	c7 44 24 08 a6 2e 80 	movl   $0x802ea6,0x8(%esp)
  801652:	00 
  801653:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80165a:	00 
  80165b:	c7 04 24 b4 2e 80 00 	movl   $0x802eb4,(%esp)
  801662:	e8 c1 ef ff ff       	call   800628 <_panic>
		}
			sys_yield();
  801667:	e8 9d fe ff ff       	call   801509 <sys_yield>
		
	}while(r!=0);
  80166c:	85 db                	test   %ebx,%ebx
  80166e:	75 86                	jne    8015f6 <ipc_send+0x26>
  801670:	eb 0a                	jmp    80167c <ipc_send+0xac>
  801672:	e8 92 fe ff ff       	call   801509 <sys_yield>
  801677:	e9 7a ff ff ff       	jmp    8015f6 <ipc_send+0x26>
	return;
	//panic("ipc_send not implemented");
}
  80167c:	83 c4 1c             	add    $0x1c,%esp
  80167f:	5b                   	pop    %ebx
  801680:	5e                   	pop    %esi
  801681:	5f                   	pop    %edi
  801682:	5d                   	pop    %ebp
  801683:	c3                   	ret    

00801684 <ipc_recv>:
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	57                   	push   %edi
  801688:	56                   	push   %esi
  801689:	53                   	push   %ebx
  80168a:	83 ec 0c             	sub    $0xc,%esp
  80168d:	8b 75 08             	mov    0x8(%ebp),%esi
  801690:	8b 7d 10             	mov    0x10(%ebp),%edi
  801693:	e8 a5 fe ff ff       	call   80153d <sys_getenvid>
  801698:	25 ff 03 00 00       	and    $0x3ff,%eax
  80169d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8016a0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8016a5:	a3 40 60 80 00       	mov    %eax,0x806040
  8016aa:	85 f6                	test   %esi,%esi
  8016ac:	74 29                	je     8016d7 <ipc_recv+0x53>
  8016ae:	8b 40 4c             	mov    0x4c(%eax),%eax
  8016b1:	3b 06                	cmp    (%esi),%eax
  8016b3:	75 22                	jne    8016d7 <ipc_recv+0x53>
  8016b5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8016bb:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8016c1:	c7 04 24 8a 2e 80 00 	movl   $0x802e8a,(%esp)
  8016c8:	e8 28 f0 ff ff       	call   8006f5 <cprintf>
  8016cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016d2:	e9 8a 00 00 00       	jmp    801761 <ipc_recv+0xdd>
  8016d7:	e8 61 fe ff ff       	call   80153d <sys_getenvid>
  8016dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016e1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8016e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8016e9:	a3 40 60 80 00       	mov    %eax,0x806040
  8016ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016f1:	89 04 24             	mov    %eax,(%esp)
  8016f4:	e8 46 fb ff ff       	call   80123f <sys_ipc_recv>
  8016f9:	89 c3                	mov    %eax,%ebx
  8016fb:	85 c0                	test   %eax,%eax
  8016fd:	79 1a                	jns    801719 <ipc_recv+0x95>
  8016ff:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801705:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  80170b:	c7 04 24 be 2e 80 00 	movl   $0x802ebe,(%esp)
  801712:	e8 de ef ff ff       	call   8006f5 <cprintf>
  801717:	eb 48                	jmp    801761 <ipc_recv+0xdd>
  801719:	e8 1f fe ff ff       	call   80153d <sys_getenvid>
  80171e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801723:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801726:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80172b:	a3 40 60 80 00       	mov    %eax,0x806040
  801730:	85 f6                	test   %esi,%esi
  801732:	74 05                	je     801739 <ipc_recv+0xb5>
  801734:	8b 40 74             	mov    0x74(%eax),%eax
  801737:	89 06                	mov    %eax,(%esi)
  801739:	85 ff                	test   %edi,%edi
  80173b:	74 0a                	je     801747 <ipc_recv+0xc3>
  80173d:	a1 40 60 80 00       	mov    0x806040,%eax
  801742:	8b 40 78             	mov    0x78(%eax),%eax
  801745:	89 07                	mov    %eax,(%edi)
  801747:	e8 f1 fd ff ff       	call   80153d <sys_getenvid>
  80174c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801751:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801754:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801759:	a3 40 60 80 00       	mov    %eax,0x806040
  80175e:	8b 58 70             	mov    0x70(%eax),%ebx
  801761:	89 d8                	mov    %ebx,%eax
  801763:	83 c4 0c             	add    $0xc,%esp
  801766:	5b                   	pop    %ebx
  801767:	5e                   	pop    %esi
  801768:	5f                   	pop    %edi
  801769:	5d                   	pop    %ebp
  80176a:	c3                   	ret    
  80176b:	00 00                	add    %al,(%eax)
  80176d:	00 00                	add    %al,(%eax)
	...

00801770 <fd2num>:
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	8b 45 08             	mov    0x8(%ebp),%eax
  801776:	05 00 00 00 30       	add    $0x30000000,%eax
  80177b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80177e:	5d                   	pop    %ebp
  80177f:	c3                   	ret    

00801780 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801786:	8b 45 08             	mov    0x8(%ebp),%eax
  801789:	89 04 24             	mov    %eax,(%esp)
  80178c:	e8 df ff ff ff       	call   801770 <fd2num>
  801791:	c1 e0 0c             	shl    $0xc,%eax
  801794:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801799:	c9                   	leave  
  80179a:	c3                   	ret    

0080179b <fd_alloc>:

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
  80179b:	55                   	push   %ebp
  80179c:	89 e5                	mov    %esp,%ebp
  80179e:	53                   	push   %ebx
  80179f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8017a2:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  8017a7:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  8017a9:	89 d0                	mov    %edx,%eax
  8017ab:	c1 e8 16             	shr    $0x16,%eax
  8017ae:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  8017b5:	a8 01                	test   $0x1,%al
  8017b7:	74 10                	je     8017c9 <fd_alloc+0x2e>
  8017b9:	89 d0                	mov    %edx,%eax
  8017bb:	c1 e8 0c             	shr    $0xc,%eax
  8017be:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  8017c5:	a8 01                	test   $0x1,%al
  8017c7:	75 09                	jne    8017d2 <fd_alloc+0x37>
			*fd_store = fd;
  8017c9:	89 0b                	mov    %ecx,(%ebx)
  8017cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d0:	eb 19                	jmp    8017eb <fd_alloc+0x50>
			return 0;
  8017d2:	81 c2 00 10 00 00    	add    $0x1000,%edx
  8017d8:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  8017de:	75 c7                	jne    8017a7 <fd_alloc+0xc>
		}
	}
	*fd_store = 0;
  8017e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8017e6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8017eb:	5b                   	pop    %ebx
  8017ec:	5d                   	pop    %ebp
  8017ed:	c3                   	ret    

008017ee <fd_lookup>:

// Check that fdnum is in range and mapped.
// If it is, set *fd_store to the fd page virtual address.
//
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8017f4:	83 f8 1f             	cmp    $0x1f,%eax
  8017f7:	77 35                	ja     80182e <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8017f9:	c1 e0 0c             	shl    $0xc,%eax
  8017fc:	8d 90 00 00 00 d0    	lea    0xd0000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  801802:	89 d0                	mov    %edx,%eax
  801804:	c1 e8 16             	shr    $0x16,%eax
  801807:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  80180e:	a8 01                	test   $0x1,%al
  801810:	74 1c                	je     80182e <fd_lookup+0x40>
  801812:	89 d0                	mov    %edx,%eax
  801814:	c1 e8 0c             	shr    $0xc,%eax
  801817:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  80181e:	a8 01                	test   $0x1,%al
  801820:	74 0c                	je     80182e <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801822:	8b 45 0c             	mov    0xc(%ebp),%eax
  801825:	89 10                	mov    %edx,(%eax)
  801827:	b8 00 00 00 00       	mov    $0x0,%eax
  80182c:	eb 05                	jmp    801833 <fd_lookup+0x45>
	return 0;
  80182e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801833:	5d                   	pop    %ebp
  801834:	c3                   	ret    

00801835 <seek>:

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
  801835:	55                   	push   %ebp
  801836:	89 e5                	mov    %esp,%ebp
  801838:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80183b:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  80183e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801842:	8b 45 08             	mov    0x8(%ebp),%eax
  801845:	89 04 24             	mov    %eax,(%esp)
  801848:	e8 a1 ff ff ff       	call   8017ee <fd_lookup>
  80184d:	85 c0                	test   %eax,%eax
  80184f:	78 0e                	js     80185f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801851:	8b 55 0c             	mov    0xc(%ebp),%edx
  801854:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  801857:	89 50 04             	mov    %edx,0x4(%eax)
  80185a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80185f:	c9                   	leave  
  801860:	c3                   	ret    

00801861 <dev_lookup>:
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
  801864:	53                   	push   %ebx
  801865:	83 ec 14             	sub    $0x14,%esp
  801868:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80186b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80186e:	ba 08 60 80 00       	mov    $0x806008,%edx
  801873:	b8 00 00 00 00       	mov    $0x0,%eax
  801878:	39 0d 08 60 80 00    	cmp    %ecx,0x806008
  80187e:	75 12                	jne    801892 <dev_lookup+0x31>
  801880:	eb 04                	jmp    801886 <dev_lookup+0x25>
  801882:	39 0a                	cmp    %ecx,(%edx)
  801884:	75 0c                	jne    801892 <dev_lookup+0x31>
  801886:	89 13                	mov    %edx,(%ebx)
  801888:	b8 00 00 00 00       	mov    $0x0,%eax
  80188d:	8d 76 00             	lea    0x0(%esi),%esi
  801890:	eb 35                	jmp    8018c7 <dev_lookup+0x66>
  801892:	83 c0 01             	add    $0x1,%eax
  801895:	8b 14 85 50 2f 80 00 	mov    0x802f50(,%eax,4),%edx
  80189c:	85 d2                	test   %edx,%edx
  80189e:	75 e2                	jne    801882 <dev_lookup+0x21>
  8018a0:	a1 40 60 80 00       	mov    0x806040,%eax
  8018a5:	8b 40 4c             	mov    0x4c(%eax),%eax
  8018a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b0:	c7 04 24 d0 2e 80 00 	movl   $0x802ed0,(%esp)
  8018b7:	e8 39 ee ff ff       	call   8006f5 <cprintf>
  8018bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8018c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018c7:	83 c4 14             	add    $0x14,%esp
  8018ca:	5b                   	pop    %ebx
  8018cb:	5d                   	pop    %ebp
  8018cc:	c3                   	ret    

008018cd <fstat>:

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
  8018cd:	55                   	push   %ebp
  8018ce:	89 e5                	mov    %esp,%ebp
  8018d0:	53                   	push   %ebx
  8018d1:	83 ec 24             	sub    $0x24,%esp
  8018d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018d7:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8018da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018de:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e1:	89 04 24             	mov    %eax,(%esp)
  8018e4:	e8 05 ff ff ff       	call   8017ee <fd_lookup>
  8018e9:	89 c2                	mov    %eax,%edx
  8018eb:	85 c0                	test   %eax,%eax
  8018ed:	78 57                	js     801946 <fstat+0x79>
  8018ef:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  8018f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f6:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8018f9:	8b 00                	mov    (%eax),%eax
  8018fb:	89 04 24             	mov    %eax,(%esp)
  8018fe:	e8 5e ff ff ff       	call   801861 <dev_lookup>
  801903:	89 c2                	mov    %eax,%edx
  801905:	85 c0                	test   %eax,%eax
  801907:	78 3d                	js     801946 <fstat+0x79>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801909:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  80190e:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  801911:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801915:	74 2f                	je     801946 <fstat+0x79>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801917:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80191a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801921:	00 00 00 
	stat->st_isdir = 0;
  801924:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80192b:	00 00 00 
	stat->st_dev = dev;
  80192e:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801931:	89 93 88 00 00 00    	mov    %edx,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801937:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80193b:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80193e:	89 04 24             	mov    %eax,(%esp)
  801941:	ff 52 14             	call   *0x14(%edx)
  801944:	89 c2                	mov    %eax,%edx
}
  801946:	89 d0                	mov    %edx,%eax
  801948:	83 c4 24             	add    $0x24,%esp
  80194b:	5b                   	pop    %ebx
  80194c:	5d                   	pop    %ebp
  80194d:	c3                   	ret    

0080194e <ftruncate>:
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	53                   	push   %ebx
  801952:	83 ec 24             	sub    $0x24,%esp
  801955:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801958:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80195b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195f:	89 1c 24             	mov    %ebx,(%esp)
  801962:	e8 87 fe ff ff       	call   8017ee <fd_lookup>
  801967:	85 c0                	test   %eax,%eax
  801969:	78 61                	js     8019cc <ftruncate+0x7e>
  80196b:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80196e:	8b 10                	mov    (%eax),%edx
  801970:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801973:	89 44 24 04          	mov    %eax,0x4(%esp)
  801977:	89 14 24             	mov    %edx,(%esp)
  80197a:	e8 e2 fe ff ff       	call   801861 <dev_lookup>
  80197f:	85 c0                	test   %eax,%eax
  801981:	78 49                	js     8019cc <ftruncate+0x7e>
  801983:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801986:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  80198a:	75 23                	jne    8019af <ftruncate+0x61>
  80198c:	a1 40 60 80 00       	mov    0x806040,%eax
  801991:	8b 40 4c             	mov    0x4c(%eax),%eax
  801994:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801998:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199c:	c7 04 24 f0 2e 80 00 	movl   $0x802ef0,(%esp)
  8019a3:	e8 4d ed ff ff       	call   8006f5 <cprintf>
  8019a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019ad:	eb 1d                	jmp    8019cc <ftruncate+0x7e>
  8019af:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  8019b2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019b7:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  8019bb:	74 0f                	je     8019cc <ftruncate+0x7e>
  8019bd:	8b 52 18             	mov    0x18(%edx),%edx
  8019c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c7:	89 0c 24             	mov    %ecx,(%esp)
  8019ca:	ff d2                	call   *%edx
  8019cc:	83 c4 24             	add    $0x24,%esp
  8019cf:	5b                   	pop    %ebx
  8019d0:	5d                   	pop    %ebp
  8019d1:	c3                   	ret    

008019d2 <write>:
  8019d2:	55                   	push   %ebp
  8019d3:	89 e5                	mov    %esp,%ebp
  8019d5:	53                   	push   %ebx
  8019d6:	83 ec 24             	sub    $0x24,%esp
  8019d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8019dc:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8019df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e3:	89 1c 24             	mov    %ebx,(%esp)
  8019e6:	e8 03 fe ff ff       	call   8017ee <fd_lookup>
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	78 68                	js     801a57 <write+0x85>
  8019ef:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8019f2:	8b 10                	mov    (%eax),%edx
  8019f4:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  8019f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019fb:	89 14 24             	mov    %edx,(%esp)
  8019fe:	e8 5e fe ff ff       	call   801861 <dev_lookup>
  801a03:	85 c0                	test   %eax,%eax
  801a05:	78 50                	js     801a57 <write+0x85>
  801a07:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801a0a:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801a0e:	75 23                	jne    801a33 <write+0x61>
  801a10:	a1 40 60 80 00       	mov    0x806040,%eax
  801a15:	8b 40 4c             	mov    0x4c(%eax),%eax
  801a18:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a20:	c7 04 24 14 2f 80 00 	movl   $0x802f14,(%esp)
  801a27:	e8 c9 ec ff ff       	call   8006f5 <cprintf>
  801a2c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a31:	eb 24                	jmp    801a57 <write+0x85>
  801a33:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801a36:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a3b:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  801a3f:	74 16                	je     801a57 <write+0x85>
  801a41:	8b 42 0c             	mov    0xc(%edx),%eax
  801a44:	8b 55 10             	mov    0x10(%ebp),%edx
  801a47:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a4e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a52:	89 0c 24             	mov    %ecx,(%esp)
  801a55:	ff d0                	call   *%eax
  801a57:	83 c4 24             	add    $0x24,%esp
  801a5a:	5b                   	pop    %ebx
  801a5b:	5d                   	pop    %ebp
  801a5c:	c3                   	ret    

00801a5d <read>:
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	53                   	push   %ebx
  801a61:	83 ec 24             	sub    $0x24,%esp
  801a64:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a67:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801a6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a6e:	89 1c 24             	mov    %ebx,(%esp)
  801a71:	e8 78 fd ff ff       	call   8017ee <fd_lookup>
  801a76:	85 c0                	test   %eax,%eax
  801a78:	78 6d                	js     801ae7 <read+0x8a>
  801a7a:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801a7d:	8b 10                	mov    (%eax),%edx
  801a7f:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801a82:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a86:	89 14 24             	mov    %edx,(%esp)
  801a89:	e8 d3 fd ff ff       	call   801861 <dev_lookup>
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	78 55                	js     801ae7 <read+0x8a>
  801a92:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801a95:	8b 41 08             	mov    0x8(%ecx),%eax
  801a98:	83 e0 03             	and    $0x3,%eax
  801a9b:	83 f8 01             	cmp    $0x1,%eax
  801a9e:	75 23                	jne    801ac3 <read+0x66>
  801aa0:	a1 40 60 80 00       	mov    0x806040,%eax
  801aa5:	8b 40 4c             	mov    0x4c(%eax),%eax
  801aa8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801aac:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab0:	c7 04 24 31 2f 80 00 	movl   $0x802f31,(%esp)
  801ab7:	e8 39 ec ff ff       	call   8006f5 <cprintf>
  801abc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ac1:	eb 24                	jmp    801ae7 <read+0x8a>
  801ac3:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801ac6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801acb:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  801acf:	74 16                	je     801ae7 <read+0x8a>
  801ad1:	8b 42 08             	mov    0x8(%edx),%eax
  801ad4:	8b 55 10             	mov    0x10(%ebp),%edx
  801ad7:	89 54 24 08          	mov    %edx,0x8(%esp)
  801adb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ade:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ae2:	89 0c 24             	mov    %ecx,(%esp)
  801ae5:	ff d0                	call   *%eax
  801ae7:	83 c4 24             	add    $0x24,%esp
  801aea:	5b                   	pop    %ebx
  801aeb:	5d                   	pop    %ebp
  801aec:	c3                   	ret    

00801aed <readn>:
  801aed:	55                   	push   %ebp
  801aee:	89 e5                	mov    %esp,%ebp
  801af0:	57                   	push   %edi
  801af1:	56                   	push   %esi
  801af2:	53                   	push   %ebx
  801af3:	83 ec 0c             	sub    $0xc,%esp
  801af6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801af9:	8b 75 10             	mov    0x10(%ebp),%esi
  801afc:	b8 00 00 00 00       	mov    $0x0,%eax
  801b01:	85 f6                	test   %esi,%esi
  801b03:	74 36                	je     801b3b <readn+0x4e>
  801b05:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b0a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b0f:	89 f0                	mov    %esi,%eax
  801b11:	29 d0                	sub    %edx,%eax
  801b13:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b17:	8d 04 17             	lea    (%edi,%edx,1),%eax
  801b1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b21:	89 04 24             	mov    %eax,(%esp)
  801b24:	e8 34 ff ff ff       	call   801a5d <read>
  801b29:	85 c0                	test   %eax,%eax
  801b2b:	78 0e                	js     801b3b <readn+0x4e>
  801b2d:	85 c0                	test   %eax,%eax
  801b2f:	74 08                	je     801b39 <readn+0x4c>
  801b31:	01 c3                	add    %eax,%ebx
  801b33:	89 da                	mov    %ebx,%edx
  801b35:	39 f3                	cmp    %esi,%ebx
  801b37:	72 d6                	jb     801b0f <readn+0x22>
  801b39:	89 d8                	mov    %ebx,%eax
  801b3b:	83 c4 0c             	add    $0xc,%esp
  801b3e:	5b                   	pop    %ebx
  801b3f:	5e                   	pop    %esi
  801b40:	5f                   	pop    %edi
  801b41:	5d                   	pop    %ebp
  801b42:	c3                   	ret    

00801b43 <fd_close>:
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	83 ec 28             	sub    $0x28,%esp
  801b49:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  801b4c:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  801b4f:	8b 75 08             	mov    0x8(%ebp),%esi
  801b52:	89 34 24             	mov    %esi,(%esp)
  801b55:	e8 16 fc ff ff       	call   801770 <fd2num>
  801b5a:	8d 55 f4             	lea    0xfffffff4(%ebp),%edx
  801b5d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b61:	89 04 24             	mov    %eax,(%esp)
  801b64:	e8 85 fc ff ff       	call   8017ee <fd_lookup>
  801b69:	89 c3                	mov    %eax,%ebx
  801b6b:	85 c0                	test   %eax,%eax
  801b6d:	78 05                	js     801b74 <fd_close+0x31>
  801b6f:	3b 75 f4             	cmp    0xfffffff4(%ebp),%esi
  801b72:	74 0e                	je     801b82 <fd_close+0x3f>
  801b74:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b78:	75 45                	jne    801bbf <fd_close+0x7c>
  801b7a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b7f:	90                   	nop    
  801b80:	eb 3d                	jmp    801bbf <fd_close+0x7c>
  801b82:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  801b85:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b89:	8b 06                	mov    (%esi),%eax
  801b8b:	89 04 24             	mov    %eax,(%esp)
  801b8e:	e8 ce fc ff ff       	call   801861 <dev_lookup>
  801b93:	89 c3                	mov    %eax,%ebx
  801b95:	85 c0                	test   %eax,%eax
  801b97:	78 16                	js     801baf <fd_close+0x6c>
  801b99:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  801b9c:	8b 40 10             	mov    0x10(%eax),%eax
  801b9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ba4:	85 c0                	test   %eax,%eax
  801ba6:	74 07                	je     801baf <fd_close+0x6c>
  801ba8:	89 34 24             	mov    %esi,(%esp)
  801bab:	ff d0                	call   *%eax
  801bad:	89 c3                	mov    %eax,%ebx
  801baf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bb3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bba:	e8 2f f8 ff ff       	call   8013ee <sys_page_unmap>
  801bbf:	89 d8                	mov    %ebx,%eax
  801bc1:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  801bc4:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  801bc7:	89 ec                	mov    %ebp,%esp
  801bc9:	5d                   	pop    %ebp
  801bca:	c3                   	ret    

00801bcb <close>:
  801bcb:	55                   	push   %ebp
  801bcc:	89 e5                	mov    %esp,%ebp
  801bce:	83 ec 18             	sub    $0x18,%esp
  801bd1:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  801bd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdb:	89 04 24             	mov    %eax,(%esp)
  801bde:	e8 0b fc ff ff       	call   8017ee <fd_lookup>
  801be3:	85 c0                	test   %eax,%eax
  801be5:	78 13                	js     801bfa <close+0x2f>
  801be7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801bee:	00 
  801bef:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  801bf2:	89 04 24             	mov    %eax,(%esp)
  801bf5:	e8 49 ff ff ff       	call   801b43 <fd_close>
  801bfa:	c9                   	leave  
  801bfb:	c3                   	ret    

00801bfc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	83 ec 18             	sub    $0x18,%esp
  801c02:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  801c05:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801c08:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c0f:	00 
  801c10:	8b 45 08             	mov    0x8(%ebp),%eax
  801c13:	89 04 24             	mov    %eax,(%esp)
  801c16:	e8 58 03 00 00       	call   801f73 <open>
  801c1b:	89 c6                	mov    %eax,%esi
  801c1d:	85 c0                	test   %eax,%eax
  801c1f:	78 1b                	js     801c3c <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801c21:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c24:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c28:	89 34 24             	mov    %esi,(%esp)
  801c2b:	e8 9d fc ff ff       	call   8018cd <fstat>
  801c30:	89 c3                	mov    %eax,%ebx
	close(fd);
  801c32:	89 34 24             	mov    %esi,(%esp)
  801c35:	e8 91 ff ff ff       	call   801bcb <close>
  801c3a:	89 de                	mov    %ebx,%esi
	return r;
}
  801c3c:	89 f0                	mov    %esi,%eax
  801c3e:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  801c41:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  801c44:	89 ec                	mov    %ebp,%esp
  801c46:	5d                   	pop    %ebp
  801c47:	c3                   	ret    

00801c48 <dup>:
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	83 ec 38             	sub    $0x38,%esp
  801c4e:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801c51:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  801c54:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801c57:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c5a:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  801c5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c61:	8b 45 08             	mov    0x8(%ebp),%eax
  801c64:	89 04 24             	mov    %eax,(%esp)
  801c67:	e8 82 fb ff ff       	call   8017ee <fd_lookup>
  801c6c:	89 c3                	mov    %eax,%ebx
  801c6e:	85 c0                	test   %eax,%eax
  801c70:	0f 88 e1 00 00 00    	js     801d57 <dup+0x10f>
  801c76:	89 3c 24             	mov    %edi,(%esp)
  801c79:	e8 4d ff ff ff       	call   801bcb <close>
  801c7e:	89 f8                	mov    %edi,%eax
  801c80:	c1 e0 0c             	shl    $0xc,%eax
  801c83:	8d b0 00 00 00 d0    	lea    0xd0000000(%eax),%esi
  801c89:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  801c8c:	89 04 24             	mov    %eax,(%esp)
  801c8f:	e8 ec fa ff ff       	call   801780 <fd2data>
  801c94:	89 c3                	mov    %eax,%ebx
  801c96:	89 34 24             	mov    %esi,(%esp)
  801c99:	e8 e2 fa ff ff       	call   801780 <fd2data>
  801c9e:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  801ca1:	89 d8                	mov    %ebx,%eax
  801ca3:	c1 e8 16             	shr    $0x16,%eax
  801ca6:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  801cad:	a8 01                	test   $0x1,%al
  801caf:	74 45                	je     801cf6 <dup+0xae>
  801cb1:	89 da                	mov    %ebx,%edx
  801cb3:	c1 ea 0c             	shr    $0xc,%edx
  801cb6:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  801cbd:	a8 01                	test   $0x1,%al
  801cbf:	74 35                	je     801cf6 <dup+0xae>
  801cc1:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  801cc8:	25 07 0e 00 00       	and    $0xe07,%eax
  801ccd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801cd1:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801cd4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cd8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cdf:	00 
  801ce0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ce4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ceb:	e8 5c f7 ff ff       	call   80144c <sys_page_map>
  801cf0:	89 c3                	mov    %eax,%ebx
  801cf2:	85 c0                	test   %eax,%eax
  801cf4:	78 3e                	js     801d34 <dup+0xec>
  801cf6:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  801cf9:	89 d0                	mov    %edx,%eax
  801cfb:	c1 e8 0c             	shr    $0xc,%eax
  801cfe:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  801d05:	25 07 0e 00 00       	and    $0xe07,%eax
  801d0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  801d0e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801d12:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d19:	00 
  801d1a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d1e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d25:	e8 22 f7 ff ff       	call   80144c <sys_page_map>
  801d2a:	89 c3                	mov    %eax,%ebx
  801d2c:	85 c0                	test   %eax,%eax
  801d2e:	78 04                	js     801d34 <dup+0xec>
  801d30:	89 fb                	mov    %edi,%ebx
  801d32:	eb 23                	jmp    801d57 <dup+0x10f>
  801d34:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d3f:	e8 aa f6 ff ff       	call   8013ee <sys_page_unmap>
  801d44:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801d47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d52:	e8 97 f6 ff ff       	call   8013ee <sys_page_unmap>
  801d57:	89 d8                	mov    %ebx,%eax
  801d59:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801d5c:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801d5f:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801d62:	89 ec                	mov    %ebp,%esp
  801d64:	5d                   	pop    %ebp
  801d65:	c3                   	ret    

00801d66 <close_all>:
  801d66:	55                   	push   %ebp
  801d67:	89 e5                	mov    %esp,%ebp
  801d69:	53                   	push   %ebx
  801d6a:	83 ec 04             	sub    $0x4,%esp
  801d6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d72:	89 1c 24             	mov    %ebx,(%esp)
  801d75:	e8 51 fe ff ff       	call   801bcb <close>
  801d7a:	83 c3 01             	add    $0x1,%ebx
  801d7d:	83 fb 20             	cmp    $0x20,%ebx
  801d80:	75 f0                	jne    801d72 <close_all+0xc>
  801d82:	83 c4 04             	add    $0x4,%esp
  801d85:	5b                   	pop    %ebx
  801d86:	5d                   	pop    %ebp
  801d87:	c3                   	ret    

00801d88 <fsipc>:
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801d88:	55                   	push   %ebp
  801d89:	89 e5                	mov    %esp,%ebp
  801d8b:	53                   	push   %ebx
  801d8c:	83 ec 14             	sub    $0x14,%esp
  801d8f:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801d91:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801d97:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d9e:	00 
  801d9f:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801da6:	00 
  801da7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dab:	89 14 24             	mov    %edx,(%esp)
  801dae:	e8 1d f8 ff ff       	call   8015d0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801db3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801dba:	00 
  801dbb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dbf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dc6:	e8 b9 f8 ff ff       	call   801684 <ipc_recv>
}
  801dcb:	83 c4 14             	add    $0x14,%esp
  801dce:	5b                   	pop    %ebx
  801dcf:	5d                   	pop    %ebp
  801dd0:	c3                   	ret    

00801dd1 <sync>:

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
  801dd1:	55                   	push   %ebp
  801dd2:	89 e5                	mov    %esp,%ebp
  801dd4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801dd7:	ba 00 00 00 00       	mov    $0x0,%edx
  801ddc:	b8 08 00 00 00       	mov    $0x8,%eax
  801de1:	e8 a2 ff ff ff       	call   801d88 <fsipc>
}
  801de6:	c9                   	leave  
  801de7:	c3                   	ret    

00801de8 <devfile_trunc>:
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	83 ec 08             	sub    $0x8,%esp
  801dee:	8b 45 08             	mov    0x8(%ebp),%eax
  801df1:	8b 40 0c             	mov    0xc(%eax),%eax
  801df4:	a3 00 30 80 00       	mov    %eax,0x803000
  801df9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dfc:	a3 04 30 80 00       	mov    %eax,0x803004
  801e01:	ba 00 00 00 00       	mov    $0x0,%edx
  801e06:	b8 02 00 00 00       	mov    $0x2,%eax
  801e0b:	e8 78 ff ff ff       	call   801d88 <fsipc>
  801e10:	c9                   	leave  
  801e11:	c3                   	ret    

00801e12 <devfile_flush>:
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	83 ec 08             	sub    $0x8,%esp
  801e18:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1b:	8b 40 0c             	mov    0xc(%eax),%eax
  801e1e:	a3 00 30 80 00       	mov    %eax,0x803000
  801e23:	ba 00 00 00 00       	mov    $0x0,%edx
  801e28:	b8 06 00 00 00       	mov    $0x6,%eax
  801e2d:	e8 56 ff ff ff       	call   801d88 <fsipc>
  801e32:	c9                   	leave  
  801e33:	c3                   	ret    

00801e34 <devfile_stat>:
  801e34:	55                   	push   %ebp
  801e35:	89 e5                	mov    %esp,%ebp
  801e37:	53                   	push   %ebx
  801e38:	83 ec 14             	sub    $0x14,%esp
  801e3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e41:	8b 40 0c             	mov    0xc(%eax),%eax
  801e44:	a3 00 30 80 00       	mov    %eax,0x803000
  801e49:	ba 00 00 00 00       	mov    $0x0,%edx
  801e4e:	b8 05 00 00 00       	mov    $0x5,%eax
  801e53:	e8 30 ff ff ff       	call   801d88 <fsipc>
  801e58:	85 c0                	test   %eax,%eax
  801e5a:	78 2b                	js     801e87 <devfile_stat+0x53>
  801e5c:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801e63:	00 
  801e64:	89 1c 24             	mov    %ebx,(%esp)
  801e67:	e8 15 ef ff ff       	call   800d81 <strcpy>
  801e6c:	a1 80 30 80 00       	mov    0x803080,%eax
  801e71:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  801e77:	a1 84 30 80 00       	mov    0x803084,%eax
  801e7c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801e82:	b8 00 00 00 00       	mov    $0x0,%eax
  801e87:	83 c4 14             	add    $0x14,%esp
  801e8a:	5b                   	pop    %ebx
  801e8b:	5d                   	pop    %ebp
  801e8c:	c3                   	ret    

00801e8d <devfile_write>:
  801e8d:	55                   	push   %ebp
  801e8e:	89 e5                	mov    %esp,%ebp
  801e90:	83 ec 18             	sub    $0x18,%esp
  801e93:	8b 55 10             	mov    0x10(%ebp),%edx
  801e96:	8b 45 08             	mov    0x8(%ebp),%eax
  801e99:	8b 40 0c             	mov    0xc(%eax),%eax
  801e9c:	a3 00 30 80 00       	mov    %eax,0x803000
  801ea1:	89 d0                	mov    %edx,%eax
  801ea3:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  801ea9:	76 05                	jbe    801eb0 <devfile_write+0x23>
  801eab:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801eb0:	89 15 04 30 80 00    	mov    %edx,0x803004
  801eb6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eba:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ebd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec1:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801ec8:	e8 bd f0 ff ff       	call   800f8a <memmove>
  801ecd:	ba 00 00 00 00       	mov    $0x0,%edx
  801ed2:	b8 04 00 00 00       	mov    $0x4,%eax
  801ed7:	e8 ac fe ff ff       	call   801d88 <fsipc>
  801edc:	c9                   	leave  
  801edd:	c3                   	ret    

00801ede <devfile_read>:
  801ede:	55                   	push   %ebp
  801edf:	89 e5                	mov    %esp,%ebp
  801ee1:	53                   	push   %ebx
  801ee2:	83 ec 14             	sub    $0x14,%esp
  801ee5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee8:	8b 40 0c             	mov    0xc(%eax),%eax
  801eeb:	a3 00 30 80 00       	mov    %eax,0x803000
  801ef0:	8b 45 10             	mov    0x10(%ebp),%eax
  801ef3:	a3 04 30 80 00       	mov    %eax,0x803004
  801ef8:	ba 00 30 80 00       	mov    $0x803000,%edx
  801efd:	b8 03 00 00 00       	mov    $0x3,%eax
  801f02:	e8 81 fe ff ff       	call   801d88 <fsipc>
  801f07:	89 c3                	mov    %eax,%ebx
  801f09:	85 c0                	test   %eax,%eax
  801f0b:	7e 17                	jle    801f24 <devfile_read+0x46>
  801f0d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f11:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801f18:	00 
  801f19:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f1c:	89 04 24             	mov    %eax,(%esp)
  801f1f:	e8 66 f0 ff ff       	call   800f8a <memmove>
  801f24:	89 d8                	mov    %ebx,%eax
  801f26:	83 c4 14             	add    $0x14,%esp
  801f29:	5b                   	pop    %ebx
  801f2a:	5d                   	pop    %ebp
  801f2b:	c3                   	ret    

00801f2c <remove>:
  801f2c:	55                   	push   %ebp
  801f2d:	89 e5                	mov    %esp,%ebp
  801f2f:	53                   	push   %ebx
  801f30:	83 ec 14             	sub    $0x14,%esp
  801f33:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801f36:	89 1c 24             	mov    %ebx,(%esp)
  801f39:	e8 f2 ed ff ff       	call   800d30 <strlen>
  801f3e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  801f43:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801f48:	7f 21                	jg     801f6b <remove+0x3f>
  801f4a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f4e:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801f55:	e8 27 ee ff ff       	call   800d81 <strcpy>
  801f5a:	ba 00 00 00 00       	mov    $0x0,%edx
  801f5f:	b8 07 00 00 00       	mov    $0x7,%eax
  801f64:	e8 1f fe ff ff       	call   801d88 <fsipc>
  801f69:	89 c2                	mov    %eax,%edx
  801f6b:	89 d0                	mov    %edx,%eax
  801f6d:	83 c4 14             	add    $0x14,%esp
  801f70:	5b                   	pop    %ebx
  801f71:	5d                   	pop    %ebp
  801f72:	c3                   	ret    

00801f73 <open>:
  801f73:	55                   	push   %ebp
  801f74:	89 e5                	mov    %esp,%ebp
  801f76:	56                   	push   %esi
  801f77:	53                   	push   %ebx
  801f78:	83 ec 30             	sub    $0x30,%esp
  801f7b:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801f7e:	89 04 24             	mov    %eax,(%esp)
  801f81:	e8 15 f8 ff ff       	call   80179b <fd_alloc>
  801f86:	89 c3                	mov    %eax,%ebx
  801f88:	85 c0                	test   %eax,%eax
  801f8a:	79 18                	jns    801fa4 <open+0x31>
  801f8c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f93:	00 
  801f94:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801f97:	89 04 24             	mov    %eax,(%esp)
  801f9a:	e8 a4 fb ff ff       	call   801b43 <fd_close>
  801f9f:	e9 9f 00 00 00       	jmp    802043 <open+0xd0>
  801fa4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fab:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801fb2:	e8 ca ed ff ff       	call   800d81 <strcpy>
  801fb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fba:	a3 00 34 80 00       	mov    %eax,0x803400
  801fbf:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801fc2:	89 04 24             	mov    %eax,(%esp)
  801fc5:	e8 b6 f7 ff ff       	call   801780 <fd2data>
  801fca:	89 c6                	mov    %eax,%esi
  801fcc:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  801fcf:	b8 01 00 00 00       	mov    $0x1,%eax
  801fd4:	e8 af fd ff ff       	call   801d88 <fsipc>
  801fd9:	89 c3                	mov    %eax,%ebx
  801fdb:	85 c0                	test   %eax,%eax
  801fdd:	79 15                	jns    801ff4 <open+0x81>
  801fdf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801fe6:	00 
  801fe7:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801fea:	89 04 24             	mov    %eax,(%esp)
  801fed:	e8 51 fb ff ff       	call   801b43 <fd_close>
  801ff2:	eb 4f                	jmp    802043 <open+0xd0>
  801ff4:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801ffb:	00 
  801ffc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802000:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802007:	00 
  802008:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80200b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80200f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802016:	e8 31 f4 ff ff       	call   80144c <sys_page_map>
  80201b:	89 c3                	mov    %eax,%ebx
  80201d:	85 c0                	test   %eax,%eax
  80201f:	79 15                	jns    802036 <open+0xc3>
  802021:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802028:	00 
  802029:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80202c:	89 04 24             	mov    %eax,(%esp)
  80202f:	e8 0f fb ff ff       	call   801b43 <fd_close>
  802034:	eb 0d                	jmp    802043 <open+0xd0>
  802036:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  802039:	89 04 24             	mov    %eax,(%esp)
  80203c:	e8 2f f7 ff ff       	call   801770 <fd2num>
  802041:	89 c3                	mov    %eax,%ebx
  802043:	89 d8                	mov    %ebx,%eax
  802045:	83 c4 30             	add    $0x30,%esp
  802048:	5b                   	pop    %ebx
  802049:	5e                   	pop    %esi
  80204a:	5d                   	pop    %ebp
  80204b:	c3                   	ret    
  80204c:	00 00                	add    %al,(%eax)
	...

00802050 <devsock_stat>:
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802050:	55                   	push   %ebp
  802051:	89 e5                	mov    %esp,%ebp
  802053:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  802056:	c7 44 24 04 5c 2f 80 	movl   $0x802f5c,0x4(%esp)
  80205d:	00 
  80205e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802061:	89 04 24             	mov    %eax,(%esp)
  802064:	e8 18 ed ff ff       	call   800d81 <strcpy>
	return 0;
}
  802069:	b8 00 00 00 00       	mov    $0x0,%eax
  80206e:	c9                   	leave  
  80206f:	c3                   	ret    

00802070 <devsock_close>:
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	83 ec 08             	sub    $0x8,%esp
  802076:	8b 45 08             	mov    0x8(%ebp),%eax
  802079:	8b 40 0c             	mov    0xc(%eax),%eax
  80207c:	89 04 24             	mov    %eax,(%esp)
  80207f:	e8 be 02 00 00       	call   802342 <nsipc_close>
  802084:	c9                   	leave  
  802085:	c3                   	ret    

00802086 <devsock_write>:
  802086:	55                   	push   %ebp
  802087:	89 e5                	mov    %esp,%ebp
  802089:	83 ec 18             	sub    $0x18,%esp
  80208c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802093:	00 
  802094:	8b 45 10             	mov    0x10(%ebp),%eax
  802097:	89 44 24 08          	mov    %eax,0x8(%esp)
  80209b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80209e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8020a8:	89 04 24             	mov    %eax,(%esp)
  8020ab:	e8 ce 02 00 00       	call   80237e <nsipc_send>
  8020b0:	c9                   	leave  
  8020b1:	c3                   	ret    

008020b2 <devsock_read>:
  8020b2:	55                   	push   %ebp
  8020b3:	89 e5                	mov    %esp,%ebp
  8020b5:	83 ec 18             	sub    $0x18,%esp
  8020b8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8020bf:	00 
  8020c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8020c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8020d4:	89 04 24             	mov    %eax,(%esp)
  8020d7:	e8 15 03 00 00       	call   8023f1 <nsipc_recv>
  8020dc:	c9                   	leave  
  8020dd:	c3                   	ret    

008020de <alloc_sockfd>:
  8020de:	55                   	push   %ebp
  8020df:	89 e5                	mov    %esp,%ebp
  8020e1:	56                   	push   %esi
  8020e2:	53                   	push   %ebx
  8020e3:	83 ec 20             	sub    $0x20,%esp
  8020e6:	89 c6                	mov    %eax,%esi
  8020e8:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8020eb:	89 04 24             	mov    %eax,(%esp)
  8020ee:	e8 a8 f6 ff ff       	call   80179b <fd_alloc>
  8020f3:	89 c3                	mov    %eax,%ebx
  8020f5:	85 c0                	test   %eax,%eax
  8020f7:	78 21                	js     80211a <alloc_sockfd+0x3c>
  8020f9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802100:	00 
  802101:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  802104:	89 44 24 04          	mov    %eax,0x4(%esp)
  802108:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80210f:	e8 96 f3 ff ff       	call   8014aa <sys_page_alloc>
  802114:	89 c3                	mov    %eax,%ebx
  802116:	85 c0                	test   %eax,%eax
  802118:	79 0a                	jns    802124 <alloc_sockfd+0x46>
  80211a:	89 34 24             	mov    %esi,(%esp)
  80211d:	e8 20 02 00 00       	call   802342 <nsipc_close>
  802122:	eb 28                	jmp    80214c <alloc_sockfd+0x6e>
  802124:	8b 15 24 60 80 00    	mov    0x806024,%edx
  80212a:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80212d:	89 10                	mov    %edx,(%eax)
  80212f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  802132:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  802139:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80213c:	89 70 0c             	mov    %esi,0xc(%eax)
  80213f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  802142:	89 04 24             	mov    %eax,(%esp)
  802145:	e8 26 f6 ff ff       	call   801770 <fd2num>
  80214a:	89 c3                	mov    %eax,%ebx
  80214c:	89 d8                	mov    %ebx,%eax
  80214e:	83 c4 20             	add    $0x20,%esp
  802151:	5b                   	pop    %ebx
  802152:	5e                   	pop    %esi
  802153:	5d                   	pop    %ebp
  802154:	c3                   	ret    

00802155 <socket>:

int
socket(int domain, int type, int protocol)
{
  802155:	55                   	push   %ebp
  802156:	89 e5                	mov    %esp,%ebp
  802158:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80215b:	8b 45 10             	mov    0x10(%ebp),%eax
  80215e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802162:	8b 45 0c             	mov    0xc(%ebp),%eax
  802165:	89 44 24 04          	mov    %eax,0x4(%esp)
  802169:	8b 45 08             	mov    0x8(%ebp),%eax
  80216c:	89 04 24             	mov    %eax,(%esp)
  80216f:	e8 82 01 00 00       	call   8022f6 <nsipc_socket>
  802174:	85 c0                	test   %eax,%eax
  802176:	78 05                	js     80217d <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802178:	e8 61 ff ff ff       	call   8020de <alloc_sockfd>
}
  80217d:	c9                   	leave  
  80217e:	66 90                	xchg   %ax,%ax
  802180:	c3                   	ret    

00802181 <fd2sockid>:
  802181:	55                   	push   %ebp
  802182:	89 e5                	mov    %esp,%ebp
  802184:	83 ec 18             	sub    $0x18,%esp
  802187:	8d 55 fc             	lea    0xfffffffc(%ebp),%edx
  80218a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80218e:	89 04 24             	mov    %eax,(%esp)
  802191:	e8 58 f6 ff ff       	call   8017ee <fd_lookup>
  802196:	89 c2                	mov    %eax,%edx
  802198:	85 c0                	test   %eax,%eax
  80219a:	78 15                	js     8021b1 <fd2sockid+0x30>
  80219c:	8b 4d fc             	mov    0xfffffffc(%ebp),%ecx
  80219f:	8b 01                	mov    (%ecx),%eax
  8021a1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  8021a6:	3b 05 24 60 80 00    	cmp    0x806024,%eax
  8021ac:	75 03                	jne    8021b1 <fd2sockid+0x30>
  8021ae:	8b 51 0c             	mov    0xc(%ecx),%edx
  8021b1:	89 d0                	mov    %edx,%eax
  8021b3:	c9                   	leave  
  8021b4:	c3                   	ret    

008021b5 <listen>:
  8021b5:	55                   	push   %ebp
  8021b6:	89 e5                	mov    %esp,%ebp
  8021b8:	83 ec 08             	sub    $0x8,%esp
  8021bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8021be:	e8 be ff ff ff       	call   802181 <fd2sockid>
  8021c3:	89 c2                	mov    %eax,%edx
  8021c5:	85 c0                	test   %eax,%eax
  8021c7:	78 11                	js     8021da <listen+0x25>
  8021c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021d0:	89 14 24             	mov    %edx,(%esp)
  8021d3:	e8 48 01 00 00       	call   802320 <nsipc_listen>
  8021d8:	89 c2                	mov    %eax,%edx
  8021da:	89 d0                	mov    %edx,%eax
  8021dc:	c9                   	leave  
  8021dd:	c3                   	ret    

008021de <connect>:
  8021de:	55                   	push   %ebp
  8021df:	89 e5                	mov    %esp,%ebp
  8021e1:	83 ec 18             	sub    $0x18,%esp
  8021e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e7:	e8 95 ff ff ff       	call   802181 <fd2sockid>
  8021ec:	89 c2                	mov    %eax,%edx
  8021ee:	85 c0                	test   %eax,%eax
  8021f0:	78 18                	js     80220a <connect+0x2c>
  8021f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8021f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  802200:	89 14 24             	mov    %edx,(%esp)
  802203:	e8 71 02 00 00       	call   802479 <nsipc_connect>
  802208:	89 c2                	mov    %eax,%edx
  80220a:	89 d0                	mov    %edx,%eax
  80220c:	c9                   	leave  
  80220d:	c3                   	ret    

0080220e <shutdown>:
  80220e:	55                   	push   %ebp
  80220f:	89 e5                	mov    %esp,%ebp
  802211:	83 ec 08             	sub    $0x8,%esp
  802214:	8b 45 08             	mov    0x8(%ebp),%eax
  802217:	e8 65 ff ff ff       	call   802181 <fd2sockid>
  80221c:	89 c2                	mov    %eax,%edx
  80221e:	85 c0                	test   %eax,%eax
  802220:	78 11                	js     802233 <shutdown+0x25>
  802222:	8b 45 0c             	mov    0xc(%ebp),%eax
  802225:	89 44 24 04          	mov    %eax,0x4(%esp)
  802229:	89 14 24             	mov    %edx,(%esp)
  80222c:	e8 2b 01 00 00       	call   80235c <nsipc_shutdown>
  802231:	89 c2                	mov    %eax,%edx
  802233:	89 d0                	mov    %edx,%eax
  802235:	c9                   	leave  
  802236:	c3                   	ret    

00802237 <bind>:
  802237:	55                   	push   %ebp
  802238:	89 e5                	mov    %esp,%ebp
  80223a:	83 ec 18             	sub    $0x18,%esp
  80223d:	8b 45 08             	mov    0x8(%ebp),%eax
  802240:	e8 3c ff ff ff       	call   802181 <fd2sockid>
  802245:	89 c2                	mov    %eax,%edx
  802247:	85 c0                	test   %eax,%eax
  802249:	78 18                	js     802263 <bind+0x2c>
  80224b:	8b 45 10             	mov    0x10(%ebp),%eax
  80224e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802252:	8b 45 0c             	mov    0xc(%ebp),%eax
  802255:	89 44 24 04          	mov    %eax,0x4(%esp)
  802259:	89 14 24             	mov    %edx,(%esp)
  80225c:	e8 57 02 00 00       	call   8024b8 <nsipc_bind>
  802261:	89 c2                	mov    %eax,%edx
  802263:	89 d0                	mov    %edx,%eax
  802265:	c9                   	leave  
  802266:	c3                   	ret    

00802267 <accept>:
  802267:	55                   	push   %ebp
  802268:	89 e5                	mov    %esp,%ebp
  80226a:	83 ec 18             	sub    $0x18,%esp
  80226d:	8b 45 08             	mov    0x8(%ebp),%eax
  802270:	e8 0c ff ff ff       	call   802181 <fd2sockid>
  802275:	89 c2                	mov    %eax,%edx
  802277:	85 c0                	test   %eax,%eax
  802279:	78 23                	js     80229e <accept+0x37>
  80227b:	8b 45 10             	mov    0x10(%ebp),%eax
  80227e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802282:	8b 45 0c             	mov    0xc(%ebp),%eax
  802285:	89 44 24 04          	mov    %eax,0x4(%esp)
  802289:	89 14 24             	mov    %edx,(%esp)
  80228c:	e8 66 02 00 00       	call   8024f7 <nsipc_accept>
  802291:	89 c2                	mov    %eax,%edx
  802293:	85 c0                	test   %eax,%eax
  802295:	78 07                	js     80229e <accept+0x37>
  802297:	e8 42 fe ff ff       	call   8020de <alloc_sockfd>
  80229c:	89 c2                	mov    %eax,%edx
  80229e:	89 d0                	mov    %edx,%eax
  8022a0:	c9                   	leave  
  8022a1:	c3                   	ret    
	...

008022b0 <nsipc>:
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8022b0:	55                   	push   %ebp
  8022b1:	89 e5                	mov    %esp,%ebp
  8022b3:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8022b6:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  8022bc:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8022c3:	00 
  8022c4:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8022cb:	00 
  8022cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022d0:	89 14 24             	mov    %edx,(%esp)
  8022d3:	e8 f8 f2 ff ff       	call   8015d0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8022d8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8022df:	00 
  8022e0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8022e7:	00 
  8022e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022ef:	e8 90 f3 ff ff       	call   801684 <ipc_recv>
}
  8022f4:	c9                   	leave  
  8022f5:	c3                   	ret    

008022f6 <nsipc_socket>:

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
  8022f6:	55                   	push   %ebp
  8022f7:	89 e5                	mov    %esp,%ebp
  8022f9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8022fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ff:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.socket.req_type = type;
  802304:	8b 45 0c             	mov    0xc(%ebp),%eax
  802307:	a3 04 50 80 00       	mov    %eax,0x805004
	nsipcbuf.socket.req_protocol = protocol;
  80230c:	8b 45 10             	mov    0x10(%ebp),%eax
  80230f:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SOCKET);
  802314:	b8 09 00 00 00       	mov    $0x9,%eax
  802319:	e8 92 ff ff ff       	call   8022b0 <nsipc>
}
  80231e:	c9                   	leave  
  80231f:	c3                   	ret    

00802320 <nsipc_listen>:
  802320:	55                   	push   %ebp
  802321:	89 e5                	mov    %esp,%ebp
  802323:	83 ec 08             	sub    $0x8,%esp
  802326:	8b 45 08             	mov    0x8(%ebp),%eax
  802329:	a3 00 50 80 00       	mov    %eax,0x805000
  80232e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802331:	a3 04 50 80 00       	mov    %eax,0x805004
  802336:	b8 06 00 00 00       	mov    $0x6,%eax
  80233b:	e8 70 ff ff ff       	call   8022b0 <nsipc>
  802340:	c9                   	leave  
  802341:	c3                   	ret    

00802342 <nsipc_close>:
  802342:	55                   	push   %ebp
  802343:	89 e5                	mov    %esp,%ebp
  802345:	83 ec 08             	sub    $0x8,%esp
  802348:	8b 45 08             	mov    0x8(%ebp),%eax
  80234b:	a3 00 50 80 00       	mov    %eax,0x805000
  802350:	b8 04 00 00 00       	mov    $0x4,%eax
  802355:	e8 56 ff ff ff       	call   8022b0 <nsipc>
  80235a:	c9                   	leave  
  80235b:	c3                   	ret    

0080235c <nsipc_shutdown>:
  80235c:	55                   	push   %ebp
  80235d:	89 e5                	mov    %esp,%ebp
  80235f:	83 ec 08             	sub    $0x8,%esp
  802362:	8b 45 08             	mov    0x8(%ebp),%eax
  802365:	a3 00 50 80 00       	mov    %eax,0x805000
  80236a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80236d:	a3 04 50 80 00       	mov    %eax,0x805004
  802372:	b8 03 00 00 00       	mov    $0x3,%eax
  802377:	e8 34 ff ff ff       	call   8022b0 <nsipc>
  80237c:	c9                   	leave  
  80237d:	c3                   	ret    

0080237e <nsipc_send>:
  80237e:	55                   	push   %ebp
  80237f:	89 e5                	mov    %esp,%ebp
  802381:	53                   	push   %ebx
  802382:	83 ec 14             	sub    $0x14,%esp
  802385:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802388:	8b 45 08             	mov    0x8(%ebp),%eax
  80238b:	a3 00 50 80 00       	mov    %eax,0x805000
  802390:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802396:	7e 24                	jle    8023bc <nsipc_send+0x3e>
  802398:	c7 44 24 0c 68 2f 80 	movl   $0x802f68,0xc(%esp)
  80239f:	00 
  8023a0:	c7 44 24 08 74 2f 80 	movl   $0x802f74,0x8(%esp)
  8023a7:	00 
  8023a8:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  8023af:	00 
  8023b0:	c7 04 24 89 2f 80 00 	movl   $0x802f89,(%esp)
  8023b7:	e8 6c e2 ff ff       	call   800628 <_panic>
  8023bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023c7:	c7 04 24 0c 50 80 00 	movl   $0x80500c,(%esp)
  8023ce:	e8 b7 eb ff ff       	call   800f8a <memmove>
  8023d3:	89 1d 04 50 80 00    	mov    %ebx,0x805004
  8023d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8023dc:	a3 08 50 80 00       	mov    %eax,0x805008
  8023e1:	b8 08 00 00 00       	mov    $0x8,%eax
  8023e6:	e8 c5 fe ff ff       	call   8022b0 <nsipc>
  8023eb:	83 c4 14             	add    $0x14,%esp
  8023ee:	5b                   	pop    %ebx
  8023ef:	5d                   	pop    %ebp
  8023f0:	c3                   	ret    

008023f1 <nsipc_recv>:
  8023f1:	55                   	push   %ebp
  8023f2:	89 e5                	mov    %esp,%ebp
  8023f4:	83 ec 18             	sub    $0x18,%esp
  8023f7:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  8023fa:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  8023fd:	8b 75 10             	mov    0x10(%ebp),%esi
  802400:	8b 45 08             	mov    0x8(%ebp),%eax
  802403:	a3 00 50 80 00       	mov    %eax,0x805000
  802408:	89 35 04 50 80 00    	mov    %esi,0x805004
  80240e:	8b 45 14             	mov    0x14(%ebp),%eax
  802411:	a3 08 50 80 00       	mov    %eax,0x805008
  802416:	b8 07 00 00 00       	mov    $0x7,%eax
  80241b:	e8 90 fe ff ff       	call   8022b0 <nsipc>
  802420:	89 c3                	mov    %eax,%ebx
  802422:	85 c0                	test   %eax,%eax
  802424:	78 47                	js     80246d <nsipc_recv+0x7c>
  802426:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80242b:	7f 05                	jg     802432 <nsipc_recv+0x41>
  80242d:	39 c6                	cmp    %eax,%esi
  80242f:	90                   	nop    
  802430:	7d 24                	jge    802456 <nsipc_recv+0x65>
  802432:	c7 44 24 0c 95 2f 80 	movl   $0x802f95,0xc(%esp)
  802439:	00 
  80243a:	c7 44 24 08 74 2f 80 	movl   $0x802f74,0x8(%esp)
  802441:	00 
  802442:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  802449:	00 
  80244a:	c7 04 24 89 2f 80 00 	movl   $0x802f89,(%esp)
  802451:	e8 d2 e1 ff ff       	call   800628 <_panic>
  802456:	89 44 24 08          	mov    %eax,0x8(%esp)
  80245a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  802461:	00 
  802462:	8b 45 0c             	mov    0xc(%ebp),%eax
  802465:	89 04 24             	mov    %eax,(%esp)
  802468:	e8 1d eb ff ff       	call   800f8a <memmove>
  80246d:	89 d8                	mov    %ebx,%eax
  80246f:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  802472:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  802475:	89 ec                	mov    %ebp,%esp
  802477:	5d                   	pop    %ebp
  802478:	c3                   	ret    

00802479 <nsipc_connect>:
  802479:	55                   	push   %ebp
  80247a:	89 e5                	mov    %esp,%ebp
  80247c:	53                   	push   %ebx
  80247d:	83 ec 14             	sub    $0x14,%esp
  802480:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802483:	8b 45 08             	mov    0x8(%ebp),%eax
  802486:	a3 00 50 80 00       	mov    %eax,0x805000
  80248b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80248f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802492:	89 44 24 04          	mov    %eax,0x4(%esp)
  802496:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  80249d:	e8 e8 ea ff ff       	call   800f8a <memmove>
  8024a2:	89 1d 14 50 80 00    	mov    %ebx,0x805014
  8024a8:	b8 05 00 00 00       	mov    $0x5,%eax
  8024ad:	e8 fe fd ff ff       	call   8022b0 <nsipc>
  8024b2:	83 c4 14             	add    $0x14,%esp
  8024b5:	5b                   	pop    %ebx
  8024b6:	5d                   	pop    %ebp
  8024b7:	c3                   	ret    

008024b8 <nsipc_bind>:
  8024b8:	55                   	push   %ebp
  8024b9:	89 e5                	mov    %esp,%ebp
  8024bb:	53                   	push   %ebx
  8024bc:	83 ec 14             	sub    $0x14,%esp
  8024bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8024c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8024c5:	a3 00 50 80 00       	mov    %eax,0x805000
  8024ca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024d5:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  8024dc:	e8 a9 ea ff ff       	call   800f8a <memmove>
  8024e1:	89 1d 14 50 80 00    	mov    %ebx,0x805014
  8024e7:	b8 02 00 00 00       	mov    $0x2,%eax
  8024ec:	e8 bf fd ff ff       	call   8022b0 <nsipc>
  8024f1:	83 c4 14             	add    $0x14,%esp
  8024f4:	5b                   	pop    %ebx
  8024f5:	5d                   	pop    %ebp
  8024f6:	c3                   	ret    

008024f7 <nsipc_accept>:
  8024f7:	55                   	push   %ebp
  8024f8:	89 e5                	mov    %esp,%ebp
  8024fa:	53                   	push   %ebx
  8024fb:	83 ec 14             	sub    $0x14,%esp
  8024fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802501:	a3 00 50 80 00       	mov    %eax,0x805000
  802506:	b8 01 00 00 00       	mov    $0x1,%eax
  80250b:	e8 a0 fd ff ff       	call   8022b0 <nsipc>
  802510:	89 c3                	mov    %eax,%ebx
  802512:	85 c0                	test   %eax,%eax
  802514:	78 27                	js     80253d <nsipc_accept+0x46>
  802516:	a1 10 50 80 00       	mov    0x805010,%eax
  80251b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80251f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  802526:	00 
  802527:	8b 45 0c             	mov    0xc(%ebp),%eax
  80252a:	89 04 24             	mov    %eax,(%esp)
  80252d:	e8 58 ea ff ff       	call   800f8a <memmove>
  802532:	8b 15 10 50 80 00    	mov    0x805010,%edx
  802538:	8b 45 10             	mov    0x10(%ebp),%eax
  80253b:	89 10                	mov    %edx,(%eax)
  80253d:	89 d8                	mov    %ebx,%eax
  80253f:	83 c4 14             	add    $0x14,%esp
  802542:	5b                   	pop    %ebx
  802543:	5d                   	pop    %ebp
  802544:	c3                   	ret    
	...

00802550 <__udivdi3>:
  802550:	55                   	push   %ebp
  802551:	89 e5                	mov    %esp,%ebp
  802553:	57                   	push   %edi
  802554:	56                   	push   %esi
  802555:	83 ec 1c             	sub    $0x1c,%esp
  802558:	8b 45 10             	mov    0x10(%ebp),%eax
  80255b:	8b 55 14             	mov    0x14(%ebp),%edx
  80255e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802561:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  802564:	89 c1                	mov    %eax,%ecx
  802566:	8b 45 08             	mov    0x8(%ebp),%eax
  802569:	85 d2                	test   %edx,%edx
  80256b:	89 d6                	mov    %edx,%esi
  80256d:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
  802570:	75 1e                	jne    802590 <__udivdi3+0x40>
  802572:	39 f9                	cmp    %edi,%ecx
  802574:	0f 86 8d 00 00 00    	jbe    802607 <__udivdi3+0xb7>
  80257a:	89 fa                	mov    %edi,%edx
  80257c:	f7 f1                	div    %ecx
  80257e:	89 c1                	mov    %eax,%ecx
  802580:	89 c8                	mov    %ecx,%eax
  802582:	89 f2                	mov    %esi,%edx
  802584:	83 c4 1c             	add    $0x1c,%esp
  802587:	5e                   	pop    %esi
  802588:	5f                   	pop    %edi
  802589:	5d                   	pop    %ebp
  80258a:	c3                   	ret    
  80258b:	90                   	nop    
  80258c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802590:	39 fa                	cmp    %edi,%edx
  802592:	0f 87 98 00 00 00    	ja     802630 <__udivdi3+0xe0>
  802598:	0f bd c2             	bsr    %edx,%eax
  80259b:	83 f0 1f             	xor    $0x1f,%eax
  80259e:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8025a1:	74 7f                	je     802622 <__udivdi3+0xd2>
  8025a3:	b8 20 00 00 00       	mov    $0x20,%eax
  8025a8:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  8025ab:	2b 45 e4             	sub    0xffffffe4(%ebp),%eax
  8025ae:	89 c1                	mov    %eax,%ecx
  8025b0:	d3 ea                	shr    %cl,%edx
  8025b2:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8025b6:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8025b9:	89 f0                	mov    %esi,%eax
  8025bb:	d3 e0                	shl    %cl,%eax
  8025bd:	09 c2                	or     %eax,%edx
  8025bf:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8025c2:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  8025c5:	89 fa                	mov    %edi,%edx
  8025c7:	d3 e0                	shl    %cl,%eax
  8025c9:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  8025cd:	89 45 f4             	mov    %eax,0xfffffff4(%ebp)
  8025d0:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8025d3:	d3 e8                	shr    %cl,%eax
  8025d5:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8025d9:	d3 e2                	shl    %cl,%edx
  8025db:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  8025df:	09 d0                	or     %edx,%eax
  8025e1:	d3 ef                	shr    %cl,%edi
  8025e3:	89 fa                	mov    %edi,%edx
  8025e5:	f7 75 e0             	divl   0xffffffe0(%ebp)
  8025e8:	89 d1                	mov    %edx,%ecx
  8025ea:	89 c7                	mov    %eax,%edi
  8025ec:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8025ef:	f7 e7                	mul    %edi
  8025f1:	39 d1                	cmp    %edx,%ecx
  8025f3:	89 c6                	mov    %eax,%esi
  8025f5:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  8025f8:	72 6f                	jb     802669 <__udivdi3+0x119>
  8025fa:	39 ca                	cmp    %ecx,%edx
  8025fc:	74 5e                	je     80265c <__udivdi3+0x10c>
  8025fe:	89 f9                	mov    %edi,%ecx
  802600:	31 f6                	xor    %esi,%esi
  802602:	e9 79 ff ff ff       	jmp    802580 <__udivdi3+0x30>
  802607:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80260a:	85 c0                	test   %eax,%eax
  80260c:	74 32                	je     802640 <__udivdi3+0xf0>
  80260e:	89 f2                	mov    %esi,%edx
  802610:	89 f8                	mov    %edi,%eax
  802612:	f7 f1                	div    %ecx
  802614:	89 c6                	mov    %eax,%esi
  802616:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802619:	f7 f1                	div    %ecx
  80261b:	89 c1                	mov    %eax,%ecx
  80261d:	e9 5e ff ff ff       	jmp    802580 <__udivdi3+0x30>
  802622:	39 d7                	cmp    %edx,%edi
  802624:	77 2a                	ja     802650 <__udivdi3+0x100>
  802626:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  802629:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  80262c:	73 22                	jae    802650 <__udivdi3+0x100>
  80262e:	66 90                	xchg   %ax,%ax
  802630:	31 c9                	xor    %ecx,%ecx
  802632:	31 f6                	xor    %esi,%esi
  802634:	e9 47 ff ff ff       	jmp    802580 <__udivdi3+0x30>
  802639:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  802640:	b8 01 00 00 00       	mov    $0x1,%eax
  802645:	31 d2                	xor    %edx,%edx
  802647:	f7 75 f0             	divl   0xfffffff0(%ebp)
  80264a:	89 c1                	mov    %eax,%ecx
  80264c:	eb c0                	jmp    80260e <__udivdi3+0xbe>
  80264e:	66 90                	xchg   %ax,%ax
  802650:	b9 01 00 00 00       	mov    $0x1,%ecx
  802655:	31 f6                	xor    %esi,%esi
  802657:	e9 24 ff ff ff       	jmp    802580 <__udivdi3+0x30>
  80265c:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  80265f:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802663:	d3 e0                	shl    %cl,%eax
  802665:	39 c6                	cmp    %eax,%esi
  802667:	76 95                	jbe    8025fe <__udivdi3+0xae>
  802669:	8d 4f ff             	lea    0xffffffff(%edi),%ecx
  80266c:	31 f6                	xor    %esi,%esi
  80266e:	e9 0d ff ff ff       	jmp    802580 <__udivdi3+0x30>
	...

00802680 <__umoddi3>:
  802680:	55                   	push   %ebp
  802681:	89 e5                	mov    %esp,%ebp
  802683:	57                   	push   %edi
  802684:	56                   	push   %esi
  802685:	83 ec 30             	sub    $0x30,%esp
  802688:	8b 55 14             	mov    0x14(%ebp),%edx
  80268b:	8b 45 10             	mov    0x10(%ebp),%eax
  80268e:	8b 75 08             	mov    0x8(%ebp),%esi
  802691:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802694:	85 d2                	test   %edx,%edx
  802696:	c7 45 d0 00 00 00 00 	movl   $0x0,0xffffffd0(%ebp)
  80269d:	89 c1                	mov    %eax,%ecx
  80269f:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  8026a6:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8026a9:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  8026ac:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  8026af:	89 7d e0             	mov    %edi,0xffffffe0(%ebp)
  8026b2:	75 1c                	jne    8026d0 <__umoddi3+0x50>
  8026b4:	39 f8                	cmp    %edi,%eax
  8026b6:	89 fa                	mov    %edi,%edx
  8026b8:	0f 86 d4 00 00 00    	jbe    802792 <__umoddi3+0x112>
  8026be:	89 f0                	mov    %esi,%eax
  8026c0:	f7 f1                	div    %ecx
  8026c2:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  8026c5:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  8026cc:	eb 12                	jmp    8026e0 <__umoddi3+0x60>
  8026ce:	66 90                	xchg   %ax,%ax
  8026d0:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  8026d3:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  8026d6:	76 18                	jbe    8026f0 <__umoddi3+0x70>
  8026d8:	89 75 d0             	mov    %esi,0xffffffd0(%ebp)
  8026db:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  8026de:	66 90                	xchg   %ax,%ax
  8026e0:	8b 45 d0             	mov    0xffffffd0(%ebp),%eax
  8026e3:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  8026e6:	83 c4 30             	add    $0x30,%esp
  8026e9:	5e                   	pop    %esi
  8026ea:	5f                   	pop    %edi
  8026eb:	5d                   	pop    %ebp
  8026ec:	c3                   	ret    
  8026ed:	8d 76 00             	lea    0x0(%esi),%esi
  8026f0:	0f bd 45 e8          	bsr    0xffffffe8(%ebp),%eax
  8026f4:	83 f0 1f             	xor    $0x1f,%eax
  8026f7:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  8026fa:	0f 84 c0 00 00 00    	je     8027c0 <__umoddi3+0x140>
  802700:	b8 20 00 00 00       	mov    $0x20,%eax
  802705:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  802708:	2b 45 dc             	sub    0xffffffdc(%ebp),%eax
  80270b:	8b 7d ec             	mov    0xffffffec(%ebp),%edi
  80270e:	8b 75 f0             	mov    0xfffffff0(%ebp),%esi
  802711:	89 c1                	mov    %eax,%ecx
  802713:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  802716:	d3 ea                	shr    %cl,%edx
  802718:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  80271b:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  80271f:	d3 e0                	shl    %cl,%eax
  802721:	09 c2                	or     %eax,%edx
  802723:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802726:	d3 e7                	shl    %cl,%edi
  802728:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  80272c:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  80272f:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  802732:	d3 e8                	shr    %cl,%eax
  802734:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  802738:	d3 e2                	shl    %cl,%edx
  80273a:	09 d0                	or     %edx,%eax
  80273c:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  80273f:	d3 e6                	shl    %cl,%esi
  802741:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802745:	d3 ea                	shr    %cl,%edx
  802747:	f7 75 f4             	divl   0xfffffff4(%ebp)
  80274a:	89 55 cc             	mov    %edx,0xffffffcc(%ebp)
  80274d:	f7 e7                	mul    %edi
  80274f:	39 55 cc             	cmp    %edx,0xffffffcc(%ebp)
  802752:	0f 82 a5 00 00 00    	jb     8027fd <__umoddi3+0x17d>
  802758:	3b 55 cc             	cmp    0xffffffcc(%ebp),%edx
  80275b:	0f 84 94 00 00 00    	je     8027f5 <__umoddi3+0x175>
  802761:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  802764:	29 c6                	sub    %eax,%esi
  802766:	19 d1                	sbb    %edx,%ecx
  802768:	89 4d cc             	mov    %ecx,0xffffffcc(%ebp)
  80276b:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  80276f:	89 f2                	mov    %esi,%edx
  802771:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  802774:	d3 ea                	shr    %cl,%edx
  802776:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  80277a:	d3 e0                	shl    %cl,%eax
  80277c:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  802780:	09 c2                	or     %eax,%edx
  802782:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  802785:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802788:	d3 e8                	shr    %cl,%eax
  80278a:	89 45 d4             	mov    %eax,0xffffffd4(%ebp)
  80278d:	e9 4e ff ff ff       	jmp    8026e0 <__umoddi3+0x60>
  802792:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  802795:	85 c0                	test   %eax,%eax
  802797:	74 17                	je     8027b0 <__umoddi3+0x130>
  802799:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  80279c:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
  80279f:	f7 f1                	div    %ecx
  8027a1:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8027a4:	f7 f1                	div    %ecx
  8027a6:	e9 17 ff ff ff       	jmp    8026c2 <__umoddi3+0x42>
  8027ab:	90                   	nop    
  8027ac:	8d 74 26 00          	lea    0x0(%esi),%esi
  8027b0:	b8 01 00 00 00       	mov    $0x1,%eax
  8027b5:	31 d2                	xor    %edx,%edx
  8027b7:	f7 75 ec             	divl   0xffffffec(%ebp)
  8027ba:	89 c1                	mov    %eax,%ecx
  8027bc:	eb db                	jmp    802799 <__umoddi3+0x119>
  8027be:	66 90                	xchg   %ax,%ax
  8027c0:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8027c3:	39 45 e0             	cmp    %eax,0xffffffe0(%ebp)
  8027c6:	77 19                	ja     8027e1 <__umoddi3+0x161>
  8027c8:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  8027cb:	39 55 f0             	cmp    %edx,0xfffffff0(%ebp)
  8027ce:	73 11                	jae    8027e1 <__umoddi3+0x161>
  8027d0:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  8027d3:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  8027d6:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  8027d9:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  8027dc:	e9 ff fe ff ff       	jmp    8026e0 <__umoddi3+0x60>
  8027e1:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  8027e4:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8027e7:	2b 45 ec             	sub    0xffffffec(%ebp),%eax
  8027ea:	1b 4d e8             	sbb    0xffffffe8(%ebp),%ecx
  8027ed:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  8027f0:	89 4d e0             	mov    %ecx,0xffffffe0(%ebp)
  8027f3:	eb db                	jmp    8027d0 <__umoddi3+0x150>
  8027f5:	39 f0                	cmp    %esi,%eax
  8027f7:	0f 86 64 ff ff ff    	jbe    802761 <__umoddi3+0xe1>
  8027fd:	29 f8                	sub    %edi,%eax
  8027ff:	1b 55 f4             	sbb    0xfffffff4(%ebp),%edx
  802802:	e9 5a ff ff ff       	jmp    802761 <__umoddi3+0xe1>
