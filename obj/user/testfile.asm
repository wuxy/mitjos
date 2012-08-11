
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
  80002c:	e8 ab 05 00 00       	call   8005dc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	53                   	push   %ebx
  800044:	83 ec 14             	sub    $0x14,%esp
  800047:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;

	strcpy(fsipcbuf.open.req_path, path);
  800049:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004d:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  800054:	e8 28 0d 00 00       	call   800d81 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800059:	89 1d 00 34 80 00    	mov    %ebx,0x803400
	
	//cprintf("\nxopen:envs[1].env_id=%x,&fsipcbuf=%x\n",envs[1].env_id,&fsipcbuf);
	ipc_send(envs[1].env_id, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80005f:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  800064:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80006b:	00 
  80006c:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  800073:	00 
  800074:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80007b:	00 
  80007c:	89 04 24             	mov    %eax,(%esp)
  80007f:	e8 2c 15 00 00       	call   8015b0 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800084:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80008b:	00 
  80008c:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  800093:	cc 
  800094:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80009b:	e8 c4 15 00 00       	call   801664 <ipc_recv>
}
  8000a0:	83 c4 14             	add    $0x14,%esp
  8000a3:	5b                   	pop    %ebx
  8000a4:	5d                   	pop    %ebp
  8000a5:	c3                   	ret    

008000a6 <umain>:

void
umain(void)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	56                   	push   %esi
  8000aa:	53                   	push   %ebx
  8000ab:	81 ec c0 02 00 00    	sub    $0x2c0,%esp
	struct Fd *fd;
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];
	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8000b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b6:	b8 00 23 80 00       	mov    $0x802300,%eax
  8000bb:	e8 80 ff ff ff       	call   800040 <xopen>
  8000c0:	85 c0                	test   %eax,%eax
  8000c2:	79 25                	jns    8000e9 <umain+0x43>
  8000c4:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000c7:	74 3c                	je     800105 <umain+0x5f>
		panic("serve_open /not-found: %e", r);
  8000c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000cd:	c7 44 24 08 0b 23 80 	movl   $0x80230b,0x8(%esp)
  8000d4:	00 
  8000d5:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8000dc:	00 
  8000dd:	c7 04 24 25 23 80 00 	movl   $0x802325,(%esp)
  8000e4:	e8 6b 05 00 00       	call   800654 <_panic>
	else if (r >= 0)
		panic("serve_open /not-found succeeded!");
  8000e9:	c7 44 24 08 84 24 80 	movl   $0x802484,0x8(%esp)
  8000f0:	00 
  8000f1:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8000f8:	00 
  8000f9:	c7 04 24 25 23 80 00 	movl   $0x802325,(%esp)
  800100:	e8 4f 05 00 00       	call   800654 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  800105:	ba 00 00 00 00       	mov    $0x0,%edx
  80010a:	b8 35 23 80 00       	mov    $0x802335,%eax
  80010f:	e8 2c ff ff ff       	call   800040 <xopen>
  800114:	85 c0                	test   %eax,%eax
  800116:	79 20                	jns    800138 <umain+0x92>
		panic("serve_open /newmotd: %e", r);
  800118:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80011c:	c7 44 24 08 3e 23 80 	movl   $0x80233e,0x8(%esp)
  800123:	00 
  800124:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012b:	00 
  80012c:	c7 04 24 25 23 80 00 	movl   $0x802325,(%esp)
  800133:	e8 1c 05 00 00       	call   800654 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  800138:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  80013f:	75 12                	jne    800153 <umain+0xad>
  800141:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800148:	75 09                	jne    800153 <umain+0xad>
  80014a:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  800151:	74 1c                	je     80016f <umain+0xc9>
		panic("serve_open did not fill struct Fd correctly\n");
  800153:	c7 44 24 08 a8 24 80 	movl   $0x8024a8,0x8(%esp)
  80015a:	00 
  80015b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800162:	00 
  800163:	c7 04 24 25 23 80 00 	movl   $0x802325,(%esp)
  80016a:	e8 e5 04 00 00       	call   800654 <_panic>
	cprintf("serve_open is good\n");
  80016f:	c7 04 24 56 23 80 00 	movl   $0x802356,(%esp)
  800176:	e8 a6 05 00 00       	call   800721 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  80017b:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  800181:	89 44 24 04          	mov    %eax,0x4(%esp)
  800185:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80018c:	ff 15 1c 50 80 00    	call   *0x80501c
  800192:	85 c0                	test   %eax,%eax
  800194:	79 20                	jns    8001b6 <umain+0x110>
		panic("file_stat: %e", r);
  800196:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80019a:	c7 44 24 08 6a 23 80 	movl   $0x80236a,0x8(%esp)
  8001a1:	00 
  8001a2:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  8001a9:	00 
  8001aa:	c7 04 24 25 23 80 00 	movl   $0x802325,(%esp)
  8001b1:	e8 9e 04 00 00       	call   800654 <_panic>
	if (strlen(msg) != st.st_size)
  8001b6:	a1 00 50 80 00       	mov    0x805000,%eax
  8001bb:	89 04 24             	mov    %eax,(%esp)
  8001be:	e8 6d 0b 00 00       	call   800d30 <strlen>
  8001c3:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  8001c6:	74 34                	je     8001fc <umain+0x156>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  8001c8:	a1 00 50 80 00       	mov    0x805000,%eax
  8001cd:	89 04 24             	mov    %eax,(%esp)
  8001d0:	e8 5b 0b 00 00       	call   800d30 <strlen>
  8001d5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e0:	c7 44 24 08 d8 24 80 	movl   $0x8024d8,0x8(%esp)
  8001e7:	00 
  8001e8:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8001ef:	00 
  8001f0:	c7 04 24 25 23 80 00 	movl   $0x802325,(%esp)
  8001f7:	e8 58 04 00 00       	call   800654 <_panic>
	cprintf("file_stat is good\n");
  8001fc:	c7 04 24 78 23 80 00 	movl   $0x802378,(%esp)
  800203:	e8 19 05 00 00       	call   800721 <cprintf>

	memset(buf, 0, sizeof buf);
  800208:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80020f:	00 
  800210:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800217:	00 
  800218:	8d 9d 5c fd ff ff    	lea    -0x2a4(%ebp),%ebx
  80021e:	89 1c 24             	mov    %ebx,(%esp)
  800221:	e8 08 0d 00 00       	call   800f2e <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800226:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80022d:	00 
  80022e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800232:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800239:	ff 15 10 50 80 00    	call   *0x805010
  80023f:	85 c0                	test   %eax,%eax
  800241:	79 20                	jns    800263 <umain+0x1bd>
		panic("file_read: %e", r);
  800243:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800247:	c7 44 24 08 8b 23 80 	movl   $0x80238b,0x8(%esp)
  80024e:	00 
  80024f:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  800256:	00 
  800257:	c7 04 24 25 23 80 00 	movl   $0x802325,(%esp)
  80025e:	e8 f1 03 00 00       	call   800654 <_panic>
	//cprintf("buf=%s\n",buf);
	if (strcmp(buf, msg) != 0)
  800263:	a1 00 50 80 00       	mov    0x805000,%eax
  800268:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026c:	8d 85 5c fd ff ff    	lea    -0x2a4(%ebp),%eax
  800272:	89 04 24             	mov    %eax,(%esp)
  800275:	e8 e7 0b 00 00       	call   800e61 <strcmp>
  80027a:	85 c0                	test   %eax,%eax
  80027c:	74 1c                	je     80029a <umain+0x1f4>
		panic("file_read returned wrong data");
  80027e:	c7 44 24 08 99 23 80 	movl   $0x802399,0x8(%esp)
  800285:	00 
  800286:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  80028d:	00 
  80028e:	c7 04 24 25 23 80 00 	movl   $0x802325,(%esp)
  800295:	e8 ba 03 00 00       	call   800654 <_panic>
	cprintf("file_read is good\n");
  80029a:	c7 04 24 b7 23 80 00 	movl   $0x8023b7,(%esp)
  8002a1:	e8 7b 04 00 00       	call   800721 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  8002a6:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8002ad:	ff 15 18 50 80 00    	call   *0x805018
  8002b3:	85 c0                	test   %eax,%eax
  8002b5:	79 20                	jns    8002d7 <umain+0x231>
		panic("file_close: %e", r);
  8002b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002bb:	c7 44 24 08 ca 23 80 	movl   $0x8023ca,0x8(%esp)
  8002c2:	00 
  8002c3:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  8002ca:	00 
  8002cb:	c7 04 24 25 23 80 00 	movl   $0x802325,(%esp)
  8002d2:	e8 7d 03 00 00       	call   800654 <_panic>
	cprintf("file_close is good\n");
  8002d7:	c7 04 24 d9 23 80 00 	movl   $0x8023d9,(%esp)
  8002de:	e8 3e 04 00 00       	call   800721 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  8002e3:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  8002e8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8002eb:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  8002f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8002f3:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  8002f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8002fb:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  800300:	89 45 f4             	mov    %eax,-0xc(%ebp)
	sys_page_unmap(0, FVA);
  800303:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  80030a:	cc 
  80030b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800312:	e8 b3 10 00 00       	call   8013ca <sys_page_unmap>
	//cprintf("fdid=%x fd_offset=%x\n erron=%d",fdcopy.fd_file.id,fdcopy.fd_offset,-E_INVAL);
	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  800317:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80031e:	00 
  80031f:	8d 85 5c fd ff ff    	lea    -0x2a4(%ebp),%eax
  800325:	89 44 24 04          	mov    %eax,0x4(%esp)
  800329:	8d 45 e8             	lea    -0x18(%ebp),%eax
  80032c:	89 04 24             	mov    %eax,(%esp)
  80032f:	ff 15 10 50 80 00    	call   *0x805010
  800335:	83 f8 fd             	cmp    $0xfffffffd,%eax
  800338:	74 20                	je     80035a <umain+0x2b4>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  80033a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80033e:	c7 44 24 08 00 25 80 	movl   $0x802500,0x8(%esp)
  800345:	00 
  800346:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
  80034d:	00 
  80034e:	c7 04 24 25 23 80 00 	movl   $0x802325,(%esp)
  800355:	e8 fa 02 00 00       	call   800654 <_panic>
	cprintf("stale fileid is good\n");
  80035a:	c7 04 24 ed 23 80 00 	movl   $0x8023ed,(%esp)
  800361:	e8 bb 03 00 00       	call   800721 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  800366:	ba 02 01 00 00       	mov    $0x102,%edx
  80036b:	b8 03 24 80 00       	mov    $0x802403,%eax
  800370:	e8 cb fc ff ff       	call   800040 <xopen>
  800375:	85 c0                	test   %eax,%eax
  800377:	79 20                	jns    800399 <umain+0x2f3>
		panic("serve_open /new-file: %e", r);
  800379:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80037d:	c7 44 24 08 0d 24 80 	movl   $0x80240d,0x8(%esp)
  800384:	00 
  800385:	c7 44 24 04 47 00 00 	movl   $0x47,0x4(%esp)
  80038c:	00 
  80038d:	c7 04 24 25 23 80 00 	movl   $0x802325,(%esp)
  800394:	e8 bb 02 00 00       	call   800654 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  800399:	8b 1d 14 50 80 00    	mov    0x805014,%ebx
  80039f:	a1 00 50 80 00       	mov    0x805000,%eax
  8003a4:	89 04 24             	mov    %eax,(%esp)
  8003a7:	e8 84 09 00 00       	call   800d30 <strlen>
  8003ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b0:	a1 00 50 80 00       	mov    0x805000,%eax
  8003b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b9:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8003c0:	ff d3                	call   *%ebx
  8003c2:	89 c3                	mov    %eax,%ebx
  8003c4:	a1 00 50 80 00       	mov    0x805000,%eax
  8003c9:	89 04 24             	mov    %eax,(%esp)
  8003cc:	e8 5f 09 00 00       	call   800d30 <strlen>
  8003d1:	39 c3                	cmp    %eax,%ebx
  8003d3:	74 20                	je     8003f5 <umain+0x34f>
		panic("file_write: %e", r);
  8003d5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003d9:	c7 44 24 08 26 24 80 	movl   $0x802426,0x8(%esp)
  8003e0:	00 
  8003e1:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8003e8:	00 
  8003e9:	c7 04 24 25 23 80 00 	movl   $0x802325,(%esp)
  8003f0:	e8 5f 02 00 00       	call   800654 <_panic>
	cprintf("file_write is good\n");
  8003f5:	c7 04 24 35 24 80 00 	movl   $0x802435,(%esp)
  8003fc:	e8 20 03 00 00       	call   800721 <cprintf>

	FVA->fd_offset = 0;
  800401:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800408:	00 00 00 
	memset(buf, 0, sizeof buf);
  80040b:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800412:	00 
  800413:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80041a:	00 
  80041b:	8d 9d 5c fd ff ff    	lea    -0x2a4(%ebp),%ebx
  800421:	89 1c 24             	mov    %ebx,(%esp)
  800424:	e8 05 0b 00 00       	call   800f2e <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800429:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800430:	00 
  800431:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800435:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80043c:	ff 15 10 50 80 00    	call   *0x805010
  800442:	89 c3                	mov    %eax,%ebx
  800444:	85 c0                	test   %eax,%eax
  800446:	79 20                	jns    800468 <umain+0x3c2>
		panic("file_read after file_write: %e", r);
  800448:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80044c:	c7 44 24 08 38 25 80 	movl   $0x802538,0x8(%esp)
  800453:	00 
  800454:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  80045b:	00 
  80045c:	c7 04 24 25 23 80 00 	movl   $0x802325,(%esp)
  800463:	e8 ec 01 00 00       	call   800654 <_panic>
	if (r != strlen(msg))
  800468:	a1 00 50 80 00       	mov    0x805000,%eax
  80046d:	89 04 24             	mov    %eax,(%esp)
  800470:	e8 bb 08 00 00       	call   800d30 <strlen>
  800475:	39 c3                	cmp    %eax,%ebx
  800477:	74 20                	je     800499 <umain+0x3f3>
		panic("file_read after file_write returned wrong length: %d", r);
  800479:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80047d:	c7 44 24 08 58 25 80 	movl   $0x802558,0x8(%esp)
  800484:	00 
  800485:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  80048c:	00 
  80048d:	c7 04 24 25 23 80 00 	movl   $0x802325,(%esp)
  800494:	e8 bb 01 00 00       	call   800654 <_panic>
	if (strcmp(buf, msg) != 0)
  800499:	a1 00 50 80 00       	mov    0x805000,%eax
  80049e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a2:	8d 85 5c fd ff ff    	lea    -0x2a4(%ebp),%eax
  8004a8:	89 04 24             	mov    %eax,(%esp)
  8004ab:	e8 b1 09 00 00       	call   800e61 <strcmp>
  8004b0:	85 c0                	test   %eax,%eax
  8004b2:	74 1c                	je     8004d0 <umain+0x42a>
		panic("file_read after file_write returned wrong data");
  8004b4:	c7 44 24 08 90 25 80 	movl   $0x802590,0x8(%esp)
  8004bb:	00 
  8004bc:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  8004c3:	00 
  8004c4:	c7 04 24 25 23 80 00 	movl   $0x802325,(%esp)
  8004cb:	e8 84 01 00 00       	call   800654 <_panic>
	cprintf("file_read after file_write is good\n");
  8004d0:	c7 04 24 c0 25 80 00 	movl   $0x8025c0,(%esp)
  8004d7:	e8 45 02 00 00       	call   800721 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8004dc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004e3:	00 
  8004e4:	c7 04 24 00 23 80 00 	movl   $0x802300,(%esp)
  8004eb:	e8 6f 1a 00 00       	call   801f5f <open>
  8004f0:	85 c0                	test   %eax,%eax
  8004f2:	79 25                	jns    800519 <umain+0x473>
  8004f4:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8004f7:	74 3c                	je     800535 <umain+0x48f>
		panic("open /not-found: %e", r);
  8004f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004fd:	c7 44 24 08 11 23 80 	movl   $0x802311,0x8(%esp)
  800504:	00 
  800505:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  80050c:	00 
  80050d:	c7 04 24 25 23 80 00 	movl   $0x802325,(%esp)
  800514:	e8 3b 01 00 00       	call   800654 <_panic>
	else if (r >= 0)
		panic("open /not-found succeeded!");
  800519:	c7 44 24 08 49 24 80 	movl   $0x802449,0x8(%esp)
  800520:	00 
  800521:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  800528:	00 
  800529:	c7 04 24 25 23 80 00 	movl   $0x802325,(%esp)
  800530:	e8 1f 01 00 00       	call   800654 <_panic>
	cprintf("***open ***\n");
  800535:	c7 04 24 64 24 80 00 	movl   $0x802464,(%esp)
  80053c:	e8 e0 01 00 00       	call   800721 <cprintf>
	if ((r = open("/newmotd", O_RDONLY)) < 0)
  800541:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800548:	00 
  800549:	c7 04 24 35 23 80 00 	movl   $0x802335,(%esp)
  800550:	e8 0a 1a 00 00       	call   801f5f <open>
  800555:	85 c0                	test   %eax,%eax
  800557:	79 20                	jns    800579 <umain+0x4d3>
		panic("open /newmotd: %e", r);
  800559:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80055d:	c7 44 24 08 44 23 80 	movl   $0x802344,0x8(%esp)
  800564:	00 
  800565:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
  80056c:	00 
  80056d:	c7 04 24 25 23 80 00 	movl   $0x802325,(%esp)
  800574:	e8 db 00 00 00       	call   800654 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800579:	89 c3                	mov    %eax,%ebx
  80057b:	c1 e3 0c             	shl    $0xc,%ebx
  80057e:	8d b3 00 00 00 d0    	lea    -0x30000000(%ebx),%esi
	cprintf("testfile:fd=%x\n",fd);
  800584:	89 74 24 04          	mov    %esi,0x4(%esp)
  800588:	c7 04 24 71 24 80 00 	movl   $0x802471,(%esp)
  80058f:	e8 8d 01 00 00       	call   800721 <cprintf>
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800594:	83 bb 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%ebx)
  80059b:	75 0c                	jne    8005a9 <umain+0x503>
  80059d:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
  8005a1:	75 06                	jne    8005a9 <umain+0x503>
  8005a3:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
  8005a7:	74 1c                	je     8005c5 <umain+0x51f>
		panic("open did not fill struct Fd correctly\n");
  8005a9:	c7 44 24 08 e4 25 80 	movl   $0x8025e4,0x8(%esp)
  8005b0:	00 
  8005b1:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  8005b8:	00 
  8005b9:	c7 04 24 25 23 80 00 	movl   $0x802325,(%esp)
  8005c0:	e8 8f 00 00 00       	call   800654 <_panic>
	cprintf("open is good\n");
  8005c5:	c7 04 24 5c 23 80 00 	movl   $0x80235c,(%esp)
  8005cc:	e8 50 01 00 00       	call   800721 <cprintf>
}
  8005d1:	81 c4 c0 02 00 00    	add    $0x2c0,%esp
  8005d7:	5b                   	pop    %ebx
  8005d8:	5e                   	pop    %esi
  8005d9:	5d                   	pop    %ebp
  8005da:	c3                   	ret    
	...

