
obj/user/writemotd:     file format elf32-i386

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
  80002c:	e8 13 02 00 00       	call   800244 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/lib.h>

void
umain(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
	int rfd, wfd;
	char buf[512];
	int n, r;

	if ((rfd = open("/newmotd", O_RDONLY)) < 0)
  800040:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800047:	00 
  800048:	c7 04 24 40 24 80 00 	movl   $0x802440,(%esp)
  80004f:	e8 fb 19 00 00       	call   801a4f <open>
  800054:	89 85 f0 fd ff ff    	mov    %eax,-0x210(%ebp)
  80005a:	85 c0                	test   %eax,%eax
  80005c:	79 20                	jns    80007e <umain+0x4a>
		panic("open /newmotd: %e", rfd);
  80005e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800062:	c7 44 24 08 49 24 80 	movl   $0x802449,0x8(%esp)
  800069:	00 
  80006a:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  800071:	00 
  800072:	c7 04 24 5b 24 80 00 	movl   $0x80245b,(%esp)
  800079:	e8 3e 02 00 00       	call   8002bc <_panic>
	if ((wfd = open("/motd", O_RDWR)) < 0)
  80007e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  800085:	00 
  800086:	c7 04 24 6c 24 80 00 	movl   $0x80246c,(%esp)
  80008d:	e8 bd 19 00 00       	call   801a4f <open>
  800092:	89 c7                	mov    %eax,%edi
  800094:	85 c0                	test   %eax,%eax
  800096:	79 20                	jns    8000b8 <umain+0x84>
		panic("open /motd: %e", wfd);
  800098:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80009c:	c7 44 24 08 72 24 80 	movl   $0x802472,0x8(%esp)
  8000a3:	00 
  8000a4:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  8000ab:	00 
  8000ac:	c7 04 24 5b 24 80 00 	movl   $0x80245b,(%esp)
  8000b3:	e8 04 02 00 00       	call   8002bc <_panic>
	cprintf("file descriptors %d %d\n", rfd, wfd);
  8000b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000bc:	8b 85 f0 fd ff ff    	mov    -0x210(%ebp),%eax
  8000c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000c6:	c7 04 24 81 24 80 00 	movl   $0x802481,(%esp)
  8000cd:	e8 b7 02 00 00       	call   800389 <cprintf>
	if (rfd == wfd)
  8000d2:	39 bd f0 fd ff ff    	cmp    %edi,-0x210(%ebp)
  8000d8:	75 1c                	jne    8000f6 <umain+0xc2>
		panic("open /newmotd and /motd give same file descriptor");
  8000da:	c7 44 24 08 ec 24 80 	movl   $0x8024ec,0x8(%esp)
  8000e1:	00 
  8000e2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  8000e9:	00 
  8000ea:	c7 04 24 5b 24 80 00 	movl   $0x80245b,(%esp)
  8000f1:	e8 c6 01 00 00       	call   8002bc <_panic>

	cprintf("OLD MOTD\n===\n");
  8000f6:	c7 04 24 99 24 80 00 	movl   $0x802499,(%esp)
  8000fd:	e8 87 02 00 00       	call   800389 <cprintf>
	while ((n = read(wfd, buf, sizeof buf-1)) > 0)
  800102:	8d 9d f4 fd ff ff    	lea    -0x20c(%ebp),%ebx
  800108:	eb 0c                	jmp    800116 <umain+0xe2>
		sys_cputs(buf, n);
  80010a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80010e:	89 1c 24             	mov    %ebx,(%esp)
  800111:	e8 42 0d 00 00       	call   800e58 <sys_cputs>
	cprintf("file descriptors %d %d\n", rfd, wfd);
	if (rfd == wfd)
		panic("open /newmotd and /motd give same file descriptor");

	cprintf("OLD MOTD\n===\n");
	while ((n = read(wfd, buf, sizeof buf-1)) > 0)
  800116:	c7 44 24 08 ff 01 00 	movl   $0x1ff,0x8(%esp)
  80011d:	00 
  80011e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800122:	89 3c 24             	mov    %edi,(%esp)
  800125:	e8 0e 14 00 00       	call   801538 <read>
  80012a:	85 c0                	test   %eax,%eax
  80012c:	7f dc                	jg     80010a <umain+0xd6>
		sys_cputs(buf, n);
	cprintf("===\n");
  80012e:	c7 04 24 a2 24 80 00 	movl   $0x8024a2,(%esp)
  800135:	e8 4f 02 00 00       	call   800389 <cprintf>
	seek(wfd, 0);
  80013a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800141:	00 
  800142:	89 3c 24             	mov    %edi,(%esp)
  800145:	e8 cc 11 00 00       	call   801316 <seek>

	if ((r = ftruncate(wfd, 0)) < 0)
  80014a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800151:	00 
  800152:	89 3c 24             	mov    %edi,(%esp)
  800155:	e8 cf 12 00 00       	call   801429 <ftruncate>
  80015a:	85 c0                	test   %eax,%eax
  80015c:	79 20                	jns    80017e <umain+0x14a>
		panic("truncate /motd: %e", r);
  80015e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800162:	c7 44 24 08 a7 24 80 	movl   $0x8024a7,0x8(%esp)
  800169:	00 
  80016a:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  800171:	00 
  800172:	c7 04 24 5b 24 80 00 	movl   $0x80245b,(%esp)
  800179:	e8 3e 01 00 00       	call   8002bc <_panic>

	cprintf("NEW MOTD\n===\n");
  80017e:	c7 04 24 ba 24 80 00 	movl   $0x8024ba,(%esp)
  800185:	e8 ff 01 00 00       	call   800389 <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0) {
  80018a:	8d b5 f4 fd ff ff    	lea    -0x20c(%ebp),%esi
  800190:	eb 40                	jmp    8001d2 <umain+0x19e>
		sys_cputs(buf, n);
  800192:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800196:	89 34 24             	mov    %esi,(%esp)
  800199:	e8 ba 0c 00 00       	call   800e58 <sys_cputs>
		if ((r = write(wfd, buf, n)) != n)
  80019e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a6:	89 3c 24             	mov    %edi,(%esp)
  8001a9:	e8 ff 12 00 00       	call   8014ad <write>
  8001ae:	39 c3                	cmp    %eax,%ebx
  8001b0:	74 20                	je     8001d2 <umain+0x19e>
			panic("write /motd: %e", r);
  8001b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b6:	c7 44 24 08 c8 24 80 	movl   $0x8024c8,0x8(%esp)
  8001bd:	00 
  8001be:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  8001c5:	00 
  8001c6:	c7 04 24 5b 24 80 00 	movl   $0x80245b,(%esp)
  8001cd:	e8 ea 00 00 00       	call   8002bc <_panic>

	if ((r = ftruncate(wfd, 0)) < 0)
		panic("truncate /motd: %e", r);

	cprintf("NEW MOTD\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0) {
  8001d2:	c7 44 24 08 ff 01 00 	movl   $0x1ff,0x8(%esp)
  8001d9:	00 
  8001da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001de:	8b 85 f0 fd ff ff    	mov    -0x210(%ebp),%eax
  8001e4:	89 04 24             	mov    %eax,(%esp)
  8001e7:	e8 4c 13 00 00       	call   801538 <read>
  8001ec:	89 c3                	mov    %eax,%ebx
  8001ee:	85 c0                	test   %eax,%eax
  8001f0:	7f a0                	jg     800192 <umain+0x15e>
		sys_cputs(buf, n);
		if ((r = write(wfd, buf, n)) != n)
			panic("write /motd: %e", r);
	}
	cprintf("===\n");
  8001f2:	c7 04 24 a2 24 80 00 	movl   $0x8024a2,(%esp)
  8001f9:	e8 8b 01 00 00       	call   800389 <cprintf>

	if (n < 0)
  8001fe:	85 db                	test   %ebx,%ebx
  800200:	79 20                	jns    800222 <umain+0x1ee>
		panic("read /newmotd: %e", n);
  800202:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800206:	c7 44 24 08 d8 24 80 	movl   $0x8024d8,0x8(%esp)
  80020d:	00 
  80020e:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800215:	00 
  800216:	c7 04 24 5b 24 80 00 	movl   $0x80245b,(%esp)
  80021d:	e8 9a 00 00 00       	call   8002bc <_panic>

	close(rfd);
  800222:	8b 85 f0 fd ff ff    	mov    -0x210(%ebp),%eax
  800228:	89 04 24             	mov    %eax,(%esp)
  80022b:	e8 75 14 00 00       	call   8016a5 <close>
	close(wfd);
  800230:	89 3c 24             	mov    %edi,(%esp)
  800233:	e8 6d 14 00 00       	call   8016a5 <close>
}
  800238:	81 c4 1c 02 00 00    	add    $0x21c,%esp
  80023e:	5b                   	pop    %ebx
  80023f:	5e                   	pop    %esi
  800240:	5f                   	pop    %edi
  800241:	5d                   	pop    %ebp
  800242:	c3                   	ret    
	...

00800244 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	83 ec 18             	sub    $0x18,%esp
  80024a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80024d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800250:	8b 75 08             	mov    0x8(%ebp),%esi
  800253:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  800256:	c7 05 3c 60 80 00 00 	movl   $0x0,0x80603c
  80025d:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  800260:	e8 58 0f 00 00       	call   8011bd <sys_getenvid>
  800265:	25 ff 03 00 00       	and    $0x3ff,%eax
  80026a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80026d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800272:	a3 3c 60 80 00       	mov    %eax,0x80603c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800277:	85 f6                	test   %esi,%esi
  800279:	7e 07                	jle    800282 <libmain+0x3e>
		binaryname = argv[0];
  80027b:	8b 03                	mov    (%ebx),%eax
  80027d:	a3 00 60 80 00       	mov    %eax,0x806000

	// call user main routine
	umain(argc, argv);
  800282:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800286:	89 34 24             	mov    %esi,(%esp)
  800289:	e8 a6 fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80028e:	e8 0d 00 00 00       	call   8002a0 <exit>
}
  800293:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800296:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800299:	89 ec                	mov    %ebp,%esp
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    
  80029d:	00 00                	add    %al,(%eax)
	...

008002a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002a6:	e8 95 15 00 00       	call   801840 <close_all>
	sys_env_destroy(0);
  8002ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002b2:	e8 3a 0f 00 00       	call   8011f1 <sys_env_destroy>
}
  8002b7:	c9                   	leave  
  8002b8:	c3                   	ret    
  8002b9:	00 00                	add    %al,(%eax)
	...

008002bc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8002c5:	89 45 fc             	mov    %eax,-0x4(%ebp)

	// Print the panic message
	if (argv0)
  8002c8:	a1 40 60 80 00       	mov    0x806040,%eax
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	74 10                	je     8002e1 <_panic+0x25>
		cprintf("%s: ", argv0);
  8002d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d5:	c7 04 24 35 25 80 00 	movl   $0x802535,(%esp)
  8002dc:	e8 a8 00 00 00       	call   800389 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8002e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ef:	a1 00 60 80 00       	mov    0x806000,%eax
  8002f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f8:	c7 04 24 3a 25 80 00 	movl   $0x80253a,(%esp)
  8002ff:	e8 85 00 00 00       	call   800389 <cprintf>
	vcprintf(fmt, ap);
  800304:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800307:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030b:	8b 45 10             	mov    0x10(%ebp),%eax
  80030e:	89 04 24             	mov    %eax,(%esp)
  800311:	e8 12 00 00 00       	call   800328 <vcprintf>
	cprintf("\n");
  800316:	c7 04 24 a5 24 80 00 	movl   $0x8024a5,(%esp)
  80031d:	e8 67 00 00 00       	call   800389 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800322:	cc                   	int3   
  800323:	eb fd                	jmp    800322 <_panic+0x66>
  800325:	00 00                	add    %al,(%eax)
	...

00800328 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800331:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800338:	00 00 00 
	b.cnt = 0;
  80033b:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  800342:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800345:	8b 45 0c             	mov    0xc(%ebp),%eax
  800348:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80034c:	8b 45 08             	mov    0x8(%ebp),%eax
  80034f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800353:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800359:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035d:	c7 04 24 a6 03 80 00 	movl   $0x8003a6,(%esp)
  800364:	e8 cc 01 00 00       	call   800535 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800369:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
  80036f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800373:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  800379:	89 04 24             	mov    %eax,(%esp)
  80037c:	e8 d7 0a 00 00       	call   800e58 <sys_cputs>
  800381:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  800387:	c9                   	leave  
  800388:	c3                   	ret    

00800389 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80038f:	8d 45 0c             	lea    0xc(%ebp),%eax
  800392:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800395:	89 44 24 04          	mov    %eax,0x4(%esp)
  800399:	8b 45 08             	mov    0x8(%ebp),%eax
  80039c:	89 04 24             	mov    %eax,(%esp)
  80039f:	e8 84 ff ff ff       	call   800328 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003a4:	c9                   	leave  
  8003a5:	c3                   	ret    

008003a6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	53                   	push   %ebx
  8003aa:	83 ec 14             	sub    $0x14,%esp
  8003ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003b0:	8b 03                	mov    (%ebx),%eax
  8003b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b5:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003b9:	83 c0 01             	add    $0x1,%eax
  8003bc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003c3:	75 19                	jne    8003de <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8003c5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003cc:	00 
  8003cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8003d0:	89 04 24             	mov    %eax,(%esp)
  8003d3:	e8 80 0a 00 00       	call   800e58 <sys_cputs>
		b->idx = 0;
  8003d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003de:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003e2:	83 c4 14             	add    $0x14,%esp
  8003e5:	5b                   	pop    %ebx
  8003e6:	5d                   	pop    %ebp
  8003e7:	c3                   	ret    
	...

008003f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	57                   	push   %edi
  8003f4:	56                   	push   %esi
  8003f5:	53                   	push   %ebx
  8003f6:	83 ec 3c             	sub    $0x3c,%esp
  8003f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003fc:	89 d7                	mov    %edx,%edi
  8003fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800401:	8b 55 0c             	mov    0xc(%ebp),%edx
  800404:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800407:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80040a:	8b 55 10             	mov    0x10(%ebp),%edx
  80040d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800410:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800413:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  80041a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80041d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  800420:	72 14                	jb     800436 <printnum+0x46>
  800422:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800425:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800428:	76 0c                	jbe    800436 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80042a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80042d:	83 eb 01             	sub    $0x1,%ebx
  800430:	85 db                	test   %ebx,%ebx
  800432:	7f 57                	jg     80048b <printnum+0x9b>
  800434:	eb 64                	jmp    80049a <printnum+0xaa>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800436:	89 74 24 10          	mov    %esi,0x10(%esp)
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	83 e8 01             	sub    $0x1,%eax
  800440:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800444:	89 54 24 08          	mov    %edx,0x8(%esp)
  800448:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80044c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800450:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800453:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800456:	89 44 24 08          	mov    %eax,0x8(%esp)
  80045a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80045e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800461:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800464:	89 04 24             	mov    %eax,(%esp)
  800467:	89 54 24 04          	mov    %edx,0x4(%esp)
  80046b:	e8 30 1d 00 00       	call   8021a0 <__udivdi3>
  800470:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800474:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800478:	89 04 24             	mov    %eax,(%esp)
  80047b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80047f:	89 fa                	mov    %edi,%edx
  800481:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800484:	e8 67 ff ff ff       	call   8003f0 <printnum>
  800489:	eb 0f                	jmp    80049a <printnum+0xaa>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80048b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80048f:	89 34 24             	mov    %esi,(%esp)
  800492:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800495:	83 eb 01             	sub    $0x1,%ebx
  800498:	75 f1                	jne    80048b <printnum+0x9b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80049a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80049e:	8b 74 24 04          	mov    0x4(%esp),%esi
  8004a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8004a5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8004a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8004b6:	89 04 24             	mov    %eax,(%esp)
  8004b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004bd:	e8 0e 1e 00 00       	call   8022d0 <__umoddi3>
  8004c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004c6:	0f be 80 56 25 80 00 	movsbl 0x802556(%eax),%eax
  8004cd:	89 04 24             	mov    %eax,(%esp)
  8004d0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8004d3:	83 c4 3c             	add    $0x3c,%esp
  8004d6:	5b                   	pop    %ebx
  8004d7:	5e                   	pop    %esi
  8004d8:	5f                   	pop    %edi
  8004d9:	5d                   	pop    %ebp
  8004da:	c3                   	ret    

008004db <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004db:	55                   	push   %ebp
  8004dc:	89 e5                	mov    %esp,%ebp
  8004de:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8004e0:	83 fa 01             	cmp    $0x1,%edx
  8004e3:	7e 0e                	jle    8004f3 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8004e5:	8b 10                	mov    (%eax),%edx
  8004e7:	8d 42 08             	lea    0x8(%edx),%eax
  8004ea:	89 01                	mov    %eax,(%ecx)
  8004ec:	8b 02                	mov    (%edx),%eax
  8004ee:	8b 52 04             	mov    0x4(%edx),%edx
  8004f1:	eb 22                	jmp    800515 <getuint+0x3a>
	else if (lflag)
  8004f3:	85 d2                	test   %edx,%edx
  8004f5:	74 10                	je     800507 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8004f7:	8b 10                	mov    (%eax),%edx
  8004f9:	8d 42 04             	lea    0x4(%edx),%eax
  8004fc:	89 01                	mov    %eax,(%ecx)
  8004fe:	8b 02                	mov    (%edx),%eax
  800500:	ba 00 00 00 00       	mov    $0x0,%edx
  800505:	eb 0e                	jmp    800515 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800507:	8b 10                	mov    (%eax),%edx
  800509:	8d 42 04             	lea    0x4(%edx),%eax
  80050c:	89 01                	mov    %eax,(%ecx)
  80050e:	8b 02                	mov    (%edx),%eax
  800510:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800515:	5d                   	pop    %ebp
  800516:	c3                   	ret    

