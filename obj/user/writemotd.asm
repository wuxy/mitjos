
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
  800048:	c7 04 24 60 1f 80 00 	movl   $0x801f60,(%esp)
  80004f:	e8 db 19 00 00       	call   801a2f <open>
  800054:	89 85 f0 fd ff ff    	mov    %eax,-0x210(%ebp)
  80005a:	85 c0                	test   %eax,%eax
  80005c:	79 20                	jns    80007e <umain+0x4a>
		panic("open /newmotd: %e", rfd);
  80005e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800062:	c7 44 24 08 69 1f 80 	movl   $0x801f69,0x8(%esp)
  800069:	00 
  80006a:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  800071:	00 
  800072:	c7 04 24 7b 1f 80 00 	movl   $0x801f7b,(%esp)
  800079:	e8 3e 02 00 00       	call   8002bc <_panic>
	if ((wfd = open("/motd", O_RDWR)) < 0)
  80007e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  800085:	00 
  800086:	c7 04 24 8c 1f 80 00 	movl   $0x801f8c,(%esp)
  80008d:	e8 9d 19 00 00       	call   801a2f <open>
  800092:	89 c7                	mov    %eax,%edi
  800094:	85 c0                	test   %eax,%eax
  800096:	79 20                	jns    8000b8 <umain+0x84>
		panic("open /motd: %e", wfd);
  800098:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80009c:	c7 44 24 08 92 1f 80 	movl   $0x801f92,0x8(%esp)
  8000a3:	00 
  8000a4:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  8000ab:	00 
  8000ac:	c7 04 24 7b 1f 80 00 	movl   $0x801f7b,(%esp)
  8000b3:	e8 04 02 00 00       	call   8002bc <_panic>
	cprintf("file descriptors %d %d\n", rfd, wfd);
  8000b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000bc:	8b 85 f0 fd ff ff    	mov    -0x210(%ebp),%eax
  8000c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000c6:	c7 04 24 a1 1f 80 00 	movl   $0x801fa1,(%esp)
  8000cd:	e8 b7 02 00 00       	call   800389 <cprintf>
	if (rfd == wfd)
  8000d2:	39 bd f0 fd ff ff    	cmp    %edi,-0x210(%ebp)
  8000d8:	75 1c                	jne    8000f6 <umain+0xc2>
		panic("open /newmotd and /motd give same file descriptor");
  8000da:	c7 44 24 08 0c 20 80 	movl   $0x80200c,0x8(%esp)
  8000e1:	00 
  8000e2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  8000e9:	00 
  8000ea:	c7 04 24 7b 1f 80 00 	movl   $0x801f7b,(%esp)
  8000f1:	e8 c6 01 00 00       	call   8002bc <_panic>

	cprintf("OLD MOTD\n===\n");
  8000f6:	c7 04 24 b9 1f 80 00 	movl   $0x801fb9,(%esp)
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
  800125:	e8 de 13 00 00       	call   801508 <read>
  80012a:	85 c0                	test   %eax,%eax
  80012c:	7f dc                	jg     80010a <umain+0xd6>
		sys_cputs(buf, n);
	cprintf("===\n");
  80012e:	c7 04 24 c2 1f 80 00 	movl   $0x801fc2,(%esp)
  800135:	e8 4f 02 00 00       	call   800389 <cprintf>
	seek(wfd, 0);
  80013a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800141:	00 
  800142:	89 3c 24             	mov    %edi,(%esp)
  800145:	e8 9c 11 00 00       	call   8012e6 <seek>

	if ((r = ftruncate(wfd, 0)) < 0)
  80014a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800151:	00 
  800152:	89 3c 24             	mov    %edi,(%esp)
  800155:	e8 9f 12 00 00       	call   8013f9 <ftruncate>
  80015a:	85 c0                	test   %eax,%eax
  80015c:	79 20                	jns    80017e <umain+0x14a>
		panic("truncate /motd: %e", r);
  80015e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800162:	c7 44 24 08 c7 1f 80 	movl   $0x801fc7,0x8(%esp)
  800169:	00 
  80016a:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  800171:	00 
  800172:	c7 04 24 7b 1f 80 00 	movl   $0x801f7b,(%esp)
  800179:	e8 3e 01 00 00       	call   8002bc <_panic>

	cprintf("NEW MOTD\n===\n");
  80017e:	c7 04 24 da 1f 80 00 	movl   $0x801fda,(%esp)
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
  8001a9:	e8 cf 12 00 00       	call   80147d <write>
  8001ae:	39 c3                	cmp    %eax,%ebx
  8001b0:	74 20                	je     8001d2 <umain+0x19e>
			panic("write /motd: %e", r);
  8001b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b6:	c7 44 24 08 e8 1f 80 	movl   $0x801fe8,0x8(%esp)
  8001bd:	00 
  8001be:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  8001c5:	00 
  8001c6:	c7 04 24 7b 1f 80 00 	movl   $0x801f7b,(%esp)
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
  8001e7:	e8 1c 13 00 00       	call   801508 <read>
  8001ec:	89 c3                	mov    %eax,%ebx
  8001ee:	85 c0                	test   %eax,%eax
  8001f0:	7f a0                	jg     800192 <umain+0x15e>
		sys_cputs(buf, n);
		if ((r = write(wfd, buf, n)) != n)
			panic("write /motd: %e", r);
	}
	cprintf("===\n");
  8001f2:	c7 04 24 c2 1f 80 00 	movl   $0x801fc2,(%esp)
  8001f9:	e8 8b 01 00 00       	call   800389 <cprintf>

	if (n < 0)
  8001fe:	85 db                	test   %ebx,%ebx
  800200:	79 20                	jns    800222 <umain+0x1ee>
		panic("read /newmotd: %e", n);
  800202:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800206:	c7 44 24 08 f8 1f 80 	movl   $0x801ff8,0x8(%esp)
  80020d:	00 
  80020e:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800215:	00 
  800216:	c7 04 24 7b 1f 80 00 	movl   $0x801f7b,(%esp)
  80021d:	e8 9a 00 00 00       	call   8002bc <_panic>

	close(rfd);
  800222:	8b 85 f0 fd ff ff    	mov    -0x210(%ebp),%eax
  800228:	89 04 24             	mov    %eax,(%esp)
  80022b:	e8 45 14 00 00       	call   801675 <close>
	close(wfd);
  800230:	89 3c 24             	mov    %edi,(%esp)
  800233:	e8 3d 14 00 00       	call   801675 <close>
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
  800256:	c7 05 20 50 80 00 00 	movl   $0x0,0x805020
  80025d:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  800260:	e8 24 0f 00 00       	call   801189 <sys_getenvid>
  800265:	25 ff 03 00 00       	and    $0x3ff,%eax
  80026a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80026d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800272:	a3 20 50 80 00       	mov    %eax,0x805020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800277:	85 f6                	test   %esi,%esi
  800279:	7e 07                	jle    800282 <libmain+0x3e>
		binaryname = argv[0];
  80027b:	8b 03                	mov    (%ebx),%eax
  80027d:	a3 00 50 80 00       	mov    %eax,0x805000

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
  8002a6:	e8 65 15 00 00       	call   801810 <close_all>
	sys_env_destroy(0);
  8002ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002b2:	e8 06 0f 00 00       	call   8011bd <sys_env_destroy>
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
  8002c8:	a1 24 50 80 00       	mov    0x805024,%eax
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	74 10                	je     8002e1 <_panic+0x25>
		cprintf("%s: ", argv0);
  8002d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d5:	c7 04 24 55 20 80 00 	movl   $0x802055,(%esp)
  8002dc:	e8 a8 00 00 00       	call   800389 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8002e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ef:	a1 00 50 80 00       	mov    0x805000,%eax
  8002f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f8:	c7 04 24 5a 20 80 00 	movl   $0x80205a,(%esp)
  8002ff:	e8 85 00 00 00       	call   800389 <cprintf>
	vcprintf(fmt, ap);
  800304:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800307:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030b:	8b 45 10             	mov    0x10(%ebp),%eax
  80030e:	89 04 24             	mov    %eax,(%esp)
  800311:	e8 12 00 00 00       	call   800328 <vcprintf>
	cprintf("\n");
  800316:	c7 04 24 c5 1f 80 00 	movl   $0x801fc5,(%esp)
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
  80046b:	e8 50 18 00 00       	call   801cc0 <__udivdi3>
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
  8004bd:	e8 2e 19 00 00       	call   801df0 <__umoddi3>
  8004c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004c6:	0f be 80 76 20 80 00 	movsbl 0x802076(%eax),%eax
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
  80059e:	ff 24 85 c0 21 80 00 	jmp    *0x8021c0(,%eax,4)
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
  80064d:	8b 14 85 20 23 80 00 	mov    0x802320(,%eax,4),%edx
  800654:	85 d2                	test   %edx,%edx
  800656:	75 23                	jne    80067b <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800658:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80065c:	c7 44 24 08 87 20 80 	movl   $0x802087,0x8(%esp)
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
  80067f:	c7 44 24 08 90 20 80 	movl   $0x802090,0x8(%esp)
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
  8006b8:	c7 45 dc 93 20 80 00 	movl   $0x802093,-0x24(%ebp)
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

