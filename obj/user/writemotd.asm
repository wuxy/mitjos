
obj/user/writemotd:     file format elf32-i386

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
  800048:	c7 04 24 a0 24 80 00 	movl   $0x8024a0,(%esp)
  80004f:	e8 0f 1a 00 00       	call   801a63 <open>
  800054:	89 85 f0 fd ff ff    	mov    %eax,0xfffffdf0(%ebp)
  80005a:	85 c0                	test   %eax,%eax
  80005c:	79 20                	jns    80007e <umain+0x4a>
		panic("open /newmotd: %e", rfd);
  80005e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800062:	c7 44 24 08 a9 24 80 	movl   $0x8024a9,0x8(%esp)
  800069:	00 
  80006a:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  800071:	00 
  800072:	c7 04 24 bb 24 80 00 	movl   $0x8024bb,(%esp)
  800079:	e8 3e 02 00 00       	call   8002bc <_panic>
	if ((wfd = open("/motd", O_RDWR)) < 0)
  80007e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  800085:	00 
  800086:	c7 04 24 cc 24 80 00 	movl   $0x8024cc,(%esp)
  80008d:	e8 d1 19 00 00       	call   801a63 <open>
  800092:	89 c7                	mov    %eax,%edi
  800094:	85 c0                	test   %eax,%eax
  800096:	79 20                	jns    8000b8 <umain+0x84>
		panic("open /motd: %e", wfd);
  800098:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80009c:	c7 44 24 08 d2 24 80 	movl   $0x8024d2,0x8(%esp)
  8000a3:	00 
  8000a4:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  8000ab:	00 
  8000ac:	c7 04 24 bb 24 80 00 	movl   $0x8024bb,(%esp)
  8000b3:	e8 04 02 00 00       	call   8002bc <_panic>
	cprintf("file descriptors %d %d\n", rfd, wfd);
  8000b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000bc:	8b 85 f0 fd ff ff    	mov    0xfffffdf0(%ebp),%eax
  8000c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000c6:	c7 04 24 e1 24 80 00 	movl   $0x8024e1,(%esp)
  8000cd:	e8 b7 02 00 00       	call   800389 <cprintf>
	if (rfd == wfd)
  8000d2:	39 bd f0 fd ff ff    	cmp    %edi,0xfffffdf0(%ebp)
  8000d8:	75 1c                	jne    8000f6 <umain+0xc2>
		panic("open /newmotd and /motd give same file descriptor");
  8000da:	c7 44 24 08 4c 25 80 	movl   $0x80254c,0x8(%esp)
  8000e1:	00 
  8000e2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  8000e9:	00 
  8000ea:	c7 04 24 bb 24 80 00 	movl   $0x8024bb,(%esp)
  8000f1:	e8 c6 01 00 00       	call   8002bc <_panic>

	cprintf("OLD MOTD\n===\n");
  8000f6:	c7 04 24 f9 24 80 00 	movl   $0x8024f9,(%esp)
  8000fd:	e8 87 02 00 00       	call   800389 <cprintf>
  800102:	8d 9d f4 fd ff ff    	lea    0xfffffdf4(%ebp),%ebx
  800108:	eb 0c                	jmp    800116 <umain+0xe2>
	while ((n = read(wfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
  80010a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80010e:	89 1c 24             	mov    %ebx,(%esp)
  800111:	e8 52 0d 00 00       	call   800e68 <sys_cputs>
  800116:	c7 44 24 08 ff 01 00 	movl   $0x1ff,0x8(%esp)
  80011d:	00 
  80011e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800122:	89 3c 24             	mov    %edi,(%esp)
  800125:	e8 23 14 00 00       	call   80154d <read>
  80012a:	85 c0                	test   %eax,%eax
  80012c:	7f dc                	jg     80010a <umain+0xd6>
	cprintf("===\n");
  80012e:	c7 04 24 02 25 80 00 	movl   $0x802502,(%esp)
  800135:	e8 4f 02 00 00       	call   800389 <cprintf>
	seek(wfd, 0);
  80013a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800141:	00 
  800142:	89 3c 24             	mov    %edi,(%esp)
  800145:	e8 db 11 00 00       	call   801325 <seek>

	if ((r = ftruncate(wfd, 0)) < 0)
  80014a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800151:	00 
  800152:	89 3c 24             	mov    %edi,(%esp)
  800155:	e8 e4 12 00 00       	call   80143e <ftruncate>
  80015a:	85 c0                	test   %eax,%eax
  80015c:	79 20                	jns    80017e <umain+0x14a>
		panic("truncate /motd: %e", r);
  80015e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800162:	c7 44 24 08 07 25 80 	movl   $0x802507,0x8(%esp)
  800169:	00 
  80016a:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  800171:	00 
  800172:	c7 04 24 bb 24 80 00 	movl   $0x8024bb,(%esp)
  800179:	e8 3e 01 00 00       	call   8002bc <_panic>

	cprintf("NEW MOTD\n===\n");
  80017e:	c7 04 24 1a 25 80 00 	movl   $0x80251a,(%esp)
  800185:	e8 ff 01 00 00       	call   800389 <cprintf>
  80018a:	8d b5 f4 fd ff ff    	lea    0xfffffdf4(%ebp),%esi
  800190:	eb 40                	jmp    8001d2 <umain+0x19e>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0) {
		sys_cputs(buf, n);
  800192:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800196:	89 34 24             	mov    %esi,(%esp)
  800199:	e8 ca 0c 00 00       	call   800e68 <sys_cputs>
		if ((r = write(wfd, buf, n)) != n)
  80019e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a6:	89 3c 24             	mov    %edi,(%esp)
  8001a9:	e8 14 13 00 00       	call   8014c2 <write>
  8001ae:	39 c3                	cmp    %eax,%ebx
  8001b0:	74 20                	je     8001d2 <umain+0x19e>
			panic("write /motd: %e", r);
  8001b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b6:	c7 44 24 08 28 25 80 	movl   $0x802528,0x8(%esp)
  8001bd:	00 
  8001be:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  8001c5:	00 
  8001c6:	c7 04 24 bb 24 80 00 	movl   $0x8024bb,(%esp)
  8001cd:	e8 ea 00 00 00       	call   8002bc <_panic>
  8001d2:	c7 44 24 08 ff 01 00 	movl   $0x1ff,0x8(%esp)
  8001d9:	00 
  8001da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001de:	8b 85 f0 fd ff ff    	mov    0xfffffdf0(%ebp),%eax
  8001e4:	89 04 24             	mov    %eax,(%esp)
  8001e7:	e8 61 13 00 00       	call   80154d <read>
  8001ec:	89 c3                	mov    %eax,%ebx
  8001ee:	85 c0                	test   %eax,%eax
  8001f0:	7f a0                	jg     800192 <umain+0x15e>
	}
	cprintf("===\n");
  8001f2:	c7 04 24 02 25 80 00 	movl   $0x802502,(%esp)
  8001f9:	e8 8b 01 00 00       	call   800389 <cprintf>

	if (n < 0)
  8001fe:	85 db                	test   %ebx,%ebx
  800200:	79 20                	jns    800222 <umain+0x1ee>
		panic("read /newmotd: %e", n);
  800202:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800206:	c7 44 24 08 38 25 80 	movl   $0x802538,0x8(%esp)
  80020d:	00 
  80020e:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800215:	00 
  800216:	c7 04 24 bb 24 80 00 	movl   $0x8024bb,(%esp)
  80021d:	e8 9a 00 00 00       	call   8002bc <_panic>

	close(rfd);
  800222:	8b 85 f0 fd ff ff    	mov    0xfffffdf0(%ebp),%eax
  800228:	89 04 24             	mov    %eax,(%esp)
  80022b:	e8 8b 14 00 00       	call   8016bb <close>
	close(wfd);
  800230:	89 3c 24             	mov    %edi,(%esp)
  800233:	e8 83 14 00 00       	call   8016bb <close>
}
  800238:	81 c4 1c 02 00 00    	add    $0x21c,%esp
  80023e:	5b                   	pop    %ebx
  80023f:	5e                   	pop    %esi
  800240:	5f                   	pop    %edi
  800241:	5d                   	pop    %ebp
  800242:	c3                   	ret    
	...

00800244 <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	83 ec 18             	sub    $0x18,%esp
  80024a:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  80024d:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  800250:	8b 75 08             	mov    0x8(%ebp),%esi
  800253:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  800256:	c7 05 3c 60 80 00 00 	movl   $0x0,0x80603c
  80025d:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  800260:	e8 68 0f 00 00       	call   8011cd <sys_getenvid>
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

	// call user main routine调用用户主例程
	umain(argc, argv);
  800282:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800286:	89 34 24             	mov    %esi,(%esp)
  800289:	e8 a6 fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80028e:	e8 0d 00 00 00       	call   8002a0 <exit>
}
  800293:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  800296:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
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
  8002a6:	e8 ab 15 00 00       	call   801856 <close_all>
	sys_env_destroy(0);
  8002ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002b2:	e8 4a 0f 00 00       	call   801201 <sys_env_destroy>
}
  8002b7:	c9                   	leave  
  8002b8:	c3                   	ret    
  8002b9:	00 00                	add    %al,(%eax)
	...

008002bc <_panic>:
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
  8002c5:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)

	// Print the panic message
	if (argv0)
  8002c8:	a1 40 60 80 00       	mov    0x806040,%eax
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	74 10                	je     8002e1 <_panic+0x25>
		cprintf("%s: ", argv0);
  8002d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d5:	c7 04 24 95 25 80 00 	movl   $0x802595,(%esp)
  8002dc:	e8 a8 00 00 00       	call   800389 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8002e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ef:	a1 00 60 80 00       	mov    0x806000,%eax
  8002f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f8:	c7 04 24 9a 25 80 00 	movl   $0x80259a,(%esp)
  8002ff:	e8 85 00 00 00       	call   800389 <cprintf>
	vcprintf(fmt, ap);
  800304:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  800307:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030b:	8b 45 10             	mov    0x10(%ebp),%eax
  80030e:	89 04 24             	mov    %eax,(%esp)
  800311:	e8 12 00 00 00       	call   800328 <vcprintf>
	cprintf("\n");
  800316:	c7 04 24 05 25 80 00 	movl   $0x802505,(%esp)
  80031d:	e8 67 00 00 00       	call   800389 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800322:	cc                   	int3   
  800323:	eb fd                	jmp    800322 <_panic+0x66>
  800325:	00 00                	add    %al,(%eax)
	...

00800328 <vcprintf>:
}

int
vcprintf(const char *fmt, va_list ap)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800331:	c7 85 f8 fe ff ff 00 	movl   $0x0,0xfffffef8(%ebp)
  800338:	00 00 00 
	b.cnt = 0;
  80033b:	c7 85 fc fe ff ff 00 	movl   $0x0,0xfffffefc(%ebp)
  800342:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800345:	8b 45 0c             	mov    0xc(%ebp),%eax
  800348:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80034c:	8b 45 08             	mov    0x8(%ebp),%eax
  80034f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800353:	8d 85 f8 fe ff ff    	lea    0xfffffef8(%ebp),%eax
  800359:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035d:	c7 04 24 a6 03 80 00 	movl   $0x8003a6,(%esp)
  800364:	e8 c8 01 00 00       	call   800531 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800369:	8b 85 f8 fe ff ff    	mov    0xfffffef8(%ebp),%eax
  80036f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800373:	8d 85 00 ff ff ff    	lea    0xffffff00(%ebp),%eax
  800379:	89 04 24             	mov    %eax,(%esp)
  80037c:	e8 e7 0a 00 00       	call   800e68 <sys_cputs>
  800381:	8b 85 fc fe ff ff    	mov    0xfffffefc(%ebp),%eax

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
  800392:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
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
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	53                   	push   %ebx
  8003aa:	83 ec 14             	sub    $0x14,%esp
  8003ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b0:	8b 03                	mov    (%ebx),%eax
  8003b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b5:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003b9:	83 c0 01             	add    $0x1,%eax
  8003bc:	89 03                	mov    %eax,(%ebx)
  8003be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003c3:	75 19                	jne    8003de <putch+0x38>
  8003c5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003cc:	00 
  8003cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8003d0:	89 04 24             	mov    %eax,(%esp)
  8003d3:	e8 90 0a 00 00       	call   800e68 <sys_cputs>
  8003d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003de:	83 43 04 01          	addl   $0x1,0x4(%ebx)
  8003e2:	83 c4 14             	add    $0x14,%esp
  8003e5:	5b                   	pop    %ebx
  8003e6:	5d                   	pop    %ebp
  8003e7:	c3                   	ret    
	...

008003f0 <printnum>:
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
  8003f9:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8003fc:	89 d7                	mov    %edx,%edi
  8003fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800401:	8b 55 0c             	mov    0xc(%ebp),%edx
  800404:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800407:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  80040a:	8b 55 10             	mov    0x10(%ebp),%edx
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800413:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  800416:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  80041d:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800420:	39 4d ec             	cmp    %ecx,0xffffffec(%ebp)
  800423:	72 11                	jb     800436 <printnum+0x46>
  800425:	8b 4d d8             	mov    0xffffffd8(%ebp),%ecx
  800428:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  80042b:	76 09                	jbe    800436 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80042d:	8d 58 ff             	lea    0xffffffff(%eax),%ebx
  800430:	85 db                	test   %ebx,%ebx
  800432:	7f 54                	jg     800488 <printnum+0x98>
  800434:	eb 61                	jmp    800497 <printnum+0xa7>
  800436:	89 74 24 10          	mov    %esi,0x10(%esp)
  80043a:	83 e8 01             	sub    $0x1,%eax
  80043d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800441:	89 54 24 08          	mov    %edx,0x8(%esp)
  800445:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800449:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80044d:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800450:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800453:	89 44 24 08          	mov    %eax,0x8(%esp)
  800457:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80045b:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  80045e:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800461:	89 14 24             	mov    %edx,(%esp)
  800464:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800468:	e8 73 1d 00 00       	call   8021e0 <__udivdi3>
  80046d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800471:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800475:	89 04 24             	mov    %eax,(%esp)
  800478:	89 54 24 04          	mov    %edx,0x4(%esp)
  80047c:	89 fa                	mov    %edi,%edx
  80047e:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  800481:	e8 6a ff ff ff       	call   8003f0 <printnum>
  800486:	eb 0f                	jmp    800497 <printnum+0xa7>
			putch(padc, putdat);
  800488:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80048c:	89 34 24             	mov    %esi,(%esp)
  80048f:	ff 55 e4             	call   *0xffffffe4(%ebp)
  800492:	83 eb 01             	sub    $0x1,%ebx
  800495:	75 f1                	jne    800488 <printnum+0x98>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800497:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80049b:	8b 74 24 04          	mov    0x4(%esp),%esi
  80049f:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8004a2:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  8004a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004a9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004ad:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  8004b0:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  8004b3:	89 14 24             	mov    %edx,(%esp)
  8004b6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004ba:	e8 51 1e 00 00       	call   802310 <__umoddi3>
  8004bf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004c3:	0f be 80 b6 25 80 00 	movsbl 0x8025b6(%eax),%eax
  8004ca:	89 04 24             	mov    %eax,(%esp)
  8004cd:	ff 55 e4             	call   *0xffffffe4(%ebp)
}
  8004d0:	83 c4 3c             	add    $0x3c,%esp
  8004d3:	5b                   	pop    %ebx
  8004d4:	5e                   	pop    %esi
  8004d5:	5f                   	pop    %edi
  8004d6:	5d                   	pop    %ebp
  8004d7:	c3                   	ret    

008004d8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004d8:	55                   	push   %ebp
  8004d9:	89 e5                	mov    %esp,%ebp
  8004db:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8004dd:	83 fa 01             	cmp    $0x1,%edx
  8004e0:	7e 0e                	jle    8004f0 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8004e2:	8b 10                	mov    (%eax),%edx
  8004e4:	8d 42 08             	lea    0x8(%edx),%eax
  8004e7:	89 01                	mov    %eax,(%ecx)
  8004e9:	8b 02                	mov    (%edx),%eax
  8004eb:	8b 52 04             	mov    0x4(%edx),%edx
  8004ee:	eb 22                	jmp    800512 <getuint+0x3a>
	else if (lflag)
  8004f0:	85 d2                	test   %edx,%edx
  8004f2:	74 10                	je     800504 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8004f4:	8b 10                	mov    (%eax),%edx
  8004f6:	8d 42 04             	lea    0x4(%edx),%eax
  8004f9:	89 01                	mov    %eax,(%ecx)
  8004fb:	8b 02                	mov    (%edx),%eax
  8004fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800502:	eb 0e                	jmp    800512 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800504:	8b 10                	mov    (%eax),%edx
  800506:	8d 42 04             	lea    0x4(%edx),%eax
  800509:	89 01                	mov    %eax,(%ecx)
  80050b:	8b 02                	mov    (%edx),%eax
  80050d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800512:	5d                   	pop    %ebp
  800513:	c3                   	ret    

00800514 <sprintputch>:

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
  800514:	55                   	push   %ebp
  800515:	89 e5                	mov    %esp,%ebp
  800517:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  80051a:	83 41 08 01          	addl   $0x1,0x8(%ecx)
	if (b->buf < b->ebuf)
  80051e:	8b 11                	mov    (%ecx),%edx
  800520:	3b 51 04             	cmp    0x4(%ecx),%edx
  800523:	73 0a                	jae    80052f <sprintputch+0x1b>
		*b->buf++ = ch;
  800525:	8b 45 08             	mov    0x8(%ebp),%eax
  800528:	88 02                	mov    %al,(%edx)
  80052a:	8d 42 01             	lea    0x1(%edx),%eax
  80052d:	89 01                	mov    %eax,(%ecx)
}
  80052f:	5d                   	pop    %ebp
  800530:	c3                   	ret    