00800517 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800517:	55                   	push   %ebp
  800518:	89 e5                	mov    %esp,%ebp
  80051a:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  80051d:	83 42 08 01          	addl   $0x1,0x8(%edx)
	if (b->buf < b->ebuf)
  800521:	8b 02                	mov    (%edx),%eax
  800523:	3b 42 04             	cmp    0x4(%edx),%eax
  800526:	73 0b                	jae    800533 <sprintputch+0x1c>
		*b->buf++ = ch;
  800528:	0f b6 4d 08          	movzbl 0x8(%ebp),%ecx
  80052c:	88 08                	mov    %cl,(%eax)
  80052e:	83 c0 01             	add    $0x1,%eax
  800531:	89 02                	mov    %eax,(%edx)
}
  800533:	5d                   	pop    %ebp
  800534:	c3                   	ret    

00800535 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800535:	55                   	push   %ebp
  800536:	89 e5                	mov    %esp,%ebp
  800538:	57                   	push   %edi
  800539:	56                   	push   %esi
  80053a:	53                   	push   %ebx
  80053b:	83 ec 3c             	sub    $0x3c,%esp
  80053e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800541:	eb 18                	jmp    80055b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800543:	84 c0                	test   %al,%al
  800545:	0f 84 9f 03 00 00    	je     8008ea <vprintfmt+0x3b5>
				return;
			putch(ch, putdat);
  80054b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80054e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800552:	0f b6 c0             	movzbl %al,%eax
  800555:	89 04 24             	mov    %eax,(%esp)
  800558:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80055b:	0f b6 03             	movzbl (%ebx),%eax
  80055e:	83 c3 01             	add    $0x1,%ebx
  800561:	3c 25                	cmp    $0x25,%al
  800563:	75 de                	jne    800543 <vprintfmt+0xe>
  800565:	b9 00 00 00 00       	mov    $0x0,%ecx
  80056a:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
  800571:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800576:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80057d:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
  800581:	eb 07                	jmp    80058a <vprintfmt+0x55>
  800583:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058a:	0f b6 13             	movzbl (%ebx),%edx
  80058d:	83 c3 01             	add    $0x1,%ebx
  800590:	8d 42 dd             	lea    -0x23(%edx),%eax
  800593:	3c 55                	cmp    $0x55,%al
  800595:	0f 87 22 03 00 00    	ja     8008bd <vprintfmt+0x388>
  80059b:	0f b6 c0             	movzbl %al,%eax
  80059e:	ff 24 85 a0 26 80 00 	jmp    *0x8026a0(,%eax,4)
  8005a5:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
  8005a9:	eb df                	jmp    80058a <vprintfmt+0x55>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005ab:	0f b6 c2             	movzbl %dl,%eax
  8005ae:	8d 78 d0             	lea    -0x30(%eax),%edi
				ch = *fmt;
  8005b1:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8005b4:	8d 42 d0             	lea    -0x30(%edx),%eax
  8005b7:	83 f8 09             	cmp    $0x9,%eax
  8005ba:	76 08                	jbe    8005c4 <vprintfmt+0x8f>
  8005bc:	eb 39                	jmp    8005f7 <vprintfmt+0xc2>
  8005be:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
  8005c2:	eb c6                	jmp    80058a <vprintfmt+0x55>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005c4:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  8005c7:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  8005ca:	8d 7c 42 d0          	lea    -0x30(%edx,%eax,2),%edi
				ch = *fmt;
  8005ce:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8005d1:	8d 42 d0             	lea    -0x30(%edx),%eax
  8005d4:	83 f8 09             	cmp    $0x9,%eax
  8005d7:	77 1e                	ja     8005f7 <vprintfmt+0xc2>
  8005d9:	eb e9                	jmp    8005c4 <vprintfmt+0x8f>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005db:	8b 55 14             	mov    0x14(%ebp),%edx
  8005de:	8d 42 04             	lea    0x4(%edx),%eax
  8005e1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e4:	8b 3a                	mov    (%edx),%edi
  8005e6:	eb 0f                	jmp    8005f7 <vprintfmt+0xc2>
			goto process_precision;

		case '.':
			if (width < 0)
  8005e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8005ec:	79 9c                	jns    80058a <vprintfmt+0x55>
  8005ee:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8005f5:	eb 93                	jmp    80058a <vprintfmt+0x55>
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8005fb:	90                   	nop    
  8005fc:	8d 74 26 00          	lea    0x0(%esi),%esi
  800600:	79 88                	jns    80058a <vprintfmt+0x55>
  800602:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800605:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80060a:	e9 7b ff ff ff       	jmp    80058a <vprintfmt+0x55>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80060f:	83 c1 01             	add    $0x1,%ecx
  800612:	e9 73 ff ff ff       	jmp    80058a <vprintfmt+0x55>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8d 50 04             	lea    0x4(%eax),%edx
  80061d:	89 55 14             	mov    %edx,0x14(%ebp)
  800620:	8b 55 0c             	mov    0xc(%ebp),%edx
  800623:	89 54 24 04          	mov    %edx,0x4(%esp)
  800627:	8b 00                	mov    (%eax),%eax
  800629:	89 04 24             	mov    %eax,(%esp)
  80062c:	ff 55 08             	call   *0x8(%ebp)
  80062f:	e9 27 ff ff ff       	jmp    80055b <vprintfmt+0x26>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800634:	8b 55 14             	mov    0x14(%ebp),%edx
  800637:	8d 42 04             	lea    0x4(%edx),%eax
  80063a:	89 45 14             	mov    %eax,0x14(%ebp)
  80063d:	8b 02                	mov    (%edx),%eax
  80063f:	89 c2                	mov    %eax,%edx
  800641:	c1 fa 1f             	sar    $0x1f,%edx
  800644:	31 d0                	xor    %edx,%eax
  800646:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800648:	83 f8 0f             	cmp    $0xf,%eax
  80064b:	7f 0b                	jg     800658 <vprintfmt+0x123>
  80064d:	8b 14 85 00 28 80 00 	mov    0x802800(,%eax,4),%edx
  800654:	85 d2                	test   %edx,%edx
  800656:	75 23                	jne    80067b <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800658:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80065c:	c7 44 24 08 67 25 80 	movl   $0x802567,0x8(%esp)
  800663:	00 
  800664:	8b 45 0c             	mov    0xc(%ebp),%eax
  800667:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066b:	8b 55 08             	mov    0x8(%ebp),%edx
  80066e:	89 14 24             	mov    %edx,(%esp)
  800671:	e8 ff 02 00 00       	call   800975 <printfmt>
  800676:	e9 e0 fe ff ff       	jmp    80055b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80067b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80067f:	c7 44 24 08 42 29 80 	movl   $0x802942,0x8(%esp)
  800686:	00 
  800687:	8b 45 0c             	mov    0xc(%ebp),%eax
  80068a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068e:	8b 55 08             	mov    0x8(%ebp),%edx
  800691:	89 14 24             	mov    %edx,(%esp)
  800694:	e8 dc 02 00 00       	call   800975 <printfmt>
  800699:	e9 bd fe ff ff       	jmp    80055b <vprintfmt+0x26>
  80069e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8006a1:	89 f9                	mov    %edi,%ecx
  8006a3:	89 5d ec             	mov    %ebx,-0x14(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a6:	8b 55 14             	mov    0x14(%ebp),%edx
  8006a9:	8d 42 04             	lea    0x4(%edx),%eax
  8006ac:	89 45 14             	mov    %eax,0x14(%ebp)
  8006af:	8b 12                	mov    (%edx),%edx
  8006b1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006b4:	85 d2                	test   %edx,%edx
  8006b6:	75 07                	jne    8006bf <vprintfmt+0x18a>
  8006b8:	c7 45 dc 70 25 80 00 	movl   $0x802570,-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8006bf:	85 f6                	test   %esi,%esi
  8006c1:	7e 41                	jle    800704 <vprintfmt+0x1cf>
  8006c3:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8006c7:	74 3b                	je     800704 <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006d0:	89 04 24             	mov    %eax,(%esp)
  8006d3:	e8 e8 02 00 00       	call   8009c0 <strnlen>
  8006d8:	29 c6                	sub    %eax,%esi
  8006da:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8006dd:	85 f6                	test   %esi,%esi
  8006df:	7e 23                	jle    800704 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006e1:	0f be 55 eb          	movsbl -0x15(%ebp),%edx
  8006e5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8006e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ef:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006f2:	89 14 24             	mov    %edx,(%esp)
  8006f5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f8:	83 ee 01             	sub    $0x1,%esi
  8006fb:	75 eb                	jne    8006e8 <vprintfmt+0x1b3>
  8006fd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800704:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800707:	0f b6 02             	movzbl (%edx),%eax
  80070a:	0f be d0             	movsbl %al,%edx
  80070d:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800710:	84 c0                	test   %al,%al
  800712:	75 42                	jne    800756 <vprintfmt+0x221>
  800714:	eb 49                	jmp    80075f <vprintfmt+0x22a>
				if (altflag && (ch < ' ' || ch > '~'))
  800716:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80071a:	74 1b                	je     800737 <vprintfmt+0x202>
  80071c:	8d 42 e0             	lea    -0x20(%edx),%eax
  80071f:	83 f8 5e             	cmp    $0x5e,%eax
  800722:	76 13                	jbe    800737 <vprintfmt+0x202>
					putch('?', putdat);
  800724:	8b 45 0c             	mov    0xc(%ebp),%eax
  800727:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800732:	ff 55 08             	call   *0x8(%ebp)
  800735:	eb 0d                	jmp    800744 <vprintfmt+0x20f>
				else
					putch(ch, putdat);
  800737:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073e:	89 14 24             	mov    %edx,(%esp)
  800741:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800744:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  800748:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80074c:	83 c6 01             	add    $0x1,%esi
  80074f:	84 c0                	test   %al,%al
  800751:	74 0c                	je     80075f <vprintfmt+0x22a>
  800753:	0f be d0             	movsbl %al,%edx
  800756:	85 ff                	test   %edi,%edi
  800758:	78 bc                	js     800716 <vprintfmt+0x1e1>
  80075a:	83 ef 01             	sub    $0x1,%edi
  80075d:	79 b7                	jns    800716 <vprintfmt+0x1e1>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80075f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800763:	0f 8e f2 fd ff ff    	jle    80055b <vprintfmt+0x26>
				putch(' ', putdat);
  800769:	8b 55 0c             	mov    0xc(%ebp),%edx
  80076c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800770:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800777:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80077a:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  80077e:	75 e9                	jne    800769 <vprintfmt+0x234>
  800780:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800783:	e9 d3 fd ff ff       	jmp    80055b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800788:	83 f9 01             	cmp    $0x1,%ecx
  80078b:	90                   	nop    
  80078c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800790:	7e 10                	jle    8007a2 <vprintfmt+0x26d>
		return va_arg(*ap, long long);
  800792:	8b 55 14             	mov    0x14(%ebp),%edx
  800795:	8d 42 08             	lea    0x8(%edx),%eax
  800798:	89 45 14             	mov    %eax,0x14(%ebp)
  80079b:	8b 32                	mov    (%edx),%esi
  80079d:	8b 7a 04             	mov    0x4(%edx),%edi
  8007a0:	eb 2a                	jmp    8007cc <vprintfmt+0x297>
	else if (lflag)
  8007a2:	85 c9                	test   %ecx,%ecx
  8007a4:	74 14                	je     8007ba <vprintfmt+0x285>
		return va_arg(*ap, long);
  8007a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a9:	8d 50 04             	lea    0x4(%eax),%edx
  8007ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8007af:	8b 00                	mov    (%eax),%eax
  8007b1:	89 c6                	mov    %eax,%esi
  8007b3:	89 c7                	mov    %eax,%edi
  8007b5:	c1 ff 1f             	sar    $0x1f,%edi
  8007b8:	eb 12                	jmp    8007cc <vprintfmt+0x297>
	else
		return va_arg(*ap, int);
  8007ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bd:	8d 50 04             	lea    0x4(%eax),%edx
  8007c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c3:	8b 00                	mov    (%eax),%eax
  8007c5:	89 c6                	mov    %eax,%esi
  8007c7:	89 c7                	mov    %eax,%edi
  8007c9:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007cc:	89 f2                	mov    %esi,%edx
  8007ce:	89 f9                	mov    %edi,%ecx
  8007d0:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
			if ((long long) num < 0) {
  8007d7:	85 ff                	test   %edi,%edi
  8007d9:	0f 89 9b 00 00 00    	jns    80087a <vprintfmt+0x345>
				putch('-', putdat);
  8007df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007ed:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007f0:	89 f2                	mov    %esi,%edx
  8007f2:	89 f9                	mov    %edi,%ecx
  8007f4:	f7 da                	neg    %edx
  8007f6:	83 d1 00             	adc    $0x0,%ecx
  8007f9:	f7 d9                	neg    %ecx
  8007fb:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  800802:	eb 76                	jmp    80087a <vprintfmt+0x345>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800804:	89 ca                	mov    %ecx,%edx
  800806:	8d 45 14             	lea    0x14(%ebp),%eax
  800809:	e8 cd fc ff ff       	call   8004db <getuint>
  80080e:	89 d1                	mov    %edx,%ecx
  800810:	89 c2                	mov    %eax,%edx
  800812:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  800819:	eb 5f                	jmp    80087a <vprintfmt+0x345>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap,lflag);
  80081b:	89 ca                	mov    %ecx,%edx
  80081d:	8d 45 14             	lea    0x14(%ebp),%eax
  800820:	e8 b6 fc ff ff       	call   8004db <getuint>
  800825:	e9 31 fd ff ff       	jmp    80055b <vprintfmt+0x26>
			base=8;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80082a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800831:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800838:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80083b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800842:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800849:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  80084c:	8b 55 14             	mov    0x14(%ebp),%edx
  80084f:	8d 42 04             	lea    0x4(%edx),%eax
  800852:	89 45 14             	mov    %eax,0x14(%ebp)
  800855:	8b 12                	mov    (%edx),%edx
  800857:	b9 00 00 00 00       	mov    $0x0,%ecx
  80085c:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  800863:	eb 15                	jmp    80087a <vprintfmt+0x345>
			base = 16;
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800865:	89 ca                	mov    %ecx,%edx
  800867:	8d 45 14             	lea    0x14(%ebp),%eax
  80086a:	e8 6c fc ff ff       	call   8004db <getuint>
  80086f:	89 d1                	mov    %edx,%ecx
  800871:	89 c2                	mov    %eax,%edx
  800873:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80087a:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  80087e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800882:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800885:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800889:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80088c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800890:	89 14 24             	mov    %edx,(%esp)
  800893:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800897:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089a:	8b 45 08             	mov    0x8(%ebp),%eax
  80089d:	e8 4e fb ff ff       	call   8003f0 <printnum>
  8008a2:	e9 b4 fc ff ff       	jmp    80055b <vprintfmt+0x26>
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ae:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008b5:	ff 55 08             	call   *0x8(%ebp)
  8008b8:	e9 9e fc ff ff       	jmp    80055b <vprintfmt+0x26>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008cb:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ce:	83 eb 01             	sub    $0x1,%ebx
  8008d1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8008d5:	0f 84 80 fc ff ff    	je     80055b <vprintfmt+0x26>
  8008db:	83 eb 01             	sub    $0x1,%ebx
  8008de:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8008e2:	0f 84 73 fc ff ff    	je     80055b <vprintfmt+0x26>
  8008e8:	eb f1                	jmp    8008db <vprintfmt+0x3a6>
				/* do nothing */;
			break;
		}
	}
}
  8008ea:	83 c4 3c             	add    $0x3c,%esp
  8008ed:	5b                   	pop    %ebx
  8008ee:	5e                   	pop    %esi
  8008ef:	5f                   	pop    %edi
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	83 ec 28             	sub    $0x28,%esp
  8008f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8008fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8008fe:	85 d2                	test   %edx,%edx
  800900:	74 04                	je     800906 <vsnprintf+0x14>
  800902:	85 c0                	test   %eax,%eax
  800904:	7f 07                	jg     80090d <vsnprintf+0x1b>
  800906:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80090b:	eb 3b                	jmp    800948 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80090d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800914:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
  800918:	89 45 f8             	mov    %eax,-0x8(%ebp)
  80091b:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80091e:	8b 45 14             	mov    0x14(%ebp),%eax
  800921:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800925:	8b 45 10             	mov    0x10(%ebp),%eax
  800928:	89 44 24 08          	mov    %eax,0x8(%esp)
  80092c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80092f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800933:	c7 04 24 17 05 80 00 	movl   $0x800517,(%esp)
  80093a:	e8 f6 fb ff ff       	call   800535 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80093f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800942:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800945:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800948:	c9                   	leave  
  800949:	c3                   	ret    

0080094a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800950:	8d 45 14             	lea    0x14(%ebp),%eax
  800953:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800956:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80095a:	8b 45 10             	mov    0x10(%ebp),%eax
  80095d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800961:	8b 45 0c             	mov    0xc(%ebp),%eax
  800964:	89 44 24 04          	mov    %eax,0x4(%esp)
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	89 04 24             	mov    %eax,(%esp)
  80096e:	e8 7f ff ff ff       	call   8008f2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800973:	c9                   	leave  
  800974:	c3                   	ret    