00800e8b <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	83 ec 28             	sub    $0x28,%esp
  800e91:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e94:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e97:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e9a:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ea2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ea7:	89 f9                	mov    %edi,%ecx
  800ea9:	89 fb                	mov    %edi,%ebx
  800eab:	89 fe                	mov    %edi,%esi
  800ead:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800eaf:	85 c0                	test   %eax,%eax
  800eb1:	7e 28                	jle    800edb <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb7:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ebe:	00 
  800ebf:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800ec6:	00 
  800ec7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ece:	00 
  800ecf:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800ed6:	e8 e1 f3 ff ff       	call   8002bc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800edb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ede:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ee1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ee4:	89 ec                	mov    %ebp,%esp
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    

00800ee8 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	83 ec 0c             	sub    $0xc,%esp
  800eee:	89 1c 24             	mov    %ebx,(%esp)
  800ef1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ef5:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ef9:	8b 55 08             	mov    0x8(%ebp),%edx
  800efc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f02:	8b 7d 14             	mov    0x14(%ebp),%edi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f05:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f0a:	be 00 00 00 00       	mov    $0x0,%esi
  800f0f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f11:	8b 1c 24             	mov    (%esp),%ebx
  800f14:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f18:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f1c:	89 ec                	mov    %ebp,%esp
  800f1e:	5d                   	pop    %ebp
  800f1f:	c3                   	ret    

00800f20 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	83 ec 28             	sub    $0x28,%esp
  800f26:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f29:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f2c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f35:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f3a:	bf 00 00 00 00       	mov    $0x0,%edi
  800f3f:	89 fb                	mov    %edi,%ebx
  800f41:	89 fe                	mov    %edi,%esi
  800f43:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f45:	85 c0                	test   %eax,%eax
  800f47:	7e 28                	jle    800f71 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f49:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f4d:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f54:	00 
  800f55:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800f5c:	00 
  800f5d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f64:	00 
  800f65:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800f6c:	e8 4b f3 ff ff       	call   8002bc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f71:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f74:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f77:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f7a:	89 ec                	mov    %ebp,%esp
  800f7c:	5d                   	pop    %ebp
  800f7d:	c3                   	ret    

00800f7e <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	83 ec 28             	sub    $0x28,%esp
  800f84:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f87:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f8a:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f93:	b8 09 00 00 00       	mov    $0x9,%eax
  800f98:	bf 00 00 00 00       	mov    $0x0,%edi
  800f9d:	89 fb                	mov    %edi,%ebx
  800f9f:	89 fe                	mov    %edi,%esi
  800fa1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800fa3:	85 c0                	test   %eax,%eax
  800fa5:	7e 28                	jle    800fcf <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fab:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fb2:	00 
  800fb3:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800fba:	00 
  800fbb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fc2:	00 
  800fc3:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800fca:	e8 ed f2 ff ff       	call   8002bc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fcf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fd2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fd5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fd8:	89 ec                	mov    %ebp,%esp
  800fda:	5d                   	pop    %ebp
  800fdb:	c3                   	ret    

00800fdc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 28             	sub    $0x28,%esp
  800fe2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fe5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fe8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800feb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff1:	b8 08 00 00 00       	mov    $0x8,%eax
  800ff6:	bf 00 00 00 00       	mov    $0x0,%edi
  800ffb:	89 fb                	mov    %edi,%ebx
  800ffd:	89 fe                	mov    %edi,%esi
  800fff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801001:	85 c0                	test   %eax,%eax
  801003:	7e 28                	jle    80102d <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801005:	89 44 24 10          	mov    %eax,0x10(%esp)
  801009:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801010:	00 
  801011:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  801018:	00 
  801019:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801020:	00 
  801021:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  801028:	e8 8f f2 ff ff       	call   8002bc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80102d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801030:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801033:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801036:	89 ec                	mov    %ebp,%esp
  801038:	5d                   	pop    %ebp
  801039:	c3                   	ret    

0080103a <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	83 ec 28             	sub    $0x28,%esp
  801040:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801043:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801046:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801049:	8b 55 08             	mov    0x8(%ebp),%edx
  80104c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80104f:	b8 06 00 00 00       	mov    $0x6,%eax
  801054:	bf 00 00 00 00       	mov    $0x0,%edi
  801059:	89 fb                	mov    %edi,%ebx
  80105b:	89 fe                	mov    %edi,%esi
  80105d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  80105f:	85 c0                	test   %eax,%eax
  801061:	7e 28                	jle    80108b <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801063:	89 44 24 10          	mov    %eax,0x10(%esp)
  801067:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80106e:	00 
  80106f:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  801076:	00 
  801077:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80107e:	00 
  80107f:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  801086:	e8 31 f2 ff ff       	call   8002bc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80108b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80108e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801091:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801094:	89 ec                	mov    %ebp,%esp
  801096:	5d                   	pop    %ebp
  801097:	c3                   	ret    

00801098 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	83 ec 28             	sub    $0x28,%esp
  80109e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010a1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010a4:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8010a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8010aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010b3:	8b 75 18             	mov    0x18(%ebp),%esi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8010bb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	7e 28                	jle    8010e9 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010c5:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8010cc:	00 
  8010cd:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  8010d4:	00 
  8010d5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010dc:	00 
  8010dd:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  8010e4:	e8 d3 f1 ff ff       	call   8002bc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010e9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010ec:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010ef:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010f2:	89 ec                	mov    %ebp,%esp
  8010f4:	5d                   	pop    %ebp
  8010f5:	c3                   	ret    

008010f6 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010f6:	55                   	push   %ebp
  8010f7:	89 e5                	mov    %esp,%ebp
  8010f9:	83 ec 28             	sub    $0x28,%esp
  8010fc:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010ff:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801102:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801105:	8b 55 08             	mov    0x8(%ebp),%edx
  801108:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80110b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80110e:	b8 04 00 00 00       	mov    $0x4,%eax
  801113:	bf 00 00 00 00       	mov    $0x0,%edi
  801118:	89 fe                	mov    %edi,%esi
  80111a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  80111c:	85 c0                	test   %eax,%eax
  80111e:	7e 28                	jle    801148 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  801120:	89 44 24 10          	mov    %eax,0x10(%esp)
  801124:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80112b:	00 
  80112c:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  801133:	00 
  801134:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80113b:	00 
  80113c:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  801143:	e8 74 f1 ff ff       	call   8002bc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801148:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80114b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80114e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801151:	89 ec                	mov    %ebp,%esp
  801153:	5d                   	pop    %ebp
  801154:	c3                   	ret    

00801155 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	83 ec 0c             	sub    $0xc,%esp
  80115b:	89 1c 24             	mov    %ebx,(%esp)
  80115e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801162:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801166:	b8 0b 00 00 00       	mov    $0xb,%eax
  80116b:	bf 00 00 00 00       	mov    $0x0,%edi
  801170:	89 fa                	mov    %edi,%edx
  801172:	89 f9                	mov    %edi,%ecx
  801174:	89 fb                	mov    %edi,%ebx
  801176:	89 fe                	mov    %edi,%esi
  801178:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80117a:	8b 1c 24             	mov    (%esp),%ebx
  80117d:	8b 74 24 04          	mov    0x4(%esp),%esi
  801181:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801185:	89 ec                	mov    %ebp,%esp
  801187:	5d                   	pop    %ebp
  801188:	c3                   	ret    

00801189 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
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
  80119a:	b8 02 00 00 00       	mov    $0x2,%eax
  80119f:	bf 00 00 00 00       	mov    $0x0,%edi
  8011a4:	89 fa                	mov    %edi,%edx
  8011a6:	89 f9                	mov    %edi,%ecx
  8011a8:	89 fb                	mov    %edi,%ebx
  8011aa:	89 fe                	mov    %edi,%esi
  8011ac:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8011ae:	8b 1c 24             	mov    (%esp),%ebx
  8011b1:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011b5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011b9:	89 ec                	mov    %ebp,%esp
  8011bb:	5d                   	pop    %ebp
  8011bc:	c3                   	ret    

008011bd <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
  8011c0:	83 ec 28             	sub    $0x28,%esp
  8011c3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011c6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011c9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8011cc:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011cf:	b8 03 00 00 00       	mov    $0x3,%eax
  8011d4:	bf 00 00 00 00       	mov    $0x0,%edi
  8011d9:	89 f9                	mov    %edi,%ecx
  8011db:	89 fb                	mov    %edi,%ebx
  8011dd:	89 fe                	mov    %edi,%esi
  8011df:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	7e 28                	jle    80120d <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011e9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8011f0:	00 
  8011f1:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  8011f8:	00 
  8011f9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801200:	00 
  801201:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  801208:	e8 af f0 ff ff       	call   8002bc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80120d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801210:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801213:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801216:	89 ec                	mov    %ebp,%esp
  801218:	5d                   	pop    %ebp
  801219:	c3                   	ret    
  80121a:	00 00                	add    %al,(%eax)
  80121c:	00 00                	add    %al,(%eax)
	...