00800531 <vprintfmt>:
  800531:	55                   	push   %ebp
  800532:	89 e5                	mov    %esp,%ebp
  800534:	57                   	push   %edi
  800535:	56                   	push   %esi
  800536:	53                   	push   %ebx
  800537:	83 ec 4c             	sub    $0x4c,%esp
  80053a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80053d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800540:	eb 03                	jmp    800545 <vprintfmt+0x14>
  800542:	8b 5d e8             	mov    0xffffffe8(%ebp),%ebx
  800545:	0f b6 03             	movzbl (%ebx),%eax
  800548:	83 c3 01             	add    $0x1,%ebx
  80054b:	3c 25                	cmp    $0x25,%al
  80054d:	74 30                	je     80057f <vprintfmt+0x4e>
  80054f:	84 c0                	test   %al,%al
  800551:	0f 84 a8 03 00 00    	je     8008ff <vprintfmt+0x3ce>
  800557:	0f b6 d0             	movzbl %al,%edx
  80055a:	eb 0a                	jmp    800566 <vprintfmt+0x35>
  80055c:	84 c0                	test   %al,%al
  80055e:	66 90                	xchg   %ax,%ax
  800560:	0f 84 99 03 00 00    	je     8008ff <vprintfmt+0x3ce>
  800566:	8b 45 0c             	mov    0xc(%ebp),%eax
  800569:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056d:	89 14 24             	mov    %edx,(%esp)
  800570:	ff d7                	call   *%edi
  800572:	0f b6 03             	movzbl (%ebx),%eax
  800575:	0f b6 d0             	movzbl %al,%edx
  800578:	83 c3 01             	add    $0x1,%ebx
  80057b:	3c 25                	cmp    $0x25,%al
  80057d:	75 dd                	jne    80055c <vprintfmt+0x2b>
  80057f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800584:	c7 45 ec ff ff ff ff 	movl   $0xffffffff,0xffffffec(%ebp)
  80058b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  800592:	c7 45 dc 00 00 00 00 	movl   $0x0,0xffffffdc(%ebp)
  800599:	c6 45 e3 20          	movb   $0x20,0xffffffe3(%ebp)
  80059d:	eb 07                	jmp    8005a6 <vprintfmt+0x75>
  80059f:	c7 45 dc 01 00 00 00 	movl   $0x1,0xffffffdc(%ebp)
  8005a6:	0f b6 03             	movzbl (%ebx),%eax
  8005a9:	0f b6 d0             	movzbl %al,%edx
  8005ac:	83 c3 01             	add    $0x1,%ebx
  8005af:	83 e8 23             	sub    $0x23,%eax
  8005b2:	3c 55                	cmp    $0x55,%al
  8005b4:	0f 87 11 03 00 00    	ja     8008cb <vprintfmt+0x39a>
  8005ba:	0f b6 c0             	movzbl %al,%eax
  8005bd:	ff 24 85 00 27 80 00 	jmp    *0x802700(,%eax,4)
  8005c4:	c6 45 e3 30          	movb   $0x30,0xffffffe3(%ebp)
  8005c8:	eb dc                	jmp    8005a6 <vprintfmt+0x75>
  8005ca:	83 ea 30             	sub    $0x30,%edx
  8005cd:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  8005d0:	0f be 13             	movsbl (%ebx),%edx
  8005d3:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  8005d6:	83 f8 09             	cmp    $0x9,%eax
  8005d9:	76 08                	jbe    8005e3 <vprintfmt+0xb2>
  8005db:	eb 42                	jmp    80061f <vprintfmt+0xee>
  8005dd:	c6 45 e3 2d          	movb   $0x2d,0xffffffe3(%ebp)
  8005e1:	eb c3                	jmp    8005a6 <vprintfmt+0x75>
  8005e3:	83 c3 01             	add    $0x1,%ebx
  8005e6:	8b 75 e4             	mov    0xffffffe4(%ebp),%esi
  8005e9:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8005ec:	8d 44 42 d0          	lea    0xffffffd0(%edx,%eax,2),%eax
  8005f0:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8005f3:	0f be 13             	movsbl (%ebx),%edx
  8005f6:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  8005f9:	83 f8 09             	cmp    $0x9,%eax
  8005fc:	77 21                	ja     80061f <vprintfmt+0xee>
  8005fe:	eb e3                	jmp    8005e3 <vprintfmt+0xb2>
  800600:	8b 55 14             	mov    0x14(%ebp),%edx
  800603:	8d 42 04             	lea    0x4(%edx),%eax
  800606:	89 45 14             	mov    %eax,0x14(%ebp)
  800609:	8b 12                	mov    (%edx),%edx
  80060b:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  80060e:	eb 0f                	jmp    80061f <vprintfmt+0xee>
  800610:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800614:	79 90                	jns    8005a6 <vprintfmt+0x75>
  800616:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  80061d:	eb 87                	jmp    8005a6 <vprintfmt+0x75>
  80061f:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800623:	79 81                	jns    8005a6 <vprintfmt+0x75>
  800625:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  800628:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  80062b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  800632:	e9 6f ff ff ff       	jmp    8005a6 <vprintfmt+0x75>
  800637:	83 c1 01             	add    $0x1,%ecx
  80063a:	e9 67 ff ff ff       	jmp    8005a6 <vprintfmt+0x75>
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8d 50 04             	lea    0x4(%eax),%edx
  800645:	89 55 14             	mov    %edx,0x14(%ebp)
  800648:	8b 55 0c             	mov    0xc(%ebp),%edx
  80064b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80064f:	8b 00                	mov    (%eax),%eax
  800651:	89 04 24             	mov    %eax,(%esp)
  800654:	ff d7                	call   *%edi
  800656:	e9 ea fe ff ff       	jmp    800545 <vprintfmt+0x14>
  80065b:	8b 55 14             	mov    0x14(%ebp),%edx
  80065e:	8d 42 04             	lea    0x4(%edx),%eax
  800661:	89 45 14             	mov    %eax,0x14(%ebp)
  800664:	8b 02                	mov    (%edx),%eax
  800666:	89 c2                	mov    %eax,%edx
  800668:	c1 fa 1f             	sar    $0x1f,%edx
  80066b:	31 d0                	xor    %edx,%eax
  80066d:	29 d0                	sub    %edx,%eax
  80066f:	83 f8 0f             	cmp    $0xf,%eax
  800672:	7f 0b                	jg     80067f <vprintfmt+0x14e>
  800674:	8b 14 85 60 28 80 00 	mov    0x802860(,%eax,4),%edx
  80067b:	85 d2                	test   %edx,%edx
  80067d:	75 20                	jne    80069f <vprintfmt+0x16e>
  80067f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800683:	c7 44 24 08 c7 25 80 	movl   $0x8025c7,0x8(%esp)
  80068a:	00 
  80068b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80068e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800692:	89 3c 24             	mov    %edi,(%esp)
  800695:	e8 f0 02 00 00       	call   80098a <printfmt>
  80069a:	e9 a6 fe ff ff       	jmp    800545 <vprintfmt+0x14>
  80069f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006a3:	c7 44 24 08 a2 29 80 	movl   $0x8029a2,0x8(%esp)
  8006aa:	00 
  8006ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b2:	89 3c 24             	mov    %edi,(%esp)
  8006b5:	e8 d0 02 00 00       	call   80098a <printfmt>
  8006ba:	e9 86 fe ff ff       	jmp    800545 <vprintfmt+0x14>
  8006bf:	8b 75 ec             	mov    0xffffffec(%ebp),%esi
  8006c2:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  8006c5:	89 5d e8             	mov    %ebx,0xffffffe8(%ebp)
  8006c8:	8b 55 14             	mov    0x14(%ebp),%edx
  8006cb:	8d 42 04             	lea    0x4(%edx),%eax
  8006ce:	89 45 14             	mov    %eax,0x14(%ebp)
  8006d1:	8b 12                	mov    (%edx),%edx
  8006d3:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  8006d6:	85 d2                	test   %edx,%edx
  8006d8:	75 07                	jne    8006e1 <vprintfmt+0x1b0>
  8006da:	c7 45 d8 d0 25 80 00 	movl   $0x8025d0,0xffffffd8(%ebp)
  8006e1:	85 f6                	test   %esi,%esi
  8006e3:	7e 40                	jle    800725 <vprintfmt+0x1f4>
  8006e5:	80 7d e3 2d          	cmpb   $0x2d,0xffffffe3(%ebp)
  8006e9:	74 3a                	je     800725 <vprintfmt+0x1f4>
  8006eb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006ef:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  8006f2:	89 14 24             	mov    %edx,(%esp)
  8006f5:	e8 e6 02 00 00       	call   8009e0 <strnlen>
  8006fa:	29 c6                	sub    %eax,%esi
  8006fc:	89 75 ec             	mov    %esi,0xffffffec(%ebp)
  8006ff:	85 f6                	test   %esi,%esi
  800701:	7e 22                	jle    800725 <vprintfmt+0x1f4>
  800703:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  800707:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  80070a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80070d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800711:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  800714:	89 04 24             	mov    %eax,(%esp)
  800717:	ff d7                	call   *%edi
  800719:	83 ee 01             	sub    $0x1,%esi
  80071c:	75 ec                	jne    80070a <vprintfmt+0x1d9>
  80071e:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  800725:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800728:	0f b6 02             	movzbl (%edx),%eax
  80072b:	0f be d0             	movsbl %al,%edx
  80072e:	8b 75 d8             	mov    0xffffffd8(%ebp),%esi
  800731:	84 c0                	test   %al,%al
  800733:	75 40                	jne    800775 <vprintfmt+0x244>
  800735:	eb 4a                	jmp    800781 <vprintfmt+0x250>
  800737:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
  80073b:	74 1a                	je     800757 <vprintfmt+0x226>
  80073d:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  800740:	83 f8 5e             	cmp    $0x5e,%eax
  800743:	76 12                	jbe    800757 <vprintfmt+0x226>
  800745:	8b 45 0c             	mov    0xc(%ebp),%eax
  800748:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800753:	ff d7                	call   *%edi
  800755:	eb 0c                	jmp    800763 <vprintfmt+0x232>
  800757:	8b 45 0c             	mov    0xc(%ebp),%eax
  80075a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075e:	89 14 24             	mov    %edx,(%esp)
  800761:	ff d7                	call   *%edi
  800763:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  800767:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80076b:	83 c6 01             	add    $0x1,%esi
  80076e:	84 c0                	test   %al,%al
  800770:	74 0f                	je     800781 <vprintfmt+0x250>
  800772:	0f be d0             	movsbl %al,%edx
  800775:	83 7d e4 00          	cmpl   $0x0,0xffffffe4(%ebp)
  800779:	78 bc                	js     800737 <vprintfmt+0x206>
  80077b:	83 6d e4 01          	subl   $0x1,0xffffffe4(%ebp)
  80077f:	79 b6                	jns    800737 <vprintfmt+0x206>
  800781:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800785:	0f 8e ba fd ff ff    	jle    800545 <vprintfmt+0x14>
  80078b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800792:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800799:	ff d7                	call   *%edi
  80079b:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  80079f:	0f 84 9d fd ff ff    	je     800542 <vprintfmt+0x11>
  8007a5:	eb e4                	jmp    80078b <vprintfmt+0x25a>
  8007a7:	83 f9 01             	cmp    $0x1,%ecx
  8007aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8007b0:	7e 10                	jle    8007c2 <vprintfmt+0x291>
  8007b2:	8b 55 14             	mov    0x14(%ebp),%edx
  8007b5:	8d 42 08             	lea    0x8(%edx),%eax
  8007b8:	89 45 14             	mov    %eax,0x14(%ebp)
  8007bb:	8b 02                	mov    (%edx),%eax
  8007bd:	8b 52 04             	mov    0x4(%edx),%edx
  8007c0:	eb 26                	jmp    8007e8 <vprintfmt+0x2b7>
  8007c2:	85 c9                	test   %ecx,%ecx
  8007c4:	74 12                	je     8007d8 <vprintfmt+0x2a7>
  8007c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c9:	8d 50 04             	lea    0x4(%eax),%edx
  8007cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8007cf:	8b 00                	mov    (%eax),%eax
  8007d1:	89 c2                	mov    %eax,%edx
  8007d3:	c1 fa 1f             	sar    $0x1f,%edx
  8007d6:	eb 10                	jmp    8007e8 <vprintfmt+0x2b7>
  8007d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007db:	8d 50 04             	lea    0x4(%eax),%edx
  8007de:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e1:	8b 00                	mov    (%eax),%eax
  8007e3:	89 c2                	mov    %eax,%edx
  8007e5:	c1 fa 1f             	sar    $0x1f,%edx
  8007e8:	89 d1                	mov    %edx,%ecx
  8007ea:	89 c2                	mov    %eax,%edx
  8007ec:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  8007ef:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  8007f2:	be 0a 00 00 00       	mov    $0xa,%esi
  8007f7:	85 c9                	test   %ecx,%ecx
  8007f9:	0f 89 92 00 00 00    	jns    800891 <vprintfmt+0x360>
  8007ff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800802:	89 74 24 04          	mov    %esi,0x4(%esp)
  800806:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80080d:	ff d7                	call   *%edi
  80080f:	8b 55 d0             	mov    0xffffffd0(%ebp),%edx
  800812:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  800815:	f7 da                	neg    %edx
  800817:	83 d1 00             	adc    $0x0,%ecx
  80081a:	f7 d9                	neg    %ecx
  80081c:	be 0a 00 00 00       	mov    $0xa,%esi
  800821:	eb 6e                	jmp    800891 <vprintfmt+0x360>
  800823:	8d 45 14             	lea    0x14(%ebp),%eax
  800826:	89 ca                	mov    %ecx,%edx
  800828:	e8 ab fc ff ff       	call   8004d8 <getuint>
  80082d:	89 d1                	mov    %edx,%ecx
  80082f:	89 c2                	mov    %eax,%edx
  800831:	be 0a 00 00 00       	mov    $0xa,%esi
  800836:	eb 59                	jmp    800891 <vprintfmt+0x360>
  800838:	8d 45 14             	lea    0x14(%ebp),%eax
  80083b:	89 ca                	mov    %ecx,%edx
  80083d:	e8 96 fc ff ff       	call   8004d8 <getuint>
  800842:	e9 fe fc ff ff       	jmp    800545 <vprintfmt+0x14>
  800847:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800855:	ff d7                	call   *%edi
  800857:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80085e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800865:	ff d7                	call   *%edi
  800867:	8b 55 14             	mov    0x14(%ebp),%edx
  80086a:	8d 42 04             	lea    0x4(%edx),%eax
  80086d:	89 45 14             	mov    %eax,0x14(%ebp)
  800870:	8b 12                	mov    (%edx),%edx
  800872:	b9 00 00 00 00       	mov    $0x0,%ecx
  800877:	be 10 00 00 00       	mov    $0x10,%esi
  80087c:	eb 13                	jmp    800891 <vprintfmt+0x360>
  80087e:	8d 45 14             	lea    0x14(%ebp),%eax
  800881:	89 ca                	mov    %ecx,%edx
  800883:	e8 50 fc ff ff       	call   8004d8 <getuint>
  800888:	89 d1                	mov    %edx,%ecx
  80088a:	89 c2                	mov    %eax,%edx
  80088c:	be 10 00 00 00       	mov    $0x10,%esi
  800891:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  800895:	89 44 24 10          	mov    %eax,0x10(%esp)
  800899:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  80089c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008a0:	89 74 24 08          	mov    %esi,0x8(%esp)
  8008a4:	89 14 24             	mov    %edx,(%esp)
  8008a7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ae:	89 f8                	mov    %edi,%eax
  8008b0:	e8 3b fb ff ff       	call   8003f0 <printnum>
  8008b5:	e9 8b fc ff ff       	jmp    800545 <vprintfmt+0x14>
  8008ba:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008c1:	89 14 24             	mov    %edx,(%esp)
  8008c4:	ff d7                	call   *%edi
  8008c6:	e9 7a fc ff ff       	jmp    800545 <vprintfmt+0x14>
  8008cb:	89 de                	mov    %ebx,%esi
  8008cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008db:	ff d7                	call   *%edi
  8008dd:	83 eb 01             	sub    $0x1,%ebx
  8008e0:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  8008e4:	0f 84 5b fc ff ff    	je     800545 <vprintfmt+0x14>
  8008ea:	8d 56 fd             	lea    0xfffffffd(%esi),%edx
  8008ed:	0f b6 02             	movzbl (%edx),%eax
  8008f0:	83 ea 01             	sub    $0x1,%edx
  8008f3:	3c 25                	cmp    $0x25,%al
  8008f5:	75 f6                	jne    8008ed <vprintfmt+0x3bc>
  8008f7:	8d 5a 02             	lea    0x2(%edx),%ebx
  8008fa:	e9 46 fc ff ff       	jmp    800545 <vprintfmt+0x14>
  8008ff:	83 c4 4c             	add    $0x4c,%esp
  800902:	5b                   	pop    %ebx
  800903:	5e                   	pop    %esi
  800904:	5f                   	pop    %edi
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	83 ec 28             	sub    $0x28,%esp
  80090d:	8b 55 08             	mov    0x8(%ebp),%edx
  800910:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800913:	85 d2                	test   %edx,%edx
  800915:	74 04                	je     80091b <vsnprintf+0x14>
  800917:	85 c0                	test   %eax,%eax
  800919:	7f 07                	jg     800922 <vsnprintf+0x1b>
  80091b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800920:	eb 3b                	jmp    80095d <vsnprintf+0x56>
  800922:	c7 45 fc 00 00 00 00 	movl   $0x0,0xfffffffc(%ebp)
  800929:	8d 44 02 ff          	lea    0xffffffff(%edx,%eax,1),%eax
  80092d:	89 45 f8             	mov    %eax,0xfffffff8(%ebp)
  800930:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800933:	8b 45 14             	mov    0x14(%ebp),%eax
  800936:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80093a:	8b 45 10             	mov    0x10(%ebp),%eax
  80093d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800941:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  800944:	89 44 24 04          	mov    %eax,0x4(%esp)
  800948:	c7 04 24 14 05 80 00 	movl   $0x800514,(%esp)
  80094f:	e8 dd fb ff ff       	call   800531 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800954:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  800957:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80095a:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
}
  80095d:	c9                   	leave  
  80095e:	c3                   	ret    

0080095f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800965:	8d 45 14             	lea    0x14(%ebp),%eax
  800968:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  80096b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80096f:	8b 45 10             	mov    0x10(%ebp),%eax
  800972:	89 44 24 08          	mov    %eax,0x8(%esp)
  800976:	8b 45 0c             	mov    0xc(%ebp),%eax
  800979:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	89 04 24             	mov    %eax,(%esp)
  800983:	e8 7f ff ff ff       	call   800907 <vsnprintf>
	va_end(ap);

	return rc;
}
  800988:	c9                   	leave  
  800989:	c3                   	ret    