00800975 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  80097b:	8d 45 14             	lea    0x14(%ebp),%eax
  80097e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800981:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800985:	8b 45 10             	mov    0x10(%ebp),%eax
  800988:	89 44 24 08          	mov    %eax,0x8(%esp)
  80098c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	89 04 24             	mov    %eax,(%esp)
  800999:	e8 97 fb ff ff       	call   800535 <vprintfmt>
	va_end(ap);
}
  80099e:	c9                   	leave  
  80099f:	c3                   	ret    

008009a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ab:	80 3a 00             	cmpb   $0x0,(%edx)
  8009ae:	74 0e                	je     8009be <strlen+0x1e>
  8009b0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009b5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009b8:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8009bc:	75 f7                	jne    8009b5 <strlen+0x15>
		n++;
	return n;
}
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c9:	85 d2                	test   %edx,%edx
  8009cb:	74 19                	je     8009e6 <strnlen+0x26>
  8009cd:	80 39 00             	cmpb   $0x0,(%ecx)
  8009d0:	74 14                	je     8009e6 <strnlen+0x26>
  8009d2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009d7:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009da:	39 d0                	cmp    %edx,%eax
  8009dc:	74 0d                	je     8009eb <strnlen+0x2b>
  8009de:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  8009e2:	74 07                	je     8009eb <strnlen+0x2b>
  8009e4:	eb f1                	jmp    8009d7 <strnlen+0x17>
  8009e6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009eb:	5d                   	pop    %ebp
  8009ec:	8d 74 26 00          	lea    0x0(%esi),%esi
  8009f0:	c3                   	ret    

008009f1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	53                   	push   %ebx
  8009f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009fb:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009fd:	0f b6 01             	movzbl (%ecx),%eax
  800a00:	88 02                	mov    %al,(%edx)
  800a02:	83 c2 01             	add    $0x1,%edx
  800a05:	83 c1 01             	add    $0x1,%ecx
  800a08:	84 c0                	test   %al,%al
  800a0a:	75 f1                	jne    8009fd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a0c:	89 d8                	mov    %ebx,%eax
  800a0e:	5b                   	pop    %ebx
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	57                   	push   %edi
  800a15:	56                   	push   %esi
  800a16:	53                   	push   %ebx
  800a17:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a20:	85 f6                	test   %esi,%esi
  800a22:	74 1c                	je     800a40 <strncpy+0x2f>
  800a24:	89 fa                	mov    %edi,%edx
  800a26:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  800a2b:	0f b6 01             	movzbl (%ecx),%eax
  800a2e:	88 02                	mov    %al,(%edx)
  800a30:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a33:	80 39 01             	cmpb   $0x1,(%ecx)
  800a36:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a39:	83 c3 01             	add    $0x1,%ebx
  800a3c:	39 f3                	cmp    %esi,%ebx
  800a3e:	75 eb                	jne    800a2b <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a40:	89 f8                	mov    %edi,%eax
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5f                   	pop    %edi
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	56                   	push   %esi
  800a4b:	53                   	push   %ebx
  800a4c:	8b 75 08             	mov    0x8(%ebp),%esi
  800a4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a52:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a55:	89 f0                	mov    %esi,%eax
  800a57:	85 d2                	test   %edx,%edx
  800a59:	74 2c                	je     800a87 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800a5b:	89 d3                	mov    %edx,%ebx
  800a5d:	83 eb 01             	sub    $0x1,%ebx
  800a60:	74 20                	je     800a82 <strlcpy+0x3b>
  800a62:	0f b6 11             	movzbl (%ecx),%edx
  800a65:	84 d2                	test   %dl,%dl
  800a67:	74 19                	je     800a82 <strlcpy+0x3b>
  800a69:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800a6b:	88 10                	mov    %dl,(%eax)
  800a6d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a70:	83 eb 01             	sub    $0x1,%ebx
  800a73:	74 0f                	je     800a84 <strlcpy+0x3d>
  800a75:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  800a79:	83 c1 01             	add    $0x1,%ecx
  800a7c:	84 d2                	test   %dl,%dl
  800a7e:	74 04                	je     800a84 <strlcpy+0x3d>
  800a80:	eb e9                	jmp    800a6b <strlcpy+0x24>
  800a82:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a84:	c6 00 00             	movb   $0x0,(%eax)
  800a87:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800a89:	5b                   	pop    %ebx
  800a8a:	5e                   	pop    %esi
  800a8b:	5d                   	pop    %ebp
  800a8c:	c3                   	ret    

00800a8d <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
  800a92:	8b 75 08             	mov    0x8(%ebp),%esi
  800a95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a98:	8b 55 10             	mov    0x10(%ebp),%edx
    int c;
    char *q = buf;

    if (buf_size <= 0)
  800a9b:	85 c0                	test   %eax,%eax
  800a9d:	7e 2e                	jle    800acd <pstrcpy+0x40>
        return;

    for(;;) {
        c = *str++;
  800a9f:	0f b6 0a             	movzbl (%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  800aa2:	84 c9                	test   %cl,%cl
  800aa4:	74 22                	je     800ac8 <pstrcpy+0x3b>
  800aa6:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  800aaa:	89 f0                	mov    %esi,%eax
  800aac:	39 de                	cmp    %ebx,%esi
  800aae:	72 09                	jb     800ab9 <pstrcpy+0x2c>
  800ab0:	eb 16                	jmp    800ac8 <pstrcpy+0x3b>
  800ab2:	83 c2 01             	add    $0x1,%edx
  800ab5:	39 d8                	cmp    %ebx,%eax
  800ab7:	73 11                	jae    800aca <pstrcpy+0x3d>
            break;
        *q++ = c;
  800ab9:	88 08                	mov    %cl,(%eax)
  800abb:	83 c0 01             	add    $0x1,%eax

    if (buf_size <= 0)
        return;

    for(;;) {
        c = *str++;
  800abe:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  800ac2:	84 c9                	test   %cl,%cl
  800ac4:	75 ec                	jne    800ab2 <pstrcpy+0x25>
  800ac6:	eb 02                	jmp    800aca <pstrcpy+0x3d>
  800ac8:	89 f0                	mov    %esi,%eax
            break;
        *q++ = c;
    }
    *q = '\0';
  800aca:	c6 00 00             	movb   $0x0,(%eax)
}
  800acd:	5b                   	pop    %ebx
  800ace:	5e                   	pop    %esi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  800ada:	0f b6 02             	movzbl (%edx),%eax
  800add:	84 c0                	test   %al,%al
  800adf:	74 16                	je     800af7 <strcmp+0x26>
  800ae1:	3a 01                	cmp    (%ecx),%al
  800ae3:	75 12                	jne    800af7 <strcmp+0x26>
		p++, q++;
  800ae5:	83 c1 01             	add    $0x1,%ecx
    *q = '\0';
}
int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ae8:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  800aec:	84 c0                	test   %al,%al
  800aee:	74 07                	je     800af7 <strcmp+0x26>
  800af0:	83 c2 01             	add    $0x1,%edx
  800af3:	3a 01                	cmp    (%ecx),%al
  800af5:	74 ee                	je     800ae5 <strcmp+0x14>
  800af7:	0f b6 c0             	movzbl %al,%eax
  800afa:	0f b6 11             	movzbl (%ecx),%edx
  800afd:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	53                   	push   %ebx
  800b05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b0b:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b0e:	85 d2                	test   %edx,%edx
  800b10:	74 2d                	je     800b3f <strncmp+0x3e>
  800b12:	0f b6 01             	movzbl (%ecx),%eax
  800b15:	84 c0                	test   %al,%al
  800b17:	74 1a                	je     800b33 <strncmp+0x32>
  800b19:	3a 03                	cmp    (%ebx),%al
  800b1b:	75 16                	jne    800b33 <strncmp+0x32>
  800b1d:	83 ea 01             	sub    $0x1,%edx
  800b20:	74 1d                	je     800b3f <strncmp+0x3e>
		n--, p++, q++;
  800b22:	83 c1 01             	add    $0x1,%ecx
  800b25:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b28:	0f b6 01             	movzbl (%ecx),%eax
  800b2b:	84 c0                	test   %al,%al
  800b2d:	74 04                	je     800b33 <strncmp+0x32>
  800b2f:	3a 03                	cmp    (%ebx),%al
  800b31:	74 ea                	je     800b1d <strncmp+0x1c>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b33:	0f b6 11             	movzbl (%ecx),%edx
  800b36:	0f b6 03             	movzbl (%ebx),%eax
  800b39:	29 c2                	sub    %eax,%edx
  800b3b:	89 d0                	mov    %edx,%eax
  800b3d:	eb 05                	jmp    800b44 <strncmp+0x43>
  800b3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b44:	5b                   	pop    %ebx
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b51:	0f b6 10             	movzbl (%eax),%edx
  800b54:	84 d2                	test   %dl,%dl
  800b56:	74 14                	je     800b6c <strchr+0x25>
		if (*s == c)
  800b58:	38 ca                	cmp    %cl,%dl
  800b5a:	75 06                	jne    800b62 <strchr+0x1b>
  800b5c:	eb 13                	jmp    800b71 <strchr+0x2a>
  800b5e:	38 ca                	cmp    %cl,%dl
  800b60:	74 0f                	je     800b71 <strchr+0x2a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b62:	83 c0 01             	add    $0x1,%eax
  800b65:	0f b6 10             	movzbl (%eax),%edx
  800b68:	84 d2                	test   %dl,%dl
  800b6a:	75 f2                	jne    800b5e <strchr+0x17>
  800b6c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	8b 45 08             	mov    0x8(%ebp),%eax
  800b79:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b7d:	0f b6 10             	movzbl (%eax),%edx
  800b80:	84 d2                	test   %dl,%dl
  800b82:	74 18                	je     800b9c <strfind+0x29>
		if (*s == c)
  800b84:	38 ca                	cmp    %cl,%dl
  800b86:	75 0a                	jne    800b92 <strfind+0x1f>
  800b88:	eb 12                	jmp    800b9c <strfind+0x29>
  800b8a:	38 ca                	cmp    %cl,%dl
  800b8c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800b90:	74 0a                	je     800b9c <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b92:	83 c0 01             	add    $0x1,%eax
  800b95:	0f b6 10             	movzbl (%eax),%edx
  800b98:	84 d2                	test   %dl,%dl
  800b9a:	75 ee                	jne    800b8a <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	83 ec 08             	sub    $0x8,%esp
  800ba4:	89 1c 24             	mov    %ebx,(%esp)
  800ba7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bab:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800bb1:	85 db                	test   %ebx,%ebx
  800bb3:	74 36                	je     800beb <memset+0x4d>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bb5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bbb:	75 26                	jne    800be3 <memset+0x45>
  800bbd:	f6 c3 03             	test   $0x3,%bl
  800bc0:	75 21                	jne    800be3 <memset+0x45>
		c &= 0xFF;
  800bc2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bc6:	89 d0                	mov    %edx,%eax
  800bc8:	c1 e0 18             	shl    $0x18,%eax
  800bcb:	89 d1                	mov    %edx,%ecx
  800bcd:	c1 e1 10             	shl    $0x10,%ecx
  800bd0:	09 c8                	or     %ecx,%eax
  800bd2:	09 d0                	or     %edx,%eax
  800bd4:	c1 e2 08             	shl    $0x8,%edx
  800bd7:	09 d0                	or     %edx,%eax
  800bd9:	89 d9                	mov    %ebx,%ecx
  800bdb:	c1 e9 02             	shr    $0x2,%ecx
  800bde:	fc                   	cld    
  800bdf:	f3 ab                	rep stos %eax,%es:(%edi)
  800be1:	eb 08                	jmp    800beb <memset+0x4d>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800be3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be6:	89 d9                	mov    %ebx,%ecx
  800be8:	fc                   	cld    
  800be9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800beb:	89 f8                	mov    %edi,%eax
  800bed:	8b 1c 24             	mov    (%esp),%ebx
  800bf0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800bf4:	89 ec                	mov    %ebp,%esp
  800bf6:	5d                   	pop    %ebp
  800bf7:	c3                   	ret    