00801220 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	8b 45 08             	mov    0x8(%ebp),%eax
  801226:	05 00 00 00 30       	add    $0x30000000,%eax
  80122b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    

00801230 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801236:	8b 45 08             	mov    0x8(%ebp),%eax
  801239:	89 04 24             	mov    %eax,(%esp)
  80123c:	e8 df ff ff ff       	call   801220 <fd2num>
  801241:	c1 e0 0c             	shl    $0xc,%eax
  801244:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801249:	c9                   	leave  
  80124a:	c3                   	ret    

0080124b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	53                   	push   %ebx
  80124f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801252:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801257:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801259:	89 d0                	mov    %edx,%eax
  80125b:	c1 e8 16             	shr    $0x16,%eax
  80125e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801265:	a8 01                	test   $0x1,%al
  801267:	74 10                	je     801279 <fd_alloc+0x2e>
  801269:	89 d0                	mov    %edx,%eax
  80126b:	c1 e8 0c             	shr    $0xc,%eax
  80126e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801275:	a8 01                	test   $0x1,%al
  801277:	75 09                	jne    801282 <fd_alloc+0x37>
			*fd_store = fd;
  801279:	89 0b                	mov    %ecx,(%ebx)
  80127b:	b8 00 00 00 00       	mov    $0x0,%eax
  801280:	eb 19                	jmp    80129b <fd_alloc+0x50>
			return 0;
  801282:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801288:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  80128e:	75 c7                	jne    801257 <fd_alloc+0xc>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801290:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801296:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  80129b:	5b                   	pop    %ebx
  80129c:	5d                   	pop    %ebp
  80129d:	c3                   	ret    

0080129e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012a1:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  8012a5:	77 38                	ja     8012df <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012aa:	c1 e0 0c             	shl    $0xc,%eax
  8012ad:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  8012b3:	89 d0                	mov    %edx,%eax
  8012b5:	c1 e8 16             	shr    $0x16,%eax
  8012b8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012bf:	a8 01                	test   $0x1,%al
  8012c1:	74 1c                	je     8012df <fd_lookup+0x41>
  8012c3:	89 d0                	mov    %edx,%eax
  8012c5:	c1 e8 0c             	shr    $0xc,%eax
  8012c8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012cf:	a8 01                	test   $0x1,%al
  8012d1:	74 0c                	je     8012df <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012d6:	89 10                	mov    %edx,(%eax)
  8012d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012dd:	eb 05                	jmp    8012e4 <fd_lookup+0x46>
	return 0;
  8012df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012e4:	5d                   	pop    %ebp
  8012e5:	c3                   	ret    

008012e6 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ec:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f6:	89 04 24             	mov    %eax,(%esp)
  8012f9:	e8 a0 ff ff ff       	call   80129e <fd_lookup>
  8012fe:	85 c0                	test   %eax,%eax
  801300:	78 0e                	js     801310 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801302:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801305:	8b 55 0c             	mov    0xc(%ebp),%edx
  801308:	89 50 04             	mov    %edx,0x4(%eax)
  80130b:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801310:	c9                   	leave  
  801311:	c3                   	ret    

00801312 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801312:	55                   	push   %ebp
  801313:	89 e5                	mov    %esp,%ebp
  801315:	53                   	push   %ebx
  801316:	83 ec 14             	sub    $0x14,%esp
  801319:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80131c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80131f:	ba 04 50 80 00       	mov    $0x805004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801324:	b8 00 00 00 00       	mov    $0x0,%eax
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801329:	39 0d 04 50 80 00    	cmp    %ecx,0x805004
  80132f:	75 11                	jne    801342 <dev_lookup+0x30>
  801331:	eb 04                	jmp    801337 <dev_lookup+0x25>
  801333:	39 0a                	cmp    %ecx,(%edx)
  801335:	75 0b                	jne    801342 <dev_lookup+0x30>
			*dev = devtab[i];
  801337:	89 13                	mov    %edx,(%ebx)
  801339:	b8 00 00 00 00       	mov    $0x0,%eax
  80133e:	66 90                	xchg   %ax,%ax
  801340:	eb 35                	jmp    801377 <dev_lookup+0x65>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801342:	83 c0 01             	add    $0x1,%eax
  801345:	8b 14 85 2c 24 80 00 	mov    0x80242c(,%eax,4),%edx
  80134c:	85 d2                	test   %edx,%edx
  80134e:	75 e3                	jne    801333 <dev_lookup+0x21>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  801350:	a1 20 50 80 00       	mov    0x805020,%eax
  801355:	8b 40 4c             	mov    0x4c(%eax),%eax
  801358:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80135c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801360:	c7 04 24 ac 23 80 00 	movl   $0x8023ac,(%esp)
  801367:	e8 1d f0 ff ff       	call   800389 <cprintf>
	*dev = 0;
  80136c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801372:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801377:	83 c4 14             	add    $0x14,%esp
  80137a:	5b                   	pop    %ebx
  80137b:	5d                   	pop    %ebp
  80137c:	c3                   	ret    

0080137d <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801383:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801386:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138a:	8b 45 08             	mov    0x8(%ebp),%eax
  80138d:	89 04 24             	mov    %eax,(%esp)
  801390:	e8 09 ff ff ff       	call   80129e <fd_lookup>
  801395:	89 c2                	mov    %eax,%edx
  801397:	85 c0                	test   %eax,%eax
  801399:	78 5a                	js     8013f5 <fstat+0x78>
  80139b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80139e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8013a5:	8b 00                	mov    (%eax),%eax
  8013a7:	89 04 24             	mov    %eax,(%esp)
  8013aa:	e8 63 ff ff ff       	call   801312 <dev_lookup>
  8013af:	89 c2                	mov    %eax,%edx
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	78 40                	js     8013f5 <fstat+0x78>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8013b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  8013ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013bd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013c1:	74 32                	je     8013f5 <fstat+0x78>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013c6:	c6 00 00             	movb   $0x0,(%eax)
	stat->st_size = 0;
  8013c9:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  8013d0:	00 00 00 
	stat->st_isdir = 0;
  8013d3:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
  8013da:	00 00 00 
	stat->st_dev = dev;
  8013dd:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8013e0:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
	return (*dev->dev_stat)(fd, stat);
  8013e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8013ed:	89 04 24             	mov    %eax,(%esp)
  8013f0:	ff 52 14             	call   *0x14(%edx)
  8013f3:	89 c2                	mov    %eax,%edx
}
  8013f5:	89 d0                	mov    %edx,%eax
  8013f7:	c9                   	leave  
  8013f8:	c3                   	ret    

008013f9 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8013f9:	55                   	push   %ebp
  8013fa:	89 e5                	mov    %esp,%ebp
  8013fc:	53                   	push   %ebx
  8013fd:	83 ec 24             	sub    $0x24,%esp
  801400:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801403:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801406:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140a:	89 1c 24             	mov    %ebx,(%esp)
  80140d:	e8 8c fe ff ff       	call   80129e <fd_lookup>
  801412:	85 c0                	test   %eax,%eax
  801414:	78 61                	js     801477 <ftruncate+0x7e>
  801416:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801419:	8b 10                	mov    (%eax),%edx
  80141b:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80141e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801422:	89 14 24             	mov    %edx,(%esp)
  801425:	e8 e8 fe ff ff       	call   801312 <dev_lookup>
  80142a:	85 c0                	test   %eax,%eax
  80142c:	78 49                	js     801477 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80142e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801431:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801435:	75 23                	jne    80145a <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801437:	a1 20 50 80 00       	mov    0x805020,%eax
  80143c:	8b 40 4c             	mov    0x4c(%eax),%eax
  80143f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801443:	89 44 24 04          	mov    %eax,0x4(%esp)
  801447:	c7 04 24 cc 23 80 00 	movl   $0x8023cc,(%esp)
  80144e:	e8 36 ef ff ff       	call   800389 <cprintf>
  801453:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801458:	eb 1d                	jmp    801477 <ftruncate+0x7e>
			env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80145a:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80145d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801462:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801466:	74 0f                	je     801477 <ftruncate+0x7e>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801468:	8b 42 18             	mov    0x18(%edx),%eax
  80146b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80146e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801472:	89 0c 24             	mov    %ecx,(%esp)
  801475:	ff d0                	call   *%eax
}
  801477:	83 c4 24             	add    $0x24,%esp
  80147a:	5b                   	pop    %ebx
  80147b:	5d                   	pop    %ebp
  80147c:	c3                   	ret    