0080098a <printfmt>:
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	83 ec 28             	sub    $0x28,%esp
  800990:	8d 45 14             	lea    0x14(%ebp),%eax
  800993:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
  800996:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80099a:	8b 45 10             	mov    0x10(%ebp),%eax
  80099d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	89 04 24             	mov    %eax,(%esp)
  8009ae:	e8 7e fb ff ff       	call   800531 <vprintfmt>
  8009b3:	c9                   	leave  
  8009b4:	c3                   	ret    
	...

008009c0 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cb:	80 3a 00             	cmpb   $0x0,(%edx)
  8009ce:	74 0e                	je     8009de <strlen+0x1e>
  8009d0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009d5:	83 c0 01             	add    $0x1,%eax
  8009d8:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8009dc:	75 f7                	jne    8009d5 <strlen+0x15>
	return n;
}
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e9:	85 d2                	test   %edx,%edx
  8009eb:	74 19                	je     800a06 <strnlen+0x26>
  8009ed:	80 39 00             	cmpb   $0x0,(%ecx)
  8009f0:	74 14                	je     800a06 <strnlen+0x26>
  8009f2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009f7:	83 c0 01             	add    $0x1,%eax
  8009fa:	39 d0                	cmp    %edx,%eax
  8009fc:	74 0d                	je     800a0b <strnlen+0x2b>
  8009fe:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800a02:	74 07                	je     800a0b <strnlen+0x2b>
  800a04:	eb f1                	jmp    8009f7 <strnlen+0x17>
  800a06:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800a0b:	5d                   	pop    %ebp
  800a0c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800a10:	c3                   	ret    

00800a11 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	53                   	push   %ebx
  800a15:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1b:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a1d:	0f b6 01             	movzbl (%ecx),%eax
  800a20:	88 02                	mov    %al,(%edx)
  800a22:	83 c2 01             	add    $0x1,%edx
  800a25:	83 c1 01             	add    $0x1,%ecx
  800a28:	84 c0                	test   %al,%al
  800a2a:	75 f1                	jne    800a1d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a2c:	89 d8                	mov    %ebx,%eax
  800a2e:	5b                   	pop    %ebx
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	57                   	push   %edi
  800a35:	56                   	push   %esi
  800a36:	53                   	push   %ebx
  800a37:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a40:	85 f6                	test   %esi,%esi
  800a42:	74 1c                	je     800a60 <strncpy+0x2f>
  800a44:	89 fa                	mov    %edi,%edx
  800a46:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  800a4b:	0f b6 01             	movzbl (%ecx),%eax
  800a4e:	88 02                	mov    %al,(%edx)
  800a50:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a53:	80 39 01             	cmpb   $0x1,(%ecx)
  800a56:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800a59:	83 c3 01             	add    $0x1,%ebx
  800a5c:	39 f3                	cmp    %esi,%ebx
  800a5e:	75 eb                	jne    800a4b <strncpy+0x1a>
	}
	return ret;
}
  800a60:	89 f8                	mov    %edi,%eax
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5f                   	pop    %edi
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	56                   	push   %esi
  800a6b:	53                   	push   %ebx
  800a6c:	8b 75 08             	mov    0x8(%ebp),%esi
  800a6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a72:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a75:	89 f0                	mov    %esi,%eax
  800a77:	85 d2                	test   %edx,%edx
  800a79:	74 2c                	je     800aa7 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800a7b:	89 d3                	mov    %edx,%ebx
  800a7d:	83 eb 01             	sub    $0x1,%ebx
  800a80:	74 20                	je     800aa2 <strlcpy+0x3b>
  800a82:	0f b6 11             	movzbl (%ecx),%edx
  800a85:	84 d2                	test   %dl,%dl
  800a87:	74 19                	je     800aa2 <strlcpy+0x3b>
  800a89:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800a8b:	88 10                	mov    %dl,(%eax)
  800a8d:	83 c0 01             	add    $0x1,%eax
  800a90:	83 eb 01             	sub    $0x1,%ebx
  800a93:	74 0f                	je     800aa4 <strlcpy+0x3d>
  800a95:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  800a99:	83 c1 01             	add    $0x1,%ecx
  800a9c:	84 d2                	test   %dl,%dl
  800a9e:	74 04                	je     800aa4 <strlcpy+0x3d>
  800aa0:	eb e9                	jmp    800a8b <strlcpy+0x24>
  800aa2:	89 f0                	mov    %esi,%eax
		*dst = '\0';
  800aa4:	c6 00 00             	movb   $0x0,(%eax)
  800aa7:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800aa9:	5b                   	pop    %ebx
  800aaa:	5e                   	pop    %esi
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	57                   	push   %edi
  800ab1:	56                   	push   %esi
  800ab2:	53                   	push   %ebx
  800ab3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab9:	8b 7d 10             	mov    0x10(%ebp),%edi
    int c;
    char *q = buf;

    if (buf_size <= 0)
  800abc:	85 c9                	test   %ecx,%ecx
  800abe:	7e 30                	jle    800af0 <pstrcpy+0x43>
        return;

    for(;;) {
        c = *str++;
  800ac0:	0f b6 07             	movzbl (%edi),%eax
        if (c == 0 || q >= buf + buf_size - 1)
  800ac3:	84 c0                	test   %al,%al
  800ac5:	74 26                	je     800aed <pstrcpy+0x40>
  800ac7:	8d 74 0a ff          	lea    0xffffffff(%edx,%ecx,1),%esi
  800acb:	0f be d8             	movsbl %al,%ebx
  800ace:	89 f9                	mov    %edi,%ecx
  800ad0:	39 f2                	cmp    %esi,%edx
  800ad2:	72 09                	jb     800add <pstrcpy+0x30>
  800ad4:	eb 17                	jmp    800aed <pstrcpy+0x40>
  800ad6:	83 c1 01             	add    $0x1,%ecx
  800ad9:	39 f2                	cmp    %esi,%edx
  800adb:	73 10                	jae    800aed <pstrcpy+0x40>
            break;
        *q++ = c;
  800add:	88 1a                	mov    %bl,(%edx)
  800adf:	83 c2 01             	add    $0x1,%edx
  800ae2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800ae6:	0f be d8             	movsbl %al,%ebx
  800ae9:	84 c0                	test   %al,%al
  800aeb:	75 e9                	jne    800ad6 <pstrcpy+0x29>
    }
    *q = '\0';
  800aed:	c6 02 00             	movb   $0x0,(%edx)
}
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5f                   	pop    %edi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	8b 55 08             	mov    0x8(%ebp),%edx
  800afb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  800afe:	0f b6 02             	movzbl (%edx),%eax
  800b01:	84 c0                	test   %al,%al
  800b03:	74 16                	je     800b1b <strcmp+0x26>
  800b05:	3a 01                	cmp    (%ecx),%al
  800b07:	75 12                	jne    800b1b <strcmp+0x26>
		p++, q++;
  800b09:	83 c1 01             	add    $0x1,%ecx
  800b0c:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  800b10:	84 c0                	test   %al,%al
  800b12:	74 07                	je     800b1b <strcmp+0x26>
  800b14:	83 c2 01             	add    $0x1,%edx
  800b17:	3a 01                	cmp    (%ecx),%al
  800b19:	74 ee                	je     800b09 <strcmp+0x14>
  800b1b:	0f b6 c0             	movzbl %al,%eax
  800b1e:	0f b6 11             	movzbl (%ecx),%edx
  800b21:	29 d0                	sub    %edx,%eax
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	53                   	push   %ebx
  800b29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b2f:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b32:	85 d2                	test   %edx,%edx
  800b34:	74 2d                	je     800b63 <strncmp+0x3e>
  800b36:	0f b6 01             	movzbl (%ecx),%eax
  800b39:	84 c0                	test   %al,%al
  800b3b:	74 1a                	je     800b57 <strncmp+0x32>
  800b3d:	3a 03                	cmp    (%ebx),%al
  800b3f:	75 16                	jne    800b57 <strncmp+0x32>
  800b41:	83 ea 01             	sub    $0x1,%edx
  800b44:	74 1d                	je     800b63 <strncmp+0x3e>
		n--, p++, q++;
  800b46:	83 c1 01             	add    $0x1,%ecx
  800b49:	83 c3 01             	add    $0x1,%ebx
  800b4c:	0f b6 01             	movzbl (%ecx),%eax
  800b4f:	84 c0                	test   %al,%al
  800b51:	74 04                	je     800b57 <strncmp+0x32>
  800b53:	3a 03                	cmp    (%ebx),%al
  800b55:	74 ea                	je     800b41 <strncmp+0x1c>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b57:	0f b6 11             	movzbl (%ecx),%edx
  800b5a:	0f b6 03             	movzbl (%ebx),%eax
  800b5d:	29 c2                	sub    %eax,%edx
  800b5f:	89 d0                	mov    %edx,%eax
  800b61:	eb 05                	jmp    800b68 <strncmp+0x43>
  800b63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b68:	5b                   	pop    %ebx
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b75:	0f b6 10             	movzbl (%eax),%edx
  800b78:	84 d2                	test   %dl,%dl
  800b7a:	74 16                	je     800b92 <strchr+0x27>
		if (*s == c)
  800b7c:	38 ca                	cmp    %cl,%dl
  800b7e:	75 06                	jne    800b86 <strchr+0x1b>
  800b80:	eb 15                	jmp    800b97 <strchr+0x2c>
  800b82:	38 ca                	cmp    %cl,%dl
  800b84:	74 11                	je     800b97 <strchr+0x2c>
  800b86:	83 c0 01             	add    $0x1,%eax
  800b89:	0f b6 10             	movzbl (%eax),%edx
  800b8c:	84 d2                	test   %dl,%dl
  800b8e:	66 90                	xchg   %ax,%ax
  800b90:	75 f0                	jne    800b82 <strchr+0x17>
  800b92:	b8 00 00 00 00       	mov    $0x0,%eax
			return (char *) s;
	return 0;
}
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ba3:	0f b6 10             	movzbl (%eax),%edx
  800ba6:	84 d2                	test   %dl,%dl
  800ba8:	74 14                	je     800bbe <strfind+0x25>
		if (*s == c)
  800baa:	38 ca                	cmp    %cl,%dl
  800bac:	75 06                	jne    800bb4 <strfind+0x1b>
  800bae:	eb 0e                	jmp    800bbe <strfind+0x25>
  800bb0:	38 ca                	cmp    %cl,%dl
  800bb2:	74 0a                	je     800bbe <strfind+0x25>
  800bb4:	83 c0 01             	add    $0x1,%eax
  800bb7:	0f b6 10             	movzbl (%eax),%edx
  800bba:	84 d2                	test   %dl,%dl
  800bbc:	75 f2                	jne    800bb0 <strfind+0x17>
			break;
	return (char *) s;
}
  800bbe:	5d                   	pop    %ebp
  800bbf:	90                   	nop    
  800bc0:	c3                   	ret    

00800bc1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	83 ec 08             	sub    $0x8,%esp
  800bc7:	89 1c 24             	mov    %ebx,(%esp)
  800bca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bce:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800bd7:	85 db                	test   %ebx,%ebx
  800bd9:	74 32                	je     800c0d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bdb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800be1:	75 25                	jne    800c08 <memset+0x47>
  800be3:	f6 c3 03             	test   $0x3,%bl
  800be6:	75 20                	jne    800c08 <memset+0x47>
		c &= 0xFF;
  800be8:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800beb:	89 d0                	mov    %edx,%eax
  800bed:	c1 e0 18             	shl    $0x18,%eax
  800bf0:	89 d1                	mov    %edx,%ecx
  800bf2:	c1 e1 10             	shl    $0x10,%ecx
  800bf5:	09 c8                	or     %ecx,%eax
  800bf7:	09 d0                	or     %edx,%eax
  800bf9:	c1 e2 08             	shl    $0x8,%edx
  800bfc:	09 d0                	or     %edx,%eax
  800bfe:	89 d9                	mov    %ebx,%ecx
  800c00:	c1 e9 02             	shr    $0x2,%ecx
  800c03:	fc                   	cld    
  800c04:	f3 ab                	rep stos %eax,%es:(%edi)
  800c06:	eb 05                	jmp    800c0d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c08:	89 d9                	mov    %ebx,%ecx
  800c0a:	fc                   	cld    
  800c0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c0d:	89 f8                	mov    %edi,%eax
  800c0f:	8b 1c 24             	mov    (%esp),%ebx
  800c12:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c16:	89 ec                	mov    %ebp,%esp
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	83 ec 08             	sub    $0x8,%esp
  800c20:	89 34 24             	mov    %esi,(%esp)
  800c23:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c27:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800c2d:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800c30:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800c32:	39 c6                	cmp    %eax,%esi
  800c34:	73 36                	jae    800c6c <memmove+0x52>
  800c36:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c39:	39 d0                	cmp    %edx,%eax
  800c3b:	73 2f                	jae    800c6c <memmove+0x52>
		s += n;
		d += n;
  800c3d:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c40:	f6 c2 03             	test   $0x3,%dl
  800c43:	75 1b                	jne    800c60 <memmove+0x46>
  800c45:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c4b:	75 13                	jne    800c60 <memmove+0x46>
  800c4d:	f6 c1 03             	test   $0x3,%cl
  800c50:	75 0e                	jne    800c60 <memmove+0x46>
			asm volatile("std; rep movsl\n"
  800c52:	8d 7e fc             	lea    0xfffffffc(%esi),%edi
  800c55:	8d 72 fc             	lea    0xfffffffc(%edx),%esi
  800c58:	c1 e9 02             	shr    $0x2,%ecx
  800c5b:	fd                   	std    
  800c5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c5e:	eb 09                	jmp    800c69 <memmove+0x4f>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c60:	8d 7e ff             	lea    0xffffffff(%esi),%edi
  800c63:	8d 72 ff             	lea    0xffffffff(%edx),%esi
  800c66:	fd                   	std    
  800c67:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c69:	fc                   	cld    
  800c6a:	eb 21                	jmp    800c8d <memmove+0x73>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c6c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c72:	75 16                	jne    800c8a <memmove+0x70>
  800c74:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c7a:	75 0e                	jne    800c8a <memmove+0x70>
  800c7c:	f6 c1 03             	test   $0x3,%cl
  800c7f:	90                   	nop    
  800c80:	75 08                	jne    800c8a <memmove+0x70>
			asm volatile("cld; rep movsl\n"
  800c82:	c1 e9 02             	shr    $0x2,%ecx
  800c85:	fc                   	cld    
  800c86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c88:	eb 03                	jmp    800c8d <memmove+0x73>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c8a:	fc                   	cld    
  800c8b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c8d:	8b 34 24             	mov    (%esp),%esi
  800c90:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c94:	89 ec                	mov    %ebp,%esp
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <memcpy>:

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
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c9e:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ca5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cac:	8b 45 08             	mov    0x8(%ebp),%eax
  800caf:	89 04 24             	mov    %eax,(%esp)
  800cb2:	e8 63 ff ff ff       	call   800c1a <memmove>
}
  800cb7:	c9                   	leave  
  800cb8:	c3                   	ret    

00800cb9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	56                   	push   %esi
  800cbd:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cbe:	8b 75 10             	mov    0x10(%ebp),%esi
  800cc1:	83 ee 01             	sub    $0x1,%esi
  800cc4:	83 fe ff             	cmp    $0xffffffff,%esi
  800cc7:	74 38                	je     800d01 <memcmp+0x48>
  800cc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccc:	8b 55 0c             	mov    0xc(%ebp),%edx
		if (*s1 != *s2)
  800ccf:	0f b6 18             	movzbl (%eax),%ebx
  800cd2:	0f b6 0a             	movzbl (%edx),%ecx
  800cd5:	38 cb                	cmp    %cl,%bl
  800cd7:	74 20                	je     800cf9 <memcmp+0x40>
  800cd9:	eb 12                	jmp    800ced <memcmp+0x34>
  800cdb:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
  800cdf:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
  800ce3:	83 c0 01             	add    $0x1,%eax
  800ce6:	83 c2 01             	add    $0x1,%edx
  800ce9:	38 cb                	cmp    %cl,%bl
  800ceb:	74 0c                	je     800cf9 <memcmp+0x40>
			return (int) *s1 - (int) *s2;
  800ced:	0f b6 d3             	movzbl %bl,%edx
  800cf0:	0f b6 c1             	movzbl %cl,%eax
  800cf3:	29 c2                	sub    %eax,%edx
  800cf5:	89 d0                	mov    %edx,%eax
  800cf7:	eb 0d                	jmp    800d06 <memcmp+0x4d>
  800cf9:	83 ee 01             	sub    $0x1,%esi
  800cfc:	83 fe ff             	cmp    $0xffffffff,%esi
  800cff:	75 da                	jne    800cdb <memcmp+0x22>
  800d01:	b8 00 00 00 00       	mov    $0x0,%eax
		s1++, s2++;
	}

	return 0;
}
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	53                   	push   %ebx
  800d0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800d11:	89 da                	mov    %ebx,%edx
  800d13:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d16:	39 d3                	cmp    %edx,%ebx
  800d18:	73 1a                	jae    800d34 <memfind+0x2a>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d1a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
			break;
  800d1e:	89 d8                	mov    %ebx,%eax
  800d20:	38 0b                	cmp    %cl,(%ebx)
  800d22:	75 06                	jne    800d2a <memfind+0x20>
  800d24:	eb 0e                	jmp    800d34 <memfind+0x2a>
  800d26:	38 08                	cmp    %cl,(%eax)
  800d28:	74 0c                	je     800d36 <memfind+0x2c>
  800d2a:	83 c0 01             	add    $0x1,%eax
  800d2d:	39 d0                	cmp    %edx,%eax
  800d2f:	90                   	nop    
  800d30:	75 f4                	jne    800d26 <memfind+0x1c>
  800d32:	eb 02                	jmp    800d36 <memfind+0x2c>
  800d34:	89 d8                	mov    %ebx,%eax
	return (void *) s;
}
  800d36:	5b                   	pop    %ebx
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	57                   	push   %edi
  800d3d:	56                   	push   %esi
  800d3e:	53                   	push   %ebx
  800d3f:	83 ec 04             	sub    $0x4,%esp
  800d42:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d45:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d48:	0f b6 03             	movzbl (%ebx),%eax
  800d4b:	3c 20                	cmp    $0x20,%al
  800d4d:	74 04                	je     800d53 <strtol+0x1a>
  800d4f:	3c 09                	cmp    $0x9,%al
  800d51:	75 0e                	jne    800d61 <strtol+0x28>
		s++;
  800d53:	83 c3 01             	add    $0x1,%ebx
  800d56:	0f b6 03             	movzbl (%ebx),%eax
  800d59:	3c 20                	cmp    $0x20,%al
  800d5b:	74 f6                	je     800d53 <strtol+0x1a>
  800d5d:	3c 09                	cmp    $0x9,%al
  800d5f:	74 f2                	je     800d53 <strtol+0x1a>

	// plus/minus sign
	if (*s == '+')
  800d61:	3c 2b                	cmp    $0x2b,%al
  800d63:	75 0d                	jne    800d72 <strtol+0x39>
		s++;
  800d65:	83 c3 01             	add    $0x1,%ebx
  800d68:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800d6f:	90                   	nop    
  800d70:	eb 15                	jmp    800d87 <strtol+0x4e>
	else if (*s == '-')
  800d72:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800d79:	3c 2d                	cmp    $0x2d,%al
  800d7b:	75 0a                	jne    800d87 <strtol+0x4e>
		s++, neg = 1;
  800d7d:	83 c3 01             	add    $0x1,%ebx
  800d80:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d87:	85 f6                	test   %esi,%esi
  800d89:	0f 94 c0             	sete   %al
  800d8c:	84 c0                	test   %al,%al
  800d8e:	75 05                	jne    800d95 <strtol+0x5c>
  800d90:	83 fe 10             	cmp    $0x10,%esi
  800d93:	75 17                	jne    800dac <strtol+0x73>
  800d95:	80 3b 30             	cmpb   $0x30,(%ebx)
  800d98:	75 12                	jne    800dac <strtol+0x73>
  800d9a:	80 7b 01 78          	cmpb   $0x78,0x1(%ebx)
  800d9e:	66 90                	xchg   %ax,%ax
  800da0:	75 0a                	jne    800dac <strtol+0x73>
		s += 2, base = 16;
  800da2:	83 c3 02             	add    $0x2,%ebx
  800da5:	be 10 00 00 00       	mov    $0x10,%esi
  800daa:	eb 1f                	jmp    800dcb <strtol+0x92>
	else if (base == 0 && s[0] == '0')
  800dac:	85 f6                	test   %esi,%esi
  800dae:	66 90                	xchg   %ax,%ax
  800db0:	75 10                	jne    800dc2 <strtol+0x89>
  800db2:	80 3b 30             	cmpb   $0x30,(%ebx)
  800db5:	75 0b                	jne    800dc2 <strtol+0x89>
		s++, base = 8;
  800db7:	83 c3 01             	add    $0x1,%ebx
  800dba:	66 be 08 00          	mov    $0x8,%si
  800dbe:	66 90                	xchg   %ax,%ax
  800dc0:	eb 09                	jmp    800dcb <strtol+0x92>
	else if (base == 0)
  800dc2:	84 c0                	test   %al,%al
  800dc4:	74 05                	je     800dcb <strtol+0x92>
  800dc6:	be 0a 00 00 00       	mov    $0xa,%esi
  800dcb:	bf 00 00 00 00       	mov    $0x0,%edi
		base = 10;

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dd0:	0f b6 13             	movzbl (%ebx),%edx
  800dd3:	89 d1                	mov    %edx,%ecx
  800dd5:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800dd8:	3c 09                	cmp    $0x9,%al
  800dda:	77 08                	ja     800de4 <strtol+0xab>
			dig = *s - '0';
  800ddc:	0f be c2             	movsbl %dl,%eax
  800ddf:	8d 50 d0             	lea    0xffffffd0(%eax),%edx
  800de2:	eb 1c                	jmp    800e00 <strtol+0xc7>
		else if (*s >= 'a' && *s <= 'z')
  800de4:	8d 41 9f             	lea    0xffffff9f(%ecx),%eax
  800de7:	3c 19                	cmp    $0x19,%al
  800de9:	77 08                	ja     800df3 <strtol+0xba>
			dig = *s - 'a' + 10;
  800deb:	0f be c2             	movsbl %dl,%eax
  800dee:	8d 50 a9             	lea    0xffffffa9(%eax),%edx
  800df1:	eb 0d                	jmp    800e00 <strtol+0xc7>
		else if (*s >= 'A' && *s <= 'Z')
  800df3:	8d 41 bf             	lea    0xffffffbf(%ecx),%eax
  800df6:	3c 19                	cmp    $0x19,%al
  800df8:	77 17                	ja     800e11 <strtol+0xd8>
			dig = *s - 'A' + 10;
  800dfa:	0f be c2             	movsbl %dl,%eax
  800dfd:	8d 50 c9             	lea    0xffffffc9(%eax),%edx
		else
			break;
		if (dig >= base)
  800e00:	39 f2                	cmp    %esi,%edx
  800e02:	7d 0d                	jge    800e11 <strtol+0xd8>
			break;
		s++, val = (val * base) + dig;
  800e04:	83 c3 01             	add    $0x1,%ebx
  800e07:	89 f8                	mov    %edi,%eax
  800e09:	0f af c6             	imul   %esi,%eax
  800e0c:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800e0f:	eb bf                	jmp    800dd0 <strtol+0x97>
		// we don't properly detect overflow!
	}
  800e11:	89 f8                	mov    %edi,%eax

	if (endptr)
  800e13:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e17:	74 05                	je     800e1e <strtol+0xe5>
		*endptr = (char *) s;
  800e19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e1c:	89 1a                	mov    %ebx,(%edx)
	return (neg ? -val : val);
  800e1e:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800e22:	74 04                	je     800e28 <strtol+0xef>
  800e24:	89 c7                	mov    %eax,%edi
  800e26:	f7 df                	neg    %edi
}
  800e28:	89 f8                	mov    %edi,%eax
  800e2a:	83 c4 04             	add    $0x4,%esp
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    
	...

