
obj/user/primes:     file format elf32-i386

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
  80002c:	e8 13 01 00 00       	call   800144 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003d:	8d 7d f0             	lea    -0x10(%ebp),%edi
  800040:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800047:	00 
  800048:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004f:	00 
  800050:	89 3c 24             	mov    %edi,(%esp)
  800053:	e8 cc 16 00 00       	call   801724 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("%d ", p);
  80005a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005e:	c7 04 24 60 24 80 00 	movl   $0x802460,(%esp)
  800065:	e8 1f 02 00 00       	call   800289 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  80006a:	e8 fa 14 00 00       	call   801569 <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 20                	jns    800095 <primeproc+0x61>
		panic("fork: %e", id);
  800075:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800079:	c7 44 24 08 9c 28 80 	movl   $0x80289c,0x8(%esp)
  800080:	00 
  800081:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800088:	00 
  800089:	c7 04 24 64 24 80 00 	movl   $0x802464,(%esp)
  800090:	e8 27 01 00 00       	call   8001bc <_panic>
	if (id == 0)
  800095:	85 c0                	test   %eax,%eax
  800097:	74 a7                	je     800040 <primeproc+0xc>
		goto top;
	
	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800099:	8d 7d f0             	lea    -0x10(%ebp),%edi
  80009c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000a3:	00 
  8000a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000ab:	00 
  8000ac:	89 3c 24             	mov    %edi,(%esp)
  8000af:	e8 70 16 00 00       	call   801724 <ipc_recv>
  8000b4:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000b6:	89 c2                	mov    %eax,%edx
  8000b8:	c1 fa 1f             	sar    $0x1f,%edx
  8000bb:	f7 fb                	idiv   %ebx
  8000bd:	85 d2                	test   %edx,%edx
  8000bf:	74 db                	je     80009c <primeproc+0x68>
			ipc_send(id, i, 0, 0);
  8000c1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000c8:	00 
  8000c9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000d0:	00 
  8000d1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000d5:	89 34 24             	mov    %esi,(%esp)
  8000d8:	e8 93 15 00 00       	call   801670 <ipc_send>
  8000dd:	eb bd                	jmp    80009c <primeproc+0x68>

008000df <umain>:
	}
}

void
umain(void)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	56                   	push   %esi
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000e7:	e8 7d 14 00 00       	call   801569 <fork>
  8000ec:	89 c6                	mov    %eax,%esi
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <umain+0x33>
		panic("fork: %e", id);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 9c 28 80 	movl   $0x80289c,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 64 24 80 00 	movl   $0x802464,(%esp)
  80010d:	e8 aa 00 00 00       	call   8001bc <_panic>
	if (id == 0)
  800112:	85 c0                	test   %eax,%eax
  800114:	75 05                	jne    80011b <umain+0x3c>
		primeproc();
  800116:	e8 19 ff ff ff       	call   800034 <primeproc>
  80011b:	bb 02 00 00 00       	mov    $0x2,%ebx

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  800120:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800127:	00 
  800128:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80012f:	00 
  800130:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800134:	89 34 24             	mov    %esi,(%esp)
  800137:	e8 34 15 00 00       	call   801670 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  80013c:	83 c3 01             	add    $0x1,%ebx
  80013f:	eb df                	jmp    800120 <umain+0x41>
  800141:	00 00                	add    %al,(%eax)
	...

00800144 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 18             	sub    $0x18,%esp
  80014a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80014d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800150:	8b 75 08             	mov    0x8(%ebp),%esi
  800153:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  800156:	c7 05 20 50 80 00 00 	movl   $0x0,0x805020
  80015d:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  800160:	e8 24 0f 00 00       	call   801089 <sys_getenvid>
  800165:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800172:	a3 20 50 80 00       	mov    %eax,0x805020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800177:	85 f6                	test   %esi,%esi
  800179:	7e 07                	jle    800182 <libmain+0x3e>
		binaryname = argv[0];
  80017b:	8b 03                	mov    (%ebx),%eax
  80017d:	a3 00 50 80 00       	mov    %eax,0x805000

	// call user main routine
	umain(argc, argv);
  800182:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800186:	89 34 24             	mov    %esi,(%esp)
  800189:	e8 51 ff ff ff       	call   8000df <umain>

	// exit gracefully
	exit();
  80018e:	e8 0d 00 00 00       	call   8001a0 <exit>
}
  800193:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800196:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800199:	89 ec                	mov    %ebp,%esp
  80019b:	5d                   	pop    %ebp
  80019c:	c3                   	ret    
  80019d:	00 00                	add    %al,(%eax)
	...

008001a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001a6:	e8 55 1c 00 00       	call   801e00 <close_all>
	sys_env_destroy(0);
  8001ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001b2:	e8 06 0f 00 00       	call   8010bd <sys_env_destroy>
}
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    
  8001b9:	00 00                	add    %al,(%eax)
	...

008001bc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8001c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8001c5:	89 45 fc             	mov    %eax,-0x4(%ebp)

	// Print the panic message
	if (argv0)
  8001c8:	a1 24 50 80 00       	mov    0x805024,%eax
  8001cd:	85 c0                	test   %eax,%eax
  8001cf:	74 10                	je     8001e1 <_panic+0x25>
		cprintf("%s: ", argv0);
  8001d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d5:	c7 04 24 89 24 80 00 	movl   $0x802489,(%esp)
  8001dc:	e8 a8 00 00 00       	call   800289 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8001e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ef:	a1 00 50 80 00       	mov    0x805000,%eax
  8001f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f8:	c7 04 24 8e 24 80 00 	movl   $0x80248e,(%esp)
  8001ff:	e8 85 00 00 00       	call   800289 <cprintf>
	vcprintf(fmt, ap);
  800204:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800207:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020b:	8b 45 10             	mov    0x10(%ebp),%eax
  80020e:	89 04 24             	mov    %eax,(%esp)
  800211:	e8 12 00 00 00       	call   800228 <vcprintf>
	cprintf("\n");
  800216:	c7 04 24 a7 29 80 00 	movl   $0x8029a7,(%esp)
  80021d:	e8 67 00 00 00       	call   800289 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800222:	cc                   	int3   
  800223:	eb fd                	jmp    800222 <_panic+0x66>
  800225:	00 00                	add    %al,(%eax)
	...

00800228 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800231:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800238:	00 00 00 
	b.cnt = 0;
  80023b:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  800242:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800245:	8b 45 0c             	mov    0xc(%ebp),%eax
  800248:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80024c:	8b 45 08             	mov    0x8(%ebp),%eax
  80024f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800253:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800259:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025d:	c7 04 24 a6 02 80 00 	movl   $0x8002a6,(%esp)
  800264:	e8 cc 01 00 00       	call   800435 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800269:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
  80026f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800273:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  800279:	89 04 24             	mov    %eax,(%esp)
  80027c:	e8 d7 0a 00 00       	call   800d58 <sys_cputs>
  800281:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  800287:	c9                   	leave  
  800288:	c3                   	ret    

00800289 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028f:	8d 45 0c             	lea    0xc(%ebp),%eax
  800292:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800295:	89 44 24 04          	mov    %eax,0x4(%esp)
  800299:	8b 45 08             	mov    0x8(%ebp),%eax
  80029c:	89 04 24             	mov    %eax,(%esp)
  80029f:	e8 84 ff ff ff       	call   800228 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a4:	c9                   	leave  
  8002a5:	c3                   	ret    

008002a6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	53                   	push   %ebx
  8002aa:	83 ec 14             	sub    $0x14,%esp
  8002ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002b0:	8b 03                	mov    (%ebx),%eax
  8002b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b5:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002b9:	83 c0 01             	add    $0x1,%eax
  8002bc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002c3:	75 19                	jne    8002de <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002c5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002cc:	00 
  8002cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8002d0:	89 04 24             	mov    %eax,(%esp)
  8002d3:	e8 80 0a 00 00       	call   800d58 <sys_cputs>
		b->idx = 0;
  8002d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002de:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002e2:	83 c4 14             	add    $0x14,%esp
  8002e5:	5b                   	pop    %ebx
  8002e6:	5d                   	pop    %ebp
  8002e7:	c3                   	ret    
	...

008002f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	83 ec 3c             	sub    $0x3c,%esp
  8002f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002fc:	89 d7                	mov    %edx,%edi
  8002fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800301:	8b 55 0c             	mov    0xc(%ebp),%edx
  800304:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800307:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80030a:	8b 55 10             	mov    0x10(%ebp),%edx
  80030d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800310:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800313:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  80031a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80031d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  800320:	72 14                	jb     800336 <printnum+0x46>
  800322:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800325:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800328:	76 0c                	jbe    800336 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80032a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80032d:	83 eb 01             	sub    $0x1,%ebx
  800330:	85 db                	test   %ebx,%ebx
  800332:	7f 57                	jg     80038b <printnum+0x9b>
  800334:	eb 64                	jmp    80039a <printnum+0xaa>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800336:	89 74 24 10          	mov    %esi,0x10(%esp)
  80033a:	8b 45 14             	mov    0x14(%ebp),%eax
  80033d:	83 e8 01             	sub    $0x1,%eax
  800340:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800344:	89 54 24 08          	mov    %edx,0x8(%esp)
  800348:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80034c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800350:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800353:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800356:	89 44 24 08          	mov    %eax,0x8(%esp)
  80035a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80035e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800361:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800364:	89 04 24             	mov    %eax,(%esp)
  800367:	89 54 24 04          	mov    %edx,0x4(%esp)
  80036b:	e8 50 1e 00 00       	call   8021c0 <__udivdi3>
  800370:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800374:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800378:	89 04 24             	mov    %eax,(%esp)
  80037b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80037f:	89 fa                	mov    %edi,%edx
  800381:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800384:	e8 67 ff ff ff       	call   8002f0 <printnum>
  800389:	eb 0f                	jmp    80039a <printnum+0xaa>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80038f:	89 34 24             	mov    %esi,(%esp)
  800392:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800395:	83 eb 01             	sub    $0x1,%ebx
  800398:	75 f1                	jne    80038b <printnum+0x9b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80039a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80039e:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8003a5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8003a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003b6:	89 04 24             	mov    %eax,(%esp)
  8003b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003bd:	e8 2e 1f 00 00       	call   8022f0 <__umoddi3>
  8003c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c6:	0f be 80 aa 24 80 00 	movsbl 0x8024aa(%eax),%eax
  8003cd:	89 04 24             	mov    %eax,(%esp)
  8003d0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003d3:	83 c4 3c             	add    $0x3c,%esp
  8003d6:	5b                   	pop    %ebx
  8003d7:	5e                   	pop    %esi
  8003d8:	5f                   	pop    %edi
  8003d9:	5d                   	pop    %ebp
  8003da:	c3                   	ret    

008003db <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003db:	55                   	push   %ebp
  8003dc:	89 e5                	mov    %esp,%ebp
  8003de:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8003e0:	83 fa 01             	cmp    $0x1,%edx
  8003e3:	7e 0e                	jle    8003f3 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8003e5:	8b 10                	mov    (%eax),%edx
  8003e7:	8d 42 08             	lea    0x8(%edx),%eax
  8003ea:	89 01                	mov    %eax,(%ecx)
  8003ec:	8b 02                	mov    (%edx),%eax
  8003ee:	8b 52 04             	mov    0x4(%edx),%edx
  8003f1:	eb 22                	jmp    800415 <getuint+0x3a>
	else if (lflag)
  8003f3:	85 d2                	test   %edx,%edx
  8003f5:	74 10                	je     800407 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8003f7:	8b 10                	mov    (%eax),%edx
  8003f9:	8d 42 04             	lea    0x4(%edx),%eax
  8003fc:	89 01                	mov    %eax,(%ecx)
  8003fe:	8b 02                	mov    (%edx),%eax
  800400:	ba 00 00 00 00       	mov    $0x0,%edx
  800405:	eb 0e                	jmp    800415 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800407:	8b 10                	mov    (%eax),%edx
  800409:	8d 42 04             	lea    0x4(%edx),%eax
  80040c:	89 01                	mov    %eax,(%ecx)
  80040e:	8b 02                	mov    (%edx),%eax
  800410:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800415:	5d                   	pop    %ebp
  800416:	c3                   	ret    

00800417 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  80041d:	83 42 08 01          	addl   $0x1,0x8(%edx)
	if (b->buf < b->ebuf)
  800421:	8b 02                	mov    (%edx),%eax
  800423:	3b 42 04             	cmp    0x4(%edx),%eax
  800426:	73 0b                	jae    800433 <sprintputch+0x1c>
		*b->buf++ = ch;
  800428:	0f b6 4d 08          	movzbl 0x8(%ebp),%ecx
  80042c:	88 08                	mov    %cl,(%eax)
  80042e:	83 c0 01             	add    $0x1,%eax
  800431:	89 02                	mov    %eax,(%edx)
}
  800433:	5d                   	pop    %ebp
  800434:	c3                   	ret    