0080147d <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80147d:	55                   	push   %ebp
  80147e:	89 e5                	mov    %esp,%ebp
  801480:	53                   	push   %ebx
  801481:	83 ec 24             	sub    $0x24,%esp
  801484:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801487:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148e:	89 1c 24             	mov    %ebx,(%esp)
  801491:	e8 08 fe ff ff       	call   80129e <fd_lookup>
  801496:	85 c0                	test   %eax,%eax
  801498:	78 68                	js     801502 <write+0x85>
  80149a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149d:	8b 10                	mov    (%eax),%edx
  80149f:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8014a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a6:	89 14 24             	mov    %edx,(%esp)
  8014a9:	e8 64 fe ff ff       	call   801312 <dev_lookup>
  8014ae:	85 c0                	test   %eax,%eax
  8014b0:	78 50                	js     801502 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014b2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  8014b5:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  8014b9:	75 23                	jne    8014de <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  8014bb:	a1 20 50 80 00       	mov    0x805020,%eax
  8014c0:	8b 40 4c             	mov    0x4c(%eax),%eax
  8014c3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014cb:	c7 04 24 f0 23 80 00 	movl   $0x8023f0,(%esp)
  8014d2:	e8 b2 ee ff ff       	call   800389 <cprintf>
  8014d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014dc:	eb 24                	jmp    801502 <write+0x85>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014de:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8014e1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014e6:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  8014ea:	74 16                	je     801502 <write+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014ec:	8b 42 0c             	mov    0xc(%edx),%eax
  8014ef:	8b 55 10             	mov    0x10(%ebp),%edx
  8014f2:	89 54 24 08          	mov    %edx,0x8(%esp)
  8014f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014fd:	89 0c 24             	mov    %ecx,(%esp)
  801500:	ff d0                	call   *%eax
}
  801502:	83 c4 24             	add    $0x24,%esp
  801505:	5b                   	pop    %ebx
  801506:	5d                   	pop    %ebp
  801507:	c3                   	ret    

00801508 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
  80150b:	53                   	push   %ebx
  80150c:	83 ec 24             	sub    $0x24,%esp
  80150f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801512:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801515:	89 44 24 04          	mov    %eax,0x4(%esp)
  801519:	89 1c 24             	mov    %ebx,(%esp)
  80151c:	e8 7d fd ff ff       	call   80129e <fd_lookup>
  801521:	85 c0                	test   %eax,%eax
  801523:	78 6d                	js     801592 <read+0x8a>
  801525:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801528:	8b 10                	mov    (%eax),%edx
  80152a:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80152d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801531:	89 14 24             	mov    %edx,(%esp)
  801534:	e8 d9 fd ff ff       	call   801312 <dev_lookup>
  801539:	85 c0                	test   %eax,%eax
  80153b:	78 55                	js     801592 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80153d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801540:	8b 41 08             	mov    0x8(%ecx),%eax
  801543:	83 e0 03             	and    $0x3,%eax
  801546:	83 f8 01             	cmp    $0x1,%eax
  801549:	75 23                	jne    80156e <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  80154b:	a1 20 50 80 00       	mov    0x805020,%eax
  801550:	8b 40 4c             	mov    0x4c(%eax),%eax
  801553:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801557:	89 44 24 04          	mov    %eax,0x4(%esp)
  80155b:	c7 04 24 0d 24 80 00 	movl   $0x80240d,(%esp)
  801562:	e8 22 ee ff ff       	call   800389 <cprintf>
  801567:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80156c:	eb 24                	jmp    801592 <read+0x8a>
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80156e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801571:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801576:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  80157a:	74 16                	je     801592 <read+0x8a>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80157c:	8b 42 08             	mov    0x8(%edx),%eax
  80157f:	8b 55 10             	mov    0x10(%ebp),%edx
  801582:	89 54 24 08          	mov    %edx,0x8(%esp)
  801586:	8b 55 0c             	mov    0xc(%ebp),%edx
  801589:	89 54 24 04          	mov    %edx,0x4(%esp)
  80158d:	89 0c 24             	mov    %ecx,(%esp)
  801590:	ff d0                	call   *%eax
}
  801592:	83 c4 24             	add    $0x24,%esp
  801595:	5b                   	pop    %ebx
  801596:	5d                   	pop    %ebp
  801597:	c3                   	ret    

00801598 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	57                   	push   %edi
  80159c:	56                   	push   %esi
  80159d:	53                   	push   %ebx
  80159e:	83 ec 0c             	sub    $0xc,%esp
  8015a1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8015a4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ac:	85 f6                	test   %esi,%esi
  8015ae:	74 36                	je     8015e6 <readn+0x4e>
  8015b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015b5:	ba 00 00 00 00       	mov    $0x0,%edx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015ba:	89 f0                	mov    %esi,%eax
  8015bc:	29 d0                	sub    %edx,%eax
  8015be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015c2:	8d 04 17             	lea    (%edi,%edx,1),%eax
  8015c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cc:	89 04 24             	mov    %eax,(%esp)
  8015cf:	e8 34 ff ff ff       	call   801508 <read>
		if (m < 0)
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	78 0e                	js     8015e6 <readn+0x4e>
			return m;
		if (m == 0)
  8015d8:	85 c0                	test   %eax,%eax
  8015da:	74 08                	je     8015e4 <readn+0x4c>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015dc:	01 c3                	add    %eax,%ebx
  8015de:	89 da                	mov    %ebx,%edx
  8015e0:	39 f3                	cmp    %esi,%ebx
  8015e2:	72 d6                	jb     8015ba <readn+0x22>
  8015e4:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015e6:	83 c4 0c             	add    $0xc,%esp
  8015e9:	5b                   	pop    %ebx
  8015ea:	5e                   	pop    %esi
  8015eb:	5f                   	pop    %edi
  8015ec:	5d                   	pop    %ebp
  8015ed:	c3                   	ret    

008015ee <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	83 ec 28             	sub    $0x28,%esp
  8015f4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8015f7:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8015fa:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015fd:	89 34 24             	mov    %esi,(%esp)
  801600:	e8 1b fc ff ff       	call   801220 <fd2num>
  801605:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801608:	89 54 24 04          	mov    %edx,0x4(%esp)
  80160c:	89 04 24             	mov    %eax,(%esp)
  80160f:	e8 8a fc ff ff       	call   80129e <fd_lookup>
  801614:	89 c3                	mov    %eax,%ebx
  801616:	85 c0                	test   %eax,%eax
  801618:	78 05                	js     80161f <fd_close+0x31>
  80161a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80161d:	74 0d                	je     80162c <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80161f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801623:	75 44                	jne    801669 <fd_close+0x7b>
  801625:	bb 00 00 00 00       	mov    $0x0,%ebx
  80162a:	eb 3d                	jmp    801669 <fd_close+0x7b>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80162c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801633:	8b 06                	mov    (%esi),%eax
  801635:	89 04 24             	mov    %eax,(%esp)
  801638:	e8 d5 fc ff ff       	call   801312 <dev_lookup>
  80163d:	89 c3                	mov    %eax,%ebx
  80163f:	85 c0                	test   %eax,%eax
  801641:	78 16                	js     801659 <fd_close+0x6b>
		if (dev->dev_close)
  801643:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801646:	8b 40 10             	mov    0x10(%eax),%eax
  801649:	bb 00 00 00 00       	mov    $0x0,%ebx
  80164e:	85 c0                	test   %eax,%eax
  801650:	74 07                	je     801659 <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  801652:	89 34 24             	mov    %esi,(%esp)
  801655:	ff d0                	call   *%eax
  801657:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801659:	89 74 24 04          	mov    %esi,0x4(%esp)
  80165d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801664:	e8 d1 f9 ff ff       	call   80103a <sys_page_unmap>
	return r;
}
  801669:	89 d8                	mov    %ebx,%eax
  80166b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80166e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801671:	89 ec                	mov    %ebp,%esp
  801673:	5d                   	pop    %ebp
  801674:	c3                   	ret    

00801675 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80167b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80167e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801682:	8b 45 08             	mov    0x8(%ebp),%eax
  801685:	89 04 24             	mov    %eax,(%esp)
  801688:	e8 11 fc ff ff       	call   80129e <fd_lookup>
  80168d:	85 c0                	test   %eax,%eax
  80168f:	78 13                	js     8016a4 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801691:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801698:	00 
  801699:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80169c:	89 04 24             	mov    %eax,(%esp)
  80169f:	e8 4a ff ff ff       	call   8015ee <fd_close>
}
  8016a4:	c9                   	leave  
  8016a5:	c3                   	ret    