00800e34 <sys_cgetc>:
}

int
sys_cgetc(void)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	83 ec 0c             	sub    $0xc,%esp
  800e3a:	89 1c 24             	mov    %ebx,(%esp)
  800e3d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e41:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e45:	b8 01 00 00 00       	mov    $0x1,%eax
  800e4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800e4f:	89 fa                	mov    %edi,%edx
  800e51:	89 f9                	mov    %edi,%ecx
  800e53:	89 fb                	mov    %edi,%ebx
  800e55:	89 fe                	mov    %edi,%esi
  800e57:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e59:	8b 1c 24             	mov    (%esp),%ebx
  800e5c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e60:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e64:	89 ec                	mov    %ebp,%esp
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    

00800e68 <sys_cputs>:
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	83 ec 0c             	sub    $0xc,%esp
  800e6e:	89 1c 24             	mov    %ebx,(%esp)
  800e71:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e75:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e79:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7f:	bf 00 00 00 00       	mov    $0x0,%edi
  800e84:	89 f8                	mov    %edi,%eax
  800e86:	89 fb                	mov    %edi,%ebx
  800e88:	89 fe                	mov    %edi,%esi
  800e8a:	cd 30                	int    $0x30
  800e8c:	8b 1c 24             	mov    (%esp),%ebx
  800e8f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e93:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e97:	89 ec                	mov    %ebp,%esp
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    

00800e9b <sys_time_msec>:

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
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	83 ec 0c             	sub    $0xc,%esp
  800ea1:	89 1c 24             	mov    %ebx,(%esp)
  800ea4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ea8:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800eac:	b8 0e 00 00 00       	mov    $0xe,%eax
  800eb1:	bf 00 00 00 00       	mov    $0x0,%edi
  800eb6:	89 fa                	mov    %edi,%edx
  800eb8:	89 f9                	mov    %edi,%ecx
  800eba:	89 fb                	mov    %edi,%ebx
  800ebc:	89 fe                	mov    %edi,%esi
  800ebe:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ec0:	8b 1c 24             	mov    (%esp),%ebx
  800ec3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ec7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ecb:	89 ec                	mov    %ebp,%esp
  800ecd:	5d                   	pop    %ebp
  800ece:	c3                   	ret    

00800ecf <sys_ipc_recv>:
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	83 ec 28             	sub    $0x28,%esp
  800ed5:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800ed8:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800edb:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800ede:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ee6:	bf 00 00 00 00       	mov    $0x0,%edi
  800eeb:	89 f9                	mov    %edi,%ecx
  800eed:	89 fb                	mov    %edi,%ebx
  800eef:	89 fe                	mov    %edi,%esi
  800ef1:	cd 30                	int    $0x30
  800ef3:	85 c0                	test   %eax,%eax
  800ef5:	7e 28                	jle    800f1f <sys_ipc_recv+0x50>
  800ef7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800efb:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f02:	00 
  800f03:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800f0a:	00 
  800f0b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f12:	00 
  800f13:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  800f1a:	e8 9d f3 ff ff       	call   8002bc <_panic>
  800f1f:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800f22:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800f25:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800f28:	89 ec                	mov    %ebp,%esp
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    

00800f2c <sys_ipc_try_send>:
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	83 ec 0c             	sub    $0xc,%esp
  800f32:	89 1c 24             	mov    %ebx,(%esp)
  800f35:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f39:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f43:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f46:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f49:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f4e:	be 00 00 00 00       	mov    $0x0,%esi
  800f53:	cd 30                	int    $0x30
  800f55:	8b 1c 24             	mov    (%esp),%ebx
  800f58:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f5c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f60:	89 ec                	mov    %ebp,%esp
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    

00800f64 <sys_env_set_pgfault_upcall>:
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	83 ec 28             	sub    $0x28,%esp
  800f6a:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800f6d:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800f70:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800f73:	8b 55 08             	mov    0x8(%ebp),%edx
  800f76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f79:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f7e:	bf 00 00 00 00       	mov    $0x0,%edi
  800f83:	89 fb                	mov    %edi,%ebx
  800f85:	89 fe                	mov    %edi,%esi
  800f87:	cd 30                	int    $0x30
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	7e 28                	jle    800fb5 <sys_env_set_pgfault_upcall+0x51>
  800f8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f91:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f98:	00 
  800f99:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800fa0:	00 
  800fa1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa8:	00 
  800fa9:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  800fb0:	e8 07 f3 ff ff       	call   8002bc <_panic>
  800fb5:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800fb8:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800fbb:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800fbe:	89 ec                	mov    %ebp,%esp
  800fc0:	5d                   	pop    %ebp
  800fc1:	c3                   	ret    

00800fc2 <sys_env_set_trapframe>:
  800fc2:	55                   	push   %ebp
  800fc3:	89 e5                	mov    %esp,%ebp
  800fc5:	83 ec 28             	sub    $0x28,%esp
  800fc8:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800fcb:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800fce:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800fd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd7:	b8 09 00 00 00       	mov    $0x9,%eax
  800fdc:	bf 00 00 00 00       	mov    $0x0,%edi
  800fe1:	89 fb                	mov    %edi,%ebx
  800fe3:	89 fe                	mov    %edi,%esi
  800fe5:	cd 30                	int    $0x30
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	7e 28                	jle    801013 <sys_env_set_trapframe+0x51>
  800feb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fef:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ff6:	00 
  800ff7:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800ffe:	00 
  800fff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801006:	00 
  801007:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  80100e:	e8 a9 f2 ff ff       	call   8002bc <_panic>
  801013:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801016:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801019:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  80101c:	89 ec                	mov    %ebp,%esp
  80101e:	5d                   	pop    %ebp
  80101f:	c3                   	ret    

00801020 <sys_env_set_status>:
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	83 ec 28             	sub    $0x28,%esp
  801026:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801029:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  80102c:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  80102f:	8b 55 08             	mov    0x8(%ebp),%edx
  801032:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801035:	b8 08 00 00 00       	mov    $0x8,%eax
  80103a:	bf 00 00 00 00       	mov    $0x0,%edi
  80103f:	89 fb                	mov    %edi,%ebx
  801041:	89 fe                	mov    %edi,%esi
  801043:	cd 30                	int    $0x30
  801045:	85 c0                	test   %eax,%eax
  801047:	7e 28                	jle    801071 <sys_env_set_status+0x51>
  801049:	89 44 24 10          	mov    %eax,0x10(%esp)
  80104d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801054:	00 
  801055:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  80105c:	00 
  80105d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801064:	00 
  801065:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  80106c:	e8 4b f2 ff ff       	call   8002bc <_panic>
  801071:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801074:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801077:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  80107a:	89 ec                	mov    %ebp,%esp
  80107c:	5d                   	pop    %ebp
  80107d:	c3                   	ret    

0080107e <sys_page_unmap>:
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	83 ec 28             	sub    $0x28,%esp
  801084:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801087:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  80108a:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  80108d:	8b 55 08             	mov    0x8(%ebp),%edx
  801090:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801093:	b8 06 00 00 00       	mov    $0x6,%eax
  801098:	bf 00 00 00 00       	mov    $0x0,%edi
  80109d:	89 fb                	mov    %edi,%ebx
  80109f:	89 fe                	mov    %edi,%esi
  8010a1:	cd 30                	int    $0x30
  8010a3:	85 c0                	test   %eax,%eax
  8010a5:	7e 28                	jle    8010cf <sys_page_unmap+0x51>
  8010a7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010ab:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8010b2:	00 
  8010b3:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  8010ba:	00 
  8010bb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010c2:	00 
  8010c3:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  8010ca:	e8 ed f1 ff ff       	call   8002bc <_panic>
  8010cf:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  8010d2:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  8010d5:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  8010d8:	89 ec                	mov    %ebp,%esp
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    

008010dc <sys_page_map>:
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	83 ec 28             	sub    $0x28,%esp
  8010e2:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  8010e5:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  8010e8:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  8010eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010f4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010f7:	8b 75 18             	mov    0x18(%ebp),%esi
  8010fa:	b8 05 00 00 00       	mov    $0x5,%eax
  8010ff:	cd 30                	int    $0x30
  801101:	85 c0                	test   %eax,%eax
  801103:	7e 28                	jle    80112d <sys_page_map+0x51>
  801105:	89 44 24 10          	mov    %eax,0x10(%esp)
  801109:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801110:	00 
  801111:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  801118:	00 
  801119:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801120:	00 
  801121:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  801128:	e8 8f f1 ff ff       	call   8002bc <_panic>
  80112d:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801130:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801133:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801136:	89 ec                	mov    %ebp,%esp
  801138:	5d                   	pop    %ebp
  801139:	c3                   	ret    

0080113a <sys_page_alloc>:
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
  80113d:	83 ec 28             	sub    $0x28,%esp
  801140:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801143:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  801146:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801149:	8b 55 08             	mov    0x8(%ebp),%edx
  80114c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80114f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801152:	b8 04 00 00 00       	mov    $0x4,%eax
  801157:	bf 00 00 00 00       	mov    $0x0,%edi
  80115c:	89 fe                	mov    %edi,%esi
  80115e:	cd 30                	int    $0x30
  801160:	85 c0                	test   %eax,%eax
  801162:	7e 28                	jle    80118c <sys_page_alloc+0x52>
  801164:	89 44 24 10          	mov    %eax,0x10(%esp)
  801168:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80116f:	00 
  801170:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  801177:	00 
  801178:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80117f:	00 
  801180:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  801187:	e8 30 f1 ff ff       	call   8002bc <_panic>
  80118c:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  80118f:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801192:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801195:	89 ec                	mov    %ebp,%esp
  801197:	5d                   	pop    %ebp
  801198:	c3                   	ret    

00801199 <sys_yield>:
  801199:	55                   	push   %ebp
  80119a:	89 e5                	mov    %esp,%ebp
  80119c:	83 ec 0c             	sub    $0xc,%esp
  80119f:	89 1c 24             	mov    %ebx,(%esp)
  8011a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011a6:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8011aa:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011af:	bf 00 00 00 00       	mov    $0x0,%edi
  8011b4:	89 fa                	mov    %edi,%edx
  8011b6:	89 f9                	mov    %edi,%ecx
  8011b8:	89 fb                	mov    %edi,%ebx
  8011ba:	89 fe                	mov    %edi,%esi
  8011bc:	cd 30                	int    $0x30
  8011be:	8b 1c 24             	mov    (%esp),%ebx
  8011c1:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011c5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011c9:	89 ec                	mov    %ebp,%esp
  8011cb:	5d                   	pop    %ebp
  8011cc:	c3                   	ret    

008011cd <sys_getenvid>:
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	83 ec 0c             	sub    $0xc,%esp
  8011d3:	89 1c 24             	mov    %ebx,(%esp)
  8011d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011da:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8011de:	b8 02 00 00 00       	mov    $0x2,%eax
  8011e3:	bf 00 00 00 00       	mov    $0x0,%edi
  8011e8:	89 fa                	mov    %edi,%edx
  8011ea:	89 f9                	mov    %edi,%ecx
  8011ec:	89 fb                	mov    %edi,%ebx
  8011ee:	89 fe                	mov    %edi,%esi
  8011f0:	cd 30                	int    $0x30
  8011f2:	8b 1c 24             	mov    (%esp),%ebx
  8011f5:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011f9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011fd:	89 ec                	mov    %ebp,%esp
  8011ff:	5d                   	pop    %ebp
  801200:	c3                   	ret    

00801201 <sys_env_destroy>:
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	83 ec 28             	sub    $0x28,%esp
  801207:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  80120a:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  80120d:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801210:	8b 55 08             	mov    0x8(%ebp),%edx
  801213:	b8 03 00 00 00       	mov    $0x3,%eax
  801218:	bf 00 00 00 00       	mov    $0x0,%edi
  80121d:	89 f9                	mov    %edi,%ecx
  80121f:	89 fb                	mov    %edi,%ebx
  801221:	89 fe                	mov    %edi,%esi
  801223:	cd 30                	int    $0x30
  801225:	85 c0                	test   %eax,%eax
  801227:	7e 28                	jle    801251 <sys_env_destroy+0x50>
  801229:	89 44 24 10          	mov    %eax,0x10(%esp)
  80122d:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801234:	00 
  801235:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  80123c:	00 
  80123d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801244:	00 
  801245:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  80124c:	e8 6b f0 ff ff       	call   8002bc <_panic>
  801251:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801254:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801257:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  80125a:	89 ec                	mov    %ebp,%esp
  80125c:	5d                   	pop    %ebp
  80125d:	c3                   	ret    
	...