00800435 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800435:	55                   	push   %ebp
  800436:	89 e5                	mov    %esp,%ebp
  800438:	57                   	push   %edi
  800439:	56                   	push   %esi
  80043a:	53                   	push   %ebx
  80043b:	83 ec 3c             	sub    $0x3c,%esp
  80043e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800441:	eb 18                	jmp    80045b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800443:	84 c0                	test   %al,%al
  800445:	0f 84 9f 03 00 00    	je     8007ea <vprintfmt+0x3b5>
				return;
			putch(ch, putdat);
  80044b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800452:	0f b6 c0             	movzbl %al,%eax
  800455:	89 04 24             	mov    %eax,(%esp)
  800458:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80045b:	0f b6 03             	movzbl (%ebx),%eax
  80045e:	83 c3 01             	add    $0x1,%ebx
  800461:	3c 25                	cmp    $0x25,%al
  800463:	75 de                	jne    800443 <vprintfmt+0xe>
  800465:	b9 00 00 00 00       	mov    $0x0,%ecx
  80046a:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
  800471:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800476:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80047d:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
  800481:	eb 07                	jmp    80048a <vprintfmt+0x55>
  800483:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	0f b6 13             	movzbl (%ebx),%edx
  80048d:	83 c3 01             	add    $0x1,%ebx
  800490:	8d 42 dd             	lea    -0x23(%edx),%eax
  800493:	3c 55                	cmp    $0x55,%al
  800495:	0f 87 22 03 00 00    	ja     8007bd <vprintfmt+0x388>
  80049b:	0f b6 c0             	movzbl %al,%eax
  80049e:	ff 24 85 e0 25 80 00 	jmp    *0x8025e0(,%eax,4)
  8004a5:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
  8004a9:	eb df                	jmp    80048a <vprintfmt+0x55>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004ab:	0f b6 c2             	movzbl %dl,%eax
  8004ae:	8d 78 d0             	lea    -0x30(%eax),%edi
				ch = *fmt;
  8004b1:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8004b4:	8d 42 d0             	lea    -0x30(%edx),%eax
  8004b7:	83 f8 09             	cmp    $0x9,%eax
  8004ba:	76 08                	jbe    8004c4 <vprintfmt+0x8f>
  8004bc:	eb 39                	jmp    8004f7 <vprintfmt+0xc2>
  8004be:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
  8004c2:	eb c6                	jmp    80048a <vprintfmt+0x55>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c4:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  8004c7:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  8004ca:	8d 7c 42 d0          	lea    -0x30(%edx,%eax,2),%edi
				ch = *fmt;
  8004ce:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8004d1:	8d 42 d0             	lea    -0x30(%edx),%eax
  8004d4:	83 f8 09             	cmp    $0x9,%eax
  8004d7:	77 1e                	ja     8004f7 <vprintfmt+0xc2>
  8004d9:	eb e9                	jmp    8004c4 <vprintfmt+0x8f>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004db:	8b 55 14             	mov    0x14(%ebp),%edx
  8004de:	8d 42 04             	lea    0x4(%edx),%eax
  8004e1:	89 45 14             	mov    %eax,0x14(%ebp)
  8004e4:	8b 3a                	mov    (%edx),%edi
  8004e6:	eb 0f                	jmp    8004f7 <vprintfmt+0xc2>
			goto process_precision;

		case '.':
			if (width < 0)
  8004e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004ec:	79 9c                	jns    80048a <vprintfmt+0x55>
  8004ee:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8004f5:	eb 93                	jmp    80048a <vprintfmt+0x55>
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004fb:	90                   	nop    
  8004fc:	8d 74 26 00          	lea    0x0(%esi),%esi
  800500:	79 88                	jns    80048a <vprintfmt+0x55>
  800502:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800505:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80050a:	e9 7b ff ff ff       	jmp    80048a <vprintfmt+0x55>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80050f:	83 c1 01             	add    $0x1,%ecx
  800512:	e9 73 ff ff ff       	jmp    80048a <vprintfmt+0x55>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8d 50 04             	lea    0x4(%eax),%edx
  80051d:	89 55 14             	mov    %edx,0x14(%ebp)
  800520:	8b 55 0c             	mov    0xc(%ebp),%edx
  800523:	89 54 24 04          	mov    %edx,0x4(%esp)
  800527:	8b 00                	mov    (%eax),%eax
  800529:	89 04 24             	mov    %eax,(%esp)
  80052c:	ff 55 08             	call   *0x8(%ebp)
  80052f:	e9 27 ff ff ff       	jmp    80045b <vprintfmt+0x26>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800534:	8b 55 14             	mov    0x14(%ebp),%edx
  800537:	8d 42 04             	lea    0x4(%edx),%eax
  80053a:	89 45 14             	mov    %eax,0x14(%ebp)
  80053d:	8b 02                	mov    (%edx),%eax
  80053f:	89 c2                	mov    %eax,%edx
  800541:	c1 fa 1f             	sar    $0x1f,%edx
  800544:	31 d0                	xor    %edx,%eax
  800546:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800548:	83 f8 0f             	cmp    $0xf,%eax
  80054b:	7f 0b                	jg     800558 <vprintfmt+0x123>
  80054d:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  800554:	85 d2                	test   %edx,%edx
  800556:	75 23                	jne    80057b <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800558:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80055c:	c7 44 24 08 bb 24 80 	movl   $0x8024bb,0x8(%esp)
  800563:	00 
  800564:	8b 45 0c             	mov    0xc(%ebp),%eax
  800567:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056b:	8b 55 08             	mov    0x8(%ebp),%edx
  80056e:	89 14 24             	mov    %edx,(%esp)
  800571:	e8 ff 02 00 00       	call   800875 <printfmt>
  800576:	e9 e0 fe ff ff       	jmp    80045b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80057b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80057f:	c7 44 24 08 c4 24 80 	movl   $0x8024c4,0x8(%esp)
  800586:	00 
  800587:	8b 45 0c             	mov    0xc(%ebp),%eax
  80058a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058e:	8b 55 08             	mov    0x8(%ebp),%edx
  800591:	89 14 24             	mov    %edx,(%esp)
  800594:	e8 dc 02 00 00       	call   800875 <printfmt>
  800599:	e9 bd fe ff ff       	jmp    80045b <vprintfmt+0x26>
  80059e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8005a1:	89 f9                	mov    %edi,%ecx
  8005a3:	89 5d ec             	mov    %ebx,-0x14(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005a6:	8b 55 14             	mov    0x14(%ebp),%edx
  8005a9:	8d 42 04             	lea    0x4(%edx),%eax
  8005ac:	89 45 14             	mov    %eax,0x14(%ebp)
  8005af:	8b 12                	mov    (%edx),%edx
  8005b1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b4:	85 d2                	test   %edx,%edx
  8005b6:	75 07                	jne    8005bf <vprintfmt+0x18a>
  8005b8:	c7 45 dc c7 24 80 00 	movl   $0x8024c7,-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8005bf:	85 f6                	test   %esi,%esi
  8005c1:	7e 41                	jle    800604 <vprintfmt+0x1cf>
  8005c3:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8005c7:	74 3b                	je     800604 <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005d0:	89 04 24             	mov    %eax,(%esp)
  8005d3:	e8 e8 02 00 00       	call   8008c0 <strnlen>
  8005d8:	29 c6                	sub    %eax,%esi
  8005da:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8005dd:	85 f6                	test   %esi,%esi
  8005df:	7e 23                	jle    800604 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005e1:	0f be 55 eb          	movsbl -0x15(%ebp),%edx
  8005e5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ef:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005f2:	89 14 24             	mov    %edx,(%esp)
  8005f5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f8:	83 ee 01             	sub    $0x1,%esi
  8005fb:	75 eb                	jne    8005e8 <vprintfmt+0x1b3>
  8005fd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800604:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800607:	0f b6 02             	movzbl (%edx),%eax
  80060a:	0f be d0             	movsbl %al,%edx
  80060d:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800610:	84 c0                	test   %al,%al
  800612:	75 42                	jne    800656 <vprintfmt+0x221>
  800614:	eb 49                	jmp    80065f <vprintfmt+0x22a>
				if (altflag && (ch < ' ' || ch > '~'))
  800616:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80061a:	74 1b                	je     800637 <vprintfmt+0x202>
  80061c:	8d 42 e0             	lea    -0x20(%edx),%eax
  80061f:	83 f8 5e             	cmp    $0x5e,%eax
  800622:	76 13                	jbe    800637 <vprintfmt+0x202>
					putch('?', putdat);
  800624:	8b 45 0c             	mov    0xc(%ebp),%eax
  800627:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800632:	ff 55 08             	call   *0x8(%ebp)
  800635:	eb 0d                	jmp    800644 <vprintfmt+0x20f>
				else
					putch(ch, putdat);
  800637:	8b 45 0c             	mov    0xc(%ebp),%eax
  80063a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063e:	89 14 24             	mov    %edx,(%esp)
  800641:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800644:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  800648:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80064c:	83 c6 01             	add    $0x1,%esi
  80064f:	84 c0                	test   %al,%al
  800651:	74 0c                	je     80065f <vprintfmt+0x22a>
  800653:	0f be d0             	movsbl %al,%edx
  800656:	85 ff                	test   %edi,%edi
  800658:	78 bc                	js     800616 <vprintfmt+0x1e1>
  80065a:	83 ef 01             	sub    $0x1,%edi
  80065d:	79 b7                	jns    800616 <vprintfmt+0x1e1>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800663:	0f 8e f2 fd ff ff    	jle    80045b <vprintfmt+0x26>
				putch(' ', putdat);
  800669:	8b 55 0c             	mov    0xc(%ebp),%edx
  80066c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800670:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800677:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80067a:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  80067e:	75 e9                	jne    800669 <vprintfmt+0x234>
  800680:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800683:	e9 d3 fd ff ff       	jmp    80045b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800688:	83 f9 01             	cmp    $0x1,%ecx
  80068b:	90                   	nop    
  80068c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800690:	7e 10                	jle    8006a2 <vprintfmt+0x26d>
		return va_arg(*ap, long long);
  800692:	8b 55 14             	mov    0x14(%ebp),%edx
  800695:	8d 42 08             	lea    0x8(%edx),%eax
  800698:	89 45 14             	mov    %eax,0x14(%ebp)
  80069b:	8b 32                	mov    (%edx),%esi
  80069d:	8b 7a 04             	mov    0x4(%edx),%edi
  8006a0:	eb 2a                	jmp    8006cc <vprintfmt+0x297>
	else if (lflag)
  8006a2:	85 c9                	test   %ecx,%ecx
  8006a4:	74 14                	je     8006ba <vprintfmt+0x285>
		return va_arg(*ap, long);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8006af:	8b 00                	mov    (%eax),%eax
  8006b1:	89 c6                	mov    %eax,%esi
  8006b3:	89 c7                	mov    %eax,%edi
  8006b5:	c1 ff 1f             	sar    $0x1f,%edi
  8006b8:	eb 12                	jmp    8006cc <vprintfmt+0x297>
	else
		return va_arg(*ap, int);
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8d 50 04             	lea    0x4(%eax),%edx
  8006c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c3:	8b 00                	mov    (%eax),%eax
  8006c5:	89 c6                	mov    %eax,%esi
  8006c7:	89 c7                	mov    %eax,%edi
  8006c9:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006cc:	89 f2                	mov    %esi,%edx
  8006ce:	89 f9                	mov    %edi,%ecx
  8006d0:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
			if ((long long) num < 0) {
  8006d7:	85 ff                	test   %edi,%edi
  8006d9:	0f 89 9b 00 00 00    	jns    80077a <vprintfmt+0x345>
				putch('-', putdat);
  8006df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006ed:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006f0:	89 f2                	mov    %esi,%edx
  8006f2:	89 f9                	mov    %edi,%ecx
  8006f4:	f7 da                	neg    %edx
  8006f6:	83 d1 00             	adc    $0x0,%ecx
  8006f9:	f7 d9                	neg    %ecx
  8006fb:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  800702:	eb 76                	jmp    80077a <vprintfmt+0x345>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800704:	89 ca                	mov    %ecx,%edx
  800706:	8d 45 14             	lea    0x14(%ebp),%eax
  800709:	e8 cd fc ff ff       	call   8003db <getuint>
  80070e:	89 d1                	mov    %edx,%ecx
  800710:	89 c2                	mov    %eax,%edx
  800712:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  800719:	eb 5f                	jmp    80077a <vprintfmt+0x345>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap,lflag);
  80071b:	89 ca                	mov    %ecx,%edx
  80071d:	8d 45 14             	lea    0x14(%ebp),%eax
  800720:	e8 b6 fc ff ff       	call   8003db <getuint>
  800725:	e9 31 fd ff ff       	jmp    80045b <vprintfmt+0x26>
			base=8;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80072a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80072d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800731:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800738:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80073b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800742:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800749:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  80074c:	8b 55 14             	mov    0x14(%ebp),%edx
  80074f:	8d 42 04             	lea    0x4(%edx),%eax
  800752:	89 45 14             	mov    %eax,0x14(%ebp)
  800755:	8b 12                	mov    (%edx),%edx
  800757:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075c:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  800763:	eb 15                	jmp    80077a <vprintfmt+0x345>
			base = 16;
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800765:	89 ca                	mov    %ecx,%edx
  800767:	8d 45 14             	lea    0x14(%ebp),%eax
  80076a:	e8 6c fc ff ff       	call   8003db <getuint>
  80076f:	89 d1                	mov    %edx,%ecx
  800771:	89 c2                	mov    %eax,%edx
  800773:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80077a:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  80077e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800782:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800785:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800789:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80078c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800790:	89 14 24             	mov    %edx,(%esp)
  800793:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800797:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079a:	8b 45 08             	mov    0x8(%ebp),%eax
  80079d:	e8 4e fb ff ff       	call   8002f0 <printnum>
  8007a2:	e9 b4 fc ff ff       	jmp    80045b <vprintfmt+0x26>
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ae:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007b5:	ff 55 08             	call   *0x8(%ebp)
  8007b8:	e9 9e fc ff ff       	jmp    80045b <vprintfmt+0x26>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007cb:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ce:	83 eb 01             	sub    $0x1,%ebx
  8007d1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007d5:	0f 84 80 fc ff ff    	je     80045b <vprintfmt+0x26>
  8007db:	83 eb 01             	sub    $0x1,%ebx
  8007de:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007e2:	0f 84 73 fc ff ff    	je     80045b <vprintfmt+0x26>
  8007e8:	eb f1                	jmp    8007db <vprintfmt+0x3a6>
				/* do nothing */;
			break;
		}
	}
}
  8007ea:	83 c4 3c             	add    $0x3c,%esp
  8007ed:	5b                   	pop    %ebx
  8007ee:	5e                   	pop    %esi
  8007ef:	5f                   	pop    %edi
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	83 ec 28             	sub    $0x28,%esp
  8007f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8007fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8007fe:	85 d2                	test   %edx,%edx
  800800:	74 04                	je     800806 <vsnprintf+0x14>
  800802:	85 c0                	test   %eax,%eax
  800804:	7f 07                	jg     80080d <vsnprintf+0x1b>
  800806:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80080b:	eb 3b                	jmp    800848 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800814:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
  800818:	89 45 f8             	mov    %eax,-0x8(%ebp)
  80081b:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80081e:	8b 45 14             	mov    0x14(%ebp),%eax
  800821:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800825:	8b 45 10             	mov    0x10(%ebp),%eax
  800828:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80082f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800833:	c7 04 24 17 04 80 00 	movl   $0x800417,(%esp)
  80083a:	e8 f6 fb ff ff       	call   800435 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80083f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800842:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800845:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800848:	c9                   	leave  
  800849:	c3                   	ret    

0080084a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800850:	8d 45 14             	lea    0x14(%ebp),%eax
  800853:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800856:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80085a:	8b 45 10             	mov    0x10(%ebp),%eax
  80085d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800861:	8b 45 0c             	mov    0xc(%ebp),%eax
  800864:	89 44 24 04          	mov    %eax,0x4(%esp)
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	89 04 24             	mov    %eax,(%esp)
  80086e:	e8 7f ff ff ff       	call   8007f2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800873:	c9                   	leave  
  800874:	c3                   	ret    

00800875 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  80087b:	8d 45 14             	lea    0x14(%ebp),%eax
  80087e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800881:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800885:	8b 45 10             	mov    0x10(%ebp),%eax
  800888:	89 44 24 08          	mov    %eax,0x8(%esp)
  80088c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800893:	8b 45 08             	mov    0x8(%ebp),%eax
  800896:	89 04 24             	mov    %eax,(%esp)
  800899:	e8 97 fb ff ff       	call   800435 <vprintfmt>
	va_end(ap);
}
  80089e:	c9                   	leave  
  80089f:	c3                   	ret    

008008a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ab:	80 3a 00             	cmpb   $0x0,(%edx)
  8008ae:	74 0e                	je     8008be <strlen+0x1e>
  8008b0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008b5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b8:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8008bc:	75 f7                	jne    8008b5 <strlen+0x15>
		n++;
	return n;
}
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c9:	85 d2                	test   %edx,%edx
  8008cb:	74 19                	je     8008e6 <strnlen+0x26>
  8008cd:	80 39 00             	cmpb   $0x0,(%ecx)
  8008d0:	74 14                	je     8008e6 <strnlen+0x26>
  8008d2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008d7:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008da:	39 d0                	cmp    %edx,%eax
  8008dc:	74 0d                	je     8008eb <strnlen+0x2b>
  8008de:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  8008e2:	74 07                	je     8008eb <strnlen+0x2b>
  8008e4:	eb f1                	jmp    8008d7 <strnlen+0x17>
  8008e6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008eb:	5d                   	pop    %ebp
  8008ec:	8d 74 26 00          	lea    0x0(%esi),%esi
  8008f0:	c3                   	ret    

008008f1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	53                   	push   %ebx
  8008f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008fb:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008fd:	0f b6 01             	movzbl (%ecx),%eax
  800900:	88 02                	mov    %al,(%edx)
  800902:	83 c2 01             	add    $0x1,%edx
  800905:	83 c1 01             	add    $0x1,%ecx
  800908:	84 c0                	test   %al,%al
  80090a:	75 f1                	jne    8008fd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80090c:	89 d8                	mov    %ebx,%eax
  80090e:	5b                   	pop    %ebx
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	57                   	push   %edi
  800915:	56                   	push   %esi
  800916:	53                   	push   %ebx
  800917:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800920:	85 f6                	test   %esi,%esi
  800922:	74 1c                	je     800940 <strncpy+0x2f>
  800924:	89 fa                	mov    %edi,%edx
  800926:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  80092b:	0f b6 01             	movzbl (%ecx),%eax
  80092e:	88 02                	mov    %al,(%edx)
  800930:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800933:	80 39 01             	cmpb   $0x1,(%ecx)
  800936:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800939:	83 c3 01             	add    $0x1,%ebx
  80093c:	39 f3                	cmp    %esi,%ebx
  80093e:	75 eb                	jne    80092b <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800940:	89 f8                	mov    %edi,%eax
  800942:	5b                   	pop    %ebx
  800943:	5e                   	pop    %esi
  800944:	5f                   	pop    %edi
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	56                   	push   %esi
  80094b:	53                   	push   %ebx
  80094c:	8b 75 08             	mov    0x8(%ebp),%esi
  80094f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800952:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800955:	89 f0                	mov    %esi,%eax
  800957:	85 d2                	test   %edx,%edx
  800959:	74 2c                	je     800987 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  80095b:	89 d3                	mov    %edx,%ebx
  80095d:	83 eb 01             	sub    $0x1,%ebx
  800960:	74 20                	je     800982 <strlcpy+0x3b>
  800962:	0f b6 11             	movzbl (%ecx),%edx
  800965:	84 d2                	test   %dl,%dl
  800967:	74 19                	je     800982 <strlcpy+0x3b>
  800969:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  80096b:	88 10                	mov    %dl,(%eax)
  80096d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800970:	83 eb 01             	sub    $0x1,%ebx
  800973:	74 0f                	je     800984 <strlcpy+0x3d>
  800975:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  800979:	83 c1 01             	add    $0x1,%ecx
  80097c:	84 d2                	test   %dl,%dl
  80097e:	74 04                	je     800984 <strlcpy+0x3d>
  800980:	eb e9                	jmp    80096b <strlcpy+0x24>
  800982:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800984:	c6 00 00             	movb   $0x0,(%eax)
  800987:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800989:	5b                   	pop    %ebx
  80098a:	5e                   	pop    %esi
  80098b:	5d                   	pop    %ebp
  80098c:	c3                   	ret    

0080098d <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	56                   	push   %esi
  800991:	53                   	push   %ebx
  800992:	8b 75 08             	mov    0x8(%ebp),%esi
  800995:	8b 45 0c             	mov    0xc(%ebp),%eax
  800998:	8b 55 10             	mov    0x10(%ebp),%edx
    int c;
    char *q = buf;

    if (buf_size <= 0)
  80099b:	85 c0                	test   %eax,%eax
  80099d:	7e 2e                	jle    8009cd <pstrcpy+0x40>
        return;

    for(;;) {
        c = *str++;
  80099f:	0f b6 0a             	movzbl (%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  8009a2:	84 c9                	test   %cl,%cl
  8009a4:	74 22                	je     8009c8 <pstrcpy+0x3b>
  8009a6:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  8009aa:	89 f0                	mov    %esi,%eax
  8009ac:	39 de                	cmp    %ebx,%esi
  8009ae:	72 09                	jb     8009b9 <pstrcpy+0x2c>
  8009b0:	eb 16                	jmp    8009c8 <pstrcpy+0x3b>
  8009b2:	83 c2 01             	add    $0x1,%edx
  8009b5:	39 d8                	cmp    %ebx,%eax
  8009b7:	73 11                	jae    8009ca <pstrcpy+0x3d>
            break;
        *q++ = c;
  8009b9:	88 08                	mov    %cl,(%eax)
  8009bb:	83 c0 01             	add    $0x1,%eax

    if (buf_size <= 0)
        return;

    for(;;) {
        c = *str++;
  8009be:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  8009c2:	84 c9                	test   %cl,%cl
  8009c4:	75 ec                	jne    8009b2 <pstrcpy+0x25>
  8009c6:	eb 02                	jmp    8009ca <pstrcpy+0x3d>
  8009c8:	89 f0                	mov    %esi,%eax
            break;
        *q++ = c;
    }
    *q = '\0';
  8009ca:	c6 00 00             	movb   $0x0,(%eax)
}
  8009cd:	5b                   	pop    %ebx
  8009ce:	5e                   	pop    %esi
  8009cf:	5d                   	pop    %ebp
  8009d0:	c3                   	ret    

008009d1 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  8009da:	0f b6 02             	movzbl (%edx),%eax
  8009dd:	84 c0                	test   %al,%al
  8009df:	74 16                	je     8009f7 <strcmp+0x26>
  8009e1:	3a 01                	cmp    (%ecx),%al
  8009e3:	75 12                	jne    8009f7 <strcmp+0x26>
		p++, q++;
  8009e5:	83 c1 01             	add    $0x1,%ecx
    *q = '\0';
}
int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009e8:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  8009ec:	84 c0                	test   %al,%al
  8009ee:	74 07                	je     8009f7 <strcmp+0x26>
  8009f0:	83 c2 01             	add    $0x1,%edx
  8009f3:	3a 01                	cmp    (%ecx),%al
  8009f5:	74 ee                	je     8009e5 <strcmp+0x14>
  8009f7:	0f b6 c0             	movzbl %al,%eax
  8009fa:	0f b6 11             	movzbl (%ecx),%edx
  8009fd:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	53                   	push   %ebx
  800a05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a0b:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a0e:	85 d2                	test   %edx,%edx
  800a10:	74 2d                	je     800a3f <strncmp+0x3e>
  800a12:	0f b6 01             	movzbl (%ecx),%eax
  800a15:	84 c0                	test   %al,%al
  800a17:	74 1a                	je     800a33 <strncmp+0x32>
  800a19:	3a 03                	cmp    (%ebx),%al
  800a1b:	75 16                	jne    800a33 <strncmp+0x32>
  800a1d:	83 ea 01             	sub    $0x1,%edx
  800a20:	74 1d                	je     800a3f <strncmp+0x3e>
		n--, p++, q++;
  800a22:	83 c1 01             	add    $0x1,%ecx
  800a25:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a28:	0f b6 01             	movzbl (%ecx),%eax
  800a2b:	84 c0                	test   %al,%al
  800a2d:	74 04                	je     800a33 <strncmp+0x32>
  800a2f:	3a 03                	cmp    (%ebx),%al
  800a31:	74 ea                	je     800a1d <strncmp+0x1c>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a33:	0f b6 11             	movzbl (%ecx),%edx
  800a36:	0f b6 03             	movzbl (%ebx),%eax
  800a39:	29 c2                	sub    %eax,%edx
  800a3b:	89 d0                	mov    %edx,%eax
  800a3d:	eb 05                	jmp    800a44 <strncmp+0x43>
  800a3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a44:	5b                   	pop    %ebx
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a51:	0f b6 10             	movzbl (%eax),%edx
  800a54:	84 d2                	test   %dl,%dl
  800a56:	74 14                	je     800a6c <strchr+0x25>
		if (*s == c)
  800a58:	38 ca                	cmp    %cl,%dl
  800a5a:	75 06                	jne    800a62 <strchr+0x1b>
  800a5c:	eb 13                	jmp    800a71 <strchr+0x2a>
  800a5e:	38 ca                	cmp    %cl,%dl
  800a60:	74 0f                	je     800a71 <strchr+0x2a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a62:	83 c0 01             	add    $0x1,%eax
  800a65:	0f b6 10             	movzbl (%eax),%edx
  800a68:	84 d2                	test   %dl,%dl
  800a6a:	75 f2                	jne    800a5e <strchr+0x17>
  800a6c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a71:	5d                   	pop    %ebp
  800a72:	c3                   	ret    