008016a6 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	83 ec 18             	sub    $0x18,%esp
  8016ac:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8016af:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016b2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016b9:	00 
  8016ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bd:	89 04 24             	mov    %eax,(%esp)
  8016c0:	e8 6a 03 00 00       	call   801a2f <open>
  8016c5:	89 c6                	mov    %eax,%esi
  8016c7:	85 c0                	test   %eax,%eax
  8016c9:	78 1b                	js     8016e6 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8016cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d2:	89 34 24             	mov    %esi,(%esp)
  8016d5:	e8 a3 fc ff ff       	call   80137d <fstat>
  8016da:	89 c3                	mov    %eax,%ebx
	close(fd);
  8016dc:	89 34 24             	mov    %esi,(%esp)
  8016df:	e8 91 ff ff ff       	call   801675 <close>
  8016e4:	89 de                	mov    %ebx,%esi
	return r;
}
  8016e6:	89 f0                	mov    %esi,%eax
  8016e8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8016eb:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8016ee:	89 ec                	mov    %ebp,%esp
  8016f0:	5d                   	pop    %ebp
  8016f1:	c3                   	ret    

008016f2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	83 ec 38             	sub    $0x38,%esp
  8016f8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8016fb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8016fe:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801701:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801704:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801707:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170b:	8b 45 08             	mov    0x8(%ebp),%eax
  80170e:	89 04 24             	mov    %eax,(%esp)
  801711:	e8 88 fb ff ff       	call   80129e <fd_lookup>
  801716:	89 c3                	mov    %eax,%ebx
  801718:	85 c0                	test   %eax,%eax
  80171a:	0f 88 e1 00 00 00    	js     801801 <dup+0x10f>
		return r;
	close(newfdnum);
  801720:	89 3c 24             	mov    %edi,(%esp)
  801723:	e8 4d ff ff ff       	call   801675 <close>

	newfd = INDEX2FD(newfdnum);
  801728:	89 f8                	mov    %edi,%eax
  80172a:	c1 e0 0c             	shl    $0xc,%eax
  80172d:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  801733:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801736:	89 04 24             	mov    %eax,(%esp)
  801739:	e8 f2 fa ff ff       	call   801230 <fd2data>
  80173e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801740:	89 34 24             	mov    %esi,(%esp)
  801743:	e8 e8 fa ff ff       	call   801230 <fd2data>
  801748:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  80174b:	89 d8                	mov    %ebx,%eax
  80174d:	c1 e8 16             	shr    $0x16,%eax
  801750:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801757:	a8 01                	test   $0x1,%al
  801759:	74 45                	je     8017a0 <dup+0xae>
  80175b:	89 da                	mov    %ebx,%edx
  80175d:	c1 ea 0c             	shr    $0xc,%edx
  801760:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801767:	a8 01                	test   $0x1,%al
  801769:	74 35                	je     8017a0 <dup+0xae>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  80176b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801772:	25 07 0e 00 00       	and    $0xe07,%eax
  801777:	89 44 24 10          	mov    %eax,0x10(%esp)
  80177b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80177e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801782:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801789:	00 
  80178a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80178e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801795:	e8 fe f8 ff ff       	call   801098 <sys_page_map>
  80179a:	89 c3                	mov    %eax,%ebx
  80179c:	85 c0                	test   %eax,%eax
  80179e:	78 3e                	js     8017de <dup+0xec>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  8017a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017a3:	89 d0                	mov    %edx,%eax
  8017a5:	c1 e8 0c             	shr    $0xc,%eax
  8017a8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017af:	25 07 0e 00 00       	and    $0xe07,%eax
  8017b4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017b8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8017bc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017c3:	00 
  8017c4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017cf:	e8 c4 f8 ff ff       	call   801098 <sys_page_map>
  8017d4:	89 c3                	mov    %eax,%ebx
  8017d6:	85 c0                	test   %eax,%eax
  8017d8:	78 04                	js     8017de <dup+0xec>
		goto err;
  8017da:	89 fb                	mov    %edi,%ebx
  8017dc:	eb 23                	jmp    801801 <dup+0x10f>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017de:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017e9:	e8 4c f8 ff ff       	call   80103a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017fc:	e8 39 f8 ff ff       	call   80103a <sys_page_unmap>
	return r;
}
  801801:	89 d8                	mov    %ebx,%eax
  801803:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801806:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801809:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80180c:	89 ec                	mov    %ebp,%esp
  80180e:	5d                   	pop    %ebp
  80180f:	c3                   	ret    

00801810 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	53                   	push   %ebx
  801814:	83 ec 04             	sub    $0x4,%esp
  801817:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  80181c:	89 1c 24             	mov    %ebx,(%esp)
  80181f:	e8 51 fe ff ff       	call   801675 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801824:	83 c3 01             	add    $0x1,%ebx
  801827:	83 fb 20             	cmp    $0x20,%ebx
  80182a:	75 f0                	jne    80181c <close_all+0xc>
		close(i);
}
  80182c:	83 c4 04             	add    $0x4,%esp
  80182f:	5b                   	pop    %ebx
  801830:	5d                   	pop    %ebp
  801831:	c3                   	ret    
	...

00801834 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	53                   	push   %ebx
  801838:	83 ec 14             	sub    $0x14,%esp
  80183b:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80183d:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801843:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80184a:	00 
  80184b:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801852:	00 
  801853:	89 44 24 04          	mov    %eax,0x4(%esp)
  801857:	89 14 24             	mov    %edx,(%esp)
  80185a:	e8 c1 02 00 00       	call   801b20 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80185f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801866:	00 
  801867:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80186b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801872:	e8 5d 03 00 00       	call   801bd4 <ipc_recv>
}
  801877:	83 c4 14             	add    $0x14,%esp
  80187a:	5b                   	pop    %ebx
  80187b:	5d                   	pop    %ebp
  80187c:	c3                   	ret    

0080187d <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  80187d:	55                   	push   %ebp
  80187e:	89 e5                	mov    %esp,%ebp
  801880:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801883:	ba 00 00 00 00       	mov    $0x0,%edx
  801888:	b8 08 00 00 00       	mov    $0x8,%eax
  80188d:	e8 a2 ff ff ff       	call   801834 <fsipc>
}
  801892:	c9                   	leave  
  801893:	c3                   	ret    

00801894 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80189a:	8b 45 08             	mov    0x8(%ebp),%eax
  80189d:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a0:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  8018a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a8:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b2:	b8 02 00 00 00       	mov    $0x2,%eax
  8018b7:	e8 78 ff ff ff       	call   801834 <fsipc>
}
  8018bc:	c9                   	leave  
  8018bd:	c3                   	ret    

008018be <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
  8018c1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ca:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  8018cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d4:	b8 06 00 00 00       	mov    $0x6,%eax
  8018d9:	e8 56 ff ff ff       	call   801834 <fsipc>
}
  8018de:	c9                   	leave  
  8018df:	c3                   	ret    

008018e0 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	53                   	push   %ebx
  8018e4:	83 ec 14             	sub    $0x14,%esp
  8018e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f0:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fa:	b8 05 00 00 00       	mov    $0x5,%eax
  8018ff:	e8 30 ff ff ff       	call   801834 <fsipc>
  801904:	85 c0                	test   %eax,%eax
  801906:	78 2b                	js     801933 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801908:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  80190f:	00 
  801910:	89 1c 24             	mov    %ebx,(%esp)
  801913:	e8 d9 f0 ff ff       	call   8009f1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801918:	a1 80 30 80 00       	mov    0x803080,%eax
  80191d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801923:	a1 84 30 80 00       	mov    0x803084,%eax
  801928:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80192e:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801933:	83 c4 14             	add    $0x14,%esp
  801936:	5b                   	pop    %ebx
  801937:	5d                   	pop    %ebp
  801938:	c3                   	ret    

00801939 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801939:	55                   	push   %ebp
  80193a:	89 e5                	mov    %esp,%ebp
  80193c:	83 ec 18             	sub    $0x18,%esp
  80193f:	8b 55 10             	mov    0x10(%ebp),%edx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	ssize_t writesize;
	size_t bufsize;
	fsipcbuf.write.req_fileid=fd->fd_file.id;
  801942:	8b 45 08             	mov    0x8(%ebp),%eax
  801945:	8b 40 0c             	mov    0xc(%eax),%eax
  801948:	a3 00 30 80 00       	mov    %eax,0x803000
	bufsize=sizeof(fsipcbuf.write.req_buf);
	if(n<bufsize)
  80194d:	89 d0                	mov    %edx,%eax
  80194f:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  801955:	76 05                	jbe    80195c <devfile_write+0x23>
  801957:	b8 f8 0f 00 00       	mov    $0xff8,%eax
		bufsize=n;	
	fsipcbuf.write.req_n=n;
  80195c:	89 15 04 30 80 00    	mov    %edx,0x803004
	memmove((void*)fsipcbuf.write.req_buf,buf,bufsize);
  801962:	89 44 24 08          	mov    %eax,0x8(%esp)
  801966:	8b 45 0c             	mov    0xc(%ebp),%eax
  801969:	89 44 24 04          	mov    %eax,0x4(%esp)
  80196d:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801974:	e8 7f f2 ff ff       	call   800bf8 <memmove>
	writesize=(ssize_t)fsipc(FSREQ_WRITE,NULL);
  801979:	ba 00 00 00 00       	mov    $0x0,%edx
  80197e:	b8 04 00 00 00       	mov    $0x4,%eax
  801983:	e8 ac fe ff ff       	call   801834 <fsipc>
	return writesize;
	//panic("devfile_write not implemented");
}
  801988:	c9                   	leave  
  801989:	c3                   	ret    