00801260 <fd2num>:
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	8b 45 08             	mov    0x8(%ebp),%eax
  801266:	05 00 00 00 30       	add    $0x30000000,%eax
  80126b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80126e:	5d                   	pop    %ebp
  80126f:	c3                   	ret    

00801270 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801276:	8b 45 08             	mov    0x8(%ebp),%eax
  801279:	89 04 24             	mov    %eax,(%esp)
  80127c:	e8 df ff ff ff       	call   801260 <fd2num>
  801281:	c1 e0 0c             	shl    $0xc,%eax
  801284:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801289:	c9                   	leave  
  80128a:	c3                   	ret    

0080128b <fd_alloc>:

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
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
  80128e:	53                   	push   %ebx
  80128f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801292:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801297:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801299:	89 d0                	mov    %edx,%eax
  80129b:	c1 e8 16             	shr    $0x16,%eax
  80129e:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  8012a5:	a8 01                	test   $0x1,%al
  8012a7:	74 10                	je     8012b9 <fd_alloc+0x2e>
  8012a9:	89 d0                	mov    %edx,%eax
  8012ab:	c1 e8 0c             	shr    $0xc,%eax
  8012ae:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  8012b5:	a8 01                	test   $0x1,%al
  8012b7:	75 09                	jne    8012c2 <fd_alloc+0x37>
			*fd_store = fd;
  8012b9:	89 0b                	mov    %ecx,(%ebx)
  8012bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c0:	eb 19                	jmp    8012db <fd_alloc+0x50>
			return 0;
  8012c2:	81 c2 00 10 00 00    	add    $0x1000,%edx
  8012c8:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  8012ce:	75 c7                	jne    801297 <fd_alloc+0xc>
		}
	}
	*fd_store = 0;
  8012d0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8012d6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8012db:	5b                   	pop    %ebx
  8012dc:	5d                   	pop    %ebp
  8012dd:	c3                   	ret    

008012de <fd_lookup>:

// Check that fdnum is in range and mapped.
// If it is, set *fd_store to the fd page virtual address.
//
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
  8012e1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012e4:	83 f8 1f             	cmp    $0x1f,%eax
  8012e7:	77 35                	ja     80131e <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012e9:	c1 e0 0c             	shl    $0xc,%eax
  8012ec:	8d 90 00 00 00 d0    	lea    0xd0000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  8012f2:	89 d0                	mov    %edx,%eax
  8012f4:	c1 e8 16             	shr    $0x16,%eax
  8012f7:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  8012fe:	a8 01                	test   $0x1,%al
  801300:	74 1c                	je     80131e <fd_lookup+0x40>
  801302:	89 d0                	mov    %edx,%eax
  801304:	c1 e8 0c             	shr    $0xc,%eax
  801307:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  80130e:	a8 01                	test   $0x1,%al
  801310:	74 0c                	je     80131e <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801312:	8b 45 0c             	mov    0xc(%ebp),%eax
  801315:	89 10                	mov    %edx,(%eax)
  801317:	b8 00 00 00 00       	mov    $0x0,%eax
  80131c:	eb 05                	jmp    801323 <fd_lookup+0x45>
	return 0;
  80131e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801323:	5d                   	pop    %ebp
  801324:	c3                   	ret    

00801325 <seek>:

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
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
  801328:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80132b:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  80132e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801332:	8b 45 08             	mov    0x8(%ebp),%eax
  801335:	89 04 24             	mov    %eax,(%esp)
  801338:	e8 a1 ff ff ff       	call   8012de <fd_lookup>
  80133d:	85 c0                	test   %eax,%eax
  80133f:	78 0e                	js     80134f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801341:	8b 55 0c             	mov    0xc(%ebp),%edx
  801344:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  801347:	89 50 04             	mov    %edx,0x4(%eax)
  80134a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80134f:	c9                   	leave  
  801350:	c3                   	ret    

00801351 <dev_lookup>:
  801351:	55                   	push   %ebp
  801352:	89 e5                	mov    %esp,%ebp
  801354:	53                   	push   %ebx
  801355:	83 ec 14             	sub    $0x14,%esp
  801358:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80135b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80135e:	ba 04 60 80 00       	mov    $0x806004,%edx
  801363:	b8 00 00 00 00       	mov    $0x0,%eax
  801368:	39 0d 04 60 80 00    	cmp    %ecx,0x806004
  80136e:	75 12                	jne    801382 <dev_lookup+0x31>
  801370:	eb 04                	jmp    801376 <dev_lookup+0x25>
  801372:	39 0a                	cmp    %ecx,(%edx)
  801374:	75 0c                	jne    801382 <dev_lookup+0x31>
  801376:	89 13                	mov    %edx,(%ebx)
  801378:	b8 00 00 00 00       	mov    $0x0,%eax
  80137d:	8d 76 00             	lea    0x0(%esi),%esi
  801380:	eb 35                	jmp    8013b7 <dev_lookup+0x66>
  801382:	83 c0 01             	add    $0x1,%eax
  801385:	8b 14 85 6c 29 80 00 	mov    0x80296c(,%eax,4),%edx
  80138c:	85 d2                	test   %edx,%edx
  80138e:	75 e2                	jne    801372 <dev_lookup+0x21>
  801390:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801395:	8b 40 4c             	mov    0x4c(%eax),%eax
  801398:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80139c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a0:	c7 04 24 ec 28 80 00 	movl   $0x8028ec,(%esp)
  8013a7:	e8 dd ef ff ff       	call   800389 <cprintf>
  8013ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8013b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013b7:	83 c4 14             	add    $0x14,%esp
  8013ba:	5b                   	pop    %ebx
  8013bb:	5d                   	pop    %ebp
  8013bc:	c3                   	ret    

008013bd <fstat>:

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
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	53                   	push   %ebx
  8013c1:	83 ec 24             	sub    $0x24,%esp
  8013c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013c7:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8013ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d1:	89 04 24             	mov    %eax,(%esp)
  8013d4:	e8 05 ff ff ff       	call   8012de <fd_lookup>
  8013d9:	89 c2                	mov    %eax,%edx
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	78 57                	js     801436 <fstat+0x79>
  8013df:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  8013e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e6:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8013e9:	8b 00                	mov    (%eax),%eax
  8013eb:	89 04 24             	mov    %eax,(%esp)
  8013ee:	e8 5e ff ff ff       	call   801351 <dev_lookup>
  8013f3:	89 c2                	mov    %eax,%edx
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	78 3d                	js     801436 <fstat+0x79>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8013f9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  8013fe:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  801401:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801405:	74 2f                	je     801436 <fstat+0x79>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801407:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80140a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801411:	00 00 00 
	stat->st_isdir = 0;
  801414:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80141b:	00 00 00 
	stat->st_dev = dev;
  80141e:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801421:	89 93 88 00 00 00    	mov    %edx,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801427:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80142b:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80142e:	89 04 24             	mov    %eax,(%esp)
  801431:	ff 52 14             	call   *0x14(%edx)
  801434:	89 c2                	mov    %eax,%edx
}
  801436:	89 d0                	mov    %edx,%eax
  801438:	83 c4 24             	add    $0x24,%esp
  80143b:	5b                   	pop    %ebx
  80143c:	5d                   	pop    %ebp
  80143d:	c3                   	ret    

0080143e <ftruncate>:
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
  801441:	53                   	push   %ebx
  801442:	83 ec 24             	sub    $0x24,%esp
  801445:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801448:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80144b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144f:	89 1c 24             	mov    %ebx,(%esp)
  801452:	e8 87 fe ff ff       	call   8012de <fd_lookup>
  801457:	85 c0                	test   %eax,%eax
  801459:	78 61                	js     8014bc <ftruncate+0x7e>
  80145b:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80145e:	8b 10                	mov    (%eax),%edx
  801460:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801463:	89 44 24 04          	mov    %eax,0x4(%esp)
  801467:	89 14 24             	mov    %edx,(%esp)
  80146a:	e8 e2 fe ff ff       	call   801351 <dev_lookup>
  80146f:	85 c0                	test   %eax,%eax
  801471:	78 49                	js     8014bc <ftruncate+0x7e>
  801473:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801476:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  80147a:	75 23                	jne    80149f <ftruncate+0x61>
  80147c:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801481:	8b 40 4c             	mov    0x4c(%eax),%eax
  801484:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801488:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148c:	c7 04 24 0c 29 80 00 	movl   $0x80290c,(%esp)
  801493:	e8 f1 ee ff ff       	call   800389 <cprintf>
  801498:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80149d:	eb 1d                	jmp    8014bc <ftruncate+0x7e>
  80149f:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  8014a2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014a7:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  8014ab:	74 0f                	je     8014bc <ftruncate+0x7e>
  8014ad:	8b 52 18             	mov    0x18(%edx),%edx
  8014b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b7:	89 0c 24             	mov    %ecx,(%esp)
  8014ba:	ff d2                	call   *%edx
  8014bc:	83 c4 24             	add    $0x24,%esp
  8014bf:	5b                   	pop    %ebx
  8014c0:	5d                   	pop    %ebp
  8014c1:	c3                   	ret    

008014c2 <write>:
  8014c2:	55                   	push   %ebp
  8014c3:	89 e5                	mov    %esp,%ebp
  8014c5:	53                   	push   %ebx
  8014c6:	83 ec 24             	sub    $0x24,%esp
  8014c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8014cc:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8014cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d3:	89 1c 24             	mov    %ebx,(%esp)
  8014d6:	e8 03 fe ff ff       	call   8012de <fd_lookup>
  8014db:	85 c0                	test   %eax,%eax
  8014dd:	78 68                	js     801547 <write+0x85>
  8014df:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8014e2:	8b 10                	mov    (%eax),%edx
  8014e4:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  8014e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014eb:	89 14 24             	mov    %edx,(%esp)
  8014ee:	e8 5e fe ff ff       	call   801351 <dev_lookup>
  8014f3:	85 c0                	test   %eax,%eax
  8014f5:	78 50                	js     801547 <write+0x85>
  8014f7:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  8014fa:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  8014fe:	75 23                	jne    801523 <write+0x61>
  801500:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801505:	8b 40 4c             	mov    0x4c(%eax),%eax
  801508:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80150c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801510:	c7 04 24 30 29 80 00 	movl   $0x802930,(%esp)
  801517:	e8 6d ee ff ff       	call   800389 <cprintf>
  80151c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801521:	eb 24                	jmp    801547 <write+0x85>
  801523:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801526:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80152b:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  80152f:	74 16                	je     801547 <write+0x85>
  801531:	8b 42 0c             	mov    0xc(%edx),%eax
  801534:	8b 55 10             	mov    0x10(%ebp),%edx
  801537:	89 54 24 08          	mov    %edx,0x8(%esp)
  80153b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80153e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801542:	89 0c 24             	mov    %ecx,(%esp)
  801545:	ff d0                	call   *%eax
  801547:	83 c4 24             	add    $0x24,%esp
  80154a:	5b                   	pop    %ebx
  80154b:	5d                   	pop    %ebp
  80154c:	c3                   	ret    

0080154d <read>:
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	53                   	push   %ebx
  801551:	83 ec 24             	sub    $0x24,%esp
  801554:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801557:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80155a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80155e:	89 1c 24             	mov    %ebx,(%esp)
  801561:	e8 78 fd ff ff       	call   8012de <fd_lookup>
  801566:	85 c0                	test   %eax,%eax
  801568:	78 6d                	js     8015d7 <read+0x8a>
  80156a:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80156d:	8b 10                	mov    (%eax),%edx
  80156f:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801572:	89 44 24 04          	mov    %eax,0x4(%esp)
  801576:	89 14 24             	mov    %edx,(%esp)
  801579:	e8 d3 fd ff ff       	call   801351 <dev_lookup>
  80157e:	85 c0                	test   %eax,%eax
  801580:	78 55                	js     8015d7 <read+0x8a>
  801582:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801585:	8b 41 08             	mov    0x8(%ecx),%eax
  801588:	83 e0 03             	and    $0x3,%eax
  80158b:	83 f8 01             	cmp    $0x1,%eax
  80158e:	75 23                	jne    8015b3 <read+0x66>
  801590:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801595:	8b 40 4c             	mov    0x4c(%eax),%eax
  801598:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80159c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a0:	c7 04 24 4d 29 80 00 	movl   $0x80294d,(%esp)
  8015a7:	e8 dd ed ff ff       	call   800389 <cprintf>
  8015ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015b1:	eb 24                	jmp    8015d7 <read+0x8a>
  8015b3:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  8015b6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015bb:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  8015bf:	74 16                	je     8015d7 <read+0x8a>
  8015c1:	8b 42 08             	mov    0x8(%edx),%eax
  8015c4:	8b 55 10             	mov    0x10(%ebp),%edx
  8015c7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8015cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015d2:	89 0c 24             	mov    %ecx,(%esp)
  8015d5:	ff d0                	call   *%eax
  8015d7:	83 c4 24             	add    $0x24,%esp
  8015da:	5b                   	pop    %ebx
  8015db:	5d                   	pop    %ebp
  8015dc:	c3                   	ret    

008015dd <readn>:
  8015dd:	55                   	push   %ebp
  8015de:	89 e5                	mov    %esp,%ebp
  8015e0:	57                   	push   %edi
  8015e1:	56                   	push   %esi
  8015e2:	53                   	push   %ebx
  8015e3:	83 ec 0c             	sub    $0xc,%esp
  8015e6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8015e9:	8b 75 10             	mov    0x10(%ebp),%esi
  8015ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8015f1:	85 f6                	test   %esi,%esi
  8015f3:	74 36                	je     80162b <readn+0x4e>
  8015f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ff:	89 f0                	mov    %esi,%eax
  801601:	29 d0                	sub    %edx,%eax
  801603:	89 44 24 08          	mov    %eax,0x8(%esp)
  801607:	8d 04 17             	lea    (%edi,%edx,1),%eax
  80160a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80160e:	8b 45 08             	mov    0x8(%ebp),%eax
  801611:	89 04 24             	mov    %eax,(%esp)
  801614:	e8 34 ff ff ff       	call   80154d <read>
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 0e                	js     80162b <readn+0x4e>
  80161d:	85 c0                	test   %eax,%eax
  80161f:	74 08                	je     801629 <readn+0x4c>
  801621:	01 c3                	add    %eax,%ebx
  801623:	89 da                	mov    %ebx,%edx
  801625:	39 f3                	cmp    %esi,%ebx
  801627:	72 d6                	jb     8015ff <readn+0x22>
  801629:	89 d8                	mov    %ebx,%eax
  80162b:	83 c4 0c             	add    $0xc,%esp
  80162e:	5b                   	pop    %ebx
  80162f:	5e                   	pop    %esi
  801630:	5f                   	pop    %edi
  801631:	5d                   	pop    %ebp
  801632:	c3                   	ret    

00801633 <fd_close>:
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	83 ec 28             	sub    $0x28,%esp
  801639:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  80163c:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  80163f:	8b 75 08             	mov    0x8(%ebp),%esi
  801642:	89 34 24             	mov    %esi,(%esp)
  801645:	e8 16 fc ff ff       	call   801260 <fd2num>
  80164a:	8d 55 f4             	lea    0xfffffff4(%ebp),%edx
  80164d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801651:	89 04 24             	mov    %eax,(%esp)
  801654:	e8 85 fc ff ff       	call   8012de <fd_lookup>
  801659:	89 c3                	mov    %eax,%ebx
  80165b:	85 c0                	test   %eax,%eax
  80165d:	78 05                	js     801664 <fd_close+0x31>
  80165f:	3b 75 f4             	cmp    0xfffffff4(%ebp),%esi
  801662:	74 0e                	je     801672 <fd_close+0x3f>
  801664:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801668:	75 45                	jne    8016af <fd_close+0x7c>
  80166a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80166f:	90                   	nop    
  801670:	eb 3d                	jmp    8016af <fd_close+0x7c>
  801672:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  801675:	89 44 24 04          	mov    %eax,0x4(%esp)
  801679:	8b 06                	mov    (%esi),%eax
  80167b:	89 04 24             	mov    %eax,(%esp)
  80167e:	e8 ce fc ff ff       	call   801351 <dev_lookup>
  801683:	89 c3                	mov    %eax,%ebx
  801685:	85 c0                	test   %eax,%eax
  801687:	78 16                	js     80169f <fd_close+0x6c>
  801689:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80168c:	8b 40 10             	mov    0x10(%eax),%eax
  80168f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801694:	85 c0                	test   %eax,%eax
  801696:	74 07                	je     80169f <fd_close+0x6c>
  801698:	89 34 24             	mov    %esi,(%esp)
  80169b:	ff d0                	call   *%eax
  80169d:	89 c3                	mov    %eax,%ebx
  80169f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016aa:	e8 cf f9 ff ff       	call   80107e <sys_page_unmap>
  8016af:	89 d8                	mov    %ebx,%eax
  8016b1:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  8016b4:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  8016b7:	89 ec                	mov    %ebp,%esp
  8016b9:	5d                   	pop    %ebp
  8016ba:	c3                   	ret    

008016bb <close>:
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	83 ec 18             	sub    $0x18,%esp
  8016c1:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  8016c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cb:	89 04 24             	mov    %eax,(%esp)
  8016ce:	e8 0b fc ff ff       	call   8012de <fd_lookup>
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	78 13                	js     8016ea <close+0x2f>
  8016d7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016de:	00 
  8016df:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  8016e2:	89 04 24             	mov    %eax,(%esp)
  8016e5:	e8 49 ff ff ff       	call   801633 <fd_close>
  8016ea:	c9                   	leave  
  8016eb:	c3                   	ret    