00800bf8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	83 ec 08             	sub    $0x8,%esp
  800bfe:	89 34 24             	mov    %esi,(%esp)
  800c01:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c05:	8b 45 08             	mov    0x8(%ebp),%eax
  800c08:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800c0b:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800c0e:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800c10:	39 c6                	cmp    %eax,%esi
  800c12:	73 38                	jae    800c4c <memmove+0x54>
  800c14:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c17:	39 d0                	cmp    %edx,%eax
  800c19:	73 31                	jae    800c4c <memmove+0x54>
		s += n;
		d += n;
  800c1b:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c1e:	f6 c2 03             	test   $0x3,%dl
  800c21:	75 1d                	jne    800c40 <memmove+0x48>
  800c23:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c29:	75 15                	jne    800c40 <memmove+0x48>
  800c2b:	f6 c1 03             	test   $0x3,%cl
  800c2e:	66 90                	xchg   %ax,%ax
  800c30:	75 0e                	jne    800c40 <memmove+0x48>
			asm volatile("std; rep movsl\n"
  800c32:	8d 7e fc             	lea    -0x4(%esi),%edi
  800c35:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c38:	c1 e9 02             	shr    $0x2,%ecx
  800c3b:	fd                   	std    
  800c3c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c3e:	eb 09                	jmp    800c49 <memmove+0x51>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c40:	8d 7e ff             	lea    -0x1(%esi),%edi
  800c43:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c46:	fd                   	std    
  800c47:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c49:	fc                   	cld    
  800c4a:	eb 21                	jmp    800c6d <memmove+0x75>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c4c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c52:	75 16                	jne    800c6a <memmove+0x72>
  800c54:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c5a:	75 0e                	jne    800c6a <memmove+0x72>
  800c5c:	f6 c1 03             	test   $0x3,%cl
  800c5f:	90                   	nop    
  800c60:	75 08                	jne    800c6a <memmove+0x72>
			asm volatile("cld; rep movsl\n"
  800c62:	c1 e9 02             	shr    $0x2,%ecx
  800c65:	fc                   	cld    
  800c66:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c68:	eb 03                	jmp    800c6d <memmove+0x75>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c6a:	fc                   	cld    
  800c6b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c6d:	8b 34 24             	mov    (%esp),%esi
  800c70:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c74:	89 ec                	mov    %ebp,%esp
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c7e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c81:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c85:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c88:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8f:	89 04 24             	mov    %eax,(%esp)
  800c92:	e8 61 ff ff ff       	call   800bf8 <memmove>
}
  800c97:	c9                   	leave  
  800c98:	c3                   	ret    

00800c99 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
  800c9f:	83 ec 04             	sub    $0x4,%esp
  800ca2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ca8:	8b 55 10             	mov    0x10(%ebp),%edx
  800cab:	83 ea 01             	sub    $0x1,%edx
  800cae:	83 fa ff             	cmp    $0xffffffff,%edx
  800cb1:	74 47                	je     800cfa <memcmp+0x61>
		if (*s1 != *s2)
  800cb3:	0f b6 30             	movzbl (%eax),%esi
  800cb6:	0f b6 39             	movzbl (%ecx),%edi
			return (int) *s1 - (int) *s2;
  800cb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800cbc:	89 f0                	mov    %esi,%eax
  800cbe:	89 fb                	mov    %edi,%ebx
  800cc0:	38 d8                	cmp    %bl,%al
  800cc2:	74 2e                	je     800cf2 <memcmp+0x59>
  800cc4:	eb 1c                	jmp    800ce2 <memcmp+0x49>
  800cc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cc9:	0f b6 70 01          	movzbl 0x1(%eax),%esi
  800ccd:	0f b6 79 01          	movzbl 0x1(%ecx),%edi
  800cd1:	83 c0 01             	add    $0x1,%eax
  800cd4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800cd7:	83 c1 01             	add    $0x1,%ecx
  800cda:	89 f3                	mov    %esi,%ebx
  800cdc:	89 f8                	mov    %edi,%eax
  800cde:	38 c3                	cmp    %al,%bl
  800ce0:	74 10                	je     800cf2 <memcmp+0x59>
			return (int) *s1 - (int) *s2;
  800ce2:	89 f1                	mov    %esi,%ecx
  800ce4:	0f b6 d1             	movzbl %cl,%edx
  800ce7:	89 fb                	mov    %edi,%ebx
  800ce9:	0f b6 c3             	movzbl %bl,%eax
  800cec:	29 c2                	sub    %eax,%edx
  800cee:	89 d0                	mov    %edx,%eax
  800cf0:	eb 0d                	jmp    800cff <memcmp+0x66>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cf2:	83 ea 01             	sub    $0x1,%edx
  800cf5:	83 fa ff             	cmp    $0xffffffff,%edx
  800cf8:	75 cc                	jne    800cc6 <memcmp+0x2d>
  800cfa:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800cff:	83 c4 04             	add    $0x4,%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d0d:	89 c1                	mov    %eax,%ecx
  800d0f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
  800d12:	39 c8                	cmp    %ecx,%eax
  800d14:	73 15                	jae    800d2b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d16:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
  800d1a:	38 10                	cmp    %dl,(%eax)
  800d1c:	75 06                	jne    800d24 <memfind+0x1d>
  800d1e:	eb 0b                	jmp    800d2b <memfind+0x24>
  800d20:	38 10                	cmp    %dl,(%eax)
  800d22:	74 07                	je     800d2b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d24:	83 c0 01             	add    $0x1,%eax
  800d27:	39 c8                	cmp    %ecx,%eax
  800d29:	75 f5                	jne    800d20 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d2b:	5d                   	pop    %ebp
  800d2c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800d30:	c3                   	ret    

00800d31 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	57                   	push   %edi
  800d35:	56                   	push   %esi
  800d36:	53                   	push   %ebx
  800d37:	83 ec 04             	sub    $0x4,%esp
  800d3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d3d:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d40:	0f b6 01             	movzbl (%ecx),%eax
  800d43:	3c 20                	cmp    $0x20,%al
  800d45:	74 04                	je     800d4b <strtol+0x1a>
  800d47:	3c 09                	cmp    $0x9,%al
  800d49:	75 0e                	jne    800d59 <strtol+0x28>
		s++;
  800d4b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d4e:	0f b6 01             	movzbl (%ecx),%eax
  800d51:	3c 20                	cmp    $0x20,%al
  800d53:	74 f6                	je     800d4b <strtol+0x1a>
  800d55:	3c 09                	cmp    $0x9,%al
  800d57:	74 f2                	je     800d4b <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d59:	3c 2b                	cmp    $0x2b,%al
  800d5b:	75 0c                	jne    800d69 <strtol+0x38>
		s++;
  800d5d:	83 c1 01             	add    $0x1,%ecx
  800d60:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d67:	eb 15                	jmp    800d7e <strtol+0x4d>
	else if (*s == '-')
  800d69:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d70:	3c 2d                	cmp    $0x2d,%al
  800d72:	75 0a                	jne    800d7e <strtol+0x4d>
		s++, neg = 1;
  800d74:	83 c1 01             	add    $0x1,%ecx
  800d77:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d7e:	85 f6                	test   %esi,%esi
  800d80:	0f 94 c0             	sete   %al
  800d83:	74 05                	je     800d8a <strtol+0x59>
  800d85:	83 fe 10             	cmp    $0x10,%esi
  800d88:	75 18                	jne    800da2 <strtol+0x71>
  800d8a:	80 39 30             	cmpb   $0x30,(%ecx)
  800d8d:	75 13                	jne    800da2 <strtol+0x71>
  800d8f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d93:	75 0d                	jne    800da2 <strtol+0x71>
		s += 2, base = 16;
  800d95:	83 c1 02             	add    $0x2,%ecx
  800d98:	be 10 00 00 00       	mov    $0x10,%esi
  800d9d:	8d 76 00             	lea    0x0(%esi),%esi
  800da0:	eb 1b                	jmp    800dbd <strtol+0x8c>
	else if (base == 0 && s[0] == '0')
  800da2:	85 f6                	test   %esi,%esi
  800da4:	75 0e                	jne    800db4 <strtol+0x83>
  800da6:	80 39 30             	cmpb   $0x30,(%ecx)
  800da9:	75 09                	jne    800db4 <strtol+0x83>
		s++, base = 8;
  800dab:	83 c1 01             	add    $0x1,%ecx
  800dae:	66 be 08 00          	mov    $0x8,%si
  800db2:	eb 09                	jmp    800dbd <strtol+0x8c>
	else if (base == 0)
  800db4:	84 c0                	test   %al,%al
  800db6:	74 05                	je     800dbd <strtol+0x8c>
  800db8:	be 0a 00 00 00       	mov    $0xa,%esi
  800dbd:	bf 00 00 00 00       	mov    $0x0,%edi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dc2:	0f b6 11             	movzbl (%ecx),%edx
  800dc5:	89 d3                	mov    %edx,%ebx
  800dc7:	8d 42 d0             	lea    -0x30(%edx),%eax
  800dca:	3c 09                	cmp    $0x9,%al
  800dcc:	77 08                	ja     800dd6 <strtol+0xa5>
			dig = *s - '0';
  800dce:	0f be c2             	movsbl %dl,%eax
  800dd1:	8d 50 d0             	lea    -0x30(%eax),%edx
  800dd4:	eb 1c                	jmp    800df2 <strtol+0xc1>
		else if (*s >= 'a' && *s <= 'z')
  800dd6:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800dd9:	3c 19                	cmp    $0x19,%al
  800ddb:	77 08                	ja     800de5 <strtol+0xb4>
			dig = *s - 'a' + 10;
  800ddd:	0f be c2             	movsbl %dl,%eax
  800de0:	8d 50 a9             	lea    -0x57(%eax),%edx
  800de3:	eb 0d                	jmp    800df2 <strtol+0xc1>
		else if (*s >= 'A' && *s <= 'Z')
  800de5:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800de8:	3c 19                	cmp    $0x19,%al
  800dea:	77 17                	ja     800e03 <strtol+0xd2>
			dig = *s - 'A' + 10;
  800dec:	0f be c2             	movsbl %dl,%eax
  800def:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800df2:	39 f2                	cmp    %esi,%edx
  800df4:	7d 0d                	jge    800e03 <strtol+0xd2>
			break;
		s++, val = (val * base) + dig;
  800df6:	83 c1 01             	add    $0x1,%ecx
  800df9:	89 f8                	mov    %edi,%eax
  800dfb:	0f af c6             	imul   %esi,%eax
  800dfe:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800e01:	eb bf                	jmp    800dc2 <strtol+0x91>
		// we don't properly detect overflow!
	}
  800e03:	89 f8                	mov    %edi,%eax

	if (endptr)
  800e05:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e09:	74 05                	je     800e10 <strtol+0xdf>
		*endptr = (char *) s;
  800e0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e0e:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800e10:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800e14:	74 04                	je     800e1a <strtol+0xe9>
  800e16:	89 c7                	mov    %eax,%edi
  800e18:	f7 df                	neg    %edi
}
  800e1a:	89 f8                	mov    %edi,%eax
  800e1c:	83 c4 04             	add    $0x4,%esp
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	83 ec 0c             	sub    $0xc,%esp
  800e2a:	89 1c 24             	mov    %ebx,(%esp)
  800e2d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e31:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e35:	b8 01 00 00 00       	mov    $0x1,%eax
  800e3a:	bf 00 00 00 00       	mov    $0x0,%edi
  800e3f:	89 fa                	mov    %edi,%edx
  800e41:	89 f9                	mov    %edi,%ecx
  800e43:	89 fb                	mov    %edi,%ebx
  800e45:	89 fe                	mov    %edi,%esi
  800e47:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e49:	8b 1c 24             	mov    (%esp),%ebx
  800e4c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e50:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e54:	89 ec                	mov    %ebp,%esp
  800e56:	5d                   	pop    %ebp
  800e57:	c3                   	ret    

00800e58 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	83 ec 0c             	sub    $0xc,%esp
  800e5e:	89 1c 24             	mov    %ebx,(%esp)
  800e61:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e65:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e69:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6f:	bf 00 00 00 00       	mov    $0x0,%edi
  800e74:	89 f8                	mov    %edi,%eax
  800e76:	89 fb                	mov    %edi,%ebx
  800e78:	89 fe                	mov    %edi,%esi
  800e7a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e7c:	8b 1c 24             	mov    (%esp),%ebx
  800e7f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e83:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e87:	89 ec                	mov    %ebp,%esp
  800e89:	5d                   	pop    %ebp
  800e8a:	c3                   	ret    

00800e8b <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	83 ec 0c             	sub    $0xc,%esp
  800e91:	89 1c 24             	mov    %ebx,(%esp)
  800e94:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e98:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ea1:	bf 00 00 00 00       	mov    $0x0,%edi
  800ea6:	89 fa                	mov    %edi,%edx
  800ea8:	89 f9                	mov    %edi,%ecx
  800eaa:	89 fb                	mov    %edi,%ebx
  800eac:	89 fe                	mov    %edi,%esi
  800eae:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800eb0:	8b 1c 24             	mov    (%esp),%ebx
  800eb3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800eb7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ebb:	89 ec                	mov    %ebp,%esp
  800ebd:	5d                   	pop    %ebp
  800ebe:	c3                   	ret    

00800ebf <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800ebf:	55                   	push   %ebp
  800ec0:	89 e5                	mov    %esp,%ebp
  800ec2:	83 ec 28             	sub    $0x28,%esp
  800ec5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ec8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ecb:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ece:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ed6:	bf 00 00 00 00       	mov    $0x0,%edi
  800edb:	89 f9                	mov    %edi,%ecx
  800edd:	89 fb                	mov    %edi,%ebx
  800edf:	89 fe                	mov    %edi,%esi
  800ee1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	7e 28                	jle    800f0f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eeb:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ef2:	00 
  800ef3:	c7 44 24 08 5f 28 80 	movl   $0x80285f,0x8(%esp)
  800efa:	00 
  800efb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f02:	00 
  800f03:	c7 04 24 7c 28 80 00 	movl   $0x80287c,(%esp)
  800f0a:	e8 ad f3 ff ff       	call   8002bc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f0f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f12:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f15:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f18:	89 ec                	mov    %ebp,%esp
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	83 ec 0c             	sub    $0xc,%esp
  800f22:	89 1c 24             	mov    %ebx,(%esp)
  800f25:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f29:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f33:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f36:	8b 7d 14             	mov    0x14(%ebp),%edi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f39:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f3e:	be 00 00 00 00       	mov    $0x0,%esi
  800f43:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f45:	8b 1c 24             	mov    (%esp),%ebx
  800f48:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f4c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f50:	89 ec                	mov    %ebp,%esp
  800f52:	5d                   	pop    %ebp
  800f53:	c3                   	ret    

00800f54 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	83 ec 28             	sub    $0x28,%esp
  800f5a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f5d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f60:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f63:	8b 55 08             	mov    0x8(%ebp),%edx
  800f66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f69:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f6e:	bf 00 00 00 00       	mov    $0x0,%edi
  800f73:	89 fb                	mov    %edi,%ebx
  800f75:	89 fe                	mov    %edi,%esi
  800f77:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	7e 28                	jle    800fa5 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f81:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f88:	00 
  800f89:	c7 44 24 08 5f 28 80 	movl   $0x80285f,0x8(%esp)
  800f90:	00 
  800f91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f98:	00 
  800f99:	c7 04 24 7c 28 80 00 	movl   $0x80287c,(%esp)
  800fa0:	e8 17 f3 ff ff       	call   8002bc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fa5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fa8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fab:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fae:	89 ec                	mov    %ebp,%esp
  800fb0:	5d                   	pop    %ebp
  800fb1:	c3                   	ret    

00800fb2 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	83 ec 28             	sub    $0x28,%esp
  800fb8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fbb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fbe:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc7:	b8 09 00 00 00       	mov    $0x9,%eax
  800fcc:	bf 00 00 00 00       	mov    $0x0,%edi
  800fd1:	89 fb                	mov    %edi,%ebx
  800fd3:	89 fe                	mov    %edi,%esi
  800fd5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800fd7:	85 c0                	test   %eax,%eax
  800fd9:	7e 28                	jle    801003 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fdb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fdf:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fe6:	00 
  800fe7:	c7 44 24 08 5f 28 80 	movl   $0x80285f,0x8(%esp)
  800fee:	00 
  800fef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ff6:	00 
  800ff7:	c7 04 24 7c 28 80 00 	movl   $0x80287c,(%esp)
  800ffe:	e8 b9 f2 ff ff       	call   8002bc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801003:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801006:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801009:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80100c:	89 ec                	mov    %ebp,%esp
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    

00801010 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	83 ec 28             	sub    $0x28,%esp
  801016:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801019:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80101c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80101f:	8b 55 08             	mov    0x8(%ebp),%edx
  801022:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801025:	b8 08 00 00 00       	mov    $0x8,%eax
  80102a:	bf 00 00 00 00       	mov    $0x0,%edi
  80102f:	89 fb                	mov    %edi,%ebx
  801031:	89 fe                	mov    %edi,%esi
  801033:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801035:	85 c0                	test   %eax,%eax
  801037:	7e 28                	jle    801061 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801039:	89 44 24 10          	mov    %eax,0x10(%esp)
  80103d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801044:	00 
  801045:	c7 44 24 08 5f 28 80 	movl   $0x80285f,0x8(%esp)
  80104c:	00 
  80104d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801054:	00 
  801055:	c7 04 24 7c 28 80 00 	movl   $0x80287c,(%esp)
  80105c:	e8 5b f2 ff ff       	call   8002bc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801061:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801064:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801067:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80106a:	89 ec                	mov    %ebp,%esp
  80106c:	5d                   	pop    %ebp
  80106d:	c3                   	ret    

0080106e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	83 ec 28             	sub    $0x28,%esp
  801074:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801077:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80107a:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80107d:	8b 55 08             	mov    0x8(%ebp),%edx
  801080:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801083:	b8 06 00 00 00       	mov    $0x6,%eax
  801088:	bf 00 00 00 00       	mov    $0x0,%edi
  80108d:	89 fb                	mov    %edi,%ebx
  80108f:	89 fe                	mov    %edi,%esi
  801091:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801093:	85 c0                	test   %eax,%eax
  801095:	7e 28                	jle    8010bf <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801097:	89 44 24 10          	mov    %eax,0x10(%esp)
  80109b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8010a2:	00 
  8010a3:	c7 44 24 08 5f 28 80 	movl   $0x80285f,0x8(%esp)
  8010aa:	00 
  8010ab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010b2:	00 
  8010b3:	c7 04 24 7c 28 80 00 	movl   $0x80287c,(%esp)
  8010ba:	e8 fd f1 ff ff       	call   8002bc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8010bf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010c2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010c5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010c8:	89 ec                	mov    %ebp,%esp
  8010ca:	5d                   	pop    %ebp
  8010cb:	c3                   	ret    

008010cc <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	83 ec 28             	sub    $0x28,%esp
  8010d2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010d5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010d8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8010db:	8b 55 08             	mov    0x8(%ebp),%edx
  8010de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010e4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010e7:	8b 75 18             	mov    0x18(%ebp),%esi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8010ef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	7e 28                	jle    80111d <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010f9:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801100:	00 
  801101:	c7 44 24 08 5f 28 80 	movl   $0x80285f,0x8(%esp)
  801108:	00 
  801109:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801110:	00 
  801111:	c7 04 24 7c 28 80 00 	movl   $0x80287c,(%esp)
  801118:	e8 9f f1 ff ff       	call   8002bc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80111d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801120:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801123:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801126:	89 ec                	mov    %ebp,%esp
  801128:	5d                   	pop    %ebp
  801129:	c3                   	ret    

0080112a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	83 ec 28             	sub    $0x28,%esp
  801130:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801133:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801136:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801139:	8b 55 08             	mov    0x8(%ebp),%edx
  80113c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801142:	b8 04 00 00 00       	mov    $0x4,%eax
  801147:	bf 00 00 00 00       	mov    $0x0,%edi
  80114c:	89 fe                	mov    %edi,%esi
  80114e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801150:	85 c0                	test   %eax,%eax
  801152:	7e 28                	jle    80117c <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  801154:	89 44 24 10          	mov    %eax,0x10(%esp)
  801158:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80115f:	00 
  801160:	c7 44 24 08 5f 28 80 	movl   $0x80285f,0x8(%esp)
  801167:	00 
  801168:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80116f:	00 
  801170:	c7 04 24 7c 28 80 00 	movl   $0x80287c,(%esp)
  801177:	e8 40 f1 ff ff       	call   8002bc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80117c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80117f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801182:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801185:	89 ec                	mov    %ebp,%esp
  801187:	5d                   	pop    %ebp
  801188:	c3                   	ret    

00801189 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  801189:	55                   	push   %ebp
  80118a:	89 e5                	mov    %esp,%ebp
  80118c:	83 ec 0c             	sub    $0xc,%esp
  80118f:	89 1c 24             	mov    %ebx,(%esp)
  801192:	89 74 24 04          	mov    %esi,0x4(%esp)
  801196:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80119a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80119f:	bf 00 00 00 00       	mov    $0x0,%edi
  8011a4:	89 fa                	mov    %edi,%edx
  8011a6:	89 f9                	mov    %edi,%ecx
  8011a8:	89 fb                	mov    %edi,%ebx
  8011aa:	89 fe                	mov    %edi,%esi
  8011ac:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8011ae:	8b 1c 24             	mov    (%esp),%ebx
  8011b1:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011b5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011b9:	89 ec                	mov    %ebp,%esp
  8011bb:	5d                   	pop    %ebp
  8011bc:	c3                   	ret    

008011bd <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
  8011c0:	83 ec 0c             	sub    $0xc,%esp
  8011c3:	89 1c 24             	mov    %ebx,(%esp)
  8011c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011ca:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ce:	b8 02 00 00 00       	mov    $0x2,%eax
  8011d3:	bf 00 00 00 00       	mov    $0x0,%edi
  8011d8:	89 fa                	mov    %edi,%edx
  8011da:	89 f9                	mov    %edi,%ecx
  8011dc:	89 fb                	mov    %edi,%ebx
  8011de:	89 fe                	mov    %edi,%esi
  8011e0:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8011e2:	8b 1c 24             	mov    (%esp),%ebx
  8011e5:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011e9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011ed:	89 ec                	mov    %ebp,%esp
  8011ef:	5d                   	pop    %ebp
  8011f0:	c3                   	ret    