0080198a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	53                   	push   %ebx
  80198e:	83 ec 14             	sub    $0x14,%esp
	// system server.
	// LAB 5: Your code here
	ssize_t readsize;
	if(debug)
		cprintf("devfile_read:fileid=%x readsize=%x\n",fd->fd_file.id,n);
	fsipcbuf.read.req_fileid=fd->fd_file.id;
  801991:	8b 45 08             	mov    0x8(%ebp),%eax
  801994:	8b 40 0c             	mov    0xc(%eax),%eax
  801997:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n=n;
  80199c:	8b 45 10             	mov    0x10(%ebp),%eax
  80199f:	a3 04 30 80 00       	mov    %eax,0x803004
	readsize=(ssize_t)fsipc(FSREQ_READ,&fsipcbuf);
  8019a4:	ba 00 30 80 00       	mov    $0x803000,%edx
  8019a9:	b8 03 00 00 00       	mov    $0x3,%eax
  8019ae:	e8 81 fe ff ff       	call   801834 <fsipc>
  8019b3:	89 c3                	mov    %eax,%ebx
	cprintf("readsize=%d\n",readsize);
  8019b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b9:	c7 04 24 34 24 80 00 	movl   $0x802434,(%esp)
  8019c0:	e8 c4 e9 ff ff       	call   800389 <cprintf>
	if(debug)
		cprintf("devfile_read:buf1=%s\nbuf2=%s\n",(char*)&fsipcbuf,fsipcbuf.readRet.ret_buf);
	if(readsize>0)
  8019c5:	85 db                	test   %ebx,%ebx
  8019c7:	7e 17                	jle    8019e0 <devfile_read+0x56>
		memmove(buf,(void*)&fsipcbuf,(size_t)readsize);
  8019c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019cd:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  8019d4:	00 
  8019d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d8:	89 04 24             	mov    %eax,(%esp)
  8019db:	e8 18 f2 ff ff       	call   800bf8 <memmove>
	//cprintf("readsize=%d",readsize);
	return readsize;
	//panic("devfile_read not implemented");
}
  8019e0:	89 d8                	mov    %ebx,%eax
  8019e2:	83 c4 14             	add    $0x14,%esp
  8019e5:	5b                   	pop    %ebx
  8019e6:	5d                   	pop    %ebp
  8019e7:	c3                   	ret    

008019e8 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	53                   	push   %ebx
  8019ec:	83 ec 14             	sub    $0x14,%esp
  8019ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8019f2:	89 1c 24             	mov    %ebx,(%esp)
  8019f5:	e8 a6 ef ff ff       	call   8009a0 <strlen>
  8019fa:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  8019ff:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a04:	7f 21                	jg     801a27 <remove+0x3f>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801a06:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a0a:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801a11:	e8 db ef ff ff       	call   8009f1 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801a16:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1b:	b8 07 00 00 00       	mov    $0x7,%eax
  801a20:	e8 0f fe ff ff       	call   801834 <fsipc>
  801a25:	89 c2                	mov    %eax,%edx
}
  801a27:	89 d0                	mov    %edx,%eax
  801a29:	83 c4 14             	add    $0x14,%esp
  801a2c:	5b                   	pop    %ebx
  801a2d:	5d                   	pop    %ebp
  801a2e:	c3                   	ret    

00801a2f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	53                   	push   %ebx
  801a33:	83 ec 24             	sub    $0x24,%esp
	// file descriptor.

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;
	if((r=fd_alloc(&fd))<0){
  801a36:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801a39:	89 04 24             	mov    %eax,(%esp)
  801a3c:	e8 0a f8 ff ff       	call   80124b <fd_alloc>
  801a41:	89 c3                	mov    %eax,%ebx
  801a43:	85 c0                	test   %eax,%eax
  801a45:	79 18                	jns    801a5f <open+0x30>
		fd_close(fd,0);
  801a47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a4e:	00 
  801a4f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801a52:	89 04 24             	mov    %eax,(%esp)
  801a55:	e8 94 fb ff ff       	call   8015ee <fd_close>
  801a5a:	e9 b4 00 00 00       	jmp    801b13 <open+0xe4>
		return r;
	}
	cprintf("open:fd=%x\n",fd);
  801a5f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801a62:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a66:	c7 04 24 41 24 80 00 	movl   $0x802441,(%esp)
  801a6d:	e8 17 e9 ff ff       	call   800389 <cprintf>
	strcpy(fsipcbuf.open.req_path,path);
  801a72:	8b 45 08             	mov    0x8(%ebp),%eax
  801a75:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a79:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801a80:	e8 6c ef ff ff       	call   8009f1 <strcpy>
	fsipcbuf.open.req_omode=mode;
  801a85:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a88:	a3 00 34 80 00       	mov    %eax,0x803400
	if((r=fsipc(FSREQ_OPEN,(void*)fd))<0)
  801a8d:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801a90:	b8 01 00 00 00       	mov    $0x1,%eax
  801a95:	e8 9a fd ff ff       	call   801834 <fsipc>
  801a9a:	89 c3                	mov    %eax,%ebx
  801a9c:	85 c0                	test   %eax,%eax
  801a9e:	79 15                	jns    801ab5 <open+0x86>
	{
		fd_close(fd,1);
  801aa0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801aa7:	00 
  801aa8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801aab:	89 04 24             	mov    %eax,(%esp)
  801aae:	e8 3b fb ff ff       	call   8015ee <fd_close>
  801ab3:	eb 5e                	jmp    801b13 <open+0xe4>
		return r;	
	}
	if((r=sys_page_map(0,(void*)fd,0,(void*)fd,PTE_P | PTE_W | PTE_U))<0)
  801ab5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801ab8:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801abf:	00 
  801ac0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ac4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801acb:	00 
  801acc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ad7:	e8 bc f5 ff ff       	call   801098 <sys_page_map>
  801adc:	89 c3                	mov    %eax,%ebx
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	79 15                	jns    801af7 <open+0xc8>
	{
		fd_close(fd,1);
  801ae2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ae9:	00 
  801aea:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801aed:	89 04 24             	mov    %eax,(%esp)
  801af0:	e8 f9 fa ff ff       	call   8015ee <fd_close>
  801af5:	eb 1c                	jmp    801b13 <open+0xe4>
		return r;
	}
	//INDEX2DATA(fd->fd_file.id);
	cprintf("fileid=%x\n",fd->fd_file.id);
  801af7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801afa:	8b 40 0c             	mov    0xc(%eax),%eax
  801afd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b01:	c7 04 24 4d 24 80 00 	movl   $0x80244d,(%esp)
  801b08:	e8 7c e8 ff ff       	call   800389 <cprintf>
	return fd->fd_file.id;
  801b0d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801b10:	8b 58 0c             	mov    0xc(%eax),%ebx
	//panic("open not implemented");
}
  801b13:	89 d8                	mov    %ebx,%eax
  801b15:	83 c4 24             	add    $0x24,%esp
  801b18:	5b                   	pop    %ebx
  801b19:	5d                   	pop    %ebp
  801b1a:	c3                   	ret    
  801b1b:	00 00                	add    %al,(%eax)
  801b1d:	00 00                	add    %al,(%eax)
	...

00801b20 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	57                   	push   %edi
  801b24:	56                   	push   %esi
  801b25:	53                   	push   %ebx
  801b26:	83 ec 1c             	sub    $0x1c,%esp
  801b29:	8b 75 08             	mov    0x8(%ebp),%esi
  801b2c:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  801b2f:	e8 55 f6 ff ff       	call   801189 <sys_getenvid>
  801b34:	25 ff 03 00 00       	and    $0x3ff,%eax
  801b39:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b3c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b41:	a3 20 50 80 00       	mov    %eax,0x805020
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  801b46:	e8 3e f6 ff ff       	call   801189 <sys_getenvid>
  801b4b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801b50:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b53:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b58:	a3 20 50 80 00       	mov    %eax,0x805020
		if(env->env_id==to_env){
  801b5d:	8b 40 4c             	mov    0x4c(%eax),%eax
  801b60:	39 f0                	cmp    %esi,%eax
  801b62:	75 0e                	jne    801b72 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  801b64:	c7 04 24 58 24 80 00 	movl   $0x802458,(%esp)
  801b6b:	e8 19 e8 ff ff       	call   800389 <cprintf>
  801b70:	eb 5a                	jmp    801bcc <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  801b72:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b76:	8b 45 10             	mov    0x10(%ebp),%eax
  801b79:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b80:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b84:	89 34 24             	mov    %esi,(%esp)
  801b87:	e8 5c f3 ff ff       	call   800ee8 <sys_ipc_try_send>
  801b8c:	89 c3                	mov    %eax,%ebx
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	79 25                	jns    801bb7 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  801b92:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b95:	74 2b                	je     801bc2 <ipc_send+0xa2>
				panic("send error:%e",r);
  801b97:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b9b:	c7 44 24 08 74 24 80 	movl   $0x802474,0x8(%esp)
  801ba2:	00 
  801ba3:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801baa:	00 
  801bab:	c7 04 24 82 24 80 00 	movl   $0x802482,(%esp)
  801bb2:	e8 05 e7 ff ff       	call   8002bc <_panic>
		}
			sys_yield();
  801bb7:	e8 99 f5 ff ff       	call   801155 <sys_yield>
		
	}while(r!=0);
  801bbc:	85 db                	test   %ebx,%ebx
  801bbe:	75 86                	jne    801b46 <ipc_send+0x26>
  801bc0:	eb 0a                	jmp    801bcc <ipc_send+0xac>
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
		{	
			if(r!=-E_IPC_NOT_RECV)
				panic("send error:%e",r);
		}
			sys_yield();
  801bc2:	e8 8e f5 ff ff       	call   801155 <sys_yield>
  801bc7:	e9 7a ff ff ff       	jmp    801b46 <ipc_send+0x26>
		
	}while(r!=0);
	return;
	//panic("ipc_send not implemented");
}
  801bcc:	83 c4 1c             	add    $0x1c,%esp
  801bcf:	5b                   	pop    %ebx
  801bd0:	5e                   	pop    %esi
  801bd1:	5f                   	pop    %edi
  801bd2:	5d                   	pop    %ebp
  801bd3:	c3                   	ret    