008005dc <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8005dc:	55                   	push   %ebp
  8005dd:	89 e5                	mov    %esp,%ebp
  8005df:	83 ec 18             	sub    $0x18,%esp
  8005e2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8005e5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8005e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8005eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  8005ee:	c7 05 24 50 80 00 00 	movl   $0x0,0x805024
  8005f5:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  8005f8:	e8 1c 0f 00 00       	call   801519 <sys_getenvid>
  8005fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800602:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800605:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80060a:	a3 24 50 80 00       	mov    %eax,0x805024
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80060f:	85 f6                	test   %esi,%esi
  800611:	7e 07                	jle    80061a <libmain+0x3e>
		binaryname = argv[0];
  800613:	8b 03                	mov    (%ebx),%eax
  800615:	a3 04 50 80 00       	mov    %eax,0x805004

	// call user main routine
	umain(argc, argv);
  80061a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061e:	89 34 24             	mov    %esi,(%esp)
  800621:	e8 80 fa ff ff       	call   8000a6 <umain>

	// exit gracefully
	exit();
  800626:	e8 0d 00 00 00       	call   800638 <exit>
}
  80062b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80062e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800631:	89 ec                	mov    %ebp,%esp
  800633:	5d                   	pop    %ebp
  800634:	c3                   	ret    
  800635:	00 00                	add    %al,(%eax)
	...

00800638 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800638:	55                   	push   %ebp
  800639:	89 e5                	mov    %esp,%ebp
  80063b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80063e:	e8 fd 16 00 00       	call   801d40 <close_all>
	sys_env_destroy(0);
  800643:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80064a:	e8 fe 0e 00 00       	call   80154d <sys_env_destroy>
}
  80064f:	c9                   	leave  
  800650:	c3                   	ret    
  800651:	00 00                	add    %al,(%eax)
	...

00800654 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800654:	55                   	push   %ebp
  800655:	89 e5                	mov    %esp,%ebp
  800657:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  80065a:	8d 45 14             	lea    0x14(%ebp),%eax
  80065d:	89 45 fc             	mov    %eax,-0x4(%ebp)

	// Print the panic message
	if (argv0)
  800660:	a1 28 50 80 00       	mov    0x805028,%eax
  800665:	85 c0                	test   %eax,%eax
  800667:	74 10                	je     800679 <_panic+0x25>
		cprintf("%s: ", argv0);
  800669:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066d:	c7 04 24 49 26 80 00 	movl   $0x802649,(%esp)
  800674:	e8 a8 00 00 00       	call   800721 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800679:	8b 45 0c             	mov    0xc(%ebp),%eax
  80067c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800680:	8b 45 08             	mov    0x8(%ebp),%eax
  800683:	89 44 24 08          	mov    %eax,0x8(%esp)
  800687:	a1 04 50 80 00       	mov    0x805004,%eax
  80068c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800690:	c7 04 24 4e 26 80 00 	movl   $0x80264e,(%esp)
  800697:	e8 85 00 00 00       	call   800721 <cprintf>
	vcprintf(fmt, ap);
  80069c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80069f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8006a6:	89 04 24             	mov    %eax,(%esp)
  8006a9:	e8 12 00 00 00       	call   8006c0 <vcprintf>
	cprintf("\n");
  8006ae:	c7 04 24 6f 24 80 00 	movl   $0x80246f,(%esp)
  8006b5:	e8 67 00 00 00       	call   800721 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006ba:	cc                   	int3   
  8006bb:	eb fd                	jmp    8006ba <_panic+0x66>
  8006bd:	00 00                	add    %al,(%eax)
	...

008006c0 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8006c0:	55                   	push   %ebp
  8006c1:	89 e5                	mov    %esp,%ebp
  8006c3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8006c9:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  8006d0:	00 00 00 
	b.cnt = 0;
  8006d3:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  8006da:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006eb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f5:	c7 04 24 3e 07 80 00 	movl   $0x80073e,(%esp)
  8006fc:	e8 c4 01 00 00       	call   8008c5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800701:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
  800707:	89 44 24 04          	mov    %eax,0x4(%esp)
  80070b:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  800711:	89 04 24             	mov    %eax,(%esp)
  800714:	e8 cf 0a 00 00       	call   8011e8 <sys_cputs>
  800719:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  80071f:	c9                   	leave  
  800720:	c3                   	ret    

00800721 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800721:	55                   	push   %ebp
  800722:	89 e5                	mov    %esp,%ebp
  800724:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800727:	8d 45 0c             	lea    0xc(%ebp),%eax
  80072a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  80072d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800731:	8b 45 08             	mov    0x8(%ebp),%eax
  800734:	89 04 24             	mov    %eax,(%esp)
  800737:	e8 84 ff ff ff       	call   8006c0 <vcprintf>
	va_end(ap);

	return cnt;
}
  80073c:	c9                   	leave  
  80073d:	c3                   	ret    