008011f1 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
  8011f4:	83 ec 28             	sub    $0x28,%esp
  8011f7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011fa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011fd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801200:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801203:	b8 03 00 00 00       	mov    $0x3,%eax
  801208:	bf 00 00 00 00       	mov    $0x0,%edi
  80120d:	89 f9                	mov    %edi,%ecx
  80120f:	89 fb                	mov    %edi,%ebx
  801211:	89 fe                	mov    %edi,%esi
  801213:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801215:	85 c0                	test   %eax,%eax
  801217:	7e 28                	jle    801241 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801219:	89 44 24 10          	mov    %eax,0x10(%esp)
  80121d:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801224:	00 
  801225:	c7 44 24 08 5f 28 80 	movl   $0x80285f,0x8(%esp)
  80122c:	00 
  80122d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801234:	00 
  801235:	c7 04 24 7c 28 80 00 	movl   $0x80287c,(%esp)
  80123c:	e8 7b f0 ff ff       	call   8002bc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801241:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801244:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801247:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80124a:	89 ec                	mov    %ebp,%esp
  80124c:	5d                   	pop    %ebp
  80124d:	c3                   	ret    
	...

00801250 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	8b 45 08             	mov    0x8(%ebp),%eax
  801256:	05 00 00 00 30       	add    $0x30000000,%eax
  80125b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80125e:	5d                   	pop    %ebp
  80125f:	c3                   	ret    

00801260 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801266:	8b 45 08             	mov    0x8(%ebp),%eax
  801269:	89 04 24             	mov    %eax,(%esp)
  80126c:	e8 df ff ff ff       	call   801250 <fd2num>
  801271:	c1 e0 0c             	shl    $0xc,%eax
  801274:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801279:	c9                   	leave  
  80127a:	c3                   	ret    

0080127b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	53                   	push   %ebx
  80127f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801282:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801287:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801289:	89 d0                	mov    %edx,%eax
  80128b:	c1 e8 16             	shr    $0x16,%eax
  80128e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801295:	a8 01                	test   $0x1,%al
  801297:	74 10                	je     8012a9 <fd_alloc+0x2e>
  801299:	89 d0                	mov    %edx,%eax
  80129b:	c1 e8 0c             	shr    $0xc,%eax
  80129e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012a5:	a8 01                	test   $0x1,%al
  8012a7:	75 09                	jne    8012b2 <fd_alloc+0x37>
			*fd_store = fd;
  8012a9:	89 0b                	mov    %ecx,(%ebx)
  8012ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b0:	eb 19                	jmp    8012cb <fd_alloc+0x50>
			return 0;
  8012b2:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012b8:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  8012be:	75 c7                	jne    801287 <fd_alloc+0xc>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8012c6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8012cb:	5b                   	pop    %ebx
  8012cc:	5d                   	pop    %ebp
  8012cd:	c3                   	ret    

008012ce <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012d1:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  8012d5:	77 38                	ja     80130f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012da:	c1 e0 0c             	shl    $0xc,%eax
  8012dd:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  8012e3:	89 d0                	mov    %edx,%eax
  8012e5:	c1 e8 16             	shr    $0x16,%eax
  8012e8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012ef:	a8 01                	test   $0x1,%al
  8012f1:	74 1c                	je     80130f <fd_lookup+0x41>
  8012f3:	89 d0                	mov    %edx,%eax
  8012f5:	c1 e8 0c             	shr    $0xc,%eax
  8012f8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012ff:	a8 01                	test   $0x1,%al
  801301:	74 0c                	je     80130f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801303:	8b 45 0c             	mov    0xc(%ebp),%eax
  801306:	89 10                	mov    %edx,(%eax)
  801308:	b8 00 00 00 00       	mov    $0x0,%eax
  80130d:	eb 05                	jmp    801314 <fd_lookup+0x46>
	return 0;
  80130f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801314:	5d                   	pop    %ebp
  801315:	c3                   	ret    

00801316 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80131c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80131f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801323:	8b 45 08             	mov    0x8(%ebp),%eax
  801326:	89 04 24             	mov    %eax,(%esp)
  801329:	e8 a0 ff ff ff       	call   8012ce <fd_lookup>
  80132e:	85 c0                	test   %eax,%eax
  801330:	78 0e                	js     801340 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801332:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801335:	8b 55 0c             	mov    0xc(%ebp),%edx
  801338:	89 50 04             	mov    %edx,0x4(%eax)
  80133b:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801340:	c9                   	leave  
  801341:	c3                   	ret    

00801342 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801342:	55                   	push   %ebp
  801343:	89 e5                	mov    %esp,%ebp
  801345:	53                   	push   %ebx
  801346:	83 ec 14             	sub    $0x14,%esp
  801349:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80134c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80134f:	ba 04 60 80 00       	mov    $0x806004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801354:	b8 00 00 00 00       	mov    $0x0,%eax
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801359:	39 0d 04 60 80 00    	cmp    %ecx,0x806004
  80135f:	75 11                	jne    801372 <dev_lookup+0x30>
  801361:	eb 04                	jmp    801367 <dev_lookup+0x25>
  801363:	39 0a                	cmp    %ecx,(%edx)
  801365:	75 0b                	jne    801372 <dev_lookup+0x30>
			*dev = devtab[i];
  801367:	89 13                	mov    %edx,(%ebx)
  801369:	b8 00 00 00 00       	mov    $0x0,%eax
  80136e:	66 90                	xchg   %ax,%ax
  801370:	eb 35                	jmp    8013a7 <dev_lookup+0x65>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801372:	83 c0 01             	add    $0x1,%eax
  801375:	8b 14 85 0c 29 80 00 	mov    0x80290c(,%eax,4),%edx
  80137c:	85 d2                	test   %edx,%edx
  80137e:	75 e3                	jne    801363 <dev_lookup+0x21>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  801380:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801385:	8b 40 4c             	mov    0x4c(%eax),%eax
  801388:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80138c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801390:	c7 04 24 8c 28 80 00 	movl   $0x80288c,(%esp)
  801397:	e8 ed ef ff ff       	call   800389 <cprintf>
	*dev = 0;
  80139c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8013a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8013a7:	83 c4 14             	add    $0x14,%esp
  8013aa:	5b                   	pop    %ebx
  8013ab:	5d                   	pop    %ebp
  8013ac:	c3                   	ret    

008013ad <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8013ad:	55                   	push   %ebp
  8013ae:	89 e5                	mov    %esp,%ebp
  8013b0:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b3:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8013b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bd:	89 04 24             	mov    %eax,(%esp)
  8013c0:	e8 09 ff ff ff       	call   8012ce <fd_lookup>
  8013c5:	89 c2                	mov    %eax,%edx
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	78 5a                	js     801425 <fstat+0x78>
  8013cb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8013d5:	8b 00                	mov    (%eax),%eax
  8013d7:	89 04 24             	mov    %eax,(%esp)
  8013da:	e8 63 ff ff ff       	call   801342 <dev_lookup>
  8013df:	89 c2                	mov    %eax,%edx
  8013e1:	85 c0                	test   %eax,%eax
  8013e3:	78 40                	js     801425 <fstat+0x78>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8013e5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  8013ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013ed:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013f1:	74 32                	je     801425 <fstat+0x78>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f6:	c6 00 00             	movb   $0x0,(%eax)
	stat->st_size = 0;
  8013f9:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  801400:	00 00 00 
	stat->st_isdir = 0;
  801403:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
  80140a:	00 00 00 
	stat->st_dev = dev;
  80140d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801410:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
	return (*dev->dev_stat)(fd, stat);
  801416:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80141d:	89 04 24             	mov    %eax,(%esp)
  801420:	ff 52 14             	call   *0x14(%edx)
  801423:	89 c2                	mov    %eax,%edx
}
  801425:	89 d0                	mov    %edx,%eax
  801427:	c9                   	leave  
  801428:	c3                   	ret    

00801429 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	53                   	push   %ebx
  80142d:	83 ec 24             	sub    $0x24,%esp
  801430:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801433:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801436:	89 44 24 04          	mov    %eax,0x4(%esp)
  80143a:	89 1c 24             	mov    %ebx,(%esp)
  80143d:	e8 8c fe ff ff       	call   8012ce <fd_lookup>
  801442:	85 c0                	test   %eax,%eax
  801444:	78 61                	js     8014a7 <ftruncate+0x7e>
  801446:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801449:	8b 10                	mov    (%eax),%edx
  80144b:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80144e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801452:	89 14 24             	mov    %edx,(%esp)
  801455:	e8 e8 fe ff ff       	call   801342 <dev_lookup>
  80145a:	85 c0                	test   %eax,%eax
  80145c:	78 49                	js     8014a7 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80145e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801461:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801465:	75 23                	jne    80148a <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801467:	a1 3c 60 80 00       	mov    0x80603c,%eax
  80146c:	8b 40 4c             	mov    0x4c(%eax),%eax
  80146f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801473:	89 44 24 04          	mov    %eax,0x4(%esp)
  801477:	c7 04 24 ac 28 80 00 	movl   $0x8028ac,(%esp)
  80147e:	e8 06 ef ff ff       	call   800389 <cprintf>
  801483:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801488:	eb 1d                	jmp    8014a7 <ftruncate+0x7e>
			env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80148a:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80148d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801492:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801496:	74 0f                	je     8014a7 <ftruncate+0x7e>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801498:	8b 42 18             	mov    0x18(%edx),%eax
  80149b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80149e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014a2:	89 0c 24             	mov    %ecx,(%esp)
  8014a5:	ff d0                	call   *%eax
}
  8014a7:	83 c4 24             	add    $0x24,%esp
  8014aa:	5b                   	pop    %ebx
  8014ab:	5d                   	pop    %ebp
  8014ac:	c3                   	ret    

008014ad <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014ad:	55                   	push   %ebp
  8014ae:	89 e5                	mov    %esp,%ebp
  8014b0:	53                   	push   %ebx
  8014b1:	83 ec 24             	sub    $0x24,%esp
  8014b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014be:	89 1c 24             	mov    %ebx,(%esp)
  8014c1:	e8 08 fe ff ff       	call   8012ce <fd_lookup>
  8014c6:	85 c0                	test   %eax,%eax
  8014c8:	78 68                	js     801532 <write+0x85>
  8014ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014cd:	8b 10                	mov    (%eax),%edx
  8014cf:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8014d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d6:	89 14 24             	mov    %edx,(%esp)
  8014d9:	e8 64 fe ff ff       	call   801342 <dev_lookup>
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	78 50                	js     801532 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014e2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  8014e5:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  8014e9:	75 23                	jne    80150e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  8014eb:	a1 3c 60 80 00       	mov    0x80603c,%eax
  8014f0:	8b 40 4c             	mov    0x4c(%eax),%eax
  8014f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014fb:	c7 04 24 d0 28 80 00 	movl   $0x8028d0,(%esp)
  801502:	e8 82 ee ff ff       	call   800389 <cprintf>
  801507:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80150c:	eb 24                	jmp    801532 <write+0x85>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80150e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801511:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801516:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  80151a:	74 16                	je     801532 <write+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80151c:	8b 42 0c             	mov    0xc(%edx),%eax
  80151f:	8b 55 10             	mov    0x10(%ebp),%edx
  801522:	89 54 24 08          	mov    %edx,0x8(%esp)
  801526:	8b 55 0c             	mov    0xc(%ebp),%edx
  801529:	89 54 24 04          	mov    %edx,0x4(%esp)
  80152d:	89 0c 24             	mov    %ecx,(%esp)
  801530:	ff d0                	call   *%eax
}
  801532:	83 c4 24             	add    $0x24,%esp
  801535:	5b                   	pop    %ebx
  801536:	5d                   	pop    %ebp
  801537:	c3                   	ret    

00801538 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801538:	55                   	push   %ebp
  801539:	89 e5                	mov    %esp,%ebp
  80153b:	53                   	push   %ebx
  80153c:	83 ec 24             	sub    $0x24,%esp
  80153f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801542:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801545:	89 44 24 04          	mov    %eax,0x4(%esp)
  801549:	89 1c 24             	mov    %ebx,(%esp)
  80154c:	e8 7d fd ff ff       	call   8012ce <fd_lookup>
  801551:	85 c0                	test   %eax,%eax
  801553:	78 6d                	js     8015c2 <read+0x8a>
  801555:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801558:	8b 10                	mov    (%eax),%edx
  80155a:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80155d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801561:	89 14 24             	mov    %edx,(%esp)
  801564:	e8 d9 fd ff ff       	call   801342 <dev_lookup>
  801569:	85 c0                	test   %eax,%eax
  80156b:	78 55                	js     8015c2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80156d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801570:	8b 41 08             	mov    0x8(%ecx),%eax
  801573:	83 e0 03             	and    $0x3,%eax
  801576:	83 f8 01             	cmp    $0x1,%eax
  801579:	75 23                	jne    80159e <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  80157b:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801580:	8b 40 4c             	mov    0x4c(%eax),%eax
  801583:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801587:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158b:	c7 04 24 ed 28 80 00 	movl   $0x8028ed,(%esp)
  801592:	e8 f2 ed ff ff       	call   800389 <cprintf>
  801597:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80159c:	eb 24                	jmp    8015c2 <read+0x8a>
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80159e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8015a1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015a6:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  8015aa:	74 16                	je     8015c2 <read+0x8a>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015ac:	8b 42 08             	mov    0x8(%edx),%eax
  8015af:	8b 55 10             	mov    0x10(%ebp),%edx
  8015b2:	89 54 24 08          	mov    %edx,0x8(%esp)
  8015b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015bd:	89 0c 24             	mov    %ecx,(%esp)
  8015c0:	ff d0                	call   *%eax
}
  8015c2:	83 c4 24             	add    $0x24,%esp
  8015c5:	5b                   	pop    %ebx
  8015c6:	5d                   	pop    %ebp
  8015c7:	c3                   	ret    

008015c8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015c8:	55                   	push   %ebp
  8015c9:	89 e5                	mov    %esp,%ebp
  8015cb:	57                   	push   %edi
  8015cc:	56                   	push   %esi
  8015cd:	53                   	push   %ebx
  8015ce:	83 ec 0c             	sub    $0xc,%esp
  8015d1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8015d4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8015dc:	85 f6                	test   %esi,%esi
  8015de:	74 36                	je     801616 <readn+0x4e>
  8015e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015e5:	ba 00 00 00 00       	mov    $0x0,%edx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015ea:	89 f0                	mov    %esi,%eax
  8015ec:	29 d0                	sub    %edx,%eax
  8015ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015f2:	8d 04 17             	lea    (%edi,%edx,1),%eax
  8015f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fc:	89 04 24             	mov    %eax,(%esp)
  8015ff:	e8 34 ff ff ff       	call   801538 <read>
		if (m < 0)
  801604:	85 c0                	test   %eax,%eax
  801606:	78 0e                	js     801616 <readn+0x4e>
			return m;
		if (m == 0)
  801608:	85 c0                	test   %eax,%eax
  80160a:	74 08                	je     801614 <readn+0x4c>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80160c:	01 c3                	add    %eax,%ebx
  80160e:	89 da                	mov    %ebx,%edx
  801610:	39 f3                	cmp    %esi,%ebx
  801612:	72 d6                	jb     8015ea <readn+0x22>
  801614:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801616:	83 c4 0c             	add    $0xc,%esp
  801619:	5b                   	pop    %ebx
  80161a:	5e                   	pop    %esi
  80161b:	5f                   	pop    %edi
  80161c:	5d                   	pop    %ebp
  80161d:	c3                   	ret    

0080161e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	83 ec 28             	sub    $0x28,%esp
  801624:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801627:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80162a:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80162d:	89 34 24             	mov    %esi,(%esp)
  801630:	e8 1b fc ff ff       	call   801250 <fd2num>
  801635:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801638:	89 54 24 04          	mov    %edx,0x4(%esp)
  80163c:	89 04 24             	mov    %eax,(%esp)
  80163f:	e8 8a fc ff ff       	call   8012ce <fd_lookup>
  801644:	89 c3                	mov    %eax,%ebx
  801646:	85 c0                	test   %eax,%eax
  801648:	78 05                	js     80164f <fd_close+0x31>
  80164a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80164d:	74 0d                	je     80165c <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80164f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801653:	75 44                	jne    801699 <fd_close+0x7b>
  801655:	bb 00 00 00 00       	mov    $0x0,%ebx
  80165a:	eb 3d                	jmp    801699 <fd_close+0x7b>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80165c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80165f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801663:	8b 06                	mov    (%esi),%eax
  801665:	89 04 24             	mov    %eax,(%esp)
  801668:	e8 d5 fc ff ff       	call   801342 <dev_lookup>
  80166d:	89 c3                	mov    %eax,%ebx
  80166f:	85 c0                	test   %eax,%eax
  801671:	78 16                	js     801689 <fd_close+0x6b>
		if (dev->dev_close)
  801673:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801676:	8b 40 10             	mov    0x10(%eax),%eax
  801679:	bb 00 00 00 00       	mov    $0x0,%ebx
  80167e:	85 c0                	test   %eax,%eax
  801680:	74 07                	je     801689 <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  801682:	89 34 24             	mov    %esi,(%esp)
  801685:	ff d0                	call   *%eax
  801687:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801689:	89 74 24 04          	mov    %esi,0x4(%esp)
  80168d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801694:	e8 d5 f9 ff ff       	call   80106e <sys_page_unmap>
	return r;
}
  801699:	89 d8                	mov    %ebx,%eax
  80169b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80169e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8016a1:	89 ec                	mov    %ebp,%esp
  8016a3:	5d                   	pop    %ebp
  8016a4:	c3                   	ret    

008016a5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016ab:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b5:	89 04 24             	mov    %eax,(%esp)
  8016b8:	e8 11 fc ff ff       	call   8012ce <fd_lookup>
  8016bd:	85 c0                	test   %eax,%eax
  8016bf:	78 13                	js     8016d4 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8016c1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016c8:	00 
  8016c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016cc:	89 04 24             	mov    %eax,(%esp)
  8016cf:	e8 4a ff ff ff       	call   80161e <fd_close>
}
  8016d4:	c9                   	leave  
  8016d5:	c3                   	ret    