00800a73 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	8b 45 08             	mov    0x8(%ebp),%eax
  800a79:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a7d:	0f b6 10             	movzbl (%eax),%edx
  800a80:	84 d2                	test   %dl,%dl
  800a82:	74 18                	je     800a9c <strfind+0x29>
		if (*s == c)
  800a84:	38 ca                	cmp    %cl,%dl
  800a86:	75 0a                	jne    800a92 <strfind+0x1f>
  800a88:	eb 12                	jmp    800a9c <strfind+0x29>
  800a8a:	38 ca                	cmp    %cl,%dl
  800a8c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800a90:	74 0a                	je     800a9c <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a92:	83 c0 01             	add    $0x1,%eax
  800a95:	0f b6 10             	movzbl (%eax),%edx
  800a98:	84 d2                	test   %dl,%dl
  800a9a:	75 ee                	jne    800a8a <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	83 ec 08             	sub    $0x8,%esp
  800aa4:	89 1c 24             	mov    %ebx,(%esp)
  800aa7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aab:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800ab1:	85 db                	test   %ebx,%ebx
  800ab3:	74 36                	je     800aeb <memset+0x4d>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ab5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800abb:	75 26                	jne    800ae3 <memset+0x45>
  800abd:	f6 c3 03             	test   $0x3,%bl
  800ac0:	75 21                	jne    800ae3 <memset+0x45>
		c &= 0xFF;
  800ac2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ac6:	89 d0                	mov    %edx,%eax
  800ac8:	c1 e0 18             	shl    $0x18,%eax
  800acb:	89 d1                	mov    %edx,%ecx
  800acd:	c1 e1 10             	shl    $0x10,%ecx
  800ad0:	09 c8                	or     %ecx,%eax
  800ad2:	09 d0                	or     %edx,%eax
  800ad4:	c1 e2 08             	shl    $0x8,%edx
  800ad7:	09 d0                	or     %edx,%eax
  800ad9:	89 d9                	mov    %ebx,%ecx
  800adb:	c1 e9 02             	shr    $0x2,%ecx
  800ade:	fc                   	cld    
  800adf:	f3 ab                	rep stos %eax,%es:(%edi)
  800ae1:	eb 08                	jmp    800aeb <memset+0x4d>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ae3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae6:	89 d9                	mov    %ebx,%ecx
  800ae8:	fc                   	cld    
  800ae9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aeb:	89 f8                	mov    %edi,%eax
  800aed:	8b 1c 24             	mov    (%esp),%ebx
  800af0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800af4:	89 ec                	mov    %ebp,%esp
  800af6:	5d                   	pop    %ebp
  800af7:	c3                   	ret    

00800af8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	83 ec 08             	sub    $0x8,%esp
  800afe:	89 34 24             	mov    %esi,(%esp)
  800b01:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b05:	8b 45 08             	mov    0x8(%ebp),%eax
  800b08:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800b0b:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b0e:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b10:	39 c6                	cmp    %eax,%esi
  800b12:	73 38                	jae    800b4c <memmove+0x54>
  800b14:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b17:	39 d0                	cmp    %edx,%eax
  800b19:	73 31                	jae    800b4c <memmove+0x54>
		s += n;
		d += n;
  800b1b:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1e:	f6 c2 03             	test   $0x3,%dl
  800b21:	75 1d                	jne    800b40 <memmove+0x48>
  800b23:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b29:	75 15                	jne    800b40 <memmove+0x48>
  800b2b:	f6 c1 03             	test   $0x3,%cl
  800b2e:	66 90                	xchg   %ax,%ax
  800b30:	75 0e                	jne    800b40 <memmove+0x48>
			asm volatile("std; rep movsl\n"
  800b32:	8d 7e fc             	lea    -0x4(%esi),%edi
  800b35:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b38:	c1 e9 02             	shr    $0x2,%ecx
  800b3b:	fd                   	std    
  800b3c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3e:	eb 09                	jmp    800b49 <memmove+0x51>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b40:	8d 7e ff             	lea    -0x1(%esi),%edi
  800b43:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b46:	fd                   	std    
  800b47:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b49:	fc                   	cld    
  800b4a:	eb 21                	jmp    800b6d <memmove+0x75>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b52:	75 16                	jne    800b6a <memmove+0x72>
  800b54:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b5a:	75 0e                	jne    800b6a <memmove+0x72>
  800b5c:	f6 c1 03             	test   $0x3,%cl
  800b5f:	90                   	nop    
  800b60:	75 08                	jne    800b6a <memmove+0x72>
			asm volatile("cld; rep movsl\n"
  800b62:	c1 e9 02             	shr    $0x2,%ecx
  800b65:	fc                   	cld    
  800b66:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b68:	eb 03                	jmp    800b6d <memmove+0x75>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b6a:	fc                   	cld    
  800b6b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b6d:	8b 34 24             	mov    (%esp),%esi
  800b70:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b74:	89 ec                	mov    %ebp,%esp
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b7e:	8b 45 10             	mov    0x10(%ebp),%eax
  800b81:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b85:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b88:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8f:	89 04 24             	mov    %eax,(%esp)
  800b92:	e8 61 ff ff ff       	call   800af8 <memmove>
}
  800b97:	c9                   	leave  
  800b98:	c3                   	ret    

00800b99 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	57                   	push   %edi
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
  800b9f:	83 ec 04             	sub    $0x4,%esp
  800ba2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba8:	8b 55 10             	mov    0x10(%ebp),%edx
  800bab:	83 ea 01             	sub    $0x1,%edx
  800bae:	83 fa ff             	cmp    $0xffffffff,%edx
  800bb1:	74 47                	je     800bfa <memcmp+0x61>
		if (*s1 != *s2)
  800bb3:	0f b6 30             	movzbl (%eax),%esi
  800bb6:	0f b6 39             	movzbl (%ecx),%edi
			return (int) *s1 - (int) *s2;
  800bb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800bbc:	89 f0                	mov    %esi,%eax
  800bbe:	89 fb                	mov    %edi,%ebx
  800bc0:	38 d8                	cmp    %bl,%al
  800bc2:	74 2e                	je     800bf2 <memcmp+0x59>
  800bc4:	eb 1c                	jmp    800be2 <memcmp+0x49>
  800bc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bc9:	0f b6 70 01          	movzbl 0x1(%eax),%esi
  800bcd:	0f b6 79 01          	movzbl 0x1(%ecx),%edi
  800bd1:	83 c0 01             	add    $0x1,%eax
  800bd4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800bd7:	83 c1 01             	add    $0x1,%ecx
  800bda:	89 f3                	mov    %esi,%ebx
  800bdc:	89 f8                	mov    %edi,%eax
  800bde:	38 c3                	cmp    %al,%bl
  800be0:	74 10                	je     800bf2 <memcmp+0x59>
			return (int) *s1 - (int) *s2;
  800be2:	89 f1                	mov    %esi,%ecx
  800be4:	0f b6 d1             	movzbl %cl,%edx
  800be7:	89 fb                	mov    %edi,%ebx
  800be9:	0f b6 c3             	movzbl %bl,%eax
  800bec:	29 c2                	sub    %eax,%edx
  800bee:	89 d0                	mov    %edx,%eax
  800bf0:	eb 0d                	jmp    800bff <memcmp+0x66>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf2:	83 ea 01             	sub    $0x1,%edx
  800bf5:	83 fa ff             	cmp    $0xffffffff,%edx
  800bf8:	75 cc                	jne    800bc6 <memcmp+0x2d>
  800bfa:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800bff:	83 c4 04             	add    $0x4,%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c0d:	89 c1                	mov    %eax,%ecx
  800c0f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
  800c12:	39 c8                	cmp    %ecx,%eax
  800c14:	73 15                	jae    800c2b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c16:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
  800c1a:	38 10                	cmp    %dl,(%eax)
  800c1c:	75 06                	jne    800c24 <memfind+0x1d>
  800c1e:	eb 0b                	jmp    800c2b <memfind+0x24>
  800c20:	38 10                	cmp    %dl,(%eax)
  800c22:	74 07                	je     800c2b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c24:	83 c0 01             	add    $0x1,%eax
  800c27:	39 c8                	cmp    %ecx,%eax
  800c29:	75 f5                	jne    800c20 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c2b:	5d                   	pop    %ebp
  800c2c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800c30:	c3                   	ret    

00800c31 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	57                   	push   %edi
  800c35:	56                   	push   %esi
  800c36:	53                   	push   %ebx
  800c37:	83 ec 04             	sub    $0x4,%esp
  800c3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3d:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c40:	0f b6 01             	movzbl (%ecx),%eax
  800c43:	3c 20                	cmp    $0x20,%al
  800c45:	74 04                	je     800c4b <strtol+0x1a>
  800c47:	3c 09                	cmp    $0x9,%al
  800c49:	75 0e                	jne    800c59 <strtol+0x28>
		s++;
  800c4b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c4e:	0f b6 01             	movzbl (%ecx),%eax
  800c51:	3c 20                	cmp    $0x20,%al
  800c53:	74 f6                	je     800c4b <strtol+0x1a>
  800c55:	3c 09                	cmp    $0x9,%al
  800c57:	74 f2                	je     800c4b <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c59:	3c 2b                	cmp    $0x2b,%al
  800c5b:	75 0c                	jne    800c69 <strtol+0x38>
		s++;
  800c5d:	83 c1 01             	add    $0x1,%ecx
  800c60:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c67:	eb 15                	jmp    800c7e <strtol+0x4d>
	else if (*s == '-')
  800c69:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c70:	3c 2d                	cmp    $0x2d,%al
  800c72:	75 0a                	jne    800c7e <strtol+0x4d>
		s++, neg = 1;
  800c74:	83 c1 01             	add    $0x1,%ecx
  800c77:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c7e:	85 f6                	test   %esi,%esi
  800c80:	0f 94 c0             	sete   %al
  800c83:	74 05                	je     800c8a <strtol+0x59>
  800c85:	83 fe 10             	cmp    $0x10,%esi
  800c88:	75 18                	jne    800ca2 <strtol+0x71>
  800c8a:	80 39 30             	cmpb   $0x30,(%ecx)
  800c8d:	75 13                	jne    800ca2 <strtol+0x71>
  800c8f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c93:	75 0d                	jne    800ca2 <strtol+0x71>
		s += 2, base = 16;
  800c95:	83 c1 02             	add    $0x2,%ecx
  800c98:	be 10 00 00 00       	mov    $0x10,%esi
  800c9d:	8d 76 00             	lea    0x0(%esi),%esi
  800ca0:	eb 1b                	jmp    800cbd <strtol+0x8c>
	else if (base == 0 && s[0] == '0')
  800ca2:	85 f6                	test   %esi,%esi
  800ca4:	75 0e                	jne    800cb4 <strtol+0x83>
  800ca6:	80 39 30             	cmpb   $0x30,(%ecx)
  800ca9:	75 09                	jne    800cb4 <strtol+0x83>
		s++, base = 8;
  800cab:	83 c1 01             	add    $0x1,%ecx
  800cae:	66 be 08 00          	mov    $0x8,%si
  800cb2:	eb 09                	jmp    800cbd <strtol+0x8c>
	else if (base == 0)
  800cb4:	84 c0                	test   %al,%al
  800cb6:	74 05                	je     800cbd <strtol+0x8c>
  800cb8:	be 0a 00 00 00       	mov    $0xa,%esi
  800cbd:	bf 00 00 00 00       	mov    $0x0,%edi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cc2:	0f b6 11             	movzbl (%ecx),%edx
  800cc5:	89 d3                	mov    %edx,%ebx
  800cc7:	8d 42 d0             	lea    -0x30(%edx),%eax
  800cca:	3c 09                	cmp    $0x9,%al
  800ccc:	77 08                	ja     800cd6 <strtol+0xa5>
			dig = *s - '0';
  800cce:	0f be c2             	movsbl %dl,%eax
  800cd1:	8d 50 d0             	lea    -0x30(%eax),%edx
  800cd4:	eb 1c                	jmp    800cf2 <strtol+0xc1>
		else if (*s >= 'a' && *s <= 'z')
  800cd6:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800cd9:	3c 19                	cmp    $0x19,%al
  800cdb:	77 08                	ja     800ce5 <strtol+0xb4>
			dig = *s - 'a' + 10;
  800cdd:	0f be c2             	movsbl %dl,%eax
  800ce0:	8d 50 a9             	lea    -0x57(%eax),%edx
  800ce3:	eb 0d                	jmp    800cf2 <strtol+0xc1>
		else if (*s >= 'A' && *s <= 'Z')
  800ce5:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800ce8:	3c 19                	cmp    $0x19,%al
  800cea:	77 17                	ja     800d03 <strtol+0xd2>
			dig = *s - 'A' + 10;
  800cec:	0f be c2             	movsbl %dl,%eax
  800cef:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800cf2:	39 f2                	cmp    %esi,%edx
  800cf4:	7d 0d                	jge    800d03 <strtol+0xd2>
			break;
		s++, val = (val * base) + dig;
  800cf6:	83 c1 01             	add    $0x1,%ecx
  800cf9:	89 f8                	mov    %edi,%eax
  800cfb:	0f af c6             	imul   %esi,%eax
  800cfe:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800d01:	eb bf                	jmp    800cc2 <strtol+0x91>
		// we don't properly detect overflow!
	}
  800d03:	89 f8                	mov    %edi,%eax

	if (endptr)
  800d05:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d09:	74 05                	je     800d10 <strtol+0xdf>
		*endptr = (char *) s;
  800d0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d0e:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800d10:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800d14:	74 04                	je     800d1a <strtol+0xe9>
  800d16:	89 c7                	mov    %eax,%edi
  800d18:	f7 df                	neg    %edi
}
  800d1a:	89 f8                	mov    %edi,%eax
  800d1c:	83 c4 04             	add    $0x4,%esp
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	83 ec 0c             	sub    $0xc,%esp
  800d2a:	89 1c 24             	mov    %ebx,(%esp)
  800d2d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d31:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d35:	b8 01 00 00 00       	mov    $0x1,%eax
  800d3a:	bf 00 00 00 00       	mov    $0x0,%edi
  800d3f:	89 fa                	mov    %edi,%edx
  800d41:	89 f9                	mov    %edi,%ecx
  800d43:	89 fb                	mov    %edi,%ebx
  800d45:	89 fe                	mov    %edi,%esi
  800d47:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d49:	8b 1c 24             	mov    (%esp),%ebx
  800d4c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d50:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d54:	89 ec                	mov    %ebp,%esp
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    

00800d58 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	83 ec 0c             	sub    $0xc,%esp
  800d5e:	89 1c 24             	mov    %ebx,(%esp)
  800d61:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d65:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6f:	bf 00 00 00 00       	mov    $0x0,%edi
  800d74:	89 f8                	mov    %edi,%eax
  800d76:	89 fb                	mov    %edi,%ebx
  800d78:	89 fe                	mov    %edi,%esi
  800d7a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d7c:	8b 1c 24             	mov    (%esp),%ebx
  800d7f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d83:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d87:	89 ec                	mov    %ebp,%esp
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	83 ec 28             	sub    $0x28,%esp
  800d91:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d94:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d97:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800da2:	bf 00 00 00 00       	mov    $0x0,%edi
  800da7:	89 f9                	mov    %edi,%ecx
  800da9:	89 fb                	mov    %edi,%ebx
  800dab:	89 fe                	mov    %edi,%esi
  800dad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800daf:	85 c0                	test   %eax,%eax
  800db1:	7e 28                	jle    800ddb <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db7:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800dbe:	00 
  800dbf:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800dc6:	00 
  800dc7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dce:	00 
  800dcf:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800dd6:	e8 e1 f3 ff ff       	call   8001bc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ddb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dde:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800de4:	89 ec                	mov    %ebp,%esp
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	83 ec 0c             	sub    $0xc,%esp
  800dee:	89 1c 24             	mov    %ebx,(%esp)
  800df1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800df5:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800df9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e02:	8b 7d 14             	mov    0x14(%ebp),%edi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e05:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e0a:	be 00 00 00 00       	mov    $0x0,%esi
  800e0f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e11:	8b 1c 24             	mov    (%esp),%ebx
  800e14:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e18:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e1c:	89 ec                	mov    %ebp,%esp
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    