008016ec <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016ec:	55                   	push   %ebp
  8016ed:	89 e5                	mov    %esp,%ebp
  8016ef:	83 ec 18             	sub    $0x18,%esp
  8016f2:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  8016f5:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016ff:	00 
  801700:	8b 45 08             	mov    0x8(%ebp),%eax
  801703:	89 04 24             	mov    %eax,(%esp)
  801706:	e8 58 03 00 00       	call   801a63 <open>
  80170b:	89 c6                	mov    %eax,%esi
  80170d:	85 c0                	test   %eax,%eax
  80170f:	78 1b                	js     80172c <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801711:	8b 45 0c             	mov    0xc(%ebp),%eax
  801714:	89 44 24 04          	mov    %eax,0x4(%esp)
  801718:	89 34 24             	mov    %esi,(%esp)
  80171b:	e8 9d fc ff ff       	call   8013bd <fstat>
  801720:	89 c3                	mov    %eax,%ebx
	close(fd);
  801722:	89 34 24             	mov    %esi,(%esp)
  801725:	e8 91 ff ff ff       	call   8016bb <close>
  80172a:	89 de                	mov    %ebx,%esi
	return r;
}
  80172c:	89 f0                	mov    %esi,%eax
  80172e:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  801731:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  801734:	89 ec                	mov    %ebp,%esp
  801736:	5d                   	pop    %ebp
  801737:	c3                   	ret    

00801738 <dup>:
  801738:	55                   	push   %ebp
  801739:	89 e5                	mov    %esp,%ebp
  80173b:	83 ec 38             	sub    $0x38,%esp
  80173e:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801741:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  801744:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801747:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80174a:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  80174d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801751:	8b 45 08             	mov    0x8(%ebp),%eax
  801754:	89 04 24             	mov    %eax,(%esp)
  801757:	e8 82 fb ff ff       	call   8012de <fd_lookup>
  80175c:	89 c3                	mov    %eax,%ebx
  80175e:	85 c0                	test   %eax,%eax
  801760:	0f 88 e1 00 00 00    	js     801847 <dup+0x10f>
  801766:	89 3c 24             	mov    %edi,(%esp)
  801769:	e8 4d ff ff ff       	call   8016bb <close>
  80176e:	89 f8                	mov    %edi,%eax
  801770:	c1 e0 0c             	shl    $0xc,%eax
  801773:	8d b0 00 00 00 d0    	lea    0xd0000000(%eax),%esi
  801779:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80177c:	89 04 24             	mov    %eax,(%esp)
  80177f:	e8 ec fa ff ff       	call   801270 <fd2data>
  801784:	89 c3                	mov    %eax,%ebx
  801786:	89 34 24             	mov    %esi,(%esp)
  801789:	e8 e2 fa ff ff       	call   801270 <fd2data>
  80178e:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  801791:	89 d8                	mov    %ebx,%eax
  801793:	c1 e8 16             	shr    $0x16,%eax
  801796:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  80179d:	a8 01                	test   $0x1,%al
  80179f:	74 45                	je     8017e6 <dup+0xae>
  8017a1:	89 da                	mov    %ebx,%edx
  8017a3:	c1 ea 0c             	shr    $0xc,%edx
  8017a6:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  8017ad:	a8 01                	test   $0x1,%al
  8017af:	74 35                	je     8017e6 <dup+0xae>
  8017b1:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  8017b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8017bd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017c1:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  8017c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017c8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017cf:	00 
  8017d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017db:	e8 fc f8 ff ff       	call   8010dc <sys_page_map>
  8017e0:	89 c3                	mov    %eax,%ebx
  8017e2:	85 c0                	test   %eax,%eax
  8017e4:	78 3e                	js     801824 <dup+0xec>
  8017e6:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  8017e9:	89 d0                	mov    %edx,%eax
  8017eb:	c1 e8 0c             	shr    $0xc,%eax
  8017ee:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  8017f5:	25 07 0e 00 00       	and    $0xe07,%eax
  8017fa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017fe:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801802:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801809:	00 
  80180a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80180e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801815:	e8 c2 f8 ff ff       	call   8010dc <sys_page_map>
  80181a:	89 c3                	mov    %eax,%ebx
  80181c:	85 c0                	test   %eax,%eax
  80181e:	78 04                	js     801824 <dup+0xec>
  801820:	89 fb                	mov    %edi,%ebx
  801822:	eb 23                	jmp    801847 <dup+0x10f>
  801824:	89 74 24 04          	mov    %esi,0x4(%esp)
  801828:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80182f:	e8 4a f8 ff ff       	call   80107e <sys_page_unmap>
  801834:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801837:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801842:	e8 37 f8 ff ff       	call   80107e <sys_page_unmap>
  801847:	89 d8                	mov    %ebx,%eax
  801849:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  80184c:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  80184f:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801852:	89 ec                	mov    %ebp,%esp
  801854:	5d                   	pop    %ebp
  801855:	c3                   	ret    

00801856 <close_all>:
  801856:	55                   	push   %ebp
  801857:	89 e5                	mov    %esp,%ebp
  801859:	53                   	push   %ebx
  80185a:	83 ec 04             	sub    $0x4,%esp
  80185d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801862:	89 1c 24             	mov    %ebx,(%esp)
  801865:	e8 51 fe ff ff       	call   8016bb <close>
  80186a:	83 c3 01             	add    $0x1,%ebx
  80186d:	83 fb 20             	cmp    $0x20,%ebx
  801870:	75 f0                	jne    801862 <close_all+0xc>
  801872:	83 c4 04             	add    $0x4,%esp
  801875:	5b                   	pop    %ebx
  801876:	5d                   	pop    %ebp
  801877:	c3                   	ret    

00801878 <fsipc>:
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	53                   	push   %ebx
  80187c:	83 ec 14             	sub    $0x14,%esp
  80187f:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801881:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801887:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80188e:	00 
  80188f:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801896:	00 
  801897:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189b:	89 14 24             	mov    %edx,(%esp)
  80189e:	e8 9d 07 00 00       	call   802040 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018a3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018aa:	00 
  8018ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018b6:	e8 39 08 00 00       	call   8020f4 <ipc_recv>
}
  8018bb:	83 c4 14             	add    $0x14,%esp
  8018be:	5b                   	pop    %ebx
  8018bf:	5d                   	pop    %ebp
  8018c0:	c3                   	ret    

008018c1 <sync>:

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
  8018c1:	55                   	push   %ebp
  8018c2:	89 e5                	mov    %esp,%ebp
  8018c4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cc:	b8 08 00 00 00       	mov    $0x8,%eax
  8018d1:	e8 a2 ff ff ff       	call   801878 <fsipc>
}
  8018d6:	c9                   	leave  
  8018d7:	c3                   	ret    

008018d8 <devfile_trunc>:
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	83 ec 08             	sub    $0x8,%esp
  8018de:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e4:	a3 00 30 80 00       	mov    %eax,0x803000
  8018e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ec:	a3 04 30 80 00       	mov    %eax,0x803004
  8018f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f6:	b8 02 00 00 00       	mov    $0x2,%eax
  8018fb:	e8 78 ff ff ff       	call   801878 <fsipc>
  801900:	c9                   	leave  
  801901:	c3                   	ret    

00801902 <devfile_flush>:
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	83 ec 08             	sub    $0x8,%esp
  801908:	8b 45 08             	mov    0x8(%ebp),%eax
  80190b:	8b 40 0c             	mov    0xc(%eax),%eax
  80190e:	a3 00 30 80 00       	mov    %eax,0x803000
  801913:	ba 00 00 00 00       	mov    $0x0,%edx
  801918:	b8 06 00 00 00       	mov    $0x6,%eax
  80191d:	e8 56 ff ff ff       	call   801878 <fsipc>
  801922:	c9                   	leave  
  801923:	c3                   	ret    

00801924 <devfile_stat>:
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
  801927:	53                   	push   %ebx
  801928:	83 ec 14             	sub    $0x14,%esp
  80192b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80192e:	8b 45 08             	mov    0x8(%ebp),%eax
  801931:	8b 40 0c             	mov    0xc(%eax),%eax
  801934:	a3 00 30 80 00       	mov    %eax,0x803000
  801939:	ba 00 00 00 00       	mov    $0x0,%edx
  80193e:	b8 05 00 00 00       	mov    $0x5,%eax
  801943:	e8 30 ff ff ff       	call   801878 <fsipc>
  801948:	85 c0                	test   %eax,%eax
  80194a:	78 2b                	js     801977 <devfile_stat+0x53>
  80194c:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801953:	00 
  801954:	89 1c 24             	mov    %ebx,(%esp)
  801957:	e8 b5 f0 ff ff       	call   800a11 <strcpy>
  80195c:	a1 80 30 80 00       	mov    0x803080,%eax
  801961:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  801967:	a1 84 30 80 00       	mov    0x803084,%eax
  80196c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801972:	b8 00 00 00 00       	mov    $0x0,%eax
  801977:	83 c4 14             	add    $0x14,%esp
  80197a:	5b                   	pop    %ebx
  80197b:	5d                   	pop    %ebp
  80197c:	c3                   	ret    

0080197d <devfile_write>:
  80197d:	55                   	push   %ebp
  80197e:	89 e5                	mov    %esp,%ebp
  801980:	83 ec 18             	sub    $0x18,%esp
  801983:	8b 55 10             	mov    0x10(%ebp),%edx
  801986:	8b 45 08             	mov    0x8(%ebp),%eax
  801989:	8b 40 0c             	mov    0xc(%eax),%eax
  80198c:	a3 00 30 80 00       	mov    %eax,0x803000
  801991:	89 d0                	mov    %edx,%eax
  801993:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  801999:	76 05                	jbe    8019a0 <devfile_write+0x23>
  80199b:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  8019a0:	89 15 04 30 80 00    	mov    %edx,0x803004
  8019a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b1:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  8019b8:	e8 5d f2 ff ff       	call   800c1a <memmove>
  8019bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c2:	b8 04 00 00 00       	mov    $0x4,%eax
  8019c7:	e8 ac fe ff ff       	call   801878 <fsipc>
  8019cc:	c9                   	leave  
  8019cd:	c3                   	ret    

008019ce <devfile_read>:
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	53                   	push   %ebx
  8019d2:	83 ec 14             	sub    $0x14,%esp
  8019d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8019db:	a3 00 30 80 00       	mov    %eax,0x803000
  8019e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8019e3:	a3 04 30 80 00       	mov    %eax,0x803004
  8019e8:	ba 00 30 80 00       	mov    $0x803000,%edx
  8019ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8019f2:	e8 81 fe ff ff       	call   801878 <fsipc>
  8019f7:	89 c3                	mov    %eax,%ebx
  8019f9:	85 c0                	test   %eax,%eax
  8019fb:	7e 17                	jle    801a14 <devfile_read+0x46>
  8019fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a01:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801a08:	00 
  801a09:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0c:	89 04 24             	mov    %eax,(%esp)
  801a0f:	e8 06 f2 ff ff       	call   800c1a <memmove>
  801a14:	89 d8                	mov    %ebx,%eax
  801a16:	83 c4 14             	add    $0x14,%esp
  801a19:	5b                   	pop    %ebx
  801a1a:	5d                   	pop    %ebp
  801a1b:	c3                   	ret    

00801a1c <remove>:
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	53                   	push   %ebx
  801a20:	83 ec 14             	sub    $0x14,%esp
  801a23:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a26:	89 1c 24             	mov    %ebx,(%esp)
  801a29:	e8 92 ef ff ff       	call   8009c0 <strlen>
  801a2e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  801a33:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a38:	7f 21                	jg     801a5b <remove+0x3f>
  801a3a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a3e:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801a45:	e8 c7 ef ff ff       	call   800a11 <strcpy>
  801a4a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a4f:	b8 07 00 00 00       	mov    $0x7,%eax
  801a54:	e8 1f fe ff ff       	call   801878 <fsipc>
  801a59:	89 c2                	mov    %eax,%edx
  801a5b:	89 d0                	mov    %edx,%eax
  801a5d:	83 c4 14             	add    $0x14,%esp
  801a60:	5b                   	pop    %ebx
  801a61:	5d                   	pop    %ebp
  801a62:	c3                   	ret    

00801a63 <open>:
  801a63:	55                   	push   %ebp
  801a64:	89 e5                	mov    %esp,%ebp
  801a66:	56                   	push   %esi
  801a67:	53                   	push   %ebx
  801a68:	83 ec 30             	sub    $0x30,%esp
  801a6b:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801a6e:	89 04 24             	mov    %eax,(%esp)
  801a71:	e8 15 f8 ff ff       	call   80128b <fd_alloc>
  801a76:	89 c3                	mov    %eax,%ebx
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	79 18                	jns    801a94 <open+0x31>
  801a7c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a83:	00 
  801a84:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801a87:	89 04 24             	mov    %eax,(%esp)
  801a8a:	e8 a4 fb ff ff       	call   801633 <fd_close>
  801a8f:	e9 9f 00 00 00       	jmp    801b33 <open+0xd0>
  801a94:	8b 45 08             	mov    0x8(%ebp),%eax
  801a97:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9b:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801aa2:	e8 6a ef ff ff       	call   800a11 <strcpy>
  801aa7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aaa:	a3 00 34 80 00       	mov    %eax,0x803400
  801aaf:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801ab2:	89 04 24             	mov    %eax,(%esp)
  801ab5:	e8 b6 f7 ff ff       	call   801270 <fd2data>
  801aba:	89 c6                	mov    %eax,%esi
  801abc:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  801abf:	b8 01 00 00 00       	mov    $0x1,%eax
  801ac4:	e8 af fd ff ff       	call   801878 <fsipc>
  801ac9:	89 c3                	mov    %eax,%ebx
  801acb:	85 c0                	test   %eax,%eax
  801acd:	79 15                	jns    801ae4 <open+0x81>
  801acf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ad6:	00 
  801ad7:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801ada:	89 04 24             	mov    %eax,(%esp)
  801add:	e8 51 fb ff ff       	call   801633 <fd_close>
  801ae2:	eb 4f                	jmp    801b33 <open+0xd0>
  801ae4:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801aeb:	00 
  801aec:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801af0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801af7:	00 
  801af8:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801afb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b06:	e8 d1 f5 ff ff       	call   8010dc <sys_page_map>
  801b0b:	89 c3                	mov    %eax,%ebx
  801b0d:	85 c0                	test   %eax,%eax
  801b0f:	79 15                	jns    801b26 <open+0xc3>
  801b11:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801b18:	00 
  801b19:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801b1c:	89 04 24             	mov    %eax,(%esp)
  801b1f:	e8 0f fb ff ff       	call   801633 <fd_close>
  801b24:	eb 0d                	jmp    801b33 <open+0xd0>
  801b26:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801b29:	89 04 24             	mov    %eax,(%esp)
  801b2c:	e8 2f f7 ff ff       	call   801260 <fd2num>
  801b31:	89 c3                	mov    %eax,%ebx
  801b33:	89 d8                	mov    %ebx,%eax
  801b35:	83 c4 30             	add    $0x30,%esp
  801b38:	5b                   	pop    %ebx
  801b39:	5e                   	pop    %esi
  801b3a:	5d                   	pop    %ebp
  801b3b:	c3                   	ret    
  801b3c:	00 00                	add    %al,(%eax)
	...

00801b40 <devsock_stat>:
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  801b46:	c7 44 24 04 78 29 80 	movl   $0x802978,0x4(%esp)
  801b4d:	00 
  801b4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b51:	89 04 24             	mov    %eax,(%esp)
  801b54:	e8 b8 ee ff ff       	call   800a11 <strcpy>
	return 0;
}
  801b59:	b8 00 00 00 00       	mov    $0x0,%eax
  801b5e:	c9                   	leave  
  801b5f:	c3                   	ret    

00801b60 <devsock_close>:
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	83 ec 08             	sub    $0x8,%esp
  801b66:	8b 45 08             	mov    0x8(%ebp),%eax
  801b69:	8b 40 0c             	mov    0xc(%eax),%eax
  801b6c:	89 04 24             	mov    %eax,(%esp)
  801b6f:	e8 be 02 00 00       	call   801e32 <nsipc_close>
  801b74:	c9                   	leave  
  801b75:	c3                   	ret    

00801b76 <devsock_write>:
  801b76:	55                   	push   %ebp
  801b77:	89 e5                	mov    %esp,%ebp
  801b79:	83 ec 18             	sub    $0x18,%esp
  801b7c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b83:	00 
  801b84:	8b 45 10             	mov    0x10(%ebp),%eax
  801b87:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b92:	8b 45 08             	mov    0x8(%ebp),%eax
  801b95:	8b 40 0c             	mov    0xc(%eax),%eax
  801b98:	89 04 24             	mov    %eax,(%esp)
  801b9b:	e8 ce 02 00 00       	call   801e6e <nsipc_send>
  801ba0:	c9                   	leave  
  801ba1:	c3                   	ret    

00801ba2 <devsock_read>:
  801ba2:	55                   	push   %ebp
  801ba3:	89 e5                	mov    %esp,%ebp
  801ba5:	83 ec 18             	sub    $0x18,%esp
  801ba8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801baf:	00 
  801bb0:	8b 45 10             	mov    0x10(%ebp),%eax
  801bb3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bba:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc1:	8b 40 0c             	mov    0xc(%eax),%eax
  801bc4:	89 04 24             	mov    %eax,(%esp)
  801bc7:	e8 15 03 00 00       	call   801ee1 <nsipc_recv>
  801bcc:	c9                   	leave  
  801bcd:	c3                   	ret    

00801bce <alloc_sockfd>:
  801bce:	55                   	push   %ebp
  801bcf:	89 e5                	mov    %esp,%ebp
  801bd1:	56                   	push   %esi
  801bd2:	53                   	push   %ebx
  801bd3:	83 ec 20             	sub    $0x20,%esp
  801bd6:	89 c6                	mov    %eax,%esi
  801bd8:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801bdb:	89 04 24             	mov    %eax,(%esp)
  801bde:	e8 a8 f6 ff ff       	call   80128b <fd_alloc>
  801be3:	89 c3                	mov    %eax,%ebx
  801be5:	85 c0                	test   %eax,%eax
  801be7:	78 21                	js     801c0a <alloc_sockfd+0x3c>
  801be9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801bf0:	00 
  801bf1:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801bf4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bff:	e8 36 f5 ff ff       	call   80113a <sys_page_alloc>
  801c04:	89 c3                	mov    %eax,%ebx
  801c06:	85 c0                	test   %eax,%eax
  801c08:	79 0a                	jns    801c14 <alloc_sockfd+0x46>
  801c0a:	89 34 24             	mov    %esi,(%esp)
  801c0d:	e8 20 02 00 00       	call   801e32 <nsipc_close>
  801c12:	eb 28                	jmp    801c3c <alloc_sockfd+0x6e>
  801c14:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801c1a:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801c1d:	89 10                	mov    %edx,(%eax)
  801c1f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801c22:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  801c29:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801c2c:	89 70 0c             	mov    %esi,0xc(%eax)
  801c2f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801c32:	89 04 24             	mov    %eax,(%esp)
  801c35:	e8 26 f6 ff ff       	call   801260 <fd2num>
  801c3a:	89 c3                	mov    %eax,%ebx
  801c3c:	89 d8                	mov    %ebx,%eax
  801c3e:	83 c4 20             	add    $0x20,%esp
  801c41:	5b                   	pop    %ebx
  801c42:	5e                   	pop    %esi
  801c43:	5d                   	pop    %ebp
  801c44:	c3                   	ret    