008016d6 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	83 ec 18             	sub    $0x18,%esp
  8016dc:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8016df:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016e2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016e9:	00 
  8016ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ed:	89 04 24             	mov    %eax,(%esp)
  8016f0:	e8 5a 03 00 00       	call   801a4f <open>
  8016f5:	89 c6                	mov    %eax,%esi
  8016f7:	85 c0                	test   %eax,%eax
  8016f9:	78 1b                	js     801716 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8016fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801702:	89 34 24             	mov    %esi,(%esp)
  801705:	e8 a3 fc ff ff       	call   8013ad <fstat>
  80170a:	89 c3                	mov    %eax,%ebx
	close(fd);
  80170c:	89 34 24             	mov    %esi,(%esp)
  80170f:	e8 91 ff ff ff       	call   8016a5 <close>
  801714:	89 de                	mov    %ebx,%esi
	return r;
}
  801716:	89 f0                	mov    %esi,%eax
  801718:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80171b:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80171e:	89 ec                	mov    %ebp,%esp
  801720:	5d                   	pop    %ebp
  801721:	c3                   	ret    

00801722 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	83 ec 38             	sub    $0x38,%esp
  801728:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80172b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80172e:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801731:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801734:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801737:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173b:	8b 45 08             	mov    0x8(%ebp),%eax
  80173e:	89 04 24             	mov    %eax,(%esp)
  801741:	e8 88 fb ff ff       	call   8012ce <fd_lookup>
  801746:	89 c3                	mov    %eax,%ebx
  801748:	85 c0                	test   %eax,%eax
  80174a:	0f 88 e1 00 00 00    	js     801831 <dup+0x10f>
		return r;
	close(newfdnum);
  801750:	89 3c 24             	mov    %edi,(%esp)
  801753:	e8 4d ff ff ff       	call   8016a5 <close>

	newfd = INDEX2FD(newfdnum);
  801758:	89 f8                	mov    %edi,%eax
  80175a:	c1 e0 0c             	shl    $0xc,%eax
  80175d:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  801763:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801766:	89 04 24             	mov    %eax,(%esp)
  801769:	e8 f2 fa ff ff       	call   801260 <fd2data>
  80176e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801770:	89 34 24             	mov    %esi,(%esp)
  801773:	e8 e8 fa ff ff       	call   801260 <fd2data>
  801778:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  80177b:	89 d8                	mov    %ebx,%eax
  80177d:	c1 e8 16             	shr    $0x16,%eax
  801780:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801787:	a8 01                	test   $0x1,%al
  801789:	74 45                	je     8017d0 <dup+0xae>
  80178b:	89 da                	mov    %ebx,%edx
  80178d:	c1 ea 0c             	shr    $0xc,%edx
  801790:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801797:	a8 01                	test   $0x1,%al
  801799:	74 35                	je     8017d0 <dup+0xae>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  80179b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8017a2:	25 07 0e 00 00       	and    $0xe07,%eax
  8017a7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017b2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017b9:	00 
  8017ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017c5:	e8 02 f9 ff ff       	call   8010cc <sys_page_map>
  8017ca:	89 c3                	mov    %eax,%ebx
  8017cc:	85 c0                	test   %eax,%eax
  8017ce:	78 3e                	js     80180e <dup+0xec>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  8017d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017d3:	89 d0                	mov    %edx,%eax
  8017d5:	c1 e8 0c             	shr    $0xc,%eax
  8017d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017df:	25 07 0e 00 00       	and    $0xe07,%eax
  8017e4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017e8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8017ec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017f3:	00 
  8017f4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017ff:	e8 c8 f8 ff ff       	call   8010cc <sys_page_map>
  801804:	89 c3                	mov    %eax,%ebx
  801806:	85 c0                	test   %eax,%eax
  801808:	78 04                	js     80180e <dup+0xec>
		goto err;
  80180a:	89 fb                	mov    %edi,%ebx
  80180c:	eb 23                	jmp    801831 <dup+0x10f>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80180e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801812:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801819:	e8 50 f8 ff ff       	call   80106e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80181e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801821:	89 44 24 04          	mov    %eax,0x4(%esp)
  801825:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80182c:	e8 3d f8 ff ff       	call   80106e <sys_page_unmap>
	return r;
}
  801831:	89 d8                	mov    %ebx,%eax
  801833:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801836:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801839:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80183c:	89 ec                	mov    %ebp,%esp
  80183e:	5d                   	pop    %ebp
  80183f:	c3                   	ret    

00801840 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	53                   	push   %ebx
  801844:	83 ec 04             	sub    $0x4,%esp
  801847:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  80184c:	89 1c 24             	mov    %ebx,(%esp)
  80184f:	e8 51 fe ff ff       	call   8016a5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801854:	83 c3 01             	add    $0x1,%ebx
  801857:	83 fb 20             	cmp    $0x20,%ebx
  80185a:	75 f0                	jne    80184c <close_all+0xc>
		close(i);
}
  80185c:	83 c4 04             	add    $0x4,%esp
  80185f:	5b                   	pop    %ebx
  801860:	5d                   	pop    %ebp
  801861:	c3                   	ret    
	...

00801864 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
  801867:	53                   	push   %ebx
  801868:	83 ec 14             	sub    $0x14,%esp
  80186b:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80186d:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801873:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80187a:	00 
  80187b:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801882:	00 
  801883:	89 44 24 04          	mov    %eax,0x4(%esp)
  801887:	89 14 24             	mov    %edx,(%esp)
  80188a:	e8 71 07 00 00       	call   802000 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80188f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801896:	00 
  801897:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80189b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018a2:	e8 0d 08 00 00       	call   8020b4 <ipc_recv>
}
  8018a7:	83 c4 14             	add    $0x14,%esp
  8018aa:	5b                   	pop    %ebx
  8018ab:	5d                   	pop    %ebp
  8018ac:	c3                   	ret    

008018ad <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  8018ad:	55                   	push   %ebp
  8018ae:	89 e5                	mov    %esp,%ebp
  8018b0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b8:	b8 08 00 00 00       	mov    $0x8,%eax
  8018bd:	e8 a2 ff ff ff       	call   801864 <fsipc>
}
  8018c2:	c9                   	leave  
  8018c3:	c3                   	ret    

008018c4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018c4:	55                   	push   %ebp
  8018c5:	89 e5                	mov    %esp,%ebp
  8018c7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d0:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  8018d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d8:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e2:	b8 02 00 00 00       	mov    $0x2,%eax
  8018e7:	e8 78 ff ff ff       	call   801864 <fsipc>
}
  8018ec:	c9                   	leave  
  8018ed:	c3                   	ret    

008018ee <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018ee:	55                   	push   %ebp
  8018ef:	89 e5                	mov    %esp,%ebp
  8018f1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8018fa:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  8018ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801904:	b8 06 00 00 00       	mov    $0x6,%eax
  801909:	e8 56 ff ff ff       	call   801864 <fsipc>
}
  80190e:	c9                   	leave  
  80190f:	c3                   	ret    

00801910 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	53                   	push   %ebx
  801914:	83 ec 14             	sub    $0x14,%esp
  801917:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80191a:	8b 45 08             	mov    0x8(%ebp),%eax
  80191d:	8b 40 0c             	mov    0xc(%eax),%eax
  801920:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801925:	ba 00 00 00 00       	mov    $0x0,%edx
  80192a:	b8 05 00 00 00       	mov    $0x5,%eax
  80192f:	e8 30 ff ff ff       	call   801864 <fsipc>
  801934:	85 c0                	test   %eax,%eax
  801936:	78 2b                	js     801963 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801938:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  80193f:	00 
  801940:	89 1c 24             	mov    %ebx,(%esp)
  801943:	e8 a9 f0 ff ff       	call   8009f1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801948:	a1 80 30 80 00       	mov    0x803080,%eax
  80194d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801953:	a1 84 30 80 00       	mov    0x803084,%eax
  801958:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80195e:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801963:	83 c4 14             	add    $0x14,%esp
  801966:	5b                   	pop    %ebx
  801967:	5d                   	pop    %ebp
  801968:	c3                   	ret    

00801969 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801969:	55                   	push   %ebp
  80196a:	89 e5                	mov    %esp,%ebp
  80196c:	83 ec 18             	sub    $0x18,%esp
  80196f:	8b 55 10             	mov    0x10(%ebp),%edx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	ssize_t writesize;
	size_t bufsize;
	fsipcbuf.write.req_fileid=fd->fd_file.id;
  801972:	8b 45 08             	mov    0x8(%ebp),%eax
  801975:	8b 40 0c             	mov    0xc(%eax),%eax
  801978:	a3 00 30 80 00       	mov    %eax,0x803000
	bufsize=sizeof(fsipcbuf.write.req_buf);
	if(n<bufsize)
  80197d:	89 d0                	mov    %edx,%eax
  80197f:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  801985:	76 05                	jbe    80198c <devfile_write+0x23>
  801987:	b8 f8 0f 00 00       	mov    $0xff8,%eax
		bufsize=n;	
	fsipcbuf.write.req_n=n;
  80198c:	89 15 04 30 80 00    	mov    %edx,0x803004
	memmove((void*)fsipcbuf.write.req_buf,buf,bufsize);
  801992:	89 44 24 08          	mov    %eax,0x8(%esp)
  801996:	8b 45 0c             	mov    0xc(%ebp),%eax
  801999:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199d:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  8019a4:	e8 4f f2 ff ff       	call   800bf8 <memmove>
	writesize=(ssize_t)fsipc(FSREQ_WRITE,NULL);
  8019a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ae:	b8 04 00 00 00       	mov    $0x4,%eax
  8019b3:	e8 ac fe ff ff       	call   801864 <fsipc>
	return writesize;
	//panic("devfile_write not implemented");
}
  8019b8:	c9                   	leave  
  8019b9:	c3                   	ret    

008019ba <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	53                   	push   %ebx
  8019be:	83 ec 14             	sub    $0x14,%esp
	// system server.
	// LAB 5: Your code here
	ssize_t readsize;
	if(debug)
		cprintf("devfile_read:fileid=%x readsize=%x\n",fd->fd_file.id,n);
	fsipcbuf.read.req_fileid=fd->fd_file.id;
  8019c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c7:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n=n;
  8019cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8019cf:	a3 04 30 80 00       	mov    %eax,0x803004
	readsize=(ssize_t)fsipc(FSREQ_READ,&fsipcbuf);
  8019d4:	ba 00 30 80 00       	mov    $0x803000,%edx
  8019d9:	b8 03 00 00 00       	mov    $0x3,%eax
  8019de:	e8 81 fe ff ff       	call   801864 <fsipc>
  8019e3:	89 c3                	mov    %eax,%ebx
	//cprintf("readsize=%d\n",readsize);
	if(debug)
		cprintf("devfile_read:buf1=%s\nbuf2=%s\n",(char*)&fsipcbuf,fsipcbuf.readRet.ret_buf);
	if(readsize>0)
  8019e5:	85 c0                	test   %eax,%eax
  8019e7:	7e 17                	jle    801a00 <devfile_read+0x46>
		memmove(buf,(void*)&fsipcbuf,(size_t)readsize);
  8019e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019ed:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  8019f4:	00 
  8019f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f8:	89 04 24             	mov    %eax,(%esp)
  8019fb:	e8 f8 f1 ff ff       	call   800bf8 <memmove>
	//cprintf("readsize=%d",readsize);
	return readsize;
	//panic("devfile_read not implemented");
}
  801a00:	89 d8                	mov    %ebx,%eax
  801a02:	83 c4 14             	add    $0x14,%esp
  801a05:	5b                   	pop    %ebx
  801a06:	5d                   	pop    %ebp
  801a07:	c3                   	ret    

00801a08 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	53                   	push   %ebx
  801a0c:	83 ec 14             	sub    $0x14,%esp
  801a0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801a12:	89 1c 24             	mov    %ebx,(%esp)
  801a15:	e8 86 ef ff ff       	call   8009a0 <strlen>
  801a1a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  801a1f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a24:	7f 21                	jg     801a47 <remove+0x3f>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801a26:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a2a:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801a31:	e8 bb ef ff ff       	call   8009f1 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801a36:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3b:	b8 07 00 00 00       	mov    $0x7,%eax
  801a40:	e8 1f fe ff ff       	call   801864 <fsipc>
  801a45:	89 c2                	mov    %eax,%edx
}
  801a47:	89 d0                	mov    %edx,%eax
  801a49:	83 c4 14             	add    $0x14,%esp
  801a4c:	5b                   	pop    %ebx
  801a4d:	5d                   	pop    %ebp
  801a4e:	c3                   	ret    

00801a4f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a4f:	55                   	push   %ebp
  801a50:	89 e5                	mov    %esp,%ebp
  801a52:	56                   	push   %esi
  801a53:	53                   	push   %ebx
  801a54:	83 ec 30             	sub    $0x30,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;
	void *page;
	if((r=fd_alloc(&fd))<0){
  801a57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a5a:	89 04 24             	mov    %eax,(%esp)
  801a5d:	e8 19 f8 ff ff       	call   80127b <fd_alloc>
  801a62:	89 c3                	mov    %eax,%ebx
  801a64:	85 c0                	test   %eax,%eax
  801a66:	79 18                	jns    801a80 <open+0x31>
		fd_close(fd,0);
  801a68:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a6f:	00 
  801a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a73:	89 04 24             	mov    %eax,(%esp)
  801a76:	e8 a3 fb ff ff       	call   80161e <fd_close>
  801a7b:	e9 9f 00 00 00       	jmp    801b1f <open+0xd0>
		return r;
	}
	//cprintf("open:fd=%x\n",fd);
	strcpy(fsipcbuf.open.req_path,path);
  801a80:	8b 45 08             	mov    0x8(%ebp),%eax
  801a83:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a87:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801a8e:	e8 5e ef ff ff       	call   8009f1 <strcpy>
	fsipcbuf.open.req_omode=mode;
  801a93:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a96:	a3 00 34 80 00       	mov    %eax,0x803400
	page=(void*)fd2data(fd);
  801a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a9e:	89 04 24             	mov    %eax,(%esp)
  801aa1:	e8 ba f7 ff ff       	call   801260 <fd2data>
  801aa6:	89 c6                	mov    %eax,%esi
	if((r=fsipc(FSREQ_OPEN,(void*)fd))<0)
  801aa8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801aab:	b8 01 00 00 00       	mov    $0x1,%eax
  801ab0:	e8 af fd ff ff       	call   801864 <fsipc>
  801ab5:	89 c3                	mov    %eax,%ebx
  801ab7:	85 c0                	test   %eax,%eax
  801ab9:	79 15                	jns    801ad0 <open+0x81>
	{
		fd_close(fd,1);
  801abb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ac2:	00 
  801ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac6:	89 04 24             	mov    %eax,(%esp)
  801ac9:	e8 50 fb ff ff       	call   80161e <fd_close>
  801ace:	eb 4f                	jmp    801b1f <open+0xd0>
		return r;	
	}
	//cprintf("open:page=%x\n",page);
	if((r=sys_page_map(0,(void*)fd,0,(void*)page,PTE_P | PTE_W | PTE_U))<0)
  801ad0:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801ad7:	00 
  801ad8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801adc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ae3:	00 
  801ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aeb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801af2:	e8 d5 f5 ff ff       	call   8010cc <sys_page_map>
  801af7:	89 c3                	mov    %eax,%ebx
  801af9:	85 c0                	test   %eax,%eax
  801afb:	79 15                	jns    801b12 <open+0xc3>
	{
		fd_close(fd,1);
  801afd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801b04:	00 
  801b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b08:	89 04 24             	mov    %eax,(%esp)
  801b0b:	e8 0e fb ff ff       	call   80161e <fd_close>
  801b10:	eb 0d                	jmp    801b1f <open+0xd0>
		return r;
	}
	//cprintf("open:fileid=%x\n",fd->fd_file.id);
	return fd2num(fd);
  801b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b15:	89 04 24             	mov    %eax,(%esp)
  801b18:	e8 33 f7 ff ff       	call   801250 <fd2num>
  801b1d:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801b1f:	89 d8                	mov    %ebx,%eax
  801b21:	83 c4 30             	add    $0x30,%esp
  801b24:	5b                   	pop    %ebx
  801b25:	5e                   	pop    %esi
  801b26:	5d                   	pop    %ebp
  801b27:	c3                   	ret    
	...

00801b30 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  801b36:	c7 44 24 04 18 29 80 	movl   $0x802918,0x4(%esp)
  801b3d:	00 
  801b3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b41:	89 04 24             	mov    %eax,(%esp)
  801b44:	e8 a8 ee ff ff       	call   8009f1 <strcpy>
	return 0;
}
  801b49:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4e:	c9                   	leave  
  801b4f:	c3                   	ret    

00801b50 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	83 ec 08             	sub    $0x8,%esp
	return nsipc_close(fd->fd_sock.sockid);
  801b56:	8b 45 08             	mov    0x8(%ebp),%eax
  801b59:	8b 40 0c             	mov    0xc(%eax),%eax
  801b5c:	89 04 24             	mov    %eax,(%esp)
  801b5f:	e8 9e 02 00 00       	call   801e02 <nsipc_close>
}
  801b64:	c9                   	leave  
  801b65:	c3                   	ret    