00800e20 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	83 ec 28             	sub    $0x28,%esp
  800e26:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e29:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e2c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e35:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e3a:	bf 00 00 00 00       	mov    $0x0,%edi
  800e3f:	89 fb                	mov    %edi,%ebx
  800e41:	89 fe                	mov    %edi,%esi
  800e43:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800e45:	85 c0                	test   %eax,%eax
  800e47:	7e 28                	jle    800e71 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e49:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4d:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e54:	00 
  800e55:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800e5c:	00 
  800e5d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e64:	00 
  800e65:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800e6c:	e8 4b f3 ff ff       	call   8001bc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e71:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e74:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e77:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e7a:	89 ec                	mov    %ebp,%esp
  800e7c:	5d                   	pop    %ebp
  800e7d:	c3                   	ret    

00800e7e <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	83 ec 28             	sub    $0x28,%esp
  800e84:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e87:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e8a:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e93:	b8 09 00 00 00       	mov    $0x9,%eax
  800e98:	bf 00 00 00 00       	mov    $0x0,%edi
  800e9d:	89 fb                	mov    %edi,%ebx
  800e9f:	89 fe                	mov    %edi,%esi
  800ea1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800ea3:	85 c0                	test   %eax,%eax
  800ea5:	7e 28                	jle    800ecf <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eab:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800eb2:	00 
  800eb3:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800eba:	00 
  800ebb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec2:	00 
  800ec3:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800eca:	e8 ed f2 ff ff       	call   8001bc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ecf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ed2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ed5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ed8:	89 ec                	mov    %ebp,%esp
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 28             	sub    $0x28,%esp
  800ee2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ee5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ee8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800eeb:	8b 55 08             	mov    0x8(%ebp),%edx
  800eee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef1:	b8 08 00 00 00       	mov    $0x8,%eax
  800ef6:	bf 00 00 00 00       	mov    $0x0,%edi
  800efb:	89 fb                	mov    %edi,%ebx
  800efd:	89 fe                	mov    %edi,%esi
  800eff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f01:	85 c0                	test   %eax,%eax
  800f03:	7e 28                	jle    800f2d <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f05:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f09:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f10:	00 
  800f11:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800f18:	00 
  800f19:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f20:	00 
  800f21:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800f28:	e8 8f f2 ff ff       	call   8001bc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f2d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f30:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f33:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f36:	89 ec                	mov    %ebp,%esp
  800f38:	5d                   	pop    %ebp
  800f39:	c3                   	ret    

00800f3a <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800f3a:	55                   	push   %ebp
  800f3b:	89 e5                	mov    %esp,%ebp
  800f3d:	83 ec 28             	sub    $0x28,%esp
  800f40:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f43:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f46:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f49:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4f:	b8 06 00 00 00       	mov    $0x6,%eax
  800f54:	bf 00 00 00 00       	mov    $0x0,%edi
  800f59:	89 fb                	mov    %edi,%ebx
  800f5b:	89 fe                	mov    %edi,%esi
  800f5d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	7e 28                	jle    800f8b <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f63:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f67:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f6e:	00 
  800f6f:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800f76:	00 
  800f77:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7e:	00 
  800f7f:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800f86:	e8 31 f2 ff ff       	call   8001bc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f8b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f8e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f91:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f94:	89 ec                	mov    %ebp,%esp
  800f96:	5d                   	pop    %ebp
  800f97:	c3                   	ret    

00800f98 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	83 ec 28             	sub    $0x28,%esp
  800f9e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fa1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fa4:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fa7:	8b 55 08             	mov    0x8(%ebp),%edx
  800faa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fb0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fb3:	8b 75 18             	mov    0x18(%ebp),%esi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb6:	b8 05 00 00 00       	mov    $0x5,%eax
  800fbb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	7e 28                	jle    800fe9 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fc5:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800fcc:	00 
  800fcd:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800fd4:	00 
  800fd5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fdc:	00 
  800fdd:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800fe4:	e8 d3 f1 ff ff       	call   8001bc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fe9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fec:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fef:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ff2:	89 ec                	mov    %ebp,%esp
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    

00800ff6 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	83 ec 28             	sub    $0x28,%esp
  800ffc:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fff:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801002:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801005:	8b 55 08             	mov    0x8(%ebp),%edx
  801008:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80100b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80100e:	b8 04 00 00 00       	mov    $0x4,%eax
  801013:	bf 00 00 00 00       	mov    $0x0,%edi
  801018:	89 fe                	mov    %edi,%esi
  80101a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  80101c:	85 c0                	test   %eax,%eax
  80101e:	7e 28                	jle    801048 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  801020:	89 44 24 10          	mov    %eax,0x10(%esp)
  801024:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80102b:	00 
  80102c:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  801033:	00 
  801034:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80103b:	00 
  80103c:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  801043:	e8 74 f1 ff ff       	call   8001bc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801048:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80104b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80104e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801051:	89 ec                	mov    %ebp,%esp
  801053:	5d                   	pop    %ebp
  801054:	c3                   	ret    

00801055 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	83 ec 0c             	sub    $0xc,%esp
  80105b:	89 1c 24             	mov    %ebx,(%esp)
  80105e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801062:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801066:	b8 0b 00 00 00       	mov    $0xb,%eax
  80106b:	bf 00 00 00 00       	mov    $0x0,%edi
  801070:	89 fa                	mov    %edi,%edx
  801072:	89 f9                	mov    %edi,%ecx
  801074:	89 fb                	mov    %edi,%ebx
  801076:	89 fe                	mov    %edi,%esi
  801078:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80107a:	8b 1c 24             	mov    (%esp),%ebx
  80107d:	8b 74 24 04          	mov    0x4(%esp),%esi
  801081:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801085:	89 ec                	mov    %ebp,%esp
  801087:	5d                   	pop    %ebp
  801088:	c3                   	ret    

00801089 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	83 ec 0c             	sub    $0xc,%esp
  80108f:	89 1c 24             	mov    %ebx,(%esp)
  801092:	89 74 24 04          	mov    %esi,0x4(%esp)
  801096:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109a:	b8 02 00 00 00       	mov    $0x2,%eax
  80109f:	bf 00 00 00 00       	mov    $0x0,%edi
  8010a4:	89 fa                	mov    %edi,%edx
  8010a6:	89 f9                	mov    %edi,%ecx
  8010a8:	89 fb                	mov    %edi,%ebx
  8010aa:	89 fe                	mov    %edi,%esi
  8010ac:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010ae:	8b 1c 24             	mov    (%esp),%ebx
  8010b1:	8b 74 24 04          	mov    0x4(%esp),%esi
  8010b5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8010b9:	89 ec                	mov    %ebp,%esp
  8010bb:	5d                   	pop    %ebp
  8010bc:	c3                   	ret    

008010bd <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8010bd:	55                   	push   %ebp
  8010be:	89 e5                	mov    %esp,%ebp
  8010c0:	83 ec 28             	sub    $0x28,%esp
  8010c3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010c6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010c9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8010cc:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010cf:	b8 03 00 00 00       	mov    $0x3,%eax
  8010d4:	bf 00 00 00 00       	mov    $0x0,%edi
  8010d9:	89 f9                	mov    %edi,%ecx
  8010db:	89 fb                	mov    %edi,%ebx
  8010dd:	89 fe                	mov    %edi,%esi
  8010df:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8010e1:	85 c0                	test   %eax,%eax
  8010e3:	7e 28                	jle    80110d <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010e5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010e9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8010f0:	00 
  8010f1:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  8010f8:	00 
  8010f9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801100:	00 
  801101:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  801108:	e8 af f0 ff ff       	call   8001bc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80110d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801110:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801113:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801116:	89 ec                	mov    %ebp,%esp
  801118:	5d                   	pop    %ebp
  801119:	c3                   	ret    
  80111a:	00 00                	add    %al,(%eax)
  80111c:	00 00                	add    %al,(%eax)
	...

00801120 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
// 
static int
duppage(envid_t envid, unsigned pn)
{
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	53                   	push   %ebx
  801124:	83 ec 14             	sub    $0x14,%esp
  801127:	89 c1                	mov    %eax,%ecx
	int r;

	// LAB 4: Your code here.
	pde_t *pde;
	pte_t *pte;
	void *addr=(void*)(pn*PGSIZE);
  801129:	89 d3                	mov    %edx,%ebx
  80112b:	c1 e3 0c             	shl    $0xc,%ebx
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
  80112e:	89 d8                	mov    %ebx,%eax
  801130:	c1 e8 16             	shr    $0x16,%eax
  801133:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  80113a:	01 
  80113b:	74 14                	je     801151 <duppage+0x31>
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else    panic("page table for pn page is not exist");
	if((*pte&PTE_W)||(*pte&PTE_COW))
  80113d:	89 d8                	mov    %ebx,%eax
  80113f:	c1 e8 0c             	shr    $0xc,%eax
  801142:	f7 04 85 00 00 40 ef 	testl  $0x802,-0x10c00000(,%eax,4)
  801149:	02 08 00 00 
  80114d:	75 1e                	jne    80116d <duppage+0x4d>
  80114f:	eb 73                	jmp    8011c4 <duppage+0xa4>
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else    panic("page table for pn page is not exist");
  801151:	c7 44 24 08 cc 27 80 	movl   $0x8027cc,0x8(%esp)
  801158:	00 
  801159:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
  801160:	00 
  801161:	c7 04 24 8a 28 80 00 	movl   $0x80288a,(%esp)
  801168:	e8 4f f0 ff ff       	call   8001bc <_panic>
	if((*pte&PTE_W)||(*pte&PTE_COW))
	{
		if((r=sys_page_map(0,addr,envid,addr,PTE_COW|PTE_U))<0)
  80116d:	c7 44 24 10 04 08 00 	movl   $0x804,0x10(%esp)
  801174:	00 
  801175:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801179:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80117d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801181:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801188:	e8 0b fe ff ff       	call   800f98 <sys_page_map>
  80118d:	85 c0                	test   %eax,%eax
  80118f:	78 60                	js     8011f1 <duppage+0xd1>
			return r;
		if((r=sys_page_map(0,addr,0,addr,PTE_COW|PTE_U))<0)//映射的时候注意env的id
  801191:	c7 44 24 10 04 08 00 	movl   $0x804,0x10(%esp)
  801198:	00 
  801199:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80119d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011a4:	00 
  8011a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011b0:	e8 e3 fd ff ff       	call   800f98 <sys_page_map>
  8011b5:	85 c0                	test   %eax,%eax
  8011b7:	0f 9f c2             	setg   %dl
  8011ba:	0f b6 d2             	movzbl %dl,%edx
  8011bd:	83 ea 01             	sub    $0x1,%edx
  8011c0:	21 d0                	and    %edx,%eax
  8011c2:	eb 2d                	jmp    8011f1 <duppage+0xd1>
                        return r;
	}
	else{	
		if((r=sys_page_map(0,addr,envid,addr,PTE_U|PTE_P))<0)
  8011c4:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8011cb:	00 
  8011cc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011d0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011df:	e8 b4 fd ff ff       	call   800f98 <sys_page_map>
  8011e4:	85 c0                	test   %eax,%eax
  8011e6:	0f 9f c2             	setg   %dl
  8011e9:	0f b6 d2             	movzbl %dl,%edx
  8011ec:	83 ea 01             	sub    $0x1,%edx
  8011ef:	21 d0                	and    %edx,%eax
			return r;
	}
	//panic("duppage not implemented");
	return 0;
}
  8011f1:	83 c4 14             	add    $0x14,%esp
  8011f4:	5b                   	pop    %ebx
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    

008011f7 <sfork>:
	return 0;
}
// Challenge!
int
sfork(void)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	57                   	push   %edi
  8011fb:	56                   	push   %esi
  8011fc:	53                   	push   %ebx
  8011fd:	83 ec 1c             	sub    $0x1c,%esp