00801bd4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	57                   	push   %edi
  801bd8:	56                   	push   %esi
  801bd9:	53                   	push   %ebx
  801bda:	83 ec 0c             	sub    $0xc,%esp
  801bdd:	8b 75 08             	mov    0x8(%ebp),%esi
  801be0:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	void *dstva=NULL;
	if(pg)
		dstva=pg;
	env = &envs[ENVX(sys_getenvid())];
  801be3:	e8 a1 f5 ff ff       	call   801189 <sys_getenvid>
  801be8:	25 ff 03 00 00       	and    $0x3ff,%eax
  801bed:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bf0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bf5:	a3 20 50 80 00       	mov    %eax,0x805020
	if(from_env_store&&(env->env_id==*from_env_store))
  801bfa:	85 f6                	test   %esi,%esi
  801bfc:	74 29                	je     801c27 <ipc_recv+0x53>
  801bfe:	8b 40 4c             	mov    0x4c(%eax),%eax
  801c01:	3b 06                	cmp    (%esi),%eax
  801c03:	75 22                	jne    801c27 <ipc_recv+0x53>
	{
		*from_env_store=0;
  801c05:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  801c0b:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("send:the reciver is sender\n");
  801c11:	c7 04 24 58 24 80 00 	movl   $0x802458,(%esp)
  801c18:	e8 6c e7 ff ff       	call   800389 <cprintf>
  801c1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c22:	e9 8a 00 00 00       	jmp    801cb1 <ipc_recv+0xdd>
		return 0;
	}
	env = &envs[ENVX(sys_getenvid())];
  801c27:	e8 5d f5 ff ff       	call   801189 <sys_getenvid>
  801c2c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801c31:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c34:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c39:	a3 20 50 80 00       	mov    %eax,0x805020
	if((r=sys_ipc_recv(dstva))<0)
  801c3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c41:	89 04 24             	mov    %eax,(%esp)
  801c44:	e8 42 f2 ff ff       	call   800e8b <sys_ipc_recv>
  801c49:	89 c3                	mov    %eax,%ebx
  801c4b:	85 c0                	test   %eax,%eax
  801c4d:	79 1a                	jns    801c69 <ipc_recv+0x95>
	{
		*from_env_store=0;
  801c4f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  801c55:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("reciver failed\n");
  801c5b:	c7 04 24 8c 24 80 00 	movl   $0x80248c,(%esp)
  801c62:	e8 22 e7 ff ff       	call   800389 <cprintf>
  801c67:	eb 48                	jmp    801cb1 <ipc_recv+0xdd>
		return r;
	}
	else{//接收成功
		env = &envs[ENVX(sys_getenvid())];
  801c69:	e8 1b f5 ff ff       	call   801189 <sys_getenvid>
  801c6e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801c73:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c76:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c7b:	a3 20 50 80 00       	mov    %eax,0x805020
		if(from_env_store)
  801c80:	85 f6                	test   %esi,%esi
  801c82:	74 05                	je     801c89 <ipc_recv+0xb5>
			*from_env_store=env->env_ipc_from;	
  801c84:	8b 40 74             	mov    0x74(%eax),%eax
  801c87:	89 06                	mov    %eax,(%esi)
		if(perm_store)
  801c89:	85 ff                	test   %edi,%edi
  801c8b:	74 0a                	je     801c97 <ipc_recv+0xc3>
			*perm_store=env->env_ipc_perm;
  801c8d:	a1 20 50 80 00       	mov    0x805020,%eax
  801c92:	8b 40 78             	mov    0x78(%eax),%eax
  801c95:	89 07                	mov    %eax,(%edi)
		env = &envs[ENVX(sys_getenvid())];
  801c97:	e8 ed f4 ff ff       	call   801189 <sys_getenvid>
  801c9c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801ca1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ca4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ca9:	a3 20 50 80 00       	mov    %eax,0x805020
		return env->env_ipc_value;
  801cae:	8b 58 70             	mov    0x70(%eax),%ebx
	}
	//panic("ipc_recv not implemented");
	return 0;
}
  801cb1:	89 d8                	mov    %ebx,%eax
  801cb3:	83 c4 0c             	add    $0xc,%esp
  801cb6:	5b                   	pop    %ebx
  801cb7:	5e                   	pop    %esi
  801cb8:	5f                   	pop    %edi
  801cb9:	5d                   	pop    %ebp
  801cba:	c3                   	ret    
  801cbb:	00 00                	add    %al,(%eax)
  801cbd:	00 00                	add    %al,(%eax)
	...

00801cc0 <__udivdi3>:
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	57                   	push   %edi
  801cc4:	56                   	push   %esi
  801cc5:	83 ec 18             	sub    $0x18,%esp
  801cc8:	8b 45 10             	mov    0x10(%ebp),%eax
  801ccb:	8b 55 14             	mov    0x14(%ebp),%edx
  801cce:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cd1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801cd4:	89 c1                	mov    %eax,%ecx
  801cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd9:	85 d2                	test   %edx,%edx
  801cdb:	89 d7                	mov    %edx,%edi
  801cdd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ce0:	75 1e                	jne    801d00 <__udivdi3+0x40>
  801ce2:	39 f1                	cmp    %esi,%ecx
  801ce4:	0f 86 8d 00 00 00    	jbe    801d77 <__udivdi3+0xb7>
  801cea:	89 f2                	mov    %esi,%edx
  801cec:	31 f6                	xor    %esi,%esi
  801cee:	f7 f1                	div    %ecx
  801cf0:	89 c1                	mov    %eax,%ecx
  801cf2:	89 c8                	mov    %ecx,%eax
  801cf4:	89 f2                	mov    %esi,%edx
  801cf6:	83 c4 18             	add    $0x18,%esp
  801cf9:	5e                   	pop    %esi
  801cfa:	5f                   	pop    %edi
  801cfb:	5d                   	pop    %ebp
  801cfc:	c3                   	ret    
  801cfd:	8d 76 00             	lea    0x0(%esi),%esi
  801d00:	39 f2                	cmp    %esi,%edx
  801d02:	0f 87 a8 00 00 00    	ja     801db0 <__udivdi3+0xf0>
  801d08:	0f bd c2             	bsr    %edx,%eax
  801d0b:	83 f0 1f             	xor    $0x1f,%eax
  801d0e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801d11:	0f 84 89 00 00 00    	je     801da0 <__udivdi3+0xe0>
  801d17:	b8 20 00 00 00       	mov    $0x20,%eax
  801d1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d1f:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801d22:	89 c1                	mov    %eax,%ecx
  801d24:	d3 ea                	shr    %cl,%edx
  801d26:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  801d2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801d2d:	89 f8                	mov    %edi,%eax
  801d2f:	8b 7d f4             	mov    -0xc(%ebp),%edi
  801d32:	d3 e0                	shl    %cl,%eax
  801d34:	09 c2                	or     %eax,%edx
  801d36:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801d39:	d3 e7                	shl    %cl,%edi
  801d3b:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d3f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801d42:	89 f2                	mov    %esi,%edx
  801d44:	d3 e8                	shr    %cl,%eax
  801d46:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  801d4a:	d3 e2                	shl    %cl,%edx
  801d4c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d50:	09 d0                	or     %edx,%eax
  801d52:	d3 ee                	shr    %cl,%esi
  801d54:	89 f2                	mov    %esi,%edx
  801d56:	f7 75 e4             	divl   -0x1c(%ebp)
  801d59:	89 d1                	mov    %edx,%ecx
  801d5b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  801d5e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d61:	f7 e7                	mul    %edi
  801d63:	39 d1                	cmp    %edx,%ecx
  801d65:	89 c6                	mov    %eax,%esi
  801d67:	72 70                	jb     801dd9 <__udivdi3+0x119>
  801d69:	39 ca                	cmp    %ecx,%edx
  801d6b:	74 5f                	je     801dcc <__udivdi3+0x10c>
  801d6d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801d70:	31 f6                	xor    %esi,%esi
  801d72:	e9 7b ff ff ff       	jmp    801cf2 <__udivdi3+0x32>
  801d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7a:	85 c0                	test   %eax,%eax
  801d7c:	75 0c                	jne    801d8a <__udivdi3+0xca>
  801d7e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d83:	31 d2                	xor    %edx,%edx
  801d85:	f7 75 f4             	divl   -0xc(%ebp)
  801d88:	89 c1                	mov    %eax,%ecx
  801d8a:	89 f0                	mov    %esi,%eax
  801d8c:	89 fa                	mov    %edi,%edx
  801d8e:	f7 f1                	div    %ecx
  801d90:	89 c6                	mov    %eax,%esi
  801d92:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801d95:	f7 f1                	div    %ecx
  801d97:	89 c1                	mov    %eax,%ecx
  801d99:	e9 54 ff ff ff       	jmp    801cf2 <__udivdi3+0x32>
  801d9e:	66 90                	xchg   %ax,%ax
  801da0:	39 d6                	cmp    %edx,%esi
  801da2:	77 1c                	ja     801dc0 <__udivdi3+0x100>
  801da4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801da7:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  801daa:	73 14                	jae    801dc0 <__udivdi3+0x100>
  801dac:	8d 74 26 00          	lea    0x0(%esi),%esi
  801db0:	31 c9                	xor    %ecx,%ecx
  801db2:	31 f6                	xor    %esi,%esi
  801db4:	e9 39 ff ff ff       	jmp    801cf2 <__udivdi3+0x32>
  801db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  801dc0:	b9 01 00 00 00       	mov    $0x1,%ecx
  801dc5:	31 f6                	xor    %esi,%esi
  801dc7:	e9 26 ff ff ff       	jmp    801cf2 <__udivdi3+0x32>
  801dcc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801dcf:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  801dd3:	d3 e0                	shl    %cl,%eax
  801dd5:	39 c6                	cmp    %eax,%esi
  801dd7:	76 94                	jbe    801d6d <__udivdi3+0xad>
  801dd9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801ddc:	31 f6                	xor    %esi,%esi
  801dde:	83 e9 01             	sub    $0x1,%ecx
  801de1:	e9 0c ff ff ff       	jmp    801cf2 <__udivdi3+0x32>
	...