00801b66 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b6c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b73:	00 
  801b74:	8b 45 10             	mov    0x10(%ebp),%eax
  801b77:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b82:	8b 45 08             	mov    0x8(%ebp),%eax
  801b85:	8b 40 0c             	mov    0xc(%eax),%eax
  801b88:	89 04 24             	mov    %eax,(%esp)
  801b8b:	e8 ae 02 00 00       	call   801e3e <nsipc_send>
}
  801b90:	c9                   	leave  
  801b91:	c3                   	ret    

00801b92 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b98:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b9f:	00 
  801ba0:	8b 45 10             	mov    0x10(%ebp),%eax
  801ba3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ba7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801baa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bae:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb1:	8b 40 0c             	mov    0xc(%eax),%eax
  801bb4:	89 04 24             	mov    %eax,(%esp)
  801bb7:	e8 f5 02 00 00       	call   801eb1 <nsipc_recv>
}
  801bbc:	c9                   	leave  
  801bbd:	c3                   	ret    

00801bbe <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	56                   	push   %esi
  801bc2:	53                   	push   %ebx
  801bc3:	83 ec 20             	sub    $0x20,%esp
  801bc6:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801bc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bcb:	89 04 24             	mov    %eax,(%esp)
  801bce:	e8 a8 f6 ff ff       	call   80127b <fd_alloc>
  801bd3:	89 c3                	mov    %eax,%ebx
  801bd5:	85 c0                	test   %eax,%eax
  801bd7:	78 21                	js     801bfa <alloc_sockfd+0x3c>
  801bd9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801be0:	00 
  801be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bef:	e8 36 f5 ff ff       	call   80112a <sys_page_alloc>
  801bf4:	89 c3                	mov    %eax,%ebx
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	79 0a                	jns    801c04 <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U)) < 0) {
		nsipc_close(sockid);
  801bfa:	89 34 24             	mov    %esi,(%esp)
  801bfd:	e8 00 02 00 00       	call   801e02 <nsipc_close>
  801c02:	eb 28                	jmp    801c2c <alloc_sockfd+0x6e>
		return r;
	}

	sfd->fd_dev_id = devsock.dev_id;
  801c04:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0d:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c12:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c22:	89 04 24             	mov    %eax,(%esp)
  801c25:	e8 26 f6 ff ff       	call   801250 <fd2num>
  801c2a:	89 c3                	mov    %eax,%ebx
}
  801c2c:	89 d8                	mov    %ebx,%eax
  801c2e:	83 c4 20             	add    $0x20,%esp
  801c31:	5b                   	pop    %ebx
  801c32:	5e                   	pop    %esi
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    

00801c35 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c3b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c3e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c42:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c45:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c49:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4c:	89 04 24             	mov    %eax,(%esp)
  801c4f:	e8 62 01 00 00       	call   801db6 <nsipc_socket>
  801c54:	85 c0                	test   %eax,%eax
  801c56:	78 05                	js     801c5d <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801c58:	e8 61 ff ff ff       	call   801bbe <alloc_sockfd>
}
  801c5d:	c9                   	leave  
  801c5e:	66 90                	xchg   %ax,%ax
  801c60:	c3                   	ret    

00801c61 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c61:	55                   	push   %ebp
  801c62:	89 e5                	mov    %esp,%ebp
  801c64:	83 ec 18             	sub    $0x18,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c67:	8d 55 fc             	lea    -0x4(%ebp),%edx
  801c6a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c6e:	89 04 24             	mov    %eax,(%esp)
  801c71:	e8 58 f6 ff ff       	call   8012ce <fd_lookup>
  801c76:	89 c2                	mov    %eax,%edx
  801c78:	85 c0                	test   %eax,%eax
  801c7a:	78 15                	js     801c91 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c7c:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  801c7f:	8b 01                	mov    (%ecx),%eax
  801c81:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  801c86:	3b 05 20 60 80 00    	cmp    0x806020,%eax
  801c8c:	75 03                	jne    801c91 <fd2sockid+0x30>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c8e:	8b 51 0c             	mov    0xc(%ecx),%edx
}
  801c91:	89 d0                	mov    %edx,%eax
  801c93:	c9                   	leave  
  801c94:	c3                   	ret    

00801c95 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9e:	e8 be ff ff ff       	call   801c61 <fd2sockid>
  801ca3:	85 c0                	test   %eax,%eax
  801ca5:	78 0f                	js     801cb6 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801ca7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801caa:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cae:	89 04 24             	mov    %eax,(%esp)
  801cb1:	e8 2a 01 00 00       	call   801de0 <nsipc_listen>
}
  801cb6:	c9                   	leave  
  801cb7:	c3                   	ret    

00801cb8 <connect>:
	return nsipc_close(fd->fd_sock.sockid);
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cb8:	55                   	push   %ebp
  801cb9:	89 e5                	mov    %esp,%ebp
  801cbb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc1:	e8 9b ff ff ff       	call   801c61 <fd2sockid>
  801cc6:	85 c0                	test   %eax,%eax
  801cc8:	78 16                	js     801ce0 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801cca:	8b 55 10             	mov    0x10(%ebp),%edx
  801ccd:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cd1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cd4:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cd8:	89 04 24             	mov    %eax,(%esp)
  801cdb:	e8 51 02 00 00       	call   801f31 <nsipc_connect>
}
  801ce0:	c9                   	leave  
  801ce1:	c3                   	ret    

00801ce2 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801ce2:	55                   	push   %ebp
  801ce3:	89 e5                	mov    %esp,%ebp
  801ce5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ceb:	e8 71 ff ff ff       	call   801c61 <fd2sockid>
  801cf0:	85 c0                	test   %eax,%eax
  801cf2:	78 0f                	js     801d03 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801cf4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cf7:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cfb:	89 04 24             	mov    %eax,(%esp)
  801cfe:	e8 19 01 00 00       	call   801e1c <nsipc_shutdown>
}
  801d03:	c9                   	leave  
  801d04:	c3                   	ret    

00801d05 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d05:	55                   	push   %ebp
  801d06:	89 e5                	mov    %esp,%ebp
  801d08:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0e:	e8 4e ff ff ff       	call   801c61 <fd2sockid>
  801d13:	85 c0                	test   %eax,%eax
  801d15:	78 16                	js     801d2d <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801d17:	8b 55 10             	mov    0x10(%ebp),%edx
  801d1a:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d21:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d25:	89 04 24             	mov    %eax,(%esp)
  801d28:	e8 43 02 00 00       	call   801f70 <nsipc_bind>
}
  801d2d:	c9                   	leave  
  801d2e:	c3                   	ret    

00801d2f <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d2f:	55                   	push   %ebp
  801d30:	89 e5                	mov    %esp,%ebp
  801d32:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d35:	8b 45 08             	mov    0x8(%ebp),%eax
  801d38:	e8 24 ff ff ff       	call   801c61 <fd2sockid>
  801d3d:	85 c0                	test   %eax,%eax
  801d3f:	78 1f                	js     801d60 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d41:	8b 55 10             	mov    0x10(%ebp),%edx
  801d44:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d48:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d4b:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d4f:	89 04 24             	mov    %eax,(%esp)
  801d52:	e8 58 02 00 00       	call   801faf <nsipc_accept>
  801d57:	85 c0                	test   %eax,%eax
  801d59:	78 05                	js     801d60 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801d5b:	e8 5e fe ff ff       	call   801bbe <alloc_sockfd>
}
  801d60:	c9                   	leave  
  801d61:	c3                   	ret    
	...

00801d70 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d76:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  801d7c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d83:	00 
  801d84:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801d8b:	00 
  801d8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d90:	89 14 24             	mov    %edx,(%esp)
  801d93:	e8 68 02 00 00       	call   802000 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d98:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d9f:	00 
  801da0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801da7:	00 
  801da8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801daf:	e8 00 03 00 00       	call   8020b4 <ipc_recv>
}
  801db4:	c9                   	leave  
  801db5:	c3                   	ret    

00801db6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801db6:	55                   	push   %ebp
  801db7:	89 e5                	mov    %esp,%ebp
  801db9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801dbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbf:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.socket.req_type = type;
  801dc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc7:	a3 04 50 80 00       	mov    %eax,0x805004
	nsipcbuf.socket.req_protocol = protocol;
  801dcc:	8b 45 10             	mov    0x10(%ebp),%eax
  801dcf:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SOCKET);
  801dd4:	b8 09 00 00 00       	mov    $0x9,%eax
  801dd9:	e8 92 ff ff ff       	call   801d70 <nsipc>
}
  801dde:	c9                   	leave  
  801ddf:	c3                   	ret    

00801de0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801de6:	8b 45 08             	mov    0x8(%ebp),%eax
  801de9:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.listen.req_backlog = backlog;
  801dee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df1:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_LISTEN);
  801df6:	b8 06 00 00 00       	mov    $0x6,%eax
  801dfb:	e8 70 ff ff ff       	call   801d70 <nsipc>
}
  801e00:	c9                   	leave  
  801e01:	c3                   	ret    

00801e02 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e08:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0b:	a3 00 50 80 00       	mov    %eax,0x805000
	return nsipc(NSREQ_CLOSE);
  801e10:	b8 04 00 00 00       	mov    $0x4,%eax
  801e15:	e8 56 ff ff ff       	call   801d70 <nsipc>
}
  801e1a:	c9                   	leave  
  801e1b:	c3                   	ret    

00801e1c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e22:	8b 45 08             	mov    0x8(%ebp),%eax
  801e25:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.shutdown.req_how = how;
  801e2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e2d:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_SHUTDOWN);
  801e32:	b8 03 00 00 00       	mov    $0x3,%eax
  801e37:	e8 34 ff ff ff       	call   801d70 <nsipc>
}
  801e3c:	c9                   	leave  
  801e3d:	c3                   	ret    

00801e3e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e3e:	55                   	push   %ebp
  801e3f:	89 e5                	mov    %esp,%ebp
  801e41:	53                   	push   %ebx
  801e42:	83 ec 14             	sub    $0x14,%esp
  801e45:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e48:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4b:	a3 00 50 80 00       	mov    %eax,0x805000
	assert(size < 1600);
  801e50:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e56:	7e 24                	jle    801e7c <nsipc_send+0x3e>
  801e58:	c7 44 24 0c 24 29 80 	movl   $0x802924,0xc(%esp)
  801e5f:	00 
  801e60:	c7 44 24 08 30 29 80 	movl   $0x802930,0x8(%esp)
  801e67:	00 
  801e68:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  801e6f:	00 
  801e70:	c7 04 24 45 29 80 00 	movl   $0x802945,(%esp)
  801e77:	e8 40 e4 ff ff       	call   8002bc <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e7c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e80:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e83:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e87:	c7 04 24 0c 50 80 00 	movl   $0x80500c,(%esp)
  801e8e:	e8 65 ed ff ff       	call   800bf8 <memmove>
	nsipcbuf.send.req_size = size;
  801e93:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	nsipcbuf.send.req_flags = flags;
  801e99:	8b 45 14             	mov    0x14(%ebp),%eax
  801e9c:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SEND);
  801ea1:	b8 08 00 00 00       	mov    $0x8,%eax
  801ea6:	e8 c5 fe ff ff       	call   801d70 <nsipc>
}
  801eab:	83 c4 14             	add    $0x14,%esp
  801eae:	5b                   	pop    %ebx
  801eaf:	5d                   	pop    %ebp
  801eb0:	c3                   	ret    

00801eb1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	56                   	push   %esi
  801eb5:	53                   	push   %ebx
  801eb6:	83 ec 10             	sub    $0x10,%esp
  801eb9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ebc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebf:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.recv.req_len = len;
  801ec4:	89 35 04 50 80 00    	mov    %esi,0x805004
	nsipcbuf.recv.req_flags = flags;
  801eca:	8b 45 14             	mov    0x14(%ebp),%eax
  801ecd:	a3 08 50 80 00       	mov    %eax,0x805008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ed2:	b8 07 00 00 00       	mov    $0x7,%eax
  801ed7:	e8 94 fe ff ff       	call   801d70 <nsipc>
  801edc:	89 c3                	mov    %eax,%ebx
  801ede:	85 c0                	test   %eax,%eax
  801ee0:	78 46                	js     801f28 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801ee2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801ee7:	7f 04                	jg     801eed <nsipc_recv+0x3c>
  801ee9:	39 c6                	cmp    %eax,%esi
  801eeb:	7d 24                	jge    801f11 <nsipc_recv+0x60>
  801eed:	c7 44 24 0c 51 29 80 	movl   $0x802951,0xc(%esp)
  801ef4:	00 
  801ef5:	c7 44 24 08 30 29 80 	movl   $0x802930,0x8(%esp)
  801efc:	00 
  801efd:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  801f04:	00 
  801f05:	c7 04 24 45 29 80 00 	movl   $0x802945,(%esp)
  801f0c:	e8 ab e3 ff ff       	call   8002bc <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f11:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f15:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801f1c:	00 
  801f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f20:	89 04 24             	mov    %eax,(%esp)
  801f23:	e8 d0 ec ff ff       	call   800bf8 <memmove>
	}

	return r;
}
  801f28:	89 d8                	mov    %ebx,%eax
  801f2a:	83 c4 10             	add    $0x10,%esp
  801f2d:	5b                   	pop    %ebx
  801f2e:	5e                   	pop    %esi
  801f2f:	5d                   	pop    %ebp
  801f30:	c3                   	ret    

00801f31 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f31:	55                   	push   %ebp
  801f32:	89 e5                	mov    %esp,%ebp
  801f34:	53                   	push   %ebx
  801f35:	83 ec 14             	sub    $0x14,%esp
  801f38:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3e:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f43:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f47:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f4e:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801f55:	e8 9e ec ff ff       	call   800bf8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f5a:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_CONNECT);
  801f60:	b8 05 00 00 00       	mov    $0x5,%eax
  801f65:	e8 06 fe ff ff       	call   801d70 <nsipc>
}
  801f6a:	83 c4 14             	add    $0x14,%esp
  801f6d:	5b                   	pop    %ebx
  801f6e:	5d                   	pop    %ebp
  801f6f:	c3                   	ret    

00801f70 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f70:	55                   	push   %ebp
  801f71:	89 e5                	mov    %esp,%ebp
  801f73:	53                   	push   %ebx
  801f74:	83 ec 14             	sub    $0x14,%esp
  801f77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7d:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f82:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f86:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f89:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f8d:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801f94:	e8 5f ec ff ff       	call   800bf8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f99:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_BIND);
  801f9f:	b8 02 00 00 00       	mov    $0x2,%eax
  801fa4:	e8 c7 fd ff ff       	call   801d70 <nsipc>
}
  801fa9:	83 c4 14             	add    $0x14,%esp
  801fac:	5b                   	pop    %ebx
  801fad:	5d                   	pop    %ebp
  801fae:	c3                   	ret    

00801faf <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801faf:	55                   	push   %ebp
  801fb0:	89 e5                	mov    %esp,%ebp
  801fb2:	53                   	push   %ebx
  801fb3:	83 ec 14             	sub    $0x14,%esp
	int r;
	
	nsipcbuf.accept.req_s = s;
  801fb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801fbe:	b8 01 00 00 00       	mov    $0x1,%eax
  801fc3:	e8 a8 fd ff ff       	call   801d70 <nsipc>
  801fc8:	89 c3                	mov    %eax,%ebx
  801fca:	85 c0                	test   %eax,%eax
  801fcc:	78 26                	js     801ff4 <nsipc_accept+0x45>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801fce:	a1 10 50 80 00       	mov    0x805010,%eax
  801fd3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fd7:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801fde:	00 
  801fdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe2:	89 04 24             	mov    %eax,(%esp)
  801fe5:	e8 0e ec ff ff       	call   800bf8 <memmove>
		*addrlen = ret->ret_addrlen;
  801fea:	a1 10 50 80 00       	mov    0x805010,%eax
  801fef:	8b 55 10             	mov    0x10(%ebp),%edx
  801ff2:	89 02                	mov    %eax,(%edx)
	}
	return r;
}
  801ff4:	89 d8                	mov    %ebx,%eax
  801ff6:	83 c4 14             	add    $0x14,%esp
  801ff9:	5b                   	pop    %ebx
  801ffa:	5d                   	pop    %ebp
  801ffb:	c3                   	ret    
  801ffc:	00 00                	add    %al,(%eax)
	...