static __inline envid_t sys_exofork(void) __attribute__((always_inline));
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801200:	ba 07 00 00 00       	mov    $0x7,%edx
  801205:	89 d0                	mov    %edx,%eax
  801207:	cd 30                	int    $0x30
  801209:	89 45 f0             	mov    %eax,-0x10(%ebp)
	pte_t *pte;
	unsigned i;
	uint32_t addr;
	envid_t envid;
	envid = sys_exofork();//创建子环境
	if(envid < 0)
  80120c:	85 c0                	test   %eax,%eax
  80120e:	79 20                	jns    801230 <sfork+0x39>
		panic("sys_exofork: %e", envid);
  801210:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801214:	c7 44 24 08 95 28 80 	movl   $0x802895,0x8(%esp)
  80121b:	00 
  80121c:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  801223:	00 
  801224:	c7 04 24 8a 28 80 00 	movl   $0x80288a,(%esp)
  80122b:	e8 8c ef ff ff       	call   8001bc <_panic>
	if(envid==0)//子环境中
  801230:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801234:	75 21                	jne    801257 <sfork+0x60>
	{
		env = &envs[ENVX(sys_getenvid())];
  801236:	e8 4e fe ff ff       	call   801089 <sys_getenvid>
  80123b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801240:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801243:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801248:	a3 20 50 80 00       	mov    %eax,0x805020
  80124d:	b8 00 00 00 00       	mov    $0x0,%eax
  801252:	e9 83 01 00 00       	jmp    8013da <sfork+0x1e3>
		return 0;
	}
	else{//父环境中,注意：这里需要设置父环境的缺页异常栈，还需要设置子环境的缺页异常栈，
	//父子环境的页异常栈不共享？具体原因还得思考
		env = &envs[ENVX(sys_getenvid())];
  801257:	e8 2d fe ff ff       	call   801089 <sys_getenvid>
  80125c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801261:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801264:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801269:	a3 20 50 80 00       	mov    %eax,0x805020
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
  80126e:	c7 04 24 e2 13 80 00 	movl   $0x8013e2,(%esp)
  801275:	e8 92 0e 00 00       	call   80210c <set_pgfault_handler>
  80127a:	be 00 00 00 00       	mov    $0x0,%esi
  80127f:	bf 00 00 00 00       	mov    $0x0,%edi
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
		{
			addr=i*PGSIZE;
			pde =(pde_t*) &vpd[VPD(addr)];
  801284:	89 f8                	mov    %edi,%eax
  801286:	c1 e8 16             	shr    $0x16,%eax
  801289:	c1 e0 02             	shl    $0x2,%eax
			if(*pde&PTE_P)//这里只处理有物理页面映射的页表项
  80128c:	f6 80 00 d0 7b ef 01 	testb  $0x1,-0x10843000(%eax)
  801293:	0f 84 dc 00 00 00    	je     801375 <sfork+0x17e>
			{
				pte=(pte_t*)&vpt[VPN(addr)];
			}
			else    continue;
			if((i==(unsigned)VPN(USTACKTOP-PGSIZE))||(i==(unsigned)VPN(PFTEMP)))
  801299:	81 fe fd eb 0e 00    	cmp    $0xeebfd,%esi
  80129f:	74 08                	je     8012a9 <sfork+0xb2>
  8012a1:	81 fe ff 07 00 00    	cmp    $0x7ff,%esi
  8012a7:	75 17                	jne    8012c0 <sfork+0xc9>
								//特殊处理，用户层普通栈
			{	
				if((r=duppage(envid,i))<0)
  8012a9:	89 f2                	mov    %esi,%edx
  8012ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ae:	e8 6d fe ff ff       	call   801120 <duppage>
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	0f 89 ba 00 00 00    	jns    801375 <sfork+0x17e>
  8012bb:	e9 1a 01 00 00       	jmp    8013da <sfork+0x1e3>
	// LAB 4: Your code here.
	pde_t *pde;
	pte_t *pte;
	void *addr=(void*)(pn*PGSIZE);
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
  8012c0:	f6 80 00 d0 7b ef 01 	testb  $0x1,-0x10843000(%eax)
  8012c7:	74 11                	je     8012da <sfork+0xe3>
	{
		pte=(pte_t*)&vpt[VPN(addr)];
  8012c9:	89 f8                	mov    %edi,%eax
  8012cb:	c1 e8 0c             	shr    $0xc,%eax
	}
	else    panic("page table for pn page is not exist");
	if(*pte&PTE_W)
  8012ce:	f6 04 85 00 00 40 ef 	testb  $0x2,-0x10c00000(,%eax,4)
  8012d5:	02 
  8012d6:	75 1e                	jne    8012f6 <sfork+0xff>
  8012d8:	eb 74                	jmp    80134e <sfork+0x157>
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else    panic("page table for pn page is not exist");
  8012da:	c7 44 24 08 cc 27 80 	movl   $0x8027cc,0x8(%esp)
  8012e1:	00 
  8012e2:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
  8012e9:	00 
  8012ea:	c7 04 24 8a 28 80 00 	movl   $0x80288a,(%esp)
  8012f1:	e8 c6 ee ff ff       	call   8001bc <_panic>
	if(*pte&PTE_W)
	{
		//cprintf("sduppage:addr=%x\n",addr);
		if((r=sys_page_map(0,addr,envid,addr,PTE_W|PTE_U))<0)
  8012f6:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
  8012fd:	00 
  8012fe:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801302:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801305:	89 44 24 08          	mov    %eax,0x8(%esp)
  801309:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80130d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801314:	e8 7f fc ff ff       	call   800f98 <sys_page_map>
  801319:	85 c0                	test   %eax,%eax
  80131b:	0f 88 b9 00 00 00    	js     8013da <sfork+0x1e3>
			return r;
		if((r=sys_page_map(0,addr,0,addr,PTE_W|PTE_U))<0)//映射的时候注意env的id
  801321:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
  801328:	00 
  801329:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80132d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801334:	00 
  801335:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801339:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801340:	e8 53 fc ff ff       	call   800f98 <sys_page_map>
  801345:	85 c0                	test   %eax,%eax
  801347:	79 2c                	jns    801375 <sfork+0x17e>
  801349:	e9 8c 00 00 00       	jmp    8013da <sfork+0x1e3>
                        return r;
	}
	else{	
		if((r=sys_page_map(0,addr,envid,addr,PTE_U|PTE_P))<0)
  80134e:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801355:	00 
  801356:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80135a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801361:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801365:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80136c:	e8 27 fc ff ff       	call   800f98 <sys_page_map>
  801371:	85 c0                	test   %eax,%eax
  801373:	78 65                	js     8013da <sfork+0x1e3>
	}
	else{//父环境中,注意：这里需要设置父环境的缺页异常栈，还需要设置子环境的缺页异常栈，
	//父子环境的页异常栈不共享？具体原因还得思考
		env = &envs[ENVX(sys_getenvid())];
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
  801375:	83 c6 01             	add    $0x1,%esi
  801378:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80137e:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  801384:	0f 85 fa fe ff ff    	jne    801284 <sfork+0x8d>
				continue;
			}
			if((r=sduppage(envid,i))<0)
				return r;
		}
		if((r=sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  80138a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801391:	00 
  801392:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801399:	ee 
  80139a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139d:	89 04 24             	mov    %eax,(%esp)
  8013a0:	e8 51 fc ff ff       	call   800ff6 <sys_page_alloc>
  8013a5:	85 c0                	test   %eax,%eax
  8013a7:	78 31                	js     8013da <sfork+0x1e3>
                        return r;//设置子环境的缺页异常栈
		if((r=sys_env_set_pgfault_upcall(envid,(void*)_pgfault_upcall))<0)
  8013a9:	c7 44 24 04 90 21 80 	movl   $0x802190,0x4(%esp)
  8013b0:	00 
  8013b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b4:	89 04 24             	mov    %eax,(%esp)
  8013b7:	e8 64 fa ff ff       	call   800e20 <sys_env_set_pgfault_upcall>
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	78 1a                	js     8013da <sfork+0x1e3>
			return r;//设置子环境的缺页异常处理入口点
		if((r=sys_env_set_status(envid,ENV_RUNNABLE))<0)
  8013c0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8013c7:	00 
  8013c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013cb:	89 04 24             	mov    %eax,(%esp)
  8013ce:	e8 09 fb ff ff       	call   800edc <sys_env_set_status>
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	78 03                	js     8013da <sfork+0x1e3>
  8013d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
			return r;//设置子环境的状态为可运行
		return envid;
	}
	//panic("sfork not implemented");
	//return -E_INVAL;
}
  8013da:	83 c4 1c             	add    $0x1c,%esp
  8013dd:	5b                   	pop    %ebx
  8013de:	5e                   	pop    %esi
  8013df:	5f                   	pop    %edi
  8013e0:	5d                   	pop    %ebp
  8013e1:	c3                   	ret    

008013e2 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8013e2:	55                   	push   %ebp
  8013e3:	89 e5                	mov    %esp,%ebp
  8013e5:	56                   	push   %esi
  8013e6:	53                   	push   %ebx
  8013e7:	83 ec 20             	sub    $0x20,%esp
  8013ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  8013ed:	8b 71 04             	mov    0x4(%ecx),%esi

	// LAB 4: Your code here.
	pde_t *pde;
	pte_t *pte;
	uint32_t *va,*srcva,*dstva;
	pde =(pde_t*) &vpd[VPD(addr)];
  8013f0:	8b 19                	mov    (%ecx),%ebx
  8013f2:	89 d8                	mov    %ebx,%eax
  8013f4:	c1 e8 16             	shr    $0x16,%eax
  8013f7:	c1 e0 02             	shl    $0x2,%eax
  8013fa:	8d 90 00 d0 7b ef    	lea    -0x10843000(%eax),%edx
	if(*pde&PTE_P)
  801400:	f6 80 00 d0 7b ef 01 	testb  $0x1,-0x10843000(%eax)
  801407:	74 16                	je     80141f <pgfault+0x3d>
	{
		pte=(pte_t*)&vpt[VPN(addr)];
  801409:	89 d8                	mov    %ebx,%eax
  80140b:	c1 e8 0c             	shr    $0xc,%eax
  80140e:	8d 04 85 00 00 40 ef 	lea    -0x10c00000(,%eax,4),%eax
	else{
		cprintf("addr=%x err=%x *pde=%x utf_eip=%x\n",(uint32_t)addr,err,*pde,utf->utf_eip);	
		panic("page table for fault va is not exist");
	}
	//cprintf("addr=%x err=%x *pte=%x utf_eip=%x\n",(uint32_t)addr,err,*pte,utf->utf_eip);
	if(!(err&FEC_WR)||!(*pte&PTE_COW))
  801415:	f7 c6 02 00 00 00    	test   $0x2,%esi
  80141b:	75 3f                	jne    80145c <pgfault+0x7a>
  80141d:	eb 43                	jmp    801462 <pgfault+0x80>
	if(*pde&PTE_P)
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else{
		cprintf("addr=%x err=%x *pde=%x utf_eip=%x\n",(uint32_t)addr,err,*pde,utf->utf_eip);	
  80141f:	8b 41 28             	mov    0x28(%ecx),%eax
  801422:	8b 12                	mov    (%edx),%edx
  801424:	89 44 24 10          	mov    %eax,0x10(%esp)
  801428:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80142c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801430:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801434:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  80143b:	e8 49 ee ff ff       	call   800289 <cprintf>
		panic("page table for fault va is not exist");
  801440:	c7 44 24 08 14 28 80 	movl   $0x802814,0x8(%esp)
  801447:	00 
  801448:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80144f:	00 
  801450:	c7 04 24 8a 28 80 00 	movl   $0x80288a,(%esp)
  801457:	e8 60 ed ff ff       	call   8001bc <_panic>
	}
	//cprintf("addr=%x err=%x *pte=%x utf_eip=%x\n",(uint32_t)addr,err,*pte,utf->utf_eip);
	if(!(err&FEC_WR)||!(*pte&PTE_COW))
  80145c:	f6 40 01 08          	testb  $0x8,0x1(%eax)
  801460:	75 49                	jne    8014ab <pgfault+0xc9>
	{	
		cprintf("envid=%x addr=%x err=%x *pte=%x utf_eip=%x\n",env->env_id,(uint32_t)addr,err,*pte,utf->utf_eip);
  801462:	8b 51 28             	mov    0x28(%ecx),%edx
  801465:	8b 08                	mov    (%eax),%ecx
  801467:	a1 20 50 80 00       	mov    0x805020,%eax
  80146c:	8b 40 4c             	mov    0x4c(%eax),%eax
  80146f:	89 54 24 14          	mov    %edx,0x14(%esp)
  801473:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801477:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80147b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80147f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801483:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  80148a:	e8 fa ed ff ff       	call   800289 <cprintf>
		panic("faulting access is illegle");
  80148f:	c7 44 24 08 a5 28 80 	movl   $0x8028a5,0x8(%esp)
  801496:	00 
  801497:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80149e:	00 
  80149f:	c7 04 24 8a 28 80 00 	movl   $0x80288a,(%esp)
  8014a6:	e8 11 ed ff ff       	call   8001bc <_panic>
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	//cprintf("pgfault:env_id=%x\n",env->env_id);
	if((r=sys_page_alloc(0,PFTEMP,PTE_W|PTE_U|PTE_P))<0)
  8014ab:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8014b2:	00 
  8014b3:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014ba:	00 
  8014bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014c2:	e8 2f fb ff ff       	call   800ff6 <sys_page_alloc>
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	79 20                	jns    8014eb <pgfault+0x109>
			//输入id=0表示当前环境id(curenv->env_id),这个时候不能用env->env-id,子环境中env的修改会缺页
		panic("alloc a page for PFTEMP failed:%e",r);
  8014cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014cf:	c7 44 24 08 68 28 80 	movl   $0x802868,0x8(%esp)
  8014d6:	00 
  8014d7:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8014de:	00 
  8014df:	c7 04 24 8a 28 80 00 	movl   $0x80288a,(%esp)
  8014e6:	e8 d1 ec ff ff       	call   8001bc <_panic>
	//cprintf("PFTEMP=%x add=%x\n",PFTEMP,(uint32_t)addr&0xfffff000);
	srcva = (uint32_t*)((uint32_t)addr&0xfffff000);
  8014eb:	89 de                	mov    %ebx,%esi
  8014ed:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  8014f3:	89 f2                	mov    %esi,%edx
	dstva = (uint32_t*)PFTEMP;
	//strncpy((char*)PFTEMP,(char*)((uint32_t)addr&0xfffff000),PGSIZE);
	for(;srcva<(uint32_t*)(ROUNDUP(addr,PGSIZE));srcva++)//数据拷贝要注意，用strncpy出错了，原因还得分析
  8014f5:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  8014fb:	89 c3                	mov    %eax,%ebx
  8014fd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801503:	39 de                	cmp    %ebx,%esi
  801505:	73 13                	jae    80151a <pgfault+0x138>
  801507:	b9 00 f0 7f 00       	mov    $0x7ff000,%ecx
	{
		*dstva=*srcva;
  80150c:	8b 02                	mov    (%edx),%eax
  80150e:	89 01                	mov    %eax,(%ecx)
		dstva++;
  801510:	83 c1 04             	add    $0x4,%ecx
		panic("alloc a page for PFTEMP failed:%e",r);
	//cprintf("PFTEMP=%x add=%x\n",PFTEMP,(uint32_t)addr&0xfffff000);
	srcva = (uint32_t*)((uint32_t)addr&0xfffff000);
	dstva = (uint32_t*)PFTEMP;
	//strncpy((char*)PFTEMP,(char*)((uint32_t)addr&0xfffff000),PGSIZE);
	for(;srcva<(uint32_t*)(ROUNDUP(addr,PGSIZE));srcva++)//数据拷贝要注意，用strncpy出错了，原因还得分析
  801513:	83 c2 04             	add    $0x4,%edx
  801516:	39 da                	cmp    %ebx,%edx
  801518:	72 f2                	jb     80150c <pgfault+0x12a>
	{
		*dstva=*srcva;
		dstva++;
	}
	if((r=sys_page_map(0,(void*)PFTEMP,0,(void*)((uint32_t)addr&0xfffff000),PTE_W|PTE_U|PTE_P))<0)
  80151a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801521:	00 
  801522:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801526:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80152d:	00 
  80152e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801535:	00 
  801536:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80153d:	e8 56 fa ff ff       	call   800f98 <sys_page_map>
  801542:	85 c0                	test   %eax,%eax
  801544:	79 1c                	jns    801562 <pgfault+0x180>
			//输入id=0表示当前环境id(curenv->env_id),这个时候不能用env->env-id,子环境中env的修改会缺页
		panic("page mapping failed");
  801546:	c7 44 24 08 c0 28 80 	movl   $0x8028c0,0x8(%esp)
  80154d:	00 
  80154e:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801555:	00 
  801556:	c7 04 24 8a 28 80 00 	movl   $0x80288a,(%esp)
  80155d:	e8 5a ec ff ff       	call   8001bc <_panic>
	//panic("pgfault not implemented");
}
  801562:	83 c4 20             	add    $0x20,%esp
  801565:	5b                   	pop    %ebx
  801566:	5e                   	pop    %esi
  801567:	5d                   	pop    %ebp
  801568:	c3                   	ret    

00801569 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801569:	55                   	push   %ebp
  80156a:	89 e5                	mov    %esp,%ebp
  80156c:	56                   	push   %esi
  80156d:	53                   	push   %ebx
  80156e:	83 ec 10             	sub    $0x10,%esp
  801571:	ba 07 00 00 00       	mov    $0x7,%edx
  801576:	89 d0                	mov    %edx,%eax
  801578:	cd 30                	int    $0x30
  80157a:	89 c6                	mov    %eax,%esi
	pte_t *pte;
	unsigned i;
	uint32_t addr;
	envid_t envid;
	envid = sys_exofork();//创建子环境
	if(envid < 0)
  80157c:	85 c0                	test   %eax,%eax
  80157e:	79 20                	jns    8015a0 <fork+0x37>
		panic("sys_exofork: %e", envid);
  801580:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801584:	c7 44 24 08 95 28 80 	movl   $0x802895,0x8(%esp)
  80158b:	00 
  80158c:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  801593:	00 
  801594:	c7 04 24 8a 28 80 00 	movl   $0x80288a,(%esp)
  80159b:	e8 1c ec ff ff       	call   8001bc <_panic>
	if(envid==0)//子环境中
  8015a0:	85 c0                	test   %eax,%eax
  8015a2:	75 21                	jne    8015c5 <fork+0x5c>
	{
		env = &envs[ENVX(sys_getenvid())];
  8015a4:	e8 e0 fa ff ff       	call   801089 <sys_getenvid>
  8015a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8015ae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8015b1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8015b6:	a3 20 50 80 00       	mov    %eax,0x805020
  8015bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8015c0:	e9 9e 00 00 00       	jmp    801663 <fork+0xfa>
		return 0;
	}
	else{//父环境中
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
  8015c5:	c7 04 24 e2 13 80 00 	movl   $0x8013e2,(%esp)
  8015cc:	e8 3b 0b 00 00       	call   80210c <set_pgfault_handler>
  8015d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015d6:	eb 08                	jmp    8015e0 <fork+0x77>
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
		{
			if(i==(unsigned)VPN(UXSTACKTOP-PGSIZE))//特殊处理，用户层缺页异常栈
  8015d8:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  8015de:	74 3d                	je     80161d <fork+0xb4>
				continue;
  8015e0:	89 da                	mov    %ebx,%edx
  8015e2:	c1 e2 0c             	shl    $0xc,%edx
			addr=i*PGSIZE;
			pde =(pde_t*) &vpd[VPD(addr)];
  8015e5:	89 d0                	mov    %edx,%eax
  8015e7:	c1 e8 16             	shr    $0x16,%eax
			if(*pde&PTE_P)//这里只处理有物理页面映射的页表项
  8015ea:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  8015f1:	01 
  8015f2:	74 1e                	je     801612 <fork+0xa9>
			{
				pte=(pte_t*)&vpt[VPN(addr)];
  8015f4:	89 d0                	mov    %edx,%eax
  8015f6:	c1 e8 0a             	shr    $0xa,%eax
			}
			else    continue;
			if((*pte&PTE_W)||(*pte&PTE_COW))
  8015f9:	f7 80 00 00 40 ef 02 	testl  $0x802,-0x10c00000(%eax)
  801600:	08 00 00 
  801603:	74 0d                	je     801612 <fork+0xa9>
			{
				if((r=duppage(envid,i))<0)
  801605:	89 da                	mov    %ebx,%edx
  801607:	89 f0                	mov    %esi,%eax
  801609:	e8 12 fb ff ff       	call   801120 <duppage>
  80160e:	85 c0                	test   %eax,%eax
  801610:	78 51                	js     801663 <fork+0xfa>
		env = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	else{//父环境中
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
  801612:	83 c3 01             	add    $0x1,%ebx
  801615:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  80161b:	75 bb                	jne    8015d8 <fork+0x6f>
			{
				if((r=duppage(envid,i))<0)
					return r;
			}
		}
		if((r=sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  80161d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801624:	00 
  801625:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80162c:	ee 
  80162d:	89 34 24             	mov    %esi,(%esp)
  801630:	e8 c1 f9 ff ff       	call   800ff6 <sys_page_alloc>
  801635:	85 c0                	test   %eax,%eax
  801637:	78 2a                	js     801663 <fork+0xfa>
			return r;//设置子环境的缺页异常栈
		if((r=sys_env_set_pgfault_upcall(envid,(void*)_pgfault_upcall))<0)
  801639:	c7 44 24 04 90 21 80 	movl   $0x802190,0x4(%esp)
  801640:	00 
  801641:	89 34 24             	mov    %esi,(%esp)
  801644:	e8 d7 f7 ff ff       	call   800e20 <sys_env_set_pgfault_upcall>
  801649:	85 c0                	test   %eax,%eax
  80164b:	78 16                	js     801663 <fork+0xfa>
			return r;//设置子环境的缺页异常处理入口点
		if((r=sys_env_set_status(envid,ENV_RUNNABLE))<0)
  80164d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801654:	00 
  801655:	89 34 24             	mov    %esi,(%esp)
  801658:	e8 7f f8 ff ff       	call   800edc <sys_env_set_status>
  80165d:	85 c0                	test   %eax,%eax
  80165f:	78 02                	js     801663 <fork+0xfa>
  801661:	89 f0                	mov    %esi,%eax
			return r;//设置子环境的状态为可运行
		return envid;
	}
	//panic("fork not implemented");
}
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	5b                   	pop    %ebx
  801667:	5e                   	pop    %esi
  801668:	5d                   	pop    %ebp
  801669:	c3                   	ret    
  80166a:	00 00                	add    %al,(%eax)
  80166c:	00 00                	add    %al,(%eax)
	...

00801670 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
  801673:	57                   	push   %edi
  801674:	56                   	push   %esi
  801675:	53                   	push   %ebx
  801676:	83 ec 1c             	sub    $0x1c,%esp
  801679:	8b 75 08             	mov    0x8(%ebp),%esi
  80167c:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  80167f:	e8 05 fa ff ff       	call   801089 <sys_getenvid>
  801684:	25 ff 03 00 00       	and    $0x3ff,%eax
  801689:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80168c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801691:	a3 20 50 80 00       	mov    %eax,0x805020
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  801696:	e8 ee f9 ff ff       	call   801089 <sys_getenvid>
  80169b:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016a0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8016a3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8016a8:	a3 20 50 80 00       	mov    %eax,0x805020
		if(env->env_id==to_env){
  8016ad:	8b 40 4c             	mov    0x4c(%eax),%eax
  8016b0:	39 f0                	cmp    %esi,%eax
  8016b2:	75 0e                	jne    8016c2 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  8016b4:	c7 04 24 d4 28 80 00 	movl   $0x8028d4,(%esp)
  8016bb:	e8 c9 eb ff ff       	call   800289 <cprintf>
  8016c0:	eb 5a                	jmp    80171c <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  8016c2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8016c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8016c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d4:	89 34 24             	mov    %esi,(%esp)
  8016d7:	e8 0c f7 ff ff       	call   800de8 <sys_ipc_try_send>
  8016dc:	89 c3                	mov    %eax,%ebx
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	79 25                	jns    801707 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  8016e2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8016e5:	74 2b                	je     801712 <ipc_send+0xa2>
				panic("send error:%e",r);
  8016e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016eb:	c7 44 24 08 f0 28 80 	movl   $0x8028f0,0x8(%esp)
  8016f2:	00 
  8016f3:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8016fa:	00 
  8016fb:	c7 04 24 fe 28 80 00 	movl   $0x8028fe,(%esp)
  801702:	e8 b5 ea ff ff       	call   8001bc <_panic>
		}
			sys_yield();
  801707:	e8 49 f9 ff ff       	call   801055 <sys_yield>
		
	}while(r!=0);
  80170c:	85 db                	test   %ebx,%ebx
  80170e:	75 86                	jne    801696 <ipc_send+0x26>
  801710:	eb 0a                	jmp    80171c <ipc_send+0xac>
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
		{	
			if(r!=-E_IPC_NOT_RECV)
				panic("send error:%e",r);
		}
			sys_yield();
  801712:	e8 3e f9 ff ff       	call   801055 <sys_yield>
  801717:	e9 7a ff ff ff       	jmp    801696 <ipc_send+0x26>
		
	}while(r!=0);
	return;
	//panic("ipc_send not implemented");
}
  80171c:	83 c4 1c             	add    $0x1c,%esp
  80171f:	5b                   	pop    %ebx
  801720:	5e                   	pop    %esi
  801721:	5f                   	pop    %edi
  801722:	5d                   	pop    %ebp
  801723:	c3                   	ret    

00801724 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	57                   	push   %edi
  801728:	56                   	push   %esi
  801729:	53                   	push   %ebx
  80172a:	83 ec 0c             	sub    $0xc,%esp
  80172d:	8b 75 08             	mov    0x8(%ebp),%esi
  801730:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	void *dstva=NULL;
	if(pg)
		dstva=pg;
	env = &envs[ENVX(sys_getenvid())];
  801733:	e8 51 f9 ff ff       	call   801089 <sys_getenvid>
  801738:	25 ff 03 00 00       	and    $0x3ff,%eax
  80173d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801740:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801745:	a3 20 50 80 00       	mov    %eax,0x805020
	if(from_env_store&&(env->env_id==*from_env_store))
  80174a:	85 f6                	test   %esi,%esi
  80174c:	74 29                	je     801777 <ipc_recv+0x53>
  80174e:	8b 40 4c             	mov    0x4c(%eax),%eax
  801751:	3b 06                	cmp    (%esi),%eax
  801753:	75 22                	jne    801777 <ipc_recv+0x53>
	{
		*from_env_store=0;
  801755:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  80175b:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("send:the reciver is sender\n");
  801761:	c7 04 24 d4 28 80 00 	movl   $0x8028d4,(%esp)
  801768:	e8 1c eb ff ff       	call   800289 <cprintf>
  80176d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801772:	e9 8a 00 00 00       	jmp    801801 <ipc_recv+0xdd>
		return 0;
	}
	env = &envs[ENVX(sys_getenvid())];
  801777:	e8 0d f9 ff ff       	call   801089 <sys_getenvid>
  80177c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801781:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801784:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801789:	a3 20 50 80 00       	mov    %eax,0x805020
	if((r=sys_ipc_recv(dstva))<0)
  80178e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801791:	89 04 24             	mov    %eax,(%esp)
  801794:	e8 f2 f5 ff ff       	call   800d8b <sys_ipc_recv>
  801799:	89 c3                	mov    %eax,%ebx
  80179b:	85 c0                	test   %eax,%eax
  80179d:	79 1a                	jns    8017b9 <ipc_recv+0x95>
	{
		*from_env_store=0;
  80179f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  8017a5:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("reciver failed\n");
  8017ab:	c7 04 24 08 29 80 00 	movl   $0x802908,(%esp)
  8017b2:	e8 d2 ea ff ff       	call   800289 <cprintf>
  8017b7:	eb 48                	jmp    801801 <ipc_recv+0xdd>
		return r;
	}
	else{//接收成功
		env = &envs[ENVX(sys_getenvid())];
  8017b9:	e8 cb f8 ff ff       	call   801089 <sys_getenvid>
  8017be:	25 ff 03 00 00       	and    $0x3ff,%eax
  8017c3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8017c6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8017cb:	a3 20 50 80 00       	mov    %eax,0x805020
		if(from_env_store)
  8017d0:	85 f6                	test   %esi,%esi
  8017d2:	74 05                	je     8017d9 <ipc_recv+0xb5>
			*from_env_store=env->env_ipc_from;	
  8017d4:	8b 40 74             	mov    0x74(%eax),%eax
  8017d7:	89 06                	mov    %eax,(%esi)
		if(perm_store)
  8017d9:	85 ff                	test   %edi,%edi
  8017db:	74 0a                	je     8017e7 <ipc_recv+0xc3>
			*perm_store=env->env_ipc_perm;
  8017dd:	a1 20 50 80 00       	mov    0x805020,%eax
  8017e2:	8b 40 78             	mov    0x78(%eax),%eax
  8017e5:	89 07                	mov    %eax,(%edi)
		env = &envs[ENVX(sys_getenvid())];
  8017e7:	e8 9d f8 ff ff       	call   801089 <sys_getenvid>
  8017ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8017f1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8017f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8017f9:	a3 20 50 80 00       	mov    %eax,0x805020
		return env->env_ipc_value;
  8017fe:	8b 58 70             	mov    0x70(%eax),%ebx
	}
	//panic("ipc_recv not implemented");
	return 0;
}
  801801:	89 d8                	mov    %ebx,%eax
  801803:	83 c4 0c             	add    $0xc,%esp
  801806:	5b                   	pop    %ebx
  801807:	5e                   	pop    %esi
  801808:	5f                   	pop    %edi
  801809:	5d                   	pop    %ebp
  80180a:	c3                   	ret    
  80180b:	00 00                	add    %al,(%eax)
  80180d:	00 00                	add    %al,(%eax)
	...

00801810 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	8b 45 08             	mov    0x8(%ebp),%eax
  801816:	05 00 00 00 30       	add    $0x30000000,%eax
  80181b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80181e:	5d                   	pop    %ebp
  80181f:	c3                   	ret    

00801820 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801826:	8b 45 08             	mov    0x8(%ebp),%eax
  801829:	89 04 24             	mov    %eax,(%esp)
  80182c:	e8 df ff ff ff       	call   801810 <fd2num>
  801831:	c1 e0 0c             	shl    $0xc,%eax
  801834:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801839:	c9                   	leave  
  80183a:	c3                   	ret    

0080183b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80183b:	55                   	push   %ebp
  80183c:	89 e5                	mov    %esp,%ebp
  80183e:	53                   	push   %ebx
  80183f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801842:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801847:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801849:	89 d0                	mov    %edx,%eax
  80184b:	c1 e8 16             	shr    $0x16,%eax
  80184e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801855:	a8 01                	test   $0x1,%al
  801857:	74 10                	je     801869 <fd_alloc+0x2e>
  801859:	89 d0                	mov    %edx,%eax
  80185b:	c1 e8 0c             	shr    $0xc,%eax
  80185e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801865:	a8 01                	test   $0x1,%al
  801867:	75 09                	jne    801872 <fd_alloc+0x37>
			*fd_store = fd;
  801869:	89 0b                	mov    %ecx,(%ebx)
  80186b:	b8 00 00 00 00       	mov    $0x0,%eax
  801870:	eb 19                	jmp    80188b <fd_alloc+0x50>
			return 0;
  801872:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801878:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  80187e:	75 c7                	jne    801847 <fd_alloc+0xc>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801880:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801886:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  80188b:	5b                   	pop    %ebx
  80188c:	5d                   	pop    %ebp
  80188d:	c3                   	ret    

0080188e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801891:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  801895:	77 38                	ja     8018cf <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801897:	8b 45 08             	mov    0x8(%ebp),%eax
  80189a:	c1 e0 0c             	shl    $0xc,%eax
  80189d:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  8018a3:	89 d0                	mov    %edx,%eax
  8018a5:	c1 e8 16             	shr    $0x16,%eax
  8018a8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8018af:	a8 01                	test   $0x1,%al
  8018b1:	74 1c                	je     8018cf <fd_lookup+0x41>
  8018b3:	89 d0                	mov    %edx,%eax
  8018b5:	c1 e8 0c             	shr    $0xc,%eax
  8018b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018bf:	a8 01                	test   $0x1,%al
  8018c1:	74 0c                	je     8018cf <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8018c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c6:	89 10                	mov    %edx,(%eax)
  8018c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018cd:	eb 05                	jmp    8018d4 <fd_lookup+0x46>
	return 0;
  8018cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8018d4:	5d                   	pop    %ebp
  8018d5:	c3                   	ret    

008018d6 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8018d6:	55                   	push   %ebp
  8018d7:	89 e5                	mov    %esp,%ebp
  8018d9:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018dc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e6:	89 04 24             	mov    %eax,(%esp)
  8018e9:	e8 a0 ff ff ff       	call   80188e <fd_lookup>
  8018ee:	85 c0                	test   %eax,%eax
  8018f0:	78 0e                	js     801900 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8018f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f8:	89 50 04             	mov    %edx,0x4(%eax)
  8018fb:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801900:	c9                   	leave  
  801901:	c3                   	ret    

00801902 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	53                   	push   %ebx
  801906:	83 ec 14             	sub    $0x14,%esp
  801909:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80190c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80190f:	ba 04 50 80 00       	mov    $0x805004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801914:	b8 00 00 00 00       	mov    $0x0,%eax
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801919:	39 0d 04 50 80 00    	cmp    %ecx,0x805004
  80191f:	75 11                	jne    801932 <dev_lookup+0x30>
  801921:	eb 04                	jmp    801927 <dev_lookup+0x25>
  801923:	39 0a                	cmp    %ecx,(%edx)
  801925:	75 0b                	jne    801932 <dev_lookup+0x30>
			*dev = devtab[i];
  801927:	89 13                	mov    %edx,(%ebx)
  801929:	b8 00 00 00 00       	mov    $0x0,%eax
  80192e:	66 90                	xchg   %ax,%ax
  801930:	eb 35                	jmp    801967 <dev_lookup+0x65>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801932:	83 c0 01             	add    $0x1,%eax
  801935:	8b 14 85 94 29 80 00 	mov    0x802994(,%eax,4),%edx
  80193c:	85 d2                	test   %edx,%edx
  80193e:	75 e3                	jne    801923 <dev_lookup+0x21>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  801940:	a1 20 50 80 00       	mov    0x805020,%eax
  801945:	8b 40 4c             	mov    0x4c(%eax),%eax
  801948:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80194c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801950:	c7 04 24 18 29 80 00 	movl   $0x802918,(%esp)
  801957:	e8 2d e9 ff ff       	call   800289 <cprintf>
	*dev = 0;
  80195c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801962:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801967:	83 c4 14             	add    $0x14,%esp
  80196a:	5b                   	pop    %ebx
  80196b:	5d                   	pop    %ebp
  80196c:	c3                   	ret    

0080196d <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80196d:	55                   	push   %ebp
  80196e:	89 e5                	mov    %esp,%ebp
  801970:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801973:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801976:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197a:	8b 45 08             	mov    0x8(%ebp),%eax
  80197d:	89 04 24             	mov    %eax,(%esp)
  801980:	e8 09 ff ff ff       	call   80188e <fd_lookup>
  801985:	89 c2                	mov    %eax,%edx
  801987:	85 c0                	test   %eax,%eax
  801989:	78 5a                	js     8019e5 <fstat+0x78>
  80198b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80198e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801992:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801995:	8b 00                	mov    (%eax),%eax
  801997:	89 04 24             	mov    %eax,(%esp)
  80199a:	e8 63 ff ff ff       	call   801902 <dev_lookup>
  80199f:	89 c2                	mov    %eax,%edx
  8019a1:	85 c0                	test   %eax,%eax
  8019a3:	78 40                	js     8019e5 <fstat+0x78>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8019a5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  8019aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8019ad:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019b1:	74 32                	je     8019e5 <fstat+0x78>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b6:	c6 00 00             	movb   $0x0,(%eax)
	stat->st_size = 0;
  8019b9:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  8019c0:	00 00 00 
	stat->st_isdir = 0;
  8019c3:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
  8019ca:	00 00 00 
	stat->st_dev = dev;
  8019cd:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8019d0:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
	return (*dev->dev_stat)(fd, stat);
  8019d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019da:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8019dd:	89 04 24             	mov    %eax,(%esp)
  8019e0:	ff 52 14             	call   *0x14(%edx)
  8019e3:	89 c2                	mov    %eax,%edx
}
  8019e5:	89 d0                	mov    %edx,%eax
  8019e7:	c9                   	leave  
  8019e8:	c3                   	ret    

008019e9 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	53                   	push   %ebx
  8019ed:	83 ec 24             	sub    $0x24,%esp
  8019f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019fa:	89 1c 24             	mov    %ebx,(%esp)
  8019fd:	e8 8c fe ff ff       	call   80188e <fd_lookup>
  801a02:	85 c0                	test   %eax,%eax
  801a04:	78 61                	js     801a67 <ftruncate+0x7e>
  801a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a09:	8b 10                	mov    (%eax),%edx
  801a0b:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801a0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a12:	89 14 24             	mov    %edx,(%esp)
  801a15:	e8 e8 fe ff ff       	call   801902 <dev_lookup>
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	78 49                	js     801a67 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a1e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801a21:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801a25:	75 23                	jne    801a4a <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801a27:	a1 20 50 80 00       	mov    0x805020,%eax
  801a2c:	8b 40 4c             	mov    0x4c(%eax),%eax
  801a2f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a33:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a37:	c7 04 24 38 29 80 00 	movl   $0x802938,(%esp)
  801a3e:	e8 46 e8 ff ff       	call   800289 <cprintf>
  801a43:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a48:	eb 1d                	jmp    801a67 <ftruncate+0x7e>
			env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801a4a:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801a4d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a52:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801a56:	74 0f                	je     801a67 <ftruncate+0x7e>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801a58:	8b 42 18             	mov    0x18(%edx),%eax
  801a5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a5e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a62:	89 0c 24             	mov    %ecx,(%esp)
  801a65:	ff d0                	call   *%eax
}
  801a67:	83 c4 24             	add    $0x24,%esp
  801a6a:	5b                   	pop    %ebx
  801a6b:	5d                   	pop    %ebp
  801a6c:	c3                   	ret    

00801a6d <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	53                   	push   %ebx
  801a71:	83 ec 24             	sub    $0x24,%esp
  801a74:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a7e:	89 1c 24             	mov    %ebx,(%esp)
  801a81:	e8 08 fe ff ff       	call   80188e <fd_lookup>
  801a86:	85 c0                	test   %eax,%eax
  801a88:	78 68                	js     801af2 <write+0x85>
  801a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8d:	8b 10                	mov    (%eax),%edx
  801a8f:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801a92:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a96:	89 14 24             	mov    %edx,(%esp)
  801a99:	e8 64 fe ff ff       	call   801902 <dev_lookup>
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	78 50                	js     801af2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801aa2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801aa5:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801aa9:	75 23                	jne    801ace <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  801aab:	a1 20 50 80 00       	mov    0x805020,%eax
  801ab0:	8b 40 4c             	mov    0x4c(%eax),%eax
  801ab3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801abb:	c7 04 24 59 29 80 00 	movl   $0x802959,(%esp)
  801ac2:	e8 c2 e7 ff ff       	call   800289 <cprintf>
  801ac7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801acc:	eb 24                	jmp    801af2 <write+0x85>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801ace:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801ad1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801ad6:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  801ada:	74 16                	je     801af2 <write+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801adc:	8b 42 0c             	mov    0xc(%edx),%eax
  801adf:	8b 55 10             	mov    0x10(%ebp),%edx
  801ae2:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ae6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ae9:	89 54 24 04          	mov    %edx,0x4(%esp)
  801aed:	89 0c 24             	mov    %ecx,(%esp)
  801af0:	ff d0                	call   *%eax
}
  801af2:	83 c4 24             	add    $0x24,%esp
  801af5:	5b                   	pop    %ebx
  801af6:	5d                   	pop    %ebp
  801af7:	c3                   	ret    