00801df0 <__umoddi3>:
  801df0:	55                   	push   %ebp
  801df1:	89 e5                	mov    %esp,%ebp
  801df3:	57                   	push   %edi
  801df4:	56                   	push   %esi
  801df5:	83 ec 30             	sub    $0x30,%esp
  801df8:	8b 45 10             	mov    0x10(%ebp),%eax
  801dfb:	8b 55 14             	mov    0x14(%ebp),%edx
  801dfe:	8b 75 08             	mov    0x8(%ebp),%esi
  801e01:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e04:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801e07:	89 c1                	mov    %eax,%ecx
  801e09:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801e0c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801e0f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801e16:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801e1d:	89 fa                	mov    %edi,%edx
  801e1f:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  801e22:	85 c0                	test   %eax,%eax
  801e24:	89 75 f0             	mov    %esi,-0x10(%ebp)
  801e27:	89 7d e0             	mov    %edi,-0x20(%ebp)
  801e2a:	75 14                	jne    801e40 <__umoddi3+0x50>
  801e2c:	39 f9                	cmp    %edi,%ecx
  801e2e:	76 60                	jbe    801e90 <__umoddi3+0xa0>
  801e30:	89 f0                	mov    %esi,%eax
  801e32:	f7 f1                	div    %ecx
  801e34:	89 55 d0             	mov    %edx,-0x30(%ebp)
  801e37:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801e3e:	eb 10                	jmp    801e50 <__umoddi3+0x60>
  801e40:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801e43:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  801e46:	76 18                	jbe    801e60 <__umoddi3+0x70>
  801e48:	89 75 d0             	mov    %esi,-0x30(%ebp)
  801e4b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801e4e:	66 90                	xchg   %ax,%ax
  801e50:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801e53:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801e56:	83 c4 30             	add    $0x30,%esp
  801e59:	5e                   	pop    %esi
  801e5a:	5f                   	pop    %edi
  801e5b:	5d                   	pop    %ebp
  801e5c:	c3                   	ret    
  801e5d:	8d 76 00             	lea    0x0(%esi),%esi
  801e60:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
  801e64:	83 f0 1f             	xor    $0x1f,%eax
  801e67:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e6a:	75 46                	jne    801eb2 <__umoddi3+0xc2>
  801e6c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801e6f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  801e72:	0f 87 c9 00 00 00    	ja     801f41 <__umoddi3+0x151>
  801e78:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  801e7b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  801e7e:	0f 83 bd 00 00 00    	jae    801f41 <__umoddi3+0x151>
  801e84:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801e87:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  801e8a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  801e8d:	eb c1                	jmp    801e50 <__umoddi3+0x60>
  801e8f:	90                   	nop    
  801e90:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801e93:	85 c0                	test   %eax,%eax
  801e95:	75 0c                	jne    801ea3 <__umoddi3+0xb3>
  801e97:	b8 01 00 00 00       	mov    $0x1,%eax
  801e9c:	31 d2                	xor    %edx,%edx
  801e9e:	f7 75 ec             	divl   -0x14(%ebp)
  801ea1:	89 c1                	mov    %eax,%ecx
  801ea3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ea6:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801ea9:	f7 f1                	div    %ecx
  801eab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801eae:	f7 f1                	div    %ecx
  801eb0:	eb 82                	jmp    801e34 <__umoddi3+0x44>
  801eb2:	b8 20 00 00 00       	mov    $0x20,%eax
  801eb7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801eba:	2b 45 d8             	sub    -0x28(%ebp),%eax
  801ebd:	8b 75 ec             	mov    -0x14(%ebp),%esi
  801ec0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ec3:	89 c1                	mov    %eax,%ecx
  801ec5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801ec8:	d3 ea                	shr    %cl,%edx
  801eca:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801ecd:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  801ed1:	d3 e0                	shl    %cl,%eax
  801ed3:	09 c2                	or     %eax,%edx
  801ed5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ed8:	d3 e6                	shl    %cl,%esi
  801eda:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  801ede:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801ee1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801ee4:	d3 e8                	shr    %cl,%eax
  801ee6:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  801eea:	d3 e2                	shl    %cl,%edx
  801eec:	09 d0                	or     %edx,%eax
  801eee:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801ef1:	d3 e7                	shl    %cl,%edi
  801ef3:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  801ef7:	d3 ea                	shr    %cl,%edx
  801ef9:	f7 75 f4             	divl   -0xc(%ebp)
  801efc:	89 55 cc             	mov    %edx,-0x34(%ebp)
  801eff:	f7 e6                	mul    %esi
  801f01:	39 55 cc             	cmp    %edx,-0x34(%ebp)
  801f04:	72 53                	jb     801f59 <__umoddi3+0x169>
  801f06:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  801f09:	74 4a                	je     801f55 <__umoddi3+0x165>
  801f0b:	90                   	nop    
  801f0c:	8d 74 26 00          	lea    0x0(%esi),%esi
  801f10:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801f13:	29 c7                	sub    %eax,%edi
  801f15:	19 d1                	sbb    %edx,%ecx
  801f17:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801f1a:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  801f1e:	89 fa                	mov    %edi,%edx
  801f20:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801f23:	d3 ea                	shr    %cl,%edx
  801f25:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  801f29:	d3 e0                	shl    %cl,%eax
  801f2b:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  801f2f:	09 c2                	or     %eax,%edx
  801f31:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801f34:	89 55 d0             	mov    %edx,-0x30(%ebp)
  801f37:	d3 e8                	shr    %cl,%eax
  801f39:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801f3c:	e9 0f ff ff ff       	jmp    801e50 <__umoddi3+0x60>
  801f41:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801f44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f47:	2b 45 ec             	sub    -0x14(%ebp),%eax
  801f4a:	1b 55 e8             	sbb    -0x18(%ebp),%edx
  801f4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801f50:	e9 2f ff ff ff       	jmp    801e84 <__umoddi3+0x94>
  801f55:	39 f8                	cmp    %edi,%eax
  801f57:	76 b7                	jbe    801f10 <__umoddi3+0x120>
  801f59:	29 f0                	sub    %esi,%eax
  801f5b:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801f5e:	eb b0                	jmp    801f10 <__umoddi3+0x120>