0080073e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	53                   	push   %ebx
  800742:	83 ec 14             	sub    $0x14,%esp
  800745:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800748:	8b 03                	mov    (%ebx),%eax
  80074a:	8b 55 08             	mov    0x8(%ebp),%edx
  80074d:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800751:	83 c0 01             	add    $0x1,%eax
  800754:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800756:	3d ff 00 00 00       	cmp    $0xff,%eax
  80075b:	75 19                	jne    800776 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80075d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800764:	00 
  800765:	8d 43 08             	lea    0x8(%ebx),%eax
  800768:	89 04 24             	mov    %eax,(%esp)
  80076b:	e8 78 0a 00 00       	call   8011e8 <sys_cputs>
		b->idx = 0;
  800770:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800776:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80077a:	83 c4 14             	add    $0x14,%esp
  80077d:	5b                   	pop    %ebx
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	57                   	push   %edi
  800784:	56                   	push   %esi
  800785:	53                   	push   %ebx
  800786:	83 ec 3c             	sub    $0x3c,%esp
  800789:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80078c:	89 d7                	mov    %edx,%edi
  80078e:	8b 45 08             	mov    0x8(%ebp),%eax
  800791:	8b 55 0c             	mov    0xc(%ebp),%edx
  800794:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800797:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80079a:	8b 55 10             	mov    0x10(%ebp),%edx
  80079d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8007a0:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8007a3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  8007aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007ad:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  8007b0:	72 14                	jb     8007c6 <printnum+0x46>
  8007b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007b5:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  8007b8:	76 0c                	jbe    8007c6 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8007bd:	83 eb 01             	sub    $0x1,%ebx
  8007c0:	85 db                	test   %ebx,%ebx
  8007c2:	7f 57                	jg     80081b <printnum+0x9b>
  8007c4:	eb 64                	jmp    80082a <printnum+0xaa>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8007c6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8007ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cd:	83 e8 01             	sub    $0x1,%eax
  8007d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d4:	89 54 24 08          	mov    %edx,0x8(%esp)
  8007d8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8007dc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8007e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8007e3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8007e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ea:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007f4:	89 04 24             	mov    %eax,(%esp)
  8007f7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007fb:	e8 50 18 00 00       	call   802050 <__udivdi3>
  800800:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800804:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800808:	89 04 24             	mov    %eax,(%esp)
  80080b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80080f:	89 fa                	mov    %edi,%edx
  800811:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800814:	e8 67 ff ff ff       	call   800780 <printnum>
  800819:	eb 0f                	jmp    80082a <printnum+0xaa>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80081b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80081f:	89 34 24             	mov    %esi,(%esp)
  800822:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800825:	83 eb 01             	sub    $0x1,%ebx
  800828:	75 f1                	jne    80081b <printnum+0x9b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80082a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80082e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800832:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800835:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800838:	89 44 24 08          	mov    %eax,0x8(%esp)
  80083c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800840:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800843:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800846:	89 04 24             	mov    %eax,(%esp)
  800849:	89 54 24 04          	mov    %edx,0x4(%esp)
  80084d:	e8 2e 19 00 00       	call   802180 <__umoddi3>
  800852:	89 74 24 04          	mov    %esi,0x4(%esp)
  800856:	0f be 80 6a 26 80 00 	movsbl 0x80266a(%eax),%eax
  80085d:	89 04 24             	mov    %eax,(%esp)
  800860:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800863:	83 c4 3c             	add    $0x3c,%esp
  800866:	5b                   	pop    %ebx
  800867:	5e                   	pop    %esi
  800868:	5f                   	pop    %edi
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800870:	83 fa 01             	cmp    $0x1,%edx
  800873:	7e 0e                	jle    800883 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800875:	8b 10                	mov    (%eax),%edx
  800877:	8d 42 08             	lea    0x8(%edx),%eax
  80087a:	89 01                	mov    %eax,(%ecx)
  80087c:	8b 02                	mov    (%edx),%eax
  80087e:	8b 52 04             	mov    0x4(%edx),%edx
  800881:	eb 22                	jmp    8008a5 <getuint+0x3a>
	else if (lflag)
  800883:	85 d2                	test   %edx,%edx
  800885:	74 10                	je     800897 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800887:	8b 10                	mov    (%eax),%edx
  800889:	8d 42 04             	lea    0x4(%edx),%eax
  80088c:	89 01                	mov    %eax,(%ecx)
  80088e:	8b 02                	mov    (%edx),%eax
  800890:	ba 00 00 00 00       	mov    $0x0,%edx
  800895:	eb 0e                	jmp    8008a5 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800897:	8b 10                	mov    (%eax),%edx
  800899:	8d 42 04             	lea    0x4(%edx),%eax
  80089c:	89 01                	mov    %eax,(%ecx)
  80089e:	8b 02                	mov    (%edx),%eax
  8008a0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  8008ad:	83 42 08 01          	addl   $0x1,0x8(%edx)
	if (b->buf < b->ebuf)
  8008b1:	8b 02                	mov    (%edx),%eax
  8008b3:	3b 42 04             	cmp    0x4(%edx),%eax
  8008b6:	73 0b                	jae    8008c3 <sprintputch+0x1c>
		*b->buf++ = ch;
  8008b8:	0f b6 4d 08          	movzbl 0x8(%ebp),%ecx
  8008bc:	88 08                	mov    %cl,(%eax)
  8008be:	83 c0 01             	add    $0x1,%eax
  8008c1:	89 02                	mov    %eax,(%edx)
}
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	57                   	push   %edi
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
  8008cb:	83 ec 3c             	sub    $0x3c,%esp
  8008ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8008d1:	eb 18                	jmp    8008eb <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008d3:	84 c0                	test   %al,%al
  8008d5:	0f 84 9f 03 00 00    	je     800c7a <vprintfmt+0x3b5>
				return;
			putch(ch, putdat);
  8008db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008e2:	0f b6 c0             	movzbl %al,%eax
  8008e5:	89 04 24             	mov    %eax,(%esp)
  8008e8:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008eb:	0f b6 03             	movzbl (%ebx),%eax
  8008ee:	83 c3 01             	add    $0x1,%ebx
  8008f1:	3c 25                	cmp    $0x25,%al
  8008f3:	75 de                	jne    8008d3 <vprintfmt+0xe>
  8008f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008fa:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
  800901:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800906:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80090d:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
  800911:	eb 07                	jmp    80091a <vprintfmt+0x55>
  800913:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091a:	0f b6 13             	movzbl (%ebx),%edx
  80091d:	83 c3 01             	add    $0x1,%ebx
  800920:	8d 42 dd             	lea    -0x23(%edx),%eax
  800923:	3c 55                	cmp    $0x55,%al
  800925:	0f 87 22 03 00 00    	ja     800c4d <vprintfmt+0x388>
  80092b:	0f b6 c0             	movzbl %al,%eax
  80092e:	ff 24 85 a0 27 80 00 	jmp    *0x8027a0(,%eax,4)
  800935:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
  800939:	eb df                	jmp    80091a <vprintfmt+0x55>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80093b:	0f b6 c2             	movzbl %dl,%eax
  80093e:	8d 78 d0             	lea    -0x30(%eax),%edi
				ch = *fmt;
  800941:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800944:	8d 42 d0             	lea    -0x30(%edx),%eax
  800947:	83 f8 09             	cmp    $0x9,%eax
  80094a:	76 08                	jbe    800954 <vprintfmt+0x8f>
  80094c:	eb 39                	jmp    800987 <vprintfmt+0xc2>
  80094e:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
  800952:	eb c6                	jmp    80091a <vprintfmt+0x55>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800954:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800957:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  80095a:	8d 7c 42 d0          	lea    -0x30(%edx,%eax,2),%edi
				ch = *fmt;
  80095e:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800961:	8d 42 d0             	lea    -0x30(%edx),%eax
  800964:	83 f8 09             	cmp    $0x9,%eax
  800967:	77 1e                	ja     800987 <vprintfmt+0xc2>
  800969:	eb e9                	jmp    800954 <vprintfmt+0x8f>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80096b:	8b 55 14             	mov    0x14(%ebp),%edx
  80096e:	8d 42 04             	lea    0x4(%edx),%eax
  800971:	89 45 14             	mov    %eax,0x14(%ebp)
  800974:	8b 3a                	mov    (%edx),%edi
  800976:	eb 0f                	jmp    800987 <vprintfmt+0xc2>
			goto process_precision;

		case '.':
			if (width < 0)
  800978:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80097c:	79 9c                	jns    80091a <vprintfmt+0x55>
  80097e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800985:	eb 93                	jmp    80091a <vprintfmt+0x55>
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800987:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80098b:	90                   	nop    
  80098c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800990:	79 88                	jns    80091a <vprintfmt+0x55>
  800992:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800995:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80099a:	e9 7b ff ff ff       	jmp    80091a <vprintfmt+0x55>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80099f:	83 c1 01             	add    $0x1,%ecx
  8009a2:	e9 73 ff ff ff       	jmp    80091a <vprintfmt+0x55>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8009a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009aa:	8d 50 04             	lea    0x4(%eax),%edx
  8009ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009b7:	8b 00                	mov    (%eax),%eax
  8009b9:	89 04 24             	mov    %eax,(%esp)
  8009bc:	ff 55 08             	call   *0x8(%ebp)
  8009bf:	e9 27 ff ff ff       	jmp    8008eb <vprintfmt+0x26>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009c4:	8b 55 14             	mov    0x14(%ebp),%edx
  8009c7:	8d 42 04             	lea    0x4(%edx),%eax
  8009ca:	89 45 14             	mov    %eax,0x14(%ebp)
  8009cd:	8b 02                	mov    (%edx),%eax
  8009cf:	89 c2                	mov    %eax,%edx
  8009d1:	c1 fa 1f             	sar    $0x1f,%edx
  8009d4:	31 d0                	xor    %edx,%eax
  8009d6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8009d8:	83 f8 0f             	cmp    $0xf,%eax
  8009db:	7f 0b                	jg     8009e8 <vprintfmt+0x123>
  8009dd:	8b 14 85 00 29 80 00 	mov    0x802900(,%eax,4),%edx
  8009e4:	85 d2                	test   %edx,%edx
  8009e6:	75 23                	jne    800a0b <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8009e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ec:	c7 44 24 08 7b 26 80 	movl   $0x80267b,0x8(%esp)
  8009f3:	00 
  8009f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8009fe:	89 14 24             	mov    %edx,(%esp)
  800a01:	e8 ff 02 00 00       	call   800d05 <printfmt>
  800a06:	e9 e0 fe ff ff       	jmp    8008eb <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800a0b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a0f:	c7 44 24 08 84 26 80 	movl   $0x802684,0x8(%esp)
  800a16:	00 
  800a17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a21:	89 14 24             	mov    %edx,(%esp)
  800a24:	e8 dc 02 00 00       	call   800d05 <printfmt>
  800a29:	e9 bd fe ff ff       	jmp    8008eb <vprintfmt+0x26>
  800a2e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800a31:	89 f9                	mov    %edi,%ecx
  800a33:	89 5d ec             	mov    %ebx,-0x14(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a36:	8b 55 14             	mov    0x14(%ebp),%edx
  800a39:	8d 42 04             	lea    0x4(%edx),%eax
  800a3c:	89 45 14             	mov    %eax,0x14(%ebp)
  800a3f:	8b 12                	mov    (%edx),%edx
  800a41:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a44:	85 d2                	test   %edx,%edx
  800a46:	75 07                	jne    800a4f <vprintfmt+0x18a>
  800a48:	c7 45 dc 87 26 80 00 	movl   $0x802687,-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800a4f:	85 f6                	test   %esi,%esi
  800a51:	7e 41                	jle    800a94 <vprintfmt+0x1cf>
  800a53:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  800a57:	74 3b                	je     800a94 <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a59:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a5d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a60:	89 04 24             	mov    %eax,(%esp)
  800a63:	e8 e8 02 00 00       	call   800d50 <strnlen>
  800a68:	29 c6                	sub    %eax,%esi
  800a6a:	89 75 f0             	mov    %esi,-0x10(%ebp)
  800a6d:	85 f6                	test   %esi,%esi
  800a6f:	7e 23                	jle    800a94 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800a71:	0f be 55 eb          	movsbl -0x15(%ebp),%edx
  800a75:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800a78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a7f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800a82:	89 14 24             	mov    %edx,(%esp)
  800a85:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a88:	83 ee 01             	sub    $0x1,%esi
  800a8b:	75 eb                	jne    800a78 <vprintfmt+0x1b3>
  800a8d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a94:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800a97:	0f b6 02             	movzbl (%edx),%eax
  800a9a:	0f be d0             	movsbl %al,%edx
  800a9d:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800aa0:	84 c0                	test   %al,%al
  800aa2:	75 42                	jne    800ae6 <vprintfmt+0x221>
  800aa4:	eb 49                	jmp    800aef <vprintfmt+0x22a>
				if (altflag && (ch < ' ' || ch > '~'))
  800aa6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800aaa:	74 1b                	je     800ac7 <vprintfmt+0x202>
  800aac:	8d 42 e0             	lea    -0x20(%edx),%eax
  800aaf:	83 f8 5e             	cmp    $0x5e,%eax
  800ab2:	76 13                	jbe    800ac7 <vprintfmt+0x202>
					putch('?', putdat);
  800ab4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800abb:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800ac2:	ff 55 08             	call   *0x8(%ebp)
  800ac5:	eb 0d                	jmp    800ad4 <vprintfmt+0x20f>
				else
					putch(ch, putdat);
  800ac7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aca:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ace:	89 14 24             	mov    %edx,(%esp)
  800ad1:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ad4:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  800ad8:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800adc:	83 c6 01             	add    $0x1,%esi
  800adf:	84 c0                	test   %al,%al
  800ae1:	74 0c                	je     800aef <vprintfmt+0x22a>
  800ae3:	0f be d0             	movsbl %al,%edx
  800ae6:	85 ff                	test   %edi,%edi
  800ae8:	78 bc                	js     800aa6 <vprintfmt+0x1e1>
  800aea:	83 ef 01             	sub    $0x1,%edi
  800aed:	79 b7                	jns    800aa6 <vprintfmt+0x1e1>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800aef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800af3:	0f 8e f2 fd ff ff    	jle    8008eb <vprintfmt+0x26>
				putch(' ', putdat);
  800af9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800afc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b00:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800b07:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b0a:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  800b0e:	75 e9                	jne    800af9 <vprintfmt+0x234>
  800b10:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800b13:	e9 d3 fd ff ff       	jmp    8008eb <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b18:	83 f9 01             	cmp    $0x1,%ecx
  800b1b:	90                   	nop    
  800b1c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800b20:	7e 10                	jle    800b32 <vprintfmt+0x26d>
		return va_arg(*ap, long long);
  800b22:	8b 55 14             	mov    0x14(%ebp),%edx
  800b25:	8d 42 08             	lea    0x8(%edx),%eax
  800b28:	89 45 14             	mov    %eax,0x14(%ebp)
  800b2b:	8b 32                	mov    (%edx),%esi
  800b2d:	8b 7a 04             	mov    0x4(%edx),%edi
  800b30:	eb 2a                	jmp    800b5c <vprintfmt+0x297>
	else if (lflag)
  800b32:	85 c9                	test   %ecx,%ecx
  800b34:	74 14                	je     800b4a <vprintfmt+0x285>
		return va_arg(*ap, long);
  800b36:	8b 45 14             	mov    0x14(%ebp),%eax
  800b39:	8d 50 04             	lea    0x4(%eax),%edx
  800b3c:	89 55 14             	mov    %edx,0x14(%ebp)
  800b3f:	8b 00                	mov    (%eax),%eax
  800b41:	89 c6                	mov    %eax,%esi
  800b43:	89 c7                	mov    %eax,%edi
  800b45:	c1 ff 1f             	sar    $0x1f,%edi
  800b48:	eb 12                	jmp    800b5c <vprintfmt+0x297>
	else
		return va_arg(*ap, int);
  800b4a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b4d:	8d 50 04             	lea    0x4(%eax),%edx
  800b50:	89 55 14             	mov    %edx,0x14(%ebp)
  800b53:	8b 00                	mov    (%eax),%eax
  800b55:	89 c6                	mov    %eax,%esi
  800b57:	89 c7                	mov    %eax,%edi
  800b59:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b5c:	89 f2                	mov    %esi,%edx
  800b5e:	89 f9                	mov    %edi,%ecx
  800b60:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
			if ((long long) num < 0) {
  800b67:	85 ff                	test   %edi,%edi
  800b69:	0f 89 9b 00 00 00    	jns    800c0a <vprintfmt+0x345>
				putch('-', putdat);
  800b6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b72:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b76:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b7d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800b80:	89 f2                	mov    %esi,%edx
  800b82:	89 f9                	mov    %edi,%ecx
  800b84:	f7 da                	neg    %edx
  800b86:	83 d1 00             	adc    $0x0,%ecx
  800b89:	f7 d9                	neg    %ecx
  800b8b:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  800b92:	eb 76                	jmp    800c0a <vprintfmt+0x345>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b94:	89 ca                	mov    %ecx,%edx
  800b96:	8d 45 14             	lea    0x14(%ebp),%eax
  800b99:	e8 cd fc ff ff       	call   80086b <getuint>
  800b9e:	89 d1                	mov    %edx,%ecx
  800ba0:	89 c2                	mov    %eax,%edx
  800ba2:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  800ba9:	eb 5f                	jmp    800c0a <vprintfmt+0x345>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap,lflag);
  800bab:	89 ca                	mov    %ecx,%edx
  800bad:	8d 45 14             	lea    0x14(%ebp),%eax
  800bb0:	e8 b6 fc ff ff       	call   80086b <getuint>
  800bb5:	e9 31 fd ff ff       	jmp    8008eb <vprintfmt+0x26>
			base=8;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800bba:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bbd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bc1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800bc8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bce:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800bd9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800bdc:	8b 55 14             	mov    0x14(%ebp),%edx
  800bdf:	8d 42 04             	lea    0x4(%edx),%eax
  800be2:	89 45 14             	mov    %eax,0x14(%ebp)
  800be5:	8b 12                	mov    (%edx),%edx
  800be7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bec:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  800bf3:	eb 15                	jmp    800c0a <vprintfmt+0x345>
			base = 16;
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bf5:	89 ca                	mov    %ecx,%edx
  800bf7:	8d 45 14             	lea    0x14(%ebp),%eax
  800bfa:	e8 6c fc ff ff       	call   80086b <getuint>
  800bff:	89 d1                	mov    %edx,%ecx
  800c01:	89 c2                	mov    %eax,%edx
  800c03:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c0a:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800c0e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c15:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c19:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c1c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c20:	89 14 24             	mov    %edx,(%esp)
  800c23:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c27:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2d:	e8 4e fb ff ff       	call   800780 <printnum>
  800c32:	e9 b4 fc ff ff       	jmp    8008eb <vprintfmt+0x26>
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c37:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c3a:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c3e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800c45:	ff 55 08             	call   *0x8(%ebp)
  800c48:	e9 9e fc ff ff       	jmp    8008eb <vprintfmt+0x26>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c50:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c54:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800c5b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c5e:	83 eb 01             	sub    $0x1,%ebx
  800c61:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800c65:	0f 84 80 fc ff ff    	je     8008eb <vprintfmt+0x26>
  800c6b:	83 eb 01             	sub    $0x1,%ebx
  800c6e:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800c72:	0f 84 73 fc ff ff    	je     8008eb <vprintfmt+0x26>
  800c78:	eb f1                	jmp    800c6b <vprintfmt+0x3a6>
				/* do nothing */;
			break;
		}
	}
}
  800c7a:	83 c4 3c             	add    $0x3c,%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	83 ec 28             	sub    $0x28,%esp
  800c88:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800c8e:	85 d2                	test   %edx,%edx
  800c90:	74 04                	je     800c96 <vsnprintf+0x14>
  800c92:	85 c0                	test   %eax,%eax
  800c94:	7f 07                	jg     800c9d <vsnprintf+0x1b>
  800c96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c9b:	eb 3b                	jmp    800cd8 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c9d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800ca4:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
  800ca8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800cab:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cae:	8b 45 14             	mov    0x14(%ebp),%eax
  800cb1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cb5:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cc3:	c7 04 24 a7 08 80 00 	movl   $0x8008a7,(%esp)
  800cca:	e8 f6 fb ff ff       	call   8008c5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cd2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cd5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800cd8:	c9                   	leave  
  800cd9:	c3                   	ret    

00800cda <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ce0:	8d 45 14             	lea    0x14(%ebp),%eax
  800ce3:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800ce6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cea:	8b 45 10             	mov    0x10(%ebp),%eax
  800ced:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfb:	89 04 24             	mov    %eax,(%esp)
  800cfe:	e8 7f ff ff ff       	call   800c82 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d03:	c9                   	leave  
  800d04:	c3                   	ret    

00800d05 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800d0b:	8d 45 14             	lea    0x14(%ebp),%eax
  800d0e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800d11:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d15:	8b 45 10             	mov    0x10(%ebp),%eax
  800d18:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d23:	8b 45 08             	mov    0x8(%ebp),%eax
  800d26:	89 04 24             	mov    %eax,(%esp)
  800d29:	e8 97 fb ff ff       	call   8008c5 <vprintfmt>
	va_end(ap);
}
  800d2e:	c9                   	leave  
  800d2f:	c3                   	ret    

00800d30 <strlen>:
// Primespipe runs 3x faster this way.
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
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d48:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  800d4c:	75 f7                	jne    800d45 <strlen+0x15>
		n++;
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
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d6a:	39 d0                	cmp    %edx,%eax
  800d6c:	74 0d                	je     800d7b <strnlen+0x2b>
  800d6e:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800d72:	74 07                	je     800d7b <strnlen+0x2b>
  800d74:	eb f1                	jmp    800d67 <strnlen+0x17>
  800d76:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
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
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dc9:	83 c3 01             	add    $0x1,%ebx
  800dcc:	39 f3                	cmp    %esi,%ebx
  800dce:	75 eb                	jne    800dbb <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
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
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e00:	83 eb 01             	sub    $0x1,%ebx
  800e03:	74 0f                	je     800e14 <strlcpy+0x3d>
  800e05:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  800e09:	83 c1 01             	add    $0x1,%ecx
  800e0c:	84 d2                	test   %dl,%dl
  800e0e:	74 04                	je     800e14 <strlcpy+0x3d>
  800e10:	eb e9                	jmp    800dfb <strlcpy+0x24>
  800e12:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
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
  800e20:	56                   	push   %esi
  800e21:	53                   	push   %ebx
  800e22:	8b 75 08             	mov    0x8(%ebp),%esi
  800e25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e28:	8b 55 10             	mov    0x10(%ebp),%edx
    int c;
    char *q = buf;

    if (buf_size <= 0)
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	7e 2e                	jle    800e5d <pstrcpy+0x40>
        return;

    for(;;) {
        c = *str++;
  800e2f:	0f b6 0a             	movzbl (%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  800e32:	84 c9                	test   %cl,%cl
  800e34:	74 22                	je     800e58 <pstrcpy+0x3b>
  800e36:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  800e3a:	89 f0                	mov    %esi,%eax
  800e3c:	39 de                	cmp    %ebx,%esi
  800e3e:	72 09                	jb     800e49 <pstrcpy+0x2c>
  800e40:	eb 16                	jmp    800e58 <pstrcpy+0x3b>
  800e42:	83 c2 01             	add    $0x1,%edx
  800e45:	39 d8                	cmp    %ebx,%eax
  800e47:	73 11                	jae    800e5a <pstrcpy+0x3d>
            break;
        *q++ = c;
  800e49:	88 08                	mov    %cl,(%eax)
  800e4b:	83 c0 01             	add    $0x1,%eax

    if (buf_size <= 0)
        return;

    for(;;) {
        c = *str++;
  800e4e:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  800e52:	84 c9                	test   %cl,%cl
  800e54:	75 ec                	jne    800e42 <pstrcpy+0x25>
  800e56:	eb 02                	jmp    800e5a <pstrcpy+0x3d>
  800e58:	89 f0                	mov    %esi,%eax
            break;
        *q++ = c;
    }
    *q = '\0';
  800e5a:	c6 00 00             	movb   $0x0,(%eax)
}
  800e5d:	5b                   	pop    %ebx
  800e5e:	5e                   	pop    %esi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	8b 55 08             	mov    0x8(%ebp),%edx
  800e67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  800e6a:	0f b6 02             	movzbl (%edx),%eax
  800e6d:	84 c0                	test   %al,%al
  800e6f:	74 16                	je     800e87 <strcmp+0x26>
  800e71:	3a 01                	cmp    (%ecx),%al
  800e73:	75 12                	jne    800e87 <strcmp+0x26>
		p++, q++;
  800e75:	83 c1 01             	add    $0x1,%ecx
    *q = '\0';
}
int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e78:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  800e7c:	84 c0                	test   %al,%al
  800e7e:	74 07                	je     800e87 <strcmp+0x26>
  800e80:	83 c2 01             	add    $0x1,%edx
  800e83:	3a 01                	cmp    (%ecx),%al
  800e85:	74 ee                	je     800e75 <strcmp+0x14>
  800e87:	0f b6 c0             	movzbl %al,%eax
  800e8a:	0f b6 11             	movzbl (%ecx),%edx
  800e8d:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e8f:	5d                   	pop    %ebp
  800e90:	c3                   	ret    