00801af8 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801af8:	55                   	push   %ebp
  801af9:	89 e5                	mov    %esp,%ebp
  801afb:	53                   	push   %ebx
  801afc:	83 ec 24             	sub    $0x24,%esp
  801aff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b09:	89 1c 24             	mov    %ebx,(%esp)
  801b0c:	e8 7d fd ff ff       	call   80188e <fd_lookup>
  801b11:	85 c0                	test   %eax,%eax
  801b13:	78 6d                	js     801b82 <read+0x8a>
  801b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b18:	8b 10                	mov    (%eax),%edx
  801b1a:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801b1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b21:	89 14 24             	mov    %edx,(%esp)
  801b24:	e8 d9 fd ff ff       	call   801902 <dev_lookup>
  801b29:	85 c0                	test   %eax,%eax
  801b2b:	78 55                	js     801b82 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801b2d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801b30:	8b 41 08             	mov    0x8(%ecx),%eax
  801b33:	83 e0 03             	and    $0x3,%eax
  801b36:	83 f8 01             	cmp    $0x1,%eax
  801b39:	75 23                	jne    801b5e <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  801b3b:	a1 20 50 80 00       	mov    0x805020,%eax
  801b40:	8b 40 4c             	mov    0x4c(%eax),%eax
  801b43:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b4b:	c7 04 24 76 29 80 00 	movl   $0x802976,(%esp)
  801b52:	e8 32 e7 ff ff       	call   800289 <cprintf>
  801b57:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b5c:	eb 24                	jmp    801b82 <read+0x8a>
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801b5e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801b61:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b66:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  801b6a:	74 16                	je     801b82 <read+0x8a>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801b6c:	8b 42 08             	mov    0x8(%edx),%eax
  801b6f:	8b 55 10             	mov    0x10(%ebp),%edx
  801b72:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b76:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b79:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b7d:	89 0c 24             	mov    %ecx,(%esp)
  801b80:	ff d0                	call   *%eax
}
  801b82:	83 c4 24             	add    $0x24,%esp
  801b85:	5b                   	pop    %ebx
  801b86:	5d                   	pop    %ebp
  801b87:	c3                   	ret    