00802000 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802000:	55                   	push   %ebp
  802001:	89 e5                	mov    %esp,%ebp
  802003:	57                   	push   %edi
  802004:	56                   	push   %esi
  802005:	53                   	push   %ebx
  802006:	83 ec 1c             	sub    $0x1c,%esp
  802009:	8b 75 08             	mov    0x8(%ebp),%esi
  80200c:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  80200f:	e8 a9 f1 ff ff       	call   8011bd <sys_getenvid>
  802014:	25 ff 03 00 00       	and    $0x3ff,%eax
  802019:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80201c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802021:	a3 3c 60 80 00       	mov    %eax,0x80603c
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  802026:	e8 92 f1 ff ff       	call   8011bd <sys_getenvid>
  80202b:	25 ff 03 00 00       	and    $0x3ff,%eax
  802030:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802033:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802038:	a3 3c 60 80 00       	mov    %eax,0x80603c
		if(env->env_id==to_env){
  80203d:	8b 40 4c             	mov    0x4c(%eax),%eax
  802040:	39 f0                	cmp    %esi,%eax
  802042:	75 0e                	jne    802052 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  802044:	c7 04 24 66 29 80 00 	movl   $0x802966,(%esp)
  80204b:	e8 39 e3 ff ff       	call   800389 <cprintf>
  802050:	eb 5a                	jmp    8020ac <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  802052:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802056:	8b 45 10             	mov    0x10(%ebp),%eax
  802059:	89 44 24 08          	mov    %eax,0x8(%esp)
  80205d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802060:	89 44 24 04          	mov    %eax,0x4(%esp)
  802064:	89 34 24             	mov    %esi,(%esp)
  802067:	e8 b0 ee ff ff       	call   800f1c <sys_ipc_try_send>
  80206c:	89 c3                	mov    %eax,%ebx
  80206e:	85 c0                	test   %eax,%eax
  802070:	79 25                	jns    802097 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  802072:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802075:	74 2b                	je     8020a2 <ipc_send+0xa2>
				panic("send error:%e",r);
  802077:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80207b:	c7 44 24 08 82 29 80 	movl   $0x802982,0x8(%esp)
  802082:	00 
  802083:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80208a:	00 
  80208b:	c7 04 24 90 29 80 00 	movl   $0x802990,(%esp)
  802092:	e8 25 e2 ff ff       	call   8002bc <_panic>
		}
			sys_yield();
  802097:	e8 ed f0 ff ff       	call   801189 <sys_yield>
		
	}while(r!=0);
  80209c:	85 db                	test   %ebx,%ebx
  80209e:	75 86                	jne    802026 <ipc_send+0x26>
  8020a0:	eb 0a                	jmp    8020ac <ipc_send+0xac>
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
		{	
			if(r!=-E_IPC_NOT_RECV)
				panic("send error:%e",r);
		}
			sys_yield();
  8020a2:	e8 e2 f0 ff ff       	call   801189 <sys_yield>
  8020a7:	e9 7a ff ff ff       	jmp    802026 <ipc_send+0x26>
		
	}while(r!=0);
	return;
	//panic("ipc_send not implemented");
}
  8020ac:	83 c4 1c             	add    $0x1c,%esp
  8020af:	5b                   	pop    %ebx
  8020b0:	5e                   	pop    %esi
  8020b1:	5f                   	pop    %edi
  8020b2:	5d                   	pop    %ebp
  8020b3:	c3                   	ret    

008020b4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020b4:	55                   	push   %ebp
  8020b5:	89 e5                	mov    %esp,%ebp
  8020b7:	57                   	push   %edi
  8020b8:	56                   	push   %esi
  8020b9:	53                   	push   %ebx
  8020ba:	83 ec 0c             	sub    $0xc,%esp
  8020bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8020c0:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	void *dstva=NULL;
	if(pg)
		dstva=pg;
	env = &envs[ENVX(sys_getenvid())];
  8020c3:	e8 f5 f0 ff ff       	call   8011bd <sys_getenvid>
  8020c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8020cd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020d5:	a3 3c 60 80 00       	mov    %eax,0x80603c
	if(from_env_store&&(env->env_id==*from_env_store))
  8020da:	85 f6                	test   %esi,%esi
  8020dc:	74 29                	je     802107 <ipc_recv+0x53>
  8020de:	8b 40 4c             	mov    0x4c(%eax),%eax
  8020e1:	3b 06                	cmp    (%esi),%eax
  8020e3:	75 22                	jne    802107 <ipc_recv+0x53>
	{
		*from_env_store=0;
  8020e5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  8020eb:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("send:the reciver is sender\n");
  8020f1:	c7 04 24 66 29 80 00 	movl   $0x802966,(%esp)
  8020f8:	e8 8c e2 ff ff       	call   800389 <cprintf>
  8020fd:	bb 00 00 00 00       	mov    $0x0,%ebx
  802102:	e9 8a 00 00 00       	jmp    802191 <ipc_recv+0xdd>
		return 0;
	}
	env = &envs[ENVX(sys_getenvid())];
  802107:	e8 b1 f0 ff ff       	call   8011bd <sys_getenvid>
  80210c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802111:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802114:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802119:	a3 3c 60 80 00       	mov    %eax,0x80603c
	if((r=sys_ipc_recv(dstva))<0)
  80211e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802121:	89 04 24             	mov    %eax,(%esp)
  802124:	e8 96 ed ff ff       	call   800ebf <sys_ipc_recv>
  802129:	89 c3                	mov    %eax,%ebx
  80212b:	85 c0                	test   %eax,%eax
  80212d:	79 1a                	jns    802149 <ipc_recv+0x95>
	{
		*from_env_store=0;
  80212f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  802135:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("reciver failed\n");
  80213b:	c7 04 24 9a 29 80 00 	movl   $0x80299a,(%esp)
  802142:	e8 42 e2 ff ff       	call   800389 <cprintf>
  802147:	eb 48                	jmp    802191 <ipc_recv+0xdd>
		return r;
	}
	else{//接收成功
		env = &envs[ENVX(sys_getenvid())];
  802149:	e8 6f f0 ff ff       	call   8011bd <sys_getenvid>
  80214e:	25 ff 03 00 00       	and    $0x3ff,%eax
  802153:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802156:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80215b:	a3 3c 60 80 00       	mov    %eax,0x80603c
		if(from_env_store)
  802160:	85 f6                	test   %esi,%esi
  802162:	74 05                	je     802169 <ipc_recv+0xb5>
			*from_env_store=env->env_ipc_from;	
  802164:	8b 40 74             	mov    0x74(%eax),%eax
  802167:	89 06                	mov    %eax,(%esi)
		if(perm_store)
  802169:	85 ff                	test   %edi,%edi
  80216b:	74 0a                	je     802177 <ipc_recv+0xc3>
			*perm_store=env->env_ipc_perm;
  80216d:	a1 3c 60 80 00       	mov    0x80603c,%eax
  802172:	8b 40 78             	mov    0x78(%eax),%eax
  802175:	89 07                	mov    %eax,(%edi)
		env = &envs[ENVX(sys_getenvid())];
  802177:	e8 41 f0 ff ff       	call   8011bd <sys_getenvid>
  80217c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802181:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802184:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802189:	a3 3c 60 80 00       	mov    %eax,0x80603c
		return env->env_ipc_value;
  80218e:	8b 58 70             	mov    0x70(%eax),%ebx
	}
	//panic("ipc_recv not implemented");
	return 0;
}
  802191:	89 d8                	mov    %ebx,%eax
  802193:	83 c4 0c             	add    $0xc,%esp
  802196:	5b                   	pop    %ebx
  802197:	5e                   	pop    %esi
  802198:	5f                   	pop    %edi
  802199:	5d                   	pop    %ebp
  80219a:	c3                   	ret    
  80219b:	00 00                	add    %al,(%eax)
  80219d:	00 00                	add    %al,(%eax)
	...

008021a0 <__udivdi3>:
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
  8021a3:	57                   	push   %edi
  8021a4:	56                   	push   %esi
  8021a5:	83 ec 18             	sub    $0x18,%esp
  8021a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8021ab:	8b 55 14             	mov    0x14(%ebp),%edx
  8021ae:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8021b4:	89 c1                	mov    %eax,%ecx
  8021b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b9:	85 d2                	test   %edx,%edx
  8021bb:	89 d7                	mov    %edx,%edi
  8021bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8021c0:	75 1e                	jne    8021e0 <__udivdi3+0x40>
  8021c2:	39 f1                	cmp    %esi,%ecx
  8021c4:	0f 86 8d 00 00 00    	jbe    802257 <__udivdi3+0xb7>
  8021ca:	89 f2                	mov    %esi,%edx
  8021cc:	31 f6                	xor    %esi,%esi
  8021ce:	f7 f1                	div    %ecx
  8021d0:	89 c1                	mov    %eax,%ecx
  8021d2:	89 c8                	mov    %ecx,%eax
  8021d4:	89 f2                	mov    %esi,%edx
  8021d6:	83 c4 18             	add    $0x18,%esp
  8021d9:	5e                   	pop    %esi
  8021da:	5f                   	pop    %edi
  8021db:	5d                   	pop    %ebp
  8021dc:	c3                   	ret    
  8021dd:	8d 76 00             	lea    0x0(%esi),%esi
  8021e0:	39 f2                	cmp    %esi,%edx
  8021e2:	0f 87 a8 00 00 00    	ja     802290 <__udivdi3+0xf0>
  8021e8:	0f bd c2             	bsr    %edx,%eax
  8021eb:	83 f0 1f             	xor    $0x1f,%eax
  8021ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8021f1:	0f 84 89 00 00 00    	je     802280 <__udivdi3+0xe0>
  8021f7:	b8 20 00 00 00       	mov    $0x20,%eax
  8021fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021ff:	2b 45 e8             	sub    -0x18(%ebp),%eax
  802202:	89 c1                	mov    %eax,%ecx
  802204:	d3 ea                	shr    %cl,%edx
  802206:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  80220a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80220d:	89 f8                	mov    %edi,%eax
  80220f:	8b 7d f4             	mov    -0xc(%ebp),%edi
  802212:	d3 e0                	shl    %cl,%eax
  802214:	09 c2                	or     %eax,%edx
  802216:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802219:	d3 e7                	shl    %cl,%edi
  80221b:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80221f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802222:	89 f2                	mov    %esi,%edx
  802224:	d3 e8                	shr    %cl,%eax
  802226:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  80222a:	d3 e2                	shl    %cl,%edx
  80222c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802230:	09 d0                	or     %edx,%eax
  802232:	d3 ee                	shr    %cl,%esi
  802234:	89 f2                	mov    %esi,%edx
  802236:	f7 75 e4             	divl   -0x1c(%ebp)
  802239:	89 d1                	mov    %edx,%ecx
  80223b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80223e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802241:	f7 e7                	mul    %edi
  802243:	39 d1                	cmp    %edx,%ecx
  802245:	89 c6                	mov    %eax,%esi
  802247:	72 70                	jb     8022b9 <__udivdi3+0x119>
  802249:	39 ca                	cmp    %ecx,%edx
  80224b:	74 5f                	je     8022ac <__udivdi3+0x10c>
  80224d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802250:	31 f6                	xor    %esi,%esi
  802252:	e9 7b ff ff ff       	jmp    8021d2 <__udivdi3+0x32>
  802257:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80225a:	85 c0                	test   %eax,%eax
  80225c:	75 0c                	jne    80226a <__udivdi3+0xca>
  80225e:	b8 01 00 00 00       	mov    $0x1,%eax
  802263:	31 d2                	xor    %edx,%edx
  802265:	f7 75 f4             	divl   -0xc(%ebp)
  802268:	89 c1                	mov    %eax,%ecx
  80226a:	89 f0                	mov    %esi,%eax
  80226c:	89 fa                	mov    %edi,%edx
  80226e:	f7 f1                	div    %ecx
  802270:	89 c6                	mov    %eax,%esi
  802272:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802275:	f7 f1                	div    %ecx
  802277:	89 c1                	mov    %eax,%ecx
  802279:	e9 54 ff ff ff       	jmp    8021d2 <__udivdi3+0x32>
  80227e:	66 90                	xchg   %ax,%ax
  802280:	39 d6                	cmp    %edx,%esi
  802282:	77 1c                	ja     8022a0 <__udivdi3+0x100>
  802284:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802287:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  80228a:	73 14                	jae    8022a0 <__udivdi3+0x100>
  80228c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802290:	31 c9                	xor    %ecx,%ecx
  802292:	31 f6                	xor    %esi,%esi
  802294:	e9 39 ff ff ff       	jmp    8021d2 <__udivdi3+0x32>
  802299:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  8022a0:	b9 01 00 00 00       	mov    $0x1,%ecx
  8022a5:	31 f6                	xor    %esi,%esi
  8022a7:	e9 26 ff ff ff       	jmp    8021d2 <__udivdi3+0x32>
  8022ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8022af:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  8022b3:	d3 e0                	shl    %cl,%eax
  8022b5:	39 c6                	cmp    %eax,%esi
  8022b7:	76 94                	jbe    80224d <__udivdi3+0xad>
  8022b9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8022bc:	31 f6                	xor    %esi,%esi
  8022be:	83 e9 01             	sub    $0x1,%ecx
  8022c1:	e9 0c ff ff ff       	jmp    8021d2 <__udivdi3+0x32>
	...

008022d0 <__umoddi3>:
  8022d0:	55                   	push   %ebp
  8022d1:	89 e5                	mov    %esp,%ebp
  8022d3:	57                   	push   %edi
  8022d4:	56                   	push   %esi
  8022d5:	83 ec 30             	sub    $0x30,%esp
  8022d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8022db:	8b 55 14             	mov    0x14(%ebp),%edx
  8022de:	8b 75 08             	mov    0x8(%ebp),%esi
  8022e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8022e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8022e7:	89 c1                	mov    %eax,%ecx
  8022e9:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8022ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8022ef:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8022f6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8022fd:	89 fa                	mov    %edi,%edx
  8022ff:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  802302:	85 c0                	test   %eax,%eax
  802304:	89 75 f0             	mov    %esi,-0x10(%ebp)
  802307:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80230a:	75 14                	jne    802320 <__umoddi3+0x50>
  80230c:	39 f9                	cmp    %edi,%ecx
  80230e:	76 60                	jbe    802370 <__umoddi3+0xa0>
  802310:	89 f0                	mov    %esi,%eax
  802312:	f7 f1                	div    %ecx
  802314:	89 55 d0             	mov    %edx,-0x30(%ebp)
  802317:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80231e:	eb 10                	jmp    802330 <__umoddi3+0x60>
  802320:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802323:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  802326:	76 18                	jbe    802340 <__umoddi3+0x70>
  802328:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80232b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80232e:	66 90                	xchg   %ax,%ax
  802330:	8b 45 d0             	mov    -0x30(%ebp),%eax
  802333:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802336:	83 c4 30             	add    $0x30,%esp
  802339:	5e                   	pop    %esi
  80233a:	5f                   	pop    %edi
  80233b:	5d                   	pop    %ebp
  80233c:	c3                   	ret    
  80233d:	8d 76 00             	lea    0x0(%esi),%esi
  802340:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
  802344:	83 f0 1f             	xor    $0x1f,%eax
  802347:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80234a:	75 46                	jne    802392 <__umoddi3+0xc2>
  80234c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80234f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  802352:	0f 87 c9 00 00 00    	ja     802421 <__umoddi3+0x151>
  802358:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  80235b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80235e:	0f 83 bd 00 00 00    	jae    802421 <__umoddi3+0x151>
  802364:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802367:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80236a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80236d:	eb c1                	jmp    802330 <__umoddi3+0x60>
  80236f:	90                   	nop    
  802370:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802373:	85 c0                	test   %eax,%eax
  802375:	75 0c                	jne    802383 <__umoddi3+0xb3>
  802377:	b8 01 00 00 00       	mov    $0x1,%eax
  80237c:	31 d2                	xor    %edx,%edx
  80237e:	f7 75 ec             	divl   -0x14(%ebp)
  802381:	89 c1                	mov    %eax,%ecx
  802383:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802386:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802389:	f7 f1                	div    %ecx
  80238b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80238e:	f7 f1                	div    %ecx
  802390:	eb 82                	jmp    802314 <__umoddi3+0x44>
  802392:	b8 20 00 00 00       	mov    $0x20,%eax
  802397:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80239a:	2b 45 d8             	sub    -0x28(%ebp),%eax
  80239d:	8b 75 ec             	mov    -0x14(%ebp),%esi
  8023a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8023a3:	89 c1                	mov    %eax,%ecx
  8023a5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8023a8:	d3 ea                	shr    %cl,%edx
  8023aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8023ad:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8023b1:	d3 e0                	shl    %cl,%eax
  8023b3:	09 c2                	or     %eax,%edx
  8023b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023b8:	d3 e6                	shl    %cl,%esi
  8023ba:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8023be:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8023c1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8023c4:	d3 e8                	shr    %cl,%eax
  8023c6:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8023ca:	d3 e2                	shl    %cl,%edx
  8023cc:	09 d0                	or     %edx,%eax
  8023ce:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8023d1:	d3 e7                	shl    %cl,%edi
  8023d3:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8023d7:	d3 ea                	shr    %cl,%edx
  8023d9:	f7 75 f4             	divl   -0xc(%ebp)
  8023dc:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8023df:	f7 e6                	mul    %esi
  8023e1:	39 55 cc             	cmp    %edx,-0x34(%ebp)
  8023e4:	72 53                	jb     802439 <__umoddi3+0x169>
  8023e6:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  8023e9:	74 4a                	je     802435 <__umoddi3+0x165>
  8023eb:	90                   	nop    
  8023ec:	8d 74 26 00          	lea    0x0(%esi),%esi
  8023f0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8023f3:	29 c7                	sub    %eax,%edi
  8023f5:	19 d1                	sbb    %edx,%ecx
  8023f7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8023fa:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8023fe:	89 fa                	mov    %edi,%edx
  802400:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802403:	d3 ea                	shr    %cl,%edx
  802405:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  802409:	d3 e0                	shl    %cl,%eax
  80240b:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  80240f:	09 c2                	or     %eax,%edx
  802411:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802414:	89 55 d0             	mov    %edx,-0x30(%ebp)
  802417:	d3 e8                	shr    %cl,%eax
  802419:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80241c:	e9 0f ff ff ff       	jmp    802330 <__umoddi3+0x60>
  802421:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802424:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802427:	2b 45 ec             	sub    -0x14(%ebp),%eax
  80242a:	1b 55 e8             	sbb    -0x18(%ebp),%edx
  80242d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802430:	e9 2f ff ff ff       	jmp    802364 <__umoddi3+0x94>
  802435:	39 f8                	cmp    %edi,%eax
  802437:	76 b7                	jbe    8023f0 <__umoddi3+0x120>
  802439:	29 f0                	sub    %esi,%eax
  80243b:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  80243e:	eb b0                	jmp    8023f0 <__umoddi3+0x120>