00800e91 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	53                   	push   %ebx
  800e95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e98:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e9b:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800e9e:	85 d2                	test   %edx,%edx
  800ea0:	74 2d                	je     800ecf <strncmp+0x3e>
  800ea2:	0f b6 01             	movzbl (%ecx),%eax
  800ea5:	84 c0                	test   %al,%al
  800ea7:	74 1a                	je     800ec3 <strncmp+0x32>
  800ea9:	3a 03                	cmp    (%ebx),%al
  800eab:	75 16                	jne    800ec3 <strncmp+0x32>
  800ead:	83 ea 01             	sub    $0x1,%edx
  800eb0:	74 1d                	je     800ecf <strncmp+0x3e>
		n--, p++, q++;
  800eb2:	83 c1 01             	add    $0x1,%ecx
  800eb5:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800eb8:	0f b6 01             	movzbl (%ecx),%eax
  800ebb:	84 c0                	test   %al,%al
  800ebd:	74 04                	je     800ec3 <strncmp+0x32>
  800ebf:	3a 03                	cmp    (%ebx),%al
  800ec1:	74 ea                	je     800ead <strncmp+0x1c>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ec3:	0f b6 11             	movzbl (%ecx),%edx
  800ec6:	0f b6 03             	movzbl (%ebx),%eax
  800ec9:	29 c2                	sub    %eax,%edx
  800ecb:	89 d0                	mov    %edx,%eax
  800ecd:	eb 05                	jmp    800ed4 <strncmp+0x43>
  800ecf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ed4:	5b                   	pop    %ebx
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    

00800ed7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	8b 45 08             	mov    0x8(%ebp),%eax
  800edd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ee1:	0f b6 10             	movzbl (%eax),%edx
  800ee4:	84 d2                	test   %dl,%dl
  800ee6:	74 14                	je     800efc <strchr+0x25>
		if (*s == c)
  800ee8:	38 ca                	cmp    %cl,%dl
  800eea:	75 06                	jne    800ef2 <strchr+0x1b>
  800eec:	eb 13                	jmp    800f01 <strchr+0x2a>
  800eee:	38 ca                	cmp    %cl,%dl
  800ef0:	74 0f                	je     800f01 <strchr+0x2a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ef2:	83 c0 01             	add    $0x1,%eax
  800ef5:	0f b6 10             	movzbl (%eax),%edx
  800ef8:	84 d2                	test   %dl,%dl
  800efa:	75 f2                	jne    800eee <strchr+0x17>
  800efc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    

00800f03 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	8b 45 08             	mov    0x8(%ebp),%eax
  800f09:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f0d:	0f b6 10             	movzbl (%eax),%edx
  800f10:	84 d2                	test   %dl,%dl
  800f12:	74 18                	je     800f2c <strfind+0x29>
		if (*s == c)
  800f14:	38 ca                	cmp    %cl,%dl
  800f16:	75 0a                	jne    800f22 <strfind+0x1f>
  800f18:	eb 12                	jmp    800f2c <strfind+0x29>
  800f1a:	38 ca                	cmp    %cl,%dl
  800f1c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800f20:	74 0a                	je     800f2c <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f22:	83 c0 01             	add    $0x1,%eax
  800f25:	0f b6 10             	movzbl (%eax),%edx
  800f28:	84 d2                	test   %dl,%dl
  800f2a:	75 ee                	jne    800f1a <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800f2c:	5d                   	pop    %ebp
  800f2d:	c3                   	ret    

00800f2e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
  800f31:	83 ec 08             	sub    $0x8,%esp
  800f34:	89 1c 24             	mov    %ebx,(%esp)
  800f37:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f3b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800f41:	85 db                	test   %ebx,%ebx
  800f43:	74 36                	je     800f7b <memset+0x4d>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f45:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f4b:	75 26                	jne    800f73 <memset+0x45>
  800f4d:	f6 c3 03             	test   $0x3,%bl
  800f50:	75 21                	jne    800f73 <memset+0x45>
		c &= 0xFF;
  800f52:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800f56:	89 d0                	mov    %edx,%eax
  800f58:	c1 e0 18             	shl    $0x18,%eax
  800f5b:	89 d1                	mov    %edx,%ecx
  800f5d:	c1 e1 10             	shl    $0x10,%ecx
  800f60:	09 c8                	or     %ecx,%eax
  800f62:	09 d0                	or     %edx,%eax
  800f64:	c1 e2 08             	shl    $0x8,%edx
  800f67:	09 d0                	or     %edx,%eax
  800f69:	89 d9                	mov    %ebx,%ecx
  800f6b:	c1 e9 02             	shr    $0x2,%ecx
  800f6e:	fc                   	cld    
  800f6f:	f3 ab                	rep stos %eax,%es:(%edi)
  800f71:	eb 08                	jmp    800f7b <memset+0x4d>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f76:	89 d9                	mov    %ebx,%ecx
  800f78:	fc                   	cld    
  800f79:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f7b:	89 f8                	mov    %edi,%eax
  800f7d:	8b 1c 24             	mov    (%esp),%ebx
  800f80:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f84:	89 ec                	mov    %ebp,%esp
  800f86:	5d                   	pop    %ebp
  800f87:	c3                   	ret    

00800f88 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	83 ec 08             	sub    $0x8,%esp
  800f8e:	89 34 24             	mov    %esi,(%esp)
  800f91:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f95:	8b 45 08             	mov    0x8(%ebp),%eax
  800f98:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800f9b:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800f9e:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800fa0:	39 c6                	cmp    %eax,%esi
  800fa2:	73 38                	jae    800fdc <memmove+0x54>
  800fa4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800fa7:	39 d0                	cmp    %edx,%eax
  800fa9:	73 31                	jae    800fdc <memmove+0x54>
		s += n;
		d += n;
  800fab:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fae:	f6 c2 03             	test   $0x3,%dl
  800fb1:	75 1d                	jne    800fd0 <memmove+0x48>
  800fb3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800fb9:	75 15                	jne    800fd0 <memmove+0x48>
  800fbb:	f6 c1 03             	test   $0x3,%cl
  800fbe:	66 90                	xchg   %ax,%ax
  800fc0:	75 0e                	jne    800fd0 <memmove+0x48>
			asm volatile("std; rep movsl\n"
  800fc2:	8d 7e fc             	lea    -0x4(%esi),%edi
  800fc5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800fc8:	c1 e9 02             	shr    $0x2,%ecx
  800fcb:	fd                   	std    
  800fcc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fce:	eb 09                	jmp    800fd9 <memmove+0x51>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fd0:	8d 7e ff             	lea    -0x1(%esi),%edi
  800fd3:	8d 72 ff             	lea    -0x1(%edx),%esi
  800fd6:	fd                   	std    
  800fd7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fd9:	fc                   	cld    
  800fda:	eb 21                	jmp    800ffd <memmove+0x75>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fdc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800fe2:	75 16                	jne    800ffa <memmove+0x72>
  800fe4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800fea:	75 0e                	jne    800ffa <memmove+0x72>
  800fec:	f6 c1 03             	test   $0x3,%cl
  800fef:	90                   	nop    
  800ff0:	75 08                	jne    800ffa <memmove+0x72>
			asm volatile("cld; rep movsl\n"
  800ff2:	c1 e9 02             	shr    $0x2,%ecx
  800ff5:	fc                   	cld    
  800ff6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ff8:	eb 03                	jmp    800ffd <memmove+0x75>
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
  801022:	e8 61 ff ff ff       	call   800f88 <memmove>
}
  801027:	c9                   	leave  
  801028:	c3                   	ret    

00801029 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801029:	55                   	push   %ebp
  80102a:	89 e5                	mov    %esp,%ebp
  80102c:	57                   	push   %edi
  80102d:	56                   	push   %esi
  80102e:	53                   	push   %ebx
  80102f:	83 ec 04             	sub    $0x4,%esp
  801032:	8b 45 08             	mov    0x8(%ebp),%eax
  801035:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801038:	8b 55 10             	mov    0x10(%ebp),%edx
  80103b:	83 ea 01             	sub    $0x1,%edx
  80103e:	83 fa ff             	cmp    $0xffffffff,%edx
  801041:	74 47                	je     80108a <memcmp+0x61>
		if (*s1 != *s2)
  801043:	0f b6 30             	movzbl (%eax),%esi
  801046:	0f b6 39             	movzbl (%ecx),%edi
			return (int) *s1 - (int) *s2;
  801049:	89 45 f0             	mov    %eax,-0x10(%ebp)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  80104c:	89 f0                	mov    %esi,%eax
  80104e:	89 fb                	mov    %edi,%ebx
  801050:	38 d8                	cmp    %bl,%al
  801052:	74 2e                	je     801082 <memcmp+0x59>
  801054:	eb 1c                	jmp    801072 <memcmp+0x49>
  801056:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801059:	0f b6 70 01          	movzbl 0x1(%eax),%esi
  80105d:	0f b6 79 01          	movzbl 0x1(%ecx),%edi
  801061:	83 c0 01             	add    $0x1,%eax
  801064:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801067:	83 c1 01             	add    $0x1,%ecx
  80106a:	89 f3                	mov    %esi,%ebx
  80106c:	89 f8                	mov    %edi,%eax
  80106e:	38 c3                	cmp    %al,%bl
  801070:	74 10                	je     801082 <memcmp+0x59>
			return (int) *s1 - (int) *s2;
  801072:	89 f1                	mov    %esi,%ecx
  801074:	0f b6 d1             	movzbl %cl,%edx
  801077:	89 fb                	mov    %edi,%ebx
  801079:	0f b6 c3             	movzbl %bl,%eax
  80107c:	29 c2                	sub    %eax,%edx
  80107e:	89 d0                	mov    %edx,%eax
  801080:	eb 0d                	jmp    80108f <memcmp+0x66>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801082:	83 ea 01             	sub    $0x1,%edx
  801085:	83 fa ff             	cmp    $0xffffffff,%edx
  801088:	75 cc                	jne    801056 <memcmp+0x2d>
  80108a:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  80108f:	83 c4 04             	add    $0x4,%esp
  801092:	5b                   	pop    %ebx
  801093:	5e                   	pop    %esi
  801094:	5f                   	pop    %edi
  801095:	5d                   	pop    %ebp
  801096:	c3                   	ret    

00801097 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
  80109a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80109d:	89 c1                	mov    %eax,%ecx
  80109f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
  8010a2:	39 c8                	cmp    %ecx,%eax
  8010a4:	73 15                	jae    8010bb <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  8010a6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
  8010aa:	38 10                	cmp    %dl,(%eax)
  8010ac:	75 06                	jne    8010b4 <memfind+0x1d>
  8010ae:	eb 0b                	jmp    8010bb <memfind+0x24>
  8010b0:	38 10                	cmp    %dl,(%eax)
  8010b2:	74 07                	je     8010bb <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8010b4:	83 c0 01             	add    $0x1,%eax
  8010b7:	39 c8                	cmp    %ecx,%eax
  8010b9:	75 f5                	jne    8010b0 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8010bb:	5d                   	pop    %ebp
  8010bc:	8d 74 26 00          	lea    0x0(%esi),%esi
  8010c0:	c3                   	ret    

008010c1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	57                   	push   %edi
  8010c5:	56                   	push   %esi
  8010c6:	53                   	push   %ebx
  8010c7:	83 ec 04             	sub    $0x4,%esp
  8010ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010d0:	0f b6 01             	movzbl (%ecx),%eax
  8010d3:	3c 20                	cmp    $0x20,%al
  8010d5:	74 04                	je     8010db <strtol+0x1a>
  8010d7:	3c 09                	cmp    $0x9,%al
  8010d9:	75 0e                	jne    8010e9 <strtol+0x28>
		s++;
  8010db:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010de:	0f b6 01             	movzbl (%ecx),%eax
  8010e1:	3c 20                	cmp    $0x20,%al
  8010e3:	74 f6                	je     8010db <strtol+0x1a>
  8010e5:	3c 09                	cmp    $0x9,%al
  8010e7:	74 f2                	je     8010db <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010e9:	3c 2b                	cmp    $0x2b,%al
  8010eb:	75 0c                	jne    8010f9 <strtol+0x38>
		s++;
  8010ed:	83 c1 01             	add    $0x1,%ecx
  8010f0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8010f7:	eb 15                	jmp    80110e <strtol+0x4d>
	else if (*s == '-')
  8010f9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801100:	3c 2d                	cmp    $0x2d,%al
  801102:	75 0a                	jne    80110e <strtol+0x4d>
		s++, neg = 1;
  801104:	83 c1 01             	add    $0x1,%ecx
  801107:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80110e:	85 f6                	test   %esi,%esi
  801110:	0f 94 c0             	sete   %al
  801113:	74 05                	je     80111a <strtol+0x59>
  801115:	83 fe 10             	cmp    $0x10,%esi
  801118:	75 18                	jne    801132 <strtol+0x71>
  80111a:	80 39 30             	cmpb   $0x30,(%ecx)
  80111d:	75 13                	jne    801132 <strtol+0x71>
  80111f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801123:	75 0d                	jne    801132 <strtol+0x71>
		s += 2, base = 16;
  801125:	83 c1 02             	add    $0x2,%ecx
  801128:	be 10 00 00 00       	mov    $0x10,%esi
  80112d:	8d 76 00             	lea    0x0(%esi),%esi
  801130:	eb 1b                	jmp    80114d <strtol+0x8c>
	else if (base == 0 && s[0] == '0')
  801132:	85 f6                	test   %esi,%esi
  801134:	75 0e                	jne    801144 <strtol+0x83>
  801136:	80 39 30             	cmpb   $0x30,(%ecx)
  801139:	75 09                	jne    801144 <strtol+0x83>
		s++, base = 8;
  80113b:	83 c1 01             	add    $0x1,%ecx
  80113e:	66 be 08 00          	mov    $0x8,%si
  801142:	eb 09                	jmp    80114d <strtol+0x8c>
	else if (base == 0)
  801144:	84 c0                	test   %al,%al
  801146:	74 05                	je     80114d <strtol+0x8c>
  801148:	be 0a 00 00 00       	mov    $0xa,%esi
  80114d:	bf 00 00 00 00       	mov    $0x0,%edi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801152:	0f b6 11             	movzbl (%ecx),%edx
  801155:	89 d3                	mov    %edx,%ebx
  801157:	8d 42 d0             	lea    -0x30(%edx),%eax
  80115a:	3c 09                	cmp    $0x9,%al
  80115c:	77 08                	ja     801166 <strtol+0xa5>
			dig = *s - '0';
  80115e:	0f be c2             	movsbl %dl,%eax
  801161:	8d 50 d0             	lea    -0x30(%eax),%edx
  801164:	eb 1c                	jmp    801182 <strtol+0xc1>
		else if (*s >= 'a' && *s <= 'z')
  801166:	8d 43 9f             	lea    -0x61(%ebx),%eax
  801169:	3c 19                	cmp    $0x19,%al
  80116b:	77 08                	ja     801175 <strtol+0xb4>
			dig = *s - 'a' + 10;
  80116d:	0f be c2             	movsbl %dl,%eax
  801170:	8d 50 a9             	lea    -0x57(%eax),%edx
  801173:	eb 0d                	jmp    801182 <strtol+0xc1>
		else if (*s >= 'A' && *s <= 'Z')
  801175:	8d 43 bf             	lea    -0x41(%ebx),%eax
  801178:	3c 19                	cmp    $0x19,%al
  80117a:	77 17                	ja     801193 <strtol+0xd2>
			dig = *s - 'A' + 10;
  80117c:	0f be c2             	movsbl %dl,%eax
  80117f:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  801182:	39 f2                	cmp    %esi,%edx
  801184:	7d 0d                	jge    801193 <strtol+0xd2>
			break;
		s++, val = (val * base) + dig;
  801186:	83 c1 01             	add    $0x1,%ecx
  801189:	89 f8                	mov    %edi,%eax
  80118b:	0f af c6             	imul   %esi,%eax
  80118e:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  801191:	eb bf                	jmp    801152 <strtol+0x91>
		// we don't properly detect overflow!
	}
  801193:	89 f8                	mov    %edi,%eax

	if (endptr)
  801195:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801199:	74 05                	je     8011a0 <strtol+0xdf>
		*endptr = (char *) s;
  80119b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80119e:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  8011a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8011a4:	74 04                	je     8011aa <strtol+0xe9>
  8011a6:	89 c7                	mov    %eax,%edi
  8011a8:	f7 df                	neg    %edi
}
  8011aa:	89 f8                	mov    %edi,%eax
  8011ac:	83 c4 04             	add    $0x4,%esp
  8011af:	5b                   	pop    %ebx
  8011b0:	5e                   	pop    %esi
  8011b1:	5f                   	pop    %edi
  8011b2:	5d                   	pop    %ebp
  8011b3:	c3                   	ret    