00801b88 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
  801b8b:	57                   	push   %edi
  801b8c:	56                   	push   %esi
  801b8d:	53                   	push   %ebx
  801b8e:	83 ec 0c             	sub    $0xc,%esp
  801b91:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b94:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b97:	b8 00 00 00 00       	mov    $0x0,%eax
  801b9c:	85 f6                	test   %esi,%esi
  801b9e:	74 36                	je     801bd6 <readn+0x4e>
  801ba0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ba5:	ba 00 00 00 00       	mov    $0x0,%edx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801baa:	89 f0                	mov    %esi,%eax
  801bac:	29 d0                	sub    %edx,%eax
  801bae:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bb2:	8d 04 17             	lea    (%edi,%edx,1),%eax
  801bb5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbc:	89 04 24             	mov    %eax,(%esp)
  801bbf:	e8 34 ff ff ff       	call   801af8 <read>
		if (m < 0)
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	78 0e                	js     801bd6 <readn+0x4e>
			return m;
		if (m == 0)
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	74 08                	je     801bd4 <readn+0x4c>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801bcc:	01 c3                	add    %eax,%ebx
  801bce:	89 da                	mov    %ebx,%edx
  801bd0:	39 f3                	cmp    %esi,%ebx
  801bd2:	72 d6                	jb     801baa <readn+0x22>
  801bd4:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801bd6:	83 c4 0c             	add    $0xc,%esp
  801bd9:	5b                   	pop    %ebx
  801bda:	5e                   	pop    %esi
  801bdb:	5f                   	pop    %edi
  801bdc:	5d                   	pop    %ebp
  801bdd:	c3                   	ret    

00801bde <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801bde:	55                   	push   %ebp
  801bdf:	89 e5                	mov    %esp,%ebp
  801be1:	83 ec 28             	sub    $0x28,%esp
  801be4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801be7:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801bea:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801bed:	89 34 24             	mov    %esi,(%esp)
  801bf0:	e8 1b fc ff ff       	call   801810 <fd2num>
  801bf5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801bf8:	89 54 24 04          	mov    %edx,0x4(%esp)
  801bfc:	89 04 24             	mov    %eax,(%esp)
  801bff:	e8 8a fc ff ff       	call   80188e <fd_lookup>
  801c04:	89 c3                	mov    %eax,%ebx
  801c06:	85 c0                	test   %eax,%eax
  801c08:	78 05                	js     801c0f <fd_close+0x31>
  801c0a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801c0d:	74 0d                	je     801c1c <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801c0f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801c13:	75 44                	jne    801c59 <fd_close+0x7b>
  801c15:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c1a:	eb 3d                	jmp    801c59 <fd_close+0x7b>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801c1c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c23:	8b 06                	mov    (%esi),%eax
  801c25:	89 04 24             	mov    %eax,(%esp)
  801c28:	e8 d5 fc ff ff       	call   801902 <dev_lookup>
  801c2d:	89 c3                	mov    %eax,%ebx
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	78 16                	js     801c49 <fd_close+0x6b>
		if (dev->dev_close)
  801c33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c36:	8b 40 10             	mov    0x10(%eax),%eax
  801c39:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c3e:	85 c0                	test   %eax,%eax
  801c40:	74 07                	je     801c49 <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  801c42:	89 34 24             	mov    %esi,(%esp)
  801c45:	ff d0                	call   *%eax
  801c47:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801c49:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c54:	e8 e1 f2 ff ff       	call   800f3a <sys_page_unmap>
	return r;
}
  801c59:	89 d8                	mov    %ebx,%eax
  801c5b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801c5e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c61:	89 ec                	mov    %ebp,%esp
  801c63:	5d                   	pop    %ebp
  801c64:	c3                   	ret    

00801c65 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801c65:	55                   	push   %ebp
  801c66:	89 e5                	mov    %esp,%ebp
  801c68:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c6b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801c6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c72:	8b 45 08             	mov    0x8(%ebp),%eax
  801c75:	89 04 24             	mov    %eax,(%esp)
  801c78:	e8 11 fc ff ff       	call   80188e <fd_lookup>
  801c7d:	85 c0                	test   %eax,%eax
  801c7f:	78 13                	js     801c94 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801c81:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801c88:	00 
  801c89:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801c8c:	89 04 24             	mov    %eax,(%esp)
  801c8f:	e8 4a ff ff ff       	call   801bde <fd_close>
}
  801c94:	c9                   	leave  
  801c95:	c3                   	ret    

00801c96 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801c96:	55                   	push   %ebp
  801c97:	89 e5                	mov    %esp,%ebp
  801c99:	83 ec 18             	sub    $0x18,%esp
  801c9c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c9f:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801ca2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ca9:	00 
  801caa:	8b 45 08             	mov    0x8(%ebp),%eax
  801cad:	89 04 24             	mov    %eax,(%esp)
  801cb0:	e8 6a 03 00 00       	call   80201f <open>
  801cb5:	89 c6                	mov    %eax,%esi
  801cb7:	85 c0                	test   %eax,%eax
  801cb9:	78 1b                	js     801cd6 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801cbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc2:	89 34 24             	mov    %esi,(%esp)
  801cc5:	e8 a3 fc ff ff       	call   80196d <fstat>
  801cca:	89 c3                	mov    %eax,%ebx
	close(fd);
  801ccc:	89 34 24             	mov    %esi,(%esp)
  801ccf:	e8 91 ff ff ff       	call   801c65 <close>
  801cd4:	89 de                	mov    %ebx,%esi
	return r;
}
  801cd6:	89 f0                	mov    %esi,%eax
  801cd8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801cdb:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801cde:	89 ec                	mov    %ebp,%esp
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    

00801ce2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801ce2:	55                   	push   %ebp
  801ce3:	89 e5                	mov    %esp,%ebp
  801ce5:	83 ec 38             	sub    $0x38,%esp
  801ce8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801ceb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801cee:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801cf1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801cf4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cf7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfe:	89 04 24             	mov    %eax,(%esp)
  801d01:	e8 88 fb ff ff       	call   80188e <fd_lookup>
  801d06:	89 c3                	mov    %eax,%ebx
  801d08:	85 c0                	test   %eax,%eax
  801d0a:	0f 88 e1 00 00 00    	js     801df1 <dup+0x10f>
		return r;
	close(newfdnum);
  801d10:	89 3c 24             	mov    %edi,(%esp)
  801d13:	e8 4d ff ff ff       	call   801c65 <close>

	newfd = INDEX2FD(newfdnum);
  801d18:	89 f8                	mov    %edi,%eax
  801d1a:	c1 e0 0c             	shl    $0xc,%eax
  801d1d:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  801d23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d26:	89 04 24             	mov    %eax,(%esp)
  801d29:	e8 f2 fa ff ff       	call   801820 <fd2data>
  801d2e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801d30:	89 34 24             	mov    %esi,(%esp)
  801d33:	e8 e8 fa ff ff       	call   801820 <fd2data>
  801d38:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  801d3b:	89 d8                	mov    %ebx,%eax
  801d3d:	c1 e8 16             	shr    $0x16,%eax
  801d40:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d47:	a8 01                	test   $0x1,%al
  801d49:	74 45                	je     801d90 <dup+0xae>
  801d4b:	89 da                	mov    %ebx,%edx
  801d4d:	c1 ea 0c             	shr    $0xc,%edx
  801d50:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801d57:	a8 01                	test   $0x1,%al
  801d59:	74 35                	je     801d90 <dup+0xae>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  801d5b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801d62:	25 07 0e 00 00       	and    $0xe07,%eax
  801d67:	89 44 24 10          	mov    %eax,0x10(%esp)
  801d6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d6e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d72:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d79:	00 
  801d7a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d7e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d85:	e8 0e f2 ff ff       	call   800f98 <sys_page_map>
  801d8a:	89 c3                	mov    %eax,%ebx
  801d8c:	85 c0                	test   %eax,%eax
  801d8e:	78 3e                	js     801dce <dup+0xec>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  801d90:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d93:	89 d0                	mov    %edx,%eax
  801d95:	c1 e8 0c             	shr    $0xc,%eax
  801d98:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d9f:	25 07 0e 00 00       	and    $0xe07,%eax
  801da4:	89 44 24 10          	mov    %eax,0x10(%esp)
  801da8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801dac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801db3:	00 
  801db4:	89 54 24 04          	mov    %edx,0x4(%esp)
  801db8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dbf:	e8 d4 f1 ff ff       	call   800f98 <sys_page_map>
  801dc4:	89 c3                	mov    %eax,%ebx
  801dc6:	85 c0                	test   %eax,%eax
  801dc8:	78 04                	js     801dce <dup+0xec>
		goto err;
  801dca:	89 fb                	mov    %edi,%ebx
  801dcc:	eb 23                	jmp    801df1 <dup+0x10f>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801dce:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dd2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dd9:	e8 5c f1 ff ff       	call   800f3a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801dde:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801de1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dec:	e8 49 f1 ff ff       	call   800f3a <sys_page_unmap>
	return r;
}
  801df1:	89 d8                	mov    %ebx,%eax
  801df3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801df6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801df9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801dfc:	89 ec                	mov    %ebp,%esp
  801dfe:	5d                   	pop    %ebp
  801dff:	c3                   	ret    

00801e00 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	53                   	push   %ebx
  801e04:	83 ec 04             	sub    $0x4,%esp
  801e07:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801e0c:	89 1c 24             	mov    %ebx,(%esp)
  801e0f:	e8 51 fe ff ff       	call   801c65 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801e14:	83 c3 01             	add    $0x1,%ebx
  801e17:	83 fb 20             	cmp    $0x20,%ebx
  801e1a:	75 f0                	jne    801e0c <close_all+0xc>
		close(i);
}
  801e1c:	83 c4 04             	add    $0x4,%esp
  801e1f:	5b                   	pop    %ebx
  801e20:	5d                   	pop    %ebp
  801e21:	c3                   	ret    
	...

00801e24 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801e24:	55                   	push   %ebp
  801e25:	89 e5                	mov    %esp,%ebp
  801e27:	53                   	push   %ebx
  801e28:	83 ec 14             	sub    $0x14,%esp
  801e2b:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801e2d:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801e33:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801e3a:	00 
  801e3b:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801e42:	00 
  801e43:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e47:	89 14 24             	mov    %edx,(%esp)
  801e4a:	e8 21 f8 ff ff       	call   801670 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801e4f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e56:	00 
  801e57:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e62:	e8 bd f8 ff ff       	call   801724 <ipc_recv>
}
  801e67:	83 c4 14             	add    $0x14,%esp
  801e6a:	5b                   	pop    %ebx
  801e6b:	5d                   	pop    %ebp
  801e6c:	c3                   	ret    

00801e6d <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801e6d:	55                   	push   %ebp
  801e6e:	89 e5                	mov    %esp,%ebp
  801e70:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801e73:	ba 00 00 00 00       	mov    $0x0,%edx
  801e78:	b8 08 00 00 00       	mov    $0x8,%eax
  801e7d:	e8 a2 ff ff ff       	call   801e24 <fsipc>
}
  801e82:	c9                   	leave  
  801e83:	c3                   	ret    

00801e84 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801e84:	55                   	push   %ebp
  801e85:	89 e5                	mov    %esp,%ebp
  801e87:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801e8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8d:	8b 40 0c             	mov    0xc(%eax),%eax
  801e90:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  801e95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e98:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801e9d:	ba 00 00 00 00       	mov    $0x0,%edx
  801ea2:	b8 02 00 00 00       	mov    $0x2,%eax
  801ea7:	e8 78 ff ff ff       	call   801e24 <fsipc>
}
  801eac:	c9                   	leave  
  801ead:	c3                   	ret    

00801eae <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801eae:	55                   	push   %ebp
  801eaf:	89 e5                	mov    %esp,%ebp
  801eb1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801eb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb7:	8b 40 0c             	mov    0xc(%eax),%eax
  801eba:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  801ebf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ec4:	b8 06 00 00 00       	mov    $0x6,%eax
  801ec9:	e8 56 ff ff ff       	call   801e24 <fsipc>
}
  801ece:	c9                   	leave  
  801ecf:	c3                   	ret    

00801ed0 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	53                   	push   %ebx
  801ed4:	83 ec 14             	sub    $0x14,%esp
  801ed7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801eda:	8b 45 08             	mov    0x8(%ebp),%eax
  801edd:	8b 40 0c             	mov    0xc(%eax),%eax
  801ee0:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ee5:	ba 00 00 00 00       	mov    $0x0,%edx
  801eea:	b8 05 00 00 00       	mov    $0x5,%eax
  801eef:	e8 30 ff ff ff       	call   801e24 <fsipc>
  801ef4:	85 c0                	test   %eax,%eax
  801ef6:	78 2b                	js     801f23 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ef8:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801eff:	00 
  801f00:	89 1c 24             	mov    %ebx,(%esp)
  801f03:	e8 e9 e9 ff ff       	call   8008f1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801f08:	a1 80 30 80 00       	mov    0x803080,%eax
  801f0d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801f13:	a1 84 30 80 00       	mov    0x803084,%eax
  801f18:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801f1e:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801f23:	83 c4 14             	add    $0x14,%esp
  801f26:	5b                   	pop    %ebx
  801f27:	5d                   	pop    %ebp
  801f28:	c3                   	ret    

00801f29 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801f29:	55                   	push   %ebp
  801f2a:	89 e5                	mov    %esp,%ebp
  801f2c:	83 ec 18             	sub    $0x18,%esp
  801f2f:	8b 55 10             	mov    0x10(%ebp),%edx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	ssize_t writesize;
	size_t bufsize;
	fsipcbuf.write.req_fileid=fd->fd_file.id;
  801f32:	8b 45 08             	mov    0x8(%ebp),%eax
  801f35:	8b 40 0c             	mov    0xc(%eax),%eax
  801f38:	a3 00 30 80 00       	mov    %eax,0x803000
	bufsize=sizeof(fsipcbuf.write.req_buf);
	if(n<bufsize)
  801f3d:	89 d0                	mov    %edx,%eax
  801f3f:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  801f45:	76 05                	jbe    801f4c <devfile_write+0x23>
  801f47:	b8 f8 0f 00 00       	mov    $0xff8,%eax
		bufsize=n;	
	fsipcbuf.write.req_n=n;
  801f4c:	89 15 04 30 80 00    	mov    %edx,0x803004
	memmove((void*)fsipcbuf.write.req_buf,buf,bufsize);
  801f52:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f56:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f59:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f5d:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801f64:	e8 8f eb ff ff       	call   800af8 <memmove>
	writesize=(ssize_t)fsipc(FSREQ_WRITE,NULL);
  801f69:	ba 00 00 00 00       	mov    $0x0,%edx
  801f6e:	b8 04 00 00 00       	mov    $0x4,%eax
  801f73:	e8 ac fe ff ff       	call   801e24 <fsipc>
	return writesize;
	//panic("devfile_write not implemented");
}
  801f78:	c9                   	leave  
  801f79:	c3                   	ret    

00801f7a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801f7a:	55                   	push   %ebp
  801f7b:	89 e5                	mov    %esp,%ebp
  801f7d:	53                   	push   %ebx
  801f7e:	83 ec 14             	sub    $0x14,%esp
	// system server.
	// LAB 5: Your code here
	ssize_t readsize;
	if(debug)
		cprintf("devfile_read:fileid=%x readsize=%x\n",fd->fd_file.id,n);
	fsipcbuf.read.req_fileid=fd->fd_file.id;
  801f81:	8b 45 08             	mov    0x8(%ebp),%eax
  801f84:	8b 40 0c             	mov    0xc(%eax),%eax
  801f87:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n=n;
  801f8c:	8b 45 10             	mov    0x10(%ebp),%eax
  801f8f:	a3 04 30 80 00       	mov    %eax,0x803004
	readsize=(ssize_t)fsipc(FSREQ_READ,&fsipcbuf);
  801f94:	ba 00 30 80 00       	mov    $0x803000,%edx
  801f99:	b8 03 00 00 00       	mov    $0x3,%eax
  801f9e:	e8 81 fe ff ff       	call   801e24 <fsipc>
  801fa3:	89 c3                	mov    %eax,%ebx
	cprintf("readsize=%d\n",readsize);
  801fa5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa9:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  801fb0:	e8 d4 e2 ff ff       	call   800289 <cprintf>
	if(debug)
		cprintf("devfile_read:buf1=%s\nbuf2=%s\n",(char*)&fsipcbuf,fsipcbuf.readRet.ret_buf);
	if(readsize>0)
  801fb5:	85 db                	test   %ebx,%ebx
  801fb7:	7e 17                	jle    801fd0 <devfile_read+0x56>
		memmove(buf,(void*)&fsipcbuf,(size_t)readsize);
  801fb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fbd:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801fc4:	00 
  801fc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc8:	89 04 24             	mov    %eax,(%esp)
  801fcb:	e8 28 eb ff ff       	call   800af8 <memmove>
	//cprintf("readsize=%d",readsize);
	return readsize;
	//panic("devfile_read not implemented");
}
  801fd0:	89 d8                	mov    %ebx,%eax
  801fd2:	83 c4 14             	add    $0x14,%esp
  801fd5:	5b                   	pop    %ebx
  801fd6:	5d                   	pop    %ebp
  801fd7:	c3                   	ret    

00801fd8 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801fd8:	55                   	push   %ebp
  801fd9:	89 e5                	mov    %esp,%ebp
  801fdb:	53                   	push   %ebx
  801fdc:	83 ec 14             	sub    $0x14,%esp
  801fdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801fe2:	89 1c 24             	mov    %ebx,(%esp)
  801fe5:	e8 b6 e8 ff ff       	call   8008a0 <strlen>
  801fea:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  801fef:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ff4:	7f 21                	jg     802017 <remove+0x3f>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801ff6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ffa:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  802001:	e8 eb e8 ff ff       	call   8008f1 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  802006:	ba 00 00 00 00       	mov    $0x0,%edx
  80200b:	b8 07 00 00 00       	mov    $0x7,%eax
  802010:	e8 0f fe ff ff       	call   801e24 <fsipc>
  802015:	89 c2                	mov    %eax,%edx
}
  802017:	89 d0                	mov    %edx,%eax
  802019:	83 c4 14             	add    $0x14,%esp
  80201c:	5b                   	pop    %ebx
  80201d:	5d                   	pop    %ebp
  80201e:	c3                   	ret    