00801c45 <socket>:

int
socket(int domain, int type, int protocol)
{
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c4b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c59:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5c:	89 04 24             	mov    %eax,(%esp)
  801c5f:	e8 82 01 00 00       	call   801de6 <nsipc_socket>
  801c64:	85 c0                	test   %eax,%eax
  801c66:	78 05                	js     801c6d <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801c68:	e8 61 ff ff ff       	call   801bce <alloc_sockfd>
}
  801c6d:	c9                   	leave  
  801c6e:	66 90                	xchg   %ax,%ax
  801c70:	c3                   	ret    

00801c71 <fd2sockid>:
  801c71:	55                   	push   %ebp
  801c72:	89 e5                	mov    %esp,%ebp
  801c74:	83 ec 18             	sub    $0x18,%esp
  801c77:	8d 55 fc             	lea    0xfffffffc(%ebp),%edx
  801c7a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c7e:	89 04 24             	mov    %eax,(%esp)
  801c81:	e8 58 f6 ff ff       	call   8012de <fd_lookup>
  801c86:	89 c2                	mov    %eax,%edx
  801c88:	85 c0                	test   %eax,%eax
  801c8a:	78 15                	js     801ca1 <fd2sockid+0x30>
  801c8c:	8b 4d fc             	mov    0xfffffffc(%ebp),%ecx
  801c8f:	8b 01                	mov    (%ecx),%eax
  801c91:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  801c96:	3b 05 20 60 80 00    	cmp    0x806020,%eax
  801c9c:	75 03                	jne    801ca1 <fd2sockid+0x30>
  801c9e:	8b 51 0c             	mov    0xc(%ecx),%edx
  801ca1:	89 d0                	mov    %edx,%eax
  801ca3:	c9                   	leave  
  801ca4:	c3                   	ret    

00801ca5 <listen>:
  801ca5:	55                   	push   %ebp
  801ca6:	89 e5                	mov    %esp,%ebp
  801ca8:	83 ec 08             	sub    $0x8,%esp
  801cab:	8b 45 08             	mov    0x8(%ebp),%eax
  801cae:	e8 be ff ff ff       	call   801c71 <fd2sockid>
  801cb3:	89 c2                	mov    %eax,%edx
  801cb5:	85 c0                	test   %eax,%eax
  801cb7:	78 11                	js     801cca <listen+0x25>
  801cb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc0:	89 14 24             	mov    %edx,(%esp)
  801cc3:	e8 48 01 00 00       	call   801e10 <nsipc_listen>
  801cc8:	89 c2                	mov    %eax,%edx
  801cca:	89 d0                	mov    %edx,%eax
  801ccc:	c9                   	leave  
  801ccd:	c3                   	ret    

00801cce <connect>:
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	83 ec 18             	sub    $0x18,%esp
  801cd4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd7:	e8 95 ff ff ff       	call   801c71 <fd2sockid>
  801cdc:	89 c2                	mov    %eax,%edx
  801cde:	85 c0                	test   %eax,%eax
  801ce0:	78 18                	js     801cfa <connect+0x2c>
  801ce2:	8b 45 10             	mov    0x10(%ebp),%eax
  801ce5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ce9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cec:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf0:	89 14 24             	mov    %edx,(%esp)
  801cf3:	e8 71 02 00 00       	call   801f69 <nsipc_connect>
  801cf8:	89 c2                	mov    %eax,%edx
  801cfa:	89 d0                	mov    %edx,%eax
  801cfc:	c9                   	leave  
  801cfd:	c3                   	ret    

00801cfe <shutdown>:
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	83 ec 08             	sub    $0x8,%esp
  801d04:	8b 45 08             	mov    0x8(%ebp),%eax
  801d07:	e8 65 ff ff ff       	call   801c71 <fd2sockid>
  801d0c:	89 c2                	mov    %eax,%edx
  801d0e:	85 c0                	test   %eax,%eax
  801d10:	78 11                	js     801d23 <shutdown+0x25>
  801d12:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d15:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d19:	89 14 24             	mov    %edx,(%esp)
  801d1c:	e8 2b 01 00 00       	call   801e4c <nsipc_shutdown>
  801d21:	89 c2                	mov    %eax,%edx
  801d23:	89 d0                	mov    %edx,%eax
  801d25:	c9                   	leave  
  801d26:	c3                   	ret    

00801d27 <bind>:
  801d27:	55                   	push   %ebp
  801d28:	89 e5                	mov    %esp,%ebp
  801d2a:	83 ec 18             	sub    $0x18,%esp
  801d2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d30:	e8 3c ff ff ff       	call   801c71 <fd2sockid>
  801d35:	89 c2                	mov    %eax,%edx
  801d37:	85 c0                	test   %eax,%eax
  801d39:	78 18                	js     801d53 <bind+0x2c>
  801d3b:	8b 45 10             	mov    0x10(%ebp),%eax
  801d3e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d42:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d45:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d49:	89 14 24             	mov    %edx,(%esp)
  801d4c:	e8 57 02 00 00       	call   801fa8 <nsipc_bind>
  801d51:	89 c2                	mov    %eax,%edx
  801d53:	89 d0                	mov    %edx,%eax
  801d55:	c9                   	leave  
  801d56:	c3                   	ret    

00801d57 <accept>:
  801d57:	55                   	push   %ebp
  801d58:	89 e5                	mov    %esp,%ebp
  801d5a:	83 ec 18             	sub    $0x18,%esp
  801d5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d60:	e8 0c ff ff ff       	call   801c71 <fd2sockid>
  801d65:	89 c2                	mov    %eax,%edx
  801d67:	85 c0                	test   %eax,%eax
  801d69:	78 23                	js     801d8e <accept+0x37>
  801d6b:	8b 45 10             	mov    0x10(%ebp),%eax
  801d6e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d72:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d75:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d79:	89 14 24             	mov    %edx,(%esp)
  801d7c:	e8 66 02 00 00       	call   801fe7 <nsipc_accept>
  801d81:	89 c2                	mov    %eax,%edx
  801d83:	85 c0                	test   %eax,%eax
  801d85:	78 07                	js     801d8e <accept+0x37>
  801d87:	e8 42 fe ff ff       	call   801bce <alloc_sockfd>
  801d8c:	89 c2                	mov    %eax,%edx
  801d8e:	89 d0                	mov    %edx,%eax
  801d90:	c9                   	leave  
  801d91:	c3                   	ret    
	...

00801da0 <nsipc>:
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
  801da3:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801da6:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  801dac:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801db3:	00 
  801db4:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801dbb:	00 
  801dbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dc0:	89 14 24             	mov    %edx,(%esp)
  801dc3:	e8 78 02 00 00       	call   802040 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801dc8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801dcf:	00 
  801dd0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801dd7:	00 
  801dd8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ddf:	e8 10 03 00 00       	call   8020f4 <ipc_recv>
}
  801de4:	c9                   	leave  
  801de5:	c3                   	ret    

00801de6 <nsipc_socket>:

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
  801de6:	55                   	push   %ebp
  801de7:	89 e5                	mov    %esp,%ebp
  801de9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801dec:	8b 45 08             	mov    0x8(%ebp),%eax
  801def:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.socket.req_type = type;
  801df4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df7:	a3 04 50 80 00       	mov    %eax,0x805004
	nsipcbuf.socket.req_protocol = protocol;
  801dfc:	8b 45 10             	mov    0x10(%ebp),%eax
  801dff:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SOCKET);
  801e04:	b8 09 00 00 00       	mov    $0x9,%eax
  801e09:	e8 92 ff ff ff       	call   801da0 <nsipc>
}
  801e0e:	c9                   	leave  
  801e0f:	c3                   	ret    

00801e10 <nsipc_listen>:
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	83 ec 08             	sub    $0x8,%esp
  801e16:	8b 45 08             	mov    0x8(%ebp),%eax
  801e19:	a3 00 50 80 00       	mov    %eax,0x805000
  801e1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e21:	a3 04 50 80 00       	mov    %eax,0x805004
  801e26:	b8 06 00 00 00       	mov    $0x6,%eax
  801e2b:	e8 70 ff ff ff       	call   801da0 <nsipc>
  801e30:	c9                   	leave  
  801e31:	c3                   	ret    

00801e32 <nsipc_close>:
  801e32:	55                   	push   %ebp
  801e33:	89 e5                	mov    %esp,%ebp
  801e35:	83 ec 08             	sub    $0x8,%esp
  801e38:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3b:	a3 00 50 80 00       	mov    %eax,0x805000
  801e40:	b8 04 00 00 00       	mov    $0x4,%eax
  801e45:	e8 56 ff ff ff       	call   801da0 <nsipc>
  801e4a:	c9                   	leave  
  801e4b:	c3                   	ret    

00801e4c <nsipc_shutdown>:
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	83 ec 08             	sub    $0x8,%esp
  801e52:	8b 45 08             	mov    0x8(%ebp),%eax
  801e55:	a3 00 50 80 00       	mov    %eax,0x805000
  801e5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e5d:	a3 04 50 80 00       	mov    %eax,0x805004
  801e62:	b8 03 00 00 00       	mov    $0x3,%eax
  801e67:	e8 34 ff ff ff       	call   801da0 <nsipc>
  801e6c:	c9                   	leave  
  801e6d:	c3                   	ret    

00801e6e <nsipc_send>:
  801e6e:	55                   	push   %ebp
  801e6f:	89 e5                	mov    %esp,%ebp
  801e71:	53                   	push   %ebx
  801e72:	83 ec 14             	sub    $0x14,%esp
  801e75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e78:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7b:	a3 00 50 80 00       	mov    %eax,0x805000
  801e80:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e86:	7e 24                	jle    801eac <nsipc_send+0x3e>
  801e88:	c7 44 24 0c 84 29 80 	movl   $0x802984,0xc(%esp)
  801e8f:	00 
  801e90:	c7 44 24 08 90 29 80 	movl   $0x802990,0x8(%esp)
  801e97:	00 
  801e98:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  801e9f:	00 
  801ea0:	c7 04 24 a5 29 80 00 	movl   $0x8029a5,(%esp)
  801ea7:	e8 10 e4 ff ff       	call   8002bc <_panic>
  801eac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801eb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb7:	c7 04 24 0c 50 80 00 	movl   $0x80500c,(%esp)
  801ebe:	e8 57 ed ff ff       	call   800c1a <memmove>
  801ec3:	89 1d 04 50 80 00    	mov    %ebx,0x805004
  801ec9:	8b 45 14             	mov    0x14(%ebp),%eax
  801ecc:	a3 08 50 80 00       	mov    %eax,0x805008
  801ed1:	b8 08 00 00 00       	mov    $0x8,%eax
  801ed6:	e8 c5 fe ff ff       	call   801da0 <nsipc>
  801edb:	83 c4 14             	add    $0x14,%esp
  801ede:	5b                   	pop    %ebx
  801edf:	5d                   	pop    %ebp
  801ee0:	c3                   	ret    

00801ee1 <nsipc_recv>:
  801ee1:	55                   	push   %ebp
  801ee2:	89 e5                	mov    %esp,%ebp
  801ee4:	83 ec 18             	sub    $0x18,%esp
  801ee7:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  801eea:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  801eed:	8b 75 10             	mov    0x10(%ebp),%esi
  801ef0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef3:	a3 00 50 80 00       	mov    %eax,0x805000
  801ef8:	89 35 04 50 80 00    	mov    %esi,0x805004
  801efe:	8b 45 14             	mov    0x14(%ebp),%eax
  801f01:	a3 08 50 80 00       	mov    %eax,0x805008
  801f06:	b8 07 00 00 00       	mov    $0x7,%eax
  801f0b:	e8 90 fe ff ff       	call   801da0 <nsipc>
  801f10:	89 c3                	mov    %eax,%ebx
  801f12:	85 c0                	test   %eax,%eax
  801f14:	78 47                	js     801f5d <nsipc_recv+0x7c>
  801f16:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801f1b:	7f 05                	jg     801f22 <nsipc_recv+0x41>
  801f1d:	39 c6                	cmp    %eax,%esi
  801f1f:	90                   	nop    
  801f20:	7d 24                	jge    801f46 <nsipc_recv+0x65>
  801f22:	c7 44 24 0c b1 29 80 	movl   $0x8029b1,0xc(%esp)
  801f29:	00 
  801f2a:	c7 44 24 08 90 29 80 	movl   $0x802990,0x8(%esp)
  801f31:	00 
  801f32:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  801f39:	00 
  801f3a:	c7 04 24 a5 29 80 00 	movl   $0x8029a5,(%esp)
  801f41:	e8 76 e3 ff ff       	call   8002bc <_panic>
  801f46:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f4a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801f51:	00 
  801f52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f55:	89 04 24             	mov    %eax,(%esp)
  801f58:	e8 bd ec ff ff       	call   800c1a <memmove>
  801f5d:	89 d8                	mov    %ebx,%eax
  801f5f:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  801f62:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  801f65:	89 ec                	mov    %ebp,%esp
  801f67:	5d                   	pop    %ebp
  801f68:	c3                   	ret    

00801f69 <nsipc_connect>:
  801f69:	55                   	push   %ebp
  801f6a:	89 e5                	mov    %esp,%ebp
  801f6c:	53                   	push   %ebx
  801f6d:	83 ec 14             	sub    $0x14,%esp
  801f70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f73:	8b 45 08             	mov    0x8(%ebp),%eax
  801f76:	a3 00 50 80 00       	mov    %eax,0x805000
  801f7b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f82:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f86:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801f8d:	e8 88 ec ff ff       	call   800c1a <memmove>
  801f92:	89 1d 14 50 80 00    	mov    %ebx,0x805014
  801f98:	b8 05 00 00 00       	mov    $0x5,%eax
  801f9d:	e8 fe fd ff ff       	call   801da0 <nsipc>
  801fa2:	83 c4 14             	add    $0x14,%esp
  801fa5:	5b                   	pop    %ebx
  801fa6:	5d                   	pop    %ebp
  801fa7:	c3                   	ret    

00801fa8 <nsipc_bind>:
  801fa8:	55                   	push   %ebp
  801fa9:	89 e5                	mov    %esp,%ebp
  801fab:	53                   	push   %ebx
  801fac:	83 ec 14             	sub    $0x14,%esp
  801faf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb5:	a3 00 50 80 00       	mov    %eax,0x805000
  801fba:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fc5:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801fcc:	e8 49 ec ff ff       	call   800c1a <memmove>
  801fd1:	89 1d 14 50 80 00    	mov    %ebx,0x805014
  801fd7:	b8 02 00 00 00       	mov    $0x2,%eax
  801fdc:	e8 bf fd ff ff       	call   801da0 <nsipc>
  801fe1:	83 c4 14             	add    $0x14,%esp
  801fe4:	5b                   	pop    %ebx
  801fe5:	5d                   	pop    %ebp
  801fe6:	c3                   	ret    

00801fe7 <nsipc_accept>:
  801fe7:	55                   	push   %ebp
  801fe8:	89 e5                	mov    %esp,%ebp
  801fea:	53                   	push   %ebx
  801feb:	83 ec 14             	sub    $0x14,%esp
  801fee:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff1:	a3 00 50 80 00       	mov    %eax,0x805000
  801ff6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ffb:	e8 a0 fd ff ff       	call   801da0 <nsipc>
  802000:	89 c3                	mov    %eax,%ebx
  802002:	85 c0                	test   %eax,%eax
  802004:	78 27                	js     80202d <nsipc_accept+0x46>
  802006:	a1 10 50 80 00       	mov    0x805010,%eax
  80200b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80200f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  802016:	00 
  802017:	8b 45 0c             	mov    0xc(%ebp),%eax
  80201a:	89 04 24             	mov    %eax,(%esp)
  80201d:	e8 f8 eb ff ff       	call   800c1a <memmove>
  802022:	8b 15 10 50 80 00    	mov    0x805010,%edx
  802028:	8b 45 10             	mov    0x10(%ebp),%eax
  80202b:	89 10                	mov    %edx,(%eax)
  80202d:	89 d8                	mov    %ebx,%eax
  80202f:	83 c4 14             	add    $0x14,%esp
  802032:	5b                   	pop    %ebx
  802033:	5d                   	pop    %ebp
  802034:	c3                   	ret    
	...