008011b4 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	83 ec 0c             	sub    $0xc,%esp
  8011ba:	89 1c 24             	mov    %ebx,(%esp)
  8011bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011c1:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8011ca:	bf 00 00 00 00       	mov    $0x0,%edi
  8011cf:	89 fa                	mov    %edi,%edx
  8011d1:	89 f9                	mov    %edi,%ecx
  8011d3:	89 fb                	mov    %edi,%ebx
  8011d5:	89 fe                	mov    %edi,%esi
  8011d7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8011d9:	8b 1c 24             	mov    (%esp),%ebx
  8011dc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011e0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011e4:	89 ec                	mov    %ebp,%esp
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    

008011e8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	83 ec 0c             	sub    $0xc,%esp
  8011ee:	89 1c 24             	mov    %ebx,(%esp)
  8011f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011f5:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8011f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ff:	bf 00 00 00 00       	mov    $0x0,%edi
  801204:	89 f8                	mov    %edi,%eax
  801206:	89 fb                	mov    %edi,%ebx
  801208:	89 fe                	mov    %edi,%esi
  80120a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80120c:	8b 1c 24             	mov    (%esp),%ebx
  80120f:	8b 74 24 04          	mov    0x4(%esp),%esi
  801213:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801217:	89 ec                	mov    %ebp,%esp
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    

0080121b <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	83 ec 28             	sub    $0x28,%esp
  801221:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801224:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801227:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80122a:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80122d:	b8 0d 00 00 00       	mov    $0xd,%eax
  801232:	bf 00 00 00 00       	mov    $0x0,%edi
  801237:	89 f9                	mov    %edi,%ecx
  801239:	89 fb                	mov    %edi,%ebx
  80123b:	89 fe                	mov    %edi,%esi
  80123d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  80123f:	85 c0                	test   %eax,%eax
  801241:	7e 28                	jle    80126b <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801243:	89 44 24 10          	mov    %eax,0x10(%esp)
  801247:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80124e:	00 
  80124f:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  801256:	00 
  801257:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80125e:	00 
  80125f:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  801266:	e8 e9 f3 ff ff       	call   800654 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80126b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80126e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801271:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801274:	89 ec                	mov    %ebp,%esp
  801276:	5d                   	pop    %ebp
  801277:	c3                   	ret    

00801278 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	83 ec 0c             	sub    $0xc,%esp
  80127e:	89 1c 24             	mov    %ebx,(%esp)
  801281:	89 74 24 04          	mov    %esi,0x4(%esp)
  801285:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801289:	8b 55 08             	mov    0x8(%ebp),%edx
  80128c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80128f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801292:	8b 7d 14             	mov    0x14(%ebp),%edi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801295:	b8 0c 00 00 00       	mov    $0xc,%eax
  80129a:	be 00 00 00 00       	mov    $0x0,%esi
  80129f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012a1:	8b 1c 24             	mov    (%esp),%ebx
  8012a4:	8b 74 24 04          	mov    0x4(%esp),%esi
  8012a8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8012ac:	89 ec                	mov    %ebp,%esp
  8012ae:	5d                   	pop    %ebp
  8012af:	c3                   	ret    

008012b0 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	83 ec 28             	sub    $0x28,%esp
  8012b6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012b9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012bc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8012bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8012c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012ca:	bf 00 00 00 00       	mov    $0x0,%edi
  8012cf:	89 fb                	mov    %edi,%ebx
  8012d1:	89 fe                	mov    %edi,%esi
  8012d3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	7e 28                	jle    801301 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012dd:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8012e4:	00 
  8012e5:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  8012ec:	00 
  8012ed:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012f4:	00 
  8012f5:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  8012fc:	e8 53 f3 ff ff       	call   800654 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801301:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801304:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801307:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80130a:	89 ec                	mov    %ebp,%esp
  80130c:	5d                   	pop    %ebp
  80130d:	c3                   	ret    

0080130e <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80130e:	55                   	push   %ebp
  80130f:	89 e5                	mov    %esp,%ebp
  801311:	83 ec 28             	sub    $0x28,%esp
  801314:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801317:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80131a:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80131d:	8b 55 08             	mov    0x8(%ebp),%edx
  801320:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801323:	b8 09 00 00 00       	mov    $0x9,%eax
  801328:	bf 00 00 00 00       	mov    $0x0,%edi
  80132d:	89 fb                	mov    %edi,%ebx
  80132f:	89 fe                	mov    %edi,%esi
  801331:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801333:	85 c0                	test   %eax,%eax
  801335:	7e 28                	jle    80135f <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801337:	89 44 24 10          	mov    %eax,0x10(%esp)
  80133b:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801342:	00 
  801343:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  80134a:	00 
  80134b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801352:	00 
  801353:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  80135a:	e8 f5 f2 ff ff       	call   800654 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80135f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801362:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801365:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801368:	89 ec                	mov    %ebp,%esp
  80136a:	5d                   	pop    %ebp
  80136b:	c3                   	ret    

0080136c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80136c:	55                   	push   %ebp
  80136d:	89 e5                	mov    %esp,%ebp
  80136f:	83 ec 28             	sub    $0x28,%esp
  801372:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801375:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801378:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80137b:	8b 55 08             	mov    0x8(%ebp),%edx
  80137e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801381:	b8 08 00 00 00       	mov    $0x8,%eax
  801386:	bf 00 00 00 00       	mov    $0x0,%edi
  80138b:	89 fb                	mov    %edi,%ebx
  80138d:	89 fe                	mov    %edi,%esi
  80138f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801391:	85 c0                	test   %eax,%eax
  801393:	7e 28                	jle    8013bd <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801395:	89 44 24 10          	mov    %eax,0x10(%esp)
  801399:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8013a0:	00 
  8013a1:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  8013a8:	00 
  8013a9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013b0:	00 
  8013b1:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  8013b8:	e8 97 f2 ff ff       	call   800654 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8013bd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013c0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8013c3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013c6:	89 ec                	mov    %ebp,%esp
  8013c8:	5d                   	pop    %ebp
  8013c9:	c3                   	ret    

008013ca <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	83 ec 28             	sub    $0x28,%esp
  8013d0:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013d3:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013d6:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8013d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8013dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013df:	b8 06 00 00 00       	mov    $0x6,%eax
  8013e4:	bf 00 00 00 00       	mov    $0x0,%edi
  8013e9:	89 fb                	mov    %edi,%ebx
  8013eb:	89 fe                	mov    %edi,%esi
  8013ed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	7e 28                	jle    80141b <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013f3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013f7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8013fe:	00 
  8013ff:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  801406:	00 
  801407:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80140e:	00 
  80140f:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  801416:	e8 39 f2 ff ff       	call   800654 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80141b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80141e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801421:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801424:	89 ec                	mov    %ebp,%esp
  801426:	5d                   	pop    %ebp
  801427:	c3                   	ret    

00801428 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	83 ec 28             	sub    $0x28,%esp
  80142e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801431:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801434:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801437:	8b 55 08             	mov    0x8(%ebp),%edx
  80143a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80143d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801440:	8b 7d 14             	mov    0x14(%ebp),%edi
  801443:	8b 75 18             	mov    0x18(%ebp),%esi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801446:	b8 05 00 00 00       	mov    $0x5,%eax
  80144b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  80144d:	85 c0                	test   %eax,%eax
  80144f:	7e 28                	jle    801479 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801451:	89 44 24 10          	mov    %eax,0x10(%esp)
  801455:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80145c:	00 
  80145d:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  801464:	00 
  801465:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80146c:	00 
  80146d:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  801474:	e8 db f1 ff ff       	call   800654 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801479:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80147c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80147f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801482:	89 ec                	mov    %ebp,%esp
  801484:	5d                   	pop    %ebp
  801485:	c3                   	ret    

00801486 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	83 ec 28             	sub    $0x28,%esp
  80148c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80148f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801492:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801495:	8b 55 08             	mov    0x8(%ebp),%edx
  801498:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80149b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80149e:	b8 04 00 00 00       	mov    $0x4,%eax
  8014a3:	bf 00 00 00 00       	mov    $0x0,%edi
  8014a8:	89 fe                	mov    %edi,%esi
  8014aa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8014ac:	85 c0                	test   %eax,%eax
  8014ae:	7e 28                	jle    8014d8 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014b4:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8014bb:	00 
  8014bc:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  8014c3:	00 
  8014c4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014cb:	00 
  8014cc:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  8014d3:	e8 7c f1 ff ff       	call   800654 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8014d8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8014db:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8014de:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014e1:	89 ec                	mov    %ebp,%esp
  8014e3:	5d                   	pop    %ebp
  8014e4:	c3                   	ret    

008014e5 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	83 ec 0c             	sub    $0xc,%esp
  8014eb:	89 1c 24             	mov    %ebx,(%esp)
  8014ee:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014f2:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014f6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8014fb:	bf 00 00 00 00       	mov    $0x0,%edi
  801500:	89 fa                	mov    %edi,%edx
  801502:	89 f9                	mov    %edi,%ecx
  801504:	89 fb                	mov    %edi,%ebx
  801506:	89 fe                	mov    %edi,%esi
  801508:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80150a:	8b 1c 24             	mov    (%esp),%ebx
  80150d:	8b 74 24 04          	mov    0x4(%esp),%esi
  801511:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801515:	89 ec                	mov    %ebp,%esp
  801517:	5d                   	pop    %ebp
  801518:	c3                   	ret    

00801519 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801519:	55                   	push   %ebp
  80151a:	89 e5                	mov    %esp,%ebp
  80151c:	83 ec 0c             	sub    $0xc,%esp
  80151f:	89 1c 24             	mov    %ebx,(%esp)
  801522:	89 74 24 04          	mov    %esi,0x4(%esp)
  801526:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80152a:	b8 02 00 00 00       	mov    $0x2,%eax
  80152f:	bf 00 00 00 00       	mov    $0x0,%edi
  801534:	89 fa                	mov    %edi,%edx
  801536:	89 f9                	mov    %edi,%ecx
  801538:	89 fb                	mov    %edi,%ebx
  80153a:	89 fe                	mov    %edi,%esi
  80153c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80153e:	8b 1c 24             	mov    (%esp),%ebx
  801541:	8b 74 24 04          	mov    0x4(%esp),%esi
  801545:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801549:	89 ec                	mov    %ebp,%esp
  80154b:	5d                   	pop    %ebp
  80154c:	c3                   	ret    

0080154d <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	83 ec 28             	sub    $0x28,%esp
  801553:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801556:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801559:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80155c:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80155f:	b8 03 00 00 00       	mov    $0x3,%eax
  801564:	bf 00 00 00 00       	mov    $0x0,%edi
  801569:	89 f9                	mov    %edi,%ecx
  80156b:	89 fb                	mov    %edi,%ebx
  80156d:	89 fe                	mov    %edi,%esi
  80156f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801571:	85 c0                	test   %eax,%eax
  801573:	7e 28                	jle    80159d <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801575:	89 44 24 10          	mov    %eax,0x10(%esp)
  801579:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801580:	00 
  801581:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  801588:	00 
  801589:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801590:	00 
  801591:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  801598:	e8 b7 f0 ff ff       	call   800654 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80159d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8015a0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8015a3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015a6:	89 ec                	mov    %ebp,%esp
  8015a8:	5d                   	pop    %ebp
  8015a9:	c3                   	ret    
  8015aa:	00 00                	add    %al,(%eax)
  8015ac:	00 00                	add    %al,(%eax)
	...

008015b0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	57                   	push   %edi
  8015b4:	56                   	push   %esi
  8015b5:	53                   	push   %ebx
  8015b6:	83 ec 1c             	sub    $0x1c,%esp
  8015b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8015bc:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  8015bf:	e8 55 ff ff ff       	call   801519 <sys_getenvid>
  8015c4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8015c9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8015cc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8015d1:	a3 24 50 80 00       	mov    %eax,0x805024
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  8015d6:	e8 3e ff ff ff       	call   801519 <sys_getenvid>
  8015db:	25 ff 03 00 00       	and    $0x3ff,%eax
  8015e0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8015e3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8015e8:	a3 24 50 80 00       	mov    %eax,0x805024
		if(env->env_id==to_env){
  8015ed:	8b 40 4c             	mov    0x4c(%eax),%eax
  8015f0:	39 f0                	cmp    %esi,%eax
  8015f2:	75 0e                	jne    801602 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  8015f4:	c7 04 24 8a 29 80 00 	movl   $0x80298a,(%esp)
  8015fb:	e8 21 f1 ff ff       	call   800721 <cprintf>
  801600:	eb 5a                	jmp    80165c <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  801602:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801606:	8b 45 10             	mov    0x10(%ebp),%eax
  801609:	89 44 24 08          	mov    %eax,0x8(%esp)
  80160d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801610:	89 44 24 04          	mov    %eax,0x4(%esp)
  801614:	89 34 24             	mov    %esi,(%esp)
  801617:	e8 5c fc ff ff       	call   801278 <sys_ipc_try_send>
  80161c:	89 c3                	mov    %eax,%ebx
  80161e:	85 c0                	test   %eax,%eax
  801620:	79 25                	jns    801647 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  801622:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801625:	74 2b                	je     801652 <ipc_send+0xa2>
				panic("send error:%e",r);
  801627:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80162b:	c7 44 24 08 a6 29 80 	movl   $0x8029a6,0x8(%esp)
  801632:	00 
  801633:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80163a:	00 
  80163b:	c7 04 24 b4 29 80 00 	movl   $0x8029b4,(%esp)
  801642:	e8 0d f0 ff ff       	call   800654 <_panic>
		}
			sys_yield();
  801647:	e8 99 fe ff ff       	call   8014e5 <sys_yield>
		
	}while(r!=0);
  80164c:	85 db                	test   %ebx,%ebx
  80164e:	75 86                	jne    8015d6 <ipc_send+0x26>
  801650:	eb 0a                	jmp    80165c <ipc_send+0xac>
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
		{	
			if(r!=-E_IPC_NOT_RECV)
				panic("send error:%e",r);
		}
			sys_yield();
  801652:	e8 8e fe ff ff       	call   8014e5 <sys_yield>
  801657:	e9 7a ff ff ff       	jmp    8015d6 <ipc_send+0x26>
		
	}while(r!=0);
	return;
	//panic("ipc_send not implemented");
}
  80165c:	83 c4 1c             	add    $0x1c,%esp
  80165f:	5b                   	pop    %ebx
  801660:	5e                   	pop    %esi
  801661:	5f                   	pop    %edi
  801662:	5d                   	pop    %ebp
  801663:	c3                   	ret    