0080201f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80201f:	55                   	push   %ebp
  802020:	89 e5                	mov    %esp,%ebp
  802022:	53                   	push   %ebx
  802023:	83 ec 24             	sub    $0x24,%esp
	// file descriptor.

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;
	if((r=fd_alloc(&fd))<0){
  802026:	8d 45 f8             	lea    -0x8(%ebp),%eax
  802029:	89 04 24             	mov    %eax,(%esp)
  80202c:	e8 0a f8 ff ff       	call   80183b <fd_alloc>
  802031:	89 c3                	mov    %eax,%ebx
  802033:	85 c0                	test   %eax,%eax
  802035:	79 18                	jns    80204f <open+0x30>
		fd_close(fd,0);
  802037:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80203e:	00 
  80203f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  802042:	89 04 24             	mov    %eax,(%esp)
  802045:	e8 94 fb ff ff       	call   801bde <fd_close>
  80204a:	e9 b4 00 00 00       	jmp    802103 <open+0xe4>
		return r;
	}
	cprintf("open:fd=%x\n",fd);
  80204f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  802052:	89 44 24 04          	mov    %eax,0x4(%esp)
  802056:	c7 04 24 a9 29 80 00 	movl   $0x8029a9,(%esp)
  80205d:	e8 27 e2 ff ff       	call   800289 <cprintf>
	strcpy(fsipcbuf.open.req_path,path);
  802062:	8b 45 08             	mov    0x8(%ebp),%eax
  802065:	89 44 24 04          	mov    %eax,0x4(%esp)
  802069:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  802070:	e8 7c e8 ff ff       	call   8008f1 <strcpy>
	fsipcbuf.open.req_omode=mode;
  802075:	8b 45 0c             	mov    0xc(%ebp),%eax
  802078:	a3 00 34 80 00       	mov    %eax,0x803400
	if((r=fsipc(FSREQ_OPEN,(void*)fd))<0)
  80207d:	8b 55 f8             	mov    -0x8(%ebp),%edx
  802080:	b8 01 00 00 00       	mov    $0x1,%eax
  802085:	e8 9a fd ff ff       	call   801e24 <fsipc>
  80208a:	89 c3                	mov    %eax,%ebx
  80208c:	85 c0                	test   %eax,%eax
  80208e:	79 15                	jns    8020a5 <open+0x86>
	{
		fd_close(fd,1);
  802090:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802097:	00 
  802098:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80209b:	89 04 24             	mov    %eax,(%esp)
  80209e:	e8 3b fb ff ff       	call   801bde <fd_close>
  8020a3:	eb 5e                	jmp    802103 <open+0xe4>
		return r;	
	}
	if((r=sys_page_map(0,(void*)fd,0,(void*)fd,PTE_P | PTE_W | PTE_U))<0)
  8020a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8020a8:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8020af:	00 
  8020b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020b4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020bb:	00 
  8020bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020c7:	e8 cc ee ff ff       	call   800f98 <sys_page_map>
  8020cc:	89 c3                	mov    %eax,%ebx
  8020ce:	85 c0                	test   %eax,%eax
  8020d0:	79 15                	jns    8020e7 <open+0xc8>
	{
		fd_close(fd,1);
  8020d2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8020d9:	00 
  8020da:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8020dd:	89 04 24             	mov    %eax,(%esp)
  8020e0:	e8 f9 fa ff ff       	call   801bde <fd_close>
  8020e5:	eb 1c                	jmp    802103 <open+0xe4>
		return r;
	}
	//INDEX2DATA(fd->fd_file.id);
	cprintf("fileid=%x\n",fd->fd_file.id);
  8020e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8020ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8020ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020f1:	c7 04 24 b5 29 80 00 	movl   $0x8029b5,(%esp)
  8020f8:	e8 8c e1 ff ff       	call   800289 <cprintf>
	return fd->fd_file.id;
  8020fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
  802100:	8b 58 0c             	mov    0xc(%eax),%ebx
	//panic("open not implemented");
}
  802103:	89 d8                	mov    %ebx,%eax
  802105:	83 c4 24             	add    $0x24,%esp
  802108:	5b                   	pop    %ebx
  802109:	5d                   	pop    %ebp
  80210a:	c3                   	ret    
	...

0080210c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80210c:	55                   	push   %ebp
  80210d:	89 e5                	mov    %esp,%ebp
  80210f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802112:	83 3d 28 50 80 00 00 	cmpl   $0x0,0x805028
  802119:	75 6a                	jne    802185 <set_pgfault_handler+0x79>
		// First time through!
		// LAB 4: Your code here.
		env=(struct Env*)&envs[ENVX(sys_getenvid())];
  80211b:	e8 69 ef ff ff       	call   801089 <sys_getenvid>
  802120:	25 ff 03 00 00       	and    $0x3ff,%eax
  802125:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802128:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80212d:	a3 20 50 80 00       	mov    %eax,0x805020
		if((r=sys_page_alloc(env->env_id,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  802132:	8b 40 4c             	mov    0x4c(%eax),%eax
  802135:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80213c:	00 
  80213d:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802144:	ee 
  802145:	89 04 24             	mov    %eax,(%esp)
  802148:	e8 a9 ee ff ff       	call   800ff6 <sys_page_alloc>
  80214d:	85 c0                	test   %eax,%eax
  80214f:	79 1c                	jns    80216d <set_pgfault_handler+0x61>
		{
			panic("Alloc a page for an exception stack failed");
  802151:	c7 44 24 08 c0 29 80 	movl   $0x8029c0,0x8(%esp)
  802158:	00 
  802159:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802160:	00 
  802161:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  802168:	e8 4f e0 ff ff       	call   8001bc <_panic>
		}
		sys_env_set_pgfault_upcall(env->env_id,(void*)_pgfault_upcall);
  80216d:	a1 20 50 80 00       	mov    0x805020,%eax
  802172:	8b 40 4c             	mov    0x4c(%eax),%eax
  802175:	c7 44 24 04 90 21 80 	movl   $0x802190,0x4(%esp)
  80217c:	00 
  80217d:	89 04 24             	mov    %eax,(%esp)
  802180:	e8 9b ec ff ff       	call   800e20 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802185:	8b 45 08             	mov    0x8(%ebp),%eax
  802188:	a3 28 50 80 00       	mov    %eax,0x805028
}
  80218d:	c9                   	leave  
  80218e:	c3                   	ret    
	...

00802190 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802190:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802191:	a1 28 50 80 00       	mov    0x805028,%eax
	call *%eax
  802196:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802198:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.这个有点难度，需要认真编写
	movl  0x28(%esp),%eax //把utf->utf_eip入栈
  80219b:	8b 44 24 28          	mov    0x28(%esp),%eax
	pushl %eax
  80219f:	50                   	push   %eax
	movl %esp,%eax
  8021a0:	89 e0                	mov    %esp,%eax
	movl 0x34(%eax),%esp  //切换到用户普通栈，压入utf_eip
  8021a2:	8b 60 34             	mov    0x34(%eax),%esp
	pushl (%eax)
  8021a5:	ff 30                	pushl  (%eax)
	movl %eax,%esp	     //切到用户异常栈
  8021a7:	89 c4                	mov    %eax,%esp
	subl $0x4,0x34(%esp) //将utf->utf_esp减去4,指向返回地址,后面不能算术操作，就在这算
  8021a9:	83 6c 24 34 04       	subl   $0x4,0x34(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0xc,%esp     //恢复通用寄存器
  8021ae:	83 c4 0c             	add    $0xc,%esp
	popal
  8021b1:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp  //恢复eflags
  8021b2:	83 c4 04             	add    $0x4,%esp
	popfl          //在用户态，该指令能否修改eflags?可以的
  8021b5:	9d                   	popf   
		       //执行完这个指令后，不能进行算术任何算术运算哦，否则eflags里面的值不对
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp     //切换到用户普通栈，用户从异常处理退出后，需要继续使用该栈
  8021b6:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8021b7:	c3                   	ret    
	...

008021c0 <__udivdi3>:
  8021c0:	55                   	push   %ebp
  8021c1:	89 e5                	mov    %esp,%ebp
  8021c3:	57                   	push   %edi
  8021c4:	56                   	push   %esi
  8021c5:	83 ec 18             	sub    $0x18,%esp
  8021c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8021cb:	8b 55 14             	mov    0x14(%ebp),%edx
  8021ce:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8021d4:	89 c1                	mov    %eax,%ecx
  8021d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d9:	85 d2                	test   %edx,%edx
  8021db:	89 d7                	mov    %edx,%edi
  8021dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8021e0:	75 1e                	jne    802200 <__udivdi3+0x40>
  8021e2:	39 f1                	cmp    %esi,%ecx
  8021e4:	0f 86 8d 00 00 00    	jbe    802277 <__udivdi3+0xb7>
  8021ea:	89 f2                	mov    %esi,%edx
  8021ec:	31 f6                	xor    %esi,%esi
  8021ee:	f7 f1                	div    %ecx
  8021f0:	89 c1                	mov    %eax,%ecx
  8021f2:	89 c8                	mov    %ecx,%eax
  8021f4:	89 f2                	mov    %esi,%edx
  8021f6:	83 c4 18             	add    $0x18,%esp
  8021f9:	5e                   	pop    %esi
  8021fa:	5f                   	pop    %edi
  8021fb:	5d                   	pop    %ebp
  8021fc:	c3                   	ret    
  8021fd:	8d 76 00             	lea    0x0(%esi),%esi
  802200:	39 f2                	cmp    %esi,%edx
  802202:	0f 87 a8 00 00 00    	ja     8022b0 <__udivdi3+0xf0>
  802208:	0f bd c2             	bsr    %edx,%eax
  80220b:	83 f0 1f             	xor    $0x1f,%eax
  80220e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802211:	0f 84 89 00 00 00    	je     8022a0 <__udivdi3+0xe0>
  802217:	b8 20 00 00 00       	mov    $0x20,%eax
  80221c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80221f:	2b 45 e8             	sub    -0x18(%ebp),%eax
  802222:	89 c1                	mov    %eax,%ecx
  802224:	d3 ea                	shr    %cl,%edx
  802226:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  80222a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80222d:	89 f8                	mov    %edi,%eax
  80222f:	8b 7d f4             	mov    -0xc(%ebp),%edi
  802232:	d3 e0                	shl    %cl,%eax
  802234:	09 c2                	or     %eax,%edx
  802236:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802239:	d3 e7                	shl    %cl,%edi
  80223b:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80223f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802242:	89 f2                	mov    %esi,%edx
  802244:	d3 e8                	shr    %cl,%eax
  802246:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  80224a:	d3 e2                	shl    %cl,%edx
  80224c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802250:	09 d0                	or     %edx,%eax
  802252:	d3 ee                	shr    %cl,%esi
  802254:	89 f2                	mov    %esi,%edx
  802256:	f7 75 e4             	divl   -0x1c(%ebp)
  802259:	89 d1                	mov    %edx,%ecx
  80225b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80225e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802261:	f7 e7                	mul    %edi
  802263:	39 d1                	cmp    %edx,%ecx
  802265:	89 c6                	mov    %eax,%esi
  802267:	72 70                	jb     8022d9 <__udivdi3+0x119>
  802269:	39 ca                	cmp    %ecx,%edx
  80226b:	74 5f                	je     8022cc <__udivdi3+0x10c>
  80226d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802270:	31 f6                	xor    %esi,%esi
  802272:	e9 7b ff ff ff       	jmp    8021f2 <__udivdi3+0x32>
  802277:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80227a:	85 c0                	test   %eax,%eax
  80227c:	75 0c                	jne    80228a <__udivdi3+0xca>
  80227e:	b8 01 00 00 00       	mov    $0x1,%eax
  802283:	31 d2                	xor    %edx,%edx
  802285:	f7 75 f4             	divl   -0xc(%ebp)
  802288:	89 c1                	mov    %eax,%ecx
  80228a:	89 f0                	mov    %esi,%eax
  80228c:	89 fa                	mov    %edi,%edx
  80228e:	f7 f1                	div    %ecx
  802290:	89 c6                	mov    %eax,%esi
  802292:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802295:	f7 f1                	div    %ecx
  802297:	89 c1                	mov    %eax,%ecx
  802299:	e9 54 ff ff ff       	jmp    8021f2 <__udivdi3+0x32>
  80229e:	66 90                	xchg   %ax,%ax
  8022a0:	39 d6                	cmp    %edx,%esi
  8022a2:	77 1c                	ja     8022c0 <__udivdi3+0x100>
  8022a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022a7:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  8022aa:	73 14                	jae    8022c0 <__udivdi3+0x100>
  8022ac:	8d 74 26 00          	lea    0x0(%esi),%esi
  8022b0:	31 c9                	xor    %ecx,%ecx
  8022b2:	31 f6                	xor    %esi,%esi
  8022b4:	e9 39 ff ff ff       	jmp    8021f2 <__udivdi3+0x32>
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  8022c0:	b9 01 00 00 00       	mov    $0x1,%ecx
  8022c5:	31 f6                	xor    %esi,%esi
  8022c7:	e9 26 ff ff ff       	jmp    8021f2 <__udivdi3+0x32>
  8022cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8022cf:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  8022d3:	d3 e0                	shl    %cl,%eax
  8022d5:	39 c6                	cmp    %eax,%esi
  8022d7:	76 94                	jbe    80226d <__udivdi3+0xad>
  8022d9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8022dc:	31 f6                	xor    %esi,%esi
  8022de:	83 e9 01             	sub    $0x1,%ecx
  8022e1:	e9 0c ff ff ff       	jmp    8021f2 <__udivdi3+0x32>
	...

008022f0 <__umoddi3>:
  8022f0:	55                   	push   %ebp
  8022f1:	89 e5                	mov    %esp,%ebp
  8022f3:	57                   	push   %edi
  8022f4:	56                   	push   %esi
  8022f5:	83 ec 30             	sub    $0x30,%esp
  8022f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8022fb:	8b 55 14             	mov    0x14(%ebp),%edx
  8022fe:	8b 75 08             	mov    0x8(%ebp),%esi
  802301:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802304:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802307:	89 c1                	mov    %eax,%ecx
  802309:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80230c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80230f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  802316:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80231d:	89 fa                	mov    %edi,%edx
  80231f:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  802322:	85 c0                	test   %eax,%eax
  802324:	89 75 f0             	mov    %esi,-0x10(%ebp)
  802327:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80232a:	75 14                	jne    802340 <__umoddi3+0x50>
  80232c:	39 f9                	cmp    %edi,%ecx
  80232e:	76 60                	jbe    802390 <__umoddi3+0xa0>
  802330:	89 f0                	mov    %esi,%eax
  802332:	f7 f1                	div    %ecx
  802334:	89 55 d0             	mov    %edx,-0x30(%ebp)
  802337:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80233e:	eb 10                	jmp    802350 <__umoddi3+0x60>
  802340:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802343:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  802346:	76 18                	jbe    802360 <__umoddi3+0x70>
  802348:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80234b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80234e:	66 90                	xchg   %ax,%ax
  802350:	8b 45 d0             	mov    -0x30(%ebp),%eax
  802353:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802356:	83 c4 30             	add    $0x30,%esp
  802359:	5e                   	pop    %esi
  80235a:	5f                   	pop    %edi
  80235b:	5d                   	pop    %ebp
  80235c:	c3                   	ret    
  80235d:	8d 76 00             	lea    0x0(%esi),%esi
  802360:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
  802364:	83 f0 1f             	xor    $0x1f,%eax
  802367:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80236a:	75 46                	jne    8023b2 <__umoddi3+0xc2>
  80236c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80236f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  802372:	0f 87 c9 00 00 00    	ja     802441 <__umoddi3+0x151>
  802378:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  80237b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80237e:	0f 83 bd 00 00 00    	jae    802441 <__umoddi3+0x151>
  802384:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802387:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80238a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80238d:	eb c1                	jmp    802350 <__umoddi3+0x60>
  80238f:	90                   	nop    
  802390:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802393:	85 c0                	test   %eax,%eax
  802395:	75 0c                	jne    8023a3 <__umoddi3+0xb3>
  802397:	b8 01 00 00 00       	mov    $0x1,%eax
  80239c:	31 d2                	xor    %edx,%edx
  80239e:	f7 75 ec             	divl   -0x14(%ebp)
  8023a1:	89 c1                	mov    %eax,%ecx
  8023a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023a6:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8023a9:	f7 f1                	div    %ecx
  8023ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023ae:	f7 f1                	div    %ecx
  8023b0:	eb 82                	jmp    802334 <__umoddi3+0x44>
  8023b2:	b8 20 00 00 00       	mov    $0x20,%eax
  8023b7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8023ba:	2b 45 d8             	sub    -0x28(%ebp),%eax
  8023bd:	8b 75 ec             	mov    -0x14(%ebp),%esi
  8023c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8023c3:	89 c1                	mov    %eax,%ecx
  8023c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8023c8:	d3 ea                	shr    %cl,%edx
  8023ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8023cd:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8023d1:	d3 e0                	shl    %cl,%eax
  8023d3:	09 c2                	or     %eax,%edx
  8023d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023d8:	d3 e6                	shl    %cl,%esi
  8023da:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8023de:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8023e1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8023e4:	d3 e8                	shr    %cl,%eax
  8023e6:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8023ea:	d3 e2                	shl    %cl,%edx
  8023ec:	09 d0                	or     %edx,%eax
  8023ee:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8023f1:	d3 e7                	shl    %cl,%edi
  8023f3:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8023f7:	d3 ea                	shr    %cl,%edx
  8023f9:	f7 75 f4             	divl   -0xc(%ebp)
  8023fc:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8023ff:	f7 e6                	mul    %esi
  802401:	39 55 cc             	cmp    %edx,-0x34(%ebp)
  802404:	72 53                	jb     802459 <__umoddi3+0x169>
  802406:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  802409:	74 4a                	je     802455 <__umoddi3+0x165>
  80240b:	90                   	nop    
  80240c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802410:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  802413:	29 c7                	sub    %eax,%edi
  802415:	19 d1                	sbb    %edx,%ecx
  802417:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80241a:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  80241e:	89 fa                	mov    %edi,%edx
  802420:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802423:	d3 ea                	shr    %cl,%edx
  802425:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  802429:	d3 e0                	shl    %cl,%eax
  80242b:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  80242f:	09 c2                	or     %eax,%edx
  802431:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802434:	89 55 d0             	mov    %edx,-0x30(%ebp)
  802437:	d3 e8                	shr    %cl,%eax
  802439:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80243c:	e9 0f ff ff ff       	jmp    802350 <__umoddi3+0x60>
  802441:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802444:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802447:	2b 45 ec             	sub    -0x14(%ebp),%eax
  80244a:	1b 55 e8             	sbb    -0x18(%ebp),%edx
  80244d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802450:	e9 2f ff ff ff       	jmp    802384 <__umoddi3+0x94>
  802455:	39 f8                	cmp    %edi,%eax
  802457:	76 b7                	jbe    802410 <__umoddi3+0x120>
  802459:	29 f0                	sub    %esi,%eax
  80245b:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  80245e:	eb b0                	jmp    802410 <__umoddi3+0x120>