00802040 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802040:	55                   	push   %ebp
  802041:	89 e5                	mov    %esp,%ebp
  802043:	57                   	push   %edi
  802044:	56                   	push   %esi
  802045:	53                   	push   %ebx
  802046:	83 ec 1c             	sub    $0x1c,%esp
  802049:	8b 75 08             	mov    0x8(%ebp),%esi
  80204c:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  80204f:	e8 79 f1 ff ff       	call   8011cd <sys_getenvid>
  802054:	25 ff 03 00 00       	and    $0x3ff,%eax
  802059:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80205c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802061:	a3 3c 60 80 00       	mov    %eax,0x80603c
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  802066:	e8 62 f1 ff ff       	call   8011cd <sys_getenvid>
  80206b:	25 ff 03 00 00       	and    $0x3ff,%eax
  802070:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802078:	a3 3c 60 80 00       	mov    %eax,0x80603c
		if(env->env_id==to_env){
  80207d:	8b 40 4c             	mov    0x4c(%eax),%eax
  802080:	39 f0                	cmp    %esi,%eax
  802082:	75 0e                	jne    802092 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  802084:	c7 04 24 c6 29 80 00 	movl   $0x8029c6,(%esp)
  80208b:	e8 f9 e2 ff ff       	call   800389 <cprintf>
  802090:	eb 5a                	jmp    8020ec <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  802092:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802096:	8b 45 10             	mov    0x10(%ebp),%eax
  802099:	89 44 24 08          	mov    %eax,0x8(%esp)
  80209d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a4:	89 34 24             	mov    %esi,(%esp)
  8020a7:	e8 80 ee ff ff       	call   800f2c <sys_ipc_try_send>
  8020ac:	89 c3                	mov    %eax,%ebx
  8020ae:	85 c0                	test   %eax,%eax
  8020b0:	79 25                	jns    8020d7 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  8020b2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020b5:	74 2b                	je     8020e2 <ipc_send+0xa2>
				panic("send error:%e",r);
  8020b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020bb:	c7 44 24 08 e2 29 80 	movl   $0x8029e2,0x8(%esp)
  8020c2:	00 
  8020c3:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8020ca:	00 
  8020cb:	c7 04 24 f0 29 80 00 	movl   $0x8029f0,(%esp)
  8020d2:	e8 e5 e1 ff ff       	call   8002bc <_panic>
		}
			sys_yield();
  8020d7:	e8 bd f0 ff ff       	call   801199 <sys_yield>
		
	}while(r!=0);
  8020dc:	85 db                	test   %ebx,%ebx
  8020de:	75 86                	jne    802066 <ipc_send+0x26>
  8020e0:	eb 0a                	jmp    8020ec <ipc_send+0xac>
  8020e2:	e8 b2 f0 ff ff       	call   801199 <sys_yield>
  8020e7:	e9 7a ff ff ff       	jmp    802066 <ipc_send+0x26>
	return;
	//panic("ipc_send not implemented");
}
  8020ec:	83 c4 1c             	add    $0x1c,%esp
  8020ef:	5b                   	pop    %ebx
  8020f0:	5e                   	pop    %esi
  8020f1:	5f                   	pop    %edi
  8020f2:	5d                   	pop    %ebp
  8020f3:	c3                   	ret    

008020f4 <ipc_recv>:
  8020f4:	55                   	push   %ebp
  8020f5:	89 e5                	mov    %esp,%ebp
  8020f7:	57                   	push   %edi
  8020f8:	56                   	push   %esi
  8020f9:	53                   	push   %ebx
  8020fa:	83 ec 0c             	sub    $0xc,%esp
  8020fd:	8b 75 08             	mov    0x8(%ebp),%esi
  802100:	8b 7d 10             	mov    0x10(%ebp),%edi
  802103:	e8 c5 f0 ff ff       	call   8011cd <sys_getenvid>
  802108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80210d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802115:	a3 3c 60 80 00       	mov    %eax,0x80603c
  80211a:	85 f6                	test   %esi,%esi
  80211c:	74 29                	je     802147 <ipc_recv+0x53>
  80211e:	8b 40 4c             	mov    0x4c(%eax),%eax
  802121:	3b 06                	cmp    (%esi),%eax
  802123:	75 22                	jne    802147 <ipc_recv+0x53>
  802125:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80212b:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  802131:	c7 04 24 c6 29 80 00 	movl   $0x8029c6,(%esp)
  802138:	e8 4c e2 ff ff       	call   800389 <cprintf>
  80213d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802142:	e9 8a 00 00 00       	jmp    8021d1 <ipc_recv+0xdd>
  802147:	e8 81 f0 ff ff       	call   8011cd <sys_getenvid>
  80214c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802151:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802154:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802159:	a3 3c 60 80 00       	mov    %eax,0x80603c
  80215e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802161:	89 04 24             	mov    %eax,(%esp)
  802164:	e8 66 ed ff ff       	call   800ecf <sys_ipc_recv>
  802169:	89 c3                	mov    %eax,%ebx
  80216b:	85 c0                	test   %eax,%eax
  80216d:	79 1a                	jns    802189 <ipc_recv+0x95>
  80216f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802175:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  80217b:	c7 04 24 fa 29 80 00 	movl   $0x8029fa,(%esp)
  802182:	e8 02 e2 ff ff       	call   800389 <cprintf>
  802187:	eb 48                	jmp    8021d1 <ipc_recv+0xdd>
  802189:	e8 3f f0 ff ff       	call   8011cd <sys_getenvid>
  80218e:	25 ff 03 00 00       	and    $0x3ff,%eax
  802193:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802196:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80219b:	a3 3c 60 80 00       	mov    %eax,0x80603c
  8021a0:	85 f6                	test   %esi,%esi
  8021a2:	74 05                	je     8021a9 <ipc_recv+0xb5>
  8021a4:	8b 40 74             	mov    0x74(%eax),%eax
  8021a7:	89 06                	mov    %eax,(%esi)
  8021a9:	85 ff                	test   %edi,%edi
  8021ab:	74 0a                	je     8021b7 <ipc_recv+0xc3>
  8021ad:	a1 3c 60 80 00       	mov    0x80603c,%eax
  8021b2:	8b 40 78             	mov    0x78(%eax),%eax
  8021b5:	89 07                	mov    %eax,(%edi)
  8021b7:	e8 11 f0 ff ff       	call   8011cd <sys_getenvid>
  8021bc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8021c1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8021c4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021c9:	a3 3c 60 80 00       	mov    %eax,0x80603c
  8021ce:	8b 58 70             	mov    0x70(%eax),%ebx
  8021d1:	89 d8                	mov    %ebx,%eax
  8021d3:	83 c4 0c             	add    $0xc,%esp
  8021d6:	5b                   	pop    %ebx
  8021d7:	5e                   	pop    %esi
  8021d8:	5f                   	pop    %edi
  8021d9:	5d                   	pop    %ebp
  8021da:	c3                   	ret    
  8021db:	00 00                	add    %al,(%eax)
  8021dd:	00 00                	add    %al,(%eax)
	...

008021e0 <__udivdi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	89 e5                	mov    %esp,%ebp
  8021e3:	57                   	push   %edi
  8021e4:	56                   	push   %esi
  8021e5:	83 ec 1c             	sub    $0x1c,%esp
  8021e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8021eb:	8b 55 14             	mov    0x14(%ebp),%edx
  8021ee:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8021f1:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  8021f4:	89 c1                	mov    %eax,%ecx
  8021f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f9:	85 d2                	test   %edx,%edx
  8021fb:	89 d6                	mov    %edx,%esi
  8021fd:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
  802200:	75 1e                	jne    802220 <__udivdi3+0x40>
  802202:	39 f9                	cmp    %edi,%ecx
  802204:	0f 86 8d 00 00 00    	jbe    802297 <__udivdi3+0xb7>
  80220a:	89 fa                	mov    %edi,%edx
  80220c:	f7 f1                	div    %ecx
  80220e:	89 c1                	mov    %eax,%ecx
  802210:	89 c8                	mov    %ecx,%eax
  802212:	89 f2                	mov    %esi,%edx
  802214:	83 c4 1c             	add    $0x1c,%esp
  802217:	5e                   	pop    %esi
  802218:	5f                   	pop    %edi
  802219:	5d                   	pop    %ebp
  80221a:	c3                   	ret    
  80221b:	90                   	nop    
  80221c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802220:	39 fa                	cmp    %edi,%edx
  802222:	0f 87 98 00 00 00    	ja     8022c0 <__udivdi3+0xe0>
  802228:	0f bd c2             	bsr    %edx,%eax
  80222b:	83 f0 1f             	xor    $0x1f,%eax
  80222e:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  802231:	74 7f                	je     8022b2 <__udivdi3+0xd2>
  802233:	b8 20 00 00 00       	mov    $0x20,%eax
  802238:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  80223b:	2b 45 e4             	sub    0xffffffe4(%ebp),%eax
  80223e:	89 c1                	mov    %eax,%ecx
  802240:	d3 ea                	shr    %cl,%edx
  802242:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802246:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  802249:	89 f0                	mov    %esi,%eax
  80224b:	d3 e0                	shl    %cl,%eax
  80224d:	09 c2                	or     %eax,%edx
  80224f:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802252:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  802255:	89 fa                	mov    %edi,%edx
  802257:	d3 e0                	shl    %cl,%eax
  802259:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  80225d:	89 45 f4             	mov    %eax,0xfffffff4(%ebp)
  802260:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802263:	d3 e8                	shr    %cl,%eax
  802265:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802269:	d3 e2                	shl    %cl,%edx
  80226b:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  80226f:	09 d0                	or     %edx,%eax
  802271:	d3 ef                	shr    %cl,%edi
  802273:	89 fa                	mov    %edi,%edx
  802275:	f7 75 e0             	divl   0xffffffe0(%ebp)
  802278:	89 d1                	mov    %edx,%ecx
  80227a:	89 c7                	mov    %eax,%edi
  80227c:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80227f:	f7 e7                	mul    %edi
  802281:	39 d1                	cmp    %edx,%ecx
  802283:	89 c6                	mov    %eax,%esi
  802285:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  802288:	72 6f                	jb     8022f9 <__udivdi3+0x119>
  80228a:	39 ca                	cmp    %ecx,%edx
  80228c:	74 5e                	je     8022ec <__udivdi3+0x10c>
  80228e:	89 f9                	mov    %edi,%ecx
  802290:	31 f6                	xor    %esi,%esi
  802292:	e9 79 ff ff ff       	jmp    802210 <__udivdi3+0x30>
  802297:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80229a:	85 c0                	test   %eax,%eax
  80229c:	74 32                	je     8022d0 <__udivdi3+0xf0>
  80229e:	89 f2                	mov    %esi,%edx
  8022a0:	89 f8                	mov    %edi,%eax
  8022a2:	f7 f1                	div    %ecx
  8022a4:	89 c6                	mov    %eax,%esi
  8022a6:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8022a9:	f7 f1                	div    %ecx
  8022ab:	89 c1                	mov    %eax,%ecx
  8022ad:	e9 5e ff ff ff       	jmp    802210 <__udivdi3+0x30>
  8022b2:	39 d7                	cmp    %edx,%edi
  8022b4:	77 2a                	ja     8022e0 <__udivdi3+0x100>
  8022b6:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  8022b9:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  8022bc:	73 22                	jae    8022e0 <__udivdi3+0x100>
  8022be:	66 90                	xchg   %ax,%ax
  8022c0:	31 c9                	xor    %ecx,%ecx
  8022c2:	31 f6                	xor    %esi,%esi
  8022c4:	e9 47 ff ff ff       	jmp    802210 <__udivdi3+0x30>
  8022c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  8022d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8022d5:	31 d2                	xor    %edx,%edx
  8022d7:	f7 75 f0             	divl   0xfffffff0(%ebp)
  8022da:	89 c1                	mov    %eax,%ecx
  8022dc:	eb c0                	jmp    80229e <__udivdi3+0xbe>
  8022de:	66 90                	xchg   %ax,%ax
  8022e0:	b9 01 00 00 00       	mov    $0x1,%ecx
  8022e5:	31 f6                	xor    %esi,%esi
  8022e7:	e9 24 ff ff ff       	jmp    802210 <__udivdi3+0x30>
  8022ec:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8022ef:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8022f3:	d3 e0                	shl    %cl,%eax
  8022f5:	39 c6                	cmp    %eax,%esi
  8022f7:	76 95                	jbe    80228e <__udivdi3+0xae>
  8022f9:	8d 4f ff             	lea    0xffffffff(%edi),%ecx
  8022fc:	31 f6                	xor    %esi,%esi
  8022fe:	e9 0d ff ff ff       	jmp    802210 <__udivdi3+0x30>
	...

00802310 <__umoddi3>:
  802310:	55                   	push   %ebp
  802311:	89 e5                	mov    %esp,%ebp
  802313:	57                   	push   %edi
  802314:	56                   	push   %esi
  802315:	83 ec 30             	sub    $0x30,%esp
  802318:	8b 55 14             	mov    0x14(%ebp),%edx
  80231b:	8b 45 10             	mov    0x10(%ebp),%eax
  80231e:	8b 75 08             	mov    0x8(%ebp),%esi
  802321:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802324:	85 d2                	test   %edx,%edx
  802326:	c7 45 d0 00 00 00 00 	movl   $0x0,0xffffffd0(%ebp)
  80232d:	89 c1                	mov    %eax,%ecx
  80232f:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  802336:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  802339:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  80233c:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  80233f:	89 7d e0             	mov    %edi,0xffffffe0(%ebp)
  802342:	75 1c                	jne    802360 <__umoddi3+0x50>
  802344:	39 f8                	cmp    %edi,%eax
  802346:	89 fa                	mov    %edi,%edx
  802348:	0f 86 d4 00 00 00    	jbe    802422 <__umoddi3+0x112>
  80234e:	89 f0                	mov    %esi,%eax
  802350:	f7 f1                	div    %ecx
  802352:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802355:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  80235c:	eb 12                	jmp    802370 <__umoddi3+0x60>
  80235e:	66 90                	xchg   %ax,%ax
  802360:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802363:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  802366:	76 18                	jbe    802380 <__umoddi3+0x70>
  802368:	89 75 d0             	mov    %esi,0xffffffd0(%ebp)
  80236b:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  80236e:	66 90                	xchg   %ax,%ax
  802370:	8b 45 d0             	mov    0xffffffd0(%ebp),%eax
  802373:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  802376:	83 c4 30             	add    $0x30,%esp
  802379:	5e                   	pop    %esi
  80237a:	5f                   	pop    %edi
  80237b:	5d                   	pop    %ebp
  80237c:	c3                   	ret    
  80237d:	8d 76 00             	lea    0x0(%esi),%esi
  802380:	0f bd 45 e8          	bsr    0xffffffe8(%ebp),%eax
  802384:	83 f0 1f             	xor    $0x1f,%eax
  802387:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  80238a:	0f 84 c0 00 00 00    	je     802450 <__umoddi3+0x140>
  802390:	b8 20 00 00 00       	mov    $0x20,%eax
  802395:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  802398:	2b 45 dc             	sub    0xffffffdc(%ebp),%eax
  80239b:	8b 7d ec             	mov    0xffffffec(%ebp),%edi
  80239e:	8b 75 f0             	mov    0xfffffff0(%ebp),%esi
  8023a1:	89 c1                	mov    %eax,%ecx
  8023a3:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8023a6:	d3 ea                	shr    %cl,%edx
  8023a8:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8023ab:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  8023af:	d3 e0                	shl    %cl,%eax
  8023b1:	09 c2                	or     %eax,%edx
  8023b3:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8023b6:	d3 e7                	shl    %cl,%edi
  8023b8:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8023bc:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  8023bf:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  8023c2:	d3 e8                	shr    %cl,%eax
  8023c4:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  8023c8:	d3 e2                	shl    %cl,%edx
  8023ca:	09 d0                	or     %edx,%eax
  8023cc:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  8023cf:	d3 e6                	shl    %cl,%esi
  8023d1:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8023d5:	d3 ea                	shr    %cl,%edx
  8023d7:	f7 75 f4             	divl   0xfffffff4(%ebp)
  8023da:	89 55 cc             	mov    %edx,0xffffffcc(%ebp)
  8023dd:	f7 e7                	mul    %edi
  8023df:	39 55 cc             	cmp    %edx,0xffffffcc(%ebp)
  8023e2:	0f 82 a5 00 00 00    	jb     80248d <__umoddi3+0x17d>
  8023e8:	3b 55 cc             	cmp    0xffffffcc(%ebp),%edx
  8023eb:	0f 84 94 00 00 00    	je     802485 <__umoddi3+0x175>
  8023f1:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  8023f4:	29 c6                	sub    %eax,%esi
  8023f6:	19 d1                	sbb    %edx,%ecx
  8023f8:	89 4d cc             	mov    %ecx,0xffffffcc(%ebp)
  8023fb:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  8023ff:	89 f2                	mov    %esi,%edx
  802401:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  802404:	d3 ea                	shr    %cl,%edx
  802406:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  80240a:	d3 e0                	shl    %cl,%eax
  80240c:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  802410:	09 c2                	or     %eax,%edx
  802412:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  802415:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802418:	d3 e8                	shr    %cl,%eax
  80241a:	89 45 d4             	mov    %eax,0xffffffd4(%ebp)
  80241d:	e9 4e ff ff ff       	jmp    802370 <__umoddi3+0x60>
  802422:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  802425:	85 c0                	test   %eax,%eax
  802427:	74 17                	je     802440 <__umoddi3+0x130>
  802429:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  80242c:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
  80242f:	f7 f1                	div    %ecx
  802431:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802434:	f7 f1                	div    %ecx
  802436:	e9 17 ff ff ff       	jmp    802352 <__umoddi3+0x42>
  80243b:	90                   	nop    
  80243c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802440:	b8 01 00 00 00       	mov    $0x1,%eax
  802445:	31 d2                	xor    %edx,%edx
  802447:	f7 75 ec             	divl   0xffffffec(%ebp)
  80244a:	89 c1                	mov    %eax,%ecx
  80244c:	eb db                	jmp    802429 <__umoddi3+0x119>
  80244e:	66 90                	xchg   %ax,%ax
  802450:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802453:	39 45 e0             	cmp    %eax,0xffffffe0(%ebp)
  802456:	77 19                	ja     802471 <__umoddi3+0x161>
  802458:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  80245b:	39 55 f0             	cmp    %edx,0xfffffff0(%ebp)
  80245e:	73 11                	jae    802471 <__umoddi3+0x161>
  802460:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  802463:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802466:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802469:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  80246c:	e9 ff fe ff ff       	jmp    802370 <__umoddi3+0x60>
  802471:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802474:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802477:	2b 45 ec             	sub    0xffffffec(%ebp),%eax
  80247a:	1b 4d e8             	sbb    0xffffffe8(%ebp),%ecx
  80247d:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  802480:	89 4d e0             	mov    %ecx,0xffffffe0(%ebp)
  802483:	eb db                	jmp    802460 <__umoddi3+0x150>
  802485:	39 f0                	cmp    %esi,%eax
  802487:	0f 86 64 ff ff ff    	jbe    8023f1 <__umoddi3+0xe1>
  80248d:	29 f8                	sub    %edi,%eax
  80248f:	1b 55 f4             	sbb    0xfffffff4(%ebp),%edx
  802492:	e9 5a ff ff ff       	jmp    8023f1 <__umoddi3+0xe1>