00801664 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801664:	55                   	push   %ebp
  801665:	89 e5                	mov    %esp,%ebp
  801667:	57                   	push   %edi
  801668:	56                   	push   %esi
  801669:	53                   	push   %ebx
  80166a:	83 ec 0c             	sub    $0xc,%esp
  80166d:	8b 75 08             	mov    0x8(%ebp),%esi
  801670:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	void *dstva=NULL;
	if(pg)
		dstva=pg;
	env = &envs[ENVX(sys_getenvid())];
  801673:	e8 a1 fe ff ff       	call   801519 <sys_getenvid>
  801678:	25 ff 03 00 00       	and    $0x3ff,%eax
  80167d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801680:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801685:	a3 24 50 80 00       	mov    %eax,0x805024
	if(from_env_store&&(env->env_id==*from_env_store))
  80168a:	85 f6                	test   %esi,%esi
  80168c:	74 29                	je     8016b7 <ipc_recv+0x53>
  80168e:	8b 40 4c             	mov    0x4c(%eax),%eax
  801691:	3b 06                	cmp    (%esi),%eax
  801693:	75 22                	jne    8016b7 <ipc_recv+0x53>
	{
		*from_env_store=0;
  801695:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  80169b:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("send:the reciver is sender\n");
  8016a1:	c7 04 24 8a 29 80 00 	movl   $0x80298a,(%esp)
  8016a8:	e8 74 f0 ff ff       	call   800721 <cprintf>
  8016ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016b2:	e9 8a 00 00 00       	jmp    801741 <ipc_recv+0xdd>
		return 0;
	}
	env = &envs[ENVX(sys_getenvid())];
  8016b7:	e8 5d fe ff ff       	call   801519 <sys_getenvid>
  8016bc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016c1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8016c4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8016c9:	a3 24 50 80 00       	mov    %eax,0x805024
	if((r=sys_ipc_recv(dstva))<0)
  8016ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016d1:	89 04 24             	mov    %eax,(%esp)
  8016d4:	e8 42 fb ff ff       	call   80121b <sys_ipc_recv>
  8016d9:	89 c3                	mov    %eax,%ebx
  8016db:	85 c0                	test   %eax,%eax
  8016dd:	79 1a                	jns    8016f9 <ipc_recv+0x95>
	{
		*from_env_store=0;
  8016df:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  8016e5:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("reciver failed\n");
  8016eb:	c7 04 24 be 29 80 00 	movl   $0x8029be,(%esp)
  8016f2:	e8 2a f0 ff ff       	call   800721 <cprintf>
  8016f7:	eb 48                	jmp    801741 <ipc_recv+0xdd>
		return r;
	}
	else{//接收成功
		env = &envs[ENVX(sys_getenvid())];
  8016f9:	e8 1b fe ff ff       	call   801519 <sys_getenvid>
  8016fe:	25 ff 03 00 00       	and    $0x3ff,%eax
  801703:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801706:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80170b:	a3 24 50 80 00       	mov    %eax,0x805024
		if(from_env_store)
  801710:	85 f6                	test   %esi,%esi
  801712:	74 05                	je     801719 <ipc_recv+0xb5>
			*from_env_store=env->env_ipc_from;	
  801714:	8b 40 74             	mov    0x74(%eax),%eax
  801717:	89 06                	mov    %eax,(%esi)
		if(perm_store)
  801719:	85 ff                	test   %edi,%edi
  80171b:	74 0a                	je     801727 <ipc_recv+0xc3>
			*perm_store=env->env_ipc_perm;
  80171d:	a1 24 50 80 00       	mov    0x805024,%eax
  801722:	8b 40 78             	mov    0x78(%eax),%eax
  801725:	89 07                	mov    %eax,(%edi)
		env = &envs[ENVX(sys_getenvid())];
  801727:	e8 ed fd ff ff       	call   801519 <sys_getenvid>
  80172c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801731:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801734:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801739:	a3 24 50 80 00       	mov    %eax,0x805024
		return env->env_ipc_value;
  80173e:	8b 58 70             	mov    0x70(%eax),%ebx
	}
	//panic("ipc_recv not implemented");
	return 0;
}
  801741:	89 d8                	mov    %ebx,%eax
  801743:	83 c4 0c             	add    $0xc,%esp
  801746:	5b                   	pop    %ebx
  801747:	5e                   	pop    %esi
  801748:	5f                   	pop    %edi
  801749:	5d                   	pop    %ebp
  80174a:	c3                   	ret    
  80174b:	00 00                	add    %al,(%eax)
  80174d:	00 00                	add    %al,(%eax)
	...

00801750 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	8b 45 08             	mov    0x8(%ebp),%eax
  801756:	05 00 00 00 30       	add    $0x30000000,%eax
  80175b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80175e:	5d                   	pop    %ebp
  80175f:	c3                   	ret    

00801760 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801766:	8b 45 08             	mov    0x8(%ebp),%eax
  801769:	89 04 24             	mov    %eax,(%esp)
  80176c:	e8 df ff ff ff       	call   801750 <fd2num>
  801771:	c1 e0 0c             	shl    $0xc,%eax
  801774:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801779:	c9                   	leave  
  80177a:	c3                   	ret    

0080177b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	53                   	push   %ebx
  80177f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801782:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801787:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801789:	89 d0                	mov    %edx,%eax
  80178b:	c1 e8 16             	shr    $0x16,%eax
  80178e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801795:	a8 01                	test   $0x1,%al
  801797:	74 10                	je     8017a9 <fd_alloc+0x2e>
  801799:	89 d0                	mov    %edx,%eax
  80179b:	c1 e8 0c             	shr    $0xc,%eax
  80179e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017a5:	a8 01                	test   $0x1,%al
  8017a7:	75 09                	jne    8017b2 <fd_alloc+0x37>
			*fd_store = fd;
  8017a9:	89 0b                	mov    %ecx,(%ebx)
  8017ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b0:	eb 19                	jmp    8017cb <fd_alloc+0x50>
			return 0;
  8017b2:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8017b8:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  8017be:	75 c7                	jne    801787 <fd_alloc+0xc>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8017c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8017c6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8017cb:	5b                   	pop    %ebx
  8017cc:	5d                   	pop    %ebp
  8017cd:	c3                   	ret    

008017ce <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8017d1:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  8017d5:	77 38                	ja     80180f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8017d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017da:	c1 e0 0c             	shl    $0xc,%eax
  8017dd:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  8017e3:	89 d0                	mov    %edx,%eax
  8017e5:	c1 e8 16             	shr    $0x16,%eax
  8017e8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8017ef:	a8 01                	test   $0x1,%al
  8017f1:	74 1c                	je     80180f <fd_lookup+0x41>
  8017f3:	89 d0                	mov    %edx,%eax
  8017f5:	c1 e8 0c             	shr    $0xc,%eax
  8017f8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017ff:	a8 01                	test   $0x1,%al
  801801:	74 0c                	je     80180f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801803:	8b 45 0c             	mov    0xc(%ebp),%eax
  801806:	89 10                	mov    %edx,(%eax)
  801808:	b8 00 00 00 00       	mov    $0x0,%eax
  80180d:	eb 05                	jmp    801814 <fd_lookup+0x46>
	return 0;
  80180f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801814:	5d                   	pop    %ebp
  801815:	c3                   	ret    

00801816 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801816:	55                   	push   %ebp
  801817:	89 e5                	mov    %esp,%ebp
  801819:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80181c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80181f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801823:	8b 45 08             	mov    0x8(%ebp),%eax
  801826:	89 04 24             	mov    %eax,(%esp)
  801829:	e8 a0 ff ff ff       	call   8017ce <fd_lookup>
  80182e:	85 c0                	test   %eax,%eax
  801830:	78 0e                	js     801840 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801832:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801835:	8b 55 0c             	mov    0xc(%ebp),%edx
  801838:	89 50 04             	mov    %edx,0x4(%eax)
  80183b:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801840:	c9                   	leave  
  801841:	c3                   	ret    

00801842 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801842:	55                   	push   %ebp
  801843:	89 e5                	mov    %esp,%ebp
  801845:	53                   	push   %ebx
  801846:	83 ec 14             	sub    $0x14,%esp
  801849:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80184c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80184f:	ba 08 50 80 00       	mov    $0x805008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801854:	b8 00 00 00 00       	mov    $0x0,%eax
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801859:	39 0d 08 50 80 00    	cmp    %ecx,0x805008
  80185f:	75 11                	jne    801872 <dev_lookup+0x30>
  801861:	eb 04                	jmp    801867 <dev_lookup+0x25>
  801863:	39 0a                	cmp    %ecx,(%edx)
  801865:	75 0b                	jne    801872 <dev_lookup+0x30>
			*dev = devtab[i];
  801867:	89 13                	mov    %edx,(%ebx)
  801869:	b8 00 00 00 00       	mov    $0x0,%eax
  80186e:	66 90                	xchg   %ax,%ax
  801870:	eb 35                	jmp    8018a7 <dev_lookup+0x65>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801872:	83 c0 01             	add    $0x1,%eax
  801875:	8b 14 85 50 2a 80 00 	mov    0x802a50(,%eax,4),%edx
  80187c:	85 d2                	test   %edx,%edx
  80187e:	75 e3                	jne    801863 <dev_lookup+0x21>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  801880:	a1 24 50 80 00       	mov    0x805024,%eax
  801885:	8b 40 4c             	mov    0x4c(%eax),%eax
  801888:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80188c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801890:	c7 04 24 d0 29 80 00 	movl   $0x8029d0,(%esp)
  801897:	e8 85 ee ff ff       	call   800721 <cprintf>
	*dev = 0;
  80189c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8018a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8018a7:	83 c4 14             	add    $0x14,%esp
  8018aa:	5b                   	pop    %ebx
  8018ab:	5d                   	pop    %ebp
  8018ac:	c3                   	ret    

008018ad <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8018ad:	55                   	push   %ebp
  8018ae:	89 e5                	mov    %esp,%ebp
  8018b0:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018b3:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8018b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bd:	89 04 24             	mov    %eax,(%esp)
  8018c0:	e8 09 ff ff ff       	call   8017ce <fd_lookup>
  8018c5:	89 c2                	mov    %eax,%edx
  8018c7:	85 c0                	test   %eax,%eax
  8018c9:	78 5a                	js     801925 <fstat+0x78>
  8018cb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8018d5:	8b 00                	mov    (%eax),%eax
  8018d7:	89 04 24             	mov    %eax,(%esp)
  8018da:	e8 63 ff ff ff       	call   801842 <dev_lookup>
  8018df:	89 c2                	mov    %eax,%edx
  8018e1:	85 c0                	test   %eax,%eax
  8018e3:	78 40                	js     801925 <fstat+0x78>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8018e5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  8018ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018ed:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018f1:	74 32                	je     801925 <fstat+0x78>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f6:	c6 00 00             	movb   $0x0,(%eax)
	stat->st_size = 0;
  8018f9:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  801900:	00 00 00 
	stat->st_isdir = 0;
  801903:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
  80190a:	00 00 00 
	stat->st_dev = dev;
  80190d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801910:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
	return (*dev->dev_stat)(fd, stat);
  801916:	89 44 24 04          	mov    %eax,0x4(%esp)
  80191a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80191d:	89 04 24             	mov    %eax,(%esp)
  801920:	ff 52 14             	call   *0x14(%edx)
  801923:	89 c2                	mov    %eax,%edx
}
  801925:	89 d0                	mov    %edx,%eax
  801927:	c9                   	leave  
  801928:	c3                   	ret    

00801929 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801929:	55                   	push   %ebp
  80192a:	89 e5                	mov    %esp,%ebp
  80192c:	53                   	push   %ebx
  80192d:	83 ec 24             	sub    $0x24,%esp
  801930:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801933:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801936:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193a:	89 1c 24             	mov    %ebx,(%esp)
  80193d:	e8 8c fe ff ff       	call   8017ce <fd_lookup>
  801942:	85 c0                	test   %eax,%eax
  801944:	78 61                	js     8019a7 <ftruncate+0x7e>
  801946:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801949:	8b 10                	mov    (%eax),%edx
  80194b:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80194e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801952:	89 14 24             	mov    %edx,(%esp)
  801955:	e8 e8 fe ff ff       	call   801842 <dev_lookup>
  80195a:	85 c0                	test   %eax,%eax
  80195c:	78 49                	js     8019a7 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80195e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801961:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801965:	75 23                	jne    80198a <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801967:	a1 24 50 80 00       	mov    0x805024,%eax
  80196c:	8b 40 4c             	mov    0x4c(%eax),%eax
  80196f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801973:	89 44 24 04          	mov    %eax,0x4(%esp)
  801977:	c7 04 24 f0 29 80 00 	movl   $0x8029f0,(%esp)
  80197e:	e8 9e ed ff ff       	call   800721 <cprintf>
  801983:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801988:	eb 1d                	jmp    8019a7 <ftruncate+0x7e>
			env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80198a:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80198d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801992:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801996:	74 0f                	je     8019a7 <ftruncate+0x7e>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801998:	8b 42 18             	mov    0x18(%edx),%eax
  80199b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80199e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019a2:	89 0c 24             	mov    %ecx,(%esp)
  8019a5:	ff d0                	call   *%eax
}
  8019a7:	83 c4 24             	add    $0x24,%esp
  8019aa:	5b                   	pop    %ebx
  8019ab:	5d                   	pop    %ebp
  8019ac:	c3                   	ret    

008019ad <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8019ad:	55                   	push   %ebp
  8019ae:	89 e5                	mov    %esp,%ebp
  8019b0:	53                   	push   %ebx
  8019b1:	83 ec 24             	sub    $0x24,%esp
  8019b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019be:	89 1c 24             	mov    %ebx,(%esp)
  8019c1:	e8 08 fe ff ff       	call   8017ce <fd_lookup>
  8019c6:	85 c0                	test   %eax,%eax
  8019c8:	78 68                	js     801a32 <write+0x85>
  8019ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019cd:	8b 10                	mov    (%eax),%edx
  8019cf:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8019d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d6:	89 14 24             	mov    %edx,(%esp)
  8019d9:	e8 64 fe ff ff       	call   801842 <dev_lookup>
  8019de:	85 c0                	test   %eax,%eax
  8019e0:	78 50                	js     801a32 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019e2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  8019e5:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  8019e9:	75 23                	jne    801a0e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  8019eb:	a1 24 50 80 00       	mov    0x805024,%eax
  8019f0:	8b 40 4c             	mov    0x4c(%eax),%eax
  8019f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019fb:	c7 04 24 14 2a 80 00 	movl   $0x802a14,(%esp)
  801a02:	e8 1a ed ff ff       	call   800721 <cprintf>
  801a07:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a0c:	eb 24                	jmp    801a32 <write+0x85>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801a0e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801a11:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a16:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  801a1a:	74 16                	je     801a32 <write+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801a1c:	8b 42 0c             	mov    0xc(%edx),%eax
  801a1f:	8b 55 10             	mov    0x10(%ebp),%edx
  801a22:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a26:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a29:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a2d:	89 0c 24             	mov    %ecx,(%esp)
  801a30:	ff d0                	call   *%eax
}
  801a32:	83 c4 24             	add    $0x24,%esp
  801a35:	5b                   	pop    %ebx
  801a36:	5d                   	pop    %ebp
  801a37:	c3                   	ret    

00801a38 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	53                   	push   %ebx
  801a3c:	83 ec 24             	sub    $0x24,%esp
  801a3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a45:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a49:	89 1c 24             	mov    %ebx,(%esp)
  801a4c:	e8 7d fd ff ff       	call   8017ce <fd_lookup>
  801a51:	85 c0                	test   %eax,%eax
  801a53:	78 6d                	js     801ac2 <read+0x8a>
  801a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a58:	8b 10                	mov    (%eax),%edx
  801a5a:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801a5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a61:	89 14 24             	mov    %edx,(%esp)
  801a64:	e8 d9 fd ff ff       	call   801842 <dev_lookup>
  801a69:	85 c0                	test   %eax,%eax
  801a6b:	78 55                	js     801ac2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801a6d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801a70:	8b 41 08             	mov    0x8(%ecx),%eax
  801a73:	83 e0 03             	and    $0x3,%eax
  801a76:	83 f8 01             	cmp    $0x1,%eax
  801a79:	75 23                	jne    801a9e <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  801a7b:	a1 24 50 80 00       	mov    0x805024,%eax
  801a80:	8b 40 4c             	mov    0x4c(%eax),%eax
  801a83:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a87:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8b:	c7 04 24 31 2a 80 00 	movl   $0x802a31,(%esp)
  801a92:	e8 8a ec ff ff       	call   800721 <cprintf>
  801a97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a9c:	eb 24                	jmp    801ac2 <read+0x8a>
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801a9e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801aa1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801aa6:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  801aaa:	74 16                	je     801ac2 <read+0x8a>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801aac:	8b 42 08             	mov    0x8(%edx),%eax
  801aaf:	8b 55 10             	mov    0x10(%ebp),%edx
  801ab2:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ab6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ab9:	89 54 24 04          	mov    %edx,0x4(%esp)
  801abd:	89 0c 24             	mov    %ecx,(%esp)
  801ac0:	ff d0                	call   *%eax
}
  801ac2:	83 c4 24             	add    $0x24,%esp
  801ac5:	5b                   	pop    %ebx
  801ac6:	5d                   	pop    %ebp
  801ac7:	c3                   	ret    

00801ac8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801ac8:	55                   	push   %ebp
  801ac9:	89 e5                	mov    %esp,%ebp
  801acb:	57                   	push   %edi
  801acc:	56                   	push   %esi
  801acd:	53                   	push   %ebx
  801ace:	83 ec 0c             	sub    $0xc,%esp
  801ad1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ad4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801ad7:	b8 00 00 00 00       	mov    $0x0,%eax
  801adc:	85 f6                	test   %esi,%esi
  801ade:	74 36                	je     801b16 <readn+0x4e>
  801ae0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ae5:	ba 00 00 00 00       	mov    $0x0,%edx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801aea:	89 f0                	mov    %esi,%eax
  801aec:	29 d0                	sub    %edx,%eax
  801aee:	89 44 24 08          	mov    %eax,0x8(%esp)
  801af2:	8d 04 17             	lea    (%edi,%edx,1),%eax
  801af5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af9:	8b 45 08             	mov    0x8(%ebp),%eax
  801afc:	89 04 24             	mov    %eax,(%esp)
  801aff:	e8 34 ff ff ff       	call   801a38 <read>
		if (m < 0)
  801b04:	85 c0                	test   %eax,%eax
  801b06:	78 0e                	js     801b16 <readn+0x4e>
			return m;
		if (m == 0)
  801b08:	85 c0                	test   %eax,%eax
  801b0a:	74 08                	je     801b14 <readn+0x4c>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b0c:	01 c3                	add    %eax,%ebx
  801b0e:	89 da                	mov    %ebx,%edx
  801b10:	39 f3                	cmp    %esi,%ebx
  801b12:	72 d6                	jb     801aea <readn+0x22>
  801b14:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801b16:	83 c4 0c             	add    $0xc,%esp
  801b19:	5b                   	pop    %ebx
  801b1a:	5e                   	pop    %esi
  801b1b:	5f                   	pop    %edi
  801b1c:	5d                   	pop    %ebp
  801b1d:	c3                   	ret    

00801b1e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801b1e:	55                   	push   %ebp
  801b1f:	89 e5                	mov    %esp,%ebp
  801b21:	83 ec 28             	sub    $0x28,%esp
  801b24:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b27:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801b2a:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801b2d:	89 34 24             	mov    %esi,(%esp)
  801b30:	e8 1b fc ff ff       	call   801750 <fd2num>
  801b35:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b38:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b3c:	89 04 24             	mov    %eax,(%esp)
  801b3f:	e8 8a fc ff ff       	call   8017ce <fd_lookup>
  801b44:	89 c3                	mov    %eax,%ebx
  801b46:	85 c0                	test   %eax,%eax
  801b48:	78 05                	js     801b4f <fd_close+0x31>
  801b4a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801b4d:	74 0d                	je     801b5c <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801b4f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b53:	75 44                	jne    801b99 <fd_close+0x7b>
  801b55:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b5a:	eb 3d                	jmp    801b99 <fd_close+0x7b>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801b5c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b63:	8b 06                	mov    (%esi),%eax
  801b65:	89 04 24             	mov    %eax,(%esp)
  801b68:	e8 d5 fc ff ff       	call   801842 <dev_lookup>
  801b6d:	89 c3                	mov    %eax,%ebx
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	78 16                	js     801b89 <fd_close+0x6b>
		if (dev->dev_close)
  801b73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b76:	8b 40 10             	mov    0x10(%eax),%eax
  801b79:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b7e:	85 c0                	test   %eax,%eax
  801b80:	74 07                	je     801b89 <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  801b82:	89 34 24             	mov    %esi,(%esp)
  801b85:	ff d0                	call   *%eax
  801b87:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801b89:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b94:	e8 31 f8 ff ff       	call   8013ca <sys_page_unmap>
	return r;
}
  801b99:	89 d8                	mov    %ebx,%eax
  801b9b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b9e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ba1:	89 ec                	mov    %ebp,%esp
  801ba3:	5d                   	pop    %ebp
  801ba4:	c3                   	ret    

00801ba5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bab:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801bae:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb5:	89 04 24             	mov    %eax,(%esp)
  801bb8:	e8 11 fc ff ff       	call   8017ce <fd_lookup>
  801bbd:	85 c0                	test   %eax,%eax
  801bbf:	78 13                	js     801bd4 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801bc1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801bc8:	00 
  801bc9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801bcc:	89 04 24             	mov    %eax,(%esp)
  801bcf:	e8 4a ff ff ff       	call   801b1e <fd_close>
}
  801bd4:	c9                   	leave  
  801bd5:	c3                   	ret    

00801bd6 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801bd6:	55                   	push   %ebp
  801bd7:	89 e5                	mov    %esp,%ebp
  801bd9:	83 ec 18             	sub    $0x18,%esp
  801bdc:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801bdf:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801be2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801be9:	00 
  801bea:	8b 45 08             	mov    0x8(%ebp),%eax
  801bed:	89 04 24             	mov    %eax,(%esp)
  801bf0:	e8 6a 03 00 00       	call   801f5f <open>
  801bf5:	89 c6                	mov    %eax,%esi
  801bf7:	85 c0                	test   %eax,%eax
  801bf9:	78 1b                	js     801c16 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801bfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bfe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c02:	89 34 24             	mov    %esi,(%esp)
  801c05:	e8 a3 fc ff ff       	call   8018ad <fstat>
  801c0a:	89 c3                	mov    %eax,%ebx
	close(fd);
  801c0c:	89 34 24             	mov    %esi,(%esp)
  801c0f:	e8 91 ff ff ff       	call   801ba5 <close>
  801c14:	89 de                	mov    %ebx,%esi
	return r;
}
  801c16:	89 f0                	mov    %esi,%eax
  801c18:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801c1b:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c1e:	89 ec                	mov    %ebp,%esp
  801c20:	5d                   	pop    %ebp
  801c21:	c3                   	ret    

00801c22 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801c22:	55                   	push   %ebp
  801c23:	89 e5                	mov    %esp,%ebp
  801c25:	83 ec 38             	sub    $0x38,%esp
  801c28:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801c2b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801c2e:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801c31:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801c34:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3e:	89 04 24             	mov    %eax,(%esp)
  801c41:	e8 88 fb ff ff       	call   8017ce <fd_lookup>
  801c46:	89 c3                	mov    %eax,%ebx
  801c48:	85 c0                	test   %eax,%eax
  801c4a:	0f 88 e1 00 00 00    	js     801d31 <dup+0x10f>
		return r;
	close(newfdnum);
  801c50:	89 3c 24             	mov    %edi,(%esp)
  801c53:	e8 4d ff ff ff       	call   801ba5 <close>

	newfd = INDEX2FD(newfdnum);
  801c58:	89 f8                	mov    %edi,%eax
  801c5a:	c1 e0 0c             	shl    $0xc,%eax
  801c5d:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  801c63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c66:	89 04 24             	mov    %eax,(%esp)
  801c69:	e8 f2 fa ff ff       	call   801760 <fd2data>
  801c6e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801c70:	89 34 24             	mov    %esi,(%esp)
  801c73:	e8 e8 fa ff ff       	call   801760 <fd2data>
  801c78:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  801c7b:	89 d8                	mov    %ebx,%eax
  801c7d:	c1 e8 16             	shr    $0x16,%eax
  801c80:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c87:	a8 01                	test   $0x1,%al
  801c89:	74 45                	je     801cd0 <dup+0xae>
  801c8b:	89 da                	mov    %ebx,%edx
  801c8d:	c1 ea 0c             	shr    $0xc,%edx
  801c90:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801c97:	a8 01                	test   $0x1,%al
  801c99:	74 35                	je     801cd0 <dup+0xae>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  801c9b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801ca2:	25 07 0e 00 00       	and    $0xe07,%eax
  801ca7:	89 44 24 10          	mov    %eax,0x10(%esp)
  801cab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cb2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cb9:	00 
  801cba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cbe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cc5:	e8 5e f7 ff ff       	call   801428 <sys_page_map>
  801cca:	89 c3                	mov    %eax,%ebx
  801ccc:	85 c0                	test   %eax,%eax
  801cce:	78 3e                	js     801d0e <dup+0xec>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  801cd0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801cd3:	89 d0                	mov    %edx,%eax
  801cd5:	c1 e8 0c             	shr    $0xc,%eax
  801cd8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801cdf:	25 07 0e 00 00       	and    $0xe07,%eax
  801ce4:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ce8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801cec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cf3:	00 
  801cf4:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cf8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cff:	e8 24 f7 ff ff       	call   801428 <sys_page_map>
  801d04:	89 c3                	mov    %eax,%ebx
  801d06:	85 c0                	test   %eax,%eax
  801d08:	78 04                	js     801d0e <dup+0xec>
		goto err;
  801d0a:	89 fb                	mov    %edi,%ebx
  801d0c:	eb 23                	jmp    801d31 <dup+0x10f>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801d0e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d12:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d19:	e8 ac f6 ff ff       	call   8013ca <sys_page_unmap>
	sys_page_unmap(0, nva);
  801d1e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d21:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d2c:	e8 99 f6 ff ff       	call   8013ca <sys_page_unmap>
	return r;
}
  801d31:	89 d8                	mov    %ebx,%eax
  801d33:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801d36:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801d39:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801d3c:	89 ec                	mov    %ebp,%esp
  801d3e:	5d                   	pop    %ebp
  801d3f:	c3                   	ret    

00801d40 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	53                   	push   %ebx
  801d44:	83 ec 04             	sub    $0x4,%esp
  801d47:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801d4c:	89 1c 24             	mov    %ebx,(%esp)
  801d4f:	e8 51 fe ff ff       	call   801ba5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801d54:	83 c3 01             	add    $0x1,%ebx
  801d57:	83 fb 20             	cmp    $0x20,%ebx
  801d5a:	75 f0                	jne    801d4c <close_all+0xc>
		close(i);
}
  801d5c:	83 c4 04             	add    $0x4,%esp
  801d5f:	5b                   	pop    %ebx
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    
	...

00801d64 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801d64:	55                   	push   %ebp
  801d65:	89 e5                	mov    %esp,%ebp
  801d67:	53                   	push   %ebx
  801d68:	83 ec 14             	sub    $0x14,%esp
  801d6b:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801d6d:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801d73:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d7a:	00 
  801d7b:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801d82:	00 
  801d83:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d87:	89 14 24             	mov    %edx,(%esp)
  801d8a:	e8 21 f8 ff ff       	call   8015b0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801d8f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d96:	00 
  801d97:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801da2:	e8 bd f8 ff ff       	call   801664 <ipc_recv>
}
  801da7:	83 c4 14             	add    $0x14,%esp
  801daa:	5b                   	pop    %ebx
  801dab:	5d                   	pop    %ebp
  801dac:	c3                   	ret    

00801dad <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801dad:	55                   	push   %ebp
  801dae:	89 e5                	mov    %esp,%ebp
  801db0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801db3:	ba 00 00 00 00       	mov    $0x0,%edx
  801db8:	b8 08 00 00 00       	mov    $0x8,%eax
  801dbd:	e8 a2 ff ff ff       	call   801d64 <fsipc>
}
  801dc2:	c9                   	leave  
  801dc3:	c3                   	ret    

00801dc4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801dc4:	55                   	push   %ebp
  801dc5:	89 e5                	mov    %esp,%ebp
  801dc7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801dca:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcd:	8b 40 0c             	mov    0xc(%eax),%eax
  801dd0:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  801dd5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd8:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ddd:	ba 00 00 00 00       	mov    $0x0,%edx
  801de2:	b8 02 00 00 00       	mov    $0x2,%eax
  801de7:	e8 78 ff ff ff       	call   801d64 <fsipc>
}
  801dec:	c9                   	leave  
  801ded:	c3                   	ret    

00801dee <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801dee:	55                   	push   %ebp
  801def:	89 e5                	mov    %esp,%ebp
  801df1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801df4:	8b 45 08             	mov    0x8(%ebp),%eax
  801df7:	8b 40 0c             	mov    0xc(%eax),%eax
  801dfa:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  801dff:	ba 00 00 00 00       	mov    $0x0,%edx
  801e04:	b8 06 00 00 00       	mov    $0x6,%eax
  801e09:	e8 56 ff ff ff       	call   801d64 <fsipc>
}
  801e0e:	c9                   	leave  
  801e0f:	c3                   	ret    

00801e10 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	53                   	push   %ebx
  801e14:	83 ec 14             	sub    $0x14,%esp
  801e17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1d:	8b 40 0c             	mov    0xc(%eax),%eax
  801e20:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801e25:	ba 00 00 00 00       	mov    $0x0,%edx
  801e2a:	b8 05 00 00 00       	mov    $0x5,%eax
  801e2f:	e8 30 ff ff ff       	call   801d64 <fsipc>
  801e34:	85 c0                	test   %eax,%eax
  801e36:	78 2b                	js     801e63 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801e38:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801e3f:	00 
  801e40:	89 1c 24             	mov    %ebx,(%esp)
  801e43:	e8 39 ef ff ff       	call   800d81 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801e48:	a1 80 30 80 00       	mov    0x803080,%eax
  801e4d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801e53:	a1 84 30 80 00       	mov    0x803084,%eax
  801e58:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801e5e:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801e63:	83 c4 14             	add    $0x14,%esp
  801e66:	5b                   	pop    %ebx
  801e67:	5d                   	pop    %ebp
  801e68:	c3                   	ret    

00801e69 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801e69:	55                   	push   %ebp
  801e6a:	89 e5                	mov    %esp,%ebp
  801e6c:	83 ec 18             	sub    $0x18,%esp
  801e6f:	8b 55 10             	mov    0x10(%ebp),%edx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	ssize_t writesize;
	size_t bufsize;
	fsipcbuf.write.req_fileid=fd->fd_file.id;
  801e72:	8b 45 08             	mov    0x8(%ebp),%eax
  801e75:	8b 40 0c             	mov    0xc(%eax),%eax
  801e78:	a3 00 30 80 00       	mov    %eax,0x803000
	bufsize=sizeof(fsipcbuf.write.req_buf);
	if(n<bufsize)
  801e7d:	89 d0                	mov    %edx,%eax
  801e7f:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  801e85:	76 05                	jbe    801e8c <devfile_write+0x23>
  801e87:	b8 f8 0f 00 00       	mov    $0xff8,%eax
		bufsize=n;	
	fsipcbuf.write.req_n=n;
  801e8c:	89 15 04 30 80 00    	mov    %edx,0x803004
	memmove((void*)fsipcbuf.write.req_buf,buf,bufsize);
  801e92:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e96:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e99:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e9d:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801ea4:	e8 df f0 ff ff       	call   800f88 <memmove>
	writesize=(ssize_t)fsipc(FSREQ_WRITE,NULL);
  801ea9:	ba 00 00 00 00       	mov    $0x0,%edx
  801eae:	b8 04 00 00 00       	mov    $0x4,%eax
  801eb3:	e8 ac fe ff ff       	call   801d64 <fsipc>
	return writesize;
	//panic("devfile_write not implemented");
}
  801eb8:	c9                   	leave  
  801eb9:	c3                   	ret    

00801eba <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	53                   	push   %ebx
  801ebe:	83 ec 14             	sub    $0x14,%esp
	// system server.
	// LAB 5: Your code here
	ssize_t readsize;
	if(debug)
		cprintf("devfile_read:fileid=%x readsize=%x\n",fd->fd_file.id,n);
	fsipcbuf.read.req_fileid=fd->fd_file.id;
  801ec1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec4:	8b 40 0c             	mov    0xc(%eax),%eax
  801ec7:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n=n;
  801ecc:	8b 45 10             	mov    0x10(%ebp),%eax
  801ecf:	a3 04 30 80 00       	mov    %eax,0x803004
	readsize=(ssize_t)fsipc(FSREQ_READ,&fsipcbuf);
  801ed4:	ba 00 30 80 00       	mov    $0x803000,%edx
  801ed9:	b8 03 00 00 00       	mov    $0x3,%eax
  801ede:	e8 81 fe ff ff       	call   801d64 <fsipc>
  801ee3:	89 c3                	mov    %eax,%ebx
	cprintf("readsize=%d\n",readsize);
  801ee5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ee9:	c7 04 24 58 2a 80 00 	movl   $0x802a58,(%esp)
  801ef0:	e8 2c e8 ff ff       	call   800721 <cprintf>
	if(debug)
		cprintf("devfile_read:buf1=%s\nbuf2=%s\n",(char*)&fsipcbuf,fsipcbuf.readRet.ret_buf);
	if(readsize>0)
  801ef5:	85 db                	test   %ebx,%ebx
  801ef7:	7e 17                	jle    801f10 <devfile_read+0x56>
		memmove(buf,(void*)&fsipcbuf,(size_t)readsize);
  801ef9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801efd:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801f04:	00 
  801f05:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f08:	89 04 24             	mov    %eax,(%esp)
  801f0b:	e8 78 f0 ff ff       	call   800f88 <memmove>
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
  801f25:	e8 06 ee ff ff       	call   800d30 <strlen>
  801f2a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  801f2f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801f34:	7f 21                	jg     801f57 <remove+0x3f>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801f36:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f3a:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801f41:	e8 3b ee ff ff       	call   800d81 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801f46:	ba 00 00 00 00       	mov    $0x0,%edx
  801f4b:	b8 07 00 00 00       	mov    $0x7,%eax
  801f50:	e8 0f fe ff ff       	call   801d64 <fsipc>
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
  801f62:	53                   	push   %ebx
  801f63:	83 ec 24             	sub    $0x24,%esp
	// file descriptor.

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;
	if((r=fd_alloc(&fd))<0){
  801f66:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801f69:	89 04 24             	mov    %eax,(%esp)
  801f6c:	e8 0a f8 ff ff       	call   80177b <fd_alloc>
  801f71:	89 c3                	mov    %eax,%ebx
  801f73:	85 c0                	test   %eax,%eax
  801f75:	79 18                	jns    801f8f <open+0x30>
		fd_close(fd,0);
  801f77:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f7e:	00 
  801f7f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801f82:	89 04 24             	mov    %eax,(%esp)
  801f85:	e8 94 fb ff ff       	call   801b1e <fd_close>
  801f8a:	e9 b4 00 00 00       	jmp    802043 <open+0xe4>
		return r;
	}
	cprintf("open:fd=%x\n",fd);
  801f8f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801f92:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f96:	c7 04 24 65 2a 80 00 	movl   $0x802a65,(%esp)
  801f9d:	e8 7f e7 ff ff       	call   800721 <cprintf>
	strcpy(fsipcbuf.open.req_path,path);
  801fa2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa9:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801fb0:	e8 cc ed ff ff       	call   800d81 <strcpy>
	fsipcbuf.open.req_omode=mode;
  801fb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fb8:	a3 00 34 80 00       	mov    %eax,0x803400
	if((r=fsipc(FSREQ_OPEN,(void*)fd))<0)
  801fbd:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801fc0:	b8 01 00 00 00       	mov    $0x1,%eax
  801fc5:	e8 9a fd ff ff       	call   801d64 <fsipc>
  801fca:	89 c3                	mov    %eax,%ebx
  801fcc:	85 c0                	test   %eax,%eax
  801fce:	79 15                	jns    801fe5 <open+0x86>
	{
		fd_close(fd,1);
  801fd0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801fd7:	00 
  801fd8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801fdb:	89 04 24             	mov    %eax,(%esp)
  801fde:	e8 3b fb ff ff       	call   801b1e <fd_close>
  801fe3:	eb 5e                	jmp    802043 <open+0xe4>
		return r;	
	}
	if((r=sys_page_map(0,(void*)fd,0,(void*)fd,PTE_P | PTE_W | PTE_U))<0)
  801fe5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801fe8:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801fef:	00 
  801ff0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ff4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ffb:	00 
  801ffc:	89 44 24 04          	mov    %eax,0x4(%esp)
  802000:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802007:	e8 1c f4 ff ff       	call   801428 <sys_page_map>
  80200c:	89 c3                	mov    %eax,%ebx
  80200e:	85 c0                	test   %eax,%eax
  802010:	79 15                	jns    802027 <open+0xc8>
	{
		fd_close(fd,1);
  802012:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802019:	00 
  80201a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80201d:	89 04 24             	mov    %eax,(%esp)
  802020:	e8 f9 fa ff ff       	call   801b1e <fd_close>
  802025:	eb 1c                	jmp    802043 <open+0xe4>
		return r;
	}
	//INDEX2DATA(fd->fd_file.id);
	cprintf("fileid=%x\n",fd->fd_file.id);
  802027:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80202a:	8b 40 0c             	mov    0xc(%eax),%eax
  80202d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802031:	c7 04 24 71 2a 80 00 	movl   $0x802a71,(%esp)
  802038:	e8 e4 e6 ff ff       	call   800721 <cprintf>
	return fd->fd_file.id;
  80203d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  802040:	8b 58 0c             	mov    0xc(%eax),%ebx
	//panic("open not implemented");
}
  802043:	89 d8                	mov    %ebx,%eax
  802045:	83 c4 24             	add    $0x24,%esp
  802048:	5b                   	pop    %ebx
  802049:	5d                   	pop    %ebp
  80204a:	c3                   	ret    
  80204b:	00 00                	add    %al,(%eax)
  80204d:	00 00                	add    %al,(%eax)
	...

00802050 <__udivdi3>:
  802050:	55                   	push   %ebp
  802051:	89 e5                	mov    %esp,%ebp
  802053:	57                   	push   %edi
  802054:	56                   	push   %esi
  802055:	83 ec 18             	sub    $0x18,%esp
  802058:	8b 45 10             	mov    0x10(%ebp),%eax
  80205b:	8b 55 14             	mov    0x14(%ebp),%edx
  80205e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802061:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802064:	89 c1                	mov    %eax,%ecx
  802066:	8b 45 08             	mov    0x8(%ebp),%eax
  802069:	85 d2                	test   %edx,%edx
  80206b:	89 d7                	mov    %edx,%edi
  80206d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802070:	75 1e                	jne    802090 <__udivdi3+0x40>
  802072:	39 f1                	cmp    %esi,%ecx
  802074:	0f 86 8d 00 00 00    	jbe    802107 <__udivdi3+0xb7>
  80207a:	89 f2                	mov    %esi,%edx
  80207c:	31 f6                	xor    %esi,%esi
  80207e:	f7 f1                	div    %ecx
  802080:	89 c1                	mov    %eax,%ecx
  802082:	89 c8                	mov    %ecx,%eax
  802084:	89 f2                	mov    %esi,%edx
  802086:	83 c4 18             	add    $0x18,%esp
  802089:	5e                   	pop    %esi
  80208a:	5f                   	pop    %edi
  80208b:	5d                   	pop    %ebp
  80208c:	c3                   	ret    
  80208d:	8d 76 00             	lea    0x0(%esi),%esi
  802090:	39 f2                	cmp    %esi,%edx
  802092:	0f 87 a8 00 00 00    	ja     802140 <__udivdi3+0xf0>
  802098:	0f bd c2             	bsr    %edx,%eax
  80209b:	83 f0 1f             	xor    $0x1f,%eax
  80209e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8020a1:	0f 84 89 00 00 00    	je     802130 <__udivdi3+0xe0>
  8020a7:	b8 20 00 00 00       	mov    $0x20,%eax
  8020ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020af:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8020b2:	89 c1                	mov    %eax,%ecx
  8020b4:	d3 ea                	shr    %cl,%edx
  8020b6:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  8020ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8020bd:	89 f8                	mov    %edi,%eax
  8020bf:	8b 7d f4             	mov    -0xc(%ebp),%edi
  8020c2:	d3 e0                	shl    %cl,%eax
  8020c4:	09 c2                	or     %eax,%edx
  8020c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8020c9:	d3 e7                	shl    %cl,%edi
  8020cb:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020cf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8020d2:	89 f2                	mov    %esi,%edx
  8020d4:	d3 e8                	shr    %cl,%eax
  8020d6:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  8020da:	d3 e2                	shl    %cl,%edx
  8020dc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020e0:	09 d0                	or     %edx,%eax
  8020e2:	d3 ee                	shr    %cl,%esi
  8020e4:	89 f2                	mov    %esi,%edx
  8020e6:	f7 75 e4             	divl   -0x1c(%ebp)
  8020e9:	89 d1                	mov    %edx,%ecx
  8020eb:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8020ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8020f1:	f7 e7                	mul    %edi
  8020f3:	39 d1                	cmp    %edx,%ecx
  8020f5:	89 c6                	mov    %eax,%esi
  8020f7:	72 70                	jb     802169 <__udivdi3+0x119>
  8020f9:	39 ca                	cmp    %ecx,%edx
  8020fb:	74 5f                	je     80215c <__udivdi3+0x10c>
  8020fd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802100:	31 f6                	xor    %esi,%esi
  802102:	e9 7b ff ff ff       	jmp    802082 <__udivdi3+0x32>
  802107:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80210a:	85 c0                	test   %eax,%eax
  80210c:	75 0c                	jne    80211a <__udivdi3+0xca>
  80210e:	b8 01 00 00 00       	mov    $0x1,%eax
  802113:	31 d2                	xor    %edx,%edx
  802115:	f7 75 f4             	divl   -0xc(%ebp)
  802118:	89 c1                	mov    %eax,%ecx
  80211a:	89 f0                	mov    %esi,%eax
  80211c:	89 fa                	mov    %edi,%edx
  80211e:	f7 f1                	div    %ecx
  802120:	89 c6                	mov    %eax,%esi
  802122:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802125:	f7 f1                	div    %ecx
  802127:	89 c1                	mov    %eax,%ecx
  802129:	e9 54 ff ff ff       	jmp    802082 <__udivdi3+0x32>
  80212e:	66 90                	xchg   %ax,%ax
  802130:	39 d6                	cmp    %edx,%esi
  802132:	77 1c                	ja     802150 <__udivdi3+0x100>
  802134:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802137:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  80213a:	73 14                	jae    802150 <__udivdi3+0x100>
  80213c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802140:	31 c9                	xor    %ecx,%ecx
  802142:	31 f6                	xor    %esi,%esi
  802144:	e9 39 ff ff ff       	jmp    802082 <__udivdi3+0x32>
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  802150:	b9 01 00 00 00       	mov    $0x1,%ecx
  802155:	31 f6                	xor    %esi,%esi
  802157:	e9 26 ff ff ff       	jmp    802082 <__udivdi3+0x32>
  80215c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80215f:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  802163:	d3 e0                	shl    %cl,%eax
  802165:	39 c6                	cmp    %eax,%esi
  802167:	76 94                	jbe    8020fd <__udivdi3+0xad>
  802169:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80216c:	31 f6                	xor    %esi,%esi
  80216e:	83 e9 01             	sub    $0x1,%ecx
  802171:	e9 0c ff ff ff       	jmp    802082 <__udivdi3+0x32>
	...

00802180 <__umoddi3>:
  802180:	55                   	push   %ebp
  802181:	89 e5                	mov    %esp,%ebp
  802183:	57                   	push   %edi
  802184:	56                   	push   %esi
  802185:	83 ec 30             	sub    $0x30,%esp
  802188:	8b 45 10             	mov    0x10(%ebp),%eax
  80218b:	8b 55 14             	mov    0x14(%ebp),%edx
  80218e:	8b 75 08             	mov    0x8(%ebp),%esi
  802191:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802194:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802197:	89 c1                	mov    %eax,%ecx
  802199:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80219c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80219f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8021a6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8021ad:	89 fa                	mov    %edi,%edx
  8021af:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8021b2:	85 c0                	test   %eax,%eax
  8021b4:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8021b7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8021ba:	75 14                	jne    8021d0 <__umoddi3+0x50>
  8021bc:	39 f9                	cmp    %edi,%ecx
  8021be:	76 60                	jbe    802220 <__umoddi3+0xa0>
  8021c0:	89 f0                	mov    %esi,%eax
  8021c2:	f7 f1                	div    %ecx
  8021c4:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8021c7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8021ce:	eb 10                	jmp    8021e0 <__umoddi3+0x60>
  8021d0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8021d3:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  8021d6:	76 18                	jbe    8021f0 <__umoddi3+0x70>
  8021d8:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8021db:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8021de:	66 90                	xchg   %ax,%ax
  8021e0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8021e3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8021e6:	83 c4 30             	add    $0x30,%esp
  8021e9:	5e                   	pop    %esi
  8021ea:	5f                   	pop    %edi
  8021eb:	5d                   	pop    %ebp
  8021ec:	c3                   	ret    
  8021ed:	8d 76 00             	lea    0x0(%esi),%esi
  8021f0:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
  8021f4:	83 f0 1f             	xor    $0x1f,%eax
  8021f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8021fa:	75 46                	jne    802242 <__umoddi3+0xc2>
  8021fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8021ff:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  802202:	0f 87 c9 00 00 00    	ja     8022d1 <__umoddi3+0x151>
  802208:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  80220b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80220e:	0f 83 bd 00 00 00    	jae    8022d1 <__umoddi3+0x151>
  802214:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802217:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80221a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80221d:	eb c1                	jmp    8021e0 <__umoddi3+0x60>
  80221f:	90                   	nop    
  802220:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802223:	85 c0                	test   %eax,%eax
  802225:	75 0c                	jne    802233 <__umoddi3+0xb3>
  802227:	b8 01 00 00 00       	mov    $0x1,%eax
  80222c:	31 d2                	xor    %edx,%edx
  80222e:	f7 75 ec             	divl   -0x14(%ebp)
  802231:	89 c1                	mov    %eax,%ecx
  802233:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802236:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802239:	f7 f1                	div    %ecx
  80223b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80223e:	f7 f1                	div    %ecx
  802240:	eb 82                	jmp    8021c4 <__umoddi3+0x44>
  802242:	b8 20 00 00 00       	mov    $0x20,%eax
  802247:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80224a:	2b 45 d8             	sub    -0x28(%ebp),%eax
  80224d:	8b 75 ec             	mov    -0x14(%ebp),%esi
  802250:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802253:	89 c1                	mov    %eax,%ecx
  802255:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802258:	d3 ea                	shr    %cl,%edx
  80225a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80225d:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  802261:	d3 e0                	shl    %cl,%eax
  802263:	09 c2                	or     %eax,%edx
  802265:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802268:	d3 e6                	shl    %cl,%esi
  80226a:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  80226e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802271:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802274:	d3 e8                	shr    %cl,%eax
  802276:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  80227a:	d3 e2                	shl    %cl,%edx
  80227c:	09 d0                	or     %edx,%eax
  80227e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802281:	d3 e7                	shl    %cl,%edi
  802283:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  802287:	d3 ea                	shr    %cl,%edx
  802289:	f7 75 f4             	divl   -0xc(%ebp)
  80228c:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80228f:	f7 e6                	mul    %esi
  802291:	39 55 cc             	cmp    %edx,-0x34(%ebp)
  802294:	72 53                	jb     8022e9 <__umoddi3+0x169>
  802296:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  802299:	74 4a                	je     8022e5 <__umoddi3+0x165>
  80229b:	90                   	nop    
  80229c:	8d 74 26 00          	lea    0x0(%esi),%esi
  8022a0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8022a3:	29 c7                	sub    %eax,%edi
  8022a5:	19 d1                	sbb    %edx,%ecx
  8022a7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8022aa:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8022ae:	89 fa                	mov    %edi,%edx
  8022b0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8022b3:	d3 ea                	shr    %cl,%edx
  8022b5:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8022b9:	d3 e0                	shl    %cl,%eax
  8022bb:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8022bf:	09 c2                	or     %eax,%edx
  8022c1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8022c4:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8022c7:	d3 e8                	shr    %cl,%eax
  8022c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8022cc:	e9 0f ff ff ff       	jmp    8021e0 <__umoddi3+0x60>
  8022d1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8022d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022d7:	2b 45 ec             	sub    -0x14(%ebp),%eax
  8022da:	1b 55 e8             	sbb    -0x18(%ebp),%edx
  8022dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8022e0:	e9 2f ff ff ff       	jmp    802214 <__umoddi3+0x94>
  8022e5:	39 f8                	cmp    %edi,%eax
  8022e7:	76 b7                	jbe    8022a0 <__umoddi3+0x120>
  8022e9:	29 f0                	sub    %esi,%eax
  8022eb:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8022ee:	eb b0                	jmp    8022a0 <__umoddi3+0x120>
